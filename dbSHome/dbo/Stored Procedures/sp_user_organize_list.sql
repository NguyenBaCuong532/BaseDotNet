



CREATE procedure [dbo].[sp_user_organize_list]
	@userId			nvarchar(450) ='81739c5c-2ca0-4e0f-acab-63373ea8a34a',
	@filter			nvarchar(100) = null
as
	begin try
		
			--set	@filter		= isnull(@filter,'')

			SELECT value = lower('9B2AB175-16FE-4A2E-88F4-F29974491FF5')
				  ,name = N'Công ty S-Service Hà Nội'
			Union 
			SELECT value = lower('DE78E748-D474-4E42-90C3-FC64ECC5FBB0')
				  ,name = N'Công ty Cổ phần S-Service Sài Gòn'
			Union 
			SELECT value = lower('EC46D5A6-A8F7-4BB7-A9B9-4F71DD59DB77')
				  ,name = N'Tập đoàn Sunshine HN'

	end try
	begin catch
		declare	@ErrorNum				int,
				@ErrorMsg				varchar(200),
				@ErrorProc				varchar(50),

				@SessionID				int,
				@AddlInfo				varchar(max)

		set @ErrorNum					= error_number()
		set @ErrorMsg					= 'sp_user_organize_list ' + error_message()
		set @ErrorProc					= error_procedure()

		set @AddlInfo					= ' '

		exec utl_ErrorLog_Set @ErrorNum, @ErrorMsg, @ErrorProc, 'org', 'GET', @SessionID, @AddlInfo
	end catch