



CREATE procedure [dbo].[sp_Hom_App_Request_ByUserId]
	@UserId	nvarchar(450),
	@ApartmentId int,
	@Offset				int				= 0,
	@PageSize			int				= 10,
	@Total				int out,
	@TotalFiltered		int out
as
	begin try
		if @ApartmentId is null or @ApartmentId = 0
			set @ApartmentId = (select top 1 ApartmentId from [dbo].[fn_Hom_User_Apartment] (@userId))			
		

		set		@Offset					= isnull(@Offset, 0)
		set		@PageSize				= isnull(@PageSize, 10)
		set		@Total					= isnull(@Total, 0)

		if		@PageSize	= 0			set @PageSize	= 10
		if		@Offset		< 0			set @Offset		=  0

		select	@Total					= count(a.RequestId)
			FROM MAS_Requests a 
				JOIN MAS_Apartments b On a.ApartmentId = b.ApartmentId 
				join MAS_Request_Types r On a.RequestTypeId = r.RequestTypeId
				WHERE r.Category in ('Fix','Ext','Sev')
					and b.ApartmentId  = @ApartmentId

		set	@TotalFiltered = @Total

		if @PageSize < 0
		begin
			set	@PageSize				= 10
		end

		SELECT a.RequestId
		  ,a.[ApartmentId]
		  ,a.[Comment]
		  ,convert(nvarchar(5),a.RequestDt,108) + ' - ' + convert(nvarchar(10),a.RequestDt,103) as RequestDate
		  ,a.RequestTypeId
		  ,isnull([Status],0) [Status]
		  --,case isnull([Status],0) when 0 then N'Tiếp nhận yêu cầu' when 1 then N'Đã phân công' when 2 then N'Đang xử lý' when 3 then N'Chờ phản hồi' else N'Hoàn thành' end [StatusName]
		  ,s.statusName
		  ,a.IsNow
		  ,a.AtTime
		  ,c.RequestTypeName
		  ,BrokenUrl1 = (select attachUrl from [MAS_Request_Attach] t where t.requestId = a.requestId and t.processId = 0 order by t.id OFFSET 0 ROWS FETCH NEXT 1 ROWS ONLY) --offset 0 fetch next 1 rows only)
		  ,BrokenUrl2 = (select attachUrl from [MAS_Request_Attach] t where t.requestId = a.requestId and t.processId = 0 order by t.id OFFSET 1 ROWS FETCH NEXT 1 ROWS ONLY)
		  ,BrokenUrl3 = (select attachUrl from [MAS_Request_Attach] t where t.requestId = a.requestId and t.processId = 0 order by t.id OFFSET 2 ROWS FETCH NEXT 1 ROWS ONLY)
		  ,RequestKey
		  ,a.rating
		  ,case when a.status = 4 then 1 else 0 end isFinished
	  FROM MAS_Requests a  
		JOIN MAS_Apartments b On a.ApartmentId = b.ApartmentId  
		JOIN MAS_Request_Types c ON a.RequestTypeId = c.RequestTypeId 
		left join CRM_Status s on a.status = s.statusId and s.statusKey = 'Request'
		WHERE c.Category in ('Fix','Ext','Sev')
				and b.ApartmentId  = @ApartmentId
	ORDER BY  RequestDt DESC
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
		set @ErrorMsg					= 'sp_Hom_App_Request_ByUserId ' + error_message()
		set @ErrorProc					= error_procedure()

		set @AddlInfo					= '@UserId ' +@UserId

		exec utl_Insert_ErrorLog @ErrorNum, @ErrorMsg, @ErrorProc, 'Requests', 'GET', @SessionID, @AddlInfo
	end catch