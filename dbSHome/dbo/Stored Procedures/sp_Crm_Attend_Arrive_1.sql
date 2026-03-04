





CREATE procedure [dbo].[sp_Crm_Attend_Arrive]
	@UserId nvarchar(250),
	@qrcode nvarchar(50)
as
begin
	declare @valid bit = 1
	declare @messages nvarchar(100) = N'Xác nhận thông tin thành công'

	begin try		
		if exists(select * from CRM_Attend_Track where ReferralCode = @qrcode)
			UPDATE [dbo].[CRM_Attend_Track]
			   SET [arrived_st] = 1
				  ,[arrived_dt] = getdate()
				  ,[arrived_id] = @UserId
			 WHERE ReferralCode = @qrcode
				and ([arrived_st] is null or [arrived_st] = 0)


	end try
	begin catch
		declare	@ErrorNum				int,
				@ErrorMsg				varchar(200),
				@ErrorProc				varchar(50),

				@SessionID				int,
				@AddlInfo				varchar(max)

		set @ErrorNum					= error_number()
		set @ErrorMsg					= 'sp_Crm_Attend_Arrive ' + error_message()
		set @ErrorProc					= error_procedure()

		set @AddlInfo					= '@UserID '  
		set @valid = 0
		set @messages = N'Xác nhận không thành công'

		exec utl_Insert_ErrorLog @ErrorNum, @ErrorMsg, @ErrorProc, 'Attend_Arrive', 'Update', @SessionID, @AddlInfo
	end catch


	select @valid as valid
		  ,@messages as [messages]

end