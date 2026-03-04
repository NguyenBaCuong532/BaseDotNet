-- Author:		hoanpv@sunshinegroup.vn
-- Description:	
-- ======================================================
	create PROCEDURE [dbo].[sp_Crm_Apartment_SetPercentDone]
	@UserId nvarchar ( 450 ), 
	@Percent int,
	@ExchangeId bigint
	AS 
	BEGIN TRY
		update CRM_Apartment_HandOver_Exchange set PercentDone = @Percent where ExchangeId = @ExchangeId
		select * from CRM_Apartment_HandOver_Exchange where ExchangeId= @ExchangeId

	END try BEGIN
			catch DECLARE
			@ErrorNum INT,
			@ErrorMsg VARCHAR ( 200 ),
			@ErrorProc VARCHAR ( 50 ),
	
			@SessionID INT,
			@AddlInfo VARCHAR ( MAX ) 
			SET @ErrorNum = error_number( ) 
			SET @ErrorMsg = '[sp_Crm_SetPercentDone] ' + error_message( ) 
			SET @ErrorProc = error_procedure( ) 
			SET @AddlInfo = ' ' EXEC utl_Insert_ErrorLog @ErrorNum, @ErrorMsg, @ErrorProc,
			'CRM_Apartment_HandOver_Exchange',
			'POST,PUT', @SessionID, @AddlInfo 
	END catch