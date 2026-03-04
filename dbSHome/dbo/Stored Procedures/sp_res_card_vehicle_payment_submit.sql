
CREATE PROCEDURE [dbo].[sp_res_card_vehicle_payment_submit]
(
    @UserID NVARCHAR(450),
    @ProjectCd NVARCHAR(40) = NULL,
    @CardVehicleId INT,
    @StartDt DATETIME = NULL,

 
    @FirstMonthPaymentMethod NVARCHAR(50) = NULL,
    @SelectedFirstMonthPaymentMethod NVARCHAR(50) = NULL
)
AS
BEGIN TRY
    SET NOCOUNT ON;
    SET XACT_ABORT ON;

    
    IF (ISNULL(@CardVehicleId, 0) = 0)
    BEGIN
        SELECT CAST(0 AS BIT) AS valid, 0 AS statusCode, N'CardVehicleId bắt buộc' AS messages,
               0 AS work_st, CAST(0 AS BIT) AS notiQue, NULL AS id, 0 AS regId, NULL AS code, 0 AS apiResult;
        SELECT 0 AS dummy;
        RETURN;
    END

    IF (@StartDt IS NULL) SET @StartDt = GETDATE();

    
    DECLARE @RawMethod NVARCHAR(50);
    SET @RawMethod = NULLIF(LTRIM(RTRIM(@FirstMonthPaymentMethod)), '');
    IF (@RawMethod IS NULL)
        SET @RawMethod = NULLIF(LTRIM(RTRIM(@SelectedFirstMonthPaymentMethod)), '');


    IF (@RawMethod IS NULL) SET @RawMethod = N'PAY_NOW';

    SET @RawMethod = LTRIM(RTRIM(@RawMethod));

    DECLARE @MethodCode NVARCHAR(50);

    
    SELECT TOP 1
        @MethodCode = LTRIM(RTRIM([Code]))
    FROM dbo.MAS_FirstMonthPaymentMethod
    WHERE IsActive = 1
      AND (
            LTRIM(RTRIM([Code])) = @RawMethod
         OR LTRIM(RTRIM([Name])) = @RawMethod
      )
    ORDER BY SortOrder;

    IF (@MethodCode IS NULL)
    BEGIN
        SELECT CAST(0 AS BIT) AS valid, 0 AS statusCode,
               N'FirstMonthPaymentMethod không hợp lệ. Nhận: [' + ISNULL(@RawMethod,'NULL')
               + N'] (Hợp lệ: PAY_NOW / TRANSFER_DEBT_NEXT_MONTH hoặc Name tương ứng trong MAS_FirstMonthPaymentMethod)' AS messages,
               0 AS work_st, CAST(0 AS BIT) AS notiQue, NULL AS id, 0 AS regId, NULL AS code, 0 AS apiResult;
        SELECT 0 AS dummy;
        RETURN;
    END

 
    SET @FirstMonthPaymentMethod = @MethodCode;

  
    DECLARE @RealProjectCd NVARCHAR(40);
    DECLARE @RequestId INT;
    DECLARE @CurrentStatus INT;

    SELECT TOP 1
        @RealProjectCd = cv.ProjectCd,
        @CurrentStatus = cv.Status,
        @RequestId     = ISNULL(cv.RequestId, 0)
    FROM dbo.MAS_CardVehicle cv
    WHERE cv.CardVehicleId = @CardVehicleId;

    IF (@RealProjectCd IS NULL)
    BEGIN
        SELECT CAST(0 AS BIT) AS valid, 0 AS statusCode, N'Không tìm thấy thẻ xe (CardVehicleId không tồn tại)' AS messages,
               0 AS work_st, CAST(0 AS BIT) AS notiQue, NULL AS id, 0 AS regId, NULL AS code, 0 AS apiResult;
        SELECT 0 AS dummy;
        RETURN;
    END

    IF (@ProjectCd IS NULL) SET @ProjectCd = @RealProjectCd;

    IF (@ProjectCd <> @RealProjectCd)
    BEGIN
        SELECT CAST(0 AS BIT) AS valid, 0 AS statusCode, N'ProjectCd không khớp với dữ liệu thẻ' AS messages,
               0 AS work_st, CAST(0 AS BIT) AS notiQue, NULL AS id, 0 AS regId, NULL AS code, 0 AS apiResult;
        SELECT 0 AS dummy;
        RETURN;
    END

    
    DECLARE @CARD_STATUS_ACTIVE  INT = 1; -- Hoạt động
    DECLARE @CARD_STATUS_OVERDUE INT = 2; -- Quá hạn TT
    DECLARE @PAY_ST_PAID   INT = 1;
    DECLARE @PAY_ST_UNPAID INT = 0;

    DECLARE @NewCardStatus INT;
    DECLARE @NewPaySt INT;

    IF (@FirstMonthPaymentMethod = N'PAY_NOW')
    BEGIN
        SET @NewCardStatus = @CARD_STATUS_ACTIVE;
        SET @NewPaySt = @PAY_ST_PAID;
    END
    ELSE
    BEGIN
        SET @NewCardStatus = @CARD_STATUS_OVERDUE;
        SET @NewPaySt = @PAY_ST_UNPAID;
    END

   
    DECLARE @StartDateOnly DATE = CONVERT(DATE, @StartDt);
    DECLARE @EndDt DATETIME = DATEADD(SECOND, -1, DATEADD(MONTH, 1, CONVERT(DATETIME, @StartDateOnly)));

    DECLARE @MonthNum INT = 1;
    DECLARE @MonthPrice DECIMAL(18,2) = 0;
    DECLARE @Amount DECIMAL(18,2) = ISNULL(@MonthPrice, 0) * @MonthNum;

    DECLARE @PayOid UNIQUEIDENTIFIER = NEWID();

  
    DECLARE @LocalTran BIT = 0;
    IF (@@TRANCOUNT = 0)
    BEGIN
        SET @LocalTran = 1;
        BEGIN TRAN;
    END

    INSERT INTO dbo.MAS_CardVehicle_Pay
    (
        CardVehicleId,
        PayDt,
        empUserId,
        Amount,
        StartDt,
        EndDt,
        Remart,
        paymentId,
        price_oid,
        month_price,
        month_num,
        payment_st,
        created_dt,
        created_by,
        oid
    )
    VALUES
    (
        @CardVehicleId,
        CASE WHEN @NewPaySt = @PAY_ST_PAID THEN GETDATE() ELSE NULL END,
        @UserID,
        @Amount,
        @StartDt,
        @EndDt,
        @FirstMonthPaymentMethod,
        @PayOid,        
        NULL,
        @MonthPrice,
        @MonthNum,
        @NewPaySt,
        GETDATE(),
        @UserID,
        @PayOid
    );

    UPDATE dbo.MAS_CardVehicle
       SET Status    = @NewCardStatus,
           StartTime = @StartDt,
           Auth_id   = @UserID,
           Auth_Dt   = GETDATE()
     WHERE CardVehicleId = @CardVehicleId;

    IF (ISNULL(@RequestId,0) <> 0)
    BEGIN
        UPDATE dbo.MAS_Requests
           SET Status = 1
         WHERE RequestId = @RequestId;
    END

    IF (@LocalTran = 1) COMMIT;

    SELECT CAST(1 AS BIT) AS valid, 1 AS statusCode, N'success' AS messages,
           1 AS work_st, CAST(0 AS BIT) AS notiQue, NULL AS id,
           @CardVehicleId AS regId, CONVERT(NVARCHAR(50), @PayOid) AS code, 1 AS apiResult;

    SELECT 0 AS dummy; -- ✅ giữ an toàn cho GridReader

END TRY
BEGIN CATCH
    IF (XACT_STATE() <> 0 AND @@TRANCOUNT > 0) ROLLBACK;

    SELECT CAST(0 AS BIT) AS valid, 0 AS statusCode,
           N'sp_res_card_vehicle_payment_submit ' + ERROR_MESSAGE() AS messages,
           0 AS work_st, CAST(0 AS BIT) AS notiQue, NULL AS id, 0 AS regId, NULL AS code, 0 AS apiResult;

    SELECT 0 AS dummy; -- ✅ giữ an toàn cho GridReader
END CATCH