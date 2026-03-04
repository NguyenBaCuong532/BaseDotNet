



--select * from MAS_Apartments where RoomCode ='S6-2102'




CREATE procedure [dbo].[sp_Hom_Service_Receivable_Bill_Pushed]
	@userId nvarchar(450),
	@receiveId	bigint
as
	begin try
			
			UPDATE t
			   SET IsPush = 1
				  ,push_dt = getdate()
				  ,push_count = isnull(push_count,0)+1
			 FROM MAS_Service_ReceiveEntry t
			 WHERE t.ReceiveId = @receiveId
		
	end try
	begin catch
		declare	@ErrorNum				int,
				@ErrorMsg				varchar(200),
				@ErrorProc				varchar(50),

				@SessionID				int,
				@AddlInfo				varchar(max)

		set @ErrorNum					= error_number()
		set @ErrorMsg					= 'sp_Hom_Service_Receivable_Bill_Pushed' + error_message()
		set @ErrorProc					= error_procedure()

		set @AddlInfo					= ''

		exec utl_Insert_ErrorLog @ErrorNum, @ErrorMsg, @ErrorProc, 'ReceivablePushed', 'Bill', @SessionID, @AddlInfo
	end catch