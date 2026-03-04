


CREATE procedure [dbo].[sp_Hom_Request_Assign]
	@userId nvarchar(450),
	@requestID	bigint,
	@assign_userId nvarchar(100),
	@assignRole int,
	@used bit
as
	begin try		
	if @Used = 1
	begin
		if not exists(select 1 from MAS_Request_Assign where requestId = @requestID and userId = @assign_userId)
			INSERT INTO [dbo].MAS_Request_Assign
			   ([RequestId]
			   ,userId
			   ,assignRole)
			VALUES
			   (@RequestId
			   ,@assign_userId
			   ,@assignRole)
		 else
			update MAS_Request_Assign
				set assignRole = @assignRole
			where requestId = @requestID 
				and userId = @assign_userId
	end
	ELSE
		DELETE FROM [dbo].MAS_Request_Assign
		WHERE [RequestId] = @RequestId AND userId = @assign_userId


	end try
	begin catch
		declare	@ErrorNum				int,
				@ErrorMsg				varchar(200),
				@ErrorProc				varchar(50),

				@SessionID				int,
				@AddlInfo				varchar(max)

		set @ErrorNum					= error_number()
		set @ErrorMsg					= 'sp_Hom_Request_Assign ' + error_message()
		set @ErrorProc					= error_procedure()

		set @AddlInfo					= '@UserID '  + @userId

		exec utl_Insert_ErrorLog @ErrorNum, @ErrorMsg, @ErrorProc, 'Request', 'Ass', @SessionID, @AddlInfo
	end catch