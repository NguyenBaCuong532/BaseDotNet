
CREATE PROCEDURE [dbo].[sp_res_service_stop_push] @userId NVARCHAR(450)
    , @apartmentIds NVARCHAR(max)
    --@ProjectCd nvarchar(30)
AS
BEGIN TRY
  --  SELECT t.ReceiveId AS Id
  --      ,
  --      --,N'BQLTN ' + c.ProjectName + N' thông báo phí sử dụng căn hộ ' + ma.RoomCode + N' tính đến ' + convert(nvarchar(10),t.ToDt,103) as title
  --      N'BQLTN ' + c.ProjectName + N'  Thông báo ngừng cung cấp dịch vụ điện, nước và xe căn hộ ' + ma.RoomCode AS title
  --      , N'BQLTN ' + c.ProjectName + N' Thông báo ngừng cung cấp dịch vụ điện, nước và xe căn hộ ' + ma.RoomCode + N'' + N' Ban QLTN ' + c.ProjectName + N' đã gửi thông báo tới quý Ông/Bà ' + d.FullName + N' - ' + ma.RoomCode + N' bằng thông báo lần 01 ngày ' + convert(NVARCHAR(10), c.dayOfNotice1, 103) + N', thông báo lần 02 ngày ' + convert(NVARCHAR(10), c.dayOfNotice2, 103) + N', thông báo lần 03 ngày ' + convert(NVARCHAR(10), c.dayOfNotice3, 103) + N' V/v đóng tiền điện, nước tháng ' + cast(month(t.ToDt) AS NVARCHAR(5)) + '/' + cast(year(t.ToDt) AS NVARCHAR(5)) + N' và gửi xe tháng ' + CASE MONTH(t.ToDt)
  --          WHEN 12
  --              THEN '1/' + cast(year(t.ToDt) + 1 AS NVARCHAR(5))
  --          ELSE cast(month(t.ToDt) + 1 AS NVARCHAR(5)) + '/' + cast(year(t.ToDt) AS NVARCHAR(5))
  --          END + N' nhưng đến nay, Ban QLTN vẫn chưa nhận được đủ các chi phí nêu trên từ quý Ông/Bà' + N' Trân trọng cảm ơn!' AS [Message]
  --      , [dbo].[fChuyenCoDauThanhKhongDau](N'BQLTN ' + c.ProjectName + N' Thông báo ngừng cung cấp dịch vụ điện, nước và xe căn hộ ' + ma.RoomCode + N'' + N'Ban QLTN ' + c.ProjectName + N' đã gửi thông báo tới quý Ông/Bà ' + d.FullName + N' - ' + ma.RoomCode + N' bằng thông báo lần 01 ngày ' + convert(NVARCHAR(10), c.dayOfNotice1, 103) + N', thông báo lần 02 ngày ' + convert(NVARCHAR(10), c.dayOfNotice2, 103) + N', thông báo lần 03 ngày ' + convert(NVARCHAR(10), c.dayOfNotice3, 103) + N' V/v đóng tiền điện, nước tháng ' + cast(month(t.ToDt) AS NVARCHAR(5)) + '/' + cast(year(t.ToDt) AS NVARCHAR(5)) + N' và gửi xe tháng ' + CASE MONTH(t.ToDt)
  --              WHEN 12
  --                  THEN '1/' + cast(year(t.ToDt) + 1 AS NVARCHAR(5))
  --              ELSE cast(month(t.ToDt) + 1 AS NVARCHAR(5)) + '/' + cast(year(t.ToDt) AS NVARCHAR(5))
  --              END + N' nhưng đến nay, Ban QLTN vẫn chưa nhận được đủ các chi phí nêu trên từ quý Ông/Bà' + N'Trân trọng cảm ơn!') AS MessageSms
  --      , N' 
		--		<div style="font-size:18px;width:1000px;font-family:none">
		--				<table border="0" style="margin-left:auto;margin-right:auto;width:100%">
		--					<tr>
		--						<th>CÔNG TY CP QL&VH S-SERVICE</th>
		--						<th>CỘNG HÒA XÃ HỘI CHỦ NGHĨA VIỆT NAM</th>
		--					</tr>
		--					<tr>
		--						<th>BQL TÒA NHÀ</td>
		--						<th>Độc lập - Tự do - Hạnh phúc</td>
		--					</tr>
		--					<tr>
		--						<th >' + Upper(c.ProjectName) + N'</td>
		--						<th>--------------</td>
		--					</tr>
		--					<tr>
		--						<td></td>
		--					<td style="text-align:center">Hà Nội </td>
		--					</tr>
		--				</table>
		--			<div style="text-align:center">
		--				<h2>THÔNG BÁO<h2>
		--				<h3> V/v: Ngừng cung cấp dịch vụ điện, nước và xe <h3>
		--			</div>

		--			<div class="row-container">
		--				<div style="margin-bottom: 40px; text-align: justify;">
		--				<h3 style="font-size: 1.1em;"><b>&nbsp;&nbsp;&nbsp;&nbsp;<u><i>Kính gửi:</i></u> Ông/Bà: ' + d.FullName + N'  – Căn hộ: ' + ma.RoomCode + 
  --      N' </b></h3>
		--			</div>

		--			<div class="translate" style="float: left; width: 87%; font-style: italic;">
		--				<p>&nbsp;&nbsp;&nbsp;&nbsp;Lời đầu tiên, Ban Quản lý tòa nhà (Ban QLTN) ' + c.ProjectName + N' xin được gửi lời chúc sức khỏe và lời chào trân trọng nhất tới Ông/Bà: ' + d.FullName + N'  – Căn hộ: ' + ma.RoomCode + N' .</p>
		--			</div>

		--			<div style="clear: both;"></div>
		--	</div>
		
		--	 <div class="row-container">
		--				<p><style="font-size: 1.1em; text-align: justify;">&nbsp;&nbsp;&nbsp;&nbsp;Ban QLTN Sunshine ' + c.ProjectName + N' đã gửi thông báo tới quý Ông/Bà <b>' + d.FullName + N'  – Căn hộ: ' + ma.RoomCode + N'</b> bằng thông báo lần 01 ngày ' + convert(NVARCHAR(10), c.dayOfNotice1, 103) + N', 
		--					thông báo lần 02 ngày ' + convert(NVARCHAR(10), c.dayOfNotice2, 103) + N', thông báo lần 03 ngày ' + convert(NVARCHAR(10), c.dayOfNotice3, 103) + 
  --      N' V/v đóng tiền điện, nước và gửi xe
		--						nhưng đến nay, Ban QLTN vẫn chưa nhận được đủ các chi phí nêu trên từ quý Ông/Bà.</p>
				
		--				<p>&nbsp;&nbsp;&nbsp;&nbsp;Vậy bằng thông báo này, Ban QLTN ' + c.ProjectName + N' sẽ tiến hành ngừng cung cấp
		--					dịch vụ đối với căn hộ: <b>' + ma.RoomCode + N'</b> kể từ <b>' + convert(CHAR(5), c.dayStopService, 108) + ' ngày ' + convert(NVARCHAR(10), c.dayStopService, 103) + N' </b>và
		--					hoàn toàn không chịu trách nhiệm về thiệt hại do việc ngừng cung cấp các dịch vụ nêu
		--					trên gây ra. Kính đề nghị Quý Ông/Bà kịp thời thanh toán các khoản chi phí trên và chi
		--					phí cấp lại dịch vụ theo quy định.
		--				</p>	
		--		        <p><b>(Quý Cư dân vui lòng bỏ qua thông báo này nếu đã thanh toán phí dịch vụ).</b></p>
		--				<p>&nbsp;&nbsp;&nbsp;&nbsp;Nơi đóng tiền: Ban quản lý toàn nhà - ' + c.address + 
  --      N' </p>
		--						<p>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;- Sáng từ: 08h00 đến 12h00</p>
		--						<p>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;- Chiều từ: 13h00 đến 20h00</p>
		--				<p>
		--					&nbsp;&nbsp;&nbsp;&nbsp;Hoặc chuyển khoản theo tài khoản số <b>' + c.bank_acc_no + N' - Tại ngân hàng: ' + c.bank_name + N' - ' + c.bank_branch + N'. Chủ tài khoản: ' + c.bank_acc_name + N'</b>.
		--				</p>
		--	</div>
		--	<div class="row-container">
		--				<p>
		--					&nbsp;&nbsp;&nbsp;&nbsp;Kính mong nhận được sự hợp tác nhanh chóng của quý  Ông/Bà: <b>' + d.FullName + N'  – Căn hộ: ' + ma.RoomCode + 
  --      N'</b> để Công ty chúng tôi được tiếp tục phục vụ quý Ông/ Bà các dịch vụ nêu
		--					trên.
		--				</p>
		--	</div>
		--	<div class="row-container">
		--				<p>
		--					&nbsp;&nbsp;&nbsp;&nbsp;Xin trân trọng thông báo!
		--				</p>
		--	</div>
		--	<div class="row-container">
		--		<table border="0" style="margin-right:auto;margin-left:auto;width:100%">
		--					<tr>
		--						<th style="text-align:left"><i>Nơi nhận:</i></th>
		--						<th>BAN QUẢN LÝ TÒA NHÀ</th>
		--					</tr>
		--					<tr>
		--						<td><i>- Như kính gửi;</i></td>
		--						<th  style="text-transform: lowercase;">' + Upper(c.ProjectName) + N'</td>
		--					</tr>
		--					<tr>
		--						<td style="text-align:left"><i>- Lưu vp.l</i></td>
		--						<td></td>
		--					</tr>
		--		</table>
		--	</div>
		
		--		<div style="clear: both;"></div>
		--</div>' AS [MessageEmail]
  --      , 'push-notification,email' AS [action_list] --push-notification,sms,email
  --      , 'new' AS [status]
  --      , d.Phone
  --      , d.Email
  --      --,'0988686022' as phone
  --      --,'duong0106xp@gmail.com' as Email
  --      , d.FullName
  --      , isnull(u2.userId, u.UserId) AS userId
  --      , isnull(u2.AvatarUrl, u.AvatarUrl) AS AvatarUrl
  --      , u.CustId
  --      --,t.BillUrl as attach_file
  --      , isnull(c.mailSender, 'no-reply@sunshinemail.vn') AS mailSender
  --      , isnull(c.investorName, 'Ban QLTN ' + c.projectName) AS investorName
  --  FROM MAS_Service_ReceiveEntry t
  --  JOIN MAS_Apartments ma
  --      ON t.ApartmentId = ma.ApartmentId
  --  JOIN MAS_Users u
  --      ON ma.UserLogin = u.UserLogin
  --  JOIN MAS_Apartment_Member am
  --      ON ma.ApartmentId = am.ApartmentId
  --          AND (
  --              u.CustId = am.CustId
  --              OR am.isNotification = 1
  --              )
  --  JOIN MAS_Projects c
  --      ON ma.projectCd = c.projectCd
  --  JOIN MAS_Customers d
  --      ON am.CustId = d.CustId
  --  LEFT JOIN UserInfo u2
  --      ON d.CustId = u2.custId
  --          AND u2.userType = 2
  --  WHERE ma.IsReceived = 1
  --      AND isExpected = 1
  --      AND t.IsPayed = 0
  --      AND ma.ApartmentId IN (
  --          SELECT part
  --          FROM [dbo].[SplitString](@apartmentIds, ',')
  --          )
  SELECT t.ReceiveId AS Id
        ,
        N'BQLTN ' + c.ProjectName + N' thông báo phí sử dụng căn hộ ' + ma.RoomCode + N' tính đến ' + convert(nvarchar(10),t.ToDt,103) as title
        ,N'BQLTN ' + c.ProjectName + N'  Thông báo ngừng cung cấp dịch vụ  ' + ma.RoomCode AS title
        , N'BQLTN ' + c.ProjectName + N' Thông báo ngừng cung cấp dịch vụ  ' + ma.RoomCode + N'' + N' Ban QLTN ' + c.ProjectName + N' đã gửi thông báo tới quý Ông/Bà ' + d.FullName + N' - ' + ma.RoomCode + N' bằng thông báo lần 01 ngày ' + convert(NVARCHAR(10), c.dayOfNotice1, 103) + N', thông báo lần 02 ngày ' + convert(NVARCHAR(10), c.dayOfNotice2, 103) + N', thông báo lần 03 ngày ' + convert(NVARCHAR(10), c.dayOfNotice3, 103) + N' V/v đóng tiền điện, nước tháng ' + cast(month(t.ToDt) AS NVARCHAR(5)) + '/' + cast(year(t.ToDt) AS NVARCHAR(5)) + N' và gửi xe tháng ' + CASE MONTH(t.ToDt)
            WHEN 12
                THEN '1/' + cast(year(t.ToDt) + 1 AS NVARCHAR(5))
            ELSE cast(month(t.ToDt) + 1 AS NVARCHAR(5)) + '/' + cast(year(t.ToDt) AS NVARCHAR(5))
            END + N' nhưng đến nay, Ban QLTN vẫn chưa nhận được đủ các chi phí nêu trên từ quý Ông/Bà' + N' Trân trọng cảm ơn!' AS [Message]
        , [dbo].[fChuyenCoDauThanhKhongDau](N'BQLTN ' + c.ProjectName + N' Thông báo ngừng cung cấp dịch vụ điện, nước và xe căn hộ ' + ma.RoomCode + N'' + N'Ban QLTN ' + c.ProjectName + N' đã gửi thông báo tới quý Ông/Bà ' + d.FullName + N' - ' + ma.RoomCode + N' bằng thông báo lần 01 ngày ' + convert(NVARCHAR(10), c.dayOfNotice1, 103) + N', thông báo lần 02 ngày ' + convert(NVARCHAR(10), c.dayOfNotice2, 103) + N', thông báo lần 03 ngày ' + convert(NVARCHAR(10), c.dayOfNotice3, 103) + N' V/v đóng tiền điện, nước tháng ' + cast(month(t.ToDt) AS NVARCHAR(5)) + '/' + cast(year(t.ToDt) AS NVARCHAR(5)) + N' và gửi xe tháng ' + CASE MONTH(t.ToDt)
                WHEN 12
                    THEN '1/' + cast(year(t.ToDt) + 1 AS NVARCHAR(5))
                ELSE cast(month(t.ToDt) + 1 AS NVARCHAR(5)) + '/' + cast(year(t.ToDt) AS NVARCHAR(5))
                END + N' nhưng đến nay, Ban QLTN vẫn chưa nhận được đủ các chi phí nêu trên từ quý Ông/Bà' + N'Trân trọng cảm ơn!') AS MessageSms
        , N' 
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
						<h3 style="font-size: 1.1em;"><b>&nbsp;&nbsp;&nbsp;&nbsp;<u><i>Kính gửi:</i></u> Ông/Bà: ' + d.FullName + N'  – Căn hộ: ' + ma.RoomCode + 
        N' </b></h3>
					</div>

					<div class="translate" style="float: left; width: 87%; font-style: italic;">
						<p>&nbsp;&nbsp;&nbsp;&nbsp;Lời đầu tiên, Ban Quản lý tòa nhà (Ban QLTN) ' + c.ProjectName + N' xin được gửi lời chúc sức khỏe và lời chào trân trọng nhất tới Ông/Bà: ' + d.FullName + N'  – Căn hộ: ' + ma.RoomCode + N' .</p>
					</div>

					<div style="clear: both;"></div>
			</div>
		
			 <div class="row-container">
						<p><style="font-size: 1.1em; text-align: justify;">&nbsp;&nbsp;&nbsp;&nbsp;Ban QLTN Sunshine ' + c.ProjectName + N' đã gửi thông báo tới quý Ông/Bà <b>' + d.FullName + N'  – Căn hộ: ' + ma.RoomCode + N'</b> bằng thông báo lần 01 ngày ' + convert(NVARCHAR(10), c.dayOfNotice1, 103) + N', 
							thông báo lần 02 ngày ' + convert(NVARCHAR(10), c.dayOfNotice2, 103) + N', thông báo lần 03 ngày ' + convert(NVARCHAR(10), c.dayOfNotice3, 103) + 
        N' V/v đóng tiền điện, nước và gửi xe
								nhưng đến nay, Ban QLTN vẫn chưa nhận được đủ các chi phí nêu trên từ quý Ông/Bà.</p>
				
						<p>&nbsp;&nbsp;&nbsp;&nbsp;Vậy bằng thông báo này, Ban QLTN ' + c.ProjectName + N' sẽ tiến hành ngừng cung cấp
							dịch vụ đối với căn hộ: <b>' + ma.RoomCode + N'</b> kể từ <b>' + convert(CHAR(5), c.dayStopService, 108) + ' ngày ' + convert(NVARCHAR(10), c.dayStopService, 103) + N' </b>và
							hoàn toàn không chịu trách nhiệm về thiệt hại do việc ngừng cung cấp các dịch vụ nêu
							trên gây ra. Kính đề nghị Quý Ông/Bà kịp thời thanh toán các khoản chi phí trên và chi
							phí cấp lại dịch vụ theo quy định.
						</p>	
				        <p><b>(Quý Cư dân vui lòng bỏ qua thông báo này nếu đã thanh toán phí dịch vụ).</b></p>
						<p>&nbsp;&nbsp;&nbsp;&nbsp;Nơi đóng tiền: Ban quản lý toàn nhà - ' + c.address + 
        N' </p>
								<p>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;- Sáng từ: 08h00 đến 12h00</p>
								<p>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;- Chiều từ: 13h00 đến 20h00</p>
						<p>
							&nbsp;&nbsp;&nbsp;&nbsp;Hoặc chuyển khoản theo tài khoản số <b>' + c.bank_acc_no + N' - Tại ngân hàng: ' + c.bank_name + N' - ' + c.bank_branch + N'. Chủ tài khoản: ' + c.bank_acc_name + N'</b>.
						</p>
			</div>
			<div class="row-container">
						<p>
							&nbsp;&nbsp;&nbsp;&nbsp;Kính mong nhận được sự hợp tác nhanh chóng của quý  Ông/Bà: <b>' + d.FullName + N'  – Căn hộ: ' + ma.RoomCode + 
        N'</b> để Công ty chúng tôi được tiếp tục phục vụ quý Ông/ Bà các dịch vụ nêu
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
		</div>' AS [MessageEmail]
        , 'push-notification,email' AS [action_list] --push-notification,sms,email
        , 'new' AS [status]
        , d.Phone
        , d.Email
        --,'0988686022' as phone
        --,'duong0106xp@gmail.com' as Email
        , d.FullName
		,u2.UserId AS userId
		,u2.AvatarUrl AS AvatarUrl
        --, isnull(u2.userId, u.UserId) AS userId
        --, isnull(u2.AvatarUrl, u.AvatarUrl) AS AvatarUrl
        , u2.CustId
        --,t.BillUrl as attach_file
        , isnull(c.mailSender, 'no-reply@sunshinemail.vn') AS mailSender
        , isnull(c.investorName, 'Ban QLTN ' + c.projectName) AS investorName
    FROM MAS_Service_ReceiveEntry t
        JOIN MAS_Apartments ma ON t.ApartmentId = ma.ApartmentId
        --inner join MAS_Rooms b on ma.RoomCode = b.RoomCode
        LEFT JOIN UserInfo u ON ma.UserLogin = u.loginName
        JOIN MAS_Apartment_Member am ON ma.ApartmentId = am.ApartmentId
                AND (
                    u.CustId = am.CustId
                    OR am.isNotification = 1
                    )
        JOIN MAS_Customers d ON am.CustId = d.CustId
        JOIN MAS_Projects c ON ma.projectCd = c.projectCd AND c.sub_projectCd = ma.sub_projectCd
        LEFT JOIN UserInfo u2 ON d.CustId = u2.custId AND u2.userType = 2
    WHERE am.isNotification = 1
	    AND ma.IsReceived = 1
        AND isExpected = 1
        AND t.IsPayed = 0
        AND ma.ApartmentId IN (
            SELECT part
            FROM [dbo].[SplitString](@apartmentIds, ',')
            )
			-- ManhNX thêm vào để check căn có tổng nợ > 0
			AND t.TotalAmt > 0
END TRY

BEGIN CATCH
    DECLARE @ErrorNum INT
        , @ErrorMsg VARCHAR(200)
        , @ErrorProc VARCHAR(50)
        , @SessionID INT
        , @AddlInfo VARCHAR(max)

    SET @ErrorNum = error_number()
    SET @ErrorMsg = 'sp_res_service_stop_push' + error_message()
    SET @ErrorProc = error_procedure()
    SET @AddlInfo = ''

    EXEC utl_Insert_ErrorLog @ErrorNum
        , @ErrorMsg
        , @ErrorProc
        , 'Service_Stop'
        , 'Push'
        , @SessionID
        , @AddlInfo
END CATCH