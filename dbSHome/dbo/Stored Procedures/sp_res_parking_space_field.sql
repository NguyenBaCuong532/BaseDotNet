
CREATE PROCEDURE [dbo].[sp_res_parking_space_field]
    @UserId UNIQUEIDENTIFIER = NULL,
    @project_code VARCHAR(50) = NULL,
    @oid UNIQUEIDENTIFIER = NULL,
    @AcceptLanguage VARCHAR(20) = 'vi-VN'
AS
BEGIN TRY
    SET NOCOUNT ON;

    DECLARE @GroupKey NVARCHAR(100) = 'common_group';
    DECLARE @TableName NVARCHAR(100) = 'config_sp_res_parking_space_field';

 
    DECLARE @oid_final UNIQUEIDENTIFIER = @oid;

    IF @oid_final IS NOT NULL
       AND NOT EXISTS (SELECT 1 FROM par_parking_space WHERE oid = @oid_final)
    BEGIN
        IF COL_LENGTH('MAS_VehicleTypes', 'oid') IS NOT NULL
        BEGIN
            SELECT TOP 1 @oid_final = p.oid
            FROM par_parking_space p
            INNER JOIN MAS_VehicleTypes vt ON vt.VehicleTypeId = p.vehicle_type
            WHERE vt.oid = @oid_final
              AND (@project_code IS NULL OR p.project_code = @project_code)
            ORDER BY p.created_date DESC;
        END
    END

    IF @oid_final IS NULL AND @project_code IS NOT NULL
    BEGIN
        SELECT TOP 1 @oid_final = oid
        FROM par_parking_space
        WHERE project_code = @project_code
        ORDER BY created_date DESC;
    END

    IF @oid_final IS NULL
        SET @oid_final = NEWID();

    
    SELECT 
        CONVERT(UNIQUEIDENTIFIER, @oid_final) AS gd,
        @TableName AS tableKey,
        @GroupKey AS groupKey;

    SELECT * 
    FROM [dbo].[fn_get_field_group](@GroupKey) 
    ORDER BY intOrder;

    ;WITH src AS (
        SELECT TOP 1 *
        FROM par_parking_space
        WHERE oid = @oid_final
    )
    SELECT
        columnValue =
            CASE a.[data_type]
                WHEN 'uniqueidentifier' THEN CONVERT(NVARCHAR(MAX),
                    CASE a.[field_name]
                        WHEN 'oid' THEN CONVERT(NVARCHAR(36), @oid_final)
                    END
                )

                WHEN 'nvarchar' THEN CONVERT(NVARCHAR(MAX),
                    CASE a.[field_name]
                        WHEN 'project_code' THEN COALESCE(b.project_code, @project_code)
                    END
                )

                WHEN 'varchar' THEN CONVERT(NVARCHAR(MAX),
                    CASE a.[field_name]
                        WHEN 'project_code' THEN COALESCE(b.project_code, @project_code)
                    END
                )

                WHEN 'int' THEN CONVERT(NVARCHAR(MAX),
                    CASE a.[field_name]
                        WHEN 'vehicle_type' THEN b.vehicle_type

        
                        WHEN 'space_count_current' THEN ISNULL(b.space_count, 0)


                        WHEN 'space_count' THEN NULL
                    END
                )

                ELSE NULL
            END,

        a.[field_name],
        a.[view_type],
        a.[data_type],
        a.[ordinal],
        a.[columnLabel],
        a.group_cd,
        a.[columnClass],

    
        [columnType] =
            CASE 
                WHEN a.field_name = 'project_code' THEN 'dropdown'
                ELSE a.[columnType]
            END,

        [columnObject] =
            CASE
                WHEN a.field_name = 'project_code'
                    THEN '/api/v2/common/GetCommonList?tableName=MAS_Projects&columnName=projectName&columnId=projectCd'
                ELSE a.[columnObject]
            END,

        a.[isSpecial],
        a.[isRequire],
        a.[isDisable],
        a.[IsVisiable],
        a.[IsEmpty],
        ISNULL(a.columnTooltip, a.[columnLabel]) AS columnTooltip,
        a.[columnDisplay],
        a.[isIgnore]
    FROM dbo.[fn_config_form_gets](@TableName, @AcceptLanguage) a
    OUTER APPLY (SELECT * FROM src) b
    ORDER BY a.group_cd, a.ordinal;

END TRY
BEGIN CATCH
    DECLARE @ErrorNum INT, @ErrorMsg VARCHAR(200), @ErrorProc VARCHAR(50), @SessionID INT, @AddlInfo VARCHAR(MAX);
    SET @ErrorNum = ERROR_NUMBER();
    SET @ErrorMsg = 'Line: ' + CONVERT(NVARCHAR(300), ERROR_LINE()) + ' Msg: ' + ERROR_MESSAGE();
    SET @ErrorProc = ERROR_PROCEDURE();
    SET @AddlInfo = 'UserId: ' + CONVERT(NVARCHAR(50), @UserId)
                  + '; project_code: ' + ISNULL(@project_code, '')
                  + '; oid_in: ' + ISNULL(CONVERT(NVARCHAR(36), @oid), 'NULL')
                  + '; oid_final: ' + ISNULL(CONVERT(NVARCHAR(36), @oid_final), 'NULL');

    EXEC utl_ErrorLog_Set @ErrorNum, @ErrorMsg, @ErrorProc, '', '', @SessionID, @AddlInfo;
END CATCH