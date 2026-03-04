-- =============================================
-- Stored Procedure: sp_res_notify_sent_imports_temp
-- Mô tả: Lấy template Excel để import danh sách gửi thông báo
-- Author: System
-- Created: 2025-01-27
-- =============================================

CREATE PROCEDURE [dbo].[sp_res_notify_sent_imports_temp]
    @userId NVARCHAR(100) = NULL
AS
BEGIN
    SET NOCOUNT ON;

    -- Return template structure with tiếng Việt column names
    SELECT 
        1 AS [STT],                           -- Số thứ tự
        N'Nguyễn Văn An' AS [Họ tên],        -- FullName
        N'0901234567' AS [Điện thoại],        -- Phone
        N'example@email.com' AS [Email],     -- Email
        N'A101' AS [Căn hộ]                   -- Room
    UNION ALL
    SELECT 
        NULL AS [STT],
        NULL AS [Họ tên],
        NULL AS [Điện thoại],
        NULL AS [Email],
        NULL AS [Căn hộ]
    WHERE 1 = 0;
END

