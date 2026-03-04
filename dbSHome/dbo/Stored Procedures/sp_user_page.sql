
-- =============================================
-- Author:		<Author,,MinhDT>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[sp_user_page]	
	@userId nvarchar(100) = '',
	@filter nvarchar(100) = '',
	@gridWidth			int				= 0,
	@Offset				int				= 0,
	@PageSize			int				= 10
	--@Total				int out,
	--@TotalFiltered		int out,
	--@GridKey		nvarchar(100) out

	
AS
BEGIN TRY
	declare @Total		bigint
	declare @GridKey	nvarchar(100) = 'view_all_user_page'

		set		@Offset					= isnull(@Offset, 0)
		set		@PageSize				= isnull(@PageSize, 10)		
		set		@filter					= isnull(@filter,'')

		if		@PageSize	= 0			set @PageSize	= 10
		if		@Offset		< 0			set @Offset		=  0
		set		@Total					= isnull(@Total, 0)
		
		select	@Total					= count(a.userId)
		from Users a 

		--root	
	select recordsTotal = @Total
		  ,recordsFiltered = @Total
		  ,gridKey = @GridKey
		  ,valid = 1

	if @Offset=0
		begin
			SELECT * FROM dbo.[fn_config_list_gets] (@GridKey, 0) 
			ORDER BY [ordinal]
		end
   
   SELECT 
		userId,
		reg_dt,
		last_dt,
		admin_st,
		fullName,
		loginName,
		phone,
		email,
		position,
		created_dt,
		parent_id,
		created_by,
		lock_st,
		lock_dt,
		active,
		custId,
		createdDate,
		LastModifiedBy,
		LastModifiedDate,
		orgId
    FROM Users
	WHERE (
            @filter = ''
             OR ISNULL(fullName, '') LIKE '%' + @filter + '%'
             OR ISNULL(phone, '') LIKE '%' + @filter + '%'
             OR ISNULL(email, '') LIKE '%' + @filter + '%'
            )
   ORDER BY fullName 
	offset @Offset rows
	fetch next @PageSize rows only

END TRY

BEGIN CATCH
    -- Xử lý lỗi
    DECLARE 
        @ErrorNum INT,
        @ErrorMsg NVARCHAR(200),
        @ErrorProc NVARCHAR(50),
        @AddlInfo NVARCHAR(MAX);

    SET @ErrorNum = ERROR_NUMBER();
    SET @ErrorMsg = 'sp_GetUsersWithFilters ' + ERROR_MESSAGE();
    SET @ErrorProc = ERROR_PROCEDURE();
    SET @AddlInfo = 'An error occurred during user filtering.';

    -- Lưu lỗi vào bảng log
    EXEC utl_Insert_ErrorLog 
        @ErrorNum, 
        @ErrorMsg, 
        @ErrorProc, 
        'userInfor', 
        'FILTER',
        NULL,
        @AddlInfo;
END CATCH