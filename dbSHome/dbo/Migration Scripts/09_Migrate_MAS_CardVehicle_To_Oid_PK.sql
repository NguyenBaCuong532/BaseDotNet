-- =============================================
-- Migrate MAS_CardVehicle: thêm cột oid, PK chuyển từ CardVehicleId sang oid
-- Giữ CardVehicleId (IDENTITY) với UNIQUE để tương thích FK và code hiện tại
-- Chạy sau: 04_Migrate_CardId_To_CardOid.sql (đã có cardOid)
-- =============================================
SET NOCOUNT ON;

BEGIN TRY
    -- 1. Thêm cột oid nếu chưa có
    IF NOT EXISTS (SELECT 1 FROM sys.columns WHERE object_id = OBJECT_ID('dbo.MAS_CardVehicle') AND name = 'oid')
    BEGIN
        ALTER TABLE [dbo].[MAS_CardVehicle] ADD [oid] UNIQUEIDENTIFIER NOT NULL CONSTRAINT [DF_MAS_CardVehicle_oid] DEFAULT (newid());
        PRINT '  ✓ Đã thêm cột oid vào MAS_CardVehicle';
    END
    ELSE
    BEGIN
        -- Đảm bảo oid NOT NULL cho PK
        IF EXISTS (SELECT 1 FROM sys.columns WHERE object_id = OBJECT_ID('dbo.MAS_CardVehicle') AND name = 'oid' AND is_nullable = 1)
        BEGIN
            UPDATE [dbo].[MAS_CardVehicle] SET [oid] = newid() WHERE [oid] IS NULL;
            ALTER TABLE [dbo].[MAS_CardVehicle] ALTER COLUMN [oid] UNIQUEIDENTIFIER NOT NULL;
            PRINT '  ✓ Cột oid đã set NOT NULL';
        END
    END

    -- 2. Drop PK hiện tại (CardVehicleId)
    IF EXISTS (SELECT 1 FROM sys.key_constraints WHERE parent_object_id = OBJECT_ID('dbo.MAS_CardVehicle') AND name = 'PK_MAS_CardVehicle')
    BEGIN
        ALTER TABLE [dbo].[MAS_CardVehicle] DROP CONSTRAINT [PK_MAS_CardVehicle];
        PRINT '  ✓ Đã drop PK cũ (CardVehicleId)';
    END

    -- 3. Thêm UNIQUE trên CardVehicleId (giữ tương thích LogMasVehicle, MAS_CardVehicle_H, SPs...)
    IF NOT EXISTS (SELECT 1 FROM sys.key_constraints WHERE parent_object_id = OBJECT_ID('dbo.MAS_CardVehicle') AND name = 'UQ_MAS_CardVehicle_CardVehicleId')
    BEGIN
        ALTER TABLE [dbo].[MAS_CardVehicle] ADD CONSTRAINT [UQ_MAS_CardVehicle_CardVehicleId] UNIQUE ([CardVehicleId]);
        PRINT '  ✓ Đã thêm UQ_MAS_CardVehicle_CardVehicleId';
    END

    -- 4. Tạo PK mới trên oid
    IF NOT EXISTS (SELECT 1 FROM sys.key_constraints WHERE parent_object_id = OBJECT_ID('dbo.MAS_CardVehicle') AND name = 'PK_MAS_CardVehicle')
    BEGIN
        ALTER TABLE [dbo].[MAS_CardVehicle] ADD CONSTRAINT [PK_MAS_CardVehicle] PRIMARY KEY CLUSTERED ([oid] ASC);
        PRINT '  ✓ Đã tạo PK mới trên oid';
    END

    PRINT 'MAS_CardVehicle: Thêm oid và migration PK sang oid hoàn tất.';
END TRY
BEGIN CATCH
    DECLARE @msg NVARCHAR(4000) = ERROR_MESSAGE();
    RAISERROR(N'09_Migrate_MAS_CardVehicle_To_Oid_PK: %s', 16, 1, @msg);
END CATCH;
