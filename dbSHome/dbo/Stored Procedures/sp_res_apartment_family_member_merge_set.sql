CREATE PROCEDURE [dbo].[sp_res_apartment_family_member_merge_set]
    @UserId NVARCHAR(450),
    @CustId NVARCHAR(450) = NULL, 
    @CustId1 NVARCHAR(450) = NULL,
    @ApartmentId INT,
    @ArrObj dbo.MergeMemberField READONLY -- Table type chứa arrObj (fieldName, result, custId)
AS
BEGIN TRY
    SET NOCOUNT ON;
    -- Lấy count của @ArrObj
    DECLARE @ArrObjCount INT = 0;
    SELECT @ArrObjCount = COUNT(*) FROM @ArrObj;
 
    DECLARE @valid BIT = 0;
    DECLARE @messages NVARCHAR(250) = N'Có lỗi xảy ra';
    -- Kiểm tra quyền admin
    IF dbo.[fn_Hom_User_admin](@UserId) <> 1
    BEGIN
        SET @valid = 0;
        SET @messages = N'Bạn không có quyền gộp thành viên';
        PRINT 'Error: ' + @messages;
        SELECT @valid AS valid, @messages AS [messages];
        RETURN;
    END
    -- Kiểm tra CustId1 có tồn tại trong căn hộ không
    DECLARE @RealCustId1 NVARCHAR(450);
    DECLARE @RealCustId2 NVARCHAR(450);
    DECLARE @FullName1 NVARCHAR(200);
    DECLARE @FullName2 NVARCHAR(200);
 
    SELECT TOP 1 
        @RealCustId1 = c.CustId,
        @FullName1 = c.FullName
    FROM MAS_Customers c WITH (NOLOCK)
    INNER JOIN MAS_Apartment_Member am WITH (NOLOCK) ON am.CustId = c.CustId
    WHERE am.ApartmentId = @ApartmentId
      AND c.CustId = @CustId; 
   
    IF @RealCustId1 IS NULL
    BEGIN
        -- Debug: Kiểm tra xem CustId có tồn tại trong database không
        DECLARE @ExistsInCustomers BIT = 0;
        SELECT @ExistsInCustomers = CASE WHEN EXISTS(SELECT 1 FROM MAS_Customers WHERE CustId = @CustId) THEN 1 ELSE 0 END;
        DECLARE @ExistsInApartment BIT = 0;
        SELECT @ExistsInApartment = CASE WHEN EXISTS(SELECT 1 FROM MAS_Apartment_Member WHERE CustId = @CustId AND ApartmentId = @ApartmentId) THEN 1 ELSE 0 END;
        -- Kiểm tra member_St
        SET @valid = 0;
        SET @messages = N'Vui lòng chọn đầy đủ các thông tin';
        PRINT 'Error: ' + @messages;
        SELECT @valid AS valid, @messages AS [messages];
        RETURN;
    END

    SELECT TOP 1 
        @RealCustId2 = c.CustId,
        @FullName2 = c.FullName
    FROM MAS_Customers c WITH (NOLOCK)
    INNER JOIN MAS_Apartment_Member am WITH (NOLOCK) ON am.CustId = c.CustId
    WHERE am.ApartmentId = @ApartmentId
      AND c.CustId = @CustId1; 

    IF @RealCustId2 IS NULL
    BEGIN
        SET @valid = 0;
        SET @messages = N'Thành viên được gộp không tồn tại trong căn hộ';
        SELECT @valid AS valid, @messages AS [messages];
        RETURN;
    END 
    
    -- Xác định custId nào sẽ được giữ lại dựa trên custId trong @ArrObj (phải làm trước khi kiểm tra ràng buộc)
    DECLARE @TargetCustId NVARCHAR(450) = NULL; -- CustId sẽ được giữ lại (update vào đây)
    DECLARE @DeleteCustId NVARCHAR(450) = NULL;  -- CustId sẽ bị xóa
    -- Lấy custId từ @ArrObj
    DECLARE @ArrObjCustId NVARCHAR(450) = NULL;
    SELECT TOP 1 @ArrObjCustId = LTRIM(RTRIM([custId]))
    FROM @ArrObj
    WHERE [custId] IS NOT NULL 
      AND LEN(LTRIM(RTRIM([custId]))) > 0;

    -- ====== VALIDATION: Kiểm tra @ArrObj phải có custId ======
    -- Nếu @ArrObj rỗng hoặc không có custId, không cho phép gộp
    IF @ArrObjCustId IS NULL
    BEGIN
        SET @valid = 0;
        SET @messages = N'Vui lòng chọn thành viên cần giữ lại trong danh sách gộp';
        PRINT 'Error: ' + @messages;
        SELECT @valid AS valid, @messages AS [messages];
        RETURN;
    END

    -- Kiểm tra custId trong @ArrObj trùng với @RealCustId1 hay @RealCustId2
    IF @ArrObjCustId = @RealCustId1
    BEGIN
        -- Trùng với @RealCustId1 → giữ @RealCustId1, xóa @RealCustId2
        SET @TargetCustId = @RealCustId1;
        SET @DeleteCustId = @RealCustId2;
    END
    ELSE IF @ArrObjCustId = @RealCustId2
    BEGIN
        -- Trùng với @RealCustId2 → giữ @RealCustId2, xóa @RealCustId1
        SET @TargetCustId = @RealCustId2;
        SET @DeleteCustId = @RealCustId1;
    END
 
    -- Kiểm tra ràng buộc tham chiếu
    IF EXISTS (SELECT 1 FROM MAS_Points WHERE CustId = @DeleteCustId)
    BEGIN
        SET @valid = 0;
        SET @messages = N'Thành viên đang có thông tin liên kết (điểm), không thể gộp/xóa';
        SELECT @valid AS valid, @messages AS [messages];
        RETURN;
    END
   
    BEGIN TRAN;
    -- Parse JSON để lấy các field
    DECLARE @SelectedFullName NVARCHAR(250) = NULL;
    DECLARE @SelectedTooltip NVARCHAR(MAX) = NULL;
   
    ------------------------------------------------------------
    -- Parse FieldsJson (dataList) để lấy giá trị chọn
    ------------------------------------------------------------
    DECLARE @SelFullName NVARCHAR(250) = NULL;
    DECLARE @SelPhone NVARCHAR(30) = NULL;
    DECLARE @SelEmail NVARCHAR(150) = NULL;
    DECLARE @SelIsSex BIT = NULL;
    DECLARE @SelBirthday DATE = NULL;
    DECLARE @SelIsForeign BIT = NULL;
    DECLARE @SelRelationName NVARCHAR(100) = NULL; -- Quan hệ với chủ hộ
    DECLARE @SelStartDate DATE = NULL; -- Ngày bắt đầu cư trú
    IF EXISTS (SELECT 1 FROM @ArrObj)
    BEGIN
        -- Lấy giá trị từ result theo fieldName (chỉ lấy những record có fieldName không null - bỏ qua item đầu tiên chứa custId)
        SELECT
            @SelFullName = MAX(CASE WHEN [fieldName] = N'Họ tên' AND [result] IS NOT NULL THEN [result] END),
            @SelPhone    = MAX(CASE WHEN [fieldName] = N'Số điện thoại' AND [result] IS NOT NULL THEN [result] END),
            @SelEmail    = MAX(CASE WHEN [fieldName] = N'Email' AND [result] IS NOT NULL THEN [result] END),
            @SelBirthday = MAX(CASE WHEN [fieldName] = N'Ngày sinh' AND [result] IS NOT NULL THEN TRY_CONVERT(DATE, [result], 103) END),
            @SelIsSex    = CAST(MAX(CASE WHEN [fieldName] = N'Giới tính' AND [result] IS NOT NULL THEN 
                                        CASE 
                                            WHEN UPPER([result]) LIKE N'%NAM%' THEN CAST(1 AS INT)
                                            ELSE CAST(0 AS INT)
                                        END
                                    END) AS BIT),
            @SelIsForeign = CAST(MAX(CASE WHEN [fieldName] = N'Người nước ngoài' AND [result] IS NOT NULL THEN 
                                        CASE 
                                            WHEN [result] LIKE N'%ngoài%' OR [result] = '1' OR [result] = 'true' OR [result] = 'True' THEN CAST(1 AS INT)
                                            ELSE CAST(0 AS INT)
                                        END
                                     END) AS BIT),
            @SelRelationName = MAX(CASE WHEN [fieldName] = N'Quan hệ với chủ hộ' AND [result] IS NOT NULL THEN [result] END),
            @SelStartDate = MAX(CASE WHEN [fieldName] = N'Ngày bắt đầu cư trú' AND [result] IS NOT NULL THEN TRY_CONVERT(DATE, [result], 103) END)
        FROM @ArrObj
        WHERE [fieldName] IS NOT NULL 
          AND [result] IS NOT NULL 
          AND LEN(LTRIM(RTRIM([result]))) > 0;
    END
    -- Map RelationName sang RelationId
    DECLARE @SelRelationId INT = NULL;
    IF @SelRelationName IS NOT NULL AND LEN(LTRIM(RTRIM(@SelRelationName))) > 0
    BEGIN
        SELECT TOP 1 @SelRelationId = RelationId
        FROM MAS_Customer_Relation WITH (NOLOCK)
        WHERE RelationName = LTRIM(RTRIM(@SelRelationName));
        -- Nếu không tìm thấy, lấy RelationId từ thành viên cũ (c1) hoặc thành viên mới (c2)
        IF @SelRelationId IS NULL
        BEGIN
            SELECT TOP 1 @SelRelationId = am.RelationId
            FROM MAS_Apartment_Member am WITH (NOLOCK)
            WHERE am.CustId = @RealCustId2 AND am.ApartmentId = @ApartmentId;
            -- Fallback: lấy từ thành viên bị gộp
            IF @SelRelationId IS NULL
            BEGIN
                SELECT TOP 1 @SelRelationId = am.RelationId
                FROM MAS_Apartment_Member am WITH (NOLOCK)
                WHERE am.CustId = @RealCustId1 AND am.ApartmentId = @ApartmentId;
            END
        END
    END
    ELSE
    BEGIN
        -- Nếu không có RelationName từ @ArrObj, lấy từ thành viên cũ (c2) hoặc thành viên bị gộp (c1)
        SELECT TOP 1 @SelRelationId = am.RelationId
        FROM MAS_Apartment_Member am WITH (NOLOCK)
        WHERE am.CustId = @RealCustId2 AND am.ApartmentId = @ApartmentId;
        -- Fallback: lấy từ thành viên bị gộp
        IF @SelRelationId IS NULL
        BEGIN
            SELECT TOP 1 @SelRelationId = am.RelationId
            FROM MAS_Apartment_Member am WITH (NOLOCK)
            WHERE am.CustId = @RealCustId1 AND am.ApartmentId = @ApartmentId;
        END
    END
    -- ====== GHI 1 BẢN LỊCH SỬ DUY NHẤT VÀO MAS_Apartment_Member_H ======
    DECLARE @DeleteFullName NVARCHAR(200) = NULL;
    DECLARE @DeletePhone NVARCHAR(50) = NULL;
    DECLARE @DeleteEmail NVARCHAR(150) = NULL;
    DECLARE @DeleteBirthday DATETIME = NULL;
    DECLARE @DeleteIsSex BIT = NULL;
    DECLARE @DeleteCountryCd NVARCHAR(50) = NULL;
    DECLARE @DeleteIsForeign BIT = NULL;
    DECLARE @UserLoginForHistory NVARCHAR(100) = NULL;
    DECLARE @HostFullNameAtTime NVARCHAR(200) = NULL;

    -- Lấy tên chủ hộ hiện tại của căn hộ tại thời điểm ghi lịch sử
    SELECT TOP 1 @HostFullNameAtTime = c.FullName
    FROM MAS_Apartment_Member am WITH (NOLOCK)
    LEFT JOIN MAS_Customers c WITH (NOLOCK) ON c.CustId = am.CustId
    WHERE am.ApartmentId = @ApartmentId
      AND am.RelationId = 0
    ORDER BY ISNULL(am.approveDt, am.RegDt) DESC;

    -- Lấy thông tin từ MAS_Apartment_Member của thành viên BỊ XÓA
    DECLARE @DeleteRelationId INT = NULL;
    DECLARE @DeleteApproveDt DATETIME = NULL;
    DECLARE @DeleteRegDt DATETIME = NULL;
    DECLARE @DeleteMemberSt INT = NULL;
    DECLARE @DeleteRelationName NVARCHAR(100) = NULL;
    
    SELECT TOP 1
           @DeleteRelationId = am.RelationId,
           @DeleteApproveDt  = am.approveDt,
           @DeleteRegDt      = am.RegDt,
           @DeleteMemberSt   = am.member_st
    FROM MAS_Apartment_Member am WITH (NOLOCK)
    WHERE am.CustId = @DeleteCustId
      AND am.ApartmentId = @ApartmentId;

    -- Lấy thông tin từ MAS_Customers của thành viên BỊ XÓA 
    SELECT TOP 1
           @DeleteIsForeign  = ISNULL(IsForeign,0),
           @DeleteFullName   = LTRIM(RTRIM(ISNULL(FullName, ''))),
           @DeletePhone      = Phone,
           @DeleteEmail      = Email,
           @DeleteBirthday   = Birthday,
           @DeleteIsSex      = IsSex,
           @DeleteCountryCd  = CountryCd
    FROM MAS_Customers WITH (NOLOCK)
    WHERE CustId = @DeleteCustId;

    -- Nếu không lấy được từ MAS_Customers hoặc FullName rỗng
    IF @DeleteFullName IS NULL OR LEN(@DeleteFullName) = 0
    BEGIN
        IF @DeleteCustId = @RealCustId1
            SET @DeleteFullName = LTRIM(RTRIM(ISNULL(@FullName1, '')));
        ELSE IF @DeleteCustId = @RealCustId2
            SET @DeleteFullName = LTRIM(RTRIM(ISNULL(@FullName2, '')));
    END

    -- Lấy RelationName từ RelationId của thành viên bị xóa
    IF @DeleteRelationId IS NOT NULL
    BEGIN
        SELECT TOP 1 @DeleteRelationName = RelationName
        FROM MAS_Customer_Relation WITH (NOLOCK)
        WHERE RelationId = @DeleteRelationId;
    END

    -- Lấy UserLogin từ UserId
    SELECT TOP 1 @UserLoginForHistory = loginName
    FROM UserInfo WITH (NOLOCK)
    WHERE userId = @UserId;

    IF @ArrObjCustId IS NULL OR @DeleteCustId != @ArrObjCustId
    BEGIN
        -- Xác định CustId để lưu vào lịch sử cho thành viên bị gộp
        -- Nếu @DeleteCustId trùng với custId trong @ArrObj, lưu @TargetCustId (thành viên không trùng)
        -- Ngược lại, lưu @DeleteCustId (thành viên bị xóa)
        DECLARE @HistoryCustIdForDelete NVARCHAR(450) = @DeleteCustId;
        IF @ArrObjCustId IS NOT NULL AND @DeleteCustId = @ArrObjCustId
        BEGIN
            -- Nếu @DeleteCustId trùng với custId trong @ArrObj, lưu @TargetCustId (thành viên không trùng)
            SET @HistoryCustIdForDelete = @TargetCustId;
        END

        INSERT INTO [dbo].[MAS_Apartment_Member_H]
            ([Oid],[ApartmentId],[CustId],[OldCustId],[NewCustId],
             [FullName],[Phone],[Email],[Birthday],[IsSex],[Gender],
             [RelationId],[RelationName],[IsOwner],[IsForeign],[IsForeigner],[CountryCd],[Nationality],
             [HostFullName],
             [ApproveDt],[ApproveDtEnd],[ContractDate],[EffectiveDate],[ExpiredDate],
             [member_st],[Note],[UserLogin],[PerformedByUserId],[PerformedAt],[CreatedBy],[CreatedDate])
        VALUES
            (NEWID(),
             @ApartmentId,
             @HistoryCustIdForDelete, 
             @DeleteCustId,
             @TargetCustId,   
             @DeleteFullName,  
             @DeletePhone,     
             @DeleteEmail,    
             @DeleteBirthday,  
             @DeleteIsSex,
             CASE WHEN @DeleteIsSex = 1 THEN 1 WHEN @DeleteIsSex = 0 THEN 0 ELSE NULL END,
             ISNULL(@DeleteRelationId,14),
             @DeleteRelationName,
             CASE WHEN ISNULL(@DeleteRelationId,14) = 0 THEN 1 ELSE 0 END,
             ISNULL(@DeleteIsForeign,0),
             ISNULL(@DeleteIsForeign,0), 
             @DeleteCountryCd, 
             @DeleteCountryCd,
             @HostFullNameAtTime,
             COALESCE(@DeleteApproveDt,@DeleteRegDt,GETDATE()), 
             GETDATE(),       
             COALESCE(@DeleteApproveDt,@DeleteRegDt,GETDATE()), 
             COALESCE(@DeleteApproveDt,@DeleteRegDt,GETDATE()),
             GETDATE(),    
             ISNULL(@DeleteMemberSt, 1),
             N'Thành viên ' + ISNULL(@DeleteFullName,N'')+ N' bị gộp và xóa khỏi căn hộ.',
             @UserLoginForHistory, 
             @UserId,        
             GETDATE(),    
             @UserId,      
             GETDATE());    
    END

    -- Update thông tin vào @TargetCustId (ưu tiên giá trị chọn từ body, fallback giá trị từ @DeleteCustId hoặc giá trị hiện tại)
    UPDATE target
    SET 
        target.FullName  = COALESCE(@SelFullName,  target.FullName, deleteCust.FullName),
        target.Phone     = COALESCE(@SelPhone,     target.Phone,    deleteCust.Phone),
        target.Phone2    = COALESCE(@SelPhone,     target.Phone2,   deleteCust.Phone2),
        target.Email     = COALESCE(@SelEmail,     target.Email,    deleteCust.Email),
        target.Email2    = COALESCE(@SelEmail,     target.Email2,   deleteCust.Email2),
        target.AvatarUrl = ISNULL(target.AvatarUrl, deleteCust.AvatarUrl),
        target.IsSex     = COALESCE(@SelIsSex,     target.IsSex,    deleteCust.IsSex),
        target.Birthday  = COALESCE(@SelBirthday,  target.Birthday, deleteCust.Birthday),
        target.IsForeign = COALESCE(@SelIsForeign, target.IsForeign, deleteCust.IsForeign),
        target.CountryCd = CASE 
                               WHEN COALESCE(@SelIsForeign, target.IsForeign, deleteCust.IsForeign) = 1 THEN target.CountryCd
                               ELSE ISNULL(target.CountryCd, ISNULL(deleteCust.CountryCd, 'VN'))
                           END,
        target.Pass_No   = ISNULL(target.Pass_No,  deleteCust.Pass_No),
        target.Pass_Dt   = ISNULL(target.Pass_Dt,  deleteCust.Pass_Dt),
        target.Pass_Plc  = ISNULL(target.Pass_Plc, deleteCust.Pass_Plc),
        target.Address   = ISNULL(target.Address,  deleteCust.Address),
        target.ProvinceCd= ISNULL(target.ProvinceCd, deleteCust.ProvinceCd),
        target.Cif_No    = ISNULL(target.Cif_No,   deleteCust.Cif_No)
    FROM MAS_Customers target
    CROSS JOIN MAS_Customers deleteCust
    WHERE target.CustId = @TargetCustId
      AND deleteCust.CustId = @DeleteCustId;
    -- Update MAS_Apartment_Member: RelationId và RegDt (Ngày bắt đầu cư trú)
    UPDATE targetAm
    SET 
        targetAm.RelationId = COALESCE(@SelRelationId, targetAm.RelationId, deleteAm.RelationId),
        targetAm.RegDt = COALESCE(@SelStartDate, targetAm.RegDt, deleteAm.RegDt)
    FROM MAS_Apartment_Member targetAm
    CROSS JOIN MAS_Apartment_Member deleteAm
    WHERE targetAm.CustId = @TargetCustId 
      AND targetAm.ApartmentId = @ApartmentId
      AND deleteAm.CustId = @DeleteCustId 
      AND deleteAm.ApartmentId = @ApartmentId;
    -- Xóa thành viên bị xóa khỏi căn hộ
    DELETE FROM MAS_Apartment_Member
    WHERE CustId = @DeleteCustId AND ApartmentId = @ApartmentId;
    COMMIT TRAN;
    SET @valid = 1;
    SET @messages = N'Gộp thành viên thành công';
    SELECT @valid AS valid, @messages AS [messages];
END TRY
BEGIN CATCH
    IF @@TRANCOUNT > 0 
        ROLLBACK TRAN;

    DECLARE @ErrorNum INT,
            @ErrorMsg VARCHAR(200),
            @ErrorProc VARCHAR(50),
            @SessionID INT,
            @AddlInfo VARCHAR(MAX);

    SET @ErrorNum = ERROR_NUMBER();
    SET @ErrorMsg = 'sp_res_apartment_family_member_merge_set ' + ERROR_MESSAGE();
    SET @ErrorProc = ERROR_PROCEDURE();
    SET @AddlInfo = '';

    EXEC utl_ErrorLog_Set @ErrorNum, @ErrorMsg, @ErrorProc, 'ApartmentMembers', 'Merge', @SessionID, @AddlInfo;

    SELECT CAST(0 AS bit) AS valid,
           @ErrorMsg AS [messages];
END CATCH;