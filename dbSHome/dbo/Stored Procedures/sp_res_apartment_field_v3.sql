CREATE PROCEDURE [dbo].[sp_res_apartment_field_v3]
    @userId         UNIQUEIDENTIFIER = NULL,
    @acceptLanguage  NVARCHAR(50) = N'vi-VN',
    @ApartmentId    INT = NULL, -- Backward compatible
    @Oid            UNIQUEIDENTIFIER = NULL -- Ưu tiên sử dụng (GUID)
AS
BEGIN TRY
    SET NOCOUNT ON;

    -- =============================================
    -- LẤY TENANT_OID TỪ USERS
    -- =============================================
    DECLARE @tenantOid UNIQUEIDENTIFIER = NULL;
    
    IF @userId IS NOT NULL
    BEGIN
        SELECT @tenantOid = tenant_oid
        FROM Users
        WHERE userId = @userId;
        
        ---- Kiểm tra user có tenant_oid không
        --IF @tenantOid IS NULL
        --BEGIN
        --    SELECT 
        --        ApartmentId = NULL,
        --        apartOid = NULL,
        --        RoomCode = NULL,
        --        tableKey = N'MAS_Apartments',
        --        groupKey = N'common_group';
        --    RETURN;
        --END
    END

    -- Khai báo biến
    DECLARE @tableKey NVARCHAR(100) = N'MAS_Apartments_v3';
    DECLARE @groupKey NVARCHAR(200) = N'apartment_field';

    -- Xác định ApartmentId từ Oid nếu có (có kiểm tra tenant_oid)
    IF @Oid IS NULL AND @ApartmentId IS NOT NULL
    BEGIN
        SELECT @Oid = Oid
        FROM dbo.MAS_Apartments
        WHERE ApartmentId = @ApartmentId
          --AND (@tenantOid IS NULL OR tenant_oid = @tenantOid);
    END

    -- =============================================
    -- TẠO DỮ LIỆU #tempIn TRƯỚC
    -- =============================================
    -- Tạo temp table để lưu dữ liệu
    IF OBJECT_ID(N'tempdb..#tempIn') IS NOT NULL 
        DROP TABLE #tempIn;

    SELECT *
    INTO #tempIn
    FROM MAS_Apartments
	WHERE (@Oid IS NOT NULL AND oid = @Oid)
          --AND (@tenantOid IS NULL OR tenant_oid = @tenantOid);
    -- Lấy dữ liệu nếu có (có kiểm tra tenant_oid)
    IF not exists(select 1 from #tempIn)
    BEGIN
        -- Tạo record mới nếu không có
        DECLARE @newOid UNIQUEIDENTIFIER = NEWID();
        INSERT INTO #tempIn (oid, RoomCode, tenant_oid)
        VALUES (@newOid, '', @tenantOid);
        SET @Oid = @newOid;
    END

    -- =============================================
    -- RESULT SET 1: INFO - Thông tin cơ bản
    -- =============================================
    SELECT 
        ApartmentId = ISNULL((SELECT TOP 1 ApartmentId FROM #tempIn), @ApartmentId),
        apartOid = ISNULL((SELECT TOP 1 oid FROM #tempIn), @Oid),
        RoomCode = (SELECT TOP 1 RoomCode FROM #tempIn),
        IsReceived = (SELECT TOP 1 IsReceived FROM #tempIn),
        ReceivedStatus = (SELECT TOP 1 IIF(IsReceived = 1, N'<span class="bg-success noti-number ml5">Đã bàn giao</span>', N'<span class="bg-primary noti-number ml5">Trống</span>') FROM #tempIn),
        tableKey = @tableKey,
        groupKey = @groupKey;

    -- =============================================
    -- RESULT SET 2: GROUPS - Nhóm field
    -- =============================================
    SELECT *
    FROM dbo.fn_get_field_group_lang(@groupKey, @acceptLanguage)
    ORDER BY intOrder;
		   

    -- =============================================
    -- RESULT SET 3: DATA - Dữ liệu field với columnValue động
    -- =============================================
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
            CASE a.[data_type]
                WHEN 'uniqueidentifier' THEN LOWER(CONVERT(NVARCHAR(100), 
                    CASE a.[field_name]
                        WHEN 'oid' THEN b.oid
                        WHEN 'apartOid' THEN b.oid
                        WHEN 'buildingOid' THEN b.buildingOid
                        WHEN 'floorOid' THEN b.floorOid
                    END))
                WHEN 'nvarchar' THEN CONVERT(NVARCHAR(MAX), 
                    CASE a.[field_name]
                        WHEN 'ProjectName' THEN bu.ProjectName
                        WHEN 'projectCd' THEN bu.ProjectCd
                        WHEN 'BuildingName' THEN bu.BuildingName
                        WHEN 'RoomCode' THEN ISNULL(b.RoomCodeView, b.RoomCode)
                        WHEN 'FullName' THEN h.FullName
                        WHEN 'AvatarUrl' THEN h.AvatarUrl
                        WHEN 'UserLogin' THEN b.UserLogin
                        WHEN 'Cif_No' THEN b.Cif_No
                        WHEN 'CustId' THEN h.CustId
                        WHEN 'FamilyImageUrl' THEN b.FamilyImageUrl
                        WHEN 'Phone' THEN h.Phone
                        WHEN 'Email' THEN h.Email
                        WHEN 'BuyerName' THEN N''
                        WHEN 'BuyerPhone' THEN N''
                        WHEN 'BuyerEmail' THEN N''
                        WHEN 'ReceiverName' THEN N'' -- Placeholder
                        WHEN 'ReceiverPhone' THEN N''
                        WHEN 'ReceiverEmail' THEN N''
                        WHEN 'ReceiverRelation' THEN N''
                        WHEN 'IsForeigner' THEN N''
                        WHEN 'ReceiveBy' THEN N''
                        WHEN 'FeeNote' THEN b.FeeNote
                        WHEN 'HandoverFiles' THEN N''
                        WHEN 'FeePrice' THEN N''
                        WHEN 'projectHotline' THEN '02473037999'
                    END)
                WHEN 'datetime' THEN 
                    CASE a.[field_name]
                        WHEN 'ReceiveDt' THEN FORMAT(b.ReceiveDt, 'dd/MM/yyyy')
                        WHEN 'FeeStart' THEN FORMAT(b.FeeStart, 'dd/MM/yyyy')
                        ELSE FORMAT(b.created_at, 'dd/MM/yyyy HH:mm:ss')
                    END
                WHEN 'bit' THEN CONVERT(NVARCHAR(50), 
                    CASE a.[field_name]
                        WHEN 'IsReceived' THEN b.IsReceived
                        WHEN 'IsRent' THEN b.IsRent
                        WHEN 'isMain' THEN b.isMain
                        WHEN 'isLinkApp' THEN b.isLinkApp
                        WHEN 'IsFree' THEN b.IsFree
                    END)
                WHEN 'int' THEN CONVERT(NVARCHAR(50),
                    CASE a.[field_name]
                        WHEN 'ApartmentId' THEN b.ApartmentId
                        WHEN 'ApartmentType' THEN b.ApartmentType
                        WHEN 'numFreeMonth' THEN b.numFreeMonth
                        WHEN 'MemberCount' THEN (SELECT COUNT(CustId) FROM MAS_Apartment_Member WHERE ApartmentId = b.ApartmentId)
                        WHEN 'CardCount' THEN (SELECT COUNT(cc.CardId) FROM MAS_Apartment_Member mm INNER JOIN MAS_Cards cc ON mm.CustId = cc.CustId WHERE mm.ApartmentId = b.ApartmentId)
                        WHEN 'VehicleCount' THEN (SELECT COUNT(vh.CardVehicleId) FROM MAS_CardVehicle vh WHERE vh.ApartmentId = b.ApartmentId)
                    END)
                WHEN 'float' THEN CONVERT(NVARCHAR(50),
                    CASE a.[field_name]
                        WHEN 'WaterwayArea' THEN b.WaterwayArea
                        WHEN 'WallArea' THEN b.WallArea
                        WHEN 'Floor' THEN b.[Floor]
                        WHEN 'CurrBal' THEN b.CurrBal
                        WHEN 'CurrPoint' THEN ISNULL(p.CurrPoint, 0)
                    END)
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
    LEFT JOIN MAS_Buildings bu ON b.buildingOid = bu.oid
    LEFT JOIN UserInfo u ON b.UserLogin = u.loginName
    LEFT JOIN MAS_Customers c ON u.CustId = c.CustId
    LEFT JOIN MAS_Points p ON c.CustId = p.CustId
    OUTER APPLY (
        SELECT TOP 1 a.*
        FROM MAS_Customers a 
        JOIN MAS_Apartment_Member bm ON a.CustId = bm.CustId 
        LEFT JOIN MAS_Customer_Relation d ON bm.RelationId = d.RelationId
        WHERE bm.ApartmentId = b.ApartmentId AND bm.RelationId = 0
    ) h
    WHERE (a.IsVisiable = 1 OR a.isRequire = 1)
    ORDER BY a.group_cd, a.ordinal;
			
END TRY
BEGIN CATCH
    DECLARE @ErrorNum INT, @ErrorMsg VARCHAR(200), @ErrorProc VARCHAR(50),
            @SessionID INT, @AddlInfo VARCHAR(MAX);
    SET @ErrorNum = ERROR_NUMBER();
    SET @ErrorMsg = N'sp_res_apartment_field ' + ERROR_MESSAGE();
    SET @ErrorProc = ERROR_PROCEDURE();
    SET @AddlInfo = N'';
    EXEC utl_errorlog_set @ErrorNum, @ErrorMsg, @ErrorProc, N'MAS_Apartments', N'GET', @SessionID, @AddlInfo;
END CATCH;