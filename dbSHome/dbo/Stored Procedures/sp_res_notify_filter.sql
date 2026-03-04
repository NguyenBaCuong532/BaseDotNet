


CREATE procedure [dbo].[sp_res_notify_filter]
	 @UserId UNIQUEIDENTIFIER = NULL,
	 @acceptLanguage nvarchar(50) = N'vi-VN',
	 @tableKey nvarchar(200) = N'notify_filter'
as
begin try
	SET NOCOUNT ON;

	DECLARE @groupKey NVARCHAR(200) = N'common_group_info';

	select id = null
		 ,tableKey = @tableKey
	     ,groupKey = @groupKey

	SELECT *
	FROM [dbo].[fn_get_field_group_lang](@groupKey, @acceptLanguage) 
	ORDER BY intOrder;

	-- Filter fields
	SELECT a.[id]
		  ,a.[table_name]
		  ,a.[field_name]
		  ,a.[view_type]
		  ,a.[data_type]
		  ,a.[ordinal]
		  ,a.[columnLabel]
		  ,a.[group_cd]
		  ,columnValue = isnull(l.columnValue, a.columnDefault)
		  ,a.[columnClass]
		  ,a.[columnType]
		  ,a.[columnObject]
		  ,a.[isSpecial]
		  ,a.[isRequire]
		  ,a.[isDisable]
		  ,a.[IsVisiable]
		  ,a.[IsEmpty]
		  ,columnTooltip = isnull(a.columnTooltip, a.[columnLabel])
		  ,a.[columnDisplay]
		  ,a.[isIgnore]
	  FROM dbo.fn_config_form_gets(@tableKey, @acceptLanguage) a
	  LEFT JOIN sys_config_form_log l ON a.id = l.id AND l.userId = @userId
	  WHERE (a.IsVisiable = 1 OR a.isRequire = 1)
	  ORDER BY a.ordinal

	end try
	begin catch
		declare	@ErrorNum				int,
				@ErrorMsg				varchar(200),
				@ErrorProc				varchar(50),

				@SessionID				int,
				@AddlInfo				varchar(max)

		set @ErrorNum					= error_number()
		set @ErrorMsg					= 'sp_hrm_notify_filter ' + error_message()
		set @ErrorProc					= error_procedure()

		set @AddlInfo					= ' '

		exec utl_ErrorLog_Set @ErrorNum, @ErrorMsg, @ErrorProc, 'employee', 'GET', @SessionID, @AddlInfo
	end catch