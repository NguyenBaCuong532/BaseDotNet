






CREATE procedure [dbo].[sp_Hom_Vehicle_Payday_Set]
	@UserId	nvarchar(450),
	@CardVehicleId bigint,
	@VehNum int,
	@Price int,
	@Quantity int,
	@Amount bigint,
	@StartDate nvarchar(30),
	@EndDate nvarchar(30),
	@Remart nvarchar(200)

as
	begin try	
		declare @valid bit = 1
		declare @messages nvarchar(100) = ''
		--declare @errmessage nvarchar(100)
		declare @StartDt datetime
		declare @ReceiveId bigint 
		--declare @PreReceiveId bigint 
		declare @Receives TABLE 
		(
			ReceiveId bigint not null
		)
		declare @ToDt datetime
		set @ToDt = convert(datetime,@EndDate,103)
		declare @ApartmentId bigint
		
		if exists(select cardvehicleid FROM MAS_CardVehicle v 
					WHere v.CardVehicleId = @CardVehicleId and isnull(v.EndTime,v.StartTime) >= @ToDt)
			begin
				set @Valid = 0
				set @Messages = N'Ngày gia hạn phải lớn hơn ngày [' + @EndDate + N']!' 
			end
		else if exists(select cardvehicleid FROM MAS_CardVehicle v 
				WHere v.CardVehicleId = @CardVehicleId and monthlyType > 0)
			begin
				
				set @Price = (select top 1 case sp.ServiceId when 5 then case when isnull(v.VehicleNum,1) <= 1 then Price else Price2 end when 6 then case when v.VehicleNum < 3 then Price else Price2 end when 7 then Price end
				 from [PAR_ServicePrice] sp 
							join MAS_VehicleTypes c on sp.ServiceId = c.ServiceId 
							Join [MAS_CardVehicle] v on c.VehicleTypeId = v.VehicleTypeId and sp.TypeId = v.[monthlyType]
							left join MAS_Apartments a on v.ApartmentId = a.ApartmentId and sp.ProjectCd = isnull(a.projectCd,v.projectCd)
						where  v.CardVehicleId = @cardVehicleId)

				INSERT INTO @Receives
				select r.[ReceiveId] FROM MAS_Service_Receivable r 
					join [MAS_Service_ReceiveEntry] e on r.ReceiveId = e.ReceiveId 
					WHere r.srcId = @CardVehicleId and r.[ServiceTypeId] = 2 and e.IsPayed = 0

				----remove du thu
				--if exists(select * from @Receives)
				----@PreReceiveId > 0 
				--	begin
						
				--		UPDATE t
				--		   SET  lastReceivable = r.fromDt
				--			   ,EndTime = r.fromDt
				--		FROM MAS_CardVehicle t
				--			join MAS_Service_Receivable r on t.CardVehicleId = r.srcId --and t.VehicleTypeId = r.ServiceTypeId
				--		 WHERE  r.ReceiveId in (select ReceiveId from @Receives)  and t.CardVehicleId = @CardVehicleId

				--		delete t from MAS_Service_Receivable t where ReceiveId in (select ReceiveId from @Receives)
						
				--		UPDATE t
				--		   SET CommonFee = (SELECT SUM(TotalAmt) FROM [MAS_Service_Receivable] WHERE [ReceiveId] = t.ReceiveId and ServiceTypeId = 1)
				--			  ,VehicleAmt = (SELECT SUM(TotalAmt) FROM [MAS_Service_Receivable] WHERE [ReceiveId] = t.ReceiveId and ServiceTypeId = 2)
				--			  ,LivingAmt = (SELECT SUM(TotalAmt) FROM [MAS_Service_Receivable] WHERE [ReceiveId] = t.ReceiveId and ServiceTypeId = 3)
				--			  ,extendAmt = (SELECT SUM(TotalAmt) FROM [MAS_Service_Receivable] WHERE [ReceiveId] = t.ReceiveId and ServiceTypeId = 4)
				--			  ,TotalAmt = (SELECT SUM(TotalAmt) FROM [MAS_Service_Receivable] WHERE [ReceiveId] = t.ReceiveId)
				--			  ,PaidAmt = (SELECT SUM(TotalAmt) FROM [MAS_Service_Receivable] WHERE [ReceiveId] = t.ReceiveId)
				--		FROM MAS_Service_ReceiveEntry t
				--		where t.ReceiveId in (select ReceiveId from @Receives)

				--		delete from MAS_Service_ReceiveEntry where ReceiveId in (select ReceiveId from @Receives) and (TotalAmt = 0 or TotalAmt is null)
				--	end

					 INSERT INTO [dbo].[MAS_Service_ReceiveEntry]
						   ([ApartmentId]
						   ,[ReceiveDt]
						   --,[FromDt]
						   ,[ToDt]
						   ,[SysDate]
						   ,ProjectCd
						   ,IsPayed
						   ,Remart
						   ,createId
						   ,isExpected
						   )
					 SELECT a.ApartmentId
						   ,getdate()
						   --,convert(date,@StartDate,103)
						   ,@ToDt
						   ,getdate()
						   ,a.ProjectCd
						   ,0
						   ,case when @Remart = '' or @Remart  is null then N'Gia hạn vé xe: ' +case when a.isVehicleNone = 1 then a.VehicleName else a.VehicleNo end + N' đến ' + format(@ToDt,'dd/MM/yyyy') else @Remart end
						   ,@UserId
						   ,0
					FROM MAS_CardVehicle a
					WHERE CardVehicleId = @CardVehicleId 

					set @ReceiveId = @@IDENTITY

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
						   )
					SELECT 
							@ReceiveId
						   ,2
						   ,v.VehicleNo
						   ,b.Amount-round(b.Amount/11,0)
							,round(b.Amount/11,0)
						   ,b.Amount
						   ,b.StartDate
						   ,@ToDt
						   ,b.Quantity
						   ,b.Price
						   ,v.CardVehicleId
					FROM MAS_CardVehicle v 
						join [dbo].[fn_Hom_Vehicle_Payday_Get] (@CardVehicleId, @ToDt) b on v.CardVehicleId = b.CardVehicleId
					WHere v.CardVehicleId = @CardVehicleId

		            set @ApartmentId = (select top 1 ApartmentId from MAS_CardVehicle where CardVehicleId = @CardVehicleId)

					UPDATE t1
					SET  t1.EndTime = @ToDt
						,t1.lastReceivable = @ToDt
						,t1.Auth_id = @UserId
						,t1.Auth_Dt = getdate()
					FROM MAS_CardVehicle t1 
					WHERE t1.CardVehicleId = @CardVehicleId 

					UPDATE t1
					SET  t1.lastReceivable = t1.endTime_Tmp
						,t1.Auth_id = @UserId
						,t1.Auth_Dt = getdate()
					FROM MAS_CardVehicle t1 
					WHERE t1.CardVehicleId <> @CardVehicleId  and ApartmentId = @ApartmentId

					UPDATE t
					   SET CommonFee = (SELECT SUM(TotalAmt) FROM [MAS_Service_Receivable] WHERE [ReceiveId] = t.ReceiveId and ServiceTypeId = 1)
						  ,VehicleAmt = (SELECT SUM(TotalAmt) FROM [MAS_Service_Receivable] WHERE [ReceiveId] = t.ReceiveId and ServiceTypeId = 2)
						  ,LivingAmt = (SELECT SUM(TotalAmt) FROM [MAS_Service_Receivable] WHERE [ReceiveId] = t.ReceiveId and ServiceTypeId = 3)
						  ,extendAmt = (SELECT SUM(TotalAmt) FROM [MAS_Service_Receivable] WHERE [ReceiveId] = t.ReceiveId and ServiceTypeId = 4)
						  ,TotalAmt = (SELECT SUM(TotalAmt) FROM [MAS_Service_Receivable] WHERE [ReceiveId] = t.ReceiveId)
						  --,ToDt = @ToDt
						  ,[ExpireDate] = DATEADD(day,10,ToDt)
						  ,IsPayed = 1
						  ,PaidAmt = (SELECT SUM(TotalAmt) FROM [MAS_Service_Receivable] WHERE [ReceiveId] = t.ReceiveId)
					FROM MAS_Service_ReceiveEntry t
					where t.ReceiveId = @ReceiveId


					INSERT INTO [dbo].MAS_Service_Receipts
					   ([ReceiptNo]
					   ,[ReceiptDt]
					   ,[CustId]
					   ,[ApartmentId]
					   ,[ReceiveId]
					   ,[TranferCd]
					   ,[Object]
					   ,[Pass_No]
					   ,[Pass_dt]
					   ,[Pass_Plc]
					   ,[Address]
					   ,[Contents]
					   ,[Attach]
					   ,[IsDBCR]
					   ,[Amount]
					   ,[CreatorCd]
					   ,[CreateDate]
					   --,[AccountLeft]
					   --,[AccountRight]
					   ,[ProjectCd])
					SELECT
					   'H'+ right('000'+ cast( DATEPART(ms,getdate()) as varchar),3) + CAST(DATEDIFF(ss, '2018-01-01', GETUTCDATE()) as varchar) 
					   ,getdate()
					   ,t1.CustId
					   ,isnull(t1.ApartmentId,0)
					   ,@ReceiveId
					   ,'Cash'
					   ,c.FullName
					   ,c.Pass_No
					   ,c.Pass_Dt
					   ,c.Pass_Plc
					   ,c.[Address]
					   ,@Remart
					   ,''
					   ,1
					   ,@Amount
					   ,@UserID
					   ,getdate()
					   --,@AccountLeft
					   --,@AccountRight
					   ,t1.ProjectCd
					  FROM MAS_CardVehicle t1 
					  left join MAS_Customers c on t1.CustId = c.CustId
					WHERE CardVehicleId = @CardVehicleId 
			end
			else
				begin 
					INSERT INTO [dbo].[MAS_CardVehicle_Pay]
						([CardVehicleId]
						,[PayDt]
						,[empUserId]
						,[Amount]
						,[StartDt]
						,[EndDt]
						,[Remart])
					SELECT
						@CardVehicleId
						,getdate()
						,@UserId
						,@Amount
						,convert(date,@StartDate,103)
						,convert(date,@EndDate,103)
						,@Remart
					FROM MAS_CardVehicle
					WHERE CardVehicleId = @CardVehicleId 

					UPDATE t1
					SET  EndTime = @ToDt
						,lastReceivable = @ToDt
						,Auth_id = @UserId
						,Auth_Dt = getdate()
					FROM MAS_CardVehicle t1 
					WHERE CardVehicleId = @CardVehicleId 
				end
		
		select @valid as valid
			  ,@messages as [messages]

	end try
	begin catch
		declare	@ErrorNum				int,
				@ErrorMsg				varchar(200),
				@ErrorProc				varchar(50),

				@SessionID				int,
				@AddlInfo				varchar(max)

		set @ErrorNum					= error_number()
		set @ErrorMsg					= 'sp_Hom_Update_Vehicle_Pay ' + error_message()
		set @ErrorProc					= error_procedure()

		set @AddlInfo					= '@UserID ' + @UserId + ' date ' + @StartDate + ', ' + @EndDate 

		exec utl_Insert_ErrorLog @ErrorNum, @ErrorMsg, @ErrorProc, 'Vehicle_Pay', 'Update', @SessionID, @AddlInfo
	end catch