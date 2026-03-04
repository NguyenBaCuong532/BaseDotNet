-- Author:		hoanpv@sunshinegroup.vn
-- Description:	
-- ======================================================
	CREATE PROCEDURE [dbo].[sp_Crm_Apartment_HandOver_Exchange_Detail_Set]
	@UserId nvarchar ( 450 ), 
	@ExchangeDetailId bigint,
	@ExchangeId bigint,
	@Content nvarchar (MAX),
	@UserTags nvarchar(1000),
	@UserTagNames nvarchar(2000)
	AS 
	BEGIN TRY
	IF EXISTS ( SELECT ExchangeDetailId FROM dbo.CRM_Apartment_HandOver_Exchange_Detail WHERE ExchangeDetailId = @ExchangeDetailId and ExchangeId = @ExchangeId) 
		BEGIN
			UPDATE [dbo].[CRM_Apartment_HandOver_Exchange_Detail]
			   SET [ExchangeId] = @ExchangeId
				  ,[Content] = @Content
				  ,[Modified] =getdate()
				  ,[ModifiedBy] = @UserId
				  ,UserTags = @UserTags
				  ,UserTagNames = @UserTagNames
			 WHERE ExchangeDetailId = @ExchangeDetailId and ExchangeId = @ExchangeId
		END 
		ELSE 
		BEGIN
			INSERT INTO [dbo].[CRM_Apartment_HandOver_Exchange_Detail]
					   ([ExchangeId]
					   ,[Content]
					   ,UserTags
					   ,UserTagNames
					   ,[Created]
					   ,[CreatedBy])
			 VALUES
					   (@ExchangeId
					   ,@Content
					   ,@UserTags
					   ,@UserTagNames
					   ,GETDATE()
					   ,@UserId)
					   set  @ExchangeDetailId = @@IDENTITY
		END 
		select * from CRM_Apartment_HandOver_Exchange_Detail where ExchangeDetailId = @ExchangeDetailId and ExchangeId = @ExchangeId
		END try BEGIN
			catch DECLARE
			@ErrorNum INT,
			@ErrorMsg VARCHAR ( 200 ),
			@ErrorProc VARCHAR ( 50 ),
	
			@SessionID INT,
			@AddlInfo VARCHAR ( MAX ) 
			SET @ErrorNum = error_number( ) 
			SET @ErrorMsg = 'sp_Crm_Apartment_HandOver_Exchange_Detail_Set ' + error_message( ) 
			SET @ErrorProc = error_procedure( ) 
			SET @AddlInfo = ' ' EXEC utl_Insert_ErrorLog @ErrorNum, @ErrorMsg, @ErrorProc,
			'CRM_Apartment_HandOver_Exchange_Detail',
			'POST,PUT', @SessionID, @AddlInfo 
	END catch