CREATE procedure [dbo].[sp_res_service_receivable_bill_set]
	@UserID	nvarchar(450),
	@ReceiveId bigint,
	@BillUrl nvarchar(350),
	@BillViewUrl nvarchar(350),
	@AcceptLanguage nvarchar(50) = null
as
begin try		
		set @BillUrl = isnull(@BillUrl, '')
    
		IF @ReceiveId > 0
    BEGIN
        UPDATE [dbo].[MAS_Service_ReceiveEntry]
			  SET
            [IsBill] = case when len(@BillUrl)> 0 then 1 else 0 end
            ,[BillUrl] = @BillUrl
            ,[BillDt] = getdate()
            ,BillViewUrl = @BillViewUrl
            ,bill_st = 2
            ,updateId = @UserID
        WHERE ReceiveId = @ReceiveId
    END
       
    DECLARE @PeriodsOid NVARCHAR(50) = (SELECT TOP 1 periods_oid FROM MAS_Service_ReceiveEntry WHERE ReceiveId = @ReceiveId);
    IF(@PeriodsOid IS NOT NULL)
    BEGIN
        UPDATE a
        SET a.status = 2
        FROM mas_billing_periods a
        WHERE a.oid = @PeriodsOid
    END

end try
begin catch
		declare	@ErrorNum				int,
				@ErrorMsg				varchar(200),
				@ErrorProc				varchar(50),

				@SessionID				int,
				@AddlInfo				varchar(max)

		set @ErrorNum					= error_number()
		set @ErrorMsg					= 'sp_res_service_receivable_bill_set ' + error_message()
		set @ErrorProc					= error_procedure()

		set @AddlInfo					= '@User ' + @UserID 

		exec utl_Insert_ErrorLog @ErrorNum, @ErrorMsg, @ErrorProc, 'Receivable_Bill_Set', 'Set', @SessionID, @AddlInfo
	end catch