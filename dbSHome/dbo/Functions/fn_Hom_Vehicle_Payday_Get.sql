--select * from MAS_CardVehicle where ApartmentId = 6120
-- select * from fn_Hom_Vehicle_Payday_Get(10748399,'2021-01-26')
CREATE FUNCTION [dbo].[fn_Hom_Vehicle_Payday_Get] 
(
    -- Add the parameters for the function here
    @CardVehicleId bigint,
	@endDate datetime
)
RETURNS 
@ReturnTable TABLE 
(
	CardVehicleId	bigint not null,
	StartDate		datetime null,
	endDate			datetime null,
	Quantity		decimal(18,2) null,
	Price		decimal(18,0),
	Amount		decimal(18,0),
	VehNum		int,
    Remart		nvarchar(350) NULL 
)
AS
BEGIN
        declare @StartDt datetime
		declare @ToDt datetime
		declare @Price decimal
		declare @VehNum int
		declare @DateCmp datetime
		declare @TotalMonth float
		declare @TotalDay int
		declare @Remart nvarchar(200)
		declare @Quantity float
		declare @Amount decimal
		declare @projectCd nvarchar(31)
		declare @calVehicleType int


	if exists(select cardvehicleid FROM MAS_CardVehicle v 
					WHere v.CardVehicleId = @CardVehicleId and isnull(v.EndTime,v.StartTime) >= @ToDt)
		return
	else
	begin
	    
		set @ToDt = @endDate--convert(datetime,@endDate,103)
		--set @StartDt = convert(datetime,@startDate,103)
		select @StartDt = isnull(v.EndTime,v.StartTime) 
			  ,@VehNum = v.VehicleNum
			  ,@projectCd = isnull(a.projectCd,v.ProjectCd)
			  ,@Remart = N'Gia hạn xe: ' + case when v.isVehicleNone = 1 then v.VehicleName else v.VehicleNo end + N' đến ' + format(@ToDt,'dd/MM/yyyy')
			  ,@calVehicleType = c.caculateVehicleType
		from MAS_CardVehicle v 
				left join MAS_Apartments a on v.ApartmentId = a.ApartmentId
				inner join MAS_Projects c on a.projectCd = c.projectCd
		where v.CardVehicleId = @CardVehicleId

		set @TotalDay = DATEDIFF(D,@StartDt,@ToDt)

		--select * from PAR_ServicePrice where ProjectCd = '03'

		set @Price = (select top 1 case sp.ServiceId when 5 then case when isnull(v.VehicleNum,1) <= 1 then Price else Price2 end when 6 then case when v.VehicleNum < 3 then Price else Price2 end when 7 then Price end
				 from [PAR_ServicePrice] sp 
							join MAS_VehicleTypes c on sp.ServiceId = c.ServiceId 
							Join [MAS_CardVehicle] v on c.VehicleTypeId = v.VehicleTypeId and sp.TypeId = v.[monthlyType] and c.VehicleTypeId = sp.VehicleType
							--join MAS_Apartments a on v.ApartmentId = a.ApartmentId and sp.ProjectCd = a.projectCd
						where  v.CardVehicleId = @cardVehicleId and sp.ProjectCd = @projectCd)

        --initialize spaces
		if @calVehicleType = 0 
				begin
					if @TotalDay <= 31
						begin
							set @TotalDay = DATEDIFF(D,@StartDt,@ToDt)
							set @Quantity = ROUND(convert(float,@TotalDay)/31,2)
							set @Remart = @Remart + N' - thời gian : ' + Convert(nvarchar(10),@TotalDay) + N' ngày'
							set @Amount = ROUND(@TotalDay*@Price/31,0)
						end
					else
						begin
							--set @TotalDay = DATEDIFF(D,dateadd(month,@TotalMonth, @StartDt),@ToDt) --- (@TotalMonth * 31)
							set @Quantity = ROUND(convert(float,@TotalDay/31),2)
							set @TotalMonth = @TotalDay/31
							if ((@TotalDay/31)> 0 and (@TotalDay%31)!= 0)
								begin
									set @Remart = @Remart + N' - thời gian : ' + Convert(nvarchar(10),@TotalMonth) + N' tháng'
								end
							else
								begin
									set @Remart = @Remart + N' - thời gian : ' + Convert(nvarchar(10),@TotalMonth) + N' tháng ' + Convert(nvarchar(10),@TotalDay%31) + N' ngày'
								end
						
							--if @TotalDay < 0 
							--begin
							--	set @TotalDay = DATEDIFF(D,@ToDt,dateadd(month,@TotalMonth, @StartDt))
							--	set @TotalMonth = @TotalMonth - 1
							--end
							--if @TotalDay > 0 
							--	begin
							--		set @Remart = @Remart + N' - thời gian : ' + Convert(nvarchar(10),@TotalMonth) + N' tháng ' + Convert(nvarchar(10),@TotalDay) + N' ngày'
							--	end
							--else
							--	begin
							--		set @Remart = @Remart + N' - thời gian : ' + Convert(nvarchar(10),@TotalMonth) + N' tháng'
							--	end
			
							set @Amount = ROUND(@TotalMonth * @Price + @TotalDay*@Price/31,0)
						end
				end
			else
				begin
					if @TotalDay <= 31
						begin
							set @TotalDay = DATEDIFF(D,@StartDt,@ToDt)
							if @TotalDay <= 15
								begin
									set @Amount = @Price/2
								end
							else
								begin
									set @Amount = @Price
								end
							set @Quantity = ROUND(convert(float,@TotalDay)/31,2)
							set @Remart = @Remart + N' - thời gian : ' + Convert(nvarchar(10),@TotalDay) + N' ngày'
						end
					else
						begin
							set @Quantity = ROUND(convert(float,@TotalDay/31),2)
							set @TotalMonth = @TotalDay/31
							if ((@TotalDay/31)> 0 and (@TotalDay%31)=0)
								begin
								    set @Quantity = @TotalDay/31
									set @Remart = @Remart + N' - thời gian : ' + Convert(nvarchar(10),@TotalMonth) + N' tháng'
								end
							else
								begin
									set @Quantity = convert(float,@TotalDay/31 + (@TotalDay%31)*1.0/31)
									set @Remart = @Remart + N' - thời gian : ' + Convert(nvarchar(10),@TotalMonth) + N' tháng ' + Convert(nvarchar(10),@TotalDay%31) + N' ngày'
								end
							if (@TotalDay/31)> 0 and (@TotalDay%31) <= 15
								begin
									set @Amount = @TotalMonth * @Price + @Price/2
								end
							else
								begin
									set @Amount = @TotalMonth * @Price + @Price
								end
							--set @TotalDay = DATEDIFF(D,dateadd(month,@TotalMonth, @StartDt),@ToDt) --- (@TotalMonth * 31)
							--set @Quantity = ROUND(convert(float,@TotalMonth + @TotalDay/31),2)
				
							--if @TotalDay < 0 
							--begin
							--	set @TotalDay = DATEDIFF(D,dateadd(month,@TotalMonth, @StartDt),@ToDt)
							--	set @TotalMonth = @TotalMonth - 1
							--end
							--if @TotalDay > 0 
							--	begin
							--		set @Remart = @Remart + N' - thời gian : ' + Convert(nvarchar(10),@TotalMonth) + N' tháng ' + Convert(nvarchar(10),@TotalDay) + N' ngày'
							--	end
							--else
							--	begin
							--		set @Remart = @Remart + N' - thời gian : ' + Convert(nvarchar(10),@TotalMonth) + N' tháng'
							--	end
			    --            if @TotalDay <= 15
							--	begin
							--		set @Amount = @TotalMonth * @Price + @Price/2
							--	end
							--else
							--	begin
							--		set @Amount = @TotalMonth * @Price + @Price
							--	end
							
						end
				end
        


            Insert Into @ReturnTable
            Select @CardVehicleId
				  ,@StartDt
				  ,@ToDt
				  ,@Quantity
				  ,@Price
				  ,@Amount
				  ,@VehNum
				  ,@Remart
		--RETURN 
	end
	RETURN
END