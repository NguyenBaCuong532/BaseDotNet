




CREATE procedure [dbo].[sp_Hom_Vehicle_Type_Get]
@VehicleType int
as
	begin try		

		/****** Script for SelectTopNRows command from SSMS  ******/
IF @VehicleType>0 
	SELECT [VehicleId]
      ,[VehicleName]
      ,[VehicleType]
	  FROM [MAS_Vehicles]
	  WHERE VehicleType = @VehicleType
ELSE
	SELECT [VehicleId]
      ,[VehicleName]
      ,[VehicleType]
	  FROM [MAS_Vehicles]
	  

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