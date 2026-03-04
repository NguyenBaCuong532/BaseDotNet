
CREATE PROCEDURE [dbo].[sp_res_apartment_household_filter] 
    @userId UNIQUEIDENTIFIER = NULL,
    @acceptLanguage NVARCHAR(50) = N'vi-VN'
AS
BEGIN TRY
    SET NOCOUNT ON;

    DECLARE @tableKey NVARCHAR(100) = N'apartment_household_filter';
    DECLARE @groupKey NVARCHAR(200) = N'common_group_info';

    SELECT id = NULL,
           tableKey = @tableKey,
           groupKey = @groupKey;

    SELECT *
    FROM [dbo].[fn_get_field_group_lang](@groupKey, @acceptLanguage)
    ORDER BY intOrder;

    -- Filter fields
    SELECT a.id,
           a.[table_name],
           a.[field_name],
           a.[view_type],
           a.[data_type],
           a.[ordinal],
           a.[columnLabel],
           a.[group_cd],
           columnValue = a.columnDefault,
           a.[columnClass],
           a.[columnType],
           a.[columnObject],
           a.[isSpecial],
           a.[isRequire],
           a.[isDisable],
           a.[IsVisiable],
           a.[columnDisplay],
           a.[IsEmpty],
           columnTooltip = ISNULL(a.columnTooltip, a.[columnLabel]),
           a.[isIgnore]
    FROM dbo.fn_config_form_gets(@tableKey, @acceptLanguage) a
    ORDER BY a.ordinal;

END TRY
BEGIN CATCH
    DECLARE @ErrorNum INT,
            @ErrorMsg VARCHAR(200),
            @ErrorProc VARCHAR(50),
            @SessionID INT,
            @AddlInfo VARCHAR(MAX);

    SET @ErrorNum = ERROR_NUMBER();
    SET @ErrorMsg = 'sp_res_household_filter' + ERROR_MESSAGE();
    SET @ErrorProc = ERROR_PROCEDURE();

    SET @AddlInfo = ' ';

    EXEC utl_errorlog_set @ErrorNum,
                          @ErrorMsg,
                          @ErrorProc,
                          'apartment_household',
                          'GET',
                          @SessionID,
                          @AddlInfo;
END CATCH;