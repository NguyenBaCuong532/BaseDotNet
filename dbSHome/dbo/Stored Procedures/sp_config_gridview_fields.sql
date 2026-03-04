

CREATE procedure [dbo].[sp_config_gridview_fields]
	@UserID		nvarchar(450),
	@action		nvarchar(10) = 'view',
	@id			bigint,
	@view_grid	nvarchar(100) = NULL,
	@field_name nvarchar(100) = NULL
as
	begin try
		if exists(select id from dbo.sys_config_list where id = @id)
			begin
				select id 
				from dbo.sys_config_list 
				where id = @id

			SELECT  objvalue as group_cd
					,objname as group_name 
			FROM [dbo].fn_config_data_gets ('common_group') 

				SELECT 
					 a.id
					,a.[table_name]
					,a.[field_name]
					,a.[view_type]
					,a.[data_type]
					,a.[ordinal]
					,isnull(a.[columnLabel],a.[field_name]) as [columnLabel]
					,1 [group_cd]
					,case a.data_type when 'nvarchar' then convert(nvarchar(350), case a.field_name
							when 'view_grid' then b.view_grid
							when 'columnField' then b.columnField
							when 'columnCaption' then b.columnCaption
							
							when 'data_type' then b.data_type
							when 'fieldType' then b.fieldType
							when 'cellClass' then b.cellClass
							when 'conditionClass' then b.conditionClass
							when 'pinned' then b.pinned
							 end
						  )
						   when 'bigint' then cast(case a.field_name
							 when 'id' then 0
							 end as nvarchar(100))
							when 'int' then cast(case a.field_name 
							when 'view_type' then b.view_type
							when 'ordinal' then b.ordinal
							when 'columnWidth' then b.columnWidth
							 end as nvarchar(100)) 
							
						else convert(nvarchar(50),case a.field_name 
							when 'isUsed' then b.isUsed
							when 'isHide' then  b.isHide
							when 'isMasterDetail' then  b.isMasterDetail
							when 'isStatusLable' then  b.isStatusLable
							when 'isFilter' then  b. isFilter
						 end) end as columnValue
						,a.[columnClass]
						,a.[columnType]
						,a.[columnObject]
						,a.[isSpecial]
						,a.[isRequire]
						,a.[isDisable]
						,a.[IsVisiable]
						,a.[IsEmpty]
						,isnull(a.columnTooltip,[columnLabel]) as columnTooltip
						,case when @action = 'edit' then 1 else 0 end as isChange
				FROM (select * from sys_config_form 
					where (table_name = 'sys_config_list')
						and (isVisiable = 1 or isRequire = 1)
						) a,
					sys_config_list b
				WHERE  b.id = @id
				ORDER BY a.ordinal
			end
		else
			begin
				select @id as id 

				SELECT  objvalue as group_cd
						,objname as group_name 
				FROM [dbo].fn_config_data_gets ('common_group') 

				SELECT	
						 a.id
						,a.[table_name]
						,a.[field_name]
						,a.[view_type]
						,a.[data_type]
						,a.[ordinal]
						,isnull(a.[columnLabel],a.[field_name]) as [columnLabel]
						,1 [group_cd]
						,case a.data_type when 'nvarchar' then convert(nvarchar(350), case a.field_name
							when 'view_grid' then b.view_grid
							when 'columnField' then b.columnField
							when 'columnCaption' then b.columnCaption
							when 'data_type' then b.data_type
							when 'fieldType' then b.fieldType
							when 'cellClass' then b.cellClass
							when 'conditionClass' then b.conditionClass
							when 'pinned' then b.pinned
							 end
						  )
						 when 'bigint' then cast(case a.field_name
							 when 'id' then 0
							 end as nvarchar(100))
						 when 'int' then cast(case a.field_name 
							when 'view_type' then b.view_type
							when 'ordinal' then b.ordinal
							when 'columnWidth' then b.columnWidth
							 end as nvarchar(100)) 
						else convert(nvarchar(50),case a.field_name 
							when 'isVisiable' then b.isUsed
							when 'isSpecial' then  b.isHide
							when 'isRequire' then  b.isMasterDetail
							when 'isDisable' then  b.isStatusLable
							when 'isDisable' then  b.isFilter
							when 'IsEmpty' then 1
						 end) end as columnValue
						 ,case when @action = 'new' then 1 else 0 end as isChange
				FROM (select * from sys_config_form 
				where (table_name = 'sys_config_list')
					) a,
					(SELECT TABLE_NAME as view_grid
						,0 as view_type
						,COLUMN_NAME as columnField
						,null as columnCaption
						,100 as columnWidth
						,DATA_TYPE
						,'text' as fieldType
						,'border-right' as cellClass
						,'' as conditionClass
						,'' as Pinned
						,ORDINAL_POSITION as ordinal
						,0 as isMasterDetail
						,0 as isStatusLable
						,1 as isUsed
						,0 as isHide
						,0 as isFilter
						,'1' as group_cd
						FROM INFORMATION_SCHEMA.COLUMNS a
						WHERE TABLE_NAME like '%' + @view_grid + '%') b
				WHERE b.view_grid = @view_grid	AND b.columnField =  @field_name
			 ORDER BY a.ordinal
			end
	
	end try
	begin catch
		declare	@ErrorNum				int,
				@ErrorMsg				varchar(200),
				@ErrorProc				varchar(50),

				@SessionID				int,
				@AddlInfo				varchar(max)

		set @ErrorNum					= error_number()
		set @ErrorMsg					= 'sp_CA_PB_Grid_Get ' + error_message()
		set @ErrorProc					= error_procedure()

		set @AddlInfo					= ''

		exec utl_ErrorLog_Set @ErrorNum, @ErrorMsg, @ErrorProc, 'sys_config_list', 'Get', @SessionID, @AddlInfo
	end catch