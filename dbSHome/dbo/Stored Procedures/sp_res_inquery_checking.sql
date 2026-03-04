-- =============================================
-- Author:		hoanpv
-- Create date: 08/10/2024
-- Description:	kiem tra tai khoan ao
-- =============================================
CREATE procedure [dbo].[sp_res_inquery_checking]
    @userId nvarchar(50) = null,
    @acceptLanguage nvarchar(50) = null,
    @virtualAccount nvarchar(50) = '16112411251661748'
AS
BEGIN TRY
    declare @valid bit = 1
    declare @messages nvarchar(100) = N'Thông tin tài khoản ảo hợp lệ'
	  
	  select
        actualAccount,
        displayName = 'NOBLE'
	  from transaction_payment_draft
	  where virtualAcc = @virtualAccount
    
END TRY
BEGIN CATCH
    DECLARE @ErrorNum INT, @ErrorMsg VARCHAR(200), @ErrorProc VARCHAR(50), @SessionID INT, @AddlInfo VARCHAR(MAX)
    SET @ErrorNum = ERROR_NUMBER()
    SET @ErrorMsg = 'sp_trans_inquery_checking ' + ERROR_MESSAGE()
    SET @ErrorProc = ERROR_PROCEDURE()
    SET @AddlInfo = ''
    EXEC utl_ErrorLog_Set @ErrorNum, @ErrorMsg, @ErrorProc, 'sp_trans_inquery_checking', 'GET', @SessionID, @AddlInfo
END CATCH