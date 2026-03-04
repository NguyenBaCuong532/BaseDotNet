CREATE PROCEDURE [dbo].[sp_res_card_classify_field] @userId NVARCHAR(450) = NULL
    , @id UNIQUEIDENTIFIER = NULL
AS
BEGIN TRY
    --
    DECLARE @group_key VARCHAR(50) = 'common_group'
    DECLARE @table_key VARCHAR(50) = 'MAS_CardBase'

    --
    SELECT gd = @id
        , tableKey = @table_key
        , groupKey = @group_key;

    SELECT *
    FROM [dbo].[fn_get_field_group](@group_key)
    ORDER BY intOrder;

    --  DECLARE @ReceiptId int = 116455
    --3 tung o trong group
    EXEC sp_get_data_fields @id
        , 'MAS_CardBase'
        , 'Guid_cd'
        
END TRY

BEGIN CATCH
    DECLARE @ErrorNum INT
        , @ErrorMsg VARCHAR(200)
        , @ErrorProc VARCHAR(50)
        , @SessionID INT
        , @AddlInfo VARCHAR(MAX);

    SET @ErrorNum = ERROR_NUMBER();
    SET @ErrorMsg = 'sp_res_card_classify_field' + ERROR_MESSAGE();
    SET @ErrorProc = ERROR_PROCEDURE();
    SET @AddlInfo = ' ';

    EXEC utl_errorlog_set @ErrorNum
        , @ErrorMsg
        , @ErrorProc
        , 'Receipt'
        , 'GetInfo'
        , @SessionID
        , @AddlInfo;
END CATCH;