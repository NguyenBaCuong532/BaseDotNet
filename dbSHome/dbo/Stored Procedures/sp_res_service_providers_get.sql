
CREATE PROCEDURE [dbo].[sp_res_service_providers_get]
    @userId NVARCHAR(200),
    @ContractTypeId INT
AS
BEGIN TRY
	IF @ContractTypeId IS NULL
	SET @ContractTypeId  = -1

    SELECT a.[ProviderCd] AS value,
           --a.[ProviderShort],
           a.[ProviderName] AS name
    --a.[Address],
    --a.[LogoUrl],
    --a.[ContactName],
    --a.[Phone],
    --a.[Email],
    --b.ContractTypeId
    FROM [dbo].[MAS_ServiceProvider] a
        INNER JOIN MAS_ProviderContractType b
            ON a.ProviderCd = b.ProviderCd
    WHERE  b.ContractTypeId = @ContractTypeId;

END TRY
BEGIN CATCH
    DECLARE @ErrorNum INT,
            @ErrorMsg VARCHAR(200),
            @ErrorProc VARCHAR(50),
            @SessionID INT,
            @AddlInfo VARCHAR(MAX);

    SET @ErrorNum = ERROR_NUMBER();
    SET @ErrorMsg = 'sp_res_service_providers_get' + ERROR_MESSAGE();
    SET @ErrorProc = ERROR_PROCEDURE();

    SET @AddlInfo = ' ';

    EXEC utl_Insert_ErrorLog @ErrorNum,
                             @ErrorMsg,
                             @ErrorProc,
                             'ServiceProvider',
                             'GET',
                             @SessionID,
                             @AddlInfo;
END CATCH;