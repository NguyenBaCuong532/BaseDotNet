CREATE FUNCTION [dbo].[fn_get_fields_from_json] (@json NVARCHAR(MAX)
, @fields NVARCHAR(MAX) --để rỗng -> lấy tất cả
)
RETURNS TABLE
AS
RETURN (
        SELECT g.[key] AS group_index
            , f.[key] AS field_index
            , group_cd = JSON_VALUE(g.[value], '$.group_cd')
            , field_name = JSON_VALUE(f.[value], '$.field_name')
            , columnValue = JSON_VALUE(f.[value], '$.columnValue')
        FROM OPENJSON(@json, '$.group_fields') g
        CROSS APPLY OPENJSON(g.[value], '$.fields') f
        WHERE ISNULL(@fields,'') = '' OR JSON_VALUE(f.[value], '$.field_name') IN (SELECT [value] FROM string_split(@fields,','))
        )