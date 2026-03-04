-- =============================================
-- Author:		<sonpt02>
-- Create date: <3/12/2024>
-- Description:	<set users details>
-- =============================================
CREATE PROCEDURE [dbo].[sp_res_user_profile_fields]
    @userId UNIQUEIDENTIFIER = NULL,
    @acceptLanguage NVARCHAR(50) = N'vi-VN'
AS
BEGIN TRY
    SET NOCOUNT ON;

    -- Khai báo biến
    DECLARE @group_key VARCHAR(50) = 'common_group';
    DECLARE @table_key VARCHAR(50) = 'Users';

    -- =============================================
    -- RESULT SET 1: INFO - Thông tin cơ bản
    -- =============================================
    SELECT 
        userId = @userId,
        tableKey = @table_key,
        groupKey = @group_key;

    -- =============================================
    -- RESULT SET 2: GROUPS - Nhóm field
    -- =============================================
    SELECT *
    FROM [dbo].[fn_get_field_group_lang](@group_key, @acceptLanguage)
    ORDER BY intOrder;

	IF EXISTS (
            SELECT 1
            FROM dbo.Users
            WHERE userId = @userId
            )
    BEGIN
        SELECT 
            s.id,
            s.table_name,
            s.field_name,
            s.view_type,
            s.data_type,
            s.ordinal,
            s.columnLabel,
            s.group_cd,
            , columnValue = ISNULL(CASE s.field_name
                    WHEN 'lastDt' THEN CONVERT(NVARCHAR(450), FORMAT(b.last_dt, 'dd/MM/yyyy'))
                    WHEN 'IsAdmin' THEN CONVERT(NVARCHAR(5), CASE WHEN b.admin_st = 1 THEN 'true' ELSE 'false' END)
                    WHEN 'FullName' THEN b.fullName
                    WHEN 'loginName' THEN b.loginName
                    WHEN 'Phone' THEN b.phone
                    WHEN 'Email' THEN b.email
                    WHEN 'Position' THEN b.position
                    WHEN 'createDt' THEN CONVERT(NVARCHAR(450), FORMAT(b.created_dt, 'dd/MM/yyyy'))
                    WHEN 'parentId' THEN b.parent_id
                    WHEN 'createBy' THEN b.created_by	
                    WHEN 'orgId' THEN CONVERT(NVARCHAR(450), b.orgId)
                    WHEN 'active' THEN CONVERT(NVARCHAR(5), CASE WHEN b.active = 1 THEN 'true' ELSE 'false' END)
                END, s.columnDefault)
            , s.columnClass
            , s.columnType
            , s.columnObject
            , s.isSpecial
            , s.isRequire
            , s.isDisable
            , s.IsVisiable
            , s.isEmpty
            , columnTooltip = ISNULL(s.columnTooltip, s.columnLabel)
            , s.columnDisplay
            , s.isIgnore
        FROM dbo.fn_config_form_gets(@table_key, @acceptLanguage) s
        CROSS JOIN Users b
        WHERE s.view_type = 0
            AND b.userId = @userId
            AND (s.IsVisiable = 1 OR s.isRequire = 1)
        ORDER BY s.ordinal
			END
		ELSE
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
            FROM dbo.fn_config_form_gets(@table_key, @acceptLanguage) a
            WHERE (a.IsVisiable = 1 OR a.isRequire = 1)
            ORDER BY a.ordinal
	END
END TRY
BEGIN CATCH
    DECLARE @ErrorNum INT,
            @ErrorMsg VARCHAR(200),
            @ErrorProc VARCHAR(50),
            @SessionID INT,
            @AddlInfo VARCHAR(MAX);

    SET @ErrorNum = ERROR_NUMBER();
    SET @ErrorMsg = 'sp_user_profile_fields' + ERROR_MESSAGE();
    SET @ErrorProc = ERROR_PROCEDURE();

    SET @AddlInfo = ' ';

    EXEC utl_errorlog_set @ErrorNum,
                          @ErrorMsg,
                          @ErrorProc,
                          'Users',
                          'GetInfo',
                          @SessionID,
                          @AddlInfo;
END CATCH;