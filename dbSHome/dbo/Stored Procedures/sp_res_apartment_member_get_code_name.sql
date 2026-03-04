-- =============================================
-- Author:      ThanhMT
-- Create date: 10/02/2026
-- Description: Lấy danh sách cho Dropdown Control
-- =============================================
CREATE PROCEDURE [dbo].[sp_res_apartment_member_get_code_name]
    @UserId uniqueidentifier = NULL,
    @project_code VARCHAR(50) = NULL,
    @ApartmentId INT,
    @CustId uniqueidentifier = NULL,
    @Filter NVARCHAR(50) = NULL,
    @AcceptLanguage VARCHAR(20) = 'vi-VN'
AS
BEGIN TRY
    SET @Filter = ISNULL(@Filter, '');
	
    SELECT
        [value] = CONVERT(NVARCHAR(50), a.CustId),
        [name] = a.FullName
    FROM
        MAS_Customers a WITH (NOLOCK)
        JOIN MAS_Apartment_Member b WITH (NOLOCK) ON a.CustId = b.CustId
    WHERE
        a.ApartmentId = @ApartmentId
        AND ((@CustId IS NOT NULL AND a.CustId = @CustId)
              OR (@CustId IS NULL AND(a.FullName LIKE N'%' + @Filter + '%' OR a.Phone LIKE N'%' + @Filter + '%'))
            )
	
END TRY
BEGIN CATCH
    DECLARE @ErrorNum INT, @ErrorMsg VARCHAR(200), @ErrorProc VARCHAR(50), @SessionID INT, @AddlInfo VARCHAR(MAX)
    SET @ErrorNum = error_number()
    SET @ErrorMsg = 'Line: ' + CONVERT(nvarchar(300), error_line()) + ' Msg: ' + error_message();
    SET @ErrorProc = error_procedure()
    SET @AddlInfo = 'UserId ' + CONVERT(NVARCHAR(50), @UserId)
    EXEC utl_ErrorLog_Set @ErrorNum, @ErrorMsg, @ErrorProc, '', '', @SessionID, @AddlInfo 
END CATCH