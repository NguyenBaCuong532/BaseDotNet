CREATE TABLE [dbo].[MAS_CardVehicle_Pay] (
    [PayId]         INT              IDENTITY (1, 1) NOT NULL,
    [CardVehicleId] INT              NOT NULL,
    [PayDt]         DATETIME         NULL,
    [empUserId]     NVARCHAR (300)   NOT NULL,
    [Amount]        DECIMAL (18)     NOT NULL,
    [StartDt]       DATE             NULL,
    [EndDt]         DATE             NULL,
    [Remart]        NVARCHAR (300)   NOT NULL,
    [paymentId]     UNIQUEIDENTIFIER CONSTRAINT [DF_MAS_CardVehicle_Pay_paymentId] DEFAULT (newid()) NULL,
    [price_oid]     UNIQUEIDENTIFIER NULL,
    [month_price]   DECIMAL (18)     NULL,
    [month_num]     FLOAT (53)       NULL,
    [payment_st]    INT              NULL,
    [created_dt]    DATETIME         NULL,
    [created_by]    UNIQUEIDENTIFIER NULL,
    [updated_dt]    DATETIME         NULL,
    [updated_by]    UNIQUEIDENTIFIER NULL,
    [oid]           UNIQUEIDENTIFIER CONSTRAINT [DF_MAS_CardVehicle_Pay_oid] DEFAULT (newid()) NOT NULL,
    [tenant_oid]    UNIQUEIDENTIFIER NULL,
    CONSTRAINT [PK_MAS_CardVehiclePay] PRIMARY KEY CLUSTERED ([PayId] ASC),
    CONSTRAINT [FK_MAS_CardVehicle_Pay_tenant_oid] FOREIGN KEY ([tenant_oid]) REFERENCES [dbo].[MAS_Projects] ([oid])
);

