

CREATE procedure [dbo].[sp_Cor_Update_Customer_Image]
	@userId	nvarchar(450),
	@imageId int,
	@imageUrl nvarchar(350),
	@faceId nvarchar(200),	
	@imageType int
as
	begin try		
	

		if not exists(select CustId from [MAS_Customer_Image] where imageId = @imageId)
		begin
			INSERT INTO [dbo].[MAS_Customer_Image]
				   ([FaceId]
				   ,[CustId]
				   ,[ImageUrl]
				   ,[ImageType]
				   ,[IsFace]
				   ,[sysDate])
			 SELECT @FaceId
				   ,CustId
				   ,@ImageUrl
				   ,@ImageType
				   ,0
				   ,getdate()
			FROM UserInfo
			WHERE UserId = @userId

		end
		else
		begin
			UPDATE [dbo].[MAS_Customer_Image]
			   SET [FaceId] = @FaceId
				  ,[ImageUrl] = @ImageUrl
				  ,[ImageType] = @ImageType
				  ,[sysDate] = getdate()
			 WHERE ImageId = @imageId
		end
		
		
	end try
	begin catch
		declare	@ErrorNum				int,
				@ErrorMsg				varchar(200),
				@ErrorProc				varchar(50),

				@SessionID				int,
				@AddlInfo				varchar(max)

		set @ErrorNum					= error_number()
		set @ErrorMsg					= 'sp_Cor_Update_Customer_Image ' + error_message()
		set @ErrorProc					= error_procedure()

		set @AddlInfo					= '@User ' 

		exec utl_Insert_ErrorLog @ErrorNum, @ErrorMsg, @ErrorProc, 'CustomerImage', 'Update', @SessionID, @AddlInfo
	end catch