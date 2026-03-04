
CREATE procedure [dbo].[sp_Hom_Par_Living_Price_Set]
	@UserID				nvarchar(450),
	@LivingPriceId		int,
	@ProjectCd			nvarchar(30),
	@NumFrom			int,
	@NumTo				int,
	@Price				int,
	@step				nvarchar(20),      
	@pos				int,   
	@isFree				bit,
	@calculateType		int,
	@isUsed				bit
as

	begin try	
		declare @valid bit = 1
				declare @messages nvarchar(200) = 'Cập nhật thành công'
		if exists (select LivingPriceId from PAR_ServiceLivingPrice where LivingPriceId = @LivingPriceId)
			begin
				UPDATE t1
                    SET
                        ProjectCd = @ProjectCd
                        ,NumFrom = @NumFrom
                        ,NumTo = @NumTo
                        ,Price = @Price
                        ,step = @step
                        ,pos = @pos
                        ,isFree = @isFree
                        ,calculateType = @calculateType
                        ,IsUsed = @isUsed
				FROM PAR_ServiceLivingPrice t1
				WHERE t1.LivingPriceId = @LivingPriceId
			end
		else
			begin
				INSERT INTO [dbo].PAR_ServiceLivingPrice
					   ( 
					  ProjectCd
					  ,NumFrom
					  ,NumTo
					  ,Price
					  ,step
					  ,pos
					  ,isFree
					  ,calculateType
					  ,IsUsed)
			
					VALUES
					   (
						@ProjectCd
					  ,@NumFrom
					  ,@NumTo
					  ,@Price
					  ,@step
					  ,@pos
					  ,@isFree
					  ,@calculateType
					  ,@isUsed)
			end
	end try
	begin catch
			declare	@ErrorNum				int = error_number(),
					@ErrorMsg				varchar(200) = 'sp_Hom_Par_Living_Price_Set ' + error_message(),
					@ErrorProc				varchar(50) = error_procedure(),

					@SessionID				int,
					@AddlInfo				varchar(max) = ' - @userId ' + @userId
			
			set @valid = 0
			set @messages = error_message()

		exec utl_Insert_ErrorLog @ErrorNum, @ErrorMsg, @ErrorProc, 'sp_Hom_Par_Living_Price_Set', 'Update', @SessionID, @AddlInfo

	end catch
	SELECT @valid as valid
		  	,@messages as [messages]