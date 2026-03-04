










CREATE procedure [dbo].[sp_Pay_Service_List]
	@UserId	nvarchar(450),
	@filter nvarchar(50)
as
	begin try
		set @filter = isnull(@filter,'')
	--1
		SELECT [WalServiceCd] as [ServiceCd]
			  ,[ServiceName]
			  ,[ServiceViewUrl]
			  ,[intOrder]
			  ,[IsFlage]
			  ,b.ProviderShort
			  ,b.ProviderName
			  ,b.Phone
			  ,t.ServiceKey
			  ,[WalServiceCd] as value
			  ,[ServiceName] as name
		  FROM [WAL_Services] t
			left join WAL_Providers b on t.ProviderCd = b.ProviderCd 
		WHERE t.IsFlage = 1
			and t.ServiceName like @filter + '%'
		Order by t.intOrder 
		
	end try
	begin catch
		declare	@ErrorNum				int,
				@ErrorMsg				varchar(200),
				@ErrorProc				varchar(50),

				@SessionID				int,
				@AddlInfo				varchar(max)

		set @ErrorNum					= error_number()
		set @ErrorMsg					= 'sp_Pay_Service_List ' + error_message()
		set @ErrorProc					= error_procedure()

		set @AddlInfo					= ' '

		exec utl_Insert_ErrorLog @ErrorNum, @ErrorMsg, @ErrorProc, 'WalService', 'GET', @SessionID, @AddlInfo
	end catch