

CREATE procedure [dbo].[sp_user_project_trees]
	@userId			nvarchar(450),
	@parentId		nvarchar(max) = null,
	@rootId			nvarchar(50) out

as
	begin try
		declare @orgId		uniqueidentifier
		if @orgId is null set @orgId = (select orgId from users x where x.userId = @userId)
		
		set @parentId = isnull(@parentId,'')
		
		set @rootId = @orgId
		--
		SELECT [key]	= ''
			,label		= N'Tất cả' 
			,data		= @orgId
			,icon		= 'pi-folder'
			,expandedIcon  = 'pi-folder-open'
			,collapsedIcon	= 'pi-folder-close'
			,[parentId] = null
			,Id			= @orgId
		union all
		SELECT [key]	= a.projectCd 
			,label		= a.projectName 
			,data		= a.projectCd--cast(a.orgDepId as varchar(50)) 
			,icon		= case when exists(select 1 from MAS_Projects x where x.projectCd = a.sub_projectCd) then 'pi-folder'
						else 'pi pi-file' end
			,expandedIcon  = case when exists(select 1 from MAS_Projects x where x.projectCd = a.sub_projectCd) then 'pi-folder-open'
						else 'pi pi-file' end
			,collapsedIcon	= 'pi-folder-close'
			,[parentId] = @orgId
			,Id			= a.projectCd
		FROM MAS_Projects a
		--where (@parentId = '' or exists(select 1 from SplitString(@parentId,',') where cast(part as nvarchar(50)) = a.projectCd))
		where (a.orgid is null or a.orgId = @orgId)

	end try
	begin catch
		declare	@ErrorNum				int,
				@ErrorMsg				varchar(200),
				@ErrorProc				varchar(50),

				@SessionID				int,
				@AddlInfo				varchar(max)

		set @ErrorNum					= error_number()
		set @ErrorMsg					= 'sp_hrm_organize_bytree ' + error_message()
		set @ErrorProc					= error_procedure()

		set @AddlInfo					= ' '

		exec utl_ErrorLog_Set @ErrorNum, @ErrorMsg, @ErrorProc, 'org', 'GET', @SessionID, @AddlInfo
	end catch