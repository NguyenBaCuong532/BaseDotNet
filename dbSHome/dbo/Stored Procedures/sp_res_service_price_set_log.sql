-- =============================================
-- Author:      ThanhMT
-- Create date: 29/08/2025
-- Description: Cấu hình giá dịch vụ - Lưu log
-- =============================================
CREATE PROCEDURE [dbo].[sp_res_service_price_set_log]
    @UserId uniqueidentifier = NULL,
    @project_code VARCHAR(50) = NULL,
    @arr_object_id VARCHAR(MAX),
    @actions VARCHAR(50),
    @table_name VARCHAR(100)
AS
DECLARE @Messages NVARCHAR(MAX) = N'Thực hiện thành công';
DECLARE @Valid BIT = 1;
BEGIN TRY
    
    DECLARE @str_user_id NVARCHAR(50) = CONVERT(NVARCHAR(50), @UserId);

    DECLARE @str_query NVARCHAR(MAX) = 
    'SELECT oid = [Value]
    INTO #arr_object_id
    FROM fn_SplitString('''+ @arr_object_id +''', '','')
    
    SELECT
        oid = NEWID(),
        project_code = '''+ @project_code +''',
        table_name = '''+ @table_name +''',
        object_id = a.oid,
        actions = UPPER(''' + @actions + '''),
        json_content = (SELECT * FROM '+ @table_name +' WHERE oid = a.oid FOR JSON PATH),
        created_user = '''+ @str_user_id +''',
        created_date = GETDATE(),
        last_modified_by = '''+ @str_user_id +''',
        last_modified_date = GETDATE()
    INTO #par_service_price_log
    FROM
        '+ @table_name +' a
        INNER JOIN #arr_object_id b ON b.oid = a.oid

    INSERT INTO par_service_price_log(oid, project_code, table_name, object_id, actions, json_content, created_user, created_date, last_modified_by, last_modified_date)
    SELECT oid, project_code, table_name, object_id, actions, json_content, created_user, created_date, last_modified_by, last_modified_date FROM #par_service_price_log';

--     SELECT str_query = @str_query;
    EXEC(@str_query);

END TRY
BEGIN CATCH
    SET @Valid = 0;
    SET @Messages = error_message();
    DECLARE @ErrorNum INT, @ErrorMsg VARCHAR(MAX), @ErrorProc VARCHAR(50), @SessionID INT, @AddlInfo VARCHAR(MAX)
    SET @ErrorNum = error_number()
    SET @ErrorMsg = 'Line: ' + CONVERT(nvarchar(300), error_line()) + ' Msg: ' + error_message();
    SET @ErrorProc = error_procedure()
    SET @AddlInfo = 'UserId: ' + CONVERT(NVARCHAR(50), @UserId)
    EXEC utl_ErrorLog_Set @ErrorNum, @ErrorMsg, @ErrorProc, '', '', @SessionID, @AddlInfo 
END CATCH

-- SELECT
--     Valid = @Valid,
--     Messages = @Messages