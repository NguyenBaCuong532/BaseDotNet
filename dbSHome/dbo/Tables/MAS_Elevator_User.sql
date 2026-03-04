CREATE TABLE [dbo].[MAS_Elevator_User] (
    [Id]          BIGINT           IDENTITY (1, 1) NOT NULL,
    [userId]      NVARCHAR (100)   NOT NULL,
    [HardwareId]  NVARCHAR (50)    NULL,
    [floorName]   NVARCHAR (10)    NOT NULL,
    [floorNumber] INT              NULL,
    [sysDt]       DATETIME         CONSTRAINT [DF_MAS_Elevator_User_SysDt] DEFAULT (getdate()) NOT NULL,
    [projectCd]   NVARCHAR (20)    NULL,
    [oid]         UNIQUEIDENTIFIER CONSTRAINT [DF_MAS_Elevator_User_oid] DEFAULT (newid()) NOT NULL,
    [tenant_oid]  UNIQUEIDENTIFIER NULL,
    CONSTRAINT [PK_MAS_Elevator_User] PRIMARY KEY CLUSTERED ([Id] ASC),
    CONSTRAINT [FK_MAS_Elevator_User_tenant_oid] FOREIGN KEY ([tenant_oid]) REFERENCES [dbo].[MAS_Projects] ([oid])
);








GO
CREATE NONCLUSTERED INDEX [idx_MAS_Elevator_User_HardwareId]
    ON [dbo].[MAS_Elevator_User]([HardwareId] ASC);


GO
CREATE NONCLUSTERED INDEX [idx_MAS_Elevator_User_sysDt]
    ON [dbo].[MAS_Elevator_User]([sysDt] ASC);


GO
CREATE NONCLUSTERED INDEX [idx_MAS_Elevator_User_floorName]
    ON [dbo].[MAS_Elevator_User]([floorName] ASC);


GO
CREATE NONCLUSTERED INDEX [idx_MAS_Elevator_User_userId]
    ON [dbo].[MAS_Elevator_User]([userId] ASC);

