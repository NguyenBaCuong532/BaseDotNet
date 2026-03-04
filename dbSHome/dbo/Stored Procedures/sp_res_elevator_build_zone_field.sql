-- Oid = mã chính; id/areaCd = phụ (tương thích ngược, bỏ sau migrate).
CREATE procedure [dbo].[sp_res_elevator_build_zone_field]
	  @UserId			UNIQUEIDENTIFIER = NULL
	 ,@areaCd		nvarchar(50) = null
	 ,@id			nvarchar(50) = null
	 ,@projectCd    nvarchar(50) = null
	 ,@zoneOid		uniqueidentifier = null
	 ,@acceptLanguage NVARCHAR(50) = N'vi-VN'
as
	begin try
		-- Ưu tiên oid (mã chính); khi có id thì resolve zoneOid từ bảng
		IF @id IS NOT NULL AND @zoneOid IS NULL
			SET @zoneOid = (SELECT oid FROM ELE_BuildZone WHERE CAST(Id AS NVARCHAR(50)) = @id);

		DECLARE @group_key VARCHAR(50) = 'common_group'
		DECLARE @table_key VARCHAR(50) = 'ELE_BuildZone'

		SELECT id = (SELECT TOP 1 Id FROM ELE_BuildZone WHERE (@zoneOid IS NOT NULL AND oid = @zoneOid) OR (@zoneOid IS NULL AND CAST(Id AS NVARCHAR(50)) = @id))
			  ,tableKey = @table_key
              ,groupKey = @group_key;

		SELECT *
		FROM [dbo].[fn_get_field_group_lang](@group_key, @acceptLanguage)
		ORDER BY intOrder;

		drop table if exists #tempIn
	
		select b.*
		into #tempIn
		from ELE_BuildZone b
		WHERE (@zoneOid IS NOT NULL AND b.oid = @zoneOid) OR (@zoneOid IS NULL AND b.id = @id)
	
		if not exists(select 1 from #tempIn)
		insert into #tempIn ([BuildZone],[AreaCd],[ProjectCd])
		select '',e.AreaCd,e.ProjectCd
		from ELE_BuildArea e
		where AreaCd = @areaCd
		and ProjectCd = @projectCd
		
		SELECT  a.id
				,table_name
				,field_name
				,view_type
				,data_type
				,ordinal
				,columnLabel
				,group_cd
				,case data_type when 'nvarchar' then convert(nvarchar(350), case field_name 
					when 'BuildZone' then b.BuildZone
					when 'AreaCd' then b.AreaCd
					when 'ProjectCd' then b.ProjectCd
					end
					) 
				end as columnValue
				,columnClass
				,columnType
				,columnObject = case when a.field_name = 'AreaCd' then columnObject + b.projectCd else columnObject end
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
		set @ErrorMsg					= 'sp_res_elevator_build_zone_field' + error_message()
		set @ErrorProc					= error_procedure()

		set @AddlInfo					= ' '

		exec utl_Insert_ErrorLog @ErrorNum, @ErrorMsg, @ErrorProc, 'elevator_build_zone', 'GET', @SessionID, @AddlInfo
	end catch