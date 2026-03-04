CREATE   procedure [dbo].[sp_res_card_vehicle_payment_load_form]
(
    @UserID UNIQUEIDENTIFIER = NULL,
    @Action INT = 0,
    @CardVehicleId INT = NULL,
    @cardVehicleOid UNIQUEIDENTIFIER = NULL,
    @RequestId INT = NULL,
    @PaymentId UNIQUEIDENTIFIER = NULL,
    @StartDt DATETIME = NULL,
    @FirstMonthPaymentMethod NVARCHAR(50) = NULL,
    @acceptLanguage NVARCHAR(50) = N'vi-VN'
)
AS
BEGIN TRY
    SET NOCOUNT ON;
    SET XACT_ABORT ON;
    IF @cardVehicleOid IS NOT NULL
        SET @CardVehicleId = (SELECT CardVehicleId FROM MAS_CardVehicle WHERE oid = @cardVehicleOid);

    -- Khai báo biến
    DECLARE @tableKey NVARCHAR(100) = N'card_vehicle_payment_load_form';

    ------------------------------------------------
    -- ACTION = 0 : LOAD FORM
    ------------------------------------------------
    IF (@Action = 0)
    BEGIN
        /* RS1: DATA */
        DECLARE @CardStartDt DATETIME;
        SELECT @CardStartDt = StartTime
        FROM dbo.MAS_CardVehicle
        WHERE CardVehicleId = @CardVehicleId;

        SELECT
            @CardVehicleId AS cardVehicleId,
            @PaymentId     AS paymentId,
            ISNULL(@CardStartDt, GETDATE()) AS startDate,
            NULL AS selectedFirstMonthPaymentMethod;

        /* RS2: GROUP */
        SELECT
            NULL AS group_table,
            N'payment_load_form' AS group_key,
            N'col-12' AS group_column,
            N'1' AS group_cd,
            N'Xác định thanh toán tháng đầu' AS group_name,
            CAST(0 AS BIT) AS isGridEditor,
            CAST(1 AS BIT) AS expand;

        /* RS3: FIELDS – fn_config_form_gets */
        SELECT
            a.id,
            a.group_cd,
            a.table_name,
            a.field_name,
            a.data_type,
            a.columnLabel,
            a.columnDefault AS columnValue,
            a.columnClass,
            a.columnType,
            a.columnObject,
            a.columnTooltip,
            a.isSpecial,
            a.isRequire,
            a.isDisable,
            a.IsVisiable,
            a.IsEmpty,
            a.columnDisplay,
            a.isIgnore,
            NULL AS maxLength,
            NULL AS table_relation
        FROM dbo.fn_config_form_gets(@tableKey, @acceptLanguage) a
        ORDER BY a.ordinal;

        /* 🔥 RS4: META – FIX QUAN TRỌNG NHẤT */
        SELECT
            N'card_vehicle_payment_load_form' AS tableKey,
            N'payment_load_form'              AS groupKey,
            NULL                              AS draftPath,
            N'/api/v2/card/SetVehiclePaymentSubmit' AS submitPath,
            NULL                              AS fieldName,
            0                                 AS status;

        /* RS5: DUMMY – giữ GridReader */
        SELECT 0 AS dummy;

        RETURN;
    END
END TRY
BEGIN CATCH
    IF @@TRANCOUNT > 0 ROLLBACK;
    SELECT CAST(0 AS BIT) AS valid, ERROR_MESSAGE() AS messages;
END CATCH;