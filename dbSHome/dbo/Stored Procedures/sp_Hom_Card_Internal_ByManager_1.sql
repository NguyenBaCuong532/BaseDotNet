CREATE procedure [dbo].[sp_Hom_Card_Internal_ByManager]
	@userId			nvarchar(50)=null,
	@clientId		nvarchar(50)=null,
	@departmentCd	nvarchar(50)=null,
	@filter			nvarchar(30) = '030471',
	@Statuses			int = null,
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
		set		@departmentCd			= isnull(@departmentCd,'')
		set		@Statuses				= isnull(@Statuses,-1)

		if		@PageSize	= 0			set @PageSize	= 10
		if		@Offset		< 0			set @Offset		=  0

		select	@Total					= count(a.CardId)
			FROM [MAS_Cards] a 
				join MAS_Customers c on a.CustId = c.CustId
				join [dbSHRM].[dbo].[Employees] e on a.CustId = e.CustId
				--left join HRM_Departments md on e.DepartmentCd = md.DepartmentCd 
			WHERE a.CardTypeId = 2 
				and a.IsVip = 1 
				and (@Statuses = -1 or a.Card_St = @Statuses)
				--and (@departmentCd = '' or md.DepartmentCd = @departmentCd)
				and (CardCd like '%' + @filter + '%' or c.Phone like '%' + @filter + '%' or c.FullName like '%' + @filter + '%' )
				

		set	@TotalFiltered = @Total

		if @PageSize < 0
		begin
			set	@PageSize				= 10
		end
	
		--1
		SELECT a.[CardCd]
			  ,convert(nvarchar(10),a.[IssueDate],103) [IssueDate]
			  ,s.[StatusName]
			  ,a.Card_St as [Status]
			  ,c.FullName
			  ,a.IsClose 
			  ,a.CloseDate 
			  ,c.Phone
			  ,c.Email
			  --,e.Position
			  ,a.CardName
			  ,a.CustId
			  ,isnull(p.CurrPoint,0) as [CurrentPoint]
			  ,case when exists(select CardId from MAS_CardVehicle where cardid = a.CardId) then 1 else 0 end IsVihecle
			  --,md.DepartmentName 
	  FROM [dbo].[MAS_Cards] a 
			inner join MAS_Customers c on a.CustId = c.CustId
			inner join MAS_CardStatus s on a.Card_St = s.StatusId
			join [dbSHRM].[dbo].[Employees] e on a.CustId = e.CustId
			left join MAS_Points p on a.CustId = p.CustId 
			--left join HRM_Departments md on e.DepartmentCd = md.DepartmentCd 
		WHERE a.CardTypeId = 2 
				and a.IsVip = 1 
				and (@Statuses = -1 or a.Card_St = @Statuses)
				--and (@departmentCd = '' or md.DepartmentCd = @departmentCd)
				and (CardCd like '%' + @filter + '%' or c.Phone like '%' + @filter + '%' or c.FullName like '%' + @filter + '%' )
		ORDER BY a.CardCd
		  offset @Offset rows	
			fetch next @PageSize rows only
	  
	--2
	
	end try
	begin catch
		declare	@ErrorNum				int,
				@ErrorMsg				varchar(200),
				@ErrorProc				varchar(50),

				@SessionID				int,
				@AddlInfo				varchar(max)

		set @ErrorNum					= error_number()
		set @ErrorMsg					= 'sp_Hom_Get_Card_Internal_ByManager ' + error_message()
		set @ErrorProc					= error_procedure()

		set @AddlInfo					= ' '

		exec utl_Insert_ErrorLog @ErrorNum, @ErrorMsg, @ErrorProc, 'CardInternal', 'GET', @SessionID, @AddlInfo
	end catch