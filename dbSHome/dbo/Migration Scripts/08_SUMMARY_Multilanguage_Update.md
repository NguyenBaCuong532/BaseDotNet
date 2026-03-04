# Tổng kết cập nhật đa ngôn ngữ cho Stored Procedures

## ✅ Đã hoàn thành

### 1. Cập nhật các stored procedures *_page (3 files)
- `sp_res_apartment_page` - ✅
- `sp_res_building_page` - ✅  
- `sp_res_elevator_floor_page` - ✅

**Pattern**: Thêm `@acceptLanguage NVARCHAR(50) = N'vi-VN'` và thay `fn_config_list_gets` → `fn_config_list_gets_lang`

### 2. Cập nhật các stored procedures *_field (23 files)
- `sp_res_apartment_field` - ✅
- `sp_res_employee_field` - ✅
- `sp_res_elevator_floor_field` - ✅
- `sp_app_apartment_member_field` - ✅
- `sp_app_notify_sent_field` - ✅
- `sp_app_request_field` - ✅
- `sp_app_service_field` - ✅
- `sp_res_request_field` - ✅
- `sp_res_vehicle_internal_field` - ✅
- `sp_res_partner_field` - ✅
- `sp_res_calendar_field` - ✅
- `sp_res_card_guest_field` - ✅
- `sp_res_vehicle_payment_field` - ✅
- `sp_res_card_internal_field` - ✅
- `sp_res_apartment_profile_receipt_field` - ✅
- `sp_res_notify_temp_fields` - ✅
- `sp_res_vehicle_payment_fields` - ✅
- `sp_res_employee_field_1` - ✅
- `sp_res_card_vehicle_field_draft` - ✅
- `sp_res_apartment_merge_member_field_draft` - ✅
- `sp_res_apartment_family_member_field_draft` - ✅
- `sp_res_apartment_fee_field_draft` - ✅
- `sp_common_filter_draft` - ✅
- `sp_res_card_guest_draft` - ✅

**Pattern**: Thêm `@acceptLanguage NVARCHAR(50) = N'vi-VN'` và thay `fn_get_field_group` → `fn_get_field_group_lang`

### 3. Cập nhật stored procedures *_set (1 file)
- `sp_res_apartment_set` - ✅

## ⏳ Còn lại (Ước tính 6-8 files)

Các stored procedures còn lại sử dụng `fn_get_field_group` cần cập nhật:
- `sp_res_report_list`
- `sp_bzz_report_list`
- `sp_Crm_Group_fields`
- `sp_Crm_Template_fields`
- `sp_Crm_Policy_Card_Fields`
- Và một số stored procedures khác (CRM module, draft procedures)

## 📊 Thống kê

- **Tổng số files đã cập nhật**: ~27 stored procedures
- **Tổng số files còn lại**: ~6-8 stored procedures
- **Tiến độ**: ~75-80% hoàn thành

## 🔍 Query kiểm tra còn lại

```sql
-- Tìm stored procedures còn sử dụng fn_get_field_group (chưa cập nhật)
SELECT 
    OBJECT_NAME(object_id) AS ProcedureName,
    'fn_get_field_group → fn_get_field_group_lang' AS NeedUpdate
FROM sys.sql_modules
WHERE definition LIKE '%fn_get_field_group(%'
  AND definition NOT LIKE '%fn_get_field_group_lang%'
ORDER BY OBJECT_NAME(object_id);

-- Tìm stored procedures còn sử dụng fn_config_list_gets
SELECT 
    OBJECT_NAME(object_id) AS ProcedureName,
    'fn_config_list_gets → fn_config_list_gets_lang' AS NeedUpdate
FROM sys.sql_modules
WHERE definition LIKE '%fn_config_list_gets(%'
  AND definition NOT LIKE '%fn_config_list_gets_lang%'
ORDER BY OBJECT_NAME(object_id);

-- Tìm stored procedures còn sử dụng fn_config_data_gets
SELECT 
    OBJECT_NAME(object_id) AS ProcedureName,
    'fn_config_data_gets → fn_config_data_gets_lang' AS NeedUpdate
FROM sys.sql_modules
WHERE definition LIKE '%fn_config_data_gets(%'
  AND definition NOT LIKE '%fn_config_data_gets_lang%'
ORDER BY OBJECT_NAME(object_id);
```

## 📝 Hướng dẫn cập nhật các file còn lại

### Pattern 1: Thêm @acceptLanguage (nếu thiếu)
```sql
CREATE PROCEDURE [dbo].[sp_xxx]
    @param1 ...,
    @acceptLanguage NVARCHAR(50) = N'vi-VN'  -- THÊM DÒNG NÀY
AS
```

### Pattern 2: Thay fn_get_field_group
```sql
-- TRƯỚC:
SELECT * FROM fn_get_field_group(@groupKey)

-- SAU:
SELECT * FROM fn_get_field_group_lang(@groupKey, @acceptLanguage)
```

### Pattern 3: Thay fn_config_list_gets
```sql
-- TRƯỚC:
SELECT * FROM fn_config_list_gets(@GridKey, 0)

-- SAU:
SELECT * FROM fn_config_list_gets_lang(@GridKey, 0, @acceptLanguage)
```

### Pattern 4: Thay fn_config_data_gets
```sql
-- TRƯỚC:
SELECT * FROM fn_config_data_gets(@fieldObject)

-- SAU:
SELECT * FROM fn_config_data_gets_lang(@fieldObject, @acceptLanguage)
```

## ✅ Hoàn thành

Để hoàn thành 100%, cần:
1. Chạy query kiểm tra ở trên để lấy danh sách chính xác
2. Cập nhật 6-8 stored procedures còn lại theo pattern
3. Test các stored procedures đã cập nhật
4. Deploy lên database

## 📚 Tài liệu liên quan

- `04_Update_StoredProcedures_Multilanguage.sql` - Hướng dẫn migration
- `05_Find_StoredProcedures_Need_Update.sql` - Query tìm stored procedures
- `06_Update_fn_get_field_group_To_Lang.sql` - Pattern cập nhật fn_get_field_group
- `07_Batch_Update_fn_get_field_group.sql` - Checklist cập nhật
