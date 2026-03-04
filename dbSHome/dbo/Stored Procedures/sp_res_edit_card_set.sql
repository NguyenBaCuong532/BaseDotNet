
CREATE   PROCEDURE [dbo].[sp_res_edit_card_set]
    @UserID NVARCHAR(450) = null,
    @CardCd nvarchar(50) = null,
	@CustId nvarchar(50) = null,
	@ImageUrl nvarchar(50) = null,
	@IssueDate nvarchar(50) = null,
	@ExpireDate nvarchar(50) = null,
	@CardTypeId int = null,
	@CurrentPoint nvarchar(50) = null,
	@StatusName nvarchar(50) = null,
	@fullname nvarchar(50) = null,
	@RoomCode nvarchar(50) = null,
	@CardTypeName nvarchar(50) = null,
	@ApartmentId nvarchar(50) = null,
	@CardStatus nvarchar(50) = null,
	@ProjectCd nvarchar(50) = null,
	@CardCdNew nvarchar(50) = null
AS
BEGIN
    DECLARE @valid BIT = 0;
    DECLARE @messages NVARCHAR(200) = N'Có lỗi xảy ra';

    BEGIN TRY

        IF NOT EXISTS (SELECT Code FROM MAS_CardBase WHERE Code = @CardCdNew) --and (IsUsed = 0 or IsUsed is null)
        BEGIN
            SET @valid = 0;
            SET @messages = N'Không tìm thấy thông tin mã thẻ mới [' + @CardCdNew + N'] trong kho số!';
        END;
        ELSE IF EXISTS
        (
            SELECT Code
            FROM MAS_CardBase
            WHERE Code = @CardCdNew
                  AND IsUsed = 1
        )
        BEGIN
            SET @valid = 0;
            SET @messages = N'Mã thẻ [' + @CardCdNew + N'] đã được sử dụng!';
        END;
		ELSE IF NOT EXISTS (SELECT 1 FROM MAS_CardBase cb							
								WHERE cb.Code = @CardCdNew and cb.ProjectCode = @projectCd)
			BEGIN
				SET @valid = 0;
				SET @messages = N'Mã thẻ ' + @CardCdNew+ N' không cùng dự án với căn hộ đang xử lý!';;
			END
		ELSE
			BEGIN
				-- Đổi trạng thái thẻ cũ sang inactive
				UPDATE MAS_CardBase 
					Set IsUsed = 0
					WHERE Code = @CardCd

				-- Nếu MAS_Cards đã có dòng với mã thẻ mới, thì UPDATE thay vì INSERT
						IF EXISTS (SELECT 1 FROM MAS_Cards WHERE CardCd = @CardCdNew)
						BEGIN
							UPDATE c
							SET 
								c.CardTypeId     = oldC.CardTypeId,
								c.IssueDate      = GETDATE(),
								c.ExpireDate     = oldC.ExpireDate,
								c.CustId         = oldC.CustId,
								c.Card_St        = oldC.Card_St,
								c.SelfLock       = oldC.SelfLock,
								c.IsVip          = oldC.IsVip,
								c.CardName       = oldC.CardName,
								c.IsDaily        = oldC.IsDaily,
								c.IsClose        = oldC.IsClose,
								c.CloseDate      = oldC.CloseDate,
								c.RequestId      = oldC.RequestId,
								c.ApartmentId    = oldC.ApartmentId,
								c.ProjectCd      = oldC.ProjectCd,
								c.VehicleTypeId  = oldC.VehicleTypeId,
								c.StarLevel      = oldC.StarLevel,
								c.IsGuest        = oldC.IsGuest,
								c.isVehicle      = oldC.isVehicle,
								c.isCredit       = oldC.isCredit,
								c.partner_id     = oldC.partner_id,
								c.created_by     = oldC.created_by,
								c.CloseBy        = oldC.CloseBy
							FROM MAS_Cards c
							INNER JOIN MAS_Cards oldC ON oldC.CardCd = @CardCd
							WHERE c.CardCd = @CardCdNew;


						END
						ELSE
						BEGIN
							-- Nếu chưa có thì thêm dòng mới
							INSERT INTO [dbo].[MAS_Cards]
								   ([CardCd]
								   ,[CardTypeId]					   
								   ,[IssueDate]
								   ,[ExpireDate]
								   ,[CustId]
								   ,[Card_St]
								   ,[SelfLock]					   
								   ,[IsVip]
								   ,[CardName]
								   ,[IsDaily]
								   ,[IsClose]
								   ,[CloseDate]
								   ,[RequestId]
								   ,[ApartmentId]
								   ,[ProjectCd]
								   ,[VehicleTypeId]
								   ,[StarLevel]
								   ,[IsGuest]
								   ,[isVehicle]
								   ,[isCredit]
								   ,[partner_id]
								   ,[created_by]
								   ,[CloseBy])
							SELECT 
									@CardCdNew
								   ,[CardTypeId]					   
								   ,GETDATE()
								   ,[ExpireDate]
								   ,[CustId]
								   ,[Card_St]
								   ,[SelfLock]					   
								   ,[IsVip]
								   ,[CardName]
								   ,[IsDaily]
								   ,[IsClose]
								   ,[CloseDate]
								   ,[RequestId]
								   ,[ApartmentId]
								   ,[ProjectCd]
								   ,[VehicleTypeId]
								   ,[StarLevel]
								   ,[IsGuest]
								   ,[isVehicle]
								   ,[isCredit]
								   ,[partner_id]
								   ,[created_by]
								   ,[CloseBy]
								FROM MAS_Cards
								WHERE CardCd = @CardCd;

						END
						
				-- Đổi trạng thái thẻ mới sang active
				UPDATE MAS_CardBase 
					Set IsUsed = 1
					WHERE Code = @CardCdNew;

				-- Đổi mã phương tiện tương ứng với thẻ cũ
				UPDATE MAS_CardVehicle
						SET CardId = (SELECT CardId FROM MAS_Cards WHERE CardCd = @CardCdNew)
						WHERE CardVehicleId = (Select CardVehicleId FROM MAS_CardVehicle cv join MAS_Cards c on cv.CardId = c.CardId
													WHERE c.CardCd = @CardCd);
				
				-- Xóa dòng dữ liệu thẻ cũ
				DELETE FROM  MAS_Cards
				 WHERE CardCd = @CardCd
					
				SET @valid = 1;
				SET @messages = N'Mã thẻ ' + @CardCd+ N' đã được đổi thành '+ @CardCdNew+ '!';;

			END

		FINAL:
			SELECT @valid valid,
           @messages AS [messages];
    END TRY
    BEGIN CATCH
        DECLARE @ErrorNum INT,
                @ErrorMsg VARCHAR(200),
                @ErrorProc VARCHAR(50),
                @SessionID INT,
                @AddlInfo VARCHAR(MAX);

        SET @ErrorNum = ERROR_NUMBER();
        SET @ErrorMsg = 'sp_res_edit_card_set' + ERROR_MESSAGE();
        SET @ErrorProc = ERROR_PROCEDURE();
        EXEC utl_Insert_ErrorLog @ErrorNum,
                                 @ErrorMsg,
                                 @ErrorProc,
                                 'Card',
                                 'Insert',
                                 @SessionID,
                                 @AddlInfo;
        SET @valid = 0;
        SET @messages = ERROR_MESSAGE();


    END CATCH;

    SELECT @valid AS valid,
           @messages AS [messages];

END;