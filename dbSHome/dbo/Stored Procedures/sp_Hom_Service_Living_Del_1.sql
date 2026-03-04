




-- exec sp_Hom_Service_Living_Del null,3739
--select * from [MAS_Service_Living_Tracking] where LivingId = 3739
CREATE procedure [dbo].[sp_Hom_Service_Living_Del]
	@userId	nvarchar(450),	
	@livingId	int	
	
as
	begin try
		declare @valid bit = 1
		declare @messages nvarchar(200)
		declare @errmessage nvarchar(100) = 'This Service_Living: ' + cast(@livingId as varchar) + ' is exists!'
		
		if not exists (select TrackingId from [MAS_Service_Living_Tracking] where LivingId = @livingId)
			delete	trg
			from	MAS_Apartment_Service_Living trg
			where LivingId = @livingId
		else
			begin
				set @valid = 0
				set @messages = N'Đã có cập cập nhật dữ liệu, không thể xóa'
				--RAISERROR (@errmessage, -- Message text.
				--	   16, -- Severity.
				--	   1 -- State.
				--	   );
			end

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
		set @ErrorMsg					= 'sp_Hom_Delete_Service_Living_ById' + error_message()
		set @ErrorProc					= error_procedure()

		set @AddlInfo					= ''

		exec utl_Insert_ErrorLog @ErrorNum, @ErrorMsg, @ErrorProc, 'Service_Living', 'DEL', @SessionID, @AddlInfo
	end catch

	select * from utl_Error_Log where TableName = 'Service_Living' order by CreatedDate desc