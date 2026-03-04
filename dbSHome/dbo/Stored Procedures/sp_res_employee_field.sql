-- =============================================
-- Author:      System
-- Create date: 2024
-- Description: Quản lý nhân viên - Lấy thông tin chi tiết
-- =============================================
CREATE OR ALTER PROCEDURE [dbo].[sp_res_employee_field]
    @UserId UNIQUEIDENTIFIER = NULL,
    @ClientId NVARCHAR(50) = NULL,
    @AcceptLanguage NVARCHAR(50) = N'vi-VN',
    @empId UNIQUEIDENTIFIER = NULL
AS
BEGIN TRY
    SET NOCOUNT ON;
    
    DECLARE @GroupKey NVARCHAR(100) = 'common_group';
    DECLARE @TableName NVARCHAR(100) = 'mas_employee';
    
    -- Config Info
    SELECT 
        @empId AS empId,
        @TableName AS tableKey,
        @GroupKey AS groupKey;
    
    -- Get Group Info
    SELECT * 
    FROM [dbo].[fn_get_field_group_lang](@GroupKey, @AcceptLanguage) 
    ORDER BY intOrder;
    
    -- Tạo temp table với structure đầy đủ
    SELECT TOP 0 b.*
    INTO #tempIn
    FROM mas_employee b;
    
    -- Insert dữ liệu nếu có record
    IF EXISTS (SELECT 1 FROM mas_employee WHERE empId = @empId)
    BEGIN
        INSERT INTO #tempIn
        SELECT b.*
        FROM mas_employee b
        WHERE b.empId = @empId;
    END
    ELSE
    BEGIN
        -- Nếu không có dữ liệu, tạo record mới với đầy đủ columns
        IF @empId IS NULL SET @empId = NEWID();
        
        -- Tạo record mới với giá trị mặc định
        INSERT INTO #tempIn (
            [empId], [code], [custId], [userId], [fullName], [email], [phone], 
            [idcard_no], [departmentName], [orgName], [companyName], [positionTypeName],
            [created_at], [updated_at], [emp_st]
        ) 
        VALUES (
            @empId, 
            '', '', '', '', '', '',  -- code, custId, userId, fullName, email, phone, idcard_no
            '', '', '', '',          -- departmentName, orgName, companyName, positionTypeName
            SYSUTCDATETIME(), NULL,  -- created_at, updated_at
            NULL                     -- emp_st
        );
    END
    
    -- Fields Info
    SELECT
        CASE [data_type] 
            WHEN 'uniqueidentifier' THEN CONVERT(NVARCHAR(MAX), 
                CASE [field_name]
                    WHEN 'empId' THEN b.empId
                END)
            WHEN 'nvarchar' THEN CONVERT(NVARCHAR(MAX), 
                CASE [field_name]
                    WHEN 'code' THEN b.code
                    WHEN 'custId' THEN b.custId
                    WHEN 'userId' THEN b.userId
                    WHEN 'fullName' THEN b.fullName
                    WHEN 'email' THEN b.email
                    WHEN 'phone' THEN b.phone
                    WHEN 'idcard_no' THEN b.idcard_no
                    WHEN 'departmentName' THEN b.departmentName
                    WHEN 'orgName' THEN b.orgName
                    WHEN 'companyName' THEN b.companyName
                    WHEN 'positionTypeName' THEN b.positionTypeName
                END)
            WHEN 'datetime' THEN CONVERT(NVARCHAR(50), 
                CASE [field_name]
                    WHEN 'created_at' THEN FORMAT(b.created_at, 'dd/MM/yyyy HH:mm:ss')
                    WHEN 'updated_at' THEN FORMAT(b.updated_at, 'dd/MM/yyyy HH:mm:ss')
                END)
            WHEN 'bit' THEN CONVERT(NVARCHAR(10), 
                CASE [field_name]
                    WHEN 'emp_st' THEN b.emp_st
                END)
        END AS columnValue,
        a.id,
        a.[field_name],
        a.[view_type],
        a.[data_type],
        a.[ordinal],
        a.[columnLabel],
        a.group_cd,
        a.[columnClass],
        a.[columnType],
        a.[columnObject],
        a.[isSpecial],
        a.[isRequire],
        a.[isDisable],
        a.[IsVisiable],
        a.[IsEmpty],
        ISNULL(a.columnTooltip, a.[columnLabel]) AS columnTooltip,
        a.[columnDisplay],
        a.[isIgnore]
    FROM
        dbo.[fn_config_form_gets](@TableName, @AcceptLanguage) a
        OUTER APPLY (SELECT TOP 1 * FROM #tempIn) b
    --WHERE (a.isVisiable = 1 OR a.isRequire = 1)
    ORDER BY a.group_cd, a.ordinal;
    
    -- Cleanup
    DROP TABLE IF EXISTS #tempIn;

END TRY
BEGIN CATCH
    DECLARE @ErrorNum INT, @ErrorMsg VARCHAR(200), @ErrorProc VARCHAR(50), @SessionID INT, @AddlInfo VARCHAR(MAX)
    SET @ErrorNum = error_number()
    SET @ErrorMsg = 'Line: ' + CONVERT(NVARCHAR(300), error_line()) + ' Msg: ' + error_message();
    SET @ErrorProc = error_procedure()
    SET @AddlInfo = 'UserId: ' + CONVERT(NVARCHAR(50), @UserId)
    EXEC utl_ErrorLog_Set @ErrorNum, @ErrorMsg, @ErrorProc, '', '', @SessionID, @AddlInfo 
END CATCH

