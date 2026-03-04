



CREATE procedure [dbo].[sp_Hom_Request_Fields]
	@UserId nvarchar(450),
	@RequestId	int

as
	begin try
			--1
			SELECT a.RequestId 
				  ,a.[ApartmentId]
				  ,a.[Comment]
				  ,convert(nvarchar(5),a.[RequestDt],108) + ' - ' + convert(nvarchar(10),a.[RequestDt],103) as RequestDate 
				  ,a.RequestTypeId
				  ,isnull([Status],0) [Status]
				  ,a.thread_id
			  FROM [dbo].MAS_Requests a 
				Where a.requestId = @RequestId

				--2
				SELECT '1' as group_cd
					  ,N'Thông tin chung' as group_name 
				--3
				SELECT a.id
					  ,table_name
					  ,field_name
					  ,view_type
					  ,data_type
					  ,ordinal
					  ,columnLabel
					  ,'1' group_cd
					   ,case data_type when 'nvarchar' then convert(nvarchar(350), case field_name 
							when 'comment' then r.[Comment]
							when 'requestTypeName' then b.RequestTypeName
							when 'roomCode' then d.RoomCode
							when 'fullName' then e.FullName
							when 'projectName' then f.ProjectName
							when 'statusName' then s.statusName -- case isnull([Status],0) when 0 then N'Mới yêu cầu' when 1 then N'Đã phân công' when 2 then N'Đang xử lý' else N'Hoàn thành' end
							when 'projectCd' then f.ProjectCd
							when 'onTime' then convert(nvarchar(10),r.[AtTime],103) + ' ' + convert(nvarchar(5),r.[AtTime],108)
							when 'requestDate' then format(requestdt,'MM/dd/yyyy hh:mm:ss')
							when 'userLogin' then u.loginName
						  end
						  ) 
					  else convert(nvarchar(50),case field_name 
						  when 'requestTypeId' then b.RequestTypeId
						  when 'status' then r.Status
						  when 'isNow' then r.isNow
						  when 'requestId' then r.requestId
						  end) 
						end as columnValue
					  ,columnClass
					  ,columnType
					  ,columnObject
					  ,isSpecial
					  ,isRequire
					  ,isDisable
					  ,isVisiable
					  ,[IsEmpty]
					  ,isnull(a.columnTooltip,[columnLabel]) as columnTooltip
				  FROM sys_config_form a
					,[dbo].MAS_Requests r
						inner join MAS_Request_Types b ON r.RequestTypeId = b.RequestTypeId
						INNER JOIN MAS_Apartments d On r.ApartmentId = d.ApartmentId 
						inner join UserInfo u on r.requestUserId = u.UserId 
						inner join MAS_Customers e On e.Custid = u.CustId
						inner join MAS_Rooms rr on d.RoomCode = rr.RoomCode 
						inner join MAS_Buildings f on rr.BuildingCd = f.BuildingCd 
						left join CRM_Status s on r.status = s.statusId and statusKey ='Request'
					  WHERE r.RequestId = @RequestId 
						and a.table_name = 'MAS_Requests' 
						and (a.isVisiable = 1 or a.isRequire =1)
				  order by ordinal

			--4
			SELECT [id]
				  ,[requestId]
				  ,[processId]
				  ,[attachUrl]
				  ,[attachType]
				  ,attachFileName
				  ,1 as used
				  ,[createDt]
			  FROM [dbSHome].[dbo].MAS_Request_Attach
			  where [requestId] = @RequestId and processId = 0
	
		
			--5
			SELECT [assignRole]
				  ,[assignRoleName]
			  FROM [CRM_Assign_Role]
			--6
			SELECT a.[Id]
				  ,a.requestId
				  ,a.[userId]
				  ,a.[assignRole]
				  ,b.loginName as userName
				  ,1 as Used
				  ,isnull(b.fullName,c.fullName) as fullName
				  ,b.avatarUrl
				  ,isnull(b.phone ,c.phone) as phone
				  ,isnull(b.email,c.email) as email
			  FROM MAS_Request_Assign a
			  join UserInfo b on a.userId = b.userId 
			  join MAS_Customers c on b.custId = c.CustId
				WHERE a.requestId = @requestId

	end try
	begin catch
		declare	@ErrorNum				int,
				@ErrorMsg				varchar(200),
				@ErrorProc				varchar(50),

				@SessionID				int,
				@AddlInfo				varchar(max)

		set @ErrorNum					= error_number()
		set @ErrorMsg					= 'sp_Hom_Request_Fields ' + error_message()
		set @ErrorProc					= error_procedure()

		set @AddlInfo					= ' '

		exec utl_Insert_ErrorLog @ErrorNum, @ErrorMsg, @ErrorProc, 'RequestFix', 'GET', @SessionID, @AddlInfo
	end catch