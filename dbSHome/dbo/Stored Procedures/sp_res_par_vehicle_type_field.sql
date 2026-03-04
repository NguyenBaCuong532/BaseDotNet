-- =============================================
-- Author:      ThanhMT
-- Create date: 14/11/2025
-- Description: Gom nhóm các loại xe để cấu hình tính số lượng - Danh sách dữ liệu phân trang
-- =============================================
CREATE PROCEDURE [dbo].[sp_res_par_vehicle_type_field]
    @UserId uniqueidentifier = NULL,
    @project_code VARCHAR(50) = NULL,
    @oid uniqueidentifier = NULL,
    @AcceptLanguage VARCHAR(20) = 'vi-VN'
AS
BEGIN TRY
    DECLARE @GroupKey NVARCHAR(100) = 'common_group' -- 'config_sp_res_par_vehicle_type_field_group';--sys_config_data
    DECLARE @TableName NVARCHAR(100) = 'config_sp_res_par_vehicle_type_field';--sys_config_form

    -- Config Info
    SELECT 
        CONVERT(UNIQUEIDENTIFIER, @oid) as gd,
        @TableName AS tableKey,
        @GroupKey AS groupKey
		
    -- Get Group Info
    SELECT * FROM [dbo].[fn_get_field_group](@GroupKey) ORDER by intOrder
	
    -- Fields Info
    SELECT
        CASE [data_type]
            WHEN 'uniqueidentifier' THEN CONVERT(NVARCHAR(MAX), 
                CASE [field_name]
                    WHEN 'oid' THEN b.oid
                END)
            WHEN 'nvarchar' THEN CONVERT(NVARCHAR(MAX), 
                CASE [field_name]
                    WHEN 'config_name' THEN b.config_name
                    WHEN 'vehicle_type_id' THEN b.vehicle_type_id
                END)
            WHEN 'int' THEN CONVERT(NVARCHAR(MAX), 
                CASE [field_name]
                    WHEN 'sort_order' THEN b.sort_order
                END)
            WHEN 'bit' THEN CONVERT(NVARCHAR(MAX), 
                CASE [field_name]
                    WHEN 'block_pricing' THEN IIF(b.block_pricing = 1, 'true', 'false')
                END)
        END AS columnValue,
        [field_name],
        [view_type],
        [data_type],
        [ordinal],
        [columnLabel],
        group_cd,
        [columnClass],
        [columnType],
        [columnObject] = CASE WHEN a.[field_name] = 'vehicle_type_id' THEN CONCAT(a.[columnObject], N'?oid=', @oid) ELSE a.[columnObject] END,
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
        OUTER APPLY (SELECT TOP 1 * FROM par_vehicle_type d WHERE oid = @oid) b
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