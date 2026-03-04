-- =============================================
-- Author:		<vdx>
-- Description:	<Báo cáo danh sách xe cư dân được thêm mới trong tháng>
-- =============================================
-- exec sp_Hom_Vehicles_Added null, null, null, 50, null, null, null 
-- exec sp_Hom_Vehicles_Added null, null, null, 500, 'xe máy', null, null 
-- exec sp_Hom_Vehicles_Added null, "03", 'máy', '2019-01-01', '2021-12-01' 
CREATE PROCEDURE [dbo].[sp_Hom_Vehicles_Added_report]
	@userId				NVARCHAR(450),
	@projectCd 			NVARCHAR(10),
 --   @Offset				INT	= 0,
	--@PageSize			INT	= 10,
	--@Filter             NVARCHAR(100),
	@fromDate 			datetime, 
	@toDate 			datetime

AS
	BEGIN TRY
		--SET	@Offset 	= ISNULL(@Offset, 0)
		--SET	@PageSize	= ISNULL(@PageSize, 10)
		--IF	@Offset		< 0 SET @Offset	  = 0
		--IF	@PageSize	< 1 SET @PageSize = 10

		--DECLARE @code      	INT = 126
		--DECLARE @StartDt    DATETIME = CONVERT(DATETIME, ISNULL(@FromDate,'2000-01-01'), @code),
		--		@EndDt      DATETIME = CONVERT(DATETIME, ISNULL(@ToDate,'2050-01-01'), @code),
		--		@q          NVARCHAR(100) = '%' + ISNULL(@filter, '') + '%'

		---- SET NOCOUNT ON added to prevent extra result sets from
		---- interfering with SELECT statements.
		--SET NOCOUNT ON;
  --          ;WITH cols
		--		AS
		--		(
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
                            ,h.[SaveDate]
                            ,h.[Reason]
       --                     ,ROW_NUMBER() OVER(ORDER BY h.[saveDate] DESC) AS seq
							--,ROW_NUMBER() OVER(ORDER BY h.[saveDate]) 	   AS totrows
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
                            AND h.[Status] = 1
                            AND a.[StartTime] IS NOT NULL
                            AND a.[StartTime] BETWEEN @fromDate AND @toDate 
                            --AND (@Filter IS NULL
                            --        OR d.[RoomCode] LIKE @q
                            --        OR cc.[Phone] LIKE @q
                            --        OR cc.[FullName] LIKE @q
                            --        OR a.[VehicleNo] LIKE @q
                            --        OR a.[VehicleName] LIKE @q
                            --        OR g.[VehicleTypeName] LIKE @q
                            --        OR c.[fullName] LIKE @q
                            --        OR c.[phone] LIKE @q
                            --        OR h.[reason] LIKE @q)
    --            )
    --         SELECT
    --                CardVehicleId
    --                ,RoomCode
    --                ,FullName
    --                ,phone
    --                ,VehicleNo
    --                ,VehicleName
    --                ,VehicleTypeName
    --                ,startTime
    --                ,EndTime
    --                ,addedBy  
    --                ,phoneExer
    --                ,SaveDate
    --                ,Reason
    --                ,seq, totrows
				--	,totrows + seq - 1 AS TotRows
				--FROM cols
				--ORDER BY seq
				--	OFFSET @Offset 
				--		ROWS FETCH NEXT @PageSize ROWS ONLY 
	END TRY

	begin catch
		declare	@ErrorNum				int = error_number(),
				@ErrorMsg				varchar(200) = 'sp_Hom_Vehicles_Added_report ' + error_message(),
				@ErrorProc				varchar(50) = error_procedure(),

				@SessionID				int,
				@AddlInfo				varchar(max) = ' - @userId ' + @userId

		exec utl_Insert_ErrorLog @ErrorNum, @ErrorMsg, @ErrorProc, 'sp_Hom_Vehicles_Added_report', 'GET', @SessionID, @AddlInfo
	end catch