
-- =============================================
-- Author:		duongpx
-- Create date: 12/10/2024 6:08:57 PM
-- Description:	ch tiết thẻ
-- =============================================
CREATE   procedure [dbo].[sp_res_card_internal_field]
	@userId			UNIQUEIDENTIFIER		= null,
	@acceptLanguage nvarchar(50)		= 'vi-VN',
	@cardid			varchar(50)			= null

AS
BEGIN TRY
	declare @tableKey nvarchar(200) = N'HRM_Cards'
		   ,@groupKey nvarchar(200) = N'common_group'
	set @cardid = isnull(@cardid,'')

	select @cardid id
		 ,groupKey = @groupKey
		 ,tableKey = @tableKey

	--group
	SELECT * FROM fn_get_field_group_lang(@groupKey, @acceptLanguage)
	--
	drop table if exists #tempIn
	
	select b.*
		--,email = c.email1
		--,Phone = c.phone1
		--,fullName 
		--,e.departmentName
		--,e.code
	into #tempIn
	from mas_Cards b
		--join mas_Employee e on b.custId = e.custId
	WHERE (b.CardCd = @cardid)
	-- data
	
	--field
	SELECT [id]
		,[table_name]
		,[field_name]
		,[view_type]
		,[data_type]
		,[ordinal]
		,[columnLabel]
		,group_cd
		,case [data_type] 
			when 'nvarchar' then convert(nvarchar(max), case [field_name] 
				when 'cardCd' then b.CardCd
				when 'custId' then b.custId
				when 'projectCd' then b.ProjectCd
				when 'code' then c.code
				when 'custName' then c.FullName 
				when 'Phone' then c.Phone
				when 'email' then c.email
				when 'departmentName' then c.departmentName
				when 'orgName' then c.orgName
				when 'positionTypeName' then c.positionTypeName
				--when 'workplaceName' then c.projectName
				end) 				
			when 'datetime' then case [field_name] 
				when 'issueDate' then format(b.issueDate,'dd/MM/yyyy')
				when 'expireDate' then  format(b.[expireDate],'dd/MM/yyyy')
				END
			WHEN 'int' THEN CONVERT(NVARCHAR(50), CASE [field_name] 
				WHEN 'partner_id' THEN (CAST(ISNULL(b.partner_id,0) AS VARCHAR(50))) 
				WHEN 'CardTypeId' THEN b.CardTypeId
			END)
			else 
			columnDefault END AS columnValue
		,[columnClass]
		,[columnType]
		,[columnObject]
		,[isSpecial]
		,[isRequire] 
		,[isDisable]
		,[IsVisiable]
		,[IsEmpty]
		,isnull(a.columnTooltip,a.[columnLabel]) as columnTooltip
		,columnDisplay
		,isIgnore
	FROM fn_config_form_gets(@tableKey, @acceptLanguage) a
	,#tempIn b
	LEFT JOIN dbo.mas_employee c ON c.CustId = b.CustId
	--WHERE (isvisiable = 1 or isRequire = 1)
		order by ordinal


END TRY
BEGIN CATCH
	declare	@ErrorNum				int,
			@ErrorMsg				varchar(200),
			@ErrorProc				varchar(50),

			@SessionID				int,
			@AddlInfo				varchar(max)

	SET @ErrorNum					= error_number()
	SET @ErrorMsg					= 'sp_hrm_card_fields ' + error_message()
	SET @ErrorProc					= error_procedure()

	SET @AddlInfo					= ' @user: ' + cast(@userId as varchar(50))

	EXEC utl_errorLog_set @ErrorNum, @ErrorMsg, @ErrorProc, 'Emp_Card', 'GET', @SessionID, @AddlInfo
END CATCH