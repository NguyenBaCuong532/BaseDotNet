


CREATE   procedure [dbo].[sp_app_point_home]
	 @userId uniqueidentifier 
	,@acceptLanguage nvarchar(50) = 'vi-VN'
as
	begin try
		if @userId = 'd9898e79-a628-42e9-b8c7-5986472b3dc8' set @userId = '24adb0fd-2267-452a-8833-7c0293420e99'

		SELECT [PointCd] as pointId
			  ,[PointType]
			  ,p.[CustId]
			  ,[CurrPoint]
			  ,[LastDt]
			  ,c.FullName as fullName
			  ,c.Phone as phone
			  ,pointImgUrl = N'/images/app_icons/module/bg-point.svg'
		  FROM [MAS_Points] p
		  Join MAS_Customers c on c.CustId = p.CustId
		  where exists(select 1 
			from UserInfo x where x.custId = p.CustId 
			and x.userId = @userId)
		  

	end try
	begin catch
		declare	@ErrorNum				int,
				@ErrorMsg				varchar(200),
				@ErrorProc				varchar(50),

				@SessionID				int,
				@AddlInfo				varchar(max)

		set @ErrorNum					= error_number()
		set @ErrorMsg					= 'sp_app_point_home ' + error_message()
		set @ErrorProc					= error_procedure()

		set @AddlInfo					= ' - @userId ' --+ @userId

		exec utl_ErrorLog_Set @ErrorNum, @ErrorMsg, @ErrorProc, 'MAS_Points', 'GET', @SessionID, @AddlInfo
	end catch