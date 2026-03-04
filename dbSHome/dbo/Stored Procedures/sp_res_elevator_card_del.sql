
CREATE PROCEDURE [dbo].[sp_res_elevator_card_del] 
	 @UserId UNIQUEIDENTIFIER = NULL
    , @Oids NVARCHAR(MAX),
	@acceptLanguage NVARCHAR(50) = N'vi-VN'
AS
BEGIN
    BEGIN TRY
        DECLARE @valid BIT = 0;
        DECLARE @messages NVARCHAR(250);

		--bảng tạm cho oids
		SET NOCOUNT ON;
			DROP TABLE IF EXISTS #ids;
			CREATE TABLE #ids (id NVARCHAR(4000) NOT NULL);

			INSERT INTO #ids(id)
			SELECT TRIM(part)
			FROM dbo.SplitString(@Oids, ',')
			WHERE TRIM(part) <> '';
		-------
        
		--IF EXISTS (
        --        SELECT TOP 1 1
        --        FROM MAS_Elevator_Card
        --        WHERE Oid = @Oid
        --        )
        --BEGIN
        --    SET @messages = N'Thẻ đã được sử dụng. Không thể xóa'

        --    GOTO FINAL
        --END

        --

        DELETE e FROM MAS_Elevator_Card e
        WHERE --Oid = @Oid
			EXISTS ( SELECT TOP 1 1 FROM #ids o WHERE e.Oid = o.id)

        SET @valid = 1
        SET @messages = N'Xóa thẻ thành công'
		        
    END TRY

    BEGIN CATCH
        DECLARE @ErrorNum INT
            , @ErrorMsg VARCHAR(200)
            , @ErrorProc VARCHAR(50)
            , @SessionID INT
            , @AddlInfo VARCHAR(MAX);

        SET @ErrorNum = ERROR_NUMBER();
        SET @ErrorMsg = 'sp_res_card_base_del' + ERROR_MESSAGE();
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
	FINAL:
    SELECT @valid AS valid
        , @messages AS [messages];
END;