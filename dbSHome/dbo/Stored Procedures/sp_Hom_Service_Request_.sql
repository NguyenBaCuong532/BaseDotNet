-- =============================================
-- Author:		<vdx>
-- Description:	<Report of service request,,>
-- =============================================
-- exec sp_Hom_Service_Request_ null, null, 0, 10, null, '2017-01-01', '2021-12-01' 
CREATE PROCEDURE [dbo].[sp_Hom_Service_Request_]
	@userId				nvarchar(450),
	@projectCd 			nvarchar(10),
	@fromDate 			nvarchar(50) = null, 
	@toDate 			NVARCHAR(50) = null
AS
    BEGIN
        BEGIN TRY
            declare @code       int = 126
           	declare @StartDt    datetime = convert(datetime, isnull(@FromDate,'2000-01-01'), @code),
	                @EndDt      datetime = convert(datetime, isnull(@ToDate,'2050-01-01'), @code)
	        SET NOCOUNT ON;        
            SELECT a.projectCd, a.status, COUNT(a.status) 
                from [dbo].[MAS_requests] a
                 GROUP BY a.projectCd, a.[status]
        END TRY

        begin catch
                declare	@ErrorNum		int = error_number(),
                        @ErrorMsg		varchar(200) = 'sp_Hom_Service_Request_ ' + error_message(),
                        @ErrorProc		varchar(50) = error_procedure(),

                        @SessionID		int,
                        @AddlInfo		varchar(max) = ' - @userId ' + @userId

                exec utl_Insert_ErrorLog @ErrorNum, @ErrorMsg, @ErrorProc, 'sp_Hom_Service_Request_', 'Update', @SessionID, @AddlInfo
        end catch
    END