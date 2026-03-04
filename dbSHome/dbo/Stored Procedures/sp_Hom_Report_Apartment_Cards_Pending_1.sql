-- =============================================
-- Author:		<KhoaNV>
-- Description:	<Báo cáo danh sách cư dân chưa được duyệt vào căn hộ tạo file Excell>
-- =============================================
CREATE PROCEDURE [dbo].[sp_Hom_Report_Apartment_Cards_Pending]
	@userId				NVARCHAR(450),
	@projectCd 			NVARCHAR(10),
	@fromDate 			Datetime, 
	@toDate 			Datetime

AS
    BEGIN TRY
		--SET	@Offset 	= ISNULL(@Offset, 0)
		--SET	@PageSize	= ISNULL(@PageSize, 10)
		--IF	@Offset		< 0 SET @Offset	  = 0
		--IF	@PageSize	< 1 SET @PageSize = 10

		--DECLARE @code      	INT = 126
		--DECLARE @StartDt    DATETIME = CONVERT(DATETIME, ISNULL(@FromDate,'2000-01-01'), @code),
		--		@EndDt      DATETIME = CONVERT(DATETIME, ISNULL(@ToDate,'2050-01-01'), @code),
		--		@q          NVARCHAR(100) = '%' + ISNULL(@filter, '') + '%'

		---- SET NOCOUNT ON added to prevent extra result sets from
		---- interfering with SELECT statements.
		--SET NOCOUNT ON;
  --      -- Mã căn	SĐT	Họ và Tên	Mối quan hệ	Ngày yêu cầu	Trạng thái
  --          ;WITH cols
		--		AS
		--		(
					 SELECT bb.[RoomCode]
                            ,a.[FullName]
                            ,a.[Phone]
                            ,isnull(d.RelationName,N'Khác') RelationName
                            ,bb.[reg_dt] requestDt
                            ,N'Chờ phê duyệt' StatusName
                            ,1 xcount
                        FROM [MAS_Customers] a 
                            join MAS_Apartment_Member b on a.CustId = b.CustId 
                            left join MAS_Customer_Relation d on b.RelationId = d.RelationId
                            left join MAS_Apartment_Reg bb on b.memberUserId = bb.userId 
                            join MAS_Apartments p on bb.RoomCode = p.RoomCode 
                        WHERE b.[member_st] = 0
                                AND (@projectCd IS NULL OR p.[projectCd] = @projectCd)
                                AND (bb.[reg_dt] IS NULL OR bb.[reg_dt] BETWEEN @fromDate AND @toDate)
                    UNION ALL

						SELECT
								p.[RoomCode]
								,a.[FullName]
								,a.[Phone]
								,isnull(d.RelationName,N'Khác') RelationName
								,b.[reg_dt] requestDt
								, N'Chờ phê duyệt' StatusName
								,1 xcount
								
							FROM UserInfo a 
								join MAS_Apartment_Reg b on a.UserId = b.userId 
								join MAS_Apartments p on b.RoomCode = p.RoomCode 
								join UserInfo r on b.UserId = r.UserId 
									left join MAS_Customer_Relation d on b.RelationId = d.RelationId
							WHERE b.reg_st = 0
								AND (@projectCd IS NULL OR p.[projectCd] = @projectCd)
								AND (b.[reg_dt] IS NULL OR b.[reg_dt] BETWEEN @fromDate AND @toDate)
        --        )
        --        SELECT  
        --                RoomCode
        --                ,FullName
        --                ,Phone
        --                ,RelationName
        --                ,requestDt
        --                ,StatusName
        --                ,seq, totrows
        --                ,totrows + seq - 1 AS TotRows
        --            FROM cols
        --            ORDER BY seq
        --                OFFSET @Offset 
        --                    ROWS FETCH NEXT @PageSize ROWS ONLY 
		select projectCd, projectName from MAS_Projects where ProjectCd =  @projectCd

    END TRY

	begin catch
		declare	@ErrorNum				int = error_number(),
				@ErrorMsg				varchar(200) = 'sp_Hom_Report_Apartment_Cards_Pending ' + error_message(),
				@ErrorProc				varchar(50) = error_procedure(),

				@SessionID				int,
				@AddlInfo				varchar(max) = ' - @userId ' + @userId

		exec utl_Insert_ErrorLog @ErrorNum, @ErrorMsg, @ErrorProc, 'sp_Hom_Report_Apartment_Cards_Pending', 'GET', @SessionID, @AddlInfo
	end catch