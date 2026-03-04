CREATE TABLE [dbo].[TRS_Request_Card] (
    [RequestId]  INT              NOT NULL,
    [CustId]     NVARCHAR (50)    NOT NULL,
    [CardTypeId] INT              NULL,
    [IsVehicle]  BIT              NULL,
    [Auth_St]    BIT              NULL,
    [Auth_Dt]    DATETIME         NULL,
    [Auth_Id]    NVARCHAR (450)   NULL,
    [CardId]     INT              NULL,
    [Status]     INT              NULL,
    [sysDate]    DATETIME         CONSTRAINT [DF_TRS_Request_Card_sysDate] DEFAULT (getdate()) NULL,
    [oid]        UNIQUEIDENTIFIER CONSTRAINT [DF_TRS_Request_Card_oid] DEFAULT (newid()) NOT NULL,
    [tenant_oid] UNIQUEIDENTIFIER NULL,
    [cardOid]    UNIQUEIDENTIFIER NULL,
    CONSTRAINT [PK_TRS_Request_Card] PRIMARY KEY CLUSTERED ([RequestId] ASC),
    CONSTRAINT [FK_TRS_Request_Card_tenant_oid] FOREIGN KEY ([tenant_oid]) REFERENCES [dbo].[MAS_Projects] ([oid])
);

