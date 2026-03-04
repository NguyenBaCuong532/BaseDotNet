CREATE PROCEDURE [dbo].[sp_res_billing_invoices_field]
    @UserId uniqueidentifier = NULL,
    @project_code VARCHAR(50) = NULL,
    @ProjectCd VARCHAR(50) = NULL,
    @BuildingCd NVARCHAR(50) = NULL,
    @FloorNo NVARCHAR(20) = NULL,
    @ApartmentCd NVARCHAR(50) = NULL,
    @oid uniqueidentifier = NULL,
    @periods_oid VARCHAR(50) = NULL,
    @AcceptLanguage VARCHAR(20) = 'vi-VN'
AS
BEGIN TRY
    SET NOCOUNT ON;

    -- Backward/forward compatibility: allow clients to send ProjectCd
    IF (@project_code IS NULL AND @ProjectCd IS NOT NULL)
        SET @project_code = @ProjectCd;

    DECLARE @GroupKey NVARCHAR(100) = 'common_group' -- sys_config_data
    DECLARE @TableName NVARCHAR(100) = 'filter_invoice_create';--sys_config_form

    -- Config Info
    SELECT 
        CONVERT(UNIQUEIDENTIFIER, @oid) as gd,
        @TableName AS tableKey,
        @GroupKey AS groupKey
		
    -- Get Group Info
    SELECT * FROM [dbo].[fn_get_field_group](@GroupKey) ORDER by intOrder
	
    -- Fields Info
    SELECT
        [columnValue] = CASE [data_type]
                            WHEN 'varchar' THEN CONVERT(NVARCHAR(MAX), 
                                CASE [field_name]
                                    WHEN 'ProjectCd' THEN @project_code
                                    WHEN 'periods_oid' THEN @periods_oid
                                    WHEN 'BuildingCd' THEN ISNULL(@BuildingCd, '')
                                    WHEN 'FloorNo' THEN ISNULL(@FloorNo, '')
                                    WHEN 'ApartmentCd' THEN ISNULL(@ApartmentCd, '')
                                END)
                        END,
        [field_name],
        [view_type],
        [data_type],
        [ordinal],
        [columnLabel],
        [group_cd],
        [columnClass],
        [columnType],
        [columnObject] = CASE
                              WHEN a.[field_name] = 'BuildingCd' THEN ISNULL(a.[columnObject], '') + @project_code
                              WHEN a.[field_name] = 'FloorNo' THEN ISNULL(a.[columnObject], '') + @BuildingCd
                              WHEN a.[field_name] = 'apartmentCd' THEN ISNULL(a.[columnObject], '')
                                                    + @project_code + '&buildingCd=' + @BuildingCd
                                                    + IIF(@FloorNo IS NULL OR TRIM(@FloorNo) = '', '', CONCAT('&floorNo=', @FloorNo))
                              ELSE a.[columnObject]
                          END,
        [isSpecial],
        [isRequire],
        [isDisable] = CASE WHEN [field_name] IN('ProjectCd') THEN 1 ELSE [isDisable] END,
        [IsVisiable],
        [IsEmpty],
        isnull(a.columnTooltip, a.[columnLabel]) as columnTooltip,
        [columnDisplay],
        [isIgnore]
    FROM
        dbo.[fn_config_form_gets](@TableName, @AcceptLanguage) a
--         OUTER APPLY (SELECT TOP 1 * FROM mas_billing_invoices d WHERE oid = @oid) b
    ORDER BY a.group_cd, a.ordinal

END TRY
BEGIN CATCH
    DECLARE @ErrorNum INT, @ErrorMsg VARCHAR(200), @ErrorProc VARCHAR(50), @SessionID INT, @AddlInfo VARCHAR(MAX)
    SET @ErrorNum = error_number()
    SET @ErrorMsg = 'Line: ' + CONVERT(nvarchar(300), error_line()) + ' Msg: ' + error_message();
    SET @ErrorProc = error_procedure()
    SET @AddlInfo = 'UserId: ' + CONVERT(NVARCHAR(50), @UserId)
    EXEC utl_ErrorLog_Set @ErrorNum, @ErrorMsg, @ErrorProc, '', '', @SessionID, @AddlInfo 
END CATCH;