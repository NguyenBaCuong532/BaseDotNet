
CREATE procedure [dbo].[sp_res_elevator_card_field]
	@UserId			UNIQUEIDENTIFIER = NULL,
	@id			uniqueidentifier = null,
	@cardId		int = N'92369',
	@acceptLanguage NVARCHAR(50) = N'vi-VN'
as
	begin try
		--Set @id = NULLIF(@id, '')
		DECLARE @group_key VARCHAR(50) = 'common_group'
		DECLARE @table_key VARCHAR(50) = 'MAS_Elevator_Card'

		SELECT id = @id
			  ,tableKey = @table_key
              ,groupKey = @group_key;

		SELECT *
		FROM [dbo].[fn_get_field_group_lang](@group_key, @acceptLanguage)
		ORDER BY intOrder;

		drop table if exists #tempIn
	
 		select top 1 b.*
 		into #tempIn
 		from MAS_Elevator_Card b
 		WHERE (b.Oid = @id) or (b.CardId = @cardId)
	
 		if not exists(select 1 from #tempIn)
 		insert into #tempIn (CardId,CardType,CardRole,ProjectCd,AreaCd,created_at)
 		select c.CardId,c.CardType,c.CardRole,c.ProjectCd,c.AreaCd,getdate()
 		from MAS_Elevator_Card c
 		where  CardId = @cardId 
		
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
					when 'buildingCd' then isnull(b.BuildCd,b.AreaCd)
					when 'AreaCd' then b.AreaCd
					when 'Note' then b.Note
					--when 'BuildZone' then bz.BuildZone
					end
					) 
				when 'datetime' then convert(nvarchar(50), case field_name 
					when 'created_at' then format(b.created_at,'dd/MM/yyyy HH:mm:ss')
					end)
				else convert(nvarchar(50),case field_name 
					when 'FloorNumber' then b.FloorNumber
					when 'cardId' then --b.cardId
										ISNULL(@cardId, (SELECT TOP 1 b.CardId FROM MAS_Elevator_Card b WHERE b.Oid = @id or (b.CardId = @cardId)))
					when 'CardRole' then b.CardRole
					when 'CardType' then --isnull(b.CardType,c.cardTypeId)
					ISNULL(c.cardTypeId, (SELECT TOP 1 b.CardType FROM MAS_Elevator_Card b WHERE b.Oid = @id or (b.CardId = @cardId)))
					end) 
				end as columnValue
				,columnClass
				,columnType
				,columnObject = case when a.field_name = 'buildingCd' then columnObject + b.ProjectCd 
									 when a.field_name = 'AreaCd' then isnull(columnObject,'/api/v2/common/GetAreaList?buildingCd=') + isnull(b.BuildCd,b.AreaCd) 
									--when a.field_name = 'FloorNumber' then isnull(columnObject,'') + '?'+ isnull(b.ProjectCd,'')
									 when a.field_name = 'FloorNumber' then isnull(columnObject,'/api/v2/common//api/v2/common/GetElevatorFloorList?buildingCd=') 
																						+ '?ProjectCd=' + b.ProjectCd + '&areaCd='+ b.AreaCd
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
			FROM
				dbo.fn_config_form_gets(@table_key, @acceptLanguage) a
			OUTER APPLY(SELECT TOP 1 * FROM MAS_Elevator_Card b WHERE b.Oid = @id ) b
 				--,#tempIn b
			OUTER APPLY (SELECT Top(1) cardTypeId From MAS_Cards WHERE CardId = @cardId) c
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

		exec utl_Insert_ErrorLog @ErrorNum, @ErrorMsg, @ErrorProc, 'elevator', 'GET', @SessionID, @AddlInfo
	end catch