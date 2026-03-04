




-- exec sp_Hom_Service_Receivable_Extend_Set null,534,200000,'sssss'
CREATE procedure [dbo].[sp_Hom_Service_Receivable_Extend_Set]
    @UserId nvarchar(250),
	@receiveId	bigint,
	@extendAmt decimal,
	@note nvarchar(250)
as
	begin try
		declare @valid bit = 0
		declare @message nvarchar(100) = ''
		if exists (select * from MAS_Service_ReceiveEntry where ReceiveId = @receiveId and IsPayed = 0)
			begin
			    Delete MAS_Service_Receivable where ServiceTypeId = 8 and ReceiveId = @receiveId
				INSERT INTO MAS_Service_Receivable
					   ([ReceiveId]
					   ,[ServiceTypeId]
					   ,[ServiceObject]
					   ,[Amount]
					   ,VATAmt
					   ,TotalAmt
					   ,fromDt
					   ,[ToDt]
					   ,[Quantity]
					   ,Price
					   ,srcId
					   ,updateId
					   ) 
		    select @receiveId
			       ,8
				   ,a.RoomCode + ':' + @note
				   ,@extendAmt
				   ,@extendAmt/10
				   ,@extendAmt
				   ,null
				   ,ToDt
				   ,1
				   ,null
				   ,a.ApartmentId
				   ,@UserId
			FROM MAS_Apartments a
					inner join MAS_Rooms b on a.RoomCode = b.RoomCode
					--join @tbAparts c on a.ApartmentId = c.ApartmentId 
					join [MAS_Service_ReceiveEntry] d on a.ApartmentId = d.ApartmentId
			where 
			--not exists(select ReceivableId from MAS_Service_Receivable where [ServiceTypeId] = 8 and ReceiveId=@receiveId and d.IsPayed = 0) and 
			d.ReceiveId = @receiveId

			UPDATE MAS_Service_ReceiveEntry 
			set ExtendAmt = (SELECT SUM(TotalAmt) FROM [MAS_Service_Receivable] WHERE [ReceiveId] = @receiveId and ServiceTypeId = 8)
				,TotalAmt = (SELECT SUM(TotalAmt) FROM [MAS_Service_Receivable] WHERE [ReceiveId] = @receiveId)
				,updateId = @UserId
			--FROM MAS_Service_ReceiveEntry 
				--inner join @tbAparts a on t.ApartmentId = a.ApartmentId
			 WHERE IsPayed = 0 and ReceiveId = @receiveId
			 set @valid = 1
			 set @message = N'Cập nhật công nợ tồn khác thành công!'
			--select * from MAS_Service_ReceiveEntry where ReceiveId = 16407
			end
		    select @valid as valid, @message as message

			--Delete from MAS_Service_Receivable where ServiceTypeId = 8
			--select * from MAS_Service_ReceiveEntry
	end try
	begin catch
		declare	@ErrorNum				int,
				@ErrorMsg				varchar(200),
				@ErrorProc				varchar(50),

				@SessionID				int,
				@AddlInfo				varchar(max)

		set @ErrorNum					= error_number()
		set @ErrorMsg					= 'sp_Hom_Service_Receivable_Extend_Set' + error_message()
		set @ErrorProc					= error_procedure()

		set @AddlInfo					= ''

		exec utl_Insert_ErrorLog @ErrorNum, @ErrorMsg, @ErrorProc, 'Receivable', 'PUT', @SessionID, @AddlInfo
	end catch