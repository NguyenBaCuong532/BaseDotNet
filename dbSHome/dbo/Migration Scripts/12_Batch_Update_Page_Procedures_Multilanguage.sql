-- =============================================
-- Script: Batch Update *_page procedures - fn_config_list_gets → fn_config_list_gets_lang
-- Mô tả: Cập nhật tất cả stored procedures *_page để hỗ trợ đa ngôn ngữ
-- Author: System
-- Created: 2025-01-29
-- =============================================

-- =============================================
-- DANH SÁCH STORED PROCEDURES ĐÃ CẬP NHẬT
-- =============================================
/*
✅ Đã cập nhật hoàn chỉnh (8 procedures):
1. sp_res_service_living_meter_page
2. sp_res_parcel_page
3. sp_res_workorder_page
4. sp_res_partner_page
5. sp_res_calendar_page
6. sp_res_apartment_lock_page
7. sp_res_request_page
8. sp_res_maintenance_plan_page
*/

-- =============================================
-- QUERY TÌM CÁC STORED PROCEDURES CẦN CẬP NHẬT
-- =============================================
SELECT 
    OBJECT_NAME(object_id) AS ProcedureName,
    CASE 
        WHEN definition LIKE '%@acceptLanguage%' THEN '✅ Có @acceptLanguage'
        ELSE '❌ THIẾU @acceptLanguage'
    END AS HasAcceptLanguage,
    CASE 
        WHEN definition LIKE '%fn_config_list_gets_lang%' THEN '✅ Đã cập nhật'
        WHEN definition LIKE '%fn_config_list_gets%' AND definition LIKE '%_page%' THEN '⏳ Cần cập nhật'
        ELSE '❓ Không sử dụng fn_config_list_gets'
    END AS Status
FROM sys.sql_modules
WHERE OBJECT_NAME(object_id) LIKE '%_page'
  AND (definition LIKE '%fn_config_list_gets%' OR definition LIKE '%@acceptLanguage%')
ORDER BY HasAcceptLanguage DESC, Status DESC, OBJECT_NAME(object_id);

-- =============================================
-- PATTERN CẬP NHẬT
-- =============================================
/*
-- Pattern 1: Thêm @acceptLanguage parameter
-- TRƯỚC:
@PageSize INT = 10
AS

-- SAU:
@PageSize INT = 10,
@acceptLanguage NVARCHAR(50) = N'vi-VN'
AS

-- Pattern 2: Thay fn_config_list_gets → fn_config_list_gets_lang
-- TRƯỚC:
SELECT * FROM [dbo].fn_config_list_gets(@GridKey, @gridWidth)
ORDER BY [ordinal];

-- SAU:
SELECT * FROM [dbo].fn_config_list_gets_lang(@GridKey, @gridWidth, @acceptLanguage)
ORDER BY [ordinal];

-- Pattern 3: Các biến thể khác
-- fn_config_list_gets(@GridKey, 0) → fn_config_list_gets_lang(@GridKey, 0, @acceptLanguage)
-- dbo.fn_config_list_gets(@GridKey, @gridWidth) → dbo.fn_config_list_gets_lang(@GridKey, @gridWidth, @acceptLanguage)
*/

-- =============================================
-- DANH SÁCH STORED PROCEDURES CẦN CẬP NHẬT (ước tính ~100+ files)
-- =============================================
/*
⏳ CẦN CẬP NHẬT:
- sp_res_card_base_page
- sp_app_feedback_page
- sp_app_card_page
- sp_app_card_amenity_page
- sp_app_apartment_member_page
- sp_res_vehicle_resident_page
- sp_res_support_service_users_page
- sp_res_service_type_page
- sp_res_partner_vehicle_page
- sp_res_partner_staff_page
- sp_res_partner_card_vehicle_page
- sp_res_partner_card_page
- sp_res_elevator_device_category_page
- sp_res_card_vehicle_page_bycd
- sp_res_apartment_lock_history
- sp_res_service_receive_entry_page
- sp_res_household_page
- sp_res_card_vehicle_payment_history_page
- sp_res_card_vehicle_swipe_history_page
- sp_res_card_vehicle_history_page
- sp_res_apartment_household_page_byid
- Và nhiều stored procedures khác...
*/
