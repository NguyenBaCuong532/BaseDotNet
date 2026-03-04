-- Danh sách các stored procedures sp_res_* còn sử dụng sys_config_form
-- Cần cập nhật: FROM sys_config_form → FROM fn_config_form_gets('TableName', @acceptLanguage)
-- Và xóa WHERE table_name = '...' vì function đã filter sẵn

-- ✅ ĐÃ CẬP NHẬT:
-- 1. sp_res_apartment_vehicle_field.sql
-- 2. sp_res_apartment_family_member_field.sql  
-- 3. sp_res_service_expected_details_field.sql

-- ⏳ CÒN LẠI CẦN CẬP NHẬT:

-- *_field procedures:
-- 4. sp_res_apartment_service_cut_history_field.sql
-- 5. sp_res_apartment_get_apartmentid_by_custid.sql
-- 6. sp_res_apartment_change_host_field.sql
-- 7. sp_res_apartment_family_member_phone_field.sql
-- 8. sp_res_apartment_service_living_field.sql
-- 9. sp_res_invoice_confirm_field.sql
-- 10. sp_res_notify_info_fields2.sql
-- 11. sp_res_apartment_profile_field.sql
-- 12. sp_res_apartment_violation_history_field.sql
-- 13. sp_res_receipt_field.sql
-- 14. sp_res_edit_card_family_field.sql
-- 15. sp_res_card_resident_field.sql
-- 16. sp_res_card_lock_field.sql
-- 17. sp_res_vehicle_lock_field_1.sql
-- 18. sp_res_vehicle_cancel_info_1.sql
-- 19. sp_res_service_living_meter_field_new_1.sql
-- 20. sp_res_apartment_changeRoomCode_field.sql
-- 21. sp_res_service_living_meter_field_new.sql
-- 22. sp_res_vehicle_cancel_info.sql
-- 23. sp_res_vehicle_lock_field.sql
-- 24. sp_res_card_family_field.sql
-- 25. sp_res_service_expected_receivable_extend_field.sql
-- 26. sp_res_family_member_getByPhone_field.sql
-- 27. sp_res_card_vehicle_paymentByDay_field.sql
-- 28. sp_res_card_field.sql
-- 29. sp_res_apartment_household_field.sql
-- 30. sp_res_apartment_add_field.sql
-- 31. sp_res_user_profile_fields.sql

-- *_filter procedures:
-- 32. sp_res_workorder_filter.sql
-- 33. sp_res_parcel_filter.sql
-- 34. sp_res_maintenance_plan_filter.sql
-- 35. sp_res_apartment_lock_filter.sql
-- 36. sp_res_cleaning_service_filter.sql
-- 37. sp_res_service_expected_filter.sql
-- 38. sp_res_card_base_filter.sql
-- 39. sp_res_notify_push_filter.sql
-- 40. sp_res_sys_manager_filter_get.sql
-- 41. sp_res_service_receivable_filter.sql
-- 42. sp_res_service_living_meter_filter.sql
-- 43. sp_res_resident_card_filter.sql
-- 44. sp_res_request_filter.sql
-- 45. sp_res_receipt_filter.sql
-- 46. sp_res_notify_temp_filter.sql
-- 47. sp_res_notify_filter.sql
-- 48. sp_res_card_vehicle_daily_filter.sql
-- 49. sp_res_apartment_household_filter.sql
-- 50. sp_res_apartment_filter.sql

-- Other procedures:
-- 51. sp_res_card_vehicle_payment_load_form.sql
-- 52. sp_res_notify_info_draft.sql (commented out, có thể bỏ qua)
-- 53. sp_res_notify_temp_draft.sql

-- Pattern cập nhật:
/*
-- TRƯỚC:
FROM sys_config_form s
WHERE s.table_name = 'TableName'

-- SAU:
FROM dbo.fn_config_form_gets('TableName', @acceptLanguage) s
-- Xóa WHERE s.table_name = 'TableName' vì function đã filter sẵn

-- Đảm bảo có @acceptLanguage parameter:
@acceptLanguage NVARCHAR(50) = N'vi-VN'
*/
