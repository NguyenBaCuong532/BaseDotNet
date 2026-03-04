









CREATE procedure [dbo].[sp_Crm_Opportunity_Set]
	@UserId	nvarchar(450),
	@Id		bigint,
	@thread_id nvarchar(150),
	@opp_cd nvarchar(50),
	@projectCd nvarchar(50), 
	@fullName nvarchar(200),
	@phone nvarchar(25),
	@email nvarchar(150),
	@address nvarchar(250),
	@birthday int,
	@sex int,
	@need_finacial decimal(18,0),
	@need_offer nvarchar(100),
	@need_prod nvarchar(100),
	@need_loan int,
	@source nvarchar(50),
	@potenial_level  int,
	@reviews	nvarchar(400)
	as 

	begin try 
		declare @valid bit = 1
		declare @messages nvarchar(100)
		--if @birthday = 'Invalid date'
		--	set @birthday = '' 

		set @projectCd		= isnull(@projectCd,'')
		set @opp_cd			= isnull(@opp_cd,'OPP' + cast((select count(id)+1 from [CRM_Opportunity]) as varchar))

		if @phone is null --and @email is null
		begin
			set @valid = 0
			set @messages = N'Không có thông tin liên hệ'  
		end
		else if @fullName is null
		begin
			set @valid = 0
			set @messages = N'Không có tên khách hàng'  
		end
		else
		if not exists(select id from [CRM_Opportunity] where id = @id or opp_cd = @opp_cd)
		begin
			if @phone is not null and exists(select id from [CRM_Opportunity] where phone = @phone)
			begin
				set @valid = 0
				set @messages = N'Số điện thoại này đã tồn tại ' + @phone 
			end
			else
			begin
			if @opp_cd = N'Tự động'
				set @opp_cd = 'C' + cast(datediff(second,{d '1970-01-01'},getdate()) as varchar(50))

			INSERT INTO [dbo].[CRM_Opportunity]
				   ([opp_cd]
				   ,[projectCd]
				   ,[fullName]
				   ,[phone]
				   ,[email]
				   ,[address]
				   ,[birthday]
				   ,[sex]
				   ,[need_finacial]
				   ,[need_offer]
				   ,[need_prod]
				   ,[need_loan]
				   ,[source]
				   ,[potenial_level]
				   ,[opp_st]
				   ,[opp_lst]
				   ,[create_by]
				   ,[create_dt]
				   ,thread_id
				   ,reviews
				   )
			 VALUES
				   (@opp_cd
				   ,@projectCd
				   ,@fullName
				   ,@phone
				   ,@email
				   ,@address
				   ,@birthday
				   ,@sex
				   ,@need_finacial
				   ,@need_offer
				   ,@need_prod
				   ,@need_loan
				   ,@source
				   ,@potenial_level
				   ,0
				   ,null
				   ,@UserId
				   ,getdate()
				   ,@thread_id
				   ,@reviews
				   )
			set @id = @@IDENTITY
			end
		end
		else
		if not exists(select id from [CRM_Opportunity] o where id = @id or opp_cd = @opp_cd and (create_by = @UserId or exists(select id from CRM_Opportunity_Assign a where a.opp_Id = o.id and a.userId = @UserId and a.assignRole < 3)))
		begin
			
			set @valid = 0
			set @messages = N'Thông tin đã tồn tại!, Bạn chưa đc phân quyền để sửa (Quyền quản lý của [' + (select top 1 userlogin from MAS_Users u join [CRM_Opportunity] o on u.UserId = o.create_by) + '])'
		end
		else
			UPDATE [dbo].[CRM_Opportunity]
			   SET [opp_cd] = @opp_cd
				  ,[projectCd] = @projectCd
				  ,[fullName] = @fullName
				  ,[phone] = @phone
				  ,[email] = @email
				  ,[address] = @address
				  ,[birthday] = @birthday
				  ,[sex] = @sex
				  ,[need_finacial] = @need_finacial
				  ,[need_offer] = @need_offer
				  ,[need_prod] = @need_prod
				  ,[need_loan] = @need_loan
				  ,[source] = @source
				  ,[potenial_level] = @potenial_level
				  ,thread_id = @thread_id
				  ,[reviews] = @reviews
				  --,[create_by] = @create_by
				  --,[create_dt] = @create_dt
			 WHERE id = @id or opp_cd = @opp_cd

		select @valid as valid
			  ,@messages as [messages]
			  ,@id as work_st

	end try
	begin catch
		declare	@ErrorNum				int,
				@ErrorMsg				varchar(200),
				@ErrorProc				varchar(50),

				@SessionID				int,
				@AddlInfo				varchar(max)

		set @ErrorNum					= error_number()
		set @ErrorMsg					= 'sp_Crm_Opportunity_Set ' + error_message()
		set @ErrorProc					= error_procedure()

		set @AddlInfo					= '@phone ' + cast(@phone as nvarchar)

		exec utl_Insert_ErrorLog @ErrorNum, @ErrorMsg, @ErrorProc, 'Opportunity', 'Set', @SessionID, @AddlInfo
	end catch