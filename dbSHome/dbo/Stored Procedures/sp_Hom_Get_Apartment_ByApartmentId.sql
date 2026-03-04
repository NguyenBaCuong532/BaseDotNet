







CREATE procedure [dbo].[sp_Hom_Get_Apartment_ByApartmentId]
	@UserId nvarchar(450),
	@roomCode	nvarchar(20)

as
	begin try
	
	--1 profile
		SELECT a.[ApartmentId]
			  ,r.[RoomCode]
			  ,c.FullName
			  ,c.AvatarUrl
			  ,r.[Floor]
			  ,u.[UserId]
			  ,a.[UserLogin]
			  ,b.[BuildingCd]
			  ,[FamilyImageUrl]
			  ,b.ProjectName
			  ,c.Phone
			  ,c.Email
			  ,a.IsReceived
			  ,convert(nvarchar(10),a.ReceiveDt,103) as ReceiveDate
			  ,a.IsRent 
			  ,MemberCount = (Select count(CustId) from MAS_Apartment_Member where ApartmentId = a.ApartmentId)
			  ,HouseholdCount = (select count(ch.custid) FROM [MAS_Customer_Household] ch join MAS_Apartment_Member am on ch.CustId = am.CustId where am.ApartmentId = a.ApartmentId)
			  ,CardCount = (Select count(cc.CardId) from MAS_Apartment_Card cc join MAS_Cards mc on cc.CardId = mc.CardId  where cc.ApartmentId = a.ApartmentId) 
			  ,VehicleCount = (Select count(vh.CardVehicleId) from MAS_Apartment_Card mm 
					inner join MAS_Cards cc on mm.CardId = cc.CardId 
					inner join MAS_CardVehicle vh on cc.CardId = vh.CardId
						where mm.ApartmentId = a.ApartmentId and cc.Card_St < 3) 
	  FROM [MAS_Apartments] a 
			inner join MAS_Rooms r on r.RoomCode = a.RoomCode
			INNER JOIN MAS_Buildings b On r.BuildingCd = b.BuildingCd 
			left join UserInfo u on a.UserLogin = u.loginName 
			INNER JOIN MAS_Customers c ON u.CustId = c.CustId 
	  WHERE a.RoomCode = @roomCode

		--2 member
		SELECT a.CustId as CifNo
			  ,a.[FullName]
			  ,a.[IsSex]
			  ,case when a.IsSex = 1 then N'Nam' else N'Nữ' end as SexName
			  ,convert(nvarchar(10),a.[Birthday],103) as [Birthday]
			  ,a.[Phone]
			  ,a.[Email]
			  ,a.[IsHost]
			  ,b.[ApartmentId]
			  ,a.[AvatarUrl]
			  ,isnull(a.IsForeign,0) as IsForeign
			  ,isnull(a.Auth_St,0) as [Status]
			  ,case when isnull(a.Auth_St,0) = 0 then N'Mới tạo' else N'Đã phê duyệt' end as StatusName
			  ,a.CustId 
			  ,(SELECT TOP 1 [imageUrl] FROM [MAS_Customer_Image] where CustId = a.CustId and Imagetype = 1) as FaceRecogUrl1
			  ,(SELECT TOP 1 [imageUrl] FROM [MAS_Customer_Image] where CustId = a.CustId and Imagetype = 2) as FaceRecogUrl2
			  ,(SELECT TOP 1 [imageUrl] FROM [MAS_Customer_Image] where CustId = a.CustId and Imagetype = 3) as FaceRecogUrl3
			  ,(SELECT TOP 1 [imageUrl] FROM [MAS_Customer_Image] where CustId = a.CustId and Imagetype = 4) as FaceRecogUrl4
			  ,(SELECT TOP 1 [imageUrl] FROM [MAS_Customer_Image] where CustId = a.CustId and Imagetype = 5) as FaceRecogUrl5
			  ,d.RelationName
			  ,c.RelationID
	  FROM MAS_Customers a 
		  inner join MAS_Apartment_Member c on a.CustId = c.CustId
		  Inner join MAS_Apartments b on c.ApartmentId = b.ApartmentId 
		  left join MAS_Customer_Relation d on c.RelationId = d.RelationId
	  WHERE RoomCode = @roomCode
	  ORDER BY [IsHost] DESC, sysDate desc
	  
	  --3 card
	  SELECT [CardCd]
		  ,convert(nvarchar(10),a.[IssueDate],103) [IssueDate]
		  ,convert(nvarchar(10),a.[ExpireDate],103) [ExpireDate]
		  ,d.[Cif_No] as CifNo
		  ,a.[CardTypeId]
		  ,c.CardTypeName 
		  ,isnull(p.CurrPoint,0) [CurrentPoint]
		  ,case when a.[CardTypeId] = 3 then 'http://data.sunshinegroup.vn/shome/card/card_cre.jpg' else 
		   case when a.[CardTypeId] = 2 then 'http://data.sunshinegroup.vn/shome/card/card_veh_plc.jpg' else 
		     'http://data.sunshinegroup.vn/shome/card/card_com_plc.jpg' end end as [ImageUrl]
		  ,b.FullName
		  ,s.[StatusName]
		  ,Card_St as [Status]
		  ,case when (Select count(vh.CardVehicleId) from MAS_CardVehicle vh  
					where vh.CardId = a.CardId and vh.[Status] < 3)>0 then 1 else 0 end as IsVehicle
	  FROM [MAS_Cards] a 
			INNER JOIN MAS_Customers b On a.CustId = b.CustId 
			inner join MAS_CardTypes c on a.CardTypeId = c.CardTypeId 
			join MAS_Apartment_Card ac on a.CardId = ac.CardId 
			inner join MAS_Apartments d on ac.ApartmentId = d.ApartmentId 
			left join MAS_Points p on p.CustId = b.CustId
			inner join MAS_CardStatus s on a.Card_St = s.StatusId
	  WHERE RoomCode = @roomCode 
	  ORDER BY c.Post
	  
	  --4 vehicles
	  SELECT CardVehicleId
		  ,convert(nvarchar(10),a.[AssignDate],103) [AssignDate]
		  ,[VehicleNo]
		  ,a.[VehicleTypeID]
		  ,f.VehicleTypeName
		  ,[VehicleName]
		  ,convert(nvarchar(10),a.[StartTime],103) [StartTime]
		  ,convert(nvarchar(10),a.[EndTime],103) [EndTime]
		  ,a.ServiceId
		  --,ServiceName
		  ,a.[Status]
		  --,case when c.IsLock = 1 then N'Đã khóa' else 
		  ,case a.[Status] when 0 then N'Chờ phê duyệt' when 1 then N'Đang hoạt động'  when 2 then N'Qúa hạn' else N'Đã khóa' end  [StatusName]
		  --,c.IsLock 
		  ,d.[CardCd]
		  ,a.isVehicleNone
	  FROM [dbo].[MAS_CardVehicle] a 
		--INNER JOIN MAS_Services b On a.ServiceId = b.ServiceId
		--Inner join MAS_CardService c on a.CardId = c.CardId and b.ServiceId = c.ServiceId
		INNER JOIN [MAS_Cards] d on a.CardId = d.CardId
		join MAS_Apartment_Card ac on a.CardId = ac.CardId 
		inner join MAS_Apartments e on ac.ApartmentId = e.ApartmentId 
		inner join MAS_VehicleTypes f on a.VehicleTypeId = f.VehicleTypeId 
	  WHERE RoomCode = @roomCode

	end try
	begin catch
		declare	@ErrorNum				int,
				@ErrorMsg				varchar(200),
				@ErrorProc				varchar(50),

				@SessionID				int,
				@AddlInfo				varchar(max)

		set @ErrorNum					= error_number()
		set @ErrorMsg					= 'sp_Get_Apartment_ByApartmentId ' + error_message()
		set @ErrorProc					= error_procedure()

		set @AddlInfo					= ' '

		exec utl_Insert_ErrorLog @ErrorNum, @ErrorMsg, @ErrorProc, 'SalerMonthly', 'GET', @SessionID, @AddlInfo
	end catch