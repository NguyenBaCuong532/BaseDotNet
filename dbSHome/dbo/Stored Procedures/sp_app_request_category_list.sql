



CREATE   procedure [dbo].[sp_app_request_category_list]
	  @userId uniqueidentifier
	, @acceptLanguage NVARCHAR(50)     = N'vi-VN'
	, @categoryType nvarchar(20) = 'fix'
as
	begin try		

		SELECT [RequestTypeId] as value
			  ,RequestTypeName as name
			  ,icon_is = 1
			  ,iconUrl as icon
			  ,category
		FROM [dbo].MAS_Request_Types
		WHERE isReady = 1
			and category = 'fix'

	end try
	begin catch
		declare	@ErrorNum				int,
				@ErrorMsg				varchar(200),
				@ErrorProc				varchar(50),

				@SessionID				int,
				@AddlInfo				varchar(max)

		set @ErrorNum					= error_number()
		set @ErrorMsg					= 'sp_Hom_Request_Categories ' + error_message()
		set @ErrorProc					= error_procedure()

		set @AddlInfo					= ' '

		exec utl_Insert_ErrorLog @ErrorNum, @ErrorMsg, @ErrorProc, 'RequestType', 'GET', @SessionID, @AddlInfo
	end catch