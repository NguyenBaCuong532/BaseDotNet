CREATE procedure [dbo].[sp_res_elevator_card_get]
	@UserId UNIQUEIDENTIFIER = NULL,
	@CardId	int,
	@acceptLanguage NVARCHAR(50) = N'vi-VN'
as
	begin try	
		drop table if exists #tempIn
	
		select cast(b.CardId as int) as CardId, b.CardCd, b.ProjectCd, b.Card_St, b.CustId,b.IssueDate, b.ExpireDate
			, b.IsClose, b.CloseDate, IsDaily, b.IsGuest, b.IsVip,b.CardTypeId,b.ApartmentId,b.partner_id
		into #tempIn
		from MAS_Cards b
		WHERE (b.CardId = @CardId)
	
		if not exists(select 1 from #tempIn)
		insert into #tempIn (CardId,CardCd,IsDaily)
		select 0,'',0--,1,'','',getdate()

		DECLARE @group_key VARCHAR(50) = 'elevator_group'
		DECLARE @table_key VARCHAR(50) = 'elevator_card'

		SELECT cardId
			  ,cardCd
			  ,projectCd
			  ,tableKey = @table_key
              ,groupKey = @group_key
		from #tempIn;

		SELECT *
		FROM [dbo].[fn_get_field_group_lang](@group_key, @acceptLanguage)
		ORDER BY intOrder;
		
		SELECT  a.id
				,table_name
				,field_name
				,view_type
				,data_type
				,ordinal
				,columnLabel
				,group_cd
				,case data_type when 'nvarchar' then convert(nvarchar(350), case field_name 
					when 'ProjectCd' then b.ProjectCd
					when 'CardCd' then b.CardCd
					when 'Card_Num' then d.Card_Num
					when 'CardTypeName' then f.CardTypeName
					when 'StatusName' then s.StatusName
					when 'Phone' then kk.Phone
					when 'FullName' then kk.FullName
					when 'roomCode' then c.roomCode
					end
					) 
				when 'datetime' then convert(nvarchar(50), case field_name 
					when 'IssueDate' then format(b.IssueDate,'dd/MM/yyyy HH:mm:ss')
					when 'ExpireDate' then format(b.ExpireDate,'dd/MM/yyyy HH:mm:ss')
					when 'CloseDate' then format(b.CloseDate,'dd/MM/yyyy HH:mm:ss')
					end)
				when 'bit' then case field_name
					when 'IsDaily' then iif(b.IsDaily = 1,'true','false')
					when 'IsVip' then iif(b.IsVip = 1,'true','false')--noi bo
					when 'IsGuest' then iif(b.IsGuest = 1,'true','false')
					when 'IsClose' then iif(b.IsClose = 1,'true','false')
					when 'IsVehicle' then iif(exists((Select 1 from MAS_CardVehicle vh where vh.CardId = b.CardId and vh.[Status] < 3)),'true','false')
					end
				else convert(nvarchar(50),case field_name 
					when 'Card_St' then b.Card_St
					when 'cardId' then b.cardId
					when 'CardTypeId' then b.CardTypeId
					when 'partner_id' then b.partner_id
					end) 
				end as columnValue
				,columnClass
				,columnType
				,columnObject = case when a.field_name = 'cardId' then replace(columnObject,'cardId=','cardId=' + cast(b.cardId as varchar(10)))
								--when a.field_name = 'projectCd' then columnObject + b.ProjectCd
								--when a.field_name = 'partner_id' then columnObject + cast(b.partner_id as varchar(10))
								else columnObject end
				,isSpecial
				,isRequire
				,isDisable
				,isVisiable = case when a.field_name = 'cardId' and @CardId > 0 then 0 else isVisiable end
				,isnull(a.columnTooltip,[columnLabel]) as columnTooltip
				,isIgnore
			FROM dbo.fn_config_form_gets(@table_key, @acceptLanguage) a
				CROSS JOIN #tempIn b
				left join MAS_CardBase d on b.CardCd = d.Code
				left join MAS_CardStatus s on b.Card_St = s.StatusId
				left join MAS_Customers kk on b.CustId = kk.CustId
				left join MAS_CardTypes f on b.CardTypeId = f.CardTypeId
				left join MAS_Apartment_Member m on b.CustId = m.CustId and b.ApartmentId = m.ApartmentId
				left join MAS_Apartments c on m.ApartmentId = c.ApartmentId and b.ApartmentId = c.ApartmentId
			WHERE a.table_name = @table_key
				AND (a.isVisiable = 1 or a.isRequire = 1)
				--and b.Card_St = 1 and b.CardId = @CardId
			order by ordinal

	end try
	begin catch
		declare	@ErrorNum				int,
				@ErrorMsg				varchar(200),
				@ErrorProc				varchar(50),

				@SessionID				int,
				@AddlInfo				varchar(max)

		set @ErrorNum					= error_number()
		set @ErrorMsg					= 'sp_res_elevator_card_get ' + error_message()
		set @ErrorProc					= error_procedure()

		set @AddlInfo					= ' '

		exec utl_Insert_ErrorLog @ErrorNum, @ErrorMsg, @ErrorProc, 'MAS_Cards', 'GET', @SessionID, @AddlInfo
	end catch