Create FUNCTION [dbo].[fn_get_notify_sms]
(
    @myString      NVARCHAR(MAX),
    @roomCode      NVARCHAR(20) = NULL,
    @projectName   NVARCHAR(100) = NULL,
    @remindTime    NVARCHAR(5) = NULL,
    @electricMonth NVARCHAR(10) = NULL,
    @serviceMonth  NVARCHAR(10) = NULL,
    @totalAmt      NVARCHAR(50) = NULL,
    @paidAmt       NVARCHAR(50) = NULL,
    @remainAmt     NVARCHAR(50) = NULL
)
RETURNS NVARCHAR(MAX)
AS
BEGIN
    DECLARE @content NVARCHAR(MAX) = ISNULL(@myString, '');

    -- Thay thế placeholder
    IF @roomCode IS NOT NULL
        SET @content = REPLACE(@content, '{roomCode}', @roomCode);

    IF @projectName IS NOT NULL
        SET @content = REPLACE(@content, '{projectName}', @projectName);

    IF @remindTime IS NOT NULL
        SET @content = REPLACE(@content, '{remindTime}', @remindTime);

    IF @electricMonth IS NOT NULL
        SET @content = REPLACE(@content, '{electricMonth}', @electricMonth);

    IF @serviceMonth IS NOT NULL
        SET @content = REPLACE(@content, '{serviceMonth}', @serviceMonth);

    IF @totalAmt IS NOT NULL
        SET @content = REPLACE(@content, '{totalAmt}', @totalAmt);

    IF @paidAmt IS NOT NULL
        SET @content = REPLACE(@content, '{paidAmt}', @paidAmt);

    IF @remainAmt IS NOT NULL
        SET @content = REPLACE(@content, '{remainAmt}', @remainAmt);

    RETURN @content;
END