CREATE procedure [dbo].[sp_Hom_Card_Status_List]
	@UserId UNIQUEIDENTIFIER = NULL,
  @all		nvarchar(250) = '-1',
  @AcceptLanguage NVARCHAR(50) = 'vi'
as
	begin try		

		SELECT @all as [StatusId]
			  ,N'Tất cả' as [StatusName]
			  ,value = @all
			  ,name = N'Tất cả'
		where @all is not null 
		UNION ALL
		SELECT [StatusId]
			  ,[StatusName]
			  ,value = [StatusId]
			  ,name = [StatusName]
		FROM [MAS_CardStatus]

	end try
	begin catch
		declare	@ErrorNum				int,
				@ErrorMsg				varchar(200),
				@ErrorProc				varchar(50),

				@SessionID				int,
				@AddlInfo				varchar(max)

		set @ErrorNum					= error_number()
		set @ErrorMsg					= 'sp_Hom_Get_CardStatus ' + error_message()
		set @ErrorProc					= error_procedure()

		set @AddlInfo					= ' '

		exec utl_Insert_ErrorLog @ErrorNum, @ErrorMsg, @ErrorProc, 'CardStatus', 'GET', @SessionID, @AddlInfo
	end catch