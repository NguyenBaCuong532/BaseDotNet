
CREATE procedure [dbo].[sp_Hom_App_FamilyMember_ByUserId]
	@UserId	nvarchar(450) = null,
	@ApartmentId int = 98978

as
	begin try
		if @ApartmentId is null or @ApartmentId = 0
			set @ApartmentId = (select top 1 ApartmentId from [dbo].[fn_Hom_User_Apartment] (@userId))		
	--1
	SELECT a.CustId 
		  ,a.[FullName]
		  ,a.[IsSex]
		  ,case when a.[IsSex] = 1 then N'Nam' else N'Nữ' end as SexName
		  ,convert(nvarchar(10),a.birthday,103) as birthday
		  ,a.[Phone]
		  ,a.[Email]
		  ,case when exists(select ApartmentId from MAS_Apartments ma 
			join UserInfo mu on ma.UserLogin = mu.loginName 
				where mu.CustId = a.CustId and ma.ApartmentId = b.ApartmentId) then 1 else 0 end as [IsHost]
		  ,b.[ApartmentId]
		  --,isnull(p.CurrPoint,0) as [CurrentPoint]
		  ,a.[AvatarUrl]
		  ,isnull(a.IsForeign,0) as IsForeign
		  ,isnull(b.member_St,1) as [Status]
		  ,case when isnull(b.member_St,1) = 0 then N'Chờ phê duyệt' else N'Đã phê duyệt' end as StatusName
		  ,convert(nvarchar(10),a.Auth_Dt,103) as AuthDate
		  --,a.CustId
		  ,(SELECT TOP 1 [imageUrl] FROM [MAS_Customer_Image] where CustId = a.CustId and Imagetype = 1) as FaceRecogUrl1
		  ,(SELECT TOP 1 [imageUrl] FROM [MAS_Customer_Image] where CustId = a.CustId and Imagetype = 2) as FaceRecogUrl2
		  ,(SELECT TOP 1 [imageUrl] FROM [MAS_Customer_Image] where CustId = a.CustId and Imagetype = 3) as FaceRecogUrl3
		  ,(SELECT TOP 1 [imageUrl] FROM [MAS_Customer_Image] where CustId = a.CustId and Imagetype = 4) as FaceRecogUrl4
		  ,(SELECT TOP 1 [imageUrl] FROM [MAS_Customer_Image] where CustId = a.CustId and Imagetype = 5) as FaceRecogUrl5
		  ,b.RelationId
		  ,isnull(d.RelationName,N'Khác') as RelationName
		  ,b.memberUserId userId
		  ,b.isNotification
		  ,case when b.memberUserId is not null or exists(select userid from UserInfo mu 
				where mu.CustId = a.CustId and mu.userType = 2) then 1 else 0 end as isApp
		  ,a.CountryCd
		  ,g.CountryName
	  FROM [MAS_Customers] a 
		join MAS_Apartment_Member b on a.CustId = b.CustId 
			left join MAS_Customer_Relation d on b.RelationId = d.RelationId
			left join [COR_Countries] g on a.CountryCd = g.CountryCd 
			-- WHERE b.ApartmentId = 6120 AND b.[member_st] = 0
	  WHERE b.ApartmentId = @ApartmentId 
		 --and b.[member_st] = 1
	  --ORDER BY a.sysDate
		UNION ALL
	SELECT a.CustId 
		  ,a.[FullName]
		  ,a.[Sex] as [IsSex]
		  ,case when a.[Sex] = 1 then N'Nam' else N'Nữ' end as SexName
		  ,convert(nvarchar(10),a.birthday,103) as birthday
		  ,a.[Phone]
		  ,a.[Email]
		  ,0 [IsHost]
		  ,p.[ApartmentId]
		  --,isnull(p.CurrPoint,0) as [CurrentPoint]
		  ,a.[AvatarUrl]
		  ,case when a.res_Cntry = 'VN' or a.res_Cntry is null then 0 else 1 end as IsForeign
		  ,0 as [Status]
		  , N'Chờ phê duyệt' as StatusName
		  ,null as AuthDate
		  --,a.CustId
		  ,(SELECT TOP 1 [imageUrl] FROM [MAS_Customer_Image] where CustId = a.CustId and Imagetype = 1) as FaceRecogUrl1
		  ,(SELECT TOP 1 [imageUrl] FROM [MAS_Customer_Image] where CustId = a.CustId and Imagetype = 2) as FaceRecogUrl2
		  ,(SELECT TOP 1 [imageUrl] FROM [MAS_Customer_Image] where CustId = a.CustId and Imagetype = 3) as FaceRecogUrl3
		  ,(SELECT TOP 1 [imageUrl] FROM [MAS_Customer_Image] where CustId = a.CustId and Imagetype = 4) as FaceRecogUrl4
		  ,(SELECT TOP 1 [imageUrl] FROM [MAS_Customer_Image] where CustId = a.CustId and Imagetype = 5) as FaceRecogUrl5
		  ,b.RelationId
		  ,isnull(d.RelationName,N'Khác') as RelationName
		  ,b.userId
		  ,0 as isNotification
		  ,case when b.userid is not null then 1 else 0 end as isApp
		  ,'VN' as countryCd
		  ,N'Việt Nam' as CountryName
	  FROM UserInfo a 
		join MAS_Apartment_Reg b on a.UserId = b.userId 
		join MAS_Apartments p on b.RoomCode = p.RoomCode 
			left join MAS_Customer_Relation d on b.RelationId = d.RelationId
			--WHERE p.ApartmentId = 6120
	  WHERE 
	  p.ApartmentId = @ApartmentId 
		and 
		b.reg_st = 0
		and not exists(select * from MAS_Apartment_Member am 
		join MAS_Customers cc on am.CustId = cc.CustId 
		where am.ApartmentId = p.ApartmentId and am.CustId = a.custId and am.memberUserId = b.userId)
	  --ORDER BY a.sysDate	

	end try
	begin catch
		declare	@ErrorNum				int,
				@ErrorMsg				varchar(200),
				@ErrorProc				varchar(50),

				@SessionID				int,
				@AddlInfo				varchar(max)

		set @ErrorNum					= error_number()
		set @ErrorMsg					= 'sp_Get_FamilyMember_ByCifNo ' + error_message()
		set @ErrorProc					= error_procedure()

		set @AddlInfo					= ' '

		exec utl_Insert_ErrorLog @ErrorNum, @ErrorMsg, @ErrorProc, 'Customer', 'GET', @SessionID, @AddlInfo
	end catch