





CREATE procedure [dbo].[sp_Cor_Customer_Save]
	@UserID	nvarchar(450),
	@CustId	nvarchar(50)
as
	begin try		
		INSERT INTO [dbo].[MAS_Customers_Save]
			   ([CustId]
			   ,[Cif_No]
			   ,[FullName]
			   ,[FirstName]
			   ,[LastName]
			   ,[AvatarUrl]
			   ,[IsSex]
			   ,[Birthday]
			   ,[RelationId]
			   ,[Phone]
			   ,[Phone2]
			   ,[Email]
			   ,[Email2]
			   ,[Pass_No]
			   ,[Pass_Dt]
			   ,[Pass_Plc]
			   ,[Address]
			   ,[ProvinceCd]
			   ,[IsForeign]
			   ,[CountryCd]
			   ,[IsContact]
			   ,[IsEmployee]
			   ,[sysDate]
			   ,[IsAdmin]
			   ,[ApartmentId]
			   ,[IsHost]
			   ,[Auth_St]
			   ,[Auth_Dt]
			   ,[Auth_Id]
			   ,[saveDate]
			   ,[saveId]
			   )
		SELECT [CustId]
			  ,[Cif_No]
			  ,[FullName]
			  ,[FirstName]
			  ,[LastName]
			  ,[AvatarUrl]
			  ,[IsSex]
			  ,[Birthday]
			  ,[RelationId]
			  ,[Phone]
			  ,[Phone2]
			  ,[Email]
			  ,[Email2]
			  ,[Pass_No]
			  ,[Pass_Dt]
			  ,[Pass_Plc]
			  ,[Address]
			  ,[ProvinceCd]
			  ,[IsForeign]
			  ,[CountryCd]
			  ,[IsContact]
			  ,[IsEmployee]
			  ,[sysDate]
			  ,[IsAdmin]
			  ,[ApartmentId]
			  ,[IsHost]
			  ,[Auth_St]
			  ,[Auth_Dt]
			  ,[Auth_Id]
			  ,getdate()
			  ,@UserID
		  FROM  MAS_Customers t2 
		  WHERE CustId = @CustId

	end try
	begin catch
		declare	@ErrorNum				int,
				@ErrorMsg				varchar(200),
				@ErrorProc				varchar(50),

				@SessionID				int,
				@AddlInfo				varchar(max)

		set @ErrorNum					= error_number()
		set @ErrorMsg					= 'sp_Cor_Customer_Save ' + error_message()
		set @ErrorProc					= error_procedure()

		set @AddlInfo					= '@User ' + @UserID 

		exec utl_Insert_ErrorLog @ErrorNum, @ErrorMsg, @ErrorProc, 'Customer', 'Insert', @SessionID, @AddlInfo
	end catch