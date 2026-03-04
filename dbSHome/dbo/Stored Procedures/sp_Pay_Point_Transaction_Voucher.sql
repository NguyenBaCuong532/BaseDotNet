








CREATE procedure [dbo].[sp_Pay_Point_Transaction_Voucher]
	@userId		nvarchar(450),
	@ClientId	nvarchar(100),
	@ClientIp	nvarchar(100),
	@custId		nvarchar(50),
	@PointCd	nvarchar(50),
	@point		decimal(18,0),
	@OrderInfo	nvarchar(100),
	@CardCd		nvarchar(50),
	@Ref_No		nvarchar(50),
	@ServiceKey	nvarchar(50),
	@PosCd		nvarchar(50),
	@roomCode	nvarchar(30) = null,
	@expireDate	nvarchar(10) = null

as
	begin try	
		set @ClientId = 'web_s_crm_prod'

		declare @valid bit = 1
		declare @messages nvarchar(150)
		declare @notimessage nvarchar(300)

		declare @custName nvarchar(250)
		declare @currPoint decimal(18,0)
		DECLARE @PayType nvarchar(50)
		DECLARE @RefNo nvarchar(100)

		if @roomCode is null or @roomCode = ''
		set @roomCode = (SELECT top 1 d.RoomCode
			  FROM MAS_Cards c 
				  join UserInfo u on u.CustId = c.CustId
				  join MAS_Apartments d on d.UserLogin = u.loginName --and c.ApartmentId = d.ApartmentId 
				  join MAS_Apartment_Card cc on cc.CardId = c.CardId and cc.ApartmentId = d.ApartmentId 
			  where c.CardCd = @CardCd)
		
		set @PayType = 'voucher'
		set @RefNo = 'KM-' + @CardCd + N'-'+ @Ref_No
		set @OrderInfo = isnull(@OrderInfo,N'Tặng điểm k/h căn: ' + isnull(@roomCode,''))
		if exists(select PointTranId from [WAL_PointOrder] where Ref_No = @RefNo)
		begin
			set @valid = 0
			set @messages = N'Đã tồn tại mã giao dịch!'
		end
		else if (select count(PointTranId) from [WAL_PointOrder] where PointCd = @PointCd and TranType = @PayType and dateadd(day,30,TranDt) >= getdate()) >= 3
		begin
			set @valid = 0
			set @messages = N'Số giao dịch tích điểm quá nhiều trong 30 tháng!'
		end
		else if (select sum(Point) from [WAL_PointOrder] where PointCd = @PointCd and TranType = @PayType and dateadd(day,30,TranDt) >= getdate()) >= 200000000
		begin
			set @valid = 0
			set @messages = N'Số tiền tích điểm quá 200tr trong 30 ngày!'
		end else if not exists(SELECT a.CardId
			  FROM MAS_Cards a where a.CardCd = @CardCd 
				and a.CustId = @custId and (a.CardTypeId <=3 Or (a.CardTypeId = 4 and a.IsVip = 1) and a.Card_St = 1))
		begin
			set @valid = 0
			set @messages = N'Thông tin thẻ và khách hàng không hợp lệ!'
		end
		else
		begin		
		  EXECUTE [dbo].[sp_Pay_Insert_Wallet_CardOrder] 
			   @UserID
			  ,@PayType
			  ,@CardCd
			  ,@RefNo
			  ,@OrderInfo
			  ,@Point
			  ,0
			  ,0
			  ,@ServiceKey
			  ,@PosCd
			  ,@ClientId
			  ,@ClientIp
			  ,@roomCode
			  ,0
		end
		
		select @valid as valid
		      ,@messages as [messages]
			  ,1 as notiQue

		select  @custName = fullName, @currPoint = b.CurrPoint from MAS_Customers a
			join MAS_Points b on a.CustId = b.CustId
			where a.CustId = @custId 

		set @notimessage = N'THÔNG BÁO TẶNG ĐIỂM' +  '<br />' + '<br />' 
			+ N'Khách hàng: ' + @custName
			+ case when @roomCode is not null then N' Căn hộ ' + isnull(@roomCode,'') + '<br />' else '' end
			+ N' Tổng số điểm tặng: ' + format(@point,'###,###,###') + '<br />'
			+ N'Nội dung ['+ @OrderInfo + ']'+ '<br />'
			+ N'Số điểm sau giao dịch: ' + format(@currPoint,'###,###,###') + '<br />'
			+ N'Trân trọng!'

		select N'Xác nhận tích điểm - Sunshine Pay' as [Title]
				  ,N's-fintech-finance' as [Event]
				  ,@notimessage as [Message]
				  ,@notimessage as [MessageNotify]
				  ,[dbo].[fChuyenCoDauThanhKhongDau] (@notimessage) as [MessageSms]
				  ,@notimessage as [MessageEmail]
				  ,'push-notification,email' as [action_list] --push-notification,sms,email
				  ,'new' as [status]
				  ,getdate() as CreatedDate
				
			select userId 
				  ,phone 
				  ,email 
				  ,avatarUrl as Avatar
				  ,fullName 
				  ,a.custId
			from UserInfo a
			where a.email is not null and a.email <> '' and a.phone = '0988686022'


	end try
	begin catch
		declare	@ErrorNum				int,
				@ErrorMsg				varchar(200),
				@ErrorProc				varchar(50),

				@SessionID				int,
				@AddlInfo				varchar(max)

		set @ErrorNum					= error_number()
		set @ErrorMsg					= 'sp_Pay_Point_Transaction_Voucher' + error_message()
		set @ErrorProc					= error_procedure()

		set @AddlInfo					= '@userId ' + @userId

		exec utl_Insert_ErrorLog @ErrorNum, @ErrorMsg, @ErrorProc, 'Point_Transaction', 'DEL', @SessionID, @AddlInfo
	end catch