CREATE PROCEDURE [dbo].[sp_res_project_list]
    @userId NVARCHAR(450),
	@isAll BIT = NULL
AS
BEGIN TRY
	--DECLARE @temp NVARCHAR(500)
	--SET @temp =(SELECT TOP(1) categoryIds FROM dbo.UserConfig WHERE userId = @userId)
    -- Data
    SELECT DISTINCT projectCd AS value
		  ,projectName AS name
		  ,projectCd
		  ,projectName
		  INTO #items
	FROM dbo.MAS_Projects
	--WHERE LOWER(CAST(projectCd AS NVARCHAR(50))) IN (SELECT value as ConvertedList
	--						FROM dbo.fn_SplitString(@temp, ','))
	ORDER BY projectCd

	IF @isAll = 1
        INSERT INTO #items
        VALUES (
			'-1',
			N'Tất cả',
			'',''
            )
		SELECT * FROM #items
END TRY
BEGIN CATCH
    DECLARE @ErrorNum INT,
            @ErrorMsg VARCHAR(200),
            @ErrorProc VARCHAR(50),
            @SessionID INT,
            @AddlInfo VARCHAR(MAX);

    SET @ErrorNum = ERROR_NUMBER();
    SET @ErrorMsg = 'sp_res_project_list' + ERROR_MESSAGE();
    SET @ErrorProc = ERROR_PROCEDURE();
    SET @AddlInfo = '';

    EXEC utl_ErrorLog_Set @ErrorNum,
                          @ErrorMsg,
                          @ErrorProc,
                          'Project',
                          'GET',
                          @SessionID,
                          @AddlInfo;
END CATCH;