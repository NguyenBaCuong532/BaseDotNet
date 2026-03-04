







CREATE procedure [dbo].[sp_Pay_Point_Transaction_Del]
	@userId nvarchar(450),
	@ref_no	nvarchar(100)	
	
as
	begin try	
		declare @valid bit = 1
		DECLARE @messages nvarchar(150)
		DECLARE @PointCd nvarchar(50)
		DECLARE @Point int
		DECLARE @CreditPoint int

		if not exists(select PointTranId from [WAL_PointOrder] where Ref_No = @ref_no)
		begin
			set @valid = 0
			set @messages = N'Không tìm thấy giao dịch'
		end
		else if exists(select PointTranId from [WAL_PointOrder] where Ref_No = @ref_no and dateadd(day,30,TranDt) <= getdate())
		begin
			set @valid = 0
			set @messages = N'Giao dịch quá hạn hóa! (chỉ cho phép Xóa trong vòng 30 ngày)'
		end
		else if exists(select PointTranId from [WAL_PointOrder] where Ref_No = @ref_no + '-1')
		begin
			set @valid = 0
			set @messages = N'Giao dịch đã thực hiện hủy không cho phép xóa'
		end
		else
		begin		
		  SELECT @PointCd = PointCd
				,@CreditPoint = [CreditPoint]
			    ,@Point = [Point]
		  FROM [dbSHome].[dbo].[WAL_PointOrder]
		  where Ref_No = @ref_no

			INSERT INTO [dbo].[WAL_PointOrder_H]
			   ([PointTranId]
			   ,[PointCd]
			   ,[TranType]
			   ,[TransNo]
			   ,[Ref_No]
			   ,[OrderAmount]
			   ,[CreditPoint]
			   ,[Point]
			   ,[CurrPoint]
			   ,[TranDt]
			   ,[OrderInfo]
			   ,[ServiceKey]
			   ,[PosCd]
			   ,[CltId]
			   ,[CltIp]
			   ,[SaveDt]
			   ,SaveBy 
			   )
		SELECT [PointTranId]
			  ,[PointCd]
			  ,[TranType]
			  ,[TransNo]
			  ,[Ref_No]
			  ,[OrderAmount]
			  ,[CreditPoint]
			  ,[Point]
			  ,[CurrPoint]
			  ,[TranDt]
			  ,[OrderInfo]
			  ,[ServiceKey]
			  ,[PosCd]
			  ,[CltId]
			  ,[CltIp]
			  ,getdate()
			  ,@userId
		  FROM [dbSHome].[dbo].[WAL_PointOrder]
		  where Ref_No = @ref_no

			DELETE FROM [dbo].[WAL_PointOrder]
			 where Ref_No = @ref_no

			UPDATE p
			 SET [CurrPoint] = CurrPoint-@Point+@CreditPoint
				,[LastDt] = getdate()
			FROM [MAS_Points] p
			WHERE p.PointCd = @PointCd
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
		set @ErrorMsg					= 'sp_Pay_Point_Transaction_Del' + error_message()
		set @ErrorProc					= error_procedure()

		set @AddlInfo					= '@userId ' + @userId

		exec utl_Insert_ErrorLog @ErrorNum, @ErrorMsg, @ErrorProc, 'RechargeLink', 'DEL', @SessionID, @AddlInfo
	end catch