


CREATE procedure [dbo].[sp_crm_user_by_search]
	@UserId nvarchar(450),
	@userIds nvarchar(max) = null,
	@filter nvarchar(50) = null
as
	begin try 
			declare @tbUsers TABLE 
			(
				userId uniqueidentifier null
			)

			if @userIds is not null
			begin
				insert into @tbUsers 
				select part from [dbo].SplitString(@userIds,',')
			end

			select value		= lower(cast(c.userId as varchar(50)))
				  ,name			= c.FullName ---+ ' - ' + isnull(pt.positionTypeName,'')
				  ,icon_is		= 1
				  ,icon			= null
			 FROM Users c 
			  where (c.userId in (select userId from @tbUsers)
				or c.Email = @filter 
				or c.phone = @filter
				or c.loginName like @filter
				)
		

	end try
	begin catch
		declare	@ErrorNum				int,
				@ErrorMsg				varchar(200),
				@ErrorProc				varchar(50),

				@SessionID				int,
				@AddlInfo				varchar(max)

		set @ErrorNum					= error_number()
		set @ErrorMsg					= 'sp_crm_customer_by_search ' + error_message()
		set @ErrorProc					= error_procedure()

		set @AddlInfo					= ' '

		exec utl_Insert_ErrorLog @ErrorNum, @ErrorMsg, @ErrorProc, 'CustomerCate', 'GET', @SessionID, @AddlInfo
	end catch