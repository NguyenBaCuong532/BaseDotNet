


CREATE procedure [dbo].[sp_Pay_Get_Cust_Info]
	@search_key	nvarchar(100)
as
	begin try	
		
			declare @cardnones nvarchar(200)
				
			SELECT top 1 [CardCd]
				  ,convert(nvarchar(10),a.[IssueDate],103) [IssueDate]
				  ,convert(nvarchar(10),a.[ExpireDate],103) [ExpireDate]
				  ,a.[CardTypeId]
				  ,isnull(p.CurrPoint,0) [CurrentPoint]
				  ,s.StatusName as [Status]
				  ,b.FullName
				  ,isnull(d.RoomCode,'') as RoomCode
				  ,c.CardTypeName
				  ,c.CardTypeImg as [ImageUrl]
				  ,a.ApartmentId
				  ,isnull(cp.Discount,0) as DiscountRate
				  ,a.CustId
				  ,b.Pass_No as idcard_no
				  ,b.Pass_Plc as idcard_issue_plc
				  ,b.Pass_Dt as idcard_issue_dt
				  ,b.phone
			FROM 
				MAS_Customers b --
				left join [MAS_Cards] a On a.CustId = b.CustId 
				left join MAS_CardTypes c on a.CardTypeId = c.CardTypeId 
				left join MAS_CardStatus s on a.Card_St = s.StatusId 
				left join MAS_Apartment_Member AS k ON b.CustId = k.CustId 
				left join MAS_Apartments d on k.ApartmentId = d.ApartmentId 
				left join MAS_Points p on a.CustId = p.CustId 
				left join CRM_CardPolicy cp on a.CardTypeId = cp.CardTypeId
			WHERE (b.Phone is not null and b.Phone != ''
					and b.Pass_No is not null and b.Pass_No != ''
				) 
				and (exists(select 1 from [MAS_Cards] x where x.CustId = b.CustId and x.CardCd like @search_key and x.Card_St = 1)
					or b.Phone like @search_key and b.Phone is not null and b.Phone != ''
					or b.Pass_No like @search_key and b.Pass_No is not null and b.Pass_No != ''
					or exists(select 1 FROM [dbo].CRM_Card x 
						WHERE x.CardTypeId = 5 
							and x.CustId = b.CustId
							and x.CardCd = @search_key 
							and x.Status = 1)
				)
		
	end try
	begin catch
		declare	@ErrorNum				int,
				@ErrorMsg				varchar(200),
				@ErrorProc				varchar(50),

				@SessionID				int,
				@AddlInfo				varchar(max)

		set @ErrorNum					= error_number()
		set @ErrorMsg					= 'sp_Pay_Get_Cust_Info ' + error_message()
		set @ErrorProc					= error_procedure()

		set @AddlInfo					= ' '

		exec utl_Insert_ErrorLog @ErrorNum, @ErrorMsg, @ErrorProc, 'CardInfo', 'GET', @SessionID, @AddlInfo
	end catch