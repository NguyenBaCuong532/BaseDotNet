-- =============================================
-- Author:		<vdx>
-- Description:	<Báo cáo yêu cầu dịch vụ,>
-- =============================================
-- exec sp_Hom_Service_Request null, null, 0, 100, NULL, '2017-01-01', '2021-12-01' 
CREATE PROCEDURE [dbo].[sp_Hom_Service_Request_report]
	@userId				NVARCHAR(450),
	@projectCd 			NVARCHAR(10),
	--@Offset				INT	= 0,
	--@PageSize			INT	= 10,
	--@Filter             NVARCHAR(100),
	@fromDate 			Datetime, 
	@toDate 			Datetime

AS
   BEGIN TRY
		
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
							,1 xcount
                        FROM [dbo].[MAS_Requests] a
                            INNER JOIN [dbSHome].[dbo].MAS_Request_Types b 
                                ON a.[requestTypeId] = b.[requestTypeId]
                            INNER JOIN UserInfo c 
                                ON a.[requestUserId] = c.[userId]	
                            INNER JOIN [MAS_Apartments] d
                                ON a.[apartmentId] = d.[apartmentId]
                        WHERE (@projectCd IS NULL OR d.[projectCd] = @projectCd)
                            AND a.[requestDt] BETWEEN @fromDate AND @toDate
							order by a.[requestDt] desc
    

				select projectCd, projectName from MAS_Projects where ProjectCd =  @projectCd
    END TRY

begin catch
    declare	@ErrorNum				int = error_number(),
            @ErrorMsg				varchar(200) = 'sp_Hom_Service_Request_report ' + error_message(),
            @ErrorProc				varchar(50) = error_procedure(),

            @SessionID				int,
            @AddlInfo				varchar(max) = ' - @userId ' + @userId

    exec utl_Insert_ErrorLog @ErrorNum, @ErrorMsg, @ErrorProc, 'sp_Hom_Service_Request_report', 'GET', @SessionID, @AddlInfo
end catch