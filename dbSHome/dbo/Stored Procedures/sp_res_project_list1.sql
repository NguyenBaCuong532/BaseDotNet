CREATE PROCEDURE [dbo].[sp_res_project_list1]
    @userId NVARCHAR(450)= 'ea596efb-5eb1-4648-a219-089d2a4d310c'	--NULL,
	,@isAll BIT = 1
AS
BEGIN TRY
    SELECT DISTINCT 
      p.projectCd AS value,
      p.projectName AS name,
      p.projectCd,
      p.projectName
		INTO #items
		FROM dbo.MAS_Projects p
		WHERE EXISTS (SELECT 1 FROM UserProject x WHERE x.projectCd = p.projectCd AND x.userId = @userId)
	ORDER BY p.projectCd

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