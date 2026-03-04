CREATE PROCEDURE [dbo].[sp_res_card_type_list] @userId NVARCHAR(50) = NULL
AS
BEGIN TRY
    SELECT [value] = CardTypeId
        , CASE 
				WHEN LTRIM(RTRIM(CardTypeName)) = N'Thẻ S-Service' THEN N'Thẻ nội bộ'
				WHEN LTRIM(RTRIM(CardTypeName)) = N'Thẻ khác' THEN N'Thẻ khách'
				WHEN LTRIM(RTRIM(CardTypeName)) = N'Thẻ gửi xe' THEN N'Thẻ lượt'
				--WHEN LTRIM(RTRIM(CardTypeName)) = N'Thẻ khách hàng thân thiết' THEN N'Thông tin ẩn'
				ELSE CardTypeName 
			END AS name
    FROM MAS_CardTypes
	WHERE LTRIM(RTRIM(CardTypeName)) <> N'Thẻ khách hàng thân thiết';
END TRY

BEGIN CATCH
    DECLARE @ErrorNum INT
        , @ErrorMsg VARCHAR(200)
        , @ErrorProc VARCHAR(50)
        , @SessionID INT
        , @AddlInfo VARCHAR(MAX);

    SET @ErrorNum = ERROR_NUMBER();
    SET @ErrorMsg = 'sp_res_card_type_list' + ERROR_MESSAGE();
    SET @ErrorProc = ERROR_PROCEDURE();
    SET @AddlInfo = '';

    EXEC utl_ErrorLog_Set @ErrorNum
        , @ErrorMsg
        , @ErrorProc
        , 'MAS_CardTypes'
        , 'GET'
        , @SessionID
        , @AddlInfo;
END CATCH;