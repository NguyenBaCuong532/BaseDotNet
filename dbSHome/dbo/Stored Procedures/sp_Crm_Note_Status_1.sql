








CREATE procedure [dbo].[sp_Crm_Note_Status]
	@UserId	nvarchar(450), 
	@Id nvarchar(450), 
	@Status int
as
	 
	begin try 
		 update [CRM_SharingNotes]
				set [Status] = @Status
				where NoteId = @Id and UserId = @UserId;
		 exec sp_Crm_Get_Note_ById @Id
		
	end try
	begin catch
		declare	@ErrorNum				int,
				@ErrorMsg				varchar(200),
				@ErrorProc				varchar(50),

				@SessionID				int,
				@AddlInfo				varchar(max)

		set @ErrorNum					= error_number()
		set @ErrorMsg					= '[sp_Crm_Update_NoteStatus] ' + error_message()
		set @ErrorProc					= error_procedure()

		set @AddlInfo					= '@Id ' + cast(@Id as nvarchar)

		exec utl_Insert_ErrorLog @ErrorNum, @ErrorMsg, @ErrorProc, 'Note', 'Update', @SessionID, @AddlInfo
	end catch