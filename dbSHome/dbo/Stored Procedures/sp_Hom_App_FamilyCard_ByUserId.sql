




-- exec sp_Hom_App_FamilyCard_ByUserId null,5672
CREATE procedure [dbo].[sp_Hom_App_FamilyCard_ByUserId]
	@UserId	nvarchar(450),
	@ApartmentId int
as
	begin try

		if @ApartmentId is null or @ApartmentId = 0
			set @ApartmentId = (select top 1 ApartmentId from [dbo].[fn_Hom_User_Apartment] (@userId))

	--1
	SELECT a.[CardCd]
		  ,convert(nvarchar(10),a.[IssueDate],103) [IssueDate]
		  ,convert(nvarchar(10),a.[ExpireDate],103) [ExpireDate]
		  ,a.CustId as CifNo
		  ,a.[CardTypeId]
		  ,pp.CardTypeName
		  ,isnull(p.CurrPoint,0) as [CurrentPoint]
		  ,pp.CardTypeImg as [ImageUrl]
		  ,b.FullName
		  ,a.Card_St as [Status]
		  ,s.StatusName 
		  --,case a.Card_St when 0 then N'Đang hoạt động' when 1 then N'Hết hiệu lực' when 2 then N'Đã báo mất thẻ' else N'Khóa thẻ' end [StatusName]
		  --,case Card_St when 0 then N'Đang hoạt động' when 1 then N'Hết hiệu lực' when 2 then N'Đã báo mất thẻ' else N'Khóa thẻ' end as [Status]
		  ,c.ApartmentId
		  ,b.CustId
		  ,p.CurrPoint as CurrentPoint
		  ,case when count(vh.CardVehicleId) > 0 then 1 else 0 end as IsVehicle
	  FROM  [MAS_Apartments] c
		join [MAS_Cards] a  on a.ApartmentId = c.ApartmentId
		left join MAS_Customers b On a.CustId = b.CustId 
		join MAS_CardStatus s on a.Card_St = s.StatusId
		join MAS_CardTypes pp on a.[CardTypeId] = pp.[CardTypeId]
		left join MAS_CardVehicle vh on a.CardId = vh.CardId --and vh.[Status] < 3
		left join MAS_Points p on b.CustId = p.CustId		
	  WHERE c.ApartmentId = @ApartmentId
	  group by
			   [CardCd]
			  ,convert(nvarchar(10),a.[IssueDate],103) 
			  ,convert(nvarchar(10),a.[ExpireDate],103) 
			  ,a.CustId 
			  ,a.CustId
			  ,a.[CardTypeId]
			  ,p.CurrPoint
			  ,pp.CardTypeImg 
			  ,b.FullName
			  ,s.[StatusName]
			  ,Card_St 
			  ,c.RoomCode
			  ,a.ApartmentId
			  ,s.StatusName 
			  ,pp.CardTypeName
			  ,c.ApartmentId
			  ,b.CustId
	  ORDER BY a.CardCd
	--2
	
	end try
	begin catch
		declare	@ErrorNum				int,
				@ErrorMsg				varchar(200),
				@ErrorProc				varchar(50),

				@SessionID				int,
				@AddlInfo				varchar(max)

		set @ErrorNum					= error_number()
		set @ErrorMsg					= 'sp_Hom_Get_Page_FamilyCard_ByUserId ' + error_message()
		set @ErrorProc					= error_procedure()

		set @AddlInfo					= ' '

		exec utl_Insert_ErrorLog @ErrorNum, @ErrorMsg, @ErrorProc, 'FamilyCard', 'GET', @SessionID, @AddlInfo
	end catch