-- Author:		hoanpv@sunshinegroup.vn
-- Description:	
-- ======================================================
	CREATE PROCEDURE [dbo].[sp_Crm_Apartment_SetChangeWorkStatus]
	@UserId nvarchar ( 450 ), 
	@WorkStatus int,
	@ExchangeId bigint,
	@TeamId int,
	@HandOverDetailId bigint
	AS 
	BEGIN TRY
		if exists (select ExchangeId from CRM_Apartment_HandOver_Exchange where ExchangeId = @ExchangeId)
			update CRM_Apartment_HandOver_Exchange set 
			WorkStatusId = @WorkStatus
			where ExchangeId = @ExchangeId

		declare @count decimal(18,1)
		set @count = (select count(ExchangeId) from CRM_Apartment_HandOver_Exchange where HandOverDetailId = @HandOverDetailId)

		declare @dem decimal(18,1)
		set @dem = (select count(ExchangeId) from CRM_Apartment_HandOver_Exchange where HandOverDetailId = @HandOverDetailId and TeamType = @TeamId and WorkStatusId = 3)

		declare @total decimal(18,1)
		set @total = (select count(ExchangeId) from CRM_Apartment_HandOver_Exchange where HandOverDetailId = @HandOverDetailId)

		if(@total = @dem)
			begin
				update CRM_Apartment_HandOver_Detail set HandOverDtStatus = 3 where HandOverDetailId = @HandOverDetailId
				update CRM_Apartment_HandOver_Detail set PercentDone = 100 where  HandOverDetailId = @HandOverDetailId
			end
		else
			begin
				update CRM_Apartment_HandOver_Detail set HandOverDtStatus = 2 where HandOverDetailId = @HandOverDetailId
				update CRM_Apartment_HandOver_Detail set PercentDone = cast((@dem/@count)*100 as int) where  HandOverDetailId = @HandOverDetailId
			end
			
		
		
	END try BEGIN
			catch DECLARE
			@ErrorNum INT,
			@ErrorMsg VARCHAR ( 200 ),
			@ErrorProc VARCHAR ( 50 ),
	
			@SessionID INT,
			@AddlInfo VARCHAR ( MAX ) 
			SET @ErrorNum = error_number( ) 
			SET @ErrorMsg = '[sp_Crm_SetChangeWorkStatus] ' + error_message( ) 
			SET @ErrorProc = error_procedure( ) 
			SET @AddlInfo = ' ' EXEC utl_Insert_ErrorLog @ErrorNum, @ErrorMsg, @ErrorProc,
			'CRM_Apartment_HandOver_Exchange',
			'POST,PUT', @SessionID, @AddlInfo 
	END catch