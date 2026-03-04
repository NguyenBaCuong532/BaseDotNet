-- =============================================
-- Author:		<vdx>
-- Description:	<Báo cáo yêu cầu dịch vụ,>
-- =============================================
-- exec sp_Hom_Service_Request null, null, 0, 100, NULL, '2017-01-01', '2021-12-01' 
CREATE PROCEDURE [dbo].[sp_Hom_Service_Request]
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
                    SELECT  a.[requestId]
                            ,d.[projectCd]
                            ,d.[RoomCode]
                            ,c.[fullName]
                            ,c.[phone]
                            ,b.[requestTypeName]
                            ,a.[requestDt] AS requestDate
                            ,a.[comment]
                            ,CASE ISNULL(a.[Status], 0) 
                                WHEN 0 THEN N'Mới yêu cầu' 
                                WHEN 1 THEN N'Đã xem' 
                                WHEN 2 THEN N'Đang xử lý' 
                                ELSE N'Hoàn thành' 
                            END [StatusName]
                            ,ROW_NUMBER() OVER(ORDER BY a.[requestDt] DESC) AS seq
							,ROW_NUMBER() OVER(ORDER BY a.[requestDt]) 	    AS totrows
                        FROM [dbSHome].[dbo].[MAS_Requests] a
                            INNER JOIN [dbSHome].[dbo].MAS_Request_Types b 
                                ON a.[requestTypeId] = b.[requestTypeId]
                            INNER JOIN UserInfo c 
                                ON a.[userId] = c.[userId]	
                            INNER JOIN [MAS_Apartments] d
                                ON a.[apartmentId] = d.[apartmentId]
                        WHERE (@projectCd IS NULL OR d.[projectCd] = @projectCd)
                            AND a.[requestDt] BETWEEN @StartDt AND @EndDt
                            AND (@Filter IS NULL
                                OR c.[Phone] LIKE @q
                                OR c.[fullName] LIKE @q
                                OR d.[RoomCode] LIKE @q
                                OR d.[UserLogin] LIKE @q
                                OR b.[requestTypeName] LIKE @q
                                OR a.[requestKey] LIKE @q
                                OR a.[comment] LIKE @q)
                )
            SELECT  requestId
                    ,projectCd
                    ,RoomCode
                    ,fullName
                    ,phone
                    ,requestTypeName
                    ,requestDate
                    ,StatusName
                    ,comment
                    ,seq, totrows
					,totrows + seq - 1 AS TotRows
				FROM cols
				ORDER BY seq
					OFFSET @Offset 
						ROWS FETCH NEXT @PageSize ROWS ONLY     
    END TRY

begin catch
    declare	@ErrorNum				int = error_number(),
            @ErrorMsg				varchar(200) = 'sp_Hom_Service_Request ' + error_message(),
            @ErrorProc				varchar(50) = error_procedure(),

            @SessionID				int,
            @AddlInfo				varchar(max) = ' - @userId ' + @userId

    exec utl_Insert_ErrorLog @ErrorNum, @ErrorMsg, @ErrorProc, 'sp_Hom_Service_Request', 'GET', @SessionID, @AddlInfo
end catch