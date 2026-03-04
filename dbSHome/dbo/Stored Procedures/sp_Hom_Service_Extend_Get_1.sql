





CREATE procedure [dbo].[sp_Hom_Service_Extend_Get]
	@UserId nvarchar(450),
	@ExtendId int
as
	begin try		
		--1
		SELECT ProjectName
			  ,a.[ApartmentId]
			  ,r.[RoomCode]
			  ,FullName as CustomerName
			  ,d.ExtendId
			  ,d.ContractTypeId
			  ,d.ProviderCd
			  ,[ContractNo]
			  ,convert(nvarchar(10),[ContractDt],103) as [ContractDate]
			  --,[ContractUrl]
			  --,convert(nvarchar(10),[ExpireDt],103) as [ExpireDate]
			  ,d.[IsClose]
			  ,d.[CloseDt]
			  ,ProviderName
			  ,d.CustId
			  --,d.IdCard
			  --,convert(nvarchar(10),d.IssueDt,103) as IssueDate
			  --,d.IssueBy
			  ,f.ContractTypeName
			  ,d.ProjectCd
			  ,d.IsCompany
			  ,d.CompanyName
			  ,d.CompanyRepresent
			  ,d.CompanyCode
			  ,d.CompanyAddress
	  
	  FROM [MAS_Apartments] a  
			inner join MAS_Rooms r on a.RoomCode = r.RoomCode 
			INNER JOIN MAS_Buildings b On r.BuildingCd = b.BuildingCd
			inner join MAS_Apartment_Service_Extend d on d.ApartmentId = a.ApartmentId 
			left join MAS_ServiceProvider e on d.ProviderCd = e.ProviderCd
			inner join MAS_contractTypes f on d.ContractTypeId = f.ContractTypeId
			left JOIN MAS_Customers c ON d.CustId = c.CustId 
	  WHERE d.ExtendId = @ExtendId 
	
	--2
	--SELECT [DeviceId]
	--	  ,[ContractId]
	--	  ,[DeviceSerial]
	--	  ,[DeviceName]
	--	  ,[DeviceWarranty]
	--	  ,[UserType]
	--	  ,[UserName]
	--	  ,[UserPassword]
	--	  ,[MeterSeri]
	--	  ,[MeterDateStart]
	--	  ,[MeterNumStart]
	--  FROM [TRS_Service_ContractDevice]
	--  WHERE ContractId = @ContractId 
	
	----3
	--SELECT a.[SchedulePayId]
	--	  ,a.[ContractId]
	--	  ,a.[PayType]
	--	  ,a.[ContractPriceId]
	--	  ,a.[Term]
	--	  ,a.[Extant]
	--	  ,a.[ExpireDate]
	--	  ,a.[BasePrice]
	--	  ,a.[DevicePrice]
	--	  ,a.[TermPrice]
	--	  ,a.[TotalAmount]
	--	  ,a.[AutoRenewal]
	--	  ,a.[lastReceivable]
	--	  ,b.PriceCode
	--	  ,b.PriceName
	--  FROM [TRS_Service_ContractSchedulePay] a
	--	join PAR_TelecomPrice b on a.ContractPriceId = b.PriceId
	--  WHERE ContractId = @ContractId 


	end try
	begin catch
		declare	@ErrorNum				int,
				@ErrorMsg				varchar(200),
				@ErrorProc				varchar(50),

				@SessionID				int,
				@AddlInfo				varchar(max)

		set @ErrorNum					= error_number()
		set @ErrorMsg					= 'sp_Get_Telecom_Contract_ById ' + error_message()
		set @ErrorProc					= error_procedure()

		set @AddlInfo					= ' '

		exec utl_Insert_ErrorLog @ErrorNum, @ErrorMsg, @ErrorProc, 'Partner', 'GET', @SessionID, @AddlInfo
	end catch