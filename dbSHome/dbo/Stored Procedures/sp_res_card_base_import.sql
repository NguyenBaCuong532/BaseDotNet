CREATE PROCEDURE [dbo].[sp_res_card_base_import] @userId NVARCHAR(50) = NULL
    , @cards card_import_type readonly
    , @accept BIT = NULL
    , @project_code NVARCHAR(50) = NULL
    , @impId UNIQUEIDENTIFIER = NULL
    , @fileName NVARCHAR(250) = NULL
    , @fileType NVARCHAR(50) = NULL
    , @fileSize INT = NULL
    , @fileUrl NVARCHAR(4000) = NULL
    , @acceptLanguage NVARCHAR(50) = N'vi-VN'
AS
BEGIN TRY
    SET NOCOUNT ON;
    DECLARE @valid BIT = 1
    DECLARE @messages NVARCHAR(MAX)
    DECLARE @recordsAccepted bigint
    DECLARE @recordIdBefore uniqueidentifier
    
    if OBJECT_ID('tempdb..#temp') is not null
        drop table #temp

    SELECT
        *,
        CASE WHEN ISNULL(code,'') = '' THEN N'; Mã thẻ không được để trống' 
           WHEN ISNULL(serial,'') = '' THEN N'; Số thẻ không được để trống' 
           WHEN ISNULL(projectName,'') = '' THEN N'; Dự án không được để trống' 
        ELSE '' END errors
    INTO #temp
    FROM @cards
    
    -- Check trùng số thẻ và mã thẻ
    UPDATE #temp
    SET errors = errors + N'; Số thẻ đã dùng'
    FROM #temp a
    WHERE
        a.serial IS NOT NULL 
        AND exists (select 1 from dbo.MAS_CardBase t where t.Card_Num = a.serial)

    UPDATE #temp
    SET errors = errors + N'; Mã thẻ đã dùng'
    FROM #temp a
    WHERE a.code IS NOT NULL 
    AND exists (select 1 from dbo.MAS_CardBase t where t.Code = a.code)

    IF(@impId IS NULL  OR  NOT EXISTS (SELECT 1 FROM ImportFiles WHERE impId = @impId) AND @fileName IS NOT NULL)
    BEGIN
        SET @impId = NEWID()
        INSERT INTO ImportFiles (
                [impId]
                , [import_type]
                , [upload_file_name]
                , [upload_file_type]
                , [upload_file_url]
                , [upload_file_size]
                , [created_by]
                , [created_dt]
                , [row_count])
          VALUES (
                @impId
                , 'cardBase'
                , @fileName
                , @fileType
                , @fileUrl
                , @fileSize
                , @userId
                , GETDATE()
                , (SELECT COUNT(*) FROM #temp))
    END

    IF @accept = 1
    BEGIN
    BEGIN TRAN
        UPDATE [dbo].[ImportFiles]
        SET [row_new] = 0
            ,[row_update] = (select count(*) from #temp where errors = '')
            ,[row_fail] = (select count(*) from #temp where errors != '')
            ,[updated_st] = 1
            ,[updated_by] = @UserId
            ,[updated_dt] = getdate()
        WHERE impId = @impId
            
        -- Cập nhật nếu đã tồn tại
        UPDATE a
        SET Card_Num = b.serial
            , Card_Hex = b.hex
            ,a.ProjectCode = p.projectCd
            ,LotNumber = LTRIM(RTRIM(b.lotNumber))
            --, IsUsed = b.usedStatus
            , SysDate = GETDATE()
        FROM
            MAS_CardBase a
            INNER JOIN #temp b ON a.Code = b.code
            LEFT JOIN dbo.MAS_Projects p ON p.projectName = b.ProjectName
        WHERE b.errors = ''

        -- Thêm mới đối với các mã thẻ mới
        INSERT INTO MAS_CardBase (
            [Guid_Cd]
            , [Card_Num]
            , [Card_Hex]
            , [Code]
            , [IsUsed]
            ,ProjectCode
            ,LotNumber
            ,SysDate)
        SELECT NEWID()
            , [serial]
            , hex
            , code
            , 0
            ,p.projectCd
            ,LTRIM(RTRIM(lotNumber))
            ,GETDATE()
        FROM
            #temp t
            OUTER APPLY(SELECT TOP 1 * FROM MAS_Projects p WHERE p.projectName = t.ProjectName) p
--             LEFT JOIN dbo.MAS_Projects p ON p.projectName = t.ProjectName
        WHERE
            t.errors = ''
            AND NOT EXISTS (SELECT 1 FROM MAS_CardBase sa WHERE sa.Code = t.code)
        
        COMMIT
    END
	SET @recordsAccepted = (SELECT count(*) FROM #temp WHERE ISNULL(errors, '') = '' OR errors = ',')
  
END TRY
BEGIN CATCH
    DECLARE @ErrorNum INT, @ErrorMsg VARCHAR(200), @ErrorProc VARCHAR(50), @SessionID INT, @AddlInfo VARCHAR(MAX);

    SET @ErrorNum = ERROR_NUMBER();
    SET @ErrorMsg = 'sp_res_cardBase_import' + ERROR_MESSAGE();
    SET @ErrorProc = ERROR_PROCEDURE();
    SET @AddlInfo = ' ';
    
--     SELECT @ErrorMsg

    EXEC utl_errorlog_set @ErrorNum, @ErrorMsg, @ErrorProc, 'sp_res_cardBase_import', 'GET', @SessionID, @AddlInfo;
END CATCH;


SELECT @valid as valid
		  ,@messages as messages
		  ,'view_cardBase_import_page' as GridKey
		  ,recordsTotal = (select count(*) from #temp)
		  ,recordsFail = (select count(*) from #temp) - @recordsAccepted
		  ,recordsAccepted = case when @accept = 1 then @recordsAccepted else 0 end
		  ,accept = case when @recordsAccepted > 0 then 1 else 0 end
		  ,@recordsAccepted
		  , count(a.code) 
FROM #temp a
WHERE ISNULL(errors, '') = '' OR errors = ','

SELECT * FROM dbo.fn_config_list_gets_lang('view_cardBase_import_page', 500, @acceptLanguage)

SELECT
    seq,serial
    ,code,hex,t.projectName,lotNumber
    --,p.projectCd
		,CASE 
			WHEN errors = ''
				THEN
					case when @valid = 1 and @accept = 1 then N'<span class="' + 'bg-success' + ' noti-number ml5">' + 'Done' + '</span>'
						when @valid = 0 and @accept = 1 then N'<span class="' + 'bg-warning' + ' noti-number ml5">' + 'Error' + '</span>'
						else N'<span class="' + 'bg-success' + ' noti-number ml5">' + 'OK' + '</span>' end
				ELSE N'<span class="' + 'bg-danger' + ' noti-number ml5">' + STUFF(errors, 1, 2, '') + '</span>'  
			END errors
FROM #temp t
LEFT JOIN dbo.MAS_Projects p ON p.projectName = t.ProjectName

select
    impId = @impId,
    fileName = @fileName,
    fileType = @fileType,
    fileSize = @fileSize,
    fileUrl = @fileUrl

select * from #temp