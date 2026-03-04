CREATE PROCEDURE [dbo].[sp_res_sys_manager_filter_get]
	@userId UNIQUEIDENTIFIER = null,
    @table_key nvarchar(50) = null,
	@acceptLanguage NVARCHAR(50) = N'vi-VN'
AS
BEGIN TRY
	SET NOCOUNT ON;

	DECLARE @groupKey NVARCHAR(200) = N'common_group_info';

	SELECT id = null
		 ,tableKey = @table_key
	     ,groupKey = @groupKey

	SELECT *
	FROM [dbo].[fn_get_field_group_lang](@groupKey, @acceptLanguage) 
	ORDER BY intOrder;

	-- Filter fields
	SELECT a.id
		  ,a.[table_name]
		  ,a.[field_name]
		  ,a.[view_type]
		  ,a.[data_type]
		  ,a.[ordinal]
		  ,[columnLabel] = a.[columnLabel] 
		  ,a.[group_cd]
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
	  FROM dbo.fn_config_form_gets(@table_key, @acceptLanguage) a
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
		set @ErrorMsg					= 'sp_res_sys_manager_filter_get ' + error_message()
		set @ErrorProc					= error_procedure()

		set @AddlInfo					= ' '

		exec utl_ErrorLog_Set @ErrorNum, @ErrorMsg, @ErrorProc, 'sp_res_sys_manager_filter_get', 'GET', @SessionID, @AddlInfo
	end catch