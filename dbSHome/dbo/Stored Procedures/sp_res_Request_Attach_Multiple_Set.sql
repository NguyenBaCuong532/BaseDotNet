
-- ======================================================
CREATE PROCEDURE [dbo].[sp_res_Request_Attach_Multiple_Set] @UserId NVARCHAR(450)
    , @attachments RequestAttachmentType READONLY
AS
BEGIN TRY
    --
    INSERT INTO [dbo].MAS_Request_Attach (
        [requestId]
        , [processId]
        , [attachUrl]
        , [attachType]
        , attachFileName
        , [createDt]
        )
    SELECT RequestId
        , ProcessId
        , AttachUrl
        , AttachType
        , AttachFileName
        , GETDATE()
    FROM @attachments a
    WHERE NOT EXISTS (
            SELECT 1
            FROM MAS_Request_Attach sa
            WHERE sa.id = a.Id
            )

    --
    UPDATE a
    SET a.requestId = b.RequestId
        , a.processId = b.ProcessId
        , a.attachUrl = b.AttachUrl
        , a.attachType = b.AttachType
        , a.attachFileName = b.AttachFileName
        , createDt = GETDATE()
    FROM MAS_Request_Attach a
    INNER JOIN @attachments b
        ON a.id = b.Id
    WHERE b.Used = 1

    DELETE a
    FROM MAS_Request_Attach a
    WHERE EXISTS (
            SELECT 1
            FROM @attachments sa
            WHERE sa.Id = a.id
                AND sa.Used = 0
            )
END TRY

BEGIN CATCH
    DECLARE @ErrorNum INT
        , @ErrorMsg VARCHAR(200)
        , @ErrorProc VARCHAR(50)
        , @SessionID INT
        , @AddlInfo VARCHAR(MAX)

    SET @ErrorNum = error_number()
    SET @ErrorMsg = 'sp_res_Request_Attach_Multiple_Set ' + error_message()
    SET @ErrorProc = error_procedure()
    SET @AddlInfo = ' '

    EXEC utl_Insert_ErrorLog @ErrorNum
        , @ErrorMsg
        , @ErrorProc
        , 'MAS_Request_Attach'
        , 'Set'
        , @SessionID
        , @AddlInfo
END CATCH