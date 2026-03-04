
CREATE PROCEDURE [dbo].[sp_res_notify_send_import_set] 
	@userId NVARCHAR(50) = NULL
    , @rooms room_notify_push_import_type readonly
    , @accept BIT = NULL
    , @projectCd NVARCHAR(150) = NULL
    , @buildingCd NVARCHAR(150) = NULL
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
	-- Check trống ô input
    SELECT *, 
		CASE WHEN ISNULL(roomCode,'') = '' THEN N', Mã thẻ không được để trống' ELSE '' END errors
    INTO #temp
    FROM @rooms
	-- Check trùng mã phòng với file truyền vào
	UPDATE #temp
	SET errors = errors + N'Mã phòng trùng nhau'
	FROM #temp a
	WHERE a.roomCode IS NOT NULL 
	AND EXISTS (SELECT roomCode, COUNT(*)
				FROM #temp
				GROUP BY roomCode
				HAVING COUNT(*) > 1
				)
	-- Check các phòng nằm ngoài dự án, tòa nhà import ban đầu
	UPDATE #temp
	SET errors = errors + N'Mã phòng không tồn tại trong dự án, tòa nhà'
	FROM #temp a
	WHERE a.roomCode IS NOT NULL 
	AND a.roomCode NOT IN (
			SELECT a1.roomCode FROM [MAS_Apartments] a1 
			LEFT JOIN MAS_Buildings b On a1.buildingOid = b.oid 
		    WHERE a1.projectCd = @ProjectCd
				AND (@buildingCd = 'all' or b.BuildingCd = @buildingCd)
				)
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
            ,[import_type]
            ,[upload_file_name]
            ,[upload_file_type]
            ,[upload_file_url]
            ,[upload_file_size]
			,[created_by]
			,[created_dt]
            ,[row_count]
            )
        VALUES (
            @impId
            ,'room_notify_push'
            ,@fileName
            ,@fileType
            ,@fileUrl
            ,@fileSize
            ,@userId
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

        COMMIT
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
    SET @ErrorMsg = 'sp_res_roomNotifySend_import' + ERROR_MESSAGE();
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
		  ,'view_roomNotifySend_import_page' as GridKey
		  ,recordsTotal = (select count(*) from #temp)
		  ,recordsFail = (select count(*) from #temp) - @recordsAccepted
		  ,recordsAccepted = case when @accept = 1 then @recordsAccepted else 0 end
		  ,accept = case when @recordsAccepted > 0 then 1 else 0 end

	SELECT * FROM dbo.fn_config_list_gets_lang('view_roomNotifySend_import_page', 500, @acceptLanguage)

	SELECT seq,roomCode
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
	-- Select ra ds các căn hộ muốn gửi thông báo
	--SELECT RoomCode FROM #temp
	SELECT ProjectName
			,b.ProjectCd
			,a.[ApartmentId]
			,BuildingName
			,a.[RoomCode]
			,c.FullName
			,c.AvatarUrl
			,ef.FloorNumber as [Floor]
			,a.WaterwayArea
			,a.[UserLogin]
			,a.[Cif_No] 
			,c.CustId
			,b.[BuildingCd]
			,c.Phone
			,c.Email
			,a.IsReceived
			,convert(nvarchar(10),a.ReceiveDt,103) as ReceiveDate
			,a.IsRent 
			,a.isMain
	  FROM [MAS_Apartments] a 
			LEFT JOIN MAS_Buildings b On a.buildingOid = b.oid 
			LEFT JOIN MAS_Elevator_Floor ef ON a.floorOid = ef.oid
			join UserInfo u on a.UserLogin = u.loginName
			JOIN MAS_Customers c ON u.CustId = c.CustId
	  WHERE a.projectCd = @ProjectCd
		and (@buildingCd = 'all' or b.BuildingCd = @buildingCd)
		and a.RoomCode IN(SELECT b.RoomCode FROM #temp b WHERE  b.errors IS NULL OR b.errors = '')