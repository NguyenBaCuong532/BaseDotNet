
CREATE PROCEDURE [dbo].[sp_res_apartment_lock_field]
    @oid UNIQUEIDENTIFIER = NULL,
    @UserId UNIQUEIDENTIFIER = NULL,
    @AcceptLanguage VARCHAR(20) = 'vi-VN'
AS
BEGIN TRY
    SET NOCOUNT ON;

    DECLARE @group_key VARCHAR(50) = 'apartment_lock_form_group';
    DECLARE @table_key VARCHAR(50) = 'ApartmentLock';

    SELECT [id] = CONVERT(NVARCHAR(50), @oid), tableKey = @table_key, groupKey = @group_key;

    SELECT *
    FROM dbo.fn_get_field_group_lang(@group_key, @AcceptLanguage)
    ORDER BY intOrder;

    SELECT
        s.table_name,
        s.field_name,
        s.view_type,
        s.data_type,
        s.ordinal,
        s.columnLabel,
        s.group_cd,
        columnValue =
            CASE
                WHEN l.oid IS NOT NULL THEN
                    ISNULL(
                        CASE s.field_name
                            WHEN 'id' THEN CONVERT(NVARCHAR(50), l.oid)
                            WHEN 'project_cd' THEN l.project_cd
                            WHEN 'apartment_id' THEN CONVERT(NVARCHAR(50), l.apartment_id)
                            WHEN 'device_id' THEN CONVERT(NVARCHAR(50), l.device_id)
                            WHEN 'lock_name' THEN l.lock_name
                            WHEN 'door_code' THEN l.door_code
                            WHEN 'status' THEN CONVERT(NVARCHAR(10), l.status)
                            WHEN 'last_unlock_dt' THEN CONVERT(NVARCHAR(10), l.last_unlock_dt, 103)
                            WHEN 'last_unlock_by' THEN l.last_unlock_by
                            WHEN 'created_by' THEN l.created_by
                            WHEN 'created_dt' THEN CONVERT(NVARCHAR(10), l.created_dt, 103)
                            WHEN 'updated_by' THEN l.updated_by
                            WHEN 'updated_dt' THEN CONVERT(NVARCHAR(10), l.updated_dt, 103)
                        END,
                        s.columnDefault
                    )
                ELSE
                    CASE
                        WHEN s.field_name = 'status' THEN '0'
                        WHEN s.field_name = 'created_dt' THEN CONVERT(NVARCHAR(10), GETDATE(), 103)
                        ELSE s.columnDefault
                    END
            END,
        s.columnClass,
        s.columnType,
        s.columnObject,
        s.isSpecial,
        s.isRequire,
        isDisable = CASE WHEN s.field_name IN ('id','created_dt','created_by','updated_dt','updated_by') THEN 1 ELSE s.isDisable END,
        s.isVisiable,
        NULL AS IsEmpty,
        ISNULL(s.columnTooltip, s.columnLabel) AS columnTooltip
    FROM dbo.fn_config_form_gets(@table_key, @AcceptLanguage) s
    LEFT JOIN dbo.apartment_lock l
        ON l.oid = @oid AND l.is_deleted = 0
    WHERE s.table_name = @table_key
    ORDER BY s.ordinal;
END TRY
BEGIN CATCH
    SELECT CAST(0 AS BIT) AS valid, ERROR_MESSAGE() AS [messages];
END CATCH