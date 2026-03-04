
CREATE FUNCTION [dbo].[fn_config_data_gets_lang] (
    @fieldObject NVARCHAR(50)
    , @acceptLanguage NVARCHAR(50) = 'vi'
    )
RETURNS @tbl TABLE (
    [objKey] NVARCHAR(50)
    , [objCode] NVARCHAR(50)
    , [objName] NVARCHAR(200)
    , [objGroup] NVARCHAR(50)
    , [objValue] NVARCHAR(100)
    , [objValue1] NVARCHAR(100)
    , [objValue2] INT
    , [intOrder] INT
    , [objClass] NVARCHAR(200)
    )
AS
BEGIN
    --
    INSERT INTO @tbl
    SELECT [key_1]
        , [key_2]
        , [par_desc] = COALESCE(l.par_desc, cc.par_desc)
        , [key_group]
        , CASE 
            WHEN [type_value] = 1
                THEN cast([value2] AS NVARCHAR(100))
            ELSE [value1]
            END objvalue
        , [value1]
        , [value2]
        , intOrder
        , [objClass] = N'<span class="' + [value1] + ' noti-number ml5">' +  COALESCE(l.par_desc, cc.par_desc) + '</span>'
    FROM sys_config_data cc
    LEFT JOIN sys_config_data_lang l ON cc.id = l.id AND l.langkey = @acceptLanguage
    WHERE [key_1] = @FieldObject
        AND [IsUsed] = 1

    RETURN
END