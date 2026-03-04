
-- =============================================
-- Author:		duongpx
-- Create date: 7/26/2024 9:43:49 AM
-- Description:	tạo nháp filter dùng chung
-- =============================================
CREATE   PROCEDURE [dbo].[sp_common_filter_draft]
     @userId             UNIQUEIDENTIFIER = null
    ,@acceptLanguage     nvarchar(50) = 'vi-VN'
    ,@gd                 uniqueidentifier = null
    ,@tableKey           nvarchar(256) = '24'
    ,@fromDate           nvarchar(50) = null
    ,@toDate             nvarchar(50) = null
    ,@projectCd          nvarchar(50) = null
    ,@buildingCd         nvarchar(50) = null
    ,@areaCd             nvarchar(50) = null
	,@app_st			int null
	,@buildCd			nvarchar(100) null
	--,@buildingCd nvarchar(100) null
	,@CardTypeId int null
	,@dateFilter nvarchar(100) null
	,@Debt nvarchar(100) null
	,@endDate nvarchar(100) null
	,@filter nvarchar(100) null
	--,@fromDate nvarchar(100) null
	,@fromDt nvarchar(100) null
	,@IsBill bit null
	,@IsDateFilter bit null
	,@isExpected bit null
	,@isFilterDate bit null
	,@IsNow bit null
	,@isPublish bit null
	,@IsPush bit null
	,@isRegisterVehicle bit null
	,@isResident bit null
	,@month int null
	,@par_service_price_type_oid nvarchar(100) null
	,@par_vehicle_daily_type_oid nvarchar(100) null
	,@par_vehicle_type_oid nvarchar(100) null
	,@partner_id int null
	,@posCd nvarchar(100) null
	--,@projectCd nvarchar(100) null
	,@question_type int null
	,@Receive int null
	,@Rent int null
	,@service_Id nvarchar(100) null
	,@serviceKey nvarchar(100) null
	,@setupStatus nvarchar(100) null
	,@source_key nvarchar(100) null
	,@source_ref nvarchar(100) null
	,@Status int null
	,@Statuses nvarchar(100) null
	,@StatusPayed nvarchar(100) null
	,@templateTypeId nvarchar(100) null
	--,@ToDate nvarchar(100) null
	,@toDt nvarchar(100) null
	,@tranType int null
	,@VehicleTypeId int null
	,@year int null

as
begin try
	
    select null gd,
        @tableKey as tableKey,
        groupKey = 'common_group'
     --2- cac group
     select * from dbo.fn_get_field_group_lang('common_group', @acceptLanguage)

      select a.[id]
            ,[table_name]
            ,[field_name]
            ,[view_type]
            ,[data_type]
            ,[ordinal]
            ,[columnLabel]
            ,[group_cd]
            ,[data_type]
            ,case [data_type]
					when 'nvarchar'
						then CONVERT(nvarchar(max), case [field_name]
						when 'projectCd' then @projectCd
						when 'buildCd' then @buildCd
						when 'buildingCd' then @buildingCd
						when 'areaCd' then @areaCd
						when 'serviceKey' then @serviceKey
						when 'filter' then @Filter
						when 'setupStatus' then @setupStatus
						when 'source_key' then @source_key
						WHEN 'service_Id' THEN @service_Id
						WHEN 'tableKey' THEN @tableKey
						WHEN 'templateTypeId' THEN @templateTypeId
						--WHEN 'Debt' THEN @Debt
						WHEN 'Statuses' THEN @Statuses
						WHEN 'posCd' THEN @posCd
						end)
					when 'bit'
						then CONVERT(nvarchar(50), case [field_name]
						when 'IsBill' then case when @IsBill = 1 then 'true' else 'false' end
						when 'IsDateFilter' then case when @IsDateFilter = 1 then 'true' else 'false' end
 						when 'isExpected' then case when @isExpected = 1 then 'true' else 'false' end
						when 'isFilterDate' then case when @isFilterDate = 1 then 'true' else 'false' end
						when 'IsNow' then case when @IsNow = 1 then 'true' else 'false' end
						when 'isPublish' then case when @isPublish = 1 then 'true' else 'false' end
						when 'IsPush' then case when @IsPush = 1 then 'true' else 'false' end
						when 'isRegisterVehicle' then case when @isRegisterVehicle = 1 then 'true' else 'false' end
						when 'isResident' then case when @isResident = 1 then 'true' else 'false' end
						--when 'IsNow' then case when @IsNow = 1 then 'true' else 'false' end
						end)
					when 'datetime'
						then CONVERT(nvarchar(50), case [field_name]
						when 'toDate' then @toDate
						when 'fromDate' then @fromDate
						when 'toDt' then @toDt
						when 'fromDt' then @fromDt
						when 'endDate' then @endDate
						when 'dateFilter' then @dateFilter
						end)
					when 'int'
						then CONVERT(nvarchar(50), case [field_name]
						when 'Month' then (CAST(@Month as varchar(50)))
						when 'Year' then (CAST(@Year as varchar(50)))
						when 'CardTypeId' then (CAST(@CardTypeId as varchar(50)))
						when 'VehicleTypeId' then (CAST(@VehicleTypeId as varchar(50)))
						WHEN 'Receive' THEN CAST(@Receive AS NVARCHAR(50)) 
						WHEN 'Rent' THEN CAST(@Rent AS NVARCHAR(50)) 
						WHEN 'partner_id' THEN CAST(@partner_id AS NVARCHAR(50)) 
						WHEN 'tranType' THEN CAST(@tranType AS NVARCHAR(50)) 
						WHEN 'Status' THEN CAST(@Status AS NVARCHAR(50)) 
						WHEN 'StatusPayed' THEN CAST(@StatusPayed AS NVARCHAR(50))
						WHEN 'app_st' THEN CAST(@app_st AS NVARCHAR(50))
						WHEN 'question_type' THEN CAST(@question_type AS NVARCHAR(50))
						end)
					when 'uniqueidentifier'
						then CONVERT(nvarchar(50), case [field_name]
						when 'gd' then (CAST(@gd as varchar(50)))
						WHEN 'par_service_price_type_oid' THEN CAST(@par_service_price_type_oid AS NVARCHAR(50)) 
						WHEN 'par_vehicle_daily_type_oid' THEN CAST(@par_vehicle_daily_type_oid AS NVARCHAR(50)) 
						WHEN 'par_vehicle_type_oid' THEN CAST(@par_vehicle_type_oid AS NVARCHAR(50)) 
						WHEN 'source_ref' THEN CAST(@source_ref AS NVARCHAR(50)) 
						--WHEN 'workTypeId' THEN CAST(@workTypeId AS NVARCHAR(50))
						--WHEN 'flowId' THEN CAST(@flowId AS NVARCHAR(50))
						--WHEN 'FormSurType' THEN CAST(@FormSurType AS NVARCHAR(50))
						--WHEN 'GroupQuestion1' THEN CAST(@FormSurType AS NVARCHAR(50))
						--WHEN 'GroupQuestion2' THEN CAST(@FormSurType AS NVARCHAR(50))
						--WHEN 'GroupQuestion3' THEN CAST(@FormSurType AS NVARCHAR(50))
						--WHEN 'GroupQuestion4' THEN CAST(@FormSurType AS NVARCHAR(50))
						
						end)
					end as columnValue
            ,[columnClass]
            ,[columnType]
            ,[columnObject] = case WHEN [field_name] = 'buildingCd' AND @projectCd IS NOT NULL THEN replace([columnObject],'projectCd=','projectCd='+CONVERT(NVARCHAR(50), @projectCd))
								WHEN [field_name] = 'buildCd' THEN replace([columnObject],'projectCd=','projectCd='+isnull(CONVERT(NVARCHAR(50), @projectCd),''))
								WHEN [field_name] = 'areaCd' THEN replace(replace([columnObject],'projectCd=','projectCd='+isnull(CONVERT(NVARCHAR(50), @projectCd),'')),'buildingCd=','buildingCd='+isnull(CONVERT(NVARCHAR(50), @buildingCd),''))
								--WHEN [field_name] = 'EmployeeExtraItem' THEN replace(replace([columnObject],'Oid=','Oid='+isnull(CONVERT(NVARCHAR(50), @EmployeeExtraItem),'')),'parentId=','parentId='+isnull(CONVERT(NVARCHAR(50), @Department),''))
								--when [field_name] = 'orgDepId' then [columnObject] + LOWER(CONVERT(nvarchar(50), isnull(@org_level,-1)))
								--when [field_name] = 'orgDepIds' then [columnObject] + LOWER(CONVERT(nvarchar(50), isnull(@org_level,-1)))
								--when [field_name] = 'flowId' then replace([columnObject],'workTypeId=','workTypeId=' + isnull(CONVERT(nvarchar(50), @workTypeId),''))
								--WHEN [field_name] = 'MasterPayroll' then case when @salaryType IS NOT NULL AND @year IS NOT NULL THEN REPLACE(REPLACE([columnObject],'salaryType=', 'salaryType='+(CAST(@salaryType AS VARCHAR(50)))),'year=','year='+ (CAST(@year AS VARCHAR(50)))) END
							else [columnObject] end
			,[isSpecial]
			,isRequire
			,[isDisable] 
            ,[IsVisiable]
            ,[IsEmpty]
            ,isnull(a.columnTooltip, a.[columnLabel]) as columnTooltip
            ,columnDisplay
            ,isIgnore
    from dbo.[fn_config_form_gets](@tableKey, '') a
    where (table_name = @tableKey)
    order by ordinal

end try
begin catch
    declare @ErrorNum int,
        @ErrorMsg varchar(200),
        @ErrorProc varchar(50),

        @SessionID int,
        @AddlInfo varchar(max)

    set @ErrorNum = ERROR_NUMBER()
    set @ErrorMsg = 'sp_bzz_common_filter_draft' + ERROR_MESSAGE()
    set @ErrorProc = ERROR_PROCEDURE()

    set @AddlInfo = ' @user: ' + cast(@userId as varchar(50))

    exec utl_errorLog_set @ErrorNum, @ErrorMsg, @ErrorProc, 'sp_bzz_common_filter_draft', 'SET', @SessionID,
         @AddlInfo
end catch