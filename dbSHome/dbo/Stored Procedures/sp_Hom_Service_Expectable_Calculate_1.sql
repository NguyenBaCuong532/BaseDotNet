-- exec sp_Hom_Service_Expectable_Calculate null,'02','70262','2021-12-30'
CREATE procedure [dbo].[sp_Hom_Service_Expectable_Calculate]
  @UserID	nvarchar(450),
	@ProjectCd nvarchar(10),
	@Apartments nvarchar(max),
	@ToDate nvarchar(10)

as
	begin try	
	declare @ApartmentId bigint	
	declare @ReceiveId bigint
	--declare @NumMonth int
	--declare @Amount int
	declare @FromDt datetime
	declare @ToDt datetime
	declare @ToDtVehicle datetime
	declare @ToDtFee datetime
	declare @feePrice decimal(18,0)


	declare @tbAparts TABLE 
	(
		[ApartmentId] [bigint] NOT NULL INDEX IX1_Apartment NONCLUSTERED
	)
	set @ToDt = EOMONTH(convert(datetime,@todate,103))
	set @ToDtVehicle = EOMONTH(DATEADD(month,1,@ToDt))
	set @ToDtFee = EOMONTH(DATEADD(month,1,@ToDt))
	set @feePrice = isnull((select top 1 Price from [PAR_ServicePrice] where ServiceTypeId = 1 and TypeId = 1 and ProjectCd = @ProjectCd),10000)

	if @Apartments is null or @Apartments = ''
		INSERT INTO @tbAparts SELECT b.ApartmentId FROM MAS_Apartments b 
			WHERE b.ProjectCd = @ProjectCd 
				and b.IsReceived = 1
				and b.isFeeStart = 1
				and (b.DebitAmt > 0 or (isnull(b.lastReceived,b.FreeToDt) < @ToDtFee)
							or exists(select (CardVehicleId) from MAS_CardVehicle v 
							where v.StartTime < @ToDtVehicle and (v.lastReceivable is null or v.lastReceivable < @ToDtVehicle) 							
								and v.ApartmentId = b.ApartmentId)
							or exists(SELECT ([TrackingId])
							FROM [dbSHome].[dbo].[MAS_Service_Living_Tracking] t
								where IsCalculate = 1 and ToDt <= @ToDt
									and t.IsReceivable = 0
									and t.ApartmentId = b.ApartmentId
									and t.Amount!=0)
						)
	else
		INSERT INTO @tbAparts SELECT b.ApartmentId FROM [dbo].[SplitString](@Apartments,',') a 
			join MAS_Apartments b on a.part = b.ApartmentId
			WHERE b.IsReceived = 1
				and b.isFeeStart = 1
				and (b.DebitAmt > 0 or (isnull(b.lastReceived,b.FreeToDt) < @ToDtFee)
							or exists(select (CardVehicleId) from MAS_CardVehicle v 
							where v.StartTime < @ToDtVehicle and (v.lastReceivable is null or v.lastReceivable < @ToDtVehicle) 							
								and v.ApartmentId = b.ApartmentId)
							or exists(SELECT ([TrackingId])
							FROM [dbSHome].[dbo].[MAS_Service_Living_Tracking] t
								where IsCalculate = 1 and ToDt <= @ToDt
									and t.IsReceivable = 0
									and t.ApartmentId = b.ApartmentId
									and t.Amount!=0)
						)
    
    --loc nhung thang da xuat hoa don
    DELETE a
    FROM @tbAparts a
    JOIN MAS_Service_ReceiveEntry r ON r.ApartmentId = a.ApartmentId
    WHERE r.ToDt = @ToDt AND r.IsBill = 1

	--1. Entry
		UPDATE t
			   SET [ProjectCd] = ma.projectCd
				  ,[ToDt] = @ToDt
				  ,isExpected = 1
			 FROM MAS_Service_ReceiveEntry t
				join @tbAparts a on t.ApartmentId = a.ApartmentId
				join MAS_Apartments ma on a.ApartmentId = ma.ApartmentId
			 WHERE IsPayed = 0  and t.ToDt = @ToDt
				and PaidAmt = 0

		INSERT INTO [dbo].[MAS_Service_ReceiveEntry]
				   ([ApartmentId]
				   ,[ReceiveDt]
				   --,[FromDt]
				   ,[ToDt]
				   ,[SysDate]
				   ,ProjectCd
				   ,IsPayed
				   ,isExpected

				   ,CommonFee
				   ,CreditAmt
				   ,DebitAmt 
				   ,ExtendAmt 
				   ,LivingAmt
				   ,VehicleAmt 
				   ,TotalAmt 
				   ,PaidAmt
				   ,createId
				   )
			 SELECT
				    a.ApartmentId
				   ,getdate()
				   --,DATEADD(m, DATEDIFF(m, 0, (select isnull(AccrualLastDt,ReceiveDt) from MAS_Apartments where ApartmentId = @ApartmentId)), 0)
				   ,@ToDt
				   ,getdate()
				   ,ma.ProjectCd
				   ,0
				   ,1
				   ,0,0,0,0,0,0,0,0
				   ,@UserID
			FROM @tbAparts a
				join MAS_Apartments ma on a.ApartmentId = ma.ApartmentId
			where not exists(select [ApartmentId] from [MAS_Service_ReceiveEntry] 
				where ApartmentId = a.ApartmentId 
					and ToDt = @ToDt 
					and IsPayed = 0
					and isExpected =1
					)

			--2. update Fee
			
			UPDATE t 
				set	  [Amount] = h.Amount*10/11
					   ,VATAmt =h.Amount/11
					   ,TotalAmt = h.Amount
					   --,0
					   ,fromDt = isnull(a.lastReceived,a.FreeToDt)
					   ,[ToDt] = @ToDt
					   ,[Quantity] = (DATEDIFF(M, isnull(a.lastReceived,a.FreeToDt),@ToDtFee)+case when DATEPART(D,isnull(a.lastReceived,a.FreeToDt))<=15 then 1 else 0 end)
					   ,Price = h.Price
					   --,a.ApartmentId
				FROM MAS_Service_Receivable t 
					join MAS_Apartments a on t.srcId = a.ApartmentId and t.ServiceTypeId = 1
					inner join MAS_Rooms b on a.RoomCode = b.RoomCode
					join @tbAparts c on a.ApartmentId = c.ApartmentId 
					join dbo.fn_Hom_ServiceFee_Payday_project(@ProjectCd,@ToDtFee) h on a.ApartmentId = h.ApartmentId
					join [MAS_Service_ReceiveEntry] d on c.ApartmentId = d.ApartmentId
				WHERE isnull(a.lastReceived,a.FreeToDt) < @ToDtFee
					--and (DATEDIFF(M, isnull(a.lastReceived,a.FreeToDt),@ToDtFee)+case when DATEPART(D,isnull(a.lastReceived,a.FreeToDt))<=15 then 1 else 0 end)>0
					and t.[ReceiveId] = d.[ReceiveId]
					and d.ToDt = @ToDt 
					and d.IsPayed = 0
					--and not exists(select ReceivableId from MAS_Service_Receivable where [ServiceTypeId] = 1 and srcId = a.ApartmentId)
			
			--2+ insert Fee
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
						d.ReceiveId
					   ,1
					   ,b.RoomCode
					    ,h.Amount*10/11
					   , h.Amount/11
					   , h.Amount 
					   --,0
					   --,0
					   ,isnull(a.lastReceived,a.FreeToDt)
					   ,@ToDt
					   ,h.Quantity
					   ,h.Price
					   ,a.ApartmentId
				FROM MAS_Apartments a
					join MAS_Rooms b on a.RoomCode = b.RoomCode
					join @tbAparts c on a.ApartmentId = c.ApartmentId 
					join dbo.fn_Hom_ServiceFee_Payday_project(@ProjectCd,@ToDtFee) h on a.ApartmentId = h.ApartmentId
					join [MAS_Service_ReceiveEntry] d on c.ApartmentId = d.ApartmentId
				WHERE isnull(a.lastReceived,a.FreeToDt) < @ToDtFee
					--and (DATEDIFF(M, isnull(a.lastReceived,a.FreeToDt),@ToDt)+case when DATEPART(D,isnull(a.lastReceived,a.FreeToDt))<=15 then 1 else 0 end)>0
					and d.ToDt = @ToDt 
					and d.IsPayed = 0
					and d.PaidAmt = 0
					and not exists(select ReceivableId from MAS_Service_Receivable t1 
							join [MAS_Service_ReceiveEntry] t2 on t1.ReceiveId = t2.ReceiveId  
							where [ServiceTypeId] = 1 and srcId = a.ApartmentId 
								and t2.IsPayed = 0
								--and t2.PaidAmt = 0
								)
		   

			UPDATE a
				SET [AccrualLastDt] = @ToDtFee
			FROM MAS_Apartments a
				join @tbAparts c on a.ApartmentId = c.ApartmentId 
				join MAS_Service_Receivable r on a.ApartmentId = r.srcId and ServiceTypeId = 1
				join [MAS_Service_ReceiveEntry] d on r.ReceiveId = d.ReceiveId
				WHERE (a.ReceiveDt < @ToDtFee
					and (isnull(a.lastReceived,a.FreeToDt) < @ToDtFee))
					and d.IsPayed = 0
					and d.PaidAmt = 0
					--and (DATEDIFF(M, isnull(a.lastReceived,a.FreeToDt),@ToDt)+case when DATEPART(D,isnull(a.lastReceived,a.FreeToDt))<=15 then 1 else 0 end)>0
					
			
			--3. Vehicle
				Update t
				  set  [Amount] = round(b.Amount*10/11,0)
					   ,VATAmt = round(b.amount/11,0)
					   ,TotalAmt = b.Amount
					   ,fromDt = isnull(v.endTime_Tmp,v.StartTime)
					   ,[ToDt] = @ToDtVehicle
					   ,[Quantity] = b.[Quantity]
					   ,price = b.Price
					   --,v.CardVehicleId as srcId
				FROM MAS_Service_Receivable t
					join MAS_CardVehicle v on t.srcId = v.CardVehicleId and [ServiceTypeId] = 2
					join @tbAparts a on v.ApartmentId = a.ApartmentId
					join [MAS_Service_ReceiveEntry] d on a.ApartmentId = d.ApartmentId and t.ReceiveId = d.ReceiveId
					join [dbo].[fn_Hom_Vehicle_Payday_project] (@ProjectCd, @ToDtVehicle) b on v.CardVehicleId = b.CardVehicleId
				WHERE  isnull(v.EndTime,v.StartTime) <= @ToDtVehicle and (v.lastReceivable is null or v.lastReceivable <= @ToDtVehicle)
					and d.IsPayed = 0
					and d.PaidAmt = 0

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
						d.ReceiveId
					   ,2
					   ,v.VehicleNo
					   ,b.Amount - round(b.amount/11,0)
					   ,round(b.amount/11,0)
					   ,b.Amount
					   ,isnull(v.endTime_Tmp,v.StartTime)
					   ,@ToDtVehicle
					   ,b.[Quantity]
					   ,b.Price
					   ,v.CardVehicleId as srcId
				FROM MAS_CardVehicle v 
					join @tbAparts a on v.ApartmentId = a.ApartmentId
					join [MAS_Service_ReceiveEntry] d on a.ApartmentId = d.ApartmentId
					join [dbo].[fn_Hom_Vehicle_Payday_project] (@ProjectCd, @ToDtVehicle) b on v.CardVehicleId = b.CardVehicleId
				WHERE 
					isnull(v.EndTime,v.StartTime) <= @ToDtVehicle and (v.lastReceivable is null or v.lastReceivable <= @ToDtVehicle)
					--and  v.[Status] = 1 
					and d.IsPayed = 0
					and d.PaidAmt = 0
					and not exists(select ReceivableId from MAS_Service_Receivable where [ServiceTypeId] = 2 and srcId = v.CardVehicleId and IsPayed = 0  and ReceiveId = d.ReceiveId and ToDt = @ToDtVehicle)
			
			UPDATE v
				SET lastReceivable = @ToDtVehicle,
				    endTime_Tmp = EndTime
				    --EndTime = @ToDtVehicle
			FROM MAS_CardVehicle v 
				join @tbAparts a on v.ApartmentId = a.ApartmentId
				join MAS_Service_Receivable r on v.CardVehicleId = r.srcId and ServiceTypeId = 2
				join [MAS_Service_ReceiveEntry] d on r.ReceiveId = d.ReceiveId
				WHERE d.IsPayed = 0
					--and v.Status = 1
					and d.PaidAmt = 0
					--and (DATEDIFF(M,isnull(v.lastReceivable,v.StartTime),@ToDtVehicle)+case when DATEPART(D,isnull(v.lastReceivable,v.StartTime))<=15 then 1 else 0 end) > 0			
			
			--4. Living fee
			Update t
				  set   [Amount] = v.Amount
					   ,VATAmt = case v.LivingTypeId when 1  then round(v.Amount*0.08,0) 
					                                 when 2 then round(v.Amount*0.15,0) end
					   ,TotalAmt = case v.LivingTypeId when 1 then round(v.Amount*1.08,0) when 2 then round(v.Amount*1.15,0) end
					   ,fromDt = v.FromDt
					   ,[ToDt] = v.ToDt
					   ,[Quantity] = v.TotalNum
					   ,price = v.Amount
					   ,NtshAmt = case v.LivingTypeId when 1 then 0 when 2 then round(v.Amount/10,0) end
					   --,v.CardVehicleId as srcId
				FROM MAS_Service_Receivable t
					join MAS_Service_Living_Tracking v on t.srcId = v.TrackingId and [ServiceTypeId] = 3
					join MAS_LivingTypes c on v.LivingTypeId = c.LivingTypeId
					join @tbAparts a on v.ApartmentId = a.ApartmentId
					join [MAS_Service_ReceiveEntry] d on a.ApartmentId = d.ApartmentId
				WHERE v.IsCalculate = 1 
					and t.[ReceiveId] = d.[ReceiveId]
					--AND v.StartTime < @ToDtVehicle and (v.lastReceivable is null or v.lastReceivable < @ToDtVehicle)
					--and (DATEDIFF(M,isnull(v.lastReceivable,v.StartTime),@ToDtVehicle)+case when DATEPART(D,isnull(v.lastReceivable,v.StartTime))<=15 then 1 else 0 end) > 0
					--and EOMONTH(DateAdd(month,1,d.ToDt)) = @ToDtVehicle 
					and MONTH(d.ToDt) = MONTH(@ToDt) and YEAR(d.ToDt) = YEAR(@ToDt)
					and d.IsPayed = 0
					and d.PaidAmt = 0
					and v.ToDt > convert(datetime,'2020-30-11',103)

			INSERT INTO MAS_Service_Receivable
					   ([ReceiveId]
					   ,[ServiceTypeId]
					   ,[ServiceObject]
					   ,[Amount]
					   ,VATAmt
					   ,TotalAmt
					   ,NtshAmt
					   ,fromDt
					   ,[ToDt]
					   ,[Quantity]
					   ,Price
					   ,srcId
					   )
				 SELECT 
						d.ReceiveId
					   ,3
					   ,c.LivingTypeName
					   ,v.Amount
					   ,case v.LivingTypeId when 1 then round(v.Amount*0.08,0) when 2  then round(v.Amount*0.15,0) end
					   ,case v.LivingTypeId when 1 then round(v.Amount*1.08,0) when 2 then round(v.Amount*1.15,0) end
					   ,case v.LivingTypeId when 1 then 0 when 2 then round(v.Amount/10,0) end
					   ,v.FromDt
					   ,v.ToDt
					   ,v.TotalNum
					   ,v.Amount
					   ,v.TrackingId
				FROM MAS_Service_Living_Tracking v 
					join MAS_LivingTypes c on v.LivingTypeId = c.LivingTypeId
					join @tbAparts a on v.ApartmentId = a.ApartmentId
					join [MAS_Service_ReceiveEntry] d on a.ApartmentId = d.ApartmentId
				WHERE v.IsCalculate = 1 
					and d.IsPayed = 0
					and d.PaidAmt = 0
					AND v.ToDt <= @ToDt 
					and v.IsReceivable = 0
					and not exists(select ReceivableId from MAS_Service_Receivable where [ServiceTypeId] = 3 and srcId = v.TrackingId and ReceiveId = d.ReceiveId and MONTH(ToDt) = MONTH(@ToDt) and YEAR(ToDt) = YEAR(@ToDt))
					and v.ToDt > convert(datetime,'2020-30-11',103)


			--5.update
			UPDATE t
			   SET CommonFee = (SELECT SUM(TotalAmt) FROM [MAS_Service_Receivable] WHERE [ReceiveId] = t.ReceiveId and ServiceTypeId = 1)
				  ,VehicleAmt = (SELECT SUM(TotalAmt) FROM [MAS_Service_Receivable] WHERE [ReceiveId] = t.ReceiveId and ServiceTypeId = 2)
				  ,LivingAmt = (SELECT SUM(TotalAmt) FROM [MAS_Service_Receivable] WHERE [ReceiveId] = t.ReceiveId and (ServiceTypeId = 3))
				  ,extendAmt = (SELECT SUM(TotalAmt) FROM [MAS_Service_Receivable] WHERE [ReceiveId] = t.ReceiveId and ServiceTypeId = 8)
				  ,TotalAmt = (SELECT SUM(TotalAmt) FROM [MAS_Service_Receivable] WHERE [ReceiveId] = t.ReceiveId) + isnull(c.DebitAmt,0) - isnull(c.RefundAmt,0)
				  ,DebitAmt = c.DebitAmt
				  ,RefundAmt = c.RefundAmt
				  --,CreditAmt = CreditAmt - c.DebitAmt 
				  ,[ExpireDate] = DATEADD(day,10,ToDt)
			FROM MAS_Service_ReceiveEntry t
				join @tbAparts a on t.ApartmentId = a.ApartmentId
				join MAS_Apartments c on a.ApartmentId = c.ApartmentId
			 WHERE t.IsPayed = 0 -- and 
				and t.PaidAmt = 0

			--update  t
			--	set t.DebitAmt = isnull(t.DebitAmt,0) + (SELECT SUM(TotalAmt) FROM [MAS_Service_Receivable] WHERE [ReceiveId] = k.ReceiveId)
			--from MAS_Apartments t 
			--	join @tbAparts a on t.ApartmentId = a.ApartmentId
			--	join MAS_Service_ReceiveEntry k on a.ApartmentId = k.ApartmentId
			--where IsPayed = 0

			--select * from MAS_Service_ReceiveEntry where ApartmentId = 6132
			--select * from MAS_Service_Receivable where ReceiveId =28097
	------------
	      --
	

	end try
	begin catch
		declare	@ErrorNum				int,
				@ErrorMsg				varchar(200),
				@ErrorProc				varchar(50),

				@SessionID				int,
				@AddlInfo				varchar(max)

		set @ErrorNum					= error_number()
		set @ErrorMsg					= 'sp_Hom_Service_Expectable_Calculate ' + error_message()
		set @ErrorProc					= error_procedure()

		set @AddlInfo					= '@UserID ' + @UserID 

		exec utl_Insert_ErrorLog @ErrorNum, @ErrorMsg, @ErrorProc, 'Receivable', 'Ins', @SessionID, @AddlInfo
	end catch

	--select * from MAS_Service_Receivable where ReceiveId = 30424