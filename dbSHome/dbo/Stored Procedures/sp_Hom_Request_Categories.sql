




CREATE procedure [dbo].[sp_Hom_Request_Categories]
	@userId nvarchar(100)
as
	begin try		

		SELECT [requestCategoryId]
			  ,[requestCategoryName]
			  ,[requestCategoryName_en]
			  ,[code]
			  ,[categoryType]
		  FROM [dbSHome].[dbo].[MAS_Request_Category]
		  WHERE [categoryType] = 1

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