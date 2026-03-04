-- =============================================
-- Script: Batch Update fn_get_field_group → fn_get_field_group_lang
-- Mô tả: Script để cập nhật hàng loạt các stored procedures
-- Author: System
-- Created: 2025-01-29
-- =============================================

-- =============================================
-- DANH SÁCH STORED PROCEDURES ĐÃ CẬP NHẬT
-- =============================================
/*
✅ Đã cập nhật:
1. sp_res_apartment_field
2. sp_res_employee_field
3. sp_res_elevator_floor_field
4. sp_app_apartment_member_field
5. sp_app_notify_sent_field
6. sp_app_request_field
7. sp_app_service_field
8. sp_res_request_field
9. sp_res_vehicle_internal_field
10. sp_res_partner_field
11. sp_res_calendar_field

⏳ CẦN CẬP NHẬT (còn lại):
- sp_Crm_Template_fields_1
- sp_Crm_Policy_Card_Fields_1
- sp_Crm_Group_fields_1
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

-- =============================================
-- PATTERN CẬP NHẬT
-- =============================================
/*
-- Bước 1: Kiểm tra và thêm @acceptLanguage (nếu thiếu)
-- Tìm: CREATE PROCEDURE [dbo].[sp_xxx]
--      @param1 ...
-- Thêm: ,@acceptLanguage NVARCHAR(50) = N'vi-VN'

-- Bước 2: Thay fn_get_field_group
-- TRƯỚC:
SELECT * FROM dbo.fn_get_field_group(@groupKey)
SELECT * FROM [dbo].[fn_get_field_group](@groupKey)
SELECT * FROM dbo.fn_get_field_group(@GroupKey)
SELECT * FROM dbo.fn_get_field_group(N'common_group')

-- SAU:
SELECT * FROM dbo.fn_get_field_group_lang(@groupKey, @acceptLanguage)
SELECT * FROM [dbo].[fn_get_field_group_lang](@groupKey, @acceptLanguage)
SELECT * FROM dbo.fn_get_field_group_lang(@GroupKey, @AcceptLanguage)
SELECT * FROM dbo.fn_get_field_group_lang(N'common_group', @acceptLanguage)
*/

-- =============================================
-- QUERY ĐỂ TÌM CÁC STORED PROCEDURES CẦN CẬP NHẬT
-- =============================================
SELECT 
    OBJECT_NAME(object_id) AS ProcedureName,
    CASE 
        WHEN definition LIKE '%@acceptLanguage%' THEN '✅ Có @acceptLanguage'
        ELSE '❌ THIẾU @acceptLanguage'
    END AS HasAcceptLanguage,
    CASE 
        WHEN definition LIKE '%fn_get_field_group_lang%' THEN '✅ Đã cập nhật'
        ELSE '⏳ Cần cập nhật'
    END AS Status
FROM sys.sql_modules
WHERE definition LIKE '%fn_get_field_group(%'
  AND definition NOT LIKE '%fn_get_field_group_lang%'
ORDER BY HasAcceptLanguage DESC, OBJECT_NAME(object_id);
