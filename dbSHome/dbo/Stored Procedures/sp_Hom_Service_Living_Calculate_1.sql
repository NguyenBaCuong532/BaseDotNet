



-- exec sp_Hom_Service_Living_Calculate_Covid null,125178,'05',1,9,2021

CREATE procedure [dbo].[sp_Hom_Service_Living_Calculate]
	
	@UserID	nvarchar(450),
	@TrackingId int,
	@ProjectCd nvarchar(30),
	@LivingType int,
	@PeriodMonth int,
	@PeriodYear int

as
	begin try	
	--set @LivingType = 1
	
	if @TrackingId > 0
	begin
		UPDATE t
		  set t.[Quantity] =(case when mp.caculateWaterType = 1 and b.LivingTypeId = 2  then 
			              (case a.Pos when 1 then (case when b.TotalNum > 0 then case when b.TotalNum > isnull(ma.NumPersonWater,1)*4 then isnull(ma.NumPersonWater,1)*4 else b.TotalNum end else 0 end)
								         when 2 then (case when b.TotalNum > 0 then case when b.TotalNum > isnull(ma.NumPersonWater,1)*6  then isnull(ma.NumPersonWater,1)*2  else b.TotalNum - (case when b.TotalNum > 0 then case when b.TotalNum > isnull(ma.NumPersonWater,1)*4 then isnull(ma.NumPersonWater,1)*4 else b.TotalNum end else 0 end) end else 0 end)
								         when 3 then (case when b.TotalNum - isnull(ma.NumPersonWater,1)*4 - isnull(ma.NumPersonWater,1)*2 < 0 then 0 else b.TotalNum - isnull(ma.NumPersonWater,1)*4 - isnull(ma.NumPersonWater,1)*2 end) end)
		                 else (case when b.TotalNum > a.[NumFrom] then case when a.[NumTo] is null or b.TotalNum <= a.[NumTo] then b.TotalNum - a.NumFrom else a.NumTo - a.[NumFrom] end else 0 end)end)
			  ,t.[Price] = a.Price
			  ,t.[Amount] = ((case when mp.caculateWaterType = 1 and b.LivingTypeId = 2  then 
							  (case a.Pos when 1 then (case when b.TotalNum > 0 then case when b.TotalNum > isnull(ma.NumPersonWater,1)*4 then isnull(ma.NumPersonWater,1)*4 else b.TotalNum end else 0 end)
										  when 2 then (case when b.TotalNum > 0 then case when b.TotalNum > isnull(ma.NumPersonWater,1)*6  then isnull(ma.NumPersonWater,1)*2  else b.TotalNum - (case when b.TotalNum > 0 then case when b.TotalNum > isnull(ma.NumPersonWater,1)*4 then isnull(ma.NumPersonWater,1)*4 else b.TotalNum end else 0 end) end else 0 end)
										  when 3 then (case when b.TotalNum - isnull(ma.NumPersonWater,1)*4 - isnull(ma.NumPersonWater,1)*2 < 0 then 0 else b.TotalNum - isnull(ma.NumPersonWater,1)*4 - isnull(ma.NumPersonWater,1)*2 end) end)
		                   else 
						      (case when b.TotalNum > a.[NumFrom] then case when a.[NumTo] is null or b.TotalNum <= a.[NumTo] then b.TotalNum - a.NumFrom else a.NumTo - a.[NumFrom] end else 0 end)end)*a.[Price])
						--- isnull(a.free_rt,0)*(case when b.TotalNum > a.[NumFrom] then case when a.[NumTo] is null or b.TotalNum <= a.[NumTo] then b.TotalNum - a.NumFrom else a.NumTo - a.[NumFrom] end else 0 end)*a.[Price]
			  ,t.FreeAmt = isnull(a.free_rt,0)*(case when mp.caculateWaterType = 1 and b.LivingTypeId = 2  then 
			              (case a.Pos when 1 then (case when b.TotalNum > 0 then case when b.TotalNum > isnull(ma.NumPersonWater,1)*4 then isnull(ma.NumPersonWater,1)*4 else b.TotalNum end else 0 end)
								         when 2 then (case when b.TotalNum > 0 then case when b.TotalNum > isnull(ma.NumPersonWater,1)*6  then isnull(ma.NumPersonWater,1)*2  else b.TotalNum - (case when b.TotalNum > 0 then case when b.TotalNum > isnull(ma.NumPersonWater,1)*4 then isnull(ma.NumPersonWater,1)*4 else b.TotalNum end else 0 end) end else 0 end)
								         when 3 then (case when b.TotalNum - isnull(ma.NumPersonWater,1)*4 - isnull(ma.NumPersonWater,1)*2 < 0 then 0 else b.TotalNum - isnull(ma.NumPersonWater,1)*4 - isnull(ma.NumPersonWater,1)*2 end) end)
		                 else (case when b.TotalNum > a.[NumFrom] then case when a.[NumTo] is null or b.TotalNum <= a.[NumTo] then b.TotalNum - a.NumFrom else a.NumTo - a.[NumFrom] end else 0 end)end)*a.[Price]
		 FROM [MAS_Service_Living_CalSheet] t
			join [PAR_ServiceLivingPrice] a on t.StepPos = a.Pos
			join MAS_Service_Living_Tracking b on t.TrackingId = b.TrackingId and a.ProjectCd = b.ProjectCd and a.LivingTypeId = b.LivingTypeId
			join MAS_Apartment_Service_Living ma on b.ApartmentId = ma.ApartmentId and ma.LivingTypeId = b.LivingTypeId and a.LivingTypeId = ma.LivingTypeId
			join MAS_Projects mp on b.ProjectCd = mp.projectCd
			where b.TrackingId = @TrackingId
				and IsReceivable = 0
        


		INSERT INTO [MAS_Service_Living_CalSheet]
				   ([TrackingId]
				   ,[StepPos]
				   ,[fromN]
				   ,[toN]
				   ,[Quantity]
				   ,[Price]
				   ,[Amount]
				   ,FreeAmt
				   --,TotalAmt
				   )
			SELECT distinct @TrackingId
				  ,[Pos]
				  ,[NumFrom]
				  ,[NumTo]
				  ,(case when mp.caculateWaterType = 1 and b.LivingTypeId = 2  then 
			              (case a.Pos when 1 then (case when b.TotalNum > 0 then case when b.TotalNum > isnull(ma.NumPersonWater,1)*4 then isnull(ma.NumPersonWater,1)*4 else b.TotalNum end else 0 end)
								         when 2 then (case when b.TotalNum > 0 then case when b.TotalNum > isnull(ma.NumPersonWater,1)*6  then isnull(ma.NumPersonWater,1)*2  else b.TotalNum - (case when b.TotalNum > 0 then case when b.TotalNum > isnull(ma.NumPersonWater,1)*4 then isnull(ma.NumPersonWater,1)*4 else b.TotalNum end else 0 end) end else 0 end)
								         when 3 then (case when b.TotalNum - isnull(ma.NumPersonWater,1)*4 - isnull(ma.NumPersonWater,1)*2 < 0 then 0 else b.TotalNum - isnull(ma.NumPersonWater,1)*4 - isnull(ma.NumPersonWater,1)*2 end) end)
		                 else (case when b.TotalNum > a.[NumFrom] then case when a.[NumTo] is null or b.TotalNum <= a.[NumTo] then b.TotalNum - a.NumFrom else a.NumTo - a.[NumFrom] end else 0 end)end) as [Quantity]
				  ,[Price]
				  ,(case when mp.caculateWaterType = 1 and b.LivingTypeId = 2  then 
			              (case a.Pos when 1 then (case when b.TotalNum > 0 then case when b.TotalNum > isnull(ma.NumPersonWater,1)*4 then isnull(ma.NumPersonWater,1)*4 else b.TotalNum end else 0 end)
								         when 2 then (case when b.TotalNum > 0 then case when b.TotalNum > isnull(ma.NumPersonWater,1)*6  then isnull(ma.NumPersonWater,1)*2  else b.TotalNum - (case when b.TotalNum > 0 then case when b.TotalNum > isnull(ma.NumPersonWater,1)*4 then isnull(ma.NumPersonWater,1)*4 else b.TotalNum end else 0 end) end else 0 end)
								         when 3 then (case when b.TotalNum - isnull(ma.NumPersonWater,1)*4 - isnull(ma.NumPersonWater,1)*2 < 0 then 0 else b.TotalNum - isnull(ma.NumPersonWater,1)*4 - isnull(ma.NumPersonWater,1)*2 end) end)
		                 else (case when b.TotalNum > a.[NumFrom] then case when a.[NumTo] is null or b.TotalNum <= a.[NumTo] then b.TotalNum - a.NumFrom else a.NumTo - a.[NumFrom] end else 0 end)end)*a.[Price]
					--- isnull(a.free_rt,0)*(case when b.TotalNum > a.[NumFrom] then case when a.[NumTo] is null or b.TotalNum <= a.[NumTo] then b.TotalNum - a.NumFrom else a.NumTo - a.[NumFrom] end else 0 end)*[Price] as [Amount]
				  ,isnull(a.free_rt,0)*(case when mp.caculateWaterType = 1 and b.LivingTypeId = 2  then 
			              (case a.Pos when 1 then (case when b.TotalNum > 0 then case when b.TotalNum > isnull(ma.NumPersonWater,1)*4 then isnull(ma.NumPersonWater,1)*4 else b.TotalNum end else 0 end)
								         when 2 then (case when b.TotalNum > 0 then case when b.TotalNum > isnull(ma.NumPersonWater,1)*6  then isnull(ma.NumPersonWater,1)*2  else b.TotalNum - (case when b.TotalNum > 0 then case when b.TotalNum > isnull(ma.NumPersonWater,1)*4 then isnull(ma.NumPersonWater,1)*4 else b.TotalNum end else 0 end) end else 0 end)
								         when 3 then (case when b.TotalNum - isnull(ma.NumPersonWater,1)*4 - isnull(ma.NumPersonWater,1)*2 < 0 then 0 else b.TotalNum - isnull(ma.NumPersonWater,1)*4 - isnull(ma.NumPersonWater,1)*2 end) end)
		                 else (case when b.TotalNum > a.[NumFrom] then case when a.[NumTo] is null or b.TotalNum <= a.[NumTo] then b.TotalNum - a.NumFrom else a.NumTo - a.[NumFrom] end else 0 end)end)*a.[Price] as FreeAmt
			  FROM MAS_Service_Living_Tracking b
				join MAS_Apartments c on b.ApartmentId = c.ApartmentId 
				join [PAR_ServiceLivingPrice] a on a.LivingTypeId = b.LivingTypeId and a.ProjectCd = c.ProjectCd 
			    join MAS_Apartment_Service_Living ma on b.ApartmentId = ma.ApartmentId and ma.LivingTypeId = b.LivingTypeId and a.LivingTypeId = ma.LivingTypeId
			    join MAS_Projects mp on b.ProjectCd = mp.projectCd
			  where b.TrackingId = @TrackingId
				and IsReceivable = 0
				and not exists(select Id from [MAS_Service_Living_CalSheet] where TrackingId = @TrackingId and StepPos = a.Pos) 
			order by Pos
	
	
			UPDATE b
			SET IsCalculate = 1
				  ,Amount = (Select sum(Amount) from [MAS_Service_Living_CalSheet] where TrackingId = b.TrackingId) *(1 - (case when @LivingType = 1 then (case  isnull(mp.type_discount_elec,0) when 1 then 0.1  
		                     when 2 then (case when (Select sum(Quantity) from [MAS_Service_Living_CalSheet] where TrackingId = b.TrackingId) > 200 then 0.1 else 0.15 end)
							 when 0 then 0 end) else 0 end))
				  ,freeAmt =  (Select sum(isnull(freeAmt,0)) from [MAS_Service_Living_CalSheet] where TrackingId = b.TrackingId)
				  ,DiscountAmt = (Select sum(Amount) from [MAS_Service_Living_CalSheet] where TrackingId = b.TrackingId)*(case when @LivingType = 1 then (case  isnull(mp.type_discount_elec,0) when 1 then 0.1  
		                     when 2 then (case when (Select sum(Quantity) from [MAS_Service_Living_CalSheet] where TrackingId = b.TrackingId) > 200 then 0.1 else 0.15 end)
							 when 0 then 0 end) else 0 end)
			FROM MAS_Service_Living_Tracking b 
				join MAS_Apartment_Service_Living c on b.LivingId = c.LivingId and b.LivingTypeId = 1
				INNER JOIN MAS_Apartments d On c.ApartmentId = d.ApartmentId 
				inner join MAS_Projects mp on b.ProjectCd = mp.projectCd
			WHERE b.TrackingId = @TrackingId
				and IsReceivable = 0

			UPDATE b
			SET IsCalculate = 1
				  ,Amount = (Select sum(Amount) from [MAS_Service_Living_CalSheet] where TrackingId = b.TrackingId) *(1 - (case when @LivingType = 2 then (case  isnull(mp.type_discount_water,0) when 1 then 0.15  
							 when 0 then 0 end) else 0 end))
				  ,freeAmt =  (Select sum(isnull(freeAmt,0)) from [MAS_Service_Living_CalSheet] where TrackingId = b.TrackingId)
				  ,DiscountAmt = (Select sum(Amount) from [MAS_Service_Living_CalSheet] where TrackingId = b.TrackingId)*(case when @LivingType = 2 then (case  isnull(mp.type_discount_water,0) when 1 then 0.15
							 when 0 then 0 end) else 0 end)
			FROM MAS_Service_Living_Tracking b 
				join MAS_Apartment_Service_Living c on b.LivingId = c.LivingId and b.LivingTypeId = 2
				INNER JOIN MAS_Apartments d On c.ApartmentId = d.ApartmentId 
				inner join MAS_Projects mp on b.ProjectCd = mp.projectCd
			WHERE b.TrackingId = @TrackingId
				and IsReceivable = 0


		   
		end
		else
		begin

			UPDATE t
			  set t.[Quantity] =(case when mp.caculateWaterType = 1 and b.LivingTypeId = 2  then 
							  (case a.Pos when 1 then (case when b.TotalNum > 0 then case when b.TotalNum > isnull(ma.NumPersonWater,1)*4 then isnull(ma.NumPersonWater,1)*4 else b.TotalNum end else 0 end)
											 when 2 then (case when b.TotalNum > 0 then case when b.TotalNum > isnull(ma.NumPersonWater,1)*6  then isnull(ma.NumPersonWater,1)*2  else b.TotalNum - (case when b.TotalNum > 0 then case when b.TotalNum > isnull(ma.NumPersonWater,1)*4 then isnull(ma.NumPersonWater,1)*4 else b.TotalNum end else 0 end) end else 0 end)
											 when 3 then (case when b.TotalNum - isnull(ma.NumPersonWater,1)*4 - isnull(ma.NumPersonWater,1)*2 < 0 then 0 else b.TotalNum - isnull(ma.NumPersonWater,1)*4 - isnull(ma.NumPersonWater,1)*2 end) end)
							 else (case when b.TotalNum > a.[NumFrom] then case when a.[NumTo] is null or b.TotalNum <= a.[NumTo] then b.TotalNum - a.NumFrom else a.NumTo - a.[NumFrom] end else 0 end)end)
				  ,t.[Price] = a.Price
				  ,t.[Amount] =(case when mp.caculateWaterType = 1 and b.LivingTypeId = 2  then 
							  (case a.Pos when 1 then (case when b.TotalNum > 0 then case when b.TotalNum > isnull(ma.NumPersonWater,1)*4 then isnull(ma.NumPersonWater,1)*4 else b.TotalNum end else 0 end)
											 when 2 then (case when b.TotalNum > 0 then case when b.TotalNum > isnull(ma.NumPersonWater,1)*6  then isnull(ma.NumPersonWater,1)*2  else b.TotalNum - (case when b.TotalNum > 0 then case when b.TotalNum > isnull(ma.NumPersonWater,1)*4 then isnull(ma.NumPersonWater,1)*4 else b.TotalNum end else 0 end) end else 0 end)
											 when 3 then (case when b.TotalNum - isnull(ma.NumPersonWater,1)*4 - isnull(ma.NumPersonWater,1)*2 < 0 then 0 else b.TotalNum - isnull(ma.NumPersonWater,1)*4 - isnull(ma.NumPersonWater,1)*2 end) end)
							 else (case when b.TotalNum > a.[NumFrom] then case when a.[NumTo] is null or b.TotalNum <= a.[NumTo] then b.TotalNum - a.NumFrom else a.NumTo - a.[NumFrom] end else 0 end)end)*a.[Price]
							--- isnull(a.free_rt,0)*(case when b.TotalNum > a.[NumFrom] then case when a.[NumTo] is null or b.TotalNum <= a.[NumTo] then b.TotalNum - a.NumFrom else a.NumTo - a.[NumFrom] end else 0 end)*a.[Price]
				  ,t.FreeAmt = isnull(a.free_rt,0)*(case when mp.caculateWaterType = 1 and b.LivingTypeId = 2  then 
							  (case a.Pos when 1 then (case when b.TotalNum > 0 then case when b.TotalNum > isnull(ma.NumPersonWater,1)*4 then isnull(ma.NumPersonWater,1)*4 else b.TotalNum end else 0 end)
											 when 2 then (case when b.TotalNum > 0 then case when b.TotalNum > isnull(ma.NumPersonWater,1)*6  then isnull(ma.NumPersonWater,1)*2  else b.TotalNum - (case when b.TotalNum > 0 then case when b.TotalNum > isnull(ma.NumPersonWater,1)*4 then isnull(ma.NumPersonWater,1)*4 else b.TotalNum end else 0 end) end else 0 end)
											 when 3 then (case when b.TotalNum - isnull(ma.NumPersonWater,1)*4 - isnull(ma.NumPersonWater,1)*2 < 0 then 0 else b.TotalNum - isnull(ma.NumPersonWater,1)*4 - isnull(ma.NumPersonWater,1)*2 end) end)
							 else (case when b.TotalNum > a.[NumFrom] then case when a.[NumTo] is null or b.TotalNum <= a.[NumTo] then b.TotalNum - a.NumFrom else a.NumTo - a.[NumFrom] end else 0 end)end)*a.[Price]
			 FROM [MAS_Service_Living_CalSheet] t
				join [PAR_ServiceLivingPrice] a on t.StepPos = a.Pos
				join MAS_Service_Living_Tracking b on t.TrackingId = b.TrackingId and a.ProjectCd = b.ProjectCd and a.LivingTypeId = b.LivingTypeId
				join MAS_Apartment_Service_Living ma on b.ApartmentId = ma.ApartmentId and ma.LivingTypeId = b.LivingTypeId and a.LivingTypeId = ma.LivingTypeId
				join MAS_Projects mp on b.ProjectCd = mp.projectCd
				where b.LivingTypeId = @LivingType
					and month(b.ToDt) = @PeriodMonth
					and year(b.ToDt) = @PeriodYear
					and IsReceivable = 0
					and b.ProjectCd = @ProjectCd


         INSERT INTO [MAS_Service_Living_CalSheet]
				   ([TrackingId]
				   ,[StepPos]
				   ,[fromN]
				   ,[toN]
				   ,[Quantity]
				   ,[Price]
				   ,[Amount]
				   ,FreeAmt
				   )
		SELECT distinct b.TrackingId
				  ,[Pos]
				  ,[NumFrom]
				  ,[NumTo]
				  ,(case when mp.caculateWaterType = 1 and b.LivingTypeId = 2  then 
			              (case a.Pos when 1 then (case when b.TotalNum > 0 then case when b.TotalNum > isnull(ma.NumPersonWater,1)*4 then isnull(ma.NumPersonWater,1)*4 else b.TotalNum end else 0 end)
								         when 2 then (case when b.TotalNum > 0 then case when b.TotalNum > isnull(ma.NumPersonWater,1)*6  then isnull(ma.NumPersonWater,1)*2  else b.TotalNum - (case when b.TotalNum > 0 then case when b.TotalNum > isnull(ma.NumPersonWater,1)*4 then isnull(ma.NumPersonWater,1)*4 else b.TotalNum end else 0 end) end else 0 end)
								         when 3 then (case when b.TotalNum - isnull(ma.NumPersonWater,1)*4 - isnull(ma.NumPersonWater,1)*2 < 0 then 0 else b.TotalNum - isnull(ma.NumPersonWater,1)*4 - isnull(ma.NumPersonWater,1)*2 end) end)
		                 else (case when b.TotalNum > a.[NumFrom] then case when a.[NumTo] is null or b.TotalNum <= a.[NumTo] then b.TotalNum - a.NumFrom else a.NumTo - a.[NumFrom] end else 0 end)end) as [Quantity]
				  ,[Price]
				  ,(case when mp.caculateWaterType = 1 and b.LivingTypeId = 2  then 
			              (case a.Pos when 1 then (case when b.TotalNum > 0 then case when b.TotalNum > isnull(ma.NumPersonWater,1)*4 then isnull(ma.NumPersonWater,1)*4 else b.TotalNum end else 0 end)
								         when 2 then (case when b.TotalNum > 0 then case when b.TotalNum > isnull(ma.NumPersonWater,1)*6  then isnull(ma.NumPersonWater,1)*2  else b.TotalNum - (case when b.TotalNum > 0 then case when b.TotalNum > isnull(ma.NumPersonWater,1)*4 then isnull(ma.NumPersonWater,1)*4 else b.TotalNum end else 0 end) end else 0 end)
								         when 3 then (case when b.TotalNum - isnull(ma.NumPersonWater,1)*4 - isnull(ma.NumPersonWater,1)*2 < 0 then 0 else b.TotalNum - isnull(ma.NumPersonWater,1)*4 - isnull(ma.NumPersonWater,1)*2 end) end)
		                 else (case when b.TotalNum > a.[NumFrom] then case when a.[NumTo] is null or b.TotalNum <= a.[NumTo] then b.TotalNum - a.NumFrom else a.NumTo - a.[NumFrom] end else 0 end)end)*a.[Price]
					--- isnull(a.free_rt,0)*(case when b.TotalNum > a.[NumFrom] then case when a.[NumTo] is null or b.TotalNum <= a.[NumTo] then b.TotalNum - a.NumFrom else a.NumTo - a.[NumFrom] end else 0 end)*[Price] as [Amount]
				  ,isnull(a.free_rt,0)*(case when mp.caculateWaterType = 1 and b.LivingTypeId = 2  then 
			              (case a.Pos when 1 then (case when b.TotalNum > 0 then case when b.TotalNum > isnull(ma.NumPersonWater,1)*4 then isnull(ma.NumPersonWater,1)*4 else b.TotalNum end else 0 end)
								         when 2 then (case when b.TotalNum > 0 then case when b.TotalNum > isnull(ma.NumPersonWater,1)*6  then isnull(ma.NumPersonWater,1)*2  else b.TotalNum - (case when b.TotalNum > 0 then case when b.TotalNum > isnull(ma.NumPersonWater,1)*4 then isnull(ma.NumPersonWater,1)*4 else b.TotalNum end else 0 end) end else 0 end)
								         when 3 then (case when b.TotalNum - isnull(ma.NumPersonWater,1)*4 - isnull(ma.NumPersonWater,1)*2 < 0 then 0 else b.TotalNum - isnull(ma.NumPersonWater,1)*4 - isnull(ma.NumPersonWater,1)*2 end) end)
		                 else (case when b.TotalNum > a.[NumFrom] then case when a.[NumTo] is null or b.TotalNum <= a.[NumTo] then b.TotalNum - a.NumFrom else a.NumTo - a.[NumFrom] end else 0 end)end)*a.[Price] as FreeAmt
			  FROM MAS_Service_Living_Tracking b
				join MAS_Apartments c on b.ApartmentId = c.ApartmentId 
				join [PAR_ServiceLivingPrice] a on a.LivingTypeId = b.LivingTypeId and a.ProjectCd = c.ProjectCd 
			    join MAS_Apartment_Service_Living ma on b.ApartmentId = ma.ApartmentId  and ma.LivingTypeId = b.LivingTypeId and a.LivingTypeId = ma.LivingTypeId
			    join MAS_Projects mp on  b.ProjectCd = mp.projectCd
			  where b.LivingTypeId = @LivingType
				and month(b.ToDt) = @PeriodMonth
				and year(b.ToDt) = @PeriodYear
				and IsReceivable = 0
				and c.projectCd = @ProjectCd
				and not exists(select Id from [MAS_Service_Living_CalSheet] where TrackingId = b.TrackingId and StepPos = a.Pos) 
			order by b.TrackingId, Pos
	
	
			UPDATE b
			   SET IsCalculate = 1
				  ,Amount = (Select sum(Amount) from [MAS_Service_Living_CalSheet] where TrackingId = b.TrackingId) *(1 - (case when @LivingType = 1 then (case  isnull(mp.type_discount_elec,0) when 1 then 0.1  
		                     when 2 then (case when (Select sum(Quantity) from [MAS_Service_Living_CalSheet] where TrackingId = b.TrackingId) > 200 then 0.1 else 0.15 end)
							 when 0 then 0 end) else 0 end))
				  ,freeAmt =  (Select sum(isnull(freeAmt,0)) from [MAS_Service_Living_CalSheet] where TrackingId = b.TrackingId)
				  ,DiscountAmt = (Select sum(Amount) from [MAS_Service_Living_CalSheet] where TrackingId = b.TrackingId)*(case when @LivingType = 1 then (case  isnull(mp.type_discount_elec,0) when 1 then 0.1  
		                     when 2 then (case when (Select sum(Quantity) from [MAS_Service_Living_CalSheet] where TrackingId = b.TrackingId) > 200 then 0.1 else 0.15 end)
							 when 0 then 0 end) else 0 end)
			FROM MAS_Service_Living_Tracking b 
				join MAS_Apartment_Service_Living c on b.LivingId = c.LivingId and b.LivingTypeId = 1
				INNER JOIN MAS_Apartments d On c.ApartmentId = d.ApartmentId 
				inner join MAS_Projects mp on  b.ProjectCd = mp.projectCd
			WHERE b.LivingTypeId = @LivingType
				and month(b.ToDt) = @PeriodMonth
				and year(b.ToDt) = @PeriodYear
				and d.projectCd = @ProjectCd
				and IsReceivable = 0

		   UPDATE b
			   SET IsCalculate = 1
				  ,Amount = (Select sum(Amount) from [MAS_Service_Living_CalSheet] where TrackingId = b.TrackingId) *(1 - (case when @LivingType = 2 then (case  isnull(mp.type_discount_water,0) when 1 then 0.15
							 when 0 then 0 end) else 0 end))
				  ,freeAmt =  (Select sum(isnull(freeAmt,0)) from [MAS_Service_Living_CalSheet] where TrackingId = b.TrackingId)
				  ,DiscountAmt = (Select sum(Amount) from [MAS_Service_Living_CalSheet] where TrackingId = b.TrackingId)*(case when @LivingType = 2 then (case  isnull(mp.type_discount_water,0) when 1 then 0.15 
							 when 0 then 0 end) else 0 end)
			FROM MAS_Service_Living_Tracking b 
				join MAS_Apartment_Service_Living c on b.LivingId = c.LivingId and b.LivingTypeId = 2
				INNER JOIN MAS_Apartments d On c.ApartmentId = d.ApartmentId 
				inner join MAS_Projects mp on b.ProjectCd = mp.projectCd
			WHERE b.LivingTypeId = @LivingType
				and month(b.ToDt) = @PeriodMonth
				and year(b.ToDt) = @PeriodYear
				and d.projectCd = @ProjectCd
				and IsReceivable = 0

		end
	select 1 as valid,N'Tính toán thành công' messages
	end try

	begin catch
		declare	@ErrorNum				int,
				@ErrorMsg				varchar(200),
				@ErrorProc				varchar(50),

				@SessionID				int,
				@AddlInfo				varchar(max)

		set @ErrorNum					= error_number()
		set @ErrorMsg					= 'sp_Hom_Service_Living_Calculate ' + error_message()
		set @ErrorProc					= error_procedure()

		set @AddlInfo					= '@UserID ' + @UserID 

		exec utl_Insert_ErrorLog @ErrorNum, @ErrorMsg, @ErrorProc, 'ServiceLivingCalculate', 'Ins', @SessionID, @AddlInfo
	end catch

	--select * from utl_Error_Log where TableName ='ServiceLivingCalculate'