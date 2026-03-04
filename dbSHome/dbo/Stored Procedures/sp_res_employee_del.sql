-- =============================================
-- Author:      System
-- Create date: 2024
-- Description: Xóa nhân viên
-- =============================================
CREATE PROCEDURE [dbo].[sp_res_employee_del]
    @UserId NVARCHAR(450) = NULL,
    @empId UNIQUEIDENTIFIER = NULL
AS
BEGIN TRY
    SET NOCOUNT ON;

    IF NOT EXISTS (SELECT 1 FROM mas_employee WHERE empId = @empId)
    BEGIN
        SELECT 0 AS valid, N'Không tìm thấy nhân viên' AS messages;
    END
    ELSE
    BEGIN
        DELETE FROM [dbo].[mas_employee]
        WHERE empId = @empId;

        SELECT 1 AS valid, N'Xóa thành công' AS messages;
    END

END TRY
BEGIN CATCH
    DECLARE @ErrorNum INT,
            @ErrorMsg VARCHAR(200),
            @ErrorProc VARCHAR(50),
            @SessionID INT,
            @AddlInfo VARCHAR(MAX);

    SET @ErrorNum = ERROR_NUMBER();
    SET @ErrorMsg = 'sp_res_employee_del' + ERROR_MESSAGE();
    SET @ErrorProc = ERROR_PROCEDURE();
    SET @AddlInfo = ' ';

    EXEC utl_ErrorLog_Set @ErrorNum,@ErrorMsg,@ErrorProc,'Employee','DEL',@SessionID,@AddlInfo;
END CATCH;