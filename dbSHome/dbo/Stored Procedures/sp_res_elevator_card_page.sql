/****** Script for SelectTopNRows command from SSMS  ******/
CREATE procedure [dbo].[sp_res_elevator_card_page]
	@UserId			UNIQUEIDENTIFIER = null,
	@CardId			int = null,
	@filter			nvarchar(50) = null,
	@ProjectCd      nvarchar(50) = null,
	@buildingCd         nvarchar(50) = null,
	@FloorNumber        nvarchar(50) = null,
	@BuildZone        nvarchar(50) = null,
	@gridWidth		int				= 0,
	@Offset			int				= 0,
	@PageSize		int				= 10,
	@acceptLanguage		NVARCHAR(50) = N'vi-VN'
as
	begin try
	declare @Total		bigint
	declare @GridKey	nvarchar(100) = 'view_elevator_card_page'
	--declare @CardId nvarchar(50)

		set		@Offset					= isnull(@Offset, 0)
		set		@PageSize				= isnull(@PageSize, 10)
		set		@Total					= isnull(@Total, 0)
		set		@filter					= isnull(@filter,'')

		if		@PageSize	= 0			set @PageSize	= 10
		if		@Offset		< 0			set @Offset		=  0


		select	@Total					= count(EC.Id)
		FROM MAS_Elevator_Card AS EC 
			join MAS_Cards a on a.CardId = ec.CardId 
		WHERE (EC.CardId = @CardId or @CardId is null 
				and (@ProjectCd is null or EC.ProjectCd = @ProjectCd)
				and (@buildingCd = 'all' or EC.BuildCd = @buildingCd)
				and (@filter = '' or a.CardCd like '%' + @filter + '%')
			)
			and exists(select 1 from UserProject p where p.userId = @UserId and p.projectCd = ec.ProjectCd)

		--root	
		select recordsTotal = @Total
			  ,recordsFiltered = @Total
			  ,gridKey = @GridKey
			  ,valid = 1
		--grid config
		IF @Offset = 0
		BEGIN
			SELECT *
			FROM [dbo].fn_config_list_gets_lang(@GridKey, @gridWidth, @acceptLanguage)
			ORDER BY [ordinal];
		END

		SELECT 
			  Distinct EC.Oid
			  , a.CardCd AS cardNumber
			  , EC.CardId as cardId
			  , EC.cardRole
			  , EC.cardType
			  , CR.roleName
			  , ct.cardTypeName
			  , EC.projectCd
			  , p.projectName
			  , ec.BuildCd
			  ,EC.areaCd
			  ,isnull(b.BuildingName,'') as buildName
			  ,EC.floorNumber
			  ,isnull(f.FloorName,0) as floorName
			  ,e.fullName
			  ,ec.id
		FROM dbo.MAS_Elevator_Card AS EC 
			join MAS_Cards a on a.CardId = ec.CardId 
			left join ELE_CardRole AS CR ON EC.CardRole = CR.Id
			left join ELE_Floor f on EC.ProjectCd = f.ProjectCd and EC.AreaCd = f.BuildCd and EC.FloorNumber = f.FloorNumber			
			left join MAS_Customers e on a.CustId = e.CustId 
			left join MAS_CardTypes ct on ct.CardTypeId = ec.CardType
			left join mas_Projects p on p.projectCd = ec.ProjectCd
			left join MAS_Buildings b on ec.BuildCd = b.BuildingCd
			WHERE (EC.CardId = @CardId or @CardId is null
					and (@ProjectCd is null or EC.ProjectCd = @ProjectCd)
					and (@buildingCd = 'all' or EC.BuildCd = @buildingCd)	
					and (@filter = '' or a.CardCd like '%' + @filter + '%')
				 )
				 and exists(select 1 from UserProject p where p.userId = @UserId and p.projectCd = ec.ProjectCd)
			order by EC.ProjectCd desc, EC.FloorNumber
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
		set @ErrorMsg					= 'sp_Hom_Get_Card_Info_ByCode ' + error_message()
		set @ErrorProc					= error_procedure()

		set @AddlInfo					= ' UserId' + cast(@UserId as varchar(50))

		exec utl_Insert_ErrorLog @ErrorNum, @ErrorMsg, @ErrorProc, 'Card_Info', 'GET', @SessionID, @AddlInfo
	end catch