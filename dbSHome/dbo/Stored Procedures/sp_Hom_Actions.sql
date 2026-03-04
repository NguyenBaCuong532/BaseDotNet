-- =============================================

CREATE PROCEDURE [dbo].[sp_Hom_Actions]
	@userId				NVARCHAR(450),
	@projectCd 			NVARCHAR(10),
	@Offset				INT	= 0,
	@PageSize			INT	= 10,
	@Filter             NVARCHAR(100),
    @status             INT,
	@fromDate 			NVARCHAR(50) = null, 
	@toDate 			NVARCHAR(50) = null

AS 
	BEGIN
		BEGIN TRY
            set	@Offset 	= ISNULL(@Offset, 0)
            set	@PageSize	= isnull(@PageSize, 10)
            if	@PageSize	<= 	0 SET @PageSize	= 10
            if	@Offset		< 	0 SET @Offset	= 0
            
            declare @code       int = 126
           	declare @StartDt    datetime = convert(datetime, isnull(@FromDate,'2000-01-01'), @code),
	                @EndDt      datetime = convert(datetime, isnull(@ToDate,'2050-01-01'), @code),
	                @q          NVARCHAR(100) = '%' + isnull(@filter, '') + '%'
           
            SET NOCOUNT ON;
				;WITH cols
                    AS
                    (SELECT a.[id]
                            ,a.[userId]
                            ,projectCd
                            ,[url]
                            ,[api]
                            ,c.[FullName]
                            ,c.[phone]
                            ,[action]
                            ,[data]
                            ,[time]
                            ,[status]
                            ,case [status]
                                when 1 then N'Thành công'  
                                else N'Thất bại' 
                            end result
                            ,ROW_NUMBER() OVER(ORDER BY a.[id] DESC)    AS seq
                            ,ROW_NUMBER() OVER(ORDER BY a.[id] )        AS totrows
                        FROM [dbSHome].[dbo].[MAS_Actions] a
                            left join Users u
                                on a.[userId] = u.UserId
                            left join MAS_Customers c
                                on u.CustId = c.CustId
                        where (@projectCd is null or a.projectCd = @projectCd)
                            and (@status is null or a.[status] = @status)
                            and a.time is not null
                            and a.time between @StartDt and @EndDt 
                            and (@Filter is NULL
                                or c.fullName LIKE @q
                                or c.Phone like @q
                                or a.action LIKE @q
                                or a.api LIKE @q
                                or a.url LIKE @q
                                or a.data LIKE @q)
                    )

                SELECT id,
                        userId
                        ,projectCd
                        ,url
                        ,api
                        ,FullName
                        ,phone
                        ,action
                        ,data
                        ,time
                        ,status
                        ,result
                        ,seq, totrows
                        ,totrows + seq - 1 as TotRows
                    FROM cols
                        ORDER BY seq
                            OFFSET @Offset 
                                 ROWS FETCH NEXT @PageSize ROWS ONLY 
        END try

		begin catch
			declare	@ErrorNum				int = error_number(),
                    @ErrorMsg				varchar(200) = 'sp_Hom_Actions ' + error_message(),
                    @ErrorProc				varchar(50) = error_procedure(),

                    @SessionID				int,
                    @AddlInfo				varchar(max) = ' - @userId ' + @userId

			exec utl_Insert_ErrorLog @ErrorNum, @ErrorMsg, @ErrorProc, 'sp_Hom_Actions', 'GET', @SessionID, @AddlInfo
        end catch
    END