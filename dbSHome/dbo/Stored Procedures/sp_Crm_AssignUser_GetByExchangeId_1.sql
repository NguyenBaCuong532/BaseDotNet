

CREATE procedure [dbo].[sp_Crm_AssignUser_GetByExchangeId]
	@UserId nvarchar(450)=null,
	@ExchangeId bigint
as
--select * from SplitString('c0316391-44f1-4849-8d66-e7ed013e29bc,23dead63-1f11-403e-b621-d3159d76032e,ae7ed78b-c97e-47a4-841f-4d780fa07d91,2f43e62b-a736-41b3-88ec-c1caf2d24f0c,8c91b4a5-58a0-448f-9a78-7728e0dba990,e2af1ba1-65ab-46ac-8655-d549a3c54f40,7550cb0f-cb88-4387-9728-9398ce979b00,abbf0352-3a1e-4f36-a2c2-4d59c4aff842,9449a563-2563-43d0-8f2d-288d97b64944,4f859aa4-0010-4c76-94e1-4f074c726531,fd57d602-70ad-421a-8772-7ca274c25b3e,1f812e3d-2dfa-443a-a422-a7903d8f7cb6,dfea1306-0b2a-464f-995a-1fb7ab4c6947,54026b24-ef10-40cb-bafa-5a9a834613b3',',')
	begin try	
	    declare @UserAssign as nvarchar(500)
		declare @AdminUserAssign as nvarchar(100)
		select @UserAssign = isnull(UserAssign,'') from CRM_Apartment_HandOver_Exchange where ExchangeId = @ExchangeId
		select @AdminUserAssign = isnull(UserAdminAssign,'') from CRM_Apartment_HandOver_Exchange where ExchangeId = @ExchangeId
		declare @tableUser TABLE(
			userId nvarchar(50) not null
		);
		declare @tableUserAdmin TABLE(
			userId nvarchar(50) not null
		);
		insert into @tableUser(userId) (select part from SplitString(@UserAssign,','))
		insert into @tableUserAdmin(userId) values (@AdminUserAssign)

		--	select c.FullName 
		--		  ,b.[UserLogin]
		--		  ,a.EmployeeCd as EmployeeCd
		--		  ,c.CustId
		--		  ,b.UserId 
		--		  ,d.DepartmentName
		--		  ,c.Phone as PhoneNumber
		--		  ,isnull(c.AvatarUrl, b.AvatarUrl) as Avatar
		--		  ,0 as IsUserAdminAssign
		--	from  MAS_Employees a 
		--		inner join MAS_Customers c ON a.CustId = c.CustId
		--		inner join MAS_Users b on a.UserId = b.UserId
		--		inner join CRM_Apartment_HandOver_User kt on b.UserId = kt.UserId
		--		inner join @tableUser us on a.UserId = us.userId
		--		left join Hrm_Departments d on a.DepartmentCd = d.DepartmentCd	
		--	--where b.UserId <> (select top 1 userId from @tableUserAdmin)
		--	where not exists (select userId from @tableUserAdmin where  userId = b.UserId)
		--union
		--	select c.FullName 
		--		  ,b.[UserLogin]
		--		  ,a.EmployeeCd as EmployeeCd
		--		  ,c.CustId
		--		  ,b.UserId 
		--		  ,d.DepartmentName
		--		  ,c.Phone as PhoneNumber
		--		  ,isnull(c.AvatarUrl, b.AvatarUrl) as Avatar
		--		  ,1 as IsUserAdminAssign
		--	from  MAS_Employees a 
		--		inner join MAS_Customers c ON a.CustId = c.CustId
		--		inner join MAS_Users b on a.UserId = b.UserId
		--		inner join CRM_Apartment_HandOver_User kt on b.UserId = kt.UserId
		--		inner join @tableUserAdmin us on a.UserId = us.userId
		--		left join Hrm_Departments d on a.DepartmentCd = d.DepartmentCd	


		
	end try
	begin catch
		declare	@ErrorNum				int,
				@ErrorMsg				varchar(200),
				@ErrorProc				varchar(50),

				@SessionID				int,
				@AddlInfo				varchar(max)

		set @ErrorNum					= error_number()
		set @ErrorMsg					= 'sp_Crm_AssignUser_GetByExchangeId ' + error_message()
		set @ErrorProc					= error_procedure()

		set @AddlInfo					= ' '

		exec utl_Insert_ErrorLog @ErrorNum, @ErrorMsg, @ErrorProc, 'CRM_Apartment_HandOver_Exchange', 'GET', @SessionID, @AddlInfo
	end catch