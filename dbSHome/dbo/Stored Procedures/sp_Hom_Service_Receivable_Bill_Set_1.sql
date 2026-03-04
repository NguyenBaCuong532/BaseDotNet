






CREATE procedure [dbo].[sp_Hom_Service_Receivable_Bill_Set]
	@UserID	nvarchar(450),
	@ReceiveId bigint,
	@BillUrl nvarchar(350),
	@BillViewUrl nvarchar(350)
as
	begin try		
		set @BillUrl = isnull(@BillUrl,'')
		IF @ReceiveId >0
			UPDATE [dbo].[MAS_Service_ReceiveEntry]
			   SET [IsBill] = case when len(@BillUrl)> 0 then 1 else 0 end
				  ,[BillUrl] = @BillUrl
				  ,[BillDt] = getdate()
				  ,BillViewUrl = @BillViewUrl
				  ,bill_st = 2
			 WHERE ReceiveId = @ReceiveId

	end try
	begin catch
		declare	@ErrorNum				int,
				@ErrorMsg				varchar(200),
				@ErrorProc				varchar(50),

				@SessionID				int,
				@AddlInfo				varchar(max)

		set @ErrorNum					= error_number()
		set @ErrorMsg					= 'sp_Hom_Service_Receivable_Bill_Set ' + error_message()
		set @ErrorProc					= error_procedure()

		set @AddlInfo					= '@User ' + @UserID 

		exec utl_Insert_ErrorLog @ErrorNum, @ErrorMsg, @ErrorProc, 'Receivable_Bill_Set', 'Set', @SessionID, @AddlInfo
	end catch