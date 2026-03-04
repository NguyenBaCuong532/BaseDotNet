CREATE PROCEDURE [dbo].[sp_res_card_base_list] 
    @UserId	UNIQUEIDENTIFIER = NULL,
    @AcceptLanguage VARCHAR(20) = 'vi-VN'
    ,@projectCd VARCHAR(50) = null
    ,@Oid		NVARCHAR(50) = null
    , @project_code NVARCHAR(50) = NULL
    ,@filter	NVARCHAR(50) = null
AS
BEGIN TRY
    
    SELECT top 10
        [value] = Code
        ,[name] = Code
    FROM MAS_CardBase a
    WHERE
        (@projectCd IS NULL OR ProjectCode = @projectCd)
        and (exists(select 1 from UserProject x where x.projectCd = a.ProjectCode and x.userId = @userId) or a.ProjectCode is null)
--         and a.IsUsed = 0
        and (a.Code LIKE '%' + @filter + '%')

END TRY

BEGIN CATCH
    DECLARE @ErrorNum INT
        , @ErrorMsg VARCHAR(200)
        , @ErrorProc VARCHAR(50)
        , @SessionID INT
        , @AddlInfo VARCHAR(MAX);

    SET @ErrorNum = ERROR_NUMBER();
    SET @ErrorMsg = 'sp_res_card_base_list' + ERROR_MESSAGE();
    SET @ErrorProc = ERROR_PROCEDURE();
    SET @AddlInfo = ' ';

    EXEC utl_Insert_ErrorLog @ErrorNum
        , @ErrorMsg
        , @ErrorProc
        , 'card_base'
        , 'GET'
        , @SessionID
        , @AddlInfo;
END CATCH;