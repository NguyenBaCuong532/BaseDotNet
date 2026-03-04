




CREATE procedure [dbo].[sp_User_Get_Action_EmailTemplate]
	@UserName nvarchar(150),
	@RequestType int,
	@lastMessage nvarchar(400)
as
	begin try
	declare @Subject nvarchar(100)
	declare @Contents nvarchar(max)
	declare @Emails nvarchar(300)
	declare @ProjectName nvarchar(100)
	declare @RoomCode nvarchar(50)
	declare @FullName nvarchar(200)
	declare @Phone nvarchar(30)
	declare @Notification nvarchar(400)

		SELECT 
		   @RoomCode = a.[RoomCode]
		  ,@ProjectName = ProjectName 
		  ,@FullName = d.FullName
		  ,@Phone = isnull(d.Phone,0)
		  
		  FROM [MAS_Apartments] a 
				  inner join MAS_Contacts b on a.Cif_No = b.Cif_No 
				  inner join MAS_Rooms r on a.RoomCode = r.RoomCode
				  inner join MAS_Buildings c on r.BuildingCd = c.BuildingCd 
				  inner join UserInfo u on a.UserLogin = u.loginName
				  inner join MAS_Customers d on u.CustId = d.CustId
		  where u.loginName = @UserName 
		
		set @Emails = (Select top 1 Emails from PAR_RequestActionEmail 
					   )

		set @Subject =  N'[Thông báo] Có yêu cầu khách hàng ' + isnull(@ProjectName ,'')
		set @Contents = N'<h4>Yêu cầu từ dự án ' + isnull(@ProjectName,'') + '</h4>'
				+ '<Table>'
				+ '<tbody>'
				+ '<tr>'
				+ '<td>'+N'Khách hàng:'+'</td>'
				+ '<td>'+@FullName+'</td>'
				+ '</tr>'
				+ '<tr>'
				+ '<td>'+N'Số ĐT:'+'</td>'
				+ '<td>'+@Phone+'</td>'
				+ '</tr>'
				+ '<tr>'
				+ '<td>'+N'Chủ căn hộ:'+'</td>'
				+ '<td>'+@RoomCode+'</td>'
				+ '</tr>'
				+ '<tr>'
				+ '<td>'+N'Nội dung yêu cầu:'+'</td>'
				+ '<td><b>'+@lastMessage+'</b></td>'
				+ '</tr>'
				
				+ '</tbody></Table>'
			+ N'<br /><p>Regards!,<br />Trigger Request Action</p>' 
		set @Notification = N'Yêu cầu từ dự án ' + isnull(@ProjectName,'') + ''
				+ '
				'+N'Khách hàng:'+@FullName+''
				+ '
				'+N'Chủ căn hộ:'+@RoomCode+''
				+ '
				'+N'Nội dung yêu cầu:'+@lastMessage+''

	SELECT   @Emails as [To]
			,@Subject as [Subject]
			,@Contents as Contents
			,'html' as BodyType
			,'no-reply@sunshinemail.vn' as SendBy
			,'SUNSHINE TECH' as SendName
			,0 as SendType

	
	end try
	begin catch
		declare	@ErrorNum				int,
				@ErrorMsg				varchar(200),
				@ErrorProc				varchar(50),

				@SessionID				int,
				@AddlInfo				varchar(max)

		set @ErrorNum					= error_number()
		set @ErrorMsg					= ' ' + error_message()
		set @ErrorProc					= error_procedure()

		set @AddlInfo					= ''

		exec utl_Insert_ErrorLog @ErrorNum, @ErrorMsg, @ErrorProc, 'Mail', 'Get', @SessionID, @AddlInfo
	end catch