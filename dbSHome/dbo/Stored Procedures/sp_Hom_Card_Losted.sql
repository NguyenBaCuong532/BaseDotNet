

CREATE procedure [dbo].[sp_Hom_Card_Losted]
	@UserID	nvarchar(450),
	@CardCd nvarchar(50)
as
begin
	declare @valid bit = 1
	declare @messages nvarchar(200) = 'Khóa thành công'
	begin try		
		declare @RequestTypeId int
		declare @RequestId int
		set @RequestTypeId = 19 --lost card
		if exists(select top 1 ApartmentId from [dbo].[fn_Hom_User_Apartment] (@userId) ua where IsHost = 1 
			or exists(select 1 from MAS_Cards where CardCd = @CardCd and custId = ua.custId))
		begin
			INSERT INTO [dbo].MAS_Requests
					   (RequestKey
					   ,ApartmentId
					   ,[RequestDt]
					   ,RequestTypeId
					   ,[Status]
					   ,userId
					   )
				select 'CardLost'
					   ,ApartmentId
					   ,getdate()
					   ,@RequestTypeId
					   ,0
					   ,@UserID
				FROM MAS_Cards
				WHERE CardCd = @CardCd

			 set @RequestId = @@IDENTITY

			UPDATE t1
			 SET Card_St = 2
				,RequestId = @RequestId
			 FROM MAS_Cards t1
			 WHERE t1.CardCd = @CardCd
		 end
		 else
		 begin
			set @valid = 0
			set @messages = N'Bạn không có quyền khóa thẻ'
		end
	end try
	begin catch
		declare	@ErrorNum				int,
				@ErrorMsg				varchar(200),
				@ErrorProc				varchar(50),

				@SessionID				int,
				@AddlInfo				varchar(max)

		set @ErrorNum					= error_number()
		set @ErrorMsg					= 'sp_Update_CardLost ' + error_message()
		set @ErrorProc					= error_procedure()

		set @AddlInfo					= '@UserID ' + @UserID 
		set @valid = 0
		set @messages = error_message()

		exec utl_Insert_ErrorLog @ErrorNum, @ErrorMsg, @ErrorProc, 'Card', 'Update', @SessionID, @AddlInfo
	end catch

	select @valid as valid
		  ,@messages as [messages]
end