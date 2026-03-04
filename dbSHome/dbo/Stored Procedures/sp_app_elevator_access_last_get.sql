

CREATE   procedure [dbo].[sp_app_elevator_access_last_get]
    @userId uniqueidentifier,
    @mode   int  -- reserved for future use
	, @acceptLanguage NVARCHAR(50) = 'vi-VN'
AS
BEGIN TRY
    SET NOCOUNT ON;

    /* ========== 1) ========== */
    ;WITH LastLogs AS (
        SELECT TOP (1)
               l.HardwareId,
			   isLastest = 1
        FROM MAS_Elevator_Log AS l
        WHERE l.UserId = @UserId
		ORDER BY LogDt DESC
		UNION ALL
		SELECT TOP (1)
               u.HardwareId,
			   isLastest = 0
		FROM [MAS_Elevator_User] u
        ORDER BY sysDt DESC
    ),
	lasttop1 as (select top 1 * FROM LastLogs),
	cust as (SELECT ap.ApartmentId, a.projectCd
			FROM UserInfo u
			join MAS_Apartment_Member ap on u.custId = ap.CustId
			join MAS_Apartments a on ap.ApartmentId = a.ApartmentId
			WHERE userId = try_cast(@userId as uniqueidentifier))
     SELECT d.HardWareId,
            d.ProjectCd,
            d.BuildingCd      AS BuildCd,
            d.BuildZone,
            d.AreaCd,
            d.FloorName,
            d.FloorNumber     AS FloorNum
			,ap.ApartmentId
			,ll.isLastest
    FROM lasttop1 AS ll
    JOIN MAS_Elevator_Device AS d ON d.HardwareId = ll.HardwareId AND d.IsActived = 1
	join cust ap on ap.projectCd = d.ProjectCd
      

END TRY
BEGIN CATCH
    DECLARE @ErrorNum  int         = ERROR_NUMBER(),
            @ErrorMsg  varchar(200)= 'sp_app_elevator_access_last_get ' + ERROR_MESSAGE(),
            @ErrorProc varchar(50) = ERROR_PROCEDURE(),
            @SessionID int         = NULL,
            @AddlInfo  varchar(max);

    SET @AddlInfo = ' UserId: ' --+ ISNULL(@UserId,'');

    EXEC utl_Insert_ErrorLog @ErrorNum, @ErrorMsg, @ErrorProc, 'FloorInfo', 'GET', @SessionID, @AddlInfo;
END CATCH