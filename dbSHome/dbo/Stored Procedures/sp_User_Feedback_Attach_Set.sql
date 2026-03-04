


-- ======================================================
	CREATE PROCEDURE [dbo].[sp_User_Feedback_Attach_Set]
		@UserId			nvarchar (450), 
		@id				bigint,
		@feedbackId		bigint,
		@processId		bigint,
		@AttachUrl		nvarchar(450),
		@attachType		nvarchar(50),
		@attachFileName nvarchar(200),
		@used bit
	AS 
begin try
	if @used = 1
	begin
	IF EXISTS (SELECT id FROM dbo.MAS_FeedbackAttach WHERE id = @id) 
		BEGIN
			UPDATE [dbo].MAS_FeedbackAttach
			   SET [feedbackId] = @feedbackId
				  ,[processId] = @processId
				  ,[attachUrl] = @attachUrl
				  ,[attachType] = @attachType
				  ,attachFileName = @attachFileName
				  ,[createDt] = getdate()
			 WHERE id = @Id 
		END 
		ELSE 
		BEGIN
				INSERT INTO [dbo].MAS_FeedbackAttach
					   ([feedbackId]
					   ,[processId]
					   ,[attachUrl]
					   ,[attachType]
					   ,attachFileName
					   ,[createDt])
				 VALUES
					   (@feedbackId
					   ,@processId
					   ,@attachUrl
					   ,@attachType
					   ,@attachFileName
					   ,getdate())
				set @Id = @@IDENTITY
		END 
	end
	else
	begin
		delete from MAS_FeedbackAttach where id = @id
	end
end try
	begin catch
	 DECLARE
			@ErrorNum INT,
			@ErrorMsg VARCHAR(200),
			@ErrorProc VARCHAR(50),
			@SessionID INT,
			@AddlInfo VARCHAR (MAX) 
			SET @ErrorNum = error_number( ) 
			SET @ErrorMsg = 'sp_User_Feedback_Attach_Set ' + error_message() 
			SET @ErrorProc = error_procedure() 
			SET @AddlInfo = ' ' 
		EXEC utl_Insert_ErrorLog @ErrorNum, @ErrorMsg, @ErrorProc,'Set','Feedback_Attach', @SessionID, @AddlInfo 
	END catch