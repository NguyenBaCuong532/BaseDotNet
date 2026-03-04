-- =============================================
-- User-Defined Table Type: NotifySentImportType
-- Mô tả: Type cho import danh sách gửi thông báo
-- Author: System
-- Created: 2025-01-27
-- =============================================

CREATE TYPE [dbo].[NotifySentImportType] AS TABLE (
    [STT]            INT            NULL,              -- Số thứ tự
    [FullName]       NVARCHAR (250) NULL,              -- FullName - Họ tên đầy đủ
    [Phone]          NVARCHAR (100) NULL,              -- Phone - Số điện thoại
    [Email]          NVARCHAR (200) NULL,              -- Email - Địa chỉ email
    [Room]           NVARCHAR (50)  NULL,              -- Room - Mã căn hộ
    [Errors]         NVARCHAR (500) NULL               -- Errors - Lỗi validation
);

