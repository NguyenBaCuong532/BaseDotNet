-- =============================================
-- Author:		<vdx>
-- Description:	<Actions Tracking add, thêm 1 action>
-- exec sp_Hom_Action_Add "vu_id", "03", "https://s-service.sunshineapp.vn/apartment/setup-fee/70756", "api-x", "save", "json", 1 
-- exec sp_Hom_Action_Add "vu_id", "03", "https://s-service.sunshineapp.vn/apartment/setup-fee/70756", "api-x", null, "json", 1 [test error]
-- =============================================
CREATE PROCEDURE [dbo].[sp_Hom_Action_Add]
    @userId		nvarchar(150),
	@projectCd 	nvarchar(10),
    @url		nvarchar(150),
    @api		nvarchar(150),
    @action		nvarchar(50),
    @data		nvarchar(350),
    @status		int

AS 
	BEGIN
		BEGIN TRY
			begin
				declare @valid bit = 1
				DECLARE @code int = 25 -- 2006-12-30 00:38:54.840
				declare @messages nvarchar(200) = 'Cập nhật thành công'
				DECLARE @now NVARCHAR(50) = convert(varchar, getdate(), @code) 
					INSERT INTO [dbo].[MAS_Actions] (userId, projectCd, url, 
													api, action, data, time, status)
								values (@userId, @projectCd,
								@url, @api, @action, 
								@data, @now , @status)

			end
		END try

		begin catch
			declare	@ErrorNum				int = error_number(),
					@ErrorMsg				varchar(200) = 'sp_Hom_Action_Add ' + error_message(),
					@ErrorProc				varchar(50) = error_procedure(),

					@SessionID				int,
					@AddlInfo				varchar(max) = ' - @userId ' + @userId
			
			set @valid = 0
			set @messages = error_message()

			exec utl_Insert_ErrorLog @ErrorNum, @ErrorMsg, @ErrorProc, 'sp_Hom_Action_Add', 'POST', @SessionID, @AddlInfo
		end catch

		SELECT @valid as valid
		  	,@messages as [messages]	
	END