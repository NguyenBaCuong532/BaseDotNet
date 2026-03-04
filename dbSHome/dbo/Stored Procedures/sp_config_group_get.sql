



CREATE procedure [dbo].[sp_config_group_get]
	@userID	nvarchar(450) = null,	
	@key_1 nvarchar(100),
	@key_2 nvarchar(100),
	@acceptLanguage nvarchar(50) = 'vi-VN'
as
	begin try	
		select id 
				,tableKey = 'sys_config_group'
				,groupKey = 'common_group'
		from sys_config_data 
		where key_1 = @key_1 and key_2 = @key_2

		SELECT *
		FROM [dbo].[fn_get_field_group] ('common_group') 
			order by intOrder

		select a.[id]
				,[table_name]
				,[field_name]
				,[view_type]
				,[data_type]
				,[ordinal]
				,[columnLabel] = case when @acceptLanguage = 'en' then [columnLabelE] else [columnLabel] end
				,[group_cd]
				,case [data_type] 
					when 'nvarchar' then convert(nvarchar(350), case [field_name] 
						when 'mod_cd' then c.mod_cd 
						when 'key_1' then c.key_1 
						when 'key_2' then c.key_2 
						when 'key_group' then c.key_group 
						when 'par_desc' then c.par_desc 
						when 'par_desc_e' then c.par_desc_e 
						when 'value1' then c.value1 
					end)
					else convert(nvarchar(350), case [field_name] 
						when 'type_value' then c.type_value 
						when 'value2' then c.value2 
						when 'intOrder' then c.intOrder 
						when 'isUsed' then c.IsUsed 
					end) 
					end as columnValue
				,[columnClass]
				,[columnType]
				,[columnObject]
				,[isSpecial]
				,[isRequire]
				,[isDisable]
				,[IsVisiable]
				,[IsEmpty]
				,isnull(a.columnTooltip,a.[columnLabel]) as columnTooltip
			from [sys_config_form] a
			,[dbo].[sys_config_data] c
			where (table_name = 'sys_config_group' 
			and (isvisiable = 1 or isRequire = 1))
			and c.key_1 = @key_1 and key_2 = @key_2
			order by ordinal
			
	end try
	begin catch
		declare	@ErrorNum				int,
				@ErrorMsg				varchar(200),
				@ErrorProc				varchar(50),

				@SessionID				int,
				@AddlInfo				varchar(max)

		set @ErrorNum					= error_number()
		set @ErrorMsg					= 'sp_config_parameter_get ' + error_message()
		set @ErrorProc					= error_procedure()

		set @AddlInfo					= ''

		exec utl_errorLog_set @ErrorNum, @ErrorMsg, @ErrorProc, 'Parameter', 'Get', @SessionID, @AddlInfo
	end catch