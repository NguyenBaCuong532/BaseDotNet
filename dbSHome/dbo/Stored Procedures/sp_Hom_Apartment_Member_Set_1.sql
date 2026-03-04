
--select * from UserInfo where custId ='D4E0899B-5FCF-48D0-8577-BC5147491BAA'

--select ApartmentId from MAS_Apartments ma 
--						join UserInfo mu on ma.UserLogin = mu.UserLogin 
--							where mu.CustId = 'D4E0899B-5FCF-48D0-8577-BC5147491BAA' and ma.ApartmentId = 98978

CREATE procedure [dbo].[sp_Hom_Apartment_Member_Set]
	@UserID		nvarchar(450) = '81739c5c-2ca0-4e0f-acab-63373ea8a34a',
	@CustId		nvarchar(50) = 'D4E0899B-5FCF-48D0-8577-BC5147491BAA',
	@FullName	nvarchar(250) = 'Nguyễn Trọng Hiền',
	@Phone		nvarchar(30) ='0987669977',	
	@Email		nvarchar(150) = 'Phangiaht@gmail.com',
	@AvatarUrl	nvarchar(250) = '',
	@Birthday	nvarchar(10) = '05/01/1945',
	@IsSex			bit = 1,
	@ApartmentId	int = 
98978,
	@RelationId		int = 0,
	@IsForeign		bit = 0,
	@IsNotification bit = 0,
	@CountryCd		nvarchar(50) = 'VN'
as
begin
	declare @valid bit = 1
	declare @messages nvarchar(200) = N'Cập nhật thành công'

	begin try		
	BEGIN TRAN Hom_Apartment_Member_Set_trans
        declare @tnx_id nvarchar(450)
        declare @CategoryCd nvarchar(50)
        set @IsForeign = isnull(@IsForeign,0)
        
        if dbo.[fn_Hom_User_admin](@userId) = 1
            --or exists(select top 1 ApartmentId from [dbo].[fn_Hom_User_Apartment] (@userId) ua where IsHost = 1 
            --	or ua.custId = @CustId)
            begin
                if @Birthday like 'Invalid%'
                    set @Birthday = null

                set @CategoryCd = (Select c.ProjectCd from MAS_Apartments c where c.ApartmentId = @ApartmentId)

                IF (@CustId is null or @CustId = '') OR NOT EXISTS(SELECT CustId FROM [MAS_Customers] WHERE CustId = @CustId)
                    begin
							set @CustId = NEWID ()
							INSERT INTO [dbo].[MAS_Customers]
								([FullName]
								,[Phone]
								,[Email]
								,[IsHost]
								,[ApartmentId]
								,[AvatarUrl]
								,[IsSex]
								,birthday
								,sysDate
								,IsForeign
								,CustId
								,CountryCd
								)
								VALUES
                                (@FullName
                                ,@Phone
                                ,@Email
                                ,0
                                ,@ApartmentId
                                ,@AvatarUrl
                                ,@IsSex
                                ,convert(datetime,@Birthday,103)
                                ,getdate()
                                ,@IsForeign
                                ,@CustId
                                ,@CountryCd
                                )
                            
                        if @RelationId = 0
                            set @RelationId = 13

                        INSERT INTO [dbo].[MAS_Apartment_Member]
								([ApartmentId]
								,[CustId]
								,[RegDt]
								,RelationId
								,isNotification
                                ,memberUserId
								)
                            VALUES
                                (@ApartmentId
                                ,@CustId
                                ,getdate()
                                ,@RelationId
                                ,@isNotification
                                ,@UserID
                                )

                    end
                ELSE
                    begin
                    
					if not exists(select ApartmentId from MAS_Apartments ma 
						join UserInfo mu on ma.UserLogin = mu.loginName 
							where mu.CustId = @CustId and ma.ApartmentId = @ApartmentId)
					 begin
						if exists(select 1 from [MAS_Customers] where CustId = @CustId and Phone is not null and phone <> '' and Phone <> @Phone)
						begin -- xóa user
							UPDATE [MAS_Apartment_Member]
                                Set RelationId = @RelationId 
                                   ,isNotification = @isNotification
								   ,memberUserId = null
                            WHERE CustId = @CustId and ApartmentId = @ApartmentId
                       
							
							select @tnx_id = u.userId from UserInfo u join [MAS_Customers] c on u.CustId = c.CustId 
								where u.custid = @CustId and u.userType = 2
							if @tnx_id is not null
							begin
							--EXECUTE [dbo].[sp_COR_User_Profile_Save] 
							--   @UserId
							--  ,@tnx_id
							--  ,'Hom_Apartment_Member_Set'

							delete u from UserInfo u join [MAS_Customers] c on u.CustId = c.CustId 
								where u.custid = @CustId and u.userType = 2--and UserLogin like 'ssupapp_' + c.Phone 
							
							delete u from UserInfo u join [MAS_Customers] c on u.CustId = c.CustId 
								where u.custid = @CustId and u.userType = 2--and loginName like 'ssupapp_' + c.Phone 
							end
						end

                        UPDATE [dbo].[MAS_Customers]
                        SET 
                             FullName = isnull(@FullName,FullName)
							,Phone = isnull(@Phone,Phone)
							,Email = isnull(@Email,Email)
							,AvatarUrl = isnull(@AvatarUrl,AvatarUrl)
							,IsSex = isnull(@IsSex,IsSex)
							,birthday = case when @Birthday is null then birthday else convert(datetime,@Birthday,103) end
							,IsForeign = @IsForeign
							,CountryCd = @CountryCd
						WHERE CustId = @CustId

                        --set @CustomerId = @CustId
                         
                        if not exists(select custid from [MAS_Apartment_Member] where CustId = @CustId and ApartmentId = @ApartmentId)
                            begin
                                if @RelationId = 0
                                    set @RelationId = 13

                                INSERT INTO [dbo].[MAS_Apartment_Member]
                                    ([ApartmentId]
                                    ,[CustId]
                                    ,[RegDt]
                                    ,RelationId
                                    ,isNotification
                                    ,memberUserId
                                    )
                                VALUES
                                    (@ApartmentId
                                    ,@CustId
                                    ,getdate()
                                    ,@RelationId
                                    ,@isNotification
                                    ,@UserID
                                    )
                            end
                        else
                            UPDATE [MAS_Apartment_Member]
                                Set RelationId = @RelationId 
                                   ,isNotification = @isNotification
                            WHERE CustId = @CustId and ApartmentId = @ApartmentId
                    
                     

                    if not exists(select CategoryCd FROM MAS_Category_Customer r 
                            where r.CategoryCd = @CategoryCd and r.CustId = @CustId)
                        INSERT INTO [dbo].MAS_Category_Customer
                                (CategoryCd
                                ,CustId
                                ,[CreationTime]
                                ,userId
                                )
                        SELECT @CategoryCd
                                ,@CustId
                                ,getdate()
                                ,@UserID

                   end
				   else --Neu la chủ hộ không đc sửa
				     begin
                      print 'hoanpv11111111111'
						if exists(select 1 from [MAS_Customers] where CustId = @CustId and Phone = @Phone)
						begin
							UPDATE [dbo].[MAS_Customers]
							SET 
								 FullName = isnull(@FullName,FullName)
								--,Phone = isnull(@Phone,Phone)
								,Email = isnull(@Email,Email)
								,AvatarUrl = isnull(@AvatarUrl,AvatarUrl)
								,IsSex = isnull(@IsSex,IsSex)
								,birthday = case when @Birthday is null then birthday else convert(datetime,@Birthday,103) end
								,IsForeign = @IsForeign
								,CountryCd = @CountryCd
							WHERE CustId = @CustId

							UPDATE [MAS_Apartment_Member]
                                Set RelationId = @RelationId 
                                   ,isNotification = @isNotification
                                   ,memberUserId = @UserID
                            WHERE CustId = @CustId and ApartmentId = @ApartmentId

						end
						else
						begin
							set @valid = 0
							set @messages = N'Bạn không có quyền sử thông tin chủ hộ'
						end
				   end
				end
            end----
		else 
            begin
                set @valid = 0
                set @messages = N'Bạn không có quyền tạo, sửa thành viên'
            end

	commit tran Hom_Apartment_Member_Set_trans
END TRY
BEGIN CATCH
	rollback tran Hom_Apartment_Member_Set_trans

		declare	@ErrorNum				int,
				@ErrorMsg				varchar(200),
				@ErrorProc				varchar(50),

				@SessionID				int,
				@AddlInfo				varchar(max)

		set @ErrorNum					= error_number()
		set @ErrorMsg					= 'sp_Hom_Apartment_Member_Set ' + error_message()
		set @ErrorProc					= error_procedure()

		set @AddlInfo					= '@CustId ' + @CustId 
		set @valid = 0
		set @messages = error_message()

		exec utl_Insert_ErrorLog @ErrorNum, @ErrorMsg, @ErrorProc, 'Apartment', 'Set', @SessionID, @AddlInfo
	end catch

	select @valid as valid
		  ,@messages as [messages]
end