

CREATE procedure [dbo].[sp_Hom_Apartment_Member_Reject]
	@UserID			nvarchar(450),
	@ApartmentId	bigint,
	@memberUserId	nvarchar(100)
as
	begin try		
		declare @valid bit = 0
		declare @messages nvarchar(200) = N'Không tìm thấy thông tin'
		declare @notification bit = 0
		declare @notimessage nvarchar(300)

		if exists(select * from MAS_Apartment_Reg t
				join MAS_Apartments c on t.roomCode = c.RoomCode
			where t.userId = @memberUserId
				and c.ApartmentId = @apartmentId)
		begin
			Update t
				set reg_st = 2
			from MAS_Apartment_Reg t
				join MAS_Apartments c on t.roomCode = c.RoomCode
			where t.userId = @memberUserId
				and c.ApartmentId = @apartmentId
			set @valid = 1
			set @notification = 1
		end
		
		select @valid as valid
		      ,@messages as [messages]
			  ,@notification as notiQue

		if @notification = 1
		begin
			 
			select N'Xác nhận duyệt thành viên cư dân - Apartment Reject' as [subject]
				  ,N's-resident' as external_key--[Event]
				  ,N'Quý Khách bị từ chối phê duyệt thành viên căn hộ.'
					+ N' Mã căn hộ [' + a.RoomCode + N'], Dự án ' + b.ProjectName
					+ N' Mời quý khách đến khai báo tại văn phòng Ban QLTN tại tầng 1.'
					+ N' Trân trọng' as content_notify
				  ,null as content_email --[MessageEmail]
				  ,'push' as [action_list] --sms,email
				  ,'new' as [status]
				  ,a.projectCd as external_sub
				  ,[mailSender] as send_by
				  ,[investorName] as send_name
			FROM MAS_Apartments a
					join MAS_Projects b on a.projectCd = b.projectCd
				WHERE a.ApartmentId = @apartmentId 

			select b.memberUserId userId
				  ,phone 
				  ,email 
				  ,avatarUrl as Avatar
				  ,fullName 
				  ,1 as app
				  ,b.custId
			from UserInfo a
				join MAS_Apartment_Member b on a.custId = b.CustId
			where a.userId = @memberUserId
				and	b.ApartmentId = @apartmentId
				and b.member_st = 1

		end

	end try
	begin catch
		declare	@ErrorNum				int,
				@ErrorMsg				varchar(200),
				@ErrorProc				varchar(50),

				@SessionID				int,
				@AddlInfo				varchar(max)

		set @ErrorNum					= error_number()
		set @ErrorMsg					= 'sp_Hom_Apartment_Member_Reject ' + error_message()
		set @ErrorProc					= error_procedure()

		set @AddlInfo					= '@UserID ' + @UserID 

		exec utl_Insert_ErrorLog @ErrorNum, @ErrorMsg, @ErrorProc, 'Member', 'Reject', @SessionID, @AddlInfo
	end catch