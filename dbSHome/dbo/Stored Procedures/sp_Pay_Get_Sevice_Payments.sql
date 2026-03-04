






CREATE procedure [dbo].[sp_Pay_Get_Sevice_Payments]
	@userId nvarchar(450),
	@isPayment bit
as
	begin try		
	if @isPayment = 1
		SELECT  TranferCd, TranferName, 1 as IsInternal
		FROM    WAL_Tranfers
		WHERE   (IsFlage = 1) 
			AND (IsPayment = 1) 
		ORDER BY intOrder
	else
		SELECT  TranferCd, TranferName, case when TranferCd = 'INT' then 0 else 1 end as IsInternal
		FROM    WAL_Tranfers
		WHERE   (IsFlage = 1) 
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
		set @ErrorMsg					= 'sp_Pay_Get_Sevice_Payments ' + error_message()
		set @ErrorProc					= error_procedure()

		set @AddlInfo					= ' '

		exec utl_Insert_ErrorLog @ErrorNum, @ErrorMsg, @ErrorProc, 'Services', 'GET', @SessionID, @AddlInfo
	end catch