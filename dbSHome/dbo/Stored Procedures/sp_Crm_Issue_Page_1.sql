

CREATE procedure [dbo].[sp_Crm_Issue_Page]
	@UserId		nvarchar(450), 
	@clientId	nvarchar(50) = null,
	@ProjectCd	nvarchar(20),
	@Status		int,
	@Filter		nvarchar(30),
	@gridWidth			int				= 0,
	@Offset				int				= 0,
	@PageSize			int				= 10,
	@Total				int out,
	@TotalFiltered		int out
	,@gridKey			nvarchar(200) out
as
	begin try 
		
		set		@Offset					= isnull(@Offset, 0)
		set		@PageSize				= isnull(@PageSize, 10)
		set		@Total					= isnull(@Total, 0)
		set		@ProjectCd				= isnull(@ProjectCd,'')
		set		@filter					= isnull(@filter,'')
		--set		@CustId					= isnull(@CustId,'')

		if		@PageSize	<= 0			set @PageSize	= 10
		if		@Offset		< 0			set @Offset		=  0
		
		
		select	@Total					= count(a.IssueId)
			from CRM_Issues a 
				join MAS_Customers b on a.CustId = b.CustId
			where exists(select 1 from UserProject c where userId = @UserId and (@ProjectCd = '' or c.projectCd = @projectCd))
				and (@Status = -1 or a.issue_st = @Status)
				and (a.createBy = @UserId or exists(select userid from CRM_Issue_Assign s where IssueId = a.issueId and s.userId = @UserId))
				and (b.Phone like @filter + '%' or b.Email like @filter + '%' or b.FullName like @filter + '%')
				

			set	@TotalFiltered = @Total

			if @Offset = 0
			begin
				SELECT * FROM [dbo].[fn_config_list_gets] ('view_Crm_Issue_Page', @gridWidth) 
				ORDER BY [ordinal]

				SELECT -1 as [statusId]
					  ,N'Tất cả' as [statusName]
					  ,isnull(aa.id_count,0) as statusCount
					  ,null [color]
				FROM (select count(issueId) as id_count 
						from CRM_Issues a
							join MAS_Customers b on a.CustId = b.CustId
							--join @tbCats ca on a.projectCd = ca.categoryCd
						where exists(select 1 from UserProject c where userId = @UserId and (@ProjectCd = '' or c.projectCd = @projectCd))
							and (a.createBy = @UserId or exists(select userid from CRM_Issue_Assign s where IssueId = a.issueId and s.userId = @UserId))
							and (b.Phone like @filter + '%' or b.Email like @filter + '%' or b.FullName like @filter + '%')
						) aa
				union all
				SELECT [statusId]
					  ,[statusName]
					  ,isnull(aa.id_count,0) as statusCount
					  ,[color]
				  FROM [dbSHome].[dbo].[CRM_Status] st
					left join (select count(issueId) as id_count, issue_st 
						from CRM_Issues a
							join MAS_Customers b on a.CustId = b.CustId
							--join @tbCats ca on a.projectCd = ca.categoryCd
						where exists(select 1 from UserProject c where userId = @UserId and (@ProjectCd = '' or c.projectCd = @projectCd))
							and (a.createby = @UserId or exists(select userid from CRM_Issue_Assign s where issueId = a.issueId and s.userId = @UserId))
							and (b.Phone like @filter + '%' or b.Email like @filter + '%' or b.FullName like @filter + '%')
						group by issue_st) aa on st.statusId = aa.issue_st
				  WHERE [statusKey] = 'Issue'
				  ORDER BY [statusId]
			end
	
		  --1
		  SELECT [IssueId]
				,[ProjectCd]
				,[IssueType]
				,[Summary]
				,[Description]
				,[SecurityLevel]
				,[CreateBy]
				,[CreateDt]
				,[SubStatus]
				,[Priority]
				,[Serverity]
				,STUFF((
				  SELECT ',' +  cu.loginName 
				  FROM CRM_Issue_Assign ca 
					join Users cu
					 on ca.UserId = cu.UserId
				  WHERE ca.IssueId = a.IssueId and (assignRole = 2)
				  order by cu.loginName 
				  FOR XML PATH('')), 1, 1, '') as [Assignee]
				,STUFF((
				  SELECT ',' +  cu.loginName 
				  FROM CRM_Issue_Assign ca 
					join Users cu
					 on ca.UserId = cu.UserId
				  WHERE ca.IssueId = a.IssueId and (assignRole = 1)
				  order by cu.loginName 
				  FOR XML PATH('')), 1, 1, '') as [ReporterTo]
				,a.[StartDt]
				,[DueDt]
				,[DueCustDt]
				,[SubType]
				,[Requestor]
				,[Impart]
				,[Feedback]
				,[CauseIssue]
				,[CPAction]
				,[IssueLevel]
				,[Solution]
				,b.FullName 
				,u.loginName as CreateByName
				,b.Phone
				,b.Email
				,a.issue_st 
				,case a.issue_st when 0 then N'Mới tạo' when 1 then N'Đang xử lý' when 2 then N'Đã xong' when 3 then N'Đóng' end as StatusName
				,(select max(ProcessDt) from CRM_Issue_Process where IssueId = a.IssueId) as StatusDate
		 FROM CRM_Issues a
			--join @tbCats ca on a.projectCd = ca.categoryCd
			join MAS_Customers b on a.CustId = b.CustId
			left join Users u on a.CreateBy = u.UserId 
			where exists(select 1 from UserProject c where userId = @UserId and (@ProjectCd = '' or c.projectCd = @projectCd))
				and (@Status = -1 or a.issue_st = @Status)
				and (a.createBy = @UserId or exists(select userid from CRM_Issue_Assign s where IssueId = a.issueId and s.userId = @UserId))
				and (b.Phone like @filter + '%' or b.Email like @filter + '%' or b.FullName like @filter + '%')
		ORDER BY a.[CreateDt] DESC, a.[Summary]
					  offset @Offset rows	
						fetch next @PageSize rows only
	

	end try
	begin catch
		declare	@ErrorNum				int,
				@ErrorMsg				varchar(200),
				@ErrorProc				varchar(50),

				@SessionID				int,
				@AddlInfo				varchar(max)

		set @ErrorNum					= error_number()
		set @ErrorMsg					= 'sp_Crm_Complain_Page ' + error_message()
		set @ErrorProc					= error_procedure()

		set @AddlInfo					= ' '

		exec utl_Insert_ErrorLog @ErrorNum, @ErrorMsg, @ErrorProc, 'Complain', 'GET', @SessionID, @AddlInfo
	end catch