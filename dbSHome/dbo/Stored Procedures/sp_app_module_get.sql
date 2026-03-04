


CREATE   procedure [dbo].[sp_app_module_get]
	@userId uniqueidentifier = 'dfedccfd-3ea5-48c4-ae23-447d80a6ada6',
	@mod_cd		nvarchar(20) =''
	,@acceptLanguage nvarchar(50) = 'vi-VN'
as
	begin try

		select m.mod_cd
			  ,[mod_name] = ISNULL(l.mod_name, m.mod_name)
			  ,isnull(l.[mod_title],m.[mod_title]) as title1
			  ,isnull(l.[mod_title],m.[mod_title]) as title_tooltip
		FROM module_app m
        LEFT JOIN module_app_lang l ON m.mod_cd = l.mod_cd AND l.langKey = @acceptLanguage
		where m.mod_cd = @mod_cd

		SELECT [mod_cd] = m.mod_cd
			  ,[mod_name] = ISNULL(l.mod_name, m.mod_name)
			  ,isnull(l.[mod_title],m.[mod_title]) as [mod_title]
			  ,[mod_gr]
			  ,[mod_icon]
			  ,pathMobile
		  FROM module_app m
          LEFT JOIN module_app_lang l ON m.mod_cd = l.mod_cd AND l.langKey = @acceptLanguage
		  where [on_flg] = 1 
			and parent_cd = @mod_cd
		  order by mod_cd

		  

	end try
	begin catch
		declare	@ErrorNum				int,
				@ErrorMsg				varchar(200),
				@ErrorProc				varchar(50),

				@SessionID				int,
				@AddlInfo				varchar(max)

		set @ErrorNum					= error_number()
		set @ErrorMsg					= 'sp_hrm_app_module_get ' + error_message()
		set @ErrorProc					= error_procedure()

		set @AddlInfo					= ' - @userId ' --+ @userId

		exec utl_ErrorLog_Set @ErrorNum, @ErrorMsg, @ErrorProc, 'Order_List', 'GET', @SessionID, @AddlInfo
	end catch