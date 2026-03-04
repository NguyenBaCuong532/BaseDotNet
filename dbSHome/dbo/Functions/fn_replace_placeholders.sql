CREATE FUNCTION [dbo].[fn_replace_placeholders]
(
    @template NVARCHAR(MAX),
    @placeholders NVARCHAR(MAX) 
    -- hỗ trợ:
    -- 1) {"fullName":"A","roomCode":"B"}
    -- 2) [{"key":"fullName","value":"A"}]
)
RETURNS NVARCHAR(MAX)
AS
BEGIN
    DECLARE @result NVARCHAR(MAX) = @template;

    IF @template IS NULL OR @placeholders IS NULL OR LTRIM(RTRIM(@placeholders)) = ''
        RETURN @result;

    -- Nếu là JSON array kiểu cũ: [{"key":"x","value":"y"}]
    IF LEFT(LTRIM(@placeholders),1) = '['
    BEGIN
        DECLARE @key NVARCHAR(200);
        DECLARE @value NVARCHAR(MAX);

        DECLARE placeholder_cursor CURSOR LOCAL FAST_FORWARD FOR
        SELECT [key], [value]
        FROM OPENJSON(@placeholders)
        WITH (
            [key] NVARCHAR(200) '$.key',
            [value] NVARCHAR(MAX) '$.value'
        );

        OPEN placeholder_cursor;
        FETCH NEXT FROM placeholder_cursor INTO @key, @value;

        WHILE @@FETCH_STATUS = 0
        BEGIN
            SET @result = REPLACE(@result, '{' + @key + '}', ISNULL(@value, ''));
            SET @result = REPLACE(@result, '{{' + @key + '}}', ISNULL(@value, ''));
            FETCH NEXT FROM placeholder_cursor INTO @key, @value;
        END

        CLOSE placeholder_cursor;
        DEALLOCATE placeholder_cursor;

        RETURN @result;
    END

    -- Nếu là JSON object: {"fullName":"A","roomCode":"B"}
    DECLARE @k NVARCHAR(200);
    DECLARE @v NVARCHAR(MAX);

    DECLARE obj_cursor CURSOR LOCAL FAST_FORWARD FOR
        SELECT [key], [value]
        FROM OPENJSON(@placeholders);

    OPEN obj_cursor;
    FETCH NEXT FROM obj_cursor INTO @k, @v;

    WHILE @@FETCH_STATUS = 0
    BEGIN
        SET @result = REPLACE(@result, '{' + @k + '}', ISNULL(@v, ''));
        SET @result = REPLACE(@result, '{{' + @k + '}}', ISNULL(@v, ''));
        FETCH NEXT FROM obj_cursor INTO @k, @v;
    END

    CLOSE obj_cursor;
    DEALLOCATE obj_cursor;

    RETURN @result;
END;