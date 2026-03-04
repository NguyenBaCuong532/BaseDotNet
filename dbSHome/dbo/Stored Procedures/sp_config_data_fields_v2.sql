
-- Author:		AnhTT, Duongpx Edit
-- Create date: 7/12/2024 10:39:53 PM
-- Description:	Get data fields
-- =============================================
CREATE
    

 PROCEDURE [dbo].[sp_config_data_fields_v2] @id NVARCHAR(150)
    , @key_name NVARCHAR(150)
    , @table_name NVARCHAR(200)
    , @dataTableName NVARCHAR(200) = ''
    , @acceptLanguage NVARCHAR(50) = 'vi-VN'
AS
BEGIN
    -- check if @dataTableName is null or empty then set value to @table_name
    IF @dataTableName IS NULL
        OR @dataTableName = ''
        SET @dataTableName = @table_name

    DECLARE @isTemptable BIT

    IF EXISTS (
            SELECT 1
            WHERE @dataTableName LIKE '#%'
            )
        SET @isTemptable = 1

    IF (
            @id IS NULL
            OR @id = ''
            )
        AND @isTemptable = 0
    BEGIN
        SELECT [id]
            , [table_name]
            , [field_name]
            , [view_type]
            , [data_type]
            , [ordinal]
            , [group_cd]
            , [columnLabel]
            , [columnLabelE]
            , [columnTooltip]
            , [columnClass]
            , [columnType]
            , [columnObject]
            , [isVisiable]
            , [isSpecial]
            , [isRequire]
            , [isDisable]
            , columnDefault [columnValue]
            , columnDisplay
            , isIgnore
        -- , maxLength
        -- , table_relation
        FROM sys_config_form
        WHERE table_name = @table_name
            AND is_active = 1
        ORDER BY ordinal
    END
    ELSE
    BEGIN
        DECLARE @sql NVARCHAR(MAX) = N''
            , @tableCols NVARCHAR(max) = N''
            , @unpivotCols NVARCHAR(max) = N'' --build columns

        SELECT @tableCols = @tableCols + ',' + CASE 
                WHEN f.data_type IN ('datetime', 'date')
                    THEN 'convert(nvarchar(max),' + QUOTENAME(f.field_name) + ',103) ' + QUOTENAME(f.field_name)
                WHEN f.data_type = 'uniqueidentifier'
                    THEN 'CONVERT(nvarchar(max),LOWER(' + QUOTENAME(f.field_name) + ')) ' + QUOTENAME(f.field_name)
                WHEN f.data_type = 'time'
                    THEN 'convert(nvarchar(max),' + QUOTENAME(f.field_name) + ',8) ' + QUOTENAME(f.field_name)
                WHEN f.data_type = 'bit'
                    OR f.columnType = 'checkbox'
                    THEN 'convert(nvarchar(max),case ' + QUOTENAME(f.field_name) + ' when 1 then ''True'' else ''False'' end) ' + QUOTENAME(f.field_name)
                ELSE 'convert(nvarchar(max),' + QUOTENAME(f.field_name) + ') ' + QUOTENAME(f.field_name)
                END
        FROM dbo.sys_config_form f
        WHERE table_name = @table_name
            AND (
                @isTemptable = 1
                AND EXISTS (
                    SELECT 1
                    FROM Tempdb.Sys.Columns x
                    WHERE Object_ID = Object_ID('tempdb..' + @dataTableName)
                        AND x.name = f.field_name
                    )
                OR @isTemptable = 0
                AND EXISTS (
                    SELECT TOP 1 1
                    FROM sys.all_columns sa
                    WHERE object_name(sa.object_id) = @table_name
                        AND f.field_name = sa.name
                    )
                )

        SET @tableCols = RIGHT(@tableCols, len(@tableCols) - 1) --unpivot cols

        SELECT @unpivotCols = @unpivotCols + ',' + QUOTENAME(f.field_name)
        FROM dbo.sys_config_form f
        WHERE f.table_name = @table_name
            AND (
                @isTemptable = 1
                AND EXISTS (
                    SELECT 1
                    FROM Tempdb.Sys.Columns x
                    WHERE Object_ID = Object_ID('tempdb..' + @dataTableName)
                        AND x.name = f.field_name
                    )
                OR @isTemptable = 0
                AND EXISTS (
                    SELECT TOP 1 1
                    FROM sys.all_columns sa
                    WHERE object_name(sa.object_id) = @table_name
                        AND f.field_name = sa.name
                    )
                )

        DECLARE @whereConditional NVARCHAR(250) = IIF(@isTemptable = 1, '', ' WHERE ' + @key_name + '= @id')

        SET @unpivotCols = RIGHT(@unpivotCols, len(@unpivotCols) - 1) --build sql
        SET @sql = 'WITH cte as ' + '(SELECT * FROM (' + 'SELECT ' + @tableCols + ' FROM ' + @dataTableName + @whereConditional + ')p UNPIVOT( columnValue FOR field_name in (' + @unpivotCols + ')) as unp) ' + 'SELECT f.[id]
				  ,f.[table_name]
				  ,f.[field_name]
				  ,f.[view_type]
				  ,f.[data_type]
				  ,f.[ordinal]
				  ,f.[group_cd]
				  ,f.[columnLabel]
				  --,f.[columnLabelE]
				  ,f.[columnTooltip]
				  ,f.[columnClass]
				  ,f.[columnType]
				  ,[columnObject] = IIF(f.columnType = ''file'',concat(f.[columnObject],t.columnValue),f.[columnObject])
				  ,f.[isVisiable]
				  ,f.[isSpecial]
				  ,f.[isRequire]
				  ,f.[isDisable]
				  ,t.columnValue [columnValue]
				  ,f.columnDisplay
				  ,f.isIgnore
				 -- ,f.maxLength
				 -- ,f.table_relation
				FROM dbo.[fn_config_form_gets](@table_name,@acceptLanguage) f 
					LEFT JOIN cte t' + 
            ' ON f.field_name = t.field_name 
				WHERE f.table_name = @table_name ORDER BY ordinal' --execute

        --PRINT @sql

        -- PRINT @whereConditional
        -- PRINT @tableCols
        -- PRINT @unpivotCols
        EXEC sp_executesql @sql
            , N'@id nvarchar(50), @table_name nvarchar(200), @acceptLanguage nvarchar(50)'
            , @id
            , @table_name
            , @acceptLanguage
    END
END