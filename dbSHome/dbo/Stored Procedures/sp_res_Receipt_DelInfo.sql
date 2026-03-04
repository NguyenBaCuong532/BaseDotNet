

--select * from MAS_Service_ReceiveEntry where ApartmentId = 6120


CREATE procedure [dbo].[sp_res_Receipt_DelInfo]
	@userId nvarchar(450),
	@ReceiptId	bigint	
	
as
	begin try
		declare @valid bit = 1
		declare @receiveId bigint
		declare @messages nvarchar(200)
		declare @refno nvarchar(100)
		declare @amtsubtractPoint DECIMAL
        -- ManhNX
		select @receiveId = ReceiveId
		from MAS_Service_Receipts 
		where ReceiptId = @ReceiptId
		--
		if exists(select ReceiptId from MAS_Service_Receipts 
			where ReceiptId = @ReceiptId)
		begin
		    set @refno = (select top 1 isnull(Ref_No,'') from MAS_Service_Receipts where ReceiptId = @ReceiptId)
			--cap nhat du no
			update t
			set  t.DebitAmt = isnull(t.DebitAmt,0) 
				+ case when b.TranferCd = 'debit' then - b.Amount else 
					case when b.Amount > k.PaidAmt - k.DebitAmt then b.Amount - k.PaidAmt + k.DebitAmt else 0 end end
			from MAS_Apartments t 
				join [MAS_Service_ReceiveEntry] k on t.ApartmentId = k.ApartmentId
				join MAS_Service_Receipts b on k.ReceiveId = b.ReceiveId
			WHERE  b.ReceiptId = @ReceiptId --and t.ApartmentId = @ApartmentId

			UPDATE t
			   SET [IsPayed] = 0
				  ,PaidAmt = PaidAmt - b.Amount 
				  -- (duongvt) + case when b.TranferCd = 'debit' then t.CreditAmt else 0 end
				  ,CreditAmt = case when b.TranferCd = 'debit' then 0 else t.CreditAmt end
			FROM [MAS_Service_ReceiveEntry] t
			 join MAS_Service_Receipts b on t.ReceiveId = b.ReceiveId
			 WHERE  ReceiptId = @ReceiptId

			 -- Cập nhật trạng thái thanh toán chỉ số điện nước duongvt
			 UPDATE t 
				SET t.IsReceivable = 'False'
				FROM dbo.MAS_Service_ReceiveEntry A
					JOIN dbo.MAS_Service_Receivable b ON a.ReceiveId = b.ReceiveId
					JOIN dbo.MAS_Service_Living_Tracking t ON t.TrackingId = b.srcId
					JOIN dbo.MAS_Service_Receipts c ON a.ReceiveId = c.ReceiveId
				WHERE	c.ReceiptId = @ReceiptId AND b.ServiceTypeId = 3
			

			if exists(select receiptId FROM [MAS_Service_ReceiveEntry] t
				join MAS_Service_Receipts b on t.ReceiveId = b.ReceiveId
				WHERE  ReceiptId = @ReceiptId
					and t.isExpected = 0)
			begin


			delete	trg
			from	MAS_Service_Receipts trg
			where ReceiptId = @ReceiptId

			EXECUTE [dbo].[sp_Hom_Service_Receivable_Del] 
					   @userId
					  ,@receiveId

			end
			else
			begin
			     

			   	 select @receiveId = ReceiveId,
				     @refno = Ref_No,
				     @amtsubtractPoint = AmtSubtractPoint
				 from MAS_Service_Receipts 
				 where ReceiptId = @ReceiptId

                 UPDATE t
                    SET t.lastReceivable = b.fromDt,
                        t.EndTime = t.endTime_Tmp
				 from MAS_CardVehicle t
				 join MAS_Service_Receivable b on t.CardVehicleId = b.srcId
				 where  ReceiveId = @receiveId and b.ServiceTypeId = 2

			          ------- cong lại diem ---------
			   	 insert into [dbo].[WAL_PointOrder_H]
					   ([PointTranId]
					   ,[PointCd]
					   ,[TranType]
					   ,[TransNo]
					   ,[Ref_No]
					   ,[OrderAmount]
					   ,[CreditPoint]
					   ,[Point]
					   ,[CurrPoint]
					   ,[TranDt]
					   ,[OrderInfo]
					   ,[ServiceKey]
					   ,[PosCd]
					   ,[CltId]
					   ,[CltIp]
					   ,[SaveDt]
					   ,SaveBy 
					   )
				 select [PointTranId]
					  ,[PointCd]
					  ,[TranType]
					  ,[TransNo]
					  ,[Ref_No]
					  ,[OrderAmount]
					  ,[CreditPoint]
					  ,[Point]
					  ,[CurrPoint]
					  ,[TranDt]
					  ,[OrderInfo]
					  ,[ServiceKey]
					  ,[PosCd]
					  ,[CltId]
					  ,[CltIp]
					  ,getdate()
					  ,@userId
				  from [dbSHome].[dbo].[WAL_PointOrder]
				  where Ref_No = @refno

				  update p
				  set p.[CurrPoint] = p.CurrPoint + @amtsubtractPoint
						,p.[LastDt] = getdate()
				  from [MAS_Points] p inner join WAL_PointOrder k on p.PointCd = k.PointCd
				  where k.Ref_No = @refno

				  delete FROM [dbo].[WAL_PointOrder]
				  where Ref_No = @refno

				  delete	trg
				  from	MAS_Service_Receipts trg
				  where ReceiptId = @ReceiptId
			end
			
		end
		else
		begin
			set @valid = 0
			set @messages = N'Không tìm thấy biên nhận'
		end

							
		select @valid as valid
		      ,@messages as [messages]
	end try
	begin catch
		declare	@ErrorNum				int,
				@ErrorMsg				varchar(200),
				@ErrorProc				varchar(50),

				@SessionID				int,
				@AddlInfo				varchar(max)

		set @ErrorNum					= error_number()
		set @ErrorMsg					= 'sp_res_Receipt_DelInfo' + error_message()
		set @ErrorProc					= error_procedure()

		set @AddlInfo					= ''

		exec utl_Insert_ErrorLog @ErrorNum, @ErrorMsg, @ErrorProc, 'Receipt', 'DEL', @SessionID, @AddlInfo
	end catch


	--select * from  WAL_PointOrder_H where SaveBy ='hoanpv'

	--select * from MAS_Service_Receipts where TranferCd ='loyaltycard'

	--select * from WAL_PointOrder where Ref_No ='TT-PH-2601-142429258200000'