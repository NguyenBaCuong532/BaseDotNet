






CREATE procedure [dbo].[sp_Hom_App_Apartment_Reg]
	@userId		nvarchar(550),
	@roomCode	nvarchar(30),	
	@contractNo	nvarchar(30),
	@relationId	int,
	@id bigint = 0
	
as
	begin try	
	declare @valid bit = 1
	declare @messages nvarchar(200)
	declare @notification bit = 1
	declare @notimessage nvarchar(300)
	declare @mailmessage nvarchar(500)

	declare @apartmentId bigint
	declare @custId nvarchar(100)
	declare @projectCd nvarchar(30)
	declare @sub_projectCd nvarchar(30)

	select @projectCd = a.projectCd
		  ,@sub_projectCd = a.sub_projectCd
		FROM [MAS_Apartments] a 
		where RoomCode = @roomCode

	if not exists(select roomcode from [MAS_Apartment_Reg] 
			where (userId = @userId and roomCode = @roomCode) or id = @id)
		begin
		INSERT INTO [dbo].[MAS_Apartment_Reg]
			   ([userId]
			   ,[roomCode]
			   ,[contractNo]
			   ,[reg_dt]
			   ,[reg_st]
			   ,relationId
			   )
		 VALUES
			   (@userId
			   ,@roomCode
			   ,@contractNo
			   ,getdate()
			   ,0
			   ,@relationId
			   )
		end
		else
		begin
			UPDATE t
			  Set contractNo = @contractNo
				 ,relationId = @relationId
				 ,reg_dt = getdate()
				 ,reg_st = 0
				 ,roomCode = @roomCode
			FROM [dbo].[MAS_Apartment_Reg] t
			WHERE (userId = @userId 
				and (roomCode = @roomCode) 
				or id = @id)
				--and reg_st = 0
			
			set @notification = 1
		end

		if exists(select * from [dbo].[MAS_Apartment_Reg] a 
			join MAS_Apartments b on a.roomCode = b.RoomCode 
			join UserInfo c on a.userId = c.UserId and c.Phone = b.UserLogin and c.userType = 2
			where a.roomCode = @roomCode and a.userId = @userId)
		begin
			select @apartmentId = a.ApartmentId, @custId = u.CustId FROM [MAS_Apartments] a 
					join UserInfo u on a.UserLogin = u.loginName 
					  WHERE exists(select userId from UserInfo 
						where userid = @UserId and CustId = u.CustId )
						and a.RoomCode = @roomCode
			exec [dbo].sp_res_apartment_home_member_approve 
				   @UserID
				  ,@apartmentId
				  ,@CustId
				  ,@UserID

			set @notification = 0
		end

		select @valid as valid
		      ,@messages as [messages]
			  ,@notification as notiQue

		if @notification = 1
		begin
			select @notimessage = N'Khách hàng đăng ký cư dân thành viên.'
					+ N' Yêu cầu phê duyệt vào căn hộ [' + a.RoomCode + N'], Dự án ' + b.ProjectName 
					+ N' Khách hàng tên: '+ isnull(u.fullName,'') + N', điện thoại: '+ u.phone +'!' 
					+ N' Trân trọng!'
				  ,@mailmessage = N'Khách hàng đăng ký cư dân thành viên.' + '<br />'
					+ N' Yêu cầu phê duyệt vào căn hộ [' + a.RoomCode + N'], Dự án ' + b.ProjectName +  '<br />'
					+ N' Khách hàng tên: '+ isnull(u.fullName,'') + N', điện thoại: '+ u.phone +'!' + '<br />'
					+ N' Trân trọng!'
				FROM MAS_Apartments a
					join MAS_Projects b on a.projectCd = b.projectCd,
					UserInfo u 
				WHERE a.RoomCode = @roomCode and u.userid = @UserId
			 
			select N'Khách hàng đăng ký cư dân - Apartment Register' as [subject]
				  ,N's-resident' as external_key--[Event]
				  ,@notimessage as content_notify
				  --,@notimessage as [MessageNotify]
				  --,[dbo].[fuConvertToUnsign1] (@notimessage) as [MessageSms]
				  ,@mailmessage as content_email --[MessageEmail]
				  ,'push,email' as [action_list] --sms,email
				  ,'new' as [status]
				  --,getdate() as CreatedDate
				  --,@userId as userId
				  ,projectCd as external_sub
				  ,[mailSender] as send_by
				  ,[investorName] as send_name
			FROM [MAS_Projects]
			 where sub_projectCd = @sub_projectCd

			--SELECT a.[userId] 
			--	  ,b.phone 
			--	  ,isnull(b.email,cc.email) as email
			--	  ,b.avatarUrl as Avatar
			--	  ,b.fullName as Name
			--	  ,1 as app
			--	  ,b.custId
			--FROM [dbAppManager].[dbo].[UserConsultant] AS a 
			--	 JOIN dbSSBigTec.dbo.[gr009mb] AS b ON a.userid = b.userid
			--	 JOIN dbSSBigTec.dbo.[gr002mb] AS c ON a.[sub_prod_cd] = c.[sub_prod_cd]		
			--	 join MAS_Customers cc on b.custId = cc.CustId	 
			--	 join [dbAppManager].[dbo].UserRoleProd rl on a.consultant_id = rl.consultant_id
			--	WHERE rl.sub_prod_cd = '005001' and isnull(cc.email,b.email) !='thangdq@sunshinegroup.vn'
			--		and a.consultant_st = 1
			--		and ((a.user_type = 'manager') or (a.user_type = 'operator' and exists(select 1 from [dbAppManager].[dbo].[UserRoleChat] ch join [dbAppManager].[dbo].AppRoleChats ac on ac.id = ch.appRoleChatId 
			--				where consultant_id =a.consultant_id
			--					and ac.chat_cd = '0503'))
			--					)
			--		and (a.project_managers is null or @projectCd = '' or exists(select 1 from [dbAppManager].[dbo].UserRoleProject where project_cd = @projectcd and consultant_id = a.consultant_id and sub_prod_cd = rl.sub_prod_cd))
			--		and b.userType = 2
			----
			--union all
			--select b.[userId] 
			--	  ,b.phone 
			--	  ,isnull(cc.email,b.email) as email
			--	  ,b.avatarUrl as Avatar
			--	  ,b.fullName as Name
			--	  ,0 as app
			--	  ,b.custId
			--from [dbAppManager].[dbo].[AppRoleChats] a
			--	join [dbAppManager].[dbo].UserWebChat c on a.id = c.appRoleChatId
			--	join dbSSBigTec.dbo.[gr009mb] AS b ON c.userid = b.userid
			--	join MAS_Customers cc on b.custId = cc.CustId
			-- WHERE a.mod_cd = '005001' and isnull(cc.email,b.email) !='thangdq@sunshinegroup.vn'
			--	and a.chat_cd = '0503'
			--	and (exists(select u.categoryCd from [dbSHome].[dbo].[MAS_Category_User] u 
			--		where u.UserId = b.userId and u.webId = '77929A9C-3085-4158-AE32-320A67704899' and u.isAll = 0 
			--		and (u.categoryCd = @projectCd))
			--		or exists(select n.categoryCd from [dbSHome].[dbo].[MAS_Category_User] u join [dbSHome].[dbo].MAS_Category n on n.base_type = u.base_type 
			--		where u.UserId = b.userId and u.webId = '77929A9C-3085-4158-AE32-320A67704899' and u.isAll = 1
			--		and (n.categoryCd = @projectCd))
			--		)
			--	and not exists(SELECT aa.consultant_id 
			--		from [dbAppManager].[dbo].[UserConsultant] AS aa 
			--	 JOIN dbSSBigTec.dbo.[gr009mb] AS bb ON aa.userid = bb.userid
			--	 JOIN dbSSBigTec.dbo.[gr002mb] AS c2 ON aa.[sub_prod_cd] = c2.[sub_prod_cd]		
			--	 join MAS_Customers c3 on bb.custId = c3.CustId	 
			--	 join [dbAppManager].[dbo].UserRoleProd rl on aa.consultant_id = rl.consultant_id
			--	WHERE rl.sub_prod_cd = '005001'
			--		and aa.consultant_st = 1
			--		and ((aa.user_type = 'manager') or (aa.user_type = 'operator' and exists(select 1 from [dbAppManager].[dbo].[UserRoleChat] ch join [dbAppManager].[dbo].AppRoleChats ac on ac.id = ch.appRoleChatId 
			--				where consultant_id =aa.consultant_id
			--					and ac.chat_cd = '0503'))
			--		)
			--		and (aa.project_managers is null or @projectCd = '' or exists(select 1 from [dbAppManager].[dbo].UserRoleProject where project_cd = @projectcd and consultant_id = aa.consultant_id and sub_prod_cd = rl.sub_prod_cd))
			--		and (c3.CustId = cc.CustId or c3.Email = cc.Email)
			--		)

			--union all
			select u2.[userId]
				  ,u2.phone 
				  ,u2.email
				  ,u2.avatarUrl as Avatar
				  ,u2.fullName as Name
				  ,1 as app
				  ,u.custId
			FROM [MAS_Apartments] a 
				join MAS_Apartment_Member u on a.ApartmentId = u.ApartmentId 
				join UserInfo u2 on u.CustId = u2.custId and u2.userType = 2
			WHERE a.RoomCode = @roomCode
				and u.member_st = 1
				and a.IsReceived = 1
				and exists(select 1 from UserInfo u1 where u1.custId = u.CustId and u1.loginName = a.UserLogin)
				and @RelationId > 1

		end

	end try
	begin catch
		declare	@ErrorNum				int,
				@ErrorMsg				varchar(200),
				@ErrorProc				varchar(50),

				@SessionID				int,
				@AddlInfo				varchar(max)

		set @ErrorNum					= error_number()
		set @ErrorMsg					= 'sp_Hom_App_Apartment_Reg' + error_message()
		set @ErrorProc					= error_procedure()

		set @AddlInfo					= ''

		exec utl_Insert_ErrorLog @ErrorNum, @ErrorMsg, @ErrorProc, 'ApartmentReg', 'Set', @SessionID, @AddlInfo
	end catch