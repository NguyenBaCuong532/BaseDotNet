-- Oid = mã chính; id/buildingCd = phụ (tương thích ngược, bỏ sau migrate).
CREATE   PROCEDURE [dbo].[sp_res_elevator_floor_del] 
	 @UserId UNIQUEIDENTIFIER = NULL
    , @id NVARCHAR(50) = NULL
	, @buildingCd NVARCHAR(50) = NULL
	, @floorOid UNIQUEIDENTIFIER = NULL
	, @acceptLanguage NVARCHAR(50) = N'vi-VN'
AS
BEGIN
    BEGIN TRY
        DECLARE @valid BIT = 0;
        DECLARE @messages NVARCHAR(250);

        -- Ưu tiên oid (mã chính); khi có id thì resolve floorOid từ bảng
        IF @id IS NOT NULL AND @floorOid IS NULL
            SET @floorOid = (SELECT oid FROM MAS_Elevator_Floor WHERE CAST(Id AS NVARCHAR(50)) = @id);
        IF @floorOid IS NULL
        BEGIN
            SELECT 0 AS valid, N'Thiếu id hoặc floorOid' AS [messages];
            RETURN;
        END
        
		/*IF EXISTS (
                SELECT TOP 1 1
                FROM MAS_Elevator_Card c
					join ELE_Floor b on c.AreaCd = b.BuildCd
                WHERE b.id = @id
                )
        BEGIN
            SET @messages = N'Khu vực đã được sử dụng. Không thể xóa'
            GOTO FINAL
        END*/

        DELETE MAS_Elevator_Floor
        WHERE oid = @floorOid

        SET @valid = 1
        SET @messages = N'Xóa thẻ thành công'

        --
        FINAL:

        SELECT valid = @valid
            , messages = @messages
    END TRY

    BEGIN CATCH
        DECLARE @ErrorNum INT
            , @ErrorMsg VARCHAR(200)
            , @ErrorProc VARCHAR(50)
            , @SessionID INT
            , @AddlInfo VARCHAR(MAX);

        SET @ErrorNum = ERROR_NUMBER();
        SET @ErrorMsg = 'sp_res_elevator_floor_del' + ERROR_MESSAGE();
        SET @ErrorProc = ERROR_PROCEDURE();
        SET @AddlInfo = '';
        SET @valid = 0;
        SET @messages = ERROR_MESSAGE();

        EXEC utl_Insert_ErrorLog @ErrorNum
            , @ErrorMsg
            , @ErrorProc
            , 'MAS_C'
            , 'DEL'
            , @SessionID
            , @AddlInfo;
    END CATCH;

    SELECT @valid AS valid
        , @messages AS [messages];
END;