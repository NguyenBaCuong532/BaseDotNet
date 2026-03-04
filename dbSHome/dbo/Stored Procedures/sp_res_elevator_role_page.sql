

CREATE   procedure [dbo].[sp_res_elevator_role_page]
	@UserId	UNIQUEIDENTIFIER,
	@filter nvarchar(200),
	@Offset				int				= 0,
	@PageSize			int				= 10,
	@gridWidth			int = 0,
	@acceptLanguage		NVARCHAR(50) = N'vi-VN'
as
	begin try	
		declare @Total		bigint
		declare @GridKey	nvarchar(100) = 'view_elevator_role_page'

		set		@Offset					= isnull(@Offset, 0)
		set		@PageSize				= isnull(@PageSize, 10)
		set		@Total					= isnull(@Total, 0)
		set		@filter					= isnull(@filter,'')


		if		@PageSize	= 0			set @PageSize	= 10
		if		@Offset		< 0			set @Offset		=  0

		select	@Total					= count(a.Id)
		from ELE_CardRole a 
		--root	
		select recordsTotal = @Total
			  ,recordsFiltered = @Total
			  ,gridKey = @GridKey
			  ,valid = 1
		
		--grid config
		IF @Offset = 0
		BEGIN
			SELECT *
			FROM [dbo].fn_config_list_gets_lang(@GridKey, 0, @acceptLanguage)
			ORDER BY [ordinal];
		END

		SELECT   CR.Id
				,CR.RoleName
				,CR.created_at
				,CR.created_by 
		FROM ELE_CardRole AS CR 
		ORDER BY  CR.Id
			offset @Offset rows	
				fetch next @PageSize rows only

	end try
	begin catch
			declare	@ErrorNum				int,
					@ErrorMsg				varchar(200),
					@ErrorProc				varchar(50),

					@SessionID				int,
					@AddlInfo				varchar(max)

			set @ErrorNum					= error_number()
			set @ErrorMsg					= 'sp_res_elevator_role_page ' + error_message()
			set @ErrorProc					= error_procedure()

			set @AddlInfo					= '@UserID ' + cast(@UserID as varchar(50)) 

			exec utl_Insert_ErrorLog @ErrorNum, @ErrorMsg, @ErrorProc, 'Elevator_CardRole', 'GET', @SessionID, @AddlInfo
		end catch