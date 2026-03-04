
CREATE PROCEDURE [dbo].[sp_res_apartment_service_living_page]
    @userId UNIQUEIDENTIFIER,
    @filter NVARCHAR(30) = NULL,
	@ApartmentId INT,

    @Offset INT = 0,
    @PageSize INT = 10,
    @Total INT = 0 OUT,
    @TotalFiltered INT = 0 OUT,
	@GridKey		nvarchar(100) out,
    @acceptLanguage NVARCHAR(50) = N'vi-VN'
AS
BEGIN TRY

    SET @Offset = ISNULL(@Offset, 0);
    SET @PageSize = ISNULL(@PageSize, 10);
    SET @Total = ISNULL(@Total, 0);
    SET @filter = ISNULL(@filter, '');
	set		@GridKey				= 'view_apartment_service_living_page'

	if @ApartmentId is null or @ApartmentId = 0
		set @ApartmentId = (SELECT top 1 c.ApartmentId 
		FROM UserInfo a inner join MAS_Apartments c on a.loginName = c.UserLogin 
		 WHERE a.UserId = @UserID)

    IF @PageSize = 0
        SET @PageSize = 10;
    IF @Offset < 0
        SET @Offset = 0;

    SELECT @Total = COUNT(a.LivingId)
    FROM MAS_Apartment_Service_Living a
        JOIN MAS_Apartments b
            ON a.ApartmentId = b.ApartmentId
        JOIN MAS_LivingTypes c
            ON a.LivingTypeId = c.LivingTypeId
        LEFT JOIN MAS_ServiceProvider d
            ON a.ProviderCd = d.ProviderCd
    WHERE a.ApartmentId = @ApartmentId

    SET @TotalFiltered = @Total;

    IF @PageSize < 0
    BEGIN
        SET @PageSize = 10;
    END;
    IF @Offset = 0
    BEGIN
        SELECT *
		FROM [dbo].fn_config_list_gets_lang('view_apartment_service_living_page', 0, @acceptLanguage)
		ORDER BY [ordinal];

    END;
    -- Data
    SELECT a.CustId,
           cus.FullName AS CustName,
           a.CustPhone,
           a.ApartmentId,
           a.ContractNo,
           CONVERT(NVARCHAR(10), a.ContractDt, 103) AS ContractDate,
           a.MeterSeri AS meterSerial,
           a.MeterNum AS meterNumber,
           CONVERT(NVARCHAR(10), a.MeterDate, 103) AS startDate,
           a.DeliverName,
           a.LivingTypeId AS LivingType,
           a.LivingId,
           a.AccrualToDt AS accrualLast,
           a.PayLastDt,
           a.ProviderCd,
           a.Note,
           c.LivingTypeName,
           a.EmployeeCd,
           d.ProviderName,
           a.NumPersonWater
    FROM MAS_Apartment_Service_Living a
        JOIN MAS_Apartments b
            ON a.ApartmentId = b.ApartmentId
        JOIN MAS_LivingTypes c
            ON a.LivingTypeId = c.LivingTypeId
        LEFT JOIN MAS_ServiceProvider d
            ON a.ProviderCd = d.ProviderCd
		LEFT JOIN dbo.MAS_Customers cus
			ON cus.CustId = a.CustId
    WHERE a.ApartmentId = @ApartmentId
    ORDER BY a.sysDate OFFSET @Offset ROWS FETCH NEXT @PageSize ROWS ONLY;
END TRY
BEGIN CATCH
    DECLARE @ErrorNum INT,
            @ErrorMsg VARCHAR(200),
            @ErrorProc VARCHAR(50),
            @SessionID INT,
            @AddlInfo VARCHAR(MAX);

    SET @ErrorNum = ERROR_NUMBER();
    SET @ErrorMsg = 'sp_res_apartment_service_living_page' + ERROR_MESSAGE();
    SET @ErrorProc = ERROR_PROCEDURE();
    SET @AddlInfo = '';

    EXEC utl_ErrorLog_Set @ErrorNum,
                          @ErrorMsg,
                          @ErrorProc,
                          'apartment_service_living',
                          'GET',
                          @SessionID,
                          @AddlInfo;
END CATCH;