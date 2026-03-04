
-- =============================================
-- Author: ANHTT
-- Create date: 2025-09-05 12:38:38
-- Description:	Delete MAS_Apartment_Reg
-- =============================================

CREATE   PROCEDURE [dbo].[sp_app_apartment_reg_del]
    @userId UNIQUEIDENTIFIER,
    @apartmentRegId BIGINT,
    @acceptLanguage	nvarchar(50) = 'vi-VN'
AS
BEGIN TRY
    DECLARE @valid BIT = 0,
            @messages NVARCHAR(250);

    --check if not exists
    IF NOT EXISTS (SELECT 1 FROM [MAS_Apartment_Reg] WHERE Id = @apartmentRegId)
    BEGIN
        SET @messages = N'Bản ghi không tồn tại';
        GOTO FINAL;
    END;
    IF EXISTS (SELECT 1 FROM [MAS_Apartment_Reg] WHERE Id = @apartmentRegId and reg_st = 1)
    BEGIN
        SET @messages = N'Yêu cầu đã được duyệt. Không thể xóa';
        GOTO FINAL;
    END;

    DELETE FROM MAS_Apartment_Reg
    WHERE Id = @apartmentRegId;
    --
    SET @valid = 1;
    SET @messages = N'Xóa yêu cầu thành công';
    --
    FINAL:
    SELECT @valid valid,
           @messages AS [messages];
END TRY
BEGIN CATCH
    SELECT @messages AS [messages];
    DECLARE @ErrorNum INT,
            @ErrorMsg VARCHAR(200),
            @ErrorProc VARCHAR(50),
            @SessionID INT,
            @AddlInfo VARCHAR(MAX);

    SET @ErrorNum = ERROR_NUMBER();
    SET @ErrorMsg = ERROR_MESSAGE();
    SET @ErrorProc = ERROR_PROCEDURE();

    SET @AddlInfo = '@Userid' --+ @userId;

    EXEC utl_errorlog_set @ErrorNum,
                          @ErrorMsg,
                          @ErrorProc,
                          'MAS_Apartment_Reg',
                          'DEL',
                          @SessionID,
                          @AddlInfo;
END CATCH;