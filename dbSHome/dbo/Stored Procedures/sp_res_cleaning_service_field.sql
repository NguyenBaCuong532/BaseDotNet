
CREATE PROCEDURE [dbo].[sp_res_cleaning_service_field]
    @UserId    UNIQUEIDENTIFIER = NULL,
    @RequestId NVARCHAR(450) = NULL,
    @acceptLanguage NVARCHAR(50) = N'vi-VN'
AS
BEGIN TRY
    IF @RequestId IS NULL
        SET @RequestId = null;

    -- 1. Thông tin chung
    SELECT 
            --a.id,
       --    a.apartment_id,
           --CONVERT(NVARCHAR(5), a.created_dt, 108) + ' - ' + CONVERT(NVARCHAR(10), a.created_dt, 103) AS RequestDate,
         --  a.created_by,

           --  a.request_code,
             ap.RoomCode,
           --  u.fullName as created_by,
           --  FORMAT(a.created_dt, 'HH:mm:ss dd/MM/yyyy') AS AtTime,
           --sv.name,
           --Status = s.objValue1 ,
           --a.is_quick_support as IsNow,


           ISNULL([Status], 0) [Status],
           [tableKey] = 'MAS_Service_Requests'
    FROM [dbo].service_request a
    JOIN [service] sv             ON sv.[id] = a.service_id
        JOIN MAS_Apartments ap        ON ap.ApartmentId = a.apartment_id
        JOIN service_package p        ON p.id = a.package_id
        LEFT JOIN [dbo].fn_config_data_gets_lang('request_st', @acceptLanguage) s ON s.objCode = a.[status]
        LEFT JOIN request_review r     ON r.src_id = a.id
        LEFT JOIN UserInfo u           ON u.userId = r.created_by
    WHERE a.id = @RequestId;

    -- 2. Nhóm tiêu đề
    SELECT '1' AS group_cd,
           N'Thông tin chung' AS group_name;

    -- 3. Trả về form field khi có request
    IF @RequestId IS NOT NULL
       AND EXISTS (SELECT 1 FROM dbo.service_request WHERE id = @RequestId)
    BEGIN
        SELECT a.id,
               a.table_name,
               a.field_name,
               a.view_type,
               a.data_type,
               a.ordinal,
               a.columnLabel,
               '1' AS group_cd,
               CASE a.data_type
                    WHEN 'nvarchar' THEN
                        CONVERT(NVARCHAR(350),
                            CASE a.field_name
                                WHEN 'requestTypeName' THEN ''
                                WHEN 'roomCode'        THEN ap.RoomCode
                                WHEN 'fullName'        THEN u.FullName
                                WHEN 'createBy'        THEN u.FullName

                                WHEN 'statusName'      THEN ''
                                WHEN 'onTime'          THEN CONVERT(NVARCHAR(10), sr.created_dt, 103) + ' ' + CONVERT(NVARCHAR(5), sr.created_dt, 108)
                                WHEN 'requestDate'     THEN FORMAT(sr.created_dt, 'MM/dd/yyyy hh:mm:ss')
                                WHEN 'requestId'     THEN sr.request_code
                            END)
                    ELSE
                        CONVERT(NVARCHAR(50),
                            CASE a.field_name
                                WHEN 'requestTypeId' THEN 0
                                WHEN 'status'        THEN sr.status
                                WHEN 'isNow'         THEN sr.is_quick_support
                                
                            END)
               END AS columnValue,
               a.columnClass,
               a.columnType,
               a.columnObject,
               a.isSpecial,
               a.isRequire,
               a.isDisable,
               a.isVisiable,
               a.[IsEmpty],
               ISNULL(a.columnTooltip, a.[columnLabel]) AS columnTooltip
        FROM dbo.fn_config_form_gets('MAS_Service_Requests', @acceptLanguage) a
        JOIN service_request sr       ON sr.id = @RequestId
        JOIN [service] sv             ON sv.[id] = sr.service_id
        JOIN MAS_Apartments ap        ON ap.ApartmentId = sr.apartment_id
        JOIN service_package p        ON p.id = sr.package_id
        LEFT JOIN [dbo].fn_config_data_gets_lang('request_st', @acceptLanguage) s ON s.objCode = sr.[status]
        LEFT JOIN request_review r     ON r.src_id = sr.id
        LEFT JOIN UserInfo u           ON u.userId = r.created_by
        WHERE (a.isVisiable = 1 OR a.isRequire = 1)
        ORDER BY a.ordinal;
    END
    ELSE
    BEGIN
        -- Trả về default form khi chưa có request
        SELECT a.[id],
               a.[table_name],
               a.[field_name],
               a.[view_type],
               a.[data_type],
               a.[ordinal],
               a.[columnLabel],
               a.group_cd,
               a.columnDefault AS columnValue,
               a.[columnClass],
               a.[columnType],
               a.[columnObject],
               a.[isSpecial],
               a.[isRequire],
               [isDisable] = 0,
               a.[isVisiable],
               ISNULL(a.columnTooltip, a.[columnLabel]) AS columnTooltip
        FROM dbo.fn_config_form_gets('MAS_Service_Requests', @acceptLanguage) a
        ORDER BY a.ordinal;
    END

END TRY
BEGIN CATCH
    DECLARE @ErrorNum INT,
            @ErrorMsg VARCHAR(200),
            @ErrorProc VARCHAR(50),
            @SessionID INT,
            @AddlInfo VARCHAR(MAX);
    SET @ErrorNum = ERROR_NUMBER();
    SET @ErrorMsg = 'sp_res_request_field ' + ERROR_MESSAGE();
    SET @ErrorProc = ERROR_PROCEDURE();
    SET @AddlInfo = ' ';
    EXEC utl_Insert_ErrorLog
         @ErrorNum,
         @ErrorMsg,
         @ErrorProc,
         'RequestFix',
         'GET',
         @SessionID ,
         @AddlInfo;
END CATCH;