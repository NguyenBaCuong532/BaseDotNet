CREATE PROCEDURE [dbo].[sp_res_service_expected_calculator_field]
    @userId UNIQUEIDENTIFIER = NULL,
    @periods_oid NVARCHAR(50) = NULL,
    @ApartmentId INT = NULL,
    @project_code NVARCHAR(20) = NULL,
    @projectCd NVARCHAR(10) = NULL,
    @acceptLanguage NVARCHAR(50) = N'vi-VN'
AS
BEGIN TRY
    SET NOCOUNT ON;

    -- Khai báo biến
    DECLARE @tableKey NVARCHAR(100) = N'service_expected_calculator';
    DECLARE @groupKey NVARCHAR(200) = N'common_group';

    IF(@project_code IS NULL AND @projectCd IS NOT NULL)
        SET @project_code = @projectCd;
        
    DECLARE @ToDate NVARCHAR(20) = NULL;
    IF(@periods_oid IS NOT NULL)
        SET @ToDate = (SELECT CONVERT(NVARCHAR(10), end_date, 103) FROM mas_billing_periods WHERE oid = @periods_oid);
        
    -- Thông tin tính dự thu theo từng căn hộ
    SELECT
        a.[ApartmentId]
        ,a.[RoomCode]
        ,c.FullName
        ,b.[BuildingCd]
        ,c.Phone 
        ,convert(nvarchar(10),ReceiveDt,103) as ReceiveDate
    INTO #MAS_Apartments
    FROM
        [MAS_Apartments] a
        LEFT JOIN MAS_Buildings b ON a.buildingOid = b.oid 
        join UserInfo m on a.UserLogin = m.loginName 
        JOIN MAS_Customers c ON m.CustId = c.CustId 	
    WHERE a.ApartmentId = @ApartmentId
    ORDER BY  a.[RoomCode]
        
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
          
    DECLARE @ExistByApartmentId BIT = 0;
    IF EXISTS(SELECT TOP 1 1 FROM #MAS_Apartments)
        SET @ExistByApartmentId = 1;
    
    --3 tung o trong group
    IF @ApartmentId IS NOT NULL AND EXISTS (SELECT 1 FROM dbo.MAS_Apartments WHERE ApartmentId = @ApartmentId)
    BEGIN
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
                        WHEN 'periods_oid'   THEN @periods_oid
                        WHEN 'ProjectName' THEN p.projectName
                        WHEN 'ProjectCd' THEN @project_code
                        WHEN 'BuildingCd' THEN a.BuildingCd
                        WHEN 'RoomCode'   THEN a.RoomCode
                    END)
                WHEN 'date' THEN CONVERT(NVARCHAR(50), 
                    CASE s.[field_name] 
                      WHEN 'ToDate' THEN ISNULL(@ToDate, CONVERT(NVARCHAR(10), GETDATE(), 103))
                    END)
            END,
            s.[columnClass],
            s.[columnType],
            columnObject = CASE 
                WHEN s.[field_name] = 'BuildingCd' THEN ISNULL(s.[columnObject], '') + @project_code
                WHEN s.[field_name] = 'apartmentCd' THEN ISNULL(s.[columnObject], '') + @project_code
                ELSE s.[columnObject]
            END,
            s.[isSpecial],
            s.[isRequire],
            [isDisable] = IIF((@periods_oid IS NOT NULL AND s.[field_name] IN('ToDate')) OR (@ExistByApartmentId = 1 AND s.[field_name] NOT IN('ToDate')), 1, s.[isDisable]),
            s.[IsVisiable],
            s.[isEmpty],
            columnTooltip = ISNULL(s.columnTooltip, s.[columnLabel]),
            s.[columnDisplay],
            s.[isIgnore]
        FROM
            dbo.fn_config_form_gets(@tableKey, @acceptLanguage) s
            -- Lấy Apartment nếu có, nếu NULL thì vẫn lấy 1 record (nếu tồn tại)
            OUTER APPLY (SELECT TOP 1 b.BuildingCd, a.RoomCode 
                         FROM MAS_Apartments a 
                         LEFT JOIN MAS_Buildings b ON a.buildingOid = b.oid
                         WHERE a.ApartmentId = @ApartmentId) a
            -- Lấy Project nếu có, nếu NULL thì vẫn lấy 1 record (nếu tồn tại)
            OUTER APPLY (SELECT TOP 1 p.projectName FROM MAS_Projects p WHERE @project_code IS NULL OR p.projectCd = @project_code) p
        WHERE (s.IsVisiable = 1 OR s.isRequire = 1)
        ORDER BY s.ordinal;
    END
    else
    BEGIN
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
              WHEN 'nvarchar' THEN 
                CONVERT(NVARCHAR(350), 
                  CASE s.[field_name] 
                    WHEN 'periods_oid'   THEN @periods_oid
                    WHEN 'ProjectName' THEN p.projectName
                    WHEN 'ProjectCd' THEN @project_code
                    WHEN 'BuildingCd' THEN ''
                    WHEN 'RoomCode'   THEN ''
                  END
                )
              WHEN 'date' THEN 
                CONVERT(NVARCHAR(50), 
                  CASE s.[field_name] 
                    WHEN 'ToDate' THEN ISNULL(@ToDate, CONVERT(NVARCHAR(10), GETDATE(), 103))
                  END
                )
            END,
            s.[columnClass],
            s.[columnType],
            columnObject = CASE 
                WHEN s.[field_name] = 'BuildingCd' THEN ISNULL(s.[columnObject], '') + @project_code
                WHEN s.[field_name] = 'apartmentCd' THEN ISNULL(s.[columnObject], '') + @project_code
                ELSE s.[columnObject]
            END,
            s.[isSpecial],
            s.[isRequire],
            [isDisable] = IIF(@periods_oid IS NOT NULL AND s.[field_name] IN('ToDate'), 1, s.[isDisable]),
            s.[IsVisiable],
            s.[isEmpty],
            columnTooltip = ISNULL(s.columnTooltip, s.[columnLabel]),
            s.[columnDisplay],
            s.[isIgnore]
        FROM
            dbo.fn_config_form_gets(@tableKey, @acceptLanguage) s
            -- Lấy Project nếu có, nếu NULL thì vẫn lấy 1 record (nếu tồn tại)
            OUTER APPLY (SELECT TOP 1 p.projectName FROM MAS_Projects p WHERE @project_code IS NULL OR p.projectCd = @project_code) p
        WHERE (s.IsVisiable = 1 OR s.isRequire = 1)
        ORDER BY s.ordinal;
    END
    
    --2. lấy ra data căn hộ
    SELECT *
    FROM [dbo].fn_config_list_gets_lang('view_service_expected_calculator_page', 0, @acceptLanguage)
    ORDER BY [ordinal];
    
    SELECT*FROM #MAS_Apartments
    
END TRY
BEGIN CATCH
    DECLARE @ErrorNum INT, @ErrorMsg VARCHAR(200), @ErrorProc VARCHAR(50), @SessionID INT, @AddlInfo VARCHAR(MAX);

    SET @ErrorNum = ERROR_NUMBER();
    SET @ErrorMsg = 'sp_res_service_expected_calculator_field' + ERROR_MESSAGE();
    SET @ErrorProc = ERROR_PROCEDURE();

    SET @AddlInfo = ' ';

    EXEC utl_errorlog_set @ErrorNum,
                          @ErrorMsg,
                          @ErrorProc,
                          'service_expected_calculator',
                          'GetInfo',
                          @SessionID,
                          @AddlInfo;
END CATCH;