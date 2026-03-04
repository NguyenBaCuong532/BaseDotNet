









CREATE procedure [dbo].[sp_Crm_Issue_Types] 
	@UserId nvarchar(300)
as
	begin try 
		 
	--1
		 select  t.IssueTypeId 
				,t.IssueTypeName
				,value	= IssueTypeId
			    ,name	= IssueTypeName
			FROM CRM_IssueType t
			ORDER BY t.IssueTypeId 
			

	end try
	begin catch
		declare	@ErrorNum				int,
				@ErrorMsg				varchar(200),
				@ErrorProc				varchar(50),

				@SessionID				int,
				@AddlInfo				varchar(max)

		set @ErrorNum					= error_number()
		set @ErrorMsg					= 'sp_Crm_Issue_Types ' + error_message()
		set @ErrorProc					= error_procedure()

		set @AddlInfo					= ' '

		exec utl_Insert_ErrorLog @ErrorNum, @ErrorMsg, @ErrorProc, 'IssueType', 'GET', @SessionID, @AddlInfo
	end catch