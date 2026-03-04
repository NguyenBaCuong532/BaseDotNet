



CREATE procedure [dbo].[sp_Hom_Apartment_Change_Host]
	@UserID	nvarchar(450),
	@ApartmentId int,
	@CustId nvarchar(50),
	@UserLogin nvarchar(100),
	@ContractRemark nvarchar(300),
	@ContractDate nvarchar(20)
as
	begin try		
		
		INSERT INTO [dbo].[MAS_Apartments_Save]
           ([ApartmentId]
           ,[RoomCode]
           ,[Cif_No]
           ,[FamilyImageUrl]
           ,[StartDt]
           ,[EndDt]
           ,[IsClose]
           ,[CloseDt]
           ,[IsLock]
           ,[IsReceived]
           ,[ReceiveDt]
           ,[IsRent]
           ,[UserLogin]
           ,[lastReceived]
           ,[ContractRemark]
           ,[ContractDt]
           ,[SaveDt]
		   ,[saveKey]
		   ,[saveBy]
		   )
		SELECT [ApartmentId]
			,[RoomCode]
			,[Cif_No]
			,[FamilyImageUrl]
			,[StartDt]
			,[EndDt]
			,[IsClose]
			,[CloseDt]
			,[IsLock]
			,[IsReceived]
			,[ReceiveDt]
			,[IsRent]
			,[UserLogin]
			,[lastReceived]
			,@ContractRemark
			,convert(date,@ContractDate,103)
			,getdate()
			,'ChangeHost'
			,@UserID
		FROM [dbo].[MAS_Apartments]
		WHERE ApartmentId = @ApartmentId

		 UPDATE t1
		   SET  UserLogin = @UserLogin
			   ,Cif_No = (select top 1 Cif_No from MAS_Customers where CustId = @CustId)
		 FROM MAS_Apartments t1 
		 WHERE t1.ApartmentId = @ApartmentId

		 UPDATE t1
		   SET  memberUserId = (select top 1 userId from UserInfo where loginName = @UserLogin)
			   ,member_st = 1
			   ,RelationId = 0
			   ,isNotification = 1
		 FROM MAS_Apartment_Member t1 
		 WHERE t1.ApartmentId = @ApartmentId
			and CustId = @CustId

	end try
	begin catch
		declare	@ErrorNum				int,
				@ErrorMsg				varchar(200),
				@ErrorProc				varchar(50),

				@SessionID				int,
				@AddlInfo				varchar(max)

		set @ErrorNum					= error_number()
		set @ErrorMsg					= 'sp_Hom_Update_Apartment_ChangeHost ' + error_message()
		set @ErrorProc					= error_procedure()

		set @AddlInfo					= '@UserID ' + @UserID 

		exec utl_Insert_ErrorLog @ErrorNum, @ErrorMsg, @ErrorProc, 'ApartmentHost', 'Update', @SessionID, @AddlInfo
	end catch