
CREATE   PROCEDURE [dbo].[sp_res_card_vehicle_service_info] 
	  @userId UNIQUEIDENTIFIER = NULL
     ,@clientId nvarchar(50) = null
    , @filter NVARCHAR(30) = NULL
    , @CardCd NVARCHAR(50)
	, @gridWidth int = 0
    , @Offset INT = 0
    , @PageSize INT = 10
    , @acceptLanguage NVARCHAR(50) = N'vi-VN'
 --   , @Total INT = 0 OUT
 --   , @TotalFiltered INT = 0 OUT
	--, @GridKey		nvarchar(100) out
AS
BEGIN TRY
	declare @Total		bigint
	declare @GridKey	nvarchar(100) = 'view_vehicle_card_service_page'

    SET @Offset = ISNULL(@Offset, 0);
    SET @PageSize = ISNULL(@PageSize, 10);
    SET @Total = ISNULL(@Total, 0);
    SET @filter = ISNULL(@filter, '');

   IF @PageSize = 0
        SET @PageSize = 10;

    IF @Offset < 0
        SET @Offset = 0;

    SELECT @Total = COUNT(CardVehicleId)
    FROM [dbo].[MAS_CardVehicle] a
    INNER JOIN [MAS_Cards] d
        ON a.CardId = d.CardId
    LEFT JOIN MAS_VehicleStatus mv
        ON a.STATUS = mv.StatusId
    LEFT JOIN MAS_VehicleTypes e
        ON a.VehicleTypeId = e.VehicleTypeId
    WHERE EXISTS (
            SELECT CardCd
            FROM [MAS_Cards]
            WHERE CardCd = @CardCd
                AND CardId = a.CardID
            )

    --root	
	select recordsTotal = @Total
		  ,recordsFiltered = @Total
		  ,gridKey = @GridKey
		  ,valid = 1
    --grid config
    IF @Offset = 0
    BEGIN
        SELECT *
        FROM [dbo].fn_config_list_gets_lang(@GridKey, 0, @acceptLanguage)
        ORDER BY [ordinal];
    END;

    -- Data
    SELECT CardVehicleId
		,cv.CardId
        ,FullName
		,CardCd
		,cv.CardVehicleId as VehicleTypeID
		,cb.ProjectCode as ProjectCd
		,p.projectName as projectName
		,AssignDate
		,cv.Auth_Dt as AuthDate
		,Convert(nvarchar, StartTime, 103) as StartTime
		,Coalesce(Convert(nvarchar,DueDate), Convert(nvarchar,Endtime))as EndTime
		,VehicleTypeName
		,VehicleName
		,VehicleNo
		,vs.StatusName  as VehicleStatusName
		,a.RoomCode as RoomCode
		--,VehicleCardStatusName
		--,IsLock
    FROM
        [dbo].[MAS_CardVehicle] cv
		INNER JOIN [MAS_Cards] c ON cv.CardId = c.CardId  

		LEFT JOIN MAS_VehicleTypes vt ON vt.VehicleTypeId = cv.VehicleTypeId 
		LEFT JOIN MAS_Apartment_Card ac ON ac.CardId = c.CardId
		LEFT JOIN MAS_Apartments a ON ac.ApartmentId = a.ApartmentId 

		LEFT JOIN MAS_CardBase cb ON cb.Code = c.CardCd
		LEFT JOIN MAS_Users u ON u.CustId = c.CustId
		LEFT JOIN MAS_Projects p on cv.ProjectCd = p.projectCd

		JOIN MAS_VehicleStatus vs ON vs.StatusId = cv.[Status]
		WHERE EXISTS (
			SELECT 1
			FROM [MAS_Cards]
			WHERE CardCd = @CardCd AND CardId = cv.CardID
		)            
			ORDER BY c.CardCd OFFSET @Offset ROWS

    FETCH NEXT @PageSize ROWS ONLY;
END TRY

BEGIN CATCH
    DECLARE @ErrorNum INT
        , @ErrorMsg VARCHAR(200)
        , @ErrorProc VARCHAR(50)
        , @SessionID INT
        , @AddlInfo VARCHAR(MAX);

    SET @ErrorNum = ERROR_NUMBER();
    SET @ErrorMsg = 'sp_res_card_vehicle_service_page' + ERROR_MESSAGE();
    SET @ErrorProc = ERROR_PROCEDURE();
    SET @AddlInfo = '';

    EXEC utl_ErrorLog_Set @ErrorNum
        , @ErrorMsg
        , @ErrorProc
        , 'view_vehicle_card_service_page'
        , 'GET'
        , @SessionID
        , @AddlInfo;
END CATCH;