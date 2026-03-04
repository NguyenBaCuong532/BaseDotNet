CREATE procedure [dbo].[sp_Cor_Get_Customer_ByKey]
@custKey	nvarchar(50) = '0987669977'

as
	begin try
	declare @custId nvarchar(50)

	if @custKey is null or @custKey = ''
		Select NULL
	else		
	--1
		set @custId = (select top 1 a.CustId 
		FROM MAS_Customers a 
		  WHERE Phone like @custKey 
			or (Pass_No like @custKey and Pass_No is not null)
		  order by sysDate )

		SELECT a.CustId 
			  ,a.[FullName]
			  ,a.[IsSex]
			  ,case when a.IsSex = 1 then N'Nam' else N'Nữ' end as SexName
			  ,convert(nvarchar(10),a.[Birthday],103) as [Birthday] 
			  ,a.[Phone]
			  ,a.[Email]
			  ,a.[Address]
			  ,a.ProvinceCd
			  ,a.[AvatarUrl]
			  ,isnull(IsForeign,0) as IsForeign
			  ,a.CountryCd
		  FROM MAS_Customers a 
		  WHERE CustId = @custId
		 -- Phone like @custKey 
			----or Email like @custKey 
			--or Pass_No like @custKey
	
		SELECT [CategoryCd]
			  ,[CategoryName]
			  ,case when CategoryLevel = 0 then [CategoryName] else '--' + [CategoryName] end as [ShowName]
			  ,CategoryLevel
		  FROM [MAS_Category] a
		WHERE exists(SELECT CategoryCd FROM [MAS_Category_Customer] b
			inner join MAS_Customers c on b.CustId = c.CustId
			WHERE CategoryCd = a.CategoryCd and 
			(c.CustId = @custId
			--Phone like @custKey 
			----or Email like @custKey 
			--or Pass_No like @custKey
			)
			)

	end try
	begin catch
		declare	@ErrorNum				int,
				@ErrorMsg				varchar(200),
				@ErrorProc				varchar(50),

				@SessionID				int,
				@AddlInfo				varchar(max)

		set @ErrorNum					= error_number()
		set @ErrorMsg					= 'sp_Get_Customer_ByKey ' + error_message()
		set @ErrorProc					= error_procedure()

		set @AddlInfo					= ' '

		exec utl_Insert_ErrorLog @ErrorNum, @ErrorMsg, @ErrorProc, 'Customer', 'GET', @SessionID, @AddlInfo
	end catch