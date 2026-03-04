
CREATE FUNCTION [dbo].[fn_get_notify_content]
(
    @myString NVARCHAR(MAX),
    @fullName NVARCHAR(250) = NULL,
    @roomCode NVARCHAR(20) = NULL,
    @projectName NVARCHAR(100) = NULL,
    @debitAmt DECIMAL(18,0) = NULL,
    @electricMonth NVARCHAR(10) = NULL,
    @waterMonth NVARCHAR(10) = NULL,
    @parkingMonth NVARCHAR(10) = NULL,
    @serviceMonth NVARCHAR(10) = NULL,
    @totalAmt DECIMAL(18,0) = NULL,
    @paidAmt DECIMAL(18,0) = NULL,
    @remainAmt DECIMAL(18,0) = NULL,
    @billUrl NVARCHAR(200) = NULL,
    @timeWorking NVARCHAR(100) = NULL,
    @bankName NVARCHAR(100) = NULL,
    @bankBranch NVARCHAR(100) = NULL,
    @bankAccNo NVARCHAR(50) = NULL,
    @bankAccName NVARCHAR(100) = NULL,

    -- Tham số bổ sung
    @dayOfNotice1 DATE = NULL,
    @dayOfNotice2 DATE = NULL,
    @dayOfNotice3 DATE = NULL,
    @stopDate DATETIME = NULL,
    @address NVARCHAR(200) = NULL,
    @electricYear NVARCHAR(10) = NULL
)
RETURNS NVARCHAR(MAX)
AS
BEGIN
    DECLARE @content NVARCHAR(MAX) = ISNULL(@myString, '');

    -- Replace placeholders
    SET @content = REPLACE(@content, '{fullName}', ISNULL(@fullName, ''));
    SET @content = REPLACE(@content, '{roomCode}', ISNULL(@roomCode, ''));
    SET @content = REPLACE(@content, '{projectName}', ISNULL(@projectName, ''));
    SET @content = REPLACE(@content, '{projectNameUpper}', ISNULL(UPPER(@projectName), ''));
    SET @content = REPLACE(@content, '{debitAmt}', ISNULL(FORMAT(@debitAmt,'###,###,###'), '0'));
    SET @content = REPLACE(@content, '{electricMonth}', ISNULL(@electricMonth, ''));
    SET @content = REPLACE(@content, '{waterMonth}', ISNULL(@waterMonth, ''));
    SET @content = REPLACE(@content, '{parkingMonth}', ISNULL(@parkingMonth, ''));
    SET @content = REPLACE(@content, '{serviceMonth}', ISNULL(@serviceMonth, ''));
    SET @content = REPLACE(@content, '{totalAmt}', ISNULL(FORMAT(@totalAmt,'###,###,###'), '0'));
    SET @content = REPLACE(@content, '{paidAmt}', ISNULL(FORMAT(@paidAmt,'###,###,###'), '0'));
    SET @content = REPLACE(@content, '{remainAmt}', ISNULL(FORMAT(@remainAmt,'###,###,###'), '0'));
    SET @content = REPLACE(@content, '{billUrl}', ISNULL(@billUrl, '#'));
    SET @content = REPLACE(@content, '{timeWorking}', ISNULL(@timeWorking, ''));
    SET @content = REPLACE(@content, '{bankName}', ISNULL(@bankName, ''));
    SET @content = REPLACE(@content, '{bankBranch}', ISNULL(@bankBranch, ''));
    SET @content = REPLACE(@content, '{bankAccNo}', ISNULL(@bankAccNo, ''));
    SET @content = REPLACE(@content, '{bankAccName}', ISNULL(@bankAccName, ''));

    -- Thay thế tham số bổ sung
    SET @content = REPLACE(@content, '{dayOfNotice1}', ISNULL(CONVERT(NVARCHAR(10), @dayOfNotice1, 103), ''));
    SET @content = REPLACE(@content, '{dayOfNotice2}', ISNULL(CONVERT(NVARCHAR(10), @dayOfNotice2, 103), ''));
    SET @content = REPLACE(@content, '{dayOfNotice3}', ISNULL(CONVERT(NVARCHAR(10), @dayOfNotice3, 103), ''));
    SET @content = REPLACE(@content, '{stopTime}', ISNULL(CONVERT(CHAR(5), @stopDate, 108), ''));
    SET @content = REPLACE(@content, '{stopDate}', ISNULL(CONVERT(NVARCHAR(10), @stopDate, 103), ''));
    SET @content = REPLACE(@content, '{address}', ISNULL(@address, ''));
    SET @content = REPLACE(@content, '{electricYear}', ISNULL(@electricYear, ''));

    RETURN @content;
END