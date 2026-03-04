
CREATE PROCEDURE [dbo].[sp_get_data_fields_n] @id NVARCHAR(50)
    , @tableName NVARCHAR(100)
    , @keyName VARCHAR(50) = NULL
    , @subQuery NVARCHAR(MAX) = NULL
    , @formName VARCHAR(50) = NULL
    
AS
BEGIN
    SET @formName = ISNULL(@formName,@tableName)
    IF ISNULL(@keyName, '') = ''
        SET @keyName = 'id'

    IF @id IS NULL
        OR @id = ''
    BEGIN
        SELECT [id]
            , [table_name]
            , [field_name]
            , [view_type]
            , [data_type]
            , [ordinal]
            , [group_cd]
            , [columnLabel]
            , [columnTooltip]
            , [columnClass]
            , [columnDisplay]
            , [columnType]
            , [columnObject]
            , [isVisiable]
            , [isSpecial]
            , [isRequire]
            , [isDisable]
            , columnDefault [columnValue]
        FROM sys_config_form
        WHERE table_name = @formName
        --and (isVisiable = 1 or isRequire = 1)
        ORDER BY ordinal
    END
    ELSE
    BEGIN
        DECLARE @sql NVARCHAR(MAX) = N''
            , @tableCols NVARCHAR(max) = N''
            , @unpivotCols NVARCHAR(max) = N'' --build columns

        SELECT @tableCols = @tableCols + ',' + CASE 
                WHEN f.data_type = 'date'
                    THEN 'convert(nvarchar(max),' + QUOTENAME(f.field_name) + ',103) ' + QUOTENAME(f.field_name)
                WHEN f.data_type = 'datetime'
                    THEN ' convert(NVARCHAR(max),format(' + QUOTENAME(f.field_name) + ','''+ ISNULL(null,'dd/MM/yyyy hh:mm:ss') +''')) ' + QUOTENAME(f.field_name)
                WHEN f.data_type = 'uniqueidentifier'
                    THEN 'LOWER(cast(' + QUOTENAME(f.field_name) + ' as nvarchar(max)))' + QUOTENAME(f.field_name)
                WHEN f.data_type = 'bit'
                    OR f.columnType = 'checkbox'
                    THEN 'convert(nvarchar(max),case ' + QUOTENAME(f.field_name) + ' when 1 then ''True'' else ''False'' end) ' + QUOTENAME(f.field_name)
                ELSE 'convert(nvarchar(max),' + QUOTENAME(f.field_name) + ') ' + QUOTENAME(f.field_name)
                END
        FROM dbo.sys_config_form f
        WHERE table_name = @formName

        SET @tableCols = RIGHT(@tableCols, len(@tableCols) - 1) --unpivot cols

        SELECT @unpivotCols = @unpivotCols + ',' + QUOTENAME(f.field_name)
        FROM dbo.sys_config_form f
        WHERE f.table_name = @formName

        SET @unpivotCols = RIGHT(@unpivotCols, len(@unpivotCols) - 1) --build sql
        SET @sql = 'WITH tempTb as (SELECT * FROM (' + 'SELECT ' + @tableCols + ' FROM ' +ISNULL('('+@subQuery+') AS t',QUOTENAME(@tableName) + ' WHERE ' + @keyName + '=@id') + ')p UNPIVOT( columnValue FOR field_name in (' + @unpivotCols + ')) as unp) ' + 'SELECt f.[id]
				  ,f.[table_name]
				  ,f.[field_name]
				  ,f.[view_type]
				  ,f.[data_type]
				  ,f.[ordinal]
				  ,f.[group_cd]
				  ,f.[columnLabel]
				  ,f.[columnTooltip]
				  ,f.[columnClass]
				  ,f.[columnDisplay]
				  ,f.[columnType]
				  ,f.[columnObject]
				  ,f.[isVisiable]
				  ,f.[isSpecial]
				  ,f.[isRequire]
				,f.[isDisable]
				,t.columnValue [columnValue]
				FROM sys_config_form f LEFT JOIN tempTb t ON f.field_name = t.field_name WHERE f.table_name = @tableName ORDER BY ordinal' --execute
        PRINT @sql
        EXEC sp_executesql @sql
            , N'@id nvarchar(50), @tableName nvarchar(100)'
            , @id
            , @formName

        
    END
END