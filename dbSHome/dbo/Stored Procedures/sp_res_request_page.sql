
CREATE procedure [dbo].[sp_res_request_page]
	@UserId		UNIQUEIDENTIFIER,
	@clientId	nvarchar(50) = null,
	@ProjectCd	nvarchar(30),
	@Status				int				= -1,
	@IsNow				int				= -1,
	@fromDate	nvarchar(20),
	@toDate		nvarchar(20),
	@filter		nvarchar(30),
	@gridWidth			int				= 0,
	@Offset				int				= 0,
	@PageSize			int				= 10,
	@acceptLanguage		NVARCHAR(50)	= N'vi-VN'
	--@Total				int out,
	--@TotalFiltered		int OUT,
	--@GridKey NVARCHAR(450) OUT
as
	begin try	
		declare @Total		bigint
		declare @GridKey	nvarchar(100) = 'view_res_request_page'
		declare @FilterRequestId int

		set		@Offset					= isnull(@Offset, 0)
		set		@PageSize				= isnull(@PageSize, 10)
		set		@Total					= isnull(@Total, 0)
		set		@filter					= isnull(@filter,'')
		set		@FilterRequestId		= try_convert(int, @filter)
		set		@ProjectCd				= isnull(@ProjectCd,'')
		set		@Status					= isnull(@Status,-1)
		set		@IsNow					= isnull(@IsNow,-1)

		if		@PageSize	<= 0		set @PageSize	= 10
		if		@Offset		< 0			set @Offset		=  0
		if		@fromDate is null or @fromDate = '' set @fromDate = null
		if		@toDate is null or @toDate = '' set @toDate = null

		select	@Total					= count(a.RequestId)
			FROM MAS_Requests a 
				Inner JOIN MAS_Apartments b On a.ApartmentId = b.ApartmentId 				
				JOIN dbo.MAS_Projects p ON p.projectCd = b.projectCd
				join MAS_Request_Types r On a.RequestTypeId = r.RequestTypeId
				join UserInfo u on a.requestUserId = u.UserId 
				join MAS_Customers d On d.Custid = u.CustId
			WHERE r.Category in ('Fix','Ext','Sev') 
				and exists(select 1 from UserProject up where up.userId = @userId and up.projectCd = @ProjectCd)
				and (@Status = -1 or a.status = @Status)
				and (@IsNow = -1 or (a.isNow = @IsNow and (@IsNow = 1 or (@IsNow = 0 and a.atTime between convert(datetime,@fromDate,103) and convert(datetime,@toDate,103)))))
				and (@filter = '' or a.RequestId = @FilterRequestId or b.RoomCode = @filter or d.Phone = @filter or d.FullName like '%' + @filter + '%')
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

		SELECT
				a.RequestId,
			   a.Oid --convert sang uuid
			  ,a.[ApartmentId]
			  ,a.[Comment]
			  ,convert(nvarchar(5),a.RequestDt,108) + ' - ' + convert(nvarchar(10),a.RequestDt,103) as RequestDate
			  ,a.RequestTypeId
			  ,isnull([Status],0) [Status]
			  --,case isnull([Status],0) when 0 then N'Mới yêu cầu' when 1 then N'Đã xem' when 2 then N'Đang xử lý' else N'Hoàn thành' end [StatusName]
			  ,s.statusName
			  ,a.IsNow
			  ,a.AtTime
			  ,RequestTypeName
			  ,BrokenUrl1 = (select [attachUrl] from [MAS_Request_Attach] where requestId = a.requestId and processId = 0 order by createDt offset 0 rows fetch next 1 rows only)
			  ,BrokenUrl2 = (select [attachUrl] from [MAS_Request_Attach] where requestId = a.requestId and processId = 0 order by createDt offset 1 rows fetch next 1 rows only)
			  --,BrokenUrl3
			  ,b.RoomCode 
			  ,d.FullName
			  ,u.loginName UserLogin
			  ,a.requestUserId userId
			  ,b.projectCd 
			  ,p.projectName 
		FROM MAS_Requests a 
			JOIN MAS_Apartments b On a.ApartmentId = b.ApartmentId 			
			JOIN dbo.MAS_Projects p ON p.projectCd = b.projectCd
			JOIN MAS_Request_Types r ON a.RequestTypeId = r.RequestTypeId 
			join UserInfo u on a.requestUserId = u.UserId 
			join MAS_Customers d On d.Custid = u.CustId
			left join CRM_Status s on a.status = s.statusId and statusKey ='Request'
			WHERE r.Category in ('Fix','Ext','Sev') 
			and exists(select 1 from UserProject up where up.userId = @userId and up.projectCd = @ProjectCd)
				and (@Status = -1 or a.status = @Status)
				and (@IsNow = -1 or (a.isNow = @IsNow and (@IsNow = 1 or (@IsNow = 0 and a.atTime between convert(datetime,@fromDate,103) and convert(datetime,@toDate,103)))))
				and (@filter = '' or a.RequestId = @FilterRequestId or b.RoomCode = @filter or d.Phone = @filter or d.FullName like '%' + @filter + '%')
				AND b.projectCd = @ProjectCd
		ORDER BY  a.RequestDt DESC, b.RoomCode
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
		set @ErrorMsg					= 'sp_res_request_get ' + error_message()
		set @ErrorProc					= error_procedure()

		set @AddlInfo					= '@UserId ' 

		exec utl_Insert_ErrorLog @ErrorNum, @ErrorMsg, @ErrorProc, 'Request', 'GET', @SessionID, @AddlInfo
	end catch