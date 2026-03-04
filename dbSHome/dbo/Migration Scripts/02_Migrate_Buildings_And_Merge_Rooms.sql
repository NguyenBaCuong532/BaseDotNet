-- =============================================
-- Migration Script: 
-- 1. Chuyển đổi MAS_Buildings PK từ BuildingCd → oid
-- 2. Merge MAS_Rooms vào MAS_Apartments (bỏ bảng MAS_Rooms)
-- 3. Thêm buildingOid vào MAS_Apartments và MAS_Apartments_Save
-- Author: System
-- Created: 2024
-- =============================================
-- 
-- QUAN TRỌNG: 
-- 1. Backup database trước khi chạy script này
-- 2. Chạy trên môi trường DEV/STAGING trước
-- 3. Test kỹ lưỡng trước khi áp dụng lên PRODUCTION
-- 4. Script này có thể chạy nhiều lần (idempotent)
--
-- =============================================

SET NOCOUNT ON;
GO

BEGIN TRANSACTION;
BEGIN TRY

    PRINT '========================================';
    PRINT 'Bắt đầu Migration: Buildings & Merge Rooms';
    PRINT '========================================';
    PRINT '';

    -- =============================================
    -- BƯỚC 1: Chuyển Primary Key của MAS_Buildings từ BuildingCd → oid
    -- =============================================
    PRINT 'BƯỚC 1: Chuyển Primary Key của MAS_Buildings từ BuildingCd → oid...';
    PRINT '';

    -- Kiểm tra xem đã chuyển PK chưa
    DECLARE @BuildingsCurrentPK NVARCHAR(200);
    SELECT @BuildingsCurrentPK = c.name
    FROM sys.key_constraints kc
    INNER JOIN sys.index_columns ic ON kc.parent_object_id = ic.object_id AND kc.unique_index_id = ic.index_id
    INNER JOIN sys.columns c ON ic.object_id = c.object_id AND ic.column_id = c.column_id
    WHERE kc.type = 'PK' AND kc.parent_object_id = OBJECT_ID('dbo.MAS_Buildings');

    IF @BuildingsCurrentPK = 'BuildingCd'
    BEGIN
        -- Đảm bảo tất cả oid đều có giá trị và unique
        IF EXISTS (SELECT 1 FROM [dbo].[MAS_Buildings] WHERE [oid] IS NULL)
        BEGIN
            RAISERROR('Có bản ghi trong MAS_Buildings có oid = NULL. Vui lòng kiểm tra!', 16, 1);
        END

        IF EXISTS (
            SELECT [oid], COUNT(*) as cnt
            FROM [dbo].[MAS_Buildings]
            GROUP BY [oid]
            HAVING COUNT(*) > 1
        )
        BEGIN
            RAISERROR('Có oid trùng lặp trong MAS_Buildings. Vui lòng kiểm tra!', 16, 1);
        END

        -- Xóa Primary Key cũ
        ALTER TABLE [dbo].[MAS_Buildings]
        DROP CONSTRAINT [PK_MAS_Buildings];
        PRINT '  ✓ Đã xóa Primary Key cũ (PK_MAS_Buildings)';

        -- Tạo Primary Key mới với oid
        ALTER TABLE [dbo].[MAS_Buildings]
        ADD CONSTRAINT [PK_MAS_Buildings] PRIMARY KEY CLUSTERED ([oid] ASC);
        PRINT '  ✓ Đã tạo Primary Key mới với oid';

        -- Tạo Unique Index cho BuildingCd (để backward compatibility)
        IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = 'IX_MAS_Buildings_BuildingCd_Unique' AND object_id = OBJECT_ID('dbo.MAS_Buildings'))
        BEGIN
            CREATE UNIQUE NONCLUSTERED INDEX [IX_MAS_Buildings_BuildingCd_Unique]
            ON [dbo].[MAS_Buildings]([BuildingCd] ASC);
            PRINT '  ✓ Đã tạo Unique Index cho BuildingCd (backward compatibility)';
        END
    END
    ELSE IF @BuildingsCurrentPK = 'oid'
    BEGIN
        PRINT '  - Primary Key đã được chuyển sang oid rồi';
    END
    ELSE
    BEGIN
        PRINT '  ⚠ Cảnh báo: Primary Key hiện tại không phải BuildingCd hoặc oid: ' + @BuildingsCurrentPK;
    END

    PRINT '';
    PRINT 'Hoàn thành BƯỚC 1';
    PRINT '';

    -- =============================================
    -- BƯỚC 2: Thêm cột buildingOid vào MAS_Apartments và MAS_Apartments_Save
    -- =============================================
    PRINT 'BƯỚC 2: Thêm cột buildingOid vào MAS_Apartments và MAS_Apartments_Save...';
    PRINT '';

    -- MAS_Apartments
    IF NOT EXISTS (SELECT 1 FROM sys.columns WHERE object_id = OBJECT_ID('dbo.MAS_Apartments') AND name = 'buildingOid')
    BEGIN
        ALTER TABLE [dbo].[MAS_Apartments]
        ADD [buildingOid] UNIQUEIDENTIFIER NULL;
        PRINT '  ✓ Đã thêm cột buildingOid vào MAS_Apartments';
    END
    ELSE
        PRINT '  - Cột buildingOid đã tồn tại trong MAS_Apartments';

    -- MAS_Apartments_Save
    IF EXISTS (SELECT 1 FROM sys.tables WHERE name = 'MAS_Apartments_Save')
    AND NOT EXISTS (SELECT 1 FROM sys.columns WHERE object_id = OBJECT_ID('dbo.MAS_Apartments_Save') AND name = 'buildingOid')
    BEGIN
        ALTER TABLE [dbo].[MAS_Apartments_Save]
        ADD [buildingOid] UNIQUEIDENTIFIER NULL;
        PRINT '  ✓ Đã thêm cột buildingOid vào MAS_Apartments_Save';
    END
    ELSE IF EXISTS (SELECT 1 FROM sys.tables WHERE name = 'MAS_Apartments_Save')
        PRINT '  - Cột buildingOid đã tồn tại trong MAS_Apartments_Save';

    PRINT '';
    PRINT 'Hoàn thành BƯỚC 2';
    PRINT '';

    -- =============================================
    -- BƯỚC 3: Populate buildingOid từ buildingCd
    -- =============================================
    PRINT 'BƯỚC 3: Populate buildingOid từ buildingCd...';
    PRINT '';

    -- MAS_Apartments: Populate từ buildingCd
    UPDATE a
    SET a.[buildingOid] = b.[oid]
    FROM [dbo].[MAS_Apartments] a
    INNER JOIN [dbo].[MAS_Buildings] b ON a.[buildingCd] = b.[BuildingCd]
    WHERE a.[buildingOid] IS NULL AND a.[buildingCd] IS NOT NULL;
    PRINT '  ✓ Đã populate buildingOid cho MAS_Apartments: ' + CAST(@@ROWCOUNT AS NVARCHAR(10)) + ' rows';

    -- MAS_Apartments_Save: Populate từ buildingCd
    IF EXISTS (SELECT 1 FROM sys.tables WHERE name = 'MAS_Apartments_Save')
    BEGIN
        UPDATE asave
        SET asave.[buildingOid] = b.[oid]
        FROM [dbo].[MAS_Apartments_Save] asave
        INNER JOIN [dbo].[MAS_Buildings] b ON asave.[buildingCd] = b.[BuildingCd]
        WHERE asave.[buildingOid] IS NULL AND asave.[buildingCd] IS NOT NULL;
        PRINT '  ✓ Đã populate buildingOid cho MAS_Apartments_Save: ' + CAST(@@ROWCOUNT AS NVARCHAR(10)) + ' rows';
    END

    PRINT '';
    PRINT 'Hoàn thành BƯỚC 3';
    PRINT '';

    -- =============================================
    -- BƯỚC 4: Merge dữ liệu từ MAS_Rooms vào MAS_Apartments
    -- =============================================
    PRINT 'BƯỚC 4: Merge dữ liệu từ MAS_Rooms vào MAS_Apartments...';
    PRINT '';

    -- Kiểm tra xem MAS_Rooms có tồn tại không
    IF EXISTS (SELECT 1 FROM sys.tables WHERE name = 'MAS_Rooms')
    BEGIN
        -- Merge dữ liệu: Cập nhật các trường từ MAS_Rooms vào MAS_Apartments qua RoomCode
        -- Các trường cần merge: Floor, WallArea, WaterwayArea, floorNo, BuildingCd (nếu chưa có)
        
        -- Thêm cột Floor vào MAS_Apartments nếu chưa có
        IF NOT EXISTS (SELECT 1 FROM sys.columns WHERE object_id = OBJECT_ID('dbo.MAS_Apartments') AND name = 'Floor')
        BEGIN
            ALTER TABLE [dbo].[MAS_Apartments]
            ADD [Floor] DECIMAL(18, 2) NULL;
            PRINT '  ✓ Đã thêm cột Floor vào MAS_Apartments';
        END

        -- Cập nhật Floor từ MAS_Rooms
        UPDATE a
        SET a.[Floor] = r.[Floor]
        FROM [dbo].[MAS_Apartments] a
        INNER JOIN [dbo].[MAS_Rooms] r ON a.[RoomCode] = r.[RoomCode]
        WHERE a.[Floor] IS NULL AND r.[Floor] IS NOT NULL;
        PRINT '  ✓ Đã merge Floor: ' + CAST(@@ROWCOUNT AS NVARCHAR(10)) + ' rows';

        -- Cập nhật WallArea từ MAS_Rooms (nếu MAS_Apartments.WallArea NULL hoặc khác)
        UPDATE a
        SET a.[WallArea] = r.[WallArea]
        FROM [dbo].[MAS_Apartments] a
        INNER JOIN [dbo].[MAS_Rooms] r ON a.[RoomCode] = r.[RoomCode]
        WHERE (a.[WallArea] IS NULL OR a.[WallArea] = 0) AND r.[WallArea] IS NOT NULL;
        PRINT '  ✓ Đã merge WallArea: ' + CAST(@@ROWCOUNT AS NVARCHAR(10)) + ' rows';

        -- Cập nhật WaterwayArea từ MAS_Rooms (nếu MAS_Apartments.WaterwayArea NULL hoặc khác)
        UPDATE a
        SET a.[WaterwayArea] = r.[WaterwayArea]
        FROM [dbo].[MAS_Apartments] a
        INNER JOIN [dbo].[MAS_Rooms] r ON a.[RoomCode] = r.[RoomCode]
        WHERE (a.[WaterwayArea] IS NULL OR a.[WaterwayArea] = 0) AND r.[WaterwayArea] IS NOT NULL;
        PRINT '  ✓ Đã merge WaterwayArea: ' + CAST(@@ROWCOUNT AS NVARCHAR(10)) + ' rows';

        -- Thêm cột floorNo vào MAS_Apartments nếu chưa có
        IF NOT EXISTS (SELECT 1 FROM sys.columns WHERE object_id = OBJECT_ID('dbo.MAS_Apartments') AND name = 'floorNo')
        BEGIN
            ALTER TABLE [dbo].[MAS_Apartments]
            ADD [floorNo] NVARCHAR(50) NULL;
            PRINT '  ✓ Đã thêm cột floorNo vào MAS_Apartments';
        END

        -- Cập nhật floorNo từ MAS_Rooms
        UPDATE a
        SET a.[floorNo] = r.[floorNo]
        FROM [dbo].[MAS_Apartments] a
        INNER JOIN [dbo].[MAS_Rooms] r ON a.[RoomCode] = r.[RoomCode]
        WHERE (a.[floorNo] IS NULL OR a.[floorNo] = '') AND r.[floorNo] IS NOT NULL;
        PRINT '  ✓ Đã merge floorNo: ' + CAST(@@ROWCOUNT AS NVARCHAR(10)) + ' rows';

        -- Cập nhật buildingCd từ MAS_Rooms (nếu MAS_Apartments.buildingCd NULL)
        UPDATE a
        SET a.[buildingCd] = r.[BuildingCd],
            a.[buildingOid] = b.[oid]
        FROM [dbo].[MAS_Apartments] a
        INNER JOIN [dbo].[MAS_Rooms] r ON a.[RoomCode] = r.[RoomCode]
        LEFT JOIN [dbo].[MAS_Buildings] b ON r.[BuildingCd] = b.[BuildingCd]
        WHERE a.[buildingCd] IS NULL AND r.[BuildingCd] IS NOT NULL;
        PRINT '  ✓ Đã merge buildingCd và buildingOid: ' + CAST(@@ROWCOUNT AS NVARCHAR(10)) + ' rows';

        -- Thêm cột RoomCodeView vào MAS_Apartments nếu chưa có
        IF NOT EXISTS (SELECT 1 FROM sys.columns WHERE object_id = OBJECT_ID('dbo.MAS_Apartments') AND name = 'RoomCodeView')
        BEGIN
            ALTER TABLE [dbo].[MAS_Apartments]
            ADD [RoomCodeView] NVARCHAR(50) NULL;
            PRINT '  ✓ Đã thêm cột RoomCodeView vào MAS_Apartments';
        END

        -- Cập nhật RoomCodeView từ MAS_Rooms
        UPDATE a
        SET a.[RoomCodeView] = r.[RoomCodeView]
        FROM [dbo].[MAS_Apartments] a
        INNER JOIN [dbo].[MAS_Rooms] r ON a.[RoomCode] = r.[RoomCode]
        WHERE (a.[RoomCodeView] IS NULL OR a.[RoomCodeView] = '') AND r.[RoomCodeView] IS NOT NULL;
        PRINT '  ✓ Đã merge RoomCodeView: ' + CAST(@@ROWCOUNT AS NVARCHAR(10)) + ' rows';

        PRINT '';
        PRINT '  ⚠ LƯU Ý: Sau khi kiểm tra dữ liệu đã merge đúng, có thể xóa bảng MAS_Rooms';
        PRINT '  -- DROP TABLE [dbo].[MAS_Rooms];';
    END
    ELSE
    BEGIN
        PRINT '  - Bảng MAS_Rooms không tồn tại, bỏ qua bước merge';
    END

    PRINT '';
    PRINT 'Hoàn thành BƯỚC 4';
    PRINT '';

    -- =============================================
    -- BƯỚC 5: Tạo Index cho buildingOid
    -- =============================================
    PRINT 'BƯỚC 5: Tạo Index cho buildingOid...';
    PRINT '';

    -- MAS_Apartments
    IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = 'IX_MAS_Apartments_buildingOid' AND object_id = OBJECT_ID('dbo.MAS_Apartments'))
    BEGIN
        CREATE NONCLUSTERED INDEX [IX_MAS_Apartments_buildingOid]
        ON [dbo].[MAS_Apartments]([buildingOid] ASC);
        PRINT '  ✓ Đã tạo index IX_MAS_Apartments_buildingOid';
    END

    -- MAS_Apartments_Save
    IF EXISTS (SELECT 1 FROM sys.tables WHERE name = 'MAS_Apartments_Save')
    AND NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = 'IX_MAS_Apartments_Save_buildingOid' AND object_id = OBJECT_ID('dbo.MAS_Apartments_Save'))
    BEGIN
        CREATE NONCLUSTERED INDEX [IX_MAS_Apartments_Save_buildingOid]
        ON [dbo].[MAS_Apartments_Save]([buildingOid] ASC);
        PRINT '  ✓ Đã tạo index IX_MAS_Apartments_Save_buildingOid';
    END

    PRINT '';
    PRINT 'Hoàn thành BƯỚC 5';
    PRINT '';

    -- =============================================
    -- BƯỚC 6: Tạo Foreign Key từ buildingOid → MAS_Buildings.oid
    -- =============================================
    PRINT 'BƯỚC 6: Tạo Foreign Key từ buildingOid → MAS_Buildings.oid...';
    PRINT '';

    -- MAS_Apartments
    IF NOT EXISTS (SELECT 1 FROM sys.foreign_keys WHERE name = 'FK_MAS_Apartments_buildingOid')
    BEGIN
        ALTER TABLE [dbo].[MAS_Apartments]
        ADD CONSTRAINT [FK_MAS_Apartments_buildingOid]
        FOREIGN KEY ([buildingOid]) REFERENCES [dbo].[MAS_Buildings]([oid]);
        PRINT '  ✓ Đã tạo FK FK_MAS_Apartments_buildingOid';
    END
    ELSE
        PRINT '  - FK FK_MAS_Apartments_buildingOid đã tồn tại';

    -- MAS_Apartments_Save
    IF EXISTS (SELECT 1 FROM sys.tables WHERE name = 'MAS_Apartments_Save')
    AND NOT EXISTS (SELECT 1 FROM sys.foreign_keys WHERE name = 'FK_MAS_Apartments_Save_buildingOid')
    BEGIN
        ALTER TABLE [dbo].[MAS_Apartments_Save]
        ADD CONSTRAINT [FK_MAS_Apartments_Save_buildingOid]
        FOREIGN KEY ([buildingOid]) REFERENCES [dbo].[MAS_Buildings]([oid]);
        PRINT '  ✓ Đã tạo FK FK_MAS_Apartments_Save_buildingOid';
    END
    ELSE IF EXISTS (SELECT 1 FROM sys.tables WHERE name = 'MAS_Apartments_Save')
        PRINT '  - FK FK_MAS_Apartments_Save_buildingOid đã tồn tại';

    PRINT '';
    PRINT 'Hoàn thành BƯỚC 6';
    PRINT '';

    -- =============================================
    -- HOÀN THÀNH
    -- =============================================
    PRINT '========================================';
    PRINT 'Migration hoàn thành thành công!';
    PRINT '========================================';
    PRINT '';
    PRINT 'TÓM TẮT:';
    PRINT '1. ✓ Đã chuyển PK của MAS_Buildings từ BuildingCd → oid';
    PRINT '2. ✓ Đã thêm buildingOid vào MAS_Apartments và MAS_Apartments_Save';
    PRINT '3. ✓ Đã populate buildingOid từ buildingCd';
    PRINT '4. ✓ Đã merge dữ liệu từ MAS_Rooms vào MAS_Apartments';
    PRINT '5. ✓ Đã tạo Index và Foreign Key';
    PRINT '';
    PRINT 'CÁC BƯỚC TIẾP THEO:';
    PRINT '1. Kiểm tra dữ liệu đã được merge đúng chưa';
    PRINT '2. Cập nhật Stored Procedures để sử dụng buildingOid thay vì buildingCd';
    PRINT '3. Cập nhật Application Code để sử dụng buildingOid';
    PRINT '4. Sau khi đảm bảo không còn sử dụng MAS_Rooms, có thể xóa bảng (tùy chọn)';
    PRINT '5. Sau khi đảm bảo không còn sử dụng buildingCd, có thể xóa cột (tùy chọn)';
    PRINT '';

    COMMIT TRANSACTION;
    PRINT 'Transaction đã được commit';

END TRY
BEGIN CATCH
    IF @@TRANCOUNT > 0
        ROLLBACK TRANSACTION;

    DECLARE @ErrorMessage NVARCHAR(4000) = ERROR_MESSAGE();
    DECLARE @ErrorSeverity INT = ERROR_SEVERITY();
    DECLARE @ErrorState INT = ERROR_STATE();

    PRINT '';
    PRINT '========================================';
    PRINT 'LỖI: Migration thất bại!';
    PRINT '========================================';
    PRINT 'Error Message: ' + @ErrorMessage;
    PRINT 'Error Severity: ' + CAST(@ErrorSeverity AS NVARCHAR(10));
    PRINT 'Error State: ' + CAST(@ErrorState AS NVARCHAR(10));
    PRINT '';
    PRINT 'Transaction đã được rollback';

    RAISERROR(@ErrorMessage, @ErrorSeverity, @ErrorState);
END CATCH;
GO
