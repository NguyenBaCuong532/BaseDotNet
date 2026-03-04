
CREATE procedure [dbo].[sp_Mas_Request_Types]
	@UserID				nvarchar(450)

as
	begin try		
		SELECT RequestTypeId
				,RequestTypeName
		  FROM [MAS_Request_Types] b 
		  WHERE (b.isReady is null or b.isReady = 1)
		  order by [RequestTypeId]

	end try
	begin catch
		declare	@ErrorNum				int,
				@ErrorMsg				varchar(200),
				@ErrorProc				varchar(50),

				@SessionID				int,
				@AddlInfo				varchar(max)

		set @ErrorNum					= error_number()
		set @ErrorMsg					= 'sp_Mas_Request_Types ' + error_message()
		set @ErrorProc					= error_procedure()

		set @AddlInfo					= '@UserID ' + @UserID --+ ' date' + @ReceiveDate

		exec utl_Insert_ErrorLog @ErrorNum, @ErrorMsg, @ErrorProc, 'ApartmentProject', 'Update', @SessionID, @AddlInfo
	end catch