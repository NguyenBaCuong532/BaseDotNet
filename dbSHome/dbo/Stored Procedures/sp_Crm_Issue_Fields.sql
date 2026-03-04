

CREATE procedure [dbo].[sp_Crm_Issue_Fields]
	@userId nvarchar(450),
	@id nvarchar(100),
	@custId nvarchar(50)
as
	begin try

		if exists(select IssueId from CRM_Issues where IssueId = @id)
			begin
				select issueId
					  ,issue_st
					  ,thread_id
					  ,custId
				from CRM_Issues 
				where IssueId = @id
				--1
				SELECT objvalue as group_cd
					  ,objname as group_name 
					FROM [dbo].[fn_config_data_gets] ('issue_field_group') 
				   order by intOrder
				--2
				SELECT a.id
					  ,table_name
					  ,field_name
					  ,view_type
					  ,data_type
					  ,ordinal
					  ,columnLabel
					  ,a.group_cd
					   ,case data_type when 'nvarchar' then convert(nvarchar(350), case field_name 
							when 'opp_cd' then b.causeIssue
							when 'projectCd' then b.projectCd
							when 'fullName' then c.fullName
							when 'phone' then c.phone
							when 'email' then c.email
							when 'address' then c.address
							when 'longing' then b.summary
							when 'offer' then b.description
							when 'feedback' then b.feedback
							when 'source' then b.cPAction
							when 'solution' then b.solution
							when 'description' then b.description
							when 'summary' then b.summary
							when 'cPAction' then b.cPAction
							when 'issueLevel' then b.issueLevel
							when 'causeIssue' then b.causeIssue
							when 'impart' then b.impart
						  end
						  ) 
					  when 'datetime' then convert(nvarchar(10), case field_name 
						  when 'startDt' then b.startDt
						  when 'dueCustDt' then b.dueCustDt
						  when 'dueDt' then b.dueDt
						  end, 103)
					  else convert(nvarchar(50), case field_name 
						  when 'issueType' then b.issueType 
						  when 'securityLevel' then b.securityLevel 
						  when 'issueId' then b.issueId
						  when 'subStatus' then b.subStatus
						  when 'priority' then b.priority
						  when 'serverity' then b.serverity
						  when 'subType' then b.subType
						    end)
						end as columnValue
					  ,columnClass
					  ,columnType
					  ,columnObject
					  ,isSpecial
					  ,isRequire
					  ,isDisable
					  ,isVisiable
					  ,[IsEmpty]
					  ,isnull(a.columnTooltip,[columnLabel]) as columnTooltip
				  FROM (select a.* from sys_config_form a
					where a.table_name = 'CRM_Issues' 
				  and (isVisiable = 1 or isRequire =1)) a
				  ,(select b.* from CRM_Issues b 						
						where b.issueId = @id) b
						join MAS_Customers c on c.CustId = b.CustId
				  order by ordinal
			--3
			SELECT [assignRole]
				  ,[assignRoleName]
			  FROM CRM_Assign_Role
			--4
			SELECT a.[Id]
				  ,a.IssueId
				  ,a.[userId]
				  ,a.[assignRole]
				  ,b.loginName as userName
				  ,1 as Used
				  ,b.fullName 
				  ,b.avatarUrl
				  ,b.phone 
				  ,b.email
			  FROM [dbSHome].[dbo].CRM_Issue_Assign a
			  join UserInfo b on a.userId = b.userId 
				WHERE a.IssueId = @id

			end
		else
			begin
				select @id as issueId
				      ,0 as issue_st 
					  ,cast(newid() as nvarchar(150)) as thread_id
					  ,@custId as custId
					--1
				SELECT *
					FROM [dbo].[fn_get_field_group] ('issue_field_group') 
				   order by intOrder
				--2
				SELECT [id]
					  ,[table_name]
					  ,[field_name]
					  ,[view_type]
					  ,[data_type]
					  ,[ordinal]
					  ,[columnLabel]
					  ,[group_cd]
					  , case data_type when 'nvarchar' then convert(nvarchar(350), case field_name 
							when 'opp_cd' then ''
							when 'projectCd' then ''
							when 'fullName' then c.fullName
							when 'phone' then c.phone
							when 'email' then c.email
							when 'address' then c.address
							when 'longing' then ''
							when 'offer' then ''
							when 'feedback' then ''
							when 'source' then ''
							when 'solution' then ''
							when 'description' then ''
							when 'summary' then ''
						  end
						  ) 
					  when 'datetime' then convert(nvarchar(10), case field_name 
						  when 'startDt' then ''
						  when 'dueDt' then ''
						  end, 103)
					  else convert(nvarchar(50), case field_name 
						  when 'issueType' then ''
						  when 'securityLevel' then '' 
						  when 'issueId' then ''
						  when 'subStatus' then ''
						  when 'priority' then ''
						  when 'serverity' then ''
						  when 'subType' then ''
						    end)
						end as columnValue
					  ,[columnClass]
					  ,[columnType]
					  ,[columnObject]
					  ,[isSpecial]
					  ,[isRequire]
					  ,[isDisable]
					  ,[isVisiable]
					  ,[IsEmpty]
					  ,isnull(a.columnTooltip,[columnLabel]) as columnTooltip
				 FROM sys_config_form a,
				 MAS_Customers c
				 where a.table_name = 'CRM_Issues'
				  and a.isvisiable = 1
				  and c.CustId = @custId
				 order by ordinal
			--3
			SELECT [assignRole]
				  ,[assignRoleName]
			  FROM [dbSHome].[dbo].[CRM_Assign_Role]
			--4
			SELECT 0 as Id
				  ,@id as [IssueId]
				  ,a.[userId]
				  ,1 as [assignRole]
				  ,b.loginName as userName
				  ,1 as Used
				  ,b.fullName 
				  ,b.avatarUrl
				  ,b.phone 
				  ,b.email
			  FROM Users a
			  join UserInfo b on a.parent_id = b.userId 
				WHERE a.userId = @userId and a.parent_id <> @userId
			UNION
			SELECT 0 as Id
				  ,@id as [IssueId]
				  ,a.[userId]
				  ,2 as [assignRole]
				  ,b.loginName as userName
				  ,1 as Used
				  ,b.fullName 
				  ,b.avatarUrl
				  ,b.phone 
				  ,b.email
			  FROM Users a
			  join UserInfo b on a.userId = b.userId 
				WHERE a.userId = @userId
		
		end
		
		SELECT [id]
			  ,[IssueId]
			  ,[processId]
			  ,[attachUrl]
			  ,[attachType]
			  ,attachFileName
			  ,1 as used
			  ,[createDt]
		  FROM CRM_Issue_Attach
		  where IssueId = @id and processId = 0

	end try
	begin catch
		declare	@ErrorNum				int,
				@ErrorMsg				varchar(200),
				@ErrorProc				varchar(50),

				@SessionID				int,
				@AddlInfo				varchar(max)

		set @ErrorNum					= error_number()
		set @ErrorMsg					= 'sp_Crm_Issue_Fields ' + error_message()
		set @ErrorProc					= error_procedure()

		set @AddlInfo					= ' '

		exec utl_Insert_ErrorLog @ErrorNum, @ErrorMsg, @ErrorProc, 'Issue_Fields', 'GET', @SessionID, @AddlInfo
	end catch