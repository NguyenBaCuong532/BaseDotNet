CREATE TABLE [dbo].[MAS_CardVehicle] (
    [CardVehicleId]            INT              IDENTITY (1, 1) NOT FOR REPLICATION NOT NULL,
    [AssignDate]               DATETIME         NULL,
    [CardId]                   INT              NOT NULL,
    [CustId]                   NVARCHAR (50)    NOT NULL,
    [VehicleNo]                NVARCHAR (16)    NOT NULL,
    [VehicleTypeId]            INT              NULL,
    [VehicleName]              NVARCHAR (100)   NULL,
    [VehicleColor]             NVARCHAR (100)   NULL,
    [StartTime]                DATETIME         NULL,
    [EndTime]                  DATETIME         NULL,
    [Status]                   INT              NULL,
    [ServiceId]                INT              NULL,
    [RegCardVehicleId]         INT              NULL,
    [RequestId]                INT              NULL,
    [isVehicleNone]            BIT              NULL,
    [monthlyType]              INT              NULL,
    [VehicleNum]               INT              NULL,
    [lastReceivable]           DATETIME         NULL,
    [Mkr_Id]                   NVARCHAR (50)    NULL,
    [Mkr_Dt]                   DATETIME         NULL,
    [Auth_id]                  NVARCHAR (200)   NULL,
    [Auth_Dt]                  DATETIME         NULL,
    [ProjectCd]                NVARCHAR (30)    NULL,
    [ApartmentId]              BIGINT           NULL,
    [Reason]                   NVARCHAR (200)   NULL,
    [VehicleNo_us]             NVARCHAR (16)    NULL,
    [sysDt]                    DATETIME         CONSTRAINT [DF_MAS_CardVehicle_sysDt] DEFAULT (getdate()) NULL,
    [locked_dt]                DATETIME         NULL,
    [endTime_Tmp]              DATETIME         NULL,
    [Is_ElectricCharge]        BIT              NULL,
    [isCharginFee]             BIT              NULL,
    [note]                     NVARCHAR (250)   NULL,
    [lock_reason]              NVARCHAR (100)   NULL,
    [card_return_request_date] DATETIME         NULL,
    [card_return_date]         DATETIME         NULL,
    [IdCardAttach]             UNIQUEIDENTIFIER NULL,
    [VehicleNoAttach]          UNIQUEIDENTIFIER NULL,
    [VehicleLicenseAttach]     UNIQUEIDENTIFIER NULL,
    [isHardLock]               BIT              NULL,
    [IsMonthlyScripts]         BIT              DEFAULT ((0)) NOT NULL,
    [DueDate]                  NVARCHAR (50)    NULL,
    [id]                       UNIQUEIDENTIFIER CONSTRAINT [DF_MAS_CardVehicle_id] DEFAULT (newid()) NOT NULL,
    [ImageUrl]                 NVARCHAR (MAX)   NULL,
    [ImageUrl2]                NVARCHAR (500)   NULL,
    [ImageUrl3]                NVARCHAR (500)   NULL,
    [ImageUrl4]                NVARCHAR (500)   NULL,
    [ImageUrl5]                NVARCHAR (500)   NULL,
    [Edit_Id]                  NVARCHAR (50)    NULL,
    [Edit_Dt]                  DATETIME         NULL,
    [tenant_oid]               UNIQUEIDENTIFIER NULL,
    [apartOid]                 UNIQUEIDENTIFIER NULL,
    [cardOid]                  UNIQUEIDENTIFIER NULL,
    [oid]                      UNIQUEIDENTIFIER CONSTRAINT [DF_MAS_CardVehicle_oid] DEFAULT (newid()) NOT NULL,
    CONSTRAINT [PK_MAS_CardVehicle] PRIMARY KEY CLUSTERED ([oid] ASC),
    CONSTRAINT [FK_MAS_CardVehicle_tenant_oid] FOREIGN KEY ([tenant_oid]) REFERENCES [dbo].[MAS_Projects] ([oid]),
    CONSTRAINT [UQ_MAS_CardVehicle_CardVehicleId] UNIQUE NONCLUSTERED ([CardVehicleId] ASC)
);






















GO
CREATE NONCLUSTERED INDEX [idx_MAS_CardVehicle_StartTime]
    ON [dbo].[MAS_CardVehicle]([StartTime] ASC);


GO
CREATE NONCLUSTERED INDEX [idx_MAS_CardVehicle_ProjectCd]
    ON [dbo].[MAS_CardVehicle]([ProjectCd] ASC);


GO
CREATE NONCLUSTERED INDEX [idx_MAS_CardVehicle_EndTime]
    ON [dbo].[MAS_CardVehicle]([EndTime] ASC);


GO
CREATE NONCLUSTERED INDEX [idx_MAS_CardVehicle_Auth_id]
    ON [dbo].[MAS_CardVehicle]([Auth_id] ASC);


GO
CREATE NONCLUSTERED INDEX [idx_MAS_CardVehicle_Mkr_Id]
    ON [dbo].[MAS_CardVehicle]([Mkr_Id] ASC);


GO
CREATE NONCLUSTERED INDEX [idx_MAS_CardVehicle_ApartmentId]
    ON [dbo].[MAS_CardVehicle]([ApartmentId] ASC);


GO
CREATE NONCLUSTERED INDEX [idx_MAS_CardVehicle_Status]
    ON [dbo].[MAS_CardVehicle]([Status] ASC);


GO
CREATE NONCLUSTERED INDEX [idx_MAS_CardVehicle_monthlyType]
    ON [dbo].[MAS_CardVehicle]([monthlyType] ASC);


GO
CREATE NONCLUSTERED INDEX [idx_MAS_CardVehicle_VehicleTypeId]
    ON [dbo].[MAS_CardVehicle]([VehicleTypeId] ASC);


GO
CREATE NONCLUSTERED INDEX [idx_MAS_CardVehicle_CardId]
    ON [dbo].[MAS_CardVehicle]([CardId] ASC);


GO
CREATE NONCLUSTERED INDEX [idx_MAS_CardVehicle_CustId]
    ON [dbo].[MAS_CardVehicle]([CustId] ASC);


GO
CREATE NONCLUSTERED INDEX [idx_MAS_CardVehicle_VehicleNo]
    ON [dbo].[MAS_CardVehicle]([VehicleNo] ASC);


GO
CREATE TRIGGER [dbo].[trg_mas_cardvehicle_update] 
   ON  dbo.MAS_CardVehicle
   FOR INSERT,UPDATE
AS 
BEGIN
	
	SET NOCOUNT ON;

			insert into LogMasVehicle(CardId,CardVehicleId,SysDt,Status,CreatedBy) select CardId,CardVehicleId,GETDATE(),Status,'no sys' from Inserted b where Status = 3 and locked_dt is null
			insert into LogMasVehicle(CardId,CardVehicleId,SysDt,Status,CreatedBy) select CardId,CardVehicleId,GETDATE(),Status,'system' from Inserted b where status = 3 and locked_dt is not null

			IF ( UPDATE (Status) and exists(select 1 from Inserted where status = 3 and locked_dt is null))  
			BEGIN  
				RAISERROR (50009, 16, 10)  
			END;  

END
GO



GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Quản lý thẻ gửi xe', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'MAS_CardVehicle';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Ngày gửi yêu cầu trả lại thẻ xe', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'MAS_CardVehicle', @level2type = N'COLUMN', @level2name = N'card_return_request_date';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Ngày thực hiện trả lại thẻ xe', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'MAS_CardVehicle', @level2type = N'COLUMN', @level2name = N'card_return_date';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Biển số xe', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'MAS_CardVehicle', @level2type = N'COLUMN', @level2name = N'VehicleNoAttach';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Giấy đăng ký xe', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'MAS_CardVehicle', @level2type = N'COLUMN', @level2name = N'VehicleLicenseAttach';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'CMT/CCCD', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'MAS_CardVehicle', @level2type = N'COLUMN', @level2name = N'IdCardAttach';


GO
CREATE NONCLUSTERED INDEX [IX_MAS_CardVehicle_cardOid]
    ON [dbo].[MAS_CardVehicle]([cardOid] ASC);

