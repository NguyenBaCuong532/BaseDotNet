



CREATE procedure [dbo].[sp_Hom_Insert_RequestFix]
	@UserID	nvarchar(450),
	@ApartmentId int,
	@RequestId int,
	@RequestTypeId int,
	--@Title nvarchar(100),
	@Comment nvarchar(max),
	@BrokenUrl1 nvarchar(250),
    @BrokenUrl2 nvarchar(250),
    @BrokenUrl3 nvarchar(250),
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
				   (RequestKey
				   ,ApartmentId
				   ,[RequestDt]
				   ,RequestTypeId
				   ,[Status]
				   ,comment
				   ,isNow
				   ,atTime
				   ,requestUserId
				   )
				VALUES
				   (
				   'RequestFix'
				   ,@ApartmentId
				   ,getdate()
				   ,@RequestTypeId
				   ,0
				   ,@Comment
				   ,@IsNow
				   ,@AtTime
				   ,@UserID
				   )	
				set @RequestId = @@IDENTITY
				INSERT INTO [dbo].[TRS_Request_Fixs]
				   ([RequestId]
				   ,[Comment]
				   ,[BrokenUrl1]
				   ,[BrokenUrl2]
				   ,[BrokenUrl3]
				   ,[IsNow]
				   ,[AtTime])
			 VALUES
				   (@RequestId
				   ,@Comment
				   ,@BrokenUrl1
				   ,@BrokenUrl2
				   ,@BrokenUrl3
				   ,@IsNow
				   ,@AtTime
				   )

				   EXECUTE [dbo].[sp_Hom_Request_Attach_Set] 
					   @UserId
					  ,0
					  ,@requestId
					  ,0
					  ,@BrokenUrl1
					  ,'image/jpeg'
					  ,''
					  ,1
					EXECUTE [dbo].[sp_Hom_Request_Attach_Set] 
					   @UserId
					  ,0
					  ,@requestId
					  ,0
					  ,@BrokenUrl2
					  ,'image/jpeg'
					  ,''
					  ,1
					EXECUTE [dbo].[sp_Hom_Request_Attach_Set] 
					   @UserId
					  ,0
					  ,@requestId
					  ,0
					  ,@BrokenUrl3
					  ,'image/jpeg'
					  ,''
					  ,1

			END
			ELSE
				UPDATE [dbo].[TRS_Request_Fixs]
					SET Comment = @Comment
						,IsNow = @IsNow
						,AtTime = @AtTime
						,[BrokenUrl1] = @BrokenUrl1
						,[BrokenUrl2] = @BrokenUrl2
						,[BrokenUrl3] = @BrokenUrl3
				WHERE RequestId = @RequestId
		
		SELECT a.[RequestId]
			,[ApartmentId]
			,b.[Comment]
			,convert(nvarchar(5),a.RequestDt,108) + ' - ' + convert(nvarchar(10),a.RequestDt,103) as [RequestDate]
			,[RequestTypeId]
			,[Status]
			,case [Status] when 0 then N'Mới yêu cầu' when 1 then N'Đã phân công' else N'Hoàn thành' end [StatusName]
			,[BrokenUrl1]
			,[BrokenUrl2]
			,[BrokenUrl3]
			,b.IsNow
			,b.AtTime
		FROM MAS_Requests a 
			inner join TRS_Request_Fixs b on a.RequestId = b.RequestId 
	  WHERE a.[RequestId] = @RequestId

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