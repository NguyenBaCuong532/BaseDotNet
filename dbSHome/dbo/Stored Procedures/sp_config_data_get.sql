



CREATE procedure [dbo].[sp_config_data_get]
	@UserID			nvarchar(450),
	@objKey			nvarchar(50),
	@acceptLanguage nvarchar(50) = 'vi-VN',
	@all			nvarchar(100) = NULL
	
as
	begin try	

		SELECT @all as [value]
			  ,CASE WHEN @acceptLanguage = 'en' THEN N'All' ELSE N'Tất cả' END as [name]
			  ,-1 as intOrder
		WHERE @all is not null and @all <> ''
			union all
		SELECT objvalue as value
			  ,objName as name 
			  ,intOrder
		FROM [dbo].fn_config_data_gets (@objKey)
		order by intOrder

	end try
	begin catch
		declare	@ErrorNum				int,
				@ErrorMsg				varchar(200),
				@ErrorProc				varchar(50),

				@SessionID				int,
				@AddlInfo				varchar(max)

		set @ErrorNum					= error_number()
		set @ErrorMsg					= 'sp_config_object_data_get ' + error_message()
		set @ErrorProc					= error_procedure()

		set @AddlInfo					= ''

		exec utl_ErrorLog_Set @ErrorNum, @ErrorMsg, @ErrorProc, 'CustObj', 'Get', @SessionID, @AddlInfo
	end catch