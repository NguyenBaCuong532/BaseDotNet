
CREATE PROCEDURE [dbo].[sp_res_request_assignment_tab]
(
      @UserId    NVARCHAR(450)
    , @RequestId INT
    , @Filter    NVARCHAR(100) = ''
    , @Offset    INT = 0
    , @PageSize  INT = 50
)
AS
BEGIN TRY
    SET NOCOUNT ON;

    SET @Filter   = ISNULL(@Filter, '');
    SET @Offset   = ISNULL(@Offset, 0);
    SET @PageSize = ISNULL(@PageSize, 50);
    IF (@PageSize <= 0) SET @PageSize = 50;
    IF (@Offset < 0)    SET @Offset = 0;


    DECLARE @MgrUserId  NVARCHAR(450) = NULL;
    DECLARE @ExecUserId NVARCHAR(450) = NULL;

    SELECT TOP 1 @MgrUserId = CONVERT(NVARCHAR(450), a.userId)
    FROM dbo.MAS_Request_Assign a
    WHERE a.requestId = @RequestId AND a.assignRole = 1
    ORDER BY a.Id DESC;

    SELECT TOP 1 @ExecUserId = CONVERT(NVARCHAR(450), a.userId)
    FROM dbo.MAS_Request_Assign a
    WHERE a.requestId = @RequestId AND a.assignRole = 2
    ORDER BY a.Id DESC;


    DECLARE @CurrentStatus INT = 0;
    DECLARE @CurrentStatusName NVARCHAR(255) = N'';

    SELECT TOP 1 @CurrentStatus = ISNULL(r.status, 0)
    FROM dbo.MAS_Requests r
    WHERE r.requestId = @RequestId;

    SELECT TOP 1 @CurrentStatusName = ISNULL(s.statusName, N'')
    FROM dbo.CRM_Status s
    WHERE s.statusKey = 'Request'
      AND s.statusId = @CurrentStatus;

    DECLARE @CurrentAssigneeUserId NVARCHAR(450) = COALESCE(@ExecUserId, @MgrUserId);
    DECLARE @HasAssignee BIT = CASE WHEN @CurrentAssigneeUserId IS NULL THEN 0 ELSE 1 END;
    DECLARE @IsAssignee  BIT = CASE WHEN @CurrentAssigneeUserId = @UserId THEN 1 ELSE 0 END;

    SELECT
          requestId             = @RequestId
        , currentStatus         = @CurrentStatus
        , currentStatusName     = @CurrentStatusName
        , currentAssigneeUserId = @CurrentAssigneeUserId
        , hasAssignee           = @HasAssignee
        , isAssignee            = @IsAssignee
        , canClaim              = CASE WHEN @HasAssignee = 0 THEN CAST(1 AS BIT) ELSE CAST(0 AS BIT) END
        , canChangeAssignee     = CAST(1 AS BIT);


    ;WITH q AS
    (
        SELECT
              a.Id
            , a.requestId
            , userId = CONVERT(NVARCHAR(450), a.userId)
            , a.assignRole
            , userName = COALESCE(ui.loginName, u.loginName, N'')
            , fullName = COALESCE(ui.fullName, c.fullName, ui.loginName, u.loginName, N'')
            , avatarUrl = ISNULL(ui.avatarUrl, N'')
            , phone = COALESCE(ui.phone, c.phone, N'')
            , email = COALESCE(ui.email, c.email, N'')
            , assignRoleName = ISNULL(ar.assignRoleName, N'')
            , used = 1
        FROM dbo.MAS_Request_Assign a
        LEFT JOIN dbo.Users u              ON CONVERT(NVARCHAR(450), a.userId) = CONVERT(NVARCHAR(450), u.UserId)
        LEFT JOIN dbo.UserInfo ui          ON CONVERT(NVARCHAR(450), a.userId) = CONVERT(NVARCHAR(450), ui.userId)
        LEFT JOIN dbo.MAS_Customers c      ON ui.custId = c.CustId
        LEFT JOIN dbo.CRM_Assign_Role ar   ON a.assignRole = ar.assignRole
        WHERE a.requestId = @RequestId
          AND (
                @Filter = ''
             OR COALESCE(ui.loginName, u.loginName, N'') LIKE '%' + @Filter + '%'
             OR COALESCE(ui.fullName, c.fullName, N'')   LIKE '%' + @Filter + '%'
             OR COALESCE(ui.phone, c.phone, N'')         LIKE '%' + @Filter + '%'
             OR COALESCE(ui.email, c.email, N'')         LIKE '%' + @Filter + '%'
          )
    )
    SELECT
          Id, requestId, userId, assignRole, userName, fullName, avatarUrl, phone, email, assignRoleName, used
    FROM q
    ORDER BY Id DESC
    OFFSET @Offset ROWS FETCH NEXT @PageSize ROWS ONLY;

 
    ;WITH st AS
    (
        SELECT s.statusId AS StatusId, ISNULL(s.statusName, N'') AS StatusName
        FROM dbo.CRM_Status s
        WHERE s.statusKey = 'Request'
          AND s.statusId IN (0,1,2,3,4,5)
    ),
    last_p AS
    (
        SELECT *
        FROM
        (
            SELECT
                  p.*
                , rn = ROW_NUMBER() OVER (PARTITION BY p.Status ORDER BY p.ProcessDt DESC, p.ProcessId DESC)
            FROM dbo.MAS_Request_Process p
            WHERE p.requestId = @RequestId
        ) x
        WHERE x.rn = 1
    ),
    base AS
    (
        SELECT
              st.StatusId
            , st.StatusName
            , ProcessId = ISNULL(lp.ProcessId, 0)
            , Dt = COALESCE(lp.ProcessDt, CASE WHEN st.StatusId = 0 THEN r.RequestDt END)
            , Note = COALESCE(NULLIF(lp.Comment, N''), CASE WHEN st.StatusId = 0 THEN r.Comment END, N'')
            , ResolvedUserId =
                COALESCE(
                    
                    CONVERT(NVARCHAR(450), lp.userId),

                    
                    CASE WHEN st.StatusId IN (0,1) THEN @MgrUserId ELSE @ExecUserId END,

                    
                    CONVERT(NVARCHAR(450), r.requestUserId)
                )
        FROM st
        JOIN dbo.MAS_Requests r
          ON r.requestId = @RequestId
        LEFT JOIN last_p lp
          ON lp.Status = st.StatusId
    )
    SELECT
          processId   = b.ProcessId
        , requestId   = @RequestId
        , userId      = b.ResolvedUserId
        , userName    = COALESCE(ui.loginName, u.loginName, N'')
        , fullName    = COALESCE(ui.fullName, c.fullName, ui.loginName, u.loginName, N'')
        , avatarUrl   = ISNULL(ui.avatarUrl, N'')
        , status      = b.StatusId
        , statusName  = b.StatusName
        , comment     = b.Note
        , processDt   = b.Dt
        , processDate = CASE WHEN b.Dt IS NULL THEN N''
                             ELSE CONVERT(NVARCHAR(5), b.Dt, 108) + N' - ' + CONVERT(NVARCHAR(10), b.Dt, 103) END
        , isOwn       = CASE WHEN b.ResolvedUserId = @UserId THEN CAST(1 AS BIT) ELSE CAST(0 AS BIT) END
    FROM base b
    LEFT JOIN dbo.UserInfo ui     ON CONVERT(NVARCHAR(450), ui.userId) = b.ResolvedUserId
    LEFT JOIN dbo.Users u         ON CONVERT(NVARCHAR(450), u.UserId)  = b.ResolvedUserId
    LEFT JOIN dbo.MAS_Customers c ON ui.custId = c.CustId
    ORDER BY b.StatusId;

  
    SELECT
          s.statusId   AS StatusId
        , ISNULL(s.statusName, N'') AS StatusName
    FROM dbo.CRM_Status s
    WHERE s.statusKey = 'Request'
      AND s.statusId IN (0,1,2,3,4,5)
    ORDER BY s.statusId;

END TRY
BEGIN CATCH

    SELECT
          requestId             = @RequestId
        , currentStatus         = 0
        , currentStatusName     = N''
        , currentAssigneeUserId = NULL
        , hasAssignee           = CAST(0 AS BIT)
        , isAssignee            = CAST(0 AS BIT)
        , canClaim              = CAST(0 AS BIT)
        , canChangeAssignee     = CAST(0 AS BIT);

    SELECT TOP 0
          Id            = CAST(NULL AS INT)
        , requestId      = CAST(NULL AS INT)
        , userId         = CAST(NULL AS NVARCHAR(450))
        , assignRole     = CAST(NULL AS INT)
        , userName       = CAST(NULL AS NVARCHAR(255))
        , fullName       = CAST(NULL AS NVARCHAR(255))
        , avatarUrl      = CAST(NULL AS NVARCHAR(500))
        , phone          = CAST(NULL AS NVARCHAR(50))
        , email          = CAST(NULL AS NVARCHAR(255))
        , assignRoleName = CAST(NULL AS NVARCHAR(255))
        , used           = CAST(NULL AS INT);

    SELECT TOP 0
          processId   = CAST(NULL AS INT)
        , requestId   = CAST(NULL AS INT)
        , userId      = CAST(NULL AS NVARCHAR(450))
        , userName    = CAST(NULL AS NVARCHAR(255))
        , fullName    = CAST(NULL AS NVARCHAR(255))
        , avatarUrl   = CAST(NULL AS NVARCHAR(500))
        , status      = CAST(NULL AS INT)
        , statusName  = CAST(NULL AS NVARCHAR(255))
        , comment     = CAST(NULL AS NVARCHAR(2000))
        , processDt   = CAST(NULL AS DATETIME)
        , processDate = CAST(NULL AS NVARCHAR(30))
        , isOwn       = CAST(NULL AS BIT);

    SELECT TOP 0
          StatusId   = CAST(NULL AS INT)
        , StatusName = CAST(NULL AS NVARCHAR(255));
END CATCH