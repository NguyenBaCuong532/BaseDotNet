








CREATE procedure [dbo].[sp_Pay_Point_Voucher_Push]
	@userId nvarchar(450),
	@ref_Nos	nvarchar(max),
	@expire_dt	nvarchar(20)
as
	begin try

					
			SELECT 0 as Id
			      --,N'BQLTN ' + c.ProjectName + N' thông báo phí sử dụng căn hộ ' + ma.RoomCode + N' tính đến ' + convert(nvarchar(10),t.ToDt,103) as title
				  ,N'Thông báo về thời hạn sử dụng quà tặng S-Smart' as title
				  ,N'CSKH ' + N' ngày hết hạn quà tặng S-Smart ' + c.FullName + N'' 
				   + N' tính đến ' + convert(nvarchar(10),@expire_dt,103) + '. ' 
				   + N'Qúy Khách ' + c.FullName + N' '
				   + N'T. ' 
				   + 'Quý Khách vui lòng sử dụng trước ngày ' + convert(nvarchar(10),@expire_dt,103)
				   + N'Trân trọng cảm ơn!' as [Message]
				  
				   ,[dbo].[fChuyenCoDauThanhKhongDau] (N'CSKH ' + N' ngày hết hạn sử dụng quà tặng S-Smart ' + c.FullName + N'' 
				   + N' tính đến ' + convert(nvarchar(10),@expire_dt,103) + '. ' 
				   + N'Qúy Khách ' + c.FullName + N' '
				   + N'T. ' 
				   + 'Quý Khách vui lòng sử dụng trước ngày ' + convert(nvarchar(10),@expire_dt,103)
				   + N'Trân trọng cảm ơn!') as MessageSms

				  ,N' 
						<div class="row-container" style="font-size:16px">
							<div style="text-align: justify;">
								<h3><u>Kính gửi ông/bà:</u> ' + c.FullName + N'</h3>
							</div>
							<div class="translate" style="float: left; width: 100%; font-style: italic;font-family:auto">
								<p>Lời đầu tiên, P.CSKH hậu mãi – Tập đoàn Sunshine kính gửi tới Quý khách lời cảm ơn chân thành vì đã đồng hành cùng chúng tôi trong suốt thời gian qua.</p>
							</div>
							<div style="clear: both;"></div>
						</div>
						<div class="row-container"  style="font-size:16px">								
					  </div>
					</div>
						<div class="row-container"  style="font-size:16px">
							<p>P.CSKH Hậu Mãi trân trọng thông báo tới Quý khách thông tin liên quan đến quà tặng S-mart được kích hoạt thông qua thẻ cư dân của Quý khách sẽ hết hạn sau <b>30</b> ngày.</p>
							<p>Sau thời hạn quy định trên, các quà tặng được kích hoạt vào thẻ cư dân sẽ hết hiệu lực sử dụng và Chủ đầu tư sẽ không chịu trách nhiệm về các vấn đề phát sinh liên quan.</p>
							<p>Nếu có bất kỳ thắc mắc hay yêu cầu hỗ trợ, Quý Khách vui lòng liên hệ theo số Tổng đài: <b>0247.303.7999</b>, Hotline: <b>0888.079.999</b>  </p>
							<p>hoặc qua Email: <b><u>cskh.haumai@sunshinegroup.vn</u></b></p>
							<p>Trân trọng thông báo!</p>
					</div> ' 
	
	            as [MessageEmail]
				  ,'sms,email' as [action_list] --push-notification,sms,email
				  ,'new' as [status]
				  ,c.Phone 
				  ,c.Email 
				  --,'0988686022' as phone
				  --,'duong0106xp@gmail.com' as Email
				  ,c.FullName 
				  ,a.userId
				  ,a.avatarUrl as AvatarUrl
				  ,c.CustId
				  ,null as attach_file
				  ,isnull('cskh@sunshinegroup.vn','no-reply@sunshinemail.vn') as mailSender
				  ,'CSKH' as investorName
				  ,wa.Ref_No as ref_no
			from MAS_Points mp
				join MAS_Customers c on c.CustId = mp.CustId
				join [WAL_PointOrder] wa on mp.PointCd = wa.PointCd
				left join WAL_Services s on wa.ServiceKey = s.ServiceKey
				left join WAL_ServicePOS p on p.PosCd = wa.PosCd
				left join UserInfo a on mp.CustId = a.custId and a.userType = 2
			 WHERE wa.expireDt < dateadd(day,10,getdate()) and (isFinal is null or isFinal = 0)
				and wa.TranType = 'voucher'
				--and IsBill = 1
				and wa.Ref_No in (SELECT part FROM [dbo].[SplitString](@ref_Nos,',')) 
		
			update wa
				set push_st = isnull(push_st,0)+1
				,push_dt = getdate()
				,push_exp_dt = convert(nvarchar(10),@expire_dt,103)
			from MAS_Points mp
				join MAS_Customers c on c.CustId = mp.CustId
				join [WAL_PointOrder] wa on mp.PointCd = wa.PointCd
				left join WAL_Services s on wa.ServiceKey = s.ServiceKey
				left join WAL_ServicePOS p on p.PosCd = wa.PosCd
			 WHERE wa.expireDt < dateadd(day,10,getdate()) and (isFinal is null or isFinal = 0)
				and wa.TranType = 'voucher'
				--and IsBill = 1
				and wa.Ref_No in (SELECT part FROM [dbo].[SplitString](@ref_Nos,',')) 

	end try
	begin catch
		declare	@ErrorNum				int,
				@ErrorMsg				varchar(200),
				@ErrorProc				varchar(50),

				@SessionID				int,
				@AddlInfo				varchar(max)

		set @ErrorNum					= error_number()
		set @ErrorMsg					= 'sp_Pay_Point_Voucher_Push' + error_message()
		set @ErrorProc					= error_procedure()

		set @AddlInfo					= ''

		exec utl_Insert_ErrorLog @ErrorNum, @ErrorMsg, @ErrorProc, 'Receivable', 'Bill', @SessionID, @AddlInfo
	end catch