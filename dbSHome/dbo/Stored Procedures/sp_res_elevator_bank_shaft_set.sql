

-- =============================================
-- Author:		duongpx
-- Description:	Thêm khu vực cho tòa
-- =============================================
CREATE   procedure [dbo].[sp_res_elevator_bank_shaft_set]
						 @UserId UNIQUEIDENTIFIER = NULL
						 ,@Id int
						,@ElevatorBank int
					   ,@ElevatorShaftName nvarchar(50)
					   ,@ElevatorShaftNumber int
					   ,@ProjectCd nvarchar(50)
					   ,@BuildZone nvarchar(50)
					   ,@acceptLanguage NVARCHAR(50) = N'vi-VN'
			as
	begin try
	if exists (select Id from [dbo].[ELE_BankShaft] where Id = @Id)
		begin
			
			UPDATE [dbo].[ELE_BankShaft]
				   SET  [ElevatorBank] = @ElevatorBank
					   ,[ElevatorShaftName] = @ElevatorShaftName 
					   ,[ElevatorShaftNumber] = @ElevatorShaftNumber
					   ,[ProjectCd] = @ProjectCd 
					   ,[BuildZone] = @BuildZone 
					   ,[created_at] = getdate()
					   ,[created_by] = CAST(@UserId AS NVARCHAR(50))

			 where Id = @Id
		end
	else
		begin
			INSERT INTO [dbo].[ELE_BankShaft]
					   ([ElevatorBank]
					   ,[ElevatorShaftName]
					   ,[ElevatorShaftNumber]
					   ,[ProjectCd]
					   ,[BuildZone]
					   ,[created_at]
					   ,[created_by])
			VALUES
					   (@ElevatorBank
					   ,@ElevatorShaftName 
					   ,@ElevatorShaftNumber
					   ,@ProjectCd 
					   ,@BuildZone 
					   ,getdate()
					   ,CAST(@UserId AS NVARCHAR(50)))

			set @Id  = @@IDENTITY
		end

		select 1 as valid, N'Thành công' as messages
	end try
	begin catch
		declare	@ErrorNum				int,
				@ErrorMsg				varchar(200),
				@ErrorProc				varchar(50),

				@SessionID				int,
				@AddlInfo				varchar(max)

		set @ErrorNum					= error_number()
		set @ErrorMsg					= 'sp_res_elevator_area_set ' + error_message()
		set @ErrorProc					= error_procedure()

		set @AddlInfo					= ' '

		exec utl_Insert_ErrorLog @ErrorNum, @ErrorMsg, @ErrorProc, 'ELE_BuildArea', 'POST,PUT', @SessionID, @AddlInfo
	end catch