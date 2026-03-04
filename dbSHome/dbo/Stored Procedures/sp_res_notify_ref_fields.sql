








CREATE procedure [dbo].[sp_res_notify_ref_fields]
	@UserId			UNIQUEIDENTIFIER,
	@external_key	nvarchar(50),
	@source_ref		uniqueidentifier,
	@acceptLanguage NVARCHAR(50) = N'vi-VN'
as
begin try
	SET NOCOUNT ON;

	-- Khai báo biến
	DECLARE @tableKey NVARCHAR(100) = N'NotifyRef';
	DECLARE @groupKey NVARCHAR(200) = N'common_group';
	
	if exists(select source_ref from NotifyRef where source_ref = @source_ref) 
	begin
		-- =============================================
		-- RESULT SET 1: INFO - Thông tin cơ bản
		-- =============================================
		select source_ref as id
			,tableKey = @tableKey
			,groupKey = @groupKey
		from NotifyRef a
		where source_ref = @source_ref 

		-- =============================================
		-- RESULT SET 2: GROUPS - Nhóm field
		-- =============================================
		SELECT *
		FROM dbo.fn_get_field_group_lang(@groupKey, @acceptLanguage) 
		ORDER BY intOrder;

		-- =============================================
		-- RESULT SET 3: DATA - Dữ liệu field với columnValue động
		-- =============================================
		SELECT a.id
			  ,a.[table_name]
			  ,a.[field_name]
			  ,a.[view_type]
			  ,a.[data_type]
			  ,a.[ordinal]
			  ,a.[columnLabel]
			  ,a.[group_cd]
			  ,columnValue = case a.[data_type] 
				  when 'nvarchar' then convert(nvarchar(max), case a.[field_name] 						
						when 'refKey' then b.refKey 
						when 'refName' then b.refName 
						when 'created_by' then b.created_by 
						when 'refIcon' then b.refIcon
						when 'external_key' then b.external_key
					end) 
				  when 'datetime' then convert(nvarchar(100),case a.[field_name] 
						when 'created_dt' then format(b.created_dt,'dd/MM/yyyy HH:mm:ss')
						end)
				  else convert(nvarchar(50),case a.[field_name] 
						when 'ref_st' then b.ref_st
					end) end
			  ,a.[columnClass]
			  ,a.[columnType]
			  ,a.[columnObject]
			  ,a.[isSpecial]
			  ,a.[isRequire]
			  ,a.[isDisable]
			  ,a.[IsVisiable]
			  ,a.[isEmpty]
			  ,columnTooltip = isnull(a.columnTooltip,a.[columnLabel])
			  ,a.[columnDisplay]
			  ,a.[isIgnore]
		FROM dbo.fn_config_form_gets(@tableKey, @acceptLanguage) a
		CROSS JOIN NotifyRef b
		WHERE b.source_ref = @source_ref 
		  AND (a.IsVisiable = 1 OR a.isRequire = 1)
		ORDER BY a.ordinal;
	end
	else
	begin
		-- =============================================
		-- RESULT SET 1: INFO - Thông tin cơ bản
		-- =============================================
		select @source_ref as id
			,tableKey = @tableKey
			,groupKey = @groupKey;

		-- =============================================
		-- RESULT SET 2: GROUPS - Nhóm field
		-- =============================================
		SELECT *
		FROM dbo.fn_get_field_group_lang(@groupKey, @acceptLanguage) 
		ORDER BY intOrder;

		-- =============================================
		-- RESULT SET 3: DATA - Dữ liệu field với columnValue động
		-- =============================================
		SELECT a.id
			  ,a.[table_name]
			  ,a.[field_name]
			  ,a.[view_type]
			  ,a.[data_type]
			  ,a.[ordinal]
			  ,a.[columnLabel]
			  ,a.[group_cd]
			  ,columnValue = isnull(case a.[data_type] 
				  when 'nvarchar' then convert(nvarchar(350), case a.[field_name] 
						when 'external_key' then @external_key 
					end) 
				  else convert(nvarchar(50),case a.[field_name] 
						--when 'source_ref' then @source_ref
						when 'ref_st' then 1
					end) end, a.columnDefault)
			  ,a.[columnClass]
			  ,a.[columnType]
			  ,a.[columnObject]
			  ,a.[isSpecial]
			  ,a.[isRequire]
			  ,a.[isDisable]
			  ,a.[IsVisiable]
			  ,a.[isEmpty]
			  ,columnTooltip = isnull(a.columnTooltip,a.[columnLabel])
			  ,a.[columnDisplay]
			  ,a.[isIgnore]
		FROM dbo.fn_config_form_gets(@tableKey, @acceptLanguage) a
		WHERE (a.IsVisiable = 1 OR a.isRequire = 1)
		ORDER BY a.ordinal;
	end
		
		
end try
begin catch
	DECLARE @ErrorNum INT,
			@ErrorMsg VARCHAR(200),
			@ErrorProc VARCHAR(50),
			@SessionID INT,
			@AddlInfo VARCHAR(MAX);

	SET @ErrorNum = ERROR_NUMBER();
	SET @ErrorMsg = 'sp_res_notify_ref_fields ' + ERROR_MESSAGE();
	SET @ErrorProc = ERROR_PROCEDURE();
	SET @AddlInfo = ' ';

	EXEC utl_errorLog_set @ErrorNum, @ErrorMsg, @ErrorProc, 'NotifyRef', 'GET', @SessionID, @AddlInfo;
end catch