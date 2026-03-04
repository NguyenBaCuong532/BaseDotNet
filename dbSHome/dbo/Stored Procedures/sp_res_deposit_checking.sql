-- =============================================
-- Author:		hoanpv
-- Create date: 08/10/2024
-- Description:	kiem tra tai khoan ao
-- =============================================
CREATE procedure [dbo].[sp_res_deposit_checking]
    @userId nvarchar(50) = null,
	@acceptLanguage nvarchar(50) = null,
	@virtualAccount nvarchar(50) = null,
	@amount decimal(18,0) = null

AS
BEGIN TRY
      declare @valid bit = 1
      declare @messages nvarchar(100) = N'Thông tin tài khoản ảo hợp lệ'
	  
	  select actualAccount,
	         displayName = 'NOBLE',
			 amount
	  from transaction_payment_draft 
	  where virtualAcc = @virtualAccount
	  and amount = @amount
END TRY
BEGIN CATCH
      DECLARE @ErrorNum INT
             ,@ErrorMsg VARCHAR(200)
             ,@ErrorProc VARCHAR(50)
             ,@SessionID INT
             ,@AddlInfo VARCHAR(MAX)

      SET @ErrorNum = ERROR_NUMBER()
      SET @ErrorMsg = 'sp_trans_deposit_checking ' + ERROR_MESSAGE()
      SET @ErrorProc = ERROR_PROCEDURE()
      SET @AddlInfo = ''

      EXEC utl_ErrorLog_Set @ErrorNum, @ErrorMsg, @ErrorProc, 'sp_trans_deposit_checking', 'GET', @SessionID, @AddlInfo
END CATCH