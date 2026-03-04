


-- =============================================
-- Author:		duongpx
-- Create date: 11/26/2024 10:16:46 AM
-- Description:	danh sách thiết bị
-- =============================================
CREATE   procedure [dbo].[sp_app_user_device_page]
	@userId uniqueidentifier,
	@acceptLanguage nvarchar(50) = 'vi-VN',
	@clientId	NVARCHAR(50),
	@Offset				INT				= 0,
	@PageSize			INT				= 10

AS
	BEGIN TRY
		declare @Total				int

		set		@Offset					= isnull(@Offset, 0)
		set		@PageSize				= isnull(@PageSize, 10)

		if		@PageSize	= 0			set @PageSize	= 10
		if		@Offset		< 0			set @Offset		=  0
		
			 
		select	@Total		= count(a.id)
			FROM [UserDevice] a 
			where a.userid = @userId 

		-- 
		select  pageSize			= @pageSize
			   ,totalPages			= CEILING(@Total/@pageSize) --FLOOR
			   ,totalElements		= @Total
			   ,[first]				= case when @Offset = 0 then 1 else 0 end
			   ,[last]				= case when @Offset >= (CEILING(@Total/@pageSize)-1)*@pageSize then 1 else 0 end

		--data
		SELECT [id]
			  ,[regOid]
			  ,[udid]
			  ,a.[userId]
			  ,[deviceName]
			  ,[deviceProvider]
			  ,[deviceVersion]
			  ,[playerId]
			  ,[clientId]
			  ,[etokenDevice]
			  ,a.[created_dt]
			  ,ISNULL([update_dt],a.[created_dt]) AS lastLoginAt
			  ,b.loginName AS userIdentity
		  FROM [dbo].[UserDevice] a 
			JOIN UserInfo b ON a.userId = b.userId
			WHERE a.userid = @userId 
			ORDER BY a.[update_dt] DESC				 
			OFFSET @Offset ROWS	
			FETCH NEXT @PageSize ROWS ONLY

	END TRY
	BEGIN CATCH
		DECLARE	@ErrorNum				INT,
				@ErrorMsg				VARCHAR(200),
				@ErrorProc				VARCHAR(50),

				@SessionID				INT,
				@AddlInfo				VARCHAR(MAX)

		SET @ErrorNum					= ERROR_NUMBER()
		SET @ErrorMsg					= 'sp_app_user_device_Page ' + ERROR_MESSAGE()
		SET @ErrorProc					= ERROR_PROCEDURE()

		SET @AddlInfo					= ' '

		EXEC utl_errorLog_set @ErrorNum, @ErrorMsg, @ErrorProc, 'Device_Page', 'GET', @SessionID, @AddlInfo
	END CATCH