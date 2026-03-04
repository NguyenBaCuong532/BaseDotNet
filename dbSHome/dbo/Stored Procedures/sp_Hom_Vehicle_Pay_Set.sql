






CREATE procedure [dbo].[sp_Hom_Vehicle_Pay_Set]
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
		declare @errmessage nvarchar(100)
		declare @ReceiveId bigint 
		declare @ToDt datetime
		set @ToDt = EOMONTH(convert(datetime,@EndDate,103))
		set @errmessage = 'This vehicle is lastdate more than ' + @EndDate
	
	if exists(select cardvehicleid FROM MAS_CardVehicle v 
				WHere v.CardVehicleId = @CardVehicleId and monthlyType >0)
	begin
	if exists(select cardvehicleid FROM MAS_CardVehicle v 
				WHere v.CardVehicleId = @CardVehicleId and isnull(v.lastReceivable,v.StartTime) < @ToDt)
	begin
		INSERT INTO [dbo].[MAS_Service_ReceiveEntry]
				   ([ApartmentId]
				   ,[ReceiveDt]
				   --,[FromDt]
				   ,[ToDt]
				   ,[SysDate]
				   ,ProjectCd
				   ,IsPayed
				   ,Remart
				   )
			 SELECT
				    a.ApartmentId
				   ,getdate()
				   --,convert(date,@StartDate,103)
				   ,@ToDt
				   ,getdate()
				   ,a.ProjectCd
				   ,0
				   ,@Remart
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
					   ,(DATEDIFF(M,isnull(v.lastReceivable,v.StartTime),@ToDt)+case when DATEPART(D,isnull(v.lastReceivable,v.StartTime))<=15 then 1 else 0 end)
							*(select top 1 case sp.ServiceId when 5 then case when isnull(v.VehicleNum,1) <= 1 then Price else Price2 end when 6 then case when isnull(v.VehicleNum,1) <= 3 then Price else Price2 end when 7 then Price end  from [PAR_ServicePrice] sp join MAS_VehicleTypes vt on sp.ServiceId = vt.ServiceId where vt.VehicleTypeId = v.VehicleTypeId and TypeId = 1)
							-round((DATEDIFF(M,isnull(v.lastReceivable,v.StartTime),@ToDt)+case when DATEPART(D,isnull(v.lastReceivable,v.StartTime))<=15 then 1 else 0 end)
							*(select top 1 case sp.ServiceId when 5 then case when isnull(v.VehicleNum,1) <= 1 then Price else Price2 end when 6 then case when isnull(v.VehicleNum,1) <= 3 then Price else Price2 end when 7 then Price end  from [PAR_ServicePrice] sp join MAS_VehicleTypes vt on sp.ServiceId = vt.ServiceId where vt.VehicleTypeId = v.VehicleTypeId and TypeId = 1)/11,0)
						,round((DATEDIFF(M,isnull(v.lastReceivable,v.StartTime),@ToDt)+case when DATEPART(D,isnull(v.lastReceivable,v.StartTime))<=15 then 1 else 0 end)
							*(select top 1 case sp.ServiceId when 5 then case when isnull(v.VehicleNum,1) <= 1 then Price else Price2 end when 6 then case when isnull(v.VehicleNum,1) <= 3 then Price else Price2 end when 7 then Price end  from [PAR_ServicePrice] sp join MAS_VehicleTypes vt on sp.ServiceId = vt.ServiceId where vt.VehicleTypeId = v.VehicleTypeId and TypeId = 1)/11,0)
					   ,(DATEDIFF(M,isnull(v.lastReceivable,v.StartTime),@ToDt)+case when DATEPART(D,isnull(v.lastReceivable,v.StartTime))<=15 then 1 else 0 end)
							*(select top 1 case sp.ServiceId when 5 then case when isnull(v.VehicleNum,1) <= 1 then Price else Price2 end when 6 then case when isnull(v.VehicleNum,1) <= 3 then Price else Price2 end when 7 then Price end  from [PAR_ServicePrice] sp join MAS_VehicleTypes vt on sp.ServiceId = vt.ServiceId where vt.VehicleTypeId = v.VehicleTypeId and TypeId = 1)
					   ,isnull(v.lastReceivable,v.StartTime)
					   ,@ToDt
					   ,(DATEDIFF(M,isnull(v.lastReceivable,v.StartTime),@ToDt)+case when DATEPART(D,isnull(v.lastReceivable,v.StartTime))<=15 then 1 else 0 end)
					   ,(select top 1 case sp.ServiceId when 5 then case when isnull(v.VehicleNum,1) <= 1 then Price else Price2 end when 6 then case when isnull(v.VehicleNum,1) <= 3 then Price else Price2 end when 7 then Price end  from [PAR_ServicePrice] sp join MAS_VehicleTypes vt on sp.ServiceId = vt.ServiceId where vt.VehicleTypeId = v.VehicleTypeId and TypeId = 1)
					   ,v.CardVehicleId
				FROM MAS_CardVehicle v 
				WHere v.CardVehicleId = @CardVehicleId

		

		 UPDATE t1
			SET  EndTime = @ToDt
				,lastReceivable = @ToDt
				,Auth_id = @UserId
				,Auth_Dt = getdate()
			FROM MAS_CardVehicle t1 
			WHERE CardVehicleId = @CardVehicleId 

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
			RAISERROR (@errmessage, -- Message text.
				   16, -- Severity.
				   1 -- State.
				   );
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