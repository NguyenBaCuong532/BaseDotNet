
CREATE PROCEDURE [dbo].[sp_res_apartment_import] @userId NVARCHAR(50) = NULL
    , @apartments apartment_import_type readonly
    , @accept BIT = 0
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
	CREATE TABLE #temp(
		[seq] [INT] NULL,
		[projectCd] [VARCHAR](450) NULL,
		[buildingCd] [NVARCHAR](450) NULL,
		[floorName] [VARCHAR](450) NULL,
		[roomCode] [NVARCHAR](450) NULL,
		[wallArea] [NVARCHAR](450) NULL,
		[waterwayArea] [NVARCHAR](450) NULL,
		[isReceived] [NVARCHAR](450) NULL,
		[receiveDt] [NVARCHAR](450) NULL,
		[isRent] [NVARCHAR](450) NULL,
		[feeStart] [NVARCHAR](450) NULL,
		[numFeeMonth] [NVARCHAR](450) NULL
		,errors nvarchar(max) default('')
	)
	INSERT INTO #temp
	(
	    seq,
	    projectCd,
	    buildingCd,
	    floorName,
	    roomCode,
	    wallArea,
	    waterwayArea,
	    isReceived,
	    receiveDt,
	    isRent,
	    feeStart,
	    numFeeMonth
	)
	SELECT seq,projectCd,buildingCd,floorName,roomCode,wallArea,waterwayArea,isReceived,receiveDt, isRent,feeStart,numFeeMonth
	FROM @apartments
	-- Check các trường bắt buộc, không được để trống
	UPDATE #temp
	SET errors = errors + N'; Mã dự án không được để trống' 
	WHERE ISNULL(projectCd,'') = ''
	UPDATE #temp
	SET errors = errors + N'; Mã tòa nhà không được để trống' 
	WHERE ISNULL(buildingCd,'') = ''
	UPDATE #temp
	SET errors = errors + N'; Tên tầng không được để trống' 
	WHERE ISNULL(floorName,'') = ''
	UPDATE #temp
	SET errors = errors + N'; Mã phòng không được để trống' 
	WHERE ISNULL(roomCode,'') = ''
	UPDATE #temp
	SET errors = errors + N'; Diện tích tim tường không được để trống' 
	WHERE ISNULL(wallArea,'') = ''
	UPDATE #temp
	SET errors = errors + N'; Diện tích thông thủy không được để trống' 
	WHERE ISNULL(waterwayArea,'') = ''

	
	-- Tồn tại ràng buộc giữa các cột: dự án - tòa nhà - tầng
	UPDATE #temp
	SET errors = errors + N'; Mã dự án không tồn tại!'
	FROM #temp a
	WHERE a.projectCd IS NOT NULL 
	AND NOT EXISTS (select 1 from dbo.MAS_Projects t where t.projectCd = a.projectCd)

	UPDATE #temp
	SET errors = errors + N'; Mã tòa nhà không tồn tại trong mã dự án'
	FROM #temp a
	WHERE a.buildingCd IS NOT NULL 
	AND a.buildingCd  NOT IN (SELECT t.BuildingCd from dbo.MAS_Buildings t where t.ProjectCd = a.projectCd)
	AND a.projectCd IS NOT NULL 
	AND EXISTS (select 1 from dbo.MAS_Projects t where t.projectCd = a.projectCd)

	UPDATE #temp
	SET errors = errors + N'; Tên tầng không tồn tại'
	FROM #temp a
	WHERE 
	a.floorName IS NOT NULL 
	AND a.floorName NOT IN  (select a.floorName FROM dbo.MAS_Elevator_Floor t WHERE t.ProjectCd = a.projectCd and t.BuildCd = a.buildingCd)
	AND a.buildingCd IS NOT NULL 
	AND EXISTS (select 1 from dbo.MAS_Buildings t where t.ProjectCd = a.projectCd)
	AND a.projectCd IS NOT NULL 
	AND EXISTS (select 1 from dbo.MAS_Projects t where t.projectCd = a.projectCd)


	UPDATE #temp
	SET errors = errors + N'; Tên căn hộ trong file import bị trùng'
	FROM #temp a JOIN (SELECT Count(*) AS dem,roomCode
				FROM #temp
				GROUP BY roomCode
				HAVING Count(*) > 1) as b ON a.roomCode = b.roomCode
	WHERE a.roomCode IS NOT NULL

	--UPDATE #temp
	--SET errors = errors + N'; Tên căn hộ trong file import bị trùng'
	--FROM #temp 
	--WHERE EXISTS(SELECT 1 FROM #temp a WHERE (SELECT COUNT(*) FROM #temp a2 WHERE a2.roomCode = a.roomCode) > 1)
	
	UPDATE #temp
	SET errors = errors + N'; Tên căn hộ đã tồn tại'
	FROM #temp a
	WHERE a.RoomCode IS NOT NULL 
	AND a.RoomCode in (select RoomCode FROM dbo.MAS_Apartments)

	UPDATE #temp
	SET errors = errors + N'; Diện tích tim tường không hợp lệ'
	FROM #temp a
	WHERE a.wallArea IS NOT NULL
	AND ISNUMERIC(wallArea) = 0

	UPDATE #temp
	SET errors = errors + N'; Diện tích thông thủy không hợp lệ'
	FROM #temp a
	WHERE a.waterwayArea IS NOT NULL
	AND ISNUMERIC(waterwayArea) = 0

	UPDATE #temp
	SET errors = errors + N'; Trạng thái bàn giao không hợp lệ'
	FROM #temp a
	WHERE [isReceived] IS NOT NULL
		and not [isReceived] in (N'0',N'1')

	UPDATE #temp
	SET errors = errors + N'; Trạng thái cho thuê không hợp lệ'
	FROM #temp a
	WHERE [isRent] IS NOT NULL
		and not [isRent] in (N'0',N'1')

	UPDATE #temp
	SET errors = errors + N'; Thời gian bàn giao không hợp lệ'
	FROM #temp a
	WHERE a.receiveDt IS NOT NULL
	AND dbo.fn_try_cast_excel_to_sql_date(a.receiveDt, 0) IS NULL

	UPDATE #temp
	SET errors = errors + N'; Thời gian bắt đầu tính phí dịch vụ không hợp lệ'
	FROM #temp a
	WHERE a.feeStart IS NOT NULL
	AND dbo.fn_try_cast_excel_to_sql_date(a.feeStart, 0) IS NULL

	UPDATE #temp
	SET errors = errors + N'; Số tháng miễn phí không hợp lệ'
	FROM #temp a
	WHERE a.numFeeMonth IS NOT NULL
	AND ISNUMERIC(numFeeMonth) = 0

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
            , 'apartment'
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
        -- Thêm mới căn hộ (MAS_Rooms đã được merge vào MAS_Apartments)
        INSERT INTO dbo.MAS_Apartments
        (
            RoomCode,
            IsReceived,
            ReceiveDt,
            IsRent,
            FeeStart,
            IsFree,
            numFreeMonth,
            projectCd,
            buildingCd,
            WaterwayArea,
			CurrBal,
			isLinkApp,
			buildingOid,
			floorOid,
			WallArea,
			floorNo
        )
		SELECT t.RoomCode,
				t.IsReceived,
				CONVERT(DATE,t.ReceiveDt,103),
				t.IsRent,
				CONVERT(DATETIME,t.feeStart,103),
				CASE WHEN t.numFeeMonth > 0 THEN 'true'
				ELSE 'false'
				end,
				CONVERT(INT,t.numFeeMonth),
				t.projectCd,
				t.buildingCd,
				CONVERT(FLOAT,t.waterwayArea),
				'0',
				'true',
				b.oid,
				ef.oid,
				CONVERT(FLOAT,t.wallArea),
				t.floorName
		FROM #temp t
		LEFT JOIN dbo.MAS_Buildings b ON t.buildingCd = b.BuildingCd AND t.projectCd = b.ProjectCd
		LEFT JOIN dbo.MAS_Elevator_Floor ef ON t.floorName = ef.FloorName AND t.projectCd = ef.ProjectCd AND t.buildingCd = ef.BuildCd
        WHERE t.errors = ''

        COMMIT TRAN
    END
	
END TRY

BEGIN CATCH
IF @@TRANCOUNT > 0 ROLLBACK
    DECLARE @ErrorNum INT
        , @ErrorMsg VARCHAR(200)
        , @ErrorProc VARCHAR(50)
        , @SessionID INT
        , @AddlInfo VARCHAR(MAX);

    SET @ErrorNum = ERROR_NUMBER();
    SET @ErrorMsg = 'sp_res_apartment_import' + ERROR_MESSAGE();
    SET @ErrorProc = ERROR_PROCEDURE();
    SET @AddlInfo = ' ';

    EXEC utl_errorlog_set @ErrorNum
        , @ErrorMsg
        , @ErrorProc
        , 'apartment'
        , 'GET'
        , @SessionID
        , @AddlInfo;
END CATCH;
	--SELECT * FROM #temp
	SET @recordsAccepted = (SELECT count(*) FROM #temp WHERE ISNULL(errors, '') = '' OR errors = ',')		
	--SELECT @recordsAccepted
	SELECT @valid as valid
		  ,@messages as messages
		  ,'view_apartment_import_page' as GridKey
		  ,recordsTotal = (select count(*) from #temp)
		  ,recordsFail = (select count(*) from #temp) - @recordsAccepted
		  ,recordsAccepted = case when @accept = 1 then @recordsAccepted else 0 end
		  ,accept = case when @recordsAccepted > 0 then 1 else 0 end

	SELECT * FROM dbo.fn_config_list_gets_lang('view_apartment_import_page', 500, @acceptLanguage)

	SELECT seq
	,projectCd
	,buildingCd,floorName,roomCode
	,wallArea,waterwayArea,isReceived,receiveDt,isRent,feeStart,numFeeMonth
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