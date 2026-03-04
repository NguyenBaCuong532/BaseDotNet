-- =============================================
-- Author: ANHTT
-- Create date: 2025-09-05 12:38:38
-- Description:	page of feedback
-- Output: page
-- =============================================
CREATE PROCEDURE [dbo].[sp_app_feedback_page]
	  @UserId UNIQUEIDENTIFIER
    , @clientId NVARCHAR(50) = NULL
	, @acceptLanguage NVARCHAR(50) = N'vi-VN'
    , @projectCd NVARCHAR(40) = NULL
    , @filter NVARCHAR(100)
    , @gridWidth INT = 0
    , @Offset INT = 0
    , @PageSize INT = 10
AS
BEGIN TRY
    DECLARE @Total BIGINT
    DECLARE @GridKey NVARCHAR(100) = 'view_app_feedbacks_page'
    DECLARE @status_key NVARCHAR(50) = 'feedback_status_new'

    SET @Offset = isnull(@Offset, 0)
    SET @PageSize = isnull(@PageSize, 10)
    SET @Total = isnull(@Total, 0)
    SET @filter = isnull(@filter, '')

    IF @PageSize = 0
        SET @PageSize = 10

    IF @Offset < 0
        SET @Offset = 0

    SELECT @Total = COUNT_BIG(a.FeedbackId)
    FROM [MAS_Feedbacks] a
    INNER JOIN UserInfo b
        ON a.UserId = b.UserId
    INNER JOIN MAS_Customers c
        ON b.CustId = c.CustId
    INNER JOIN [MAS_Apartments] n
        ON a.ApartmentId = n.ApartmentId
    JOIN MAS_Projects p
        ON n.projectCd = p.projectCd
    WHERE (
            @filter IS NULL
            OR n.RoomCode LIKE @filter
            OR c.Phone LIKE '%' + @filter + '%'
            OR c.FullName LIKE '%' + @filter + '%'
            )
        AND EXISTS (
            SELECT 1
            FROM UserInfo u
            WHERE u.userId = @UserId
                AND (
                    u.userType = 2
                    AND n.projectCd = @projectCd
                    OR u.userId = a.userId
                    )
            )

    --root	
    SELECT recordsTotal = @Total
        , recordsFiltered = @Total
        , gridKey = @GridKey
        , valid = 1

    --grid config
    IF @Offset = 0
    BEGIN
        SELECT *
        FROM [dbo].fn_config_list_gets_lang(@GridKey, 0, @acceptLanguage)
        ORDER BY [ordinal];
    END

    --1 feedbacks
    SELECT a.Oid
        , p.projectName
        , n.[RoomCode]
        , c.FullName
        , c.AvatarUrl
        , f.FeedbackTypeId
        , f.FeedbackTypeName
        , a.Title
        , left(a.Comment, 80) + CASE 
            WHEN len(a.Comment) > 80
                THEN ' ...'
            ELSE ''
            END AS Comment
        , dbo.fn_Get_DateAgo(a.InputDate, getdate()) FeedbackDate
        , a.FeedbackId
        , a.[Status] as status
        , statusName = s.objValue1  
    FROM [MAS_Feedbacks] a
    INNER JOIN UserInfo b
        ON a.UserId = b.UserId
    INNER JOIN MAS_Customers c
        ON b.CustId = c.CustId
    INNER JOIN [MAS_Apartments] n
        ON a.ApartmentId = n.ApartmentId
    JOIN MAS_Projects p
        ON n.projectCd = p.projectCd
    LEFT JOIN MAS_FeedbackType f
        ON f.FeedbackTypeId = a.FeedbackTypeId
    LEFT JOIN dbo.fn_config_data_gets_lang(@status_key, @acceptLanguage) s
        ON s.objCode = a.[Status]
    WHERE  (
            @filter IS NULL
            OR n.RoomCode LIKE @filter
            OR c.Phone LIKE '%' + @filter + '%'
            OR c.FullName LIKE '%' + @filter + '%'
            )
        AND EXISTS (
            SELECT 1
            FROM UserInfo u
            WHERE u.userId = @UserId
                AND (
                    u.userType = 2
                    AND n.projectCd = @projectCd
                    OR u.userId = a.userId
                    )
            )
    ORDER BY a.[InputDate] DESC offset @Offset rows

    FETCH NEXT @PageSize rows ONLY


END TRY

BEGIN CATCH
    DECLARE @ErrorNum INT
        , @ErrorMsg VARCHAR(200)
        , @ErrorProc VARCHAR(50)
        , @SessionID INT
        , @AddlInfo VARCHAR(max)

    SET @ErrorNum = error_number()
    SET @ErrorMsg = error_message()
    SET @ErrorProc = error_procedure()
    SET @AddlInfo = ' '

    EXEC utl_Insert_ErrorLog @ErrorNum
        , @ErrorMsg
        , @ErrorProc
        , 'MAS_Feedbacks'
        , 'GET'
        , @SessionID
        , @AddlInfo
END CATCH