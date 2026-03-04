-- =============================================
-- Author:		duongpx
-- Create date: 2024-07-01
-- Description:	lay user push
-- =============================================
CREATE FUNCTION [dbo].[fn_get_user_push] (
	 @userId			nvarchar(450) 
	,@to_type			int 
	,@to_level			int 
	,@to_groups			nvarchar(max) 
)
RETURNS 
@rt TABLE 
(
	[userId] [nvarchar](100) NULL,
	[custId] [nvarchar](100) NULL,
	[phone] [nvarchar](30) NULL,
	[email] [nvarchar](300) NULL,
	[fullName] [nvarchar](300) NULL,
	[room] [nvarchar](50) NULL
)
AS
BEGIN
    DECLARE @tbGr TABLE ([Id] nvarchar(50) NULL);
    DECLARE @tbPos TABLE ([cd] nvarchar(50) NULL);
    DECLARE @tbPosOid TABLE ([oid] UNIQUEIDENTIFIER NULL);  -- chứa GUID (buildingOid/apartOid)
    DECLARE @tbPosInt TABLE ([id] INT NULL);                -- chứa INT (ApartmentId)

    IF @to_type = 0 -- crm
    BEGIN
        IF @to_level = 0 --- dự án
        BEGIN
            INSERT INTO @tbPos
            SELECT part FROM dbo.SplitString(@to_groups, ',');

            INSERT INTO @rt
            SELECT userId = NULL
                  ,e.custId
                  ,c.phone
                  ,c.email
                  ,c.fullName
                  ,''
            FROM CRM_Customer e
            JOIN MAS_Customers c ON e.custId = c.custId
            WHERE EXISTS (SELECT 1 FROM @tbPos WHERE cd = e.categoryCd);
        END
        ELSE IF @to_level = 1 -- nhóm
        BEGIN
            INSERT INTO @tbPos
            SELECT part FROM dbo.SplitString(@to_groups, ',');

            INSERT INTO @rt
            SELECT userId = NULL
                  ,c.custId
                  ,c.phone
                  ,c.email
                  ,c.fullName
                  ,''
            FROM MAS_Customers c
            JOIN CRM_Customer g ON c.CustId = g.custId
            WHERE EXISTS (SELECT 1 FROM @tbPos WHERE cd = g.group_id);
        END
        ELSE IF @to_level = 2 -- người quản lý
        BEGIN
            INSERT INTO @tbPos
            SELECT part FROM dbo.SplitString(@to_groups, ',');

            INSERT INTO @rt
            SELECT DISTINCT c.userId
                  ,c.custId
                  ,c.phone
                  ,c.email
                  ,c.fullName
                  ,''
            FROM Users c
            WHERE EXISTS (SELECT 1 FROM @tbPos WHERE cd = c.userId);
        END
        ELSE IF @to_level = 3 -- khách hàng
        BEGIN
            INSERT INTO @tbGr
            SELECT TRY_CAST(part AS nvarchar(50))
            FROM dbo.SplitString(@to_groups, ',');

            INSERT INTO @rt
            SELECT userId = NULL
                  ,c.custId
                  ,c.phone
                  ,c.email
                  ,c.fullName
                  ,''
            FROM MAS_Customers c
            JOIN @tbGr o ON c.CustId = o.Id
            WHERE EXISTS (SELECT 1 FROM @tbGr WHERE id = c.CustId);
        END
        ELSE IF @to_level = 9 -- tùy chọn
        BEGIN
            SET @to_groups = REPLACE(@to_groups,' ',',');
            SET @to_groups = REPLACE(@to_groups,';',',');

            INSERT INTO @rt
            SELECT DISTINCT NULL,NULL,part,NULL,NULL,''
            FROM dbo.SplitString(@to_groups, ',')
            WHERE dbo.fn_check_phone_vn(part) = 1
              AND NOT EXISTS (SELECT 1 FROM @rt x WHERE x.email = part);

            INSERT INTO @rt
            SELECT DISTINCT NULL,NULL,NULL,part,NULL,''
            FROM dbo.SplitString(@to_groups, ',')
            WHERE dbo.fn_check_mail(part) = 1
              AND NOT EXISTS (SELECT 1 FROM @rt x WHERE x.phone = part);
        END
    END
    ELSE -- @to_type = 1 - resident
    BEGIN
        IF @to_level = 1 --- tòa nhà
        BEGIN
           
            INSERT INTO @tbPos
            SELECT part FROM dbo.SplitString(@to_groups, ',');

            INSERT INTO @tbPosOid
            SELECT TRY_CONVERT(UNIQUEIDENTIFIER, part)
            FROM dbo.SplitString(@to_groups, ',')
            WHERE TRY_CONVERT(UNIQUEIDENTIFIER, part) IS NOT NULL;

            -- chủ hộ
            INSERT INTO @rt
            SELECT DISTINCT u.userId
                  ,u.custId
                  ,c.phone
                  ,c.email
                  ,c.fullName
                  ,e.RoomCode
            FROM MAS_Apartments e
            JOIN UserInfo u ON e.UserLogin = u.loginName
            JOIN MAS_Customers c ON c.CustId = u.custId
            WHERE
                (
                    EXISTS (SELECT 1 FROM @tbPos    p WHERE p.cd  = e.buildingCd)   -- legacy buildingCd
                 OR EXISTS (SELECT 1 FROM @tbPosOid o WHERE o.oid = e.buildingOid) -- new buildingOid
                )
              AND NOT EXISTS (SELECT 1 FROM @rt x WHERE x.userId = u.userId);

            -- thành viên
            INSERT INTO @rt
            SELECT DISTINCT m.memberUserId
                  ,u.custId
                  ,u.phone
                  ,u.email
                  ,u.fullName
                  ,e.RoomCode
            FROM MAS_Apartments e
        
            JOIN MAS_Apartment_Member m
                 ON (m.apartOid = e.oid OR (m.apartOid IS NULL AND m.ApartmentId = e.ApartmentId))
                AND m.isNotification = 1
            JOIN MAS_Customers u ON u.CustId = m.CustId
            WHERE
                (
                    EXISTS (SELECT 1 FROM @tbPos    p WHERE p.cd  = e.buildingCd)
                 OR EXISTS (SELECT 1 FROM @tbPosOid o WHERE o.oid = e.buildingOid) 
                )
              AND NOT EXISTS (SELECT 1 FROM @rt x WHERE x.CustId = u.CustId);
        END
        ELSE IF @to_level = 3 -- căn hộ
        BEGIN
            INSERT INTO @tbPos
            SELECT part FROM dbo.SplitString(@to_groups, ',');

           
            INSERT INTO @tbPosOid
            SELECT TRY_CONVERT(UNIQUEIDENTIFIER, part)
            FROM dbo.SplitString(@to_groups, ',')
            WHERE TRY_CONVERT(UNIQUEIDENTIFIER, part) IS NOT NULL; 

         
            INSERT INTO @tbPosInt
            SELECT TRY_CONVERT(INT, part)
            FROM dbo.SplitString(@to_groups, ',')
            WHERE TRY_CONVERT(INT, part) IS NOT NULL; 

            -- căn hộ (chủ hộ)
            INSERT INTO @rt
            SELECT DISTINCT u.userId
                  ,u.custId
                  ,c.phone
                  ,c.email
                  ,c.fullName
                  ,e.RoomCode
            FROM MAS_Apartments e
            JOIN UserInfo u ON e.UserLogin = u.loginName
            JOIN MAS_Customers c ON c.CustId = u.custId
            WHERE
                (
                    EXISTS (SELECT 1 FROM @tbPosInt i WHERE i.id  = e.ApartmentId) -- legacy ApartmentId
                 OR EXISTS (SELECT 1 FROM @tbPosOid o WHERE o.oid = e.oid)        -- new apartOid
                )
              AND NOT EXISTS (SELECT 1 FROM @rt x WHERE x.userId = u.userId);

            -- thành viên
            INSERT INTO @rt
            SELECT DISTINCT m.memberUserId
                  ,u.custId
                  ,u.phone
                  ,u.email
                  ,u.fullName
                  ,e.RoomCode
            FROM MAS_Apartments e
            
            JOIN MAS_Apartment_Member m
                 ON (m.apartOid = e.oid OR (m.apartOid IS NULL AND m.ApartmentId = e.ApartmentId))
                AND m.isNotification = 1
            JOIN MAS_Customers u ON u.CustId = m.CustId
            WHERE
                (
                    EXISTS (SELECT 1 FROM @tbPosInt i WHERE i.id  = e.ApartmentId)
                 OR EXISTS (SELECT 1 FROM @tbPosOid o WHERE o.oid = e.oid)       
                )
              AND NOT EXISTS (SELECT 1 FROM @rt x WHERE x.CustId = u.CustId);
        END
        ELSE IF @to_level = 4 -- người quản lý
        BEGIN
            INSERT INTO @tbPos
            SELECT part FROM dbo.SplitString(@to_groups, ',');

            INSERT INTO @rt
            SELECT DISTINCT c.userId
                  ,c.custId
                  ,c.phone
                  ,c.email
                  ,c.fullName
                  ,''
            FROM Users c
            WHERE EXISTS (SELECT 1 FROM @tbPos WHERE cd = c.userId)
              AND NOT EXISTS (SELECT 1 FROM @rt x WHERE x.userId = c.userId);
        END
        ELSE IF @to_level = 5 -- đối tác
        BEGIN
            INSERT INTO @tbGr
            SELECT TRY_CAST(part AS nvarchar(50))
            FROM dbo.SplitString(@to_groups, ',');

            INSERT INTO @rt
            SELECT DISTINCT u.userId
                  ,c.custId
                  ,c.phone
                  ,c.email
                  ,c.fullName
                  ,''
            FROM MAS_Customers c
            JOIN MAS_Cards e ON c.CustId = e.custId
            JOIN UserInfo u ON c.CustId = u.custId
            JOIN @tbGr o ON c.CustId = o.Id
            WHERE EXISTS (SELECT 1 FROM @tbGr WHERE id = e.partner_id)
              AND NOT EXISTS (SELECT 1 FROM @rt x WHERE x.userId = u.userId);
        END
        ELSE
        BEGIN
            SET @to_groups = REPLACE(@to_groups,' ',',');
            SET @to_groups = REPLACE(@to_groups,';',',');

            INSERT INTO @tbPos
            SELECT part
            FROM dbo.SplitString(@to_groups, ',')
            WHERE dbo.fn_check_phone_vn(part) = 1;

            INSERT INTO @rt
            SELECT DISTINCT NULL,NULL,cd,NULL,NULL,''
            FROM @tbPos p
            WHERE NOT EXISTS (SELECT 1 FROM @rt x WHERE x.email = p.cd);

            INSERT INTO @tbPos
            SELECT part
            FROM dbo.SplitString(@to_groups, ',')
            WHERE dbo.fn_check_mail(part) = 1;

            INSERT INTO @rt
            SELECT DISTINCT NULL,NULL,NULL,cd,NULL,''
            FROM @tbPos p
            WHERE NOT EXISTS (SELECT 1 FROM @rt x WHERE x.phone = p.cd);
        END
    END

    RETURN;
END