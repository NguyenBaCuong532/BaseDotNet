-- =============================================
-- Đổi tên bảng ELE_Building thành ELE_BuildArea
-- Chạy sau khi đã có bảng ELE_Building (sau script 10 nếu dùng).
-- =============================================
SET NOCOUNT ON;

IF OBJECT_ID('dbo.ELE_Building', 'U') IS NOT NULL
BEGIN
    -- Đổi tên bảng
    EXEC sp_rename 'dbo.ELE_Building', 'ELE_BuildArea';
    PRINT '  ✓ Table renamed: ELE_Building -> ELE_BuildArea';

    -- Đổi tên constraint (object type = OBJECT cho constraint)
    IF EXISTS (SELECT 1 FROM sys.key_constraints WHERE parent_object_id = OBJECT_ID('dbo.ELE_BuildArea') AND name = 'PK_ELE_Building')
    BEGIN
        EXEC sp_rename 'dbo.ELE_BuildArea.PK_ELE_Building', 'PK_ELE_BuildArea', 'OBJECT';
        PRINT '  ✓ PK_ELE_Building -> PK_ELE_BuildArea';
    END
    IF EXISTS (SELECT 1 FROM sys.foreign_keys WHERE parent_object_id = OBJECT_ID('dbo.ELE_BuildArea') AND name = 'FK_ELE_Building_tenant_oid')
    BEGIN
        EXEC sp_rename 'dbo.ELE_BuildArea.FK_ELE_Building_tenant_oid', 'FK_ELE_BuildArea_tenant_oid', 'OBJECT';
        PRINT '  ✓ FK_ELE_Building_tenant_oid -> FK_ELE_BuildArea_tenant_oid';
    END
    IF EXISTS (SELECT 1 FROM sys.key_constraints WHERE parent_object_id = OBJECT_ID('dbo.ELE_BuildArea') AND name = 'UQ_ELE_Building_Id')
    BEGIN
        EXEC sp_rename 'dbo.ELE_BuildArea.UQ_ELE_Building_Id', 'UQ_ELE_BuildArea_Id', 'OBJECT';
        PRINT '  ✓ UQ_ELE_Building_Id -> UQ_ELE_BuildArea_Id';
    END
    IF EXISTS (SELECT 1 FROM sys.default_constraints WHERE parent_object_id = OBJECT_ID('dbo.ELE_BuildArea') AND name = 'DF_ELE_Building_SysDate')
    BEGIN
        EXEC sp_rename 'dbo.ELE_BuildArea.DF_ELE_Building_SysDate', 'DF_ELE_BuildArea_SysDate', 'OBJECT';
        PRINT '  ✓ DF_ELE_Building_SysDate -> DF_ELE_BuildArea_SysDate';
    END
    IF EXISTS (SELECT 1 FROM sys.default_constraints WHERE parent_object_id = OBJECT_ID('dbo.ELE_BuildArea') AND name = 'DF_ELE_Building_oid')
    BEGIN
        EXEC sp_rename 'dbo.ELE_BuildArea.DF_ELE_Building_oid', 'DF_ELE_BuildArea_oid', 'OBJECT';
        PRINT '  ✓ DF_ELE_Building_oid -> DF_ELE_BuildArea_oid';
    END
    -- Cập nhật sys_config_form nếu có cấu hình form theo tên bảng cũ
    IF OBJECT_ID('dbo.sys_config_form', 'U') IS NOT NULL
    BEGIN
        UPDATE dbo.sys_config_form SET table_name = 'ELE_BuildArea' WHERE table_name = 'ELE_Building';
        IF @@ROWCOUNT > 0
            PRINT '  ✓ sys_config_form: table_name ELE_Building -> ELE_BuildArea';
    END
END
ELSE
    PRINT '  Table dbo.ELE_Building not found; skip rename.';

GO
