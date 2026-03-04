








CREATE procedure [dbo].[sp_Pay_Point_Transaction_Cancel]
	@userId nvarchar(450),
	@ClientId nvarchar(100),
	@ClientIp nvarchar(100),
	@ref_no	nvarchar(100)	
	
as
	begin try	
		declare @valid bit = 1
		DECLARE @messages nvarchar(150)
		DECLARE @PayType nvarchar(50)
		DECLARE @CardNum nvarchar(50)
		DECLARE @newRefNo nvarchar(100)
		DECLARE @OrderInfo nvarchar(450)
		DECLARE @Point int
		DECLARE @CreditPoint int
		DECLARE @OrderAmount int
		DECLARE @ServiceKey nvarchar(50)
		DECLARE @PosCd nvarchar(50)
		DECLARE @roomCode nvarchar(30)

		if not exists(select PointTranId from [WAL_PointOrder] where Ref_No = @ref_no)
		begin
			set @valid = 0
			set @messages = N'Không tìm thấy giao dịch'
		end
		else if exists(select PointTranId from [WAL_PointOrder] where Ref_No = @ref_no and dateadd(day,30,TranDt) <= getdate())
		begin
			set @valid = 0
			set @messages = N'Giao dịch quá hạn hóa! (chỉ cho phép Hủy trong vòng 30 ngày)'
		end
		else if exists(select PointTranId from [WAL_PointOrder] where Ref_No = @ref_no + '-1')
		begin
			set @valid = 0
			set @messages = N'Giao dịch đã thực hiện hủy không cho phép Hủy'
		end
		else
		begin		
		  SELECT @PayType = [TranType]
			  ,@CardNum = [TransNo]
			  ,@OrderAmount = [OrderAmount]
			  ,@CreditPoint = - [CreditPoint]
			  ,@Point = - [Point]
			  ,@OrderInfo = N'Giao dịch hủy'
			  ,@ServiceKey = [ServiceKey]
			  ,@PosCd = [PosCd]
			  ,@roomCode = [roomCode]
		  FROM [dbSHome].[dbo].[WAL_PointOrder]
		  where Ref_No = @ref_no

			if not exists(SELECT Ref_No FROM [dbSHome].[dbo].[WAL_PointOrder]
			where Ref_No = @Ref_No + '-1')
			begin
				set @newRefNo = @Ref_No + '-1'

				EXECUTE [dbo].[sp_Pay_Insert_Wallet_CardOrder] 
					 @UserID
					,@PayType
					,@CardNum
					,@newRefNo
					,@OrderInfo
					,@Point
					,@CreditPoint
					,@OrderAmount
					,@ServiceKey
					,@PosCd
					,@ClientId
					,@ClientIp
					,@roomCode
					,0
			end
			else
			begin
				set @valid = 0
				set @messages = N'Giao dịch đã thực hiện hủy không cho phép Hủy'
			end
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
		set @ErrorMsg					= 'sp_Pay_Point_Transaction_Cancel' + error_message()
		set @ErrorProc					= error_procedure()

		set @AddlInfo					= '@userId ' + @userId

		exec utl_Insert_ErrorLog @ErrorNum, @ErrorMsg, @ErrorProc, 'RechargeLink', 'DEL', @SessionID, @AddlInfo
	end catch