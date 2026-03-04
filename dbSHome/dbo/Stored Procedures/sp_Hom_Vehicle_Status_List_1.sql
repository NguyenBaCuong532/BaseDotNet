







CREATE procedure [dbo].[sp_Hom_Vehicle_Status_List]
as
	begin try		

		SELECT -1 as [StatusId]
			  ,N'Tất cả' as [StatusName]
		UNION ALL
		SELECT [StatusId]
			  ,[StatusName]
		FROM MAS_VehicleStatus

	end try
	begin catch
		declare	@ErrorNum				int,
				@ErrorMsg				varchar(200),
				@ErrorProc				varchar(50),

				@SessionID				int,
				@AddlInfo				varchar(max)

		set @ErrorNum					= error_number()
		set @ErrorMsg					= 'sp_Hom_Get_VehicleStatus ' + error_message()
		set @ErrorProc					= error_procedure()

		set @AddlInfo					= ' '

		exec utl_Insert_ErrorLog @ErrorNum, @ErrorMsg, @ErrorProc, 'VehicleStatus', 'GET', @SessionID, @AddlInfo
	end catch