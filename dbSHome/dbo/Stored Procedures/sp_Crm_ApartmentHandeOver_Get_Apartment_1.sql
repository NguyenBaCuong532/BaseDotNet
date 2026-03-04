





CREATE procedure [dbo].[sp_Crm_ApartmentHandeOver_Get_Apartment] 
	@userId nvarchar(450),
	@ProjectCd nvarchar(50),
	@BuildingCd nvarchar(50),
	@FloorFrom nvarchar(10),
	@FloorTo nvarchar(10),
	@RoomCode nvarchar(20)
as
	begin try	
	select null where 0=1
				--select a.RoomCd as RoomCd ,
				--	   a.Code as RoomCode,
				--	   ct.ContractId as ContractId,
				--	   ct.Cus_Name as CustomerName,
				--	   ct.Cus_Phone1 as PhoneNumber,
				--	   b.BuildingCd,
				--	   c.BuildingName,
				--	   b.ProjectCd,
				--	   e.ProjectName
				--from .dbo.BLD_Rooms a inner join .dbo.COR_Contracts ct on a.RoomCd = ct.RoomCd --and (ct.Status = 2 or ct.Status = 4)
				--							left join .dbo.BLD_RoomCategory b on a.CategoryCd = b.CategoryCd
				--							inner join .dbo.BLD_Buildings c on b.BuildingCd = c.BuildingCd
				--							inner join .dbo.BLD_Projects e on c.ProjectCd = e.ProjectCd
				--where not exists (select hd.RoomCd from CRM_Apartment_HandOver_Detail hd where hd.RoomCd = a.RoomCd and ProjectCd = @ProjectCd and BuildingCd = @BuildingCd and IsAgreeReceive = 1)
				--      and not exists (select dh.ContractId  from .dbo.COR_Contract_Liquidation dh where dh.ContractId = ct.ContractId)
				--	  and a.FloorNo between  isnull(@FloorFrom,'00') and isnull(@FloorTo,'99')
				--	  and (@ProjectCd is null or b.ProjectCd = @ProjectCd)
				--	  and (@BuildingCd is null or b.BuildingCd = @BuildingCd)
				--	  and (@RoomCode is null or a.Code like '%' + @roomCode + '%')
			  
			 
			--select * from CRM_Issues WHERE IssueId = @IssueId

			end try
	begin catch
		declare	@ErrorNum				int,
				@ErrorMsg				varchar(200),
				@ErrorProc				varchar(50),

				@SessionID				int,
				@AddlInfo				varchar(max)

		set @ErrorNum					= error_number()
		set @ErrorMsg					= 'sp_Crm_HandeOver_Get_Apartment ' + error_message()
		set @ErrorProc					= error_procedure()

		set @AddlInfo					= '@CustId '  

		exec utl_Insert_ErrorLog @ErrorNum, @ErrorMsg, @ErrorProc, '.dbo.BLD_Rooms', 'Get', @SessionID, @AddlInfo
	end catch