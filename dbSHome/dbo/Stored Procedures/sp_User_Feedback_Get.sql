








CREATE procedure [dbo].[sp_User_Feedback_Get]
		--@UserId nvarchar(450),
		@FeedbackId	int

as
	begin try
	
		--1
		 SELECT p.projectName 
			  ,n.[RoomCode]
			  ,c.FullName
			  ,c.AvatarUrl
			  ,f.FeedbackTypeName 
			  ,a.Title 
			  ,a.Comment
			  ,dbo.fn_Get_DateAgo(a.InputDate,getdate()) FeedbackDate
			  ,a.FeedbackId
			  ,a.[Status]
			  ,case a.[Status] when 0 then N'Mới tại' when 1 then N'Đang thực hiện' else N'Hoàn thành' end as StatusName
		  FROM [MAS_Feedbacks] a 
				inner join UserInfo b on a.UserId = b.UserId 
				left join MAS_FeedbackType f on f.FeedbackTypeId = a.FeedbackTypeId 
				INNER JOIN MAS_Customers c ON b.CustId = c.CustId
				inner join [MAS_Apartments] n on a.ApartmentId = n.ApartmentId
				inner join MAS_Projects p on p.projectCd = n.projectCd
		  WHERE FeedbackId = @FeedbackId
		
		--2
		SELECT [ProcessId]
			  ,FeedbackId
			  ,[Comment]
			  ,b.FullName as [EmployeeName]
			  ,convert(nvarchar(5),a.[ProcessDt],108) + ' - ' + convert(nvarchar(10),a.[ProcessDt],103) as [ProcessDate]
			  ,a.userId
			  ,isnull([Status],0) [Status]
			  ,b.FullName
			  ,b.AvatarUrl
			  ,isnull([Status],0) [Status]
			  ,case isnull([Status],0) when 0 then N'Mới tại' when 1 then N'Đang thực hiện' else N'Hoàn thành' end as StatusName
		  FROM MAS_FeedbackProcess a 
			 JOIN UserInfo b ON a.userId = b.UserId
		  WHERE FeedbackId = @FeedbackId
			  ORDER BY [ProcessDt] DESC

		--3
		SELECT [id]
			  ,FeedbackId as requestId
			  ,[processId]
			  ,[attachUrl]
			  ,[attachType]
			  ,attachFileName
			  ,1 as used
			  ,[createDt]
		  FROM [dbSHome].[dbo].MAS_FeedbackAttach
		  where FeedbackId = @FeedbackId 
			and processId = 0

	end try
	begin catch
		declare	@ErrorNum				int,
				@ErrorMsg				varchar(200),
				@ErrorProc				varchar(50),

				@SessionID				int,
				@AddlInfo				varchar(max)

		set @ErrorNum					= error_number()
		set @ErrorMsg					= 'sp_User_Get_Feedback_ById ' + error_message()
		set @ErrorProc					= error_procedure()

		set @AddlInfo					= ' '

		exec utl_Insert_ErrorLog @ErrorNum, @ErrorMsg, @ErrorProc, 'Feedback', 'GET', @SessionID, @AddlInfo
	end catch