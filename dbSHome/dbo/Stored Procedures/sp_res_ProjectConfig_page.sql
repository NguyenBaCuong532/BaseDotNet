-- =============================================
-- Author:      ThanhMT
-- Create date: 22/10/2025
-- Description: Cấu hình chung cho dự án - Danh sách dữ liệu phân trang
-- =============================================
CREATE PROCEDURE [dbo].[sp_res_ProjectConfig_page]
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
    DECLARE @ViewGrid NVARCHAR(100) = 'config_sp_res_ProjectConfig_page';--sys_config_list
    SET @OffSet = ISNULL(@OffSet, 0);
    SET @PageSize = ISNULL(@PageSize, 20);
    SET @Filter = ISNULL(@Filter, '');
    
    DECLARE @tblProjectConfig TABLE(config_code NVARCHAR(100),
                                    config_name NVARCHAR(100),
                                    config_type NVARCHAR(50),
                                    config_value_default NVARCHAR(500))
                                    
    INSERT INTO @tblProjectConfig(config_code, config_name, config_type, config_value_default)
    VALUES('file_mau_thong_bao_phi', N'File mẫu thông báo phí', 'file', N'79a46265-c9b3-40b9-a8a3-0c3ed196728a'),
          ('file_mau_thong_bao_nhac_no', N'File mẫu thông báo nhắc nợ', 'file', N'79a46265-c9b3-40b9-a8a3-0c3ed196728a'),
          ('file_mau_thong_bao_cat_dich_vu', N'File mẫu thông báo cắt dịch vụ', 'file', N'79a46265-c9b3-40b9-a8a3-0c3ed196728a'),
          ('mau_thong_bao_phi', N'Mẫu nội dung thông báo phí', 'notify', N''),
          ('mau_thong_bao_nhac_no', N'Mẫu nội dung thông báo nhắc nợ', 'notify', N''),
          ('mau_thong_bao_cat_dich_vu', N'Mẫu nội dung thông báo cắt dịch vụ', 'notify', N'')
          
    INSERT INTO par_project_config(oid, project_code, config_code, config_name, config_type, config_value, config_value_default, created_by, created_date, last_modified_by, last_modified_date)
    SELECT NEWID(), @project_code, a.config_code, a.config_name, a.config_type, NULL, a.config_value_default, @UserId, GETDATE(), @UserId, GETDATE()
    FROM
        @tblProjectConfig a
        LEFT JOIN par_project_config b ON b.config_code = a.config_code AND b.project_code = @project_code
    WHERE b.project_code IS NULL

    SELECT a.*
    INTO #par_project_config
    FROM par_project_config a
    WHERE a.project_code = @project_code
    -- 	(@Filter = '' OR (@Filter <> '' AND (a.Name LIKE N'%'+@Filter+'%')))
		
    SELECT *
    INTO #par_project_config_page
    FROM #par_project_config
    ORDER BY config_code, created_date DESC
    OFFSET @Offset ROWS FETCH NEXT @PageSize ROWS ONLY;
	
    SELECT
        RecordsTotal = (SELECT COUNT(*) FROM #par_project_config),
        RecordsFiltered = (SELECT COUNT(*) FROM #par_project_config_page),
        GridKey = @ViewGrid
	
    SELECT*FROM dbo.fn_config_list_gets_lang(@ViewGrid, @gridWidth, @AcceptLanguage) ORDER BY ordinal;
	
    SELECT
        a.*,
        confgi_type_name = CASE
                              WHEN a.config_type = 'notify' THEN N'<span class="bg-info noti-number ml5">Nội dung thông báo</span>'
                              WHEN a.config_type = 'file' THEN N'<span class="bg-secondary noti-number ml5">File tùy chỉnh</span>'
                           END,
        config_value_type_name = IIF(a.config_value IS NULL OR TRIM(a.config_value) = '', N'<span class="bg-primary noti-number ml5">Mặc định</span>', N'<span class="bg-warning noti-number ml5">Tùy chỉnh</span>'),
        config_value_display = CASE
                                  WHEN a.config_type = 'file' THEN b.file_name
                                  WHEN a.config_type = 'notify' THEN c.tempName
                                  ELSE a.config_value
                               END
    FROM
        #par_project_config_page a
        OUTER APPLY(SELECT TOP 1 * FROM meta_info b WHERE b.sourceOid = a.config_value ORDER BY b.Created DESC) b
        OUTER APPLY(SELECT TOP 1 * FROM NotifyTemplate c WHERE c.tempId = a.config_value) c
        
END TRY
BEGIN CATCH
    DECLARE @ErrorNum INT, @ErrorMsg VARCHAR(200), @ErrorProc VARCHAR(50), @SessionID INT, @AddlInfo VARCHAR(MAX)
    SET @ErrorNum = error_number()
    SET @ErrorMsg = 'Line: ' + CONVERT(nvarchar(300), error_line()) + ' Msg: ' + error_message();
    SET @ErrorProc = error_procedure()
    SET @AddlInfo = 'UserId: ' + CONVERT(NVARCHAR(50), @UserId)
    EXEC utl_ErrorLog_Set @ErrorNum, @ErrorMsg, @ErrorProc, '', '', @SessionID, @AddlInfo 
END CATCH