


CREATE procedure [dbo].[sp_res_elevator_card_evevate_get]
	@UserId		UNIQUEIDENTIFIER = NULL,
	@Code		nvarchar(50)='2913553526',
	@cardtype	int = 1,
	@mode		int				= 0,
	@HardwareId nvarchar(200) ='nfc-406043',
	@acceptLanguage NVARCHAR(50) = N'vi-VN'
as
	begin try	
	declare @er int
	declare @StationId int
	declare @CardCd nvarchar(30)
	declare @id bigint

	if @cardtype = 5 ---- token info
	begin
		if exists(select 1 from [MAS_Elevator_Log] where HardwareId = @HardwareId and userId = @UserId)
			UPDATE [dbo].[MAS_Elevator_Log]
			   SET [LogDt] = getdate()
			 WHERE HardwareId = @HardwareId and userId = @UserId
		else
			INSERT INTO [dbo].[MAS_Elevator_Log]
				   ([HardwareId]
				   ,[userId]
				   ,[LogDt])
			 VALUES
				   (@HardwareId
				   ,@UserId
				   ,getdate())

		SELECT @Code as [CardCd]
			  --,convert(nvarchar(10),a.[IssueDate],103) IssueDate
			  --,convert(nvarchar(10),a.[ExpireDate],103) [ExpireDate]
			  ,@cardtype as card_type
			  ,@HardwareId as reader_id
			  ,@Code as card_code
			  ,1 as open_gate
			  ,upper(d.HardwareId) as hardware_id
			  ,d.ElevatorBank as elevator_bank
			  ,d.ElevatorShaftNumber as elevator_shaft_number
			  ,d.ElevatorShaftName as elevator_shaft_name  
			  --,a.CardId 
		FROM MAS_Customers c
			join UserInfo u on c.CustId = u.custId
			left join MAS_Elevator_Device d on HardwareId = @HardwareId and IsActived = 1
		WHERE u.userId = @UserId
			and (
				exists(select * from MAS_Apartment_Member m where m.CustId = u.CustId and m.member_st = 1)
				)

		set @id = (select top 1 id from MAS_Elevator_User eu where eu.userid = @UserId order by sysDt desc) --and sysDt > dateadd(minute,-1,getdate())

		if @id > 0 and exists(SELECT t.[FloorName]
				  ,t.[FloorNumber] as FloorNum
				  ,t.FloorType 
			  FROM [MAS_Elevator_Floor] t
				join MAS_Elevator_Device d on d.ProjectCd = t.ProjectCd and d.BuildZone = t.BuildZone
			   ,UserInfo u 
			  WHERE d.HardwareId = @HardwareId 
					and d.IsActived = 1
					and u.userId = @UserId
					and (
						exists(select * from MAS_Apartment_Member m where m.CustId = u.CustId and m.member_st = 1)
						)
					and exists(SELECT a.[CardCd]
						FROM [dbo].[MAS_Cards] a 
						WHERE (custId = u.custId) 
							and a.Card_St = 1
							and (T.FloorType = 'CC'
								or ((a.CardTypeId = 1 or a.CardTypeId = 3) 
									and (exists(select 1 from MAS_Apartment_Card ac 
										join MAS_Apartments ma on ac.ApartmentId = ma.ApartmentId 
										LEFT JOIN MAS_Buildings mb ON ma.buildingOid = mb.oid 
										LEFT JOIN MAS_Elevator_Floor ef ON ma.floorOid = ef.oid
										where ac.CardId = a.CardId 
											and ma.IsReceived = 1
											and ma.isFeeStart = 1
											and ma.floorNo = t.[FloorName] and mb.ProjectCd = t.ProjectCd and mb.BuildingCd = t.buildingCd)
										)
									)
								or ((a.CardTypeId = 2 or exists(select Id from [MAS_Elevator_Card] ec where ec.CardId = a.CardId and ec.CardType = 2 and ec.CardRole = 1 and ec.ProjectCd = t.ProjectCd)) and t.FloorType = 'VP')
								or ((a.CardTypeId = 4) and t.FloorType = 'KK' and a.ProjectCd = t.ProjectCd)
								or (exists(select Id from [MAS_Elevator_Card] ec where ec.CardId = a.CardId and ec.CardRole = 2 and ec.ProjectCd = t.ProjectCd))
								or (exists(select Id from [MAS_Elevator_Card] ec where ec.CardId = a.CardId and ec.CardRole = 3 and ec.ProjectCd = t.ProjectCd and ec.AreaCd = t.AreaCd))
								or (exists(select Id from [MAS_Elevator_Card] ec where ec.CardId = a.CardId and ec.CardRole = 4 and ec.ProjectCd = t.ProjectCd and ec.AreaCd = t.AreaCd and ec.FloorNumber = t.FloorNumber))
								) 
							)
							and exists(select 1 from MAS_Elevator_User eu where eu.id = @id and eu.floorName = t.FloorName)
							)
				begin
				SELECT t.[FloorName]
					  ,t.[FloorNumber] as FloorNum
					  ,t.FloorType 
				  FROM [MAS_Elevator_Floor] t
					join MAS_Elevator_Device d on d.ProjectCd = t.ProjectCd and d.BuildZone = t.BuildZone
				   ,UserInfo u 
				  WHERE d.HardwareId = @HardwareId 
						and d.IsActived = 1
						and u.userId = @UserId
						and (
							exists(select * from MAS_Apartment_Member m where m.CustId = u.CustId and m.member_st = 1)
							)
						and exists(SELECT a.[CardCd]
							FROM [dbo].[MAS_Cards] a 
							WHERE (custId = u.custId) 
								and a.Card_St = 1
								and (T.FloorType = 'CC'
									or ((a.CardTypeId = 1 or a.CardTypeId = 3) 
										and (exists(select 1 from MAS_Apartment_Card ac 
											join MAS_Apartments ma on (ac.apartOid = ma.oid or (ac.apartOid is null and ac.ApartmentId = ma.ApartmentId))
											left join MAS_Elevator_Floor ef on ma.floorOid = ef.oid
											join MAS_Buildings mb on ma.buildingOid = mb.oid
											where ac.CardId = a.CardId 
												and ma.IsReceived = 1
												and ma.isFeeStart = 1
												and ISNULL(ef.FloorName, ma.floorNo) = t.[FloorName] and mb.ProjectCd = t.ProjectCd and mb.BuildingCd = t.BuildingCd)
											)
										)
									or ((a.CardTypeId = 2 or exists(select Id from [MAS_Elevator_Card] ec where ec.CardId = a.CardId and ec.CardType = 2 and ec.CardRole = 1 and ec.ProjectCd = t.ProjectCd)) and t.FloorType = 'VP')
									or ((a.CardTypeId = 4) and t.FloorType = 'KK' and a.ProjectCd = t.ProjectCd)
									or (exists(select Id from [MAS_Elevator_Card] ec where ec.CardId = a.CardId and ec.CardRole = 2 and ec.ProjectCd = t.ProjectCd))
									or (exists(select Id from [MAS_Elevator_Card] ec where ec.CardId = a.CardId and ec.CardRole = 3 and ec.ProjectCd = t.ProjectCd and ec.AreaCd = t.AreaCd))
									or (exists(select Id from [MAS_Elevator_Card] ec where ec.CardId = a.CardId and ec.CardRole = 4 and ec.ProjectCd = t.ProjectCd and ec.AreaCd = t.AreaCd and ec.FloorNumber = t.FloorNumber))
									) 
								)
							and exists(select 1 from MAS_Elevator_User eu where eu.id = @id and eu.floorName = t.FloorName)
		
			UPDATE [dbo].[MAS_Elevator_User]
			   SET [HardwareId] = @HardwareId
			 WHERE id = @id and [HardwareId] is null
		end
		else if @mode = 0 --multi select
			SELECT t.[FloorName]
				  ,t.[FloorNumber] as FloorNum
				  ,t.FloorType 
			  FROM [MAS_Elevator_Floor] t
				join MAS_Elevator_Device d on d.ProjectCd = t.ProjectCd and d.BuildZone = t.BuildZone
			   ,UserInfo u 
			  WHERE d.HardwareId = @HardwareId 
					and d.IsActived = 1
					and u.userId = @UserId
					and (
						exists(select * from MAS_Apartment_Member m where m.CustId = u.CustId and m.member_st = 1)
						)
					and exists(SELECT a.[CardCd]
						FROM [dbo].[MAS_Cards] a 
						WHERE (custId = u.custId) 
							and a.Card_St = 1
							and (T.FloorType = 'CC'
								or ((a.CardTypeId = 1 or a.CardTypeId = 3) 
									and (exists(select 1 from MAS_Apartment_Card ac 
										join MAS_Apartments ma on (ac.apartOid = ma.oid or (ac.apartOid is null and ac.ApartmentId = ma.ApartmentId))
										left join MAS_Elevator_Floor ef on ma.floorOid = ef.oid
										join MAS_Buildings mb on ma.buildingOid = mb.oid
										where ac.CardId = a.CardId 
											and ma.IsReceived = 1
											and ma.isFeeStart = 1
											and ISNULL(ef.FloorName, ma.floorNo) = t.[FloorName] and mb.ProjectCd = t.ProjectCd and mb.BuildingCd = t.BuildingCd)
										)
									)
								or ((a.CardTypeId = 2 or exists(select Id from [MAS_Elevator_Card] ec where ec.CardId = a.CardId and ec.CardType = 2 and ec.CardRole = 1 and ec.ProjectCd = t.ProjectCd)) and t.FloorType = 'VP')
								or ((a.CardTypeId = 4) and t.FloorType = 'KK' and a.ProjectCd = t.ProjectCd)
								or (exists(select Id from [MAS_Elevator_Card] ec where ec.CardId = a.CardId and ec.CardRole = 2 and ec.ProjectCd = t.ProjectCd))
								or (exists(select Id from [MAS_Elevator_Card] ec where ec.CardId = a.CardId and ec.CardRole = 3 and ec.ProjectCd = t.ProjectCd and ec.AreaCd = t.AreaCd))
								or (exists(select Id from [MAS_Elevator_Card] ec where ec.CardId = a.CardId and ec.CardRole = 4 and ec.ProjectCd = t.ProjectCd and ec.AreaCd = t.AreaCd and ec.FloorNumber = t.FloorNumber))
								) 
							)
				ORDER BY t.[FloorNumber]
		else	--single mode select
			SELECT top 1 t.[FloorName]
				  ,t.[FloorNumber] as FloorNum
				  ,t.FloorType 
			  FROM [MAS_Elevator_Floor] t
				join MAS_Elevator_Device d on d.ProjectCd = t.ProjectCd and d.BuildZone = t.BuildZone
			   ,UserInfo u 
			  WHERE d.HardwareId = @HardwareId 
					and d.IsActived = 1
					and u.userId = @UserId
					and (
						exists(select * from MAS_Apartment_Member m 
									join MAS_Apartments ma on (m.apartOid = ma.oid or (m.apartOid is null and m.ApartmentId = ma.ApartmentId))
									left join MAS_Elevator_Floor ef on ma.floorOid = ef.oid
									join MAS_Buildings mb on ma.buildingOid = mb.oid
							where m.CustId = u.CustId 
								and m.member_st = 1
								and (m.main_st = 1 or m.main_st is null)
								and ma.IsReceived = 1
								and ma.isFeeStart = 1
								and ISNULL(ef.FloorName, ma.floorNo) = t.[FloorName] and mb.ProjectCd = t.ProjectCd and mb.BuildingCd = t.BuildingCd
								)
						)					
				ORDER BY t.[FloorNumber]

	end
	else -- card info
	begin
		set @Code = right('0000000000' + @Code, 10)
		----loger
		if not exists(SELECT a.[CardCd]
			FROM [dbo].[MAS_Cards] a 
				join MAS_CardBase b on a.CardCd = b.Code 
			WHERE (Card_Num = @Code) 
				and (a.CardTypeId > 0 and a.CardTypeId < 5) 
				and a.Card_St = 1)
			begin
				set @er = 1+@cardtype
				--exec utl_Insert_ErrorLog @er, @HardwareId,'sp_Hom_ELE_Card_ByAccess', 'CardElevate', 'GET', '', @Code
			end
			else
			begin
				set @er = 0
				set @StationId = (select top 1 id from MAS_Elevator_Device where HardwareId = @HardwareId)
				set @CardCd = (select top 1 Code from MAS_CardBase where Card_Num = @Code)
				exec [dbo].sp_Hom_Card_LogReader_Set @StationId, @CardCd
			end
				
		
		--1 card info
		SELECT a.[CardCd]
			  ,convert(nvarchar(10),a.[IssueDate],103) IssueDate
			  ,convert(nvarchar(10),a.[ExpireDate],103) [ExpireDate]
			  ,a.CardTypeId as card_type
			  ,@HardwareId as reader_id
			  ,b.Card_Num as card_code
			  ,1 as open_gate
			  ,upper(d.HardwareId) as hardware_id
			  ,d.ElevatorBank as elevator_bank
			  ,d.ElevatorShaftNumber as elevator_shaft_number
			  ,d.ElevatorShaftName as elevator_shaft_name  
			  ,a.CardId 
		FROM [dbo].[MAS_Cards] a 
			join MAS_CardBase b on a.CardCd = b.Code 
			join MAS_Customers c on a.CustId = c.CustId
			left join MAS_Elevator_Device d on d.HardwareId = @HardwareId and d.IsActived = 1
		WHERE Card_Num = @Code 
			and (Card_St = 1)

		--Card Floor		
		SELECT t.[FloorName]
			  ,t.[FloorNumber] as FloorNum
			  ,t.FloorType 
		  FROM [MAS_Elevator_Floor] t
			join MAS_Elevator_Device d on d.ProjectCd = t.ProjectCd and d.BuildZone = t.BuildZone
		  WHERE d.HardwareId = @HardwareId 
				and d.IsActived = 1
				and exists(SELECT a.[CardCd]
					FROM [dbo].[MAS_Cards] a 
						join MAS_CardBase b on a.CardCd = b.Code 
					WHERE (Card_Num = @Code) 
						and a.Card_St = 1
						and (T.FloorType = 'CC'
							or ((a.CardTypeId = 1 or a.CardTypeId = 3) 
								and (exists(select 1 from MAS_Apartment_Card ac 
									join MAS_Apartments ma on (ac.apartOid = ma.oid or (ac.apartOid is null and ac.ApartmentId = ma.ApartmentId))
									left join MAS_Elevator_Floor ef on ma.floorOid = ef.oid
									join MAS_Buildings mb on ma.buildingOid = mb.oid
									where ac.CardId = a.CardId 
										and ma.IsReceived = 1
										and ma.isFeeStart = 1
										and ISNULL(ef.FloorName, ma.floorNo) = t.[FloorName] and mb.ProjectCd = t.ProjectCd and mb.BuildingCd = t.BuildingCd)
									)
								)
							or ((a.CardTypeId = 2 or exists(select Id from [MAS_Elevator_Card] ec where ec.CardId = a.CardId and ec.CardType = 2 and ec.CardRole = 1 and ec.ProjectCd = t.ProjectCd)) and t.FloorType = 'VP')
							or (a.CardTypeId in (2,4) and t.FloorType = 'KK' and a.ProjectCd = t.ProjectCd)
							or (exists(select Id from [MAS_Elevator_Card] ec where ec.CardId = a.CardId and ec.CardRole = 2 and ec.ProjectCd = t.ProjectCd))
							or (exists(select Id from [MAS_Elevator_Card] ec where ec.CardId = a.CardId and ec.CardRole = 3 and ec.ProjectCd = t.ProjectCd and ec.AreaCd = t.AreaCd))
							or (exists(select Id from [MAS_Elevator_Card] ec where ec.CardId = a.CardId and ec.CardRole = 4 and ec.ProjectCd = t.ProjectCd and ec.AreaCd = t.AreaCd and ec.FloorNumber = t.FloorNumber))							
							) 
						)
			ORDER BY t.[FloorNumber]
	  
	  end
	end try
	begin catch
		declare	@ErrorNum				int,
				@ErrorMsg				varchar(200),
				@ErrorProc				varchar(50),

				@SessionID				int,
				@AddlInfo				varchar(max)

		set @ErrorNum					= error_number()
		set @ErrorMsg					= 'sp_Hom_ELE_Card_ByAccess ' + error_message()
		set @ErrorProc					= error_procedure()

		set @AddlInfo					= ' ' + @Code

		exec utl_Insert_ErrorLog @ErrorNum, @ErrorMsg, @ErrorProc, 'Card_Elevate', 'GET', @SessionID, @AddlInfo
	end catch