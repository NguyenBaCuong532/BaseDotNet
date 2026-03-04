Create     PROCEDURE [dbo].[sp_res_elevator_device_category_del] 
	  @UserId UNIQUEIDENTIFIER = NULL
     ,@ids NVARCHAR(450)
	 ,@InvalidId NVARCHAR(50) = null
	 ,@acceptLanguage NVARCHAR(50) = N'vi-VN'
AS
BEGIN

    BEGIN TRY
        DECLARE @valid BIT = 0;
        DECLARE @messages NVARCHAR(250);
        
		SET @ids = NULLIF(@ids, '')
		-------
				SET NOCOUNT ON;
				DROP TABLE IF EXISTS #ids;
				CREATE TABLE #ids (id NVARCHAR(4000) NOT NULL);

				INSERT INTO #ids(id)
				SELECT TRY_CAST(TRIM(part) AS nvarchar)
				FROM SplitString(@ids, ',')
				WHERE TRIM(part) <> '';
		------

		IF not exists (select 1 from #ids)
			BEGIN
				SET @messages = N'Id truyền vào đang bị null'
				GOTO FINAL
			END

		IF EXISTS (
                SELECT TOP 1 1
                FROM MAS_Elevator_Device_Category b
				inner join #ids i on b.Id = i.id
                and IsActived = 'true'
                )
        BEGIN
			Select @InvalidId = STRING_AGG(b.HardwareId, ', ')
			FROM MAS_Elevator_Device_Category b
			inner join #ids i on b.Id = i.id
            and IsActived = 'true'

            SET @messages = N'Mã thiết bị '+ @InvalidId + N' đang hoạt động, vui lòng kiểm tra lại'
            GOTO FINAL
        END

        DELETE   MAS_Elevator_Device_Category
        WHERE id in (select id from #ids)

        SET @valid = 1
        SET @messages = N'Xóa danh mục thiết bị thành công'

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
        SET @ErrorMsg = 'sp_res_elevator_device_category_del' + ERROR_MESSAGE();
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