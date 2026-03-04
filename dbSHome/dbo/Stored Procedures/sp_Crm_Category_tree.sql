


CREATE procedure [dbo].[sp_Crm_Category_tree]
	@userId			nvarchar(450),
	--@parentId		uniqueidentifier,
	@rootId			nvarchar(50) out

as
	begin try
		set @rootId = '0'

		
		SELECT [key]		= cast(a.[base_type] as varchar(100))
			,label			= a.[base_name] + '-' + a.base_desc
			,data			= cast(a.[base_type] as nvarchar(100))
			,icon			= 'pi pi-file' 
			,expandedIcon	= 'pi pi-file' 
			,collapsedIcon	= 'pi-folder-close'
			,id				= cast(a.[base_type] as nvarchar(100))
			,[parentId]		= @rootId
			,int_order		= [base_type]
		FROM [MAS_Base_Type] a
		union all
		SELECT [key]		= [CategoryCd]
			,label			= a.[CategoryName]
			,data			= a.[CategoryCd]
			,icon			= 'pi pi-file' 
			,expandedIcon	= 'pi pi-file' 
			,collapsedIcon	= 'pi-folder-close'			
			,id				= a.[CategoryCd]
			,[parentId]		= cast(a.[base_type] as nvarchar(100))
			,int_order		= a.[intOrder]
		FROM [MAS_Category] a
			join [MAS_Base_Type] b on a.base_type = b.base_type
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
		set @ErrorMsg					= 'sp_user_report_bytree ' + error_message()
		set @ErrorProc					= error_procedure()

		set @AddlInfo					= ' '

		exec utl_ErrorLog_Set @ErrorNum, @ErrorMsg, @ErrorProc, 'org', 'GET', @SessionID, @AddlInfo
	end catch