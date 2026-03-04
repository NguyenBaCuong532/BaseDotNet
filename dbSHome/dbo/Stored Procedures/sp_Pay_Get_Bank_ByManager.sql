





CREATE procedure [dbo].[sp_Pay_Get_Bank_ByManager]
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
			 
		select	@Total					= count(a.SourceCd)
			FROM WAL_Banks a
			WHERE (a.ShortName like '%' + @filter + '%' or a.SourceName like '%' + @filter + '%')

		set @TotalFiltered = @Total	

		SELECT SourceCd
			  ,[ShortName]
			  ,SourceName
			  ,[LogoUrl]
			  ,case when isIntCard = 1 then 0 else 1 end as IsInternal
		FROM WAL_Banks a
		  WHERE (a.ShortName like '%' + @filter + '%' or a.SourceName like '%' + @filter + '%')
		  --WHERE IsBank = 1

	end try
	begin catch
		declare	@ErrorNum				int,
				@ErrorMsg				varchar(200),
				@ErrorProc				varchar(50),

				@SessionID				int,
				@AddlInfo				varchar(max)

		set @ErrorNum					= error_number()
		set @ErrorMsg					= 'sp_Get_Bank_List ' + error_message()
		set @ErrorProc					= error_procedure()

		set @AddlInfo					= ' '

		exec utl_Insert_ErrorLog @ErrorNum, @ErrorMsg, @ErrorProc, 'Bank', 'GET', @SessionID, @AddlInfo
	end catch