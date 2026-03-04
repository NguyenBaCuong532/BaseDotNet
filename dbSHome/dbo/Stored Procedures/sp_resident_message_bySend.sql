
CREATE PROCEDURE [dbo].[sp_resident_message_bySend]
	@UserId nvarchar(50) = null,
	@AcceptLanguage nvarchar(50) = null
AS
BEGIN TRY
    SELECT TOP 20 convert(NVARCHAR(50), n.MessageId) AS MessageId
        , n.Phone
        , n.Contents AS [message]
        , convert(NVARCHAR(50), n.scheduleAt) AS scheduleAt
        , n.brandName
        , n.[partner]
        , n.custName
        , n.custId
        , convert(NVARCHAR(50), n.sourceId) AS sourceId
    FROM MessageJobs AS n
    WHERE (
            scheduleAt IS NULL
            OR CAST((scheduleAt - 599266080000000000) / 10000000 / 24 / 60 / 60 AS DATETIME) > getutcdate()
            )
        AND (
            Schedule IS NULL
            OR Schedule <= GETDATE()
            )
END TRY

BEGIN CATCH
    DECLARE @ErrorNum INT
        , @ErrorMsg VARCHAR(200)
        , @ErrorProc VARCHAR(50)
        , @SessionID INT
        , @AddlInfo VARCHAR(max)

    SET @ErrorNum = error_number()
    SET @ErrorMsg = 'sp_resident_message_bySend ' + error_message()
    SET @ErrorProc = error_procedure()
    SET @AddlInfo = ''

    EXEC utl_errorLog_set @ErrorNum
        , @ErrorMsg
        , @ErrorProc
        , 'MessageJobs'
        , 'Get'
        , @SessionID
        , @AddlInfo
END CATCH