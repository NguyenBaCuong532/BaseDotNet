
-- =============================================
-- Author:		VuTc
-- Create date: 10/15/2025
-- Description:	List tên tòa nhà
-- =============================================
CREATE PROCEDURE [dbo].[sp_res_report_building_name_list]
	@UserId				UNIQUEIDENTIFIER = NULL
	,@FromDate			NVARCHAR(50) 	= '01/01/2021'		--NULL,
	,@ToDate		    NVARCHAR(50)	= '31/01/2022'	--NULL,
	,@AcceptLanguage	VARCHAR(20)	= 'vi-VN'
	

AS 
BEGIN

	SET NOCOUNT ON;

	DECLARE @messages NVARCHAR(MAX)
	DECLARE @GridKey NVARCHAR(250)

/*	DECLARE @FromDate2			DATETIME 	= CONVERT(DATETIME,@FromDate,103) 
			,@ToDate2		    DATETIME  	= CONVERT(DATETIME,@ToDate,103) */

	BEGIN TRY	
		CREATE TABLE #Buildings([value] NVARCHAR(50), [name] NVARCHAR(50), BuildingCd NVARCHAR(50), ProjectName NVARCHAR(150))
			INSERT INTO #Buildings(value, name, BuildingCd, ProjectName)
			SELECT TRY_CONVERT(NVARCHAR,Id) , BuildingName, BuildingCd , ProjectName 
			FROM MAS_Buildings

		CREATE INDEX IX_Buildings ON #Buildings(value, name)
		SELECT * FROM #Buildings

		
	
	END TRY


	BEGIN CATCH
	DECLARE	@ErrorNum				INT,
			@ErrorMsg				VARCHAR(200),
			@ErrorProc				VARCHAR(50),

			@SessionID				INT,
			@AddlInfo				VARCHAR(max)

	SET		@ErrorNum				= error_number()
	SET		@ErrorMsg				= 'sp_res_report_building_name_list' + error_message()
	SET		@ErrorProc				= error_procedure()

	SET		@AddlInfo				= ' '

	EXEC utl_errorLog_set @ErrorNum, @ErrorMsg, @ErrorProc, 'sp_res_report_building_name_list', 'GET', @SessionID, @AddlInfo
	END CATCH
END