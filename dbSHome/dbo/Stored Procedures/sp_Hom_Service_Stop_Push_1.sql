






-- exec sp_Hom_Service_Stop_Push null,6120

CREATE procedure [dbo].[sp_Hom_Service_Stop_Push]
	@userId nvarchar(450),
	@apartmentIds	nvarchar(max)
	--@ProjectCd nvarchar(30)
as
	begin try

		
			
			SELECT t.ReceiveId as Id,
			
			      --,N'BQLTN ' + c.ProjectName + N' thông báo phí sử dụng căn hộ ' + ma.RoomCode + N' tính đến ' + convert(nvarchar(10),t.ToDt,103) as title
				  N'BQLTN ' + c.ProjectName + N'  Thông báo ngừng cung cấp dịch vụ '  + ma.RoomCode as title
				  --,N'BQLTN ' + c.ProjectName + N' Thông báo ngừng cung cấp dịch vụ điện, nước và xe căn hộ ' + ma.RoomCode + N'' 				   
				  -- + N' Ban QLTN ' + c.ProjectName + N' đã gửi thông báo tới quý Ông/Bà ' + d.FullName + N' - '+ ma.RoomCode 
				  -- + N' bằng thông báo lần 01 ngày ' + convert(nvarchar(10),c.dayOfNotice1,103) + N', thông báo lần 02 ngày ' + convert(nvarchar(10),c.dayOfNotice2,103) + N', thông báo lần 03 ngày ' + convert(nvarchar(10),c.dayOfNotice3,103) + N' V/v đóng tiền điện, nước tháng ' +  cast(month(t.ToDt) as nvarchar(5)) + '/' + cast(year(t.ToDt) as nvarchar(5)) + N' và gửi xe tháng ' + case MONTH(t.ToDt) when 12 then  '1/' + cast(year(t.ToDt) + 1 as nvarchar(5)) else cast(month(t.ToDt) + 1 as nvarchar(5)) + '/' + cast(year(t.ToDt) as nvarchar(5)) end +N' nhưng đến nay, Ban QLTN vẫn chưa nhận được đủ các chi phí nêu trên từ quý Ông/Bà'
				  -- + N' Trân trọng cảm ơn!' as [Message]
                  , N' Ban QLTN ' + c.ProjectName + N' đã gửi thông báo tới quý Ông/Bà ' + d.FullName + N' - '+ ma.RoomCode 
				   + N' bằng thông báo lần 01 ngày ' + convert(nvarchar(10),c.dayOfNotice1,103) + N', V/v đóng tiền điện, nước tháng ' +  cast(month(t.ToDt) as nvarchar(5)) + '/' + cast(year(t.ToDt) as nvarchar(5)) + N' và gửi xe tháng ' + case MONTH(t.ToDt) when 12 then  '1/' + cast(year(t.ToDt) + 1 as nvarchar(5)) else cast(month(t.ToDt) + 1 as nvarchar(5)) + '/' + cast(year(t.ToDt) as nvarchar(5)) end +N' nhưng đến nay, Ban QLTN vẫn chưa nhận được đủ các chi phí nêu trên từ quý Ông/Bà'
				   + N' Trân trọng cảm ơn!' as [Message]
				  
				  ,[dbo].[fChuyenCoDauThanhKhongDau] ( N'Ban QLTN ' + c.ProjectName + N' đã gửi thông báo tới quý Ông/Bà ' + d.FullName + N' - '+ ma.RoomCode 
				   + N' bằng thông báo lần 01 ngày ' + convert(nvarchar(10),c.dayOfNotice1,103) + N', V/v đóng tiền điện, nước tháng ' +  cast(month(t.ToDt) as nvarchar(5)) + '/' + cast(year(t.ToDt) as nvarchar(5)) + N' và gửi xe tháng ' + case MONTH(t.ToDt) when 12 then  '1/' + cast(year(t.ToDt) + 1 as nvarchar(5)) else cast(month(t.ToDt) + 1 as nvarchar(5)) + '/' + cast(year(t.ToDt) as nvarchar(5)) end +N' nhưng đến nay, Ban QLTN vẫn chưa nhận được đủ các chi phí nêu trên từ quý Ông/Bà'
				   + N'Trân trọng cảm ơn!') as MessageSms

				  ,N' 
				<div style="font-size:18px;width:1000px;font-family:none">
						<table border="0" style="margin-left:auto;margin-right:auto;width:100%">
							<tr>
								<th>CÔNG TY CP QL&VH S-SERVICE</th>
								<th>CỘNG HÒA XÃ HỘI CHỦ NGHĨA VIỆT NAM</th>
							</tr>
							<tr>
								<th>BQL TÒA NHÀ</td>
								<th>Độc lập - Tự do - Hạnh phúc</td>
							</tr>
							<tr>
								<th >' + Upper(c.ProjectName) + N'</td>
								<th>--------------</td>
							</tr>
							<tr>
								<td></td>
							<td style="text-align:center">Hà Nội </td>
							</tr>
						</table>
					<div style="text-align:center">
						<h2>THÔNG BÁO<h2>
						<h3> V/v: Ngừng cung cấp dịch vụ <h3>
					</div>

					<div class="row-container">
						<div style="margin-bottom: 40px; text-align: justify;">
						<h3 style="font-size: 1.1em;"><b>&nbsp;&nbsp;&nbsp;&nbsp;<u><i>Kính gửi:</i></u> Ông/Bà: ' + d.FullName + N'  – Căn hộ: '+ ma.RoomCode + N' </b></h3>
					</div>

					<div class="translate" style="float: left; width: 87%; font-style: italic;">
						<p>&nbsp;&nbsp;&nbsp;&nbsp;Lời đầu tiên, Ban Quản lý tòa nhà (Ban QLTN) ' + c.ProjectName + N' xin được gửi lời chúc sức khỏe và lời chào trân trọng nhất tới Ông/Bà: ' + d.FullName + N'  – Căn hộ: '+ ma.RoomCode + N' .</p>
					</div>

					<div style="clear: both;"></div>
			</div>
		
			 <div class="row-container">
						<p><style="font-size: 1.1em; text-align: justify;">&nbsp;&nbsp;&nbsp;&nbsp;Ban QLTN Sunshine ' + c.ProjectName + N' đã gửi thông báo tới quý Ông/Bà <b>' + d.FullName + N'  – Căn hộ: '+ ma.RoomCode + N'</b> bằng thông báo lần 01 ngày ' + convert(nvarchar(10),c.dayOfNotice1,103) + N', 
							thông báo lần 02 ngày ' + convert(nvarchar(10),c.dayOfNotice2,103) + N', thông báo lần 03 ngày ' + convert(nvarchar(10),c.dayOfNotice3,103) + N' V/v đóng tiền điện, nước và gửi xe
								nhưng đến nay, Ban QLTN vẫn chưa nhận được đủ các chi phí nêu trên từ quý Ông/Bà.</p>
				
						<p>&nbsp;&nbsp;&nbsp;&nbsp;Vậy bằng thông báo này, Ban QLTN ' + c.ProjectName + N' sẽ tiến hành ngừng cung cấp
							dịch vụ đối với căn hộ: <b>' + ma.RoomCode + N'</b> kể từ <b>'+ convert(char(5), c.dayStopService, 108)+ ' ngày ' + convert(nvarchar(10),c.dayStopService,103) + N' </b>và
							hoàn toàn không chịu trách nhiệm về thiệt hại do việc ngừng cung cấp các dịch vụ nêu
							trên gây ra. Kính đề nghị Quý Ông/Bà kịp thời thanh toán các khoản chi phí trên và chi
							phí cấp lại dịch vụ theo quy định.
						</p>	
				        <p><b>(Quý Cư dân vui lòng bỏ qua thông báo này nếu đã thanh toán phí dịch vụ).</b></p>
						<p>&nbsp;&nbsp;&nbsp;&nbsp;Nơi đóng tiền: Ban quản lý toàn nhà - '+ c.address + N' </p>
								<p>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;- Sáng từ: 08h00 đến 12h00</p>
								<p>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;- Chiều từ: 13h00 đến 20h00</p>
						<p>
							&nbsp;&nbsp;&nbsp;&nbsp;Hoặc chuyển khoản theo tài khoản số <b>'+c.bank_acc_no+N' - Tại ngân hàng: '+c.bank_name+N' - '+c.bank_branch+N'. Chủ tài khoản: '+c.bank_acc_name+N'</b>.
						</p>
			</div>
			<div class="row-container">
						<p>
							&nbsp;&nbsp;&nbsp;&nbsp;Kính mong nhận được sự hợp tác nhanh chóng của quý  Ông/Bà: <b>' + d.FullName + N'  – Căn hộ: '+ ma.RoomCode + N'</b> để Công ty chúng tôi được tiếp tục phục vụ quý Ông/ Bà các dịch vụ nêu
							trên.
						</p>
			</div>
			<div class="row-container">
						<p>
							&nbsp;&nbsp;&nbsp;&nbsp;Xin trân trọng thông báo!
						</p>
			</div>
			<div class="row-container">
				<table border="0" style="margin-right:auto;margin-left:auto;width:100%">
							<tr>
								<th style="text-align:left"><i>Nơi nhận:</i></th>
								<th>BAN QUẢN LÝ TÒA NHÀ</th>
							</tr>
							<tr>
								<td><i>- Như kính gửi;</i></td>
								<th  style="text-transform: lowercase;">' + Upper(c.ProjectName) + N'</td>
							</tr>
							<tr>
								<td style="text-align:left"><i>- Lưu vp.l</i></td>
								<td></td>
							</tr>
				</table>
			</div>
		
				<div style="clear: both;"></div>
		</div>'
	
			
	
			as [MessageEmail]
				  ,'push-notification,email' as [action_list] --push-notification,sms,email
				  ,'new' as [status]
				  ,d.Phone 
				  ,d.Email 
				  --,'0988686022' as phone
				  --,'duong0106xp@gmail.com' as Email
				  ,d.FullName 
				  ,isnull(u2.userId, u.UserId) as userId
				  ,isnull(u2.AvatarUrl,u.AvatarUrl) as AvatarUrl
				  ,u.CustId
				  --,t.BillUrl as attach_file
				  ,isnull(c.mailSender,'no-reply@sunshinemail.vn') as mailSender
				  ,isnull(c.investorName,'Ban QLTN ' + c.projectName) as investorName
			FROM MAS_Service_ReceiveEntry t
				join MAS_Apartments ma on t.ApartmentId = ma.ApartmentId
				join UserInfo u on ma.UserLogin = u.loginName 
				join MAS_Apartment_Member am on ma.ApartmentId = am.ApartmentId and (u.CustId = am.CustId or am.isNotification = 1)
				join MAS_Projects c on ma.projectCd = c.projectCd 
				join MAS_Customers d on am.CustId = d.CustId 
				left join UserInfo u2 on d.CustId = u2.custId and u2.userType = 2
			 WHERE ma.IsReceived = 1
				and isExpected = 1			
				and t.IsPayed = 0					
				and ma.ApartmentId in (SELECT part FROM [dbo].[SplitString](@apartmentIds,',')) 
		


	end try
	begin catch
		declare	@ErrorNum				int,
				@ErrorMsg				varchar(200),
				@ErrorProc				varchar(50),

				@SessionID				int,
				@AddlInfo				varchar(max)

		set @ErrorNum					= error_number()
		set @ErrorMsg					= 'sp_Hom_Service_Stop_Push' + error_message()
		set @ErrorProc					= error_procedure()

		set @AddlInfo					= ''

		exec utl_Insert_ErrorLog @ErrorNum, @ErrorMsg, @ErrorProc, 'Service_Stop', 'Push', @SessionID, @AddlInfo
	end catch