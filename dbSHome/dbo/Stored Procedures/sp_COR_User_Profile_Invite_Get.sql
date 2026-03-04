
CREATE procedure [dbo].[sp_COR_User_Profile_Invite_Get]
	@UserId nvarchar(450)

as
	begin try	

	SELECT a.Reg_UserId 
		  ,i.fullName 
		  ,i.[avatarUrl] as avatarUrl
		  ,i.userId 
		  ,i.referralCd 
		  ,i.phone 
		  ,i.email 
		  ,datediff(second,{d '1970-01-01'} ,isnull(i.invited_at,i.created_dt)) as invited_at
		  ,i.fb_linked
		  ,i.fb_id
		  ,i.fb_name
		  --,c.objName saler_type_name
		  --,d.objName as region_name
		  --,s.saler_id
		  --,s.rating
		  ,qr_code_url = 'https://qr.ksfinance.net/me/'+i.referralCd
		  --,s.org_id
	FROM UserInfo a
		left join MAS_Customers g on a.custId = g.CustId
		join UserInfo i on a.invited_by = i.referralCd 
		--join agency_saler_mb s on i.userId = s.userId and s.saler_st = 1
		--left join [dbo].[fn_ca804pb_gets] ('saler_type') c on s.saler_type = c.[objvalue]
		--left join [dbo].[fn_ca804pb_gets] ('core_agent_region_group') d on s.region_id = d.[objvalue]
	WHERE a.userId = @UserId

	
	end try
	begin catch
		declare	@ErrorNum				int,
				@ErrorMsg				varchar(200),
				@ErrorProc				varchar(50),

				@SessionID				int,
				@AddlInfo				varchar(max)

		set @ErrorNum					= error_number()
		set @ErrorMsg					= 'sp_COR_User_Profile_Invite_Get ' + error_message()
		set @ErrorProc					= error_procedure()

		set @AddlInfo					= '@UserId ' + @UserId 

		exec utl_ErrorLog_Set @ErrorNum, @ErrorMsg, @ErrorProc, 'UserInvited', 'Set', @SessionID, @AddlInfo
	end catch