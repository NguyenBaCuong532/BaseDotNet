-- =============================================
-- Script: Tìm tất cả Stored Procedures cần cập nhật cho đa ngôn ngữ
-- Mô tả: Liệt kê các stored procedures cần:
--   1. Thêm @acceptLanguage parameter
--   2. Thay fn_config_list_gets → fn_config_list_gets_lang
--   3. Thay fn_config_data_gets → fn_config_data_gets_lang
-- Author: System
-- Created: 2025-01-29
-- =============================================

-- =============================================
-- 1. Tìm các stored procedures *_page sử dụng fn_config_list_gets
-- =============================================
SELECT 
    OBJECT_NAME(object_id) AS ProcedureName,
    'PAGE' AS ProcedureType,
    'fn_config_list_gets' AS FunctionToReplace,
    'fn_config_list_gets_lang' AS ReplaceWith,
    CASE 
        WHEN definition LIKE '%@acceptLanguage%' THEN 'Có @acceptLanguage'
        ELSE 'THIẾU @acceptLanguage'
    END AS Status
FROM sys.sql_modules
WHERE definition LIKE '%fn_config_list_gets(%'
  AND definition NOT LIKE '%fn_config_list_gets_lang%'
  AND OBJECT_NAME(object_id) LIKE '%_page'
ORDER BY Status DESC, OBJECT_NAME(object_id);

-- =============================================
-- 2. Tìm các stored procedures sử dụng fn_config_data_gets
-- =============================================
SELECT 
    OBJECT_NAME(object_id) AS ProcedureName,
    'DATA' AS ProcedureType,
    'fn_config_data_gets' AS FunctionToReplace,
    'fn_config_data_gets_lang' AS ReplaceWith,
    CASE 
        WHEN definition LIKE '%@acceptLanguage%' THEN 'Có @acceptLanguage'
        ELSE 'THIẾU @acceptLanguage'
    END AS Status
FROM sys.sql_modules
WHERE definition LIKE '%fn_config_data_gets(%'
  AND definition NOT LIKE '%fn_config_data_gets_lang%'
ORDER BY Status DESC, OBJECT_NAME(object_id);

-- =============================================
-- 3. Tìm các stored procedures *_field sử dụng fn_config_form_gets
-- =============================================
SELECT 
    OBJECT_NAME(object_id) AS ProcedureName,
    'FIELD' AS ProcedureType,
    'fn_config_form_gets' AS FunctionToReplace,
    'fn_config_form_gets (giữ nguyên, đã hỗ trợ @acceptLanguage)' AS ReplaceWith,
    CASE 
        WHEN definition LIKE '%@acceptLanguage%' THEN 'Có @acceptLanguage'
        ELSE 'THIẾU @acceptLanguage'
    END AS Status
FROM sys.sql_modules
WHERE definition LIKE '%fn_config_form_gets(%'
  AND (OBJECT_NAME(object_id) LIKE '%_field' OR OBJECT_NAME(object_id) LIKE '%_fields')
ORDER BY Status DESC, OBJECT_NAME(object_id);

-- =============================================
-- 4. Tổng hợp: Tất cả stored procedures cần thêm @acceptLanguage
-- =============================================
SELECT DISTINCT
    OBJECT_NAME(object_id) AS ProcedureName,
    CASE 
        WHEN OBJECT_NAME(object_id) LIKE '%_page' THEN 'PAGE'
        WHEN OBJECT_NAME(object_id) LIKE '%_field' OR OBJECT_NAME(object_id) LIKE '%_fields' THEN 'FIELD'
        ELSE 'OTHER'
    END AS ProcedureType,
    CASE 
        WHEN definition LIKE '%fn_config_list_gets%' THEN 'Sử dụng fn_config_list_gets'
        WHEN definition LIKE '%fn_config_data_gets%' THEN 'Sử dụng fn_config_data_gets'
        WHEN definition LIKE '%fn_config_form_gets%' THEN 'Sử dụng fn_config_form_gets'
        ELSE 'Khác'
    END AS FunctionUsed
FROM sys.sql_modules
WHERE (definition LIKE '%fn_config_list_gets%' 
       OR definition LIKE '%fn_config_data_gets%'
       OR definition LIKE '%fn_config_form_gets%')
  AND definition NOT LIKE '%@acceptLanguage%'
ORDER BY ProcedureType, OBJECT_NAME(object_id);

-- =============================================
-- 5. Tìm các stored procedures có tên *_fields (cần đổi thành *_field)
-- =============================================
SELECT 
    OBJECT_NAME(object_id) AS ProcedureName,
    'Cần đổi tên: ' + OBJECT_NAME(object_id) + ' → ' + REPLACE(OBJECT_NAME(object_id), '_fields', '_field') AS RenameTo
FROM sys.sql_modules
WHERE OBJECT_NAME(object_id) LIKE '%_fields'
  AND OBJECT_NAME(object_id) NOT LIKE '%_fields_%' -- Loại trừ các tên như sp_xxx_fields_1
ORDER BY OBJECT_NAME(object_id);

-- =============================================
-- 6. Script mẫu để cập nhật một stored procedure
-- =============================================
/*
-- Ví dụ: Cập nhật sp_res_xxx_page

-- Bước 1: Thêm @acceptLanguage vào parameters
ALTER PROCEDURE [dbo].[sp_res_xxx_page]
    @userId NVARCHAR(450),
    @acceptLanguage NVARCHAR(50) = N'vi-VN', -- THÊM DÒNG NÀY
    @filter NVARCHAR(100) = '',
    ...

-- Bước 2: Thay fn_config_list_gets
-- TRƯỚC:
SELECT * FROM [dbo].fn_config_list_gets(@GridKey, 0)

-- SAU:
SELECT * FROM [dbo].fn_config_list_gets_lang(@GridKey, 0, @acceptLanguage)

-- Bước 3: Thay fn_config_data_gets (nếu có)
-- TRƯỚC:
SELECT * FROM [dbo].fn_config_data_gets(@fieldObject)

-- SAU:
SELECT * FROM [dbo].fn_config_data_gets_lang(@fieldObject, @acceptLanguage)
*/
