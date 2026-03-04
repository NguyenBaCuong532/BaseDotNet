-- =============================================
-- Author:		<vdx>
-- Description:	<Contract transfering report,>
-- =============================================
-- exec sp_Hom_Transfer_Page null, null, 0, 10, null, '2017-01-01', '2021-12-01' 
CREATE PROCEDURE [dbo].[sp_Hom_Transfer_Page]
	@userId				nvarchar(450),
    @clientId			nvarchar(50),
	@projectCd 			nvarchar(10),
    @BuildingCd			nvarchar(50) = null,
    @Offset				int	= 0,
	@PageSize			int	= 10,
	@Filter             nvarchar(100),
	@fromDate 			nvarchar(50) = null, 
	@toDate 			NVARCHAR(50) = null,
    @gridWidth			int		= 0,
    @contract_type		int,
	@procedureStatus	int = NULL,
	@isApprove			bit = NULL,
	@isVIP				bit = NULL,
    @Total				int out,
	@TotalFiltered		int out
AS
    BEGIN
        BEGIN TRY
            SET NOCOUNT ON;     
            set	@Offset 	= isnull(@Offset, 0)
            set	@PageSize	= isnull(@PageSize, 10)
            if	@PageSize	<= 	0 set @PageSize	= 10
            if	@Offset		< 	0 set @Offset	= 0
            
            SET		@contract_type			= isnull(@contract_type,0)
            DECLARE @code       int = 126
           	DECLARE @StartDt    datetime = convert(datetime, isnull(@FromDate,'2000-01-01'), @code),
	                @EndDt      datetime = convert(datetime, isnull(@ToDate,'2050-01-01'), @code),
                    @q          NVARCHAR(100) = '%' + isnull(@filter, '') + '%'
            DECLARE @webId      nvarchar(50) 
			--= (select id 
   --                                 from [dbAppManager].[dbo].[ClientWebs] 
   --                                     where clientId = @clientId or clientIdDev = @clientId)
            DECLARE @tbCats TABLE 
            (
                categoryCd [nvarchar](20) not null  INDEX IX1_category NONCLUSTERED
            )
            INSERT INTO @tbCats
                select distinct 
                        u.categoryCd 
                    from [dbSHome].[dbo].[MAS_Category_User] u 
                        where u.UserId = @UserId and u.webId = @webId and u.isAll = 0 
                            and not exists(select CategoryCd 
                                    from @tbCats 
                                        where categoryCd = u.CategoryCd)
                            and (@ProjectCd IS NULL or u.categoryCd = @ProjectCd)
            INSERT INTO @tbCats
                select distinct 
                        n.categoryCd 
                    from [dbSHome].[dbo].[MAS_Category_User] u 
                        join [dbSHome].[dbo].MAS_Category n 
                            on n.base_type = u.base_type 
                    where u.UserId = @UserId and u.webId = @webId and u.isAll = 1
                        and not exists(select CategoryCd 
                                from @tbCats 
                                    where categoryCd = n.CategoryCd)
                        and (@ProjectCd IS NULL or n.categoryCd = @ProjectCd)
            set @TotalFiltered = 20   
            set @Total = 20   

                --SELECT [id]
                --        ,[transferNo]
                --        ,[orderId]
                --        ,[contractId]
                --        ,[contractNo]
                --        ,[cus_Cif_No_Old]
                --        ,[cus_Name_Old]
                --        ,[cus_Cif_No_New]
                --        ,[cus_Name_New]
                --        ,[transfer_Time]
                --        ,[description]

                --    FROM [COR_Contract_Transfer]
            
        END TRY

        begin catch
                declare	@ErrorNum		int = error_number(),
                        @ErrorMsg		varchar(200) = 'sp_Hom_Transfer_Page ' + error_message(),
                        @ErrorProc		varchar(50) = error_procedure(),

                        @SessionID		int,
                        @AddlInfo		varchar(max) = ' - @userId ' + @userId

                exec utl_Insert_ErrorLog @ErrorNum, @ErrorMsg, @ErrorProc, 'sp_Hom_Transfer_Page', 'Update', @SessionID, @AddlInfo
        end catch
    END