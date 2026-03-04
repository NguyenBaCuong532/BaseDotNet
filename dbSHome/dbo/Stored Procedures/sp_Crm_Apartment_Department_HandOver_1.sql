






CREATE procedure [dbo].[sp_Crm_Apartment_Department_HandOver]
	@UserId nvarchar(450)

as
	begin try
	--1
	SELECT a.[DepartmentCd]
		  ,a.[DepartmentName] as DepartmentName
		  ,[EmailOwn]
		  ,[EmailList]
		  ,[Note]
		  ,[intOrder]
	  FROM [Hrm_Departments] a 
		inner join CRM_Apartment_HandOver_Team b on a.DepartmentCd = b.DepartmentCd

	end try
	begin catch
		declare	@ErrorNum				int,
				@ErrorMsg				varchar(200),
				@ErrorProc				varchar(50),

				@SessionID				int,
				@AddlInfo				varchar(max)

		set @ErrorNum					= error_number()
		set @ErrorMsg					= 'sp_Get_Department_ById ' + error_message()
		set @ErrorProc					= error_procedure()

		set @AddlInfo					= ' '

		exec utl_Insert_ErrorLog @ErrorNum, @ErrorMsg, @ErrorProc, 'Department', 'GET', @SessionID, @AddlInfo
	end catch