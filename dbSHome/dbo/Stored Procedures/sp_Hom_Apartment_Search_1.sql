








CREATE procedure [dbo].[sp_Hom_Apartment_Search]
	@userId			nvarchar(450),
	@ProjectCd		nvarchar(30),
	@buildingCd		nvarchar(30) = null,
	@filter			nvarchar(50)
as
	begin try
		set @filter		= isnull(@filter,'')
		set @buildingCd	= isnull(@buildingCd,'')
	--1 profile
		SELECT ProjectName
			  ,b.ProjectCd
			  ,a.[ApartmentId]
			  ,BuildingName
			  ,a.[RoomCode]
			  ,c.FullName
			  ,c.AvatarUrl
			  ,r.[Floor]
			  ,a.WaterwayArea
			  ,a.[UserLogin]
			  ,a.[Cif_No] 
			  ,c.CustId
			  ,b.[BuildingCd]
			  ,[FamilyImageUrl]
			  --,MemberCount = (Select count(CustId) from MAS_Apartment_Member where ApartmentId = a.ApartmentId)
			  --,(Select count(CardId) from MAS_Apartment_Member mm inner join MAS_Cards cc on mm.CustId = cc.CustId where mm.ApartmentId = a.ApartmentId) as CardCount
			  ,c.Phone
			  ,c.Email
			  ,a.IsReceived
			  ,convert(nvarchar(10),a.ReceiveDt,103) as ReceiveDate
			  ,a.IsRent 
			  --,'02473037888' as projectHotline
			  ,a.isMain
	  FROM [MAS_Apartments] a 
			join MAS_Rooms r on a.RoomCode = r.RoomCode 
			JOIN MAS_Buildings b On r.BuildingCd = b.BuildingCd 
			JOIN dbo.MAS_Apartment_Member m on a.ApartmentId = m.ApartmentId
			JOIN dbo.MAS_Customers c ON m.custID = C.custID  			
	  WHERE a.projectCd = @ProjectCd
		and (@buildingCd = '' or r.BuildingCd = @buildingCd)
		and a.RoomCode like '%' + @filter + '%'
		AND m.RelationId = '0'
		
	

	end try
	begin catch
		declare	@ErrorNum				int,
				@ErrorMsg				varchar(200),
				@ErrorProc				varchar(50),

				@SessionID				int,
				@AddlInfo				varchar(max)

		set @ErrorNum					= error_number()
		set @ErrorMsg					= 'sp_Hom_Apartment_Search ' + error_message()
		set @ErrorProc					= error_procedure()

		set @AddlInfo					= ' '

		exec utl_Insert_ErrorLog @ErrorNum, @ErrorMsg, @ErrorProc, 'Apartment', 'GET', @SessionID, @AddlInfo
	end catch