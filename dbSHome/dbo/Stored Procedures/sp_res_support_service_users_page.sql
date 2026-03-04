-- =============================================
-- Author:      ThanhMT
-- Create date: 19/01/2026
-- Description: Phân công trưởng nhóm và các thành viên xử lý nhóm yêu cầu hỗ trợ - Danh sách dữ liệu phân trang
-- =============================================
CREATE PROCEDURE [dbo].[sp_res_support_service_users_page]
    @UserId UNIQUEIDENTIFIER = null,
    @project_code NVARCHAR(50) = NULL,
    @service_type_oid NVARCHAR(50) = NULL,
    @ClientId nvarchar(50) = null,
    @Filter nvarchar(150) = NULL,
    @GridWidth INT = 0,
    @Offset INT = 0,
    @PageSize INT = 10,
    @AcceptLanguage nvarchar(50) = N'vi-VN'
AS
BEGIN TRY
    DECLARE @ViewGrid NVARCHAR(100) = 'support_service_users_page';--sys_config_list
    SET @OffSet = ISNULL(@OffSet, 0);
    SET @PageSize = ISNULL(@PageSize, 20);
    SET @Filter = ISNULL(@Filter, '');

    SELECT a.*
    INTO #support_service_users
    FROM
        support_service_users a
        INNER JOIN service s ON s.id = a.support_service_oid
        INNER JOIN Users u ON u.userId = a.user_oid
    WHERE
        (@Filter = '' OR (@Filter <> '' AND (u.fullname LIKE N'%'+@Filter+'%')))
        AND (@service_type_oid IS NULL OR s.service_type_id = @service_type_oid)
		
    SELECT *
    INTO #support_service_users_page
    FROM #support_service_users
    ORDER BY created_at DESC
    OFFSET @Offset ROWS FETCH NEXT @PageSize ROWS ONLY;
	
    SELECT
        RecordsTotal = (SELECT COUNT(*) FROM #support_service_users),
        RecordsFiltered = (SELECT COUNT(*) FROM #support_service_users_page),
        GridKey = @ViewGrid
    IF(@OffSet <= 0)
		SELECT*FROM dbo.fn_config_list_gets_lang(@ViewGrid, @gridWidth, @AcceptLanguage) ORDER BY ordinal;
	
    SELECT
        a.oid,
        support_service_name = s.name,
        user_fullname = u.fullname,
        role_name = r.par_desc,
        status_name = CASE WHEN a.is_active = 1 THEN N'<span class="bg-success noti-number ml5">Đang hoạt động</span>' ELSE N'<span class="bg-danger noti-number ml5">Ngưng hoạt động</span>' END,
        last_updated_by = '',
        last_updated_at = FORMAT(a.updated_at, 'dd/MM/yyyy HH:mm')
    FROM
        #support_service_users_page a
        INNER JOIN service s ON s.id = a.support_service_oid
        INNER JOIN Users u ON u.userId = a.user_oid
        OUTER APPLY(SELECT TOP 1 *FROM sys_config_data WHERE key_1 = 'support_service_users_role' AND value1 = a.service_role) r

END TRY
BEGIN CATCH
    DECLARE @ErrorNum INT, @ErrorMsg VARCHAR(200), @ErrorProc VARCHAR(50), @SessionID INT, @AddlInfo VARCHAR(MAX)
    SET @ErrorNum = error_number()
    SET @ErrorMsg = 'Line: ' + CONVERT(nvarchar(300), error_line()) + ' Msg: ' + error_message();
    SET @ErrorProc = error_procedure()
    SET @AddlInfo = 'UserId: ' + CONVERT(NVARCHAR(50), @UserId)
    EXEC utl_ErrorLog_Set @ErrorNum, @ErrorMsg, @ErrorProc, '', '', @SessionID, @AddlInfo
END CATCH