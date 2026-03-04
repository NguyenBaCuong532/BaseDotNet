





CREATE procedure [dbo].[sp_Hom_Card_Guest_Set]
	@UserID	nvarchar(450),
	@CustId nvarchar(50),
	@CustPhone nvarchar(20),
	@CustName nvarchar(100),
	@CardCd nvarchar(50),
	@IssueDate nvarchar(20),
	@ExpireDate nvarchar(20),
	@ProjectCd nvarchar(30),
	@partner_id int = 0
as
	begin try	
		declare @valid bit = 1
		declare @messages nvarchar(200) = ''
		declare @CardTypeId int
		set @CardTypeId = 4 --the guest

		if not exists(select Code from MAS_CardBase where Code = @CardCd)
			begin
				set @Valid = 0
				set @Messages = N'Không tìm thấy thông mã thẻ [' + @CardCd + N']!' 
			end
		--else if exists(select cardId from MAS_Cards where CardCd = @CardCd and Card_St < 3)
		--	begin
		--		set @Valid = 0
		--		set @Messages = N'Số thẻ [' + @CardCd + N'] đang được sử dụng, Cần phải khóa trước cấp!' 
		--	end
		else if not exists(select * from MAS_Projects where projectCd = @ProjectCd)
			begin
				set @Valid = 0
				set @Messages = N'Chưa chọn dự án!' 
			end
		else
		begin
			if exists(select top 1 CustId from MAS_Customers WHERE Phone like @CustPhone)
				set @CustId = (select top 1 CustId from MAS_Customers WHERE Phone like @CustPhone)
			else
			begin
				set @custId = newid()
					INSERT INTO [dbo].[MAS_Customers]
						   (CustId
						   ,[FullName]
						   ,[Phone]
						   ,[Email]
						   ,[AvatarUrl]
						   ,[IsSex]
						   ,IsForeign
						   ,sysDate
						   --,created_by
						   )
						VALUES
						   (@custId
						   ,@CustName
						   ,@CustPhone
						   ,null
						   ,null
						   ,1
						   ,0 
						   ,getdate()
						   --,@UserID
						   )
			end

			if exists(select * from [MAS_Cards] where [CardCd] = @CardCd and Card_St >= 3)
				EXECUTE [dbo].[sp_Hom_Card_Del] 
				   @userId
				  ,@CardCd

		if not exists(select * from [MAS_Cards] where [CardCd] = @CardCd)
		begin
			INSERT INTO [dbo].[MAS_Cards]
				   ([CardCd]
				   ,[IssueDate]
				   ,[ExpireDate]
				   ,[Card_St]
				   ,[IsClose]
				   ,IsDaily
				   ,[IsVip]
				   ,IsGuest
				   ,CustId
				   ,CardTypeId
				   ,CardName
				   ,ProjectCd
				   ,isVehicle
				   ,isCredit
				   ,partner_id
				   ,created_by
				   )
				VALUES
				   (@CardCd
				   ,Getdate() --isnull(convert(date,@IssueDate,103),Getdate())
				   ,isnull(convert(date,@ExpireDate,103),Getdate())
				   ,1
				   ,0
				   ,0
				   ,0
				   ,1
				   ,@CustId
				   ,@CardTypeId
				   ,N'Thẻ Khách'
				   ,@ProjectCd
				   ,0
				   ,0
				   ,@partner_id
				   ,@UserID
				   )

			   UPDATE MAS_CardBase SET IsUsed = 1 WHERE Code = @CardCd 
		end
		else
			--UPDATE [MAS_Cards] SET partner_id = @partner_id 
			--WHERE CardCd = @CardCd 
			UPDATE [MAS_Cards] 
			SET   CustId  =		@CustId
				 --[IssueDate] =   isnull(convert(date,@IssueDate,103),Getdate())
				 ,[ExpireDate] = isnull(convert(date,@ExpireDate,103),Getdate())
				 ,[Card_St] =	1	
				 ,[IsClose] =	0
				 ,IsDaily =		0
				 ,[IsVip] =		0
				 ,IsGuest =		1
				 ,CardTypeId =	@CardTypeId
				 ,CardName	 =	N'Thẻ Khách'
				 ,ProjectCd	 =	@ProjectCd
				 ,isVehicle	 =	0
				 ,isCredit	 =	0
				,partner_id = @partner_id 
			WHERE CardCd = @CardCd 

			UPDATE [dbo].[MAS_Customers]
			SET
				[FullName] = @CustName,
				[Phone]	  = @CustPhone
			WHERE CustId = @CustId
		end

	/**TO DO***/
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
		set @ErrorMsg					= 'sp_Hom_Insert_Card_Guest ' + error_message()
		set @ErrorProc					= error_procedure()

		set @AddlInfo					= '@CardCd '  + isnull(@CardCd,'NULL')

		exec utl_Insert_ErrorLog @ErrorNum, @ErrorMsg, @ErrorProc, 'CardGuest', 'Insert', @SessionID, @AddlInfo
		
		select @valid as valid
			  ,@messages as [messages]
	end catch