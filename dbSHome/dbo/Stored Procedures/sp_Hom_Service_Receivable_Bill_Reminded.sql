









CREATE procedure [dbo].[sp_Hom_Service_Receivable_Bill_Reminded]
	@userId nvarchar(450),
	@receiveId	bigint
as
	begin try
			UPDATE t
			   SET reminded = isnull(reminded,0)+1
				  ,remind_dt = getdate()
			 FROM MAS_Service_ReceiveEntry t
			 WHERE t.ReceiveId = @receiveId
			
	end try
	begin catch
		declare	@ErrorNum				int,
				@ErrorMsg				varchar(200),
				@ErrorProc				varchar(50),

				@SessionID				int,
				@AddlInfo				varchar(max)

		set @ErrorNum					= error_number()
		set @ErrorMsg					= 'sp_Hom_Service_Receivable_Bill_Reminded' + error_message()
		set @ErrorProc					= error_procedure()

		set @AddlInfo					= ''

		exec utl_Insert_ErrorLog @ErrorNum, @ErrorMsg, @ErrorProc, 'ReceivableReminded', 'Set', @SessionID, @AddlInfo
	end catch