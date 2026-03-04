




CREATE procedure [dbo].[sp_Crm_Group_get]
	@UserID nvarchar(450)
	

	
as 

begin try
	
	select GroupId as value
		  ,GroupName as name
	from CRM_Group
	where ParentId is null

end try
	begin catch
		declare	@ErrorNum				int,
				@ErrorMsg				varchar(200),
				@ErrorProc				varchar(50),

				@SessionID				int,
				@AddlInfo				varchar(max)

		set @ErrorNum					= error_number()
		set @ErrorMsg					= '[sp_Crm_Get_Group_Tree] ' + error_message()
		set @ErrorProc					= error_procedure()

		set @AddlInfo					= '@GroupId ' 

		exec utl_Insert_ErrorLog @ErrorNum, @ErrorMsg, @ErrorProc, 'Group', 'GET', @SessionID, @AddlInfo
	end catch