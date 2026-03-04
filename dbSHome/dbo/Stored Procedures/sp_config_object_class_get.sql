







CREATE procedure [dbo].[sp_config_object_class_get]
	@UserID	nvarchar(450),
	@objKey nvarchar(50),
	@all	nvarchar(100) = NULL
	,@acceptLanguage nvarchar(50) = 'en'
as
	begin try		

		select N'Tất cả' as [name]
				,@all as [value]
				,1 as isHtml 
				,-1 as intOrder
			where @all is not null
			union all
		SELECT objClass as name
		      ,objValue as value
			  ,1 as isHtml 
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
		set @ErrorMsg					= 'sp_bzz_config_object_class_get ' + error_message()
		set @ErrorProc					= error_procedure()

		set @AddlInfo					= ''

		exec utl_ErrorLog_Set @ErrorNum, @ErrorMsg, @ErrorProc, 'CustObj', 'Get', @SessionID, @AddlInfo
	end catch