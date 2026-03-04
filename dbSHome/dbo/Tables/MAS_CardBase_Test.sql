CREATE TABLE [dbo].[MAS_CardBase_Test] (
    [Guid_Cd]        UNIQUEIDENTIFIER CONSTRAINT [DF__MAS_CardB__Guid___70C39DF3] DEFAULT (newid()) NOT NULL,
    [Card_Num]       NVARCHAR (20)    NOT NULL,
    [Card_Hex]       NVARCHAR (50)    NULL,
    [Code]           NVARCHAR (20)    NOT NULL,
    [IsUsed]         BIT              NULL,
    [SysDate]        DATETIME         CONSTRAINT [DF__MAS_CardB__SysDa__71B7C22C] DEFAULT (getdate()) NOT NULL,
    [ProjectCode]    NVARCHAR (50)    NULL,
    [SubProjectCode] NVARCHAR (50)    NULL,
    [Type]           INT              NULL,
    [rowguid]        UNIQUEIDENTIFIER CONSTRAINT [DF__MAS_CardB__rowgu__72ABE665] DEFAULT (newsequentialid()) ROWGUIDCOL NOT NULL,
    [LotNumber]      NVARCHAR (50)    NULL,
    [tenant_oid]     UNIQUEIDENTIFIER NULL,
    CONSTRAINT [FK_MAS_CardBase_Test_tenant_oid] FOREIGN KEY ([tenant_oid]) REFERENCES [dbo].[MAS_Projects] ([oid])
);






GO
CREATE NONCLUSTERED INDEX [IX_MAS_CardBase_ProjectCode_Code_INCL]
    ON [dbo].[MAS_CardBase_Test]([ProjectCode] ASC, [Code] ASC)
    INCLUDE([Guid_Cd], [Card_Num], [Card_Hex], [IsUsed], [SysDate]);


GO
CREATE NONCLUSTERED INDEX [IX_CardBase_Code]
    ON [dbo].[MAS_CardBase_Test]([Code] ASC);


GO
CREATE NONCLUSTERED INDEX [idx_MAS_CardBase_IsUsed]
    ON [dbo].[MAS_CardBase_Test]([IsUsed] ASC);


GO
CREATE UNIQUE NONCLUSTERED INDEX [idx_MAS_CardBase_Card_Num]
    ON [dbo].[MAS_CardBase_Test]([Card_Num] ASC);


GO
CREATE UNIQUE NONCLUSTERED INDEX [MSmerge_index_1437390523]
    ON [dbo].[MAS_CardBase_Test]([rowguid] ASC);


GO

CREATE TRIGGER [dbo].[MSmerge_ins_B4AA33E3914D4D9590EF992FEDEABF6F]
ON [dbo].[MAS_CardBase_Test]
WITH EXECUTE AS CALLER
FOR INSERT
AS
declare @is_mergeagent bit, @at_publisher bit, @retcode smallint 

    set rowcount 0
    set transaction isolation level read committed

        select @is_mergeagent = convert(bit, sessionproperty('replication_agent'))
        select @at_publisher = 0 
    if (select trigger_nestlevel()) = 1 and @is_mergeagent = 1
        return  
    declare @article_rows_inserted int
    select @article_rows_inserted =  count(*) from inserted 
    if @article_rows_inserted = 0 
        return
    declare @tablenick int, @rowguid uniqueidentifier
    , @replnick binary(6), @lineage varbinary(311), @colv1 varbinary(1), @cv varbinary(1)
    , @ccols int, @newgen bigint, @version int, @curversion int
    , @oldmaxversion int, @child_newgen bigint, @child_oldmaxversion int, @child_metadatarows_updated int 
    , @logical_record_parent_rowguid uniqueidentifier 
    , @num_parent_rows int, @parent_row_inserted bit, @ts_rows_exist bit, @marker uniqueidentifier 
    declare @dt datetime
    declare @nickbin varbinary(8)
    declare @error int 
    set nocount on
    set @tablenick = 441005     
    set @lineage = 0x0
    set @retcode = 0
    select @oldmaxversion= maxversion_at_cleanup from dbo.sysmergearticles where nickname = @tablenick
    select @dt = getdate()

    select @replnick = 0x517ce0d26d07 
    set @nickbin= @replnick + 0xFF

    select @newgen = NULL
        select top 1 @newgen = generation from [dbo].[MSmerge_genvw_B4AA33E3914D4D9590EF992FEDEABF6F] with (rowlock, updlock, readpast) 
        where art_nick = 441005      and genstatus = 0
            and  changecount <= (1000 - isnull(@article_rows_inserted,0))
    if @newgen is NULL
    begin
        insert into [dbo].[MSmerge_genvw_B4AA33E3914D4D9590EF992FEDEABF6F] with (rowlock)
            (guidsrc, genstatus, art_nick, nicknames, coldate, changecount)
             values   (newid(), 0, @tablenick, @nickbin, @dt, @article_rows_inserted)
        select @error = @@error, @newgen = @@identity    
        if @error<>0 or @newgen is NULL
            goto FAILURE
    end
    else
    begin
        -- now update the changecount of the generation we go to reflect the number of rows we put in this generation
        update [dbo].[MSmerge_genvw_B4AA33E3914D4D9590EF992FEDEABF6F]  with (rowlock)
            set changecount = changecount + @article_rows_inserted
            where generation = @newgen
        if @@error<>0 goto FAILURE
    end
    set @lineage = { fn UPDATELINEAGE (0x0, @replnick, 1) }
            set @colv1 = NULL
    if (@@error <> 0)
    begin
        goto FAILURE
    end

    select @ts_rows_exist = 0 
        select @ts_rows_exist = 1 where exists (select ts.rowguid from inserted i, [dbo].[MSmerge_tsvw_B4AA33E3914D4D9590EF992FEDEABF6F] ts with (rowlock) where ts.tablenick = @tablenick and ts.rowguid = i.rowguidcol)     
    if @ts_rows_exist = 1
    begin    
        select @version = max({fn GETMAXVERSION(lineage)}) from [dbo].[MSmerge_tsvw_B4AA33E3914D4D9590EF992FEDEABF6F] where 
            tablenick = @tablenick and rowguid in (select rowguidcol from inserted) 

        if @version is not null
        begin
            -- reset lineage and colv to higher version...
            set @curversion = 0
            while (@curversion <= @version)
            begin
                set @lineage = { fn UPDATELINEAGE (@lineage, @replnick, @oldmaxversion+1) }
                set @curversion= { fn GETMAXVERSION(@lineage) }
            end

            if (@colv1 IS NOT NULL)
                set @colv1 = { fn UPDATECOLVBM(@colv1, @replnick, 0x01, 0x00, { fn GETMAXVERSION(@lineage) }) }    
                delete from [dbo].[MSmerge_tsvw_B4AA33E3914D4D9590EF992FEDEABF6F] with (rowlock) where tablenick = @tablenick and rowguid in
                    (select rowguidcol from inserted) 
        end
    end 
    select @marker = newid()  
        insert into [dbo].[MSmerge_ctsv_B4AA33E3914D4D9590EF992FEDEABF6F] with (rowlock) (tablenick, rowguid, lineage, colv1, generation, partchangegen, marker) 
        select @tablenick, rowguidcol, @lineage, @colv1, @newgen, (-@newgen), @marker
        from inserted i where not exists
        (select rowguid from [dbo].[MSmerge_ctsv_B4AA33E3914D4D9590EF992FEDEABF6F] with (readcommitted, rowlock, readpast) where tablenick = @tablenick and rowguid = i.rowguidcol)  
    if @@error <> 0 
        goto FAILURE   

    return
FAILURE:
    if @@trancount > 0
        rollback tran
    raiserror (20041, 16, -1)
    return
GO


-- ----------------------------
-- Triggers structure for table MAS_CardBase
-- ----------------------------
CREATE TRIGGER [dbo].[MSmerge_del_B4AA33E3914D4D9590EF992FEDEABF6F]
ON [dbo].[MAS_CardBase_Test]
WITH EXECUTE AS CALLER
FOR DELETE
AS
declare @is_mergeagent bit, @at_publisher bit, @retcode smallint 

    set rowcount 0
    set transaction isolation level read committed

            select @is_mergeagent = convert(bit, sessionproperty('replication_agent'))
            select @at_publisher = 0 
    if (select trigger_nestlevel()) = 1 and @is_mergeagent = 1
        return 
    declare @article_rows_deleted int
    declare @xe_message varbinary(1000)
    select @article_rows_deleted = count(*) from deleted
    if @article_rows_deleted=0
        return
    declare @tablenick int, @replnick binary(6), 
            @lineage varbinary(311), @newgen bigint, @oldmaxversion int, @child_newgen bigint, 
            @child_oldmaxversion int, @child_metadatarows_updated int, @cv varbinary(1),
            @logical_record_parent_oldmaxversion int, @logical_record_lineage varbinary(311), @logical_record_parent_regular_lineage varbinary(311), @logical_record_parent_gencur bigint,
            @num_parent_rows int, @logical_record_parent_rowguid uniqueidentifier, @parent_row_inserted bit, @rowguid uniqueidentifier 
    declare @dt datetime, @nickbin varbinary(8), @error int
     
    set nocount on
    select @tablenick = 441005     
    if @article_rows_deleted = 1 select @rowguid = rowguidcol from deleted
    select @oldmaxversion= maxversion_at_cleanup from dbo.sysmergearticles where nickname = @tablenick
    select @dt = getdate()

    select @replnick = 0x517ce0d26d07
    set @nickbin= @replnick + 0xFF

    select @newgen = NULL
        select top 1 @newgen = generation from [dbo].[MSmerge_genvw_B4AA33E3914D4D9590EF992FEDEABF6F] with (rowlock, updlock, readpast) 
        where art_nick = 441005       and genstatus = 0    
        
            and  changecount <= (1000 - isnull(@article_rows_deleted,0))
    if @newgen is NULL
    begin
        insert into [dbo].[MSmerge_genvw_B4AA33E3914D4D9590EF992FEDEABF6F]  with (rowlock)
            (guidsrc, genstatus, art_nick, nicknames, coldate, changecount)
               values (newid(), 0, @tablenick, @nickbin, @dt, @article_rows_deleted)
        select @error = @@error, @newgen = @@identity    
        if @error<>0 or @newgen is NULL
            goto FAILURE
    end
    else
    begin
        -- now update the changecount of the generation we go to reflect the number of rows we put in this generation
        update [dbo].[MSmerge_genvw_B4AA33E3914D4D9590EF992FEDEABF6F]  with (rowlock)
            set changecount = changecount + @article_rows_deleted
            where generation = @newgen
        if @@error<>0 goto FAILURE
    end
  
    set @lineage = { fn UPDATELINEAGE(0x0, @replnick, @oldmaxversion+1) }  
    if @article_rows_deleted = 1
        insert into [dbo].[MSmerge_tsvw_B4AA33E3914D4D9590EF992FEDEABF6F] with (rowlock) (rowguid, tablenick, type, lineage, generation)
            select @rowguid, @tablenick, 1, isnull((select { fn UPDATELINEAGE(COALESCE(c.lineage, @lineage), @replnick, @oldmaxversion+1) } from 
            [dbo].[MSmerge_ctsv_B4AA33E3914D4D9590EF992FEDEABF6F] c with (rowlock) where c.tablenick = @tablenick and c.rowguid = @rowguid),@lineage), @newgen
    else
        insert into [dbo].[MSmerge_tsvw_B4AA33E3914D4D9590EF992FEDEABF6F] with (rowlock) (rowguid, tablenick, type, lineage, generation)
            select d.rowguidcol, @tablenick, 1, { fn UPDATELINEAGE(COALESCE(c.lineage, @lineage), @replnick, @oldmaxversion+1) }, @newgen from 
            deleted d left outer join [dbo].[MSmerge_ctsv_B4AA33E3914D4D9590EF992FEDEABF6F] c with (rowlock) on c.tablenick = @tablenick and c.rowguid = d.rowguidcol 
             
    if @@error <> 0
        GOTO FAILURE  
        delete [dbo].[MSmerge_ctsv_B4AA33E3914D4D9590EF992FEDEABF6F]  with (rowlock)
        from deleted d, [dbo].[MSmerge_ctsv_B4AA33E3914D4D9590EF992FEDEABF6F] cont with (rowlock)
        where cont.tablenick = @tablenick and cont.rowguid = d.rowguidcol
        option (force order, loop join)

    if @@error <> 0
        GOTO FAILURE

    -- DEBUG    insert into MSmerge_debug (okay,artnick,generation_old,twhen,comment) values
    -- DEBUG        (0, @tablenick, @newgen, getdate(), 'del_trg')
    
    return
FAILURE:
    if @@trancount > 0
        rollback tran
    raiserror (20041, 16, -1)
    return