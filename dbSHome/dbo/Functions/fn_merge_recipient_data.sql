CREATE FUNCTION [dbo].[fn_merge_recipient_data]
(
      @dataJson   NVARCHAR(MAX)
    , @fullName   NVARCHAR(200)
    , @email      NVARCHAR(200)
    , @phone      NVARCHAR(50)
)
RETURNS NVARCHAR(MAX)
AS
BEGIN
    /*
        Hàm này:
        1. Loại bỏ các key fullName, email, phone cũ trong dataJson (vì có thể bị duplicate hoặc sai)
        2. Thêm lại với giá trị đúng của người nhận hiện tại
        
        Input dataJson format: [{"key":"...", "value":"..."}, ...]
        Output: dataJson đã được cập nhật đúng thông tin người nhận
    */

    DECLARE @result NVARCHAR(MAX);

    -- Nếu JSON rỗng hoặc không hợp lệ, khởi tạo mảng rỗng
    IF @dataJson IS NULL OR ISJSON(@dataJson) = 0
    BEGIN
        SET @result = '[]';
    END
    ELSE
    BEGIN
        -- Loại bỏ các key fullName, email, phone cũ (giữ lại các key khác, chỉ lấy unique)
        SELECT @result = (
            SELECT [key], [value]
            FROM (
                SELECT 
                    [key], 
                    [value],
                    ROW_NUMBER() OVER (PARTITION BY [key] ORDER BY (SELECT NULL)) AS rn
                FROM OPENJSON(@dataJson)
                WITH ([key] NVARCHAR(200), [value] NVARCHAR(MAX))
                WHERE [key] NOT IN ('fullName', 'email', 'phone')
            ) t
            WHERE rn = 1
            FOR JSON PATH
        );

        IF @result IS NULL
            SET @result = '[]';
    END

    -- Thêm fullName của người nhận
    SET @result = JSON_MODIFY(
        @result, 
        'append $', 
        JSON_QUERY('{"key":"fullName","value":"' + REPLACE(ISNULL(@fullName, ''), '"', '\"') + '"}')
    );

    -- Thêm email của người nhận
    SET @result = JSON_MODIFY(
        @result, 
        'append $', 
        JSON_QUERY('{"key":"email","value":"' + REPLACE(ISNULL(@email, ''), '"', '\"') + '"}')
    );

    -- Thêm phone của người nhận
    SET @result = JSON_MODIFY(
        @result, 
        'append $', 
        JSON_QUERY('{"key":"phone","value":"' + REPLACE(ISNULL(@phone, ''), '"', '\"') + '"}')
    );

    RETURN @result;
END