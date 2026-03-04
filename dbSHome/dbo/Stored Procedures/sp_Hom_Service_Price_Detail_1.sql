
CREATE procedure [dbo].[sp_Hom_Service_Price_Detail]
	@UserID				nvarchar(450),
	@servicePriceId		int = 0

as
			
		SELECT a.[ServicePriceId]
				,a.ProjectCd
			  ,[TypeId]
			  ,a.[ServiceTypeId]
			  ,b.ServiceTypeName
			  ,[ServiceId]
			  ,c.BuildingName as ServiceName
			  ,a.[Price], Price2
			  ,[CalculateType], Unit
			  --,N'Tính theo diện tích' as CalculateName
			  ,[IsFree], IsUsed, Note
		  FROM [PAR_ServicePrice] a  
				inner join MAS_ServiceTypes b on a.ServiceTypeId = b.ServiceTypeId  
				inner join MAS_Buildings c on a.ServiceId = c.Id 
		  where @servicePriceId = 0 or ServicePriceId = @servicePriceId