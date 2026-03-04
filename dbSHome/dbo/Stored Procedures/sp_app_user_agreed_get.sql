



CREATE   procedure [dbo].[sp_app_user_agreed_get]
    @userId uniqueidentifier = null,
	@acceptLanguage nvarchar(50) = null,
	@clientId nvarchar(30) = ''
as
	begin try
          if not exists(select 1 from UserAgree where userid = @userId )
            begin
                INSERT INTO [dbo].UserAgree
			           ([userId]
			           ,[reg_dt]
			           ,[last_dt]
			           ,[confirm_dt]
			           ,[confirm_cd]
			           ,[agreed_st]
			           ,[agreed_dt]
			           ,[signed_st]
			           ,[signed_dt])
		            SELECT @userId
			               ,getdate()
			               ,null
			               ,null
			               ,null
			               ,[agreed_st] = 0
			               ,null
			               ,0
			               ,null
			    --        FROM cust_info
			    --WHERE userid = @userId
            end

        SELECT a.userId
			  ,a.[reg_dt]
			  ,a.[last_dt]
			  ,isnull(a.[agreed_st],0) as [agreed_st]
			  --, 0 as [agreed_st]
			  ,a.[agreed_dt]
			  ,valid		= case when datediff(year,isnull('1993-05-11', getdate()),getdate()) < 18 then 0 else 1 end 
			  ,[messages]	= case when datediff(year,isnull('1993-05-11', getdate()),getdate()) < 18 then N'Quý khách chưa đủ tuổi, để thực hiện hợp đồng dân sự' else '' end 
			  --,term_content	=  dbo.fn_Get_TC(@clientId)
		  FROM UserAgree a 
			WHERE a.[userId] = @userId 
			        

	end try
	begin catch
		declare	@ErrorNum				int,
				@ErrorMsg				varchar(200),
				@ErrorProc				varchar(50),

				@SessionID				int,
				@AddlInfo				varchar(max)

		set @ErrorNum					= error_number()
		set @ErrorMsg					= 'sp_UserAgreed_get ' + error_message()
		set @ErrorProc					= error_procedure()

		set @AddlInfo					= ' '

		EXEC utl_ErrorLog_Set @ErrorNum, @ErrorMsg, @ErrorProc, 'UserAgree', 'Insert', @SessionID, @AddlInfo
	end catch