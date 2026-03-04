








CREATE procedure [dbo].[sp_Hom_Card_Partner_Del]
	@userId nvarchar(450),
	@partner_id	int
	
as
	begin try	
		declare @valid bit = 1
		declare @messages nvarchar(100) = ''
		if not exists(select partner_id from MAS_CardPartner where partner_id = @partner_id)
			begin
				set @Valid = 0
				set @Messages = N'Không tìm thấy thông [' + @partner_id + N']!' 
			end
		else if exists(select CardId from MAS_Cards where partner_id = @partner_id)
			begin
				set @Valid = 0
				set @Messages = N'Đang được sử dụng, không thẻ xóa!' 
			end
		else
		begin		
			delete from MAS_CardPartner
			where partner_id = @partner_id
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
		set @ErrorMsg					= 'sp_Hom_Card_Partner_Del' + error_message()
		set @ErrorProc					= error_procedure()

		set @AddlInfo					= ''

		exec utl_Insert_ErrorLog @ErrorNum, @ErrorMsg, @ErrorProc, 'CardPartner', 'DEL', @SessionID, @AddlInfo
	end catch