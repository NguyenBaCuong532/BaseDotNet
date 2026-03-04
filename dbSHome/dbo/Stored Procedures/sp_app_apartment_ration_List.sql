CREATE PROCEDURE [dbo].[sp_app_apartment_ration_List]
    @userId UNIQUEIDENTIFIER = NULL,
    @acceptLanguage NVARCHAR(50) = 'vi-VN'
AS
BEGIN TRY
    SELECT
        cr.RelationName AS name,
		cr.RelationId AS value
    FROM  MAS_Customer_Relation cr
 
END TRY
BEGIN CATCH
    DECLARE @ErrorNum INT,
            @ErrorMsg VARCHAR(200),
            @ErrorProc VARCHAR(50),
            @SessionID INT,
            @AddlInfo VARCHAR(MAX);

    SET @ErrorNum = ERROR_NUMBER();
    SET @ErrorMsg = ERROR_MESSAGE();
    SET @ErrorProc = ERROR_PROCEDURE();

    EXEC utl_ErrorLog_Set
         @ErrorNum,
         @ErrorMsg,
         @ErrorProc,
         'MAS_ApartmentRations',
         'GET',
         @SessionID,
         @AddlInfo;
END CATCH;