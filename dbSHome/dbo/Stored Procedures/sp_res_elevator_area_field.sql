-- Oid = mã chính; id/buildingCd = phụ (tương thích ngược, bỏ sau migrate).
CREATE procedure [dbo].[sp_res_elevator_area_field]
	 @UserId			UNIQUEIDENTIFIER = NULL
	,@buildingCd		nvarchar(50) = null
	,@id			nvarchar(50) = null
	,@projectCd     nvarchar(50) = null
	,@areaOid		uniqueidentifier = null
	,@acceptLanguage NVARCHAR(50) = N'vi-VN'
as
	begin try
		-- Ưu tiên oid (mã chính); khi có id thì resolve areaOid từ bảng
		IF @id IS NOT NULL AND @areaOid IS NULL
			SET @areaOid = (SELECT oid FROM ELE_BuildArea WHERE CAST(Id AS NVARCHAR(50)) = @id);

		DECLARE @group_key VARCHAR(50) = 'common_group'
		DECLARE @table_key VARCHAR(50) = 'ELE_BuildArea'
		drop table if exists #tempIn
	
		select b.*
		into #tempIn
		from ELE_BuildArea b
		WHERE (b.oid = @areaOid) 
	
		if not exists(select 1 from #tempIn)
		insert into #tempIn ([AreaCd],[AreaName],[ProjectCd],[buildingId])
		select '','',@ProjectCd,@buildingCd

		SELECT id = ISNULL((SELECT TOP 1 CAST(Id AS NVARCHAR(50)) FROM #tempIn), @id)
			  ,areaCd
			  ,buildingCd = @buildingCd
			  ,projectCd = @projectCd
			  ,tableKey = @table_key
              ,groupKey = @group_key
		from #tempIn;

		SELECT *
		FROM [dbo].[fn_get_field_group_lang](@group_key, @acceptLanguage)
		ORDER BY intOrder;

		

		
		SELECT  a.id
				,table_name
				,field_name
				,view_type
				,data_type
				,ordinal
				,columnLabel
				,group_cd
				,case data_type when 'nvarchar' then convert(nvarchar(350), case field_name 
					when 'BuildingCd' then @buildingCd
					when 'AreaCd' then b.AreaCd
					when 'ProjectCd' then @projectCd
					when 'AreaName' then b.AreaName
					end
					) 
				end as columnValue
				,columnClass
				,columnType
				,columnObject = case when a.field_name = 'BuildingCd' then columnObject + @projectCd 
									else columnObject end
				,isSpecial
				,isRequire
				,isDisable
				,isVisiable
				,isnull(a.columnTooltip,[columnLabel]) as columnTooltip
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
		set @ErrorMsg					= 'sp_res_elevator_area_field ' + error_message()
		set @ErrorProc					= error_procedure()

		set @AddlInfo					= ' '

		exec utl_Insert_ErrorLog @ErrorNum, @ErrorMsg, @ErrorProc, 'elevator', 'GET', @SessionID, @AddlInfo
	end catch