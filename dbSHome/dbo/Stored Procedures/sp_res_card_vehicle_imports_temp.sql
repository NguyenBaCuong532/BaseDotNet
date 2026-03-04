CREATE procedure [dbo].[sp_res_card_vehicle_imports_temp]
	 @userId				NVARCHAR(50)
AS
BEGIN TRY
	SELECT 	[order]	= null
			,base_name = ''
			,base_amt = null
			,note = ''		  
			, errors = ''
END TRY
BEGIN CATCH
	DECLARE	@ErrorNum				INT,
			@ErrorMsg				VARCHAR(200),
			@ErrorProc				VARCHAR(50),

			@SessionID				INT,
			@AddlInfo				VARCHAR(max)

	SET		@ErrorNum				= error_number()
	SET		@ErrorMsg				= 'sp_res_vehicle_cardBase_imports_temp ' + error_message()
	SET		@ErrorProc				= error_procedure()

	SET		@AddlInfo				= ' '

	EXEC utl_errorLog_set @ErrorNum, @ErrorMsg, @ErrorProc, 'sp_res_vehicle_cardBase_imports_temp', 'GET', @SessionID, @AddlInfo
END CATCH