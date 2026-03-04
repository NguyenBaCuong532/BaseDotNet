CREATE PROCEDURE [dbo].[sp_res_service_expected_details_field]
    @userId UNIQUEIDENTIFIER = NULL,
    @project_code NVARCHAR(10) = NULL,
    @receiveId INT = 141525,
    @acceptLanguage NVARCHAR(50) = N'vi-VN'
AS
BEGIN TRY
    SET NOCOUNT ON;

    -- Khai báo biến
    DECLARE @tableKey NVARCHAR(100) = N'service_expected_details';
    DECLARE @groupKey NVARCHAR(200) = N'common_group_service_expected_info';

    -- =============================================
    -- RESULT SET 1: INFO - Thông tin cơ bản
    -- =============================================
    SELECT 
        receiveId = @receiveId,
        tableKey = @tableKey, 
        groupKey = @groupKey;
   
    -- =============================================
    -- RESULT SET 2: GROUPS - Nhóm field
    -- =============================================
    SELECT *
    FROM dbo.fn_config_data_gets_lang(@groupKey, @acceptLanguage)
    ORDER BY intOrder
   
    --3 tung o trong group
    IF @receiveId IS NOT NULL AND EXISTS(SELECT 1 FROM dbo.MAS_Service_ReceiveEntry WHERE ReceiveId = @receiveId)
    BEGIN
        DECLARE @Par_vehicle_oid NVARCHAR(100);
        DECLARE @projectCd NVARCHAR(100);

        select @projectCd=ProjectCd from MAS_Service_ReceiveEntry where ReceiveId=@receiveId
        select @Par_vehicle_oid=oid from par_vehicle where project_code=@projectCd

        SELECT DISTINCT 
            a.id
            , a.table_name
            , a.field_name
            , a.view_type
            , a.data_type
            , a.ordinal
            , a.columnLabel
            , a.group_cd
            , columnValue = CASE a.data_type
                WHEN 'nvarchar' THEN CONVERT(NVARCHAR(350),
                    CASE a.field_name 
                        WHEN 'RoomCode' THEN d.RoomCode
                        WHEN 'FullName' THEN e.FullName
                        WHEN 'ProjectCd' THEN p.projectCd
                        WHEN 'UserLogin' THEN u.loginName
                        WHEN 'Phone' THEN e.Phone
                    END)
                WHEN 'decimal' THEN CAST(CASE a.field_name 
                    WHEN 'TotalAmt' THEN b.TotalAmt
                    WHEN 'CommonFee' THEN b.CommonFee
                    WHEN 'VehicleAmt' THEN TienXe.VehicleAmt
                    WHEN 'LivingAmt' THEN (ISNULL(TienDien.ElectricAmt, 0) + ISNULL(TienNuoc.WaterAmt, 0))
                    WHEN 'ElectricAmt' THEN TienDien.ElectricAmt
                    WHEN 'WaterAmt' THEN TienNuoc.WaterAmt
                    WHEN 'ExtendAmt' THEN b.ExtendAmt
                    WHEN 'PaidAmt' THEN b.PaidAmt
                    WHEN 'Price' THEN f.Price 
                    WHEN 'FreeAmt' THEN f.TotalAmt
                    WHEN 'FeeVatAmt' THEN f.TotalAmt/11
                    WHEN 'FeeNoVatAmt' THEN f.TotalAmt - f.TotalAmt/11
                END AS NVARCHAR(100)) 
                WHEN 'date' THEN CONVERT(NVARCHAR(50), CASE a.field_name 
                    WHEN 'ReceiveDt' THEN CONVERT(NVARCHAR(10), b.ReceiveDt, 103)
                    WHEN 'ToDt' THEN CONVERT(NVARCHAR(10), b.ToDt, 103)
                    WHEN 'ExpireDate' THEN CONVERT(NVARCHAR(10), b.ExpireDate, 103)
                END)
                ELSE CONVERT(NVARCHAR(50), CASE a.field_name 
                    WHEN 'IsPayed' THEN b.[IsPayed]
                    WHEN 'WaterwayArea' THEN d.WaterwayArea
                    WHEN 'MonthFee' THEN DATEDIFF(m, f.fromDt, f.ToDt)
                END) 
            END
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
            CROSS JOIN [dbo].MAS_Service_ReceiveEntry b
            JOIN MAS_Apartments d ON b.ApartmentId = d.ApartmentId
            LEFT JOIN UserInfo u ON d.UserLogin = u.loginName 
            LEFT JOIN MAS_Customers e ON u.CustId = e.CustId 
            LEFT JOIN MAS_Service_Receivable f ON f.srcId = b.ApartmentId AND f.ReceiveId = b.ReceiveId AND f.ServiceTypeId = 1
            OUTER APPLY(SELECT SUM(TotalAmt) AS VehicleAmt FROM MAS_Service_Receivable sr WHERE sr.ReceiveId = b.ReceiveId AND sr.ServiceTypeId = 2) TienXe
            OUTER APPLY(SELECT SUM(TotalAmt) AS ElectricAmt FROM MAS_Service_Receivable sr WHERE sr.ReceiveId = b.ReceiveId AND sr.ServiceTypeId = 3) TienDien
            OUTER APPLY(SELECT SUM(TotalAmt) AS WaterAmt FROM MAS_Service_Receivable sr WHERE sr.ReceiveId = b.ReceiveId AND sr.ServiceTypeId = 4) TienNuoc
            JOIN MAS_Projects p ON d.projectCd = p.projectCd
        WHERE a.table_name = @tableKey
            AND b.ReceiveId = @receiveId
            AND (a.IsVisiable = 1 OR a.isRequire = 1)
        ORDER BY a.ordinal

	END
	else
    BEGIN
        SELECT 
            a.id,
            a.table_name,
            a.field_name,
            a.view_type,
            a.data_type,
            a.ordinal,
            a.columnLabel,
            a.group_cd,
            a.columnDefault AS columnValue,
            a.columnClass,
            a.columnType,
            a.columnObject,
            a.isSpecial,
            a.isRequire,
            a.isDisable,
            a.IsVisiable,
            a.isEmpty,
            columnTooltip = ISNULL(a.columnTooltip, a.columnLabel),
            a.columnDisplay,
            a.isIgnore
        FROM dbo.fn_config_form_gets(@tableKey, @acceptLanguage) a
        WHERE a.table_name = @tableKey
        ORDER BY a.ordinal;
    END
	  
END TRY
BEGIN CATCH
    DECLARE @ErrorNum INT,
            @ErrorMsg VARCHAR(200),
            @ErrorProc VARCHAR(50),
            @SessionID INT,
            @AddlInfo VARCHAR(MAX);

    SET @ErrorNum = ERROR_NUMBER();
    SET @ErrorMsg = 'sp_res_service_expected_details_field' + ERROR_MESSAGE();
    SET @ErrorProc = ERROR_PROCEDURE();

    SET @AddlInfo = ' ';

    EXEC utl_errorlog_set @ErrorNum,
                          @ErrorMsg,
                          @ErrorProc,
                          'service_expected_details',
                          'GetInfo',
                          @SessionID,
                          @AddlInfo;
END CATCH;