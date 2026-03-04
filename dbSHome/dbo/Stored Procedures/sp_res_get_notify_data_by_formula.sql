-- =============================================
-- Author:      System
-- Create date: 2026-01-07
-- Description: Lấy dữ liệu thông báo dựa trên formulaId và sourceId
--              Trả về JSON chứa các key-value của fields
-- =============================================
CREATE PROCEDURE [dbo].[sp_res_get_notify_data_by_formula]
    @formula NVARCHAR(MAX),
    @sourceId   NVARCHAR(36),
    @projectCd NVARCHAR(30) = NULL,
    @resultJson NVARCHAR(MAX) OUTPUT
AS
BEGIN
    SET NOCOUNT ON;
    
    DECLARE @sql NVARCHAR(MAX);
    DECLARE @params NVARCHAR(500);
    
    IF @formula IS NULL
    BEGIN
        SET @resultJson = '[]';
        RETURN;
    END
    

    -- Thay thế các placeholder trong formula
    SET @formula = REPLACE(@formula, '{sourceId}', CAST(@sourceId AS NVARCHAR(50)));
    SET @formula = REPLACE(@formula, '{projectCd}', ISNULL(@projectCd, ''));
    
    -- Tạo bảng tạm để lưu kết quả
    CREATE TABLE #NotifyData (
        [key] NVARCHAR(200),
        [value] NVARCHAR(MAX)
    );

    -- Thực thi dynamic SQL
    BEGIN TRY
        -- Formula phải trả về kết quả với 2 cột: [key], [value]
        INSERT INTO #NotifyData ([key], [value])
        EXEC sp_executesql @formula;
    END TRY
    BEGIN CATCH
        -- Log lỗi nếu cần
        SET @resultJson = '[]';
        DROP TABLE IF EXISTS #NotifyData;
        RETURN;
    END CATCH
    
    -- Chuyển kết quả thành JSON
    SELECT @resultJson = (
        SELECT [key], [value]
        FROM #NotifyData
        FOR JSON PATH
    );
    
    -- Cleanup
    DROP TABLE IF EXISTS #NotifyData;
    
    IF @resultJson IS NULL
        SET @resultJson = '[]';
END;