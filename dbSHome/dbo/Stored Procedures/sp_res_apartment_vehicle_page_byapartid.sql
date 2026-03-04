CREATE PROCEDURE [dbo].[sp_res_apartment_vehicle_page_byapartid]
    @userId UNIQUEIDENTIFIER = NULL,
    @filter NVARCHAR(30) = NULL,
    @ApartmentId INT = 5466,
    @Oid NVARCHAR(450) = NULL, -- convert thì int -uuid

	@gridWidth int = 0,
    @Offset INT = 0,
    @PageSize INT = 10,
    @acceptLanguage NVARCHAR(50) = N'vi-VN'
 --   @Total INT = 0 OUT,
 --   @TotalFiltered INT = 0 OUT,
	--@GridKey		nvarchar(100) out
AS
BEGIN TRY
	declare @Total		bigint
	declare @GridKey	nvarchar(100) = 'view_apartment_vehicle_page'

    SET @Offset = ISNULL(@Offset, 0);
    SET @PageSize = ISNULL(@PageSize, 10);
    SET @Total = ISNULL(@Total, 0);
    SET @filter = ISNULL(@filter, '');

    IF @ApartmentId IS NULL
       OR @ApartmentId = 0
        SET @ApartmentId =
    (
        SELECT TOP 1
               c.ApartmentId
        FROM UserInfo a
            INNER JOIN MAS_Apartments c
                ON a.loginName = c.UserLogin
        WHERE a.UserId = @userId
    )   ;

    IF @PageSize = 0
        SET @PageSize = 10;
    IF @Offset < 0
        SET @Offset = 0;

    SELECT @Total = COUNT(a.CardVehicleId)
    FROM
        MAS_CardVehicle a
        LEFT JOIN MAS_Customers b ON a.CustId = b.CustId
        INNER JOIN MAS_VehicleTypes c ON a.VehicleTypeId = c.VehicleTypeId
        JOIN MAS_Apartments ac ON a.ApartmentId = ac.ApartmentId
        LEFT JOIN MAS_Cards p ON a.CardId = p.CardId
        LEFT JOIN MAS_VehicleStatus mc ON a.[Status] = mc.StatusId
    WHERE ac.ApartmentId = @ApartmentId;

    --root	
	select recordsTotal = @Total
		  ,recordsFiltered = @Total
		  ,gridKey = @GridKey
		  ,valid = 1

    IF @Offset = 0
    BEGIN
        SELECT *
        FROM [dbo].fn_config_list_gets_lang(@GridKey, 0, @acceptLanguage)
        ORDER BY [ordinal];

    END;
    -- Data
    SELECT a.CardVehicleId,
           CONVERT(NVARCHAR(10), a.StartTime, 103) StartTime,
           CONVERT(NVARCHAR(10), a.EndTime, 103) EndTime,
           a.CustId,
           a.VehicleTypeId,
           c.VehicleTypeName,
           b.FullName,
           mc.StatusNameLable, --AS [StatusNameLable],
           --mc.StatusName,
           mc.StatusId as [Status],
           mc.StatusId AS IsLock,
           --,case a.Card_St when 0 then N'Đang hoạt động' when 1 then N'Hết hiệu lực' when 2 then N'Đã báo mất thẻ' else N'Khóa thẻ' end [StatusName]
           --,case Card_St when 0 then N'Đang hoạt động' when 1 then N'Hết hiệu lực' when 2 then N'Đã báo mất thẻ' else N'Khóa thẻ' end as [Status]
           ac.ApartmentId,
           b.CustId,
           a.VehicleNo,
           a.VehicleNum,
           a.VehicleName,
           a.isVehicleNone,
           a.lastReceivable,
           ac.RoomCode,
           p.CardCd,
           b.Phone,
           CancelDate = FORMAT(cv.CancelDate, 'dd/MM/yyyy')
    FROM
        MAS_CardVehicle a
        LEFT JOIN MAS_Customers b ON a.CustId = b.CustId
        INNER JOIN MAS_VehicleTypes c ON a.VehicleTypeId = c.VehicleTypeId
        JOIN MAS_Apartments ac ON a.ApartmentId = ac.ApartmentId
        LEFT JOIN MAS_Cards p ON a.CardId = p.CardId
        LEFT JOIN MAS_VehicleStatus mc ON a.[Status] = mc.StatusId
        OUTER APPLY(SELECT TOP 1 * FROM mas_cancel_vehicle_card WHERE CardVehicleId = a.CardVehicleId) cv
    WHERE ac.ApartmentId = @ApartmentId
    ORDER BY a.AssignDate OFFSET @Offset ROWS FETCH NEXT @PageSize ROWS ONLY;
    
END TRY
BEGIN CATCH
    DECLARE @ErrorNum INT,
            @ErrorMsg VARCHAR(200),
            @ErrorProc VARCHAR(50),
            @SessionID INT,
            @AddlInfo VARCHAR(MAX);

    SET @ErrorNum = ERROR_NUMBER();
    SET @ErrorMsg = 'sp_res_apartment_vehicle_get' + ERROR_MESSAGE();
    SET @ErrorProc = ERROR_PROCEDURE();
    SET @AddlInfo = '';

    EXEC utl_errorlog_set @ErrorNum,
                          @ErrorMsg,
                          @ErrorProc,
                          'apartment_vehicle',
                          'GET',
                          @SessionID,
                          @AddlInfo;
END CATCH;