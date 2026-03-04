CREATE procedure [dbo].[sp_Crm_Loyal_Set]
	 @UserID	nvarchar(450)
	,@CustId	nvarchar(50)
	,@FullName nvarchar(250)
	,@AvatarUrl nvarchar(250)
	,@Phone nvarchar(30)
	,@Email nvarchar(150)
	,@IsSex bit
	,@Birthday nvarchar(10)
	,@Address nvarchar(250)
	,@ProvinceCd nvarchar(50)
	--,@IsForeign bit
	,@CountryCd nvarchar(50)
	,@Pass_No nvarchar(50)
	,@Pass_Dt nvarchar(20)
	,@Pass_Plc nvarchar(100)
	--,@Categories nvarchar(max) = null,
	,@clientId nvarchar(100) 
	,@group_id int
	,@note nvarchar(255)
	,@categoryCd nvarchar(50)
	,@base_type int = null

	as
	begin try	
		declare @valid bit = 1
		declare @messages nvarchar(100)
			
		set @CountryCd = isnull(@CountryCd,'VN')

		if not exists(select CustId from [MAS_Customers] where CustId = isnull(@custId,''))
		begin
			--set @custId = newid()
	
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
				   ,case when @CountryCd = 'VN' then 0 else 1 end 
				   ,@CountryCd
				   ,@Pass_No
				   ,convert(datetime,@Pass_Dt ,103)
				   ,@Pass_Plc
				   ,getdate()
				   ,@Address
				   
				   )

				INSERT INTO [dbo].[CRM_Customer]
					([custId]
					,[group_id]
					,[note]
					,[cust_rank]
					,[create_by]
					,[create_dt]
					,[clientId]
					,categoryCd
					,base_type
					)
				VALUES
					(@custId
					,@group_id
					,@note
					,1
					,@UserID
					,getdate()
					,@clientId
					,@categoryCd
					,@base_type
					)

					INSERT INTO [dbo].[MAS_Category_Customer]
						   ([CustId]
						   ,[CategoryCd]
						   ,[CreationTime]
						   
						   ,[userId])
					 VALUES
						   (@CustId
						   ,@CategoryCd
						   ,getdate()						   
						   ,@userId
						   )

		end
		ELSE if exists(select CustId from [CRM_Customer] where CustId = @custId)
		begin
			UPDATE t 
				SET FullName = isnull(@FullName,FullName)
				   ,Phone = isnull(@Phone,Phone)
				   ,Email = isnull(@Email,Email)
				   ,AvatarUrl = isnull(@AvatarUrl,AvatarUrl)
				   ,IsSex = isnull(@IsSex,IsSex)
				   ,birthday = case when @Birthday is null then birthday else convert(date,@Birthday,103) end
				   ,[Address] = isnull(@Address,[Address])
				   ,ProvinceCd = isnull(@ProvinceCd,ProvinceCd)
				   ,IsForeign = case when @CountryCd = 'VN' then 0 else 1 end 
				   ,CountryCd = isnull(@CountryCd,CountryCd)
				   ,Pass_No = isnull(@Pass_No,Pass_No)
				   ,Pass_Dt = convert(datetime,@Pass_Dt,103)
				   ,Pass_Plc = isnull(@Pass_Plc,Pass_Plc)
				   
				FROM [MAS_Customers] t 
				WHERE t.CustId  = @CustId 
		
			UPDATE [dbo].[CRM_Customer]
			   SET [group_id] = @group_id
				  ,[note] = @note
				  ,[categoryCd] = @categoryCd
				  ,[base_type] = @base_type
				  --,[create_dt] = @create_dt
				  ,[modify_dt] = getdate()
			 WHERE CustId  = @CustId 

		end
		else
		begin
			set @valid = 0
			set @messages = N'Không được quyền thay đổi thông tin'
		end

		select @valid as valid
			  ,@messages as [messages]
			  --,0 as work_st

	end try
	begin catch
		declare	@ErrorNum				int,
				@ErrorMsg				varchar(200),
				@ErrorProc				varchar(50),

				@SessionID				int,
				@AddlInfo				varchar(max)

		set @ErrorNum					= error_number()
		set @ErrorMsg					= 'sp_Crm_Loyal_Set ' + error_message()
		set @ErrorProc					= error_procedure()

		set @AddlInfo					= '@Id ' + cast(@UserID as varchar)

		exec utl_Insert_ErrorLog @ErrorNum, @ErrorMsg, @ErrorProc, 'Crm_Loyal', 'SET', @SessionID, @AddlInfo
		select 0 as valid, 'Error' as messages, 0 as work_st
	end catch