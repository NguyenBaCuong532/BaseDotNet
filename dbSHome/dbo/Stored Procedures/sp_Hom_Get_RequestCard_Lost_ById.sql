








CREATE procedure [dbo].[sp_Hom_Get_RequestCard_Lost_ById]
@UserId nvarchar(450),
@requestId	int

as
	begin try
		
	--1
		SELECT r.RequestKey
			  ,r.RequestId
			  ,rr.RoomCode
			  ,ProjectName
			  ,d.FullName
			  ,[dbo].[fn_Get_TimeAgo1](r.RequestDt ,getdate()) as RequestDate
			  ,r.[Status] as [Status]
			  ,case r.[Status] when 0 then N'Mới yêu cầu' when 1 then N'Đã xem' when 2 then N'Đã khóa' else N'Từ chối' end as [StatusName]
			  ,N'Yêu cầu khóa thẻ' as regForm
			  ,CardCd
			  ,e.FullName as CardFullName
		  FROM MAS_Requests r 
		  inner join MAS_Request_Types t on r.RequestTypeId = t.RequestTypeId 
		  inner join MAS_Cards b on r.RequestId = b.RequestId 
		  inner join MAS_Apartments c on r.ApartmentId = c.ApartmentId 
		  INNER JOIN UserInfo cc ON c.UserLogin = cc.loginName
		  INNER JOIN MAS_Customers d ON cc.CustId = d.custId
		  inner join MAS_Rooms rr on c.RoomCode = rr.RoomCode 
		  inner join MAS_Buildings p ON rr.BuildingCd = p.BuildingCd 
		  INNER JOIN MAS_Customers e ON b.CustId = e.CustId
		  WHERE r.RequestId = @requestId 
			and RequestKey = 'CardLost'
		
	--2
		

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