



CREATE procedure [dbo].[sp_Hom_Apartment_Household_Set]
	@UserID	nvarchar(450),
	@CustId	nvarchar(50),
	@IsResident bit, 
	@ResAdd1 nvarchar(250),
	@ContactAdd1 nvarchar(250),	
	@PassNo nvarchar(50),
	@PassDate nvarchar(10),
	@PassPlace nvarchar(100),
	@ApartmentId int
as
	begin try		
	

	IF NOT EXISTS(SELECT CustId FROM MAS_Customer_Household WHERE CustId = @custId and ApartmentId = @ApartmentId)
		INSERT INTO [dbo].MAS_Customer_Household
           ([ApartmentId]
           ,CustId
           ,[IsResident]
           ,[ResAdd1]
           ,[ContactAdd1]
           ,[Pass_No]
           ,[Pass_I_Dt]
           ,[Pass_I_Plc]
           ,[sysDate])
     VALUES(
            @ApartmentId
           ,@CustId
           ,@IsResident
           ,@ResAdd1
           ,@ContactAdd1
           ,@PassNo
           ,convert(datetime,@PassDate,103)
           ,@PassPlace
           ,getdate()
		   )
		--FROM MAS_Customers 
		--WHERE Cif_No = @Cifno and ApartmentId = @ApartmentId
	ELSE
			UPDATE t
			   SET 
				--[ApartmentId] = @ApartmentId
				  --,CustId = @CifNo
				   [IsResident] = @IsResident
				  ,[ResAdd1] = @ResAdd1
				  ,[ContactAdd1] = @ContactAdd1
				  ,[Pass_No] = @PassNo
				  ,[Pass_I_Dt] = convert(datetime,@PassDate,103)
				  ,[Pass_I_Plc] = @PassPlace
			FROM MAS_Customer_Household t inner join MAS_Customers t2 on t.CustId = t2.CustId
			 WHERE t.CustId = @custId and t.ApartmentId = @ApartmentId

	end try
	begin catch
		declare	@ErrorNum				int,
				@ErrorMsg				varchar(200),
				@ErrorProc				varchar(50),

				@SessionID				int,
				@AddlInfo				varchar(max)

		set @ErrorNum					= error_number()
		set @ErrorMsg					= 'sp_Insert_Apartment_Household ' + error_message()
		set @ErrorProc					= error_procedure()

		set @AddlInfo					= '@custId ' + @custId 

		exec utl_Insert_ErrorLog @ErrorNum, @ErrorMsg, @ErrorProc, 'Household', 'Insert', @SessionID, @AddlInfo
	end catch