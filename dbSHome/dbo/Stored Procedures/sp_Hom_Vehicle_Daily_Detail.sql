
create procedure [dbo].[sp_Hom_Vehicle_Daily_Detail]
	@UserID				nvarchar(450),
	@VehicleDailyId		int = 0

as
	begin try		
		SELECT a.[VehicleDailyId]
				,a.projectCd as ProjectCd
			  ,a.[VehicleTypeId]
			  ,b.VehicleTypeName
			  ,a.[Price0], Price1, Price2
			  ,Unit, Block0, Block1
			  ,Note0,  Note1, Note2
			  --,N'Tính theo diện tích' as CalculateName
			  ,[IsFree], IsUsed
		  FROM [PAR_BlockVehicleDaily] a  
				inner join MAS_VehicleTypes b on a.VehicleTypeId = b.VehicleTypeId 
		  where (@VehicleDailyId = 0 or a.VehicleDailyId = @VehicleDailyId) 
				and a.IsUsed is null or a.IsUsed = 1
		  Order by a.[VehicleTypeId]

  	
	end try
	begin catch
		declare	@ErrorNum				int,
				@ErrorMsg				varchar(200),
				@ErrorProc				varchar(50),

				@SessionID				int,
				@AddlInfo				varchar(max)

		set @ErrorNum					= error_number()
		set @ErrorMsg					= 'sp_Hom_Vehicle_Daily_Detail ' + error_message()
		set @ErrorProc					= error_procedure()

		set @AddlInfo					= '@UserID ' + @UserID --+ ' date' + @ReceiveDate

		exec utl_Insert_ErrorLog @ErrorNum, @ErrorMsg, @ErrorProc, 'ApartmentProject', 'Update', @SessionID, @AddlInfo
	end catch