
CREATE procedure [dbo].[sp_Hom_Service_Receivable_Report_ByRoomCode]
	@userId	nvarchar(450),
	@roomCode nvarchar(100),
	@toDate Datetime
as
	begin try

		--1
		SELECT TOP 1 e.[ReceiveId]
					,e.[ApartmentId]
					,e.[ReceiveDt] as receiveDate
					--,convert(nvarchar(10),e.[FromDt],103) as fromDate
					,convert(nvarchar(10),e.[ToDt],103) as toDate
					,e.TotalAmt
					,convert(nvarchar(10),e.[ExpireDate],103) as [ExpireDate]
					,e.[IsPayed]
					,e.PaidAmt
					,convert(nvarchar(10),e.PayedDt,103) as PayedDate
					,b.RoomCode
					,d.FullName
					,d.Address as [Address]
					,b.WaterwayArea
					,e.IsBill
					,e.BillUrl
					,e.isPush
					,CONCAT(b.projectCd,'-',v.ProjectName)  as projectFolder
			  FROM MAS_Service_ReceiveEntry e
				join MAS_Apartments b on e.ApartmentId = b.ApartmentId
				join MAS_Rooms a on a.RoomCode = b.RoomCode 
				join MAS_Buildings c on a.BuildingCd = c.BuildingCd 
				join UserInfo u on b.UserLogin = u.loginName
				join MAS_Customers d on u.CustId = d.CustId
				left join MAS_Projects as v on v.projectCd = b.projectCd 			
				WHERE e.isExpected = 1
					and b.RoomCode = @roomCode
					and MONTH(e.ToDt) = MONTH(@toDate)
					and YEAR(e.ToDt) = YEAR(@toDate)
					order by e.SysDate desc
	end try
	begin catch
		declare	@ErrorNum				int,
				@ErrorMsg				varchar(200),
				@ErrorProc				varchar(50),

				@SessionID				int,
				@AddlInfo				varchar(max)

		set @ErrorNum					= error_number()
		set @ErrorMsg					= 'sp_Hom_Service_Receivable_Report_ByRoomCode ' + error_message()
		set @ErrorProc					= error_procedure()

		set @AddlInfo					= '@UserID ' + @UserID 

		exec utl_Insert_ErrorLog @ErrorNum, @ErrorMsg, @ErrorProc, 'Service_Receivable_Report', 'Get', @SessionID, @AddlInfo
	end catch