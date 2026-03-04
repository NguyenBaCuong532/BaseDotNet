





CREATE procedure [dbo].[sp_Hom_Apartment_Member_ByCustId]
	@UserId	nvarchar(450),	
	@CustId	nvarchar(50),	
	@apartmentId int

as
	begin try
	
	--1
	if (@apartmentId is null or @apartmentId = 0)
		SELECT a.CustId 
			  ,a.[FullName]
			  ,a.[IsSex]
			  ,case when a.IsSex = 1 then N'Nam' else N'Nữ' end as SexName
			  ,convert(nvarchar(10),a.[Birthday],103) as [Birthday] 
			  ,a.[Phone]
			  ,a.[Email]
			  ,a.[IsHost]
			  ,a.[ApartmentId]
			  ,isnull(b.CurrPoint,0) as [CurrentPoint]
			  ,a.[AvatarUrl]
			  ,isnull(a.IsForeign,0) as IsForeign
			  ,isnull(a.Auth_St,0) as [Status]
			  ,case when isnull(a.Auth_St,0) = 0 then N'Mới tạo' else N'Đã phê duyệt' end as StatusName
			  ,convert(nvarchar(10),a.Auth_Dt,103) as AuthDate
			  ,(SELECT TOP 1 [imageUrl] FROM [MAS_Customer_Image] where CustId = a.CustId and Imagetype = 1) as FaceRecogUrl1
			  ,(SELECT TOP 1 [imageUrl] FROM [MAS_Customer_Image] where CustId = a.CustId and Imagetype = 2) as FaceRecogUrl2
			  ,(SELECT TOP 1 [imageUrl] FROM [MAS_Customer_Image] where CustId = a.CustId and Imagetype = 3) as FaceRecogUrl3
			  ,(SELECT TOP 1 [imageUrl] FROM [MAS_Customer_Image] where CustId = a.CustId and Imagetype = 4) as FaceRecogUrl4
			  ,(SELECT TOP 1 [imageUrl] FROM [MAS_Customer_Image] where CustId = a.CustId and Imagetype = 5) as FaceRecogUrl5
			  ,a.CountryCd
	  FROM MAS_Customers a 
		left join MAS_Points b on a.CustId = b.CustId 
	  WHERE a.CustId = @CustId
		and exists(select ma.ApartmentId from MAS_Apartments ma 
			inner join UserInfo b on ma.UserLogin = b.loginName 
			inner join MAS_Apartment_Member d on ma.ApartmentId = d.ApartmentId
			where d.CustId = a.CustId 
				and (b.UserId = @UserId
					or exists(select userid from UserInfo where CustId = b.CustId and UserId = @UserId)
					)
				)
	else
		SELECT a.CustId 
			  ,a.[FullName]
			  ,a.[IsSex]
			  ,case when a.IsSex = 1 then N'Nam' else N'Nữ' end as SexName
			  ,convert(nvarchar(10),a.[Birthday],103) as [Birthday] 
			  ,a.[Phone]
			  ,a.[Email]
			  ,a.[IsHost]
			  ,a.[ApartmentId]
			  ,isnull(b.CurrPoint,0) as [CurrentPoint]
			  ,a.[AvatarUrl]
			  ,isnull(a.IsForeign,0) as IsForeign
			  ,isnull(a.Auth_St,0) as [Status]
			  ,case when isnull(a.Auth_St,0) = 0 then N'Mới tạo' else N'Đã phê duyệt' end as StatusName
			  ,convert(nvarchar(10),a.Auth_Dt,103) as AuthDate
			  ,(SELECT TOP 1 [imageUrl] FROM [MAS_Customer_Image] where CustId = a.CustId and Imagetype = 1) as FaceRecogUrl1
			  ,(SELECT TOP 1 [imageUrl] FROM [MAS_Customer_Image] where CustId = a.CustId and Imagetype = 2) as FaceRecogUrl2
			  ,(SELECT TOP 1 [imageUrl] FROM [MAS_Customer_Image] where CustId = a.CustId and Imagetype = 3) as FaceRecogUrl3
			  ,(SELECT TOP 1 [imageUrl] FROM [MAS_Customer_Image] where CustId = a.CustId and Imagetype = 4) as FaceRecogUrl4
			  ,(SELECT TOP 1 [imageUrl] FROM [MAS_Customer_Image] where CustId = a.CustId and Imagetype = 5) as FaceRecogUrl5
			  ,a.CountryCd
			  ,ma.memberUserId userId
			  ,isnull(u.loginName, 'ssupapp_' + a.Phone) as loginname
	  FROM MAS_Customers a 
		join MAS_Apartment_Member ma on ma.CustId = a.CustId
		left join UserInfo u on ma.memberUserId = u.UserId and u.CustId = ma.CustId
		left join MAS_Points b on a.CustId = b.CustId 
	  WHERE a.CustId = @CustId
		and ma.ApartmentId = @apartmentId
		--and exists(select ma.ApartmentId from MAS_Apartments ma 
		--	--inner join UserInfo b on ma.UserLogin = b.UserLogin 
		--	inner 
		--	where d.CustId = a.CustId and d.ApartmentId = @apartmentId)

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