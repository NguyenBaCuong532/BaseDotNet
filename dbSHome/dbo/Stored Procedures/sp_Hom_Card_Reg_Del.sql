


CREATE procedure [dbo].[sp_Hom_Card_Reg_Del]
	@RegCardId	int	
	
as
	begin try	

	IF NOT Exists(Select CardCd FROM MAS_Cards a inner join TRS_Request_Card b on a.CardId = b.CardId WHERE b.RequestId = @RegCardId)
	BEGIN
		delete rcc from TRS_RegCardCredit rcc
		where 	rcc.RequestId = @RegCardId

		delete rcv from TRS_RegCardVehicle rcv
		where 	rcv.RequestId = @RegCardId

		delete	rc
		from	TRS_Request_Card rc
		where	rc.RequestId = @RegCardId

		delete from MAS_Requests where RequestId = @RegCardId
	END

	end try
	begin catch
		declare	@ErrorNum				int,
				@ErrorMsg				varchar(200),
				@ErrorProc				varchar(50),

				@SessionID				int,
				@AddlInfo				varchar(max)

		set @ErrorNum					= error_number()
		set @ErrorMsg					= 'sp_Delete_FamilyMember_ByCifNo]' + error_message()
		set @ErrorProc					= error_procedure()

		set @AddlInfo					= ''

		exec utl_Insert_ErrorLog @ErrorNum, @ErrorMsg, @ErrorProc, 'Member', 'DEL', @SessionID, @AddlInfo
	end catch