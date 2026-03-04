CREATE TABLE [dbo].[MAS_Apartment_Reg] (
    [Id]         BIGINT           IDENTITY (1, 1) NOT NULL,
    [userId]     NVARCHAR (100)   NOT NULL,
    [roomCode]   NVARCHAR (20)    NOT NULL,
    [contractNo] NVARCHAR (100)   NULL,
    [relationId] INT              NULL,
    [reg_dt]     DATETIME         CONSTRAINT [DF_MAS_Apartment_Reg_reg_dt] DEFAULT (getdate()) NULL,
    [reg_st]     INT              CONSTRAINT [DF_MAS_Apartment_Reg_reg_st] DEFAULT ((0)) NULL,
    [auth_dt]    DATETIME         NULL,
    [row_guid]   UNIQUEIDENTIFIER CONSTRAINT [DF_MAS_Apartment_Reg_oid] DEFAULT (newid()) NOT NULL,
    [tenant_oid] UNIQUEIDENTIFIER NULL,
    CONSTRAINT [PK_MAS_Apartment_Reg] PRIMARY KEY CLUSTERED ([roomCode] ASC, [userId] ASC),
    CONSTRAINT [FK_MAS_Apartment_Reg_tenant_oid] FOREIGN KEY ([tenant_oid]) REFERENCES [dbo].[MAS_Projects] ([oid])
);

