CREATE   procedure [dbo].[sp_res_service_expected_calculator_field_v2]
    @userId UNIQUEIDENTIFIER = NULL,
    @project_code NVARCHAR(20) = NULL,
    @RevenuePeriodId NVARCHAR(50) = NULL,
    @ApartmentId INT = NULL,
    @ProjectCd NVARCHAR(50) = NULL,
    @FloorNo NVARCHAR(20) = NULL,
    @Apartments NVARCHAR(MAX) = NULL,
    @RevenuePeriodFromDate NVARCHAR(20) = NULL,
    @ToDate NVARCHAR(20) = NULL,
    @BuildingCd NVARCHAR(50) = NULL,
    @ApartmentCd NVARCHAR(50) = NULL,
    @acceptLanguage NVARCHAR(50) = N'vi-VN'
AS
BEGIN TRY
    SET NOCOUNT ON;

    -- Khai báo biến
    DECLARE @tableKey NVARCHAR(100) = N'config_sp_res_service_expected_calculator_field_v2';
    DECLARE @groupKey NVARCHAR(200) = N'common_group';

    -- =============================================
    -- RESULT SET 1: INFO - Thông tin cơ bản
    -- =============================================
    SELECT
        ApartmentId = @ApartmentId,
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
    SELECT 
        s.id,
        s.[table_name],
        s.[field_name],
        s.[view_type],
        s.[data_type],
        s.[ordinal],
        s.[columnLabel],
        s.[group_cd],
        columnValue = CASE s.[data_type] 
            WHEN 'nvarchar' THEN CONVERT(NVARCHAR(350), 
                CASE s.[field_name]
                    WHEN 'RevenuePeriodId'   THEN @RevenuePeriodId
                    WHEN 'ProjectCd'   THEN @project_code
                    WHEN 'BuildingCd'  THEN ISNULL(@BuildingCd, a.BuildingCd)
                    WHEN 'FloorNo'  THEN ISNULL(@FloorNo, a.floorNo)
                    WHEN 'RoomCode'    THEN a.RoomCode
                    WHEN 'ApartmentCd'    THEN a.RoomCode
                END)
            WHEN 'date' THEN CONVERT(NVARCHAR(50), 
                CASE s.[field_name] 
                    WHEN 'RevenuePeriodFromDate' THEN FORMAT(p.start_date, 'dd/MM/yyyy')
                    WHEN 'ToDate' THEN FORMAT(p.end_date, 'dd/MM/yyyy')
                END)
        END,
        s.[columnClass],
        s.[columnType],
        columnObject = CASE 
            WHEN s.[field_name] = 'BuildingCd' THEN ISNULL(s.[columnObject], '') + @project_code
            WHEN s.[field_name] = 'FloorNo' THEN ISNULL(s.[columnObject], '') + ISNULL(@BuildingCd, a.BuildingCd)
            WHEN s.[field_name] = 'ApartmentCd' THEN CONCAT(s.[columnObject], CONCAT(N'?projectCd=', @project_code), CONCAT(N'&buildingCd=', ISNULL(@BuildingCd, a.BuildingCd)), CONCAT(N'&floorNo=', ISNULL(@FloorNo, a.floorNo)))
            ELSE s.[columnObject]
        END,
        s.[isSpecial],
        s.[isRequire],
        [isDisable] = IIF(@ApartmentId IS NOT NULL, 1, s.[isDisable]),
        s.[IsVisiable],
        s.[isEmpty],
        columnTooltip = ISNULL(s.columnTooltip, s.[columnLabel]),
        s.[columnDisplay],
        s.[isIgnore]
    FROM
        dbo.fn_config_form_gets(@tableKey, @acceptLanguage) s
        ,MAS_Apartments a 
                    LEFT JOIN MAS_Buildings b ON a.buildingOid = b.oid
        OUTER APPLY(SELECT TOP 1 * FROM mas_revenue_periods p WHERE oid = @RevenuePeriodId) p
    WHERE a.ApartmentId = @ApartmentId 
	and (s.IsVisiable = 1 OR s.isRequire = 1)
    ORDER BY s.ordinal;
       
    --2. lấy ra data căn hộ
    SELECT *
    FROM [dbo].fn_config_list_gets_lang('view_service_expected_calculator_page', 0, @acceptLanguage)
    ORDER BY [ordinal];
    
    SELECT
        a.[ApartmentId]
        ,a.[RoomCode]
			  ,c.FullName
			  ,b.[BuildingCd]
			  ,c.Phone 
			  ,convert(nvarchar(10),ReceiveDt,103) as ReceiveDate
    FROM
        [MAS_Apartments] a 
        LEFT JOIN MAS_Buildings b ON a.buildingOid = b.oid 
        join UserInfo m on a.UserLogin = m.loginName 
        JOIN MAS_Customers c ON m.CustId = c.CustId 	
    WHERE a.ApartmentId = @ApartmentId
    ORDER BY  a.[RoomCode] 
      
END TRY
BEGIN CATCH
    DECLARE @ErrorNum INT, @ErrorMsg VARCHAR(200), @ErrorProc VARCHAR(50), @SessionID INT, @AddlInfo VARCHAR(MAX);
    SET @ErrorNum = ERROR_NUMBER();
    SET @ErrorMsg = 'sp_res_service_expected_calculator_field' + ERROR_MESSAGE();
    SET @ErrorProc = ERROR_PROCEDURE();
    SET @AddlInfo = ' ';
    EXEC utl_errorlog_set @ErrorNum, @ErrorMsg, @ErrorProc, 'service_expected_calculator', 'GetInfo', @SessionID, @AddlInfo;
END CATCH;