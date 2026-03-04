




CREATE procedure [dbo].[sp_Crm_Opportunity_Assign]
	@opp_Id	bigint,
	@UserId nvarchar(250),
	@assignRole int,
	@Used bit
as
	begin try		
	if @Used = 1
	begin
		if not exists(select * from CRM_Opportunity_Assign where opp_Id = @opp_Id and UserId = @UserId)
			INSERT INTO [dbo].CRM_Opportunity_Assign
			   (opp_Id
			   ,[UserId]
			   ,assignRole)
			VALUES
			   (@opp_Id
			   ,@UserId
			   ,@assignRole
			   )
		end
		ELSE
			DELETE FROM [dbo].CRM_Opportunity_Assign
			WHERE opp_Id = @opp_Id 
				AND [UserId] = @UserId 
				and not exists(select id from CRM_Opportunity where create_by = @UserId)


	end try
	begin catch
		declare	@ErrorNum				int,
				@ErrorMsg				varchar(200),
				@ErrorProc				varchar(50),

				@SessionID				int,
				@AddlInfo				varchar(max)

		set @ErrorNum					= error_number()
		set @ErrorMsg					= 'sp_Crm_Opportunity_Assign ' + error_message()
		set @ErrorProc					= error_procedure()

		set @AddlInfo					= '@UserID '  

		exec utl_Insert_ErrorLog @ErrorNum, @ErrorMsg, @ErrorProc, 'OpportunityAssign', 'Update', @SessionID, @AddlInfo
	end catch