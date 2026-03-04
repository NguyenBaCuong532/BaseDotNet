
-- =============================================
-- Function: fn_get_message_lang
-- Description: Retrieves localized message text with fallback to default (Vietnamese)
-- Parameters:
--   @messageCode: Message key (e.g., 'error.general', 'label.estimated')
--   @acceptLanguage: Language code (e.g., 'vi-VN', 'en-US', 'zh-CN')
-- Returns: Localized message text, or default text, or message code if not found
-- =============================================
CREATE   FUNCTION [dbo].[fn_get_message_lang](
    @messageCode NVARCHAR(100),
    @acceptLanguage NVARCHAR(50) = N'vi-VN'
)
RETURNS NVARCHAR(250)
AS
BEGIN
    DECLARE @message NVARCHAR(250);
    DECLARE @messageId BIGINT;
    
    -- Get message ID and default text (Vietnamese)
    SELECT @messageId = id, @message = messages
    FROM sys_config_message
    WHERE code = @messageCode;
    
    -- If message exists, try to get translation
    IF @messageId IS NOT NULL
    BEGIN
        -- Try to get translation for requested language
        SELECT @message = COALESCE(
            (SELECT TOP 1 messages 
             FROM sys_config_message_lang 
             WHERE id = @messageId 
               AND langkey = @acceptLanguage),
            @message  -- Fallback to default message (Vietnamese)
        );
    END
    
    -- Return message or the code itself if not found (helpful for debugging)
    RETURN ISNULL(@message, @messageCode);
END;