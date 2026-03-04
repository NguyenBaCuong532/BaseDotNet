
CREATE procedure [dbo].[sp_Hom_Card_Guest_Detail]
	@UserId		nvarchar(450),
	@cardCd		nvarchar(50)	= null
as
	begin try
	--1
		SELECT a.[CardCd]
			  ,format(a.[IssueDate],'dd/MM/yyyy hh:mm:ss') as [IssueDate]
			  ,format(a.[ExpireDate],'dd/MM/yyyy hh:mm:ss') as [ExpireDate]
			  ,s.[StatusName]
			  ,a.Card_St as [Status]
			  ,c.FullName as CustName
			  ,a.IsClose 
			  ,a.CloseDate 
			  ,c.Phone as CustPhone
			  ,c.Email
			  ,a.CardName
			  ,a.CustId
			  ,case when exists(select CardId from MAS_CardVehicle where cardid = a.CardId) then 1 else 0 end IsVehicle
			  ,p.projectName
			  ,a.ProjectCd
			  ,d.partner_name 
			  ,e.CardVehicleId
	  FROM [dbo].[MAS_Cards] a 
			join MAS_Customers c on a.CustId = c.CustId
			join MAS_CardStatus s on a.Card_St = s.StatusId
			join MAS_Projects p on a.ProjectCd = p.projectCd
			left join MAS_CardPartner d on a.partner_id = d.partner_id 
			left join MAS_CardVehicle e on e.cardid = a.CardId 
		WHERE a.IsGuest = 1
				and (CardCd like '%' + @cardCd + '%')
			--ORDER BY a.CardCd 
	  
	--2
	
	end try
	begin catch
		declare	@ErrorNum				int,
				@ErrorMsg				varchar(200),
				@ErrorProc				varchar(50),

				@SessionID				int,
				@AddlInfo				varchar(max)

		set @ErrorNum					= error_number()
		set @ErrorMsg					= 'sp_Hom_Card_Guest_Detail_ByManager ' + error_message()
		set @ErrorProc					= error_procedure()

		set @AddlInfo					= ' '

		exec utl_Insert_ErrorLog @ErrorNum, @ErrorMsg, @ErrorProc, 'CardGuestDetail', 'GET', @SessionID, @AddlInfo
	end catch