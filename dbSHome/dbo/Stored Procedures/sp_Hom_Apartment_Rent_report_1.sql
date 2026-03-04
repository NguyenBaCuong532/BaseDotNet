-- =============================================
-- Author:		<vdx>
-- Description:	<Báo cáo, thống kê số lượng, chi tiết thông tin khách thuê nhà theo dự án,>
-- =============================================
-- exec sp_Hom_Apartment_Rent null, null, 0, 850, null, null, null 
-- exec sp_Hom_Apartment_Rent null, '01', 0, 850, null, null, null 
-- exec sp_Hom_Apartment_Rent null, '01', 0, 500, null, null, null 
-- exec sp_Hom_Apartment_Rent null, '03', 0, 10, null, null, null 
-- exec sp_Hom_Apartment_Rent null, "03", 0, 1000000, null,'2018-01-01', '2021-12-01' 
CREATE PROCEDURE [dbo].[sp_Hom_Apartment_Rent_report]
	@userId				NVARCHAR(450) = NULL,
	@projectCd 			NVARCHAR(10)  = NULL,
	
	@fromDate 			datetime, 
	@toDate 			datetime

AS
	BEGIN TRY
		
                    SELECT 
							d.[ApartmentId]
							,d.[RoomCode]
							,c.[fullName]
							,c.[phone]
							,CASE c.[issex]
								WHEN 0 THEN N'Nữ' 
								WHEN 1 THEN N'Nam' 
								ELSE N'Không rõ' 
							END gender
                            ,c.[birthday]
							,c.CountryCd AS nation
							,d.[WaterwayArea] AS carpetArea
							,d.[ReceiveDt] AS receivedDate
							,d.[FeeStart]
                           	,(SELECT COUNT(*) 
                                    FROM MAS_CardVehicle a 
                                    WHERE a.[ApartmentId] = d.[ApartmentId])
					        AS vehicle
							,1 xcount
							,ROW_NUMBER() OVER(ORDER BY d.[ApartmentId] DESC)  AS seq
							,ROW_NUMBER() OVER(ORDER BY d.[ApartmentId]) 	   AS totrows
                        FROM [MAS_Apartments] d
							INNER JOIN UserInfo m 
								ON d.[UserLogin] = m.loginName
							LEFT JOIN MAS_Customers c 
								ON m.[CustId] = c.[CustId]
                        WHERE  d.[IsRent] = 1
							AND (@projectCd IS NULL OR d.[projectCd] = @projectCd)
                            AND d.[ReceiveDt] BETWEEN @fromDate AND @toDate
						 

						select projectCd, projectName from MAS_Projects where ProjectCd =  @ProjectCd
            
	END TRY

	begin catch
		declare	@ErrorNum				int = error_number(),
				@ErrorMsg				varchar(200) = 'sp_Hom_Apartment_Rent_report ' + error_message(),
				@ErrorProc				varchar(50) = error_procedure(),

				@SessionID				int,
				@AddlInfo				varchar(max) = ' - @userId ' + @userId

		exec utl_Insert_ErrorLog @ErrorNum, @ErrorMsg, @ErrorProc, 'sp_Hom_Apartment_Rent_report', 'GET', @SessionID, @AddlInfo
	end catch