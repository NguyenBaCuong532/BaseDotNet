







CREATE procedure [dbo].[sp_Hom_Get_RequestSev_ByRequestId]
@UserId nvarchar(450),
@RequestId	int

as
	begin try
		
	--1
		SELECT a.RequestId 
		  ,a.[ApartmentId]
		  ,a.[Comment]
		  ,convert(nvarchar(5),a.[RequestDt],108) + ' - ' + convert(nvarchar(10),a.[RequestDt],103) as RequestDate 
		  ,a.RequestTypeId
		  ,isnull([Status],0) [Status]
		  ,case isnull([Status],0) when 0 then N'Mới yêu cầu' when 1 then N'Đã phân công' when 2 then N'Đang xử lý' else N'Hoàn thành' end [StatusName]
		  ,convert(nvarchar(10),a.[AtTime],103) + ' ' + convert(nvarchar(5),a.[AtTime],108) as [OnTime]
		  ,b.RequestTypeName
		  ,d.RoomCode 
		  ,e.FullName
		  ,f.ProjectCd 
		  ,f.ProjectName 
		  ,u.loginName UserLogin
	  FROM [dbo].MAS_Requests a 
		inner join MAS_Request_Types b ON a.RequestTypeId = b.RequestTypeId
		inner join TRS_Request_Sevs c on a.RequestId = c.RequestId 
		INNER JOIN MAS_Apartments d On a.ApartmentId = d.ApartmentId 
		inner join MAS_Contacts cc on d.Cif_No = cc.Cif_No 
		inner join MAS_Customers e On e.Custid = cc.CustId
		inner join MAS_Rooms rr on d.RoomCode = rr.RoomCode 
		inner join MAS_Buildings f on rr.BuildingCd = f.BuildingCd 
		inner join UserInfo u on d.UserLogin = u.loginName 
	  WHERE a.RequestId = @RequestId
		
	--2
		SELECT [ProcessId]
			  ,[RequestId]
			  ,[Comment]
			  ,b.FullName as [EmployeeName]
			  ,convert(nvarchar(5),a.[ProcessDt],108) + ' - ' + convert(nvarchar(10),a.[ProcessDt],103) as [ProcessDate]
			  ,a.userId
			  ,isnull([Status],0) [Status]
			  ,FullName
			  ,b.AvatarUrl
	  FROM [MAS_Request_Process] a 
			inner join UserInfo b on a.userId = b.UserId
		WHERE RequestId = @RequestId
		  ORDER BY [ProcessDt] DESC
		

	end try
	begin catch
		declare	@ErrorNum				int,
				@ErrorMsg				varchar(200),
				@ErrorProc				varchar(50),

				@SessionID				int,
				@AddlInfo				varchar(max)

		set @ErrorNum					= error_number()
		set @ErrorMsg					= 'sp_Get_RequestFix_ByRequestId ' + error_message()
		set @ErrorProc					= error_procedure()

		set @AddlInfo					= ' '

		exec utl_Insert_ErrorLog @ErrorNum, @ErrorMsg, @ErrorProc, 'RequestFix', 'GET', @SessionID, @AddlInfo
	end catch