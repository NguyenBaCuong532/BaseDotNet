-- Oid = mã chính; id = phụ (tương thích ngược, bỏ sau migrate).
CREATE procedure [dbo].[sp_res_elevator_device_field]
	@UserId			UNIQUEIDENTIFIER = NULL,
	@id			int = NULL,
	@deviceOid		uniqueidentifier = NULL,
	@acceptLanguage NVARCHAR(50) = N'vi-VN'
as
	begin try
		-- Ưu tiên oid (mã chính); khi có id thì resolve deviceOid từ bảng
		IF @id IS NOT NULL AND @deviceOid IS NULL
			SET @deviceOid = (SELECT oid FROM MAS_Elevator_Device WHERE Id = @id);
		IF @deviceOid IS NOT NULL
			SET @id = (SELECT Id FROM MAS_Elevator_Device WHERE oid = @deviceOid);
		
		DECLARE @group_key VARCHAR(50) = 'common_group'
		DECLARE @table_key VARCHAR(50) = 'MAS_Elevator_Device'

		SELECT id = @id
			  ,tableKey = @table_key
              ,groupKey = @group_key;

		SELECT *
		FROM [dbo].[fn_get_field_group_lang](@group_key, @acceptLanguage)
		ORDER BY intOrder;

		drop table if exists #tempIn
	
		select b.*
		into #tempIn
		from MAS_Elevator_Device b
		WHERE (@deviceOid IS NOT NULL AND b.oid = @deviceOid) OR (@deviceOid IS NULL AND b.id = @id)
	
		--if not exists(select 1 from #tempIn)
		--insert into #tempIn (HardwareId,FloorNumber,FloorName,ProjectCd,buildingCd,AreaCd,IsActived,created_at)
		--select '',1,1,'','','','',getdate()

		if not exists(select 1 from #tempIn)
			begin
				SET IDENTITY_INSERT #tempIn ON
				insert into #tempIn (Id,HardwareId,FloorNumber,FloorName,ProjectCd,buildingCd,AreaCd,IsActived,created_at, oid)
				select  ISNULL((SELECT MAX(Id) FROM MAS_Elevator_Device), 0) + 1,'','','','','','','',getdate(), newid()
				SET IDENTITY_INSERT #tempIn OFF				
			end


		
		SELECT  a.id
				,table_name
				,field_name
				,view_type
				,data_type
				,ordinal
				,columnLabel
				,group_cd
				,case data_type 
				when 'nvarchar' then convert(nvarchar(350), case field_name 
					when 'HardwareId' then b.HardwareId
					when 'ProjectCd' then b.ProjectCd
					when 'AreaCd' then b.AreaCd
					when 'FloorName' then b.FloorName
					when 'ElevatorShaftName' then b.ElevatorShaftName
					when 'BuildZone' then b.BuildZone
					when 'buildingCd' then isnull(b.buildingCd,b.AreaCd)				
					end
					) 
				when 'datetime' then convert(nvarchar(50), case field_name 
					when 'created_at' then format(b.created_at,'dd/MM/yyyy HH:mm:ss')
					end)
				when 'bit' then 
					case field_name 
						when 'IsActived' then --cast(b.IsActived as bit)
										CASE WHEN b.IsActived = '0' THEN 'false' ELSE 'true' END
					end
				else convert(nvarchar(50),case field_name 
					when 'Id' then b.Id
					when 'FloorNumber' then b.FloorNumber
					when 'ElevatorBank' then b.ElevatorBank
					when 'ElevatorShaftNumber' then b.ElevatorShaftNumber
					--when 'IsActived' then b.IsActived
										  --CASE WHEN b.IsActived = '0' THEN 'false' ELSE 'true' END
					end) 
				end as columnValue
				,columnClass
				,columnType
				,columnObject = case when a.field_name = 'AreaCd' then columnObject +  isnull(b.buildingCd,b.AreaCd)
					when a.field_name = 'FloorNumber' then isnull(columnObject,'') + '?areaCd=' + isnull(b.AreaCd,'') + '&ProjectCd=' + b.ProjectCd
					when a.field_name = 'BuildZone' then columnObject + '?projectCd=' + b.ProjectCd + '&AreaCd=' +  isnull(b.buildingCd,b.AreaCd)
					when a.field_name = 'buildingCd' then columnObject + b.ProjectCd
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
		set @ErrorMsg					= 'sp_res_elevator_device_field ' + error_message()
		set @ErrorProc					= error_procedure()

		set @AddlInfo					= ' '

		exec utl_Insert_ErrorLog @ErrorNum, @ErrorMsg, @ErrorProc, 'elevator', 'GET', @SessionID, @AddlInfo
	end catch