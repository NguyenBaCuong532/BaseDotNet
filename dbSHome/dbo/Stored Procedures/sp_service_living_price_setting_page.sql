-- =============================================
-- Author:		namhm
-- Create date: 03/07/2025
-- Description:	Lấy danh sách bảng giá điện/nước
-- =============================================
CREATE PROCEDURE [dbo].[sp_service_living_price_setting_page] 
	@UserId				nvarchar(450) = NULL,
	@acceptLanguage		nvarchar(50) = N'vi-VN',
	@filter				nvarchar(100)	= NULL,
	@ProjectCd			nvarchar(100)	 = NULL,
	@LivingTypeId		nvarchar(100)	= NULL,
	@isActive			int				= NULL,
	@gridWidth			int				= 0,
	@Offset				int				= 0,
	@PageSize			int				= 10
	--@Total				int out,
	--@TotalFiltered		int out
	--,@GridKey			nvarchar(200) out
AS
	begin try		
		declare @Total		bigint
		declare @GridKey	nvarchar(100) = 'view_service_living_price_setting_page'

		set		@Offset					= isnull(@Offset, 0)
		set		@PageSize				= isnull(@PageSize, 10)
		set		@Total					= isnull(@Total, 0)
		set		@filter					= isnull(@filter,'')
		set		@isActive				= isnull(@isActive,0)
		if		@PageSize	= 0			set @PageSize	= 10
		if		@Offset		< 0			set @Offset		=  0

		--1--
		select	@Total					= count(a.[LivingPriceId])
            FROM [PAR_ServiceLivingPrice] a 
                    inner join MAS_Services b 
                        on a.LivingTypeId = b.ServiceId 
                WHERE a.LivingTypeId = 1 
                        and (a.IsUsed is null or a.IsUsed = 1)
                        and (@ProjectCd is null or a.ProjectCd is null or a.ProjectCd = @ProjectCd)
		--root	
		select recordsTotal = @Total
			  ,recordsFiltered = @Total
			  ,gridKey = @GridKey
			  ,valid = 1
		--grid config
		if @Offset = 0
		--2--
		begin
			select * from dbo.fn_config_list_gets_lang(@GridKey, @gridWidth, @acceptLanguage) 
			order by [ordinal]
		end
		--3--
        SELECT [LivingPriceId]
                ,[ProjectCd]
                ,[Step] = CASE 
									 WHEN @LivingTypeId = 1 THEN 
										 N': Cho kWh từ ' + CONVERT(nvarchar(10), [NumFrom]) + ' - ' + ISNULL(CONVERT(nvarchar(10), [NumTo]), N'trở lên')
									 WHEN @LivingTypeId = 2 THEN 
										 N': Cho m3 từ ' + CONVERT(nvarchar(10), [NumFrom]) + ' - ' + ISNULL(CONVERT(nvarchar(10), [NumTo]), N'trở lên')
									 ELSE NULL
									END
                ,a.LivingTypeId
                ,b.ServiceName 
                ,[NumFrom]
                ,[NumTo]
                ,[Price]
                ,[CalculateType]
                ,[IsFree], IsUsed
				,StartTime
            FROM [PAR_ServiceLivingPrice] a 
                    inner join MAS_Services b 
                        on a.LivingTypeId = b.ServiceId 
                WHERE a.LivingTypeId = @LivingTypeId
                        and (a.IsUsed is null or a.IsUsed = 1)
                        and (@ProjectCd is null or a.ProjectCd is null or a.ProjectCd = @ProjectCd)
                ORDER BY Pos
		OFFSET @Offset ROWS   
		FETCH NEXT @PageSize ROWS ONLY;


	end try
	begin catch
		declare	@ErrorNum				int,
				@ErrorMsg				varchar(200),
				@ErrorProc				varchar(50),

				@SessionID				int,
				@AddlInfo				varchar(max)

		set @ErrorNum					= error_number()
		set @ErrorMsg					= '[sp_service_living_price_setting_page] ' + error_message()
		set @ErrorProc					= error_procedure()

		set @AddlInfo					= ' '

		exec utl_ErrorLog_Set @ErrorNum, @ErrorMsg, @ErrorProc, '[sp_service_living_price_setting_page]', 'Get', @SessionID, @AddlInfo
	end catch