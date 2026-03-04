
CREATE PROCEDURE [dbo].[sp_res_Request_Assign_Multiple] @userId NVARCHAR(450)
    , @requestID BIGINT
    , @assigns UserAssignType READONLY
AS
BEGIN TRY
    -- 
    INSERT INTO [dbo].MAS_Request_Assign (
        [RequestId]
        , userId
        , assignRole
        )
    SELECT @requestID
        , UserId
        , AssignRole
    FROM @assigns a
    WHERE NOT EXISTS (
            SELECT 1
            FROM MAS_Request_Assign sa
            WHERE sa.requestId = @requestID
                AND sa.userId = a.UserId
            )
        AND a.Used = 1

    --
    UPDATE a
    SET a.assignRole = b.AssignRole
    FROM MAS_Request_Assign a
    INNER JOIN @assigns b
        ON a.userId = b.UserId
    WHERE a.requestId = @requestID
        AND b.Used = 1

    --
    DELETE a
    FROM [dbo].MAS_Request_Assign a
    WHERE [RequestId] = @RequestId
        AND EXISTS (
            SELECT 1
            FROM @assigns sa
            WHERE sa.Used = 0
                AND sa.UserId = a.userId
            )
END TRY

BEGIN CATCH
    DECLARE @ErrorNum INT
        , @ErrorMsg VARCHAR(200)
        , @ErrorProc VARCHAR(50)
        , @SessionID INT
        , @AddlInfo VARCHAR(max)

    SET @ErrorNum = error_number()
    SET @ErrorMsg = 'sp_res_Request_Assign ' + error_message()
    SET @ErrorProc = error_procedure()
    SET @AddlInfo = '@UserID ' + @userId

    EXEC utl_Insert_ErrorLog @ErrorNum
        , @ErrorMsg
        , @ErrorProc
        , 'MAS_Request_Assign'
        , 'SET'
        , @SessionID
        , @AddlInfo
END CATCH