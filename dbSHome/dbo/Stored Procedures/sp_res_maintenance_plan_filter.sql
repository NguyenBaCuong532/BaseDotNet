CREATE PROCEDURE [dbo].[sp_res_maintenance_plan_filter]
    @userId UNIQUEIDENTIFIER = NULL,
    @acceptLanguage NVARCHAR(50) = N'vi-VN'
AS
BEGIN TRY
    SET NOCOUNT ON;
    
    DECLARE @tableKey NVARCHAR(100) = N'maintenance_plan_filter';
    
    SELECT tableKey = @tableKey;

    SELECT a.[id], 
           a.[table_name], 
           a.[field_name], 
           a.[view_type], 
           a.[data_type], 
           a.[ordinal], 
           a.[columnLabel], 
           a.[columnType], 
           a.[columnObject], 
           a.[IsVisiable], 
           a.[is_active],
           a.[columnDisplay],
           a.[isIgnore]
    FROM dbo.fn_config_form_gets(@tableKey, @acceptLanguage) a
    WHERE a.[is_active] = 1
    ORDER BY a.[ordinal];
END TRY
BEGIN CATCH
    DECLARE @ErrorNum INT, @ErrorMsg VARCHAR(200), @ErrorProc VARCHAR(50), @SessionID INT, @AddlInfo VARCHAR(MAX);
    SET @ErrorNum = ERROR_NUMBER();
    SET @ErrorMsg = 'sp_res_maintenance_plan_filter ' + ERROR_MESSAGE();
    SET @ErrorProc = ERROR_PROCEDURE();
    EXEC utl_errorlog_set @ErrorNum, @ErrorMsg, @ErrorProc, 'MaintenancePlan', 'GetFilter', @SessionID, @AddlInfo;
END CATCH;