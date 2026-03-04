-- =============================================
-- Author:		
-- Create date: 7/11/2024 6:16:29 PM
-- Description:	xuat can ho
-- =============================================
CREATE procedure [dbo].[sp_Hom_Apartment_Exports]
	@userId		nvarchar(450),
	@clientId	nvarchar(50),
	@ProjectCd	nvarchar(40),
	@buildingCd nvarchar(30) = '',
	@Received	int = -1,
	@Rent		int = -1,
	@Debt		int = -1,
	@setupStatus	int = -1,
	@filter		nvarchar(100)
as
	begin try
		--declare @clientId nvarchar(50) = 'web_s_service_prod'
		declare @webId nvarchar(50) --= (select id from [dbAppManager].[dbo].[ClientWebs] where clientId = @clientId or clientIdDev = @clientId)
		declare @tbCats TABLE 
		(
			categoryCd [nvarchar](50) not null
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

		

		set		@filter					= isnull(@filter,'')
		set		@buildingCd				= isnull(@buildingCd,'')
		set		@filter					= isnull(@filter,'')
		set		@Received				= isnull(@Received,-1)
		set		@Rent					= isnull(@Rent,-1)
		set		@Debt					= isnull(@Debt,-1)

		SELECT ROW_NUMBER() OVER(ORDER BY a.RoomCode ASC) as STT 
			  ,ProjectName as DuAn
			  ,BuildingName TenToaNha
			  ,r.[Floor] Tang
			  ,r.[RoomCode] MaCan
			  ,a.WaterwayArea DienTichThongThuy
			  ,c.FullName as TenChuNha
			  ,(Select count(CustId) from MAS_Apartment_Member where ApartmentId = a.ApartmentId) as SoThanhVien
			  ,(Select count(CardId) from MAS_Apartment_Member mm inner join MAS_Cards cc on mm.CustId = cc.CustId where mm.ApartmentId = a.ApartmentId) as SoTheDaCap
			  ,c.Phone DienThoai
			  ,c.Email 
			  ,(Select count(vh.CardVehicleId) from MAS_Apartment_Member mm 
					inner join MAS_Cards cc on mm.CustId = cc.CustId 
					inner join MAS_CardVehicle vh on cc.CardId = vh.CardId
						where mm.ApartmentId = a.ApartmentId and cc.Card_St < 3) as SoXeDangKy
			  ,convert(nvarchar(10),a.ReceiveDt,103) as NgayNhanNha
			  ,case when a.IsRent =1 then N'Cho thuê' else N'Chính chủ' end as ChoThue
	  FROM [MAS_Apartments] a 
			inner join MAS_Rooms r on a.RoomCode = r.RoomCode 
			INNER JOIN MAS_Buildings b On r.BuildingCd = b.BuildingCd 
			inner join UserInfo u on a.UserLogin = u.loginName
			INNER JOIN MAS_Customers c ON u.CustId = c.CustId 
			join @tbCats t on a.projectCd = t.categoryCd 
		 WHERE (@buildingCd= '' or b.BuildingCd = @buildingCd)
					and (@Received = -1 Or IsReceived = @Received)
					and (@Rent = -1 Or IsRent = @Rent)
					and ((@Debt is null or @Debt = -1) Or (@Debt = 0 and a.CurrBal = 0) or (@Debt = 1 and a.CurrBal > 0) or (@Debt = 2 and a.CurrBal < 0))
						and (r.RoomCode like '%' + @filter + '%' or c.FullName like '%' + @filter +'%' or c.Phone like '%' + @filter +'%')
		ORDER BY  a.[RoomCode] 
	

	end try
	begin catch
		declare	@ErrorNum				int,
				@ErrorMsg				varchar(200),
				@ErrorProc				varchar(50),

				@SessionID				int,
				@AddlInfo				varchar(max)

		set @ErrorNum					= error_number()
		set @ErrorMsg					= 'sp_Hom_Get_Apartment_Export_ByManager ' + error_message()
		set @ErrorProc					= error_procedure()

		set @AddlInfo					= ' '

		exec utl_Insert_ErrorLog @ErrorNum, @ErrorMsg, @ErrorProc, 'Apartments', 'GET', @SessionID, @AddlInfo
	end catch