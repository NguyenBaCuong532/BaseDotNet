-- exec sp_Hom_Get_Service_Price null, "05"
-- exec sp_Hom_Get_Service_Price null, "03"
-- exec sp_Hom_Get_Service_Price null, null
CREATE procedure [dbo].[sp_Hom_Get_Service_Price]
	@UserId	nvarchar(450) = NULL,
	@ProjectCd	nvarchar(30)
as
begin try		
	
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

        --ve xe thang - ok
        SELECT 
                [ServicePriceId]
            --,[TypeId]
            --,a.[ServiceTypeId]
                ,a.ServiceTypeName
                --,a.[ServiceId]
                ,a.ServiceName
                ,a.[Price]
                ,a.[Price2]
                ,a.Unit
                ,a.Note
                ,a.IsUsed
                --,N'Tính theo số lượng dịch vụ' as CalculateName
                ,[IsFree]
            FROM [PAR_ServicePrice] a  
                    --inner join MAS_ServiceTypes b on a.ServiceTypeId = b.ServiceTypeId  
                    --inner join MAS_Services c on a.ServiceId = c.[ServiceId]
                where  a.[ServiceTypeId] = 2
                            and (IsUsed is null or IsUsed = 1)
                            and (@ProjectCd is null or a.ProjectCd is null or a.ProjectCd = @ProjectCd)
                order by [ServiceTypeId]


        --ve xe ngay-ok
        SELECT [VehicleDailyId]
                --,[ProjectCd]
                ,a.[VehicleTypeId]
                ,b.VehicleTypeName 
                ,note0
                ,[Price0]
                ,note1
                ,[Price1]
                ,note2
                ,Price2
                ,[IsFree]
                ,unit, IsUsed
            FROM [PAR_BlockVehicleDaily] a 
                inner join MAS_VehicleTypes b 
                    on a.VehicleTypeId = b.VehicleTypeId 
                    and (@ProjectCd is null or a.ProjectCd is null or a.ProjectCd = @ProjectCd)
                where a.IsUsed is null or a.IsUsed = 1
                Order by a.[VehicleTypeId]

        --gia dien
        SELECT [LivingPriceId]
                ,[ProjectCd]
                ,[Step] + N': Cho kWh từ ' + convert(nvarchar(10),[NumFrom]) + ' - ' + isnull(convert(nvarchar(10),[NumTo]),N'trở lên') as [Description]
                ,a.LivingTypeId
                ,b.ServiceName 
                ,[NumFrom]
                ,[NumTo]
                ,[Price]
                ,[CalculateType]
                ,[IsFree], IsUsed
				,StartTime
            FROM [PAR_ServiceLivingPrice] a 
                    inner join MAS_Services b 
                        on a.LivingTypeId = b.ServiceId 
                WHERE a.LivingTypeId = 1 
                        and (a.IsUsed is null or a.IsUsed = 1)
                        and (@ProjectCd is null or a.ProjectCd is null or a.ProjectCd = @ProjectCd)
                ORDER BY Pos

        --gia nuoc
        SELECT [LivingPriceId]
                ,[ProjectCd]
                ,[Step] + N': Cho m3 từ ' + convert(nvarchar(10),[NumFrom]) + ' - ' + isnull(convert(nvarchar(10),[NumTo]),N'trở lên') as [Description]
                ,a.LivingTypeId
                ,b.ServiceName 
                ,[NumFrom]
                ,[NumTo]
                ,[Price]
                ,[CalculateType]
                ,[IsFree]
				,StartTime
            FROM [PAR_ServiceLivingPrice] a 
                    inner join MAS_Services b 
                        on a.LivingTypeId = b.ServiceId 
                WHERE a.LivingTypeId = 2 
                        and (a.IsUsed is null or a.IsUsed = 1)
                        and (@ProjectCd is null or a.ProjectCd is null or a.ProjectCd = @ProjectCd)
                ORDER BY Pos

        --dich vu, sua chua
        SELECT RequestTypeId
                ,RequestTypeName
            FROM [MAS_Request_Types] b 
                WHERE exists(SELECT [PriceId] 
                                    FROM [PAR_RequestTypePrice] 
                                        WHERE [RequestTypeId] = b.RequestTypeId)
                        and (b.isReady is null or b.isReady = 1)
                order by [RequestTypeId]

        SELECT a.[PriceId]
                ,a.[RequestTypeId]
                ,a.[ItemName]
                ,a.[IsFree]
                ,a.[Price]
                ,a.[Unit]
                ,a.[Note]
            FROM [PAR_RequestTypePrice] a 
                inner join [MAS_Request_Types] b 
                    on a.RequestTypeId = b.RequestTypeId 
                where a.isUsed is null or a.isUsed = 1	
                order by a.[RequestTypeId],[Post]

end try
begin catch
	declare	@ErrorNum				int,
			@ErrorMsg				varchar(200),
			@ErrorProc				varchar(50),

			@SessionID				int,
			@AddlInfo				varchar(max)

	set @ErrorNum					= error_number()
	set @ErrorMsg					= '[sp_Get_Service_Price] ' + error_message()
	set @ErrorProc					= error_procedure()

	set @AddlInfo					= ' ' 

	exec utl_Insert_ErrorLog @ErrorNum, @ErrorMsg, @ErrorProc, 'ServicePrice', 'GET', @SessionID, @AddlInfo
end catch