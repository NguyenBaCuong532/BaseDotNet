-- =============================================
-- Author:		duongpx
-- Create date: 11/01/2025 
-- Description:	10/24/2025 2:49:48 PM
-- =============================================
CREATE procedure [dbo].[sp_app_security_policy_list]
	@UserID	nvarchar(450) = null,
	@acceptLanguage	nvarchar(50) = 'vi-VN',
	@type nvarchar(100) = null
as
	begin try	
		if @type is null
			begin
				SELECT cast(a.Oid as nvarchar(50)) as value
					  ,a.name as name
					  ,a.[content]
				FROM security_policy a
				order by a.name
			end
		else if @type = 'orderLoan'
			begin
				SELECT cast(a.Oid as nvarchar(50)) as value
					  ,a.name as name
					  ,a.[content]
				FROM security_policy a
				where a.name = N'Vay mua nhà'
			end
		else if @type = 'introNoble'
			begin
				SELECT cast(a.Oid as nvarchar(50)) as value
					  ,a.name as name
					  ,a.[content]
				FROM security_policy a
				where a.name = N'Giới thiệu Noble'
			end
		else
			begin
				SELECT cast(a.Oid as nvarchar(50)) as value
					  ,a.name as name
					  ,a.[content]
				FROM security_policy a
				where a.name = N'Chính sách bảo mật'
			end

	end try
	begin catch
		declare	@ErrorNum				int,
				@ErrorMsg				varchar(200),
				@ErrorProc				varchar(50),

				@SessionID				int,
				@AddlInfo				varchar(max)

		set @ErrorNum					= error_number()
		set @ErrorMsg					= 'sp_app_security_policy_list ' + error_message()
		set @ErrorProc					= error_procedure()

		set @AddlInfo					= ''

		exec utl_ErrorLog_Set @ErrorNum, @ErrorMsg, @ErrorProc, 'sp_app_security_policy_list', 'Get', @SessionID, @AddlInfo
	end catch