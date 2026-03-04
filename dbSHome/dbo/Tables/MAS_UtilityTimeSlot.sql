CREATE TABLE [dbo].[MAS_UtilityTimeSlot] (
    [TimeSlotId]    INT              IDENTITY (1, 1) NOT NULL,
    [requestTypeId] INT              NOT NULL,
    [fromTime]      INT              NULL,
    [toTime]        INT              NULL,
    [isFree]        BIT              NULL,
    [price]         DECIMAL (18)     NULL,
    [unit]          NVARCHAR (50)    NULL,
    [note]          NVARCHAR (200)   NULL,
    [isReady]       BIT              NULL,
    [oid]           UNIQUEIDENTIFIER CONSTRAINT [DF_MAS_UtilityTimeSlot_oid] DEFAULT (newid()) NOT NULL,
    [tenant_oid]    UNIQUEIDENTIFIER NULL,
    CONSTRAINT [PK_MAS_Utility_Time_Slot] PRIMARY KEY CLUSTERED ([TimeSlotId] ASC),
    CONSTRAINT [FK_MAS_UtilityTimeSlot_tenant_oid] FOREIGN KEY ([tenant_oid]) REFERENCES [dbo].[MAS_Projects] ([oid])
);

