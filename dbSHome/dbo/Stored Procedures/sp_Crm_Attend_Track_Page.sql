




CREATE procedure [dbo].[sp_Crm_Attend_Track_Page]
	@UserId			nvarchar(450), 
	@Filter			nvarchar(100),
	@attendCd		nvarchar(30),
	@Status				int			= -1,
	@gridWidth			int			= 0,
	@Offset				int			= 0,
	@PageSize			int			= 10,
	@Total				int out,
	@TotalFiltered		int out
	,@gridKey			nvarchar(200) out
as
	begin try 
		set		@Offset					= isnull(@Offset, 0)
		set		@PageSize				= isnull(@PageSize, 10)
		set		@Total					= isnull(@Total, 0)
		set		@Filter					= isnull(@Filter,'')
		set		@attendCd				= isnull(@attendCd,'')

		if		@PageSize	<= 0			set @PageSize	= 10
		if		@Offset		< 0			set @Offset		=  0
		
		 
		select	@Total					= count(t.track_id)
			FROM  CRM_Attend_Track t
				join  CRM_Attend_Category r on t.attend_cd = r.attend_cd
			 where (@attendCd = '' or r.[attend_cd] = @attendCd)
				and (@Filter = '' or [ReferralCode] like @Filter or t.[Phone] like '%'+@Filter+'%' or t.[Email] like '%'+@Filter+'%')
				and (@Status = -1 or isnull(arrived_st,0) = @Status)
		set	@TotalFiltered = @Total

		if @Offset = 0
		begin
			SELECT * FROM dbo.fn_config_list_gets('view_Crm_Attend_Track_Page', @gridWidth) 
			ORDER BY [ordinal]
		end
	
		--1
		SELECT t.[track_id]
			  ,t.[attend_cd]
			  ,t.[contactName]
			  ,t.[Phone]
			  ,t.[Email]
			  ,t.[Note]
			  ,t.[child_name]
			  ,format(t.[child_birthday],'dd/MM/yyyy') as [child_birthday]
			  ,case when t.[learned_maplebear] = 1 then N'Có' else N'Không' end as [learned_maplebear]
			  ,t.[num_of_attend]
			  ,t.[ReferralCode]
			  ,t.[qrcode_url]
			  ,t.[Source]
			  ,format(t.[Createdate],'dd/MM/yyyy HH:mm:ss') as [Createdate]
			  ,isnull(t.[arrived_st],0) as [arrived_st]
			  ,t.[arrived_dt]
			  ,u.UserLogin as [arrived_id]
	 FROM  CRM_Attend_Track t
		join  CRM_Attend_Category r on t.attend_cd = r.attend_cd
		left join MAS_Users u on t.arrived_id = u .UserId 
	  where (@attendCd = '' or r.[attend_cd] = @attendCd)
			and (@Filter = '' or [ReferralCode] like @Filter or t.[Phone] like '%'+@Filter+'%' or t.[Email] like '%'+@Filter+'%')
			and (@Status = -1 or isnull(arrived_st,0) = @Status)
		ORDER BY t.[track_id]
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
		set @ErrorMsg					= 'sp_Crm_Attend_Track_Page ' + error_message()
		set @ErrorProc					= error_procedure()

		set @AddlInfo					= ' '

		exec utl_Insert_ErrorLog @ErrorNum, @ErrorMsg, @ErrorProc, 'Attend', 'GET', @SessionID, @AddlInfo
	end catch