CREATE   PROCEDURE [dbo].[sp_res_apartment_service_cut_history_del]
    @userId NVARCHAR(450),
    @id nvarchar(50)
AS
BEGIN TRY
    DECLARE @valid BIT = 0;
    DECLARE @messages NVARCHAR(200) = N'Có lỗi xảy ra';

    DECLARE @errmessage NVARCHAR(100) = N'This Service_Living: ' + CAST(@id AS VARCHAR) + N' is exists!';

    IF EXISTS
    (
        SELECT 1
        FROM MAS_Service_Cut_History
        WHERE id = @id
    )
	BEGIN
	    DELETE trg
        FROM MAS_Service_Cut_History trg
        WHERE id = @id;
		SET @valid = 1;
        SET @messages = N'Xóa thành công';
	END  
    ELSE
    BEGIN
        SET @valid = 0;
        SET @messages = N'Không thấy dữ liệu';
    END;

    SELECT @valid AS valid,
           @messages AS [messages];

END TRY
BEGIN CATCH
    DECLARE @ErrorNum INT,
            @ErrorMsg VARCHAR(200),
            @ErrorProc VARCHAR(50),
            @SessionID INT,
            @AddlInfo VARCHAR(MAX);

    SET @ErrorNum = ERROR_NUMBER();
    SET @ErrorMsg = 'sp_res_apartment_service_cut_history_del' + ERROR_MESSAGE();
    SET @ErrorProc = ERROR_PROCEDURE();

    SET @AddlInfo = '';

    EXEC utl_Insert_ErrorLog @ErrorNum,
                             @ErrorMsg,
                             @ErrorProc,
                             'MAS_Service_Cut_History',
                             'DEL',
                             @SessionID,
                             @AddlInfo;
END CATCH;