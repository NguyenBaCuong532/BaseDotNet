# Tổng kết cập nhật sys_config_form → fn_config_form_gets

## ✅ Đã hoàn thành cập nhật

### Các stored procedures đã cập nhật:
1. `sp_res_apartment_merge_member_field_draft` - ✅
2. `sp_res_apartment_profile_receipt_field` - ✅
3. `sp_res_apartment_family_member_field_draft` - ✅
4. `sp_res_apartment_fee_field_draft` - ✅
5. `sp_res_card_guest_draft` - ✅
6. `sp_res_card_internal_field` - ✅
7. `sp_res_card_vehicle_field_draft` - ✅
8. `sp_res_employee_field_1` - ✅
9. `sp_res_notify_temp_fields` - ✅
10. `sp_res_request_field` - ✅

## 📝 Pattern cập nhật

### Pattern 1: Thay FROM sys_config_form
```sql
-- TRƯỚC:
FROM sys_config_form s
WHERE s.table_name = 'TableName'
  AND (s.isVisiable = 1 OR s.isRequire = 1)

-- SAU:
FROM fn_config_form_gets('TableName', @acceptLanguage) s
--WHERE (s.isVisiable = 1 OR s.isRequire = 1)
```

### Pattern 2: Thay SELECT từ sys_config_form
```sql
-- TRƯỚC:
SELECT columnTooltip
FROM sys_config_form
WHERE table_name = 'TableName' AND field_name = 'FieldName'

-- SAU:
SELECT columnTooltip
FROM fn_config_form_gets('TableName', @acceptLanguage)
WHERE field_name = 'FieldName'
```

## ⏳ Còn lại

Các stored procedures còn sử dụng `sys_config_form` trực tiếp (ước tính ~100+ files):
- `sp_res_apartment_family_member_field.sql`
- `sp_res_card_guest_field.sql`
- `sp_res_vehicle_payment_fields.sql`
- `sp_Crm_Group_fields.sql`
- Và nhiều stored procedures khác...

## 🔍 Query kiểm tra còn lại

```sql
-- Tìm stored procedures còn sử dụng sys_config_form trực tiếp
SELECT 
    OBJECT_NAME(object_id) AS ProcedureName,
    'sys_config_form → fn_config_form_gets' AS NeedUpdate
FROM sys.sql_modules
WHERE (definition LIKE '%FROM sys_config_form%'
   OR definition LIKE '%from sys_config_form%'
   OR definition LIKE '%FROM [sys_config_form]%'
   ) and OBJECT_NAME(object_id) like 'sp_res_%'
ORDER BY OBJECT_NAME(object_id);
```

## 📚 Lưu ý

1. **Đảm bảo có @acceptLanguage**: Tất cả stored procedures cần có parameter `@acceptLanguage NVARCHAR(50) = N'vi-VN'`

2. **Xóa WHERE table_name**: Khi dùng `fn_config_form_gets`, không cần filter `WHERE table_name = '...'` vì function đã filter sẵn

3. **Xóa WHERE isVisiable/isRequire**: Function `fn_config_form_gets` đã filter sẵn `(isvisiable = 1 OR isRequire = 1)`

4. **Giữ nguyên alias**: Nếu có alias `s`, `a`, v.v. thì giữ nguyên
