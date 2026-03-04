




-- =============================================
-- Author:		duongpx
-- Create date: 8/18/2024 6:35:22 AM
-- Description:	chi tiết gửi thông báo
-- =============================================
CREATE procedure [dbo].[sp_res_notify_push_filter]
	 @UserId UNIQUEIDENTIFIER = NULL,
	 @acceptLanguage nvarchar(50) = N'vi-VN',
	 @n_id			uniqueidentifier = null
as
begin try
	SET NOCOUNT ON;

	DECLARE @tableKey NVARCHAR(100) = N'notify_push_filter';
	DECLARE @groupKey NVARCHAR(200) = N'common_group';

	declare @is_act_push bit = 0
			,@is_act_sms bit = 0
			,@is_act_email bit = 0
			,@to_type nvarchar(10)

	select @is_act_push = is_act_push
		  ,@is_act_sms = is_act_sms
		  ,@is_act_email = is_act_email
		  ,@to_type = case when CHARINDEX('crm', source_key, 0) > 0 then '0' else '1' end
	from NotifyInbox 
	where n_id = @n_id

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
		  ,columnValue = isnull(l.columnValue, case when a.field_name in ('orgDepId') 
						then LOWER(cast(@n_id as varchar(50))) else a.columnDefault end)
		  ,a.[columnClass]
		  ,a.[columnType]
		  ,a.[columnObject]
		  ,a.[isSpecial]
		  ,a.[isRequire]
		  ,a.[isDisable]
		  ,[isVisiable] = case when a.field_name in ('push_st') and @is_act_push = 1 then 1 
							when a.field_name in ('email_st') and @is_act_email = 1 then 1 
							when a.field_name in ('sms_st') and @is_act_sms = 1 then 1 
							else a.[IsVisiable] end
		  ,a.[IsEmpty]
		  ,columnTooltip = isnull(a.columnTooltip, a.[columnLabel])
		  ,a.[columnDisplay]
		  ,a.[isIgnore]
	  FROM dbo.fn_config_form_gets(@tableKey, @acceptLanguage) a
		left join sys_config_form_log l on a.id = l.id and l.userId = @userId
	  where (a.IsVisiable = 1 or a.isRequire = 1 or a.field_name in ('push_st','email_st','sms_st'))
	  order by a.ordinal

	end try
	begin catch
		declare	@ErrorNum				int,
				@ErrorMsg				varchar(200),
				@ErrorProc				varchar(50),

				@SessionID				int,
				@AddlInfo				varchar(max)

		set @ErrorNum					= error_number()
		set @ErrorMsg					= 'sp_hrm_notify_push_filter' + error_message()
		set @ErrorProc					= error_procedure()

		set @AddlInfo					= ' '

		exec utl_ErrorLog_Set @ErrorNum, @ErrorMsg, @ErrorProc, 'employee', 'GET', @SessionID, @AddlInfo
	end catch