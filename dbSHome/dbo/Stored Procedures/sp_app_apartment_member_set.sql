
-- =============================================
-- Author: duongpx
-- Create date: 2025-09-18 09:14:34
-- Description: Tạo/Cập nhật bảng MAS_Apartment_Member
-- =============================================
CREATE PROCEDURE [dbo].[sp_app_apartment_member_set]
     @userId UNIQUEIDENTIFIER = NULL,
     @acceptLanguage NVARCHAR(50) = N'vi-VN',
     @oid UNIQUEIDENTIFIER = NULL,

     @CustId NVARCHAR(50) = NULL,
     @fullName NVARCHAR(150) = NULL,
     @relationName INT = NULL, 
     @birthDay NVARCHAR(50) = NULL,
     @sex BIT = NULL,
     @phone NVARCHAR(50) = NULL,
     @email NVARCHAR(50) = NULL,
	 @avatarUrl NVARCHAR(500) = NULL,
     @ApartmentId INT = NULL,
     @isCheck BIT = NULL
AS
BEGIN TRY
    SET NOCOUNT ON;

    DECLARE @valid BIT = 0;
    DECLARE @messages NVARCHAR(250);
    DECLARE @action NVARCHAR(20);

    -- Nếu tạo mới và chưa có @ApartmentId từ app thì fallback căn hộ chính của user
    IF (@oid IS NULL AND @ApartmentId IS NULL)
    BEGIN
        SET @ApartmentId = ([dbo].[fn_get_apartment_main](dbo.fn_get_customerid(@userId)));
    END

    -- Kiểm tra trùng số điện thoại
    IF ISNULL(LTRIM(RTRIM(@phone)), '') <> ''
    BEGIN
        DECLARE @ExistingCustId NVARCHAR(50) = NULL;
        DECLARE @CurrentCustId NVARCHAR(50) = NULL;

        -- Lấy CustId hiện tại nếu đang UPDATE
        IF @oid IS NOT NULL
        BEGIN
            SELECT TOP 1 @CurrentCustId = b.CustId
            FROM MAS_Apartment_Member b
            WHERE b.Oid = @oid;
        END

        -- Kiểm tra số điện thoại đã tồn tại cho khách hàng khác
        SELECT TOP 1 
            @ExistingCustId = c.CustId
        FROM MAS_Customers c
        INNER JOIN MAS_Apartment_Member b 
            ON b.CustId = c.CustId
        WHERE c.Phone = @phone
          AND b.member_st = 0          -- chỉ kiểm tra thành viên chờ duyệt
          AND (@CurrentCustId IS NULL OR c.CustId <> @CurrentCustId);

        IF @ExistingCustId IS NOT NULL
        BEGIN
            SET @valid = 0;
            SET @messages = N'Số điện thoại đã được sử dụng bởi thành viên chờ duyệt khác';
            SELECT 
                @valid AS valid, 
                @messages AS [messages],
                @oid AS id,
                N'ERROR' AS action;
            RETURN;
        END
    END

    -- =============================================
    -- UPDATE
    -- =============================================
    IF EXISTS (SELECT 1 FROM MAS_Apartment_Member WHERE Oid = @oid)
    BEGIN
        SET @action = N'UPDATE';

        -- Update member
        UPDATE b
        SET b.RelationId = @relationName
        FROM MAS_Apartment_Member b
        WHERE b.Oid = @oid;

        -- Update customer
        UPDATE c
        SET c.FullName = @fullName,
            c.Birthday = TRY_CONVERT(DATE, @birthDay, 103),
            c.Phone = @phone,
            c.Email = @email,
            c.IsSex = ISNULL(@sex, c.IsSex),
            c.Auth_St = ISNULL(@isCheck, c.Auth_St),
			c.AvatarUrl = ISNULL(@avatarUrl, c.AvatarUrl)
        FROM MAS_Customers c
        INNER JOIN MAS_Apartment_Member b ON c.CustId = b.CustId
        WHERE b.Oid = @oid;

        -- Update UserInfo (giới tính chủ hộ)
        UPDATE u
        SET u.Sex = @sex
        FROM UserInfo u
        INNER JOIN MAS_Apartments ap ON ap.UserLogin = u.loginName
        INNER JOIN MAS_Apartment_Member b ON b.ApartmentId = ap.ApartmentId
        WHERE b.Oid = @oid;

        SET @valid = 1;
        SET @messages = N'Cập nhật thành công';
    END
    ELSE
    BEGIN
        -- =============================================
        -- INSERT
        -- =============================================
        SET @action = N'INSERT';

        IF (@CustId IS NULL OR @CustId = N'') OR NOT EXISTS(SELECT 1 FROM [dbo].[MAS_Customers] WHERE CustId = @CustId)
        BEGIN
            SET @CustId = CONVERT(NVARCHAR(50), NEWID());

             INSERT INTO [dbo].[MAS_Customers]
                   ([FullName]
                   ,[Phone]
                   ,[Email]
                   ,[IsHost]
                   ,[ApartmentId]
                   ,[IsSex]
                   ,[birthday]
                   ,[Auth_St]
                   ,[sysDate]
                   ,[CustId]
                   ,[AvatarUrl])
            VALUES
                   (@fullName
                   ,@phone
                   ,@email
                   ,0
                   ,@ApartmentId
                   ,@sex
                   ,TRY_CONVERT(date,@birthDay,103)
                   ,@isCheck
                   ,GETDATE()
                   ,@CustId
                   ,@avatarUrl);
        END

        SET @oid = NEWID();

        INSERT INTO [dbo].[MAS_Apartment_Member] (
             Oid
            ,ApartmentId
            ,CustId
            ,RelationId
            ,memberUserId
            ,main_st
            ,member_st
            ,RegDt
        )
        VALUES (
             @oid
            --,([dbo].[fn_get_apartment_main](dbo.fn_get_customerid(@userId)))
            ,@ApartmentId
            ,@CustId
            ,ISNULL(@RelationName, 0)
            ,@userId
            ,0   -- không phải chủ hộ
            ,0   -- trạng thái khởi tạo/pending
            ,GETDATE()
        );

        SET @valid = 1;
        SET @messages = N'Thêm mới thành công';
    END
    -- =============================================
    -- RESULT - Trả về kết quả
    -- =============================================
    SELECT 
        @valid AS valid, 
        @messages AS [messages],
        @oid AS id,
        @action AS action;

END TRY
BEGIN CATCH
    DECLARE @ErrorNum INT, @ErrorMsg VARCHAR(200), @ErrorProc VARCHAR(50),
            @SessionID INT, @AddlInfo VARCHAR(MAX);
    SET @ErrorNum = ERROR_NUMBER();
    SET @ErrorMsg = ERROR_MESSAGE();
    SET @ErrorProc= ERROR_PROCEDURE();
    SET @AddlInfo =  N', @id: ' + ISNULL(CAST(@oid AS NVARCHAR(50)), N'NULL');
    EXEC utl_errorlog_set @ErrorNum, @ErrorMsg, @ErrorProc, N'MAS_Apartment_Member', N'SET', @SessionID, @AddlInfo;
    
    -- Trả về lỗi
    SELECT 
        0 AS valid, 
        N'Lỗi: ' + ERROR_MESSAGE() AS [messages],
        @oid AS id,
        N'ERROR' AS action;
END CATCH