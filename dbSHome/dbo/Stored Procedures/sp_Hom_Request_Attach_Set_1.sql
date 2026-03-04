

-- ======================================================
	CREATE PROCEDURE [dbo].[sp_Hom_Request_Attach_Set]
		@UserId		nvarchar (450), 
		@id			bigint,
		@requestId		bigint,
		@processId	bigint,
		@AttachUrl	nvarchar(450),
		@attachType nvarchar(50),
		@attachFileName nvarchar(200),
		@used bit
	AS 
begin try
	if @used = 1
	begin
	IF EXISTS (SELECT id FROM dbo.MAS_Request_Attach WHERE id = @id) 
		BEGIN
			UPDATE [dbo].MAS_Request_Attach
			   SET [requestId] = @requestId
				  ,[processId] = @processId
				  ,[attachUrl] = @attachUrl
				  ,[attachType] = @attachType
				  ,attachFileName = @attachFileName
				  ,[createDt] = getdate()
			 WHERE id = @Id 
		END 
		ELSE 
		BEGIN
				INSERT INTO [dbo].MAS_Request_Attach
					   ([requestId]
					   ,[processId]
					   ,[attachUrl]
					   ,[attachType]
					   ,attachFileName
					   ,[createDt])
				 VALUES
					   (@requestId
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
		delete from MAS_Request_Attach where id = @id
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
			SET @ErrorMsg = 'sp_Hom_Request_Attach_Set ' + error_message() 
			SET @ErrorProc = error_procedure() 
			SET @AddlInfo = ' ' 
		EXEC utl_Insert_ErrorLog @ErrorNum, @ErrorMsg, @ErrorProc,'Request_Attach','Set', @SessionID, @AddlInfo 
	END catch