



CREATE procedure [dbo].[sp_Hom_Card_Del]
	@userId nvarchar(450),
	@CardCd	nvarchar(50)	
	
as
	begin try	
		declare @valid bit = 1
		declare @messages nvarchar(100) = ''
		if not exists(select cardId from MAS_Cards where CardCd = @CardCd)
			begin
				set @Valid = 0
				set @Messages = N'Không tìm thấy thông mã thẻ [' + @CardCd + N']!' 
				--RAISERROR (@messages, -- Message text.
				--	   16, -- Severity.
				--	   1 -- State.
				--	   );
			end
		else if exists(select cardId from MAS_Cards where CardCd = @CardCd and Card_St < 3)
			begin
				set @Valid = 0
				set @Messages = N'Số thẻ [' + @CardCd + N'] đang được sử dụng, Cần phải khóa trước khi xóa!' 
				--RAISERROR (@messages, -- Message text.
				--	   16, -- Severity.
				--	   1 -- State.
				--	   );
			end
		else --if exists(select cardId from MAS_Cards where CardCd = @CardCd and Card_St >= 3)
		begin
			INSERT INTO [dbo].[MAS_CardVehicle_H]
				   ([CardVehicleId]
				   ,[AssignDate]
				   ,[CardId]
				   ,[CustId]
				   ,[VehicleNo]
				   ,[VehicleTypeId]
				   ,[VehicleName]
				   ,[VehicleColor]
				   ,[StartTime]
				   ,[EndTime]
				   ,[Status]
				   ,[ServiceId]
				   ,[RegCardVehicleId]
				   ,[RequestId]
				   ,[isVehicleNone]
				   ,[monthlyType]
				   ,[lastReceivable]
				   ,[Auth_id]
				   ,[Auth_Dt]
				   ,[ProjectCd]
				   ,[Reason]
				   ,[SaveDate]
				   ,[SaveId])
			SELECT [CardVehicleId]
				  ,[AssignDate]
				  ,[CardId]
				  ,[CustId]
				  ,[VehicleNo]
				  ,[VehicleTypeId]
				  ,[VehicleName]
				  ,[VehicleColor]
				  ,[StartTime]
				  ,[EndTime]
				  ,[Status]
				  ,[ServiceId]
				  ,[RegCardVehicleId]
				  ,[RequestId]
				  ,[isVehicleNone]
				  ,[monthlyType]
				  ,[lastReceivable]
				  ,[Auth_id]
				  ,[Auth_Dt]
				  ,[ProjectCd]
				  ,[Reason]
				  ,getdate()
				  ,@UserId
			  FROM [dbSHome].[dbo].[MAS_CardVehicle] a	
			  where exists(select cardId from MAS_Cards where CardCd = @CardCd and CardId = a.CardId and Card_St >= 3) 

			  UPDATE t
			   SET [VehicleNum] = t.VehicleNum - 1
			FROM [dbo].[MAS_CardVehicle] t join [dbo].[MAS_CardVehicle] a on t.ApartmentId = a.ApartmentId and t.VehicleTypeId = a.VehicleTypeId 
			  and t.VehicleNum > a.VehicleNum 
			WHERE t.[Status] = 1
				and exists(select cardId from MAS_Cards where CardCd = @CardCd and CardId = a.CardId and Card_St >= 3) 

			delete a from MAS_CardVehicle a
			where exists(select cardId from MAS_Cards where CardCd = @CardCd and CardId = a.CardId and Card_St >= 3) 

			delete a from MAS_CardCredit a
			where exists(select cardId from MAS_Cards where CardCd = @CardCd and CardId = a.CardId and Card_St >= 3) 

			delete a from MAS_CardService a
			where exists(select cardId from MAS_Cards where CardCd = @CardCd and CardId = a.CardId and Card_St >= 3) 

			delete	cc
			from	[MAS_Apartment_Card] cc  
				join  MAS_Cards ma on cc.CardId = ma.CardId 
			where CardCd = @CardCd 

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
			   ,[SaveId])
			 SELECT [CardId]
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
			  ,getdate()
			  ,@userId
		  FROM [MAS_Cards]
		  where CardCd = @CardCd

			delete	trg
			from	MAS_Cards trg
			where CardCd = @CardCd and Card_St >= 3

			UPDATE MAS_CardBase Set IsUsed = 0 
			WHERE Code = @CardCd 

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
		set @ErrorMsg					= 'sp_Delete_Card_ByCardCd' + error_message()
		set @ErrorProc					= error_procedure()

		set @AddlInfo					= ''

		exec utl_Insert_ErrorLog @ErrorNum, @ErrorMsg, @ErrorProc, 'Card', 'DEL', @SessionID, @AddlInfo
	end catch