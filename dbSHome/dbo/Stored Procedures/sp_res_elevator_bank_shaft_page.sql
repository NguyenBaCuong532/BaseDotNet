


CREATE   procedure [dbo].[sp_res_elevator_bank_shaft_page]
	@UserId	UNIQUEIDENTIFIER, 
	@filter			nvarchar(50) = NULL,
	@Offset				int				= 0,
	@PageSize			int				= 10,
	@ProjectCd		nvarchar(30),
	@BuildingCd		nvarchar(50),
	@BuildZone nvarchar(50),
	@gridWidth				int = 0,
	@acceptLanguage		NVARCHAR(50) = N'vi-VN'
as
	begin try 
	declare @Total		bigint
	declare @GridKey	nvarchar(100) = 'view_elevator_bank_shaft_page'

		set		@Offset					= isnull(@Offset, 0)
		set		@PageSize				= isnull(@PageSize, 10)
		set		@Total					= isnull(@Total, 0)
		set		@filter					= isnull(@filter,'')

		if		@PageSize	<= 0		set @PageSize	= 10
		if		@Offset		< 0			set @Offset		=  0
		
		select	@Total					= count(a.Id)
		from ELE_BankShaft a 
		where (@ProjectCd is null or a.ProjectCd = @ProjectCd)			   
			   and (@BuildZone is null or a.BuildZone = @BuildZone)

		--root	
		select recordsTotal = @Total
			  ,recordsFiltered = @Total
			  ,gridKey = @GridKey
			  ,valid = 1

		--gridflexs
		IF @Offset = 0
		BEGIN
			SELECT *
			FROM [dbo].fn_config_list_gets_lang(@GridKey, 0, @acceptLanguage)
			ORDER BY [ordinal];
		END;
	
		--1
		select a.[ElevatorBank]
           ,a.[ElevatorShaftName]
           ,a.[ElevatorShaftNumber]
		   ,b.ProjectName
           ,a.[ProjectCd]
           ,a.[BuildZone]
		from [dbo].ELE_BankShaft a 
			left join mas_Projects b on a.ProjectCd = b.ProjectCd
		where (@ProjectCd is null or a.ProjectCd = @ProjectCd)
			   and (@BuildZone is null or a.BuildZone = @BuildZone)
		ORDER BY a.ElevatorBank desc
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
		set @ErrorMsg					= 'view_elevator_bank_shaft_page' + error_message()
		set @ErrorProc					= error_procedure()

		set @AddlInfo					= ' '

		exec utl_Insert_ErrorLog @ErrorNum, @ErrorMsg, @ErrorProc, 'elevator_bank_shaft', 'GET', @SessionID, @AddlInfo
	end catch