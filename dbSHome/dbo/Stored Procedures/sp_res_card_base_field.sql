CREATE PROCEDURE [dbo].[sp_res_card_base_field] @UserId UNIQUEIDENTIFIER = NULL,
    @AcceptLanguage VARCHAR(20) = 'vi-VN'
    , @id UNIQUEIDENTIFIER = NULL
    , @project_code NVARCHAR(50) = NULL
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
--     EXEC sp_get_data_fields @id
--         , @table_key
--         , 'Guid_cd'
    
    
    -- Fields Info
    SELECT
        CASE [data_type]
            WHEN 'uniqueidentifier'
                THEN CONVERT(NVARCHAR(MAX), 
                    CASE [field_name]
                        WHEN 'oid' THEN b.Guid_cd
                    END)
            WHEN 'nvarchar'
                THEN CONVERT(NVARCHAR(MAX),
                    CASE [field_name]
                        WHEN 'ProjectCode' THEN b.ProjectCode
                        WHEN 'Type' THEN CONVERT(NVARCHAR(50), CASE WHEN b.Type IS NULL 
																	THEN c.CardTypeId
																	ELSE b.Type 
																END)
                    END)
        END AS columnValue,
        [field_name],
        [view_type],
        [data_type],
        [ordinal],
        [columnLabel] = [columnLabel],
        group_cd,
        [columnClass],
        [columnType],
        [columnObject],
        [isSpecial],
        [isRequire],
        [isDisable],
        [IsVisiable],
        [IsEmpty],
        isnull(a.columnTooltip,a.[columnLabel]) as columnTooltip,
        [columnDisplay],
        [isIgnore]
    FROM
        dbo.[fn_config_form_gets](@table_key, NULL) a
        OUTER APPLY (SELECT TOP 1 * FROM MAS_CardBase d WHERE Guid_cd = @id) b
        LEFT JOIN MAS_Cards c ON c.CardCd = b.Code
    ORDER BY a.group_cd, a.ordinal
        
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