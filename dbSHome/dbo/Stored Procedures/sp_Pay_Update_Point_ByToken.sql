








CREATE procedure [dbo].[sp_Pay_Update_Point_ByToken]
	@UserID	nvarchar(450),
	@CardToken nvarchar(50)

as
	begin try		
		--declare @oldChang int
		DECLARE @newpoint bigint
		--declare @codeCode nvarchar(30)
		declare @custId nvarchar(50)
		declare @Point int
		declare @OrderInfo nvarchar(200)
		declare @seri nvarchar(30)
		declare @PayType nvarchar(50)
		if exists(select * from UserInfo where userid = @UserID and loginName like 'ssupapp_0123456789%')
		begin
		set @custId = (select top 1 CustId from UserInfo where userid = @UserID)
		select @Point = b.cardValue, @seri = a.CardSerial from WAL_CrdTransactionRecharge a join WAL_CrdTransaction b on a.CrdTransId = b.CrdTransId  where RechargeCode = @CardToken
		set @OrderInfo = N'Nạp điểm từ thẻ ' + @seri
		set @PayType = 'rechargepoint'

		if not exists(SELECT p.PointCd
			 FROM MAS_Points p 
				--inner join UserInfo b on p.CustId = b.CustId 
			 WHERE p.CustId = @custId
			 )
			BEGIN
				set @newpoint = CAST(RAND(CHECKSUM(NEWID())) * 1000000000 as INT)
				WHILE exists(select pointCd from [MAS_Points] where PointCd = @newpoint)
				BEGIN
					set @newpoint = CAST(RAND(CHECKSUM(NEWID())) * 1000000000 as INT)
				END
					INSERT INTO [dbo].[MAS_Points]
						([PointCd]
						,[PointType]
						,[CustId]
						,[CurrPoint]
						,[LastDt])
					VALUES(
						 @newpoint
						,0
						,@custId
						,0
						,getdate()
						)
			END
		IF not exists(select PointTranId from WAL_PointOrder where Ref_No = @CardToken)
		BEGIN

			INSERT INTO [dbo].WAL_PointOrder
				   ([PointTranId]
				   ,[PointCd]
				   ,[TransNo]
				   ,[Ref_No]
				   ,[TranType]
				   ,[OrderInfo]
				   ,OrderAmount
				   ,[CreditPoint]
				   ,[Point]
				   ,[TranDt]
				   ,ServiceKey
				   ,PosCd
				   ,[CurrPoint]
				   )
			 SELECT
				    NEWID()
				   ,p.PointCd
				   ,@seri
				   ,@CardToken
				   ,@PayType
				   ,@OrderInfo
				   ,0
				   ,0
				   ,@Point
				   ,getdate()
				   ,''
				   ,''
				   ,[CurrPoint]
			 FROM MAS_Points p 
			 WHERE CustId = @custId
			 
			 UPDATE p
			   SET [CurrPoint] = CurrPoint+@Point
				  ,[LastDt] = getdate()
				FROM [MAS_Points] p
			 WHERE p.CustId = @custId

			 UPDATE [dbo].[WAL_CrdTransactionRecharge]
			   SET [IsRec] = 1
			 WHERE RechargeCode = @CardToken

			 SELECT [PointTranId]
				  ,a.[PointCd]
				  ,[TranType]
				  ,[TransNo] as CardSerial
				  ,[Ref_No] as CardToken
				  ,[OrderAmount]
				  ,[CreditPoint]
				  ,[Point]
				  ,p.[CurrPoint]
				  ,[TranDt]
				  ,[OrderInfo] as Remark
				  ,[ServiceKey]
				  ,[PosCd]
			  FROM [WAL_PointOrder] a
			  join [MAS_Points] p on a.PointCd = p.PointCd 
			  WHERE [TransNo] = @seri
		END 
		

		END
	end try
	begin catch
		declare	@ErrorNum				int,
				@ErrorMsg				varchar(200),
				@ErrorProc				varchar(50),

				@SessionID				int,
				@AddlInfo				varchar(max)

		set @ErrorNum					= error_number()
		set @ErrorMsg					= 'sp_Pay_Insert_Wallet_CardOrder ' + error_message()
		set @ErrorProc					= error_procedure()

		set @AddlInfo					= '@Point: ' + cast(@Point as varchar)  + ' @seri: ' + @seri

		exec utl_Insert_ErrorLog @ErrorNum, @ErrorMsg, @ErrorProc, 'SCard', 'Insert', @SessionID, @AddlInfo
	end catch