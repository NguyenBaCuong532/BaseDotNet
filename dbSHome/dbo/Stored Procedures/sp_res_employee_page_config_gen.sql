-- =============================================
-- Script: Gen Config Data cho view_employee_page
-- Mô tả: Tạo config grid cho trang danh sách nhân viên
-- Author: System
-- Created: 2024
-- =============================================

-- Sử dụng MERGE để insert hoặc update config
MERGE [dbo].[sys_config_list] AS target
USING (
    VALUES
        -- empId - Mã nhân viên (ID)
        ('view_employee_page', 0, 'empId', N'Mã NV', 'Employee ID', 100, 'uniqueidentifier', 'text', NULL, NULL, NULL, 1, 1, 0, 0, 0, 0),
        
        -- code - Mã số nhân viên
        ('view_employee_page', 0, 'code', N'Mã số', 'Code', 100, 'nvarchar', 'text', NULL, NULL, NULL, 2, 1, 0, 0, 0, 1),
        
        -- custId - Mã khách hàng
        ('view_employee_page', 0, 'custId', N'Mã KH', 'Customer ID', 100, 'nvarchar', 'text', NULL, NULL, NULL, 3, 1, 0, 0, 0, 1),
        
        -- userId - Mã người dùng
        ('view_employee_page', 0, 'userId', N'Mã User', 'User ID', 120, 'nvarchar', 'text', NULL, NULL, NULL, 4, 1, 0, 0, 0, 0),
        
        -- fullName - Họ và tên
        ('view_employee_page', 0, 'fullName', N'Họ tên', 'Full Name', 200, 'nvarchar', 'text', NULL, NULL, NULL, 5, 1, 0, 0, 0, 1),
        
        -- email - Email
        ('view_employee_page', 0, 'email', N'Email', 'Email', 200, 'nvarchar', 'text', NULL, NULL, NULL, 6, 1, 0, 0, 0, 1),
        
        -- phone - Số điện thoại
        ('view_employee_page', 0, 'phone', N'Điện thoại', 'Phone', 120, 'nvarchar', 'text', NULL, NULL, NULL, 7, 1, 0, 0, 0, 1),
        
        -- idcard_no - Số CMND/CCCD
        ('view_employee_page', 0, 'idcard_no', N'CMND/CCCD', 'ID Card', 120, 'nvarchar', 'text', NULL, NULL, NULL, 8, 1, 0, 0, 0, 0),
        
        -- departmentName - Tên phòng ban
        ('view_employee_page', 0, 'departmentName', N'Phòng ban', 'Department', 150, 'nvarchar', 'text', NULL, NULL, NULL, 9, 1, 0, 0, 0, 1),
        
        -- orgName - Tên tổ chức
        ('view_employee_page', 0, 'orgName', N'Tổ chức', 'Organization', 150, 'nvarchar', 'text', NULL, NULL, NULL, 10, 1, 0, 0, 0, 1),
        
        -- companyName - Tên công ty
        ('view_employee_page', 0, 'companyName', N'Công ty', 'Company', 150, 'nvarchar', 'text', NULL, NULL, NULL, 11, 1, 0, 0, 0, 1),
        
        -- positionTypeName - Chức vụ
        ('view_employee_page', 0, 'positionTypeName', N'Chức vụ', 'Position', 150, 'nvarchar', 'text', NULL, NULL, NULL, 12, 1, 0, 0, 0, 0),
        
        -- created_at - Ngày tạo
        ('view_employee_page', 0, 'created_at', N'Ngày tạo', 'Created Date', 150, 'datetime', 'datetime', NULL, NULL, NULL, 13, 1, 0, 0, 0, 0),
        
        -- updated_at - Ngày cập nhật
        ('view_employee_page', 0, 'updated_at', N'Ngày cập nhật', 'Updated Date', 150, 'datetime', 'datetime', NULL, NULL, NULL, 14, 1, 0, 0, 0, 0),
        
        -- emp_st - Trạng thái
        ('view_employee_page', 0, 'emp_st', N'Trạng thái', 'Status', 100, 'bit', 'checkbox', 'text-center', NULL, NULL, 15, 1, 0, 0, 1, 0)
) AS source (
    [view_grid], [view_type], [columnField], [columnCaption], [columnCaptionE],
    [columnWidth], [data_type], [fieldType], [cellClass], [conditionClass],
    [pinned], [ordinal], [isUsed], [isHide], [isMasterDetail], [isStatusLable], [isFilter]
)
ON target.[view_grid] = source.[view_grid]
   AND target.[view_type] = source.[view_type]
   AND target.[columnField] = source.[columnField]
WHEN MATCHED THEN
    UPDATE SET
        [columnCaption] = source.[columnCaption],
        [columnCaptionE] = source.[columnCaptionE],
        [columnWidth] = source.[columnWidth],
        [data_type] = source.[data_type],
        [fieldType] = source.[fieldType],
        [cellClass] = source.[cellClass],
        [conditionClass] = source.[conditionClass],
        [pinned] = source.[pinned],
        [ordinal] = source.[ordinal],
        [isUsed] = source.[isUsed],
        [isHide] = source.[isHide],
        [isMasterDetail] = source.[isMasterDetail],
        [isStatusLable] = source.[isStatusLable],
        [isFilter] = source.[isFilter]
WHEN NOT MATCHED THEN
    INSERT (
        [view_grid], [view_type], [columnField], [columnCaption], [columnCaptionE],
        [columnWidth], [data_type], [fieldType], [cellClass], [conditionClass],
        [pinned], [ordinal], [isUsed], [isHide], [isMasterDetail], [isStatusLable], [isFilter]
    )
    VALUES (
        source.[view_grid], source.[view_type], source.[columnField], source.[columnCaption], source.[columnCaptionE],
        source.[columnWidth], source.[data_type], source.[fieldType], source.[cellClass], source.[conditionClass],
        source.[pinned], source.[ordinal], source.[isUsed], source.[isHide], source.[isMasterDetail], source.[isStatusLable], source.[isFilter]
    );

-- Kiểm tra kết quả
SELECT 
    id,
    view_grid,
    view_type,
    columnField,
    columnCaption,
    columnCaptionE,
    columnWidth,
    data_type,
    fieldType,
    cellClass,
    ordinal,
    isUsed,
    isHide,
    isFilter,
    isStatusLable
FROM [dbo].[sys_config_list]
WHERE view_grid = 'view_employee_page'
ORDER BY ordinal;

