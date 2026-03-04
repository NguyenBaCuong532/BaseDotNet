



CREATE procedure [dbo].[sp_app_module_more]
	@userId			nvarchar(450) = '78f371f0-5dce-4024-810e-ba36fa34b0e8'
	,@acceptLanguage nvarchar(50) = 'vi-VN'
as
	begin try
		
		SELECT a.objValue1 as mod_gr
			  ,a.objName as mod_group		
		FROM [dbo].fn_config_data_gets ('app_mod_gr') a
		where exists(select 1 from module_app where mod_gr = a.objValue1 
			and on_flg =1
			)
		order by intOrder

		SELECT [mod_cd]
			  ,[mod_name]
			  ,[mod_title]
			  ,[mod_gr]
			  ,[mod_icon]
			  ,pathMobile
		  FROM module_app
		  where [on_flg] = 1 and parent_cd is null
		  order by int_ord

	end try
	begin catch
		declare	@ErrorNum				int,
				@ErrorMsg				varchar(200),
				@ErrorProc				varchar(50),

				@SessionID				int,
				@AddlInfo				varchar(max)

		set @ErrorNum					= error_number()
		set @ErrorMsg					= 'sp_hrm_app_module_more ' + error_message()
		set @ErrorProc					= error_procedure()

		set @AddlInfo					= ' - @userId ' + @userId

		exec utl_ErrorLog_Set @ErrorNum, @ErrorMsg, @ErrorProc, 'modules', 'GET', @SessionID, @AddlInfo
	end catch