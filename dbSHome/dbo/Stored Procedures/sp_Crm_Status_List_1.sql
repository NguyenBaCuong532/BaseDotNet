










CREATE procedure [dbo].[sp_Crm_Status_List] 
	@UserId nvarchar(300),
	@statusKey nvarchar(50)
as
	begin try 
		 
	--1
		select   statusId
				,statusName
				,color
			FROM   CRM_Status mt
			where mt.statusKey = @statusKey
				and statusId > 0
				and mt.isActived = 1
			order by mt.statusId
			

	end try
	begin catch
		declare	@ErrorNum				int,
				@ErrorMsg				varchar(200),
				@ErrorProc				varchar(50),

				@SessionID				int,
				@AddlInfo				varchar(max)

		set @ErrorNum					= error_number()
		set @ErrorMsg					= 'sp_Crm_Get_Customer_IssueType ' + error_message()
		set @ErrorProc					= error_procedure()

		set @AddlInfo					= ' '

		exec utl_Insert_ErrorLog @ErrorNum, @ErrorMsg, @ErrorProc, 'IssueType', 'GET', @SessionID, @AddlInfo
	end catch