






CREATE procedure [dbo].[sp_Hom_Request_Voted]
	@UserID	nvarchar(450),
	@RequestId bigint,
	@Comment nvarchar(max),
	@rating int
as
	begin try		
		
			UPDATE [dbo].MAS_Requests
				SET  review_dt = getdate()
					,rating = @rating
					--,review_comment = @Comment
			WHERE RequestId = @RequestId

			SELECT a.RequestId 
				  ,a.[ApartmentId]
				  ,a.[Comment]
				  ,convert(nvarchar(5),a.RequestDt,108) + ' - ' + convert(nvarchar(10),a.RequestDt,103) as RequestDate 
				  ,a.RequestTypeId
				  ,a.[Status]
				  ,case a.[Status] when 0 then N'Mới yêu cầu' when 1 then N'Đã xem' else N'Hoàn thành' end [StatusName]
				  ,a.IsNow
				  ,convert(nvarchar(10),a.AtTime,103) + ' ' + convert(nvarchar(5),a.AtTime,108) as [AtTime]
				  ,b.RequestTypeName
				  ,a.thread_id
		  FROM [dbo].MAS_Requests a 
			inner join MAS_Request_Types b ON a.RequestTypeId = b.RequestTypeId
			--inner join TRS_Request_Sevs c on a.RequestId = c.RequestId 
		  WHERE a.RequestId = @RequestId

	end try
	begin catch
		declare	@ErrorNum				int,
				@ErrorMsg				varchar(200),
				@ErrorProc				varchar(50),

				@SessionID				int,
				@AddlInfo				varchar(max)

		set @ErrorNum					= error_number()
		set @ErrorMsg					= 'sp_Hom_Request_Voted ' + error_message()
		set @ErrorProc					= error_procedure()

		set @AddlInfo					= '@ApartmentId ' + @RequestId 

		exec utl_Insert_ErrorLog @ErrorNum, @ErrorMsg, @ErrorProc, 'Request_Voted', 'Insert', @SessionID, @AddlInfo
	end catch