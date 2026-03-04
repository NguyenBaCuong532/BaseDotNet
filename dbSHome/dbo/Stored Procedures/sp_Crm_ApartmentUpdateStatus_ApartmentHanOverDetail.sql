
CREATE procedure [dbo].[sp_Crm_ApartmentUpdateStatus_ApartmentHanOverDetail]
	@userId	nvarchar(450),
	@HandOverDetailId bigint,
	@Column nvarchar(100),
	@Status bit
as
	begin try		
		Declare @query NVARCHAR(500);
		Declare @nStatus nvarchar(20);
		if @Status = 1
			set @nStatus = '1'
		else
			set @nStatus = '0'
		set @query = 'update CRM_Apartment_HandOver_Detail set '+ @Column + ' = ' + @nStatus  + ', Modified = getdate(), ModifiedBy = '''+ @userId + ''' where HandOverDetailId = ' + cast(@HandOverDetailId as nvarchar(10))
		if exists (select HandOverDetailId from CRM_Apartment_HandOver_Detail where HandOverDetailId = @HandOverDetailId)
			begin
				execute(@query)
			end

		declare @count int
		declare @dempm int
		declare @demkt int
		declare @dembnt int
		declare @departmentcd nvarchar(20)

		declare @hanoverid int
		set @hanoverid = (select top 1 HandOverId from CRM_Apartment_HandOver_Detail where HandOverDetailId = @HandOverDetailId)
		set @count = (select count(HandOverDetailId) from CRM_Apartment_HandOver_Detail where HandOverId = @hanoverid)
		set @dempm = (select count(HandOverDetailId) from CRM_Apartment_HandOver_Detail where HandOverId = @hanoverid and IsPMCheck = 1)
		set @demkt = (select count(HandOverDetailId) from CRM_Apartment_HandOver_Detail where HandOverId = @hanoverid and IsKTCheck = 1)
		set @dembnt = (select count(HandOverDetailId) from CRM_Apartment_HandOver_Detail where HandOverId = @hanoverid and IsBNTCheck = 1)

		set @departmentcd = (select top 1 d.DepartmentCd from  MAS_Employees a 
			inner join Hrm_Departments d on a.DepartmentCd = d.DepartmentCd
			inner join MAS_Customers b on a.CustId = b.CustId
			inner join MAS_Users c on b.CustId = c.CustId
			inner join CRM_Apartment_HandOver_User kt on c.UserId = kt.UserId
			where c.UserId = @userId)

		if (@count = @dempm)
			begin
				update t set t.StatusType = 1
				from CRM_Apartment_HandOver_Exchange t inner join CRM_Apartment_HandOver_Team b on t.DepartmentCd = b.DepartmentCd
				where HandOverId = @hanoverid and (@departmentcd is null or t.DepartmentCd = @departmentcd) and b.Type = 1
			end
		else 
			begin
				update t set t.StatusType = 0
				from CRM_Apartment_HandOver_Exchange t inner join CRM_Apartment_HandOver_Team b on t.DepartmentCd = b.DepartmentCd
				where HandOverId = @hanoverid and (@departmentcd is null or t.DepartmentCd = @departmentcd) and b.Type = 1
			end
		---------------
		if (@count = @demkt)
			begin
				update t set t.StatusType = 1
				from CRM_Apartment_HandOver_Exchange t inner join CRM_Apartment_HandOver_Team b on t.DepartmentCd = b.DepartmentCd
				where HandOverId = @hanoverid and (@departmentcd is null or t.DepartmentCd = @departmentcd) and b.Type = 2
			end
		else 
			begin
				update t set t.StatusType = 0
				from CRM_Apartment_HandOver_Exchange t inner join CRM_Apartment_HandOver_Team b on t.DepartmentCd = b.DepartmentCd
				where HandOverId = @hanoverid and (@departmentcd is null or t.DepartmentCd = @departmentcd) and b.Type = 2
			end
		--------------
		if (@count = @dembnt)
			begin
				update t set t.StatusType = 1
				from CRM_Apartment_HandOver_Exchange t inner join CRM_Apartment_HandOver_Team b on t.DepartmentCd = b.DepartmentCd
				where HandOverId = @hanoverid and (@departmentcd is null or t.DepartmentCd = @departmentcd) and b.Type = 3
			end
		else 
			begin
				update t set t.StatusType = 0
				from CRM_Apartment_HandOver_Exchange t inner join CRM_Apartment_HandOver_Team b on t.DepartmentCd = b.DepartmentCd
				where HandOverId = @hanoverid and (@departmentcd is null or t.DepartmentCd = @departmentcd) and b.Type = 3
			end

		select * from CRM_Apartment_HandOver_Detail where HandOverDetailId = @HandOverDetailId 
		--select @query
	end try
	begin catch
		declare	@ErrorNum				int,
				@ErrorMsg				varchar(200),
				@ErrorProc				varchar(50),

				@SessionID				int,
				@AddlInfo				varchar(max)

		set @ErrorNum					= error_number()
		set @ErrorMsg					= 'sp_Update_Cab_Driver_Status ' + error_message()
		set @ErrorProc					= error_procedure()

		set @AddlInfo					= '@UserID ' + @userId

		exec utl_Insert_ErrorLog @ErrorNum, @ErrorMsg, @ErrorProc, 'Drivers', 'Update', @SessionID, @AddlInfo
	end catch