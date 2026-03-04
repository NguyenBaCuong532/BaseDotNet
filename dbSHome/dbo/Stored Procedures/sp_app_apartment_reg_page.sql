

-- =============================================
-- Author:	AnhTT
-- Create date: 2025-09-10 21:50:32
-- Description:	Danh sách căn hộ của người dùng (Bao gồm căn chưa duyệt)
-- =============================================
CREATE   PROCEDURE [dbo].[sp_app_apartment_reg_page] 
	 @userId UNIQUEIDENTIFIER = NULL
    ,@acceptLanguage NVARCHAR(50) = N'vi-VN'
AS
BEGIN TRY
    DECLARE @status_key NVARCHAR(50) = 'apartment_member_status';
    DECLARE @customerId UNIQUEIDENTIFIER = dbo.fn_get_customerid(@userId);
    
    SELECT ApartmentId = NULL
        , apartmentRegId = a.Id
        , a.RoomCode
        , p.address
        , p.projectCd
        , p.projectName
        , projectIntroUrl = NULL
        , isMain = NULL
        , [status] = 0
        , [StatusName] = s.objClass
    FROM MAS_Apartment_Reg a
    INNER JOIN MAS_Apartments ap ON ap.RoomCode = a.RoomCode
    INNER JOIN MAS_Buildings b ON ap.buildingOid = b.oid
    INNER JOIN MAS_Projects p ON p.oid = b.tenant_oid
    LEFT JOIN fn_config_data_gets_lang(@status_key, @acceptLanguage) s
        ON s.objCode = a.reg_st
    WHERE a.userId = @userId
        --AND NOT EXISTS (
        --    SELECT TOP 1 1
        --    FROM cte sa
        --    WHERE sa.RoomCode = a.roomCode
        --    )
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
    SET @AddlInfo = '';

    EXEC utl_errorlog_set @ErrorNum
        , @ErrorMsg
        , @ErrorProc
        , 'MAS_Apartments'
        , 'GET'
        , @SessionID
        , @AddlInfo;
END CATCH