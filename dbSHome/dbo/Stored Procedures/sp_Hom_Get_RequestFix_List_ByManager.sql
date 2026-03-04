


CREATE procedure [dbo].[sp_Hom_Get_RequestFix_List_ByManager]
	@UserId	nvarchar(450),
	@ProjectCd nvarchar(30),
	@RoomCd nvarchar(30),
	@Offset				int				= 0,
	@PageSize			int				= 10,
	@Total				int out,
	@TotalFiltered		int out
as
	begin try	
		declare @tbRegs TABLE 
		(
			RequestId [Int] null
		)

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
			WHERE r.Category in ('Fix','Ext') 
				and d.ProjectCd like @ProjectCd + '%'
				and rr.RoomCode like '%' + @RoomCd + '%'
				and exists (SELECT * FROM [dbo].[fn_Exists_CustCategory] (@UserId,null) where CategoryCd = d.ProjectCd
			)
		INSERT INTO @tbRegs 
			SELECT a.RequestId
			  FROM MAS_Requests a 
				  INNER JOIN MAS_Apartments b ON a.ApartmentId = b.ApartmentId
				  inner join MAS_Request_Types r On a.RequestTypeId = r.RequestTypeId
				  inner join MAS_Rooms rr on b.RoomCode = rr.RoomCode
				  inner join MAS_Buildings d on rr.BuildingCd = d.BuildingCd 
				WHERE r.Category in ('Fix','Ext') 
					and d.ProjectCd like @ProjectCd + '%'
					and rr.RoomCode like '%' + @RoomCd + '%'
					and exists (SELECT * FROM [dbo].[fn_Exists_CustCategory] (@UserId,null) where CategoryCd = d.ProjectCd
					)
				 ORDER BY  a.RequestDt DESC,rr.RoomCode
					offset @Offset rows	
					fetch next @PageSize rows only

		set	@TotalFiltered = @Total

		if @PageSize < 0
		begin
			set	@PageSize				= 10
		end

		SELECT a.RequestId
			  ,a.[ApartmentId]
			  ,e.[Comment]
			  ,convert(nvarchar(5),a.RequestDt,108) + ' - ' + convert(nvarchar(10),a.RequestDt,103) as RequestDate
			  ,a.RequestTypeId
			  ,isnull([Status],0) [Status]
			  ,case isnull([Status],0) when 0 then N'Mới yêu cầu' when 1 then N'Đã xem' when 2 then N'Đang xử lý' else N'Hoàn thành' end [StatusName]
			  ,a.IsNow
			  ,a.AtTime
			  ,RequestTypeName
			  ,BrokenUrl1
			  ,BrokenUrl2
			  ,BrokenUrl3
			  ,b.RoomCode 
			  ,d.FullName
			  ,u.loginName UserLogin
		FROM MAS_Requests a 
			INNER JOIN MAS_Apartments b On a.ApartmentId = b.ApartmentId 
			INNER JOIN MAS_Request_Types c ON a.RequestTypeId = c.RequestTypeId 
			INNER JOIN MAS_Contacts cc on b.Cif_No = cc.Cif_No 
			inner join MAS_Customers d On d.Custid = cc.CustId
			inner join TRS_Request_Fixs e on a.RequestId = e.RequestId 
			inner join MAS_Rooms rr on b.RoomCode = rr.RoomCode
			inner join MAS_Buildings f on rr.BuildingCd = f.BuildingCd 
			inner join UserInfo u on b.UserLogin = u.loginName 
			WHERE c.Category in ('Fix','Ext') 
				and f.ProjectCd like @ProjectCd + '%'
				and rr.RoomCode like '%' + @RoomCd + '%'
				and exists (SELECT * FROM [dbo].[fn_Exists_CustCategory] (@UserId,null) where CategoryCd = f.ProjectCd
					)
		ORDER BY  a.RequestDt DESC,rr.RoomCode
			offset @Offset rows	
					fetch next @PageSize rows only
		
		--2
		SELECT [Id]
			  ,a.[RequestId]
			  ,a.userId
			  ,FullName as EmployeeName
			  ,a.assignRole
			  ,b.Phone
			  ,b.Email
		FROM [MAS_Request_Assign] a 
			  inner join UserInfo b on a.userId = b.UserId
			  inner join @tbRegs c on a.RequestId = c.RequestId
	  
	
		--3
		SELECT [ProcessId]
			  ,a.[RequestId]
			  ,[Comment]
			  ,b.FullName as [EmployeeName]
			  ,convert(nvarchar(10),a.[ProcessDt],103) + ' ' + convert(nvarchar(5),a.[ProcessDt],108) as [ProcessDate]  
			  ,a.userId
			  ,isnull([Status],0) [Status]
		 FROM [MAS_Request_Process] a 
				inner join UserInfo b on a.userId = b.UserId
				inner join @tbRegs c on a.RequestId = c.RequestId

	end try
	begin catch
		declare	@ErrorNum				int,
				@ErrorMsg				varchar(200),
				@ErrorProc				varchar(50),

				@SessionID				int,
				@AddlInfo				varchar(max)

		set @ErrorNum					= error_number()
		set @ErrorMsg					= 'sp_Get_RequestFix_List_ByManager ' + error_message()
		set @ErrorProc					= error_procedure()

		set @AddlInfo					= '@UserId ' 

		exec utl_Insert_ErrorLog @ErrorNum, @ErrorMsg, @ErrorProc, 'RequestFixs', 'GET', @SessionID, @AddlInfo
	end catch