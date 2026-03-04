

CREATE procedure [dbo].[sp_Hom_Apartment_Member_Del]
	@UserId	nvarchar(450),	
	@CustId	nvarchar(50),	
	@apartmentId int
as
	begin try		
		declare @valid bit = 1
		declare @messages nvarchar(100) = 'Cập nhật thành công'	
		if exists(select CustId from MAS_Apartments a inner join UserInfo b on a.UserLogin = b.loginName where CustId = @CustId and ApartmentId = @apartmentId)
		begin
			set @Valid = 0
			set @Messages = N'Thành viên là chủ hộ không thể xóa' 
		end
		else if exists(select CustId from MAS_Cards a where CustId = @CustId and a.Card_St <3 and a.ApartmentId = @apartmentId) 
			or exists(select CustId from MAS_Cards a where CustId = @CustId and a.Card_St <3 and ApartmentId = @apartmentId)
		begin
			set @Valid = 0
			set @Messages = N'Thành viên là đang được cấp thẻ cần Khóa thẻ trước!' 
		end
		else
		begin
			delete from MAS_Apartment_Member where CustId = @CustId and ApartmentId = @apartmentId

			if not exists(select CustId from MAS_Cards a where CustId = @CustId) 
				and not exists(select CustId from MAS_Apartment_Card a join MAS_Cards b on a.CardId = b.CardId where CustId = @CustId)
				and not exists(select CustId from MAS_Apartments a inner join UserInfo b on a.UserLogin = b.loginName where CustId = @CustId and ApartmentId <> @apartmentId)
			begin	
				delete	trg
				from	MAS_Customers trg
				where	trg.CustId			= @CustId and (IsContact is null or IsContact = 0)
			end
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
		set @ErrorMsg					= 'sp_Hom_Apartment_Member_Del' + error_message()
		set @ErrorProc					= error_procedure()

		set @AddlInfo					= ''

		exec utl_Insert_ErrorLog @ErrorNum, @ErrorMsg, @ErrorProc, 'Member', 'DEL', @SessionID, @AddlInfo
	end catch