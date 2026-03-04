
CREATE   PROCEDURE [dbo].[sp_res_apartment_status_get]
	 @UserID		uniqueidentifier
	,@apartId		uniqueidentifier
	,@acceptLanguage NVARCHAR(50) = N'vi-VN'
as
	begin try		
		
		select e.oid as apartId
			  ,e.RoomCode as code
			  ,fullName			= c.fullName
			  ,avatarUrl		= c.avatarUrl 
			  ,apartStatus		= case when e.IsRent = 1 then N'<span class="bg-warning noti-number ml5">Cho thuê</span>' 
									when e.IsLock = 1 then N'<span class="bg-warning noti-number ml5">Bị khóa</span>'
									else s.[objClass] end
			  ,created_by		= us.fullName
			  --,tab_st			= case when isnull(e.profile_st,0) = 0 then 0 
					--				 when isnull(e.working_st,0) = 0 then 1
					--				 when isnull(co.contract_st,0) = 0 then 2
					--				 when isnull(e.insurance_st,0) = 0 then 3
					--				 when isnull(e.train_st,0) = 0 then 4
					--				 else 5 end
			 ,created			= e.created_at
			 ,updated			= e.lastReceived
		 from MAS_Apartments e
            join UserInfo c on e.UserLogin = c.loginName
			left join Users us on e.created_by = us.userId
			left join dbo.fn_config_data_gets_lang('apartment_status', @acceptLanguage) s on e.IsReceived = s.objValue
		where e.oid = @apartId 

	end try
	begin catch
		declare	@ErrorNum				int,
				@ErrorMsg				varchar(200),
				@ErrorProc				varchar(50),

				@SessionID				int,
				@AddlInfo				varchar(max)

		set @ErrorNum					= error_number()
		set @ErrorMsg					= 'sp_res_apartment_status_get ' + error_message()
		set @ErrorProc					= error_procedure()

		set @AddlInfo					= ''

		exec utl_ErrorLog_Set @ErrorNum, @ErrorMsg, @ErrorProc, 'apartment', 'Get', @SessionID, @AddlInfo
	end catch