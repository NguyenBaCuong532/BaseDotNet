



CREATE procedure [dbo].[sp_Hom_Card_Guest_Vehicle_Set]
	@UserID	nvarchar(450),
	@projectCd nvarchar(30),
	@CardVehicleId int,
	
	@CardCd nvarchar(50), 
	@FullName nvarchar(200),	
	@Phone nvarchar(20),
	@VehicleTypeId int = 0,
	@VehicleNo nvarchar(10) = '',
	@VehicleName nvarchar(50) = '',
	@StartTime nvarchar(20) = '',
	@EndTime nvarchar(20),
	@isVehicleNone bit

as
begin
	declare @valid bit = 1
	declare @messages nvarchar(200) = N'Cập nhật thành công'

	begin try	

	declare @CardId int
	declare @CustId nvarchar(50)
	set @CustId = (SELECT top 1 CustId FROM MAS_Customers WHERE Phone = @Phone)
	set @CardId = isnull((SELECT top 1 CardId FROM MAS_Cards WHERE CardCd = @CardCd and Card_St < 3 and CustId = @CustId),0)
	set @projectCd = isnull(@projectCd,(SELECT top 1 ProjectCd FROM MAS_Cards WHERE CardCd = @CardCd and Card_St < 3 and CustId = @CustId))
	
	if @CardVehicleId = 0
		begin
			if @ProjectCd is null or not exists(select * from MAS_Projects where projectCd = @ProjectCd)
			begin
				set @Valid = 0
				set @Messages = N'Chưa chọn dự án!' 
			end
			else if @isVehicleNone = 0 and exists(select * from [MAS_CardVehicle] where VehicleNo like @VehicleNo and [Status] = 1 and isVehicleNone = 0)
			begin
				set @Valid = 0
				set @Messages = N'Đã có đăng ký biển số xe [' + @VehicleNo + N'] trong hệ thống!' 
			end
			else if @isVehicleNone = 1 and @CardId = 0 
			begin
				set @Valid = 0
				set @Messages = N'Cần phải cấp thẻ, hoặc mã thẻ chưa đúng người cấp' 
			end
			else if @VehicleTypeId > 1 and exists(select b.[CardId] FROM MAS_Cards b  join [MAS_CardVehicle] a on a.CardId = b.CardId 
					where b.CardCd = @CardCd and b.Card_St < 3 and b.CustId = @CustId)
			begin
				set @Valid = 0
				set @Messages = N'Mã thẻ đã được cấp cho người khác [' + @CardCd + N']!' 
			end
			else  if @VehicleTypeId > 1 and exists(select a.[CardId] FROM [MAS_CardVehicle] a join MAS_Cards b on a.CardId = b.CardId 
					where b.CardCd = @CardCd and a.[Status] < 3 and a.VehicleTypeId > 1)
			begin
				set @Valid = 0
				set @Messages = N'Không được cấp nhiều dịch vụ vào 1 thẻ [' + @CardCd + N']!' 
			end
			 
			else

			begin
			
				if  exists(select * from MAS_CardBase where Code = @CardCd and (IsUsed = 0 or IsUsed is null)) and not exists(select * from MAS_Cards where CardCd = @CardCd)
				BEGIN
					INSERT INTO [dbo].[MAS_Cards]
						   ([CardCd]
						   ,[IssueDate]
						   ,[Card_St]
						   ,[IsClose]
						   ,[IsDaily]
						   ,[ProjectCd]
						   ,[VehicleTypeId]
						   ,IsVip
						   ,CardTypeId
						   ,IsGuest
						   ,CustId 
						   )
						VALUES
						   (@CardCd
						   ,Getdate()
						   ,1
						   ,0
						   ,0
						   ,@ProjectCd
						   ,@VehicleTypeId
						   ,0
						   ,3
						   ,1
						   ,@CustId
						   )

					   UPDATE MAS_CardBase SET IsUsed = 1 WHERE Code = @CardCd 
				END

				set @CardId = isnull((SELECT top 1 CardId FROM [MAS_Cards] WHERE [CardCd] = @CardCd),0)
				if @ProjectCd is not null
				INSERT INTO [dbo].[MAS_CardVehicle]
						   ([AssignDate]
						   ,[CardId]
						   ,[VehicleNo]
						   ,[VehicleTypeId]
						   ,[VehicleName]
						   ,[StartTime]
						   ,[EndTime]
						   ,[Status]
						   ,[ServiceId]
						   ,CustId
						   ,ProjectCd
						   ,monthlyType
						   ,Mkr_Id 
						   ,Mkr_Dt 
						   )
					 VALUES
						   (getdate()
						   ,@CardId
						   ,@VehicleNo
						   ,@VehicleTypeId
						   ,@VehicleName
						   ,convert(datetime,@StartTime,103)
						   ,convert(datetime,@EndTime,103)
						   ,1
						   ,0
						   ,@CustId
						   ,@projectCd
						   ,2
						   ,@UserID 
						   ,Getdate()
						   )
					else
					begin
						set @Valid = 0
						set @Messages = N'Chưa chọn dự án!' 
					end
				end
			end
			else
			begin
				if @isVehicleNone = 0 and exists(select * from [MAS_CardVehicle] where VehicleNo like @VehicleNo and [Status] = 1 and isVehicleNone = 0 and CardVehicleId <> @CardVehicleId)
				begin
					set @Valid = 0
					set @Messages = N'Đã có đăng ký biển số xe [' + @VehicleNo + N'] trong hệ thống!' 
				end
				else if @VehicleTypeId > 1 and @CardId = 0
				begin
					set @Valid = 0
					set @Messages = N'Mã thẻ không hợp lệ [' + isnull(@CardCd,'') + N']!' 
				end
				else
					UPDATE [dbo].[MAS_CardVehicle]
						SET [VehicleNo] = @VehicleNo
							,[VehicleTypeId] = @VehicleTypeId
							,[VehicleName] = @VehicleName
							,[StartTime] = convert(datetime,@StartTime,103)
							,[EndTime] = convert(datetime,@EndTime,103)
							,CardId = @CardId 
							,Auth_id = @UserID 
							,Auth_Dt = getdate()
						WHERE CardVehicleId = @CardVehicleId

			end

		
	end try
	begin catch
		declare	@ErrorNum				int,
				@ErrorMsg				varchar(200),
				@ErrorProc				varchar(50),

				@SessionID				int,
				@AddlInfo				varchar(max)

		set @ErrorNum					= error_number()
		set @ErrorMsg					= 'sp_Hom_Card_Guest_Vehicle_Set ' + error_message()
		set @ErrorProc					= error_procedure()

		set @AddlInfo					= '@Cif_no ' + @Phone 
		set @valid = 0
		set @messages = error_message()

		exec utl_Insert_ErrorLog @ErrorNum, @ErrorMsg, @ErrorProc, 'CardGuestVeh', 'Set', @SessionID, @AddlInfo
	end catch

	select @valid as valid
		  ,@messages as [messages]


end