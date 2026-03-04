
CREATE PROCEDURE [dbo].[sp_res_card_vehicle_import] 
		@userId NVARCHAR(50) = NULL
    , @cards vehicle_card_import_type readonly
    , @accept BIT = NULL
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

    SELECT *, 
		CASE WHEN ISNULL(code,'') = '' THEN N', Mã thẻ không được để trống' ELSE '' END errors
    INTO #temp
    FROM @cards
	-- Check trùng mã thẻ
	UPDATE #temp
	SET errors = errors + N'Mã thẻ không tồn tại'
	FROM #temp a
	WHERE a.code IS NOT NULL 
	AND NOT EXISTS (select 1 from dbo.MAS_CardBase t where t.Code = a.code)

    IF @impId IS NULL  OR  NOT EXISTS (
            SELECT 1
            FROM ImportFiles
            WHERE impId = @impId
            )
        AND @fileName IS NOT NULL
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
			,[created_dt]
            , [row_count]
            
            )
        VALUES (
            @impId
            , 'vehicle_cardBase'
            , @fileName
            , @fileType
            , @fileUrl
            , @fileSize
            , @userId
			,GETDATE()
			,(SELECT COUNT(*) FROM #temp)
            )
    END

    --
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
        -- Chuyển thẻ đã có và chưa sử dụng sang thẻ lượt
        UPDATE a
        SET  IsUsed = 1
			,a.Type = 3 -- loại thẻ: thẻ gửi xe
            , SysDate = GETDATE()
        FROM MAS_CardBase a
        INNER JOIN #temp b
            ON a.Code = b.code
        WHERE b.errors IS NULL OR b.errors = ''

		COMMIT
		SET @recordsAccepted = (SELECT count(*) FROM #temp WHERE ISNULL(errors, '') = '' OR errors = ',')
    END
	SET @recordsAccepted = (SELECT count(*) FROM #temp WHERE ISNULL(errors, '') = '' OR errors = ',')	
END TRY

BEGIN CATCH
    DECLARE @ErrorNum INT
        , @ErrorMsg VARCHAR(200)
        , @ErrorProc VARCHAR(50)
        , @SessionID INT
        , @AddlInfo VARCHAR(MAX);

    SET @ErrorNum = ERROR_NUMBER();
    SET @ErrorMsg = 'sp_res_vehicle_cardBase_import' + ERROR_MESSAGE();
    SET @ErrorProc = ERROR_PROCEDURE();
    SET @AddlInfo = ' ';

    EXEC utl_errorlog_set @ErrorNum
        , @ErrorMsg
        , @ErrorProc
        , 'vehicle_cardBase'
        , 'GET'
        , @SessionID
        , @AddlInfo;
END CATCH;
SELECT @valid as valid
		  ,@messages as messages
		  ,'view_vehicle_cardBase_import_page' as GridKey
		  ,recordsTotal = (select count(*) from #temp)
		  ,recordsFail = (select count(*) from #temp) - @recordsAccepted
		  ,recordsAccepted = case when @accept = 1 then @recordsAccepted else 0 end
		  ,accept = case when @recordsAccepted > 0 then 1 else 0 end
		  ,@recordsAccepted
		  , count(a.code) 
		  FROM #temp a WHERE ISNULL(errors, '') = '' OR errors = ','

	SELECT * FROM dbo.fn_config_list_gets_lang('view_vehicle_cardBase_import_page', 500, @acceptLanguage)

	SELECT seq,code
		,CASE 
			WHEN errors = ''
				THEN
					case when @valid = 1 and @accept = 1 then N'<span class="' + 'bg-success' + ' noti-number ml5">' + 'Done' + '</span>'
						when @valid = 0 and @accept = 1 then N'<span class="' + 'bg-warning' + ' noti-number ml5">' + 'Error' + '</span>'
						else N'<span class="' + 'bg-success' + ' noti-number ml5">' + 'OK' + '</span>' end
				ELSE N'<span class="' + 'bg-danger' + ' noti-number ml5">' + STUFF(errors, 1, 2, '') + '</span>'  
			END errors
	FROM #temp t

	select impId = @impId, fileName = @fileName, fileType = @fileType, fileSize = @fileSize, fileUrl = @fileUrl 

	select * from #temp