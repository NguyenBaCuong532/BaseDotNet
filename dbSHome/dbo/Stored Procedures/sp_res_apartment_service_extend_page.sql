
CREATE PROCEDURE [dbo].[sp_res_apartment_service_extend_page]
    @userId UNIQUEIDENTIFIER,
    @filter NVARCHAR(30) = NULL,
	@ApartmentId INT,

    @Offset INT = 0,
    @PageSize INT = 10,
    @Total INT = 0 OUT,
    @TotalFiltered INT = 0 OUT,
    @acceptLanguage NVARCHAR(50) = N'vi-VN'
AS
BEGIN TRY

    SET @Offset = ISNULL(@Offset, 0);
    SET @PageSize = ISNULL(@PageSize, 10);
    SET @Total = ISNULL(@Total, 0);
    SET @filter = ISNULL(@filter, '');

	if @ApartmentId is null or @ApartmentId = 0
		set @ApartmentId = (SELECT top 1 c.ApartmentId 
		FROM UserInfo a inner join MAS_Apartments c on a.loginName = c.UserLogin 
		 WHERE a.UserId = @UserID)

    IF @PageSize = 0
        SET @PageSize = 10;
    IF @Offset < 0
        SET @Offset = 0;

    SELECT @Total = COUNT(a.ExtendId)
	  FROM MAS_Apartment_Service_Extend a 
		  join MAS_Apartments b on a.ApartmentId = b.ApartmentId 
		  left join PAR_TelecomPrice c on a.PackPriceId = c.PriceId
		  LEFT JOIN dbo.MAS_ServiceProvider sp ON sp.ProviderCd = a.ProviderCd
	  WHERE a.ApartmentId = @ApartmentId

    SET @TotalFiltered = @Total;

    IF @PageSize < 0
    BEGIN
        SET @PageSize = 10;
    END;
    IF @Offset = 0
    BEGIN
        SELECT *
		FROM [dbo].fn_config_list_gets_lang('view_apartment_service_extend_fee_page', 0, @acceptLanguage)
		ORDER BY [ordinal];

    END;
    -- Data
    SELECT a.CustId 
			  ,a.CustName
			  ,a.CustPhone
			  ,a.ApartmentId 
			  ,a.ContractNo 
			  ,convert(nvarchar(10),a.ContractDt ,103) as ContractDate
			  ,a.ContractUser
			  ,a.ContractPassword
			  ,a.DeviceSeri as DeviceSerial
			  ,a.DeviceName
			  ,convert(nvarchar(10),a.DeviceWarranty,103) as DeviceWarranty
			  ,a.ContractTypeId
			  ,a.ExtendId
			  ,a.AccrualToDt
			  ,a.PayLastDt
			  ,sp.ProviderShort AS ProviderCd    -- a.ProviderCd
			  ,a.isCompany 
			  ,a.CompanyCode
			  ,a.CompanyName
			  ,a.CompanyRepresent
			  ,a.CompanyAddress
			  ,a.PackPriceId
			  ,c.PriceName as PackPriceName
	  FROM MAS_Apartment_Service_Extend a 
		  join MAS_Apartments b on a.ApartmentId = b.ApartmentId 
		  left join PAR_TelecomPrice c on a.PackPriceId = c.PriceId
		  LEFT JOIN dbo.MAS_ServiceProvider sp ON sp.ProviderCd = a.ProviderCd
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
    SET @ErrorMsg = 'sp_res_apartment_service_extend_page' + ERROR_MESSAGE();
    SET @ErrorProc = ERROR_PROCEDURE();
    SET @AddlInfo = '';

    EXEC utl_ErrorLog_Set @ErrorNum,
                          @ErrorMsg,
                          @ErrorProc,
                          'apartment_service_extend',
                          'GET',
                          @SessionID,
                          @AddlInfo;
END CATCH;