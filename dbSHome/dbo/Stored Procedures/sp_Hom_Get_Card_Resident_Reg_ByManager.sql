





CREATE procedure [dbo].[sp_Hom_Get_Card_Resident_Reg_ByManager]
	@ProjectCd nvarchar(30),
	@RoomCd nvarchar(30),
	@Offset				int				= 0,
	@PageSize			int				= 10,
	@Total				int out,
	@TotalFiltered		int out

as
	begin try
		declare @tbRegs TABLE 
		(
			RegCardId [Int] null
		)

		set		@Offset					= isnull(@Offset, 0)
		set		@PageSize				= isnull(@PageSize, 10)
		set		@Total					= isnull(@Total, 0)
		set		@RoomCd					= isnull(@RoomCd,'')

		if		@PageSize	= 0			set @PageSize	= 10
		if		@Offset		< 0			set @Offset		=  0

		INSERT INTO @tbRegs 
			SELECT a.RequestId 
			  FROM TRS_Request_Card a 
			  inner join MAS_Requests f on a.RequestId = f.RequestId 
			  INNER JOIN MAS_Apartments b ON f.ApartmentId = b.ApartmentId
			  WHERE f.ProjectCd = @ProjectCd and b.RoomCode like @RoomCd +'%'
				  ORDER BY f.RequestDt DESC
				  offset @Offset rows	
					fetch next @PageSize rows only

			select	@Total					= count(a.RequestId)
			FROM TRS_Request_Card a 
			inner join MAS_Requests f on a.RequestId = f.RequestId 
			INNER JOIN MAS_Apartments b ON f.ApartmentId = b.ApartmentId
				--WHERE (IsManager is null or IsManager = 0)

			set @TotalFiltered = @Total
	--1
		SELECT a.RequestId
			  ,f.[ApartmentId]
			  ,a.CustId as CifNo
			  ,a.CustId
			  ,a.[CardTypeId]
			  ,CardTypeName
			  ,[IsVehicle]
			  ,convert(nvarchar(5),f.RequestDt,108) + ' - ' + convert(nvarchar(10),f.RequestDt,103) as RequestDate 
			  ,case RequestKey 
				when 'RequestFix' then
					case isnull(f.[Status],0) when 0 then N'Mới yêu cầu' when 1 then N'Đã phân công' when 2 then N'Đang xử lý' else N'Hoàn thành' end 
				when 'RequestSev' then
					case isnull(f.[Status],0) when 0 then N'Mới yêu cầu' when 1 then N'Đã phân công' when 2 then N'Đang xử lý' else N'Hoàn thành' end 
				when 'CardRegister' then
					case isnull(f.[Status],0) when 0 then N'Mới yêu cầu' when 1 then N'Đã xem' when 2 then N'Đâ cấp thẻ' else N'Từ chối' end 
				when 'CardAdd' then
					case isnull(f.[Status],0) when 0 then N'Mới yêu cầu' when 1 then N'Đã xem' when 2 then N'Đâ phê duyệt' else N'Từ chối' end 
				else
					case isnull(f.[Status],0) when 0 then N'Yêu cầu khóa' when 1 then N'Đã xem' when 2 then N'Đã khóa thẻ' else N'Từ chối' end 
			  end as	[StatusName]
			  --,case isnull(f.[Status],0) when 0 then N'Mới yêu cầu' when 1 then N'Đã xem' when 2 then N'Đâ cấp thẻ' else N'Từ chối' end as [StatusName]
			  ,a.[Auth_Dt]
			  ,[CardId]
			  ,d.FullName
			  ,e.RoomCode
			  ,f.Status
	  FROM [dbo].TRS_Request_Card a 
	  inner join MAS_Requests f on a.RequestId = f.RequestId 
	  INNER JOIN MAS_CardTypes b On a.CardTypeId = b.CardTypeId
	  INNER JOIN MAS_Apartments e ON f.ApartmentId = e.ApartmentId 
	  inner join UserInfo cc ON e.UserLogin = cc.loginName
	  INNER JOIN MAS_Customers d ON cc.CustId = d.CustId
	  INNER JOIN @tbRegs c On a.RequestId = c.RegCardId 
	   WHERE f.ProjectCd = @ProjectCd and e.RoomCode like @RoomCd +'%'
			ORDER BY f.RequestDt DESC, RoomCode
				  offset @Offset rows	
					fetch next @PageSize rows only
	--2
		SELECT [RegCardVehicleId]
			  ,a.RequestId 
			  ,a.[VehicleTypeId]
			  ,[VehicleNo]
			  ,VehicleName
			  ,VehicleTypeName
	  FROM [TRS_RegCardVehicle] a 
		INNER JOIN MAS_VehicleTypes b On a.VehicleTypeId = b.VehicleTypeId
		INNER JOIN @tbRegs c On a.RequestId = c.RegCardId 
	--3
	SELECT [RegCardCreditId]
		  ,a.RequestId 
		  ,[Cif_No2] as CifNo2
		  ,b.FullName
		  ,[CreditLimit]
		  ,[SalaryAvg]
		  ,[isSalaryTranfer]
		  ,[ResidenProvince]
	  FROM [TRS_RegCardCredit] a Left Join MAS_Customers b On a.Cif_No2 = b.Cif_No 
	  INNER JOIN @tbRegs c On a.RequestId = c.RegCardId 

	end try
	begin catch
		declare	@ErrorNum				int,
				@ErrorMsg				varchar(200),
				@ErrorProc				varchar(50),

				@SessionID				int,
				@AddlInfo				varchar(max)

		set @ErrorNum					= error_number()
		set @ErrorMsg					= 'sp_Hom_Get_Card_Registers_ByManager ' + error_message()
		set @ErrorProc					= error_procedure()

		set @AddlInfo					= ' '

		exec utl_Insert_ErrorLog @ErrorNum, @ErrorMsg, @ErrorProc, 'CardRegisters', 'GET', @SessionID, @AddlInfo
	end catch