/****** Script for SelectTopNRows command from SSMS  ******/
CREATE procedure [dbo].[sp_res_elevator_card_page_bycd]
	@UserId			UNIQUEIDENTIFIER = NULL,
	@filter			nvarchar(50) = NULL,
	@CardCd			nvarchar(50) = NULL,
	@ProjectCd      nvarchar(50) = null,
	@BuildCd        nvarchar(50) = null,
	@Offset			int				= 0,
	@PageSize		int				= 10,
	@acceptLanguage NVARCHAR(50) = N'vi-VN'
as
	begin try

	declare @CardId nvarchar(50)
		set	@Offset					= isnull(@Offset, 0)
		set		@PageSize				= isnull(@PageSize, 10)

		if		@PageSize	= 0			set @PageSize	= 10
		if		@Offset		< 0			set @Offset		=  0
		
		set @CardId = (select b.CardId from MAS_CardBase a join MAS_Cards b on a.Code = b.CardCd where Code = @CardCd)
		
		SELECT  EC.Id
			  , (select top 1  b.CardCd from MAS_CardBase a join MAS_Cards b on a.Code = b.CardCd where b.CardId = EC.CardId) AS CardNumber
			  , EC.CardId
			  , EC.CardRole
			  , EC.CardType
			  , CR.RoleName
			  , (select top 1  CardTypeName from MAS_CardTypes where CardTypeId = EC.CardType) as CardTypeName
			  , EC.ProjectCd
			  , (select top 1  ProjectName from mas_Projects where ProjectCd = EC.ProjectCd) as ProjectName
			  ,EC.AreaCd BuildCd
			  , isnull(EC.AreaCd, EC.BuildCd) as BuildName
			  ,EC.FloorNumber
			  , isnull(f.FloorName, EC.FloorNumber ) as FloorName
			  , (select top 1  e.FullName from dbo.MAS_Cards AS a 
			   left join MAS_Customers e on a.CustId = e.CustId
			   left join MAS_CardBase d on a.CardCd = d.Code where a.CardId = EC.CardId) AS FullName
			  , EC.created_at,
			  ec.Oid
		FROM dbo.MAS_Elevator_Card AS EC 
			left join ELE_CardRole AS CR ON EC.CardRole = CR.Id
			left join ELE_Floor f on EC.ProjectCd = f.ProjectCd and EC.BuildCd = f.BuildCd and EC.FloorNumber=f.FloorNumber
			WHERE EC.CardId = @CardId
				 and (@ProjectCd is null or EC.ProjectCd = @ProjectCd)
				 and (@BuildCd is null or EC.BuildCd = @BuildCd)
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

		set @AddlInfo					= ' UserId' + ISNULL(CAST(@UserId AS NVARCHAR(50)), '')

		exec utl_Insert_ErrorLog @ErrorNum, @ErrorMsg, @ErrorProc, 'Card_Info', 'GET', @SessionID, @AddlInfo
	end catch