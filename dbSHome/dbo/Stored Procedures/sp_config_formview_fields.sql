

CREATE procedure [dbo].[sp_config_formview_fields]
	@UserID		nvarchar(450),
	@action		nvarchar(10) = 'view',
	@id			bigint,
	@table_name nvarchar(100),
	@field_name nvarchar(100)
as
	begin try
	if exists(select id from [dbo].sys_config_form where id = @id)
		begin
			select id from [dbo].sys_config_form where id = @id

			SELECT  objvalue as group_cd
					,objname as group_name 
			FROM [dbo].fn_config_data_gets ('common_group') 

			SELECT  a.[id]
					,a.[table_name]
					,a.[field_name]
					,a.[view_type]
					,a.[data_type]
					,a.[ordinal]
					,1 as [group_cd]
					,case a.[data_type] when 'nvarchar' then convert(nvarchar(350), case a.[field_name]
						when 'table_name' then b.table_name
						when 'field_name' then b.field_name
						when 'data_type' then b.data_type
						when 'group_cd' then b.group_cd
						when 'columnLabel' then b.columnLabel
						when 'columnDefault' then b.columnDefault
						when 'columnClass' then b.columnClass
						when 'columnType' then b.columnType
						when 'columnObject' then b.columnObject
						when 'columnTooltip' then b.columnTooltip
					  end
					  ) 				 
				  else convert(nvarchar(50),case a.[field_name] 
						when 'isVisiable' then b.IsVisiable
						when 'isEmpty' then b.IsEmpty
						when 'isSpecial' then b.isSpecial 
						when 'isRequire' then b.isRequire 
						when 'isDisable' then b.isDisable 
						when 'view_type' then b.view_type
					    when 'ordinal' then b.ordinal
					    when 'id' then b.id
					  end) end as columnValue
					,a.[columnLabel]					
					,a.[columnDefault]
					,a.[columnClass]
					,a.[columnType]
					,a.[columnObject]
					,a.[isVisiable]
					,a.[IsEmpty]
					,a.[isSpecial]
					,a.[isRequire]
					,case when a.field_name = 'id' then 1 else a.[isDisable] end as [isDisable]
					,isnull(a.columnTooltip,a.[columnLabel]) as columnTooltip
					,case when @action = 'edit' then 1 else 0 end as isChange
				FROM (select * from sys_config_form 
					where (table_name = 'sys_config_form')
						--and (isVisiable = 1 or isRequire = 1)
						--and id = @id
						) a,
					[dbo].sys_config_form b
				WHERE b.id = @id
				ORDER by a.[ordinal]
			end
		else
			begin

			select @id as id

			SELECT  objvalue as group_cd
					,objname as group_name 
			FROM [dbo].fn_config_data_gets ('common_group') 

			if not exists(select * from sys_config_form where table_name = 'sys_config_form')
			SELECT  0 [id]
					,a.[table_name]
					,a.[field_name]
					,a.[view_type]
					,a.[data_type]
					,a.[ordinal]
					,1 as [group_cd]
					,case a.[data_type] when 'nvarchar' then convert(nvarchar(350), case a.[field_name]
						when 'table_name' then b.table_name
						when 'field_name' then b.field_name
						when 'data_type' then b.data_type
						when 'group_cd' then b.group_cd
						when 'columnLabel' then b.columnLabel
						when 'columnDefault' then b.columnDefault
						when 'columnClass' then b.columnClass
						when 'columnType' then b.columnType
						when 'columnObject' then b.columnObject
					  end
					  ) 				 
				  else convert(nvarchar(50),case a.[field_name] 
						when 'isVisiable' then b.IsVisiable
						when 'isEmpty' then b.IsEmpty
						when 'isSpecial' then b.isSpecial 
						when 'isRequire' then b.isRequire 
						when 'isDisable' then b.isDisable
						when 'id' then 0
						when 'view_type' then b.view_type
					  when 'ordinal' then b.ordinal
					  end) end as columnValue
					,a.[columnLabel]
					--,[columnValue]
					,a.[columnDefault]
					,a.[columnClass]
					,a.[columnType]
					,a.[columnObject]
					,a.[isVisiable]
					,a.[IsEmpty]
					,a.[isSpecial]
					,a.[isRequire]
					,a.[isDisable]
					,case when @action = 'new' then 1 else 0 end as isChange
				FROM (SELECT TABLE_NAME as table_name
					  ,COLUMN_NAME as field_name
					  ,0 as view_type
					  ,DATA_TYPE as data_type
					  ,ORDINAL_POSITION as ordinal
					  ,COLUMN_NAME as columnLabel
					  ,null as columnValue
					  ,null as columnDefault
					  ,case when DATA_TYPE = 'bit' then 'col-md-2' else 'col-md-4' end as columnClass
					  ,case when DATA_TYPE = 'bit' then 'select' else 'input' end as columnType
					  ,case when DATA_TYPE = 'bit' then 'order_refer_st' else '' end as columnObject
					  ,0  as isSpecial
					  ,case when IS_NULLABLE = 'YES' then 0 else 1 end as isRequire
					  ,0 as isDisable
					  ,1 as IsVisiable
					  ,1 as [IsEmpty]
					  ,cast(1 as nvarchar) as group_cd
				FROM INFORMATION_SCHEMA.COLUMNS 
				WHERE TABLE_NAME like 'ca830pb' 
					and COLUMN_NAME not like 'ca830pb%' 
					) a,
					(SELECT TABLE_NAME as table_name
					  ,COLUMN_NAME as field_name
					  ,0 as view_type
					  ,DATA_TYPE as data_type
					  ,ORDINAL_POSITION as ordinal
					  ,COLUMN_NAME as columnLabel
					  ,null as columnValue
					  ,null as columnDefault
					  ,case when DATA_TYPE = 'bit' then 'col-md-2' else 'col-md-4' end as columnClass
					  ,case when DATA_TYPE = 'bit' then 'select' else 'input' end as columnType
					  ,case when DATA_TYPE = 'bit' then 'order_refer_st' else '' end as columnObject
					  ,0  as isSpecial
					  ,case when IS_NULLABLE = 'YES' then 0 else 1 end as isRequire
					  ,0 as isDisable
					  ,1 as IsVisiable
					  ,1 as [IsEmpty]
					  ,cast(1 as nvarchar) as group_cd
				FROM INFORMATION_SCHEMA.COLUMNS 
				WHERE TABLE_NAME like @table_name 
					and COLUMN_NAME = @field_name) b
				ORDER By a.ordinal
			else
			SELECT  a.[id]
					,a.[table_name]
					,a.[field_name]
					,a.[view_type]
					,a.[data_type]
					,a.[ordinal]
					,1 as [group_cd]
					,case a.[data_type] when 'nvarchar' then convert(nvarchar(350), case a.[field_name]
						when 'table_name' then b.table_name
						when 'field_name' then b.field_name
						when 'data_type' then b.data_type
						when 'group_cd' then b.group_cd
						when 'columnLabel' then b.columnLabel
						when 'columnDefault' then b.columnDefault
						when 'columnClass' then b.columnClass
						when 'columnType' then b.columnType
						when 'columnObject' then b.columnObject
					  end
					  ) 
				  else convert(nvarchar(50),case a.[field_name] 
						when 'isVisiable' then b.IsVisiable
						when 'isEmpty' then b.IsEmpty
						when 'isSpecial' then b.isSpecial 
						when 'isRequire' then b.isRequire 
						when 'isDisable' then b.isDisable 
						when 'view_type' then b.view_type
					    when 'ordinal' then b.ordinal
					    when 'id' then 0
					  end) end as columnValue
					,a.[columnLabel]
					,a.[columnDefault]
					,a.[columnClass]
					,a.[columnType]
					,a.[columnObject]
					,a.[isVisiable]
					,a.[IsEmpty]
					,a.[isSpecial]
					,a.[isRequire]
					,case when a.field_name = 'id' then 1 else a.[isDisable] end as [isDisable]
				FROM (select * from sys_config_form 
					where (table_name = 'sys_config_form')
						) a,
					(SELECT TABLE_NAME as table_name
					  ,COLUMN_NAME as field_name
					  ,0 as view_type
					  ,DATA_TYPE as data_type
					  ,ORDINAL_POSITION as ordinal
					  ,COLUMN_NAME as columnLabel
					  ,null as columnValue
					  ,null as columnDefault
					  ,case when DATA_TYPE = 'bit' then 'col-md-2' else 'col-md-4' end as columnClass
					  ,case when DATA_TYPE = 'bit' then 'select' else 'input' end as columnType
					  ,case when DATA_TYPE = 'bit' then 'order_refer_st' else '' end as columnObject
					  ,0  as isSpecial
					  ,case when IS_NULLABLE = 'YES' then 0 else 1 end as isRequire
					  ,0 as isDisable
					  ,1 as IsVisiable
					  ,1 as [IsEmpty]
					  ,cast(1 as nvarchar) as group_cd
				FROM INFORMATION_SCHEMA.COLUMNS 
				WHERE TABLE_NAME like @table_name 
					and COLUMN_NAME = @field_name) b
				ORDER by a.[ordinal]
			

			end
		
	end try
	begin catch
		declare	@ErrorNum				int,
				@ErrorMsg				varchar(200),
				@ErrorProc				varchar(50),

				@SessionID				int,
				@AddlInfo				varchar(max)

		set @ErrorNum					= error_number()
		set @ErrorMsg					= 'sp_CA_PB_Fields_Get ' + error_message()
		set @ErrorProc					= error_procedure()

		set @AddlInfo					= ''

		exec utl_ErrorLog_Set @ErrorNum, @ErrorMsg, @ErrorProc, 'ca830pb', 'Get', @SessionID, @AddlInfo
	end catch