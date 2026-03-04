





CREATE procedure [dbo].[sp_Crm_Assign_Role_List]
	@userId	nvarchar(300)
	
as
	begin try		
	
		SELECT [assignRole]
			  ,[assignRoleName]
			  ,value	= [assignRole]
			  ,name		= [assignRoleName]
		  FROM CRM_Assign_Role
	 
	end try
	begin catch
		declare	@ErrorNum				int,
				@ErrorMsg				varchar(200),
				@ErrorProc				varchar(50),

				@SessionID				int,
				@AddlInfo				varchar(max)

		set @ErrorNum					= error_number()
		set @ErrorMsg					= 'sp_Crm_Opportunity_Role_List ' + error_message()
		set @ErrorProc					= error_procedure()

		set @AddlInfo					= '@UserID '  

		exec utl_Insert_ErrorLog @ErrorNum, @ErrorMsg, @ErrorProc, 'Opportunity_Role', 'Get', @SessionID, @AddlInfo
	end catch