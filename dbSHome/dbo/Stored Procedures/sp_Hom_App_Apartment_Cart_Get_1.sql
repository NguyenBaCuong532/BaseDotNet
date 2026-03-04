










CREATE procedure [dbo].[sp_Hom_App_Apartment_Cart_Get]
	@UserId nvarchar(450),
	@roomCd	nvarchar(20),
	@language		nvarchar(50)
as
	begin try
		--declare
		declare @langVi bit
		if @language = 'vi-VN' or @language = 'vi' or @language = null
			set @langVi = 1
		else 
			set @langVi = 0

	--1 profile
		SELECT a.[ApartmentId]
			  ,r.[RoomCode]
			  ,c.FullName
			  ,c.AvatarUrl
			  ,r.floorNo
			  ,u.[UserId]
			  ,a.[UserLogin]
			  ,b.[BuildingCd]
			  ,b.BuildingName
			  ,b.ProjectName
			  --,c.Phone
			  --,c.Email
			  ,a.IsReceived
			  ,convert(nvarchar(10),a.ReceiveDt,103) as ReceiveDate
			  ,a.IsRent 
	  FROM [MAS_Apartments] a 
			join MAS_Rooms r on r.RoomCode = a.RoomCode
			JOIN MAS_Buildings b On r.BuildingCd = b.BuildingCd 
			join UserInfo u on a.UserLogin = u.loginName 
			JOIN MAS_Customers c ON u.CustId = c.CustId 
	  WHERE exists(select userId from UserInfo 
		where userid = @UserId and CustId = u.CustId)
				
		--SELECT [contractId]
		--	  ,[contractNo]
		--	  ,[contract_Dt]
		--	  ,[status]
		--	  ,[orderId]
		--	  ,[roomCd]
		--	  ,[roomCode]
		--	  ,[cif_No]
		--	  ,[totalAmt]
		--  FROM [COR_Contracts] a
		--  WHERE [roomCd] = @roomCd 
		--	and (a.status = 2 or a.status = 5)
	
		--if @langVi = 1
		--	select a.DetailId,
		--		   a.OrderId,
		--		   a.InstallNum,
		--		   a.InstallDate,
		--		   a.InstallNote,
		--		   a.Rate,
		--		   a.MainFee,
		--		   a.Amount,
		--		   a.PayedAmt,
		--		   a.Status,
		--		   a.InstallDes
		--	from BUS_Order_SchPay a
		--		join [].[dbo].BUS_Orders b on a.orderId = b.orderId 
		--	where b.roomCd = @roomCd 
		--		and b.isClose = 0
		--else
		--	select a.DetailId,
		--		   a.OrderId,
		--		   a.InstallNum,
		--		   a.InstallDate,
		--		   a.InstallNote_En as InstallNote,
		--		   a.Rate,
		--		   a.MainFee,
		--		   a.Amount,
		--		   a.PayedAmt,
		--		   a.Status,
		--		   a.InstallDes_En as InstallDes
		--	from BUS_Order_SchPay a
		--		join BUS_Orders b on a.orderId = b.orderId 
		--	where b.roomCd = @roomCd 
		--		and b.isClose = 0

	end try
	begin catch
		declare	@ErrorNum				int,
				@ErrorMsg				varchar(200),
				@ErrorProc				varchar(50),

				@SessionID				int,
				@AddlInfo				varchar(max)

		set @ErrorNum					= error_number()
		set @ErrorMsg					= 'sp_Hom_App_Apartment_Cart_Get' + error_message()
		set @ErrorProc					= error_procedure()

		set @AddlInfo					= ' '

		exec utl_Insert_ErrorLog @ErrorNum, @ErrorMsg, @ErrorProc, 'Apartment_Cart', 'GET', @SessionID, @AddlInfo
	end catch