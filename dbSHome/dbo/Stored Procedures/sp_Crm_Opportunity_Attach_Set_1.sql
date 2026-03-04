
-- ======================================================
	CREATE PROCEDURE [dbo].[sp_Crm_Opportunity_Attach_Set]
		@UserId		nvarchar (450), 
		@id			bigint,
		@opp_Id		bigint,
		@processId	bigint,
		@AttachUrl	nvarchar(450),
		@attachType nvarchar(50),
		@attachFileName nvarchar(200),
		@used bit
	AS 
begin try
	if @used = 1
	begin
	IF EXISTS (SELECT id FROM dbo.[CRM_Opportunity_Attach] WHERE id = @id) 
		BEGIN
			UPDATE [dbo].[CRM_Opportunity_Attach]
			   SET [opp_Id] = @opp_Id
				  ,[processId] = @processId
				  ,[attachUrl] = @attachUrl
				  ,[attachType] = @attachType
				  ,attachFileName = @attachFileName
				  ,[createDt] = getdate()
			 WHERE id = @Id 
		END 
		ELSE 
		BEGIN
				INSERT INTO [dbo].[CRM_Opportunity_Attach]
					   ([opp_Id]
					   ,[processId]
					   ,[attachUrl]
					   ,[attachType]
					   ,attachFileName
					   ,[createDt])
				 VALUES
					   (@opp_Id
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
		delete from [CRM_Opportunity_Attach] where id = @id
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
			SET @ErrorMsg = 'sp_Crm_Opportunity_Attach_Set ' + error_message() 
			SET @ErrorProc = error_procedure() 
			SET @AddlInfo = ' ' 
		EXEC utl_Insert_ErrorLog @ErrorNum, @ErrorMsg, @ErrorProc,'Opportunity_Attach','PUT', @SessionID, @AddlInfo 
	END catch