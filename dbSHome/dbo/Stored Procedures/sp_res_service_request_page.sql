
-- =============================================
-- Author: AnhTT
-- Create date: 2025-09-23
-- Description: danh sách gói dịch vụ
-- =============================================
CREATE PROCEDURE [dbo].[sp_res_service_request_page] 
  @UserId		UNIQUEIDENTIFIER,
	@clientId	nvarchar(50) = null,
	@ProjectCd	nvarchar(30),
	@isExtra 	nvarchar(30),
	@serviceId	uniqueidentifier,
	@Status				int				= -1,
	@IsNow				int				= -1,
	@fromDate	nvarchar(20),
	@toDate		nvarchar(20),
	@filter		nvarchar(30),
	@gridWidth			int				= 0,
	@Offset				int				= 0,
	@PageSize			int				= 10,
	@acceptLanguage		NVARCHAR(50) = N'vi-VN'
	--@Total				int out,
	--@TotalFiltered		int OUT,
	--@GridKey NVARCHAR(450) OUT
as
	begin try	
		declare @Total		bigint
		declare @GridKey	nvarchar(100) = 'view_res_service_package_page'

		set		@Offset					= isnull(@Offset, 0)
		set		@PageSize				= isnull(@PageSize, 10)
		set		@Total					= isnull(@Total, 0)
		set		@filter					= isnull(@filter,'')
		set		@ProjectCd				= isnull(@ProjectCd,'')
		set		@Status					= isnull(@Status,-1)
		set		@IsNow					= isnull(@IsNow,-1)

		if		@PageSize	<= 0		set @PageSize	= 10
		if		@Offset		< 0			set @Offset		=  0
		if		@fromDate is null or @fromDate = '' set @fromDate = null
		if		@toDate is null or @toDate = '' set @toDate = null

		select	@Total					= count(a.id)
			FROM service_request a 
			JOIN MAS_Apartments b On a.apartment_id = b.ApartmentId 			
			JOIN dbo.MAS_Projects p ON p.projectCd = b.projectCd
			JOIN [service_type] r ON a.service_id = r.id 
			join UserInfo u on a.created_by = u.UserId 
			join MAS_Customers d On d.Custid = u.CustId
			left join CRM_Status s on a.status = s.statusId and statusKey ='Request'
			WHERE --r.Category in ('Fix','Ext','Sev') and 
			exists(select 1 from UserProject up where up.userId = @userId and up.projectCd = @ProjectCd)
				and (@Status = -1 or a.status = @Status)
				and (@IsNow = -1 or (a.is_quick_support = @IsNow ))
				and (@filter = '' or b.RoomCode = @filter or d.Phone = @filter or d.FullName like '%' + @filter + '%')
				AND b.projectCd = @ProjectCd
		
		

		--root	
		select recordsTotal = @Total
			  ,recordsFiltered = @Total
			  ,gridKey = @GridKey
			  ,valid = 1
		--grid config
		if @Offset = 0
		begin
			SELECT * FROM dbo.fn_config_list_gets_lang(@GridKey, @gridWidth, @acceptLanguage) 
			ORDER BY [ordinal]
		end

		SELECT a.request_code
			  ,a.apartment_id
			  ,u.fullName as createBy
			 -- ,convert(nvarchar(5),a.RequestDt,108) + ' - ' + convert(nvarchar(10),a.RequestDt,103) as RequestDate
			  ,a.service_id
			  ,isnull([Status],0) [Status]
			  --,case isnull([Status],0) when 0 then N'Mới yêu cầu' when 1 then N'Đã xem' when 2 then N'Đang xử lý' else N'Hoàn thành' end [StatusName]
			  ,s.statusName
			  ,a.is_quick_support
			--  ,a.AtTime
			--  ,RequestTypeName
			 -- ,BrokenUrl1 = (select [attachUrl] from [MAS_Request_Attach] where requestId = a.requestId and processId = 0 order by createDt offset 0 rows fetch next 1 rows only)
			 -- ,BrokenUrl2 = (select [attachUrl] from [MAS_Request_Attach] where requestId = a.requestId and processId = 0 order by createDt offset 1 rows fetch next 1 rows only)
			  --,BrokenUrl3
			  ,b.RoomCode 
			  ,d.FullName
			  ,a.created_by
			  ,b.projectCd 
			  ,p.projectName 
		FROM service_request a 
			JOIN MAS_Apartments b On a.apartment_id = b.ApartmentId 			
			JOIN dbo.MAS_Projects p ON p.projectCd = b.projectCd
			JOIN dbo.[service] se ON se.id = a.service_id
			JOIN [service_type] r ON se.service_type_id = r.id 
			JOIN [service_package] sp ON sp.id = a.package_id 
			join UserInfo u on a.created_by = u.UserId 
			join MAS_Customers d On d.Custid = u.CustId
			left join CRM_Status s on a.status = s.statusId and statusKey ='Request'
			WHERE 
			--r.Category in ('Fix','Ext','Sev') and 
			exists(select 1 from UserProject up where up.userId = @userId and up.projectCd = @ProjectCd)
				and (@Status = -1 or a.status = @Status)
				and (@IsNow = -1 or (a.is_quick_support = @IsNow ))
				and (@filter = '' or b.RoomCode = @filter or d.Phone = @filter or d.FullName like '%' + @filter + '%')
				AND b.projectCd = @ProjectCd
		ORDER BY  a.service_date DESC, b.RoomCode
			offset @Offset rows	
				fetch next @PageSize rows only
		
		
	end try
	begin catch
		declare	@ErrorNum				int,
				@ErrorMsg				varchar(200),
				@ErrorProc				varchar(50),

				@SessionID				int,
				@AddlInfo				varchar(max)

		set @ErrorNum					= error_number()
		set @ErrorMsg					= 'sp_res_service_package_page ' + error_message()
		set @ErrorProc					= error_procedure()

		set @AddlInfo					= '@UserId ' 

		exec utl_Insert_ErrorLog @ErrorNum, @ErrorMsg, @ErrorProc, 'Request', 'GET', @SessionID, @AddlInfo
	end catch