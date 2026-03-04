




CREATE procedure [dbo].[sp_Hom_Card_Daily_Set]
	@UserID	nvarchar(450),
	@ProjectCd nvarchar(30),
	@CardCd nvarchar(50),
	@VehicleTypeId int
	
as
	begin try	
	declare @valid bit = 1
	declare @messages nvarchar(200) = ''
	declare @CardTypeId int
	--declare @errmessage nvarchar(100)
	--set @errmessage = 'This Card: ' + @CardCd + ' is not exists or used!'
	set @VehicleTypeId = 2
	set @CardTypeId = 3 --Ve xe

	if not exists(select * from MAS_CardBase where Code = @CardCd)	--and (IsUsed = 0 or IsUsed is null)
		begin
			set @Valid = 0
			set @Messages = N'Không tìm thấy thông tin mã thẻ [' + @CardCd + N'] trong kho số!' 
			--RAISERROR (@messages, -- Message text.
			--	   16, -- Severity.
			--	   1 -- State.
			--	   );
		end
	else if exists(select * from MAS_CardBase where Code = @CardCd and IsUsed = 1)
		begin
			set @Valid = 0
			set @Messages = N'Mã thẻ [' + @CardCd + N'] đã được sử dụng!' 
			--RAISERROR (@messages, -- Message text.
			--	   16, -- Severity.
			--	   1 -- State.
			--	   );
		end
	else
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
		   ,created_by
		   )
		VALUES
           (@CardCd
           ,Getdate()
           ,1
		   ,0
           ,1
           ,@ProjectCd
           ,@VehicleTypeId
		   ,0
		   ,@CardTypeId
		   ,@UserID
		   )

		   UPDATE MAS_CardBase SET IsUsed = 1 WHERE Code = @CardCd 
	END
		
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
		set @ErrorMsg					= 'sp_Hom_Card_Daily_Set ' + error_message()
		set @ErrorProc					= error_procedure()

		set @AddlInfo					= '@CardCd '  + @CardCd

		exec utl_Insert_ErrorLog @ErrorNum, @ErrorMsg, @ErrorProc, 'Card', 'Insert', @SessionID, @AddlInfo
	end catch