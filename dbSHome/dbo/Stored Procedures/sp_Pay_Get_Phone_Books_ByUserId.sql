







CREATE procedure [dbo].[sp_Pay_Get_Phone_Books_ByUserId]
	@userId nvarchar(450),
	@filter nvarchar(150),
	--@isUser int,
	@Offset				int				= 0,
	@PageSize			int				= 10,
	@Total				int out,
	@TotalFiltered		int out
as
	begin try		
	--1
		set		@Offset					= isnull(@Offset, 0)
		set		@PageSize				= isnull(@PageSize, 10)
		set		@Total					= isnull(@Total, 0)
		set		@filter					= isnull(@filter,'')

		if		@PageSize	= 0			set @PageSize	= 10
		if		@Offset		< 0			set @Offset		=  0
		
			 
		select	@Total					= count(a.[Id])
			FROM [WAL_PhoneBooks] a
		  WHERE a.UserId = @userId 
			and (a.Phone like '%' + @filter + '%' or a.Email like '%' + @filter + '%' or a.FullName like '%' + @filter + '%')

		set @TotalFiltered = @Total
		if @PageSize = -1 set @PageSize = @Total

		SELECT [Id]
			  ,[UserId]
			  ,[FullName]
			  ,[AvatarUrl]
			  ,[ContactName]
			  ,[Phone]
			  ,[Email]
			  ,[isWallet]
			  ,walletCd
			  ,[CreateDt]
		  FROM [WAL_PhoneBooks] a
		  WHERE a.UserId = @userId 
			and (a.Phone like '%' + @filter + '%' or a.Email like '%' + @filter + '%' or a.FullName like '%' + @filter + '%')
			and a.isWallet = 1
	  ORDER BY [FullName]
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
		set @ErrorMsg					= 'sp_Pay_Get_Phone_Books_ByUserId ' + error_message()
		set @ErrorProc					= error_procedure()

		set @AddlInfo					= ' '

		exec utl_Insert_ErrorLog @ErrorNum, @ErrorMsg, @ErrorProc, 'PhoneBooks', 'GET', @SessionID, @AddlInfo
	end catch