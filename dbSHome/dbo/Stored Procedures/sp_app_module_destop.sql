
CREATE PROCEDURE [dbo].[sp_app_module_destop] 
	  @userId UNIQUEIDENTIFIER = NULL
    , @acceptLanguage NVARCHAR(50) = 'vi-VN'
AS
BEGIN TRY
    --LOCAL_SVG | NETWORK_IMAGE | NETWORK_SVG
    SELECT 'LOCAL_SVG' AS BannerType
        , NULL AS BannerURL

    --,'assets/images/theme/banner20_10.svg' as BannerURL --link 20-10
    SELECT [mod_cd] = m.mod_cd
        , [mod_name] = COALESCE(l.mod_name, m.mod_name)
        , [mod_title] = COALESCE(l.mod_name, m.mod_name)
        , [on_flg]
        , [mod_gr]
        , [mod_icon]
        , pathMobile
    FROM [dbo].module_app m
    LEFT JOIN module_app_lang l
        ON m.mod_cd = l.mod_cd
            AND l.langKey = @acceptLanguage
    WHERE [on_flg] = 1
        AND parent_cd IS NULL
        AND EXISTS (
            SELECT 1
            FROM [module_type] t
            JOIN UserInfo u
                ON t.userType = u.userType
            WHERE t.mod_cd = m.mod_cd
                AND u.userId = @userId
            )
    ORDER BY int_ord
END TRY

BEGIN CATCH
    DECLARE @ErrorNum INT
        , @ErrorMsg VARCHAR(200)
        , @ErrorProc VARCHAR(50)
        , @SessionID INT
        , @AddlInfo VARCHAR(max)

    SET @ErrorNum = error_number()
    SET @ErrorMsg = 'sp_hrm_app_module_destop ' + error_message()
    SET @ErrorProc = error_procedure()
    SET @AddlInfo = ' '

    EXEC utl_errorLog_set @ErrorNum
        , @ErrorMsg
        , @ErrorProc
        , 'module_app'
        , 'GET'
        , @SessionID
        , @AddlInfo
END CATCH