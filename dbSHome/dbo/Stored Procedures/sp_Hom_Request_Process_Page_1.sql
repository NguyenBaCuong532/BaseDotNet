







CREATE procedure [dbo].[sp_Hom_Request_Process_Page]
	@UserId	nvarchar(450),
	@requestId	bigint,
	@Filter		nvarchar(30),
	@Offset				int				= 0,
	@PageSize			int				= 10,
	@Total				int out,
	@TotalFiltered		int out

as
	begin try
		set		@Offset					= isnull(@Offset, 0)
		set		@PageSize				= isnull(@PageSize, 10)
		set		@Total					= isnull(@Total, 0)
		set		@filter					= isnull(@filter,'')

		if		@PageSize	= 0			set @PageSize	= 10
		if		@Offset		< 0			set @Offset		=  0

		select	@Total					= count(a.requestId)
			FROM [MAS_Request_Process] a 
				left Join Users b On a.userId = b.UserId --and a.assignRole = 1
				--left Join MAS_Customers c On a.CustId = c.CustId and (a.assignRole = 2 or a.assignRole is null)
			Where requestId = @requestId
				and (@Filter = '' or b.loginName = @Filter or b.Phone = @Filter)
				--and (a.[Comment] like '%' + @Filter + '%' OR a.statusId like '%' + @Filter + '%')
			set	@TotalFiltered = @Total

			if @PageSize < 0
			begin
				set	@PageSize				= 10
			end

	--2
		SELECT ProcessId
			  ,requestId
			  ,[Comment]
			  ,dbo.fn_Get_TimeAgo1(a.ProcessDt,getdate()) as ProcessDate
			  ,b.loginName as UserName
			  --,b.a
			  ,case when a.UserId = @UserId then 0 else 0 end as IsOwn
			  ,a.Status
			  ,s.StatusName
			  --,s.color 
		FROM [MAS_Request_Process] a 
			left Join Users b On a.userId = b.UserId --and a.assignRole = 1
			--left Join MAS_Customers c On a.CustId = c.CustId and (a.assignRole = 0 or a.assignRole is null)
			left join CRM_Status s on a.Status = s.StatusId and s.statusKey = 'Request'
		Where requestId = @requestId 
			and (@Filter = '' or b.loginName = @Filter or b.Phone = @Filter)
			--and (a.[Comment] like '%' + @Filter + '%' OR a.statusId like '%' + @Filter + '%')
		order by ProcessDt desc
					  offset @Offset rows	
						fetch next @PageSize rows only
	
		SELECT [id]
			  ,requestId
			  ,[processId]
			  ,[attachUrl]
			  ,[attachType]
			  ,attachFileName
			  ,1 as used
			  ,[createDt]
		  FROM [dbSHome].[dbo].[MAS_Request_Attach]
		  where requestId = @requestId and processId > 0

	end try
	begin catch
		declare	@ErrorNum				int,
				@ErrorMsg				varchar(200),
				@ErrorProc				varchar(50),

				@SessionID				int,
				@AddlInfo				varchar(max)

		set @ErrorNum					= error_number()
		set @ErrorMsg					= 'sp_Hom_Request_Process_Page ' + error_message()
		set @ErrorProc					= error_procedure()

		set @AddlInfo					= ' '

		exec utl_Insert_ErrorLog @ErrorNum, @ErrorMsg, @ErrorProc, 'Request_Process', 'GET', @SessionID, @AddlInfo
	end catch