


CREATE procedure [dbo].[sp_res_document_set]
    @UserID			nvarchar(450),
	@DocId int,
	@ProjectCd nvarchar(30),
	@DocumentTitle nvarchar(200),
	@DocumentUrl nvarchar(300),
	@IsUsed bit
	
as
	begin try		
		if @IsUsed = 1 
		begin	
			IF not exists(select DocId from [TRS_DocumentUrl] where DocId = @DocId)
				INSERT INTO [dbo].[TRS_DocumentUrl]
				   ([DocumentTitle]
				   ,[DocumentUrl]
				   ,[InputDt]
				   ,ProjectCd)
				VALUES
				   (@DocumentTitle
				   ,@DocumentUrl
				   ,getdate()
				   ,@ProjectCd
				   )
		end
		else
			delete from [TRS_DocumentUrl] where DocId = @DocId

	end try
	begin catch
		declare	@ErrorNum				int,
				@ErrorMsg				varchar(200),
				@ErrorProc				varchar(50),

				@SessionID				int,
				@AddlInfo				varchar(max)

		set @ErrorNum					= error_number()
		set @ErrorMsg					= 'sp_Insert_DocumentUrl ' + error_message()
		set @ErrorProc					= error_procedure()

		set @AddlInfo					= '@Id ' + @DocId

		exec utl_Insert_ErrorLog @ErrorNum, @ErrorMsg, @ErrorProc, 'Document', 'Insert', @SessionID, @AddlInfo
	end catch