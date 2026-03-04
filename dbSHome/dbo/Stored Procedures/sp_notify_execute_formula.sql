
-- =============================================
-- Author:		Auto-generated
-- Create date: 2024
-- Description:	Stored procedure helper để thực thi formula từ NotifyField
--              Hỗ trợ thay thế các placeholder: {empId}, {canId}, {custId}, {n_id}, {sourceId}, {organizeId}
--              Trả về giá trị đã format theo field_type
-- =============================================
CREATE   PROCEDURE [dbo].[sp_notify_execute_formula]
    @formula         NVARCHAR(MAX),           -- Công thức SQL cần thực thi
    @field_type      NVARCHAR(50) = NULL,     -- Loại field để format
    @empId           UNIQUEIDENTIFIER = NULL, -- Tham số empId (khi to_type = 0)
    @canId           UNIQUEIDENTIFIER = NULL, -- Tham số canId (khi to_type = 1)
    @custId          UNIQUEIDENTIFIER = NULL, -- Tham số custId (khi to_type = 2)
    @n_id            UNIQUEIDENTIFIER = NULL, -- ID của thông báo
    @sourceId        UNIQUEIDENTIFIER = NULL, -- ID của record nguồn
    @organizeId      UNIQUEIDENTIFIER = NULL, -- OrganizeId
    @value           NVARCHAR(MAX) OUTPUT     -- Giá trị trả về (đã format)
AS
BEGIN
    SET NOCOUNT ON;
    
    DECLARE @result NVARCHAR(MAX) = NULL;
    DECLARE @sql NVARCHAR(MAX) = @formula;
    
    BEGIN TRY
        -- Thay thế các placeholder trong formula
        IF @empId IS NOT NULL
            SET @sql = REPLACE(@sql, '{empId}', CAST(@empId AS NVARCHAR(36)));
        IF @canId IS NOT NULL
            SET @sql = REPLACE(@sql, '{canId}', CAST(@canId AS NVARCHAR(36)));
        IF @custId IS NOT NULL
            SET @sql = REPLACE(@sql, '{custId}', CAST(@custId AS NVARCHAR(36)));
        IF @n_id IS NOT NULL
            SET @sql = REPLACE(@sql, '{n_id}', CAST(@n_id AS NVARCHAR(36)));
        IF @sourceId IS NOT NULL
            SET @sql = REPLACE(@sql, '{sourceId}', CAST(@sourceId AS NVARCHAR(36)));
        IF @organizeId IS NOT NULL
            SET @sql = REPLACE(@sql, '{organizeId}', CAST(@organizeId AS NVARCHAR(36)));
        
        DECLARE @result_table TABLE (value NVARCHAR(MAX));
        
        -- Thực thi dynamic SQL
        INSERT INTO @result_table
        EXEC sp_executesql @sql;
        
        SELECT TOP 1 @result = value FROM @result_table;
    END TRY
    BEGIN CATCH
        -- Nếu lỗi, set giá trị NULL
        SET @result = NULL;
    END CATCH
    
    -- Format giá trị theo field_type nếu cần
    IF @field_type IS NOT NULL AND @result IS NOT NULL
    BEGIN
        -- Format date
        IF @field_type = 'date'
        BEGIN
            DECLARE @date_value DATETIME;
            SET @date_value = TRY_CAST(@result AS DATETIME);
            IF @date_value IS NOT NULL
                SET @result = FORMAT(@date_value, 'dd/MM/yyyy');
        END
        -- Format datetime
        ELSE IF @field_type = 'datetime'
        BEGIN
            SET @date_value = TRY_CAST(@result AS DATETIME);
            IF @date_value IS NOT NULL
                SET @result = FORMAT(@date_value, 'dd/MM/yyyy HH:mm:ss');
        END
        -- Format time
        ELSE IF @field_type = 'time'
        BEGIN
            DECLARE @time_value TIME = TRY_CAST(@result AS TIME);
            IF @time_value IS NOT NULL
                SET @result = FORMAT(@time_value, 'HH:mm:ss');
        END
        -- Format currency
        ELSE IF @field_type = 'currency'
        BEGIN
            DECLARE @num_value DECIMAL(18,2);
            SET @num_value = TRY_CAST(@result AS DECIMAL(18,2));
            IF @num_value IS NOT NULL
                SET @result = FORMAT(@num_value, 'N0') + ' VNĐ';
        END
        -- Format number
        ELSE IF @field_type = 'number'
        BEGIN
            SET @num_value = TRY_CAST(@result AS DECIMAL(18,2));
            IF @num_value IS NOT NULL
                SET @result = FORMAT(@num_value, 'N0');
        END
    END
    
    SET @value = ISNULL(@result, '');
END