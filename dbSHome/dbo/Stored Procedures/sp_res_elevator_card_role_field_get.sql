
CREATE procedure [dbo].[sp_res_elevator_card_role_field_get]
	@UserId	UNIQUEIDENTIFIER = NULL,
	@acceptLanguage NVARCHAR(50) = N'vi-VN'
as
begin try	
	SELECT 
		 ROW_NUMBER() OVER (ORDER BY EC.Note ) AS  RowNumber
		 ,EC.CardId
		 ,P.ProjectName
		 ,B.BuildingName
		 ,F.FloorName
		 ,CB.Card_Num AS CardNumber
		 ,CR.RoleName
		 ,t.CardTypeName
		 ,EC.Note
		  FROM [dbSHome].[dbo].[MAS_Elevator_Card] EC
			  JOIN ELE_CardRole CR ON EC.CardRole = CR.Id
			  join MAS_CardTypes t on EC.CardType = t.CardTypeId
			  Join mas_Projects P ON EC.ProjectCd = P.ProjectCd
			  join MAS_Buildings B ON EC.AreaCd = B.BuildingCd
			  left join ELE_Floor F ON EC.FloorNumber = F.FloorNumber 
			  join MAS_Cards C ON EC.CardId = C.CardId
			  join MAS_CardBase CB on c.CardCd = CB.Code 
		-- WHERE CB.Card_Num = '3200269265'
		ORDER BY EC.created_at DESC
end try
	begin catch
		declare	@ErrorNum				int,
				@ErrorMsg				varchar(200),
				@ErrorProc				varchar(50),

				@SessionID				int,
				@AddlInfo				varchar(max)

		set @ErrorNum					= error_number()
		set @ErrorMsg					= 'sp_Hom_Get_Card_Elevate_ByCode ' + error_message()
		set @ErrorProc					= error_procedure()

		set @AddlInfo					= 'UserId ' + ISNULL(CAST(@UserId AS NVARCHAR(50)), '')

		exec utl_Insert_ErrorLog @ErrorNum, @ErrorMsg, @ErrorProc, 'Card_Elevate', 'GET', @SessionID, @AddlInfo
	end catch