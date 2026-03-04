


CREATE procedure [dbo].[sp_Crm_Attend_Submit]
	@attendCd nvarchar(30), 
	@contactName nvarchar(250), 
	@Phone nvarchar(30), 
	@Email nvarchar(150),
	@Note nvarchar(max),
	@Source nvarchar(300),
	@child_name nvarchar(250),
	@child_birthday nvarchar(20),
	@learned_maplebear bit,
	@num_of_attend int,
	@ReferralCode	nvarchar(20),
	@qrcode_url		nvarchar(500)
as
begin
	declare @valid bit = 1
	declare @messages nvarchar(100) = N'Đăng ký thông tin thành công'

	begin try	
	

	if not exists(select * from [CRM_Attend_Track] 
					where (Phone like @Phone or Email like @Email)
						and [attend_cd] like @attendCd
						and (arrived_st is null or arrived_st = 0))
		begin
			INSERT INTO [dbo].[CRM_Attend_Track]
				   ([attend_cd]
				   ,[contactName]
				   ,[Phone]
				   ,[Email]
				   ,[Note]
				   ,[child_name]
				   ,[child_birthday]
				   ,[learned_maplebear]
				   ,[num_of_attend]
				   ,[ReferralCode]
				   ,[qrcode_url]
				   ,[Source]
				   ,[Createdate]
				   )
				 VALUES
					(@attendCd
					,@contactName
					,@Phone
					,@Email
					,@Note
					,@child_name
					,@child_birthday
					,@learned_maplebear
					,@num_of_attend
					,@ReferralCode
					,@qrcode_url
					,@Source
					,getdate()
				   )
		end
	else
	begin
		--select @qrcode_url = qrcode_url from [CRM_Attend_Track] 
		--			where (Phone like @Phone or Email like @Email)
		--				and [attend_cd] like @attendCd
		--				and (arrived_st is null or arrived_st = 0)
		--if not @qrcode_url is null
		
			UPDATE [dbo].[CRM_Attend_Track]
			   SET [contactName] = @contactName
				  ,[Phone] = @Phone
				  ,[Email] = @Email
				  ,[Note] = @Note
				  ,[child_name] = @child_name
				  ,[child_birthday] = @child_birthday
				  ,[learned_maplebear] = @learned_maplebear
				  ,[num_of_attend] = @num_of_attend
				  ,[Source] = @Source
				  ,qrcode_url = isnull(@qrcode_url,qrcode_url)
			 WHERE (Phone like @Phone or Email like @Email)
				and [attend_cd] like @attendCd
					and (arrived_st is null or arrived_st = 0)

		set @valid = 0
		set @messages = N'Bạn đã đăng ký thông tin'
	end

	end try
	begin catch
		declare	@ErrorNum				int,
				@ErrorMsg				varchar(200),
				@ErrorProc				varchar(50),

				@SessionID				int,
				@AddlInfo				varchar(max)

		set @ErrorNum					= error_number()
		set @ErrorMsg					= 'sp_Crm_Attend_Submit ' + error_message()
		set @ErrorProc					= error_procedure()

		set @AddlInfo					= '@Phone'  + @Phone + '@Email' + @Email
		set @valid = 0
		set @messages = N'Đăng ký không thành công'

		exec utl_Insert_ErrorLog @ErrorNum, @ErrorMsg, @ErrorProc, 'Attend_Submit', 'Set', @SessionID, @AddlInfo
	end catch


	select @valid as valid
		  ,@messages as [messages]
		  ,@qrcode_url as code
end