-- =============================================
-- Author:      ThanhMT
-- Create date: 17/10/2025
-- Description: Cấu hình thứ tự ưu tiên thanh toán dịch vụ căn hộ - Danh sách dữ liệu phân trang
-- =============================================
CREATE PROCEDURE [dbo].[sp_res_payment_priority_configs_page]
    @UserId UNIQUEIDENTIFIER = null,
    @project_code NVARCHAR(50) = NULL,
    @ClientId nvarchar(50) = null,
    @Filter nvarchar(150) = NULL,
    @GridWidth INT = 0,
    @Offset INT = 0,
    @PageSize INT = 10,
    @AcceptLanguage nvarchar(50) = N'vi-VN'
AS
BEGIN TRY
    DECLARE @ViewGrid NVARCHAR(100) = 'config_sp_res_payment_priority_configs_page';--sys_config_list
    SET @OffSet = ISNULL(@OffSet, 0);
    SET @PageSize = ISNULL(@PageSize, 20);
    SET @Filter = ISNULL(@Filter, '');
    
    -- Kiểm tra nếu như chưa có thông tin thì tự động sao chép từ danh sách các dịch vụ sang
    IF (TRIM(ISNULL(@project_code, '')) <> '' AND NOT EXISTS(SELECT TOP 1 1 FROM mas_payment_priority_configs WHERE project_code = @project_code))
    BEGIN
        INSERT INTO mas_payment_priority_configs(oid, project_code, payment_service_id, priority_order, created_by, created_time, last_modified_by, last_modified_time)
        SELECT NEWID(), @project_code, oid, sort_order, @UserId, GETDATE(), @UserId, GETDATE() FROM mas_payment_services
    END
    
    SELECT
        a.oid,
        b.service_name,
        a.priority_order,
        a.is_collect_fee
    INTO #mas_payment_priority_configs
    FROM
        mas_payment_priority_configs a
        INNER JOIN mas_payment_services b ON b.oid = a.payment_service_id
    WHERE a.project_code = @project_code
    ORDER BY a.priority_order
    -- WHERE
    -- 	(@Filter = '' OR (@Filter <> '' AND (a.Name LIKE N'%'+@Filter+'%')))
		
    SELECT *
    INTO #mas_payment_priority_configs_page
    FROM #mas_payment_priority_configs
    ORDER BY is_collect_fee DESC, priority_order
    OFFSET @Offset ROWS FETCH NEXT @PageSize ROWS ONLY;
	
    SELECT
        RecordsTotal = (SELECT COUNT(*) FROM #mas_payment_priority_configs),
        RecordsFiltered = (SELECT COUNT(*) FROM #mas_payment_priority_configs_page),
        GridKey = @ViewGrid
	
    SELECT*FROM dbo.fn_config_list_gets_lang(@ViewGrid, @gridWidth, @AcceptLanguage) ORDER BY ordinal;
	
    SELECT
        *,
        is_collect_fee_name = IIF(is_collect_fee = 1, N'<span class="bg-success noti-number ml5">Đang áp dụng</span>', N'<span class="bg-secondary noti-number ml5">Không áp dụng</span>')
    FROM #mas_payment_priority_configs_page

END TRY
BEGIN CATCH
    DECLARE @ErrorNum INT, @ErrorMsg VARCHAR(200), @ErrorProc VARCHAR(50), @SessionID INT, @AddlInfo VARCHAR(MAX)
    SET @ErrorNum = error_number()
    SET @ErrorMsg = 'Line: ' + CONVERT(nvarchar(300), error_line()) + ' Msg: ' + error_message();
    SET @ErrorProc = error_procedure()
    SET @AddlInfo = 'UserId: ' + CONVERT(NVARCHAR(50), @UserId)
    EXEC utl_ErrorLog_Set @ErrorNum, @ErrorMsg, @ErrorProc, '', '', @SessionID, @AddlInfo 
END CATCH