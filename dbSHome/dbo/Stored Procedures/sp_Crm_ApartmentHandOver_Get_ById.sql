








CREATE procedure [dbo].[sp_Crm_ApartmentHandOver_Get_ById]
	@UserId	nvarchar(450), 
	@HandOverId bigint
as
	begin try 
		declare @TypeDepartmentUser int
		--set @TypeDepartmentUser = (select top 1 kc.Type from  MAS_Employees a 
		--	inner join Hrm_Departments d on a.DepartmentCd = d.DepartmentCd
		--	inner join MAS_Customers b on a.CustId = b.CustId
		--	inner join  c on b.CustId = c.CustId
		--	inner join CRM_Apartment_HandOver_User kt on c.UserId = kt.UserId
		--	inner join CRM_Apartment_HandOver_Team kc on d.DepartmentCd = kc.DepartmentCd
		--	where kt.UserId = @UserId
		--	)
			

		SELECT [HandOverId]
			  ,[TitleHandOver]
			  ,[OutDateHandOver]	
			  ,[RequestDateCus]
			  ,[BuildingCd]
			  ,[ProjectCd]
			  ,isnull(@TypeDepartmentUser,0) as TypeDepartmentUser
			  ,[IsClose]
			  ,[Created]
			  ,[CreatedBy]
			  ,[Modified]
			  ,[ModifiedBy]
		  FROM [dbo].[CRM_Apartment_HandOver]
		  WHERE HandOverId = @HandOverId

		  SELECT [HandOverDetailId]
			  ,[HandOverId]
			  ,[ContractId]
			  ,[RoomCd]
			  ,[RoomCode]
			  ,[CustomerName]
			  ,[PhoneNumber]
			  ,[BuildingCd]
			  ,[ProjectCd]
			  ,[HandOverExpectedDate]
			  ,[RequestDateCus]
			  ,[IsPMCheck]
			  ,[IsKTCheck]
			  ,[IsBNTCheck]
			  ,[IsAgreeReceive]
			  ,[IsComplete]
			  ,[Created]
			  ,[CreatedBy]
			  ,[Modified]
			  ,[ModifiedBy]
		  FROM [dbo].[CRM_Apartment_HandOver_Detail]
		  WHERE HandOverId = @HandOverId

	end try
	begin catch
		declare	@ErrorNum				int,
				@ErrorMsg				varchar(200),
				@ErrorProc				varchar(50),

				@SessionID				int,
				@AddlInfo				varchar(max)

		set @ErrorNum					= error_number()
		set @ErrorMsg					= '[sp_Crm_Get_ApartmentHandOver_ById] ' + error_message()
		set @ErrorProc					= error_procedure()

		set @AddlInfo					= ' '

		exec utl_Insert_ErrorLog @ErrorNum, @ErrorMsg, @ErrorProc, 'CRM_Apartment_HandOver,CRM_Apartment_HandOver_Detail', 'GET', @SessionID, @AddlInfo
	end catch