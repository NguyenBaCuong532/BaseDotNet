

CREATE procedure [dbo].[sp_app_point_page]
	  @UserId	UNIQUEIDENTIFIER
	, @filter         NVARCHAR(30)     = NULL
	, @payType        NVARCHAR(50)     = NULL
    , @Offset         INT              = 0
    , @PageSize       INT              = 10
    , @gridWidth      INT              = 0
    , @acceptLanguage NVARCHAR(50)     = N'vi-VN'
	, @month int = 0
	, @year int = 0
as
	begin try
		declare @Total int
			   ,@GridKey nvarchar(200) = 'app_point_page'

		set		@Offset					= isnull(@Offset, 0)
		set		@PageSize				= isnull(@PageSize, 10)
		set		@Total					= isnull(@Total, 0)
		if		@PageSize	= 0			set @PageSize	= 10
		if		@Offset		< 0			set @Offset		=  0
		set @payType = isnull(@payType,'')

		if @month = 0 or @month is null set @month = month(getdate())
		if @year = 0 or @year is null set @year = year(getdate())
	begin	

		select	@Total					= count(t.Ref_No)
				FROM [dbo].WAL_PointOrder t
					join MAS_Points a on t.PointCd = a.PointCd 
					join UserInfo u on a.CustId = u.CustId 
				WHERE u.UserId = @userId
					--and month(t.TranDt) = @month
					--and year(t.TranDt) = @year
					and t.Point > 0
				
		-- =============================================
		-- RESULT SET 1: METADATA
		-- =============================================
		SELECT recordsTotal    = @Total,
			   recordsFiltered = @Total,
			   gridKey         = @GridKey,
			   valid           = 1;

		-- =============================================
		-- RESULT SET 2: HEADER (chỉ lần đầu)
		-- =============================================
		IF @Offset = 0
		BEGIN
			SELECT *
			FROM dbo.fn_config_list_gets_lang(@GridKey, 0, @acceptLanguage)
			ORDER BY ordinal;
		END

		--for time filter
		SELECT t.Ref_No 
			  ,t.TransNo
			  ,t.[TranDt]
			  ,case when t.TranType = 'voucher' then 'Tặng điểm ' else N'Tích điểm tại ' end + isnull(s.ServiceName,'') as Remark
			  ,t.Point 
			  ,[dbo].[fn_Get_TimeAgo1] (t.TranDt,getdate()) as DateAgo
			  ,N'Tháng ' + cast(month(t.TranDt)as nvarchar(2)) + '/' + cast(year(t.TranDt)as nvarchar(4)) TimeGroup
			  ,t.TranType 
			  ,N'Thành công' as statusName
			  ,1 [status]
			  ,t.PointTranId as Oid
			  ,type_icon = ty.value1
			FROM [dbo].WAL_PointOrder t
				join MAS_Points a on t.PointCd = a.PointCd 
				join UserInfo u on a.CustId = u.CustId 
				join WAL_Services s on t.ServiceKey = s.ServiceKey 
				left join sys_config_data ty on ty.key_2 = t.TranType and ty.key_1 = 'tran_type'
			WHERE u.UserId = 'd9898e79-a628-42e9-b8c7-5986472b3dc8' --@userId
				--and month(t.TranDt) = @month
				--and year(t.TranDt) = @year
				and t.Point > 0
			ORDER BY t.[TranDt] DESC
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
		set @ErrorMsg					= 'sp_app_point_page ' + error_message()
		set @ErrorProc					= error_procedure()

		set @AddlInfo					= ' '

		exec utl_Insert_ErrorLog @ErrorNum, @ErrorMsg, @ErrorProc, 'WAL_PointOrder', 'GET', @SessionID, @AddlInfo
	end catch