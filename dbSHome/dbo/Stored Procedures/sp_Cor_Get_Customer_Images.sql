






CREATE procedure [dbo].[sp_Cor_Get_Customer_Images]
	@userId	nvarchar(450),
	@Offset				int				= 0,
	@PageSize			int				= 10,
	--@CustId	nvarchar(50),  
	@Total				int out,
	@TotalFiltered		int out

as
	begin try
		set		@Offset					= isnull(@Offset, 0)
		set		@PageSize				= isnull(@PageSize, 10)
		set		@Total					= isnull(@Total, 0) 
		--set		@CustId					= isnull(@CustId,'')

		if		@PageSize	= 0			set @PageSize	= 10
		if		@Offset		< 0			set @Offset		=  0

		select 
			@Total					= count(a.ImageId)
			 from MAS_Customer_Image a
				join [dbSHRM].[dbo].[Employees] e on e.CustId = a.CustId
			where e.UserId = @userId

		set	@TotalFiltered = @Total 
		if @PageSize < 0
		begin
			set	@PageSize				= 10
		end

	--1
		SELECT [ImageId]
			  ,[FaceId]
			  ,a.[CustId]
			  ,a.[ImageUrl]
			  ,[ImageType]
			  ,[IsFace]
			  ,[sysDate]
		  FROM [MAS_Customer_Image] a
				join [dbSHRM].[dbo].[Employees] e on e.CustId = a.CustId
			where e.UserId = @userId
		  ORDER BY ImageId desc
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
		set @ErrorMsg					= 'sp_Cor_Get_Customer_Images ' + error_message()
		set @ErrorProc					= error_procedure()

		set @AddlInfo					= '@custId ' + @userId

		exec utl_Insert_ErrorLog @ErrorNum, @ErrorMsg, @ErrorProc, 'Customer', 'GET', @SessionID, @AddlInfo
	end catch