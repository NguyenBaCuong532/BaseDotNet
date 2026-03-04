CREATE PROCEDURE [dbo].[sp_res_advertisement_set]
    @id UNIQUEIDENTIFIER = NULL,
    @title NVARCHAR(200),
    @description NVARCHAR(500) = NULL,
    @image_url NVARCHAR(500),
    @link_url NVARCHAR(500) = NULL,
    @position INT = 1,
    @priority INT = 1,
    @start_date DATETIME,
    @end_date DATETIME,
    @is_active BIT = 1,
    @company_name NVARCHAR(200) = NULL,
    @company_contact NVARCHAR(100) = NULL,
    @company_phone NVARCHAR(20) = NULL,
    @company_email NVARCHAR(100) = NULL,
    @user_id UNIQUEIDENTIFIER
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @result_id UNIQUEIDENTIFIER;
    DECLARE @current_dt DATETIME = GETUTCDATE();

    -- Validation
    IF @title IS NULL OR LEN(TRIM(@title)) = 0
    BEGIN
        SELECT 0 AS isValid, 'Title is required' AS message;
        RETURN;
    END

    IF @image_url IS NULL OR LEN(TRIM(@image_url)) = 0
    BEGIN
        SELECT 0 AS isValid, 'Image URL is required' AS message;
        RETURN;
    END

    IF @start_date >= @end_date
    BEGIN
        SELECT 0 AS isValid, 'Start date must be before end date' AS message;
        RETURN;
    END

    BEGIN TRY
        IF @id IS NULL OR @id = '00000000-0000-0000-0000-000000000000'
        BEGIN
            -- Create new record
            SET @result_id = NEWID();

            INSERT INTO advertisement_info (
                id, title, description, image_url, link_url, position, priority,
                start_date, end_date, is_active, company_name, company_contact,
                company_phone, company_email, click_count, view_count, is_deleted,
                app_st, created_dt, created_by, updated_dt, updated_by
            )
            VALUES (
                @result_id, @title, @description, @image_url, @link_url, @position, @priority,
                @start_date, @end_date, @is_active, @company_name, @company_contact,
                @company_phone, @company_email, 0, 0, 0,
                0, @current_dt, @user_id, NULL, NULL
            );

            SELECT 1 AS isValid, 'Advertisement created successfully' AS message, @result_id AS id;
        END
        ELSE
        BEGIN
            -- Update existing record
            IF NOT EXISTS (SELECT 1 FROM advertisement_info WHERE id = @id AND is_deleted = 0)
            BEGIN
                SELECT 0 AS isValid, 'Advertisement not found' AS message;
                RETURN;
            END

            UPDATE advertisement_info
            SET title = @title,
                description = @description,
                image_url = @image_url,
                link_url = @link_url,
                position = @position,
                priority = @priority,
                start_date = @start_date,
                end_date = @end_date,
                is_active = @is_active,
                company_name = @company_name,
                company_contact = @company_contact,
                company_phone = @company_phone,
                company_email = @company_email,
                updated_dt = @current_dt,
                updated_by = @user_id
            WHERE id = @id;

            SELECT 1 AS isValid, 'Advertisement updated successfully' AS message, @id AS id;
        END
    END TRY
    BEGIN CATCH
        SELECT 0 AS isValid, ERROR_MESSAGE() AS message;
    END CATCH
END
GO