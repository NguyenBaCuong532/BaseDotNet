



CREATE procedure [dbo].[sp_Crm_Group_Del]
	@GroupId nvarchar(50)
	
as
	begin try	
		 delete from [dbo].[CRM_Group] 
		 where GroupId = @GroupId;

		 select  1 as valid, 'success' as messages
	end try
	begin catch
		declare	@ErrorNum				int,
				@ErrorMsg				varchar(200),
				@ErrorProc				varchar(50),

				@SessionID				int,
				@AddlInfo				varchar(max)

		
		set @ErrorNum					= error_number()
		set @ErrorMsg					= '[sp_Crm_Delete_Group]' + error_message()
		set @ErrorProc					= error_procedure()

		set @AddlInfo					= ''
		select  0 as valid, @ErrorMsg as messages
		exec utl_Insert_ErrorLog @ErrorNum, @ErrorMsg, @ErrorProc, 'Group', 'DEL', @SessionID, @AddlInfo
	end catch