






CREATE procedure [dbo].[sp_Pay_Delete_Recharge_Link]
	@userId nvarchar(450),
	@LinkedID	bigint	
	
as
	begin try	
		if exists(select LinkedID from WAL_TranferLinked where LinkedID = @LinkedID)
		begin		

			delete	trg
			from	WAL_TranferLinked trg
			where LinkedID = @LinkedID

		end

	end try
	begin catch
		declare	@ErrorNum				int,
				@ErrorMsg				varchar(200),
				@ErrorProc				varchar(50),

				@SessionID				int,
				@AddlInfo				varchar(max)

		set @ErrorNum					= error_number()
		set @ErrorMsg					= 'sp_Pay_Delete_Recharge_Link' + error_message()
		set @ErrorProc					= error_procedure()

		set @AddlInfo					= '@userId ' + @userId

		exec utl_Insert_ErrorLog @ErrorNum, @ErrorMsg, @ErrorProc, 'RechargeLink', 'DEL', @SessionID, @AddlInfo
	end catch