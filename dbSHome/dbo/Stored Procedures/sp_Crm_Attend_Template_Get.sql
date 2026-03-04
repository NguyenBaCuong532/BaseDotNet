




CREATE procedure [dbo].[sp_Crm_Attend_Template_Get]
	@attendCd nvarchar(50),
	@phone nvarchar(30),
	@email nvarchar(200)
as
begin
	declare @valid bit = 1
	declare @messages nvarchar(100) = N'Đăng ký thông tin thành công'
	DECLARE @referralCode nvarchar(20)
	begin try
			
		--	,0 as SendType
		if exists(select * from [CRM_Attend_Track] 
					where (Phone like @Phone or Email like @Email)
						and [attend_cd] like @attendCd)
		begin
			select @ReferralCode = [ReferralCode], @messages = qrcode_url from [CRM_Attend_Track] 
					where (Phone like @Phone or Email like @Email)
						and [attend_cd] like @attendCd
			set @valid = 0
			--set @messages = N'Đăng ký bổ sung thông tin'
		end
		else
		begin
			set @ReferralCode = datediff(second,{d '2020-01-01'},getdate())
			set @valid = 1
			set @messages = null
			--set @messages = N'Đăng ký thông tin mới'
		end

		select @valid as valid
			  ,@messages as [messages]
			  ,@ReferralCode as code

		SELECT [attend_cd]
			  ,[attend_name]
			  ,[attend_desc]
			  ,[reply_subject] as [Subject]
			  ,[reply_contents] --+ case when @valid = 1 then N'Lần đầu'  else N'Cập nhật' end + '<br />'
					as ReplyContents
			  ,[reply_footer] as ReplyContentsFooter
			  ,[reply_by] as SendName
			  ,[reply_bodytype] as BodyType
			  ,[cc_subject]
			  ,[cc_mails] as [To]
			  ,[cc_contents] as Contents
			  ,0 as SendType
			  ,datediff(second,{d '2020-01-01'},getdate()) as remart
		  FROM [dbSHome].[dbo].[CRM_Attend_Category]
		  where [attend_cd] = @attendCd

	end try
	begin catch
		declare	@ErrorNum				int,
				@ErrorMsg				varchar(200),
				@ErrorProc				varchar(50),

				@SessionID				int,
				@AddlInfo				varchar(max)

		set @ErrorNum					= error_number()
		set @ErrorMsg					= 'sp_Crm_Attend_Template_Get ' + error_message()
		set @ErrorProc					= error_procedure()

		set @AddlInfo					= ''
		set @valid = 0
		exec utl_Insert_ErrorLog @ErrorNum, @ErrorMsg, @ErrorProc, 'GetTempMail', 'Get', @SessionID, @AddlInfo
	end catch


	select @valid as valid
		  ,@messages as [messages]
		  ,@ReferralCode as code
end