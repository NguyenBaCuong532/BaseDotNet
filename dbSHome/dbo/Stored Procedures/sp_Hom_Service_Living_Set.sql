




CREATE procedure [dbo].[sp_Hom_Service_Living_Set]
	
	@UserID	nvarchar(450),
	@ApartmentId bigint,
	@LivingId	bigint,
	@LivingType int,
	@ContractNo nvarchar(50),
	@ContractDate nvarchar(10),
	@MeterSerial nvarchar(50),	
	@MeterNumber bigint,
	@StartDate nvarchar(10),
	@EmployeeCd nvarchar(50),	
	@DeliverName nvarchar(100),
	@CustId nvarchar(50),
	@CustName nvarchar(100),
	@CustPhone nvarchar(20),
	@Note nvarchar(200),
	@ProviderCd nvarchar(50),
	@NumPersonWater int

as
	begin try		
	declare @ProjectCd nvarchar(30)
	set @ProjectCd = (select a.ProjectCd from MAS_Apartments a 
		where a.ApartmentId = @ApartmentId)
	if not exists(SELECT LivingId FROM MAS_Apartment_Service_Living a 
		JOIN MAS_Apartments b ON a.ApartmentId = b.ApartmentId  
			WHERE LivingId = @LivingId)
			INSERT INTO [dbo].[MAS_Apartment_Service_Living]
			   ([LivingTypeId]
			   ,[ProjectCd]
			   ,[ProviderCd]
			   ,[ApartmentId]
			   ,[ContractNo]
			   ,[ContractDt]
			   ,[EmployeeCd]
			   ,[DeliverName]
			   ,[CustId]
			   ,[CustName]
			   ,[CustPhone]
			   ,[Note]
			   ,[MeterSeri]
			   ,[MeterDate]
			   ,[MeterNum]
			   ,MeterLastDt
			   ,MeterLastNum
			   ,[sysDate]
			   ,NumPersonWater
			   )
		 VALUES
			   (@LivingType
			   ,@ProjectCd
			   ,@ProviderCd
			   ,@ApartmentId
			   ,@ContractNo
			   ,convert(datetime,@ContractDate,103)
			   ,@EmployeeCd
			   ,@DeliverName
			   ,@CustId
			   ,@CustName
			   ,@CustPhone
			   ,@Note
			   ,@MeterSerial
			   ,convert(datetime,@StartDate,103)
			   ,@MeterNumber
			   ,convert(datetime,@StartDate,103)
			   ,@MeterNumber
			   ,getdate()
			   ,@NumPersonWater)
		 
	else
			UPDATE [dbo].[MAS_Apartment_Service_Living]
			   SET [LivingTypeId] = @LivingType
				  ,[ProjectCd] = @ProjectCd
				  ,[ProviderCd] = @ProviderCd
				  ,[ApartmentId] = @ApartmentId
				  ,[ContractNo] = @ContractNo
				  ,[ContractDt] = convert(datetime,@ContractDate,103)
				  ,[EmployeeCd] = @EmployeeCd
				  ,[DeliverName] = @DeliverName
				  ,[CustId] = @CustId
				  ,[CustName] = @CustName
				  ,[CustPhone] = @CustPhone
				  ,[Note] = @Note
				  ,[MeterSeri] = @MeterSerial
				  ,[MeterDate] = convert(datetime,@StartDate,103)
				  ,[MeterNum] = @MeterNumber
				  ,MeterLastDt = convert(datetime,@StartDate,103)
				  ,MeterLastNum = @MeterNumber
				  ,NumPersonWater = @NumPersonWater
			 WHERE LivingId = @LivingId

	end try
	begin catch
		declare	@ErrorNum				int,
				@ErrorMsg				varchar(200),
				@ErrorProc				varchar(50),

				@SessionID				int,
				@AddlInfo				varchar(max)

		set @ErrorNum					= error_number()
		set @ErrorMsg					= 'sp_Hom_Insert_Service_Living ' + error_message()
		set @ErrorProc					= error_procedure()

		set @AddlInfo					= '@UserID ' + @UserID 

		exec utl_Insert_ErrorLog @ErrorNum, @ErrorMsg, @ErrorProc, 'ServiceLiving', 'Ins', @SessionID, @AddlInfo
	end catch