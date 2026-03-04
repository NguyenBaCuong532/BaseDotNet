CREATE PROCEDURE [dbo].[sp_res_apartment_member_history_page]
    @userId UNIQUEIDENTIFIER,
    @ApartmentId INT,
    @CustId NVARCHAR(50) = NULL,
    @filter NVARCHAR(100) = NULL,
    @gridWidth int = 0,
    @Offset INT = 0,
    @PageSize INT = 10,
    @acceptLanguage NVARCHAR(50) = N'vi-VN'
AS
BEGIN TRY
    SET NOCOUNT ON;

    DECLARE @Total BIGINT = 0;
    DECLARE @GridKey NVARCHAR(100) = 'view_apartment_family_member_page';

    SET @Offset = ISNULL(@Offset, 0);
    SET @PageSize = CASE WHEN ISNULL(@PageSize, 0) > 0 THEN @PageSize ELSE 10 END;
    SET @filter = ISNULL(@filter, N'');
    
    IF @ApartmentId IS NULL OR @ApartmentId = 0
    BEGIN
        SELECT recordsTotal = 0,
               recordsFiltered = 0,
               gridKey = @GridKey,
               valid = 1;
        RETURN;
    END

    IF @PageSize = 0
        SET @PageSize = 10;
    IF @Offset < 0
        SET @Offset = 0;

    -- Tính tổng số bản ghi (đọc trực tiếp từ MAS_Apartment_Member_H, không cần JOIN)
    SELECT @Total = COUNT(h.Oid)
    FROM dbo.MAS_Apartment_Member_H h WITH (NOLOCK)
    WHERE h.ApartmentId = @ApartmentId
      AND (@CustId IS NULL OR h.CustId = @CustId OR h.OldCustId = @CustId OR h.NewCustId = @CustId)
      AND (
           @filter = N''
           OR h.FullName LIKE N'%' + @filter + N'%'
           OR h.Phone LIKE N'%' + @filter + N'%'
           OR h.Email LIKE N'%' + @filter + N'%'
      );

    -- Result 1: root
    SELECT recordsTotal = @Total,
           recordsFiltered = @Total,
           gridKey = @GridKey,
           valid = 1;

    -- Result 2: grid config
    IF @Offset = 0
    BEGIN
        SELECT *
        FROM [dbo].fn_config_list_gets_lang(@GridKey, @gridWidth, @acceptLanguage)
        ORDER BY [ordinal];
    END
    ELSE
    BEGIN
        -- Trả về empty result set khi @Offset != 0
        SELECT TOP 0 *
        FROM [dbo].fn_config_list_gets_lang(@GridKey, @gridWidth, @acceptLanguage);
    END;

    -- Result 3: Data (đọc trực tiếp từ MAS_Apartment_Member_H, không cần JOIN với MAS_Customers)
    SELECT h.Oid AS HistoryId, -- Sử dụng Oid làm HistoryId
           h.Oid AS HistoryIdInt, -- Giữ Oid để làm key
           h.ApartmentId,
           h.CustId,
           h.FullName,
           h.Phone,
           h.Email,
           CASE WHEN h.IsSex = 1 THEN N'Nam' 
                WHEN h.IsSex = 0 THEN N'Nữ' 
                ELSE N'' END AS SexName,
           ISNULL(h.IsForeign, ISNULL(h.IsForeigner, 0)) AS IsForeign,
           CASE WHEN ISNULL(h.IsForeign, ISNULL(h.IsForeigner, 0)) = 1
                THEN '<i class="pi pi-check text-blue-500 font-bold"></i>'
                ELSE '<i class="pi pi-times text-red-500 font-bold"></i>'
           END AS IsForeignName,
           ISNULL(h.CountryCd, h.Nationality) AS CountryCd,
           h.RelationId,
           h.RelationName,
           ISNULL(h.HostFullName, CASE WHEN ISNULL(h.RelationId, 99) = 0 THEN h.FullName ELSE N'' END) AS HostName, -- Tên chủ hộ
           CASE WHEN ISNULL(h.RelationId, 99) = 0 THEN 1 ELSE 0 END AS IsHost,
           CASE WHEN ISNULL(h.RelationId, 99) = 0 
                THEN '<i class="pi pi-check text-blue-500 font-bold"></i>'
                ELSE '<i class="pi pi-times text-red-500 font-bold"></i>'
           END AS IsHostName,
           CASE WHEN appInfo.userId IS NOT NULL 
                THEN '<i class="pi pi-check text-blue-500 font-bold"></i>'
                ELSE '<i class="pi pi-times text-red-500 font-bold"></i>'
           END AS isAppName,
           CASE WHEN appInfo.userId IS NOT NULL THEN 1 ELSE 0 END AS isApp,
           CONVERT(NVARCHAR(10), ISNULL(h.ApproveDt, h.EffectiveDate), 103) AS EffectiveDate,
           CONVERT(NVARCHAR(10), ISNULL(h.ApproveDtEnd, h.ExpiredDate), 103) AS ExpiredDate,
           CASE WHEN ISNULL(h.member_st, 1) = 1 THEN N'Đã duyệt' 
                WHEN ISNULL(h.member_st, 1) = 0 THEN N'Chờ duyệt' 
                ELSE N'Chưa xác định' END AS StatusName,
           h.Note,
           h.PerformedByUserId AS ActionUserId,
           CONVERT(NVARCHAR(16), ISNULL(h.PerformedAt, h.CreatedDate), 103) + ' ' + CONVERT(NVARCHAR(8), ISNULL(h.PerformedAt, h.CreatedDate), 108) AS ActionDate,
            CONVERT(NVARCHAR(10),h.Birthday, 103) AS birthday,
           ISNULL(h.IsNotification, 0) AS IsNotification
    FROM dbo.MAS_Apartment_Member_H h WITH (NOLOCK)
    OUTER APPLY (
        SELECT TOP 1 u.userId
        FROM dbo.UserInfo u WITH (NOLOCK)
        WHERE u.CustId = h.CustId
        ORDER BY u.created_dt DESC, u.reg_userId DESC
    ) appInfo
    WHERE h.ApartmentId = @ApartmentId
      AND (@CustId IS NULL OR h.CustId = @CustId OR h.OldCustId = @CustId OR h.NewCustId = @CustId)
      AND (
           @filter = N''
           OR h.FullName LIKE N'%' + @filter + N'%'
           OR h.Phone LIKE N'%' + @filter + N'%'
           OR h.Email LIKE N'%' + @filter + N'%'
      )
    ORDER BY ISNULL(h.PerformedAt, h.CreatedDate) DESC,
             h.Oid DESC
    OFFSET @Offset ROWS FETCH NEXT @PageSize ROWS ONLY;

END TRY
BEGIN CATCH
    DECLARE @ErrorNum INT,
            @ErrorMsg VARCHAR(200),
            @ErrorProc VARCHAR(50),
            @SessionID INT,
            @AddlInfo VARCHAR(MAX);

    SET @ErrorNum = ERROR_NUMBER();
    SET @ErrorMsg = 'sp_res_apartment_member_history_page ' + ERROR_MESSAGE();
    SET @ErrorProc = ERROR_PROCEDURE();
    SET @AddlInfo = '';

    EXEC utl_ErrorLog_Set @ErrorNum,
                          @ErrorMsg,
                          @ErrorProc,
                          'FamilyMember',
                          'HistoryPage',
                          @SessionID,
                          @AddlInfo;
END CATCH;