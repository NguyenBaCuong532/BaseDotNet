




CREATE procedure [dbo].[sp_Hom_Insert_RequestSev]
	@UserID	nvarchar(450),
	@ApartmentId int,
	@RequestId int,
	@RequestTypeId int,
	--@Title nvarchar(100),
	@Comment nvarchar(max),
	@IsNow bit,
	@AtTime datetime = null
as
	begin try		
		--declare @ApartmentId int
		if @ApartmentId is null or @ApartmentId = 0
			set @ApartmentId = (SELECT top 1 ApartmentId FROM MAS_Apartment_Member a 
				inner join UserInfo b on a.CustId=b.CustId WHERE b.UserId = @UserID)
		
		IF (@ApartmentId>0)
			if @RequestId = 0
				BEGIN
					INSERT INTO [dbo].MAS_Requests
						   ([ApartmentId]
						   ,RequestDt
						   ,RequestTypeId
						   ,[Status]
						   ,RequestKey
						   ,comment
						   ,isNow
						   ,atTime
						   ,requestUserId
						   )
					 VALUES
						   (@ApartmentId
						   ,getdate()
						   ,@RequestTypeId
						   ,0
						   ,'RequestSev'
						   ,@Comment
						   ,@IsNow
						   ,@AtTime
						   ,@UserID
						   )	
					set @RequestId = @@IDENTITY
					INSERT INTO [dbo].[TRS_Request_Sevs]
						   ([RequestId]
						   ,[Comment]
						   ,[IsNow]
						   ,[AtTime])
					 VALUES
						   (@RequestId
						   ,@Comment
						   ,@IsNow
						   ,@AtTime
						   )
				END
			ELSE
				UPDATE [dbo].TRS_Request_Sevs
				   SET [Comment] = @Comment
					  ,[IsNow] = @IsNow
					  ,AtTime = @AtTime
				WHERE RequestId = @RequestId

			SELECT a.RequestId 
			  ,[ApartmentId]
			  ,c.[Comment]
			  ,convert(nvarchar(5),a.RequestDt,108) + ' - ' + convert(nvarchar(10),a.RequestDt,103) as RequestDate 
			  ,a.RequestTypeId
			  ,[Status]
			  ,case [Status] when 0 then N'Mới yêu cầu' when 1 then N'Đã xem' else N'Hoàn thành' end [StatusName]
			  ,c.IsNow
			  ,convert(nvarchar(10),c.AtTime,103) + ' ' + convert(nvarchar(5),c.AtTime,108) as [AtTime]
			  ,RequestTypeName
		  FROM [dbo].MAS_Requests a 
		    join MAS_Request_Types b ON a.RequestTypeId = b.RequestTypeId
			inner join TRS_Request_Sevs c on a.RequestId = c.RequestId 
		  WHERE a.RequestId = @RequestId

	end try
	begin catch
		declare	@ErrorNum				int,
				@ErrorMsg				varchar(200),
				@ErrorProc				varchar(50),

				@SessionID				int,
				@AddlInfo				varchar(max)

		set @ErrorNum					= error_number()
		set @ErrorMsg					= 'sp_Insert_RequestFix ' + error_message()
		set @ErrorProc					= error_procedure()

		set @AddlInfo					= '@ApartmentId ' + @ApartmentId 

		exec utl_Insert_ErrorLog @ErrorNum, @ErrorMsg, @ErrorProc, 'RequestFix', 'Insert', @SessionID, @AddlInfo
	end catch