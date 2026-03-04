-- =============================================
-- Author:		<vdx>
-- Description:	<Báo cáo danh sách xe đã bị xóa khỏi hệ thống>
-- =============================================
-- exec sp_Hom_Vehicles_Removed null, "03", null, 50, null, null, null 
-- exec sp_Hom_Vehicles_Removed null, '09', 0, 10, null, '2017-01-01', '2021-12-01' 
CREATE PROCEDURE [dbo].[sp_Hom_Vehicles_Removed]
	@userId				NVARCHAR(450),
	@projectCd 			NVARCHAR(10),
	@Offset				INT	= 0,
	@PageSize			INT	= 10,
	@Filter             NVARCHAR(100),
	@fromDate 			NVARCHAR(50) = null, 
	@toDate 			NVARCHAR(50) = null

AS
	BEGIN TRY
		SET	@Offset 	= ISNULL(@Offset, 0)
		SET	@PageSize	= ISNULL(@PageSize, 10)
		IF	@Offset		< 0 SET @Offset	  = 0
		IF	@PageSize	< 1 SET @PageSize = 10

		DECLARE @code      	INT = 126
		DECLARE @StartDt    DATETIME = CONVERT(DATETIME, ISNULL(@FromDate,'2000-01-01'), @code),
				@EndDt      DATETIME = CONVERT(DATETIME, ISNULL(@ToDate,'2050-01-01'), @code),
				@q          NVARCHAR(100) = '%' + ISNULL(@filter, '') + '%'

		-- SET NOCOUNT ON added to prevent extra result sets from
		-- interfering with SELECT statements.
		SET NOCOUNT ON;

            ;WITH cols
				AS
				(
                    SELECT 
                            a.[CardVehicleId]
                            ,d.[RoomCode]
                            ,cc.[phone]
                            ,cc.[FullName]
                            ,a.[VehicleNo]
                            ,a.[VehicleName]
                            ,g.[VehicleTypeName]
                            ,a.[EndTime]
                            ,c.[phone]    AS phoneExer  
                            ,a.[saveDate] AS removedDate
                            ,c.[FullName] AS deleteBy
                            ,h.[Reason]
                            ,ROW_NUMBER() OVER(ORDER BY a.[saveDate] DESC) AS seq
							,ROW_NUMBER() OVER(ORDER BY a.[saveDate]) 	   AS totrows
                        FROM [dbSHome].[dbo].[MAS_CardVehicle_H] a
                            INNER JOIN [MAS_Apartments] d
                                ON a.[apartmentId] = d.[apartmentId]
                            LEFT JOIN [MAS_CardVehicle] h
                                ON a.[CardVehicleId] = h.[CardVehicleId]
                            INNER JOIN MAS_VehicleTypes g 
                                ON a.[VehicleTypeId] = g.[VehicleTypeId]
                            INNER JOIN [UserInfo] u
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
                            AND a.[saveDate] BETWEEN  @StartDt AND @EndDt 
							AND (@projectCd IS NULL OR d.[projectCd] = @projectCd)
							AND (@Filter IS NULL
									OR d.[RoomCode] LIKE @q
                                    OR cc.[Phone] LIKE @q
                                    OR cc.[FullName] LIKE @q
                                    OR a.[VehicleNo] LIKE @q
                                    OR a.[VehicleName] LIKE @q
                                    OR g.[VehicleTypeName] LIKE @q
                                    OR c.[fullName] LIKE @q
                                    OR c.[phone] LIKE @q
                                    OR h.[reason] LIKE @q)
				)        
            SELECT
                    CardVehicleId
                    ,RoomCode
                    ,FullName
                    ,phone
                    ,VehicleNo
                    ,VehicleName
                    ,VehicleTypeName
                    ,EndTime
                    ,removedDate
                    ,deleteBy  
                    ,phoneExer
                    ,Reason
                    ,seq, totrows
					,totrows + seq - 1 AS TotRows
				FROM cols
				ORDER BY seq
					OFFSET @Offset 
						ROWS FETCH NEXT @PageSize ROWS ONLY 
			
	END try

	begin catch
		declare	@ErrorNum				int = error_number(),
				@ErrorMsg				varchar(200) = 'sp_Hom_Vehicles_Removed ' + error_message(),
				@ErrorProc				varchar(50) = error_procedure(),

				@SessionID				int,
				@AddlInfo				varchar(max) = ' - @userId ' + @userId
		exec utl_Insert_ErrorLog @ErrorNum, @ErrorMsg, @ErrorProc, 'sp_Hom_Vehicles_Removed', 'GET', @SessionID, @AddlInfo
	end catch