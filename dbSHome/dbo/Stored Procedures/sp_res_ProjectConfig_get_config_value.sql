CREATE PROCEDURE [dbo].[sp_res_ProjectConfig_get_config_value]
    @UserId uniqueidentifier = NULL,
    @project_code VARCHAR(50) = '09',
    @config_code VARCHAR(500) = NULL,
	@receive_id VARCHAR(50) = NULL
AS

DECLARE @Messages NVARCHAR(100) = N'Thực hiện thành công';
DECLARE @Valid BIT = 1;
BEGIN TRY
    
    DECLARE @config_value NVARCHAR(500) = NULL;
    DECLARE @config_type NVARCHAR(500) = NULL;

	IF(@receive_id is not null)
	BEGIN
		SELECT @project_code = t.ProjectCd FROM MAS_Service_ReceiveEntry t WHERE ReceiveId = @receive_id
	END
    
    SELECT
        @config_value = IIF(b.config_value IS NULL OR TRIM(b.config_value) = '', a.config_value_default, b.config_value),
        @config_type = a.config_type
    FROM
        par_project_config_default a
        INNER JOIN par_project_config b ON a.config_code = b.config_code AND b.project_code = @project_code
    WHERE a.config_code = @config_code
        
    IF(@config_type = 'file')
        SELECT TOP 1 @config_value = file_url FROM meta_info WHERE sourceOid = @config_value
    
END TRY
BEGIN CATCH
    SET @Valid = 0;
    SET @Messages = error_message();
	
    DECLARE @ErrorNum INT, @ErrorMsg VARCHAR(200), @ErrorProc VARCHAR(50), @SessionID INT, @AddlInfo VARCHAR(MAX)
    SET @ErrorNum = error_number()
    SET @ErrorMsg = 'Line: ' + CONVERT(nvarchar(300), error_line()) + ' Msg: ' + error_message();
    SET @ErrorProc = error_procedure()
    SET @AddlInfo = 'UserId: ' + CONVERT(NVARCHAR(50), @UserId)
    EXEC utl_ErrorLog_Set @ErrorNum, @ErrorMsg, @ErrorProc, '', '', @SessionID, @AddlInfo 
END CATCH

FINALLY:
    SELECT
        Valid = @Valid,
        Messages = @Messages,
        Data = @config_value,
        config_type = @config_type