







CREATE procedure [dbo].[sp_Pay_Get_Wallet_BankLink_ByManager]
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
		
			 
		select	@Total					= count(a.LinkId)
			FROM WAL_BankLinked AS a 
             INNER JOIN WAL_Banks AS b ON a.SourceCd = b.SourceCd
			 INNER JOIN [WAL_Tranfers] AS c ON a.[TranferCd] = c.[TranferCd]
			 WHERE (b.ShortName like '%' + @filter + '%' or b.SourceName like '%' + @filter + '%' or c.TranferName like '%' + @filter + '%')

		set @TotalFiltered = @Total

		--2
		SELECT   a.LinkId
				,a.LinkDt as LinkDate
				,b.SourceCd
				,b.ShortName
				,b.SourceName
				,b.LogoUrl
				,a.TranferCd
				,c.[TranferName]
				,c.RateFee
				,case when b.isIntCard = 1 then 0 else 1 end as IsInternal
		FROM   WAL_BankLinked AS a 
             INNER JOIN WAL_Banks AS b ON a.SourceCd = b.SourceCd
			 INNER JOIN [WAL_Tranfers] AS c ON a.[TranferCd] = c.[TranferCd]
			 WHERE (b.ShortName like '%' + @filter + '%' or b.SourceName like '%' + @filter + '%' or c.TranferName like '%' + @filter + '%')
		ORDER BY a.[TranferCd],a.SourceCd
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
		set @ErrorMsg					= 'sp_Pay_Get_Wallet_BankLink_ByManager ' + error_message()
		set @ErrorProc					= error_procedure()

		set @AddlInfo					= ' '

		exec utl_Insert_ErrorLog @ErrorNum, @ErrorMsg, @ErrorProc, 'BankLink', 'GET', @SessionID, @AddlInfo
	end catch