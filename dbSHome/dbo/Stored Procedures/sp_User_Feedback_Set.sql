




CREATE procedure [dbo].[sp_User_Feedback_Set]
	@UserID	nvarchar(450),
	@ClientID	nvarchar(50),
	@FeedbackTypeId int,
	@Title nvarchar(100),
	@Comment nvarchar(max)
	
as
	begin try		
		declare @feedbackId bigint
		--declare @regUserId int
		declare @appId int 
		declare @ApartmentId bigint

		set @appId = (select appid from PAR_AppClient where ClientId = @ClientID)

		if @ApartmentId is null or @ApartmentId = 0
			set @ApartmentId = (SELECT top 1 ApartmentId FROM MAS_Apartments a 
			inner join UserInfo b on b.loginName = a.UserLogin WHERE b.UserId = @UserID
				)
		if @ApartmentId is null
			set @ApartmentId = (select top 1 a.ApartmentId FROM [MAS_Apartments] a 
					join UserInfo u on a.UserLogin = u.loginName 
					  WHERE exists(select userId from UserInfo 
						where userid = @UserId and CustId = u.CustId)
					order by isnull(a.isMain,0) desc
				)

		--IF (@regUserId>0)
		--begin
			INSERT INTO [dbo].MAS_Feedbacks
			   (UserId
			   ,Title
			   ,Comment
			   ,[InputDate]
			   ,FeedbackTypeId
			   ,AppId 
			   ,ClientId
			   ,ApartmentId
			   )
			VALUES
			   (
			    @UserId
			   ,@Title
			   ,@Comment
			   ,getdate()
			   ,@FeedbackTypeId
			   ,@appId 
			   ,@ClientID
			   ,@ApartmentId
			   )

			set @feedbackId = @@IDENTITY

			select * from MAS_Feedbacks where FeedbackId = @feedbackId

		--end
	end try
	begin catch
		declare	@ErrorNum				int,
				@ErrorMsg				varchar(200),
				@ErrorProc				varchar(50),

				@SessionID				int,
				@AddlInfo				varchar(max)

		set @ErrorNum					= error_number()
		set @ErrorMsg					= 'sp_User_Feedback_Set ' + error_message()
		set @ErrorProc					= error_procedure()

		set @AddlInfo					= '@ ' 

		exec utl_Insert_ErrorLog @ErrorNum, @ErrorMsg, @ErrorProc, 'Feedbacks', 'Insert', @SessionID, @AddlInfo
	end catch