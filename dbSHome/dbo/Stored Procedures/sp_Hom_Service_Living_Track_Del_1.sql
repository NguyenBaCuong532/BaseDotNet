






CREATE procedure [dbo].[sp_Hom_Service_Living_Track_Del]
	@userId nvarchar(450),
	@TrackingId	bigint	
	
as
	begin try
		declare @valid bit = 1
		declare @messages nvarchar(200)
		declare @errmessage nvarchar(100)
		set @errmessage = 'This Living_racking: ' + cast(@TrackingId as varchar) + ' is Accrual!'
		if not exists (select TrackingId from [MAS_Service_Living_Tracking] where TrackingId = @TrackingId and IsReceivable = 1)
			and not exists(select * from MAS_Service_Receivable where srcId = @TrackingId and ServiceTypeId = 3)
		begin
			UPDATE t
			   SET AccrualToDt = a.fromDt,
				  MeterLastDt = a.FromDt,
				  MeterLastNum = a.FromNum
					
			FROM MAS_Apartment_Service_Living t
			 join [MAS_Service_Living_Tracking] a on a.LivingId = t.LivingId
			 WHERE  TrackingId = @TrackingId 
				and IsReceivable = 0


			delete t
			FROM MAS_Service_Living_CalSheet t
			 WHERE  TrackingId = @TrackingId

			delete	trg
			from	[MAS_Service_Living_Tracking] trg
			where TrackingId = @TrackingId

		end
		else
		begin
			set @valid = 0
			set @messages = N'Chỉ số đo đã được tính dự thu, không thẻ xóa'
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
		set @ErrorMsg					= 'sp_Hom_Delete_Service_Living_Track_ById' + error_message()
		set @ErrorProc					= error_procedure()

		set @AddlInfo					= ''

		exec utl_Insert_ErrorLog @ErrorNum, @ErrorMsg, @ErrorProc, 'LivingTrack', 'DEL', @SessionID, @AddlInfo
	end catch