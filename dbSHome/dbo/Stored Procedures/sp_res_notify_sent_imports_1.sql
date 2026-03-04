-- =============================================
-- Stored Procedure: sp_res_notify_sent_imports
-- Mô tả: Import danh sách gửi thông báo (Validate hoặc Save)
-- Author: System
-- Created: 2025-01-27
-- =============================================

CREATE   procedure [dbo].[sp_res_notify_sent_imports]
    @data NotifySentImportType READONLY,
    @n_id UNIQUEIDENTIFIER,
    @accept bit = NULL,
    --@accept_int BIT = NULL,
    @userId NVARCHAR(100) = NULL,
    @impId UNIQUEIDENTIFIER = NULL,
    @fileName NVARCHAR(250) = NULL,
    @fileType NVARCHAR(50) = NULL,
    @fileSize INT = NULL,
    @fileUrl NVARCHAR(4000) = NULL,
    @acceptLanguage NVARCHAR(50) = N'vi-VN'
AS
BEGIN TRY
    SET NOCOUNT ON;

    DECLARE @recordsTotal INT = 0;
    DECLARE @recordsAccepted INT = 0;
    DECLARE @recordsFail INT = 0;
    DECLARE @messages NVARCHAR(MAX) = '';
    DECLARE @valid BIT = 1;

    -- Convert @accept string to bit
    SET @accept = ISNULL(@accept,0);

    -- Kiểm tra n_id có tồn tại trong NotifyInbox không
    IF NOT EXISTS (SELECT 1 FROM NotifyInbox WHERE n_id = @n_id)
    BEGIN
        SET @valid = 0;
        SET @messages = N'Mã thông báo không tồn tại.';
        SET @recordsTotal = (SELECT COUNT(*) FROM @data);
        SET @recordsFail = @recordsTotal;
        SET @recordsAccepted = 0;
        
        -- Return kết quả
        SELECT @valid as valid,
               @messages as messages,
               'view_notify_sent_import_page' as GridKey,
               recordsTotal = @recordsTotal,
               recordsFail = @recordsFail,
               recordsAccepted = @recordsAccepted,
               accept = 0;

        SELECT * FROM dbo.fn_config_list_gets_lang('view_notify_sent_import_page', 500, @acceptLanguage);

        SELECT STT, FullName, Phone, Email, Room,
               N'<span class="bg-danger noti-number ml5">Mã thông báo không tồn tại</span>' as errors
        FROM @data;

        SELECT impId = @impId, fileName = @fileName, fileType = @fileType, 
               fileSize = @fileSize, fileUrl = @fileUrl;
        RETURN;
    END

    -- Tạo temp table để validate
    IF OBJECT_ID('tempdb..#temp') IS NOT NULL
        DROP TABLE #temp;

    -- Load dữ liệu từ TVP vào #temp + kiểm tra lỗi cơ bản
    SELECT a.STT,a.FullName,a.Phone,a.Email,a.Room,
        CASE 
            -- Validate FullName (bắt buộc)
            WHEN ISNULL(FullName,'') = '' THEN N'; Họ tên không được để trống'
            -- Validate Email format (nếu có)
            WHEN Email IS NOT NULL AND Email != '' 
                AND Email NOT LIKE '%@%.%' 
                THEN N'; Email không đúng định dạng'
            -- Validate Phone (nếu có)
            WHEN Phone IS NOT NULL AND Phone != '' 
                AND LEN(Phone) < 10 
                THEN N'; Số điện thoại phải có ít nhất 10 ký tự'
            ELSE '' 
        END errors
    INTO #temp
    FROM @data a;

    -- Lưu file import vào ImportFiles (nếu chưa có)
    IF @impId IS NULL 
       OR NOT EXISTS (SELECT 1 FROM ImportFiles WHERE impId = @impId)
       AND @fileName IS NOT NULL
    BEGIN
        SET @impId = NEWID();

        INSERT INTO ImportFiles (
            impId, import_type, upload_file_name, upload_file_type, upload_file_url, 
            upload_file_size, created_by, created_dt, row_count
        )
        VALUES (
            @impId, 'notifySent', @fileName, @fileType, @fileUrl, 
            @fileSize, @userId, GETDATE(), (SELECT COUNT(*) FROM #temp)
        );
    END

    -- Nếu xác nhận import (accept_int = 1)
    IF @accept = 1
    BEGIN
        BEGIN TRAN

            UPDATE [dbo].[ImportFiles]
               SET row_new = 0,
                   row_update = (SELECT COUNT(*) FROM #temp WHERE errors = ''),
                   row_fail = (SELECT COUNT(*) FROM #temp WHERE errors != ''),
                   updated_st = 1,
                   updated_by = @userId,
                   updated_dt = GETDATE()
             WHERE impId = @impId;

            -- Insert dữ liệu mới
            INSERT INTO NotifySent (
                n_id,
                email,
                phone,
                fullName,
                room,
                push_st,
                sms_st,
                email_st,
                createId,
                createDt
            )
            SELECT 
                @n_id,
                t.Email,
                t.Phone,
                t.FullName,
                t.Room,
                0,  -- push_st: chưa gửi
                0,  -- sms_st: chưa gửi
                0,  -- email_st: chưa gửi
                @userId,
                GETDATE()
            FROM #temp t
            WHERE t.errors = '';  -- Chỉ insert các dòng không có lỗi

        COMMIT
    END

    SET @recordsAccepted = (SELECT COUNT(*) FROM #temp WHERE ISNULL(errors,'') = '');
    SET @recordsTotal = (SELECT COUNT(*) FROM #temp);
    SET @recordsFail = @recordsTotal - @recordsAccepted;

    IF @recordsFail > 0
    BEGIN
        SET @valid = 0;
        SET @messages = N'Có ' + CAST(@recordsFail AS NVARCHAR(10)) + N' dòng dữ liệu không hợp lệ.';
    END
    ELSE IF @recordsAccepted > 0 AND @accept = 1
    BEGIN
        SET @messages = N'Đã lưu thành công ' + CAST(@recordsAccepted AS NVARCHAR(10)) + N' bản ghi.';
    END
    ELSE IF @recordsAccepted > 0
    BEGIN
        SET @messages = N'Dữ liệu hợp lệ. Có thể lưu.';
    END

END TRY
BEGIN CATCH
    IF @@TRANCOUNT > 0
        ROLLBACK TRAN;

    DECLARE @ErrorNum INT, @ErrorMsg VARCHAR(200), @ErrorProc VARCHAR(50), 
            @SessionID INT, @AddlInfo VARCHAR(MAX);

    SET @ErrorNum = ERROR_NUMBER();
    SET @ErrorMsg = 'sp_res_notify_sent_imports ' + ERROR_MESSAGE();
    SET @ErrorProc = ERROR_PROCEDURE();
    SET @AddlInfo = ' ';

    EXEC utl_errorlog_set @ErrorNum, @ErrorMsg, @ErrorProc,
                          'notifySent', 'IMPORT', @SessionID, @AddlInfo;

    SET @valid = 0;
    SET @messages = N'Lỗi khi xử lý: ' + ERROR_MESSAGE();
    SET @recordsTotal = (SELECT COUNT(*) FROM @data);
    SET @recordsFail = @recordsTotal;
    SET @recordsAccepted = 0;
END CATCH;

    -- Trả về kết quả
    SELECT @valid as valid,
           @messages as messages,
           'view_notify_sent_import_page' as GridKey,
           recordsTotal = @recordsTotal,
           recordsFail = @recordsFail,
           recordsAccepted = CASE WHEN @accept = 1 THEN @recordsAccepted ELSE 0 END,
           accept = CASE WHEN @recordsAccepted > 0 THEN 1 ELSE 0 END;

    SELECT * FROM dbo.fn_config_list_gets_lang('view_notify_sent_import_page', 500, @acceptLanguage);

    SELECT STT, FullName, Phone, Email, Room,
           CASE 
               WHEN errors = '' THEN
                   CASE 
                       WHEN @valid = 1 AND @accept = 1 THEN N'<span class="bg-success noti-number ml5">Done</span>'
                       WHEN @valid = 0 AND @accept = 1 THEN N'<span class="bg-warning noti-number ml5">Error</span>'
                       ELSE N'<span class="bg-success noti-number ml5">OK</span>' 
                   END
               ELSE N'<span class="bg-danger noti-number ml5">' + STUFF(errors,1,2,'') + '</span>'
           END errors
    FROM #temp;

    SELECT impId = @impId, fileName = @fileName, fileType = @fileType, 
           fileSize = @fileSize, fileUrl = @fileUrl;