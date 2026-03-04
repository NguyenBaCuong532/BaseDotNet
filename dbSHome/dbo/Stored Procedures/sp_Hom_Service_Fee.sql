-- =============================================
-- Author:		<vdx>
-- Description:	<Description,,>
-- =============================================
-- exec sp_Hom_Vehicles_Locked null, "03", null, null 
-- exec sp_Hom_Vehicles_Locked null, null, 0, 10, null, '2019-01-01', '2021-12-01' 
CREATE PROCEDURE [dbo].[sp_Hom_Service_Fee]
	@userId				nvarchar(450),
	@fromDate 			nvarchar(50) = null, 
	@toDate 			NVARCHAR(50) = null
AS
BEGIN try
	declare @StartDt datetime
	declare @EndDt datetime
	set @StartDt = convert(datetime, isnull(@FromDate,'2018-01-01'), 103)
	set @EndDt = convert(datetime, isnull(@ToDate,'2050-01-01'), 103)
	SET NOCOUNT ON;
		
		SELECT h.ProjectName, 
				(select sum(a.Amount) 
					from MAS_Service_Receipts a
					where a.ProjectCd = h.projectCd) 
					as ServiceAmount 
			from MAS_Projects h 
			where h.projectCd in 
					(select a.ProjectCd 
						FROM MAS_Service_Receipts a
							
							where a.ProjectCd is not null
								
						group by a.ProjectCd)
END try

begin catch
		declare	@ErrorNum				int,
				@ErrorMsg				varchar(200),
				@ErrorProc				varchar(50),

				@SessionID				int,
				@AddlInfo				varchar(max)

		set @ErrorNum					= error_number()
		set @ErrorMsg					= 'sp_Hom_Service_Fee ' + error_message()
		set @ErrorProc					= error_procedure()

		set @AddlInfo					=  ' - @userId ' + @userId

		exec utl_Insert_ErrorLog @ErrorNum, @ErrorMsg, @ErrorProc, 'sp_Hom_Service_Fee', 'GET', @SessionID, @AddlInfo
	end catch