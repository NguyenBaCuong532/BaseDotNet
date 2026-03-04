

CREATE   PROCEDURE [dbo].[sp_app_notify_ref_list] @userId uniqueidentifier
    , @source_key NVARCHAR(50) = NULL
    , @externalKey NVARCHAR(50) = NULL
AS
BEGIN
    BEGIN TRY
        IF @externalKey IS NULL
            SET @externalKey = 's-resident'

        SELECT [name] = refName
            , [value] = lower([source_ref])
        FROM [dbo].[NotifyRef] a
        WHERE a.external_key = @externalKey
            AND [ref_st] = 1
    END TRY

    BEGIN CATCH
        DECLARE @ErrorNum INT
            , @ErrorMsg VARCHAR(200)
            , @ErrorProc VARCHAR(50)
            , @SessionID INT
            , @AddlInfo VARCHAR(max)

        SET @ErrorNum = error_number()
        SET @ErrorMsg = 'sp_res_notify_ref_list ' + error_message()
        SET @ErrorProc = error_procedure()
        SET @AddlInfo = '@ ' + cast(0 AS VARCHAR)

        EXEC utl_errorLog_set @ErrorNum
            , @ErrorMsg
            , @ErrorProc
            , 'NotifyRef'
            , 'Set'
            , @SessionID
            , @AddlInfo
    END CATCH
END