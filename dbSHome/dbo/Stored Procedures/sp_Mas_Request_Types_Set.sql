

CREATE procedure [dbo].[sp_Mas_Request_Types_Set]
	@UserID				nvarchar(450),
	@requestTypeId		int,
	@requestTypeName	nvarchar(30),
	@requestCategoryId	int,
	@category			nvarchar(10),
	@unit				nvarchar(20),
	
	@Price				int,
	
	@note				nvarchar(50),      
	@typeName			nvarchar(50),   
	
	@isFree				bit,
	@iconUrl			nvarchar(200),
	@sub_prod_cd		nvarchar(10),
	@chat_cd			nvarchar(10),
	@isReady			bit
as

	begin try	
		declare @valid bit = 1
		declare @messages nvarchar(200) = 'Cập nhật thành công'
		if exists (select requestTypeId from MAS_Request_Types where requestTypeId = @requestTypeId)
			begin
				UPDATE t1
				 SET
					  requestTypeName = @requestTypeName
					  ,requestCategoryId = @requestCategoryId
					  ,category = @category
					  ,unit = @unit
					  ,Price = @Price
					  ,note = @note
					  ,typeName = @typeName
					  ,isFree = @isFree
					  ,iconUrl = @iconUrl
					  ,sub_prod_cd = @sub_prod_cd
					  ,chat_cd = @chat_cd
					  ,isReady = @isReady
				FROM MAS_Request_Types t1
				WHERE t1.requestTypeId = @requestTypeId
			end
			else
			begin
				INSERT INTO [dbo].MAS_Request_Types
					   ( 
					  requestTypeName
					  ,requestCategoryId
					  ,category
					  ,unit
					  ,Price
					  ,note
					  ,typeName
					  ,isFree
					  ,iconUrl
					  ,sub_prod_cd
					  ,chat_cd
					  ,isReady)
			
					VALUES
					   (
						@requestTypeName
					  ,@requestCategoryId
					  ,@category
					  ,@unit
					  ,@Price
					  ,@note
					  ,@typeName
					  ,@isFree
					  ,@iconUrl
					  ,@sub_prod_cd
					  ,@chat_cd
					  ,@isReady)
			end
	end try
	begin catch
		declare	@ErrorNum				int = error_number(),
					@ErrorMsg				varchar(200) = 'sp_Mas_Request_Types_Set ' + error_message(),
					@ErrorProc				varchar(50) = error_procedure(),

					@SessionID				int,
					@AddlInfo				varchar(max) = ' - @userId ' + @userId
			
			set @valid = 0
			set @messages = error_message()

			exec utl_Insert_ErrorLog @ErrorNum, @ErrorMsg, @ErrorProc, 'sp_Mas_Request_Types_Set', 'POST', @SessionID, @AddlInfo
		end catch

		SELECT @valid as valid
		  	,@messages as [messages]