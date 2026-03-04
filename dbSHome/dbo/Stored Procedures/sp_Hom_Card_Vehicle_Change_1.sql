





CREATE procedure [dbo].[sp_Hom_Card_Vehicle_Change]
	@UserId	nvarchar(450),
	@CardVehicleId bigint,
	@CardId bigint

as
	begin try	
		if exists (select a.apartmentId from MAS_Apartment_Member a 
					inner join MAS_Cards b on a.CustId = b.CustId
					inner join MAS_CardVehicle c on b.CardId = c.CardId
				where CardVehicleId = @CardVehicleId 
				and exists(select CardId from MAS_Cards mc inner join MAS_Apartment_Member ma on mc.CustId = ma.CustId 
					where mc.CardId = @CardId and ma.ApartmentId = a.ApartmentId))
		begin
			UPDATE t1
				SET CardId = @CardId
			FROM MAS_CardVehicle t1 
			WHERE CardVehicleId = @CardVehicleId 

			UPDATE t
				SET [isVehicle] = case when (select count(cardVehicleId) from MAS_CardVehicle where CardId = t.CardId and status = 1) > 0 then 1 else 0 end
			FROM [MAS_Cards] t
				WHERE CardId = @cardId 
		end

	end try
	begin catch
		declare	@ErrorNum				int,
				@ErrorMsg				varchar(200),
				@ErrorProc				varchar(50),

				@SessionID				int,
				@AddlInfo				varchar(max)

		set @ErrorNum					= error_number()
		set @ErrorMsg					= 'sp_Hom_Update_Card_Vehicle_Change ' + error_message()
		set @ErrorProc					= error_procedure()

		set @AddlInfo					= '@UserID '  

		exec utl_Insert_ErrorLog @ErrorNum, @ErrorMsg, @ErrorProc, 'VehicleChange', 'Update', @SessionID, @AddlInfo
	end catch