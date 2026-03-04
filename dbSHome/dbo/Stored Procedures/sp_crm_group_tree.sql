


CREATE procedure [dbo].[sp_crm_group_tree]
	@userId			nvarchar(450),
	--@parentId		int,
	@rootId			int out

as
	begin try
		set @rootId = 0

		SELECT [key]		= cast(1 as varchar(100))
			,label			= N'Tất cả'
			,data			= 1
			,icon			= 'pi pi-file' 
			,expandedIcon	= 'pi pi-file' 
			,collapsedIcon	= 'pi-folder-close'
			,id				= 1
			,[parentId]		= @rootId
			,int_order		= 0
		--FROM [MAS_Base_Type] a
		union all
		SELECT [key]		= GroupId
			,label			= a.HiddenName
			,data			= GroupId
			,icon			= 'pi pi-file' 
			,expandedIcon	= 'pi pi-file' 
			,collapsedIcon	= 'pi-folder-close'			
			,id				= GroupId
			,[parentId]		= a.ParentId
			,int_order		= a.GroupId
		FROM CRM_Group a
			where a.[IsActive] = 1
		order by int_order
		

	end try
	begin catch
		declare	@ErrorNum				int,
				@ErrorMsg				varchar(200),
				@ErrorProc				varchar(50),

				@SessionID				int,
				@AddlInfo				varchar(max)

		set @ErrorNum					= error_number()
		set @ErrorMsg					= 'sp_crm_group_tree ' + error_message()
		set @ErrorProc					= error_procedure()

		set @AddlInfo					= ' '

		exec utl_ErrorLog_Set @ErrorNum, @ErrorMsg, @ErrorProc, 'org', 'GET', @SessionID, @AddlInfo
	end catch