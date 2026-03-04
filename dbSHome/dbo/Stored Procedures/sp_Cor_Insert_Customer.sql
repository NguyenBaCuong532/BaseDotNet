




CREATE procedure [dbo].[sp_Cor_Insert_Customer]
	@UserID	nvarchar(450),
	@CustId	nvarchar(50),
	@FullName nvarchar(250),
	@AvatarUrl nvarchar(250),
	@Phone nvarchar(30),	
	@Email nvarchar(150),
	@IsSex bit,
	@Birthday nvarchar(10),
	@Address nvarchar(250),
	@ProvinceCd nvarchar(50),
	@IsForeign bit,
	@CountryCd nvarchar(50),
	@PassNo nvarchar(50),
	@PassDate nvarchar(20),
	@PassPlace nvarchar(100),
	@Categories nvarchar(max) = null,
	@ClientId nvarchar(100) 
as
	begin try		
		declare @tbCats TABLE 
		(
			CategoryCd [nvarchar](50) null
		)
		if @Categories is null or @Categories = ''
			INSERT INTO @tbCats SELECT top 1 CategoryCd FROM MAS_Category_User WHERE UserId = @UserID
		else
			INSERT INTO @tbCats SELECT [part] FROM [dbo].[SplitString](@Categories,',')

		INSERT INTO @tbCats
		select CategoryCd from PAR_AppClient p
		Where ClientId = @ClientId and CategoryCd is not null
			and not exists(select CategoryCd FROM @tbCats r where r.CategoryCd = p.CategoryCd)

		if @custId is null or @custId = '' or not exists(select CustId from [MAS_Customers] where CustId = @custId)
		begin
			set @custId = newid()
	
			INSERT INTO [dbo].[MAS_Customers]
				   (CustId
				   ,[FullName]
				   ,[Phone]
				   ,[Email]
				   ,[AvatarUrl]
				   ,[IsSex]
				   ,birthday
				   ,ProvinceCd
				   ,IsForeign
				   ,CountryCd
				   ,Pass_No
				   ,Pass_Dt
				   ,Pass_Plc
				   ,sysDate
				   ,[Address]
				   )
			 VALUES
				   (@custId
				   ,@FullName
				   ,@Phone
				   ,@Email
				   ,@AvatarUrl
				   ,@IsSex
				   ,convert(date,@Birthday,103)
				   ,@ProvinceCd
				   ,@IsForeign 
				   ,@CountryCd
				   ,@PassNo
				   ,convert(datetime,@PassDate ,103)
				   ,@PassPlace
				   ,getdate()
				   ,@Address
				   )

		end
		ELSE
		begin
			UPDATE t 
			SET 
			    FullName = isnull(@FullName,FullName)
			   ,Phone = isnull(@Phone,Phone)
			   ,Email = isnull(@Email,Email)
			   ,AvatarUrl = isnull(@AvatarUrl,AvatarUrl)
			   ,IsSex = isnull(@IsSex,IsSex)
			   ,birthday = case when @Birthday is null then birthday else convert(date,@Birthday,103) end
			   ,[Address] = isnull(@Address,[Address])
			   ,ProvinceCd = isnull(@ProvinceCd,ProvinceCd)
			   ,IsForeign = isnull(@IsForeign,IsForeign)
			   ,CountryCd = isnull(@CountryCd,CountryCd)
			   ,Pass_No = isnull(@PassNo,Pass_No)
			   ,Pass_Dt = convert(datetime,@PassDate,103)
			   ,Pass_Plc = isnull(@PassPlace,Pass_Plc)
			FROM [MAS_Customers] t 
			WHERE t.CustId  = @CustId 
		end

		INSERT INTO [dbo].MAS_Category_Customer
				(CategoryCd
				,CustId
				,[CreationTime]
				,userId
				)
		  SELECT a.CategoryCd
				,@CustId
				,getdate()
				,@UserID
		FROM @tbCats a 
			inner join MAS_Category c on a.CategoryCd = c.CategoryCd 
		WHERE not exists(select CategoryCd FROM MAS_Category_Customer r 
				where r.CategoryCd = a.CategoryCd and r.CustId = @CustId)

		exec sp_Cor_Get_Customer_ByCustId null, @CustId

	end try
	begin catch
		declare	@ErrorNum				int,
				@ErrorMsg				varchar(200),
				@ErrorProc				varchar(50),

				@SessionID				int,
				@AddlInfo				varchar(max)

		set @ErrorNum					= error_number()
		set @ErrorMsg					= 'sp_Insert_Customer ' + error_message()
		set @ErrorProc					= error_procedure()

		set @AddlInfo					= '@User ' + @UserID 

		exec utl_Insert_ErrorLog @ErrorNum, @ErrorMsg, @ErrorProc, 'Customer', 'Insert', @SessionID, @AddlInfo
	end catch