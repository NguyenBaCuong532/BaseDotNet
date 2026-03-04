






CREATE procedure [dbo].[sp_Hom_Service_Receivable_Item_Del]
   
	@ReceivableId	bigint
	
as
	begin try
	    declare @message nvarchar(100) =''
		declare @valid bit = 0
	    declare @errmessage nvarchar(100)
		set @errmessage = 'This Receivable: ' + cast(@ReceivableId as varchar) + ' is Receipted!'
	    declare @ReceiveId bigint
		select  @ReceiveId = ReceiveId from MAS_Service_Receivable where ReceivableId = @ReceivableId
	    
		if  exists (select ReceivableId from MAS_Service_Receivable where ReceivableId = @ReceivableId) 
		    and not exists (select * from MAS_Service_ReceiveEntry where ReceiveId = @ReceiveId and (IsPayed = 1 or IsBill = 1))
				begin
					Delete t
					from MAS_Service_Receivable t
					where ReceivableId = @ReceivableId

					UPDATE MAS_Service_ReceiveEntry 
					set CommonFee = (SELECT SUM(TotalAmt) FROM [MAS_Service_Receivable] WHERE [ReceiveId] = @ReceiveId and ServiceTypeId = 1)
				        ,VehicleAmt = (SELECT SUM(TotalAmt) FROM [MAS_Service_Receivable] WHERE [ReceiveId] = @ReceiveId and ServiceTypeId = 2)
				        ,LivingAmt = (SELECT SUM(TotalAmt) FROM [MAS_Service_Receivable] WHERE [ReceiveId] = @ReceiveId and (ServiceTypeId = 3 or ServiceTypeId = 4))
					    ,ExtendAmt = (SELECT SUM(TotalAmt) FROM [MAS_Service_Receivable] WHERE [ReceiveId] = @receiveId and ServiceTypeId = 8)
						,TotalAmt = (SELECT SUM(TotalAmt) FROM [MAS_Service_Receivable] WHERE [ReceiveId] = @receiveId)
					 WHERE IsPayed = 0 and ReceiveId = @receiveId

					 set @message = N'Xóa dự thu thành công'
					 set @valid = 1

				end
		else
			begin
				set @message = N'Dự thu đã được tạo hóa đơn hoặc thanh toán. Không được xóa '
				--RAISERROR (@errmessage, -- Message text.
				--		   16, -- Severity.
				--		   1 -- State.
				--		   );
			end
		select  @valid as valid,@message as messages

	end try
	begin catch
		declare	@ErrorNum				int,
				@ErrorMsg				varchar(200),
				@ErrorProc				varchar(50),

				@SessionID				int,
				@AddlInfo				varchar(max)

		set @ErrorNum					= error_number()
		set @ErrorMsg					= 'sp_Hom_Service_Receivable_Item_Del' + error_message()
		set @ErrorProc					= error_procedure()

		set @AddlInfo					= ''

		exec utl_Insert_ErrorLog @ErrorNum, @ErrorMsg, @ErrorProc, 'MAS_Service_Receivable', 'DEL', @SessionID, @AddlInfo
	end catch