





CREATE procedure [dbo].[sp_Hom_Vehicle_Type_List]
as
	begin try		

		/****** Script for SelectTopNRows command from SSMS  ******/
	SELECT [VehicleTypeId]
		,[VehicleTypeName]
	FROM [MAS_VehicleTypes]
	ORDER BY [VehicleTypeId]
	  

	end try
	begin catch
		declare	@ErrorNum				int,
				@ErrorMsg				varchar(200),
				@ErrorProc				varchar(50),

				@SessionID				int,
				@AddlInfo				varchar(max)

		set @ErrorNum					= error_number()
		set @ErrorMsg					= 'sp_Get_VehileTypes ' + error_message()
		set @ErrorProc					= error_procedure()

		set @AddlInfo					= ' '

		exec utl_Insert_ErrorLog @ErrorNum, @ErrorMsg, @ErrorProc, 'MAS_VehicleTypes', 'GET', @SessionID, @AddlInfo
	end catch