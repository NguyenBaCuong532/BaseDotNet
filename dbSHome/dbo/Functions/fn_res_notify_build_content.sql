CREATE   FUNCTION dbo.fn_res_notify_build_content
(
      @subjectTemplate       NVARCHAR(300)
    , @emailTemplate         NVARCHAR(MAX)
    , @smsTemplate           NVARCHAR(1000)
    , @notifyTemplate        NVARCHAR(300)
    , @dataJson              NVARCHAR(MAX)
)
RETURNS TABLE
AS
RETURN
(
    SELECT
        subject =
            dbo.fn_replace_placeholders(@subjectTemplate, @dataJson),

        content_email =
            dbo.fn_replace_placeholders(@emailTemplate, @dataJson),

        content_sms =
            dbo.fn_replace_placeholders(@smsTemplate, @dataJson),

        content_notify =
            dbo.fn_replace_placeholders(@notifyTemplate, @dataJson)
);