




CREATE procedure [dbo].[sp_Hom_Mas_Customer_Set]
	@CustId	nvarchar(450),
	@avatar_url nvarchar(450),
	@birthday nvarchar(450),
	@email1 nvarchar(250) ,
	@full_name nvarchar(250),
	@phone1 nvarchar(50), 
	@sex bit,
	@userId nvarchar(50),
	@cif_no nvarchar(250),
	@idcard_no nvarchar(20),
	@idcard_issue_dt nvarchar(250),
	@idcard_issue_plc nvarchar(250),
	@res_add nvarchar(250),
	@res_cntry nvarchar(250)

as
	begin try	
		begin
			if not exists(select 1 from MAS_Customers where CustId = @CustId)
				INSERT INTO dbSHome.[dbo].[MAS_Customers]
					([CustId]
					,[Cif_No]
					,[FullName]
					,[FirstName]
					,[LastName]
					,[IsSex]
					,[Birthday]
					,[Phone]
					,[Phone2]
					,[Email]
					,[Email2]
					,[Pass_No]
					,[Pass_Dt]
					,[Pass_Plc]
					,[Address]
					,[IsForeign]
					,[CountryCd]
					)
				VALUES (
					@CustId
					,@cif_no
					,@full_name
					,null
					,null
					,@sex
					,CONVERT(datetime,@birthday,103)
					,@phone1
					,null
					,@email1
					,null
					,@idcard_no
					,CONVERT(datetime,@idcard_issue_dt,103)
					,@idcard_issue_plc
					,@res_add
					,null
					,@res_cntry
				
				);
		end
	end try
	begin catch
		declare	@ErrorNum				int,
				@ErrorMsg				varchar(200),
				@ErrorProc				varchar(50),

				@SessionID				int,
				@AddlInfo				varchar(max)

		set @ErrorNum					= error_number()
		set @ErrorMsg					= 'sp_Hom_Mas_Customer_Set ' + error_message()
		set @ErrorProc					= error_procedure()

		set @AddlInfo					= '@Cif_no ' + @CustId 

		exec utl_Insert_ErrorLog @ErrorNum, @ErrorMsg, @ErrorProc, 'sp_Hom_Mas_Customer_Set', 'Insert', @SessionID, @AddlInfo
	end catch