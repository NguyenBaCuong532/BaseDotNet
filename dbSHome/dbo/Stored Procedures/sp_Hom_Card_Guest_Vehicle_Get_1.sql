







CREATE procedure [dbo].[sp_Hom_Card_Guest_Vehicle_Get]
	@CardVehicleId	int
as
	begin try	
		--1
		SELECT b.CardVehicleId
			  ,convert(nvarchar(10),a.[IssueDate],103) [IssueDate]
			  ,c.FullName
			  ,b.VehicleNo 
			  ,b.VehicleName 
			  ,c.Phone
			  ,convert(nvarchar(10),b.StartTime,103) as StartTime
			  ,convert(nvarchar(10),b.EndTime,103) as EndTime
			  ,a.CardName as CardTypeName
			  ,a.cardCd
			  ,a.CustId
			  ,d.VehicleTypeName
			  ,b.[Status]
			  ,case b.[Status] when 1 then N'Đang hoạt động' when 2 then 'Quá hạn TT' else 'Khóa xe' end as StatusName
			  ,b.AssignDate
			  ,b.VehicleTypeId
			  ,b.projectCd
	  FROM MAS_CardVehicle b
			left join [dbo].[MAS_Cards] a on a.CardId = b.CardId
			join MAS_Customers c on b.CustId = c.CustId
			join MAS_VehicleTypes d on b.VehicleTypeId = d.VehicleTypeId
	  WHERE CardVehicleId = @CardVehicleId



	end try
	begin catch
		declare	@ErrorNum				int,
				@ErrorMsg				varchar(200),
				@ErrorProc				varchar(50),

				@SessionID				int,
				@AddlInfo				varchar(max)

		set @ErrorNum					= error_number()
		set @ErrorMsg					= 'sp_Get_Card_Vehicle_ById ' + error_message()
		set @ErrorProc					= error_procedure()

		set @AddlInfo					= ' '

		exec utl_Insert_ErrorLog @ErrorNum, @ErrorMsg, @ErrorProc, 'CardVehicle', 'GET', @SessionID, @AddlInfo
	end catch