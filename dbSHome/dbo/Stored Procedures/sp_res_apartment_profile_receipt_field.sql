--EXEC dbo.sp_res_apartment_profile_receipt_field @userId = N'dea0d445-d934-4769-902f-843a517ebcc1',   -- nvarchar(450)
--                                                @ApartmentId = 4443-- int
CREATE   PROCEDURE [dbo].[sp_res_apartment_profile_receipt_field]
    @userId UNIQUEIDENTIFIER = null,
    @ApartmentId INT,
    @acceptLanguage NVARCHAR(50) = N'vi-VN'
AS
BEGIN TRY
    --
    IF @ApartmentId IS NOT NULL
       AND NOT EXISTS
    (
        SELECT 1
        FROM dbo.MAS_Apartments
        WHERE ApartmentId = @ApartmentId
    )
        SET @ApartmentId = NULL;
    --begin
    --1 thong tin chung
    SELECT @ApartmentId [ApartmentId],[tableKey] = 'MAS_Apartments_Profile_Receipt';
    --2- cac group
	DECLARE @group_key VARCHAR(50) = 'common_group'
	SELECT *
    FROM DBO.fn_get_field_group_lang(@group_key, @acceptLanguage)
    --SELECT 1 [group_cd],
    --       N'Thông tin chung' [group_name];
    --3 tung o trong group
    --exec sp_get_data_fields @ApartmentId,'Apartment'
	if @ApartmentId = 0 or @ApartmentId is null
			set @ApartmentId = (select top 1 a.ApartmentId FROM [MAS_Apartments] a 
					join UserInfo u on a.UserLogin = u.loginName 
					  WHERE exists(select userId from UserInfo 
						where userid = @UserId and CustId = u.CustId)
					order by a.isMain desc
				)

    SELECT s.id,
           s.[table_name],
           s.[field_name],
           s.[view_type],
           s.[data_type],
           s.[ordinal],
           s.[columnLabel],
           s.[group_cd],
           ISNULL(   CASE [field_name]
                         WHEN 'ProjectName' THEN
                             ProjectName
                         WHEN 'projectCd' THEN
                             b.ProjectCd
                         WHEN 'ApartmentId' THEN
                             LOWER(CONVERT(NVARCHAR(500), a.[ApartmentId]))
                         WHEN 'BuildingName' THEN
                             BuildingName
                         WHEN 'RoomCode' THEN
                             isnull(a.RoomCodeView,a.[RoomCode])
						WHEN 'RoomCode' THEN
                             a.RoomCode
						WHEN 'FullName' THEN
                             c.FullName
							 WHEN 'AvatarUrl' THEN
                             c.AvatarUrl
							 WHEN 'Floor' THEN
                             convert(nvarchar(500),a.[Floor])
							 WHEN 'WaterwayArea' THEN
							 convert(nvarchar(500),a.WaterwayArea)
							 WHEN 'UserLogin' THEN
                             a.[UserLogin]
							 WHEN 'Cif_No' THEN
                             a.[Cif_No] 
							 WHEN 'CustId' THEN
                             c.CustId
							 WHEN '[FamilyImageUrl]' THEN
                             [FamilyImageUrl]
							 WHEN 'MemberCount' THEN
                             (Select CONVERT(NVARCHAR(450),COUNT(CustId)) from MAS_Apartment_Member where ApartmentId = a.ApartmentId)
							 WHEN 'CardCount' THEN
                             (Select CONVERT(NVARCHAR(450),count(CardId)) from MAS_Apartment_Member mm inner join MAS_Cards cc on mm.CustId = cc.CustId where mm.ApartmentId = a.ApartmentId)
							 WHEN 'VehicleCount' THEN
                             (Select CONVERT(NVARCHAR(450),count(vh.CardVehicleId)) from MAS_CardVehicle vh where vh.ApartmentId = a.ApartmentId) --and vh.Status = 1)
							 WHEN 'Phone' THEN
                             c.Phone
							 WHEN 'Email' THEN
                             c.Email
							 WHEN 'IsReceived' THEN
                             convert(nvarchar(500),a.IsReceived)
							 WHEN 'ReceiveDt' THEN
							 --CONVERT(NVARCHAR(450),FORMAT(a.ReceiveDt, 'dd/MM/yyyy'))
							 convert(nvarchar(10),a.ReceiveDt,103) 
							 WHEN 'IsRent' THEN
                              convert(nvarchar(500),a.IsRent)
							 WHEN 'projectHotline' THEN
                             '02473037999'
							 WHEN 'isMain' THEN
                             convert(nvarchar(500),a.isMain)
							 WHEN 'CurrBal' THEN
                             convert(nvarchar(500),a.CurrBal)
							 WHEN 'CurrPoint' THEN
                             convert(nvarchar(500),ISNULL(p.CurrPoint ,0))
                     --WHEN 'link' THEN
                     --    FORMAT(b.insurance_date, 'dd/MM/yyyy')
                     END,
                     [columnDefault]
                 ) AS columnValue,
           [columnClass],
           [columnType],
           [columnObject],
           [isSpecial],
           [isRequire],
           [isDisable],
           s.[isVisiable],
           NULL AS [IsEmpty],
           ISNULL(s.columnTooltip, s.[columnLabel]) AS columnTooltip
           , s.columnDisplay
           , s.isIgnore
    FROM fn_config_form_gets('MAS_Apartments_Profile_Receipt', @acceptLanguage) s
        JOIN dbo.MAS_Apartments a ON a.ApartmentId = @ApartmentId
        LEFT JOIN MAS_Buildings b ON a.buildingOid = b.oid 
        join UserInfo u on a.UserLogin = u.loginName
        left join MAS_Customers c ON u.CustId = c.CustId
        left join MAS_Points p on c.CustId = p.CustId
    WHERE (s.IsVisiable = 1 OR s.isRequire = 1)
    ORDER BY ordinal;
END TRY
BEGIN CATCH
    DECLARE @ErrorNum INT,
            @ErrorMsg VARCHAR(200),
            @ErrorProc VARCHAR(50),
            @SessionID INT,
            @AddlInfo VARCHAR(MAX);

    SET @ErrorNum = ERROR_NUMBER();
    SET @ErrorMsg = 'sp_res_apartment_profile_receipt_field' + ERROR_MESSAGE();
    SET @ErrorProc = ERROR_PROCEDURE();

    SET @AddlInfo = ' ';

    EXEC utl_errorlog_set @ErrorNum,
                          @ErrorMsg,
                          @ErrorProc,
                          'Apartment_Receipt',
                          'GetInfo',
                          @SessionID,
                          @AddlInfo;
END CATCH;