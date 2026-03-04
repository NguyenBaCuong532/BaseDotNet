CREATE procedure [dbo].[sp_Hom_ELE_Card_Del]
   @UserId	nvarchar(50),
   @MasEcId	int	
	
as
	begin try	
		if exists(select Id from MAS_Elevator_Card where Id = @MasEcId)
		begin		

			delete	trg
			from	MAS_Elevator_Card trg
			where Id = @MasEcId
		end
	end try
	begin catch
		declare	@ErrorNum				int,
				@ErrorMsg				varchar(200),
				@ErrorProc				varchar(50),

				@SessionID				int,
				@AddlInfo				varchar(max)

		set @ErrorNum					= error_number()
		set @ErrorMsg					= 'sp_Hom_ELE_Card_Del' + error_message()
		set @ErrorProc					= error_procedure()

		set @AddlInfo					= ' UserId' + @UserId

		exec utl_Insert_ErrorLog @ErrorNum, @ErrorMsg, @ErrorProc, 'MAS_Elevator_Card', 'DEL', @SessionID, @AddlInfo
	end catch