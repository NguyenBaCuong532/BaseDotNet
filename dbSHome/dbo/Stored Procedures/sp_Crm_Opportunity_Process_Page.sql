







CREATE procedure [dbo].[sp_Crm_Opportunity_Process_Page]
	@UserId	nvarchar(450),
	@Offset				int				= 0,
	@PageSize			int				= 10,
	@opp_Id bigint,
	@Filter nvarchar(30),
	@gridWidth			int				= 0,
	@Total				int out,
	@TotalFiltered		int out
	,@gridKey			nvarchar(200) out

as
	begin try
		set		@Offset					= isnull(@Offset, 0)
		set		@PageSize				= isnull(@PageSize, 10)
		set		@Total					= isnull(@Total, 0)
		set		@filter					= isnull(@filter,'')

		if		@PageSize	= 0			set @PageSize	= 10
		if		@Offset		< 0			set @Offset		=  0

		select	@Total					= count(a.opp_Id)
			FROM CRM_Opportunity_Process a 
				left Join MAS_Users b On a.userId = b.UserId --and a.IsManager = 1
				left Join CRM_Opportunity c On a.opp_Id = c.Id -- and (a.IsManager = 0 or a.IsManager is null)
			Where opp_Id = @opp_Id
				and [Comment] like '%' + @Filter + '%'
			set	@TotalFiltered = @Total

			if @PageSize < 0
			begin
				set	@PageSize				= 10
			end

	--2
		SELECT ProcessId
			  ,opp_Id
			  ,[Comment]
			  ,dbo.fn_Get_TimeAgo1(a.ProcessDt,getdate()) as ProcessDate
			  ,isnull(b.UserLogin,c.FullName) as UserName
			  ,b.AvatarUrl
			  ,case when a.UserId = @UserId then 0 else 0 end as IsOwn
			  ,a.statusId
			  ,s.StatusName
			  ,approve_st 
			  ,approve_dt 
			  ,p.UserLogin as approve_by 
			  ,s.color
		FROM CRM_Opportunity_Process a 
			left Join MAS_Users b On a.userId = b.UserId 
			left Join CRM_Opportunity c On a.opp_Id = c.Id 
			left join CRM_Status s on a.statusId = s.StatusId
			left Join MAS_Users p On a.approve_by = p.UserId 
		Where opp_Id = @opp_Id 
			and s.statusKey = 'opportunity'
			and a.[Comment] like '%' + @Filter + '%'
		order by ProcessDt desc
					  offset @Offset rows	
						fetch next @PageSize rows only
		
		SELECT [id]
			  ,[opp_Id]
			  ,[processId]
			  ,[attachUrl]
			  ,[attachType]
			  ,attachFileName
			  ,1 as used
			  ,[createDt]
		  FROM [dbSHome].[dbo].[CRM_Opportunity_Attach]
		  where opp_Id = @opp_Id and processId > 0

	end try
	begin catch
		declare	@ErrorNum				int,
				@ErrorMsg				varchar(200),
				@ErrorProc				varchar(50),

				@SessionID				int,
				@AddlInfo				varchar(max)

		set @ErrorNum					= error_number()
		set @ErrorMsg					= 'sp_Crm_Opportunity_Process_Page ' + error_message()
		set @ErrorProc					= error_procedure()

		set @AddlInfo					= ' '

		exec utl_Insert_ErrorLog @ErrorNum, @ErrorMsg, @ErrorProc, 'OppComment', 'GET', @SessionID, @AddlInfo
	end catch