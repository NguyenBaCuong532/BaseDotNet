CREATE procedure [dbo].[sp_Crm_Apartment_HandOver_Set]
	@UserID	nvarchar(450),
	@HandOverId bigint,
	@TitleHandOver nvarchar(100),
	@OutDateHandOver datetime,
	@RequestDateCus nvarchar(50),
	@BuildingCd nvarchar(50),
	@ProjectCd nvarchar(50)
as
	begin try		

		if not exists(select HandOverId from [CRM_Apartment_HandOver] where HandOverId = @HandOverId)
		begin
			insert into [dbo].[CRM_Apartment_HandOver]
			   (TitleHandOver
			   ,OutDateHandOver
			   ,RequestDateCus
			   ,BuildingCd
			   ,ProjectCd
			   ,[Created]
			   ,[CreatedBy])
			values
			   (@TitleHandOver
			   ,@OutDateHandOver
			   ,@RequestDateCus
			   ,@BuildingCd
			   ,@ProjectCd
			   ,getdate()
			   ,@UserID)
			set @HandOverId = @@IDENTITY
		end
		else
			begin
				update [dbo].[CRM_Apartment_HandOver]
				set   TitleHandOver = @TitleHandOver
					  ,OutDateHandOver = @OutDateHandOver
					  ,RequestDateCus = @RequestDateCus
					  ,[BuildingCd] = @BuildingCd
					  ,[ProjectCd] = @ProjectCd
					  ,[Modified] = getdate()
					  ,[ModifiedBy] = @UserID
				 where HandOverId = @HandOverId
			end
		select * from CRM_Apartment_HandOver where HandOverId = @HandOverId
	end try
	begin catch
		declare	@ErrorNum				int,
				@ErrorMsg				varchar(200),
				@ErrorProc				varchar(50),

				@SessionID				int,
				@AddlInfo				varchar(max)

		set @ErrorNum					= error_number()
		set @ErrorMsg					= 'sp_Crm_Apartment_HandOver_Set ' + error_message()
		set @ErrorProc					= error_procedure()

		set @AddlInfo					= '@UserID ' + @UserID 

		exec utl_Insert_ErrorLog @ErrorNum, @ErrorMsg, @ErrorProc, 'sp_Crm_Apartment_HandOver_Set', 'Set', @SessionID, @AddlInfo
	end catch