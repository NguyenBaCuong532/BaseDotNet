









CREATE procedure [dbo].[sp_Pay_Point_Transaction_Withdraw]
	@userId nvarchar(450),
	@ClientId nvarchar(100),
	@ClientIp nvarchar(100),
	@ref_no	nvarchar(100),
	@Point int
as
	begin try	
		declare @valid bit = 1
		DECLARE @messages nvarchar(150) = N'Thu hồi thành công!'
		
		declare @notimessage nvarchar(500)
		declare @mailmessage nvarchar(max)

		DECLARE @PayType nvarchar(50)
		DECLARE @CustId nvarchar(50)
		DECLARE @newRefNo nvarchar(100)
		DECLARE @OrderInfo nvarchar(450)
		--DECLARE @Point int
		DECLARE @CreditPoint int
		DECLARE @OrderAmount int
		DECLARE @ServiceKey nvarchar(50)
		DECLARE @PosCd nvarchar(50)
		DECLARE @roomCode nvarchar(30)

		if not exists(select PointTranId from [WAL_PointOrder] where Ref_No = @ref_no)
		begin
			set @valid = 0
			set @messages = N'Không tìm thấy giao dịch'
		end
		else if exists(select p.CurrPoint from MAS_Points p join [WAL_PointOrder] a on a.PointCd = p.PointCd  where a.Ref_No = @ref_no and p.CurrPoint < @Point )
		begin
			set @valid = 0
			set @messages = N'Số tiền thu hồi lớn hơn số tiền còn lại!, hãy chọn lại ngày thu hồi phù hợp'
		end
		else if exists(select PointTranId from [WAL_PointOrder] where Ref_No = @ref_no + '-1')
		begin
			set @valid = 0
			set @messages = N'Giao dịch đã thực hiện hủy không cho phép thu hồi'
		end
		else
		begin		
		  SELECT @PayType = [TranType]
			  ,@CustId = p.CustId
			  ,@OrderAmount = 0
			  ,@CreditPoint = 0
			  ,@Point = - @Point
			  ,@OrderInfo = N'Thu hồi điểm quá hạn'
			  ,@ServiceKey = [ServiceKey]
			  ,@PosCd = [PosCd]
			  ,@roomCode = [roomCode]
		  FROM [dbSHome].[dbo].[WAL_PointOrder] a
			join MAS_Points p on a.PointCd = p.PointCd 
		  where Ref_No = @ref_no

			if not exists(SELECT Ref_No FROM [dbSHome].[dbo].[WAL_PointOrder]
			where Ref_No = @Ref_No + '-1')
			begin
				set @newRefNo = @Ref_No + '-1'

				EXECUTE [dbo].[sp_Pay_Insert_Wallet_PointOrder] 
					   @UserID
					  ,@PayType
					  ,@CustId
					  ,@newRefNo
					  ,@OrderInfo
					  ,@Point
					  ,@CreditPoint
					  ,@OrderAmount
					  ,@ServiceKey
					  ,@PosCd
					  ,@ClientId
					  ,@ClientIp
					  ,0

				UPDATE p
				   SET isFinal = 1
					FROM [WAL_PointOrder] p
				 WHERE p.Ref_No = @ref_no

				 set @notimessage = N'Nội dung thông báo thu hồi (nội dung notification đến app)'
				 set @mailmessage = N'
					 <div class="row-container" style="font-size:16px">
								<div style="text-align: justify;">
									<h3><u>Kính gửi</u>: Quý khách hàng</h3>
								</div>
								<div class="translate" style="float: left; width: 100%; font-style: italic;">
									<p>P.CSKH Hậu Mãi trân trọng thông báo tới Quý khách thông tin như sau:</p>
								</div>
							<div style="clear: both;"></div>
					</div>
						<div class="row-container"  style="font-size:16px">	 </div>
					</div>
						<div class="row-container"  style="font-size:16px">
							<p>Quà tặng S-mart được kích hoạt thông qua thẻ cư dân của Quý khách đã hết thời hạn sử dụng.</p>
							<p>Kính mong Quý khách sẽ tiếp tục đồng hành với Sunshine Mart để nhận được nhiều ưu đãi và chương trình khuyến mãi</p>
							<p>Nếu có bất kỳ thắc mắc hay yêu cầu hỗ trợ, Quý Khách vui lòng liên hệ theo số Tổng đài: <b>0247.303.7999</b>, Hotline: <b>0888.079.999</b>  </p>
							<p>hoặc qua Email: <b><u>cskh.haumai@sunshinegroup.vn</u></b></p>
							<p>Trân trọng thông báo!</p>
					</div> ' 
			end
			else
			begin
				set @valid = 0
				set @messages = N'Giao dịch đã thực hiện hủy không cho phép Hủy'
			end
		end

		select @valid as valid
		      ,@messages as [messages]
			  

		if @valid = 1
			select N'Thu hồi điểm - Point withdrawal' as [Title]
				  ,N's-pay' as [Event]
				  ,@notimessage as [Message]
				  ,@notimessage as [MessageNotify]
				  --,[dbo].[fuConvertToUnsign1] (@notimessage) as [MessageSms]
				  ,@mailmessage as [MessageEmail]
				  ,'push-notification,email' as [action_list] --sms,email
				  ,'new' as [status]
				  
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
				  ,isnull('cskh@sunshinegroup.vn','no-reply@sunshinemail.vn') as mailSender
				  ,'CSKH' as investorName
				  ,@Ref_No as ref_no
				  ,1 as app
			FROM [MAS_Apartments] a 
				join MAS_Apartment_Member u on a.ApartmentId = u.ApartmentId 
				join MAS_Customers c on u.CustId = c.CustId
				left join UserInfo u2 on u.CustId = u2.custId and u2.userType = 2
			WHERE u.CustId = @CustId
				and u.member_st = 1
				and a.IsReceived = 1
				and (exists(select 1 from UserInfo u1 where u1.custId = u.CustId and u1.loginName = a.UserLogin) or u.isNotification = 1)
				

		

	end try
	begin catch
		declare	@ErrorNum				int,
				@ErrorMsg				varchar(200),
				@ErrorProc				varchar(50),

				@SessionID				int,
				@AddlInfo				varchar(max)

		set @ErrorNum					= error_number()
		set @ErrorMsg					= 'sp_Pay_Point_Transaction_Withdraw' + error_message()
		set @ErrorProc					= error_procedure()

		set @AddlInfo					= '@userId ' + @userId

		exec utl_Insert_ErrorLog @ErrorNum, @ErrorMsg, @ErrorProc, 'Transaction_Withdraw', 'DEL', @SessionID, @AddlInfo
	end catch