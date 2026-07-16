/*------------------------------------------------------------------------------

sp2_repl.sql
THIS SCRIPT UPDATES REPLICATION SYSTEM STORED PROCEDURES FROM SQL 2000 to SQL 2000  SP1

Changes in this file are organized as follows (please maintain):
	Common system objects (replsys.sql)
	Common repl objects (replcom.sql)
	Tran repl objects (repltran.sql) 
	Merge repl objects (rladmin.sql, rlrecon.sql, rlcore.sql)

Notes:
+ Catalog-updates and sp_MS_upd_sysobj_category are enabled for the entire
	file.  Do not disable or re-enable them.  Please do not change set options.
+ grep for "--.
------------------------------------------------------------------------------*/

--------------------------------------------------------------------------------
-- VERIFY Server is started in single-user-mode (catalog-updates enabled), and
--	start marking of system-objects.
--------------------------------------------------------------------------------
use master
go

dump tran master with no_log
go

exec dbo.sp_configure 'allow updates',1
go
reconfigure with override
go

set ANSI_NULLS off

exec sp_MS_upd_sysobj_category 1
go

--------------------------------------------------------------------------------
--.	System objects (replsys.sql)
--------------------------------------------------------------------------------
if exists (select * from sysobjects
    where type = 'P'
            and name = 'sp_replicationdboption')
    drop procedure sp_replicationdboption

if exists (select * from sysobjects
		where type = 'P'
			and name = 'sp_MSmakesystableviews')
	drop procedure sp_MSmakesystableviews

if exists (select * from sysobjects
		where type = 'P'
			and name = 'sp_MSinsertbeforeimageclause')
	drop procedure sp_MSinsertbeforeimageclause

if exists (select * from sysobjects
			where type = 'P' and
			name = 'sp_MSsetartprocs')
	drop procedure sp_MSsetartprocs

if exists (select * from sysobjects
			where type = 'P' and
			name = 'sp_MSmakeconflictinsertproc')
	drop procedure sp_MSmakeconflictinsertproc

if exists (select * from sysobjects
		where type = 'P'
			and name = 'sp_MSsetconflicttable')
	drop procedure sp_MSsetconflicttable

if exists (select * from sysobjects
		where type = 'P'
			and name = 'sp_MShelpalterbeforetable')
	drop procedure sp_MShelpalterbeforetable

if exists (select * from sysobjects
	where type = 'P '
			and name = 'sp_addpullsubscription_agent')
	drop procedure sp_addpullsubscription_agent

if exists (select * from sysobjects
	where type = 'P '
			and name = 'sp_addmergepullsubscription_agent')
	drop procedure sp_addmergepullsubscription_agent

if exists (select * from sysobjects
        where type = 'P '
                and name = 'sp_MSenumallsubscriptions')
	drop proc sp_MSenumallsubscriptions

if exists (select * from sysobjects
        where type = 'P '
                and name = 'sp_MSenumsubscriptions')
	drop proc sp_MSenumsubscriptions
	
if exists (select * from sysobjects
        where type = 'P '
                and name = 'sp_vupgrade_subpass')
	drop proc sp_vupgrade_subpass

if exists (select * from sysobjects
        where type = 'P '
                and name = 'sp_vupgrade_replmsdb')
	drop proc sp_vupgrade_replmsdb

if exists (select * from sysobjects
	where type = 'P '
			and name = 'sp_vupgrade_publisher')
	drop procedure sp_vupgrade_publisher

if exists (select * from sysobjects 
		where name = 'sp_vupgrade_subscription_databases' 
				and type = 'P')
	  drop procedure sp_vupgrade_subscription_databases

if exists (select * from sysobjects 
		where name = 'sp_vupgrade_replication' 
				and type = 'P')
	  drop procedure sp_vupgrade_replication
go
if exists (select * from sysobjects
	where type = 'P '
			and name = 'sp_MSdrop_rlcore')
begin
	drop procedure sp_MSdrop_rlcore
end

/*
** Create stored procedures to drop the stored procedures
** created by this script
*/

raiserror('Creating procedure sp_MSdrop_rlcore', 0,1)
GO
create procedure sp_MSdrop_rlcore
as

	if exists (select * from sysobjects
			where type = 'P'
				and name = 'sp_MSguidtostr')
		drop procedure sp_MSguidtostr

	if exists (select * from sysobjects
			where type = 'P'
				and name = 'sp_MShelpdestowner')
		drop procedure sp_MShelpdestowner

	if exists (select * from sysobjects
			where type = 'P'
				and name = 'sp_MSchangeobjectowner')
		drop procedure sp_MSchangeobjectowner

	if exists (select * from sysobjects
			where type = 'P'
				and name = 'sp_MSgetcolumnlist')
		drop procedure sp_MSgetcolumnlist

	if exists (select * from sysobjects
			where type = 'P'
				and name = 'sp_MSgetconflicttablename')
		drop procedure sp_MSgetconflicttablename

	if exists (select * from sysobjects
			where type = 'P'
				and name = 'sp_MSuniquetempname')
		drop procedure sp_MSuniquetempname

	if exists (select * from sysobjects
			where type = 'P'
				and name = 'sp_MSuniqueobjectname')
		drop procedure sp_MSuniqueobjectname
 
	if exists (select * from sysobjects
			where type = 'P'
				and name = 'sp_MSfillupmissingcols')
		drop procedure sp_MSfillupmissingcols

	if exists (select * from sysobjects
			where type = 'P'
				and name = 'sp_MSaddguidcolumn')
		drop procedure sp_MSaddguidcolumn

	if exists (select * from sysobjects
			where type = 'P'
				and name = 'sp_MSprepare_mergearticle')
		drop procedure sp_MSprepare_mergearticle

	if exists (select * from sysobjects
			where type = 'P'
				and name = 'sp_MSuniquecolname')
		drop procedure sp_MSuniquecolname

	if exists (select * from sysobjects
			where type = 'P'
				and name = 'sp_MSaddguidindex')
		drop procedure sp_MSaddguidindex

	if exists (select * from sysobjects
			where type = 'P'
				and name = 'sp_MSrefcnt')
		drop procedure sp_MSrefcnt
	
	if exists (select * from sysobjects
			where type = 'P'
				and name = 'sp_MSgentablenickname')
		drop procedure sp_MSgentablenickname
	
	if exists (select * from sysobjects
			where type = 'P'
				and name = 'sp_MStablenickname')
		drop procedure sp_MStablenickname
	
	if exists (select * from sysobjects
		where type = 'P'
			and name = 'sp_MStablenamefromnick')
		drop procedure sp_MStablenamefromnick

	if exists (select * from sysobjects
			where type = 'P'
				and name = 'sp_MSgetmakegenerationapplock')
		drop procedure sp_MSgetmakegenerationapplock

	if exists (select * from sysobjects
		where type = 'P'
			and name = 'sp_MSreleasemakegenerationapplock')
		drop procedure sp_MSreleasemakegenerationapplock

	if exists (select * from sysobjects
		where type = 'P'
			and name = 'sp_MSmakegeneration')
		drop procedure sp_MSmakegeneration

	if exists (select * from sysobjects
			where type = 'P'
				and name = 'sp_MSfixlineageversions')
		drop procedure sp_MSfixlineageversions
	
	if exists (select * from sysobjects
			where type = 'P'
				and name = 'sp_MSaddupdatetrigger')
		drop procedure sp_MSaddupdatetrigger
	
	if exists (select * from sysobjects
			where type = 'P'
				and name = 'sp_MSaddmergetriggers')
		drop procedure sp_MSaddmergetriggers
	
	if exists (select * from sysobjects
				where type = 'P' and
				name = 'sp_MSmaptype')
		drop procedure sp_MSmaptype 

	if exists (select * from sysobjects
				where type = 'P' and
				name = 'sp_MSquerysubtype')
		drop procedure sp_MSquerysubtype 

	if exists( select * from sysobjects where type = 'P ' and name = 'sp_showrowreplicainfo')
	begin
	    drop procedure sp_showrowreplicainfo
	end

	if exists( select * from sysobjects where type = 'P ' and name = 'sp_MSsethighestversion')
	begin
		drop procedure sp_MSsethighestversion
	end

	if exists( select * from sysobjects where type = 'P ' and name = 'sp_mergemetadataretentioncleanup')
	begin
		drop procedure sp_mergemetadataretentioncleanup
	end

	if exists( select * from sysobjects where type = 'P ' and name = 'sp_MSpurgecontentsorphans')
	begin
		drop procedure sp_MSpurgecontentsorphans
	end
	
	if exists( select * from sysobjects where type = 'P ' and name = 'sp_MScleanup_zeroartnick_genhistory')
	begin
		drop procedure sp_MScleanup_zeroartnick_genhistory
	end
	
	if exists( select * from sysobjects where type = 'P ' and name = 'sp_MSdelete_specifiedcontents')
	begin
		drop procedure sp_MSdelete_specifiedcontents
	end

go
exec dbo.sp_MS_marksystemobject sp_MSdrop_rlcore
go
/* Create  sp_replicationdboption */
raiserror('Creating procedure sp_replicationdboption', 0,1)
GO

CREATE PROCEDURE sp_replicationdboption (
      @dbname    sysname,
      @optname   sysname,
      @value     sysname,
      @ignore_distributor bit = 0,
	  @from_scripting bit = 0
    ) AS

    SET NOCOUNT ON

    /*
    ** Declarations.
    */
    
    declare @alert_name     sysname
    declare @alert_id       int
    declare @command        nvarchar(255)
    declare @description    nvarchar(500)
    declare @category_name  sysname
    declare @agentname      sysname
    DECLARE @retcode        int
    DECLARE @optbit         int
    DECLARE @optbit_value   int /* Desired value with the optbit mask */
    DECLARE @proc           nvarchar(255)
		, @category int

    /*
    ** Initialization
    */

    /*
    ** Parameter check
    ** @dbname
    */
    SELECT @category = category FROM master.dbo.sysdatabases WHERE
        name = @dbname collate database_default
	if @category is null
    BEGIN
        RAISERROR(15010, 16, -1, @dbname)
        RETURN(1)
    END

    /*
    ** Parameter check
    ** @type
    */
    IF @optname is null or LOWER(@optname collate SQL_Latin1_General_CP1_CS_AS) NOT IN ('publish',
        'merge publish',
		'subscribe', -- Used by sp_dboption for backward compatibility only.
		'sync with backup',
		'max cmds in tran'
		)
    BEGIN
        RAISERROR(14138,16,-1,@optname)
        RETURN(1)
    END

    /*
    ** Parameter check
    ** @value
    */
    IF LOWER(@value collate SQL_Latin1_General_CP1_CS_AS) NOT IN ('true','false')
    BEGIN
      RAISERROR(14137,16,-1)
      RETURN(1)
    END

    /*
    ** Security Check
    */
	-- This proc is not granted to public. Only other system proc or sysadmin can use this
	-- sp_dboption will call this and it has its own security check,

    /*
    **  If we're in a transaction, disallow this since it might make recovery
    **  impossible.
    **
    */
    IF @@trancount > 0 
    BEGIN
        RAISERROR(15002,16,-1,'sp_replicationdboption')
        RETURN(1)
    END
    
    IF LOWER(@optname collate SQL_Latin1_General_CP1_CS_AS) = 'publish'
        BEGIN
            SELECT @optbit = 1
            SELECT @proc = QUOTENAME(@dbname) + '.dbo.sp_MSpublishdb'
        END
    ELSE IF LOWER(@optname collate SQL_Latin1_General_CP1_CS_AS) = 'merge publish'
        BEGIN
            SELECT @optbit = 4
            SELECT @proc = QUOTENAME(@dbname) + '.dbo.sp_MSmergepublishdb'
        END
    ELSE IF LOWER(@optname collate SQL_Latin1_General_CP1_CS_AS) = 'subscribe'
        BEGIN
            SELECT @optbit = 2
        END
    ELSE IF LOWER(@optname collate SQL_Latin1_General_CP1_CS_AS) = 'sync with backup'
        BEGIN
            SELECT @optbit = 32
        END
    ELSE IF LOWER(@optname collate SQL_Latin1_General_CP1_CS_AS) = 'max cmds in tran'
        BEGIN
            SELECT @optbit = 64
        END

    IF LOWER(@value collate SQL_Latin1_General_CP1_CS_AS) = 'true'
        SELECT @optbit_value = @optbit
    ELSE
        SELECT @optbit_value = 0

          
    /*
    ** Check if the option is set as required already
    */
	if (@category & @optbit) = @optbit_value 
	BEGIN
		if @optbit_value = 64 -- setting 'max cmds in tran' to the same, do nothing
			RETURN (0)
        if LOWER(@value collate SQL_Latin1_General_CP1_CS_AS) = 'true'
            RAISERROR (14035, 10, -1, @optname, @dbname)        
        else
            RAISERROR (14037, 10, -1, @optname, @dbname)
        RETURN (1)
    END

	-- If turning on 'sync with backup', make sure 'publish' or 'dist' is turned on already.
	if  @optbit_value = 32 and (@category & 1 = 0 and @category & 16 = 0)
	begin
		raiserror(20019, 16, -1, 'sync with backup')
		return (1)
	end
	if  @optbit_value = 64 and (@category & 16 = 0)
	begin
		raiserror(20019, 16, -1, 'max cmds in tran')
		return (1)
	end

	-- We do not allow turning on sync with backup mode at publishing db if the db is
	-- in simple recovery mode
	if  @optbit_value = 32 and @category & 1 <> 0 and 
		databasepropertyex(@dbname, 'recovery') = 'SIMPLE'
	begin
		raiserror(20622, 16, -1, 'sync with backup')
		return (1)
	end
	
	-- If turning off 'publish', turn off 'sync with backup' as well if the database
	-- is not a distribution database.
	if @optbit = 1 and @optbit_value = 0 and @category & 32 <> 0 and @category & 16 = 0
	begin
		EXEC @retcode =  dbo.sp_replicationdboption   
			@dbname = @dbname,
			@optname = 'sync with backup',
			@value = 'false',
			@ignore_distributor = @ignore_distributor,
			@from_scripting = @from_scripting
		IF @@ERROR <> 0 or @retcode <> 0
		BEGIN
			GOTO UNDO
		END
	end

	-- if turning on 'sync with backup' a distribution database, initialize the backup lsns 
	-- to nulls, this should be done before the category bit is set.
	declare @backup_proc nvarchar(1000)
	if @optbit_value = 32 and @category & 16 <> 0
	begin
        SELECT @backup_proc = QUOTENAME(@dbname) + 
			'.dbo.sp_MSrepl_init_backup_lsns'
		exec @retcode = @backup_proc
        if @@error <> 0 or @retcode <> 0
            goto UNDO
	end

    /*
    ** Prepare the required option
    */
	if @proc is not null
	begin
		EXEC @retcode = @proc @value = @value,
			@ignore_distributor = @ignore_distributor
		IF @@ERROR <> 0 or @retcode <> 0
		BEGIN
			GOTO UNDO
		END
	end


    /*
    ** Preparation succeeded. 
    ** Toggle the category bit in master..sysdatabases
    */
    UPDATE master..sysdatabases SET category = category ^ @optbit
    WHERE name = @dbname
    IF @@ERROR <> 0 
    BEGIN
        GOTO UNDO
    END


    declare @num_mergedb int
    select @num_mergedb = null
    if lower(@optname collate SQL_Latin1_General_CP1_CS_AS) = 'merge publish'
    begin
        if lower(@value collate SQL_Latin1_General_CP1_CS_AS) = 'true'
        begin            
            -- Set the 'startup' option for sp_MScleanupmergepublisher if the
            -- database is enabled for merge replication.  
            exec ('use master 
                   exec dbo.sp_procoption ''sp_MScleanupmergepublisher'', ''startup'', ''true''')
        end
        else
        begin
            -- Reset the 'startup' option for sp_MScleanupmergepublisher if
            -- this is the last database that has its 'merge publish' option 
            -- disabled
            select @num_mergedb = count(*) from master..sysdatabases 
             where (category & 4) <> 0
            if @num_mergedb = 0
            begin
                exec ('use master 
                       exec dbo.sp_procoption ''sp_MScleanupmergepublisher'', ''startup'', ''false''')
            end
        end
    end
    

	-- Get expired subscription cleanup agent name
    set @agentname = formatmessage(20569)  

    IF ((LOWER(@optname collate SQL_Latin1_General_CP1_CS_AS) = 'merge publish') or (LOWER(@optname) = 'publish')) and (LOWER(@value) = 'true')
    BEGIN
        IF NOT EXISTS (SELECT * FROM msdb..sysjobs_view WHERE name = @agentname collate database_default and
						UPPER(originating_server) = UPPER(CONVERT(sysname, SERVERPROPERTY('ServerName'))))
            BEGIN
                SELECT @command =  'EXEC dbo.sp_expired_subscription_cleanup'
            
                set @description = formatmessage(20542)
    
                select @category_name = name FROM msdb.dbo.syscategories where category_id = 17   
                
                EXECUTE @retcode = msdb.dbo.sp_MSadd_repl_job @agentname,
                @subsystem = 'TSQL',
                @server = @@SERVERNAME,
                @databasename = @dbname,
                @description = @description,
                @freqtype = 4,        -- daily
                @activestarttimeofday=010000,   -- from 01:00:00 am
                @command = @command,
                @enabled = 1,
                @retryattempts = 0,
                @loghistcompletionlevel = 0,
                @category_name = @category_name
            
                IF @@ERROR <> 0 or @retcode <> 0
                    BEGIN
                         return (1)
                    END
            END

		-- Expired subscription cleanup alert            
        select @category_name = name FROM msdb.dbo.syscategories where category_id = 20
        set @alert_name = formatmessage(20538)  
        set @alert_id = 14157 -- corresponding to formatmessage(20538)
        if not exists (select * from msdb.dbo.sysalerts where message_id = @alert_id)
        begin
            exec @retcode = msdb.dbo.sp_add_alert @enabled = 0, @name = @alert_name, @category_name = @category_name, @message_id = 14157
            if @@error <> 0 or @retcode <> 0
                goto UNDO
        end
    END

    IF ((LOWER(@optname collate SQL_Latin1_General_CP1_CS_AS) = 'merge publish') or (LOWER(@optname collate SQL_Latin1_General_CP1_CS_AS) = 'publish')) and (LOWER(@value collate SQL_Latin1_General_CP1_CS_AS) = 'false')
    BEGIN
            IF (EXISTS (SELECT * FROM msdb..sysjobs_view WHERE name = @agentname collate database_default and 
							UPPER(originating_server) = UPPER(CONVERT(sysname, SERVERPROPERTY('ServerName'))))) 
                and (NOT exists (select name from master..sysdatabases where category & 4 =4 ))
                and (NOT exists (select name from master..sysdatabases where category & 1 =1))
        BEGIN
            EXEC @retcode = msdb.dbo.sp_delete_job  @job_name = @agentname
            IF @@ERROR <> 0 or @retcode <> 0
                return (1)            
        END
        
        set @alert_id = 14157 -- cleanup  alert
        set @alert_name = formatmessage(20569)
        if exists (select * from msdb.dbo.sysalerts where message_id=@alert_id)
            and (NOT exists (select name from master..sysdatabases where category & 4 =4 ))
                and (NOT exists (select name from master..sysdatabases where category & 1 =1))
        begin
            select @alert_name=name from msdb.dbo.sysalerts where message_id=@alert_id
            exec @retcode = msdb.dbo.sp_delete_alert @alert_name
            if @@error <> 0 or @retcode <> 0
                return (1)            
        end
    END
    
    /*
    **  ??? 
    ** CHECKPOINT the database that was changed. Make the change
    ** effective immediatly
    */
    CHECKPOINT
    IF @@ERROR <> 0 
    BEGIN
        RETURN(1)
    END

    RETURN(0)

UNDO:
    -- Create system table is not allowed in a multi-statement transactions.
    -- Drop the tables here
    IF LOWER(@value collate SQL_Latin1_General_CP1_CS_AS) = 'true'
        EXEC dbo.sp_replicationdboption 
          @dbname    = @dbname,
          @optname   = @optname,
          @value     = 'false',
          @ignore_distributor = @ignore_distributor

    return(1)   
GO

raiserror('Creating procedure sp_MSmakeconflictinsertproc', 0,1)
GO

create procedure sp_MSmakeconflictinsertproc 
	(@tablename sysname, @ownername sysname, @procname sysname, @basetableid int, @pubid uniqueidentifier=NULL)
as
declare @arglist	nvarchar(4000)
declare @header		nvarchar(4000)
declare @qualname   nvarchar(270)
declare @argname	nvarchar(270)
declare @noset		bit
declare @wherepc	nvarchar(255)
declare @id 		int
declare @sync_objid	int
declare @colname nvarchar(140)
declare @typename sysname
declare @colid smallint
declare @status tinyint
declare @len smallint
declare @prec smallint
declare @scale int
declare @retcode smallint
declare @sys_loop bit
declare @old_colname nvarchar(140)
declare @create_time_col nvarchar(8)
declare @p_number_for_conflict_type nvarchar(270)

set nocount on

select @sys_loop = 0
set @create_time_col = NULL
set @id = NULL

/*
** To check if specified object exists in current database
*/
select @id = id, @ownername=user_name(uid) from sysobjects where name = @tablename
	if @id is NULL return (1)

set @qualname = QUOTENAME(@ownername) + '.' + QUOTENAME(@tablename)

-- create temp table to select the command text out of
create table #tempcmd (phase int NOT NULL, step int identity NOT NULL, 
cmdtext nvarchar(4000) collate database_default null)

select @header = 'Create procedure dbo.' + @procname + ' ( ' 
insert into #tempcmd (phase, cmdtext) values (0,  @header)

select @sync_objid = sync_objid from sysmergearticles where objid = @basetableid and (pubid = @pubid or @pubid is NULL)

select @colid = min(colid) from syscolumns where id = @id and iscomputed <>1 and 
	type_name(xtype) <> 'timestamp' and ((name not in (select name from syscolumns where id=@basetableid) 
		and @sys_loop =1) OR
	 (name in (select name from syscolumns where id=@basetableid) and @sys_loop =0))
select @colname = c.name, @status = c.status, @typename = t.name, @len = c.length,
	@prec = c.prec, @scale = c.scale
	from syscolumns c, systypes t
	where c.id = @id and c.colid = @colid and c.xusertype = t.xusertype 

/*
** Get the column list from the conflict_table schema and filter it with 
table view for vertical partitioning
*/
Reverse_Order:
while (@colname is not null) 
begin
	set @noset = 0
	if exists (select * from syscolumns where name=@colname and id=@basetableid)
		and not exists (select * from syscolumns where name=@colname and id=@sync_objid)
		goto NEXT_COL 		
	if @typename='nvarchar' or @typename='nchar' -- a unit of nchar takes 2 bytes
		select @len = @len/2
	exec @retcode = dbo.sp_MSmaptype @typename out, @len, @prec, @scale
	if @@ERROR<>0 or @retcode<>0 return (1)
	select @argname = '@p' + rtrim(convert(nchar, @colid))
	
	if LOWER(@colname collate SQL_Latin1_General_CP1_CS_AS)='conflict_type'
		select @p_number_for_conflict_type=@argname
		
	-- based on colid, add text to appropriate pieces
	if (COLUMNPROPERTY( @basetableid, @colname, 'IsRowGuidCol') = 1)  
		begin
			select @noset =1
			set @wherepc = ' where rowguidcol = ' + @argname
		end
	else if (@colname = 'origin_datasource')
		begin
			select @wherepc =@wherepc +  ' and origin_datasource = ' + @argname
			set @noset =1
		end
	set @old_colname = @colname
	set @colname = QUOTENAME(@colname)
	if @arglist is null
		begin
		set @arglist = @argname + ' ' + @typename
		--give default value of NULL to new merge columns for backward compatibility concern
		insert into #tempcmd (phase, cmdtext) values (3, @colname)
		select @header = ') values ('
		insert into #tempcmd (phase, cmdtext) values (4, @header)

		insert into #tempcmd (phase, cmdtext) values (4, @argname)
		if @noset=0
			insert into #tempcmd (phase, cmdtext) values (1, @colname + ' = ' + @argname)
		end
	else 
		begin
		if len(@arglist)>3700
			begin
				insert into #tempcmd (phase, cmdtext) values (0,  @arglist)			
				select @arglist = ' '
			end
		set @arglist = @arglist + ', ' + @argname + ' ' + @typename
		if @sys_loop = 1 and @old_colname not in ('origin_datasource','conflict_type','reason_code','reason_text', 'pubid') 
			begin
				select @arglist=@arglist + ' = NULL'		
				if @old_colname='MSrepl_create_time'
					select @create_time_col=@argname
			end

		insert into #tempcmd (phase, cmdtext) values (3, ',' + @colname)

		insert into #tempcmd (phase, cmdtext) values (4, ',' + @argname)

		if @noset =0
			begin
				if exists (select * from #tempcmd where phase=1)
					insert into #tempcmd (phase, cmdtext) values (1, ',' + @colname + ' = ' + @argname)
				else
					insert into #tempcmd (phase, cmdtext) values (1, @colname + ' = ' + @argname)
			end
		end
NEXT_COL:
	select @colid = min(colid) from syscolumns where id = @id and colid>@colid and iscomputed <>1 and 
		type_name(xtype) <> 'timestamp' and 
		((name not in (select name from syscolumns where id=@basetableid) and @sys_loop =1) OR
	 		(name in (select name from syscolumns where id=@basetableid) and @sys_loop =0))
	set @colname = NULL
	select @colname = c.name, @status = c.status, @typename = t.name, @len = c.length,
		@prec = c.prec, @scale = c.scale
		from syscolumns c, systypes t
		where c.id = @id and c.colid = @colid and c.xusertype = t.xusertype
end

if @sys_loop = 0
begin
	select @sys_loop = 1
	select @colid = min(colid) from syscolumns where id = @id  and iscomputed <>1 
		and type_name(xtype) <> 'timestamp' and 
		((name not in (select name from syscolumns where id=@basetableid) and @sys_loop =1) OR
	 	(name in (select name from syscolumns where id=@basetableid) and @sys_loop =0))
	select @colname = c.name, @status = c.status, @typename = t.name, @len = c.length,
		@prec = c.prec, @scale = c.scale
		from syscolumns c, systypes t
			where c.id = @id and c.colid = @colid and c.xusertype = t.xusertype 
	goto Reverse_Order
end

-- now create the procedure
select @procname = QUOTENAME(@procname)

insert into #tempcmd (phase, cmdtext) values (0,  @arglist)			

select @header =  ') as'
insert into #tempcmd (phase, cmdtext) values (0,  @header)

select @header = ' '
-- for ease of expansion here in case we add new merge columns in conflict tables.
if @create_time_col is not NULL
	select @header = @header + ' 
		select ' + @create_time_col + ' = getdate() '

select @header = @header + ' if exists (select * from ' + @qualname + ' ' + @wherepc + ')
	begin
	update ' + @qualname + ' set ' 
insert into #tempcmd (phase, cmdtext) values (0,  @header)

--see comment in sp_MSinsertdeleteconflict for this <5 or >4 checking.

select @header = @wherepc + ' and (conflict_type<5 or ' + @p_number_for_conflict_type + ' >4) 
	end
	else
	insert into ' + @qualname + ' ('
insert into #tempcmd (phase, cmdtext) values (2,  @header)

insert into #tempcmd (phase, cmdtext) values (4, ')')

-- Now we select out the command text pieces in proper order so that our caller,
-- xp_execresultset will execute the command that creates the stored procedure.

select cmdtext from #tempcmd order by phase, step
drop table #tempcmd
go
exec dbo.sp_MS_marksystemobject sp_MSmakeconflictinsertproc 
go
grant exec on dbo.sp_MSmakeconflictinsertproc to public
go


raiserror('Creating procedure sp_MSsetartprocs', 0,1)
GO

SET ANSI_NULLS ON 
SET QUOTED_IDENTIFIER ON
GO
-- Call by snapshot
create procedure sp_MSsetartprocs
	(@publication		sysname,
	@article			sysname,
	@force_flag 		int = 0)
as
	declare @ownername sysname
	declare @objectname sysname
	declare @guidstr nvarchar(40)
	declare @pubidstr nvarchar(40)
	declare @conflict_proc sysname
	declare @conflict_table sysname
	declare @snapshot_ready int
	declare @ins_procname sysname
	declare @sel_procname sysname
	declare @upd_procname sysname
	declare @view_selprocname nvarchar(290)
	declare @viewname sysname
	declare @artid uniqueidentifier
	declare @pubid uniqueidentifier
	declare @objid int
    declare @rgcol nvarchar(140)
	declare @sync_objid int
	declare @retcode smallint
	declare @dbname sysname
	declare @command  nvarchar(1000)
	
	set nocount on
	/*
	** Check to see if current publication has permission
	*/
	exec @retcode=sp_MSreplcheck_publish
	if @retcode<>0 or @@ERROR<>0 return (1)
	
	-- figure out pubid and artid
	if @force_flag = 1
		begin
		-- don't qualify that must be publisher when we are forcing remake at subscribers
		select @pubid = pubid, @snapshot_ready=snapshot_ready from sysmergepublications where name = @publication and 
			pubid in (select pubid from sysmergearticles where name=@article)
		end
	else
		select @pubid = pubid, @snapshot_ready=snapshot_ready 
			from sysmergepublications where name = @publication and UPPER(publisher)=UPPER(@@SERVERNAME) and publisher_db=db_name()
    if @pubid IS NULL
        BEGIN
			RAISERROR (20026, 16, -1, @publication)
    	    RETURN (1)
        END

	select @conflict_table=NULL
	select @artid = artid, @objid = objid, @sync_objid = sync_objid, @conflict_table=conflict_table FROM sysmergearticles WHERE name = @article	AND pubid = @pubid
    if @artid IS NULL
        BEGIN
			RAISERROR (20027, 16, -1, @article)
            RETURN (1)
        END

	/* Drop the article procs if they preexist */
	exec @retcode = dbo.sp_MSdroparticleprocs @pubid, @artid
	if @@ERROR<>0 OR @retcode<>0 
		begin
			return (1)
		end
	
	-- get owner name, and table name
	select @objectname = name, @ownername = user_name(uid)	from sysobjects
		where id = @objid 

	-- make the insert and update proc names
	exec @retcode = dbo.sp_MSguidtostr @artid, @guidstr out
	if @@ERROR <>0 OR @retcode <>0 return (1)

	exec @retcode = dbo.sp_MSguidtostr @pubid, @pubidstr out
	if @@ERROR <>0 OR @retcode <>0 return (1)

	select @ins_procname = 'sp_ins_' + substring(@guidstr, 1, 16) + substring(@pubidstr, 1, 16)
	exec dbo.sp_MSuniqueobjectname @ins_procname, @ins_procname output
	if @@ERROR <>0 OR @retcode <>0 return (1)
	
	select @upd_procname = 'sp_upd_' + substring(@guidstr, 1, 16) + substring(@pubidstr, 1, 16)
	exec dbo.sp_MSuniqueobjectname @upd_procname, @upd_procname output
	if @@ERROR <>0 OR @retcode <>0 return (1)

	select @sel_procname = 'sp_sel_' + substring(@guidstr, 1, 16) + substring(@pubidstr, 1, 16)
	exec dbo.sp_MSuniqueobjectname @sel_procname, @sel_procname output
	if @@ERROR <>0 OR @retcode <>0 return (1)

	set @view_selprocname = 'sel_' + substring(@guidstr, 1, 16) + substring(@pubidstr, 1, 16)
    exec @retcode = dbo.sp_MSuniqueobjectname @view_selprocname , @view_selprocname output
    if @retcode <> 0 or @@ERROR <> 0 return (1) 

	-- create the procs
	set @dbname = db_name()

	set @command = 'sp_MSmakeinsertproc ' + QUOTENAME(@objectname) + ' , ' + QUOTENAME(@ownername) + ' , ' + @ins_procname  + ', [' + convert(nchar(36), @pubid) + ']'

	exec @retcode = master..xp_execresultset @command, @dbname

	if @@ERROR<>0 OR @retcode<>0 
		begin
			return (1)
		end


	exec @retcode = dbo.sp_MS_marksystemobject  @ins_procname 
	if @@ERROR<>0 or @retcode<>0  return (1)
	
	exec ('grant exec on ' + @ins_procname + ' to public')
	set @command = 'sp_MSmakeupdateproc ' + QUOTENAME(@objectname) + ' , ' + QUOTENAME(@ownername) + ' , ' + @upd_procname + ', [' + convert(nchar(36), @pubid) + ']'
	exec @retcode = master..xp_execresultset @command, @dbname
	if @@ERROR<>0 OR @retcode<>0 
		begin
			return (1)
		end
	exec @retcode = dbo.sp_MS_marksystemobject  @upd_procname 
	if @@ERROR<>0 or @retcode<>0 return (1)
	exec ('grant exec on ' + @upd_procname + ' to public')
	if @@ERROR<>0 return (1)
	set @command= 'SET ANSI_NULLS ON SET QUOTED_IDENTIFIER ON'
	exec (@command)
	if @@ERROR<>0 return (1)
	set @command = 'sp_MSmakeselectproc ' + QUOTENAME(@objectname) + ' , ' + QUOTENAME(@ownername)+ ' , ' + @sel_procname + ', [' + convert(nchar(36), @pubid) + ']'
	exec @retcode = master..xp_execresultset @command, @dbname
	if @@ERROR<>0 or @retcode<>0
		begin
			return (1)
		end
	exec @retcode = dbo.sp_MS_marksystemobject  @sel_procname 
	if @@ERROR<>0 or @retcode<>0 return (1)
	exec ('grant exec on ' + @sel_procname + ' to public')
	if @@ERROR<>0 return (1)

	if @sync_objid <> 0 
		begin

   	 	select @ownername = user_name(uid), @viewname = name from sysobjects 
                where id = @sync_objid 
    	select @rgcol = QUOTENAME(name) from syscolumns where id = @objid and
                ColumnProperty(id, name, 'isrowguidcol') = 1
		
    	exec @retcode=dbo.sp_MSmakeviewproc @viewname, @ownername, @view_selprocname, @rgcol, @objid
		if @@ERROR<>0 or @retcode<>0
			return (1)
		end
	else
		set @view_selprocname = ''

	--to be consistent with upgrade code by checking snapshot_ready>0
	if @snapshot_ready>0 and @conflict_table is not NULl
		begin
			exec @retcode = dbo.sp_MSguidtostr @artid, @guidstr out
			if @@ERROR <>0 OR @retcode <>0 return (1)

			exec @retcode = dbo.sp_MSguidtostr @pubid, @pubidstr out
			if @@ERROR <>0 OR @retcode <>0 return (1)

			select @conflict_proc = 'sp_cft_' + substring(@guidstr, 1, 16) + substring(@pubidstr, 1, 16)

			exec @retcode=sp_MSuniqueobjectname @conflict_proc , @conflict_proc output
			if @@ERROR <> 0 OR @retcode <> 0 
				return(1)
			set @dbname = db_name()
			set @command = 'sp_MSmakeconflictinsertproc ' + QUOTENAME(@conflict_table) + ' , ' + QUOTENAME(@ownername) + ' , ' + @conflict_proc  + ' , ' + convert(nvarchar,@objid) 

			set @command = @command	+ ', [' + convert(nchar(36), @pubid) + ']'
			exec @retcode = master..xp_execresultset @command, @dbname
			if @@ERROR<>0 OR @retcode<>0 
			begin
				return (1)
			end
			exec @retcode = dbo.sp_MS_marksystemobject  @conflict_proc 
			if @@ERROR<>0 or @retcode<>0  return (1)

			exec ('grant exec on ' + @conflict_proc + ' to public')
			if @@ERROR<>0 return (1)
			update sysmergearticles set ins_conflict_proc = @conflict_proc where artid = @artid and pubid=@pubid
		end
	-- update articles to set the names
	update sysmergearticles set insert_proc = @ins_procname, update_proc = @upd_procname ,
		select_proc = @sel_procname, view_sel_proc = @view_selprocname
		where artid = @artid and pubid = @pubid
	IF @@ERROR<>0 return (1)
	return (0)
go
exec dbo.sp_MS_marksystemobject sp_MSsetartprocs
go
grant exec on dbo.sp_MSsetartprocs to public
go
SET ANSI_NULLS OFF 
GO


raiserror('Creating procedure sp_MSsetconflicttable', 0,1)
GO

/* Add the conflict table pointer to sysmergearticles - Used by reconciler */
CREATE PROCEDURE sp_MSsetconflicttable (
	@article			sysname,
	@conflict_table		nvarchar(255),
	@publisher			sysname = NULL,
	@publisher_db		sysname = NULL, 
	@publication		sysname = NULL
	) AS

	declare @artid uniqueidentifier
	declare @pubid uniqueidentifier
	declare @quoted_conflict_table nvarchar(270)
	declare @basetableid	int
	
	--special case'd this out for backward compatibility with 7.0 subscribers.
	if @publisher is NULL and @publisher_db is NULL and @publication is NULL
		return (0)

	select @pubid=pubid	from sysmergepublications 
		where name=@publication and LOWER(publisher)=LOWER(@publisher) and publisher_db=@publisher_db
		
	select @artid = artid, @basetableid=objid FROM sysmergearticles WHERE name = @article and pubid=@pubid	
    if @artid IS NULL
        BEGIN
			RAISERROR (20027, 16, -1, @article)
            RETURN (1)
        END

	/*
	** Check to see if current publication has permission
	*/
	declare @retcode int

	if sessionproperty('replication_agent') = 0
	begin
		exec @retcode=sp_MSreplcheck_connection
			@artid = @artid
		if @retcode<>0 or @@ERROR<>0 return (1)
	end

	select @quoted_conflict_table = quotename(@conflict_table)
	exec @retcode = dbo.sp_MS_marksystemobject @quoted_conflict_table
	
	update sysmergearticles set conflict_table = @conflict_table where artid = @artid and pubid=@pubid
	if @@ERROR <> 0
		return (1)

	declare @rgcol nvarchar(135)
	declare @indname nvarchar(131)
	declare @owner sysname
	declare @quotedname nvarchar(270)
		
	select @rgcol = QUOTENAME(name) from syscolumns where id = @basetableid and
                ColumnProperty(id, name, 'isrowguidcol') = 1
	select @owner=user_name(uid) from sysobjects where name=@conflict_table
	select @indname = 'uc_' + @conflict_table
	if len(@indname) > 128
        begin
            select @indname = substring(@indname,1,92) + convert(nvarchar(36), newid())
        end
	set @indname = QUOTENAME(@indname)
	set @quotedname = QUOTENAME(@owner) + '.' + QUOTENAME(@conflict_table)

	--only create the conflict table index when needed.
	if not exists (select * from sysindexes where id = object_id(@quotedname) and keys is not null)
		begin
			exec ('Create unique clustered index ' + @indname + ' on ' + @quotedname +
        			' (' + @rgcol + ', origin_datasource)' )
			if @@error <> 0
				return (1)
		end

	/* Create the conflict insert proc only when necessary for performance reason */
	if exists (select * from sysmergearticles where artid = @artid and pubid=@pubid and OBJECT_ID(ins_conflict_proc) is null)
		BEGIN
		exec dbo.sp_MSgetconflictinsertproc @pubid=@pubid, @artid = @artid, @output = 0
		IF @@ERROR<> 0 OR @retcode <> 0
			return (1)
		END

	return (0)
go
exec dbo.sp_MS_marksystemobject sp_MSsetconflicttable 
go
grant exec on dbo.sp_MSsetconflicttable to public
go

raiserror('Creating procedure sp_addpullsubscription_agent', 0,1)
go
CREATE PROCEDURE sp_addpullsubscription_agent (
    @publisher sysname,
    @publisher_db sysname,
    @publication sysname,         /* publication name */
    @subscriber sysname = NULL,
    @subscriber_db sysname = NULL,
    @subscriber_security_mode       int = NULL,                     /* 0 standard; 1 integrated */
    @subscriber_login               sysname = NULL,
    @subscriber_password            sysname = NULL,
    @distributor sysname = @publisher,
    @distribution_db sysname = NULL,
    @distributor_security_mode int = 0,
    @distributor_login sysname = 'sa',
    @distributor_password sysname = NULL,
    @optional_command_line nvarchar(4000) = '',
    @frequency_type  int = 2 ,  /* 2== OnDemand */
    @frequency_interval int = 1, 
    @frequency_relative_interval int = 1, 
    @frequency_recurrence_factor int = 1, 
    @frequency_subday int = 1, 
    @frequency_subday_interval int = 1 ,
    @active_start_time_of_day int = 0, 
    @active_end_time_of_day int = 0,         
    @active_start_date int = 0, 
    @active_end_date int =0,
    @distribution_jobid binary(16) = NULL OUTPUT,
    @encrypted_distributor_password bit = 0,
    @enabled_for_syncmgr nvarchar(5) = 'false', /* Enabled for SYNCMGR: true or false */
    @ftp_address sysname = NULL,
    @ftp_port int = NULL,
    @ftp_login sysname = NULL,
    @ftp_password sysname = NULL,
    @alt_snapshot_folder  nvarchar(255) = NULL,
    @working_directory    nvarchar(255) = NULL,
    @use_ftp              nvarchar(5) = 'false',
    @publication_type     tinyint = 0,-- 0 - Transactional, 1 - Snapshot, 2 - Merge
    @dts_package_name sysname  = NULL,  /* value will be sent and validated at distributor */                                  
    @dts_package_password  sysname = NULL,
    @dts_package_location nvarchar(12) = N'subscriber',
    @reserved nvarchar(100) = N'', -- Not default to null because null problems in conditional expressions.
    @offloadagent          nvarchar(5) = 'false',
    @offloadserver         sysname = NULL,
    @job_name              sysname = NULL
    ) AS

    SET NOCOUNT ON

    /*
    ** Declarations.
    */

    DECLARE @command nvarchar(4000)
    DECLARE @retcode int
    DECLARE @subscription_type_id int   /* 1 = pull, 2 = anonymous */
    DECLARE @independent_agent_id bit
    DECLARE @distribution_agent nvarchar(100) 
    DECLARE @category_name sysname
    DECLARE @platform_nt binary
    DECLARE @subscriber_enc_password nvarchar(524)
    DECLARE @distributor_enc_password   nvarchar(524)
    DECLARE @use_ftp_bit bit
    DECLARE @offload_agent_bit bit
    
    select @platform_nt = 0x1

    /*
    ** Security Check
    */

    EXEC @retcode = dbo.sp_MSreplcheck_subscribe
    IF @@ERROR <> 0 or @retcode <> 0
        RETURN(1)

    /*
    ** Initializations.
    */

    -- Set null @optional_command_line to empty string to avoid string concat problem
    if @optional_command_line is null
        set @optional_command_line = ''
    else
        set @optional_command_line = N' ' + LTRIM( RTRIM(@optional_command_line) ) + N' '

    IF @distributor_password = N''
        select @distributor_password = NULL

    IF @ftp_password = N''
        select @ftp_password = NULL

    IF @dts_package_password = N''
        select @dts_package_password = NULL

    /*
    ** Parameter Check: @publisher
    ** Check to make sure that the publisher is define
    */
    IF @publisher IS NULL
    BEGIN
        RAISERROR (14043, 16, -1, '@publisher')
        RETURN (1)
    END

    EXECUTE @retcode = dbo.sp_validname @publisher

    IF @@ERROR <> 0 OR @retcode <> 0
       RETURN (1)
    

    /*
    ** Parameter Check: @publisher_db
    */

    IF @publisher_db IS NULL
    BEGIN
        RAISERROR (14043, 16, -1, '@publisher_db')
        RETURN (1)
    END

    EXECUTE @retcode = dbo.sp_validname @publisher_db

    IF @@ERROR <> 0 OR @retcode <> 0
       RETURN (1)

    /*
    ** Parameter Check: @publication
    ** 
    */
    IF @publication IS NULL
    BEGIN
        RAISERROR (14043, 16, -1, '@publication')
        RETURN (1)
    END

    EXECUTE @retcode = dbo.sp_validname @publication

    IF @@ERROR <> 0 OR @retcode <> 0
       RETURN (1)

    /*
    ** Parameter Check: @subscriber and @subscriber_db
    */

    if @subscriber IS NULL or rtrim(@subscriber) = ''
        SELECT @subscriber = @@SERVERNAME

    if @subscriber_db IS NULL or rtrim(@subscriber_db) = ''
        SELECT @subscriber_db = DB_NAME()
    
    EXECUTE @retcode = dbo.sp_validname @subscriber
    IF @@ERROR <> 0 OR @retcode <> 0
       RETURN (1)
    
    EXECUTE @retcode = dbo.sp_validname @subscriber_db
    IF @@ERROR <> 0 OR @retcode <> 0
       RETURN (1)

    /* 
    ** Check to see if MSreplictaion_subscriptions table exists.
    ** If so, copy it into the temp table
    */
    IF  NOT EXISTS (SELECT * FROM sysobjects WHERE 
        type = 'U' AND
        name = 'MSreplication_subscriptions')
    BEGIN
        RAISERROR (20017, 16, -1)
        RETURN (1)
    END 
    
    /*
    ** Check to make sure that the subscription does exist
    */
    IF NOT EXISTS (SELECT * FROM  MSreplication_subscriptions
                WHERE UPPER(publisher) = UPPER(@publisher) AND
                      publisher_db  = @publisher_db AND
                      publication = @publication)
    BEGIN
        RAISERROR (20017, 16, -1)
        RETURN (1)
    END
    
    declare @update_mode_id int
    SELECT  @distribution_agent = NULL
    SELECT  @independent_agent_id = independent_agent, 
            @subscription_type_id = subscription_type,
            @distribution_agent = distribution_agent,
            @update_mode_id = update_mode
        FROM  MSreplication_subscriptions
        WHERE UPPER(publisher) = UPPER(@publisher) AND
              publisher_db  = @publisher_db AND
              publication = @publication
    /* Distribution agent for push subscriptions is at distributor side */
    IF @subscription_type_id = 0
    BEGIN
        RAISERROR (21001, 16, -1)
        RETURN (1)
    END

    IF @distribution_agent IS NOT NULL
    BEGIN
        RAISERROR (21002, 11, -1, @distribution_agent)
        RETURN (1)
    END

    -- Parameter check: @subscriber_security_mode
    if @subscriber_security_mode is null
    begin
        if ( platform() & @platform_nt ) = @platform_nt
            select @subscriber_security_mode = 1
        else
            select @subscriber_security_mode = 0
    end 

    if ( ( platform() & @platform_nt ) <> @platform_nt and @subscriber_security_mode = 1 )
    begin
        RAISERROR(21038, 16, -1)
        RETURN (1)
    end

    if (@subscription_type_id <> 0)
    begin
        if (@subscriber_security_mode = 0) and (@subscriber_login IS NULL or rtrim(@subscriber_login) = '')
        begin
            raiserror(21344, 16, -1, '@subscriber_login')
            return (1)
        end
    end
    
    if (@distributor_security_mode = 0) and (@distributor_login IS NULL or rtrim(@distributor_login) = '')
    begin
        raiserror(3217, 16, -1, '@distributor_login')
        return (1)
    end

    IF NOT EXISTS (select * from sysobjects where name = 'MSsubscription_properties' and type = 'U')
    begin
        exec @retcode = sp_MScreate_sub_tables @property_table = 1
        if @retcode <> 0 or @@error <> 0
        return (1)
    end

    /* 
    ** Parameter check: @alt_snapshot_folder 
    ** @alt_snapshot_folder and @use_ftp are mutually exclusive    
    */

    IF @alt_snapshot_folder <> N'' AND @alt_snapshot_folder IS NOT NULL
       AND LOWER(@use_ftp collate SQL_Latin1_General_CP1_CS_AS) = N'true'
    BEGIN
        RAISERROR(21146, 16, -1)
        RETURN (1)
    END

    /* 
    ** Parameter check: @use_ftp
    ** Must be 'true' or 'false'
    */
    IF LOWER(@use_ftp collate SQL_Latin1_General_CP1_CS_AS) NOT IN ('true', 'false')
    BEGIN
        RAISERROR (14148, 16, -1, '@use_ftp')
        RETURN (1)
    END
    
    IF LOWER(@use_ftp collate SQL_Latin1_General_CP1_CS_AS) = 'true'
    BEGIN
        SELECT @use_ftp_bit = 1
    END
    ELSE
    BEGIN
        SELECT @use_ftp_bit = 0
    END


    /*
    ** Parameter check: @publication_type
    ** Must be 0 - Transactional or 1 - Snapshot
    */
    IF @publication_type NOT IN (0, 1)
    BEGIN
        RAISERROR (20033, 16, -1)
        RETURN (1)
    END

    /*
    ** Parameter Check: @dts_package_location
    ** Valid values:
    ** distributor
    ** subscriber
    **
    */
    IF LOWER(@dts_package_location collate SQL_Latin1_General_CP1_CS_AS) NOT IN ('distributor', 'subscriber')
    BEGIN
        RAISERROR(21179, 16, -1)    
        RETURN (1)
    END

    declare @dts_package_location_id int

    IF LOWER(@dts_package_location collate SQL_Latin1_General_CP1_CS_AS) = 'distributor'
        SELECT @dts_package_location_id = 0
    ELSE 
        SELECT @dts_package_location_id = 1

    -- Have to be a push, non updatable  subscription to set DTS package name
    if @dts_package_name is not null
    begin
        if  @update_mode_id != 0
        begin
            RAISERROR(21180, 16, -1)    
            RETURN (1)
        end
    end
    
    -- Copy the passwords to new value before attempting to encrypt
    set @distributor_enc_password = @distributor_password
    IF (@encrypted_distributor_password = 0)
        -- Encrypt the password
        BEGIN
            EXEC @retcode = master.dbo.xp_repl_encrypt @distributor_enc_password OUTPUT
            IF @@error <> 0 OR @retcode <> 0
                return 1
        END
	
    declare @dts_package_enc_password nvarchar(524)
    set @dts_package_enc_password = @dts_package_password

    if @dts_package_enc_password is not null
    begin
        EXEC @retcode = master.dbo.xp_repl_encrypt @dts_package_enc_password OUTPUT
        IF @@error <> 0 OR @retcode <> 0
            return 1
    end

    /*
    ** Parameter Check: @offloadserver
    ** 1. If @offloadagent = 'true' then @offloadserver cannot be null.
    ** 2. Similar to the push case, we don't allow "remote" activation
    **    of agent on the local machine.
    */
    SELECT @offloadagent = LOWER(@offloadagent collate SQL_Latin1_General_CP1_CS_AS)
    IF @offloadagent NOT IN ('true', 'false')
    BEGIN
        RAISERROR (14148, 16, -1, '@offloadagent')
        RETURN (1)
    END

    IF @offloadagent = 'true'
    BEGIN
        SELECT @offload_agent_bit = 1
    END
    ELSE
    BEGIN
        SELECT @offload_agent_bit = 0
    END

    IF @offload_agent_bit = 1 AND (@offloadserver is NULL or
                               @offloadserver = N'')
    BEGIN
        RAISERROR(21215, 16, -1)
        RETURN (1)
    END
    
    IF UPPER(@offloadserver) = UPPER(@@SERVERNAME) AND
       @offload_agent_bit = 1
    BEGIN
        RAISERROR(21227, 16, -1)
        RETURN (1)
    END

    EXEC @retcode = sp_MSreplcheckoffloadserver @offloadserver
    IF @retcode <> 0 OR @@ERROR <> 0
        RETURN (1)

    /*
    ** Construct unique name
    */
    if @subscriber is NULL select @subscriber = ''
    if @subscriber_db is NULL select @subscriber_db = ''
    
    declare @job_existing bit
    if @job_name is null
    begin
        select @job_existing = 0
        SELECT @job_name = CONVERT(nvarchar(18),@publisher ) + '-' + CONVERT(nvarchar(18),@publisher_db) + '-' + 
                        CONVERT(nvarchar(18),@publication) + '-' + CONVERT(nvarchar(18),@subscriber) + '-' +
                        CONVERT(nvarchar(18),@subscriber_db) + '-' + CONVERT(nvarchar(36),newid())
    end
    else
        select @job_existing = 1

    -- Get property values.
    if @reserved = 'no_change_to_properties'
    begin
        -- Get the distributor value. It will be used in agent command line.
        select @distributor = distributor, 
            @enabled_for_syncmgr = case enabled_for_syncmgr
                when 0 then 'false'
                when 1 then 'true'
                end
        from MSsubscription_properties where
            UPPER(publisher) = UPPER(@publisher)
            and publisher_db =  @publisher_db
            and publication = @publication              
    end

    BEGIN TRAN

    /*
    ** If the publication is independent agent type or it is the first
    ** subscription on the non independent agent publications.
    */

    IF @independent_agent_id = 1 OR 
        NOT EXISTS (SELECT * FROM MSreplication_subscriptions WHERE
                            UPPER(@publisher) = UPPER(publisher) and
                            @publisher_db = publisher_db and
                            agent_id IS NOT NULL and
                            independent_agent = 0)
    BEGIN
        if @job_existing = 0
        begin
            /* Construct agent command */
            SELECT @command = '-Publisher ' + @publisher + ' '
            SELECT @command = @command + '-PublisherDB ' + QUOTENAME(@publisher_db) + ' '
            IF @independent_agent_id = 1
                SELECT @command = @command + '-Publication ' + QUOTENAME(@publication) + ' '

            SELECT @command = @command + '-Distributor ' + QUOTENAME(@distributor)  + ' '

            /*
            Use -Xdatabase to save command line space
            We can not use -Xserver for distribution because SQLExec will validate the server
            to be in sysservers.

            SELECT @command = @command + '-DistributionDB ' + QUOTENAME(@distribution_db)  + ' '
            */
            
            SELECT @command = @command + '-SubscriptionType ' + convert(nvarchar(10),@subscription_type_id)  + ' '
            SELECT @command = @command + '-Subscriber ' + QUOTENAME(@subscriber)  + ' '
        
            select @command = @command + '-SubscriberSecurityMode ' + 
                convert(nvarchar(10),@subscriber_security_mode) + ' '
            if @subscriber_login is not NULL
                select @command = @command + '-SubscriberLogin ' + quotename(@subscriber_login) + ' '
            if @subscriber_password is not NULL
            begin
                set @subscriber_enc_password = @subscriber_password
                exec @retcode = master.dbo.xp_repl_encrypt @subscriber_enc_password OUTPUT
                select @command = @command + '-SubscriberEncryptedPassword ' + quotename(@subscriber_enc_password) + ' '
            end

            SELECT @command = @command + '-SubscriberDB ' + QUOTENAME(@subscriber_db) + ' '

                    
            if @dts_package_name is not null
              select @command = @command + '-UseDTS '

            if @offload_agent_bit = 1 
                select @command = @command + N'-Offload ' + @offloadserver + N' '

            /* 
            ** make sure the command line is not truncated
            */
            /* Use datalength because len doesn't count the last space in @command */
            IF (datalength(@command) + datalength(@optional_command_line)) > 8000
            BEGIN
                RAISERROR(20018, 16, -1)
                RETURN(1)
            END

            SELECT @command = @command + @optional_command_line

            -- Get Distribution category name (assumes category_id = 10)
            select @category_name = name FROM msdb.dbo.syscategories where category_id = 10

            EXEC @retcode = dbo.sp_MSadd_repl_job
                    @name = @job_name,
                    @subsystem = 'Distribution',
                    @server = @@SERVERNAME,
                    @databasename = @distribution_db,
                    @enabled = 1,
                    @freqtype = @frequency_type,
                    @freqinterval = @frequency_interval,
                    @freqsubtype = @frequency_subday,
                    @freqsubinterval = @frequency_subday_interval,
                    @freqrelativeinterval = @frequency_relative_interval,
                    @freqrecurrencefactor = @frequency_recurrence_factor,
                    @activestartdate = @active_start_date,
                    @activeenddate = @active_end_date,
                    @activestarttimeofday = @active_start_time_of_day,
                    @activeendtimeofday = @active_end_time_of_day,
                    @command = @command,
                    @category_name = @category_name,
                    @retryattempts = 10,
                    @retrydelay = 1,
                    @job_id = @distribution_jobid OUTPUT

            IF @@ERROR <> 0 or @retcode <> 0
            BEGIN
                IF @@TRANCOUNT = 1
                    ROLLBACK TRAN
                ELSE
                    COMMIT TRAN   
                RETURN(1)
            END
        end
        else
        begin
            select @distribution_jobid = job_id from msdb..sysjobs_view where 
                name = @job_name collate database_default and
                UPPER(originating_server) = UPPER(CONVERT(sysname, SERVERPROPERTY('ServerName')))
            if @distribution_jobid IS NULL
            begin
                -- Message from msdb.dbo.sp_verify_job_identifiers
                RAISERROR(14262, -1, -1, 'Job', @job_name)          
                IF @@TRANCOUNT = 1
                    ROLLBACK TRAN
                ELSE
                    COMMIT TRAN   
                RETURN(1)
            end
        end
    END

    if @reserved <> 'no_change_to_properties' and (@subscription_type_id = 1) OR (@subscription_type_id = 2)
    BEGIN
        IF NOT EXISTS (select * from MSsubscription_properties 
            where UPPER(publisher) = UPPER(@publisher)
              and publisher_db =  @publisher_db
              and publication = @publication) 
        BEGIN
            -- Publication type:
            -- 0  transactional
            -- 1  snapshot
            -- 2  merge (not allowed)

            INSERT INTO MSsubscription_properties 
            (publisher, publisher_db, publication, publication_type, 
             publisher_login,publisher_password, publisher_security_mode, 
             distributor, distributor_login, distributor_password, 
             distributor_security_mode, ftp_address, ftp_port, ftp_login, 
             ftp_password, alt_snapshot_folder, working_directory, use_ftp,
             dts_package_name, dts_package_password, dts_package_location, 
             offload_agent, offload_server, dynamic_snapshot_location)
            values (@publisher, @publisher_db, @publication, @publication_type, NULL, NULL, 1, 
                @distributor, @distributor_login, @distributor_enc_password, 
                @distributor_security_mode, null, null, null,
                null, @alt_snapshot_folder, @working_directory, @use_ftp_bit,
                @dts_package_name, @dts_package_enc_password, 
                @dts_package_location_id, @offload_agent_bit, @offloadserver, null)

            IF @@ERROR <> 0 
            BEGIN
                IF @@TRANCOUNT = 1
                    ROLLBACK TRAN
                ELSE
                    COMMIT TRAN           
                RETURN(1)
            END
        END
        ELSE
        BEGIN
            update MSsubscription_properties set
                distributor = @distributor,
                distributor_login = @distributor_login,
                distributor_password = @distributor_enc_password,
                distributor_security_mode = @distributor_security_mode,
                dts_package_name = @dts_package_name,
                dts_package_password = @dts_package_enc_password,
                dts_package_location = @dts_package_location_id
                where UPPER(publisher) = UPPER(@publisher)
                    and publisher_db =  @publisher_db
                    and publication = @publication
        END


        -- For dependent subscriptions we need to fix up all the
        -- shared properties  
        IF @independent_agent_id = 0 
        BEGIN

            EXEC @retcode = sp_MSfixupsharedagentproperties
                   @publisher = @publisher,
                   @publisher_db = @publisher_db,
                   @publication = @publication,
                   @distributor = @distributor,
                   @distributor_security_mode = @distributor_security_mode,
                   @distributor_login = @distributor_login,
                   @distributor_password = @distributor_enc_password,
                   @ftp_address = @ftp_address,
                   @ftp_port = @ftp_port,
                   @ftp_login = @ftp_login,
                   @ftp_password = @ftp_password,
                   @alt_snapshot_folder = @alt_snapshot_folder,
                   @working_directory = @working_directory,
                   @use_ftp = @use_ftp_bit,
                   @offload_agent = @offload_agent_bit,
                   @offload_server = @offloadserver
                    
            IF @retcode <> 0 OR @@ERROR <> 0
            BEGIN
            IF @@TRANCOUNT = 1
                ROLLBACK TRAN
            ELSE
                COMMIT TRAN           
            RETURN(1)
            END
        END

        IF @@ERROR <> 0 
        BEGIN
            IF @@TRANCOUNT = 1
                ROLLBACK TRAN
            ELSE
                COMMIT TRAN           
            RETURN(1)
        END
    END


    /* If we do not have independent agents , i.e. independent_agent=0, but there is
    already a row for that publisher and that publisher database with a NOT null 
    distribution_agent_id, then set the @distribution_jobid to that id.  Note that if
    there are no rows returned, the value of the variable does not change, which is what we want.
    There should never be more than one row ever returned for this query - but will use TOP 1
    to insist that is the case.
    */
    
    IF @independent_agent_id = 0
    BEGIN
        SELECT DISTINCT @distribution_jobid=agent_id, @job_name = distribution_agent 
          FROM MSreplication_subscriptions
         WHERE UPPER(publisher) = UPPER(@publisher) 
           AND publisher_db =  @publisher_db
           AND agent_id IS NOT NULL AND independent_agent=0
    
    END

    UPDATE MSreplication_subscriptions 
       SET distribution_agent = @job_name,
           agent_id = @distribution_jobid
     WHERE UPPER(publisher) = UPPER(@publisher) 
       AND publisher_db =  @publisher_db 
       AND publication =  @publication 
       AND (subscription_type = 1 /* pull*/ OR subscription_type = 2) /*anonymous*/

    IF @@ERROR <> 0 
    BEGIN
        IF @@TRANCOUNT = 1
            ROLLBACK TRAN
        ELSE
            COMMIT TRAN           
        RETURN(1)
    END 

    /* Conditional support for MobileSync */
    if LOWER(@enabled_for_syncmgr collate SQL_Latin1_General_CP1_CS_AS) = 'true'
    BEGIN
        /* Call sp_MSregistersubscription so that the subscription can be synchronized via MobileSync etc. */
        declare @subscription_id uniqueidentifier
        declare @failover_mode_id int
        set @subscription_id = convert(uniqueidentifier, @distribution_jobid)

        if @update_mode_id in (3,5) 
            select @failover_mode_id = 1
        else if @update_mode_id in (2,4)
            select @failover_mode_id = 2
        else
            select @failover_mode_id = 0
            
        exec @retcode = dbo.sp_MSregistersubscription @replication_type = 1,
                                    @publisher = @publisher,
                                    @publisher_db = @publisher_db,
                                    @publication = @publication,
                                    @subscriber = @subscriber,
                                    @subscriber_db = @subscriber_db,
                                    @subscriber_security_mode = @subscriber_security_mode,
                                    @subscriber_login = @subscriber_login,
                                    @subscriber_password = @subscriber_password,
                                    @distributor = @distributor,
                                    @subscription_id = @subscription_id,
                                    @independent_agent = @independent_agent_id,
                                    @subscription_type = @subscription_type_id,
                                    @failover_mode = @failover_mode_id
        IF @@ERROR <> 0 or @retcode <> 0
        BEGIN
            IF @@TRANCOUNT = 1
                ROLLBACK TRAN
            ELSE
                COMMIT TRAN           
            RETURN(1)
        END
    END

    COMMIT TRAN
    RETURN(0)
GO

grant execute on dbo.sp_addpullsubscription_agent to public
go

raiserror('Creating procedure sp_MSenumallsubscriptions', 0,1)
go

CREATE PROCEDURE sp_MSenumallsubscriptions(
@subscription_type	nvarchar(5) = 'push', 
@subscriber_db		sysname='%'
)AS

	set nocount on
	declare @current_db		sysname
	declare @retcode		int
	declare @proc			nvarchar(200)
	declare @db_status		int

	create table #MSenumallsubscriptions (
						publisher			sysname collate database_default not null,
						publisher_db		sysname collate database_default not null,
						publication			sysname collate database_default null,
						replication_type	int not NULL,
						subscription_type	int not NULL,
						last_updated		datetime null,
						subscriber_db		sysname collate database_default not null,
						update_mode			smallint null,
						last_sync_status	int null,
						last_sync_summary	sysname collate database_default null,
						last_sync_time		datetime null
						)

	declare #cur_db cursor local FAST_FORWARD FOR select DISTINCT name, status
		FROM master.dbo.sysdatabases where ((@subscriber_db = N'%' collate database_default) or (name = @subscriber_db collate database_default)) and
			has_dbaccess(name) = 1
	open #cur_db
	fetch #cur_db into @current_db, @db_status
	while (@@fetch_status <> -1)
	begin
		/*
		 * we only return subscriptions in db which is not in loading (0x20), suspect(0x100),
		 * offline(0x200), in recovering(0x80), shutdown(0x40000), not recovered(0x40)
		 */
		if (@db_status & 0x403e0) = 0
			begin
				select @proc = QUOTENAME(@current_db) + '.' + 'dbo.sp_MSenumsubscriptions ' 
				insert into #MSenumallsubscriptions exec @retcode = @proc  @subscription_type
				if @@ERROR<>0 or @retcode<>0
					begin
						close #cur_db
						deallocate #cur_db
						return (1)
					end
			end
		fetch next from #cur_db into @current_db, @db_status
	end
    select  distinct 'publisher'				= publisher,
            'publishing database'	= publisher_db,
            'publication'			= publication,
            'replication type'		= replication_type,
            'subscription type'     = subscription_type,
			'last updating time'	= convert(nvarchar(12), last_updated, 112) + 
                                          substring(convert(nvarchar(24), last_updated, 121), 11,13),
			'subscribing database'  = subscriber_db,
			'update_mode'           = update_mode,
			'last sync status'		= last_sync_status,
			'last sync summary'		= last_sync_summary,
			'last sync time'		= convert(nvarchar(12), last_sync_time, 112) + 
				substring(convert(nvarchar(24), last_sync_time, 121), 11,13)
	from #MSenumallsubscriptions
	--drop table #MSenumallsubscriptions
	close #cur_db
	deallocate #cur_db
	return (0)
Go
grant execute on dbo.sp_MSenumallsubscriptions to public
go 
exec dbo.sp_MS_marksystemobject sp_MSenumallsubscriptions
GO

raiserror('Creating procedure sp_MSinsertbeforeimageclause', 0,1)
GO

create proc sp_MSinsertbeforeimageclause @pubid uniqueidentifier, @objid int, @tablenickstr nvarchar(12)  as
	set nocount on
	declare @cmdpiece nvarchar(4000)
	declare @before_objid int
	declare @sync_objid int
	declare @before_name sysname
	declare @collist nvarchar(4000)
	declare @vallist nvarchar(4000)
	declare @colname sysname
	declare @colordinal smallint
	declare @argname sysname

	-- Do we have a before table?
	select @before_objid = max(before_image_objid) from  sysmergearticles where objid = @objid and
			before_image_objid is not null
	select @before_name = OBJECT_NAME(@before_objid)

	select @sync_objid = sync_objid	from sysmergearticles where objid=@objid and pubid=@pubid

	if @before_name is null
		begin
			return 0
		end

	set @collist = ''
	-- Loop over columns to make the column list for the insert / select command
	declare col_cursor CURSOR LOCAL FAST_FORWARD for select name from syscolumns
	where id = @before_objid and name <> 'generation' and name <> 'system_delete' order by colid
	FOR READ ONLY

	open col_cursor
	set @vallist = ''
	fetch next from col_cursor into @colname
	while (@@fetch_status <> -1)
		begin
		--this column is not in vertical partitioning
		if not exists (select * from syscolumns where name=@colname and id=@sync_objid)
		begin
			fetch next from col_cursor into @colname
			continue
		end
		set @collist = @collist + QUOTENAME(@colname) + ', '
		exec sp_MSgetcolordinalfromcolname @objid, @sync_objid, @colname, @colordinal out
		select @argname = '@p' + rtrim(convert(nchar, @colordinal))
		set @vallist = @vallist + @argname + ', '
		fetch next from col_cursor into @colname
		end
	close col_cursor
	deallocate col_cursor

	-- Our list has all of the columns except generation since that gets set to a local variable
	-- Make the insert command
	set @cmdpiece = ' declare @gen_cur int select @gen_cur = max(gen_cur) from sysmergearticles where nickname = ' + @tablenickstr
	insert into #tempcmd (phase, cmdtext) values (8, @cmdpiece)
	--select @cmdpiece

	set @cmdpiece = ' insert into ' + QUOTENAME(@before_name) + ' ( ' + @collist +	
					' generation, system_delete) values (' + @vallist + ' @gen_cur, 1 )'
	insert into #tempcmd (phase, cmdtext) values (8, @cmdpiece)
	--select @cmdpiece

	return 0
	
go

exec dbo.sp_MS_marksystemobject sp_MSinsertbeforeimageclause  
go

grant exec on dbo.sp_MSinsertbeforeimageclause to public
go
create procedure sp_MShelpalterbeforetable
	@objid int,
	@biname sysname
AS
	declare @command nvarchar(4000)
	declare @retcode int
	declare @include int
	declare @tablenick int
	declare @colpat nvarchar(130)
	declare @colname nvarchar(130)
	declare @typename sysname
	declare @colid smallint
	declare @colidstr nvarchar(3)
	declare @status tinyint
	declare @len smallint
	declare @prec smallint
	declare @scale int
	declare @isnullable tinyint
	declare @bi_objid int
	set nocount on
	declare @cMaxIndexLength int

	set @cMaxIndexLength= 900  -- max index column size in SQL 2000

	select @tablenick = max(nickname) from sysmergearticles where objid = @objid
	if @tablenick is null 
		return (1)

	select @bi_objid = OBJECT_ID(@biname)		
	
	-- Loop over the columns and see which ones we include
	declare col_cursor CURSOR LOCAL FAST_FORWARD for select name, status, type_name(xtype), length,
		 prec, scale, isnullable, colid from syscolumns
	where id = @objid and iscomputed <> 1 and type_name(xtype) <> 'timestamp' order by colid
	FOR READ ONLY
	
	open col_cursor
	fetch next from col_cursor into @colname, @status, @typename, @len, @prec, @scale, @isnullable, @colid
	while (@@fetch_status <> -1)
		begin
		set @include = 0
		set @colpat = '%' + @colname + '%'

		if not exists (select * from syscolumns where id = @bi_objid and QUOTENAME(name) = QUOTENAME('system_delete'))
			begin
				set @command = 'alter table ' + @biname + ' ADD system_delete bit default(0) '
				execute ( @command )
				if @@ERROR<>0 
					goto errlabel

				/* grant select to system_delete column */
			   	exec ('grant select (system_delete) on ' + @biname + ' to public')
			   	if @@ERROR<>0 
					goto errlabel

					
			end

		exec ('grant select (generation), update(generation), delete on ' + @biname + ' to public')
			   	if @@ERROR<>0 
					goto errlabel

		-- Is this column already in the before image table?
		-- or the column is not in the vertical partitioning?
		if exists (select * from syscolumns where id = @bi_objid and name = @colname) OR
			exists (select * from sysmergearticles where objid=@objid and not exists (
				select * from syscolumns where id = sync_objid and name = @colname))
			begin
			goto fetchnext
			end

		-- does updating this column change membership in a partial replica? 
		if exists (select * from sysmergearticles 
			where objid = @objid and subset_filterclause like @colpat)
			set @include = 1
		else if exists (select * from sysmergesubsetfilters
			where art_nickname = @tablenick and join_filterclause like @colpat)
			set @include = 1
		else if exists (select * from sysmergesubsetfilters
			where join_nickname = @tablenick and join_filterclause like @colpat)
			set @include = 1

		-- If we want this column, map its type and insert a row to temp table
		if @include <> 1
			begin
			goto fetchnext
			end
		if @typename='nvarchar' or @typename='nchar' -- a unit of nchar takes 2 bytes
			set @len = @len/2
		exec @retcode = dbo.sp_MSmaptype @typename out, @len, @prec, @scale
		if @@ERROR<>0 or @retcode<>0 
			goto errlabel
		if @typename not in ('text', 'ntext','image')
		begin
			set @colname = QUOTENAME(@colname)
	
			-- Always make columns nullable when we add them because we might have
			-- existing rows in the before image table.

			set @command = 'alter table ' + @biname + ' ADD ' + @colname + ' ' + @typename + ' NULL '
		
			execute ( @command )
			if @@ERROR<>0 goto errlabel

			-- Insert a create index command if column is not too long
			if (@len <= @cMaxIndexLength)
			begin
				set @colidstr =convert(nvarchar(3), @colid)
	 			set @command = 'create index ' + @biname + '_' + @colidstr + ' on ' + @biname + ' (' + @colname + ')'
				execute ( @command )
				if @@ERROR<>0 goto errlabel
			end
		end
							
fetchnext:
		/* Repeat the loop with next column */
		fetch next from col_cursor into @colname, @status, @typename, @len, @prec, @scale, @isnullable, @colid
		end
	close col_cursor
	deallocate col_cursor	
	return 0
errlabel:
	close col_cursor
	deallocate col_cursor	
	return 1

go

exec dbo.sp_MS_marksystemobject sp_MShelpalterbeforetable 
go

SET ANSI_NULLS OFF 
GO
raiserror('Creating procedure sp_MSmakesystableviews', 0,1)
GO

-- Used by snapshot
create procedure sp_MSmakesystableviews (
	@publication sysname,
    @dynamic_snapshot_views_table_name sysname = null
    )
AS
	declare @guidstr 		nvarchar(40)
	declare @pubid  		uniqueidentifier
	declare @contentsview 	sysname 
	declare @tombstoneview 	sysname
	declare @genhistoryview	sysname
	declare @filtersview	sysname
	declare @piece			nvarchar(4000)
	declare @retcode smallint
	declare @dbname			sysname
	declare @art_count		int
	declare @skip_ctsv 		int
	declare	@command		nvarchar(500)
    declare @dynamic_filters bit
    declare @view_creation_command nvarchar(4000)
    declare @newid          uniqueidentifier

	/*
	** Check to see if current publication has permission
	*/
	exec @retcode=sp_MSreplcheck_publish
	if @retcode<>0 or @@ERROR<>0 return (1)
	set @skip_ctsv = 0
	select @pubid = pubid, @dynamic_filters = dynamic_filters from sysmergepublications where name = @publication and UPPER(publisher)=UPPER(@@SERVERNAME) and publisher_db=db_name()
	if @pubid is null
        BEGIN
			RAISERROR (20026, 16, -1, @publication)
            RETURN (1)
        END
	select @art_count=count(*) from sysmergearticles where pubid=@pubid
	if @art_count > 253
		set @skip_ctsv=1
    select @newid = newid()
	create table #temp_table_for_systable_view(contentsview sysname, tombstoneview sysname NULL, genhistoryview sysname NULL, filtersview sysname NULL)
	exec @retcode = dbo.sp_MSguidtostr @newid, @guidstr out
	if @@ERROR<>0 OR @retcode<>0 return (1)
	select @contentsview = 'cont' + @guidstr
	select @tombstoneview = 'ts' + @guidstr
	select @genhistoryview = 'gh' + @guidstr
	select @filtersview = 'filt' + @guidstr

	set @guidstr = '''' + convert(nchar(36), @pubid) + ''''
	
	exec @retcode = dbo.sp_MSuniqueobjectname @tombstoneview, @tombstoneview out
	if @@ERROR<>0 OR @retcode<>0 return (1)
	exec @retcode = dbo.sp_MSuniqueobjectname @contentsview, @contentsview out
	if @@ERROR<>0 OR @retcode<>0 return (1)
	exec @retcode = dbo.sp_MSuniqueobjectname @genhistoryview, @genhistoryview out
	if @@ERROR<>0 OR @retcode<>0 return (1)
	exec @retcode = dbo.sp_MSuniqueobjectname @filtersview, @filtersview out
	if @@ERROR<>0 OR @retcode<>0 return (1)
	
	insert #temp_table_for_systable_view values(@contentsview,@tombstoneview,@genhistoryview,@filtersview)

	if @skip_ctsv = 0
	begin
		/* generate view for MSmerge_contents qualified by the pubid */
	    /* For dynamically filtered publication, security check is performed in
	       the sync view of the base table */
		set @command = 'sp_MSmakectsview ' + QUOTENAME(@publication) + ' , ' + @contentsview + ' , ' + COALESCE(QUOTENAME(@dynamic_snapshot_views_table_name) collate database_default, N'null' collate database_default) 
		set @dbname = db_name()

		exec @retcode = master..xp_execresultset @command, @dbname
		if @@ERROR<>0 OR @retcode <>0 
			return (1)
	end
	else
	begin
		exec('create view ' + @contentsview + ' as select * from MSmerge_contents where 1 = 2')
		if @@ERROR<>0
			return (1)
	end
	/* 
	** generate the view for dbo.MSmerge_tombstone. In SP2 and Shiloh, the change was made to make the view 
	** return 0 rows since it is unnecessary and expensive to propagate the tombstones.
	** In order to leave all the other moving parts unchanged, we decided to let the view 
	** return 0 rows.
	*/
    select @view_creation_command = 'create view ' + @tombstoneview + ' as select * from dbo.MSmerge_tombstone where 1= 2 and
			tablenick in (select nickname from sysmergearticles where pubid = ' +
			@guidstr + ')'

    if @dynamic_filters = 1
    begin
        select @view_creation_command = @view_creation_command + ' and ((is_srvrolemember(''sysadmin'') = 1) or (is_member(''db_owner'') = 1) or (sessionproperty(''replication_agent'') = 1))'
    end

	exec (@view_creation_command)
	if @@ERROR <>0 
		begin
			return (1)
		end

	select @view_creation_command = 'create view ' + @genhistoryview + '(guidsrc, guidlocal, pubid, generation,
			art_nick, nicknames, coldate) as select DISTINCT guidsrc, guidlocal, CONVERT(uniqueidentifier, ' 
			+ @guidstr + '), generation, art_nick, nicknames, coldate  from dbo.MSmerge_genhistory
			where guidlocal <> ''00000000-0000-0000-0000-000000000000'' and (art_nick = 0 or art_nick is NULL or
					art_nick in (select nickname from sysmergearticles where pubid = ' +
			@guidstr + ')) '
    if @dynamic_filters = 1
    begin
        select @view_creation_command = @view_creation_command + ' and ((is_srvrolemember(''sysadmin'') = 1) or (is_member(''db_owner'') = 1) or (sessionproperty(''replication_agent'') = 1))'
    end

	exec (@view_creation_command)
	if @@ERROR <>0
		begin
			return (1)
		end

    select @view_creation_command = 'create view ' + @filtersview + ' as select * from sysmergesubsetfilters where pubid = ' +
			@guidstr

    if @dynamic_filters = 1
    begin
        select @view_creation_command = @view_creation_command + ' and ((is_srvrolemember(''sysadmin'') = 1) or (is_member(''db_owner'') = 1) or (sessionproperty(''replication_agent'') = 1))'
    end

	exec (@view_creation_command)
	if @@ERROR <>0
		begin
			return (1)
		end

    if @dynamic_filters = 1
    begin
        exec ('grant select on ' + @contentsview + ' to public')
		if @@error<>0 return(1)
        exec ('grant select on ' + @tombstoneview + ' to public')
		if @@error<>0 return(1)
        exec ('grant select on ' + @genhistoryview + ' to public')
		if @@error<>0 return(1)
        exec ('grant select on ' + @filtersview + ' to public')            
		if @@error<>0 return(1)
    end

	set nocount on
	/* we only generate per-article contents view for static publications */
	if @dynamic_filters=0
		begin
			exec @retcode = sp_MSgettablecontents @pubid
			if @@ERROR<>0 OR @retcode <>0 return (1)
 		end
	exec('select * from #temp_table_for_systable_view ')
	drop table #temp_table_for_systable_view

	return (0)
go
exec dbo.sp_MS_marksystemobject sp_MSmakesystableviews
go
grant exec on dbo.sp_MSmakesystableviews to public
go

raiserror('Creating procedure sp_MSenumsubscriptions', 0,1)
go

CREATE PROCEDURE sp_MSenumsubscriptions(
@subscription_type	nvarchar(5) = 'push',
@publisher		sysname = '%',
@publisher_db 	sysname = '%'
)AS

	set nocount on
	declare @dbname		sysname
	declare @category 	int
	declare @proc			nvarchar(200)
	declare @retcode	int
	declare @cur_db		sysname
	declare @type_value	int

	select @type_value = 100
	
	if LOWER(@subscription_type collate SQL_Latin1_General_CP1_CS_AS)='push'
		select @type_value = 0
	else
		if LOWER(@subscription_type collate SQL_Latin1_General_CP1_CS_AS)='pull'
			select @type_value = 1
		else
			if LOWER(@subscription_type collate SQL_Latin1_General_CP1_CS_AS)='both'
				select @type_value = 2

	select @cur_db = db_name()
	
	create table #MSenumpushsubscriptions (
						publisher			sysname collate database_default not null,
						publisher_db		sysname collate database_default not null,
						publication			sysname collate database_default null,
						replication_type	int not NULL,
						subscription_type	int not NULL,
						last_updated		datetime null,
						subscriber_db		sysname collate database_default not null,
						update_mode			smallint null,
						last_sync_status	int null,
						last_sync_summary	sysname collate database_default null,
						last_sync_time		datetime null
						)

	if exists (select * from sysobjects where name='sysmergesubscriptions')
	begin
		-- return all subscriptions that this database is a subscriber to
		-- suppress all subscriptions that originate from this database.
		insert into #MSenumpushsubscriptions select p.publisher, p.publisher_db, p.name, 2, 
			s.subscription_type, s.last_sync_date, s.db_name, 
			NULL, s.last_sync_status, s.last_sync_summary, s.last_sync_date
			from sysmergepublications p, sysmergesubscriptions s
			where p.pubid = s.pubid 
			and (s.subscription_type=@type_value OR @type_value=2) 
			and s.pubid <> s.subid 
			and ((@publisher = N'%') or (p.publisher = @publisher))
           	and ((@publisher_db = N'%') or ( p.publisher_db = @publisher_db))
			and s.db_name = @cur_db
			and p.pubid not in 
				(select pubid from sysmergepublications pubs where 
					lower(pubs.publisher) = LOWER(@@servername) AND
					pubs.publisher_db = @cur_db)
	end

	if exists (select * from sysobjects where name='MSreplication_subscriptions')
	begin
		if  exists (select * from sysobjects where name='MSsubscription_properties') and
			exists (select * from sysobjects where name='MSsubscription_agents ') 
		begin
			-- update_mode in MSreplication_subscriptions table is not reliable.
			insert into #MSenumpushsubscriptions select s.publisher, s.publisher_db, s.publication,
				case isnull(p.publication_type,0) when 0 then 0 else 1 end,
				s.subscription_type,
				s.time, @cur_db, 
				-- NOTE: For Queued case: we will always return 2/3 for the 4/5 case
				-- since we overload update_mode based on queue_type
				case when isnull(a.update_mode,0) = 4 then 2
				when isnull(a.update_mode,0) = 5 then 3
				else isnull(a.update_mode,0)
				end,
				a.last_sync_status,
				a.last_sync_summary,
				a.last_sync_time
				from MSreplication_subscriptions s with (NOLOCK) 
				left outer join MSsubscription_agents a with (NOLOCK) 
					on (UPPER(s.publisher) = UPPER(a.publisher) and 
						s.publisher_db = a.publisher_db and 
						((s.publication = a.publication and 
						s.independent_agent = 1 and
						a.publication <> N'ALL') or
						(a.publication = N'ALL' and s.independent_agent = 0)) and
						s.subscription_type = a.subscription_type)
				left outer join MSsubscription_properties p with (NOLOCK)
					on (UPPER(s.publisher) = UPPER(p.publisher) and 
						s.publisher_db = p.publisher_db and 
						s.publication = p.publication and
						-- don't use property table for push. 
						s.subscription_type <> 0) 
				where
					((@publisher = N'%') OR (UPPER(s.publisher) = UPPER(@publisher))) AND
					((@publisher_db = N'%') or ( s.publisher_db = @publisher_db)) and
					((s.subscription_type = 0 and @type_value = 0) or
					-- For pull, return both pull and anonymous
					(s.subscription_type <> 0 and @type_value = 1) or
					@type_value = 2) 
		end
		-- Property table does not exists.
		else if exists (select * from sysobjects where name='MSsubscription_agents ') 
		begin
			-- update_mode in MSreplication_subscriptions table is not reliable.
			insert into #MSenumpushsubscriptions select s.publisher, s.publisher_db, s.publication,
				-- Property table does not exists. Say transactional.
				0,
				s.subscription_type,
				s.time, @cur_db, 
				-- NOTE: For Queued case: we will always return 2/3 for the 4/5 case
				-- since we overload update_mode based on queue_type
				case when isnull(a.update_mode,0) = 4 then 2
				when isnull(a.update_mode,0) = 5 then 3
				else isnull(a.update_mode,0)
				end,
				a.last_sync_status,
				a.last_sync_summary,
				a.last_sync_time
				from MSreplication_subscriptions s with (NOLOCK) 
				left outer join MSsubscription_agents a with (NOLOCK) 
					on (UPPER(s.publisher) = UPPER(a.publisher) and 
						s.publisher_db = a.publisher_db and 
						((s.publication = a.publication and 
						s.independent_agent = 1 and
						a.publication <> N'ALL') or
						(a.publication = N'ALL' and s.independent_agent = 0)) and
						s.subscription_type = a.subscription_type)
				where
					((@publisher = N'%') OR (UPPER(s.publisher) = UPPER(@publisher))) AND
					((@publisher_db = N'%') or ( s.publisher_db = @publisher_db)) and
					((s.subscription_type = 0 and @type_value = 0) or
					-- For pull, return both pull and anonymous
					(s.subscription_type <> 0 and @type_value = 1) or
					@type_value = 2) 			
		end
		-- Agents table does not exists.
		else if exists (select * from sysobjects where name='MSsubscription_properties ') 
		begin
			-- update_mode in MSreplication_subscriptions table is not reliable.
			insert into #MSenumpushsubscriptions select s.publisher, s.publisher_db, s.publication,
				case isnull(p.publication_type,0) when 0 then 0 else 1 end,
				s.subscription_type,
				s.time, @cur_db, 
				s.update_mode,
				NULL, --a.last_sync_status,
				NULL, --a.last_sync_summary,
				NULL  --a.last_sync_time	
				from MSreplication_subscriptions s with (NOLOCK) 
				left outer join MSsubscription_properties p with (NOLOCK)
					on (UPPER(s.publisher) = UPPER(p.publisher) and 
						s.publisher_db = p.publisher_db and 
						s.publication = p.publication and
						-- don't use property table for push. 
						s.subscription_type <> 0) 
				where
					((@publisher = N'%') OR (UPPER(s.publisher) = UPPER(@publisher))) AND
					((@publisher_db = N'%') or ( s.publisher_db = @publisher_db)) and
					((s.subscription_type = 0 and @type_value = 0) or
					-- For pull, return both pull and anonymous
					(s.subscription_type <> 0 and @type_value = 1) or
					@type_value = 2) 
		end
		-- Both table does not exists
		else
		begin
			-- update_mode in MSreplication_subscriptions table is not reliable.
			insert into #MSenumpushsubscriptions select s.publisher, s.publisher_db, s.publication,
				0,
				s.subscription_type,
				s.time, @cur_db, 
				s.update_mode,
				NULL, -- a.last_sync_status,
				NULL, -- a.last_sync_summary
				NULL  -- a.last_sync_time
				from MSreplication_subscriptions s with (NOLOCK)
				where
					((@publisher = N'%') OR (UPPER(s.publisher) = UPPER(@publisher))) AND
					((@publisher_db = N'%') or ( s.publisher_db = @publisher_db)) and
					((s.subscription_type = 0 and @type_value = 0) or
					-- For pull, return both pull and anonymous
					(s.subscription_type <> 0 and @type_value = 1) or
					@type_value = 2) 
		end
	
	end
	select * from #MSenumpushsubscriptions
	--drop table #MSenumpushsubscriptions
	return (0)
GO

grant execute on dbo.sp_MSenumsubscriptions to public
go 
exec dbo.sp_MS_marksystemobject sp_MSenumsubscriptions
GO


raiserror('Creating procedure sp_addmergepullsubscription_agent', 0,1)
GO
CREATE PROCEDURE sp_addmergepullsubscription_agent (
	@name							sysname = NULL,
	@publisher						sysname,  						/* Publisher server */
	@publisher_db					sysname,  						/* Publisher database */
	@publication 					sysname,	      				/* Publication name */
	@publisher_security_mode		int = 1,
	@publisher_login				sysname = NULL,
	@publisher_password				sysname = NULL,
	@publisher_encrypted_password	bit = 0,
	@subscriber						sysname = NULL,
	@subscriber_db					sysname = NULL,
	@subscriber_security_mode		int = NULL,						/* 0 standard; 1 integrated */
	@subscriber_login				sysname = NULL,
	@subscriber_password			sysname = NULL,
	@distributor					sysname = @@SERVERNAME,
	@distributor_security_mode		int = 0,						/* 0 standard; 1 integrated */
	@distributor_login				sysname = 'sa',
	@distributor_password			sysname = NULL,
	@encrypted_password				bit = 0,			/* distributor password encrypted or not */
    @frequency_type  				int = NULL,
    @frequency_interval 			int = NULL,				
    @frequency_relative_interval 	int = NULL, 
    @frequency_recurrence_factor 	int = NULL, 
	@frequency_subday 				int = NULL,
    @frequency_subday_interval 		int = NULL,	   
    @active_start_time_of_day 		int = NULL, 
    @active_end_time_of_day 		int = NULL,         
    @active_start_date 				int = NULL, 
    @active_end_date 				int = NULL,
	@optional_command_line 			nvarchar(255) = '',			/* Optional command line arguments */
    @merge_jobid					binary(16) = NULL OUTPUT,
    @enabled_for_syncmgr 			nvarchar(5) = 'false', /* Enabled for SYNCMGR: true or false */
	@ftp_address 					sysname = NULL,
	@ftp_port 						int = NULL,
	@ftp_login 						sysname = NULL,
	@ftp_password 					sysname = NULL,
    @alt_snapshot_folder  			nvarchar(255) = NULL,
    @working_directory    			nvarchar(255) = NULL,
    @use_ftp              			nvarchar(5) = 'false',
	@reserved 						nvarchar(100) = N'', -- Not default to null because null problems in conditional expressions.
	@use_interactive_resolver   	nvarchar(5) = 'false',
    @offloadagent         			nvarchar(5) = 'false',
    @offloadserver        			sysname = null,
	-- Used by DMO scripting
	@job_name						sysname = NULL,
    @dynamic_snapshot_location      nvarchar(260) = NULL
    ) AS

    SET NOCOUNT ON

    /*
    ** Declarations.
    */
    declare @command 				nvarchar(4000)
    declare @retcode 				int
	declare @database				sysname
	declare @repid					uniqueidentifier
	declare @pubid					uniqueidentifier
    declare @subscriber_srvid		int 
    declare @publisher_srvid		int 
	declare @name_id				nvarchar(50)
	declare @subscriber_typeid		int
	declare @subscription_type_id	int
	declare @category_name			sysname
	declare @platform_nt			binary
	DECLARE @subscriber_enc_password 	nvarchar(524)
	DECLARE @publisher_enc_password 	nvarchar(524)
	DECLARE @distributor_enc_password 	nvarchar(524)
    DECLARE @use_ftp_bit            	bit
	declare @use_interactive_bit		bit
    DECLARE @offload_agent_bit      	bit

	select @platform_nt = 0x1

    SELECT @use_ftp_bit = 0

	-- For attach check
	if exists (select * from sysobjects where name = 'MSrepl_restore_stage')
	begin
		raiserror(21211, 16, -1)
		return 1
	end

	-- Set null @optional_command_line to empty string to avoid string concat problem
	if @optional_command_line is null
		set @optional_command_line = ''
        else
                set @optional_command_line = N' ' + LTRIM( RTRIM(@optional_command_line) ) + N' '

	IF @distributor_password = N''
		select @distributor_password = NULL

	IF @publisher_password = N''
		select @publisher_password = NULL

	IF @ftp_password = N''
		select @ftp_password = NULL

	/*
	** Parameter Check: @subscriber and @subscriber_db
	*/

	if @subscriber IS NULL or rtrim(@subscriber) = ''
		SELECT @subscriber = @@SERVERNAME

	if @subscriber_db IS NULL or rtrim(@subscriber_db) = ''
		SELECT @subscriber_db = DB_NAME()
	
	EXECUTE @retcode = dbo.sp_validname @subscriber
    IF @@ERROR <> 0 OR @retcode <> 0
       RETURN (1)
	
    EXECUTE @retcode = dbo.sp_validname @subscriber_db
    IF @@ERROR <> 0 OR @retcode <> 0
       RETURN (1)

	-- Parameter check: @subscriber_security_mode	
	if @subscriber_security_mode is null
	begin
		if ( platform() & @platform_nt ) = @platform_nt
			select @subscriber_security_mode = 1
		else
			select @subscriber_security_mode = 0
	end	

    /* 
    ** Parameter check: @alt_snapshot_folder 
    ** @alt_snapshot_folder and @use_ftp are mutually exclusive    
    ** @dynamic_snapshot_location is incompatible with both 
    ** @alt_snapshot_folder and @use_ftp
    */

    IF @alt_snapshot_folder <> N'' AND @alt_snapshot_folder IS NOT NULL
    BEGIN
        IF LOWER(@use_ftp collate SQL_Latin1_General_CP1_CS_AS) = N'true'
        BEGIN
            RAISERROR(21146, 16, -1)
            RETURN (1)
        END
        IF @dynamic_snapshot_location <> N'' AND @dynamic_snapshot_location IS NOT NULL
        BEGIN
            RAISERROR(21341, 16, -1)
            RETURN (1)
        END
    END

   	/*
    ** Parameter Check: @use_interactive_resolver  
    */
    if LOWER(@use_interactive_resolver collate SQL_Latin1_General_CP1_CS_AS) NOT IN ('true', 'false')
        BEGIN
            RAISERROR (14148, 16, -1, '@use_interactive_resolver')
            RETURN (1)
        END
    if LOWER(@use_interactive_resolver collate SQL_Latin1_General_CP1_CS_AS) = 'true'
        set @use_interactive_bit = 1
    else 
        set @use_interactive_bit = 0

    /* 
    ** Parameter check: @use_ftp
    ** Must be 'true' or 'false'
    */
    IF LOWER(@use_ftp collate SQL_Latin1_General_CP1_CS_AS) NOT IN ('true', 'false')
    BEGIN
        RAISERROR (14148, 16, -1, '@use_ftp')
        RETURN (1)
    END
    
    IF LOWER(@use_ftp collate SQL_Latin1_General_CP1_CS_AS) = 'true'
    BEGIN
        /*
        ** Ftp file transfer is incompatible with @dynamic_snapshot_location
        */
        IF @dynamic_snapshot_location <> N'' AND @dynamic_snapshot_location IS NOT NULL
        BEGIN
            RAISERROR (21342, 16, -1)
            RETURN (1)
        END

        SELECT @use_ftp_bit = 1

    END
    ELSE
    BEGIN
        SELECT @use_ftp_bit = 0
    END

    /*
    ** Parameter Check: @offloadserver
    ** If @offloadagent = 'true' then @offloadserver cannot be null
    */
    SELECT @offloadagent = LOWER(@offloadagent collate SQL_Latin1_General_CP1_CS_AS)
    IF @offloadagent NOT IN ('true', 'false')
    BEGIN
        RAISERROR (14148, 16, -1, '@offloadagent')
        RETURN (1)
    END

    IF @offloadagent = 'true'
    BEGIN
        SELECT @offload_agent_bit = 1
    END
    ELSE
    BEGIN
        SELECT @offload_agent_bit = 0
    END

    IF @offload_agent_bit = 1 AND (@offloadserver IS NULL or
                               @offloadserver = N'')
    BEGIN
        RAISERROR(21215, 16, -1)
        RETURN (1)
    END

    IF UPPER(@offloadserver) = UPPER(@@SERVERNAME) AND
       @offload_agent_bit = 1
    BEGIN
        RAISERROR(21227, 16, -1)
        RETURN (1)
    END

    EXEC @retcode = sp_MSreplcheckoffloadserver @offloadserver
    IF @retcode <> 0 OR @@ERROR <> 0
        RETURN (1)

    -- Make sure that there are no leading or trailing blanks
    -- in the dynamic snapshot location
    select @dynamic_snapshot_location = rtrim(ltrim(@dynamic_snapshot_location))

	if ( ( platform() & @platform_nt ) <> @platform_nt and @subscriber_security_mode = 1)
	begin
		RAISERROR(21038, 16, -1)
		RETURN (1)
	end

	select @subscription_type_id = 1 /* pull agent only */
	/*
	** Set Default schedule values if NULL is specified
	** The default are not implemented during parmeter defintion because this procedure
	** is can be called from sp_addmergesubscription.
	*/
	if @frequency_type is NULL
		set @frequency_type = 4		/* Daily */
	if @frequency_interval is NULL
		set @frequency_interval = 1
	if @frequency_relative_interval is NULL
		set @frequency_relative_interval = 1
	if @frequency_recurrence_factor is NULL
		set @frequency_recurrence_factor = 0
	if @frequency_subday is NULL
		set @frequency_subday = 8	/* Hour */
    if @frequency_subday_interval is NULL
		set @frequency_subday_interval = 1
    if @active_start_time_of_day is NULL
		set @active_start_time_of_day = 0
    if @active_end_time_of_day is NULL
		set @active_end_time_of_day = 235959
    if @active_start_date is NULL
		set @active_start_date = 0
    if @active_end_date is NULL
		set @active_end_date = 99991231

	select @subscriber_srvid = srvid from master..sysservers where UPPER(srvname) = UPPER(@@SERVERNAME) collate database_default
    IF @subscriber_srvid IS NULL
		BEGIN
		   RAISERROR (14010, 16, -1)
		   RETURN (1)     
		END
			
	select @pubid = pubid from sysmergepublications 
		where name = @publication and UPPER(publisher)=UPPER(@publisher) and publisher_db=@publisher_db
	IF @pubid is NULL
		begin
			RAISERROR (20026, 16, -1, @publication)
			RETURN (1)
		end
			
	select @repid = subid, @subscriber_typeid = subscriber_type from sysmergesubscriptions
			where srvid = @subscriber_srvid and pubid<>subid and pubid = @pubid and db_name = @subscriber_db

	if @subscriber_typeid = 3 set @subscription_type_id = 2 /* This corresponds to anonymous subscription */

	if (@subscription_type_id <> 0)
	begin
		if (@subscriber_security_mode = 0) and (@subscriber_login IS NULL or rtrim(@subscriber_login) = '')
		begin
			raiserror(3217, 16, -1, '@subscriber_login')
			return (1)
		end
	end

	if (@distributor_security_mode = 0) and (@distributor_login IS NULL or rtrim(@distributor_login) = '')
	begin
		raiserror(3217, 16, -1, '@distributor_login')
		return (1)
	end

	if (@publisher_security_mode = 0) and (@publisher_login IS NULL or rtrim(@publisher_login) = '')
	begin
		raiserror(3217, 16, -1, '@publisher_login')
		return (1)
	end

	IF NOT EXISTS (select * from sysobjects where name = 'MSsubscription_properties' and type = 'U')
	begin
		raiserror(14027, 16, -1, 'The subscription properties table ''MSsubscription_properties''')
		return (1)
	end
	
	declare @job_existing bit
	-- For scripting
	if @job_name is null
		select @job_existing = 0
	else
	begin
		select @job_existing = 1
		select @name = @job_name
	end

	/*
    ** Construct unique task name if @name = NULL
	*/
	IF @name IS NULL
		begin
			 SELECT @name = CONVERT(nvarchar(23),@publisher ) + '-' + CONVERT(nvarchar(23),@publisher_db) + '-' + 
						CONVERT(nvarchar(23),@publication) + '-' + CONVERT(nvarchar(23),@subscriber) + '-' +
						CONVERT(nvarchar(23), @subscriber_db) + '- 0'
		end
	else
	begin
		/*
		** validate name
		*/
		exec @retcode = dbo.sp_MSreplcheck_name @name
		if @@ERROR <> 0 or @retcode <> 0
			return(1)

	end

	-- Get property values.
	if @reserved = 'no_change_to_properties'
	begin
		-- Get the distributor value. It will be used in agent command line.
		select @distributor = distributor, 
			@enabled_for_syncmgr = case enabled_for_syncmgr
				when 0 then 'false'
				when 1 then	'true'
				end
			from MSsubscription_properties where
			UPPER(publisher) = UPPER(@publisher)
			and publisher_db =  @publisher_db
			and publication = @publication
	end

	begin tran
	save tran sp_addpullsub_agent

	if @job_existing = 0
	begin
		/* Construct task command */
		select @command = '-Publisher ' + QUOTENAME(@publisher) + ' -PublisherDB ' + QUOTENAME(@publisher_db) + ' '
		select @command = @command + '-Publication ' + QUOTENAME(@publication) + ' '
		select @command = @command + '-Subscriber ' + QUOTENAME(@@SERVERNAME)  + ' '
		select @command = @command + '-SubscriberDB ' + QUOTENAME(db_name()) + ' '
		SELECT @command = @command + '-SubscriptionType ' + convert(nvarchar(10), @subscription_type_id)  + ' '
		
		select @command = @command + '-SubscriberSecurityMode ' + 
			convert(nvarchar(10),@subscriber_security_mode) + ' '
		if @subscriber_login is not NULL
			select @command = @command + '-SubscriberLogin ' + quotename(@subscriber_login) + ' '
		if @subscriber_password is not NULL
		begin
			set @subscriber_enc_password = @subscriber_password
			exec @retcode = master.dbo.xp_repl_encrypt @subscriber_enc_password OUTPUT
			select @command = @command + '-SubscriberEncryptedPassword ' + quotename(@subscriber_enc_password) + ' '
		end
		
		select @command = @command + @optional_command_line
		select @command = @command + ' -Distributor ' + QUOTENAME(@distributor) + ' '

		if @offload_agent_bit = 1
			select @command = @command + N'-Offload ' + @offloadserver + N' '
		
        select @dynamic_snapshot_location = rtrim(ltrim(@dynamic_snapshot_location))
        if @dynamic_snapshot_location is not null and 
           @dynamic_snapshot_location <> N''
            select @command = @command + N'-DynamicSnapshotLocation ' + fn_replquotename(@dynamic_snapshot_location) collate database_default + N' '

		select @database = db_name()

		-- Get Merge category name (assumes category_id = 14)
		select @category_name = name FROM msdb.dbo.syscategories where category_id = 14

		EXEC @retcode = dbo.sp_MSadd_repl_job
				@name = @name,
				@subsystem = 'Merge',
				@server = @@SERVERNAME,
				@databasename = @database,
				@enabled = 1,
				@freqtype = @frequency_type,
				@freqinterval = @frequency_interval,
				@freqsubtype = @frequency_subday,
				@freqsubinterval = @frequency_subday_interval,
				@freqrelativeinterval = @frequency_relative_interval,
				@freqrecurrencefactor = @frequency_recurrence_factor,
				@activestartdate = @active_start_date,
				@activeenddate = @active_end_date,
				@activestarttimeofday = @active_start_time_of_day,
				@activeendtimeofday = @active_end_time_of_day,
				@command = @command,
				@retryattempts = 10,
				@retrydelay = 1,
				@category_name = @category_name,
				@job_id = @merge_jobid OUTPUT

		if @@ERROR <> 0 or @retcode <> 0 goto Rollback_tran
	end
	else
	begin
		select @merge_jobid = job_id from msdb..sysjobs_view where 
			name = @name collate database_default and
			UPPER(originating_server) = UPPER(CONVERT(sysname, SERVERPROPERTY('ServerName')))
		if @merge_jobid IS NULL
		begin
			-- Message from msdb.dbo.sp_verify_job_identifiers
			RAISERROR(14262, -1, -1, 'Job', @name)          
			goto Rollback_tran
		end
	end


	if @reserved <> 'attach_subscription' and (@subscription_type_id = 1) OR (@subscription_type_id = 2)
	begin
		IF NOT EXISTS (select * from MSsubscription_properties 
            where UPPER(publisher) = UPPER(@publisher)
			and publisher_db =  @publisher_db
			and publication = @publication) 
		BEGIN
			
			-- Copy the passwords to new value before attempting to encrypt
			set @distributor_enc_password = @distributor_password
			set @publisher_enc_password = @publisher_password

			IF (@encrypted_password = 0)
			-- Encrypt the password
			BEGIN
				EXEC @retcode = master.dbo.xp_repl_encrypt @distributor_enc_password OUTPUT
				IF @@error <> 0 OR @retcode <> 0 goto Rollback_tran
			END
	
			IF (@publisher_encrypted_password = 0)
			-- Encrypt the password
			BEGIN
				EXEC @retcode = master.dbo.xp_repl_encrypt @publisher_enc_password OUTPUT
				IF @@error <> 0 OR @retcode <> 0 goto Rollback_tran
			END
	
			INSERT INTO MSsubscription_properties 
			(publisher, publisher_db, publication, publication_type, 
			 publisher_login,publisher_password, publisher_security_mode, 
			 distributor, distributor_login, distributor_password, 
			 distributor_security_mode, ftp_address, ftp_port, ftp_login, 
			 ftp_password, alt_snapshot_folder, working_directory, use_ftp,
             offload_agent, offload_server, dynamic_snapshot_location)
			values 
			(@publisher, @publisher_db, @publication, 2, @publisher_login, 
			 @publisher_enc_password, @publisher_security_mode, @distributor, 
			 @distributor_login, @distributor_enc_password, 
			 @distributor_security_mode, null, null, null,
			 null, @alt_snapshot_folder, @working_directory, @use_ftp_bit,
             @offload_agent_bit, @offloadserver, @dynamic_snapshot_location)
		END
	end

		
	/* Update merge joibd for this pull subscription */
	UPDATE MSmerge_replinfo set merge_jobid = @merge_jobid WHERE repid = @repid

	/* Update the distributor column in sysmergesubscriptions */
	UPDATE sysmergesubscriptions set 
			use_interactive_resolver = @use_interactive_bit,
			distributor = @distributor 
				WHERE subid = @repid
	
	/* Conditional support for MobileSync */
    if LOWER(@enabled_for_syncmgr collate SQL_Latin1_General_CP1_CS_AS) = 'true'
    BEGIN
		/* Call sp_MSregistersubscription so that the subscription can be synchronized via MobileSync etc. */
		exec @retcode = dbo.sp_MSregistersubscription @replication_type = 2,
									@publisher = @publisher,
									@publisher_security_mode = @publisher_security_mode,
									@publisher_login = @publisher_login,
									@publisher_password = @publisher_password,
									@publisher_db = @publisher_db,
									@publication = @publication,
								    @subscriber = @subscriber,
								    @subscriber_db = @subscriber_db,
									@subscriber_security_mode = @subscriber_security_mode,
									@subscriber_login = @subscriber_login,
									@subscriber_password = @subscriber_password,
									@distributor = @distributor,
									@distributor_security_mode = @distributor_security_mode,
									@distributor_login = @distributor_login,
									@distributor_password = @distributor_password,
								    @subscription_id = @repid,
									@subscription_type = @subscription_type_id,
									@use_interactive_resolver = @use_interactive_bit

		IF @@ERROR <> 0 or @retcode <> 0 goto Rollback_tran
	END

commit tran
	RETURN (0)
Rollback_tran:
	rollback tran sp_addpullsub_agent
	commit tran
	return(1)
GO

exec dbo.sp_MS_marksystemobject sp_addmergepullsubscription_agent
go

grant exec on dbo.sp_addmergepullsubscription_agent to public
go

--------------------------------------------------------------------------------
--. sp_MSget_load_hint
--------------------------------------------------------------------------------
if exists (select * from sysobjects
    where type = 'P '
            and name = 'sp_MSget_load_hint')
    drop procedure sp_MSget_load_hint

raiserror('Creating procedure sp_MSget_load_hint', 0,1)
go
create procedure sp_MSget_load_hint @objname sysname, @type int
as
declare @objid int
declare @tabname sysname
declare @tabid int
declare @hint   nvarchar(2048)
declare @i int
declare @thiskey sysname
declare @indid smallint
declare @indstat int

select @objid = object_id( @objname )

if exists ( select * from sysobjects where id = @objid and type = 'V' )
begin
	select @tabid = depid from sysdepends where id = object_id( @objname )
	select @tabname = object_name( @tabid )
	
	select @indid = indid, @indstat = status 
	    from sysindexes where id = @tabid and ( status & @type ) = @type
	if @indid is not null
	begin
		create table #colnames ( idxcolname sysname collate database_default)

		select @thiskey = index_col( @tabname, @indid, 1 )
		select @i = 2
		while (@thiskey is not null )
		begin
			insert into #colnames( idxcolname ) values( @thiskey )
			select @thiskey = index_col(@tabname, @indid, @i)
			select @i = @i + 1
		end
		if exists ( select idxcolname from #colnames 
                     where idxcolname not in
	                    (select name from syscolumns where id = object_id( @objname ) ) )
		begin
			select @tabid = 0
		end	
		drop table #colnames
	end
	else
	begin
		select @tabid = 0
	end
end
else 
begin
	select @tabname = @objname
	select @tabid = object_id( @objname )

	select @indid = indid, @indstat = status 
	    from sysindexes where id = @tabid and ( status & @type ) = @type
	if @indid is null
	begin
		select @tabid = 0
	end
end

-- Check for computed columns in chosen index. If computed columns exist,
-- don't return a load hint.
if @indid is not null
begin
    select @i = 1
    select @thiskey = index_col( @tabname, @indid, @i )
    while @thiskey is not null
    begin
        if isnull( columnproperty( @tabid, @thiskey, 'IsComputed' ), 0 ) = 1
        begin
            select @indid = null,
                   @tabid = 0
            break
        end
        select @i = @i + 1
        select @thiskey = index_col( @tabname, @indid, @i )
    end
end

if @tabid <> 0
begin
	select @hint = 'ORDER( '+QUOTENAME(index_col( @tabname, @indid, 1 )) collate database_default
	select @thiskey = index_col( @tabname, @indid, 2 ) 
	select @i = 3
	while (@thiskey is not null )
	begin
		select @hint = @hint + ',' + QUOTENAME(@thiskey) collate database_default
		select @thiskey = index_col(@tabname, @indid, @i)
		select @i = @i + 1
	end

	select @hint = @hint + ' ASC)'

	select @hint, @indstat
end
GO

EXEC dbo.sp_MS_marksystemobject sp_MSget_load_hint
grant execute on dbo.sp_MSget_load_hint to public

--------------------------------------------------------------------------------
--. sp_MSdroparticleconstraints
--------------------------------------------------------------------------------
if exists (select * from sysobjects
		where type = 'P '
			and name = 'sp_MSadd_repl_job')
	drop procedure sp_MSadd_repl_job

raiserror('Creating procedure sp_MSadd_repl_job',0,1)
go

CREATE PROCEDURE sp_MSadd_repl_job
  @name                   nvarchar(200),
  @subsystem              nvarchar(60)  = 'TSQL',
  @server                 sysname  = NULL,
  @username               sysname  = NULL,
  @databasename           sysname  = NULL,
  @enabled                TINYINT      = 0,
  @freqtype               INT          = 2, -- 2 means OnDemand
  @freqinterval           INT          = 1,
  @freqsubtype            INT          = 1,
  @freqsubinterval        INT          = 1,
  @freqrelativeinterval   INT          = 1,
  @freqrecurrencefactor   INT          = 1,
  @activestartdate        INT          = 0,
  @activeenddate          INT          = 0,
  @activestarttimeofday   INT          = 0,
  @activeendtimeofday     INT          = 0,
  @nextrundate            INT          = 0,
  @nextruntime            INT          = 0,
  @runpriority            INT          = 0,
  @emailoperatorname      nvarchar(100) = NULL,
  @retryattempts          INT          = NULL,
  @retrydelay             INT          = 0,
  @command                nvarchar(4000)= NULL,
  @loghistcompletionlevel INT          = 2,
  @emailcompletionlevel   INT          = 0,
  @description            nvarchar(255) = NULL,
  @tagadditionalinfo      nvarchar(96)  = NULL,
  @tagobjectid            INT          = NULL,
  @tagobjecttype          INT          = NULL,
  @cmdexecsuccesscode     INT          = 0,
  @category_name          sysname = NULL, -- New for 7.0
  @failure_detection      BIT           = 0,
  @agent_id               INT           = NULL,
  @job_id BINARY(16) = NULL OUTPUT
AS
BEGIN
  DECLARE   @retval INT
  declare   @step_id int
  declare   @step_name nvarchar(100)
  declare   @step_command nvarchar(1024)
  declare   @on_fail_action tinyint
  declare   @on_success_action tinyint
  declare   @schedule_name nvarchar(100)
  declare   @comments nvarchar(100)

  SET NOCOUNT ON

  SELECT @retval = 1 -- 0 means success, 1 means failure
  set @step_id = 1
  set @on_fail_action = 2   -- Return failure
  set @on_success_action = 1    -- Return success
  set @step_command = NULL

  /*
  ** Set default retries to every minute for 10 minutes.
  **
  */
  if @retryattempts = NULL and @retrydelay = 0
  begin
     select @retryattempts = 10
     select @retrydelay = 1
  end

  BEGIN TRANSACTION
  save tran sp_MSadd_repl_job

    -- Drop the job if it already exists
    IF EXISTS (SELECT * FROM msdb..sysjobs_view WHERE name = @name collate database_default)
    begin
        exec @retval = msdb.dbo.sp_delete_job @job_name=@name
        if @@ERROR<>0 or @retval<>0
            goto UNDO
    end

    -- Add the job
    EXECUTE @retval = msdb.dbo.sp_add_job
      @job_name                   = @name,
      @enabled                    = @enabled,
      @start_step_id              = 1,
      @description                = @description,
      @category_name              = @category_name,
      @notify_level_eventlog      = @loghistcompletionlevel,
      @notify_level_email         = @emailcompletionlevel,
      @notify_email_operator_name = @emailoperatorname,
      @job_id = @job_id OUTPUT

    IF (@retval <> 0)
    BEGIN
        GOTO UNDO
    END

    -- Add startup message step
    if @failure_detection = 1
    begin

        select @step_name = 
            case UPPER(@subsystem collate SQL_Latin1_General_CP1_CS_AS)
                when N'SNAPSHOT' then formatmessage(21410)
                when N'LOGREADER' then formatmessage(20528)
                when N'DISTRIBUTION' then formatmessage(21411)
                when N'MERGE' then formatmessage(21412)
                when N'QUEUEREADER' then formatmessage(21422)
            end 
        select @comments = formatmessage(20529)

        -- Construct command based on subsystem type
        select @step_command =
            case UPPER(@subsystem collate SQL_Latin1_General_CP1_CS_AS) 
                WHEN 'SNAPSHOT' THEN
                N'sp_MSadd_snapshot_history @perfmon_increment = 0,  @agent_id = ' + 
                    convert (nvarchar(10), @agent_id) + N', @runstatus = 1,  
                    @comments = ''' + @comments + ''''
                WHEN 'LOGREADER' THEN
                N'sp_MSadd_logreader_history @perfmon_increment = 0, @agent_id = ' + 
                    convert (nvarchar(10), @agent_id) + N', @runstatus = 1, 
                    @comments = ''' + @comments + ''''
                WHEN 'DISTRIBUTION' THEN
                N'sp_MSadd_distribution_history @perfmon_increment = 0, @agent_id = ' + 
                    convert (nvarchar(10), @agent_id) + N', @runstatus = 1,  
                    @comments = ''' + @comments + ''''
                WHEN 'MERGE' THEN
                N'sp_MSadd_merge_history @perfmon_increment = 0, @agent_id = ' + 
                    convert (nvarchar(10),@agent_id) + N', @runstatus = 1,  
                    @comments = ''' + @comments + ''''
                WHEN 'QUEUEREADER' THEN
                N'sp_MSadd_qreader_history @perfmon_increment = 0, @agent_id = ' + 
                    convert (nvarchar(10), @agent_id) + N', @runstatus = 1,  
                    @comments = ''' + @comments + ''''                  
            end
    
        -- Add the job step
        EXECUTE @retval = msdb.dbo.sp_add_jobstep
          @job_id                = @job_id,
          @step_id               = @step_id,
          @step_name             = @step_name,
          @command               = @step_command,
          @cmdexec_success_code  = @cmdexecsuccesscode,
          @on_success_action     = 3,   -- Goto next step
          @on_fail_action        = 3,   -- Goto next step
          @server                = @server,
          @database_name         = @databasename,
          @database_user_name    = @username,
          @os_run_priority       = @runpriority

        IF (@retval <> 0)
        BEGIN
            GOTO UNDO
        END

        set @step_id = @step_id + 1
        set @on_fail_action = 3         -- Goto next step
    end

    -- Add the job step
    select @step_name = formatmessage(20530)
    EXECUTE @retval = msdb.dbo.sp_add_jobstep
      @job_id                = @job_id,
      @step_id               = @step_id,
      @step_name             = @step_name,
      @subsystem             = @subsystem,
      @command               = @command,
      @cmdexec_success_code  = @cmdexecsuccesscode,
      @on_success_action     = @on_success_action,
      @on_fail_action        = @on_fail_action,
      @server                = @server,
      @database_name         = @databasename,
      @database_user_name    = @username,
      @retry_attempts        = @retryattempts,
      @retry_interval        = @retrydelay,
      @os_run_priority       = @runpriority

    IF (@retval <> 0)
    BEGIN
        GOTO UNDO
    END

    -- Add failure message step
    if @failure_detection = 1
    begin

        set @step_id = @step_id + 1

        select @step_name = formatmessage(20531)

        -- Construct command
        select @step_command = N'sp_MSdetect_nonlogged_shutdown @subsystem = ''' + @subsystem +  N''', @agent_id = ' + convert (nvarchar(10),   @agent_id) 

        -- Add the job step
        EXECUTE @retval = msdb.dbo.sp_add_jobstep
          @job_id                = @job_id,
          @step_id               = @step_id,
          @step_name             = @step_name,
          @command               = @step_command,
          @cmdexec_success_code  = @cmdexecsuccesscode,
          @on_success_action     = 2,                   -- Always quit with failure
          @server                = @server,
          @database_name         = @databasename,
          @database_user_name    = @username,
          @os_run_priority       = @runpriority

        IF (@retval <> 0)
        BEGIN
            GOTO UNDO
        END
    end

    -- Add the job schedule
    IF (@activestartdate = 0)
      SELECT @activestartdate = NULL
    IF (@activeenddate = 0)
      SELECT @activeenddate = NULL
    
    -- But if @activeenddate is NOT NULL, then @activestartdate cannot be allowed to be NULL either.  Set it to today's date converted to the int format used yyyymmdd

    IF (@activeenddate IS NOT NULL AND @activestartdate IS NULL)
    SELECT @activestartdate=DATEPART(YYYY,getdate()) * 10000 + DATEPART(MM,getdate()) * 100 + DATEPART(DD,getdate())

    -- But never let startdate be > end date
    IF (@activestartdate > @activeenddate)
    SELECT @activestartdate=@activeenddate

    IF (@activestarttimeofday = 0)
      SELECT @activestarttimeofday = NULL
    IF (@activeendtimeofday = 0)
      SELECT @activeendtimeofday = NULL
    IF (@freqtype <> 0x2) -- OnDemand tasks simply have no schedule in 7.0
    BEGIN
      select @schedule_name = formatmessage(20532)

      EXECUTE @retval = msdb.dbo.sp_add_jobschedule
        @job_id                 = @job_id,
        @name                   = @schedule_name,
        @enabled                = 1,
        @freq_type              = @freqtype,
        @freq_interval          = @freqinterval,
        @freq_subday_type       = @freqsubtype,
        @freq_subday_interval   = @freqsubinterval,
        @freq_relative_interval = @freqrelativeinterval,
        @freq_recurrence_factor = @freqrecurrencefactor,
        @active_start_date      = @activestartdate,
        @active_end_date        = @activeenddate,
        @active_start_time      = @activestarttimeofday,
        @active_end_time        = @activeendtimeofday

      IF (@retval <> 0)
      BEGIN
        GOTO UNDO
      END
    END

    -- And finally, add the job server
    EXECUTE @retval = msdb.dbo.sp_add_jobserver @job_id = @job_id, @server_name  = '(local)'

    IF (@retval <> 0)
    BEGIN
      GOTO UNDO
    END

  COMMIT TRANSACTION

  -- If this is an autostart LogReader or Distribution or Merge job, add the [new] '-Continuous' paramter to the command
  IF (@freqtype = 0x40) AND ((UPPER(@subsystem collate SQL_Latin1_General_CP1_CS_AS) = 'LOGREADER') OR (UPPER(@subsystem collate SQL_Latin1_General_CP1_CS_AS) = 'DISTRIBUTION') OR 
            (UPPER(@subsystem collate SQL_Latin1_General_CP1_CS_AS) = 'MERGE') OR (UPPER(@subsystem collate SQL_Latin1_General_CP1_CS_AS) = 'QUEUEREADER'))
  BEGIN
    UPDATE msdb.dbo.sysjobsteps
    SET command = command + ' -Continuous'
    WHERE (job_id = @job_id)
      AND ((@failure_detection = 0 and step_id = 1) or (@failure_detection = 1 and step_id = 2))
  END  

  -- If this is an autostart job, start it now (for backwards compatibility with 6.x SQLExecutive behaviour)
  IF (@freqtype = 0x40)
    EXECUTE msdb.dbo.sp_start_job @job_id = @job_id, @error_flag = 0

  RETURN(0)

UNDO:
    rollback tran sp_MSadd_repl_job
    commit tran
    return(1)

END
go
exec sp_MS_marksystemobject sp_MSadd_repl_job

--------------------------------------------------------------------------------
--. sp_MSdroparticleconstraints
--------------------------------------------------------------------------------
if exists ( select * from sysobjects
    where type = 'P ' and name = 'sp_MSdroparticleconstraints' )
    drop procedure sp_MSdroparticleconstraints

go
--
-- Name: sp_MSdroparticleconstraints
--
-- Description: This procedure is used by the Distribution Agent to purge all
--              the existing check, PK, UK, and FK constraints on a table
--              article at the Subscriber.
--
-- Parameters:  @destination_object sysname (mandatory)
--              @destination_owner sysname (mandatory)
-- 
-- Returns: 0 - succeeded
--          1 - failed
-- 
-- Security: Procedural security check is done inside this procedure
--           to make sure that the caller is either a member of the db_owner
--           role of the subscriber database or a member of the sysadmin role
--           of the subscription server 
--
print ''
print 'Creating procedure sp_MSdroparticleconstraints'
go
create procedure dbo.sp_MSdroparticleconstraints (
    @destination_object sysname,
    @destination_owner sysname
    )
as
begin
    set nocount on
    declare @retcode      int,
            @objid        int,
            @constid      int,
            @drop_command nvarchar(4000),
            @qualified_tablename nvarchar(540),
            @publish_bit  int,
            @mergepublish_bit int

    
    select @retcode             = 0,
           @objid               = null,
           @constid             = null,
           @drop_command        = null,
           @qualified_tablename = null,
           @publish_bit         = 1,
           @mergepublish_bit    = 128

    -- Security check
    exec @retcode = sp_MSreplcheck_subscribe
    if @retcode<>0 or @@error<>0
        return 1

    -- Get object id of the target table
    select @objid = id 
      from sysobjects
     where name = @destination_object
       and (user_name(uid) = @destination_owner 
            or @destination_owner is null 
            or @destination_owner = N'')

    -- If the object is not at the subscriber, there isn't anything we 
    -- can(or need to)  do
    if @objid is null 
        return 0

    select @qualified_tablename = 
            N'['+replace(@destination_object,N']',N']]')+N']'

    if @destination_owner is not null and @destination_owner<>N''
    begin
        select @qualified_tablename = 
            N'['+replace(@destination_owner,N']',N']]')+N'].'+@qualified_tablename
    end

    -- Skip constraint dropping for republished article
    if exists (select * 
                 from sysobjects 
                where id = @objid
                  and ((replinfo & @publish_bit <> 0) or
                       (replinfo & @mergepublish_bit <> 0)))
    begin
        return 0
    end

    declare hConst cursor local fast_forward for
     select constid 
       from sysconstraints 
      where id = @objid
      order by convert(int, objectproperty(constid,'IsForeignKey')) desc
    if @@error<>0
        return 1

    open hConst
    if @@error<>0
        return 1
    
    fetch hConst into @constid 
    while (@@fetch_status<>-1)
    begin
    
        if objectproperty(@constid,N'IsUniqueCnst') = 1 or
           objectproperty(@constid,N'IsPrimaryKey') = 1 or
           objectproperty(@constid,N'IsCheckCnst') = 1 or
           objectproperty(@constid,N'IsForeignKey') = 1
        begin
            select @drop_command = 
                N'alter table '+@qualified_tablename+' drop constraint '+object_name(@constid)
            exec(@drop_command)
            if @@error <> 0
                return 1
        end
        fetch hConst into @constid        
    end
    close hConst
    deallocate hConst

    return @retcode

end
go
exec sp_MS_marksystemobject sp_MSdroparticleconstraints
grant execute on sp_MSdroparticleconstraints to public 

--------------------------------------------------------------------------------
--. sp_MScopysnapshot
--------------------------------------------------------------------------------
if exists (select * from sysobjects
     where type = 'P '
            and name = 'sp_MSagent_access_check')
     drop procedure sp_MSagent_access_check

raiserror('Creating procedure sp_MSagent_access_check',0,1)
go
CREATE PROCEDURE sp_MSagent_access_check (
    @job_id         VARBINARY(16),
    @agent_type     sysname = NULL -- 'distribution' or 'merge', case insensitive
) AS

    DECLARE @retcode int
    DECLARE @count   int

    IF @agent_type IS NOT NULL
    BEGIN
        IF LOWER(@agent_type collate SQL_Latin1_General_CP1_CS_AS) NOT IN (N'distribution', N'merge')
        BEGIN
            RAISERROR(21170, 16, -1)
            RETURN (1)
        END
    END

    SELECT @retcode = 0
    -- Create a list of owners of the subscriptions depending on the given 
    -- agent 
    CREATE TABLE #sub_owner_list (owner_name sysname collate database_default)

    -- Try querying the Transactional subscriptions for the owner 
    IF @agent_type IS NULL OR LOWER(@agent_type collate SQL_Latin1_General_CP1_CS_AS) = N'distribution'
    BEGIN

        IF EXISTS (SELECT * 
                     FROM sysobjects 
                    WHERE type in ('U', 'S') AND name = N'syssubscriptions')
        BEGIN
            INSERT INTO #sub_owner_list 
            SELECT DISTINCT login_name 
              FROM dbo.syssubscriptions 
             WHERE distribution_jobid = @job_id 
        END

        IF NOT EXISTS (SELECT * FROM #sub_owner_list) AND 
           @agent_type IS NOT NULL
        BEGIN
            RAISERROR(21167, 16, -1, 'Distribution')
            SELECT @retcode = 1
            GOTO FAILURE
        END 
    END

    IF (@agent_type IS NULL AND NOT EXISTS (SELECT * FROM #sub_owner_list)) OR
       LOWER(@agent_type collate SQL_Latin1_General_CP1_CS_AS) = N'merge' 
    BEGIN
        
        SELECT @count = COUNT(*)
          FROM sysobjects
         WHERE name IN (N'sysmergesubscriptions', N'MSmerge_replinfo')
        
        IF @count = 2        
        BEGIN
            INSERT INTO #sub_owner_list 
            SELECT DISTINCT sms.login_name 
              FROM dbo.MSmerge_replinfo mr
        INNER JOIN dbo.sysmergesubscriptions sms
                ON mr.repid = sms.subid
             WHERE mr.merge_jobid = @job_id
        END

        IF NOT EXISTS (SELECT * FROM #sub_owner_list) AND 
           @agent_type IS NOT NULL
        BEGIN
            RAISERROR(21167, 16, -1, 'Merge')
            SELECT @retcode = 1
            GOTO FAILURE
        END 
    END

    IF NOT EXISTS (SELECT * FROM #sub_owner_list) 
    BEGIN
        RAISERROR(21134, 16, -1)
        SELECT @retcode = 1
        GOTO FAILURE
    END

    IF suser_sname(suser_sid()) NOT IN (SELECT owner_name FROM #sub_owner_list) AND
       is_srvrolemember('sysadmin') <> 1 AND
       is_member('db_owner') <> 1
    BEGIN

        RAISERROR(21168, 16, -1)
        SELECT @retcode = 1
        GOTO FAILURE
    END

FAILURE:

    DROP TABLE #sub_owner_list
    RETURN @retcode

GO

EXEC dbo.sp_MS_marksystemobject sp_MSagent_access_check
--------------------------------------------------------------------------------
--. sp_MScopysnapshot
--------------------------------------------------------------------------------
if exists (select * from sysobjects 
		where name = 'sp_MScopysnapshot' 
				and type = 'P')
	  drop procedure sp_MScopysnapshot

raiserror('Creating procedure sp_MScopysnapshot', 0,1)
go
CREATE PROCEDURE sp_MScopysnapshot (
    @source_folder           nvarchar(255),
    @destination_folder      nvarchar(255)
    )
AS
BEGIN
    SET NOCOUNT ON
    DECLARE @directory_exists bit    
    DECLARE @ftporuncdir      nvarchar(5)
    DECLARE @pubdir           nvarchar(255)
    DECLARE @timestampdir     nvarchar(255)
    DECLARE @bslashindex      int
    DECLARE @bslashindex2     int
    DECLARE @bslashcounter    int
    DECLARE @command          nvarchar(1000)
    DECLARE @retcode          int
    DECLARE @platform_nt      bit

    IF platform() & 0x1 = 0x1
        SELECT @platform_nt = 1
    ELSE
        SELECT @platform_nt = 0

    -- If @source_folder is NULL then either the snapshot has not been 
    -- generated or it has been cleaned up
    IF @source_folder IS NULL OR @source_folder = N''
    BEGIN
        RAISERROR(21289, 16, -1)
        RETURN (1)
    END

    -- Make sure that the @destination folder is not null
    IF @destination_folder IS NULL OR
       @destination_folder = N''
    BEGIN
        RAISERROR(21287, 16, -1)      
        RETURN (1)
    END

    -- Append backslash to @destination_folder if it is not 
    -- there already
    IF SUBSTRING(@destination_folder, LEN(@destination_folder), 1) <> N'\'
    BEGIN
        SELECT @destination_folder = @destination_folder + N'\'
    END

    -- Check if the destination folder exists 
    EXEC sp_MSget_file_existence @destination_folder, @directory_exists OUTPUT
    IF @directory_exists = 0
    BEGIN
        RAISERROR(21287, 16, -1)      
        RETURN (1)
    END    
    
    -- Parse out the last three components in the source folder 
    -- Note that the source_folder must have a trailing backslash
    SELECT @bslashindex = 1
    SELECT @bslashindex2 = 1
    SELECT @bslashcounter = 0
    WHILE (@bslashindex <> 0)
    BEGIN
        SELECT @bslashindex = CHARINDEX(N'\', @source_folder, @bslashindex + 1)
        SELECT @bslashcounter = @bslashcounter + 1
        IF @bslashcounter > 4
        BEGIN
            SELECT @bslashindex2 = CHARINDEX(N'\', @source_folder, @bslashindex2 + 1)
        END    
    END  

    SELECT @bslashindex = CHARINDEX(N'\', @source_folder, @bslashindex2 + 1)
    SELECT @ftporuncdir = SUBSTRING(@source_folder, @bslashindex2 + 1, @bslashindex - @bslashindex2 - 1)
    SELECT @bslashindex2 = @bslashindex

    SELECT @bslashindex = CHARINDEX(N'\', @source_folder, @bslashindex2 + 1)
    SELECT @pubdir = SUBSTRING(@source_folder, @bslashindex2 + 1, @bslashindex - @bslashindex2 - 1) 
    SELECT @bslashindex2 = @bslashindex

    SELECT @bslashindex = CHARINDEX(N'\', @source_folder, @bslashindex2 + 1)
    SELECT @timestampdir = SUBSTRING(@source_folder, @bslashindex2 + 1, @bslashindex - @bslashindex2 - 1) 
    SELECT @bslashindex2 = @bslashindex
        
    -- Create the subdirectory structure underneath the specified snapshot
    -- folder. Ignore errors for now, we will check whether the directory 
    -- is successfully created later on.

    -- Don't suppress output from xp_cmdshell so user knows what's going on
    -- in case something goes wrong 
    SELECT @destination_folder = @destination_folder + @ftporuncdir + '\'
    SELECT @command = 'mkdir "' + @destination_folder + '"'
    IF (@platform_nt = 1)
        SELECT @command = '" ' + @command + ' "'
    EXEC master..xp_cmdshell @command
    
    SELECT @destination_folder = @destination_folder + @pubdir + '\'
    SELECT @command = 'mkdir "' + @destination_folder + '"'
    IF (@platform_nt = 1)
        SELECT @command = '" ' + @command + ' "'
    EXEC master..xp_cmdshell @command

    SELECT @destination_folder = @destination_folder + @timestampdir + '\'
    SELECT @command = 'mkdir "' + @destination_folder + '"'
    IF (@platform_nt = 1)
        SELECT @command = '" ' + @command + ' "'
    EXEC master..xp_cmdshell @command

    -- Check if the real destination folder exists
    EXEC sp_MSget_file_existence @destination_folder, @directory_exists OUTPUT
    IF @directory_exists = 0
    BEGIN
        RAISERROR(21288, 16, -1)
        RETURN (1)
    END

    -- Do the actual copying
    SELECT @command = 'copy "' + @source_folder + '*.*" "' + @destination_folder + '"'    
    IF (@platform_nt = 1)
        SELECT @command = '" ' + @command + ' "'
    
    EXEC @retcode = master..xp_cmdshell @command
    
    IF @retcode <> 0
        RETURN (1)
    ELSE
        RETURN (0)
END
go
EXEC dbo.sp_MS_marksystemobject sp_MScopysnapshot
go

--------------------------------------------------------------------------------
--. sp_MSestimatesnapshotworkload
--------------------------------------------------------------------------------
if exists (select * from sysobjects
     where type = 'P '
            and name = 'sp_attachsubscription')
     drop procedure sp_attachsubscription
go
print ''
print 'Creating procedure sp_attachsubscription'
go
CREATE PROCEDURE sp_attachsubscription (
@dbname	sysname,
@filename nvarchar(260),
@subscriber_security_mode		int = NULL,						/* 0 standard; 1 integrated */
@subscriber_login				sysname = NULL,
@subscriber_password			sysname = NULL
)
AS

    SET NOCOUNT ON

    /*
    ** Declarations.
    */
	declare @cmd nvarchar(4000)
	declare @retcode int
	DECLARE @platform_nt binary
	declare @copy_created bit
    declare @exists bit

	select @platform_nt = 0x1	
	select @retcode = 0
	select @copy_created = 0
    select @exists = 0

	-- Parameter check: @subscriber_security_mode
	if @subscriber_security_mode is null
	begin
		if ( platform() & @platform_nt ) = @platform_nt
			select @subscriber_security_mode = 1
		else
			select @subscriber_security_mode = 0
	end	

	if ( ( platform() & @platform_nt ) <> @platform_nt and @subscriber_security_mode = 1 )
	begin
		RAISERROR(21038, 16, -1)
		RETURN (1)
	end

	if (@subscriber_security_mode = 0) and (@subscriber_login IS NULL or rtrim(@subscriber_login) = '')
		set @subscriber_login = 'sa'

	-- Check to make sure the database does not exists.
	if exists (select * from master..sysdatabases where name = @dbname collate database_default)
	begin
		raiserror(20621, 16, -1, @dbname)
		return (1)
	end

	-- Check to see if users has permissions to create database
	-- permissions() have to be run in master to return create db permission.
	declare @pm int
	exec @retcode = master.dbo.sp_executesql N'select @pm = permissions()', N'@pm int output', @pm output
	if @@error <> 0 or @retcode <> 0
		return 1
	if @pm & 1 = 0
	begin
		raiserror(20618, 16, -1)
		return 1
	end

	-- Decompress the file
	-- We have to copy the file to another location first. 
	-- (cannot use source as destination')
	declare @temp_copy nvarchar(260)
	declare @file_dir nvarchar(260)
	declare @file_name nvarchar(260)
	declare @dir_cmd nvarchar(260)
	-- Set @drive_cmd if needed 
	-- Set temp copy to be the file directory first
	-- Note @file_dir include '\'
	if (charindex('\', @filename, 1) = 0)
	begin
		select @file_dir = ''
		select @file_name = @filename
	end
	else
	begin
		select @file_dir = left(@filename,len(@filename) + 1 - 
			charindex('\', reverse(@filename), 1))
		select @file_name = right(@filename, len(@filename) - len(@file_dir))
	end
	-- Get guid name
    declare @guid_name nvarchar(36)
    select @guid_name =  convert (nvarchar(36), newid())
	select @temp_copy = @file_dir + @guid_name + '.tmp'


	-- copy file
	select @cmd = 'copy "' + @filename + '" "' + @temp_copy + '"'
	exec @retcode = master.dbo.xp_cmdshell @cmd, NO_OUTPUT
	if @@error <> 0 or @retcode <> 0
	begin
		raiserror(21248, 16, -1, @filename)
		select @retcode = 1
		goto Cleanup
	end	

    exec @retcode = dbo.sp_MSget_file_existence @temp_copy, @exists output
    if @@error <> 0 or @retcode <> 0
    begin
        select @retcode = 1
        goto Cleanup
    end
    if @exists = 0
    begin
		raiserror(21247, 16, -1, @temp_copy)        
        select @retcode = 1
        goto Cleanup
    end

	select @copy_created = 1

	-- decompress
	exec @retcode = master.dbo.xp_unpackcab 
		@cabfilename = @temp_copy,
		@destination_folder = @file_dir,
		@verbose_level = 0,
		@destination_file = @file_name,
		@suppress_messages = 1
		
	if @@error <> 0 
	begin
		select @retcode = 1
		goto Cleanup
	end

	if @retcode in (1030,1029,2005)
	begin
		raiserror(20609, 16, -1, @filename)
		select @retcode = 1
		goto Cleanup
	end	
	else if @retcode <> 0
	-- re-issue the command to get errors
	begin
		exec @retcode = master.dbo.xp_unpackcab 
			@cabfilename = @temp_copy,
			@destination_folder = @file_dir,
			@verbose_level = 0,
			@destination_file = @file_name,
			@suppress_messages = 0
		select @retcode = 1
		goto Cleanup
	end

	-- Attach
	exec @retcode = dbo.sp_attach_single_file_db
		@dbname = @dbname,
		@physname = @filename
	if @retcode<>0 or @@error<>0
	begin
		raiserror(21248, 16, -1, @filename)
		select @retcode = 1
		goto Cleanup
	end


	-- Prepare the database for detach. 2 things will be done
	-- 1. Set a flag to indicate that this is a prepare sub db for detach
	-- 2. For merge, create table to store sysservers info for later fixing up after attach
	select @cmd = quotename(@dbname) + '.dbo.sp_MSrestore_sub'
	exec @retcode = @cmd
		@subscriber_security_mode = @subscriber_security_mode,	
		@subscriber_login = @subscriber_login,
		@subscriber_password = @subscriber_password
	if @retcode<>0 or @@error<>0
	begin
		select @retcode = 1
		goto Cleanup
	end

Cleanup:
	if @retcode <> 0
	begin
		-- The files will be deleted if some thing failed. 
		if exists (select * from master..sysdatabases where name = @dbname collate database_default)
			begin
				select @cmd = 'drop database ' + quotename(@dbname)
				exec (@cmd)
			end				
	end

	if @temp_copy is not null
	begin
		-- Restore the original file, ignore errors
		if @retcode <> 0 and @copy_created = 1
		begin
			select @cmd = 'copy "' + @temp_copy + '" "' + @filename + '"'
			exec master.dbo.xp_cmdshell @cmd, NO_OUTPUT
		end

		-- Delete the temp file.
		select @cmd = 'del ' + quotename(@temp_copy,'"') 
		EXEC master..xp_cmdshell @cmd, NO_OUTPUT
	end

	return @retcode
go
EXEC dbo.sp_MS_marksystemobject sp_attachsubscription
grant execute on dbo.sp_attachsubscription to public
go

--------------------------------------------------------------------------------
--. sp_MSestimatesnapshotworkload
--------------------------------------------------------------------------------
if exists (select * from sysobjects
    where type = 'P'
            and name = 'sp_MSestimatesnapshotworkload')
    drop procedure sp_MSestimatesnapshotworkload
go

raiserror(15339,-1,-1,'sp_MSestimatesnapshotworkload')
go
create proc sp_MSestimatesnapshotworkload (
    @publication sysname
    )
as
begin
    set nocount on

    declare @taskload                       int
    declare @bigtaskload                    bigint
    declare @table_created                  bit
    declare @retcode                        int

    -- Publication info
    declare @pubid                          int
    declare @compress_snapshot              bit
    declare @snapshot_in_defaultfolder      bit
    declare @alt_snapshot_folder            nvarchar(255)
    declare @enabled_for_internet           bit
    declare @ftp_password                   nvarchar(524) 
    declare @ftp_subdirectory               nvarchar(255)
    declare @pre_snapshot_script            nvarchar(255)
    declare @post_snapshot_script           nvarchar(255)    

    -- Per publication summary stats
    declare @numarticles                    int
    declare @totalrowcount                  int   
    declare @needsysprescript               bit
    declare @copysnapshot                   bit
    declare @deletefiles                    bit
    declare @scriptproccost                 int
    declare @addcommandstotal               int
    declare @numscripts                     int
    declare @totalbcpcostper100             int
    declare @numprescriptcommands           int 

    select @numarticles = 0
    select @totalrowcount = 0
    select @needsysprescript = 0
    select @copysnapshot = 0
    select @deletefiles = 0
    select @scriptproccost = 0
    select @deletefiles = 0
    select @addcommandstotal = 0
    select @numscripts = 0
    select @totalbcpcostper100 = 0
    select @numprescriptcommands = 0

    -- Per article variables
    declare @artid                          int
    declare @schema_option                  int
    declare @creation_script                nvarchar(255)
    declare @type                           tinyint
    declare @objid                          int
    declare @rowcount                       int
    declare @name                           sysname
    declare @pre_creation_command           int

    select @table_created = 0

    -- Security check
    select @retcode = 0
	EXEC @retcode = dbo.sp_MSreplcheck_publish
	IF @@ERROR <> 0 or @retcode <> 0
		return (1)

    select @pubid = null
    select @compress_snapshot = 0
    select @snapshot_in_defaultfolder = 0
    select @alt_snapshot_folder = null
    select @enabled_for_internet = 0
    select @ftp_password = null
    select @ftp_subdirectory = null
    select @pre_snapshot_script = null
    select @post_snapshot_script = null
    -- Validate publication and retrieve publication information 
    select @pubid = pubid, 
           @compress_snapshot = compress_snapshot,
           @snapshot_in_defaultfolder = snapshot_in_defaultfolder,
           @alt_snapshot_folder = alt_snapshot_folder,
           @enabled_for_internet = enabled_for_internet,
           @ftp_password = ftp_password,
           @ftp_subdirectory = ftp_subdirectory,
           @pre_snapshot_script = pre_snapshot_script,
           @post_snapshot_script = post_snapshot_script
           from syspublications
     where name = @publication
    if @pubid = null
    begin   
        raiserror(20026, 11, -1, @publication)
        return (1)
    end

    -- An artid of -1 means the task is a per publication
    -- task

    -- Task id mapping - This is the list of task whose completion can be 
    -- reported by the snapshot agent
    -- 0 - Total workload (not really a task)
    -- 1 - Schema script generation
    -- 2 - Trigger script generation 
    -- 3 - XProp script generation
    -- 4 - Bcp file generation
    -- 5 - Activating subscription (estimate number of subscriptions?)
    -- 6 - Adding snapshot commands
    -- 7 - System pre-script generation
    -- 8 - Flushing folder for scripts
    -- 9 - Constraint script generation
    -- 10 - Copying pre-script
    -- 11 - Copying post-script
    -- 12 - Copying custom schema creation script
    -- 13 - Index script generation
    -- 14 - Flushing the cabinet
    -- 15 - Adding rowguid column
    -- 16 - Setting article procs
    -- 17 - Adding merge triggers
    -- 18 - Generating system table scripts
    -- 19 - Generating system table bcp files
    -- 20 - Making publication generation
    -- 21 - Generating and setting conflict script
    -- 22 - Generating publication views

    -- Weights and overheads
    -- DMO Script generation - 7/script
    -- BCP 5 overhead + 5/100 rows
    -- Flush folder for bcp 2/100 rows
    -- Delete file 2
    -- System pre-snapshot script 1 overhead + 0.5/pre-creation command
    -- Copying user file 2
    -- Adding file to cabinet 1 for scripts and 1/100 rows in bcp file
    -- Loading article info 3
    -- Delete bcp file 2/100rows 
    -- Copy bcp file  2/100rows  
    -- Flush scripts folder 1/2 scripts
    -- Flushing cabinet per 5 scripts 1
    -- Flushing cabinet per 500 rows 1

    -- Here is the list of cost factors 
    declare @addcommandcost     int
    declare @dmoscriptcost      int
    declare @bcpoverhead        int
    declare @bcpcostper100      int
    declare @flushper100        int
    declare @flushperscript     int
    declare @delfilecost        int
    declare @syspreoverhead     int
    declare @syspreper2commands int
    declare @addbcptocabper100  int
    declare @addscripttocab     int
    declare @copyfilecost       int
    declare @loadartinfo        int    
    declare @deletebcpper100    int
    declare @copybcpper100      int
    declare @flushper2scripts   int
    declare @flushcabper5scripts int
    declare @flushcabper500bcprows int
    declare @maxint             int

    select @addcommandcost = 2
    select @dmoscriptcost = 7
    select @bcpcostper100 = 20
    select @bcpoverhead = 2
    select @flushper100 = 2
    select @flushperscript = 3
    select @delfilecost = 2
    select @syspreoverhead = 1
    select @syspreper2commands = 1
    select @addbcptocabper100 = 1
    select @addscripttocab = 1
    select @copyfilecost = 2
    select @loadartinfo = 3    
    select @deletebcpper100 = 1
    select @copybcpper100 = 2
    select @flushper2scripts = 1
    select @flushcabper5scripts = 1
    select @flushcabper500bcprows = 1
    select @maxint = 2147483647

    create table #workload_breakdown
    (
        name        sysname collate database_default,
        artid       int,
        taskid      int,
        taskload    int
    )
    if @@error <> 0
        goto Failure

    select @table_created = 1

    -- Per publication work load estimate that can be done using publication
    -- properties alone
    
    -- Adding snapshot header commands
    
    -- Snapshot header begins + Snapshot header ends +
    -- directory command + Snapshot trailer command = 3 * @addcommandcost
    select @addcommandstotal = 4
    
    -- Alternate snapshot folder = 1 * @addcommandcost
    if @alt_snapshot_folder is not null and
       @alt_snapshot_folder <> N'' and
       @snapshot_in_defaultfolder = 1
    begin
        select @addcommandstotal = @addcommandstotal + @addcommandcost
    end

    -- Ftp commands
    if @enabled_for_internet = 1
    begin
        -- ftp_address and ftp_port must be there +=2 * @addcommandcost
        select @addcommandstotal = @addcommandstotal + 2 * @addcommandcost

        -- ftp_password += 1 * @addcommandcost
        if @ftp_password is not null and
           @ftp_password <> N''
        begin
            select @addcommandstotal = @addcommandstotal + @addcommandcost
        end
        
        -- ftp_subdirectory += 1 * @addcommandcost
        if @ftp_subdirectory is not null and
           @ftp_subdirectory <> N''
        begin
            select @addcommandstotal = @addcommandstotal + 1 * @addcommandcost
        end
    end

    -- Compressed archive path
    if @compress_snapshot = 1
    begin
        select @addcommandstotal = @addcommandstotal + 1 * @addcommandcost
    end    

    -- Snapshot trailer command
    select @addcommandstotal = @addcommandstotal +  @addcommandcost

    -- Need to copy files?
    if @alt_snapshot_folder is not null and @alt_snapshot_folder <> N''
       and @snapshot_in_defaultfolder = 1 and @compress_snapshot = 0
    begin
        select @copysnapshot = 1
    end

    -- Compute per-script file post processing cost and bcp cost per 100 rows
    -- Need to delete files?
    if (@alt_snapshot_folder is null or @alt_snapshot_folder <> N''
       or @snapshot_in_defaultfolder = 0) and @compress_snapshot = 1
    begin
        select @deletefiles = 1
    end

    select @totalbcpcostper100 = @bcpcostper100
    -- Copy file?
    if @copysnapshot = 1
    begin
        select @scriptproccost = @scriptproccost + @copyfilecost
        select @totalbcpcostper100 = @totalbcpcostper100 + @copybcpper100
    end

    -- Add file to cabinet?
    if @compress_snapshot = 1
    begin
        select @scriptproccost = @scriptproccost + @addscripttocab 
        select @totalbcpcostper100 = @totalbcpcostper100 + @addbcptocabper100
    end

    -- Delete file?
    if @deletefiles = 1
    begin 
        select @scriptproccost = @scriptproccost + @delfilecost
        select @totalbcpcostper100 = @totalbcpcostper100 + @deletebcpper100
    end

    -- Pre/Post-snapshot scripts, has to be computed after the 
    -- the per-script post-processing cost is calculated 
    if @pre_snapshot_script is not null and
       @pre_snapshot_script <> N''
    begin
        -- Cost of copying the script file
        select @taskload = @copyfilecost + @scriptproccost
        insert #workload_breakdown values (N'', -1, 10, @taskload)        
        -- Cost of adding the pre-snapshot command
        select @addcommandstotal = @addcommandstotal + @addcommandcost
        -- Increment scripts counter
        select @numscripts = @numscripts + 1
    end

    if @post_snapshot_script is not null and
       @post_snapshot_script <> N''
    begin
        -- Cost of copying the script file
        select @taskload = @copyfilecost + @scriptproccost
        insert #workload_breakdown values (N'', -1, 11, @taskload)
        -- Cost of adding the post-snapshot command
        select @addcommandstotal = @addcommandstotal + @addcommandcost
        -- Increment scripts counter
        select @numscripts = @numscripts + 1
    end
           
    -- Estimate the break down of per article tasks 
    declare hCarticles cursor local fast_forward
    for select artid, creation_script, objid, convert(int, schema_option), type, name, pre_creation_cmd  
          from sysextendedarticlesview where pubid = @pubid 

    open hCarticles
   
    fetch hCarticles into @artid, @creation_script, @objid, @schema_option, @type, @name, @pre_creation_command
    while (@@fetch_status <> -1)
    begin
        if @type = 0x40 -- Schema view articles, may require index scripting
        begin
            select @taskload = 0
            -- See if a custom creation script will be used 
            if @schema_option = 0 and @creation_script is not null and
               @creation_script <> N''
            begin
                -- Script generation
                select @taskload = @copyfilecost + @scriptproccost
                insert #workload_breakdown values (@name, @artid, 12, @taskload)
                -- Cost of adding commands for the custom script
                select @addcommandstotal = @addcommandstotal + @addcommandcost
                -- Increment scripts counter
                select @numscripts = @numscripts + 1
                -- No need to worry about index script
            end
            else
            begin
                -- Script generation 
                select @taskload = @dmoscriptcost + @scriptproccost
                -- Must script out schema script
                insert #workload_breakdown values (@name, @artid, 1, @taskload)
                -- Cost of adding the command
                select @addcommandstotal = @addcommandstotal + @addcommandcost
                -- Increment scripts counter
                select @numscripts = @numscripts + 1

                -- Index script?
                if (@schema_option & 0x50) <> 0x0
                begin
                    -- Cost of script generation
                    select @taskload = @dmoscriptcost + @scriptproccost
                    insert #workload_breakdown values (@name, @artid, 13, @taskload)
                    -- Cost of adding command for the script
                    select @addcommandstotal = @addcommandstotal + @addcommandcost
                    -- Increment scripts counter
                    select @numscripts = @numscripts + 1
                end

                -- Trigger script?
                if (@schema_option & 0x100) <> 0x0
                begin
                    -- Cost of script generation
                    select @taskload = @dmoscriptcost + @scriptproccost
                    insert #workload_breakdown values (@name, @artid, 2, @taskload)
                    -- Cost of adding command for the script
                    select @addcommandstotal = @addcommandstotal + @addcommandcost
                    -- Increment scripts counter
                    select @numscripts = @numscripts + 1
                end 

                -- XProp script?
                if (@schema_option & 0x2000) <> 0x0
                begin
                    -- Cost of script generation 
                    select @taskload = @dmoscriptcost + @scriptproccost
                    insert #workload_breakdown values (@name, @artid, 3, @taskload)
                    -- Cost of adding command
                    select @addcommandstotal = @addcommandstotal + @addcommandcost
                    -- Increment scripts counter
                    select @numscripts = @numscripts + 1
                end
            end        
        end
        else if @type in (0x08, 0x18, 0x20, 0x80) -- Regular schema or proc exec articles 
        begin
            select @taskload = 0
            -- See if a custom creation script will be used 
            if @schema_option = 0 and @creation_script is not null and
               @creation_script <> N''
            begin
                -- Script generation
                select @taskload = @copyfilecost + @scriptproccost
                insert #workload_breakdown values (@name, @artid, 12, @taskload)
                -- Cost of adding commands for the custom script
                select @addcommandstotal = @addcommandstotal + @addcommandcost
                -- Increment scripts counter
                select @numscripts = @numscripts + 1
            end
            else 
            begin
                -- Script generation 
                select @taskload = @dmoscriptcost + @scriptproccost
                -- Must script out schema script
                insert #workload_breakdown values (@name, @artid, 1, @taskload)
                -- Cost of adding the command
                select @addcommandstotal = @addcommandstotal + @addcommandcost
                -- Increment scripts counter
                select @numscripts = @numscripts + 1

                -- XProp script?
                if (@schema_option & 0x2000) <> 0x0
                begin
                    -- Cost of script generation 
                    select @taskload = @dmoscriptcost + @scriptproccost
                    insert #workload_breakdown values (@name, @artid, 3, @taskload)
                    -- Cost of adding command
                    select @addcommandstotal = @addcommandstotal + @addcommandcost
                -- Increment scripts counter
                select @numscripts = @numscripts + 1
                end
            end
        end
        else -- Log based articles, requires bcp
        begin
           select @taskload = 0
           -- See if a custom creation script will be used 
            if @schema_option = 0 and @creation_script is not null and
               @creation_script <> N''
            begin
                -- Script generation
                select @taskload = @copyfilecost + @scriptproccost
                insert #workload_breakdown values (@name, @artid, 12, @taskload)
                -- Cost of adding commands for the custom script
                select @addcommandstotal = @addcommandstotal + @addcommandcost
                -- Increment scripts counter
                select @numscripts = @numscripts + 1
                -- No need to worry about index script
            end
            else
            begin
                -- Script generation 
                select @taskload = @dmoscriptcost + @scriptproccost
                -- Must script out schema script
                insert #workload_breakdown values (@name, @artid, 1, @taskload)
                -- Cost of adding the command
                select @addcommandstotal = @addcommandstotal + @addcommandcost
                -- Increment scripts counter
                select @numscripts = @numscripts + 1

                -- Index script is not optional for logbased articles
                -- Cost of script generation
                select @taskload = @dmoscriptcost + @scriptproccost
                insert #workload_breakdown values (@name, @artid, 13, @taskload)
                -- Cost of adding command for the script
                select @addcommandstotal = @addcommandstotal + @addcommandcost
                -- Increment scripts counter
                select @numscripts = @numscripts + 1

                -- Constraint script?
                if (@schema_option & 0xf00) <> 0x0
                begin
                    -- Cost of script generation
                    select @taskload = @dmoscriptcost + @scriptproccost
                    insert #workload_breakdown values (@name, @artid, 9, @taskload)
                    -- Cost of adding command for the script
                    select @addcommandstotal = @addcommandstotal + @addcommandcost
                    -- Increment scripts counter
                    select @numscripts = @numscripts + 1
                end
    
                -- Trigger script?
                if (@schema_option & 0x100) <> 0x0
                begin
                    -- Cost of script generation
                    select @taskload = @dmoscriptcost + @scriptproccost
                    insert #workload_breakdown values (@name, @artid, 2, @taskload)
                    -- Cost of adding command for the script
                    select @addcommandstotal = @addcommandstotal + @addcommandcost
                    -- Increment scripts counter
                    select @numscripts = @numscripts + 1
                end 
        
                -- XProp script?
                if (@schema_option & 0x2000) <> 0x0
                begin
                    -- Cost of script generation 
                    select @taskload = @dmoscriptcost + @scriptproccost
                    insert #workload_breakdown values (@name, @artid, 3, @taskload)
                    -- Cost of adding command
                    select @addcommandstotal = @addcommandstotal + @addcommandcost
                    -- Increment scripts counter
                    select @numscripts = @numscripts + 1
                end
            end        
        
            -- Get fast row count from sysindexes for bcp op estimation
            select @rowcount = 
                    case when isnull(rowcnt,0) > @maxint then @maxint / 10000
                         when isnull(rowcnt,0) > @maxint / 10000 then rowcnt / 10000
                         else isnull(rowcnt,0)
                    end
               from sysindexes 
             where id = @objid 
               and indid in (0,1)

            -- Increment the total row count
            select @totalrowcount = @totalrowcount + @rowcount        

            -- BCP computation            
            -- Bcp file generation
            select @taskload = @bcpoverhead + (@rowcount * @totalbcpcostper100) / 100 
            insert #workload_breakdown values (@name, @artid, 4, @taskload)
        end    

        -- System pre-snapshot script required?
        if @type in (0x40, 0x80) or ((@type & 0x1)<>0 and @pre_creation_command =  3)
        begin
            select @needsysprescript = 1
            -- Incrememt the number of pre-script command counter
            select @numprescriptcommands = @numprescriptcommands + 1
        end

        -- Increment the article count
        select @numarticles = @numarticles + 1

        fetch hCarticles into @artid, @creation_script, @objid, @schema_option, @type, @name, @pre_creation_command
    end
    
    -- System pre-snapshot script processing cost 
    if @needsysprescript = 1
    begin
        select @taskload = @syspreoverhead + 
                (@numprescriptcommands * @syspreper2commands) / 2 +
               @scriptproccost
        insert #workload_breakdown values (N'', -1, 7, @taskload)         
        select @numscripts = @numscripts + 1
    end

    -- Cost of flushing folder for the scripts 
    if @compress_snapshot = 1
    begin
        select @taskload = (@numscripts * @flushper2scripts) / 2
        insert #workload_breakdown values (N'', -1, 8, @taskload) 
    end

    -- Synctran commands cost?
        

    -- Subscription activation cost?


    -- Cost for flushing the cabinet
    if @compress_snapshot = 1
    begin
        select @taskload = (@numscripts * @flushcabper5scripts / 5) +
                           (@totalrowcount * @flushcabper500bcprows / 500)
        insert #workload_breakdown values (N'', -1, 14, @taskload)
    end

    -- Add the total add commands cost
    insert #workload_breakdown values (N'', -1, 6, @addcommandstotal)

    -- Compute the total workload and put that in the 
    -- workload break down
    select @bigtaskload = sum(convert(bigint,taskload)) from #workload_breakdown
    select @taskload =
            case when @bigtaskload > @maxint then @maxint
                 else @bigtaskload
            end
    insert #workload_breakdown values (N'', -1, 0, @taskload) 

    select name, taskid, taskload from #workload_breakdown order by artid, taskid asc
    drop table #workload_breakdown
    return 0

Failure:
    if @table_created = 1
       drop table #workload_breakdown
    return 1

end
go
exec dbo.sp_MS_marksystemobject sp_MSestimatesnapshotworkload
grant execute on dbo.sp_MSestimatesnapshotworkload to public

--------------------------------------------------------------------------------
--. sp_MSestimatemergesnapshotworkload
--------------------------------------------------------------------------------
if exists (select * from sysobjects
    where type = 'P'
            and name = 'sp_MSestimatemergesnapshotworkload')
    drop procedure sp_MSestimatemergesnapshotworkload

raiserror(15339,-1,-1,'sp_MSestimatemergesnapshotworkload')
GO
create proc sp_MSestimatemergesnapshotworkload (
    @publication sysname
    )
as
begin
    set nocount on

    declare @taskload                       int
    declare @bigtaskload                    bigint
    declare @table_created                  bit
    declare @retcode                        int

    -- constant
    declare @zerouuid                       uniqueidentifier
    select @zerouuid = convert(uniqueidentifier, N'{00000000-0000-0000-0000-000000000000}')
    -- Publication info
    declare @pubid                          uniqueidentifier
    declare @compress_snapshot              bit
    declare @snapshot_in_defaultfolder      bit
    declare @alt_snapshot_folder            nvarchar(255)
    declare @enabled_for_internet           bit
    declare @ftp_password                   nvarchar(524) 
    declare @ftp_subdirectory               nvarchar(255)
    declare @pre_snapshot_script            nvarchar(255)
    declare @post_snapshot_script           nvarchar(255)    
    declare @dynamic_filters                bit

    -- Per publication summary stats
    declare @numarticles                    int
    declare @totalrowcount                  int   
    declare @needsysprescript               bit
    declare @copysnapshot                   bit
    declare @deletefiles                    bit
    declare @scriptproccost                 int
    declare @addcommandstotal               int
    declare @numscripts                     int
    declare @totalbcpcostper100             int
    declare @numprescriptcommands           int 
    declare @numunsyncedarticles            int
    declare @numtablearticles               int
    declare @systablesrowcount              int
    declare @maxint                         int

    select @numarticles = 0
    select @totalrowcount = 0
    select @needsysprescript = 0
    select @copysnapshot = 0
    select @deletefiles = 0
    select @scriptproccost = 0
    select @deletefiles = 0
    select @addcommandstotal = 0
    select @numscripts = 0
    select @totalbcpcostper100 = 0
    select @numprescriptcommands = 0
    select @numunsyncedarticles = 0
    select @numtablearticles = 0
    select @systablesrowcount = 0
    select @maxint = 2147483647

    -- Per article variables
    declare @artid                          uniqueidentifier
    declare @schema_option                  int
    declare @creation_script                nvarchar(255)
    declare @type                           tinyint
    declare @objid                          int
    declare @rowcount                       int
    declare @name                           sysname
    declare @status                         int


    -- Security check
    select @retcode = 0
	EXEC @retcode = dbo.sp_MSreplcheck_publish
	IF @@ERROR <> 0 or @retcode <> 0
		return (1)

    select @table_created = 0

    select @pubid = null
    select @compress_snapshot = 0
    select @snapshot_in_defaultfolder = 0
    select @alt_snapshot_folder = null
    select @enabled_for_internet = 0
    select @ftp_password = null
    select @ftp_subdirectory = null
    select @pre_snapshot_script = null
    select @post_snapshot_script = null
    -- Validate publication and retrieve publication information 
    select @pubid = pubid, 
           @compress_snapshot = compress_snapshot,
           @snapshot_in_defaultfolder = snapshot_in_defaultfolder,
           @alt_snapshot_folder = alt_snapshot_folder,
           @enabled_for_internet = enabled_for_internet,
           @ftp_password = ftp_password,
           @ftp_subdirectory = ftp_subdirectory,
           @pre_snapshot_script = pre_snapshot_script,
           @post_snapshot_script = post_snapshot_script,
           @dynamic_filters = dynamic_filters
           from sysmergepublications
     where name = @publication
       and upper(@@servername) = publisher
       and publisher_db = db_name()
    if @pubid = null
    begin   
        raiserror(20026, 11, -1, @publication)
        return (1)
    end

    -- An artid of -1 means the task is a per publication
    -- task

    -- Task id mapping - This is the list of task whose completion can be 
    -- reported by the snapshot agent
    -- 0 - Total workload (not really a task)
    -- 1 - Schema script generation
    -- 2 - Trigger script generation 
    -- 3 - XProp script generation
    -- 4 - Bcp file generation
    -- 5 - Activating subscription (estimate number of subscriptions?)
    -- 6 - Adding snapshot commands
    -- 7 - System pre-script generation
    -- 8 - Flushing folder for scripts
    -- 9 - Constraint script generation
    -- 10 - Copying pre-script
    -- 11 - Copying post-script
    -- 12 - Copying custom schema creation script
    -- 13 - Index script generation
    -- 14 - Flushing the cabinet
    -- 15 - Adding rowguid column
    -- 16 - Setting article procs
    -- 17 - Adding merge triggers
    -- 18 - Generating system table scripts
    -- 19 - Generating system table bcp files
    -- 20 - Making publication generation
    -- 21 - Generating and setting conflict script
    -- 22 - Generating publication views
    
    -- Weights and overheads
    -- DMO Script generation - 7/script
    -- BCP 5 overhead + 5/100 rows
    -- Flush folder for bcp 2/100 rows
    -- Delete file 2
    -- System pre-snapshot script 1 overhead + 0.5/pre-creation command
    -- Copying user file 2
    -- Adding file to cabinet 1 for scripts and 1/100 rows in bcp file
    -- Loading article info 3
    -- Delete bcp file 2/100rows 
    -- Copy bcp file  2/100rows  
    -- Flush scripts folder 1/2 scripts
    -- Flushing cabinet per 5 scripts 1
    -- Flushing cabinet per 500 rows 1
    -- Script execution 3
    -- Adding rowguid columns 20/100 rows
    -- Adding merge triggers 7
    -- Setting article procs 5

    -- Here is the list of cost factors 
    declare @addcommandcost     int
    declare @dmoscriptcost      int
    declare @bcpoverhead        int
    declare @bcpcostper100      int
    declare @flushper100        int
    declare @flushperscript     int
    declare @delfilecost        int
    declare @syspreoverhead     int
    declare @syspreper2commands int
    declare @addbcptocabper100  int
    declare @addscripttocab     int
    declare @copyfilecost       int
    declare @loadartinfo        int    
    declare @deletebcpper100    int
    declare @copybcpper100      int
    declare @flushper2scripts   int
    declare @flushcabper5scripts int
    declare @flushcabper500bcprows int
    declare @scriptexeccost int
    declare @rowguidper100 int
    declare @addmergetriggers int
    declare @setartprocs int
    declare @pubviewperarticle int
    declare @genperarticle int

    select @addcommandcost = 2
    select @dmoscriptcost = 7
    select @bcpcostper100 = 20
    select @bcpoverhead = 2
    select @flushper100 = 2
    select @flushperscript = 3
    select @delfilecost = 2
    select @syspreoverhead = 1
    select @syspreper2commands = 1
    select @addbcptocabper100 = 1
    select @addscripttocab = 1
    select @copyfilecost = 2
    select @loadartinfo = 3    
    select @deletebcpper100 = 1
    select @copybcpper100 = 2
    select @flushper2scripts = 1
    select @flushcabper5scripts = 1
    select @flushcabper500bcprows = 1
    select @scriptexeccost = 3
    select @rowguidper100 = 20
    select @addmergetriggers = 3
    select @pubviewperarticle = 2
    select @genperarticle = 2
    select @setartprocs = 5

    create table #workload_breakdown
    (
        name        sysname collate database_default,
        artid       uniqueidentifier,
        taskid      int,
        taskload    int
    )
    if @@error <> 0
        goto Failure

    select @table_created = 1

    -- Per publication work load estimate that can be done using publication
    -- properties alone
    
    -- Adding snapshot header commands
    
    -- Snapshot header begins + Snapshot header ends +
    -- directory command + Snapshot trailer command = 3 * @addcommandcost
    select @addcommandstotal = 4
    
    -- Alternate snapshot folder = 1 * @addcommandcost
    if @alt_snapshot_folder is not null and
       @alt_snapshot_folder <> N'' and
       @snapshot_in_defaultfolder = 1
    begin
        select @addcommandstotal = @addcommandstotal + @addcommandcost
    end

    -- Ftp commands
    if @enabled_for_internet = 1
    begin
        -- ftp_address and ftp_port must be there +=2 * @addcommandcost
        select @addcommandstotal = @addcommandstotal + 2 * @addcommandcost

        -- ftp_password += 1 * @addcommandcost
        if @ftp_password is not null and
           @ftp_password <> N''
        begin
            select @addcommandstotal = @addcommandstotal + @addcommandcost
        end
        
        -- ftp_subdirectory += 1 * @addcommandcost
        if @ftp_subdirectory is not null and
           @ftp_subdirectory <> N''
        begin
            select @addcommandstotal = @addcommandstotal + 1 * @addcommandcost
        end
    end

    -- Compressed archive path
    if @compress_snapshot = 1
    begin
        select @addcommandstotal = @addcommandstotal + 1 * @addcommandcost
    end    

    -- Snapshot trailer command
    select @addcommandstotal = @addcommandstotal +  @addcommandcost

    -- Need to copy files?
    if @alt_snapshot_folder is not null and @alt_snapshot_folder <> N''
       and @snapshot_in_defaultfolder = 1 and @compress_snapshot = 0
    begin
        select @copysnapshot = 1
    end

    -- Compute per-script file post processing cost and bcp cost per 100 rows
    -- Need to delete files?
    if (@alt_snapshot_folder is null or @alt_snapshot_folder <> N''
       or @snapshot_in_defaultfolder = 0) and @compress_snapshot = 1
    begin
        select @deletefiles = 1
    end

    select @totalbcpcostper100 = @bcpcostper100
    -- Copy file?
    if @copysnapshot = 1
    begin
        select @scriptproccost = @scriptproccost + @copyfilecost
        select @totalbcpcostper100 = @totalbcpcostper100 + @copybcpper100
    end

    -- Add file to cabinet?
    if @compress_snapshot = 1
    begin
        select @scriptproccost = @scriptproccost + @addscripttocab 
        select @totalbcpcostper100 = @totalbcpcostper100 + @addbcptocabper100
    end

    -- Delete file?
    if @deletefiles = 1
    begin 
        select @scriptproccost = @scriptproccost + @delfilecost
        select @totalbcpcostper100 = @totalbcpcostper100 + @deletebcpper100
    end

    -- Pre/Post-snapshot scripts, has to be computed after the 
    -- the per-script post-processing cost is calculated 
    if @pre_snapshot_script is not null and
       @pre_snapshot_script <> N''
    begin
        -- Cost of copying the script file
        select @taskload = @copyfilecost + @scriptproccost
        insert #workload_breakdown values (N'', @zerouuid, 10, @taskload)
        -- Cost of adding the pre-snapshot command
        select @addcommandstotal = @addcommandstotal + @addcommandcost
        -- Increment scripts counter
        select @numscripts = @numscripts + 1
    end

    if @post_snapshot_script is not null and
       @post_snapshot_script <> N''
    begin
        -- Cost of copying the script file
        select @taskload = @copyfilecost + @scriptproccost
        insert #workload_breakdown values (N'', @zerouuid, 11, @taskload)
        -- Cost of adding the post-snapshot command
        select @addcommandstotal = @addcommandstotal + @addcommandcost
        -- Increment scripts counter
        select @numscripts = @numscripts + 1
    end
           
    -- Estimate the break down of per article tasks 
    declare hCarticles cursor local fast_forward
    for select artid, creation_script, objid, convert(int, schema_option), type, name,
               status  
          from sysmergeextendedarticlesview where pubid = @pubid 

    open hCarticles
   
    fetch hCarticles into @artid, @creation_script, @objid, @schema_option, @type, @name,
        @status
    while (@@fetch_status <> -1)
    begin
        if @type = 0x40 -- Schema view articles, may require index scripting
        begin
            select @taskload = 0
            -- See if a custom creation script will be used 
            if @schema_option = 0 and @creation_script is not null and
               @creation_script <> N''
            begin
                -- Script generation
                select @taskload = @copyfilecost + @scriptproccost
                insert #workload_breakdown values (@name, @artid, 12, @taskload)
                -- Cost of adding commands for the custom script
                select @addcommandstotal = @addcommandstotal + @addcommandcost
                -- Increment scripts counter
                select @numscripts = @numscripts + 1
                -- No need to worry about index script
            end
            else
            begin
                -- Script generation 
                select @taskload = @dmoscriptcost + @scriptproccost
                -- Must script out schema script
                insert #workload_breakdown values (@name, @artid, 1, @taskload)
                -- Cost of adding the command
                select @addcommandstotal = @addcommandstotal + @addcommandcost
                -- Increment scripts counter
                select @numscripts = @numscripts + 1

                -- DRI script containing the view's indexes?
                if (@schema_option & 0x50) <> 0x0
                begin
                    -- Cost of script generation
                    select @taskload = @dmoscriptcost + @scriptproccost
                    insert #workload_breakdown values (@name, @artid, 9, @taskload)
                    -- Cost of adding command for the script
                    select @addcommandstotal = @addcommandstotal + @addcommandcost
                    -- Increment scripts counter
                    select @numscripts = @numscripts + 1
                end

                -- Trigger script?
                if (@schema_option & 0x100) <> 0x0
                begin
                    -- Cost of script generation
                    select @taskload = @dmoscriptcost + @scriptproccost
                    insert #workload_breakdown values (@name, @artid, 2, @taskload)
                    -- Cost of adding command for the script
                    select @addcommandstotal = @addcommandstotal + @addcommandcost
                    -- Increment scripts counter
                    select @numscripts = @numscripts + 1
                end 

                -- XProp script?
                if (@schema_option & 0x2000) <> 0x0
                begin
                    -- Cost of script generation 
                    select @taskload = @dmoscriptcost + @scriptproccost
                    insert #workload_breakdown values (@name, @artid, 3, @taskload)
                    -- Cost of adding command
                    select @addcommandstotal = @addcommandstotal + @addcommandcost
                    -- Increment scripts counter
                    select @numscripts = @numscripts + 1
                end
            end        
        end
        else if @type in (0x08, 0x18, 0x20, 0x80) -- Regular schema articles 
        begin
            select @taskload = 0
            -- See if a custom creation script will be used 
            if @schema_option = 0 and @creation_script is not null and
               @creation_script <> N''
            begin
                -- Script generation
                select @taskload = @copyfilecost + @scriptproccost
                insert #workload_breakdown values (@name, @artid, 12, @taskload)
                -- Cost of adding commands for the custom script
                select @addcommandstotal = @addcommandstotal + @addcommandcost
                -- Increment scripts counter
                select @numscripts = @numscripts + 1
            end
            else 
            begin
                -- Script generation 
                select @taskload = @dmoscriptcost + @scriptproccost
                -- Must script out schema script
                insert #workload_breakdown values (@name, @artid, 1, @taskload)
                -- Cost of adding the command
                select @addcommandstotal = @addcommandstotal + @addcommandcost
                -- Increment scripts counter
                select @numscripts = @numscripts + 1

                -- XProp script?
                if (@schema_option & 0x2000) <> 0x0
                begin
                    -- Cost of script generation 
                    select @taskload = @dmoscriptcost + @scriptproccost
                    insert #workload_breakdown values (@name, @artid, 3, @taskload)
                    -- Cost of adding command
                    select @addcommandstotal = @addcommandstotal + @addcommandcost
                -- Increment scripts counter
                select @numscripts = @numscripts + 1
                end
            end
        end
        else -- Merge table articles, requires bcp
        begin
           select @taskload = 0
           -- See if a custom creation script will be used 
            if @schema_option = 0 and @creation_script is not null and
               @creation_script <> N''
            begin
                -- Script generation
                select @taskload = @copyfilecost + @scriptproccost
                insert #workload_breakdown values (@name, @artid, 12, @taskload)
                -- Cost of adding commands for the custom script
                select @addcommandstotal = @addcommandstotal + @addcommandcost
                -- Increment scripts counter
                select @numscripts = @numscripts + 1
                -- No need to worry about index script
            end
            else
            begin
                -- Script generation 
                select @taskload = @dmoscriptcost + @scriptproccost
                -- Must script out schema script
                insert #workload_breakdown values (@name, @artid, 1, @taskload)
                -- Cost of adding the command
                select @addcommandstotal = @addcommandstotal + @addcommandcost
                -- Increment scripts counter
                select @numscripts = @numscripts + 1

                -- Constraint script is not optional for merge table article
                -- Cost of script generation
                select @taskload = @dmoscriptcost + @scriptproccost
                insert #workload_breakdown values (@name, @artid, 9, @taskload)
                -- Cost of adding command for the script
                select @addcommandstotal = @addcommandstotal + @addcommandcost
                -- Increment scripts counter
                select @numscripts = @numscripts + 1
    
                -- Trigger script?
                if (@schema_option & 0x100) <> 0x0
                begin
                    -- Cost of script generation
                    select @taskload = @dmoscriptcost + @scriptproccost
                    insert #workload_breakdown values (@name, @artid, 2, @taskload)
                    -- Cost of adding command for the script
                    select @addcommandstotal = @addcommandstotal + @addcommandcost
                    -- Increment scripts counter
                    select @numscripts = @numscripts + 1
                end 
        
                -- XProp script?
                if (@schema_option & 0x2000) <> 0x0
                begin
                    -- Cost of script generation 
                    select @taskload = @dmoscriptcost + @scriptproccost
                    insert #workload_breakdown values (@name, @artid, 3, @taskload)
                    -- Cost of adding command
                    select @addcommandstotal = @addcommandstotal + @addcommandcost
                    -- Increment scripts counter
                    select @numscripts = @numscripts + 1
                end
            end        

            -- Conflict script generation and setting
            -- Cost of script generation and execution 
            select @taskload = @dmoscriptcost + @scriptexeccost + @scriptproccost
            insert #workload_breakdown values (@name, @artid, 21, @taskload)

            -- Get fast row count from sysindexes for bcp op estimation
            select @rowcount = 
                    case when isnull(rowcnt,0) > @maxint then @maxint / 10000
                         when isnull(rowcnt,0) > @maxint / 10000 then rowcnt / 10000
                         else isnull(rowcnt,0)
                    end
              from sysindexes 
             where id = @objid and indid in (0,1)

            -- For unsynced articles, we need to 
            -- 1) Add rowguid column 
            -- 2) Set article procs
            -- 3) Add merge triggers
            if @status = 1
            begin
                -- Add rowguid column - use article row count to estimate the cost
                select @taskload = (@rowcount * @rowguidper100) / 100
                insert #workload_breakdown values (@name, @artid, 15, @taskload) 
      
                -- Set article procs
                select @taskload = @setartprocs
                insert #workload_breakdown values (@name, @artid, 16, @taskload)

                -- Add merge triggers    
                select @taskload = @addmergetriggers 
                insert #workload_breakdown values (@name, @artid, 17, @taskload)

                -- Increment the number of unsynced articles
                select @numunsyncedarticles = @numunsyncedarticles + 1
            end

            -- Increment the total row count
            select @totalrowcount = @totalrowcount + @rowcount        

            -- BCP computation            
            -- Bcp file generation
            select @taskload = @bcpoverhead + (@rowcount * @totalbcpcostper100) / 100 
            insert #workload_breakdown values (@name, @artid, 4, @taskload)

            -- Increment the table articles counter
            select @numtablearticles = @numtablearticles + 1

        end    

        -- System pre-snapshot script required?
        if @type in (0x40, 0x80)
        begin
            select @needsysprescript = 1
            -- Incrememt the number of pre-script command counter
            select @numprescriptcommands = @numprescriptcommands + 1
        end

        -- Increment the article count
        select @numarticles = @numarticles + 1

        fetch hCarticles into @artid, @creation_script, @objid, @schema_option, @type, @name,
            @status
    end
        
    -- The cost of making publication views depends upon the 
    -- number of unsynced articles
    if @numunsyncedarticles <> 0
    begin
        select @taskload = @numunsyncedarticles * @pubviewperarticle 
        insert #workload_breakdown values (N'', @zerouuid, 22, @taskload) 
    end

    -- Make publication generation - roughly proportional to the number of table
    -- articles we have
    select @taskload = @numtablearticles * @genperarticle
    insert #workload_breakdown values (N'', @zerouuid, 20, @taskload)

    -- Merge system tables processing 
    -- Script files
    select @taskload = 4 * (@dmoscriptcost + @scriptproccost)
    insert #workload_breakdown values (N'', @zerouuid, 18, @taskload)

    -- Cost of adding the commands
    select @addcommandcost = @addcommandcost + 4

    -- Bcp files - Generated only when the publication is not enabled for
    -- dynamic filters
    if @dynamic_filters = 0
    begin
        if exists (select * from sysobjects where name = N'MSmerge_contents')
        begin
            select @rowcount = 
                    case when isnull(rowcnt,0) > @maxint then @maxint / 10000
                         when isnull(rowcnt,0) > @maxint / 10000 then rowcnt / 10000
                         else isnull(rowcnt,0)       
                    end
              from sysindexes 
             where id = object_id('dbo.MSmerge_contents') 
               and indid in (0,1)
            select @systablesrowcount = @systablesrowcount + @rowcount
        end
        if exists (select * from sysobjects where name = N'MSmerge_tombstones')
        begin
            select @rowcount = 
                    case when isnull(rowcnt,0) > @maxint then @maxint / 10000
                         when isnull(rowcnt,0) > @maxint / 10000 then rowcnt / 10000
                         else isnull(rowcnt,0)       
                    end
              from sysindexes 
             where id = object_id('dbo.MSmerge_tombstoness') 
               and indid in (0,1)
            select @systablesrowcount = @systablesrowcount + @rowcount
        end
        if exists (select * from sysobjects where name = N'MSmerge_genhistory')
        begin
            select @rowcount = 
                    case when isnull(rowcnt,0) > @maxint then @maxint / 10000
                         when isnull(rowcnt,0) > @maxint / 10000 then rowcnt / 10000
                         else isnull(rowcnt,0)       
                    end
              from sysindexes 
             where id = object_id('dbo.MSmerge_genhistory') 
               and indid in (0,1)
            select @systablesrowcount = @systablesrowcount + @rowcount
        end
    end
    if exists (select * from sysobjects where name = N'sysmergesubsetfilters')
    begin
        select @rowcount = count(*) from sysmergesubsetfilters
        select @systablesrowcount = @systablesrowcount + @rowcount 
    end

    select @taskload = (4 * @bcpoverhead) + (@systablesrowcount * @totalbcpcostper100) / 100 
    insert #workload_breakdown values (N'', @zerouuid, 19, @taskload)
    select @totalrowcount = @totalrowcount + @systablesrowcount

    -- System pre-snapshot script processing cost 
    if @needsysprescript = 1
    begin
        select @taskload = @syspreoverhead + 
                (@numprescriptcommands * @syspreper2commands) / 2 +
               @scriptproccost
        insert #workload_breakdown values (N'', @zerouuid, 7, @taskload)         
        select @numscripts = @numscripts + 1
    end

    -- Cost of flushing folder for the scripts 
    if @compress_snapshot = 1
    begin
        select @taskload = (@numscripts * @flushper2scripts) / 2
        insert #workload_breakdown values (N'', @zerouuid, 8, @taskload) 
    end

    -- Cost for flushing the cabinet
    if @compress_snapshot = 1
    begin
        select @taskload = (@numscripts * @flushcabper5scripts / 5) +
                           (@totalrowcount * @flushcabper500bcprows / 500)
        insert #workload_breakdown values (N'', @zerouuid, 14, @taskload)
    end

    -- Add the total add commands cost
    insert #workload_breakdown values (N'', @zerouuid, 6, @addcommandstotal)

    -- Compute the total workload and put that in the 
    -- workload break down
    select @bigtaskload = sum(convert(bigint,taskload)) from #workload_breakdown
    select @taskload =
            case when @bigtaskload > @maxint then @maxint
            else @bigtaskload
            end
    insert #workload_breakdown values (N'', @zerouuid, 0, @taskload) 

    select name, taskid, taskload from #workload_breakdown order by artid, taskid asc
    drop table #workload_breakdown
    return 0

Failure:
    if @table_created = 1
       drop table #workload_breakdown
    return 1
end
go
exec dbo.sp_MS_marksystemobject sp_MSestimatemergesnapshotworkload
grant execute on dbo.sp_MSestimatemergesnapshotworkload to public

--------------------------------------------------------------------------------
--. sp_addsynctriggers
--------------------------------------------------------------------------------
if exists (select * from sysobjects
	where type = 'P '
			and name = 'sp_addsynctriggers')
	drop procedure sp_addsynctriggers

raiserror('Creating procedure sp_addsynctriggers', 0,1)
go

CREATE PROCEDURE sp_addsynctriggers (
	@sub_table       sysname,			-- table name 
	@sub_table_owner sysname,			-- table owner
	@publisher      sysname,            -- publishing server name
	@publisher_db   sysname,            -- publishing database name. If NULL then same as current db
	@publication	sysname,			-- publication name.
	@ins_proc       sysname,
	@upd_proc       sysname,
	@del_proc       sysname,
	@cftproc		sysname,
	@proc_owner		sysname,
	@identity_col   sysname = 'NULL', 
	@ts_col         sysname = 'NULL',
	@filter_clause  nvarchar(4000) = 'NULL',
	@primary_key_bitmap  varbinary(4000),
	@identity_support bit = 0,
	@independent_agent bit = 0
	,@distributor	sysname				-- distribution server name
)
AS
BEGIN
    set nocount on

	declare @db						sysname
			,@trigname				sysname
			,@ins_trig				sysname
			,@upd_trig				sysname
			,@del_trig				sysname
			,@qual_ins_trig			nvarchar(540)
			,@qual_upd_trig			nvarchar(540)
			,@qual_del_trig			nvarchar(540)
			,@dbname				sysname
			,@ccols					int
			,@cnt					int
			,@retcode				int
			,@cmd					nvarchar(4000)
			,@merge_pub_object_bit	int
			,@synctran_bit			int
			,@object_id				int
			,@bitmap_str				varchar(8000)
			,@constraint_name			sysname
			,@quoted_name			nvarchar(540)
			,@qualname				nvarchar(540)
			,@loctrancount 			int

	select 	@merge_pub_object_bit 	= 128
			,@synctran_bit			= 256

	--  Security Check
    EXEC @retcode = dbo.sp_MSreplcheck_subscribe
    IF @@ERROR <> 0 or @retcode <> 0
	RETURN(1)


    -- Dist Agent executes this sproc with 'implicit transasctions on'.
    -- We take care of our own transactions boundaries to get out of tran 
	set implicit_transactions off
	select @loctrancount = @@trancount
    while @@trancount > 0 commit tran

	-- check valid server and database setting
	-- 1. nested trigger have to be on
	if exists (select * from master..sysconfigures where config = 115 and value = 0)
	begin
        raiserror(21081, 16, 1)
        return (1)
	end

	-- 2. db option: recursive trigger have to be off
	if DATABASEPROPERTY(db_name(), N'IsRecursiveTriggersEnabled') <> 0
	begin
        raiserror(21082, 16, 1)
        return (1)
	end	
	
	-- 2. db compatibility level have to be 7.0
	if exists (select * from master..sysdatabases where dbid = db_id() and 
		cmptlevel < 70)
	begin
        raiserror(21083, 16, 1)
        return (1)
	end	
	
	if lower(@sub_table_owner) = N'null'
		select @qualname = QUOTENAME(@sub_table)		
	else
		select @qualname = QUOTENAME(@sub_table_owner) + N'.' + QUOTENAME(@sub_table)

	-- Verify that table exists 
	select @object_id = object_id (@qualname)
	if @object_id is null
    begin
        raiserror(20507, 16, 1, @qualname, 'sp_addsynctriggers')
        return (1)
    end

	-- Add default to timestamp, identity and version guid column
	if OBJECTPROPERTY(@object_id, 'tablehastimestamp') <> 1
    begin
	    select @constraint_name = 'MSrepl_synctran_ts_default_' + convert(nvarchar(10), @object_id)
	    select @quoted_name = quotename(@ts_col)
	    if @ts_col is not null and @ts_col not in ('null','NULL') and not exists
		    (select * from sysobjects where name = @constraint_name)
	    begin
		    exec ('alter table ' + @qualname + 
			    ' add constraint ' + @constraint_name + 
			    ' default 0 for ' + @quoted_name )
		    if @@ERROR<>0 return 1
	    end
    end
	
    if OBJECTPROPERTY(@object_id, 'tablehasidentity') <> 1
    begin
	    select @constraint_name = 'MSrepl_synctran_identity_default_' + convert(nvarchar(10), @object_id)
	    select @quoted_name = quotename(@identity_col)
	    if @identity_col is not null and @identity_col not in ('null','NULL') and not exists
		    (select * from sysobjects where name = @constraint_name)
	    begin
		    exec ('alter table ' + @qualname + 
			    ' add constraint ' + @constraint_name + 
			    ' default 0 for ' + @quoted_name )
		    if @@ERROR<>0 return 1
	    end
    end

	-- The default constraint is transfered with snapshot already for native publication.
	-- Need to detect to see if default constraint already there.
	select @quoted_name = 'msrepl_tran_version'
    declare @colid int
    select @colid = colid from syscolumns where 
        id = @object_id and
        name = @quoted_name
	if not exists (select * from sysconstraints where
        id = @object_id and 
        colid = @colid and
		status & 5 = 5) -- default
    begin 
	    select @constraint_name = 'MSrepl_tran_version_default_' + convert(nvarchar(10), @object_id)
		exec ('alter table ' + @qualname + 
			' add constraint ' + @constraint_name + 
			' default newid() for ' + @quoted_name )
		if @@ERROR<>0 return 1
    end

	-- If MSsubscription_properties table does not exists, create one.
	if (LOWER(@cftproc) = 'null')
	begin
		exec @retcode = dbo.sp_MScreate_sub_tables
			@tran_sub_table = 0,
			@property_table = 1,
			@sqlqueue_table = 0
	end
	else
	begin
		exec @retcode = dbo.sp_MScreate_sub_tables
			@tran_sub_table = 0,
			@property_table = 1,
			@sqlqueue_table = 1
	end
	IF @@ERROR <> 0 or @retcode <> 0
		RETURN(1)

	-- If no entry in MSsubscription_properties for this publication, add one.
	IF NOT EXISTS (select * from MSsubscription_properties 
            where UPPER(publisher) = UPPER(@publisher)
				and publisher_db =  @publisher_db
				and publication = @publication) 
	BEGIN
		-- Use status rpc for local publisher
		declare @security_mode int
		declare @login sysname
		if UPPER(@@servername) = UPPER(@publisher)
		begin
			select @security_mode = 2
		end
		else
		begin
			select @security_mode = 0
			select @login = 'sa'
		end

		exec @retcode = dbo.sp_link_publication
			@publisher = @publisher,
			@publisher_db = @publisher_db,
			@publication = @publication,
			@security_mode = @security_mode,
			@login = @login,
			@password = NULL,
			@distributor = @distributor
		IF @@ERROR <> 0 or @retcode <> 0
			RETURN(1)
	END
	  
    if exists (select * from sysobjects where 
		replinfo & @merge_pub_object_bit <> 0 and
		id = @object_id)
	begin
        raiserror(21063, 16, 1, @qualname)
        return (1)
	end
	
    -- Get agent_id
    declare @agent_id int

	-- First try to get the agent id initialized by the distribution agent
	declare @login_time datetime
	select @login_time = login_time from master..sysprocesses where spid = @@spid

	select @agent_id = id from MSsubscription_agents where
		spid = @@spid and
		login_time = @login_time

	-- If row not found, the current call is not from a distribution agent. Uses
	-- are creating trigger manually using the script generated by
	-- sp_script_synctran_triggers.
	-- Get the row using the publication name. However, it is possible that there are
	-- more than one qualifed rows with different subscription_type, for example
	-- pull and push subscriptions to share agent publications or subscriptions that has
	-- not been cleaned up.
	if @agent_id is null
	begin
		declare @num_dup_rows int
		select @agent_id = avg(id), @num_dup_rows = count(*) from MSsubscription_agents where
			publisher = @publisher and
			publisher_db = @publisher_db and
			publication = case @independent_agent 
				when 0 then N'ALL'
				else @publication
				end and
			-- We know the subscription must be updateble. This
			-- is to reduce the chance of dup rows.
			update_mode <> 0

		if @num_dup_rows > 1
		begin
			-- Raise subscription already exist error
			-- This should rarely happen.
			RAISERROR (14058, 16, -1)
			return(1)
		end

		if @agent_id is null
		begin
			raiserror(20588, 16, -1)
			return(1)
		end
	end


	/*
	**	Create system table MSreplication_objects if it does not exist
	*/
	IF NOT EXISTS (SELECT * FROM sysobjects WHERE 
		type = 'U' AND name = 'MSreplication_objects')
		BEGIN
			CREATE TABLE dbo.MSreplication_objects
			(
			publisher sysname NULL,
			publisher_db sysname NULL,
       		publication sysname NULL, 
			object_name	sysname NOT NULL,
			object_type	char(2) NOT NULL
			)
			IF @@ERROR <> 0
				begin
					rollback transaction 
					return (1)
				end
			
			CREATE UNIQUE CLUSTERED INDEX ucMSreplication_objects ON dbo.MSreplication_objects(object_name)
			EXEC dbo.sp_MS_marksystemobject 'dbo.MSreplication_objects'
		END


	-- Drop all replication triggers on the source object
	-- We should drop all because we don't support updatable subscriptions to 
	-- multiple publications on same dest table.
	declare object_cursor CURSOR LOCAL FAST_FORWARD for 
		select o.object_name, so.id from MSreplication_objects o, sysobjects so where
			o.object_name = so.name and
			so.parent_obj = @object_id and
			o.object_type = 'T'

	declare @old_id int 
	declare @old_name sysname

	OPEN object_cursor
    FETCH object_cursor INTO @old_name, @old_id
 	WHILE (@@fetch_status <> -1)
	BEGIN
        -- Cleanup identity range table
        declare @parent_obj int
        select @parent_obj = 0
		select @parent_obj = parent_obj from sysobjects where id = @old_id
        if exists (select * from sysobjects where name = 'MSsub_identity_range')
            delete MSsub_identity_range where objid = @parent_obj

        -- Drop the trigger
        exec @retcode = dbo.sp_MSdrop_object 
			@object_id = @old_id
		if @retcode <> 0 or @@error <> 0
			goto UNDO
		delete from MSreplication_objects where object_name=@old_name
		FETCH object_cursor INTO @old_name, @old_id
	END
    CLOSE object_cursor
    DEALLOCATE object_cursor

	-- Generate trigger names
        select @trigname = RTRIM(SUBSTRING(@sub_table,1,110))
	select @ins_trig = N'trg_MSsync_ins_' + @trigname 
	select @upd_trig = N'trg_MSsync_upd_' + @trigname 
	select @del_trig = N'trg_MSsync_del_' + @trigname 

	-- check uniqueness of names and revert to ugly guid-based name if friendly name already exists
	if exists (select name from sysobjects where name in (@ins_trig, @upd_trig, @del_trig))
        begin
            declare @guid_name nvarchar(36)
            select @guid_name =  convert (nvarchar(36), newid())
		select @ins_trig = 'trg_MSsync_ins_' + @guid_name
		select @upd_trig = 'trg_MSsync_upd_' + @guid_name
		select @del_trig = 'trg_MSsync_del_' + @guid_name
        end

	-- Get qual names
	if lower(@sub_table_owner) = N'null'
	begin
		select @qual_ins_trig = @ins_trig
		select @qual_upd_trig = @upd_trig
		select @qual_del_trig = @del_trig
	end
	else
	begin
		select @qual_ins_trig = QUOTENAME(@sub_table_owner) + N'.' + @ins_trig
		select @qual_upd_trig = QUOTENAME(@sub_table_owner) + N'.' + @upd_trig
		select @qual_del_trig = QUOTENAME(@sub_table_owner) + N'.' + @del_trig
	end


	exec @retcode = master..xp_varbintohexstr @primary_key_bitmap, @bitmap_str output
	if @retcode <> 0 or @@error <> 0
		return 1



/*
	exec ('if exists (select * from sysobjects where name = N''' + @ins_trig + N''' and xtype = N''TR'')
        drop trigger ' + @ins_trig)
    exec ('if exists (select * from sysobjects where name = N''' + @upd_trig + N''' and xtype = N''TR'')
        drop trigger ' + @upd_trig)
    exec ('if exists (select * from sysobjects where name = N''' + @del_trig + N''' and xtype = N''TR'')
        drop trigger ' + @del_trig)

*/
    -- We are now going to create triggers, so start a transaction
    begin tran
        -- Call out to individual create trigger routines
	    select @dbname = db_name()
	    select @cmd = 'sp_MSscript_sync_ins_trig ' + 
		    convert( nvarchar, @object_id )  + ', N' + 
			quotename(@publisher, '''')     + ', N' + 
			quotename(@publisher_db, '''')  + ', N' + 
			quotename(@publication, '''')   + ', N' + 
		    quotename(@ins_trig, '''')      + ', N' + 
			quotename(@ins_proc, '''')      + ', N' + 
			quotename(@proc_owner, '''')	+ ', N' + 
			quotename(@cftproc, '''')       + ', ' + 
			convert(nvarchar(10), @agent_id) + ', N' + 
			quotename(@identity_col, '''') + ', N' + 
			quotename(@ts_col, '''')        
		if @filter_clause in ('NULL', 'null')
		    select @cmd = @cmd + ', null' 
		else 
            select @cmd = @cmd + ', N''' + replace (@filter_clause,'''','''''')  + ''''
									
		-- Set primary key bitmap
		select @cmd = @cmd + ', ' + @bitmap_str

	    exec @retcode = master..xp_execresultset @cmd, @dbname
		IF @@ERROR <> 0 or @retcode <> 0
			goto UNDO
	    select @cmd = 'sp_MSscript_sync_upd_trig ' + 
		    convert( nvarchar, @object_id )  + ', N' + 
			quotename(@publisher, '''')     + ', N' + 
			quotename(@publisher_db, '''')  + ', N' + 
			quotename(@publication, '''')   + ', N' + 
		    quotename(@upd_trig, '''')      + ', N' + 
			quotename(@upd_proc, '''')      + ', N' + 
			quotename(@proc_owner, '''')	+ ', N' + 
			quotename(@cftproc, '''')       + ', ' + 
			convert(nvarchar(10), @agent_id)  + ', N' + 
			quotename(@identity_col, '''')  + ', N' + 
			quotename(@ts_col, '''')        
		if @filter_clause in ('NULL', 'null')
		    select @cmd = @cmd + ', null' 
		else 
            select @cmd = @cmd + ', N''' + replace (@filter_clause,'''','''''')  + ''''
									
		-- Set primary key bitmap
		select @cmd = @cmd + ', ' + @bitmap_str

		exec @retcode = master..xp_execresultset @cmd, @dbname
		IF @@ERROR <> 0 or @retcode <> 0
			goto UNDO

	    select @cmd = 'sp_MSscript_sync_del_trig ' + 
		    convert( nvarchar, @object_id )  + ', N' + 
			quotename(@publisher, '''')     + ', N' + 
			quotename(@publisher_db, '''')  + ', N' + 
			quotename(@publication, '''')   + ', N' + 
		    quotename(@del_trig, '''')      + ', N' + 
			quotename(@del_proc, '''')      + ', N' + 
			quotename(@proc_owner, '''')	+ ', N' + 
			quotename(@cftproc, '''')       + ', ' + 
			convert(nvarchar(10), @agent_id) + ', N' + 
			quotename(@identity_col, '''')  + ', N' + 
			quotename(@ts_col, '''')        
		if @filter_clause in ('NULL', 'null')
		    select @cmd = @cmd + ', null' 
		else 
            select @cmd = @cmd + ', N''' + replace (@filter_clause,'''','''''')  + ''''			

		-- Set primary key bitmap
		select @cmd = @cmd + ', ' + @bitmap_str

	    exec @retcode = master..xp_execresultset @cmd, @dbname
		IF @@ERROR <> 0 or @retcode <> 0
			goto UNDO

		-- Drop old entries before insert. The triggers with those names
		-- are created as above.
		delete MSreplication_objects where object_name = @ins_trig
		IF @@ERROR <> 0
			goto UNDO
		delete MSreplication_objects where object_name = @upd_trig
		IF @@ERROR <> 0
			goto UNDO
		delete MSreplication_objects where object_name = @del_trig
		IF @@ERROR <> 0
			goto UNDO

		-- Mark procedures as system procs so they don't show up in the UI
		exec dbo.sp_MS_marksystemobject @qual_ins_trig
		IF @@ERROR <> 0
			goto UNDO

		insert into MSreplication_objects(publisher, publisher_db, publication, object_name, object_type)
					values(@publisher, @publisher_db, @publication, @ins_trig, 'T')
		IF @@ERROR <> 0
			goto UNDO

		exec dbo.sp_MS_marksystemobject @qual_upd_trig
		IF @@ERROR <> 0
			goto UNDO
				
		insert into MSreplication_objects(publisher, publisher_db, publication, object_name, object_type)
					values(@publisher, @publisher_db, @publication, @upd_trig, 'T')
		IF @@ERROR <> 0
			goto UNDO

		exec dbo.sp_MS_marksystemobject @qual_del_trig
		IF @@ERROR <> 0
			goto UNDO

		insert into MSreplication_objects(publisher, publisher_db, publication, object_name, object_type)
					values(@publisher, @publisher_db, @publication, @del_trig, 'T')
		IF @@ERROR <> 0
			goto UNDO

		-- Mark the table for warnings in BCP
		update sysobjects set replinfo = replinfo | @synctran_bit where
			id = @object_id
		IF @@ERROR <> 0
			goto UNDO

		-- Set up identity range table
		if @identity_support <> 0
		begin
			if not exists (select * from sysobjects where name = 'MSsub_identity_range')
			begin
				create table dbo.MSsub_identity_range (
					objid int not null,
					range bigint not null,
					last_seed bigint not null,
					threshold int not null)
				IF @@ERROR <> 0
					goto UNDO
			
				CREATE UNIQUE CLUSTERED INDEX ucMSsub_identity_range ON dbo.MSsub_identity_range (objid)
				
				EXEC dbo.sp_MS_marksystemobject 'MSsub_identity_range'
				IF @@ERROR <> 0
					goto UNDO
			end
			if not exists (select * from MSsub_identity_range where objid = @object_id)
			begin
				-- add zero at the beginning.
				insert into MSsub_identity_range (objid, range, last_seed, threshold) values
					(@object_id, 0, 0, 0)
				IF @@ERROR <> 0
					goto UNDO
			end
		end

	-- commit tran
	commit tran

	-- Set trigger firing order for insert
	exec dbo.sp_settriggerorder @qual_ins_trig,'first','insert'
	exec dbo.sp_settriggerorder @qual_upd_trig,'first','update'
	exec dbo.sp_settriggerorder @qual_del_trig,'first','delete'
	
    -- Ignore errors.
    exec dbo.sp_MSsub_cleanup_orphans

	-- restore the trancount if necessary
	if (@loctrancount > 0)
	begin
		while (@@trancount < @loctrancount)
			begin tran
	end

	return (0)
UNDO:
	if @@trancount <> 0
		rollback tran
	return(1)
END
go

grant exec on dbo.sp_addsynctriggers to public

--------------------------------------------------------------------------------
--. sp_MSscript_where_clause
--------------------------------------------------------------------------------
if exists (select * from sysobjects
	where type = 'P '
			and name = 'sp_MSscript_where_clause')
	drop procedure sp_MSscript_where_clause

raiserror('Creating procedure sp_MSscript_where_clause', 0,1)
go
create procedure sp_MSscript_where_clause (
	@objid		  int,
	@columns      binary(32), 
	@clause_type  varchar(15) = 'pk_new', -- 'new pk', 'old pk', 'upd version', 'upd rc', 'trg pk', 'qcft_comp', 'new_pk_q', 'subwins_check'
	@ts_col       sysname = NULL,
	@indent       int = 0,
	@op_type      char(3) = NULL, -- 'ins', 'del', 'upd'
	@primary_key_bitmap varbinary(4000) = null )
as
BEGIN
	declare	@cmd			nvarchar(4000)
			,@colname		sysname
			,@ccoltype		sysname
			,@spacer		nvarchar(20)
			,@indkey		int
			,@indid			int
			,@key			sysname
			,@rc			int
			,@this_col		int
			,@art_col		int
			,@src_cols		int
			,@total_col		int
			,@col			sysname
			,@qualname		nvarchar(512)
			,@curparam		nvarchar(20)
			,@retcode		int
			,@fcreatedcolmap	bit
	declare @colmap table (relativeorder int identity(1,1), colid int)

	select @spacer = N' '
		,@cmd = N''
		,@indkey = 1
		,@indid = 0
		,@fcreatedcolmap = 0
	exec sp_MSget_qualified_name @objid, @qualname OUTPUT
	select @src_cols = max(colid)
			,@total_col = count(colid)
		from syscolumns where id = @objid
	exec dbo.sp_MSpad_command @cmd output, @indent
	if (@clause_type = 'qcft_comp')
		select @cmd = @cmd + N' '' where '
	else
		select @cmd = @cmd + N'where'
	exec dbo.sp_MSflush_command @cmd output, 1, @indent

	if @clause_type in ('new pk','old pk','upd version','trg pk','version pk','qcft_comp','new_pk_q','subwins_check')
	begin
		if @primary_key_bitmap is null
		begin
			exec @indid = dbo.sp_MStable_has_unique_index @objid
			if @indid is null
			begin
				raiserror('Debug: Cannot find unique index', 16, -1)
				return (1)
			end
		end

		--
		-- check if column Id match relative column order
		-- for specific trigger operations
		--
		if ((@total_col < @src_cols) and (@clause_type = 'trg pk') and 
			(@columns is null) and (@primary_key_bitmap is not null))
		begin
			--
			-- this table may have altered columns, so when we need to 
			-- set a mapping for using the bitmaps properly as the bitmap
			-- always refers relative column order
			--
			insert into @colmap (colid)
				select colid from syscolumns where id = @objid order by colid
			if (@@error != 0)
			begin
				raiserror('Could not create column mapping', 16, -1)
				return (1)
			end
			select @fcreatedcolmap = 1
		end
		
		while (1=1)
		begin
			--
			-- get the column position
			--
	        	if @primary_key_bitmap is null 
	        	begin
		             	select @key = index_col(@qualname, @indid, @indkey)
		             	if @key is null
		             		break
		             	--exec dbo.sp_MSget_col_position @objid, @columns, @key, @col output, @this_col output
		             	exec dbo.sp_MSget_col_position @objid, @columns, @key, @col output, NULL, 0, NULL, @this_col output
	        	end
	        	else
	        	begin
	        		exec dbo.sp_MSget_map_position @primary_key_bitmap, @indkey, @col output, @this_col output
	        		if @this_col is null
	        			break

				--
				-- set the actual column id for this relative order in the PK bitmap if necessary
				--
				if (@fcreatedcolmap = 1)
				begin
					select @this_col = colid
						,@col = 'c' + convert(sysname, colid) 
					from @colmap 
					where relativeorder = @this_col 
				end
	        	end

			--
			-- Get column name
			--
			exec @retcode = dbo.sp_MSget_colinfo @objid, @this_col, @columns, 0, @key output, @ccoltype output
			if (@retcode = 1)
			begin
				--
				-- this column not used for replication
				-- continue
				--
				select @indkey = @indkey + 1
				continue
			end
		
			if @clause_type = 'new pk'
			begin
			    if ColumnProperty(@objid, @key, 'IsIdentity') = 1
			        select @cmd = @cmd + @spacer + quotename(@key) + N' = @@identity'
			    else
			        select @cmd = @cmd + @spacer + quotename(@key) + N' = @' + @col

			    select @spacer = ' and '
			end
			else if @clause_type in ('upd version', 'subwins_check')
			begin
			    select @cmd = @cmd + @spacer + quotename(@key) + N' = @' + @col + N'_old'
			    select @spacer = ' and '
			end
			else if @clause_type = 'version pk'
			begin
			    select @cmd = @cmd + @spacer + @qualname + '.' + quotename(@key) + N' = inserted.' + quotename(@key)
			    select @spacer = ' and
	'
			end
			else if @clause_type in ('trg pk', 'old pk')
			begin				
				if @op_type = 'ins'
					select @cmd = @cmd + @spacer + quotename(@key) + N' = @' + @col + N'_old'
				else
					-- The vars correspoding to pk were set in sp_MSscript
					-- _pkvar_assignment.
					select @cmd = @cmd + @spacer + quotename(@key) + N' = @' + @col 
				select @spacer = ' and
	'
			end
			else if (@clause_type = 'qcft_comp')
			begin
				--
				-- Conflict compensation generation
				-- This is a special case - we generate
				-- and exec string for the WHERE clause
				--
				if (@op_type = 'ins')
					select @curparam = N'@' + @col
				else if (@op_type = 'del')
					select @curparam = N'@' + @col + N'_old'
				else
					select @curparam = N'ISNULL(@' + @col + N', @' + @col + N'_old)'
				
				select @cmd = @cmd + @spacer + quotename(@key)
				
				if (lower(@ccoltype collate SQL_Latin1_General_CP1_CS_AS) = 'varchar')
					select @cmd = @cmd + N' = '' + '''''''' + master.dbo.fn_MSgensqescstr(' + @curparam + N') collate database_default + '''''''' '
				else if (lower(@ccoltype collate SQL_Latin1_General_CP1_CS_AS) = 'nvarchar')
					select @cmd = @cmd + N' = '' + ''N'''''' + master.dbo.fn_MSgensqescstr(' + @curparam + N') collate database_default + '''''''' '
				else if (lower(@ccoltype collate SQL_Latin1_General_CP1_CS_AS) = 'char')
					select @cmd = @cmd + N' = '' + '''''''' + master.dbo.fn_MSgensqescstr(CAST(RTRIM(' + @curparam + N') as nvarchar)) collate database_default + '''''''' '
				else if (lower(@ccoltype collate SQL_Latin1_General_CP1_CS_AS) = 'nchar')
					select @cmd = @cmd + N' = '' + ''N'''''' + master.dbo.fn_MSgensqescstr(CAST(RTRIM(' + @curparam + N') as nvarchar)) collate database_default + '''''''' '
				else if (lower(@ccoltype collate SQL_Latin1_General_CP1_CS_AS) in ('binary','varbinary'))
					select @cmd = @cmd + N' = '' + master.dbo.fn_varbintohexstr(' + @curparam + N') collate database_default ' 
				else if (lower(@ccoltype collate SQL_Latin1_General_CP1_CS_AS) in ('bit','bigint','int','smallint','tinyint','float','real','decimal','numeric'))
					select @cmd = @cmd + N' = '' + CAST(' + @curparam + N' as nvarchar) '
				else if (lower(@ccoltype collate SQL_Latin1_General_CP1_CS_AS) in ('money','smallmoney'))
					select @cmd = @cmd + N' = '' + CONVERT(nvarchar(40),' + @curparam + N', 2) '
				else if (lower(@ccoltype collate SQL_Latin1_General_CP1_CS_AS) = 'uniqueidentifier')
					select @cmd = @cmd + N' = '' + '''''''' + CAST(' + @curparam + N' as nvarchar(40)) + '''''''' '
				else if (lower(@ccoltype collate SQL_Latin1_General_CP1_CS_AS) in ('datetime','smalldatetime'))
					select @cmd = @cmd + N' = '' + '''''''' + CONVERT(nvarchar(40), ' + @curparam + N', 112) + N'' '' + CONVERT(nvarchar(40), ' + @curparam + N', 114) + '''''''' '	
				else if (lower(@ccoltype collate SQL_Latin1_General_CP1_CS_AS) = 'sql_variant')
					select @cmd = @cmd + N' = '' + master.dbo.fn_sqlvarbasetostr(' + @curparam + N' ) collate database_default '
				else
					select @cmd = @cmd + N' = '' + CAST(' + @curparam + N' as nvarchar) '
				
				select @spacer = ' + '' and  '
			end
			else if @clause_type = 'new_pk_q'
			begin
				--
				-- new value of primary key, ignore identity
				-- used for scripting in synctran procs
				--
				select @cmd = @cmd + @spacer + quotename(@key) + N' = @' + @col
				select @spacer = ' and '
			end
			select @indkey = @indkey + 1

			-- flush command if necessary
			exec dbo.sp_MSflush_command @cmd output, 1, @indent
		end -- end of while loop
	    
		-- add version col as necessary
		if ((@clause_type in ('upd version','subwins_check')) and (@ts_col is not null))
		begin
			--
			-- @ts_col is version col actually.
			-- check for special cases for queued processing
			--
			exec dbo.sp_MSget_col_position @objid, @columns, @ts_col, @col output
			if (@clause_type = 'subwins_check')
				select @cmd = @cmd + @spacer + @ts_col + N' = @' + @col
			else
				select @cmd = @cmd + @spacer + @ts_col + N' = @' + @col + N'_old'

			--
			-- save off command fragment
			--
			exec dbo.sp_MSflush_command @cmd output, 1, @indent
		end
	end -- end of if clause_type
	-- 'upd rc' is used for column value conflict detection. It is no longer used.
	else if @clause_type = 'upd rc'
	begin
		select @this_col = 1, @art_col = 1
		while @this_col <= @src_cols
		begin
			exec @rc = dbo.sp_MSget_colinfo @objid, @this_col, @columns, 0, @colname output, @ccoltype output
			if @rc = 0
			begin
				select @cmd = @cmd +  @spacer + '(' + @colname + N' = @c' + convert(varchar(4), @this_col) + N'_old or (' 
				select @cmd = @cmd + @colname + ' is null and @c' + convert(varchar(4), @this_col) + N'_old is null)) '
				select @spacer = N' and 
	'
				exec dbo.sp_MSflush_command @cmd output, 0, @indent
			end
			exec dbo.sp_MSflush_command @cmd output, 1, @indent
			select @this_col = @this_col + 1
		end

		-- save off cmd fragment
		exec dbo.sp_MSflush_command @cmd output, 1, @indent
	end
	
END
go

grant execute on dbo.sp_MSscript_where_clause to public

--------------------------------------------------------------------------------
--. sp_MSarticlecleanup
--------------------------------------------------------------------------------
if exists (select * from sysobjects
	where type = 'P '
		and name = 'sp_MSarticlecleanup')
	drop procedure sp_MSarticlecleanup

raiserror('Creating procedure sp_MSarticlecleanup', 0,1)
GO

create procedure sp_MSarticlecleanup
	(@pubid uniqueidentifier, @artid uniqueidentifier)
as
	set nocount on
	declare @source_table 	nvarchar(270)
	declare @conflict_table nvarchar(270)
	declare @ownername 		sysname
	declare @objectname 	sysname
	declare @tablenick		int
	declare @objid 			int
	declare @sync_objid 	int
	declare @view_type		int
	declare @tsview			nvarchar(50)
	declare @guidstr		nvarchar(50)
	declare @csview			nvarchar(50)
	declare @viewname		nvarchar(270)
	declare @retcode		smallint
	declare @qualified_name	nvarchar(270)
	declare @bi_tablename	sysname
	declare	@bi_viewname	sysname
	declare @bi_procname	sysname
	declare @constraintname	sysname
	declare @merge_pub_markcolumn_bit int
	declare @merge_pub_unmarkcolumn_bit int

	-- to be called after article is set up in a subscriber

	/*
    ** Security Check
    */
    EXEC @retcode = dbo.sp_MSreplcheck_publish
    IF @@ERROR <> 0 or @retcode <> 0
        return (1)

	select @merge_pub_markcolumn_bit = 0x4000
	select @merge_pub_unmarkcolumn_bit = ~@merge_pub_markcolumn_bit

	select @objid = max(objid) from sysmergearticles where artid = @artid

	-- get owner name, and table name
	select @objectname = name, @ownername = user_name(uid)
		from sysobjects	where id = @objid

	-- construct the qualified table name
	select @source_table = QUOTENAME(@ownername) + '.' + QUOTENAME(@objectname)

	exec @retcode=sp_MSguidtostr @artid, @guidstr out
	if @retcode<>0 or @@ERROR<>0 return (1)
	
	-- get the insert, update and conflict proc names from sysmergearticles
	select 	@sync_objid = sync_objid, 
			@view_type = view_type, 
			@tablenick = nickname,
			@bi_tablename = object_name(before_image_objid),
			@bi_viewname = object_name(before_view_objid),
			@conflict_table = conflict_table 
		from sysmergearticles where
			pubid = @pubid and artid = @artid

	/*
	** We are not owner_qualifed this conflict table because it is created by snapshot agent
	*/
	select @qualified_name = QUOTENAME(@ownername) + '.' + QUOTENAME(@conflict_table)

	/* Drop the conflict table */
	if (@conflict_table IS NOT NULL) and exists (select * from sysobjects where
			name = @conflict_table and type = 'U')
		begin
			exec ('drop table ' + @qualified_name)
			if @@ERROR<>0 return (1)
		end


	/* If there is a before image table, drop it and its cleanup proc */
	if (@bi_tablename is not null)
		begin
		set @bi_procname = @bi_tablename + '_clean'

		if exists (select * from sysobjects where
			name = @bi_procname and type = 'P')
			begin
			exec ('drop proc ' + @bi_procname)
			if @@ERROR<>0 return (1)
			end
		exec ('drop table ' + @bi_tablename)
		if @@ERROR<>0 return (1)
		end
	/* If there is a before image view, drop it */
	if (@bi_viewname is not null)
		begin
		exec ('drop view ' + @bi_viewname)
		if @@ERROR<>0 return (1)
		end
		
	/* Drop the article procs */
	exec @retcode=sp_MSdroparticleprocs @pubid, @artid
	if @@ERROR<>0 or @retcode<>0 return (1)

	/* Drop the article triggers */
	exec @retcode=sp_MSdroparticletriggers @source_table
	if @@ERROR<>0 or @retcode<>0 return (1)

	exec @retcode=sp_MSunmarkreplinfo @objectname, @ownername
	if @@ERROR<>0 or @retcode<>0 return (1)

	/* so that columns can be dropped */
	update syscolumns set colstat=colstat & @merge_pub_unmarkcolumn_bit where id=@objid
	if @@ERROR<>0 return (1)

	/* If the article's has a temporary ( view type = 2) or a permanent view (view_type = 1 ) drop the sync object */
	if (@view_type = 1 OR @view_type = 2)
		begin
			select @viewname = sysobjects.name from sysobjects where 
				ObjectProperty (sysobjects.id, 'IsView') = 1 
				and ObjectProperty (sysobjects.id, 'IsMSShipped') = 1 
				and sysobjects.id = @sync_objid
			if @viewname IS NOT NULL
				begin
					select @ownername = user_name(uid) from sysobjects where name=@viewname
					set @viewname = QUOTENAME(@ownername) + '.' + QUOTENAME(@viewname)
					exec ('drop view ' + @viewname)
					if @@ERROR<>0 return (1)
				end
		end

	/*
	** Drop the views created for MSmerge_contents and MSmerge_tombstone before dropping these two tables
	*/
	set @csview = 'ctsv_' + @guidstr
	set @tsview = 'tsvw_' + @guidstr
	if EXISTS (select * from sysobjects where name=@csview and type='V')
	BEGIN
		select @ownername = user_name(uid) from sysobjects where  name=@csview
		select @viewname = QUOTENAME(@ownername) + '.' + QUOTENAME(@csview)
		exec ('drop view ' + @viewname)
			if @@ERROR<>0 return (1)
	END
		
	if EXISTS (select * from sysobjects where name=@tsview and type='V')
	BEGIN
		select @ownername = user_name(uid) from sysobjects where  name=@tsview
		select @viewname = QUOTENAME(@ownername) + '.' + QUOTENAME(@tsview)
		exec ('drop view ' + @viewname)
			if @@ERROR<>0 return (1)
	END

	select @constraintname = 'repl_identity_range_pub_' + convert(nvarchar(36), @artid)
	select @constraintname = REPLACE(@constraintname, '-', '_')
	if exists (select * from sysobjects where name = @constraintname and xtype='C')
	begin
		exec ('alter table '+ @source_table + ' drop constraint ' + @constraintname)
		if @@ERROR<>0
			return (1)
	end

	select @constraintname = 'repl_identity_range_repub_' + convert(nvarchar(36), @artid)
	select @constraintname = REPLACE(@constraintname, '-', '_')
	if exists (select * from sysobjects where name = @constraintname and xtype='C')
	begin
		exec ('alter table '+ @source_table + ' drop constraint ' + @constraintname)
		if @@ERROR<>0
			return (1)
	end

	/* Delete from contents, tombstone, delete conflicts; Ignore errors that occur */
	delete from MSmerge_contents where tablenick = @tablenick
	delete from MSmerge_tombstone where tablenick = @tablenick
	/* Delete rows from MSmerge_genhistory - if this is the last table that refers to them */
	if not exists (select * from sysmergearticles where nickname = @tablenick and pubid <> @pubid)
		delete from MSmerge_genhistory where art_nick = @tablenick

	delete from MSmerge_delete_conflicts where tablenick = @tablenick
	delete from MSrepl_identity_range where objid=@objid
GO

exec dbo.sp_MS_marksystemobject sp_MSarticlecleanup
grant execute on dbo.sp_MSarticlecleanup to public

--------------------------------------------------------------------------------
--. fn_repladjustcolumnmap
--------------------------------------------------------------------------------
if exists ( select * from sysobjects
    where type = 'FN'
    and name = 'fn_repladjustcolumnmap' )
    drop function system_function_schema.fn_repladjustcolumnmap	
    
raiserror('Creating function fn_repladjustcolumnmap', 0,1)
go
create function system_function_schema.fn_repladjustcolumnmap
(
	@objid	int
	,@total_col int
	,@inmap varbinary(4000)
) 
returns varbinary(4000)
as
begin
	declare @colmap table (relativeorder int identity(1,1), colid int)
	declare
		@outmap varbinary(4000)
		,@relpos int
		,@colid int
		,@bytepos int
		,@bitpos int
		,@num_bytes int

	--
	-- initialize
	--
	select @outmap = 0
	insert into @colmap (colid)
		select colid from syscolumns where id = @objid order by colid
	if (@@error != 0)
	begin
		return cast(NULL as varbinary(4000))
	end

	--
	-- for each column in the column map
	--
	declare #colmap_cursor cursor local fast_forward for 
		select relativeorder, colid from @colmap 
		order by relativeorder
	for read only

	open #colmap_cursor
	fetch #colmap_cursor into @relpos, @colid
	while (@@fetch_status = 0)
	begin
		--
		-- select the absolute column position
		--
		select @bytepos = 1 + ((@colid-1) / 8)
			,@bitpos =  power(2, (@colid-1) % 8 ) 

		if (substring(@inmap, @bytepos, 1) & @bitpos = @bitpos)
		begin
			--
			-- set the relative position for this column in the output
			--
			select @bytepos = 1 + ((@relpos-1) / 8)
				,@bitpos =  power(2, (@relpos-1) % 8 )
				,@num_bytes = @total_col / 8 + 1

			select @outmap = substring(@outmap, 1, (@bytepos - 1)) + 
				(convert(binary(1), substring(@outmap, @bytepos, 1) | convert(tinyint,@bitpos))) + 
				substring(@outmap, (@bytepos + 1), (@num_bytes - @bytepos))
		end

		-- fetch next column mapping
		fetch #colmap_cursor into @relpos, @colid		
	end
	close #colmap_cursor
	deallocate #colmap_cursor

	return @outmap
end
go
grant execute on system_function_schema.fn_repladjustcolumnmap to public

--------------------------------------------------------------------------------
--. sp_MSscript_begintrig1
--------------------------------------------------------------------------------
if exists (select * from sysobjects
	where type = 'P '
			and name = 'sp_MSscript_begintrig1')
	drop procedure sp_MSscript_begintrig1

raiserror('Creating procedure sp_MSscript_begintrig1', 0,1)
go
create procedure sp_MSscript_begintrig1 (
	@trigname      sysname
	,@objid         int
	,@procname      sysname
	,@filter_clause nvarchar(4000)
	,@op_type       char(3) = 'ins' -- ins, upd, del
	,@fisqueued	  bit = 0 -- 1 = Queued subscription
)
as
BEGIN
	declare @cmd       nvarchar(4000)
			,@start     int
			,@sub_len   int
			,@qualname  nvarchar(512)

    exec sp_MSget_qualified_name @objid, @qualname OUTPUT

	-- construct trigger name
	select @cmd = N'create trigger ' + QUOTENAME(@trigname) + N' on ' + @qualname + N' for '
	select @cmd = case
					when (@op_type = 'ins') then @cmd + N'insert '
					when (@op_type = 'upd') then @cmd + N'update '
					when (@op_type = 'del') then @cmd + N'delete '
				end
	select @cmd = @cmd + N'not for replication
as
'
	insert into #proctext(procedure_text) values (@cmd)

	--
	-- declare common local variables
	--
	--		,@update_mode char(40)
	--		,@failover_mode char(10)
	--
	insert into #proctext(procedure_text) values (N'
	declare 	@rc int
		,@retcode int
		,@connect_string nvarchar(2000)
		,@rpc_proc nvarchar(4000)
		,@rpc_types nvarchar(4000)
		,@update_mode_id int
		,@bitmap varbinary(4000)
		,@version_guid uniqueidentifier
		,@trigger_op char(10) ')

		--
		-- queued specific declarations
		--
	insert into #proctext(procedure_text) values (N'
		,@failover_mode_id int
		,@queue_server sysname
		,@queue_id sysname
		,@tran_id varchar(255)
		,@subscriber sysname
		,@subscriber_db sysname 
		,@partial_cmd bit
		,@start_offset int
		,@end_offset int
		,@vb_buffer varbinary(8000)
		,@vb_bufferlen int		
		')

	-- script variables used to retrieve data from inserted table
	if @op_type in ('ins', 'upd')
	begin
		insert into #proctext(procedure_text) values(N'
	declare ')
	        exec dbo.sp_MSscript_params @objid, null, null, 0, null
	end
	insert into #proctext(procedure_text) values(N'
	declare ')
	exec dbo.sp_MSscript_params @objid, null, '_old',  0, null

	-- Set @rc, @subscriber and @subscriber_db
	-- Optimization. Return immediately if no row changed
	select @cmd = N'

	select @rc = @@ROWCOUNT, @subscriber = @@SERVERNAME, @subscriber_db = db_name() 
	if @rc = 0 
		return 
	set nocount on '
	insert into #proctext(procedure_text) values(@cmd)
		
	-- set column update bitmap for update trigger
	if @op_type in ('upd')
	begin
		declare 	@num_bytes		int
				,@i_byte			int
				,@i_bit			tinyint
				,@len_before nvarchar(10)
				,@len_after nvarchar(10)
				,@index1 nvarchar(10)
				,@index2 nvarchar(10)
				,@this_col 		int
				,@max_col			int
				,@total_col		int

		--
		-- check if the subscriber table was altered for column changes
		--
		select @max_col = max(colid)
				,@total_col = count(colid)
			from syscolumns where id = @objid
		if (@total_col = @max_col)
		begin
			--
			-- actual colid and relative column order are same
			--
			insert into #proctext(procedure_text) values(N'
	select @bitmap = columns_updated() 
	')
		end
		else
		begin
			--
			-- we need to convert the columns_updated bitmap to 
			-- a bitmap that contains relative column information
			--
			select @cmd = N'
	select @bitmap = fn_repladjustcolumnmap( ' + cast(@objid as sysname) + N', ' +
				cast(@total_col as sysname) + N', columns_updated())'
			insert into #proctext(procedure_text) values(@cmd)
			select @cmd = N'				
	if (@bitmap is null) 
	begin
		raiserror(''fn_repladjustcolumnmap could not create column mapping'', 16, 1)
		goto FAILURE
	end
	'
			insert into #proctext(procedure_text) values(@cmd)
		end

	        --
	        -- Mark the version bit in the bitmap as updated.
	        --
	        select @cmd = N'
	' + '-- set the bit for msrepl_tran_version'
		insert into #proctext(procedure_text) values(@cmd)

		-- get actual column id
		exec dbo.sp_MSget_col_position @objid, null, 'msrepl_tran_version', @this_col = @this_col output
		if (@total_col < @max_col)
		begin
			--
			-- this table has altered columns, create a mapping between
			-- relative column position and actual column id
			--
			declare @colmap table (relativeorder int identity(1,1), colid int)
			insert into @colmap (colid)
				select colid from syscolumns where id = @objid order by colid
			if (@@error != 0)
			begin
				raiserror('Could not create column mapping', 16, -1)
				return (1)
			end

			--
			-- get the relative column position for msrepl_tran_version
			--
			select @this_col = relativeorder from @colmap where colid = @this_col 
		end
	
		select @num_bytes = @total_col / 8 + 1
			,@i_byte = 1 + (@this_col-1) / 8
			,@i_bit  = power(2, (@this_col-1) % 8 )

		select @len_before = convert(nvarchar(10), @i_byte -1)
			,@index1 = convert(nvarchar(10), @i_byte)
			,@index2 = convert(nvarchar(10), @i_byte + 1)
			,@len_after = convert(nvarchar(10), @num_bytes - @i_byte)

		select @cmd = N'
	select @bitmap = substring(@bitmap, 1, ' + @len_before + 
            ') + (convert(binary(1), substring(@bitmap, ' + @index1 + 
            ', 1) | convert(tinyint,' + convert(nvarchar(10), @i_bit) + 
            '))) + substring(@bitmap, ' + @index2 + 
            ', ' + @len_after + 
            ') '
		exec dbo.sp_MSflush_command @cmd, 1
	end

	select @cmd = N'
	select @version_guid = newid() '
	insert into #proctext(procedure_text) values(@cmd) 

	-- Partition check statement
	if @filter_clause IS NOT NULL
	begin
		declare @retcode int
		exec @retcode = sp_MSsubst_filter_names NULL, N'inserted', @filter_clause output
		if @retcode <> 0 or @@error <> 0
			return 1	    
				
		select @cmd = N'
	if exists (select * from inserted where not ('
		insert into #proctext(procedure_text) values(@cmd) 
		    
		-- break filter_clause into chunks of 255
		select @start = 1
		while @start < len(@filter_clause)
		begin
			if len(@filter_clause) < 255
				select @sub_len = len(@filter_clause)
			else
				select @sub_len = 255
			select @cmd = substring(@filter_clause, @start, @sub_len)
			exec dbo.sp_MSflush_command @cmd output, 1
			select @start = @start + @sub_len
		end
				
		select @cmd = N'))
	 begin 
	     exec sp_MSreplraiserror 21034
	     goto FAILURE 
	 end '
		insert into #proctext(procedure_text) values(@cmd) 
	end

	-- trigger nesting checks
	if @op_type in ('upd')
	begin
		select @cmd = N'
	' + '-- trigger nesting check
	exec @retcode = dbo.sp_check_sync_trigger @@procid, @trigger_op OUTPUT 
	if (@retcode = 1)
		return '
		insert into #proctext(procedure_text) values(@cmd) 
	end

END
go

grant execute on dbo.sp_MSscript_begintrig1 to public

--------------------------------------------------------------------------------
--. sp_MSscript_trigger_variables
--------------------------------------------------------------------------------
if exists (select * from sysobjects
	where type = 'P '
			and name = 'sp_MSscript_trigger_variables')
	drop procedure sp_MSscript_trigger_variables

raiserror('Creating procedure sp_MSscript_trigger_variables', 0,1)
go
create procedure sp_MSscript_trigger_variables
(
	@objid int,
	@prefix char(1) = null, -- null or '@'
	@postfix varchar(4) = null,
	@indent int = 0,
	@spacer nvarchar(1) = N' ', 
	@bOutput_params tinyint = 0,  -- declare output params if necessary
	@identity_col sysname = null,
	@ts_col sysname = null,
	@include_type bit = 0,
	@set_nulls	bit = 0,
	@op_type char(3) = 'ins', -- 'ins, 'upd', 'del'
	@is_new		bit = 0,
	@primary_key_bitmap varbinary(4000) = NULL,
	@no_output bit = 0
)
as
begin
	declare @cmd          nvarchar(4000)
			,@colname      sysname
			,@ccoltype     sysname
			,@src_cols     int
			,@this_col     int
			,@total_col		int
			,@indkey			int
			,@fcreatedcolmap	bit
			,@rc           int
			,@column		  nvarchar(4000)
	declare @colmap table (relativeorder int identity(1,1), colid int)

	-- script cursor select variables
	select @cmd = N''
			,@indkey = 1
			,@fcreatedcolmap = 0
	select @src_cols = max(colid)
			,@total_col = count(colid)
		from syscolumns where id = @objid
	exec dbo.sp_MSpad_command @cmd output, @indent

	--
	-- check if column Id match relative column order
	-- for trigger scripting
	--
	if (@total_col < @src_cols)
	begin
		--
		-- this table may have altered columns, so when we need to 
		-- set a mapping for using the bitmaps properly as the bitmap
		-- always refers relative column order
		--
		insert into @colmap (colid)
			select colid from syscolumns where id = @objid order by colid
		if (@@error != 0)
		begin
			raiserror('Could not create column mapping', 16, -1)
			return (1)
		end
		select @fcreatedcolmap = 1
	end

	while (@indkey <= @total_col)
	begin
		--
		-- set the actual column id for this relative order in the bitmap if necessary
		--
		if (@fcreatedcolmap = 1)
		begin
			select @this_col = colid from @colmap 
				where relativeorder = @indkey 
		end
		else
		begin
			select @this_col = @indkey
		end

		--
		-- Get column name
		-- Don't include timestamp or computed columns        
		--
		exec @rc = dbo.sp_MSget_colinfo @objid, @this_col, null, 0, @colname output, @ccoltype output
		if @rc = 0 and EXISTS (select name from syscolumns where id=@objid and colid=@this_col and iscomputed<>1 and xtype <> 189)
		begin
			if @prefix is null
			begin
			
				if (@set_nulls = 1)
				begin
					-- Optimization:
					-- Get null or actual column name
					-- Note: the output is quoted.
					exec dbo.sp_MSget_synctran_column 
						@ts_col = @ts_col,
						@op_type = @op_type, -- 'ins, 'upd', 'del'
						@is_new = @is_new,
						@primary_key_bitmap = @primary_key_bitmap,
						@colname = @colname,
						@this_col = @this_col,
						@column = @column output,
						@from_proc = 0, 
						@coltype = @ccoltype, 
						@type = NULL,
						@art_col = @indkey
					select @cmd = @cmd + @spacer + @column + isnull(@postfix, N'')
				end
				else
				begin
					-- set null is false
					select @cmd = @cmd + @spacer + N'[' + @colname + isnull(@postfix, N'') + N']'
				end
			end
			else
			begin
				-- prefix was specified
				select @cmd = @cmd + @spacer + isnull(@prefix, N'') 
					+ N'c' + RTRIM(convert(nvarchar(4), @this_col)) + isnull(@postfix, N'')
			end

			if (@include_type = 1)
			begin
				declare @typestring nvarchar(100)
				exec dbo.sp_MSget_type @objid, @this_col, @colname output, @typestring OUTPUT
				select @cmd = @cmd +  N' ' + @typestring 
			end

			-- new vars of type timestamp and identity are declared as output params
			if (@bOutput_params = 1 and (@ccoltype = N'timestamp' or ColumnProperty(@objid, @colname, 'IsIdentity') = 1))
				or (@colname = @identity_col or @colname = @ts_col)
			begin
				-- YWU: Do this to avoid output in cursor declaration statement.
				-- The right thing seems to be set output only when bOutput_params is set
				-- but it seems not the way this sp is called.
				if @set_nulls = 0 and @no_output = 0
					select @cmd = @cmd + N' output'
			end

			select @spacer = N','
		end -- if rc=0 and exists ...
		
		exec dbo.sp_MSflush_command @cmd output, 0, @indent
		select @indkey = @indkey + 1
	end -- while () loop

	exec dbo.sp_MSflush_command @cmd output, 1, @indent
	insert into #proctext(procedure_text) values(N'
') 

end
go

grant execute on dbo.sp_MSscript_trigger_variables to public

--------------------------------------------------------------------------------
--. sp_MSscript_trigger_assignment
--------------------------------------------------------------------------------
if exists (select * from sysobjects
	where type = 'P '
			and name = 'sp_MSscript_trigger_assignment')
	drop procedure sp_MSscript_trigger_assignment

raiserror('Creating procedure sp_MSscript_trigger_assignment', 0,1)
go

create procedure sp_MSscript_trigger_assignment (
	@objid int
	,@postfix char(4) = null
	,@indent int = 0
	,@ts_col sysname
	,@op_type char(3) -- 'ins, 'upd', 'del'
	,@is_new	bit
	,@primary_key_bitmap varbinary(4000) = null
)
as
BEGIN
	declare @cmd          nvarchar(4000)
			,@colname      sysname
			,@spacer       nvarchar(1)
			,@ccoltype     sysname
			,@src_cols     int
			,@this_col     int
			,@total_col		int
			,@indkey			int
			,@fcreatedcolmap	bit
			,@rc           int
			,@column		  nvarchar(4000)
	declare @colmap table (relativeorder int identity(1,1), colid int)

	-- initialize
	select @spacer = N' '
			,@indkey = 1
			,@fcreatedcolmap = 0
	select @src_cols = max(colid)
			,@total_col = count(colid)
		from syscolumns where id = @objid
	exec dbo.sp_MSpad_command @cmd output, @indent

	--
	-- check if column Id match relative column order
	-- for trigger scripting
	--
	if (@total_col < @src_cols)
	begin
		--
		-- this table may have altered columns, so when we need to 
		-- set a mapping for using the bitmaps properly as the bitmap
		-- always refers relative column order
		--
		insert into @colmap (colid)
			select colid from syscolumns where id = @objid order by colid
		if (@@error != 0)
		begin
			raiserror('Could not create column mapping', 16, -1)
			return (1)
		end
		select @fcreatedcolmap = 1
	end

	while (@indkey <= @total_col)
	begin
		--
		-- set the actual column id for this relative order in the bitmap if necessary
		--
		if (@fcreatedcolmap = 1)
		begin
			select @this_col = colid from @colmap 
				where relativeorder = @indkey 
		end
		else
		begin
			select @this_col = @indkey
		end

		--
		-- Get column name
		--
		exec @rc = dbo.sp_MSget_colinfo @objid, @this_col, null, 0, @colname output, @ccoltype output
		if @rc = 0  and EXISTS (select name from syscolumns where id=@objid and @this_col=colid and iscomputed<>1)
		begin
			-- Optimization:
			-- Get null or actual column name
			-- Note: the output is quoted.
			exec dbo.sp_MSget_synctran_column 
				@ts_col = @ts_col,
				@op_type = @op_type, -- 'ins, 'upd', 'del'
				@is_new = @is_new,
				@primary_key_bitmap = @primary_key_bitmap,
				@colname = @colname,
				@this_col = @this_col,
				@column = @column output,
				@from_proc = 0, 
				@coltype = NULL, 
				@type = NULL,
				@art_col = @indkey

			select @cmd = @cmd + @spacer + N'@c' + 
				convert(sysname, @this_col) + isnull(@postfix, N'') + 
				N' = ' + @column  
				
			select @spacer = N','
		end
		exec dbo.sp_MSflush_command @cmd output, 1, @indent
		select @indkey = @indkey + 1
	end
	exec dbo.sp_MSflush_command @cmd output, 1, @indent

END
go

grant execute on dbo.sp_MSscript_trigger_assignment to public

--------------------------------------------------------------------------------
--. sp_MSget_synctran_column
--------------------------------------------------------------------------------
if exists (select * from sysobjects
	where type = 'P '
			and name = 'sp_MSget_synctran_column')
	drop procedure sp_MSget_synctran_column

raiserror('Creating procedure sp_MSget_synctran_column', 0,1)
go
create procedure sp_MSget_synctran_column
(
	@ts_col sysname,
	@op_type char(3), -- 'ins, 'upd', 'del'
	@is_new	bit,
	@primary_key_bitmap varbinary(4000) = null,
	@colname sysname,
	@this_col int, -- position in source object
	@column nvarchar(4000) output,
	@from_proc bit = 0,
	@coltype sysname = NULL,
	@type	varchar(10) = NULL,
	@art_col int = NULL -- position in the partition.
)
as
begin
	declare @bytestr      nvarchar(10)
			,@bitstr       nvarchar(10)
			,@typed_null	  nvarchar(255)

	--
	-- if @art_col is not NULL then it means one of the following:
	-- 1) If we are scripting for triggers - then it means the subscriber
	-- 	table (destination table) was altered and column id do not match
	-- 	relative column order(as specified in PK bitmap or columns_updated()).
	--	The @art_col will represent the relative column order in the bitmap
	--	and @this_col will represent the actual column id
	--
	-- 2) If we are scripting for synctran procedures on publisher - then 
	--	@art_col represents the relative index of the column that is being
	--	replicated and @this_col represents the actual column id of the column
	--
	-- if @art_col is NULL - then we will set it to the value of @this_col
	--
	if (@art_col is NULL)
		select @art_col = @this_col
		
	select @typed_null = case when (@coltype is null) then N'NULL'
					else N'convert(' + @coltype + N', NULL)' end

	-- Optimization:
	-- If the column value is not needed, we set the corresponding
	-- param to null to reduce the network traffic. Here is the rule:

	-- For new values in update trigger,
	--	Set the param to column value or null depending on whether or
	--  or the column is updated.
	-- For old values 
	--	if ts col is replicated and the current column is not the ts col
	--	and the column is not in primary key, set the param to null
	-- For other cases
	--	set the param to column values.

	-- Called by proc
	if @type = 'pk_var'
	begin
		select @bytestr = convert( nvarchar, 1 + (@art_col-1) / 8 )
		select @bitstr =  convert( nvarchar, power(2, (@art_col-1) % 8 ) )

		select @column = N'case substring(@bitmap,' 
			+ @bytestr + N',1) & ' + @bitstr +  
			N' when ' + @bitstr + N' then ' + N'@c'+ convert( nvarchar, @this_col ) + 
			N' else ' + N'@c'+ convert( nvarchar, @this_col )  + N'_old end'
	end
	else if (@from_proc = 1)
	begin
		select @bytestr = convert( nvarchar, 1 + (@art_col-1) / 8 )
		select @bitstr =  convert( nvarchar, power(2, (@art_col-1) % 8 ) )

		select @column = N'case substring(@bitmap,' 
			+ @bytestr + N',1) & ' + @bitstr +  
			N' when ' + @bitstr + N' then ' + N'@c'+ convert( nvarchar, @this_col ) + 
			N' else [' + @colname + N'] end'
	end
	-- Called in trigger,
	else if (@is_new = 1) and (@op_type = 'upd')
	begin
		-- @bitmap is set using columns_updated() at the beginning
		-- of the trigger.
		select @bytestr = convert( nvarchar, 1 + (@art_col-1) / 8 )
		select @bitstr =  convert( nvarchar, power(2, (@art_col-1) % 8 ) )
		
		select @column = N'case substring(@bitmap,' + @bytestr + N',1) & ' + @bitstr +  
			N' when ' + @bitstr + N' then [' + @colname + N'] ' + 
			N' else ' + @typed_null 
			+' end'
	end
	else if ((@is_new = 0) and 
		(@ts_col is not null and @colname not in (@ts_col, N'msrepl_tran_version')) and
		(@primary_key_bitmap is not null and 
		(substring(@primary_key_bitmap, 1 + (@art_col-1) / 8 , 1) & power(2, (@art_col-1) % 8 )) = 0))
		select @column =  @typed_null
	else 
		select @column = N'[' + @colname  + N'] '
	
	-- Add a new line
	select @column = @column + N'
	'
end
go

--------------------------------------------------------------------------------
--. sp_MSscript_pkvar_assignment
--------------------------------------------------------------------------------
if exists (select * from sysobjects
	where type = 'P '
			and name = 'sp_MSscript_pkvar_assignment')
	drop procedure sp_MSscript_pkvar_assignment

raiserror('Creating procedure sp_MSscript_pkvar_assignment', 0,1)
go
create procedure sp_MSscript_pkvar_assignment
(
	@objid		  int,
	@columns      binary(32), 
	@indent       int = 0,
	@identity_col sysname = NULL, -- Not null value used by trigger scripting
	@ts_col       sysname = NULL,  -- Not null value used by trigger scripting
	@primary_key_bitmap varbinary(4000) = null
)
as
begin
	-- This stored procedure will assign the '_old' var to new var
	-- based on @bitmap. This is to avoid using case statement
	-- in the where clause in the synctran pub proc, which
	-- will cause a table scan.
	declare @cmd          nvarchar(4000)
		,@spacer       nvarchar(20)
		,@indkey       int
		,@indid        int
		,@this_col     int
		,@col          sysname
		,@qualname     nvarchar(512)
		,@column		  nvarchar(255)
		,@key	      sysname
		,@src_cols	  int
		,@total_col		int
		,@fcreatedcolmap	bit
		,@art_col int -- relative position of column
	declare @colmap table (relativeorder int identity(1,1), colid int)

	select @spacer = N'select '
		,@cmd = N''
		,@indkey = 1
		,@indid = 0
		,@fcreatedcolmap = 0
	exec sp_MSget_qualified_name @objid, @qualname OUTPUT
	select @src_cols = max(colid)
			,@total_col = count(colid)
		from syscolumns where id = @objid
	exec dbo.sp_MSpad_command @cmd output, @indent
	exec dbo.sp_MSflush_command @cmd output, 1, @indent

	if @primary_key_bitmap is null
	begin
		exec @indid = dbo.sp_MStable_has_unique_index @objid
		if @indid is null
		begin
			raiserror('Debug: Cannot find unique index', 16, -1)
			return (1)
		end
	end

	--
	-- check if column Id match relative column order
	-- for trigger scripting
	--
	if ((@total_col < @src_cols) and 
		(@columns is null) and (@primary_key_bitmap is not null))
	begin
		--
		-- this table may have altered columns, so when we need to 
		-- set a mapping for using the bitmaps properly as the bitmap
		-- always refers relative column order
		--
		insert into @colmap (colid)
			select colid from syscolumns where id = @objid order by colid
		if (@@error != 0)
		begin
			raiserror('Could not create column mapping', 16, -1)
			return (1)
		end
		select @fcreatedcolmap = 1
	end

	while (1=1)
	begin
		if @primary_key_bitmap is null 
		begin
			select @key = index_col(@qualname, @indid, @indkey)
			if @key is null
				break
			exec dbo.sp_MSget_col_position @objid, @columns, @key, @col output, @this_col output
		end
		else
		begin
			exec dbo.sp_MSget_map_position @primary_key_bitmap, @indkey, @col output, @this_col output
			if @this_col is null
				break

    			--
    			-- set the actual column id for this relative order in the PK bitmap if necessary
    			--
			if (@fcreatedcolmap = 1)
			begin
				select @art_col = @this_col
				select @this_col = colid
					,@col = 'c' + convert(sysname, colid) 
				from @colmap 
				where relativeorder = @art_col 
			end
			else
			begin
				select @art_col = NULL
			end

			-- Get column name
			exec dbo.sp_MSget_colinfo @objid, @this_col, @columns, 0, @key output
		end

		select @indkey = @indkey + 1

		if @key in (@identity_col, @ts_col)
			continue

		select @cmd = @spacer + N'@c' + convert(nvarchar(10), @this_col)

		-- Get the new values for the columns in primary key.
		exec dbo.sp_MSget_synctran_column 
			@ts_col = null,
			@op_type = null , -- 'ins, 'upd', 'del'
			@is_new = null,
			@primary_key_bitmap = null,
			@colname = null,
			@this_col = @this_col,
			@column = @column output,
			@from_proc = 0,
			@coltype = null,
			@type = 'pk_var',
			@art_col = @art_col
			select @cmd = @cmd + N' = ' + @column 
			select @spacer = ',
	'

		-- flush command if necessary
		exec dbo.sp_MSflush_command @cmd output, 1, @indent
	end

end
go
grant exec on dbo.sp_MSscript_pkvar_assignment to public

--------------------------------------------------------------------------------
--.	Common system objects (replcom.sql)
--------------------------------------------------------------------------------
if exists (select * from sysobjects
	where type = 'P'
        and name = 'sp_MSdrop_distributor_alerts_and_responses')
        drop procedure sp_MSdrop_distributor_alerts_and_responses
go

if exists (select * from sysobjects
	where type = 'P'
        and name = 'sp_adddistributiondb')
        drop procedure sp_adddistributiondb
go

if exists (select * from sysobjects
	where type = 'P '
	and name = 'sp_MScreate_replication_checkup_agent')
	drop procedure sp_MScreate_replication_checkup_agent
go

raiserror('Creating procedure sp_MSdrop_distributor_alerts_and_responses', 0,1)
go
create procedure sp_MSdrop_distributor_alerts_and_responses
as

    declare @name           nvarchar(100)
    declare @alert_id       int
    declare @retcode        int

    --
    -- Delete alerts and response jobs
    --

    -- Drop Replication Checkup Agent
    select @name = formatmessage(20533)
    IF EXISTS (SELECT * FROM msdb..sysjobs_view WHERE name = @name collate database_default and
        UPPER(originating_server) = UPPER(CONVERT(sysname, SERVERPROPERTY('ServerName'))))
    BEGIN
        EXEC @retcode = msdb.dbo.sp_delete_job  @job_name = @name
        IF @@ERROR <> 0 or @retcode <> 0
        BEGIN
            return (1)            
        END
    END

    -- Drop Reinit subscription response job
    set @name = formatmessage(20570)
    IF EXISTS (SELECT * FROM msdb..sysjobs_view WHERE name = @name collate database_default and
        UPPER(originating_server) = UPPER(CONVERT(sysname, SERVERPROPERTY('ServerName'))))
    BEGIN
        EXEC @retcode = msdb.dbo.sp_delete_job  @job_name = @name
        IF @@ERROR <> 0 or @retcode <> 0
        BEGIN
            return (1)            
        END
    END

    -- Drop the alerts
    set @alert_id = 14150 -- success alert
    set @name=formatmessage(20540)
    if exists (select * from msdb.dbo.sysalerts where message_id=@alert_id)
    begin
        select @name=name from msdb.dbo.sysalerts where message_id=@alert_id
        exec @retcode = msdb.dbo.sp_delete_alert @name
        if @@error <> 0 or @retcode <> 0
            return (1)            
    end
    
    set @alert_id = 14151 -- failure alert
    set @name = formatmessage(20536)
    if exists (select * from msdb.dbo.sysalerts where message_id=@alert_id)
    begin
        select @name=name from msdb.dbo.sysalerts where message_id=@alert_id
        exec @retcode = msdb.dbo.sp_delete_alert @name
        if @@error <> 0 or @retcode <> 0
            return (1)            
    end
    
    set @alert_id = 14152 -- retry alert
    set @name = formatmessage(20537)
    if exists (select * from msdb.dbo.sysalerts where message_id=@alert_id)
    begin
        select @name=name from msdb.dbo.sysalerts where message_id=@alert_id
        exec @retcode = msdb.dbo.sp_delete_alert @name
        if @@error <> 0 or @retcode <> 0
            return (1)            
    end

    set @alert_id = 14153 -- warnning alert
    set @name = formatmessage(20540)
    if exists (select * from msdb.dbo.sysalerts where message_id=@alert_id)
    begin
        select @name=name from msdb.dbo.sysalerts where message_id=@alert_id
        exec @retcode = msdb.dbo.sp_delete_alert @name
        if @@error <> 0 or @retcode <> 0
            return (1)            
    end

    -- Remove Validation Failure Alert
    set @alert_id = 20574 
    set @name = formatmessage(20565)
    if exists (select * from msdb.dbo.sysalerts where message_id=@alert_id)
    begin
        select @name=name from msdb.dbo.sysalerts where message_id=@alert_id
        exec @retcode = msdb.dbo.sp_delete_alert @name
        if @@error <> 0 or @retcode <> 0
            return (1)            
    end

    -- Remove Validation Sucess Alert
    set @alert_id = 20575
    set @name = formatmessage(20566)
    if exists (select * from msdb.dbo.sysalerts where message_id=@alert_id)
    begin
        select @name=name from msdb.dbo.sysalerts where message_id=@alert_id
        exec @retcode = msdb.dbo.sp_delete_alert @name
        if @@error <> 0 or @retcode <> 0
            return (1)            
    end
    
    -- Remove Reinitialized after Validation Failure
    set @alert_id = 20525 -- checksum alert
    set @name = formatmessage(20573)
    if exists (select * from msdb.dbo.sysalerts where message_id=@alert_id)
    begin
        select @name=name from msdb.dbo.sysalerts where message_id=@alert_id
        exec @retcode = msdb.dbo.sp_delete_alert @name
        if @@error <> 0 or @retcode <> 0
            return (1)            
    end

    -- Remove subscription reinitialized after validation failure
    set @alert_id = 20572 -- corresponding to formatmessage(20566),  
    set @name=formatmessage(20573)
    if exists (select * from msdb.dbo.sysalerts where message_id=@alert_id)
    begin
        select @name=name from msdb.dbo.sysalerts where message_id=@alert_id
        exec @retcode = msdb.dbo.sp_delete_alert @name
        if @@error <> 0 or @retcode <> 0
            return (1)            
    end

    -- Remove Shutdown request Alert
    set @alert_id = 20578 --  Custom agent shutdown message
    set @name=formatmessage(20578)
    if exists (select * from msdb.dbo.sysalerts where message_id=@alert_id)
    begin
        select @name=name from msdb.dbo.sysalerts where message_id=@alert_id
        exec @retcode = msdb.dbo.sp_delete_alert @name
        if @@error <> 0 or @retcode <> 0
            return (1)            
    end

GO

raiserror('Creating procedure sp_adddistributiondb', 0,1)
go

CREATE PROCEDURE sp_adddistributiondb (
    @database sysname,
    @data_folder nvarchar(255) = NULL,
    @data_file nvarchar(255) = NULL,            /* physical file name */
    @data_file_size int = 2,                    /* Default: 2MB */            
    @log_folder nvarchar(255) = NULL,
    @log_file nvarchar(255) = NULL,             /* physical file name */
    @log_file_size int = 0,
    @min_distretention int = 0,                 /* min distribution retention period in hours */
    @max_distretention int = 72,                /* max distribution retention period in hours */
    @history_retention int = 48,                /* history retention period in hours */
    @security_mode int = 0,                     /* distributor login security 0 standard 1 integrated */
    @login sysname = 'sa',                      /* standard login name */
    @password sysname = NULL,                   /* standard login password */
    @createmode int = 0,  /* 0: use create db for attach (recommended), 
                            1: create db or use existing but no attach (this is the old way), 
                            2: create for instdist and detach only */
	@from_scripting bit = 0
    ) AS

    SET NOCOUNT ON

    /*
    ** Declarations.
    */
    DECLARE @data_path nvarchar(512)
    DECLARE @log_path nvarchar(512)
    
    DECLARE @data_path_quoted_for_copy nvarchar(512)
    DECLARE @log_path_quoted_for_copy nvarchar(512)

    DECLARE @logical_data_file nvarchar(255)
    DECLARE @logical_log_file nvarchar(255)
    DECLARE @canneddbdata_file nvarchar(255)
    DECLARE @canneddblog_file nvarchar(255)
    DECLARE @filecopy_cmd nvarchar(255)
    DECLARE @file_exists bit
    DECLARE @data_file_preexists int
    DECLARE @log_file_preexists int
	DECLARE @osql_path nvarchar(260)
    DECLARE @osql_cmd nvarchar(1000)
	DECLARE @osql_for_nt int
    DECLARE @devnum int
    --DECLARE @num_pages int
    DECLARE @retcode int
    DECLARE @reg_key nvarchar(255)
    DECLARE @agentname nvarchar(100)
    DECLARE @command nvarchar (2048)
    DECLARE @distbit int
    DECLARE @install_path nvarchar(255)
    DECLARE @mssql_data_path nvarchar(255)
    DECLARE @on_clause nvarchar(512)
    DECLARE @logon_clause nvarchar(512)
    DECLARE @distproc nvarchar(255)
    DECLARE @major_version int
    DECLARE @db_exists bit
    DECLARE @trunc_log_bit int
    DECLARE @description nvarchar(100)
    DECLARE @category_name sysname
    DECLARE @createmode_attach int
    DECLARE @createmode_noattach int
    DECLARE @createmode_fordetach int

    --DECLARE @filegrowth nvarchar(10)
    DECLARE @data_file_size_str nvarchar(10)
    DECLARE @log_file_size_str nvarchar(10)
    DECLARE @platform_nt binary

    --DECLARE @max_datafile_size int
    --DECLARE @max_logfile_size int
    
	IF @password = N''
		select @password = NULL

    select @platform_nt = 0x1
    --select @filegrowth = N'512KB'

    -- on error, delete the data and log files only if they didn't pre-exist.
    -- by default, assume they pre-exist.
    select @data_file_preexists = 1
    select @log_file_preexists = 1
    select @file_exists = 0

    if (@data_file_size IS NULL) or (@data_file_size = 0)
        select @data_file_size_str = N'512KB'
    else
        select @data_file_size_str = convert(nvarchar(10), @data_file_size)

    if (@log_file_size IS NULL) or (@log_file_size = 0)
        select @log_file_size_str = N'512KB'
    else
        select @log_file_size_str = convert(nvarchar(10), @log_file_size)
    
    --if (@data_file_size > 16)
    --  select @max_datafile_size = @data_file_size
    --else
    --  select @max_datafile_size = 16
    
    --if (@log_file_size > 16)
    --  select @max_logfile_size = @log_file_size
    --else
    --  select @max_logfile_size = 16

    select @createmode_attach = 0, @createmode_noattach = 1, @createmode_fordetach = 2
    SELECT @trunc_log_bit = 8
    SELECT @distbit = 16

    if (@createmode <> @createmode_fordetach)
    begin
    
        /* 
        ** Check if replication components are installed on this server
        */
        exec @retcode = dbo.sp_MS_replication_installed
        if (@retcode <> 1)
        begin
            return (1)
        end
    
        /* 
        ** Check for invalid security modes
        */
        IF @security_mode < 0 OR @security_mode > 1
        BEGIN
            RAISERROR(14109, 16, -1)
            RETURN (1)
        END

        IF ( ( @platform_nt != platform() & @platform_nt ) and @security_mode = 1)
        BEGIN
            RAISERROR(21038, 16, -1)
            RETURN (1)
        END
    
        /* 
        ** Check for invalid retention values 
        */
        IF @min_distretention < 0 OR @max_distretention < 0 
        BEGIN
            RAISERROR(14106, 16, -1)
            RETURN (1)
        END
        IF @min_distretention > @max_distretention
        BEGIN
            RAISERROR(14107, 16, -1) 
            RETURN (1)
        END

        /*
        ** Check to make sure this is a distributor
        */
        IF NOT EXISTS (SELECT * FROM master..sysservers
              WHERE UPPER(datasource) = UPPER(@@SERVERNAME) collate database_default
                 AND srvstatus & 8 <> 0)
        BEGIN
            RAISERROR (14114, 16, -1, @@SERVERNAME)
            RETURN(1)
        END
    
        /*
        ** Check if database is already configured as a distributor database
        */
        IF EXISTS (SELECT * FROM msdb..MSdistributiondbs WHERE name = @database collate database_default)
        BEGIN
            RAISERROR (14119, 16, -1, @database)
            RETURN(1)
        END    
    end

    /* 
    ** Get path to osql client (TOOLS) directory
    */
    EXECUTE @retcode = master.dbo.sp_MSgettools_path @osql_path OUTPUT
    IF ( @retcode <> 0 ) or ( @@ERROR <> 0 ) or ( @osql_path is NULL ) or ( @osql_path = '' )
    BEGIN
        GOTO UNDO       
    END

    /* 
    ** Get path to version specific INSTALL directory
    */
	exec @retcode = master.dbo.sp_MSget_setup_paths
		@sql_path = @install_path output,
		@data_path = @mssql_data_path output
    IF @retcode <> 0 or @install_path is NULL or @install_path='' or @mssql_data_path = ''
    BEGIN
        GOTO UNDO       
    END

    IF @data_folder IS NULL or @data_folder = ''
        select @data_folder = @mssql_data_path + '\DATA'

    IF @log_folder IS NULL or @log_folder = ''
        select @log_folder = @mssql_data_path + '\DATA'

    IF @data_file IS NULL
        SELECT @data_file = @database + '.MDF'

    IF @log_file IS NULL
        SELECT @log_file = @database + '.LDF'

    if substring(@data_folder, len(@data_folder), 1) = '\'
    select @data_folder = substring (@data_folder, 1, len(@data_folder) -1)
    if substring(@log_folder, len(@log_folder), 1) = '\'
    select @log_folder = substring (@log_folder, 1, len(@log_folder) -1)

    SELECT @data_path = @data_folder + '\' + @data_file
    SELECT @log_path = @log_folder + '\' + @log_file

    SELECT @data_path_quoted_for_copy = '"' + @data_folder + '\' + @data_file + '"'
    SELECT @log_path_quoted_for_copy = '"' + @log_folder + '\' + @log_file + '"'

    select @logical_data_file = @database

    /* 
    ** Truncate the logical log file name back to 128 characters
    ** long so the 'CREATE DATABASE' statement won't complain.
    */
    /* LEN(@logical_log_file) = LEN(@database) + LEN('_log') and
       LEN(@logical_log_file) <= 128 implies 
       LEN(@database) <=124 */
    IF (LEN(@database) > 124)
        SELECT @logical_log_file = SUBSTRING(@database, 1, 124) + '_log'  
    ELSE 
        SELECT @logical_log_file = @database + '_log'

    if (@createmode = @createmode_attach)
    begin
        select @canneddbdata_file = @mssql_data_path + '\DATA\DISTMDL.MDF'
        select @canneddblog_file = @mssql_data_path + '\DATA\DISTMDL.LDF'

        exec dbo.sp_MSget_file_existence @canneddbdata_file, @file_exists OUTPUT
        if (@file_exists = 0)
        begin
            /* Fallback to mode where instdist.sql needs to be run */
            select @createmode = @createmode_noattach
        end

        exec dbo.sp_MSget_file_existence @canneddblog_file, @file_exists OUTPUT
        if (@file_exists = 0)
        begin
            /* Fallback to mode where instdist.sql needs to be run */
            select @createmode = @createmode_noattach
        end
    end

    /*
    ** Create the distributor database if it does not exist
    */
    IF NOT EXISTS (SELECT * from master..sysdatabases WHERE name = @database collate database_default) AND (@createmode <> @createmode_attach)
    BEGIN

        -- Note: Use system's default file growth.
        IF @logical_data_file IS NOT NULL AND NOT EXISTS (SELECT * FROM master..sysdevices WHERE name = @logical_data_file collate database_default)
        BEGIN
            SELECT @on_clause = ' ON (NAME =''' + @logical_data_file + ''',FILENAME=''' + REPLACE( @data_path, '''', '''''' ) + 
                ''', SIZE=' + @data_file_size_str + ', MAXSIZE = UNLIMITED)'
        END

        IF @logical_log_file IS NOT NULL AND NOT EXISTS (SELECT * FROM master..sysdevices WHERE name = @logical_log_file collate database_default)
        BEGIN
            SELECT @logon_clause = ' LOG ON (NAME =''' + @logical_log_file + ''',FILENAME=''' + REPLACE( @log_path, '''', '''''' ) + 
                ''', SIZE=' + @log_file_size_str + ', MAXSIZE= UNLIMITED)'          
        END

        /*
        ** Create distributor database
        */
        SELECT @command = 'USE master  CREATE DATABASE ' +  QUOTENAME(@database) + 
            + isnull(@on_clause, ' ') + isnull(@logon_clause, ' ')

        EXEC (@command)
        IF @@ERROR <> 0
            RETURN (1)
        SELECT @db_exists = 0
    END
    ELSE IF NOT EXISTS (SELECT * from master..sysdatabases WHERE name = @database collate database_default) AND (@createmode = @createmode_attach)
    BEGIN
    /* DO THE CREATE DATABASE FOR ATTACH STUFF */
        
        exec dbo.sp_MSget_file_existence @data_path, @data_file_preexists OUTPUT
        if (@data_file_preexists = 1)
        begin
            raiserror(5170, 16, -1, @data_path)
            return 1
        end
    
        SELECT @on_clause = ' ON (NAME = ''' + @logical_data_file + ''', FILENAME=''' + REPLACE( @data_path, '''', '''''' ) + ''')'
        
        exec dbo.sp_MSget_file_existence @log_path, @log_file_preexists OUTPUT
        if (@log_file_preexists = 1)
        begin
            raiserror(5170, 16, -1, @log_path)
            return 1
        end

        SELECT @logon_clause = ' LOG ON (NAME = ''' + @logical_log_file + ''', FILENAME=''' + REPLACE( @log_path, '''', '''''' ) + ''')'

        select @filecopy_cmd = 'copy "' + @canneddbdata_file + '" ' + @data_path_quoted_for_copy
        EXEC @retcode = master..xp_cmdshell @filecopy_cmd, NO_OUTPUT
        IF @retcode <> 0 OR @@ERROR <> 0
        BEGIN
            RAISERROR (14113, 16, -1, @filecopy_cmd, 'instdist.out')
            return (1)
        END

        select @filecopy_cmd = 'copy "' + @canneddblog_file + '" ' + @log_path_quoted_for_copy
        EXEC @retcode = master..xp_cmdshell @filecopy_cmd, NO_OUTPUT
        IF @retcode <> 0 OR @@ERROR <> 0
        BEGIN
            RAISERROR (14113, 16, -1, @filecopy_cmd, 'instdist.out')
            return (1)
        END

        /*
        ** Create distributor database
        */
        SELECT @command = 'USE master  CREATE DATABASE ' +  QUOTENAME(@database) + 
            + @on_clause + @logon_clause + ' FOR ATTACH'

        EXEC (@command)
        IF @@ERROR <> 0
        begin
            RETURN (1)
        end
        dbcc dbreindexall(@database, 240) with no_infomsgs

        SELECT @db_exists = 0
    END
    ELSE
    BEGIN
        SELECT @db_exists = 1
    END

    -- Must make the dist db owned by sa so that the sps in it can select from
    -- security cache tables in tempdb by owership chain rule.
    declare @retcode2 int
    select @retcode2 = 0
    select @distproc = QUOTENAME(@database) + '.dbo.sp_executesql'
    SELECT @command = 
        -- If the db is created by sa or from attach, sa is dbo already.
        -- sp_changedbowner will fail is the new owner is an user in the db already.
        ' if not exists (select * from sysusers where sid = 0x01) ' +
        ' exec @retcode2 = dbo.sp_changedbowner ''sa'''
    EXEC @retcode = @distproc @command, N'@retcode2 int output', @retcode2 output
    IF @retcode <> 0 or @retcode2 <> 0 or @@ERROR <> 0
    BEGIN
        GOTO UNDO
    END

    /* Set the database option truncate log on checkpoint & turn off autoclose which is default of win9x*/
    IF EXISTS (SELECT * FROM master.dbo.sysdatabases WHERE 
        name = @database collate database_default AND
        (status & @trunc_log_bit) = 0 )   -- if its not already marked
    BEGIN
        EXEC @retcode = dbo.sp_dboption @database, 'trunc. log on chkpt.', 'true'
        IF @retcode <> 0 OR @@ERROR <> 0
        BEGIN
            GOTO UNDO
        END
    END

    EXEC @retcode = dbo.sp_dboption @database, 'autoclose', 'false'
        IF @retcode <> 0 OR @@ERROR <> 0
        BEGIN
            GOTO UNDO
        END

    /*
    **
    ** Update sysdatabase category bit
    ** This is to prevent user from dropping the database.
    **/
    if (@createmode <> @createmode_fordetach)
    begin
        UPDATE master..sysdatabases SET category = category | @distbit WHERE name = @database collate database_default
        IF @@ERROR <> 0
        BEGIN
            GOTO UNDO
        END
    end

    /* 
    ** Install instdist.sql
    */

    if (@createmode <> @createmode_attach) OR (@db_exists = 1)
    begin
		if (( platform() & @platform_nt = @platform_nt ))
			select @osql_for_nt = 1
		else
			select @osql_for_nt = 0

        -- Always use integrated security on WINNT since @login passed-in is for remote 
        -- subscriber and may not have enough privilege to apply the script
        IF (@security_mode = 1 or @osql_for_nt = 1) AND NOT (@security_mode = 0 AND @createmode = 2)
		BEGIN
            SELECT @osql_cmd = '" "' + @osql_path + '\binn\osql" -E '  
			if serverproperty('instancename') is not null
				SELECT @osql_cmd = @osql_cmd + ' -S"' + @@SERVERNAME + '" '
		END
        ELSE
		BEGIN
        -- cannot specify -S w/ -E for local execution, SID does not map 
		if (@osql_for_nt = 1)
            SELECT @osql_cmd = '" "' + @osql_path + '\binn\osql" -U"' + @login + '" -P"' + 
                isnull(@password,'') + '" -S"' + @@SERVERNAME + '" '
		else
			SELECT @osql_cmd = '"'   + @osql_path + '\binn\osql" -U"' + @login + '" -P"' + 
                isnull(@password,'') + '" -S"' + @@SERVERNAME + '" '
		END
    
        select @osql_cmd = @osql_cmd + '-l60 -t60 '

        -- We must use -b option to make osql return error code !!
        SELECT @osql_cmd = @osql_cmd + 
            ' -d"' + @database + '" -b ' +
            ' -i' + '"' + @install_path + '\install\instdist.sql"' + 
            ' -o' + '"' + @install_path + '\install\instdist.out"'

		if (@osql_for_nt = 1)
		BEGIN
	        SELECT @osql_cmd = @osql_cmd + ' "'
		END
    
        EXEC @retcode = master..xp_cmdshell @osql_cmd
        IF @retcode <> 0 OR @@ERROR <> 0
        BEGIN
            RAISERROR (14113, 16, -1, @osql_cmd, 'instdist.out')
            GOTO UNDO       
        END
    end
    
    if (@createmode <> @createmode_fordetach)
    begin
        /* Set db_existed bit in MSrepl_version */
        IF @db_exists = 1
        BEGIN
            SELECT @distproc = 'UPDATE ' +
                @database + '..MSrepl_version SET db_existed = 0x1'
    
            EXEC(@distproc)
            IF @@ERROR <> 0
            BEGIN
                GOTO UNDO       
            END
        END

        DELETE msdb.dbo.MSdistributiondbs WHERE name = @database collate database_default
        IF @@ERROR <> 0
        BEGIN
            GOTO UNDO       
        END

        INSERT INTO msdb.dbo.MSdistributiondbs VALUES (
            @database, @min_distretention, @max_distretention, @history_retention
            )
        IF @@ERROR <> 0
        BEGIN
            GOTO UNDO       
        END

        -- This login need db_owner priviledge to call sps in distribution db
        declare @distributor_login sysname
        select @distributor_login = 'distributor_admin'

        select @command = quotename(@database) + '.dbo.sp_MSrepl_dbrole'
        exec @retcode = @command 'db_owner', @distributor_login, 'add'
        IF @@error <> 0 OR @retcode <> 0
            GOTO UNDO

		if @from_scripting = 0
		begin
			/*
			** Create the history cleanup agent.
			*/
			SELECT @agentname = formatmessage (20567, @database)
			SELECT @command =  'EXEC dbo.sp_MShistory_cleanup @history_retention = ' + 
				CONVERT(nvarchar(12), @history_retention)

			IF EXISTS (SELECT * FROM msdb..sysjobs_view WHERE name = @agentname collate database_default and
				UPPER(originating_server) = UPPER(CONVERT(sysname, SERVERPROPERTY('ServerName'))))
			BEGIN
				EXEC @retcode = msdb.dbo.sp_delete_job 
					@job_name = @agentname
				IF @@ERROR <> 0 or @retcode <> 0
				BEGIN
					GOTO UNDO
				END
			END

			set @description = formatmessage(20535)

			-- Get History Cleanup category name (assumes category_id = 12)
			select @category_name = name FROM msdb.dbo.syscategories where category_id = 12

			EXECUTE @retcode = dbo.sp_MSadd_repl_job @agentname,
			@subsystem = 'TSQL',
			@server = @@SERVERNAME,
			@databasename = @database,
			@description = @description,
			@freqtype = 4,    
			@freqsubtype = 4,         
			@freqsubinterval = 10,    /* Number of minutes between runs */ 
			@command = @command,
			@enabled = 1,
			@retryattempts = 0,
			@loghistcompletionlevel = 0,
			@category_name = @category_name
    
			IF @@ERROR <> 0 or @retcode <> 0
			BEGIN
				GOTO UNDO
			END

			/*
			** Create the distribution cleanup agent.
			*/
			SELECT @agentname = formatmessage (20568, @database)
			SELECT @command =  'EXEC dbo.sp_MSdistribution_cleanup @min_distretention = ' + 
				CONVERT(nvarchar(12), @min_distretention) + ', @max_distretention = ' +
				CONVERT(nvarchar(12), @max_distretention)

			IF EXISTS (SELECT * FROM msdb..sysjobs_view WHERE name = @agentname collate database_default and
				UPPER(originating_server) = UPPER(CONVERT(sysname, SERVERPROPERTY('ServerName'))))
			BEGIN
				EXEC @retcode = msdb.dbo.sp_delete_job 
					@job_name = @agentname
				IF @@ERROR <> 0 or @retcode <> 0
				BEGIN
					GOTO UNDO
				END
			END

			set @description = formatmessage(20541)
			-- Get Distribution Cleanup category name (assumes category_id = 11)
			select @category_name = name FROM msdb.dbo.syscategories where category_id = 11
    
			EXECUTE @retcode = msdb.dbo.sp_MSadd_repl_job @agentname,
			@subsystem = 'TSQL',
			@server = @@SERVERNAME,
			@databasename = @database,
			@description = @description,
			@freqtype = 4,    
			@freqsubtype = 4,         
			@freqsubinterval = 10,    /* Number of minutes between runs */ 
			@command = @command,
			@retryattempts = 0,
			@enabled = 0,
			@loghistcompletionlevel = 0,
			@category_name = @category_name,
			-- Start  and end time is 5 min off from the history cleanup, which use the default.
			@activestarttimeofday = 000500,
			@activeendtimeofday   = 000459

			IF @@ERROR <> 0 or @retcode <> 0
			BEGIN
				GOTO UNDO
			end
		end
    end
    else
    begin
        /*detach */
        dbcc detachdb(@database)
    end
    
    RETURN(0)

UNDO:

    IF @db_exists = 0
        EXECUTE dbo.sp_dropdistributiondb @database

    /* Need to do it since sp_dropdistributiondb will fail in some cases */
    UPDATE master..sysdatabases SET category = category & ~@distbit WHERE name = @database collate database_default
    
    DELETE msdb.dbo.MSdistributiondbs where name = @database collate database_default

    /* drop the database and ignore error */
    IF @db_exists = 0 AND
        EXISTS (SELECT * from master..sysdatabases WHERE name = @database collate database_default)
    BEGIN
        SELECT @command = 'USE master  DROP DATABASE ' +  QUOTENAME(@database) 
        EXEC (@command)
    END

    if (@createmode = @createmode_attach)
    begin
        if (@data_file_preexists = 0)
        begin
            select @command = 'del ' + @data_path_quoted_for_copy
            exec master..xp_cmdshell @command
            --ignore errors
        end
        if (@log_file_preexists = 0)
        begin
            select @command = 'del ' + @log_path_quoted_for_copy
            exec master..xp_cmdshell @command
            --ignore errors
        end
    end
        
    RETURN(1)        
GO
 
raiserror('Creating procedure sp_MScreate_replication_checkup_agent', 0,1)
go
create procedure sp_MScreate_replication_checkup_agent
@heartbeat_interval int = 10    -- minutes
as
    declare @command nvarchar(100)
    declare @retcode int
    declare @interval int
    declare @job_name nvarchar(100)
    declare @description nvarchar(100)
    declare @category_name sysname

    select @command = 'sp_replication_agent_checkup @heartbeat_interval = ' +
        convert(nvarchar(10), @heartbeat_interval)      
        
    -- Create job if it already exists
    select @job_name = formatmessage(20533)

    IF EXISTS (SELECT * FROM msdb..sysjobs_view WHERE name = @job_name collate database_default and
        UPPER(originating_server) = UPPER(CONVERT(sysname, SERVERPROPERTY('ServerName'))))
    BEGIN
        EXEC @retcode = msdb.dbo.sp_delete_job  @job_name = @job_name
        IF @@ERROR <> 0 or @retcode <> 0
        BEGIN
            return (1)            
        END
    END

    -- Create new job
    set @interval = convert(int, @heartbeat_interval)
    set @description = formatmessage(20534)

    -- Get Checkup category name (assumes category_id = 16)
    select @category_name = name FROM msdb.dbo.syscategories where category_id = 16
    EXECUTE @retcode = dbo.sp_MSadd_repl_job 
            @name = @job_name,
            @subsystem = 'TSQL', 
            @enabled = 1, 
            @command = @command,
            @description = @description,
            @freqtype = 4,
            @freqinterval = 1,
            @freqsubtype = 4,
            @freqsubinterval = @interval,
            @retryattempts = 0,
            @category_name = @category_name
    if @@ERROR <> 0 or @retcode <> 0
        return (1)
go

raiserror('Creating procedure sp_vupgrade_subpass', 0,1)
GO
create procedure sp_vupgrade_subpass
as
begin
	/* 
	 * Upgrade replication ftp_password and distributor_passwords
	 * in subscriber database.
	 *
	 * Setup version upgrade procedure call order:
	 *	sp_vupgrade_replication -> sp_vupgrade_subscription_databases -> sp_vupgrade_subpass
	*/
	begin transaction

	/*
	 * MSsubscription_properties
	*/
	if exists (select name from sysobjects where name='MSsubscription_properties')
	begin
		if not exists (select * from syscolumns where id = Object_Id('MSsubscription_properties') and name = 'ftp_password' and length = '1048')
		begin
			declare @dbname sysname
			declare @cmptlevel tinyint
			set @dbname = db_name()
			select @cmptlevel = cmptlevel from master..sysdatabases where name = @dbname collate database_default
			if @cmptlevel < 70
			begin
                                raiserror (15048, -1, -1, 70, 70, 70, 80)
			end
			else
			begin
			        /*
				 * alter ftp_password column from sysname to nvarchar(524)
				*/
				exec( 'alter table MSsubscription_properties alter column ftp_password nvarchar(524)' )
				exec( 'alter table MSsubscription_properties alter column distributor_password nvarchar(524)' )
				exec( 'alter table MSsubscription_properties alter column publisher_password nvarchar(524)' )
				exec( 'alter table MSsubscription_properties alter column dts_package_password nvarchar(524)' )
			end

			/*
			 * convert all the ftp_passwords to new encryption
			 */
			declare @ftp_password nvarchar(524)
			declare @distributor_password nvarchar(524)
			declare @publisher_password nvarchar(524)
			declare @dts_package_password nvarchar(524)
			declare @retcode int

			declare cur_MSsubscription_properties CURSOR LOCAL FORWARD_ONLY for 
			select ftp_password, distributor_password, publisher_password, dts_package_password
			from MSsubscription_properties
			for update of ftp_password, distributor_password, publisher_password, dts_package_password
		
			open cur_MSsubscription_properties
			fetch next from cur_MSsubscription_properties into @ftp_password, @distributor_password, @publisher_password, @dts_package_password
			while ( @@fetch_status <> -1 )
			begin
				EXEC @retcode = master.dbo.xp_repl_convert_encrypt @ftp_password OUTPUT
				IF @@error <> 0 OR @retcode <> 0
				begin
					rollback transaction
					return 1
				end
      				
				EXEC @retcode = master.dbo.xp_repl_convert_encrypt @distributor_password OUTPUT
				IF @@error <> 0 OR @retcode <> 0
				begin
					rollback transaction
					return 1
				end
	
				EXEC @retcode = master.dbo.xp_repl_convert_encrypt @publisher_password OUTPUT
				IF @@error <> 0 OR @retcode <> 0
				begin
					rollback transaction
					return 1
				end

				EXEC @retcode = master.dbo.xp_repl_convert_encrypt @dts_package_password OUTPUT
				IF @@error <> 0 OR @retcode <> 0
				begin
					rollback transaction
					return 1
				end
       	
				update MSsubscription_properties
				set ftp_password=@ftp_password, distributor_password=@distributor_password, publisher_password=@publisher_password, dts_package_password=@dts_package_password
				where current of cur_MSsubscription_properties
		
			        fetch next from cur_MSsubscription_properties into @ftp_password, @distributor_password, @publisher_password, @dts_package_password
			end
		end
	end
	commit transaction
end
GO
exec sp_MS_marksystemobject 'sp_vupgrade_subpass'
go

raiserror('Creating procedure sp_vupgrade_replmsdb', 0,1)
go
create procedure sp_vupgrade_replmsdb 
as
begin
/* 
 * Process schema and metadata changes specific to a msdb database. Updates datatype
 * mappings for heterogeneous replication.
 *
 * Setup version upgrade procedure call order:
 *	sp_vupgrade_replication -> sp_vupgrade_replmsdb (only called at distributors)
*/

	set nocount on 

	declare @retcode int
			,@profile_id int
			,@table_name sysname
			,@profile_name nvarchar(100)
			,@profile_desc nvarchar(100)

	-- raiserror('sp_vupgrade_replmsdb', 0,1)
	
	-- Drop and regenerate agent parameters and associated values from system profiles.
	select @profile_id = 1
	while (@profile_id < 8)
	begin

		exec @retcode = dbo.sp_drop_agent_parameter @profile_id
	    if (@retcode = 1)
	        return (1)

		exec @retcode = dbo.sp_generate_agent_parameter @profile_id
	    if (@retcode = 1)
	        return (1)

		select @profile_id = @profile_id + 1

	end
	
	declare hUserProfile CURSOR LOCAL FAST_FORWARD FOR
        select distinct profile_id from msdb..MSagent_profiles where profile_id >= 8 for read only   
	open hUserProfile 
	fetch hUserProfile into @profile_id

	while @@fetch_status <> -1
    	begin
		exec @retcode = dbo.sp_drop_agent_parameter @profile_id, @parameter_name = '-ReadBatchThreshold'
		if (@retcode = 1)
		begin
			close hUserProfile 
			deallocate hUserProfile 
	        	return (1)
		end

		fetch hUserProfile into @profile_id
    	end    
    	close hUserProfile 
    	deallocate hUserProfile 

	--
	-- Add 8.0 agent profiles
	--

    /* 
	** Distribution agent : Synchronization Manager Profile
	*/
    select @profile_id = NULL
		,@profile_name = formatmessage(20550) -- Dist SyncMgr Profile
		,@profile_desc = formatmessage(20551)
	select @profile_id = profile_id from msdb..MSagent_profiles 
		where agent_type = 3 and profile_name = @profile_name
	if (@profile_id is null)
	begin
		--
		-- Add profile
		--
		select @profile_id = NULL

		exec @retcode = dbo.sp_add_agent_profile
				@profile_id = @profile_id OUT,
				@profile_name = @profile_name,
				@agent_type = 3,   -- 1-Snapshot, 2-Logreader, 3-Distribution, 4-Merge
				@profile_type = 0,   -- 0-System, 1-Custom 
				@description = @profile_desc,
				@default = 0
		if (@retcode = 1 or @@ERROR <> 0)
			return (1)
	end
	else
	begin
		--
		-- Profile exists - drop the parameters for regeneration
		--
		exec @retcode = dbo.sp_drop_agent_parameter @profile_id
		if (@retcode = 1)
			return (1)
	end
    exec @retcode = dbo.sp_generate_agent_parameter 
		@profile_id = 10,
		@real_profile_id = @profile_id
    if (@retcode = 1 or @@ERROR <> 0)
		return (1)


	-- Queue default profile
	select @profile_id = NULL
	select @profile_id = profile_id from msdb..MSagent_profiles 
		where agent_type = 9 and def_profile = 1
	if (@profile_id is null)
	begin
		--
		-- Add profile
		--
		select @profile_id = NULL
				,@profile_name = formatmessage(20545) -- Default QueueReader Profile
				,@profile_desc = formatmessage(20589)

		exec @retcode = dbo.sp_add_agent_profile
			@profile_id = @profile_id OUT,
			@profile_name = @profile_name,
			@agent_type = 9,
			@profile_type = 0, 
			@description = @profile_desc,
			@default = 1
		if (@retcode = 1 or @@ERROR <> 0)
			return (1)
	end
	else
	begin
		--
		-- Profile exists - drop the parameters for regeneration
		--
		exec @retcode = dbo.sp_drop_agent_parameter @profile_id
		if (@retcode = 1)
			return (1)
	end
	exec @retcode = dbo.sp_generate_agent_parameter 
		@profile_id = 11,
		@real_profile_id = @profile_id
	if (@retcode = 1 or @@ERROR <> 0)
		return (1)

	--
	-- Add 'skip data consistency error' profile
	--
	select @profile_id = NULL
		,@profile_name = formatmessage(20599) -- Default Distribution Profile
		,@profile_desc = formatmessage(20600)
	select @profile_id = profile_id from msdb..MSagent_profiles 
		where agent_type = 3 and profile_name = @profile_name
	if (@profile_id is null)
	begin
		--
		-- Add profile
		--
		select @profile_id = NULL

		exec @retcode = dbo.sp_add_agent_profile
				@profile_id = @profile_id OUT,
				@profile_name = @profile_name,
				@agent_type = 3,   -- 1-Snapshot, 2-Logreader, 3-Distribution, 4-Merge
				@profile_type = 0,   -- 0-System, 1-Custom 
				@description = @profile_desc,
				@default = 0
		if (@retcode = 1 or @@ERROR <> 0)
			return (1)
	end
	else
	begin
		--
		-- Profile exists - drop the parameters for regeneration
		--
		exec @retcode = dbo.sp_drop_agent_parameter @profile_id
		if (@retcode = 1)
			return (1)
	end
	exec @retcode = dbo.sp_generate_agent_parameter 
		@profile_id = 14,
		@real_profile_id = @profile_id
	if (@retcode = 1 or @@ERROR <> 0)
		return (1)
		
    /* 
	** Merge agent : Non default profile for disconnected scenarios ( unreliable link ) 
	*/
    set @profile_id = NULL
	set @profile_name = formatmessage(20548) -- Non-Default Merge Profile
    set @profile_desc = formatmessage(20549)

	select @profile_id = profile_id from msdb..MSagent_profiles where agent_type = 4 and profile_name = @profile_name
	if (@profile_id is null)
	begin
	    exec @retcode = dbo.sp_add_agent_profile
            @profile_id = @profile_id OUT,
            @profile_name = @profile_name,
            @agent_type = 4,   -- 1-Snapshot, 2-Logreader, 3-Distribution, 4-Merge
            @profile_type = 0,   -- 0-System, 1-Custom 
            @description = @profile_desc,
            @default = 0
	end
	else
	begin
		--
		-- Profile exists - drop the parameters for regeneration
		--
		exec @retcode = dbo.sp_drop_agent_parameter @profile_id
		if (@retcode = 1)
			return (1)
	end

	exec @retcode = dbo.sp_generate_agent_parameter 7, @profile_id
	if (@retcode = 1 or @@ERROR <> 0)
		return (1)

    /* 
	** Merge agent : Non default profile for verbose histroy
	*/
    set @profile_id = NULL
    set @profile_name = formatmessage(20546) -- Verbose Merge Profile
    set @profile_desc = formatmessage(20547)

	select @profile_id = profile_id from msdb..MSagent_profiles where agent_type = 4 and profile_name = @profile_name
	if (@profile_id is null)
	begin
	    exec @retcode = dbo.sp_add_agent_profile
            @profile_id = @profile_id OUT,
            @profile_name = @profile_name,
            @agent_type = 4,   -- 1-Snapshot, 2-Logreader, 3-Distribution, 4-Merge
            @profile_type = 0,   -- 0-System, 1-Custom 
            @description = @profile_desc,
            @default = 0
	end
	else
	begin
		--
		-- Profile exists - drop the parameters for regeneration
		--
		exec @retcode = dbo.sp_drop_agent_parameter @profile_id
		if (@retcode = 1)
			return (1)
	end

	exec @retcode = dbo.sp_generate_agent_parameter 8, @profile_id
	if (@retcode = 1 or @@ERROR <> 0)
		return (1)

    /* 
	** Merge agent : Synchronization Manager Profile
	*/
    set @profile_id = NULL
    set @profile_name = formatmessage(20550) -- SyncMgr Profile
    set @profile_desc = formatmessage(20551)

	select @profile_id = profile_id from msdb..MSagent_profiles where agent_type = 4 and profile_name = @profile_name
	if (@profile_id is null)
	begin
	    exec @retcode = dbo.sp_add_agent_profile
            @profile_id = @profile_id OUT,
            @profile_name = @profile_name,
            @agent_type = 4,   -- 1-Snapshot, 2-Logreader, 3-Distribution, 4-Merge
            @profile_type = 0,   -- 0-System, 1-Custom 
            @description = @profile_desc,
            @default = 0
	end
	else
	begin
		--
		-- Profile exists - drop the parameters for regeneration
		--
		exec @retcode = dbo.sp_drop_agent_parameter @profile_id
		if (@retcode = 1)
			return (1)
	end

	exec @retcode = dbo.sp_generate_agent_parameter 9, @profile_id
	if (@retcode = 1 or @@ERROR <> 0)
		return (1)

	 /* 
	** Merge agent : Rowcount Validation profile  
	*/
    set @profile_id = NULL
    set @profile_name = formatmessage(21308) -- Rowcount Validation Profile
    set @profile_desc = formatmessage(21309) -- Rowcount Validation Profile Description

	select @profile_id = profile_id from msdb..MSagent_profiles where agent_type = 4 and profile_name = @profile_name
	if (@profile_id is null)
	begin
	    exec @retcode = dbo.sp_add_agent_profile
            @profile_id = @profile_id OUT,
            @profile_name = @profile_name,
            @agent_type = 4,   -- 1-Snapshot, 2-Logreader, 3-Distribution, 4-Merge
            @profile_type = 0,   -- 0-System, 1-Custom 
            @description = @profile_desc,
            @default = 0
	end
	else
	begin
		--
		-- Profile exists - drop the parameters for regeneration
		--
		exec @retcode = dbo.sp_drop_agent_parameter @profile_id
		if (@retcode = 1)
			return (1)
	end

	exec @retcode = dbo.sp_generate_agent_parameter 12, @profile_id
	if (@retcode = 1 or @@ERROR <> 0)
		return (1)

    /* 
	** Merge agent : Rowcount & Checksum Validation profile  
	*/
    set @profile_id = NULL
    set @profile_name = formatmessage(21310) -- Rowcount & Checksum Validation Profile
    set @profile_desc = formatmessage(21311) -- Rowcount & Checksum Validation Profile Description
	
	select @profile_id = profile_id from msdb..MSagent_profiles where agent_type = 4 and profile_name = @profile_name
	if (@profile_id is null)
	begin
	    exec @retcode = dbo.sp_add_agent_profile
            @profile_id = @profile_id OUT,
            @profile_name = @profile_name,
            @agent_type = 4,   -- 1-Snapshot, 2-Logreader, 3-Distribution, 4-Merge
            @profile_type = 0,   -- 0-System, 1-Custom 
            @description = @profile_desc,
            @default = 0
	end
	else
	begin
		--
		-- Profile exists - drop the parameters for regeneration
		--
		exec @retcode = dbo.sp_drop_agent_parameter @profile_id
		if (@retcode = 1)
			return (1)
	end

	exec @retcode = dbo.sp_generate_agent_parameter 13, @profile_id
	if (@retcode = 1 or @@ERROR <> 0)
		return (1)

	/* 
	** Merge agent : High volume server-to-server profile
	*/
    set @profile_id = NULL
    set @profile_name = formatmessage(20616) -- High volume server-to-server profile
    set @profile_desc = formatmessage(20617) -- High volume server-to-server profile Description

	select @profile_id = profile_id from msdb..MSagent_profiles where agent_type = 4 and profile_name = @profile_name
	if (@profile_id is null)
	begin
	    exec @retcode = dbo.sp_add_agent_profile
            @profile_id = @profile_id OUT,
            @profile_name = @profile_name,
            @agent_type = 4,   -- 1-Snapshot, 2-Logreader, 3-Distribution, 4-Merge
            @profile_type = 0,   -- 0-System, 1-Custom 
            @description = @profile_desc,
            @default = 0
	end
	else
	begin
		--
		-- Profile exists - drop the parameters for regeneration
		--
		exec @retcode = dbo.sp_drop_agent_parameter @profile_id
		if (@retcode = 1)
			return (1)
	end

	exec @retcode = dbo.sp_generate_agent_parameter 15, @profile_id
	if (@retcode = 1 or @@ERROR <> 0)
		return (1)

	-- Add MSdatatype_mappings table and default mappings
    if not exists( select * from msdb..sysobjects where name = 'MSdatatype_mappings' 
        and xtype = 'U')
    begin
        create table msdb.dbo.MSdatatype_mappings 
        (
        dbms_name           sysname NOT NULL,
        sql_type            sysname NOT NULL,
        dest_type           sysname NOT NULL,
        dest_prec           int     NOT NULL,
        dest_create_params  int     NOT NULL,
        dest_nullable       bit     NOT NULL
        )

		-- MS Jet
        exec dbo.sp_add_datatype_mapping 'MS Jet', 'binary' , 'binary', 255, 4, 1
        exec dbo.sp_add_datatype_mapping 'MS Jet', 'varbinary' , 'varbinary', 255, 4, 1
        exec dbo.sp_add_datatype_mapping 'MS Jet', 'binary' , 'image', 1073741824, 0, 1
        exec dbo.sp_add_datatype_mapping 'MS Jet', 'varbinary' , 'image', 1073741824, 0, 1
		exec dbo.sp_add_datatype_mapping 'MS Jet', 'sql_variant' , 'longtext', 1073741824, 0, 1
        exec dbo.sp_add_datatype_mapping 'MS Jet', 'varchar' , 'varchar', 255, 4, 1
        exec dbo.sp_add_datatype_mapping 'MS Jet', 'varchar' , 'longtext', 1073741824, 0, 1
        exec dbo.sp_add_datatype_mapping 'MS Jet', 'nchar' , 'nchar', 255, 4, 1
        exec dbo.sp_add_datatype_mapping 'MS Jet', 'nchar' , 'longtext', 1073741824, 0, 1
        exec dbo.sp_add_datatype_mapping 'MS Jet', 'char' , 'char', 255, 4, 1
        exec dbo.sp_add_datatype_mapping 'MS Jet', 'char' , 'longtext', 1073741824, 0, 1
        exec dbo.sp_add_datatype_mapping 'MS Jet', 'nvarchar' , 'nchar varying', 255, 4, 1
        exec dbo.sp_add_datatype_mapping 'MS Jet', 'nvarchar' , 'longtext', 1073741824, 0, 1
        exec dbo.sp_add_datatype_mapping 'MS Jet', 'datetime' , 'datetime', 255, 0, 1
        exec dbo.sp_add_datatype_mapping 'MS Jet', 'smalldatetime' , 'datetime', 255, 0, 1
        exec dbo.sp_add_datatype_mapping 'MS Jet', 'decimal' , 'decimal', 255, 3, 1
        exec dbo.sp_add_datatype_mapping 'MS Jet', 'numeric' , 'decimal', 255, 3, 1
        exec dbo.sp_add_datatype_mapping 'MS Jet', 'float' , 'float', 255, 0, 1
        exec dbo.sp_add_datatype_mapping 'MS Jet', 'real' , 'real', 255, 0, 1
        exec dbo.sp_add_datatype_mapping 'MS Jet', 'bigint' , 'decimal', 255, 0, 1
        exec dbo.sp_add_datatype_mapping 'MS Jet', 'int' , 'int', 255, 0, 1
        exec dbo.sp_add_datatype_mapping 'MS Jet', 'smallint' , 'smallint', 255, 0, 1
        exec dbo.sp_add_datatype_mapping 'MS Jet', 'tinyint' , 'byte', 255, 0, 1
        exec dbo.sp_add_datatype_mapping 'MS Jet', 'money' , 'currency', 255, 0, 1
        exec dbo.sp_add_datatype_mapping 'MS Jet', 'smallmoney' , 'currency', 255, 0, 1
        exec dbo.sp_add_datatype_mapping 'MS Jet', 'bit' , 'bit', 255, 0, 1
        exec dbo.sp_add_datatype_mapping 'MS Jet', 'sysname' , 'nchar varying', 255, 4, 1
        exec dbo.sp_add_datatype_mapping 'MS Jet', 'timestamp' , 'binary', 255, 4, 1
        exec dbo.sp_add_datatype_mapping 'MS Jet', 'uniqueidentifier' , 'guid', 255, 0, 1
        exec dbo.sp_add_datatype_mapping 'MS Jet', 'text' , 'longtext', 1073741824, 0, 1
        exec dbo.sp_add_datatype_mapping 'MS Jet', 'ntext' , 'longtext', 1073741824, 0, 1
        exec dbo.sp_add_datatype_mapping 'MS Jet', 'image' , 'image', 1073741824, 0, 1

		-- Oracle
        exec dbo.sp_add_datatype_mapping 'Oracle', 'binary' , 'raw', 255, 4, 1
        exec dbo.sp_add_datatype_mapping 'Oracle', 'varbinary' , 'raw', 255, 4, 1
        exec dbo.sp_add_datatype_mapping 'Oracle', 'binary' , 'long raw', 2147483647, 0, 1
        exec dbo.sp_add_datatype_mapping 'Oracle', 'varbinary' , 'long raw', 2147483647, 0, 1
		exec dbo.sp_add_datatype_mapping 'Oracle', 'sql_variant' , 'long', 2147483647, 0, 1
        --exec dbo.sp_add_datatype_mapping 'Oracle', 'varchar' , 'char', 255, 4, 1
        exec dbo.sp_add_datatype_mapping 'Oracle', 'varchar' , 'varchar2', 2000, 4, 1
        exec dbo.sp_add_datatype_mapping 'Oracle', 'varchar' , 'long', 2147483647, 0, 1
        exec dbo.sp_add_datatype_mapping 'Oracle', 'nchar' , 'char', 255, 4, 1
        exec dbo.sp_add_datatype_mapping 'Oracle', 'nchar' , 'varchar2', 2000, 4, 1
        exec dbo.sp_add_datatype_mapping 'Oracle', 'nchar' , 'long', 2147483647, 0, 1
        exec dbo.sp_add_datatype_mapping 'Oracle', 'char' , 'char', 255, 4, 1
        exec dbo.sp_add_datatype_mapping 'Oracle', 'char' , 'varchar2', 2000, 4, 1
        exec dbo.sp_add_datatype_mapping 'Oracle', 'char' , 'long', 2147483647, 0, 1
        --exec dbo.sp_add_datatype_mapping 'Oracle', 'nvarchar' , 'char', 255, 4, 1
        exec dbo.sp_add_datatype_mapping 'Oracle', 'nvarchar' , 'varchar2', 2000, 4, 1
        exec dbo.sp_add_datatype_mapping 'Oracle', 'nvarchar' , 'long', 2147483647, 0, 1
        exec dbo.sp_add_datatype_mapping 'Oracle', 'datetime' , 'date', 255, 0, 1
        exec dbo.sp_add_datatype_mapping 'Oracle', 'smalldatetime' , 'date', 255, 0, 1
        exec dbo.sp_add_datatype_mapping 'Oracle', 'decimal' , 'number', 255, 3, 1
        exec dbo.sp_add_datatype_mapping 'Oracle', 'numeric' , 'number', 255, 3, 1
        exec dbo.sp_add_datatype_mapping 'Oracle', 'float' , 'float', 255, 0, 1
        exec dbo.sp_add_datatype_mapping 'Oracle', 'real' , 'float', 255, 0, 1
        exec dbo.sp_add_datatype_mapping 'Oracle', 'bigint' , 'number', 255, 3, 1
        exec dbo.sp_add_datatype_mapping 'Oracle', 'int' , 'number', 255, 3, 1
        exec dbo.sp_add_datatype_mapping 'Oracle', 'smallint' , 'number', 255, 3, 1
        exec dbo.sp_add_datatype_mapping 'Oracle', 'tinyint' , 'number', 255, 3, 1
        exec dbo.sp_add_datatype_mapping 'Oracle', 'money' , 'number', 255, 3, 1
        exec dbo.sp_add_datatype_mapping 'Oracle', 'smallmoney' , 'number', 255, 3, 1
        exec dbo.sp_add_datatype_mapping 'Oracle', 'bit' , 'number', 255, 3, 1
        exec dbo.sp_add_datatype_mapping 'Oracle', 'sysname' , 'char', 255, 4, 1
        exec dbo.sp_add_datatype_mapping 'Oracle', 'timestamp' , 'raw', 255, 4, 1
        exec dbo.sp_add_datatype_mapping 'Oracle', 'uniqueidentifier' , 'char', 255, 4, 1
        exec dbo.sp_add_datatype_mapping 'Oracle', 'text' , 'long', 2147483647, 0, 1
        exec dbo.sp_add_datatype_mapping 'Oracle', 'ntext' , 'long', 2147483647, 0, 1
        exec dbo.sp_add_datatype_mapping 'Oracle', 'image' , 'long raw', 2147483647, 0, 1

		-- MS SSCE
		exec dbo.sp_add_datatype_mapping 'MS SSCE', 'binary' , 'binary', 255, 4, 1
		exec dbo.sp_add_datatype_mapping 'MS SSCE', 'varbinary' , 'varbinary', 255, 4, 1
		exec dbo.sp_add_datatype_mapping 'MS SSCE', 'binary' , 'image', 1073741824, 0, 1
		exec dbo.sp_add_datatype_mapping 'MS SSCE', 'varbinary' , 'image', 1073741824, 0, 1
		exec dbo.sp_add_datatype_mapping 'MS SSCE', 'sql_variant' , 'ntext', 1073741824, 0, 1
		exec dbo.sp_add_datatype_mapping 'MS SSCE', 'varchar' , 'national char varying', 255, 4, 1
		exec dbo.sp_add_datatype_mapping 'MS SSCE', 'varchar' , 'ntext', 1073741824, 0, 1
		exec dbo.sp_add_datatype_mapping 'MS SSCE', 'nchar' , 'nchar', 255, 4, 1
		exec dbo.sp_add_datatype_mapping 'MS SSCE', 'nchar' , 'ntext', 1073741824, 0, 1
		exec dbo.sp_add_datatype_mapping 'MS SSCE', 'char' , 'nchar', 255, 4, 1
		exec dbo.sp_add_datatype_mapping 'MS SSCE', 'char' , 'ntext', 1073741824, 0, 1
		exec dbo.sp_add_datatype_mapping 'MS SSCE', 'nvarchar' , 'national char varying', 255, 4, 1
		exec dbo.sp_add_datatype_mapping 'MS SSCE', 'nvarchar' , 'ntext', 1073741824, 0, 1
		exec dbo.sp_add_datatype_mapping 'MS SSCE', 'datetime' , 'datetime', 255, 0, 1
		exec dbo.sp_add_datatype_mapping 'MS SSCE', 'smalldatetime' , 'datetime', 255, 0, 1
		exec dbo.sp_add_datatype_mapping 'MS SSCE', 'decimal' , 'numeric', 255, 3, 1
		exec dbo.sp_add_datatype_mapping 'MS SSCE', 'numeric' , 'numeric', 255, 3, 1
		exec dbo.sp_add_datatype_mapping 'MS SSCE', 'float' , 'float', 255, 0, 1
		exec dbo.sp_add_datatype_mapping 'MS SSCE', 'real' , 'real', 255, 0, 1
		exec dbo.sp_add_datatype_mapping 'MS SSCE', 'bigint' , 'bigint', 255, 0, 1
		exec dbo.sp_add_datatype_mapping 'MS SSCE', 'int' , 'int', 255, 0, 1
		exec dbo.sp_add_datatype_mapping 'MS SSCE', 'smallint' , 'smallint', 255, 0, 1
		exec dbo.sp_add_datatype_mapping 'MS SSCE', 'tinyint' , 'tinyint', 255, 0, 1
		exec dbo.sp_add_datatype_mapping 'MS SSCE', 'money' , 'money', 255, 0, 1
		exec dbo.sp_add_datatype_mapping 'MS SSCE', 'smallmoney' , 'money', 255, 0, 1
		exec dbo.sp_add_datatype_mapping 'MS SSCE', 'bit' , 'bit', 255, 0, 1
		exec dbo.sp_add_datatype_mapping 'MS SSCE', 'sysname' , 'national char varying', 255, 4, 1
		exec dbo.sp_add_datatype_mapping 'MS SSCE', 'timestamp' , 'binary', 255, 4, 1
		exec dbo.sp_add_datatype_mapping 'MS SSCE', 'uniqueidentifier' , 'uniqueidentifier', 255, 0, 1
		exec dbo.sp_add_datatype_mapping 'MS SSCE', 'text' , 'ntext', 1073741824, 0, 1
		exec dbo.sp_add_datatype_mapping 'MS SSCE', 'ntext' , 'ntext', 1073741824, 0, 1
		exec dbo.sp_add_datatype_mapping 'MS SSCE', 'image' , 'image', 1073741824, 0, 1

		--DB2/400
		exec dbo.sp_add_datatype_mapping 'DB2/400', 'bit', 'SMALLINT', 1,  0, 1
		exec dbo.sp_add_datatype_mapping 'DB2/400', 'tinyint', 'SMALLINT', 1, 0, 1
		exec dbo.sp_add_datatype_mapping 'DB2/400', 'smallint', 'SMALLINT', 5, 0, 1
		exec dbo.sp_add_datatype_mapping 'DB2/400', 'int', 'INT', 10, 0, 1

		exec dbo.sp_add_datatype_mapping 'DB2/400', 'char', 'CHAR', 8000, 4, 1
		exec dbo.sp_add_datatype_mapping 'DB2/400', 'varchar', 'VARCHAR', 8000, 4, 1
		exec dbo.sp_add_datatype_mapping 'DB2/400', 'smalldatetime', 'TIMESTAMP', 26, 0, 1
		exec dbo.sp_add_datatype_mapping 'DB2/400', 'datetime', 'TIMESTAMP', 26, 0, 1

		exec dbo.sp_add_datatype_mapping 'DB2/400', 'real', 'REAL', 24, 0, 1
		exec dbo.sp_add_datatype_mapping 'DB2/400', 'decimal', 'DECIMAL', 31, 3, 1
		exec dbo.sp_add_datatype_mapping 'DB2/400', 'double precision', 'DOUBLE', 53, 0, 1
		exec dbo.sp_add_datatype_mapping 'DB2/400', 'float', 'FLOAT', 53, 0, 1
		exec dbo.sp_add_datatype_mapping 'DB2/400', 'numeric', 'NUMERIC', 31, 3, 1

		exec dbo.sp_add_datatype_mapping 'DB2/400', 'smallmoney', 'DECIMAL', 10, 3, 1
		exec dbo.sp_add_datatype_mapping 'DB2/400', 'money', 'DECIMAL', 19, 3, 1

		exec dbo.sp_add_datatype_mapping 'DB2/400', 'varbinary', 'VARCHAR () FOR BIT DATA', 8000, 4, 1
		exec dbo.sp_add_datatype_mapping 'DB2/400', 'binary', 'CHAR () FOR BIT DATA', 8000, 4, 1

		exec dbo.sp_add_datatype_mapping 'DB2/400', 'timestamp', 'CHAR () FOR BIT DATA', 8, 4, 1
		exec dbo.sp_add_datatype_mapping 'DB2/400', 'uniqueidentifier', 'CHAR', 38, 4, 1
		exec dbo.sp_add_datatype_mapping 'DB2/400', 'image', 'VARCHAR () FOR BIT DATA', 32739, 4, 1
		exec dbo.sp_add_datatype_mapping 'DB2/400', 'text', 'VARCHAR', 32739, 4, 1

		--DB2/MVS
		exec dbo.sp_add_datatype_mapping 'DB2/MVS', 'bit', 'SMALLINT', 1,  0, 1
		exec dbo.sp_add_datatype_mapping 'DB2/MVS', 'tinyint', 'SMALLINT', 1, 0, 1
		exec dbo.sp_add_datatype_mapping 'DB2/MVS', 'smallint', 'SMALLINT', 5, 0, 1
		exec dbo.sp_add_datatype_mapping 'DB2/MVS', 'int', 'INT', 10, 0, 1

		exec dbo.sp_add_datatype_mapping 'DB2/MVS', 'char', 'CHAR', 254, 4, 1
		exec dbo.sp_add_datatype_mapping 'DB2/MVS', 'varchar', 'VARCHAR', 4045, 4, 1
		exec dbo.sp_add_datatype_mapping 'DB2/MVS', 'char', 'VARCHAR', 4045, 4, 1
		exec dbo.sp_add_datatype_mapping 'DB2/MVS', 'smalldatetime', 'TIMESTAMP', 26, 0, 1
		exec dbo.sp_add_datatype_mapping 'DB2/MVS', 'datetime', 'TIMESTAMP', 26, 0, 1

		exec dbo.sp_add_datatype_mapping 'DB2/MVS', 'real', 'REAL', 24, 0, 1
		exec dbo.sp_add_datatype_mapping 'DB2/MVS', 'decimal', 'DECIMAL', 31, 3, 1
		exec dbo.sp_add_datatype_mapping 'DB2/MVS', 'double precision', 'DOUBLE', 53, 0, 1
		exec dbo.sp_add_datatype_mapping 'DB2/MVS', 'float', 'FLOAT', 53, 0, 1
		exec dbo.sp_add_datatype_mapping 'DB2/MVS', 'numeric', 'NUMERIC', 31, 3, 1

		exec dbo.sp_add_datatype_mapping 'DB2/MVS', 'smallmoney', 'DECIMAL', 10, 3, 1
		exec dbo.sp_add_datatype_mapping 'DB2/MVS', 'money', 'DECIMAL', 19, 3, 1

		exec dbo.sp_add_datatype_mapping 'DB2/MVS', 'varbinary', 'VARCHAR () FOR BIT DATA', 4045, 4, 1
		exec dbo.sp_add_datatype_mapping 'DB2/MVS', 'binary', 'CHAR () FOR BIT DATA', 254, 4, 1

		exec dbo.sp_add_datatype_mapping 'DB2/MVS', 'timestamp', 'CHAR () FOR BIT DATA', 8, 4, 1
		exec dbo.sp_add_datatype_mapping 'DB2/MVS', 'uniqueidentifier', 'CHAR', 38, 4, 1
		exec dbo.sp_add_datatype_mapping 'DB2/MVS', 'image', 'VARCHAR () FOR BIT DATA', 4045, 4, 1
		exec dbo.sp_add_datatype_mapping 'DB2/MVS', 'text', 'VARCHAR', 4045, 4, 1

		--DB2/NT
		exec dbo.sp_add_datatype_mapping 'DB2/NT', 'bit', 'SMALLINT', 1,  0, 1
		exec dbo.sp_add_datatype_mapping 'DB2/NT', 'tinyint', 'SMALLINT', 1, 0, 1
		exec dbo.sp_add_datatype_mapping 'DB2/NT', 'smallint', 'SMALLINT', 5, 0, 1
		exec dbo.sp_add_datatype_mapping 'DB2/NT', 'int', 'INT', 10, 0, 1

		exec dbo.sp_add_datatype_mapping 'DB2/NT', 'char', 'CHAR', 254, 4, 1
		exec dbo.sp_add_datatype_mapping 'DB2/NT', 'varchar', 'VARCHAR', 4000, 4, 1
		exec dbo.sp_add_datatype_mapping 'DB2/NT', 'char', 'VARCHAR', 4000, 4, 1
		exec dbo.sp_add_datatype_mapping 'DB2/NT', 'smalldatetime', 'TIMESTAMP', 26, 0, 1
		exec dbo.sp_add_datatype_mapping 'DB2/NT', 'datetime', 'TIMESTAMP', 26, 0, 1

		exec dbo.sp_add_datatype_mapping 'DB2/NT', 'real', 'REAL', 24, 0, 1
		exec dbo.sp_add_datatype_mapping 'DB2/NT', 'decimal', 'DECIMAL', 31, 3, 1
		exec dbo.sp_add_datatype_mapping 'DB2/NT', 'double precision', 'DOUBLE', 53, 0, 1
		exec dbo.sp_add_datatype_mapping 'DB2/NT', 'float', 'FLOAT', 53, 0, 1
		exec dbo.sp_add_datatype_mapping 'DB2/NT', 'numeric', 'NUMERIC', 31, 3, 1

		exec dbo.sp_add_datatype_mapping 'DB2/NT', 'smallmoney', 'DECIMAL', 10, 3, 1
		exec dbo.sp_add_datatype_mapping 'DB2/NT', 'money', 'DECIMAL', 19, 3, 1

		exec dbo.sp_add_datatype_mapping 'DB2/NT', 'varbinary', 'VARCHAR () FOR BIT DATA', 4000, 4, 1
		exec dbo.sp_add_datatype_mapping 'DB2/NT', 'binary', 'CHAR () FOR BIT DATA', 254, 4, 1

		exec dbo.sp_add_datatype_mapping 'DB2/NT', 'timestamp', 'CHAR () FOR BIT DATA', 8, 4, 1
		exec dbo.sp_add_datatype_mapping 'DB2/NT', 'uniqueidentifier', 'CHAR', 38, 4, 1
		exec dbo.sp_add_datatype_mapping 'DB2/NT', 'image', 'VARCHAR () FOR BIT DATA', 4000, 4, 1
		exec dbo.sp_add_datatype_mapping 'DB2/NT', 'text', 'VARCHAR', 4000, 4, 1


		--DB2/6000
		exec dbo.sp_add_datatype_mapping 'DB2/6000', 'bit', 'SMALLINT', 1,  0, 1
		exec dbo.sp_add_datatype_mapping 'DB2/6000', 'tinyint', 'SMALLINT', 1, 0, 1
		exec dbo.sp_add_datatype_mapping 'DB2/6000', 'smallint', 'SMALLINT', 5, 0, 1
		exec dbo.sp_add_datatype_mapping 'DB2/6000', 'int', 'INT', 10, 0, 1

		exec dbo.sp_add_datatype_mapping 'DB2/6000', 'char', 'CHAR', 254, 4, 1
		exec dbo.sp_add_datatype_mapping 'DB2/6000', 'varchar', 'VARCHAR', 4000, 4, 1
		exec dbo.sp_add_datatype_mapping 'DB2/6000', 'char', 'VARCHAR', 4000, 4, 1
		exec dbo.sp_add_datatype_mapping 'DB2/6000', 'smalldatetime', 'TIMESTAMP', 26, 0, 1
		exec dbo.sp_add_datatype_mapping 'DB2/6000', 'datetime', 'TIMESTAMP', 26, 0, 1

		exec dbo.sp_add_datatype_mapping 'DB2/6000', 'real', 'REAL', 24, 0, 1
		exec dbo.sp_add_datatype_mapping 'DB2/6000', 'decimal', 'DECIMAL', 31, 3, 1
		exec dbo.sp_add_datatype_mapping 'DB2/6000', 'double precision', 'DOUBLE', 53, 0, 1
		exec dbo.sp_add_datatype_mapping 'DB2/6000', 'float', 'FLOAT', 53, 0, 1
		exec dbo.sp_add_datatype_mapping 'DB2/6000', 'numeric', 'NUMERIC', 31, 3, 1

		exec dbo.sp_add_datatype_mapping 'DB2/6000', 'smallmoney', 'DECIMAL', 10, 3, 1
		exec dbo.sp_add_datatype_mapping 'DB2/6000', 'money', 'DECIMAL', 19, 3, 1

		exec dbo.sp_add_datatype_mapping 'DB2/6000', 'varbinary', 'VARCHAR () FOR BIT DATA', 4000, 4, 1
		exec dbo.sp_add_datatype_mapping 'DB2/6000', 'binary', 'CHAR () FOR BIT DATA', 254, 4, 1

		exec dbo.sp_add_datatype_mapping 'DB2/6000', 'timestamp', 'CHAR () FOR BIT DATA', 8, 4, 1
		exec dbo.sp_add_datatype_mapping 'DB2/6000', 'uniqueidentifier', 'CHAR', 38, 4, 1
		exec dbo.sp_add_datatype_mapping 'DB2/6000', 'image', 'VARCHAR () FOR BIT DATA', 4000, 4, 1
		exec dbo.sp_add_datatype_mapping 'DB2/6000', 'text', 'VARCHAR', 4000, 4, 1

    end

	/*
	 * New indexes added starting with 7.0 sp1
	*/

	--	MSdistpublishers
	select @table_name = N'MSdistpublishers'
	IF EXISTS ( SELECT * FROM msdb.dbo.sysobjects WHERE name = 'MSdistpublishers' ) 
	BEGIN
		IF EXISTS ( SELECT name
			FROM msdb.dbo.MSdistpublishers
			GROUP BY name 
			HAVING COUNT(*) > 1 )
			RAISERROR (21203, 10, 19, @table_name)
		ELSE
			IF NOT EXISTS ( SELECT * FROM msdb.dbo.sysindexes WHERE name = 'uc1MSdistpublishers' AND
				id = OBJECT_ID('msdb.dbo.MSdistpublishers') )
				CREATE UNIQUE CLUSTERED INDEX uc1MSdistpublishers ON msdb.dbo.MSdistpublishers(name)

	END
	
	--	MSdistributiondbs
	SELECT @table_name = N'MSdistributiondbs'
	IF EXISTS ( SELECT * FROM msdb.dbo.sysobjects WHERE name = 'MSdistributiondbs' )
	BEGIN
		IF EXISTS ( SELECT name
			FROM msdb.dbo.MSdistributiondbs
			GROUP BY name 
			HAVING COUNT(*) > 1 )
			RAISERROR (21203, 10, 20, @table_name)			
		ELSE				
			IF NOT EXISTS ( SELECT * FROM msdb.dbo.sysindexes WHERE name = 'uc1MSdistributiondbs' AND
				id = OBJECT_ID('msdb.dbo.MSdistributiondbs') )
				CREATE UNIQUE CLUSTERED INDEX uc1MSdistributiondbs ON msdb.dbo.MSdistributiondbs(name)
	END
	
	--	MSdistributor
	SELECT @table_name = N'MSdistributor'
	IF EXISTS ( SELECT * FROM msdb.dbo.sysobjects WHERE name = 'MSdistributor' )
	BEGIN
		IF EXISTS ( SELECT property
			FROM msdb.dbo.MSdistributor
			GROUP BY property 
			HAVING COUNT(*) > 1 )
			RAISERROR (21203, 10, 21, @table_name)			
		ELSE					
			IF NOT EXISTS ( SELECT * FROM msdb.dbo.sysindexes WHERE name = 'uc1MSdistributor' AND
				id = OBJECT_ID('msdb.dbo.MSdistributor') )
				CREATE UNIQUE CLUSTERED INDEX uc1MSdistributor ON msdb.dbo.MSdistributor(property)
	END	

	/* 
	 * Upgrade replication passwords in msdb database.
	*/
	begin transaction
	/*
	 * MSdistpublishers
	*/
	if exists (select name from msdb.dbo.sysobjects where name='MSdistpublishers')
	begin
		if not exists (select * from msdb.dbo.syscolumns where id = Object_Id('msdb.dbo.MSdistpublishers') and name = 'password' and length = '1048')
		begin
			/*
			 * alter password column from sysname to nvarchar(524)
			*/

			alter table msdb.dbo.MSdistpublishers alter column password nvarchar(524)
		end

		/*
		 * convert all the passwords to new encryption
		 */
		declare @password nvarchar(524)
		declare cur_MSdistpublishers CURSOR LOCAL FORWARD_ONLY for 
			select password
			from msdb.dbo.MSdistpublishers
			for update of password
			
		open cur_MSdistpublishers
		fetch next from cur_MSdistpublishers into @password
		while ( @@fetch_status <> -1 )
		begin
			EXEC @retcode = master.dbo.xp_repl_convert_encrypt @password OUTPUT
			IF @@error <> 0 OR @retcode <> 0
			begin
				rollback transaction
				return 1
			end

			update msdb.dbo.MSdistpublishers
			set password=@password
			where current of cur_MSdistpublishers

			fetch next from cur_MSdistpublishers into @password
		end
	end
	commit transaction

	return (0)
end
go
exec dbo.sp_MS_marksystemobject sp_vupgrade_replmsdb
go

raiserror('Creating procedure sp_vupgrade_subscription_databases', 0,1)
GO
create procedure sp_vupgrade_subscription_databases
as
begin
/* 
 * Process schema and metadata changes common to all databases. This proc loops
 * through each database and upgrades MSsubscription_properties, transactional tables
 * and merge tables.
 *
 * Setup version upgrade procedure call order:
 *	sp_vupgrade_replication -> sp_vupgrade_subscription_databases
*/
	set nocount on

	-- raiserror('sp_vupgrade_subscription_databases', 0,1) with nowait
	declare @dbname nvarchar(270), @has_dbaccess bit

	declare current_db CURSOR LOCAL FAST_FORWARD for 
		select N'[' + replace(name, N']', N']]') + N']', has_dbaccess(name) from master..sysdatabases 
			WHERE name <> N'master' collate database_default
			AND name <> N'tempdb' collate database_default
			AND name <> N'msdb' collate database_default
		for read only

	-- Note: dbname is quoted!
	open current_db
	fetch current_db into @dbname, @has_dbaccess
	while ( @@fetch_status <> -1 )
	begin

		-- upgrade repl tables in sub dbs if needed - sub dbs are not marked with subscribed status 
		-- skip any database in an offline state and write warning to upgrade log
		if ( @has_dbaccess = 1 )
		begin
			--
			-- NOTE : there are several things to process here
			-- for each upgrade - all these steps may NOT be necessary
			-- and should be commented/uncommented out as required
			-- 
			-- Current setting for SQL 2000 SP1 upgrade
			--
			raiserror( 21377, 0, 1, @dbname) with nowait
			-- exec ('use '+ @dbname + ' exec dbo.sp_vupgrade_MSsubscription_properties')
			exec ('use '+ @dbname + ' exec dbo.sp_vupgrade_subscription_tables')
			exec ('use '+ @dbname + ' exec dbo.sp_vupgrade_mergetables')
			-- exec ('use '+ @dbname + ' exec dbo.sp_vupgrade_subpass')
		end
		else
		begin
			raiserror( 21373, 10, 1, @dbname) with nowait
		end

		fetch next from current_db into @dbname, @has_dbaccess
	end
	close current_db
	deallocate current_db
end
go

raiserror('Creating procedure sp_vupgrade_publisher', 0,1)
go
create procedure sp_vupgrade_publisher @ver_old int, @ver_retention int
as
begin
/* 
 * Process schema and metadata changes specific to a publisher and dispatch calls to sp_vupgrade_publisherdb
 * for any databases marked with the publishing bits.
 *
 * Setup version upgrade procedure call order:
 *	sp_vupgrade_replication -> sp_vupgrade_publisher
*/

	set nocount on

	declare @proc_name			nvarchar(350)
	declare @publication		sysname
	declare @upgraded			bit 
	declare @retcode 			int
	declare @publisher_db		nvarchar(270)
	declare @agentname			sysname
	declare @has_dbaccess		bit

	-- raiserror('sp_vupgrade_publisher', 0,1)

	/*
	 * Expired subscription cleanup agent name needs set to localized string (message 20569) and 
	 * jobstep set to correct procedure name based on name change between SQL7.0 and SQL7.5
	*/
	set @agentname = formatmessage(20569)  
	
	update msdb.dbo.sysjobs
		set name = @agentname
		from msdb.dbo.sysjobs, msdb.dbo.sysjobsteps as s
		where msdb.dbo.sysjobs.job_id = s.job_id
		and 
		( upper(s.command) = upper(N'EXEC sp_MScleanup_subscription') 
		or upper(s.command) = upper(N'EXEC dbo.sp_MScleanup_subscription') )

	update msdb.dbo.sysjobsteps 
		set  command = N'EXEC dbo.sp_expired_subscription_cleanup' 
		where upper(command) = upper(N'EXEC sp_MScleanup_subscription')
		or upper(command) = upper(N'EXEC dbo.sp_MScleanup_subscription')
			
	/*
	 * Process schema and metadata changes for each publishing database on the publisher.
	 * 
	 * Transactional replication system tables at the publisher are updated by sp_vupgrade_publisherdb.
	 * Most merge system tables exist in both the publishing and subscribing databases; merge schema 
	 * and metadata changes are processed by a separate pass over all databases in sp_vupgrade_mergetables.
	*/
	declare DC cursor local FAST_FORWARD for select distinct N'[' + replace(name, N']', N']]') + N']', has_dbaccess(name) from master..sysdatabases 
	--	where ((category & 4) = 4) or ((category & 1) = 1)
			WHERE name <> N'master' collate database_default
			AND name <> N'tempdb' collate database_default
			AND name <> N'msdb' collate database_default
		for read only
	open DC
	fetch DC into @publisher_db, @has_dbaccess
	while (@@fetch_status <> -1)
	begin
		-- upgrade repl tables in publishing dbs if needed
		-- skip any database in an offline state and write warning to upgrade log
		if ( @has_dbaccess = 1 )
		begin
			raiserror( 21375, 10, 1, @publisher_db) with nowait

			select @proc_name = @publisher_db + '.dbo.sp_vupgrade_publisherdb'
			exec @retcode = @proc_name 
				@ver_old = @ver_old,
				@ver_retention = @ver_retention
			if @retcode<>0 or @@ERROR<>0
			begin
				close DC
				deallocate DC
				return (1)
			end
		end
		else
		begin 
			-- report informational message stating database is not accessible.
			raiserror( 21376, 10, 1, @publisher_db) with nowait
		end

		fetch DC into @publisher_db, @has_dbaccess

	end
	close DC
	deallocate DC
		
    /*
     * We need to mark sp_MScleanupmergepublisher as a startup procedure
     * if there are any databases enabled for merge replication.
     */
    if exists (select * from sysdatabases where (category & 4) <> 0)
    begin
        exec dbo.sp_procoption 'sp_MScleanupmergepublisher', 'startup', 'true'
    end

end
go

exec dbo.sp_MS_marksystemobject sp_vupgrade_publisher
go

raiserror('Creating procedure sp_vupgrade_replication', 0,1)
GO
create procedure sp_vupgrade_replication ( @login sysname = N'sa', @password sysname = N'', @ver_old int = 517, @force_remove tinyint = 0, @security_mode bit = 0 )
as
begin
/* 
 * Dispatcher proc for handling schema and metadata changes during setup initiated version upgrade 
 * for replication components. Any schema changes to replication system tables may require modifications 
 * here to maintain upgrade path. All modifications called in these procs are within "if exists" checks
 * making them repeatable for debugging and to support incremental upgrades (e.g. Beta 1 to Beta 2 to RTM)
 * 
 * If server is a distributor, run new instdist.sql against all distribution dbs.
 *
 * This proc gets called by setup at the end of an install over an existing version.
*/

	set nocount on 

	declare @dbname sysname
	declare @has_dbaccess bit
	declare @install_path nvarchar(255)
	declare @osql_path nvarchar(260)
	declare @osql_cmd nvarchar(512)
	declare @osql_for_nt int
	declare @retcode int
    declare @platform_nt binary
	declare @db_distbit int
	declare @ver_min 			int

	select @db_distbit = 16
    select @platform_nt = 0x1

	-- raiserror('sp_vupgrade_replication', 0,1) with nowait

	/*
	 * obsolete check; ver check was to prevent repl upgrade from
	 * versions prior to SQL7.0 Beta 3; check is removed by setting @ver_min = -1
	*/
	select @ver_min= -1 -- change if later wish to support a minimum upgrade version
	if ( @ver_old < @ver_min ) or ( @force_remove = 1 )
		exec dbo.sp_removesrvreplication
	else
	begin

		/* 
		 * always need to run instdist.sql to update distribution databases on a distributor
		 * setup must restart in non-single user mode so we can shell out to run instdist.sql scripts
		*/
		if exists( select * from master..sysdatabases where category & @db_distbit = @db_distbit )
		begin

			/* 
			** Get installation path -- osql client (TOOLS) path
			*/
			EXECUTE @retcode = master.dbo.sp_MSgettools_path @osql_path OUTPUT
			IF ( @@ERROR <> 0 ) OR ( @retcode <> 0 ) or ( @osql_path is NULL ) or ( @osql_path = '' )
			BEGIN
				RETURN (1)
			END

			/* 
			** Get installation path -- instance specific (INSTALL) directory
			*/
			exec @retcode = master.dbo.sp_MSget_setup_paths
				@sql_path = @install_path output
			IF @@ERROR<> 0 OR @retcode <> 0 or @install_path is NULL or @install_path=N''
			BEGIN
				RETURN (1)
			END

			-- Set the flag for platform
			if (( platform() & @platform_nt = @platform_nt ))
				select @osql_for_nt = 1
			else
				select @osql_for_nt = 0

			declare cur_distdb CURSOR LOCAL FAST_FORWARD for 
				select name, has_dbaccess(name) from master..sysdatabases 
					where category & @db_distbit = @db_distbit
				for read only
			
			open cur_distdb
			fetch cur_distdb into @dbname, @has_dbaccess
			while ( @@fetch_status <> -1 )
			begin

				-- if distribution database is available upgrade it; if offline error out
				if ( @has_dbaccess = 1 )
				begin
					raiserror( 21374, 0, 1, @dbname) with nowait

					/*
					 * Format osql cmd line appropriate for security mode and OS to run instdist.sql against
					 * each distribution database. Instdist.sql will recompile procs and will also do some
					 * schema and metadata upgrade of changed replication tables. Query timeout increased to
					 * make enough time for alter tables in instdist.sql run for upgrade to complete.
					*/
					if ( @osql_for_nt = 1 )
						select @osql_cmd = N'" "'
					else
						select @osql_cmd = N' "'
					
					-- Cannot specify -S w/ -E for local execution, SID does not map (nofix)
					if ( @security_mode = 1 and @osql_for_nt = 1 )
					begin
						select @osql_cmd = @osql_cmd + @osql_path + '\binn\osql" -E '
						if serverproperty('instancename') is not null
							select @osql_cmd = @osql_cmd + ' -S"' + @@SERVERNAME + '" '
					end
					else
						select @osql_cmd = @osql_cmd + @osql_path + '\binn\osql" -U' + isnull(@login, N'sa') + ' -P' + isnull(@password, N'') + ' -S"' + @@SERVERNAME + '" '

					select @osql_cmd = @osql_cmd + ' -l30 -t120 '
					select @osql_cmd = @osql_cmd + ' -b ' + ' -d' + @dbname
					select @osql_cmd = @osql_cmd +	' -i' + '"' + @install_path + '\install\instdist.sql"' + 
													' -o' + '"' + @install_path + '\install\instdist.out"'			

					if (@osql_for_nt = 1)
						select @osql_cmd = @osql_cmd + ' "'

	 				exec @retcode = master..xp_cmdshell @osql_cmd
					if @retcode <> 0 or @@error <> 0
					begin
						raiserror (14113, 16, -1, @osql_cmd, 'instdist.out')
					end

					/*
					 * Process schema and metadata changes for each distribution database
					*/

					select @dbname = quotename(@dbname)
					exec ('use '+ @dbname + ' exec dbo.sp_vupgrade_distdb')
					if @@error <> 0
						return(1)
				end
				else
				begin
					/* Report informational message stating distribution
					** database is not accessible.
					*/
					raiserror( 21378, 10, 1, @dbname) with nowait
				end
				
				fetch next from cur_distdb into @dbname, @has_dbaccess
			end
			close cur_distdb
			deallocate cur_distdb
		end

	
		-- Update subscription database schema
		exec @retcode = dbo.sp_vupgrade_subscription_databases
		if @retcode <> 0 or @@error <> 0
			return (1)


	end

	return (0)

end
go

exec dbo.sp_MS_marksystemobject sp_vupgrade_replication
go

--------------------------------------------------------------------------------
--.	Transaction replication system objects (repltran.sql)
--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
--. sp_addarticle
--------------------------------------------------------------------------------
if exists (select * from sysobjects
    where type = 'P '
      and name = 'sp_addarticle')
    drop procedure sp_addarticle
    
print ''
print 'Creating procedure sp_addarticle'
go
CREATE PROCEDURE sp_addarticle
    @publication        sysname,                /* publication name */
    @article            sysname,                /* article name */
    @source_table       nvarchar (386) = NULL,  /* table name */
    @destination_table  sysname = NULL,	        /* destination table name */
    @vertical_partition nchar(5) = 'false',     /* vertical partition */
    @type               sysname = NULL,	        /* article type */
    @filter	            nvarchar (386) = NULL,  /* stored procedure used to filter table */
    @sync_object        nvarchar (386) = NULL,  /* view or table used for synchronization */
    @ins_cmd            nvarchar (255) = NULL,  /* insert format string */
    @del_cmd            nvarchar (255) = NULL,  /* delete format string */
    @upd_cmd            nvarchar (255) = NULL,  /* update format string */
    @creation_script    nvarchar (127) = NULL,  /* article schema script */
    @description        nvarchar (255) = NULL,  /* article description */
    @pre_creation_cmd   nvarchar(10) = 'drop',  /* 'none', 'drop', 'delete', 'truncate' */
    @filter_clause      ntext    = NULL,        /* where clause */
    @schema_option      varbinary(8) = NULL,
	@destination_owner  sysname = NULL,
	@status	            tinyint = 16,           /* Default: binary command format */
	@source_owner       sysname = NULL,         /* NULL for 6.5 users, not NULL for 7.0 users */
	@sync_object_owner  sysname = NULL,         /* NULL for 6.5 users, not NULL for 7.0 users */
	@filter_owner       sysname = NULL,	        /* NULL for 6.5 users, not NULL for 7.0 users */
	@source_object      sysname = NULL,	        /* if @source_table is NULL, this parameter can not be NULL */
    @artid              int = NULL OUTPUT,       /* article id of the new article  */
    @auto_identity_range	nvarchar(5)	= 'FALSE',	/* set it to false for now - change is possible */
    @pub_identity_range		bigint	= NULL,
    @identity_range			bigint = NULL,
    @threshold				int	= NULL,
	@force_invalidate_snapshot bit = 0	/* Force invalidate existing snapshot */
    AS

    SET NOCOUNT ON

    /*
    ** Declarations.
    */	
    DECLARE @bak_source sysname
	DECLARE @num_columns int
    DECLARE @accessid smallint
    DECLARE @db sysname
    DECLARE @filterid int
    DECLARE @object sysname
    DECLARE @owner sysname
    DECLARE @pubid int
    DECLARE @publish_bit smallint
    DECLARE @retcode int
    DECLARE @site sysname
    DECLARE @syncid int
    DECLARE @tabid int
    DECLARE @typeid smallint
    DECLARE @pkkey sysname
    DECLARE @i int
    DECLARE @indid int
    DECLARE @precmdid int
    DECLARE @object_type nchar(2)
    DECLARE @push tinyint
    DECLARE @dbname sysname
    DECLARE @cmd nvarchar(255)
    DECLARE @fHasPk int
    DECLARE @no_sync tinyint
    DECLARE @immediate_sync bit
    DECLARE @is_filter_in_use int
    DECLARE @distributor sysname
    DECLARE @distribdb sysname
    DECLARE @distproc nvarchar (255)
    DECLARE @sync_method tinyint
    -- SyncTran
    DECLARE @autogen_sync_procs_id int
	DECLARE @custom_proc_name nvarchar(255)
	DECLARE @guid varbinary(16)
	declare @allow_sync_tran bit
    DECLARE @repl_freq int
	declare @allow_queued_tran bit
	declare @allow_dts bit
	declare @merge_pub_object_bit  int
	declare @valid_ins_cmd nvarchar(255)
			,@valid_upd_cmd nvarchar(255)
			,@valid_del_cmd nvarchar(255)
			,@MSrepl_tran_version_datatype sysname
			,@colid int
	declare @backward_comp_level int
	declare @schema_option_int int
	select @backward_comp_level = 10 -- default to sphinx
	
	select @merge_pub_object_bit 	= 128
    SELECT @push = 0
    SELECT @dbname = DB_NAME()

    SELECT @publish_bit = 1

    SELECT @no_sync = 2 /* no sync type in syssubscriptions */
    /*
    ** Security Check.
    */
	exec @retcode = dbo.sp_MSreplcheck_publish
	if @@ERROR <> 0 or @retcode <> 0
		return(1)

    /*
    ** Padding out the specified schema option to the left
    */
    select @schema_option = fn_replprepadbinary8(@schema_option)

    /*
    ** Parameter Check: @article.
    ** The @article name cannot be NULL and must conform to the rules
    ** for identifiers.
    */

    IF @article IS NULL
        BEGIN
            RAISERROR (14043, 16, -1, '@article')
            RETURN (1)
        END

	exec @retcode = dbo.sp_MSreplcheck_name @article
    if @@ERROR <> 0 or @retcode <> 0
        return(1)

    if LOWER(@article) = 'all'
        BEGIN
            RAISERROR (14032, 16, -1, '@article')
            RETURN (1)
        END

    /*
    ** Parameter Check: @publication.
    ** The @publication name cannot be NULL and must conform to the rules
    ** for identifiers.
    */

    IF @publication IS NULL
    BEGIN
        RAISERROR (14043, 16, -1, '@publication')
        RETURN (1)
    END

    EXECUTE @retcode = dbo.sp_validname @publication

    IF @retcode <> 0
    RETURN (1)

    /*
    ** Parameter Check: @destination_owner.
    ** The @destination_owner must conform to the rules
    ** for identifiers.
    */

    if @destination_owner is not null
	BEGIN
		EXECUTE @retcode = dbo.sp_validname @destination_owner

		IF @retcode <> 0
			RETURN (1)
	END

    /*
    ** Parameter Check: @source_table.
    ** Check to see that the @source_table is local, that it conforms
    ** to the rules for identifiers, and that it is a table, and not
    ** a view or another database object.
    */

    IF @source_table IS NULL
        BEGIN
        	if @source_object is NOT NULL
        		select @source_table = @source_object
        	else
        		begin
            		RAISERROR (14043, 16, -1, '@source_table')
            		RETURN (1)
            	end
        END

	IF @source_owner is NULL -- 6.5 users only
	begin
    	IF @source_table LIKE '%.%.%' AND PARSENAME(@source_table, 3) <> DB_NAME()
       		BEGIN
          		RAISERROR (14004, 16, -1, @source_table)
      			RETURN (1)
       		END
    end

	-- For 7.0 users, @source_owner is not nullable.
	
	select @bak_source = @source_table
	
	IF @source_owner is not NULL
		begin
			select @source_table = QUOTENAME(@source_owner) + '.' + QUOTENAME(@source_table)
		    IF @destination_table IS NULL
        		SELECT @destination_table = @bak_source
        end
    ELSE 
	begin
		-- Make @source_table qualifed.
		select @tabid = object_id(@source_table)
		if @tabid is not null
		begin
			exec @retcode = dbo.sp_MSget_qualified_name @tabid, @source_table output
			if @retcode <> 0 or @@error <> 0
				return 1	
			IF @destination_table IS NULL
			-- Set destination_table if not provided or default by now.
			-- If @source_table is qualified (6.x behavior) only use table name for destination name.
				SELECT @destination_table = PARSENAME(@source_table, 1)	
		end
	end
        
	select @num_columns=count(*) from syscolumns where id = object_id(@source_table)
	if @num_columns > 255
		begin
			RAISERROR (20068, 16, -1, @source_table, 255)
            RETURN (1)
        end

    /*
    **  Get the id of the @source_table
    */
    SELECT @tabid = id, @object_type = type
    FROM sysobjects
    WHERE id = OBJECT_ID(@source_table)

    IF @tabid IS NULL
        BEGIN
            RAISERROR (14027, 11, -1, @source_table)
            RETURN (1)
        END

    /*
    ** Parameter Check: @type
    ** If the article is added as a 'schema-bound view schema only' article,
    ** make sure that the source object is a schema-bound view.
    ** Conversely, a schema-bound view cannot be published as a 
    ** 'view schema only' article.
    */
    IF @type IS NULL
		SELECT @type = 'logbased'

    select @type = lower(@type collate SQL_Latin1_General_CP1_CS_AS)

    if @type = N'indexed view schema only' and objectproperty(@tabid, 'IsSchemaBound') <> 1
    begin
        raiserror (21277, 11, -1, @source_table)        
        return (1)    
    end

    /*
    ** If the article is published as an IV logbased article, we'd better make
    ** sure that the view is schema bound and it has a clustered index.
    ** Conversely, a schema-bound view should never be published as a regular
    ** table logbased article.
    */
    if @type in (N'indexed view logbased', 
                 N'indexed view logbased manualfilter', 
                 N'indexed view logbased manualview', 
                 N'indexed view logbased manualboth') and 
        (isnull(objectproperty(@tabid, 'IsSchemaBound'),0) <> 1 or
         not exists (select * from sysindexes where id = @tabid) or
         isnull(objectproperty(@tabid, 'IsView'),0) = 0) 
    begin
        raiserror (21278, 11, -1, @source_table)
        return (1)
    end    
    
    if @type in (N'view schema only', 
                 N'logbased', 
                 N'logbased manualfilter', 
                 N'logbased manualview', 
                 N'logbased manualboth') and 
        objectproperty(@tabid, 'IsSchemaBound') = 1
    begin
        raiserror (21275, 11, -1, @source_table)
        return (1)
    end

	-- Check if there are snapshot or subscriptions and raiserror if needed.
    EXECUTE @retcode  = dbo.sp_MSreinit_article
        @publication = @publication, 
		-- Virtual subscriptions of all the articles will be deactivated.
        -- @article = @article,
		@need_new_snapshot = 1,
		@force_invalidate_snapshot = @force_invalidate_snapshot,
		@check_only = 1
    IF @@ERROR <> 0 OR @retcode <> 0
		return 1


    -- Encrypted objects are not publishable for replication
    IF @type IN (N'proc exec',
                 N'serializable proc exec',
                 N'proc schema only',
                 N'indexed view schema only',
                 N'indexed view logbased',
                 N'indexed view logbased manualfilter',
                 N'indexed view logbased manualview',
                 N'indexed view logbased manualboth',
                 N'view schema only',
                 N'func schema only')
    BEGIN
        IF EXISTS (SELECT * FROM syscomments
                    WHERE id = @tabid
                      AND encrypted = 1)
        BEGIN
            RAISERROR(21004, 16, -1, @source_table)        
            RETURN (1)
        END
    END   

    -- at this point, we've done all the common parameter checks.
    -- If this is a procedure execution article, branch to the proc execution publishing
    -- routine; or if this is a schema only procedure or view article, brach to the
    -- schema only article publishing routine; otherwise continue processing as if it were a table

    IF (@object_type = 'P' AND @type <> N'proc schema only') or 
		@type IN (N'proc schema only', N'view schema only', N'func schema only', 'indexed view schema only')
    BEGIN
		begin tran
        save TRAN sp_addarticle

		IF (@object_type = 'P' AND @type <> N'proc schema only')
		begin

            IF @schema_option IS NULL
            BEGIN
                SELECT @schema_option = 0x0000000000000001
            END

			EXECUTE @retcode = dbo.sp_MSaddexecarticle @publication,
				@article,
				@source_table,
				@destination_table,
				@type,
				@creation_script,
				@description,
				@pre_creation_cmd,
				@schema_option,
				@destination_owner,
				@artid OUTPUT
		end
		else 
		begin
		    -- Note: a transaction is started inside sp_MSaddschemaarticle        
            IF @schema_option IS NULL
            BEGIN
                SELECT @schema_option = 0x0000000000000001
            END

			IF @type = N'proc schema only'
			BEGIN
				SELECT @typeid = 0x20
			END
			ELSE IF @type = N'view schema only'
			BEGIN
				SELECT @typeid = 0x40
			END    
			ELSE IF @type = N'func schema only'
			BEGIN
				SELECT @typeid = 0x80
			select @backward_comp_level = 40 -- UDF not available in sphinx
			END
			ELSE IF @type = N'indexed view schema only'
			BEGIN
				SELECT @typeid = 0x40
			select @backward_comp_level = 40 -- SchemaBinding not available in sphinx
			END    

			EXECUTE @retcode = dbo.sp_MSaddschemaarticle 
				@publication = @publication,
				@article = @article,
				@source_object = @source_table,
				@destination_object = @destination_table,
				@type = @typeid,
				@creation_script = @creation_script,
				@description = @description,
				@pre_creation_cmd = @pre_creation_cmd,
				@schema_option = @schema_option,
				@destination_owner = @destination_owner,
				@status = @status,
				@artid = @artid OUTPUT

		end
		IF @retcode <> 0 or @@error <> 0
			goto UNDO
	end
    ELSE
	begin

		/*
		** Make sure that the table name specified is a table and not a view.
		*/

		IF NOT EXISTS (SELECT * FROM sysobjects
			WHERE id = (SELECT OBJECT_ID(@source_table))
			AND type = 'U')
			AND NOT EXISTS ( SELECT * FROM sysobjects so, sysindexes si
			WHERE so.id = OBJECT_ID(@source_table)
			AND so.type = 'V'
			AND si.id = so.id )
		BEGIN
			RAISERROR (14028, 16, -1)
			RETURN (1)
		END


		/*
		** Parameter Check:  @destination_table.
		** If the destination table is not specified, assume it's the same
		** as the source table.  Make sure that the table name is not qualified.
		*/

		/*
		** Parameter Check: @vertical_partition
		** Check to make sure that the vertical partition is either TRUE or FALSE.
		*/

		SELECT @vertical_partition = LOWER(@vertical_partition collate SQL_Latin1_General_CP1_CS_AS)
		IF @vertical_partition NOT IN ('true', 'false')
		BEGIN
			RAISERROR (14029, 16, -1)
			RETURN (1)
		END

		/*
		** Parameter Check: @filter
		** Make sure that the filter is a valid stored procedure.
		*/
		IF @filter IS NOT NULL
		BEGIN
			IF @filter_owner IS NULL
			BEGIN
    			select @object = PARSENAME( @filter, 1 )
    			select @owner  = PARSENAME( @filter, 2 )
	    		select @db     = PARSENAME( @filter, 3 )
    			select @site   = PARSENAME( @filter, 4 )

    			if @object IS NULL
        		  return 1
			END  
			ELSE
			BEGIN
				select @filter = QUOTENAME(@filter_owner) + '.' + QUOTENAME(@filter)
			END

			/*
			** Get the id of the @filter
			*/
			select @filterid = id from sysobjects where
				id = OBJECT_ID(@filter) and type = 'RF'
			IF @filterid IS NULL
			BEGIN
				RAISERROR (14027, 11, -1, @filter)
				RETURN (1)
			END

			EXEC @is_filter_in_use = dbo.sp_MSdoesfilterhaveparent @filterid
			if( @is_filter_in_use <> 0 )
			BEGIN
				RAISERROR( 21009, 11, -1 )
				RETURN (1)
			END
		END
		ELSE
			select @filterid = 0


		/*
		** Get the pubid and its properties
		*/
		SELECT @pubid = pubid, @autogen_sync_procs_id = autogen_sync_procs, @sync_method = sync_method,
			@allow_sync_tran = allow_sync_tran,
			@allow_queued_tran = allow_queued_tran,
			@allow_dts	= allow_dts,
			@repl_freq = repl_freq 
		FROM syspublications where name = @publication

		IF @pubid IS NULL
			BEGIN
				RAISERROR (14027, 11, -1, @publication)
				RETURN (1)
			END

		-- Only allow table and index view for dts publications
		if @allow_dts <> 0 and @type not in ( 
			N'logbased', 
			N'logbased manualfilter', 
			N'logbased manualview', 
			N'logbased manualboth',
			N'indexed view logbased', 
			N'indexed view logbased manualfilter', 
			N'indexed view logbased manualview', 
			N'indexed view logbased manualboth')
		begin
			raiserror(20611, 16, -1)
			return(1)
		end

		-- can't do fancy type stuff with MVs!

		ELSE IF (@allow_sync_tran <> 0 
				OR @allow_queued_tran <> 0)
				AND EXISTS ( select * from sysobjects 
					where id = OBJECT_ID(@source_table)
					and xtype = 'V' )
		BEGIN
			RAISERROR(14059, 16, -1)
			RETURN 1
		END
		
		--
		-- parameter check: @status
		-- bits 8, 16, 64 can be set directly
		-- Other bits from 1 ~ 64 are used but cannot be set here.
		-- Bit 64 can only be set for publication that allows DTS.
		-- Bit 32 is set internally according to whether or not timestamp is in
		-- the partition for queued publications.

		IF (@status & ~ 88 ) <> 0 
		BEGIN
			RAISERROR( 21061, 16, -1, @status, @article )
			RETURN (1)
		END
		else if (@status & 64 <> 0 and @allow_dts = 0)
		begin
			raiserror(20590, 16, -1)
			return (1)
		end


		/*
		** Parameter Check:  @article, @publication.
		** Check if the article already exists in this publication.
		*/

		IF EXISTS (SELECT *
					 FROM sysextendedarticlesview
					WHERE pubid = @pubid
					  AND name = @article)
			BEGIN
				RAISERROR (14030, 16, -1, @article, @publication)
				RETURN (1)
			END

		/*
		** Set the typeid.  The default type is logbased.  Anything else is
		** currently undefined (reserved for future use).
		**
		**      @typeid     type
		**      =======     ========
		**          1     logbased
		**          3     logbased manualfilter
		**          5     logbased manualview
		**          7     logbased manualboth
		**          8     proc exec              (valid in dbo.sp_MSaddexecarticle)
		**          24    serializable proc exec (valid in dbo.sp_MSaddexecarticle)
		**          32    proc schema only       (valid in dbo.sp_MSaddschemaarticle)
		**          64    view schema only       (valid in dbo.sp_MSaddschemaarticle)
		**         128    func schema only       (valid in dbo.sp_MSaddschemaarticle)
		**       Note that for the following article types, the 256 bit is not really persisted
		**         257    indexed view logbased
		**         259    indexed view logbased manualfilter
		**         261    indexed view logbased manualview
		**         263    indexed view logbased manualboth
		**         320    indexed view schema only (valid in dbo.sp_MSaddschemaarticle)
		*/


		IF LOWER(@type collate SQL_Latin1_General_CP1_CS_AS) NOT IN 
                                    ('logbased', 
									 'logbased manualfilter', 
									 'logbased manualview', 
									 'logbased manualboth',
									 'indexed view logbased', 
									 'indexed view logbased manualfilter', 
									 'indexed view logbased manualview', 
									 'indexed view logbased manualboth',
									 'proc schema only', 
									 'view schema only')
		BEGIN
			RAISERROR (14023, 16, -1)
			RETURN (1)
		END

		IF LOWER(@type collate SQL_Latin1_General_CP1_CS_AS) = 'logbased' OR LOWER(@type) = 'indexed view logbased'
			SELECT @typeid = 1
		ELSE IF LOWER(@type collate SQL_Latin1_General_CP1_CS_AS) = 'logbased manualfilter' OR LOWER(@type collate SQL_Latin1_General_CP1_CS_AS) = 'indexed view logbased manualfilter'
		   SELECT @typeid = 3
		ELSE IF LOWER(@type collate SQL_Latin1_General_CP1_CS_AS) = 'logbased manualview' OR LOWER(@type collate SQL_Latin1_General_CP1_CS_AS) = 'indexed view logbased manualview'
		   SELECT @typeid = 5
		ELSE IF LOWER(@type collate SQL_Latin1_General_CP1_CS_AS) = 'logbased manualboth' OR LOWER(@type collate SQL_Latin1_General_CP1_CS_AS) = 'indexed view logbased manualboth'
			SELECT @typeid = 7

		/*
		** Set the precmdid.  The default type is 'drop'.
		**
		**      @precmdid   pre_creation_cmd
		**      =========   ================
		**            0     none
		**          1     drop
		**          2     delete
		**          3     truncate
		*/
		IF LOWER(@pre_creation_cmd collate SQL_Latin1_General_CP1_CS_AS) NOT IN ('none', 'drop', 'delete', 'truncate')
		BEGIN
			RAISERROR (14061, 16, -1)
			RETURN (1)
		END

		/*
		** Determine the integer value for the pre_creation_cmd.
		*/
		IF LOWER(@pre_creation_cmd collate SQL_Latin1_General_CP1_CS_AS) = 'none'
			SELECT @precmdid = 0
		ELSE IF LOWER(@pre_creation_cmd collate SQL_Latin1_General_CP1_CS_AS) = 'drop'
			SELECT @precmdid = 1
		ELSE IF LOWER(@pre_creation_cmd collate SQL_Latin1_General_CP1_CS_AS) = 'delete'
			SELECT @precmdid = 2
		ELSE IF LOWER(@pre_creation_cmd collate SQL_Latin1_General_CP1_CS_AS) = 'truncate'
			SELECT @precmdid = 3

		IF @sync_object IS NULL
			select @syncid = @tabid
		ELSE
		BEGIN

		IF @sync_object_owner is NULL  -- 6.5 only
		BEGIN

			/*
			** Parameter Check: @sync_object.
			** Check to see that the sync_object is local and that it
			** conforms to the rules for identifiers.
			*/

			select @object = PARSENAME( @sync_object, 1 )
			select @owner  = PARSENAME(  @sync_object, 2 )
			select @db     = PARSENAME(  @sync_object, 3 )
			select @site   = PARSENAME(  @sync_object, 4 )

			if @object IS NULL
				  return 1


			IF @sync_object LIKE '%.%.%' AND @db <> DB_NAME()
			BEGIN
				RAISERROR (14004, 16, -1, @sync_object)
				RETURN (1)
			END

		END -- end of 65 processing
		else -- for sphinx, @sync_object_owner can not be null
			select @sync_object = QUOTENAME(@sync_object_owner) + '.' + QUOTENAME(@sync_object)
			
			/*
			**  Get the id of the @sync_object
			*/

			SELECT @syncid = id FROM sysobjects WHERE id = OBJECT_ID(@sync_object)

			IF @syncid IS NULL
			BEGIN
				RAISERROR (14027, 11, -1, @sync_object)
				RETURN (1)
			END

			/*
			** Make sure the sync object specified is a table or a view.
			*/

			IF NOT EXISTS (SELECT * FROM sysobjects
					WHERE id = (SELECT OBJECT_ID(@sync_object))
					AND (type = 'U' or
						 type = 'V'))
			BEGIN
				RAISERROR (14031, 16, -1)
				RETURN (1)
			END
		END

		/*
		** If the publication is log-based, or allows updating subscribers
		** make sure there is a primary key on the source table.
		** or a UCI on the view.
		** NOTE!  sprok in SPSUP.SQL
		*/
		IF EXISTS (SELECT * FROM syspublications 
			WHERE pubid = @pubid AND
				(repl_freq = 0 OR allow_sync_tran = 1 OR @allow_queued_tran = 1))
		BEGIN
			EXEC @fHasPk = dbo.sp_MSreplsup_table_has_pk @tabid

			IF @fHasPk = 0
			BEGIN
				IF EXISTS ( select * from sysobjects 
					where id = OBJECT_ID(@source_table)
					and xtype = 'U' )
				BEGIN
					RAISERROR (14088, 16, -1, @source_table)
				END
				ELSE
				BEGIN
					RAISERROR( 14089, 16, -1, @source_table)
				END
				RETURN (1)
			END
		END

		/*
		** Parameter Check:  @creation_script and @schema_option
		** @schema_option cannot be null
		** If @schema_option is 0, there have to be @creation_script defined.
		*/
		IF @schema_option IS NULL
		BEGIN
			-- Snapshot publication, no custom proc. generation
			-- We need insert proc for snapshot publications for DTS.
			-- Do not generate user triggers by default (0x00100 - user trigger flag)
			IF @repl_freq = 1 and @allow_dts = 0
			BEGIN
				SELECT @schema_option  = 0x0000000000000071
			END
			ELSE
			BEGIN
				SELECT @schema_option  = 0x00000000000000F3
			END

			if (@allow_queued_tran = 1)
				select @schema_option = fn_replprepadbinary8(fn_replgetbinary8lodword(@schema_option) | 0x8000)
		END

		/*
		** Parameter Check: @schema_option
		** If bit 0x2 is set, this cannot be an article for a snapshot publication
		** For queued updating, DRI_Primary Key option has to be set
		*/
		IF ((CONVERT(INT, @schema_option) & 0x2) <> 0) AND (@repl_freq = 1)
		BEGIN
			RAISERROR (21143, 16, -1)
			RETURN (1)
		END
		else if ((@allow_queued_tran = 1) and 
			((fn_replgetbinary8lodword(@schema_option) & 0x8000) = 0))
		BEGIN
			RAISERROR (21394, 16, 1)
			RETURN (1)
		END
		
		/* 
		** Since custom proc name is based on destination table name
		*/
		
		if @allow_dts = 0
			set @custom_proc_name = @destination_table
		else
			set @custom_proc_name = @article

		-- Publication allow dts/queued must use parameterized commands and 
		-- ins/upd/del commands are generated 
		-- internally and are fixed (they will used as keys to find the correct transformations)
		if (@allow_dts = 1 or @allow_queued_tran = 1)
		begin
			select @valid_ins_cmd = N'CALL sp_MSins_' + @custom_proc_name
			IF @repl_freq = 0
			begin
				--
				-- Note :
				-- Now that we are autogenrating the custom procs for queued
				-- we will follow the current behavior :
				-- for queued INS/UPD/DEL will use CALL/XCALL/XCALL respectively
				-- for DTS INS/UPD/DEL will use CALL/XCALL/XCALL
				-- In case it allows both queued and DTS, DTS will take precedence
				-- YWU: Check this
				--
				select @valid_del_cmd = N'XCALL sp_MSdel_' + @custom_proc_name
				if (@allow_queued_tran = 1)
				begin
					select @valid_upd_cmd = N'XCALL sp_MSupd_' + @custom_proc_name
				end
				if (@allow_dts = 1)
				begin
					if @status = 16
						select @valid_upd_cmd = N'CALL sp_MSupd_' + @custom_proc_name
					else 
						select @valid_upd_cmd = N'XCALL sp_MSXpd_' + @custom_proc_name
				end
			end
			else
			begin
				select @valid_upd_cmd = N'SQL'
				select @valid_del_cmd = N'SQL'
			end

			if (@allow_dts = 1)
			begin
				-- For publication allows DTS, @status can only be 16 or 48
				-- 
				if  (@status <> 16 and @status <> 80) or
					(@ins_cmd is not null and @ins_cmd <> @valid_ins_cmd) or 
					(@upd_cmd is not null and @upd_cmd <> @valid_upd_cmd) or 
					(@del_cmd is not null and @del_cmd <> @valid_del_cmd)
				begin
					raiserror(21174, 16, -1)
					return (1)
				end
			end 
			else if (@allow_queued_tran = 1)
			begin
				if  (@ins_cmd is not null and @ins_cmd != @valid_ins_cmd) or 
					(@upd_cmd is not null and @upd_cmd != @valid_upd_cmd) or 
					(@del_cmd is not null and @del_cmd != @valid_del_cmd)
				begin
					raiserror(21191, 16, -1, @valid_ins_cmd, @valid_upd_cmd, @valid_del_cmd)
					return (1)
				end
			end
				
			select @ins_cmd = @valid_ins_cmd
			select @upd_cmd = @valid_upd_cmd
			select @del_cmd = @valid_del_cmd
		end
		-- If pub sync_type is character mode bcp(1) 
		else if @sync_method = 1
		begin
			-- Parameterized command is not supported. Mask it off.
			select @status = @status & ~16
			if @ins_cmd is NULL  select @ins_cmd = 'SQL'
			if @upd_cmd is NULL  select @upd_cmd = 'SQL'
			if @del_cmd is NULL  select @del_cmd = 'SQL'
		end

		/*
		** Parameter Check: @schema_option
		** If Autogeneration of custom procedures is not enabled 
		** then the default commands will be SQL
		*/
		IF ((CONVERT(int, @schema_option) & 0x2) = 0)
		BEGIN
			if @ins_cmd is NULL  select @ins_cmd = 'SQL'
			if @upd_cmd is NULL  select @upd_cmd = 'SQL'
			if @del_cmd is NULL  select @del_cmd = 'SQL'
		END
	 		 
		-- Autogenerate custom procedure names if not provided.
		-- Use destination table name as the base name by default. 
	/*	
		-- Use article name by default. If the name is too long or there's confliction,
		-- use guid (to prevent proc for diff art in diff pub has same name which cause problems
		-- when being subscribed by the same subscriber db.
		if ((@source_object is not NULL and len(@article) > 119) or
			(@source_object is NULL and len(@article) > 21)) or
			exists (select * from sysarticles where name = @article)
		begin
			set @guid = CONVERT(varbinary(16), LEFT(NEWID(),8))
			exec @retcode = master.dbo.xp_varbintohexstr @guid, @custom_proc_name OUTPUT
			if @@error <> 0 or @retcode <> 0
				RETURN(1)
		end
		else
			set @custom_proc_name = @article
	*/

		-- If no command then construct name 
		if @ins_cmd is NULL
		begin
			if (@status & 16) <> 0 -- parameterized
			begin
				if @source_object is not NULL  -- 7.0 format
					set @ins_cmd = N'CALL ' + convert (sysname, 'sp_MSins_' + @custom_proc_name)
				else -- 6.x compatible
					set @ins_cmd = N'CALL ' + convert(nvarchar(30), 'sp_MSins_' + @custom_proc_name)
			end
			else
				select @ins_cmd = 'SQL'
		end

		if @del_cmd is NULL
		begin
			if (@status & 16) <> 0 -- parameterized
			begin
				if @source_object is not NULL  -- 7.0 format
					set @del_cmd = N'CALL ' + convert (sysname, 'sp_MSdel_' + @custom_proc_name)
				else -- 6.x compatible
					set @del_cmd = N'CALL ' + convert(nvarchar(30), 'sp_MSdel_' + @custom_proc_name)
			end
			else
				select @del_cmd = 'SQL'
		end

		if @upd_cmd is NULL
		begin
			if (@status & 16) <> 0 -- parameterized
			begin
				if @source_object is not NULL  -- 7.0 format
					set @upd_cmd = N'MCALL ' + convert (sysname, 'sp_MSupd_' + @custom_proc_name)
				else -- 6.x compatible
					set @upd_cmd = N'CALL ' + convert(nvarchar(30), 'sp_MSupd_' + @custom_proc_name)
			end
			else
				select @upd_cmd = 'SQL'
		end

		--
		-- Sync/QueuedTran
		-- Add guid column if not exists
		--
		if (@allow_sync_tran = 1 or @allow_queued_tran = 1)
		begin
			SELECT @MSrepl_tran_version_datatype = TYPE_NAME(xtype),
				@colid = colid
			FROM dbo.syscolumns  
			WHERE id = @tabid AND name = 'msrepl_tran_version'

			if (@MSrepl_tran_version_datatype IS NULL)
			begin
				--
				-- column does not exist, add it
				--
				if exists (select * from sysobjects where id = @tabid and replinfo & @merge_pub_object_bit <>0)
				begin
					--if being merged, call stored procedure to add this column.
					exec @retcode = sp_repladdcolumn @source_object=@source_table,
													 @column = 'msrepl_tran_version',
													 @typetext= 'uniqueidentifier not null default newid()'
					if @@ERROR<>0 or @retcode<>0
						return (1)
				end
				else
				begin
					exec ('alter table ' + @source_table + ' add msrepl_tran_version uniqueidentifier not null default newid()' )
	        		IF @@ERROR <> 0 
	            		RETURN (1)
				end
			end
			else
			begin
				--
				-- column exists, it should be of type uniqueidentifier
				--
				if (@MSrepl_tran_version_datatype != 'uniqueidentifier')
				begin
					raiserror(21192, 16, -1) 
					RETURN (1)
				end

				-- Create the default constraint if it is not there
				if not exists (select * from sysconstraints where
					id = @tabid and 
					colid = @colid and
					status & 5 = 5) -- default
				begin 
					declare @constraint_name sysname
					select @constraint_name = 'MSrepl_tran_version_default_' + convert(nvarchar(10), @tabid)
					if not exists (select * from sysobjects where name = @constraint_name)
					begin
						exec ('alter table ' + @source_table + 
							' add constraint ' + @constraint_name + 
							' default newid() for msrepl_tran_version')
						if @@ERROR<>0 return 1
					end
				end

			end
		end

	/*  
		-- SyncTran
		-- Add timestamp column if not exists
		if @allow_sync_tran = 1 and @allow_queued_tran = 0 and ObjectProperty(@tabid, 'TableHasTimestamp') = 0
		begin
			exec ('alter table ' + @source_table + ' add msrepl_synctran_ts timestamp not null' )
			IF @@ERROR <> 0 
				RETURN (1)
		end
	*/

		-- if concurrent, must use stored procedures at subcriber when replicating commands

		if @sync_method IN (3,4) and 
		   (lower(@del_cmd) not like N'%call%' or 
			lower(@ins_cmd) not like N'%call%' or
			lower(@upd_cmd) not like N'%call%' )
		begin
			raiserror( 21153, 16, -1, @article )
			return 1
		end

		-- Identity range support
			/*
		** Parameter Check:  @allow_push.
		*/

		IF @auto_identity_range IS NULL OR LOWER(@auto_identity_range collate SQL_Latin1_General_CP1_CS_AS) NOT IN ('true', 'false')
			BEGIN
				RAISERROR (14148, 16, -1, '@auto_identity_range')
				RETURN (1)
			END
		IF LOWER(@auto_identity_range collate SQL_Latin1_General_CP1_CS_AS) = 'true' 
		begin
			if @allow_queued_tran = 0
			begin
				raiserror(21231, 16 ,-1)
				return 1
			end
			/*
			** If you want to have identity support, @range and threshold can not be NULL
			*/
			if (@pub_identity_range is NULL or @identity_range is NULL or @threshold is NULL)
				begin
					raiserror(21193, 16, -1)
					return (1)
				end

			if OBJECTPROPERTY(@tabid, 'tablehasidentity') <> 1
			begin
				raiserror(21194, 16, -1)
				return (1)
			end

			if @pub_identity_range <= 1 or @identity_range <= 1
			begin
				raiserror(21232, 16 ,-1)
				return 1
			end

			if @threshold < 1 or @threshold > 100
			begin
				raiserror(21233, 16 ,-1)
				return 1
			end

			declare @xtype int, @xprec int, @max_range bigint
			select @xtype=xtype, @xprec=xprec from syscolumns where id=@tabid and 
				columnproperty(id, name, 'IsIdentity')=1
			select @max_range =
					case @xtype when 52 then power((convert(bigint,2)), 8*2-1) - 1 --smallint 
						when 48 then power((convert(bigint,2)), 8-1) - 1 		 --tinyint
						when 56 then power((convert(bigint,2)), 8*4-1) - 1 		 --int
						when 127 then power((convert(bigint,2)), 62) - 1 + power((convert(bigint,2)), 62)  	--bigint
       					when 108 then power((convert(bigint,10)), @xprec) 	 --numeric
       					when 106 then power((convert(bigint,10)), @xprec) 	 --decimal
 					else
						power((convert(bigint,2)), 62) + power((convert(bigint,2)), 62) - 1  -- defaulted to bigint
					end
		
			if @pub_identity_range * 2 + @identity_range > (@max_range - IDENT_CURRENT(@source_table))
				begin
					raiserror(21290, 16, -1)
					return (1)
				end

			-- Set the range to negtive if incr of the identity is negtive
			if IDENT_INCR(@source_table) < 0
			begin
				select @pub_identity_range = -1 * @pub_identity_range;
				select @identity_range = -1 * @identity_range;
			end

			-- If the table is already published in queued but is not auto identity
			-- raiserror error
			if exists (select * from  sysarticles sa, sysarticleupdates au, syspublications pub where 
				sa.objid = @tabid and
				au.artid = sa.artid and
				au.pubid = pub.pubid and
				pub.allow_queued_tran = 1 and 
				au.identity_support = 0)
			begin
				raiserror (21240, 16, -1, @source_table)
				return (1)
			end

			-- If the table is already published in queued and have different auto identity 
			-- range values, raise error.
			if exists (select * from MSpub_identity_range where objid=@tabid and 
			((pub_range<>@pub_identity_range) or (range <> @identity_range) or (threshold <> @threshold)))
			begin
				raiserror(21291, 16, -1)
				return (1)
			end
		end
		else
		begin
			-- @auto_identity_range is false
			-- If the publication is queued and the table has published with auto identity
			-- already, raise error.
			if exists (select * from  sysarticles sa, sysarticleupdates au where 
				sa.objid = @tabid and
				au.artid = sa.artid and
				au.identity_support = 1)
			begin
				raiserror (21240, 16, -1, @source_table)
				return (1)
			end
		end

		-- SQL insert doesn't work because we need to do 'set identity_insert on/off' 
		-- before and after the insert.
		-- The exception is snapshot publication.
		/* Queue now uses fixed commands. Message 21234 should be removed.
		if @allow_queued_tran = 1 and OBJECTPROPERTY(@tabid, 'tablehasidentity') = 1 and
			@ins_cmd = 'SQL' and @repl_freq <> 1
		begin
			raiserror(21234, 16, -1)
			return (1)
		end
		*/

		-- Do not allow the table to be published by both merge and queued tran
		if @allow_queued_tran = 1
		begin
			if exists (select * from sysobjects where name = 'sysmergearticles')
			begin
				if exists (select * from sysmergearticles where objid = @tabid)
				begin
					declare @obj_name sysname
					select @obj_name = object_name(@tabid)
					raiserror(21266, 16, -1, @obj_name)
					return (1)
				end
			end
		end

		/*
		**  Add article to sysarticles and update sysobjects category bit.
		*/
		-- begin tran
		begin tran
		save TRAN sp_addarticle

		INSERT sysarticles (columns, creation_script, del_cmd, description,
			dest_table, filter, filter_clause, ins_cmd, name,
			objid, pre_creation_cmd, pubid,
			status, sync_objid, type, upd_cmd, schema_option,
			dest_owner)
		VALUES (0, @creation_script, @del_cmd, @description, @destination_table,
			@filterid, @filter_clause, @ins_cmd, @article, @tabid,
			@precmdid, @pubid, @status, @syncid, @typeid, @upd_cmd, @schema_option, 
			@destination_owner)

		IF @@ERROR <> 0
			goto UNDO

		SELECT @artid = @@IDENTITY

		UPDATE sysobjects SET replinfo =  replinfo |  @publish_bit
			WHERE id = (SELECT objid FROM sysarticles WHERE name = @article 
				and pubid =  @pubid)

		IF @@ERROR <> 0
			goto UNDO

		IF @filter IS NOT NULL
		BEGIN
			EXEC dbo.sp_MSsetfilterparent @filter, @tabid
			IF @@ERROR <> 0
				goto UNDO
		END

		EXEC dbo.sp_MSsetfilteredstatus @tabid
		IF @@ERROR <> 0
			goto UNDO

		/*
		** Set all bits to '1' in the columns column to include all columns.
		*/

		IF @vertical_partition = 'false'
		BEGIN
			EXECUTE @retcode  = dbo.sp_articlecolumn @publication, @article
			-- synctran
			, @refresh_synctran_procs = 0
 			, @force_invalidate_snapshot = @force_invalidate_snapshot
      
			IF @@ERROR <> 0 OR @retcode <> 0
				goto UNDO
		END
    
		/*
		** 1. Set all bits to '1' for all columns in the primary key.
		** 2. Set version column bit to 1 if the publication is synctran
		** 3. For queued replication, set all column bits to 1 that do not allow
		**		NULL or DEFAULT value
		*/
		ELSE
		BEGIN
			--
			-- for updating subscribers build a temp table
			-- to keep track of columns that are mandatory
			--
			if (@allow_sync_tran = 1 or @allow_queued_tran = 1)
			begin
				create table #pktable(name sysname collate database_default)
			end
        	
			--
			-- if it's a table, get the indid of the PK
			--
			if exists( select * from sysobjects where id = @tabid and xtype = 'U' )
			begin
				SELECT @indid = indid FROM sysindexes
				WHERE id = @tabid
				AND (status & 2048) <> 0    /* PK index */
			end
			else  -- else it's a mview, use the CI (which, for a MV, must be unique)        
			begin
				SELECT @indid = 1
			end

			/*
			**  First we'll figure out what the keys are.
			*/
			SELECT @i = 1

			WHILE (@i <= 16)
			BEGIN
				SELECT @pkkey = INDEX_COL(@source_table, @indid, @i)
				if @pkkey is NULL
					break

				EXECUTE @retcode  = dbo.sp_articlecolumn @publication,
					@article, @pkkey, 'add'
					-- synctran
					, @refresh_synctran_procs = 0
					, @force_invalidate_snapshot = @force_invalidate_snapshot
				IF @@ERROR <> 0 OR @retcode <> 0
					goto UNDO

				if (@allow_sync_tran = 1 or @allow_queued_tran = 1)
					insert into #pktable(name) values(@pkkey)
					
				select @i = @i + 1
			END

			if (@allow_sync_tran = 1 or @allow_queued_tran = 1)
			BEGIN
				--
				-- The version column needs to go in
				--
				declare @version_col sysname
				-- Get synctran column
				select @version_col = 'msrepl_tran_version'
				EXECUTE @retcode  = dbo.sp_articlecolumn @publication,
					@article, @version_col, 'add'
					-- synctran
					, @refresh_synctran_procs = 0
					, @force_invalidate_snapshot = @force_invalidate_snapshot

				IF @@ERROR <> 0 OR @retcode <> 0
					goto UNDO

				insert into #pktable(name) values('msrepl_tran_version')

				--
				-- select the columns that are not IDENTITY columns
				-- and do not allow NULL 
				-- and do not have any DEFAULT constraints defined for them
				-- and have not been processed already
				-- (IDENTITY columns do not need to be referenced explicitly - 
				-- which is like having a DEFAULT value so they can be excluded)
				--
				declare #htemp cursor local fast_forward for
					select name from dbo.syscolumns 
					where id = @tabid and isnullable = 0 
						and cdefault = 0 
						and ColumnProperty(id, name, N'IsIdentity') != 1
						and name not in (select name from #pktable)	

				open #htemp
				fetch #htemp into @version_col
				while (@@fetch_status = 0)
				begin
					EXECUTE @retcode  = dbo.sp_articlecolumn @publication,
					@article, @version_col, 'add', @refresh_synctran_procs = 0
					, @force_invalidate_snapshot = @force_invalidate_snapshot

					IF (@@ERROR != 0 OR @retcode != 0)
					BEGIN
						close #htemp
						deallocate #htemp
						drop table #pktable
						goto UNDO
					END
					fetch #htemp into @version_col
				end
				close #htemp
				deallocate #htemp
				drop table #pktable
			END
		end -- IF @vertical_partition = 'false' ELSE
 
		------------------------------------------------------------------------------
		-- if table based article does not use a view for sync, create one and use it
		------------------------------------------------------------------------------

		if @tabid = @syncid 
		begin
			-- generate view name

			declare @viewname varchar(255)

			set @guid = CONVERT(varbinary(16), LEFT(NEWID(),8))
			exec @retcode = master.dbo.xp_varbintohexstr @guid, @viewname OUTPUT
			if @@ERROR <> 0 OR @retcode <> 0
				goto UNDO
			
			set @viewname = 'syncobj_' + @viewname

			-- create view for object synchronization
			if ((@allow_sync_tran = 1 or @allow_queued_tran = 1) 
				and @vertical_partition = 'true')
			begin
				--
				-- vertical partition is true - this means we may not have the 
				-- complete view yet - column could be added or dropped.
				-- we do not want to validate the provided filter clause now
				-- sp_articlefilter will be called explicitly later to add article 
				-- filter and sp_articleview will be called finally to regenerate the 
				-- view - and the filter validation will be done then for updating subscribers
				--
				exec @retcode = dbo.sp_articleview @publication, @article, @viewname, NULL
					,@force_invalidate_snapshot = @force_invalidate_snapshot
			end
			else
			begin
				exec @retcode = dbo.sp_articleview @publication, @article, @viewname, @filter_clause
					,@force_invalidate_snapshot = @force_invalidate_snapshot
			end
			if @@ERROR <> 0 OR @retcode <> 0
				goto UNDO
		end

		-- Need to change syscolumns status before generating sync procs because the
		-- status will be used to decide whether or not call set identity insert.
		IF LOWER(@auto_identity_range collate SQL_Latin1_General_CP1_CS_AS) = 'true' 
		begin
			-- Make the identity column as not for replication
			select @colid = null
			select @colid = colid from syscolumns  where
				 id = @tabid and
				 colstat & 0x0001 <> 0 and -- is identity
				 colstat & 0x0008 = 0 -- No 'not for repl' property
			if @colid is not null
			begin
				exec @retcode  = dbo.sp_replupdateschema @source_table
				-- Mark 'not for repl'
				update syscolumns set colstat = colstat | 0x0008 where
					id = @tabid and colid = @colid
				-- Single to refresh the object cache.
				exec @retcode  = dbo.sp_replupdateschema @source_table
				IF @@ERROR <> 0 OR @retcode <> 0
					goto UNDO
			end
		end

		/* 
		** if @autogen_sync_procs_id is 1, autogen the sync tran procs, including name 
		*/
		if @tabid > 0 and @autogen_sync_procs_id = 1
		begin
			declare @insproc sysname, @updproc sysname, @delproc sysname, @updtrig sysname
			select @insproc   = 'sp_MSsync_ins_'+ SUBSTRING(RTRIM(@article), 1, 100) + '_' + rtrim(convert(varchar, @pubid))
			select @updproc   = 'sp_MSsync_upd_'+ SUBSTRING(RTRIM(@article), 1, 100) + '_' + rtrim(convert(varchar, @pubid))
			select @delproc   = 'sp_MSsync_del_'+ SUBSTRING(RTRIM(@article), 1, 100) + '_' + rtrim(convert(varchar, @pubid))
			select @updtrig   = 'sp_MSsync_upd_trig_'+ SUBSTRING(RTRIM(@article), 1, 100) + '_' + rtrim(convert(varchar, @pubid))

			-- check uniqueness of names and revert to ugly guid-based name if friendly name already exists
			if exists (select name from sysobjects where name in (@insproc, @updproc, @delproc, @updtrig))
			begin
				declare @guid_name nvarchar(36)
				select @guid_name =  convert (nvarchar(36), newid())
				-- remove '-' from guid name because rpc can't handle '-'
				select @guid_name = replace (@guid_name,'-','_')
				select @insproc = 'sp_MSsync_ins_' + @guid_name
				select @updproc = 'sp_MSsync_upd_' + @guid_name
				select @delproc = 'sp_MSsync_del_' + @guid_name
				select @updtrig = 'sp_MSsync_upd_trig_' + @guid_name
			end

			if @insproc IS NULL
			begin
				RAISERROR (14043, 11, -1, '@insproc')
				goto UNDO
			end

			if @updproc IS NULL
			begin
				RAISERROR (14043, 11, -1, '@updproc')
				goto UNDO
			end

			if @delproc IS NULL
			begin
				RAISERROR (14043, 11, -1, '@delproc')
				goto UNDO
			end


			if @updtrig IS NULL
			begin
				RAISERROR (14043, 11, -1, '@updtrig')
				goto UNDO
			end


			exec @retcode = dbo.sp_articlesynctranprocs @publication, @article, @insproc, @updproc, @delproc, true, @updtrig

			IF @@ERROR <> 0 OR @retcode <> 0
				goto UNDO
		end
		-- end SyncTran

		-- Generate the conflict table and conflict proc for Queued Tran case
		if (@allow_queued_tran = 1)
		begin
			exec @retcode = dbo.sp_MSmakeconflicttable @article, @publication, 0
			IF @@ERROR <> 0 OR @retcode <> 0
				goto UNDO
			exec @retcode = dbo.sp_MSmaketrancftproc @article, @publication
			IF @@ERROR <> 0 OR @retcode <> 0
				goto UNDO
		end 

		IF LOWER(@auto_identity_range collate SQL_Latin1_General_CP1_CS_AS) = 'true' 
		begin
			-- Have to do the update below after sync proc generation since
			-- it will insert row to sysarticleupdates
			update sysarticleupdates set identity_support = 1 where artid = @artid
			IF @@ERROR <> 0
				goto UNDO
			
			-- It is possible that the table is already being published. If so
			-- keep the old identity range values.
			if not exists (select * from MSpub_identity_range where objid = @tabid)
			begin
				insert into MSpub_identity_range (objid, range, pub_range, current_pub_range, last_seed, threshold) 
					values (@tabid, @identity_range, @pub_identity_range, @pub_identity_range, null, @threshold) 
				IF @@ERROR <> 0
					goto UNDO
			
				-- Call stored procedure to reconcile identity range
				exec @retcode = dbo.sp_MSpub_adjust_identity @artid = @artid
				IF @@ERROR <> 0 OR @retcode <> 0
					goto UNDO
			end					
		end -- IF LOWER(@auto_identity_range collate SQL_Latin1_General_CP1_CS_AS) = 'true' 
	END -- End of the else block handle table articles.

	-- 0x00001000 collation
	-- 0x00002000 extended property
    -- @schema_option is already padded out at the beginning of this procedure

	SELECT @schema_option_int = fn_replgetbinary8lodword(@schema_option)
	IF ((@schema_option_int & 0x00001000 <>0 ) or 
        (@schema_option_int & 0x00002000 <> 0 ))
		select @backward_comp_level = 40
	if @backward_comp_level > 10
		update syspublications set backward_comp_level = @backward_comp_level where pubid = @pubid

    /*
    ** Get distribution server information for remote RPC call.
    */
    EXECUTE @retcode = dbo.sp_helpdistributor @rpcsrvname = @distributor OUTPUT,
       @distribdb   = @distribdb OUTPUT
    IF @@ERROR <> 0 or @retcode <> 0
		goto UNDO

    SELECT @dbname =  DB_NAME()
    
    SELECT @distproc = RTRIM(@distributor) + '.' + @distribdb + 
        '.dbo.sp_MSadd_article'
    EXECUTE @retcode = @distproc
        @publisher = @@SERVERNAME,
        @publisher_db = @dbname,
        @publication = @publication,
        @article = @article,
        @article_id = @artid,
		@destination_object = @destination_table,
		@source_owner = @source_owner,
		@source_object = @bak_source,
		@description = @description

    IF @@ERROR <> 0 OR @retcode <> 0
		goto UNDO
    
    /* If the publication is immediate_sync type
    ** 1. Change the immediate_sync_ready status to false 
    ** 2. Add a virtual subscription on the article 
    ** 3. Add subscriptions for all the subscriber
    ** that have no_sync subscriptions on the publication
    **
    ** Note: Subscriptions for subscribers that have automatic sync subscriptions
    ** on the publication will be added by snasphot agent.
    */
    if EXISTS (SELECT *    FROM syspublications WHERE
        name = @publication    AND
        immediate_sync = 1 )
    BEGIN
        EXECUTE @retcode  = dbo.sp_addsubscription 
            @publication = @publication, 
            @article = @article, 
            @subscriber = NULL, 
            @destination_db = 'virtual', 
            @sync_type = 'automatic', 
            @status = NULL, 
            @reserved = 'internal'
        IF @@ERROR <> 0 OR @retcode <> 0
			GOTO UNDO

		-- Note: We have to add the subscriptions to the new article before 
		-- the virtual subscriptions being activated!!!! Otherwise, the snapshot 
		-- transactions may be skipped by dist agents.
        EXECUTE @retcode  = dbo.sp_refreshsubscriptions @publication

        IF @@ERROR <> 0 OR @retcode <> 0
			GOTO UNDO
		
		-- Have to call this stored procedure to invalidate existing snapshot
		-- if there are any. 
        EXECUTE @retcode  = dbo.sp_MSreinit_article
            @publication = @publication, 
			-- Virtual subscriptions of all the articles will be deactivated.
			-- @article = @article,
			@need_new_snapshot = 1,
			@force_invalidate_snapshot = @force_invalidate_snapshot	
        IF @@ERROR <> 0 OR @retcode <> 0
			GOTO UNDO
    END

    COMMIT TRANSACTION
	return 0
UNDO:
	if @@trancount > 0
	begin
		ROLLBACK TRANSACTION sp_addarticle
		commit tran
	end
	RETURN (1)
go
 
EXEC dbo.sp_MS_marksystemobject sp_addarticle
grant execute on dbo.sp_addarticle to public
--------------------------------------------------------------------------------
--. sp_reinitsubscription
--------------------------------------------------------------------------------

if exists (select * from sysobjects
    where type = 'P '
      and name = 'sp_reinitsubscription')
    drop procedure sp_reinitsubscription

print ''
print 'Creating procedure sp_reinitsubscription'
go

CREATE PROCEDURE sp_reinitsubscription (
    @publication sysname = 'all',    /* publication name */
    @article sysname = 'all',        /* article name */
    -- Force user to specify the subscriber name
    @subscriber sysname,             /* subscriber name */
    @destination_db sysname = 'all'   /* destination database name */
	,@for_schema_change bit = 0
) AS

    DECLARE @retcode int
    DECLARE @distributor sysname
    DECLARE @distribdb sysname
    declare @active tinyint
    declare @subscribed tinyint
    declare @automatic tinyint
    DECLARE @artid int
    DECLARE @distproc nvarchar (255)
    DECLARE @dbname sysname
    DECLARE @sub_ts binary(10) -- must be binary(10) type.
    DECLARE @sync_type tinyint
    DECLARE @immediate_sync bit
    DECLARE @subscription_type int
    DECLARE @push int
    DECLARE @pub sysname
    DECLARE @dest_db sysname
    DECLARE @sub_name sysname
    DECLARE @art_name sysname
    DECLARE @none tinyint
    declare @login_name sysname


  
    -- Initialization
    select @active = 2
    select @subscribed = 1
    select @dbname = DB_NAME()
    SELECT @none = 2            /* Const: synchronization type 'none' */
    SELECT @automatic = 1       /* Const: synchronization type 'automatic' */
    select @push = 0

    /* 
    ** Security Check.
    ** We use login_name stored in syssubscriptions to manage security 
    */

    /* Validate names */

    EXECUTE @retcode = dbo.sp_validname @publication
    IF @@ERROR <> 0 OR @retcode <> 0
        RETURN (1)

    /* article name can be a quoted name
    EXECUTE @retcode = dbo.sp_validname @article
    IF @@ERROR <> 0 OR @retcode <> 0
        RETURN (1)
    */

    -- Subscriber can be NULL
    IF @subscriber IS NOT NULL
    BEGIN
        EXECUTE @retcode = dbo.sp_validname @subscriber
        IF @@ERROR <> 0 OR @retcode <> 0
            RETURN (1)

        EXECUTE @retcode = dbo.sp_validname @destination_db
        IF @@ERROR <> 0 OR @retcode <> 0
            RETURN (1)
    END

    -- Replace 'all' with '%'
    if LOWER(@publication) = 'all'
        SELECT @publication = '%'

    if LOWER(@article) = 'all'
        SELECT @article = '%'

    if LOWER(@subscriber) = 'all'
        SELECT @subscriber = '%'

    if LOWER(@destination_db) = 'all'
        SELECT @destination_db = '%'

    /*
    ** Parameter Check:  @publication
    ** Check to make sure that the publication exists, that it's not NULL,
    ** and that it conforms to the rules for identifiers.
    */
    IF NOT EXISTS (SELECT * FROM syspublications WHERE name LIKE @publication)
        BEGIN
        IF @publication = '%'
                RAISERROR (14008, 11, -1)
        ELSE
                RAISERROR (20026, 11, -1, @publication)
        RETURN (1)
        END

    /*
    ** Parameter Check:  @article
    ** Check to make sure that the article exists, that it's not null,
    ** and that it conforms to the rules for identifiers.
    */
    IF NOT EXISTS (SELECT *
                     FROM sysextendedarticlesview a,
                          syspublications b
                WHERE a.name LIKE @article
                      AND a.pubid = b.pubid
                      AND b.name LIKE @publication)

        BEGIN
        IF @article = '%'
                RAISERROR (14009, 11, -1, @publication)
        ELSE
                RAISERROR (20027, 11, -1, @article)
        RETURN (1)
        END

    -- Don't check subscriber and dest_db for virtual subscriptions
    IF @subscriber IS NOT NULL and @subscriber <> N'%'
    BEGIN    
        /*
        ** Parameter Check:  @subscriber
        ** Check to make sure that the subscriber exists
        */
        select @subscriber = UPPER(@subscriber)
        
        IF NOT EXISTS (SELECT *
                         FROM master..sysservers
                        WHERE UPPER(srvname) = UPPER(@subscriber) collate database_default
                          AND (srvstatus & 4) <> 0)

            BEGIN
                RAISERROR (14063, 11, -1)
                RETURN (1)
            END
    END

    -- Wrong dest_db will be caught by the following query

    -- Check to make sure the subscription exists 
    IF  @publication <> '%' AND
        @subscriber <> '%' AND

        NOT EXISTS (SELECT *
          FROM syssubscriptions sub,
               sysextendedarticlesview art,
               syspublications pub,
               master..sysservers ss
         WHERE pub.name LIKE @publication collate database_default
           AND art.name LIKE @article collate database_default
           AND ((UPPER(ss.srvname) = UPPER(@subscriber) collate database_default
           AND sub.srvid = ss.srvid)
           OR (@subscriber is NULL 
           AND pub.allow_anonymous = 1))
           AND sub.artid = art.artid
           AND art.pubid = pub.pubid
           AND ((@destination_db = N'%') OR (sub.dest_db = @destination_db collate database_default)))
    BEGIN
        RAISERROR (14055, 16, -1)
        RETURN (1)
    END

    EXEC @retcode = dbo.sp_helpdistributor @rpcsrvname = @distributor OUTPUT,
                                       @distribdb = @distribdb OUTPUT
    IF @retcode <> 0 OR @@ERROR <> 0
        RETURN (1)

    IF @distribdb IS NULL OR @distributor IS NULL
    BEGIN
        RAISERROR (14071, 16, -1)
        RETURN (1)
    END

    DECLARE hCresyncsub CURSOR LOCAL FAST_FORWARD FOR
        -- non immediate_sync pubs
        SELECT pub.name,
               pub.immediate_sync,
               art.name,
               ss.srvname,
               sub.dest_db,
               sub.sync_type,
               sub.subscription_type,
               sub.login_name
          FROM syssubscriptions sub,
               sysextendedarticlesview art,
               syspublications pub,
               master..sysservers ss
         WHERE pub.name LIKE @publication
           AND art.name LIKE @article
           AND ((@subscriber = N'%') OR (UPPER(ss.srvname) = UPPER(@subscriber) collate database_default))
           AND sub.srvid = ss.srvid
           AND sub.artid = art.artid
           AND art.pubid = pub.pubid
           AND ((@destination_db = N'%') OR (sub.dest_db = @destination_db collate database_default))
           AND sub.status = @active
           AND pub.immediate_sync = 0
        
        UNION
        -- Immediate_sync pubs
        SELECT DISTINCT
               pub.name,
               immediate_sync,
			   -- If @article is '%', do publication level operation.
			   -- otherwise, do article level
               case @article 
					when '%' then '%'
					else art.name
					end, 
               ss.srvname,
               sub.dest_db,
               sub.sync_type,
               sub.subscription_type,
               sub.login_name
          FROM syssubscriptions sub,
               sysextendedarticlesview art,
               syspublications pub,
               master..sysservers ss
         WHERE pub.name LIKE @publication collate database_default -- Ignore @article
           AND art.name LIKE @article collate database_default
           AND ((@subscriber = N'%') OR (UPPER(ss.srvname) = UPPER(@subscriber) collate database_default))
           AND sub.srvid = ss.srvid
           AND sub.artid = art.artid
           AND art.pubid = pub.pubid
           AND ((@destination_db = N'%') OR (sub.dest_db = @destination_db collate database_default))
           AND sub.status = @active
           AND pub.immediate_sync = 1
                 
        UNION
        -- For anonymous subscribers or attached subscriptions.
        SELECT DISTINCT pub.name,
               immediate_sync,
			   -- If @article is '%', do publication level operation.
			   -- otherwise, do article level
               case @article 
					when '%' then '%'
					else art.name
					end, -- art.name is '%' from immediate_sync pub
               CONVERT(sysname, NULL), -- subscriber name (null represent virtual)
               'virtual', -- destination_db for virtual subscription is hardcoded in 
                         -- sp_MSadd_subscription.
               @automatic, -- sub.sync_type is auto tor anonymous subscriber
               @push,      -- virtual subscription is push type,
               'sa'
          FROM syspublications pub,
               sysarticles art
         WHERE pub.name LIKE @publication -- Ignore @article
           AND art.name LIKE @article
           AND art.pubid = pub.pubid
           AND pub.immediate_sync = 1
           AND (@subscriber = '%' OR @subscriber IS NULL) 
                 
    FOR READ ONLY

    OPEN hCresyncsub 

    -- Note: Don't overwrite the variables used in the cursor.
    FETCH hCresyncsub INTO @pub, @immediate_sync, @art_name, @sub_name, 
        @dest_db, @sync_type, @subscription_type, @login_name

    WHILE (@@fetch_status <> -1)
    BEGIN
        -- Security Check
        IF  suser_sname(suser_sid()) <> @login_name AND is_srvrolemember('sysadmin') <> 1  
            AND is_member ('db_owner') <> 1
        BEGIN
                RAISERROR (14126, 11, -1)
                RETURN (1)
        END

        if @sync_type = @none
        begin
		raiserror(21071, 10, -1, @art_name, @sub_name, @dest_db, @pub)
		FETCH hCresyncsub INTO @pub, @immediate_sync, @art_name, @sub_name, 
			@dest_db, @sync_type, @subscription_type, @login_name
		continue
        end

        begin tran
        save TRAN sp_reinitsubscription

        -- Reset subscription status to subscribed.
		-- It will be reactivated later as following:
		-- 1. Well known on non immediate_sync: it need to be reactivated by snapshot agent
		-- 2. Well known on immediate_sync: it will be reactivated laster in 
		-- this stored procedure to the state of virtual subscription. The status will be 
		-- active if the virtual subscription is active.
		-- 3. Anonymous (on immediate_sync by design): Only reset the status to subscribed
		-- if a single article is reinited or there's a schema change on the article. 
		-- (refer to sp_MSreinit_article.) In this case, the status will be reactivated by
		-- snapshot agent. If the whole publication is reinited and it is not for a schema 
		-- change, we don't need to do this 
		-- since the anonymous agent will automatically pick up latest snapshots after
		-- we reset the subscription guid later.

		-- If @sub_name is null, we are resetting anonymous subscriptions.
		-- Don't do this when reiniting anonymous subscription on whole publication.
        IF not (@sub_name IS NULL and @article = '%') or @for_schema_change = 1
        BEGIN
            EXEC @retcode = dbo.sp_changesubstatus
                @publication = @pub,
                @article = @art_name,
                @subscriber = @sub_name,
                @destination_db = @dest_db,
                @status = 'subscribed'
            IF @@ERROR <> 0 OR @retcode <> 0
            BEGIN
                CLOSE hCresyncsub
                DEALLOCATE hCresyncsub
                RAISERROR (14070, 16, -1)
                GOTO UNDO
            END
        END

		-- Don't do this when reiniting a single article.
        -- Reset the subscription guid at the distributor for immediate_sync publication.
     	-- Reset subscription creation datetime for all types of publication
		-- used by retention cleanup.
		if @article = '%'
		begin
			SELECT @distproc = RTRIM(@distributor) + '.' + RTRIM(@distribdb) + '.dbo.sp_MSreset_subscription'
			EXEC @retcode = @distproc 
				@publisher = @@SERVERNAME, 
				@publisher_db = @dbname, 
				@publication = @pub,
				@subscriber = @sub_name, 
				@subscriber_db = @dest_db,
				@subscription_type = @subscription_type

			IF @@ERROR <> 0 OR @retcode <> 0
			BEGIN
				CLOSE hCresyncsub
				DEALLOCATE hCresyncsub
				GOTO UNDO
			END
		end

        -- Activate the subscription again if the publication is immediate_sync and
		-- the whole publication is reinitted.
        -- Otherwise, the snapshot agent will activate the subscription
		
		-- If this is for schema change, commands generated by the LR will be invalid
		-- until the new snapshot is generated and applied so DON'T reactivate. 
		-- Let the snapshot agent do it.

        --IF (@for_schema_change = 0 AND @immediate_sync = 1 AND @subscriber IS NOT NULL)
        IF (@for_schema_change = 0 and 
				@immediate_sync = 1 AND 
				@subscriber IS NOT NULL and 
				@article = '%')
        BEGIN
            -- Set subscription status back to active again.
            EXEC @retcode = dbo.sp_changesubstatus
                @publication = @pub,
                @article = @art_name,
                @subscriber = @sub_name,
                @destination_db = @dest_db,
                @status = 'active'
            IF @@ERROR <> 0 OR @retcode <> 0
            BEGIN
                CLOSE hCresyncsub
                DEALLOCATE hCresyncsub
                RAISERROR (14070, 16, -1)
                GOTO UNDO
            END
        END
		
		-- If article level reinit, reinit dependent articles in the publication as well	
		if @article <> '%'
		begin
			-- Reinit articles on which the current article depends on.
			declare @objid int, @pubid int, @srvid smallint,
				@pre_creation_cmd tinyint
			select @pubid = pubid from syspublications where name = @pub
			select @objid = objid,
					@pre_creation_cmd = pre_creation_cmd from sysarticles where 
				pubid = @pubid and 
				name = @art_name
			-- @sub_name is from sysservers, no need to upper it.
			select @srvid = srvid from master..sysservers where srvname = @sub_name collate database_default
			-- set virtual id if needed
			if @srvid is null
				select @srvid = -1

			-- Have to use temp cursor name otherwise we will get a 'cursor already exists' error
			-- in recursive calls.
			DECLARE #hCdep CURSOR LOCAL FAST_FORWARD FOR
				SELECT distinct art.name from sysextendedarticlesview art, syssubscriptions s where
					art.pubid = @pubid and
					s.artid = art.artid and
					s.srvid = @srvid and
					s.dest_db = @dest_db and
					s.status = @active and
					-- Has dri on referencing table or not
					(convert(int, substring(art.schema_option, len(art.schema_option) - 2 + 1, 2)) & 0x00000200 <> 0 and
					  -- If the article schema option includes DRI, reinit articles that have 
					  -- forein key relationship on this table, have to do this
					  -- otherwise dist will fail because we cannot drop or delete base table.
					  exists ( select * from  sysreferences r where
							r.rkeyid = @objid and
							art.objid = r.fkeyid) or
					  -- If there's a schema bound view on this table, reinit that view etc.
					  -- We have to do this for schema bound view other wise, we cannot drop the table
					 -- Only do it if precreation command is 'drop table'
					 (@pre_creation_cmd = 1 and
					  exists ( select * from sysdepends d where
							d.depid = @objid and
							art.objid = d.id and
							objectproperty(art.objid, 'IsSchemaBound') = 1)))
			FOR READ ONLY

			OPEN #hCdep

			-- Note: @art_name is changed
			FETCH #hCdep INTO @art_name

			WHILE (@@fetch_status <> -1)
			BEGIN
				EXEC @retcode = dbo.sp_reinitsubscription
					@publication = @pub,
					@article = @art_name,
					@subscriber = @sub_name,
					@destination_db = @dest_db,
					@for_schema_change = @for_schema_change
				IF @@ERROR <> 0 OR @retcode <> 0
					GOTO UNDO
				FETCH #hCdep INTO @art_name
			END
			
			CLOSE #hCdep
			DEALLOCATE #hCdep
		end
	
        COMMIT TRAN 

        FETCH hCresyncsub INTO @pub, @immediate_sync, @art_name, @sub_name, 
            @dest_db, @sync_type, @subscription_type, @login_name
    END

    CLOSE hCresyncsub
    DEALLOCATE hCresyncsub

    RETURN(0)

UNDO:
    IF @@TRANCOUNT > 0
    begin
        ROLLBACK TRAN sp_reinitsubscription
        COMMIT TRAN
    end
    return 1
go

EXEC dbo.sp_MS_marksystemobject sp_reinitsubscription
grant execute on dbo.sp_reinitsubscription to public
--------------------------------------------------------------------------------
--. sp_scriptpublicationcustomprocs
--------------------------------------------------------------------------------
if exists ( select * from sysobjects
    where type = 'P ' and name = 'sp_scriptpublicationcustomprocs')
    drop procedure sp_scriptpublicationcustomprocs

raiserror('Creating procedure sp_scriptpublicationcustomprocs',0,-1)
go
--
-- Name: sp_scriptpublicationcustomprocs
--
-- Description: This is a utility procedure for scripting out the 
--              article "custom" ins/upd/del procedures for all 
--              table articles in a publication with the auto-generate custom
--              procedure schema option enabled. This is particularly useful 
--              and in fact specifically designed for setting up no-sync 
--              subscriptions. 
-- 
-- Notes: 1) Reconciliation procedures for concurrent snapshot will
--           not be scripted by this procedure. It does not really make 
--           sense to have concurrent snapshots for no-sync subscriptions.
--        2) Custom procedures will not be scripted out for articles 
--           without the auto-generate custom procedure (0x2) schema_option.
--
-- Parameter: @publication sysname
--
-- Security: Execute permission is granted to public; procedural security 
--           check is performed inside the procedure to restrict access
--           to sysadmins and db_owners of current database. 
--
-- Example: exec Northwind.dbo.sp_scriptpublicationcustomprocs @publication = N'Northwind'
--
create procedure dbo.sp_scriptpublicationcustomprocs
    @publication sysname
as
begin
    set nocount on

    declare @retcode          int,
            @artid            int,
            @pubid            int,
            @cursor_allocated bit,
            @cursor_opened    bit,
            @table_created    bit,
            @ins_cmd          nvarchar(255),
            @upd_cmd          nvarchar(255),
            @del_cmd          nvarchar(255),
            @article          sysname,
            @schema_option    int,
            @repl_freq        int,
            @formattedmessage nvarchar(4000)
    
    -- Initializations 
    select @retcode = 0,
           @pubid = null,
           @cursor_allocated = 0,
           @cursor_opened = 0,
           @table_created = 0

    -- Security check: Sysadmins and db_owners only
    exec @retcode = sp_MSreplcheck_publish
    if @retcode <> 0 or @@error <> 0
    begin
        return 1
    end

    -- Make sure the current database is enabled for transaction replication
    if not exists (select * 
                     from master..sysdatabases 
                    where name = db_name() collate database_default
                      and (category & 0x1) <> 0)
    begin
        raiserror(14013, 16, -1)
        return 1
    end
 
    -- Parameter check: The specified @publication is a valid Transactional publication

    select @pubid = pubid, 
           @repl_freq = repl_freq
      from dbo.syspublications
     where name = @publication
    if @pubid is null
    begin
        raiserror(20026, 16, -1, @publication)
        return 1            
    end
    
    -- Don't script out custom procs for a snapshot publication
    if @repl_freq = 1
    begin
        raiserror(21515, 16, -1, @publication) 
        return 1
    end
    -- Create temp table for procedure text
    create table #proctext_scriptpublicationcustomprocs
    (
        line_no int identity(1,1) primary key,
        line nvarchar(4000)
    ) 
    if @@error<>0
    begin
        return 1
    end    
    select @table_created = 1
    
    -- Script header
    select @formattedmessage = formatmessage(21516, @publication, db_name())
    if @@error <> 0 begin select @retcode = 1 goto Failure end
    insert into #proctext_scriptpublicationcustomprocs values(N'--')
    insert into #proctext_scriptpublicationcustomprocs values(N'-- ' + @formattedmessage)
    insert into #proctext_scriptpublicationcustomprocs values(N'--')
    insert into #proctext_scriptpublicationcustomprocs values(N'')
    insert into #proctext_scriptpublicationcustomprocs values(N'')

    -- Open cursor through all table articles in the specified publication and script out
    -- custom procs as necessary
    
    declare harticle cursor local fast_forward for
        select artid, ins_cmd, upd_cmd, del_cmd, name, fn_replgetbinary8lodword(schema_option)
          from sysarticles
         where pubid = @pubid
           and (type & 1) <> 0
    if @@error <> 0
    begin
        select @retcode = 1
        goto Failure
    end
    select @cursor_allocated = 1

    open harticle
    if @@error <> 0
    begin
        select @retcode = 1
        goto Failure
    end
    select @cursor_opened = 1
    
    fetch harticle into @artid, @ins_cmd, @upd_cmd, @del_cmd, @article, @schema_option

    while (@@fetch_status<>-1)
    begin        
        
        if (@schema_option & 2) = 0
        begin
            
            select @formattedmessage = formatmessage(21517,@article)
            if @@error <> 0 begin select @retcode = 1 goto Failure end
            insert into #proctext_scriptpublicationcustomprocs values(N'----')
            insert into #proctext_scriptpublicationcustomprocs values(N'---- ' + @formattedmessage)
            insert into #proctext_scriptpublicationcustomprocs values(N'----')
            insert into #proctext_scriptpublicationcustomprocs values(N'')
            goto SkipArticle
        end 

        select @formattedmessage = formatmessage(21518,@article)
        if @@error <> 0 begin select @retcode = 1 goto Failure end
        insert into #proctext_scriptpublicationcustomprocs values(N'----')
        insert into #proctext_scriptpublicationcustomprocs values(N'---- ' + @formattedmessage)
        insert into #proctext_scriptpublicationcustomprocs values(N'----')
        insert into #proctext_scriptpublicationcustomprocs values(N'')

        if lower(substring(@ins_cmd,1,len(N'call'))) = N'call'
        begin
            
            insert into #proctext_scriptpublicationcustomprocs exec @retcode = sp_scriptinsproc @artid
            if @@error <> 0 or @retcode <> 0
            begin
                select @retcode = 1
                goto Failure
            end
            insert into #proctext_scriptpublicationcustomprocs values('go')
            insert into #proctext_scriptpublicationcustomprocs values('')
        end
        else if lower(substring(@ins_cmd,1,len(N'sql'))) = N'sql'
        begin
            select @formattedmessage = formatmessage(21519)
            if @@error <> 0 begin select @retcode = 1 goto Failure end                
            insert #proctext_scriptpublicationcustomprocs values('-- ' + @formattedmessage)
            insert #proctext_scriptpublicationcustomprocs values('')
        end
        else
        begin
            select @formattedmessage = formatmessage(21520,@ins_cmd)
            if @@error <> 0 begin select @retcode = 1 goto Failure end                
            insert #proctext_scriptpublicationcustomprocs values('-- ' + @formattedmessage)
            insert #proctext_scriptpublicationcustomprocs values('')
        end

        if lower(substring(@upd_cmd,1,len(N'call'))) = N'call'
        begin
            insert into #proctext_scriptpublicationcustomprocs exec @retcode = sp_scriptupdproc @artid
            if @@error <> 0 or @retcode <> 0
            begin
                select @retcode = 1
                goto Failure
            end
            insert into #proctext_scriptpublicationcustomprocs values('go')
            insert into #proctext_scriptpublicationcustomprocs values('')

        end
        else if lower(substring(@upd_cmd,1,len(N'mcall'))) = N'mcall'
        begin
            insert into #proctext_scriptpublicationcustomprocs exec @retcode = sp_scriptmappedupdproc @artid
            if @@error <> 0 or @retcode <> 0
            begin
                select @retcode = 1
                goto Failure
            end
            insert into #proctext_scriptpublicationcustomprocs values('go')
            insert into #proctext_scriptpublicationcustomprocs values('')
        end
        else if lower(substring(@upd_cmd,1,len(N'xcall'))) = N'xcall'
        begin
            insert into #proctext_scriptpublicationcustomprocs exec @retcode = sp_scriptxupdproc @artid
            if @@error <> 0 or @retcode <> 0
            begin
                select @retcode = 1
                goto Failure
            end
            insert into #proctext_scriptpublicationcustomprocs values('go')
            insert into #proctext_scriptpublicationcustomprocs values('')
        end
        else if lower(substring(@upd_cmd,1,len(N'sql'))) = N'sql'
        begin
            select @formattedmessage = formatmessage(21519)
            if @@error <> 0 begin select @retcode = 1 goto Failure end                
            insert #proctext_scriptpublicationcustomprocs values('-- ' + @formattedmessage)
            insert #proctext_scriptpublicationcustomprocs values('')
        end
        else
        begin
            select @formattedmessage = formatmessage(21520,@upd_cmd)
            if @@error <> 0 begin select @retcode = 1 goto Failure end                
            insert #proctext_scriptpublicationcustomprocs values('-- ' + @formattedmessage)
            insert #proctext_scriptpublicationcustomprocs values('')
        end

        if lower(substring(@del_cmd,1,len(N'call'))) = N'call'
        begin
            insert into #proctext_scriptpublicationcustomprocs exec @retcode = sp_scriptdelproc @artid
            if @@error <> 0 or @retcode <> 0
            begin
                select @retcode = 1
                goto Failure
            end
            insert into #proctext_scriptpublicationcustomprocs values('go')
            insert into #proctext_scriptpublicationcustomprocs values('')
        end
        else if lower(substring(@del_cmd,1,len(N'xcall'))) = N'xcall'
        begin
            insert into #proctext_scriptpublicationcustomprocs exec @retcode = sp_scriptxdelproc @artid
            if @@error <> 0 or @retcode <> 0
            begin
                select @retcode = 1
                goto Failure
            end
            insert into #proctext_scriptpublicationcustomprocs values('go')
            insert into #proctext_scriptpublicationcustomprocs values('')
        end
        else if lower(substring(@del_cmd,1,len(N'sql'))) = N'sql'
        begin
            select @formattedmessage = formatmessage(21519)
            if @@error <> 0 begin select @retcode = 1 goto Failure end                
            insert #proctext_scriptpublicationcustomprocs values('-- ' + @formattedmessage)
            insert #proctext_scriptpublicationcustomprocs values('')
        end
        else
        begin
            select @formattedmessage = formatmessage(21520,@del_cmd)
            if @@error <> 0 begin select @retcode = 1 goto Failure end                
            insert #proctext_scriptpublicationcustomprocs values('-- ' + @formattedmessage)
            insert #proctext_scriptpublicationcustomprocs values('')
        end
SkipArticle:
        fetch harticle into @artid, @ins_cmd, @upd_cmd, @del_cmd, @article, @schema_option
    end
    
    select '--' = line from #proctext_scriptpublicationcustomprocs order by line_no asc
   
Failure:
    if @table_created <> 0
    begin
        drop table #proctext_scriptpublicationcustomprocs
    end
    
    if @cursor_opened <> 0
    begin
        close harticle
    end

    if @cursor_allocated <> 0
    begin
        deallocate harticle
    end 
    return @retcode    
end
go

exec sp_MS_marksystemobject sp_scriptpublicationcustomprocs
grant execute on dbo.sp_scriptpublicationcustomprocs to public

--------------------------------------------------------------------------------
--. sp_MScomputearticlecreationorder
--------------------------------------------------------------------------------
if exists ( select * from sysobjects 
    where type = 'P ' and name = 'sp_MScomputearticlescreationorder' )
begin
    drop procedure sp_MScomputearticlescreationorder
end
print ''
print 'Creating procedure sp_MScomputearticlescreationorder'
go
CREATE PROCEDURE sp_MScomputearticlescreationorder
    @publication sysname
AS
    SET NOCOUNT ON
    DECLARE @pubid int 
    DECLARE @max_level int
    DECLARE @current_level int
    DECLARE @update_level int
    DECLARE @limit int
    DECLARE @result int

    SELECT @pubid = NULL
    -- Get the pubid from syspublications 
    SELECT @pubid = pubid 
      FROM syspublications
     WHERE name = @publication

    IF @@ERROR <> 0
        RETURN (1)

    IF @pubid IS NULL
    BEGIN
        RAISERROR(20026, 16, -1, @publication)
        RETURN (1)
    END

    EXEC @result = sp_getapplock @Resource = @publication, 
				@LockMode = N'Shared', 
				@LockOwner = N'Session', 
				@LockTimeout = 0

    IF @result < 0
    BEGIN
        RAISERROR(21385, 16, -1, @publication)
        RETURN (1)
    END

    -- Find out the total number of articles in this publication and
    -- compute the maximum tree height based on the number of articles in 
    -- the publication. Here, the tree height is counted from the
    -- leaf-nodes towards the root(s)
    SELECT @max_level = COUNT(*) + 10,
           @limit =2 *  COUNT(*) + 11 
      FROM sysextendedarticlesview 
     WHERE pubid = @pubid
 
    IF @@ERROR <> 0
    BEGIN
        RETURN (1)
    END
   
    -- The following temp table contains the minimal amount of 
    -- article information that we want to keep around and the current
    -- computed tree level of the article
    CREATE TABLE #article_level_info
    (
        article         sysname collate database_default not null,
        source_objid    INT     NOT NULL,
        tree_level      INT     NOT NULL,
        ref_level       INT     NOT NULL,
        major_type      TINYINT NOT NULL  -- 1-view&func, 0-other 
    )  
   
    CREATE CLUSTERED INDEX ucarticle_level_info 
        ON #article_level_info(source_objid)

    IF @@ERROR <> 0
    BEGIN
        GOTO Failure
    END

    -- Populate the article level info table. All articles will be
    -- assigned 0 as their initial tree level. Having 
    -- a tree level of 0 means that the algorithm hasn't discovered 
    -- any objects that the article depends on within the publication.

    INSERT INTO #article_level_info 
    SELECT name, objid, 0, 0, 
        CASE type    
            WHEN 0x40 THEN 1
            WHEN 0x80 THEN 1
            ELSE 0 
        END
      FROM sysextendedarticlesview
     WHERE pubid = @pubid
      
    -- To jump-start the algorithm, update the tree_level of 
    -- all articles with no dependency to @max_level.

    UPDATE #article_level_info 
       SET tree_level = @max_level
     WHERE NOT EXISTS (SELECT * 
                         FROM sysdepends 
                        WHERE source_objid = id
                          and id <> depid)
    IF @@ERROR <> 0
        GOTO Failure

    -- For each increasing tree level starting from @max_level, update the 
    -- the tree_level of articles depending on objects at the current
    -- level to current level + 1
    SELECT @current_level = @max_level
    WHILE 1 = 1
    BEGIN
        SELECT @update_level = @current_level + 1

        UPDATE #article_level_info
           SET tree_level = @update_level
          FROM #article_level_info 
        INNER JOIN sysdepends d
            ON #article_level_info.source_objid = d.id 
        INNER JOIN #article_level_info ali1
            ON (d.depid = ali1.source_objid       
               AND ali1.tree_level = @current_level
               AND d.id <> d.depid)
    
        -- Terminate the algorithm if we cannot find any articles 
        -- depending on articles at the current level     
        IF @@ROWCOUNT = 0
            GOTO PHASE1

        IF @@ERROR <> 0
            GOTO Failure

        SELECT @current_level = @current_level + 1

        -- Although there should not be any circular 
        -- dependencies among the articles, the following
        -- check is performed to guarantee that 
        -- the algorithm will terminate even if there 
        -- is circular dependency among the articles
        
        -- Note that with at least one node per level,
        -- the current level can never exceed the total 
        -- number of articles (nodes) unless there is
        -- circular dependency among the articles.
        
        -- @limit is defined to be # of articles + 1
        -- although @limit = # of articles - 1 will be
        -- sufficient. This is to make absolutely sure that 
        -- the algorithm will never terminate too early

        IF @current_level > @limit
            GOTO PHASE1
    END

PHASE1:

    -- There may be interdependencies among articles 
    -- that haven't been included in the previous calculations so
    -- we compute the proper order among these articles here.
    SELECT @limit = @max_level - 9
    SELECT @current_level = 0
    WHILE 1 = 1
    BEGIN
        SELECT @update_level = @current_level + 1
        
        UPDATE #article_level_info 
           SET tree_level = @update_level
          FROM #article_level_info
        INNER JOIN sysdepends d
            ON (#article_level_info.source_objid = d.id
                AND #article_level_info.tree_level < @max_level) 
        INNER JOIN #article_level_info ali1
            ON (d.depid = ali1.source_objid
                AND ali1.tree_level = @current_level
                AND d.id <> d.depid)
        IF @@ROWCOUNT = 0
            GOTO PHASE2
        
        IF @@ERROR <> 0
            GOTO Failure

        SELECT @current_level = @current_level + 1
        IF @current_level > @limit
            GOTO PHASE2
    END         

PHASE2:

    -- Since transactional doesn't keep the nickname around in 
    -- sysmergearticles as merge does, we need to compute FK/PK ordering on 
    -- the fly. 
    SELECT @current_level = 0
    SELECT @limit = @max_level - 9
    WHILE 1 = 1
    BEGIN
        SELECT @update_level = @current_level + 1
        
        UPDATE #article_level_info
           SET ref_level = @update_level
          FROM #article_level_info
        INNER JOIN sysreferences r
            ON (#article_level_info.source_objid = r.fkeyid
                and r.rkeyid <> r.fkeyid)
        INNER JOIN #article_level_info ali1
            ON (r.rkeyid = ali1.source_objid 
                AND ali1.ref_level = @current_level)
        IF @@ROWCOUNT = 0
            GOTO PHASE3

        IF @@ERROR <> 0
            GOTO Failure

        SELECT @current_level = @current_level + 1
        IF @current_level > @limit
            GOTO PHASE3
    END

PHASE3:

    -- Select the articles out of #article_level_info 
    -- in ascending order of tree_level. This will give
    -- the proper order in which articles can be created
    -- without violating the internal dependencies among
    -- themselves. Note that this algorithm still allows 
    -- unresolved external references outside the publication.
    -- All this algorithm can guarantee is that all articles will
    -- be created successfully using the resulting order if 
    -- there is no dependent object outside the publication. 
    -- We need to order the articles in reverse ref_level
    -- to account for FK/PK constraints when dropping/deleting rows/truncating
    -- tables on the Subscriber.

    SELECT article
      FROM #article_level_info
    ORDER BY major_type ASC, tree_level ASC, ref_level DESC

    DROP TABLE #article_level_info
    RETURN (0)

Failure:

    DROP TABLE #article_level_info
    RETURN (1)
GO

exec dbo.sp_MS_marksystemobject sp_MScomputearticlescreationorder
grant exec on dbo.sp_MScomputearticlescreationorder to public

--------------------------------------------------------------------------------
--. sp_getqueuedrows
--------------------------------------------------------------------------------
if exists ( select * from sysobjects
        where type = 'P ' and name = 'sp_getqueuedrows' )
    drop procedure sp_getqueuedrows    

--
-- sp_getqueuedrows
--
-- sp_getqueuedrows is invoked by user to find the rows of given table on
-- a subscriber database that have participated in a queued update and 
-- currently have not been resolved by the queue reader agent - i.e. current
-- have an outstanding queued transaction. The table has to be part of 
-- queued subscription.
-- 
-- Parameters
-- 	@tablename	sysname -- name of table
--	@user		sysname -- optional name of user
--	@tranid		nvarchar(70) -- optional tranid to filter results on
--
-- Returns
--	0 if success 
--	1 if failure
--
-- Resultset
-- 	Rows that currently have at least one queued transaction for this
--	subscribed table
--
raiserror('Creating procedure sp_getqueuedrows', 0,1)
go
create proc sp_getqueuedrows (
	@tablename sysname
	,@owner sysname = NULL
	,@tranid nvarchar(70) = NULL
)
as
begin
	set nocount on
	declare @retcode int
		,@dbname sysname
		,@qualified_tabname nvarchar(1000)
		,@tabid int
		,@agent_id int
		,@publisher sysname
		,@publisher_db sysname
		,@publication sysname
		,@queue_id sysname
		,@update_mode int
		,@failover_id int
		,@cmd nvarchar(4000)
		,@queue_server sysname
		,@indid int
		,@indkey int
		,@key sysname
		,@colid int
		,@typestring nvarchar(4000)
		,@artcol int
		,@xpinputstr nvarchar(4000)
		,@selectcl nvarchar(4000)
		,@joincl nvarchar(4000)

	--
	-- prepare the fully qualified table
	--
	select @owner = case when (@owner IS NULL) then N'dbo' else @owner end
			,@dbname = db_name()	
	select @qualified_tabname = quotename(@dbname) + N'.' 
					+ quotename(@owner) + N'.' + quotename(@tablename)
	select @tabid = object_id(@qualified_tabname)
	if (@tabid IS NULL) or (@tabid = 0)
	begin
		-- error
		raiserror('sp_getqueuedrows(debug): could not locate table %s', 16, 1, @qualified_tabname)
		return 1
	end

	--
	-- current user should have SELECT permission on the table
	--
	if ( permissions(@tabid) & 0x1 = 0 )
	begin
		-- error
		raiserror('sp_getqueuedrows(debug): current user does not have SELECT permission on table %s', 16, 1, @qualified_tabname)
		return 1
	end

	--
	-- make sure the table is participating in a active queued subscription
	--
	select @agent_id = agent_id 
	from dbo.MSsubscription_articles 
	where dest_table = @tablename and owner = @owner

	if (@agent_id IS NULL)
	begin
		-- error
		raiserror('sp_getqueuedrows(debug): table %s is not part of any active initialized queued subscription. Make sure your queued subscriptions are properly initialized', 16, 1, @qualified_tabname)
		return 1
	end

	--
	-- get the details for the subscription
	--
	select @publisher = publisher
			,@publisher_db = publisher_db
			,@publication = publication
			,@update_mode = update_mode
			,@queue_server = queue_server
			,@queue_id = queue_id
			,@failover_id = failover_mode
	from dbo.MSsubscription_agents where id = @agent_id
	if (@update_mode not in (2,3,4,5))
	begin
		-- error
		raiserror('sp_getqueuedrows(debug): table %s is not part of any active initialized queued subscription. Make sure your queued subscriptions are properly initialized', 16, 2, @qualified_tabname)
		return 1
	end
	
	--
	-- If we are in Immediate Failover mode - no queued messages
	--
	if (@update_mode in (3,5) and (@failover_id = 0))
	begin
		--
		-- do an empty select on the source table and return
		--
		select @cmd = N'declare @dummy_action nvarchar(10), @dummy_tranid nvarchar(70)
					select action=@dummy_action, tranid=@dummy_tranid, * from ' + 
					@qualified_tabname + N' where 1 = 2 '
		exec (@cmd)
		return 0
	end

	if (@update_mode in (2,3))
	begin
		--
		-- set queue prefix for MSMQ cases
		--
		select @queue_id = N'DIRECT=OS:' + @queue_server + N'\PRIVATE$\' + @queue_id
	end
	else
	begin
		--
		-- Check the queue table for SQLQ
		--
		if not exists (select * from dbo.MSreplication_queue
		where UPPER(publisher) = UPPER(@publisher) and
				publisher_db = @publisher_db and
				publication = @publication and
				tranid = case when @tranid IS NULL then tranid else @tranid end)
		begin
			--
			-- do an empty select on the source table and return
			--
			select @cmd = N'declare @dummy_action nvarchar(10), @dummy_tranid nvarchar(70)
					select action=@dummy_action, tranid=@dummy_tranid, * from ' + 
					@qualified_tabname + N' where 1 = 2 '
			exec (@cmd)
			return 0
		end
	end

	--
	-- Now find the PK columns for this table
	--
	select @indkey = 1
		,@artcol = 0
		,@xpinputstr = N''
		,@selectcl = N''
		,@joincl = N''
		,@retcode = 0

	select @indid = i.indid 
	from dbo.sysindexes i 
	where ((i.status & 2048) != 0) and (i.id = @tabid)
	if (@indid is null)
	begin
		raiserror('sp_getqueuedrows(debug): Cannot find primary key for %s', 
				16, -1, @qualified_tabname)
		return 1
	end
	
	--
	-- create an enumeration of all the columns that are part of PK
	--
	create table #pkcoltab(pkindex int identity, keyname sysname collate database_default not null)
	while (@indkey <= 16)
	begin
		select @key = index_col( @qualified_tabname, @indid, @indkey )
		if (@key is null)
			break
		else
			insert into #pkcoltab(keyname) values(@key)

		select @indkey = @indkey + 1
	end

	--
	-- initialize the commands that we need to build
	--
	if exists (select * from dbo.sysobjects where name = 'tempcrtcmd')
		drop table tempcrtcmd
	create table tempcrtcmd (c1 int identity NOT NULL, procedure_text nvarchar(4000) NULL)
	
	select @cmd = N'create table tempqjointab (action nvarchar(10), tranid nvarchar(70) '
	insert into tempcrtcmd(procedure_text) values(@cmd)

	--
	-- now walk through each article col and if it is
	-- a part of PK, then check find the column position of the key
	-- corresponding to any article column is set
	--
	DECLARE #hCColid CURSOR LOCAL FAST_FORWARD FOR 
		select colid, [name] from dbo.syscolumns 
		where id = @tabid order by colid asc

	OPEN #hCColid
	FETCH #hCColid INTO @colid, @key
	WHILE (@@fetch_status != -1)
	begin
		exec sp_MSget_type @tabid, @colid, NULL, @typestring output
		if ((@typestring IS NOT NULL) and (@typestring != N'timestamp'))
		begin
			--
			-- this column is part of the article
			--
			select @artcol = @artcol + 1
			if exists (select * from #pkcoltab where keyname = @key)
			begin
				--
				-- this column is part of PK (offset and precision, scale)
				-- prepare the input string for XP
				-- prepare the create join table command
				-- prepare the join and select clause for the result
				--
				select @xpinputstr = @xpinputstr + N';' + cast(@artcol as nvarchar) 
				if (@typestring = N'bigint')
					select @xpinputstr = @xpinputstr + N'(19,0)'
				else if (@typestring like N'decimal%') or (@typestring like N'numeric%')
				begin
					declare @startpos int
							,@endpos  int

					select @startpos = charindex(N'(', @typestring, 1)
					select @endpos = charindex(N')', @typestring, @startpos)
					select @xpinputstr = @xpinputstr + substring(@typestring, @startpos, (@endpos - @startpos + 1))
				end
				select @cmd = N',' + quotename(@key) + N' ' + @typestring
				insert into tempcrtcmd(procedure_text) values(@cmd)
				select @selectcl = @selectcl + N', b.' + quotename(@key)
				
				if (@joincl = N'')
				begin
					select @joincl = @joincl + N'a.' + quotename(@key) + N' = b.' + quotename(@key)
				end
				else
				begin
					select @joincl = @joincl + N'and a.' + quotename(@key) + N' = b.' + quotename(@key)
				end				
			end
			else
			begin
				--
				-- this column is not part of PK
				-- build the select clause for this column
				--
				select @selectcl = @selectcl + N', a.' + quotename(@key)
			end
		end		

		--
		-- get the next column
		--
		FETCH #hCColid INTO @colid, @key
	end
	CLOSE #hCColid
	DEALLOCATE #hCColid
	drop table #pkcoltab

	--
	-- create the join table now
	--
	select @cmd = N') '
	insert into tempcrtcmd(procedure_text) values(@cmd)
	if exists (select * from dbo.sysobjects where name = N'tempqjointab')
		drop table tempqjointab
	select @cmd = 'select procedure_text from dbo.tempcrtcmd order by c1'
	exec @retcode = master..xp_execresultset @cmd, @dbname
	if (@retcode != 0)
		goto cleanup

	--
	-- populate the join table now
	--
	if (@update_mode in (2,3))
	begin
		--
		-- MSMQ case : one call to the xp should populate the join table
		--
		insert into tempqjointab
			exec master.dbo.xp_readpkfromqueue @tablename, @queue_id, @xpinputstr, @tranid
	end
	else
	begin
		--
		-- SQLQ case : select the data for this subscription and call the
		-- xp for each row in the cursor to populate the join table
		--
		declare @spancount int
				,@data varbinary(8000)
				,@state bit
		
		declare #hcurQInfo cursor local FAST_FORWARD FOR
		select data, cmdstate, tranid
		from dbo.MSreplication_queue
		where UPPER(publisher) = UPPER(@publisher) and
				publisher_db = @publisher_db and
				publication = @publication and
				tranid = case when @tranid IS NULL then tranid else @tranid end and
				commandtype = 1
		order by orderkey
		FOR READ ONLY

		select @spancount = 0
		open #hcurQInfo
		fetch #hcurQInfo into @data, @state, @tranid
		while (@@FETCH_STATUS = 0)
		begin
			declare @qbdata0 varbinary(8000)
					,@qbdata1 varbinary(8000)

			if (@state = 1)
			begin
				--
				-- command spanning more than a row
				-- we will allow spanning upto 2 rows
				--
				if (@spancount = 0)
					select @qbdata0 = @data
				else
				begin
					raiserror('sp_getqueuedrows(debug): Queued data spans 3 rows, cannot proceed', 16, -1)
					close #hcurQInfo
					deallocate #hcurQInfo
					select @retcode = 1
					goto cleanup
				end
				select @spancount = @spancount + 1
			end
			else
			begin
				--
				-- final row for the command
				--
				if (@spancount = 0)
					select @qbdata0 = @data				
				else if (@spancount = 1)
					select @qbdata1 = @data
				else
				begin
					raiserror('sp_getqueuedrows(debug): Queued data spans 3 rows, cannot proceed', 16, -1)
					close #hcurQInfo
					deallocate #hcurQInfo
					select @retcode = 1
					goto cleanup
				end

				--
				-- call the xp to populate the join table
				--
				insert into tempqjointab
					exec master.dbo.xp_readpkfromvarbin @tablename, @xpinputstr, @tranid, @spancount, @qbdata0, @qbdata1

				--
				-- reset the span count
				--
				select @spancount = 0
			end

			--
			-- fetch the next row
			--
			fetch #hcurQInfo into @data, @state, @tranid
		end
		close #hcurQInfo
		deallocate #hcurQInfo
	end

	--
	-- Now perform the join
	--
	select @cmd = N'select b.action, b.tranid ' + @selectcl 
		+ N'from ' + @qualified_tabname + N' a right join tempqjointab b on (' + @joincl + N') '
	exec (@cmd)
	
	--
	-- all done
	--
cleanup:	
	if exists (select * from dbo.sysobjects where name = N'tempqjointab')
		drop table tempqjointab
	if exists (select * from dbo.sysobjects where name = 'tempcrtcmd')
		drop table tempcrtcmd
	return @retcode
end
go

EXEC dbo.sp_MS_marksystemobject sp_getqueuedrows
grant execute on dbo.sp_getqueuedrows to public

--------------------------------------------------------------------------------
--. sp_MSmaketrancftproc
--------------------------------------------------------------------------------
if exists (select * from sysobjects
        where type = 'P '
            and name = 'sp_MSmaketrancftproc')
    drop procedure sp_MSmaketrancftproc    

--
-- procedure to generate script conflict reporting procedure
-- for a given queued publication article
--

print ''
print 'Creating procedure sp_MSmaketrancftproc'
go

create procedure sp_MSmaketrancftproc (
	@article sysname, 
	@publication sysname,
	@is_debug bit=0)
as
BEGIN
declare @source_table nvarchar(540)
		,@owner sysname
		,@procname sysname
		,@source_objid int
		,@artid int
		,@pubid int
		,@conflict_tableid int
		,@conflict_table	sysname
		,@conflict_proc_id int
		,@indid int
		,@indkey int
		,@ind_col_name sysname
		,@qualname   nvarchar(540)
		,@destqualname   nvarchar(540)
		,@destowner sysname
		,@dbname sysname
		,@retcode smallint
		,@retain_varname int

declare @colid		int
		,@colname	sysname
		,@coltype	sysname
		,@ccoltype	sysname
		,@rowcnt	int

declare @argtabempty	bit
		,@seltabempty	bit
		,@sel2tabempty	bit
		,@valtabempty 	bit
		,@paramtabempty	bit
		,@where_clausetabempty bit
		,@decltabempty bit
		,@assigntabempty bit
		,@compinsertabempty bit

declare @argterm	nvarchar(4000)
		,@selterm	nvarchar(4000)
		,@sel2term	nvarchar(4000)
		,@updterm	nvarchar(4000)
		,@valterm 	nvarchar(4000)
		,@paramterm	nvarchar(4000)
		,@where_term nvarchar(4000)
		,@declterm	nvarchar(4000)
		,@assignterm nvarchar(4000)
		,@compinsterm nvarchar(4000)

declare @cmd		nvarchar(4000)

set nocount on

--
-- prepare the proc name and get the other parameters
--
select @artid = a.artid, @pubid = a.pubid, @source_table = object_name(a.objid), 
		@source_objid = a.objid, @destowner = a.dest_owner 
from sysarticles a, syspublications p
        where a.name = @article and
              p.name = @publication and
              a.pubid = p.pubid

-- Get the object owner name
select @owner = u.name 
from sysusers u, sysobjects o 
where o.id = @source_objid and o.uid = u.uid

--
-- Prepare the proc name 
-- The source table should be owner qualified
--
select @source_table = QUOTENAME(@owner) + N'.' + QUOTENAME(@source_table)
exec @retcode = sp_MSgettranconflictname @publication=@publication, 
					@source_object= @source_table, 
					@str_prefix='sp_MScft_', 
					@conflict_table=@procname OUTPUT

--
-- The conflict table should exist before we do any conflict procs
--
select @conflict_tableid = conflict_tableid, 
		@conflict_table = OBJECT_NAME(conflict_tableid) 
from sysarticleupdates
where artid = @artid and pubid = @pubid
if ( @conflict_tableid is NULL)
	return (1)
--
-- To check if specified object exists in current database
--
select @qualname = case when (@owner is null or @owner = ' ') then QUOTENAME(@conflict_table)
					else QUOTENAME(@owner) + N'.' + QUOTENAME(@conflict_table) end
if (object_id(@qualname) is NULL)
	return (1)

--
-- The source table should have an unique index
--
exec @indid = dbo.sp_MStable_has_unique_index @source_objid
if (@indid = 0)
	return (1)

--
-- Get all the columns participating in the index of the source table
--
create table #indcoltab ( colname sysname collate database_default )
select @indkey = 1;
while (@indkey <= 16)
begin
	select @ind_col_name = index_col(@source_table, @indid, @indkey)
	if (@ind_col_name is not NULL) 
		insert into #indcoltab(colname) values(@ind_col_name)
	else
		select @indkey = 16

	select @indkey = @indkey + 1
end

--
-- prepare destination table name (required for decentralized conflict processing)
--
select @destqualname = case when (@destowner is null or @destowner = ' ') 
					then QUOTENAME(@conflict_table)
					else QUOTENAME(@destowner) + N'.' + QUOTENAME(@conflict_table) end

-- build the lists
select @argtabempty = 1
	,@valtabempty = 1
	,@paramtabempty = 1
	,@seltabempty = 1
	,@sel2tabempty = 1
	,@decltabempty = 1
	,@assigntabempty = 1
	,@where_clausetabempty = 1
	,@compinsertabempty = 1

create table #argtab ( c1 int identity NOT NULL, procedure_text nvarchar(4000) collate database_default null)
create table #valtab ( c1 int identity NOT NULL, procedure_text nvarchar(4000) collate database_default null)
create table #paramtab ( c1 int identity NOT NULL, procedure_text nvarchar(4000) collate database_default null)
create table #seltab ( c1 int identity NOT NULL, procedure_text nvarchar(4000) collate database_default null)
create table #sel2tab ( c1 int identity NOT NULL, procedure_text nvarchar(4000) collate database_default null)
create table #decltab ( c1 int identity NOT NULL, procedure_text nvarchar(4000) collate database_default null)
create table #assigntab ( c1 int identity NOT NULL, procedure_text nvarchar(4000) collate database_default null)
create table #where_clausetab ( c1 int identity NOT NULL, procedure_text nvarchar(4000) collate database_default null)
create table #compinstab ( c1 int identity NOT NULL, procedure_text nvarchar(4000) collate database_default null)

-- some predefined declares and assignments
select @cmd = N'
	declare @reinit_code int, @subwins_code int, @pubwins_code int, @qcfttabrowid uniqueidentifier
			,@retcode smallint, @compcmd nvarchar(4000), @centralized_conflicts bit'
insert into #decltab(procedure_text) values(@cmd)
select @decltabempty = 0
	
select @cmd = N'
	select @reinit_code = 3
			,@subwins_code = 2
			,@pubwins_code = 1
			,@qcfttabrowid = NEWID()'
insert into #assigntab(procedure_text) values(@cmd)
select @cmd = N'
	select @centralized_conflicts = centralized_conflicts
	from dbo.syspublications where pubid = ' + cast(@pubid as nvarchar)
insert into #assigntab(procedure_text) values(@cmd)
select @assigntabempty = 0
	
declare #argcursor cursor local FAST_FORWARD FOR 
		select colid
		from syscolumns
		where iscomputed = 0 and id=@conflict_tableid 
		order by colid
FOR READ ONLY

select @retain_varname = 0
open #argcursor
fetch #argcursor into @colid
while (@@FETCH_STATUS = 0)
begin
	--
	-- Get the column name and column type
	--
	exec dbo.sp_MSget_type @conflict_tableid, @colid, @colname output, @coltype OUTPUT
	if (@@ERROR<>0 or @retcode<>0)
		return (1)

	--
	-- skip this specific column or if type is not returned
	--
	if ((@coltype IS NULL) or (LOWER(@colname) = 'qcfttabrowid'))
	begin
		-- do the next fetch and continue
		fetch #argcursor into @colid
		continue	
	end
		
	exec dbo.sp_MSget_colinfo @conflict_tableid, @colid, NULL, 0, NULL, @ccoltype output
	if (@@ERROR<>0 or @retcode<>0)
		return (1)

	--
	-- parameterize the vars that are the column values of the source
	-- table. For the columns that are specific to the conflict table
	-- retain specific names for the vars
	--
	if (LOWER(@colname collate SQL_Latin1_General_CP1_CS_AS) = 'origin_datasource')
		select @retain_varname = @colid

	if (@retain_varname = 0)
		select @argterm = N'@param' + cast(@colid as nvarchar) 
	else
		select @argterm = N'@' + @colname
		
	select @valterm = quotename(@colname)
	select @paramterm = @argterm
	select @updterm = @valterm + N' = ' + @argterm

	if (@retain_varname = 0)
	begin
		select @selterm = @paramterm + N' = ' + @valterm
		select @sel2term = @paramterm + N' = case when ' + @paramterm + 
					N' is NULL then ' + @valterm + N' else ' + @paramterm + N' end'
	end
	else
	begin
		select @selterm = NULL
		select @sel2term = NULL
	end
	 
	select @argterm = @argterm + N' ' + @coltype

	-- Check if this is part of primary key	/ unique index
	if (@colname in ( select colname from #indcoltab ) )
	begin
		-- this key assignment becomes part of where clause
		select @where_term = @updterm
		select @updterm = NULL
		select @selterm = NULL
		select @sel2term = NULL
	end
	else
		select @where_term = NULL

	-- special columns - process them as local var
	if (LOWER(@colname collate SQL_Latin1_General_CP1_CS_AS) = 'insertdate' )
	begin
		select @declterm = N'
	declare ' + @argterm
		select @assignterm = N'
	select ' + @paramterm + N' = GETDATE()'
		select @argterm = NULL
	end
	else if (LOWER(@colname collate SQL_Latin1_General_CP1_CS_AS) = 'pubid' )
	begin
		select @declterm = N'
	declare ' + @argterm
		select @assignterm = N'
	select ' + @paramterm + N' = ' + cast(@pubid as nvarchar)
		select @argterm = NULL
	end
	else
	begin
		select @declterm = NULL
		select @assignterm = NULL
	end

	-- build the term for compensating insert
	if (lower(@ccoltype collate SQL_Latin1_General_CP1_CS_AS) = 'varchar')
		select @compinsterm = N' '''''' + master.dbo.fn_MSgensqescstr(' + @valterm + N') collate database_default + '''''''' '
	else if (lower(@ccoltype collate SQL_Latin1_General_CP1_CS_AS) = 'nvarchar')
		select @compinsterm = N' N'''''' + master.dbo.fn_MSgensqescstr(' + @valterm + N') collate database_default + '''''''' '
	else if (lower(@ccoltype collate SQL_Latin1_General_CP1_CS_AS) = 'char')
		select @compinsterm = N' '''''' + master.dbo.fn_MSgensqescstr(CAST(RTRIM(' + @valterm + N') as nvarchar(4000))) collate database_default + '''''''' '
	else if (lower(@ccoltype collate SQL_Latin1_General_CP1_CS_AS) = 'nchar')
		select @compinsterm = N' N'''''' + master.dbo.fn_MSgensqescstr(CAST(RTRIM(' + @valterm + N') as nvarchar(4000))) collate database_default + '''''''' '
	else if (lower(@ccoltype collate SQL_Latin1_General_CP1_CS_AS) in ('binary','varbinary'))
		select @compinsterm = N' '' + master.dbo.fn_varbintohexstr(' + @valterm + N') collate database_default ' 
	else if (lower(@ccoltype collate SQL_Latin1_General_CP1_CS_AS) in ('bit','bigint','int','smallint','tinyint','float','real','decimal','numeric'))
		select @compinsterm = N' '' + CAST(' + @valterm + N' as nvarchar) '
	else if (lower(@ccoltype collate SQL_Latin1_General_CP1_CS_AS) in ('money','smallmoney'))
		select @compinsterm = N' '' + CONVERT(nvarchar(40),' + @valterm + N', 2) '
	else if (lower(@ccoltype collate SQL_Latin1_General_CP1_CS_AS) = 'uniqueidentifier')
		select @compinsterm = N' '''''' + CAST(' + @valterm + N' as nvarchar(40)) + '''''''' '
	else if (lower(@ccoltype collate SQL_Latin1_General_CP1_CS_AS) in ('datetime','smalldatetime'))
		select @compinsterm = N' '''''' + CONVERT(nvarchar(40), ' + @valterm + N', 112) + N'' ''  + CONVERT(nvarchar(40), ' + @valterm + N', 114) + '''''''' '
	else if (lower(@ccoltype collate SQL_Latin1_General_CP1_CS_AS) = 'sql_variant')
		select @compinsterm = N' '' + master.dbo.fn_sqlvarbasetostr(' + @valterm + N' ) collate database_default '
	else
		select @compinsterm = N' '' + CAST(' + @valterm + N' as nvarchar) '
	
	-- Now append to the various lists
	if (@argterm is NOT NULL)
	begin		
		if (@argtabempty = 1)
		begin
			select @argtabempty = 0
			select @cmd = N'
	' + @argterm
		end
		else
			select @cmd = N',
	' + @argterm
		insert into #argtab(procedure_text) values(@cmd)
	end
	if (@valterm is NOT NULL)
	begin
		if (@valtabempty = 1)
		begin
			select @valtabempty = 0
			select @cmd = @valterm
		end
		else
			select @cmd = N', ' + @valterm
		insert into #valtab(procedure_text) values(@cmd)
	end
	if (@paramterm is NOT NULL)
	begin
		if (@paramtabempty = 1)
		begin
			select @paramtabempty = 0
			select @cmd = @paramterm
		end
		else
			select @cmd = N', ' + @paramterm
		insert into #paramtab(procedure_text) values(@cmd)
	end
	if (@selterm is NOT NULL)
	begin
		if (@seltabempty = 1)
		begin
			select @seltabempty = 0
			select @cmd = N'
		' + @selterm
		end
		else
			select @cmd = N'
		,' + @selterm		
		insert into #seltab(procedure_text) values(@cmd)
	end
	if (@sel2term is NOT NULL)
	begin
		if (@sel2tabempty = 1)
		begin
			select @sel2tabempty = 0
			select @cmd = N'
		' + @sel2term
		end
		else
			select @cmd = N'
		,' + @sel2term		
		insert into #sel2tab(procedure_text) values(@cmd)
	end	
	if (@where_term is NOT NULL)
	begin
		if (@where_clausetabempty = 1)
		begin
			select @where_clausetabempty = 0
			select @cmd = @where_term
		end
		else
			select @cmd = N' AND 
			' + @where_term
		insert into #where_clausetab(procedure_text) values(@cmd)
	end
	if (@declterm is NOT NULL)
	begin
		select @cmd = @declterm + N'
	'
		insert into #decltab(procedure_text) values(@cmd)
	end		

	if (@assignterm is NOT NULL)
	begin
		select @cmd = @assignterm + N'
	'
		insert into #assigntab(procedure_text) values(@cmd)
	end		

	if (@compinsterm is NOT NULL)
	begin
		if (@compinsertabempty = 1)
		begin
			select @compinsertabempty = 0
			select @cmd = N' + ISNULL(''' + @compinsterm + N', ''null'')'
		end
		else
			select @cmd = N' + ISNULL('',' + @compinsterm + N', ''null'')'
		insert into #compinstab(procedure_text) values(@cmd)
	end
	
	-- do the next fetch
	fetch #argcursor into @colid

end
close #argcursor
deallocate #argcursor
drop table #indcoltab

--
-- generation phase
--
BEGIN TRAN sp_MSmaketrancftproc

-- create temp table to select the command text out of
if exists (select * from sysobjects where name = 'tempcmd' and uid = user_id('dbo'))
		drop table dbo.tempcmd
create table dbo.tempcmd ( c1 int identity NOT NULL, cmdtext nvarchar(4000) NULL)

-- create header
insert into  dbo.tempcmd(cmdtext) 
values(N'create procedure '+QUOTENAME(@owner)+ N'.'+ QUOTENAME(@procname) + N'( 
')

-- insert the arglist
insert into dbo.tempcmd(cmdtext) select procedure_text from #argtab order by c1 
insert into dbo.tempcmd(cmdtext) values(N' ,@subcriber sysname = NULL, @subdb sysname = NULL )
as
begin
')

-- insert the declare list
insert into dbo.tempcmd(cmdtext) select procedure_text from #decltab order by c1 
insert into dbo.tempcmd(cmdtext) values(N'
')

-- insert the assignment list (for declared vars)
insert into dbo.tempcmd(cmdtext) select procedure_text from #assigntab order by c1

-- do the select for the case where we need to retain values of publisher
insert into dbo.tempcmd(cmdtext) values(N'
	if (@reason_code = @subwins_code)
	begin
		select ')
insert into dbo.tempcmd(cmdtext) select procedure_text from #seltab order by c1
insert into dbo.tempcmd(cmdtext) values(N'
		from ' + @source_table + N' where ')
insert into dbo.tempcmd(cmdtext) select procedure_text from #where_clausetab order by c1
insert into dbo.tempcmd(cmdtext) values(N'
	end')

insert into dbo.tempcmd(cmdtext) values(N'
	else
	begin
		select ')
	
insert into dbo.tempcmd(cmdtext) select procedure_text from #sel2tab order by c1
insert into dbo.tempcmd(cmdtext) values(N'
		from ' + @source_table + N' where ')
insert into dbo.tempcmd(cmdtext) select procedure_text from #where_clausetab order by c1
insert into dbo.tempcmd(cmdtext) values(N'
	end
')

--
-- insert the conflict row in the publisher cft table
--
insert into dbo.tempcmd(cmdtext) values(N'
	insert into ' + @qualname + N'(')
insert into dbo.tempcmd(cmdtext) select procedure_text from #valtab order by c1
insert into dbo.tempcmd(cmdtext) values(N',[qcfttabrowid]) 
	values (')
insert into dbo.tempcmd(cmdtext) select procedure_text from #paramtab order by c1
insert into dbo.tempcmd(cmdtext) values(N',@qcfttabrowid)
')

--
-- generate compensating command decentralized logging
-- depending on the number of columns, we will split the compensating
-- command into several compensating commands
--
select @rowcnt = 0, @compinsertabempty = 1
select @cmd = N'
	if (@centralized_conflicts = 0)
	begin
		select @compcmd = N''insert into ' + master.dbo.fn_MSgensqescstr(@destqualname) collate database_default + N' ( '
insert into dbo.tempcmd(cmdtext) values(@cmd)

declare #htempcur cursor local for
	select master.dbo.fn_MSgensqescstr(procedure_text) from #valtab order by c1
for read only

open #htempcur
fetch #htempcur into @compinsterm
while (@@fetch_status = 0)
begin
	insert into dbo.tempcmd(cmdtext) select @compinsterm
	select @rowcnt = @rowcnt + 1

	--
	-- if we have processed 10 terms then split the command
	--
	if (@rowcnt > 9)
	begin
		select @cmd = N'''
		from ' + @qualname + N' where qcfttabrowid = @qcfttabrowid and tranid = @tranid' 
		insert into dbo.tempcmd(cmdtext) values(@cmd)		
	
		select @cmd = N'
		exec @retcode = dbo.sp_MSadd_compensating_cmd @subcriber, @subdb, @compcmd, ' 
			+ CAST(@artid as nvarchar(10)) + N', ' + CAST(@pubid as nvarchar(10)) + N',1,0,'
			+ CAST(@compinsertabempty as nvarchar(4)) + N'
		if (@@error != 0 or @retcode != 0)
			return 1 
		
		select @compcmd = N''' 
		insert into dbo.tempcmd(cmdtext) values(@cmd)
		select @rowcnt = 0, @compinsertabempty = 0
	end
	fetch #htempcur into @compinsterm
end

close #htempcur
deallocate #htempcur

insert into dbo.tempcmd(cmdtext) values(N', [qcfttabrowid] ) values ('' ')
select @rowcnt = @rowcnt + 1

declare #htempcur cursor local for
	select procedure_text from #compinstab order by c1
for read only

open #htempcur
fetch #htempcur into @compinsterm
while (@@fetch_status = 0)
begin
	insert into dbo.tempcmd(cmdtext) select @compinsterm
	select @rowcnt = @rowcnt + 1

	--
	-- if we have processed 10 terms then split the command
	--
	if (@rowcnt > 9)
	begin
		select @cmd = N'
		from ' + @qualname + N' where qcfttabrowid = @qcfttabrowid and tranid = @tranid' 
		insert into dbo.tempcmd(cmdtext) values(@cmd)		
	
		select @cmd = N'
		exec @retcode = dbo.sp_MSadd_compensating_cmd @subcriber, @subdb, @compcmd, ' 
			+ CAST(@artid as nvarchar(10)) + N', ' + CAST(@pubid as nvarchar(10)) + N',1,0,'
			+ CAST(@compinsertabempty as nvarchar(4)) + N'
		if (@@error != 0 or @retcode != 0)
			return 1 
		
		select @compcmd = N'' ''' 
		insert into dbo.tempcmd(cmdtext) values(@cmd)
		select @rowcnt = 0, @compinsertabempty = 0
	end
	fetch #htempcur into @compinsterm
end

close #htempcur
deallocate #htempcur

--
-- script the remaining compensating command
--
select @cmd = N' + '', '''''' + CAST([qcfttabrowid] as nvarchar(40)) + '''''''' + N'' ) ''
		from ' + @qualname + N' where qcfttabrowid = @qcfttabrowid and tranid = @tranid' 
insert into dbo.tempcmd(cmdtext) values(@cmd)
select @rowcnt = @rowcnt + 1

select @cmd = N'
		exec @retcode = dbo.sp_MSadd_compensating_cmd @subcriber, @subdb, @compcmd, ' 
			+ CAST(@artid as nvarchar(10)) + N', ' + CAST(@pubid as nvarchar(10)) + N',0,0,'
			+ CAST(@compinsertabempty as nvarchar(4)) + N'
		if (@@error != 0 or @retcode != 0)
			return 1 ' 
insert into dbo.tempcmd(cmdtext) values(@cmd)		
insert into dbo.tempcmd(cmdtext) values(N'
	end
end')

if (@is_debug = 0)
begin
	-- Now we select out the command text pieces in proper order so that our caller,
	-- xp_execresultset will execute the command that creates the stored procedure.
	select @dbname = db_name()
	select @cmd = N'select cmdtext from dbo.tempcmd order by c1'
	exec @retcode = master..xp_execresultset @cmd, @dbname
	if (@@error != 0 or @retcode != 0)
	begin
		-- roll back the tran
		rollback tran sp_MSmaketrancftproc
		return (1)
	end
	
	--
	-- Check if we create the proc and update sysarticleupdates
	--
	select @conflict_proc_id = id from sysobjects where name = @procname and type = 'P '
	if (@conflict_proc_id is NULL or @conflict_proc_id = 0)
	begin
		-- roll back the tran
		rollback tran sp_MSmaketrancftproc
		return (1)
	end
	else
	begin
		update dbo.sysarticleupdates set ins_conflict_proc = @conflict_proc_id
			where artid = @artid and pubid = @pubid
		if @@error <> 0
		begin
			-- roll back the tran
			rollback tran sp_MSmaketrancftproc
			return (1)
		end

		-- mark the proc as system object
		if (@owner in ('dbo','INFORMATION_SCHEMA'))
		begin
			exec @retcode = dbo.sp_MS_marksystemobject @procname
			if (@@error != 0 or @retcode != 0)
			begin
				-- roll back the tran
				rollback tran sp_MSmaketrancftproc
				return (1)
			end
		end
	end
end
else
	select cmdtext from dbo.tempcmd order by c1

COMMIT TRAN 

-- drop the temp tables
drop table dbo.tempcmd
drop table #argtab 
drop table #valtab 
drop table #paramtab 
drop table #seltab 
drop table #sel2tab 
drop table #decltab 
drop table #assigntab 
drop table #where_clausetab 
drop table #compinstab
END
go

exec dbo.sp_MS_marksystemobject sp_MSmaketrancftproc 
grant execute on dbo.sp_MSmaketrancftproc to public

--------------------------------------------------------------------------------
--. sp_MSscript_compensating_insert
--------------------------------------------------------------------------------
if exists (select * from sysobjects
    where type = 'P '
            and name = 'sp_MSscript_compensating_insert')
    drop procedure sp_MSscript_compensating_insert 

--
-- proc that generates a compensating insert command string
-- specify the type of proc where this generation will be used
--
raiserror('Creating procedure sp_MSscript_compensating_insert', 0,1)
go
create procedure sp_MSscript_compensating_insert (
	@publication sysname,
	@article     sysname, 
	@objid int,
	@columns binary(32),
	@proctype	int = 1)		-- 0 = use new_pk, 1 = use old_pk
AS
BEGIN
	declare @cmd nvarchar(4000)
			,@artid int
			,@pubid int
			,@dest_table sysname
			,@dest_owner nvarchar(260)
			,@colname      sysname
			,@ccoltype     sysname
			,@this_col     int
			,@rc           int
			,@num_col	  int
			,@qualname nvarchar(540)
			,@cast_str nvarchar(4000)
			,@column_string nvarchar(4000)
			,@ins_cmd nvarchar(255)
			,@startoffset int
			,@setprefix bit
			,@commandlen int
			,@fragmentlen int
			,@collen int
			,@first_time bit
			,@fullcastlen int
			,@splitlen int

	--
	-- initialize the vars we will use
	--
	select @pubid = pubid from syspublications where name = @publication
	select @artid = artid, @dest_table = dest_table, 
		@dest_owner = dest_owner, @ins_cmd = ins_cmd from sysarticles 
	where name = @article and pubid = @pubid
	select @dest_owner = case when (@dest_owner IS NULL) then N''
				else quotename(@dest_owner) + N'.' end
	exec sp_MSget_qualified_name @objid, @qualname OUTPUT

	--
	-- The compensating command will be split into one or more
	-- fragment commands if the length exceeds 3450 characters in length 
	-- (to accomodate compensating server/db names)
	-- For correctly estimating the length of the compensating command
	-- we have to take the max column length of the data into consideration along
	-- with the scripting command length
	--

	--
	-- use the insert command if available
	--
	select @commandlen = 0
			,@setprefix = 1

	if (@ins_cmd = N'SQL')
	begin
		select @cmd = N'
			select @cmd = ''INSERT INTO ' + master.dbo.fn_MSgensqescstr(@dest_owner) collate database_default 
						+ quotename(master.dbo.fn_MSgensqescstr(@dest_table) collate database_default) + N''' + 
						'' SELECT '' + '
	end
	else
	begin
		select @cmd = N'
			select @cmd = ''EXEC ' + substring(@ins_cmd, 5, len(@ins_cmd) - 4) + N' '' + '
	end
	insert into #proctext(procedure_text) values( @cmd )
 	select @commandlen = @commandlen + len(@cmd)
	
	select @num_col = 0
	DECLARE hCColid CURSOR LOCAL FAST_FORWARD FOR 
	select colid, length from syscolumns where id = @objid order by colid asc

	OPEN hCColid
	FETCH hCColid INTO @this_col, @collen
	WHILE (@@fetch_status != -1)
	begin
		exec @rc = dbo.sp_MSget_colinfo @objid, @this_col, @columns, 1, @colname output, @ccoltype output
		if @rc = 0  and EXISTS (select name from syscolumns where id=@objid and colid=@this_col and iscomputed<>1)
		begin
			if rtrim(@ccoltype) not like N'timestamp' 
			begin
				select @num_col = @num_col + 1

				--
				-- Compute the command fragment length needed for this column
				-- based on the coltype
				--				
				if (lower(@ccoltype collate SQL_Latin1_General_CP1_CS_AS) in ('ntext','text','image'))
				begin
					--
					-- For compensating commands we have to include the text and image data
					-- as the custom procs used by Distribution process expects them - as it
					-- done for regular transactional replication - but we will only send NULLs
					-- as it is not possible to ascertain the size of the data during the generation
					--		
					select @cast_str = N' ''null'' '
					select @fullcastlen = len(@cast_str)
					select @fragmentlen = @fullcastlen + 4 + @collen
				end
				else if (lower(@ccoltype collate SQL_Latin1_General_CP1_CS_AS) in ('varchar','nvarchar','char','nchar'))
				begin
					if (lower(@ccoltype collate SQL_Latin1_General_CP1_CS_AS) in ('nvarchar', 'nchar'))
						select @collen = (@collen / 2)
	
					select @cast_str = case 
							when (lower(@ccoltype collate SQL_Latin1_General_CP1_CS_AS) in ('nvarchar', 'nchar'))
								then N' ISNULL(''N'''''' + master.dbo.fn_MSgensqescstr(' + quotename(@colname) + N') collate database_default + '''''''', ''null'') '
								else N' ISNULL('''''''' + master.dbo.fn_MSgensqescstr(' + quotename(@colname) + N') collate database_default + '''''''', ''null'') '
							end
	   
					select @fullcastlen = len(@cast_str)
					select @fragmentlen = @fullcastlen + 4 + @collen
				end
				else if (lower(@ccoltype collate SQL_Latin1_General_CP1_CS_AS) in ('binary','varbinary'))
				begin
					--
					-- each byte has 2 nibbles - we need a char to represent each nibble
					--
					select @collen = @collen * 2
					select @cast_str = N' ISNULL(master.dbo.fn_varbintohexsubstring(1,' + quotename(@colname) + N',1,0) collate database_default, ''null'') '
					select @fullcastlen = len(@cast_str)
					select @fragmentlen = @fullcastlen + 4 + @collen + 2
				end
				else if (lower(@ccoltype collate SQL_Latin1_General_CP1_CS_AS) in ('bit','bigint','int','smallint','tinyint','float','real','decimal','numeric'))
				begin
					select @collen = 40
					select @cast_str = N' ISNULL(CAST(' + quotename(@colname) + N' as nvarchar), ''null'') '
					select @fragmentlen = len(@cast_str) + @collen
				end
				else if (lower(@ccoltype collate SQL_Latin1_General_CP1_CS_AS) in ('money','smallmoney'))
				begin
					select @collen = 40
					select @cast_str = N' ISNULL(CONVERT(nvarchar(40),' + quotename(@colname) + N',2), ''null'') '
					select @fragmentlen = len(@cast_str) + @collen
				end
				else if (lower(@ccoltype collate SQL_Latin1_General_CP1_CS_AS) = 'uniqueidentifier')
				begin
					select @collen = 40
					select @cast_str = N' ISNULL('''''''' + CAST(' + quotename(@colname) + N' as nvarchar(40)) + '''''''', ''null'') '
					select @fragmentlen = len(@cast_str) + @collen
				end
				else if (lower(@ccoltype collate SQL_Latin1_General_CP1_CS_AS) in ('datetime','smalldatetime'))
				begin
					select @collen = 40
					select @cast_str = N' ISNULL('''''''' + CONVERT(nvarchar(40), ' + quotename(@colname) + N', 112) + N'' '' +  CONVERT(nvarchar(40), ' + quotename(@colname) + N', 114) + '''''''', ''null'') '
					select @fragmentlen = len(@cast_str) + @collen
				end
				else if (lower(@ccoltype collate SQL_Latin1_General_CP1_CS_AS) = 'sql_variant')
				begin
					--
					-- need to revisit this later
					--
					select @cast_str = N' ISNULL(master.dbo.fn_sqlvarbasetostr(' + quotename(@colname) + N' ) collate database_default, ''null'') '
					select @fragmentlen = len(@cast_str) + @collen
				end					
				else
				begin
					select @collen = 40
					select @cast_str = N' ISNULL(CAST(' + quotename(@colname) + N' as nvarchar), ''null'') '
					select @fragmentlen = len(@cast_str) + @collen
				end
			
				--
				-- for fixed datatypes - we will not split the data at all we will
				-- flush the command script and continue
				-- for varying/large datatypes, we will have to split data if necessary
				--
				if ((lower(@ccoltype collate SQL_Latin1_General_CP1_CS_AS) in ('varchar','nvarchar','char','nchar','binary','varbinary')) 
						and (@fragmentlen + @commandlen > 3450))
				begin
			 		--
			 		-- the column length is too big, we have to break the data string
			 		-- initialize
			 		--
					if (@num_col = 1)
					begin
						select @column_string = N'
				' 
					end
					else
					begin
						select @column_string = N'
				+ '','' + ' 
					end

					--
					-- use substring to break the string value in the
					-- compensating command
					--
					select @first_time = 1
							,@startoffset = 1
					while (@collen > 0)
					begin
				 		select @splitlen = case when ((@first_time = 1) or (@collen > 3450))
				 								then (3450 - @commandlen - 30 - @fullcastlen)
				 								else @collen end
				 		if (@splitlen < 1)
				 		begin
				 			--
				 			-- we have overcompensated the splitlen
				 			-- set to half of the column length
				 			--
				 			select @splitlen = @collen / 2
				 		end

						--
						-- Do we need to put quotes (many datatypes need it)
						--
					 	if (@first_time = 1)
					 	begin
							if (lower(@ccoltype collate SQL_Latin1_General_CP1_CS_AS) in ('varchar','nvarchar','char','nchar'))
								select @column_string = case 
									when (lower(@ccoltype collate SQL_Latin1_General_CP1_CS_AS) in ('nvarchar', 'nchar'))
										then @column_string + N' ISNULL(''N'''''' + master.dbo.fn_MSgensqescstr( '
										else @column_string + N' ISNULL('''''''' + master.dbo.fn_MSgensqescstr( '
									end
							else if (lower(@ccoltype collate SQL_Latin1_General_CP1_CS_AS) in ('binary','varbinary'))
								select @column_string = @column_string + N' ISNULL(master.dbo.fn_varbintohexsubstring(1,' 
						end
					 	else
					 	begin
							if (lower(@ccoltype collate SQL_Latin1_General_CP1_CS_AS) in ('varchar','nvarchar','char','nchar'))
						 		select @column_string = N' + ISNULL(master.dbo.fn_MSgensqescstr( '
							else if (lower(@ccoltype collate SQL_Latin1_General_CP1_CS_AS) in ('binary','varbinary'))
								select @column_string = @column_string + N' + ISNULL(master.dbo.fn_varbintohexsubstring(0,' 
					 	end

						--
						-- prepare the substring script
						--
						if (lower(@ccoltype collate SQL_Latin1_General_CP1_CS_AS) in ('varchar','nvarchar','char','nchar'))
							select @cast_str = N'SUBSTRING(' + quotename(@colname) + N', ' + cast(@startoffset as nvarchar) + N', ' +  cast(@splitlen as nvarchar) + N')'
						else if (lower(@ccoltype collate SQL_Latin1_General_CP1_CS_AS) in ('binary','varbinary'))
							select @cast_str = quotename(@colname) + N', ' + cast(@startoffset as nvarchar) + N', ' +  cast((@splitlen/2) as nvarchar)

						if (@first_time = 1)
					 	begin
							select @cast_str = @cast_str + N') collate database_default, ''null'') '
									,@first_time = 0
					 	end
					 	else
					 	begin
							if (lower(@ccoltype collate SQL_Latin1_General_CP1_CS_AS) in ('varchar','nvarchar','char','nchar'))
							begin
								--
								-- for strings the last fragment needs the single
								-- quote to be added for the string
								--
								select @cast_str = @cast_str + N') collate database_default '
								select @cast_str = case 
									when (@collen - @splitlen < 1)
										then @cast_str + N'+ '''''''', '''') '											
										else @cast_str + N', '''') ' 
									end
							end
							else if (lower(@ccoltype collate SQL_Latin1_General_CP1_CS_AS) in ('binary','varbinary'))
								select @cast_str = @cast_str + N') collate database_default, '''') '
						end
						 		
						select @column_string = @column_string + @cast_str
						insert into #proctext(procedure_text) values( @column_string )

						if (@fragmentlen + @commandlen > 3450)
						begin
							select @cmd = N'
			from ' + @qualname 
							insert into #proctext(procedure_text) values( @cmd )
							if (@proctype = 1)
								exec dbo.sp_MSscript_where_clause @objid, @columns, 'upd version', NULL, 0, 'del'
							else
								exec dbo.sp_MSscript_where_clause @objid, @columns, 'new_pk_q', NULL, 0, 'ins'
							exec sp_MSscript_compensating_send @pubid, @artid, 1, @setprefix
							if (@setprefix = 1)
								select @setprefix = 0

							select @cmd = N'
			select @cmd = N''''' 
							insert into #proctext(procedure_text) values( @cmd )
							select @commandlen = 0
						end
						else
							select @commandlen = @commandlen + len(@column_string)

						--
						-- update vars for next round
						--
						select @collen = @collen - @splitlen
								,@column_string = N''
								,@startoffset = case 
									when (lower(@ccoltype collate SQL_Latin1_General_CP1_CS_AS) in ('binary','varbinary')) 
										then (@splitlen/2) + @startoffset 
										else @splitlen + @startoffset 
									end
						select @fragmentlen = @fullcastlen + 4 + @collen
					end							

					--
					-- we done with this column now
					-- skip processing further and continue
					--						
					select @commandlen = @commandlen + len(@column_string)
			 	end
			 	else
			 	begin
					--
					-- Handling general fixed type column cases
					--
					if (@num_col = 1)
					begin
						select @column_string = N'
				' + @cast_str
					end
					else
					begin
						select @column_string = N'
				+ '','' + ' + @cast_str
					end

					--
					-- check if we need to flush the command first
					--
					if (@fragmentlen + len(@column_string) + @commandlen > 3450)
					begin
						--
						-- send this compensating command first
						--
						select @cmd = N'
			from ' + @qualname 
						insert into #proctext(procedure_text) values( @cmd )

						if (@proctype = 1)
							exec dbo.sp_MSscript_where_clause @objid, @columns, 'upd version', NULL, 0, 'del'
						else
							exec dbo.sp_MSscript_where_clause @objid, @columns, 'new_pk_q', NULL, 0, 'ins'
		
						exec sp_MSscript_compensating_send @pubid, @artid, 1, @setprefix
						if (@setprefix = 1)
							select @setprefix = 0

						select @cmd = N'
			select @cmd = N'' ''' 
						insert into #proctext(procedure_text) values( @cmd )
						select @commandlen = 0					
					end

					--
					-- script out the column string
					--
					insert into #proctext(procedure_text) values( @column_string )

					--
					-- if we are processing sql_variants, flush the command again
					--
					if (lower(@ccoltype collate SQL_Latin1_General_CP1_CS_AS) = 'sql_variant')
					begin
						--
						-- send this compensating command first
						--
						select @cmd = N'
			from ' + @qualname 
						insert into #proctext(procedure_text) values( @cmd )

						if (@proctype = 1)
							exec dbo.sp_MSscript_where_clause @objid, @columns, 'upd version', NULL, 0, 'del'
						else
							exec dbo.sp_MSscript_where_clause @objid, @columns, 'new_pk_q', NULL, 0, 'ins'
		
						exec sp_MSscript_compensating_send @pubid, @artid, 1, @setprefix
						if (@setprefix = 1)
							select @setprefix = 0

						select @cmd = N'
			select @cmd = N'' ''' 
						insert into #proctext(procedure_text) values( @cmd )
						select @commandlen = 0					
					end
					else
						select @commandlen = @commandlen + @fragmentlen + len(@column_string)
				end
			end
		end

		--
		-- process the next column
		--
		FETCH hCColid INTO @this_col, @collen
	end
	CLOSE hCColid
	DEALLOCATE hCColid

	--
	-- Check if we need to flush the command one more time (final)
	--
	if (@commandlen > 0)
	begin
		--
		-- send the last fragment of the command
		--
		select @cmd = N'
			from ' + @qualname 
		insert into #proctext(procedure_text) values( @cmd )

		if (@proctype = 1)
			exec dbo.sp_MSscript_where_clause @objid, @columns, 'upd version', NULL, 0, 'del'
		else
			exec dbo.sp_MSscript_where_clause @objid, @columns, 'new_pk_q', NULL, 0, 'ins'
		exec sp_MSscript_compensating_send @pubid, @artid, 0, @setprefix
	end

	--
	-- all done
	--
	return 0
END
go

EXEC dbo.sp_MS_marksystemobject sp_MSscript_compensating_insert
grant execute on dbo.sp_MSscript_compensating_insert to public

--------------------------------------------------------------------------------
--. sp_MSscript_insert_pubwins
--------------------------------------------------------------------------------
if exists (select * from sysobjects
    where type = 'P '
            and name = 'sp_MSscript_insert_pubwins')
    drop procedure sp_MSscript_insert_pubwins 

--
-- proc to generate publisher wins resolution code block
-- for insert proc used for synctran/queued
--
raiserror('Creating procedure sp_MSscript_insert_pubwins', 0,1)
go
create procedure sp_MSscript_insert_pubwins (
	@publication sysname,
	@article     sysname, 
	@objid int,
	@columns binary(32) )
AS
BEGIN
	declare @cmd nvarchar(4000)
			,@artid int
			,@pubid int
			,@dest_table sysname
			,@dest_owner nvarchar(260)
			,@colname      sysname
			,@ccoltype     sysname
			,@this_col     int
			,@rc           int
			,@num_col	  int
			,@qualname nvarchar(512)
			,@cast_str nvarchar(1000)
			,@decl_str nvarchar(2000)
			,@assign_str nvarchar(4000)
			,@typestring nvarchar(100)
			,@exec_str nvarchar(1000)

	--
	-- initialize the vars we will use
	--
	select @pubid = pubid from syspublications where name = @publication
	select @artid = artid, @dest_table = dest_table, @dest_owner = dest_owner
	from sysarticles where name = @article and pubid = @pubid
	select @dest_owner = case when (@dest_owner IS NULL) then N''
				else quotename(@dest_owner) + N'.' end
	exec sp_MSget_qualified_name @objid, @qualname OUTPUT
				
	--
	-- start script generation
	--
	select @cmd = N'
	else if (@error in (0, 547, 2627) and @execution_mode = @QPubWins)
	begin
		' + N'--
		' + N'-- Publisher Wins resolution
		' + N'-- Find where we have to generate compensating action
		' + N'--
		if (@rowcount = 1 and @error = 0)
		begin'
	insert into #proctext(procedure_text) values( @cmd )

	select @cmd = N'
			' + N'--
			' + N'-- No conflict for this command
			' + N'-- Row does not exist
			' + N'-- Generate delete compensating action
			' + N'--
			select @cftcase = 23'
	insert into #proctext(procedure_text) values( @cmd )

	--
	-- Continue with scripting
	--
	select @cmd = N'
		end
		else if (@rowcount = 0 and @error in (547, 2627))
		begin
			' + N'--
			' + N'-- conflict for this command
			' + N'-- Row already exists
			' + N'-- generate update compensating action
			' + N'-- DELETE compensating command + INSERT compensating command
			' + N'--			
			select @cftcase = 21'
	insert into #proctext(procedure_text) values( @cmd )

	--
	-- continue with scripting
	--			
	select @cmd = N'		
		end
		else
			return -1

		' + N'--
		' + N'-- generate compensating command according to the cases
		' + N'--'
	insert into #proctext(procedure_text) values( @cmd )

	select @cmd = N'
		if (@cftcase in (21,23))
		begin
			' + N'--
			' + N'-- delete compensating command
			' + N'--'
	insert into #proctext(procedure_text) values( @cmd )
	
	--
	-- Generate the delete compensating code
	--
	select @cmd = N'
			select @cmd = ''DELETE ' + master.dbo.fn_MSgensqescstr(@dest_owner) collate database_default 
		+ quotename(master.dbo.fn_MSgensqescstr(@dest_table) collate database_default) + N' '' + '
	insert into #proctext(procedure_text) values( @cmd )
	exec dbo.sp_MSscript_where_clause @objid, @columns, 'qcft_comp', NULL, 0, 'ins'
	exec sp_MSscript_compensating_send @pubid, @artid, 0, 1

	select @cmd = N'
		end

		if (@cftcase = 21)
		begin
			' + N'--
			' + N'-- insert compensating command
			' + N'--'
	insert into #proctext(procedure_text) values( @cmd )

	--
	-- generate the compensating insert command
	--
	exec dbo.sp_MSscript_compensating_insert @publication, @article, @objid, @columns, 0

	--
	-- continue with scripting
	--			
	select @cmd = N'		
		end
	end'
	insert into #proctext(procedure_text) values( @cmd )

	--
	-- all done
	--
	return 0	
END
go

EXEC dbo.sp_MS_marksystemobject sp_MSscript_insert_pubwins
grant execute on dbo.sp_MSscript_insert_pubwins to public
GO

--------------------------------------------------------------------------------
--. sp_MSscript_update_pubwins
--------------------------------------------------------------------------------
   if exists (select * from sysobjects
        where type = 'P '
                and name = 'sp_MSscript_update_pubwins')
        drop procedure sp_MSscript_update_pubwins 

--
-- proc to generate publisher wins resolution code block
-- for update proc used for synctran/queued
--
raiserror('Creating procedure sp_MSscript_update_pubwins', 0,1)
go
create procedure sp_MSscript_update_pubwins (
	@publication sysname,
	@article     sysname, 
	@objid int,
	@columns binary(32) )
AS
BEGIN
	declare @cmd nvarchar(4000)
			,@artid int
			,@pubid int
			,@dest_table sysname
			,@dest_owner nvarchar(260)
			,@colname      sysname
			,@ccoltype     sysname
			,@this_col     int
			,@rc           int
			,@num_col	  int
			,@qualname nvarchar(512)
			,@cast_str nvarchar(1000)
			,@decl_str nvarchar(2000)
			,@assign_str nvarchar(4000)
			,@typestring nvarchar(100)
			,@exec_str nvarchar(1000)

	--
	-- initialize the vars we will use
	--
	select @pubid = pubid from syspublications where name = @publication
	select @artid = artid, @dest_table = dest_table, @dest_owner = dest_owner
	from sysarticles where name = @article and pubid = @pubid
	select @dest_owner = case when (@dest_owner IS NULL) then N''
				else quotename(@dest_owner) + N'.' end
	exec sp_MSget_qualified_name @objid, @qualname OUTPUT

	--
	-- start scripting
	--
	select @cmd = N'
	else if (@error in (0, 547, 2627) and @execution_mode = @QPubWins)
	begin
		if (@rowcount = 1)
		begin
			' + N'--
			' + N'-- no conflict for this command
			' + N'-- Check if PK update was being done
			' + N'-- '
	insert into #proctext(procedure_text) values( @cmd )

	--
	-- script the PK update check
	--
	select @cmd = N'
			exec @retcode = dbo.sp_MSispkupdateinconflict ' + 
		cast(@pubid as nvarchar(10)) + N', ' + cast(@artid as nvarchar(10)) + N', @bitmap'
	insert into #proctext(procedure_text) values( @cmd )

	--
	-- continue scripting
	--
	select @cmd = N'
			if (@retcode = -1)
				return -1
			if (@retcode = 0)
			begin
				' + N'--
				' + N'-- PK update is not being done
				' + N'-- generate delete + insert compensating action with OLD_PK
				' + N'-- 
				select @cftcase = 0
			end'
	insert into #proctext(procedure_text) values( @cmd )

	--
	-- continue scripting
	--
	select @cmd = N'
			else
			begin
				' + N'--
				' + N'-- PK update is being done
				' + N'-- generate delete + insert compensating action with OLD_PK
				' + N'-- generate delete compensating action with NEW_PK
				' + N'-- 
				select @cftcase = 1
			end
		end'
	insert into #proctext(procedure_text) values( @cmd )

	--
	-- continue scripting
	--
	select @cmd = N'
		else
		begin
			' + N'--
			' + N'-- Conflict for this command
			' + N'-- Check if PK update was being done
			' + N'--'
	insert into #proctext(procedure_text) values( @cmd )

	--
	-- script the PK update check
	--
	select @cmd = N'
			exec @retcode = dbo.sp_MSispkupdateinconflict ' + 
		cast(@pubid as nvarchar(10)) + N', ' + cast(@artid as nvarchar(10)) + N', @bitmap'
	insert into #proctext(procedure_text) values( @cmd )

	select @cmd = N'
			if (@retcode = -1)
				return -1
			if (@retcode = 0)
			begin
				' + N'--
				' + N'-- PK update is not being done
				' + N'-- Now find the type of conflict
				' + N'-- '
	insert into #proctext(procedure_text) values( @cmd )
				
	--
	-- script the if exists code using OLD_PK
	--
	select @cmd = N'
				if exists (select * from ' + @qualname 
	insert into #proctext(procedure_text) values( @cmd )
	exec dbo.sp_MSscript_where_clause @objid, @columns, 'upd version', NULL, 0
	insert into #proctext(procedure_text) values( N' )')

	--
	-- continue scripting
	--
	select @cmd = N'
				begin
					' + N'--
					' + N'-- row exists
					' + N'-- generate delete + insert compensating action with OLD_PK
					' + N'--
					select @cftcase = 11
				end'
	insert into #proctext(procedure_text) values( @cmd )
	select @cmd = N'
				else
				begin
					' + N'--
					' + N'-- row does not exist
					' + N'-- generate delete compensating action with OLD_PK
					' + N'--
					select @cftcase = 13
				end
			end'
	insert into #proctext(procedure_text) values( @cmd )
			
	--
	-- continue scripting
	--
	select @cmd = N'
			else
			begin
				' + N'--
				' + N'-- PK update is being done
				' + N'-- Now find the type of conflict
				' + N'-- 
				select @cftcase = 0'
	insert into #proctext(procedure_text) values( @cmd )
				
	--
	-- script the if exists code using OLD_PK
	--
	select @cmd = N'
				if exists (select * from ' + @qualname 
	insert into #proctext(procedure_text) values( @cmd )
	exec dbo.sp_MSscript_where_clause @objid, @columns, 'upd version', NULL, 0
	insert into #proctext(procedure_text) values( N' )')

	--
	-- continue scripting
	--
	select @cmd = N'
				begin
					' + N'--
					' + N'-- row with OLD_PK exists
					' + N'-- generate delete compensating action with OLD_PK +
					' + N'-- insert compensating action with OLD_PK 
					' + N'--
					select @cftcase = 14
				end'
	insert into #proctext(procedure_text) values( @cmd )

	--
	-- script the if exists code using NEW_PK
	--
	select @cmd = N'
				if exists (select * from ' + @qualname 
	insert into #proctext(procedure_text) values( @cmd )
	exec dbo.sp_MSscript_where_clause @objid, @columns, 'new_pk_q', NULL, 0
	insert into #proctext(procedure_text) values( N' )')

	--
	-- continue scripting
	--
	select @cmd = N'
				begin
					' + N'--
					' + N'-- row with NEW_PK exists
					' + N'-- case 15: rows with NEW_PK and OLD_PK exist
					' + N'-- generate delete compensating actions with OLD_PK, NEW_PK +
					' + N'-- insert compensating actions with OLD_PK, NEW_PK' 
	insert into #proctext(procedure_text) values( @cmd )
	select @cmd = N'
					' + N'-- case 16: row with NEW_PK exists and OLD_PK does not exist
					' + N'-- generate delete compensating action with OLD_PK, NEW_PK +
					' + N'-- insert compensating action with NEW_PK 
					' + N'--
					select @cftcase = case when (@cftcase = 14) then 15 else 16 end
				end'
	insert into #proctext(procedure_text) values( @cmd )

	--
	-- continue scripting
	--	
	select @cmd = N'
				else
				begin
					' + N'--
					' + N'-- row with NEW_PK does not exists
					' + N'-- case 12 : no existing rows with OLD_PK or NEW_PK
					' + N'-- generate delete compensating action with OLD_PK, NEW_PK '
	insert into #proctext(procedure_text) values( @cmd )
	select @cmd = N'
					' + N'-- case 17 : row with OLD_PK exist and NEW_PK does not exist 
					' + N'-- generate delete compensating action with OLD_PK, NEW_PK +
					' + N'-- insert compensating action with OLD_PK 
					' + N'-- 
					select @cftcase = case when (@cftcase = 0) then 12 else 17 end 
				end '
	insert into #proctext(procedure_text) values( @cmd )
	select @cmd = N'
			end
		end' 		
	insert into #proctext(procedure_text) values( @cmd )

	--
	-- continue scripting
	--
	select @cmd = N'
		if (@cftcase in (0, 1, 11, 12, 13, 14, 15, 16, 17))
		begin
			' + N'--
			' + N'-- generation of delete compensating command with OLD_PK
			' + N'--'
	insert into #proctext(procedure_text) values( @cmd )

	--
	-- generate delete compensating cmd with OLD_PK
	--
	select @cmd = N'
			select @cmd = ''DELETE ' + master.dbo.fn_MSgensqescstr(@dest_owner) collate database_default 
		+ quotename(master.dbo.fn_MSgensqescstr(@dest_table) collate database_default) + N' '' + '
	insert into #proctext(procedure_text) values( @cmd )
	exec dbo.sp_MSscript_where_clause @objid, @columns, 'qcft_comp', NULL, 0, 'del'
	
	--
	-- script the sending command
	--
	exec sp_MSscript_compensating_send @pubid, @artid, 0, 1
	
	--
	-- continue scripting
	--
	select @cmd = N'
		end
		
		if (@cftcase in (1, 12, 15, 16, 17))
		begin
			' + N'--
			' + N'-- generation of delete compensating command with NEW_PK
			' + N'--'
	insert into #proctext(procedure_text) values( @cmd )

	--
	-- generate delete compensating cmd with NEW_PK
	--
	select @cmd = N'
			select @cmd = ''DELETE ' + master.dbo.fn_MSgensqescstr(@dest_owner) collate database_default 
		+ quotename(master.dbo.fn_MSgensqescstr(@dest_table) collate database_default) + N' '' + '
	insert into #proctext(procedure_text) values( @cmd )
	exec dbo.sp_MSscript_where_clause @objid, @columns, 'qcft_comp', NULL, 0, 'ins'
	
	--
	-- script the sending command
	--
	exec sp_MSscript_compensating_send @pubid, @artid, 0, 1
	
	--
	-- continue scripting
	--
	select @cmd = N'
		end

		if (@cftcase in (0, 1, 11, 14, 15, 17))
		begin
			' + N'--
			' + N'-- generate and send insert compensating command with OLD_PK
			' + N'--'
	insert into #proctext(procedure_text) values( @cmd )

	--
	-- script compensating insert with OLD_PK
	--
	exec dbo.sp_MSscript_compensating_insert @publication, @article, @objid, @columns, 1
	
	--
	-- continue scripting
	--
	select @cmd = N'
		end

		if (@cftcase in (15, 16))
		begin
			' + N'--
			' + N'-- generate and send insert compensating command with NEW_PK
			' + N'--'
	insert into #proctext(procedure_text) values( @cmd )

	--
	-- script compensating insert with NEW_PK
	--
	exec dbo.sp_MSscript_compensating_insert @publication, @article, @objid, @columns, 0
	
	--
	-- continue with scripting
	--
	select @cmd = N'
		end
		select @retcode = 0
	end'
	insert into #proctext(procedure_text) values( @cmd )
	
	--
	-- all done
	--
	return 0	
END
go

EXEC dbo.sp_MS_marksystemobject sp_MSscript_update_pubwins
grant execute on dbo.sp_MSscript_update_pubwins to public

--------------------------------------------------------------------------------
--.	Merge admin. procedures (rladmin.sql)
--------------------------------------------------------------------------------

--------------------------------------------------------------------------------
--. sp_MScleanup_conflict_table
--------------------------------------------------------------------------------
if exists (select * from sysobjects
        where type = 'P'
            and name = 'sp_MScleanup_conflict_table')
    drop procedure sp_MScleanup_conflict_table

raiserror('Creating procedure sp_MScleanup_conflict_table', 0,1)
GO
/*
** This stored procedure is to periodically check and cleanup all the conflict entries 
** in conflict tables that has been there longer than the value of conflict_retention in
** days. 
*/

create procedure sp_MScleanup_conflict_table
AS
BEGIN
	declare	@retcode			int
	declare @pubid				uniqueidentifier
	declare	@conflict_retention	int
			,@conflict_table	sysname
			,@cmd				nvarchar(4000)
			,@tranpubid			int

	/*
	** Security Check
	*/
    EXEC @retcode = dbo.sp_MSreplcheck_publish
    IF @@ERROR <> 0 or @retcode <> 0
        return (1)

	--
	-- merge cleanup
	--
	if exists (select * from sysobjects where name = 'sysmergepublications')
	begin
		declare PC CURSOR LOCAL FAST_FORWARD for select DISTINCT pubid, conflict_retention
			from sysmergepublications where LOWER(publisher)=LOWER(@@SERVERNAME) and publisher_db=db_name() and conflict_retention>0
		open PC
		fetch PC into @pubid, @conflict_retention
		while (@@fetch_status<>-1)
		begin
			exec @retcode = sp_MScleanup_conflict @pubid, @conflict_retention
			if @@ERROR<>0 or @retcode<>0
			begin
				close PC
				deallocate PC
				return (1)
			end
			fetch next from PC into  @pubid, @conflict_retention
		end
		close PC
		deallocate PC
	end

	--
	-- tran cleanup
	--
	if (EXISTS (select * from sysobjects where name = 'syspublications'))
	begin
		--
		-- do for each conflict table in each publication
		--
		declare hCftTab cursor LOCAL FAST_FORWARD for
			select a.pubid, a.conflict_retention, OBJECT_NAME(c.conflict_tableid)
			from (syspublications as a join sysarticles as b on a.pubid = b.pubid)
				join sysarticleupdates as c on c.artid = b.artid and c.pubid = b.pubid
			where a.allow_queued_tran = 1 and a.conflict_retention>0

		open hCftTab
		fetch hCftTab into @tranpubid, @conflict_retention, @conflict_table
		while (@@fetch_status != -1)
		begin
			--
			-- delete the expired messages
			--
			select @cmd = 'delete ' + quotename(master.dbo.fn_MSgensqescstr(@conflict_table)) collate database_default + 
				' where datediff(dd, getdate(), insertdate) > ' + 
				cast(@conflict_retention as nvarchar(10)) +
				' and pubid = ' + cast(@tranpubid as nvarchar(10))

			execute (@cmd)
			if (@@error != 0)
			begin
				close hCftTab
				deallocate hCftTab
				return 1				
			end
				
			--
			-- Get next conflict table to clean
			--
			fetch hCftTab into @tranpubid, @conflict_retention, @conflict_table
		end

		--
		-- close cursor
		--
		close hCftTab
		deallocate hCftTab
	end

	--
	-- all done 
	--
	return 0
END
GO
exec dbo.sp_MS_marksystemobject sp_MScleanup_conflict_table
go

--------------------------------------------------------------------------------
--. sp_MSpublicationview
--------------------------------------------------------------------------------
if exists (select * from sysobjects
    where type = 'P'
      and name = 'sp_MSpublicationview')
    drop procedure sp_MSpublicationview
go
raiserror('Creating procedure sp_MSpublicationview', 0,1)
GO
CREATE PROCEDURE sp_MSpublicationview(
    @publication sysname,
    @force_flag int = 0,
    @max_network_optimization bit = 0
    ) AS
    declare     @pubid              uniqueidentifier
    declare     @artid              uniqueidentifier
    declare     @join_articlename       nvarchar(270)
    declare     @join_viewname      nvarchar(270)
    declare     @join_before_view  	nvarchar(270)
    declare		@before_name		nvarchar(270)
    declare		@before_viewname	nvarchar(270)
    declare 	@unqual_sourcename	nvarchar(270)
    declare     @article            nvarchar(270)
    declare     @art_nick           int
    declare     @join_nick          int
    declare     @join_filterclause  nvarchar(4000)
    declare     @bool_filterclause  nvarchar(4000)
    declare     @view_rule          nvarchar(4000)
    declare		@before_view_rule	nvarchar(4000)
    declare		@before_objid		int
    declare     @article_level      int
    declare     @progress           int
    declare     @art                int
    declare     @viewname           nvarchar(270)
    declare     @procname           nvarchar(300)
    declare     @source_objid       int
    declare     @source_object      nvarchar(270)
    declare     @sync_objid         int
    declare 	@bitset				int
    declare     @permanent          int
    declare     @temporary          int
    declare     @filter_id          int
    declare     @filter_id_str      nvarchar(10)
	declare 	@guidstr nvarchar(40)
	declare 	@pubidstr nvarchar(40)
    declare     @rgcol              nvarchar(270)
    declare     @view_type          int
    declare     @belongsname        nvarchar(270)
    declare     @join_nickstr       nvarchar(10)
    declare     @unqual_jointable   nvarchar(270)  
    declare     @retcode            smallint
    declare     @hasguid            int
    declare 	@vertical_partition int
    declare     @join_unique_key    int
    declare     @simple_join_view   int
    declare     @join_filterid      int
    declare     @allhaveguids       int
    declare     @command            nvarchar(4000)
    declare     @objid              int
    declare     @owner              nvarchar(270)
    declare		@table				nvarchar(270)
    declare     @quoted_view        nvarchar(290)
    declare     @before_rowguidname	sysname
    declare     @quoted_pub         nvarchar(290)
    declare     @quoted_proc        nvarchar(290)
	declare 	@snapshot_ready		int
	declare 	@columns			varbinary(128)
	declare		@column_list		nvarchar(4000)
	declare		@prefixed_column_list		nvarchar(4000)
	declare 	@colname			nvarchar(270)
	declare 	@colid				int
    declare     @dynamic_filters    bit
    declare		@alias_for_sourceobject	sysname
    set @progress       = 1
    set @article_level  = 0
    set @permanent      = 1
    set @temporary      = 2
    set @allhaveguids   = 1
    set @before_rowguidname = NULL
    /*
    ** Only legal publisher can run this stored procedure
    */
    set nocount on
	/* make sure current database is enabled for merge replication */
    exec @retcode=dbo.sp_MSCheckmergereplication
    if @@ERROR<>0 or @retcode<>0
    	return (1)

    select @pubid = pubid, @snapshot_ready = snapshot_ready, @dynamic_filters = dynamic_filters FROM sysmergepublications 
        WHERE name = @publication and UPPER(publisher)=UPPER(@@servername) and publisher_db=db_name() 
    IF @pubid IS NULL
        BEGIN
            RAISERROR (20026, 11, -1, @publication)
            RETURN (1)
        END

	select @table=object_name(objid) from sysmergearticles where pubid=@pubid and (columns is NULL or columns = 0x00)
	if @table is not NULL
		begin
			raiserror(21318, 16, -1, @table)
			return (1)
		end

    -- If snapshot is already ready, views are good.  Don't drop and recreate as someone
    -- might be using them.
    
	if @snapshot_ready = 1 and @force_flag = 0
		return (0)
		
	exec @retcode = dbo.sp_MSguidtostr @pubid, @pubidstr out
	if @@ERROR <>0 OR @retcode <>0 return (1)

    create table #art(indexcol int identity NOT NULL, art_nick int NOT NULL, article_level int NOT NULL)
    if @@ERROR <> 0
        begin
        goto FAILURE
        end

    while @progress > 0
        BEGIN
        /*
        ** Select articles that have either a boolean_filter or at least one join filter 
        ** into a temp table in an optimized order.
        */
        insert into #art(art_nick, article_level) select nickname, @article_level from sysmergearticles 
            where pubid=@pubid and nickname not in (select art_nick from #art)
                and nickname not in 
                (select  art_nickname from sysmergesubsetfilters
                    where pubid=@pubid and join_nickname not in 
                        (select art_nick from #art))
        /*
        ** NOTENOTE: add error checking here.
        */

        set @progress = @@rowcount
        select @article_level = @article_level + 1
        END

    /* Drop the old views and reset sync_objid */
    select @art_nick = min(nickname) from sysmergearticles where pubid = @pubid and objid<>sync_objid
    while @art_nick is not null
        begin
        /* Drop the old view */
        select @viewname = OBJECT_NAME (sync_objid), @before_viewname = OBJECT_NAME(before_view_objid)
        	from sysmergearticles where
            pubid = @pubid and nickname = @art_nick
        if @viewname IS NOT NULL
        begin
            select @quoted_view = QUOTENAME(@viewname)
            exec ('drop view ' + @quoted_view)
        end
        if @before_viewname IS NOT NULL
        begin
            exec ('drop view ' + @before_viewname)
        end
        /* Update the row in sysmergearticles */
        update sysmergearticles set view_type = 0, sync_objid = objid where 
            pubid = @pubid and nickname = @art_nick
        if @@ERROR <> 0 goto FAILURE

        /* Find the next one */
        select @art_nick = min(nickname) from sysmergearticles where pubid = @pubid and objid<>sync_objid
        end
        
    set @art = 0
    select @art=min(indexcol) from #art where indexcol>@art

    while (@art is not null)
        begin
        select @art_nick=art_nick, @article_level = article_level from #art 
                where indexcol = @art
        select @article = name, @artid = artid, @columns = columns, @source_objid = objid,
        	@sync_objid = sync_objid, @procname = view_sel_proc, @before_objid = before_image_objid from sysmergearticles 
                where nickname=@art_nick and pubid = @pubid
                
        exec @retcode = sp_MSgetcolumnlist @pubid, @column_list OUTPUT, @source_objid
        
		set @before_name = OBJECT_NAME(@before_objid)
		if @before_name is not null
			begin
			select @before_rowguidname=name from syscolumns where id=@source_objid and columnproperty(@source_objid, name , 'isrowguidcol')=1
			exec @retcode = dbo.sp_MSguidtostr @pubid, @guidstr out
			set @before_viewname = @before_name + '_v_' + @guidstr
			end
		else
			set @before_viewname = NULL
        select @quoted_proc = QUOTENAME(@procname)
        
		exec @retcode = dbo.sp_MSguidtostr @artid, @guidstr out
		if @@ERROR <>0 OR @retcode <>0 return (1)

        select @source_object = QUOTENAME(user_name(uid)) + '.' + QUOTENAME(name) from sysobjects 
                where id = @source_objid 
        select @unqual_sourcename = QUOTENAME(OBJECT_NAME(@source_objid))
        
        select @bool_filterclause=subset_filterclause, @vertical_partition=vertical_partition 
        	from sysmergearticles where name = @article and pubid = @pubid

		-- verify the syntax of boolean filter, if added with vertical-partition to true
		-- in this case, the filter clause can contain columns that do not exist in the partition.
        if len(@bool_filterclause) > 0
        	begin
			/*
			-- let server return appropriate error message 
			exec ('select ' + @column_list + ' into #temptable_publicationview from ' + @source_object + 
				'declare @test int select @test=1 from #temptable_publicationview ' + @unqual_sourcename + ' where ' + @bool_filterclause)
			if @@ERROR<>0
			begin
				raiserror(21256, 16, -1, @bool_filterclause, @source_object)
				return (1)
			end
			*/
        	select @bool_filterclause = ' (' + @bool_filterclause + ') '
        	end
                
        set @rgcol = NULL
        select @rgcol = QUOTENAME(name) from syscolumns where id = @source_objid and
                ColumnProperty(id, name, 'isrowguidcol') = 1
        if @rgcol is not NULL
            set @hasguid = 1
        else 
            begin
            set @hasguid = 0
            set @allhaveguids = 0
            end

        /*
        ** Process non looping articles that have either a boolean or a join_filter.
        */
        if ( @article_level > 0 OR (len(@bool_filterclause) > 0) ) 
            begin
            /*
            ** If the article has a previously generated view, then drop the view before 
            ** creating the new one.
            */
            set @viewname = NULL
            select @viewname =  name from sysobjects where id = @sync_objid and
                ObjectProperty (id, 'IsView') = 1  and
                ObjectProperty (id, 'IsMSShipped') = 1 
            if @viewname IS NOT NULL
                begin
                    select @quoted_view = QUOTENAME(@viewname)
                    exec ('drop view ' + @quoted_view)
                    if @@ERROR<>0 return (1)
                end
                /*
                ** Any join filter(s)? If any, process join filter(s)
            	*/
            if (@article_level > 0) 
                begin
                declare pub1 CURSOR LOCAL FAST_FORWARD FOR select join_filterclause, join_nickname, join_articlename,
                    join_unique_key, join_filterid from sysmergesubsetfilters where pubid=@pubid and artid=@artid
                FOR READ ONLY
                open pub1                                       
                fetch pub1 into @join_filterclause, @join_nick, @join_articlename, @join_unique_key, @join_filterid
				select @join_filterclause=' ( ' + @join_filterclause + ') '
                select @unqual_jointable = QUOTENAME(name) from sysobjects 
                    where id = (select objid from sysmergearticles where name=@join_articlename and pubid=@pubid) 
                
                if @max_network_optimization = 0
			        select @join_viewname = object_name(sync_objid), @join_before_view = object_name(before_image_objid)
                	from sysmergearticles where nickname = @join_nick and pubid = @pubid
                else
					select @join_viewname = object_name(sync_objid), 
					@join_before_view = object_name(case when before_view_objid is not null then before_view_objid else before_image_objid end)
                	from sysmergearticles where nickname = @join_nick and pubid = @pubid
					
                select @join_viewname = QUOTENAME(@join_viewname)

                if (@join_unique_key = 1 and (@bool_filterclause is null or len(@bool_filterclause) = 0) and
                    not exists (select * from sysmergesubsetfilters where pubid=@pubid and artid=@artid and join_filterid <> @join_filterid))
                    begin
                    set @simple_join_view = 1
                    if @column_list = ' * '
                    	select @column_list = ' ' + @unqual_sourcename + '.* '
                    set @view_rule = 'select ' + @column_list + ' from ' + @source_object + ' ' + @unqual_sourcename + ' , ' +  @join_viewname + ' ' + @unqual_jointable + ' where ' + @join_filterclause
                    /* add security check to the view if this is a dynamically filtered publication */
                    set @view_rule = @view_rule + ' and ((is_srvrolemember(''sysadmin'') = 1) or (is_member(''db_owner'') = 1) or (sessionproperty(''replication_agent'') = 1))'
                    end
                else
                    begin
                    set @simple_join_view = 0
					/* Alias the source object with the unqualified name and use that to select the rowguidcol */                   
                    set @view_rule = 'select ' + @unqual_sourcename + '.rowguidcol from ' + @source_object  + ' ' + @unqual_sourcename + ' , ' +  @join_viewname + ' ' + @unqual_jointable + ' where ' + @join_filterclause
                    end
                if @before_name is not null
                	set @before_view_rule = 'select * from ' + @before_name + ' ' +  @unqual_sourcename + ' where exists (select * from ' +
                   	 	@join_viewname + ' ' + @unqual_jointable + ' where ' + @join_filterclause + ') or exists (select * from ' +
                   	 	@join_before_view + ' ' + @unqual_jointable + ' where ' + @join_filterclause + ') '
                   	 	
                fetch next from pub1 into @join_filterclause, @join_nick, @join_articlename, @join_unique_key, @join_filterid
                WHILE (@@fetch_status <> -1)
                    begin
					select @join_filterclause=' ( ' + @join_filterclause + ') '
                    select @unqual_jointable = name from sysobjects 
                        where id = ( select objid from sysmergearticles where name=@join_articlename and pubid=@pubid) 
       
					if @max_network_optimization = 0
		                select @join_viewname = object_name(sync_objid), @join_before_view = object_name(before_image_objid)
                		from sysmergearticles where nickname = @join_nick and pubid = @pubid
                	else
                		select @join_viewname = object_name(sync_objid), 
               			@join_before_view = object_name(case when before_view_objid is not null then before_view_objid else before_image_objid end)
                		from sysmergearticles where nickname = @join_nick and pubid = @pubid
                	
                    select @join_viewname = QUOTENAME(@join_viewname)
                    set @view_rule = @view_rule + ' union select ' + @source_object + '.rowguidcol from ' + @source_object + ', ' +  @join_viewname + ' ' + @unqual_jointable + ' where ' + @join_filterclause
                   	if @before_name is not null
                		set @before_view_rule = @before_view_rule + ' or exists (select * from ' +
                   	 	@join_viewname + ' ' + @unqual_jointable + ' where ' + @join_filterclause + ') or exists (select * from ' +
                   	 	@join_before_view + ' ' + @unqual_jointable + ' where ' + @join_filterclause + ') '
                 
                    fetch next from pub1 into @join_filterclause, @join_nick, @join_articlename, @join_unique_key, @join_filterid
                    end 
                close pub1
                deallocate pub1
                        
                if len(@bool_filterclause) > 0
                	begin
                    set @view_rule = @view_rule + ' union select ' + @source_object + '.rowguidcol from '+ @source_object + ' where '+ @bool_filterclause
                   	if @before_name is not null
                		set @before_view_rule = @before_view_rule + ' or ' + @bool_filterclause
					
                    end
                -- Now do the actual view rule as a semi-join, if not a simple join on unique key
                if (@simple_join_view = 0)
                    begin
                    /* 
                    ** Generate a unique alias for the outer select to make sure that it does not generate an
                    ** ambiguous reference with table names used in the join_filter clause 
                    */
					set @alias_for_sourceobject = 'alias_' + @guidstr
					exec @retcode = sp_MSgetcolumnlist @pubid, @prefixed_column_list OUTPUT, @source_objid, @alias_for_sourceobject

                    set @view_rule = 'select ' + @prefixed_column_list + ' from ' + @source_object + ' ' + @alias_for_sourceobject + ' where rowguidcol in (' + @view_rule + ')'
					set @view_rule = @view_rule + ' and ((is_srvrolemember(''sysadmin'') = 1) or (is_member(''db_owner'') = 1) or (sessionproperty(''replication_agent'') = 1))'
                    end
                end
            else  /* boolean filter only */
            	begin
                select @view_rule = ' select ' + @column_list + ' from '+ @source_object + ' ' + @unqual_sourcename + ' where '+ @bool_filterclause
				if @before_name is not null
					set @before_view_rule = ' select * from ' + @before_name + ' ' + @unqual_sourcename + ' where ' + @bool_filterclause
                set @view_rule = @view_rule + ' and ((is_srvrolemember(''sysadmin'') = 1) or (is_member(''db_owner'') = 1) or (sessionproperty(''replication_agent'') = 1))'
				end
                           
            select @viewname = @publication + '_' + @article + '_VIEW'
            exec @retcode = dbo.sp_MSuniqueobjectname @viewname , @viewname output
            select @quoted_view = QUOTENAME(@viewname)
            
            if @retcode <> 0 or @@ERROR <> 0 return (1) 
            /* If we havent generated rowguidcol yet, use dummy rule that doesnt refer to it */
            if @hasguid = 0
                set @view_rule = ' select ' + @column_list + ' from '+ @source_object + ' ' + @unqual_sourcename
            exec ('create view '+ @quoted_view + ' as '+ @view_rule)
            if @@ERROR<>0
            	return (1)
            /* grant select permission on sync view to public - security check is performed inside the view */ 
			exec ('grant select on ' + @quoted_view + ' to public')
			if @@ERROR<>0
				return (1)
            /* Mark view as system object */                        
            execute sp_MS_marksystemobject @quoted_view
            if @@ERROR<>0
            	return (1)
            if @hasguid = 1
                begin
                select @procname=view_sel_proc from sysmergearticles where pubid=@pubid and artid=@artid
		        if object_id(@procname) is not NULL
                    begin
                    exec ('drop procedure ' + @quoted_proc)
                    update sysmergearticles set view_sel_proc = NULL where artid = @artid and pubid = @pubid 
                    end
                else
                    begin
					set @procname = 'sel_' + substring(@guidstr, 1, 16) + substring(@pubidstr, 1, 16)
                    exec @retcode = dbo.sp_MSuniqueobjectname @procname , @procname output
                    if @retcode <> 0 or @@ERROR <> 0
                            return (1)
                    end
                select @owner = user_name(uid) from sysobjects 
                    where name = @viewname 
                exec dbo.sp_MSmakeviewproc @viewname, @owner, @procname, @rgcol, @source_objid
                if @retcode<>0 or @@ERROR<>0
                	return (1)
                update sysmergearticles set view_sel_proc = @procname where pubid=@pubid and artid=@artid
                end
            select @quoted_view = QUOTENAME(@viewname)
            update sysmergearticles set sync_objid = OBJECT_ID (@quoted_view), view_type = @permanent
                where artid = @artid and pubid = @pubid 
			if @before_name is not null and @before_view_rule is not null
				begin
				exec @retcode = sp_MScreatebeforetable @source_objid
				if @@ERROR <>0 OR @retcode <>0 return (1)
				if object_id(@before_viewname) is not NULL
					exec ('drop view ' + @before_viewname)				
				exec ('create view ' + @before_viewname + ' as ' + @before_view_rule)
				if @@ERROR<>0
					return (1)
				if @before_rowguidname is not NULL
					begin
						exec ('grant select (' + @before_rowguidname + ') on '+ @before_viewname + ' to public')
						if @@ERROR<>0
							return (1)
					end

				exec ('grant select (generation) on '+ @before_viewname + ' to public')
				if @@ERROR<>0
					return (1)

				execute sp_MS_marksystemobject @before_viewname
	            if @@ERROR<>0
    	        	return (1)
	            update sysmergearticles set before_view_objid = OBJECT_ID (@before_viewname)
	            	where artid = @artid and pubid = @pubid
				end

            end /* end of view creation for this article */
        else 
        begin
            select @sync_objid = @source_objid
            if @vertical_partition=1 and @column_list<> ' * '
				begin
					select @viewname = @publication + '_' + @article + '_VIEW'
		            exec @retcode = dbo.sp_MSuniqueobjectname @viewname , @viewname output
					select @quoted_view = QUOTENAME(@viewname)
					set @view_rule = ' select ' + @column_list + ' from '+ @source_object + ' ' + @unqual_sourcename
                    set @view_rule = @view_rule + ' where ((is_srvrolemember(''sysadmin'') = 1) or (is_member(''db_owner'') = 1) or (sessionproperty(''replication_agent'') = 1))'

	            	exec ('create view '+ @quoted_view + ' as '+ @view_rule)
	            	if @@ERROR<>0
	            		return (1)
	        	    execute sp_MS_marksystemobject @quoted_view
	            	if @@ERROR<>0
	            		return (1)

                    /* grant select permission on sync view to public - security check is performed inside the view */ 
					exec ('grant select on ' + @quoted_view + ' to public')
					if @@ERROR<>0
	                	return (1)
	            	select @sync_objid=object_id(@viewname)
				update sysmergearticles set view_sel_proc = @procname, sync_objid=@sync_objid
    	            where artid = @artid and pubid = @pubid 
				end
            else if @dynamic_filters = 1
                begin
                    /* This article doesn't have any vertical or horizontal filters but if the publication is enabled for dynamic filtering, 
                        we still want to generate a dummy view so that logins in the publication access list can generate a dynamic snapshot. */
                    select @viewname = @publication + '_' + @article + '_VIEW'
                    exec @retcode = dbo.sp_MSuniqueobjectname @viewname, @viewname output
                    select @quoted_view = QUOTENAME(@viewname)
                    set @view_rule = ' select  * from ' + @source_object  + ' where ((is_srvrolemember(''sysadmin'') = 1) or (is_member(''db_owner'') = 1) or (sessionproperty(''replication_agent'') = 1))'     
	            	exec ('create view '+ @quoted_view + ' as '+ @view_rule)
	            	if @@ERROR<>0
	            		return (1)
	        	    execute sp_MS_marksystemobject @quoted_view
	            	if @@ERROR<>0
	            		return (1)
                    exec ('grant select on ' + @quoted_view + ' to public')
        	        if @@ERROR<>0
	                	return (1)
	            	select @sync_objid=object_id(@viewname)
    				update sysmergearticles set view_sel_proc = @procname, sync_objid=@sync_objid, view_type = @permanent
    	            where artid = @artid and pubid = @pubid 
                end

        	if @hasguid = 1
            begin
            /* still make the select proc, although it selects directly from table */
	        if object_id(@procname) is not NULL
				begin
					exec ('drop proc ' + @procname)
					update sysmergearticles set view_sel_proc = NULL where artid = @artid and pubid = @pubid 
				end
			set @procname = 'sel_' + substring(@guidstr, 1, 16) + substring(@pubidstr, 1, 16)
            exec @retcode = dbo.sp_MSuniqueobjectname @procname , @procname output
            if @retcode <> 0 or @@ERROR <> 0 return (1) 
            select @owner = user_name(uid), @viewname = name from sysobjects 
                where id = @source_objid
            exec dbo.sp_MSmakeviewproc @viewname, @owner, @procname, @rgcol, @source_objid
			update sysmergearticles set view_sel_proc = @procname where pubid=@pubid and artid=@artid
            end
        end
   select @art=min(indexcol) from #art where indexcol>@art
   end

    /* If there are looping articles, we must use a dynamic publication since no views on temp tables */
    update sysmergearticles set view_type = @temporary
        where pubid=@pubid and nickname not in (select art_nick from #art)
    if @@rowcount > 0
        begin
        if not exists (select * from sysmergepublications where dynamic_filters = 1 and pubid = @pubid)
            begin
            declare @repl_nick int
            /* treat these articles as if the publication were dynamic */
            execute @retcode = dbo.sp_MSgetreplnick @nickname = @repl_nick output
            if (@@error <> 0) or @retcode <> 0 or @repl_nick IS NULL 
		        begin
		        RAISERROR (14055, 11, -1)
		        RETURN(1)
		        end                 

            select @art_nick = min(nickname) from sysmergearticles where
                pubid = @pubid and view_type = @temporary
            while @art_nick is not null
                begin
                /* Loop over articles with circular filters.  Create dummy view and add rows to contents */
                select @article = name, @artid = artid, @source_objid = objid, @sync_objid = sync_objid, @procname = view_sel_proc from sysmergearticles 
                    where nickname=@art_nick and pubid = @pubid
                select @source_object = QUOTENAME(user_name(uid)) + '.' + QUOTENAME(name) from sysobjects 
                    where id = @source_objid 

                set @viewname = NULL
                select @viewname =  name from sysobjects where id = @sync_objid and
                    ObjectProperty (id, 'IsView') = 1  and
                    ObjectProperty (id, 'IsMSShipped') = 1 
                if @viewname IS NOT NULL
                    begin
                        select @quoted_view = QUOTENAME(@viewname)
                        exec ('drop view ' + @quoted_view)
                        if @@ERROR<>0 return (1)
                    end
                select @viewname = 'SYNC_' + @publication + '_' + @article 
                exec @retcode = dbo.sp_MSuniqueobjectname @viewname , @viewname output
                if @retcode <> 0 or @@ERROR <> 0 return (1) 
                select @quoted_view = QUOTENAME(@viewname)
                exec ('create view ' + @quoted_view + ' as select * from ' + @source_object + ' 
                        where 1 = 0 ')
                if @@ERROR<>0 return (1)
                update sysmergearticles set sync_objid = OBJECT_ID (@viewname),
                    view_sel_proc = NULL where artid = @artid and pubid = @pubid 
                if @@ERROR<>0 return (1)

				select @owner = user_name(uid) from sysobjects where id = @source_objid
				set @table = OBJECT_NAME(@source_objid)
        		exec @retcode = dbo.sp_addtabletocontents @table, @owner
                IF @@ERROR <> 0 or @retcode <> 0 return (1)
                
                select @art_nick = min(nickname) from sysmergearticles where
                    pubid = @pubid and view_type = @temporary and nickname > @art_nick
                end
            end
        end
        
    drop table #art
    if @allhaveguids = 1
        begin
        declare @dbname sysname
        set @dbname = db_name()
        /* create the filter expand procs now */
        set @filter_id = 0
        select @filter_id = min(join_filterid) from sysmergesubsetfilters where
                pubid = @pubid and join_filterid > @filter_id
        while @filter_id is not null
            begin
            set @filter_id_str = convert(nvarchar(10), @filter_id)
            select @procname = expand_proc
                from sysmergesubsetfilters where pubid = @pubid and join_filterid = @filter_id
            /* drop old proc, or generate a new procname */
            select @quoted_proc = QUOTENAME(@procname)
	        if object_id(@procname) is not NULL
                exec ('drop procedure ' + @quoted_proc)
            else
                begin
                set @procname = 'expand_' + @filter_id_str
                exec @retcode = dbo.sp_MSuniqueobjectname @procname, @procname output
                if @retcode <>0 return (1)
                update sysmergesubsetfilters set expand_proc = @procname where  pubid = @pubid and join_filterid = @filter_id
                end
            select @quoted_proc = QUOTENAME(@procname)
            select @quoted_pub = QUOTENAME(@publication)
            set @command = 'exec dbo.sp_MSmakeexpandproc ' + @quoted_pub + ' , ' + @filter_id_str + ', ' + @quoted_proc
            exec @retcode = master..xp_execresultset @command, @dbname
            if @retcode <> 0 return (1)
			exec dbo.sp_MS_marksystemobject @quoted_proc
            if @@ERROR<>0
            	return (1)
            exec ('grant execute on ' + @quoted_proc + ' to public ')
            select @filter_id = min(join_filterid) from sysmergesubsetfilters where
                pubid = @pubid and join_filterid > @filter_id
            end
        end

    return (0)

FAILURE: 
    return (1)
go
exec dbo.sp_MS_marksystemobject sp_MSpublicationview
go
grant execute on dbo.sp_MSpublicationview to public
go
--------------------------------------------------------------------------------
--. sp_MScomputemergearticlescreationorder
--------------------------------------------------------------------------------
if exists (select * from sysobjects
    where type = 'P' and 
    name = 'sp_MScomputemergearticlescreationorder')
    drop procedure sp_MScomputemergearticlescreationorder

raiserror(15339,-1,-1,'sp_MScomputemergearticlescreationorder')
GO
CREATE PROCEDURE sp_MScomputemergearticlescreationorder
    @publication sysname
AS
    SET NOCOUNT ON
    DECLARE @pubid uniqueidentifier 
    DECLARE @max_level int
    DECLARE @current_level int
    DECLARE @update_level int
    DECLARE @limit int

    SELECT @pubid = NULL
    -- Get the pubid from sysmergepublications 
    SELECT @pubid = pubid 
      FROM sysmergepublications
     WHERE name = @publication
       AND UPPER(publisher) = UPPER(@@SERVERNAME)
       AND publisher_db = DB_NAME()

    IF @@ERROR <> 0
        RETURN (1)

    IF @pubid IS NULL
    BEGIN
        RAISERROR(20026, 16, -1, @publication)
        RETURN (1)
    END

    -- Find out the total number of articles in this publication and
    -- compute the maximum tree height based on the number of articles in 
    -- the publication. Here, the tree height is counted from the
    -- leaf-nodes towards the root(s) starting from @max_level
    SELECT @max_level = COUNT(*) + 10,
           @limit = 2 * COUNT(*) + 11 
      FROM sysmergeextendedarticlesview 
     WHERE pubid = @pubid
 
    IF @@ERROR <> 0
    BEGIN
        RETURN (1)
    END
   
    -- The following temp table contains the minimal amount of 
    -- article information that we want to keep around and the current
    -- computed tree level of the article
    CREATE TABLE #article_level_info
    (
        article         sysname collate database_default not null,
        source_objid    INT     NOT NULL,
        tree_level      INT     NOT NULL,
        nickname        INT     NOT NULL,
        major_type      TINYINT NOT NULL  -- 1-view&func, 0-other
    )  
   
    CREATE CLUSTERED INDEX ucarticle_level_info 
        ON #article_level_info(source_objid)

    IF @@ERROR <> 0
    BEGIN
        GOTO Failure
    END

    -- Populate the article level info table. All articles will be
    -- assigned 0 as their initial tree level. Having 
    -- a tree level of 0 means that the algorithm hasn't discovered 
    -- any objects that the article depends on within the publication.

    INSERT INTO #article_level_info 
    SELECT name, objid, 0, ISNULL(nickname, 5*@max_level),
        CASE type
            WHEN 0x40 THEN 1
            WHEN 0x80 THEN 1
            ELSE 0
        END 
      FROM sysmergeextendedarticlesview
     WHERE pubid = @pubid
      
    -- To jump-start the algorithm, update the tree_level of 
    -- all articles with no dependency to @max_level.

    UPDATE #article_level_info 
       SET tree_level = @max_level
     WHERE NOT EXISTS (SELECT * 
                         FROM sysdepends 
                        WHERE source_objid = id
                          AND id <> depid)
    IF @@ERROR <> 0
        GOTO Failure

    -- For each increasing tree level starting from @max_level, update the 
    -- the tree_level of articles depending on objects at the current
    -- level to current level + 1
    SELECT @current_level = @max_level
    WHILE 1 = 1
    BEGIN
        SELECT @update_level = @current_level + 1

        UPDATE #article_level_info
           SET tree_level = @update_level
          FROM #article_level_info 
        INNER JOIN sysdepends d
            ON #article_level_info.source_objid = d.id 
        INNER JOIN #article_level_info ali1
            ON (d.depid = ali1.source_objid       
               AND ali1.tree_level = @current_level
               AND d.id <> d.depid)
    
        -- Terminate the algorithm if we cannot find any articles 
        -- depending on articles at the current level     
        IF @@ROWCOUNT = 0
            GOTO PHASE1

        IF @@ERROR <> 0
            GOTO Failure

        SELECT @current_level = @current_level + 1

        -- Although there should not be any circular 
        -- dependencies among the articles, the following
        -- check is performed to guarantee that 
        -- the algorithm will terminate even if there 
        -- is circular dependency among the articles
        
        -- Note that with at least one node per level,
        -- the current level can never exceed the total 
        -- number of articles (nodes) unless there is
        -- circular dependency among the articles.
        
        -- @limit is defined to be # of articles + 1
        -- although @limit = # of articles - 1 will be
        -- sufficient. This is to make absolutely sure that 
        -- the algorithm will never terminate too early

        IF @current_level > @limit
            GOTO PHASE1
    END

PHASE1:
    
    -- There may be interdependencies among articles 
    -- that haven't been included in the previous calculations so
    -- we compute the proper order among these articles here.
    SELECT @limit = @max_level - 9
    SELECT @current_level = 0
    WHILE 1 = 1
    BEGIN
        SELECT @update_level = @current_level + 1
        
        UPDATE #article_level_info 
           SET tree_level = @update_level
          FROM #article_level_info
        INNER JOIN sysdepends d
            ON (#article_level_info.source_objid = d.id
                AND #article_level_info.tree_level < @max_level) 
        INNER JOIN #article_level_info ali1
            ON (d.depid = ali1.source_objid
                AND ali1.tree_level = @current_level
                AND d.id <> d.depid)
        IF @@ROWCOUNT = 0
            GOTO PHASE2
        
        IF @@ERROR <> 0
            GOTO Failure

        SELECT @current_level = @current_level + 1
        IF @current_level > @limit
            GOTO PHASE2
    END         

PHASE2:

    -- Select the articles out of #article_level_info 
    -- in ascending order of tree_level. This will give
    -- the proper order in which articles can be created
    -- without violating the internal dependencies among
    -- the themselves. Note that this algorithm still allows 
    -- unresolved external references outside the publication.
    -- All this algorithm can guarantee is that all articles will
    -- be created successfully using the resulting order if 
    -- there is no dependent object outside the publication. 

    SELECT article
      FROM #article_level_info
    ORDER BY major_type ASC, tree_level ASC, nickname ASC

    DROP TABLE #article_level_info
    RETURN (0)

Failure:

    DROP TABLE #article_level_info
    RETURN (1)
GO

exec dbo.sp_MS_marksystemobject sp_MScomputemergearticlescreationorder
grant exec on dbo.sp_MScomputemergearticlescreationorder to public
go

--------------------------------------------------------------------------------
--. sp_MSlocalizeinterruptedgenerations
--------------------------------------------------------------------------------
if exists (select * from sysobjects
    where type = 'P' and 
    name = 'sp_MSlocalizeinterruptedgenerations')
    drop procedure sp_MSlocalizeinterruptedgenerations
go
raiserror('Creating procedure sp_MSlocalizeinterruptedgenerations', 0,1)
GO

CREATE PROCEDURE sp_MSlocalizeinterruptedgenerations	@localize_zeroartnick_generations bit=0
-- this proc loops over interrupted generations 
-- and transfers those changes that arrived before the interrupt to a new local generation
as
begin

	declare @new_guidsrc uniqueidentifier

	if @localize_zeroartnick_generations = 0
		update dbo.MSmerge_genhistory set @new_guidsrc = guidsrc = newid(), guidlocal = @new_guidsrc, coldate = getdate()
		where guidlocal = '00000000-0000-0000-0000-000000000000'  -- incomplete gen
		and generation not in (select gen_cur from sysmergearticles)  -- not a local incomplete gen
		and coldate not in (select login_time from master..sysprocesses)  -- not a gen that currently receives replica updates from another db
		and isnull(art_nick, 0) <> 0		-- we don't localize generations with art_nick = 0 or NULL.
	else
		update dbo.MSmerge_genhistory set @new_guidsrc = guidsrc = newid(), guidlocal = @new_guidsrc, coldate = getdate()
		where guidlocal = '00000000-0000-0000-0000-000000000000'  -- incomplete gen
		and generation not in (select gen_cur from sysmergearticles)  -- not a local incomplete gen
		and coldate not in (select login_time from master..sysprocesses)  -- not a gen that currently receives replica updates from another db
	
	if @@error <> 0
		return 1
	else
		return 0
end
go
exec dbo.sp_MS_marksystemobject sp_MSlocalizeinterruptedgenerations
go
grant exec on dbo.sp_MSlocalizeinterruptedgenerations to public
go
if exists (select * from sysobjects 
        where name = 'sp_MSupdate_replication_status' 
                and type = 'P')
      drop procedure sp_MSupdate_replication_status
go
raiserror('Creating procedure sp_MSupdate_replication_status', 0,1)
go
create procedure sp_MSupdate_replication_status
@publisher sysname,
@publisher_db sysname,
@publication sysname,
@publication_type int = 0,      -- 0 Transactional/Snapshot 1 Merge
@agent_type int,
@agent_name nvarchar(100),
@status int
as

    declare @deleted int
    declare @refresh int
	declare @getstatus int
    declare @dummy int
	declare @is_merge_agent bit
	
	if @agent_type = 4 or @agent_type = 0x80000004
		set @is_merge_agent = 1
	else
		set @is_merge_agent = 0

    set @deleted = -1
    set @refresh = -2			-- Status used to only update the timestamp column
	set @getstatus = -3			-- Get status of agent for dummy distribution row


	-- if table dne, then we're just installing distribution so we don't need to update status
    if (select object_id('tempdb.dbo.MSreplication_agent_status')) is NULL
        return 0

	-- If there are not rows in the table, we know that it is not loaded or used
	-- No need to refresh (better performance)
	-- At least, there will on row if loaded (see sp_MSload_replication_status)
    if not exists (select * from tempdb.dbo.MSreplication_agent_status)
        return 0

	if @status = @getstatus
	begin
		select @status = isnull(status, 0) from tempdb.dbo.MSreplication_agent_status where
			UPPER(publisher) = UPPER(@publisher) and
            publisher_db = @publisher_db and
            publication = 'ALL' and
			agent_type = @agent_type
	end			

	-- Update timestamp column via dummy update
	if @status = @refresh
	begin
		-- Dummy update to force timestamps to be updated.
        update tempdb.dbo.MSreplication_agent_status set status = status where
            UPPER(publisher) = UPPER(@publisher) and
            publisher_db = @publisher_db and
            publication like @publication -- Must use like as publication may be "%"
        return (0)
	end

    -- Remove row if @deleted
    if @status = @deleted
    begin
        if @@trancount > 0
        begin
            if exists (select * from tempdb.dbo.MSreplication_agent_status with (TABLOCKX) where 1 = 1)
            begin
                select @dummy = 1
            end
        end        

		if @agent_name = '%' or @agent_name IS NULL
            delete from tempdb.dbo.MSreplication_agent_status with (TABLOCKX) where
                UPPER(publisher) = UPPER(@publisher) and
                publisher_db = @publisher_db and
                publication = @publication and
                agent_type = @agent_type 
		else
            delete from tempdb.dbo.MSreplication_agent_status with (TABLOCKX) where
                UPPER(publisher) = UPPER(@publisher) and
                publisher_db = @publisher_db and
                publication = @publication and
                agent_type = @agent_type and
                agent_name = @agent_name

        -- Dummy update to force timestamps to be updated.  This will signal a row has been
        -- removed.
        update tempdb.dbo.MSreplication_agent_status set status = status where
            UPPER(publisher) = UPPER(@publisher) and
            publisher_db = @publisher_db and
            publication = @publication
        return (0)
    end     

    -- If misc. replication job then the status needs to be mapped.
    if @agent_type = 5
    begin
        set @status = 
        case isnull(@status,5)	-- mapped to never run
            when 0 then 5   -- Fail mapping
            when 1 then 2   -- Success mapping
            when 2 then 5   -- Retry mapping
            when 3 then 2   -- Shutdown mapping
            when 4 then 3   -- Inprogress mapping
            when 5 then 0   -- Unknown is mapped to never run
        end
    end

	if @is_merge_agent = 1
	begin
		update tempdb.dbo.MSreplication_agent_status set status = @status 
				where agent_name = @agent_name and
				publication = @publication and
                UPPER(publisher) = UPPER(@publisher) and
                publisher_db = @publisher_db and
                agent_type = @agent_type

		if @@rowcount = 0
			insert into tempdb.dbo.MSreplication_agent_status 
		       (publisher, publisher_db, publication, publication_type, agent_type, status, agent_name) values
			   (@publisher, @publisher_db, @publication, @publication_type, @agent_type, @status, @agent_name)
	end
	else
	begin
	    if not exists (select * from tempdb.dbo.MSreplication_agent_status where 
		    UPPER(publisher) = UPPER(@publisher) and
			publisher_db = @publisher_db and
			publication = @publication and
			agent_type = @agent_type and
			agent_name = @agent_name)
			
			insert into tempdb.dbo.MSreplication_agent_status 
	                (publisher, publisher_db, publication, publication_type, agent_type, status, agent_name) values
					(@publisher, @publisher_db, @publication, @publication_type, @agent_type, @status, @agent_name)
				
		else
			update tempdb.dbo.MSreplication_agent_status set status = @status where
                UPPER(publisher) = UPPER(@publisher) and
                publisher_db = @publisher_db and
                (publication = @publication or @publication = 'ALL')and
                agent_type = @agent_type and
                agent_name = @agent_name
    end                

    return (0)
go
if exists (select * from sysobjects 
        where name = 'sp_MScreate_replication_status_table' 
                and type = 'P')
      drop procedure sp_MScreate_replication_status_table
go
raiserror('Creating procedure sp_MScreate_replication_status_table', 0,1)
go
create proc sp_MScreate_replication_status_table
as
    declare @retcode int

    if (select object_id('tempdb.dbo.MSreplication_agent_status')) is NULL
    begin
        -- begin tran
        create table tempdb.dbo.MSreplication_agent_status (
            publisher sysname NOT NULL,
            publisher_db sysname NOT NULL,
            publication sysname NOT NULL,
            publication_type int NOT NULL,          -- 0 transactional/snapshot  1 Merge
            agent_type int NOT NULL,
            status int NOT NULL,
            agent_name nvarchar(100) NOT NULL,
            timestamp NOT NULL
            )
        if @@error <> 0
            return 1
        
  		create clustered index cMSreplication_agent_status ON tempdb.dbo.MSreplication_agent_status (agent_name)
		if @@error <> 0
            return 1
        create nonclustered index nc1MSreplication_agent_status ON 
            tempdb.dbo.MSreplication_agent_status (publication, publisher_db, publisher)
        if @@error <> 0
            return 1
		create nonclustered index nc2MSreplication_agent_status ON 
            tempdb.dbo.MSreplication_agent_status (agent_type)
        if @@error <> 0
            return 1
		create nonclustered index nc3MSreplication_agent_status ON 
            tempdb.dbo.MSreplication_agent_status (timestamp)
        if @@error <> 0
            return 1
    end
    return 0  -- If here, all is well and we're done.
go

if exists (select * from sysobjects
	where type = 'P '
			and name = 'sp_MSCleanupForPullReinit')
	drop procedure sp_MSCleanupForPullReinit
go
CREATE PROCEDURE sp_MSCleanupForPullReinit (
	@publication 		sysname,
	@publisher_db		sysname,
	@publisher     		sysname = @@servername
	) AS
	declare @pubid 		uniqueidentifier
	declare @artid 		uniqueidentifier
	declare @retcode	smallint

	/*
    ** Security Check
    */
    EXEC @retcode = dbo.sp_MSreplcheck_publish
    IF @@ERROR <> 0 or @retcode <> 0
        return (1)

	/* This only gets called after database is enable to subscribe, so sysmergepublications should exist */
	select @pubid = pubid FROM sysmergepublications 
		WHERE name = @publication and UPPER(publisher)=UPPER(@publisher) and publisher_db = @publisher_db

	/* Normal case - nothing to cleanup, just return */
	if @pubid is null
		return (1)	

	begin transaction
	save tran cleanupforreinit
	/* 
	** Make sure you NULL out gen_cur for other articles that share this table 
	** since we are deleting the genhistroy row for that generation 
	*/
	update sysmergearticles set gen_cur=NULL where gen_cur in
		(select generation from MSmerge_genhistory where pubid = @pubid)
	if @@ERROR<>0 
		goto Error
	delete from MSmerge_genhistory where pubid = @pubid
	if @@ERROR<>0 
		goto Error
	delete from sysmergesubsetfilters where pubid=@pubid
	if @@ERROR<>0 
		goto Error
	delete from sysmergeschemachange where pubid = @pubid
	if @@ERROR<>0 
		goto Error
	delete from MSmerge_contents where tablenick in (select nickname from sysmergearticles where pubid=@pubid)
	if @@ERROR<>0 
		goto Error
	delete from MSmerge_tombstone where tablenick in (select nickname from sysmergearticles where pubid=@pubid)
	if @@ERROR<>0 
		goto Error
	update MSmerge_replinfo set recgen = NULL, recguid = NULL, sentgen = NULL, sentguid = NULL 
			where repid in ( select subid from sysmergesubscriptions where pubid = @pubid)
	if @@ERROR<>0 
		goto Error

	commit tran 
	return (0)

Error:
	rollback tran cleanupforreinit
	commit tran 
	return (1)
GO
exec dbo.sp_MS_marksystemobject sp_MSCleanupForPullReinit
go

grant execute on dbo.sp_MSCleanupForPullReinit to public
go
if object_id('dbo.sp_MSscriptviewproc', 'P') is not null 
    drop procedure dbo.sp_MSscriptviewproc
go
create procedure dbo.sp_MSscriptviewproc (
    @viewname  sysname,
    @ownername sysname,
    @procname  nvarchar(290),
    @rgcol     sysname,
    @objid     int = NULL -- for possible backward comp. issue
    )
as
begin

    declare @retcode        smallint
    declare @colname        nvarchar(258)
    declare @view_id        int
    declare @iscomputed     tinyint
    declare @xtype          sysname
    select @retcode=0
    declare @proctext       table (line_no int primary key identity(1,1), line nvarchar(4000))
    if @@error <> 0 or @retcode <> 0 begin select @retcode = 1 goto Failure end 

    set nocount on
    select @procname=QUOTENAME(@procname)
    insert into @proctext (line) values (
'create procedure dbo.' + @procname + ' (@tablenick int, @max_rows int = NULL,
    @guidlast uniqueidentifier = ''00000000-0000-0000-0000-000000000000'') 
    AS

    set nocount on
    set rowcount 0
    if  @max_rows is not null
    begin
        -- used to select data for initial pop. of subscriber for dynamic filtered publication
        set rowcount @max_rows
        declare @lin varbinary (255)
        declare @cv varbinary (2048)
        declare @replnick int
        declare @objid int
        declare @ccols int

        select @objid = objid from sysmergearticles where nickname = @tablenick
        select @ccols = max(colid) from syscolumns where id = @objid
        
        exec dbo.sp_MSgetreplnick @nickname = @replnick out
        if (@@error <> 0) or @replnick IS NULL 
        begin
            RAISERROR (14055, 11, -1)
            RETURN(1)
        end                 
        set @lin = { fn UPDATELINEAGE(0x0, @replnick, 1) }
        set @cv = { fn INITCOLVS(@ccols, @replnick) }

        select @tablenick, v.' + @rgcol + ', coalesce (c.generation,1), 
            coalesce (c.lineage, @lin), coalesce (c.colv1, @cv)')
    if @@error <> 0 or @retcode <> 0 begin select @retcode = 1 goto Failure end 

    if @objid is not NULL and exists (select * from syscolumns where id = @objid 
        and (iscomputed=1 or type_name(xtype)='timestamp'))
    begin
        select @view_id = object_id(@viewname)
        declare collist cursor local fast_forward for 
            select name from syscolumns where id = @view_id order by colid asc
                for read only
        open collist
        fetch collist into @colname
        while (@@fetch_status <> -1)
        begin
            --since a view does not preserve computed/timestamp property, we have to rely on the base table
            select @iscomputed=iscomputed, @xtype=xtype from syscolumns where id = @objid and name=@colname
            if @iscomputed=0 and type_name(@xtype) <> 'timestamp'
            begin
                select @colname = QUOTENAME(@colname) --previously we use rowguidcol to replace 'rowguid'
                                                      --which can cause problems and is not necessary.
                insert @proctext (line) values('
            , v.' + @colname) 
                if @@error <> 0 or @retcode <> 0 begin select @retcode = 1 goto Failure end 
            end
            fetch next from collist into @colname
        end                 
    end
    else
    begin
        insert into @proctext (line) values (
'             , v.*')
        if @@error <> 0 or @retcode <> 0 begin select @retcode = 1 goto Failure end 
    end

    insert into @proctext (line) values ('
            from ' +
                 QUOTENAME(@ownername) + '.' +
                    QUOTENAME(@viewname) + ' v left outer join  dbo.MSmerge_contents c on
                      v.' + @rgcol + ' = c.rowguid  and c.tablenick = @tablenick where v.' + @rgcol + ' > @guidlast 
                     order by v.' + @rgcol + '
        return (1)      
    end

    insert into #belong (tablenick, rowguid, flag, skipexpand, partchangegen, joinchangegen)
        select ct.tablenick, ct.rowguid, 0, 0, ct.partchangegen, ct.joinchangegen
                    from  #contents_subset ct, ' + QUOTENAME(@ownername) + '.' +
                    QUOTENAME(@viewname) + ' v where ct.tablenick = @tablenick
                    and ct.rowguid = v.' + @rgcol + '  
    if @@ERROR <> 0
        begin
        RAISERROR(''Error selecting from view'' , 16, -1)
        return (1)  
        end')
            
    select line from @proctext order by line_no asc
Failure:
    return @retcode
end
go
exec dbo.sp_MS_marksystemobject sp_MSscriptviewproc
grant execute on sp_MSscriptviewproc to public
go

if exists (select * from sysobjects
	where type = 'P '
			and name = 'sp_MSmakeviewproc')
	drop procedure sp_MSmakeviewproc
go

create procedure sp_MSmakeviewproc (
    @viewname sysname,
    @ownername sysname,
    @procname nvarchar(290),
    @rgcol sysname,
    @objid int = NULL --for possible backward comp. issue
    )
as
begin
    declare @retcode        smallint
    declare @command        nvarchar(4000)
    declare @db_name        sysname
    set nocount on

    select @retcode = 0
    select @db_name = db_name()
    if @@error <> 0 or @retcode <> 0 begin select @retcode = 1 goto Failure end 

    select @command = N'exec dbo.sp_MSscriptviewproc 
        @viewname = ' + fn_replmakestringliteral(@viewname) collate database_default + '
        ,@ownername = ' + fn_replmakestringliteral(@ownername) collate database_default + '
        ,@procname = ' + fn_replmakestringliteral(@procname) collate database_default + '
        ,@rgcol = ' + fn_replmakestringliteral(@rgcol) collate database_default + '
        ,@objid = ' + isnull(convert(nvarchar(20), @objid), N'null') 
    if @@error <> 0 or @retcode <> 0 begin select @retcode = 1 goto Failure end 

    exec @retcode = master.dbo.xp_execresultset @command, @db_name
    if @@error <> 0 or @retcode <> 0 begin select @retcode = 1 goto Failure end 

    select @procname=QUOTENAME(@procname)
    exec dbo.sp_MS_marksystemobject @procname
    if @@error <> 0 or @retcode <> 0 begin select @retcode = 1 goto Failure end 
    exec ('grant exec on ' + @procname + ' to public')
    if @@error <> 0 or @retcode <> 0 begin select @retcode = 1 goto Failure end 

Failure:
    return @retcode
end
go
exec dbo.sp_MS_marksystemobject sp_MSmakeviewproc    

if exists (select * from sysobjects
        where type = 'P'
            and name = 'sp_MSmakeselectproc')
    drop procedure sp_MSmakeselectproc
go
SET ANSI_NULLS ON 
SET QUOTED_IDENTIFIER ON
GO
create procedure sp_MSmakeselectproc 
    (@tablename sysname, @ownername sysname, @procname sysname, @pubid uniqueidentifier)
as
declare @retcode            smallint
declare @argname            nvarchar(10)
declare @varname            nvarchar(10)
declare @columns            varbinary(128)
declare @cmdpiece           nvarchar(4000)
declare @qualified_name     nvarchar(270)
declare @column_list        table (line_no int identity(1,1) primary key, line nvarchar(4000))
declare @littlecomp nvarchar(300)
declare @colid              int
declare @col_name           nvarchar(140)
declare @id                 int
declare @idstr              nvarchar(100)
declare @sync_objid         int
set nocount on

if @ownername is NULL or @ownername=''
    select @qualified_name = QUOTENAME(@tablename)
else    
    select @qualified_name = QUOTENAME(@ownername) + '.' + QUOTENAME(@tablename)

select @id = object_id(@qualified_name)

select @sync_objid=sync_objid from sysmergearticles where objid = @id and pubid=@pubid

set @idstr = rtrim(convert(nchar, @id)) 

/*
** Include computed columns.
*/
IF EXISTS (select name from syscolumns where id = @id and (name not in 
    (select name from syscolumns where id = @sync_objid)))
    OR exists (select name from syscolumns where id=@id and iscomputed=1)
    OR ObjectProperty(@id, 'TableHasTimestamp') = 1 
BEGIN
    DECLARE column_cursor CURSOR LOCAL FAST_FORWARD FOR
        select name from syscolumns where id=@id 
                and iscomputed<>1 
                and type_name(xtype) <>'timestamp' 
                and name in (select name from syscolumns where id=@sync_objid)
    FOR READ ONLY
    open column_cursor
    fetch next from column_cursor into @col_name
    WHILE (@@fetch_status <> -1)
    BEGIN
            if ColumnProperty(@id, @col_name, 'isrowguidcol') = 1
                select @col_name='rowguidcol'
            else
                set @col_name = QUOTENAME(@col_name)
            if (select count(*) from @column_list) = 0
                insert into @column_list(line) values (@col_name + '
')
            else
                insert into @column_list(line) values (', ' + @col_name + '
')
            fetch next from column_cursor into @col_name            
    END
    close column_cursor
    deallocate column_cursor

    if (select count(*) from @column_list) = 0
    begin
        RAISERROR(21125, 16, -1)
        return (1)
    end
END
else 
    insert into @column_list(line) values('t.*')

/*
** Check for dbo permission
*/
    exec @retcode=sp_MSreplcheck_subscribe
    if @retcode<>0 or @@ERROR<>0 return (1)

set @cmdpiece= 'SET ANSI_NULLS ON SET QUOTED_IDENTIFIER ON'
exec (@cmdpiece)
if @@error<>0 return(1)

-- create temp table to select the command text out of
create table #tempcmd (step int identity NOT NULL, cmdtext nvarchar(4000) collate database_default null)

select @cmdpiece = '
Create procedure dbo.'  + QUOTENAME(@procname) + ' (@type int output, @rowguid uniqueidentifier=NULL) AS
    declare @retcode    int
        
    set nocount on
        
    if sessionproperty(''replication_agent'') = 0
    begin       
        exec @retcode = dbo.sp_MSreplcheck_connection @objid= ' + @idstr + '
        if @@ERROR<>0 or @retcode<>0 
            return (1)
    end
        
    if @type = 1
    begin
        select ' 
insert into #tempcmd (cmdtext) values (@cmdpiece)
insert into #tempcmd (cmdtext) select line from @column_list where line_no = 1
insert into #tempcmd (cmdtext) select 
'               ' + line from @column_list where line_no > 1 order by line_no asc
select @cmdpiece='              from ' + @qualified_name + ' t where rowguidcol = @rowguid
        if @@ERROR<>0 return(1)
    end
            
    else if @type < 4
    begin
        select c.tablenick, c.rowguid, c.generation, c.lineage, c.colv1
               ,' 
insert into #tempcmd (cmdtext) values (@cmdpiece)
insert into #tempcmd (cmdtext) select line from @column_list where line_no = 1
insert into #tempcmd (cmdtext) select 
'              ' + line from @column_list where line_no > 1 order by line_no asc
select @cmdpiece='          from ' +
                 @qualified_name + ' t,  #cont c where
               t.rowguidcol = c.rowguid
         order by t.rowguidcol 
        if @@ERROR<>0 return(1)
    end

    else if @type = 4
    begin
        set @type = 0
        if exists (select * from ' + @qualified_name + ' where rowguidcol = @rowguid)
            set @type = 3
        if @@ERROR<>0 return(1)
    end

    else if @type = 5
    begin
        delete ' + @qualified_name + ' where rowguidcol = @rowguid
        if @@ERROR<>0 return(1)
    end

    else if @type = 6 -- sp_MSenumcolumns
    begin
        select ' 
insert into #tempcmd (cmdtext) values (@cmdpiece)
insert into #tempcmd (cmdtext) select line from @column_list where line_no = 1
insert into #tempcmd (cmdtext) select 
'               ' + line from @column_list where line_no > 1 order by line_no asc
select @cmdpiece='              from ' + @qualified_name + ' t where 1=2
        if @@ERROR<>0 return(1)
    end

    else if @type = 7 -- sp_MSlocktable
    begin
        select 1 from ' + @qualified_name + '(tablock holdlock) where 1 = 2
        if @@ERROR<>0 return(1)
    end

    else if @type = 8 -- put update lock
    begin
        if not exists (select * from ' + @qualified_name + '(UPDLOCK HOLDLOCK) where rowguidcol = @rowguid)
        begin
            RAISERROR(20031 , 16, -1)
            return(1)
        end
    end
        
    return(0)'

insert into #tempcmd (cmdtext) values (@cmdpiece)
select cmdtext from #tempcmd order by step
drop table #tempcmd
go
            
exec dbo.sp_MS_marksystemobject sp_MSmakeselectproc 
go
grant exec on dbo.sp_MSmakeselectproc to public
go

SET ANSI_NULLS OFF
go

if exists (select * from sysobjects
	where type = 'P'
		and name = 'sp_MSproxiedmetadata')
	drop procedure sp_MSproxiedmetadata
go

create procedure sp_MSproxiedmetadata
	@tablenick	int,
	@rowguid	uniqueidentifier,
	@lineage	varbinary(256),
	@colv		varbinary(2048)
as
	declare @old_lin varbinary(256)
	declare @old_colv varbinary(2048)
	declare @retcode int

Loop:
	set @old_lin= NULL
	select @old_lin = lineage, @old_colv = colv1 from dbo.MSmerge_contents where
		tablenick = @tablenick and rowguid = @rowguid

	if (@old_lin IS NOT NULL)
	begin
		exec @retcode= master..xp_proxiedmetadata @lineage out, @colv out, @old_lin, @old_colv
		if @@error<>0 or @retcode<>0
		begin
			return(1)
		end
		update dbo.MSmerge_contents set lineage = @lineage, colv1 = @colv
			where tablenick = @tablenick and rowguid = @rowguid and lineage = @old_lin
		if @@rowcount = 0 goto Loop
	end
	else
	begin
		select @old_lin = lineage from dbo.MSmerge_tombstone where
			tablenick = @tablenick and rowguid = @rowguid
		if (@old_lin IS NULL)
			return (0)

		exec @retcode= master..xp_proxiedmetadata @lineage out, @colv out, @old_lin, NULL
		if @@error<>0 or @retcode<>0
		begin
			return(1)
		end
		update dbo.MSmerge_tombstone set lineage = @lineage
			where tablenick = @tablenick and rowguid = @rowguid and lineage = @old_lin
		if @@rowcount = 0 goto Loop
	end

	return (0)
GO
exec dbo.sp_MS_marksystemobject sp_MSproxiedmetadata
grant exec on dbo.sp_MSproxiedmetadata to public
go

if exists (select * from sysobjects
	where type = 'P '
			and name = 'sp_MSmakegeneration')
	drop procedure sp_MSmakegeneration
go
raiserror('Creating procedure sp_MSmakegeneration', 0,1)
GO
create procedure sp_MSmakegeneration
	@gencheck int = 0
	as
	set nocount on

	declare @gen int
	declare @nick int
	declare @genguid uniqueidentifier
	declare @dt datetime
	declare @dt2 datetime
	declare @art_nick int
	declare @first_ts int
	declare @makenewrow bit
	declare @retcode smallint
	declare @guidnull uniqueidentifier
	declare @nickbin varbinary(255)
	declare @maxgendiff_fornewrow int
	declare @count_of_articles int
	declare @lock_acquired bit
   	declare @lock_resource nvarchar(255)
	declare @procfailed bit
	declare @delete_old_genhistory bit
	declare @close_old_genhistory bit
	declare @localize_zeroartnick_generations bit
		
	select @procfailed = 1
   	select @retcode = 0

	set @guidnull = '00000000-0000-0000-0000-000000000000'
		
	/*
	** Check to see if current publication has permission
	*/
	exec @retcode=sp_MSreplcheck_connection
	if @retcode<>0 or @@ERROR<>0 goto EXIT_PROC
	
	set @genguid = newid()
	exec @retcode=sp_MSgetreplnick @nickname = @nick out
	if @retcode<>0 or @@error<>0 goto EXIT_PROC

	-- convert @nick into binary and add a guard byte if needed
	if @nick % 256 = 0
		set @nickbin = convert(binary(4), @nick) + 0x01
	else
		set @nickbin = convert(binary(4), @nick)

	select @dt2 = max(coldate) from dbo.MSmerge_genhistory where guidsrc = guidlocal
	set @dt = getdate()

	if datediff(dd, @dt2, @dt) = 0
	begin
		if 500 > datediff(ms, @dt2, @dt) and 0 < datediff(ms, @dt2, @dt)
		begin
			select @procfailed = 0
			goto EXIT_PROC
		end
	end

	if @gencheck = 3
		set @localize_zeroartnick_generations = 1
	else
		set @localize_zeroartnick_generations = 0

	-- localize interrupted generations
	exec @retcode= sp_MSlocalizeinterruptedgenerations @localize_zeroartnick_generations = @localize_zeroartnick_generations
	if @retcode<>0 or @@error<>0 goto EXIT_PROC

	-- If @gencheck param is set to 1 ( = ForceConvergence), look for rows with missing generation numbers and set their
	-- gen to 0
	if @gencheck = 1 or @gencheck = 2
	begin
		update dbo.MSmerge_contents set generation = 0 where generation not in
			(select generation from dbo.MSmerge_genhistory)
		update dbo.MSmerge_tombstone set generation = 0 where generation not in
			(select generation from dbo.MSmerge_genhistory)
	end
	/*
	** If there are no zero generation tombstones or rows, add a dummy row in there. 
	*/
   	if not exists (select * from dbo.MSmerge_genhistory)
	begin
	   	insert into dbo.MSmerge_genhistory (guidsrc, guidlocal, generation, art_nick, nicknames, coldate) values
			(@genguid, @genguid, 1, 0, @nickbin, @dt)
		if (@@error <> 0) goto EXIT_PROC
	end

	select @art_nick = min(nickname), @count_of_articles = count(*) from sysmergearticles

	-- Calculate how much less than the max generation in MSmerge_genhistory are we willing to have the minimum open generation in MSmerge_genhistory.
	-- Having a number smaller than or roughly equal to the number of articles will cause more aggressive closing of existing open gens (and making new rows) with 0 changes
	-- and hence more generations for merge agents to deal with. Having a very high number will cause less aggressive closing of open gens but will cause the
	-- common gens of replicas to be stuck at lower numbers because of the existence of "holes" at much lower gen values. An optimization that works well
	-- and is a compromise between the two extremes is to have the max of 100 or (2 * @count_of_articles) + 1 as the max diff we allow before deciding to make a new row.
	if ((2 * @count_of_articles) + 1) > 100
		select @maxgendiff_fornewrow = (2 * @count_of_articles) + 1
	else
		select @maxgendiff_fornewrow = 100

	while @art_nick is not null
	begin
		declare @cmd nvarchar(200)
		declare @old_bi_gen int
		declare @bi_objid int

		set @old_bi_gen= NULL -- if @old_bi_gen stays NULL: no need to move bi-rows
		set @bi_objid= NULL
		set @delete_old_genhistory = 0
		set @close_old_genhistory = 0
		set @makenewrow = 0
		
		set @bi_objid= (select top 1 before_image_objid from sysmergearticles where nickname = @art_nick)
		if @bi_objid is not null
		begin
			set @cmd= 'update dbo.' + object_name(@bi_objid) + ' set generation= @gen where generation = @oldgen'
		end
		
		begin tran
		save tran sp_MSmakegeneration
		select @gen = max(gen_cur) from sysmergearticles (updlock holdlock) where nickname = @art_nick and gen_cur is not null

		-- if either we have no gen_cur set yet, or if we have one but no corresponding genhistory row or we have a closed one which
		-- was bcp-ed in after a reinit, we need to create a new one.
		if @gen is null or 
			(	@gen is not null 
				and not exists (select generation from dbo.MSmerge_genhistory where generation = @gen and guidlocal = @guidnull)
			)
		begin
			declare @oldgen int
			declare @maxgencur int

			set @genguid = newid()
			set @oldgen = @gen

			select @gen = COALESCE(1 + max(generation), 1) from dbo.MSmerge_genhistory (updlock)
			
			-- Make sure that the new generation value is not smaller than any existing sysmergearticles.gen_cur.
			select @maxgencur = isnull(max(gen_cur),0) from sysmergearticles where gen_cur is not null

			if (@gen <= @maxgencur)
			begin
				set @gen = @maxgencur + 1
				-- Now we are guaranteed to not collide with an existing gen_cur
			end
			
			insert into dbo.MSmerge_genhistory (guidsrc, guidlocal, generation, art_nick, nicknames, coldate) 
				values(@genguid, @guidnull, @gen, @art_nick, @nickbin, @dt)
			if (@@error <> 0)
			begin
				goto EXIT_RELEASE_TRAN
			end	
			
			update sysmergearticles set gen_cur = @gen where nickname = @art_nick
			if (@@error <> 0)
			begin
				goto EXIT_RELEASE_TRAN
			end	

			-- if this was the case of a gen_cur with no matching genhistory rows, then update the contents and tombstones rows with the new generation value.
			if @oldgen is not null
			begin
				update dbo.MSmerge_contents set generation = @gen, partchangegen = @gen, joinchangegen = @gen
			 		where generation = @oldgen and partchangegen = @oldgen and tablenick = @art_nick
				if (@@error <> 0)
				begin
					goto EXIT_RELEASE_TRAN
				end	
				update dbo.MSmerge_contents set generation = @gen, joinchangegen = @gen
				 	where generation = @oldgen and joinchangegen = @oldgen and tablenick = @art_nick
				if (@@error <> 0)
				begin
					goto EXIT_RELEASE_TRAN
				end	
				update dbo.MSmerge_contents set generation = @gen where generation = @oldgen and tablenick = @art_nick
				if (@@error <> 0)
				begin
					goto EXIT_RELEASE_TRAN
				end
				update dbo.MSmerge_tombstone set generation = @gen where generation = @oldgen and tablenick = @art_nick
				if (@@error <> 0)
				begin
					goto EXIT_RELEASE_TRAN
				end

				if @bi_objid is not null
				begin
					exec dbo.sp_executesql @cmd, N'@gen int, @oldgen int', @gen= @gen, @oldgen= @oldgen
					if @@ERROR <> 0 goto EXIT_RELEASE_TRAN
				end
			end
		end
			
		-- these updates should be hitting zero rows...
		if exists (select * from dbo.MSmerge_contents (readpast readcommitted) where generation = 0 and tablenick = @art_nick)
		begin
			update dbo.MSmerge_contents set generation = @gen, partchangegen = @gen, joinchangegen = @gen
			 	where generation = 0 and partchangegen = 0 and tablenick = @art_nick
			if (@@error <> 0)
			begin
				goto EXIT_RELEASE_TRAN
			end	
			update dbo.MSmerge_contents set generation = @gen, joinchangegen = @gen
			 	where generation = 0 and joinchangegen = 0 and tablenick = @art_nick
			if (@@error <> 0)
			begin
				goto EXIT_RELEASE_TRAN
			end	
			update dbo.MSmerge_contents set generation = @gen where generation = 0 and tablenick = @art_nick
			if (@@error <> 0)
			begin
				goto EXIT_RELEASE_TRAN
			end
		end
			
		if exists (select * from dbo.MSmerge_tombstone (readpast readcommitted) where generation = 0 and tablenick = @art_nick)
		begin
			update dbo.MSmerge_tombstone set generation = @gen where generation = 0 and tablenick = @art_nick
			if (@@error <> 0)
			begin
				goto EXIT_RELEASE_TRAN
			end
		end
		if not exists (select * from dbo.MSmerge_contents where tablenick = @art_nick and
						generation = @gen) and
		   not exists (select * from dbo.MSmerge_tombstone where tablenick = @art_nick and
						generation = @gen)
		begin

			select @dt2 = coldate from dbo.MSmerge_genhistory where generation = @gen
			if datediff(dd, @dt2, @dt) = 0 and not exists (select * from dbo.MSmerge_genhistory
					where generation > @maxgendiff_fornewrow + @gen)
			begin
				set @makenewrow = 0
				set @delete_old_genhistory = 0
				
				-- If @gencheck param is set to 3 (= OverrideMakeNewGenerations), set the @makenewrow flag
				-- This is done for message based merges to ensure that the incomplete gens always get closed
				-- during every merge if there are completed generations > than this one.
				-- Besides closed generations > this one, we also need to watch out for open generations > this one
				-- that have pending changes, and hence sp_MSmakegeneration will eventually close them out. This is
				-- required when the @gen just happens to be processed before other open generations with changes.
				if @gencheck = 3 
				begin
					if exists (select * from dbo.MSmerge_genhistory gh 
								where gh.generation > @gen 
								and gh.guidlocal <> @guidnull)
						or exists (select * from dbo.MSmerge_contents mc where mc.generation > @gen)
						or exists (select * from dbo.MSmerge_tombstone mt where mt.generation > @gen)
					begin
						set @makenewrow = 1
						set @old_bi_gen= @gen -- we will move bi-rows
						set @delete_old_genhistory = 1
					end
				end				
			end
			else
			begin
				set @makenewrow = 1
				set @old_bi_gen= @gen -- we will move bi-rows
				set @delete_old_genhistory = 1
			end
		end
		else
		begin
			set @makenewrow = 1
			set @delete_old_genhistory = 0	-- don't delete existing genhistory row. just mark it as closed.
			set @close_old_genhistory = 1
		end

		if (@makenewrow = 1)
		begin
			declare @newgen int

			/* reset next generation for this article */
			set @genguid = newid()
			insert into dbo.MSmerge_genhistory (guidsrc, guidlocal, generation, art_nick, nicknames, coldate) 
				select @genguid, @guidnull, COALESCE(1 + max(generation), 1), @art_nick, @nickbin, @dt from dbo.MSmerge_genhistory (updlock)
			if (@@error <> 0)
			begin
				goto EXIT_RELEASE_TRAN
			end	
			select @newgen  =  generation  from dbo.MSmerge_genhistory where guidsrc = @genguid
			update sysmergearticles set gen_cur = @newgen where nickname = @art_nick
			if (@@error <> 0)
			begin
				goto EXIT_RELEASE_TRAN
			end	

			if @bi_objid is not null and @old_bi_gen is not NULL
			begin
				exec dbo.sp_executesql @cmd, N'@gen int, @oldgen int', @gen = @newgen, @oldgen = @old_bi_gen
				if @@ERROR <> 0 goto EXIT_RELEASE_TRAN
			end
		end

		if (@delete_old_genhistory = 1)
		begin
			declare @error int
			declare @genhistory_rowsdeleted int

			-- delete the old genhistory row only if there still aren't any rows in contents or 
			-- tombstone with this generation value. Note that after the previous update statement on sysmergearticles
			-- no new spids can take locks on sysmergearticles and hence cannot 
			-- insert any new rows with the old gen_cur.
			delete from dbo.MSmerge_genhistory 
			where generation = @gen
			and not exists (select * from dbo.MSmerge_contents where tablenick = @art_nick and generation = @gen) 
			and not exists (select * from dbo.MSmerge_tombstone where tablenick = @art_nick and generation = @gen)

			select @genhistory_rowsdeleted = @@rowcount, @error = @@error

			-- If the genhistory row which we previously thought could be deleted, now has changes in contents or 
			-- tombstone, it's okay to not delete it and still leave it as open. In future this open generation
			-- will be treated as an interrupted generation and the changes in it will be moved to a new local 
			-- generation. So there will be convergence. Deleting the genhistory row based on incorrect past determination
			-- of 0 changes is dangerous and can easily cause non-convergence.
			-- The best solution is to close this generation if we finally didn't delete it. The reason is that it
			-- allows subscribers to move their last received watermark higher than this open generation.
			if @genhistory_rowsdeleted = 0
			begin
				set @close_old_genhistory = 1
			end

			if (@error <> 0)
			begin
				goto EXIT_RELEASE_TRAN
			end	
		end

		if (@close_old_genhistory = 1)
		begin
			set @genguid = newid()
			update dbo.MSmerge_genhistory set guidsrc = @genguid, guidlocal = @genguid, coldate = @dt
				where generation = @gen
			if (@@error <> 0)
			begin
				goto EXIT_RELEASE_TRAN
			end	
			update MSmerge_replinfo set recgen = @gen, recguid = @genguid, 
				sentgen = @gen, sentguid = @genguid where replnickname = @nick
			if (@@error <> 0)
			begin
				goto EXIT_RELEASE_TRAN
			end	
		end

		commit transaction		

		-- set up for next time through the loop
		select @art_nick = min(nickname) from sysmergearticles where nickname > @art_nick
		
		set @dt = getdate()
	end

	select @procfailed = 0
		
EXIT_RELEASE_TRAN:

	if (@procfailed = 1)
	begin
		rollback tran sp_MSmakegeneration
		commit transaction
	end

EXIT_PROC:

	if (@procfailed = 1)
		return (1)	
	else
		return (0)
go

exec dbo.sp_MS_marksystemobject sp_MSmakegeneration 
go
grant exec on dbo.sp_MSmakegeneration to public
go
if exists (select * from sysobjects
	where type = 'P '
			and name = 'sp_MSsetupnotbelongs')
	drop procedure sp_MSsetupnotbelongs
go
raiserror('Creating procedure sp_MSsetupnotbelongs', 0,1)
go
create procedure sp_MSsetupnotbelongs
@artnick			int,
@before_view_objid	int,
@before_table_objid int,
@rgcol				sysname,
@commongen			int
AS
	declare @before_view_name sysname
	declare @before_table_name sysname
	declare @artnickstr nvarchar(10)
	declare @commongenstr nvarchar(12)
	
	set @artnickstr = convert(nvarchar(10), @artnick)
	set @commongenstr = convert(nvarchar(12), @commongen)
	
	/* Put changes in #notbelong  that aren't in #belong and have a relevant partchangegen	*/
	-- If publication has before image tables, we should screen changes using the before image tables
	--rowguid in (select ' + @rgcol + ' from ' + @before_view_name + ') and
	if @before_view_objid is not null
	begin
		set @before_view_name = OBJECT_NAME(@before_view_objid)
		set @before_table_name = OBJECT_NAME(@before_table_objid)
		execute ('insert into #notbelong (tablenick, rowguid, flag, partchangegen, joinchangegen)
				select tablenick, rowguid, 0, partchangegen, joinchangegen
				from #contents_subset
				where partchangegen > ' + @commongenstr + ' 
				and tablenick = ' + @artnickstr + ' 
				and	(rowguid in (select ' + @rgcol + ' from ' + @before_view_name + ' where generation > ' + @commongenstr + ')
				or (rowguid in (select ' + @rgcol + '  from ' + @before_table_name + ' where system_delete = 1 and generation > ' + @commongenstr + ')
				and (rowguid not in (select ' + @rgcol + ' from ' + @before_view_name + ' where generation > ' + @commongenstr + '))))	
				and rowguid not in (select rowguid from #belong) ')
		if @@ERROR <>0 
		begin
			return (1)
		end
			
		if exists (select * from #genlist)
		begin
			/* Add tombstones to ##notbelong */
			execute ('insert into #notbelong (tablenick, rowguid, flag, partchangegen, joinchangegen, type) 
				select tablenick, rowguid,  0, generation, generation, type from
				#tombstone_subset where tablenick = ' + @artnickstr + ' and
				(type = 6 or rowguid in (select ' + @rgcol + ' from ' + @before_view_name + ' where generation > ' + @commongenstr + '))')
			if @@ERROR <>0
			begin
				return (1)
			end
		end
	end
	else
	begin 
		insert into #notbelong (tablenick, rowguid, flag, partchangegen, joinchangegen)
			select tablenick, rowguid, 0, partchangegen, joinchangegen
				from #contents_subset
				where partchangegen > @commongen 
				and tablenick = @artnick 
				and rowguid not in (select rowguid from #belong)

		if @@ERROR <>0
		begin
			return (1)
		end

		if exists (select * from #genlist)
		begin
			insert into #notbelong (tablenick, rowguid, flag, partchangegen, joinchangegen, type) 
				select tablenick, rowguid,  0, generation, generation, type from
				#tombstone_subset where tablenick = @artnick

			if @@ERROR <>0
			begin
				return (1)
			end
		end
	end

	return (0)
GO
exec dbo.sp_MS_marksystemobject sp_MSsetupnotbelongs
go
grant exec on dbo.sp_MSsetupnotbelongs to public
go
if exists (select * from sysobjects
	where type = 'P '
			and name = 'sp_vupgrade_mergetables')
	drop procedure sp_vupgrade_mergetables
go
raiserror('Creating procedure sp_vupgrade_mergetables', 0,1)
GO
create procedure sp_vupgrade_mergetables( @skip_procgen bit = 0 )
as
begin
/* 
 * Process schema and metadata changes common to transactional pub/sub databases.
 *
 * @skip_procgen is set by sp_restoredbreplication when calling this proc directly to update
 * system tables during restore of a down-level (e.g. - SQL7.0) database to current version
 * 
 * Setup version upgrade procedure call order:
 *	sp_vupgrade_replication -> sp_vupgrade_subscription_databases -> sp_vupgrade_mergetables
*/

	set nocount on 

	declare @artnick int
	declare @objid  int
	declare @col_track int
	declare @article sysname
	declare @pubname sysname
	declare @artid uniqueidentifier
	declare @pubid uniqueidentifier
    declare @qualified_name         nvarchar(257)
    declare @source_owner           sysname
    declare @source_object			sysname
	declare @table_name				sysname
	declare @retcode				integer
	declare @snapshot_ready			int
	declare @cmd 					nvarchar(4000)

	-- raiserror('sp_vupgrade_mergetables', 0,1)

	/*
	 * sysmergearticles
	*/
	if (exists (select * from sysobjects where name = 'sysmergearticles'))
	begin

        -- Set all invalid sysmergearticles.sync_objid to the corresponding 
        -- objid, this will allow regeneration of article procs to succeed
        update dbo.sysmergearticles 
           set sync_objid = objid 
         where object_name(sync_objid) is null

        if @@ERROR<>0
            return(1)

		exec @retcode = dbo.sp_MSUpgradeConflictTable @skip_procgen
		if @@ERROR<>0 or @retcode<>0
			return (1)		
		if not exists (select * from syscolumns where id = object_id('sysmergearticles') and
						name = 'maxversion_at_cleanup')
		begin
			alter table sysmergearticles add maxversion_at_cleanup int NOT NULL default 1
			if @@ERROR <> 0 return 1
		end

	    if not exists (select * from sysobjects where name = 'sysmergeschemaarticles')
	        begin	            
	            create table dbo.sysmergeschemaarticles 
	            (   name                    sysname             NOT NULL,
	                type                    tinyint             NULL,
	                objid                   int                 NOT NULL,
	                artid                   uniqueidentifier    NOT NULL,
	                description             nvarchar(255)       NULL,
	                pre_creation_command    tinyint             NULL,
	                pubid                   uniqueidentifier    NOT NULL,
	                status                  tinyint             NULL,
	                creation_script         nvarchar(255)       NULL,
	                schema_option           binary(8)           NULL,
	                destination_object      sysname             NOT NULL,
	                destination_owner       sysname             NULL
	                -- Note: Please update sysmergeextendedarticlesview whenever
	                -- there is a schema change in sysmergeschemaarticles
	            )
	            
	            exec dbo.sp_MS_marksystemobject sysmergeschemaarticles
				create unique clustered index uc1sysmergeschemaarticles on sysmergeschemaarticles(artid, pubid)


	        end

		if not exists (select * from sysobjects where name = 'MSmerge_errorlineage')
			begin		
				create table dbo.MSmerge_errorlineage (
				tablenick		int NOT NULL,
				rowguid			uniqueidentifier NOT NULL,
				lineage			varbinary(255)
				)
				exec dbo.sp_MS_marksystemobject MSmerge_errorlineage
				create unique clustered index uc1errorlineage on MSmerge_errorlineage(tablenick, rowguid)
				
				grant select on MSmerge_errorlineage to public
			end

	    if not exists (select * from sysobjects where name = 'MSmerge_altsyncpartners')
	        begin	        
	            create table dbo.MSmerge_altsyncpartners (
	                subid 				uniqueidentifier 	not null,
	                alternate_subid 	uniqueidentifier 	not null,
	                description			nvarchar(255)		NULL

	            )

	            exec dbo.sp_MS_marksystemobject MSmerge_altsyncpartners

	            create unique clustered index uciMSmerge_altsyncpartners on 
	                dbo.MSmerge_altsyncpartners(subid, alternate_subid)
	            
	        end


		-- create view now that sysmergearticles is altered and sysmergeextendedarticles is created
		if exists (select * from sysobjects where name='sysmergeextendedarticlesview')
		begin
            drop view dbo.sysmergeextendedarticlesview
		end    

		-- cannot create view directly in proc
		exec ('create view dbo.sysmergeextendedarticlesview
		    	   as
               select name, type, objid, sync_objid, view_type, artid, description, pre_creation_command, pubid,
			   nickname, column_tracking, status, conflict_table, creation_script, conflict_script, article_resolver,
			   ins_conflict_proc, insert_proc, update_proc, select_proc, schema_option, destination_object,
			   resolver_clsid, subset_filterclause, missing_col_count, missing_cols, columns, resolver_info,
			   view_sel_proc, gen_cur, excluded_cols, excluded_col_count, vertical_partition, identity_support,
			   destination_owner, before_image_objid, before_view_objid, verify_resolver_signature, 
			   allow_interactive_resolver, fast_multicol_updateproc, check_permissions, maxversion_at_cleanup				   
			   from sysmergearticles
	           union all
               select name, type, objid, NULL, NULL, artid, description, pre_creation_command, pubid, 
			   NULL, NULL, status, NULL, creation_script, NULL, NULL, 
			   NULL, NULL, NULL, NULL, schema_option, destination_object, 
			   NULL, NULL, NULL, NULL, NULL, NULL, 
			   NULL, NULL, NULL, NULL, NULL, NULL, 
			   destination_owner, NULL, NULL, NULL, 
			   0, 0, 0, NULL 
			   from sysmergeschemaarticles
			   go')

	    exec dbo.sp_MS_marksystemobject sysmergeextendedarticlesview

		-- Do not regenerate views, procs if this is called from sp_restoredbreplication. Restore only
		-- needs to update schema, then it can call existing system procs to remove db replication cleanly
		if @skip_procgen = 0
		begin
			select @artnick = min(a.nickname) from sysmergearticles a inner join sysmergepublications p on p.pubid = a.pubid where p.snapshot_ready =1
			while @artnick is not null
			begin
				-- find base table to compute number of columns
				select @objid = objid, @col_track = column_tracking
					from sysmergearticles where nickname = @artnick

				-- regenerate the triggers
				select @source_owner = user_name(uid), @source_object = name from sysobjects where id = @objid
				select @qualified_name = QUOTENAME(@source_owner) + '.' + QUOTENAME(@source_object)
				exec dbo.sp_MSaddmergetriggers @qualified_name, NULL, @col_track

				/* Loop through all articles that this table is involved in and regenerate the article procs */
	            declare hcArtCursor CURSOR LOCAL FAST_FORWARD FOR select artid, pubid from sysmergearticles where nickname = @artnick order by artid, pubid
	            
    	        OPEN hcArtCursor
        	    FETCH hcArtCursor INTO @artid, @pubid
                WHILE (@@fetch_status <> -1)
                    BEGIN
                        select @pubname = name, @snapshot_ready = snapshot_ready from sysmergepublications where pubid = @pubid
                        -- regenerate procs, triggers, and views only for articles with snapshot ready
                        if @snapshot_ready>0
                            begin
                            	declare @rgcol nvarchar(270)
								declare @indname nvarchar(270)
								declare @quotedname nvarchar(270)
								declare @conflict_table sysname
								declare @conflict_table_id int
								declare @owner sysname
                                select @article = name, @conflict_table=conflict_table, @conflict_table_id=object_id(conflict_table)  
                                	from sysmergearticles where artid = @artid and pubid = @pubid

								--make sure conflict table has already got the indexes needed for performance enhancement
								--if not there we will add it up
 								if ( @conflict_table_id is not null) and not exists 
 									(select * from sysindexes where id = @conflict_table_id and keys is not null)
 								begin
							        select @owner=user_name(uid) from sysobjects where id= @conflict_table_id
									select @rgcol = QUOTENAME(name) from syscolumns 
										where id = @objid and ColumnProperty(id, name, 'isrowguidcol') = 1
							        select @indname = 'uc_' + @conflict_table
							        if len(@indname) > 128
        							begin
							            select @indname = substring(@indname,1,92) + convert(nvarchar(36), newid())
        							end
						        	set @indname = QUOTENAME(@indname)
						        	set @quotedname = QUOTENAME(@owner) + '.' + QUOTENAME(@conflict_table)
						        	exec ('Create unique clustered index ' + @indname + ' on ' + @quotedname +
        								' (' + @rgcol + ', origin_datasource)' )
	        						if @@error <> 0
    	    							return (1)
								end
                                
                                -- remake the articles procs
                                exec @retcode = dbo.sp_MSsetartprocs @publication = @pubname,   @article = @article, @force_flag = 1
                                if @@ERROR <>0 OR @retcode <>0 
                                    return (1)
                            END
                        FETCH hcArtCursor INTO @artid, @pubid
                    END                         
                CLOSE hcArtCursor
                DEALLOCATE hcArtCursor

				-- we no longer try to delete metadata rows that might have truncated colv1
				--  deleting can cause non-convergence problems where they previously didn't
				--  exist, so we will try to patch up any truncated colv1 values in the merge agent.
				
				-- find next article
				select @artnick = min(a.nickname) from sysmergearticles a inner join sysmergepublications p on p.pubid = a.pubid where p.snapshot_ready > 0 and a.nickname > @artnick
			end -- end colv metadata fixup, article proc and trigger re-gen

			-- Loop over publications and recreate the views, skipping publications where snapshot is not ready
			select @pubname = min(name) from sysmergepublications where UPPER(publisher)=UPPER(@@SERVERNAME) and publisher_db=db_name() and snapshot_ready > 0
			while @pubname is not null
			begin
				-- remake the publication views
				exec dbo.sp_MSpublicationview @pubname, 1
				select @pubname = min(name) from sysmergepublications where name > @pubname and UPPER(publisher)=UPPER(@@SERVERNAME) and publisher_db=db_name() and snapshot_ready > 0

			end
		end -- end @skip_procgen
	end -- end sysmergearticles modifications


	SELECT @table_name = N'MSmerge_tombstone'
	IF EXISTS ( SELECT * FROM sysobjects WHERE name = 'MSmerge_tombstone' )
	BEGIN
		IF EXISTS (SELECT * FROM sysindexes WHERE name = 'unc3MSmerge_tombstone' AND id = OBJECT_ID('MSmerge_tombstone'))
			drop index MSmerge_tombstone.unc3MSmerge_tombstone
		
	END

	SELECT @table_name = N'MSmerge_contents'
	IF EXISTS ( SELECT * FROM sysobjects WHERE name = 'MSmerge_contents' )
	BEGIN
		IF EXISTS (SELECT * FROM sysindexes WHERE name = 'nc2MSmerge_contents' AND id = OBJECT_ID('MSmerge_contents'))
			drop index MSmerge_contents.nc2MSmerge_contents

		IF EXISTS (SELECT * FROM sysindexes WHERE name = 'nc3MSmerge_contents' AND id = OBJECT_ID('MSmerge_contents'))
			drop index MSmerge_contents.nc3MSmerge_contents

		IF EXISTS (SELECT * FROM sysindexes WHERE name = 'nc4MSmerge_contents' AND id = OBJECT_ID('MSmerge_contents'))
			drop index MSmerge_contents.nc4MSmerge_contents

		IF EXISTS (SELECT * FROM sysindexes WHERE name = 'unc3SycContents' AND id = OBJECT_ID('MSmerge_contents'))
			drop index MSmerge_contents.unc3SycContents
		
		create index nc2MSmerge_contents on MSmerge_contents(generation)
		if @@ERROR <> 0 return 1

		create index nc3MSmerge_contents on MSmerge_contents(partchangegen)
		if @@ERROR <> 0 return 1

		create index nc4MSmerge_contents on MSmerge_contents(rowguid)
		if @@ERROR <> 0 return 1
	END

	if (exists (select * from sysobjects where name = 'sysmergearticles'))
	begin
		-- before image tables
		declare @binames table (biname sysname)
		insert into @binames select name from sysobjects 
								where xtype='U' 
								and name like 'MS_bi%'
								and id in (select before_image_objid from sysmergearticles)
		declare @biname sysname
		set @biname= (select top 1 biname from @binames)
		while @biname is not null
		begin
			set @cmd= 'drop index ' + @biname + '.' + @biname + '_gen'
			exec dbo.sp_executesql @cmd
			set @cmd= 'create clustered index ' + @biname + '_gen on ' + @biname + '(generation)'
			exec dbo.sp_executesql @cmd
			delete from @binames where biname=@biname
			set @biname= (select top 1 biname from @binames)
		end
	end

	-- remove orphaned rows in MSmerge_contents
	if (
			exists (select * from sysobjects where name = 'sysmergearticles') and
			exists (select * from sysobjects where name = 'sysmergepublications') and
			exists (select * from sysobjects where name = 'MSmerge_genhistory') and
			exists (select * from sysobjects where name = 'MSmerge_contents') and
			exists (select * from sysobjects where name = 'MSmerge_tombstone')
		)
	begin
		exec @retcode= sp_MSpurgecontentsorphans
		if @retcode<>0 or @@error<>0 return 1
	end
end
GO
exec sp_MS_marksystemobject 'sp_vupgrade_mergetables'
go
if exists (select * from sysobjects
	where type = 'P '
			and name = 'sp_addmergearticle')
	drop procedure sp_addmergearticle
go
raiserror('Creating procedure sp_addmergearticle', 0,1)
GO

create procedure sp_addmergearticle
    @publication            sysname,                            /* publication name */
    @article                sysname,                            /* article name */
    @source_object          sysname,                            /* source object name */
    @type                   sysname = 'table',                  /* article type */
    @description            nvarchar(255)= NULL,                /* article description */
    @column_tracking        nvarchar(10) = 'false',             /* column level tracking */
    @status                 nvarchar(10) = 'unsynced',          /* unsynced, active */
    @pre_creation_cmd       nvarchar(10) = 'drop',              /* 'none', 'drop', 'delete', 'truncate' */
    @creation_script        nvarchar(255)= NULL,                /* article schema script */
    @schema_option          varbinary(8)   = NULL,              /* article schema creation options */
    @subset_filterclause    nvarchar(1000) = '',                /* filter clause */
    @article_resolver       nvarchar(255)= NULL,                 /* custom resolver for article */
    @resolver_info          nvarchar(255) = NULL,                /* custom resolver info */
    @source_owner           sysname = NULL,
    @destination_owner		sysname = NULL,
    @vertical_partition		nvarchar(5) = 'FALSE',				/* vertical partitioning or not */
    @auto_identity_range	nvarchar(5)	= 'FALSE',				/* set it to false for now - change is possible */
    @pub_identity_range		bigint	= NULL,
    @identity_range			bigint = NULL,
    @threshold				int	= NULL,
	@verify_resolver_signature 		int = 0,					/* 0=do not verify signature, 1=verify that signature is from trusted source, more values may be added later */
    @destination_object     		sysname = @source_object,
	@allow_interactive_resolver		nvarchar(5) = 'false',		/* whether article allows interactive resolution or not */
	@fast_multicol_updateproc		nvarchar(5) = 'true',		/* whether update proc should update multiple columns in one update statement or not. if 0, then separate update issued for each column changed. */
	@check_permissions		int = 0, /* bitmap where 0x00 for nochecks, 0x01 for insert check, 0x2 for update check, 0x4 for delete check */
	@force_invalidate_snapshot bit = 0	/* Force invalidate existing snapshot */
    AS

    set nocount on

    /*
    ** Declarations.
    */
	declare @max_range				bigint
    declare @publisher				sysname
    declare @publisher_db			sysname
	declare @already_published		bit
    declare @identity_so_far		bigint
    declare @ver_partition			int
    declare @sp_resolver			sysname
    declare @num_columns            smallint
    declare @pubid                  uniqueidentifier                /* Publication id */
    declare @db                     sysname
	declare @identity_support		int
    declare @object                 sysname
    declare @owner                  sysname
    declare @retcode                int
    declare @objid                  int
    declare @sync_objid             int
    declare @typeid                 smallint
    declare @nickname               int
    declare @merge_pub_object_bit int
    declare @column_tracking_id     int
    declare @cmd                    nvarchar(255)
    declare @statusid               tinyint --1: inactive; 2: active; 5:new_inactive 6:new_active
    declare @next_seed				bigint
    declare @precmdid               int
    declare @resolver_clsid         nvarchar(50)
    declare @resolver_clsid_old     nvarchar(50)
    declare @tablenick              int
    declare @artid                  uniqueidentifier
	declare @i						int
	declare @max_identity			bigint
	declare @colname				sysname
	declare @indid					int
	declare @pkkey					sysname
    declare @distributor            sysname
    declare @distribdb              sysname
    declare @distproc               nvarchar(300)
    declare @dbname                 sysname
    declare @replinfo               int
    declare @db_name                sysname
    declare @subset                 int
    declare @is_publisher			int
    declare @row_size               int
    declare @sp_name				sysname
    declare @sp_owner				sysname
    declare @qualified_name         nvarchar(270)
    declare @snapshot_ready         tinyint
	declare @sync_mode				tinyint
	declare @allow_interactive_bit	bit
	declare @fast_multicol_updateproc_bit bit
    declare @additive_resolver		sysname
    declare @average_resolver		sysname
    declare @mindate_resolver		sysname
    declare @needs_pickup			bit
    declare @maxdate_resolver		sysname
    declare @minimum_resolver		sysname
    declare @maximum_resolver		sysname
    declare @mergetxt_resolver		sysname
    declare @pricolumn_resolver		sysname
	declare @xtype					int
	declare @xprec					int
	declare @initial_setting		bit
	declare @bump_to_80				bit
	declare @gen 					int
	declare @replnick 				int
	declare @genguid 				uniqueidentifier
	declare @guidnull 				uniqueidentifier
	declare @dt 					datetime
	
	/* make sure current database is enabled for merge replication */
    exec @retcode=dbo.sp_MSCheckmergereplication
    if @@ERROR<>0 or @retcode<>0
    	return (1)

    /*
    ** Initializations 
    */
	set @guidnull = '00000000-0000-0000-0000-000000000000'
    select @is_publisher = 0
    select @initial_setting = 0
    select @needs_pickup = 0
    select @bump_to_80 = 0
    select @already_published = 0
    select @publisher = @@SERVERNAME
    select @publisher_db = db_name()
    select @max_identity	= NULL
    select @next_seed		= NULL
    select @statusid        = 0
    select @resolver_clsid  = NULL
    select @subset          = 1     /* Const: publication type 'subset' */
    select @merge_pub_object_bit    = 128
	select @db_name	= db_name()
    select @sp_resolver 		= 'Microsoft SQLServer Stored Procedure Resolver'
    select @additive_resolver 	= 'Microsoft SQL Server Additive Conflict Resolver'
    select @average_resolver 	= 'Microsoft SQL Server Averaging Conflict Resolver'
    select @minimum_resolver 	= 'Microsoft SQL Server Minimum Conflict Resolver'
    select @maximum_resolver 	= 'Microsoft SQL Server Maximum Conflict Resolver'
    select @mindate_resolver 	= 'Microsoft SQL Server DATETIME (Earlier Wins) Conflict Resolver'
    select @maxdate_resolver 	= 'Microsoft SQL Server DATETIME (Later Wins) Conflict Resolver'
    select @mergetxt_resolver 	= 'Microsoft SQL Server Merge Text Columns Conflict Resolver'
    select @pricolumn_resolver 	= 'Microsoft SQL Server Priority Column Resolver'

    if @source_owner is NULL
        begin
            select @source_owner = user_name(uid) from sysobjects where id = object_id(@source_object)
            if @source_owner is NULL  
                begin
                    raiserror (14027, 11, -1, @source_object)
                    return (1)
                end
        end
    select @qualified_name = QUOTENAME(@source_owner) + '.' + QUOTENAME(@source_object)

	if @subset_filterclause <> '' and @subset_filterclause is not NULL
	begin
	/* check the validity of subset_filterclause */
	exec ('declare @test int select @test=1 from ' + @qualified_name + ' where (1=2) and ' + @subset_filterclause)
	if @@ERROR<>0
		begin
			raiserror(21256, 16, -1, @subset_filterclause, @article)
			return (1)
		end
	end
    if @destination_owner is NULL
    	select @destination_owner = 'dbo'
    
    /*
    ** Security Check
    */
    EXEC @retcode = dbo.sp_MSreplcheck_publish
    IF @@ERROR <> 0 or @retcode <> 0
        return (1)

    /*
    ** Pad out the specified schema option to the left
    */
    select @schema_option = fn_replprepadbinary8(@schema_option)

    /*
    ** Parameter Check: @publication.
    ** The @publication id cannot be NULL and must conform to the rules
    ** for identifiers.
    */   
        
    if @publication is NULL
        begin
            raiserror (14043, 16, -1, '@publication')
            return (1)
        end

    select @pubid = pubid, @snapshot_ready = snapshot_ready, @sync_mode=sync_mode from sysmergepublications 
        where name = @publication and UPPER(publisher)=UPPER(@publisher) and publisher_db=@publisher_db
    if @pubid is NULL
        begin
            raiserror (20026, 16, -1, @publication)
            return (1)
        end

	if lower(@article)='all'
		begin
			raiserror(21401, 16, -1)
			return (1)
		end

    /*
    ** Parameter Check: @type
    ** If the article is added as a 'indexed view schema only' article,
    ** make sure that the source object is a schema-bound view.
    ** Conversely, a schema-bound view cannot be published as a 
    ** 'view schema only' article.
    */
    select @type = lower(@type collate SQL_Latin1_General_CP1_CS_AS)

    if @type = N'indexed view schema only' and objectproperty(object_id(@qualified_name), 'IsSchemaBound') <> 1
    begin
        raiserror (21277, 11, -1, @qualified_name)        
        return (1)    
    end
    else if @type = N'view schema only' and objectproperty(object_id(@qualified_name), 'IsSchemaBound') = 1
    begin
        raiserror (21275, 11, -1, @qualified_name)
        return (1)
    end

    /*
    ** Only publisher can call sp_addmergearticle
    */
    EXEC @retcode = dbo.sp_MScheckatpublisher @pubid
    IF @@ERROR <> 0 or @retcode <>  0
        BEGIN
            RAISERROR (20073, 16, -1)
            RETURN (1)
        END
        
    /*
    ** Parameter Check: @article.
    ** Check to see that the @article is local, that it conforms
    ** to the rules for identifiers, and that it is a table, and not
    ** a view or another database object.
    */

    if @article is NULL
        begin
            raiserror (20045, 16, -1)
            return (1)
        end

	exec @retcode = dbo.sp_MSreplcheck_name @article
    if @@ERROR <> 0 or @retcode <> 0
        return(1)
        

    /*
    ** Set the precmdid.  The default type is 'drop'.
    **
    **      @precmdid   pre_creation_cmd
    **      =========   ================
    **            0     none
    **            1     drop
    **            2     delete
    **            3     truncate
    */
    IF LOWER(@pre_creation_cmd collate SQL_Latin1_General_CP1_CS_AS) NOT IN ('none', 'drop', 'delete', 'truncate')
       BEGIN
          RAISERROR (14061, 16, -1)
          RETURN (1)
       END

    /*
    ** Determine the integer value for the pre_creation_cmd.
    */
    IF LOWER(@pre_creation_cmd collate SQL_Latin1_General_CP1_CS_AS) = 'none'
       select @precmdid = 0
    ELSE IF LOWER(@pre_creation_cmd collate SQL_Latin1_General_CP1_CS_AS) = 'drop'
       select @precmdid = 1
    ELSE IF LOWER(@pre_creation_cmd collate SQL_Latin1_General_CP1_CS_AS) = 'delete'
       select @precmdid = 2
    ELSE IF LOWER(@pre_creation_cmd collate SQL_Latin1_General_CP1_CS_AS) = 'truncate'
       select @precmdid = 3


    /*
    ** Set the typeid.  The default type is table.  It can 
    ** be one of following.
    **
    **      @typeid     type
    **      =======     ========
    **         0xa      table
    **        0x20      proc schema only
    **        0x40      view schema only
    **        0x80      func schema only
    **        0x40      indexed view schema only (overloaded)
    */        

    IF LOWER(@type collate SQL_Latin1_General_CP1_CS_AS) NOT IN ('table', 'proc schema only', 'view schema only', 'func schema only', 'indexed view schema only')
       BEGIN
            RAISERROR (20074, 16, -1)
            RETURN (1)
       END

    IF LOWER(@type collate SQL_Latin1_General_CP1_CS_AS) = N'table'
    BEGIN
       SET @typeid = 0x0a
    END
    ELSE IF LOWER(@type collate SQL_Latin1_General_CP1_CS_AS) = N'proc schema only'
    BEGIN
       SET @typeid = 0x20 
    END
    ELSE IF LOWER(@type collate SQL_Latin1_General_CP1_CS_AS) = N'view schema only'
    BEGIN
       SET @typeid = 0x40
    END
    ELSE IF LOWER(@type collate SQL_Latin1_General_CP1_CS_AS) = N'indexed view schema only'
    BEGIN
       SET @typeid = 0x40
    END
    ELSE IF LOWER(@type collate SQL_Latin1_General_CP1_CS_AS) = N'func schema only'
    BEGIN
       SET @typeid = 0x80
    END

    select @sync_objid = OBJECT_ID(@qualified_name)
    if @sync_objid is NULL
        begin
            raiserror (14027, 11, -1, @qualified_name)
            return (1)
        end


    if @typeid in (0x20,0x40,0x80)
    begin
        if exists (select * from syscomments
                    where id = @sync_objid
                      and encrypted = 1)
        begin
            raiserror(21004, 16, -1, @source_object)
            return 1
        end
    end

    /*
    ** Parameter Check:  @article, @publication.
    ** Check if the article already exists in this publication.
    */

    IF EXISTS (SELECT *
                 FROM sysmergeextendedarticlesview
                WHERE pubid = @pubid
                  AND name = @article)
        BEGIN
			raiserror (21292, 16, -1, @source_object)
            RETURN (1)
        END
        
    /*
    ** At this point, all common parameter validations 
    ** for table and schema only articles have been 
    ** performed, so branch out here to handle schema
    ** only articles as a special case.
    */
    
    IF @typeid in (0x20, 0x40, 0x80)
    BEGIN
    
        IF @destination_object IS NULL OR @destination_object = N''
        BEGIN
            SELECT @destination_object = @source_object
        END
    
        IF @schema_option IS NULL
        BEGIN
            SELECT @schema_option = 0x0000000000000001
        END
        EXEC @retcode = dbo.sp_MSaddmergeschemaarticle 
            @pubid = @pubid,
            @article = @article,
            @source_object = @source_object,
            @type = @typeid,
            @description = @description,
            @status = @status,
            @pre_creation_command = @precmdid,
            @creation_script = @creation_script,
            @source_owner = @source_owner,
            @destination_owner = @destination_owner,
            @schema_option = @schema_option,
            @destination_object = @destination_object,
            @qualified_name = @qualified_name,   
            @publication = @publication,
            @snapshot_ready = @snapshot_ready,
            @force_invalidate_snapshot = @force_invalidate_snapshot
        
       RETURN (@retcode)
    END

    IF @schema_option IS NULL
    BEGIN
        SELECT @schema_option = 0x000000000000CFF1
    END

    /*
    ** If scheme option contains collation or extended properties, 
    ** bump up the compatibility-level
    */    
    -- Since only the lower 32 bits of @schema_option are 
    -- used, the following check is sufficient. Note that @schema_option is
    -- already padded out to the left at the beginning of this procedure.
    declare @schema_option_lodword int
    declare @xprop_schema_option int
    declare @collation_schema_option int
    select @xprop_schema_option = 0x00002000
    select @collation_schema_option = 0x00001000
    select @schema_option_lodword = fn_replgetbinary8lodword(@schema_option)
    if (@schema_option_lodword & @collation_schema_option) <> 0
    begin    
        raiserror(21389, 10, -1, @publication)
        select @bump_to_80 = 1
    end
    if (@schema_option_lodword & @xprop_schema_option) <> 0
    begin   
        raiserror(21390, 10, -1, @publication)
        select @bump_to_80 = 1
    end

    /*
    ** Merge table articles does not really support destination object. It has the same value as source
    */
    select @destination_object = @source_object

/*
    select @row_size=sum(length) from syscolumns where id=OBJECT_ID(@qualified_name)
    if @row_size>6000 
        begin
			RAISERROR (21062, 16, -1, @qualified_name)  
            -- RETURN (1)
        end
*/
	IF LOWER(@vertical_partition collate SQL_Latin1_General_CP1_CS_AS) = 'false'
		begin
			select @ver_partition = 0
		end
	else
		begin			
			select @ver_partition = 1
		end
    select @num_columns=count(*) from syscolumns where id = object_id(@qualified_name)

    if @num_columns > 246 and LOWER(@vertical_partition collate SQL_Latin1_General_CP1_CS_AS) = 'false'
        begin
            RAISERROR (20068, 16, -1, @qualified_name, 246)
            RETURN (1)
        end

    /*
    **  Get the id of the @qualified_name
    */
    select @objid = id, @replinfo = replinfo from sysobjects where id = OBJECT_ID(@qualified_name)
    if @objid is NULL
        begin
            raiserror (14027, 11, -1, @qualified_name)
            return (1)
        end

    /*
    ** If current publication contains a non-sync subscription, all articles to be added in it
    ** has to contain a rowguidcol.
    */
    if exists (select * from sysmergesubscriptions where pubid = @pubid and sync_type = 2)
        begin
            if not exists (select * from syscolumns c 
                where c.id=@objid and ColumnProperty(c.id, c.name, 'isrowguidcol') = 1)
                begin
                    raiserror(20086 , 16, -1, @publication)
                    return (1)
                end
        end

	/*
	** If you want to have identity support, @range and threshold can not be NULL
	*/
	if LOWER(@auto_identity_range collate SQL_Latin1_General_CP1_CS_AS) = 'true' and (@identity_range is NULL or @threshold is NULL or @pub_identity_range is NULL)
		begin
			raiserror(21193, 16, -1)
			return (1)
		end

	if LOWER(@auto_identity_range collate SQL_Latin1_General_CP1_CS_AS) = 'false' and (@identity_range is not NULL or @threshold is not NULL or @pub_identity_range is not NULL)
		begin
			raiserror(21282, 16, -1)
			return (1)
		end

	if @threshold<0 OR @threshold>100
		begin
			raiserror(21241, 16, -1)
			return (1)
		end

	if LOWER(@auto_identity_range collate SQL_Latin1_General_CP1_CS_AS) = 'true'
		begin
			select @identity_support = 1
			if OBJECTPROPERTY(@objid, 'tablehasidentity') <> 1
			begin
				raiserror(21194, 16, -1)
				return (1)
			end
		
		    if @pub_identity_range <= 1 or @identity_range <= 1
			begin
				raiserror(21232, 16 ,-1)
				return 1
			end

			select @xtype=xtype, @xprec=xprec from syscolumns where id=@objid and columnproperty(id, name, 'IsIdentity')=1
			select @max_range =
					case @xtype when 52 then power((convert(bigint,2)), 8*2-1) - 1 --smallint 
						when 48 then power((convert(bigint,2)), 8-1) - 1 		 --tinyint
						when 56 then power((convert(bigint,2)), 8*4-1) - 1 		 --int
						when 127 then power((convert(bigint,2)), 62) - 1 + power((convert(bigint,2)), 62)  	--bigint
 						else
							power((convert(bigint,2)), 62) -1 + power((convert(bigint,2)), 62)  -- defaulted to bigint
					end

			if (@xtype=108 or @xtype=106) and @xprec<18
				select @max_range = power((convert(bigint,10)), (@xprec+1)) - 1
		
			if @pub_identity_range * 2 + @identity_range > (@max_range - IDENT_CURRENT(@source_object))
				begin
					raiserror(21290, 16, -1)
					return (1)
				end
		end
	else
		select @identity_support = 0			


    /*
    ** Make sure that the table name specified is a table and not a view.
    */

    if NOT exists (select * from sysobjects
        where id = (select OBJECT_ID(@qualified_name)) AND type = 'U')
        begin
            raiserror (20074, 16, -1)
            return (1)
        end

    /*
    ** If the table contains one more columns of type bigint or sql_variant, 
    ** and the publication is not of type native mode, we bump up the backward 
    ** compatibility level.
    */
    if @sync_mode=0 and EXISTS (SELECT * FROM syscolumns c WHERE c.id = @sync_objid
                AND (type_name(c.xtype) = 'bigint' or type_name(c.xtype) = 'sql_variant'))
	begin
		raiserror(21357, 10, -1, @publication)
		select	@bump_to_80 = 1
	end

	/*
	** 7.0 subscribers do not like data type 'timestamp'
	*/
	if EXISTS (select * from syscolumns where id=@sync_objid and type_name(xtype) ='timestamp')
	begin
		raiserror(21358, 10, -1, @publication)
		select @bump_to_80 = 1
	end
        
    /*
    ** Validate the column tracking
    */
    if @column_tracking IS NULL OR LOWER(@column_tracking collate SQL_Latin1_General_CP1_CS_AS) NOT IN ('true', 'false')
        BEGIN
            RAISERROR (14148, 16, -1, '@column_tracking')
            RETURN (1)
        END
    if LOWER(@column_tracking collate SQL_Latin1_General_CP1_CS_AS) = 'true' 
        SET @column_tracking_id = 1
    else 
        SET @column_tracking_id = 0

	if @column_tracking_id=0 and @sync_mode = 1 and @ver_partition = 1
		begin
			RAISERROR (21244, 16, -1)
            RETURN (1)
		end

   	/*
    ** Parameter Check: @allow_interactive_resolver  
    */
    if LOWER(@allow_interactive_resolver collate SQL_Latin1_General_CP1_CS_AS) NOT IN ('true', 'false')
        BEGIN
            RAISERROR (14148, 16, -1, '@allow_interactive_resolver')
            RETURN (1)
        END
    if LOWER(@allow_interactive_resolver collate SQL_Latin1_General_CP1_CS_AS) = 'true'
        set @allow_interactive_bit = 1
    else 
        set @allow_interactive_bit = 0

	/*
    ** Parameter Check: @fast_multicol_updateproc  
    */
	if LOWER(@fast_multicol_updateproc collate SQL_Latin1_General_CP1_CS_AS) NOT IN ('true', 'false')
        BEGIN
            RAISERROR (14148, 16, -1, '@fast_multicol_updateproc')
            RETURN (1)
        END
    if LOWER(@fast_multicol_updateproc collate SQL_Latin1_General_CP1_CS_AS) = 'true'
        set @fast_multicol_updateproc_bit = 1
    else 
        set @fast_multicol_updateproc_bit = 0

    /*
    ** Get the pubid.
    */
    SELECT @pubid = pubid FROM sysmergepublications 
        WHERE name = @publication and UPPER(publisher)=UPPER(@publisher) and publisher_db=@publisher_db
    if @pubid is NULL
        begin
            raiserror (20026, 11, -1, @publication)
            return (1)
        end

    execute @retcode = dbo.sp_MSgetreplnick @pubid = @pubid, @nickname = @nickname output
    if (@@error <> 0) or @retcode <> 0 or @nickname IS NULL 
        begin
        RAISERROR (14055, 11, -1)
        RETURN(1)
        end                 

	/*
	** Get distribution server information for remote RPC call.
	*/
	EXECUTE @retcode = dbo.sp_helpdistributor @rpcsrvname = @distributor OUTPUT,
           			@distribdb   = @distribdb OUTPUT
	IF @@ERROR <> 0 or @retcode <> 0 or @distributor is NULL
	BEGIN
		RAISERROR (21337, 16, -1)
		RETURN (1)
	END

    /*
    ** Validate the article resolver
    */
    if @article_resolver IS NOT NULL
        begin
            if @article_resolver = 'default' OR @article_resolver = ''
                begin
                    select @article_resolver = NULL
                    select @resolver_clsid = NULL
                end                 
            else
                begin
                    /*
                    ** Get the distributor info
                    */
                    select @distproc = RTRIM(@distributor) + '.master.dbo.xp_regread'
                    EXECUTE @retcode = @distproc 'HKEY_LOCAL_MACHINE',
                                  'SOFTWARE\Microsoft\Microsoft SQL Server\80\Replication\ArticleResolver',
                                  @article_resolver,
                                  @param = @resolver_clsid  OUTPUT

                    IF @retcode <> 0 or @resolver_clsid IS NULL
                        BEGIN
                          RAISERROR (20020, 16, -1)
                          RETURN (1)
                        END
                end
        end

	/*
	** If article resolver is 'SP resolver', make sure that resolver_info refers to an SP or XP;
	** Also make sure it is stored with owner qualification
	*/
	if  @article_resolver = @sp_resolver
		begin
			if not exists (select * from sysobjects where id = object_id(@resolver_info) and ( type = 'P' or type = 'X'))
				begin
					raiserror(21343, 16, -1, @resolver_info)
					return (1)
				end
				
			select @sp_name = name, @sp_owner=user_name(uid) from sysobjects where id = object_id(@resolver_info)
			select @resolver_info = QUOTENAME(@sp_owner) + '.' + QUOTENAME(@sp_name) 
		end

	/* The following resolvers expect the @resolver_info to be NON NULL */
	if  @article_resolver = @sp_resolver or 
		@article_resolver = @additive_resolver or
		@article_resolver = @average_resolver or
		@article_resolver = @minimum_resolver or
		@article_resolver = @maximum_resolver or
		@article_resolver = @mindate_resolver or
		@article_resolver = @maxdate_resolver or
		@article_resolver = @mergetxt_resolver or
		@article_resolver = @pricolumn_resolver
		begin
		    if @resolver_info IS NULL 
		        begin
        			RAISERROR (21301, 16, -1, @article_resolver)
					return (1)
		        end
		end
	/*
	** If article resolver uses column names, make sure that resolver_info refers to a valid column.
	*/
	if  @article_resolver = @pricolumn_resolver or
		@article_resolver = @additive_resolver or
		@article_resolver = @average_resolver or
		@article_resolver = @minimum_resolver or
		@article_resolver = @maximum_resolver
		begin
			if not exists (select * from syscolumns where id = @objid and name=@resolver_info)
				begin
		            RAISERROR (21501, 16, -1, @article_resolver)
					return (1)
				end
		end
	/*
	** If article resolver is 'mindate/maxdate resolver', make sure that resolver_info refers to a column that is of datatype 'datetime' or smalldatetime
	*/
	if  @article_resolver = @mindate_resolver or
		@article_resolver = @maxdate_resolver
		begin
			if not exists (select * from syscolumns where id = @objid and name=@resolver_info and type_name(xtype)='datetime' or type_name(xtype) = 'smalldatetime' )
				begin
		            RAISERROR (21302, 16, -1, @article_resolver)
					return (1)
				end
		end

	/* The following resolvers expect the article to be column tracked - warn that the default resolver will be used */
	if  @article_resolver = @additive_resolver or
		@article_resolver = @average_resolver or
		@article_resolver = @mergetxt_resolver
		begin
			if @column_tracking_id = 0
				begin
		            RAISERROR (21303, 10, -1, @article, @article_resolver)
				end
				
		end

    if @resolver_info IS NOT NULL and @article_resolver IS NULL
	    begin
    	    RAISERROR (21300, 10, -1, @article)
        	set @resolver_info = NULL
        end

	/* Make sure that coltracking option matches */
	if exists (select * from sysmergearticles where objid = @objid and
			identity_support <> @identity_support)
		begin
			raiserror (21240, 16, -1, @source_object)
			return (1)
		end

	-- Do not allow the table to be published by both merge and queued tran
	if exists (select * from sysobjects where name = 'syspublications')
	begin
		if exists (select * from syspublications p, sysarticles a where 
			p.allow_queued_tran = 1 and
			p.pubid = a.pubid and
			a.objid = @objid)
		begin
			declare @obj_name sysname
			select @obj_name = object_name(@objid)
			raiserror(21266, 16, -1, @obj_name)
			return (1)
		end
	end

	if exists (select * from sysmergearticles where objid=@objid and pubid in(select pubid from sysmergepublications where UPPER(publisher)=UPPER(@publisher) 
        		and publisher_db=@publisher_db))
	select @already_published = 1

	if @already_published = 1 and LOWER(@auto_identity_range collate SQL_Latin1_General_CP1_CS_AS) = 'true'
	begin
		raiserror(21359, 10, -1, @publication)
		select @bump_to_80 = 1
		if exists (select * from MSrepl_identity_range where objid=@objid and 
			((pub_range<>@pub_identity_range) or (range <> @identity_range) or (threshold <> @threshold)))
			begin
				raiserror(21291, 16, -1)
				return (1)
			end
	end
	
    /*
    **  Add article to sysmergearticles and update sysobjects category bit.
    */
    begin tran
    save TRAN sp_addmergearticle

	/*
	** We used to prevent an article from being added to a publication whose snapshot
	** has been run already. Now we change this so that it is acceptable by doing reinit.
	*/
		if @snapshot_ready > 0 
		begin
			if @force_invalidate_snapshot = 0
			begin
				raiserror(21364, 16, -1, @article)
				goto FAILURE
			end
			update sysmergepublications set snapshot_ready=2 where pubid=@pubid
			if @@ERROR<>0
				goto FAILURE
		end

	/* 
	** article status 5 or 6 means there is at least one new article after snapshot is ready
	** hence all articles added after that point will be new articles as well, regardless of snapshot_ready value.
	*/
		if @snapshot_ready>0 or exists (select * from sysmergearticles where pubid=@pubid and (status=5 or status=6))
		begin
			select @needs_pickup=1
		end


        /*
        ** the case when @already_publisher=1 has been handled outside of the transaction
        */
        if LOWER(@auto_identity_range collate SQL_Latin1_General_CP1_CS_AS) = 'true' and @already_published = 0
		begin
			-- Set the range to negtive if incr of the identity is negtive
	        if IDENT_INCR(@source_object) < 0
    	    begin
        	    select @pub_identity_range = -1 * @pub_identity_range;
            	select @identity_range = -1 * @identity_range;
	        end
			raiserror(21359, 10, -1, @publication)
			select @bump_to_80 = 1
			select @next_seed = next_seed, @max_identity=max_identity from MSrepl_identity_range where objid=@objid
			select @identity_so_far = 0
			if @next_seed is NULL
			begin
				select @initial_setting = 1 -- adjust for existing rows, only for original publisher
				select @is_publisher= 1 --original publisher
				select @identity_so_far = IDENT_CURRENT(@source_object)
				if @identity_so_far is NULL
					begin
						select @next_seed = IDENT_SEED(@source_object)
						select @identity_so_far = @next_seed
					end
				else
					select @next_seed = @identity_so_far

				-- use boundary values by cutting off odds,	
				-- and always give publisher side one more range to allow for existing rows.				

				/* To avoid div by zero errors, error out if pub_range is 0 */
				if @pub_identity_range = 0
					begin
						goto FAILURE
					end
				select @next_seed = (@next_seed/@pub_identity_range) * @pub_identity_range 

				-- to compensate publisher side an extra range in case it loses some slots by rounding up.
				-- which only happens when the identity incremental is a positive value

				if (((@pub_identity_range > 0) and (@identity_so_far > @next_seed))
					OR
					((@pub_identity_range < 0) and (@identity_so_far < @next_seed))) --to make it symmetric both directions
					
					select @next_seed = @next_seed + @pub_identity_range
					
				select @max_identity = @max_range --max range decided by data type of identity column
				
				insert MSrepl_identity_range(objid, next_seed, pub_range, range, max_identity, threshold, current_max)
					values (@objid,@next_seed + @pub_identity_range, @pub_identity_range, @identity_range, @max_identity, @threshold, @next_seed + @pub_identity_range)
			end	
			else
			begin
				select @is_publisher=2 -- republisher
				update MSrepl_identity_range set current_max = @next_seed + @pub_identity_range,
												 pub_range = @pub_identity_range,
												 threshold= @threshold,
												 range = @identity_range
					where objid=@objid
				if @@ERROR<>0
					goto FAILURE
			end
				
	        select @distproc = RTRIM(@distributor) + '.' + @distribdb + '.dbo.sp_MSinsert_identity'
			SELECT @dbname =  DB_NAME()
			exec @retcode = @distproc @publisher = @publisher,
									  @publisher_db = @publisher_db,
									  @identity_support=@identity_support,
									  @tablename=@source_object,
									  @pub_identity_range = @pub_identity_range,
									  @identity_range =@identity_range,
									  @threshold =@threshold,
									  @next_seed = @next_seed,
									  @max_identity=@max_identity
			if @retcode<>0 or @@ERROR<>0
				goto FAILURE
				
			/* This is to change identity column to 'not for replication' if not having been so already */
			select @colname=NULL
			select @colname = name from syscolumns  where
				 id = @objid and
				 colstat & 0x0001 <> 0 and -- is identity
				 colstat & 0x0008 = 0 -- No 'not for repl' property
			if @colname is not null
			begin
                exec @retcode  = dbo.sp_replupdateschema @source_object
				-- Mark 'not for repl'
				update syscolumns set colstat = colstat | 0x0008 where
					id = @objid and name = @colname
				-- Single to refresh the object cache.
                exec @retcode  = dbo.sp_replupdateschema @source_object
				IF @@ERROR <> 0 OR @retcode <> 0
					goto FAILURE
			end

		end

        select @artid = artid from sysmergearticles where objid = @objid
        select @statusid = 1  /*default status is inactive */

        if @artid is NULL
            begin
                set @artid = newid()
                if @@ERROR <> 0
                    goto FAILURE
                execute @retcode = dbo.sp_MSgentablenickname @tablenick output, @nickname, @objid
                if @@ERROR <> 0 OR @retcode <> 0
                    goto FAILURE
            end
        /* Clone the article properties if article has already been published (in a different pub) */
        else
            begin
            /*
            ** Parameter Check:  @article, @publication.
            ** Check if the table already exists in this publication.
            */
            if exists (select * from sysmergearticles
                where pubid = @pubid AND artid = @artid)
                begin
                    raiserror (21292, 16, -1, @source_object)
                    goto FAILURE
                end
            
            /* Make sure that coltracking option matches */
            if exists (select * from sysmergearticles where artid = @artid and
                         column_tracking <> @column_tracking_id)
                begin
                    raiserror (20030, 16, -1, @article)
                    goto FAILURE
                end

            /* Reuse the article nickname if article has already been published (in a different pub)*/
            select @tablenick = nickname from sysmergearticles where artid = @artid
            if @tablenick IS NULL
                goto FAILURE
                
            /* Make sure that @resolver_clsid matches the existing resolver_clsid */
            select @resolver_clsid_old = resolver_clsid from sysmergearticles where artid = @artid 
            if ((@resolver_clsid IS NULL AND @resolver_clsid_old IS NOT NULL) OR
                (@resolver_clsid IS NOT NULL AND @resolver_clsid_old IS NULL) OR
                (@resolver_clsid IS NOT NULL AND @resolver_clsid_old IS NOT NULL AND @resolver_clsid_old <> @resolver_clsid))
                begin
                    raiserror (20037, 16, -1, @article)
                    goto FAILURE
                end

            /* Insert to articles, copying some stuff from other article row */
            insert into sysmergearticles (name, type, objid, sync_objid, artid, description,
                    pre_creation_command, pubid, nickname, column_tracking, status,
                    creation_script, article_resolver,
                    resolver_clsid, schema_option, 
                    destination_object, destination_owner, subset_filterclause, view_type, resolver_info, gen_cur, 
                    missing_cols, missing_col_count, excluded_cols, excluded_col_count, identity_support,
                    before_image_objid, before_view_objid, verify_resolver_signature, allow_interactive_resolver, 
                    fast_multicol_updateproc, check_permissions)
                -- use top 1, distinct could return more than one matching row if status different on partitioned articles
                select top 1 @article, type, objid, @sync_objid, @artid, @description, @precmdid,
                    @pubid, nickname, column_tracking, @statusid, @creation_script,
                    article_resolver, resolver_clsid, @schema_option, @destination_object, @destination_owner, @subset_filterclause, 
                    0, resolver_info, gen_cur, 0x00, 0, 0x00,0, identity_support,
                    before_image_objid, before_view_objid, verify_resolver_signature, allow_interactive_resolver, 
                    fast_multicol_updateproc, check_permissions
                    from sysmergearticles where artid = @artid

            /* Jump to end of transaction  */
            goto DONE_TRAN
            end

        /* Add the specific GUID based replication columns to sysmergearticles */
        insert sysmergearticles (name, objid, sync_objid, artid, type, description, pubid, nickname, 
                column_tracking, status, schema_option, pre_creation_command, destination_object, destination_owner, 
                article_resolver, resolver_clsid, subset_filterclause, view_type, resolver_info, columns,
                missing_cols, missing_col_count, excluded_cols, excluded_col_count, identity_support,
                before_image_objid, before_view_objid, verify_resolver_signature, creation_script, allow_interactive_resolver, 
                fast_multicol_updateproc, check_permissions)
        values (@article, @objid, @sync_objid, @artid, @typeid, @description, @pubid, @tablenick, 
                @column_tracking_id, @statusid, @schema_option, @precmdid, @destination_object, @destination_owner, 
                @article_resolver, @resolver_clsid, @subset_filterclause, 0, @resolver_info, NULL,
                 0x00, 0, 0x00,0, @identity_support, NULL, NULL, @verify_resolver_signature, @creation_script, @allow_interactive_bit, 
                 @fast_multicol_updateproc_bit, @check_permissions)
        if @@ERROR <> 0
            goto FAILURE

        exec @retcode = dbo.sp_replupdateschema @qualified_name
        if @@ERROR <> 0 or @retcode <> 0
            goto FAILURE
        update sysobjects set replinfo = (replinfo | @merge_pub_object_bit) where id = @objid
        if @@ERROR <> 0
            goto FAILURE

        /* set up the article's gen-cur */
		set @genguid = newid()
		set @dt = getdate()

		exec @retcode=sp_MSgetreplnick @nickname = @replnick out
		if @retcode<>0 or @@error<>0 
			goto FAILURE

		/*
		** If there are no zero generation tombstones or rows, add a dummy row in there. 
		*/
	   	if not exists (select * from MSmerge_genhistory)
			begin
			begin tran
		   	insert into MSmerge_genhistory (guidsrc, guidlocal, generation, art_nick, nicknames, coldate) values
				(@genguid, @genguid, 1, 0, @replnick, @dt)
			if (@@error <> 0)
				begin
				goto FAILURE
				end	
			commit tran
			end

		/* Make a generation and update the article's gen_cur */
		select @gen = max(gen_cur) from sysmergearticles (updlock holdlock) where nickname = @tablenick and gen_cur is not null
		if @gen is null
			begin
			set @genguid = newid()
			set @dt = getdate()
			insert into MSmerge_genhistory (guidsrc, guidlocal, generation, art_nick, nicknames, coldate) 
				select @genguid, @guidnull, COALESCE(1 + max(generation), 1), @tablenick, @replnick, @dt from MSmerge_genhistory (updlock)
			if (@@error <> 0)
				goto FAILURE
			select @gen =  generation from MSmerge_genhistory where guidsrc = @genguid
			update sysmergearticles set gen_cur = @gen where nickname = @tablenick
			if (@@error <> 0)
				goto FAILURE
			end

        /* If the article status is active then prepare the article for merge replication */
        if @status = 'active'
            begin
                /* Get a holdlock on the underlying table */
                select @cmd = 'select * into #tab1 from '
                select @cmd = @cmd + @qualified_name 
                select @cmd = @cmd + '(TABLOCK HOLDLOCK) where 1 = 2 '
                execute(@cmd)

                /* Add the guid column to the user table */
                execute @retcode = dbo.sp_MSaddguidcolumn @source_owner, @source_object
                if @@ERROR <> 0 OR  @retcode <> 0  -- NOTE: new change
                    goto FAILURE

                /* Create an index on the rowguid column in the user table */
                execute @retcode = dbo.sp_MSaddguidindex @publication, @source_owner, @source_object
                if @@ERROR <> 0 OR @retcode <> 0
                    goto FAILURE

                /* Create the merge triggers on the base table */
                execute @retcode = dbo.sp_MSaddmergetriggers @qualified_name, NULL, @column_tracking_id
                if @@ERROR <> 0 OR @retcode <> 0
                    goto FAILURE 

                /* Create the merge insert/update stored procedures for the base table */
                execute @retcode = dbo.sp_MSsetartprocs @publication, @article
                if @@ERROR <> 0 OR @retcode <> 0
                    goto FAILURE

                /* Set the article status to be active so that Snapshot does not do this again */
                select @statusid = 2 /* Active article */
                update sysmergearticles set status = @statusid where artid = @artid
                if @@ERROR <> 0 
                    goto FAILURE
            end
        
DONE_TRAN:				
			/* identity range control is row level. So one the one is needed for each table */
			if @identity_support=1 and @already_published=0
			begin

				exec @retcode = sp_MSreseed @objid=@objid,
										@next_seed=@next_seed,
										@range = @pub_identity_range,
										@is_publisher=@is_publisher,
										@check_only = 1,
										@initial_setting = @initial_setting,
										@bound_value = @identity_so_far
				if @@ERROR<>0 or @retcode<>0
						goto FAILURE
			end

    /*
    ** Set all bits to '1' in the columns column to include all columns.
    */

        IF @ver_partition = 0 --meanning no vertical partition needed.
        BEGIN
            EXECUTE @retcode  = dbo.sp_mergearticlecolumn @publication=@publication, @article=@article, @schema_replication='true'            
			IF @@ERROR <> 0 OR @retcode <> 0
            BEGIN
				RAISERROR(21198, 16, -1)
				goto FAILURE
            END
        END

        /*
        **  Set all bits to '1' for all columns in the primary key.
        */
        ELSE
        BEGIN
            SELECT @indid = indid FROM sysindexes WHERE id = @objid AND (status & 2048) <> 0    /* PK index */
            /*
            **  First we'll figure out what the keys are.
            */
            SELECT @i = 1
            WHILE (@i <= 16)
            BEGIN
                SELECT @pkkey = INDEX_COL(@source_object, @indid, @i)
                if @pkkey is NULL
                    break
                EXECUTE @retcode  = dbo.sp_mergearticlecolumn @publication, @article, @pkkey, 'add'
                IF @@ERROR <> 0 OR @retcode <> 0
                BEGIN
					RAISERROR(21198, 16, -1)
					goto FAILURE
				END
                select @i = @i + 1
            END
			/*
			** make sure any existing rowguidcol is in the partition. We can not live without it.
			*/
			select @colname=NULL
			select @colname = name from syscolumns where id = @objid 
				and ColumnProperty(@objid, name, 'isrowguidcol') = 1
			if @colname is not NULL
			BEGIN
				EXECUTE @retcode  = dbo.sp_mergearticlecolumn @publication, @article, @colname, 'add'
				if @@error<>0 or @retcode<>0
					goto FAILURE
			END
		END

        exec @retcode = sp_MSfillupmissingcols @publication, @source_object
        if @retcode<>0 or @@ERROR<>0
        	goto FAILURE

        /*
        ** For articles with subset filter clause - set the pub type to subset
        */
        if len(@subset_filterclause) > 0
            begin
                execute @retcode = dbo.sp_MSsubsetpublication @publication
                if @@ERROR <> 0 or @retcode<>0
                    goto FAILURE
            end                     

        SELECT @dbname =  DB_NAME()
        
        SELECT @distproc = RTRIM(@distributor) + '.' + @distribdb + 
            '.dbo.sp_MSadd_article'
        EXECUTE @retcode = @distproc
            @publisher = @@SERVERNAME,
            @publisher_db = @dbname,
            @publication = @publication,
            @article = @article,
            @destination_object = @destination_object,
            @source_owner = @source_owner,
            @source_object = @source_object,
            @description = @description
            -- @article_id = NULL
        IF @@ERROR <> 0 or @retcode <> 0
            BEGIN
                goto FAILURE
            END

		if @bump_to_80=1
			begin
				exec @retcode = sp_MSBumpupCompLevel @pubid, 40
				if @@ERROR<>0 or @retcode<>0
					goto FAILURE
			end
		if @needs_pickup=1
			begin
				declare @needs_pick_value int 
				select @needs_pick_value=5 --new_inactive status
				update sysmergearticles set status=@needs_pick_value where artid = @artid and pubid=@pubid
				if @@ERROR<>0
					goto FAILURE

                /* 
                ** Add the guid column to the user table if needed, cause snapshot_ready>0 would imply
                ** this article has got a rowguid column. No need to add index, triggers, or procedures
                ** as snapshot run will take care of those.
                */
                execute @retcode = dbo.sp_MSaddguidcolumn @source_owner, @source_object
                if @@ERROR <> 0 OR  @retcode <> 0  -- NOTE: new change
                    goto FAILURE

                execute @retcode = dbo.sp_MSaddguidindex @publication, @source_owner, @source_object
                if @@ERROR <> 0 OR @retcode <> 0
                    goto FAILURE
                    
			end

        COMMIT TRAN 

        /* If the article status is active adding the merge triggers to the base table */
         
        return (0)
FAILURE:
        RAISERROR (20009, 16, -1, @article, @publication)
        if @@TRANCOUNT > 0
        begin
            ROLLBACK TRANSACTION sp_addmergearticle
            COMMIT TRANSACTION
        end
        return (1)
go

exec dbo.sp_MS_marksystemobject sp_addmergearticle
go
grant execute on dbo.sp_addmergearticle to public
go
if exists (select * from sysobjects
	where type = 'P '
			and name = 'sp_MSmakearticleprocs')
	drop procedure sp_MSmakearticleprocs
go
raiserror('Creating procedure sp_MSmakearticleprocs', 0,1)
GO
create procedure sp_MSmakearticleprocs
	(@pubid uniqueidentifier, @artid uniqueidentifier)
as
	declare @ownername sysname
	declare @objectname sysname
	declare @ins_procname sysname
	declare @sel_procname sysname
	declare @upd_procname sysname
	declare @guidstr nvarchar(40)
	declare @trigname 		sysname
	declare @objid int
	declare @dbname			sysname
	declare @command		nvarchar(1000)
	
	-- to be called after article is set up in a subscriber
	declare @retcode smallint

	/*
	** Check for subscribing permission
	*/
	exec @retcode=sp_MSreplcheck_subscribe
	if @retcode<>0 or @@ERROR<>0 return (1)

	select @objid = max(objid) from sysmergearticles where artid = @artid
	-- get owner name, and table name
	select @objectname = name, @ownername = user_name(uid)
		from sysobjects	where id = @objid

	-- get the  insert and update proc names from sys articles
	select @ins_procname = insert_proc, @upd_procname = update_proc, @sel_procname = select_proc
		from sysmergearticles where pubid = @pubid and artid = @artid

	if object_id(@ins_procname) is not NULL
	begin
		exec ('drop proc ' + @ins_procname)
		if @@ERROR<>0 
			return (1)
	end

	if object_id(@upd_procname) is not NULL
	begin
		exec ('drop proc ' + @upd_procname)
		if @@ERROR<>0
			return (1)
	end

	if object_id(@sel_procname) is not NULL
	begin
		exec ('drop proc ' + @sel_procname)
		if @@ERROR<>0
			return (1)
	end

	-- create the procs
	set @dbname = db_name()
	/* If procedure already exists because article in multiple pubs don't bother */
	if not exists (select * from sysobjects where name = @ins_procname and type = 'P')
		begin
		set @command = 'sp_MSmakeinsertproc ' + QUOTENAME(@objectname) + ' , ' + QUOTENAME(@ownername) + ' , ' + @ins_procname  + ', [' + convert(nchar(36), @pubid) + ']'
		exec @retcode = master..xp_execresultset @command, @dbname
		if @@ERROR<>0 OR @retcode <>0 return (1)
		exec @retcode = dbo.sp_MS_marksystemobject  @ins_procname 
		if @@ERROR<>0 OR @retcode <>0 return (1)

		exec ('grant exec on ' + @ins_procname + ' to public')
		if @@ERROR<>0 return (1)
		end

	/* If procedure already exists because article in multiple pubs don't bother */
	if not exists (select * from sysobjects where name = @upd_procname and type = 'P')
		begin
		set @command = 'sp_MSmakeupdateproc ' + QUOTENAME(@objectname) + ' , ' + QUOTENAME(@ownername) + ' , ' + @upd_procname + ', [' + convert(nchar(36), @pubid) + ']'
		exec @retcode = master..xp_execresultset @command, @dbname
		if @@ERROR<>0 OR @retcode <>0 return (1)
		exec @retcode = dbo.sp_MS_marksystemobject  @upd_procname 
		if @@ERROR<>0 or @retcode <>0 return (1)
		exec ('grant exec on ' + @upd_procname + ' to public')
		if @@ERROR<>0 return (1)
		end
		
	/* If procedure already exists because article in multiple pubs don't bother */
	if not exists (select * from sysobjects where name = @sel_procname and type = 'P')
		begin
		set @command = 'sp_MSmakeselectproc ' + QUOTENAME(@objectname) + ' , ' + QUOTENAME(@ownername) + ' , ' + @sel_procname + ', [' + convert(nchar(36), @pubid) + ']'
		exec @retcode = master..xp_execresultset @command, @dbname
		if @@ERROR<>0 or @retcode<>0
			return (1)
		exec @retcode = dbo.sp_MS_marksystemobject  @sel_procname 
		if @@ERROR<>0 OR @retcode <>0 return (1)

		exec ('grant exec on ' + @sel_procname + ' to public')
		if @@ERROR<>0 return (1)
		end
		
go
exec dbo.sp_MS_marksystemobject sp_MSmakearticleprocs
go
grant exec on dbo.sp_MSmakearticleprocs to public
go
if exists (select * from sysobjects
	where type = 'P '
			and name = 'sp_MSmakeconflicttable')
	drop procedure sp_MSmakeconflicttable
go
raiserror('Creating procedure sp_MSmakeconflicttable', 0,1)
go
create procedure sp_MSmakeconflicttable (
	@article sysname, 
	@publication sysname,
	@creation_mode bit = 0, 	-- 0 = for publisher, 1 = for subscriber (snapshot)
	@is_debug bit = 0)	
as
begin
	--
	-- variables
	--
	declare @retcode	int
			,@cmd		nvarchar(4000)
			,@qualname	nvarchar(540)
			,@basetablename nvarchar(540)
			,@id 		int
			,@colid		int
			,@colname	sysname
			,@col		sysname
			,@coltype	sysname
			,@iscolnullable	bit
			,@dbname		sysname
			,@ownername	sysname
			,@tablename	sysname
			,@basetableid int
			,@columns	varbinary(32)
			,@isset		int
			,@tabid		int
			,@artid		int
			,@pubid		int
			,@indid		int
			,@indkey		int
			,@key		sysname
			,@indexname	sysname
			,@mode_publisher bit
			,@mode_subscriber bit
			,@is_queued bit

	set nocount on
	select @dbname = db_name()
	select @mode_publisher = 0, @mode_subscriber = 1

	--
	-- Check and make sure the base table exists
	--
	select	@artid = a.artid, @basetableid = a.objid, 
			@basetablename = object_name(a.objid), @columns = a.columns, 
			@pubid = a.pubid, @is_queued = NULLIF(p.allow_queued_tran, 0)
	from sysarticles a, syspublications p
	where	a.name = @article and
			p.name = @publication and
			a.pubid = p.pubid
	if (@basetableid is null or @basetableid = 0)
	begin
		raiserror('sp_MSmakeconflicttable(debug): bad basetableid = %d', 16, 1, @basetableid)
		return (1)
	end

	--
	-- If the publication does not allowed queued tran, return
	--
	if (@is_queued != 1)
		return 0

	--
	-- get the article owner
	--
    select @ownername = user_name(o.uid) 
	from sysobjects o , sysarticles a 
	where	o.id=a.objid and 
			a.name=@article

	--
	-- base table should be owner qualified
	--
	select @basetablename = QUOTENAME(@ownername) + N'.' + QUOTENAME(@basetablename)
	
	--
	-- Prepare the name for the Conflict table, index
	--
	if (@creation_mode = @mode_publisher)
	begin
		--
		-- creating on publisher - get unique names for table, index
		--
		exec @retcode = sp_MSgettranconflictname @publication=@publication, 
							@source_object=@basetablename, 
							@str_prefix='conflict_', 
							@conflict_table=@tablename OUTPUT
		if (@retcode != 0 or @@error != 0)
		begin
			raiserror('sp_MSmakeconflicttable(debug): sp_MSgettranconflictname failed for cft name', 16, 1)
			return (1)
		end

		exec @retcode = sp_MSgettranconflictname @publication=@publication, 
							@source_object=@basetablename, 
							@str_prefix='cftind_', 
							@conflict_table=@indexname OUTPUT
		if (@retcode != 0 or @@error != 0)
		begin
			raiserror('sp_MSmakeconflicttable(debug): sp_MSgettranconflictname failed for cft index', 16, 1)
			return (1)
		end
	end
	else
	begin
		--
		-- Get the destination owner
		--
		select	@ownername = dest_owner
		from sysarticles 
		where artid = @artid and pubid = @pubid
		
		--
		-- creating for subscriber, get the names from existing
		-- table on publisher
		--
		select @id = conflict_tableid, @tablename = OBJECT_NAME(conflict_tableid) 
		from sysarticleupdates
		where artid = @artid and pubid = @pubid

		exec @indid = dbo.sp_MStable_has_unique_index @id
		if (@indid = 0)
		begin
			raiserror('sp_MSmakeconflicttable(debug): no unique index for cft table', 16, 1)
			return (1)
		end
			
		select @indexname = name
		from sysindexes 
		where indid = @indid and id = @id
	end
	
	--
	-- Qualify the Conflict tablename
	--
	select @qualname = case 
		when (@ownername is null or @ownername = ' ') then QUOTENAME(@tablename)
				else QUOTENAME(@ownername) + '.' + QUOTENAME(@tablename) end

	--
	-- To check if specified object exists in current database drop it if it exists
	-- Do this only if we are creating for Publisher
	--
	if (@creation_mode = @mode_publisher)
	begin
		select @id = object_id(@qualname)
		if @id is not NULL
		begin
			execute( N'drop table ' + @qualname )
			if (@@error != 0)
			begin
				raiserror('sp_MSmakeconflicttable(debug): could not drop cft table', 16, 1)
				return (1)
			end
		end
	end

	--
	-- begin tran
	--
	begin tran sp_MSmakeconflicttable

	--
	-- create table to select the command text out of
	--
	if exists (select * from sysobjects where name = 'tempcmd' and uid = user_id('dbo'))
		drop table dbo.tempcmd
		
	create table dbo.tempcmd (step int identity NOT NULL, cmdtext nvarchar(4000) NULL)

	if (@creation_mode = @mode_subscriber)
	begin
		select @cmd = N'DROP TABLE ' + @qualname + N'
'
		insert into dbo.tempcmd(cmdtext) values(@cmd)
		insert into dbo.tempcmd(cmdtext) values(N'GO
')		
	end
	
	select @cmd = N'CREATE TABLE ' + @qualname + N'('
	insert into dbo.tempcmd(cmdtext) values(@cmd)

	--
	-- Declare the cursor to get info on each column of base table
	--
	declare #hcurColumnInfo cursor local FAST_FORWARD FOR
		select colid,
		isnullable
		from syscolumns
		where iscomputed = 0 and id=@basetableid 
		order by colid
	FOR READ ONLY

	select @cmd = NULL
	open #hcurColumnInfo
	fetch #hcurColumnInfo into @colid, @iscolnullable
	while (@@FETCH_STATUS = 0)
	begin
		-- Check if this column is included for replication
		if (@columns is null)
			select @isset = 1
		else
			exec @isset = dbo.sp_isarticlecolbitset @colid, @columns

		-- Get the typestring for this column
		-- Skip this column if it is NULL
		if ( @isset != 0 )
		begin		
			exec @retcode = dbo.sp_MSget_type @basetableid, @colid, @colname output, @coltype OUTPUT
			if (@@ERROR!= 0 or @retcode != 0)
			begin
				raiserror('sp_MSmakeconflicttable(debug): sp_MSget_type failed', 16, 1)
				rollback tran sp_MSmakeconflicttable
				return (1)
			end

			if (@coltype IS NULL)
				select @isset = 0
		end
			
		-- process the column ?
		if ( @isset != 0 )
		begin		
			-- Initialize
			if (@cmd is NULL)
				select @cmd = N'	'
			else
				select @cmd = N'	,'

			-- Create the column info
			select @cmd = @cmd + quotename(@colname) + N' ' 
			select @cmd = @cmd + @coltype
			
			-- Apply nullability
			if (@iscolnullable = 1)
				select @cmd = @cmd + N' NULL'
			else
				select @cmd = @cmd + N' NOT NULL'

			-- insert into the temptable
			insert into dbo.tempcmd(cmdtext) values(@cmd)
		end

		-- do the next fetch
		fetch #hcurColumnInfo into @colid, @iscolnullable
	end

	close #hcurColumnInfo
	deallocate #hcurColumnInfo

	--
	-- Now add the conflict related columns
	--
	insert into dbo.tempcmd(cmdtext) values(N'	,origin_datasource nvarchar(255) NULL
	,conflict_type int NULL
	,reason_code int NULL
	,reason_text nvarchar(720) NULL
	,pubid int NULL
	,tranid nvarchar(40) NULL
	,insertdate datetime NOT NULL
	,qcfttabrowid uniqueidentifier DEFAULT NEWID() NOT NULL)
	')

	--
	-- Create an unique index - we add some more fields to the index of base table
	--
	exec @indid = dbo.sp_MStable_has_unique_index @basetableid
	if (@indid = 0)
	begin
		raiserror('sp_MSmakeconflicttable(debug): no unique index for base table', 16, 1)
		rollback tran sp_MSmakeconflicttable
		return (1)
	end

	if (@creation_mode = @mode_subscriber)
	begin
		insert into dbo.tempcmd(cmdtext) values(N'GO
')		
	end

	insert into dbo.tempcmd(cmdtext) values(N'
	CREATE UNIQUE INDEX ' + quotename(@indexname) + ' ON ' +  @qualname  + N'(')

	select @cmd = NULL
	select @indkey = 1
	while (@indkey <= 16)
	begin	
		select @key = index_col(@basetablename, @indid, @indkey)
		if (@key is not null)
		begin
			-- make sure we are replicating this column
			if (@columns is null)
				select @isset = 1
			else
			begin
				-- map the index to the right column in base table
				exec dbo.sp_MSget_col_position @basetableid, @columns, @key, @col output, @colid output
				exec @isset = dbo.sp_isarticlecolbitset @colid, @columns
			end
				
			if (@isset = 1)
			begin
				if (@cmd is NULL)
					select @cmd = quotename(@key)
				else
					select @cmd = @cmd + N', ' + quotename(@key)
			end
		end
		select @indkey = @indkey + 1
	end
	
	--
	-- Add two more fields in the index
	--
	if (@cmd is NULL)
		select @cmd = N'tranid, qcfttabrowid'
	else
		select @cmd = @cmd + N', tranid, qcfttabrowid'
	insert into dbo.tempcmd(cmdtext) values(@cmd + N')')

	--
	-- If we are creating on publisher
	-- create the table now and update sysarticleupdates now
	--
	if (@creation_mode = @mode_publisher)
	begin
		if (@is_debug = 0)
		begin
			--
			-- create the table now
			--
			select @cmd = 'select cmdtext from dbo.tempcmd order by step'
			exec @retcode = master..xp_execresultset @cmd, @dbname
			if (@@error != 0 or @retcode != 0)
			begin
				raiserror('sp_MSmakeconflicttable(debug): xp_execresultset failed', 16, 1)
				rollback tran sp_MSmakeconflicttable
				return (1)
			end

			--
			-- update sysarticleupdates
			--
			select @tabid = id from sysobjects where name = @tablename
			if (@tabid = 0 or @tabid is NULL)
			begin
				raiserror('sp_MSmakeconflicttable(debug): cft table not created after xp_execresultset', 16, 1)
				rollback tran sp_MSmakeconflicttable
				return (1)
			end
			else
			begin
				update dbo.sysarticleupdates set conflict_tableid = @tabid
					where artid = @artid and pubid = @pubid

				-- mark the table as system object
				if (@ownername in ('dbo','INFORMATION_SCHEMA'))
				begin
					exec @retcode = dbo.sp_MS_marksystemobject @tablename
					if (@@error != 0 or @retcode != 0)
					begin
						-- roll back the tran
						raiserror('sp_MSmakeconflicttable(debug): sp_MS_marksystemobject exec failed for cft table', 16, 1)
						rollback tran sp_MSmakeconflicttable
						return (1)
					end
				end
			end
		end
		else
			select cmdtext from dbo.tempcmd order by step
	end

	--
	-- commit the tran
	--
	commit tran	

	--
	-- If we are creating for subscriber then
	-- just to a select on the temp table
	--
	if (@creation_mode = @mode_subscriber)
	begin
		select cmdtext from dbo.tempcmd order by step
	end

	-- drop the table we created
	drop table dbo.tempcmd
	return 0
end
go
exec dbo.sp_MS_marksystemobject sp_MSmakeconflicttable 
go
grant execute on dbo.sp_MSmakeconflicttable to public
go
--------------------------------------------------------------------------------
--. sp_MSupdategenhistory
--------------------------------------------------------------------------------
if exists (select * from sysobjects
	where type = 'P ' and name = 'sp_MSupdategenhistory')
	drop procedure sp_MSupdategenhistory
go
raiserror('Creating procedure sp_MSupdategenhistory', 0,1)
GO
CREATE PROCEDURE sp_MSupdategenhistory
	(@guidsrc uniqueidentifier, @pubid uniqueidentifier, @gen int, @art_nick int = NULL)
as
	declare @guidlocal uniqueidentifier
	
	/*
	** Check to see if current publication has permission
	*/
	declare @retcode int

	if sessionproperty('replication_agent') = 0
	begin
		exec @retcode=sp_MSreplcheck_connection
			@pubid = @pubid
		if @retcode<>0 or @@ERROR<>0 return (1)
	end
	
	if (@guidsrc is null)
	begin
		RAISERROR(14043, 16, -1, '@guidsrc')
		return (1)
	end
		
	if @art_nick = 0 set @art_nick = NULL
	
	set @guidlocal = newid()
	begin tran
	save tran sp_MSupdategenhistory
	if exists (select * from dbo.MSmerge_genhistory where guidsrc = @guidsrc and generation < @gen)
	begin
		create table #gentable (generation int)

		insert into #gentable select generation from dbo.MSmerge_genhistory where guidsrc = @guidsrc and generation < @gen

		update mc set mc.generation= @gen from dbo.MSmerge_contents as mc inner join #gentable as g 
			on (mc.generation=g.generation) 
		if @@ERROR <> 0 goto FAILURE

		update mt set mt.generation= @gen from dbo.MSmerge_tombstone as mt inner join #gentable as g 
			on (mt.generation=g.generation) 
		if @@ERROR <> 0 goto FAILURE
		
		declare @cmd nvarchar(200)
		declare @bi_objid int
		set @bi_objid= (select top 1 before_image_objid from sysmergearticles where nickname = @art_nick)
		if @bi_objid is not null
		begin
			set @cmd= 'update bi set bi.generation= @gen from dbo.' + object_name(@bi_objid) + ' as bi inner join #gentable as g
				on (bi.generation = g.generation)'
			exec dbo.sp_executesql @cmd, N'@gen int', @gen= @gen
			if @@ERROR <> 0 goto FAILURE
		end

		delete from dbo.MSmerge_genhistory where guidsrc = @guidsrc and generation < @gen
		
		if @@ERROR <> 0 goto FAILURE

		drop table #gentable
	end
	if exists (select * from dbo.MSmerge_genhistory where guidsrc = @guidsrc)
		update dbo.MSmerge_genhistory set   guidlocal= @guidlocal, 
											art_nick = case when isnull(@art_nick,0) <> 0 then @art_nick else art_nick end, 
											coldate= getdate() 
											where guidsrc = @guidsrc 
	else
	begin
		declare @mynickname int
		declare @nickbin varbinary(255)

		exec dbo.sp_MSgetreplnick @nickname = @mynickname out
		if @@ERROR<>0 goto FAILURE

		-- Append guard byte if it is needed
		if @mynickname % 256 = 0
			set @nickbin  = convert(binary(4), @mynickname) + 0x01
		else
			set @nickbin  = convert(binary(4), @mynickname)

		insert into dbo.MSmerge_genhistory (guidsrc, guidlocal, generation, art_nick, nicknames, coldate) values
			(@guidsrc, @guidlocal, @gen, @art_nick, @nickbin , getdate())

	end

	commit

	-- Now that we have closed a generation that was open, we might be ready to
	-- cleanup metadata or something like that.
	exec @retcode = sp_MSquiescecheck					
	
	return (0)
	
FAILURE:
	rollback tran sp_MSupdategenhistory
	commit tran
	return(1)
go
exec dbo.sp_MS_marksystemobject sp_MSupdategenhistory
go
grant exec on dbo.sp_MSupdategenhistory to public
go
--------------------------------------------------------------------------------
--. sp_mergemetadataretentioncleanup
--------------------------------------------------------------------------------
if exists (select * from sysobjects
	where type = 'P ' and name = 'sp_mergemetadataretentioncleanup')
	drop procedure sp_mergemetadataretentioncleanup
go
raiserror('Creating procedure sp_mergemetadataretentioncleanup', 0,1)
GO
create procedure sp_mergemetadataretentioncleanup
	(@num_genhistory_rows int = 0 output, 
	 @num_contents_rows int = 0 output, 
	 @num_tombstone_rows int = 0 output)
as
	declare @maxretention int
	declare @artnick int
	declare @gen int
	declare @retcode smallint
	declare @bi_objid int
	declare @cmd nvarchar(200)
	declare @guidnull uniqueidentifier
	declare @delbatchsize int
	declare @delcount int
   	declare @applockname nvarchar(255)

	set @num_genhistory_rows= 0
	set @num_contents_rows= 0
	set @num_tombstone_rows= 0

	-- if somebody else is already cleaning up in this database, we simply return
   	set @applockname= 'MS_sp_mergemetadataretentioncleanup' + convert(nvarchar(11), db_id())
	exec @retcode= sp_getapplock @Resource= @applockname, @LockMode= 'Exclusive', @LockOwner= 'Session', @LockTimeout= 0 
	if @@error <> 0 or @retcode < 0 return (0)
	
	set @guidnull= '00000000-0000-0000-0000-000000000000'
	set @delbatchsize= 5000

	create table #oldgens (gen int unique clustered)

	-- iterate over all articles that do not belong to a publication with infinite retention
	declare article_curs cursor local fast_forward for 
		select distinct nickname from sysmergearticles where 
			nickname not in (select distinct a.nickname from sysmergearticles as a inner join sysmergepublications as p on (a.pubid = p.pubid) 
								where isnull(p.retention, 0) = 0)

	open article_curs
	fetch next from article_curs into @artnick

	while (@@fetch_status <> -1)
	begin
		-- find max retention of all pubs the article belongs to
		select @maxretention= max(isnull(retention,0)) from sysmergepublications where
								pubid in (select pubid from sysmergearticles where nickname = @artnick)
		-- add one to make up for maximal possible timezone differences, plus one to compensate for clock inaccuracies
		set @maxretention= @maxretention + 1

		delete from #oldgens
		insert into #oldgens select distinct generation from MSmerge_genhistory where
	 							art_nick = @artnick and
								guidlocal <> @guidnull and
								coldate < dateadd(day, -@maxretention, getdate())

		-- go to next article if this one has no stale generations
		if @@rowcount = 0
		begin
			fetch next from article_curs into @artnick
			continue
		end

		-- set highest version in sysmergearticles
		exec @retcode= sp_MSsethighestversion @artnick= @artnick
		if @retcode<>0 or @@error<>0 goto Failure

		-- clean up contents, tombstone, before image (if it exists), genhistory
		set rowcount @delbatchsize
		set @delcount= @delbatchsize
		while @delcount = @delbatchsize
		begin
			delete mc from MSmerge_contents as mc inner join #oldgens as og on (mc.generation = og.gen) where mc.tablenick = @artnick
			set @delcount= @@rowcount
			set @num_contents_rows= @num_contents_rows + @delcount
		end

		set @delcount= @delbatchsize
		while @delcount = @delbatchsize
		begin
			delete mt from MSmerge_tombstone as mt inner join #oldgens as og on (mt.generation = og.gen) where tablenick = @artnick
			set @delcount= @@rowcount
			set @num_tombstone_rows= @num_tombstone_rows + @delcount
		end

		set @bi_objid= (select top 1 before_image_objid from sysmergearticles where nickname = @artnick)
		if @bi_objid is not null
		begin
			set @cmd= 'delete bi from ' + object_name(@bi_objid) + ' as bi inner join #oldgens as og on (bi.generation = og.gen)'
			set @delcount= @delbatchsize
			while @delcount = @delbatchsize
			begin
				exec dbo.sp_executesql @cmd
				set @delcount= @@rowcount
			end
		end

		set @delcount= @delbatchsize
		while @delcount = @delbatchsize
		begin
			delete gh from MSmerge_genhistory as gh inner join #oldgens as og on (gh.generation = og.gen) where art_nick = @artnick
			set @delcount= @@rowcount
			set @num_genhistory_rows= @num_genhistory_rows + @delcount
		end

		set rowcount 0

		-- get next article
		fetch next from article_curs into @artnick
	end

	close article_curs
	deallocate article_curs
	drop table #oldgens
	
	exec sp_MScleanup_zeroartnick_genhistory @num_genhistory_rows output, @num_contents_rows output
	 
	exec @retcode= sp_releaseapplock @Resource= @applockname, @LockOwner= 'Session'
	if @@error <> 0 or @retcode < 0
		return (1)
	else
		return (0)

Failure:
	close article_curs
	deallocate article_curs
	drop table #oldgens
	exec sp_releaseapplock @Resource= @applockname, @LockOwner= 'Session'
	return (1)

go
exec dbo.sp_MS_marksystemobject sp_mergemetadataretentioncleanup
go
grant execute on dbo.sp_mergemetadataretentioncleanup to public
go
--------------------------------------------------------------------------------
--. sp_MSpurgecontentsorphans
--------------------------------------------------------------------------------
if exists (select * from sysobjects
	where type = 'P ' and name = 'sp_MSpurgecontentsorphans')
	drop procedure sp_MSpurgecontentsorphans
go
raiserror('Creating procedure sp_MSpurgecontentsorphans', 0,1)
go
create procedure sp_MSpurgecontentsorphans
as
	declare @retcode smallint
	
	create table #oldgens (artnick int, gen int)
	create unique clustered index ucOldgens on #oldgens(artnick, gen)

	-- find generations that exist in MSmerge_contents but not in MSmerge_genhistory
	insert into #oldgens (artnick, gen) select distinct tablenick, generation
			from dbo.MSmerge_contents
			where generation not in (select distinct generation from dbo.MSmerge_genhistory)
			
	exec @retcode = sp_MSdelete_specifiedcontents
	drop table #oldgens
	return @retcode
go
exec dbo.sp_MS_marksystemobject sp_MSpurgecontentsorphans
go
grant execute on dbo.sp_MSpurgecontentsorphans to public
go
--------------------------------------------------------------------------------
--. sp_MScleanup_zeroartnick_genhistory
--------------------------------------------------------------------------------
if exists (select * from sysobjects
	where type = 'P ' and name = 'sp_MScleanup_zeroartnick_genhistory')
	drop procedure sp_MScleanup_zeroartnick_genhistory
go
raiserror('Creating procedure sp_MScleanup_zeroartnick_genhistory', 0,1)
GO
create procedure sp_MScleanup_zeroartnick_genhistory 
	(@num_genhistory_rows int = 0 output, 
	 @num_contents_rows int = 0 output)
as
	declare @retcode smallint
	declare @maxretention int
	declare @guidnull uniqueidentifier
	declare @oldgencount int
	declare @zeroartnickgencount int
	
	-- If there is any publication that has infinite retention, then we 
	-- should not clean up genhistory rows that have 0 art_nick. This is 
	-- because the gen could potentially have changes in articles that belong
	-- to that publication.
	if exists (select * from sysmergepublications where isnull(retention,0) = 0)
		return 0
	
	-- Now we know we only have publications that have a finite retention period.
	-- Let us choose the highest retention period across all publications and use
	-- that when cleaning up generations with 0 art_nick. Again this is because this
	-- gen could have changes in articles from any of those publications. It is safer
	-- to be pessimistic.
	select @maxretention = max(isnull(retention,0)) from sysmergepublications
	
	-- add one to make up for maximal possible timezone differences, plus one to compensate for clock inaccuracies
	set @maxretention= @maxretention + 1

	create table #oldgens (artnick int, gen int)
	create unique clustered index ucOldgens on #oldgens(artnick, gen)
	create table #zeroartnickgens (gen int)
	create unique clustered index ucZeroartnickgens on #zeroartnickgens(gen)
	
	set @guidnull= '00000000-0000-0000-0000-000000000000'
	
	insert into #zeroartnickgens (gen) select distinct generation from MSmerge_genhistory where
									art_nick = 0 and
									generation > 1 and
									guidlocal <> @guidnull and
									coldate < dateadd(day, -@maxretention, getdate())
									
	select @zeroartnickgencount = @@rowcount
	
	if (@zeroartnickgencount = 0)
	begin
		drop table #oldgens
		drop table #zeroartnickgens
		return 0
	end
	
	-- find entries that exist in MSmerge_contents that have art_nick = 0 in MSmerge_genhistory
	insert into #oldgens (artnick, gen) select distinct tablenick, generation
			from dbo.MSmerge_contents
			where generation in (select gen from #zeroartnickgens)
		
	select @oldgencount = @@rowcount
	set @retcode = 0
	
	if (@oldgencount > 0)
	begin
		exec @retcode = sp_MSdelete_specifiedcontents @num_contents_rows output
	end
	
	if (@@error = 0 and @retcode = 0)
	begin
		declare @delcount int
		declare @delbatchsize int
		set @delbatchsize= 5000

		set rowcount @delbatchsize
		set @delcount= @delbatchsize
		while @delcount = @delbatchsize
		begin
			delete gh from MSmerge_genhistory as gh inner join #zeroartnickgens as zag on (gh.generation = zag.gen) 
					where art_nick = 0 
					and generation > 1 
					and guidlocal <> @guidnull 
					and coldate < dateadd(day, -@maxretention, getdate())
					
			set @delcount= @@rowcount
			set @num_genhistory_rows= @num_genhistory_rows + @delcount
		end

		set rowcount 0
	end
	
	drop table #oldgens
	drop table #zeroartnickgens
	return @retcode
go
exec dbo.sp_MS_marksystemobject sp_MScleanup_zeroartnick_genhistory
go
--------------------------------------------------------------------------------
--. sp_MSdelete_specifiedcontents
--------------------------------------------------------------------------------
if exists (select * from sysobjects
	where type = 'P ' and name = 'sp_MSdelete_specifiedcontents')
	drop procedure sp_MSdelete_specifiedcontents
go
raiserror('Creating procedure sp_MSdelete_specifiedcontents', 0,1)
GO
create procedure sp_MSdelete_specifiedcontents (@num_contents_rows int = 0 output)
as
	declare @retcode smallint
	-- iterate over articles in the temptable
	declare @artnick int
	declare article_curs cursor local fast_forward for 
		select distinct artnick from #oldgens

	open article_curs
	fetch next from article_curs into @artnick

	while (@@fetch_status <> -1)
	begin
		-- if necessary, update highest version in sysmergearticles
		exec @retcode= sp_MSsethighestversion @artnick= @artnick
		if @retcode<>0 or @@error<>0 goto Failure

		-- clean up orphaned rows in MSmerge_contents
		declare @delcount int
		declare @delbatchsize int
		
		set @delbatchsize= 5000
		set rowcount @delbatchsize
		set @delcount= @delbatchsize
		while @delcount = @delbatchsize
		begin
			delete mc from MSmerge_contents as mc inner join #oldgens as og 
				on (mc.tablenick = og.artnick and mc.generation = og.gen) 
				where mc.tablenick = @artnick
			set @delcount= @@rowcount
			set @num_contents_rows = @num_contents_rows + @delcount
		end

		-- get next article
		fetch next from article_curs into @artnick
	end
	set rowcount 0
	
	close article_curs
	deallocate article_curs
	return(0)

Failure:
	close article_curs
	deallocate article_curs
	return (1)
go
exec dbo.sp_MS_marksystemobject sp_MSdelete_specifiedcontents
go
--------------------------------------------------------------------------------
-- sp_MSaddupdatetrigger
--------------------------------------------------------------------------------
if exists (select * from sysobjects
	where type = 'P ' and name = 'sp_MSaddupdatetrigger')
	drop procedure sp_MSaddupdatetrigger
go
raiserror('Creating procedure sp_MSaddupdatetrigger', 0,1)
GO
CREATE PROCEDURE sp_MSaddupdatetrigger 
	@source_table		nvarchar(270),		/* source table name */
	@owner				sysname,			/* Owner name of source table */
	@object 			sysname,			/* Object name */
	@artid				uniqueidentifier,	/* Article id */
	@column_tracking		int,
	@viewname			sysname 			/* name of view on syscontents */
    
AS
	declare @command1 nvarchar(4000)
	declare @command2 nvarchar(4000)
	declare @command3 nvarchar(4000)
    declare @command4 nvarchar(4000)
	declare @inscommand nvarchar(2000)
	declare @tablenick int	
	declare @nickname int
	declare @viewcols int
	declare @trigname sysname
	declare @ext nvarchar(10)
	declare @gstr sysname
	declare @tablenickchar nvarchar(11)
	declare @ccols int
	declare @guidstr	nvarchar(32)
	declare @colid smallint
	declare @colordinal		smallint
	declare @colordstr		varchar(4)

	declare @colname 	sysname
	declare @cur_name	sysname
	declare @colpat nvarchar(130)
	declare @colchar nvarchar(5)
	declare @piece nvarchar(400)

	declare @retcode int
	declare @ifcol nvarchar(4000)
	declare @ccolchar nvarchar(5)
	declare @partchangecnt int
	declare @joinchangecnt int
	declare @partchangecnt2 int
	declare @cvstr1	nvarchar(500)
	declare @cvstr2 nvarchar(500)
	declare @flag smallint
	declare @missingbm varbinary(500)
	declare @missing_cols	varbinary(32)
	declare @mapdownbm varbinary(500)
	declare @mapupbm   varbinary(500)
	declare @missingcolid int
	declare @maxcolid int
	declare @missingbmstr varchar(1000)
	declare @mapdownbmstr varchar(1000)
	declare @mapupbmstr   varchar(1000)
	declare @objid int
	declare @sync_objid int
	declare @partchbm varbinary(500)
	declare @missing_col_count	int
	declare @excluded_col_count int
	declare @joinchbm varbinary(500)
	declare @partchstr varchar(1002)
	declare @joinchstr varchar(1002)
	declare @column_hole bit
	declare @notforrepl_bit bit
	declare @notforrepl_str nvarchar(200)
	declare @owner_is_admin bit
	
	set @notforrepl_bit = 1
	set @ifcol = ''
	set @column_hole = 0
	set @owner_is_admin = 0
	
	select @owner_is_admin=sysadmin from master..syslogins l, sysusers u where l.sid=u.sid and u.name=@owner collate database_default
	select @flag = 0
	set @objid = OBJECT_ID(@source_table)
	select @sync_objid = sync_objid, @missing_cols = missing_cols, @excluded_col_count = excluded_col_count,
									@missing_col_count=missing_col_count 
					from sysmergearticles where artid= @artid and objid=@objid
	select @ccols =  count(*) from syscolumns where id = @objid and iscomputed <> 1 and type_name(xtype) <> 'timestamp'
	/* Figure out if there are any holes in the colid sequence */
	select @maxcolid = max(colid) from syscolumns where id = @objid
	if @ccols <> @maxcolid
		select @column_hole = 1
	/*
	** adjust the number of columns in the original table by adding up missing columns; in both Pub/Sub sides.
	*/
	if @missing_col_count>0
		select @ccols = @ccols + @missing_col_count
	select @ccolchar = convert(nchar, @ccols)
	set @colordinal = 0
	
	execute @retcode=sp_MStablenickname @owner, @object, @tablenick output
	if @@ERROR<>0 or @retcode<>0 return (1)
	set @tablenickchar = convert(nchar, @tablenick)
	set @joinchbm = 0x0
	set @partchbm = 0x0

	-- Check if the update trigger can be made NOT FOR REPLICATION
	if exists (select * from sysmergearticles 
			   where nickname = @tablenick 
			   and
			   (before_image_objid is not null or
			    before_view_objid is not null or
			    datalength (subset_filterclause) > 1
			   ))
	begin
		select @notforrepl_bit = 0
	end
	else if exists (select * from sysmergesubsetfilters where art_nickname = @tablenick or join_nickname = @tablenick)
	begin
		select @notforrepl_bit = 0
	end
	else
	begin
		select @notforrepl_bit = 1
	end
	
	select @notforrepl_str = ' 
	if sessionproperty(''replication_agent'') = 1 and (select trigger_nestlevel()) = 1 -- and master.dbo.fn_isreplmergeagent() = 1
		return '
		
	declare col_cursor CURSOR LOCAL FAST_FORWARD for select name, colid from syscolumns where
		id = @objid  and iscomputed <> 1 and type_name(xtype) <> 'timestamp' order by colid
	FOR READ ONLY
	
	/* Try to set the ifcol pieces of the trigger */
	open col_cursor
	fetch next from col_cursor into @colname, @colid
	while (@@fetch_status <> -1)
		begin
		set @colordinal = @colordinal + 1
		set @colpat = '%' + @colname + '%'
		/* Don't let them update the rowguid column */
		if columnproperty( @objid, @colname , 'isrowguidcol')=1
			set @ifcol = 'if update(' + QUOTENAME(@colname) +	')
			begin
			if @@trancount > 0
				rollback tran
				
			RAISERROR (20062, 16, -1)
			end
				'
		/* does updating this column change membership in a partial replica? */
		select @partchangecnt = count(*) from sysmergearticles 
			where nickname = @tablenick and subset_filterclause like @colpat
		select @partchangecnt2 = count(*) from sysmergesubsetfilters
			where art_nickname = @tablenick and join_filterclause like @colpat
		select @joinchangecnt = count(*) from sysmergesubsetfilters
		 	where join_nickname = @tablenick and join_filterclause like @colpat
		if @partchangecnt > 0 or @partchangecnt2 > 0
			exec dbo.sp_MSsetbit @partchbm out, @colid
		else if @joinchangecnt > 0
			exec dbo.sp_MSsetbit @joinchbm out, @colid
		/* Repeat the loop with next column */
		fetch next from col_cursor into @colname, @colid
		end
	close col_cursor
	deallocate col_cursor

	-- Initialize string for inserting to before_image table
	exec sp_MSgetbeforetableinsert @objid, @inscommand output

	/* Make strings to initialize variables for partchange, joinchange bitmaps */
	exec master..xp_varbintohexstr @partchbm, @partchstr out
	exec master..xp_varbintohexstr @joinchbm, @joinchstr out

	select @mapdownbm =0x00
	select @mapupbm = 0x00
	/*
	** To see if there is a need for map down.
	*/
	if @column_hole<>0
	begin
		set @missingcolid = 1
		while (@missingcolid <= @maxcolid)
			begin
			if not exists (select * from syscolumns where colid = @missingcolid and
						id = OBJECT_ID(@source_table) and iscomputed <> 1 and type_name(xtype) <> 'timestamp')
					exec dbo.sp_MSsetbit @mapdownbm out, @missingcolid
			set @missingcolid = @missingcolid + 1
			end
	end
	set @mapupbm = @missing_cols -- do this at both sides, good for republishing.
	
	exec master..xp_varbintohexstr @mapdownbm, @mapdownbmstr out
	exec master..xp_varbintohexstr @mapupbm, @mapupbmstr out
	
	execute @retcode=sp_MSgetreplnick @nickname = @nickname output
	if @retcode<>0 or @@error<>0 return (1)
	set @ext = 'upd_'

	exec @retcode=sp_MSguidtostr @artid, @guidstr out
	if @retcode<>0 or @@error<>0 return (1)

	set @trigname =  @ext + @guidstr 

	/* Make sure trigger name is unique */
	exec @retcode=sp_MSuniqueobjectname @trigname, @trigname output
	if @retcode<>0 or @@error<>0 return (1)
	if @column_tracking <> 0
		begin
		/* Set cv pieces appropriately */
		set @cvstr1 = ' 
		    set @lineage = { fn UPDATELINEAGE(0x0, @nick, @oldmaxversion+1) }
		    set @cv = { fn INITCOLVS(@ccols, @nick) }
			if (@@error <> 0)
				begin
				goto FAILURE
				end
		    set @cv = { fn UPDATECOLVBM(@cv, @nick, @bm, @missingbm, { fn GETMAXVERSION(@lineage) }) }
		'
		set @cvstr2 = '
				colv1 = { fn UPDATECOLVBM(colv1, @nick, @bm, @missingbm, { fn GETMAXVERSION({ fn UPDATELINEAGE(lineage, @nick, @oldmaxversion+1) }) }) } '
		end
	else
		begin
		set @cvstr1 = '   set @lineage = { fn UPDATELINEAGE(0x0, @nick, @oldmaxversion+1) }
			set @cv = NULL
 	'
		set @cvstr2 = ' colv1 = NULL '
		end
	/* UNDONE maybe remove null guid checks in SQL SERVER 7.0 */
	select @command1 = 'create trigger ' + @trigname + ' on ' + @source_table +
	' FOR UPDATE AS '

	if (@notforrepl_bit = 1)
		select @command1 = @command1 + @notforrepl_str

	select @command1 = @command1 + ' 
	/* Declare variables */

	declare @article_rows_updated int
	select @article_rows_updated = count(*) from inserted
	declare @contents_rows_updated int, @updateerror int
	declare @bm varbinary(500), @missingbm varbinary(500), @lineage varbinary(255), @cv varbinary(2048)
	declare @tablenick int, @nick int, @ccols int, @partchange int, @joinchange int
	declare	@partchangebm varbinary(500), @joinchangebm varbinary(500)
	declare @oldmaxversion int
		
	set nocount on
	set @tablenick = ' + @tablenickchar + '
	select @oldmaxversion= maxversion_at_cleanup from sysmergearticles where nickname = @tablenick
	
	/* Use intrinsic funtion to set bits for updated columns */
	set @bm = columns_updated()

	/* only do the map down when needed */
	set @missingbm = ' 

	select @command2 = '  

	/* See if the partition might have changed */
	if @partchangebm = 0x0
		set @partchange = 0
	else
		set @partchange= { fn INTERSECTBITMAPS (@bm, @partchangebm) }
	
	/* See if a column used in a join filter changed */
	if @joinchangebm = 0x0
		set @joinchange = 0
	else
		set @joinchange= { fn INTERSECTBITMAPS (@bm, @joinchangebm) }
	'

	if @mapdownbm<>0x00
		select @command2 = @command2 + 
				' execute master..xp_mapdown_bitmap ' + @mapdownbmstr +', @bm output '

	select @command2 = @command2 + '

	exec dbo.sp_MSgetreplnick @nickname = @nick output
	select @ccols = ' + @ccolchar + '
	' + @cvstr1 + '
		' 
	set @command3 = '

	update ' + @viewname + ' 
	set lineage = { fn UPDATELINEAGE(lineage, @nick, @oldmaxversion+1) }, 
		generation = A.gen_cur, 
		joinchangegen = case when (@joinchange = 1) then A.gen_cur else joinchangegen end, 
		partchangegen = case when (@partchange = 1) then A.gen_cur else partchangegen end, 
		' + @cvstr2 + ' 
	FROM inserted as I JOIN ' + @viewname + ' as V 
	ON (I.rowguidcol=V.rowguid)
	and V.tablenick = @tablenick
	JOIN (select top 1 nickname, gen_cur = isnull(gen_cur, 0) from sysmergearticles where nickname = @tablenick) as A
	ON V.tablenick = A.nickname

	select @updateerror = @@error, @contents_rows_updated = @@rowcount
	 ' + case when @inscommand is null or @inscommand = ' ' then ' ' else ' if @joinchange = 1 or @partchange = 1 ' + @inscommand end + ' 
	if @article_rows_updated <> @contents_rows_updated
	begin

		insert into ' + @viewname + ' (tablenick, rowguid, lineage, colv1, generation, partchangegen, joinchangegen) 
			select @tablenick, rowguidcol, @lineage, @cv, A.gen_cur, 
			case when (@joinchange = 1 or @partchange = 1) then A.gen_cur else NULL end, 
			case when @joinchange = 1 then A.gen_cur else NULL end
			from inserted,
			(select top 1 nickname, gen_cur = isnull(gen_cur, 0) from sysmergearticles where nickname = @tablenick) as A
			where rowguidcol not in (select rowguid from ' + @viewname + ' where tablenick = @tablenick)

		if @@error <> 0
			GOTO FAILURE
	end

	-- DEBUG	insert into MSmerge_debug (okay,artnick,generation_old,twhen,comment) values
	-- DEBUG		(0, @tablenick, @newgen, getdate(), ''upd_trg'')

	return
FAILURE:
				if @@trancount > 0
					rollback tran
				raiserror (20041, 16, -1)
				return
					'
			
	execute (@command1 + @mapupbmstr + '
		set @partchangebm = ' + @partchstr + '
		set @joinchangebm = ' + @joinchstr + '
			' + @ifcol +  
			@command2 + @command3)
	if @@ERROR <> 0 
		begin
			raiserror(20064, 16, -1)
			return (1)
		end
	
    select @command4 = 'sp_MS_marksystemobject ''' + REPLACE(@owner, '''', '''''') + '.' + @trigname + ''''
	if @owner_is_admin=1
		execute (@command4)		
GO

exec dbo.sp_MS_marksystemobject sp_MSaddupdatetrigger
go
--------------------------------------------------------------------------------
-- sp_MSvalidate_agent_parameter
--------------------------------------------------------------------------------
if exists (select * from sysobjects 
	where name = 'sp_MSvalidate_agent_parameter' and type = 'P')
    drop procedure sp_MSvalidate_agent_parameter
go
raiserror('Creating procedure sp_MSvalidate_agent_parameter', 0,1)
go
create procedure sp_MSvalidate_agent_parameter (
    @profile_id      int,
    @parameter_name  sysname,
    @parameter_value nvarchar(255)
)
as
    declare @agent_type  int
    declare @original_parameter_name sysname
    declare @numeric_value int

    -- Make sure parameters are non-null
    if @profile_id is null
    BEGIN
        RAISERROR (14043, 16, -1, '@profile_id')
        RETURN (1)
    END

    if @parameter_name is null 
    BEGIN
        RAISERROR (14043, 16, -1, '@parameter_name')
        RETURN (1)
    END

    IF @parameter_value is null
    BEGIN
        RAISERROR (14043, 16, -1, '@parameter_value')
        RETURN (1)
    END

    select @original_parameter_name = @parameter_name
    
    select @agent_type = agent_type
    from msdb..MSagent_profiles 
    where profile_id = @profile_id

	-- Parameter name validation
    if (substring(@parameter_name, 1, 1) <> '/' and 
        substring(@parameter_name, 1, 1) <> '-')
    begin
        return 1
    end

    select @parameter_name = lower(substring(@parameter_name, 2, len(@parameter_name) - 1) collate SQL_Latin1_General_CP1_CS_AS)

    -- Snapshot agent - agent_type = 1
    if (@agent_type = 1)
    begin
        if not @parameter_name in ( 
            N'bcpbatchsize',   
            N'historyverboselevel',
            N'logintimeout',
            N'maxbcpthreads',
            N'querytimeout',
            N'startqueuetimeout',
            N'maxnetworkoptimization'
            )    
        begin
            raiserror(21111, 16, -1, @original_parameter_name)
            return 1
        end
    end
    -- Logreader - agent_type = 2
    else if (@agent_type =2)  
    begin
        if not lower(@parameter_name collate SQL_Latin1_General_CP1_CS_AS) in ( 
            N'historyverboselevel',
            N'logintimeout',
            N'pollinginterval',
            N'querytimeout',
            N'readbatchsize'
            )    
        begin
            raiserror(21112, 16, -1, @original_parameter_name)
            return 1
        end
    end
    -- Distribution agent - agent_type = 3
    else if (@agent_type = 3)
    begin
        if not @parameter_name in ( 
            N'bcpbatchsize',   
            N'commitbatchsize',   
            N'commitbatchthreshold',   
            N'historyverboselevel',
            N'logintimeout',
            N'maxbcpthreads',
            N'maxdeliveredtransactions',
            N'pollinginterval',
            N'querytimeout',
            N'transactionsperhistory',
            N'skiperrors',
            N'keepalivemessageinterval',
            N'useinprocloader'            
            )    
        begin
            raiserror(21113, 16, -1, @original_parameter_name)
            return 1
        end
    end
    -- Merge agent - agent_type = 4
    else if (@agent_type = 4)
    begin 
        if not @parameter_name in ( 
            N'startqueuetimeout',
            N'pollinginterval',   
            N'validateinterval',   
            N'logintimeout',   
            N'querytimeout',
            N'maxuploadchanges',
            N'maxdownloadchanges',
            N'uploadgenerationsperbatch',   
            N'downloadgenerationsperbatch',   
            N'uploadreadchangesperbatch',   
            N'downloadreadchangesperbatch',   
            N'uploadwritechangesperbatch',
            N'downloadwritechangesperbatch',
            N'validate',   
            N'fastrowcount',   
            N'historyverboselevel',
            N'changesperhistory',
            N'bcpbatchsize',
            N'numdeadlockretries',
            N'keepalivemessageinterval',
            N'srcthreads',
            N'destthreads',
            N'useinprocloader',
            N'metadataretentioncleanup'
            )    
        begin
            raiserror(21114, 16, -1, @original_parameter_name)
            return 1
        end
    end
    -- Qreader agent - agent_type = 9
    else if (@agent_type = 9)  
    begin
        if not lower(@parameter_name collate SQL_Latin1_General_CP1_CS_AS) in ( 
            N'resolverstate',
            N'sqlqueuemode',
            N'historyverboselevel',
            N'pollinginterval',
            N'logintimeout',
            N'querytimeout'
            )    
        begin
            raiserror(21112, 16, -1, @original_parameter_name)
            return 1
        end
    end
    else if @agent_type is null
    begin
        raiserror (20066, 16, -1)   -- profile not defined
        return 1
    end
    else
    begin
        -- MSagent_parameters table corruption
        return 1
    end

    -- Parameter value validation
    if (@parameter_name = N'bcpbatchsize')
    begin
        select @numeric_value = convert(int, @parameter_value)
        if @@error <> 0 or @numeric_value < 1
        begin
            raiserror(21115, 16, -1, @parameter_value, @original_parameter_name)
            return 1     
        end
    end
    else if (@parameter_name = N'commitbatchsize')
    begin
        select @numeric_value = convert(int, @parameter_value)
        if @@error <> 0 or @numeric_value < 1
        begin
            raiserror(21115, 16, -1, @parameter_value, @original_parameter_name)
            return 1     
        end                        
    end
    else if (@parameter_name = N'commitbatchthreshold')
    begin
        select @numeric_value = convert(int, @parameter_value)
        if @@error <> 0 or @numeric_value < 1
        begin
            raiserror(21115, 16, -1, @parameter_value, @original_parameter_name)
            return 1     
        end                        
    end
    else if (@parameter_name = N'downloadgenerationsperbatch')
    begin
        select @numeric_value = convert(int, @parameter_value)
        if @@error <> 0 or @numeric_value < 1
        begin
            raiserror(21115, 16, -1, @parameter_value, @original_parameter_name)
            return 1     
        end 
		if @numeric_value > 2000
		begin
			raiserror(14266, 16, -1, 'DownloadGenerationsPerBatch', '1 - 2000') 
			return 1
		end                      
    end
    else if (@parameter_name = N'downloadreadchangesperbatch')
    begin
        select @numeric_value = convert(int, @parameter_value)
        if @@error <> 0 or @numeric_value < 1
        begin
            raiserror(21115, 16, -1, @parameter_value, @original_parameter_name)
            return 1     
        end    
		if @numeric_value > 2000
		begin
			raiserror(14266, 16, -1, 'DownloadReadChangesPerBatch', '1 - 2000') 
			return 1
		end                      
    end
    else if (@parameter_name = N'downloadwritechangesperbatch')
    begin
        select @numeric_value = convert(int, @parameter_value)
        if @@error <> 0 or @numeric_value < 1
        begin
            raiserror(21115, 16, -1, @parameter_value, @original_parameter_name)
            return 1     
        end 
		if @numeric_value > 2000
		begin
			raiserror(14266, 16, -1, 'DownloadWriteChangesPerBatch', '1 - 2000') 
			return 1
		end                         
    end
    else if (@parameter_name = N'fastrowcount')
    begin
        select @numeric_value = convert(int, @parameter_value)
        if @@error <> 0 or not (@numeric_value in (1,2,3))
        begin
            raiserror(21116, 16, -1, @parameter_value, @original_parameter_name)
            return 1     
        end                        
    end
    else if (@parameter_name = N'historyverboselevel')
    begin
        select @numeric_value = convert(int, @parameter_value)
        if @@error <> 0 or not (@numeric_value in (0,1,2,3))
        begin
            raiserror(21117, 16, -1, @parameter_value, @original_parameter_name)
            return 1     
        end                        
    end
    else if (@parameter_name = N'logintimeout')
    begin
        select @numeric_value = convert(int, @parameter_value)
        if @@error <> 0 or @numeric_value < 1
        begin
            raiserror(21115, 16, -1, @parameter_value, @original_parameter_name)
            return 1     
        end                        
    end
    else if (@parameter_name = N'maxbcpthreads')
    begin
        select @numeric_value = convert(int, @parameter_value)
        if @@error <> 0 or @numeric_value < 1
        begin
            raiserror(21115, 16, -1, @parameter_value, @original_parameter_name)
            return 1     
        end                        
    end
    else if (@parameter_name = N'maxdeliveredtransactions')
    begin
        select @numeric_value = convert(int, @parameter_value)
        if @@error <> 0 or @numeric_value < 0
        begin
            raiserror(21119, 16, -1, @parameter_value, @original_parameter_name)
            return 1     
        end                        
    end
    else if (@parameter_name = N'pollinginterval')
    begin
        select @numeric_value = convert(int, @parameter_value)
        if @@error <> 0 or @numeric_value < 1
        begin
            raiserror(21115, 16, -1, @parameter_value, @original_parameter_name)
            return 1     
        end                        
    end
    else if (@parameter_name = N'querytimeout')
    begin
        select @numeric_value = convert(int, @parameter_value)
        if @@error <> 0 or @numeric_value < 1
        begin
            raiserror(21115, 16, -1, @parameter_value, @original_parameter_name)
            return 1     
        end                        
    end
    else if (@parameter_name = N'readbatchsize')
    begin
        select @numeric_value = convert(int, @parameter_value)
        if @@error <> 0 or @numeric_value < 1
        begin
            raiserror(21115, 16, -1, @parameter_value, @original_parameter_name)
            return 1     
        end                        
    end
    else if (@parameter_name = N'transactionsperhistory')
    begin
        select @numeric_value = convert(int, @parameter_value)
        if @@error <> 0 or @numeric_value not between 0 and 10000
        begin
            raiserror(211118, 16, -1, @parameter_value, @original_parameter_name)
            return 1     
        end                        
    end
    else if (@parameter_name = N'uploadgenerationsperbatch')
    begin
        select @numeric_value = convert(int, @parameter_value)
        if @@error <> 0 or @numeric_value < 1
        begin
            raiserror(21115, 16, -1, @parameter_value, @original_parameter_name)
            return 1     
        end 
		if @numeric_value > 2000
		begin
			raiserror(14266, 16, -1, 'UploadGenerationsPerBatch', '1 - 2000') 
			return 1
		end                         
    end
    else if (@parameter_name = N'uploadreadchangesperbatch')
    begin
        select @numeric_value = convert(int, @parameter_value)
        if @@error <> 0 or @numeric_value < 1
        begin
            raiserror(21115, 16, -1, @parameter_value, @original_parameter_name)
            return 1     
        end     
		if @numeric_value > 2000
		begin
			raiserror(14266, 16, -1, 'UploadReadChangesPerBatch', '1 - 2000') 
			return 1
		end                     
    end
    else if (@parameter_name = N'uploadwritechangesperbatch')
    begin
        select @numeric_value = convert(int, @parameter_value)
        if @@error <> 0 or @numeric_value < 1
        begin
            raiserror(21115, 16, -1, @parameter_value, @original_parameter_name)
            return 1     
        end 
		if @numeric_value > 2000
		begin
			raiserror(14266, 16, -1, 'UploadWriteChangesPerBatch', '1 - 2000') 
			return 1
		end                         
    end
    else if (@parameter_name = N'validate')
    begin
        select @numeric_value = convert(int, @parameter_value)
        if @@error <> 0 or not (@numeric_value in (0,1,2,3))
        begin
            raiserror(21117, 16, -1, @parameter_value, @original_parameter_name)
            return 1     
        end                        
    end
    else if (@parameter_name = N'validateinterval')
    begin
        select @numeric_value = convert(int, @parameter_value)
        if @@error <> 0 or @numeric_value < 1
        begin
            raiserror(21115, 16, -1, @parameter_value, @original_parameter_name)
            return 1     
        end                        
    end
    else if (@parameter_name = N'skiperrors')
    begin
		-- Empty string is valid.
		if @parameter_value <> N''
		begin
			-- Valid format: 11:22:33
			if	@parameter_value like '%[^0-9:]%' or
				@parameter_value like ':%' or
				@parameter_value like '%:' or
				@parameter_value like '%::%'
			begin
				raiserror(20601, 16, -1)
				return 1
			end
			-- cannot has number of errors equals to or more than 11
			if	@parameter_value like '%:%:%:%:%:%:%:%:%:%:%'
			begin
				raiserror(20602, 16, -1)
				return 1
			end
		end
    end
    -- Parameter value validation
    else if (@parameter_name = N'numdeadlockretries')
    begin
        select @numeric_value = convert(int, @parameter_value)
        if @@error <> 0 or @numeric_value < 1
        begin
            raiserror(21115, 16, -1, @parameter_value, @original_parameter_name)
            return 1     
        end
		if @numeric_value > 100
		begin
			raiserror(14266, 16, -1, 'NumDeadlockRetries', '1 - 100') 
			return 1
		end                         
    end
	else if (@parameter_name = N'srcthreads')
    begin
        select @numeric_value = convert(int, @parameter_value)
        if @@error <> 0 or @numeric_value < 1
        begin
            raiserror(21115, 16, -1, @parameter_value, @original_parameter_name)
            return 1     
        end                        
    end
	else if (@parameter_name = N'destthreads')
    begin
        select @numeric_value = convert(int, @parameter_value)
        if @@error <> 0 or @numeric_value < 1
        begin
            raiserror(21115, 16, -1, @parameter_value, @original_parameter_name)
            return 1     
        end                        
    end
    else if (@parameter_name = N'keepalivemessageinterval')
    begin
        select @numeric_value = convert(int, @parameter_value)
        if @@error <> 0 or @numeric_value < 30
        begin
            raiserror(21405, 16, -1, @parameter_value, @original_parameter_name, 30)            
            return 1
        end
    end
    else if (@parameter_name = N'useinprocloader')
    begin
        select @numeric_value = convert(int, @parameter_value)
        if @@error <> 0 or @numeric_value not in (0, 1) or rtrim(@parameter_value) = N''
        begin
            raiserror(21406, 16, -1, @parameter_value, @original_parameter_name)
            return 1
        end
    end
    else if (@parameter_name = N'startqueuetimeout')
    begin
        select @numeric_value = convert(int, @parameter_value)
        if @@error <> 0 or (@numeric_value < 300 and @numeric_value <> 0) or rtrim(@parameter_value) = N''
        begin
            raiserror(21404, 16, -1, @parameter_value, @original_parameter_name)
            return 1
        end
    end
    else if (@parameter_name = N'resolverstate')
    begin
        select @numeric_value = convert(int, @parameter_value)
        if @@error <> 0 or @numeric_value not in (1,2,3)
        begin
            raiserror(21115, 16, -1, @parameter_value, @original_parameter_name)
            return 1     
        end                        
    end
    else if (@parameter_name = N'sqlqueuemode')
    begin
        select @numeric_value = convert(int, @parameter_value)
        if @@error <> 0 or @numeric_value not in (0,1,2)
        begin
            raiserror(21115, 16, -1, @parameter_value, @original_parameter_name)
            return 1     
        end                        
    end
    else if (@parameter_name = N'maxnetworkoptimization')
    begin
        select @numeric_value = convert(int, @parameter_value)
        if @@error <> 0 or @numeric_value not in (0, 1) or rtrim(@parameter_value) = N''
        begin
            raiserror(21406, 16, -1, @parameter_value, @original_parameter_name)
            return 1
        end
    end
    
    return 0
go 
EXEC dbo.sp_MS_marksystemobject 'sp_MSvalidate_agent_parameter'
go

SET ANSI_NULLS OFF
GO

-------------------------------------------------------------------------------
-- END OF FILE: Turn off marking of system objects.
--	DO NOT ADD ANYTHING AFTER THIS POINT
-------------------------------------------------------------------------------
exec sp_MS_upd_sysobj_category 2
go

exec sp_configure 'allow updates',0
go

reconfigure with override
go





