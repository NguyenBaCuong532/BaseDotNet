





CREATE procedure [dbo].[sp_Pay_Create_New_PointCd] 
	@UserID nvarchar(450),
	@newpoint		int out
	
as
	begin try
				
	set @newpoint = CAST(RAND(CHECKSUM(NEWID())) * 1000000000 as bigint)
	WHILE exists(select pointCd from [MAS_Points] where PointCd = @newpoint)
	BEGIN
		set @newpoint = CAST(RAND(CHECKSUM(NEWID())) * 1000000000 as bigint)
	END
		INSERT INTO [dbo].[MAS_Points]
			([PointCd]
			,[PointType]
			,[CustId]
			,[CurrPoint]
			,[LastDt])
		SELECT  @newpoint
			,0
			,b.CustId
			,0
			,getdate()
			FROM UserInfo b 
			WHERE b.UserId = @UserID

	end try
	begin catch
		declare	@ErrorNum				int,
				@ErrorMsg				varchar(200),
				@ErrorProc				varchar(50),

				@SessionID				int,
				@AddlInfo				varchar(max)

		set @ErrorNum					= error_number()
		set @ErrorMsg					= 'sp_create_new_pointcd' + error_message()
		set @ErrorProc					= error_procedure()

		set @AddlInfo					= ''

		exec utl_Insert_ErrorLog @ErrorNum, @ErrorMsg, @ErrorProc, 'Bill', 'DEL', @SessionID, @AddlInfo
	end catch