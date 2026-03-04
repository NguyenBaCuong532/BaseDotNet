-- =============================================
-- Author:		duongpx
-- Create date: 12/10/2024 6:08:57 PM
-- Description:	ch tiết vé xe
-- =============================================
CREATE procedure [dbo].[sp_res_vehicle_internal_field]
	@userId			UNIQUEIDENTIFIER = null,
	@acceptLanguage nvarchar(50) = 'vi-VN',
	@cardVehicleId	int = null,
	@cardVehicleOid	UNIQUEIDENTIFIER = null,
	@empId			uniqueidentifier = null
as
begin try
	IF @cardVehicleOid IS NOT NULL
		SET @cardVehicleId = (SELECT CardVehicleId FROM MAS_CardVehicle WHERE oid = @cardVehicleOid);
	declare @tableKey nvarchar(200) = N'mas_CardVehicle'
		   ,@groupKey nvarchar(200) = N'common_group'

	declare @user_Id nvarchar(150)
	declare @CustId nvarchar(150) 
	declare @fullName nvarchar(450)
	declare @org_Id uniqueidentifier 
	
	drop table if exists #tempIn

	select b.*
		,fullName = c.FullName
		,departmentName = departmentName
		,e.code
		,y.CardCd
	into #tempIn
	from mas_CardVehicle b
		join MAS_Customers c on b.custId = c.custId
		LEFT JOIN mas_Employee e on c.custId = e.custId
		join MAS_Cards y on b.CardId = y.CardId
	WHERE (b.cardVehicleId = @cardVehicleId)
	
	if not exists(select 1 from #tempIn)
	insert into #tempIn (cardVehicleId,custId,CardId,CardCd,VehicleNo
				,fullName,departmentName,code
				)
	select @cardVehicleId,b.custId,0,'',''
		--,email = c.email1
		--,Phone = c.phone1
		,fullName = c.FullName
		,departmentName = departmentName
		,b.code
	from mas_employee b
		join MAS_Customers c on b.custId = c.custId
		--left join Organizes o on b.orgDepId = o.orgDepId
	where b.empId = @empId

	--select top 1 @user_Id = e.userId 
	--	 ,@CustId = e.custId
	--	 ,@org_Id = e.orgDepId
	--	 ,@fullName = u.fullName
	--from Employees e
	--	left join UserInfo u on e.userId = u.userId
	--where e.empId = @empId and e.emp_st = 1

	--if not exists(select 1 from HRM_CardVehicle where CardVehicleId = @cardVehicleId) set @cardVehicleId = 0
	
	select	cardVehicleId = @cardVehicleId
			,@tableKey as tableKey
		    ,groupKey = @groupKey
	--2- cac group

	select * from DBO.fn_get_field_group_lang(@groupKey, @acceptLanguage)

	

	-- data
	--exec dbo.[sp_hrm_config_data_fields] @cardVehicleId, 'cardVehicleId', @tableKey, '#tempIn',@userId,@acceptLanguage

	SELECT a.id	
			,[table_name]
			,[field_name]
			,[view_type]
			,[data_type]
			,[ordinal]
			,[columnLabel]
			,[group_cd]
			,case [data_type] 
				when 'nvarchar' then convert(nvarchar(500), 
				case [field_name] 
					when 'departmentName' then b.departmentName
					when 'CustId' then cast(b.CustId as varchar(50))
					when 'CardCd' then cast(b.CardCd as varchar(50))
					when 'VehicleNo' then b.VehicleNo
					when 'VehicleName' then b.VehicleName
					when 'VehicleColor' then b.VehicleColor
					when 'fullName' then b.fullName
					when 'note' then b.note
					end)
				when 'int' then convert(nvarchar(50), 
				case [field_name] 
					when 'CardVehicleId' then CAST(b.CardVehicleId as varchar(50))
					when 'VehicleTypeId' then CAST(b.VehicleTypeId as varchar(50))
					end)
			when 'datetime' then convert(nvarchar(50), 
				case [field_name]
					when 'StartTime' then FORMAT(b.StartTime, 'dd/MM/yyyy')
					when 'EndTime' then FORMAT(b.EndTime, 'dd/MM/yyyy')
					END) end as columnValue
			,[columnClass]
			,[columnType]
			,[columnObject] = case when field_name in ('CardCd') 
							then [columnObject] + lower(@CustId)
							else [columnObject] end
			,[isSpecial]
			,[isRequire]
			,[isDisable]
			,a.[IsVisiable]
			,a.[IsEmpty]
			,isnull(a.columnTooltip,a.[columnLabel]) as columnTooltip
			,a.columnDisplay
			,a.isIgnore
		FROM dbo.fn_config_form_gets(@tableKey,@acceptLanguage) a
		cross apply #tempIn b
		order by a.ordinal
	
	----image
	--select ImageLink as Url  
	--	  ,ImageType as Type
	-- from HRM_CardVehicle_Image 
	-- where CardVehicleId = @cardVehicleId

end try
begin catch
	declare	@ErrorNum				int,
			@ErrorMsg				varchar(200),
			@ErrorProc				varchar(50),

			@SessionID				int,
			@AddlInfo				varchar(max)

	set @ErrorNum					= error_number()
	set @ErrorMsg					= 'sp_vehicle_internal_field ' + error_message()
	set @ErrorProc					= error_procedure()

	set @AddlInfo					= ' @user: ' + cast(@userId as varchar(50)) 

	exec utl_ErrorLog_Set @ErrorNum, @ErrorMsg, @ErrorProc, 'sp_hrm_employee_vehicle_fields', 'GET', @SessionID, @AddlInfo
end catch