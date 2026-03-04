-- Updated: Hỗ trợ ApartmentId và Oid (backward compatible)
CREATE PROCEDURE [dbo].[sp_res_apartment_list]
    @UserId UNIQUEIDENTIFIER = NULL,
    @AcceptLanguage VARCHAR(20) = 'vi-VN',
    @ProjectCd NVARCHAR(40),
    @BuildingCd NVARCHAR(30) = NULL,
    @floorNo NVARCHAR(30) = NULL,
    @ApartmentId INT = NULL,  -- Backward compatible
    @Oid UNIQUEIDENTIFIER = NULL, -- Ưu tiên sử dụng (GUID)
    @filter NVARCHAR(30) = NULL
AS
BEGIN TRY

    SELECT
        a.ApartmentId AS value,
        a.oid AS apartOid,
        a.[RoomCode] AS name
    FROM
        [MAS_Apartments] a
        LEFT JOIN MAS_Buildings b ON a.buildingOid = b.oid
    WHERE
        b.ProjectCd LIKE @ProjectCd + '%'
        AND (ISNULL(@BuildingCd, '') = '' OR b.BuildingCd LIKE N'%'+ @BuildingCd +'%')
        AND (ISNULL(@floorNo, '') = '' OR a.floorNo LIKE N'%'+ @floorNo +'%')
        AND (
            ((@ApartmentId IS NULL AND @Oid IS NULL) AND ((ISNULL(@filter, '') = '') OR a.RoomCode LIKE N'%'+ @filter +'%'))
            OR ((@ApartmentId IS NOT NULL AND a.ApartmentId = @ApartmentId) OR (@Oid IS NOT NULL AND a.oid = @Oid))
        )
    ORDER BY a.[RoomCode];

END TRY
BEGIN CATCH
    DECLARE @ErrorNum INT,
            @ErrorMsg VARCHAR(200),
            @ErrorProc VARCHAR(50),
            @SessionID INT,
            @AddlInfo VARCHAR(MAX);

    SET @ErrorNum = ERROR_NUMBER();
    SET @ErrorMsg = 'sp_res_apartment_list' + ERROR_MESSAGE();
    SET @ErrorProc = ERROR_PROCEDURE();

    SET @AddlInfo = ' ';

    EXEC utl_Insert_ErrorLog @ErrorNum,
                             @ErrorMsg,
                             @ErrorProc,
                             'Apartments',
                             'GET',
                             @SessionID,
                             @AddlInfo;
END CATCH;