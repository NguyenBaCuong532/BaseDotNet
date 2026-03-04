


CREATE procedure [dbo].[sp_Pay_Point_Cust_Info]
	@userId		nvarchar(450),
	@phone		nvarchar(50),
	@roomCode	nvarchar(50)
as
	begin try	
		
		if @phone is not null
			if exists(select b.custId from MAS_Customers b 
				join UserInfo AS k ON b.CustId = k.CustId 
				join MAS_Apartments d on k.loginName = d.UserLogin 
				WHERE b.Phone = @phone)
			SELECT [CardCd]
				  ,convert(nvarchar(10),a.[IssueDate],103) [IssueDate]
				  ,convert(nvarchar(10),a.[ExpireDate],103) [ExpireDate]
				  ,a.CardId
				  ,isnull(p.CurrPoint,0) [CurrentPoint]
				  ,s.StatusName as [Status]
				  ,b.FullName
				  ,isnull(d.RoomCode,'') as RoomCode
				  ,CardTypeName
				  ,isnull(cp.Discount,0) as DiscountRate
				  ,p.PointCd
				  ,b.CustId

			FROM [dbo].[MAS_Cards] a 
				inner join MAS_CardBase e on a.CardCd = e.Code
				Inner Join MAS_Customers b On a.CustId = b.CustId 
				inner join MAS_CardTypes c on a.CardTypeId = c.CardTypeId 
				join MAS_CardStatus s on a.Card_St = s.StatusId 
				join UserInfo AS k ON b.CustId = k.CustId 
				join MAS_Apartments d on k.loginName = d.UserLogin and a.ApartmentId = d.ApartmentId 
				left join MAS_Points p on a.CustId = p.CustId 
				left join CRM_CardPolicy cp on a.CardTypeId = cp.CardTypeId
			WHERE (a.CardTypeId <=3 Or (a.CardTypeId = 4 and a.IsVip = 1)) 
				and a.Card_St = 1
				and b.Phone = @phone
			else
				SELECT [CardCd]
				  ,convert(nvarchar(10),a.[IssueDate],103) [IssueDate]
				  ,convert(nvarchar(10),a.[ExpireDate],103) [ExpireDate]
				  ,a.CardId
				  ,isnull(p.CurrPoint,0) [CurrentPoint]
				  ,s.StatusName as [Status]
				  ,b.FullName
				  ,isnull(d.RoomCode,'') as RoomCode
				  ,CardTypeName
				  ,isnull(cp.Discount,0) as DiscountRate
				  ,p.PointCd
				  ,b.CustId

			FROM [dbo].[MAS_Cards] a 
				inner join MAS_CardBase e on a.CardCd = e.Code
				Inner Join MAS_Customers b On a.CustId = b.CustId 
				inner join MAS_CardTypes c on a.CardTypeId = c.CardTypeId 
				join MAS_CardStatus s on a.Card_St = s.StatusId 
				left join UserInfo AS k ON b.CustId = k.CustId 
				left join MAS_Apartments d on k.loginName = d.UserLogin and a.ApartmentId = d.ApartmentId 					
				left join MAS_Points p on a.CustId = p.CustId 
				left join CRM_CardPolicy cp on a.CardTypeId = cp.CardTypeId
			WHERE  (a.CardTypeId <=3 Or (a.CardTypeId = 4 and a.IsVip = 1)) 
				and a.Card_St = 1
				and b.Phone = @phone 
				--and em.IsApproved = 1
		else
			SELECT [CardCd]
				  ,convert(nvarchar(10),a.[IssueDate],103) [IssueDate]
				  ,convert(nvarchar(10),a.[ExpireDate],103) [ExpireDate]
				  ,a.CardId
				  ,isnull(p.CurrPoint,0) [CurrentPoint]
				  ,s.StatusName as [Status]
				  ,b.FullName
				  ,isnull(d.RoomCode,'') as RoomCode
				  ,CardTypeName
				  ,isnull(cp.Discount,0) as DiscountRate
				  ,p.PointCd
				  ,b.CustId

			FROM [dbo].[MAS_Cards] a 
				join MAS_CardBase e on a.CardCd = e.Code
				Join MAS_Customers b On a.CustId = b.CustId 
				join MAS_CardTypes c on a.CardTypeId = c.CardTypeId 
				join MAS_CardStatus s on a.Card_St = s.StatusId 
				join UserInfo AS k ON b.CustId = k.CustId 
				join MAS_Apartments d on k.loginName = d.UserLogin and a.ApartmentId = d.ApartmentId 
				left join MAS_Points p on a.CustId = p.CustId 
				left join CRM_CardPolicy cp on a.CardTypeId = cp.CardTypeId
			WHERE (a.CardTypeId <=3 Or (a.CardTypeId = 4 and a.IsVip = 1)) 
				and a.Card_St = 1
				and (d.RoomCode = @roomCode or a.CardCd = @roomCode)

	end try
	begin catch
		declare	@ErrorNum				int,
				@ErrorMsg				varchar(200),
				@ErrorProc				varchar(50),

				@SessionID				int,
				@AddlInfo				varchar(max)

		set @ErrorNum					= error_number()
		set @ErrorMsg					= 'sp_Pay_Point_Cust_Info ' + error_message()
		set @ErrorProc					= error_procedure()

		set @AddlInfo					= ' '

		exec utl_Insert_ErrorLog @ErrorNum, @ErrorMsg, @ErrorProc, 'PointInfo', 'GET', @SessionID, @AddlInfo
	end catch