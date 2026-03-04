






CREATE procedure [dbo].[sp_Hom_Card_Partner_Set]
	@UserID	nvarchar(450),
	@partner_id int,
	@projectCd nvarchar(20),
	@partner_name nvarchar(100),
	@partner_cd nvarchar(50)
as
	begin try	
		declare @valid bit = 1
		declare @messages nvarchar(200) = ''
		declare @CardTypeId int

		if @partner_name is null or @partner_name = ''
			begin
				set @Valid = 0
				set @Messages = N'Phải nhập thông tin tên' 
			end
		else if exists(select partner_id from MAS_CardPartner where partner_name = @partner_name and projectCd = @projectCd and partner_id <> @partner_id)
			begin
				set @Valid = 0
				set @Messages = N'Thông tin đã tồn tại không được nhập trùng' 
			end
		else if not exists(select * from MAS_Projects where projectCd = @ProjectCd)
			begin
				set @Valid = 0
				set @Messages = N'Chưa chọn dự án!' 
			end
		else
		begin
			if exists(select top 1 partner_id from MAS_CardPartner WHERE partner_id = @partner_id)
				UPDATE [dbo].[MAS_CardPartner]
				   SET [partner_cd] = @partner_cd
					  ,[partner_name] = @partner_name
					  ,[projectCd] = @projectCd
					  ,update_dt = getdate()
					  ,update_by = @UserID
				 WHERE partner_id = @partner_id
			else
			begin
				INSERT INTO [dbo].[MAS_CardPartner]
					   ([partner_cd]
					   ,[partner_name]
					   ,[projectCd]
					   ,[create_dt]
					   ,[create_by]
					   )
				 VALUES
					   (@partner_cd
					   ,@partner_name
					   ,@projectCd
					   ,getdate()
					   ,@UserID
					   )
			end
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
		set @ErrorMsg					= 'sp_Hom_Card_Partner_Set ' + error_message()
		set @ErrorProc					= error_procedure()

		set @AddlInfo					= '@CardCd '  + isnull(@partner_name,'NULL')

		exec utl_Insert_ErrorLog @ErrorNum, @ErrorMsg, @ErrorProc, 'CardParter', 'Set', @SessionID, @AddlInfo
		
		select @valid as valid
			  ,@messages as [messages]
	end catch