-- =============================================
-- Author:      System
-- Create date: 2024
-- Description: Quản lý nhân viên - Danh sách dữ liệu phân trang
-- =============================================
CREATE OR ALTER PROCEDURE [dbo].[sp_res_employee_page]
    @UserId UNIQUEIDENTIFIER = NULL,
    @ClientId NVARCHAR(50) = NULL,
    @AcceptLanguage NVARCHAR(50) = N'vi-VN',
    @filter NVARCHAR(250) = NULL,
    @departmentName NVARCHAR(200) = NULL,
    @orgName NVARCHAR(200) = NULL,
    @companyName NVARCHAR(200) = NULL,
    @emp_st BIT = NULL,
    @GridWidth INT = 0,
    @Offset INT = 0,
    @PageSize INT = 10
AS
BEGIN TRY
    SET NOCOUNT ON;
    
    DECLARE @ViewGrid NVARCHAR(100) = 'view_employee_page';
    DECLARE @Total BIGINT = 0;
    DECLARE @RecordsFiltered BIGINT = 0;
    
    SET @Offset = ISNULL(@Offset, 0);
    SET @PageSize = ISNULL(@PageSize, 20);
    SET @filter = ISNULL(@filter, '');
    SET @departmentName = ISNULL(@departmentName, '');
    SET @orgName = ISNULL(@orgName, '');
    SET @companyName = ISNULL(@companyName, '');
    
    IF @PageSize <= 0 SET @PageSize = 20;
    IF @Offset < 0 SET @Offset = 0;
    
    -- Tính tổng số bản ghi
    SELECT @Total = COUNT(*)
    FROM mas_employee e
    WHERE (@filter = '' OR 
           e.fullName LIKE '%' + @filter + '%' OR 
           e.code LIKE '%' + @filter + '%' OR 
           e.custId LIKE '%' + @filter + '%' OR 
           e.email LIKE '%' + @filter + '%' OR 
           e.phone LIKE '%' + @filter + '%')
      AND (@departmentName = '' OR e.departmentName LIKE '%' + @departmentName + '%')
      AND (@orgName = '' OR e.orgName LIKE '%' + @orgName + '%')
      AND (@companyName = '' OR e.companyName LIKE '%' + @companyName + '%')
      AND (@emp_st IS NULL OR e.emp_st = @emp_st);
    
    -- Result Set 1: Summary
    SELECT 
        recordsTotal = @Total,
        recordsFiltered = @Total,
        gridKey = @ViewGrid;
    
    -- Result Set 2: Grid Config (chỉ khi Offset = 0)
    IF @Offset = 0
    BEGIN
        SELECT * 
        FROM dbo.fn_config_list_gets_lang(@ViewGrid, @GridWidth, @AcceptLanguage)
        ORDER BY ordinal;
    END
    
    -- Result Set 3: Data List
    SELECT 
        e.empId,
        e.code,
        e.custId,
        e.userId,
        e.fullName,
        e.email,
        e.phone,
        e.idcard_no,
        e.departmentName,
        e.orgName,
        e.companyName,
        e.positionTypeName,
        e.created_at,
        e.updated_at,
        e.emp_st
    FROM mas_employee e
    WHERE (@filter = '' OR 
           e.fullName LIKE '%' + @filter + '%' OR 
           e.code LIKE '%' + @filter + '%' OR 
           e.custId LIKE '%' + @filter + '%' OR 
           e.email LIKE '%' + @filter + '%' OR 
           e.phone LIKE '%' + @filter + '%')
      AND (@departmentName = '' OR e.departmentName LIKE '%' + @departmentName + '%')
      AND (@orgName = '' OR e.orgName LIKE '%' + @orgName + '%')
      AND (@companyName = '' OR e.companyName LIKE '%' + @companyName + '%')
      AND (@emp_st IS NULL OR e.emp_st = @emp_st)
    ORDER BY e.created_at DESC
    OFFSET @Offset ROWS
    FETCH NEXT @PageSize ROWS ONLY;

END TRY
BEGIN CATCH
    DECLARE @ErrorNum INT, @ErrorMsg VARCHAR(200), @ErrorProc VARCHAR(50), @SessionID INT, @AddlInfo VARCHAR(MAX)
    SET @ErrorNum = error_number()
    SET @ErrorMsg = 'Line: ' + CONVERT(NVARCHAR(300), error_line()) + ' Msg: ' + error_message();
    SET @ErrorProc = error_procedure()
    SET @AddlInfo = 'UserId: ' + CONVERT(NVARCHAR(50), @UserId)
    EXEC utl_ErrorLog_Set @ErrorNum, @ErrorMsg, @ErrorProc, '', '', @SessionID, @AddlInfo 
END CATCH

