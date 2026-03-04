CREATE   PROCEDURE [dbo].[sp_res_partner_list]
    @UserId NVARCHAR(50) = NULL,
    @projectCd VARCHAR(50)
AS
BEGIN TRY
    SELECT
        [value] = a.partner_id,
        [name]  = a.partner_name
        -- Nếu bạn muốn show thêm loại:
        --, partner_type_id = a.partner_type_id
        --, partner_type_name = t.type_name
    FROM MAS_CardPartner a
    LEFT JOIN MAS_PartnerType t ON a.partner_type_id = t.partner_type_id
    WHERE @projectCd IS NULL OR a.projectCd = @projectCd;
END TRY
BEGIN CATCH
    DECLARE @ErrorNum INT,
            @ErrorMsg VARCHAR(200),
            @ErrorProc VARCHAR(50),
            @SessionID INT,
            @AddlInfo VARCHAR(MAX);

    SET @ErrorNum = ERROR_NUMBER();
    SET @ErrorMsg = 'sp_res_partner_list ' + ERROR_MESSAGE();
    SET @ErrorProc = ERROR_PROCEDURE();
    SET @AddlInfo = ' ';

    EXEC utl_Insert_ErrorLog @ErrorNum, @ErrorMsg, @ErrorProc, 'MAS_CardPartner', 'GET', @SessionID, @AddlInfo;
END CATCH