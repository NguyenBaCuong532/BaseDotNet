-- =============================================
-- Script: Batch Update @userId nvarchar* → @userId UNIQUEIDENTIFIER
-- Mô tả: Cập nhật tất cả stored procedures chuyển @userId từ nvarchar sang UNIQUEIDENTIFIER
-- Author: System
-- Created: 2025-01-29
-- =============================================

-- =============================================
-- DANH SÁCH STORED PROCEDURES ĐÃ CẬP NHẬT
-- =============================================
/*
✅ Đã cập nhật (26 procedures):
1. sp_res_get_fee_info
2. sp_res_maintenance_plan_fields
3. sp_res_notify_info_draft
4. sp_res_service_living_meter_field
5. sp_res_parcel_fields
6. sp_res_service_receivable_field
7. sp_res_workorder_fields
8. sp_res_card_vehicle_field
9. sp_res_vehicle_payment_fields
10. sp_res_vehicle_payment_field
11. sp_res_vehicle_internal_field
12. sp_res_request_field
13. sp_res_elevator_floor_field
14. sp_res_employee_field
15. sp_res_employee_field_1
16. sp_res_elevator_floor_page
17. sp_res_apartment_page
18. sp_res_building_page
19. sp_res_card_vehicle_field_draft
20. sp_res_card_internal_field
21. sp_res_card_guest_field
22. sp_res_card_guest_draft
23. sp_res_apartment_profile_receipt_field
24. sp_res_apartment_merge_member_field_draft
25. sp_res_apartment_fee_field_draft
26. sp_res_apartment_family_member_field_draft
27. sp_Hom_Floor_List
28. sp_Hom_Room_List
29. sp_common_filter_draft
30. sp_res_vehicle_resident_field
31. sp_res_apartment_floor_list
32. sp_res_apartment_room_list
33. sp_res_apartment_fee_field
34. sp_res_service_living_meter_water_calculate
35. sp_res_card_set
36. sp_res_workorder_set
37. sp_res_workorder_page
38. sp_res_partner_page
39. sp_res_calendar_page
40. sp_res_apartment_lock_page
41. sp_res_request_page
42. sp_res_service_living_meter_page
43. sp_res_maintenance_plan_page
44. sp_res_parcel_page
45. sp_res_calendar_set
46. sp_res_apartment_lock_set
*/

-- =============================================
-- QUERY TÌM CÁC STORED PROCEDURES CẦN CẬP NHẬT
-- =============================================
SELECT 
    OBJECT_NAME(object_id) AS ProcedureName,
    CASE 
        WHEN definition LIKE '%@userId UNIQUEIDENTIFIER%' OR definition LIKE '%@UserId UNIQUEIDENTIFIER%' THEN '✅ Đã cập nhật'
        WHEN definition LIKE '%@userId nvarchar%' OR definition LIKE '%@UserId nvarchar%' OR 
             definition LIKE '%@userid nvarchar%' OR definition LIKE '%@UserID nvarchar%' THEN '⏳ Cần cập nhật'
        ELSE '❓ Không có @userId'
    END AS Status
FROM sys.sql_modules
WHERE (definition LIKE '%@userId%' OR definition LIKE '%@UserId%' OR definition LIKE '%@userid%' OR definition LIKE '%@UserID%')
ORDER BY Status DESC, OBJECT_NAME(object_id);

-- =============================================
-- PATTERN CẬP NHẬT
-- =============================================
/*
-- Pattern 1: @userId nvarchar(450) → @userId UNIQUEIDENTIFIER
@userId NVARCHAR(450) = NULL
→
@userId UNIQUEIDENTIFIER = NULL

-- Pattern 2: @UserId nvarchar(50) → @UserId UNIQUEIDENTIFIER
@UserId NVARCHAR(50)
→
@UserId UNIQUEIDENTIFIER

-- Pattern 3: @UserID nvarchar(450) → @UserID UNIQUEIDENTIFIER
@UserID NVARCHAR(450)
→
@UserID UNIQUEIDENTIFIER

-- Pattern 4: @userid nvarchar(40) → @userid UNIQUEIDENTIFIER
@userid nvarchar(40) = null
→
@userid UNIQUEIDENTIFIER = null

-- Lưu ý: Cần kiểm tra các chỗ sử dụng @userId trong code để đảm bảo tương thích
-- Ví dụ: Nếu có CONVERT hoặc CAST từ nvarchar sang uniqueidentifier, có thể cần điều chỉnh
*/
