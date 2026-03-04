CREATE TABLE [dbo].[MAS_Apartment_HostChange_History] (
    [HistoryId]         UNIQUEIDENTIFIER CONSTRAINT [DF_MAS_AptHostHist_HistoryId] DEFAULT (newid()) NOT NULL,
    [ApartmentId]       INT              NOT NULL,
    [OldCustId]         NVARCHAR (50)    NULL,
    [NewCustId]         NVARCHAR (50)    NULL,
    [CheckFlag]         BIT              NOT NULL,
    [RelationId]        INT              NULL,
    [IsForeign]         BIT              NULL,
    [LeaveId]           BIT              NULL,
    [ApproveDt]         DATETIME         NULL,
    [ApproveDtEnd]      DATETIME         NULL,
    [ContractDate]      DATE             NULL,
    [Note]              NVARCHAR (MAX)   NULL,
    [UserLogin]         NVARCHAR (100)   NULL,
    [PerformedByUserId] NVARCHAR (450)   NULL,
    [PerformedAt]       DATETIME         CONSTRAINT [DF_MAS_AptHostHist_PerformedAt] DEFAULT (getdate()) NOT NULL,
    [CustId]            NVARCHAR (50)    NULL,
    [tenant_oid]        UNIQUEIDENTIFIER NULL,
    [apartOid]          UNIQUEIDENTIFIER NULL,
    CONSTRAINT [PK_MAS_AptHostHist] PRIMARY KEY CLUSTERED ([HistoryId] ASC),
    CONSTRAINT [FK_MAS_Apartment_HostChange_History_tenant_oid] FOREIGN KEY ([tenant_oid]) REFERENCES [dbo].[MAS_Projects] ([oid])
);






GO
CREATE NONCLUSTERED INDEX [IX_MAS_AptHostHist_OldCust_NewCust]
    ON [dbo].[MAS_Apartment_HostChange_History]([OldCustId] ASC, [NewCustId] ASC);


GO
CREATE NONCLUSTERED INDEX [IX_MAS_AptHostHist_ApartmentId_PerformedAt]
    ON [dbo].[MAS_Apartment_HostChange_History]([ApartmentId] ASC, [PerformedAt] DESC);

