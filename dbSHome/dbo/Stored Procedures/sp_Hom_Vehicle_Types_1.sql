
CREATE procedure [dbo].[sp_Hom_Vehicle_Types]
	@UserID				nvarchar(450)

as
	begin try		
		SELECT [VehicleTypeId]
			  ,[VehicleTypeName]
			  ,[ServiceId]
			  ,[rowguid]
		  FROM [dbSHome].[dbo].[MAS_VehicleTypes]
  	
	end try
	begin catch
		declare	@ErrorNum				int,
				@ErrorMsg				varchar(200),
				@ErrorProc				varchar(50),

				@SessionID				int,
				@AddlInfo				varchar(max)

		set @ErrorNum					= error_number()
		set @ErrorMsg					= 'sp_Hom_Vehicle_Types ' + error_message()
		set @ErrorProc					= error_procedure()

		set @AddlInfo					= '@UserID ' + @UserID --+ ' date' + @ReceiveDate

		exec utl_Insert_ErrorLog @ErrorNum, @ErrorMsg, @ErrorProc, 'ApartmentProject', 'Update', @SessionID, @AddlInfo
	end catch