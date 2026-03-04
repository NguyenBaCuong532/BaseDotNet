



CREATE procedure [dbo].[sp_Hom_Get_RequestSev_List_ByManager]
	@UserId	nvarchar(450),
	@ProjectCd nvarchar(30),
	@RoomCd nvarchar(30),
	@Offset				int				= 0,
	@PageSize			int				= 10,
	@Total				int out,
	@TotalFiltered		int out
as
	begin try	

		set		@Offset					= isnull(@Offset, 0)
		set		@PageSize				= isnull(@PageSize, 10)
		set		@Total					= isnull(@Total, 0)
		set		@RoomCd					= isnull(@RoomCd,'')
		set		@ProjectCd				= isnull(@ProjectCd,'')

		if		@PageSize	= 0			set @PageSize	= 10
		if		@Offset		< 0			set @Offset		=  0

		select	@Total					= count(a.RequestId)
			FROM MAS_Requests a 
				Inner JOIN MAS_Apartments b On a.ApartmentId = b.ApartmentId 
					inner join MAS_Request_Types r On a.RequestTypeId = r.RequestTypeId
					inner join MAS_Rooms rr on b.RoomCode = rr.RoomCode
					inner join MAS_Buildings d on rr.BuildingCd = d.BuildingCd 
				WHERE r.Category in ('Sev')
					and d.ProjectCd like @ProjectCd + '%'
					and rr.RoomCode like '%' + @RoomCd + '%'
					and exists (SELECT * FROM [dbo].[fn_Exists_CustCategory] (@UserId,null) where CategoryCd = d.ProjectCd
			)
		set	@TotalFiltered = @Total

		if @PageSize < 0
		begin
			set	@PageSize				= 10
		end

		SELECT a.RequestId 
			  ,a.[ApartmentId]
			  ,e.[Comment]
			  ,convert(nvarchar(5),a.[RequestDt],108) + ' - ' + convert(nvarchar(10),a.[RequestDt],103) as RequestDate 
			  ,a.RequestTypeId
			  ,isnull(a.[Status],0) [Status]
			  ,case isnull(a.[Status],0) when 0 then N'Mới yêu cầu' when 1 then N'Đã phân công' else N'Hoàn thành' end [StatusName]
			  ,convert(nvarchar(10),a.[AtTime],103) + ' ' + convert(nvarchar(5),a.[AtTime],108) as [OnTime]
			  ,b.RequestTypeName
			  ,c.RoomCode
			  ,d.FullName
			  ,u.loginName UserLogin
	  FROM [dbo].MAS_Requests a 
			inner join MAS_Request_Types b ON a.RequestTypeId = b.RequestTypeId 
			INNER JOIN MAS_Apartments c On a.ApartmentId = c.ApartmentId 
			INNER JOIN MAS_Contacts cc on cc.Cif_No = c.Cif_No 
			inner join MAS_Customers d On d.custId = cc.CustId 
			inner join TRS_Request_Sevs e on a.RequestId = e.RequestId 
			inner join MAS_Rooms rr on c.RoomCode = rr.RoomCode
			inner join MAS_Buildings f on rr.BuildingCd = f.BuildingCd 
			inner join UserInfo u on c.UserLogin = u.loginName 
		WHERE b.Category in ('Sev')
			and f.ProjectCd like @ProjectCd + '%'
			and rr.RoomCode like '%' + @RoomCd + '%'
			and exists (SELECT * FROM [dbo].[fn_Exists_CustCategory] (@UserId,null) where CategoryCd = f.ProjectCd
			)
	ORDER BY [RequestDt] DESC,c.RoomCode
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

		set @AddlInfo					= '@UserId ' 

		exec utl_Insert_ErrorLog @ErrorNum, @ErrorMsg, @ErrorProc, 'RequestFixs', 'GET', @SessionID, @AddlInfo
	end catch