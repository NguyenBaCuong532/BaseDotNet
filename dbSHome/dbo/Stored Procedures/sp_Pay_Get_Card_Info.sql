

CREATE procedure [dbo].[sp_Pay_Get_Card_Info]
	@CardNum	nvarchar(100)
as
	begin try	
		exec utl_Insert_ErrorLog 0, '', '', 'PayCardInfo', 'GET', '', @CardNum
		declare @qrCodeUrl nvarchar(200) = 'https://qr.ksfinance.net/me/'
		declare @prefix nvarchar(50);	
		if LEN(@CardNum) > len(@qrCodeUrl)
		begin
			set @prefix = 'qrcode'
			set @CardNum = SUBSTRING(@CardNum, len(@qrCodeUrl), LEN(@CardNum) - len(@qrCodeUrl)+1)
		end
		else
		begin
			set @prefix = LEFT(@CardNum, 5);
			if @prefix = 'smart' 
			begin 
				if charindex(':',@CardNum,0) > 0
					set @CardNum = SUBSTRING(@CardNum, charindex(':',@CardNum,0)+1, LEN(@CardNum) - 5)
				else
					set @CardNum = SUBSTRING(@CardNum, 6, LEN(@CardNum) - 5)
			end 
			else 
			begin
				set @prefix = LEFT(@CardNum, 6);
				if @prefix = 'cardid' or @prefix = 'qrcode'
				begin
					if charindex(':',@CardNum,0) > 0  
						set @CardNum = SUBSTRING(@CardNum, charindex(':',@CardNum,0)+1, LEN(@CardNum) - 6)
					else
						set @CardNum = SUBSTRING(@CardNum, 7, LEN(@CardNum) - 6)
				end
			end
		end
		declare @cardnones nvarchar(200)
		
		--set @cardnones = '00000114,00000115,'
		if len(@CardNum) = 8 --and @prefix = 'smart'--Khach hang than thien
			SELECT [CardCd]
				  ,convert(nvarchar(10),a.[IssueDate],103) [IssueDate]
				  ,convert(nvarchar(10),a.[ExpireDate],103) [ExpireDate]
				  ,a.[CardTypeId]
				  ,isnull(p.CurrPoint,0) [CurrentPoint]
				  --,case a.[Status] when 0 then N'Đang hoạt động' when 1 then N'Hết hiệu lực' when 2 then N'Đã báo mất thẻ' else N'Khóa thẻ' end [Status]
				  ,b.FullName
				  ,c.CardTypeName
				  ,c.CardTypeImg as [ImageUrl]
				  ,case when @CardNum = '00000114' or @CardNum = '00000115' then 0 else isnull(cp.Discount,0) end as DiscountRate
				  ,a.CustId
			FROM [dbo].CRM_Card a 
				Join MAS_Customers b On a.CustId = b.CustId 
				join MAS_CardTypes c on a.CardTypeId = c.CardTypeId 				--
				left join MAS_Points p on a.CustId = p.CustId 
				left join CRM_CardPolicy cp on a.CardTypeId = cp.CardTypeId
			WHERE a.CardTypeId = 5 
				and a.CardCd = @CardNum 
				and a.Status = 1
		else if len(@CardNum) = 6 and @prefix = 'cardid'--khach hang cu dan va noi bo
			SELECT [CardCd]
				  ,convert(nvarchar(10),a.[IssueDate],103) [IssueDate]
				  ,convert(nvarchar(10),a.[ExpireDate],103) [ExpireDate]
				  ,a.[CardTypeId]
				  ,isnull(p.CurrPoint,0) [CurrentPoint]
				  --,case Card_St when 0 then N'Đang hoạt động' when 1 then N'Hết hiệu lực' when 2 then N'Đã báo mất thẻ' else N'Khóa thẻ' end [Status]
				  ,s.StatusName as [Status]
				  ,b.FullName
				  ,isnull(d.RoomCode,'CBNV') as RoomCode
				  ,CardTypeName
				  ,c.CardTypeImg as [ImageUrl]
				  ,a.ApartmentId
				  ,isnull(cp.Discount,0) as DiscountRate
				  ,a.CustId
			FROM [dbo].[MAS_Cards] a 
				join MAS_CardBase e on a.CardCd = e.Code
				Join MAS_Customers b On a.CustId = b.CustId 
				join MAS_CardTypes c on a.CardTypeId = c.CardTypeId 
				join MAS_CardStatus s on a.Card_St = s.StatusId 
				left join MAS_Apartment_Member AS k ON b.CustId = k.CustId 
				left join MAS_Apartments d on k.ApartmentId = d.ApartmentId 			
				left join MAS_Points p on a.CustId = p.CustId 
				left join CRM_CardPolicy cp on a.CardTypeId = cp.CardTypeId
			WHERE (a.CardTypeId <=3 --Or (a.CardTypeId = 4 and a.IsVip = 1)
				) 
				and e.Code = @CardNum
				and a.Card_St = 1
		--else if len(@CardNum) = 10 and @prefix = 'qrcode'--khach hang KSF
		--	SELECT 'qrcode'+a.referralCd [CardCd]
		--		  ,convert(nvarchar(10),a.last_dt,103) [IssueDate]
		--		  ,null [ExpireDate]
		--		  ,6 [CardTypeId]
		--		  ,isnull(p.CurrPoint,0) [CurrentPoint]
		--		  ,N'Hoạt động' as [Status]
		--		  ,a.FullName
		--		  ,'KSF App' as RoomCode
		--		  ,N'Khách hàng cài app' CardTypeName
		--		  ,a.avatarUrl as [ImageUrl]
		--		  ,0 ApartmentId
		--		  ,isnull(cp.Discount,0) as DiscountRate
		--		  ,a.CustId
		--	FROM [].dbo.gr09mb a 
		--		Join [].dbo.gr10mb b On a.cif_no = b.cif_no 				
		--		left join MAS_Points p on a.CustId = p.CustId 
		--		left join CRM_CardPolicy cp on cp.CardTypeId = 6 and getdate() between cp.FromDate and cp.ToDate
		--	WHERE (a.idcard_verified = 1 
		--		and a.userType = 3) 
		--		and a.referralCd = @CardNum
		else if len(@CardNum) = 10 --len = 10: khach hang cu dan va noi bo -- so decimal
			SELECT [CardCd]
				  ,convert(nvarchar(10),a.[IssueDate],103) [IssueDate]
				  ,convert(nvarchar(10),a.[ExpireDate],103) [ExpireDate]
				  ,a.[CardTypeId]
				  ,isnull(p.CurrPoint,0) [CurrentPoint]
				  ,s.StatusName as [Status]
				  ,b.FullName
				  ,isnull(d.RoomCode,'CBNV') as RoomCode
				  ,c.CardTypeName
				  ,c.CardTypeImg as [ImageUrl]
				  ,a.ApartmentId
				  ,isnull(cp.Discount,0) as DiscountRate
				  ,a.CustId
			FROM [dbo].[MAS_Cards] a 
				join MAS_CardBase e on a.CardCd = e.Code
				Join MAS_Customers b On a.CustId = b.CustId 
				join MAS_CardTypes c on a.CardTypeId = c.CardTypeId 
				join MAS_CardStatus s on a.Card_St = s.StatusId 
				left join MAS_Apartment_Member AS k ON b.CustId = k.CustId 
				left join MAS_Apartments d on k.ApartmentId = d.ApartmentId 
				left join MAS_Points p on a.CustId = p.CustId 
				left join CRM_CardPolicy cp on a.CardTypeId = cp.CardTypeId
			WHERE (a.CardTypeId <=3 --Or (a.CardTypeId = 4 and a.IsVip = 1)
				) 
				and e.Card_Num = @CardNum
				and a.Card_St = 1
		else if len(@cardNum) = 12
			SELECT top 1 [CardCd]
				  ,convert(nvarchar(10),a.[IssueDate],103) [IssueDate]
				  ,convert(nvarchar(10),a.[ExpireDate],103) [ExpireDate]
				  ,a.[CardTypeId]
				  ,isnull(p.CurrPoint,0) [CurrentPoint]
				  ,s.StatusName as [Status]
				  ,b.FullName
				  ,isnull(d.RoomCode,'CBNV') as RoomCode
				  ,c.CardTypeName
				  ,c.CardTypeImg as [ImageUrl]
				  ,a.ApartmentId
				  ,isnull(cp.Discount,0) as DiscountRate
				  ,a.CustId
			FROM [dbo].[MAS_Cards] a 
				inner join MAS_CardBase e on a.CardCd = e.Code
				Inner Join MAS_Customers b On a.CustId = b.CustId 
				join UserInfo u on b.CustId = u.CustId
				inner join MAS_CardTypes c on a.CardTypeId = c.CardTypeId 
				join MAS_CardStatus s on a.Card_St = s.StatusId 
				left join MAS_Apartment_Member AS k ON b.CustId = k.CustId 
				left join MAS_Apartments d on k.ApartmentId = d.ApartmentId 
				left join MAS_Points p on a.CustId = p.CustId 
				left join CRM_CardPolicy cp on a.CardTypeId = cp.CardTypeId
			WHERE (a.CardTypeId <=3 --Or (a.CardTypeId = 4 and a.IsVip = 1)
				) 
				and u.UserId = '@cardNum' --dbAppManager.[dbo].[fn_User_Token_Get](@cardNum)
		
	end try
	begin catch
		declare	@ErrorNum				int,
				@ErrorMsg				varchar(200),
				@ErrorProc				varchar(50),

				@SessionID				int,
				@AddlInfo				varchar(max)

		set @ErrorNum					= error_number()
		set @ErrorMsg					= 'sp_Pay_Get_Card_Info ' + error_message()
		set @ErrorProc					= error_procedure()

		set @AddlInfo					= ' '

		exec utl_Insert_ErrorLog @ErrorNum, @ErrorMsg, @ErrorProc, 'CardInfo', 'GET', @SessionID, @AddlInfo
	end catch