




CREATE procedure [dbo].[sp_Cor_Get_Customer_ByLoginName]
@userId	nvarchar(450)=null,
@loginName	nvarchar(50)='shrm_0979103942'

as
	begin try
	if not (@loginName is null or @loginName = '')
	begin
	--1
		SELECT a.CustId 
			  ,a.[FullName]
			  ,a.[IsSex]
			  ,case when a.IsSex = 1 then N'Nam' else N'Nữ' end as SexName
			  ,convert(nvarchar(10),a.[Birthday],103) as [Birthday] 
			  ,a.[Phone]
			  ,a.[Email]
			  ,isnull(p.CurrPoint,0) [CurrentPoint]
			  ,a.[AvatarUrl]
			  ,isnull(IsForeign,0) as IsForeign
			  ,isnull(Auth_St,0) as [Status]
			  ,case when isnull(Auth_St,0) = 0 then N'Mới tạo' else N'Đã phê duyệt' end as StatusName
			  ,convert(nvarchar(10),Auth_Dt,103) as AuthDate
			  ,a.[Address]
			  ,a.ProvinceCd 
			  ,a.CountryCd
			  ,cc.Cif_No as CifNo
			  ,STUFF((
				  SELECT ',' +  crmGro.GroupName 
				  FROM [dbo].[CRM_Membership] crmMem 
					join [CRM_Group] crmGro
					 on crmMem.[GroupId] = crmGro.[GroupId]
				  WHERE crmMem.CustId = a.CustId 
				  FOR XML PATH('')), 1, 1, '') as GroupName
			  ,STUFF((
				  SELECT ',' +  aa.RoomCode 
				  FROM MAS_Apartments aa 
					join MAS_Apartment_Member b on aa.ApartmentId = b.ApartmentId
				  WHERE b.CustId = a.CustId 
				  FOR XML PATH(''))+ N', Sunshine Center, Ngõ 16 Phạm Hùng', 1, 1, '') + isnull(a.[Address],'') as [Address]
			  ,STUFF((SELECT ',' +  CategoryName FROM (
				  SELECT distinct b.CategoryName , b.[CategoryCd]
				  FROM MAS_Category_Customer aa 
					join MAS_Category b on aa.CategoryCd = b.CategoryCd
				  WHERE aa.CustId = a.CustId ) t
				  ORder by t.[CategoryCd] desc
				  FOR XML PATH('')), 1, 1, '') as categoryNames
	  FROM MAS_Customers a 
		left join MAS_Points p on a.CustId = p.CustId
		left join MAS_Contacts cc on a.CustId = cc.CustId 
	  WHERE exists(select userId from UserInfo where loginName like @loginName and CustId = a.CustId)
	  --2
	   SELECT distinct [CategoryCd]
			  ,[CategoryName]
			  ,case when CategoryLevel = 0 then [CategoryName] else '--' + [CategoryName] end as [ShowName]
			  ,CategoryLevel
		  FROM [MAS_Category] a
		WHERE exists(SELECT CategoryCd FROM [MAS_Category_Customer] b
			inner join UserInfo c on b.CustId = c.CustId
			WHERE CategoryCd = a.CategoryCd and c.loginName = @loginName)
		--union all
		--SELECT 'V03' [CategoryCd]
		--	  ,N'Nhân viên' [CategoryName]
		--	  ,'--' + N'Nhân viên' as [ShowName]
		--	  ,1
		--  FROM [dbSHRM].[dbo].[Employees] a
		--	join UserInfo c on a.userId = c.userId
		--WHERE a.emp_st = 1
		--	and c.loginName = @loginName
			
	end
	else
	begin
		--1
		SELECT cc.Cif_No as CifNo
			  ,a.CustId
			  ,[FullName]
			  ,a.[IsSex]
			  ,case when a.IsSex = 1 then N'Nam' else N'Nữ' end as SexName
			  ,convert(nvarchar(10),[Birthday],103) as [Birthday] 
			  ,a.[Phone]
			  ,a.[Email]
			  ,isnull(p.CurrPoint,0) [CurrentPoint]
			  ,a.[AvatarUrl]
			  ,isnull(a.IsForeign,0) as IsForeign
			  ,isnull(a.Auth_St,0) as [Status]
			  ,case when isnull(a.Auth_St,0) = 0 then N'Mới tạo' else N'Đã phê duyệt' end as StatusName
			  ,convert(nvarchar(10),a.Auth_Dt,103) as AuthDate
			 -- ,a.[Address]
			  ,a.ProvinceCd 
			  ,a.CountryCd
			  ,STUFF((
				  SELECT ',' +  crmGro.GroupName 
				  FROM [dbo].[CRM_Membership] crmMem 
					join [CRM_Group] crmGro
					 on crmMem.[GroupId] = crmGro.[GroupId]
				  WHERE crmMem.CustId = a.CustId 
				  FOR XML PATH('')), 1, 1, '') as GroupName
			  ,STUFF((
				  SELECT ',' +  aa.RoomCode 
				  FROM MAS_Apartments aa 
					join MAS_Apartment_Member b
					 on aa.ApartmentId = b.ApartmentId
				  WHERE b.CustId = a.CustId 
				  FOR XML PATH(''))+ N', Sunshine Palace, Ngõ 13 Lĩnh Nam', 1, 1, '') + isnull(a.[Address],'') as [Address]
			  ,STUFF((SELECT ',' +  CategoryName FROM (
				  SELECT distinct b.CategoryName , b.[CategoryCd]
				  FROM MAS_Category_Customer aa 
					join MAS_Category b on aa.CategoryCd = b.CategoryCd
				  WHERE aa.CustId = a.CustId ) t
				  ORder by t.[CategoryCd] desc
				  FOR XML PATH('')), 1, 1, '') as categoryNames
	  FROM MAS_Customers a 
		  left join MAS_Points p on a.CustId = p.CustId
		  left join MAS_Contacts cc on a.CustId = cc.CustId 
	  WHERE exists(select userId from UserInfo where CustId = a.CustId and UserId = @userId)
     
	  --2
		SELECT distinct [CategoryCd]
			  ,[CategoryName]
			  ,case when CategoryLevel = 0 then [CategoryName] else '--' + [CategoryName] end as [ShowName]
			  ,CategoryLevel
		  FROM [MAS_Category] a
		WHERE exists(SELECT CategoryCd FROM [MAS_Category_Customer] b
			inner join UserInfo c on b.CustId = c.CustId
			WHERE b.CategoryCd = a.CategoryCd and c.UserId = @userId)
		--union all
		--SELECT 'V03' [CategoryCd]
		--	  ,N'Nhân viên' [CategoryName]
		--	  ,'--' + N'Nhân viên' as [ShowName]
		--	  ,1
		--  FROM [dbSHRM].[dbo].[Employees] a
		--WHERE a.emp_st = 1
		--	and a.UserId = @userId
		--ORder by [CategoryCd] desc

	end
	end try
	begin catch
		declare	@ErrorNum				int,
				@ErrorMsg				varchar(200),
				@ErrorProc				varchar(50),

				@SessionID				int,
				@AddlInfo				varchar(max)

		set @ErrorNum					= error_number()
		set @ErrorMsg					= 'sp_Cor_Get_Customer_ByLoginName ' + error_message()
		set @ErrorProc					= error_procedure()

		set @AddlInfo					= '@loginName ' + @loginName

		exec utl_Insert_ErrorLog @ErrorNum, @ErrorMsg, @ErrorProc, 'Customer', 'GET', @SessionID, @AddlInfo
	end catch