
CREATE procedure [dbo].[sp_res_elevator_card_by_code_field_get]
	@UserId	UNIQUEIDENTIFIER = NULL,
	@CardNum	nvarchar(50) = NULL,
	@CustomerPhoneNumber nvarchar(50) = NULL,
	@HardwareId nvarchar(200) = NULL,
	@acceptLanguage NVARCHAR(50) = N'vi-VN'
as
	begin try	
	declare @er int
	declare @StationId int
	declare @CardCd nvarchar(30)

		--if @HardwareId ='NFC-985943' or @HardwareId = 'NFC-D05F43'
		--	exec utl_Insert_ErrorLog 2, @HardwareId,'sp_Hom_Get_Card_Elevate_ByCode', 'CardElevate', 'GET', '', @Code
		--loger
		if not exists(SELECT a.[CardCd]
			FROM [dbo].[MAS_Cards] a 
				join MAS_CardBase b on a.CardCd = b.Code 
			WHERE (b.Code =  @CardNum) 
				and (a.CardTypeId = 2 or a.CardTypeId = 3 or a.CardTypeId = 4) 
				and a.Card_St = 1)
			begin
				set @er = 1
				exec utl_Insert_ErrorLog @er, @HardwareId,'sp_Hom_Get_Card_Info_ByCode', 'CardElevate', 'GET', '', @CardNum
			end
			else
			begin
				--set @er = 0
				--set @StationId = (select top 1 id from MAS_Elevator_Device where HardwareId = @HardwareId)
				--set @CardCd = (select top 1 Code from MAS_CardBase where Card_Num = @CardNum)
				--exec [dbo].[sp_Hom_Insert_LogReader] @StationId, @CardCd
			
				

		--1 card info
		SELECT TOP 1 a.[CardCd]
			  ,convert(nvarchar(10),a.[IssueDate],103) IssueDate
			  ,convert(nvarchar(10),a.[ExpireDate],103) [ExpireDate]
			  ,b.Code as CardNumber
			  , t.CardTypeName as CardTypeName
			  ,1 as open_gate
			  ,upper(d.HardwareId) as HardwareId
			  ,d.ElevatorBank as ElevatorBank
			  ,d.ElevatorShaftNumber as ElevatorShaftNumber
			  ,d.ElevatorShaftName as ElevatorShaftName  
			  ,a.CardId
			  ,c.FullName
			  ,c.Phone
		FROM [dbo].[MAS_Cards] a 
			left join MAS_CardBase b on a.CardCd = b.Code 
			left join MAS_Customers c on a.CustId = c.CustId
			left join MAS_CardTypes t on a.CardTypeId = t.CardTypeId
			,(select ElevatorBank, ElevatorShaftNumber, ElevatorShaftName, HardwareId  from MAS_Elevator_Device where IsActived = 1  and (@HardwareId IS NULL OR HardwareId = @HardwareId)
			) d
		WHERE  (@CardNum IS NULL OR Code  =  @CardNum) 
			and (@CustomerPhoneNumber IS NULL OR c.Phone = @CustomerPhoneNumber)
			and (Card_St = 1)
			end
			end try
	begin catch
		declare	@ErrorNum				int,
				@ErrorMsg				varchar(200),
				@ErrorProc				varchar(50),

				@SessionID				int,
				@AddlInfo				varchar(max)

		set @ErrorNum					= error_number()
		set @ErrorMsg					= 'sp_Hom_Get_Card_Info_ByCode ' + error_message()
		set @ErrorProc					= error_procedure()

		set @AddlInfo					= ' UserId' + ISNULL(CAST(@UserId AS NVARCHAR(50)), '')

		exec utl_Insert_ErrorLog @ErrorNum, @ErrorMsg, @ErrorProc, 'Card_Info', 'GET', @SessionID, @AddlInfo
	end catch