
CREATE procedure [dbo].[sp_res_elevator_role_set]
	@UserId	UNIQUEIDENTIFIER = NULL,
	@Id int = null,
	@RoleName nvarchar(200),
	@acceptLanguage NVARCHAR(50) = N'vi-VN'
as
begin

	begin try	
	DECLARE @valid BIT = 0;
    DECLARE @messages NVARCHAR(250);
		IF not exists(SELECT Id FROM ELE_CardRole WHERE Id = @Id)
			BEGIN
			if exists(select 1 from ELE_CardRole where RoleName = @RoleName)
			begin
				set @valid = 0
				set @messages = N'Đã tồn tại tên quyền không thể thêm'
				goto FINAL
			end

				SET IDENTITY_INSERT dbo.ELE_CardRole ON;
				INSERT INTO dbo.ELE_CardRole
				(RoleName,
				Id
				,created_at
				,created_by)
			VALUES
				(@RoleName,
				@Id
				,GETDATE()
				,@UserId)
				SET IDENTITY_INSERT dbo.ELE_CardRole OFF;
			END
		ELSE
			BEGIN
			if exists(select 1 from ELE_CardRole where RoleName = @RoleName and id <> @Id)
			begin
				set @valid = 0
				set @messages = N'Đã tồn tại tên quyền không thể sửa'
				goto FINAL
			end

				UPDATE dbo.ELE_CardRole
				SET RoleName = @RoleName
					,created_at = GETDATE()
					,created_by = @UserId
				WHERE Id = @Id
			END

		set @valid = 1
		set @messages = N'Thành công!'

	end try
	begin catch
		declare	@ErrorNum				int,
				@ErrorMsg				varchar(200),
				@ErrorProc				varchar(50),

				@SessionID				int,
				@AddlInfo				varchar(max)

		set @ErrorNum					= error_number()
		set @ErrorMsg					= 'sp_Hom_Set_Elevator_CardRole ' + error_message()
		set @ErrorProc					= error_procedure()

		set @AddlInfo					= '@UserID ' + cast(@UserID as varchar(50))
		set @valid = 0
		set @messages = error_message()
		exec utl_Insert_ErrorLog @ErrorNum, @ErrorMsg, @ErrorProc, 'Elevator_CardRole', 'SET', @SessionID, @AddlInfo
	end catch
	FINAL:
    SELECT @valid AS valid
        , @messages AS [messages];
end