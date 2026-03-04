

CREATE   procedure [dbo].[sp_res_elevator_bank_shaft_field]
	@UserId			UNIQUEIDENTIFIER = NULL,
	@buildingCd		nvarchar(50)
	,@id			nvarchar(50)
	,@acceptLanguage NVARCHAR(50) = N'vi-VN'
as
	begin try
		
		DECLARE @group_key VARCHAR(50) = 'common_group'
		DECLARE @table_key VARCHAR(50) = 'ELE_BankShaft'

		SELECT @id [id]
			  ,tableKey = @table_key
              ,groupKey = @group_key;

		SELECT *
		FROM [dbo].[fn_get_field_group_lang](@group_key, @acceptLanguage)
		ORDER BY intOrder;

		drop table if exists #tempIn
	
		select b.*
		into #tempIn
		from ELE_BankShaft b
		WHERE (b.id = @id)
	
		if not exists(select 1 from #tempIn)
		insert into #tempIn (
			[ElevatorBank]
           ,[ElevatorShaftName]
           ,[ElevatorShaftNumber]
           ,[ProjectCd]
           ,[BuildZone]
           )
		select '','','',b.ProjectCd,''
		from MAS_Buildings b
		where BuildingCd = @buildingCd
		
		SELECT  a.id
				,table_name
				,field_name
				,view_type
				,data_type
				,ordinal
				,columnLabel
				,'1' as group_cd
				,case data_type when 'nvarchar' then convert(nvarchar(350), case field_name 
					when 'ElevatorBank' then b.ElevatorBank
					when 'ElevatorShaftName' then b.ElevatorShaftName
					when '[ElevatorShaftNumber' then b.ElevatorShaftNumber
					when 'ProjectCd' then b.ProjectCd
					when 'BuildZone' then b.BuildZone
					end
					) 
				when 'datetime' then convert(nvarchar(50), case field_name 
					when 'created_at'  then format(b.created_at,'dd/MM/yyyy HH:mm:ss')
					end)
					 
				else convert(nvarchar(50),case field_name 
					when 'id' then b.id
					end) 
				end as columnValue
				,columnClass
				,columnType
				,columnObject = ''
				--,columnObject = case when a.field_name = 'BuildingCd' then columnObject + b.ProjectCd 
									--else columnObject end
				,isSpecial
				,isRequire
				,isDisable
				,isVisiable
				,isnull(a.columnTooltip,[columnLabel]) as columnTooltip
			FROM dbo.fn_config_form_gets(@table_key, @acceptLanguage) a
				CROSS JOIN #tempIn b
			WHERE  a.table_name = @table_key
				AND (a.isVisiable = 1 or a.isRequire =1)
			order by ordinal
		
			
	end try
	begin catch
		declare	@ErrorNum				int,
				@ErrorMsg				varchar(200),
				@ErrorProc				varchar(50),

				@SessionID				int,
				@AddlInfo				varchar(max)

		set @ErrorNum					= error_number()
		set @ErrorMsg					= 'sp_res_project_field ' + error_message()
		set @ErrorProc					= error_procedure()

		set @AddlInfo					= ' '

		exec utl_Insert_ErrorLog @ErrorNum, @ErrorMsg, @ErrorProc, 'Projects', 'GET', @SessionID, @AddlInfo
	end catch