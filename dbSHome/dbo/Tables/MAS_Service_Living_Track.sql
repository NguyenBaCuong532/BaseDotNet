CREATE TABLE [dbo].[MAS_Service_Living_Track] (
    [TrackId]      BIGINT           IDENTITY (1, 1) NOT NULL,
    [ProjectCd]    NVARCHAR (30)    NULL,
    [ApartmentId]  INT              NOT NULL,
    [LivingTypeId] INT              NOT NULL,
    [MeterSerial]  NVARCHAR (30)    NULL,
    [Value]        FLOAT (53)       NULL,
    [oid]          UNIQUEIDENTIFIER CONSTRAINT [DF_MAS_Service_Living_Track_oid] DEFAULT (newid()) NOT NULL,
    [tenant_oid]   UNIQUEIDENTIFIER NULL,
    [apartOid]     UNIQUEIDENTIFIER NULL,
    CONSTRAINT [PK_MAS_Service_Living_Track] PRIMARY KEY CLUSTERED ([TrackId] ASC),
    CONSTRAINT [FK_MAS_Service_Living_Track_tenant_oid] FOREIGN KEY ([tenant_oid]) REFERENCES [dbo].[MAS_Projects] ([oid])
);

