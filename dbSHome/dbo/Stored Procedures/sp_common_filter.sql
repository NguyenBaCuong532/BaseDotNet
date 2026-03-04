-- =============================================
-- Author:		duongpx
-- Create date: 7/14/2024 9:43:49 AM
-- Description:	filter dùng chung
-- =============================================
CREATE PROCEDURE [dbo].[sp_common_filter] @userId NVARCHAR(450) = NULL
    , @project_code NVARCHAR(50) = NULL
    , @acceptLanguage NVARCHAR(50) = 'vi-VN'
    , @tableKey NVARCHAR(200) = '_filter'
    , @source_key NVARCHAR(200) = 'common'
    , @n_id UNIQUEIDENTIFIER = NULL
      , @ProjectCd NVARCHAR(50) = NULL 
      ,@Type NVARCHAR(50) = NULL
      ,@DateFrom Datetime = NULL
      ,@DateTo Datetime = NULL
      , @KeyWord NVARCHAR(50) = NULL
    , @queryParams NVARCHAR(4000) = NULL
AS
BEGIN TRY
    DECLARE @fromDate DATETIME = DATEADD(MONTH, DATEDIFF(MONTH, 0, GETDATE()) - 6, 0)
    DECLARE @is_act_push BIT = 0
        , @is_act_sms BIT = 0
        , @is_act_email BIT = 0
        , @to_type NVARCHAR(10)

    SELECT @is_act_push = is_act_push
        , @is_act_sms = is_act_sms
        , @is_act_email = is_act_email
        , @to_type = CASE 
            WHEN CHARINDEX('recruit', source_key, 0) > 0
                THEN '1'
            ELSE '0'
            END
    FROM NotifyInbox
    WHERE n_id = @n_id
    DECLARE @custId UNIQUEIDENTIFIER = dbo.fn_get_customerid(@userId)
    DECLARE @main_apartment bigint = dbo.fn_get_apartment_main(@custId)
    --
    SELECT id = NULL
        , tableKey = @tableKey
        , groupKey = 'common_group'

    SELECT *
    FROM [dbo].[fn_get_field_group_lang]('common_group', @acceptLanguage)
    ORDER BY intOrder

    --
    --2 tung o 
    SELECT a.[id]
        , [table_name]
        , [field_name]
        , [view_type]
        , [data_type]
        , [ordinal]
        , [columnLabel]
        , [group_cd]
        , columnValue = CASE field_name
            WHEN 'fromDate'
                THEN FORMAT(@fromDate, 'dd/MM/yyyy')
            WHEN 'toDate'
                THEN FORMAT(GETDATE(), 'dd/MM/yyyy')
            WHEN 'month'
                THEN CAST(MONTH(GETDATE()) AS NVARCHAR(2))
            WHEN 'year'
                THEN CAST(YEAR(GETDATE()) AS NVARCHAR(4))
            WHEN 'monthYear'
                THEN FORMAT(GETDATE(), 'MM/yyyy')
            WHEN 'source_key'
                THEN @source_key
            WHEN 'apartmentId'
                THEN LOWER(@main_apartment)
            ELSE ISNULL(q.[Value], columnDefault)
            END
        , [columnClass]
        , [columnType]
        , [columnObject] = CASE --when field_name in ('projectCd') then [columnObject] + LOWER(CONVERT(nvarchar(50), 3))
            WHEN field_name IN ('source_key', 'source_ref')
                AND (
                    @source_key IS NOT NULL
                    OR @source_key <> ''
                    )
                THEN [columnObject] + @source_key
            ELSE replace([columnObject], 'projectCd=', 'projectCd=' + isnull(@project_code, ''))
            END
        , [isSpecial]
        , [isRequire]
        , [isDisable]
        , [IsVisiable] = CASE 
            WHEN field_name IN ('push_st')
                AND @is_act_push = 1
                THEN 1
            WHEN field_name IN ('email_st')
                AND @is_act_email = 1
                THEN 1
            WHEN field_name IN ('sms_st')
                AND @is_act_sms = 1
                THEN 1
            ELSE [isVisiable]
            END
        , [IsEmpty]
        , isnull(a.columnTooltip, a.[columnLabel]) AS columnTooltip
        , columnDisplay
        , isIgnore
    FROM dbo.[fn_config_form_gets](@tableKey, @acceptLanguage) a
    LEFT JOIN sys_config_form_log l
        ON a.id = l.id
            AND l.userId = @userId
            AND l.created_dt > dateadd(day, - 7, getdate())
    LEFT JOIN dbo.fn_parse_query_params(@queryParams) q ON q.[Key] = a.field_name
    WHERE (
            isVisiable = 1
            OR isRequire = 1
            )
    ORDER BY ordinal
END TRY

BEGIN CATCH
    DECLARE @ErrorNum INT
        , @ErrorMsg VARCHAR(200)
        , @ErrorProc VARCHAR(50)
        , @SessionID INT
        , @AddlInfo VARCHAR(max)

    SET @ErrorNum = error_number()
    SET @ErrorMsg = 'sp_common_filter ' + error_message()
    SET @ErrorProc = error_procedure()
    SET @AddlInfo = ' '

    EXEC utl_ErrorLog_Set @ErrorNum
        , @ErrorMsg
        , @ErrorProc
        , 'AttendanceRecord'
        , 'GET'
        , @SessionID
        , @AddlInfo
END CATCH