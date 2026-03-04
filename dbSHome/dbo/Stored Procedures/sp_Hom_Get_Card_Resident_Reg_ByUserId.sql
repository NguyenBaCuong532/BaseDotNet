




CREATE procedure [dbo].[sp_Hom_Get_Card_Resident_Reg_ByUserId]
	@UserId	nvarchar(450),
	@ApartmentId int
as
	begin try
		if @ApartmentId is null or @ApartmentId = 0
			set @ApartmentId = (SELECT top 1 ApartmentId FROM MAS_Apartment_Member a inner join UserInfo b on a.CustId=b.CustId WHERE a.memberUserId = @UserID)
	--1
		SELECT a.RequestId 
			  ,[ApartmentId]
			  ,a.CustId as CifNo
			  ,a.CustId
			  ,a.[CardTypeId]
			  ,CardTypeName
			  ,[IsVehicle]
			  ,convert(nvarchar(5),f.[RequestDt],108) + ' - ' + convert(nvarchar(10),[RequestDt],103) as [RequestDate] 
			  ,f.[Status]
			  ,[Auth_Dt]
			  ,[CardId]
			  ,case isnull(f.[Status],0) when 0 then N'Mới yêu cầu' when 1 then N'Đã xem' when 2 then N'Đã cấp thẻ' else N'Từ chối' end as [StatusName]
	  FROM [TRS_Request_Card] a 
		INNER JOIN MAS_CardTypes b On a.CardTypeId = b.CardTypeId
		Inner join MAS_Requests f on a.RequestId = f.RequestId 
	  WHERE f.ApartmentId = @ApartmentId
	  ORDER BY f.RequestDt desc
	--2
		SELECT [RegCardVehicleId]
			  ,RequestId 
			  ,a.[VehicleTypeId]
			  ,[VehicleNo]
			  ,VehicleName
			  ,VehicleTypeName
	  FROM [TRS_RegCardVehicle] a INNER JOIN MAS_VehicleTypes b On a.VehicleTypeId = b.VehicleTypeId
	WHERE EXISTS(SELECT c.[ApartmentId] FROM [MAS_Apartments] c 
		INNER JOIN MAS_Requests f ON f.ApartmentId = c.ApartmentId
		INNER JOIN [dbo].TRS_Request_Card b ON b.RequestId = f.RequestId WHERE b.RequestId = a.RequestId AND c.ApartmentId = @ApartmentId)
	--3
	SELECT [RegCardCreditId]
		  ,RequestId 
		  ,[Cif_No2] as CifNo2
		  ,b.FullName
		  ,[CreditLimit]
		  ,[SalaryAvg]
		  ,[isSalaryTranfer]
		  ,[ResidenProvince]
	  FROM [TRS_RegCardCredit] a Left Join MAS_Customers b On a.Cif_No2 = b.Cif_No
	  WHERE EXISTS(SELECT c.[ApartmentId] FROM [MAS_Apartments] c 
		INNER JOIN MAS_Requests f ON f.ApartmentId = c.ApartmentId
		INNER JOIN [dbo].TRS_Request_Card b ON b.RequestId = f.RequestId WHERE b.RequestId = a.RequestId AND c.ApartmentId = @ApartmentId)

	end try
	begin catch
		declare	@ErrorNum				int,
				@ErrorMsg				varchar(200),
				@ErrorProc				varchar(50),

				@SessionID				int,
				@AddlInfo				varchar(max)

		set @ErrorNum					= error_number()
		set @ErrorMsg					= 'sp_Hom_Get_Card_Registers_ByUserId ' + error_message()
		set @ErrorProc					= error_procedure()

		set @AddlInfo					= ' '

		exec utl_Insert_ErrorLog @ErrorNum, @ErrorMsg, @ErrorProc, 'CardRegisters', 'GET', @SessionID, @AddlInfo
	end catch