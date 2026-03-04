-- =============================================
-- Migration Script: Chuyển đổi ApartmentId (INT) → apartOid (GUID)
-- Mục đích: Chuẩn hóa khóa chính của MAS_Apartments từ ApartmentId → oid
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
    PRINT 'Bắt đầu Migration: ApartmentId → apartOid';
    PRINT '========================================';
    PRINT '';

    -- =============================================
    -- BƯỚC 1: Thêm cột apartOid vào các bảng con
    -- =============================================
    PRINT 'BƯỚC 1: Thêm cột apartOid vào các bảng con...';
    PRINT '';

    -- MAS_Apartment_Member
    IF NOT EXISTS (SELECT 1 FROM sys.columns WHERE object_id = OBJECT_ID('dbo.MAS_Apartment_Member') AND name = 'apartOid')
    BEGIN
        ALTER TABLE [dbo].[MAS_Apartment_Member]
        ADD [apartOid] UNIQUEIDENTIFIER NULL;
        PRINT '  ✓ Đã thêm cột apartOid vào MAS_Apartment_Member';
    END
    ELSE
        PRINT '  - Cột apartOid đã tồn tại trong MAS_Apartment_Member';

    -- MAS_Customers - BỎ QUA: Bảng này dùng chung cho nhiều MAS_Apartments, không migrate

    -- MAS_Apartment_Card
    IF NOT EXISTS (SELECT 1 FROM sys.columns WHERE object_id = OBJECT_ID('dbo.MAS_Apartment_Card') AND name = 'apartOid')
    BEGIN
        ALTER TABLE [dbo].[MAS_Apartment_Card]
        ADD [apartOid] UNIQUEIDENTIFIER NULL;
        PRINT '  ✓ Đã thêm cột apartOid vào MAS_Apartment_Card';
    END
    ELSE
        PRINT '  - Cột apartOid đã tồn tại trong MAS_Apartment_Card';

    -- MAS_Customer_Household
    IF NOT EXISTS (SELECT 1 FROM sys.columns WHERE object_id = OBJECT_ID('dbo.MAS_Customer_Household') AND name = 'apartOid')
    BEGIN
        ALTER TABLE [dbo].[MAS_Customer_Household]
        ADD [apartOid] UNIQUEIDENTIFIER NULL;
        PRINT '  ✓ Đã thêm cột apartOid vào MAS_Customer_Household';
    END
    ELSE
        PRINT '  - Cột apartOid đã tồn tại trong MAS_Customer_Household';

    -- MAS_Requests
    IF NOT EXISTS (SELECT 1 FROM sys.columns WHERE object_id = OBJECT_ID('dbo.MAS_Requests') AND name = 'apartOid')
    BEGIN
        ALTER TABLE [dbo].[MAS_Requests]
        ADD [apartOid] UNIQUEIDENTIFIER NULL;
        PRINT '  ✓ Đã thêm cột apartOid vào MAS_Requests';
    END
    ELSE
        PRINT '  - Cột apartOid đã tồn tại trong MAS_Requests';

    -- MAS_Feedbacks
    IF EXISTS (SELECT 1 FROM sys.tables WHERE name = 'MAS_Feedbacks')
    AND NOT EXISTS (SELECT 1 FROM sys.columns WHERE object_id = OBJECT_ID('dbo.MAS_Feedbacks') AND name = 'apartOid')
    BEGIN
        ALTER TABLE [dbo].[MAS_Feedbacks]
        ADD [apartOid] UNIQUEIDENTIFIER NULL;
        PRINT '  ✓ Đã thêm cột apartOid vào MAS_Feedbacks';
    END
    ELSE IF EXISTS (SELECT 1 FROM sys.tables WHERE name = 'MAS_Feedbacks')
        PRINT '  - Cột apartOid đã tồn tại trong MAS_Feedbacks';

    -- MAS_Cards
    IF EXISTS (SELECT 1 FROM sys.tables WHERE name = 'MAS_Cards')
    AND NOT EXISTS (SELECT 1 FROM sys.columns WHERE object_id = OBJECT_ID('dbo.MAS_Cards') AND name = 'apartOid')
    BEGIN
        ALTER TABLE [dbo].[MAS_Cards]
        ADD [apartOid] UNIQUEIDENTIFIER NULL;
        PRINT '  ✓ Đã thêm cột apartOid vào MAS_Cards';
    END
    ELSE IF EXISTS (SELECT 1 FROM sys.tables WHERE name = 'MAS_Cards')
        PRINT '  - Cột apartOid đã tồn tại trong MAS_Cards';

    -- MAS_Card_H
    IF EXISTS (SELECT 1 FROM sys.tables WHERE name = 'MAS_Card_H')
    AND NOT EXISTS (SELECT 1 FROM sys.columns WHERE object_id = OBJECT_ID('dbo.MAS_Card_H') AND name = 'apartOid')
    BEGIN
        ALTER TABLE [dbo].[MAS_Card_H]
        ADD [apartOid] UNIQUEIDENTIFIER NULL;
        PRINT '  ✓ Đã thêm cột apartOid vào MAS_Card_H';
    END
    ELSE IF EXISTS (SELECT 1 FROM sys.tables WHERE name = 'MAS_Card_H')
        PRINT '  - Cột apartOid đã tồn tại trong MAS_Card_H';

    -- MAS_Apartment_Violation
    IF EXISTS (SELECT 1 FROM sys.tables WHERE name = 'MAS_Apartment_Violation')
    AND NOT EXISTS (SELECT 1 FROM sys.columns WHERE object_id = OBJECT_ID('dbo.MAS_Apartment_Violation') AND name = 'apartOid')
    BEGIN
        ALTER TABLE [dbo].[MAS_Apartment_Violation]
        ADD [apartOid] UNIQUEIDENTIFIER NULL;
        PRINT '  ✓ Đã thêm cột apartOid vào MAS_Apartment_Violation';
    END
    ELSE IF EXISTS (SELECT 1 FROM sys.tables WHERE name = 'MAS_Apartment_Violation')
        PRINT '  - Cột apartOid đã tồn tại trong MAS_Apartment_Violation';

    -- MAS_Apartment_Service_Extend
    IF EXISTS (SELECT 1 FROM sys.tables WHERE name = 'MAS_Apartment_Service_Extend')
    AND NOT EXISTS (SELECT 1 FROM sys.columns WHERE object_id = OBJECT_ID('dbo.MAS_Apartment_Service_Extend') AND name = 'apartOid')
    BEGIN
        ALTER TABLE [dbo].[MAS_Apartment_Service_Extend]
        ADD [apartOid] UNIQUEIDENTIFIER NULL;
        PRINT '  ✓ Đã thêm cột apartOid vào MAS_Apartment_Service_Extend';
    END
    ELSE IF EXISTS (SELECT 1 FROM sys.tables WHERE name = 'MAS_Apartment_Service_Extend')
        PRINT '  - Cột apartOid đã tồn tại trong MAS_Apartment_Service_Extend';

    -- MAS_Apartment_Service_Living
    IF EXISTS (SELECT 1 FROM sys.tables WHERE name = 'MAS_Apartment_Service_Living')
    AND NOT EXISTS (SELECT 1 FROM sys.columns WHERE object_id = OBJECT_ID('dbo.MAS_Apartment_Service_Living') AND name = 'apartOid')
    BEGIN
        ALTER TABLE [dbo].[MAS_Apartment_Service_Living]
        ADD [apartOid] UNIQUEIDENTIFIER NULL;
        PRINT '  ✓ Đã thêm cột apartOid vào MAS_Apartment_Service_Living';
    END
    ELSE IF EXISTS (SELECT 1 FROM sys.tables WHERE name = 'MAS_Apartment_Service_Living')
        PRINT '  - Cột apartOid đã tồn tại trong MAS_Apartment_Service_Living';

    -- MAS_Apartment_Profile
    IF EXISTS (SELECT 1 FROM sys.tables WHERE name = 'MAS_Apartment_Profile')
    AND NOT EXISTS (SELECT 1 FROM sys.columns WHERE object_id = OBJECT_ID('dbo.MAS_Apartment_Profile') AND name = 'apartOid')
    BEGIN
        ALTER TABLE [dbo].[MAS_Apartment_Profile]
        ADD [apartOid] UNIQUEIDENTIFIER NULL;
        PRINT '  ✓ Đã thêm cột apartOid vào MAS_Apartment_Profile';
    END
    ELSE IF EXISTS (SELECT 1 FROM sys.tables WHERE name = 'MAS_Apartment_Profile')
        PRINT '  - Cột apartOid đã tồn tại trong MAS_Apartment_Profile';

    -- MAS_Apartment_Member_H
    IF EXISTS (SELECT 1 FROM sys.tables WHERE name = 'MAS_Apartment_Member_H')
    AND NOT EXISTS (SELECT 1 FROM sys.columns WHERE object_id = OBJECT_ID('dbo.MAS_Apartment_Member_H') AND name = 'apartOid')
    BEGIN
        ALTER TABLE [dbo].[MAS_Apartment_Member_H]
        ADD [apartOid] UNIQUEIDENTIFIER NULL;
        PRINT '  ✓ Đã thêm cột apartOid vào MAS_Apartment_Member_H';
    END
    ELSE IF EXISTS (SELECT 1 FROM sys.tables WHERE name = 'MAS_Apartment_Member_H')
        PRINT '  - Cột apartOid đã tồn tại trong MAS_Apartment_Member_H';

    -- MAS_Apartment_HostChange_History
    IF EXISTS (SELECT 1 FROM sys.tables WHERE name = 'MAS_Apartment_HostChange_History')
    AND NOT EXISTS (SELECT 1 FROM sys.columns WHERE object_id = OBJECT_ID('dbo.MAS_Apartment_HostChange_History') AND name = 'apartOid')
    BEGIN
        ALTER TABLE [dbo].[MAS_Apartment_HostChange_History]
        ADD [apartOid] UNIQUEIDENTIFIER NULL;
        PRINT '  ✓ Đã thêm cột apartOid vào MAS_Apartment_HostChange_History';
    END
    ELSE IF EXISTS (SELECT 1 FROM sys.tables WHERE name = 'MAS_Apartment_HostChange_History')
        PRINT '  - Cột apartOid đã tồn tại trong MAS_Apartment_HostChange_History';

    -- MAS_Service_Living_Tracking
    IF EXISTS (SELECT 1 FROM sys.tables WHERE name = 'MAS_Service_Living_Tracking')
    AND NOT EXISTS (SELECT 1 FROM sys.columns WHERE object_id = OBJECT_ID('dbo.MAS_Service_Living_Tracking') AND name = 'apartOid')
    BEGIN
        ALTER TABLE [dbo].[MAS_Service_Living_Tracking]
        ADD [apartOid] UNIQUEIDENTIFIER NULL;
        PRINT '  ✓ Đã thêm cột apartOid vào MAS_Service_Living_Tracking';
    END
    ELSE IF EXISTS (SELECT 1 FROM sys.tables WHERE name = 'MAS_Service_Living_Tracking')
        PRINT '  - Cột apartOid đã tồn tại trong MAS_Service_Living_Tracking';

    -- MAS_Service_Living_Track
    IF EXISTS (SELECT 1 FROM sys.tables WHERE name = 'MAS_Service_Living_Track')
    AND NOT EXISTS (SELECT 1 FROM sys.columns WHERE object_id = OBJECT_ID('dbo.MAS_Service_Living_Track') AND name = 'apartOid')
    BEGIN
        ALTER TABLE [dbo].[MAS_Service_Living_Track]
        ADD [apartOid] UNIQUEIDENTIFIER NULL;
        PRINT '  ✓ Đã thêm cột apartOid vào MAS_Service_Living_Track';
    END
    ELSE IF EXISTS (SELECT 1 FROM sys.tables WHERE name = 'MAS_Service_Living_Track')
        PRINT '  - Cột apartOid đã tồn tại trong MAS_Service_Living_Track';

    -- MAS_Service_Cut_History
    IF EXISTS (SELECT 1 FROM sys.tables WHERE name = 'MAS_Service_Cut_History')
    AND NOT EXISTS (SELECT 1 FROM sys.columns WHERE object_id = OBJECT_ID('dbo.MAS_Service_Cut_History') AND name = 'apartOid')
    BEGIN
        ALTER TABLE [dbo].[MAS_Service_Cut_History]
        ADD [apartOid] UNIQUEIDENTIFIER NULL;
        PRINT '  ✓ Đã thêm cột apartOid vào MAS_Service_Cut_History';
    END
    ELSE IF EXISTS (SELECT 1 FROM sys.tables WHERE name = 'MAS_Service_Cut_History')
        PRINT '  - Cột apartOid đã tồn tại trong MAS_Service_Cut_History';

    -- MAS_Service_ReceiveEntry
    IF EXISTS (SELECT 1 FROM sys.tables WHERE name = 'MAS_Service_ReceiveEntry')
    AND NOT EXISTS (SELECT 1 FROM sys.columns WHERE object_id = OBJECT_ID('dbo.MAS_Service_ReceiveEntry') AND name = 'apartOid')
    BEGIN
        ALTER TABLE [dbo].[MAS_Service_ReceiveEntry]
        ADD [apartOid] UNIQUEIDENTIFIER NULL;
        PRINT '  ✓ Đã thêm cột apartOid vào MAS_Service_ReceiveEntry';
    END
    ELSE IF EXISTS (SELECT 1 FROM sys.tables WHERE name = 'MAS_Service_ReceiveEntry')
        PRINT '  - Cột apartOid đã tồn tại trong MAS_Service_ReceiveEntry';

    -- MAS_Service_Receipts
    IF EXISTS (SELECT 1 FROM sys.tables WHERE name = 'MAS_Service_Receipts')
    AND NOT EXISTS (SELECT 1 FROM sys.columns WHERE object_id = OBJECT_ID('dbo.MAS_Service_Receipts') AND name = 'apartOid')
    BEGIN
        ALTER TABLE [dbo].[MAS_Service_Receipts]
        ADD [apartOid] UNIQUEIDENTIFIER NULL;
        PRINT '  ✓ Đã thêm cột apartOid vào MAS_Service_Receipts';
    END
    ELSE IF EXISTS (SELECT 1 FROM sys.tables WHERE name = 'MAS_Service_Receipts')
        PRINT '  - Cột apartOid đã tồn tại trong MAS_Service_Receipts';

    -- MAS_Service_Receipts_H
    IF EXISTS (SELECT 1 FROM sys.tables WHERE name = 'MAS_Service_Receipts_H')
    AND NOT EXISTS (SELECT 1 FROM sys.columns WHERE object_id = OBJECT_ID('dbo.MAS_Service_Receipts_H') AND name = 'apartOid')
    BEGIN
        ALTER TABLE [dbo].[MAS_Service_Receipts_H]
        ADD [apartOid] UNIQUEIDENTIFIER NULL;
        PRINT '  ✓ Đã thêm cột apartOid vào MAS_Service_Receipts_H';
    END
    ELSE IF EXISTS (SELECT 1 FROM sys.tables WHERE name = 'MAS_Service_Receipts_H')
        PRINT '  - Cột apartOid đã tồn tại trong MAS_Service_Receipts_H';

    -- TRS_PayRegBill
    IF EXISTS (SELECT 1 FROM sys.tables WHERE name = 'TRS_PayRegBill')
    AND NOT EXISTS (SELECT 1 FROM sys.columns WHERE object_id = OBJECT_ID('dbo.TRS_PayRegBill') AND name = 'apartOid')
    BEGIN
        ALTER TABLE [dbo].[TRS_PayRegBill]
        ADD [apartOid] UNIQUEIDENTIFIER NULL;
        PRINT '  ✓ Đã thêm cột apartOid vào TRS_PayRegBill';
    END
    ELSE IF EXISTS (SELECT 1 FROM sys.tables WHERE name = 'TRS_PayRegBill')
        PRINT '  - Cột apartOid đã tồn tại trong TRS_PayRegBill';

    -- MAS_Apartments_Save
    IF EXISTS (SELECT 1 FROM sys.tables WHERE name = 'MAS_Apartments_Save')
    AND NOT EXISTS (SELECT 1 FROM sys.columns WHERE object_id = OBJECT_ID('dbo.MAS_Apartments_Save') AND name = 'apartOid')
    BEGIN
        ALTER TABLE [dbo].[MAS_Apartments_Save]
        ADD [apartOid] UNIQUEIDENTIFIER NULL;
        PRINT '  ✓ Đã thêm cột apartOid vào MAS_Apartments_Save';
    END
    ELSE IF EXISTS (SELECT 1 FROM sys.tables WHERE name = 'MAS_Apartments_Save')
        PRINT '  - Cột apartOid đã tồn tại trong MAS_Apartments_Save';

    -- MAS_CardVehicle
    IF EXISTS (SELECT 1 FROM sys.tables WHERE name = 'MAS_CardVehicle')
    AND NOT EXISTS (SELECT 1 FROM sys.columns WHERE object_id = OBJECT_ID('dbo.MAS_CardVehicle') AND name = 'apartOid')
    BEGIN
        ALTER TABLE [dbo].[MAS_CardVehicle]
        ADD [apartOid] UNIQUEIDENTIFIER NULL;
        PRINT '  ✓ Đã thêm cột apartOid vào MAS_CardVehicle';
    END
    ELSE IF EXISTS (SELECT 1 FROM sys.tables WHERE name = 'MAS_CardVehicle')
        PRINT '  - Cột apartOid đã tồn tại trong MAS_CardVehicle';

    -- MAS_CardVehicle_H
    IF EXISTS (SELECT 1 FROM sys.tables WHERE name = 'MAS_CardVehicle_H')
    AND NOT EXISTS (SELECT 1 FROM sys.columns WHERE object_id = OBJECT_ID('dbo.MAS_CardVehicle_H') AND name = 'apartOid')
    BEGIN
        ALTER TABLE [dbo].[MAS_CardVehicle_H]
        ADD [apartOid] UNIQUEIDENTIFIER NULL;
        PRINT '  ✓ Đã thêm cột apartOid vào MAS_CardVehicle_H';
    END
    ELSE IF EXISTS (SELECT 1 FROM sys.tables WHERE name = 'MAS_CardVehicle_H')
        PRINT '  - Cột apartOid đã tồn tại trong MAS_CardVehicle_H';

    PRINT '';
    PRINT 'Hoàn thành BƯỚC 1';
    PRINT '';

    -- =============================================
    -- BƯỚC 2: Populate dữ liệu từ ApartmentId → apartOid
    -- =============================================
    PRINT 'BƯỚC 2: Populate dữ liệu từ ApartmentId → apartOid...';
    PRINT '';

    -- MAS_Apartment_Member
    UPDATE am
    SET am.[apartOid] = a.[oid]
    FROM [dbo].[MAS_Apartment_Member] am
    INNER JOIN [dbo].[MAS_Apartments] a ON am.[ApartmentId] = a.[ApartmentId]
    WHERE am.[apartOid] IS NULL;
    PRINT '  ✓ Đã populate apartOid cho MAS_Apartment_Member: ' + CAST(@@ROWCOUNT AS NVARCHAR(10)) + ' rows';

    -- MAS_Customers - BỎ QUA: Bảng này dùng chung cho nhiều MAS_Apartments, không migrate

    -- MAS_Apartment_Card
    UPDATE ac
    SET ac.[apartOid] = a.[oid]
    FROM [dbo].[MAS_Apartment_Card] ac
    INNER JOIN [dbo].[MAS_Apartments] a ON ac.[ApartmentId] = a.[ApartmentId]
    WHERE ac.[apartOid] IS NULL;
    PRINT '  ✓ Đã populate apartOid cho MAS_Apartment_Card: ' + CAST(@@ROWCOUNT AS NVARCHAR(10)) + ' rows';

    -- MAS_Customer_Household
    UPDATE ch
    SET ch.[apartOid] = a.[oid]
    FROM [dbo].[MAS_Customer_Household] ch
    INNER JOIN [dbo].[MAS_Apartments] a ON ch.[ApartmentId] = a.[ApartmentId]
    WHERE ch.[apartOid] IS NULL;
    PRINT '  ✓ Đã populate apartOid cho MAS_Customer_Household: ' + CAST(@@ROWCOUNT AS NVARCHAR(10)) + ' rows';

    -- MAS_Requests
    UPDATE r
    SET r.[apartOid] = a.[oid]
    FROM [dbo].[MAS_Requests] r
    INNER JOIN [dbo].[MAS_Apartments] a ON r.[apartmentId] = a.[ApartmentId]
    WHERE r.[apartOid] IS NULL;
    PRINT '  ✓ Đã populate apartOid cho MAS_Requests: ' + CAST(@@ROWCOUNT AS NVARCHAR(10)) + ' rows';

    -- MAS_Feedbacks
    IF EXISTS (SELECT 1 FROM sys.tables WHERE name = 'MAS_Feedbacks')
    BEGIN
        UPDATE f
        SET f.[apartOid] = a.[oid]
        FROM [dbo].[MAS_Feedbacks] f
        INNER JOIN [dbo].[MAS_Apartments] a ON f.[ApartmentId] = a.[ApartmentId]
        WHERE f.[apartOid] IS NULL;
        PRINT '  ✓ Đã populate apartOid cho MAS_Feedbacks: ' + CAST(@@ROWCOUNT AS NVARCHAR(10)) + ' rows';
    END

    -- MAS_Cards
    IF EXISTS (SELECT 1 FROM sys.tables WHERE name = 'MAS_Cards')
    BEGIN
        UPDATE c
        SET c.[apartOid] = a.[oid]
        FROM [dbo].[MAS_Cards] c
        INNER JOIN [dbo].[MAS_Apartments] a ON c.[ApartmentId] = a.[ApartmentId]
        WHERE c.[apartOid] IS NULL;
        PRINT '  ✓ Đã populate apartOid cho MAS_Cards: ' + CAST(@@ROWCOUNT AS NVARCHAR(10)) + ' rows';
    END

    -- MAS_Card_H
    IF EXISTS (SELECT 1 FROM sys.tables WHERE name = 'MAS_Card_H')
    BEGIN
        UPDATE ch
        SET ch.[apartOid] = a.[oid]
        FROM [dbo].[MAS_Card_H] ch
        INNER JOIN [dbo].[MAS_Apartments] a ON ch.[ApartmentId] = a.[ApartmentId]
        WHERE ch.[apartOid] IS NULL;
        PRINT '  ✓ Đã populate apartOid cho MAS_Card_H: ' + CAST(@@ROWCOUNT AS NVARCHAR(10)) + ' rows';
    END

    -- MAS_Apartment_Violation
    IF EXISTS (SELECT 1 FROM sys.tables WHERE name = 'MAS_Apartment_Violation')
    BEGIN
        UPDATE av
        SET av.[apartOid] = a.[oid]
        FROM [dbo].[MAS_Apartment_Violation] av
        INNER JOIN [dbo].[MAS_Apartments] a ON av.[ApartmentId] = a.[ApartmentId]
        WHERE av.[apartOid] IS NULL;
        PRINT '  ✓ Đã populate apartOid cho MAS_Apartment_Violation: ' + CAST(@@ROWCOUNT AS NVARCHAR(10)) + ' rows';
    END

    -- MAS_Apartment_Service_Extend
    IF EXISTS (SELECT 1 FROM sys.tables WHERE name = 'MAS_Apartment_Service_Extend')
    BEGIN
        UPDATE ase
        SET ase.[apartOid] = a.[oid]
        FROM [dbo].[MAS_Apartment_Service_Extend] ase
        INNER JOIN [dbo].[MAS_Apartments] a ON ase.[ApartmentId] = a.[ApartmentId]
        WHERE ase.[apartOid] IS NULL;
        PRINT '  ✓ Đã populate apartOid cho MAS_Apartment_Service_Extend: ' + CAST(@@ROWCOUNT AS NVARCHAR(10)) + ' rows';
    END

    -- MAS_Apartment_Service_Living
    IF EXISTS (SELECT 1 FROM sys.tables WHERE name = 'MAS_Apartment_Service_Living')
    BEGIN
        UPDATE asl
        SET asl.[apartOid] = a.[oid]
        FROM [dbo].[MAS_Apartment_Service_Living] asl
        INNER JOIN [dbo].[MAS_Apartments] a ON asl.[ApartmentId] = a.[ApartmentId]
        WHERE asl.[apartOid] IS NULL;
        PRINT '  ✓ Đã populate apartOid cho MAS_Apartment_Service_Living: ' + CAST(@@ROWCOUNT AS NVARCHAR(10)) + ' rows';
    END

    -- MAS_Apartment_Profile
    IF EXISTS (SELECT 1 FROM sys.tables WHERE name = 'MAS_Apartment_Profile')
    BEGIN
        UPDATE ap
        SET ap.[apartOid] = a.[oid]
        FROM [dbo].[MAS_Apartment_Profile] ap
        INNER JOIN [dbo].[MAS_Apartments] a ON ap.[ApartmentId] = a.[ApartmentId]
        WHERE ap.[apartOid] IS NULL;
        PRINT '  ✓ Đã populate apartOid cho MAS_Apartment_Profile: ' + CAST(@@ROWCOUNT AS NVARCHAR(10)) + ' rows';
    END

    -- MAS_Apartment_Member_H
    IF EXISTS (SELECT 1 FROM sys.tables WHERE name = 'MAS_Apartment_Member_H')
    BEGIN
        UPDATE amh
        SET amh.[apartOid] = a.[oid]
        FROM [dbo].[MAS_Apartment_Member_H] amh
        INNER JOIN [dbo].[MAS_Apartments] a ON amh.[ApartmentId] = a.[ApartmentId]
        WHERE amh.[apartOid] IS NULL;
        PRINT '  ✓ Đã populate apartOid cho MAS_Apartment_Member_H: ' + CAST(@@ROWCOUNT AS NVARCHAR(10)) + ' rows';
    END

    -- MAS_Apartment_HostChange_History
    IF EXISTS (SELECT 1 FROM sys.tables WHERE name = 'MAS_Apartment_HostChange_History')
    BEGIN
        UPDATE ahch
        SET ahch.[apartOid] = a.[oid]
        FROM [dbo].[MAS_Apartment_HostChange_History] ahch
        INNER JOIN [dbo].[MAS_Apartments] a ON ahch.[ApartmentId] = a.[ApartmentId]
        WHERE ahch.[apartOid] IS NULL;
        PRINT '  ✓ Đã populate apartOid cho MAS_Apartment_HostChange_History: ' + CAST(@@ROWCOUNT AS NVARCHAR(10)) + ' rows';
    END

    -- MAS_Service_Living_Tracking
    IF EXISTS (SELECT 1 FROM sys.tables WHERE name = 'MAS_Service_Living_Tracking')
    BEGIN
        UPDATE slt
        SET slt.[apartOid] = a.[oid]
        FROM [dbo].[MAS_Service_Living_Tracking] slt
        INNER JOIN [dbo].[MAS_Apartments] a ON slt.[ApartmentId] = a.[ApartmentId]
        WHERE slt.[apartOid] IS NULL;
        PRINT '  ✓ Đã populate apartOid cho MAS_Service_Living_Tracking: ' + CAST(@@ROWCOUNT AS NVARCHAR(10)) + ' rows';
    END

    -- MAS_Service_Living_Track
    IF EXISTS (SELECT 1 FROM sys.tables WHERE name = 'MAS_Service_Living_Track')
    BEGIN
        UPDATE slt
        SET slt.[apartOid] = a.[oid]
        FROM [dbo].[MAS_Service_Living_Track] slt
        INNER JOIN [dbo].[MAS_Apartments] a ON slt.[ApartmentId] = a.[ApartmentId]
        WHERE slt.[apartOid] IS NULL;
        PRINT '  ✓ Đã populate apartOid cho MAS_Service_Living_Track: ' + CAST(@@ROWCOUNT AS NVARCHAR(10)) + ' rows';
    END

    -- MAS_Service_Cut_History
    IF EXISTS (SELECT 1 FROM sys.tables WHERE name = 'MAS_Service_Cut_History')
    BEGIN
        UPDATE sch
        SET sch.[apartOid] = a.[oid]
        FROM [dbo].[MAS_Service_Cut_History] sch
        INNER JOIN [dbo].[MAS_Apartments] a ON sch.[ApartmentId] = a.[ApartmentId]
        WHERE sch.[apartOid] IS NULL;
        PRINT '  ✓ Đã populate apartOid cho MAS_Service_Cut_History: ' + CAST(@@ROWCOUNT AS NVARCHAR(10)) + ' rows';
    END

    -- MAS_Service_ReceiveEntry
    IF EXISTS (SELECT 1 FROM sys.tables WHERE name = 'MAS_Service_ReceiveEntry')
    BEGIN
        UPDATE sre
        SET sre.[apartOid] = a.[oid]
        FROM [dbo].[MAS_Service_ReceiveEntry] sre
        INNER JOIN [dbo].[MAS_Apartments] a ON sre.[ApartmentId] = a.[ApartmentId]
        WHERE sre.[apartOid] IS NULL;
        PRINT '  ✓ Đã populate apartOid cho MAS_Service_ReceiveEntry: ' + CAST(@@ROWCOUNT AS NVARCHAR(10)) + ' rows';
    END

    -- MAS_Service_Receipts
    IF EXISTS (SELECT 1 FROM sys.tables WHERE name = 'MAS_Service_Receipts')
    BEGIN
        UPDATE sr
        SET sr.[apartOid] = a.[oid]
        FROM [dbo].[MAS_Service_Receipts] sr
        INNER JOIN [dbo].[MAS_Apartments] a ON sr.[ApartmentId] = a.[ApartmentId]
        WHERE sr.[apartOid] IS NULL;
        PRINT '  ✓ Đã populate apartOid cho MAS_Service_Receipts: ' + CAST(@@ROWCOUNT AS NVARCHAR(10)) + ' rows';
    END

    -- MAS_Service_Receipts_H
    IF EXISTS (SELECT 1 FROM sys.tables WHERE name = 'MAS_Service_Receipts_H')
    BEGIN
        UPDATE srh
        SET srh.[apartOid] = a.[oid]
        FROM [dbo].[MAS_Service_Receipts_H] srh
        INNER JOIN [dbo].[MAS_Apartments] a ON srh.[ApartmentId] = a.[ApartmentId]
        WHERE srh.[apartOid] IS NULL;
        PRINT '  ✓ Đã populate apartOid cho MAS_Service_Receipts_H: ' + CAST(@@ROWCOUNT AS NVARCHAR(10)) + ' rows';
    END

    -- TRS_PayRegBill
    IF EXISTS (SELECT 1 FROM sys.tables WHERE name = 'TRS_PayRegBill')
    BEGIN
        UPDATE prb
        SET prb.[apartOid] = a.[oid]
        FROM [dbo].[TRS_PayRegBill] prb
        INNER JOIN [dbo].[MAS_Apartments] a ON prb.[ApartmentId] = a.[ApartmentId]
        WHERE prb.[apartOid] IS NULL;
        PRINT '  ✓ Đã populate apartOid cho TRS_PayRegBill: ' + CAST(@@ROWCOUNT AS NVARCHAR(10)) + ' rows';
    END

    -- MAS_Apartments_Save
    IF EXISTS (SELECT 1 FROM sys.tables WHERE name = 'MAS_Apartments_Save')
    BEGIN
        UPDATE asave
        SET asave.[apartOid] = a.[oid]
        FROM [dbo].[MAS_Apartments_Save] asave
        INNER JOIN [dbo].[MAS_Apartments] a ON asave.[ApartmentId] = a.[ApartmentId]
        WHERE asave.[apartOid] IS NULL;
        PRINT '  ✓ Đã populate apartOid cho MAS_Apartments_Save: ' + CAST(@@ROWCOUNT AS NVARCHAR(10)) + ' rows';
    END

    -- MAS_CardVehicle
    IF EXISTS (SELECT 1 FROM sys.tables WHERE name = 'MAS_CardVehicle')
    BEGIN
        UPDATE cv
        SET cv.[apartOid] = a.[oid]
        FROM [dbo].[MAS_CardVehicle] cv
        INNER JOIN [dbo].[MAS_Apartments] a ON cv.[ApartmentId] = a.[ApartmentId]
        WHERE cv.[apartOid] IS NULL;
        PRINT '  ✓ Đã populate apartOid cho MAS_CardVehicle: ' + CAST(@@ROWCOUNT AS NVARCHAR(10)) + ' rows';
    END

    -- MAS_CardVehicle_H
    IF EXISTS (SELECT 1 FROM sys.tables WHERE name = 'MAS_CardVehicle_H')
    BEGIN
        UPDATE cvh
        SET cvh.[apartOid] = a.[oid]
        FROM [dbo].[MAS_CardVehicle_H] cvh
        INNER JOIN [dbo].[MAS_Apartments] a ON cvh.[ApartmentId] = a.[ApartmentId]
        WHERE cvh.[apartOid] IS NULL;
        PRINT '  ✓ Đã populate apartOid cho MAS_CardVehicle_H: ' + CAST(@@ROWCOUNT AS NVARCHAR(10)) + ' rows';
    END

    PRINT '';
    PRINT 'Hoàn thành BƯỚC 2';
    PRINT '';

    -- =============================================
    -- BƯỚC 3: Tạo Index cho apartOid
    -- =============================================
    PRINT 'BƯỚC 3: Tạo Index cho apartOid...';
    PRINT '';

    -- Tạo index cho các bảng chính
    IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = 'IX_MAS_Apartment_Member_apartOid' AND object_id = OBJECT_ID('dbo.MAS_Apartment_Member'))
    BEGIN
        CREATE NONCLUSTERED INDEX [IX_MAS_Apartment_Member_apartOid]
        ON [dbo].[MAS_Apartment_Member]([apartOid] ASC);
        PRINT '  ✓ Đã tạo index IX_MAS_Apartment_Member_apartOid';
    END

    -- MAS_Customers - BỎ QUA: Bảng này dùng chung cho nhiều MAS_Apartments, không migrate

    IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = 'IX_MAS_Requests_apartOid' AND object_id = OBJECT_ID('dbo.MAS_Requests'))
    BEGIN
        CREATE NONCLUSTERED INDEX [IX_MAS_Requests_apartOid]
        ON [dbo].[MAS_Requests]([apartOid] ASC);
        PRINT '  ✓ Đã tạo index IX_MAS_Requests_apartOid';
    END

    PRINT '';
    PRINT 'Hoàn thành BƯỚC 3';
    PRINT '';

    -- =============================================
    -- BƯỚC 4: Tạo Foreign Key từ apartOid → MAS_Apartments.oid
    -- =============================================
    PRINT 'BƯỚC 4: Tạo Foreign Key từ apartOid → MAS_Apartments.oid...';
    PRINT '';

    -- MAS_Apartment_Member
    IF NOT EXISTS (SELECT 1 FROM sys.foreign_keys WHERE name = 'FK_MAS_Apartment_Member_apartOid')
    BEGIN
        ALTER TABLE [dbo].[MAS_Apartment_Member]
        ADD CONSTRAINT [FK_MAS_Apartment_Member_apartOid]
        FOREIGN KEY ([apartOid]) REFERENCES [dbo].[MAS_Apartments]([oid]);
        PRINT '  ✓ Đã tạo FK FK_MAS_Apartment_Member_apartOid';
    END
    ELSE
        PRINT '  - FK FK_MAS_Apartment_Member_apartOid đã tồn tại';

    -- MAS_Customers - BỎ QUA: Bảng này dùng chung cho nhiều MAS_Apartments, không migrate

    -- MAS_Apartment_Card
    IF NOT EXISTS (SELECT 1 FROM sys.foreign_keys WHERE name = 'FK_MAS_Apartment_Card_apartOid')
    BEGIN
        ALTER TABLE [dbo].[MAS_Apartment_Card]
        ADD CONSTRAINT [FK_MAS_Apartment_Card_apartOid]
        FOREIGN KEY ([apartOid]) REFERENCES [dbo].[MAS_Apartments]([oid]);
        PRINT '  ✓ Đã tạo FK FK_MAS_Apartment_Card_apartOid';
    END
    ELSE
        PRINT '  - FK FK_MAS_Apartment_Card_apartOid đã tồn tại';

    -- MAS_Customer_Household
    IF NOT EXISTS (SELECT 1 FROM sys.foreign_keys WHERE name = 'FK_MAS_Customer_Household_apartOid')
    BEGIN
        ALTER TABLE [dbo].[MAS_Customer_Household]
        ADD CONSTRAINT [FK_MAS_Customer_Household_apartOid]
        FOREIGN KEY ([apartOid]) REFERENCES [dbo].[MAS_Apartments]([oid]);
        PRINT '  ✓ Đã tạo FK FK_MAS_Customer_Household_apartOid';
    END
    ELSE
        PRINT '  - FK FK_MAS_Customer_Household_apartOid đã tồn tại';

    -- MAS_Requests
    IF NOT EXISTS (SELECT 1 FROM sys.foreign_keys WHERE name = 'FK_MAS_Requests_apartOid')
    BEGIN
        ALTER TABLE [dbo].[MAS_Requests]
        ADD CONSTRAINT [FK_MAS_Requests_apartOid]
        FOREIGN KEY ([apartOid]) REFERENCES [dbo].[MAS_Apartments]([oid]);
        PRINT '  ✓ Đã tạo FK FK_MAS_Requests_apartOid';
    END
    ELSE
        PRINT '  - FK FK_MAS_Requests_apartOid đã tồn tại';

    -- Các bảng khác (nếu tồn tại)
    IF EXISTS (SELECT 1 FROM sys.tables WHERE name = 'MAS_Feedbacks')
    AND NOT EXISTS (SELECT 1 FROM sys.foreign_keys WHERE name = 'FK_MAS_Feedbacks_apartOid')
    BEGIN
        ALTER TABLE [dbo].[MAS_Feedbacks]
        ADD CONSTRAINT [FK_MAS_Feedbacks_apartOid]
        FOREIGN KEY ([apartOid]) REFERENCES [dbo].[MAS_Apartments]([oid]);
        PRINT '  ✓ Đã tạo FK FK_MAS_Feedbacks_apartOid';
    END

    IF EXISTS (SELECT 1 FROM sys.tables WHERE name = 'MAS_Cards')
    AND NOT EXISTS (SELECT 1 FROM sys.foreign_keys WHERE name = 'FK_MAS_Cards_apartOid')
    BEGIN
        ALTER TABLE [dbo].[MAS_Cards]
        ADD CONSTRAINT [FK_MAS_Cards_apartOid]
        FOREIGN KEY ([apartOid]) REFERENCES [dbo].[MAS_Apartments]([oid]);
        PRINT '  ✓ Đã tạo FK FK_MAS_Cards_apartOid';
    END

    IF EXISTS (SELECT 1 FROM sys.tables WHERE name = 'MAS_Apartment_Service_Extend')
    AND NOT EXISTS (SELECT 1 FROM sys.foreign_keys WHERE name = 'FK_MAS_Apartment_Service_Extend_apartOid')
    BEGIN
        ALTER TABLE [dbo].[MAS_Apartment_Service_Extend]
        ADD CONSTRAINT [FK_MAS_Apartment_Service_Extend_apartOid]
        FOREIGN KEY ([apartOid]) REFERENCES [dbo].[MAS_Apartments]([oid]);
        PRINT '  ✓ Đã tạo FK FK_MAS_Apartment_Service_Extend_apartOid';
    END

    IF EXISTS (SELECT 1 FROM sys.tables WHERE name = 'MAS_Apartment_Service_Living')
    AND NOT EXISTS (SELECT 1 FROM sys.foreign_keys WHERE name = 'FK_MAS_Apartment_Service_Living_apartOid')
    BEGIN
        ALTER TABLE [dbo].[MAS_Apartment_Service_Living]
        ADD CONSTRAINT [FK_MAS_Apartment_Service_Living_apartOid]
        FOREIGN KEY ([apartOid]) REFERENCES [dbo].[MAS_Apartments]([oid]);
        PRINT '  ✓ Đã tạo FK FK_MAS_Apartment_Service_Living_apartOid';
    END

    IF EXISTS (SELECT 1 FROM sys.tables WHERE name = 'MAS_Service_Receipts')
    AND NOT EXISTS (SELECT 1 FROM sys.foreign_keys WHERE name = 'FK_MAS_Service_Receipts_apartOid')
    BEGIN
        ALTER TABLE [dbo].[MAS_Service_Receipts]
        ADD CONSTRAINT [FK_MAS_Service_Receipts_apartOid]
        FOREIGN KEY ([apartOid]) REFERENCES [dbo].[MAS_Apartments]([oid]);
        PRINT '  ✓ Đã tạo FK FK_MAS_Service_Receipts_apartOid';
    END

    PRINT '';
    PRINT 'Hoàn thành BƯỚC 4';
    PRINT '';

    -- =============================================
    -- BƯỚC 5: Chuyển Primary Key của MAS_Apartments từ ApartmentId → oid
    -- =============================================
    PRINT 'BƯỚC 5: Chuyển Primary Key của MAS_Apartments từ ApartmentId → oid...';
    PRINT '';

    -- Kiểm tra xem đã chuyển PK chưa
    DECLARE @CurrentPK NVARCHAR(200);
    SELECT @CurrentPK = c.name
    FROM sys.key_constraints kc
    INNER JOIN sys.index_columns ic ON kc.parent_object_id = ic.object_id AND kc.unique_index_id = ic.index_id
    INNER JOIN sys.columns c ON ic.object_id = c.object_id AND ic.column_id = c.column_id
    WHERE kc.type = 'PK' AND kc.parent_object_id = OBJECT_ID('dbo.MAS_Apartments');

    IF @CurrentPK = 'ApartmentId'
    BEGIN
        -- Đảm bảo tất cả oid đều có giá trị và unique
        IF EXISTS (SELECT 1 FROM [dbo].[MAS_Apartments] WHERE [oid] IS NULL)
        BEGIN
            RAISERROR('Có bản ghi trong MAS_Apartments có oid = NULL. Vui lòng kiểm tra!', 16, 1);
        END

        IF EXISTS (
            SELECT [oid], COUNT(*) as cnt
            FROM [dbo].[MAS_Apartments]
            GROUP BY [oid]
            HAVING COUNT(*) > 1
        )
        BEGIN
            RAISERROR('Có oid trùng lặp trong MAS_Apartments. Vui lòng kiểm tra!', 16, 1);
        END

        -- Xóa Primary Key cũ
        ALTER TABLE [dbo].[MAS_Apartments]
        DROP CONSTRAINT [PK_MAS_Apartments];
        PRINT '  ✓ Đã xóa Primary Key cũ (PK_MAS_Apartments)';

        -- Tạo Primary Key mới với oid
        ALTER TABLE [dbo].[MAS_Apartments]
        ADD CONSTRAINT [PK_MAS_Apartments] PRIMARY KEY CLUSTERED ([oid] ASC);
        PRINT '  ✓ Đã tạo Primary Key mới với oid';

        -- Tạo Unique Index cho ApartmentId (để backward compatibility)
        IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = 'IX_MAS_Apartments_ApartmentId_Unique' AND object_id = OBJECT_ID('dbo.MAS_Apartments'))
        BEGIN
            CREATE UNIQUE NONCLUSTERED INDEX [IX_MAS_Apartments_ApartmentId_Unique]
            ON [dbo].[MAS_Apartments]([ApartmentId] ASC);
            PRINT '  ✓ Đã tạo Unique Index cho ApartmentId (backward compatibility)';
        END
    END
    ELSE IF @CurrentPK = 'oid'
    BEGIN
        PRINT '  - Primary Key đã được chuyển sang oid rồi';
    END
    ELSE
    BEGIN
        PRINT '  ⚠ Cảnh báo: Primary Key hiện tại không phải ApartmentId hoặc oid: ' + @CurrentPK;
    END

    PRINT '';
    PRINT 'Hoàn thành BƯỚC 5';
    PRINT '';

    -- =============================================
    -- HOÀN THÀNH
    -- =============================================
    PRINT '========================================';
    PRINT 'Migration hoàn thành thành công!';
    PRINT '========================================';
    PRINT '';
    PRINT 'LƯU Ý:';
    PRINT '1. Kiểm tra dữ liệu đã được migrate đúng chưa';
    PRINT '2. Cập nhật Stored Procedures để sử dụng apartOid thay vì ApartmentId';
    PRINT '3. Cập nhật Application Code để sử dụng apartOid';
    PRINT '4. Sau khi đảm bảo không còn sử dụng ApartmentId, có thể xóa cột ApartmentId (tùy chọn)';
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
