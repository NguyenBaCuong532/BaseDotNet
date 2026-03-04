
CREATE procedure [dbo].[sp_Crm_Card_Page]
	@UserId				nvarchar(450), 
	@custId				nvarchar(100), 
	@gridWidth			int				= 0,
	@Offset				int				= 0,
	@PageSize			int				= 10,
	@Filter nvarchar(450), 
	@Total				int out,
	@TotalFiltered		int out
	,@gridKey			nvarchar(200) out
as
	begin try 
		set		@Offset					= isnull(@Offset, 0)
		set		@PageSize				= isnull(@PageSize, 10)
		set		@Total					= isnull(@Total, 0)
		set		@filter					= isnull(@filter,'')
		set		@custId					= isnull(@custId,'')

		if		@PageSize	<= 0		set @PageSize	= 10
		if		@Offset		< 0			set @Offset		=  0
		
		if @Offset = 0
		begin
			select * from dbo.fn_config_list_gets('view_Crm_Card_Page', @gridWidth - 100) 
			order by [ordinal]
		end

		if exists(select custId from CRM_Customer where CustId = @custId)
		begin

		select	@Total					= count(crd.CardCd)
				FROM  CRM_Card crd
				join MAS_Customers cus on crd.CustId = cus.CustId
				where crd.CustId like @custId + '%'
				and  (crd.CardCd like '%'+@filter+'%' or cus.FullName like '%'+@filter+'%' or cus.Phone = @filter)

		set	@TotalFiltered = @Total

		--1
		SELECT 
		--d.Card_Num,
			crd.cardId,
			crd.cardCd,
			--ctp.imageUrl,
			crd.cardName,
			convert(nvarchar(10),crd.[IssueDate],103) [issueDate],
			convert(nvarchar(10),crd.[ExpireDate],103)   as [expireDate],
			stt.statusName,
			crd.[status]
			,mct.cardTypeName
			,cus.fullName 
			,p.currPoint
			,crd.isVip--case when crd.IsVip = 1 then N'Có' else N'Không' end as IsVip
			,crd.cardTypeId
			,cp.discount
			,p.CurrPoint as CurrentPoint
	 FROM  CRM_Card crd
			join MAS_CardTypes mct on crd.CardTypeId = mct.CardTypeId
			--join CRM_CardType ctp on crd.CardTypeId = ctp.CardTypeId
			join MAS_Customers cus on crd.CustId = cus.CustId
			--join CRM_Customer cc on cus.CustId = cc.CustId
			join CRM_CardStatus stt on crd.Status = stt.StatusId
			left join MAS_Points p on crd.CustId = p.CustId
			left join CRM_CardPolicy cp on crd.CardTypeId = cp.CardTypeId and cp.IsVip = ISNULL(crd.IsVip, 0) 
					and (crd.ExpireDate > GETDATE() or crd.ExpireDate is null)
					and (cp.FromDate <= GETDATE() and cp.ToDate >= GETDATE())
			where crd.CustId like @custId + '%'
			and  (crd.CardCd like '%'+@filter+'%' or cus.FullName like '%'+@filter+'%' or cus.Phone = @filter +'%')
	
			ORDER BY crd.[IssueDate] desc
				  offset @Offset rows	
					fetch next @PageSize rows only
		end
		else
		begin 

		select	@Total					= count(a.CardCd)
				FROM  [MAS_Apartments] c
				--join MAS_Apartment_Card ac on a.CardId = ac.CardId 
				join [MAS_Cards] a  on a.ApartmentId = c.ApartmentId
				join MAS_Customers b On a.CustId = b.CustId 
				where b.CustId like @custId + '%'

		set	@TotalFiltered = @Total

		SELECT a.[CardCd]
			  ,convert(nvarchar(10),a.[IssueDate],103) [IssueDate]
			  ,convert(nvarchar(10),a.[ExpireDate],103) [ExpireDate]
			  ,a.CustId 
			  ,a.[CardTypeId]
			  ,pp.CardTypeName
			  ,pp.CardTypeImg as [ImageUrl]
			  ,b.FullName
			  ,a.Card_St as [Status]
			  ,s.StatusName 
			  ,c.ApartmentId
			  ,b.CustId
			  ,c.RoomCode + '-' + b.FullName as FullName
			  ,p.CurrPoint 
			  ,cp.discount
		  --,case when count(vh.CardVehicleId) > 0 then 1 else 0 end as IsVehicle
	  FROM  [MAS_Apartments] c
		--join MAS_Apartment_Card ac on a.CardId = ac.CardId 
		join [MAS_Cards] a  on a.ApartmentId = c.ApartmentId
		join MAS_Customers b On a.CustId = b.CustId 
		--join MAS_Rooms r on c.RoomCode = r.RoomCode 
		--join MAS_Buildings d on r.BuildingCd = d.BuildingCd 
		join MAS_CardStatus s on a.Card_St = s.StatusId
		join MAS_CardTypes pp on a.[CardTypeId] = pp.[CardTypeId]
		left join MAS_CardVehicle vh on a.CardId = vh.CardId and vh.[Status] < 3
		left join MAS_Points p on b.CustId = p.CustId
		left join CRM_CardPolicy cp on a.CardTypeId = cp.CardTypeId and cp.IsVip = ISNULL(a.IsVip, 0) 
					and (a.ExpireDate > GETDATE() or a.ExpireDate is null)
					and (cp.FromDate <= GETDATE() and cp.ToDate >= GETDATE())
	  WHERE b.CustId = @custId 


		end

	end try
	begin catch
		declare	@ErrorNum				int,
				@ErrorMsg				varchar(200),
				@ErrorProc				varchar(50),

				@SessionID				int,
				@AddlInfo				varchar(max)

		set @ErrorNum					= error_number()
		set @ErrorMsg					= 'sp_Crm_Get_Card_Page ' + error_message()
		set @ErrorProc					= error_procedure()

		set @AddlInfo					= ' '

		exec utl_Insert_ErrorLog @ErrorNum, @ErrorMsg, @ErrorProc, 'Card_Page', 'GET', @SessionID, @AddlInfo
	end catch