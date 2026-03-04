


CREATE procedure [dbo].[sp_Hom_Apartment_Fee_Set]
	@UserID			nvarchar(450),
	@ApartmentId	bigint,
	@IsFeeStart		bit,
	@FeeStart		nvarchar(10),
	@IsFree			bit,
	@FreeMonth		int,
	@FreeToDate		nvarchar(10),
	@FeeNote		nvarchar(200),
	@IsReceived		bit,
	@ReceiveDate	nvarchar(10),
	@DebitAmt		decimal(18,0),
	@WaterwayArea	float
as
	begin try	
		declare @valid bit = 1
		declare @messages nvarchar(100) = N'Cập nhật thành công'	

		if @IsFeeStart = 1
			begin
				INSERT INTO [dbo].[MAS_Apartments_Save]
				   ([ApartmentId]
				   ,[RoomCode]
				   ,[Cif_No]
				   ,[UserLogin]
				   ,[FamilyImageUrl]
				   ,[StartDt]
				   ,[EndDt]
				   ,[IsClose]
				   ,[CloseDt]
				   ,[IsLock]
				   ,[IsReceived]
				   ,[ReceiveDt]
				   ,[IsRent]
				   ,[lastReceived]
				   ,[FeeStart]
				   ,[IsFree]
				   ,[FeeNote]
				   ,[numFreeMonth]
				   ,[AccrualLastDt]
				   ,[PayLastDt]
				   ,[projectCd]
				   ,[buildingCd]
				   ,[isMain]
				   ,[WaterwayArea]
				   ,[isFeeStart]
				   ,[CurrBal]
				   ,[isLinkApp]
				   ,[DebitAmt]
				   ,[FreeToDt]
				   --,[ContractRemark]
				   --,[ContractDt]
				   ,[SaveDt]
				   ,[saveKey]
				   ,[saveBy])
				SELECT [ApartmentId]
				  ,[RoomCode]
				  ,[Cif_No]
				  ,[UserLogin]
				  ,[FamilyImageUrl]
				  ,[StartDt]
				  ,[EndDt]
				  ,[IsClose]
				  ,[CloseDt]
				  ,[IsLock]
				  ,[IsReceived]
				  ,[ReceiveDt]
				  ,[IsRent]
				  ,[lastReceived]
				  ,[FeeStart]
				  ,[IsFree]
				  ,[FeeNote]
				  ,[numFreeMonth]
				  ,[AccrualLastDt]
				  ,[PayLastDt]
				  ,[projectCd]
				  ,[buildingCd]
				  ,[isMain]
				  ,[WaterwayArea]
				  ,[isFeeStart]
				  ,[CurrBal]
				  ,[isLinkApp]
				  ,[DebitAmt]
				  ,[FreeToDt]
				  ,getdate()
				  ,'SetupFee'
				  ,@UserID
			  FROM [dbo].[MAS_Apartments]
			  WHERE ApartmentId = @ApartmentId

				UPDATE t1
			SET  IsFeeStart = @IsFeeStart
				,FeeStart = convert(datetime,isnull(@FeeStart,@ReceiveDate),103)
				,IsFree = @IsFree
				,numFreeMonth = @FreeMonth
				,FreeToDt = case when @IsFree = 1 then dateadd(month,@freeMonth,convert(datetime,isnull(@FeeStart,@ReceiveDate),103)) else convert(datetime,isnull(@FeeStart,@ReceiveDate),103) end--convert(datetime,@FreeToDate,103)
				,FeeNote = @FeeNote
				,IsReceived = @IsReceived
				,ReceiveDt = convert(datetime,@ReceiveDate,103)
				,lastReceived = null
				,DebitAmt = @DebitAmt
				,WaterwayArea = isnull(@WaterwayArea,WaterwayArea)
			FROM MAS_Apartments t1
			WHERE t1.ApartmentId = @ApartmentId
			--exec utl_Insert_ErrorLog @UserID, @ApartmentId, '', 'UpdateBy', 'MAS_Apartments', '', N'Lưu thông người tin cập nhật phí dịch vụ'
			end
		else
		begin
			set @Valid = 0
			set @Messages = N'Yêu cầu phải cập nhật bắt đầu tính phí!' 
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
		set @ErrorMsg					= 'sp_Hom_Update_Apartment_Fee ' + error_message()
		set @ErrorProc					= error_procedure()

		set @AddlInfo					= '@UserID ' + @UserID + ' @WaterwayArea' + @WaterwayArea

		exec utl_Insert_ErrorLog @ErrorNum, @ErrorMsg, @ErrorProc, 'ApartmentFee', 'Update', @SessionID, @AddlInfo
	end catch