









CREATE procedure [dbo].[sp_User_Get_ClientApp]
		@clientId nvarchar(250)

as
	begin try
	
	--1
	 SELECT [ClientId]
		   ,[ClientName]
		   ,[AppId]
		   ,AppName
	  FROM [PAR_AppClient]
		  WHERE [ClientId] = @clientId
	

	end try
	begin catch
		declare	@ErrorNum				int,
				@ErrorMsg				varchar(200),
				@ErrorProc				varchar(50),

				@SessionID				int,
				@AddlInfo				varchar(max)

		set @ErrorNum					= error_number()
		set @ErrorMsg					= 'sp_User_Get_ClientApp ' + error_message()
		set @ErrorProc					= error_procedure()

		set @AddlInfo					= ' '

		exec utl_Insert_ErrorLog @ErrorNum, @ErrorMsg, @ErrorProc, 'ClientApp', 'GET', @SessionID, @AddlInfo
	end catch