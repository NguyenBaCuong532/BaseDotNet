






CREATE procedure [dbo].[sp_Crm_Issue_Process_Page]
	@UserId	nvarchar(450),
	@Offset				int				= 0,
	@PageSize			int				= 10,
	@IssueId bigint,
	@Filter nvarchar(30),
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

		select	@Total					= count(a.IssueId)
			FROM [CRM_Issue_Process] a 
				left Join Users b On a.userId = b.UserId and a.assignRole = 1
				left Join MAS_Customers c On a.CustId = c.CustId and (a.assignRole = 2 or a.assignRole is null)
			Where IssueId = @IssueId
				and (a.[Comment] like '%' + @Filter + '%' OR a.statusId like '%' + @Filter + '%')
			set	@TotalFiltered = @Total

			if @PageSize < 0
			begin
				set	@PageSize				= 10
			end

	--2
		SELECT ProcessId
			  ,IssueId
			  ,[Comment]
			  ,dbo.fn_Get_TimeAgo1(a.ProcessDt,getdate()) as ProcessDate
			  ,isnull(b.loginName,c.FullName) as UserName
			  --,b.AvatarUrl
			  ,case when a.UserId = @UserId then 0 else 0 end as IsOwn
			  ,a.statusId
			  ,s.StatusName
			  ,s.color 
		FROM [CRM_Issue_Process] a 
			left Join Users b On a.userId = b.UserId and a.assignRole = 1
			left Join MAS_Customers c On a.CustId = c.CustId and (a.assignRole = 0 or a.assignRole is null)
			left join CRM_Status s on a.statusId = s.StatusId
		Where IssueId = @IssueId 
			and s.statusKey = 'issue'
			and (a.[Comment] like '%' + @Filter + '%' OR a.statusId like '%' + @Filter + '%')
		order by ProcessDt desc
					  offset @Offset rows	
						fetch next @PageSize rows only
	
		SELECT [id]
			  ,issueId
			  ,[processId]
			  ,[attachUrl]
			  ,[attachType]
			  ,attachFileName
			  ,1 as used
			  ,[createDt]
		  FROM [dbSHome].[dbo].[CRM_Issue_Attach]
		  where issueId = @IssueId and processId > 0

	end try
	begin catch
		declare	@ErrorNum				int,
				@ErrorMsg				varchar(200),
				@ErrorProc				varchar(50),

				@SessionID				int,
				@AddlInfo				varchar(max)

		set @ErrorNum					= error_number()
		set @ErrorMsg					= 'sp_Crm_Issue_Process_Page ' + error_message()
		set @ErrorProc					= error_procedure()

		set @AddlInfo					= ' '

		exec utl_Insert_ErrorLog @ErrorNum, @ErrorMsg, @ErrorProc, 'IssueProccess', 'GET', @SessionID, @AddlInfo
	end catch