








CREATE procedure [dbo].[sp_Hom_App_Request_Get]
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
			  ,s.statusName 
			  ,convert(nvarchar(10),a.[AtTime],103) + ' ' + convert(nvarchar(5),a.[AtTime],108) as [AtTime]
			  ,a.isNow
			  ,b.RequestTypeName
			  ,a.rating
			  ,case when a.status = 4 then 1 else 0 end as IsFinished
			 
		  FROM [dbo].MAS_Requests a 
			join MAS_Request_Types b ON a.RequestTypeId = b.RequestTypeId
			JOIN MAS_Apartments d On a.ApartmentId = d.ApartmentId 
			join CRM_Status s on a.status = s.statusId and s.statusKey = 'Request'
		  WHERE a.RequestId = @RequestId
		
		--2
		SELECT [id]
			  ,[requestId]
			  ,[processId]
			  ,[attachUrl]
			  ,[attachType]
			  ,attachFileName
			  ,1 as used
			  ,[createDt]
		  FROM [dbo].MAS_Request_Attach
		  where [requestId] = @RequestId and processId = 0
	
		--3
		SELECT [ProcessId]
			  ,[RequestId]
			  ,[Comment]
			  ,b.FullName as userName
			  ,convert(nvarchar(5),a.[ProcessDt],108) + ' - ' + convert(nvarchar(10),a.[ProcessDt],103) as [ProcessDate]
			  ,a.userId
			  ,isnull([Status],0) [Status]
			  ,s.statusName
			  ,FullName
			  ,b.AvatarUrl
	  FROM [MAS_Request_Process] a 
		INNER JOIN UserInfo b ON a.userId = b.UserId
		join CRM_Status s on a.status = s.statusId and s.statusKey = 'Request'
	  WHERE RequestId = @RequestId
		  ORDER BY [ProcessDt] DESC
		
		--4
		SELECT a.RequestId 
			  ,a.rating
			  ,case when a.status = 4 then 1 else 0 end as IsFinished
			  ,d.comment
			  ,format(a.review_dt, 'dd/MM/yyyy hh:mm:ss') as review_date
		  FROM [dbo].MAS_Requests a 
			JOIN [MAS_Request_Process] d On a.requestId = d.requestId 
		  WHERE a.RequestId = @RequestId	
			and d.Status = 4
			and d.userId = @UserId

		--5
		SELECT a.[id]
			  ,a.[requestId]
			  ,a.[processId]
			  ,a.[attachUrl]
			  ,a.[attachType]
			  ,a.attachFileName
			  ,1 as used
			  ,a.[createDt]
		  FROM [dbo].MAS_Request_Attach a
			JOIN [MAS_Request_Process] d On a.processId = d.processId 
		  where d.RequestId = @RequestId	
			and d.Status = 4
			and d.userId = @UserId


	end try
	begin catch
		declare	@ErrorNum				int,
				@ErrorMsg				varchar(200),
				@ErrorProc				varchar(50),

				@SessionID				int,
				@AddlInfo				varchar(max)

		set @ErrorNum					= error_number()
		set @ErrorMsg					= 'sp_Hom_App_Request_Get ' + error_message()
		set @ErrorProc					= error_procedure()

		set @AddlInfo					= ' '

		exec utl_Insert_ErrorLog @ErrorNum, @ErrorMsg, @ErrorProc, 'Request', 'GET', @SessionID, @AddlInfo
	end catch