
-- =============================================
-- Author:      ThanhMT
-- Create date: 17/11/2025
-- Description: Khóa thẻ xe cư dân - Lưu thông tin chỉnh sửa hoặc thêm mới
-- =============================================
CREATE PROCEDURE [dbo].[sp_res_mas_cancel_vehicle_card_set]
    @UserId uniqueidentifier = NULL,
    @project_code VARCHAR(50) = NULL,
    @CardVehicleId INT,
    @VehicleNo NVARCHAR(100),
    @FullName NVARCHAR(100),
    @VehicleTypeId INT,
    @RegisterDate NVARCHAR(50),
    @CancelDate NVARCHAR(50),
    @CurrentFee NVARCHAR(50),
    @TotalCollected NVARCHAR(50),
    @Note NVARCHAR(100),
    @AcceptLanguage VARCHAR(20) = 'vi-VN'

AS

DECLARE @Oid uniqueidentifier;
DECLARE @Messages NVARCHAR(200) = '';
DECLARE @Valid BIT = 1;
DECLARE @HasPaidCurrentPeriod BIT = 0;
BEGIN TRY
    
    IF EXISTS(SELECT TOP 1 1 FROM mas_cancel_vehicle_card WHERE CardVehicleId = @CardVehicleId)
    BEGIN
        SET @Valid = 0;
        SET @Messages = N'Thẻ xe đã hủy trước đó. Vui lòng kiểm tra lại.';
        GOTO FINALLY;
    END

    -- Retrieve Info for History
    DECLARE @CardCd NVARCHAR(50), @CardId INT, @CustId NVARCHAR(50), @ProjectCd NVARCHAR(50), @OwnerNameFromDB NVARCHAR(200), @VehicleTypeName NVARCHAR(100)
    SELECT TOP 1 
        @CardCd = c.CardCd,
        @CardId = c.CardId,
        @CustId = cv.CustId,
        @ProjectCd = cv.ProjectCd,
        @OwnerNameFromDB = cust.FullName,
        @VehicleTypeName = vt.VehicleTypeName
    FROM MAS_CardVehicle cv WITH (NOLOCK)
    JOIN MAS_Cards c WITH (NOLOCK) ON cv.CardId = c.CardId
    LEFT JOIN MAS_Customers cust WITH (NOLOCK) ON cv.CustId = cust.CustId
    LEFT JOIN MAS_VehicleTypes vt WITH (NOLOCK) ON cv.VehicleTypeId = vt.VehicleTypeId
    WHERE cv.CardVehicleId = @CardVehicleId
    
    DECLARE @RegisterDateValue DATETIME = CONVERT(DATE, @RegisterDate, 103);
    DECLARE @CancelDateValue   DATETIME = CONVERT(DATE, @CancelDate, 103);
    
    -- Convert Fees to DECIMAL for storage
    DECLARE @CurrentFeeDec DECIMAL(18, 2) = NULL;
    DECLARE @TotalCollectedDec DECIMAL(18, 2) = NULL;
    BEGIN TRY
        SET @CurrentFeeDec = CAST(@CurrentFee AS DECIMAL(18, 2));
        SET @TotalCollectedDec = CAST(@TotalCollected AS DECIMAL(18, 2));
    END TRY
    BEGIN CATCH
        -- Ignore conversion errors, leave as NULL or 0
        SET @CurrentFeeDec = 0;
        SET @TotalCollectedDec = 0;
    END CATCH

    SET @Oid = NEWID();
    INSERT INTO mas_cancel_vehicle_card
        (oid, CardVehicleId, VehicleNo, FullName, VehicleTypeId, RegisterDate, CancelDate, Note, created_user, created_date, last_modified_by , last_modified_date)
    VALUES
        (@Oid, @CardVehicleId, @VehicleNo, @FullName, @VehicleTypeId, @RegisterDateValue, @CancelDateValue, @Note, @UserId, GETDATE(), @UserId, GETDATE());
    
    -- ============================================
    -- 8. Kiểm tra trạng thái thanh toán kỳ hiện tại
    -- ============================================
    /*
        TH1: Cư dân chưa thanh toán phí gửi xe
             → "Huỷ thành công. Vui lòng kiểm tra thông tin thanh toán bổ sung."
        TH2: Cư dân đã thanh toán phí gửi xe
             → "Huỷ thành công. Vui lòng kiểm tra thông tin hoàn tiền."
    */
    SELECT TOP 1
           @HasPaidCurrentPeriod = 1
    FROM dbo.MAS_CardVehicle_Pay p WITH (NOLOCK)
    WHERE p.CardVehicleId = @CardVehicleId
      AND p.payment_st = 1  -- Đã thanh toán
      AND (
            (p.StartDt IS NULL OR @CancelDateValue >= p.StartDt)
        AND (p.EndDt   IS NULL OR @CancelDateValue <= p.EndDt)
          );

    IF(@CancelDateValue <= CAST(GETDATE() AS DATE))
    BEGIN
        UPDATE a
        SET a.Status = 5
        FROM MAS_CardVehicle a
        WHERE a.CardVehicleId = @CardVehicleId;

        -- INSERT HISTORY (ActionType 5: Huỷ xe)
        INSERT INTO MAS_CardVehicle_Card_H (
            ActionType,
            ActionTypeName,
            CardId,
            CardVehicleId,
            FromDate,
            ToDate,
            VehicleTypeId,
            VehicleTypeName,
            OldCardCode,
            NewCardCode,
            OldOwner,
            NewOwner,
            OldOwnerCustId,
            NewOwnerCustId,
            VehicleNo,
            Operator,
            ActionTime,
            Notes,
            ProjectCd,
            CreatedDate
        )
        VALUES (
            5, -- Huỷ xe
            N'Huỷ xe',
            @CardId,
            @CardVehicleId,
            GETDATE(),
            NULL,
            @VehicleTypeId,
            @VehicleTypeName,
            @CardCd,          -- Corrected: OldCardCode
            @CardCd,          -- Corrected: NewCardCode
            @OwnerNameFromDB, -- Corrected: OldOwner
            @OwnerNameFromDB, -- Corrected: NewOwner
            @CustId,          -- Corrected: OldOwnerCustId
            @CustId,          -- Corrected: NewOwnerCustId
            @VehicleNo,       -- Corrected: VehicleNo
            CAST(@UserId AS NVARCHAR(50)), 
            GETDATE(),
            @Note,
            @ProjectCd,
            GETDATE()
        )
    END
    
    -- Thiết lập thông báo theo trạng thái thanh toán
    IF @HasPaidCurrentPeriod = 1
    BEGIN
        -- TH2: Cư dân đã thanh toán phí gửi xe
        SET @Messages = N'Huỷ thành công. Vui lòng kiểm tra thông tin hoàn tiền.';
    END
    ELSE
    BEGIN
        -- TH1: Cư dân chưa thanh toán phí gửi xe
        SET @Messages = N'Huỷ thành công. Vui lòng kiểm tra thông tin thanh toán bổ sung.';
    END
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
        id = @oid,
        Valid = @Valid,
        Messages = @Messages