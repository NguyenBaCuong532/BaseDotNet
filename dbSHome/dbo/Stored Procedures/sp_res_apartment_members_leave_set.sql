CREATE PROCEDURE [dbo].[sp_res_apartment_members_leave_set]
    @UserId NVARCHAR(450),
    @ApartmentId INT,
    @CustIds NVARCHAR(MAX), -- CSV of CustId
    @ActionDate NVARCHAR(50) = NULL, -- dd/MM/yyyy
    @Note NVARCHAR(500) = NULL
AS
BEGIN TRY
    SET NOCOUNT ON;

    DECLARE @valid BIT = 0;
    DECLARE @messages NVARCHAR(250) = N'Có lỗi xảy ra';
    DECLARE @ActionDt DATE = CASE 
                                WHEN ISNULL(@ActionDate,'') = '' 
                                    THEN CONVERT(date, GETDATE()) 
                                ELSE CONVERT(date, @ActionDate, 103) 
                             END;
    DECLARE @ActionPerformedAt DATETIME = GETDATE();
    DECLARE @HostActionPerformedAt DATETIME = DATEADD(MILLISECOND, -1, @ActionPerformedAt);

    DECLARE @UserLoginForHistory NVARCHAR(100);
    SELECT TOP 1 @UserLoginForHistory = loginName
    FROM UserInfo WHERE userId = @UserId;

    -- Parse CustIds
    DECLARE @CustTable TABLE (CustId NVARCHAR(450) PRIMARY KEY);
    INSERT INTO @CustTable (CustId)
    SELECT DISTINCT TRIM(value)
    FROM STRING_SPLIT(@CustIds, ',')
    WHERE TRIM(value) <> '';

    -- Filter actual members
    DECLARE @ValidCust TABLE (CustId NVARCHAR(450) PRIMARY KEY);
    INSERT INTO @ValidCust (CustId)
    SELECT am.CustId
    FROM dbo.MAS_Apartment_Member am
    INNER JOIN @CustTable c ON c.CustId = am.CustId
    WHERE am.ApartmentId = @ApartmentId;

    IF NOT EXISTS (SELECT 1 FROM @ValidCust)
    BEGIN
        SELECT CAST(0 AS bit) AS valid,
               N'Không có thành viên hợp lệ để cập nhật' AS [messages],
               NULL AS CustIds_Leaved;
        RETURN;
    END

    -- Check if any member is a host (chủ hộ) - RelationId = 0
    DECLARE @HostCustId NVARCHAR(450);
    DECLARE @HostFullName NVARCHAR(200);
    
    SELECT TOP 1 
        @HostCustId = am.CustId,
        @HostFullName = c.FullName
    FROM dbo.MAS_Apartment_Member am
    INNER JOIN @ValidCust v ON v.CustId = am.CustId
    LEFT JOIN dbo.MAS_Customers c ON c.CustId = am.CustId
    WHERE am.ApartmentId = @ApartmentId
      AND ISNULL(am.RelationId, 99) = 0;

    IF @HostCustId IS NOT NULL
    BEGIN
        SELECT CAST(0 AS bit) AS valid,
               N'Thành viên ' + ISNULL(@HostFullName, @HostCustId) + N' là chủ hộ, chưa thể rời đi' AS [messages],
               NULL AS CustIds_Leaved;
        RETURN;
    END

    BEGIN TRAN;

    DECLARE @LeaveNote NVARCHAR(MAX) = NULLIF(LTRIM(RTRIM(@Note)), N'');
    DECLARE @MemberCount INT = (SELECT COUNT(1) FROM @ValidCust);

    -- Identify hosts leaving (RelationId = 0)
    DECLARE @HostLeaving TABLE (CustId NVARCHAR(450) PRIMARY KEY);
    INSERT INTO @HostLeaving (CustId)
    SELECT am.CustId
    FROM dbo.MAS_Apartment_Member am
    INNER JOIN @ValidCust v ON v.CustId = am.CustId
    WHERE am.ApartmentId = @ApartmentId
      AND ISNULL(am.RelationId, 99) = 0;

    -- Lấy thông tin thành viên trước khi xóa để insert vào history
    DECLARE @MemberInfo TABLE (
        CustId NVARCHAR(450),
        RelationId INT,
        IsForeign BIT,
        ApproveDt DATETIME,
        RegDt DATETIME
    );
    
    INSERT INTO @MemberInfo (CustId, RelationId, IsForeign, ApproveDt, RegDt)
    SELECT am.CustId, 
           am.RelationId, 
           ISNULL(c.IsForeign, 0) AS IsForeign,
           am.approveDt,
           am.RegDt
    FROM dbo.MAS_Apartment_Member am
    INNER JOIN @ValidCust v ON am.CustId = v.CustId
    LEFT JOIN dbo.MAS_Customers c ON c.CustId = am.CustId
    WHERE am.ApartmentId = @ApartmentId;

    -- Thêm bản ghi vào bảng lịch sử cho mỗi thành viên rời đi
    INSERT INTO [dbo].MAS_Apartment_Member_H
        ([Oid], [ApartmentId], [OldCustId], [NewCustId], [CheckFlag], [RelationId], [IsForeign], [LeaveId],
         [ApproveDt], [ApproveDtEnd], [ContractDate], [Note], [UserLogin], [PerformedByUserId], [PerformedAt], [CustId])
    SELECT NEWID(),
           @ApartmentId,
           mi.CustId,
           mi.CustId,
           0,
           ISNULL(mi.RelationId, 14),
           ISNULL(mi.IsForeign, 0),
           1,
           ISNULL(mi.ApproveDt, mi.RegDt),
           @ActionDt,
           ISNULL(mi.ApproveDt, mi.RegDt),
           COALESCE(@LeaveNote, N'Rời đi'),
           @UserLoginForHistory,
           @UserId,
           @ActionPerformedAt,
           mi.CustId
    FROM @MemberInfo mi;

    -- Xóa thành viên rời đi khỏi bảng MAS_Apartment_Member
    DELETE am
    FROM dbo.MAS_Apartment_Member am
    INNER JOIN @ValidCust v ON am.CustId = v.CustId
    WHERE am.ApartmentId = @ApartmentId;

    -- If the current host leaves, clear Apartment UserLogin (host)
    IF EXISTS (SELECT 1 FROM @HostLeaving)
    BEGIN
        UPDATE MAS_Apartments
        SET UserLogin = NULL
        WHERE ApartmentId = @ApartmentId;
    END

    COMMIT TRAN;
    
    SET @valid = 1;
    SET @messages = N'Ghi nhận rời đi thành công';

    SELECT @valid AS valid,
           @messages AS [messages],
           STRING_AGG(CustId, ',') AS CustIds_Leaved,
           @ActionPerformedAt AS ActionPerformedAt
    FROM @ValidCust;
END TRY
BEGIN CATCH
    IF @@TRANCOUNT > 0 ROLLBACK TRAN;

    DECLARE @ErrorNum INT,
            @ErrorMsg NVARCHAR(200),
            @ErrorProc NVARCHAR(50),
            @SessionID INT,
            @AddlInfo NVARCHAR(MAX);

    SET @ErrorNum = ERROR_NUMBER();
    SET @ErrorMsg = 'sp_res_apartment_members_leave_set ' + ERROR_MESSAGE();
    SET @ErrorProc = ERROR_PROCEDURE();
    SET @AddlInfo = '';

    EXEC utl_errorlog_set @ErrorNum,
                          @ErrorMsg,
                          @ErrorProc,
                          'ApartmentMembers',
                          'Leave',
                          @SessionID,
                          @AddlInfo;

    SELECT CAST(0 AS bit) AS valid,
           @ErrorMsg AS [messages],
           NULL AS CustIds_Leaved;
END CATCH;