CREATE PROCEDURE [dbo].[sp_res_get_notify_template_fields]
    @UserID nvarchar(450) = NULL,
    @tempId UNIQUEIDENTIFIER = NULL
AS
BEGIN TRY
    
    -- Lấy danh sách field từ NotifyTemplateField và NotifyField
    SELECT 
        '{' + nf.fieldName + '}' AS value,
        nf.fieldLabel + '-' + '{' + nf.fieldName + '}' AS name
    FROM NotifyField nf
    LEFT JOIN NotifyTemplateField ntf ON ntf.fieldId = nf.fieldId AND ntf.tempId = @tempId
    WHERE nf.formulaId = (SELECT formulaId FROM NotifyTemplate WHERE tempId = @tempId)
    ORDER BY ISNULL(ntf.intOrder, 999), nf.fieldName;
    
END TRY
BEGIN CATCH
    DECLARE @ErrorNum INT,
            @ErrorMsg VARCHAR(200),
            @ErrorProc VARCHAR(50),
            @SessionID INT,
            @AddlInfo VARCHAR(MAX)

    SET @ErrorNum = ERROR_NUMBER()
    SET @ErrorMsg = 'sp_res_get_notify_template_fields ' + ERROR_MESSAGE()
    SET @ErrorProc = ERROR_PROCEDURE()
    SET @AddlInfo = '@tempId: ' + CAST(@tempId AS VARCHAR(100))

    EXEC utl_ErrorLog_Set @ErrorNum, @ErrorMsg, @ErrorProc, 'NotifyTemplate', 'Get', @SessionID, @AddlInfo
END CATCH