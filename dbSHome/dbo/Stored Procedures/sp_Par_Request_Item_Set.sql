


CREATE procedure [dbo].[sp_Par_Request_Item_Set]
	@UserID				nvarchar(450),
	@PriceId			int,
	@RequestTypeId		int,
	@unit				nvarchar(20),
	@Price				int,
	@note				nvarchar(50),      
	@ItemName			nvarchar(50),
	@isFree				bit,
	@Post				nvarchar(10),
	@isUsed				bit
as

	begin try	
        declare @valid bit = 1
		declare @messages nvarchar(200) = 'Cập nhật thành công'
		if exists (select PriceId from PAR_RequestTypePrice where PriceId = @PriceId)
			begin
				UPDATE t1
				 SET
					  RequestTypeId = @RequestTypeId
					  ,unit = @unit
					  ,Price = @Price
					  ,note = @note
					  ,ItemName = @ItemName
					  ,isFree = @isFree
					  ,Post = @Post
					  ,isUsed = @isUsed
				FROM PAR_RequestTypePrice t1
				WHERE t1.PriceId = @PriceId
			end
		else
			begin
				INSERT INTO [dbo].PAR_RequestTypePrice
					   (RequestTypeId
					  ,Unit
					  ,Price
					  ,note
					  ,ItemName
					  ,isFree
					  ,Post
					  ,isUsed)
			
					VALUES
					   (@RequestTypeId
					  ,@unit
					  ,@Price
					  ,@note
					  ,@ItemName
					  ,@isFree
					  ,@Post
					  ,@isUsed)
			end
	end try
	begin catch
		declare	@ErrorNum				int = error_number(),
					@ErrorMsg				varchar(200) = 'sp_Par_Request_Item_Set ' + error_message(),
					@ErrorProc				varchar(50) = error_procedure(),

					@SessionID				int,
					@AddlInfo				varchar(max) = ' - @userId ' + @userId
			
			set @valid = 0
			set @messages = error_message()

			exec utl_Insert_ErrorLog @ErrorNum, @ErrorMsg, @ErrorProc, 'sp_Par_Request_Item_Set', 'POST', @SessionID, @AddlInfo
		end catch

		SELECT @valid as valid
		  	,@messages as [messages]