-- =============================================
-- Author:		<vdx>
-- Description:	<số lượng cư dân về nhận nhà,>
-- =============================================
CREATE PROCEDURE [dbo].[sp_Hom_Apartment_Received]
	@userId				NVARCHAR(450),
	@projectCd 			NVARCHAR(10),
	@Offset				INT	= 0,
	@PageSize			INT	= 10,
	@Filter             NVARCHAR(100),
	@fromDate 			NVARCHAR(50) = NULL, 
	@toDate 			NVARCHAR(50) = NULL

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
							d.[ApartmentId]
							,d.[RoomCode]
							,d.[WaterwayArea] AS carpetArea
							,c.[fullName]
							,c.[phone]
							,CASE c.IsSex
								WHEN 0 THEN N'Nữ' 
								WHEN 1 THEN N'Nam' 
								ELSE N'Không rõ' 
							END gender
                            ,c.[birthday]
							,c.CountryCd AS nation
							,d.[ReceiveDt] AS receivedDate
                            ,(SELECT COUNT(*) 
                                    FROM MAS_CardVehicle a 
                                    WHERE a.[ApartmentId] = d.[ApartmentId])
					        AS vehicle
							,d.[FeeStart]
							,ROW_NUMBER() OVER(ORDER BY d.[ApartmentId] DESC)  AS seq
							,ROW_NUMBER() OVER(ORDER BY d.[ApartmentId]) 	   AS totrows
						FROM [MAS_Apartments] d
							INNER JOIN UserInfo m 
								ON d.[UserLogin] = m.loginName
							LEFT JOIN MAS_Customers c 
								ON m.[CustId] = c.[CustId]
                        WHERE  d.[IsReceived] = 1
							AND (@projectCd IS NULL OR d.[projectCd] = @projectCd)
							AND d.[ReceiveDt] IS NOT NULL
                            AND d.[ReceiveDt] BETWEEN @StartDt AND @EndDt
							AND (@Filter IS NULL
								OR c.[fullName] LIKE @q
								OR c.[Birthday] LIKE @q
								OR d.[RoomCode] LIKE @q
								OR m.[Phone] LIKE @q
								OR d.[UserLogin] LIKE @q
								OR c.CountryCd LIKE @q
								)        
                )
                SELECT  
                        ApartmentId
                        ,RoomCode
                        ,carpetArea
                        ,fullName
                        ,phone
                        ,gender
                        ,birthday
                        ,nation
                        ,receivedDate
                        ,FeeStart
                        ,vehicle
                        ,seq, totrows
                        ,totrows + seq - 1 AS TotRows
                    FROM cols
                    ORDER BY seq
                        OFFSET @Offset 
                            ROWS FETCH NEXT @PageSize ROWS ONLY 
		
	END TRY

	begin catch
		declare	@ErrorNum				int = error_number(),
				@ErrorMsg				varchar(200) = 'sp_Hom_Apartment_Received ' + error_message(),
				@ErrorProc				varchar(50) = error_procedure(),

				@SessionID				int,
				@AddlInfo				varchar(max) = ' - @userId ' + @userId

		exec utl_Insert_ErrorLog @ErrorNum, @ErrorMsg, @ErrorProc, 'sp_Hom_Apartment_Received', 'GET', @SessionID, @AddlInfo
	end catch