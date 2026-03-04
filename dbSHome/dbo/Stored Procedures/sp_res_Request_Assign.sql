
CREATE PROCEDURE [dbo].[sp_res_Request_Assign] @userId NVARCHAR(450)
    , @requestID BIGINT
    , @assign_userId NVARCHAR(100)
    , @assignRole INT
    , @used BIT
AS
BEGIN TRY
    IF @Used = 1
    BEGIN
        IF NOT EXISTS (
                SELECT 1
                FROM MAS_Request_Assign
                WHERE requestId = @requestID
                    AND userId = @assign_userId
                )
            INSERT INTO [dbo].MAS_Request_Assign (
                [RequestId]
                , userId
                , assignRole
                )
            VALUES (
                @RequestId
                , @assign_userId
                , @assignRole
                )
        ELSE
            UPDATE MAS_Request_Assign
            SET assignRole = @assignRole
            WHERE requestId = @requestID
                AND userId = @assign_userId
    END
    ELSE
        DELETE
        FROM [dbo].MAS_Request_Assign
        WHERE [RequestId] = @RequestId
            AND userId = @assign_userId
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