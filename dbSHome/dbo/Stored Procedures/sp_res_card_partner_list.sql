
CREATE PROCEDURE [dbo].[sp_res_card_partner_list] 
	 @UserId NVARCHAR(50) = NULL
    ,@projectCd VARCHAR(50)
AS
BEGIN TRY
    SELECT [value] = partner_id
        , [name] = partner_name
    FROM MAS_CardPartner
    WHERE @projectCd IS NULL 
	OR projectCd = @projectCd
END TRY

BEGIN CATCH
    DECLARE @ErrorNum INT
        , @ErrorMsg VARCHAR(200)
        , @ErrorProc VARCHAR(50)
        , @SessionID INT
        , @AddlInfo VARCHAR(MAX);

    SET @ErrorNum = ERROR_NUMBER();
    SET @ErrorMsg = 'sp_res_card_partner_list' + ERROR_MESSAGE();
    SET @ErrorProc = ERROR_PROCEDURE();
    SET @AddlInfo = ' ';

    EXEC utl_Insert_ErrorLog @ErrorNum
        , @ErrorMsg
        , @ErrorProc
        , 'MAS_CardPartner'
        , 'GET'
        , @SessionID
        , @AddlInfo;
END CATCH;