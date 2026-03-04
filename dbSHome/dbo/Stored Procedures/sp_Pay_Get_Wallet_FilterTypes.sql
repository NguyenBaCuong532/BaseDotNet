









create procedure [dbo].[sp_Pay_Get_Wallet_FilterTypes]
as
	begin try		


	SELECT -1 as FilterTypeId, N'Tất cả giao dịch' as FilterTypeName
	union 
	SELECT 0 as FilterTypeId, N'Thành công' as FilterTypeName
	union 
	SELECT 0 as FilterTypeId, N'Thất bại' as FilterTypeName
	union 
	SELECT 0 as FilterTypeId, N'Nạp tiền vào ví' as FilterTypeName
	union 
	SELECT 0 as FilterTypeId, N'Chi tiêu thanh toán' as FilterTypeName

	end try
	begin catch
		declare	@ErrorNum				int,
				@ErrorMsg				varchar(200),
				@ErrorProc				varchar(50),

				@SessionID				int,
				@AddlInfo				varchar(max)

		set @ErrorNum					= error_number()
		set @ErrorMsg					= 'sp_Pay_Get_Wallet_FilterTypes ' + error_message()
		set @ErrorProc					= error_procedure()

		set @AddlInfo					= ' '

		exec utl_Insert_ErrorLog @ErrorNum, @ErrorMsg, @ErrorProc, 'FilterTypes', 'GET', @SessionID, @AddlInfo
	end catch