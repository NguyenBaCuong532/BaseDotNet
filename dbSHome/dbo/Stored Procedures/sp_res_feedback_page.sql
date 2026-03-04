CREATE PROCEDURE [dbo].[sp_res_feedback_page] 
	  @UserId UNIQUEIDENTIFIER
    , @clientId NVARCHAR(50) = null
    , @projectCd NVARCHAR(40) = NULL
    , @filter NVARCHAR(100)
    , @gridWidth			int				= 0
    , @Offset INT = 0
    , @PageSize INT = 10
    , @acceptLanguage NVARCHAR(50) = N'vi-VN'
    
AS
BEGIN TRY
    declare @Total		bigint
    declare @GridKey	nvarchar(100) = 'view_MAS_Feedbacks_page'
    DECLARE @status_key NVARCHAR(50) = 'feedback_status_new'

    SET @Offset = isnull(@Offset, 0)
    SET @PageSize = isnull(@PageSize, 10)
    SET @Total = isnull(@Total, 0)
    SET @filter = isnull(@filter, '')

    IF @PageSize = 0
        SET @PageSize = 10

    IF @Offset < 0
        SET @Offset = 0

    SELECT @Total = count(a.FeedbackId)
    FROM
        [MAS_Feedbacks] a
        INNER JOIN UserInfo b ON a.UserId = b.UserId
        INNER JOIN MAS_Customers c ON b.CustId = c.CustId
        INNER JOIN [MAS_Apartments] n ON a.ApartmentId = n.ApartmentId
        JOIN MAS_Projects p ON n.projectCd = p.projectCd
    WHERE
        (
            @filter = ''
            OR n.RoomCode LIKE @filter
            OR c.Phone LIKE '%' + @filter + '%'
            OR c.FullName LIKE '%' + @filter + '%'
        )
        and exists(select 1 from UserProject up where up.userId = @userId and up.projectCd = @ProjectCd)

    --and exists (SELECT * FROM [dbo].[fn_Exists_CustCategory] (@UserId,null) where CategoryCd = mb.ProjectCd)
    --root	
    select
        recordsTotal = @Total
        ,recordsFiltered = @Total
        ,gridKey = @GridKey
        ,valid = 1
        
      --grid config
    IF @Offset = 0
    BEGIN
        SELECT *
        FROM [dbo].fn_config_list_gets_lang(@GridKey, 0, @acceptLanguage)
        ORDER BY [ordinal];
    END

    --1 feedbacks
    SELECT p.projectName
        , n.[RoomCode]
        , c.FullName
        , c.AvatarUrl
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
        , StatusName = s.objValue1 
        , ViewByUser = u.FullName
        , ViewTime = FORMAT(viewed_at, 'dd/MM/yyyy HH:mm')
    FROM
        [MAS_Feedbacks] a
        INNER JOIN UserInfo b ON a.UserId = b.UserId
        INNER JOIN MAS_Customers c ON b.CustId = c.CustId
        INNER JOIN [MAS_Apartments] n ON a.ApartmentId = n.ApartmentId
        JOIN MAS_Projects p ON n.projectCd = p.projectCd
        LEFT JOIN MAS_FeedbackType f ON f.FeedbackTypeId = a.FeedbackTypeId
        LEFT JOIN Users u ON u.UserId = a.viewed_by
        LEFT JOIN dbo.fn_config_data_gets_lang(@status_key, @acceptLanguage) s
        ON s.objCode = a.[Status]
    WHERE p.projectCd=@projectCd and
        (
            @filter = ''
            OR n.RoomCode LIKE @filter
            OR c.Phone LIKE '%' + @filter + '%'
            OR c.FullName LIKE '%' + @filter + '%'
        )
        and exists(select 1 from UserProject up where up.userId = @userId and up.projectCd = @ProjectCd)
    ORDER BY a.[InputDate] DESC
    offset @Offset rows FETCH NEXT @PageSize rows ONLY
END TRY

BEGIN CATCH
    DECLARE @ErrorNum INT
        , @ErrorMsg VARCHAR(200)
        , @ErrorProc VARCHAR(50)
        , @SessionID INT
        , @AddlInfo VARCHAR(max)

    SET @ErrorNum = error_number()
    SET @ErrorMsg = 'sp_res_Feedback_page ' + error_message()
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