CREATE PROCEDURE [dbo].[sp_res_apartment_building_list]
    @UserId UNIQUEIDENTIFIER = NULL,
    @ProjectCd NVARCHAR(40),
	@isAll BIT = null,
	@acceptLanguage NVARCHAR(50) = N'vi-VN'
AS
BEGIN TRY
    -- Updated: thêm buildingOid (oid)
    SELECT b.BuildingName AS name,
           b.[BuildingCd] AS value,
           b.oid AS buildingOid
	INTO #items
    FROM MAS_Buildings b
    WHERE ProjectCd = @ProjectCd 
    ORDER BY BuildingCd;

	IF @isAll = 1
        INSERT INTO #items (name, value, buildingOid)
        VALUES (
            N'Tất cả',
			'all',
            NULL
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
    SET @ErrorMsg = 'sp_res_apartment_building_list' + ERROR_MESSAGE();
    SET @ErrorProc = ERROR_PROCEDURE();

    SET @AddlInfo = ' ';

    EXEC utl_Insert_ErrorLog @ErrorNum,
                             @ErrorMsg,
                             @ErrorProc,
                             'BuildFloor',
                             'GET',
                             @SessionID,
                             @AddlInfo;
END CATCH;