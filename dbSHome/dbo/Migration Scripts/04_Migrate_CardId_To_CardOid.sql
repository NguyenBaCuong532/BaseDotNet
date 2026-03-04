-- =============================================
-- Migration Script: Chuyển đổi CardId (INT) → cardOid (GUID)
-- Mục đích: Chuẩn hóa tham chiếu thẻ từ CardId → cardOid (MAS_Cards.oid)
-- Author: System
-- Created: 2025
-- =============================================
--
-- QUAN TRỌNG:
-- 1. Backup database trước khi chạy script này
-- 2. Chạy trên môi trường DEV/STAGING trước
-- 3. Test kỹ lưỡng trước khi áp dụng lên PRODUCTION
-- 4. Script này có thể chạy nhiều lần (idempotent)
-- 5. MAS_Cards đã có cột [oid] (GUID) - dùng làm khóa logic; giữ CardId để tương thích ngược
--
-- =============================================

SET NOCOUNT ON;
GO

BEGIN TRANSACTION;
BEGIN TRY

    PRINT '========================================';
    PRINT 'Bắt đầu Migration: CardId → cardOid';
    PRINT '========================================';
    PRINT '';

    -- =============================================
    -- BƯỚC 1: Đảm bảo MAS_Cards.oid UNIQUE (để dùng làm PK logic / FK target)
    -- =============================================
    PRINT 'BƯỚC 1: Ràng buộc UNIQUE trên MAS_Cards.oid...';
    IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE object_id = OBJECT_ID('dbo.MAS_Cards') AND name = 'UQ_MAS_Cards_oid')
    BEGIN
        -- Kiểm tra dữ liệu: oid phải unique
        IF EXISTS (SELECT oid FROM dbo.MAS_Cards GROUP BY oid HAVING COUNT(*) > 1)
            RAISERROR('MAS_Cards có oid trùng lặp, không thể tạo UNIQUE constraint.', 16, 1);
        ALTER TABLE [dbo].[MAS_Cards]
        ADD CONSTRAINT [UQ_MAS_Cards_oid] UNIQUE NONCLUSTERED ([oid] ASC);
        PRINT '  ✓ Đã thêm UNIQUE constraint UQ_MAS_Cards_oid';
    END
    ELSE
        PRINT '  - UNIQUE constraint UQ_MAS_Cards_oid đã tồn tại';
    PRINT '';

    -- =============================================
    -- BƯỚC 2: Thêm cột cardOid vào các bảng tham chiếu tới MAS_Cards
    -- =============================================
    PRINT 'BƯỚC 2: Thêm cột cardOid vào các bảng con...';

    -- MAS_Apartment_Card
    IF NOT EXISTS (SELECT 1 FROM sys.columns WHERE object_id = OBJECT_ID('dbo.MAS_Apartment_Card') AND name = 'cardOid')
    BEGIN
        ALTER TABLE [dbo].[MAS_Apartment_Card] ADD [cardOid] UNIQUEIDENTIFIER NULL;
        PRINT '  ✓ Đã thêm cardOid vào MAS_Apartment_Card';
    END
    ELSE PRINT '  - MAS_Apartment_Card đã có cardOid';

    -- MAS_CardVehicle
    IF NOT EXISTS (SELECT 1 FROM sys.columns WHERE object_id = OBJECT_ID('dbo.MAS_CardVehicle') AND name = 'cardOid')
    BEGIN
        ALTER TABLE [dbo].[MAS_CardVehicle] ADD [cardOid] UNIQUEIDENTIFIER NULL;
        PRINT '  ✓ Đã thêm cardOid vào MAS_CardVehicle';
    END
    ELSE PRINT '  - MAS_CardVehicle đã có cardOid';

    -- MAS_Elevator_Card
    IF NOT EXISTS (SELECT 1 FROM sys.columns WHERE object_id = OBJECT_ID('dbo.MAS_Elevator_Card') AND name = 'cardOid')
    BEGIN
        ALTER TABLE [dbo].[MAS_Elevator_Card] ADD [cardOid] UNIQUEIDENTIFIER NULL;
        PRINT '  ✓ Đã thêm cardOid vào MAS_Elevator_Card';
    END
    ELSE PRINT '  - MAS_Elevator_Card đã có cardOid';

    -- MAS_CardService
    IF NOT EXISTS (SELECT 1 FROM sys.columns WHERE object_id = OBJECT_ID('dbo.MAS_CardService') AND name = 'cardOid')
    BEGIN
        ALTER TABLE [dbo].[MAS_CardService] ADD [cardOid] UNIQUEIDENTIFIER NULL;
        PRINT '  ✓ Đã thêm cardOid vào MAS_CardService';
    END
    ELSE PRINT '  - MAS_CardService đã có cardOid';

    -- MAS_CardCredit
    IF NOT EXISTS (SELECT 1 FROM sys.columns WHERE object_id = OBJECT_ID('dbo.MAS_CardCredit') AND name = 'cardOid')
    BEGIN
        ALTER TABLE [dbo].[MAS_CardCredit] ADD [cardOid] UNIQUEIDENTIFIER NULL;
        PRINT '  ✓ Đã thêm cardOid vào MAS_CardCredit';
    END
    ELSE PRINT '  - MAS_CardCredit đã có cardOid';

    -- MAS_Card_H
    IF EXISTS (SELECT 1 FROM sys.tables WHERE name = 'MAS_Card_H')
    AND NOT EXISTS (SELECT 1 FROM sys.columns WHERE object_id = OBJECT_ID('dbo.MAS_Card_H') AND name = 'cardOid')
    BEGIN
        ALTER TABLE [dbo].[MAS_Card_H] ADD [cardOid] UNIQUEIDENTIFIER NULL;
        PRINT '  ✓ Đã thêm cardOid vào MAS_Card_H';
    END
    ELSE IF EXISTS (SELECT 1 FROM sys.tables WHERE name = 'MAS_Card_H') PRINT '  - MAS_Card_H đã có cardOid';

    -- MAS_CardVehicle_H
    IF EXISTS (SELECT 1 FROM sys.tables WHERE name = 'MAS_CardVehicle_H')
    AND NOT EXISTS (SELECT 1 FROM sys.columns WHERE object_id = OBJECT_ID('dbo.MAS_CardVehicle_H') AND name = 'cardOid')
    BEGIN
        ALTER TABLE [dbo].[MAS_CardVehicle_H] ADD [cardOid] UNIQUEIDENTIFIER NULL;
        PRINT '  ✓ Đã thêm cardOid vào MAS_CardVehicle_H';
    END
    ELSE IF EXISTS (SELECT 1 FROM sys.tables WHERE name = 'MAS_CardVehicle_H') PRINT '  - MAS_CardVehicle_H đã có cardOid';

    -- MAS_CardVehicle_Swipe_H
    IF EXISTS (SELECT 1 FROM sys.tables WHERE name = 'MAS_CardVehicle_Swipe_H')
    AND NOT EXISTS (SELECT 1 FROM sys.columns WHERE object_id = OBJECT_ID('dbo.MAS_CardVehicle_Swipe_H') AND name = 'cardOid')
    BEGIN
        ALTER TABLE [dbo].[MAS_CardVehicle_Swipe_H] ADD [cardOid] UNIQUEIDENTIFIER NULL;
        PRINT '  ✓ Đã thêm cardOid vào MAS_CardVehicle_Swipe_H';
    END
    ELSE IF EXISTS (SELECT 1 FROM sys.tables WHERE name = 'MAS_CardVehicle_Swipe_H') PRINT '  - MAS_CardVehicle_Swipe_H đã có cardOid';

    -- MAS_CardVehicle_Pay_H
    IF EXISTS (SELECT 1 FROM sys.tables WHERE name = 'MAS_CardVehicle_Pay_H')
    AND NOT EXISTS (SELECT 1 FROM sys.columns WHERE object_id = OBJECT_ID('dbo.MAS_CardVehicle_Pay_H') AND name = 'cardOid')
    BEGIN
        ALTER TABLE [dbo].[MAS_CardVehicle_Pay_H] ADD [cardOid] UNIQUEIDENTIFIER NULL;
        PRINT '  ✓ Đã thêm cardOid vào MAS_CardVehicle_Pay_H';
    END
    ELSE IF EXISTS (SELECT 1 FROM sys.tables WHERE name = 'MAS_CardVehicle_Pay_H') PRINT '  - MAS_CardVehicle_Pay_H đã có cardOid';

    -- MAS_CardVehicle_Card_H
    IF EXISTS (SELECT 1 FROM sys.tables WHERE name = 'MAS_CardVehicle_Card_H')
    AND NOT EXISTS (SELECT 1 FROM sys.columns WHERE object_id = OBJECT_ID('dbo.MAS_CardVehicle_Card_H') AND name = 'cardOid')
    BEGIN
        ALTER TABLE [dbo].[MAS_CardVehicle_Card_H] ADD [cardOid] UNIQUEIDENTIFIER NULL;
        PRINT '  ✓ Đã thêm cardOid vào MAS_CardVehicle_Card_H';
    END
    ELSE IF EXISTS (SELECT 1 FROM sys.tables WHERE name = 'MAS_CardVehicle_Card_H') PRINT '  - MAS_CardVehicle_Card_H đã có cardOid';

    -- LogMasVehicle
    IF EXISTS (SELECT 1 FROM sys.tables WHERE name = 'LogMasVehicle')
    AND NOT EXISTS (SELECT 1 FROM sys.columns WHERE object_id = OBJECT_ID('dbo.LogMasVehicle') AND name = 'cardOid')
    BEGIN
        ALTER TABLE [dbo].[LogMasVehicle] ADD [cardOid] UNIQUEIDENTIFIER NULL;
        PRINT '  ✓ Đã thêm cardOid vào LogMasVehicle';
    END
    ELSE IF EXISTS (SELECT 1 FROM sys.tables WHERE name = 'LogMasVehicle') PRINT '  - LogMasVehicle đã có cardOid';

    -- TRS_LogReader
    IF EXISTS (SELECT 1 FROM sys.tables WHERE name = 'TRS_LogReader')
    AND NOT EXISTS (SELECT 1 FROM sys.columns WHERE object_id = OBJECT_ID('dbo.TRS_LogReader') AND name = 'cardOid')
    BEGIN
        ALTER TABLE [dbo].[TRS_LogReader] ADD [cardOid] UNIQUEIDENTIFIER NULL;
        PRINT '  ✓ Đã thêm cardOid vào TRS_LogReader';
    END
    ELSE IF EXISTS (SELECT 1 FROM sys.tables WHERE name = 'TRS_LogReader') PRINT '  - TRS_LogReader đã có cardOid';

    -- TRS_Request_Card
    IF EXISTS (SELECT 1 FROM sys.tables WHERE name = 'TRS_Request_Card')
    AND NOT EXISTS (SELECT 1 FROM sys.columns WHERE object_id = OBJECT_ID('dbo.TRS_Request_Card') AND name = 'cardOid')
    BEGIN
        ALTER TABLE [dbo].[TRS_Request_Card] ADD [cardOid] UNIQUEIDENTIFIER NULL;
        PRINT '  ✓ Đã thêm cardOid vào TRS_Request_Card';
    END
    ELSE IF EXISTS (SELECT 1 FROM sys.tables WHERE name = 'TRS_Request_Card') PRINT '  - TRS_Request_Card đã có cardOid';

    -- TRS_RegServiceExtend
    IF EXISTS (SELECT 1 FROM sys.tables WHERE name = 'TRS_RegServiceExtend')
    AND NOT EXISTS (SELECT 1 FROM sys.columns WHERE object_id = OBJECT_ID('dbo.TRS_RegServiceExtend') AND name = 'cardOid')
    BEGIN
        ALTER TABLE [dbo].[TRS_RegServiceExtend] ADD [cardOid] UNIQUEIDENTIFIER NULL;
        PRINT '  ✓ Đã thêm cardOid vào TRS_RegServiceExtend';
    END
    ELSE IF EXISTS (SELECT 1 FROM sys.tables WHERE name = 'TRS_RegServiceExtend') PRINT '  - TRS_RegServiceExtend đã có cardOid';

    -- MAS_Card_Sync
    IF EXISTS (SELECT 1 FROM sys.tables WHERE name = 'MAS_Card_Sync')
    AND NOT EXISTS (SELECT 1 FROM sys.columns WHERE object_id = OBJECT_ID('dbo.MAS_Card_Sync') AND name = 'cardOid')
    BEGIN
        ALTER TABLE [dbo].[MAS_Card_Sync] ADD [cardOid] UNIQUEIDENTIFIER NULL;
        PRINT '  ✓ Đã thêm cardOid vào MAS_Card_Sync';
    END
    ELSE IF EXISTS (SELECT 1 FROM sys.tables WHERE name = 'MAS_Card_Sync') PRINT '  - MAS_Card_Sync đã có cardOid';

    -- MAS_CardVehicle_Tmp
    IF EXISTS (SELECT 1 FROM sys.tables WHERE name = 'MAS_CardVehicle_Tmp')
    AND NOT EXISTS (SELECT 1 FROM sys.columns WHERE object_id = OBJECT_ID('dbo.MAS_CardVehicle_Tmp') AND name = 'cardOid')
    BEGIN
        ALTER TABLE [dbo].[MAS_CardVehicle_Tmp] ADD [cardOid] UNIQUEIDENTIFIER NULL;
        PRINT '  ✓ Đã thêm cardOid vào MAS_CardVehicle_Tmp';
    END
    ELSE IF EXISTS (SELECT 1 FROM sys.tables WHERE name = 'MAS_CardVehicle_Tmp') PRINT '  - MAS_CardVehicle_Tmp đã có cardOid';

    PRINT '';

    -- =============================================
    -- BƯỚC 3: Cập nhật cardOid từ MAS_Cards.oid (backfill)
    -- =============================================
    PRINT 'BƯỚC 3: Backfill cardOid từ MAS_Cards.oid...';

    UPDATE ac SET ac.cardOid = c.oid
    FROM dbo.MAS_Apartment_Card ac
    INNER JOIN dbo.MAS_Cards c ON c.CardId = ac.CardId
    WHERE ac.cardOid IS NULL;

    UPDATE v SET v.cardOid = c.oid
    FROM dbo.MAS_CardVehicle v
    INNER JOIN dbo.MAS_Cards c ON c.CardId = v.CardId
    WHERE v.cardOid IS NULL;

    UPDATE e SET e.cardOid = c.oid
    FROM dbo.MAS_Elevator_Card e
    INNER JOIN dbo.MAS_Cards c ON c.CardId = e.CardId
    WHERE e.cardOid IS NULL;

    UPDATE s SET s.cardOid = c.oid
    FROM dbo.MAS_CardService s
    INNER JOIN dbo.MAS_Cards c ON c.CardId = s.CardId
    WHERE s.cardOid IS NULL;

    UPDATE cr SET cr.cardOid = c.oid
    FROM dbo.MAS_CardCredit cr
    INNER JOIN dbo.MAS_Cards c ON c.CardId = cr.CardId
    WHERE cr.cardOid IS NULL;

    IF EXISTS (SELECT 1 FROM sys.tables WHERE name = 'MAS_Card_H')
    BEGIN
        UPDATE h SET h.cardOid = c.oid
        FROM dbo.MAS_Card_H h
        INNER JOIN dbo.MAS_Cards c ON c.CardId = h.CardId
        WHERE h.cardOid IS NULL;
    END

    IF EXISTS (SELECT 1 FROM sys.tables WHERE name = 'MAS_CardVehicle_H')
    BEGIN
        UPDATE h SET h.cardOid = c.oid
        FROM dbo.MAS_CardVehicle_H h
        INNER JOIN dbo.MAS_Cards c ON c.CardId = h.CardId
        WHERE h.cardOid IS NULL;
    END

    IF EXISTS (SELECT 1 FROM sys.tables WHERE name = 'MAS_CardVehicle_Swipe_H')
    BEGIN
        UPDATE h SET h.cardOid = c.oid
        FROM dbo.MAS_CardVehicle_Swipe_H h
        INNER JOIN dbo.MAS_Cards c ON c.CardId = h.CardId
        WHERE h.cardOid IS NULL;
    END

    IF EXISTS (SELECT 1 FROM sys.tables WHERE name = 'MAS_CardVehicle_Pay_H')
    BEGIN
        UPDATE h SET h.cardOid = c.oid
        FROM dbo.MAS_CardVehicle_Pay_H h
        INNER JOIN dbo.MAS_Cards c ON c.CardId = h.CardId
        WHERE h.cardOid IS NULL;
    END

    IF EXISTS (SELECT 1 FROM sys.tables WHERE name = 'MAS_CardVehicle_Card_H')
    BEGIN
        UPDATE h SET h.cardOid = c.oid
        FROM dbo.MAS_CardVehicle_Card_H h
        INNER JOIN dbo.MAS_Cards c ON c.CardId = h.CardId
        WHERE h.cardOid IS NULL;
    END

    IF EXISTS (SELECT 1 FROM sys.tables WHERE name = 'LogMasVehicle')
    BEGIN
        UPDATE l SET l.cardOid = c.oid
        FROM dbo.LogMasVehicle l
        INNER JOIN dbo.MAS_Cards c ON c.CardId = l.CardId
        WHERE l.cardOid IS NULL;
    END

    IF EXISTS (SELECT 1 FROM sys.tables WHERE name = 'TRS_LogReader')
    BEGIN
        UPDATE t SET t.cardOid = c.oid
        FROM dbo.TRS_LogReader t
        INNER JOIN dbo.MAS_Cards c ON c.CardId = t.CardId
        WHERE t.cardOid IS NULL;
    END

    IF EXISTS (SELECT 1 FROM sys.tables WHERE name = 'TRS_Request_Card')
    BEGIN
        UPDATE t SET t.cardOid = c.oid
        FROM dbo.TRS_Request_Card t
        INNER JOIN dbo.MAS_Cards c ON c.CardId = t.CardId
        WHERE t.cardOid IS NULL;
    END

    IF EXISTS (SELECT 1 FROM sys.tables WHERE name = 'TRS_RegServiceExtend')
    BEGIN
        UPDATE t SET t.cardOid = c.oid
        FROM dbo.TRS_RegServiceExtend t
        INNER JOIN dbo.MAS_Cards c ON c.CardId = t.CardId
        WHERE t.cardOid IS NULL;
    END

    IF EXISTS (SELECT 1 FROM sys.tables WHERE name = 'MAS_Card_Sync')
    BEGIN
        UPDATE s SET s.cardOid = c.oid
        FROM dbo.MAS_Card_Sync s
        INNER JOIN dbo.MAS_Cards c ON c.CardId = s.CardId
        WHERE s.cardOid IS NULL;
    END

    IF EXISTS (SELECT 1 FROM sys.tables WHERE name = 'MAS_CardVehicle_Tmp')
    BEGIN
        UPDATE t SET t.cardOid = c.oid
        FROM dbo.MAS_CardVehicle_Tmp t
        INNER JOIN dbo.MAS_Cards c ON c.CardId = t.CardId
        WHERE t.cardOid IS NULL;
    END

    PRINT '  ✓ Đã backfill cardOid';
    PRINT '';

    -- =============================================
    -- BƯỚC 4: Tạo index trên cardOid (tùy chọn, hỗ trợ truy vấn)
    -- =============================================
    PRINT 'BƯỚC 4: Tạo index trên cardOid...';

    IF EXISTS (SELECT 1 FROM sys.tables WHERE name = 'MAS_Apartment_Card')
    AND NOT EXISTS (SELECT 1 FROM sys.indexes WHERE object_id = OBJECT_ID('dbo.MAS_Apartment_Card') AND name = 'IX_MAS_Apartment_Card_cardOid')
    BEGIN
        CREATE NONCLUSTERED INDEX [IX_MAS_Apartment_Card_cardOid] ON [dbo].[MAS_Apartment_Card]([cardOid] ASC);
        PRINT '  ✓ IX_MAS_Apartment_Card_cardOid';
    END

    IF EXISTS (SELECT 1 FROM sys.tables WHERE name = 'MAS_CardVehicle')
    AND NOT EXISTS (SELECT 1 FROM sys.indexes WHERE object_id = OBJECT_ID('dbo.MAS_CardVehicle') AND name = 'IX_MAS_CardVehicle_cardOid')
    BEGIN
        CREATE NONCLUSTERED INDEX [IX_MAS_CardVehicle_cardOid] ON [dbo].[MAS_CardVehicle]([cardOid] ASC);
        PRINT '  ✓ IX_MAS_CardVehicle_cardOid';
    END

    IF EXISTS (SELECT 1 FROM sys.tables WHERE name = 'MAS_Elevator_Card')
    AND NOT EXISTS (SELECT 1 FROM sys.indexes WHERE object_id = OBJECT_ID('dbo.MAS_Elevator_Card') AND name = 'IX_MAS_Elevator_Card_cardOid')
    BEGIN
        CREATE NONCLUSTERED INDEX [IX_MAS_Elevator_Card_cardOid] ON [dbo].[MAS_Elevator_Card]([cardOid] ASC);
        PRINT '  ✓ IX_MAS_Elevator_Card_cardOid';
    END

    PRINT '';
    PRINT '========================================';
    PRINT 'Migration CardId → cardOid hoàn tất.';
    PRINT '========================================';

    COMMIT TRANSACTION;
END TRY
BEGIN CATCH
    ROLLBACK TRANSACTION;
    DECLARE @ErrMsg NVARCHAR(4000) = ERROR_MESSAGE();
    DECLARE @ErrNum INT = ERROR_NUMBER();
    RAISERROR('Migration thất bại: %d - %s', 16, 1, @ErrNum, @ErrMsg);
END CATCH
GO
