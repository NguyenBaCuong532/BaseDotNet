
CREATE procedure [dbo].[sp_res_elevator_role_list]
	@UserId		UNIQUEIDENTIFIER = NULL,
	@CardRoleId int = null,
	@acceptLanguage NVARCHAR(50) = N'vi-VN'
as
	begin try	
		SELECT   CR.Id as value
				,CR.RoleName as name
				,CR.Id
				,CR.RoleName 
		FROM ELE_CardRole AS CR 
		WHERE  (@CardRoleId  IS NULL OR (CR.Id = @CardRoleId ))
	end try
	begin catch
			declare	@ErrorNum				int,
					@ErrorMsg				varchar(200),
					@ErrorProc				varchar(50),

					@SessionID				int,
					@AddlInfo				varchar(max)

			set @ErrorNum					= error_number()
			set @ErrorMsg					= 'sp_res_elevator_card_role_get ' + error_message()
			set @ErrorProc					= error_procedure()

			set @AddlInfo					= '@UserID ' + cast(@UserID as varchar(50))

			exec utl_Insert_ErrorLog @ErrorNum, @ErrorMsg, @ErrorProc, 'elevator_card', 'GET', @SessionID, @AddlInfo
		end catch