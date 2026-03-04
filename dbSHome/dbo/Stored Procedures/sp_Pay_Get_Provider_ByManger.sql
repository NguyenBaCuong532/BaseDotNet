




CREATE procedure [dbo].[sp_Pay_Get_Provider_ByManger]
	@userId	nvarchar(400),
	@filter nvarchar(150),
	--@isUser int,
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
		
			 
		select	@Total					= count(c.ProviderCd)
			FROM WAL_Providers c
			WHERE (c.Phone like '%' + @filter + '%' or c.Email like '%' + @filter + '%' or ProviderName like '%' + @filter + '%')

		set @TotalFiltered = @Total

		SELECT [ProviderCd]
		  ,[ProviderShort]
		  ,[ProviderName]
		  ,[Address]
		  ,[LogoUrl]
		  ,[ContactName]
		  ,[Phone]
		  ,[Email]
		  ,ProviderId
	  FROM [dbo].WAL_Providers c
	  WHERE (c.Phone like '%' + @filter + '%' or c.Email like '%' + @filter + '%' or ProviderName like '%' + @filter + '%')
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
		set @ErrorMsg					= 'sp_Pay_Get_Provider_ByManger ' + error_message()
		set @ErrorProc					= error_procedure()

		set @AddlInfo					= ' '

		exec utl_Insert_ErrorLog @ErrorNum, @ErrorMsg, @ErrorProc, 'Provider', 'GET', @SessionID, @AddlInfo
	end catch