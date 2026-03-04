








CREATE procedure [dbo].[sp_Crm_Customer_By_Group]
	@GroupId	int,
	@type		nvarchar(50),
	@foreign	int,
	@sex		int
as
	begin try 
	 
	if @type = 'email'
		SELECT	a.[CustId]
				,c.AvatarUrl
				,c.FullName
				,c.Email
				,c.Phone
		 FROM [dbSHome].[dbo].[CRM_Customer] a
			  join [dbsHome].[dbo].[MAS_Customers] c on a.[CustId] = c.[CustId]   
			  join CRM_Membership cm on a.CustId = cm.CustId
			  join CRM_Group cg on cm.GroupId = cg.GroupId
		  where c.Email is not null and c.Email <> ''
			and cg.GroupId = @GroupId 
			and (@sex = -1 or c.IsSex = @sex)
			and (@foreign = 0 
				or (@foreign = 1 and (c.IsForeign = 0 or c.IsForeign is null)) 
				or (@foreign = 2 and (c.IsForeign = 1))
				) 
	else
		SELECT	a.[CustId]
				,c.AvatarUrl
				,c.FullName
				,c.Email
				,c.Phone
		 FROM [dbSHome].[dbo].[CRM_Customer] a
			  join [dbsHome].[dbo].[MAS_Customers] c on a.[CustId] = c.[CustId]   
			  join CRM_Membership cm on a.CustId = cm.CustId
			  join CRM_Group cg on cm.GroupId = cg.GroupId
		  where c.Phone is not null and c.Phone <> ''
			and cg.GroupId = @GroupId 
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
		set @ErrorMsg					= 'sp_Crm_Customer_By_Group' + error_message()
		set @ErrorProc					= error_procedure()

		set @AddlInfo					= ' '

		exec utl_Insert_ErrorLog @ErrorNum, @ErrorMsg, @ErrorProc, 'Customer', 'GET', @SessionID, @AddlInfo
	end catch