
CREATE PROCEDURE [dbo].[sp_res_build_notify_content]
    @formula NVARCHAR(MAX) = NULL,
    @sourceId UNIQUEIDENTIFIER,               -- dùng GUID, khớp với entryId
    @projectCd NVARCHAR(30) = NULL,
    @additionalData NVARCHAR(MAX) = NULL,     -- JSON bổ sung
    @subject NVARCHAR(300) OUTPUT,
    @content_email NVARCHAR(MAX) OUTPUT,
    @content_sms NVARCHAR(1000) OUTPUT,
    @content_notify NVARCHAR(300) OUTPUT
AS
BEGIN TRY
    SET NOCOUNT ON;
    
    DECLARE @formulaId UNIQUEIDENTIFIER;
    DECLARE @subjectTemplate NVARCHAR(300);
    DECLARE @emailTemplate NVARCHAR(MAX);
    DECLARE @smsTemplate NVARCHAR(1000);
    DECLARE @notifyTemplate NVARCHAR(300);
    DECLARE @dataJson NVARCHAR(MAX);
    DECLARE @mergedJson NVARCHAR(MAX);
    
    IF (@formula IS NULL OR @formula = '')
    BEGIN
        -- Không có formula, trả về template gốc
        SET @subject        = @subjectTemplate;
        SET @content_email  = @emailTemplate;
        SET @content_sms    = @smsTemplate;
        SET @content_notify = @notifyTemplate;
        RETURN;
    END;
    
    -- Lấy dữ liệu từ formula (sourceId chuyển sang chuỗi để nhúng vào formula)
    DECLARE @sourceIdStr NVARCHAR(36);
    SET @sourceIdStr = CONVERT(NVARCHAR(36), @sourceId);


    EXEC [dbo].[sp_res_get_notify_data_by_formula] 
        @formula  = @formula,
        @sourceId   = @sourceIdStr,
        @projectCd  = @projectCd,
        @resultJson = @dataJson OUTPUT;
    
    -- Merge với additional data nếu có
    IF @additionalData IS NOT NULL AND LTRIM(RTRIM(@additionalData)) <> ''
    BEGIN
        IF @dataJson IS NULL OR @dataJson = '[]'
            SET @mergedJson = @additionalData;
        ELSE
            SET @mergedJson = LEFT(@dataJson, LEN(@dataJson) - 1) 
                              + ',' 
                              + SUBSTRING(@additionalData, 2, LEN(@additionalData));
    END
    ELSE
        SET @mergedJson = @dataJson;
    
    -- Thay thế placeholders trong các template
    SET @subject        = [dbo].[fn_replace_placeholders](@subject, @mergedJson);
    SET @content_email  = [dbo].[fn_replace_placeholders](@content_email,   @mergedJson);
    SET @content_sms    = [dbo].[fn_replace_placeholders](@content_sms,     @mergedJson);
    SET @content_notify = [dbo].[fn_replace_placeholders](@content_notify,  @mergedJson);

END TRY

BEGIN CATCH
    DECLARE @ErrorNum INT = ERROR_NUMBER(),
            @ErrorMsg VARCHAR(200) = 'sp_res_notify_build_content: ' + ERROR_MESSAGE(),
            @ErrorProc VARCHAR(50) = ERROR_PROCEDURE(),
            @SessionID INT,
            @AddlInfo VARCHAR(MAX) = '';

    EXEC utl_ErrorLog_Set @ErrorNum, @ErrorMsg, @ErrorProc, 'NotifySent', 'Build', @SessionID, @AddlInfo;
END CATCH