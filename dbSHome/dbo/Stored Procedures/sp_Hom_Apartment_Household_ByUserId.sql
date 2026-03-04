





CREATE procedure [dbo].[sp_Hom_Apartment_Household_ByUserId]
	@UserId	nvarchar(450),
	@ApartmentId int

as
	begin try
	if @ApartmentId is null or @ApartmentId = 0
		set @ApartmentId = (SELECT top 1 c.ApartmentId FROM UserInfo a 
			inner join MAS_Apartments c on a.loginName = c.UserLogin 
		 WHERE a.UserId = @UserID)
	--1
	
	SELECT a.CustId 
		  ,a.[FullName]
		  ,case when a.[IsSex] = 1 then N'Nam' else N'Nữ' end as SexName
		  ,convert(nvarchar(10),a.birthday,103) as birthday
		  ,a.[Phone]
		  ,a.[Email]
		  ,a.[IsHost]
		  ,c.[ApartmentId]
		  ,a.[AvatarUrl]
		  ,isnull(a.IsForeign,0) as IsForeign
		  
		  ,isnull(b.[IsResident],0) IsResident
		  ,b.[ResAdd1]
		  ,b.[ContactAdd1]
		  ,b.[Pass_No] as PassNo
		  ,convert(nvarchar(10),b.[Pass_I_Dt],103) as PassDate 
		  ,b.[Pass_I_Plc] as PassPlace
		  ,d.RelationName
	  FROM [MAS_Customers] a 
		left join [MAS_Customer_Household] b ON a.CustId = b.CustId
		join MAS_Apartment_Member c on a.CustId = c.CustId 
		left join MAS_Customer_Relation d on c.RelationId = d.RelationId 
	WHERE EXISTS(SELECT [ApartmentId] FROM MAS_Apartment_Member WHERE CustId = a.CustId AND ApartmentId = @ApartmentId)
		and c.ApartmentId = @ApartmentId
		  ORDER BY [IsHost] desc, b.sysDate desc
	

	end try
	begin catch
		declare	@ErrorNum				int,
				@ErrorMsg				varchar(200),
				@ErrorProc				varchar(50),

				@SessionID				int,
				@AddlInfo				varchar(max)

		set @ErrorNum					= error_number()
		set @ErrorMsg					= 'sp_Get_Aparment_Household_ByUserId ' + error_message()
		set @ErrorProc					= error_procedure()

		set @AddlInfo					= ' '

		exec utl_Insert_ErrorLog @ErrorNum, @ErrorMsg, @ErrorProc, 'Customer', 'GET', @SessionID, @AddlInfo
	end catch