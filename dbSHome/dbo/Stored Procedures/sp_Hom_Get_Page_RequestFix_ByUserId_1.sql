


CREATE procedure [dbo].[sp_Hom_Get_Page_RequestFix_ByUserId]
	@UserId	nvarchar(450),
	@ApartmentId int,
	@Offset				int				= 0,
	@PageSize			int				= 10,
	@Total				int out,
	@TotalFiltered		int out
as
	begin try	
		if @ApartmentId is null or @ApartmentId = 0
		set @ApartmentId = (SELECT top 1 ApartmentId FROM MAS_Apartment_Member a 
			inner join UserInfo b on a.CustId=b.CustId WHERE a.memberUserId = @UserID)

		set		@Offset					= isnull(@Offset, 0)
		set		@PageSize				= isnull(@PageSize, 10)
		set		@Total					= isnull(@Total, 0)

		if		@PageSize	= 0			set @PageSize	= 10
		if		@Offset		< 0			set @Offset		=  0

		select	@Total					= count(a.RequestId)
			FROM MAS_Requests a 
				JOIN MAS_Apartments b On a.ApartmentId = b.ApartmentId 
				join MAS_Request_Types r On a.RequestTypeId = r.RequestTypeId
			WHERE r.Category in ('Fix','Ext')
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
		  ,case isnull([Status],0) when 0 then N'Mới yêu cầu' when 1 then N'Đã phân công' when 2 then N'Đang xử lý' else N'Hoàn thành' end [StatusName]
		  ,a.IsNow
		  ,a.AtTime
		  ,RequestTypeName
		  ,a.rating
		  --,BrokenUrl1
		  --,BrokenUrl2
		  --,BrokenUrl3
		  ,RequestKey
	  FROM MAS_Requests a 
		JOIN MAS_Apartments b On a.ApartmentId = b.ApartmentId 
		JOIN MAS_Request_Types c ON a.RequestTypeId = c.RequestTypeId 
			--inner join TRS_Request_Fixs e on a.RequestId = e.RequestId 
		WHERE c.Category in ('Fix','Ext')
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
		set @ErrorMsg					= 'sp_Get_RequestFixs_ByUserId ' + error_message()
		set @ErrorProc					= error_procedure()

		set @AddlInfo					= '@UserId ' +@UserId

		exec utl_Insert_ErrorLog @ErrorNum, @ErrorMsg, @ErrorProc, 'RequestFixs', 'GET', @SessionID, @AddlInfo
	end catch