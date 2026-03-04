


-- =============================================
-- Author: duongpx
-- Create date: 11/6/2025 11:31:31 AM
-- Description:	list pay type
-- Output:
-- =============================================
CREATE   procedure [dbo].[sp_app_point_type_list] 
	  @userId uniqueidentifier = NULL
    , @acceptLanguage NVARCHAR(50) = 'vi-VN'
AS
BEGIN TRY
	
    SELECT par_desc AS name
          ,key_2 AS value
		  ,icon_is = 1
		  ,icon = value1
		  ,intOrder 
    FROM sys_config_data
    WHERE key_1 = 'tran_type'
	union 
	SELECT N'Tất cả' AS name
          ,null AS value
		  ,icon_is = 0
		  ,icon = ''
		  ,intOrder = -1
	order by intOrder

END TRY

BEGIN CATCH
    DECLARE @ErrorNum INT
        , @ErrorMsg VARCHAR(200)
        , @ErrorProc VARCHAR(50)
        , @SessionID INT
        , @AddlInfo VARCHAR(MAX);

    SET @ErrorNum = ERROR_NUMBER();
    SET @ErrorMsg = ERROR_MESSAGE();
    SET @ErrorProc = ERROR_PROCEDURE();

    --SET @AddlInfo = NULL;
    EXEC utl_ErrorLog_Set @ErrorNum
        , @ErrorMsg
        , @ErrorProc
        , 'sp_app_point_type_list'
        , 'GET'
        , @SessionID
        , @AddlInfo;
END CATCH;