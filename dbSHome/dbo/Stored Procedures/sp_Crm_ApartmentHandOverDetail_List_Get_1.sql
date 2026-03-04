

CREATE procedure [dbo].[sp_Crm_ApartmentHandOverDetail_List_Get]
	@UserId nvarchar(450)=null,
	@HanOVerId bigint
as
	begin try		
		 
		 select isnull(c.TitleHandOver,N'Not title') as TitleHandOver
				,a.HandOverDetailId
			    ,a.HandOverId
				,a.ContractId
				,a.RoomCd
				,a.RoomCode
				,a.CustomerName
				,a.PhoneNumber
				,a.BuildingCd
				,a.ProjectCd
				,a.HandOverExpectedDate
				,a.RequestDateCus
				,d.HandOverDtStatusName as HandOverDtStatus
				,d.Color as HandOverDtStatusColor
				,a.PercentDone as PhanTramKetQua
				,(select count(b.ExchangeId) 
				 from CRM_Apartment_HandOver_Exchange b 
				 where b.HandOverDetailId = a.HandOverDetailId) as TotalWork

				 ,(select count(b.ExchangeId) 
				   from CRM_Apartment_HandOver_Exchange b 
				   where b.HandOverDetailId = a.HandOverDetailId and b.WorkStatusId = 1) as DangChoStatus
				 ,(select Color from CRM_Apartment_HandOver_WorkStatus where WorkStatusId = 1) as DangChoSatatusColor

					 ,(select count(b.ExchangeId) 
					   from CRM_Apartment_HandOver_Exchange b 
					   where b.HandOverDetailId = a.HandOverDetailId and b.WorkStatusId = 2) as DangLamStatus
					 ,(select Color from CRM_Apartment_HandOver_WorkStatus where WorkStatusId = 2) as DangLamStatusColor

					 ,(select count(b.ExchangeId) 
					   from CRM_Apartment_HandOver_Exchange b 
					   where b.HandOverDetailId = a.HandOverDetailId and b.WorkStatusId = 3) as HoanThanhStatus
					 ,(select Color from CRM_Apartment_HandOver_WorkStatus where WorkStatusId = 3) as HoanThanhStatusColor

					 ,(select count(b.ExchangeId) 
					   from CRM_Apartment_HandOver_Exchange b 
					   where b.HandOverDetailId = a.HandOverDetailId and b.WorkStatusId = 4) as QuaHanStatus
					 ,(select Color from CRM_Apartment_HandOver_WorkStatus where WorkStatusId = 4) as QuaHanStatusColor
			 from CRM_Apartment_HandOver_Detail a left join CRM_Apartment_HandOver c on a.HandOverId = c.HandOverId
				  left join CRM_Apartment_HandOverDt_Status d on a.HandOverDtStatus= d.HandOverDtStatusId
		 where a.HandOverId = @HanOVerId
		

	end try
	begin catch
		declare	@ErrorNum				int,
				@ErrorMsg				varchar(200),
				@ErrorProc				varchar(50),

				@SessionID				int,
				@AddlInfo				varchar(max)

		set @ErrorNum					= error_number()
		set @ErrorMsg					= 'sp_Crm_GetApartmentHandOverDetail_List ' + error_message()
		set @ErrorProc					= error_procedure()

		set @AddlInfo					= ' '

		exec utl_Insert_ErrorLog @ErrorNum, @ErrorMsg, @ErrorProc, 'CRM_Apartment_HandOver_Detail', 'GET', @SessionID, @AddlInfo
	end catch