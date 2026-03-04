
CREATE procedure [dbo].[sp_Hom_Get_Service_Receivables_Search]
	@UserID	nvarchar(450),
	@ProjectCd nvarchar(10),
	@Status bit,
	@FromDt nvarchar(50) = null,
	@ToDt nvarchar(50) = null
as
	begin try	
	declare @StartDt datetime
	declare @EndDt datetime
	
	set @StartDt = convert(datetime,isnull(@FromDt,'2018-01-01'),103)
	set @EndDt = convert(datetime,isnull(@ToDt,'2050-01-01'),103)
			-------Common Fee----------
			select sum(isnull(e.CommonFee,0)) as TotalCommonAmt,
				   sum(case when e.IsPayed = 1 then CommonFee else 0 end) as TotalCommonPayed,
				   sum(case when e.IsPayed = 0 then CommonFee else 0 end) as TotalCommonNotPayed
			from MAS_Service_ReceiveEntry e
				join MAS_Apartments b on e.ApartmentId = b.ApartmentId
				join MAS_Rooms a on a.RoomCode = b.RoomCode 
				join MAS_Buildings c on a.BuildingCd = c.BuildingCd 
			where (@ProjectCd is null or c.ProjectCd like @ProjectCd + '%')
					and e.ReceiveDt between @StartDt and @EndDt
			-------Vehicle Fee----------
			select sum(isnull(e.VehicleAmt,0)) as TotalVehicelAmt,
				   sum(case when e.IsPayed = 1 then VehicleAmt else 0 end) as TotalVehicelPayed,
				   sum(case when e.IsPayed = 0 then VehicleAmt else 0 end) as TotalVehicelNotPayed
			from MAS_Service_ReceiveEntry e
				join MAS_Apartments b on e.ApartmentId = b.ApartmentId
				join MAS_Rooms a on a.RoomCode = b.RoomCode 
				join MAS_Buildings c on a.BuildingCd = c.BuildingCd 
			where (@ProjectCd is null or c.ProjectCd like @ProjectCd + '%')
					and e.ReceiveDt between @StartDt and @EndDt
			-------Living Fee----------
			select sum(isnull(e.LivingAmt,0)) as TotalLivingAmt,
				   sum(case when e.IsPayed = 1 then LivingAmt else 0 end) as TotalLivingPayed,
				   sum(case when e.IsPayed = 0 then LivingAmt else 0 end) as TotalLivingNotPayed
			from MAS_Service_ReceiveEntry e
				join MAS_Apartments b on e.ApartmentId = b.ApartmentId
				join MAS_Rooms a on a.RoomCode = b.RoomCode 
				join MAS_Buildings c on a.BuildingCd = c.BuildingCd 
			where (@ProjectCd is null or c.ProjectCd like @ProjectCd + '%')
					and e.ReceiveDt between @StartDt and @EndDt
		    -------Details----------

			select e.[ReceiveId]
				  ,e.[ApartmentId]
				  ,e.[ReceiveDt] as ReceiveDate
				  ,convert(nvarchar(10),e.[ToDt],103) as toDate
				  ,e.TotalAmt
				  ,convert(nvarchar(10),e.[ExpireDate],103) as [ExpireDate]
				  ,e.[IsPayed]
				  ,e.PaidAmt
				  ,convert(nvarchar(10),e.PayedDt,103) as PayedDate
				  ,b.RoomCode
				  ,d.FullName
				  ,b.WaterwayArea
				  ,e.IsBill
				  ,e.BillUrl
				  ,(select top 1 [ReceiptNo]
						  from MAS_Service_Receipts mr
						  where mr.ReceiveId = e.ReceiveId) as ReceiptNos
				  ,(select top 1 TranferCd
						  from MAS_Service_Receipts mr
						  where mr.ReceiveId = e.ReceiveId) as TranferCds
			  from MAS_Service_ReceiveEntry e
				join MAS_Apartments b on e.ApartmentId = b.ApartmentId
				join MAS_Rooms a on a.RoomCode = b.RoomCode 
				join MAS_Buildings c on a.BuildingCd = c.BuildingCd 
				join UserInfo u on b.UserLogin = u.loginName
				join MAS_Customers d on u.CustId = d.CustId
			  where (@ProjectCd is null or c.ProjectCd like @ProjectCd + '%')
					and e.ReceiveDt between @StartDt and @EndDt
			  order by  e.[ReceiveDt] desc, b.RoomCode
	end try
	begin catch
		declare	@ErrorNum				int,
				@ErrorMsg				varchar(200),
				@ErrorProc				varchar(50),

				@SessionID				int,
				@AddlInfo				varchar(max)

		set @ErrorNum					= error_number()
		set @ErrorMsg					= 'sp_Hom_Get_Service_Expectables ' + error_message()
		set @ErrorProc					= error_procedure()

		set @AddlInfo					= '@UserID ' + @UserID 

		exec utl_Insert_ErrorLog @ErrorNum, @ErrorMsg, @ErrorProc, 'Expectables', 'Get', @SessionID, @AddlInfo
	end catch