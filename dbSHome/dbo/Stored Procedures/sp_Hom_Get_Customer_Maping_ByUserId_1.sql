




CREATE procedure [dbo].[sp_Hom_Get_Customer_Maping_ByUserId]
	@UserId nvarchar(450)
	--@ProjectCd nvarchar(30)
as
	begin try
	
		declare @curdate date
		set @curdate = getdate()
		--1 Apartment
		--SELECT  a.[Cif_No] as base_cif
		--	,[Status]
		--	,[Cust_Type] as customer_type
		--	,[CategoryId]
		--	,[Salut] as salut
		--	,a.[Sex_Cd] as sex
		--	,a.[Birthday] as birthday
		--	,[DateOfBirth]
		--	,ISNULL(( case LEN(REPLACE(a.[Cust_Name],' ','')) when LEN(a.[Cust_Name]) - 2 then PARSENAME(REPLACE(a.[Cust_Name],' ','.'), 3) else PARSENAME(REPLACE(a.[Cust_Name],' ','.'), 4) end ),'noname') as first_name
		--	,ISNULL(( case LEN(REPLACE(a.[Cust_Name],' ','')) when LEN(a.[Cust_Name]) - 1 then null else PARSENAME(REPLACE(a.[Cust_Name],' ','.'), 2) end ),'noname') as middle_name
		--	,ISNULL(PARSENAME(REPLACE(a.[Cust_Name],' ','.'), 1),'noname') as last_name
		--	,a.[Cust_Name] as full_name
		--	,[Short_Name] as short_name
		--	,[Comp_Code] as company_code
		--	,a.[Pass_No] as passport_no
		--	,a.[Pass_I_Dt] as passport_issue_date
		--	,a.[Pass_I_Plc] as passport_issue_place
		--	,[Pass_I_By] as passport_issue_by
		--	,[Pass_E_Dt] as passport_expire_date
		--	,[Pass_No2] as identitycard_no
		--	,[Pass_I_Dt2] as identitycard_issue_date
		--	,[Pass_I_Plc2]
		--	,a.[Res_Add_1] as resident_address
		--	,a.[Res_Add_2]
		--	,(SELECT part
  --                    FROM 
  --                    [dbo].[SplitString]('N'+a.Res_Add_1, ',') where id between ((SELECT count(*)
  --                    FROM 
  --                    [dbo].[SplitString]('N'+a.Res_Add_1, ','))-2) and (SELECT count(*)
  --                    FROM 
  --                    [dbo].[SplitString]('N'+a.Res_Add_1, ','))-2) as resident_ward
		--	,(SELECT part
  --                    FROM 
  --                    [dbo].[SplitString]('N'+a.[Res_Add_1], ',') where id between ((SELECT count(*)
  --                    FROM 
  --                    [dbo].[SplitString]('N'+a.[Res_Add_1], ','))-1) and (SELECT count(*)
  --                    FROM 
  --                    [dbo].[SplitString]('N'+a.[Res_Add_1], ','))-1) as resident_district
		--	,(SELECT part
  --                    FROM 
  --                    [dbo].[SplitString]('N'+a.[Res_Add_1], ',') where id between ((SELECT count(*)
  --                    FROM 
  --                    [dbo].[SplitString]('N'+a.[Res_Add_1], ','))) and (SELECT count(*)
  --                    FROM 
  --                    [dbo].[SplitString]('N'+a.[Res_Add_1], ','))) as resident_city
		--	,a.[Res_Cntry_Cd] as resident_country
		--	,a.[Leg_Add_1] as contact_address
		--	,a.[Leg_Add_2]
		--	,a.[Leg_Add_3]
		--	, (SELECT part
  --                    FROM 
  --                    [dbo].[SplitString]('N'+a.[Leg_Add_1], ',') where id between ((SELECT count(*)
  --                    FROM 
  --                    [dbo].[SplitString]('N'+a.[Leg_Add_1], ','))-1) and (SELECT count(*)
  --                    FROM 
  --                    [dbo].[SplitString]('N'+a.[Leg_Add_1], ','))-1) as contact_district
		--	,(SELECT part
  --                    FROM 
  --                    [dbo].[SplitString]('N'+a.[Leg_Add_1], ',') where id between ((SELECT count(*)
  --                    FROM 
  --                    [dbo].[SplitString]('N'+a.[Leg_Add_1], ','))) and (SELECT count(*)
  --                    FROM 
  --                    [dbo].[SplitString]('N'+a.[Leg_Add_1], ','))) as contact_city
		--	,[Leg_Cntry_Cd] as contact_country
		--	,a.[TradingAddress] as trading_address
		--	,[TradingAddress2] 
		--	,a.[Phone_1] as mobile
		--	,[Phone_2] as phone
		--	,a.[Fax]
		--	,[Email_Id] as email
		--	,a.[Mail_To]
		--	,[Emp_Code]
		--	,[IsStaff] as is_staff
		--	,[IsVIP] as is_vip 
		--	,case when a.[Res_Cntry_Cd] = 'VN' or a.[Res_Cntry_Cd] is null then 0 else 1 end as is_foreign
		--	,[VIPText]
		--	,[Tax_St]
		--	,[Tax_Cd] as tax_code
		--	,a.[Co_Rep_Name] as company_representative_name
		--	,a.[Co_Rep_Position] as company_representative_position
		--	,a.[Co_Rep_AuthorityNo] as company_representative_decision_no
		--	,a.[Co_BRN_TaxCode] as company_tax_code
		--	,a.[Co_BRN_FirstDate] as company_registration_date
		--	,a.[Co_BRN_LastChange] as company_registration_change_date
		--	,a.[Co_BRN_LastDate] as company_registration_last_date
		--	,a.[Co_BRN_Plc] as company_registration_place
		--	,a.[BankAccount] as bank_account
		--	,a.[BankBrach] as bank_branch
		--	,a.[BankName] as bank_name
		--	,a.[Mkr_St] 
		--	,a.[Mkr_Cd] as created_by
		--	,a.[Mkr_Dt] as created_date
		--	,a.[Aut_Cd] as approved_by
		--	,a.[Aut_Dt] as appoved_date
		--	,[Open_Dt] as opening_date
		--	,[Closing_Dt] as closing_date
		--	,[IsOrder]
		--	,[IsContract]
		--	,[IsAccount]
		--	,[UserId]
		--	,[SysDate]
		--FROM [dbSCRM].[dbo].[COR_Customers] a join 
		--[dbSCRM].[dbo].viewContract b on a.Cif_No = b.Cif_No
		--WHERE b.ProjectCd =01 
		
		--select '' as lat, '' as lon

		----2 Resident
		--SELECT [Cif_No] as base_cif
		--	  ,b.Code as Code
		--	  ,b.StyleName as style
		--	  ,b.LookOutName as lookout
		--	  ,b.TypeName as room_type

		--	  ,b.WaterwayArea as clearance_area
		--	  ,b.WallArea as wall_area
		--	  ,b.BuildingName as building
		--	  ,b.FloorNo as floor_no
		--	  ,b.TypeId as number_of_room
		--	  ,a.Price 
		--	  ,a.Amount
		--	  ,c.ProjectName as project
		--	  ,b.PositionName as position
		--FROM [dbSCRM].[dbo].[COR_Contracts] a 
		--	join [dbSCRM].[dbo].[viewRoom] b on a.RoomCd = b.RoomCd 
		--	join [dbSCRM].[dbo].[BLD_Projects] c on b.ProjectCd = c.ProjectCd 

		--3 school
		SELECT ''

		

		--4 car
		SELECT [Cif_No] as base_cif
			  ,c.VehicleName as car_name
			  ,c.VehicleNo as plate
			  ,d.VehicleTypeName as car_level_type
		  FROM [dbSHome].[dbo].[MAS_Customers] a
		  join [MAS_Cards] b on a.CustId = b.CustId 
		  join MAS_CardVehicle c on b.CardId = c.CardId 
		  join [MAS_VehicleTypes] d on c.VehicleTypeId = d.VehicleTypeId 
		

		--5 car charge
		SELECT [Cif_No] as base_cif
			  ,c.VehicleName as car_name
			  ,c.VehicleNo as plate
			  ,d.VehicleTypeName as car_level_type
			  ,c.StartTime as payment_date
			  ,DATEDIFF(month, c.StartTime, c.EndTime)*(case c.VehicleTypeId when 1 then 1000000 when 2 then 180000 else 80000 end) as amount
		  FROM [dbSHome].[dbo].[MAS_Customers] a
		  join [MAS_Cards] b on a.CustId = b.CustId 
		  join MAS_CardVehicle c on b.CardId = c.CardId 
		  join [MAS_VehicleTypes] d on c.VehicleTypeId = d.VehicleTypeId 

		--6 member
		SELECT e.Cif_No as base_cif
		  ,a.[FullName]
		  ,a.[IsSex] as Sex
	  FROM [MAS_Customers] a 
			inner join MAS_Apartment_Member b on a.CustId = b.CustId 
			join MAS_Apartments c on b.ApartmentId = c.ApartmentId 
			join MAS_Users d on c.UserLogin = d.UserLogin 
			join MAS_Customers e on d.CustId = e.CustId 
			--left join MAS_Points p on a.CustId = p.CustId 

		--7 point
		SELECT [PointCd] as point_code
			  ,[PointType] as point_type
			  ,p.[CustId]
			  ,[CurrPoint] as current_point
			  ,[LastDt] as Last_Date
			  --,'Platinum' as [Priority]
			  ,(select sum(OrderAmount) from WAL_PointOrder where PointCd = p.PointCd) as total_order_amount
			  ,(select sum(CreditPoint) from WAL_PointOrder where PointCd = p.PointCd) as total_credit_point
			  ,(select sum(Point) from WAL_PointOrder where PointCd = p.PointCd) as total_debit_point
			  --,c.FullName 
			  --,'*****' + right(c.Phone ,4) as Phone
			  --,c.Email
			  ,c.Cif_No as Base_cif
		  FROM MAS_Points p 
			join MAS_Customers c on p.CustId = c.CustId

		--8
		SELECT ''

	end try
	begin catch
		declare	@ErrorNum				int,
				@ErrorMsg				varchar(200),
				@ErrorProc				varchar(50),

				@SessionID				int,
				@AddlInfo				varchar(max)

		set @ErrorNum					= error_number()
		set @ErrorMsg					= 'sp_Hom_Get_Customer_Maping_ByUserId ' + error_message()
		set @ErrorProc					= error_procedure()

		set @AddlInfo					= ' '

		exec utl_Insert_ErrorLog @ErrorNum, @ErrorMsg, @ErrorProc, 'Customer_Maping', 'GET', @SessionID, @AddlInfo
	end catch