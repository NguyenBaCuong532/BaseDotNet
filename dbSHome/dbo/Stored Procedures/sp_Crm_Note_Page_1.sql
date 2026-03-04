








CREATE procedure [dbo].[sp_Crm_Note_Page]
	@UserId	nvarchar(450), 
	@Offset				int				= 0,
	@PageSize			int				= 10,
	@CustId	nvarchar(450),  
	@Status int,
	@Filter nvarchar(50),
	@gridWidth			int				= 0,
	@Total				int out,
	@TotalFiltered		int out
	,@gridKey			nvarchar(200) out
as
declare @PosCd varchar(30);
declare @ServiceKey varchar(30);

	begin try 
		set		@Offset					= isnull(@Offset, 0)
		set		@PageSize				= isnull(@PageSize, 10)
		set		@Total					= isnull(@Total, 0) 
		set		@Filter					= isnull(@Filter, '')
		if		@PageSize	= 0			set @PageSize	= 10
		if		@Offset		< 0			set @Offset		=  0

		 
		select 
			@Total					= count(N.Id)
			 from  CRM_SharingNotes S
			inner join CRM_Notes N on N.Id = S.NoteId
			inner JOIN MAS_Parameters P on (S.Status = P.VALUEINT) and P.CATEGORY = 'NOTE_STATUS' 
			inner join Users M on N.UserId = M.UserId
			where 
				 (P.VALUEINT = @Status or @Status is null)
				 and (S.UserId = @UserId)
				 and N.Custid = @CustId
				 and N.Contents like '%'+@Filter+'%';
		
		set	@TotalFiltered = @Total 
		if @PageSize < 0
		begin
			set	@PageSize				= 10
		end
	
	--1
		select 
			 N.Id
			 , N.UserId
			 , N.Custid
			 , N.Contents
			 , P.NAME as [Status]
			 , N.Created
			 , N.Updated
			 , M.loginName as CreatedBy
			 , (select IIF(COUNT(1) = 0, 0, 1) from CRM_Attachment where ObjectId = N.Id) as HasAttachment
		from  CRM_SharingNotes S
		inner join CRM_Notes N on N.Id = S.NoteId
		inner JOIN MAS_Parameters P on (S.Status = P.VALUEINT) and P.CATEGORY = 'NOTE_STATUS' 
		inner join Users M on N.UserId = M.UserId
		where 
				 (P.VALUEINT = @Status  or @Status is null)
				 and (S.UserId = @UserId)
				 and N.Custid = @CustId
				  and N.Contents like '%'+@Filter+'%'
		ORDER BY N.Contents desc
					  offset @Offset rows	
						fetch next @PageSize rows only;

	end try
	begin catch
		declare	@ErrorNum				int,
				@ErrorMsg				varchar(200),
				@ErrorProc				varchar(50),

				@SessionID				int,
				@AddlInfo				varchar(max)

		set @ErrorNum					= error_number()
		set @ErrorMsg					= '[sp_Crm_Get_Notes] ' + error_message()
		set @ErrorProc					= error_procedure()

		set @AddlInfo					= ' '

		exec utl_Insert_ErrorLog @ErrorNum, @ErrorMsg, @ErrorProc, 'Notes', 'GET', @SessionID, @AddlInfo
	end catch