



CREATE procedure [dbo].[sp_Hom_App_Apartment_Member_Set]
	@UserID	nvarchar(450),
	@CustId	nvarchar(50),
	@FaceId nvarchar(150),
	@AvatarUrl nvarchar(250),
	@FullName nvarchar(250),
	@Phone nvarchar(30),	
	@Email nvarchar(150),
	@Address nvarchar(250),
	@Sex bit,
	@Birthday nvarchar(10),
	@FaceRecogUrl1 nvarchar(250),
	@FaceRecogUrl2 nvarchar(250),
	@FaceRecogUrl3 nvarchar(250),
	@FaceRecogUrl4 nvarchar(250),
	@FaceRecogUrl5 nvarchar(250),
	@ApartmentId bigint,
	@RelationId int,
	@IsForeign bit = 0
as
	begin try		
	--declare @CustomerId nvarchar(50)
	declare @CategoryCd nvarchar(50)
	set @IsForeign = isnull(@IsForeign,0)
	
	if exists(select top 1 ApartmentId from [dbo].[fn_Hom_User_Apartment] (@userId) ua where IsHost = 1 
			or ua.custId = @CustId)
	
	begin
	if @ApartmentId is null or @ApartmentId = 0 
		set @ApartmentId = (select top 1 ApartmentId from [dbo].[fn_Hom_User_Apartment] (@userId))

	set @CategoryCd = (Select c.ProjectCd from MAS_Apartments c where c.ApartmentId = @ApartmentId)

	IF (@CustId is null or @CustId = '') OR NOT EXISTS(SELECT CustId FROM [MAS_Customers] WHERE CustId = @CustId)
	begin
		set @CustId = NEWID ()
		INSERT INTO [dbo].[MAS_Customers]
			   ([FullName]
			   ,[Phone]
			   ,[Email]
			   ,[IsHost]
			   ,[ApartmentId]
			   ,[AvatarUrl]
			   ,[IsSex]
			   ,birthday
			   ,sysDate
			   ,IsForeign
			   ,CustId
			   
			   )
		 VALUES
			   (@FullName
			   ,@Phone
			   ,@Email
			   ,0
			   ,@ApartmentId
			   ,@AvatarUrl
			   ,@Sex
			   ,convert(date,@Birthday,103)
			   ,getdate()
			   ,@IsForeign
			   ,@CustId
			   )
		
		if @RelationId = 0
			set @RelationId = 13
		INSERT INTO [dbo].[MAS_Apartment_Member]
			   ([ApartmentId]
			   ,[CustId]
			   ,[RegDt]
			   ,RelationId
			   )
		 VALUES
			   (@ApartmentId
			   ,@CustId
			   ,getdate()
			   ,@RelationId
			   )

		end
		ELSE
		begin
			UPDATE [dbo].[MAS_Customers]
			SET 
			    FullName = isnull(@FullName,FullName)
			   --,Phone = isnull(@Phone,Phone)
			   ,Email = isnull(@Email,Email)
			   ,AvatarUrl = isnull(@AvatarUrl,AvatarUrl)
			   ,IsSex = isnull(@Sex,IsSex)
			   ,birthday = case when @Birthday is null then birthday else convert(date,@Birthday,103) end
			   ,IsForeign = @IsForeign
			WHERE CustId = @CustId

			--set @CustomerId = @CustId
		end

		if not exists(select CategoryCd FROM MAS_Category_Customer r 
				where r.CategoryCd = @CategoryCd and r.CustId = @CustId)
			INSERT INTO [dbo].MAS_Category_Customer
					(CategoryCd
					,CustId
					,[CreationTime]
					,userId
					)
			  SELECT @CategoryCd
					,@CustId
					,getdate()
					,@UserID
		--1
		if not (@FaceRecogUrl1 is null or @FaceRecogUrl1 = '') 
			if not exists(select imageId from [MAS_Customer_Image] where custId = @CustId and imagetype = 1)
				INSERT INTO [dbo].[MAS_Customer_Image]
					   ([CustId]
					   ,[imageUrl]
					   ,[Imagetype]
					   ,[IsFace]
					   ,[sysDate])
				 VALUES
					   (@CustId
					   ,@FaceRecogUrl1
					   ,1
					   ,1
					   ,getdate())
			else
				UPDATE [dbo].[MAS_Customer_Image]
				   SET [imageUrl] = @FaceRecogUrl1
					  ,[IsFace] = 1
					  ,[sysDate] = getdate()
				 WHERE custId = @CustId and imagetype = 1
		--2
		if not (@FaceRecogUrl2 is null or @FaceRecogUrl2 = '') 
			if not exists(select imageId from [MAS_Customer_Image] where custId = @CustId and imagetype = 2)
				INSERT INTO [dbo].[MAS_Customer_Image]
					   ([CustId]
					   ,[imageUrl]
					   ,[Imagetype]
					   ,[IsFace]
					   ,[sysDate])
				 VALUES
					   (@CustId
					   ,@FaceRecogUrl2
					   ,2
					   ,1
					   ,getdate())
			else
				UPDATE [dbo].[MAS_Customer_Image]
				   SET [imageUrl] = @FaceRecogUrl2
					  ,[IsFace] = 1
					  ,[sysDate] = getdate()
				 WHERE custId = @CustId and imagetype = 2
	
		--3
		if not (@FaceRecogUrl3 is null or @FaceRecogUrl3 = '') 
			if not exists(select imageId from [MAS_Customer_Image] where custId = @CustId and imagetype = 3)
				INSERT INTO [dbo].[MAS_Customer_Image]
					   ([CustId]
					   ,[imageUrl]
					   ,[Imagetype]
					   ,[IsFace]
					   ,[sysDate])
				 VALUES
					   (@CustId
					   ,@FaceRecogUrl3
					   ,3
					   ,1
					   ,getdate())
			else
				UPDATE [dbo].[MAS_Customer_Image]
				   SET [imageUrl] = @FaceRecogUrl3
					  ,[IsFace] = 1
					  ,[sysDate] = getdate()
				 WHERE custId = @CustId and imagetype = 3
	
		--4
		if not (@FaceRecogUrl4 is null or @FaceRecogUrl4 = '') 
			if not exists(select imageId from [MAS_Customer_Image] where custId = @CustId and imagetype = 4)
				INSERT INTO [dbo].[MAS_Customer_Image]
					   ([CustId]
					   ,[imageUrl]
					   ,[Imagetype]
					   ,[IsFace]
					   ,[sysDate])
				 VALUES
					   (@CustId
					   ,@FaceRecogUrl4
					   ,4
					   ,1
					   ,getdate())
			else
				UPDATE [dbo].[MAS_Customer_Image]
				   SET [imageUrl] = @FaceRecogUrl4
					  ,[IsFace] = 1
					  ,[sysDate] = getdate()
				 WHERE custId = @CustId and imagetype = 4
	
		--5
		if not (@FaceRecogUrl5 is null or @FaceRecogUrl5 = '') 
			if not exists(select imageId from [MAS_Customer_Image] where custId = @CustId and imagetype = 5)
				INSERT INTO [dbo].[MAS_Customer_Image]
					   ([CustId]
					   ,[imageUrl]
					   ,[Imagetype]
					   ,[IsFace]
					   ,[sysDate])
				 VALUES
					   (@CustId
					   ,@FaceRecogUrl5
					   ,5
					   ,1
					   ,getdate())
			else
				UPDATE [dbo].[MAS_Customer_Image]
				   SET [imageUrl] = @FaceRecogUrl5
					  ,[IsFace] = 1
					  ,[sysDate] = getdate()
				 WHERE custId = @CustId and imagetype = 5
	
	
		EXECUTE [dbo].[sp_Hom_Apartment_Member_ByCustId] 
				   @UserId
				  ,@CustId
				  ,@apartmentId
	
		end

	end try
	begin catch
		declare	@ErrorNum				int,
				@ErrorMsg				varchar(200),
				@ErrorProc				varchar(50),

				@SessionID				int,
				@AddlInfo				varchar(max)

		set @ErrorNum					= error_number()
		set @ErrorMsg					= 'sp_Hom_Update_Member_Profile ' + error_message()
		set @ErrorProc					= error_procedure()

		set @AddlInfo					= '@CustId ' + @CustId 

		exec utl_Insert_ErrorLog @ErrorNum, @ErrorMsg, @ErrorProc, 'Member_Profile', 'Insert', @SessionID, @AddlInfo
	end catch