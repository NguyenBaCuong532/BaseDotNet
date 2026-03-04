
-- =============================================
-- Author:		VuTc
-- Create date: 10/15/2025
-- Description:	List Số phòng / Số căn hộ
-- =============================================
CREATE PROCEDURE [dbo].[sp_res_report_room_code_list]
	@UserId				UNIQUEIDENTIFIER = NULL
	,@FromDate			NVARCHAR(50) 	= '01/01/2021'		--NULL,
	,@ToDate		    NVARCHAR(50)	= '31/01/2022'	--NULL,
	,@AcceptLanguage	VARCHAR(20)	= 'vi-VN'
	,@RoomCode			NVARCHAR(100)	= NULL

AS 
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	--SELECT Oid, EmployeeID, FullName FROM dbo.EmployeeMaintenance WHERE EmployeeID = 'S 01119'
	SET NOCOUNT ON;

	DECLARE @messages NVARCHAR(MAX)
	DECLARE @GridKey NVARCHAR(250)
/*	DECLARE @FromDate2			DATETIME 	= CONVERT(DATETIME,@FromDate,103) 
			,@ToDate2		    DATETIME  	= CONVERT(DATETIME,@ToDate,103) */

	BEGIN TRY	
				SELECT a.RoomCode [value], b.BuildingCd [name]
				FROM MAS_Apartments a
				LEFT JOIN MAS_Buildings b ON a.buildingOid = b.oid
				ORDER BY a.RoomCode, b.BuildingCd	
	END TRY


	BEGIN CATCH
	DECLARE	@ErrorNum				INT,
			@ErrorMsg				VARCHAR(200),
			@ErrorProc				VARCHAR(50),

			@SessionID				INT,
			@AddlInfo				VARCHAR(max)

	SET		@ErrorNum				= error_number()
	SET		@ErrorMsg				= 'sp_res_report_room_code_list' + error_message()
	SET		@ErrorProc				= error_procedure()

	SET		@AddlInfo				= ' '

	EXEC utl_errorLog_set @ErrorNum, @ErrorMsg, @ErrorProc, 'sp_res_report_room_code_list', 'GET', @SessionID, @AddlInfo
	END CATCH
END