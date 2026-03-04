
CREATE PROCEDURE [dbo].[sp_res_apartment_home_member_approve]
    @UserID NVARCHAR(450),
    @apartmentId BIGINT,
    @CustId NVARCHAR(50),
    @memberUserId NVARCHAR(100)
AS
BEGIN TRY
    DECLARE @valid BIT = 1;
    DECLARE @messages NVARCHAR(200);
    DECLARE @notification BIT = 1;
    DECLARE @notimessage NVARCHAR(300);
    DECLARE @user_type INT = 1; --userType = 0 (Khách) userType = 1 (Cư dân), userType = 2 Bên hỗ trợ, cung cấp dịch vụ
    DECLARE @existingCustId NVARCHAR(50);

    IF dbo.[fn_Hom_User_admin](@userId) = 1
        OR EXISTS (
            SELECT TOP 1 ApartmentId
            FROM [dbo].[fn_Hom_User_Apartment](@userId) ua
            WHERE IsHost = 1
        )
    BEGIN
        ---------------------------------------------------------
        -- PHÊ DUYỆT THÀNH VIÊN
        ---------------------------------------------------------
        IF @CustId IS NOT NULL
            AND @CustId <> ''
            AND EXISTS (
                SELECT am.custid
                FROM MAS_Apartment_Member am
                JOIN MAS_Customers cc
                    ON am.CustId = cc.CustId
                WHERE am.ApartmentId = @apartmentId
                    AND am.CustId = @CustId
            )
        BEGIN
            UPDATE t1
            SET member_st = 1,
                approveDt = GETDATE(),
                approveBy = @UserID,
                memberUserId = @memberUserId
            FROM MAS_Apartment_Member t1
            WHERE t1.CustId = @CustId
                AND t1.ApartmentId = @apartmentId;

            UPDATE t
            SET [Cif_No]    = ISNULL(t.Cif_No, u.cif_no),
                [FullName]  = ISNULL(t.FullName, u.fullName),
                [AvatarUrl] = ISNULL(t.AvatarUrl, u.avatarUrl),
                [IsSex]     = ISNULL(t.IsSex, u.sex),
                [Birthday]  = ISNULL(t.Birthday, u.birthday),
                [Phone]     = u.phone,
                [Email]     = ISNULL(t.Email, u.email),
                [Pass_No]   = ISNULL(t.Pass_No, u.idcard_no),
                [Pass_Dt]   = ISNULL(t.Pass_Dt, u.idcard_Issue_Dt),
                [Pass_Plc]  = ISNULL(t.Pass_Plc, u.idcard_Issue_Plc),
                [Address]   = ISNULL(t.Address, u.res_Add),
                [ProvinceCd]= ISNULL(t.ProvinceCd, u.res_City),
                [IsForeign] = ISNULL(t.IsForeign, CASE
                    WHEN u.res_Cntry IS NULL OR u.res_Cntry = 'VN' THEN 0
                    ELSE 1
                END),
                [CountryCd] = ISNULL(t.CountryCd, u.res_Cntry)
            FROM [dbo].[MAS_Customers] t
            JOIN UserInfo u
                ON t.custId = u.custId
            WHERE u.userId = @memberUserId;

            UPDATE t
            SET custId = @CustId,
                cif_no = ISNULL(cif_no, (
                    SELECT TOP 1 cif_no
                    FROM [MAS_Customers]
                    WHERE custId = @CustId
                )),
                userType = @user_type
            FROM UserInfo t
            WHERE t.userId = @memberUserId;

            UPDATE t
            SET reg_st = 1
            FROM MAS_Apartment_Reg t
            JOIN MAS_Apartments c
                ON t.roomCode = c.RoomCode
            WHERE t.userId = @memberUserId
                AND c.ApartmentId = @apartmentId;

            PRINT '=========1=========';
        END
        ELSE
        BEGIN
            IF NOT EXISTS (
                SELECT userid
                FROM UserInfo u
                JOIN MAS_Customers c
                    ON u.custId = c.CustId
                WHERE u.userId = @memberUserId
            )
            BEGIN
                IF (@CustId IS NULL OR @CustId = '')
                BEGIN
                    -- Nếu đã tồn tại khách hàng với cùng số điện thoại thì tái sử dụng CustId đó
                    SELECT TOP 1 @existingCustId = c.CustId
                    FROM MAS_Customers c
                    WHERE c.Phone = (
                        SELECT TOP 1 t.phone 
                        FROM dbSHome.dbo.UserInfo t
                        WHERE t.userId = @memberUserId
                    );

                    IF @existingCustId IS NOT NULL
                        SET @CustId = @existingCustId;
                    ELSE
                        SET @CustId = NEWID();
                END;

                UPDATE t
                SET custId = @CustId,
                    userType = @user_type
                FROM UserInfo t
                WHERE t.userId = @memberUserId;

                IF @existingCustId IS NULL
                BEGIN
                    INSERT INTO [dbo].[MAS_Customers] (
                        [CustId],
                        [Cif_No],
                        [FullName],
                        [AvatarUrl],
                        [IsSex],
                        [Birthday],
                        [Phone],
                        [Email],
                        [Pass_No],
                        [Pass_Dt],
                        [Pass_Plc],
                        [Address],
                        [ProvinceCd],
                        [IsForeign],
                        [CountryCd]
                    )
                    SELECT a.custId,
                        a.cif_no,
                        a.fullName,
                        a.avatarUrl,
                        a.sex,
                        a.birthday,
                        a.phone,
                        a.email,
                        a.idcard_No,
                        a.idcard_Issue_Dt,
                        a.idcard_Issue_Plc,
                        a.res_Add,
                        a.res_City,
                        CASE
                            WHEN a.res_Cntry IS NULL OR a.res_Cntry = 'VN' THEN 0
                            ELSE 1
                        END,
                        a.res_Cntry
                    FROM UserInfo a
                    WHERE a.userId = @memberUserId;
                END;

                PRINT '=========2=========';
            END
            ELSE
            BEGIN
                UPDATE t
                SET [Cif_No]    = ISNULL(t.Cif_No, u.cif_no),
                    [FullName]  = ISNULL(t.FullName, u.fullName),
                    [AvatarUrl] = ISNULL(t.AvatarUrl, u.avatarUrl),
                    [IsSex]     = ISNULL(t.IsSex, u.sex),
                    [Birthday]  = ISNULL(t.Birthday, u.birthday),
                    [Phone]     = ISNULL(t.Phone, u.phone),
                    [Email]     = ISNULL(t.Email, u.email),
                    [Pass_No]   = ISNULL(t.Pass_No, u.idcard_no),
                    [Pass_Dt]   = ISNULL(t.Pass_Dt, u.idcard_Issue_Dt),
                    [Pass_Plc]  = ISNULL(t.Pass_Plc, u.idcard_Issue_Plc),
                    [Address]   = ISNULL(t.Address, u.res_Add),
                    [ProvinceCd]= ISNULL(t.ProvinceCd, u.res_City),
                    [IsForeign] = ISNULL(t.IsForeign, CASE
                        WHEN u.res_Cntry IS NULL OR u.res_Cntry = 'VN' THEN 0
                        ELSE 1
                    END),
                    [CountryCd] = ISNULL(t.CountryCd, u.res_Cntry)
                FROM [dbo].[MAS_Customers] t
                JOIN UserInfo u
                    ON t.custId = u.custId
                WHERE u.userId = @memberUserId;

                PRINT '=========3=========';
            END

            INSERT INTO [dbo].[MAS_Apartment_Member] (
                [ApartmentId],
                [CustId],
                [RegDt],
                [RelationId],
                memberUserId,
                [member_st],
                [approveBy],
                [approveDt]
            )
            SELECT c.ApartmentId,
                u.CustId,
                a.reg_dt,
                a.relationId,
                a.userId,
                1,
                @memberUserId,
                GETDATE()
            FROM MAS_Apartment_Reg a
            JOIN UserInfo u
                ON a.userId = u.userId
            JOIN MAS_Apartments c
                ON a.roomCode = c.RoomCode
            WHERE a.userId = @memberUserId
                AND c.ApartmentId = @apartmentId
                AND NOT EXISTS (
                    SELECT ApartmentId
                    FROM [MAS_Apartment_Member] t
                    WHERE t.ApartmentId = c.ApartmentId
                        AND t.CustId = u.custid
                );

            UPDATE t
            SET reg_st = 1
            FROM MAS_Apartment_Reg t
            JOIN MAS_Apartments c
                ON t.roomCode = c.RoomCode
            WHERE t.userId = @memberUserId
                AND c.ApartmentId = @apartmentId;

            UPDATE t
            SET userType = @user_type
            FROM UserInfo t
            WHERE t.userId = @memberUserId;

            PRINT '=========4=========';
        END
    END
    ELSE
    BEGIN
        SET @valid = 0;
        SET @messages = N'Bạn không có quyền phê duyệt';
        SET @notification = 0;
    END

    SELECT @valid AS valid,
           @messages AS [messages],
           @notification AS notiQue;

    IF @notification = 1
    BEGIN
        SELECT N'Xác nhận duyệt thành viên cư dân - Apartment Approved' AS [subject],
            N's-resident' AS external_key, --[Event]
            N'Quý Khách hàng đã được duyệt thành viên cư dân.' + N' Mã căn hộ [' + a.RoomCode + N'], Dự án ' + b.ProjectName + N' Trân trọng' AS content_notify,
            NULL AS content_email, --[MessageEmail]
            'push' AS [action_list], --sms,email
            'new' AS [status],
            a.projectCd AS external_sub,
            [mailSender] AS send_by,
            [investorName] AS send_name
        FROM MAS_Apartments a
        JOIN MAS_Projects b
            ON a.sub_projectCd = b.sub_projectCd,
            UserInfo u
        WHERE a.ApartmentId = @apartmentId
            AND u.userid = @memberUserId;

        SELECT b.memberUserId userId,
            phone,
            email,
            avatarUrl AS Avatar,
            fullName,
            a.custId,
            1 AS app
        FROM UserInfo a
        JOIN dbSHome.dbo.MAS_Apartment_Member b
            ON a.custId = b.CustId
        WHERE b.ApartmentId = @apartmentId
            AND b.member_st = 1
            AND b.memberUserId IS NOT NULL;
    END
END TRY
BEGIN CATCH
    DECLARE @ErrorNum INT,
            @ErrorMsg VARCHAR(200),
            @ErrorProc VARCHAR(50),
            @SessionID INT,
            @AddlInfo VARCHAR(MAX);
    SET @ErrorNum = ERROR_NUMBER();
    SET @ErrorMsg = 'sp_Hom_Apartment_Member_Approve ' + ERROR_MESSAGE();
    SET @ErrorProc = ERROR_PROCEDURE();
    SET @AddlInfo = '@UserID ' + @UserID;
    SET @valid = 0;
    SET @messages = ERROR_MESSAGE();
    EXEC utl_Insert_ErrorLog @ErrorNum,
        @ErrorMsg,
        @ErrorProc,
        'Member',
        'Set',
        @SessionID,
        @AddlInfo;

    SELECT @valid AS valid,
           @messages AS [messages];
END CATCH;