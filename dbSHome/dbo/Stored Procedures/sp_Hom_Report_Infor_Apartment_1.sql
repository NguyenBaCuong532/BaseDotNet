-- =============================================
-- Author:		<Khoanv>
-- Description:	<Báo cáo thông tin cư dân theo dự án ngày đến,Báo cáo số lượng, thông tin chi tiết cư dân đến và đi theo căn hộ và theo thời gian>
-- =============================================
-- exec sp_Hom_Service_Request null, null, 0, 100, NULL, '2017-01-01', '2021-12-01' 
CREATE PROCEDURE [dbo].[sp_Hom_Report_Infor_Apartment]
	@userId				NVARCHAR(450),
	@projectCd 			NVARCHAR(10),
	--@Offset				INT	= 0,
	--@PageSize			INT	= 10,
	--@Filter             NVARCHAR(100),
	@fromDate 			Datetime, 
	@toDate 			Datetime

AS
   BEGIN TRY
		select * from (

  	SELECT a.CustId 
		  ,a.[FullName]
		  ,a.[IsSex]
		  ,case when a.[IsSex] = 1 then N'Nam' else N'Nữ' end as SexName
		  ,convert(nvarchar(10),a.birthday,103) as birthday
		  ,a.[Phone]
		  ,a.[Email]
		 -- ,case when exists(select ApartmentId from MAS_Apartments ma 
			--join UserInfo mu on ma.UserLogin = mu.UserLogin 
			--	where mu.CustId = a.CustId and ma.ApartmentId = b.ApartmentId) then 1 else 0 end as [IsHost]
		  ,b.[ApartmentId]
		  --,isnull(p.CurrPoint,0) as [CurrentPoint]
		  --,a.[AvatarUrl]
		  ,isnull(a.IsForeign,0) as IsForeign
		  ,isnull(b.member_St,1) as [Status]
		  ,case when isnull(b.member_St,1) = 0 then N'Chờ phê duyệt' else N'Đã phê duyệt' end as StatusName
		  ,convert(nvarchar(10),a.Auth_Dt,103) as AuthDate
		  ----,a.CustId
		  --,b.RelationId
		  ,isnull(d.RelationName,N'Khác') as RelationName
		  ,userId = b.memberUserId
		  ,b.isNotification
		  ,case when b.memberUserId is not null or exists(select userid from UserInfo mu 
				where mu.CustId = a.CustId and mu.userType = 2) then 1 else 0 end as isApp
		  ,a.CountryCd
		  ,g.CountryName
	  FROM [MAS_Customers] a 
		join MAS_Apartment_Member b on a.CustId = b.CustId 
			left join MAS_Customer_Relation d on b.RelationId = d.RelationId
			left join [COR_Countries] g on a.CountryCd = g.CountryCd 
	
		UNION ALL
	SELECT a.CustId 
		  ,a.[FullName]
		  ,a.[Sex] as [IsSex]
		  ,case when a.[Sex] = 1 then N'Nam' else N'Nữ' end as SexName
		  ,convert(nvarchar(10),a.birthday,103) as birthday
		  ,a.[Phone]
		  ,a.[Email]
		  --,0 [IsHost]
		  ,p.[ApartmentId]
		  --,isnull(p.CurrPoint,0) as [CurrentPoint]
		  --,a.[AvatarUrl]
		  ,case when a.res_Cntry = 'VN' or a.res_Cntry is null then 0 else 1 end as IsForeign
		  ,0 as [Status]
		  , N'Chờ phê duyệt' as StatusName
		  ,null as AuthDate
		  --,a.CustId
		  --,b.RelationId
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
	  WHERE  b.reg_st = 0
		and not exists(select * from MAS_Apartment_Member am join MAS_Customers cc on am.CustId = cc.CustId where am.ApartmentId = p.ApartmentId and am.CustId = a.custId and am.memberUserId = b.userId)
	 
	)as ab
			
			inner join MAS_Apartments y on y.ApartmentId = ab.ApartmentId
			inner join MAS_Rooms r on y.RoomCode = r.RoomCode 
					INNER JOIN MAS_Buildings b On r.BuildingCd = b.BuildingCd 
			where y.projectCd =  @projectCd and y.ReceiveDt BETWEEN @fromDate AND @toDate
			 order by r.BuildingCd, r.Floor,  ab.ApartmentId, ab.FullName  

				select projectCd, projectName from mas_Projects where ProjectCd =  @projectCd
    END TRY

begin catch
    declare	@ErrorNum				int = error_number(),
            @ErrorMsg				varchar(200) = 'sp_Hom_Report_Infor_Apartment ' + error_message(),
            @ErrorProc				varchar(50) = error_procedure(),

            @SessionID				int,
            @AddlInfo				varchar(max) = ' - @userId ' + @userId

    exec utl_Insert_ErrorLog @ErrorNum, @ErrorMsg, @ErrorProc, 'sp_Hom_Report_Infor_Apartment', 'GET', @SessionID, @AddlInfo
end catch