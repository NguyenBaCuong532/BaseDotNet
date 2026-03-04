








CREATE procedure [dbo].[sp_Hom_Card_Daily_ByExport]
	@userId nvarchar(300),
	@ProjectCd	nvarchar(40),
	@filter nvarchar(60),
	@Statuses int = null
as
	begin try
		--declare @tbIsUse TABLE 
		--(
		--	Id [Int] null
		--)
		--if	@Statuses is null or @Statuses = -1 
		--	insert into @tbIsUse (Id) select 0 union select 1 union select 2 union select 3 
		--else
		--begin
		--	if @Statuses = 2 
		--		set @Statuses = 3
		--	insert into @tbIsUse (Id) select @Statuses
		--end

		set		@filter					= isnull(@filter,'')
		set		@ProjectCd				= isnull(@ProjectCd,'')
		set		@Statuses				= isnull(@Statuses,-1)
	--1
		SELECT ROW_NUMBER() OVER(ORDER BY [CardCd] ASC) as STT 
			,[CardCd] MaThe
			,convert(nvarchar(10),a.[IssueDate],103) NgayCap
			,s.StatusName TrangThai
	  FROM [MAS_Cards] a 
			inner join MAS_VehicleTypes b on a.VehicleTypeId = b.VehicleTypeId 
			inner join MAS_CardStatus s on a.Card_St = s.StatusId
		WHERE a.ProjectCd = @ProjectCd 
				And a.CardTypeId = 3 
				and a.IsDaily = 1
				and CardCd like  @filter + '%'
				and (@Statuses = -1 or Card_St = @Statuses)-- in (select Id from @tbIsUse)
				--and exists (SELECT * FROM [dbo].[fn_Exists_CustCategory] (@UserId,a.CustId) where CategoryCd = a.ProjectCd)
		ORDER BY [CardCd] 
	

	--2
	
	end try
	begin catch
		declare	@ErrorNum				int,
				@ErrorMsg				varchar(200),
				@ErrorProc				varchar(50),

				@SessionID				int,
				@AddlInfo				varchar(max)

		set @ErrorNum					= error_number()
		set @ErrorMsg					= 'sp_Get_CardDaly_Export_ByManager ' + error_message()
		set @ErrorProc					= error_procedure()

		set @AddlInfo					= ' '

		exec utl_Insert_ErrorLog @ErrorNum, @ErrorMsg, @ErrorProc, 'CardExport', 'GET', @SessionID, @AddlInfo
	end catch