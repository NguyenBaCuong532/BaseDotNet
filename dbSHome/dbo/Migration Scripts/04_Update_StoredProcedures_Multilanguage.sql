-- =============================================
-- Script: Cập nhật Stored Procedures để hỗ trợ đa ngôn ngữ
-- Mô tả: 
--   1. Thêm @acceptLanguage NVARCHAR(50) = N'vi-VN' vào tất cả stored procedures
--   2. Thay fn_config_list_gets → fn_config_list_gets_lang trong các *_page procedures
--   3. Thay fn_config_data_gets → fn_config_data_gets_lang
--   4. fn_config_form_gets đã hỗ trợ @acceptLanguage, giữ nguyên
-- Author: System
-- Created: 2025-01-29
-- =============================================

-- Lưu ý: Script này chỉ là hướng dẫn. Cần chạy từng stored procedure một để đảm bảo không có lỗi.

-- =============================================
-- 1. Tìm tất cả stored procedures cần cập nhật
-- =============================================

-- Tìm các stored procedures sử dụng fn_config_list_gets (cần thay thành fn_config_list_gets_lang)
SELECT 
    OBJECT_NAME(object_id) AS ProcedureName,
    'fn_config_list_gets' AS FunctionToReplace,
    'fn_config_list_gets_lang' AS ReplaceWith
FROM sys.sql_modules
WHERE definition LIKE '%fn_config_list_gets(%'
  AND definition NOT LIKE '%fn_config_list_gets_lang%'
ORDER BY OBJECT_NAME(object_id);

-- Tìm các stored procedures sử dụng fn_config_data_gets (cần thay thành fn_config_data_gets_lang)
SELECT 
    OBJECT_NAME(object_id) AS ProcedureName,
    'fn_config_data_gets' AS FunctionToReplace,
    'fn_config_data_gets_lang' AS ReplaceWith
FROM sys.sql_modules
WHERE definition LIKE '%fn_config_data_gets(%'
  AND definition NOT LIKE '%fn_config_data_gets_lang%'
ORDER BY OBJECT_NAME(object_id);

-- Tìm các stored procedures chưa có @acceptLanguage
SELECT 
    OBJECT_NAME(object_id) AS ProcedureName
FROM sys.sql_modules
WHERE definition NOT LIKE '%@acceptLanguage%'
  AND (definition LIKE '%fn_config_list_gets%' 
       OR definition LIKE '%fn_config_data_gets%'
       OR definition LIKE '%fn_config_form_gets%')
ORDER BY OBJECT_NAME(object_id);

-- =============================================
-- 2. Pattern để cập nhật
-- =============================================

-- Pattern 1: Thêm @acceptLanguage vào parameters
-- Tìm: CREATE PROCEDURE [dbo].[sp_xxx]
--      @param1 ...
-- Thêm: ,@acceptLanguage NVARCHAR(50) = N'vi-VN'

-- Pattern 2: Thay fn_config_list_gets(@GridKey, 0)
-- Thành: fn_config_list_gets_lang(@GridKey, 0, @acceptLanguage)

-- Pattern 3: Thay fn_config_data_gets(@fieldObject)
-- Thành: fn_config_data_gets_lang(@fieldObject, @acceptLanguage)

-- Pattern 4: fn_config_form_gets đã hỗ trợ @acceptLanguage, giữ nguyên
-- Nhưng đảm bảo có truyền @acceptLanguage vào

-- =============================================
-- 3. Ví dụ cập nhật
-- =============================================

/*
-- Ví dụ: sp_res_apartment_page
-- TRƯỚC:
CREATE procedure [dbo].[sp_res_apartment_page]
	@userId nvarchar(450),
	@clientId nvarchar(50) = null,
	...
	SELECT * FROM [dbo].fn_config_list_gets(@GridKey, 0)

-- SAU:
CREATE procedure [dbo].[sp_res_apartment_page]
	@userId nvarchar(450),
	@clientId nvarchar(50) = null,
	@acceptLanguage NVARCHAR(50) = N'vi-VN',
	...
	SELECT * FROM [dbo].fn_config_list_gets_lang(@GridKey, 0, @acceptLanguage)
*/

-- =============================================
-- 4. Checklist
-- =============================================
/*
- [ ] sp_res_apartment_page - ✅ Đã cập nhật
- [ ] sp_res_building_page - ✅ Đã cập nhật
- [ ] sp_res_elevator_floor_page - ✅ Đã cập nhật
- [ ] sp_res_apartment_field - ✅ Đã có @acceptLanguage
- [ ] sp_res_apartment_set - ✅ Đã có @acceptLanguage
- [ ] Các stored procedures *_page khác
- [ ] Các stored procedures sử dụng fn_config_data_gets
*/
