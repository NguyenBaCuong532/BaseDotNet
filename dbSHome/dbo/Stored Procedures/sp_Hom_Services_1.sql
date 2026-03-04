
CREATE procedure [dbo].[sp_Hom_Services]
	@UserID				nvarchar(450),
	@serviceTypeId		int = 0

as
	begin try		
		SELECT [ServiceId]
			  ,[ServiceName]
			  ,[ServiceTypeId]
		  FROM [dbSHome].[dbo].[MAS_Services] 
		  where @serviceTypeId = 0 or ServiceTypeId = @serviceTypeId

	end try
	begin catch
		declare	@ErrorNum				int,
				@ErrorMsg				varchar(200),
				@ErrorProc				varchar(50),

				@SessionID				int,
				@AddlInfo				varchar(max)

		set @ErrorNum					= error_number()
		set @ErrorMsg					= 'sp_Hom_Services ' + error_message()
		set @ErrorProc					= error_procedure()

		set @AddlInfo					= '@UserID ' + @UserID --+ ' date' + @ReceiveDate

		exec utl_Insert_ErrorLog @ErrorNum, @ErrorMsg, @ErrorProc, 'ApartmentProject', 'Update', @SessionID, @AddlInfo
	end catch