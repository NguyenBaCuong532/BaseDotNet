








CREATE procedure [dbo].[sp_Pay_Get_Wallet_Service_ByManager]
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
		
			 
		select	@Total					= count(a.WalServiceCd)
			FROM WAL_Services AS a 
             left JOIN WAL_Providers AS b ON a.ProviderCd = b.ProviderCd
			 --WHERE (b.ShortName like '%' + @filter + '%' or b.SourceName like '%' + @filter + '%' or c.TranferName like '%' + @filter + '%')

		set @TotalFiltered = @Total

		--2
		SELECT   a.WalServiceCd as ServiceCd
				,a.CreateDt as CreateDate
				,b.ProviderShort
				,b.ProviderName
				,a.ServiceName
				,a.ServiceViewUrl
				,a.IconKey
				,a.IsFlage
				,a.intOrder
				,a.ProviderCd
				,a.ServiceKey
		FROM   WAL_Services AS a 
             left JOIN WAL_Providers AS b ON a.ProviderCd = b.ProviderCd
			 --INNER JOIN [WAL_Tranfers] AS c ON a.[TranferCd] = c.[TranferCd]
			 --WHERE (b.ShortName like '%' + @filter + '%' or b.SourceName like '%' + @filter + '%' or c.TranferName like '%' + @filter + '%')
		ORDER BY a.intOrder, a.CreateDt DESC
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
		set @ErrorMsg					= 'sp_Pay_Get_Wallet_Service_ByManager ' + error_message()
		set @ErrorProc					= error_procedure()

		set @AddlInfo					= ' '

		exec utl_Insert_ErrorLog @ErrorNum, @ErrorMsg, @ErrorProc, 'WalletService', 'GET', @SessionID, @AddlInfo
	end catch