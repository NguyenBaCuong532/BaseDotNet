CREATE PROCEDURE [dbo].[sp_res_apartment_fee_set]
    @UserID NVARCHAR(450),
    @par_residence_type_oid uniqueidentifier,
    @ApartmentId BIGINT,
    @IsFeeStart INT,
    @FeeStart NVARCHAR(10),
    @IsFree INT,
    @FreeMonth INT,
    @FreeToDate NVARCHAR(10),
    @FeeNote NVARCHAR(200),
    @IsReceived INT,
    @ReceiveDate NVARCHAR(10),
    @DebitAmt DECIMAL(18, 0),
    @IsRent INT
--,@WaterwayArea	float
AS
BEGIN TRY
    DECLARE @valid BIT = 1;
    DECLARE @messages NVARCHAR(100) = N'Cập nhật thành công';

    IF @IsFeeStart = 1
        BEGIN
            INSERT INTO [dbo].[MAS_Apartments_Save]
            (
                [ApartmentId],
                [RoomCode],
                [Cif_No],
                [UserLogin],
                [FamilyImageUrl],
                [StartDt],
                [EndDt],
                [IsClose],
                [CloseDt],
                [IsLock],
                [IsReceived],
                [ReceiveDt],
                [IsRent],
                [lastReceived],
                [FeeStart],
                [IsFree],
                [FeeNote],
                [numFreeMonth],
                [AccrualLastDt],
                [PayLastDt],
                [projectCd],
                [buildingCd],
                [isMain],
                [WaterwayArea],
                [isFeeStart],
                [CurrBal],
                [isLinkApp],
                [DebitAmt],
                [FreeToDt],
                --,[ContractRemark]
                --,[ContractDt]
                [SaveDt],
                [saveKey],
                [saveBy]
            )
            SELECT [ApartmentId],
                   [RoomCode],
                   [Cif_No],
                   [UserLogin],
                   [FamilyImageUrl],
                   [StartDt],
                   [EndDt],
                   [IsClose],
                   [CloseDt],
                   [IsLock],
                   [IsReceived],
                   [ReceiveDt],
                   [IsRent],
                   [lastReceived],
                   [FeeStart],
                   [IsFree],
                   [FeeNote],
                   [numFreeMonth],
                   [AccrualLastDt],
                   [PayLastDt],
                   [projectCd],
                   [buildingCd],
                   [isMain],
                   [WaterwayArea],
                   [isFeeStart],
                   [CurrBal],
                   [isLinkApp],
                   [DebitAmt],
                   [FreeToDt],
                   GETDATE(),
                   'SetupFee',
                   @UserID
            FROM [dbo].[MAS_Apartments]
            WHERE ApartmentId = @ApartmentId;

           --     UPDATE t1
           --     SET isFeeStart = @IsFeeStart,
           --         FeeStart = CONVERT(DATETIME, ISNULL(@FeeStart, @ReceiveDate), 103),
           --         IsFree = @IsFree,
           --         numFreeMonth = @FreeMonth,
           --         FreeToDt = CASE
           --                        WHEN @IsFree = 1 THEN
           --                            DATEADD(MONTH, @FreeMonth, CONVERT(DATETIME, ISNULL(@FeeStart, @ReceiveDate), 103))
           --                        ELSE
           --                            CONVERT(DATETIME, ISNULL(@FeeStart, @ReceiveDate), 103)
           --                    END, --convert(datetime,@FreeToDate,103)
           --         FeeNote = @FeeNote,
           --         IsReceived = @IsReceived,
           --         ReceiveDt = CONVERT(DATETIME, @ReceiveDate, 103),
           --         --lastReceived = NULL,
           --         DebitAmt = @DebitAmt,
              --IsRent = @IsRent
           --     --,WaterwayArea = isnull(@WaterwayArea,WaterwayArea)
           --     FROM MAS_Apartments t1
           --     WHERE t1.ApartmentId = @ApartmentId;

           --duongvt sửa cho lưu được khi để @isfree = 0
            UPDATE t1
            SET
                isFeeStart = @IsFeeStart,
                par_residence_type_oid = @par_residence_type_oid,
                FeeStart = CASE WHEN @IsFree = 0 THEN NULL
                ELSE CONVERT(DATETIME, ISNULL(@FeeStart, @ReceiveDate), 103) END,
                IsFree = @IsFree,
                numFreeMonth = @FreeMonth,
                FreeToDt = CASE WHEN @IsFree = 0 THEN NULL
                ELSE
                    CASE
                       WHEN @IsFree = 1 THEN DATEADD(MONTH, @FreeMonth, CONVERT(DATETIME, ISNULL(@FeeStart, @ReceiveDate), 103))
                       ELSE CONVERT(DATETIME, ISNULL(@FeeStart, @ReceiveDate), 103)
                     END
                END , --convert(datetime,@FreeToDate,103)
                FeeNote = @FeeNote,
                IsReceived = @IsReceived,
                ReceiveDt = CONVERT(DATETIME, @ReceiveDate, 103),
                --lastReceived = NULL,
                DebitAmt = @DebitAmt,
          IsRent = @IsRent
            --,WaterwayArea = isnull(@WaterwayArea,WaterwayArea)
            FROM MAS_Apartments t1
            WHERE t1.ApartmentId = @ApartmentId;

            UPDATE dbo.MAS_Apartments
            SET lastreceived = ISNULL(FreeToDt,lastReceived)
            WHERE ApartmentId = @ApartmentId 
        --AND lastReceived IS NULL
        
        --exec utl_Insert_ErrorLog @UserID, @ApartmentId, '', 'UpdateBy', 'MAS_Apartments', '', N'Lưu thông người tin cập nhật phí dịch vụ'
        END;
    ELSE
        BEGIN
            SET @valid = 0;
            SET @messages = N'Yêu cầu phải cập nhật bắt đầu tính phí!';
        END;

    SELECT @valid AS valid,
           @messages AS [messages];
END TRY
BEGIN CATCH
    DECLARE @ErrorNum INT, @ErrorMsg VARCHAR(200), @ErrorProc VARCHAR(50), @SessionID INT, @AddlInfo VARCHAR(MAX);

    SET @ErrorNum = ERROR_NUMBER();
    SET @ErrorMsg = 'sp_Hom_Update_Apartment_Fee ' + ERROR_MESSAGE();
    SET @ErrorProc = ERROR_PROCEDURE();
    SET @AddlInfo = '@UserID ' + @UserID;
    EXEC utl_Insert_ErrorLog @ErrorNum, @ErrorMsg, @ErrorProc, 'ApartmentFee', 'Update', @SessionID, @AddlInfo;
END CATCH;