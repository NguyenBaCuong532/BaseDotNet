CREATE procedure [dbo].[sp_Hom_Card_Internal_ByExport]
	@filter	nvarchar(50),
	@Statuses int = null
as
	begin try
		declare @tbIsUse TABLE 
		(
			Id [Int] null
		)
		if	@Statuses is null or @Statuses = -1 
			insert into @tbIsUse (Id) select 0 union select 1 union select 2 union select 3 
		else
		begin
			if @Statuses = 2 
				set @Statuses = 3
			insert into @tbIsUse (Id) select @Statuses
		end

	--1
		set @filter = isnull(@filter,'')

		SELECT ROW_NUMBER() OVER(ORDER BY CardCd ASC) as STT 
			  ,a.[CardCd] MaThe
			  ,convert(nvarchar(10),a.[IssueDate],103) NgayCapThe
			  ,s.StatusName TrangThai
			  ,c.FullName TenNguoiDung
			  ,c.Phone DienThoai
			  ,c.Email Email
			  ,a.CardName TenThe
			  ,b.Card_Hex MaTheThangMay
			  --,f.DepartmentName PhongBan
	  FROM [dbo].[MAS_Cards] a 
			inner join MAS_CardBase b on b.Code = a.CardCd
			left join [dbSHRM].[dbo].[Employees] e on a.CustId = e.CustId
			left join MAS_Customers c on a.CustId = c.CustId
			--left join HRM_Departments f on e.DepartmentCd = f.DepartmentCd
			inner join MAS_CardStatus s on a.Card_St = s.StatusId
		WHERE a.CardTypeId = 2 
			and a.IsVip = 1 
			and (CardCd like '%' + @filter + '%' or c.Phone like '%' + @filter + '%' or c.FullName like '%' + @filter + '%' )
			and Card_St in (select Id from @tbIsUse)
		ORDER BY CardCd DESC
	

	--2
	
	end try
	begin catch
		declare	@ErrorNum				int,
				@ErrorMsg				varchar(200),
				@ErrorProc				varchar(50),

				@SessionID				int,
				@AddlInfo				varchar(max)

		set @ErrorNum					= error_number()
		set @ErrorMsg					= 'sp_Get_Card_Export_Vip_ByManager ' + error_message()
		set @ErrorProc					= error_procedure()

		set @AddlInfo					= ' '

		exec utl_Insert_ErrorLog @ErrorNum, @ErrorMsg, @ErrorProc, 'CardExport', 'GET', @SessionID, @AddlInfo
	end catch