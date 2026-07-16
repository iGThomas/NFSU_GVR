/*
** replcom.sql            1997/02/12 22:03
**
**
** Copyright Microsoft, Inc. 1998-2000
** All Rights Reserved.
*/


dump tran master with no_log
go

exec dbo.sp_configure 'update',1
go
reconfigure with override
go

set ANSI_NULLS off
go

use master
go

exec dbo.sp_MS_upd_sysobj_category 1 --Capture time for use at the end
go


dump tran master with no_log
GO

/* 
** Drop the stored procedures in this script using the old dropping SP 
** and then drop itself
*/
if exists (select * from sysobjects
    where type = 'P'
            and name = 'sp_MSdrop_replcom')
begin
    drop procedure sp_MSdrop_replcom
end

/*
** Create stored procedures to drop the stored procedures
** created by this script
*/

raiserror('Creating procedure sp_MSdrop_replcom', 0,1)
GO

create procedure sp_MSdrop_replcom
as
    if exists (select * from sysobjects 
        where type = 'P'
            and name = 'sp_MScreate_distributor_tables')
        drop procedure sp_MScreate_distributor_tables

    if exists (select * from sysobjects
        where type = 'P'
                and name = 'sp_MSIfExistsRemoteLogin')
        drop procedure sp_MSIfExistsRemoteLogin

    if exists (select * from sysobjects
        where type = 'P'
                and name = 'sp_helppublicationsync')
        drop procedure sp_helppublicationsync

    if exists (select * from sysobjects
            where type = 'P'
                and name = 'sp_addpublication_snapshot')
        drop procedure sp_addpublication_snapshot

    if exists (select * from sysobjects
            where type = 'P'
                and name = 'sp_MShelpobjectpublications')
        drop procedure sp_MShelpobjectpublications

    if exists (select * from sysobjects
            where type = 'P'
                and name = 'sp_addpublisher')
        drop procedure sp_addpublisher

    if exists (select * from sysobjects
            where type = 'P'
                and name = 'sp_addsubscriber')
        drop procedure sp_addsubscriber

    if exists (select * from sysobjects
            where type = 'P'
                and name = 'sp_addsubscriber_schedule')
        drop procedure sp_addsubscriber_schedule

    if exists (select * from sysobjects
            where type = 'P'
                and name = 'sp_changesubscriber_schedule')
        drop procedure sp_changesubscriber_schedule

    if exists (select * from sysobjects
            where type = 'P'
                and name = 'sp_changesubscriber')
        drop procedure sp_changesubscriber

    IF EXISTS (SELECT * FROM sysobjects
            WHERE type = 'P'
                AND name = 'sp_MScreate_dist_tables')
        DROP PROCEDURE sp_MScreate_dist_tables

	IF EXISTS (SELECT * FROM sysobjects
			WHERE type = 'P'
				AND name = 'sp_MSupdate_mqserver_distdb')
		DROP PROCEDURE sp_MSupdate_mqserver_distdb

    if exists (select * from sysobjects
            where type = 'P'
                and name = 'sp_distcounters')
        drop procedure sp_distcounters


    if exists (select * from sysobjects
            where type = 'P'
                and name = 'sp_droppublisher')
        drop procedure sp_droppublisher

    if exists (select * from sysobjects
            where type = 'P'
                and name = 'sp_dropsubscriber')
        drop procedure sp_dropsubscriber

    if exists (select * from sysobjects
            where type = 'P'
                and name = 'sp_dsninfo')
        drop procedure sp_dsninfo

    if exists (select * from sysobjects
            where type = 'P'
                and name = 'sp_enumdsn')
        drop procedure sp_enumdsn

    if exists (select * from sysobjects
            where type = 'P'
                and name = 'sp_helpdistributor')
        drop procedure sp_helpdistributor

    if exists (select * from sysobjects
            where type = 'P'
                and name = 'sp_helppublicationsync')    /* Remove old version */
        drop procedure sp_helppublicationsync

    if exists (select * from sysobjects
            where type = 'P'
                and name = 'sp_helpreplicationdb')
        drop procedure sp_helpreplicationdb

    if exists (select * from sysobjects
            where type = 'P'
                and name = 'sp_helpsubscriberinfo')
        drop procedure sp_helpsubscriberinfo

    if exists (select * from sysobjects
            where type = 'P'
                and name = 'sp_publishdb')
        drop procedure sp_publishdb

    if exists (select * from sysobjects
            where type = 'P'
                and name = 'sp_replica')
        drop procedure sp_replica

    if exists (select * from sysobjects
            where type = 'P'
                and name = 'sp_adddistributiondb')
        drop procedure sp_adddistributiondb

    if exists (select * from sysobjects
            where type = 'P'
                and name = 'sp_changedistributiondb')
        drop procedure sp_changedistributiondb

    if exists (select * from sysobjects
            where type = 'P'
                and name = 'sp_helpdistributiondb')
        drop procedure sp_helpdistributiondb

    if exists (select * from sysobjects
            where type = 'P'
                and name = 'sp_dropdistributiondb')
        drop procedure sp_dropdistributiondb

    if exists (select * from sysobjects
            where type = 'P'
                and name = 'sp_adddistpublisher')
        drop procedure sp_adddistpublisher

    if exists (select * from sysobjects
            where type = 'P'
                and name = 'sp_changedistpublisher')
        drop procedure sp_changedistpublisher

    if exists (select * from sysobjects
            where type = 'P'
                and name = 'sp_helpdistpublisher')
        drop procedure sp_helpdistpublisher

    if exists (select * from sysobjects
            where type = 'P'
                and name = 'sp_dropdistpublisher')
        drop procedure sp_dropdistpublisher

    if exists (select * from sysobjects
            where type = 'P'
                and name = 'sp_MSadd_distributor_alerts_and_responses')
        drop procedure  sp_MSadd_distributor_alerts_and_responses

    if exists (select * from sysobjects
            where type = 'P'
                and name = 'sp_MSdrop_distributor_alerts_and_responses')
        drop procedure  sp_MSdrop_distributor_alerts_and_responses

    if exists (select * from sysobjects
            where type = 'P'
                and name = 'sp_adddistributor')
        drop procedure  sp_adddistributor

    if exists (select * from sysobjects
            where type = 'P'
                and name = 'sp_dropdistributor')
        drop procedure sp_dropdistributor

    if exists (select * from sysobjects
            where type = 'P'
                and name = 'sp_changedistributor_property')
        drop procedure sp_changedistributor_property

    if exists (select * from sysobjects
            where type = 'P'
                and name = 'sp_helpdistributor_properties')
        drop procedure sp_helpdistributor_properties

    if exists (select * from sysobjects
            where type = 'X'
                and name = 'sp_repldone')
        exec dbo.sp_dropextendedproc 'sp_repldone'

    if exists (select * from sysobjects
            where type = 'X'
                and name = 'sp_repltrans')
        exec dbo.sp_dropextendedproc 'sp_repltrans'

    if exists (select * from sysobjects
            where type = 'X'
                and name = 'sp_replcmds')
        exec dbo.sp_dropextendedproc 'sp_replcmds'

    if exists (select * from sysobjects
            where type = 'X'
                and name = 'sp_replcounters')
        exec dbo.sp_dropextendedproc 'sp_replcounters'

    if exists (select * from sysobjects
            where type = 'X'
                and name = 'sp_replflush')
        exec dbo.sp_dropextendedproc 'sp_replflush'

    if exists (select * from sysobjects
            where type = 'X'
                 and name = 'sp_replpostcmd' )
        exec dbo.sp_dropextendedproc 'sp_replpostcmd'

    if exists (select * from sysobjects
            where type = 'X'
                 and name = 'sp_replpostschema' )
        exec dbo.sp_dropextendedproc 'sp_replpostschema'

    if exists (select * from sysobjects
            where type = 'X'
                 and name = 'sp_replincrementlsn' )
        exec dbo.sp_dropextendedproc 'sp_replincrementlsn'

    if exists (select * from sysobjects
            where type = 'P'
                 and name = 'sp_replincrementlsn' )
        drop procedure sp_replincrementlsn

    if exists (select * from sysobjects
            where type = 'X'
                 and name = 'sp_replincrementlsn_internal' )
        exec dbo.sp_dropextendedproc 'sp_replincrementlsn_internal'

    if exists (select * from sysobjects
            where type = 'X'
                 and name = 'sp_replupdateschema' )
        exec dbo.sp_dropextendedproc 'sp_replupdateschema'

    if exists (select * from sysobjects
            where type = 'X'
                 and name = 'sp_replsetoriginator_internal' )
        exec dbo.sp_dropextendedproc 'sp_replsetoriginator_internal'

    if exists (select * from sysobjects
            where type = 'X'
                 and name = 'sp_replsetoriginator' )
        exec dbo.sp_dropextendedproc 'sp_replsetoriginator'

    if exists (select * from sysobjects
            where type = 'P'
                 and name = 'sp_replsetoriginator' )
        drop procedure sp_replsetoriginator

    if exists (select * from sysobjects
            where type = 'P'
                 and name = 'sp_replsetoriginator_pal' )
        drop procedure sp_replsetoriginator_pal

    if exists (select * from sysobjects
            where type = 'X'
                 and name = 'sp_replsetsyncstatus' )
        exec dbo.sp_dropextendedproc 'sp_replsetsyncstatus'

    if exists (select * from sysobjects
            where type = 'X'
                 and name = 'sp_replpostsyncstatus' )
        exec dbo.sp_dropextendedproc 'sp_replpostsyncstatus'

    if exists (select * from sysobjects
            where type = 'P'
                 and name = 'sp_replpostsyncstatus' )
        drop procedure sp_replpostsyncstatus

    if exists (select * from sysobjects
            where type = 'X'
                 and name = 'sp_replpostsyncstatus_int' )
        exec dbo.sp_dropextendedproc 'sp_replpostsyncstatus_int'

    if exists (select * from sysobjects
            where type = 'X'
                and name = 'xp_enumdsn')
        exec dbo.sp_dropextendedproc 'xp_enumdsn'

    if exists (select * from sysobjects
            where type = 'X'
                and name = 'xp_oledbinfo')
        exec dbo.sp_dropextendedproc 'xp_oledbinfo'

    if exists (select * from sysobjects
            where type = 'X'
                and name = 'xp_dsninfo')
        exec dbo.sp_dropextendedproc 'xp_dsninfo'

    if exists (select * from sysobjects
            where type = 'X'
                and name = 'xp_repl_encrypt')
        exec dbo.sp_dropextendedproc 'xp_repl_encrypt'

    if exists (select * from sysobjects
            where type = 'X'
                and name = 'xp_repl_convert_encrypt')
        exec dbo.sp_dropextendedproc 'xp_repl_convert_encrypt'

    if exists (select * from sysobjects
            where type = 'X'
                and name = 'xp_repl_help_connect')
        exec dbo.sp_dropextendedproc 'xp_repl_help_connect'

     if exists (select * from sysobjects
            where type = 'X'
                and name = 'xp_replproberemsrv')
        exec dbo.sp_dropextendedproc 'xp_replproberemsrv'

    -- sp_helpsubscriber is removed permanently from the system.
    if exists (select * from sysobjects
        where type = 'P'
                and name = 'sp_helpsubscriber')
        drop procedure sp_helpsubscriber

	-- sp_MSrepl_encrypt obsolete; use xp_repl_encrypt
    if exists (select * from sysobjects
        where type = 'P'
                and name = 'sp_MSrepl_encrypt')
        drop procedure sp_MSrepl_encrypt

    if exists (select * from sysobjects 
        where name = 'sp_add_agent_profile' 
                and type = 'P')
        drop procedure sp_add_agent_profile

    if exists (select * from sysobjects 
        where name = 'sp_help_agent_profile' 
                and type = 'P')
        drop procedure sp_help_agent_profile

    if exists (select * from sysobjects 
        where name = 'sp_help_agent_default' 
            and type = 'P')
        drop procedure sp_help_agent_default

    if exists (select * from sysobjects 
        where name = 'sp_drop_agent_profile' 
                and type = 'P')
        drop procedure sp_drop_agent_profile

    if exists (select name from sysobjects 
        where name = 'sp_MSupdate_agenttype_default'
                and type = 'P')
        drop procedure sp_MSupdate_agenttype_default

    if exists (select * from sysobjects 
        where name = 'sp_MSvalidate_agent_parameter' 
                and type = 'P')
        drop procedure sp_MSvalidate_agent_parameter

    if exists (select * from sysobjects 
        where name = 'sp_add_agent_parameter' 
                and type = 'P')
        drop procedure sp_add_agent_parameter

    if exists (select * from sysobjects 
        where name = 'sp_generate_agent_parameter' 
                and type = 'P')
        drop procedure sp_generate_agent_parameter

    if exists (select * from sysobjects 
        where name = 'sp_change_agent_parameter' 
                and type = 'P')
        drop procedure sp_change_agent_parameter

    if exists (select * from sysobjects 
        where name = 'sp_change_agent_profile' 
                and type = 'P')
        drop procedure sp_change_agent_profile

    if exists (select * from sysobjects 
        where name = 'sp_help_agent_parameter' 
                and type = 'P')
      drop procedure sp_help_agent_parameter

    if exists (select * from sysobjects 
        where name = 'sp_drop_agent_parameter' 
                and type = 'P')
      drop procedure sp_drop_agent_parameter

    if exists (select * from sysobjects 
        where name = 'sp_MShelp_distdb' 
                and type = 'P')
      drop procedure sp_MShelp_distdb

    if exists (select * from sysobjects 
        where name = 'sp_MShelp_distdb' 
                and type = 'P')
      drop procedure sp_MShelp_distdb

    if exists (select * from sysobjects 
        where name = 'sp_MSenum_misc_agents'
                and type = 'P')
      drop procedure sp_MSenum_misc_agents

    if exists (select * from sysobjects 
        where name = 'sp_MSupdate_replication_status' 
                and type = 'P')
      drop procedure sp_MSupdate_replication_status

    if exists (select * from sysobjects 
        where name = 'sp_MSload_replication_status' 
                and type = 'P')
      drop procedure sp_MSload_replication_status

    if exists (select * from sysobjects 
        where name = 'sp_MScreate_replication_status_table' 
                and type = 'P')
      drop procedure sp_MScreate_replication_status_table

    if exists (select * from sysobjects 
        where name = 'sp_MShelp_replication_status' 
                and type = 'P')
      drop procedure sp_MShelp_replication_status

    if exists (select * from sysobjects 
        where name = 'sp_MSenum_replication_agents' 
                and type = 'P')
      drop procedure sp_MSenum_replication_agents

    if exists (select * from sysobjects 
        where name = 'sp_replication_agent_checkup' 
                and type = 'P')
      drop procedure sp_replication_agent_checkup

    if exists (select * from sysobjects 
        where name = 'sp_MSreplrole' 
                and type = 'P')
      drop procedure sp_MSreplrole

    if exists (select * from sysobjects 
        where name = 'sp_MScreate_replication_checkup_agent' 
                and type = 'P')
      drop procedure sp_MScreate_replication_checkup_agent

    if exists (select * from sysobjects 
        where name = 'sp_MSenum_replication_job' 
                and type = 'P')
      drop procedure sp_MSenum_replication_job

    if exists (select * from sysobjects 
        where name = 'sp_MSrepl_dbrole' 
                and type = 'P')
      drop procedure sp_MSrepl_dbrole

    if exists (select * from sysobjects
        where type = 'P'
                and name = 'sp_oledbinfo')
        drop procedure sp_oledbinfo

    if exists (select * from sysobjects
        where type = 'P'
                and name = 'sp_enumoledbdatasources')
        drop procedure sp_enumoledbdatasources

    if exists (select * from sysobjects
        where type = 'P'
                and name = 'sp_MSget_oledbinfo')
        drop procedure sp_MSget_oledbinfo

    if exists (select * from sysobjects 
        where name = 'sp_changedistributor_password' 
                and type = 'P')
      drop procedure sp_changedistributor_password

    if exists (select * from sysobjects 
        where name = 'sp_grant_publication_access' 
                and type = 'P')
      drop procedure sp_grant_publication_access

    if exists (select * from sysobjects 
        where name = 'sp_revoke_publication_access' 
                and type = 'P')
      drop procedure sp_revoke_publication_access

    if exists (select * from sysobjects 
        where name = 'sp_help_publication_access' 
                and type = 'P')
      drop procedure sp_help_publication_access

    if exists (select * from sysobjects 
        where name = 'sp_check_publication_access' 
                and type = 'P')
      drop procedure sp_check_publication_access

    if exists (select * from sysobjects 
        where name = 'sp_MSinit_replication_perfmon' 
                and type = 'P')
      drop procedure sp_MSinit_replication_perfmon

    if exists (select * from sysobjects 
        where name = 'sp_MSrepl_startup' 
                and type = 'P')
      drop procedure sp_MSrepl_startup

    if exists (select * from sysobjects 
        where name = 'sp_MSflush_access_cache' 
                and type = 'P')
      drop procedure sp_MSflush_access_cache

    if exists (select * from sysobjects 
        where name = 'sp_MSreinit_failed_subscriptions' 
                and type = 'P')
      drop procedure sp_MSreinit_failed_subscriptions

    if exists (select * from sysobjects 
        where name = 'sp_add_datatype_mapping' 
                and type = 'P')
        drop procedure sp_add_datatype_mapping
    
    if exists (select * from sysobjects 
        where name = 'sp_help_datatype_mapping' 
                and type = 'P')
        drop procedure sp_help_datatype_mapping

	if exists (select * from sysobjects 
        where name = 'sp_MSrepl_gettype_mappings' 
                and type = 'P')
        drop procedure sp_MSrepl_gettype_mappings
		
    if exists (select * from sysobjects 
        where name = 'sp_MSfix_6x_tasks' 
                and type = 'P')
        drop procedure sp_MSfix_6x_tasks

    if exists (select * from sysobjects 
        where name = 'sp_MSget_agent_names' 
                and type = 'P')
        drop procedure sp_MSget_agent_names

	-- Common conflict viewer support procs
    if exists (select * from sysobjects
            where type = 'P'
                and name = 'sp_MShelpconflictpublications')
        drop procedure sp_MShelpconflictpublications

    -- Procs for managing dynamic snapshot views
    if exists (select * from sysobjects
            where type = 'P'
                and name = 'sp_MScleanupdynsnapshotvws')
        drop procedure sp_MScleanupdynsnapshotvws

    if exists (select * from sysobjects
            where type = 'P'
                and name = 'sp_MScleanupmergepublisher')
        drop procedure sp_MScleanupmergepublisher

    if exists (select * from sysobjects
            where type = 'P'
                and name = 'sp_MScleanupmergepublisherdb')
        drop procedure sp_MScleanupmergepublisherdb
    
    if exists (select * from sysobjects
            where type = 'P'
                and name = 'sp_MShelp_replication_table')
        drop procedure sp_MShelp_replication_table
    if exists (select * from sysobjects
            where type = 'P'
                and name = 'sp_MScopyscriptfile')
        drop procedure sp_MScopyscriptfile

    if exists (select * from sysobjects
            where type = 'FN'
                and name = 'fn_replgetagentcommandlinefromjobid')
        drop function system_function_schema.fn_replgetagentcommandlinefromjobid
    
    if exists (select * from sysobjects
            where type = 'P'
                and name = 'sp_replproberemoteserver')
        drop procedure sp_replproberemoteserver
        
    if exists (select * from sysobjects
            where type = 'FN'
                and name = 'fn_getpersistedservernamecasevariation'
                and user_id('system_function_schema') = uid)
        drop function system_function_schema.fn_getpersistedservernamecasevariation

GO

/* 
**  We must execute dbo.sp_MSdrop_replcom here since sp_MSdrop_replcom may not exist
**  before this script is applied and it is possible
**  that some replication sps are left. (We ignore error when dropping
**  the replication so it is possible sp_MSdrop_replcom is dropped but
**  some replication sps were left).
*/
exec dbo.sp_MSdrop_replcom
go

raiserror('Creating procedure sp_MScreate_distributor_tables', 0,1)
GO

create procedure sp_MScreate_distributor_tables
as
    declare @profile_id     int
    declare @retcode    int
    declare @profile_name nvarchar(100)
    declare @profile_desc nvarchar(100)

    /* Create MSpublishers table */
    IF EXISTS (SELECT * FROM msdb..sysobjects WHERE name = 'MSdistpublishers'
        and xtype = 'U')
    begin
        DROP TABLE msdb..MSdistpublishers
        if @@error<> 0 goto FAILURE
    end

    /* Create MSdistributiondbs table */
    IF EXISTS (SELECT * FROM msdb..sysobjects WHERE name = 'MSdistributiondbs'
        and xtype = 'U')
    begin
        DROP TABLE msdb..MSdistributiondbs
        if @@error<> 0 goto FAILURE
    end

    /* create MSdistributor table */
    IF EXISTS (SELECT * FROM msdb..sysobjects WHERE name = 'MSdistributor'
        and xtype = 'U')
    begin
        DROP TABLE msdb..MSdistributor
        if @@error<> 0 goto FAILURE
    end

    /* create sysreplicationalerts table */
    IF EXISTS (SELECT * FROM msdb..sysobjects WHERE name = 'sysreplicationalerts'
        and xtype = 'U')
    begin
        DROP TABLE msdb..sysreplicationalerts
        if @@error<> 0 goto FAILURE
    end
    
    /* create MSagent_profiles table */
    IF EXISTS (SELECT * FROM msdb..sysobjects WHERE name = 'MSagent_profiles'
        and xtype = 'U')
    begin
        DROP TABLE msdb..MSagent_profiles
        if @@error<> 0 goto FAILURE
    end

    /* create MSagent_parameters table */
    IF EXISTS (SELECT * FROM msdb..sysobjects WHERE name = 'MSagent_parameters' 
        and xtype = 'U')
    begin
        DROP TABLE msdb..MSagent_parameters
        if @@error<> 0 goto FAILURE
    end

    /* create MSdatatype_mappings table */
    IF EXISTS (SELECT * FROM msdb..sysobjects WHERE name = 'MSdatatype_mappings' 
        and xtype = 'U')
    begin
        DROP TABLE msdb..MSdatatype_mappings
        if @@error<> 0 goto FAILURE
    end

    
    CREATE TABLE msdb.dbo.MSdistpublishers
    (
        name                sysname     NOT NULL,
        distribution_db     sysname     NOT NULL,
        working_directory   nvarchar(255) NOT NULL,
        security_mode       int         NOT NULL,
        login               sysname     NOT NULL,
        password            nvarchar(524) NULL,
        active              bit         NOT NULL,
        trusted             bit         NOT NULL,
        thirdparty_flag     bit         NOT NULL
    )
    if @@error<> 0 goto FAILURE

	CREATE UNIQUE CLUSTERED INDEX uc1MSdistpublishers 
		ON msdb.dbo.MSdistpublishers(name)
	if @@error<> 0 goto FAILURE

	exec msdb.dbo.sp_MS_marksystemobject MSdistpublishers

    CREATE TABLE msdb.dbo.MSdistributiondbs
    (
        name            sysname     NOT NULL,
        min_distretention   int     NOT NULL,
        max_distretention   int     NOT NULL,
        history_retention   int     NOT NULL
    )
    if @@error<> 0 goto FAILURE

	CREATE UNIQUE CLUSTERED INDEX uc1MSdistributiondbs 
			ON msdb.dbo.MSdistributiondbs(name)
	if @@error<> 0 goto FAILURE

	exec msdb.dbo.sp_MS_marksystemobject MSdistributiondbs


    CREATE TABLE msdb.dbo.MSdistributor 
    ( 
        property        sysname     NOT NULL, 
        value           nvarchar(3000)  NULL
    )
    if @@error<> 0 goto FAILURE
	
	CREATE UNIQUE CLUSTERED INDEX uc1MSdistributor 
			ON msdb.dbo.MSdistributor(property)
	if @@error<> 0 goto FAILURE
	exec msdb.dbo.sp_MS_marksystemobject MSdistributor

    CREATE TABLE msdb.dbo.sysreplicationalerts
    (
        alert_id            int identity(1,1) NOT NULL,
        status              int NOT NULL,
        agent_type          int NULL,
        agent_id            int NULL,
        error_id            int NULL,
        alert_error_code    int NULL,
        time                datetime NOT NULL,
        publisher           sysname NULL,
        publisher_db        sysname NULL,
        publication         sysname NULL,
        publication_type    int NULL,
        subscriber          sysname NULL,
        subscriber_db       sysname NULL,
        article             sysname NULL,
        destination_object  sysname NULL,
        source_object       sysname NULL,
        alert_error_text    ntext NULL
    )
    if @@error<> 0 goto FAILURE

    CREATE UNIQUE CLUSTERED INDEX ucsysreplicationalerts ON msdb.dbo.sysreplicationalerts(alert_id)
    if @@error<> 0 goto FAILURE
	exec msdb.dbo.sp_MS_marksystemobject sysreplicationalerts

    CREATE TABLE msdb.dbo.MSagent_profiles
    (
        profile_id    int           NOT NULL IDENTITY,
        profile_name  sysname       NOT NULL,
        agent_type          int             NOT NULL, -- 1-Snapshot, 2-Logreader,
                                                      -- 3-Distribution, 4-Merge,
                                                      -- 9-Qreader
        type                int             NOT NULL, -- 0-System, 1-Custom
        description         nvarchar(3000)  NULL,
        def_profile   bit               NOT NULL
    )
    if @@error<> 0 goto FAILURE


    CREATE UNIQUE CLUSTERED INDEX ucMSagent_profiles ON msdb.dbo.MSagent_profiles
        (profile_name, profile_id, agent_type)
    if @@error<> 0 goto FAILURE
	exec msdb.dbo.sp_MS_marksystemobject MSagent_profiles

    CREATE TABLE msdb.dbo.MSagent_parameters
    (
        profile_id     int          NOT NULL,
        parameter_name       sysname        NOT NULL,
        value                nvarchar(255)  NOT NULL
    )
    if @@error<> 0 goto FAILURE

    CREATE UNIQUE CLUSTERED INDEX ucMSagent_parameters ON msdb.dbo.MSagent_parameters
        (parameter_name, profile_id)
    if @@error<> 0 goto FAILURE
	
	exec msdb.dbo.sp_MS_marksystemobject MSagent_parameters
    /* 
	** Create default / non default profiles 
	** for all the agents 
	*/

    /* 
	** Snapshot agent 
	*/
    set @profile_id = NULL
    set @profile_name = formatmessage(20545) -- Default Snapshot Profile
    set @profile_desc = NULL

    exec @retcode = dbo.sp_add_agent_profile
            @profile_id = @profile_id OUT,
            @profile_name = @profile_name,
            @agent_type = 1,   -- 1-Snapshot, 2-Logreader, 3-Distribution, 4-Merge
            @profile_type = 0,   -- 0-System, 1-Custom 
            @description = @profile_desc,
            @default = 1
    if (@retcode = 1 or @@ERROR <> 0)
        goto FAILURE

	exec @retcode = dbo.sp_generate_agent_parameter @profile_id
    if (@retcode = 1 or @@ERROR <> 0)
        goto FAILURE

    /* 
	** Logreader agent 
	*/
    set @profile_id = NULL
    set @profile_name = formatmessage(20545) -- Default LogReader Profile
    set @profile_desc = NULL

    exec @retcode = dbo.sp_add_agent_profile
            @profile_id = @profile_id OUT,
            @profile_name = @profile_name,
            @agent_type = 2,   -- 1-Snapshot, 2-Logreader, 3-Distribution, 4-Merge
            @profile_type = 0,   -- 0-System, 1-Custom 
            @description = @profile_desc,
            @default = 1
    if (@retcode = 1 or @@ERROR <> 0)
        goto FAILURE

    exec @retcode = dbo.sp_generate_agent_parameter @profile_id
    if (@retcode = 1 or @@ERROR <> 0)
        goto FAILURE

    /* 
	** Logreader agent - Verbose History Profile
	*/
    set @profile_id = NULL
    set @profile_name = formatmessage(20546) -- LogReader Verbose History Profile
    set @profile_desc = formatmessage(20547)

    exec @retcode = dbo.sp_add_agent_profile
            @profile_id = @profile_id OUT,
            @profile_name = @profile_name,
            @agent_type = 2,   -- 1-Snapshot, 2-Logreader, 3-Distribution, 4-Merge
            @profile_type = 0,   -- 0-System, 1-Custom 
            @description = @profile_desc,
            @default = 0
    if (@retcode = 1 or @@ERROR <> 0)
        goto FAILURE

    exec @retcode = dbo.sp_generate_agent_parameter @profile_id
    if (@retcode = 1 or @@ERROR <> 0)
        goto FAILURE

    /* 
	** Distribution agent 
	*/
    set @profile_id = NULL
    set @profile_name = formatmessage(20545) -- Default Distribution Profile
    set @profile_desc = NULL

    exec @retcode = dbo.sp_add_agent_profile
            @profile_id = @profile_id OUT,
            @profile_name = @profile_name,
            @agent_type = 3,   -- 1-Snapshot, 2-Logreader, 3-Distribution, 4-Merge
            @profile_type = 0,   -- 0-System, 1-Custom 
            @description = @profile_desc,
            @default = 1
    if (@retcode = 1 or @@ERROR <> 0)
        goto FAILURE

    exec @retcode = dbo.sp_generate_agent_parameter @profile_id
    if (@retcode = 1 or @@ERROR <> 0)
        goto FAILURE

    /*
	** Distribution Agent Verbose History Profile
	*/
    set @profile_id = NULL
    set @profile_name = formatmessage(20546) -- Distribution Verbose History Profile
    set @profile_desc = formatmessage(20547)

    exec @retcode = dbo.sp_add_agent_profile
            @profile_id = @profile_id OUT,
            @profile_name = @profile_name,
            @agent_type = 3,   -- 1-Snapshot, 2-Logreader, 3-Distribution, 4-Merge
            @profile_type = 0,   -- 0-System, 1-Custom 
            @description = @profile_desc,
            @default = 0
    if (@retcode = 1 or @@ERROR <> 0)
        goto FAILURE

    exec @retcode = dbo.sp_generate_agent_parameter @profile_id
    if (@retcode = 1 or @@ERROR <> 0)
        goto FAILURE
 
    /* 
	** Merge agent : Default profile for well connected scenarios 
	*/
    set @profile_id = NULL
    set @profile_name = formatmessage(20545) -- Default Merge Profile
    set @profile_desc = NULL

    exec @retcode = dbo.sp_add_agent_profile
            @profile_id = @profile_id OUT,
            @profile_name = @profile_name,
            @agent_type = 4,   -- 1-Snapshot, 2-Logreader, 3-Distribution, 4-Merge
            @profile_type = 0,   -- 0-System, 1-Custom 
            @description = @profile_desc,
            @default = 1

    if (@retcode = 1 or @@ERROR <> 0)
        goto FAILURE

    exec @retcode = dbo.sp_generate_agent_parameter @profile_id
    if (@retcode = 1 or @@ERROR <> 0)
        goto FAILURE

    /* 
	** Merge agent : Non default profile for disconnected scenarios ( unreliable link ) 
	*/
    set @profile_id = NULL
    set @profile_name = formatmessage(20548) -- Non-Default Merge Profile
    set @profile_desc = formatmessage(20549)

    exec @retcode = dbo.sp_add_agent_profile
            @profile_id = @profile_id OUT,
            @profile_name = @profile_name,
            @agent_type = 4,   -- 1-Snapshot, 2-Logreader, 3-Distribution, 4-Merge
            @profile_type = 0,   -- 0-System, 1-Custom 
            @description = @profile_desc,
            @default = 0

    if (@retcode = 1 or @@ERROR <> 0)
        goto FAILURE

    exec @retcode = dbo.sp_generate_agent_parameter @profile_id
    if (@retcode = 1 or @@ERROR <> 0)
        goto FAILURE

    /* 
	** Merge agent : Non default profile for verbose histroy
	*/
    set @profile_id = NULL
    set @profile_name = formatmessage(20546) -- Verbose Merge Profile
    set @profile_desc = formatmessage(20547)

    exec @retcode = dbo.sp_add_agent_profile
            @profile_id = @profile_id OUT,
            @profile_name = @profile_name,
            @agent_type = 4,   -- 1-Snapshot, 2-Logreader, 3-Distribution, 4-Merge
            @profile_type = 0,   -- 0-System, 1-Custom 
            @description = @profile_desc,
            @default = 0

    if (@retcode = 1 or @@ERROR <> 0)
        goto FAILURE

    exec @retcode = dbo.sp_generate_agent_parameter @profile_id
    if (@retcode = 1 or @@ERROR <> 0)
        goto FAILURE

    /* 
	** Merge agent : Synchronization Manager Profile
	*/
    set @profile_id = NULL
    set @profile_name = formatmessage(20550) -- SyncMgr Profile
    set @profile_desc = formatmessage(20551)

    exec @retcode = dbo.sp_add_agent_profile
            @profile_id = @profile_id OUT,
            @profile_name = @profile_name,
            @agent_type = 4,   -- 1-Snapshot, 2-Logreader, 3-Distribution, 4-Merge
            @profile_type = 0,   -- 0-System, 1-Custom 
            @description = @profile_desc,
            @default = 0

    if (@retcode = 1 or @@ERROR <> 0)
        goto FAILURE

    exec @retcode = dbo.sp_generate_agent_parameter @profile_id
    if (@retcode = 1 or @@ERROR <> 0)
        goto FAILURE

    /* 
	** Distribution agent : Synchronization Manager Profile
	*/
    set @profile_id = NULL
    set @profile_name = formatmessage(20550) -- SyncMgr Profile
    set @profile_desc = formatmessage(20551)

    exec @retcode = dbo.sp_add_agent_profile
            @profile_id = @profile_id OUT,
            @profile_name = @profile_name,
            @agent_type = 3,   -- 1-Snapshot, 2-Logreader, 3-Distribution, 4-Merge
            @profile_type = 0,   -- 0-System, 1-Custom 
            @description = @profile_desc,
            @default = 0

    if (@retcode = 1 or @@ERROR <> 0)
        goto FAILURE

    exec @retcode = dbo.sp_generate_agent_parameter @profile_id
    if (@retcode = 1 or @@ERROR <> 0)
        goto FAILURE

	/* 
	** Qreader agent (default profile)
	*/
	set @profile_id = NULL
	set @profile_name = formatmessage(20545) -- Default QueueReader Profile
    set @profile_desc = formatmessage(20589)

	exec @retcode = dbo.sp_add_agent_profile
			@profile_id = @profile_id OUT,
			@profile_name = @profile_name,
			@agent_type = 9,
			@profile_type = 0, 
			@description = @profile_desc,
			@default = 1
	if (@retcode = 1 or @@ERROR <> 0)
		goto FAILURE

	exec @retcode = dbo.sp_generate_agent_parameter @profile_id
	if (@retcode = 1 or @@ERROR <> 0)
		goto FAILURE

    /* 
	** Merge agent : Rowcount Validation profile  
	*/
    set @profile_id = NULL
    set @profile_name = formatmessage(21308) -- Rowcount Validation Profile
    set @profile_desc = formatmessage(21309) -- Rowcount Validation Profile Description

    exec @retcode = dbo.sp_add_agent_profile
            @profile_id = @profile_id OUT,
            @profile_name = @profile_name,
            @agent_type = 4,   -- 1-Snapshot, 2-Logreader, 3-Distribution, 4-Merge
            @profile_type = 0,   -- 0-System, 1-Custom 
            @description = @profile_desc,
            @default = 0

    if (@retcode = 1 or @@ERROR <> 0)
        goto FAILURE

    exec @retcode = dbo.sp_generate_agent_parameter @profile_id
    if (@retcode = 1 or @@ERROR <> 0)
        goto FAILURE

    /* 
	** Merge agent : Rowcount & Checksum Validation profile  
	*/
    set @profile_id = NULL
    set @profile_name = formatmessage(21310) -- Rowcount & Checksum Validation Profile
    set @profile_desc = formatmessage(21311) -- Rowcount & Checksum Validation Profile Description

    exec @retcode = dbo.sp_add_agent_profile
            @profile_id = @profile_id OUT,
            @profile_name = @profile_name,
            @agent_type = 4,   -- 1-Snapshot, 2-Logreader, 3-Distribution, 4-Merge
            @profile_type = 0,   -- 0-System, 1-Custom 
            @description = @profile_desc,
            @default = 0

    if (@retcode = 1 or @@ERROR <> 0)
        goto FAILURE

    exec @retcode = dbo.sp_generate_agent_parameter @profile_id
    if (@retcode = 1 or @@ERROR <> 0)
        goto FAILURE


    /* 
	** Distribution agent, skip error profile
	*/
    set @profile_id = NULL
    set @profile_name = formatmessage(20599) -- Default Distribution Profile
    set @profile_desc = formatmessage(20600)

    exec @retcode = dbo.sp_add_agent_profile
            @profile_id = @profile_id OUT,
            @profile_name = @profile_name,
            @agent_type = 3,   -- 1-Snapshot, 2-Logreader, 3-Distribution, 4-Merge
            @profile_type = 0,   -- 0-System, 1-Custom 
            @description = @profile_desc,
            @default = 0
    if (@retcode = 1 or @@ERROR <> 0)
        goto FAILURE

    exec @retcode = dbo.sp_generate_agent_parameter @profile_id
    if (@retcode = 1 or @@ERROR <> 0)
        goto FAILURE

	/* 
	** Merge agent : High volume server-to-server profile
	*/
    set @profile_id = NULL
    set @profile_name = formatmessage(20616) -- High volume server-to-server profile
    set @profile_desc = formatmessage(20617) -- High volume server-to-server profile Description

    exec @retcode = dbo.sp_add_agent_profile
            @profile_id = @profile_id OUT,
            @profile_name = @profile_name,
            @agent_type = 4,   -- 1-Snapshot, 2-Logreader, 3-Distribution, 4-Merge
            @profile_type = 0,   -- 0-System, 1-Custom 
            @description = @profile_desc,
            @default = 0

    if (@retcode = 1 or @@ERROR <> 0)
        goto FAILURE

    exec @retcode = dbo.sp_generate_agent_parameter @profile_id
    if (@retcode = 1 or @@ERROR <> 0)
        goto FAILURE

    create table msdb.dbo.MSdatatype_mappings 
    (
    dbms_name           sysname NOT NULL,
    sql_type            sysname NOT NULL,
    dest_type           sysname NOT NULL,
    dest_prec           int     NOT NULL,
    dest_create_params  int     NOT NULL,
    dest_nullable       bit     NOT NULL
    )
	exec msdb.dbo.sp_MS_marksystemobject MSdatatype_mappings
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
	exec dbo.sp_add_datatype_mapping 'DB2/400', 'tinyint', 'SMALLINT', 3, 0, 1
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
	exec dbo.sp_add_datatype_mapping 'DB2/MVS', 'tinyint', 'SMALLINT', 3, 0, 1
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
	exec dbo.sp_add_datatype_mapping 'DB2/NT', 'tinyint', 'SMALLINT', 3, 0, 1
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
	exec dbo.sp_add_datatype_mapping 'DB2/6000', 'tinyint', 'SMALLINT', 3, 0, 1
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

    return 0
FAILURE:
    return 1
go

dump tran master with no_log
GO

/*
** Create replication stored procedures and functions.
** Part 2:  create all other stored procedures and functions.
*/
--
-- Name: fn_getpersistedservernamecasevariation
--
-- Description: A simple function for getting the case variation of a
--              server name as persisted in master..sysservers. For
--              example, if sErVeRnAmE is what is being persisted 
--              as a srvname in sysservers
--
--              select fn_getpersistedservernamecasevariation('SERVERNAME')
--              select fn_getpersistedservernamecasevariation('servername')
--            
--              will all return the string 'sErVeRnAmE'                
--
-- Parameter: @servername sysname (mandatory)
--
-- Notes: This function will return null if the specified server name
--        does not match any srvname's in master..sysservers in a
--        case insensitive manner.
--
-- Security: Admin access only
-- 
raiserror('Creating function fn_getpersistedservernamecasevariation', 0,1)
go
create function system_function_schema.fn_getpersistedservernamecasevariation (
    @servername sysname
    ) returns sysname
as
begin

    declare @real_servername sysname
    select @real_servername = null
    select @real_servername = srvname 
      from master.dbo.sysservers
     where upper(@servername) = upper(srvname) collate database_default 

    return @real_servername
end
go

raiserror('Creating procedure sp_MSIfExistsRemoteLogin', 0,1)
GO

CREATE proc sp_MSIfExistsRemoteLogin
    @remotesrvname sysname,
    @locallgname   sysname,
    @remotelgname  sysname
AS
begin


    if (@locallgname IS NULL)
    begin
     IF EXISTS (SELECT * FROM master.dbo.sysremotelogins srl, master.dbo.sysservers ss
                 WHERE UPPER(ss.srvname) = UPPER(@remotesrvname) collate database_default AND 
                       srl.remoteserverid = ss.srvid AND 
                       (srl.remoteusername = @remotelgname OR 
                       (srl.remoteusername IS NULL AND srl.sid = 0x2)))
        return (1)
    else
        return (0)
    end

    if exists (SELECT * FROM master.dbo.sysremotelogins srl, master.dbo.sysservers ss 
                                WHERE UPPER(ss.srvname) = UPPER(@remotesrvname) collate database_default AND 
                                      srl.remoteserverid = ss.srvid AND 
                                      srl.remoteusername = @remotelgname AND 
                                      srl.sid = suser_sid(@locallgname))
        return (1)
    else
        return (0)
end
go

raiserror('Creating procedure sp_helppublicationsync', 0,1)
GO

CREATE PROCEDURE sp_helppublicationsync (
        @publication sysname    /* The publication name */
        ) AS
    SET NOCOUNT ON
    RAISERROR (21023, 16, -1,'sp_helppublicationsync')
    RETURN(1)
GO

raiserror('Creating procedure sp_MSreplrole', 0,1)
GO
create procedure sp_MSreplrole
@name sysname,
@operation nvarchar(4)
as
declare @retcode int
-- Add/Drop when proper.
if @operation = 'add'
begin
    if user_id(@name) is null
    begin
        exec @retcode = dbo.sp_addrole @name
        IF @@ERROR <> 0 or @retcode <> 0
            RETURN (1)
    end
end
else if @operation = 'drop' 
begin
    if user_id(@name) is not null
    begin
        exec @retcode = dbo.sp_droprole @name
        IF @@ERROR <> 0 or @retcode <> 0
            RETURN (1)
    end
end
go

dump tran master with no_log
GO

raiserror('Creating procedure sp_addpublication_snapshot', 0,1)
GO

CREATE PROCEDURE sp_addpublication_snapshot (
    @publication sysname,    
    @frequency_type  int = 4 ,              /* 4== Daily */
    @frequency_interval int = 1,            /* Every day */
    @frequency_subday int = 4,              /* Sub interval = Minute */
    @frequency_subday_interval int = 5,     /* Every five minutes */
    @frequency_relative_interval int = 1, 
    @frequency_recurrence_factor int = 0, 
    @active_start_date int = 0, 
    @active_end_date int = 99991231 , 
    @active_start_time_of_day int = 0, 
    @active_end_time_of_day int = 235959,
    @snapshot_job_name nvarchar(100) = NULL         
) AS

    SET NOCOUNT ON

    /*
    ** Declarations.
    */
    DECLARE @retcode                int
    DECLARE @newid                  int
    DECLARE @mergepublish_bit       smallint
    DECLARE @transpublish_bit       int
    DECLARE @transpub_found         bit
    DECLARE @mergepub_found         bit
    DECLARE @newagentid             int

    /*
    ** Initializations
    */
    select @mergepublish_bit    = 4
    select @transpublish_bit    = 1
    select @transpub_found      = 0
    select @mergepub_found      = 0
    
	/*
	** Parameter Check
	*/
	exec @retcode = dbo.sp_MSreplcheck_name @publication
    if @@ERROR <> 0 or @retcode <> 0
        return(1)

    /*
    ** Security Check
    */
    exec @retcode = dbo.sp_MSreplcheck_publish
    if @@ERROR <> 0 or @retcode <> 0
        return(1)

    /*
    **  Check if the publication is valid.
    **  1. Check transaction-level publications
    **  2. Check merge publications
    */
    if (select category & @transpublish_bit from master..sysdatabases where name = DB_NAME() collate database_default) <> 0
    begin
        EXEC @retcode = dbo.sp_MSaddpub_snapshot     @publication ,    
            @frequency_type,  
            @frequency_interval, 
            @frequency_subday, 
            @frequency_subday_interval,
            @frequency_relative_interval, 
            @frequency_recurrence_factor, 
            @active_start_date, 
            @active_end_date, 
            @active_start_time_of_day, 
            @active_end_time_of_day,         
            @newagentid OUTPUT,
            @snapshot_job_name 

        IF @retcode <> 0 and @@ERROR <> 0 
            BEGIN
                RETURN (1)
            END

        if @newagentid <> 0
            begin
                select @transpub_found = 1
                goto DONE
            end             

    end
    
    if (select category & @mergepublish_bit from master..sysdatabases where name = DB_NAME() collate database_default) <> 0
    begin
        EXEC @retcode = dbo.sp_MSaddmergepub_snapshot     @publication ,    
            @frequency_type,  
            @frequency_interval, 
            @frequency_subday, 
            @frequency_subday_interval,
            @frequency_relative_interval, 
            @frequency_recurrence_factor, 
            @active_start_date, 
            @active_end_date, 
            @active_start_time_of_day, 
            @active_end_time_of_day,         
            @newagentid OUTPUT,
            @snapshot_job_name

        IF @retcode <> 0 and @@ERROR <> 0 
            BEGIN
                RETURN (1)
            END

        if @newagentid <> 0
            begin
                select @mergepub_found = 1
                goto DONE
            end             
    end

DONE:
    if @transpub_found = 0 and @mergepub_found = 0
    begin
        RAISERROR (15001, 11, -1, @publication)
        RETURN (1)
    end
    return (0)        
GO
 
raiserror('Creating procedure sp_MShelpobjectpublications', 0,1)
GO

create procedure sp_MShelpobjectpublications (@object_name sysname)
AS
    /*
    ** Declarations.
    */
    DECLARE @retcode                int
    DECLARE @mergepublish_bit       smallint
    DECLARE @transpublish_bit       int

    declare @object_id int

    /*
    ** Initializations
    */
    select @mergepublish_bit    = 4
    select @transpublish_bit    = 1
    select @object_id           = OBJECT_ID(@object_name)

    create table #helpobjpubs (
        publication     sysname     	collate database_default not null, 
        reptype         int             NOT NULL, 
        article         sysname     	collate database_default not null, 
        article_type    int             NULL, 
        column_tracking int             NULL, 
        article_resolver nvarchar(255)  collate database_default null,
        identity_support int 			NULL, 
        resolver_clsid nvarchar(50)		NULL,
		resolver_info  nvarchar(255)	NULL,
        verify_resolver_signature int 	NULL,
		allow_interactive_resolver bit 	NULL,
        fast_multicol_updateproc bit	NULL,
        check_permissions int			NULL)
    /*
    **  1. Return the transactional publications that the table is involved in
    */
    if (select category & @transpublish_bit from master..sysdatabases where name = DB_NAME() collate database_default) <> 0
    begin
        if exists (select * from sysextendedarticlesview a, 
            syspublications p where a.pubid = p.pubid and a.objid = @object_id)
            begin
                insert into #helpobjpubs(publication, reptype, article, article_type) 
                    select p.name, 1, a.name, a.type  from sysextendedarticlesview a, 
                        syspublications p where a.pubid = p.pubid and a.objid = @object_id
                IF @@ERROR <> 0 
                    BEGIN
                        select @retcode = 1
                        goto DONE
                    END
            end
    end
    /*
    **  2. Return the merge publications that the table is involved in
    */
    if exists (select * from sysobjects where name='sysmergepublications')
    begin
        if exists (select * from sysmergeextendedarticlesview a, 
            sysmergepublications p where a.pubid = p.pubid and a.objid = @object_id)
            begin
                insert into #helpobjpubs (publication, reptype, article, article_type, column_tracking, article_resolver,
                identity_support, resolver_clsid, resolver_info, verify_resolver_signature, allow_interactive_resolver,
                    		fast_multicol_updateproc, check_permissions)
                    select p.name, 2, a.name, a.type, a.column_tracking, a.article_resolver, a.identity_support,
                    		a.resolver_clsid, a.resolver_info, a.verify_resolver_signature, a.allow_interactive_resolver,
                    		a.fast_multicol_updateproc, a.check_permissions
                        from sysmergeextendedarticlesview a, sysmergepublications p 
                        where a.pubid = p.pubid and a.objid = @object_id
                IF @@ERROR <> 0 
                    BEGIN
                        select @retcode = 1
                        goto DONE
                    END
            end
    end
    select @retcode = 0

DONE:
    select * from #helpobjpubs
    drop table #helpobjpubs
    return (@retcode)
go

raiserror('Creating procedure sp_helpreplicationdb', 0,1)
GO

CREATE PROCEDURE sp_helpreplicationdb
        @dbname sysname = '%', @type sysname = 'pub'
    AS

    SET NOCOUNT ON

    /*
    ** Declarations.
    */

    DECLARE @retcode int, @typebit int

    if (lower(@type collate SQL_Latin1_General_CP1_CS_AS) like 'pub%')
       select @typebit = 1
    else if (lower(@type collate SQL_Latin1_General_CP1_CS_AS) like 'sub%')
       select @typebit = 2
    else
    begin
       raiserror(14091,-1,-1)
       return 1
    end

    /*
    ** Parameter Check:  @dbname.
    ** Check to make sure that the database name conforms to the rules
    ** for identifiers.
    */

    IF @dbname <> '%'
       BEGIN
          EXECUTE @retcode = dbo.sp_validname @dbname

          IF @@ERROR <> 0 OR @retcode <> 0
          RETURN (1)
       END

    /*
    ** Show databases with this option enabled.
    */

    SELECT name
      FROM master..sysdatabases
     WHERE ((@dbname = N'%') or (name = @dbname collate database_default)) 
       AND (category & @typebit) <> 0
go
 

raiserror('Creating procedure sp_helpdistributor', 0,1)
go

CREATE PROCEDURE sp_helpdistributor (
    @distributor sysname  = '%' OUTPUT, /* The distribution server name */
    @distribdb   sysname  = '%' OUTPUT, /* The distribution database */
    @directory   nvarchar(255) = '%' OUTPUT, /* The working directory */
    @account     nvarchar(255) = '%' OUTPUT, /* The Windows NT user account */
    @min_distretention int      = -1 OUTPUT, /* The min distribution retention */
    @max_distretention int      = -1 OUTPUT, /* The min distribution retention */
    @history_retention   int  = -1 OUTPUT, /* The history retention period */
    @history_cleanupagent nvarchar(100) = '%' OUTPUT, /* The history cleanup agent */
    @distrib_cleanupagent nvarchar(100) = '%' OUTPUT, /* The distribution cleanup agent */
    @publisher sysname = NULL,  /* Name of publisher */
    @local nvarchar(5) = NULL,        /* Get local server values */
    @rpcsrvname sysname = '%' OUTPUT
) AS
    SET NOCOUNT ON

    /*
    ** Declarations.
    */
    DECLARE @loc_distributor         sysname
    DECLARE @loc_distribdb             sysname
    DECLARE @loc_directory             nvarchar(255)
    DECLARE @loc_account             nvarchar(255)
    DECLARE @loc_mindistretention     int
    DECLARE @loc_maxdistretention     int
    DECLARE @loc_historyretention   int  
    DECLARE @loc_historycleanupagent nvarchar(100)
    DECLARE @loc_distribcleanupagent nvarchar(100)
    DECLARE @loc_security_mode  int  
    DECLARE @loc_login sysname
    DECLARE @loc_password sysname
    declare @loc_rpcsrvname sysname
    DECLARE @proc nvarchar(255)
    DECLARE @reg_key nvarchar (255)
    DECLARE @retcode int
    declare @rpcsrvlogin sysname
    declare @srvid smallint
    declare @dist_rpcname sysname
    declare @platform_nt binary

    select @platform_nt = 0x1

    IF @publisher IS NULL
    BEGIN
        /* 
        ** 6.x compatibility 
        ** If local is set, we know the call is from a publisher. 
        ** set it to be @@REMSERVER 
        ** Otherwise, set it to be local server name
        ** Note: @@REMSERVER is NULL for local sp calls 
        */
        IF LOWER(@local) = 'local' AND @@REMSERVER IS NOT NULL
            SELECT @publisher = @@REMSERVER
        ELSE
            SELECT  @publisher = @@SERVERNAME
    END

    /*
    ** Get the distribution server
    */
    SELECT @dist_rpcname = srvname, @loc_distributor = datasource, @srvid = srvid, @loc_rpcsrvname = srvname
        FROM master..sysservers
        WHERE srvstatus & 8 <> 0
    
    if @loc_distributor is null
        GOTO DONE

    select @rpcsrvlogin = name from master.dbo.sysxlogins where
        srvid = @srvid and sid is NULL

    /*
    ** If remote distribuiton, execute dbo.sp_helpdistributor on distribution
    ** server.
    */
    IF UPPER(@loc_distributor) <> UPPER(@@SERVERNAME)
    BEGIN
        SELECT @proc = @dist_rpcname + '.master.dbo.sp_helpdistributor'
        EXECUTE @retcode = @proc
            @loc_distributor OUTPUT,
            @loc_distribdb OUTPUT,
            @loc_directory OUTPUT,
            @loc_account OUTPUT,
            @loc_mindistretention OUTPUT,
            @loc_maxdistretention OUTPUT,
            @loc_historyretention OUTPUT,
            @loc_historycleanupagent OUTPUT,
            @loc_distribcleanupagent OUTPUT,
            @@SERVERNAME,
            @local = 'local'
        IF @retcode <> 0 or @@ERROR <> 0
           RETURN (1)

            GOTO DONE
    END

    SELECT  @loc_distribdb = distribution_db,
            @loc_directory = working_directory
        FROM msdb.dbo.MSdistpublishers WHERE UPPER(name) = UPPER(@publisher) collate database_default

    IF @@ERROR <> 0
        RETURN 1 ;

    SELECT  @loc_mindistretention = min_distretention,      
            @loc_maxdistretention = max_distretention,
            @loc_historyretention = history_retention
        FROM msdb.dbo.MSdistributiondbs WHERE name = @loc_distribdb collate database_default 

    /*
    ** Fetch the distribution account name.
    */
    IF ((@distributor = '%' AND @distribdb = '%' AND @directory = '%'
    AND @account = '%' AND @min_distretention = -1 AND @max_distretention = -1 
    AND @history_retention = -1 AND @history_cleanupagent = '%' 
    AND @distrib_cleanupagent = '%' ) 
    OR @account IS NULL) and ( platform() & @platform_nt = @platform_nt ) 
       BEGIN

		declare @instance sysname
		declare @regkey nvarchar(260)
		select @instance = convert(sysname, SERVERPROPERTY('InstanceName'))
		select @regkey = 'SYSTEM\CurrentControlSet\Services\'
		-- default installation
		if @instance is null
			SELECT @regkey = @regkey + 'SQLServerAgent' 
		else
			SELECT @regkey = @regkey + 'SQLAgent$' + @instance

        SELECT @proc = 'master..xp_regread'
        EXECUTE @retcode = @proc 'HKEY_LOCAL_MACHINE',
              @regkey,
              'ObjectName',
            @param = @loc_account OUTPUT
    
        IF @@ERROR <> 0 OR @retcode <> 0
            SELECT @loc_account = NULL
       END

    /*
    ** Fetch the history cleanup agentname.
    */
    IF @loc_distribdb IS NOT NULL
        SELECT @loc_historycleanupagent = formatmessage (20567, @loc_distribdb)

    /*
    ** Fetch the distribution cleanup agent name.
    */
    IF @loc_distribdb IS NOT NULL
        SELECT @loc_distribcleanupagent = formatmessage (20568, @loc_distribdb)


DONE:
    /*
    ** Return result set if no output parameters
    */

    IF @distributor = '%' AND @distribdb = '%' AND @directory = '%'
    AND @account = '%' AND @min_distretention = -1 AND @max_distretention = -1 
    AND @history_retention = -1 AND @history_cleanupagent = '%' 
    AND @distrib_cleanupagent = '%' AND @rpcsrvname = '%' 
    SELECT       'distributor'           = @loc_distributor,
               'distribution database' = @loc_distribdb,
               'directory'              = @loc_directory,
               'account'               = @loc_account,
               'min distrib retention' = @loc_mindistretention,
               'max distrib retention' = @loc_maxdistretention,
               'history retention'     = @loc_historyretention,
               'history cleanup agent'  = @loc_historycleanupagent,
               'distribution cleanup agent' = @loc_distribcleanupagent,
               'rpc server name' = @loc_rpcsrvname,
               'rpc login name' = @rpcsrvlogin

    /*
    ** Return output parameters if requested.
    */

    IF @distributor IS NULL
        SELECT @distributor = @loc_distributor
    IF @distribdb IS NULL
        SELECT @distribdb = @loc_distribdb
    IF @directory IS NULL
        SELECT @directory = @loc_directory
    IF @account IS NULL
        SELECT @account = @loc_account
    IF @min_distretention IS NULL
        SELECT @min_distretention = @loc_mindistretention
    IF @max_distretention IS NULL
        SELECT @max_distretention = @loc_maxdistretention
    IF @history_retention IS NULL
        SELECT @history_retention = @loc_historyretention
    IF @history_cleanupagent IS NULL
        SELECT @history_cleanupagent = @loc_historycleanupagent
    IF @distrib_cleanupagent IS NULL
        SELECT @distrib_cleanupagent = @loc_distribcleanupagent
   
    IF @rpcsrvname IS NULL
    begin
        -- Use local RPC if possible to avoid blocking problem.
        if is_srvrolemember('sysadmin') = 1 and UPPER(@loc_distributor) = UPPER(@@servername)
            select @rpcsrvname = @@servername
        else
            select @rpcsrvname = @loc_rpcsrvname
    end
  
    RETURN (0)
GO
 
dump tran master with no_log
go

raiserror('Creating procedure sp_enumdsn', 0,1)
GO

CREATE PROCEDURE sp_enumdsn
    AS

    if 1 <> is_srvrolemember('sysadmin')
    begin
    	raiserror(15247,-1,-1)
    	return 1
	end

    SET NOCOUNT ON

    DECLARE @distributor sysname
    DECLARE @distproc nvarchar (300)
    DECLARE @retcode int

    DECLARE @dsotype_odbc int
    DECLARE @dsotype_oledb int

    select @dsotype_odbc = 1
    select @dsotype_oledb = 3

    /*
    ** Get distribution server information for remote RPC
    ** subscription calls.
    */

    EXEC @retcode = dbo.sp_helpdistributor @rpcsrvname = @distributor OUTPUT
    IF @@error <> 0 OR @retcode <> 0 or @distributor is null
        BEGIN
        RAISERROR (14071, 16, -1)
            RETURN (1)
    END

    create table #datasourcestemptable (DataSourceName sysname collate database_default not null, Description nvarchar(255) collate database_default null, DataSourceType int null, ProviderName nvarchar(255) collate database_default null)
    
    /*
    ** Call xp_enumdsn
    */
    SELECT @distproc = RTRIM(@distributor) + '.master..xp_enumdsn'
    insert into #datasourcestemptable(DataSourceName, Description) EXEC @retcode = @distproc
    IF @@error <> 0
        BEGIN
        RAISERROR (14071, 16, -1)
        RETURN (1)
    END

    update #datasourcestemptable set DataSourceType = @dsotype_odbc where DataSourceType is null
    IF @@error <> 0 
    BEGIN
        RETURN (1)
    END

    /*
    ** Call sp_enumoledbdatasources
    */
    SELECT @distproc = RTRIM(@distributor) + '.master.dbo.sp_enumoledbdatasources'
    insert into #datasourcestemptable(DataSourceName, Description, ProviderName) EXEC @retcode = @distproc
    IF @@error <> 0
        BEGIN
        RAISERROR (14071, 16, -1)
        RETURN (1)
    END

    update #datasourcestemptable set DataSourceType = @dsotype_oledb where DataSourceType is null
    IF @@error <> 0 
    BEGIN
        RETURN (1)
    END
    
    select 'Data Source Name' = DataSourceName, Description, 'Type' = DataSourceType, 'Provider Name' = ProviderName 
    from #datasourcestemptable
    order by 3, 1

    drop table #datasourcestemptable

    return (0)
go

raiserror('Creating procedure sp_enumoledbdatasources', 0,1)
GO

CREATE PROCEDURE sp_enumoledbdatasources
    AS
    set nocount on

    select srvname, srvproduct, providername from master..sysservers where 
    (srvstatus & 0x0080) <> 0

    return (0)
go

raiserror('Creating procedure sp_helpsubscriberinfo', 0,1)
GO

CREATE PROCEDURE sp_helpsubscriberinfo
    @subscriber sysname = '%'
    AS

    SET NOCOUNT ON

    DECLARE @distributor sysname
    DECLARE @distribdb sysname
    DECLARE @distproc nvarchar (300)
    DECLARE @retcode int
    DECLARE @subscriber_bit smallint
    DECLARE @show_password bit

    /*
    ** Security Check
    */

    /*
    ** Initializations.
    */
    SELECT @subscriber_bit = 4


    /*
    ** Check if subscriber is valid
    */

    IF @subscriber IS NULL
        BEGIN
            RAISERROR (14043, 16, -1, '@subscriber')
            RETURN (1)
        END


    IF @subscriber <> '%'
        BEGIN

            EXECUTE @retcode = dbo.sp_validname @subscriber
            IF @retcode <> 0
                RETURN (1)

            IF NOT EXISTS (SELECT *
                        FROM master..sysservers
                        WHERE UPPER(srvname) = UPPER(@subscriber) collate database_default
                        AND (srvstatus & @subscriber_bit) <> 0)
                BEGIN
                    RAISERROR (14010, 16, -1)
                    RETURN (1)
                END
        END


    /*
    ** Get distribution server information for remote RPC
    ** subscription calls.
    */

    EXEC @retcode = dbo.sp_helpdistributor @rpcsrvname = @distributor OUTPUT,
                                       @distribdb   = @distribdb OUTPUT

    /* RAISEERROR is subscriber is not '%' */                                               
    IF @@error <> 0 OR @retcode <> 0 OR @distribdb IS NULL OR @distributor IS NULL
        BEGIN
        IF @subscriber <> '%'
            BEGIN
                RAISERROR (14071, 16, -1)
                RETURN (1)
            END
        ELSE
            RETURN 0
        END

     create table #subscriber_info
     (
        publisher  sysname collate database_default not null,
        subscriber  sysname collate database_default not null,
        type tinyint not null,           /* 0: MS SQL Server 1: ODBC Data Source */
        login sysname collate database_default null, 
        password nvarchar(524) NULL,
        commit_batch_size int not null,  -- commit_batch_size, no longer supported
        status_batch_size int not null,  -- status_batch_size, no longer supported
        flush_frequency int not null,  -- flush_frequency, no longer supported
        frequency_type int not null,
        frequency_interval int not null,
        frequency_relative_interval int not null,
        frequency_recurrence_factor int not null,
        frequency_subday int not null,
        frequency_subday_interval int not null,
        active_start_time_of_day int not null,
        active_end_time_of_day int not null,
        active_start_date int not null,
        active_end_date int not null,
        retryattempt    int not null, -- retryattempt, no longer exist
        retrydelay  int not null,  -- retrydelay, no longer exist
        description nvarchar(255) collate database_default null,
        security_mode int not null,
        frequency_type2 int not null,
        frequency_interval2 int not null,
        frequency_relative_interval2 int not null,
        frequency_recurrence_factor2 int not null,
        frequency_subday2 int not null,
        frequency_subday_interval2 int not null,
        active_start_time_of_day2 int not null,
        active_end_time_of_day2 int not null,
        active_start_date2 int not null,
        active_end_date2 int not null
    )

    IF @@error <> 0
        RETURN (1)
     
    /*
    ** Retrieve MSsubscriber_info
    */
    if is_srvrolemember('sysadmin') = 1
        select @show_password = 1
    else
        select @show_password = 0

    SELECT @distproc = RTRIM(@distributor) + '.' +
        RTRIM(@distribdb) + '.dbo.sp_MShelp_subscriber_info'

    insert into #subscriber_info EXEC @retcode = @distproc 
        @publisher = @@SERVERNAME, 
        @subscriber = @subscriber,
        @show_password = @show_password

    IF @@error <> 0
        BEGIN
        RAISERROR (14071, 16, -1)
        RETURN (1)
    END

    IF @retcode <> 0
        BEGIN
        RAISERROR (14085, 16, -1)
        RETURN (1)
     END

    -- Filter out subscribers that are not defined locally but left at the distributor
    -- This will happen if the publisher is cleaned up when the distributor is offline.
    select info.* from #subscriber_info info, master..sysservers servers where
        UPPER(info.subscriber) = UPPER(servers.srvname) collate database_default and
        (servers.srvstatus & @subscriber_bit) <> 0

go
 
raiserror('Creating procedure sp_replica', 0,1)
GO

CREATE PROCEDURE sp_replica (
        @tabname nvarchar(92),     /* The table being replicated */
        @replicated nvarchar(5)    /* True or false */
        ) AS

    SET NOCOUNT ON
    RAISERROR (21023, 16, -1,'sp_replica')
    RETURN(1)
go
 

dump tran master with no_log
go

raiserror('Creating procedure sp_addpublisher', 0,1)
GO

CREATE PROCEDURE sp_addpublisher (
    @publisher sysname,      /* publisher server name */
    @type nvarchar (5) = NULL     /* NULL or 'dist' */
 ) AS

    SET NOCOUNT ON
    RAISERROR (21023, 16, -1,'sp_addpublisher')
    RETURN(1)
go
 
raiserror('Creating procedure sp_addsubscriber', 0,1)
GO

CREATE PROCEDURE sp_addsubscriber (
    @subscriber sysname,
    @type tinyint = 0,
    @login sysname = 'sa',
    @password sysname = NULL,
    @commit_batch_size int = 100,
    @status_batch_size int = 100,
    @flush_frequency int = 0,
    @frequency_type int = 64,
    @frequency_interval int = 1,
    @frequency_relative_interval int = 1,
    @frequency_recurrence_factor int = 0,
    @frequency_subday int = 4,
    @frequency_subday_interval int = 5,
    @active_start_time_of_day int = 0,
    @active_end_time_of_day int = 235959,
    @active_start_date int = 0,
    @active_end_date int = 99991231,
    @description nvarchar (255) = NULL,
    @security_mode int = 1,  /* backward compatible */ /* 0 standard; 1 integrated */
    @encrypted_password bit = 0
        ) AS

    DECLARE @distributor sysname
    DECLARE @distribdb sysname
    DECLARE @distproc nvarchar (300)
    DECLARE @retcode int
    DECLARE @dsn_subscriber tinyint
    DECLARE @jet_subscriber tinyint
    DECLARE @oledb_subscriber tinyint
    DECLARE @dist_rpcname sysname
    DECLARE @platform_nt binary

    -- Defined in sqlrepl.h
    select @dsn_subscriber = 1    /* Const: subscriber type 'dsn' */ 
    select @jet_subscriber = 2   
    select @oledb_subscriber = 3  
    
    select @platform_nt = 0x1

    /* 
    ** Check if replication components are installed on this server
    */
    exec @retcode = dbo.sp_MS_replication_installed
    if (@retcode <> 1)
    begin
        return (1)
    end
    
    /*
    ** Parameter Check:  @subscriber.
    ** Check to make sure that the subscriber doesn't already exist, and
    ** that the name is a valid non-null identifier.
    */

    IF @subscriber IS NULL
        BEGIN
            RAISERROR (14043, 16, -1, '@subscriber')
            RETURN (1)
        END

    EXECUTE @retcode = dbo.sp_validname @subscriber

    IF @@ERROR <> 0 OR @retcode <> 0
    RETURN (1)

    if LOWER(@subscriber) = 'all'
        BEGIN
            RAISERROR (14032, 16, -1, '@subscriber')
            RETURN (1)
        END

    /* 
    ** Check for invalid security mode
    */
    IF @security_mode < 0 OR @security_mode > 1
        BEGIN
            RAISERROR(14109, 16, -1)
            RETURN (1)
        END

    IF (UPPER(@subscriber) = UPPER(@@SERVERNAME) and @platform_nt != ( platform() & @platform_nt ) and @security_mode = 1)
        BEGIN
            RAISERROR(21038, 16, -1)
            RETURN (1)
        END

    IF EXISTS (SELECT *
                 FROM master..sysservers
                WHERE UPPER(srvname) = UPPER(@subscriber) collate database_default
                  AND srvstatus & 4 <> 0)

        BEGIN
            RAISERROR (14040, 16, -1, @subscriber)
            RETURN (1)
        END

	IF @password = N''
		select @password = NULL

    
    /*
    **  If no MSsubscriber_info parameters skip RPC code.
    */

    IF @frequency_type = -1
        GOTO ADDSUB

    /*
    ** Get distribution server information for remote RPC
    ** subscription calls.
    */

 /*   BEGIN TRAN addsubscriber */

    EXEC @retcode = dbo.sp_helpdistributor  @distributor = @distributor OUTPUT,
                                        @rpcsrvname = @dist_rpcname OUTPUT,
                                        @distribdb   = @distribdb   OUTPUT

    IF @@error <> 0
        BEGIN
         RAISERROR (14071, 16, -1)
         goto undo
     END

    IF @retcode <> 0 OR @distribdb IS NULL OR @distributor IS NULL
        BEGIN
            RAISERROR (14071, 16, -1)
            goto undo
        END


    DECLARE @zeroint int
    SELECT @zeroint = 0
    /*
    ** Insert information into MSsubscriber_info
    */
    SELECT @distproc = RTRIM(@dist_rpcname) + '.' + RTRIM(@distribdb) + '.dbo.sp_MSadd_subscriber_info'
    EXEC @retcode = @distproc
         @@SERVERNAME,
         @subscriber,
     @type,
     @login,
     @password,
     @commit_batch_size,
     @status_batch_size,
     @flush_frequency,
     @frequency_type,
     @frequency_interval,
     @frequency_relative_interval,
     @frequency_recurrence_factor,
     @frequency_subday,
     @frequency_subday_interval,
     @active_start_time_of_day,
     @active_end_time_of_day,
     @active_start_date,
     @active_end_date,
     /* Work around of server RPC  named parameter problem */
     @retryattempts = @zeroint,
     @retrydelay  = @zeroint,
     @description = @description,
     @security_mode = @security_mode,
     @encrypted_password = @encrypted_password

    IF @@error <> 0 OR @retcode <> 0
        BEGIN
        RAISERROR (14042, 16, -1)
        goto undo
    END

    /*
    ** add schedule information into MSsubscriber_schedule for merge agent
    */
    -- NOTE: We may need better default schedule for merge agent
    
    SELECT @distproc = RTRIM(@dist_rpcname) + '.' + RTRIM(@distribdb) + '.dbo.sp_MSadd_subscriber_schedule'
    EXEC @retcode = @distproc
         @@SERVERNAME,
         @subscriber,
         0, -- agent_type = 0 means distribution agent
         @frequency_type,
         @frequency_interval,
         @frequency_relative_interval,
         @frequency_recurrence_factor,
         @frequency_subday,
         @frequency_subday_interval,
         @active_start_time_of_day,
         @active_end_time_of_day,
         @active_start_date,
         @active_end_date
    
    IF @@error <> 0 OR @retcode <> 0
        BEGIN
            RAISERROR (14042, 16, -1)
            goto undo
        END

    EXEC @retcode = @distproc
         @@SERVERNAME,
         @subscriber,
         1,             --agent_type = 0 means merge agent
         4,             --frequency_type,
         1,             --frequency_interval,
         1,             --frequency_relative_interval,
         0,             --frequency_recurrence_factor,
         8,             --frequency_subday,
         1,             --frequency_subday_interval,
         0,             --active_start_time_of_day,
         235959,        --active_end_time_of_day,
         0,             --active_start_date,
         99991231       --active_end_date
    
    IF @@error <> 0 OR @retcode <> 0
        BEGIN
            RAISERROR (14042, 16, -1)
            goto undo
        END

/*    Commit Transaction addsubscriber */

ADDSUB:

    /*
    ** The server may already be listed in master..sysservers, but might
    ** not be marked as a subscriber yet.  If it's not in
    ** master..sysservers, let's add it first.
    */

    IF NOT EXISTS (SELECT *
                         FROM master..sysservers
                        WHERE LOWER(srvname) = LOWER(@subscriber) collate database_default)
    begin

        EXECUTE @retcode = dbo.sp_addserver @subscriber

            IF @@error <> 0 OR @retcode <> 0
                BEGIN
                RAISERROR (14042, 16, -1)
                    RETURN (1)
                END
    end
    ELSE
    BEGIN
        SELECT @subscriber = fn_getpersistedservernamecasevariation(@subscriber) collate database_default
    END

    /*
    ** Set the server option to indicate this is a subscriber.
    */

    EXECUTE @retcode = dbo.sp_serveroption @subscriber, 'sub', true

    IF @@error <> 0 OR @retcode <> 0
        BEGIN
           RAISERROR (14042, 16, -1)
           RETURN (1)
        END

    /*
    ** Set the server option to indicate this is a DSN subscriber.
    */
    if @type = @dsn_subscriber OR @type = @jet_subscriber OR @type = @oledb_subscriber
       BEGIN
          update master..sysservers set srvproduct = 'MSREPL-NONSQL' where
            UPPER(srvname) = UPPER(@subscriber) collate database_default
          IF @@error <> 0 
            return(1)
       END
    
        RETURN (0) 
undo:

    RETURN (1) 
GO

raiserror('Creating procedure sp_addsubscriber_schedule', 0,1)
GO

CREATE PROCEDURE sp_addsubscriber_schedule (
    @subscriber sysname,
    @agent_type smallint = 0,
    @frequency_type int = 64,
    @frequency_interval int = 1,
    @frequency_relative_interval int = 1,
    @frequency_recurrence_factor int = 0,
    @frequency_subday int = 4,
    @frequency_subday_interval int = 5,
    @active_start_time_of_day int = 0,
    @active_end_time_of_day int = 235959,
    @active_start_date int = 0,
    @active_end_date int = 99991231
        ) AS

    DECLARE @distributor sysname
    DECLARE @distribdb sysname
    DECLARE @distproc nvarchar (300)
    DECLARE @retcode int
    DECLARE @msg nvarchar(255)
    
    /*
    ** Parameter Check:  @subscriber.
    ** Check to make sure that the subscriber doesn't already exist, and
    ** that the name is a valid non-null identifier.
    */

    IF @subscriber IS NULL
        BEGIN
            RAISERROR (14043, 16, -1, '@subscriber')
            RETURN (1)
        END

    EXECUTE @retcode = dbo.sp_validname @subscriber

    IF @@ERROR <> 0 OR @retcode <> 0
    RETURN (1)

    if LOWER(@subscriber) = 'all'
        BEGIN
            RAISERROR (14032, 16, -1, '@subscriber')
            RETURN (1)
        END

    IF NOT EXISTS (SELECT * FROM master..sysservers WHERE UPPER(srvname) = UPPER(@subscriber) collate database_default)
        BEGIN
            RAISERROR (14048, 16, -1, @subscriber)
            RETURN (1)
        END
    
    EXEC @retcode = dbo.sp_helpdistributor @rpcsrvname = @distributor OUTPUT,
                                       @distribdb   = @distribdb   OUTPUT

    IF @@error <> 0
        BEGIN
         RAISERROR (14071, 16, -1)
         RETURN (1)
     END

    IF @retcode <> 0 OR @distribdb IS NULL OR @distributor IS NULL
        BEGIN
            RAISERROR (14071, 16, -1)
            RETURN (1)
        END
    
    SELECT @distproc = RTRIM(@distributor) + '.' + RTRIM(@distribdb) + '.dbo.sp_MSadd_subscriber_schedule'
    EXEC @retcode = @distproc
         @@SERVERNAME,
         @subscriber,
         @agent_type,
         @frequency_type,
         @frequency_interval,
         @frequency_relative_interval,
         @frequency_recurrence_factor,
         @frequency_subday,
         @frequency_subday_interval,
         @active_start_time_of_day,
         @active_end_time_of_day,
         @active_start_date,
         @active_end_date
    
    IF @@error <> 0 OR @retcode <> 0
        BEGIN
        RAISERROR (14042, 16, -1)
        RETURN (1)
    END

    RETURN (0)
GO
 
raiserror('Creating procedure sp_changesubscriber', 0,1)
GO

CREATE PROCEDURE sp_changesubscriber (
    @subscriber sysname,
    @type tinyint = NULL,
    @login sysname = NULL,
    @password sysname = '%',
    @commit_batch_size int = NULL,
    @status_batch_size int = NULL,
    @flush_frequency int = NULL,
    @frequency_type int = NULL,
    @frequency_interval int = NULL,
    @frequency_relative_interval int = NULL,
    @frequency_recurrence_factor int = NULL,
    @frequency_subday int = NULL,
    @frequency_subday_interval int = NULL,
    @active_start_time_of_day int = NULL,
    @active_end_time_of_day int = NULL,
    @active_start_date int = NULL,
    @active_end_date int = NULL,
    @description nvarchar (255) = NULL,
    @security_mode int = NULL /* 0 standard; 1 integrated */

        ) AS

    DECLARE @distributor sysname
    DECLARE @distribdb sysname
    DECLARE @distproc nvarchar (300)
    DECLARE @msg nvarchar(255)
    DECLARE @retcode int
    DECLARE @platform_nt binary

    select @platform_nt = 0x1

    IF (UPPER(@subscriber) = UPPER(@@SERVERNAME) and @platform_nt != ( platform() & @platform_nt ) and @security_mode = 1)
        BEGIN
            RAISERROR(21038, 16, -1)
            RETURN (1)
        END

    /*
    ** Check to make sure that the subscriber exists.
    */
    IF NOT EXISTS (SELECT *
                 FROM master..sysservers
                WHERE UPPER(srvname) = UPPER(@subscriber) collate database_default)
        BEGIN
            RAISERROR(14048, 16, 1, @subscriber)
            RETURN (1)
        END

    /*
    ** Get distribution server information for remote RPC
    ** subscription calls.
    */
    EXEC @retcode = dbo.sp_helpdistributor @rpcsrvname = @distributor OUTPUT,
        @distribdb = @distribdb OUTPUT
    IF @@ERROR <> 0 OR @retcode <> 0
        BEGIN
            RAISERROR (14071, 16, -1)
            RETURN (1)
        END

    DECLARE @intnull int
    /*
    ** Update MSsubscriber_info
    */
    SELECT @distproc = RTRIM(@distributor) + '.' +
        RTRIM(@distribdb) + '.dbo.sp_MSupdate_subscriber_info'
    EXEC @retcode = @distproc
        @@SERVERNAME,
        @subscriber,
    @type,
    @login,
    @password,
    @commit_batch_size,
    @status_batch_size,
    @flush_frequency,
    @frequency_type,
    @frequency_interval,
    @frequency_relative_interval,
    @frequency_recurrence_factor,
    @frequency_subday,
    @frequency_subday_interval,
    @active_start_time_of_day,
    @active_end_time_of_day,
    @active_start_date,
    @active_end_date,
    @retryattempts = @intnull,
    @retrydelay  = @intnull,
    @description = @description,
    @security_mode = @security_mode
    IF @@ERROR <> 0 OR @retcode <> 0
        BEGIN
            RAISERROR (14048, 16, -1, @subscriber)
            RETURN (1)
    END
go
 
raiserror('Creating procedure sp_changesubscriber_schedule', 0,1)
GO

CREATE PROCEDURE sp_changesubscriber_schedule (
    @subscriber sysname,
    @agent_type smallint,
    @frequency_type int = NULL,
    @frequency_interval int = NULL,
    @frequency_relative_interval int = NULL,
    @frequency_recurrence_factor int = NULL,
    @frequency_subday int = NULL,
    @frequency_subday_interval int = NULL,
    @active_start_time_of_day int = NULL,
    @active_end_time_of_day int = NULL,
    @active_start_date int = NULL,
    @active_end_date int = NULL
        ) AS

    DECLARE @distributor sysname
    DECLARE @distribdb sysname
    DECLARE @distproc nvarchar (300)
    DECLARE @msg nvarchar(255)
    DECLARE @retcode int

    /*
    ** Check to make sure that the subscriber DOES exist.
    */
    IF NOT EXISTS (SELECT *
                 FROM master..sysservers
                WHERE UPPER(srvname) = UPPER(@subscriber) collate database_default)
        BEGIN
            RAISERROR (14048, 16, -1, @subscriber)
            RETURN (1)
        END

    /*
    ** Get distribution server information for remote RPC
    ** subscription calls.
    */
    EXEC @retcode = dbo.sp_helpdistributor @rpcsrvname = @distributor OUTPUT,
        @distribdb = @distribdb OUTPUT
    IF @@ERROR <> 0 OR @retcode <> 0
         BEGIN
            RAISERROR (14071, 16, -1)
             RETURN (1)
         END

    /*
    ** Update MSsubscriber_info
    */
    SELECT @distproc = RTRIM(@distributor) + '.' +
        RTRIM(@distribdb) + '.dbo.sp_MSupdate_subscriber_schedule'
    EXEC @retcode = @distproc
        @@SERVERNAME,
        @subscriber,
        @agent_type,
        @frequency_type,
        @frequency_interval,
        @frequency_relative_interval,
        @frequency_recurrence_factor,
        @frequency_subday,
        @frequency_subday_interval,
        @active_start_time_of_day,
        @active_end_time_of_day,
        @active_start_date,
        @active_end_date
    
    IF @@ERROR <> 0 OR @retcode <> 0
        BEGIN
            RAISERROR (14048, 16, -1, @subscriber)
            RETURN (1)
        END
        
    RETURN (0)  
go 
    
raiserror('Creating procedure sp_distcounters', 0,1)
GO

CREATE PROCEDURE sp_distcounters
    AS

    SET NOCOUNT ON

    /*
    ** Declarations.
    */
    DECLARE @distributor sysname
    DECLARE @distribdb sysname
    DECLARE @distproc nvarchar (300)
    DECLARE @retcode int

    /*
    ** Get distribution server information for remote RPC
    ** subscription calls.  If no distribution information, assume
    ** replication is not being used.
    */
    EXEC @retcode = dbo.sp_helpdistributor @rpcsrvname = @distributor OUTPUT,
                                       @distribdb = @distribdb OUTPUT
    IF @@error <> 0 OR @retcode <> 0 OR @distributor IS NULL OR
       @distribdb IS NULL
    RETURN (1)

    /*
    ** Request counters from Distribution Server
    */
    SELECT @distproc = RTRIM(@distributor) + '.' + RTRIM(@distribdb) +
    '.dbo.sp_MSdistribution_counters'
    EXEC @retcode = @distproc @@SERVERNAME
go
 

raiserror('Creating procedure sp_droppublisher', 0,1)
GO

CREATE PROCEDURE sp_droppublisher (
    @publisher sysname,         /* publisher server name */
    @type nvarchar (5) = NULL      /* NULL or 'dist' */
        ) AS

    SET NOCOUNT ON
    RAISERROR (21023, 16, -1,'sp_droppublisher')
    RETURN(1)

go
 
raiserror('Creating procedure sp_dropsubscriber', 0,1)
GO

CREATE PROCEDURE sp_dropsubscriber (
    @subscriber sysname,        /* The name of the subscriber */
    @reserved nvarchar(50) = NULL,
    @ignore_distributor bit = 0
        ) AS

    SET NOCOUNT ON

    /*
    ** Declarations.
    */

    DECLARE @db_name sysname
    DECLARE @foundSubscription int
    DECLARE @command nvarchar(255)
    DECLARE @transpublishdb_bit int
    DECLARE @mergepublishdb_bit int
    DECLARE @distributor sysname
    DECLARE @distribdb sysname
    DECLARE @distproc nvarchar (300)
    DECLARE @retcode int
    DECLARE @type nvarchar(10)

    SELECT @transpublishdb_bit = 1
    SELECT @mergepublishdb_bit = 4


    /*
    ** Parameter Check:  @subscriber.
    ** Check to make sure that the subscriber exists.
    */

    IF @subscriber IS NULL
        BEGIN
            RAISERROR (14043, 16, -1, '@subscriber')
            RETURN (1)
        END

    EXECUTE @retcode = dbo.sp_validname @subscriber

    IF @retcode <> 0
    RETURN (1)

    IF lower(@subscriber) <> 'all' and NOT EXISTS (SELECT *
                     FROM master..sysservers
                    WHERE UPPER(srvname) = UPPER(@subscriber) collate database_default
                      AND srvstatus & 4 <> 0)

        BEGIN
            RAISERROR (14048, 16, -1, @subscriber)
            RETURN (1)
        END

    if lower(@subscriber) = 'all'
    begin
        DECLARE hCdropsubscriber_all CURSOR LOCAL FAST_FORWARD FOR
            SELECT srvname
                     FROM master..sysservers
                    WHERE srvstatus & 4 <> 0
        FOR READ ONLY
        OPEN hCdropsubscriber_all
        FETCH hCdropsubscriber_all INTO @subscriber
    
        WHILE (@@fetch_status <> -1)
        BEGIN
            EXECUTE @retcode  = dbo.sp_dropsubscriber
                @subscriber = @subscriber,    
                @ignore_distributor = @ignore_distributor,
                @reserved = @reserved
            IF @@ERROR <> 0 OR @retcode <> 0
            BEGIN
                CLOSE hCdropsubscriber_all
                DEALLOCATE hCdropsubscriber_all
                RETURN (1)
            END
            FETCH hCdropsubscriber_all INTO @subscriber
        end
        
        CLOSE hCdropsubscriber_all
        DEALLOCATE hCdropsubscriber_all

        return(0)
    end


    /*
    ** There should be no subscription by the subscriber
    ** Open a cursor the published databases.
    **
    */
    DECLARE hCdropsubscriber CURSOR LOCAL FAST_FORWARD FOR
            SELECT name, N'tran' FROM master..sysdatabases      
                WHERE (category & @transpublishdb_bit) <> 0 
        UNION
            select name, N'merge' from master..sysdatabases      
                WHERE (category & @mergepublishdb_bit) <> 0 
    FOR READ ONLY

    OPEN hCdropsubscriber
    FETCH hCdropsubscriber INTO @db_name, @type
    
    WHILE (@@fetch_status <> -1)
    BEGIN        
		IF LOWER(@reserved collate SQL_Latin1_General_CP1_CS_AS) = 'drop_subscriptions'
        BEGIN
            if @type = 'tran'
            begin
                SELECT @command = quotename(@db_name) + '.dbo.sp_dropsubscription'
                EXECUTE @retcode  = @command 
                    @publication = 'all', 
                    @article = 'all', 
                    @subscriber = @subscriber,
                    @ignore_distributor = @ignore_distributor
            end
            if @type = 'merge'
            begin
                SELECT @command = quotename(@db_name) + '.dbo.sp_dropmergesubscription'
                EXECUTE @retcode  = @command 
                    @publication = 'all', 
                    @subscriber = @subscriber,
                    @subscription_type = 'both',
                    @ignore_distributor = @ignore_distributor
            end
            IF @@ERROR <> 0 OR @retcode <> 0
            BEGIN
                CLOSE hCdropsubscriber
                DEALLOCATE hCdropsubscriber
                RETURN (1)
            END
        END
        
		-- Set @foundSubscription to not null so that sp_helpsubscription will not display
		-- result set
		select @foundSubscription = 0

        if @type = 'tran'
        begin
            SELECT @command = quotename(@db_name) + '.dbo.sp_helpsubscription'
            EXECUTE @retcode  = @command @publication = '%', @article = '%', 
                @subscriber = @subscriber,
                @found = @foundSubscription  OUTPUT

            IF @@ERROR <> 0 OR @retcode <> 0
            BEGIN
                CLOSE hCdropsubscriber
                DEALLOCATE hCdropsubscriber
                RETURN (1)
            END
        end
        else
        begin
            SELECT @command = quotename(@db_name) + '.dbo.sp_helpmergesubscription'
            EXECUTE @retcode  = @command @publication = '%', 
                @subscriber = @subscriber,
                @subscription_type = 'both',
                @found = @foundSubscription  OUTPUT

            IF @@ERROR <> 0 OR @retcode <> 0
            BEGIN
                CLOSE hCdropsubscriber
                DEALLOCATE hCdropsubscriber
                RETURN (1)
            END
        end


        IF @foundSubscription <> 0
        BEGIN
            CLOSE hCdropsubscriber
            DEALLOCATE hCdropsubscriber
            RAISERROR ( 14144,  16, -1, @subscriber, @db_name)
            RETURN (1)
        END

        FETCH hCdropsubscriber INTO @db_name, @type

    END
    
    CLOSE hCdropsubscriber
    DEALLOCATE hCdropsubscriber

    /*
    ** Drop the subsubscriber_info in the distribution database
    */
    /*
    ** if @ignore_distributor = 1, we are in bruteforce cleanup mode, don't do RPC.
    */
    if @ignore_distributor = 0
    begin


        /*
        ** Get distribution server information for remote RPC
        ** agent verification.
        */
        EXEC @retcode = dbo.sp_helpdistributor 
            @rpcsrvname = @distributor OUTPUT,
            @distribdb = @distribdb OUTPUT
        IF @@error <> 0 OR @retcode <> 0
            BEGIN
            RAISERROR (14071, 16, -1)
               RETURN (1)
        END
        
        /*
        ** Insert information into MSsubscriber_info in the distribution db
        */
        if @distribdb is not null
        begin
            SELECT @distproc = RTRIM(@distributor) + '.' + RTRIM(@distribdb) + '.dbo.sp_MSdrop_subscriber_info'
            EXEC @retcode = @distproc
                 @publisher = @@SERVERNAME,
                 @subscriber = @subscriber

            IF @@error <> 0 OR @retcode <> 0
                BEGIN
                RAISERROR (14042, 16, -1)
                RETURN (1)
            END
        end
    end

    -- We have already validated the existence of the server at this point
    SELECT @subscriber = fn_getpersistedservernamecasevariation(@subscriber) collate database_default

    /*
    ** Turn off the subscriber server option.
    */
    EXECUTE @retcode = dbo.sp_serveroption @subscriber, 'sub', false
    IF @@ERROR <> 0 OR @retcode <> 0
    BEGIN
       RAISERROR (14047, 16, -1, @subscriber)
       RETURN (1)
    END

    RAISERROR (14062, 10, -1)
go
 
raiserror('Creating procedure sp_dsninfo', 0,1)
GO

CREATE PROCEDURE sp_dsninfo
--  xp_dsninfo does not support unicode
    @dsn varchar(128),
    @infotype varchar(128) = NULL,
    @login varchar(128) = NULL,
    @password varchar(128) = NULL,
    @dso_type int = 1  /* 1 is ODBC, 3 OLEDB. */
    AS

    SET NOCOUNT ON

    DECLARE @distributor sysname
    DECLARE @distproc nvarchar (300)
    DECLARE @retcode int
    DECLARE @dsotype_odbc int
    DECLARE @dsotype_oledb int

    select @dsotype_odbc = 1
    select @dsotype_oledb = 3

    /*
    ** Get distribution server information for remote RPC
    ** subscription calls.
    */

    EXEC @retcode = dbo.sp_helpdistributor @rpcsrvname = @distributor OUTPUT
    IF @@error <> 0 OR @retcode <> 0
        BEGIN
        RAISERROR (14071, 16, -1)
            RETURN (1)
    END

    if (@dso_type = @dsotype_odbc)
    begin
        /*
        ** Call xp_dsninfo
        */
        SELECT @distproc = RTRIM(@distributor) + '.master..xp_dsninfo'
        EXEC @retcode = @distproc @dsn, @infotype, @login, @password
        IF @@error <> 0
            BEGIN
            RAISERROR (14071, 16, -1)
            RETURN (1)
        END
    end
    else if (@dso_type = @dsotype_oledb)
    begin
        /*
        ** Call sp_oledbinfo
        */
        EXEC @retcode = master.dbo.sp_oledbinfo @dsn, @infotype, @login, @password
        IF @@error <> 0
            BEGIN
            RAISERROR (14071, 16, -1)
            RETURN (1)
        END
    end

go
 
dump tran master with no_log
go

raiserror('Creating procedure sp_publishdb', 0,1)
GO

/* For backward compatible */
CREATE PROCEDURE sp_publishdb @dbname sysname,@value nvarchar (5)
    AS

    DECLARE @retcode int

    EXECUTE @retcode = dbo.sp_replicationdboption @dbname, 'publish', @value

    IF @@ERROR <> 0 or @retcode <> 0
    BEGIN
       RETURN (1)
    END

    RETURN(0)
go
 

raiserror('Creating procedure sp_MScreate_dist_tables', 0,1)
GO

CREATE PROCEDURE sp_MScreate_dist_tables
AS

   /*
   ** Important:  
   ** We use varbinary(16) for xact_id and xact_seqno, we don't want ending nulls
   ** to be truncated by the server
   **
   ** Also, in MSrepl_commands, we don't want ending space to be truncated.  
   */
   SET ANSI_PADDING ON

   IF NOT EXISTS (SELECT * FROM sysobjects WHERE name = 'MSrepl_version' and type = 'U')
   BEGIN
      /****************************************************************************/
      raiserror('Creating table MSrepl_version', 0,1)
      /****************************************************************************/
      CREATE TABLE dbo.MSrepl_version
      (
      major_version int NOT NULL,
      minor_version int NOT NULL,
      revision int NOT NULL,
      db_existed bit NULL
      )
	  CREATE UNIQUE CLUSTERED INDEX ucMSrepl_version ON dbo.MSrepl_version
					(major_version, minor_version, revision)
    
      EXEC dbo.sp_MS_marksystemobject 'MSrepl_version'
      
      INSERT INTO MSrepl_version VALUES (7,0,0,0)
   END

   IF NOT EXISTS (SELECT * FROM sysobjects WHERE name = 'MSpublisher_databases' and type = 'U')
   BEGIN
      /****************************************************************************/
      raiserror('Creating table MSpublisher_databases', 0,1)
      /****************************************************************************/
      CREATE TABLE dbo.MSpublisher_databases(
        publisher_id smallint NOT NULL,
        publisher_db sysname NULL,
        id int identity NOT NULL,                   
    )
      EXEC dbo.sp_MS_marksystemobject 'MSpublisher_databases'

      raiserror('Creating clustered index ucMSpublisher_databases', 0,1)
      CREATE UNIQUE CLUSTERED INDEX ucMSpublisher_databases ON dbo.MSpublisher_databases
     (publisher_id, publisher_db, id)
   END

   IF NOT EXISTS (SELECT * FROM sysobjects WHERE name = 'MSpublications' and type = 'U')
   BEGIN
      /****************************************************************************/
      raiserror('Creating table MSpublications', 0,1)
      /****************************************************************************/
      CREATE TABLE dbo.MSpublications (
        publisher_id smallint NOT NULL,
        publisher_db sysname NULL,
        publication sysname NOT NULL,
        publication_id int identity NOT NULL,   -- This id IS NOT the same as the SQL Server publisher's
        publication_type int NOT NULL,          -- 0 = Snapshot 1 = Transactional
        thirdparty_flag bit NOT NULL,           -- 0 = SQL Server 1 = Third Party
        independent_agent bit NOT NULL,
        immediate_sync bit NOT NULL,
        allow_push bit NOT NULL,
        allow_pull bit NOT NULL,
        allow_anonymous bit NOT NULL,
        description nvarchar(255) NULL,
        vendor_name nvarchar(100) NULL,
        retention	int NULL,
		sync_method int default 0 NOT NULL,
		allow_subscription_copy bit default 0 not null,
		thirdparty_options int null,
		allow_queued_tran bit default 0	not null
		)
      EXEC dbo.sp_MS_marksystemobject 'MSpublications'

	 -- publication_id needs to be the first columns in the index. It
	 -- is used in sp_MSmaximum_cleanup_seqno.
      raiserror('Creating clustered index ucMSpublications', 0,1)
      CREATE UNIQUE CLUSTERED INDEX ucMSpublications ON dbo.MSpublications
     (publication_id,  publication, publisher_db, publisher_id)

   END
   ELSE
   BEGIN
      IF NOT EXISTS (select * from syscolumns
        where name = 'sync_method'
        and id=object_id('MSpublications'))
      BEGIN
         ALTER TABLE MSpublications ADD sync_method int default 0 not null
      END

      IF NOT EXISTS (select * from syscolumns
        where name = 'allow_subscription_copy'
        and id=object_id('MSpublications'))
      BEGIN
         ALTER TABLE MSpublications ADD allow_subscription_copy bit default 0 not null
      END
      IF NOT EXISTS (select * from syscolumns
        where name = 'thirdparty_options'
        and id=object_id('MSpublications'))
      BEGIN
         ALTER TABLE MSpublications ADD thirdparty_options int null
      END

      IF NOT EXISTS (select * from syscolumns
        where name = 'allow_queued_tran'
        and id=object_id('MSpublications'))
      BEGIN
         ALTER TABLE MSpublications ADD allow_queued_tran bit default 0	not null
      END
   END


   IF NOT EXISTS (SELECT * FROM sysobjects WHERE name = 'MSarticles' and type = 'U')
   BEGIN
      /****************************************************************************/
      raiserror('Creating table MSarticles', 0,1)
      /****************************************************************************/
    CREATE TABLE dbo.MSarticles (
        publisher_id smallint NOT NULL,
        publisher_db sysname NULL,
        publication_id int NOT NULL,
        article sysname NOT NULL,
        article_id int NOT NULL,                            -- This id is the same as a SQL Server Publisher's
        destination_object sysname NULL,
        source_owner    sysname NULL,
        source_object sysname NULL,
        description nvarchar(255) NULL
    )   

      EXEC dbo.sp_MS_marksystemobject 'MSarticles'

      raiserror('Creating clustered index ucMSarticles', 0,1)
      CREATE UNIQUE CLUSTERED INDEX ucMSarticles ON dbo.MSarticles
     (publisher_db, publisher_id, article_id, article, publication_id)
   END

	IF NOT EXISTS( SELECT * FROM sysobjects WHERE name = 'MSsync_states' )
	BEGIN
		CREATE TABLE dbo.MSsync_states
		(
			publisher_id smallint not null,
			publisher_db sysname not null,
			publication_id int not null 
		)
		EXEC dbo.sp_MS_marksystemobject 'MSsync_states'

		CREATE UNIQUE CLUSTERED INDEX ucMSsyncstates on dbo.MSsync_states
		( publisher_id, publisher_db, publication_id )
	END

   IF NOT EXISTS (SELECT * FROM sysobjects WHERE name = 'MSsubscriptions' and type = 'U')
   BEGIN
      /****************************************************************************/
      raiserror('Creating table MSsubscriptions', 0,1)
      /****************************************************************************/
       CREATE TABLE dbo.MSsubscriptions
      (
        publisher_database_id int NOT NULL,         -- Used to reference MSrepl_transactions and MSrepl_commands
        publisher_id smallint NOT NULL,
        publisher_db sysname NOT NULL,
        publication_id int NOT NULL,
        article_id int NOT NULL,
        subscriber_id smallint NOT NULL,
        subscriber_db sysname NOT NULL,
        subscription_type int NOT NULL,         -- 0 = push, 1 = pull, 2 = anonymous 
        sync_type tinyint NOT NULL,                 -- 1 = automatic 2 = no sync
        status tinyint NOT NULL,                        -- 0 = inactive, 1 = subscribed, 2 = active 
        subscription_seqno varbinary(16) NOT NULL,  -- publisher's database sequence number 
        snapshot_seqno_flag bit NOT NULL,               -- 1 if subscription_seqno is the snapshot seqno
        independent_agent bit NOT NULL,             -- Value carried over from MSpublications
        subscription_time datetime NOT NULL, 
        loopback_detection bit NOT NULL,  
        agent_id int NOT NULL,
        update_mode tinyint NOT NULL,				-- 0 = read only, 1 = sync tran, 2 = queued tran, 
													-- 3 = failover, 4 = sqlqueued tran, 5 = sqlqueued failover
        publisher_seqno varbinary(16) NOT NULL,
		ss_cplt_seqno   varbinary(16) NOT NULL
      )

      EXEC dbo.sp_MS_marksystemobject 'MSsubscriptions'

      raiserror('Creating clustered index ucMSsubscirptions', 0,1)
      CREATE UNIQUE CLUSTERED INDEX ucMSsubscriptions ON dbo.MSsubscriptions
      (agent_id, article_id)

	  -- Index used by sp_MSdelete_publisherdb_trans
      raiserror('Creating index iMSsubscriptions', 0,1)
      CREATE INDEX iMSsubscriptions ON dbo.MSsubscriptions
      (publisher_database_id, article_id, subscriber_id, subscriber_db, publication_id, publisher_db, publisher_id)
    END
    ELSE
    BEGIN
		if not exists ( select * from syscolumns 
						where id = object_id( N'MSsubscriptions' ) 
						and name = N'ss_cplt_seqno' )
		begin				
			exec ('alter table MSsubscriptions add ss_cplt_seqno varbinary(16) NULL')
			exec ('update MSsubscriptions set ss_cplt_seqno = publisher_seqno')
			exec ('alter table MSsubscriptions alter column ss_cplt_seqno varbinary(16) NOT NULL')
		end
    END

   -- For beta 3 upgrade, we need to create new index here.
   if not exists (select * from sysindexes where name = 'iMSsubscriptions2')
   begin
	  -- Index used by sp_MSdelete_publisherdb_trans
      raiserror('Creating index iMSsubscriptions2', 0,1)
      CREATE INDEX iMSsubscriptions2 ON dbo.MSsubscriptions
      (publisher_database_id, subscription_seqno)
   end

   
   IF NOT EXISTS (SELECT * FROM sysobjects WHERE name = 'MSmerge_subscriptions' and type = 'U')
   BEGIN
      /****************************************************************************/
      raiserror('Creating table MSmerge_subscriptions', 0,1)
      /****************************************************************************/
       CREATE TABLE dbo.MSmerge_subscriptions
      (
        publisher_id smallint NOT NULL,
        publisher_db sysname NULL,
        publication_id int NOT NULL,
        subscriber_id smallint NOT NULL,
        subscriber_db sysname NULL,
        subscription_type int NULL,         -- 0 = push, 1 = pull, 2 = anonymous 
        sync_type tinyint NOT NULL,                 -- 1 = automatic 2 = no sync
        status tinyint NOT NULL,                        -- 0 = inactive, 1 = subscribed, 2 = active 
        subscription_time datetime NOT NULL
      )

      EXEC dbo.sp_MS_marksystemobject 'MSmerge_subscriptions'

      raiserror('Creating clustered index ucMSmerge_subscriptions', 0,1)
      CREATE UNIQUE CLUSTERED INDEX ucMSmerge_subscriptions ON dbo.MSmerge_subscriptions
     (publisher_id, publisher_db, publication_id, subscriber_id, subscriber_db)
   END


   IF NOT EXISTS (SELECT * FROM sysobjects WHERE name = 'MSrepl_transactions' and type = 'U')
   BEGIN
      /****************************************************************************/
      raiserror('Creating table MSrepl_transactions', 0,1)
      /****************************************************************************/
      CREATE TABLE dbo.MSrepl_transactions
      (
      publisher_database_id int NOT NULL,
      xact_id varbinary(16) NULL,
      xact_seqno varbinary (16 )  NOT NULL,
      entry_time datetime  NOT NULL
      )

      EXEC dbo.sp_MS_marksystemobject 'MSrepl_transactions'

      raiserror('Creating clustered index usMSrepl_transactions', 0,1)
      CREATE UNIQUE CLUSTERED INDEX ucMSrepl_transactions ON dbo.MSrepl_transactions
         (publisher_database_id, xact_seqno)
         WITH STATISTICS_NORECOMPUTE

      CREATE STATISTICS stat_publisher_database_id
         ON MSrepl_transactions (publisher_database_id)
         WITH NORECOMPUTE

      CREATE STATISTICS stat_xact_id
         ON MSrepl_transactions (xact_id)
         WITH NORECOMPUTE

      CREATE STATISTICS stat_xact_seqno
         ON MSrepl_transactions (xact_seqno)
         WITH NORECOMPUTE

      CREATE STATISTICS stat_entry_time
         ON MSrepl_transactions (entry_time)
         WITH NORECOMPUTE

   END

   IF NOT EXISTS (SELECT * FROM sysobjects WHERE name = 'MSrepl_commands' and type = 'U')
   BEGIN

      /****************************************************************************/
      raiserror('Creating table MSrepl_commands', 0,1)
      /****************************************************************************/


      CREATE TABLE dbo.MSrepl_commands (
      publisher_database_id int not null,
      xact_seqno varbinary(16) not null,
      type int not null, 
      article_id int not null,
      originator_id int not null,
      command_id int not null,
      partial_command bit not null,
      command varbinary(1024) NULL
      )


      EXEC dbo.sp_MS_marksystemobject 'MSrepl_commands'

      raiserror('Creating clusterd index ucMSrepl_commands', 0,1)
      CREATE UNIQUE CLUSTERED INDEX ucMSrepl_commands ON dbo.MSrepl_commands
         (publisher_database_id, xact_seqno, command_id)
         WITH STATISTICS_NORECOMPUTE

      CREATE STATISTICS stat_xact_seqno
         ON MSrepl_commands (xact_seqno)
         WITH NORECOMPUTE

      CREATE STATISTICS stat_type
         ON MSrepl_commands (type)
         WITH NORECOMPUTE

      CREATE STATISTICS stat_article_id
         ON MSrepl_commands (article_id)
         WITH NORECOMPUTE

      CREATE STATISTICS stat_originator_id
         ON MSrepl_commands (originator_id)
         WITH NORECOMPUTE

      CREATE STATISTICS stat_command_id
         ON MSrepl_commands (command_id)
         WITH NORECOMPUTE

      CREATE STATISTICS stat_partial_command
         ON MSrepl_commands (partial_command)
         WITH NORECOMPUTE

   END


   IF NOT EXISTS (SELECT * FROM sysobjects WHERE name = 'MSrepl_originators' and type = 'U')
   BEGIN
      /****************************************************************************/
      raiserror('Creating table MSrepl_orginators', 0,1)
      /****************************************************************************/
      CREATE TABLE dbo.MSrepl_originators
      (
      id int identity not null,
      publisher_database_id int not null,
      srvname   sysname not null,
      dbname    sysname not null
      )

      EXEC dbo.sp_MS_marksystemobject 'MSrepl_originators'

      raiserror('Creating clustered index usMSrepl_originators', 0,1)
      CREATE UNIQUE CLUSTERED INDEX ucMSrepl_originators ON dbo.MSrepl_originators
         (publisher_database_id, srvname, dbname)
   END

   IF NOT EXISTS (SELECT * FROM sysobjects WHERE name = 'MSsubscriber_info' and type = 'U')
   BEGIN
      /****************************************************************************/
      raiserror('Creating table MSsubscriber_info', 0,1)
      /****************************************************************************/
      CREATE TABLE dbo.MSsubscriber_info
      (
      publisher  sysname NOT NULL,
      subscriber  sysname NOT NULL,
      type tinyint NOT NULL,           /* 0: MS SQL Server 1: ODBC Data Source */
      login sysname NULL,
      password nvarchar(524) NULL,
      description nvarchar(255) NULL,
      security_mode int NOT NULL
      )

      EXEC dbo.sp_MS_marksystemobject 'MSsubscriber_info'

      raiserror('Creating clustered index ucMSsubscriber_info', 0,1)
      CREATE UNIQUE CLUSTERED INDEX ucMSsubscriber_info ON dbo.MSsubscriber_info
     (publisher, subscriber)
   END
   ELSE
   BEGIN
      IF NOT EXISTS (select * from syscolumns
        where name = 'description'
        and id=object_id('MSsubscriber_info'))
      BEGIN
         
         ALTER TABLE MSsubscriber_info ADD description nvarchar (255) NULL
         UPDATE MSsubscriber_info SET description = 'SQL Server 6.0'
      END
   END

   IF NOT EXISTS (SELECT * FROM sysobjects WHERE name = 'MSsubscriber_schedule' and type = 'U')
   BEGIN
         raiserror('Creating table MSsubscriber_schedule', 0,1)
         
        CREATE TABLE dbo.MSsubscriber_schedule
        (
            publisher  sysname NOT NULL,
            subscriber  sysname NOT NULL,
            agent_type      smallint NOT NULL,   -- 0 for distribution agent, 1 for merge agent
            frequency_type int NOT NULL,
            frequency_interval int NOT NULL,
            frequency_relative_interval int NOT NULL,
            frequency_recurrence_factor int NOT NULL,
            frequency_subday int NOT NULL,
            frequency_subday_interval int NOT NULL,
            active_start_time_of_day int NOT NULL,
            active_end_time_of_day int NOT NULL,
            active_start_date int NOT NULL,
            active_end_date int NOT NULL
        )
      EXEC dbo.sp_MS_marksystemobject 'MSsubscriber_schedule'

        CREATE UNIQUE CLUSTERED INDEX ucMSsubscriber_schedule ON dbo.MSsubscriber_schedule
     (publisher, subscriber, agent_type)
     
    END

   IF NOT EXISTS (SELECT * FROM sysobjects WHERE name = 'MSsnapshot_history' and type = 'U')
   BEGIN
        /****************************************************************************/
         raiserror('Creating table MSsnapshot_history', 0,1)
        /****************************************************************************/
        CREATE TABLE dbo.MSsnapshot_history 
        (
        agent_id int NOT NULL,
        runstatus int NOT NULL,
        start_time datetime NOT NULL,        
        time datetime NOT NULL,    
        duration int NOT NULL,            
        comments nvarchar(255) NOT NULL,

        -- Session summary statistics
        delivered_transactions int NOT NULL,
        delivered_commands int NOT NULL,
        delivery_rate float NOT NULL,

        error_id int NOT NULL,
        timestamp NOT NULL
    )

      EXEC dbo.sp_MS_marksystemobject 'MSsnapshot_history'

     raiserror('Creating clustered index ucMSsnapshot_history', 0,1)
    CREATE UNIQUE CLUSTERED INDEX ucMSsnapshot_history ON dbo.MSsnapshot_history
        (agent_id, timestamp, start_time, time)

	if not exists (select * from sysindexes where name = 'nc1MSsnapshot_history')
	begin
		 raiserror('Creating clustered index nc1MSsnapshot_history', 0,1)
		create nonclustered index nc1MSsnapshot_history on MSsnapshot_history(agent_id, start_time) 
	end	

   END
       
   IF NOT EXISTS (SELECT * FROM sysobjects WHERE name = 'MSlogreader_history' and type = 'U')
   BEGIN
        /****************************************************************************/
        raiserror('Creating table MSlogreader_history', 0,1)
        /****************************************************************************/    
        CREATE TABLE dbo.MSlogreader_history
        (
        agent_id int NOT NULL,
        runstatus int NOT NULL,
        start_time datetime NOT NULL,
        time datetime NOT NULL,
        duration int NOT NULL,
        comments nvarchar(255) NOT NULL,
        xact_seqno varbinary(16) NULL,

        -- Session summary statistics
        delivery_time int NOT NULL,
        delivered_transactions int NOT NULL,
        delivered_commands int NOT NULL,
        average_commands int NOT NULL,
        delivery_rate float NOT NULL,
        delivery_latency int NOT NULL,

        error_id int NOT NULL,
        timestamp NOT NULL
        )

      EXEC dbo.sp_MS_marksystemobject 'MSlogreader_history'

    raiserror('Creating clustered index ucMSlogreader_history', 0,1)
    CREATE UNIQUE CLUSTERED INDEX ucMSlogreader_history ON dbo.MSlogreader_history
        (agent_id, timestamp, runstatus, start_time, time) 

	if not exists (select * from sysindexes where name = 'nc1MSlogreader_history')
	begin
	    raiserror('Creating nonclustered index nc1MSlogreader_history', 0,1)
		create nonclustered index nc1MSlogreader_history on MSlogreader_history(agent_id, start_time) 
	end	

   END

   IF NOT EXISTS (SELECT * FROM sysobjects WHERE name = 'MSdistribution_history' and type = 'U')
   BEGIN
        /****************************************************************************/
          raiserror('Creating table MSdistribution_history', 0,1)
        /****************************************************************************/    

        CREATE TABLE dbo.MSdistribution_history
        (
        agent_id int NOT NULL,
        runstatus int NOT NULL,
        start_time datetime NOT NULL,
        time datetime NOT NULL,
        duration int NOT NULL,
        comments nvarchar(255) NOT NULL,
        xact_seqno varbinary(16) NULL,

        -- Current statistics
        current_delivery_rate float NOT NULL,
        current_delivery_latency int NOT NULL,

        -- Session summary statistics
        delivered_transactions int NOT NULL,
        delivered_commands int NOT NULL,
        average_commands int NOT NULL,
        delivery_rate float NOT NULL,       
        delivery_latency int NOT NULL, 

        -- Summary statistics across all sessions
        total_delivered_commands int NOT NULL, 

        error_id int NOT NULL,
        updateable_row bit NOT NULL,
        timestamp NOT NULL
        )

    EXEC dbo.sp_MS_marksystemobject 'MSdistribution_history'

    raiserror('Creating clustered index ucMSdistribution_history', 0,1)
    CREATE UNIQUE CLUSTERED INDEX ucMSdistribution_history ON dbo.MSdistribution_history
        (agent_id, timestamp, runstatus, start_time, time) 


	if not exists (select * from sysindexes where name = 'nc1MSdistribution_history')
	begin
	    raiserror('Creating clustered index nc1MSdistribution_history', 0,1)
		create nonclustered index nc1MSdistribution_history on MSdistribution_history(agent_id, start_time) 
	end	

   END

   IF NOT EXISTS (SELECT * FROM sysobjects WHERE name = 'MSmerge_history' and type = 'U')
   BEGIN
        /****************************************************************************/
      raiserror('Creating table MSmerge_history', 0,1)
        /****************************************************************************/    

        CREATE TABLE dbo.MSmerge_history
        (
        agent_id                    int             NOT NULL,
        runstatus               int             NOT NULL,
        start_time              datetime        NOT NULL,
        time                    datetime        NOT NULL,
        duration                int             NOT NULL,
        comments                nvarchar(255)   NOT NULL,
        delivery_time               int         NOT NULL,
        delivery_rate               float       NOT NULL,
        publisher_insertcount       int         NULL,
        publisher_updatecount       int         NULL,
        publisher_deletecount       int         NULL,
        publisher_conflictcount     int         NULL,
        subscriber_insertcount      int         NULL,
        subscriber_updatecount      int         NULL,
        subscriber_deletecount      int         NULL,
        subscriber_conflictcount    int         NULL,
        error_id                    int         NOT NULL,
        timestamp                               NOT NULL,
		updateable_row				bit			NOT NULL
        )        

    EXEC dbo.sp_MS_marksystemobject 'MSmerge_history'

    raiserror('Creating clustered index ucMSmerge_history', 0,1)
    CREATE UNIQUE CLUSTERED INDEX ucMSmerge_history ON dbo.MSmerge_history
        (agent_id, timestamp, runstatus) 
        
	if not exists (select * from sysindexes where name = 'nc1MSmerge_history')
		begin
			raiserror('Creating nonclustered index nc1MSmerge_history', 0,1)
			create nonclustered index nc1MSmerge_history on MSmerge_history(agent_id, runstatus, start_time) 
		end
   END
   ELSE
   BEGIN
      IF NOT EXISTS (select * from syscolumns
        where name = 'updateable_row'
        and id=object_id('MSmerge_history'))
      BEGIN 
         ALTER TABLE MSmerge_history ADD updateable_row bit default 1 NOT NULL
      END

	  if not exists (select * from sysindexes where name = 'nc1MSmerge_history' and id=object_id('MSmerge_history'))
	  begin
			raiserror('Creating nonclustered index nc1MSmerge_history', 0,1)
			create nonclustered index nc1MSmerge_history on MSmerge_history(agent_id, runstatus, start_time) 
	  end	
   END


   IF NOT EXISTS (SELECT * FROM sysobjects WHERE name = 'MSrepl_errors' and type = 'U')
   BEGIN
        /****************************************************************************/
        raiserror('Creating table MSrepl_errors', 0,1)
        /****************************************************************************/    

        CREATE TABLE dbo.MSrepl_errors
        (
        id                  int NOT NULL,
        time                datetime NOT NULL,
        error_type_id       int NULL,
        source_type_id      int NULL,
        source_name         nvarchar(100) NULL,
        error_code          sysname NULL,
        error_text          ntext NULL,
		xact_seqno			varbinary(16) NULL,
		command_id			int NULL
        )

      EXEC dbo.sp_MS_marksystemobject 'MSrepl_errors'

    raiserror('Creating clustered index ucMSrepl_errors', 0,1)
    CREATE CLUSTERED INDEX ucMSrepl_errors ON dbo.MSrepl_errors
        (id, time) -- WITH ALLOW_DUP_ROW
   END
   ELSE
   BEGIN
      IF NOT EXISTS (select * from syscolumns
        where name = 'xact_seqno'
        and id=object_id('MSrepl_errors'))
         ALTER TABLE MSrepl_errors ADD xact_seqno varbinary(16) NULL

      IF NOT EXISTS (select * from syscolumns
        where name = 'command_id'
        and id=object_id('MSrepl_errors'))
         ALTER TABLE MSrepl_errors ADD command_id int NULL
   END

   IF NOT EXISTS (SELECT * FROM sysobjects WHERE name = 'MSsnapshot_agents' and type = 'U')
   BEGIN
        /****************************************************************************/
        raiserror('Creating table MSsnapshot_agents', 0,1)
        /****************************************************************************/    

        CREATE TABLE dbo.MSsnapshot_agents
        (
        id                  int IDENTITY NOT NULL,
        name                nvarchar(100) NOT NULL,
        publisher_id        smallint NOT NULL,
        publisher_db        sysname NOT NULL,
        publication         sysname NOT NULL,
        publication_type    int NOT NULL,       -- 0 transactional 1 snapshot 2 merge
        local_job           bit NOT NULL,
        job_id              binary(16) NULL,
        profile_id  int     NOT NULL
        )

      EXEC dbo.sp_MS_marksystemobject 'MSsnapshot_agents'

    raiserror('Creating clustered index ucMSsnapshot_agents', 0,1)
    CREATE CLUSTERED INDEX ucMSsnapshot_agents ON dbo.MSsnapshot_agents
        (publication, publisher_db, publisher_id) 

    raiserror('Creatingindex iMSsnapshot_agents', 0,1)
    CREATE UNIQUE INDEX iMSsnapshot_agents ON dbo.MSsnapshot_agents
        (id)
   END

   IF NOT EXISTS (SELECT * FROM sysobjects WHERE name = 'MSlogreader_agents' and type = 'U')
   BEGIN
        /****************************************************************************/
        raiserror('Creating table MSlogreader_agents', 0,1)
        /****************************************************************************/    

        CREATE TABLE dbo.MSlogreader_agents
        (
        id                  int IDENTITY NOT NULL,
        name                nvarchar(100) NOT NULL,
        publisher_id        smallint NOT NULL,
        publisher_db        sysname NOT NULL,
        publication         sysname NOT NULL,-- Not used for SQL Server publisher
        local_job           bit NOT NULL,
        job_id              binary(16) NULL,
        profile_id  int     NOT NULL
        )

      EXEC dbo.sp_MS_marksystemobject 'MSlogreader_agents'

    raiserror('Creating clustered index ucMSlogreader_agents', 0,1)
    CREATE CLUSTERED INDEX ucMSlogreader_agents ON dbo.MSlogreader_agents
        (publisher_db, publisher_id) 

    raiserror('Creatingindex iMSlogreader_agents', 0,1)
    CREATE UNIQUE INDEX iMSlogreader_agents ON dbo.MSlogreader_agents
        (id)
   END

   IF NOT EXISTS (SELECT * FROM sysobjects WHERE name = 'MSdistribution_agents' and type = 'U')
   BEGIN
        /****************************************************************************/
        raiserror('Creating table MSdistribution_agents', 0,1)
        /****************************************************************************/    

        CREATE TABLE dbo.MSdistribution_agents
        (
		id                  int IDENTITY NOT NULL,
		name                nvarchar(100) NOT NULL,
		publisher_database_id int NOT NULL,
		publisher_id        smallint NOT NULL,
		publisher_db        sysname NOT NULL,
		publication         sysname NOT NULL,
		subscriber_id       smallint NULL, 
		subscriber_db       sysname NULL,
		subscription_type   int NOT NULL,
		local_job           bit NULL,
		job_id              binary(16) NULL,
		subscription_guid   binary(16) NOT NULL,
		profile_id  int     NOT NULL,
		anonymous_subid     uniqueidentifier NULL,
		subscriber_name     sysname NULL,
		virtual_agent_id    int NULL,
		anonymous_agent_id  int NULL,
		creation_date		datetime default (getdate()) not NULL,
		queue_id			sysname null,
        queue_status        int default 0 not null,
        offload_enabled     bit default 0 NOT NULL,
        offload_server      sysname NULL,
		dts_package_name	sysname NULL,
		dts_package_password nvarchar(524) NULL,
		dts_package_location int default 0 not null,
		sid					varbinary(85) default suser_sid() not null,
		queue_server		sysname NULL
        )

        EXEC dbo.sp_MS_marksystemobject 'MSdistribution_agents'

        raiserror('Creating clustered index ucMSdistribution_agents', 0,1)
        CREATE UNIQUE CLUSTERED INDEX ucMSdistribution_agents ON dbo.MSdistribution_agents
            (id)

        raiserror('Creatingindex iMSdistribution_agents', 0,1)
        CREATE INDEX iMSdistribution_agents ON dbo.MSdistribution_agents
            (publication, publisher_db, publisher_id, subscriber_id, subscriber_db, anonymous_subid) 
   END

	if not exists (select * from syscolumns where 
		id = object_id('MSdistribution_agents') and
		name = 'creation_date')
	begin
		alter table MSdistribution_agents add creation_date datetime default (getdate()) not null
	end 

	if not exists (select * from syscolumns where 
		id = object_id('MSdistribution_agents') and
		name = 'offload_enabled')
	begin
		alter table MSdistribution_agents add offload_enabled bit default 0 not null
	end 

	if not exists (select * from syscolumns where 
		id = object_id('MSdistribution_agents') and
		name = 'offload_server')
	begin
		alter table MSdistribution_agents add offload_server sysname null
	end 

	if not exists (select * from syscolumns where 
		id = object_id('MSdistribution_agents') and
		name = 'queue_id')
	begin
		alter table MSdistribution_agents add queue_id sysname null
	end 

	if not exists (select * from syscolumns where 
		id = object_id('MSdistribution_agents') and
		name = 'queue_status')
	begin
		alter table MSdistribution_agents add queue_status int default 0 not null
	end 

	if not exists (select * from syscolumns where 
		id = object_id('MSdistribution_agents') and
		name = 'dts_package_name')
	begin
		alter table MSdistribution_agents add dts_package_name sysname null
	end 
	if not exists (select * from syscolumns where 
		id = object_id('MSdistribution_agents') and
		name = 'dts_package_password')
	begin
		alter table MSdistribution_agents add dts_package_password nvarchar(524) null
	end 

	if not exists (select * from syscolumns where 
		id = object_id('MSdistribution_agents') and
		name = 'dts_package_location')
	begin
		alter table MSdistribution_agents add dts_package_location int default 0 not null
	end 

	if not exists (select * from syscolumns where 
		id = object_id('MSdistribution_agents') and
		name = 'sid')
	begin
		-- set sid to be the upgrade user. db_owner or sysadmin
		-- can drop the agent entry
		alter table MSdistribution_agents add sid varbinary(85) default suser_sid() not null
	end 

	if not exists (select * from syscolumns where 
		id = object_id('MSdistribution_agents') and
		name = 'queue_server')
	begin
		alter table MSdistribution_agents add queue_server sysname null
		EXEC dbo.sp_MSupdate_mqserver_distdb
	end 
	
   IF NOT EXISTS (SELECT * FROM sysobjects WHERE name = 'MSmerge_agents' and type = 'U')
   BEGIN
        /****************************************************************************/
        raiserror('Creating table MSmerge_agents', 0,1)
        /****************************************************************************/    

        CREATE TABLE dbo.MSmerge_agents
        (
		id                  int IDENTITY NOT NULL,
		name                nvarchar(100) NOT NULL,
		publisher_id        smallint NOT NULL,
		publisher_db        sysname NOT NULL,
		publication         sysname NOT NULL,
		subscriber_id       smallint NULL,
		subscriber_db       sysname NULL,
		local_job           bit NULL,
		job_id              binary(16) NULL,
		profile_id          int NULL,
		anonymous_subid     uniqueidentifier NULL,
		subscriber_name     sysname NULL,
		creation_date		datetime default (getdate()) not NULL,
        offload_enabled     bit default 0 NOT NULL,
        offload_server      sysname NULL,
		sid					varbinary(85) default suser_sid() not null
        )

      EXEC dbo.sp_MS_marksystemobject 'MSmerge_agents'

    raiserror('Creating clustered index ucMSmerge_agents', 0,1)
    CREATE CLUSTERED INDEX ucMSmerge_agents ON dbo.MSmerge_agents
        (publication, publisher_db, publisher_id, subscriber_id, subscriber_db, anonymous_subid) 
    
    raiserror('Creatingindex iMSmerge_agents', 0,1)
    CREATE UNIQUE INDEX iMSmerge_agents ON dbo.MSmerge_agents
        (id)
	END


	-- Need to re_visit the indexing of this table
	if not exists (select * from sysobjects where name = 'MSrepl_identity_range')
		begin		
			raiserror('Creating table MSrepl_identity_range',0,1)
			
			create table dbo.MSrepl_identity_range (
			publisher				sysname not NULL, 
			publisher_db			sysname	not NULL,
			tablename				sysname not NULL,
			identity_support		int NULL,
			next_seed				bigint NULL, --resource control
			pub_range				bigint NULL, --publisher range
			range					bigint NULL, -- set by sp_addmergearticle
			max_identity			bigint NULL, --resource control
			threshold				int	NULL,	--in percentage, set by sp_addmergearticle
			current_max				bigint NULL	--max value for current check constraint,set by sp_addmergearticle
			)
			exec dbo.sp_MS_marksystemobject MSrepl_identity_range

			grant select on MSrepl_identity_range to public
		end

	if not exists (select * from syscolumns where 
		id = object_id('MSmerge_agents') and
		name = 'creation_date')
	begin
		alter table MSmerge_agents add creation_date datetime default (getdate()) not null
	end 

	if not exists (select * from syscolumns where 
		id = object_id('MSmerge_agents') and
		name = 'offload_enabled')
	begin
		alter table MSmerge_agents add offload_enabled bit default 0 not null
	end 

	if not exists (select * from syscolumns where 
		id = object_id('MSmerge_agents') and
		name = 'offload_server')
	begin
		alter table MSmerge_agents add offload_server sysname null
	end 

	if not exists (select * from syscolumns where 
		id = object_id('MSmerge_agents') and
		name = 'sid')
	begin
		-- set sid to be the upgrade user. db_owner or sysadmin
		-- can drop the agent entry
		alter table MSmerge_agents add sid varbinary(85) default suser_sid() not null
	end 

	IF NOT EXISTS (SELECT * FROM sysobjects WHERE name = 'MSpublication_access' and type = 'U')
	BEGIN
		/****************************************************************************/
		raiserror('Creating table MSpublication_access', 0,1)
		/****************************************************************************/    

		CREATE TABLE dbo.MSpublication_access
		(
		publication_id      int NULL,       -- Publication_id is unique in distribution database.
		login               sysname NOT NULL
											-- Logins in the publication access list, they nust
											-- exist at both publisher and distributor side.            
		)

		EXEC dbo.sp_MS_marksystemobject 'MSpublication_access'

		raiserror('Creating clustered index ucMSpublication_access', 0,1)
		CREATE UNIQUE CLUSTERED INDEX ucMSpublication_access ON dbo.MSpublication_access
			(publication_id, login) 
	END

	-- For b3 upgrade
	if NOT EXISTS (select * from syscolumns where name='retention' and id=object_id('MSpublications'))
	begin
		alter table MSpublications add retention int NULL 
		UPDATE msdb..MSdistributiondbs set max_distretention=72 where
			name = db_name() collate database_default
	end

	-- drop default_access column
	if exists (select * from syscolumns where id = object_id('MSpublications') and
		name = 'default_access')
	begin
		alter table MSpublications drop column default_access
	end 

	-- Drop publisher_id column
	if EXISTS (select * from syscolumns where name='publisher_id' and id=object_id('MSpublication_access'))
	begin
		drop index MSpublication_access.ucMSpublication_access

		alter table MSpublication_access drop column publisher_id

		raiserror('Creating clustered index ucMSpublication_access', 0,1)
		CREATE CLUSTERED INDEX ucMSpublication_access ON dbo.MSpublication_access
		(publication_id, login) 
	end

	IF NOT EXISTS (SELECT * FROM sysobjects WHERE name = 'MSqreader_agents' and type = 'U')
	BEGIN
		/****************************************************************************/
		raiserror('Creating table MSqreader_agents', 0,1)
		/****************************************************************************/    

		CREATE TABLE dbo.MSqreader_agents
		(
		id                  int IDENTITY NOT NULL,
		name                nvarchar(100) NULL,
		job_id              binary(16) NULL,
		profile_id  		int NULL
		)

      EXEC dbo.sp_MS_marksystemobject 'MSqreader_agents'

    raiserror('Creating unique index ucMSqreader_agents', 0,1)
    CREATE UNIQUE INDEX ucMSqreader_agents ON dbo.MSqreader_agents
        (id)
   END

	-- add columns for existing table
	if not exists (select * from syscolumns where 
		id = object_id('MSqreader_agents') and
		name = 'profile_id')
	begin
		alter table dbo.MSqreader_agents add profile_id int NULL
	end 
   

	IF NOT EXISTS (SELECT * FROM sysobjects WHERE name = 'MSqreader_history' and type = 'U')
	BEGIN
	/****************************************************************************/
	raiserror('Creating table MSqreader_history', 0,1)
	/****************************************************************************/    

	CREATE TABLE dbo.MSqreader_history
	(
	agent_id int NOT NULL,
	publication_id int NULL,
	runstatus int NOT NULL,
	start_time datetime NOT NULL,
	time datetime NOT NULL,
	duration int NOT NULL,
	comments nvarchar(255) NOT NULL,
	transaction_id nvarchar(40) NULL, 
	transaction_status int NULL,
	transactions_processed int NULL DEFAULT 0,
	commands_processed int NULL DEFAULT 0,
	delivery_rate float NOT NULL DEFAULT 0.0,
	transaction_rate float NOT NULL DEFAULT 0.0,
	subscriber sysname NULL,
	subscriberdb sysname NULL,
	error_id int NULL,    
	timestamp NOT NULL
	)

	EXEC dbo.sp_MS_marksystemobject 'MSqreader_history'

	raiserror('Creating clustered index ucMSqreader_history', 0,1)
	CREATE CLUSTERED INDEX ucMSqreader_history ON dbo.MSqreader_history
	(agent_id, timestamp, runstatus, start_time, time) 
	END

	-- alter column publication_id
	if not exists (select * from syscolumns where 
		id = object_id('MSqreader_history') and
		name = 'publication_id')
	begin
		alter table dbo.MSqreader_history alter column publication_id int NULL
	end

	-- add columns for existing table
	if not exists (select * from syscolumns where 
		id = object_id('MSqreader_history') and
		name = 'error_id')
	begin
		alter table dbo.MSqreader_history add error_id int NULL
	end 

	if not exists (select * from syscolumns where 
		id = object_id('MSqreader_history') and
		name = 'transactions_processed')
	begin
		alter table dbo.MSqreader_history add transactions_processed int NULL DEFAULT 0
	end 

	if not exists (select * from syscolumns where 
		id = object_id('MSqreader_history') and
		name = 'delivery_rate')
	begin
		alter table dbo.MSqreader_history add delivery_rate float NOT NULL DEFAULT 0.0
	end 

	if not exists (select * from syscolumns where 
		id = object_id('MSqreader_history') and
		name = 'transaction_rate')
	begin
		alter table dbo.MSqreader_history add transaction_rate float NOT NULL DEFAULT 0.0
	end 

	IF NOT EXISTS (SELECT * FROM sysobjects WHERE name = 'MSrepl_backup_lsns' and type = 'U')
	BEGIN
		/****************************************************************************/
		raiserror('Creating table MSrepl_backup_lsns', 0,1)
		/****************************************************************************/    

		CREATE TABLE dbo.MSrepl_backup_lsns
		(
		publisher_database_id int NOT NULL,
		valid_xact_id varbinary(16) NULL,
		valid_xact_seqno varbinary (16 ) NULL,
		next_xact_id varbinary(16) NULL,
		next_xact_seqno varbinary (16 )  NULL
		)

		EXEC dbo.sp_MS_marksystemobject 'MSrepl_backup_lsns'

		raiserror('Creating clustered index ucMSrepl_backup_lsns', 0,1)
		CREATE UNIQUE CLUSTERED INDEX ucMSrepl_backup_lsns ON dbo.MSrepl_backup_lsns
			(publisher_database_id)

		if exists (select * from MSpublisher_databases)
		begin
			/****************************************************************************/
			raiserror('Upgrading MSrepl_backup_lsns', 0,1)
			/****************************************************************************/    
			insert into MSrepl_backup_lsns select d.id, 
				NULL, NULL, NULL, NULL from MSpublisher_databases d
			-- No need to set the lsns in the table since the 'sync with backup' option is 
			-- new in 8.0
		end

	END
GO

dump tran master with no_log
go

--
-- sp_MSupdate_mqserver_distdb
--
-- This procedure is called to upgrade the MSMQ related entries in 
-- MSdistribution_agents in distribution database - this processing 
-- cannot be done directly inside sp_MScreate_dist_tables or sp_vupgrade_distdb
-- since we need the queue_server column for the processing and we can
-- get a syntax error if the table exists without the column
--
-- Assumption : MSsubscription_agents has been created 
--				and column queue_server exists
--
raiserror('Creating procedure sp_MSupdate_mqserver_distdb', 0,1)
go
create procedure sp_MSupdate_mqserver_distdb
as
begin
	if exists (select * from MSdistribution_agents
		where queue_id IS NOT NULL and substring(queue_id, 1, 10) != N'mssqlqueue' and queue_server IS NULL)
	begin
		--
		-- we have entries for active Queued subscriptions using MSMQ that need upgrade
		--
		declare @queue_server sysname

		--
		-- prepare the queue server name
		--
		select @queue_server = @@servername
		if (charindex(N'\', @queue_server) > 0)
			select @queue_server = substring(@queue_server, 1, charindex(N'\', @queue_server) - 1)

		--
		-- update the queue_server column for these entries
		--
		update MSdistribution_agents
		set queue_server = @queue_server
		where queue_id IS NOT NULL and substring(queue_id, 1, 10) != N'mssqlqueue' and queue_server IS NULL
	end
end
go

raiserror('Creating procedure sp_MSadd_distributor_alerts_and_responses', 0,1)
go
create procedure sp_MSadd_distributor_alerts_and_responses
	@from_scripting bit = 0
as

    declare @description    nvarchar(500)
    declare @category_name  sysname
    declare @agent_name     sysname
    declare @response_job   nvarchar(100)
    declare @alert_name     nvarchar(100)
    declare @alert_id       int
    declare @retcode        int

    --
    -- Add replication alert response jobs
    --
    select @category_name = name FROM msdb.dbo.syscategories where category_id = 18

    -- Add Validation failure response job
    -- (20570,10,0,'Reinitialize Subscriptions On Validation Failure.', 1033)   -- Title of a alert response job
    -- (20571,10,0,'Reiniitializes all subscriptions that have failed due to data validation failures.', 1033)  -- Description of a alert response job
    set @response_job = formatmessage(20570)
    set @description = formatmessage(20571)
    
	if @from_scripting = 0
	begin
		-- Delete the job if it already exists
		if (exists (select * from msdb..sysjobs_view where name = @response_job collate database_default))
		begin
			exec @retcode = msdb.dbo.sp_delete_job @job_name = @response_job
			if @@ERROR <> 0 or @retcode <> 0
				return (1)
		end

		execute @retcode = msdb.dbo.sp_MSadd_repl_job 
			@response_job,
			@subsystem = 'TSQL',
			@server = @@SERVERNAME,
			@databasename = 'master',
			@description = @description,
			@command = 'exec dbo.sp_MSreinit_failed_subscriptions @failure_level = 1',
			@enabled = 1,
			@loghistcompletionlevel = 0,
			@retryattempts = 0,
			@category_name = @category_name
		if @@ERROR <> 0 or @retcode <> 0
			return (1)
	end

    --
    -- Add replication alerts
    --

    -- Get Replication category name (assumes category_id = 20)
    select @category_name = name FROM msdb.dbo.syscategories where category_id = 20

    -- Add Failure Alert
    set @alert_name = formatmessage(20536)  
    set @alert_id = 14151 -- corresponding to formatmessage(20536),  Failure alert
    if not exists (select * from msdb.dbo.sysalerts where message_id = @alert_id)
    begin
        exec @retcode = msdb.dbo.sp_add_alert @enabled = 0, @name = @alert_name, @category_name = @category_name, @message_id = 14151
        if @@error <> 0 or @retcode <> 0
            return 1
    end

    -- Add Retry Alert
    set @alert_name=formatmessage(20537)
    set @alert_id = 14152 -- corresponding to formatmessage(20537),  Retry alert
    if not exists (select * from msdb.dbo.sysalerts where message_id = @alert_id)
    begin
        exec @retcode = msdb.dbo.sp_add_alert @enabled = 0, @name = @alert_name, @category_name = @category_name, @message_id = 14152
        if @@error <> 0 or @retcode <> 0
            return 1
    end

    -- Add Success Alert
    set @alert_name=formatmessage(20540)
    set @alert_id = 14150 -- corresponding to formatmessage(20540), 
    if not exists (select * from msdb.dbo.sysalerts where message_id = @alert_id)
    begin
        exec @retcode = msdb.dbo.sp_add_alert @enabled = 0, @name = @alert_name, @category_name = @category_name, @message_id = 14150
        if @@error <> 0 or @retcode <> 0
            return 1
    end

    -- Add Shutdown request Alert
    set @alert_name=formatmessage(20578)
    set @alert_id = 20578 --  Custom agent shutdown message
    if not exists (select * from msdb.dbo.sysalerts where message_id = @alert_id)
    begin
        exec @retcode = msdb.dbo.sp_add_alert @enabled = 0, @name = @alert_name, @category_name = @category_name, @message_id = 20578
        if @@error <> 0 or @retcode <> 0
            return 1
    end

    -- Add Validation Failure Alert
    set @alert_name=formatmessage(20565)
    set @alert_id = 20574 -- corresponding to formatmessage(20574), 
    if not exists (select * from msdb.dbo.sysalerts where message_id = @alert_id)
    begin
        exec @retcode = msdb.dbo.sp_add_alert @enabled = 0, @name = @alert_name, @category_name = @category_name, @message_id = 20574
        if @@error <> 0 or @retcode <> 0
            return 1
    end

    -- Add Validation Success Alert
    set @alert_name=formatmessage(20566)
    set @alert_id = 20575 -- corresponding to formatmessage(20575), 
    if not exists (select * from msdb.dbo.sysalerts where message_id = @alert_id)
    begin
        exec @retcode = msdb.dbo.sp_add_alert @enabled = 0, @name = @alert_name, @category_name = @category_name, @message_id = 20575
        if @@error <> 0 or @retcode <> 0
            return 1
    end

    -- Add Reinitialized after Validation Failure
    set @alert_name=formatmessage(20573)
    set @alert_id = 20572 -- corresponding to formatmessage(20566),  
    if not exists (select * from msdb.dbo.sysalerts where message_id = @alert_id)
    begin
        exec @retcode = msdb.dbo.sp_add_alert @enabled = 0, @name = @alert_name, @category_name = @category_name, @message_id = 20572
        if @@error <> 0 or @retcode <> 0
            return 1
    end

GO


raiserror('Creating procedure sp_MSdrop_distributor_alerts_and_responses', 0,1)
go
create proc sp_MSdrop_distributor_alerts_and_responses
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
raiserror('Creating procedure sp_adddistributor', 0,1)
go

CREATE PROCEDURE sp_adddistributor (
    @distributor sysname,            /* distributor server name */
    @heartbeat_interval int = 10,    -- minutes
    @password sysname = NULL,
	@from_scripting bit = 0

) AS

    SET NOCOUNT ON

    /*
    ** Declarations.
    */
    DECLARE @retcode int
    DECLARE @agentname nvarchar(100)
    DECLARE @command nvarchar(255)
    DECLARE @distribution_db sysname
    DECLARE @distproc nvarchar(255)
    DECLARE @dist_rpcname sysname
    DECLARE @server_added bit
    declare @login sysname

    select @server_added = 0 
    select @login = 'distributor_admin'

    /* 
    ** Check if replication components are installed on this server
    */
    exec @retcode = dbo.sp_MS_replication_installed
    if (@retcode <> 1)
    begin
        return (1)
    end

    -- Must be at master db.
    IF db_name() <> 'master'
    BEGIN
        RAISERROR(5001, 16,-1)
        return (1)
    END
    /*
    ** Parameter Check:  @distributor.
    ** Check to make sure that the distributor is not NULL and that it
    ** conforms to the rules for identifiers.
    */
    IF @distributor IS NULL
        BEGIN
            RAISERROR (14043, 16, -1, '@distributor')
            RETURN (1)
        END

    EXECUTE @retcode = dbo.sp_validname @distributor

    IF @@ERROR <> 0 OR @retcode <> 0
       RETURN (1)

	IF @password = N''
	    select @password = NULL
	
	-- Seed default password with random value only for a local distributor.
	IF (@password is null) AND (UPPER(@@SERVERNAME) = UPPER(@distributor)) 
		select @password = convert(sysname, newid())
    /*
    ** Check to make sure that the distributor doesn't already exist.
    */
    SELECT @dist_rpcname = NULL
    SELECT @dist_rpcname = srvname FROM master..sysservers
              WHERE  srvstatus & 8 <> 0
    IF @dist_rpcname IS NOT NULL
    BEGIN
        RAISERROR (14099, 16, -1, @dist_rpcname)
        RETURN(1)
    END

    -- drop repl_distributor if it exists.
    if exists (select * from master..sysservers where lower(srvname) = 
        'repl_distributor' collate database_default)
    begin
        exec @retcode = dbo.sp_dropserver 'repl_distributor', 'droplogins'
        IF @@error <> 0 OR @retcode <> 0
        BEGIN
            RETURN(1)
        END
    end

    -- Add the linked server entry for the distributor
    -- Note we do this even for local server for consistancy
    EXECUTE @retcode = dbo.sp_addserver  'repl_distributor'
    IF @@error <> 0 OR @retcode <> 0
    BEGIN
        RETURN (1)
    END

    select @server_added = 1

    -- Mark system link
    EXECUTE @retcode = dbo.sp_serveroption  'repl_distributor', 'system','true'
    IF @@error <> 0 OR @retcode <> 0
    BEGIN
        RETURN (1)
    END

    EXECUTE @retcode = dbo.sp_setnetname  'repl_distributor', @distributor
    IF @@error <> 0 OR @retcode <> 0
    BEGIN
        goto UNDO
    END
        
    exec @retcode = dbo.sp_addlinkedsrvlogin 
        @rmtsrvname= 'repl_distributor',
        @useself = 'false',
        @locallogin = NULL,
        @rmtuser = @login,
        @rmtpassword = @password
    IF @@error <> 0 OR @retcode <> 0
    BEGIN
        goto UNDO
    END


    /*
    ** If this is not the local server, remote distributor must be set up first
    */
    IF UPPER(@distributor) <> UPPER(@@SERVERNAME)
    BEGIN
	/* Check distributor version, 7.0 distributor should error out*/
	declare @dist_ver int
	select @dist_ver = 0
	EXEC @retcode = repl_distributor.master.dbo.sp_executesql N'select @dist_ver = @@microsoftversion', 
									N'@dist_ver int output', @dist_ver output
	IF (@retcode <> 0 or @@ERROR <> 0)
	begin
            GOTO UNDO
	end
	if (@dist_ver < 0x07320000 )
	begin
            RAISERROR (21320,16,-1)
            GOTO UNDO
	end
        /*
        ** Test to see if the local server is defined as publisher
        ** at the remove distributor.
        ** Note: cannot call sp_helpdistributor locally since the server is not
        ** marked for distribution.
        ** We can not move the serveroption call before this RPC because RPC failure
        ** may cause the SP to terminate. Thus, we can not UNDO the server option.
        */
        SELECT @distproc = 'repl_distributor.master.dbo.sp_helpdistributor'
    
        DECLARE @loc_directory             nvarchar(255)
        DECLARE @loc_account             nvarchar(255)
        DECLARE @loc_mindistretention     int
        DECLARE @loc_maxdistretention     int
        DECLARE @loc_historyretention   int  
        DECLARE @loc_historycleanupagent nvarchar(100)
        DECLARE @loc_distribcleanupagent nvarchar(100)
        DECLARE @alert_name nvarchar(100)
        DECLARE @alert_id int

        EXECUTE @distproc
            @distributor OUTPUT,
            @distribution_db OUTPUT,
            @loc_directory OUTPUT,
            @loc_account OUTPUT,
            @loc_mindistretention OUTPUT,
            @loc_maxdistretention OUTPUT,
            @loc_historyretention OUTPUT,
            @loc_historycleanupagent OUTPUT,
            @loc_distribcleanupagent OUTPUT,
            @@SERVERNAME,
            @local = 'local'

        IF @@error <> 0 OR @retcode <> 0 OR @distribution_db is NULL
        BEGIN
            RAISERROR (21007,16,-1)
            GOTO UNDO
        END

        /* Activate the dist publisher at the remote distributor */
        SELECT @distproc = 'repl_distributor.master.dbo.sp_changedistpublisher'
            EXECUTE @retcode = @distproc @@SERVERNAME, 'active','true'
        IF @@error <> 0 OR @retcode <> 0
        BEGIN
            GOTO UNDO
        END
    END
    ELSE
    /* set the registry */
    BEGIN
        EXEC @retcode = dbo.sp_MScreate_distributor_tables 
        if @@error <> 0 or @retcode <> 0
            goto UNDO

        declare @distributor_login sysname
        select @distributor_login = 'distributor_admin'

        -- Add publisher rpc login
        if not exists (select * from master..syslogins where loginname = @distributor_login collate database_default)
        begin
            EXEC @retcode = dbo.sp_addlogin @loginame = @distributor_login,
				@passwd = @password
            if @@error <> 0 or @retcode <> 0
                goto UNDO
        end
		else
		begin
			-- Change the password if the distributor is local
			EXEC @retcode = dbo.sp_password NULL, @password, 'distributor_admin'
			if @@error <> 0 or @retcode <> 0
				goto UNDO
		end

        -- Add the login to sysadmin
        -- Refer to sp_MSpublication_access in distribution db
        if is_srvrolemember('sysadmin', @distributor_login) <> 1
        begin
            exec @retcode = dbo.sp_addsrvrolemember @distributor_login, 'sysadmin'
            IF @@error <> 0 OR @retcode <> 0
                GOTO UNDO
        end

		if @from_scripting <> 1
		begin
			-- Add Replication Agent Checkup Agent
			exec @retcode = dbo.sp_MScreate_replication_checkup_agent @heartbeat_interval = @heartbeat_interval
			if @@error <> 0 or @retcode <> 0
				goto UNDO
		end
        
        delete msdb..MSdistributor where property = 'heartbeat_interval'
        if @@error <> 0
            goto UNDO
        insert into msdb..MSdistributor (property, value) values ('heartbeat_interval',
            convert(nvarchar(10), @heartbeat_interval))
        if @@error <> 0 
            goto UNDO

        -- Add Replication Alerts and Response Jobs
        exec @retcode = dbo.sp_MSadd_distributor_alerts_and_responses
			@from_scripting = @from_scripting
        if @@error <> 0 or @retcode <> 0
            goto UNDO
    
    END


    /*
    ** Set the server option to indicate that this is a distributor.
    ** 
    */
    EXECUTE @retcode = dbo.sp_serveroption 'repl_distributor', 'dist', true
    IF @@error <> 0 OR @retcode <> 0
    BEGIN
        GOTO UNDO
    END

    -- Set sp_MSrepl_startup to be a startup stored procedure
    -- Note: This needs to be after the marking the distribution server
    exec @retcode = dbo.sp_procoption 'sp_MSrepl_startup', 'startup', 'true' 
    if @@error <> 0 or @retcode <> 0
        goto UNDO1

    exec @retcode = dbo.sp_MSrepl_startup
    if @@error <> 0 or @retcode <> 0
        goto UNDO1

    RETURN (0)

UNDO1:
    exec dbo.sp_serveroption 'repl_distributor', 'dist', false

UNDO:
    IF @server_added = 1
    begin
        -- Drop the remote logins, otherwise, sp_dropserver will fail.
        EXECUTE dbo.sp_dropserver 'repl_distributor', 'droplogins'
    end
    
    RETURN (1)
GO
 

raiserror('Creating procedure sp_changedistributor_property', 0,1)
go

CREATE PROCEDURE sp_changedistributor_property (
    @property sysname     = NULL,       /* The property to change */
    @value nvarchar(255)  = NULL        /* The new property value */
    ) AS

    declare @retcode int
    declare @new_heartbeat_interval int 

    -- Check to make sure the local server is a distributor
    if not exists (SELECT * FROM master..sysservers
              WHERE  srvstatus & 8 <> 0 and
              UPPER(datasource) = UPPER(@@servername) collate database_default)
    begin
        RAISERROR (14114, 16, -1, @@SERVERNAME)
        return(1)
    end

    -- Return list of properties if @property is NULL
    if @property is NULL
    begin
        create table #tab1 (properties sysname collate database_default not null)
        insert into #tab1 values ('heartbeat_interval')
        select * from #tab1
        return (0)
    end

    if @property is NULL
    begin
        if exists (select name from msdb..sysobjects where name = 'MSdistributor')
        begin
            select property from msdb..MSdistributor
            return 0
        end
        return 1
    end

    -- Check for valid property
    IF LOWER(@property collate SQL_Latin1_General_CP1_CS_AS) NOT IN ('heartbeat_interval')
    BEGIN
        RAISERROR (14154, 16, -1)
        RETURN (1)
    END

    if LOWER(@property collate SQL_Latin1_General_CP1_CS_AS) = 'heartbeat_interval'
    begin
        if exists (select name from msdb..sysobjects where name = 'MSdistributor')  
        begin
            update msdb..MSdistributor set value = @value where property = @property
            if @@error <> 0
                return 1
            select @new_heartbeat_interval = CONVERT(int, @value)
            exec @retcode = dbo.sp_MScreate_replication_checkup_agent @heartbeat_interval = 
                @new_heartbeat_interval
            if @@error <> 0 or @retcode <> 0
                return 1
        end
        else 
            return 1
    end

    return (0)

GO

raiserror('Creating procedure sp_helpdistributor_properties', 0,1)
go

CREATE PROCEDURE sp_helpdistributor_properties 
     AS

    if exists (select name from msdb..sysobjects where name = 'MSdistributor')
    begin
        -- There is currently only one property, so this will work
        select 'heartbeat_interval' = convert(int, value) from msdb..MSdistributor where
            property = 'heartbeat_interval'
        return (0)
    end
    return (1)
GO

raiserror('Creating procedure sp_dropdistributor', 0,1)
go

CREATE PROCEDURE sp_dropdistributor
@no_checks bit = 0,
@ignore_distributor bit = 0
AS

    SET NOCOUNT ON

    /*
    ** Declarations.
    */
    DECLARE @retcode int
    DECLARE @distributor sysname
    DECLARE @agentname nvarchar(100)
    DECLARE @distbit int
    DECLARE @distribdb sysname
    DECLARE @foundSubscriber int
    DECLARE @proc nvarchar(255) 
    declare @optname sysname
    declare @name sysname
    DECLARE @transpublishdb_bit int
    DECLARE @mergepublishdb_bit int
    declare @job_name nvarchar(100)
    declare @alert_name nvarchar(100)

    declare @dist_rpcname sysname

    declare @alert_id   int
   
    SELECT @transpublishdb_bit = 1
    SELECT @mergepublishdb_bit = 4
    SELECT @foundSubscriber = 0
    SELECT @distbit = 16

    -- Get distributor name
    select @distributor = datasource, @dist_rpcname = srvname from master..sysservers 
        WHERE srvstatus & 8 <> 0
    if @distributor is null
    BEGIN
        RAISERROR (21043, 16, -1)
        RETURN(1)
    END

    if @no_checks = 1
    begin
        -- We are in bruteforce cleanup mode, drop everything.
        DECLARE hCdropdistributor CURSOR LOCAL FAST_FORWARD FOR
                SELECT name, N'publish' FROM master..sysdatabases      
                    WHERE (category & @transpublishdb_bit) <> 0 
                UNION
                select name, N'merge publish' from master..sysdatabases
                    WHERE (category & @mergepublishdb_bit) <> 0
                FOR READ ONLY

        OPEN hCdropdistributor
        FETCH hCdropdistributor INTO @name, @optname
    
        WHILE (@@fetch_status <> -1)
        BEGIN
                        
            EXECUTE @retcode  = dbo.sp_replicationdboption 
              @dbname = @name,
              @optname = @optname,
              @value = 'false',
              @ignore_distributor = @ignore_distributor
            
            IF @@ERROR <> 0 OR @retcode <> 0
            BEGIN
                CLOSE hCdropdistributor
                DEALLOCATE hCdropdistributor
                RETURN (1)
            END
            FETCH hCdropdistributor INTO @name, @optname
        end

        CLOSE hCdropdistributor
        DEALLOCATE hCdropdistributor
    
        -- Drop subscriber
        EXECUTE @retcode  = dbo.sp_dropsubscriber
          @subscriber = 'all',
          @ignore_distributor = @ignore_distributor

        IF @@ERROR <> 0 OR @retcode <> 0
            RETURN (1)

        IF UPPER(@distributor) = UPPER(@@SERVERNAME) 
        begin
            -- Clean up dist publishers
            DECLARE hCdropdistributor CURSOR LOCAL FAST_FORWARD FOR
                    SELECT name FROM msdb..MSdistpublishers
            FOR READ ONLY

            OPEN hCdropdistributor
            FETCH hCdropdistributor INTO @name

            WHILE (@@fetch_status <> -1)
            BEGIN
                exec @retcode = dbo.sp_dropdistpublisher
                    @publisher = @name,
                    @no_checks = 1
            
                IF @@ERROR <> 0 OR @retcode <> 0
                BEGIN
                    CLOSE hCdropdistributor
                    DEALLOCATE hCdropdistributor
                    RETURN (1)
                END
                FETCH hCdropdistributor INTO @name
            end

            CLOSE hCdropdistributor
            DEALLOCATE hCdropdistributor

            -- Clean up distribution dbs
            DECLARE hCdropdistributor CURSOR LOCAL FAST_FORWARD FOR
                    SELECT name FROM msdb..MSdistributiondbs
            FOR READ ONLY

            OPEN hCdropdistributor
            FETCH hCdropdistributor INTO @name
    
            WHILE (@@fetch_status <> -1)
            BEGIN
                exec @retcode = dbo.sp_dropdistributiondb
                    @database = @name

                IF @@ERROR <> 0 OR @retcode <> 0
                BEGIN
                    CLOSE hCdropdistributor
                    DEALLOCATE hCdropdistributor
                    RETURN (1)
                END
                FETCH hCdropdistributor INTO @name
            end

            CLOSE hCdropdistributor
            DEALLOCATE hCdropdistributor
        end
    end
    
    -- If everything should be cleaned up when we reach here with @no_checks = 1
    /*
    ** If local distributor, check if there are any distributor databases
    */
    IF UPPER(@distributor) = UPPER(@@SERVERNAME) 
    BEGIN
        IF EXISTS (SELECT * FROM msdb..MSdistributiondbs)
        BEGIN
            RAISERROR (14121, 16, -1, @distributor)
            RETURN(1)
        END
    END
    ELSE
    begin
        -- Check to see if there are database published.
        if exists (SELECT * FROM master..sysdatabases      
            WHERE (category & @transpublishdb_bit) <> 0 or 
            (category & @mergepublishdb_bit) <> 0)
        begin
            raiserror(21045, 16, -1)
            return(1)
        end

        -- Check to see if there are subscribers defined.
        if exists (SELECT *
                     FROM master..sysservers
                    WHERE srvstatus & 4 <> 0)
        begin
            raiserror(21008, 16, -1)
            return(1)
        end
    end


    /*
    ** if @ignore_distributor = 1, we are in bruteforce cleanup mode, don't do RPC.
    */
    if @ignore_distributor = 0 
    begin
        /*
        ** Get distribution server information
        */
        EXEC @retcode = dbo.sp_helpdistributor @publisher = @@SERVERNAME,
            @distribdb = @distribdb OUTPUT
        IF @@error <> 0 OR @retcode <> 0
        BEGIN
            RAISERROR (14071, 16, -1)
            RETURN (1)
        END

        IF @distribdb is NOT NULL
        BEGIN
            /* 
            ** Deactivate the dist publisher at the  distributor 
            ** Only do this if @distribdb is NOT NULL, which means the dist publisher
            ** if defined.
            */
            SELECT @proc = RTRIM(@dist_rpcname) + '.master.dbo.sp_changedistpublisher'
                EXECUTE @retcode = @proc @@SERVERNAME, 'active','false'
            IF @@error <> 0 OR @retcode <> 0
            BEGIN
                RETURN (1)
            END
        END
    end


    /*
    ** Clear the server option to indicate that this is a distributor.
    */
    EXECUTE @retcode = dbo.sp_serveroption @dist_rpcname, 'dist', false
    IF @@error <> 0 OR @retcode <> 0
        BEGIN
            RETURN(1)
        END

    -- Prevent dropping local server entry accidentally if user 
    -- set 'dist' server option on local server.
    if UPPER(@dist_rpcname) <> UPPER(@@servername)
    begin
        exec @retcode = dbo.sp_dropserver @dist_rpcname, 'droplogins'
        IF @@error <> 0 OR @retcode <> 0
        BEGIN
            RETURN(1)
        END
    end


    -- Drop table after unmark distributor to prevent 
    -- sp_helpdist* failures.

    /* If local, Drop replication category and alerts */
    IF UPPER(@distributor) = UPPER(@@SERVERNAME)
    BEGIN

	-- Attempts to drop distributor_login, no big deal if it's still in use and we can't drop, don't quit here.

       	declare @distributor_login sysname
        select @distributor_login = 'distributor_admin'

        if exists (select * from master..syslogins where loginname = @distributor_login collate database_default)
        begin
            EXEC @retcode = dbo.sp_droplogin @loginame = @distributor_login
	end

        -- Drop Distributor Alerts and Jobs
        exec @retcode = dbo.sp_MSdrop_distributor_alerts_and_responses
        IF @@ERROR <> 0 or @retcode <> 0
        BEGIN
            return (1)            
        END

        -- Drop the two system tables.
        if exists (select * from msdb..sysobjects where name = 'MSdistpublishers'
            and xtype = 'U')
            drop table msdb..MSdistpublishers
    
        if @@error <> 0 
            return 1 ;

        if exists (select * from msdb..sysobjects where name = 'MSdistributiondbs'
            and xtype = 'U')
            drop table msdb..MSdistributiondbs

        if @@error <> 0
            return 1 ;

        if exists (select * from msdb..sysobjects where name = 'MSdistributor'
                and xtype = 'U')
            drop table msdb..MSdistributor

        if @@error <> 0
            return 1 ;

        if exists (select * from msdb..sysobjects where name = 'sysreplicationalerts'
                and xtype = 'U')
            drop table msdb..sysreplicationalerts

        if @@error <> 0
            return 1 ;


        if exists (select * from msdb..sysobjects where name = 'MSagent_profiles'
            and xtype = 'U')
            drop table msdb..MSagent_profiles

        if @@error <> 0
            return 1 ;


       if exists (select * from msdb..sysobjects where name = 'MSagent_parameters'
                and xtype = 'U')
            drop table msdb..MSagent_parameters

        if @@error <> 0
            return 1 ;

    END

    -- Nnregister sp_MSrepl_startup as a startup stored procedure
    exec @retcode = dbo.sp_procoption 'sp_MSrepl_startup', 'startup', 'false' 
    if @@error <> 0 or @retcode <> 0
        return 1

    RETURN (0)        
GO

dump tran master with NO_LOG
go

raiserror('Creating procedure sp_helpdistributiondb', 0,1)
go

CREATE PROCEDURE sp_helpdistributiondb (
    @database sysname = '%'
    ) AS

    SET NOCOUNT ON

    declare @retcode int
    declare @cmd    nvarchar(500)

    /*
    ** Check to make sure this is a distributor
    */
    IF NOT EXISTS (select * from master..sysservers
              where UPPER(datasource) = UPPER(@@SERVERNAME) collate database_default
                 AND srvstatus & 8 <> 0)
    begin
    if @database <> '%' 
    begin
            raiserror (14114, 16, -1, @@SERVERNAME)
            return(1)
    end
    else
       return(0)
    end

    IF NOT EXISTS (select * from msdb..sysobjects where name = 'MSdistributiondbs' and type = 'U')
    begin
        raiserror (14071, 16, -1)
        return(1)
    end    

    /*
    ** Check if database is configured as a distributor database
    */
    IF @database <> '%' AND NOT EXISTS (select * from msdb..MSdistributiondbs where name = @database collate database_default)
    begin
        raiserror (14117, 16, -1, @database)
        return(1)
    end    

    -- Begin from sp_helpdb

    /*  Create temp table before any DMP to enure dynamic
    **  Since we examine the status bits in sysdatabase and turn them
    **  into english, we need a temporary table to build the descriptions.
    */
    create table #spdbdesc
    (
        dbid    smallint    null,
        dbdesc  nvarchar(175)   collate database_default null
    )
    if @@error<>0
    begin
        return(1)
    end

    /* 
    ** Since we need to execute dynamic SQL to get the list of files, create a temp 
    ** table to keep file descriptions
    */
    create table #spfiledesc
    (
        dbid    smallint        not null,
        fileid  smallint        not null,
        status  int        not null,
        size    int             not null,
        name    sysname         collate database_default not null,
        filename nvarchar(260)   collate database_default not null
    )   
    if @@error<>0
    begin
        return(1)
    end

    /*
    **  Initialize #spdbdesc from sysdatabases
    */
    insert into #spdbdesc (dbid)
            select dbid 
              from master.dbo.sysdatabases d 
        inner join msdb.dbo.MSdistributiondbs dist
                on dist.name = d.name collate database_default 
             where dist.name like @database collate database_default
               and has_dbaccess(d.name) = 1

    declare @name sysname

    /* 
    ** Insert the list of all files into #spfiledesc
    */
    declare c1 CURSOR LOCAL FAST_FORWARD FOR 
        select db_name (dbid) from #spdbdesc
    open c1
    fetch c1 into @name
    while @@fetch_status >= 0
    begin

        /* Insert row for each database */
        select @cmd =  ('insert into #spfiledesc
                select db_id (N'+ QUOTENAME(@name,'''') + '), fileid, status, size, RTRIM(name), RTRIM(filename) from' 
                + ' ' + QUOTENAME(@name) + '.dbo.sysfiles')
        exec (@cmd)
        fetch c1 into @name
    end
    deallocate c1

    SELECT dist.name, min_distretention, max_distretention, history_retention,
        'history_cleanup_agent' =  formatmessage (20567, dist.name),
        'distributor_cleanup_agent' = formatmessage(20568, dist.name),
        'status'= 0, 

        -- Refer to sp_helpdb for the following query.
        'data_folder' = substring(v_data.filename, 1, len(v_data.filename) - charindex('\', reverse(v_data.filename))),
        'data_file' = right(v_data.filename, charindex('\', reverse(v_data.filename))-1),
        'data_file_size' = CONVERT(int, (select low from master.dbo.spt_values
            where type = 'E'
                and number = 1)
            * convert(dec(15), v_data.size)/ 1048576),
    
        'log_folder' = substring(v_log.filename, 1, len(v_log.filename) - charindex('\', reverse(v_log.filename))),
        'log_file' = right(v_log.filename, charindex('\', reverse(v_log.filename))-1),
        'log_file_size' = CONVERT(int, (select low from master.dbo.spt_values
            where type = 'E'
                and number = 1)
            * convert(dec(15), v_log.size)/ 1048576)
        
        FROM msdb.dbo.MSdistributiondbs dist,
        master.dbo.sysdatabases d, #spfiledesc v_data,
        #spfiledesc v_log
        WHERE dist.name LIKE @database collate database_default
            
            and v_data.dbid = d.dbid 
            and v_data.dbid > 0 
            and v_data.status & 2 = 2
            and v_data.status & 0x40 = 0 -- data
            and v_data.fileid = (select min(v_data2.fileid) from #spfiledesc v_data2 where
                    v_data2.dbid = d.dbid 
                and v_data2.dbid > 0    
                and v_data2.status & 2 = 2
                and v_data2.status & 0x40 = 0 ) -- data

            
            and v_log.dbid = d.dbid 
            and v_log.dbid > 0  
            and v_log.status & 2 = 2
            and v_log.status & 0x40 = 0x40 -- log
            and v_log.fileid = (select min(v_log2.fileid) from #spfiledesc v_log2 where
                    v_log2.dbid = d.dbid 
                and v_log2.dbid > 0 
                and v_log2.status & 2 = 2
                and v_log2.status & 0x40 = 0x40 ) -- log

            and d.name = dist.name collate database_default
GO
 

dump tran master with no_log
GO

raiserror('Creating procedure sp_changedistributiondb', 0,1)
go

CREATE PROCEDURE sp_changedistributiondb (
    @database sysname,
    @property sysname     = NULL,     /* The property to change */
    @value nvarchar(255)     = NULL      /* The new property value */
    ) AS

    SET NOCOUNT ON

    /*
    ** Declarations.
    */
    DECLARE @distributor sysname
    DECLARE @min_distretention     int
    DECLARE @max_distretention     int
    DECLARE @retcode             int
    DECLARE @new_min_distretention     int
    DECLARE @new_max_distretention     int
    DECLARE @new_history_retention     int
    DECLARE @agentname nvarchar(100)
    DECLARE @command nvarchar(255)
    DECLARE @security_mode int
    DECLARE @distbit int

    SELECT @distbit = 16

    /*
    ** Parameter Check:  @property.
    ** If the @property parameter is NULL, print the options.
    */

    IF @property IS NULL
        BEGIN
            CREATE TABLE #tab1 (properties sysname collate database_default not null)
            INSERT INTO #tab1 VALUES ('min_distretention')
            INSERT INTO #tab1 VALUES ('max_distretention')
            INSERT INTO #tab1 VALUES ('history_retention')
            SELECT * FROM #tab1
            RETURN (0)
        END

    /*
    ** Parameter Check:  @property.
    ** Check to make sure that @property is a valid property in
    ** sysarticles.
    */
    IF @property IS NULL OR LOWER(@property collate SQL_Latin1_General_CP1_CS_AS) NOT IN 
                                                    ('min_distretention',
                                                     'max_distretention',
                                                     'history_retention')
             
        BEGIN

            RAISERROR (14115, 16, -1, 
            '''min_distretention'', ''max_distretention'' or ''history_retention''')
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
    ** Check if database is configured as a distributor database
    */
    IF NOT EXISTS (SELECT * FROM master..sysdatabases
              WHERE name = @database collate database_default
                 AND category & @distbit <> 0)
    BEGIN
        RAISERROR (14117, 16, -1, @database)
        RETURN(1)
    END
    
    /*
    ** Change the property.
    */
    IF LOWER(@property collate SQL_Latin1_General_CP1_CS_AS) = 'min_distretention'
        BEGIN
            IF @value IS NULL
                BEGIN
                    RAISERROR (14043, 16, -1, '@value') 
                    RETURN (1)
                END

            /*
            ** Set the MinDistRetention registry key value
            */
            SELECT @new_min_distretention = CONVERT(int, @value)

            /*
            ** Get MaxDistRetention value
            */
            SELECT @max_distretention = max_distretention FROM msdb..MSdistributiondbs
                WHERE name = @database collate database_default
                
            /* 
            ** Check for invalid retention values 
            */
            IF @new_min_distretention < 0
                BEGIN
                       RAISERROR(14106, 16, -1)
                    RETURN (1)
                END
            IF @new_min_distretention > @max_distretention
                BEGIN
                    RAISERROR(14107, 16, -1) 
                    RETURN (1)
                END

            UPDATE msdb..MSdistributiondbs SET min_distretention = @new_min_distretention
                WHERE name = @database collate database_default
            IF @@error <> 0 
                BEGIN
                    RETURN (1)
                END

            /*
            ** Update Distribution Cleanup agent 
            */
    		select @agentname = name from msdb..sysjobs j, msdb..sysjobsteps s where 
			j.job_id = s.job_id and
			j.category_id = 11 and
			s.database_name = @database collate database_default
        
			SELECT @command =  'EXEC dbo.sp_MSdistribution_cleanup @min_distretention = ' + 
                CONVERT(nvarchar(12), @new_min_distretention) + ', @max_distretention = ' +
                CONVERT(nvarchar(12), @max_distretention)
            EXEC @retcode = msdb.dbo.sp_update_jobstep @job_name = @agentname, @step_id = 1, 
                @command = @command
            IF @@error <> 0 OR @retcode <> 0
               RETURN(1)

        END

    IF LOWER(@property collate SQL_Latin1_General_CP1_CS_AS) = 'max_distretention'
        BEGIN
            IF @value IS NULL
                BEGIN
                    RAISERROR (14043, 16, -1, '@value') 
                    RETURN (1)
                END

            /*
            ** Set the MaxDistRetention registry key value
            */
            SELECT @new_max_distretention = CONVERT(int, @value)

            /*
            ** Get MinDistRetention value
            */
            SELECT @min_distretention = min_distretention FROM msdb..MSdistributiondbs
                WHERE name = @database collate database_default

            /* 
            ** Check for invalid retention values 
            */
            IF @new_max_distretention < 0
                BEGIN
                       RAISERROR(14106, 16, -1)
                    RETURN (1)
                END
            IF @new_max_distretention < @min_distretention
                BEGIN
                    RAISERROR(14107, 16, -1) 
                    RETURN (1)
                END

            UPDATE msdb..MSdistributiondbs SET max_distretention = @new_max_distretention
                WHERE name = @database collate database_default
            IF @@error <> 0 
                BEGIN
                    RETURN (1)
                END
            /*
            ** Update Distribution Cleanup agent 
            */
			select @agentname = name from msdb..sysjobs j, msdb..sysjobsteps s where 
				j.job_id = s.job_id and
				j.category_id = 11 and
				s.database_name = @database collate database_default
            SELECT @command =  'EXEC dbo.sp_MSdistribution_cleanup @min_distretention = ' + 
                CONVERT(nvarchar(12), @min_distretention) + ', @max_distretention = ' +
                CONVERT(nvarchar(12), @new_max_distretention)
            EXEC @retcode = msdb.dbo.sp_update_jobstep @job_name = @agentname, @step_id = 1, 
                @command = @command
            IF @@error <> 0 OR @retcode <> 0
               RETURN(1)
        END

    IF LOWER(@property collate SQL_Latin1_General_CP1_CS_AS) = 'history_retention'
        BEGIN
            IF @value IS NULL
                BEGIN
                    RAISERROR (14043, 16, -1, '@value') 
                    RETURN (1)
                END

            /*
            ** Set the HistoryRetention registry key value
            */
            SELECT @new_history_retention = CONVERT(int, @value)

            UPDATE msdb..MSdistributiondbs SET history_retention = @new_history_retention
                WHERE name = @database collate database_default
            IF @@error <> 0 
                BEGIN
                    RETURN (1)
                END

            /*
            ** Update History Cleanup agent 
            */
			select @agentname = name from msdb..sysjobs j, msdb..sysjobsteps s where 
				j.job_id = s.job_id and
				j.category_id = 12 and
				s.database_name = @database collate database_default
            SELECT @command =  'EXEC dbo.sp_MShistory_cleanup @history_retention = ' + 
                CONVERT(nvarchar(12), @new_history_retention)
            EXEC @retcode = msdb.dbo.sp_update_jobstep @job_name = @agentname, @step_id = 1, 
                @command = @command
            IF @@error <> 0 OR @retcode <> 0
               RETURN(1)

        END




    /*
    ** Return succeed.
    */
    RAISERROR (14105, 10, -1, @property)
    RETURN (0)
go
 
raiserror('Creating procedure sp_dropdistributiondb', 0,1)
go

CREATE PROCEDURE sp_dropdistributiondb (
    @database sysname        
    
) AS

    SET NOCOUNT ON
    /*
    ** Declarations.
    */
    DECLARE @retcode int
    DECLARE @agentname nvarchar(100)
    DECLARE @reg_key nvarchar(255)
    DECLARE @security_mode int
    DECLARE    @distbit int
    DECLARE @distpublisher sysname
    DECLARE @distdb sysname
    DECLARE @device_name sysname
    DECLARE @command nvarchar(255)

    SELECT @distbit = 16

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
    ** Check if database is configured as a distributor database
    */
    IF NOT EXISTS (SELECT * FROM msdb..MSdistributiondbs WHERE name = @database collate database_default)
    BEGIN
        RAISERROR (14117, 16, -1, @database)
        RETURN(1)
    END

    /*
    ** Check if any DistPublishers are using this database
    */
    IF EXISTS (SELECT * FROM msdb..MSdistpublishers WHERE
        distribution_db = @database collate database_default)
    BEGIN
        RAISERROR (14120, 16, -1, @database)
        RETURN (1)
    END
    
	/*
	** Check if the DB is being currently used
	*/
	IF EXISTS (SELECT * FROM master..sysprocesses WHERE
		dbid = DB_ID(@database))
	BEGIN
		RAISERROR (21122, 16, 1, @database)
		RETURN (1)
	END
	   

    /*
    ** Drop the history cleanup agent.
    */
    -- Get agent name
    select @agentname = null
	select @agentname = name from msdb..sysjobs j, msdb..sysjobsteps s where 
		j.job_id = s.job_id and
		j.category_id = 12 and
		s.database_name = @database collate database_default

    if @agentname is not null
    BEGIN
        EXEC @retcode = msdb.dbo.sp_delete_job 
            @job_name = @agentname
        IF @@ERROR <> 0 or @retcode <> 0
        BEGIN
            RETURN(1)
        END
    END

    /*
    ** Drop the distribution cleanup agent.
    */
    select @agentname = null
    select @agentname = name from msdb..sysjobs j, msdb..sysjobsteps s where 
				j.job_id = s.job_id and
				j.category_id = 11 and
				s.database_name = @database collate database_default
    if @agentname is not null
    BEGIN
        EXEC @retcode = msdb.dbo.sp_delete_job 
            @job_name = @agentname
        IF @@ERROR <> 0 or @retcode <> 0
        BEGIN
            RETURN(1)
        END
    END

    /*
    ** Update sysdatabase category bit before dropping the database
    ** Otherwise, the database can not be dropped.
    **
    */
    UPDATE master..sysdatabases SET category = category & ~@distbit WHERE name = @database collate database_default
    IF @@ERROR <> 0
        BEGIN
            RETURN (1)
        END


    -- Drop the distributor db if it exists
    IF EXISTS (SELECT * FROM master..sysdatabases WHERE name = @database collate database_default)
    BEGIN

        CREATE TABLE #db_existed
        (
        db_existed bit  NOT NULL
        )

        /* Get version stamp */
        SELECT @command = 'INSERT INTO #db_existed SELECT db_existed FROM ' +
            QUOTENAME(@database) + '..MSrepl_version'
    
        EXEC(@command)
        IF @@ERROR <> 0
        BEGIN
            RETURN(1)       
        END

        -- Drop the distribution db only if it is created in sp_adddistributiondb.
        IF NOT EXISTS (SELECT * FROM #db_existed where db_existed = 0x1)
        BEGIN
    
			-- we're dropping the database, so don't bother to clean up
			-- individual records.  Just make sure we blow away the synchronization
			-- files & directories hosted by the file system.

			SELECT @command = QUOTENAME(@database) + '.dbo.sp_MSdrop_snapshot_dirs'
			SELECT @command = 'EXEC ' + @command
			EXEC (@command)
			IF (@@ERROR <> 0)
			BEGIN
				RETURN (1)
			END

            /* Save the device info before dropping the database */
            CREATE TABLE #distdbdevices (name sysname  collate database_default not null)

            /* Drop distributor devices */
            /* Query is copied from sp_helpdb */
            SELECT @command = 
                'INSERT INTO #distdbdevices select DISTINCT name from ' + QUOTENAME(@database) + '.dbo.sysfiles'
            EXEC (@command)
            IF @@ERROR <>0
            BEGIN
                RETURN(1)      
            END

            /*
            ** Drop the distribution database
            */
			SELECT @command = 'drop database ' + QUOTENAME(@database)
			EXEC (@command)
            IF @@ERROR <> 0
                BEGIN
                    /* Mark the database as distribution database again 
                    ** Otherwise, this sp will fail when it is reentered.
                    ** It is often the case that if there's an open session
                    ** on the database, it can not be dropped.
                    */
                    RETURN(1)
                END

            /* Drop distributor devices */
            /* Query is copied from sp_helpdb */
            /* SQL SERVER 7.0 may drop some auto generated device files, drop drop them here
               again
            */
            DECLARE hCdropdistributiondb CURSOR LOCAL FAST_FORWARD FOR
                SELECT DISTINCT dd.name FROM #distdbdevices dd, master.dbo.sysdevices ss
                    WHERE ss.name = dd.name collate database_default
            FOR READ ONLY
    
            OPEN hCdropdistributiondb
            FETCH hCdropdistributiondb INTO @device_name

            WHILE (@@fetch_status <> -1)
            BEGIN
                /* 
                ** Device may be used by other databases
                ** Ignore all errors 
                */
                EXEC dbo.sp_dropdevice @device_name, DELFILE
                FETCH hCdropdistributiondb INTO @device_name
            END

            CLOSE hCdropdistributiondb
            DEALLOCATE hCdropdistributiondb

        END
		-- else, database did exist before it was made the distributor, 
		-- do full cleanup
		ELSE
		BEGIN

			-- run 'fast clean' routine first. this removes repldata files
			-- and truncates MSrepl_transactions/commands

			SELECT @command = QUOTENAME(@database) + '.dbo.sp_MSfast_delete_trans'
			SELECT @command = 'EXEC ' + @command
			EXEC (@command)
			IF (@@ERROR <> 0)
			BEGIN
				RETURN (1)
			END

			-- Do distribution cleanup the final time
			-- this handles those fiddly agent tables & such
			-- ( and would delete commands/xacts if we hadn't already purged 'em )

			SELECT @command = QUOTENAME(@database) + 
				'.dbo.sp_MSdistribution_cleanup @min_distretention = 0, @max_distretention = 0'
			SELECT @command = 'EXEC ' + @command
			EXEC (@command)
			IF (@@ERROR <> 0)
			BEGIN
				RETURN (1)
			END
		END
    END
    

    /*
    ** Delete the DistributionDB entry
    */

    DELETE msdb.dbo.MSdistributiondbs where name = @database collate database_default
    IF @@error <> 0
    BEGIN
        RETURN(1)
    END
    

    RETURN (0)
                
GO
 
dump tran master with no_log
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

    SELECT @data_path_quoted_for_copy = '"' + fn_escapecmdshellsymbolsremovequotes(@data_folder) collate database_default + '\' + fn_escapecmdshellsymbolsremovequotes(@data_file) collate database_default + '"'
    SELECT @log_path_quoted_for_copy = '"' + fn_escapecmdshellsymbolsremovequotes(@log_folder) collate database_default + '\' + fn_escapecmdshellsymbolsremovequotes(@log_file) collate database_default + '"'

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

        select @filecopy_cmd = 'copy "' + fn_escapecmdshellsymbolsremovequotes(@canneddbdata_file) collate database_default + '" ' + @data_path_quoted_for_copy
        EXEC @retcode = master..xp_cmdshell @filecopy_cmd, NO_OUTPUT
        IF @retcode <> 0 OR @@ERROR <> 0
        BEGIN
            RAISERROR (14113, 16, -1, @filecopy_cmd, 'instdist.out')
            return (1)
        END

        select @filecopy_cmd = 'copy "' + fn_escapecmdshellsymbolsremovequotes(@canneddblog_file) collate database_default + '" ' + @log_path_quoted_for_copy
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
        -- sp_changedbowner will fail if the new owner is an user in the db already.
        -- Addendum: we don't perform the check for existing rows in
        -- sysusers anymore as the server has implemented special logic 
        -- that handles such scenarios transparently.
        -- ' if not exists (select * from sysusers where sid = 0x01) ' +
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
            SELECT @osql_cmd = '" "' + fn_escapecmdshellsymbolsremovequotes(@osql_path) collate database_default + '\binn\osql" -E '  
			if serverproperty('instancename') is not null
				SELECT @osql_cmd = @osql_cmd + ' -S"' + fn_escapecmdshellsymbols(@@SERVERNAME) collate database_default + '" '
		END
        ELSE
		BEGIN
        -- cannot specify -S w/ -E for local execution, SID does not map 
		if (@osql_for_nt = 1)
            SELECT @osql_cmd = '" "' + fn_escapecmdshellsymbolsremovequotes(@osql_path) collate database_default + '\binn\osql" -U"' + fn_escapecmdshellsymbols(@login) collate database_default + '" -P"' + 
                fn_escapecmdshellsymbols(isnull(@password,'')) collate database_default + '" -S"' + fn_escapecmdshellsymbols(@@SERVERNAME) collate database_default + '" '
		else
			SELECT @osql_cmd = '"'   + fn_escapecmdshellsymbolsremovequotes(@osql_path) collate database_default + '\binn\osql" -U"' + fn_escapecmdshellsymbols(@login) collate database_default + '" -P"' + 
                fn_escapecmdshellsymbols(isnull(@password,'')) collate database_default + '" -S"' + fn_escapecmdshellsymbols(@@SERVERNAME) collate database_default + '" '
		END
    
        select @osql_cmd = @osql_cmd + '-l60 -t60 '

        -- We must use -b option to make osql return error code !!
        SELECT @osql_cmd = @osql_cmd + 
            ' -d"' + fn_escapecmdshellsymbols(@database) collate database_default + '" -b ' +
            ' -i' + '"' + fn_escapecmdshellsymbolsremovequotes(@install_path) collate database_default + '\install\instdist.sql"' + 
            ' -o' + '"' + fn_escapecmdshellsymbolsremovequotes(@install_path) collate database_default + '\install\instdist.out"'

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
 
dump tran master with no_log
GO

raiserror('Creating procedure sp_dropdistpublisher', 0,1)
go

CREATE PROCEDURE sp_dropdistpublisher (
    @publisher sysname,         /* publisher server name */
    @no_checks bit = 0
        ) AS

    SET NOCOUNT ON

    DECLARE @distributor sysname
    DECLARE @distaccount nvarchar(127)
    DECLARE @proc nvarchar (255)
    DECLARE @retcode int
    DECLARE @privilege sysname
    DECLARE @reg_key nvarchar(255)
    DECLARE @return_status int
    DECLARE @foundSubscriber int 
    DECLARE @distribdb sysname
    DECLARE @command nvarchar(255)
    DECLARE @active_value int
    DECLARE @publish_bit int
    DECLARE @mergepub_bit int


    SELECT @return_status = 0
    SELECT @foundSubscriber = 0

    SELECT @publish_bit = 1
    SELECT @mergepub_bit = 4

    /*
    ** Parameter Check:  @publisher.
    ** Check to make sure that the publisher exists, that the name isn't
    ** NULL, and that the name conforms to the rules for identifiers.
    */

    IF @publisher IS NULL
        BEGIN
            RAISERROR (14043, 16, -1, '@publisher')
            RETURN (1)
        END

    EXECUTE @retcode = dbo.sp_validname @publisher

    IF @retcode <> 0
        RETURN (1)

    /*
    ** Get distribution server information for remote RPC
    ** agent verification.
    */
    EXEC @retcode = dbo.sp_helpdistributor @publisher = @publisher,
        @distributor = @distributor OUTPUT,
        @distribdb = @distribdb OUTPUT
    IF @@error <> 0 OR @retcode <> 0
        BEGIN
        RAISERROR (14071, 16, -1)
           RETURN (1)
    END

    /*
    ** Only a local distributor can be modified.
    */
    IF UPPER(@distributor) <> UPPER(@@SERVERNAME)
        BEGIN
        RAISERROR (14114, 16, -1, @@SERVERNAME)
        RETURN (1)
        END
 
    IF NOT EXISTS (SELECT *
    FROM msdb..MSdistpublishers
            WHERE UPPER(name) = UPPER(@publisher) collate database_default)
    BEGIN
        RAISERROR (14080, 11, -1)
        RETURN (1)
    END


    IF UPPER(@publisher) = UPPER(@@SERVERNAME)
    BEGIN
        /* 
        ** If @publisher is local, 
        ** 1. check to make sure there is no subscriber 
        ** for the publisher in the distribution database
        ** 2. check to make sure there are not database enabled for replication
        */
        -- Check to see if there are subscribers defined.
        if exists (SELECT *
                     FROM master..sysservers
                    WHERE srvstatus & 4 <> 0)
        begin
            raiserror(21047, 16, -1)
            return(1)
        end
        
        IF EXISTS (SELECT * FROM master..sysdatabases WHERE 
            (category & @publish_bit) <> 0 OR
            (category & @mergepub_bit) <> 0)
        BEGIN 
            RAISERROR (21033, 16, -1, @@SERVERNAME)
            RETURN (1)
        END
    END
    ELSE
    BEGIN
        if @no_checks = 0
        begin
            /* 
            ** If the publisher is remote, check the status of the distpublisher 
            ** The status will be inactive if the remote publisher dropped the
            ** distributor.
            */

            IF EXISTS (SELECT * FROM msdb.dbo.MSdistpublishers WHERE
                UPPER(name) = UPPER(@publisher) collate database_default and active = 1)
            BEGIN
                RAISERROR (14098, 16, -1, @publisher, @@SERVERNAME)
                RETURN (1)
            END
        end
        else
        begin
            SELECT @command = @distribdb + '.dbo.sp_MSdistpublisher_cleanup'
            exec @retcode = @command @publisher
            if @retcode <> 0 or @@error <> 0
                return 1
        end
    END

    DELETE msdb..MSdistpublishers where UPPER(name) = UPPER(@publisher) collate database_default
    IF @@ERROR <> 0  RETURN (1)


    declare @fExists int
    exec @fExists = dbo.sp_MSIfExistsRemoteLogin @publisher, 'distributor_admin', 'sa'
    if (@fExists = 1)
    BEGIN
       EXECUTE @retcode = dbo.sp_dropremotelogin @publisher, 'distributor_admin', sa
       IF @@ERROR <> 0 OR @retcode <> 0 RETURN (1)
    END

    exec @fExists = dbo.sp_MSIfExistsRemoteLogin @publisher, 'distributor_admin', 
        'distributor_admin'
    if (@fExists = 1)
    BEGIN
       EXECUTE @retcode = dbo.sp_dropremotelogin @publisher, 'distributor_admin',
            'distributor_admin'
       IF @@ERROR <> 0 OR @retcode <> 0 RETURN (1)
    END

/* SECURITY ********************************
    IF EXISTS (SELECT * FROM master..sysremotelogins
       WHERE remoteserverid = (SELECT srvid FROM master..sysservers
       WHERE UPPER(srvname) = UPPER(@publisher) collate database_default)
       AND remoteusername = 'sa'
       AND suid = 1)     --'sa' 
*********************************/


/* SECURITY ********************************
    IF EXISTS (SELECT * FROM master..sysremotelogins
       WHERE remoteserverid = (SELECT srvid FROM master..sysservers
       WHERE UPPER(srvname) = UPPER(@publisher) collate databsae_default)
       AND remoteusername = 'probe'
       AND suid = 10)     -- 'probe' 
    exec @fExists = dbo.sp_MSIfExistsRemoteLogin @publisher, 'probe', 'probe'
    if (@fExists = 1)
    BEGIN
       EXECUTE @retcode = dbo.sp_remoteoption @publisher, probe, probe, trusted, false
       IF @@ERROR <> 0 OR @retcode <> 0 RETURN (1)
    END
*********************************/

    return(@return_status)
GO
 
raiserror('Creating procedure sp_adddistpublisher', 0,1)
go

CREATE PROCEDURE sp_adddistpublisher (
    @publisher sysname,      /* publisher server name */
    @distribution_db sysname,
    @security_mode int = NULL,
    @login sysname = 'sa',
    @password sysname = NULL,
    @working_directory nvarchar(255),
    @trusted nvarchar(5) = 'false',
    @encrypted_password bit = 0,
    @thirdparty_flag bit = 0
        ) AS

    SET NOCOUNT ON

    /*
    ** Declarations.
    */

    DECLARE @retcode int
    DECLARE @reg_key nvarchar(255)
    DECLARE @distbit int
    DECLARE @active_value int
    DECLARE @server_added bit
    DECLARE @proc nvarchar(255)
    declare @fExists int
    declare @command nvarchar(255)
    declare @trusted_id bit
    declare @platform_nt binary
	declare @qv_replication varchar(10)
	declare @qv_replication_unlimited integer
	declare @qv_value_replication integer
    declare @enc_password nvarchar(524)

    select @platform_nt = 0x1
	select @qv_replication = '2745196162', @qv_replication_unlimited = 0

    SELECT @distbit = 16
    SELECT @server_added = 0

    /* 
    ** Check if replication components are installed on this server
    */
    exec @retcode = dbo.sp_MS_replication_installed
    if (@retcode <> 1)
    begin
        return (1)
    end

    IF @working_directory IS NULL or ltrim(rtrim(@working_directory)) = ''
    BEGIN
        RAISERROR (14043, 16, -1, '@working_directory')
        return (1)
    END


    /*
    ** Parameter Check:  @publisher.
    ** Check to make sure that the publisher is not NULL and that it
    ** conforms to the rules for identifiers.
    */

    IF @publisher IS NULL
        BEGIN
            RAISERROR (14043, 16, -1, '@publisher')
            return (1)
        END

    EXECUTE @retcode = dbo.sp_validname @publisher

    IF @@ERROR <> 0 OR @retcode <> 0
        return (1)

	IF @password = N''
		select @password = NULL

    /* On REPLICATION_LIMITED server, only local publisher is supported.
     * Note: The login and password registered for local publisher will be used for 
     * local agents to login to distributor, thus local publisher has to be installed first.
     * We choose not to support remote dist publshers on REPLICATION_LIMITED server altogether.
     * On NT, local agents will always use integrated security to log into 
     * distributor
	 * Today, REPLICATION_LIMITED means desktop but we check specific sku entry just in case
	*/
	exec @qv_value_replication = master.dbo.sp_MSinstance_qv @qv_replication	

	if ( @qv_value_replication != @qv_replication_unlimited ) and ( UPPER(@publisher) <> UPPER(@@servername) )
    begin
        -- remote dist publisher is not supported on this server version
        raiserror(21041,16,-1)
        return (1)
    end


    -- Set default security
    IF @security_mode IS NULL
    BEGIN
        IF (UPPER(@publisher) = UPPER(@@SERVERNAME) and ( platform() & @platform_nt = @platform_nt ) )
            SELECT @security_mode = 1
        ELSE
            SELECT @security_mode = 0
    END

    /* 
    ** Check for invalid security mode
    */
    IF @security_mode < 0 OR @security_mode > 1
        BEGIN
            RAISERROR(14109, 16, -1)
            return (1)
        END

    IF (UPPER(@publisher) = UPPER(@@SERVERNAME) and ( @platform_nt != platform() & @platform_nt ) and @security_mode = 1)
    BEGIN
        RAISERROR(21038, 16, -1)
        RETURN (1)
    END

    -- Encrypt the password
    select @enc_password = @password
    IF @encrypted_password = 0
    BEGIN
        EXEC @retcode = master.dbo.xp_repl_encrypt @enc_password OUTPUT
        IF @@error <> 0 OR @retcode <> 0
            return 1
    END

    -- Validate the working directory 
    -- Remove heading and trailing spaces
    select @working_directory = RTRIM(LTRIM(@working_directory))
    
    -- if the last char is '\', remove it.
    if substring(@working_directory, len(@working_directory),1) = '\'
        select @working_directory = substring(@working_directory, 1,
            len(@working_directory)-1)

    -- Don't do validation if it is a UNC path due to security problem.
    -- If the server is started as a service using local system account, we
    -- don't have access to the UNC path.
    if substring(@working_directory, 1,2) <> '\\'
    begin
        select @command = 'dir "' + fn_escapecmdshellsymbolsremovequotes(@working_directory) collate database_default + '"'
        exec @retcode = master..xp_cmdshell @command, 'no_output'
        if @@error <> 0
            return (1)
        if @retcode <> 0 
        begin
            raiserror (21037, 16, -1, @working_directory)
            return (1)
        end
    end

    /*
    ** Parameter Check:  @trusted
    */

	-- Security - trusted is an insecure default.
	-- User must override the secure default by explicitly
	-- requesting @trusted = 'true'

    IF LOWER(@trusted collate SQL_Latin1_General_CP1_CS_AS) NOT IN ('true', 'false')
        BEGIN
            RAISERROR (14148, 16, -1, '@trusted')
            RETURN (1)
        END

    IF LOWER(@trusted collate SQL_Latin1_General_CP1_CS_AS) = 'true' SELECT @trusted_id = 1
    ELSE SELECT @trusted_id = 0

    /*
    ** Check to make sure this is a distributor
    */
    IF NOT EXISTS (SELECT * FROM master..sysservers
              WHERE UPPER(datasource) = UPPER(@@SERVERNAME) collate database_default
                 AND srvstatus & 8 <> 0)
    BEGIN
        RAISERROR (14114, 16, -1, @@SERVERNAME)
        return (1)
    END

    /*
    ** Check if database is configured as a distributor database
    */
    IF NOT EXISTS (SELECT * FROM msdb..MSdistributiondbs WHERE name = @distribution_db collate database_default)
    BEGIN
        RAISERROR (14117, 16, -1, @distribution_db)
        return (1)
    END

    /* Check if publisher is already defined. */
    IF EXISTS (SELECT *
         FROM msdb..MSdistpublishers
        WHERE UPPER(name) = UPPER(@publisher) collate database_default)

    BEGIN
        RAISERROR (14074, 16, -1, @publisher)
        RETURN (1)
    END



    IF NOT EXISTS (SELECT *
             FROM master..sysservers
            WHERE UPPER(srvname) = UPPER(@publisher) collate database_default)

    /* Add the server if it does not exist. */
    BEGIN
        EXECUTE @retcode = dbo.sp_addserver @publisher
        IF @@error <> 0 OR @retcode <> 0
        BEGIN
            RAISERROR (14075, 16, -1)
            GOTO UNDO
        END
        SELECT @server_added = 1
    END
    ELSE
    BEGIN
        SELECT @publisher = fn_getpersistedservernamecasevariation(@publisher) collate database_default
    END
     
    /*
    ** Set the Active  value.
    ** If the @publisher is local, set it to true.
    ** Otherwise, set it to false
    */
    IF UPPER(@publisher) = UPPER(@@SERVERNAME)
        SELECT @active_value = 1
    ELSE
        SELECT @active_value = 0


    DELETE msdb.dbo.MSdistpublishers where UPPER(name) = UPPER(@publisher) collate database_default
    IF @@ERROR <> 0
    BEGIN
        GOTO UNDO       
    END

    INSERT INTO msdb.dbo.MSdistpublishers VALUES (
        @publisher, @distribution_db, @working_directory,
        @security_mode, @login, @enc_password, @active_value, @trusted_id, @thirdparty_flag)
    IF @@ERROR <> 0
    BEGIN
        GOTO UNDO       
    END

    -- Add distributor_admin to distribution_admin non trusted mapping
    exec @fExists = dbo.sp_MSIfExistsRemoteLogin @publisher, null, 
        'distributor_admin'
    if( @fExists = 0 )
    BEGIN

        EXECUTE @retcode = dbo.sp_addremotelogin @publisher, 'distributor_admin', 
            'distributor_admin'
        IF @@error <> 0 OR @retcode <> 0
        BEGIN
            RAISERROR (14075, 16, -1)
            GOTO UNDO
        END
    END

    -- For 6x publisher, we still need the trusted sa to sa.
    -- For 6x publisher upgrading to 7.0, distributor_admin to distributor_admin need to be trusted.
    -- add remotelogin of SA if it doesn't already exist
    -- If there's a mapping for remote login sa already, we cannot map it to distributor_admin
    -- this is the case of server upgraded from 6.5.
    exec @fExists = dbo.sp_MSIfExistsRemoteLogin @publisher, null, 'sa'
    if( @fExists = 0 )
    BEGIN
        EXECUTE @retcode = dbo.sp_addremotelogin @publisher, 'distributor_admin', 'sa'
        IF @@error <> 0 OR @retcode <> 0
        BEGIN
            RAISERROR (14075, 16, -1)
            GOTO UNDO
        END
    END
    if @trusted_id = 1
    begin
        exec @fExists = dbo.sp_MSIfExistsRemoteLogin @publisher, 'distributor_admin', 'sa'
        if( @fExists = 1 )
        BEGIN
            EXECUTE @retcode = dbo.sp_remoteoption @publisher, 'distributor_admin', 'sa', trusted, true
            IF @@error <> 0 OR @retcode <> 0
            BEGIN
                RAISERROR (14075, 16, -1)
                GOTO UNDO
            END
        END

        EXECUTE @retcode = dbo.sp_remoteoption @publisher, 'distributor_admin', 'distributor_admin', trusted, true
        IF @@error <> 0 OR @retcode <> 0
        BEGIN
            RAISERROR (14075, 16, -1)
            GOTO UNDO
        END
    END


    /* Add remotelogin enabling the 'probe' of the publisher to
    ** RPC for distribution counter information.
    */
/* SECURITY ********************************
    IF NOT EXISTS (SELECT *
              FROM master..sysremotelogins srl,
               master..sysservers ss
             WHERE UPPER(ss.srvname) = UPPER(@publisher) collate database_default
           AND srl.remoteserverid = ss.srvid
           AND srl.remoteusername = 'probe'
       AND srl.suid = 10)    -- 'probe' 
    exec @fExists = dbo.sp_MSIfExistsRemoteLogin @publisher, 'probe', 'probe'
    if (@fExists = 0)
    BEGIN
       EXECUTE @retcode = dbo.sp_addremotelogin @publisher, 'probe', 'probe'
       IF @@error <> 0 OR @retcode <> 0
       BEGIN
        RAISERROR (14075, 16, -1)
        GOTO UNDO
       END
    END
*********************************/
    
    RETURN(0)

UNDO:
    -- If the server is marked, drop it
    IF EXISTS (SELECT *
         FROM msdb..MSdistpublishers
        WHERE UPPER(name) = UPPER(@publisher) collate database_default)
        EXEC dbo.sp_dropdistpublisher @publisher

    IF @server_added = 1
        EXEC dbo.sp_dropserver @publisher

    RETURN(1)
GO
 

raiserror('Creating procedure sp_changedistpublisher', 0,1)
go

CREATE PROCEDURE sp_changedistpublisher (
    @publisher sysname,
    @property sysname     = NULL,     /* The property to change */
    @value nvarchar(255)     = NULL      /* The new property value */
    ) AS

    SET NOCOUNT ON

    /*
    ** Declarations.
    */
    DECLARE @retcode int
    DECLARE @new_database sysname
    DECLARE @new_security_mode int
    DECLARE @new_login sysname
    DECLARE @new_password nvarchar(524)
    DECLARE @distbit int
    DECLARE @new_active int
    DECLARE @new_trusted bit
    DECLARE @command nvarchar(255)
    declare @distribdb sysname
    DECLARE @platform_nt binary

    SELECT @platform_nt = 0x1
    SELECT @distbit = 16
    
    /*
    ** Parameter Check:  @property.
    ** If the @property parameter is NULL, print the options.
    */

    IF @property IS NULL
        BEGIN
            CREATE TABLE #tab1 (properties sysname collate database_default not null)
            INSERT INTO #tab1 VALUES ('distribution_db')
            INSERT INTO #tab1 VALUES ('working_directory')
            INSERT INTO #tab1 VALUES ('security_mode')
            INSERT INTO #tab1 VALUES ('login')
            INSERT INTO #tab1 VALUES ('password')
            INSERT INTO #tab1 VALUES ('active')
            INSERT INTO #tab1 VALUES ('trusted')
            SELECT * FROM #tab1
            RETURN (0)
        END

    /*
    ** Parameter Check:  @property.
    ** Check to make sure that @property is a valid property in
    ** msdb.dbo.MSdistpublishers.
    */
    IF @property IS NULL OR LOWER(@property collate SQL_Latin1_General_CP1_CS_AS) NOT IN 
        ('distribution_db',
         'working_directory',
         'security_mode',
         'login',
         'password',
         'active',
         'trusted')
        BEGIN
            RAISERROR (14115, 16, -1, 
            '''distribution_db'', ''working_directory'', ''security_mode'', ''login'', ''password'', ''active'', or ''trusted''')
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

    -- Get the distribution db name.
    select @distribdb = distribution_db from msdb..MSdistpublishers where
        UPPER(name) = UPPER(@publisher) collate database_default

    /*
    ** Change the property.
    */
    IF LOWER(@property collate SQL_Latin1_General_CP1_CS_AS) = 'distribution_db'
        BEGIN
            IF @value IS NULL
                BEGIN
                    RAISERROR (14043, 16, -1, '@value') 
                    RETURN (1)
                END

            IF @value <> @distribdb and 
                EXISTS (SELECT * FROM msdb.dbo.MSdistpublishers WHERE
                UPPER(name) = UPPER(@publisher) collate database_default and active = 1)
            BEGIN
                RAISERROR (21046, 16, -1)
                RETURN (1)
            END

            /*
            ** Check if database is configured as a distributor database
            */
            IF NOT EXISTS (SELECT * FROM master..sysdatabases
              WHERE name = @value collate database_default
                 AND category & @distbit <> 0)
                BEGIN
                    RAISERROR (14117, 16, -1, @new_database)
                    RETURN(1)
                END

            UPDATE msdb..MSdistpublishers SET distribution_db = @value
                WHERE UPPER(name) = UPPER(@publisher) collate database_default
            IF @@error <> 0 
                BEGIN
                    RETURN (1)
                END
        END
   
    IF LOWER(@property collate SQL_Latin1_General_CP1_CS_AS) = 'working_directory'
        BEGIN
            IF @value IS NULL
                BEGIN
                    RAISERROR (14043, 16, -1, '@value') 
                    RETURN (1)
                END

            
            -- Validate the working directory 
            -- Remove heading and trailing spaces
            select @value = RTRIM(LTRIM(@value))

            -- if the last char is '\', remove it.

            if substring(@value, len(@value),1) = '\'
                select @value = substring(@value, 1,
                    len(@value)-1)

            -- Don't do validation if it is a UNC path due to security problem.
            -- If the server is started as a service using local system account, we
            -- don't have access to the UNC path.
            if substring(@value, 1,2) <> '\\'
            begin
                select @command = 'dir "' + fn_escapecmdshellsymbolsremovequotes(@value) collate database_default + N'"'
                exec @retcode = master..xp_cmdshell @command, 'no_output'
                if @@error <> 0
                    return 1
                if @retcode <> 0 
                begin
                    raiserror (21037, 16, -1, @value)
                    return 1
                end
            end

            UPDATE msdb..MSdistpublishers SET working_directory = @value
                WHERE UPPER(name) = UPPER(@publisher) collate database_default
            IF @@error <> 0 
                BEGIN
                    RETURN (1)
                END
        END

    IF LOWER(@property collate SQL_Latin1_General_CP1_CS_AS) = 'security_mode'
        BEGIN
            IF @value IS NULL
                BEGIN
                    RAISERROR (14043, 16, -1, '@value') 
                    RETURN (1)
                END

            /*
            ** Set the SecurityMode registry key value
            */
            SELECT @new_security_mode = CONVERT(int, @value)

            /* 
            ** Check for invalid values 
            */
            IF @new_security_mode < 0 OR @new_security_mode > 1
                BEGIN
                    RAISERROR(14109, 16, -1)
                    RETURN (1)
                END

            IF (UPPER(@publisher) = UPPER(@@SERVERNAME) and ( @platform_nt != platform() & @platform_nt ) and @new_security_mode = 1)
            BEGIN
                RAISERROR(21038, 16, -1)
                RETURN (1)
            END

            UPDATE msdb..MSdistpublishers SET security_mode = @new_security_mode
                WHERE UPPER(name) = UPPER(@publisher) collate database_default
            IF @@error <> 0 
                BEGIN
                    RETURN (1)
                END
        END

    IF LOWER(@property collate SQL_Latin1_General_CP1_CS_AS) = 'login'
        BEGIN
            IF @value IS NULL
                BEGIN
                    RAISERROR (14043, 16, -1, '@value') 
                    RETURN (1)
                END

            /*
            ** Set the Login registry key value
            */
            SELECT @new_login = CONVERT(sysname, @value)

            UPDATE msdb..MSdistpublishers SET login = @new_login
                WHERE UPPER(name) = UPPER(@publisher) collate database_default
            IF @@error <> 0 
                BEGIN
                    RETURN (1)
                END
        END

    IF LOWER(@property collate SQL_Latin1_General_CP1_CS_AS) = 'password'
        BEGIN
            /*
            ** Set the Password registry key value
            */
            SELECT @new_password = CONVERT(nvarchar(524), @value)

            -- Encrypt the password
            EXEC @retcode = master.dbo.xp_repl_encrypt @new_password OUTPUT
            IF @@error <> 0 OR @retcode <> 0
                RETURN (1)

            UPDATE msdb..MSdistpublishers SET password = @new_password
                WHERE UPPER(name) = UPPER(@publisher) collate database_default
            IF @@error <> 0 
                BEGIN
                    RETURN (1)
                END
         END

    IF LOWER(@property collate SQL_Latin1_General_CP1_CS_AS) = 'active'
        BEGIN
            /*
            ** Check for a valid  value.
            */

            IF LOWER(@value collate SQL_Latin1_General_CP1_CS_AS) NOT IN ('true', 'false')
            BEGIN
                RAISERROR (14137, 16, -1)
                RETURN (1)
            END

            IF LOWER(@value collate SQL_Latin1_General_CP1_CS_AS) = 'true'
            begin
                -- Clean up the database in case of the remote publisher is reinstalling publishing.
                SELECT @command = @distribdb + '.dbo.sp_MSdistpublisher_cleanup'
                exec @retcode = @command @publisher
                if @retcode <> 0 or @@error <> 0
                    return 1
                SELECT @new_active = 1
            end
            ELSE
            BEGIN
                SELECT @new_active = 0
            END

            /*
            ** Set the Active registry key value
            */
            UPDATE msdb..MSdistpublishers SET active = @new_active
                WHERE UPPER(name) = UPPER(@publisher) collate database_default
            IF @@error <> 0
                BEGIN
                    RETURN (1)
                END

        END

    IF LOWER(@property collate SQL_Latin1_General_CP1_CS_AS) = 'trusted'
        BEGIN
            /*
            ** Check for a valid  value.
            */

            IF LOWER(@value collate SQL_Latin1_General_CP1_CS_AS) NOT IN ('true', 'false')
            BEGIN
                RAISERROR (14137, 16, -1)
                RETURN (1)
            END

            declare @fExists int

            IF LOWER(@value collate SQL_Latin1_General_CP1_CS_AS) = 'true'
            begin
                SELECT @new_trusted = 1
                exec @fExists = dbo.sp_MSIfExistsRemoteLogin @publisher, 'distributor_admin', 'sa'
                if( @fExists = 1 )
                BEGIN
                    EXECUTE @retcode = dbo.sp_remoteoption @publisher, 'distributor_admin', 'sa', trusted, true
                    IF @@error <> 0 OR @retcode <> 0
                    BEGIN
                        RAISERROR (14075, 16, -1)
                        RETURN (1)
                    END
                END


                EXECUTE @retcode = dbo.sp_remoteoption @publisher, 'distributor_admin', 
                    'distributor_admin', trusted, true
                IF @@error <> 0 OR @retcode <> 0
                BEGIN
                    RAISERROR (14075, 16, -1)
                    RETURN (1)
                END
            end
            ELSE
            BEGIN
                SELECT @new_trusted = 0
     
                exec @fExists = dbo.sp_MSIfExistsRemoteLogin @publisher, 'distributor_admin', 'sa'
                if( @fExists = 1 )
                BEGIN
                    EXECUTE @retcode = dbo.sp_remoteoption @publisher, 'distributor_admin', 'sa', trusted, false
                    IF @@error <> 0 OR @retcode <> 0
                    BEGIN
                        RAISERROR (14075, 16, -1)
                        RETURN (1)
                    END
                END


                EXECUTE @retcode = dbo.sp_remoteoption @publisher, 'distributor_admin',
                    'distributor_admin', trusted, 'false'
                IF @@error <> 0 OR @retcode <> 0
                BEGIN
                    RAISERROR (14075, 16, -1)
                    RETURN (1)
                END
            END

            /*
            ** Set the trusted property
            */
            UPDATE msdb..MSdistpublishers SET trusted = @new_trusted
                WHERE UPPER(name) = UPPER(@publisher) collate database_default
            IF @@error <> 0
                BEGIN
                    RETURN (1)
                END
        END

  
    /*
    ** Return succeed.
    */
    RAISERROR (21035, 10, -1, @property)

DONE:    
    RETURN (0)
go
 
raiserror('Creating procedure sp_helpdistpublisher', 0,1)
go

CREATE PROCEDURE sp_helpdistpublisher (
    @publisher sysname = '%'         /* publisher server name */
	, @check_user bit = 0
) 
AS
BEGIN
    SET NOCOUNT ON
    declare @is_sysadmin int

	select @is_sysadmin = is_srvrolemember('sysadmin')
	IF @publisher IS null
	begin
		raiserror (14043, 16, -1, '@publisher')
		return (1)
	end

    /*
    ** Check to make sure this is a distributor
    */
    IF NOT EXISTS (select * from master..sysservers
              where UPPER(datasource) = UPPER(@@SERVERNAME) collate database_default
                 AND srvstatus & 8 <> 0)
    begin
		if @publisher <> '%' 
		begin
				raiserror (14114, 16, -1, @@SERVERNAME)
				return(1)
		end
		else
			return(0)
    end

    IF @publisher <> '%' AND NOT EXISTS (select * from msdb..MSdistpublishers
            where UPPER(name) = UPPER(@publisher) collate database_default)
    begin
        raiserror (14080, 11, -1)
        return (1)
    end

	-- If sysadmin, no need for filtering
	if @is_sysadmin = 1
		select @check_user = 0

	create table #distdbs (name sysname collate database_default)

	if @check_user = 1
	begin
	    declare @distbit int, @db_name sysname, @cmd nvarchar(1000)
	    select @distbit = 16
		declare hCdatabase CURSOR LOCAL FAST_FORWARD FOR
			select name from master.dbo.sysdatabases 
				where
				category & @distbit <> 0 and
				has_dbaccess(name) = 1
		for read only

		open hCdatabase
		fetch next from hCdatabase into @db_name
		while (@@fetch_status <> -1)
		begin
			
			-- Check to see if the user has permision to monitor the distribution 
			-- database.
			declare @has_pm bit
			select @cmd = quotename(@db_name) + '.dbo.sp_executesql'
			exec @cmd
				N'if is_member(N''db_owner'') = 1 or is_member(N''replmonitor'') = 1 set @has_pm = 1', 
				N'@has_pm bit output',
				@has_pm output
			if @has_pm = 1
				insert #distdbs values (@db_name)
			fetch next from hCdatabase into @db_name
		end
		close hCdatabase
		deallocate hCdatabase
	end

	SELECT p.name, distribution_db, security_mode, 
		-- Not to return login unless sysadmin is called.
		'login' = case when (@is_sysadmin = 1) then login else cast(NULL as sysname) end,
		-- Not to return password unless sysadmin is called.
		'password' = case  when (@is_sysadmin = 1) then password else cast(NULL as sysname) end,
		active, working_directory, trusted, thirdparty_flag
	FROM msdb.dbo.MSdistpublishers p
	where ((@publisher = N'%') or (UPPER(p.name) collate database_default = UPPER(@publisher) collate database_default)) and
			(@check_user = 0 or exists 
				(select * from #distdbs d where p.distribution_db = d.name collate database_default))
	IF @@ERROR <> 0
    begin
        return(1)
    end
END
GO
 
dump tran master with no_log
go

raiserror('Creating procedure sp_add_agent_profile', 0,1)
go

/*
** The system profile of the same type of agent will be used as a template for 
** the parameters in this new user profile.
*/
CREATE PROCEDURE sp_add_agent_profile (
    @profile_id             int = NULL OUTPUT,
    @profile_name           sysname,
    @agent_type             int,            -- 1-Snapshot, 2-Logreader, 
											-- 3-Distribution, 4-Merge,
											-- 9-Qreader
    @profile_type           int = 1,        -- 0-System, 1-Custom 
    @description            nvarchar(3000) = NULL,
    @default                bit = 0         -- 0-Not Default, 1-Default
)
AS
    SET NOCOUNT ON

    declare     @sys_profile    int
    declare     @default_id     int
    declare     @sysdefault_id  int
    declare     @retcode        int

    SELECT @profile_name = RTRIM(@profile_name)

    IF @profile_name IS NULL
    BEGIN
        RAISERROR (14043, 16, -1, '@profile_name')
        RETURN (1)
    END

	exec @retcode = dbo.sp_MSreplcheck_name @profile_name
    if @@ERROR <> 0 or @retcode <> 0
        return(1)

    /* The profile name is unique across a particular agent type */
    IF EXISTS ( SELECT * FROM msdb..MSagent_profiles 
            WHERE profile_name = @profile_name collate database_default
            AND agent_type = @agent_type )
    BEGIN
        RAISERROR(20057, 16, -1, @profile_name)
        RETURN (1)
    END

    IF @agent_type NOT IN (1, 2, 3, 4, 9)
    BEGIN
        RAISERROR(20058, 16, -1)
        return (1)
    END

    IF @profile_type NOT IN (0, 1)
    BEGIN
        RAISERROR(20059, 16, -1)
        return (1)
    END

    BEGIN TRAN

    /*
    ** First find out the default profile of the same agent type
    */
    select @default_id = profile_id from msdb..MSagent_profiles WHERE agent_type = @agent_type AND def_profile = 1
    
    INSERT INTO msdb..MSagent_profiles
            VALUES (@profile_name, @agent_type, @profile_type, @description, 0)
    IF @@ERROR <> 0
        GOTO UNDO

    SELECT @profile_id = profile_id 
        FROM msdb..MSagent_profiles
        WHERE profile_name = @profile_name collate database_default AND agent_type = @agent_type

	/*
	** If there is system profiles of the same agent type, use the primary system one as template of parameter set
	*/
	IF EXISTS (select * from msdb..MSagent_profiles where agent_type = @agent_type AND type = 0)
		select @sysdefault_id = min(profile_id) from msdb..MSagent_profiles where agent_type = @agent_type AND type = 0

	if @sysdefault_id IS NULL
		select @sysdefault_id = @default_id

	if @profile_type=1
	BEGIN
   	 	INSERT INTO msdb..MSagent_parameters 
    	    select @profile_id, parameter_name, value from msdb..MSagent_parameters 
        	    where profile_id = @sysdefault_id      
		if @@ERROR<>0 
			GOTO UNDO
	END

    /* Only one profile for an agent type must be default */
    IF @default = 1
		BEGIN
			UPDATE msdb..MSagent_profiles
				SET def_profile = 0 WHERE profile_id = @default_id
			IF @@ERROR <> 0
				GOTO UNDO
			UPDATE msdb..MSagent_profiles
				SET def_profile = 1 WHERE profile_id = @profile_id
			IF @@ERROR <> 0
				GOTO UNDO
		END

    COMMIT TRAN
    RETURN 0 

UNDO:

    IF @@TRANCOUNT = 1
        ROLLBACK TRAN
    ELSE
        COMMIT TRAN

    RETURN 1 
GO

raiserror('Creating procedure sp_drop_agent_parameter', 0,1)
go

-- Drop a/all parameter(s) of a/all profile(s) from the MSagent_parameters table
create procedure sp_drop_agent_parameter (
    @profile_id int,
    @parameter_name     sysname = '%'
)
as
    set nocount on

    declare @default            bit
    declare @agent_type         int
    declare @retstatus          int
    select @retstatus = 0

    if @parameter_name is null
    BEGIN
        RAISERROR (14043, 16, -1, '@parameter_name')
        RETURN (1)
    END

    select @agent_type = agent_type, @default=def_profile
    from msdb..MSagent_profiles
    where profile_id = @profile_id

    if @default is null
    BEGIN
        RAISERROR (20066, 16, -1) -- profile not defined
        RETURN (1)
    END
    
    select @parameter_name = lower(@parameter_name collate SQL_Latin1_General_CP1_CS_AS)

    if left(@parameter_name,1) in (N'-', N'/')
        select @parameter_name = right(@parameter_name,len(@parameter_name)-1)

    /* Delete the parameters of the profile */
    delete  msdb..MSagent_parameters 
    where   right(lower(parameter_name collate SQL_Latin1_General_CP1_CS_AS),len(parameter_name)-1) like 
            @parameter_name collate SQL_Latin1_General_CP1_CS_AS
    and     profile_id = @profile_id

    if @@error <> 0
    begin
        select @retstatus = 1
        goto UNDO
    end

UNDO:
    
    return @retstatus
GO

raiserror('Creating procedure sp_drop_agent_profile', 0,1)
go
-- Drop a profile from the MSagent_profiles table, as well as the corresponding
-- parameters from the MSagent_parameters table

CREATE PROCEDURE sp_drop_agent_profile (
    @profile_id int
)
AS
    SET NOCOUNT ON

    declare @snapshot_type      int
    declare @logreader_type     int
    declare @distribution_type  int
    declare @merge_type         int
    declare @qreader_type		int
    
    declare @tablename          nvarchar(255)
    declare @proc               nvarchar(255)
    declare @distribution_db    sysname
    declare @profile_type       int

    declare @default            bit
    declare @usage_count        int
    declare @agent_type         int
    declare @retstatus          int
    DECLARE @retcode            int

    declare @default_sys_id     int

    SELECT @agent_type = agent_type, @profile_type = type, @default=def_profile
    FROM msdb..MSagent_profiles
    WHERE profile_id = @profile_id

    IF @default IS NULL
    BEGIN
        RAISERROR (20066, 16, -1) -- Profile not defined
        RETURN (1)
    END

    /*
    ** Before dropping a default profile, one system profile of the same agent type
    ** has to become the new default profile.
    */
    IF @default = 1
    BEGIN
        select @default_sys_id=min(profile_id) from msdb..MSagent_profiles
            where agent_type = @agent_type AND type = 0
            
        UPDATE msdb..MSagent_profiles SET def_profile = 1 WHERE profile_id = @default_sys_id
    END

    select @snapshot_type = 1
    select @logreader_type = 2
    select @distribution_type = 3
    select @merge_type = 4
    select @qreader_type = 9

        /* By default, assume that this profile is not being used */
    select @usage_count = -1

    select @tablename = 
        case @agent_type
            when @snapshot_type then 'MSsnapshot_agents'
            when @logreader_type then 'MSlogreader_agents'
            when @distribution_type then 'MSdistribution_agents'
            when @merge_type then 'MSmerge_agents'
            when @qreader_type then 'MSqreader_agents'
        end

    declare hCdistdbs CURSOR LOCAL FAST_FORWARD FOR
        select distinct distribution_db 
        from msdb..MSdistpublishers
        for read only

    open hCdistdbs
    fetch hCdistdbs into @distribution_db

    while @@fetch_status <> -1 and @usage_count = -1
    begin
        select @proc = @distribution_db + '.dbo.sp_MSprofile_in_use'
        execute @usage_count = @proc @tablename = @tablename, @profile_id = @profile_id
    
        if @@error <> 0
        begin
            select @retstatus = 1
            goto UNDO
        end

        fetch hCdistdbs into @distribution_db
    end

    /* A profile in use cannot be dropped */
    if @usage_count = 0 
    begin
        RAISERROR(20065, 16, -1) -- Cannot drop profile, because it is in use.
        select @retstatus = 1
        goto UNDO 
    end

    BEGIN TRAN

    /*****
     * NOTE : If sp_drop_agent_parameter fails, the profile must not be 
     * deleted either 
     */
    EXECUTE @retcode = dbo.sp_drop_agent_parameter @profile_id = @profile_id,
                            @parameter_name = '%'

    IF @@ERROR <> 0 OR @retcode <> 0
        GOTO UNDO
            
    /* Delete all the entries in one go */
    DELETE msdb..MSagent_profiles 
    WHERE profile_id = @profile_id

    IF @@ERROR <> 0
        GOTO UNDO

    COMMIT TRAN

    close hCdistdbs
    deallocate hCdistdbs

    RETURN 0

UNDO:
    IF @@TRANCOUNT = 1
        ROLLBACK TRAN
    ELSE IF @@TRANCOUNT > 1 -- Sometimes we can get here when @@trancount = 0, so need to check explicitly.
        COMMIT TRAN

    close hCdistdbs
    deallocate hCdistdbs


    RETURN (1)
GO

raiserror('Creating procedure sp_help_agent_profile', 0,1)
go


-- View the row(s) of the MSagent_profiles table

create procedure sp_help_agent_profile(
    @agent_type     int = 0,
    @profile_id int = -1
)
as
    set nocount on

    declare @proc nvarchar(255)

    declare @snapshot_type      int
    declare @logreader_type     int
    declare @distribution_type  int
    declare @merge_type     int
    declare @qreader_type		int

    select @snapshot_type = 1
    select @logreader_type = 2
    select @distribution_type = 3
    select @merge_type = 4
    select @qreader_type = 9

    if @agent_type is null 
    BEGIN
        RAISERROR (14043, 16, -1, '@agent_type')
        RETURN (1)
    END

    if @profile_id is null
    BEGIN
        RAISERROR (14043, 16, -1, '@profile_id')
        RETURN (1)
    END

    if @agent_type not in (0, @snapshot_type, @logreader_type, @distribution_type, @merge_type, @qreader_type)
    BEGIN
        RAISERROR(20058, 16, -1)
        return (1)
    END

    select profile_id, profile_name, agent_type, type, description, def_profile
		from msdb..MSagent_profiles where
			 (profile_id = @profile_id or @profile_id = -1) and
			 (agent_type = @agent_type or @agent_type = 0)
		order by profile_id, profile_name

GO

raiserror('Creating procedure sp_help_agent_default', 0,1)
go

create procedure sp_help_agent_default (
    @profile_id     int OUTPUT, 
    @agent_type         int
)
as
    set nocount on

    if @agent_type not in (1, 2, 3, 4)
    BEGIN
        RAISERROR(20058, 16, -1)
        return (1)
    END


    select @profile_id = profile_id 
    from msdb..MSagent_profiles 
    where agent_type = @agent_type
    and def_profile = 1 
go

raiserror('Creating procedure sp_MSupdate_agenttype_default', 0,1)
go

-- Set a profile as a default for an agent_type
create procedure sp_MSupdate_agenttype_default(
    @profile_id int
)
as
    set nocount on

    declare @agent_type int

    /* This profile must have been defined for this agent type */
    if not exists ( select * from msdb..MSagent_profiles
            where profile_id = @profile_id )
    BEGIN
        RAISERROR (20066, 16, -1)   -- profile not defined
        RETURN (1)
    END


    select @agent_type = agent_type
    from msdb..MSagent_profiles 
    where profile_id = @profile_id

    BEGIN TRAN

    update msdb..MSagent_profiles
    set def_profile = 0
    where agent_type = @agent_type
    and def_profile = 1

    if @@error <> 0
        goto UNDO

    update msdb..MSagent_profiles
    set def_profile = 1
    where profile_id = @profile_id

    if @@error <> 0
        goto UNDO 

    COMMIT TRAN

    return 0

UNDO:
    if @@trancount = 1
        rollback tran
    else
        commit tran

    return 1 
GO


/*
** Create stored procedures to generate default profile 
** parameters for replication agents.
*/

raiserror('Creating procedure sp_generate_agent_parameter', 0,1)
GO

create procedure sp_generate_agent_parameter(
	@profile_id     int,		-- Fixed profile id used
	@real_profile_id int = NULL -- Used by version upgrade 
)
as
	declare @retcode    int

	-- If real profile id is not passed in. Use the fix profile id.
	if @real_profile_id is NULL
		select @real_profile_id = @profile_id

        /* 
	** Snapshot agent 
	*/
	if (@profile_id = 1)
        begin
		exec @retcode = dbo.sp_add_agent_parameter 
			    @profile_id = @real_profile_id,
				@parameter_name = '-BcpBatchSize',
				@parameter_value = '100000'
		if (@retcode = 1 or @@ERROR <> 0)
			goto FAILURE

		exec @retcode = dbo.sp_add_agent_parameter 
				@profile_id = @real_profile_id,
				@parameter_name = '-HistoryVerboseLevel',
				@parameter_value = '2'
		if (@retcode = 1 or @@ERROR <> 0)
			goto FAILURE

		exec @retcode = dbo.sp_add_agent_parameter 
				@profile_id = @real_profile_id,
				@parameter_name = '-LoginTimeout',
				@parameter_value = '15'
		if (@retcode = 1 or @@ERROR <> 0)
			goto FAILURE

		exec @retcode = dbo.sp_add_agent_parameter 
				@profile_id = @real_profile_id,
				@parameter_name = '-MaxBcpThreads',
				@parameter_value = '1'
		if (@retcode = 1 or @@ERROR <> 0)
			goto FAILURE

		exec @retcode = dbo.sp_add_agent_parameter 
				@profile_id = @real_profile_id,
				@parameter_name = '-QueryTimeout',
				@parameter_value = '300'        -- 5 minutes 
		if (@retcode = 1 or @@ERROR <> 0)
			goto FAILURE
        end

        /* 
	** Logreader agent 
	*/
	else if (@profile_id = 2)
        begin
  
		exec @retcode = dbo.sp_add_agent_parameter 
				@profile_id = @real_profile_id,
				@parameter_name = '-HistoryVerboseLevel',
				@parameter_value = '1'
		if (@retcode = 1 or @@ERROR <> 0)
			goto FAILURE

		exec @retcode = dbo.sp_add_agent_parameter 
				@profile_id = @real_profile_id,
				@parameter_name = '-LoginTimeout',
				@parameter_value = '15'
		if (@retcode = 1 or @@ERROR <> 0)
			goto FAILURE

		exec @retcode = dbo.sp_add_agent_parameter 
				@profile_id = @real_profile_id,
				@parameter_name = '-PollingInterval',
				@parameter_value = '10'
		if (@retcode = 1 or @@ERROR <> 0)
			goto FAILURE

		exec @retcode = dbo.sp_add_agent_parameter 
				@profile_id = @real_profile_id,
				@parameter_name = '-QueryTimeout',
				@parameter_value = '300'        -- 5 minutes
		if (@retcode = 1 or @@ERROR <> 0)
			goto FAILURE

		exec @retcode = dbo.sp_add_agent_parameter 
				@profile_id = @real_profile_id,
				@parameter_name = '-ReadBatchSize',
				@parameter_value = '500'
		if (@retcode = 1 or @@ERROR <> 0)
			goto FAILURE

        end

        /* 
	** Logreader agent - Verbose History Profile
	*/
	else if (@profile_id = 3)
        begin

		exec @retcode = dbo.sp_add_agent_parameter 
				@profile_id = @real_profile_id,
				@parameter_name = '-HistoryVerboseLevel',
				@parameter_value = '2'
		if (@retcode = 1 or @@ERROR <> 0)
			goto FAILURE

		exec @retcode = dbo.sp_add_agent_parameter 
				@profile_id = @real_profile_id,
				@parameter_name = '-LoginTimeout',
				@parameter_value = '15'
		if (@retcode = 1 or @@ERROR <> 0)
			goto FAILURE

		exec @retcode = dbo.sp_add_agent_parameter 
				@profile_id = @real_profile_id,
				@parameter_name = '-PollingInterval',
				@parameter_value = '10'
		if (@retcode = 1 or @@ERROR <> 0)
			goto FAILURE

		exec @retcode = dbo.sp_add_agent_parameter 
				@profile_id = @real_profile_id,
				@parameter_name = '-QueryTimeout',
				@parameter_value = '300'        -- 5 minutes
		if (@retcode = 1 or @@ERROR <> 0)
			goto FAILURE

		exec @retcode = dbo.sp_add_agent_parameter 
				@profile_id = @real_profile_id,
				@parameter_name = '-ReadBatchSize',
				@parameter_value = '500'
		if (@retcode = 1 or @@ERROR <> 0)
			goto FAILURE

        end

        /* 
	** Distribution agent 
	*/
	else if (@profile_id = 4)
	  begin

		exec @retcode = dbo.sp_add_agent_parameter 
				@profile_id = @real_profile_id,
				@parameter_name = '-BcpBatchSize',
				@parameter_value = '100000'
		if (@retcode = 1 or @@ERROR <> 0)
			goto FAILURE

		exec @retcode = dbo.sp_add_agent_parameter 
				@profile_id = @real_profile_id,
				@parameter_name = '-CommitBatchSize',
				@parameter_value = '100'
		if (@retcode = 1 or @@ERROR <> 0)
			goto FAILURE

		exec @retcode = dbo.sp_add_agent_parameter 
				@profile_id = @real_profile_id,
				@parameter_name = '-CommitBatchThreshold',
				@parameter_value = '1000'
		if (@retcode = 1 or @@ERROR <> 0)
			goto FAILURE

		exec @retcode = dbo.sp_add_agent_parameter 
				@profile_id = @real_profile_id,
				@parameter_name = '-HistoryVerboseLevel',
				@parameter_value = '1'
		if (@retcode = 1 or @@ERROR <> 0)
			goto FAILURE

		exec @retcode = dbo.sp_add_agent_parameter 
				@profile_id = @real_profile_id,
				@parameter_name = '-LoginTimeout',
				@parameter_value = '15'
		if (@retcode = 1 or @@ERROR <> 0)
			goto FAILURE

		exec @retcode = dbo.sp_add_agent_parameter 
				@profile_id = @real_profile_id,
				@parameter_name = '-MaxBcpThreads',
				@parameter_value = '1'
		if (@retcode = 1 or @@ERROR <> 0)
			goto FAILURE

		exec @retcode = dbo.sp_add_agent_parameter 
				@profile_id = @real_profile_id,
				@parameter_name = '-MaxDeliveredTransactions',
				@parameter_value = '0'
		if (@retcode = 1 or @@ERROR <> 0)
			goto FAILURE

		exec @retcode = dbo.sp_add_agent_parameter 
				@profile_id = @real_profile_id,
				@parameter_name = '-PollingInterval',
				@parameter_value = '10'
		if (@retcode = 1 or @@ERROR <> 0)
			goto FAILURE

		exec @retcode = dbo.sp_add_agent_parameter 
				@profile_id = @real_profile_id,
				@parameter_name = '-QueryTimeout',
				@parameter_value = '300'        -- 5 minutes 
		if (@retcode = 1 or @@ERROR <> 0)
			goto FAILURE

		exec @retcode = dbo.sp_add_agent_parameter 
				@profile_id = @real_profile_id,
				@parameter_name = '-TransactionsPerHistory',
				@parameter_value = '100'
		if (@retcode = 1 or @@ERROR <> 0)
			goto FAILURE

		exec @retcode = dbo.sp_add_agent_parameter 
				@profile_id = @real_profile_id,
				@parameter_name = '-SkipErrors',
				@parameter_value = ''
		if (@retcode = 1 or @@ERROR <> 0)
			goto FAILURE

        exec @retcode = dbo.sp_add_agent_parameter
                @profile_id = @real_profile_id,
                @parameter_name = '-KeepAliveMessageInterval',
                @parameter_value = '300'
        if (@retcode = 1 or @@ERROR <> 0)
            goto FAILURE

	    end

    /*
	** Distribution Agent Verbose History Profile
	*/
	else if (@profile_id = 5)
	  begin

		exec @retcode = dbo.sp_add_agent_parameter 
				@profile_id = @real_profile_id,
				@parameter_name = '-BcpBatchSize',
				@parameter_value = '100000'
		if (@retcode = 1 or @@ERROR <> 0)
			goto FAILURE

		exec @retcode = dbo.sp_add_agent_parameter 
				@profile_id = @real_profile_id,
				@parameter_name = '-CommitBatchSize',
				@parameter_value = '100'
		if (@retcode = 1 or @@ERROR <> 0)
			goto FAILURE

		exec @retcode = dbo.sp_add_agent_parameter 
				@profile_id = @real_profile_id,
				@parameter_name = '-CommitBatchThreshold',
				@parameter_value = '1000'
		if (@retcode = 1 or @@ERROR <> 0)
			goto FAILURE

		exec @retcode = dbo.sp_add_agent_parameter 
				@profile_id = @real_profile_id,
				@parameter_name = '-HistoryVerboseLevel',
				@parameter_value = '2'
		if (@retcode = 1 or @@ERROR <> 0)
			goto FAILURE

		exec @retcode = dbo.sp_add_agent_parameter 
				@profile_id = @real_profile_id,
				@parameter_name = '-LoginTimeout',
				@parameter_value = '15'
		if (@retcode = 1 or @@ERROR <> 0)
			goto FAILURE

		exec @retcode = dbo.sp_add_agent_parameter 
				@profile_id = @real_profile_id,
				@parameter_name = '-MaxBcpThreads',
				@parameter_value = '1'
		if (@retcode = 1 or @@ERROR <> 0)
			goto FAILURE

		exec @retcode = dbo.sp_add_agent_parameter 
				@profile_id = @real_profile_id,
				@parameter_name = '-MaxDeliveredTransactions',
				@parameter_value = '0'
		if (@retcode = 1 or @@ERROR <> 0)
			goto FAILURE

		exec @retcode = dbo.sp_add_agent_parameter 
				@profile_id = @real_profile_id,
				@parameter_name = '-PollingInterval',
				@parameter_value = '10'
		if (@retcode = 1 or @@ERROR <> 0)
			goto FAILURE

		exec @retcode = dbo.sp_add_agent_parameter 
				@profile_id = @real_profile_id,
				@parameter_name = '-QueryTimeout',
				@parameter_value = '300'        -- 5 minutes 
		if (@retcode = 1 or @@ERROR <> 0)
			goto FAILURE

		exec @retcode = dbo.sp_add_agent_parameter 
				@profile_id = @real_profile_id,
				@parameter_name = '-TransactionsPerHistory',
				@parameter_value = '100'
		if (@retcode = 1 or @@ERROR <> 0)
			goto FAILURE

		exec @retcode = dbo.sp_add_agent_parameter 
				@profile_id = @real_profile_id,
				@parameter_name = '-SkipErrors',
				@parameter_value = ''
		if (@retcode = 1 or @@ERROR <> 0)
			goto FAILURE

        exec @retcode = dbo.sp_add_agent_parameter
                @profile_id = @real_profile_id,
                @parameter_name = '-KeepAliveMessageInterval',
                @parameter_value = '300'
        if (@retcode = 1 or @@ERROR <> 0)
            goto FAILURE

        end
    /* 
	** Merge agent : Default profile for well connected scenarios 
	*/
	else if (@profile_id = 6)
        begin
		exec @retcode = dbo.sp_add_agent_parameter 
				@profile_id = @real_profile_id,
				@parameter_name = '-PollingInterval',
				@parameter_value = '60'
		if (@retcode = 1 or @@ERROR <> 0)
			goto FAILURE

		exec @retcode = dbo.sp_add_agent_parameter 
				@profile_id = @real_profile_id,
				@parameter_name = '-StartQueueTimeout',
				@parameter_value = '0'
		if (@retcode = 1 or @@ERROR <> 0)
			goto FAILURE

		exec @retcode = dbo.sp_add_agent_parameter 
				@profile_id = @real_profile_id,
				@parameter_name = '-MaxDownloadChanges',
				@parameter_value = '0'
		if (@retcode = 1 or @@ERROR <> 0)
			goto FAILURE

		exec @retcode = dbo.sp_add_agent_parameter 
				@profile_id = @real_profile_id,
				@parameter_name = '-MaxUploadChanges',
				@parameter_value = '0'
		if (@retcode = 1 or @@ERROR <> 0)
			goto FAILURE

		exec @retcode = dbo.sp_add_agent_parameter 
				@profile_id = @real_profile_id,
				@parameter_name = '-ValidateInterval',
				@parameter_value = '60'
		if (@retcode = 1 or @@ERROR <> 0)
			goto FAILURE

		exec @retcode = dbo.sp_add_agent_parameter 
				@profile_id = @real_profile_id,
				@parameter_name = '-LoginTimeout',
				@parameter_value = '15'
		if (@retcode = 1 or @@ERROR <> 0)
			goto FAILURE

		exec @retcode = dbo.sp_add_agent_parameter 
				@profile_id = @real_profile_id,
				@parameter_name = '-QueryTimeout',
				@parameter_value = '300'        
		if (@retcode = 1 or @@ERROR <> 0)
			goto FAILURE

		exec @retcode = dbo.sp_add_agent_parameter 
				@profile_id = @real_profile_id,
				@parameter_name = '-UploadGenerationsPerBatch',
				@parameter_value = '100'
		if (@retcode = 1 or @@ERROR <> 0)
			goto FAILURE

		exec @retcode = dbo.sp_add_agent_parameter 
				@profile_id = @real_profile_id,
				@parameter_name = '-DownloadGenerationsPerBatch',
				@parameter_value = '100'
		if (@retcode = 1 or @@ERROR <> 0)
			goto FAILURE

		exec @retcode = dbo.sp_add_agent_parameter 
				@profile_id = @real_profile_id,
				@parameter_name = '-UploadReadChangesPerBatch',
				@parameter_value = '100'
		if (@retcode = 1 or @@ERROR <> 0)
			goto FAILURE

		exec @retcode = dbo.sp_add_agent_parameter 
				@profile_id = @real_profile_id,
				@parameter_name = '-DownloadReadChangesPerBatch',
				@parameter_value = '100'
		if (@retcode = 1 or @@ERROR <> 0)
			goto FAILURE

		exec @retcode = dbo.sp_add_agent_parameter 
				@profile_id = @real_profile_id,
				@parameter_name = '-UploadWriteChangesPerBatch',
				@parameter_value = '100'
		if (@retcode = 1 or @@ERROR <> 0)
			goto FAILURE

		exec @retcode = dbo.sp_add_agent_parameter 
				@profile_id = @real_profile_id,
				@parameter_name = '-DownloadWriteChangesPerBatch',
				@parameter_value = '100'
		if (@retcode = 1 or @@ERROR <> 0)
			goto FAILURE

		exec @retcode = dbo.sp_add_agent_parameter 
				@profile_id = @real_profile_id,
				@parameter_name = '-Validate',
				@parameter_value = '0'
		if (@retcode = 1 or @@ERROR <> 0)
			goto FAILURE

		exec @retcode = dbo.sp_add_agent_parameter 
				@profile_id = @real_profile_id,
				@parameter_name = '-FastRowCount',
				@parameter_value = '1'
		if (@retcode = 1 or @@ERROR <> 0)
			goto FAILURE
        
		exec @retcode = dbo.sp_add_agent_parameter 
				@profile_id = @real_profile_id,
				@parameter_name = '-HistoryVerboseLevel',
				@parameter_value = '1'
		if (@retcode = 1 or @@ERROR <> 0)
			goto FAILURE

		exec @retcode = dbo.sp_add_agent_parameter 
				@profile_id = @real_profile_id,
				@parameter_name = '-ChangesPerHistory',
				@parameter_value = '100'
		if (@retcode = 1 or @@ERROR <> 0)
			goto FAILURE

		exec @retcode = dbo.sp_add_agent_parameter 
			    @profile_id = @real_profile_id,
				@parameter_name = '-BcpBatchSize',
				@parameter_value = '100000'
		if (@retcode = 1 or @@ERROR <> 0)
			goto FAILURE

		exec @retcode = dbo.sp_add_agent_parameter 
			    @profile_id = @real_profile_id,
				@parameter_name = '-NumDeadlockRetries',
				@parameter_value = '5'
		if (@retcode = 1 or @@ERROR <> 0)
			goto FAILURE

		exec @retcode = dbo.sp_add_agent_parameter 
			    @profile_id = @real_profile_id,
				@parameter_name = '-SrcThreads',
				@parameter_value = '3'
		if (@retcode = 1 or @@ERROR <> 0)
			goto FAILURE

		exec @retcode = dbo.sp_add_agent_parameter 
			    @profile_id = @real_profile_id,
				@parameter_name = '-DestThreads',
				@parameter_value = '4'
		if (@retcode = 1 or @@ERROR <> 0)
			goto FAILURE

        exec @retcode = dbo.sp_add_agent_parameter
                @profile_id = @real_profile_id,
                @parameter_name = '-KeepAliveMessageInterval',
                @parameter_value = '300'
        if (@retcode = 1 or @@ERROR <> 0)
            goto FAILURE

        exec @retcode = dbo.sp_add_agent_parameter
                @profile_id = @real_profile_id,
                @parameter_name = '-MetadataRetentionCleanup',
                @parameter_value = '1'
        if (@retcode = 1 or @@ERROR <> 0)
            goto FAILURE

        end

    /* 
	** Merge agent : Non default profile for disconnected scenarios ( unreliable link ) 
	*/
	else if (@profile_id = 7)
        begin

		exec @retcode = dbo.sp_add_agent_parameter 
				@profile_id = @real_profile_id,
				@parameter_name = '-PollingInterval',
				@parameter_value = '60'
		if (@retcode = 1 or @@ERROR <> 0)
			goto FAILURE

		exec @retcode = dbo.sp_add_agent_parameter 
				@profile_id = @real_profile_id,
				@parameter_name = '-StartQueueTimeout',
				@parameter_value = '0'
		if (@retcode = 1 or @@ERROR <> 0)
			goto FAILURE

		exec @retcode = dbo.sp_add_agent_parameter 
				@profile_id = @real_profile_id,
				@parameter_name = '-MaxDownloadChanges',
				@parameter_value = '0'
		if (@retcode = 1 or @@ERROR <> 0)
			goto FAILURE

		exec @retcode = dbo.sp_add_agent_parameter 
				@profile_id = @real_profile_id,
				@parameter_name = '-MaxUploadChanges',
				@parameter_value = '0'
		if (@retcode = 1 or @@ERROR <> 0)
			goto FAILURE
			
		exec @retcode = dbo.sp_add_agent_parameter 
				@profile_id = @real_profile_id,
				@parameter_name = '-ValidateInterval',
				@parameter_value = '60'
		if (@retcode = 1 or @@ERROR <> 0)
			goto FAILURE

		exec @retcode = dbo.sp_add_agent_parameter 
				@profile_id = @real_profile_id,
				@parameter_name = '-LoginTimeout',
				@parameter_value = '15'
		if (@retcode = 1 or @@ERROR <> 0)
			goto FAILURE

		exec @retcode = dbo.sp_add_agent_parameter 
				@profile_id = @real_profile_id,
				@parameter_name = '-QueryTimeout',
				@parameter_value = '300'
		if (@retcode = 1 or @@ERROR <> 0)
			goto FAILURE

		exec @retcode = dbo.sp_add_agent_parameter 
				@profile_id = @real_profile_id,
				@parameter_name = '-UploadGenerationsPerBatch',
				@parameter_value = '20'
		if (@retcode = 1 or @@ERROR <> 0)
			goto FAILURE

		exec @retcode = dbo.sp_add_agent_parameter 
				@profile_id = @real_profile_id,
				@parameter_name = '-DownloadGenerationsPerBatch',
				@parameter_value = '100'
		if (@retcode = 1 or @@ERROR <> 0)
			goto FAILURE

		exec @retcode = dbo.sp_add_agent_parameter 
				@profile_id = @real_profile_id,
				@parameter_name = '-UploadReadChangesPerBatch',
				@parameter_value = '100'
		if (@retcode = 1 or @@ERROR <> 0)
			goto FAILURE

		exec @retcode = dbo.sp_add_agent_parameter 
				@profile_id = @real_profile_id,
				@parameter_name = '-DownloadReadChangesPerBatch',
				@parameter_value = '100'
		if (@retcode = 1 or @@ERROR <> 0)
			goto FAILURE

		exec @retcode = dbo.sp_add_agent_parameter 
				@profile_id = @real_profile_id,
				@parameter_name = '-UploadWriteChangesPerBatch',
				@parameter_value = '100'
		if (@retcode = 1 or @@ERROR <> 0)
			goto FAILURE

		exec @retcode = dbo.sp_add_agent_parameter 
				@profile_id = @real_profile_id,
				@parameter_name = '-DownloadWriteChangesPerBatch',
				@parameter_value = '100'
		if (@retcode = 1 or @@ERROR <> 0)
			goto FAILURE

		exec @retcode = dbo.sp_add_agent_parameter 
				@profile_id = @real_profile_id,
				@parameter_name = '-Validate',
				@parameter_value = '0'
		if (@retcode = 1 or @@ERROR <> 0)
			goto FAILURE
        
		exec @retcode = dbo.sp_add_agent_parameter 
				@profile_id = @real_profile_id,
				@parameter_name = '-FastRowCount',
				@parameter_value = '1'
		if (@retcode = 1 or @@ERROR <> 0)
			goto FAILURE

		exec @retcode = dbo.sp_add_agent_parameter 
				@profile_id = @real_profile_id,
				@parameter_name = '-HistoryVerboseLevel',
				@parameter_value = '1'
		if (@retcode = 1 or @@ERROR <> 0)
			goto FAILURE

		exec @retcode = dbo.sp_add_agent_parameter 
				@profile_id = @real_profile_id,
				@parameter_name = '-ChangesPerHistory',
				@parameter_value = '100'
		if (@retcode = 1 or @@ERROR <> 0)
			goto FAILURE

		exec @retcode = dbo.sp_add_agent_parameter 
			    @profile_id = @real_profile_id,
				@parameter_name = '-BcpBatchSize',
				@parameter_value = '100000'
		if (@retcode = 1 or @@ERROR <> 0)
			goto FAILURE

		exec @retcode = dbo.sp_add_agent_parameter 
			    @profile_id = @real_profile_id,
				@parameter_name = '-KeepAliveMessageInterval',
				@parameter_value = '300'
		if (@retcode = 1 or @@ERROR <> 0)
			goto FAILURE

		exec @retcode = dbo.sp_add_agent_parameter 
			    @profile_id = @real_profile_id,
				@parameter_name = '-NumDeadlockRetries',
				@parameter_value = '5'
		if (@retcode = 1 or @@ERROR <> 0)
			goto FAILURE

		exec @retcode = dbo.sp_add_agent_parameter 
			    @profile_id = @real_profile_id,
				@parameter_name = '-SrcThreads',
				@parameter_value = '3'
		if (@retcode = 1 or @@ERROR <> 0)
			goto FAILURE

		exec @retcode = dbo.sp_add_agent_parameter 
			    @profile_id = @real_profile_id,
				@parameter_name = '-DestThreads',
				@parameter_value = '4'
		if (@retcode = 1 or @@ERROR <> 0)
			goto FAILURE

        exec @retcode = dbo.sp_add_agent_parameter
                @profile_id = @real_profile_id,
                @parameter_name = '-MetadataRetentionCleanup',
                @parameter_value = '1'
        if (@retcode = 1 or @@ERROR <> 0)
            goto FAILURE

        end

        /* 
	** Merge agent : Default profile for well connected scenarios - Verbose history logging 
	*/
	else if (@profile_id = 8)
        begin
		exec @retcode = dbo.sp_add_agent_parameter 
				@profile_id = @real_profile_id,
				@parameter_name = '-PollingInterval',
				@parameter_value = '60'
		if (@retcode = 1 or @@ERROR <> 0)
			goto FAILURE
			
		exec @retcode = dbo.sp_add_agent_parameter 
				@profile_id = @real_profile_id,
				@parameter_name = '-StartQueueTimeout',
				@parameter_value = '0'
		if (@retcode = 1 or @@ERROR <> 0)
			goto FAILURE
			
		exec @retcode = dbo.sp_add_agent_parameter 
				@profile_id = @real_profile_id,
				@parameter_name = '-MaxDownloadChanges',
				@parameter_value = '0'
		if (@retcode = 1 or @@ERROR <> 0)
			goto FAILURE

		exec @retcode = dbo.sp_add_agent_parameter 
				@profile_id = @real_profile_id,
				@parameter_name = '-MaxUploadChanges',
				@parameter_value = '0'
		if (@retcode = 1 or @@ERROR <> 0)
			goto FAILURE

		exec @retcode = dbo.sp_add_agent_parameter 
				@profile_id = @real_profile_id,
				@parameter_name = '-ValidateInterval',
				@parameter_value = '60'
		if (@retcode = 1 or @@ERROR <> 0)
			goto FAILURE

		exec @retcode = dbo.sp_add_agent_parameter 
				@profile_id = @real_profile_id,
				@parameter_name = '-LoginTimeout',
				@parameter_value = '15'
		if (@retcode = 1 or @@ERROR <> 0)
			goto FAILURE

		exec @retcode = dbo.sp_add_agent_parameter 
				@profile_id = @real_profile_id,
				@parameter_name = '-QueryTimeout',
				@parameter_value = '300'        
		if (@retcode = 1 or @@ERROR <> 0)
			goto FAILURE

		exec @retcode = dbo.sp_add_agent_parameter 
				@profile_id = @real_profile_id,
				@parameter_name = '-UploadGenerationsPerBatch',
				@parameter_value = '100'
		if (@retcode = 1 or @@ERROR <> 0)
			goto FAILURE

		exec @retcode = dbo.sp_add_agent_parameter 
				@profile_id = @real_profile_id,
				@parameter_name = '-DownloadGenerationsPerBatch',
				@parameter_value = '100'
		if (@retcode = 1 or @@ERROR <> 0)
			goto FAILURE

		exec @retcode = dbo.sp_add_agent_parameter 
				@profile_id = @real_profile_id,
				@parameter_name = '-UploadReadChangesPerBatch',
				@parameter_value = '100'
		if (@retcode = 1 or @@ERROR <> 0)
			goto FAILURE

		exec @retcode = dbo.sp_add_agent_parameter 
				@profile_id = @real_profile_id,
				@parameter_name = '-DownloadReadChangesPerBatch',
				@parameter_value = '100'
		if (@retcode = 1 or @@ERROR <> 0)
			goto FAILURE

		exec @retcode = dbo.sp_add_agent_parameter 
				@profile_id = @real_profile_id,
				@parameter_name = '-UploadWriteChangesPerBatch',
				@parameter_value = '100'
		if (@retcode = 1 or @@ERROR <> 0)
			goto FAILURE

		exec @retcode = dbo.sp_add_agent_parameter 
				@profile_id = @real_profile_id,
				@parameter_name = '-DownloadWriteChangesPerBatch',
				@parameter_value = '100'
		if (@retcode = 1 or @@ERROR <> 0)
			goto FAILURE

		exec @retcode = dbo.sp_add_agent_parameter 
				@profile_id = @real_profile_id,
				@parameter_name = '-Validate',
				@parameter_value = '0'
		if (@retcode = 1 or @@ERROR <> 0)
			goto FAILURE

		exec @retcode = dbo.sp_add_agent_parameter 
				@profile_id = @real_profile_id,
				@parameter_name = '-FastRowCount',
				@parameter_value = '1'
		if (@retcode = 1 or @@ERROR <> 0)
			goto FAILURE
        
		exec @retcode = dbo.sp_add_agent_parameter 
				@profile_id = @real_profile_id,
				@parameter_name = '-HistoryVerboseLevel',
				@parameter_value = '3'
		if (@retcode = 1 or @@ERROR <> 0)
			goto FAILURE

		exec @retcode = dbo.sp_add_agent_parameter 
				@profile_id = @real_profile_id,
				@parameter_name = '-ChangesPerHistory',
				@parameter_value = '50'
		if (@retcode = 1 or @@ERROR <> 0)
			goto FAILURE

		exec @retcode = dbo.sp_add_agent_parameter 
			    @profile_id = @real_profile_id,
				@parameter_name = '-BcpBatchSize',
				@parameter_value = '100000'
		if (@retcode = 1 or @@ERROR <> 0)
			goto FAILURE

		exec @retcode = dbo.sp_add_agent_parameter 
			    @profile_id = @real_profile_id,
				@parameter_name = '-NumDeadlockRetries',
				@parameter_value = '5'
		if (@retcode = 1 or @@ERROR <> 0)
			goto FAILURE

		exec @retcode = dbo.sp_add_agent_parameter 
			    @profile_id = @real_profile_id,
				@parameter_name = '-SrcThreads',
				@parameter_value = '3'
		if (@retcode = 1 or @@ERROR <> 0)
			goto FAILURE

		exec @retcode = dbo.sp_add_agent_parameter 
			    @profile_id = @real_profile_id,
				@parameter_name = '-DestThreads',
				@parameter_value = '4'
		if (@retcode = 1 or @@ERROR <> 0)
			goto FAILURE

        exec @retcode = dbo.sp_add_agent_parameter
                @profile_id = @real_profile_id,
                @parameter_name = '-KeepAliveMessageInterval',
                @parameter_value = '300'
        if (@retcode = 1 or @@ERROR <> 0)
            goto FAILURE

        exec @retcode = dbo.sp_add_agent_parameter
                @profile_id = @real_profile_id,
                @parameter_name = '-MetadataRetentionCleanup',
                @parameter_value = '1'
        if (@retcode = 1 or @@ERROR <> 0)
            goto FAILURE

        end

    /* 
	** Merge agent : (Synchronization Manager Profile)
	*/
	else if (@profile_id = 9)
        begin
		exec @retcode = dbo.sp_add_agent_parameter 
				@profile_id = @real_profile_id,
				@parameter_name = '-PollingInterval',
				@parameter_value = '60'
		if (@retcode = 1 or @@ERROR <> 0)
			goto FAILURE

		exec @retcode = dbo.sp_add_agent_parameter 
				@profile_id = @real_profile_id,
				@parameter_name = '-StartQueueTimeout',
				@parameter_value = '0'
		if (@retcode = 1 or @@ERROR <> 0)
			goto FAILURE

		exec @retcode = dbo.sp_add_agent_parameter 
				@profile_id = @real_profile_id,
				@parameter_name = '-MaxDownloadChanges',
				@parameter_value = '0'
		if (@retcode = 1 or @@ERROR <> 0)
			goto FAILURE

		exec @retcode = dbo.sp_add_agent_parameter 
				@profile_id = @real_profile_id,
				@parameter_name = '-MaxUploadChanges',
				@parameter_value = '0'
		if (@retcode = 1 or @@ERROR <> 0)
			goto FAILURE
			
		exec @retcode = dbo.sp_add_agent_parameter 
				@profile_id = @real_profile_id,
				@parameter_name = '-ValidateInterval',
				@parameter_value = '60'
		if (@retcode = 1 or @@ERROR <> 0)
			goto FAILURE

		exec @retcode = dbo.sp_add_agent_parameter 
				@profile_id = @real_profile_id,
				@parameter_name = '-LoginTimeout',
				@parameter_value = '15'
		if (@retcode = 1 or @@ERROR <> 0)
			goto FAILURE

		exec @retcode = dbo.sp_add_agent_parameter 
				@profile_id = @real_profile_id,
				@parameter_name = '-QueryTimeout',
				@parameter_value = '300'
		if (@retcode = 1 or @@ERROR <> 0)
			goto FAILURE

		exec @retcode = dbo.sp_add_agent_parameter 
				@profile_id = @real_profile_id,
				@parameter_name = '-UploadGenerationsPerBatch',
				@parameter_value = '100'
		if (@retcode = 1 or @@ERROR <> 0)
			goto FAILURE

		exec @retcode = dbo.sp_add_agent_parameter 
				@profile_id = @real_profile_id,
				@parameter_name = '-DownloadGenerationsPerBatch',
				@parameter_value = '100'
		if (@retcode = 1 or @@ERROR <> 0)
			goto FAILURE

		exec @retcode = dbo.sp_add_agent_parameter 
				@profile_id = @real_profile_id,
				@parameter_name = '-UploadReadChangesPerBatch',
				@parameter_value = '100'
		if (@retcode = 1 or @@ERROR <> 0)
			goto FAILURE

		exec @retcode = dbo.sp_add_agent_parameter 
				@profile_id = @real_profile_id,
				@parameter_name = '-DownloadReadChangesPerBatch',
				@parameter_value = '100'
		if (@retcode = 1 or @@ERROR <> 0)
			goto FAILURE

		exec @retcode = dbo.sp_add_agent_parameter 
				@profile_id = @real_profile_id,
				@parameter_name = '-UploadWriteChangesPerBatch',
				@parameter_value = '100'
		if (@retcode = 1 or @@ERROR <> 0)
			goto FAILURE

		exec @retcode = dbo.sp_add_agent_parameter 
				@profile_id = @real_profile_id,
				@parameter_name = '-DownloadWriteChangesPerBatch',
				@parameter_value = '100'
		if (@retcode = 1 or @@ERROR <> 0)
			goto FAILURE

		exec @retcode = dbo.sp_add_agent_parameter 
				@profile_id = @real_profile_id,
				@parameter_name = '-Validate',
				@parameter_value = '0'
		if (@retcode = 1 or @@ERROR <> 0)
			goto FAILURE
        
		exec @retcode = dbo.sp_add_agent_parameter 
				@profile_id = @real_profile_id,
				@parameter_name = '-FastRowCount',
				@parameter_value = '1'
		if (@retcode = 1 or @@ERROR <> 0)
			goto FAILURE

		exec @retcode = dbo.sp_add_agent_parameter 
				@profile_id = @real_profile_id,
				@parameter_name = '-HistoryVerboseLevel',
				@parameter_value = '1'
		if (@retcode = 1 or @@ERROR <> 0)
			goto FAILURE

		exec @retcode = dbo.sp_add_agent_parameter 
				@profile_id = @real_profile_id,
				@parameter_name = '-ChangesPerHistory',
				@parameter_value = '50'
		if (@retcode = 1 or @@ERROR <> 0)
			goto FAILURE

		exec @retcode = dbo.sp_add_agent_parameter 
			    @profile_id = @real_profile_id,
				@parameter_name = '-BcpBatchSize',
				@parameter_value = '1000'
		if (@retcode = 1 or @@ERROR <> 0)
			goto FAILURE

		exec @retcode = dbo.sp_add_agent_parameter 
			    @profile_id = @real_profile_id,
				@parameter_name = '-NumDeadlockRetries',
				@parameter_value = '5'
		if (@retcode = 1 or @@ERROR <> 0)
			goto FAILURE

		exec @retcode = dbo.sp_add_agent_parameter 
			    @profile_id = @real_profile_id,
				@parameter_name = '-SrcThreads',
				@parameter_value = '3'
		if (@retcode = 1 or @@ERROR <> 0)
			goto FAILURE

		exec @retcode = dbo.sp_add_agent_parameter 
			    @profile_id = @real_profile_id,
				@parameter_name = '-DestThreads',
				@parameter_value = '4'
		if (@retcode = 1 or @@ERROR <> 0)
			goto FAILURE

        exec @retcode = dbo.sp_add_agent_parameter
                @profile_id = @real_profile_id,
                @parameter_name = '-KeepAliveMessageInterval',
                @parameter_value = '300'
        if (@retcode = 1 or @@ERROR <> 0)
            goto FAILURE

        exec @retcode = dbo.sp_add_agent_parameter
                @profile_id = @real_profile_id,
                @parameter_name = '-MetadataRetentionCleanup',
                @parameter_value = '1'
        if (@retcode = 1 or @@ERROR <> 0)
            goto FAILURE

        end

    /* 
	** Distribution agent (Synchronization Manager Profile)
	*/
	else if (@profile_id = 10)
        begin
		exec @retcode = dbo.sp_add_agent_parameter 
				@profile_id = @real_profile_id,
				@parameter_name = '-BcpBatchSize',
				@parameter_value = '1000'
		if (@retcode = 1 or @@ERROR <> 0)
			goto FAILURE

		exec @retcode = dbo.sp_add_agent_parameter 
				@profile_id = @real_profile_id,
				@parameter_name = '-CommitBatchSize',
				@parameter_value = '100'
		if (@retcode = 1 or @@ERROR <> 0)
			goto FAILURE

		exec @retcode = dbo.sp_add_agent_parameter 
				@profile_id = @real_profile_id,
				@parameter_name = '-CommitBatchThreshold',
				@parameter_value = '1000'
		if (@retcode = 1 or @@ERROR <> 0)
			goto FAILURE

		exec @retcode = dbo.sp_add_agent_parameter 
				@profile_id = @real_profile_id,
				@parameter_name = '-HistoryVerboseLevel',
				@parameter_value = '1'
		if (@retcode = 1 or @@ERROR <> 0)
			goto FAILURE

		exec @retcode = dbo.sp_add_agent_parameter 
				@profile_id = @real_profile_id,
				@parameter_name = '-LoginTimeout',
				@parameter_value = '15'
		if (@retcode = 1 or @@ERROR <> 0)
			goto FAILURE

		exec @retcode = dbo.sp_add_agent_parameter 
				@profile_id = @real_profile_id,
				@parameter_name = '-MaxBcpThreads',
				@parameter_value = '1'
		if (@retcode = 1 or @@ERROR <> 0)
			goto FAILURE

		exec @retcode = dbo.sp_add_agent_parameter 
				@profile_id = @real_profile_id,
				@parameter_name = '-MaxDeliveredTransactions',
				@parameter_value = '0'
		if (@retcode = 1 or @@ERROR <> 0)
			goto FAILURE

		exec @retcode = dbo.sp_add_agent_parameter 
				@profile_id = @real_profile_id,
				@parameter_name = '-PollingInterval',
				@parameter_value = '10'
		if (@retcode = 1 or @@ERROR <> 0)
			goto FAILURE

		exec @retcode = dbo.sp_add_agent_parameter 
				@profile_id = @real_profile_id,
				@parameter_name = '-QueryTimeout',
				@parameter_value = '300'        -- 5 minutes 
		if (@retcode = 1 or @@ERROR <> 0)
			goto FAILURE

		exec @retcode = dbo.sp_add_agent_parameter 
				@profile_id = @real_profile_id,
				@parameter_name = '-TransactionsPerHistory',
				@parameter_value = '100'
		if (@retcode = 1 or @@ERROR <> 0)
			goto FAILURE

		exec @retcode = dbo.sp_add_agent_parameter 
				@profile_id = @real_profile_id,
				@parameter_name = '-SkipErrors',
				@parameter_value = ''
		if (@retcode = 1 or @@ERROR <> 0)
			goto FAILURE

        exec @retcode = dbo.sp_add_agent_parameter
                @profile_id = @real_profile_id,
                @parameter_name = '-KeepAliveMessageInterval',
                @parameter_value = '300'
        if (@retcode = 1 or @@ERROR <> 0)
            goto FAILURE

        end
	
    /* 
	** Queue Reader agent default profile
	*/
	else if (@profile_id = 11)
    begin
		exec @retcode = dbo.sp_add_agent_parameter 
				@profile_id = @real_profile_id,
				@parameter_name = '-HistoryVerboseLevel',
				@parameter_value = '1'
		if (@retcode = 1 or @@ERROR <> 0)
			goto FAILURE

		exec @retcode = dbo.sp_add_agent_parameter 
				@profile_id = @real_profile_id,
				@parameter_name = '-PollingInterval',
				@parameter_value = '10'
		if (@retcode = 1 or @@ERROR <> 0)
			goto FAILURE

		exec @retcode = dbo.sp_add_agent_parameter 
				@profile_id = @real_profile_id,
				@parameter_name = '-LoginTimeout',
				@parameter_value = '15'
		if (@retcode = 1 or @@ERROR <> 0)
			goto FAILURE

		exec @retcode = dbo.sp_add_agent_parameter 
				@profile_id = @real_profile_id,
				@parameter_name = '-QueryTimeout',
				@parameter_value = '300'        -- 5 minutes 
		if (@retcode = 1 or @@ERROR <> 0)
			goto FAILURE
	end
	  
    /* 
	** Merge agent : Rowcount Validation profile for well connected scenarios 
	*/
	else if (@profile_id = 12)
        begin
		exec @retcode = dbo.sp_add_agent_parameter 
				@profile_id = @real_profile_id,
				@parameter_name = '-PollingInterval',
				@parameter_value = '60'
		if (@retcode = 1 or @@ERROR <> 0)
			goto FAILURE


		exec @retcode = dbo.sp_add_agent_parameter 
				@profile_id = @real_profile_id,
				@parameter_name = '-StartQueueTimeout',
				@parameter_value = '0'
		if (@retcode = 1 or @@ERROR <> 0)
			goto FAILURE

		exec @retcode = dbo.sp_add_agent_parameter 
				@profile_id = @real_profile_id,
				@parameter_name = '-MaxDownloadChanges',
				@parameter_value = '0'
		if (@retcode = 1 or @@ERROR <> 0)
			goto FAILURE

		exec @retcode = dbo.sp_add_agent_parameter 
				@profile_id = @real_profile_id,
				@parameter_name = '-MaxUploadChanges',
				@parameter_value = '0'
		if (@retcode = 1 or @@ERROR <> 0)
			goto FAILURE

		exec @retcode = dbo.sp_add_agent_parameter 
				@profile_id = @real_profile_id,
				@parameter_name = '-ValidateInterval',
				@parameter_value = '60'
		if (@retcode = 1 or @@ERROR <> 0)
			goto FAILURE

		exec @retcode = dbo.sp_add_agent_parameter 
				@profile_id = @real_profile_id,
				@parameter_name = '-LoginTimeout',
				@parameter_value = '15'
		if (@retcode = 1 or @@ERROR <> 0)
			goto FAILURE

		exec @retcode = dbo.sp_add_agent_parameter 
				@profile_id = @real_profile_id,
				@parameter_name = '-QueryTimeout',
				@parameter_value = '300'        
		if (@retcode = 1 or @@ERROR <> 0)
			goto FAILURE

		exec @retcode = dbo.sp_add_agent_parameter 
				@profile_id = @real_profile_id,
				@parameter_name = '-UploadGenerationsPerBatch',
				@parameter_value = '100'
		if (@retcode = 1 or @@ERROR <> 0)
			goto FAILURE

		exec @retcode = dbo.sp_add_agent_parameter 
				@profile_id = @real_profile_id,
				@parameter_name = '-DownloadGenerationsPerBatch',
				@parameter_value = '100'
		if (@retcode = 1 or @@ERROR <> 0)
			goto FAILURE

		exec @retcode = dbo.sp_add_agent_parameter 
				@profile_id = @real_profile_id,
				@parameter_name = '-UploadReadChangesPerBatch',
				@parameter_value = '100'
		if (@retcode = 1 or @@ERROR <> 0)
			goto FAILURE

		exec @retcode = dbo.sp_add_agent_parameter 
				@profile_id = @real_profile_id,
				@parameter_name = '-DownloadReadChangesPerBatch',
				@parameter_value = '100'
		if (@retcode = 1 or @@ERROR <> 0)
			goto FAILURE

		exec @retcode = dbo.sp_add_agent_parameter 
				@profile_id = @real_profile_id,
				@parameter_name = '-UploadWriteChangesPerBatch',
				@parameter_value = '100'
		if (@retcode = 1 or @@ERROR <> 0)
			goto FAILURE

		exec @retcode = dbo.sp_add_agent_parameter 
				@profile_id = @real_profile_id,
				@parameter_name = '-DownloadWriteChangesPerBatch',
				@parameter_value = '100'
		if (@retcode = 1 or @@ERROR <> 0)
			goto FAILURE

		exec @retcode = dbo.sp_add_agent_parameter 
				@profile_id = @real_profile_id,
				@parameter_name = '-Validate',
				@parameter_value = '1'
		if (@retcode = 1 or @@ERROR <> 0)
			goto FAILURE

		exec @retcode = dbo.sp_add_agent_parameter 
				@profile_id = @real_profile_id,
				@parameter_name = '-FastRowCount',
				@parameter_value = '1'
		if (@retcode = 1 or @@ERROR <> 0)
			goto FAILURE
        
		exec @retcode = dbo.sp_add_agent_parameter 
				@profile_id = @real_profile_id,
				@parameter_name = '-HistoryVerboseLevel',
				@parameter_value = '1'
		if (@retcode = 1 or @@ERROR <> 0)
			goto FAILURE

		exec @retcode = dbo.sp_add_agent_parameter 
				@profile_id = @real_profile_id,
				@parameter_name = '-ChangesPerHistory',
				@parameter_value = '100'
		if (@retcode = 1 or @@ERROR <> 0)
			goto FAILURE
		exec @retcode = dbo.sp_add_agent_parameter 
			    @profile_id = @real_profile_id,
				@parameter_name = '-BcpBatchSize',
				@parameter_value = '100000'
		if (@retcode = 1 or @@ERROR <> 0)
			goto FAILURE

		exec @retcode = dbo.sp_add_agent_parameter 
			    @profile_id = @real_profile_id,
				@parameter_name = '-NumDeadlockRetries',
				@parameter_value = '5'
		if (@retcode = 1 or @@ERROR <> 0)
			goto FAILURE

		exec @retcode = dbo.sp_add_agent_parameter 
			    @profile_id = @real_profile_id,
				@parameter_name = '-SrcThreads',
				@parameter_value = '3'
		if (@retcode = 1 or @@ERROR <> 0)
			goto FAILURE

		exec @retcode = dbo.sp_add_agent_parameter 
			    @profile_id = @real_profile_id,
				@parameter_name = '-DestThreads',
				@parameter_value = '4'
		if (@retcode = 1 or @@ERROR <> 0)
			goto FAILURE
			
        exec @retcode = dbo.sp_add_agent_parameter
                @profile_id = @real_profile_id,
                @parameter_name = '-KeepAliveMessageInterval',
                @parameter_value = '300'
        if (@retcode = 1 or @@ERROR <> 0)
            goto FAILURE

        exec @retcode = dbo.sp_add_agent_parameter
                @profile_id = @real_profile_id,
                @parameter_name = '-MetadataRetentionCleanup',
                @parameter_value = '1'
        if (@retcode = 1 or @@ERROR <> 0)
            goto FAILURE

        end

    /* 
    ** Merge agent : Rowcount & Checksum Validation profile for well connected scenarios 
    */
	else if (@profile_id = 13)
        begin
		exec @retcode = dbo.sp_add_agent_parameter 
				@profile_id = @real_profile_id,
				@parameter_name = '-PollingInterval',
				@parameter_value = '60'
		if (@retcode = 1 or @@ERROR <> 0)
			goto FAILURE

		exec @retcode = dbo.sp_add_agent_parameter 
				@profile_id = @real_profile_id,
				@parameter_name = '-StartQueueTimeout',
				@parameter_value = '0'
		if (@retcode = 1 or @@ERROR <> 0)
			goto FAILURE

		exec @retcode = dbo.sp_add_agent_parameter 
				@profile_id = @real_profile_id,
				@parameter_name = '-MaxDownloadChanges',
				@parameter_value = '0'
		if (@retcode = 1 or @@ERROR <> 0)
			goto FAILURE

		exec @retcode = dbo.sp_add_agent_parameter 
				@profile_id = @real_profile_id,
				@parameter_name = '-MaxUploadChanges',
				@parameter_value = '0'
		if (@retcode = 1 or @@ERROR <> 0)
			goto FAILURE

		exec @retcode = dbo.sp_add_agent_parameter 
				@profile_id = @real_profile_id,
				@parameter_name = '-ValidateInterval',
				@parameter_value = '60'
		if (@retcode = 1 or @@ERROR <> 0)
			goto FAILURE

		exec @retcode = dbo.sp_add_agent_parameter 
				@profile_id = @real_profile_id,
				@parameter_name = '-LoginTimeout',
				@parameter_value = '15'
		if (@retcode = 1 or @@ERROR <> 0)
			goto FAILURE

		exec @retcode = dbo.sp_add_agent_parameter 
				@profile_id = @real_profile_id,
				@parameter_name = '-QueryTimeout',
				@parameter_value = '300'        
		if (@retcode = 1 or @@ERROR <> 0)
			goto FAILURE

		exec @retcode = dbo.sp_add_agent_parameter 
				@profile_id = @real_profile_id,
				@parameter_name = '-UploadGenerationsPerBatch',
				@parameter_value = '100'
		if (@retcode = 1 or @@ERROR <> 0)
			goto FAILURE

		exec @retcode = dbo.sp_add_agent_parameter 
				@profile_id = @real_profile_id,
				@parameter_name = '-DownloadGenerationsPerBatch',
				@parameter_value = '100'
		if (@retcode = 1 or @@ERROR <> 0)
			goto FAILURE

		exec @retcode = dbo.sp_add_agent_parameter 
				@profile_id = @real_profile_id,
				@parameter_name = '-UploadReadChangesPerBatch',
				@parameter_value = '100'
		if (@retcode = 1 or @@ERROR <> 0)
			goto FAILURE

		exec @retcode = dbo.sp_add_agent_parameter 
				@profile_id = @real_profile_id,
				@parameter_name = '-DownloadReadChangesPerBatch',
				@parameter_value = '100'
		if (@retcode = 1 or @@ERROR <> 0)
			goto FAILURE

		exec @retcode = dbo.sp_add_agent_parameter 
				@profile_id = @real_profile_id,
				@parameter_name = '-UploadWriteChangesPerBatch',
				@parameter_value = '100'
		if (@retcode = 1 or @@ERROR <> 0)
			goto FAILURE

		exec @retcode = dbo.sp_add_agent_parameter 
				@profile_id = @real_profile_id,
				@parameter_name = '-DownloadWriteChangesPerBatch',
				@parameter_value = '100'
		if (@retcode = 1 or @@ERROR <> 0)
			goto FAILURE

		exec @retcode = dbo.sp_add_agent_parameter 
				@profile_id = @real_profile_id,
				@parameter_name = '-Validate',
				@parameter_value = '3'
		if (@retcode = 1 or @@ERROR <> 0)
			goto FAILURE

		exec @retcode = dbo.sp_add_agent_parameter 
				@profile_id = @real_profile_id,
				@parameter_name = '-FastRowCount',
				@parameter_value = '1'
		if (@retcode = 1 or @@ERROR <> 0)
			goto FAILURE
        
		exec @retcode = dbo.sp_add_agent_parameter 
				@profile_id = @real_profile_id,
				@parameter_name = '-HistoryVerboseLevel',
				@parameter_value = '1'
		if (@retcode = 1 or @@ERROR <> 0)
			goto FAILURE

		exec @retcode = dbo.sp_add_agent_parameter 
				@profile_id = @real_profile_id,
				@parameter_name = '-ChangesPerHistory',
				@parameter_value = '100'
		if (@retcode = 1 or @@ERROR <> 0)
			goto FAILURE
		exec @retcode = dbo.sp_add_agent_parameter 
			    @profile_id = @real_profile_id,
				@parameter_name = '-BcpBatchSize',
				@parameter_value = '100000'
		if (@retcode = 1 or @@ERROR <> 0)
			goto FAILURE

		exec @retcode = dbo.sp_add_agent_parameter 
			    @profile_id = @real_profile_id,
				@parameter_name = '-NumDeadlockRetries',
				@parameter_value = '5'
		if (@retcode = 1 or @@ERROR <> 0)
			goto FAILURE
			
		exec @retcode = dbo.sp_add_agent_parameter 
			    @profile_id = @real_profile_id,
				@parameter_name = '-SrcThreads',
				@parameter_value = '3'
		if (@retcode = 1 or @@ERROR <> 0)
			goto FAILURE

		exec @retcode = dbo.sp_add_agent_parameter 
			    @profile_id = @real_profile_id,
				@parameter_name = '-DestThreads',
				@parameter_value = '4'
		if (@retcode = 1 or @@ERROR <> 0)
			goto FAILURE

        exec @retcode = dbo.sp_add_agent_parameter
                @profile_id = @real_profile_id,
                @parameter_name = '-KeepAliveMessageInterval',
                @parameter_value = '300'
        if (@retcode = 1 or @@ERROR <> 0)
            goto FAILURE

        exec @retcode = dbo.sp_add_agent_parameter
                @profile_id = @real_profile_id,
                @parameter_name = '-MetadataRetentionCleanup',
                @parameter_value = '1'
        if (@retcode = 1 or @@ERROR <> 0)
            goto FAILURE

        end

    /* 
    ** Distribution agent, skip error profile
    */
	else if (@profile_id = 14)
	  begin

		exec @retcode = dbo.sp_add_agent_parameter 
				@profile_id = @real_profile_id,
				@parameter_name = '-BcpBatchSize',
				@parameter_value = '100000'
		if (@retcode = 1 or @@ERROR <> 0)
			goto FAILURE

		exec @retcode = dbo.sp_add_agent_parameter 
				@profile_id = @real_profile_id,
				@parameter_name = '-CommitBatchSize',
				@parameter_value = '100'
		if (@retcode = 1 or @@ERROR <> 0)
			goto FAILURE

		exec @retcode = dbo.sp_add_agent_parameter 
				@profile_id = @real_profile_id,
				@parameter_name = '-CommitBatchThreshold',
				@parameter_value = '1000'
		if (@retcode = 1 or @@ERROR <> 0)
			goto FAILURE

		exec @retcode = dbo.sp_add_agent_parameter 
				@profile_id = @real_profile_id,
				@parameter_name = '-HistoryVerboseLevel',
				@parameter_value = '1'
		if (@retcode = 1 or @@ERROR <> 0)
			goto FAILURE

		exec @retcode = dbo.sp_add_agent_parameter 
				@profile_id = @real_profile_id,
				@parameter_name = '-LoginTimeout',
				@parameter_value = '15'
		if (@retcode = 1 or @@ERROR <> 0)
			goto FAILURE

		exec @retcode = dbo.sp_add_agent_parameter 
				@profile_id = @real_profile_id,
				@parameter_name = '-MaxBcpThreads',
				@parameter_value = '1'
		if (@retcode = 1 or @@ERROR <> 0)
			goto FAILURE

		exec @retcode = dbo.sp_add_agent_parameter 
				@profile_id = @real_profile_id,
				@parameter_name = '-MaxDeliveredTransactions',
				@parameter_value = '0'
		if (@retcode = 1 or @@ERROR <> 0)
			goto FAILURE

		exec @retcode = dbo.sp_add_agent_parameter 
				@profile_id = @real_profile_id,
				@parameter_name = '-PollingInterval',
				@parameter_value = '10'
		if (@retcode = 1 or @@ERROR <> 0)
			goto FAILURE

		exec @retcode = dbo.sp_add_agent_parameter 
				@profile_id = @real_profile_id,
				@parameter_name = '-QueryTimeout',
				@parameter_value = '300'        -- 5 minutes 
		if (@retcode = 1 or @@ERROR <> 0)
			goto FAILURE

		exec @retcode = dbo.sp_add_agent_parameter 
				@profile_id = @real_profile_id,
				@parameter_name = '-TransactionsPerHistory',
				@parameter_value = '100'
		if (@retcode = 1 or @@ERROR <> 0)
			goto FAILURE

		exec @retcode = dbo.sp_add_agent_parameter 
				@profile_id = @real_profile_id,
				@parameter_name = '-SkipErrors',
				@parameter_value = '2601:2627:20598'
		if (@retcode = 1 or @@ERROR <> 0)
			goto FAILURE

        exec @retcode = dbo.sp_add_agent_parameter
                @profile_id = @real_profile_id,
                @parameter_name = '-KeepAliveMessageInterval',
                @parameter_value = '300'
        if (@retcode = 1 or @@ERROR <> 0)
            goto FAILURE

        end

    /* 
    ** Merge agent : Rowcount Validation profile for high volumn server-to-server
    */
        else if (@profile_id = 15)
        begin
		exec @retcode = dbo.sp_add_agent_parameter 
				@profile_id = @real_profile_id,
				@parameter_name = '-PollingInterval',
				@parameter_value = '60'
		if (@retcode = 1 or @@ERROR <> 0)
			goto FAILURE

		exec @retcode = dbo.sp_add_agent_parameter 
				@profile_id = @real_profile_id,
				@parameter_name = '-StartQueueTimeout',
				@parameter_value = '0'
		if (@retcode = 1 or @@ERROR <> 0)
			goto FAILURE

		exec @retcode = dbo.sp_add_agent_parameter 
				@profile_id = @real_profile_id,
				@parameter_name = '-MaxDownloadChanges',
				@parameter_value = '0'
		if (@retcode = 1 or @@ERROR <> 0)
			goto FAILURE

		exec @retcode = dbo.sp_add_agent_parameter 
				@profile_id = @real_profile_id,
				@parameter_name = '-MaxUploadChanges',
				@parameter_value = '0'
		if (@retcode = 1 or @@ERROR <> 0)
			goto FAILURE

		exec @retcode = dbo.sp_add_agent_parameter 
				@profile_id = @real_profile_id,
				@parameter_name = '-ValidateInterval',
				@parameter_value = '60'
		if (@retcode = 1 or @@ERROR <> 0)
			goto FAILURE

		exec @retcode = dbo.sp_add_agent_parameter 
				@profile_id = @real_profile_id,
				@parameter_name = '-LoginTimeout',
				@parameter_value = '15'
		if (@retcode = 1 or @@ERROR <> 0)
			goto FAILURE

		exec @retcode = dbo.sp_add_agent_parameter 
				@profile_id = @real_profile_id,
				@parameter_name = '-QueryTimeout',
				@parameter_value = '600'        
		if (@retcode = 1 or @@ERROR <> 0)
			goto FAILURE

		exec @retcode = dbo.sp_add_agent_parameter 
				@profile_id = @real_profile_id,
				@parameter_name = '-UploadGenerationsPerBatch',
				@parameter_value = '2000'
		if (@retcode = 1 or @@ERROR <> 0)
			goto FAILURE

		exec @retcode = dbo.sp_add_agent_parameter 
				@profile_id = @real_profile_id,
				@parameter_name = '-DownloadGenerationsPerBatch',
				@parameter_value = '2000'
		if (@retcode = 1 or @@ERROR <> 0)
			goto FAILURE

		exec @retcode = dbo.sp_add_agent_parameter 
				@profile_id = @real_profile_id,
				@parameter_name = '-UploadReadChangesPerBatch',
				@parameter_value = '100'
		if (@retcode = 1 or @@ERROR <> 0)
			goto FAILURE

		exec @retcode = dbo.sp_add_agent_parameter 
				@profile_id = @real_profile_id,
				@parameter_name = '-DownloadReadChangesPerBatch',
				@parameter_value = '100'
		if (@retcode = 1 or @@ERROR <> 0)
			goto FAILURE

		exec @retcode = dbo.sp_add_agent_parameter 
				@profile_id = @real_profile_id,
				@parameter_name = '-UploadWriteChangesPerBatch',
				@parameter_value = '100'
		if (@retcode = 1 or @@ERROR <> 0)
			goto FAILURE

		exec @retcode = dbo.sp_add_agent_parameter 
				@profile_id = @real_profile_id,
				@parameter_name = '-DownloadWriteChangesPerBatch',
				@parameter_value = '100'
		if (@retcode = 1 or @@ERROR <> 0)
			goto FAILURE

		exec @retcode = dbo.sp_add_agent_parameter 
				@profile_id = @real_profile_id,
				@parameter_name = '-Validate',
				@parameter_value = '0'
		if (@retcode = 1 or @@ERROR <> 0)
			goto FAILURE

		exec @retcode = dbo.sp_add_agent_parameter 
				@profile_id = @real_profile_id,
				@parameter_name = '-FastRowCount',
				@parameter_value = '1'
		if (@retcode = 1 or @@ERROR <> 0)
			goto FAILURE
        
		exec @retcode = dbo.sp_add_agent_parameter 
				@profile_id = @real_profile_id,
				@parameter_name = '-HistoryVerboseLevel',
				@parameter_value = '1'
		if (@retcode = 1 or @@ERROR <> 0)
			goto FAILURE

		exec @retcode = dbo.sp_add_agent_parameter 
				@profile_id = @real_profile_id,
				@parameter_name = '-ChangesPerHistory',
				@parameter_value = '100'
		if (@retcode = 1 or @@ERROR <> 0)
			goto FAILURE

		exec @retcode = dbo.sp_add_agent_parameter 
			    @profile_id = @real_profile_id,
				@parameter_name = '-BcpBatchSize',
				@parameter_value = '100000'
		if (@retcode = 1 or @@ERROR <> 0)
			goto FAILURE

		exec @retcode = dbo.sp_add_agent_parameter 
			    @profile_id = @real_profile_id,
				@parameter_name = '-NumDeadlockRetries',
				@parameter_value = '5'
		if (@retcode = 1 or @@ERROR <> 0)
			goto FAILURE

		exec @retcode = dbo.sp_add_agent_parameter 
			    @profile_id = @real_profile_id,
				@parameter_name = '-SrcThreads',
				@parameter_value = '3'
		if (@retcode = 1 or @@ERROR <> 0)
			goto FAILURE

		exec @retcode = dbo.sp_add_agent_parameter 
			    @profile_id = @real_profile_id,
				@parameter_name = '-DestThreads',
				@parameter_value = '4'
		if (@retcode = 1 or @@ERROR <> 0)
			goto FAILURE

        exec @retcode = dbo.sp_add_agent_parameter
                @profile_id = @real_profile_id,
                @parameter_name = '-KeepAliveMessageInterval',
                @parameter_value = '300'
        if (@retcode = 1 or @@ERROR <> 0)
            goto FAILURE

        exec @retcode = dbo.sp_add_agent_parameter
                @profile_id = @real_profile_id,
                @parameter_name = '-MetadataRetentionCleanup',
                @parameter_value = '1'
        if (@retcode = 1 or @@ERROR <> 0)
            goto FAILURE

        end

    return 0
FAILURE:
    return 1
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
            N'maxnetworkoptimization',
            N'useperarticlecontentsview'
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
    else if (@parameter_name = N'useperarticlecontentsview')
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


raiserror('Creating procedure sp_add_agent_parameter', 0,1)
go

-- Add a row into the "MSagent_parameters" table
create procedure sp_add_agent_parameter (
    @profile_id int,
    @parameter_name         sysname,
    @parameter_value        nvarchar(255)
)
as
    declare @slash_parameter_name sysname
    declare @dash_parameter_name sysname
    declare @retcode int
    
    set nocount on

    select @parameter_name = RTRIM(@parameter_name)

	-- Append leading '-' when not given
    if (substring(@parameter_name, 1, 1) <> '/' and 
        substring(@parameter_name, 1, 1) <> '-')
    BEGIN
		select @parameter_name = N'-' + @parameter_name
	END

    -- Call proc to validate parameter value
    exec @retcode = dbo.sp_MSvalidate_agent_parameter 
                        @profile_id = @profile_id, 
                        @parameter_name = @parameter_name,
                        @parameter_value = @parameter_value
    if @retcode <> 0
        RETURN(1)


    select @slash_parameter_name = lower(stuff(@parameter_name, 1, 1, N'/') collate SQL_Latin1_General_CP1_CS_AS)
    select @dash_parameter_name = lower(stuff(@parameter_name, 1, 1, N'-') collate SQL_Latin1_General_CP1_CS_AS)
     

    /* A parameter may be defined only once per profile */
    if exists ( select * from msdb..MSagent_parameters 
            where profile_id = @profile_id
            and (lower(parameter_name collate SQL_Latin1_General_CP1_CS_AS) = @slash_parameter_name collate SQL_Latin1_General_CP1_CS_AS  
            or lower(parameter_name collate SQL_Latin1_General_CP1_CS_AS) = @dash_parameter_name collate SQL_Latin1_General_CP1_CS_AS))
    BEGIN
        RAISERROR (20067, 16, -1, @parameter_name)  -- The parameter name ''%s'' already exists for the specified profile
        RETURN (1)
    END

    insert into msdb..MSagent_parameters
    values (@profile_id, @parameter_name, @parameter_value) ;

    if @@error <> 0
        return(1)
GO

raiserror('Creating procedure sp_change_agent_parameter', 0,1)
go
-- Change one parameter of a profile from the MSagent_parameters table
create procedure sp_change_agent_parameter(
    @profile_id int,
    @parameter_name         sysname,
    @parameter_value        nvarchar(255)
)AS
    declare @slash_parameter_name sysname
    declare @dash_parameter_name sysname
    declare @retcode int

    select @parameter_name = LTRIM(RTRIM(@parameter_name))
    select @parameter_value = LTRIM(RTRIM(@parameter_value))

    -- DMO sends in empty sting as '(null)'.
	if @parameter_value = N'(null)'
		select @parameter_value = N''

	-- Append leading '-' when not given
    if (substring(@parameter_name, 1, 1) <> '/' and 
        substring(@parameter_name, 1, 1) <> '-')
    BEGIN
		select @parameter_name = N'-' + @parameter_name
	END

	-- Call proc to validate parameter value
    exec @retcode = dbo.sp_MSvalidate_agent_parameter 
                        @profile_id = @profile_id, 
                        @parameter_name = @parameter_name,
                        @parameter_value = @parameter_value
    if @retcode <> 0
        RETURN(1)


    select @slash_parameter_name = lower(stuff(@parameter_name, 1, 1, N'/') collate SQL_Latin1_General_CP1_CS_AS)
    select @dash_parameter_name = lower(stuff(@parameter_name, 1, 1, N'-') collate SQL_Latin1_General_CP1_CS_AS)
   
    IF exists ( select * from msdb..MSagent_parameters 
            where profile_id = @profile_id and 
                (lower(parameter_name collate SQL_Latin1_General_CP1_CS_AS) = @slash_parameter_name collate SQL_Latin1_General_CP1_CS_AS or
                 lower(parameter_name collate SQL_Latin1_General_CP1_CS_AS) = @dash_parameter_name collate SQL_Latin1_General_CP1_CS_AS))
    BEGIN
        update msdb..MSagent_parameters set value = @parameter_value where 
            profile_id = @profile_id and 
            (lower(parameter_name collate SQL_Latin1_General_CP1_CS_AS) = @slash_parameter_name collate SQL_Latin1_General_CP1_CS_AS or
            lower(parameter_name collate SQL_Latin1_General_CP1_CS_AS) = @dash_parameter_name collate SQL_Latin1_General_CP1_CS_AS) 

        if @@error <> 0
            return(1)
    END
GO

raiserror('Creating procedure sp_change_agent_profile', 0,1)
go
-- Change one parameter of a profile from the MSagent_profiles table
create procedure sp_change_agent_profile(
    @profile_id         int,
    @property           sysname,
    @value              nvarchar(3000)
)AS

    IF lower(@property collate SQL_Latin1_General_CP1_CS_AS) not in ('description')
    BEGIN
        RAISERROR(21183, 16, -1, @property)
        RETURN (1)
    END

    IF exists ( select * from msdb..MSagent_profiles where profile_id = @profile_id)
    BEGIN
        update msdb..MSagent_profiles set description = @value where profile_id = @profile_id
        if @@error <> 0
            return(1)
    END
GO


raiserror('Creating procedure sp_help_agent_parameter', 0,1)
go
-- View all the parameters of a profile from the MSagent_parameters table
create procedure sp_help_agent_parameter(
    @profile_id     int = -1
)
as
    set nocount on
    
    if @profile_id = -1
    begin   
        select profile_id, parameter_name, value
        from msdb..MSagent_parameters
        order by profile_id, parameter_name
    end
    else
    begin
        select profile_id, parameter_name, value
        from msdb..MSagent_parameters
        where profile_id = @profile_id
        order by profile_id, parameter_name
    end
GO

raiserror('Creating procedure sp_MShelp_distdb', 0,1)
go

-- Called by the distribution agent to find the dist. db of a dist. publisher
create procedure sp_MShelp_distdb (     
    @publisher_name     sysname
)
as
if exists (select name from msdb..sysobjects where name = 'MSdistpublishers')
begin
    select distribution_db from msdb..MSdistpublishers
    where UPPER(name) = UPPER(@publisher_name) collate database_default
end
else 
    select NULL where 1=2   /* We still want an empty rowset for some agents */
GO

dump tran master with no_log
GO

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

raiserror('Creating procedure sp_MSenum_misc_agents', 0,1)
go
create procedure sp_MSenum_misc_agents
as
    SET NOCOUNT ON

    declare @timestamp timestamp

    -- Not supported, but returned to be consistent with other sp_MSenum_replication_agent
    -- result set.
    set @timestamp = 0

    select j.name, 'agent_type' = c.name,
            'status' = case isnull(jh.run_status, 5) -- mapped to never run
                when 0 then 5   -- Fail mapping
                when 1 then 2   -- Success mapping
                when 2 then 5   -- Retry mapping
                when 3 then 2   -- Shutdown mapping
                when 4 then 3   -- Inprogress mapping
                when 5 then 0   -- Unknown is mapped to never run
            end,
            jh.message, 'start_time' = convert(nvarchar(8), jh.run_date) + N' ' +
                                       stuff(stuff(right(convert(nvarchar(7), jh.run_time + 1000000), 6), 5, 0, N':'), 3, 0, N':') + 
                                       + N'.000',
            jh.run_duration, 
            'job_id' = convert(binary(16), j.job_id), 'local_timestamp' = @timestamp from 
                msdb..sysjobs j
            LEFT OUTER JOIN msdb..sysjobhistory jh ON
            j.job_id = jh.job_id and 
            jh.instance_id = (select max(instance_id) from msdb..sysjobhistory jh2 where
                jh2.job_id = j.job_id)
            INNER JOIN msdb..syscategories c ON
            j.category_id = c.category_id
            where j.category_id in (11, 12,16,17,18)

    order by j.job_id asc
go 

raiserror('Creating procedure sp_MSload_replication_status', 0,1)
go

create procedure sp_MSload_replication_status
as
    set nocount on

    declare @db_name sysname
    declare @distbit int
    declare @retcode int

    select @distbit = 16
    select @retcode = 0

    -- Flush out all current rows
    delete tempdb.dbo.MSreplication_agent_status

    -- Load misc. replication jobs status and map SQL Agent status to replication status
    -- If users delete all misc repl jobs, the status table may not be updated
	-- see sp_MSupdate_replication_status
	insert into tempdb.dbo.MSreplication_agent_status 
        select '', '', '', -1, 5, 
            case isnull(jh.run_status,5) -- mapped to never run
                when 0 then 5   -- Fail mapping
                when 1 then 2   -- Success mapping
                when 2 then 5   -- Retry mapping
                when 3 then 2   -- Shutdown mapping
                when 4 then 3   -- Inprogress mapping
                when 5 then 0   -- Unknown is mapped to never run
            end,
            j.name, NULL from msdb..sysjobs j
            LEFT OUTER JOIN msdb..sysjobhistory jh ON
            j.job_id = jh.job_id and 
            jh.instance_id = (select max(instance_id) from msdb..sysjobhistory jh2 where
                jh2.job_id = j.job_id)
            where j.category_id in (11,12,16,17,18)
    if @@error <> 0
        return 1

    declare hCdatabase CURSOR LOCAL FAST_FORWARD FOR
        select name from master.dbo.sysdatabases 
            where
            category & @distbit <> 0 and
			has_dbaccess(name) = 1
        for read only

    open hCdatabase
    fetch next from hCdatabase into @db_name
    while (@@fetch_status <> -1)
    begin
		select @db_name = QUOTENAME(@db_name)
		
        insert into tempdb.dbo.MSreplication_agent_status 
            (publisher, publisher_db, publication, publication_type, agent_type, status, agent_name)
            exec (@db_name + '.dbo.sp_MSenum_replication_status')

        fetch next from hCdatabase into @db_name
    end
        
DONE:
    close hCdatabase
    deallocate hCdatabase


    -- Add and initialize Perfmon SQL Replication Agents instances
    exec @retcode = dbo.sp_MSinit_replication_perfmon
    if @retcode <> 0 or @@error <> 0
        return 1

GO

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
		exec tempdb.dbo.sp_MS_marksystemobject MSreplication_agent_status
    end
    return 0  -- If here, all is well and we're done.
go

raiserror('Creating procedure sp_MShelp_replication_status', 0,1)
go

create procedure sp_MShelp_replication_status (
	@publisher sysname = '%',
	@publisher_db sysname = '%',
	@publication sysname = '%',
	@agent_type int = 0,
	@exclude_anonymous bit = 0
	)
as
begin
    --set transaction isolation level read uncommitted
    
	declare @retcode int
			,@max_status int
			,@max_timestamp timestamp
			,@publication_type int
			,@all_status int
			,@all_timestamp timestamp
			,@distdbname sysname
			,@anonymous_mask int
			,@anonymous_bit_when_hide int
			,@anonymous_bit_when_show int
			
	select @anonymous_mask = 0x80000000
	if @exclude_anonymous = 0
	begin
		select @anonymous_bit_when_hide = 0x00000000
				,@anonymous_bit_when_show = 0x80000000
	end
	else
	begin
		select @anonymous_bit_when_hide = 0x80000000
				,@anonymous_bit_when_show = 0x00000000
	end

	-- If the local distributor is not installed, we return nothing rather than
	-- fail with table not exists error.
    if (select object_id('tempdb.dbo.MSreplication_agent_status')) is NULL
        return 0

    -- If the temporary status table is empty populate it.
	-- If populated, there should be at lease history cleanup task.
    if not exists (select * from tempdb.dbo.MSreplication_agent_status)
    begin                                           
        exec @retcode = dbo.sp_MSload_replication_status
        if @@error <> 0
            return 1
    end

	
    -- @agent_type is only supported with all wildcards
    if @agent_type <> 0 and (@publisher <> '%' or @publisher_db <> '%' or @publication <> '%')
        return 1
    
    if @publisher = '%'
    begin
        -- @agent_type = 0 returns status of all agents including the misc. agents.
        -- @agent_type = -1 returns status of all agents except misc. agents.
        if @agent_type = 0 or @agent_type = -1
        begin
            select @max_status = max(status), @max_timestamp = max(timestamp) 
            from tempdb.dbo.MSreplication_agent_status (NOLOCK)
                where ((@agent_type = -1 and agent_type <> 5) or
                      @agent_type = 0) and 
					  -- Filter out anonymous if needed
					  agent_type & @anonymous_bit_when_hide = 0
        end
        else
        begin
            select @max_status = max(status), @max_timestamp = max(timestamp) 
            from tempdb.dbo.MSreplication_agent_status (NOLOCK) 
            where
				-- Turn off the anonymous bit when showing
                agent_type & ~@anonymous_bit_when_show = @agent_type
        end
    end
    else if @publication = '%'
    begin
        select @max_status = max(status), @max_timestamp = max(timestamp)
        from tempdb.dbo.MSreplication_agent_status (NOLOCK) 
        where UPPER(publisher) = UPPER(@publisher) and 
			  -- Filter out anonymous if needed
			  agent_type & @anonymous_bit_when_hide = 0
--          publisher_db = @publisher_db 

		--
		-- Process the Queue reader entry separately and check if we need to pick them
		--
   		select @distdbname = distribution_db 
    			from msdb.dbo.MSdistpublishers where name = @publisher collate database_default
		
		select @all_status = status, @all_timestamp = timestamp 
		from tempdb.dbo.MSreplication_agent_status (NOLOCK) 
		where agent_type = 9 and publisher = @@servername and publisher_db = @distdbname

        if @all_status > @max_status
            select @max_status = @all_status

        if @all_timestamp > @max_timestamp
            select @max_timestamp = @all_timestamp
    end
    else if @publication <> '%'
    begin
        select top 1 @max_status = status from tempdb.dbo.MSreplication_agent_status (NOLOCK) where
            UPPER(publisher) = UPPER(@publisher) and
            publisher_db = @publisher_db and
            publication = @publication  and 
			-- Filter out anonymous if needed
			agent_type & @anonymous_bit_when_hide = 0
            order by status desc
        
		-- Get publication type from the Snapshot agent of the Publication. This used to determine
		-- if the Logreader status should be included.
		select @publication_type = publication_type from tempdb.dbo.MSreplication_agent_status (NOLOCK) where
            UPPER(publisher) = UPPER(@publisher) and
            publisher_db = @publisher_db and
            publication = @publication and
            agent_type = 1	-- Snapshot agent

        select @max_timestamp = max(timestamp) from tempdb.dbo.MSreplication_agent_status (NOLOCK) where
            UPPER(publisher) = UPPER(@publisher) and
            publisher_db = @publisher_db and
            publication = @publication  and 
			-- Filter out anonymous if needed
			agent_type & @anonymous_bit_when_hide = 0

        -- If publication_type = 0 then transactional and must include the Logreader
		-- with publication = 'ALL'
        if @publication_type = 0
        begin
            select @all_status = status, @all_timestamp = timestamp 
            from tempdb.dbo.MSreplication_agent_status (NOLOCK) 
            where
                UPPER(publisher) = UPPER(@publisher) and
                publisher_db = @publisher_db and
				publication = 'ALL' and
				agent_type = 2 --Logreader

            if @all_status > @max_status
                select @max_status = @all_status

            if @all_timestamp > @max_timestamp
                select @max_timestamp = @all_timestamp

			--
			-- Process the Queue reader entry separately and check if we need to pick them
			--
	   		select @distdbname = distribution_db 
	    			from msdb.dbo.MSdistpublishers where name = @publisher collate database_default
			
			declare @proc nvarchar(512)
					,@allow_queued_tran bit
					
			SELECT @proc = quotename(@distdbname) + N'.dbo.sp_MSispublicationqueued'
			exec @retcode = @proc
				@publisher = @publisher
				,@publisher_db = @publisher_db
				,@publication = @publication
				,@allow_queued_tran = @allow_queued_tran output
			if (@retcode != 0 and @@error != 0)
				return 1

			if (@allow_queued_tran = 1)
			begin
				select @all_status = status, @all_timestamp = timestamp
				from tempdb.dbo.MSreplication_agent_status (NOLOCK) 
				where agent_type = 9 and publisher = @@servername and publisher_db = @distdbname

				if @all_status > @max_status
					select @max_status = @all_status 

				if @all_timestamp > @max_timestamp
					select @max_timestamp = @all_timestamp
			end
        end
    end

    -- Return result set
    select 'status' = isnull(@max_status, 0), 'timestamp' = isnull (@max_timestamp, 0)

    --set transaction isolation level read committed
    return (0)
end
go

raiserror('Creating procedure sp_MSenum_replication_agents', 0,1)
go
create procedure sp_MSenum_replication_agents
@type int,
@exclude_anonymous bit = 0,
@check_user bit = 0
as
    set nocount on
    --set transaction isolation level read uncommitted

    declare @snapshot int
    declare @logreader int
    declare @distribution int
    declare @sproc sysname
    declare @db_name sysname
    declare @table_name sysname
    declare @cmd nvarchar(255)
    declare @distbit int
    declare @merge int
    declare @misc int
    declare @qreader int

    select @distbit = 16

    select @snapshot = 1
    select @logreader = 2
    select @distribution = 3
    select @merge = 4
    select @misc = 5
    select @qreader = 9

    if @type = @misc
    begin
        exec dbo.sp_MSenum_misc_agents
        return 0
    end

    if @type = @snapshot
    begin
        select @sproc = 'sp_MSenum_snapshot'
        create table #snapshot (dbname sysname collate database_default not null, name nvarchar(100) collate database_default not null, 
            status int NOT NULL,
            publisher sysname collate database_default not null, publisher_db sysname collate database_default not null, 
            publication sysname collate database_default not null,
            start_time nvarchar(24) collate database_default null, time nvarchar(24) collate database_default null, duration int NULL,
            comments nvarchar(255) collate database_default null, delivered_transactions int NULL, 
            delivered_commands int NULL, delivery_rate float NULL, error_id INT NULL,
            job_id binary(16) NULL, local_job bit NULL, profile_id int NOT NULL, 
            agent_id int NOT NULL, local_timestamp binary(8) NOT NULL)

        create unique clustered index ucsnapshot ON #snapshot (job_id)

        select @table_name = '#snapshot'
    end
    else if @type = @logreader
    begin
        select @sproc = 'sp_MSenum_logreader'
        create table #logreader (dbname sysname collate database_default not null, name nvarchar(100) collate database_default not null,  
            status int NOT NULL,
            publisher sysname collate database_default not null, publisher_db sysname collate database_default not null,
            start_time nvarchar(24) collate database_default null, time nvarchar(24) collate database_default null, duration int NULL,
            comments nvarchar(255) collate database_default null, delivery_time int NULL, 
            delivered_transactions int NULL, delivered_commands int NULL, 
            average_commands int NULL, delivery_rate int NULL, delivery_latency int NULL, 
            error_id INT NULL, job_id binary(16) NULL, local_job bit NULL,
            profile_id int NOT NULL, agent_id int NOT NULL, local_timestamp binary(8) NOT NULL)

        create unique clustered index uclogreader ON #logreader (job_id)

        select @table_name = '#logreader'
    end
    else if @type = @distribution
    begin
        select @sproc = 'sp_MSenum_distribution'
        create table #distribution (dbname sysname collate database_default not null, 
            name nvarchar(100) collate database_default not null,  
            status int NOT NULL,
            publisher sysname collate database_default not null, publisher_db sysname collate database_default not null, 
            publication sysname collate database_default null,
            subscriber sysname collate database_default null, subscriber_db sysname collate database_default null, subscription_type int NULL,
            start_time nvarchar(24) collate database_default null, time nvarchar(24) collate database_default null, duration int NULL,
            comments nvarchar(255) NULL, delivery_time int NULL, 
            delivered_transactions int NULL, delivered_commands int NULL, 
            average_commands int NULL, delivery_rate int NULL, 
            delivery_latency int NULL, error_id INT NULL,
            job_id binary(16) NULL, local_job bit NULL, profile_id int NOT NULL, 
            agent_id int NOT NULL, local_timestamp binary(8) NOT NULL, 
            offload_enabled bit NOT NULL, offload_server sysname collate database_default null,
			subscriber_type tinyint NULL)

	    create unique clustered index ucdistribution ON #distribution (job_id)

        select @table_name = '#distribution'
    end
    else if @type = @merge
    begin
        select @sproc = 'sp_MSenum_merge'
        create table #merge (dbname sysname collate database_default not null, name nvarchar(100) collate database_default not null, 
            status int NOT NULL,
            publisher sysname collate database_default not null, publisher_db sysname collate database_default not null, publication sysname collate database_default null,
            subscriber sysname collate database_default null, subscriber_db sysname collate database_default null, subscription_type int NULL,
            start_time nvarchar(24) collate database_default null, time nvarchar(24) collate database_default null, duration int NULL, 
            comments nvarchar(255) NULL, delivery_rate int NULL,
            publisher_insertcount int NULL, publisher_updatecount int NULL, publisher_deletecount int NULL,
            publisher_conficts int NULL, 
            subscriber_insertcount int NULL, subscriber_updatecount int NULL, subscriber_deletecount int NULL,
            subscriber_conficts int NULL, error_id int NULL, job_id binary(16) NULL,
            local_job bit NULL, profile_id int NOT NULL, agent_id int NOT NULL, 
			local_timestamp binary(8) NOT NULL, offload_enabled bit NOT NULL, 
			offload_server sysname collate database_default null, subscriber_type tinyint NULL)

		create unique clustered index ucmerge ON #merge (job_id)


        select @table_name = '#merge'
    end
	else if @type = @qreader
	begin
		select @sproc = 'sp_MSenum_qreader'
		create table #qreader (dbname sysname collate database_default not null, 
			name nvarchar(100) collate database_default not null, status int NOT NULL,
			start_time nvarchar(24) collate database_default null, time nvarchar(24) collate database_default null, duration int NULL,
			comments nvarchar(255) collate database_default null, 
			transactions_processed int NULL, commands_processed int NULL, 
            average_commands int NULL, delivery_rate int NULL, delivery_latency int NULL,
			error_id INT NULL, job_id binary(16) NULL, 
			profile_id int NULL, agent_id int NOT NULL, local_timestamp binary(8) NOT NULL)

		create unique clustered index ucqreader ON #qreader (job_id)

		select @table_name = '#qreader'
	end

    declare hCdatabase CURSOR LOCAL FAST_FORWARD FOR
        select name from master.dbo.sysdatabases 
            where
            category & @distbit <> 0 and
			has_dbaccess(name) = 1
	for read only

    open hCdatabase
    fetch next from hCdatabase into @db_name
    while (@@fetch_status <> -1)
    begin
		
		-- Check to see if the user has permision to monitor the distribution 
		-- database.
		declare @has_pm bit
		select @cmd = quotename(@db_name) + '.dbo.sp_executesql'
		exec @cmd
			N'if is_member(N''db_owner'') = 1 or is_member(N''replmonitor'') = 1 set @has_pm = 1', 
			N'@has_pm bit output',
			@has_pm output
		if @has_pm = 1
		begin
			if @check_user = 1
			begin
				select 'is_replmonitor' = 1
				return
			end
			else
			begin
				select @cmd = 'insert into ' + @table_name +
					' exec ' + quotename(@db_name) + '.dbo.' + @sproc + ' @show_distdb = 1' 
					
				if @type in (@distribution, @merge)
					select @cmd = @cmd +
						', @exclude_anonymous = ' + cast(@exclude_anonymous as nvarchar(1))

				exec (@cmd)
			end
		end
        fetch next from hCdatabase into @db_name
    end
    close hCdatabase
    deallocate hCdatabase

	-- Don't return agents if in check user mode
	if @check_user = 1
		return


    select @cmd = 'select * from ' + @table_name + ' order by job_id asc'
    exec (@cmd)

    -- Drop the table
    select @cmd = 'drop table ' + @table_name
    exec (@cmd)
    --set transaction isolation level read committed

GO

raiserror('Creating procedure sp_replication_agent_checkup', 0,1)
go
create procedure sp_replication_agent_checkup
@heartbeat_interval int = 10        -- minutes
as
    declare @distribution_db sysname
    declare @retstatus int
    declare @proc nvarchar(255)
    declare @retcode int

    declare hCdistdbs CURSOR LOCAL FAST_FORWARD for
        select name from msdb..MSdistributiondbs where 
			has_dbaccess(name) = 1
    for read only
    open hCdistdbs
    fetch hCdistdbs into @distribution_db
    while @@fetch_status <> -1
    begin
        select @proc = @distribution_db + '.dbo.sp_MSagent_stethoscope'
        execute  @retcode = @proc @heartbeat_interval
        if @@error <> 0 or @retcode <> 0
        begin
            select @retstatus = 1
            goto UNDO
        end
        fetch hCdistdbs into @distribution_db
    end

    set @retstatus = 0

UNDO:
    close hCdistdbs
    deallocate hCdistdbs
    return (@retstatus)
go

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

raiserror('Creating procedure sp_MSenum_replication_job', 0,1)
go
create procedure sp_MSenum_replication_job
@job_id uniqueidentifier
as
    SET NOCOUNT ON
    declare @message nvarchar(1024)
    declare @retcode int
    declare @runstatus int
    declare @date int
    declare @time int

    -- Get last message from SQL Agent History table
    create table #JobHistory (
        instance_id int NOT NULL, 
        job_id uniqueidentifier NOT NULL,
        job_name nvarchar(100) collate database_default not null,
        step_id int NOT NULL,
        step_name nvarchar(100) collate database_default not null, 
        sql_message_id int NOT NULL,
        sql_severity int NOT NULL,
        message nvarchar(1024) collate database_default null,
        run_status int NOT NULL,
        run_date int NOT NULL,
        run_time int NOT NULL,
        run_duration int NOT NULL,
        operator_emailed sysname collate database_default null,
        operator_netsent sysname collate database_default null,
        operator_paged sysname collate database_default null,
        retries_attempted int NOT NULL,
        server sysname collate database_default not null
    )
    if @@error <> 0
        return 1

    -- Insert last history for step_id 1 (Agent running)
    set rowcount 1
    insert into #JobHistory exec msdb.dbo.sp_help_jobhistory @job_id = @job_id, @step_id = 1, 
        @mode = 'FULL'          

    -- Get the last history
    select @message = message, @runstatus = run_status, @date = run_date, @time = run_time
        from #JobHistory

    -- Reset rowcount
    set rowcount 0

    -- Map SQL Agent runstatus to Replication runstatus
    set @runstatus = 
    case @runstatus
        when 0 then 6   -- Fail mapping
        when 1 then 2   -- Success mapping
        when 2 then 5   -- Retry mapping
        when 3 then 2   -- Shutdown mapping
        when 4 then 3   -- Inprogress mapping
        when 5 then 0   -- Unknown is mapped to never run
    end

	declare @sztime nchar(6)
	select @sztime = convert(nchar(6), @time)

	-- If the time is like 53030 (5:30:30), make it 053030
	if len(@sztime) = 5
		select @sztime = N'0' + @sztime

    -- Return status and message
    select 'runstatus' = isnull(@runstatus, 0), 'message' = @message,  'date' = @date, 
        'time' = @time, 'datetime' = 
			-- use this style 20000405 13:05:00.000, refer to sp_MSenumallsubscriptions
			convert(nchar(8), @date) + N' ' + 
            substring(@sztime, 1, 2) + N':' +
			substring(@sztime, 3, 2) + N':' +
			-- miliseconds are not availible
			substring(@sztime, 5, 2) + N'.000'

    drop table #JobHistory
go 

raiserror('Creating procedure sp_MSrepl_dbrole', 0,1)
go
CREATE PROCEDURE sp_MSrepl_dbrole
    @rolename       sysname,
    @loginname      sysname,
    @operation      nvarchar(10),
    @is_member      bit = 0 OUTPUT
AS
    -- This is an internal stored procedure. 
    -- If operation is 'add', it will add the login as a user to current database if necessary
    -- get the user name of the login and add it to the role
    -- If operation is 'drop', it will drop the user from the role.
    -- SETUP RUNTIME OPTIONS / DECLARE VARIABLES --
    declare @retcode int
    declare @username sysname
    declare @sid varbinary(85)

    select @sid = suser_sid(@loginname)

    if @operation = 'is_member'
    begin
        if exists (select * from sysusers r, sysusers u, sysmembers m where 
            u.sid = @sid and
            r.name = @rolename and
            m.groupuid = r.uid and
            m.memberuid = u.uid)
            select @is_member = 1
        else
            select @is_member = 0
        return(0)
    end
    
    -- Add the login to  db  role.
    if  is_srvrolemember('sysadmin',  @loginname) <> 1
    begin
        select @username = name from sysusers where sid = @sid
        if @operation = 'add'
        begin
            if @username is null
            begin
                -- Add the server login to be a user with same name in the database
                exec @retcode = dbo.sp_adduser  @loginname
                if @retcode<>0 or @@error <> 0
                    return 1
                select @username = @loginname
            end

            exec @retcode = dbo.sp_addrolemember @rolename, @username
            if @@error <> 0 OR @retcode <> 0
                return 1
        end
        else if @operation = 'drop'
        begin
            if @username is not null
            begin
                exec @retcode = dbo.sp_droprolemember @rolename, @username
                if @@error <> 0 OR @retcode <> 0
                    return 1
            end
        end
    end     
go

raiserror('Creating procedure sp_changedistributor_password', 0,1)
go
CREATE PROCEDURE sp_changedistributor_password (
    @password sysname       
    ) AS

    declare @distributor sysname
    declare @distnetname sysname
    declare @retcode int
    declare @login sysname

    select @login = 'distributor_admin'
    SELECT @distributor = NULL
    SELECT @distributor = srvname, @distnetname = datasource 
        FROM master..sysservers
        WHERE  srvstatus & 8 <> 0
    
    exec @retcode = dbo.sp_addlinkedsrvlogin 
        @rmtsrvname= @distributor,
        @useself = 'false',
        @locallogin = NULL,
        @rmtuser = @login,
        @rmtpassword = @password
    IF @@error <> 0 OR @retcode <> 0
    BEGIN
        RETURN (1)
    END

    if UPPER(@distnetname) = UPPER(@@servername)
    begin
            -- Change the password if the distributor is local
        EXEC @retcode = dbo.sp_password NULL, @password, 'distributor_admin'
        if @@error <> 0 or @retcode <> 0
            return(1)
    end

    return (0)
GO

raiserror('Creating procedure sp_oledbinfo', 0,1)
go
CREATE PROCEDURE sp_oledbinfo
    @server nvarchar(128),
    @infotype nvarchar(128) = NULL,
    @login nvarchar(128) = NULL,
    @password nvarchar(128) = NULL
    AS

    SET NOCOUNT ON

    DECLARE @distributor sysname
    DECLARE @distproc nvarchar (255)
    DECLARE @retcode int

    /*
    ** Get distribution server information for remote RPC
    ** subscription calls.
    */

    EXEC @retcode = dbo.sp_helpdistributor @rpcsrvname = @distributor OUTPUT
    IF @@error <> 0 OR @retcode <> 0
        BEGIN
        RAISERROR (14071, 16, -1)
            RETURN (1)
    END

    select @distproc = rtrim(@distributor) + '.master.dbo.sp_MSget_oledbinfo'
    exec @retcode = @distproc @server, @infotype, @login, @password
    IF @@error <> 0
        BEGIN
        RAISERROR (14071, 16, -1)
        RETURN (1)
    END

go

raiserror('Creating procedure sp_MSget_oledbinfo', 0,1)
go
CREATE PROCEDURE sp_MSget_oledbinfo
    @server nvarchar(128),  -- the name by which the oledb datasource is referred to.
    @infotype nvarchar(128) = NULL,
    @login nvarchar(128) = NULL,
    @password nvarchar(128) = NULL
    AS

    SET NOCOUNT ON

    DECLARE @distproc nvarchar (255)
    DECLARE @providername nvarchar(256)
    DECLARE @datasource nvarchar(4000)
    DECLARE @location nvarchar(4000)
    DECLARE @providerstring nvarchar(4000)
    DECLARE @catalog nvarchar(256)
    DECLARE @retcode int

    select @providername = providername, @datasource = datasource, @location = location, @providerstring = providerstring, @catalog = catalog
        from master..sysservers where UPPER(srvname) = UPPER(@server) collate database_default

    if (@@rowcount = 0)
    begin
        raiserror(15015, 16, -1, @server)
        return (1)
    end

    exec @retcode = master..xp_oledbinfo @providername, @datasource, @location, @providerstring, @catalog, @login, @password, @infotype
    IF @@error <> 0
        BEGIN
        RAISERROR (14071, 16, -1)
        RETURN (1)
    END

go


raiserror('Creating procedure sp_grant_publication_access', 0,1)
go
CREATE PROCEDURE sp_grant_publication_access (
    @publication sysname,
    @login sysname,
    @reserved nvarchar(10) = NULL
        ) AS

    -- This stored procedure can be called repeatedly.
    DECLARE @distribdb sysname
    DECLARE @distproc nvarchar (300)
    DECLARE @retcode int
    DECLARE @dist_rpcname sysname
    DECLARE @database sysname
    
    -- Security Check
    exec @retcode = dbo.sp_MSreplcheck_publish
    if @@ERROR <> 0 or @retcode <> 0
        return(1)
	
	select @database = db_name()

	-- Existance check of the publication will be done in sp_MSpublication_access
    -- Note, even if the login exists, it may or may not has access
    -- to the server (granted or denied). 
    if @reserved is null
	begin
		if not exists (select * from master..syslogins where 
			sid = suser_sid(@login) and
			hasaccess = 1)
		begin
			raiserror(15007, 16, -1, @login) 
			return (1)
		end
		
        -- Don't do the user check if sysadmin since sysadmin can enter
        -- the database as dbo.
		if is_srvrolemember('sysadmin',@login) = 0 and
            not exists (select * from sysusers where
			(sid = suser_sid(@login) or name = N'guest') and
			hasdbaccess = 1) 
		begin
			raiserror(20619, 16, -1, @login, @database) 
			return (1)			
		end
	end

    -- at this point we know that the login exists and has access to the server
    -- get the pubid and add the given login to the PAL role
    -- don't add role if 'init' because role will be added in addmergepublication
    declare @role sysname
    declare @pubid uniqueidentifier
    declare @pubidstr nvarchar(40)
    declare @user sysname

    if (@reserved <> 'init')
    begin
        if exists(select * from dbo.sysobjects where name = 'sysmergepublications')
        begin
            select @pubid = pubid from dbo.sysmergepublications where name = @publication and UPPER(publisher) = UPPER(@@servername) collate database_default and publisher_db = db_name()
            if (@pubid is not null)
            begin
                -- Fix the databse role which represents the users who have access to this publication
                -- this has to be outside the transaction. Hence it is done here since adding the role 
                -- could not be done in sp_addmergepublication.
                exec @retcode = dbo.sp_MSrepl_FixPALRole @pubid, @role output
                if (@retcode<>0 or @@error <> 0)
                    return 1

                -- map the login to a user in the current db
                select @user = name from sysusers where sid = suser_sid(@login) and hasdbaccess = 1
                if @user is NULL
                begin
                    if (is_srvrolemember('sysadmin', @login) = 1) 
                        select @user = 'dbo'

                    if @user is NULL
                    begin
            			raiserror(20624, 16, -1, @login, @database) 
            			return (1)
        			end
                end

                if @user <> 'dbo'
                begin
                    exec @retcode = dbo.sp_addrolemember @role, @user
                    if (@retcode <> 0 or @@error <> 0)
                        return 1
                end
        	end
        end
    end
    
    EXEC @retcode = dbo.sp_helpdistributor  @rpcsrvname = @dist_rpcname OUTPUT,
                                        @distribdb   = @distribdb   OUTPUT
    IF @@error <> 0
    BEGIN
         RAISERROR (14071, 16, -1)
         return (1)
    END

    IF @retcode <> 0 OR @distribdb IS NULL OR @dist_rpcname IS NULL
    BEGIN
        RAISERROR (14071, 16, -1)
        return(1)
    END

    SELECT @distproc = RTRIM(@dist_rpcname) + '.' + RTRIM(@distribdb) + '.dbo.sp_MSpublication_access'
    
    declare @skip bit

    declare @login2 sysname

    if @reserved = 'init'
    begin
		-- Skip logins that are not at the distributor without
		-- raiseing error.
        set @skip = 1
        declare hC CURSOR LOCAL FAST_FORWARD for
            select loginname from master..syslogins where
                (is_srvrolemember('sysadmin', loginname) = 1 or
				sid = suser_sid()) 
		for read only
    end
    else
    begin
        set @skip = 0
        declare hC CURSOR LOCAL FAST_FORWARD for
                select @login
            for read only
    end

    open hC
    fetch hC into @login2

    while (@@fetch_status <> -1)
    begin
        EXEC @retcode = @distproc
             @publisher = @@SERVERNAME,
             @publisher_db = @database,
             @publication = @publication,
             @login= @login2,
             @operation = 'add',
             @skip = @skip
        IF @@error <> 0 OR @retcode <> 0
            return (1)

        fetch hC into @login2
    end
    
    close hC
    deallocate hC
GO

raiserror('Creating procedure sp_revoke_publication_access', 0,1)
go
CREATE PROCEDURE sp_revoke_publication_access (
    @publication sysname,
    @login sysname
        ) AS

    -- This stored procedure can be called repeatedly.
    DECLARE @distribdb sysname
    DECLARE @distproc nvarchar (300)
    DECLARE @retcode int
    DECLARE @dist_rpcname sysname
    DECLARE @database sysname

    -- Security Check
    exec @retcode = dbo.sp_MSreplcheck_publish
    if @@ERROR <> 0 or @retcode <> 0
        return(1)
    -- remove the user from the PAL role in the publishing database
    -- added for role based security
    declare @role sysname
    declare @pubid uniqueidentifier
    declare @pubidstr nvarchar(40)
    declare @user sysname
    
    if exists(select * from dbo.sysobjects where name = 'sysmergepublications')
    begin
        select @pubid = pubid from dbo.sysmergepublications where name = @publication and UPPER(publisher) = UPPER(@@servername) collate database_default and publisher_db = db_name()
        if (@pubid is not null)
        begin
            exec dbo.sp_MSguidtostr @pubid, @pubidstr output
            set @role = 'MSmerge_' + @pubidstr

            if exists (select * from dbo.sysusers where issqlrole=1 and name=@role)
            begin
                select @user = name from sysusers where sid = suser_sid(@login) and name <> 'dbo'
                if @user is not NULL
                begin
                    exec @retcode = dbo.sp_droprolemember @role, @user
                    if (@retcode <> 0 or @@error <> 0)
                        return 1
                end
            end
    	end
    end


    -- Do check existense when dropping since the login might be dropped
    -- outside replication already.

    select @database = db_name()

    EXEC @retcode = dbo.sp_helpdistributor  @rpcsrvname = @dist_rpcname OUTPUT,
                                        @distribdb   = @distribdb   OUTPUT
    IF @@error <> 0
    BEGIN
         RAISERROR (14071, 16, -1)
         return (1)
    END

    IF @retcode <> 0 OR @distribdb IS NULL OR @dist_rpcname IS NULL
    BEGIN
        RAISERROR (14071, 16, -1)
        return(1)
    END

    SELECT @distproc = RTRIM(@dist_rpcname) + '.' + RTRIM(@distribdb) + '.dbo.sp_MSpublication_access'
    EXEC @retcode = @distproc
         @publisher = @@SERVERNAME,
         @publisher_db = @database,
         @publication = @publication,
         @login= @login,
         @operation = 'drop'

    IF @@error <> 0 OR @retcode <> 0
        return (1)

    -- also remove the entry in tempdb cache on the publisher. this entry is created when calling replcheck_pull and 
    -- is subsequently used by replcheck_connection. By removing all cache entries for this publication
    -- there would be a small performance hit but this would be the best way to fix the security hole since
    -- the login could be role or an NT group
    delete from tempdb.dbo.MSpublisher_access 
        where publication = @publication and db_id = db_id()
	if @@error <> 0
		return (1)

GO

raiserror('Creating procedure sp_help_publication_access', 0,1)
go
CREATE PROCEDURE sp_help_publication_access (
    @publication sysname,
    @return_granted bit = 1,
    @login sysname = '%',
	@initial_list bit = 0
        ) AS

    set nocount on
    -- This stored procedure can be called repeatedly.
    DECLARE @distribdb sysname
    DECLARE @distproc nvarchar (300)
    DECLARE @retcode int
    DECLARE @dist_rpcname sysname
    DECLARE @database sysname

    exec @retcode = dbo.sp_MSreplcheck_publish
    if @@ERROR <> 0 or @retcode <> 0
        return(1)

    -- Do check existense when dropping since the login might be dropped
    -- outside replication already.

    select @database = db_name()

    EXEC @retcode = dbo.sp_helpdistributor  @rpcsrvname = @dist_rpcname OUTPUT,
                                        @distribdb   = @distribdb   OUTPUT
    IF @@error <> 0
    BEGIN
         RAISERROR (14071, 16, -1)
         return (1)
    END

    IF @retcode <> 0 OR @distribdb IS NULL OR @dist_rpcname IS NULL
    BEGIN
        RAISERROR (14071, 16, -1)
        return(1)
    END

	SELECT @distproc = RTRIM(@dist_rpcname) + '.' + RTRIM(@distribdb) + '.dbo.sp_MSpublication_access'

    -- Get logins in the PAL if needed
	if @initial_list = 0
	begin
		create table #granted (login sysname collate database_default null)    
		insert into #granted EXEC @retcode = @distproc
			 @publisher = @@SERVERNAME,
			 @publisher_db = @database,
			 @publication = @publication,
			 @operation = 'help',
			 @login = @login

		IF @@error <> 0 OR @retcode <> 0
			return (1)
	end

	-- Get distributor valid logins if needed
	if @return_granted = 0 or @initial_list = 1
	begin
		create table #dist_logins(login sysname collate database_default null)
		insert into #dist_logins EXEC @retcode = @distproc
			 @publisher = @@SERVERNAME,
			 @operation = 'get_logins'
	end

	if @initial_list = 1
	begin
		-- Get the initial list for the publication to be created
		-- by the current user
		-- It contains all the logins sysadmin group and the current user
		-- that have valid login at the distributor.
		select l.loginname, l.isntname, l.isntgroup
		 from master..syslogins l, #dist_logins d where
			l.sid = suser_sid(d.login) and
			l.hasaccess = 1 and
			(is_srvrolemember('sysadmin',d.login) = 1 or (l.sid = suser_sid())) 
	end
	else if @return_granted = 0
	begin
		select l.loginname, l.isntname, l.isntgroup
		 from master..syslogins l, #dist_logins d where
			l.sid = suser_sid(d.login) and
			l.hasaccess = 1 and 
			not exists (select * from #granted g where 
				suser_sid(g.login) = l.sid) and
			exists (select * from sysusers u where
				(u.sid = l.sid or u.name = 'guest') and
				u.hasdbaccess = 1)
	end
	else if @return_granted = 1
	begin
		select l.loginname, l.isntname, l.isntgroup from master..syslogins l,
			#granted g where
			l.sid = suser_sid(g.login)
	end
GO

raiserror('Creating procedure sp_check_publication_access', 0,1)
go
CREATE PROCEDURE sp_check_publication_access
@publication sysname,
@given_login sysname = NULL
AS
	set nocount on
    declare @retcode int
    exec @retcode = dbo.sp_MSreplcheck_pull 
        @publication = @publication,
        @given_login = @given_login
	if @retcode <> 0 or @@error <> 0
		return (1)
    return 0
GO

exec dbo.sp_MS_marksystemobject sp_check_publication_access
go

raiserror('Creating procedure sp_MSget_agent_names', 0,1)
go
CREATE PROCEDURE sp_MSget_agent_names
@publication sysname,        
@subscriber sysname = NULL,              
@subscriber_db sysname = NULL,
@publisher sysname = NULL,
@publisher_db sysname = NULL
as
	set nocount on

	declare @retcode int

	if @publisher is null
	-- We are at the publisher side, call into the distributor
	begin
		/*
		** Get distribution server information for remote RPC
		** agent verification.
		*/
		declare @distributor sysname
		declare @distribdb sysname
		declare @distproc nvarchar(1000), @pubdb sysname

		select @pubdb = db_name()

		EXEC @retcode = dbo.sp_helpdistributor @rpcsrvname = @distributor OUTPUT,
			@distribdb = @distribdb OUTPUT

		IF @@error <> 0 OR @retcode <> 0
		BEGIN
			RAISERROR (14071, 16, -1)
			RETURN (1)
		END

		/*
		** Call proc to change the distributor
		*/
		SELECT @distproc = RTRIM(@distributor) + '.' + @distribdb + 
			'.dbo.sp_MSget_agent_names'
		exec @retcode = @distproc 
			@publisher = @@SERVERNAME,
			@publisher_db = @pubdb,
			@publication = @publication,
			@subscriber = @subscriber,
			@subscriber_db = @subscriber_db
	end
	else
	-- We are at the distribution db
	begin
		declare @publisher_id smallint
		select @publisher_id = srvid from master..sysservers where UPPER(srvname) = UPPER(@publisher) collate database_default

		if @subscriber is null
		-- Returning publication agents if @subscriber is null
		begin
			declare @snapshot_agent sysname, @logreader_agent sysname, @qreader_agent sysname
			
			-- Have to use name in sysjobs table because users may rename
			-- the SQLServerAgent jobs. If users deleted the jobs, DMO scripting will
			-- create new jobs.

			select 
				'snapshot_agent' = (select j.name from MSsnapshot_agents a, msdb..sysjobs j where
					publisher_id = @publisher_id and
					publisher_db = @publisher_db collate database_default and
					publication = @publication collate database_default and
					a.job_id = j.job_id),
				'logreader_agent' = (select j.name from MSlogreader_agents a, msdb..sysjobs j where
					publisher_id = @publisher_id and
					publisher_db = @publisher_db collate database_default and
					a.job_id = j.job_id),
				'qreader_agent' = (select j.name from MSqreader_agents a, msdb..sysjobs j where
					a.job_id = j.job_id)
		end
		else
		begin
			declare @subscriber_id smallint
			select @subscriber_id = srvid from master..sysservers where UPPER(srvname) = UPPER(@subscriber) collate database_default
			declare @publication_type int, @independent_agent bit

			select @publication_type = publication_type, @independent_agent = independent_agent
				from MSpublications where 
					publisher_id = @publisher_id and
					publisher_db = @publisher_db and
					publication = @publication

			if @publication_type = 2
			-- Merge publication, get merge agent name
			begin
				select 'merge_agent' = j.name from MSmerge_agents a, msdb..sysjobs j where
					publisher_id = @publisher_id and
					publisher_db = @publisher_db collate database_default and
					publication = @publication collate database_default and
					subscriber_id = @subscriber_id and
					subscriber_db = @subscriber_db collate database_default and
					a.job_id = j.job_id
			end
			else
			begin
				select 'distribution_agent' = j.name from MSdistribution_agents a, msdb..sysjobs j where
					publisher_id = @publisher_id and
					publisher_db = @publisher_db collate database_default and
					(publication = @publication collate database_default or
					 publication = N'ALL' and @independent_agent = 0) and
					subscriber_id = @subscriber_id and
					subscriber_db = @subscriber_db collate database_default and
					a.job_id = j.job_id
			end
		end
	end -- If @publisher is null

go

exec dbo.sp_MS_marksystemobject sp_MSget_agent_names
go

raiserror('Creating procedure sp_MSinit_replication_perfmon', 0,1)
go

create proc sp_MSinit_replication_perfmon
as
    declare @agent_type int
    declare @agent_name nvarchar(100)
    declare @status int

    -- Remove all existing instances
    dbcc deleteinstance ("SQL Replication Agents", "%")
    dbcc deleteinstance ("SQL Replication Snapshot", "%")
    dbcc deleteinstance ("SQL Replication Logreader", "%")
    dbcc deleteinstance ("SQL Replication Distribution", "%")
    dbcc deleteinstance ("SQL Replication Merge", "%")
    dbcc deleteinstance ("SQL Replication Queuereader", "%")

    -- Add and initialize Perfmon SQL Replication Agents instances
    dbcc addinstance ("SQL Replication Agents", "Snapshot")
    dbcc addinstance ("SQL Replication Agents", "Logreader")
    dbcc addinstance ("SQL Replication Agents", "Distribution")
    dbcc addinstance ("SQL Replication Agents", "Merge")
    dbcc addinstance ("SQL Replication Agents", "Queuereader")
    dbcc setinstance ("SQL Replication Agents", "Running", "Snapshot", 0)
    dbcc setinstance ("SQL Replication Agents", "Running", "Logreader", 0)
    dbcc setinstance ("SQL Replication Agents", "Running", "Distribution", 0)
    dbcc setinstance ("SQL Replication Agents", "Running", "Merge", 0)
    dbcc setinstance ("SQL Replication Agents", "Running", "Queuereader", 0)

    -- Add instances for each agent currently in the status table
    declare hC CURSOR LOCAL FAST_FORWARD for select agent_type, agent_name, status from tempdb.dbo.MSreplication_agent_status for read only
    open hC
    fetch hC into @agent_type, @agent_name, @status
    while (@@fetch_status <> -1)
    begin

        if @agent_type = 1 
        begin
            dbcc addinstance ("SQL Replication Snapshot", @agent_name)
            if @status = 1 or @status = 3 or @status = 4
                dbcc incrementinstance ("SQL Replication Agents", "Running", "Snapshot", 1)
        end
        else if @agent_type = 2 
        begin
            dbcc addinstance ("SQL Replication Logreader", @agent_name)
            if @status = 1 or @status = 3 or @status = 4
                dbcc incrementinstance ("SQL Replication Agents", "Running", "Logreader", 1)
        end
        else if @agent_type = 3 
        begin
            dbcc addinstance ("SQL Replication Distribution", @agent_name)
            if @status = 1 or @status = 3 or @status = 4
                dbcc incrementinstance ("SQL Replication Agents", "Running", "Distribution", 1)
        end
        else if @agent_type = 4 
        begin
            dbcc addinstance ("SQL Replication Merge", @agent_name)
            if @status = 1 or @status = 3 or @status = 4
                dbcc incrementinstance ("SQL Replication Agents", "Running", "Merge", 1)
        end
        else if @agent_type = 9 
        begin
            dbcc addinstance ("SQL Replication Queuereader", @agent_name)
            if @status = 1 or @status = 3 or @status = 4
                dbcc incrementinstance ("SQL Replication Agents", "Running", "Queuereader", 1)
        end

        fetch hC into @agent_type, @agent_name, @status
    end
    close hC
    deallocate hC
GO

raiserror('Creating procedure sp_MSrepl_startup', 0,1)
go
create procedure sp_MSrepl_startup
as

    -- Drop and create publisher side cache table
    if exists (select * from tempdb..sysobjects where name = 'MSpublisher_access' and
    type = 'U')
        drop table tempdb.dbo.MSpublisher_access

    create table tempdb.dbo.MSpublisher_access
    (
    spid int NOT NULL,
    db_id int not null,
    publication sysname not null,
    login_time datetime not null,
    pubid uniqueidentifier null -- Used for merge only.
    )

    CREATE CLUSTERED INDEX ucMSpublisher_access ON tempdb.dbo.MSpublisher_access
        (spid, publication, db_id)

	exec tempdb.dbo.sp_MS_marksystemobject MSpublisher_access
    -- Drop and create distributor side cache table
    -- We need to avoid publisher and distributor using the same table to prevent
    -- contention in local distributor case.
    if exists (select * from master..sysservers
                  WHERE  srvstatus & 8 <> 0 and UPPER(datasource) = UPPER(@@servername) collate database_default)
    begin
        if exists (select * from tempdb..sysobjects where name = 'MSdistributor_access' and
        type = 'U')
            drop table tempdb.dbo.MSdistributor_access

        create table tempdb.dbo.MSdistributor_access
        (
        spid int NOT NULL,
        db_id int not null,
        agent_id int not null,
        agent_type int not null,
        publication_id int not null,
        login_time datetime not null
        )

        CREATE CLUSTERED INDEX ucMSdistributor_access ON tempdb.dbo.MSdistributor_access
            (spid, agent_id, db_id)
		exec tempdb.dbo.sp_MS_marksystemobject MSdistributor_access
		-- Create repl monitor table
		exec sp_MScreate_replication_status_table
   end
go

-- If a distributor is installed, mark the sp as a startup sp. 
if exists (select * FROM master..sysservers WHERE  srvstatus & 8 <> 0)
    exec dbo.sp_procoption 'sp_MSrepl_startup', 'startup', 'true' 
go

raiserror('Creating procedure sp_MSflush_access_cache', 0,1)
go
CREATE PROCEDURE sp_MSflush_access_cache 
AS
    -- Delete all the 'dead' connections in MSpublisher_access.
    delete tempdb.dbo.MSpublisher_access 
        from tempdb.dbo.MSpublisher_access a
        where not exists (select * from master..sysprocesses p where
            a.spid = p.spid and
            p.login_time = a.login_time)
    if @@error <> 0
        return 1
    else
        return 0

    if exists (select * from tempdb..sysobjects where name = 'MSdistributor_access' and
    type = 'U')
    begin
        -- Delete all the 'dead' connections in MSdistributor_access.
        delete tempdb.dbo.MSdistributor_access 
            from tempdb.dbo.MSdistributor_access a
            where not exists (select * from master..sysprocesses p where
                a.spid = p.spid and
                p.login_time = a.login_time)
        if @@error <> 0
            return 1
        else
            return 0
    end
    return (0)
GO

raiserror('Creating procedure sp_MSreinit_failed_subscriptions', 0,1)
go
-- This stored procedure is used as a response to the Replication Validation Failure Alert.
-- It will reinit the failed subscription. If the publisher is remote, it must be configured as a remote server 
-- for this procedure to work.
create proc sp_MSreinit_failed_subscriptions
@failure_level int = 0      -- 0 All failure  1 Validation failures
as

    declare @publisher sysname
    declare @publisher_db sysname
    declare @publication sysname
    declare @article sysname
    declare @publication_type int
    declare @subscriber sysname
    declare @subscriber_db sysname
    declare @agent_type int
    declare @alert_id int
    declare @proc nvarchar(100)
    declare @message nvarchar(4000)
    declare @retcode int
    declare @found bit
    declare @return_value int
    
    set nocount on

    set @found = 0          -- set if cursor returns a row
    set @return_value = 0   -- set to success

    -- For each publication validation failure, resync the subscription
    declare hc CURSOR LOCAL FAST_FORWARD for select publisher, publisher_db, publication, publication_type, article, subscriber, 
        subscriber_db, alert_id from 
        msdb..sysreplicationalerts where
        (@failure_level = 0 or (@failure_level = 1 and alert_error_code = 20574)) and   -- 20574 = validation failure
        status = 0
        for read only

    open hc
    fetch hc into  @publisher, @publisher_db, @publication, @publication_type, @article, @subscriber, @subscriber_db, @alert_id
    while (@@fetch_status <> -1)
    begin
        
        set @found = 1

        -- Reinit snapshot or transactional subscription (article level)
        if @publication_type = 0 or @publication_type = 1
        begin
            set @proc = @publisher + '.' + @publisher_db + '.dbo.sp_reinitsubscription'
            exec @retcode = @proc
                @publication = @publication,
                @article = @article,
                @subscriber = @subscriber,
                @destination_db = @subscriber_db
            -- Ignore failures, update status bit if successful
            if @retcode = 0
            begin
                -- Change status to 1 which means the alerts has been serviced
                update msdb..sysreplicationalerts set status = 1 where alert_id = @alert_id

                -- Raiserror that subscription was reinitialized
                if @failure_level = 0
                    -- 'Subscriber ''%s'' subscription to article ''%s'' in publication ''%s'' has been reinitialized after a synchronization failure.'
                    raiserror(20576, 10,-1, @subscriber, @article, @publication) 
                else if @failure_level  = 1
                    -- 'Subscriber ''%s'' subscription to article ''%s'' in publication ''%s'' has been reinitialized after a validation failure.'
                    raiserror(20572, 10,-1, @subscriber, @article, @publication) 
            end
            else -- failure
                set @return_value = 1
        end
        -- Reinit merge subscription (full publication)
        else if @publication_type = 2       
        begin
            set @proc = @publisher + '.' + @publisher_db + '.dbo.sp_reinitmergesubscription'
            exec @retcode = @proc
                @publication = @publication,
                @subscriber = @subscriber,
                @subscriber_db = @subscriber_db
            -- Ignore failures, update status bit if successful
            if @retcode = 0
            begin
                -- Change status to 1 which means the alerts has been serviced
                update msdb..sysreplicationalerts set status = 1 where alert_id = @alert_id

                -- Raiserror that subscription was reinitialized
                if @failure_level = 0
                    -- 'Subscriber ''%s'' subscription to to article ''%s'' in publication ''%s'' has been reinitialized after a synchronization failure.'
                     raiserror(20576, 10,-1, @subscriber, @article, @publication) 
                else if @failure_level  = 1
                    -- 'Subscriber ''%s'' subscription to to article ''%s'' in publication ''%s'' has been reinitialized after a validation failure.'
                    raiserror(20572, 10,-1, @subscriber, @article, @publication)
            end
            else -- failure
                set @return_value = 1
        end

        fetch hc into  @publisher, @publisher_db, @publication, @publication_type, @article, @subscriber, @subscriber_db, @alert_id
    end

    close hc
    deallocate hc

    -- Return a message stating no entries where found
    if @found = 0
    begin
        -- 'No entries were found in msdb..sysreplicationalerts.'
        raiserror(20577, 10,-1) 

        -- There is most likely a problem, set failure return value
        set @return_value = 1
    end

    return @return_value 
go
dump tran master with no_log
GO

raiserror('Creating procedure sp_add_datatype_mapping', 0,1)
go

-- Add a row into the "MSdatatype_mappings" table
create procedure sp_add_datatype_mapping (
    @dbms_name          sysname,
    @sql_type           sysname,
    @dest_type          sysname,
    @dest_prec          int,
    @dest_create_params int,
    @dest_nullable      bit
)
as
    set nocount on

    if @dbms_name is null
    BEGIN
        RAISERROR (14043, 16, -1, '@dbms_name')
        RETURN (1)
    END
    
    if @sql_type is null 
    BEGIN
        RAISERROR (14043, 16, -1, '@sql_type')
        RETURN (1)
    END

    if @dest_type is null
    BEGIN
        RAISERROR (14043, 16, -1, '@dest_type')
        RETURN (1)
    END

    if @dest_prec is null
    BEGIN
        RAISERROR (14043, 16, -1, '@dest_prec')
        RETURN (1)
    END

    if @dest_create_params is null
    BEGIN
        RAISERROR (14043, 16, -1, '@dest_create_params')
        RETURN (1)
    END

    if @dest_nullable is null
    BEGIN
        RAISERROR (14043, 16, -1, '@dest_nullable')
        RETURN (1)
    END
 

    insert into msdb..MSdatatype_mappings
    values (@dbms_name, @sql_type, @dest_type, @dest_prec, @dest_create_params, @dest_nullable)

    if @@error <> 0
        return(1)
GO

raiserror('Creating procedure sp_MSrepl_gettype_mappings', 0,1)
go
create procedure sp_MSrepl_gettype_mappings(
    @dbms_name          sysname,
    @sql_type           sysname = '%',
    @source_prec        int = NULL
)
as
    set nocount on
	declare @retcode int
	declare @distributor sysname
	declare @distribdb sysname
	declare @distproc nvarchar (255)
    
	EXECUTE @retcode = dbo.sp_helpdistributor @rpcsrvname = @distributor OUTPUT,
		   @distribdb   = @distribdb OUTPUT
	IF @@ERROR <> 0 or @retcode <> 0
	BEGIN
		RAISERROR (14071, 16, -1)
		RETURN (1)
	END

	SELECT @distproc = RTRIM(@distributor) + '.master' + 
			'.dbo.sp_help_datatype_mapping'

	EXECUTE @retcode = @distproc
					   @dbms_name = @dbms_name,
					   @sql_type = @sql_type,
					   @source_prec = @source_prec
			
	IF @@ERROR <> 0 OR @retcode <> 0
		return 1
	ELSE
		return 0
go

raiserror('Creating procedure sp_help_datatype_mapping', 0,1)
go
create procedure sp_help_datatype_mapping(
    @dbms_name          sysname,
    @sql_type           sysname = '%',
    @source_prec        int = NULL
)
as
    set nocount on
    
    if @source_prec is NULL
    begin
        select sql_type, dest_type, dest_prec, dest_create_params, dest_nullable
        from msdb..MSdatatype_mappings 
        where dbms_name = @dbms_name collate database_default
        and sql_type like @sql_type collate database_default
    end
    else
    begin
        select sql_type, dest_type, dest_prec, dest_create_params, dest_nullable
        from msdb..MSdatatype_mappings 
        where dbms_name = @dbms_name collate database_default
        and sql_type like @sql_type collate database_default
        and dest_prec = (select min(dest_prec)
                            from msdb..MSdatatype_mappings 
                            where dbms_name = @dbms_name collate database_default
                            and sql_type like @sql_type collate database_default
                            and dest_prec >= @source_prec
                        )
    end
GO

raiserror('Creating procedure sp_MSfix_6x_tasks', 0,1)
go
CREATE PROCEDURE sp_MSfix_6x_tasks (
	@publisher sysname = NULL
) AS

    SET NOCOUNT ON

    DECLARE @distributor sysname
    DECLARE @distproc nvarchar (255)
	declare @retcode int

	-- If @publisher is null redirect the call to distributor
	if @publisher is null
	begin
		/*
		** Get distribution server information for remote RPC
		** agent verification.
		*/
		EXEC @retcode = dbo.sp_helpdistributor @rpcsrvname = @distributor OUTPUT

		IF @@error <> 0 OR @retcode <> 0
		BEGIN
			RAISERROR (14071, 16, -1)
			RETURN (1)
		END

		/*
		** RPC distributor
		*/
		SELECT @distproc = RTRIM(@distributor) + '.master.dbo.sp_MSfix_6x_tasks'

		EXECUTE @retcode = @distproc
			@publisher = @@SERVERNAME
		IF @@ERROR <> 0 or @retcode <> 0
			return (1)
	end
	else
	begin

		declare @category_id int
		declare @category_name sysname
		declare @server sysname
		declare @databasename sysname
		declare @name sysname
		declare @distdb sysname
		declare @job_id uniqueidentifier
		declare @sSubsystem sysname

        -- Drop entry in systasks first.
        DECLARE hCtasks CURSOR LOCAL FAST_FORWARD FOR
            SELECT name FROM msdb.dbo.systasks_view st WHERE 
                
                -- drop distribution agents.
                (st.name LIKE @publisher + '_' + '%' + '_' + '%' AND 
                LOWER(subsystem collate SQL_Latin1_General_CP1_CS_AS) = 'distribution' AND
                server = @@SERVERNAME) OR
                                
                (LOWER(subsystem collate SQL_Latin1_General_CP1_CS_AS) = 'logreader' AND
                server = @publisher) OR 
                
                (LOWER(subsystem collate SQL_Latin1_General_CP1_CS_AS) = 'snapshot' AND
                server = @publisher) OR

                (st.name LIKE '%' + '_' + '%' + '_Cleanup' AND 
				st.command LIKE '%' + 'sp_replcleanup' + '%' AND
				LOWER(subsystem collate SQL_Latin1_General_CP1_CS_AS) = 'tsql')
            FOR READ ONLY

        OPEN hCtasks
        FETCH hCtasks INTO @name

        WHILE (@@fetch_status <> -1)
        BEGIN
            
            EXEC @retcode = msdb.dbo.sp_droptask @name = @name
            if @retcode <> 0 or @@error <> 0
                return(1)
            FETCH hCtasks INTO @name
        END

		-- Now spin through each old replication job and fixup categories names
		declare hcJobsToFix CURSOR LOCAL FAST_FORWARD for 
				select distinct j.job_id, j.name, s.subsystem, 
					s.server, s.database_name
					from msdb.dbo.sysjobs j left join msdb.dbo.sysjobsteps s
						on j.job_id = s.job_id
					where j.category_id = 0 and s.step_id = 1 and lower(s.subsystem collate SQL_Latin1_General_CP1_CS_AS) in ( 'snapshot', 'logreader', 'distribution' )
				for read only

		open hcJobsToFix 
		fetch hcJobsToFix into @job_id, @name, @sSubsystem,
			@server,@databasename

		while (@@fetch_status <> -1 )
		begin
			-- Note, have to make it a transaction, once the category_id is changed,
			-- the task will never be picked up again.
			begin tran 

				-- Get Distribution category name (assumes category_id = 10)
				select @category_id =
					case lower(@sSubsystem collate SQL_Latin1_General_CP1_CS_AS) 
						when 'snapshot' then 15
						when 'distribution' then 10
						when 'logreader' then 13
						else 0
					end

				select @category_name = name FROM msdb.dbo.syscategories where category_id = @category_id
				
				-- raiserror( 'Would update %s to category %d based on subsystem value %s', -1, 10, @nJobName, @iCategory, @sSubsystem )
				exec @retcode = msdb.dbo.sp_update_job @job_id = @job_id, 
					@category_name = @category_name
				if @retcode <> 0 or @@error <> 0
					goto UNDO


				-- Add the replication agent for monitoring
				SELECT @distdb = distribution_db from msdb..MSdistpublishers where UPPER(name) = UPPER(@server) collate database_default
				IF (@category_id = 13) -- Logreader
				BEGIN
					SELECT @distproc = @distdb + '.dbo.sp_MSadd_logreader_agent'
					EXECUTE @retcode = @distproc
						@name = @name,
						@publisher = @server,
						@publisher_db = @databasename,
						@publication = '',  
						@local_job = 1,
						@job_existing = 1,
						@job_id = @job_id

					IF (@retcode <> 0 or @@error<>0)
						goto UNDO
				END
				ELSE 
				IF (@category_id = 15) -- Snapshot
				BEGIN
                    DECLARE @publication sysname

                    SELECT @publication = NULL
                    EXECUTE master.dbo.sp_MSget_publication_from_taskname
                                            @taskname = @name,
                                            @publisher = @server,
                                            @publisherdb = @databasename,
                                            @publication = @publication OUTPUT

                    IF (@publication IS NOT NULL )
                    BEGIN    			
					    SELECT @distproc = @distdb + '.dbo.sp_MSadd_publication'
					    EXECUTE @retcode = @distproc
						    @publisher = @server,
						    @publisher_db = @databasename,
						    @publication = @publication,
						    @publication_type = 0 -- Transactional
					    IF (@retcode <> 0 or @@error<>0)
						    goto UNDO

					    SELECT @distproc = @distdb + '.dbo.sp_MSadd_snapshot_agent'
					    EXECUTE @retcode = @distproc
						    @name = @name,
						    @publisher = @server,
						    @publisher_db = @databasename,
						    @publication = @publication,
						    @local_job = 1,
						    @job_existing = 1,
						    @snapshot_jobid = @job_id
					    IF (@retcode <> 0 or @@error<>0)
						    goto UNDO
                    END
				END
			commit tran
			fetch hcJobsToFix into @job_id, @name, @sSubsystem,
				@server,@databasename
		end			
		close hcJobsToFix
		deallocate hcJobsToFix
	end
	return (0)
UNDO:
	if @@trancount <> 0
		rollback tran
	return (1)
GO

/*
 * Name :       sp_MShelpconflictpublications
 * Description: This sp returns a list of publications or subscriptions in the current
 *    database that may have conflicts. Results are ordered by publication
 *    name.
 * Parameters:  1. publication_type( sysname; '%'==ALL (default) | 'merge' | 'queued' )
 * Output Result Set has the following structure:
 *  ----------------------------------------------------------------------------------
 *      Name                Datatype                Description
 *  ----------------------------------------------------------------------------------
 *  a. name					(sysname)			Publication name
 *  b. publication_type		(varchar(9))		'merge' | 'queued' | 'immediate' (reserved)
 *  c. merge_pub_id			(uniqueidentifier)	Merge publication identifier
 *  d. queued_pub_id		(integer)			Queued publication identifier (I would prefer to name this as tran_pub_id)
 *  e. sub_agent_id			(integer)			Unique publication identifier on a tran subscriber
 *  NOTE: In case of queued tran publications, either d or e will have a value at any time
 *  and this will also indicate, if we are processing a subscriber of a publication (d 
 *  will be NULL and e will have a value) or if we are processing the publisher side (d
 *  will have a value and e will be NULL)
*/
raiserror('Creating procedure sp_MShelpconflictpublications', 0,1)
GO

CREATE PROCEDURE sp_MShelpconflictpublications ( @publication_type varchar(9) ='%' )
AS 
BEGIN

	SET nocount ON

        DECLARE @retcode int

        /*
        **  Security check.  restrict to 'sysadmin' and member of db_owner role
        */ 
        exec @retcode = dbo.sp_MSreplcheck_publish
        if @@ERROR <> 0 or @retcode <> 0
            return (1)
	
	-- validate publication type
	IF NOT( lower(@publication_type collate SQL_Latin1_General_CP1_CS_AS) IN ('%', 'merge', 'queued') )
	BEGIN
		raiserror( 'invalid publication type', 16, -1 )
		RETURN (1)
	END
	
	-- temp table to store combined result set
	CREATE TABLE #result_list ( publication sysname collate database_default, publication_type VARCHAR(9) DEFAULT 'merge', 
								merge_pub_id UNIQUEIDENTIFIER NULL, 
								queued_pub_id INTEGER NULL, sub_agent_id INTEGER NULL, publisher sysname collate database_default NULL, publisher_db sysname collate database_default NULL)

	-- fetch merge results into temp table; need not affect any rows
	IF ( lower(@publication_type collate SQL_Latin1_General_CP1_CS_AS) IN ('%', 'merge') )
	BEGIN
		IF EXISTS( SELECT * FROM sysobjects WHERE name = 'sysmergepublications' )
			INSERT #result_list ( publication, merge_pub_id, publisher, publisher_db)
				EXEC sp_MShelpmergeconflictpublications

		-- may return 18757 (not merge published) and that is ok if @publication_type = ALL
		IF ( @@ERROR <> 0) AND ( @@ERROR = 18757 AND @publication_type = '%' ) 
			GOTO FAILURE
				
	END

	-- fetch tran results into temp table
	IF ( lower(@publication_type collate SQL_Latin1_General_CP1_CS_AS) IN ('%', 'queued') )
	BEGIN
		INSERT #result_list  ( publication, publication_type, merge_pub_id , queued_pub_id, sub_agent_id )
			EXEC sp_MShelptranconflictpublications
		IF ( @@ERROR <> 0) 
			GOTO FAILURE

	END

	-- return combined result list
	SELECT * FROM #result_list

	IF EXISTS( SELECT * FROM sysobjects WHERE type = 'U' AND name = '#result_list' )
		DROP TABLE #result_list

	RETURN (0)

FAILURE:

	IF EXISTS( SELECT * FROM sysobjects WHERE type = 'U' AND name = '#result_list' )
		DROP TABLE #result_list

	RETURN (1)
	
END
GO

raiserror('Creating function system_function_schema.fn_replgetagentcommandlinefromjobid',0,1)
go
--
-- Name: fn_replgetagentcommandlinefromjobid
--
-- Description: This function retrieves the command line  
--              of the replication agent with the 
--              specified job_id.
--
-- Parameters: @agenttype nvarchar(16)
--             @job_id uniqueidentifier
-- 
-- Returns: nvarchar(3200) 
--
-- Notes: This function can return null if the 
--        the given job_id doesn't belong to a
--        replication agent of the specified type.
--
-- Security: Admin access only
-- 
create function system_function_schema.fn_replgetagentcommandlinefromjobid (
    @agenttype nvarchar(16),
    @job_id uniqueidentifier
    ) returns nvarchar(3200)
as
begin
    declare @commandline nvarchar(3200)
    select @commandline = null
    select @agenttype = upper(@agenttype collate SQL_Latin1_General_CP1_CS_AS)
    select @commandline = command 
      from msdb.dbo.sysjobsteps
     where job_id = @job_id
       and upper(subsystem collate SQL_Latin1_General_CP1_CS_AS) = @agenttype collate SQL_Latin1_General_CP1_CS_AS

    return @commandline
end
go

raiserror('Creating procedure sp_replproberemoteserver', 0,1)
go
--
-- Name: sp_replproberemoteserver
--
-- Description: This is a lightweight wrapper for calling xp_replproberremsrv
--              with the added nicety of looking up the agent command line
--              using the given jobid. This procedure supports two different
--              modes of operation based on the @no_rpc parameter. If the 
--              @no_rpc parameter is 1, this procedure will not attempt to make
--              rpc call to the Distributor. The local mode is mainly useful 
--              for verifying remote pull subscription agent.
-- 
-- Parameters: @remoteservername sysname (mandatory) 
--             @agent_type nvarchar(16) (optional, default = null) 
--             @agent_jobid uniqueidentifier (optional default = null)
--             @no_rpc bit (optional default = 0)
--
-- Notes: If @job_id is null, only activation verification will be carried
--        out.
--
-- Security: Execute permission of this procedure is granted to public, 
--           internal security check is performed to make sure that the
--           caller is at least a db_owner of the current database.
--
-- Result: 'probe_succeeded' 0 or 1
--
-- Returns: 0    - succeeded
--          <> 0 - failed
--
create procedure dbo.sp_replproberemoteserver (
    @remoteservername sysname,
    @agent_type       nvarchar(16) = null,
    @agent_jobid      uniqueidentifier = null,
    @no_rpc           bit = 0
    ) 
as
begin
    set nocount on
    declare @retcode        int
    declare @commandline    nvarchar(3200)
    declare @distributor    sysname
    declare @distributiondb sysname     
    declare @distproc       nvarchar(255)
    declare @succeeded      nvarchar(10)

    select @retcode = 0
    select @commandline = null
    select @succeeded = null

    -- security check, db_owner
    -- Note that this proc can be called from either a publisher database or
    -- a subscriber database
    exec @retcode = dbo.sp_MSreplcheck_publish
    if @@error <> 0 or @retcode <> 0
        return (1)
    
    if @agent_type is null
    begin
        select @agent_type = 'distribution'
    end
    
    -- @remoteservername cannot be null or empty
    select @remoteservername = rtrim(ltrim(@remoteservername))
    if @remoteservername is null or
       @remoteservername = N''
    begin
        raiserror(21263,16,-1,'@remoteservername')
        return 1
    end     
    
    -- @agent_type must be 'distribution' or 'merge'
    if @agent_type not in (N'distribution', N'merge')
    begin
        raiserror(21182,16,-1) 
        return 1
    end

    -- Get Distributor information
    if @no_rpc = 0
    begin
        exec @retcode = dbo.sp_helpdistributor @rpcsrvname = @distributor output,
                                          @distribdb = @distributiondb output
        if @@error <> 0 or @retcode <> 0
            return 1
    end
    else
    begin
        select @distributor = @@servername
    end

    if upper(@@servername) <> upper(@distributor)
    begin
        select @distproc = ltrim(rtrim(@distributor)) + '.' + 
            'master.dbo.sp_replproberemoteserver'
        exec @retcode = @distproc @remoteservername, 
                                  @agent_type, 
                                  @agent_jobid, 
                                  1
        return @retcode
    end        
    else
    begin
        -- If the given @job_id is not null, try to get
        -- the agent command line
        if @agent_jobid is not null 
        begin
            select @commandline = fn_replgetagentcommandlinefromjobid(
                @agent_type,
                @agent_jobid) collate database_default

            if @commandline is null
            begin
                raiserror(21361,6,-1, @agent_type) 
                select 'probe_succeeded' = 0
                return 1
            end

        end 
 
        exec @retcode = master.dbo.xp_replproberemsrv 
            @remoteservername, 
            @agent_type, 
            @succeeded output,
            @commandline 

        if lower(@succeeded collate SQL_Latin1_General_CP1_CS_AS) = N'true'  
            select 'probe_succeeded' = 1
        else
            select 'probe_succeeded' = 0

        return @retcode
    end

    select 'probe_succeeded' = 0

    return 1
end
go
exec sp_MS_marksystemobject sp_replproberemoteserver
go
grant execute on dbo.sp_replproberemoteserver to public
go

raiserror('Creating procedure sp_MScleanupmergepublisher', 0,1)
go
--
-- Name: sp_MScleanupmergepublisher
-- 
-- Description: This procedure currently performs the following function(s):
--              1) Cleans up all the stale dynamic snapshot views
--              in all databases enabled for merge replication. This 
--              procedure should normally be called at merge publisher startup.
--              
-- Notes: 1)This procedure is enabled as a startup procedure when a database is
--        enabled as a first merge publisher database on the server and it 
--        will be unmarked as a startup procedure when the last merge publisher
--        database is disabled.
--        2)Errors within the SP are mostly ignored.
--        3)This procedure can also be used by admins/securityadmins to perform
--        manual cleanup of all dynamic snapshot views. Note that cleaning up the 
--        dynamic snapshot views can disrupt dynamic snapshots that are being generated.
--        
-- Returns: (undefined)
--
-- Security: Only members of the sysadmin fixed server role can execute this
--           procedure successfully. So for this procedure to function proprely 
--           as a startup procedure, the MSSQLServer service account must be a 
--           member of the sysadmin role.
--
create procedure sp_MScleanupmergepublisher
as
begin
    set nocount on
    declare @status_mask int
    declare @published_mask int
    declare @published_database_name sysname
    declare @command nvarchar(4000)

    -- Masks off the databases with status that we don't want to deal with
    select @status_mask = 32 | -- loading
                          64 | -- pre recovery
                          128 | -- recovering
                          256 | -- not recovered
                          512 | -- offline
                          1024  -- read only

    select @published_mask = 4 -- Merge published

    declare hPublishedDatabase cursor local fast_forward for
        select name from sysdatabases 
         where (status & @status_mask) = 0
           and (category & @published_mask) <> 0

    open hPublishedDatabase

    fetch hPublishedDatabase into @published_database_name
    while  (@@fetch_status <> -1)
    begin

        select @command = 'use ' + QUOTENAME(@published_database_name) + '
' +                       'exec sp_MScleanupmergepublisherdb'


        exec (@command)
        -- Ignore errors
        fetch hPublishedDatabase into @published_database_name
    end

    close hPublishedDatabase
    deallocate hPublishedDatabase

end
go
exec sp_MS_marksystemobject sp_MScleanupmergepublisher
go

--
-- Name: sp_MScleanupdynsnapshotvws
--
-- Description: This procedure is used to drop all the views listed in the     
--              MSdynamicsnapshotviews table of the publisher database. It is 
--              typically called by the merge cleanup procedure 
--              (sp_MScleanupmergepublisherdb) during server startup although
--              the database administrator can choose to proactively call this
--              procedure manually to clean up any temporary dynamic snapshot
--              views left over from an abnormally terminated dynamic snapshot
--              generation session.
--
-- Parameter: (none) 
--                 
-- Notes: Calling this procedure while a dynamic snapshot is being generated 
--        will probably disrupt the said dynamic snapshot generation session.
-- 
-- Returns: 0 - succeeded
--          1 - failed
-- 
-- Result: none
--
-- Security: Execute permission of this procedure is granted to public. 
--           Internally, this procedure will call sp_MSreplcheck_publish
--           to make sure that the caller is either server sysadmin or dbo 
--           of the publishing database
--              
raiserror('Creating procedure sp_MScleanupdynsnapshotvws', 0,1)
go
create procedure sp_MScleanupdynsnapshotvws
as
begin
    set nocount on    
    declare @retcode int
    select @retcode = 0
    
    -- Security check
    exec @retcode = sp_MSreplcheck_publish
    if @@error<>0 or @retcode<>0
    begin
        return 1
    end

    -- Do nothing if the MSdynamicsnapshotviews table does not exist
    if exists (select * from sysobjects where name = N'MSdynamicsnapshotviews')
    begin
        declare @dynamic_snapshot_view_name sysname
        declare @drop_view_command nvarchar(4000) 

        declare hViews cursor local fast_forward for
         select dynamic_snapshot_view_name
           from MSdynamicsnapshotviews
        if @@error<>0
        begin
            goto Failure
        end
        
        open hViews
        if @@error<>0
        begin
           goto Failure
        end
    
        fetch hViews into @dynamic_snapshot_view_name
        while (@@fetch_status<>-1)
        begin
            select @drop_view_command = 'drop view ' + 
                quotename(@dynamic_snapshot_view_name)
            exec(@drop_view_command)
            if @@error<>0
            begin
                select @retcode = 1 -- Just to indicate that a failure occurred
            end        
            delete from MSdynamicsnapshotviews
             where dynamic_snapshot_view_name = @dynamic_snapshot_view_name
            if @@error<>0
            begin
                select @retcode = 1 -- Just to indicate that a failure occurred
            end        
            fetch hViews into @dynamic_snapshot_view_name
        end
    end
    return @retcode
Failure:
    return 1
end
go
exec sp_MS_marksystemobject 'sp_MScleanupdynsnapshotvws'
go
raiserror('Creating procedure sp_MScleanupmergepublisherdb',0,1)
go
--
-- Name: sp_MScleanupmergepublisherdb
--
-- Description: This procedure is the per-database analogue of 
--              sp_MScleanupmergepublisher and it currently performs the 
--              following function(s):
--              1) Cleans up all the stale dynamic snapshot views
--              in the current database.
--
-- Returns: (undefined)
--
-- Security: Only members of the sysadmin fixed server role can execute this
--           procedure.
--
create procedure sp_MScleanupmergepublisherdb
as
begin
    set nocount on
    declare @temp_login sysname

    if exists (select * from sysobjects
        where name = 'MSdynamicsnapshotviews')
    begin
        -- Ignore errors
        exec sp_MScleanupdynsnapshotvws
    end

end
go
exec sp_MS_marksystemobject sp_MScleanupmergepublisherdb 
go

raiserror('Creating procedure sp_MShelp_replication_table',0,1)
go
--
-- Name: sp_MShelp_replication_table
--
-- Description: This procedure is used by DMO to get tables can be published and
--				their properties
--
-- Returns: error code
--
-- Security: public
--
CREATE PROCEDURE sp_MShelp_replication_table (
    @table_name sysname = NULL,
    @table_owner sysname = NULL
    ) 
AS

SET NOCOUNT ON

declare @objid int

if @table_name is not null
begin
	if @table_owner is NULL
		select @table_owner = user_name()
	declare @qualified_table_name	nvarchar(260)
	select @qualified_table_name = QUOTENAME(@table_owner) + '.' + QUOTENAME(@table_name)
	select @objid = object_id(@qualified_table_name)
	if @objid is null
	begin
		RAISERROR (14027, 11, -1, @qualified_table_name)
		return(1)
	end
end

create table #merge_objects (objid int primary key)

create table #queued_tran_objects (objid int primary key)

if object_id('sysmergearticles') is not null
	insert into #merge_objects select distinct objid from sysmergearticles where 
		objid = @objid or @objid is null

if object_id('sysarticles') is not null
	insert into #queued_tran_objects select distinct objid from sysarticles a,
		syspublications p where 
		(objid = @objid or @objid is null) and 
		a.pubid = p.pubid and
		p.allow_queued_tran = 1

select	'table name' = o.name, 
		'table owner' = user_name(o.uid), 
		'ID' = o.id, 
		'Category' = o.category,
		'HasGuidColumn' = case when 
				exists (select * from syscolumns c where c.id = o.id and
				xtype = (select xtype from systypes where name = 'uniqueidentifier')) 
			then cast(1 as bit) 
			else cast(0 as bit)
			end,
		'HasTimeStampColumn' = ObjectProperty(o.id, 'TableHasTimestamp'),
		'HasRowVersionColumn' = case when 
				exists (select * from syscolumns c where c.id = o.id and 
				name = N'msrepl_tran_version')
			then cast(1 as bit) 
			else cast(0 as bit)
			end,
		'HasIdentityColumn' = ObjectProperty(o.id, 'TableHasIdentity'),
		'HasSQLVariantColumn' = case when 
				exists (select * from syscolumns c where c.id = o.id and
				xtype = (select xtype from systypes where name = 'sql_variant')) 
			then cast(1 as bit) 
			else cast(0 as bit)
			end,
		'HasBigIntColumn' = case when 
				exists (select * from syscolumns c where c.id = o.id and
				xtype = (select xtype from systypes where name = 'bigint'))
			then cast(1 as bit) 
			else cast(0 as bit)
			end,
		'HasBigIntIdentityColumn' = case when 
				exists (select * from syscolumns c where c.id = o.id and
				ColumnProperty(o.id, c.name, 'IsIdentity') = 1 and
				xtype = (select xtype from systypes where name = 'bigint'))
			then cast(1 as bit) 
			else cast(0 as bit)
			end,
		'MergePublished' = case when exists (select * from #merge_objects m where
			m.objid = o.id)
			then cast(1 as bit) 
			else cast(0 as bit)
			end,
		'QueuedTranPublished' = case when exists (select * from #queued_tran_objects m where
			m.objid = o.id)
			then cast(1 as bit) 
			else cast(0 as bit)
			end,
		'HasIdentityNotForReplColumn' = case when 
				exists (select * from syscolumns c where c.id = o.id and 
					ColumnProperty(o.id, c.name, 'IsIdNotForRepl') = 1)
			then cast(1 as bit) 
			else cast(0 as bit)
			end

		from sysobjects o where o.xtype = 'U' and 
			ObjectProperty(o.id, 'IsMSShipped') = 0 and
			(o.id = @objid or @objid is null)
			order by 1, 2
			
drop table #merge_objects
drop table #queued_tran_objects
go
exec sp_MS_marksystemobject sp_MShelp_replication_table
grant execute on dbo.sp_MShelp_replication_table to public
go
create proc sp_MScopyscriptfile (
	@scriptfile nvarchar(4000), 
	@cmd nvarchar(4000) OUTPUT
)
as
declare @directory nvarchar(4000)
declare @filename nvarchar(1024)
declare @subdirectory nvarchar(1024)
declare @retcode int

IF @scriptfile IS NULL
BEGIN
	RAISERROR (14043, 16, -1, '@scriptfile')
	RETURN (1)
END
-- Create the directory on distributor to store script.
exec sp_helpdistributor @directory=@directory OUTPUT
select @subdirectory = convert(nvarchar(64), GetDate(), 121)
select @subdirectory = replace(@subdirectory, N'-', N'')
select @subdirectory = replace(@subdirectory, N' ', N'')
select @subdirectory = replace(@subdirectory, N':', N'')
select @subdirectory = replace(@subdirectory, N'.', N'')
if(right(@directory, 1) = N'\')
	select @directory = @directory + @subdirectory
else
	select @directory = @directory + N'\' + @subdirectory
select @cmd = N'md "' + fn_escapecmdshellsymbolsremovequotes(@directory) collate database_default + '"'
exec @retcode = master..xp_cmdshell @cmd, NO_OUTPUT
if(@retcode <> 0)
begin
	raiserror(21330, 16, -1, @cmd)
	return (1)
end

-- Copy script to distributor
select @cmd = N'copy "' + fn_escapecmdshellsymbolsremovequotes(@scriptfile) collate database_default + N'" "' + fn_escapecmdshellsymbolsremovequotes(@directory) collate database_default + N'"'
exec @retcode = master..xp_cmdshell @cmd, NO_OUTPUT
if(@retcode <> 0)
begin 
	raiserror(21331, 16, -1, @cmd)
	return (1)
end

-- Prepare command, to be posted to log
select @filename = right(@scriptfile, charindex(N'\', reverse(@scriptfile)))
if(left(@filename, 1) = N'\')	
	select @cmd = @directory + @filename
else
	select @cmd = @directory + N'\' + @filename
go
exec sp_MS_marksystemobject sp_MScopyscriptfile
go
--
-- Name:    
--          sp_replsetoriginator
--          
-- Description: 
--          wrapper for sp_replsetoriginator_internal with DBO check
--  
-- Security: 
--          DBO only
--
-- Returns:  	0 : success
--		1 : failure          
--      
-- Owner:   
--          qunguo
--
--
raiserror('Creating procedure sp_replsetoriginator',0,1)
go
create proc sp_replsetoriginator (
	@originator_srv sysname, 
	@originator_db sysname
)
as
	declare @retcode int
	/*
    	** Security Check, this proc is only called by distrib.exe, against sub db as DBO
    	*/
    	exec @retcode = dbo.sp_MSreplcheck_subscribe
    	if @@ERROR <> 0 or @retcode <> 0
	begin
        	return(1)
	end

    	exec @retcode = dbo.sp_replsetoriginator_internal @originator_srv, @originator_db
    	if @@ERROR <> 0 or @retcode <> 0
	begin
        	return(1)
	end

	return 0
go
exec sp_MS_marksystemobject sp_replsetoriginator
go
--
-- Name:    
--          sp_replsetoriginator_pal
--          
-- Description: 
--          wrapper for sp_replsetoriginator_internal with pull access check
--  
-- Security: 
--          DBO or PAL access
--
-- Returns:  	0 : success
--		1 : failure          
--      
-- Owner:   
--          qunguo
--
--
raiserror('Creating procedure sp_replsetoriginator_pal',0,1)
go
create proc sp_replsetoriginator_pal (
	@originator_srv sysname, 
	@originator_db sysname,
	@publication sysname
)
as
	declare @retcode int
	/*
    	** Security Check, this is called by updatable subscriber in sync-tran proc, hence PAL access
    	*/
	exec @retcode = dbo.sp_MSreplcheck_pull @publication = @publication
	if @@error <> 0 or @retcode <> 0
	begin
		return (1)
	end

    	exec @retcode = dbo.sp_replsetoriginator_internal @originator_srv, @originator_db
    	if @@ERROR <> 0 or @retcode <> 0
	begin
        	return(1)
	end

	return 0
go
exec sp_MS_marksystemobject sp_replsetoriginator_pal
go
--
-- Name:    
--          sp_replincrementlsn
--          
-- Description: 
--          wrapper for sp_replincrementlsn_internal with DBO check
--  
-- Security: 
--          DBO only
--
-- Returns:  	0 : success
--		1 : failure          
--      
-- Owner:   
--          qunguo
--
--
raiserror('Creating procedure sp_replincrementlsn',0,1)
go
create proc sp_replincrementlsn (
	@xact_seqno binary(10) OUTPUT
)
as
	declare @retcode int
	/*
    	** Security Check, this proc is called by snapshot agent or sp_repladd(drop)column, against pub db as DBO
    	*/
    	exec @retcode = dbo.sp_MSreplcheck_publish
    	if @@ERROR <> 0 or @retcode <> 0
	begin
        	return(1)
	end

    	exec @retcode = dbo.sp_replincrementlsn_internal @xact_seqno OUTPUT
    	if @@ERROR <> 0 or @retcode <> 0
	begin
        	return(1)
	end

	return 0
go
exec sp_MS_marksystemobject sp_replincrementlsn
go
--
-- Name:    
--          sp_replpostsyncstatus
--          
-- Description: 
--          wrapper for sp_replpostsyncstatus_int with DBO check
--  
-- Security: 
--          DBO only
--
-- Returns:  	0 : success
--		1 : failure          
--      
-- Owner:   
--          qunguo
--
--
raiserror('Creating procedure sp_replpostsyncstatus',0,1)
go
create proc sp_replpostsyncstatus (
	@pubid int, 
	@artid int, 
	@syncstat int, 
	@xact_seqno binary(10) OUTPUT
)
as
	declare @retcode int
	/*
    	** Security Check, this proc is called by snapshot agent as DBO on publisher
    	*/
    	exec @retcode = dbo.sp_MSreplcheck_publish
    	if @@ERROR <> 0 or @retcode <> 0
	begin
        	return(1)
	end

    	exec @retcode = dbo.sp_replpostsyncstatus_int @pubid, @artid, @syncstat, @xact_seqno OUTPUT
    	if @@ERROR <> 0 or @retcode <> 0
	begin
        	return(1)
	end

	return 0
go
exec sp_MS_marksystemobject sp_replpostsyncstatus
go
/*
** Add extended stored procedures for replication support.
*/
sp_addextendedproc  'sp_repldone', 'repldone extended procedure'
go

sp_addextendedproc  'sp_repltrans', 'repltrans extended procedure'
go

sp_addextendedproc  'sp_replcounters', 'replcounters extended procedure'
go

sp_addextendedproc  'sp_replcmds', 'replcmds extended procedure'
go

sp_addextendedproc  'sp_replflush', 'replflush extended procedure'
go

dump tran master with no_log
go

sp_addextendedproc  'sp_replpostcmd', 'replpostcmd extended procedure'
go
sp_addextendedproc  'sp_replpostschema', 'replpostschema extended procedure'
go

sp_addextendedproc  'sp_replincrementlsn_internal', 'replincrementlsn extended procedure'
go

sp_addextendedproc  'sp_replupdateschema', 'replupdateschema extended procedure'
go

sp_addextendedproc  'sp_replsetoriginator_internal', 'replsetoriginator extended procedure'
go

sp_addextendedproc  'sp_replsetsyncstatus', 'replsetsyncstatus extended procedure'
go

sp_addextendedproc  'sp_replpostsyncstatus_int', 'replpostsyncstatus_int extended procedure'
go

/*
** Add xp_enum_dsn extended procedure
*/
sp_addextendedproc 'xp_dsninfo','xpstar.dll'
go
exec dbo.sp_MS_marksystemobject xp_dsninfo
go

/*
** Add xp_enum_dsn extended procedure
*/
sp_addextendedproc 'xp_enumdsn','xpstar.dll'
go
exec dbo.sp_MS_marksystemobject xp_enumdsn
go

/*
** Add xp_oledbinfo extended procedure
*/
sp_addextendedproc 'xp_oledbinfo','xprepl.dll'
go
exec dbo.sp_MS_marksystemobject xp_oledbinfo
go

/*
** Add xp_repl_encrypt extended procedure
*/
sp_addextendedproc 'xp_repl_encrypt','xprepl.dll'
go
exec dbo.sp_MS_marksystemobject xp_repl_encrypt
go


/*
** Add xp_repl_convert_encrypt extended procedure
*/
sp_addextendedproc 'xp_repl_convert_encrypt','xprepl.dll'
go
exec dbo.sp_MS_marksystemobject xp_repl_convert_encrypt
go



/*
** Add xp_repl_convert_encrypt extended procedure
*/
sp_addextendedproc 'xp_repl_help_connect','xprepl.dll'
go
exec dbo.sp_MS_marksystemobject xp_repl_help_connect
go



/*
** Add xp_replproberemsrv extended procedure
*/
sp_addextendedproc 'xp_replproberemsrv','xprepl.dll'
go
exec dbo.sp_MS_marksystemobject xp_replproberemsrv
go

dump tran master with no_log
go

grant execute on dbo.sp_addpublication_snapshot to public
go
grant execute on dbo.sp_MShelpobjectpublications to public
go
grant execute on dbo.sp_helpreplicationdb to public
go
grant execute on dbo.sp_enumdsn to public
go
grant execute on dbo.sp_helpsubscriberinfo to public
go
grant execute on dbo.sp_replica to public
go
grant execute on dbo.sp_distcounters to public
go
grant execute on dbo.sp_helpdistributor to public
go
grant execute on dbo.sp_helpdistributiondb to public
go
grant execute on dbo.sp_helpdistpublisher to public
go
grant execute on dbo.sp_replcounters to public
go
grant execute on dbo.sp_MShelp_distdb to public
go
grant execute on dbo.sp_grant_publication_access to public
go
grant execute on dbo.sp_revoke_publication_access to public
go
grant execute on dbo.sp_help_publication_access to public
go
grant execute on dbo.sp_check_publication_access to public
go
grant execute on dbo.sp_replsetoriginator to public
go
grant execute on dbo.sp_replsetoriginator_pal to public
go


GRANT EXECUTE ON dbo.sp_MShelpconflictpublications TO PUBLIC
GO

grant execute on dbo.sp_repldone to public
go
grant execute on dbo.sp_repltrans to public
go
grant execute on dbo.sp_replcounters to public
go
grant execute on dbo.sp_replcmds to public
go
grant execute on dbo.sp_replpostschema to public
go
grant execute on dbo.sp_replincrementlsn to public
go
grant execute on dbo.sp_replsetsyncstatus to public
go
grant execute on dbo.sp_replpostsyncstatus to public
go
grant execute on sp_MSenum_replication_job to public
go
grant execute on sp_MSrepl_gettype_mappings to public
go
grant execute on sp_MShelp_replication_status to public
grant execute on sp_MSenum_replication_agents to public
-- proc need to be granted to public for replmonitor role
grant execute on sp_help_agent_default to public
grant execute on sp_help_agent_profile to public
grant execute on sp_help_agent_parameter to public
grant execute on sp_helpdistributor_properties to public
grant execute on sp_MScleanupdynsnapshotvws to public
grant execute on sp_MSget_agent_names to public
go


dump tran master with no_log
go



dump tran master with no_log
go
sp_configure 'allow updates',0
go
reconfigure with override
go

print ''
print 'Checking objects created by replcom.sql.'
go
--obsolete   exec dbo.sp_check_objects 'repl'
exec dbo.sp_MS_upd_sysobj_category 2  --set sysobjects.category | 2 based on crdate.
go

print ''
print 'replcom.sql completed successfully.'
go

dump tran master with no_log
go
checkpoint
go
-- - -----
