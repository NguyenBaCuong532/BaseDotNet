









CREATE procedure [dbo].[sp_Pay_Get_Wallet_List_ByManager]
	@userId	nvarchar(400),
	@filter nvarchar(150),
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
			 
		select	@Total					= count(a.WalletCd)
			FROM MAS_Contacts c 			
			inner join MAS_Customers d on c.CustId = d.CustId 
			inner join WAL_Profile a on a.BaseCif = c.Cif_No 
			WHERE (c.Phone like '%' + @filter + '%' or c.Email like '%' + @filter + '%' or d.FullName like '%' + @filter + '%')

		set @TotalFiltered = @Total

		if @PageSize = -1 set @PageSize = @Total
	--1 
		SELECT a.[WalletCd]
		  ,a.[BaseCif]
		  ,d.FullName
		  ,d.Phone
		  ,d.Email
		  --,u.UserLogin
		  --,u.AvatarUrl
		  ,a.PaymentLimit
		  ,a.CreateDt as CreateDate
		  ,case when a.LastDt is null then 0 else 1 end as isActived
		  ,a.LastDt as lastLoginDate
		  ,(select max(TxnDt) from WAL_Transactions where fromWalletCd = a.WalletCd or toWalletCd = a.WalletCd) as lastTransactionDate
		FROM MAS_Contacts c 			
			inner join MAS_Customers d on c.CustId = d.CustId 
			inner join WAL_Profile a on a.BaseCif = c.Cif_No 
		WHERE (c.Phone like '%' + @filter + '%' or c.Email like '%' + @filter + '%' or d.FullName like '%' + @filter + '%')
		ORDER BY CreateDt
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
		set @ErrorMsg					= 'sp_Get_Empoyee_List_ByManager ' + error_message()
		set @ErrorProc					= error_procedure()

		set @AddlInfo					= ' '

		exec utl_Insert_ErrorLog @ErrorNum, @ErrorMsg, @ErrorProc, 'Employees', 'GET', @SessionID, @AddlInfo
	end catch