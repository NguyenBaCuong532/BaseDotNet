


CREATE procedure [dbo].[sp_res_elevator_card_customers_get]
	@UserId UNIQUEIDENTIFIER = NULL,
	@CardCd	nvarchar(50) = '047419',
	@acceptLanguage NVARCHAR(50) = N'vi-VN'
as
	begin try	
	

			  SELECT top 50 a.CustId as CustId,
					 a.CardId
					,a.CardCd
					,convert(nvarchar(10),a.[IssueDate],103) as IssueDate
					,convert(nvarchar(10),a.[ExpireDate],103) as  ExpireDate
					,f.CardTypeName as CardTypeName
					,isnull(d.Card_Num,'') as CardNumber
					,s.[StatusName]
					,isnull(null, kk.Phone) as PhoneNumber
					,a.Card_St Status
					,isnull(a.IsDaily,0) as IsDaily
					,a.IsVip
					,isnull(null,kk.FullName) as FullName
					,isnull(a.IsVip,0) as IsNoiBo
					,isnull(a.IsGuest,0) as IsTheKhach
					,case when a.isVip = 1 then N'Thẻ nội bộ' else case when a.IsGuest = 1 then N'Khách ngoài' else isnull(c.RoomCode,'') end end as RoomCode
					,case when (Select count(vh.CardVehicleId) from MAS_CardVehicle vh  
					where vh.CardId = a.CardId and vh.[Status] < 3)>0 then 1 else 0 end as IsVehicle
					,s.StatusName as Status
					,a.CustId as value
					,kk.FullName + ' ('+kk.Phone+') - ' + a.CardCd + ' ('+f.CardTypeName+')' as name
				FROM dbo.MAS_Cards AS a 
				   inner join MAS_CardBase d on a.CardCd = d.Code
				   inner join MAS_CardStatus s on a.Card_St = s.StatusId
				   inner join MAS_Customers kk on a.CustId = kk.CustId
				   left join MAS_CardTypes f on a.CardTypeId = f.CardTypeId
				   left join MAS_Apartment_Member m on a.CustId = m.CustId and a.ApartmentId = m.ApartmentId
				   left join MAS_Apartments c on m.ApartmentId = c.ApartmentId and a.ApartmentId = c.ApartmentId
			where a.Card_St = 1
			and (@CardCd is null 
				or a.CardCd like '%' + @CardCd + '%' 
				or kk.Phone like '%' + @CardCd + '%')
			--and u.userType = 1
		
	end try
	begin catch
		declare	@ErrorNum				int,
				@ErrorMsg				varchar(200),
				@ErrorProc				varchar(50),

				@SessionID				int,
				@AddlInfo				varchar(max)

		set @ErrorNum					= error_number()
		set @ErrorMsg					= 'sp_Hom_Get_Card_ByCardCd ' + error_message()
		set @ErrorProc					= error_procedure()

		set @AddlInfo					= ' '

		exec utl_Insert_ErrorLog @ErrorNum, @ErrorMsg, @ErrorProc, 'MAS_Cards', 'GET', @SessionID, @AddlInfo
	end catch