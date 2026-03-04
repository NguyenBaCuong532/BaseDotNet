CREATE TABLE [dbo].[MAS_CardEdit_H] (
    [ActionType]   INT              NULL,
    [StartDate]    NVARCHAR (50)    NULL,
    [EndDate]      NVARCHAR (50)    NULL,
    [VehicleType]  INT              NULL,
    [CardCdBefore] NVARCHAR (50)    NULL,
    [CardCdAfter]  NVARCHAR (50)    NULL,
    [OwnerBefore]  NVARCHAR (100)   NULL,
    [OwnerAfter]   NVARCHAR (100)   NULL,
    [VehicleNo]    NVARCHAR (50)    NULL,
    [UserId]       NVARCHAR (100)   NULL,
    [SaveDate]     NVARCHAR (50)    NULL,
    [Note]         NVARCHAR (250)   NULL,
    [oid]          UNIQUEIDENTIFIER CONSTRAINT [DF_MAS_CardEdit_H_oid] DEFAULT (newid()) NOT NULL,
    [tenant_oid]   UNIQUEIDENTIFIER NULL,
    CONSTRAINT [FK_MAS_CardEdit_H_tenant_oid] FOREIGN KEY ([tenant_oid]) REFERENCES [dbo].[MAS_Projects] ([oid])
);

