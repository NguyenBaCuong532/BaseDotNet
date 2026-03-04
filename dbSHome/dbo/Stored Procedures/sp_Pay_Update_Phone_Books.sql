

CREATE procedure [dbo].[sp_Pay_Update_Phone_Books]
	@UserID				nvarchar(450),
	@XML				nvarchar(max)
	
as
	begin try	
		declare	@XMLID					int,
				@XMLRootName			varchar(300)
		set		@XML					= dbo.ufn_Replace_XmlChars(@XML)
		set		@XMLRootName			= dbo.ufn_Get_Element_Level_2(@XML)
		
		--exec utl_Insert_ErrorLog 0, @XML, 0, 'PhoneBooks', @XMLRootName, 0, @XMLNameLevel3

		exec	sp_xml_preparedocument	@XMLID out, @XML

		UPDATE t
		   SET [FullName] = x.fullName
			  ,[AvatarUrl] = x.avatarUrl
			  ,[Email] = x.email
			  ,isWallet = x.isWallet
			  ,walletCd = x.walletCd			  
			FROM [dbo].[WAL_PhoneBooks] t 
				inner join openxml (@XMLID, @XMLRootName, 2) 
		with	(
				phone				nvarchar(50),
				fullName			nvarchar(200),
				email				nvarchar(200),	
				avatarUrl			nvarchar(300),
				isWallet			bit,
				walletCd			nvarchar(30)
				) x	on t.Phone = x.Phone
		 WHERE t.UserId = @userId

		INSERT INTO [dbo].[WAL_PhoneBooks]
			   ([UserId]
			   ,[FullName]
			   ,[AvatarUrl]
			   ,[ContactName]
			   ,[Phone]
			   ,[Email]
			   ,[isWallet]
			   ,walletCd
			   ,[CreateDt]
			   )
		select	@UserID
			   ,x.fullName
			   ,x.avatarUrl
			   ,null
			   ,x.phone
			   ,x.email
			   ,x.isWallet
			   ,x.walletCd			  
			   ,getdate()
		from	openxml (@XMLID, @XMLRootName, 2) 
		with	(
				phone				nvarchar(50),
				fullName			nvarchar(200),
				email				nvarchar(200),	
				avatarUrl			nvarchar(300),
				isWallet			bit,
				walletCd			nvarchar(30)
				) x		
			where not x.phone in (select Phone from [WAL_PhoneBooks] where UserId = @UserID)
		
		exec sp_xml_removedocument @XMLID		
		
	end try
	begin catch
		declare	@ErrorNum				int,
				@ErrorMsg				varchar(200),
				@ErrorProc				varchar(50),

				@SessionID				int,
				@AddlInfo				varchar(max)

		set @ErrorNum					= error_number()
		set @ErrorMsg					= 'sp_Pay_Update_Phone_Books ' + error_message()
		set @ErrorProc					= error_procedure()

		set @AddlInfo					= '@XML=' + @XML

		exec utl_Insert_ErrorLog @ErrorNum, @ErrorMsg, @ErrorProc, 'PhoneBooks', 'INS', @SessionID, @AddlInfo
	end catch