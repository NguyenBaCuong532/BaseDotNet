CREATE PROCEDURE [dbo].[sp_res_apartment_family_member_list] @UserId UNIQUEIDENTIFIER = NULL
    , @ApartmentId INT
    , @acceptLanguage NVARCHAR(50) = N'vi-VN'
AS
BEGIN TRY
    IF @ApartmentId IS NULL
        OR @ApartmentId = 0
        SET @ApartmentId = (
                SELECT TOP 1 ApartmentId
                FROM [dbo].[fn_Hom_User_Apartment](CAST(@UserId AS NVARCHAR(450)))
                )

    SELECT [value] = a.CustId
        , [name] = a.[FullName]
        , [IsHost] = CASE 
            WHEN EXISTS (
                    SELECT ApartmentId
                    FROM MAS_Apartments ma
                    JOIN UserInfo mu
                        ON ma.UserLogin = mu.loginName
                    WHERE mu.CustId = a.CustId
                        AND ma.ApartmentId = b.ApartmentId
                    )
                THEN 1
            ELSE 0
            END
    FROM [MAS_Customers] a
    JOIN MAS_Apartment_Member b
        ON a.CustId = b.CustId
    LEFT JOIN MAS_Customer_Relation d
        ON b.RelationId = d.RelationId
    LEFT JOIN [COR_Countries] g
        ON a.CountryCd = g.CountryCd
    -- WHERE b.ApartmentId = 6120 AND b.[member_st] = 0
    WHERE b.ApartmentId = @ApartmentId
    --and b.[member_st] = 1
    --ORDER BY a.sysDate
    
    UNION ALL
    
    SELECT [value] = r.CustId
        , [name] = a.[FullName]
        , [IsHost] = 0
    FROM UserInfo a
    JOIN MAS_Apartment_Reg b
        ON a.UserId = b.userId
    JOIN MAS_Apartments p
        ON b.RoomCode = p.RoomCode
    JOIN UserInfo r
        ON b.UserId = r.UserId
    LEFT JOIN MAS_Customer_Relation d
        ON b.RelationId = d.RelationId
    --WHERE p.ApartmentId = 6120
    WHERE p.ApartmentId = @ApartmentId
        AND b.reg_st = 0
        AND NOT EXISTS (
            SELECT *
            FROM MAS_Apartment_Member am
            JOIN MAS_Customers cc
                ON am.CustId = cc.CustId
            WHERE am.ApartmentId = p.ApartmentId
                AND am.CustId = a.custId
                AND am.memberUserId = b.userId
            )
        --ORDER BY a.sysDate	
END TRY

BEGIN CATCH
    DECLARE @ErrorNum INT
        , @ErrorMsg VARCHAR(200)
        , @ErrorProc VARCHAR(50)
        , @SessionID INT
        , @AddlInfo VARCHAR(max)

    SET @ErrorNum = error_number()
    SET @ErrorMsg = 'sp_res_apartment_family_member_list ' + error_message()
    SET @ErrorProc = error_procedure()
    SET @AddlInfo = ' '

    EXEC utl_Insert_ErrorLog @ErrorNum
        , @ErrorMsg
        , @ErrorProc
        , 'Customer'
        , 'GET'
        , @SessionID
        , @AddlInfo
END CATCH