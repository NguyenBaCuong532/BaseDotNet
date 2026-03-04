-- =============================================
-- Author:		duongpx
-- Create date: 10/14/2024 11:34:18 PM
-- Description:	trang giao dịch nhận tiền ngân hàng
CREATE procedure [dbo].[sp_res_trans_bank_page]
      @UserId			UNIQUEIDENTIFIER = NULL
	 ,@Filter			NVARCHAR(250) = NULL
	 ,@AcceptLanguage	VARCHAR(20) = 'vi-VN'
	 ,@ApartmentId		int = null
	 ,@RoomCode			nvarchar(50) = NULL
	 ,@trans_st			int	= null
	 ,@from_dt			nvarchar(10) = null
	 ,@to_dt			nvarchar(10) = null
	 ,@projectCd		nvarchar(5)  = null
	 ,@gridWidth		int = 0
     ,@Offset			INT = 0
     ,@PageSize			INT = 10
  --   ,@Total			BIGINT OUT
  --   ,@TotalFiltered	BIGINT OUT
	 --,@GridKey			nvarchar(200) out
AS
BEGIN TRY
	declare @Total		bigint
	declare @GridKey	nvarchar(100) = 'view_trans_response_page'
	declare @from_date datetime
	declare @to_date datetime

	if @from_dt is null or @from_dt = ''
	begin
		set @from_date = null
	end
	else
	begin
		set @from_date = convert(datetime,@from_dt,103)
	end

	if @to_dt is null or @to_dt = ''
		set @to_date = null--dateadd(day,1,@from_date)
	else
		set @to_date = dateadd(day,1,convert(datetime,@to_dt,103))

      SET @Offset		=	ISNULL(@Offset, 0)
      SET @PageSize		=	ISNULL(@PageSize, 10)
      SET @PageSize = IIF(@PageSize = 0, 10, @PageSize);
      
      SET @Total		=	ISNULL(@Total, 0)
      SET @Filter		=	ISNULL(@Filter, '')
	  SET @trans_st		=	ISNULL(@trans_st, -1)
	  

      SELECT  @Total =	COUNT(a.id)
		 FROM [dbo].[trans_response_klb] a
		 LEFT JOIN transaction_payment_draft b ON a.virtualAccount = b.virtualAcc
		 LEFT JOIN MAS_Service_ReceiveEntry c ON b.sourceOid = c.entryId
		 LEFT JOIN MAS_Apartments d ON d.ApartmentId = c.ApartmentId
		 WHERE (@from_date is null or a.created >= @from_date)
			and (@to_date is null or a.created <= @to_date)
			and (@ApartmentId is null or c.ApartmentId = @ApartmentId)
			and (@RoomCode is null or d.RoomCode = @RoomCode)
		
			--and (@trans_st is null or a.success = @trans_st)
			--and (@Filter = '' or a.narratives LIKE '%' + @Filter + '%')

      --root	
	select recordsTotal = @Total
		  ,recordsFiltered = @Total
		  ,gridKey = @GridKey
		  ,valid = 1
    --grid config
	if @Offset = 0
		begin
			SELECT * FROM [dbo].[fn_config_list_gets_lang] (@GridKey, @gridWidth, @AcceptLanguage) 
			ORDER BY [ordinal]
		end

		SELECT 
			a.[id],
			[success] = CASE 
						   WHEN a.[success] = 1 THEN N'<span class="bg-success noti-number ml5">Success</span>' 
						   ELSE N'<span class="bg-warning noti-number ml5">Fail</span>' 
					   END,
			a.[interBankTrace],
			a.[virtualAccount],
			a.[actualAccount],
			a.[fromBin],
			a.[fromAccount],
			a.[amount],
			a.[statusCode],
			a.[transferDesc],
			a.[created_by],
			a.[txnNumber],
			[time] = CONVERT(VARCHAR, CONVERT(DATE, a.[time]), 103),
			[created] = FORMAT(a.[created], 'dd-MM-yyyy'),
			a.[rc_count],
			rowid = ROW_NUMBER() OVER (ORDER BY a.[created] DESC)
		FROM 
			[dbo].[trans_response_klb] a
		LEFT JOIN 
			transaction_payment_draft b ON a.virtualAccount = b.virtualAcc
		LEFT JOIN 
			MAS_Service_ReceiveEntry c ON b.sourceOid = c.entryId
		--LEFT JOIN 
		--	MAS_Apartments d ON d.ApartmentId = c.ApartmentId
		WHERE c.projectCd = @projectCd
			AND (@from_date IS NULL OR a.created >= @from_date)
			AND (@to_date IS NULL OR a.created <= @to_date)
			AND (@Filter IS NULL OR a.transferDesc LIKE '%' + @Filter + '%')


			
      ORDER BY a.created DESC 
		OFFSET @Offset 
		ROWS FETCH NEXT @PageSize ROWS ONLY
	
END TRY
BEGIN CATCH
      DECLARE @ErrorNum INT
             ,@ErrorMsg VARCHAR(200)
             ,@ErrorProc VARCHAR(50)
             ,@SessionID INT
             ,@AddlInfo VARCHAR(MAX)

      SET @ErrorNum = ERROR_NUMBER()
      SET @ErrorMsg = 'sp_trans_info_Page ' + ERROR_MESSAGE()
      SET @ErrorProc = ERROR_PROCEDURE()
      SET @AddlInfo = ''

      EXEC utl_ErrorLog_Set @ErrorNum, @ErrorMsg, @ErrorProc, 'trans_info', 'GET', @SessionID, @AddlInfo
END CATCH