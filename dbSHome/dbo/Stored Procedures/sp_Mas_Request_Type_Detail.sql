
CREATE procedure [dbo].[sp_Mas_Request_Type_Detail]
	@UserID				nvarchar(450),
	@requestTypeId		int = 0

as
	begin try		
		SELECT [requestTypeId]
			  ,[requestTypeName]
			  ,[requestCategoryId]
			  ,[category]
			  ,[isFree]
			  ,[price]
			  ,[unit]
			  ,[note]
			  ,[typeName]
			  ,[isReady]
			  ,[iconUrl]
			  ,[sub_prod_cd]
			  ,[chat_cd]
		  FROM [dbSHome].[dbo].[MAS_Request_Types]
          where [requestTypeId] = @requestTypeId

  	
	end try
	begin catch
		declare	@ErrorNum				int,
				@ErrorMsg				varchar(200),
				@ErrorProc				varchar(50),

				@SessionID				int,
				@AddlInfo				varchar(max)

		set @ErrorNum					= error_number()
		set @ErrorMsg					= 'sp_Mas_Request_Type_Detail ' + error_message()
		set @ErrorProc					= error_procedure()

		set @AddlInfo					= '@UserID ' + @UserID --+ ' date' + @ReceiveDate

		exec utl_Insert_ErrorLog @ErrorNum, @ErrorMsg, @ErrorProc, 'ApartmentProject', 'Update', @SessionID, @AddlInfo
	end catch