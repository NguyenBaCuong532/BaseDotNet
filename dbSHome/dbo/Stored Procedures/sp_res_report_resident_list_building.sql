
-- =============================================
-- Author:		VuTc
-- Create date: 11/3/2025 9:48:13 AM
-- Description:	DS dự án, tòa nhà, căn hộ / Resident
-- =============================================
CREATE PROCEDURE [dbo].[sp_res_report_resident_list_building]
	@UserId				UNIQUEIDENTIFIER = NULL
	,@ClientId			NVARCHAR(150)	= NULL
	,@filter			NVARCHAR(150) = NULL
	,@gridWidth			INT = 0
	,@offset			INT = 0
	,@pageSize			INT = 20000
	,@FromDate			NVARCHAR(50) 	= '01/10/2025'		-- NULL,
	,@ToDate		    NVARCHAR(50)	= '30/11/2025'		-- NULL,
	,@ProjectCd			NVARCHAR(30)	= NULL				-- '01,02,03' NULL
	,@BuildingCd		NVARCHAR(MAX)	= NULL				-- 'Sunshine Center',
	,@RoomCode			NVARCHAR(MAX)	= NULL				--	'G3-2912,G1-01.01A,G1-1511'			--NULL	
	,@total				INT				= 0 OUT
    ,@gridKey			NVARCHAR(100)	= '' OUT
    ,@TotalFiltered		INT = NULL OUT
	,@AcceptLanguage	VARCHAR(20)	= 'vi-VN'
AS
BEGIN
	SET NOCOUNT ON;

	DECLARE @messages NVARCHAR(MAX)
	DECLARE @FromDate2			DATETIME 	= CONVERT(DATETIME,@FromDate,103) 
			,@ToDate2		    DATETIME  	= CONVERT(DATETIME,@ToDate,103)

	IF(@BuildingCd	= '' OR @BuildingCd	IS NULL)	SET @BuildingCd	= NULL
	IF(@RoomCode	= '' OR @RoomCode		IS NULL)	SET @RoomCode		= NULL
	IF(@ProjectCd	= '' OR @ProjectCd		IS NULL)	SET @ProjectCd		= NULL

	BEGIN TRY	

	IF @Offset IS NULL
        SET @Offset = 0;
    IF @PageSize IS NULL
        SET @PageSize = 10;
    SET @GridKey = 'view_apartment_project_building_room';
    SET @Offset = ISNULL(@Offset, 0);
    SET @PageSize = ISNULL(@PageSize, 10);
    SET @Total = ISNULL(@Total, 0);
    SET @filter = RTRIM(LTRIM(ISNULL(@filter, '')));
    IF @PageSize = 0
        SET @PageSize = 1000;
    IF @Offset < 0
        SET @Offset = 0;

	IF @Offset = 0
    BEGIN
        SELECT *
        FROM dbo.fn_config_list_gets_lang(@GridKey, @gridWidth, @AcceptLanguage);
    END;


	CREATE TABLE #MAS_ProjectCd (ProjectCd NVARCHAR(50))
		IF(ISNULL(@ProjectCd, '0') <> '0')
			BEGIN
			INSERT INTO #MAS_ProjectCd(ProjectCd)
			SELECT CAST(data AS NVARCHAR(50)) ProjectCd
			FROM dbo.fn_TKM_ALL_1000_Split(@ProjectCd, ',')	
			END
		ELSE
			SET @ProjectCd = NULL
		CREATE INDEX MAS_ProjectCd ON #MAS_ProjectCd(ProjectCd)
		--SELECT * FROM #MAS_ProjectCd

		SELECT ApartmentId
				,ProjectCd = a.projectCd
				,b.ProjectName
				,b.BuildingName
				,RoomCode
				,BuildingCd = a.buildingCd
				,Sub_projectCd = sub_projectCd
			INTO #Temp
			FROM MAS_Apartments a
			LEFT JOIN MAS_Buildings b ON a.buildingOid = b.oid 
			WHERE	(@ProjectCd IS NULL  OR a.ProjectCd   IN (SELECT ProjectCd  FROM #MAS_ProjectCd))
			/* AND		(@BuildingCd IS NULL OR b.BuildingCd  IN (SELECT BuildingCd FROM #Buildings))
			AND		(@RoomCode IS NULL   OR a.RoomCode	  IN (SELECT RoomCode   FROM #MAS_Rooms)) */
			ORDER BY a.projectCd, b.BuildingCd, a.RoomCode ASC
	
	SELECT @Total = COUNT(*) FROM #Temp
	SELECT * FROM #Temp

	END TRY


	BEGIN CATCH
	DECLARE	@ErrorNum				INT,
			@ErrorMsg				VARCHAR(200),
			@ErrorProc				VARCHAR(50),

			@SessionID				INT,
			@AddlInfo				VARCHAR(max)

	SET		@ErrorNum				= error_number()
	SET		@ErrorMsg				= 'sp_res_report_resident_list_building' + error_message()
	SET		@ErrorProc				= error_procedure()
	SET		@AddlInfo				= ' '

	EXEC utl_errorLog_set @ErrorNum, @ErrorMsg, @ErrorProc, 'sp_res_report_resident_list_building', 'GET', @SessionID, @AddlInfo
	END CATCH
END;

/*
		CREATE TABLE #Buildings(BuildingCd NVARCHAR(50))
		IF(ISNULL(@BuildingCd, '0') <> '0')
		BEGIN
			INSERT INTO #Buildings(BuildingCd)
			SELECT CAST(data AS NVARCHAR(50)) BuildingCd		
			FROM dbo.fn_TKM_ALL_1000_Split(@BuildingCd, ',')
		END
		ELSE
		BEGIN
			SET @BuildingCd = NULL
		END
		CREATE INDEX IX_Buildings ON #Buildings(BuildingCd)
		SELECT * FROM #Buildings

		CREATE TABLE #MAS_Rooms (RoomCode NVARCHAR(50))
		IF(ISNULL(@RoomCode, '0') <> '0')
			BEGIN
			INSERT INTO #MAS_Rooms(RoomCode)
			SELECT CAST(data AS NVARCHAR(50)) RoomCode
			FROM dbo.fn_TKM_ALL_1000_Split(@RoomCode, ',')	
			END
		ELSE
			SET @RoomCode = NULL
		CREATE INDEX MAS_Rooms ON #MAS_Rooms(RoomCode)
	
	--SELECT  * FROM #MAS_Rooms
*/