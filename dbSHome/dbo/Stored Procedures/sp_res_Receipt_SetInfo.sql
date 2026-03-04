--exec sp_Hom_Service_Receipt_Set null,'01',0,null,'24/10/2020',23352,'5ECB7BBB-69FD-441E-9D76-A585E9841484',6120,'loyaltycard',N'Nguyễn Tiến Dũng',null,null,null,null,null,null,null,null,null
CREATE PROCEDURE [dbo].[sp_res_Receipt_SetInfo]
    @UserID NVARCHAR(50) = NULL
    , @ReceiptId INT
    , @ProjectCd NVARCHAR(10)
    , @ReceiptNo NVARCHAR(50)
    , @ReceiptDate NVARCHAR(10)
    , @ReceiveId INT = NULL
    , @CustId NVARCHAR(50) = null
    , @ApartmentId INT = NULL
    , @TranferCd NVARCHAR(250)
    , @Object NVARCHAR(200)
    , @PassNo NVARCHAR(100)
    , @PassDate NVARCHAR(22)
    , @PassPlc NVARCHAR(250)
    , @Address NVARCHAR(250)
    , @Contents NVARCHAR(350)
    , @Amount DECIMAL(18, 0)
    , @Attach NVARCHAR(50)
    , @IsDBCR BIT = 0
    , @IsDebit BIT = 0
    , @AmtSubtractPoint DECIMAL
    , @PaymentOption NVARCHAR(500) = NULL
AS
BEGIN TRY
    DECLARE @valid BIT = 1
    DECLARE @messages NVARCHAR(400) = N'Cập nhật thành công'
    DECLARE @notification BIT = 0
    DECLARE @notimessage NVARCHAR(400)
    DECLARE @mailmessage NVARCHAR(max)
    DECLARE @creditAmt DECIMAL(18, 0)
    DECLARE @PayType NVARCHAR(50)
    DECLARE @CardCd NVARCHAR(50)
    DECLARE @RefNo NVARCHAR(100)
    DECLARE @OrderInfo NVARCHAR(50)
    DECLARE @ServiceKey NVARCHAR(50)
    DECLARE @PosCd NVARCHAR(50)
    DECLARE @ClientId NVARCHAR(50)
    DECLARE @ClientIp NVARCHAR(50)
    DECLARE @roomCode NVARCHAR(50)
    DECLARE @debitAmtTemp DECIMAL(18, 0)
    
    --IF EXISTS(SELECT TOP 1 1 FROM MAS_Service_Receipts WHERE ReceiveId = @ReceiveId)
    --BEGIN
    --    SET @valid = 0;
    --    SET @messages = N'Hóa đơn đã được chuyển nợ trước đó. Vui lòng kiểm tra lại.';
    --    GOTO FINAL;
    --END

    SET @ReceiptNo = 'H' + right('000' + cast(DATEPART(ms, getdate()) AS VARCHAR), 3) + CAST(DATEDIFF(ss, '2018-01-01', GETUTCDATE()) AS VARCHAR)

    IF (@ApartmentId = 0 or @ApartmentId is null)
        SET @ApartmentId = (SELECT top 1 ApartmentId FROM MAS_Service_ReceiveEntry a WHERE ReceiveId = @ReceiveId)

    IF @ProjectCd IS NULL
        SET @ProjectCd = (SELECT projectCd FROM MAS_Apartments a WHERE a.ApartmentId = @ApartmentId)

    IF @CustId IS NULL OR @CustId = ''
        SET @CustId = (SELECT custId FROM UserInfo WHERE UserId = @UserID )
    --select * from MAS_Service_Receipts
    IF @ReceiptId IS NULL OR @ReceiptId = 0
    BEGIN
        SET @notification = 0

        IF @TranferCd = 'debit'
        BEGIN
            IF EXISTS (SELECT 1 FROM MAS_Service_ReceiveEntry e WHERE ReceiveId = @ReceiveId and IsPayed = 1)
            BEGIN
                GOTO FINAL;
            END
            SET @debitAmtTemp = (SELECT DebitAmt FROM [MAS_Service_ReceiveEntry] WHERE ReceiveId = @ReceiveId)
            SET @creditAmt = (SELECT totalAmt - paidAmt - creditAmt FROM [MAS_Service_ReceiveEntry] WHERE ReceiveId = @ReceiveId)
            SET @Amount = @creditAmt --+ @debitAmtTemp
            SET @Contents = isnull(@Contents, '') + N'(Chuyển nợ)'

            SELECT @notimessage = N'Xác nhận chuyển nợ.'
                                  + N' Quý căn [' + a.RoomCode + N'], Dự án ' 
                                  + b.ProjectName + N' Khách hàng tên: ' + isnull(u.fullName, '') 
                                  + N'' + N' Đã thực hiện chuyển nợ số tiền [' + cast(@Amount AS VARCHAR) + '] sang kỳ tiếp theo!' 
                                  + N' Trân trọng!'
                , @mailmessage = N'Xác nhận chuyển nợ.' + '<br />' 
                                  + N' Quý căn hộ [' + a.RoomCode + N'], Dự án ' + b.ProjectName + '<br />' + N' Khách hàng tên: ' 
                                  + isnull(u.fullName, '') + N'' + '<br />'
                                  + N' Đã thực hiện chuyển nợ số tiền [' + cast(@Amount AS VARCHAR) + '] sang kỳ tiếp theo!' 
                                  + '<br />' + N' Trân trọng!'
            FROM
                MAS_Apartments a
                JOIN MAS_Projects b ON a.projectCd = b.projectCd
                JOIN UserInfo u ON a.UserLogin = u.loginName
            WHERE a.RoomCode = @roomCode


        END
        ELSE
        BEGIN
            SET @creditAmt = 0

            SELECT @notimessage = N'Xác nhận thanh toán.'
                                  + N' Quý căn [' + a.RoomCode + N'], Dự án ' + b.ProjectName + N' Khách hàng tên: ' 
                                  + isnull(u.fullName, '') + N'' + N' Đã thực hiện thanh toán số tiền [' + cast(@Amount AS VARCHAR) + '] nội dung: ' 
                                  + @Contents + N' Trân trọng!'
                , @mailmessage = N'Xác nhận chuyển nợ.' + '<br />' 
                                  + N' Quý căn hộ [' + a.RoomCode + N'], Dự án ' + b.ProjectName + '<br />' + N' Khách hàng tên: ' 
                                  + isnull(u.fullName, '') + N'' + '<br />' + N' Đã thực hiện thanh toán số tiền [' + cast(@Amount AS VARCHAR) + '] nội dung ' 
                                  + @Contents + '<br />' + N' Trân trọng!'
            FROM
                MAS_Apartments a
                JOIN MAS_Projects b ON a.projectCd = b.projectCd
                JOIN UserInfo u ON a.UserLogin = u.loginName
            WHERE a.RoomCode = @roomCode
        END

		----Chọn Thanh toán tiền công nợ cũ >> thì sau khi Lưu hệ thống tự động tích đã thanh toán vào hóa đơn các tháng trước
		--IF CHARINDEX('Debt', @PaymentOption) > 0
		--	BEGIN
		--		UPDATE MAS_Service_ReceiveEntry
		--		SET IsPayed = 1
		--		WHERE ApartmentId = @ApartmentId
		--	END

    IF (@PaymentOption IS NULL AND @TranferCd != 'debit')
    BEGIN
        DECLARE @AutoPaymentAmt DECIMAL(18,2) = ISNULL(@Amount, 0)
        DECLARE @HistoricalPaidAmt DECIMAL(18,2)
        DECLARE @AvailablePaymentAmt DECIMAL(18,2)
        DECLARE @PaidSectionsHistory NVARCHAR(MAX)

        -- Gom tất cả PaymentSection đã ghi nhận trước đó để tránh phân bổ trùng
        SELECT @PaidSectionsHistory = STUFF((
            SELECT ',' + REPLACE(ISNULL(PaymentSection, ''), ' ', '')
            FROM [dbo].[MAS_Service_Receipts]
            WHERE ReceiveId = @ReceiveId
              AND (@ReceiptId IS NULL OR ReceiptId <> @ReceiptId)
            FOR XML PATH(''), TYPE
            ).value('.', 'NVARCHAR(MAX)'), 1, 1, '')

        IF (@PaidSectionsHistory IS NULL OR LTRIM(RTRIM(@PaidSectionsHistory)) = '')
            SET @PaidSectionsHistory = ''
        ELSE
            SET @PaidSectionsHistory = ',' + @PaidSectionsHistory + ','

        SELECT @HistoricalPaidAmt = ISNULL(SUM(ISNULL(Amount, 0)), 0)
        FROM [dbo].[MAS_Service_Receipts]
        WHERE ReceiveId = @ReceiveId

        DECLARE @Priority TABLE (
          priority_order INT,
          ServiceTypeId INT,
          TotalAmt DECIMAL(18,2),
          SectionCode NVARCHAR(50),
          IsPaidPrior BIT
        )

        INSERT INTO @Priority (priority_order, ServiceTypeId, TotalAmt, SectionCode, IsPaidPrior)
        SELECT 
          p.priority_order,
          p.ServiceTypeId,
          ISNULL(st.TotalAmt, 0) AS TotalAmt,
          CASE p.ServiceTypeId
            WHEN 1 THEN N'Common'
            WHEN 2 THEN N'Vehicle'
            WHEN 3 THEN N'Electric'
            WHEN 4 THEN N'Water'
            WHEN 9 THEN N'Debt'
            ELSE N'ST' + CAST(p.ServiceTypeId AS NVARCHAR(10))
          END AS SectionCode,
          CASE WHEN CHARINDEX(',' + 
              CASE p.ServiceTypeId
                WHEN 1 THEN N'Common'
                WHEN 2 THEN N'Vehicle'
                WHEN 3 THEN N'Electric'
                WHEN 4 THEN N'Water'
                WHEN 9 THEN N'Debt'
                ELSE N'ST' + CAST(p.ServiceTypeId AS NVARCHAR(10))
              END + ',', @PaidSectionsHistory) > 0 THEN 1 ELSE 0 END
        FROM mas_payment_priority_configs p
			LEFT JOIN (
				SELECT 
					r.ServiceTypeId,
					SUM(ISNULL(r.TotalAmt, 0)) AS TotalAmt
				FROM MAS_Service_Receivable r
				WHERE r.ReceiveId = @ReceiveId
				GROUP BY r.ServiceTypeId
			) st ON st.ServiceTypeId = p.ServiceTypeId
			WHERE p.project_code = @ProjectCd
				AND ISNULL(st.TotalAmt, 0) > 0

			DECLARE @ConsumedAmt DECIMAL(18,2) = (
				SELECT ISNULL(SUM(TotalAmt), 0)
				FROM @Priority
				WHERE IsPaidPrior = 1
			)

			SET @AvailablePaymentAmt = ISNULL(@HistoricalPaidAmt, 0) + @AutoPaymentAmt - ISNULL(@ConsumedAmt, 0)
			IF (@AvailablePaymentAmt < 0)
				SET @AvailablePaymentAmt = 0

			;WITH Outstanding AS (
				SELECT 
					priority_order,
					SectionCode,
					TotalAmt,
					SUM(ISNULL(TotalAmt, 0)) OVER (ORDER BY priority_order ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING) AS PreviousTotal,
					SUM(ISNULL(TotalAmt, 0)) OVER (ORDER BY priority_order ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW) AS CumulativeTotal
				FROM @Priority
				WHERE IsPaidPrior = 0
			)
			SELECT @PaymentOption = STUFF((
					SELECT ',' + SectionCode
					FROM Outstanding
					WHERE @AvailablePaymentAmt >= CumulativeTotal
					ORDER BY priority_order
					FOR XML PATH(''), TYPE
					).value('.', 'NVARCHAR(MAX)'), 1, 1, '')

			IF (@PaymentOption IS NOT NULL AND LTRIM(RTRIM(@PaymentOption)) = '')
				SET @PaymentOption = NULL
		END

        INSERT INTO [dbo].MAS_Service_Receipts (
            [ReceiptNo]
            , [ReceiptDt]
            , [CustId]
            , [ApartmentId]
            , [ReceiveId]
            , [TranferCd]
            , [Object]
            , [Pass_No]
            , [Pass_dt]
            , [Pass_Plc]
            , [Address]
            , [Contents]
            , [Attach]
            , [IsDBCR]
            , [Amount]
            , [CreatorCd]
            , [CreateDate]
            --,[AccountLeft]
            --,[AccountRight]
            , [ProjectCd]
            , AmtSubtractPoint
            , Ref_No
            , RefundAmt
			, PaymentSection
            )
        VALUES (
            @ReceiptNo
            , isnull(convert(DATETIME, @ReceiptDate, 103), getdate())
            , @CustId
            , @ApartmentId
            , @ReceiveId
            , @TranferCd
            , NULL
            , @PassNo
            , convert(DATETIME, @Passdate, 103)
            , @PassPlc
            , @Address
            , @Contents
            , @Attach
            , @IsDBCR
            , @Amount --case when @Amount < 0 then 0 else @Amount end (Triều Dương)
            , @UserID
            , getdate()
            --,@AccountLeft
            --,@AccountRight
            , @ProjectCd
            , @AmtSubtractPoint
            , @RefNo
            , CASE 
                WHEN @Amount > (
                        SELECT TOP 1 isnull(TotalAmt, 0)
                        FROM MAS_Service_ReceiveEntry
                        WHERE ReceiveId = @ReceiveId
                        )
                    THEN @Amount - (
                            SELECT TOP 1 isnull(TotalAmt, 0)
                            FROM MAS_Service_ReceiveEntry
                            WHERE ReceiveId = @ReceiveId
                            )
                ELSE 0
                END
			, @PaymentOption
            )

        SET @ReceiptId = @@IDENTITY
        
        IF(@TranferCd != 'debit')
        BEGIN
        UPDATE t
            SET
                t.[PaidAmt] = isnull(t.PaidAmt, 0) + isnull(b.Amount,0)  --(case when @creditAmt < 0 then 0 else @creditAmt end)
                --, t.[IsPayed] = CASE 
                --    WHEN isnull(PaidAmt, 0) + isnull(b.Amount,0) < t.TotalAmt - isnull(@creditAmt,0)
                --        THEN 0
                --    ELSE 1
                --    END   (Triều Dương)
                , t.IsPayed = CASE 
                                  WHEN ISNULL(t.PaidAmt,0) + ISNULL(b.Amount,0) >= t.TotalAmt THEN 1
                                  ELSE 0
                              END 
                --, t.creditAmt = creditAmt + @creditAmt (Triều Dương)
                --,t.RefundAmt = b.RefundAmt
                --,OverAmt = case when @Amount > t.TotalAmt then @Amount - t.TotalAmt else 0 end
                , t.PayedDt = getdate()
            FROM
                [MAS_Service_ReceiveEntry] t
                LEFT JOIN MAS_Service_Receipts b ON t.ReceiveId = b.ReceiveId
            WHERE
                t.ReceiveId = @ReceiveId
                and b.ReceiptId = @ReceiptId            
        END


		-- Lấy danh sách PaymentSection đã thanh toán
			DECLARE @PaidSections NVARCHAR(MAX) = STUFF((
				SELECT ', ' + [PaymentSection]
				FROM [dbSHome].[dbo].[MAS_Service_Receipts]
				WHERE ReceiveId = @receiveId
				FOR XML PATH('')
			), 1, 2, '');

			-- Thêm dấu phẩy đầu/cuối để tránh trùng khớp một phần
			SET @PaidSections = ',' + ISNULL(@PaidSections, '') + ',';

			-- Cập nhật MAS_Service_Receivable
			UPDATE r
			SET 
				r.IsPaid = 1,
				r.PaymentDate = GETDATE()
			FROM dbo.MAS_Service_Receivable r
			WHERE r.ReceiveId = @receiveId
			  AND r.TotalAmt > 0
			  AND (r.IsPaid = 0 or r.IsPaid is null)
			  AND (
				-- 1. Dịch vụ chung: ServiceTypeId = 1 → CommonFee
				(r.ServiceTypeId = 1 AND CHARINDEX(',Common,', @PaidSections) > 0)

				-- 2. Phí giữ xe: ServiceTypeId = 2 → VehicleAmt
				OR (r.ServiceTypeId = 2 AND CHARINDEX(',Vehicle,', @PaidSections) > 0)

				-- 3. Điện sinh hoạt: ServiceTypeId = 3 + ServiceObject = 'Điện sinh hoạt' → ElectricityFee
				OR (r.ServiceTypeId = 3 
					--AND r.ServiceObject = N'Điện sinh hoạt' 
					AND CHARINDEX(',Electric,', @PaidSections) > 0)

				-- 4. Nước sinh hoạt: ServiceTypeId = 3 + ServiceObject = 'Nước sinh hoạt' → WaterFee
				OR (r.ServiceTypeId = 4
					--AND r.ServiceObject = N'Nước sinh hoạt' 
					AND CHARINDEX(',Water,', @PaidSections) > 0)

				-- 5. Nợ phí: ServiceTypeId = 9 → DebitAmt
				OR (r.ServiceTypeId = 9 AND CHARINDEX(',Debt,', @PaidSections) > 0)
			  );


        IF @TranferCd = 'debit'
        BEGIN
            UPDATE t
            SET t.DebitAmt = @creditAmt
                , lastReceived = CASE 
                    WHEN k.CommonFee > 0
                        THEN AccrualLastDt
                    ELSE t.lastReceived
                    END
            FROM MAS_Apartments t
            JOIN [MAS_Service_ReceiveEntry] k
                ON t.ApartmentId = k.ApartmentId
            JOIN MAS_Service_Receipts b
                ON k.ReceiveId = b.ReceiveId
            WHERE b.ReceiptId = @ReceiptId
                AND t.ApartmentId = @ApartmentId

			UPDATE [dbo].[MAS_Service_ReceiveEntry]
			   SET 
				   [IsDebt] = 1
				  ,IsPayed = 0
			 WHERE ReceiveId = @ReceiveId and IsPayed != 1

        END
        ELSE
        BEGIN
            UPDATE t
            SET t.DebitAmt = CASE 
                    WHEN isnull(t.DebitAmt, 0) - @Amount > 0
                        THEN isnull(t.DebitAmt, 0) - @Amount
                    ELSE 0
                    END
                , t.RefundAmt = b.RefundAmt
                , lastReceived = CASE 
                    WHEN k.CommonFee > 0
                        THEN AccrualLastDt
                    ELSE t.lastReceived
                    END
            FROM MAS_Apartments t
            JOIN [MAS_Service_ReceiveEntry] k
                ON t.ApartmentId = k.ApartmentId
            JOIN MAS_Service_Receipts b
                ON k.ReceiveId = b.ReceiveId
            WHERE b.ReceiptId = @ReceiptId
                AND t.ApartmentId = @ApartmentId
        END

        --if @TranferCd = 'refunddebit'
        --	begin
        --		update t
        --		set t.DebitAmt = t.DebitAmt + @Amount
        --		from MAS_Apartments t 
        --			join [MAS_Service_ReceiveEntry] k on t.ApartmentId = k.ApartmentId
        --			join MAS_Service_Receipts b on k.ReceiveId = b.ReceiveId
        --		  WHERE  b.ReceiptId = @ReceiptId and t.ApartmentId = @ApartmentId
        --	end
        declare @EndTimeTmp datetime
        --update accural
        UPDATE t
        SET @EndTimeTmp = t.EndTime,
            t.EndTime = t.lastReceivable,
            t.endTime_Tmp = @EndTimeTmp
        FROM MAS_CardVehicle t
        JOIN MAS_Service_Receivable b
            ON t.CardVehicleId = b.srcId
        WHERE ReceiveId = @receiveId
            AND b.ServiceTypeId = 2
            AND t.ApartmentId = @ApartmentId --and t.Status <> 3

        UPDATE t
        SET IsReceivable = 1
        FROM
            MAS_Service_Living_Tracking t
            JOIN MAS_Service_Receivable b ON t.TrackingId = b.srcId
        WHERE
            ReceiveId = @receiveId
            AND b.ServiceTypeId = 3

        IF @TranferCd = 'loyaltycard'
        BEGIN
            SET @PayType = N'servicefee'
            SET @roomCode = (
                    SELECT TOP 1 RoomCode
                    FROM MAS_Apartments
                    WHERE ApartmentId = @ApartmentId
                    )
            SET @OrderInfo = isnull(@OrderInfo, N'Thanh toán hóa đơn căn hộ : ' + isnull(@roomCode, ''))
            SET @ClientId = 'web_s_service_prod'
            SET @RefNo = 'TT-' + @roomCode + '-' + cast((CAST(CHECKSUM(NEWID()) AS BIGINT) * CAST(100000 AS BIGINT)) AS NVARCHAR(50))
            SET @ServiceKey = 'SK002690'
            SET @PosCd = (
                    SELECT PosCd
                    FROM WAL_ServicePOS
                    WHERE ServiceKey = @ServiceKey
                        AND projectCd = @ProjectCd
                    )

            IF NOT EXISTS (
                    SELECT PointTranId
                    FROM WAL_PointOrder
                    WHERE Ref_No = @RefNo
                    )
            BEGIN
                INSERT INTO [dbo].WAL_PointOrder (
                    [PointTranId]
                    , [PointCd]
                    , [TransNo]
                    , [Ref_No]
                    , [TranType]
                    , [OrderInfo]
                    , OrderAmount
                    , [CreditPoint]
                    , [Point]
                    , [TranDt]
                    , ServiceKey
                    , PosCd
                    , [CurrPoint]
                    , CltId
                    , CltIp
                    , roomCode
                    )
                SELECT NEWID()
                    , p.PointCd
                    , @roomCode
                    , @RefNo
                    , @PayType
                    , @OrderInfo
                    , 0
                    , @AmtSubtractPoint
                    , 0
                    , getdate()
                    , @ServiceKey
                    , @PosCd
                    , p.[CurrPoint]
                    , @ClientId
                    , @ClientIp
                    , @roomCode
                FROM MAS_Points p
                WHERE CustId = @custId

                UPDATE MAS_Service_Receipts
                SET Ref_No = @RefNo
                WHERE ReceiptId = @ReceiptId

                UPDATE p
                SET [CurrPoint] = CurrPoint - @AmtSubtractPoint
                    , [LastDt] = getdate()
                FROM [MAS_Points] p
                WHERE p.CustId = @custId
            END
        END
    END
    ELSE
    BEGIN

        UPDATE t
           SET  [PaidAmt] = isnull(PaidAmt,0) - b.Amount + @Amount
				--SET 	[PaidAmt] = isnull(PaidAmt,0) + b.Amount
        	  ,[IsPayed] = case when isnull(PaidAmt,0) - b.Amount + @Amount < t.TotalAmt then 0 else 1 end
        	  --, IsPayed = 1
        	  ,PayedDt = getdate()
        FROM [MAS_Service_ReceiveEntry] t
         join MAS_Service_Receipts b on t.ReceiveId = b.ReceiveId
         WHERE  ReceiptId = @ReceiptId

        UPDATE [dbo].MAS_Service_Receipts
        SET [ReceiptNo] = @ReceiptNo
            , [ReceiptDt] = convert(DATETIME, @ReceiptDate, 103)
            , CustId = @CustId
            , [ApartmentId] = @ApartmentId
            --,[TranferCd] = @TranferCd
            , [Object] = CASE 
                WHEN @Object = ''
                    THEN NULL
                ELSE @Object
                END
            , [Pass_No] = @PassNo
            , [Pass_dt] = convert(DATETIME, @Passdate, 103)
            , [Pass_Plc] = @PassPlc
            , [Address] = @Address
            , [Contents] = @Contents
            , [Attach] = @Attach
            , [IsDBCR] = @IsDBCR
            --,[Amount] = @Amount
            , [CreatorCd] = @UserID
        WHERE ReceiptId = @ReceiptId

		--IF (CHARINDEX('DebitAmt', @PaymentOption) > 0)
		--	BEGIN 
		--		UPDATE [dbo].[MAS_Service_ReceiveEntry]
		--			SET IsPayed = 1
		--		WHERE ApartmentId = @ApartmentId
		--	END
    END

    SELECT @valid AS valid
        , regId = @ReceiptId
        , @messages AS [messages]
        , @notification AS notiQue
        , @ReceiveId AS work_st

    IF @notification = 1
    BEGIN
        SELECT N'Xác nhận thanh toán - Apartment Payment' AS [subject]
            , N's-resident' AS external_key --[Event]
            , @notimessage AS content_notify
            , @mailmessage AS content_email --[MessageEmail]
            , 'push,email' AS [action_list] --sms,email
            , 'new' AS [status]
            , @userId AS userId
            , a.projectCd AS external_sub
            , [mailSender] AS send_by
            , [investorName] AS send_name
        FROM MAS_Apartments a
        JOIN MAS_Projects b
            ON a.sub_projectCd = b.sub_projectCd
        WHERE a.RoomCode = @roomCode

        SELECT u2.[userId]
            , u2.phone
            , u2.email
            , u2.avatarUrl AS Avatar
            , u2.fullName
            , 1 AS app
            , u.CustId
        FROM [MAS_Apartments] a
        JOIN MAS_Apartment_Member u
            ON a.ApartmentId = u.ApartmentId
        JOIN UserInfo u2
            ON u.CustId = u2.custId
                AND u2.userType = 2
        WHERE a.RoomCode = @roomCode
            AND u.member_st = 1
            AND a.IsReceived = 1
            AND EXISTS (
                SELECT 1
                FROM UserInfo u1
                WHERE u1.custId = u.CustId
                    AND u1.loginName = a.UserLogin
                )
            --and @RelationId > 1
    END

    EXEC sp_Hom_Service_Receipt_ByReceiveId @userId
        , @ReceiveId
END TRY

BEGIN CATCH
    DECLARE @ErrorNum INT
        , @ErrorMsg VARCHAR(200)
        , @ErrorProc VARCHAR(50)
        , @SessionID INT
        , @AddlInfo VARCHAR(max)

    SET @messages = error_message();
    SET @valid = 0;
    
    SET @ErrorNum = error_number()
    SET @ErrorMsg = 'sp_res_Receipt_SetInfo ' + @messages
    SET @ErrorProc = error_procedure()
    SET @AddlInfo = '@CustId ' + @CustId

    EXEC utl_Insert_ErrorLog @ErrorNum
        , @ErrorMsg
        , @ErrorProc
        , 'MAS_Receipts'
        , 'Insert'
        , @SessionID
        , @AddlInfo
END CATCH

FINAL:
    SELECT
        @valid AS valid
        , regId = @ReceiptId
        , @messages AS [messages]
        , @notification AS notiQue
        , @ReceiveId AS work_st
        
    --select * from MAS_Apartments where ApartmentId = 6120
    --select * from utl_Error_Log where TableName ='Receipts' order by CreatedDate desc
    --select * from MAS_Service_ReceiveEntry where ApartmentId = 6120
    --select * from MAS_Apartments where ApartmentId = 6120