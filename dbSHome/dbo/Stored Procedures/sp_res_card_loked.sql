CREATE PROCEDURE [dbo].[sp_res_card_loked]
	@UserID	nvarchar(450) = NULL,
	@CardCd nvarchar(50),
	@Status int = 1,
	@Reason nvarchar(45),
	@IsHardLock bit
AS
BEGIN TRY
	declare @valid bit = 0, @messages nvarchar(250)

	set @Status = isnull(@Status,1)
		if @Status = 1
		begin
		     UPDATE t1
				SET  Card_St = 3
					,CloseDate	= getdate()
					,CloseBy	= @UserID
			 FROM MAS_Cards t1
			 WHERE t1.CardCd = @CardCd

			 UPDATE t1
				SET [Status] = 2
			FROM [MAS_Requests] t1 INNER JOIN MAS_Cards t2 on t1.RequestId = t2.RequestId 
			WHERE CardCd = @CardCd

			INSERT INTO [dbo].[MAS_Card_H]
				   ([CardId]
				   ,[CardCd]
				   ,[CardTypeId]
				   ,[ImageUrl]
				   ,[IssueDate]
				   ,[ExpireDate]
				   ,[CustId]
				   ,[Card_St]
				   ,[IsVip]
				   ,[CardName]
				   ,[IsDaily]
				   ,[IsClose]
				   ,[CloseDate]
				   ,[RequestId]
				   ,[ApartmentId]
				   ,[ProjectCd]
				   ,[VehicleTypeId]
				   ,[StarLevel]
				   ,[IsGuest]
				   ,[SaveDate]
				   ,[SaveId]
				   ,[isVehicle]
				   ,[isCredit]
				   ,[partner_id]
				   ,[created_by]
				   ,[CloseBy]
				   ,[Reason]
				   ,[IsHardLock])

				SELECT 
					   CardId
					   ,CardCd
					   ,CardTypeId
					   ,ImageUrl
					   ,IssueDate
					   ,ExpireDate
					   ,CustId
					   ,Card_St
					   ,IsVip
					   ,CardName
					   ,IsDaily
					   ,IsClose
					   ,CloseDate
					   ,RequestId
					   ,ApartmentId
					   ,ProjectCd
					   ,VehicleTypeId
					   ,StarLevel
					   ,IsGuest
					   ,GETDATE()
					   ,@UserId
					   ,isVehicle
					   ,isCredit
					   ,partner_id
					   ,created_by
					   ,CloseBy
					   ,@Reason
					   ,@IsHardLock
			FROM MAS_Cards c
			WHERE c.CardCd = @CardCd

			UPDATE t1
				SET [Status] = 3
				   ,locked_dt = getdate()
			FROM MAS_CardVehicle t1 INNER JOIN MAS_Cards t2 on t1.CardId = t2.CardId 
			WHERE CardCd = @CardCd

			UPDATE t
			   SET [VehicleNum] = t.VehicleNum - 1
			FROM [dbo].[MAS_CardVehicle] t join [dbo].[MAS_CardVehicle] a on t.ApartmentId = a.ApartmentId and t.VehicleTypeId = a.VehicleTypeId 
			  and t.VehicleNum > a.VehicleNum 
			WHERE t.[Status] = 1
				and exists(select cardId from MAS_Cards where CardCd = @CardCd and CardId = t.CardId) 
			--
			SET @valid = 1
			SET @messages = N'Khóa thẻ thành công'
		end
		else
		begin
				 
			UPDATE t1
				SET Card_St = 1
			 FROM MAS_Cards t1
			 WHERE t1.CardCd = @CardCd

			 UPDATE t1
				SET [Status] = 1
			FROM [MAS_Requests] t1 INNER JOIN MAS_Cards t2 on t1.RequestId = t2.RequestId 
			WHERE CardCd = @CardCd

			UPDATE t1
				SET [Status] = 1
				   ,locked_dt = null
			FROM MAS_CardVehicle t1 INNER JOIN MAS_Cards t2 on t1.CardId = t2.CardId 
			WHERE CardCd = @CardCd

			INSERT INTO [dbo].[MAS_Card_H]
				   ([CardId]
				   ,[CardCd]
				   ,[CardTypeId]
				   ,[ImageUrl]
				   ,[IssueDate]
				   ,[ExpireDate]
				   ,[CustId]
				   ,[Card_St]
				   ,[IsVip]
				   ,[CardName]
				   ,[IsDaily]
				   ,[IsClose]
				   ,[CloseDate]
				   ,[RequestId]
				   ,[ApartmentId]
				   ,[ProjectCd]
				   ,[VehicleTypeId]
				   ,[StarLevel]
				   ,[IsGuest]
				   ,[SaveDate]
				   ,[SaveId]
				   ,[isVehicle]
				   ,[isCredit]
				   ,[partner_id]
				   ,[created_by]
				   ,[CloseBy]
				   ,[Reason])

				SELECT 
					   CardId
					   ,CardCd
					   ,CardTypeId
					   ,ImageUrl
					   ,IssueDate
					   ,ExpireDate
					   ,CustId
					   ,Card_St
					   ,IsVip
					   ,CardName
					   ,IsDaily
					   ,IsClose
					   ,CloseDate
					   ,RequestId
					   ,ApartmentId
					   ,ProjectCd
					   ,VehicleTypeId
					   ,StarLevel
					   ,IsGuest
					   ,GETDATE()
					   ,@UserId
					   ,isVehicle
					   ,isCredit
					   ,partner_id
					   ,created_by
					   ,CloseBy
					   ,@Reason
			FROM MAS_Cards c
			WHERE c.CardCd = @CardCd
			--
			SET @valid = 1
			SET @messages = N'Mở thẻ thành công'
		end
	
	--
	FINAL:
		SELECT @valid valid, @messages as [messages]
END TRY
BEGIN CATCH
	SELECT @messages AS [messages]
	DECLARE	@ErrorNum				int,
			@ErrorMsg				varchar(200),
			@ErrorProc				varchar(50),

			@SessionID				int,
			@AddlInfo				varchar(max)

	set @ErrorNum					= error_number()
	set @ErrorMsg					= 'sp_res_card_loked' + error_message()
	set @ErrorProc					= error_procedure()

	set @AddlInfo					= '@Userid'  + @UserId

	exec utl_ErrorLog_Set @ErrorNum, @ErrorMsg, @ErrorProc, 'card', 'SET', @SessionID, @AddlInfo
end catch