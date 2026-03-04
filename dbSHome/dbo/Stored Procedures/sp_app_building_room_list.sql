
-- =============================================
-- Author: ANHTT
-- Create date: 2025-09-05 12:38:38
-- Description:	list room (Updated: dùng MAS_Apartments thay MAS_Rooms)
-- Output:
-- =============================================
CREATE
    

 PROCEDURE [dbo].[sp_app_building_room_list] 
	  @userId UNIQUEIDENTIFIER = NULL
    , @buildingCd NVARCHAR(50) = NULL   -- Backward compatible
    , @buildingOid UNIQUEIDENTIFIER = NULL -- Ưu tiên (GUID)
    , @floorNo NVARCHAR(50) = NULL
    , @floorOid UNIQUEIDENTIFIER = NULL  -- Ưu tiên (GUID)
    , @acceptLanguage NVARCHAR(50) = 'vi-VN'
AS
BEGIN TRY
    SELECT a.[RoomCode] AS name
        , a.[RoomCode] AS value
    FROM MAS_Apartments a
    LEFT JOIN MAS_Buildings b ON a.buildingOid = b.oid
    WHERE (@buildingOid IS NOT NULL AND a.buildingOid = @buildingOid
           OR (@buildingCd IS NOT NULL AND b.BuildingCd = @buildingCd))
      AND (@floorOid IS NOT NULL AND a.floorOid = @floorOid
           OR @floorNo IS NULL OR a.floorNo = @floorNo)
    ORDER BY a.RoomCode;
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
