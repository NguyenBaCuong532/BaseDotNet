



-- exec sp_Hom_Service_Living_Calculate null,0,'03',2,10,2020

create procedure [dbo].[sp_Hom_Service_Living_Calculate_cu]
	
	@UserID	nvarchar(450),
	@TrackingId int,
	@ProjectCd nvarchar(30),
	@LivingType int,
	@PeriodMonth int,
	@PeriodYear int

as
	begin try		
	
	if @TrackingId > 0
	begin
		UPDATE t
		   SET [Quantity] = (case when b.TotalNum > a.[NumFrom] then case when a.[NumTo] is null or b.TotalNum <= a.[NumTo] then b.TotalNum - a.NumFrom else a.NumTo - a.[NumFrom] end else 0 end)
			  ,[Price] = a.Price
			  ,[Amount] = (case when b.TotalNum > a.[NumFrom] then case when a.[NumTo] is null or b.TotalNum <= a.[NumTo] then b.TotalNum - a.NumFrom else a.NumTo - a.[NumFrom] end else 0 end)*a.[Price]
						--- isnull(a.free_rt,0)*(case when b.TotalNum > a.[NumFrom] then case when a.[NumTo] is null or b.TotalNum <= a.[NumTo] then b.TotalNum - a.NumFrom else a.NumTo - a.[NumFrom] end else 0 end)*a.[Price]
			  ,FreeAmt = isnull(a.free_rt,0)*(case when b.TotalNum > a.[NumFrom] then case when a.[NumTo] is null or b.TotalNum <= a.[NumTo] then b.TotalNum - a.NumFrom else a.NumTo - a.[NumFrom] end else 0 end)*a.[Price]
		 FROM [MAS_Service_Living_CalSheet] t
			join [PAR_ServiceLivingPrice] a on t.StepPos = a.Pos
			join MAS_Service_Living_Tracking b on t.TrackingId = b.TrackingId and a.ProjectCd = b.ProjectCd and a.LivingTypeId = b.LivingTypeId
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
			SELECT @TrackingId
				  ,[Pos]
				  ,[NumFrom]
				  ,[NumTo]
				  ,(case when b.TotalNum > a.[NumFrom] then case when a.[NumTo] is null or b.TotalNum <= a.[NumTo] then b.TotalNum - a.NumFrom else a.NumTo - a.[NumFrom] end else 0 end) as [Quantity]
				  ,[Price]
				  ,(case when b.TotalNum > a.[NumFrom] then case when a.[NumTo] is null or b.TotalNum <= a.[NumTo] then b.TotalNum - a.NumFrom else a.NumTo - a.[NumFrom] end else 0 end)*[Price] 
					--- isnull(a.free_rt,0)*(case when b.TotalNum > a.[NumFrom] then case when a.[NumTo] is null or b.TotalNum <= a.[NumTo] then b.TotalNum - a.NumFrom else a.NumTo - a.[NumFrom] end else 0 end)*[Price] as [Amount]
				  ,isnull(a.free_rt,0)*(case when b.TotalNum > a.[NumFrom] then case when a.[NumTo] is null or b.TotalNum <= a.[NumTo] then b.TotalNum - a.NumFrom else a.NumTo - a.[NumFrom] end else 0 end)*[Price] as FreeAmt
			  FROM MAS_Service_Living_Tracking b
				join MAS_Apartments c on b.ApartmentId = c.ApartmentId 
				join [PAR_ServiceLivingPrice] a on a.LivingTypeId = b.LivingTypeId and a.ProjectCd = c.ProjectCd 
			  where b.TrackingId = @TrackingId
				and IsReceivable = 0
				and not exists(select Id from [MAS_Service_Living_CalSheet] where TrackingId = @TrackingId and StepPos = a.Pos) 
			order by Pos
	
	
			UPDATE b
			   SET IsCalculate = 1
				  ,Amount = (Select sum(Amount) from [MAS_Service_Living_CalSheet] where TrackingId = b.TrackingId)
				  ,freeAmt =  (Select sum(isnull(freeAmt,0)) from [MAS_Service_Living_CalSheet] where TrackingId = b.TrackingId)
			FROM MAS_Service_Living_Tracking b 
				join MAS_Apartment_Service_Living c on b.LivingId = c.LivingId
				INNER JOIN MAS_Apartments d On c.ApartmentId = d.ApartmentId 
			WHERE b.TrackingId = @TrackingId
				and IsReceivable = 0
		end
		else
		begin

			UPDATE t
		   SET [Quantity] = (case when b.TotalNum > a.[NumFrom] then case when a.[NumTo] is null or b.TotalNum <= a.[NumTo] then b.TotalNum - a.NumFrom else a.NumTo - a.[NumFrom] end else 0 end)
			  ,[Price] = a.Price
			  ,[Amount] = (case when b.TotalNum > a.[NumFrom] then case when a.[NumTo] is null or b.TotalNum <= a.[NumTo] then b.TotalNum - a.NumFrom else a.NumTo - a.[NumFrom] end else 0 end)*a.[Price]
					--- isnull(a.free_rt,0)*(case when b.TotalNum > a.[NumFrom] then case when a.[NumTo] is null or b.TotalNum <= a.[NumTo] then b.TotalNum - a.NumFrom else a.NumTo - a.[NumFrom] end else 0 end)*a.[Price]
			  ,FreeAmt = isnull(a.free_rt,0)*(case when b.TotalNum > a.[NumFrom] then case when a.[NumTo] is null or b.TotalNum <= a.[NumTo] then b.TotalNum - a.NumFrom else a.NumTo - a.[NumFrom] end else 0 end)*a.[Price]
		 FROM MAS_Service_Living_Tracking b
			join MAS_Apartments c on b.ApartmentId = c.ApartmentId 
			join [MAS_Service_Living_CalSheet] t on t.TrackingId = b.TrackingId 
			join [PAR_ServiceLivingPrice] a on t.StepPos = a.Pos and a.ProjectCd = b.ProjectCd and a.LivingTypeId = b.LivingTypeId
			where b.LivingTypeId = @LivingType
				and month(b.ToDt) = @PeriodMonth
				and year(b.ToDt) = @PeriodYear
				and IsReceivable = 0
				--and c.projectCd = @ProjectCd

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
			SELECT b.TrackingId
				  ,[Pos]
				  ,[NumFrom]
				  ,[NumTo]
				  ,(case when b.TotalNum > a.[NumFrom] then case when a.[NumTo] is null or b.TotalNum <= a.[NumTo] then b.TotalNum - a.NumFrom else a.NumTo - a.[NumFrom] end else 0 end) as [Quantity]
				  ,[Price]
				  ,(case when b.TotalNum > a.[NumFrom] then case when a.[NumTo] is null or b.TotalNum <= a.[NumTo] then b.TotalNum - a.NumFrom else a.NumTo - a.[NumFrom] end else 0 end)*[Price] 
					--- isnull(a.free_rt,0)*(case when b.TotalNum > a.[NumFrom] then case when a.[NumTo] is null or b.TotalNum <= a.[NumTo] then b.TotalNum - a.NumFrom else a.NumTo - a.[NumFrom] end else 0 end)*[Price] as [Amount]
				  ,isnull(a.free_rt,0)*(case when b.TotalNum > a.[NumFrom] then case when a.[NumTo] is null or b.TotalNum <= a.[NumTo] then b.TotalNum - a.NumFrom else a.NumTo - a.[NumFrom] end else 0 end)*[Price] as FreeAmt
			  FROM MAS_Service_Living_Tracking b
				join MAS_Apartments c on b.ApartmentId = c.ApartmentId 
				join [PAR_ServiceLivingPrice] a on a.LivingTypeId = b.LivingTypeId and a.ProjectCd = c.ProjectCd 
			  where b.LivingTypeId = @LivingType
				and month(b.ToDt) = @PeriodMonth
				and year(b.ToDt) = @PeriodYear
				and IsReceivable = 0
				--and c.projectCd = @ProjectCd
				and not exists(select Id from [MAS_Service_Living_CalSheet] where TrackingId = b.TrackingId and StepPos = a.Pos) 
			order by b.TrackingId, Pos
	
	
			UPDATE b
			   SET IsCalculate = 1
				  ,Amount = (Select sum(Amount) from [MAS_Service_Living_CalSheet] where TrackingId = b.TrackingId)
				  ,freeAmt =  (Select sum(isnull(freeAmt,0)) from [MAS_Service_Living_CalSheet] where TrackingId = b.TrackingId)
			FROM MAS_Service_Living_Tracking b 
				join MAS_Apartment_Service_Living c on b.LivingId = c.LivingId
				INNER JOIN MAS_Apartments d On c.ApartmentId = d.ApartmentId 
			WHERE b.LivingTypeId = @LivingType
				and month(b.ToDt) = @PeriodMonth
				and year(b.ToDt) = @PeriodYear
				--and d.projectCd = @ProjectCd
				and IsReceivable = 0

		end
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