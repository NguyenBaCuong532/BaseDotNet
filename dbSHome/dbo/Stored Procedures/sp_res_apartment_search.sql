








CREATE procedure [dbo].[sp_res_apartment_search]
	@UserId UNIQUEIDENTIFIER = NULL,
	@AcceptLanguage VARCHAR(20) = 'vi-VN',
	@ProjectCd		nvarchar(30),
	@buildingCd		nvarchar(30) = null,
	@buildingOid     uniqueidentifier = null,
	@filter			nvarchar(50)
as

	begin try
		set @filter		= isnull(@filter,'')
		set @buildingCd	= isnull(@buildingCd,'')
	--1 profile (Updated: JOIN by apartOid/oid)
		SELECT ProjectName
			  ,b.ProjectCd
			  ,a.[ApartmentId]
			  ,a.oid AS apartOid
			  ,BuildingName
			  ,a.[RoomCode]
			  ,c.FullName
			  ,c.AvatarUrl
			  ,ef.FloorNumber as [Floor]
			  ,a.WaterwayArea
			  ,a.[UserLogin]
			  ,a.[Cif_No] 
			  ,c.CustId
			  ,b.[BuildingCd]
			  ,b.oid AS buildingOid   -- thêm
			  ,[FamilyImageUrl]
			  ,c.Phone
			  ,c.Email
			  
			  ,a.IsReceived
			  ,convert(nvarchar(10),a.ReceiveDt,103) as ReceiveDate
			  ,a.IsRent 
			  ,a.isMain
	  FROM [MAS_Apartments] a 
			LEFT JOIN MAS_Buildings b On a.buildingOid = b.oid 
			LEFT JOIN MAS_Elevator_Floor ef ON a.floorOid = ef.oid
			JOIN dbo.MAS_Apartment_Member m ON (m.apartOid = a.oid OR (m.apartOid IS NULL AND m.ApartmentId = a.ApartmentId))
			JOIN dbo.MAS_Customers c ON m.custID = C.custID  			
	  WHERE a.projectCd = @ProjectCd
		AND (
        (@buildingOid IS NOT NULL AND a.buildingOid = @buildingOid)  -- ưu tiên GUID
     OR (@buildingOid IS NULL AND (@buildingCd = '' OR b.BuildingCd = @buildingCd)) 
    )
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
		set @ErrorMsg					= 'sp_res_apartment_search ' + error_message()
		set @ErrorProc					= error_procedure()

		set @AddlInfo					= ' '

		exec utl_Insert_ErrorLog @ErrorNum, @ErrorMsg, @ErrorProc, 'Apartment', 'GET', @SessionID, @AddlInfo

	end catch