-- Updated: Hỗ trợ buildingCd và buildingOid (backward compatible)
CREATE PROCEDURE [dbo].[sp_res_apartment_floor_list]
    @UserId UNIQUEIDENTIFIER = NULL,
    @buildingCd NVARCHAR(40) = NULL,  -- Backward compatible
    @buildingOid UNIQUEIDENTIFIER = NULL, -- Ưu tiên sử dụng (GUID)
    @areaCd NVARCHAR(40) = NULL
AS
BEGIN TRY

    SET @buildingCd = ISNULL(@buildingCd, '');
    IF @buildingOid IS NOT NULL AND @buildingCd = ''
        SELECT @buildingCd = BuildingCd FROM MAS_Buildings WHERE oid = @buildingOid;

    --1 
    SELECT distinct
        a.floorNo as name
			  ,a.floorNo as value
    INTO #MAS_Rooms
		FROM [dbSHome].[dbo].[MAS_Apartments] a
		LEFT JOIN MAS_Buildings b ON a.buildingOid = b.oid
		WHERE ((@buildingOid IS NOT NULL AND a.buildingOid = @buildingOid) OR (@buildingCd <> '' AND b.BuildingCd LIKE '%'+ @buildingCd +'%'))
		  AND a.floorNo IS NOT NULL
		ORDER BY a.floorNo
    
    IF(NOT EXISTS(SELECT TOP 1 1 FROM #MAS_Rooms WHERE [value] = '21'))
        INSERT INTO #MAS_Rooms(name, value)
        VALUES('21', '21')
        
    IF(NOT EXISTS(SELECT TOP 1 1 FROM #MAS_Rooms WHERE [value] = '22'))
        INSERT INTO #MAS_Rooms(name, value)
        VALUES('22', '22')

    IF (@buildingCd = 'B-18')
    BEGIN
         IF(NOT EXISTS(SELECT TOP 1 1 FROM #MAS_Rooms WHERE [value] = '28'))
            INSERT INTO #MAS_Rooms(name, value)
            VALUES('28', '28')

         IF(NOT EXISTS(SELECT TOP 1 1 FROM #MAS_Rooms WHERE [value] = '29'))
            INSERT INTO #MAS_Rooms(name, value)
            VALUES('29', '29')

 
         IF(NOT EXISTS(SELECT TOP 1 1 FROM #MAS_Rooms WHERE [value] = '32'))
            INSERT INTO #MAS_Rooms(name, value)
            VALUES('32', '32')

        IF(NOT EXISTS(SELECT TOP 1 1 FROM #MAS_Rooms WHERE [value] = '33'))
            INSERT INTO #MAS_Rooms(name, value)
            VALUES('33', '33')


        IF(NOT EXISTS(SELECT TOP 1 1 FROM #MAS_Rooms WHERE [value] = '35'))
        INSERT INTO #MAS_Rooms(name, value)
        VALUES('35', '35')

    END

    IF (@buildingCd in ('C-18', 'B-18'))
    BEGIN
        IF(NOT EXISTS(SELECT TOP 1 1 FROM #MAS_Rooms WHERE [value] = '30'))
        INSERT INTO #MAS_Rooms(name, value)
        VALUES('30', '30')
        
        IF(NOT EXISTS(SELECT TOP 1 1 FROM #MAS_Rooms WHERE [value] = '34'))
        INSERT INTO #MAS_Rooms(name, value)
        VALUES('34', '34')
    END
    
    IF(@buildingCd = 'C-18')
    BEGIN
        IF(NOT EXISTS(SELECT TOP 1 1 FROM #MAS_Rooms WHERE [value] = '31'))
        INSERT INTO #MAS_Rooms(name, value)
        VALUES('31', '31')
    END

    IF(@buildingCd = 'A1' OR @buildingCd = 'A2')
    BEGIN
        IF(NOT EXISTS(SELECT TOP 1 1 FROM #MAS_Rooms WHERE [value] = '02'))
        INSERT INTO #MAS_Rooms(name, value)
        VALUES('02', '02')

        IF(NOT EXISTS(SELECT TOP 1 1 FROM #MAS_Rooms WHERE [value] = '2.5'))
        INSERT INTO #MAS_Rooms(name, value)
        VALUES('2.5', '2.5')

        IF(NOT EXISTS(SELECT TOP 1 1 FROM #MAS_Rooms WHERE [value] = '26'))
        INSERT INTO #MAS_Rooms(name, value)
        VALUES('26', '26')
    END

    IF(@buildingCd = 'A2')
    BEGIN
        IF(NOT EXISTS(SELECT TOP 1 1 FROM #MAS_Rooms WHERE [value] = '01'))
        INSERT INTO #MAS_Rooms(name, value)
        VALUES('01', '01')
    END
     
    SELECT  *
    FROM #MAS_Rooms
    ORDER BY [value]

END TRY
BEGIN CATCH
    DECLARE @ErrorNum INT,
            @ErrorMsg VARCHAR(200),
            @ErrorProc VARCHAR(50),
            @SessionID INT,
            @AddlInfo VARCHAR(MAX);

    SET @ErrorNum = ERROR_NUMBER();
    SET @ErrorMsg = 'sp_res_apartment_floor_list' + ERROR_MESSAGE();
    SET @ErrorProc = ERROR_PROCEDURE();

    SET @AddlInfo = ' ';

    EXEC utl_Insert_ErrorLog @ErrorNum,
                             @ErrorMsg,
                             @ErrorProc,
                             'Floor',
                             'GET',
                             @SessionID,
                             @AddlInfo;
END CATCH;