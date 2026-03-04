CREATE procedure [dbo].[sp_Hom_Service_Receivable_Del]
	@userId		nvarchar(450),
	@receiveId	bigint	
as
	begin try
		declare @valid bit = 1
		declare @messages nvarchar(200)

		--declare @errmessage nvarchar(100)
		--set @errmessage = 'This Receivable: ' + cast(@receiveId as varchar) + ' is Receipted!'
		if not exists (select receiveid from MAS_Service_Receipts where ReceiveId = @receiveId)
		begin
			UPDATE t
			   SET AccrualLastDt = b.fromDt
			      --,DebitAmt = t.DebitAmt - (- a.PaidAmt)
				  ,lastReceived = b.fromDt
			FROM MAS_Apartments t
				join MAS_Service_ReceiveEntry a on a.ApartmentId = t.ApartmentId
				left join MAS_Service_Receivable b on a.ReceiveId = b.ReceiveId
			 WHERE  a.ReceiveId = @receiveId 
				and b.ServiceTypeId = 1 
				and a.isExpected = 1

			 UPDATE t
			   --SET t.lastReceivable = b.fromDt (duongvt)
				  -- ,EndTime = b.fromDt
				  SET t.lastReceivable = t.endTime_Tmp
				   ,EndTime = t.endTime_Tmp
			FROM MAS_CardVehicle t
			 join MAS_Service_Receivable b on t.CardVehicleId = b.srcId
			 WHERE  ReceiveId = @receiveId and b.ServiceTypeId = 2

			 UPDATE t
			   SET lastReceivable = b.fromDt
				  ,IsReceivable = 0
				  --,IsCalculate = 0
			FROM MAS_Service_Living_Tracking t
			 join MAS_Service_Receivable b on t.TrackingId = b.srcId
			 WHERE  b.ReceiveId = @receiveId and b.ServiceTypeId = 3

			delete t
			FROM MAS_Service_Receivable t
			 WHERE  ReceiveId = @receiveId

			delete	trg
			from	MAS_Service_ReceiveEntry trg
			where ReceiveId = @receiveId

			

		end
		else
		begin
            -- Check sendDate
            IF EXISTS (SELECT 1 FROM MAS_Service_ReceiveEntry WHERE ReceiveId = @receiveId AND sendDate IS NOT NULL)
            BEGIN
			    set @valid = 0
			    set @messages = N'Hóa đơn đã gửi thông báo, không cho phép xóa!'
            END
            ELSE
            BEGIN
			    set @valid = 0
			    set @messages = N'Hóa đơn đã được thanh toán, không cho phép xóa!'
            END
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
		set @ErrorMsg					= 'sp_Hom_Delete_Receivable_ById' + error_message()
		set @ErrorProc					= error_procedure()

		set @AddlInfo					= ''

		exec utl_Insert_ErrorLog @ErrorNum, @ErrorMsg, @ErrorProc, 'Receivable', 'DEL', @SessionID, @AddlInfo
	end catch


--select * from MAS_Service_Receivable where  ServiceObject like '%2601%'