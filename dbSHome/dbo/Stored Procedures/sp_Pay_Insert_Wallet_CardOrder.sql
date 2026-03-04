







CREATE procedure [dbo].[sp_Pay_Insert_Wallet_CardOrder]
	@UserID	nvarchar(450),
	@PayType nvarchar(50),
	@CardNum nvarchar(50),
	@RefNo nvarchar(100),
	@OrderInfo nvarchar(450),
	@Point int,
	@CreditPoint int,
	@OrderAmount int,
	@ServiceKey nvarchar(50),
	@PosCd nvarchar(50),
	@ClientId nvarchar(100),
	@ClientIp nvarchar(100),
	@roomCode nvarchar(30) = null,
	@notiQue bit = 0
as
	begin try		
		declare @mailmessage nvarchar(max)
		declare @notimessage nvarchar(300)
		declare @CurrPoint decimal(18,0)
		declare @LastPoint decimal(18,0)
		DECLARE @newpoint bigint
		declare @codeCode nvarchar(30)
		declare @custId nvarchar(50)
		declare @bigsale bit
		declare @Pos_name nvarchar(200)
		declare @PointCd nvarchar(100)
		declare @sendby nvarchar(200)

		--set @bigsale = 0

		--if @bigsale = 1 
		--begin
		--	set @Point = round((@OrderAmount-@CreditPoint)/10,0)
		--end
		if CHARINDEX('qrcode',@CardNum,0)>0
		begin
			set @codeCode = SUBSTRING(@CardNum, 7, LEN(@CardNum) - 6)	
			set @PayType = 'ksfpoint'
			set @custId = (select top 1 custId from UserInfo a where referralCd = @codeCode and a.idcard_verified = 1 and a.userType = 3)
			if not exists(select 1 from MAS_Customers where custid = @custId)
				INSERT INTO [dbo].[MAS_Customers]
				   (CustId
				   ,[FullName]
				   ,[Phone]
				   ,[Email]
				   ,[AvatarUrl]
				   ,[IsSex]
				   ,birthday
				   ,ProvinceCd
				   ,IsForeign
				   ,CountryCd
				   ,Pass_No
				   ,Pass_Dt
				   ,Pass_Plc
				   ,sysDate
				   ,[Address]
				   )
			 select a.custId
				   ,a.fullName
				   ,a.phone
				   ,a.email
				   ,a.avatarUrl
				   ,a.sex
				   ,a.birthday
				   ,a.res_city
				   ,case when a.res_cntry = 'VN' then 0 else 1 end 
				   ,a.res_cntry
				   ,a.idcard_no
				   ,a.idcard_issue_dt
				   ,a.idcard_issue_plc
				   ,getdate()
				   ,a.res_add
			  from UserInfo a 
				where custid = @custId

			set @PointCd = (SELECT p.PointCd FROM MAS_Points p WHERE p.CustId = @custId)

			if @Point > 250000 set @Point = 250000

			if @PointCd is not null and @Point + isnull((select sum(Point) from WAL_PointOrder where TranType = @PayType and PointCd = @PointCd),0) > 250000
				set @Point =  250000 - isnull((select sum(Point) from WAL_PointOrder where TranType = @PayType and PointCd = @PointCd),0)
			

		end
		else
		if len(@CardNum) = 8
		begin
			set @codeCode = @CardNum
			set @custId = (select custId from CRM_Card where CardCd = @codeCode)
			if @CardNum = '00000114' or @CardNum = '00000115'
			begin
				set @Point = 0
				set @CreditPoint = 0
			end
		end 
		else
		begin 
			if len(@CardNum) <> 6
				set @codeCode = (select top (1) Code from MAS_CardBase where Card_Num = @CardNum)
			else
				set @codeCode = @CardNum
			set @custId = (select custId from MAS_Cards where CardCd = @codeCode)
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

		IF not exists(select PointTranId from WAL_PointOrder where Ref_No = @RefNo and [TransNo] = @codeCode)
		BEGIN
			SELECT @CurrPoint = CurrPoint
				FROM [MAS_Points] p
			 WHERE p.CustId = @custId
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
				   ,roomCode
				   )
			 SELECT
				    NEWID()
				   ,p.PointCd
				   ,@codeCode
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
				   ,@roomCode
			 FROM MAS_Points p 
			 WHERE CustId = @custId
			 
			 set @LastPoint = @CurrPoint+@Point-@CreditPoint
			 UPDATE p
			   SET [CurrPoint] = @LastPoint --CurrPoint+@Point-@CreditPoint
				  ,[LastDt] = getdate()
				FROM [MAS_Points] p
			 WHERE p.CustId = @custId

			if @notiQue = 1
			begin
			set @notimessage = N'SunshineMart ' + format(getdate(),'dd/MM/yyyy HH:mm:ss')
				+ case when CHARINDEX('qrcode',@CardNum,0)>0 then N'Mã giới thiệu: ' + @codeCode else N'Số Thẻ: ' + @codeCode end
				+ N'Mua hàng tại ' + @Pos_name 
				+ N'Số dư trước giao dịch: ' + replace(format(@CurrPoint,'###.###.##0'),',','.') + N' điểm'
				+ N'Số điểm được tích: ' + replace(format(@Point,'###.###.##0'),',','.') + N' điểm'
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
				  ,'push-notification,email' as [action_list] --sms,email
				  ,'new' as [status]
				  --,'sms,email' as [action_list] --push-notification,sms,email
				  --,'new' as [status]

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
			FROM MAS_Customers c 
				left join UserInfo u2 on c.CustId = u2.custId and u2.userType = 2
			WHERE c.CustId = @CustId
		end

		END 
		


		--END
	end try
	begin catch
		declare	@ErrorNum				int,
				@ErrorMsg				varchar(200),
				@ErrorProc				varchar(50),

				@SessionID				int,
				@AddlInfo				varchar(max)

		set @ErrorNum					= error_number()
		set @ErrorMsg					= 'sp_Pay_Insert_Wallet_CardOrder ' + error_message()
		set @ErrorProc					= error_procedure()

		set @AddlInfo					= '@SCard ' 

		exec utl_Insert_ErrorLog @ErrorNum, @ErrorMsg, @ErrorProc, 'SCard', 'Insert', @SessionID, @AddlInfo
	end catch