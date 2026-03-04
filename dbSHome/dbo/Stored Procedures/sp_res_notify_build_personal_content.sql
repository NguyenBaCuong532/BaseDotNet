-- =============================================
-- Author:      System
-- Create date: 2026-01-13
-- Description: Build nội dung cá nhân hóa cho từng người nhận
--              Kiểm tra tempId → formulaId, nếu có thì replace placeholders
-- =============================================
CREATE PROCEDURE [dbo].[sp_res_notify_build_personal_content]
    @UserID NVARCHAR(450) = NULL,
    @n_id UNIQUEIDENTIFIER
AS
BEGIN TRY
    SET NOCOUNT ON;
    
    DECLARE @tempId UNIQUEIDENTIFIER;
    DECLARE @formulaId UNIQUEIDENTIFIER;
    DECLARE @projectCd NVARCHAR(5);
    DECLARE @formula NVARCHAR(MAX);
    
    -- Lấy tempId từ NotifyInbox
    SELECT @tempId = tempId 
    FROM NotifyInbox 
    WHERE n_id = @n_id;

    IF @tempId IS NULL 
        RETURN; -- Không có template → không cần replace
    
    -- Lấy formulaId từ NotifyTemplate
    SELECT @formulaId = t.formulaId,
           @projectCd = t.projectCd,
           @formula = f.formula
    FROM NotifyTemplate t
    JOIN NotifyFormula f ON t.formulaId = f.formulaId 
    WHERE tempId = @tempId;


    IF @formulaId IS NULL 
        RETURN; -- Không có formula → không cần replace
    
    -- Lấy nội dung template từ NotifyInbox
    DECLARE @subjectTemplate NVARCHAR(300);
    DECLARE @contentNotifyTemplate NVARCHAR(MAX);
    DECLARE @contentSmsTemplate NVARCHAR(1000);
    DECLARE @contentEmailTemplate NVARCHAR(MAX);
    
    SELECT 
        @subjectTemplate = [subject],
        @contentNotifyTemplate = content_notify,
        @contentSmsTemplate = content_sms,
        @contentEmailTemplate = content_email
    FROM NotifyInbox
    WHERE n_id = @n_id;
    
    DECLARE @sentId BIGINT;
    DECLARE @custId NVARCHAR(100);
    DECLARE @dataJson NVARCHAR(MAX);
    DECLARE @subjectPersonal NVARCHAR(300);
    DECLARE @contentNotifyPersonal NVARCHAR(MAX);
    DECLARE @contentSmsPersonal NVARCHAR(1000);
    DECLARE @contentEmailPersonal NVARCHAR(MAX);
    
    DECLARE sent_cursor CURSOR LOCAL FAST_FORWARD FOR
    SELECT id, custId
    FROM NotifySent
    WHERE n_id = @n_id;
    
    OPEN sent_cursor;
    FETCH NEXT FROM sent_cursor INTO @sentId, @custId;
    
    WHILE @@FETCH_STATUS = 0
    BEGIN
        -- Sử dụng custId làm key chính
        DECLARE @sourceId NVARCHAR(100) = @custId;
        
        IF @sourceId IS NOT NULL
        BEGIN
            EXEC [dbo].[sp_res_get_notify_data_by_formula] 
                @formula = @formula,
                @sourceId = @sourceId,
                @projectCd = @projectCd,
                @resultJson = @dataJson OUTPUT;

            -- Replace placeholders
            IF @dataJson IS NOT NULL AND @dataJson <> '[]'
            BEGIN
                SET @subjectPersonal = [dbo].[fn_replace_placeholders](@subjectTemplate, @dataJson);
                SET @contentNotifyPersonal = [dbo].[fn_replace_placeholders](@contentNotifyTemplate, @dataJson);
                SET @contentSmsPersonal = [dbo].[fn_replace_placeholders](@contentSmsTemplate, @dataJson);
                SET @contentEmailPersonal = [dbo].[fn_replace_placeholders](@contentEmailTemplate, @dataJson);

                -- Update NotifySent với nội dung đã cá nhân hóa
                UPDATE NotifySent
                SET [subject] = @subjectPersonal,
                    content_notify= @contentNotifyPersonal,
                    content_sms = @contentSmsPersonal,
                    content_email = @contentEmailPersonal
                WHERE id = @sentId;
            END
        END
        
        FETCH NEXT FROM sent_cursor INTO @sentId, @custId;
    END
    
    CLOSE sent_cursor;
    DEALLOCATE sent_cursor;
    
END TRY
BEGIN CATCH
    DECLARE @ErrorNum INT = ERROR_NUMBER(),
            @ErrorMsg VARCHAR(200) = 'sp_res_notify_build_personal_content: ' + ERROR_MESSAGE(),
            @ErrorProc VARCHAR(50) = ERROR_PROCEDURE(),
            @SessionID INT,
            @AddlInfo VARCHAR(MAX) = '@n_id: ' + CAST(@n_id AS VARCHAR(50));

    EXEC utl_ErrorLog_Set @ErrorNum, @ErrorMsg, @ErrorProc, 'NotifySent', 'Build', @SessionID, @AddlInfo;
END CATCH