-- Author:		hoanpv@sunshinegroup.vn
-- Description:	
-- ======================================================
	CREATE PROCEDURE [dbo].[sp_Crm_Apartment_HandOver_Attach_Set]
	@UserId nvarchar ( 450 ), 
	@AttachId bigint,
	@AttachName nvarchar(50),
	@AttachSize nvarchar(100),
	@AttachLink nvarchar(200),
	@ExchangeId bigint,
	@ExchangeDetaild bigint
	AS 
	BEGIN TRY
	IF EXISTS ( SELECT ExchangeDetailId FROM dbo.CRM_Apartment_HandOver_Attach WHERE AttachId = AttachId and (ExchangeId = @ExchangeId or ExchangeDetailId = @ExchangeDetaild)) 
		BEGIN
			UPDATE [dbo].[CRM_Apartment_HandOver_Attach]
			   SET [AttachName] = @AttachName
				  ,[AttachSize] = @AttachSize
				  ,[AttachLink] = @AttachLink
				  ,[ExchangeId] = @ExchangeId
				  ,[ExchangeDetailId] = @ExchangeDetaild
				  ,[Type] = 1
				  ,[Modified] = getdate()
				  ,[ModifiedBy] = @UserId
			 WHERE AttachId = AttachId and (ExchangeId = @ExchangeId or ExchangeDetailId = @ExchangeDetaild)
		END 
		ELSE 
		BEGIN
				INSERT INTO [dbo].[CRM_Apartment_HandOver_Attach]
					   ([AttachName]
					   ,[AttachSize]
					   ,[AttachLink]
					   ,[ExchangeId]
					   ,[ExchangeDetailId]
					   ,[Type]
					   ,[Created]
					   ,[CreatedBy])
				 VALUES
					   (@AttachName
					   ,@AttachSize
					   ,@AttachLink
					   ,@ExchangeId
					   ,@ExchangeDetaild
					   ,1
					   ,getdate()
					   ,@UserId)
				 set @AttachId = @@IDENTITY
		END 
		select * from CRM_Apartment_HandOver_Attach WHERE AttachId = AttachId and (ExchangeId = @ExchangeId or ExchangeDetailId = @ExchangeDetaild)
		END try BEGIN
			catch DECLARE
			@ErrorNum INT,
			@ErrorMsg VARCHAR ( 200 ),
			@ErrorProc VARCHAR ( 50 ),
	
			@SessionID INT,
			@AddlInfo VARCHAR ( MAX ) 
			SET @ErrorNum = error_number( ) 
			SET @ErrorMsg = 'sp_Crm_Apartment_HandOver_Attach_Set ' + error_message( ) 
			SET @ErrorProc = error_procedure( ) 
			SET @AddlInfo = ' ' EXEC utl_Insert_ErrorLog @ErrorNum, @ErrorMsg, @ErrorProc,
			'CRM_Apartment_HandOver_Attach',
			'POST,PUT', @SessionID, @AddlInfo 
	END catch