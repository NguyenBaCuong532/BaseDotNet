







CREATE procedure [dbo].[sp_Hom_Card_Resident_ByExport]
	@UserId		nvarchar(450),
	@clientId	nvarchar(50),
	@ProjectCd	nvarchar(40),
	@RoomCd		nvarchar(30),
	@Statuses	int = null
as
	begin try
		set @clientId = 'web_s_service_prod'
		declare @webId nvarchar(50) = (select id from [dbAppManager].[dbo].[ClientWebs] where clientId = @clientId or clientIdDev = @clientId)
		declare @tbCats TABLE 
		(
			categoryCd [nvarchar](50) not null INDEX IX1_category NONCLUSTERED
		)
		set		@projectCd				= isnull(@projectCd,'')
		INSERT INTO @tbCats
		select distinct u.categoryCd from [dbSHome].[dbo].[MAS_Category_User] u 
			where u.UserId = @UserId and u.webId = @webId and u.isAll = 0 
			and (@ProjectCd = '' or u.categoryCd = @ProjectCd)
			and not exists(select CategoryCd from @tbCats where categoryCd = u.CategoryCd)
		INSERT INTO @tbCats
		select distinct n.categoryCd from [dbSHome].[dbo].[MAS_Category_User] u join [dbSHome].[dbo].MAS_Category n on n.base_type = u.base_type 
			where u.UserId = @UserId and u.webId = @webId and u.isAll = 1
			and (@ProjectCd = '' or n.categoryCd = @ProjectCd)
			and not exists(select CategoryCd from @tbCats where categoryCd = n.CategoryCd)

		set		@RoomCd					= isnull(@RoomCd,'')

	--1
	  SELECT ROW_NUMBER() OVER(ORDER BY p.RoomCode,[CardCd] ASC) as STT 
			,[CardCd] as MaThe
			,convert(nvarchar(10),a.[IssueDate],103) as NgayCapThe
			--,convert(nvarchar(10),a.[ExpireDate],103) [ExpireDate]
			,b.Cif_No as CifNo
			,[CardTypeName] as LoaiThe
			,b.FullName as HoVaTen
			,s.StatusName as TrangThai
			,p.RoomCode as CanHo
			,e.Card_Hex MaTheThangMay
	  FROM [MAS_Cards] a 
		JOIN MAS_Customers b On a.CustId = b.CustId 
		join MAS_CardBase e on e.Code = a.CardCd
		--join MAS_Apartment_Member c on b.CustId = c.CustId
		join [MAS_Apartments] p on a.ApartmentId = p.ApartmentId
		join @tbCats t on p.projectCd = t.categoryCd 
		join MAS_CardTypes f on a.CardTypeId = f.CardTypeId 
		join MAS_CardStatus s on a.Card_St = s.StatusId
	  WHERE a.CardTypeId <= 3
			and (p.RoomCode like '%' + @RoomCd + '%' Or CardCd like '%'+@RoomCd +'%' or b.FullName like '%'+ @RoomCd +'%')
			--and ((@Statuses is null or @Statuses = -1 ) Or a.Card_St = @Statuses)
		ORDER BY p.RoomCode,[CardCd]


	end try
	begin catch
		declare	@ErrorNum				int,
				@ErrorMsg				varchar(200),
				@ErrorProc				varchar(50),

				@SessionID				int,
				@AddlInfo				varchar(max)

		set @ErrorNum					= error_number()
		set @ErrorMsg					= 'sp_Get_Card_Export_ByManager ' + error_message()
		set @ErrorProc					= error_procedure()

		set @AddlInfo					= ' '

		exec utl_Insert_ErrorLog @ErrorNum, @ErrorMsg, @ErrorProc, 'CardExport', 'GET', @SessionID, @AddlInfo
	end catch