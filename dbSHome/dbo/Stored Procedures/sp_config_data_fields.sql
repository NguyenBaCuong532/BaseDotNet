



    -- Author:		AnhTT
    -- Create date: 
    -- Description:	Get data fields
    -- =============================================
CREATE procedure [dbo].[sp_config_data_fields] @id nvarchar(50),@fieldname nvarchar(50),
    @tableName nvarchar(100) AS BEGIN
IF @id is null or @id = ''
begin
		select 
			 [id]
			,[table_name]
			,[field_name]
			,[view_type]
			,[data_type]
			,[ordinal]
			,[group_cd]
			,[columnLabel]
			,[columnTooltip]
			,[columnClass]
			,[columnType]
			,[columnObject]
			,[isVisiable]
			,[isSpecial]
			,[isRequire]
			,[isDisable]
			,columnDefault [columnValue]
			,columnDisplay
			,isIgnore
		  from sys_config_form
		  where table_name = @tableName
			  and (isVisiable = 1 or isRequire = 1)
		  order by ordinal
end
else
	begin
		DECLARE @sql NVARCHAR(MAX) = N'',
			@tableCols nvarchar(max) = N'',
			@unpivotCols nvarchar(max) = N'' --build columns
		SELECT @tableCols = @tableCols + ',' +case
				when f.data_type =  'datetime' then 'convert(nvarchar(max),' + QUOTENAME(f.field_name) + ',103) ' + QUOTENAME(f.field_name)
				when f.data_type = 'uniqueidentifier' then 'LOWER(cast('+QUOTENAME(f.field_name)+' as nvarchar(max)))' + QUOTENAME(f.field_name)
				when f.data_type = 'time' then 'convert(nvarchar(max),' + QUOTENAME(f.field_name) + ',8) ' + QUOTENAME(f.field_name)
				when f.data_type = 'bit' or f.columnType = 'checkbox' then 'convert(nvarchar(max),case '+QUOTENAME(f.field_name)+' when 1 then ''True'' else ''False'' end) ' + QUOTENAME(f.field_name)
				else 'convert(nvarchar(max),' + QUOTENAME(f.field_name) + ') ' + QUOTENAME(f.field_name)
			end
		FROM dbo.sys_config_form f
		where table_name = @tableName
		--and (f.isIgnore is null or f.isIgnore = 0)
		set @tableCols = RIGHT(@tableCols, len(@tableCols) -1) --unpivot cols
		SELECT @unpivotCols = @unpivotCols + ',' + QUOTENAME(f.field_name)
		FROM dbo.sys_config_form f
		where f.table_name = @tableName
		--and (f.isIgnore is null or f.isIgnore = 0)
		set @unpivotCols = RIGHT(@unpivotCols, len(@unpivotCols) -1) --build sql
		set @sql = 'WITH tempTb as (SELECT * FROM (' + 'SELECT ' + @tableCols + ' FROM ' + @tableName + ' WHERE '+@fieldname+'=@id' + ')p UNPIVOT( columnValue FOR field_name in (' + @unpivotCols + ')) as unp) ' 
		+ 'SELECt f.[id]
				  ,f.[table_name]
				  ,f.[field_name]
				  ,f.[view_type]
				  ,f.[data_type]
				  ,f.[ordinal]
				  ,f.[group_cd]
				  ,f.[columnLabel]
				  ,f.[columnTooltip]
				  ,f.[columnClass]
				  ,f.[columnType]
				  ,f.[columnObject]
				  ,f.[isVisiable]
				  ,f.[isSpecial]
				  ,f.[isRequire]
				  ,f.[isDisable]
				  ,t.columnValue [columnValue]
				  ,f.columnDisplay
				  ,f.isIgnore
				FROM sys_config_form f LEFT JOIN tempTb t ON f.field_name = t.field_name WHERE f.table_name = @tableName ORDER BY ordinal' --execute
			exec sp_executesql @sql,
			N'@id nvarchar(50), @tableName nvarchar(100)',
			@id,
			@tableName
	end
END