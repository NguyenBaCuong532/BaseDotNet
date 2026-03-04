


--select * from MAS_Service_ReceiveEntry where  ApartmentId in (select ApartmentId from MAS_Apartments where ProjectCd ='05') --and RoomCode ='S2-15A08')
--order by sendDate desc




CREATE procedure [dbo].[sp_Hom_Service_Receivable_Bill_Push]
	@userId nvarchar(450)=null,
	@receiveIds	nvarchar(max)='159995',
	@ProjectCd nvarchar(30)=null
as
	begin try
        -- luu vet khi click gui thong bao dien nuoc hang thang
        insert into audit_email_sms (receiveIds,userId,projectCd) values (@receiveIds,@userId,@ProjectCd)

        declare @ReceviceTblJob table (
                   Id bigint
                   ,title nvarchar(500)
			       ,[Message] nvarchar(max)
                   ,MessageSms nvarchar(max)
                   ,[MessageEmail] nvarchar(max)
			       ,[action_list] nvarchar(50)
			       ,[status] nvarchar(50)
			       ,Phone  nvarchar(50)
				  ,Email nvarchar(100)
				  ,FullName  nvarchar(100)
				  ,userId nvarchar(50)
				  ,AvatarUrl nvarchar(MAX)
				  ,CustId nvarchar(50)
                  ,attach_file nvarchar(max)
				  ,mailSender nvarchar(250)
				  ,investorName nvarchar(500)
				  ,projectCd nvarchar(50)
        )

		if @receiveIds is null or @receiveIds = ''
		begin
			INSERT INTO @ReceviceTblJob
			SELECT distinct ReceiveId as Id
				  ,N'BQLTN ' + c.ProjectName + N' thông báo phí điện, nước tháng ' +  cast(month(t.ToDt) as nvarchar(5))+ N' và phí dịch vụ, phí gửi xe tháng ' +  case MONTH(t.ToDt) when 12 then  '1'  else cast(month(t.ToDt) + 1 as nvarchar(5))  end + N' căn hộ ' + ma.RoomCode as title
				  ,N'BQLTN ' + c.ProjectName + N' thông báo phí sử dụng căn hộ ' + ma.RoomCode + N'' 
				   + N' tính đến ' + convert(nvarchar(10),t.ToDt,103) + '. ' 
				   + N'Qúy Khách căn ' + ma.RoomCode + N' có hóa đơn: ' + format(t.TotalAmt,'###,###,###') + N'VNĐ. '
				   + case when t.DebitAmt > 0 then N'Trong đó số nợ kỳ trước ' + format(t.DebitAmt,'###,###,###') + N'đ. ' else '' end
				   + N'Quý Khách vui lòng thanh toán trước ngày ' + convert(nvarchar(10),t.ExpireDate,103)
				   + N'. Trân trọng cảm ơn!' as [Message]
				   
				  ,N'BQLTN ' + c.ProjectName + ' TB thu phi thang ' + case MONTH(t.ToDt) when 12 then  '1' else cast(month(t.ToDt) + 1 as nvarchar(5))  end + N' can ho ' + ma.RoomCode + N' bao gom: Tien dien, nuoc thang ' +  cast(month(t.ToDt) as nvarchar(5)) +
				   + N'. Tien dich vu, gui xe, cong no thang ' + case MONTH(t.ToDt) when 12 then  '1' else cast(month(t.ToDt) + 1 as nvarchar(5))  end
				   + '. Tong so: ' + format(isnull(t.TotalAmt,0) - isnull(t.PaidAmt,0),'###,###,###') + 'd'
				    + N'. Xin cam on!' as MessageSms


				  ,N' 
						<div class="row-container" style="font-size:16px">
							<div style="text-align: justify;">
								<h3><i>Kính gửi ông/bà: ' + d.FullName + N' - Căn hộ '+ ma.RoomCode + N' </i></h3>
								<h3><i>Dear Mr./Ms.: ' + d.FullName + N' - Apartment  ' + ma.RoomCode + N' </i></h3>
							</div>
							<div class="translate" style="float: left; width: 100%; font-style: italic;">
								<p>Lời đầu tiên, Ban Quản lý Tòa nhà xin gửi lời chào, lời chúc sức khỏe tới Quý Cư dân/Quý khách hàng.</p>
								<p><i>First of all, the Building Management would like to send greetings and health wishes to our dear residents/customers.</i></p>
							</div>
							<div style="clear: both;"></div>
						</div>
		
		
						<div class="row-container"  style="font-size:16px">
								<p><style="font-size: 1.1em; text-align: justify;">Ban Quản lý Tòa nhà ' + c.projectName + N' xin gửi thông báo thu phí căn hộ <b>'+ ma.RoomCode + N' </b> bao gồm:</p>
								<p><style="font-size: 1.1em; text-align: justify;"><i>' + c.projectName + N' Building Management would like to send you charge notification for apartment <b>'+ ma.RoomCode + N' </b>, including:</i></p>
								<ul class="list">
									<li>&nbsp;&nbsp;&nbsp;&nbsp;Công nợ (nếu có)/<i>Debit (if any)</i>: '+ format(t.DebitAmt,'###,###,###')+N'VNĐ</li>
									<li>&nbsp;&nbsp;&nbsp;&nbsp;Phí điện tháng/<i>Electricity fee as of: </i>' +  cast(month(t.ToDt) as nvarchar(5)) + '/' + cast(year(t.ToDt) as nvarchar(5)) + N'</li>
									<li>&nbsp;&nbsp;&nbsp;&nbsp;Phí nước tháng/<i>Water fee as of: </i>' +  cast(month(t.ToDt) as nvarchar(5)) + '/' + cast(year(t.ToDt) as nvarchar(5)) + N'</li>  
									<li>&nbsp;&nbsp;&nbsp;&nbsp;Phí gửi xe tháng/<i>Parking bill as of: </i>' + case MONTH(t.ToDt) when 12 then  '1/' + cast(year(t.ToDt) + 1 as nvarchar(5)) else cast(month(t.ToDt) + 1 as nvarchar(5)) + '/' + cast(year(t.ToDt) as nvarchar(5)) end +N'</li>
									<li>&nbsp;&nbsp;&nbsp;&nbsp;Phí quản lý dịch vụ tháng/<i>Service bill as of: </i> ' + case MONTH(t.ToDt) when 12 then  '1/' + cast(year(t.ToDt) + 1 as nvarchar(5)) else cast(month(t.ToDt) + 1 as nvarchar(5)) + '/' + cast(year(t.ToDt) as nvarchar(5)) end +N'</li>
									<li>&nbsp;&nbsp;&nbsp;&nbsp;Tổng số tiền/<i>Total</i>:<span style="color:red"><b> ' + format(t.TotalAmt,'###,###,###') + N'VNĐ.</span></b></li>
									<li>&nbsp;&nbsp;&nbsp;&nbsp;Số tiền đã thanh toán:<span style="color:red"><b> ' + format(t.PaidAmt,'###,###,###') + N'VNĐ.</span></b></li>
									<li>&nbsp;&nbsp;&nbsp;&nbsp;Số tiền còn lại:<span style="color:red"><b> '  + format(t.TotalAmt-t.PaidAmt,'###,###,###') + N'VNĐ.</span></b></li>
				
					
								</ul>
							<div class="translate" style="float: left; width: 75%; background: #d2d0d0; border-left: 2px solid #004071; padding-top:20px; padding-left:20px; font-style: italic;">
								<p>Chi tiết các khoản phí, Quý Cư dân/Quý khách hàng vui lòng xem tại đây. For details, Please kindly see the detail attachment: <a href = '+ t.BillViewUrl + N' > Xem chi tiết/See details </a></p>	
							</div>
							<div style="clear: both;"></div>
					</div>
	
					<div class="row-container"  style="font-size:16px">
								<p><style="font-size: 1.1em; text-align: justify;">Quý cư dân/Quý khách hàng vui lòng thanh toán trong vòng <span style="color:red"><b>7 ngày </b></span>  ngày kể từ ngày thông báo. Quý cư dân/Quý khách hàng có thể thực hiện thanh toán bằng tiền mặt tại phòng kế toán hoặc quầy lễ tân từ '+c.timeWorking+N' hoặc chuyển khoản. Tuy nhiên, chúng tôi khuyến khích Quý cư dân/Quý khách hàng thanh toán bằng hình thức chuyển khoản.</p>
								<p><style="font-size: 1.1em; text-align: justify;"><i>All of the fees have to be paid within <span style="color:red"><b>7 days</b></span> from issuing notification date. You can pay in cash at Reception Counter from '+c.timeWorking+N' or bank transfer as below:</i></p>
								<p><b>Thông tin chuyển khoản/ <i>Transfer information</i>:</b> <span style="color:red">(Ưu tiên/Priority)</span></p>
								<ul>
									<li>&nbsp;&nbsp;&nbsp;&nbsp;Ngân hàng/<i>Bank</i>: <b>'+c.bank_name+N' - '+c.bank_branch+N'	</b>				
									<li>&nbsp;&nbsp;&nbsp;&nbsp;Số tài khoản/<i>Account number</i>: <b>'+c.bank_acc_no+N'	</b>				
									<li>&nbsp;&nbsp;&nbsp;&nbsp;Chủ Tài khoản/<i>Name</i>: <b>'+c.bank_acc_name+N' </b>					
									<li>&nbsp;&nbsp;&nbsp;&nbsp;Nội dung/<i>Description</i>: <b>Can ho…nop phi thang…./ <i>Unit no:...payment fee for month...</i></b>				
								</ul>
					</div>
        
					</div>
						<div class="row-container"  style="font-size:16px">
							<p>BQLTN rất mong sẽ nhận được sự hợp tác tích cực và ủng hộ của Quý cư dân/Quý khách hàng để công việc được hoàn thành nhanh chóng và thuận lợi.</p>
							<p><i>The Building Management hopes to look forward to receiving the cooperation and support from your residents/Customers so that the task can be completed quickly and smoothly</i>.</p>
							<p>Xin cám ơn!</p>
							<p>Thank you!</p>
					</div> ' as [MessageEmail]
				  ,'push,sms,email' as [action_list]
				  ,'new' as [status]
				  ,d.Phone 
				  ,d.Email 
				  ,d.FullName 
				  ,isnull(u2.userId, u.UserId) as userId
				  ,isnull(u2.AvatarUrl,u.AvatarUrl) as AvatarUrl
				  ,u.CustId
				  ,t.BillUrl as attach_file
				  ,'no-reply@sunshinemail.vn' as mailSender
				  ,isnull(c.investorName,'Ban QLTN ' + c.projectName) as investorName
				  ,c.projectCd
			FROM MAS_Service_ReceiveEntry t
				join MAS_Apartments ma on t.ApartmentId = ma.ApartmentId
				--inner join MAS_Rooms b on ma.RoomCode = b.RoomCode
				join UserInfo u on ma.UserLogin = u.loginName 
				join MAS_Apartment_Member am on ma.ApartmentId = am.ApartmentId and (u.CustId = am.CustId or am.isNotification = 1)
				join MAS_Customers d on am.CustId = d.CustId 
				join MAS_Projects c on ma.projectCd = c.projectCd 
				left join UserInfo u2 on d.CustId = u2.custId and u2.userType = 2
			 WHERE IsPayed = 0 
				and isExpected = 1
				and IsBill = 1
				and t.ProjectCd = @ProjectCd
				and (t.IsPush is null or t.IsPush = 0)
				and isnull(t.TotalAmt,0) > 0
                and (sendDate is null or sendDate <= dateadd(minute,-10,getdate()))
		
		
		end
		else
		begin
			INSERT INTO @ReceviceTblJob
			SELECT distinct ReceiveId as Id
				  ,N'BQLTN ' + c.ProjectName + N' thông báo phí điện, nước tháng ' +  cast(month(t.ToDt) as nvarchar(5))+ N' và phí dịch vụ, phí gửi xe tháng ' +  case MONTH(t.ToDt) when 12 then  '1'  else cast(month(t.ToDt) + 1 as nvarchar(5))  end + N' căn hộ ' + ma.RoomCode as title
				  ,N'BQLTN ' + c.ProjectName + N' thông báo phí sử dụng căn hộ ' + ma.RoomCode + N'' 
				   + N' tính đến ' + convert(nvarchar(10),t.ToDt,103) + '. ' 
				   + N'Qúy Khách căn ' + ma.RoomCode + N' có hóa đơn: ' + format(t.TotalAmt,'###,###,###') + N'VNĐ. '
				   + case when t.DebitAmt > 0 then N'Trong đó số nợ kỳ trước ' + format(t.DebitAmt,'###,###,###') + N'đ. ' else '' end
				   + N'Quý Khách vui lòng thanh toán trước ngày ' + convert(nvarchar(10),t.ExpireDate,103)
				   + N'. Trân trọng cảm ơn!' as [Message]
				   


				  ,N'BQLTN ' + c.ProjectName + ' TB thu phi thang ' + case MONTH(t.ToDt) when 12 then  '1' else cast(month(t.ToDt) + 1 as nvarchar(5))  end + N' can ho ' + ma.RoomCode + N' bao gom: Tien dien, nuoc thang ' +  cast(month(t.ToDt) as nvarchar(5)) +
				   + N'. Tien dich vu, gui xe, cong no thang ' + case MONTH(t.ToDt) when 12 then  '1' else cast(month(t.ToDt) + 1 as nvarchar(5))  end
				   + '. Tong so: ' + format(isnull(t.TotalAmt,0) - isnull(t.PaidAmt,0),'###,###,###') + 'd'
				    + N'. Xin cam on!' as MessageSms


				  ,N' 
						<div class="row-container" style="font-size:16px">
							<div style="text-align: justify;">
								<h3><i>Kính gửi ông/bà: ' + d.FullName + N' - Căn hộ '+ ma.RoomCode + N' </i></h3>
								<h3><i>Dear Mr./Ms.: ' + d.FullName + N' - Apartment  ' + ma.RoomCode + N' </i></h3>
							</div>
							<div class="translate" style="float: left; width: 100%; font-style: italic;">
								<p>Lời đầu tiên, Ban Quản lý Tòa nhà xin gửi lời chào, lời chúc sức khỏe tới Quý Cư dân/Quý khách hàng.</p>
								<p><i>First of all, the Building Management would like to send greetings and health wishes to our dear residents/customers.</i></p>
							</div>
							<div style="clear: both;"></div>
						</div>
		
		
						<div class="row-container"  style="font-size:16px">
								<p><style="font-size: 1.1em; text-align: justify;">Ban Quản lý Tòa nhà ' + c.projectName + N' xin gửi thông báo thu phí căn hộ <b>'+ ma.RoomCode + N' </b> bao gồm:</p>
								<p><style="font-size: 1.1em; text-align: justify;"><i>' + c.projectName + N' Building Management would like to send you charge notification for apartment <b>'+ ma.RoomCode + N' </b>, including:</i></p>
								<ul class="list">
									<li>&nbsp;&nbsp;&nbsp;&nbsp;Công nợ (nếu có)/<i>Debit (if any)</i>: '+ format(t.DebitAmt,'###,###,###')+N'VNĐ</li>
									<li>&nbsp;&nbsp;&nbsp;&nbsp;Phí điện tháng/<i>Electricity fee as of: </i>' +  cast(month(t.ToDt) as nvarchar(5)) + '/' + cast(year(t.ToDt) as nvarchar(5)) + N'</li>
									<li>&nbsp;&nbsp;&nbsp;&nbsp;Phí nước tháng/<i>Water fee as of: </i>' +  cast(month(t.ToDt) as nvarchar(5)) + '/' + cast(year(t.ToDt) as nvarchar(5)) + N'</li>  
									<li>&nbsp;&nbsp;&nbsp;&nbsp;Phí gửi xe tháng/<i>Parking bill as of: </i>' + case MONTH(t.ToDt) when 12 then  '1/' + cast(year(t.ToDt) + 1 as nvarchar(5)) else cast(month(t.ToDt) + 1 as nvarchar(5)) + '/' + cast(year(t.ToDt) as nvarchar(5)) end +N'</li>
									<li>&nbsp;&nbsp;&nbsp;&nbsp;Phí quản lý dịch vụ tháng/<i>Service bill as of: </i> ' + case MONTH(t.ToDt) when 12 then  '1/' + cast(year(t.ToDt) + 1 as nvarchar(5)) else cast(month(t.ToDt) + 1 as nvarchar(5)) + '/' + cast(year(t.ToDt) as nvarchar(5)) end +N'</li>
									<li>&nbsp;&nbsp;&nbsp;&nbsp;Tổng số tiền/<i>Total</i>:<span style="color:red"><b> ' + format(t.TotalAmt,'###,###,###') + N'VNĐ.</span></b></li>
									<li>&nbsp;&nbsp;&nbsp;&nbsp;Số tiền đã thanh toán:<span style="color:red"><b> ' + format(t.PaidAmt,'###,###,###') + N'VNĐ.</span></b></li>
									<li>&nbsp;&nbsp;&nbsp;&nbsp;Số tiền còn lại:<span style="color:red"><b> '  + format(t.TotalAmt-t.PaidAmt,'###,###,###') + N'VNĐ.</span></b></li>
				
					
								</ul>
							<div class="translate" style="float: left; width: 75%; background: #d2d0d0; border-left: 2px solid #004071; padding-top:20px; padding-left:20px; font-style: italic;">
								<p>Chi tiết các khoản phí, Quý Cư dân/Quý khách hàng vui lòng xem tại đây. For details, Please kindly see the detail attachment: <a href = '+ ISNULL(t.BillViewUrl,'') + N' > Xem chi tiết/See details </a></p>	
							</div>
							<div style="clear: both;"></div>
					</div>
	
					<div class="row-container"  style="font-size:16px">
								<p><style="font-size: 1.1em; text-align: justify;">Quý cư dân/Quý khách hàng vui lòng thanh toán trong vòng <span style="color:red"><b>7 ngày </b></span>  ngày kể từ ngày thông báo. Quý cư dân/Quý khách hàng có thể thực hiện thanh toán bằng tiền mặt tại phòng kế toán hoặc quầy lễ tân từ '+c.timeWorking+N' hoặc chuyển khoản. Tuy nhiên, chúng tôi khuyến khích Quý cư dân/Quý khách hàng thanh toán bằng hình thức chuyển khoản.</p>
								<p><style="font-size: 1.1em; text-align: justify;"><i>All of the fees have to be paid within <span style="color:red"><b>7 days</b></span> from issuing notification date. You can pay in cash at Reception Counter from '+c.timeWorking+N' or bank transfer as below:</i></p>
								<p><b>Thông tin chuyển khoản/ <i>Transfer information</i>:</b> <span style="color:red">(Ưu tiên/Priority)</span></p>
								<ul>
									<li>&nbsp;&nbsp;&nbsp;&nbsp;Ngân hàng/<i>Bank</i>: <b>'+c.bank_name+N' - '+c.bank_branch+N'	</b>				
									<li>&nbsp;&nbsp;&nbsp;&nbsp;Số tài khoản/<i>Account number</i>: <b>'+c.bank_acc_no+N'	</b>				
									<li>&nbsp;&nbsp;&nbsp;&nbsp;Chủ Tài khoản/<i>Name</i>: <b>'+c.bank_acc_name+N' </b>					
									<li>&nbsp;&nbsp;&nbsp;&nbsp;Nội dung/<i>Description</i>: <b>Can ho…nop phi thang…./ <i>Unit no:...payment fee for month...</i></b>				
								</ul>
					</div>
        
					</div>
						<div class="row-container"  style="font-size:16px">
							<p>BQLTN rất mong sẽ nhận được sự hợp tác tích cực và ủng hộ của Quý cư dân/Quý khách hàng để công việc được hoàn thành nhanh chóng và thuận lợi.</p>
							<p><i>The Building Management hopes to look forward to receiving the cooperation and support from your residents/Customers so that the task can be completed quickly and smoothly</i>.</p>
							<p>Xin cám ơn!</p>
							<p>Thank you!</p>
					</div> ' 
	
	as [MessageEmail]
				  ,'push,sms,email' as [action_list] 
				  ,'new' as [status]
				  ,d.Phone 
				  ,d.Email 
				  ,d.FullName 
				  ,isnull(u2.userId, u.UserId) as userId
				  ,isnull(u2.AvatarUrl,u.AvatarUrl) as AvatarUrl
				  ,u.CustId
				  ,t.BillUrl as attach_file
				  ,'no-reply@sunshinemail.vn' as mailSender
				  ,isnull(c.investorName,'Ban QLTN ' + c.projectName) as investorName
				  ,c.projectCd
			FROM MAS_Service_ReceiveEntry t
				join MAS_Apartments ma on t.ApartmentId = ma.ApartmentId
				join UserInfo u on ma.UserLogin = u.loginName 
				join MAS_Apartment_Member am on ma.ApartmentId = am.ApartmentId and (u.CustId = am.CustId or am.isNotification = 1)
				--inner join MAS_Rooms b on ma.RoomCode = b.RoomCode
				join MAS_Projects c on ma.projectCd = c.projectCd 
				join MAS_Customers d on am.CustId = d.CustId 
				left join UserInfo u2 on d.CustId = u2.custId and u2.userType = 2
			 WHERE (IsPayed = 0 or IsPayed = 1)
				and isExpected = 1
				--and IsBill = 1
				and t.ReceiveId in (SELECT part FROM [dbo].[SplitString](@receiveIds,',')) 
                and (sendDate is null or sendDate <= dateadd(minute,-10,getdate()))
		end

        update e
			set sendDate = getdate()
		from MAS_Service_ReceiveEntry e
				join @ReceviceTblJob s on e.ReceiveId = s.Id

        SELECT * FROM @ReceviceTblJob

	end try
	begin catch
		declare	@ErrorNum				int,
				@ErrorMsg				varchar(200),
				@ErrorProc				varchar(50),

				@SessionID				int,
				@AddlInfo				varchar(max)

		set @ErrorNum					= error_number()
		set @ErrorMsg					= 'sp_Hom_Service_Receivable_Bill_Create' + error_message()
		set @ErrorProc					= error_procedure()

		set @AddlInfo					= ''

		exec utl_Insert_ErrorLog @ErrorNum, @ErrorMsg, @ErrorProc, 'Receivable', 'Bill', @SessionID, @AddlInfo
	end catch