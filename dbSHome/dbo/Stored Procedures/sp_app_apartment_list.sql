
-- =============================================
-- Author: ANHTT
-- Create date: 2025-09-05 12:38:38
-- Description:	list apartment| căn đã duyệt
-- Output:
-- =============================================
CREATE PROCEDURE [dbo].[sp_app_apartment_list] 
	  @userId UNIQUEIDENTIFIER = NULL
    , @projectCd NVARCHAR(50) = NULL
    , @acceptLanguage NVARCHAR(50) = 'vi-VN'
AS
BEGIN TRY
    --DECLARE @customerId UNIQUEIDENTIFIER = dbo.fn_get_customerid(@userId)
    DECLARE @userLogin NVARCHAR(100);
    DECLARE @custId UNIQUEIDENTIFIER;
    DECLARE @main_apartment NVARCHAR(50)

    SELECT @userLogin = loginName
        , @custId = custId
    FROM UserInfo
    WHERE userId = @userId

    SELECT TOP 1 @main_apartment = ApartmentId
    FROM MAS_Apartment_Member
    WHERE CustId = @custId
        AND main_st = 1
        --AND isNotification = 1

    -- Updated: buildingOid, floor từ MAS_Apartments/MAS_Elevator_Floor, member by apartOid
    SELECT [value] = a.ApartmentId
        , apartOid = a.oid
        , [name] = dbo.fn_apartment_format(a.[RoomCode], ISNULL(ef.FloorName, a.floorNo), ISNULL(b.BuildingName, b.buildingCd))
        , a.projectCd
        , p.projectName
        , isMain = IIF(@main_apartment = a.ApartmentId, 1, 0)
    FROM MAS_Apartments a
    LEFT JOIN MAS_Buildings b ON a.buildingOid = b.oid
    LEFT JOIN MAS_Elevator_Floor ef ON a.floorOid = ef.oid
    LEFT JOIN MAS_Projects p ON p.oid = a.tenant_oid
    WHERE (
            a.UserLogin = @userLogin
            OR EXISTS (
                SELECT TOP 1 1
                FROM MAS_Apartment_Member m
                WHERE (m.apartOid = a.oid OR (m.apartOid IS NULL AND m.ApartmentId = a.ApartmentId))
                    AND m.CustId = @custId
                )
            )
        AND (
            @projectCd IS NULL
            OR a.[projectCd] = @projectCd
            )
END TRY

BEGIN CATCH
    DECLARE @ErrorNum INT
        , @ErrorMsg VARCHAR(200)
        , @ErrorProc VARCHAR(50)
        , @SessionID INT
        , @AddlInfo VARCHAR(MAX);

    SET @ErrorNum = ERROR_NUMBER();
    SET @ErrorMsg = ERROR_MESSAGE();
    SET @ErrorProc = ERROR_PROCEDURE();

    --SET @AddlInfo = NULL;
    EXEC utl_ErrorLog_Set @ErrorNum
        , @ErrorMsg
        , @ErrorProc
        , 'MAS_Apartments'
        , 'GET'
        , @SessionID
        , @AddlInfo;
END CATCH;