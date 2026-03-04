








CREATE procedure [dbo].[sp_Crm_Note_Sharing]
	@UserId	nvarchar(450), 
	@NoteId nvarchar(450), 
	@SharingUserId nvarchar(450)
as
	 
	begin try 
		 if not exists(select NoteId from [CRM_SharingNotes] where NoteId = isnull(@NoteId,'') and UserId = @SharingUserId)
			begin
				 insert into [CRM_SharingNotes](NoteId, UserId, [Status])
				 values(@NoteId, @SharingUserId, 1);
			end
		-- 1
		select NoteId as Id from [CRM_SharingNotes] where NoteId = isnull(@NoteId,'') and UserId = @SharingUserId; 
		-- 2
		select NoteId
		, [Status]
		, UserId 
		from [CRM_SharingNotes] where NoteId = isnull(@NoteId,'') and UserId = @SharingUserId
		
	end try
	begin catch
		declare	@ErrorNum				int,
				@ErrorMsg				varchar(200),
				@ErrorProc				varchar(50),

				@SessionID				int,
				@AddlInfo				varchar(max)

		set @ErrorNum					= error_number()
		set @ErrorMsg					= '[sp_Crm_Insert_SharingNote] ' + error_message()
		set @ErrorProc					= error_procedure()

		set @AddlInfo					= '@Id ' + cast(@NoteId as nvarchar)

		exec utl_Insert_ErrorLog @ErrorNum, @ErrorMsg, @ErrorProc, 'Note', 'insert', @SessionID, @AddlInfo
	end catch