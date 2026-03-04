-- exec sp_res_service_receivable_bill_create '81739c5c-2ca0-4e0f-acab-63373ea8a34a',null,

CREATE procedure [dbo].[sp_res_service_receivable_bill_create]
	@userId nvarchar(450),
	@receiveIds	nvarchar(max)=null,
	@ProjectCd nvarchar(30)
as
	begin try

		if @receiveIds is null or @receiveIds = ''
		begin
			UPDATE t
			   SET IsBill = 0
				  ,bill_st = 1
			 FROM MAS_Service_ReceiveEntry t
				join MAS_Apartments ma on t.ApartmentId = ma.ApartmentId
				LEFT JOIN MAS_Buildings c ON ma.buildingOid = c.oid 
			 WHERE IsPayed = 0 
				and isExpected = 1
				and t.ProjectCd = @ProjectCd

			SELECT t.ReceiveId
				  ,0 as receiveBillStatus
			FROM MAS_Service_ReceiveEntry t
				join MAS_Apartments ma on t.ApartmentId = ma.ApartmentId
				LEFT JOIN MAS_Buildings c ON ma.buildingOid = c.oid 
			 WHERE IsPayed = 0 
				and isExpected = 1
				and t.ProjectCd = @ProjectCd
		end
		else
		begin
			UPDATE t
			   SET IsBill = 0
			      ,bill_st = 1
			 FROM MAS_Service_ReceiveEntry t
				join MAS_Apartments ma on (t.apartOid = ma.oid OR (t.apartOid IS NULL AND t.ApartmentId = ma.ApartmentId))
				join MAS_Buildings c on ma.buildingOid = c.oid
			 WHERE isExpected = 1
				--and IsPayed = 0 
				and t.ReceiveId in (SELECT part FROM [dbo].[SplitString](@receiveIds,',')) 
			
			SELECT t.ReceiveId
				  ,0 as receiveBillStatus
			FROM MAS_Service_ReceiveEntry t
				join MAS_Apartments ma on t.ApartmentId = ma.ApartmentId
				LEFT JOIN MAS_Buildings c ON ma.buildingOid = c.oid 
			 WHERE isExpected = 1
				and IsPayed = 0 
				and t.ReceiveId in (SELECT part FROM [dbo].[SplitString](@receiveIds,',')) 
		end

	end try
	begin catch
		declare	@ErrorNum				int,
				@ErrorMsg				varchar(200),
				@ErrorProc				varchar(50),

				@SessionID				int,
				@AddlInfo				varchar(max)

		set @ErrorNum					= error_number()
		set @ErrorMsg					= 'sp_res_service_receivable_bill_create' + error_message()
		set @ErrorProc					= error_procedure()

		set @AddlInfo					= ''

		exec utl_Insert_ErrorLog @ErrorNum, @ErrorMsg, @ErrorProc, 'Receivable', 'Bill', @SessionID, @AddlInfo
	end catch