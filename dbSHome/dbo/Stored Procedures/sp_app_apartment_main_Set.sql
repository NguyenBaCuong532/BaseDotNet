

CREATE   procedure [dbo].[sp_app_apartment_main_Set] 
	  @userId UNIQUEIDENTIFIER
    , @apartmentId BIGINT
    , @status INT = NULL
	, @acceptLanguage NVARCHAR(50) = 'vi-VN'
AS
BEGIN TRY
    DECLARE @custId UNIQUEIDENTIFIER = dbo.fn_get_customerid(@userId)
    UPDATE t
    SET main_st = CASE 
            WHEN t.ApartmentId = @apartmentId
                THEN 1
            ELSE 0
            END
    FROM [dbo].MAS_Apartment_Member t
    WHERE t.CustId = @custId
    -- JOIN UserInfo u
    --     ON t.CustId = u.custId
    -- WHERE t.userId = @userId
END TRY

BEGIN CATCH
    DECLARE @ErrorNum INT
        , @ErrorMsg VARCHAR(200)
        , @ErrorProc VARCHAR(50)
        , @SessionID INT
        , @AddlInfo VARCHAR(max)

    SET @ErrorNum = error_number()
    SET @ErrorMsg = error_message()
    SET @ErrorProc = error_procedure()
    SET @AddlInfo = ''

    EXEC utl_Insert_ErrorLog @ErrorNum
        , @ErrorMsg
        , @ErrorProc
        , 'ApartmentMain'
        , 'Set'
        , @SessionID
        , @AddlInfo
END CATCH