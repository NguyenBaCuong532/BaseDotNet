
create procedure [dbo].[sp_COR_User_Link_Point_ByUserId]
	@UserId		nvarchar(450),
	@dbcr_flg	bit,
	@Offset				int				= 0,
	@PageSize			int				= 10,
	@Total				int out,
	@TotalFiltered		int out
as
	begin try
		declare @month int
		declare @year int

		set		@Offset					= isnull(@Offset, 0)
		set		@PageSize				= isnull(@PageSize, 10)
		set		@Total					= isnull(@Total, 0)

		if		@PageSize	= 0			set @PageSize	= 10
		if		@Offset		< 0			set @Offset		=  0

	begin
		--select	@Total					= count(t.po_tnx_id)
		--		FROM [dbo].ca009tb t
		--			join ca009mb a on t.po_id = a.po_id 
		--			join UserInfo u on a.userid = u.userId 
		--		WHERE u.UserId = @userId
		--			and t.dbcr_flg = @dbcr_flg
		set @TotalFiltered = @Total

	-- all
		SELECT 1
			  -- t.Ref_No 
			  --,t.tnx_no
			  --,t.tnx_info
			  --,t.remark 
			  --,t.Point 
			  --,[dbo].[fn_Get_TimeAgo1] (t.tnx_dt,getdate()) as DateAgo
			  ----,N'Tháng ' + cast(month(t.tnx_dt)as nvarchar(2)) + '/' + cast(year(t.tnx_dt)as nvarchar(4)) TimeGroup
			  --,t.tnx_type 
			  --,DATEDIFF(SECOND,{d '1970-01-01'},t.tnx_dt) as tnx_time
		FROM 
			 UserInfo u 
			-- join ca009mb a on a.userid = u.userId 
			--join [dbo].ca009tb t on t.po_id = a.po_id 
		WHERE u.UserId = @userId 
			and 0=1
			--and t.dbcr_flg = @dbcr_flg
		ORDER BY u.agreed_dt DESC
				  offset @Offset rows	
					fetch next @PageSize rows only
	end
		

	end try
	begin catch
		declare	@ErrorNum				int,
				@ErrorMsg				varchar(200),
				@ErrorProc				varchar(50),

				@SessionID				int,
				@AddlInfo				varchar(max)

		set @ErrorNum					= error_number()
		set @ErrorMsg					= 'sp_COR_User_Point_ByUserId ' + error_message()
		set @ErrorProc					= error_procedure()

		set @AddlInfo					= ' '

		exec utl_ErrorLog_set @ErrorNum, @ErrorMsg, @ErrorProc, 'PointTransaction', 'GET', @SessionID, @AddlInfo
	end catch