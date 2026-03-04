CREATE PROCEDURE [dbo].[sp_res_apartment_change_host_set]
     @userId NVARCHAR(450) = NULL,
	@fullnameChangeHost NVARCHAR(250) = NULL,
	@Id NVARCHAR(250),
    @ApartmentId INT,
	@CustId NVARCHAR(50),
	@UserLogin NVARCHAR(100),
	@ContractRemark NVARCHAR(300),
	@ContractDate NVARCHAR(20),
	@acceptLanguage NVARCHAR(50) = 'vi-VN',
    @Phone NVARCHAR(30) = NULL,
    @Email NVARCHAR(150) = NULL,
    @AvatarUrl NVARCHAR(250) = NULL,
    @Birthday NVARCHAR(10) = NULL,
    @IsSex BIT = 0,
    @RelationId INT = 0,
    @IsForeign BIT = 0,
    @IsNotification BIT = 0,
    @CountryCd NVARCHAR(50) = 'VN',
	@cifNo NVARCHAR(50) = NULL,
    @EffectiveDate NVARCHAR(50) = NULL,
    @note NVARCHAR(MAX) = NULL,
    @householdHead NVARCHAR(150) = NULL
AS	
BEGIN TRY
    SET NOCOUNT ON;

    -- =====================================
    -- 1. Declare variables
    -- =====================================
    DECLARE @valid BIT = 0, @messages NVARCHAR(250) = N'Có lỗi xảy ra';
    DECLARE @EffDate DATE = CASE WHEN ISNULL(LTRIM(RTRIM(@EffectiveDate)), '') <> '' THEN CONVERT(DATE, @EffectiveDate, 103) ELSE CONVERT(DATE, @ContractDate, 103) END;
    DECLARE @OldCustId NVARCHAR(50), @OldApproveDt DATETIME, @OldMemberSt INT;
    DECLARE @HistoryPerformedAt DATETIME = GETDATE();
    DECLARE @NormalizedUserLogin NVARCHAR(100);
    DECLARE @OldHostOid UNIQUEIDENTIFIER, @OldHostMemberOid UNIQUEIDENTIFIER, @NewHostOid UNIQUEIDENTIFIER, @NewHostMemberOid UNIQUEIDENTIFIER;
    DECLARE @NewHostPrevRelationId INT, @NewHostOriginalApproveDt DATETIME;
    DECLARE @OldFullName NVARCHAR(200), @OldPhone NVARCHAR(50), @OldEmail NVARCHAR(150), @OldBirthday DATETIME, @OldIsSex BIT, @OldCountryCd NVARCHAR(50), @OldIsForeign BIT, @OldRelationName NVARCHAR(100);
    DECLARE @NewFullName NVARCHAR(200), @NewPhone NVARCHAR(50), @NewEmail NVARCHAR(150), @NewBirthday DATETIME, @NewIsSex BIT, @NewCountryCd NVARCHAR(50), @NewRelationName NVARCHAR(100);
    DECLARE @HostFullNameAtTime NVARCHAR(200), @UserLoginForHistory NVARCHAR(100);
    DECLARE @OldHostNote NVARCHAR(200) = N'Thay đổi chủ hộ';
    DECLARE @OldHostDemotedRelationId INT = 14;

    -- =====================================
    -- 2. Normalize UserLogin
    -- =====================================
    IF @UserLogin IS NOT NULL AND LTRIM(RTRIM(@UserLogin)) <> ''
        SET @NormalizedUserLogin = CASE WHEN LEFT(LTRIM(RTRIM(@UserLogin)), 8) = 'ssupapp_' THEN LTRIM(RTRIM(@UserLogin)) ELSE 'ssupapp_' + LTRIM(RTRIM(@UserLogin)) END;
    ELSE
    BEGIN
        SELECT TOP 1 @NormalizedUserLogin = CASE WHEN LEFT(loginName, 8) = 'ssupapp_' THEN loginName ELSE 'ssupapp_' + loginName END
        FROM UserInfo WITH (NOLOCK) WHERE CustId = @CustId ORDER BY created_dt DESC, reg_userId DESC;
    END
    IF @NormalizedUserLogin IS NULL SET @NormalizedUserLogin = ISNULL('ssupapp_' + LTRIM(RTRIM(@Phone)), 'ssupapp_' + REPLACE(CONVERT(NVARCHAR(32), @CustId), '-', ''));

    -- =====================================
    -- 3. Get basic information
    -- =====================================
    SELECT TOP 1 @UserLoginForHistory = loginName FROM UserInfo WITH (NOLOCK) WHERE userId = @userId;
    SELECT TOP 1 @HostFullNameAtTime = c.FullName
    FROM MAS_Apartment_Member am WITH (NOLOCK)
    LEFT JOIN MAS_Customers c WITH (NOLOCK) ON c.CustId = am.CustId
    WHERE am.ApartmentId = @ApartmentId AND am.RelationId = 0
    ORDER BY ISNULL(am.approveDt, am.RegDt) DESC;

    -- =====================================
    -- 4. Save apartment history
    -- =====================================
    INSERT INTO [dbo].[MAS_Apartments_Save]
        ([ApartmentId],[RoomCode],[Cif_No],[FamilyImageUrl],[StartDt],[EndDt],[IsClose],[CloseDt],[IsLock],[IsReceived],[ReceiveDt],[IsRent],[UserLogin],[lastReceived],[ContractRemark],[ContractDt],[SaveDt],[saveKey],[saveBy])
    SELECT [ApartmentId],[RoomCode],[Cif_No],[FamilyImageUrl],[StartDt],[EndDt],[IsClose],[CloseDt],[IsLock],[IsReceived],[ReceiveDt],[IsRent],COALESCE(@NormalizedUserLogin, [UserLogin]),[lastReceived],@ContractRemark,convert(date,@ContractDate,103),getdate(),'ChangeHost',@userId
    FROM [dbo].[MAS_Apartments] WITH (NOLOCK) WHERE ApartmentId = @ApartmentId;

    -- =====================================
    -- 5. Update customer information
    -- =====================================
    UPDATE [dbo].[MAS_Customers] 
    SET Phone = ISNULL(@Phone, Phone), 
        Email = ISNULL(@Email, Email), 
        AvatarUrl = ISNULL(@AvatarUrl, AvatarUrl), 
        IsSex = ISNULL(@IsSex, IsSex), 
        Birthday = CASE WHEN @Birthday IS NULL THEN Birthday ELSE CONVERT(DATETIME, @Birthday, 103) END, 
        IsForeign = @IsForeign, 
        CountryCd = @CountryCd 
    WHERE CustId = @CustId;
    
    UPDATE t1 
    SET UserLogin = COALESCE(@NormalizedUserLogin, UserLogin), 
        Cif_No = (SELECT TOP 1 Cif_No FROM MAS_Customers WITH (NOLOCK) WHERE CustId = @CustId) 
    FROM MAS_Apartments t1 
    WHERE t1.ApartmentId = @ApartmentId;

    -- =====================================
    -- 6. Get current host information
    -- =====================================
    SELECT TOP 1 @OldCustId = am.CustId, @OldApproveDt = am.approveDt, @OldMemberSt = am.member_st
    FROM dbo.MAS_Apartment_Member am WITH (NOLOCK) 
    WHERE am.ApartmentId = @ApartmentId AND am.RelationId = 0;
		
    -- =====================================
    -- 7. Validate: Check current host status
    -- =====================================
    IF @OldCustId IS NOT NULL AND @OldCustId <> @CustId AND (@OldMemberSt = 0 OR @OldMemberSt IS NULL)
    BEGIN
        SET @valid = 0; 
        SET @messages = N'Trạng thái chủ hộ hiện tại đang chờ duyệt, không thể cập nhật chủ hộ';
        SELECT @valid AS valid, @messages AS [messages]; 
        RETURN;
    END
		
    -- =====================================
    -- 8. Validate: Check pending members
    -- =====================================
    IF EXISTS (SELECT 1 FROM dbo.MAS_Apartment_Member am WITH (NOLOCK) WHERE am.ApartmentId = @ApartmentId AND (am.member_st = 0 OR am.member_st IS NULL))
    BEGIN
        DECLARE @PendingMemberName NVARCHAR(250);
        SELECT TOP 1 @PendingMemberName = c.FullName 
        FROM dbo.MAS_Apartment_Member am WITH (NOLOCK) 
        LEFT JOIN dbo.MAS_Customers c WITH (NOLOCK) ON c.CustId = am.CustId 
        WHERE am.ApartmentId = @ApartmentId AND (am.member_st = 0 OR am.member_st IS NULL) 
        ORDER BY am.CustId;
        SET @valid = 0; 
        SET @messages = N'Có thành viên đang ở trạng thái chờ phê duyệt' + ISNULL(N' (' + @PendingMemberName + N')', N'') + N', không thể chuyển chủ hộ';
        SELECT @valid AS valid, @messages AS [messages]; 
        RETURN;
    END
		
    -- =====================================
    -- 9. Get old host information
    -- =====================================
    IF @OldCustId IS NOT NULL
    BEGIN
        SELECT TOP 1 @OldIsForeign = ISNULL(IsForeign,0), @OldFullName = FullName, @OldPhone = Phone, @OldEmail = Email, @OldBirthday = Birthday, @OldIsSex = IsSex, @OldCountryCd = CountryCd
        FROM dbo.MAS_Customers WITH (NOLOCK) WHERE CustId = @OldCustId;
        SELECT TOP 1 @OldRelationName = r.RelationName 
        FROM MAS_Apartment_Member am WITH (NOLOCK) 
        LEFT JOIN MAS_Customer_Relation r WITH (NOLOCK) ON r.RelationId = am.RelationId 
        WHERE am.ApartmentId = @ApartmentId AND am.CustId = @OldCustId;
        SELECT TOP 1 @OldHostOid = h.Oid 
        FROM MAS_Apartment_Member_H h WITH (NOLOCK) 
        WHERE h.ApartmentId = @ApartmentId AND h.CustId = @OldCustId 
        ORDER BY h.PerformedAt DESC, h.Oid DESC;
    END

    DECLARE @NewHostNote NVARCHAR(MAX) = COALESCE(NULLIF(LTRIM(RTRIM(@note)), N''), NULLIF(LTRIM(RTRIM(@ContractRemark)), N''), CASE WHEN @OldCustId = @CustId THEN N'Cập nhật chủ hộ' ELSE @OldHostNote END);

    -- =====================================
    -- 10. Validate: Check effective date
    -- =====================================
    IF @OldCustId IS NOT NULL AND @OldCustId <> @CustId AND @OldApproveDt IS NOT NULL AND @EffDate <= @OldApproveDt
    BEGIN
        SET @valid = 0; 
        SET @messages = N'Ngày hiệu lực của chủ hộ mới phải lớn hơn ngày hiệu lực hiện tại (' + CONVERT(NVARCHAR(10), @OldApproveDt, 103) + N').';
        SELECT @valid AS valid, @messages AS [messages]; 
        RETURN;
    END

    -- =====================================
    -- 11. Get new host information
    -- =====================================
    SELECT TOP 1 @NewFullName = FullName, @NewPhone = Phone, @NewEmail = Email, @NewBirthday = Birthday, @NewIsSex = IsSex, @NewCountryCd = CountryCd 
    FROM dbo.MAS_Customers WITH (NOLOCK) WHERE CustId = @CustId;
    SELECT TOP 1 @NewRelationName = r.RelationName 
    FROM MAS_Apartment_Member am WITH (NOLOCK) 
    LEFT JOIN MAS_Customer_Relation r WITH (NOLOCK) ON r.RelationId = am.RelationId 
    WHERE am.ApartmentId = @ApartmentId AND am.CustId = @CustId;

    -- =====================================
    -- 12. Process old host history (end as host)
    -- =====================================
    IF @OldCustId IS NOT NULL AND @OldCustId <> @CustId
    BEGIN
        IF @OldHostOid IS NOT NULL
            UPDATE MAS_Apartment_Member_H 
            SET OldCustId = @OldCustId, NewCustId = @CustId, member_st = ISNULL(@OldMemberSt, 1), RelationId = 0, RelationName = @OldRelationName, 
                IsForeign = ISNULL(@OldIsForeign, 0), CountryCd = @OldCountryCd, 
                FullName = @OldFullName, Phone = @OldPhone, Email = @OldEmail, Birthday = @OldBirthday, IsSex = @OldIsSex, 
                HostFullName = @HostFullNameAtTime, 
                ApproveDt = @OldApproveDt, ApproveDtEnd = DATEADD(DAY, -1, @EffDate), 
                EffectiveDate = CONVERT(DATE, @OldApproveDt), ExpiredDate = DATEADD(DAY, -1, @EffDate), Note = @OldHostNote, 
                PerformedByUserId = @userId, PerformedAt = @HistoryPerformedAt, 
                CustId = @OldCustId, CreatedBy = @userId, CreatedDate = GETDATE() 
            WHERE Oid = @OldHostOid;
        ELSE
        BEGIN
            INSERT INTO [dbo].[MAS_Apartment_Member_H] 
                ([Oid],[ApartmentId],[CustId],[OldCustId],[NewCustId],[FullName],[Phone],[Email],[Birthday],[IsSex],
                 [RelationId],[RelationName],[IsForeign],[CountryCd],[HostFullName],
                 [ApproveDt],[ApproveDtEnd],[EffectiveDate],[ExpiredDate],[member_st],[Note],
                 [PerformedByUserId],[PerformedAt],[CreatedBy],[CreatedDate])
            VALUES 
                (NEWID(),@ApartmentId,@OldCustId,@OldCustId,@CustId,@OldFullName,@OldPhone,@OldEmail,@OldBirthday,@OldIsSex,
                 0,@OldRelationName,ISNULL(@OldIsForeign,0),@OldCountryCd,@HostFullNameAtTime,
                 @OldApproveDt,DATEADD(DAY,-1,@EffDate),CONVERT(DATE, @OldApproveDt),
                 DATEADD(DAY,-1,@EffDate),ISNULL(@OldMemberSt, 1),@OldHostNote,
                 @userId,@HistoryPerformedAt,@userId,GETDATE());
            SELECT TOP 1 @OldHostOid = h.Oid 
            FROM MAS_Apartment_Member_H h WITH (NOLOCK) 
            WHERE h.ApartmentId = @ApartmentId AND h.CustId = @OldCustId 
            ORDER BY h.PerformedAt DESC, h.Oid DESC;
        END

        -- =====================================
        -- 13. Process old host history (become member)
        -- =====================================
        SELECT TOP 1 @OldHostMemberOid = h.Oid 
        FROM MAS_Apartment_Member_H h WITH (NOLOCK) 
        WHERE h.ApartmentId = @ApartmentId AND h.CustId = @OldCustId AND (@OldHostOid IS NULL OR h.Oid <> @OldHostOid) 
        ORDER BY h.PerformedAt DESC, h.Oid DESC;
        
        IF @OldHostMemberOid IS NOT NULL
            UPDATE MAS_Apartment_Member_H 
            SET OldCustId = @OldCustId, NewCustId = @OldCustId, member_st = ISNULL(@OldMemberSt, 1), RelationId = @OldHostDemotedRelationId, 
                RelationName = (SELECT TOP 1 RelationName FROM MAS_Customer_Relation WITH (NOLOCK) WHERE RelationId = @OldHostDemotedRelationId), 
                IsForeign = ISNULL(@OldIsForeign,0), CountryCd = @OldCountryCd, 
                FullName = @OldFullName, Phone = @OldPhone, Email = @OldEmail, Birthday = @OldBirthday, IsSex = @OldIsSex, 
                HostFullName = @HostFullNameAtTime, ApproveDt = @EffDate, ApproveDtEnd = NULL, 
                EffectiveDate = @EffDate, ExpiredDate = NULL, Note = N'Thành viên', 
                PerformedByUserId = @userId, PerformedAt = DATEADD(MILLISECOND, 2, @HistoryPerformedAt), 
                CustId = @OldCustId, CreatedBy = @userId, CreatedDate = GETDATE() 
            WHERE Oid = @OldHostMemberOid;
        ELSE
            INSERT INTO [dbo].[MAS_Apartment_Member_H] 
                ([Oid],[ApartmentId],[CustId],[OldCustId],[NewCustId],[FullName],[Phone],[Email],[Birthday],[IsSex],
                 [RelationId],[RelationName],[IsForeign],[CountryCd],[HostFullName],
                 [ApproveDt],[ApproveDtEnd],[EffectiveDate],[ExpiredDate],[member_st],[Note],
                 [PerformedByUserId],[PerformedAt],[CreatedBy],[CreatedDate])
            VALUES 
                (NEWID(),@ApartmentId,@OldCustId,@OldCustId,@OldCustId,@OldFullName,@OldPhone,@OldEmail,@OldBirthday,@OldIsSex,
                 @OldHostDemotedRelationId,
                 (SELECT TOP 1 RelationName FROM MAS_Customer_Relation WITH (NOLOCK) WHERE RelationId = @OldHostDemotedRelationId),
                 ISNULL(@OldIsForeign,0),@OldCountryCd,@HostFullNameAtTime,
                 @EffDate,NULL,@EffDate,NULL,ISNULL(@OldMemberSt, 1),N'Thành viên',
                 @userId,DATEADD(MILLISECOND, 2, @HistoryPerformedAt),@userId,GETDATE());
    END

    -- =====================================
    -- 14. Update old host relation
    -- =====================================
    UPDATE t1 
    SET memberUserId = (SELECT TOP 1 userId FROM UserInfo WITH (NOLOCK) WHERE loginName = @NormalizedUserLogin), 
        member_st = 1, 
        RelationId = @OldHostDemotedRelationId 
    FROM MAS_Apartment_Member t1 
    WHERE t1.ApartmentId = @ApartmentId AND RelationId = 0;

    -- =====================================
    -- 15. Get new host previous information
    -- =====================================
    IF @OldCustId IS NOT NULL AND @OldCustId <> @CustId
    BEGIN
        SELECT TOP 1 @NewHostPrevRelationId = am.RelationId 
        FROM MAS_Apartment_Member am WITH (NOLOCK) 
        WHERE am.ApartmentId = @ApartmentId AND am.CustId = @CustId;
        SELECT TOP 1 @NewHostOriginalApproveDt = h.ApproveDt 
        FROM MAS_Apartment_Member_H h WITH (NOLOCK) 
        WHERE h.ApartmentId = @ApartmentId AND h.CustId = @CustId 
        ORDER BY h.ApproveDt ASC, h.PerformedAt ASC, h.Oid ASC;
        IF @NewHostOriginalApproveDt IS NULL 
            SELECT TOP 1 @NewHostOriginalApproveDt = am.approveDt 
            FROM MAS_Apartment_Member am WITH (NOLOCK) 
            WHERE am.ApartmentId = @ApartmentId AND am.CustId = @CustId;
    END

    -- =====================================
    -- 16. Update new host member history (before becoming host)
    -- =====================================
    UPDATE hist 
    SET ApproveDtEnd = DATEADD(DAY, -1, @EffDate), 
        ExpiredDate = DATEADD(DAY, -1, @EffDate), 
        Note = N'Thành viên' 
    FROM MAS_Apartment_Member_H hist 
    WHERE hist.ApartmentId = @ApartmentId AND hist.CustId = @CustId 
      AND hist.ApproveDtEnd IS NULL AND CONVERT(DATE, hist.ApproveDt) < @EffDate;
    
    -- =====================================
    -- 17. Update new host relation
    -- =====================================
    UPDATE t1 
    SET memberUserId = (SELECT TOP 1 userId FROM UserInfo WITH (NOLOCK) WHERE loginName = @NormalizedUserLogin), 
        member_st = 1, 
        RelationId = 0, 
        approveDt = @EffDate, 
        isNotification = 1 
    FROM MAS_Apartment_Member t1 
    WHERE t1.ApartmentId = @ApartmentId AND CustId = @CustId;

    -- =====================================
    -- 18. Process UserInfo
    -- =====================================
    IF @NormalizedUserLogin IS NOT NULL AND NOT EXISTS (SELECT 1 FROM dbo.UserInfo WITH (NOLOCK) WHERE loginName = @NormalizedUserLogin)
        INSERT INTO [dbo].[UserInfo] 
            ([CustId],userId,loginName,lock_st,created_dt,[FullName],[Phone],[Email]) 
        VALUES 
            (@CustId,NEWID(),@NormalizedUserLogin,0,GETDATE(),
             (SELECT TOP 1 Fullname FROM dbo.MAS_Customers WITH (NOLOCK) WHERE CustId = @CustId),
             (SELECT TOP 1 phone FROM dbo.MAS_Customers WITH (NOLOCK) WHERE CustId = @CustId),
             (SELECT TOP 1 Email FROM dbo.MAS_Customers WITH (NOLOCK) WHERE CustId = @CustId));
    ELSE IF @NormalizedUserLogin IS NOT NULL 
        UPDATE dbo.UserInfo SET custId = @CustId WHERE loginName = @NormalizedUserLogin;
		
    -- =====================================
    -- 19. Process new host history (become host)
    -- =====================================
    SELECT TOP 1 @NewHostOid = h.Oid 
    FROM MAS_Apartment_Member_H h WITH (NOLOCK) 
    WHERE h.ApartmentId = @ApartmentId AND h.CustId = @CustId 
    ORDER BY h.PerformedAt DESC, h.Oid DESC;
    
    IF @NewHostOid IS NOT NULL
        UPDATE MAS_Apartment_Member_H 
        SET OldCustId = ISNULL(@OldCustId, @CustId), NewCustId = @CustId, RelationId = 0, RelationName = @NewRelationName, 
            IsForeign = @IsForeign, CountryCd = @NewCountryCd, 
            FullName = @NewFullName, Phone = @NewPhone, Email = @NewEmail, Birthday = @NewBirthday, IsSex = @NewIsSex, 
            HostFullName = @HostFullNameAtTime, 
            member_st = 1, ApproveDt = @EffDate, ApproveDtEnd = NULL, EffectiveDate = @EffDate, 
            ExpiredDate = NULL, Note = @NewHostNote, 
            PerformedByUserId = @userId, PerformedAt = DATEADD(MILLISECOND, 1, @HistoryPerformedAt), CustId = @CustId, 
            CreatedBy = @userId, CreatedDate = GETDATE() 
        WHERE Oid = @NewHostOid;
    ELSE
        INSERT INTO [dbo].[MAS_Apartment_Member_H] 
            ([Oid],[ApartmentId],[CustId],[OldCustId],[NewCustId],[FullName],[Phone],[Email],[Birthday],[IsSex],
             [RelationId],[RelationName],[IsForeign],[CountryCd],[HostFullName],
             [ApproveDt],[ApproveDtEnd],[EffectiveDate],[ExpiredDate],[member_st],[Note],
             [PerformedByUserId],[PerformedAt],[CreatedBy],[CreatedDate])
        VALUES 
            (NEWID(),@ApartmentId,@CustId,ISNULL(@OldCustId, @CustId),@CustId,@NewFullName,@NewPhone,@NewEmail,@NewBirthday,@NewIsSex,
             0,@NewRelationName,@IsForeign,@NewCountryCd,@HostFullNameAtTime,
             @EffDate,NULL,@EffDate,NULL,1,@NewHostNote,
             @userId,DATEADD(MILLISECOND, 1, @HistoryPerformedAt),@userId,GETDATE());

    -- =====================================
    -- 20. Process new host member history (before becoming host)
    -- =====================================
    IF @OldCustId IS NOT NULL AND @OldCustId <> @CustId
    BEGIN
        SELECT TOP 1 @NewHostMemberOid = h.Oid 
        FROM MAS_Apartment_Member_H h WITH (NOLOCK) 
        WHERE h.ApartmentId = @ApartmentId AND h.CustId = @CustId AND (@NewHostOid IS NULL OR h.Oid <> @NewHostOid) 
        ORDER BY h.PerformedAt DESC, h.Oid DESC;
        
        IF @NewHostMemberOid IS NOT NULL
            UPDATE MAS_Apartment_Member_H 
            SET RelationId = COALESCE(@NewHostPrevRelationId, 14), 
                RelationName = (SELECT TOP 1 RelationName FROM MAS_Customer_Relation WITH (NOLOCK) WHERE RelationId = COALESCE(@NewHostPrevRelationId, 14)), 
                IsForeign = @IsForeign, CountryCd = @NewCountryCd, 
                FullName = @NewFullName, Phone = @NewPhone, Email = @NewEmail, Birthday = @NewBirthday, IsSex = @NewIsSex, 
                HostFullName = @HostFullNameAtTime, 
                member_st = 1, ApproveDt = COALESCE(@NewHostOriginalApproveDt, DATEADD(DAY, -1, @EffDate)), 
                ApproveDtEnd = DATEADD(DAY, -1, @EffDate), 
                EffectiveDate = COALESCE(@NewHostOriginalApproveDt, DATEADD(DAY, -1, @EffDate)), ExpiredDate = DATEADD(DAY, -1, @EffDate), 
                Note = N'Thành viên', PerformedByUserId = @userId, 
                PerformedAt = DATEADD(MILLISECOND, -1, @HistoryPerformedAt), CustId = @CustId, CreatedBy = @userId, CreatedDate = GETDATE() 
            WHERE Oid = @NewHostMemberOid;
        ELSE
            INSERT INTO [dbo].[MAS_Apartment_Member_H] 
                ([Oid],[ApartmentId],[CustId],[OldCustId],[NewCustId],[FullName],[Phone],[Email],[Birthday],[IsSex],
                 [RelationId],[RelationName],[IsForeign],[CountryCd],[HostFullName],
                 [ApproveDt],[ApproveDtEnd],[EffectiveDate],[ExpiredDate],[member_st],[Note],
                 [PerformedByUserId],[PerformedAt],[CreatedBy],[CreatedDate])
            VALUES 
                (NEWID(),@ApartmentId,@CustId,@CustId,@CustId,@NewFullName,@NewPhone,@NewEmail,@NewBirthday,@NewIsSex,
                 COALESCE(@NewHostPrevRelationId, 14),
                 (SELECT TOP 1 RelationName FROM MAS_Customer_Relation WITH (NOLOCK) WHERE RelationId = COALESCE(@NewHostPrevRelationId, 14)),
                 @IsForeign,@NewCountryCd,@HostFullNameAtTime,
                 COALESCE(@NewHostOriginalApproveDt, DATEADD(DAY, -1, @EffDate)),DATEADD(DAY, -1, @EffDate),
                 COALESCE(@NewHostOriginalApproveDt, DATEADD(DAY, -1, @EffDate)),DATEADD(DAY, -1, @EffDate),
                 1,N'Thành viên',@userId,
                 DATEADD(MILLISECOND, -1, @HistoryPerformedAt),@userId,GETDATE());
    END

    -- =====================================
    -- 21. Return result
    -- =====================================
    SET @valid = 1; 
    SET @messages = N'Sửa thông tin chủ hộ thành công';
    SELECT @valid AS valid, @messages AS [messages];
END TRY
BEGIN CATCH
    -- =====================================
    -- Error handling
    -- =====================================
    IF @@TRANCOUNT > 0 ROLLBACK TRAN;
    DECLARE @ErrorNum INT, @ErrorMsg NVARCHAR(200), @ErrorProc NVARCHAR(50), @SessionID INT, @AddlInfo NVARCHAR(MAX);
    SET @ErrorNum = ERROR_NUMBER();
    SET @ErrorMsg = 'sp_res_apartment_change_host_set ' + ERROR_MESSAGE();
    SET @ErrorProc = ERROR_PROCEDURE();
    SET @AddlInfo = N'@userId: ' + ISNULL(@userId, N'NULL') + N', @ApartmentId: ' + ISNULL(CAST(@ApartmentId AS NVARCHAR(50)), N'NULL') + N', @CustId: ' + ISNULL(@CustId, N'NULL');
    EXEC utl_ErrorLog_Set @ErrorNum, @ErrorMsg, @ErrorProc, 'apartment_change_host', 'Set', @SessionID, @AddlInfo;
    SELECT CAST(0 AS bit) AS valid, @ErrorMsg AS [messages];
END CATCH;