






CREATE procedure [dbo].[sp_Pay_Point_Transaction_filter]
	@UserId NVARCHAR(450)
	,@acceptLanguage nvarchar(50) = 'vi-VN'
	
as
	begin try
		 
		 select id = null
			 ,tableKey = 'Point_Transaction_filter'
		     ,groupKey = 'common_group'
		

		SELECT *
		FROM [dbo].[fn_get_field_group] ('common_group') 
		   order by intOrder

		--2 tung o 
		SELECT a.[id]
			  ,[table_name]
			  ,[field_name]
			  ,[view_type]
			  ,[data_type]
			  ,[ordinal]
			  ,[columnLabel]
			  ,[group_cd]
			  ,columnValue		= isnull(l.columnValue,columnDefault)
			  ,[columnClass]
			  ,[columnType]
			  ,[columnObject]
			  ,[isSpecial]
			  ,[isRequire]
			  ,[isDisable]
			  ,[IsVisiable]
			  ,[IsEmpty]
			  ,columnTooltip	= isnull(a.columnTooltip,a.[columnLabel]) 
		  FROM [sys_config_form] a
			left join sys_config_form_log l on a.id = l.id and l.userId = @userId
		  where a.table_name = 'Point_Transaction_filter' 
		  and (isVisiable = 1 or isRequire =1)
		  order by ordinal

	end try
	begin catch
		declare	@ErrorNum				int,
				@ErrorMsg				varchar(200),
				@ErrorProc				varchar(50),

				@SessionID				int,
				@AddlInfo				varchar(max)

		set @ErrorNum					= error_number()
		set @ErrorMsg					= 'sp_Pay_Point_Transaction_filter ' + error_message()
		set @ErrorProc					= error_procedure()

		set @AddlInfo					= ' '

		exec utl_ErrorLog_Set @ErrorNum, @ErrorMsg, @ErrorProc, 'filter', 'GET', @SessionID, @AddlInfo
	end catch