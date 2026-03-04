-- Updated: Hỗ trợ BuildingCd/buildingOid và floorNo/floorOid (backward compatible)
CREATE PROCEDURE [dbo].[sp_res_apartment_room_list]
    @UserId UNIQUEIDENTIFIER,
    @BuildingCd NVARCHAR(40) = NULL,  -- Backward compatible
    @buildingOid UNIQUEIDENTIFIER = NULL, -- Ưu tiên (GUID)
    @floorNo NVARCHAR(20) = NULL,
    @floorOid UNIQUEIDENTIFIER = NULL -- Ưu tiên (GUID)
AS
BEGIN TRY
    SET @floorNo = ISNULL(@floorNo, '');
    --1 
    SELECT a.RoomCode AS name,
           a.RoomCode AS value
    FROM MAS_Apartments a
    LEFT JOIN MAS_Buildings b ON a.buildingOid = b.oid
    WHERE ((@buildingOid IS NOT NULL AND a.buildingOid = @buildingOid) OR (@BuildingCd IS NOT NULL AND b.BuildingCd LIKE @BuildingCd))
          AND
          (
              (@floorOid IS NOT NULL AND a.floorOid = @floorOid)
              OR (@floorNo = '' OR a.floorNo LIKE @floorNo + '%')
          )
    ORDER BY a.RoomCode;

END TRY
BEGIN CATCH
    DECLARE @ErrorNum INT,
            @ErrorMsg VARCHAR(200),
            @ErrorProc VARCHAR(50),
            @SessionID INT,
            @AddlInfo VARCHAR(MAX);

    SET @ErrorNum = ERROR_NUMBER();
    SET @ErrorMsg = 'sp_res_apartment_room_list ' + ERROR_MESSAGE();
    SET @ErrorProc = ERROR_PROCEDURE();

    SET @AddlInfo = ' ';

    EXEC utl_Insert_ErrorLog @ErrorNum,
                             @ErrorMsg,
                             @ErrorProc,
                             'Rooms',
                             'GET',
                             @SessionID,
                             @AddlInfo;
END CATCH;