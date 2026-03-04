-- =============================================
-- Migrate Elevator-related tables: oid làm PK (mã chính)
-- Nguyên tắc: Oid = mã chính; Id/code cũ = phụ (UQ để tương thích), có thể bỏ sau migrate.
-- Các bảng đã có cột oid; script thêm UQ trên khóa cũ và chuyển PK sang oid.
-- =============================================
SET NOCOUNT ON;

-- ----- 1. ELE_Building (Area) -----
BEGIN TRY
    IF NOT EXISTS (SELECT 1 FROM sys.key_constraints WHERE parent_object_id = OBJECT_ID('dbo.ELE_Building') AND name = 'UQ_ELE_Building_Id')
    BEGIN
        ALTER TABLE [dbo].[ELE_Building] ADD CONSTRAINT [UQ_ELE_Building_Id] UNIQUE ([Id]);
        PRINT '  ✓ ELE_Building: UQ(Id)';
    END
    IF EXISTS (SELECT 1 FROM sys.key_constraints WHERE parent_object_id = OBJECT_ID('dbo.ELE_Building') AND name = 'PK_ELE_Building')
    BEGIN
        ALTER TABLE [dbo].[ELE_Building] DROP CONSTRAINT [PK_ELE_Building];
        PRINT '  ✓ ELE_Building: drop PK(Id)';
    END
    IF NOT EXISTS (SELECT 1 FROM sys.key_constraints WHERE parent_object_id = OBJECT_ID('dbo.ELE_Building') AND name = 'PK_ELE_Building')
    BEGIN
        ALTER TABLE [dbo].[ELE_Building] ADD CONSTRAINT [PK_ELE_Building] PRIMARY KEY CLUSTERED ([oid] ASC);
        PRINT '  ✓ ELE_Building: PK(oid)';
    END
END TRY BEGIN CATCH
    DECLARE @msg1 NVARCHAR(4000) = ERROR_MESSAGE();
    PRINT '  ELE_Building: ' + @msg1;
END CATCH;

-- ----- 2. ELE_BuildZone (Zone) -----
BEGIN TRY
    IF NOT EXISTS (SELECT 1 FROM sys.key_constraints WHERE parent_object_id = OBJECT_ID('dbo.ELE_BuildZone') AND name = 'UQ_ELE_BuildZone_Id')
    BEGIN
        ALTER TABLE [dbo].[ELE_BuildZone] ADD CONSTRAINT [UQ_ELE_BuildZone_Id] UNIQUE ([Id]);
        PRINT '  ✓ ELE_BuildZone: UQ(Id)';
    END
    IF EXISTS (SELECT 1 FROM sys.key_constraints WHERE parent_object_id = OBJECT_ID('dbo.ELE_BuildZone') AND name = 'PK_ELE_BuildZone')
    BEGIN
        ALTER TABLE [dbo].[ELE_BuildZone] DROP CONSTRAINT [PK_ELE_BuildZone];
        PRINT '  ✓ ELE_BuildZone: drop PK(Id)';
    END
    IF NOT EXISTS (SELECT 1 FROM sys.key_constraints WHERE parent_object_id = OBJECT_ID('dbo.ELE_BuildZone') AND name = 'PK_ELE_BuildZone')
    BEGIN
        ALTER TABLE [dbo].[ELE_BuildZone] ADD CONSTRAINT [PK_ELE_BuildZone] PRIMARY KEY CLUSTERED ([oid] ASC);
        PRINT '  ✓ ELE_BuildZone: PK(oid)';
    END
END TRY BEGIN CATCH
    PRINT '  ELE_BuildZone: ' + ERROR_MESSAGE();
END CATCH;

-- ----- 3. MAS_Elevator_Floor -----
BEGIN TRY
    IF NOT EXISTS (SELECT 1 FROM sys.key_constraints WHERE parent_object_id = OBJECT_ID('dbo.MAS_Elevator_Floor') AND name = 'UQ_MAS_Elevator_Floor_Id')
    BEGIN
        ALTER TABLE [dbo].[MAS_Elevator_Floor] ADD CONSTRAINT [UQ_MAS_Elevator_Floor_Id] UNIQUE ([Id]);
        PRINT '  ✓ MAS_Elevator_Floor: UQ(Id)';
    END
    IF EXISTS (SELECT 1 FROM sys.key_constraints WHERE parent_object_id = OBJECT_ID('dbo.MAS_Elevator_Floor') AND name = 'PK_MAS_Elevator_Floor')
    BEGIN
        ALTER TABLE [dbo].[MAS_Elevator_Floor] DROP CONSTRAINT [PK_MAS_Elevator_Floor];
        PRINT '  ✓ MAS_Elevator_Floor: drop PK(Id)';
    END
    IF NOT EXISTS (SELECT 1 FROM sys.key_constraints WHERE parent_object_id = OBJECT_ID('dbo.MAS_Elevator_Floor') AND name = 'PK_MAS_Elevator_Floor')
    BEGIN
        ALTER TABLE [dbo].[MAS_Elevator_Floor] ADD CONSTRAINT [PK_MAS_Elevator_Floor] PRIMARY KEY CLUSTERED ([oid] ASC);
        PRINT '  ✓ MAS_Elevator_Floor: PK(oid)';
    END
END TRY BEGIN CATCH
    PRINT '  MAS_Elevator_Floor: ' + ERROR_MESSAGE();
END CATCH;

-- ----- 4. MAS_Elevator_Device (PK hiện tại: HardwareId) -----
BEGIN TRY
    IF NOT EXISTS (SELECT 1 FROM sys.key_constraints WHERE parent_object_id = OBJECT_ID('dbo.MAS_Elevator_Device') AND name = 'UQ_MAS_Elevator_Device_HardwareId')
    BEGIN
        ALTER TABLE [dbo].[MAS_Elevator_Device] ADD CONSTRAINT [UQ_MAS_Elevator_Device_HardwareId] UNIQUE ([HardwareId]);
        PRINT '  ✓ MAS_Elevator_Device: UQ(HardwareId)';
    END
    IF EXISTS (SELECT 1 FROM sys.key_constraints WHERE parent_object_id = OBJECT_ID('dbo.MAS_Elevator_Device') AND name = 'PK_MAS_Elevator_Device')
    BEGIN
        ALTER TABLE [dbo].[MAS_Elevator_Device] DROP CONSTRAINT [PK_MAS_Elevator_Device];
        PRINT '  ✓ MAS_Elevator_Device: drop PK(HardwareId)';
    END
    IF NOT EXISTS (SELECT 1 FROM sys.key_constraints WHERE parent_object_id = OBJECT_ID('dbo.MAS_Elevator_Device') AND name = 'PK_MAS_Elevator_Device')
    BEGIN
        ALTER TABLE [dbo].[MAS_Elevator_Device] ADD CONSTRAINT [PK_MAS_Elevator_Device] PRIMARY KEY CLUSTERED ([oid] ASC);
        PRINT '  ✓ MAS_Elevator_Device: PK(oid)';
    END
END TRY BEGIN CATCH
    PRINT '  MAS_Elevator_Device: ' + ERROR_MESSAGE();
END CATCH;

-- ----- 5. MAS_Elevator_Device_Category -----
BEGIN TRY
    IF NOT EXISTS (SELECT 1 FROM sys.key_constraints WHERE parent_object_id = OBJECT_ID('dbo.MAS_Elevator_Device_Category') AND name = 'UQ_MAS_Elevator_Device_Category_Id')
    BEGIN
        ALTER TABLE [dbo].[MAS_Elevator_Device_Category] ADD CONSTRAINT [UQ_MAS_Elevator_Device_Category_Id] UNIQUE ([Id]);
        PRINT '  ✓ MAS_Elevator_Device_Category: UQ(Id)';
    END
    IF EXISTS (SELECT 1 FROM sys.key_constraints WHERE parent_object_id = OBJECT_ID('dbo.MAS_Elevator_Device_Category') AND name = 'PK_MAS_Elevator_Device_Category')
    BEGIN
        ALTER TABLE [dbo].[MAS_Elevator_Device_Category] DROP CONSTRAINT [PK_MAS_Elevator_Device_Category];
        PRINT '  ✓ MAS_Elevator_Device_Category: drop PK(Id)';
    END
    IF NOT EXISTS (SELECT 1 FROM sys.key_constraints WHERE parent_object_id = OBJECT_ID('dbo.MAS_Elevator_Device_Category') AND name = 'PK_MAS_Elevator_Device_Category')
    BEGIN
        ALTER TABLE [dbo].[MAS_Elevator_Device_Category] ADD CONSTRAINT [PK_MAS_Elevator_Device_Category] PRIMARY KEY CLUSTERED ([oid] ASC);
        PRINT '  ✓ MAS_Elevator_Device_Category: PK(oid)';
    END
END TRY BEGIN CATCH
    PRINT '  MAS_Elevator_Device_Category: ' + ERROR_MESSAGE();
END CATCH;

-- ----- 6. MAS_Elevator_Card -----
BEGIN TRY
    IF NOT EXISTS (SELECT 1 FROM sys.key_constraints WHERE parent_object_id = OBJECT_ID('dbo.MAS_Elevator_Card') AND name = 'UQ_MAS_Elevator_Card_Id')
    BEGIN
        ALTER TABLE [dbo].[MAS_Elevator_Card] ADD CONSTRAINT [UQ_MAS_Elevator_Card_Id] UNIQUE ([Id]);
        PRINT '  ✓ MAS_Elevator_Card: UQ(Id)';
    END
    IF EXISTS (SELECT 1 FROM sys.key_constraints WHERE parent_object_id = OBJECT_ID('dbo.MAS_Elevator_Card') AND name = 'PK_MAS_Elevator_Card')
    BEGIN
        ALTER TABLE [dbo].[MAS_Elevator_Card] DROP CONSTRAINT [PK_MAS_Elevator_Card];
        PRINT '  ✓ MAS_Elevator_Card: drop PK';
    END
    IF NOT EXISTS (SELECT 1 FROM sys.key_constraints WHERE parent_object_id = OBJECT_ID('dbo.MAS_Elevator_Card') AND name = 'PK_MAS_Elevator_Card')
    BEGIN
        ALTER TABLE [dbo].[MAS_Elevator_Card] ADD CONSTRAINT [PK_MAS_Elevator_Card] PRIMARY KEY CLUSTERED ([Oid] ASC);
        PRINT '  ✓ MAS_Elevator_Card: PK(Oid)';
    END
END TRY BEGIN CATCH
    PRINT '  MAS_Elevator_Card: ' + ERROR_MESSAGE();
END CATCH;

PRINT '10_Migrate_Elevator_Tables_To_Oid_PK: Hoàn tất.';
