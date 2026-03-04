-- =============================================
-- Author:  <Author,,Name>
-- Create date: <Create Date,,>
-- Description: <Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[sp_spk_tracks_shift]
	@userId nvarchar(100),
	@ProjectCd nvarchar(30),
	@monthly int,
	@vehicleType  int ,
	@status      int ,
	@vehilceNo nvarchar(20),
	@cardCd    nvarchar(20) ,
	
	@timeInOut int,
	@shift    int ,
	@startDate     nvarchar(50),
	@endDate nvarchar(50) = NULL,
	@Filter nvarchar(50) = NULL,
	@Offset				int				= 0,
	@PageSize			int				= 10,
	@Total				int out,
	@TotalFiltered		int out,
	@TotalAmount		int out,
	@GridKey			nvarchar(100) out,
	@AcceptLanguage nvarchar(50) = 'vi'
AS
BEGIN

	declare @dSartDate datetime
	declare @dEndDate datetime

	declare @ds_SartDate datetime
	declare @ds_EndDate datetime
	declare @de_SartDate datetime
	declare @de_EndDate datetime

	declare @tbMonthly TABLE(id [Int] null)
	declare @tbVehicletype TABLE(id [Int] null)
	declare @tbstatus TABLE(id [Int] null)
	declare @tbShift TABLE(id [Int] null)
	declare @IsPriceFirst bit
	set @IsPriceFirst = isnull((select top 1 Value from SPK_Variable where Name like 'PriceFirst'), 0);
	SET @Filter = ISNULL(@Filter, '');
		
	set	@gridKey	= 'view_spk_tracks_shift'
	if @Offset = 0
		select * from [dbo].fn_config_list_gets (@gridKey, 0) order by [ordinal]

	SET @Offset = isnull(@Offset, 0)
	SET @PageSize = isnull(@PageSize, 10)
	SET @Total = isnull(@Total, 0)
		
	if @PageSize = 0
		set @PageSize = 10
	if @Offset < 0
		set @Offset	=  0

	set @vehilceNo = isnull(@vehilceNo,'')
	set @cardCd = isnull(@cardCd,'')

	if @monthly is null or @monthly = -1
		insert into @tbMonthly (Id) select 0 union select 1 
	else
		insert into @tbMonthly (Id) select @monthly

	if @vehicleType is null or @vehicleType = -1
		insert into @tbVehicletype (Id) select 1 union select 2 union select 3 
	else
		insert into @tbVehicletype (Id) select @vehicleType

	if @status is null or @status = -1
		insert into @tbstatus (Id) select 0 union select 1 
	else
		insert into @tbstatus (Id) select @status

	if @shift is null or @shift = -1
		insert into @tbShift (Id) select 1 union select 2 
	else
		insert into @tbShift (Id) select @shift

	  
	set @dSartDate = convert(datetime, @startDate, 103)
	set @dEndDate = convert(datetime, @endDate, 103)
	IF(@dSartDate IS NULL AND @dEndDate IS NULL)
	BEGIN
		SET @dEndDate = GETDATE();
		SET @dSartDate = DATEADD(day, -1, @dEndDate);
	END
	ELSE IF(@dSartDate IS NULL)
		SET @dSartDate = DATEADD(day, -1, @dEndDate);
	ELSE IF(@dEndDate IS NULL)
		SET @dEndDate = DATEADD(day, 1, @dEndDate);

	if @dSartDate <= convert(datetime,'31/07/2018',103)
	set @IsPriceFirst = 1
		
	--set @dEndDate = DATEADD(day,1,@dSartDate)

	if @shift is null or @shift = -1
		insert into @tbShift (Id) select 1 union select 2 
	else
		insert into @tbShift (Id) select @shift
			

	set @ds_SartDate = DATEADD(hour, 6, @dSartDate)
	set @ds_endDate = DATEADD(hour, 20, @dSartDate)

	set @de_SartDate = DATEADD(hour,18,@dEndDate)
	set @de_endDate = DATEADD(day,1,DATEADD(hour,6,@dEndDate))

	IF @IsPriceFirst = 0 
		BEGIN
			SELECT
				@Total = count(a.TrackId),
				@TotalAmount = isnull(sum(isnull(case when [DateIn] < convert(datetime,'01/08/2018',103) 
					and (trackid in (70947,68272,64862,68808,54160,85386)) then 0 else a.Amount end,0)),0)
			FROM viewTracks a 
			where DailyType in (select id from @tbMonthly)
				and VehicleType in (select id from @tbVehicletype)
				and [Status] in (select id from @tbstatus)
				AND (
						(@status < 0
							AND ((@dSartDate <= a.DateIn AND a.DateIn <= @dEndDate)
							OR (@dSartDate <= a.DateOut AND a.DateOut <= @dEndDate))
						)
						-- Chỉ lấy xe đang trong bãi (lọc theo DateIn trong range)
						OR (@status = 0 AND a.DateIn BETWEEN @dSartDate AND @dEndDate)
						-- Chỉ lấy xe đã ra (lọc theo DateOut trong range)
						OR (@status = 1 AND a.DateOut BETWEEN @dSartDate AND @dEndDate)
					)
				--and InLPRText like '%' + @vehilceNo +'%'
				AND (TRIM(@Filter) = '' OR (VehicleNo LIKE N'%'+ @Filter +'%' OR CardCd LIKE N'%'+ @Filter +'%' OR TicketNo LIKE N'%'+ @Filter +'%'))
				and exists( select b.ShiftId
							FROM
								SPK_ShiftLog b
								inner join SPK_ShiftLineOut c on b.ShiftId = c.ShiftId 
							WHERE
								(b.ShiftId = a.ShiftOut) 
								AND (
										(@status < 0 AND (b.ShiftId = a.ShiftIn OR b.ShiftId = a.ShiftOut))
										OR (@status = 0 AND b.ShiftId = a.ShiftIn)
										OR (@status = 1 AND b.ShiftId = a.ShiftOut)
									)
								--and b.ShiftDt = @dSartDate
								and b.ShiftNo in (select Id from @tbShift))
			
			set	@TotalFiltered = @Total

			if @PageSize < 0
				set	@PageSize = 10

			SELECT
				a.[TrackId]
				,a.[TicketNo]
				,a.DateIn
				,a.DateOut
				,a.[CardCd]
				,a.[VehicleTypeName]
				,a.[DailyTypeName]
				,convert(nvarchar(10),a.[DateIn],103) + ' ' + convert(nvarchar(10),a.[DateIn],108) as [DatetimeIn]
				,convert(nvarchar(10),a.[DateOut],103) + ' ' + convert(nvarchar(10),a.[DateOut],108) as [DatetimeOut]
				,[InLPRSnapshoot_ICloud] as [InLPRSnapshoot]
				,[InOVLSnapshoot_ICloud] as [InOVLSnapshoot]
				,[InLPRImage_ICloud]  as [InLPRImage]
				,a.[InLPRText]
				,[OutLPRSnapshoot_ICloud] as [OutLPRSnapshoot]
				,[OutOVLSnapshoot_ICloud] as [OutOVLSnapshoot]
				,[OutLPRImage_ICloud]  as [OutLPRImage]
				,a.[OutLPRText]
				,a.[StatusName]
				,a.[Status]
				,a.[Amount]
				,a.[FullName]
				,a.[RoomCode]
				,a.[VehicleName]
				,a.[VehicleNo]
				,'Ca ' + cast(a.[Shift1] as varchar) as InShift
				,'Ca ' + cast(a.[Shift2] as varchar) as OutShift
			--INTO #SPK_Trackings
			from
				(SELECT
					e.TrackId, e.GateIn, e.GateOut, e.TicketNo, e.CardId, aa.CardCd, b.Card_Num AS Card_Code, e.VehicleType, 
					CASE e.[VehicleType] WHEN 1 THEN N'Ô tô' WHEN 2 THEN N'Xe máy' ELSE N'Xe đạp' END AS VehicleTypeName, e.DailyType,
					case when e.DailyType = 1 then N'Vé lượt' else N'Vé tháng' end as DailyTypeName, e.DateIn, e.DateOut, 
					e.[InLPRSnapshoot_ICloud], e.[InOVLSnapshoot_ICloud], e.[InLPRImage_ICloud], e.InLPRText, 
					e.[OutLPRSnapshoot_ICloud], e.[OutOVLSnapshoot_ICloud], e.[OutLPRImage_ICloud], e.OutLPRText, 
					e.ClientId, e.Status,
					case when e.Status = 1 then N'Đã ra' else N'Đang trong bãi' end as StatusName,
					Amount = CASE
								WHEN @timeInOut = 0 AND [DateIn] < convert(datetime,'01/08/2018',103) and (trackid in (70947,68272,64862,68808,54160)) then 0
								WHEN @timeInOut = 1 AND [DateIn] < convert(datetime,'01/08/2018',103) and (trackid in (70947,68272,64862,68808,54160,85386)) then 0
								ELSE e.Amount
							 END,
					d.FullName, c.RoomCode, f.VehicleName
					,f.VehicleColor, f.VehicleNo
					,[Shift1]
					,[Shift2]
					,ShiftIn
					,ShiftOut
					,e.isVehicleNone
				FROM
					dbo.SPK_Trackings AS e 
					left JOIN dbo.MAS_Cards AS aa ON aa.CardId = e.CardId 
					left JOIN dbo.MAS_CardBase AS b ON aa.CardCd = b.Code 
					LEFT JOIN dbo.MAS_Apartments AS c ON aa.ApartmentId = c.ApartmentId 
					LEFT JOIN dbo.MAS_Customers AS d ON aa.CustId = d.CustId 
					LEFT JOIN dbo.MAS_CardVehicle AS f ON f.CardId = aa.CardId and e.VehicleType = f.VehicleTypeId
				) a
			where 
				DailyType in (select id from @tbMonthly)
				and VehicleType in (select id from @tbVehicletype)
				and [Status] in (select id from @tbstatus)
				--and InLPRText like '%' + @vehilceNo +'%'
				AND (TRIM(@Filter) = '' OR (VehicleNo LIKE N'%'+ @Filter +'%' OR CardCd LIKE N'%'+ @Filter +'%' OR TicketNo LIKE N'%'+ @Filter +'%'))
				AND (
						(@status < 0
							AND ((@dSartDate <= a.DateIn AND a.DateIn <= @dEndDate)
							OR (@dSartDate <= a.DateOut AND a.DateOut <= @dEndDate))
						)
						-- Chỉ lấy xe đang trong bãi (lọc theo DateIn trong range)
						OR (@status = 0 AND a.DateIn BETWEEN @dSartDate AND @dEndDate)
						-- Chỉ lấy xe đã ra (lọc theo DateOut trong range)
						OR (@status = 1 AND a.DateOut BETWEEN @dSartDate AND @dEndDate)
					)
				--and CardCd like '%' + @cardCd +'%'
				AND exists( select b.ShiftId
							FROM
								SPK_ShiftLog b
								inner join SPK_ShiftLineOut c on b.ShiftId = c.ShiftId
							WHERE
								(
									(@status < 0 AND (b.ShiftId = a.ShiftIn OR b.ShiftId = a.ShiftOut))
									OR (@status = 0 AND b.ShiftId = a.ShiftIn)
									OR (@status = 1 AND b.ShiftId = a.ShiftOut)
								)
								--and b.ShiftDt = @dSartDate
								--AND (b.ShiftDt BETWEEN @dSartDate AND @dEndDate)
								--AND (b.ShiftDt >= @dSartDate AND @dEndDate <= b.ShiftDt)
								and b.ShiftNo in (select Id from @tbShift))
			ORDER BY DateIn DESC
			offset @Offset rows
			fetch next @PageSize rows ONLY
		END
	ELSE
		BEGIN
			IF @timeInOut = 0
				BEGIN
					SELECT
						@Total = count(a.TrackId),
						@TotalAmount = isnull(sum(isnull(a.Amount,0)),0)
					FROM viewTracks a 
					where DailyType in (select id from @tbMonthly)
						and VehicleType in (select id from @tbVehicletype)
						and [Status] in (select id from @tbstatus)
						and InLPRText like '%' + @vehilceNo +'%'
						and exists( select b.ShiftId from SPK_ShiftLog b 
							where (b.ShiftId = a.ShiftIn) 
							and b.ShiftDt = @dSartDate and b.ShiftNo in (select Id from @tbShift))
					
					set	@TotalFiltered = @Total

					if @PageSize < 0
						set	@PageSize = 10

					SELECT
						a.[TrackId]
						,a.[TicketNo]
						,a.[CardCd]
						,a.[VehicleTypeName]
						,a.[DailyTypeName]
						,convert(nvarchar(10),a.[DateIn],103) + ' ' + convert(nvarchar(10),a.[DateIn],108) as [DatetimeIn]
						,convert(nvarchar(10),a.[DateOut],103) + ' ' + convert(nvarchar(10),a.[DateOut],108) as [DatetimeOut]
						--,[dbo].[convertLocalToUrl](a.[InLPRSnapshoot]) as [InLPRSnapshoot]
						--,[dbo].[convertLocalToUrl](a.[InOVLSnapshoot]) as [InOVLSnapshoot]
						--,[dbo].[convertLocalToUrl](a.[InLPRImage]) as [InLPRImage]
						,[InLPRSnapshoot_ICloud] as [InLPRSnapshoot]
						,[InOVLSnapshoot_ICloud] as [InOVLSnapshoot]
						,[InLPRImage_ICloud]  as [InLPRImage]
						,a.[InLPRText]
						--,[dbo].[convertLocalToUrl](a.[OutLPRSnapshoot]) as [OutLPRSnapshoot]
						--,[dbo].[convertLocalToUrl](a.[OutOVLSnapshoot]) as [OutOVLSnapshoot]
						--,[dbo].[convertLocalToUrl](a.[OutLPRImage]) as [OutLPRImage]
						,[OutLPRSnapshoot_ICloud] as [OutLPRSnapshoot]
						,[OutOVLSnapshoot_ICloud] as [OutOVLSnapshoot]
						,[OutLPRImage_ICloud]  as [OutLPRImage]
						,a.[OutLPRText]
						,a.[StatusName]
						,a.[Status]
						--,a.[IsFree]
						--,a.[Price]
						,a.[Amount]
						--,a.[Lane]
						,a.[FullName]
						,a.[RoomCode]
						,a.[VehicleName]
						--,a.[VehicleColor]
						,a.[VehicleNo]
						,'Ca ' + cast(a.[Shift1] as varchar) as InShift
						,'Ca ' + cast(a.[Shift2] as varchar) as OutShift 
						--,case when a.[Status] = 1 then [dbo].[fn_getTotalTime] (a.[DateIn],a.[DateOut]) else '' end as TotalTime
					from --viewTracks 
					(
						SELECT      e.TrackId, e.GateIn, e.GateOut, e.TicketNo, e.CardId, aa.CardCd, b.Card_Num AS Card_Code, e.VehicleType, 
						CASE e.[VehicleType] WHEN 1 THEN N'Ô tô' WHEN 2 THEN N'Xe máy' ELSE N'Xe đạp' END AS VehicleTypeName, e.DailyType,
						case when e.DailyType = 1 then N'Vé lượt' else N'Vé tháng' end as DailyTypeName, e.DateIn, e.DateOut, 
						e.[InLPRSnapshoot_ICloud], e.[InOVLSnapshoot_ICloud], e.[InLPRImage_ICloud], e.InLPRText, 
						e.[OutLPRSnapshoot_ICloud], e.[OutOVLSnapshoot_ICloud], e.[OutLPRImage_ICloud], e.OutLPRText, 
						e.ClientId, e.Status,
						case when e.Status = 1 then N'Đã ra' else N'Đang trong bãi' end as StatusName,
						--e.IsFree, 
						--e.Price, 
						e.Amount, 
						--e.Lane, c.Cif_No, aa.VehicleTypeId,
						d.FullName, c.RoomCode, f.VehicleName
						,f.VehicleColor, f.VehicleNo
					   ,[Shift1]
					   ,[Shift2]
					   ,ShiftIn
					   ,ShiftOut
					   ,e.isVehicleNone
					   --,case when e.[Status] = 1 then [dbo].[fn_getTotalTime] (e.[DateIn],e.[DateOut]) else '' end as TotalTime
					FROM
						dbo.SPK_Trackings AS e 
						left JOIN dbo.MAS_Cards AS aa ON aa.CardId = e.CardId 
						left JOIN dbo.MAS_CardBase AS b ON aa.CardCd = b.Code 
						LEFT JOIN dbo.MAS_Apartments AS c ON aa.ApartmentId = c.ApartmentId 
								--MAS_Contacts h on c.Cif_No = h.Cif_No LEFT OUTER JOIN
						LEFT JOIN dbo.MAS_Customers AS d ON aa.CustId = d.CustId 
						LEFT JOIN dbo.MAS_CardVehicle AS f ON f.CardId = aa.CardId and e.VehicleType = f.VehicleTypeId
					) a
					where 
					DailyType in (select id from @tbMonthly)
						and VehicleType in (select id from @tbVehicletype)
						and [Status] in (select id from @tbstatus)
						and InLPRText like '%' + @vehilceNo +'%'
						--and CardCd like '%' + @cardCd +'%'
						and 
						exists( select b.ShiftId from SPK_ShiftLog b 
							where (b.ShiftId = a.ShiftIn) 
							and b.ShiftDt = @dSartDate and b.ShiftNo in (select Id from @tbShift))
					ORDER BY DateIn DESC
					  offset @Offset rows	
						fetch next @PageSize rows only
				END
			ELSE
				BEGIN
					SELECT
						@Total = count(a.TrackId),
						@TotalAmount = isnull(sum(isnull(a.Amount,0)),0)
					FROM viewTracks a 
					where DailyType in (select id from @tbMonthly)
						and VehicleType in (select id from @tbVehicletype)
						--and [Status] in (select id from @tbstatus)
						and InLPRText like '%' + @vehilceNo +'%'
						and exists( select b.ShiftId from SPK_ShiftLog b 
							where (b.ShiftId = a.ShiftOut) 
							and b.ShiftDt = @dSartDate and b.ShiftNo in (select Id from @tbShift))

					set	@TotalFiltered = @Total

					if @PageSize < 0
						set	@PageSize = 10

					SELECT
						a.[TrackId]
						,a.[TicketNo]
						,a.[CardCd]
						,a.[VehicleTypeName]
						,a.[DailyTypeName]
						,convert(nvarchar(10),a.[DateIn],103) + ' ' + convert(nvarchar(10),a.[DateIn],108) as [DatetimeIn]
						,convert(nvarchar(10),a.[DateOut],103) + ' ' + convert(nvarchar(10),a.[DateOut],108) as [DatetimeOut]
						--,[dbo].[convertLocalToUrl](a.[InLPRSnapshoot]) as [InLPRSnapshoot]
						--,[dbo].[convertLocalToUrl](a.[InOVLSnapshoot]) as [InOVLSnapshoot]
						--,[dbo].[convertLocalToUrl](a.[InLPRImage]) as [InLPRImage]
						,[InLPRSnapshoot_ICloud] as [InLPRSnapshoot]
						,[InOVLSnapshoot_ICloud] as [InOVLSnapshoot]
						,[InLPRImage_ICloud]  as [InLPRImage]
						,a.[InLPRText]
						--,[dbo].[convertLocalToUrl](a.[OutLPRSnapshoot]) as [OutLPRSnapshoot]
						--,[dbo].[convertLocalToUrl](a.[OutOVLSnapshoot]) as [OutOVLSnapshoot]
						--,[dbo].[convertLocalToUrl](a.[OutLPRImage]) as [OutLPRImage]
						,[OutLPRSnapshoot_ICloud] as [OutLPRSnapshoot]
						,[OutOVLSnapshoot_ICloud] as [OutOVLSnapshoot]
						,[OutLPRImage_ICloud]  as [OutLPRImage]
						,a.[OutLPRText]
						,a.[StatusName]
						,a.[Status]
						--,a.[IsFree]
						--,a.[Price]
						,a.[Amount]
						--,a.[Lane]
						,a.[FullName]
						,a.[RoomCode]
						,a.[VehicleName]
						--,a.[VehicleColor]
						,a.[VehicleNo]
						,'Ca ' + cast(a.[Shift1] as varchar) as InShift
						,'Ca ' + cast(a.[Shift2] as varchar) as OutShift 
						--,case when a.[Status] = 1 then [dbo].[fn_getTotalTime] (a.[DateIn],a.[DateOut]) else '' end as TotalTime
					from --viewTracks 
						(
							SELECT
								e.TrackId, e.GateIn, e.GateOut, e.TicketNo, e.CardId, aa.CardCd, b.Card_Num AS Card_Code, e.VehicleType, 
								CASE e.[VehicleType] WHEN 1 THEN N'Ô tô' WHEN 2 THEN N'Xe máy' ELSE N'Xe đạp' END AS VehicleTypeName, e.DailyType,
								case when e.DailyType = 1 then N'Vé lượt' else N'Vé tháng' end as DailyTypeName, e.DateIn, e.DateOut, 
								e.[InLPRSnapshoot_ICloud], e.[InOVLSnapshoot_ICloud], e.[InLPRImage_ICloud], e.InLPRText, 
								e.[OutLPRSnapshoot_ICloud], e.[OutOVLSnapshoot_ICloud], e.[OutLPRImage_ICloud], e.OutLPRText, 
								e.ClientId, e.Status,
								case when e.Status = 1 then N'Đã ra' else N'Đang trong bãi' end as StatusName,
								--e.IsFree, 
								e.Price, 
								e.Amount, 
								--e.Lane, c.Cif_No, aa.VehicleTypeId,
								d.FullName, c.RoomCode, f.VehicleName
								,f.VehicleColor, f.VehicleNo
								,[Shift1]
								,[Shift2]
								,ShiftIn
								,ShiftOut
								,e.isVehicleNone
								--,case when e.[Status] = 1 then [dbo].[fn_getTotalTime] (e.[DateIn],e.[DateOut]) else '' end as TotalTime
							FROM
								dbo.SPK_Trackings AS e 
								left JOIN dbo.MAS_Cards AS aa ON aa.CardId = e.CardId 
								left JOIN dbo.MAS_CardBase AS b ON aa.CardCd = b.Code 
								LEFT JOIN dbo.MAS_Apartments AS c ON aa.ApartmentId = c.ApartmentId 
										--MAS_Contacts h on c.Cif_No = h.Cif_No LEFT OUTER JOIN
								LEFT JOIN dbo.MAS_Customers AS d ON aa.CustId = d.CustId 
								LEFT JOIN dbo.MAS_CardVehicle AS f ON f.CardId = aa.CardId and e.VehicleType = f.VehicleTypeId
						) a
					where 
					DailyType in (select id from @tbMonthly)
						and VehicleType in (select id from @tbVehicletype)
						--and [Status] in (select id from @tbstatus)
						and InLPRText like '%' + @vehilceNo +'%'
						--and CardCd like '%' + @cardCd +'%'
						and 
						exists( select b.ShiftId from SPK_ShiftLog b 
							where (b.ShiftId = a.ShiftOut) 
							and b.ShiftDt = @dSartDate and b.ShiftNo in (select Id from @tbShift))
					ORDER BY DateIn DESC
					  offset @Offset rows	
						fetch next @PageSize rows only
				END
		END
END