







create procedure [dbo].[sp_Hom_Apartment_RoomCodeView_Set]
	@userId nvarchar(450),
	@roomCode nvarchar(50),
	@buildingCd nvarchar(50),
	@roomCodeView nvarchar(50)

as
	begin try
		--set @clientId = 'web_s_service_prod'
		if exists (select * from MAS_Rooms where RoomCode = @roomCode and BuildingCd = @buildingCd)
			begin
				update MAS_Rooms set RoomCodeView = @roomCodeView where RoomCode = @roomCode and BuildingCd = @buildingCd
			end


	end try
	begin catch
		declare	@ErrorNum				int,
				@ErrorMsg				varchar(200),
				@ErrorProc				varchar(50),

				@SessionID				int,
				@AddlInfo				varchar(max)

		set @ErrorNum					= error_number()
		set @ErrorMsg					= 'sp_Hom_Apartment_RoomCodeView_Set ' + error_message()
		set @ErrorProc					= error_procedure()

		set @AddlInfo					= ' '

		exec utl_Insert_ErrorLog @ErrorNum, @ErrorMsg, @ErrorProc, 'Apartments', 'GET', @SessionID, @AddlInfo
	end catch