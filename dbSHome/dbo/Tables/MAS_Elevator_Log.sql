CREATE TABLE [dbo].[MAS_Elevator_Log] (
    [LogId]      INT              IDENTITY (1, 1) NOT NULL,
    [HardwareId] NVARCHAR (50)    NOT NULL,
    [userId]     NVARCHAR (100)   NOT NULL,
    [LogDt]      DATETIME         NOT NULL,
    [oid]        UNIQUEIDENTIFIER CONSTRAINT [DF_MAS_Elevator_Log_oid] DEFAULT (newid()) NOT NULL,
    [tenant_oid] UNIQUEIDENTIFIER NULL,
    CONSTRAINT [PK_MAS_Elevator_Log] PRIMARY KEY CLUSTERED ([LogId] ASC),
    CONSTRAINT [FK_MAS_Elevator_Log_tenant_oid] FOREIGN KEY ([tenant_oid]) REFERENCES [dbo].[MAS_Projects] ([oid])
);








GO
CREATE NONCLUSTERED INDEX [idx_MAS_Elevator_Log_LogDt]
    ON [dbo].[MAS_Elevator_Log]([LogDt] ASC);


GO
CREATE NONCLUSTERED INDEX [idx_MAS_Elevator_Log_HardwareId_userId]
    ON [dbo].[MAS_Elevator_Log]([HardwareId] ASC, [userId] ASC);


GO
CREATE NONCLUSTERED INDEX [IX_ELog_User_LogDt_Includes]
    ON [dbo].[MAS_Elevator_Log]([userId] ASC, [LogDt] DESC)
    INCLUDE([LogId], [HardwareId]);

