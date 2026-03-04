


CREATE procedure [dbo].[sp_Hom_Request_Set]
	@UserID	nvarchar(450),
	@ApartmentId int,
	@RequestId int,
	@RequestTypeId int,
	@Comment nvarchar(max),
	@IsNow bit,
	@AtTime datetime = null,
	@thread_id nvarchar(200) = null
as
	begin try		
		--declare @ApartmentId int
		declare @webId nvarchar(50) = '77929A9C-3085-4158-AE32-320A67704899'
		declare @tbUsers TABLE 
		(
			userid [nvarchar](100) not null INDEX IX1_category NONCLUSTERED
		)

		if @ApartmentId is null or @ApartmentId = 0
			set @ApartmentId = (SELECT top 1 ApartmentId FROM MAS_Apartment_Member a 
				join UserInfo b on a.CustId=b.CustId WHERE b.UserId = @UserID
				)
		if @ApartmentId is null
			set @ApartmentId = (SELECT top 1 ApartmentId FROM MAS_Apartment_Member a 
				join UserInfo b on a.CustId=b.CustId WHERE 
				exists(select userid from UserInfo where CustId = b.CustId and UserId = @UserId)
				)
		
		INSERT INTO @tbUsers
		select distinct u.userId from [dbSHome].[dbo].[MAS_Category_User] u 
			join MAS_Apartments a on u.categoryCd = a.projectCd
			where u.webId = @webId and u.isAll = 0 
			and (a.ApartmentId = @ApartmentId)
		INSERT INTO @tbUsers
		select distinct u.userId from [dbSHome].[dbo].[MAS_Category_User] u 
			join [dbSHome].[dbo].MAS_Category n on n.base_type = u.base_type 
			join MAS_Apartments a on u.categoryCd = a.projectCd
			where u.webId = @webId and u.isAll = 1
			and (a.ApartmentId = @ApartmentId)


		IF (@ApartmentId>0)
			if @RequestId = 0
				BEGIN
					INSERT INTO [dbo].MAS_Requests
						   ([ApartmentId]
						   ,RequestDt
						   ,RequestTypeId
						   ,[Status]
						   ,RequestKey
						   ,[Comment]
						   ,[IsNow]
						   ,[AtTime]
						   ,thread_id
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
						   ,@thread_id
						   ,@UserID
						   )	
					set @RequestId = @@IDENTITY
					
					
				END
			ELSE
				UPDATE [dbo].MAS_Requests
				   SET [Comment] = @Comment
					  ,[IsNow] = @IsNow
					  ,AtTime = @AtTime
				WHERE RequestId = @RequestId

			SELECT a.RequestId 
				  ,a.[ApartmentId]
				  ,a.[Comment]
				  ,convert(nvarchar(5),a.RequestDt,108) + ' - ' + convert(nvarchar(10),a.RequestDt,103) as RequestDate 
				  ,a.RequestTypeId
				  ,a.[Status]
				  ,case a.[Status] when 0 then N'Mới yêu cầu' when 1 then N'Đã xem' else N'Hoàn thành' end [StatusName]
				  ,a.IsNow
				  ,convert(nvarchar(10),a.AtTime,103) + ' ' + convert(nvarchar(5),a.AtTime,108) as [AtTime]
				  ,b.RequestTypeName
				  ,a.thread_id
		  FROM [dbo].MAS_Requests a 
			join MAS_Request_Types b ON a.RequestTypeId = b.RequestTypeId
		  WHERE a.RequestId = @RequestId

	end try
	begin catch
		declare	@ErrorNum				int,
				@ErrorMsg				varchar(200),
				@ErrorProc				varchar(50),

				@SessionID				int,
				@AddlInfo				varchar(max)

		set @ErrorNum					= error_number()
		set @ErrorMsg					= 'sp_Hom_Request_Set ' + error_message()
		set @ErrorProc					= error_procedure()

		set @AddlInfo					= '@ApartmentId ' + @ApartmentId 

		exec utl_Insert_ErrorLog @ErrorNum, @ErrorMsg, @ErrorProc, 'RequestFix', 'Insert', @SessionID, @AddlInfo
	end catch