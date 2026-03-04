-- =============================================
-- Script: Gen Config Data cho view_notify_sent_import_page
-- Mô tả: Tạo config grid cho trang import danh sách gửi thông báo
-- Author: System
-- Created: 2025-01-27
-- =============================================

-- Sử dụng MERGE để insert hoặc update config
MERGE [dbo].[sys_config_list] AS target
USING (
    VALUES
        -- STT - Số thứ tự
        ('view_notify_sent_import_page', 1, 'STT', N'STT', 'STT', 60, 'int', 'number', NULL, NULL, NULL, 1, 1, 0, 0, 0, 0),
        
        -- FullName - Họ tên
        ('view_notify_sent_import_page', 1, 'FullName', N'Họ tên', 'Full Name', 200, 'nvarchar', 'text', NULL, NULL, NULL, 2, 1, 0, 0, 0, 1),
        
        -- Phone - Số điện thoại
        ('view_notify_sent_import_page', 1, 'Phone', N'Điện thoại', 'Phone', 120, 'nvarchar', 'text', NULL, NULL, NULL, 3, 1, 0, 0, 0, 1),
        
        -- Email - Email
        ('view_notify_sent_import_page', 1, 'Email', N'Email', 'Email', 200, 'nvarchar', 'text', NULL, NULL, NULL, 4, 1, 0, 0, 0, 1),
        
        -- Room - Căn hộ
        ('view_notify_sent_import_page', 1, 'Room', N'Căn hộ', 'Room', 100, 'nvarchar', 'text', NULL, NULL, NULL, 5, 1, 0, 0, 0, 1),
        
        -- Errors - Lỗi validation
        ('view_notify_sent_import_page', 1, 'Errors', N'Lỗi', 'Errors', 300, 'nvarchar', 'html', NULL, NULL, NULL, 6, 1, 0, 0, 1, 0)
) AS source (
    [view_grid], [view_type], [columnField], [columnCaption], [columnCaptionE],
    [columnWidth], [data_type], [fieldType], [cellClass], [conditionClass],
    [pinned], [ordinal], [isUsed], [isHide], [isMasterDetail], [isStatusLable], [isFilter]
)
ON target.[view_grid] = source.[view_grid]
   AND target.[view_type] = source.[view_type]
   AND target.[columnField] = source.[columnField]
WHEN MATCHED THEN
    UPDATE SET
        [columnCaption] = source.[columnCaption],
        [columnCaptionE] = source.[columnCaptionE],
        [columnWidth] = source.[columnWidth],
        [data_type] = source.[data_type],
        [fieldType] = source.[fieldType],
        [cellClass] = source.[cellClass],
        [conditionClass] = source.[conditionClass],
        [pinned] = source.[pinned],
        [ordinal] = source.[ordinal],
        [isUsed] = source.[isUsed],
        [isHide] = source.[isHide],
        [isMasterDetail] = source.[isMasterDetail],
        [isStatusLable] = source.[isStatusLable],
        [isFilter] = source.[isFilter]
WHEN NOT MATCHED THEN
    INSERT (
        [view_grid], [view_type], [columnField], [columnCaption], [columnCaptionE],
        [columnWidth], [data_type], [fieldType], [cellClass], [conditionClass],
        [pinned], [ordinal], [isUsed], [isHide], [isMasterDetail], [isStatusLable], [isFilter]
    )
    VALUES (
        source.[view_grid], source.[view_type], source.[columnField], source.[columnCaption], source.[columnCaptionE],
        source.[columnWidth], source.[data_type], source.[fieldType], source.[cellClass], source.[conditionClass],
        source.[pinned], source.[ordinal], source.[isUsed], source.[isHide], source.[isMasterDetail], source.[isStatusLable], source.[isFilter]
    );

-- Kiểm tra kết quả
SELECT 
    id,
    view_grid,
    view_type,
    columnField,
    columnCaption,
    columnWidth,
    fieldType,
    ordinal,
    isUsed,
    isHide
FROM [dbo].[sys_config_list]
WHERE view_grid = 'view_notify_sent_import_page'
ORDER BY ordinal;

