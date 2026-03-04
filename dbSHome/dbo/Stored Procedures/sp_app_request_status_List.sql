




CREATE   procedure [dbo].[sp_app_request_status_List]
	  @userId uniqueidentifier
	, @acceptLanguage NVARCHAR(50)     = N'vi-VN'
	, @statusKey nvarchar(20) = 'request'
as
	begin try		

		SELECT objvalue as value
			  ,objName as name 
			  ,intOrder
			  ,objGroup as icon
		FROM [dbo].fn_config_data_gets ('request_st')

	end try
	begin catch
		declare	@ErrorNum				int,
				@ErrorMsg				varchar(200),
				@ErrorProc				varchar(50),

				@SessionID				int,
				@AddlInfo				varchar(max)

		set @ErrorNum					= error_number()
		set @ErrorMsg					= 'sp_app_request_status_List ' + error_message()
		set @ErrorProc					= error_procedure()

		set @AddlInfo					= ' '

		exec utl_Insert_ErrorLog @ErrorNum, @ErrorMsg, @ErrorProc, 'RequestType', 'GET', @SessionID, @AddlInfo
	end catch