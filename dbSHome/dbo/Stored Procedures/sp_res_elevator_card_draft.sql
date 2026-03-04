CREATE procedure [dbo].[sp_res_elevator_card_draft]
	 @UserId		UNIQUEIDENTIFIER = NULL
	,@id			uniqueidentifier = null
	,@CardId		int
	,@CardRole		int
	,@CardType		int
	,@ProjectCd		nvarchar(30) = null
	,@BuildingCd	nvarchar(50) = null
	,@areaCd		nvarchar(50) = null
	,@FloorNumber	int = null
	,@Note			nvarchar(50) = null
	,@acceptLanguage NVARCHAR(50) = N'vi-VN'
as
	begin try
		
		DECLARE @group_key VARCHAR(50) = 'common_group'
		DECLARE @table_key VARCHAR(50) = 'MAS_Elevator_Card'

		SELECT id = @id
			  ,tableKey = @table_key
              ,groupKey = @group_key;

		SELECT *
		FROM [dbo].[fn_get_field_group_lang](@group_key, @acceptLanguage)
		ORDER BY intOrder;

		drop table if exists #tempIn
	
		select b.*
		into #tempIn
		from MAS_Elevator_Card b
		WHERE 0 = 1
	
		if not exists(select 1 from #tempIn)
 		insert into #tempIn (Oid, CardId,CardType,CardRole,buildingCd,ProjectCd,AreaCd,FloorNumber,created_at)
 		select NEWID(), ISNULL(@CardId, ''),@CardType,@CardRole,@BuildingCd,@ProjectCd,@areaCd,@FloorNumber,getdate()
 		

		
		SELECT  a.id
				,table_name
				,field_name
				,view_type
				,data_type
				,ordinal
				,columnLabel
				,group_cd
				,case data_type when 'nvarchar' then convert(nvarchar(350), case field_name 
					when 'ProjectCd' then b.projectCd
					when 'buildingCd' then b.buildingCd
					when 'AreaCd' then b.AreaCd
					when 'Note' then b.Note
					end
					) 
				when 'datetime' then convert(nvarchar(50), case field_name 
					when 'created_at' then format(b.created_at,'dd/MM/yyyy HH:mm:ss')
					end)
				else convert(nvarchar(50),case field_name 
					when 'FloorNumber' then b.FloorNumber
					when 'cardId' then b.cardId
					when 'CardRole' then b.CardRole
					when 'CardType' then b.CardType 
										--(SELECT TOP 1 b.CardType FROM MAS_Elevator_Card b WHERE b.Oid = @id or (b.CardId = @cardId))
					end) 
				end as columnValue
				,columnClass
				,columnType
				,columnObject	= case when a.field_name = 'buildingCd' then columnObject + b.ProjectCd 
									when a.field_name = 'AreaCd' then columnObject + b.buildingCd + '&ProjectCd=' + b.ProjectCd
									when a.field_name = 'FloorNumber' then isnull(columnObject,'') + '?areaCd=' + isnull(b.AreaCd,'') + '&ProjectCd=' + b.ProjectCd
								else columnObject end
				,isSpecial
				,isRequire	
				,isDisable		/*= case when b.CardRole = 2 and a.field_name in ('buildingCd','AreaCd','FloorNumber') then 1 
									when b.CardRole = 3 and a.field_name in ('AreaCd','FloorNumber') then 1
									when b.CardRole = 1 and a.field_name in ('FloorNumber') then 1
								else isDisable end*/
				,isVisiable
				,isnull(a.columnTooltip,[columnLabel]) as columnTooltip
				,isIgnore
			FROM dbo.fn_config_form_gets(@table_key, @acceptLanguage) a
				CROSS JOIN #tempIn b
			WHERE a.table_name = @table_key
				AND (a.isVisiable = 1 or a.isRequire = 1)
			order by ordinal
		
	end try
	begin catch
		declare	@ErrorNum				int,
				@ErrorMsg				varchar(200),
				@ErrorProc				varchar(50),

				@SessionID				int,
				@AddlInfo				varchar(max)

		set @ErrorNum					= error_number()
		set @ErrorMsg					= 'sp_res_elevator_card_field ' + error_message()
		set @ErrorProc					= error_procedure()

		set @AddlInfo					= ' '

		exec utl_Insert_ErrorLog @ErrorNum, @ErrorMsg, @ErrorProc, 'elevator', 'SET', @SessionID, @AddlInfo
	end catch