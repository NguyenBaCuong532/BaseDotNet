




CREATE procedure [dbo].[sp_Hom_Card_Internal_Set]
	@UserID	nvarchar(450),
	@CustId nvarchar(50),
	@EmployeeId nvarchar(20),
	@CardCd nvarchar(50),
	@IssueDate nvarchar(20),
	@ExpireDate nvarchar(20),
	@CardName nvarchar(100),
	@ProjectCd nvarchar(30)
as
	begin try	
	declare @valid bit = 1
	declare @messages nvarchar(200) = ''
	declare @CardTypeId int
	
	set @CardTypeId = 2 --the noi bo

	--if not (@EmployeeId is null or @EmployeeId = '')
	--	set @CustId = (select top 1 CustId from [dbSHRM].[dbo].[Employees] WHERE EmployeeCd = @EmployeeId)

		if not exists(select * from MAS_CardBase where Code = @CardCd)	
		begin
			set @Valid = 0
			set @Messages = N'Không tìm thấy thông tin mã thẻ [' + @CardCd + N'] trong kho số!' 
		end
		else if exists(select cardId from MAS_Cards where CardCd = @CardCd and Card_St < 3)
			begin
				set @Valid = 0
				set @Messages = N'Số thẻ [' + @CardCd + N'] đang được sử dụng, Cần phải khóa trước khi xóa!' 
			end

		else if not exists(select * from [MAS_Cards] where [CardCd] = @CardCd)
		begin
			--if not exists(select 1 from MAS_Customers where CustId = @CustId)
			--	INSERT INTO [dbo].[MAS_Customers]
			--	   ([CustId]
			--	   ,[Cif_No]
			--	   ,[FullName]
			--	   ,[FirstName]
			--	   ,[LastName]
			--	   ,[IsSex]
			--	   ,[Birthday]
			--	   ,[Phone]
			--	   ,[Phone2]
			--	   ,[Email]
			--	   ,[Email2]
			--	   ,[Pass_No]
			--	   ,[Pass_Dt]
			--	   ,[Pass_Plc]
			--	   ,[Address]
			--	   ,[IsForeign]
			--	   ,[CountryCd]
			--	   )
			--SELECT  [custId]
			--	   ,[cif_No]
			--	   ,case when cust_Type = 0 then [full_Name] else [com_Name] end
			--	   ,[first_Name]
			--	   ,[last_Name]
			--	   ,[sex]
			--	   ,[birthday]
			--	   ,[phone1]
			--	   ,[phone2]
			--	   ,[email1]
			--	   ,[email2]
			--	   ,[idcard_No]
			--	   ,[idcard_Issue_Dt]
			--	   ,[idcard_Issue_Plc]
			--	   ,res_Add1 
			--			+ case when res_Add2 is null then '' else ', ' + res_Add2 end
			--			+ case when res_Add3 is null then '' else ', ' + res_Add3 end
			--			+ case when res_Add4 is null then '' else ', ' + res_Add4 end
			--	   ,[is_Foreign]
			--	   ,[res_Cntry]
			--  FROM dbSSBigTec.dbo.[gr010mb]
			--  WHERE CustId = @CustId

			INSERT INTO [dbo].[MAS_Cards]
			   ([CardCd]
			   ,[IssueDate]
			   ,[ExpireDate]
			   ,[Card_St]
			   ,[IsClose]
			   ,IsDaily
			   ,[IsVip]
			   ,CustId
			   ,CardTypeId
			   ,CardName
			   ,ProjectCd
			   ,created_by 
			   )
			VALUES
			   (@CardCd
			   ,getdate()
			   ,isnull(convert(date,@ExpireDate,103),Getdate())
			   ,1
			   ,0
			   ,0
			   ,1
			   ,@CustId
			   ,@CardTypeId
			   ,@CardName
			   ,@ProjectCd
			   ,@UserID
			   )

			   UPDATE MAS_CardBase SET IsUsed = 1 WHERE Code = @CardCd 
			end
		else
		
		   UPDATE [dbo].[MAS_Cards]
			   SET [CustId] = @CustId
				  --,[IssueDate] = isnull(convert(date,@IssueDate,103),[IssueDate])
				  ,[ExpireDate] = isnull(convert(date,@ExpireDate,103),[ExpireDate])
				  ,CardName = @CardName
				  ,ProjectCd = @ProjectCd
			WHERE [CardCd] = @CardCd 
	
		select @valid as valid
			  ,@messages as [messages]
	
	end try
	begin catch
		declare	@ErrorNum				int,
				@ErrorMsg				varchar(200),
				@ErrorProc				varchar(50),

				@SessionID				int,
				@AddlInfo				varchar(max)

		set @ErrorNum					= error_number()
		set @ErrorMsg					= 'sp_Hom_Card_Internal_Set ' + error_message()
		set @ErrorProc					= error_procedure()

		set @AddlInfo					= '@CardCd '  + isnull(@CardCd,'NULL')

		exec utl_Insert_ErrorLog @ErrorNum, @ErrorMsg, @ErrorProc, 'Card', 'Insert', @SessionID, @AddlInfo
		
		select @valid as valid
			  ,@messages as [messages]
	end catch