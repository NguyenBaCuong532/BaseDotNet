
CREATE procedure [dbo].[sp_user_prod_async]
	 @userId		uniqueidentifier	= '85228acd-1cc9-4b5e-b12d-e36913b460c2'
    ,@userName		nvarchar(100) = 'hoanpv3'
    ,@fullName		nvarchar(200) = 'Phạm Văn Hoàn'
    ,@orgId			uniqueidentifier ='51F67C15-28E1-4A6D-ABB0-CB58CE5DC0E0'
	,@active		bit = 1
	,@usersync		uniqueidentifier = null
    ,@admin_st		bit = null
	,@emp_code		nvarchar(50) = null
	,@categoryIds	nvarchar(max) = null
	,@workplaces	nvarchar(max) = null
	,@phone			nvarchar(50) = null
	,@email			nvarchar(250) = null
	,@role_sync		bit = 0
	,@webId			uniqueidentifier = null
	--,@tbOrgs		UserCategoryType readonly
as
begin
	declare @valid bit = 1
	declare @messages nvarchar(100) = N'Cập nhật thành công'

	begin try
		declare @tbWorkplaces table
		(
			projectCd nvarchar(50)
		)
		declare @tbOrgs table
		(
			subProjectCd nvarchar(50)
		)
		--declare @phone nvarchar(50),@email nvarchar(250)
		declare @custId uniqueidentifier 
		--select top 1 @custId = Oid 
		--	,@phone = isnull(@phone,e.PhoneNumbers)
		--	,@email = isnull(@phone,@email)
		-- from EmployeeMaintenance e 
		--		where e.EmployeeID = @emp_code and e.GCRecord IS NULL AND e.Organization IS NOT NULL

		insert @tbOrgs
		select try_cast([Value] as nvarchar(50)) 
		from dbo.fn_SplitString(@categoryIds,',')

		insert @tbWorkplaces
		select try_cast([Value] as nvarchar(50)) 
		from dbo.fn_SplitString(@workplaces,',')

		--cms user
		if not exists(select 1 from Users where userid = cast(@userId as nvarchar(50)))
            begin
                INSERT INTO [dbo].Users
				   ([userId]
				   ,[loginName]
				   ,[fullName]
				   ,[active]
				   ,[orgId]
				   ,[created_by]
				   ,[created_dt]
                   ,admin_st
				   ,custId
				   ,position
				   ,phone
				   ,email
				   )
				select
				   cast(@userId as nvarchar(50))
				   ,@userName
				   ,@fullName
				   ,@active
				   ,@orgId
				   ,cast(@usersync as nvarchar(50))
				   ,getdate()
                   ,@admin_st
				   ,@custId
				   ,@emp_code
				   ,@phone
				   ,@email
				 --from EmployeeMaintenance e
				 --  where Oid = @custId

            end
			else
            begin
                UPDATE [dbo].Users
				SET [active]	= @active
                    ,orgId		= @orgId
					,[fullName]	= @fullName
					,[last_dt]	= getdate()
                    ,admin_st	= @admin_st
					,custId		= @custId
					,position	= @emp_code
					,phone		= @phone
					,email		= @email
				--from EmployeeMaintenance c
				WHERE userid = cast(@userId as nvarchar(50))
				--and c.Oid = @custId
            end
		
		if @active = 1 and @role_sync = 1
		begin
      
		--phan quyen cong ty tra luong
			delete x from UserProject x
				where [userId] = cast(@userId as nvarchar(50)) 
				and not exists(select 1 from @tbWorkplaces where projectCd = x.projectCd)
			
			INSERT INTO [dbo].UserProject
				   ([userId]
				   ,[projectCd]
				   ,[created]
				   ,[created_by]
				   )
			 SELECT cast(@userId as nvarchar(50))
				   ,projectCd
				   ,getdate()
				   ,cast(@usersync as nvarchar(50))
			 from @tbWorkplaces c
			 where not exists(select 1 from UserProject 
				where [userId] = cast(@userId as nvarchar(50)) and projectCd = c.projectCd)
			

			--phan quyen to chuc
			delete x from UserSubProject x
				where [userId] = cast(@userId as nvarchar(50)) 
				and not exists(select 1 from @tbOrgs where subProjectCd = x.subProjectCd)
			
			INSERT INTO [dbo].UserSubProject
				   ([userId]
				   ,[subProjectCd]
				   ,[created]
				   ,[created_by]
				   )
			 SELECT cast(@userId as nvarchar(50))
				   ,subProjectCd
				   ,getdate()
				   ,cast(@usersync as nvarchar(50))
			 from @tbOrgs c
			 where not exists(select 1 from UserSubProject 
				where [userId] = cast(@userId as nvarchar(50)) and subProjectCd = c.subProjectCd)
		end
		------link user
		
	end try
	begin catch
		declare	@ErrorNum				int,
				@ErrorMsg				varchar(200),
				@ErrorProc				varchar(50),

				@SessionID				int,
				@AddlInfo				varchar(max)

		set @ErrorNum					= error_number()
		set @ErrorMsg					= 'sp_user_prod_async ' + error_message()
		set @ErrorProc					= error_procedure()

		set @AddlInfo					= ' - @userId ' 
		set @valid = 0
		set @messages = error_message()

		exec utl_ErrorLog_Set @ErrorNum, @ErrorMsg, @ErrorProc, 'sp_user_prod_async', 'GET', @SessionID, @AddlInfo
	end catch


	FINAL:
	select @valid as valid
		   ,@messages [messages]
end