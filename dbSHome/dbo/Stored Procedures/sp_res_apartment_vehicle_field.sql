CREATE PROCEDURE [dbo].[sp_res_apartment_vehicle_field]
    @userId UNIQUEIDENTIFIER = null,
    @cardVehicleId INT = NULL,
    @cardVehicleOid UNIQUEIDENTIFIER = NULL,
    @acceptLanguage NVARCHAR(50) = N'vi-VN'
AS
BEGIN TRY
    SET NOCOUNT ON;
    IF @cardVehicleOid IS NOT NULL
        SET @cardVehicleId = (SELECT CardVehicleId FROM MAS_CardVehicle WHERE oid = @cardVehicleOid);

    -- Khai báo biến
    DECLARE @tableKey NVARCHAR(100) = N'apartment_vehicle';
    DECLARE @groupKey NVARCHAR(200) = N'common_group';

    -- Validation
    IF @cardVehicleId IS NOT NULL
       AND NOT EXISTS
    (
        SELECT 1
        FROM dbo.MAS_CardVehicle
        WHERE CardVehicleId = @cardVehicleId
    )
        SET @cardVehicleId = NULL;

    -- =============================================
    -- RESULT SET 1: INFO - Thông tin cơ bản
    -- =============================================
    SELECT 
        cardVehicleId = @cardVehicleId,
        tableKey = @tableKey, 
        groupKey = @groupKey;

    -- =============================================
    -- RESULT SET 2: GROUPS - Nhóm field
    -- =============================================
    SELECT *
    FROM [dbo].[fn_get_field_group_lang](@groupKey, @acceptLanguage)
    ORDER BY intOrder;

    -- =============================================
    -- RESULT SET 3: DATA - Dữ liệu field với columnValue động
    -- =============================================
    
    -- Tạo temp table để lưu dữ liệu với các JOIN cần thiết
    IF OBJECT_ID(N'tempdb..#tempIn') IS NOT NULL 
        DROP TABLE #tempIn;

    SELECT 
        a.CardVehicleId,
        a.StartTime,
        a.EndTime,
        a.CustId,
        a.VehicleTypeId,
        c.VehicleTypeName,
        b.FullName,
        mc.StatusId AS Status,
        ac.ApartmentId,
        a.VehicleNo,
        a.VehicleNum,
        a.VehicleName,
        a.isVehicleNone,
        a.lastReceivable,
        ac.RoomCode,
        p.CardCd,
        b.Phone
    INTO #tempIn
    FROM MAS_CardVehicle a
        LEFT JOIN MAS_Customers b ON a.CustId = b.CustId
        INNER JOIN MAS_VehicleTypes c ON a.VehicleTypeId = c.VehicleTypeId
        JOIN MAS_Apartments ac ON a.ApartmentId = ac.ApartmentId
        LEFT JOIN MAS_Cards p ON a.CardId = p.CardId
        LEFT JOIN MAS_VehicleStatus mc ON a.[Status] = mc.StatusId
    WHERE a.CardVehicleId = @cardVehicleId;

    -- Nếu không có dữ liệu, tạo record mới
    IF NOT EXISTS (SELECT 1 FROM #tempIn)
    BEGIN
        INSERT INTO #tempIn (CardVehicleId) 
        VALUES (@cardVehicleId);
    END

    -- Trả về dữ liệu field với columnValue được format
    SELECT
          a.id
        , a.table_name
        , a.field_name
        , a.view_type
        , a.data_type
        , a.ordinal
        , a.columnLabel
        , a.group_cd
        , columnValue = ISNULL(
            CASE a.field_name
                WHEN 'CardVehicleId' THEN CONVERT(NVARCHAR(450), b.CardVehicleId)
                WHEN 'StartTime' THEN CONVERT(NVARCHAR(450), FORMAT(b.StartTime, 'dd/MM/yyyy'))
                WHEN 'EndTime' THEN CONVERT(NVARCHAR(450), FORMAT(b.EndTime, 'dd/MM/yyyy'))
                WHEN 'CustId' THEN b.CustId
                WHEN 'VehicleTypeId' THEN CONVERT(NVARCHAR(450), b.VehicleTypeId)
                WHEN 'VehicleTypeName' THEN b.VehicleTypeName
                WHEN 'FullName' THEN b.FullName
                WHEN 'Status' THEN CONVERT(NVARCHAR(450), b.Status)
                WHEN 'ApartmentId' THEN CONVERT(NVARCHAR(500), b.ApartmentId)
                WHEN 'VehicleNo' THEN b.VehicleNo
                WHEN 'VehicleNum' THEN CONVERT(NVARCHAR(500), b.VehicleNum)
                WHEN 'VehicleName' THEN b.VehicleName
                WHEN 'isVehicleNone' THEN CONVERT(NVARCHAR(450), b.isVehicleNone)
                WHEN 'lastReceivable' THEN CONVERT(NVARCHAR(450), FORMAT(b.lastReceivable, 'dd/MM/yyyy'))
                WHEN 'RoomCode' THEN b.RoomCode
                WHEN 'CardCd' THEN b.CardCd
                WHEN 'Phone' THEN b.Phone
            END,
            a.columnDefault
        )
        , a.columnClass
        , a.columnType
        , a.columnObject
        , a.isSpecial
        , a.isRequire
        , a.isDisable
        , a.IsVisiable
        , a.isEmpty
        , columnTooltip = ISNULL(a.columnTooltip, a.columnLabel)
        , a.columnDisplay
        , a.isIgnore
    FROM dbo.fn_config_form_gets(@tableKey, @acceptLanguage) a
    CROSS JOIN #tempIn b
    WHERE a.table_name = @tableKey
      AND (a.IsVisiable = 1 OR a.isRequire = 1)
    ORDER BY a.ordinal;
	-- 4. Lấy ra config list ds các lần thanh toán dịch vụ phương tiện
	SELECT *
        FROM [dbo].fn_config_list_gets_lang('view_apartment_vehicle_payment_page', 0, @acceptLanguage)
        ORDER BY [ordinal];
	--5. lấy ra data các lần thanh toán
	SELECT a.[ReceivableId]
			  ,a.[ReceiveId]
			  ,a.[ServiceTypeId]
			  ,a.[Quantity]
			  ,a.[Price]
			  ,a.[TotalAmt] as [Amount]
			  ,convert(nvarchar(10),a.[fromDt],103) as StartDate
			  ,convert(nvarchar(10),a.[ToDt],103) as EndDate
			  ,s.IsPayed
			  ,s.PayedDt as PayedDate
			  ,c.VehicleNum as VehNum
			  ,c.CardVehicleId 
			  ,e.Contents as Remart
			  ,e.ReceiptId as VehiclePayId
			  ,e.[Object] as CustomerName
	  FROM [dbo].MAS_Service_Receivable a 
			join MAS_CardVehicle c on a.srcId = c.CardVehicleId
			inner join MAS_Service_ReceiveEntry s on a.ReceiveId = s.ReceiveId
			left join MAS_Service_Receipts e on a.[ReceiveId] = e.[ReceiveId]
		WHERE a.ServiceTypeId = 2 
			and a.srcId = @cardVehicleId 
			--AND e.ReceiptId = 165850
		ORDER BY a.srcId, a.fromDt DESC
END TRY
BEGIN CATCH
    DECLARE @ErrorNum INT,
            @ErrorMsg VARCHAR(200),
            @ErrorProc VARCHAR(50),
            @SessionID INT,
            @AddlInfo VARCHAR(MAX);

    SET @ErrorNum = ERROR_NUMBER();
    SET @ErrorMsg = 'sp_res_apartment_vehicle_field' + ERROR_MESSAGE();
    SET @ErrorProc = ERROR_PROCEDURE();

    SET @AddlInfo = ' ';

    EXEC utl_errorlog_set @ErrorNum,
                          @ErrorMsg,
                          @ErrorProc,
                          'apartment_vehicle',
                          'GetInfo',
                          @SessionID,
                          @AddlInfo;
END CATCH;