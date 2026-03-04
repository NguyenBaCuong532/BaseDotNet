








CREATE procedure [dbo].[sp_Cor_Get_Customer_List]
	@UserId	nvarchar(450),
	@filter nvarchar(30),
	@IsEmployee			int		= -1,
	@IsContact			int		= -1,
	@IsUser				int		= -1,
	@Offset				int				= 0,
	@PageSize			int				= 10,
	@Total				int out,
	@TotalFiltered		int out
as
	begin try
		declare @tbIsUser TABLE 
		(
			Id [Int] null
		)
		declare @tbIsEmp TABLE 
		(
			Id [Int] null
		)
		declare @tbIsCont TABLE 
		(
			Id [Int] null
		)
		set		@Offset					= isnull(@Offset, 0)
		set		@PageSize				= isnull(@PageSize, 10)
		set		@Total					= isnull(@Total, 0)
		set		@filter					= isnull(@filter,'')

		if		@PageSize	= 0			set @PageSize	= 10
		if		@Offset		< 0			set @Offset		=  0
		
		if		@IsEmployee is null or @IsEmployee = -1 
			insert into @tbIsEmp (Id) select 0 union select 1 
		else
			insert into @tbIsEmp (Id) select @IsEmployee
		
		if		@IsContact is null or @IsContact = -1 
			insert into @tbIsCont (Id) select 0 union select 1 
		else
			insert into @tbIsCont (Id) select @IsContact

		if		@isUser is null or @isUser = -1 
			insert into @tbIsUser (Id) select 0 union select 1 
		else
			insert into @tbIsUser (Id) select @isUser

		select	@Total					= count(a.CustId)
			FROM MAS_Customers a 
			  WHERE isnull(IsEmployee,0) in (Select Id from @tbIsEmp) 
				and isnull(IsContact,0) in (select id from @tbIsCont)
				and (FullName like '%'+@filter+'%' or Phone like '%'+@filter+'%' or Email like '%'+@filter+'%' or Pass_No like '%'+@filter+'%')

		set	@TotalFiltered = @Total

		if @PageSize < 0
		begin
			set	@PageSize				= 10
		end
	
	--1
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
			  ,isnull(a.IsForeign,0) as IsForeign
			  ,a.CountryCd
	  FROM MAS_Customers a 
	  WHERE isnull(IsEmployee,0) in (Select Id from @tbIsEmp) 
		and isnull(IsContact,0) in (select id from @tbIsCont)
		and (FullName like '%'+@filter+'%' or Phone like '%'+@filter+'%' or Email like '%'+@filter+'%' or Pass_No like '%'+@filter+'%')
		ORDER BY sysDate DESC, FullName
				  offset @Offset rows	
					fetch next @PageSize rows only

	end try
	begin catch
		declare	@ErrorNum				int,
				@ErrorMsg				varchar(200),
				@ErrorProc				varchar(50),

				@SessionID				int,
				@AddlInfo				varchar(max)

		set @ErrorNum					= error_number()
		set @ErrorMsg					= 'sp_Get_Customer_List ' + error_message()
		set @ErrorProc					= error_procedure()

		set @AddlInfo					= ' '

		exec utl_Insert_ErrorLog @ErrorNum, @ErrorMsg, @ErrorProc, 'Customer', 'GET', @SessionID, @AddlInfo
	end catch