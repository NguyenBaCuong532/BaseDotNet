
CREATE PROCEDURE [dbo].[sp_spk_project_list]
    @userId NVARCHAR(450),
	@isAll BIT = NULL
AS
BEGIN TRY
	DECLARE @temp NVARCHAR(500)
    -- Data
    SELECT DISTINCT sub_projectCd AS value
		  ,projectName AS name
		  ,projectCd
		  ,projectName
		  INTO #items
	FROM dbo.MAS_Projects p
	where exists(select 1 from UserProject x 
		where x.projectCd = p.projectCd 
			and x.userId = @userId)
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
    SET @ErrorMsg = 'sp_res_project_list1' + ERROR_MESSAGE();
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