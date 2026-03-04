


-- Oid = mã chính; id/buildingCd = phụ (tương thích ngược, bỏ sau migrate).
CREATE PROCEDURE [dbo].[sp_res_elevator_area_del] 
	  @UserId UNIQUEIDENTIFIER = NULL
    , @buildingCd nvarchar(50) = NULL
	, @id nvarchar(50) = NULL
	, @areaOid UNIQUEIDENTIFIER = NULL
	, @acceptLanguage NVARCHAR(50) = N'vi-VN'
AS
BEGIN
    BEGIN TRY
        DECLARE @valid BIT = 0;
        DECLARE @messages NVARCHAR(250);

        -- Ưu tiên oid (mã chính); khi có areaOid thì resolve id từ bảng
        IF @id IS NOT NULL and @areaOid IS NULL
            SET @areaOid = (SELECT oid FROM ELE_BuildArea WHERE id = @id);
        
        IF @areaOid IS NULL
        BEGIN
            SELECT 0 AS valid, N'Thiếu id hoặc areaOid' AS [messages];
            RETURN;
        END
        
		IF EXISTS (
                SELECT TOP 1 1
                FROM MAS_Elevator_Card c
					join ELE_BuildArea b on c.AreaCd = b.AreaCd
                WHERE b.oid = @areaOid
                )
        BEGIN
            SET @messages = N'Khu vực đã được sử dụng. Không thể xóa'
            GOTO FINAL
        END

        --
        DELETE ELE_BuildArea
        WHERE oid = @areaOid

        SET @valid = 1
        SET @messages = N'Xóa thẻ thành công'

        --
    END TRY

    BEGIN CATCH
        DECLARE @ErrorNum INT
            , @ErrorMsg VARCHAR(200)
            , @ErrorProc VARCHAR(50)
            , @SessionID INT
            , @AddlInfo VARCHAR(MAX);

        SET @ErrorNum = ERROR_NUMBER();
        SET @ErrorMsg = 'sp_res_elevator_area_del' + ERROR_MESSAGE();
        SET @ErrorProc = ERROR_PROCEDURE();
        SET @AddlInfo = '';
        SET @valid = 0;
        SET @messages = ERROR_MESSAGE();

        EXEC utl_Insert_ErrorLog @ErrorNum
            , @ErrorMsg
            , @ErrorProc
            , 'elevator_area_del'
            , 'DEL'
            , @SessionID
            , @AddlInfo;
    END CATCH;
	FINAL:
    SELECT @valid AS valid
        , @messages AS [messages];
END;