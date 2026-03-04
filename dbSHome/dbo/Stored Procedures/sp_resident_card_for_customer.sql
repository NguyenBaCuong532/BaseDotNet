

CREATE procedure [dbo].[sp_resident_card_for_customer]
	@UserID	nvarchar(450),
	@CustId	nvarchar(100) 
as
	begin try	

		SELECT value = CardId
			  ,name = CardCd
		  FROM [MAS_Cards] where CustId = @CustId

	end try
	begin catch
		declare	@ErrorNum				int,
				@ErrorMsg				varchar(200),
				@ErrorProc				varchar(50),

				@SessionID				int,
				@AddlInfo				varchar(max)

		set @ErrorNum					= error_number()
		set @ErrorMsg					= 'sp_hrm_employee_card_status ' + error_message()
		set @ErrorProc					= error_procedure()

		set @AddlInfo					= ''

		exec utl_ErrorLog_Set @ErrorNum, @ErrorMsg, @ErrorProc, 'CustObj', 'Get', @SessionID, @AddlInfo
	end catch