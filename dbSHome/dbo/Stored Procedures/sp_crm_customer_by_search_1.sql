










CREATE procedure [dbo].[sp_crm_customer_by_search]
	@UserId nvarchar(450),
	@custIds nvarchar(max) = null,
	@filter nvarchar(50) = null
as
	begin try 
			declare @tbCusts TABLE 
			(
				custId uniqueidentifier null
			)

			if @custIds is not null
			begin
				insert into @tbCusts 
				select part from [dbo].SplitString(@custIds,',')
			end

			select value		= lower(cast(c.custId as varchar(50)))
				  ,name			= c.FullName ---+ ' - ' + isnull(pt.positionTypeName,'')
				  ,icon_is		= 1
				  ,icon			= c.AvatarUrl
			 FROM [MAS_Customers] c 
			  where (c.CustId in (select custId from @tbCusts)
				or c.Email = @filter 
				or c.phone = @filter
				or c.FullName like @filter
				)
		
		--and exists(select custid from MAS_Category_Customer d where d.CustId = c.CustId and d.CategoryCd = @categoryCd)
		--and (@sex = -1 or c.IsSex = @sex)
		--and (@foreign = 0 
		--		or (@foreign = 1 and (c.IsForeign = 0 or c.IsForeign is null)) 
		--		or (@foreign = 2 and (c.IsForeign = 1))
		--		) 
	--else
	--	SELECT	c.[CustId]
	--			,c.AvatarUrl
	--			,c.FullName
	--			,c.Email
	--			,c.Phone
	-- FROM  [dbsHome].[dbo].[MAS_Customers] c 
	--  where c.Phone is not null and c.Phone <> ''
	--	and exists(select custid from MAS_Category_Customer d where d.CustId = c.CustId and d.CategoryCd = @categoryCd)
	--	and (@sex = -1 or c.IsSex = @sex)
	--	and (@foreign = 0 
	--			or (@foreign = 1 and (c.IsForeign = 0 or c.IsForeign is null)) 
	--			or (@foreign = 2 and (c.IsForeign = 1))
	--			) 

	end try
	begin catch
		declare	@ErrorNum				int,
				@ErrorMsg				varchar(200),
				@ErrorProc				varchar(50),

				@SessionID				int,
				@AddlInfo				varchar(max)

		set @ErrorNum					= error_number()
		set @ErrorMsg					= 'sp_crm_customer_by_search ' + error_message()
		set @ErrorProc					= error_procedure()

		set @AddlInfo					= ' '

		exec utl_Insert_ErrorLog @ErrorNum, @ErrorMsg, @ErrorProc, 'CustomerCate', 'GET', @SessionID, @AddlInfo
	end catch