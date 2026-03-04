



CREATE procedure [dbo].[sp_User_Get_FeedbackTypes]
	@clientId nvarchar(50) = null
as
	begin try		

		SELECT [FeedbackTypeId]
			  ,[FeedbackTypeName]
		FROM [MAS_FeedbackType] a
		where exists(select * FROM PAR_AppClient where appId = a.AppId and (clientId = @clientId or clientid = 'swagger')) 
	end try
	begin catch
		declare	@ErrorNum				int,
				@ErrorMsg				varchar(200),
				@ErrorProc				varchar(50),

				@SessionID				int,
				@AddlInfo				varchar(max)

		set @ErrorNum					= error_number()
		set @ErrorMsg					= 'sp_User_Get_FeedbackTypes ' + error_message()
		set @ErrorProc					= error_procedure()

		set @AddlInfo					= ' '

		exec utl_Insert_ErrorLog @ErrorNum, @ErrorMsg, @ErrorProc, 'Feedbacks', 'GET', @SessionID, @AddlInfo
	end catch