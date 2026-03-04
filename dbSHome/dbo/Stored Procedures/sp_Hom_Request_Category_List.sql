




CREATE procedure [dbo].[sp_Hom_Request_Category_List]
	@userId			nvarchar(200),
	@categoryType	int,
	@language		nvarchar(50)
as
	begin try		
		declare @ApartmentId bigint
		declare @langVi bit
		if @language = 'vi-VN' or @language = 'vi' or @language = null
			set @langVi = 1
		else 
			set @langVi = 0

		SELECT [RequestCategoryId]
			  ,case when @langVi = 1 then RequestCategoryName else requestCategoryName_en end as RequestCategoryName
			  ,[Code]
		  FROM [dbSHome].[dbo].MAS_Request_Category
		  WHERE categoryType = @categoryType

		SELECT [RequestTypeId]
			  ,case when @langVi = 1 then [RequestTypeName] else RequestTypeName_en end as RequestTypeName
			  ,[RequestCategoryId]
			  ,[Category]
			  ,[IsFree]
			  ,[Price]
			  ,[Unit]
			  ,[Note]
			  ,iconUrl
			  ,sub_prod_cd
			  ,chat_cd as role_id
		FROM [dbo].MAS_Request_Types
		WHERE isReady = 1

	end try
	begin catch
		declare	@ErrorNum				int,
				@ErrorMsg				varchar(200),
				@ErrorProc				varchar(50),

				@SessionID				int,
				@AddlInfo				varchar(max)

		set @ErrorNum					= error_number()
		set @ErrorMsg					= 'sp_Hom_Request_Category_List ' + error_message()
		set @ErrorProc					= error_procedure()

		set @AddlInfo					= ' '

		exec utl_Insert_ErrorLog @ErrorNum, @ErrorMsg, @ErrorProc, 'RequestType', 'GET', @SessionID, @AddlInfo
	end catch