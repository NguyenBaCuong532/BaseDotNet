






create procedure [dbo].[sp_resident_employee_vehicle_approve]
	@UserID	nvarchar(450),
	@CardVehicleId int,
	@CardCd nvarchar(10),
	@EndTime nvarchar(50)

as
begin
	declare @valid bit = 1
	declare @messages nvarchar(100) = 'Cập nhật thành công'	

	begin try	
	declare @cardId int
	declare @CustId nvarchar(50)
	declare @VehicleTypeId int

	--declare @errmessage nvarchar(100)
	--set @errmessage = 'This Vehicle: ' + @UserID + ' is not exists or used!'
	if @EndTime = ''
		set @EndTime = null
	
	select @CustId = CustId, @VehicleTypeId = VehicleTypeId from [mas_CardVehicle] WHERE CardVehicleId = @CardVehicleId and [Status] = 0 --and VehicleTypeId > 1

	if @VehicleTypeId > 1 and (not exists(select top 1 1 from mas_Cards where CardCd = @CardCd)) or @CustId is null
	begin
		set @messages = 'Require card code!' + @CardCd + ' or cust not exists!'
		set @valid = 0
		goto FINAL
	end
	
	if @VehicleTypeId > 1 and exists((select cardId from mas_Cards a where a.CardCd = @CardCd and a.CustId <> @CustId))
	begin
		set @messages = 'Th card code!' + @CardCd + ' is used'
		set @valid = 0
		goto FINAL

	end
	if @VehicleTypeId = 1
	begin
		UPDATE [mas_CardVehicle]
			SET [Status] = 1
				--,CardId = @CardId
				,[EndTime] = convert(datetime,@EndTime,103)
				,Auth_id = @UserID
				,Auth_Dt = getdate()
			WHERE CardVehicleId = @CardVehicleId and [Status] = 0
	end
	else
	begin
		--if exists(select * from [HRM_CardVehicle] where CardVehicleId = @CardVehicleId and [Status] = 0 and VehicleTypeId > 1) 
		
		--begin
			--if @CardCd is not null and @CardCd <> '' and not exists((select top 1 cardId from HRM_Cards where CardCd = @CardCd))
			--begin
			--	INSERT INTO [HRM_Cards]
			--		   (
			--			[ApartmentId]
			--		   ,[CardCd]
			--		   ,[IssueDate]
			--		   ,[ExpireDate]
			--		   ,CustId
			--		   ,[CardTypeId]
			--		   ,[ImageUrl]
			--		   ,[Card_St]
			--		   ,IsDaily 
			--		   ,IsVip 
			--		   ,ProjectCd
			--		   )
			--	SELECT 
			--		   0
			--		  ,@CardCd
			--		  ,getdate()
			--		  ,null
			--		  ,@CustId
			--		  ,2
			--		  ,null
			--		  ,1
			--		  ,0
			--		  ,1
			--		  ,''
			--	from HRM_CardBase 
			--	where Code = @CardCd

			--	UPDATE HRM_CardBase Set IsUsed = 1 
			--	WHERE Code = @CardCd 
			
			--end
		
			set @cardId = isnull((select top 1 cardId from mas_Cards where CardCd = @CardCd),
				(select cardId from [mas_CardVehicle] WHERE CardVehicleId = @CardVehicleId and [Status] = 0))
	
			UPDATE [mas_CardVehicle]
				SET [Status] = 1
					,CardId = @CardId
					,[EndTime] = convert(datetime,@EndTime,103)
					,Auth_id = @UserID
					,Auth_Dt = getdate()
				WHERE CardVehicleId = @CardVehicleId and [Status] = 0
		--end
	end
		
	end try
	begin catch
		declare	@ErrorNum				int,
				@ErrorMsg				varchar(200),
				@ErrorProc				varchar(50),

				@SessionID				int,
				@AddlInfo				varchar(max)

		set @ErrorNum					= error_number()
		set @ErrorMsg					= 'sp_hrm_employee_vehicle_approve ' + error_message()
		set @ErrorProc					= error_procedure()

		set @AddlInfo					= '@Cif_no ' + @UserID 
		set @valid = 0
		set @messages = error_message()

		exec utl_Insert_ErrorLog @ErrorNum, @ErrorMsg, @ErrorProc, 'CardVehicleAuth', 'Update', @SessionID, @AddlInfo
	end catch


	FINAL:
	select @valid as valid
		  ,@messages as [messages]


end