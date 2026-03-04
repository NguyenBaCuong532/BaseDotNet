









CREATE procedure [dbo].[sp_Crm_Base_Type_List] 
	 @clientId				nvarchar(50)
	,@userId				nvarchar(450)
as
	begin try 
		 
		 SELECT [base_type]
			   ,[base_name]
			   ,[base_desc]
			   ,value	= [base_type]
			   ,name	= [base_name] + '-' + [base_desc]
		  FROM [MAS_Base_Type] a
		 -- where exists(select userid from MAS_Category_User b
			--	join dbo.ClientWebs c on b.webId = c.id
			--where base_type = a.base_type and userid = @userId 
			--	and (c.clientId = @clientId or clientIdDev = @clientId)
			--	)
			--	and [base_type] > 0
			order by base_type 
	end try
	begin catch
		declare	@ErrorNum				int,
				@ErrorMsg				varchar(200),
				@ErrorProc				varchar(50),

				@SessionID				int,
				@AddlInfo				varchar(max)

		set @ErrorNum					= error_number()
		set @ErrorMsg					= 'sp_Crm_Base_Type_List' + error_message()
		set @ErrorProc					= error_procedure()

		set @AddlInfo					= ' '

		exec utl_Insert_ErrorLog @ErrorNum, @ErrorMsg, @ErrorProc, 'BaseType', 'GET', @SessionID, @AddlInfo
	end catch