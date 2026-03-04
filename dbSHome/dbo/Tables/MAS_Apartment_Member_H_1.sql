CREATE TABLE [dbo].[MAS_Apartment_Member_H] (
    [Oid]               UNIQUEIDENTIFIER CONSTRAINT [DF_MAS_Apartment_Member_H_Oid] DEFAULT (newid()) NOT NULL,
    [ApartmentId]       INT              NOT NULL,
    [CustId]            NVARCHAR (50)    NOT NULL,
    [OldCustId]         NVARCHAR (50)    NULL,
    [NewCustId]         NVARCHAR (50)    NULL,
    [FullName]          NVARCHAR (200)   NULL,
    [Phone]             NVARCHAR (50)    NULL,
    [Email]             NVARCHAR (150)   NULL,
    [Birthday]          DATETIME         NULL,
    [IsSex]             BIT              NULL,
    [Gender]            TINYINT          NULL,
    [RelationId]        INT              NULL,
    [RelationName]      NVARCHAR (100)   NULL,
    [IsOwner]           BIT              CONSTRAINT [DF__MAS_Apart__IsOwn__7375ED6C] DEFAULT ((0)) NOT NULL,
    [HostFullName]      NVARCHAR (200)   NULL,
    [IsForeign]         BIT              NULL,
    [IsForeigner]       BIT              NULL,
    [CountryCd]         NVARCHAR (50)    NULL,
    [Nationality]       NVARCHAR (100)   NULL,
    [ApproveDt]         DATETIME         NULL,
    [ApproveDtEnd]      DATETIME         NULL,
    [ContractDate]      DATE             NULL,
    [EffectiveDate]     DATE             NOT NULL,
    [ExpiredDate]       DATE             NULL,
    [CheckFlag]         BIT              CONSTRAINT [DF_MAS_Apartment_Member_H_CheckFlag] DEFAULT ((0)) NULL,
    [ActionType]        NVARCHAR (50)    NULL,
    [Note]              NVARCHAR (MAX)   NULL,
    [UserLogin]         NVARCHAR (100)   NULL,
    [PerformedByUserId] NVARCHAR (450)   NULL,
    [PerformedAt]       DATETIME         CONSTRAINT [DF_MAS_Apartment_Member_H_PerformedAt] DEFAULT (getdate()) NOT NULL,
    [CreatedBy]         NVARCHAR (50)    NULL,
    [CreatedDate]       DATETIME         CONSTRAINT [DF__MAS_Apart__Creat__76525A17] DEFAULT (getdate()) NOT NULL,
    [IsNotification]    BIT              NULL,
    [member_st]         INT              NULL,
    [LeaveId]           BIGINT           NULL,
    [tenant_oid]        UNIQUEIDENTIFIER NULL,
    [apartOid]          UNIQUEIDENTIFIER NULL,
    CONSTRAINT [PK__MAS_Apar__CB3E4F316D0B87FF] PRIMARY KEY CLUSTERED ([Oid] ASC),
    CONSTRAINT [FK_MAS_Apartment_Member_H_tenant_oid] FOREIGN KEY ([tenant_oid]) REFERENCES [dbo].[MAS_Projects] ([oid])
);






GO
CREATE NONCLUSTERED INDEX [IX_MAS_Apartment_Member_H_ApartmentId_PerformedAt]
    ON [dbo].[MAS_Apartment_Member_H]([ApartmentId] ASC, [PerformedAt] DESC);

