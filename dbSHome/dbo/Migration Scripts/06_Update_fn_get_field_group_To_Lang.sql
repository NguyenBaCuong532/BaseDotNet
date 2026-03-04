-- =============================================
-- Script: Cập nhật fn_get_field_group → fn_get_field_group_lang
-- Mô tả: Thay thế tất cả fn_get_field_group(@groupKey) 
--        thành fn_get_field_group_lang(@groupKey, @acceptLanguage)
-- Author: System
-- Created: 2025-01-29
-- =============================================

-- =============================================
-- 1. Tìm tất cả stored procedures cần cập nhật
-- =============================================
SELECT 
    OBJECT_NAME(object_id) AS ProcedureName,
    CASE 
        WHEN definition LIKE '%@acceptLanguage%' THEN 'Có @acceptLanguage - SẴN SÀNG CẬP NHẬT'
        ELSE 'THIẾU @acceptLanguage - CẦN THÊM TRƯỚC'
    END AS Status
FROM sys.sql_modules
WHERE definition LIKE '%fn_get_field_group(%'
  AND definition NOT LIKE '%fn_get_field_group_lang%'
ORDER BY Status DESC, OBJECT_NAME(object_id);

-- =============================================
-- 2. Pattern cập nhật
-- =============================================
/*
-- TRƯỚC:
SELECT * FROM dbo.fn_get_field_group(@groupKey)
SELECT * FROM [dbo].[fn_get_field_group](@groupKey)
SELECT * FROM dbo.fn_get_field_group(@GroupKey)

-- SAU:
SELECT * FROM dbo.fn_get_field_group_lang(@groupKey, @acceptLanguage)
SELECT * FROM [dbo].[fn_get_field_group_lang](@groupKey, @acceptLanguage)
SELECT * FROM dbo.fn_get_field_group_lang(@GroupKey, @AcceptLanguage)
*/

-- =============================================
-- 3. Script tự động cập nhật (CẨN THẬN - Backup trước khi chạy)
-- =============================================
/*
DECLARE @sql NVARCHAR(MAX);
DECLARE @procName SYSNAME;
DECLARE @oldDefinition NVARCHAR(MAX);
DECLARE @newDefinition NVARCHAR(MAX);

DECLARE proc_cursor CURSOR FOR
SELECT 
    OBJECT_NAME(object_id),
    definition
FROM sys.sql_modules
WHERE definition LIKE '%fn_get_field_group(%'
  AND definition NOT LIKE '%fn_get_field_group_lang%'
  AND definition LIKE '%@acceptLanguage%'; -- Chỉ cập nhật những SP đã có @acceptLanguage

OPEN proc_cursor;
FETCH NEXT FROM proc_cursor INTO @procName, @oldDefinition;

WHILE @@FETCH_STATUS = 0
BEGIN
    SET @newDefinition = @oldDefinition;
    
    -- Thay thế các pattern
    SET @newDefinition = REPLACE(@newDefinition, 
        'fn_get_field_group(@groupKey)', 
        'fn_get_field_group_lang(@groupKey, @acceptLanguage)');
    SET @newDefinition = REPLACE(@newDefinition, 
        'fn_get_field_group(@GroupKey)', 
        'fn_get_field_group_lang(@GroupKey, @AcceptLanguage)');
    SET @newDefinition = REPLACE(@newDefinition, 
        '[dbo].[fn_get_field_group](@groupKey)', 
        '[dbo].[fn_get_field_group_lang](@groupKey, @acceptLanguage)');
    SET @newDefinition = REPLACE(@newDefinition, 
        'dbo.fn_get_field_group(@groupKey)', 
        'dbo.fn_get_field_group_lang(@groupKey, @acceptLanguage)');
    
    -- Chỉ cập nhật nếu có thay đổi
    IF @newDefinition <> @oldDefinition
    BEGIN
        PRINT 'Updating: ' + @procName;
        -- EXEC sp_executesql @newDefinition; -- UNCOMMENT ĐỂ THỰC SỰ CẬP NHẬT
        PRINT 'Updated: ' + @procName;
    END
    
    FETCH NEXT FROM proc_cursor INTO @procName, @oldDefinition;
END

CLOSE proc_cursor;
DEALLOCATE proc_cursor;
*/

-- =============================================
-- 4. Danh sách stored procedures đã cập nhật thủ công
-- =============================================
/*
✅ Đã cập nhật:
- sp_res_apartment_field
- sp_res_employee_field
- sp_res_elevator_floor_field
- sp_app_apartment_member_field
- sp_app_notify_sent_field
- sp_app_request_field

⏳ Cần cập nhật:
- sp_app_service_field
- sp_res_vehicle_internal_field
- sp_res_partner_field
- sp_res_calendar_field
- sp_Crm_Template_fields_1
- sp_Crm_Policy_Card_Fields_1
- sp_Crm_Group_fields_1
- sp_res_request_field
- sp_res_employee_field_1
- sp_res_vehicle_payment_fields
- sp_res_card_vehicle_field_draft
- sp_res_apartment_merge_member_field_draft
- sp_Crm_Template_fields
- sp_Crm_Policy_Card_Fields
- sp_Crm_Group_fields
- sp_res_apartment_family_member_field_draft
- sp_res_report_list
- sp_bzz_report_list
- sp_res_apartment_fee_field_draft
- sp_res_card_guest_field
- sp_common_filter_draft
- sp_res_vehicle_payment_field
- sp_res_card_internal_field
- sp_res_notify_temp_fields
- sp_res_card_guest_draft
- sp_res_apartment_profile_receipt_field
*/
