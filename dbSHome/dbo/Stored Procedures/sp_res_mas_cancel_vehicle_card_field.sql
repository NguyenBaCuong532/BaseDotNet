
-- =============================================
-- Author:      ThanhMT
-- Create date: 17/11/2025
-- Description: Khóa thẻ xe cư dân - Lấy thông tin thêm mới hoặc chỉnh sửa
-- =============================================
CREATE PROCEDURE [dbo].[sp_res_mas_cancel_vehicle_card_field]
    @UserId uniqueidentifier = NULL,
    @project_code VARCHAR(50) = NULL,
    @CardVehicleId NVARCHAR(50) = NULL,
    @cardVehicleOid UNIQUEIDENTIFIER = NULL,
    @AcceptLanguage VARCHAR(20) = 'vi-VN'
AS
BEGIN TRY
    DECLARE @GroupKey        NVARCHAR(100) = 'common_group'; -- 'config_sp_res_mas_cancel_vehicle_card_field_group';--sys_config_data
    DECLARE @TableName       NVARCHAR(100) = 'config_sp_res_mas_cancel_vehicle_card_field';--sys_config_form
    DECLARE @CardVehicleIdInt INT;

    IF @cardVehicleOid IS NOT NULL
        SET @CardVehicleIdInt = (SELECT CardVehicleId FROM MAS_CardVehicle WHERE oid = @cardVehicleOid);
    ELSE
        SET @CardVehicleIdInt = TRY_CONVERT(INT, @CardVehicleId);
    IF @CardVehicleIdInt IS NOT NULL AND @CardVehicleId IS NULL
        SET @CardVehicleId = CAST(@CardVehicleIdInt AS NVARCHAR(50));

    -- ===============================
    -- Phí gửi xe hiện tại & Số tiền đã thu
    -- ===============================
    DECLARE @CurrentFee     DECIMAL(18, 2) = 0; -- Phí gửi xe hiện tại
    DECLARE @TotalCollected DECIMAL(18, 2) = 0; -- Số tiền đã thu
    
    DECLARE @VehicleNum INT;
    DECLARE @VehicleTypeId INT;

    IF @CardVehicleIdInt IS NOT NULL
    BEGIN
        -- 1. Lấy thông tin xe (VehicleNum, VehicleTypeId)
        SELECT TOP 1 
            @VehicleNum = VehicleNum,
            @VehicleTypeId = VehicleTypeId
        FROM dbo.MAS_CardVehicle WITH (NOLOCK)
        WHERE CardVehicleId = @CardVehicleIdInt;

        -- 2. Phí gửi xe hiện tại: dựa vào VehicleNum và Bảng giá (PAR_ServicePrice)
        -- Logic: Xe 1 lấy Price, Xe > 1 lấy Price2 (hoặc Price nếu Price2 null)
        SELECT TOP 1
              @CurrentFee = CASE 
                                WHEN ISNULL(@VehicleNum, 1) <= 1 THEN ISNULL(p.Price, 0)
                                ELSE ISNULL(p.Price2, ISNULL(p.Price, 0))
                            END
        FROM dbo.PAR_ServicePrice p WITH (NOLOCK)
        WHERE p.VehicleType = @VehicleTypeId
          AND (p.ProjectCd = @project_code OR @project_code IS NULL);

        -- 3. Số tiền đã thu: tổng Amount các giao dịch đã thanh toán trong MAS_Service_Receivable
        SELECT
              @TotalCollected = ISNULL(SUM(r.Amount), 0)
        FROM dbo.MAS_Service_Receivable r WITH (NOLOCK)
        WHERE r.srcId = @CardVehicleIdInt
          AND r.IsPaid = 1; -- 1 = Đã thanh toán
    END;

    -- Config Info
    SELECT
        @TableName AS tableKey,
        @GroupKey AS groupKey
		
    -- Get Group Info
    SELECT * FROM [dbo].[fn_get_field_group](@GroupKey) ORDER by intOrder
	
    -- Fields Info
    SELECT
        CASE [data_type]
            WHEN 'nvarchar' THEN CONVERT(NVARCHAR(MAX), 
                CASE [field_name]
                    WHEN 'VehicleNo' THEN b.VehicleNo
                    WHEN 'FullName' THEN b.FullName
                    WHEN 'Note' THEN b.Note
                END)
            WHEN 'date' THEN CONVERT(NVARCHAR(MAX), 
                CASE [field_name]
                    WHEN 'CancelDate' THEN FORMAT(GETDATE(), 'dd/MM/yyyy')
                    WHEN 'RegisterDate' THEN FORMAT(GETDATE(), 'dd/MM/yyyy')
                END)
            WHEN 'int' THEN 
                CASE [field_name]
                    WHEN 'CardVehicleId' THEN CONVERT(NVARCHAR(MAX), @CardVehicleId)
                    WHEN 'VehicleTypeId' THEN CONVERT(NVARCHAR(MAX), b.VehicleTypeId)
                    WHEN 'CurrentFee'   THEN CONVERT(NVARCHAR(MAX), @CurrentFee)
                    WHEN 'TotalCollected'       THEN CONVERT(NVARCHAR(MAX), @TotalCollected)
                END
        END AS columnValue,
        [field_name],
        [view_type],
        [data_type],
        [ordinal],
        [columnLabel],
        group_cd,
        [columnClass],
        [columnType],
        [columnObject],
        [isSpecial],
        [isRequire],
        [isDisable],
        [IsVisiable],
        [IsEmpty],
        isnull(a.columnTooltip,a.[columnLabel]) as columnTooltip,
        [columnDisplay],
        [isIgnore]
    FROM
        dbo.[fn_config_form_gets](@TableName, @AcceptLanguage) a
        OUTER APPLY (SELECT
                          a.*,
                          c.FullName
                      FROM
                          MAS_CardVehicle a
                          left JOIN MAS_Cards AS b ON a.CardId = b.CardId
                          JOIN MAS_Customers AS c ON a.CustId = c.CustId
                      WHERE a.CardVehicleId = @CardVehicleId) b
    ORDER BY a.group_cd, a.ordinal

END TRY
BEGIN CATCH
    DECLARE @ErrorNum INT, @ErrorMsg VARCHAR(200), @ErrorProc VARCHAR(50), @SessionID INT, @AddlInfo VARCHAR(MAX)
    SET @ErrorNum = error_number()
    SET @ErrorMsg = 'Line: ' + CONVERT(nvarchar(300), error_line()) + ' Msg: ' + error_message();
    SET @ErrorProc = error_procedure()
    SET @AddlInfo = 'UserId: ' + CONVERT(NVARCHAR(50), @UserId)
    EXEC utl_ErrorLog_Set @ErrorNum, @ErrorMsg, @ErrorProc, '', '', @SessionID, @AddlInfo 
END CATCH