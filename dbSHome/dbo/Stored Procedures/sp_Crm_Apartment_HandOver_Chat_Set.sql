-- Author:		hoanpv@sunshinegroup.vn
-- Description:	
-- ======================================================
	CREATE PROCEDURE [dbo].[sp_Crm_Apartment_HandOver_Chat_Set]
	@UserId nvarchar ( 450 ), 
	@ExchangeDEtailId bigint,
	@ExchangeId  bigint,
	@Content nvarchar(MAX),
	@Type int,
	@FileName nvarchar(100),
	@FileSize nvarchar(100),
	@Icon nvarchar(100),
	@LinkFile nvarchar(2000)
	AS 
	BEGIN TRY
	IF EXISTS ( SELECT ExchangeDetailId FROM dbo.CRM_Apartment_HandOver_Attach WHERE ExchangeDetailId = @ExchangeDEtailId and ExchangeId = @ExchangeId) 
		BEGIN
			UPDATE [dbo].[CRM_Apartment_HandOver_Exchange_Detail]
			   SET [ExchangeId] = @ExchangeId
				  ,[Content] = @Content
				  ,[Type] = @Type
				  ,[FileName] = @FileName
				  ,[FileSize] = @FileSize
				  ,[Icon] =@Icon
				  ,[Modified] = getdate()
				  ,[ModifiedBy] = @UserId
				  ,LinkFile = @LinkFile
			  WHERE ExchangeDetailId = @ExchangeDEtailId and ExchangeId = @ExchangeId
		END 
		ELSE 
		BEGIN
				INSERT INTO [dbo].[CRM_Apartment_HandOver_Exchange_Detail]
						   ([ExchangeId]
						   ,[Content]
						   ,[Type]
						   ,[FileName]
						   ,[FileSize]
						   ,[Icon]
						   ,LinkFile
						   ,[Created]
						   ,[CreatedBy])
				 VALUES
					       (@ExchangeId
						   ,@Content
						   ,@Type
						   ,@FileName
						   ,@FileSize
						   ,@Icon
						   ,@LinkFile
						   ,getdate()
						   ,@UserId)
				 set @ExchangeDEtailId = @@IDENTITY
		END 
		select ExchangeDetailId,
			   ExchangeId,
			   Content,
			   Type,
			   FileName,
			   FileSize,
			   Icon,
			   LinkFile,
			   dbo.fn_GetNameByUserId(CreatedBy) as CreatedBy 
	    from CRM_Apartment_HandOver_Exchange_Detail 
		where ExchangeId = @ExchangeId order by Created desc

		END try BEGIN
			catch DECLARE
			@ErrorNum INT,
			@ErrorMsg VARCHAR ( 200 ),
			@ErrorProc VARCHAR ( 50 ),
	
			@SessionID INT,
			@AddlInfo VARCHAR ( MAX ) 
			SET @ErrorNum = error_number( ) 
			SET @ErrorMsg = 'sp_Crm_Apartment_HandOver_Chat_Set ' + error_message( ) 
			SET @ErrorProc = error_procedure( ) 
			SET @AddlInfo = ' ' EXEC utl_Insert_ErrorLog @ErrorNum, @ErrorMsg, @ErrorProc,
			'sp_Crm_Apartment_HandOver_Chat_Set',
			'POST,PUT', @SessionID, @AddlInfo 
	END catch