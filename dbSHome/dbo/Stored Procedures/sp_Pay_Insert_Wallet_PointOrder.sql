CREATE procedure [dbo].[sp_Pay_Insert_Wallet_PointOrder]
	@UserID	nvarchar(450),
	@PayType nvarchar(50),
	@CustId nvarchar(50),
	@RefNo nvarchar(100),
	@OrderInfo nvarchar(450),
	@Point int,
	@CreditPoint int,
	@OrderAmount int,
	@ServiceKey nvarchar(50),
	@PosCd nvarchar(50),
	@ClientId nvarchar(100),
	@ClientIp nvarchar(100),
	@notiQue bit = 0

as
	begin try		
		declare @mailmessage nvarchar(max)
		declare @notimessage nvarchar(300)
		declare @CurrPoint decimal(18,0)
		declare @LastPoint decimal(18,0)
		DECLARE @newpoint bigint
		declare @codeCode nvarchar(30)
		declare @bigsale bit
		declare @Pos_name nvarchar(200)

		DECLARE @sendby nvarchar(200)
		--declare @bigsale bit
		set @bigsale = 0
		--set @notiQue = 0
		if @bigsale = 1 
		begin
			set @Point = round((@OrderAmount-@CreditPoint)/10,0)
		end
		
		if not exists(SELECT p.PointCd
			 FROM MAS_Points p 
			 WHERE p.CustId = @custId
			 )
			BEGIN
				set @newpoint = CAST(RAND(CHECKSUM(NEWID())) * 1000000000 as INT)
				WHILE exists(select pointCd from [MAS_Points] where PointCd = @newpoint)
				BEGIN
					set @newpoint = CAST(RAND(CHECKSUM(NEWID())) * 1000000000 as INT)
				END
					INSERT INTO [dbo].[MAS_Points]
						([PointCd]
						,[PointType]
						,[CustId]
						,[CurrPoint]
						,[LastDt])
					VALUES(
						 @newpoint
						,0
						,@custId
						,0
						,getdate()
						)
			END

		IF not exists(select PointTranId from WAL_PointOrder where Ref_No = @RefNo and [TransNo] = 'SPOINT')
		BEGIN
			select @codeCode = PointCd,
				@CurrPoint = CurrPoint  from [MAS_Points] where CustId = @CustId
			select @Pos_name = PosName from [WAL_ServicePOS] where PosCd = @PosCd

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
				   )
			 SELECT
				    NEWID()
				   ,p.PointCd
				   ,'SPOINT'
				   ,@RefNo
				   ,@PayType
				   ,@OrderInfo
				   ,@OrderAmount
				   ,@CreditPoint
				   ,@Point
				   ,getdate()
				   ,@ServiceKey
				   ,@PosCd
				   ,[CurrPoint]
				   ,@ClientId 
				   ,@ClientIp
			 FROM MAS_Points p 
			 WHERE CustId = @custId

			 set @LastPoint = @CurrPoint+@Point-@CreditPoint

			 UPDATE p
			   SET [CurrPoint] = @LastPoint
				  ,[LastDt] = getdate()
				FROM [MAS_Points] p
			 WHERE p.CustId = @custId

			 
		END 
		if @notiQue = 1
		begin
			set @notimessage = N'S-Mart ' + format(getdate(),'dd/MM/yyyy HH:mm:ss')
				+ N'Mã tích điểm: ' + @codeCode
				+ N'Mua hàng tại ' + @Pos_name 
				+ N'Số dư trước giao dịch: ' + replace(format(@CurrPoint,'###.###.##0'),',','.') + N' điểm'
				+ N'Phát sinh tiêu: ' + replace(format(@CreditPoint,'###.###.##0'),',','.') + N' điểm'
				+ N'Số dư hiện tại: ' + replace(format(@LastPoint,'###.###.##0'),',','.') + N' điểm'

			select @mailmessage = N'
					 <div class="row-container" style="font-size:16px">
								<div style="text-align: justify;">
									<h3><u>Kính gửi</u>: Quý khách hàng</h3>
								</div>
								<div class="translate" style="float: left; width: 100%; font-style: italic;">
									<p>' + N'SunshineMart ' + format(getdate(),'dd/MM/yyyy HH:mm:ss')+'</p>
								</div>
							<div style="clear: both;"></div>
					</div>
						<div class="row-container"  style="font-size:16px">	 </div>
					</div>
						<div class="row-container"  style="font-size:16px">
							<p>'+ N'Số Thẻ: ' + @codeCode +'</p>
							<p>'+ N'Mua hàng tại ' + @Pos_name +'</p>
							<p>'+ N'Số dư trước giao dịch: ' + replace(format(@CurrPoint,'###,###,##0'),',','.') + N' điểm' +N'</p>
							<p>'+ N'Số điểm được tích: ' + replace(format(@Point,'###,###,##0'),',','.') + N' điểm' + N'</p>
							<p>'+ N'Phát sinh tiêu: ' + replace(format(@CreditPoint,'###,###,##0'),',','.') +N'</p>
							<p>'+ N'Số dư hiện tại: ' + replace(format(@LastPoint,'###,###,##0'),',','.') + N' điểm' +N'</p>
							<p>Nếu có bất kỳ thắc mắc hay yêu cầu hỗ trợ, Quý Khách vui lòng liên hệ theo số Hotline: <b>'+a.hotline+'</b>  </p>
							<p>hoặc qua Email: <b><u>'+a.email+'</u></b></p>
							<p>Trân trọng thông báo!</p>
					</div> ' 
					,@sendby = a.email
				from WAL_ServicePOS a
					where PosCd = @PosCd

			select N'Thông báo tiêu điểm' as [Title]
				  ,N's-pay' as [Event]
				  ,@notimessage as [Message]
				  ,@notimessage as [MessageNotify]
				  --,[dbo].[fuConvertToUnsign1] (@notimessage) as [MessageSms]
				  ,@mailmessage as [MessageEmail]
				  
				  ,'sms,email' as [action_list] --push-notification,sms,email
				  ,'new' as [status]

				  ,c.Phone 
				  ,c.Email 
				  --,'0988686022' as phone
				  --,'duong0106xp@gmail.com' as Email
				  ,c.FullName
				  ,u2.userId
				  ,u2.avatarUrl as AvatarUrl
				  ,c.CustId
				  ,null as attach_file
				  ,@sendby as mailSender
				  ,'CSKH' as investorName
				  ,@RefNo as ref_no
				  ,1 as app
			FROM [MAS_Apartments] a 
				join MAS_Apartment_Member u on a.ApartmentId = u.ApartmentId 
				join MAS_Customers c on u.CustId = c.CustId
				left join UserInfo u2 on u.CustId = u2.custId and u2.userType = 2
			WHERE u.CustId = @CustId
				and u.member_st = 1
				and a.IsReceived = 1
				and (exists(select 1 from UserInfo u1 where u1.custId = u.CustId and u1.loginName = a.UserLogin) or u.isNotification = 1)
		end

		--END
	end try
	begin catch
		declare	@ErrorNum				int,
				@ErrorMsg				varchar(200),
				@ErrorProc				varchar(50),

				@SessionID				int,
				@AddlInfo				varchar(max)

		set @ErrorNum					= error_number()
		set @ErrorMsg					= 'sp_Pay_Insert_Wallet_PointOrder ' + error_message()
		set @ErrorProc					= error_procedure()

		set @AddlInfo					= '@SPoint ' + @custId

		exec utl_Insert_ErrorLog @ErrorNum, @ErrorMsg, @ErrorProc, 'SPoint', 'Insert', @SessionID, @AddlInfo
	end catch