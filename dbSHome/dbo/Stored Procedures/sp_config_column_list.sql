




CREATE procedure [dbo].[sp_config_column_list]
	@UserId			nvarchar(450),
	@mod_cd			nvarchar(50),
	@table_type			nvarchar(50),
	@table_name		nvarchar(100),
	@filter			nvarchar(200)
as
	begin try	
	set @filter = isnull(@filter,'')
	if @table_type = 'table'
	
		SELECT TABLE_NAME
			  ,COLUMN_NAME
		FROM INFORMATION_SCHEMA.COLUMNS a
		WHERE TABLE_NAME like @table_name and COLUMN_NAME like '%' + @filter + '%'
			and not exists (select id from sys_config_form 
				where table_name = a.TABLE_NAME and field_name = a.COLUMN_NAME and [view_type] = 0)
	else
		SELECT TABLE_NAME
			  ,COLUMN_NAME
		FROM INFORMATION_SCHEMA.COLUMNS a
		WHERE TABLE_NAME like @table_name and COLUMN_NAME like '%' + @filter + '%'
			and not exists (select id from sys_config_list 
				where [view_grid] = a.TABLE_NAME and [columnField] = a.COLUMN_NAME and [view_type] = 0)
	 

	end try
	begin catch
		declare	@ErrorNum				int,
				@ErrorMsg				varchar(200),
				@ErrorProc				varchar(50),

				@SessionID				int,
				@AddlInfo				varchar(max)

		set @ErrorNum					= error_number()
		set @ErrorMsg					= 'sp_uinv_config_FieldColumn_List ' + error_message()
		set @ErrorProc					= error_procedure()

		set @AddlInfo					= '@ ' 

		exec utl_ErrorLog_Set @ErrorNum, @ErrorMsg, @ErrorProc, 'FieldColumn', 'Get', @SessionID, @AddlInfo
	end catch