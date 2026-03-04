-- =============================================
-- Author:		<vdx>
-- Description:	<Báo cáo danh sách xe cư dân được thêm mới trong tháng>
-- =============================================
-- exec sp_Hom_Vehicles_Added null, null, null, 50, null, null, null 
-- exec sp_Hom_Vehicles_Added null, null, null, 500, 'xe máy', null, null 
-- exec sp_Hom_Vehicles_Added null, "03", 'máy', '2019-01-01', '2021-12-01' 
CREATE PROCEDURE [dbo].[sp_Hom_Report_Vehicles_Added]
	@userId				NVARCHAR(450),
	@projectCd 			NVARCHAR(10),
	@fromDate 			datetime, 
	@toDate 			datetime

AS
	BEGIN TRY
		--  data 1------------------
        SELECT
                a.[CardVehicleId]
                ,d.[RoomCode]
                ,cc.[phone]
                ,cc.[FullName]
                ,a.[VehicleNo]
                ,a.[VehicleName]
                ,g.[VehicleTypeName]
                ,a.[StartTime]
                ,a.[EndTime]
                ,c.[phone]      AS phoneExer
                ,c.[FullName]   AS AddedBy
                ,format(h.[SaveDate],'dd/MM/yyyy') [SaveDate]
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
                INNER JOIN UserInfo u
                    ON h.[SaveId] = u.[UserId]
                INNER JOIN MAS_Customers c
                    ON u.[CustId] = c.[CustId]
                    --where a.locked_dt is not null    

                INNER JOIN UserInfo m 
                    ON d.[UserLogin] = m.loginName
                LEFT JOIN MAS_Customers cc 
                    ON m.[CustId] = cc.[CustId]    
            WHERE (@projectCd IS NULL OR d.[projectCd] = @projectCd)
                AND h.[Status] = 1
                AND a.[StartTime] IS NOT NULL
                AND a.[StartTime] BETWEEN @fromDate AND @toDate 
			order by h.[SaveDate] desc

	--  data 2------------------
		select projectCd, projectName from MAS_Projects where ProjectCd =  @projectCd

	END TRY

	begin catch
		declare	@ErrorNum				int = error_number(),
				@ErrorMsg				varchar(200) = 'sp_Hom_Report_Vehicles_Added ' + error_message(),
				@ErrorProc				varchar(50) = error_procedure(),

				@SessionID				int,
				@AddlInfo				varchar(max) = ' - @userId ' + @userId

		exec utl_Insert_ErrorLog @ErrorNum, @ErrorMsg, @ErrorProc, 'sp_Hom_Report_Vehicles_Added', 'GET', @SessionID, @AddlInfo
	end catch