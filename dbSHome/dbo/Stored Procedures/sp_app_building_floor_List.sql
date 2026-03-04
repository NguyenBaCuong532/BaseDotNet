
-- =============================================
-- Author: ANHTT
-- Create date: 2025-09-05 12:38:38
-- Description:	list floor (Updated: dùng MAS_Apartments/MAS_Elevator_Floor thay MAS_Rooms)
-- Output:
-- =============================================
CREATE
    

 PROCEDURE [dbo].[sp_app_building_floor_List] 
	  @userId UNIQUEIDENTIFIER = NULL
    , @buildingCd NVARCHAR(50) = NULL       -- Backward compatible (BuildingCd)
    , @buildingOid UNIQUEIDENTIFIER = NULL   -- Ưu tiên (GUID)
    , @floorNo NVARCHAR(50) = NULL
    , @acceptLanguage NVARCHAR(50) = 'vi-VN'
AS
BEGIN TRY
    SELECT DISTINCT ISNULL(ef.FloorName, a.floorNo) AS name
        , ISNULL(ef.FloorName, a.floorNo) AS value
    FROM MAS_Apartments a
    LEFT JOIN MAS_Buildings b ON a.buildingOid = b.oid
    LEFT JOIN MAS_Elevator_Floor ef ON a.floorOid = ef.oid
    WHERE (@buildingOid IS NOT NULL AND a.buildingOid = @buildingOid
           OR (@buildingCd IS NOT NULL AND b.BuildingCd = @buildingCd))
      AND (a.floorNo IS NOT NULL OR ef.FloorName IS NOT NULL)
    ORDER BY value;
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

    EXEC utl_ErrorLog_Set @ErrorNum
        , @ErrorMsg
        , @ErrorProc
        , 'MAS_Apartments'
        , 'GET'
        , @SessionID
        , @AddlInfo;
END CATCH;
