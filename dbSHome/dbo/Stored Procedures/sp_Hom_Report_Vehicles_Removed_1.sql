-- =============================================
-- Author:		<vdx>
-- Description:	<Báo cáo danh sách xe đã bị xóa khỏi hệ thống>
-- =============================================
-- exec sp_Hom_Vehicles_Removed null, "03", null, 50, null, null, null 
-- exec sp_Hom_Vehicles_Removed null, '09', 0, 10, null, '2017-01-01', '2021-12-01' 
CREATE PROCEDURE [dbo].[sp_Hom_Report_Vehicles_Removed]
	@userId				NVARCHAR(450),
	@projectCd 			NVARCHAR(10),
	--@Offset				INT	= 0,
	--@PageSize			INT	= 10,
	--@Filter             NVARCHAR(100),
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
					,format(a.[EndTime],'dd/MM/yyyy') [EndTime]
					,c.[phone]    AS phoneExer  
					,format(a.[SaveDate],'dd/MM/yyyy') AS removedDate
					,c.[FullName] AS deleteBy
					,h.[Reason]
					,1 xcount
				FROM [dbSHome].[dbo].[MAS_CardVehicle_H] a
					INNER JOIN [MAS_Apartments] d
						ON a.[apartmentId] = d.[apartmentId]
					LEFT JOIN [MAS_CardVehicle] h
						ON a.[CardVehicleId] = h.[CardVehicleId]
					INNER JOIN MAS_VehicleTypes g 
						ON a.[VehicleTypeId] = g.[VehicleTypeId]
					INNER JOIN UserInfo u
						ON a.[SaveId] = u.[UserId]
					INNER JOIN MAS_Customers c
						ON u.[CustId] = c.[CustId]

					INNER JOIN UserInfo m 
						ON d.[UserLogin] = m.loginName
					LEFT JOIN MAS_Customers cc 
						ON m.[CustId] = cc.[CustId]
				WHERE h.[CardVehicleId] IS NULL
					AND a.[Status] = 3
					AND a.[saveDate] IS NOT NULL
					AND a.[saveDate] BETWEEN  @fromDate AND @toDate 
					AND (@projectCd IS NULL OR d.[projectCd] = @projectCd)
				order by a.[SaveDate] desc

		--  data 2------------------
			select projectCd, projectName from MAS_Projects where ProjectCd =  @projectCd
			
	END try

	begin catch
		declare	@ErrorNum				int = error_number(),
				@ErrorMsg				varchar(200) = 'sp_Hom_Report_Vehicles_Removed ' + error_message(),
				@ErrorProc				varchar(50) = error_procedure(),

				@SessionID				int,
				@AddlInfo				varchar(max) = ' - @userId ' + @userId
		exec utl_Insert_ErrorLog @ErrorNum, @ErrorMsg, @ErrorProc, 'sp_Hom_Report_Vehicles_Removed', 'GET', @SessionID, @AddlInfo
	end catch