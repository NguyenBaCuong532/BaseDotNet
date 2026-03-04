









CREATE procedure [dbo].[sp_Crm_Card_Set]
	@UserId	nvarchar(450),
	@CustId   nvarchar(255),
	@CardCd  nvarchar(50),
	@IssueDate nvarchar(10), 
	@ExpireDate nvarchar(10),
	@CardTypeId  int,
	@IsVip bit
as 

	begin try 
	declare @valid bit = 1
	declare @messages nvarchar(100)

	if not exists(select CustId from Mas_Customers where CustId = @CustId)
	 begin
		set @valid = 0
		set @messages = N'Không tìm thấy khách hàng!'
		goto FINAL
	 end

	 --if not exists(select CustId from CRM_Customer where CustId = @CustId)
		--INSERT INTO [dbo].[CRM_Customer]
		--	   ([custId]
		--	   ,[group_id]
		--	   ,[note]
		--	   ,[cust_rank]
		--	   ,[create_by]
		--	   ,[create_dt]
		--	   ,[modify_dt]
		--	   ,[clientId]
		--	   ,[categoryCd])
		--select custId
		--	  ,null
		--	  ,null
		--	  ,null
		--	  ,@UserId
		--	  ,getdate()
		--	  ,null
		--	  ,null
		--	  ,null
		-- from Mas_Customers where CustId = @CustId

	 if not exists(select CustId from CRM_Customer where CustId = @CustId)
	 begin
		set @valid = 0
		set @messages = N'Không cấp đúng đối tượng khách hàng!'
	 end
	 else
	 if exists(select cardCd from CRM_Card where CustId = @CustId and [Status] = 1)
	 begin
		set @valid = 0
		set @messages = N'Đã cấp thẻ, đang được sử dụng, không cấp thêm!'
	 end
	 else if not exists(select cardCd from CRM_Card where CardCd = @CardCd)
		INSERT INTO [dbo].[CRM_Card]
			   ([CardCd]
			   ,[CustId]
			   ,[CreatedTime]
			   ,[CreatedBy]
			   ,[UpdatedTime]
			   ,[UpdatedBy]
			   ,[ExpireDate]
			   ,[CardTypeId]
			   ,[IssueDate]
			   ,[Status]
			   ,[CardName]
			   ,[IsVip])
		 VALUES
			   (@CardCd
			   ,@CustId 
			   ,SYSDATETIME()
			   ,@UserId
			   ,SYSDATETIME()
			   ,@UserId
			   ,null
			   ,5
			   ,GETDATE()
			   ,1
			   ,N'Khách hàng thân thiết'
			   ,0)
		else
		begin
			set @valid = 0
			set @messages = N'Đã có mã số thẻ!'
		end
		
		FINAL:
		select @valid as valid
		      ,@messages as [messages] 
	
	end try
	begin catch
		declare	@ErrorNum				int,
				@ErrorMsg				varchar(200),
				@ErrorProc				varchar(50),

				@SessionID				int,
				@AddlInfo				varchar(max)

		set @ErrorNum					= error_number()
		set @ErrorMsg					= 'sp_Crm_Card_Set ' + error_message()
		set @ErrorProc					= error_procedure()

		set @AddlInfo					= '@CardCd ' + cast(@CardCd as nvarchar)

		exec utl_Insert_ErrorLog @ErrorNum, @ErrorMsg, @ErrorProc, 'Crm_Card', 'Set', @SessionID, @AddlInfo
	end catch