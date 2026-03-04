CREATE TABLE [dbo].[MAS_Cards_Test] (
    [CardId]        INT              IDENTITY (1, 1) NOT FOR REPLICATION NOT NULL,
    [CardCd]        NVARCHAR (50)    NOT NULL,
    [CardTypeId]    INT              NULL,
    [ImageUrl]      NVARCHAR (250)   NULL,
    [IssueDate]     DATETIME         NULL,
    [ExpireDate]    DATETIME         NULL,
    [CustId]        NVARCHAR (50)    NULL,
    [Card_St]       INT              NULL,
    [IsVip]         BIT              NULL,
    [CardName]      NVARCHAR (150)   NULL,
    [IsDaily]       BIT              NOT NULL,
    [IsClose]       BIT              NULL,
    [CloseDate]     DATETIME         NULL,
    [RequestId]     INT              NULL,
    [ApartmentId]   INT              NULL,
    [ProjectCd]     NVARCHAR (30)    NULL,
    [VehicleTypeId] INT              NULL,
    [StarLevel]     INT              NULL,
    [IsGuest]       BIT              NULL,
    [isVehicle]     BIT              NULL,
    [isCredit]      BIT              NULL,
    [partner_id]    INT              NULL,
    [created_by]    NVARCHAR (100)   NULL,
    [CloseBy]       NVARCHAR (100)   NULL,
    [rowguid]       UNIQUEIDENTIFIER DEFAULT (newsequentialid()) ROWGUIDCOL NOT NULL,
    [SelfLock]      BIT              NULL,
    [IsLost]        BIT              NULL,
    [oid]           UNIQUEIDENTIFIER CONSTRAINT [DF_MAS_Cards_Test_oid] DEFAULT (newid()) NOT NULL,
    [tenant_oid]    UNIQUEIDENTIFIER NULL,
    CONSTRAINT [FK_MAS_Cards_Test_tenant_oid] FOREIGN KEY ([tenant_oid]) REFERENCES [dbo].[MAS_Projects] ([oid])
);






GO
CREATE NONCLUSTERED INDEX [idx_MAS_Cards_partner_id]
    ON [dbo].[MAS_Cards_Test]([partner_id] ASC);


GO
CREATE NONCLUSTERED INDEX [idx_MAS_Cards_IsGuest]
    ON [dbo].[MAS_Cards_Test]([IsGuest] ASC);


GO
CREATE NONCLUSTERED INDEX [idx_MAS_Cards_IsVip]
    ON [dbo].[MAS_Cards_Test]([IsVip] ASC);


GO
CREATE NONCLUSTERED INDEX [idx_MAS_Cards_IsDaily]
    ON [dbo].[MAS_Cards_Test]([IsDaily] ASC);


GO
CREATE NONCLUSTERED INDEX [idx_MAS_Cards_CardCd]
    ON [dbo].[MAS_Cards_Test]([CardCd] ASC);


GO
CREATE NONCLUSTERED INDEX [idx_MAS_Cards_CardTypeId]
    ON [dbo].[MAS_Cards_Test]([CardTypeId] ASC);


GO
CREATE NONCLUSTERED INDEX [idx_MAS_Cards_Card_St]
    ON [dbo].[MAS_Cards_Test]([Card_St] ASC);


GO
CREATE NONCLUSTERED INDEX [idx_MAS_Cards_ApartmentId]
    ON [dbo].[MAS_Cards_Test]([ApartmentId] ASC);


GO
CREATE NONCLUSTERED INDEX [idx_MAS_Cards_projectCd]
    ON [dbo].[MAS_Cards_Test]([ProjectCd] ASC);


GO
CREATE NONCLUSTERED INDEX [idx_MAS_Cards_CustId]
    ON [dbo].[MAS_Cards_Test]([CustId] ASC);


GO
CREATE UNIQUE NONCLUSTERED INDEX [MSmerge_index_1569583013]
    ON [dbo].[MAS_Cards_Test]([rowguid] ASC);


GO

CREATE TRIGGER [dbo].[MSmerge_upd_9D6354C0F20943F092E3BF1330B06748]
ON [dbo].[MAS_Cards_Test]
WITH EXECUTE AS CALLER
FOR UPDATE
AS
declare @is_mergeagent bit, @at_publisher bit, @retcode int 

    set rowcount 0
    set transaction isolation level read committed

        select @is_mergeagent = convert(bit, sessionproperty('replication_agent'))
        select @at_publisher = 0  
    if (select trigger_nestlevel()) = 1 and @is_mergeagent = 1
        return   
    declare @article_rows_updated int
    -- Should use @@rowcount below but there is a bug because of which sometimes in the presence of 
    -- other triggers on the table, the @@rowcount cannot be relied on.
    select @article_rows_updated = count(*) from inserted 
    
    if @article_rows_updated=0
        return
    declare @contents_rows_updated int, @updateerror int, @rowguid uniqueidentifier
    , @bm varbinary(500), @missingbm varbinary(500), @lineage varbinary(311), @cv varbinary(1), @partchangebm varbinary(500), @joinchangebm varbinary(500), @logicalrelationchangebm varbinary(500)
    , @tablenick int, @partchange int, @joinchange int, @logicalrelationchange int, @oldmaxversion int
    , @partgen bigint, @newgen bigint, @child_newgen bigint, @child_oldmaxversion int, @child_metadatarows_updated int
    , @logical_record_parent_oldmaxversion int, @logical_record_lineage varbinary(311), @logical_record_parent_regular_lineage varbinary(311), @logical_record_parent_gencur bigint, @logical_record_parent_rowguid uniqueidentifier
    , @replnick binary(6), @num_parent_rows int, @parent_row_inserted bit 
    declare @dt datetime
    declare @nickbin varbinary(8)
    declare @error int
    declare @null_lineage_updated bit 
    set nocount on

    set @tablenick = 441000     
    
    select @replnick = 0x517ce0d26d07 
    select @nickbin = @replnick + 0xFF
    
    select @null_lineage_updated = 0

    select @oldmaxversion = maxversion_at_cleanup from dbo.sysmergearticles where nickname = @tablenick
    select @dt = getdate()
    
    -- Use intrinsic funtion to set bits for updated columns
    set @bm = columns_updated() 
    select @newgen = NULL
    select top 1 @newgen = generation from MSmerge_genvw_9D6354C0F20943F092E3BF1330B06748 with (rowlock, updlock, readpast) 
        where art_nick = 441000      and 
            genstatus = 0  and
            changecount <= (1000 - isnull(@article_rows_updated,0))
    if @newgen is NULL
    begin
        insert into MSmerge_genvw_9D6354C0F20943F092E3BF1330B06748 with (rowlock)
        (guidsrc, genstatus, art_nick, nicknames, coldate, changecount)
             values   (newid(), 0, @tablenick, @nickbin, @dt, @article_rows_updated)
        select @error = @@error, @newgen = @@identity    
        if @error<>0 or @newgen is NULL
            goto FAILURE
    end     
    else
    begin
        -- now update the changecount of the generation we go to reflect the number of rows we put in this generation
        update MSmerge_genvw_9D6354C0F20943F092E3BF1330B06748 with (rowlock)
            set changecount = changecount + @article_rows_updated
            where generation = @newgen 
        if @@error<>0 goto FAILURE
    end 

    /* save a copy of @bm */
    declare @origin_bm varbinary(500)
    set  @origin_bm =  @bm

    /* only do the map down when needed */
    set @missingbm = 0x00     
	set @partchangebm = 0x00  
	set @joinchangebm = 0x00  
	set @logicalrelationchangebm = 0x00 
    if update([rowguid])
    begin
        if @@trancount > 0
            rollback tran
                
        RAISERROR (20062, 16, -1)
    end  
	/* See if the partition might have changed */ 
		set @partchange = 0     
	/* See if a column used in a join filter changed */ 
		set @joinchange = 0 
	/* See if a column used in a logical record relationship changed */ 
		set @logicalrelationchange = 0  
    execute sp_mapdown_bitmap 0x0000F91704, @bm output 
       set @lineage = { fn UPDATELINEAGE(0x0, @replnick, @oldmaxversion+1) }
            set @cv = NULL
     
    if @joinchange = 1 or @partchange = 1
        set @partgen = @newgen
 
    else    
        set @partgen = NULL 
        update MSmerge_ctsv_9D6354C0F20943F092E3BF1330B06748 with (rowlock)
        set lineage = { fn UPDATELINEAGE(lineage, @replnick, @oldmaxversion+1) }, 
            generation = @newgen, 
            partchangegen = case when (@partchange = 1 or @joinchange = 1) then @newgen else partchangegen end, 
             colv1 = NULL  
        FROM inserted as I JOIN MSmerge_ctsv_9D6354C0F20943F092E3BF1330B06748 as V with (rowlock)
        ON (I.rowguidcol=V.rowguid)
        and V.tablenick = @tablenick
        option (force order, loop join)

        select @updateerror = @@error, @contents_rows_updated = @@rowcount 
          
        if @article_rows_updated <> @contents_rows_updated
        begin  
            insert into MSmerge_ctsv_9D6354C0F20943F092E3BF1330B06748 with (rowlock) (tablenick, rowguid, lineage, colv1, generation, partchangegen) 
            select @tablenick, rowguidcol, @lineage, @cv, @newgen, @partgen
            from inserted i 
            where not exists (select rowguid from MSmerge_ctsv_9D6354C0F20943F092E3BF1330B06748 with (readcommitted, rowlock, readpast) where tablenick = @tablenick and rowguid = i.rowguidcol)     
            if @@error <> 0
                GOTO FAILURE
        end     

    return
FAILURE:
    if @@trancount > 0
        rollback tran
    raiserror (20041, 16, -1)
    return
GO

CREATE TRIGGER [dbo].[MSmerge_ins_9D6354C0F20943F092E3BF1330B06748]
ON [dbo].[MAS_Cards_Test]
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
    if is_member('db_owner') = 1
    begin
        -- select the range values from the MSmerge_identity_range table
        -- this can be hardcoded if performance is a problem
        declare @range_begin numeric(38,0)
        declare @range_end numeric(38,0)
        declare @next_range_begin numeric(38,0)
        declare @next_range_end numeric(38,0)

        select @range_begin = range_begin,
               @range_end = range_end,
               @next_range_begin = next_range_begin,
               @next_range_end = next_range_end
            from dbo.MSmerge_identity_range where artid='9D6354C0-F209-43F0-92E3-BF1330B06748' and subid='E0D26D07-517C-457E-827D-6191FB7361F3' and is_pub_range=0

        if @range_begin is not null and @range_end is not NULL and @next_range_begin is not null and @next_range_end is not NULL
        begin
            if IDENT_CURRENT('[dbo].[MAS_Cards_Test]') = @range_end
            begin
                DBCC CHECKIDENT ('[dbo].[MAS_Cards_Test]', RESEED, @next_range_begin) with no_infomsgs
            end
            else if IDENT_CURRENT('[dbo].[MAS_Cards_Test]') >= @next_range_end
            begin
                exec sys.sp_MSrefresh_publisher_idrange '[dbo].[MAS_Cards_Test]', 'E0D26D07-517C-457E-827D-6191FB7361F3', '9D6354C0-F209-43F0-92E3-BF1330B06748', 2, 1
                if @@error<>0 or @retcode<>0
                    goto FAILURE
            end
        end
    end 
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
    set @tablenick = 441000     
    set @lineage = 0x0
    set @retcode = 0
    select @oldmaxversion= maxversion_at_cleanup from dbo.sysmergearticles where nickname = @tablenick
    select @dt = getdate()

    select @replnick = 0x517ce0d26d07 
    set @nickbin= @replnick + 0xFF

    select @newgen = NULL
        select top 1 @newgen = generation from [dbo].[MSmerge_genvw_9D6354C0F20943F092E3BF1330B06748] with (rowlock, updlock, readpast) 
        where art_nick = 441000      and genstatus = 0
            and  changecount <= (1000 - isnull(@article_rows_inserted,0))
    if @newgen is NULL
    begin
        insert into [dbo].[MSmerge_genvw_9D6354C0F20943F092E3BF1330B06748] with (rowlock)
            (guidsrc, genstatus, art_nick, nicknames, coldate, changecount)
             values   (newid(), 0, @tablenick, @nickbin, @dt, @article_rows_inserted)
        select @error = @@error, @newgen = @@identity    
        if @error<>0 or @newgen is NULL
            goto FAILURE
    end
    else
    begin
        -- now update the changecount of the generation we go to reflect the number of rows we put in this generation
        update [dbo].[MSmerge_genvw_9D6354C0F20943F092E3BF1330B06748]  with (rowlock)
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
        select @ts_rows_exist = 1 where exists (select ts.rowguid from inserted i, [dbo].[MSmerge_tsvw_9D6354C0F20943F092E3BF1330B06748] ts with (rowlock) where ts.tablenick = @tablenick and ts.rowguid = i.rowguidcol)     
    if @ts_rows_exist = 1
    begin    
        select @version = max({fn GETMAXVERSION(lineage)}) from [dbo].[MSmerge_tsvw_9D6354C0F20943F092E3BF1330B06748] where 
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
                delete from [dbo].[MSmerge_tsvw_9D6354C0F20943F092E3BF1330B06748] with (rowlock) where tablenick = @tablenick and rowguid in
                    (select rowguidcol from inserted) 
        end
    end 
    select @marker = newid()  
        insert into [dbo].[MSmerge_ctsv_9D6354C0F20943F092E3BF1330B06748] with (rowlock) (tablenick, rowguid, lineage, colv1, generation, partchangegen, marker) 
        select @tablenick, rowguidcol, @lineage, @colv1, @newgen, (-@newgen), @marker
        from inserted i where not exists
        (select rowguid from [dbo].[MSmerge_ctsv_9D6354C0F20943F092E3BF1330B06748] with (readcommitted, rowlock, readpast) where tablenick = @tablenick and rowguid = i.rowguidcol)  
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
-- Triggers structure for table MAS_Cards
-- ----------------------------
CREATE TRIGGER [dbo].[MSmerge_del_9D6354C0F20943F092E3BF1330B06748]
ON [dbo].[MAS_Cards_Test]
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
    select @tablenick = 441000     
    if @article_rows_deleted = 1 select @rowguid = rowguidcol from deleted
    select @oldmaxversion= maxversion_at_cleanup from dbo.sysmergearticles where nickname = @tablenick
    select @dt = getdate()

    select @replnick = 0x517ce0d26d07
    set @nickbin= @replnick + 0xFF

    select @newgen = NULL
        select top 1 @newgen = generation from [dbo].[MSmerge_genvw_9D6354C0F20943F092E3BF1330B06748] with (rowlock, updlock, readpast) 
        where art_nick = 441000       and genstatus = 0    
        
            and  changecount <= (1000 - isnull(@article_rows_deleted,0))
    if @newgen is NULL
    begin
        insert into [dbo].[MSmerge_genvw_9D6354C0F20943F092E3BF1330B06748]  with (rowlock)
            (guidsrc, genstatus, art_nick, nicknames, coldate, changecount)
               values (newid(), 0, @tablenick, @nickbin, @dt, @article_rows_deleted)
        select @error = @@error, @newgen = @@identity    
        if @error<>0 or @newgen is NULL
            goto FAILURE
    end
    else
    begin
        -- now update the changecount of the generation we go to reflect the number of rows we put in this generation
        update [dbo].[MSmerge_genvw_9D6354C0F20943F092E3BF1330B06748]  with (rowlock)
            set changecount = changecount + @article_rows_deleted
            where generation = @newgen
        if @@error<>0 goto FAILURE
    end
  
    set @lineage = { fn UPDATELINEAGE(0x0, @replnick, @oldmaxversion+1) }  
    if @article_rows_deleted = 1
        insert into [dbo].[MSmerge_tsvw_9D6354C0F20943F092E3BF1330B06748] with (rowlock) (rowguid, tablenick, type, lineage, generation)
            select @rowguid, @tablenick, 1, isnull((select { fn UPDATELINEAGE(COALESCE(c.lineage, @lineage), @replnick, @oldmaxversion+1) } from 
            [dbo].[MSmerge_ctsv_9D6354C0F20943F092E3BF1330B06748] c with (rowlock) where c.tablenick = @tablenick and c.rowguid = @rowguid),@lineage), @newgen
    else
        insert into [dbo].[MSmerge_tsvw_9D6354C0F20943F092E3BF1330B06748] with (rowlock) (rowguid, tablenick, type, lineage, generation)
            select d.rowguidcol, @tablenick, 1, { fn UPDATELINEAGE(COALESCE(c.lineage, @lineage), @replnick, @oldmaxversion+1) }, @newgen from 
            deleted d left outer join [dbo].[MSmerge_ctsv_9D6354C0F20943F092E3BF1330B06748] c with (rowlock) on c.tablenick = @tablenick and c.rowguid = d.rowguidcol 
             
    if @@error <> 0
        GOTO FAILURE  
        delete [dbo].[MSmerge_ctsv_9D6354C0F20943F092E3BF1330B06748]  with (rowlock)
        from deleted d, [dbo].[MSmerge_ctsv_9D6354C0F20943F092E3BF1330B06748] cont with (rowlock)
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