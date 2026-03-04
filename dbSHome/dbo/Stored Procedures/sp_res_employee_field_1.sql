CREATE PROCEDURE [dbo].[sp_res_employee_field]
    @userId UNIQUEIDENTIFIER = null,
    @empId UNIQUEIDENTIFIER = NULL,
    @acceptLanguage NVARCHAR(50) = N'vi-VN'
AS
BEGIN TRY
    SET NOCOUNT ON;

    DECLARE @group_key VARCHAR(50) = 'employee_group';
    DECLARE @table_key VARCHAR(50) = 'mas_employee';

    /* ========== 1) Root / Thông tin chung ========== */
    SELECT  e.empId,
            @table_key AS tableKey,
            @group_key AS groupKey
    FROM dbo.mas_employee e
    WHERE (@empId IS NOT NULL AND e.empId = @empId)
       OR (@empId IS NULL AND 1 = 0); -- Không có record nếu không có empId

    /* ========== 2) Group definition ========== */
    IF EXISTS (SELECT 1 FROM dbo.fn_get_field_group_lang(@group_key, @acceptLanguage))
    BEGIN
        SELECT *
        FROM dbo.fn_get_field_group_lang(@group_key, @acceptLanguage)
        ORDER BY intOrder;
    END
    ELSE
    BEGIN
        -- fallback: để backend luôn có group_key
        SELECT  group_table  = NULL,
                group_key    = @group_key,
                group_column = 'col-12',
                group_cd     = '1',
                group_name   = N'Thông tin chung',
                isGridEditor = CAST(0 AS bit),
                expand       = CAST(1 AS bit);
    END

    /* ========== 3) Fields (LUÔN trả ra theo sys_config_form) ========== */
    IF EXISTS (SELECT 1 FROM dbo.mas_employee 
               WHERE (@empId IS NOT NULL AND empId = @empId))
    BEGIN
        SELECT  a.id,
                a.table_name,
                a.field_name,
                a.view_type,
                a.data_type,
                a.ordinal,
                a.columnLabel,
                a.group_cd,
                columnValue =
                    ISNULL(
                        CASE
                            WHEN a.data_type = 'nvarchar' THEN
                                CONVERT(NVARCHAR(350),
                                    CASE a.field_name
                                        WHEN 'code'          THEN e.code
                                        WHEN 'custId'        THEN e.custId
                                        WHEN 'userId'        THEN e.userId
                                        WHEN 'fullName'      THEN e.fullName
                                        WHEN 'email'         THEN e.email
                                        WHEN 'phone'         THEN e.phone
                                        WHEN 'idcard_no'     THEN e.idcard_no
                                        WHEN 'departmentName' THEN e.departmentName
                                        WHEN 'orgName'       THEN e.orgName
                                        WHEN 'companyName'   THEN e.companyName
                                        WHEN 'positionTypeName' THEN e.positionTypeName
                                    END
                                )
                            WHEN a.data_type = 'uniqueidentifier' THEN
                                CONVERT(NVARCHAR(500),
                                    CASE a.field_name
                                        WHEN 'empId'         THEN LOWER(CONVERT(NVARCHAR(500), e.empId))
                                    END
                                )
                            WHEN a.data_type = 'datetime' THEN
                                CONVERT(NVARCHAR(50),
                                    CASE a.field_name
                                        WHEN 'created_at'    THEN CONVERT(NVARCHAR(50), FORMAT(e.created_at, 'dd/MM/yyyy HH:mm:ss'))
                                        WHEN 'updated_at'    THEN CONVERT(NVARCHAR(50), FORMAT(e.updated_at, 'dd/MM/yyyy HH:mm:ss'))
                                    END
                                )
                            ELSE
                                CONVERT(NVARCHAR(50),
                                    CASE a.field_name
                                        WHEN 'emp_st'        THEN CONVERT(NVARCHAR(10), e.emp_st)
                                    END
                                )
                        END,
                        a.columnDefault
                    ),
                a.columnClass,
                a.columnType,
                a.columnObject,
                a.isSpecial,
                a.isRequire,
                a.isDisable,
                a.isVisiable,
                IsEmpty = ISNULL(a.IsEmpty, 0),
                columnTooltip = ISNULL(a.columnTooltip, a.columnLabel)
                , a.columnDisplay
                , a.isIgnore
        FROM fn_config_form_gets(@table_key, @acceptLanguage) a
        LEFT JOIN dbo.mas_employee e ON (@empId IS NOT NULL AND e.empId = @empId)
        --WHERE (a.isVisiable = 1 OR a.isRequire = 1)
        ORDER BY a.ordinal;
    END
    ELSE
    BEGIN
        -- Nếu không có record, trả về form mặc định
        SELECT  a.id,
                a.table_name,
                a.field_name,
                a.view_type,
                a.data_type,
                a.ordinal,
                a.columnLabel,
                a.group_cd,
                columnValue = a.columnDefault,
                a.columnClass,
                a.columnType,
                a.columnObject,
                a.isSpecial,
                a.isRequire,
                isDisable = 0,
                a.isVisiable,
                IsEmpty = ISNULL(a.IsEmpty, 0),
                columnTooltip = ISNULL(a.columnTooltip, a.columnLabel)
                , a.columnDisplay
                , a.isIgnore
        FROM fn_config_form_gets(@table_key, @acceptLanguage) a
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
    SET @ErrorMsg = 'sp_res_employee_field' + ERROR_MESSAGE();
    SET @ErrorProc = ERROR_PROCEDURE();
    SET @AddlInfo = ' ';

    EXEC utl_ErrorLog_Set @ErrorNum, @ErrorMsg,@ErrorProc, 'Employee', 'GetInfo', @SessionID, @AddlInfo;
END CATCH;