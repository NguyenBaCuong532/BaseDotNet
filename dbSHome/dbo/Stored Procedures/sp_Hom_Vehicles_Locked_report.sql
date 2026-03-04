-- =============================================
-- Author:		<vdx>
-- Description:	<Báo cáo danh sách xe cư dân bị khóa trong tháng và người thực hiện khóa xe,>
-- =============================================
-- exec sp_Hom_Vehicles_Locked null, null, null, 50, null, null, null 
-- exec sp_Hom_Vehicles_Locked null, null, null, 500, 'xe máy', null, null 
-- exec sp_Hom_Vehicles_Locked null, "03", '2019-01-01', '2021-12-01' 
CREATE PROCEDURE [dbo].[sp_Hom_Vehicles_Locked_report]
	@userId				NVARCHAR(450),
	@projectCd 			NVARCHAR(10),
	
	@fromDate 			Datetime, 
	@toDate 			Datetime

AS
	BEGIN TRY
		
                    SELECT
                            a.[CardVehicleId]
                            ,d.[RoomCode]
                            ,cc.[phone]
                            ,cc.[FullName]
                            ,a.[VehicleNo]
                            ,a.[VehicleName]
                            ,g.[VehicleTypeName]
                            ,a.[EndTime]
                            ,c.[phone]      AS phoneExer
                            ,a.[locked_dt]  AS lockedDate
                            ,c.[FullName]   AS LockedBy
                            ,h.[Reason]
							,1 xcount
                        FROM [dbSHome].[dbo].[MAS_CardVehicle] a
                            INNER JOIN [MAS_Apartments] d
                                ON a.[apartmentId] = d.[apartmentId]
                            INNER JOIN [MAS_CardVehicle_H] h
                                ON a.[CardVehicleId] = h.[CardVehicleId]
                            INNER JOIN MAS_VehicleTypes g 
                                ON a.[VehicleTypeId] = g.[VehicleTypeId]
                            -- locker    
                            INNER JOIN [UserInfo] u
                                ON h.[SaveId] = u.[UserId]
                            INNER JOIN MAS_Customers c
                                ON u.[CustId] = c.[CustId]
                                --where a.locked_dt is not null    
                            INNER JOIN UserInfo m 
                                ON d.[UserLogin] = m.loginName
                            LEFT JOIN MAS_Customers cc 
                                ON m.[CustId] = cc.[CustId]    
                        WHERE (@projectCd IS NULL OR d.[projectCd] = @projectCd)
                            AND a.[locked_dt] IS NOT NULL
                            AND a.[locked_dt] BETWEEN @fromDate AND @toDate 
                          

select projectCd, projectName from mas_Projects where ProjectCd =  @projectCd


	END TRY

	begin catch
		declare	@ErrorNum				int = error_number(),
				@ErrorMsg				varchar(200) = 'sp_Hom_Vehicles_Locked_report ' + error_message(),
				@ErrorProc				varchar(50) = error_procedure(),

				@SessionID				int,
				@AddlInfo				varchar(max) = ' - @userId ' + @userId

		exec utl_Insert_ErrorLog @ErrorNum, @ErrorMsg, @ErrorProc, 'sp_Hom_Vehicles_Locked_report', 'GET', @SessionID, @AddlInfo
	end catch