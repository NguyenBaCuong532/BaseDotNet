--exec sp_Hom_Service_Receipt_Set null,'01',0,null,'24/10/2020',23352,'5ECB7BBB-69FD-441E-9D76-A585E9841484',6120,'loyaltycard',N'Nguyễn Tiến Dũng',null,null,null,null,null,null,null,null,null

CREATE procedure [dbo].[sp_Hom_Service_Receipt_Set]
		 @UserID	nvarchar(450)
    ,@project_code NVARCHAR(50) = NULL
		,@ProjectCd nvarchar(10)
		,@ReceiptId int 
		,@ReceiptNo nvarchar(50)
		,@ReceiptDate nvarchar(10)
		,@ReceiveId int
		,@CustId nvarchar(50)
		,@ApartmentId int
		,@TranferCd nvarchar(250)
		,@Object nvarchar(200)
		,@PassNo nvarchar(100) 
		,@PassDate nvarchar(22)
		,@PassPlc nvarchar(250) 
		,@Address nvarchar(250) 
		,@Contents nvarchar(350)
		,@Amount decimal(18,0)
		,@Attach nvarchar(50)
		,@IsDBCR bit = 0
	    ,@IsDebit bit = 0
		,@AmtSubtractPoint decimal
as
	begin try	
	declare @valid bit = 1
	declare @messages nvarchar(400) = N'Cập nhật thành công'	
	declare @notification bit = 0
	declare @notimessage nvarchar(400)
	declare @mailmessage nvarchar(max)

	declare @creditAmt decimal(18,0)
	declare @PayType nvarchar(50)
	declare @CardCd nvarchar(50)
	declare @RefNo nvarchar(100)
	declare @OrderInfo nvarchar(50)
	declare @ServiceKey nvarchar(50)
	declare @PosCd nvarchar(50)
	declare @ClientId nvarchar(50)
	declare @ClientIp nvarchar(50)
	declare @roomCode nvarchar(50)

	declare @debitAmtTemp decimal(18,0)
	
	
	set @ReceiptNo = 'H'+ right('000'+ cast( DATEPART(ms,getdate()) as varchar),3) + CAST( DATEDIFF(ss, '2018-01-01', GETUTCDATE()) as varchar) 
	
	if (@ApartmentId =0)
		set @ApartmentId = (select top 1 ApartmentId from MAS_Apartments a inner join UserInfo u on a.UserLogin = u.loginName where u.UserId = @UserID)
    if @ProjectCd is null 
		set @ProjectCd = (select projectCd from MAS_Apartments a where a.ApartmentId = @ApartmentId)
	if @CustId is null or @CustId = ''
		set @CustId = (select custId from UserInfo where UserId = @UserID)
	
	--select * from MAS_Service_Receipts
	if @ReceiptId is null or @ReceiptId = 0
		begin

		set @notification = 0

		if @TranferCd = 'debit'
		begin
			set @debitAmtTemp = (select DebitAmt from [MAS_Service_ReceiveEntry] where ReceiveId = @ReceiveId)
			set @creditAmt = (select totalAmt - paidAmt - creditAmt from [MAS_Service_ReceiveEntry] where ReceiveId = @ReceiveId)
			set @Amount = @creditAmt --+ @debitAmtTemp
			set @Contents = isnull(@Contents,'') + N'(Chuyển nợ)'

			select @notimessage = N'Xác nhận chuyển nợ.'
					+ N' Quý căn [' + a.RoomCode + N'], Dự án ' + b.ProjectName 
					+ N' Khách hàng tên: '+ isnull(u.fullName,'') + N'' 
					+ N' Đã thực hiện chuyển nợ số tiền ['+cast(@Amount as varchar)+'] sang kỳ tiếp theo!'
					+ N' Trân trọng!'
				  ,@mailmessage = N'Xác nhận chuyển nợ.' + '<br />'
					+ N' Quý căn hộ [' + a.RoomCode + N'], Dự án ' + b.ProjectName +  '<br />'
					+ N' Khách hàng tên: '+ isnull(u.fullName,'') + N'' + '<br />'
					+ N' Đã thực hiện chuyển nợ số tiền ['+cast(@Amount as varchar)+'] sang kỳ tiếp theo!'  + '<br />'
					+ N' Trân trọng!'
				FROM MAS_Apartments a
					join MAS_Projects b on a.projectCd = b.projectCd
					join UserInfo u on a.UserLogin = u.loginName
				WHERE a.RoomCode = @roomCode 

		end
		else
		begin
			set @creditAmt = 0

			select @notimessage = N'Xác nhận thanh toán.'
					+ N' Quý căn [' + a.RoomCode + N'], Dự án ' + b.ProjectName 
					+ N' Khách hàng tên: '+ isnull(u.fullName,'') + N'' 
					+ N' Đã thực hiện thanh toán số tiền ['+cast(@Amount as varchar)+'] nội dung: ' + @Contents
					+ N' Trân trọng!'
				  ,@mailmessage = N'Xác nhận chuyển nợ.' + '<br />'
					+ N' Quý căn hộ [' + a.RoomCode + N'], Dự án ' + b.ProjectName +  '<br />'
					+ N' Khách hàng tên: '+ isnull(u.fullName,'') + N'' + '<br />'
					+ N' Đã thực hiện thanh toán số tiền ['+cast(@Amount as varchar)+'] nội dung ' + @Contents + '<br />'
					+ N' Trân trọng!'
				FROM MAS_Apartments a
					join MAS_Projects b on a.projectCd = b.projectCd
					join UserInfo u on a.UserLogin = u.loginName
				WHERE a.RoomCode = @roomCode

		end


			INSERT INTO [dbo].MAS_Service_Receipts
			   ([ReceiptNo]
			   ,[ReceiptDt]
			   ,[CustId]
			   ,[ApartmentId]
			   ,[ReceiveId]
			   ,[TranferCd]
			   ,[Object]
			   ,[Pass_No]
			   ,[Pass_dt]
			   ,[Pass_Plc]
			   ,[Address]
			   ,[Contents]
			   ,[Attach]
			   ,[IsDBCR]
			   ,[Amount]
			   ,[CreatorCd]
			   ,[CreateDate]
			   --,[AccountLeft]
			   --,[AccountRight]
			   ,[ProjectCd]
			   ,AmtSubtractPoint
			   ,Ref_No
			   ,RefundAmt)
		 VALUES
			   (@ReceiptNo
			   ,isnull(convert(datetime,@ReceiptDate,103),getdate())
			   ,@CustId
			   ,@ApartmentId
			   ,@ReceiveId
			   ,@TranferCd
			   ,null
			   ,@PassNo
			   ,convert(datetime,@Passdate,103)
			   ,@PassPlc
			   ,@Address
			   ,@Contents
			   ,@Attach
			   ,@IsDBCR
			   ,@Amount
			   ,@UserID
			   ,getdate()
			   --,@AccountLeft
			   --,@AccountRight
			   ,@ProjectCd
			   ,@AmtSubtractPoint
			   ,@RefNo
			   ,case when @Amount > (select top 1 isnull(TotalAmt,0)  from MAS_Service_ReceiveEntry where ReceiveId = @ReceiveId) 
			    then @Amount - (select top 1 isnull(TotalAmt,0)  from MAS_Service_ReceiveEntry where ReceiveId = @ReceiveId) else 0 end
			   )
			
			set @ReceiptId = @@IDENTITY

			UPDATE t
			   SET [PaidAmt] = isnull(PaidAmt,0) + b.Amount -- @creditAmt
				  ,[IsPayed] = case when isnull(PaidAmt,0) + b.Amount < t.TotalAmt  then 0 else 1 end
				  ,creditAmt = creditAmt + @creditAmt
				  --,t.RefundAmt = b.RefundAmt
				  --,OverAmt = case when @Amount > t.TotalAmt then @Amount - t.TotalAmt else 0 end
				  ,PayedDt = getdate()
			FROM [MAS_Service_ReceiveEntry] t
			 join MAS_Service_Receipts b on t.ReceiveId = b.ReceiveId
			 WHERE  ReceiptId = @ReceiptId

			 if @TranferCd = 'debit'
			begin
				update t
				set t.DebitAmt = @creditAmt,
					t.RefundAmt ='0'
				   ,lastReceived = case when k.CommonFee > 0 then AccrualLastDt else t.lastReceived end
				from MAS_Apartments t 
					join [MAS_Service_ReceiveEntry] k on t.ApartmentId = k.ApartmentId
					join MAS_Service_Receipts b on k.ReceiveId = b.ReceiveId
				  WHERE  b.ReceiptId = @ReceiptId and t.ApartmentId = @ApartmentId

			UPDATE [dbo].[MAS_Service_ReceiveEntry]
			   SET [PaidAmt] = 0
				  ,[IsDebt] = 1
				  ,IsPayed = 0
			 WHERE ReceiveId = @ReceiveId
			end
			else
			begin
				update t
				set  t.DebitAmt = case when isnull(t.DebitAmt,0) - @Amount > 0 then isnull(t.DebitAmt,0) - @Amount else 0 end
				     --,t.RefundAmt = b.RefundAmt -- Triều Dương comment 04012024
					 ,t.RefundAmt='0'
					,lastReceived = case when k.CommonFee > 0 then AccrualLastDt else t.lastReceived end
				from MAS_Apartments t 
					 join [MAS_Service_ReceiveEntry] k on t.ApartmentId = k.ApartmentId
					 join MAS_Service_Receipts b on k.ReceiveId = b.ReceiveId
					 WHERE  b.ReceiptId = @ReceiptId and t.ApartmentId = @ApartmentId
			end

			--if @TranferCd = 'refunddebit'
			--	begin
			--		update t
			--		set t.DebitAmt = t.DebitAmt + @Amount
			--		from MAS_Apartments t 
			--			join [MAS_Service_ReceiveEntry] k on t.ApartmentId = k.ApartmentId
			--			join MAS_Service_Receipts b on k.ReceiveId = b.ReceiveId
			--		  WHERE  b.ReceiptId = @ReceiptId and t.ApartmentId = @ApartmentId
			--	end

			--update accural
			UPDATE t
				SET t.EndTime =  t.lastReceivable
			FROM MAS_CardVehicle t
				join MAS_Service_Receivable b on t.CardVehicleId = b.srcId
				WHERE  ReceiveId = @receiveId and b.ServiceTypeId = 2 and t.ApartmentId = @ApartmentId --and t.Status <> 3


				
			UPDATE t
				SET IsReceivable = 1
			FROM MAS_Service_Living_Tracking t
				join MAS_Service_Receivable b on t.TrackingId = b.srcId
				WHERE  ReceiveId = @receiveId and b.ServiceTypeId = 3

		if @TranferCd ='loyaltycard'
			begin
			set @PayType = N'servicefee'
			
			set @roomCode = (select top 1 RoomCode from MAS_Apartments where ApartmentId = @ApartmentId)
			set @OrderInfo = isnull(@OrderInfo,N'Thanh toán hóa đơn căn hộ : ' + isnull(@roomCode,''))
			set @ClientId = 'web_s_service_prod'
			set @RefNo = 'TT-'+ @roomCode + '-' + cast((CAST(CHECKSUM(NEWID()) AS bigint) * CAST(100000 AS bigint)) as nvarchar(50))
			set @ServiceKey = 'SK002690'
			set @PosCd = (select PosCd from WAL_ServicePOS where ServiceKey = @ServiceKey and projectCd = @ProjectCd)
			    IF not exists(select PointTranId from WAL_PointOrder where Ref_No = @RefNo)
					begin
							 INSERT INTO [dbo].WAL_PointOrder
								   ([PointTranId]
								   ,[PointCd]
								   ,[TransNo]
								   ,[Ref_No]
								   ,[TranType]
								   ,[OrderInfo]
								   ,OrderAmount
								   ,[CreditPoint]
								   ,[Point]
								   ,[TranDt]
								   ,ServiceKey
								   ,PosCd
								   ,[CurrPoint]
								   ,CltId
								   ,CltIp
								   ,roomCode
								   )
							 SELECT
									NEWID()
								   ,p.PointCd
								   ,@roomCode
								   ,@RefNo
								   ,@PayType
								   ,@OrderInfo
								   ,0
								   ,@AmtSubtractPoint
								   ,0
								   ,getdate()
								   ,@ServiceKey
								   ,@PosCd
								   ,p.[CurrPoint]
								   ,@ClientId 
								   ,@ClientIp
								   ,@roomCode
							 FROM MAS_Points p 
							 WHERE CustId = @custId

							 update MAS_Service_Receipts
							 set Ref_No = @RefNo
							 where ReceiptId = @ReceiptId
			 
							 UPDATE p
							   SET [CurrPoint] = CurrPoint - @AmtSubtractPoint
								  ,[LastDt] = getdate()
								FROM [MAS_Points] p
							 WHERE p.CustId = @custId
						
					end
				
			end

		end
		ELSE
		begin
			UPDATE t
			   SET [PaidAmt] = isnull(PaidAmt,0) + b.Amount --+ @Amount
				  ,[IsPayed] = case when isnull(PaidAmt,0) + b.Amount  < t.TotalAmt then 0 else 1 end
				  --, IsPayed = 1
				  ,PayedDt = getdate()
			FROM [MAS_Service_ReceiveEntry] t
			 join MAS_Service_Receipts b on t.ReceiveId = b.ReceiveId
			 WHERE  ReceiptId = @ReceiptId

			UPDATE [dbo].MAS_Service_Receipts
			   SET [ReceiptNo] = @ReceiptNo
				  ,[ReceiptDt] = convert(datetime,@ReceiptDate,103)
				  ,CustId = @CustId
				  ,[ApartmentId] = @ApartmentId
				  --,[TranferCd] = @TranferCd
				  ,[Object] = case when @Object = '' then null else @Object end
				  ,[Pass_No] = @PassNo
				  ,[Pass_dt] = convert(datetime,@Passdate,103)
				  ,[Pass_Plc] = @PassPlc
				  ,[Address] = @Address
				  ,[Contents] = @Contents
				  ,[Attach] = @Attach
				  ,[IsDBCR] = @IsDBCR
				  --,[Amount] = @Amount
				  ,[CreatorCd] = @UserID
			 WHERE ReceiptId  = @ReceiptId
		end
		
		select @valid as valid
		      ,@messages as [messages]
			  ,@notification as notiQue
			  ,@ReceiveId as work_st

		if @notification = 1
		begin
			
			select N'Xác nhận thanh toán - Apartment Payment' as [subject]
				  ,N's-resident' as external_key--[Event]
				  ,@notimessage as content_notify
				  ,@mailmessage as content_email --[MessageEmail]
				  ,'push,email' as [action_list] --sms,email
				  ,'new' as [status]
				  ,@userId as userId
				  ,a.projectCd as external_sub
				  ,[mailSender] as send_by
				  ,[investorName] as send_name
			FROM MAS_Apartments a
				join MAS_Projects b on a.sub_projectCd = b.sub_projectCd
				WHERE a.RoomCode = @roomCode

			

					
			select u2.[userId] 
				  ,u2.phone 
				  ,u2.email
				  ,u2.avatarUrl as Avatar
				  ,u2.fullName
				  ,1 as app
				  ,u.CustId
			FROM [MAS_Apartments] a 
				join MAS_Apartment_Member u on a.ApartmentId = u.ApartmentId 
				join UserInfo u2 on u.CustId = u2.custId and u2.userType = 2
			WHERE a.RoomCode = @roomCode
				and u.member_st = 1
				and a.IsReceived = 1
				and exists(select 1 from UserInfo u1 where u1.custId = u.CustId and u1.loginName = a.UserLogin)
				--and @RelationId > 1

		end
						

		exec sp_Hom_Service_Receipt_ByReceiveId @userId, @ReceiveId

	end try
	begin catch
		declare	@ErrorNum				int,
				@ErrorMsg				varchar(200),
				@ErrorProc				varchar(50),

				@SessionID				int,
				@AddlInfo				varchar(max)

		set @ErrorNum					= error_number()
		set @ErrorMsg					= 'sp_Hom_Service_Receipt_Set ' + error_message()
		set @ErrorProc					= error_procedure()

		set @AddlInfo					= '@CustId ' + @CustId 

		exec utl_Insert_ErrorLog @ErrorNum, @ErrorMsg, @ErrorProc, 'MAS_Receipts', 'Insert', @SessionID, @AddlInfo
	end catch

	--select * from MAS_Apartments where ApartmentId = 6120

	--select * from utl_Error_Log where TableName ='Receipts' order by CreatedDate desc

	--select * from MAS_Service_ReceiveEntry where ApartmentId = 6120
	--select * from MAS_Apartments where ApartmentId = 6120