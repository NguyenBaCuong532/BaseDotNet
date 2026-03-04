



create procedure [dbo].[sp_spk_vehicle_types]
	@UserID		nvarchar(450),
	@all		nvarchar(250) = '-1'
as
	begin try		

		/****** Script for  command from   ******/
	SELECT cast(@all as int) as [VehicleTypeId]
			  ,N'Tất cả' as [VehicleTypeName]
			  ,value = @all
			  ,name = N'Tất cả'
	where @all is not null 
		UNION ALL
	SELECT [VehicleTypeId]
		  ,[VehicleTypeName]
		  ,value	= [VehicleTypeId]
		  ,name		= [VehicleTypeName]
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
		set @ErrorMsg					= 'sp_spk_vehicle_types ' + error_message()
		set @ErrorProc					= error_procedure()

		set @AddlInfo					= ' '

		exec utl_Insert_ErrorLog @ErrorNum, @ErrorMsg, @ErrorProc, 'MAS_VehicleTypes', 'GET', @SessionID, @AddlInfo
	end catch