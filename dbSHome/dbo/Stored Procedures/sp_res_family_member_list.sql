CREATE PROCEDURE [dbo].[sp_res_family_member_list]
    @UserId UNIQUEIDENTIFIER = NULL,
    @AcceptLanguage VARCHAR(20) = 'vi-VN',
	@ApartmentId INT
AS
BEGIN TRY

    SET @ApartmentId = ISNULL(@ApartmentId,0)
    
    -- Data
    SELECT a.CustId AS value
		  ,a.[FullName] AS name
		  
	  FROM [MAS_Customers] a 
		join MAS_Apartment_Member b on a.CustId = b.CustId 
	  WHERE b.ApartmentId = @ApartmentId 
		
END TRY
BEGIN CATCH
    DECLARE @ErrorNum INT,
            @ErrorMsg VARCHAR(200),
            @ErrorProc VARCHAR(50),
            @SessionID INT,
            @AddlInfo VARCHAR(MAX);

    SET @ErrorNum = ERROR_NUMBER();
    SET @ErrorMsg = 'sp_res_family_member_list' + ERROR_MESSAGE();
    SET @ErrorProc = ERROR_PROCEDURE();
    SET @AddlInfo = '';

    EXEC utl_ErrorLog_Set @ErrorNum,
                          @ErrorMsg,
                          @ErrorProc,
                          'FamilyMember',
                          'GET',
                          @SessionID,
                          @AddlInfo;
END CATCH;