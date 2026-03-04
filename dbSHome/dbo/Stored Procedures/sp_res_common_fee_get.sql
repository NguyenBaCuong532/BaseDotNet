CREATE PROCEDURE [dbo].[sp_res_common_fee_get]
    @ProjectCd NVARCHAR(10) = NULL,
	@UserId				UNIQUEIDENTIFIER = NULL,
	@acceptLanguage nvarchar(50) = N'vi-VN',

	@offset INT = 0,
    @pageSize INT = 10,
    @Total INT = 0 OUT,
	@TotalFiltered INT = 0 OUT,
	@filter NVARCHAR(30) = NULL,
	@gridWidth INT = 0,

	
	@GridKey		nvarchar(100) out

AS
BEGIN 

	SET @offset = ISNULL(@offset, 0);
    SET @pageSize = ISNULL(@pageSize, 10);
	SET @filter = isnull(@filter, '');
    SET @Total = ISNULL(@Total, 0);
	set @GridKey				= 'view_common_price'
	


	SELECT @Total = COUNT(a.[ServicePriceId])
	  FROM [PAR_ServicePrice] a  
                    inner join MAS_ServiceTypes b 
                        on a.ServiceTypeId = b.ServiceTypeId  
                    inner join MAS_Buildings c 
                        on a.ServiceId = c.Id 
                where [TypeId] = 1 
                        and (IsUsed is null or IsUsed = 1)
                        and (@ProjectCd is null or a.ProjectCd is null or a.ProjectCd = @ProjectCd)

    SET @TotalFiltered = @Total;

	    IF @PageSize < 0
    BEGIN
        SET @PageSize = 10;
    END;

		IF @Offset = 0
    BEGIN
        SELECT *
        FROM [dbo].fn_config_list_gets_lang(@GridKey, @gridWidth, @acceptLanguage)
        ORDER BY [ordinal];

    END;

	--data
        SELECT a.[ServicePriceId]
                ,a.projectCd
                --,[TypeId]
                --,a.[ServiceTypeId]
                ,b.ServiceTypeName
                --,[ServiceId]
                ,c.BuildingName as ServiceName
                ,a.[Price]
                ,a.Unit, a.IsUsed, a.Note
                --,[CalculateType]
                --,N'Tính theo diện tích' as CalculateName
                ,[IsFree]
            FROM [PAR_ServicePrice] a  
                    inner join MAS_ServiceTypes b 
                        on a.ServiceTypeId = b.ServiceTypeId  
                    inner join MAS_Buildings c 
                        on a.ServiceId = c.Id   
                where [TypeId] = 1 
                        and (IsUsed is null or IsUsed = 1)
                        and (@ProjectCd is null or a.ProjectCd is null or a.ProjectCd = @ProjectCd)
END