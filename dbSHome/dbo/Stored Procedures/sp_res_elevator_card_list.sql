


CREATE procedure [dbo].[sp_res_elevator_card_list]
	@UserId UNIQUEIDENTIFIER = NULL,
	@cardId	int = null,
	@filter	nvarchar(50) = null,
	@acceptLanguage NVARCHAR(50) = N'vi-VN'
as
	begin try	
			SET @filter = NULLIF(@filter, '0')
			--drop table if exists #cards

			  SELECT a.CardId as value
					,a.CardCd + ' ('+ kk.FullName + isnull('-' + kk.Phone,'') +')' as name
				into #cards
				FROM dbo.MAS_Cards AS a 
				   inner join MAS_CardBase d on a.CardCd = d.Code
				   inner join MAS_CardStatus s on a.Card_St = s.StatusId
				   inner join MAS_Customers kk on a.CustId = kk.CustId
				   left join MAS_CardTypes f on a.CardTypeId = f.CardTypeId
				   left join MAS_Apartment_Member m on a.CustId = m.CustId and a.ApartmentId = m.ApartmentId
				   left join MAS_Apartments c on m.ApartmentId = c.ApartmentId and a.ApartmentId = c.ApartmentId
			where a.Card_St = 1
			and (a.CardId = @cardId)
			
			--filter
			insert into #cards
			SELECT top 20 a.CardId as value
					,a.CardCd + '('+ kk.FullName + isnull('-' + kk.Phone,'') +')' as name
				FROM dbo.MAS_Cards AS a 
				   inner join MAS_CardBase d on a.CardCd = d.Code
				   inner join MAS_CardStatus s on a.Card_St = s.StatusId
				   inner join MAS_Customers kk on a.CustId = kk.CustId
				   left join MAS_CardTypes f on a.CardTypeId = f.CardTypeId
				   left join MAS_Apartment_Member m on a.CustId = m.CustId and a.ApartmentId = m.ApartmentId
				   left join MAS_Apartments c on m.ApartmentId = c.ApartmentId and a.ApartmentId = c.ApartmentId
			where a.Card_St = 1
			and (@filter is not  null)
				and (a.CardCd like '%' + @filter + '%' or kk.Phone like '%' + @filter + '%')
				--and exists(select 1 from UserProject p where p.userId = @UserId and p.projectCd = ec.ProjectCd)

			select * from #cards

	end try
	begin catch
		declare	@ErrorNum				int,
				@ErrorMsg				varchar(200),
				@ErrorProc				varchar(50),

				@SessionID				int,
				@AddlInfo				varchar(max)

		set @ErrorNum					= error_number()
		set @ErrorMsg					= 'sp_Hom_Get_Card_ByCardCd ' + error_message()
		set @ErrorProc					= error_procedure()

		set @AddlInfo					= ' '

		exec utl_Insert_ErrorLog @ErrorNum, @ErrorMsg, @ErrorProc, 'MAS_Cards', 'GET', @SessionID, @AddlInfo
	end catch