CREATE TABLE [dbo].[MAS_Elevator_Card] (
    [Id]          INT              IDENTITY (1, 1) NOT NULL,
    [CardId]      INT              NOT NULL,
    [CardRole]    INT              NULL,
    [CardType]    INT              NOT NULL,
    [ProjectCd]   NVARCHAR (30)    NULL,
    [AreaCd]      NVARCHAR (50)    NULL,
    [FloorNumber] INT              NULL,
    [Note]        NVARCHAR (50)    NULL,
    [created_at]  DATETIME         CONSTRAINT [DF_MAS_Elevator_Card_created_at] DEFAULT (getdate()) NULL,
    [created_by]  UNIQUEIDENTIFIER NULL,
    [Oid]         UNIQUEIDENTIFIER CONSTRAINT [DF_MAS_Elevator_Card_Oid] DEFAULT (newid()) NOT NULL,
    [BuildCd]     NVARCHAR (50)    NULL,
    [buildingCd]  NVARCHAR (50)    NULL,
    [tenant_oid]  UNIQUEIDENTIFIER NULL,
    [cardOid]     UNIQUEIDENTIFIER NULL,
    CONSTRAINT [PK_MAS_Elevator_Card] PRIMARY KEY CLUSTERED ([Oid] ASC),
    CONSTRAINT [FK_MAS_Elevator_Card_tenant_oid] FOREIGN KEY ([tenant_oid]) REFERENCES [dbo].[MAS_Projects] ([oid]),
    CONSTRAINT [UQ_MAS_Elevator_Card_Id] UNIQUE NONCLUSTERED ([Id] ASC)
);














GO
CREATE NONCLUSTERED INDEX [idx_MAS_Elevator_Card_FloorNumber]
    ON [dbo].[MAS_Elevator_Card]([FloorNumber] ASC);


GO
CREATE NONCLUSTERED INDEX [idx_MAS_Elevator_Card_BuildCd]
    ON [dbo].[MAS_Elevator_Card]([BuildCd] ASC);




GO
CREATE NONCLUSTERED INDEX [idx_MAS_Elevator_Card_CardType]
    ON [dbo].[MAS_Elevator_Card]([CardType] ASC);


GO
CREATE NONCLUSTERED INDEX [idx_MAS_Elevator_Card_ProjectCd]
    ON [dbo].[MAS_Elevator_Card]([ProjectCd] ASC);


GO
CREATE NONCLUSTERED INDEX [idx_MAS_Elevator_Card_CardRole]
    ON [dbo].[MAS_Elevator_Card]([CardRole] ASC);


GO
CREATE NONCLUSTERED INDEX [idx_MAS_Elevator_Card_CardId]
    ON [dbo].[MAS_Elevator_Card]([CardId] ASC);


GO
CREATE NONCLUSTERED INDEX [IX_EleCard_Role_Project]
    ON [dbo].[MAS_Elevator_Card]([CardId] ASC, [CardRole] ASC, [ProjectCd] ASC, [AreaCd] ASC, [FloorNumber] ASC, [CardType] ASC);


GO
CREATE NONCLUSTERED INDEX [idx_MAS_Elevator_Card_AreaCd]
    ON [dbo].[MAS_Elevator_Card]([AreaCd] ASC);


GO
CREATE NONCLUSTERED INDEX [IX_MAS_Elevator_Card_cardOid]
    ON [dbo].[MAS_Elevator_Card]([cardOid] ASC);

