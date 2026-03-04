







CREATE procedure [dbo].[sp_Hom_Card_Guest_Vehicle_Del]
	@userId nvarchar(450),
	@CardVehicleId	bigint	
	
as
	begin try	
		declare @valid bit = 1
		declare @messages nvarchar(100) = ''
		if not exists(select CardVehicleId from MAS_CardVehicle where CardVehicleId = @CardVehicleId)
			begin
				set @Valid = 0
				set @Messages = N'Không tìm thấy thông [' + @CardVehicleId + N']!' 
				--RAISERROR (@messages, -- Message text.
				--	   16, -- Severity.
				--	   1 -- State.
				--	   );
			end
		else
		begin		
			EXECUTE [dbo].[sp_Hom_Card_Vehicle_Del] 
			   @userId
			  ,@cardVehicleId

			delete from MAS_Cards
			where exists(select * from	MAS_CardVehicle 
			where CardVehicleId = @CardVehicleId and cardid = MAS_Cards.CardId)

		end

		select @valid as valid
			  ,@messages as [messages]

	end try
	begin catch
		declare	@ErrorNum				int,
				@ErrorMsg				varchar(200),
				@ErrorProc				varchar(50),

				@SessionID				int,
				@AddlInfo				varchar(max)

		set @ErrorNum					= error_number()
		set @ErrorMsg					= 'sp_Hom_Card_Guest_Vehicle_Del' + error_message()
		set @ErrorProc					= error_procedure()

		set @AddlInfo					= ''

		exec utl_Insert_ErrorLog @ErrorNum, @ErrorMsg, @ErrorProc, 'CardGuest', 'DEL', @SessionID, @AddlInfo
	end catch