






CREATE procedure [dbo].[sp_Pay_Get_Sevice_Recharges]
	@userId nvarchar(450)
as
	begin try		

		SELECT  TranferCd, TranferName
		FROM    WAL_Tranfers
		WHERE   
			--(IsPayment = 1) 
			  (IsFlage = 1) 
			AND (IsRecharge = 1)
		ORDER BY intOrder

	end try
	begin catch
		declare	@ErrorNum				int,
				@ErrorMsg				varchar(200),
				@ErrorProc				varchar(50),

				@SessionID				int,
				@AddlInfo				varchar(max)

		set @ErrorNum					= error_number()
		set @ErrorMsg					= 'sp_Pay_Get_Sevice_Recharges ' + error_message()
		set @ErrorProc					= error_procedure()

		set @AddlInfo					= ' '

		exec utl_Insert_ErrorLog @ErrorNum, @ErrorMsg, @ErrorProc, 'Services', 'GET', @SessionID, @AddlInfo
	end catch