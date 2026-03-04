CREATE PROCEDURE [dbo].[sp_res_vehicle_resident_field]
      @CardVehicleId INT = NULL,
      @cardVehicleOid UNIQUEIDENTIFIER = NULL,
      @UserId UNIQUEIDENTIFIER,
      @AcceptLanguage NVARCHAR(50) = NULL,

      @ApartmentId   INT = null,
      @CustomersOid  UNIQUEIDENTIFIER = null,
      @AssignDate    nvarchar(50) = null,
      @AuthDate      nvarchar(50) = null,
      @AuthName      nvarchar(50) = null,
      @CardCd        nvarchar(50) = null,
      @VehicleTypeID int = null,
      @VehicleTypeName nvarchar(100) = null,
      @VehicleNo     nvarchar(30) = null,
      @VehicleName   nvarchar(100) = null,
      @ServiceId     int = 0,
      @ServiceName   nvarchar(100) = null,
      @StartTime     nvarchar(10) = null,
      @EndTime       nvarchar(10) = null,
      @Status        int = NULL,
      @VehicleCardStatusName nvarchar(50) = null,
      @VehicleStatusName nvarchar(50) = null,
      @projectCd     nvarchar(50) = null,
      @VehicleColor  nvarchar(50) = null,
      @RadioButton   bit = 0,
      @RadioButton1  bit = 0,
      @DueDate       nvarchar(50) = null,

      @ImageUrl      nvarchar(500) = NULL,
      @ImageUrl2     nvarchar(500) = NULL,
      @ImageUrl3     nvarchar(500) = NULL,
      @ImageUrl4     nvarchar(500) = NULL,
      @ImageUrl5     nvarchar(500) = NULL,

      @ImgHeader     nvarchar(500) = NULL,
      @GroupFileId   UNIQUEIDENTIFIER = NULL
AS
BEGIN TRY
    SET NOCOUNT ON;
    IF @cardVehicleOid IS NOT NULL
        SET @CardVehicleId = (SELECT CardVehicleId FROM MAS_CardVehicle WHERE oid = @cardVehicleOid);

    DECLARE @DomainUrl NVARCHAR(200) = N'https://cdn.sunshinegroup.vn/media/'; -- Link server (giống SP đúng)
    DECLARE @group_key NVARCHAR(50) = N'common_group';
    DECLARE @table_key NVARCHAR(50) = N'apartment_vehicle_card';

    SET @authName = (SELECT TOP 1 fullName FROM dbo.Users WHERE userId = @UserId);

    -- RS0: meta
    SELECT  CardVehicleId = @CardVehicleId,
            tableKey      = @table_key,
            groupKey      = @group_key;

    -- RS1: groups
    SELECT *
    FROM [dbo].[fn_get_field_group](@group_key)
    ORDER BY intOrder;

    -- RS2: fields
    SELECT 
        s.[table_name]
        , s.[field_name]
        , s.[view_type]
        , s.[data_type]
        , s.[ordinal]
        , s.[columnLabel]
        , s.[group_cd]
        , columnValue = ISNULL(CASE s.[field_name]
                                  WHEN 'CardVehicleId'        THEN CONVERT(NVARCHAR(500), a.CardVehicleId)
                                  WHEN 'ApartmentId'          THEN CONVERT(NVARCHAR(100), ISNULL(@ApartmentId, a.ApartmentId))
                                  WHEN 'VehicleNo'            THEN ISNULL(@VehicleNo, a.VehicleNo)
                                  WHEN 'CustomersOid'         THEN CONVERT(NVARCHAR(100), ISNULL(@CustomersOid, a.CustId))
                                  WHEN 'VehicleName'          THEN ISNULL(@VehicleName, a.VehicleName)
                                  WHEN 'VehicleTypeID'        THEN CONVERT(NVARCHAR(10), ISNULL(@VehicleTypeID, a.VehicleTypeId))
                                  WHEN 'VehicleTypeName'      THEN CONVERT(NVARCHAR(500), e.VehicleTypeName)
                                  WHEN 'AssignDate'           THEN CONVERT(NVARCHAR(20), a.[AssignDate], 103)
                                  WHEN 'StartTime'            THEN CONVERT(NVARCHAR(10), ISNULL(a.[StartTime], GETDATE()), 103)
                                  WHEN 'EndTime'              THEN CONVERT(NVARCHAR(10), a.[EndTime], 103)
                                  WHEN 'ServiceId'            THEN CONVERT(NVARCHAR(500), a.ServiceId)
                                  WHEN 'ServiceName'          THEN N'Vé tháng - ' + e.VehicleTypeName
                                  WHEN 'Status'               THEN CONVERT(NVARCHAR(500), a.[Status])
                                  WHEN 'VehicleStatusName'    THEN mv.StatusName
                                  WHEN 'CardCd'               THEN CONVERT(NVARCHAR(500), ISNULL(@CardCd, ISNULL(card.CardCd, d.CardCd)))
                                  WHEN 'AuthName'             THEN ISNULL(u.fullName, @authName)
                                  WHEN 'AuthDate'             THEN CONVERT(NVARCHAR(20), ISNULL(a.Auth_Dt, GETDATE()), 103)
                                  WHEN 'ProjectCd'            THEN CONVERT(NVARCHAR(500), d.ProjectCd)
                                  WHEN 'VehicleColor'         THEN ISNULL(@VehicleColor, a.VehicleColor)
                                  WHEN 'DueDate'              THEN CONVERT(NVARCHAR(20), a.DueDate, 103)

                                  WHEN 'RadioButton'          THEN CONVERT(NVARCHAR(500), CASE WHEN a.IsMonthlyScripts = 1 THEN 'true' ELSE 'false' END)
                                  WHEN 'RadioButton1'         THEN CONVERT(NVARCHAR(500), CASE WHEN a.IsMonthlyScripts = 1 THEN 'false' ELSE 'true' END)
                                  WHEN 'GroupFileId'         THEN CONVERT(NVARCHAR(500), @GroupFileId)

                                  -- ✅ FIX: NỐI LINK ẢNH GIỐNG SP ĐÚNG
                                  WHEN 'ImageUrl'             THEN IIF(a.ImageUrl IS NULL OR TRIM(a.ImageUrl) = '', '', IIF(a.ImageUrl  LIKE 'http%', a.ImageUrl,  @DomainUrl + ISNULL(a.ImageUrl,  '')))
                                  WHEN 'ImageUrl2'            THEN IIF(a.ImageUrl2 IS NULL OR TRIM(a.ImageUrl2) = '', '', IIF(a.ImageUrl2 LIKE 'http%', a.ImageUrl2, @DomainUrl + ISNULL(a.ImageUrl2, '')))
                                  WHEN 'ImageUrl3'            THEN IIF(a.ImageUrl3 IS NULL OR TRIM(a.ImageUrl3) = '', '', IIF(a.ImageUrl3 LIKE 'http%', a.ImageUrl3, @DomainUrl + ISNULL(a.ImageUrl3, '')))
                                  WHEN 'ImageUrl4'            THEN IIF(a.ImageUrl4 IS NULL OR TRIM(a.ImageUrl4) = '', '', IIF(a.ImageUrl4 LIKE 'http%', a.ImageUrl4, @DomainUrl + ISNULL(a.ImageUrl4, '')))
                                  WHEN 'ImageUrl5'            THEN IIF(a.ImageUrl5 IS NULL OR TRIM(a.ImageUrl5) = '', '', IIF(a.ImageUrl5 LIKE 'http%', a.ImageUrl5, @DomainUrl + ISNULL(a.ImageUrl5, '')))
                              END
                              , s.[columnDefault])
        , s.[columnClass]
        , s.[columnType]
        , columnObject = CASE
                            WHEN s.[field_name] = 'ApartmentId' THEN s.[columnObject] + ISNULL(@projectCd, '')
                                + IIF(ISNULL(@ApartmentId, a.ApartmentId) IS NULL, '', '&apartmentId=' + CONVERT(NVARCHAR(50), ISNULL(@ApartmentId, a.ApartmentId)))
                            WHEN s.[field_name] = 'CustomersOid' THEN s.[columnObject] + CONVERT(NVARCHAR(50), ISNULL(ISNULL(@ApartmentId, a.ApartmentId), 0))
                                + '&custId=' + IIF(ISNULL(@CustomersOid, a.CustId) IS NULL, '', CONVERT(NVARCHAR(100), ISNULL(@CustomersOid, a.CustId)))
                            ELSE s.[columnObject]
                          END
        , s.[isSpecial]
        , [isRequire] = CASE
                              WHEN (s.[field_name] = 'CardCd' AND ISNULL(@VehicleTypeID, a.VehicleTypeId) <> 1) THEN 1
                              ELSE s.[isRequire]
                          END
        , [isDisable] = CASE 
                            WHEN s.[field_name] = 'DueDate' THEN IIF(a.IsMonthlyScripts = 1, 'true', 'false')
                            ELSE s.[isDisable]
                        END
        , s.[isVisiable]
        , NULL AS [IsEmpty]
        , ISNULL(s.columnTooltip, s.[columnLabel]) AS columnTooltip
    FROM
        dbo.fn_config_form_gets(@table_key, ISNULL(@AcceptLanguage, N'vi-VN')) s
        OUTER APPLY(SELECT TOP 1 * FROM dbo.MAS_CardVehicle a WHERE s.table_name = @table_key AND a.CardVehicleId = @CardVehicleId) a
        LEFT JOIN dbo.MAS_Cards d ON a.CardId = d.CardId
        LEFT JOIN dbo.MAS_VehicleTypes e ON a.VehicleTypeId = e.VehicleTypeId
        LEFT JOIN dbo.Users u ON u.userId = a.Auth_id
        LEFT JOIN dbo.MAS_VehicleStatus mv ON a.[STATUS] = mv.StatusId
        OUTER APPLY(SELECT TOP 1 mc.CardCd
                    FROM
                        [MAS_Apartments] ap
                        join [MAS_Cards] mc on mc.ApartmentId = ap.ApartmentId
                    WHERE
                        ap.ApartmentId = ISNULL(@ApartmentId, a.ApartmentId)
                        AND (mc.CardCd = @CardCd OR mc.CustId = @CustomersOid)) card
    WHERE s.table_name = @table_key
    ORDER BY s.ordinal;
END TRY
BEGIN CATCH
    DECLARE @ErrorNum  INT = ERROR_NUMBER(),
            @ErrorMsg  NVARCHAR(4000) = N'sp_res_vehicle_resident_field: ' + ERROR_MESSAGE(),
            @ErrorProc NVARCHAR(200) = ERROR_PROCEDURE(),
            @SessionID INT,
            @AddlInfo  NVARCHAR(MAX) = N'';

    EXEC utl_errorlog_set 
          @ErrorNum
        , @ErrorMsg
        , @ErrorProc
        , @table_key
        , 'GetInfo'
        , @SessionID
        , @AddlInfo;

   
END CATCH;