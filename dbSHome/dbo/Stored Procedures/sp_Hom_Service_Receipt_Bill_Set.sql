






create procedure [dbo].[sp_Hom_Service_Receipt_Bill_Set]
	@UserID	nvarchar(450),
	@ReceiptId bigint,
	@ReceiptBillUrl nvarchar(350),
	@ReceiptBillViewUrl nvarchar(350)
as
	begin try		
		set @ReceiptBillUrl = isnull(@ReceiptBillUrl,'')
		IF @ReceiptId >0
			UPDATE [dbo].MAS_Service_Receipts
			   SET ReceiptBillUrl = @ReceiptBillUrl
				  ,ReceiptBillViewUrl = @ReceiptBillViewUrl
			 WHERE ReceiptId = @ReceiptId

	end try
	begin catch
		declare	@ErrorNum				int,
				@ErrorMsg				varchar(200),
				@ErrorProc				varchar(50),

				@SessionID				int,
				@AddlInfo				varchar(max)

		set @ErrorNum					= error_number()
		set @ErrorMsg					= 'sp_Hom_Service_Receipt_Bill_Set ' + error_message()
		set @ErrorProc					= error_procedure()

		set @AddlInfo					= '@User ' + @UserID 

		exec utl_Insert_ErrorLog @ErrorNum, @ErrorMsg, @ErrorProc, 'MAS_Service_Receipts', 'Set', @SessionID, @AddlInfo
	end catch