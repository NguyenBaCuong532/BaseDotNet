CREATE FUNCTION [dbo].[fn_get_notify_subject]
(
    @myString NVARCHAR(MAX),
    @roomCode NVARCHAR(20) = NULL,
    @projectName NVARCHAR(100) = NULL,
    @electricMonth NVARCHAR(10) = NULL,
    @serviceMonth NVARCHAR(10) = NULL,
    @remindTime NVARCHAR(5) = NULL,
	@toDate       NVARCHAR(20) = NULL
)
RETURNS NVARCHAR(MAX)
AS
BEGIN
    DECLARE @content NVARCHAR(MAX) = ISNULL(@myString, '');

    IF @roomCode IS NOT NULL
        SET @content = REPLACE(@content, '{roomCode}', @roomCode);

    IF @projectName IS NOT NULL
        SET @content = REPLACE(@content, '{projectName}', @projectName);

    IF @electricMonth IS NOT NULL
        SET @content = REPLACE(@content, '{electricMonth}', @electricMonth);

    IF @serviceMonth IS NOT NULL
        SET @content = REPLACE(@content, '{serviceMonth}', @serviceMonth);

    IF @remindTime IS NOT NULL
        SET @content = REPLACE(@content, '{remindTime}', @remindTime);

	IF @toDate IS NOT NULL
        SET @content = REPLACE(@content, '{toDate}', @toDate);

    RETURN @content;
END