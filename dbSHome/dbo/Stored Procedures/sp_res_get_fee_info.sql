
CREATE PROCEDURE [dbo].[sp_res_get_fee_info]
	@UserID				UNIQUEIDENTIFIER,
	@ServicePriceId		int = 0,
	@acceptLanguage		NVARCHAR(50) = N'vi-VN'
AS 
	BEGIN 
		
		SELECT  @ServicePriceId AS [servicePriceId],[tableKey] = 'MAS_Fee_Service';

		SELECT 1 [group_cd],N'Thông tin phí' [group_name];
		

		if @ServicePriceId = 0 or @ServicePriceId is NULL
			BEGIN
				SELECT a.[id],
					   a.[table_name],
					   a.[field_name],
					   a.[view_type],
					   a.[data_type],
					   a.[ordinal],
					   a.[columnLabel],
					   a.group_cd,
					   a.[columnClass],
					   a.[columnType],
					   a.[columnObject],
					   a.[isSpecial],
					   a.[isRequire],
					   a.[isDisable],
					   a.[isVisiable],
					   --,[IsEmpty]
					   ISNULL(a.columnTooltip, a.[columnLabel]) AS columnTooltip
					   , a.[columnDisplay]
					   , a.[isIgnore]
				FROM fn_config_form_gets('MAS_Fee_Service', @acceptLanguage) a
				ORDER BY a.ordinal;
			END
		ELSE
		 BEGIN
   

			SELECT s.[id],
           s.[table_name],
           s.[field_name],
           s.[view_type],
           s.[data_type],
           s.[ordinal],
           s.[columnLabel],
           s.[group_cd],
           ISNULL(
				   CASE s.[field_name]
					WHEN 'servicePriceId' THEN
                             CONVERT(NVARCHAR(500), sp.ServicePriceId)
					   WHEN 'projectCd' THEN CONVERT(NVARCHAR(100), sp.ProjectCd)
					   WHEN 'typeId' THEN CONVERT(NVARCHAR(100), sp.TypeId)
					   WHEN 'serviceTypeId' THEN CONVERT(NVARCHAR(100), sp.ServiceTypeId)
					   WHEN 'serviceId' THEN CONVERT(NVARCHAR(100), sp.ServiceId)
					   WHEN 'calculateType' THEN CONVERT(NVARCHAR(100), sp.CalculateType)
					   WHEN 'unit' THEN CONVERT(NVARCHAR(100), sp.Unit)
					   WHEN 'price' THEN CONVERT(NVARCHAR(100), sp.Price)
					   WHEN 'price2' THEN CONVERT(NVARCHAR(100), sp.Price2)
					   WHEN 'isUsed' THEN CONVERT(NVARCHAR(100), sp.IsUsed)
					   WHEN 'isFree' THEN CONVERT(NVARCHAR(100), sp.IsFree)
					   WHEN 'note' THEN sp.Note -- đã là nvarchar rồi
				   END,
				   s.[columnDefault]
				) AS columnValue,
           s.[columnClass],
           s.[columnType],
           s.[columnObject],
           s.[isSpecial],
           s.[isRequire],
           s.[isDisable],
           s.[isVisiable],
           NULL AS [IsEmpty],
           ISNULL(s.columnTooltip, s.[columnLabel]) AS columnTooltip
			   , s.[columnDisplay]
			   , s.[isIgnore]
			 FROM fn_config_form_gets('MAS_Fee_Service', @acceptLanguage) s
					JOIN dbo.PAR_ServicePrice sp ON sp.ServicePriceId = @ServicePriceId
					join MAS_Buildings c on sp.ServiceId = c.Id 
				ORDER BY s.ordinal;		
		END

    END