
-- =============================================
-- Author:		<Author,,Name>
-- Create date: 2025-12-25
-- Description:	Lấy group đa ngôn ngữ
-- =============================================
CREATE FUNCTION [dbo].[fn_get_field_group_lang] (
    @form NVARCHAR(200)
    , @acceptLanguage VARCHAR(50)
    )
RETURNS TABLE
AS
RETURN (
        SELECT key_1 AS group_key
            , key_2 AS group_cd
            , COALESCE(l.par_desc, a.par_desc) AS group_name
            , value1 AS group_column
            , intOrder
            , key_group
        FROM dbo.sys_config_data a
        LEFT JOIN sys_config_data_lang l
            ON a.id = l.id
                AND l.langkey = @acceptLanguage
        WHERE key_1 = @form
            AND isUsed = 1
        )