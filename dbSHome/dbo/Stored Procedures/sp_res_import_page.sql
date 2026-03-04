
CREATE PROCEDURE [dbo].[sp_res_import_page] @userId NVARCHAR(50) = ''
    , @import_type NVARCHAR(100)
    , @filter NVARCHAR(100) = NULL
    , @gridWidth INT = 0
    , @Offset INT = 0
    , @PageSize INT = 10
    , @acceptLanguage NVARCHAR(50) = N'vi-VN'
    --, @Total INT =0 OUT
    --, @TotalFiltered INT = 0 OUT
    --, @GridKey NVARCHAR(200) = 'view_import_page' OUT
AS
BEGIN
    BEGIN TRY
		declare @Total		bigint
		declare @GridKey	nvarchar(100) = 'view_import_page'

        SET @Offset = isnull(@Offset, 0)
        SET @PageSize = isnull(@PageSize, 10)
        SET @Total = isnull(@Total, 0)
        --SET @TotalFiltered = isnull(@TotalFiltered, 0)
        SET @filter = rtrim(ltrim(isnull(@filter, '')))

        IF @PageSize = 0
            SET @PageSize = 10

        IF @Offset < 0
            SET @Offset = 0

        SELECT @Total = count(a.[impId])
        FROM ImportFiles a
        WHERE [import_type] = @import_type

        --root	
		select recordsTotal = @Total
			  ,recordsFiltered = @Total
			  ,gridKey = @GridKey
			  ,valid = 1
		--grid config
         IF @Offset = 0
             SELECT *
             FROM fn_config_list_gets_lang(@GridKey, 0, @acceptLanguage)
             ORDER BY [ordinal]

        SELECT [impId]
            , [upload_upload_url] = [upload_file_url]
            , [upload_file_name] = [upload_file_name]
            , [upload_file_type] = [upload_file_type]
            , [upload_file_size] = [upload_file_size]
            , [upload_file_size_name] = dbo.[fn_FileSize]([upload_file_size])
            , [created_by] = mk.fullName
            , [created_dt] = format(a.created_dt, 'dd/MM/yyyy hh:mm:ss ttt')
            --,int_order				= isnull(int_order,ROW_NUMBER() OVER(ORDER BY a.[created_dt] desc))
            , [meta_status] = st.[objValue1]
            , [meta_file_type_icon] = ft.objValue1
            , [row_count]
            , [row_new]
            , [row_update]
            , [row_fail]
            , [updated_st]
            , [updated_by]
            , [updated_dt]
        FROM ImportFiles a
        LEFT JOIN [dbo].[fn_config_data_gets]('meta_status') st
            ON a.[updated_st] = st.objValue
        LEFT JOIN [dbo].[fn_config_data_gets]('file_type') ft
            ON isnull(a.[upload_file_type], 'file') = ft.objCode
        LEFT JOIN Users mk
            ON a.created_by = mk.userId
        WHERE [import_type] = @import_type
        ORDER BY a.[created_dt] DESC Offset @Offset ROWS

        FETCH NEXT @PageSize ROWS ONLY
    END TRY

    BEGIN CATCH
        DECLARE @ErrorNum INT
            , @ErrorMsg VARCHAR(200)
            , @ErrorProc VARCHAR(50)
            , @SessionID INT
            , @AddlInfo VARCHAR(max)

        SET @ErrorNum = error_number()
        SET @ErrorMsg = 'sp_res_import_page ' + error_message()
        SET @ErrorProc = error_procedure()
        SET @AddlInfo = ' @user: ' + @userId + ' - clientid: '

        EXEC utl_ErrorLog_Set @ErrorNum
            , @ErrorMsg
            , @ErrorProc
            , 'attach'
            , 'GET'
            , @SessionID
            , @AddlInfo
    END CATCH
END