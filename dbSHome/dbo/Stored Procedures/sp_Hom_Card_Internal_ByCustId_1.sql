CREATE procedure [dbo].[sp_Hom_Card_Internal_ByCustId]
	@UserId	nvarchar(450),
	@CustId nvarchar(50)
as
	begin try

	--1
		SELECT a.[CardCd]
			  ,convert(nvarchar(10),a.[IssueDate],103) [IssueDate]
			  ,s.[StatusName]
			  ,a.Card_St as [Status]
			  ,c.FullName
			  ,a.IsClose 
			  ,a.CloseDate 
			  ,c.Phone
			  ,c.Email
			  ,a.CardName
			  ,a.CustId
			  --,isnull(p.CurrPoint,0) as [CurrentPoint]
			  ,case when exists(select CardId from MAS_CardVehicle where cardid = a.CardId) then 1 else 0 end IsVihecle
			  --,md.DepartmentName 
	  FROM [dbo].[MAS_Cards] a 
			inner join MAS_Customers c on a.CustId = c.CustId
			inner join MAS_CardStatus s on a.Card_St = s.StatusId
			inner join [dbSHRM].[dbo].[Employees] e on a.CustId = e.CustId
			--inner join MAS_Points p on a.CustId = p.CustId 
			--left join HRM_Departments md on e.DepartmentCd = md.DepartmentCd 
		WHERE a.CustId = @CustId
			--and a.CardTypeId = 2 
			--and a.IsVip = 1 
			 
	--2
	
	end try
	begin catch
		declare	@ErrorNum				int,
				@ErrorMsg				varchar(200),
				@ErrorProc				varchar(50),

				@SessionID				int,
				@AddlInfo				varchar(max)

		set @ErrorNum					= error_number()
		set @ErrorMsg					= 'sp_Hom_Get_Card_VIP_ByCustId ' + error_message()
		set @ErrorProc					= error_procedure()

		set @AddlInfo					= ' '

		exec utl_Insert_ErrorLog @ErrorNum, @ErrorMsg, @ErrorProc, 'CardVIP', 'GET', @SessionID, @AddlInfo
	end catch