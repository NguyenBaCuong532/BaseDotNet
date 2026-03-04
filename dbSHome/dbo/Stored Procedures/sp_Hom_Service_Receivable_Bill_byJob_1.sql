CREATE procedure [dbo].[sp_Hom_Service_Receivable_Bill_byJob] 
as
	begin try
			
		   SELECT s.ReceiveId
			  FROM [MAS_Service_ReceiveEntry] s
				where (IsBill = 0 or IsBill is null)
					and bill_st = 0
				ORDER BY s.SysDate 

	end try
	begin catch
		declare	@ErrorNum				int,
				@ErrorMsg				varchar(200),
				@ErrorProc				varchar(50),

				@SessionID				int,
				@AddlInfo				varchar(max)

		set @ErrorNum					= error_number()
		set @ErrorMsg					= 'sp_Hom_Service_Receivable_Bill_byJob ' + error_message()
		set @ErrorProc					= error_procedure()

		set @AddlInfo					= ''

		exec utl_Insert_ErrorLog @ErrorNum, @ErrorMsg, @ErrorProc, 'Receivable_Bill', 'Get', @SessionID, @AddlInfo
	end catch