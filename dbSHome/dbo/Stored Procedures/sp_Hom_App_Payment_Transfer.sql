













CREATE procedure [dbo].[sp_Hom_App_Payment_Transfer]
	@userId	nvarchar(450),
	@receiveId int
as
	begin try
		--0
		SELECT a.ReceiveId
			  ,TotalAmt as [TotalAmt]
			  ,isnull(a.Remart,N'Hóa đơn tháng ' + cast(month(a.ToDt) as varchar) + N' năm ' + cast(year(a.ToDt) as varchar)) as Remark 
			  ,b.RoomCode
			  ,d.[address]
			  ,d.projectName 
			  ,d.timeWorking
			  ,d.bank_acc_name 
			  ,d.bank_acc_no 
			  ,d.bank_branch 
			  ,d.bank_name 
			  ,[dbo].[fChuyenCoDauThanhKhongDau](c.FullName) + N' nop phi thang ' + cast(month(a.ToDt) as varchar) + '/' + cast(year(a.ToDt) as varchar) 
				+ ' can ho ' + b.RoomCode + ' MaHD ' + cast(a.ReceiveId as varchar) as receiveContent
	  FROM [dbo].MAS_Service_ReceiveEntry a 
			INNER JOIN MAS_Apartments b ON a.ApartmentId = b.ApartmentId
			left join Mas_projects d on b.projectCd = d.projectCd
			left join UserInfo u on b.UserLogin = u.loginName 
			left join MAS_Customers c on u.CustId = c.CustId 
		WHERE  a.ReceiveId = @ReceiveId
	

	end try
	begin catch
		declare	@ErrorNum				int,
				@ErrorMsg				varchar(200),
				@ErrorProc				varchar(50),

				@SessionID				int,
				@AddlInfo				varchar(max)

		set @ErrorNum					= error_number()
		set @ErrorMsg					= 'sp_Hom_App_Payment_Transfer ' + error_message()
		set @ErrorProc					= error_procedure()

		set @AddlInfo					= ' '

		exec utl_Insert_ErrorLog @ErrorNum, @ErrorMsg, @ErrorProc, 'Payment_Transfer', 'GET', @SessionID, @AddlInfo
	end catch