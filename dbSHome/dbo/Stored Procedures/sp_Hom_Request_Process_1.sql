





CREATE procedure [dbo].[sp_Hom_Request_Process]
	@UserID	nvarchar(450),
	@RequestId int,
	@Comment nvarchar(max),
	@Status int
	
as
	begin try		
		declare @ProcessId bigint

			INSERT INTO [dbo].MAS_Request_Process
				   ([RequestId]
				   ,Comment
				   ,userId
				   ,[ProcessDt]
				   ,[Status])
			 SELECT top (1) @RequestId
				   ,@Comment
				   ,UserId
				   ,getdate()
				   ,@Status
			FROM Users WHERE UserId = @UserID 

			set @ProcessId = @@IDENTITY

			UPDATE [dbo].MAS_Requests
			   SET [Status] = @Status
			 WHERE [RequestId] = @RequestId

			SELECT a.[ProcessId]
				  ,a.[RequestId]
				  ,a.[Comment]
				  ,b.FullName as userName
				  ,convert(nvarchar(10),a.[ProcessDt],103) + ' ' + convert(nvarchar(5),a.[ProcessDt],108) as [ProcessDate]  
				  ,a.userId
				  ,a.[Status]
				  ,s.statusName
		  FROM MAS_Request_Process a 
			inner join Users b On a.userId = b.UserId
			join CRM_Status s on a.Status = s.statusId and s.statusKey = 'Request'
		  WHERE ProcessId = @ProcessId


	end try
	begin catch
		declare	@ErrorNum				int,
				@ErrorMsg				varchar(200),
				@ErrorProc				varchar(50),

				@SessionID				int,
				@AddlInfo				varchar(max)

		set @ErrorNum					= error_number()
		set @ErrorMsg					= 'sp_Hom_Request_Process ' + error_message()
		set @ErrorProc					= error_procedure()

		set @AddlInfo					= '@NotiId ' + @RequestId 

		exec utl_Insert_ErrorLog @ErrorNum, @ErrorMsg, @ErrorProc, 'Request', 'process', @SessionID, @AddlInfo
	end catch