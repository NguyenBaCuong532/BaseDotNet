







CREATE procedure [dbo].[sp_Hom_Get_Service_Extend_ByManager]
	@ProjectCd	nvarchar(40),
	@extendTypeId int = 0,
	@filter nvarchar(100),
	@Offset				int				= 0,
	@PageSize			int				= 10,
	@Total				int out,
	@TotalFiltered		int out
as
	begin try
	
		set		@Offset					= isnull(@Offset, 0)
		set		@PageSize				= isnull(@PageSize, 10)
		set		@Total					= isnull(@Total, 0)
		
		set		@filter					= isnull(@filter,'')

		if		@PageSize	= 0			set @PageSize	= 10
		if		@Offset		< 0			set @Offset		=  0
		

	if @extendTypeId = 0
	begin
		select	@Total					= count(a.[ApartmentId])
			FROM [MAS_Apartments] a  
				inner join MAS_Rooms r on a.RoomCode = r.RoomCode 
				INNER JOIN MAS_Buildings b On r.BuildingCd = b.BuildingCd
				inner join MAS_Apartment_Service_Extend d on d.ApartmentId = a.ApartmentId 
				left join MAS_ServiceProvider e on d.ProviderCd = e.ProviderCd
				inner join MAS_contractTypes f on d.ContractTypeId = f.ContractTypeId
				left JOIN MAS_Customers c ON d.CustId = c.CustId 
			WHERE b.ProjectCd like @ProjectCd + '%'
				and (r.RoomCode like '%' + @filter + '%' or c.FullName like '%' + @filter +'%' or c.Phone like '%' + @filter +'%')

		set @TotalFiltered = @Total
		if @PageSize = -1 
			set @PageSize = @Total
	
		SELECT ProjectName
			  ,a.[ApartmentId]
			  ,r.[RoomCode]
			  ,c.FullName as CustName
			  ,c.Phone as CustPhone
			  ,d.ExtendId
			  ,d.ContractTypeId
			  ,d.ProviderCd
			  ,[ContractNo]
			  ,convert(nvarchar(10),[ContractDt],103) as [ContractDate]
			  ,d.ContractUser
			  ,d.ContractPassword
			  ,d.[IsClose]
			  ,d.[CloseDt]
			  ,ProviderName
			  ,d.CustId
			  ,d.DeviceSeri as DeviceSerial
			  ,convert(nvarchar(10),d.DeviceWarranty,103) as DeviceWarranty
			  ,d.DeviceName
			  ,f.ContractTypeName
			  ,d.ProjectCd
			  ,d.IsCompany
			  ,d.CompanyName
			  ,d.CompanyRepresent
			  ,d.CompanyCode
			  ,d.CompanyAddress
			  ,pp.PriceName as PackPriceName
			  ,d.PackPriceId
	  FROM [MAS_Apartments] a  
			inner join MAS_Rooms r on a.RoomCode = r.RoomCode 
			INNER JOIN MAS_Buildings b On r.BuildingCd = b.BuildingCd
			inner join MAS_Apartment_Service_Extend d on d.ApartmentId = a.ApartmentId 
			left join MAS_ServiceProvider e on d.ProviderCd = e.ProviderCd
			left join MAS_contractTypes f on d.ContractTypeId = f.ContractTypeId
			left JOIN MAS_Customers c ON d.CustId = c.CustId 
			left join PAR_TelecomPrice pp on d.PackPriceId = pp.PriceId
	  WHERE b.ProjectCd like @ProjectCd + '%'
			and (r.RoomCode like '%' + @filter + '%' or c.FullName like '%' + @filter +'%' or c.Phone like '%' + @filter +'%')
		ORDER BY  a.[RoomCode]
				  offset @Offset rows	
					fetch next @PageSize rows only

	end
	else
	begin
		select	@Total					= count(a.[ApartmentId])
			FROM [MAS_Apartments] a  
				inner join MAS_Rooms r on a.RoomCode = r.RoomCode 
				INNER JOIN MAS_Buildings b On r.BuildingCd = b.BuildingCd
				inner join MAS_Apartment_Service_Extend d on d.ApartmentId = a.ApartmentId 
				left join MAS_ServiceProvider e on d.ProviderCd = e.ProviderCd
				inner join MAS_contractTypes f on d.ContractTypeId = f.ContractTypeId
			INNER JOIN MAS_Customers c ON d.CustId = c.CustId 
			WHERE b.ProjectCd = @ProjectCd 
				and (r.RoomCode like '%' + @filter + '%' or c.FullName like '%' + @filter +'%' or c.Phone like '%' + @filter +'%')
				and d.ContractTypeId = @extendTypeId
		set @TotalFiltered = @Total
		set @TotalFiltered = @Total
		if @PageSize = -1 
			set @PageSize = @Total
	
		SELECT ProjectName
			  ,a.[ApartmentId]
			  ,r.[RoomCode]
			  ,c.FullName as CustName
			  ,c.Phone as CustPhone
			  ,d.ExtendId
			  ,d.ContractTypeId
			  ,d.ProviderCd
			  ,[ContractNo]
			  ,convert(nvarchar(10),[ContractDt],103) as [ContractDate]
			  ,d.ContractUser
			  ,d.ContractPassword
			  ,d.[IsClose]
			  ,d.[CloseDt]
			  ,ProviderName
			  ,d.CustId
			  ,d.DeviceSeri as DeviceSerial
			  ,convert(nvarchar(10),d.DeviceWarranty,103) as DeviceWarranty
			  ,d.DeviceName
			  ,f.ContractTypeName
			  ,d.ProjectCd
			  ,d.IsCompany
			  ,d.CompanyName
			  ,d.CompanyRepresent
			  ,d.CompanyCode
			  ,d.CompanyAddress
			  ,pp.PriceName as PackPriceName
			  ,d.PackPriceId
	  FROM [MAS_Apartments] a  
			inner join MAS_Rooms r on a.RoomCode = r.RoomCode 
			INNER JOIN MAS_Buildings b On r.BuildingCd = b.BuildingCd
			inner join MAS_Apartment_Service_Extend d on d.ApartmentId = a.ApartmentId 
			left join MAS_ServiceProvider e on d.ProviderCd = e.ProviderCd
			left join MAS_contractTypes f on d.ContractTypeId = f.ContractTypeId
			left JOIN MAS_Customers c ON d.CustId = c.CustId 
			left join PAR_TelecomPrice pp on d.PackPriceId = pp.PriceId
	  WHERE b.ProjectCd = @ProjectCd 
			and (r.RoomCode like '%' + @filter + '%' or c.FullName like '%' + @filter +'%' or c.Phone like '%' + @filter +'%')
			and d.ContractTypeId = @extendTypeId
		ORDER BY  a.[RoomCode]
				  offset @Offset rows	
					fetch next @PageSize rows only

	end

	end try
	begin catch
		declare	@ErrorNum				int,
				@ErrorMsg				varchar(200),
				@ErrorProc				varchar(50),

				@SessionID				int,
				@AddlInfo				varchar(max)

		set @ErrorNum					= error_number()
		set @ErrorMsg					= 'sp_Hom_Get_Service_Extend_ByManager ' + error_message()
		set @ErrorProc					= error_procedure()

		set @AddlInfo					= ' '

		exec utl_Insert_ErrorLog @ErrorNum, @ErrorMsg, @ErrorProc, 'ServExend', 'GET', @SessionID, @AddlInfo
	end catch