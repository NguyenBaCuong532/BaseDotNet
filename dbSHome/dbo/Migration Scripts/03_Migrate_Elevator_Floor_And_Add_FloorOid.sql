-- =============================================
-- Migration Script: 
-- 1. Chuyển đổi MAS_Elevator_Floor PK từ Id → oid
-- 2. Thêm buildingOid vào MAS_Elevator_Floor
-- 3. Thêm floorOid vào MAS_Apartments
-- 4. Populate floorOid từ Floor và floorNo (thay thế cho Floor, floorNo)
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
    PRINT 'Bắt đầu Migration: Elevator Floor & Add FloorOid';
    PRINT '========================================';
    PRINT '';

    -- =============================================
    -- BƯỚC 1: Thêm buildingOid vào MAS_Elevator_Floor
    -- =============================================
    PRINT 'BƯỚC 1: Thêm buildingOid vào MAS_Elevator_Floor...';
    PRINT '';

    IF NOT EXISTS (SELECT 1 FROM sys.columns WHERE object_id = OBJECT_ID('dbo.MAS_Elevator_Floor') AND name = 'buildingOid')
    BEGIN
        ALTER TABLE [dbo].[MAS_Elevator_Floor]
        ADD [buildingOid] UNIQUEIDENTIFIER NULL;
        PRINT '  ✓ Đã thêm cột buildingOid vào MAS_Elevator_Floor';
    END
    ELSE
        PRINT '  - Cột buildingOid đã tồn tại trong MAS_Elevator_Floor';

    PRINT '';
    PRINT 'Hoàn thành BƯỚC 1';
    PRINT '';

    -- =============================================
    -- BƯỚC 2: Populate buildingOid từ buildingCd
    -- =============================================
    PRINT 'BƯỚC 2: Populate buildingOid từ buildingCd...';
    PRINT '';

    UPDATE ef
    SET ef.[buildingOid] = b.[oid]
    FROM [dbo].[MAS_Elevator_Floor] ef
    INNER JOIN [dbo].[MAS_Buildings] b ON ef.[buildingCd] = b.[BuildingCd]
    WHERE ef.[buildingOid] IS NULL AND ef.[buildingCd] IS NOT NULL;
    PRINT '  ✓ Đã populate buildingOid cho MAS_Elevator_Floor: ' + CAST(@@ROWCOUNT AS NVARCHAR(10)) + ' rows';

    PRINT '';
    PRINT 'Hoàn thành BƯỚC 2';
    PRINT '';

    -- =============================================
    -- BƯỚC 3: Chuyển Primary Key của MAS_Elevator_Floor từ Id → oid
    -- =============================================
    PRINT 'BƯỚC 3: Chuyển Primary Key của MAS_Elevator_Floor từ Id → oid...';
    PRINT '';

    -- Kiểm tra xem đã chuyển PK chưa
    DECLARE @ElevatorFloorCurrentPK NVARCHAR(200);
    SELECT @ElevatorFloorCurrentPK = c.name
    FROM sys.key_constraints kc
    INNER JOIN sys.index_columns ic ON kc.parent_object_id = ic.object_id AND kc.unique_index_id = ic.index_id
    INNER JOIN sys.columns c ON ic.object_id = c.object_id AND ic.column_id = c.column_id
    WHERE kc.type = 'PK' AND kc.parent_object_id = OBJECT_ID('dbo.MAS_Elevator_Floor');

    IF @ElevatorFloorCurrentPK = 'Id'
    BEGIN
        -- Đảm bảo tất cả oid đều có giá trị và unique
        IF EXISTS (SELECT 1 FROM [dbo].[MAS_Elevator_Floor] WHERE [oid] IS NULL)
        BEGIN
            RAISERROR('Có bản ghi trong MAS_Elevator_Floor có oid = NULL. Vui lòng kiểm tra!', 16, 1);
        END

        IF EXISTS (
            SELECT [oid], COUNT(*) as cnt
            FROM [dbo].[MAS_Elevator_Floor]
            GROUP BY [oid]
            HAVING COUNT(*) > 1
        )
        BEGIN
            RAISERROR('Có oid trùng lặp trong MAS_Elevator_Floor. Vui lòng kiểm tra!', 16, 1);
        END

        -- Xóa Primary Key cũ
        ALTER TABLE [dbo].[MAS_Elevator_Floor]
        DROP CONSTRAINT [PK_MAS_Elevator_Floor];
        PRINT '  ✓ Đã xóa Primary Key cũ (PK_MAS_Elevator_Floor)';

        -- Tạo Primary Key mới với oid
        ALTER TABLE [dbo].[MAS_Elevator_Floor]
        ADD CONSTRAINT [PK_MAS_Elevator_Floor] PRIMARY KEY CLUSTERED ([oid] ASC);
        PRINT '  ✓ Đã tạo Primary Key mới với oid';

        -- Tạo Unique Index cho Id (để backward compatibility)
        IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = 'IX_MAS_Elevator_Floor_Id_Unique' AND object_id = OBJECT_ID('dbo.MAS_Elevator_Floor'))
        BEGIN
            CREATE UNIQUE NONCLUSTERED INDEX [IX_MAS_Elevator_Floor_Id_Unique]
            ON [dbo].[MAS_Elevator_Floor]([Id] ASC);
            PRINT '  ✓ Đã tạo Unique Index cho Id (backward compatibility)';
        END
    END
    ELSE IF @ElevatorFloorCurrentPK = 'oid'
    BEGIN
        PRINT '  - Primary Key đã được chuyển sang oid rồi';
    END
    ELSE
    BEGIN
        PRINT '  ⚠ Cảnh báo: Primary Key hiện tại không phải Id hoặc oid: ' + @ElevatorFloorCurrentPK;
    END

    PRINT '';
    PRINT 'Hoàn thành BƯỚC 3';
    PRINT '';

    -- =============================================
    -- BƯỚC 4: Tạo Index cho buildingOid
    -- =============================================
    PRINT 'BƯỚC 4: Tạo Index cho buildingOid...';
    PRINT '';

    IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = 'IX_MAS_Elevator_Floor_buildingOid' AND object_id = OBJECT_ID('dbo.MAS_Elevator_Floor'))
    BEGIN
        CREATE NONCLUSTERED INDEX [IX_MAS_Elevator_Floor_buildingOid]
        ON [dbo].[MAS_Elevator_Floor]([buildingOid] ASC);
        PRINT '  ✓ Đã tạo index IX_MAS_Elevator_Floor_buildingOid';
    END

    PRINT '';
    PRINT 'Hoàn thành BƯỚC 4';
    PRINT '';

    -- =============================================
    -- BƯỚC 5: Tạo Foreign Key từ buildingOid → MAS_Buildings.oid
    -- =============================================
    PRINT 'BƯỚC 5: Tạo Foreign Key từ buildingOid → MAS_Buildings.oid...';
    PRINT '';

    IF NOT EXISTS (SELECT 1 FROM sys.foreign_keys WHERE name = 'FK_MAS_Elevator_Floor_buildingOid')
    BEGIN
        ALTER TABLE [dbo].[MAS_Elevator_Floor]
        ADD CONSTRAINT [FK_MAS_Elevator_Floor_buildingOid]
        FOREIGN KEY ([buildingOid]) REFERENCES [dbo].[MAS_Buildings]([oid]);
        PRINT '  ✓ Đã tạo FK FK_MAS_Elevator_Floor_buildingOid';
    END
    ELSE
        PRINT '  - FK FK_MAS_Elevator_Floor_buildingOid đã tồn tại';

    PRINT '';
    PRINT 'Hoàn thành BƯỚC 5';
    PRINT '';

    -- =============================================
    -- BƯỚC 6: Thêm cột floorOid vào MAS_Apartments
    -- =============================================
    PRINT 'BƯỚC 6: Thêm cột floorOid vào MAS_Apartments...';
    PRINT '';

    IF NOT EXISTS (SELECT 1 FROM sys.columns WHERE object_id = OBJECT_ID('dbo.MAS_Apartments') AND name = 'floorOid')
    BEGIN
        ALTER TABLE [dbo].[MAS_Apartments]
        ADD [floorOid] UNIQUEIDENTIFIER NULL;
        PRINT '  ✓ Đã thêm cột floorOid vào MAS_Apartments';
    END
    ELSE
        PRINT '  - Cột floorOid đã tồn tại trong MAS_Apartments';

    PRINT '';
    PRINT 'Hoàn thành BƯỚC 6';
    PRINT '';

    -- =============================================
    -- BƯỚC 7: Populate floorOid từ Floor và floorNo
    -- =============================================
    PRINT 'BƯỚC 7: Populate floorOid từ Floor và floorNo...';
    PRINT '';

    -- Match theo buildingCd + FloorNumber (từ Floor) hoặc FloorName (từ floorNo)
    -- Ưu tiên: FloorNumber = Floor (nếu có), sau đó FloorName = floorNo
    
    -- Match theo FloorNumber = Floor (nếu Floor là số nguyên)
    UPDATE a
    SET a.[floorOid] = ef.[oid]
    FROM [dbo].[MAS_Apartments] a
    INNER JOIN [dbo].[MAS_Elevator_Floor] ef ON a.[buildingCd] = ef.[buildingCd]
    WHERE a.[floorOid] IS NULL
      AND a.[buildingCd] IS NOT NULL
      AND a.[Floor] IS NOT NULL
      AND ef.[FloorNumber] = CAST(a.[Floor] AS INT)
      AND a.[Floor] = CAST(a.[Floor] AS INT); -- Đảm bảo Floor là số nguyên
    PRINT '  ✓ Đã populate floorOid theo FloorNumber: ' + CAST(@@ROWCOUNT AS NVARCHAR(10)) + ' rows';

    -- Match theo FloorName = floorNo (cho các trường hợp còn lại)
    UPDATE a
    SET a.[floorOid] = ef.[oid]
    FROM [dbo].[MAS_Apartments] a
    INNER JOIN [dbo].[MAS_Elevator_Floor] ef ON a.[buildingCd] = ef.[buildingCd]
    WHERE a.[floorOid] IS NULL
      AND a.[buildingCd] IS NOT NULL
      AND a.[floorNo] IS NOT NULL
      AND a.[floorNo] != ''
      AND ef.[FloorName] = a.[floorNo];
    PRINT '  ✓ Đã populate floorOid theo FloorName: ' + CAST(@@ROWCOUNT AS NVARCHAR(10)) + ' rows';

    -- Match theo buildingOid + FloorNumber (nếu đã có buildingOid)
    UPDATE a
    SET a.[floorOid] = ef.[oid]
    FROM [dbo].[MAS_Apartments] a
    INNER JOIN [dbo].[MAS_Elevator_Floor] ef ON a.[buildingOid] = ef.[buildingOid]
    WHERE a.[floorOid] IS NULL
      AND a.[buildingOid] IS NOT NULL
      AND a.[Floor] IS NOT NULL
      AND ef.[FloorNumber] = CAST(a.[Floor] AS INT)
      AND a.[Floor] = CAST(a.[Floor] AS INT);
    PRINT '  ✓ Đã populate floorOid theo buildingOid + FloorNumber: ' + CAST(@@ROWCOUNT AS NVARCHAR(10)) + ' rows';

    -- Match theo buildingOid + FloorName (cho các trường hợp còn lại)
    UPDATE a
    SET a.[floorOid] = ef.[oid]
    FROM [dbo].[MAS_Apartments] a
    INNER JOIN [dbo].[MAS_Elevator_Floor] ef ON a.[buildingOid] = ef.[buildingOid]
    WHERE a.[floorOid] IS NULL
      AND a.[buildingOid] IS NOT NULL
      AND a.[floorNo] IS NOT NULL
      AND a.[floorNo] != ''
      AND ef.[FloorName] = a.[floorNo];
    PRINT '  ✓ Đã populate floorOid theo buildingOid + FloorName: ' + CAST(@@ROWCOUNT AS NVARCHAR(10)) + ' rows';

    PRINT '';
    PRINT 'Hoàn thành BƯỚC 7';
    PRINT '';

    -- =============================================
    -- BƯỚC 8: Tạo Index cho floorOid
    -- =============================================
    PRINT 'BƯỚC 8: Tạo Index cho floorOid...';
    PRINT '';

    IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = 'IX_MAS_Apartments_floorOid' AND object_id = OBJECT_ID('dbo.MAS_Apartments'))
    BEGIN
        CREATE NONCLUSTERED INDEX [IX_MAS_Apartments_floorOid]
        ON [dbo].[MAS_Apartments]([floorOid] ASC);
        PRINT '  ✓ Đã tạo index IX_MAS_Apartments_floorOid';
    END

    PRINT '';
    PRINT 'Hoàn thành BƯỚC 8';
    PRINT '';

    -- =============================================
    -- BƯỚC 9: Tạo Foreign Key từ floorOid → MAS_Elevator_Floor.oid
    -- =============================================
    PRINT 'BƯỚC 9: Tạo Foreign Key từ floorOid → MAS_Elevator_Floor.oid...';
    PRINT '';

    IF NOT EXISTS (SELECT 1 FROM sys.foreign_keys WHERE name = 'FK_MAS_Apartments_floorOid')
    BEGIN
        ALTER TABLE [dbo].[MAS_Apartments]
        ADD CONSTRAINT [FK_MAS_Apartments_floorOid]
        FOREIGN KEY ([floorOid]) REFERENCES [dbo].[MAS_Elevator_Floor]([oid]);
        PRINT '  ✓ Đã tạo FK FK_MAS_Apartments_floorOid';
    END
    ELSE
        PRINT '  - FK FK_MAS_Apartments_floorOid đã tồn tại';

    PRINT '';
    PRINT 'Hoàn thành BƯỚC 9';
    PRINT '';

    -- =============================================
    -- HOÀN THÀNH
    -- =============================================
    PRINT '========================================';
    PRINT 'Migration hoàn thành thành công!';
    PRINT '========================================';
    PRINT '';
    PRINT 'TÓM TẮT:';
    PRINT '1. ✓ Đã thêm buildingOid vào MAS_Elevator_Floor';
    PRINT '2. ✓ Đã populate buildingOid từ buildingCd';
    PRINT '3. ✓ Đã chuyển PK của MAS_Elevator_Floor từ Id → oid';
    PRINT '4. ✓ Đã tạo Index và Foreign Key cho buildingOid';
    PRINT '5. ✓ Đã thêm floorOid vào MAS_Apartments';
    PRINT '6. ✓ Đã populate floorOid từ Floor và floorNo';
    PRINT '7. ✓ Đã tạo Index và Foreign Key cho floorOid';
    PRINT '';
    PRINT 'CÁC BƯỚC TIẾP THEO:';
    PRINT '1. Kiểm tra dữ liệu đã được populate đúng chưa';
    PRINT '2. Cập nhật Stored Procedures để sử dụng floorOid thay vì Floor, floorNo';
    PRINT '3. Cập nhật Application Code để sử dụng floorOid';
    PRINT '4. Sau khi đảm bảo không còn sử dụng Floor, floorNo, có thể xóa 2 cột này (tùy chọn)';
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
