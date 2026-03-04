CREATE PROCEDURE [dbo].[sp_res_request_field]
    @UserId UNIQUEIDENTIFIER = NULL,
    @RequestId INT = 0,
    @Oid NVARCHAR(450)= NULL,
    @acceptLanguage NVARCHAR(50) = N'vi-VN'
AS
BEGIN TRY
    SET NOCOUNT ON;

    SET @RequestId = ISNULL(@RequestId, 0);

    DECLARE @RequestDate NVARCHAR(50);

SELECT @RequestDate =
    CONVERT(NVARCHAR(5), RequestDt, 108) + ' - ' + CONVERT(NVARCHAR(10), RequestDt, 103)
FROM dbo.MAS_Requests
WHERE requestId = @RequestId;



    DECLARE @group_key VARCHAR(50) = 'request_group';
    DECLARE @table_key VARCHAR(50) = 'MAS_Requests';

    /* ========== 1) Root / Thông tin chung ========== */
    SELECT  a.RequestId,
            a.ApartmentId,
            a.Comment,
            @RequestDate AS RequestDate,
            a.RequestTypeId,
            isnull(a.Status,0) as [Status],
            a.thread_id,
            tableKey = @table_key,
            groupKey = @group_key
    FROM dbo.MAS_Requests a
    WHERE a.requestId = @RequestId;

    /* ========== 2) Group definition (đúng format backend cần) ========== */
    IF EXISTS (SELECT 1 FROM dbo.fn_get_field_group_lang(@group_key, @acceptLanguage))
    BEGIN
        SELECT *
        FROM dbo.fn_get_field_group_lang(@group_key, @acceptLanguage)
        ORDER BY intOrder;
    END
    ELSE
    BEGIN
        -- fallback: để backend luôn có group_key
        SELECT  group_table  = NULL,
                group_key    = @group_key,
                group_column = 'col-12',
                group_cd     = '1',
                group_name   = N'Thông tin chung',
                isGridEditor = CAST(0 AS bit),
                expand       = CAST(1 AS bit);
    END

    /* ========== 3) Fields (LUÔN trả ra theo sys_config_form) ========== */
    IF EXISTS (SELECT 1 FROM dbo.MAS_Requests WHERE requestId = @RequestId)
    BEGIN
        SELECT  a.id,
                a.table_name,
                a.field_name,
                a.view_type,
                a.data_type,
                a.ordinal,
                a.columnLabel,
                a.group_cd,
                columnValue =
                    ISNULL(
                        CASE
                            WHEN a.data_type = 'nvarchar' THEN
                                CONVERT(NVARCHAR(350),
                                    CASE a.field_name
                                        WHEN 'comment'          THEN r.comment
                                        WHEN 'requestTypeName'  THEN b.requestTypeName
                                        WHEN 'roomCode'         THEN d.RoomCode
                                        WHEN 'fullName'         THEN e.FullName
                                        WHEN 'projectName'      THEN f.ProjectName
                                        WHEN 'statusName'       THEN s.statusName
                                        WHEN 'projectCd'        THEN f.ProjectCd
                                        WHEN 'onTime'           THEN CASE WHEN r.atTime IS NULL THEN NULL
                                                                         ELSE CONVERT(NVARCHAR(5), r.atTime, 108) + ' - ' + CONVERT(NVARCHAR(10), r.atTime, 103) END
                                        WHEN 'requestDate' THEN @RequestDate


                                        WHEN 'userLogin'        THEN u.loginName
                                    END
                                )
                            ELSE
                                CONVERT(NVARCHAR(50),
                                    CASE a.field_name
                                        WHEN 'requestTypeId' THEN b.requestTypeId
                                        WHEN 'status'        THEN r.status
                                        WHEN 'isNow'         THEN r.isNow
                                        WHEN 'requestId'     THEN r.requestId
                                    END
                                )
                        END,
                        a.columnDefault
                    ),
                a.columnClass,
                a.columnType,
                a.columnObject,
                a.isSpecial,
                a.isRequire,
                a.isDisable,
                a.isVisiable,
                IsEmpty = ISNULL(a.IsEmpty, 0),
                columnTooltip = ISNULL(a.columnTooltip, a.columnLabel)
                , a.columnDisplay
                , a.isIgnore
        FROM fn_config_form_gets(@table_key, @acceptLanguage) a
        LEFT JOIN dbo.MAS_Requests r         ON r.requestId = @RequestId
        LEFT JOIN MAS_Request_Types b        ON r.requestTypeId = b.requestTypeId
        LEFT JOIN MAS_Apartments d           ON r.apartmentId   = d.ApartmentId
        LEFT JOIN UserInfo u                 ON r.requestUserId = u.UserId
        LEFT JOIN MAS_Customers e            ON e.CustId        = u.CustId
        LEFT JOIN MAS_Buildings f            ON d.buildingOid   = f.oid
        LEFT JOIN CRM_Status s               ON r.status        = s.statusId AND s.statusKey = 'Request'
        --WHERE (a.isVisiable = 1 OR a.isRequire = 1)
        ORDER BY a.ordinal;
    END
    ELSE
    BEGIN
        SELECT  a.id, a.table_name, a.field_name, a.view_type, a.data_type, a.ordinal, a.columnLabel,
                a.group_cd,
                columnValue = a.columnDefault,
                a.columnClass, a.columnType, a.columnObject,
                a.isSpecial, a.isRequire, isDisable = 0, a.isVisiable,
                IsEmpty = ISNULL(a.IsEmpty, 0),
                columnTooltip = ISNULL(a.columnTooltip, a.columnLabel)
                , a.columnDisplay
                , a.isIgnore
        FROM fn_config_form_gets(@table_key, @acceptLanguage) a
        ORDER BY a.ordinal;
    END

    /* ========== 4) Attach ========== */
    SELECT  [id],[requestId],[processId],[attachUrl],[attachType],attachFileName,
            1 as used,[createDt]
    FROM dbo.MAS_Request_Attach
    WHERE requestId = @RequestId AND processId = 0;

    /* ========== 5) Role ========== */
    SELECT [assignRole],[assignRoleName]
    FROM [CRM_Assign_Role];

    /* ========== 6) Assign ========== */
    SELECT  a.[Id], a.requestId, a.[userId], a.[assignRole],
            b.loginName as userName,
            1 as Used,
            ISNULL(b.fullName,c.fullName) as fullName,
            b.avatarUrl,
            ISNULL(b.phone ,c.phone) as phone,
            ISNULL(b.email,c.email) as email
    FROM MAS_Request_Assign a
    JOIN UserInfo b      ON a.userId = b.userId
    JOIN MAS_Customers c ON b.custId = c.CustId
    WHERE a.requestId = @RequestId;

END TRY
BEGIN CATCH
    DECLARE @ErrorNum INT, @ErrorMsg VARCHAR(200), @ErrorProc VARCHAR(50), @SessionID INT, @AddlInfo VARCHAR(MAX);
    SET @ErrorNum = ERROR_NUMBER();
    SET @ErrorMsg = 'sp_res_request_field ' + ERROR_MESSAGE();
    SET @ErrorProc = ERROR_PROCEDURE();
    SET @AddlInfo = ' ';
    EXEC utl_Insert_ErrorLog @ErrorNum, @ErrorMsg, @ErrorProc, 'RequestFix', 'GET', @SessionID, @AddlInfo;
END CATCH;

--EXEC dbo.sp_res_request_field @UserId = NULL, @RequestId = 3041;