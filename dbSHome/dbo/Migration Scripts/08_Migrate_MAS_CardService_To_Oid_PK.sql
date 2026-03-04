-- =============================================
-- Migrate MAS_CardService: PK từ (ServiceId, CardId) sang oid
-- Chạy sau: 04_Migrate_CardId_To_CardOid.sql (đã có cột oid, cardOid)
-- =============================================
SET NOCOUNT ON;

BEGIN TRY
    -- 1. Đảm bảo cột oid tồn tại và NOT NULL
    IF NOT EXISTS (SELECT 1 FROM sys.columns WHERE object_id = OBJECT_ID('dbo.MAS_CardService') AND name = 'oid')
    BEGIN
        ALTER TABLE [dbo].[MAS_CardService] ADD [oid] UNIQUEIDENTIFIER NOT NULL CONSTRAINT [DF_MAS_CardService_oid] DEFAULT (newid());
        PRINT '  ✓ Đã thêm cột oid vào MAS_CardService';
    END
    ELSE
    BEGIN
        -- Đảm bảo oid NOT NULL cho PK
        IF EXISTS (SELECT 1 FROM sys.columns c JOIN sys.types t ON c.user_type_id = t.user_type_id
                   WHERE c.object_id = OBJECT_ID('dbo.MAS_CardService') AND c.name = 'oid' AND c.is_nullable = 1)
        BEGIN
            UPDATE [dbo].[MAS_CardService] SET [oid] = newid() WHERE [oid] IS NULL;
            ALTER TABLE [dbo].[MAS_CardService] ALTER COLUMN [oid] UNIQUEIDENTIFIER NOT NULL;
            PRINT '  ✓ Cột oid đã set NOT NULL';
        END
    END

    -- 2. Drop PK hiện tại (composite ServiceId, CardId)
    IF EXISTS (SELECT 1 FROM sys.key_constraints WHERE parent_object_id = OBJECT_ID('dbo.MAS_CardService') AND name = 'PK_MAS_CardService')
    BEGIN
        ALTER TABLE [dbo].[MAS_CardService] DROP CONSTRAINT [PK_MAS_CardService];
        PRINT '  ✓ Đã drop PK cũ (ServiceId, CardId)';
    END

    -- 3. Thêm UNIQUE trên (ServiceId, CardId) để giữ ràng buộc duy nhất
    IF NOT EXISTS (SELECT 1 FROM sys.key_constraints WHERE parent_object_id = OBJECT_ID('dbo.MAS_CardService') AND name = 'UQ_MAS_CardService_ServiceId_CardId')
    BEGIN
        ALTER TABLE [dbo].[MAS_CardService] ADD CONSTRAINT [UQ_MAS_CardService_ServiceId_CardId] UNIQUE ([ServiceId], [CardId]);
        PRINT '  ✓ Đã thêm UQ_MAS_CardService_ServiceId_CardId';
    END

    -- 4. Tạo PK mới trên oid
    IF NOT EXISTS (SELECT 1 FROM sys.key_constraints WHERE parent_object_id = OBJECT_ID('dbo.MAS_CardService') AND name = 'PK_MAS_CardService')
    BEGIN
        ALTER TABLE [dbo].[MAS_CardService] ADD CONSTRAINT [PK_MAS_CardService] PRIMARY KEY CLUSTERED ([oid] ASC);
        PRINT '  ✓ Đã tạo PK mới trên oid';
    END

    PRINT 'MAS_CardService: Migration PK sang oid hoàn tất.';
END TRY
BEGIN CATCH
    DECLARE @msg NVARCHAR(4000) = ERROR_MESSAGE();
    RAISERROR(N'08_Migrate_MAS_CardService_To_Oid_PK: %s', 16, 1, @msg);
END CATCH;
