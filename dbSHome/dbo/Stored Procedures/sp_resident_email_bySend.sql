
-- =============================================
-- Author:		
-- Create date: 
-- Description:	Lấy job gửi email
-- Update: Thêm lock tránh đọc trùng
-- =============================================
CREATE PROCEDURE [dbo].[sp_resident_email_bySend] @id NVARCHAR(100) = NULL,
	@UserId nvarchar(50) = null,
	@AcceptLanguage nvarchar(50) = null
AS
BEGIN TRY
    IF OBJECT_ID('tempdb..#EmailJobs') IS NOT NULL
        DROP TABLE #EmailJobs

    BEGIN TRAN

    SELECT TOP 100 convert(NVARCHAR(50), [id]) AS [id]
        , [mailto] AS [To]
        , [Cc]
        , [Bcc]
        , [SendBy]
        , [Subject]
        , [Contents]
        , [BodyType]
        , CASE 
            WHEN [Attachs] = ''
                THEN NULL
            ELSE [Attachs]
            END AS atts
        , [SendType]
        , [SendName]
        , [SendDate] AS [SendingTime]
        , [custId]
        , cast([sourceId] AS VARCHAR(50)) AS [sourceId]
        , [remart]
        , mailto
        , attachs
        , STATUS
        , send
        , sendDate
        , isRead
        , readDt
        , createId
        , createdDate
        , clientId
        , clientIp
        , sourceKey
    INTO #EmailJobs
    FROM [dbo].EmailJobs s WITH (
            ROWLOCK
            , UPDLOCK
            )
    WHERE (
            mailto IS NOT NULL
            AND mailto <> ''
            )
        AND (
            id = @id
            OR @id IS NULL
            OR @id = ''
            ) --and ([SendDate] is null or [SendDate] <= dateadd(minute,-10,getdate()))
        AND (
            Schedule IS NULL
            OR Schedule <= GETDATE()
            )
    ORDER BY createdDate --desc

    INSERT INTO [dbo].[EmailJobsHistory] (
        [id]
        , [mailto]
        , [cc]
        , [bcc]
        , [sendBy]
        , [subject]
        , [contents]
        , [bodyType]
        , [attachs]
        , [status]
        , [send]
        , [sendName]
        , [sendDate]
        , [sendType]
        , [custId]
        , [isRead]
        , [readDt]
        , [createId]
        , [createdDate]
        , [clientId]
        , [clientIp]
        , [sourceId]
        , [remart]
        , [sourceKey]
        )
    SELECT [id]
        , [mailto]
        , [cc]
        , [bcc]
        , [sendBy]
        , [subject]
        , [contents]
        , [bodyType]
        , [attachs]
        , [status]
        , [send]
        , [sendName]
        , [sendDate]
        , [sendType]
        , [custId]
        , [isRead]
        , [readDt]
        , [createId]
        , [createdDate]
        , [clientId]
        , [clientIp]
        , [sourceId]
        , [remart]
        , [sourceKey]
    FROM #EmailJobs

    DELETE e
    FROM EmailJobs e
    JOIN #EmailJobs s
        ON e.id = s.id

    COMMIT

    SELECT *
    FROM #EmailJobs

    SELECT n_id
        , [attach_name]
        , [attach_url]
        , attach_type
        , s.id
    FROM [dbo].[NotifyAttach] a
    JOIN #EmailJobs s ON a.n_id = s.sourceId
    WHERE s.sourceId IS NOT NULL
	union all
	SELECT n_id = b.sourceOid
		  ,[attach_name] = b.file_name
		  ,[attach_url] = dbo.fn_path_cdn_get(b.file_url)
		  ,attach_type = b.file_type
		  ,id = b.Oid
	FROM meta_info b
	JOIN #EmailJobs s ON b.sourceOid = s.sourceId
	--WHERE sourceOid = @groupFileId;

END TRY

BEGIN CATCH
    DECLARE @ErrorNum INT
        , @ErrorMsg VARCHAR(200)
        , @ErrorProc VARCHAR(50)
        , @SessionID INT
        , @AddlInfo VARCHAR(max)

    SET @ErrorNum = error_number()
    SET @ErrorMsg = 'sp_resident_email_bySend ' + error_message()
    SET @ErrorProc = error_procedure()
    SET @AddlInfo = ''

    EXEC utl_errorLog_set @ErrorNum
        , @ErrorMsg
        , @ErrorProc
        , 'EmailSend'
        , 'Get'
        , @SessionID
        , @AddlInfo
END CATCH