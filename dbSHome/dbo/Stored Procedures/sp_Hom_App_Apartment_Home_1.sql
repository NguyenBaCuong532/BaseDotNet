











CREATE procedure [dbo].[sp_Hom_App_Apartment_Home]
	@UserId			nvarchar(450),
	@language		nvarchar(50)
as
	begin try
		declare @ApartmentId bigint
		declare @langVi bit
		if @language = 'vi-VN' or @language = 'vi' or @language = null
			set @langVi = 1
		else 
			set @langVi = 0

		--
		set @ApartmentId = (select top 1 a.ApartmentId
							FROM [MAS_Apartments] a 
								join MAS_Apartment_Member u on a.ApartmentId = u.ApartmentId 
								join UserInfo u2 on u.CustId = u2.custId 
							WHERE u2.userId = try_cast(@UserId as uniqueidentifier)
								and u.member_st = 1
								--and a.IsReceived = 1
							order by isnull(u.main_st,0) desc, u.RegDt desc)			

		if @langVi = 1
			select case when @ApartmentId > 0 then 1 else 0 end isResident
				   ,'19006077' as projectHotline
				   ,case when @ApartmentId > 0 then N'Chào mừng bạn đã là cư dân của Sunshine' else N'Ứng dụng dành riêng cho cư dân Sunshine! Bạn hãy liên hệ đến số hotline để được kích hoạt tài khoản' end  as instruction
		else
			select case when @ApartmentId > 0 then 1 else 0 end isResident
				   ,'19006077' as projectHotline
				   ,case when @ApartmentId > 0 then N'Welcome to be a resident of Sunshine' else N'Application exclusively for Sunshine residents! Please contact the hotline number to activate your account' end  as instruction
			
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
			  ,MemberCount = (Select count(CustId) from MAS_Apartment_Member where ApartmentId = a.ApartmentId)
			  ,(Select count(CardId) from MAS_Apartment_Member mm inner join MAS_Cards cc on mm.CustId = cc.CustId where mm.ApartmentId = a.ApartmentId) as CardCount
			  ,c.Phone
			  ,c.Email
			  ,a.IsReceived
			  ,convert(nvarchar(10),a.ReceiveDt,103) as ReceiveDate
			  ,a.IsRent 
			  ,'02473037999' as projectHotline
			  ,isnull(am.main_st,0) isMain
			  ,am.CustId 
			  ,cast(am.memberUserId as uniqueidentifier) userId
	  FROM [MAS_Apartments] a 
		join MAS_Rooms r on a.RoomCode = r.RoomCode 
		JOIN MAS_Buildings b On r.BuildingCd = b.BuildingCd 
		join MAS_Apartment_Member am on a.ApartmentId = am.ApartmentId 
		JOIN MAS_Customers c ON am.CustId = c.CustId
	  WHERE a.ApartmentId = @ApartmentId
		and exists(select 1 from UserInfo where userId = try_cast(@UserId as uniqueidentifier) and custid = am.CustId)
				
	--register
		SELECT ProjectName
			  ,b.ProjectCd
			  ,r.[RoomCode]
			  ,r.[Floor]
			  ,r.WaterwayArea
			  ,datediff(second,{d '1970-01-01'}, a.reg_dt) as reg_date
			  ,a.reg_st 
			  ,a.reg_st as reg_status
			  ,a.contractNo
			  ,r.floorNo
			  ,r.BuildingCd 
			  ,b.BuildingName 
			  ,a.relationId 
			  ,l.RelationName
			  ,a.Id
	  FROM [MAS_Apartment_Reg] a 
		join MAS_Rooms r on a.RoomCode = r.RoomCode 
		JOIN MAS_Buildings b On r.BuildingCd = b.BuildingCd 
		left join MAS_Customer_Relation l on a.relationId = l.RelationId 
		where a.userId = @UserId
			and a.reg_st = 0 
		order by reg_dt desc

	end try
	begin catch
		declare	@ErrorNum				int,
				@ErrorMsg				varchar(200),
				@ErrorProc				varchar(50),

				@SessionID				int,
				@AddlInfo				varchar(max)

		set @ErrorNum					= error_number()
		set @ErrorMsg					= 'sp_Hom_App_Apartment_Home' + error_message()
		set @ErrorProc					= error_procedure()

		set @AddlInfo					= ' '

		exec utl_Insert_ErrorLog @ErrorNum, @ErrorMsg, @ErrorProc, 'Apartment_Home', 'GET', @SessionID, @AddlInfo
	end catch