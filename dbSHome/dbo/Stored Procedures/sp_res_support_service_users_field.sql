-- =============================================
-- Author:      ThanhMT
-- Create date: 19/01/2026
-- Description: Phân công trưởng nhóm và các thành viên xử lý nhóm yêu cầu hỗ trợ - Lấy thông tin thêm mới hoặc chỉnh sửa
-- =============================================
CREATE PROCEDURE [dbo].[sp_res_support_service_users_field]
    @UserId uniqueidentifier = NULL,
    @project_code VARCHAR(50) = NULL,
    @oid uniqueidentifier = NULL,
    @service_type_oid NVARCHAR(50) = NULL,
    @support_service_oid NVARCHAR(50) = NULL,
    @user_oid NVARCHAR(50) = NULL,
    @service_role NVARCHAR(100) = NULL,
    @is_active BIT = NULL,
    @AcceptLanguage VARCHAR(20) = 'vi-VN'
AS
BEGIN TRY
    DECLARE @GroupKey NVARCHAR(100) = 'common_group' -- sys_config_data
    DECLARE @TableName NVARCHAR(100) = 'support_service_users_field';--sys_config_form

    -- Config Info
    SELECT 
        CONVERT(UNIQUEIDENTIFIER, @oid) as gd,
        @TableName AS tableKey,
        @GroupKey AS groupKey
		
    -- Get Group Info
    SELECT * FROM [dbo].[fn_get_field_group](@GroupKey) ORDER by intOrder
	
    -- Fields Info
    SELECT
        [columnValue] = CASE [data_type]
                            WHEN 'uniqueidentifier' THEN LOWER(CONVERT(NVARCHAR(MAX), 
                                CASE [field_name]
                                    WHEN 'oid' THEN ISNULL(@oid, b.oid)
                                    WHEN 'service_type_oid' THEN ISNULL(@service_type_oid, s.service_type_id)
                                    WHEN 'support_service_oid' THEN ISNULL(@support_service_oid, b.support_service_oid)
                                    WHEN 'user_oid' THEN ISNULL(@user_oid, b.user_oid)
                                END))
                            WHEN 'nvarchar' THEN CONVERT(NVARCHAR(MAX), 
                                CASE [field_name]
                                    WHEN 'service_role' THEN ISNULL(@service_role, b.service_role)
                                END)
                            WHEN 'bit' THEN CONVERT(NVARCHAR(MAX), 
                                CASE [field_name]
                                    WHEN 'is_active' THEN IIF(ISNULL(@is_active, b.is_active) = 1, 'true', 'false')
                                END)
                        END,
        [field_name],
        [view_type],
        [data_type],
        [ordinal],
        [columnLabel],
        [group_cd],
        [columnClass],
        [columnType],
        [columnObject] = CASE
                            WHEN [field_name] = 'support_service_oid' THEN [columnObject]+'&columnParent=service_type_id&valueParent='+ISNULL(@service_type_oid, s.service_type_id)+'&colSortOrder=ordinal'
                            WHEN [field_name] = 'user_oid' THEN [columnObject]+'?userIds='+ ISNULL(@user_oid, ISNULL(CONVERT(VARCHAR(50), b.user_oid), '')) +'&filter='
                            ELSE [columnObject]
                         END,
        [isSpecial],
        [isRequire],
        [isDisable],
        [IsVisiable],
        [IsEmpty],
        isnull(a.columnTooltip, a.[columnLabel]) as columnTooltip,
        [columnDisplay],
        [isIgnore]
    FROM
        dbo.[fn_config_form_gets](@TableName, @AcceptLanguage) a
        OUTER APPLY(SELECT TOP 1 * FROM support_service_users d WHERE oid = @oid) b
        OUTER APPLY(SELECT TOP 1 s.id, s.service_type_id
                    FROM
                        service s
                        INNER JOIN service_type t ON s.service_type_id = t.id
                    WHERE s.id = support_service_oid) s
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