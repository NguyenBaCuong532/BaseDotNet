








CREATE procedure [dbo].[sp_Crm_Note_Set]
	@UserId	nvarchar(450), 
	@Id nvarchar(450),
	@CustId nvarchar(450),
	@Content nvarchar(max),
	@AttachmentUrl nvarchar(max),
	@SharingUserId  nvarchar(max)
as
	 
	begin try 
		 if not exists(select Id from [CRM_Notes] where Id = isnull(@Id,''))
			begin
				set @Id = newid()
				insert into CRM_Notes(Id, Custid, UserId, Contents, Created)
				values(@Id, @CustId, @UserId, @Content, getdate());
				insert into [CRM_SharingNotes](NoteId, UserId, [Status])
				values(@Id, @UserId, 1);
				
			end
		 else
			begin
				update CRM_Notes 
				set Contents = @Content
				, Updated = getdate()
				where Id = @Id;
			end 
		if(@AttachmentUrl is not null
			and @AttachmentUrl != '') 
			begin
				delete from CRM_Attachment where Type = 'NOTE_ATTACHMENT' and ObjectId = @Id;
				insert into CRM_Attachment(ObjectId, AttachmentUrl, [Type])
				SELECT @Id, [part], 'NOTE_ATTACHMENT' FROM [dbo].[SplitString](@AttachmentUrl,',') ;
			end
		if(@SharingUserId is not null and @SharingUserId != '')
		begin 
			exec [sp_Crm_Insert_SharingNote] @UserId ,  @Id ,  @SharingUserId 
		end
		 exec sp_Crm_Get_Note_ById @Id
		
	end try
	begin catch
		declare	@ErrorNum				int,
				@ErrorMsg				varchar(200),
				@ErrorProc				varchar(50),

				@SessionID				int,
				@AddlInfo				varchar(max)

		set @ErrorNum					= error_number()
		set @ErrorMsg					= '[sp_Crm_Insert_Note] ' + error_message()
		set @ErrorProc					= error_procedure()

		set @AddlInfo					= '@Id ' + cast(@Id as nvarchar)

		exec utl_Insert_ErrorLog @ErrorNum, @ErrorMsg, @ErrorProc, 'Note', 'Save', @SessionID, @AddlInfo
	end catch