









CREATE procedure [dbo].[sp_Crm_Customer_By_Category]
	@categoryCd	nvarchar(50),  
	@type		nvarchar(50),
	@foreign	int,
	@sex		int
as
	begin try 
	 
	if @type = 'email'
		SELECT	c.[CustId]
				,c.AvatarUrl
				,c.FullName
				,c.Email
				,c.Phone
	 FROM  [dbsHome].[dbo].[MAS_Customers] c 
	  where c.Email is not null and c.Email <> ''
		and exists(select custid from MAS_Category_Customer d where d.CustId = c.CustId and d.CategoryCd = @categoryCd)
		and (@sex = -1 or c.IsSex = @sex)
		and (@foreign = 0 
				or (@foreign = 1 and (c.IsForeign = 0 or c.IsForeign is null)) 
				or (@foreign = 2 and (c.IsForeign = 1))
				) 
	else
		SELECT	c.[CustId]
				,c.AvatarUrl
				,c.FullName
				,c.Email
				,c.Phone
	 FROM  [dbsHome].[dbo].[MAS_Customers] c 
	  where c.Phone is not null and c.Phone <> ''
		and exists(select custid from MAS_Category_Customer d where d.CustId = c.CustId and d.CategoryCd = @categoryCd)
		and (@sex = -1 or c.IsSex = @sex)
		and (@foreign = 0 
				or (@foreign = 1 and (c.IsForeign = 0 or c.IsForeign is null)) 
				or (@foreign = 2 and (c.IsForeign = 1))
				) 

	end try
	begin catch
		declare	@ErrorNum				int,
				@ErrorMsg				varchar(200),
				@ErrorProc				varchar(50),

				@SessionID				int,
				@AddlInfo				varchar(max)

		set @ErrorNum					= error_number()
		set @ErrorMsg					= 'sp_Crm_Customer_By_Category ' + error_message()
		set @ErrorProc					= error_procedure()

		set @AddlInfo					= ' '

		exec utl_Insert_ErrorLog @ErrorNum, @ErrorMsg, @ErrorProc, 'CustomerCate', 'GET', @SessionID, @AddlInfo
	end catch