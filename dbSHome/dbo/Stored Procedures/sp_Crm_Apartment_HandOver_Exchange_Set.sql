

CREATE procedure [dbo].[sp_Crm_Apartment_HandOver_Exchange_Set]
	@UserID	nvarchar(450),
	@ExchangeId bigint,
	@HandOverDetailId bigint,
	@DepartmentCd nvarchar(50),
	@WorkStatusId int,
	@TeamType int,
	@StartDate datetime,
	@EndDate datetime,
	@TotalTime int,
	@Title nvarchar(MAX),
	@UserAssign nvarchar(MAX),
	@UserAdminAssign nvarchar(MAX),
	@StatusType int,
	@Note nvarchar(500)
as
	begin try
	
		if not exists(select ExchangeId from [CRM_Apartment_HandOver_Exchange] where ExchangeId = @ExchangeId)
			begin
				insert into [dbo].[CRM_Apartment_HandOver_Exchange]
						   ([HandOverDetailId]
						   ,[Title]
						   ,[UserAssign]
						   ,[UserAdminAssign]
						   ,DepartmentCd
						   ,WorkStatusId
						   ,TeamType
						   ,StartDate
						   ,EndDate
						   ,TotalTime
						   ,StatusType
						   ,Note
						   ,[Created]
						   ,[CreatedBy])
				values
						   (@HandOverDetailId
						   ,@Title
						   ,@UserAssign
						   ,@UserAdminAssign
						   ,@DepartmentCd
						   ,1
						   ,@TeamType
						   ,@StartDate
						   ,@EndDate
						   ,@TotalTime
						   ,0
						   ,@Note
						   ,getdate()
						   ,@UserID)
				set @ExchangeId = @@IDENTITY
			end
		else
			begin
				UPDATE [dbo].[CRM_Apartment_HandOver_Exchange]
				   SET [HandOverDetailId] = @HandOverDetailId
					  ,[Title] = @Title
					  ,[UserAssign] =@UserAssign
					  ,[UserAdminAssign] = @UserAdminAssign
					  ,DepartmentCd = @DepartmentCd
					  ,WorkStatusId = @WorkStatusId
					  ,StartDate = @StartDate
					  ,EndDate = @EndDate
					  ,TotalTime =@TotalTime
					  ,StatusType = @StatusType
					  ,Note = @Note
					  ,[Modified] = getdate()
					  ,[ModifiedBy] = @UserID
				 WHERE ExchangeId = @ExchangeId
			end
		select * from CRM_Apartment_HandOver_Exchange where ExchangeId = @ExchangeId

	end try
	begin catch
		declare	@ErrorNum				int,
				@ErrorMsg				varchar(200),
				@ErrorProc				varchar(50),

				@SessionID				int,
				@AddlInfo				varchar(max)

		set @ErrorNum					= error_number()
		set @ErrorMsg					= 'sp_Crm_Apartment_HandOver_Exchange_Set ' + error_message()
		set @ErrorProc					= error_procedure()

		set @AddlInfo					= ' '

		exec utl_Insert_ErrorLog @ErrorNum, @ErrorMsg, @ErrorProc, 'CRM_Apartment_HandOver_Exchange', 'PUT', @SessionID, @AddlInfo
	end catch