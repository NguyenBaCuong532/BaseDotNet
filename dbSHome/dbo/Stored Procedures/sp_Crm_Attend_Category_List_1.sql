






CREATE procedure [dbo].[sp_Crm_Attend_Category_List]
	@userId	nvarchar(300)
	
as
	begin try		
	
		SELECT [attend_cd]
			  ,[attend_name]
			  ,[attend_desc]
			  ,value	= [attend_cd]
			  ,name		= [attend_name]
		  FROM [dbSHome].[dbo].[CRM_Attend_Category]
		  order by [attend_cd]
	 
	end try
	begin catch
		declare	@ErrorNum				int,
				@ErrorMsg				varchar(200),
				@ErrorProc				varchar(50),

				@SessionID				int,
				@AddlInfo				varchar(max)

		set @ErrorNum					= error_number()
		set @ErrorMsg					= 'sp_Crm_Attend_Category_List ' + error_message()
		set @ErrorProc					= error_procedure()

		set @AddlInfo					= '@UserID '  

		exec utl_Insert_ErrorLog @ErrorNum, @ErrorMsg, @ErrorProc, 'Opportunity_Role', 'Get', @SessionID, @AddlInfo
	end catch