
CREATE PROCEDURE [dbo].[sp_res_apartment_service_living_del]
    @userId NVARCHAR(450),
    @LivingId INT
AS
BEGIN TRY
    DECLARE @valid BIT = 0;
    DECLARE @messages NVARCHAR(200) = N'Có lỗi xảy ra';

    DECLARE @errmessage NVARCHAR(100) = N'This Service_Living: ' + CAST(@LivingId AS VARCHAR) + N' is exists!';

    IF NOT EXISTS
    (
        SELECT TrackingId
        FROM [MAS_Service_Living_Tracking]
        WHERE LivingId = @LivingId
    )
	BEGIN
	    DELETE trg
        FROM MAS_Apartment_Service_Living trg
        WHERE LivingId = @LivingId;
		--
		SET @valid = 1;
        SET @messages = N'Xóa thành công';
	END  
    ELSE
    BEGIN
        SET @valid = 0;
        SET @messages = N'Đã có cập cập nhật dữ liệu, không thể xóa';
    --RAISERROR (@errmessage, -- Message text.
    --	   16, -- Severity.
    --	   1 -- State.
    --	   );
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
    SET @ErrorMsg = 'sp_res_apartment_service_living_del' + ERROR_MESSAGE();
    SET @ErrorProc = ERROR_PROCEDURE();

    SET @AddlInfo = '';

    EXEC utl_Insert_ErrorLog @ErrorNum,
                             @ErrorMsg,
                             @ErrorProc,
                             'Service_Living',
                             'DEL',
                             @SessionID,
                             @AddlInfo;
END CATCH;

--select * from utl_Error_Log where TableName = 'Service_Living' order by CreatedDate desc