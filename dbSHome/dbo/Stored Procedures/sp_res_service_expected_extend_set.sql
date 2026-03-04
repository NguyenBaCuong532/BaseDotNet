-- =============================================
-- Author:      ThanhMT
-- Create date: 18/11/2025
-- Description: Khóa thẻ xe cư dân - Lưu thông tin chỉnh sửa hoặc thêm mới
-- =============================================
CREATE PROCEDURE [dbo].[sp_res_service_expected_extend_set]
    @UserId uniqueidentifier = NULL,
    @project_code VARCHAR(50) = NULL,
    @ReceiveId INT,
    @IsRefundCustomer BIT,
    @Amount DECIMAL(18, 2),
    @VatAmt DECIMAL(18, 2),
    @ToDt NVARCHAR(50),
    @ServiceObject NVARCHAR(100),
    @AcceptLanguage VARCHAR(20) = 'vi-VN'
AS

DECLARE @Messages NVARCHAR(100) = '';
DECLARE @Valid BIT = 1;
BEGIN TRY
    IF EXISTS(SELECT TOP 1 1 FROM MAS_Service_ReceiveEntry WHERE ReceiveId = @ReceiveId AND IsBill = 1)
    BEGIN
        SET @Valid = 0;
        SET @Messages = N'Đã xuất hóa đơn. Không thể bổ sung điều chỉnh.';
        GOTO FINALLY;
    END
    
    IF(@Amount = 0)
    BEGIN
        SET @Valid = 0;
        SET @Messages = N'Số tiền điều chỉnh phải khác 0';
        GOTO FINALLY;
    END
    
    DECLARE @ToDtValue DATE = CONVERT(DATE, @ToDt, 103);
    DECLARE @TotalAmt DECIMAL(18, 2) = (@Amount + @VatAmt);
    IF(@IsRefundCustomer = 1)
    BEGIN
        SET @Amount = -@Amount;
        SET @VatAmt = -@VatAmt;
        SET @TotalAmt = -@TotalAmt;
    END
    
    INSERT INTO MAS_Service_Receivable(ReceiveId, ServiceTypeId, Amount, VatAmt, TotalAmt, ToDt, ServiceObject, updateId, sysDate)
    VALUES(@ReceiveId, 8, @Amount, @VatAmt, @TotalAmt, @ToDtValue, @ServiceObject, @UserId, GETDATE());

    SET @Messages = N'Thêm mới bản ghi thành công'
END TRY
BEGIN CATCH
    SET @Valid = 0;
    SET @Messages = error_message();
	
    DECLARE @ErrorNum INT, @ErrorMsg VARCHAR(200), @ErrorProc VARCHAR(50), @SessionID INT, @AddlInfo VARCHAR(MAX)
    SET @ErrorNum = error_number()
    SET @ErrorMsg = 'Line: ' + CONVERT(nvarchar(300), error_line()) + ' Msg: ' + error_message();
    SET @ErrorProc = error_procedure()
    SET @AddlInfo = 'UserId: ' + CONVERT(NVARCHAR(50), @UserId)
    EXEC utl_ErrorLog_Set @ErrorNum, @ErrorMsg, @ErrorProc, '', '', @SessionID, @AddlInfo 
END CATCH

FINALLY:
    SELECT
        Valid = @Valid,
        Messages = @Messages