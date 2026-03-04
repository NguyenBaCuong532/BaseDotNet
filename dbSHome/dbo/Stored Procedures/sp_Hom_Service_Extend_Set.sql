




CREATE procedure [dbo].[sp_Hom_Service_Extend_Set]
	 @UserID	nvarchar(450)
	,@ApartmentId bigint
	,@ExtendId int
	,@ContractType int
	,@ContractNo nvarchar(100)
	,@ContractDate nvarchar(10)
	,@ContractUser nvarchar(50)
	,@ContractPassword nvarchar(50)
	,@DeviceSerial nvarchar(50)
	,@DeviceName nvarchar(100)
	,@DeviceWarranty nvarchar(30)
	,@ProviderCd nvarchar(50)
	,@PackPriceId int
	,@CustId nvarchar(50)
	,@CustName nvarchar(200)
	,@CustPhone nvarchar(200)
	,@IsCompany bit
	,@CompanyName nvarchar(200)
	,@CompanyRepresent nvarchar(100)
	,@CompanyAddress nvarchar(300)
	,@CompanyCode nvarchar(50)

as
	begin try		
		declare @ProjectCd nvarchar(30)
		set @ProjectCd = (select a.ProjectCd from MAS_Apartments a join MAS_Rooms b on a.RoomCode = b.RoomCode join MAS_Buildings c on b.BuildingCd = c.BuildingCd where a.ApartmentId = @ApartmentId)
		
			if not exists(SELECT ApartmentId FROM [MAS_Apartment_Service_Extend] WHERE ExtendId = @ExtendId)
			BEGIN
				INSERT INTO [dbo].[MAS_Apartment_Service_Extend]
				   ([ContractTypeId]
				   ,[ProjectCd]
				   ,[ProviderCd]
				   ,[ApartmentId]
				   ,[ContractNo]
				   ,[ContractDt]
				   ,[ContractUser]
				   ,[ContractPassword]
				   --,[EmployeeCd]
				   ,[DeviceSeri]
				   ,[DeviceName]
				   ,[DeviceWarranty]
				   ,[PackPriceId]
				   ,[CustId]
				   ,[CustName]
				   ,[CustPhone]
				   ,[IsCompany]
				   ,[CompanyName]
				   ,[CompanyRepresent]
				   ,[CompanyAddress]
				   ,[CompanyCode]
				   --,[AccrualToDt]
				   --,[PayLastDt]
				   --,[IsDocumentUpload]
				   --,[IsClose]
				   --,[CloseDt]
				   ,[sysDate])
			 VALUES
				   (@ContractType
				   ,@ProjectCd
				   ,@ProviderCd
				   ,@ApartmentId
				   ,@ContractNo
				   ,convert(date,@ContractDate,103)
				   ,@ContractUser
				   ,@ContractPassword
				   --,@EmployeeCd, nvarchar(50),>
				   ,@DeviceSerial
				   ,@DeviceName
				   ,@DeviceWarranty
				   ,@PackPriceId
				   ,@CustId
				   ,@CustName
				   ,@CustPhone
				   ,@IsCompany
				   ,@CompanyName
				   ,@CompanyRepresent
				   ,@CompanyAddress
				   ,@CompanyCode
				   --,@AccrualToDt
				   --,@PayLastDt
				   --,@IsDocumentUpload
				   --,@IsClose
				   --,@CloseDt
				   ,getdate())

					   --set @ContractId = @@IDENTITY
			END
			ELSE
				UPDATE [dbo].[MAS_Apartment_Service_Extend]
				   SET [ContractTypeId] = @ContractType
					  ,[ProjectCd] = @ProjectCd
					  ,[ProviderCd] = @ProviderCd
					  ,[ApartmentId] = @ApartmentId
					  ,[ContractNo] = @ContractNo
					  ,[ContractDt] = convert(date,@ContractDate,103)
					  ,[ContractUser] = @ContractUser
					  ,[ContractPassword] = @ContractPassword
					  ,[DeviceSeri] = @DeviceSerial
					  ,[DeviceName] = @DeviceName
					  ,[DeviceWarranty] = @DeviceWarranty
					  ,[PackPriceId] = @PackPriceId
					  ,[CustId] = @CustId
					  ,[CustName] = @CustName
					  ,[CustPhone] = @CustPhone
					  ,[IsCompany] = @IsCompany
					  ,[CompanyName] = @CompanyName
					  ,[CompanyRepresent] = @CompanyRepresent
					  ,[CompanyAddress] = @CompanyAddress
					  ,[CompanyCode] = @CompanyCode
				 WHERE ExtendId = @ExtendId
		
		--EXECUTE [dbo].[sp_Hom_Get_Service_Contract_ById] 
		--	   @UserId
		--	  ,@ContractId

	end try
	begin catch
		declare	@ErrorNum				int,
				@ErrorMsg				varchar(200),
				@ErrorProc				varchar(50),

				@SessionID				int,
				@AddlInfo				varchar(max)

		set @ErrorNum					= error_number()
		set @ErrorMsg					= 'sp_Hom_Insert_Service_Extend ' + error_message()
		set @ErrorProc					= error_procedure()

		set @AddlInfo					= '@ApartmentId ' + cast(@ApartmentId as varchar)

		exec utl_Insert_ErrorLog @ErrorNum, @ErrorMsg, @ErrorProc, 'ContractExtend', 'Insert', @SessionID, @AddlInfo
	end catch