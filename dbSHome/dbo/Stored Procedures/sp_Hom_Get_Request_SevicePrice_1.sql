CREATE   PROCEDURE [dbo].[sp_Hom_Get_Request_SevicePrice]
    @UserId        nvarchar(450),
    @RequestTypeId int,
    @priceDate     nvarchar(20)
AS
BEGIN TRY
    SET NOCOUNT ON;

    DECLARE @Subject  nvarchar(100),
            @Contents nvarchar(max),
            @scont    nvarchar(max),
            @body     nvarchar(max);

    -- Tiêu đề
    SELECT TOP (1) @Subject = RequestTypeName
    FROM dbo.MAS_Request_Types
    WHERE RequestTypeId = @RequestTypeId;

    ;WITH src AS
    (
        SELECT ItemName, IsFree, Price, Unit, Note, Post
        FROM dbo.PAR_RequestTypePrice
        WHERE RequestTypeId = @RequestTypeId
    ),
    rows AS
    (
        SELECT
            N'<tr>' +
            N'<td>' + ISNULL(ItemName, N'') + N'</td>' +
            N'<td><b>' + FORMAT(Price, '#,##0') + N' ' + ISNULL(Unit, N'') + N'</b>' +
                CASE WHEN Note IS NULL OR Note = N'' THEN N'' ELSE N' (' + Note + N')' END +
            N'</td>' +
            N'</tr>' AS line,
            Post
        FROM src
    )
    SELECT @scont = STRING_AGG(line, N'') WITHIN GROUP (ORDER BY Post)
    FROM rows;

    -- Thân nội dung
    SET @body =
        N'<h1>S-SERVICES</h1>' +
        N'<h2>' + ISNULL(@Subject, N'') + N'</h2>' +
        N'<h3>Ngày cập nhật: ' + ISNULL(@priceDate, N'') + N'</h3>' +
        N'<hr />' +
        N'<div class="note">Dịch vụ đang vận hành thử nghiệm</div>' +
        N'<table>' +
        N'  <tbody>' +
        N'    <tr>' +
        N'      <th style="width:50%">' + N'Dịch vụ' + N'</th>' +
        N'      <th style="width:50%">' + N'Phí'     + N'</th>' +
        N'    </tr>' +
             ISNULL(@scont, N'') +
        N'  </tbody>' +
        N'</table>';

    -- Khung HTML
    SET @Contents = N'<!DOCTYPE html>
<html>
<head>
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <style type="text/css">
    body { margin:15px; font-family:arial; font-size:12pt; }
    h1 { color:#4118CD; margin:0; padding:10px 0 1px 0; }
    h2 { margin:0; padding:1px 0; font-weight:normal; font-size:14pt; }
    h3 { color:#ccc; margin:0; padding:1px 0; font-weight:normal; font-size:12pt; }
    img { max-width:100%; }
    hr { background:#ccc !important; color:#ccc !important; border:0; height:1px !important; }
    table { width:100%; border-collapse:collapse; }
    th, td { border:1px solid #ccc; padding:8px; }
    .note { font-style:italic; color:red; }
    </style>
</head>
<body>' + @body + N'</body></html>';

    SELECT
        @priceDate   AS priceDate,
        @Subject     AS RequestTypeName,
        @Contents    AS Contents;
END TRY
BEGIN CATCH
    DECLARE @ErrorNum  int          = ERROR_NUMBER(),
            @ErrorMsg  varchar(200) = ' ' + ERROR_MESSAGE(),
            @ErrorProc varchar(50)  = ERROR_PROCEDURE(),
            @SessionID int,
            @AddlInfo  varchar(max) = '';

    EXEC dbo.utl_Insert_ErrorLog @ErrorNum, @ErrorMsg, @ErrorProc, 'Mail', 'Get', @SessionID, @AddlInfo;
END CATCH;