



CREATE procedure [dbo].[sp_Hom_Request_Types]
	@userId nvarchar(100),
	@requestCategoryId int
as
	begin try		

		SELECT [RequestTypeId]
			  ,[RequestTypeName]
			  ,[Category]
			  ,[IsFree]
			  ,[Price]
			  ,[Unit]
			  ,[Note]
			  ,iconUrl
		FROM [dbo].MAS_Request_Types
		WHERE requestCategoryId = @requestCategoryId 
			and isReady = 1
	end try
	begin catch
		declare	@ErrorNum				int,
				@ErrorMsg				varchar(200),
				@ErrorProc				varchar(50),

				@SessionID				int,
				@AddlInfo				varchar(max)

		set @ErrorNum					= error_number()
		set @ErrorMsg					= 'sp_Get_RequestTypes ' + error_message()
		set @ErrorProc					= error_procedure()

		set @AddlInfo					= ' '

		exec utl_Insert_ErrorLog @ErrorNum, @ErrorMsg, @ErrorProc, 'RequestType', 'GET', @SessionID, @AddlInfo
	end catch