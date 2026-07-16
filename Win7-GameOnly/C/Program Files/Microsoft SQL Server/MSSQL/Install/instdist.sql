/*
** InstDist.SQL   
**
**
** Copyright Microsoft, Inc. 1998-2000
** All Rights Reserved.
*/


if (    (db_id()     = 1)  -- 'master' db
    OR
        is_srvrolemember('sysadmin') <> 1  -- SA
   )
    begin
    raiserror('Error, the ''master'' database cannot be the distribution database.  This ISQL run will terminate now.'
                 ,11,127)  -- State=127 should halt ISQL.EXE
    end

if (    (db_id()     = 1)  -- 'master' db
    OR
        is_srvrolemember('sysadmin') <> 1 -- SA
   )
    begin
    raiserror('Minor error, because previous attempt to gently terminate ISQL failed.  Harshly killing spid.'
                 ,22,127) with log   -- SeverityLevel>=19 kills spid.
    end
select 'At top, db_name()=',db_name()

go


declare @dbname sysname
select  @dbname = db_name()
execute('dump transaction ' +@dbname+ ' with no_log')
go
checkpoint

go
EXEC dbo.sp_configure 'allow updates', 1
GO
reconfigure with override
GO

set ANSI_NULLS off
go

--
-- Check and make sure the database has the correct compatibility level
--
declare @dbname sysname
		,@cmptlevelmaster tinyint
		,@cmptlevel tinyint
		
select  @dbname = db_name()
select 	@cmptlevelmaster = cmptlevel from master.dbo.sysdatabases where name = 'master'
select 	@cmptlevel = cmptlevel from master.dbo.sysdatabases where name = @dbname
if (@cmptlevel != @cmptlevelmaster)
begin
	raiserror('Warning: Distribution database ''%s'' has compatibility level of %d. Changing it to %d.'
		,10, 1, @dbname, @cmptlevel, @cmptlevelmaster)
	exec dbo.sp_dbcmptlevel @dbname, @cmptlevelmaster
end
go

/****************************************************************************/
PRINT ''
PRINT 'Creating distribution tables'
PRINT ''
/****************************************************************************/
EXEC dbo.sp_MScreate_dist_tables
go

declare @dbname sysname
select  @dbname = db_name()
execute('dump transaction ' +@dbname+ ' with no_log')
go

exec dbo.sp_MS_upd_sysobj_category 1  --Capture now_datetime for use below.

/****************************************************************************/
PRINT ''
PRINT 'Dropping all distribution stored procedures'
PRINT ''
/****************************************************************************/
IF EXISTS (SELECT * FROM sysobjects WHERE
   name = 'sp_MSadd_repl_command' and type = 'P')
      DROP PROCEDURE sp_MSadd_repl_command

IF EXISTS (SELECT * FROM sysobjects WHERE
   name = 'sp_MScheckretention' and type = 'P')
      DROP PROCEDURE sp_MScheckretention

IF EXISTS (SELECT * FROM sysobjects WHERE
   name = 'sp_MScheck_Jet_Subscriber' and type = 'P')
      DROP PROCEDURE sp_MScheck_Jet_Subscriber

IF EXISTS (SELECT * FROM sysobjects WHERE
   name = 'sp_MSadd_repl_commands27' and type = 'P')
      DROP PROCEDURE sp_MSadd_repl_commands27

IF EXISTS (SELECT * FROM sysobjects WHERE
   name = 'sp_MSadd_repl_commands27hp' and type = 'P')
      DROP PROCEDURE sp_MSadd_repl_commands27hp

IF EXISTS (SELECT * FROM sysobjects WHERE
   name = 'sp_MSadd_repl_commands27hp_mcit' and type = 'P')
      DROP PROCEDURE sp_MSadd_repl_commands27hp_mcit

IF EXISTS (SELECT * FROM sysobjects WHERE
   name = 'sp_MSadd_repl_commands27hp6x' and type = 'P')
      DROP PROCEDURE sp_MSadd_repl_commands27hp6x

IF EXISTS (SELECT * FROM sysobjects WHERE
   name = 'sp_MSrefresh_anonymous' and type = 'P')
      DROP PROCEDURE sp_MSrefresh_anonymous
      
IF EXISTS (SELECT * FROM sysobjects WHERE
   name = 'sp_MSadd_subscription' and type = 'P')
      DROP PROCEDURE sp_MSadd_subscription

IF EXISTS (SELECT * FROM sysobjects WHERE                    
   name = 'sp_MSdrop_subscription' and type = 'P')
      DROP PROCEDURE sp_MSdrop_subscription

if exists (select * from sysobjects where 
	type = 'P' and name = 'sp_MSfetchAdjustidentityrange')
	drop procedure sp_MSfetchAdjustidentityrange

IF EXISTS (SELECT * FROM sysobjects WHERE   
    name = 'sp_MSupdate_subscription' and type = 'P')
       DROP PROCEDURE sp_MSupdate_subscription

IF EXISTS (SELECT * FROM sysobjects WHERE
    name = 'sp_MSget_repl_commands' and type = 'P')
       DROP PROCEDURE sp_MSget_repl_commands

IF EXISTS (SELECT * FROM sysobjects WHERE
    name = 'sp_MSget_repl_cmds_anonymous' and type = 'P')
       DROP PROCEDURE sp_MSget_repl_cmds_anonymous

IF EXISTS (select * from sysobjects where
   name = 'sp_MSdrop_agent_entry' and type = 'P')
      DROP PROCEDURE sp_MSdrop_agent_entry
      
IF EXISTS (SELECT * FROM sysobjects WHERE
    name = 'sp_MSadd_anonymous_agent' and type = 'P')
       DROP PROCEDURE sp_MSadd_anonymous_agent

-- SyncTran


IF EXISTS (SELECT * FROM sysobjects WHERE
    name = 'sp_MSget_undelivered_commands' and type = 'P')
       DROP PROCEDURE sp_MSget_undelivered_commands

IF EXISTS (SELECT * FROM sysobjects WHERE
    name = 'sp_MSget_anonymous_cmds' and type = 'P')
       DROP PROCEDURE sp_MSget_anonymous_cmds

IF EXISTS (SELECT * FROM sysobjects WHERE
    name = 'sp_MSget_loopback_cmds' and type = 'P')
       DROP PROCEDURE sp_MSget_loopback_cmds

IF EXISTS (SELECT * FROM sysobjects WHERE
    name = 'sp_MSanonymous_status' and type = 'P')
       DROP PROCEDURE sp_MSanonymous_status

IF EXISTS (SELECT * FROM sysobjects WHERE
    name = 'sp_MSsubscription_status' and type = 'P')
       DROP PROCEDURE sp_MSsubscription_status
GO    

declare @dbname sysname
select  @dbname = db_name()
execute('dump transaction ' +@dbname+ ' with no_log')

go

IF EXISTS (SELECT * FROM sysobjects WHERE
   name = 'sp_MSget_last_transaction' and type = 'P')
      DROP PROCEDURE sp_MSget_last_transaction
    

IF EXISTS (SELECT * FROM sysobjects WHERE
   name = 'sp_MSadd_subscriber_info' and type = 'P')
      DROP PROCEDURE sp_MSadd_subscriber_info

IF EXISTS (SELECT * FROM sysobjects WHERE
   name = 'sp_MSadd_subscriber_schedule' and type = 'P')
      DROP PROCEDURE sp_MSadd_subscriber_schedule

IF EXISTS (SELECT * FROM sysobjects WHERE
   name = 'sp_MSupdate_subscriber_info' and type = 'P')
      DROP PROCEDURE sp_MSupdate_subscriber_info

IF EXISTS (SELECT * FROM sysobjects WHERE
   name = 'sp_MSupdate_subscriber_schedule' and type = 'P')
      DROP PROCEDURE sp_MSupdate_subscriber_schedule

IF EXISTS (SELECT * FROM sysobjects WHERE
   name = 'sp_MSdrop_subscriber_info' and type = 'P')
      DROP PROCEDURE sp_MSdrop_subscriber_info

IF EXISTS (SELECT * FROM sysobjects WHERE
   name = 'sp_MShelp_subscriber_info' and type = 'P')
      DROP PROCEDURE sp_MShelp_subscriber_info

IF EXISTS (select * from sysobjects where
   name = 'sp_MSdistribution_counters' and type = 'P')
      DROP PROCEDURE sp_MSdistribution_counters

IF EXISTS (select * from sysobjects where
   name = 'sp_MSremove_published_jobs' and type = 'P')
      DROP PROCEDURE sp_MSremove_published_jobs

IF EXISTS (select * from sysobjects where
   name = 'sp_MSset_snapshot_xact_seqno' and type = 'P')
      DROP PROCEDURE sp_MSset_snapshot_xact_seqno

IF EXISTS (select * from sysobjects where
   name = 'sp_MSadd_snapshot_history' and type = 'P')
      DROP PROCEDURE sp_MSadd_snapshot_history

IF EXISTS (select * from sysobjects where
   name = 'sp_MSadd_logreader_history' and type = 'P')
      DROP PROCEDURE sp_MSadd_logreader_history

IF EXISTS (select * from sysobjects where
   name = 'sp_MSadd_distribution_history' and type = 'P')
      DROP PROCEDURE sp_MSadd_distribution_history

IF EXISTS (select * from sysobjects where
   name = 'sp_MSdistribution_cleanup' and type = 'P')
      DROP PROCEDURE sp_MSdistribution_cleanup

IF EXISTS (select * from sysobjects where
   name = 'sp_MSsubscription_cleanup' and type = 'P')
      DROP PROCEDURE sp_MSsubscription_cleanup

IF EXISTS (select * from sysobjects where
   name = 'sp_MSdistribution_delete' and type = 'P')
      DROP PROCEDURE sp_MSdistribution_delete

IF EXISTS (select * from sysobjects where
   name = 'sp_MSmaximum_cleanup_seqno' and type = 'P')
      DROP PROCEDURE sp_MSmaximum_cleanup_seqno

IF EXISTS (select * from sysobjects where
   name = 'sp_MSreplremoveuncdir' and type = 'P')
      DROP PROCEDURE sp_MSreplremoveuncdir

IF EXISTS (select * from sysobjects where
   name = 'sp_MSdrop_snapshot_dirs' and type = 'P')
      DROP PROCEDURE sp_MSdrop_snapshot_dirs

IF EXISTS (select * from sysobjects where
   name = 'sp_MSfast_delete_trans' and type = 'P')
      DROP PROCEDURE sp_MSfast_delete_trans

IF EXISTS (select * from sysobjects where
   name = 'sp_MSdelete_dodelete' and type = 'P')
      DROP PROCEDURE sp_MSdelete_dodelete

IF EXISTS (select * from sysobjects where
   name = 'sp_MSdelete_publisherdb_trans' and type = 'P')
      DROP PROCEDURE sp_MSdelete_publisherdb_trans

IF EXISTS (select * from sysobjects where
   name = 'sp_MShistory_cleanup' and type = 'P')
      DROP PROCEDURE sp_MShistory_cleanup

IF EXISTS (select * from sysobjects where
   name = 'sp_MSget_repl_version' and type = 'P')
      DROP PROCEDURE sp_MSget_repl_version

IF EXISTS (select * from sysobjects where
   name = 'sp_MSenum_subscriptions' and type = 'P')
      DROP PROCEDURE sp_MSenum_subscriptions

IF EXISTS (select * from sysobjects where
   name = 'sp_MSIfExistsSubscription' and type = 'P')
      DROP PROCEDURE sp_MSIfExistsSubscription

IF EXISTS (select * from sysobjects where
   name = 'sp_MSenum_snapshot' and type = 'P')
      DROP PROCEDURE sp_MSenum_snapshot
      
IF EXISTS (select * from sysobjects where
   name = 'sp_MSadd_merge_anonymous_agent' and type = 'P')
      DROP PROCEDURE sp_MSadd_merge_anonymous_agent
    
IF EXISTS (select * from sysobjects where
   name = 'sp_MSenum_snapshot_s' and type = 'P')
      DROP PROCEDURE sp_MSenum_snapshot_s

IF EXISTS (select * from sysobjects where
   name = 'sp_MSenum_snapshot_sd' and type = 'P')
      DROP PROCEDURE sp_MSenum_snapshot_sd

IF EXISTS (select * from sysobjects where
   name = 'sp_MSenum_logreader' and type = 'P')
      DROP PROCEDURE sp_MSenum_logreader

IF EXISTS (select * from sysobjects where
   name = 'sp_MSenum_logreader_s' and type = 'P')
      DROP PROCEDURE sp_MSenum_logreader_s

IF EXISTS (select * from sysobjects where
   name = 'sp_MSenum_logreader_sd' and type = 'P')
      DROP PROCEDURE sp_MSenum_logreader_sd

IF EXISTS (select * from sysobjects where
   name = 'sp_MSenum_qreader' and type = 'P')
      DROP PROCEDURE sp_MSenum_qreader

IF EXISTS (select * from sysobjects where
   name = 'sp_MSenum_qreader_s' and type = 'P')
      DROP PROCEDURE sp_MSenum_qreader_s

IF EXISTS (select * from sysobjects where
   name = 'sp_MSenum_qreader_sd' and type = 'P')
      DROP PROCEDURE sp_MSenum_qreader_sd

IF EXISTS (select * from sysobjects where
   name = 'sp_MSenum_distribution' and type = 'P')
      DROP PROCEDURE sp_MSenum_distribution

IF EXISTS (select * from sysobjects where
   name = 'sp_MSenum_distribution_s' and type = 'P')
      DROP PROCEDURE sp_MSenum_distribution_s

IF EXISTS (SELECT * FROM sysobjects WHERE
   name = 'sp_MShelp_subscription_status' and type = 'P')
      DROP PROCEDURE sp_MShelp_subscription_status

IF EXISTS (SELECT * FROM sysobjects WHERE
   name = 'sp_MScleanup_agent_entry' and type = 'P')
      DROP PROCEDURE sp_MScleanup_agent_entry

IF EXISTS (select * from sysobjects where
   name = 'sp_MSenum_distribution_sd' and type = 'P')
      DROP PROCEDURE sp_MSenum_distribution_sd

IF EXISTS (select * from sysobjects where
   name = 'sp_MSenum_merge' and type = 'P')
      DROP PROCEDURE sp_MSenum_merge

IF EXISTS (select * from sysobjects where
   name = 'sp_MSenum_merge_s' and type = 'P')
      DROP PROCEDURE sp_MSenum_merge_s

IF EXISTS (select * from sysobjects where
   name = 'sp_MSenum_merge_sd' and type = 'P')
      DROP PROCEDURE sp_MSenum_merge_sd

IF EXISTS (select * from sysobjects where
   name = 'sp_MSgetagentoffloadinfo' and type = 'P')
      DROP PROCEDURE sp_MSgetagentoffloadinfo

IF EXISTS (select * from sysobjects where
   name = 'sp_MSenableagentoffload' and type = 'P')
      DROP PROCEDURE sp_MSenableagentoffload

IF EXISTS (select * from sysobjects where
   name = 'sp_MSdisableagentoffload' and type = 'P')
      DROP PROCEDURE sp_MSdisableagentoffload 

IF EXISTS (select * from sysobjects where
   name = 'sp_MSadd_repl_error' and type = 'P')
      DROP PROCEDURE sp_MSadd_repl_error

IF EXISTS (select * from sysobjects where
   name = 'sp_MSadd_repl_alert' and type = 'P')
      DROP PROCEDURE sp_MSadd_repl_alert

IF EXISTS (select * from sysobjects where
   name = 'sp_MSadd_replmergealert' and type = 'P')
      DROP PROCEDURE sp_MSadd_replmergealert

IF EXISTS (select * from sysobjects where
   name = 'sp_MSget_new_errorid' and type = 'P')
      DROP PROCEDURE sp_MSget_new_errorid

IF EXISTS (select * from sysobjects where
   name = 'sp_MSget_repl_error' and type = 'P')
      DROP PROCEDURE sp_MSget_repl_error

IF EXISTS (select * from sysobjects where
   name = 'sp_MSadd_merge_history' and type = 'P')
      DROP PROCEDURE sp_MSadd_merge_history

IF EXISTS (select * from sysobjects where
   name = 'sp_MSdist_activate_auto_sub' and type = 'P')
      DROP PROCEDURE sp_MSdist_activate_auto_sub

IF EXISTS (select * from sysobjects where
   name = 'sp_MSlock_auto_sub' and type = 'P')
      DROP PROCEDURE sp_MSlock_auto_sub

IF EXISTS (select * from sysobjects where
   name = 'sp_MSget_new_xact_seqno' and type = 'P')
      DROP PROCEDURE sp_MSget_new_xact_seqno

IF EXISTS (select * from sysobjects where
   name = 'sp_MSvalidate_distpublisher' and type = 'P')
      DROP PROCEDURE sp_MSvalidate_distpublisher

IF EXISTS (select * from sysobjects where
   name = 'sp_MSadd_publication' and type = 'P')
      DROP PROCEDURE sp_MSadd_publication

IF EXISTS (select * from sysobjects where
   name = 'sp_MSchange_publication' and type = 'P')
      DROP PROCEDURE sp_MSchange_publication

IF EXISTS (select * from sysobjects where
   name = 'sp_MSadd_article' and type = 'P')
      DROP PROCEDURE sp_MSadd_article

IF EXISTS (select * from sysobjects where
   name = 'sp_MSchange_article' and type = 'P')
      DROP PROCEDURE sp_MSchange_article

IF EXISTS (select * from sysobjects where
   name = 'sp_MSdrop_publication' and type = 'P')
      DROP PROCEDURE sp_MSdrop_publication

IF EXISTS (select * from sysobjects where
   name = 'sp_MSdrop_article' and type = 'P')
      DROP PROCEDURE sp_MSdrop_article

IF EXISTS (select * from sysobjects where
   name = 'sp_MShelp_publication' and type = 'P')
      DROP PROCEDURE sp_MShelp_publication

IF EXISTS (select * from sysobjects where
   name = 'sp_MShelp_article' and type = 'P')
      DROP PROCEDURE sp_MShelp_article

IF EXISTS (select * from sysobjects where
   name = 'sp_MShelp_subscription' and type = 'P')
      DROP PROCEDURE sp_MShelp_subscription

IF EXISTS (select * from sysobjects where
   name = 'sp_MSadd_subscription_3rd' and type = 'P')
      DROP PROCEDURE sp_MSadd_subscription_3rd

IF EXISTS (select * from sysobjects where
   name = 'sp_MSdrop_subscription_3rd' and type = 'P')
      DROP PROCEDURE sp_MSdrop_subscription_3rd

IF EXISTS (select * from sysobjects where
   name = 'sp_MSactivate_subscriptions' and type = 'P')
      DROP PROCEDURE sp_MSactivate_subscriptions

IF EXISTS (select * from sysobjects where
   name = 'sp_MSrepl_raiserror' and type = 'P')
      DROP PROCEDURE sp_MSrepl_raiserror

IF EXISTS (select * from sysobjects where
   name = 'sp_MSadd_merge_subscription' and type = 'P')
      DROP PROCEDURE sp_MSadd_merge_subscription

IF EXISTS (select * from sysobjects where
   name = 'sp_MSdrop_merge_subscription' and type = 'P')
      DROP PROCEDURE sp_MSdrop_merge_subscription

IF EXISTS (select * from sysobjects where
   name = 'sp_MSenum_merge_subscriptions' and type = 'P')
      DROP PROCEDURE sp_MSenum_merge_subscriptions

IF EXISTS (select * from sysobjects where
   name = 'sp_MSadd_snapshot_agent' and type = 'P')
      DROP PROCEDURE sp_MSadd_snapshot_agent

IF EXISTS (select * from sysobjects where
   name = 'sp_MSdrop_snapshot_agent' and type = 'P')
      DROP PROCEDURE sp_MSdrop_snapshot_agent

IF EXISTS (select * from sysobjects where
   name = 'sp_MSadd_logreader_agent' and type = 'P')
      DROP PROCEDURE sp_MSadd_logreader_agent

IF EXISTS (select * from sysobjects where
   name = 'sp_MSdrop_logreader_agent' and type = 'P')
      DROP PROCEDURE sp_MSdrop_logreader_agent

IF EXISTS (select * from sysobjects where
   name = 'sp_MSadd_distribution_agent' and type = 'P')
      DROP PROCEDURE sp_MSadd_distribution_agent

IF EXISTS (select * from sysobjects where
   name = 'sp_MSdrop_distribution_agent' and type = 'P')
      DROP PROCEDURE sp_MSdrop_distribution_agent

IF EXISTS (select * from sysobjects where
   name = 'sp_MSdrop_distribution_agentid' and type = 'P')
      DROP PROCEDURE sp_MSdrop_distribution_agentid

IF EXISTS (select * from sysobjects where
   name = 'sp_MSdrop_merge_agentid' and type = 'P')
      DROP PROCEDURE sp_MSdrop_merge_agentid

IF EXISTS (select * from sysobjects where
   name = 'sp_MSadd_merge_agent' and type = 'P')
      DROP PROCEDURE sp_MSadd_merge_agent

IF EXISTS (select * from sysobjects where
   name = 'sp_MSdrop_merge_agent' and type = 'P')
      DROP PROCEDURE sp_MSdrop_merge_agent

IF EXISTS (select * from sysobjects where
   name = 'sp_MSadd_qreader_agent' and type = 'P')
      DROP PROCEDURE sp_MSadd_qreader_agent

IF EXISTS (select * from sysobjects where
   name = 'sp_MSadd_qreader_history' and type = 'P')
      DROP PROCEDURE sp_MSadd_qreader_history

IF EXISTS (select * from sysobjects where
   name = 'sp_MSdrop_qreader_agent' and type = 'P')
      DROP PROCEDURE sp_MSdrop_qreader_agent

IF EXISTS (select * from sysobjects where
   name = 'sp_MSdrop_qreader_history' and type = 'P')
      DROP PROCEDURE sp_MSdrop_qreader_history

IF EXISTS (select name from sysobjects where 
   name = 'sp_update_agent_profile' and type = 'P')
    DROP PROCEDURE sp_update_agent_profile

IF EXISTS (select name from sysobjects where 
   name = 'sp_MSprofile_in_use' and type = 'P')
    DROP PROCEDURE sp_MSprofile_in_use

IF EXISTS (select * from sysobjects where
   name = 'sp_MSreset_subscription' and type = 'P')
      DROP PROCEDURE sp_MSreset_subscription

IF EXISTS (select * from sysobjects where
   name = 'sp_MSget_subscription_guid' and type = 'P')
      DROP PROCEDURE sp_MSget_subscription_guid

IF EXISTS (select * from sysobjects where
   name = 'sp_MSreset_subscription_seqno' and type = 'P')
      DROP PROCEDURE sp_MSreset_subscription_seqno

IF EXISTS (select * from sysobjects where
   name = 'sp_MShelp_profile' and type = 'P')
      DROP PROCEDURE sp_MShelp_profile

IF EXISTS (select * from sysobjects where
   name = 'sp_MShelp_snapshot_agentid' and type = 'P')
      DROP PROCEDURE sp_MShelp_snapshot_agentid

IF EXISTS (select * from sysobjects where
   name = 'sp_MShelp_logreader_agentid' and type = 'P')
      DROP PROCEDURE sp_MShelp_logreader_agentid

IF EXISTS (select * from sysobjects where
   name = 'sp_MShelp_merge_agentid' and type = 'P')
      DROP PROCEDURE sp_MShelp_merge_agentid

IF EXISTS (select * from sysobjects where
   name = 'sp_MSenum_replication_status' and type = 'P')
      DROP PROCEDURE sp_MSenum_replication_status

IF EXISTS (select * from sysobjects where
   name = 'sp_MSagent_stethoscope' and type = 'P')
      DROP PROCEDURE sp_MSagent_stethoscope

IF EXISTS (select * from sysobjects where
   name = 'sp_MSlock_distribution_agent' and type = 'P')
      DROP PROCEDURE sp_MSlock_distribution_agent

IF EXISTS (select * from sysobjects where
   name = 'sp_MSenumerate_PAL' and type = 'P')
      DROP PROCEDURE sp_MSenumerate_PAL

IF EXISTS (select * from sysobjects where
   name = 'sp_MSdetect_nonlogged_shutdown' and type = 'P')
      DROP PROCEDURE sp_MSdetect_nonlogged_shutdown

IF EXISTS (select * from sysobjects where
   name = 'sp_MSdistpublisher_cleanup' and type = 'P')
      DROP PROCEDURE sp_MSdistpublisher_cleanup

IF EXISTS (select * from sysobjects where
   name = 'sp_MSpublication_access' and type = 'P')
      DROP PROCEDURE sp_MSpublication_access

IF EXISTS (select * from sysobjects where
   name = 'sp_MScheck_pull_access' and type = 'P')
      DROP PROCEDURE sp_MScheck_pull_access

GO
IF EXISTS (select * from sysobjects where
   name = 'sp_MSdrop_6x_publication' and type = 'P')
      DROP PROCEDURE sp_MSdrop_6x_publication

IF EXISTS (select * from sysobjects where
   name = 'sp_MShelp_distribution_agentid' and type = 'P')
      DROP PROCEDURE sp_MShelp_distribution_agentid
GO

IF EXISTS (select * from sysobjects where
   name = 'sp_MScheck_tran_retention' and type = 'P')
      DROP PROCEDURE sp_MScheck_tran_retention
GO

IF EXISTS (select * from sysobjects where
   name = 'sp_MSreinit_subscription' and type = 'P')
      DROP PROCEDURE sp_MSreinit_subscription
go

IF EXISTS (select * from sysobjects where
   name = 'sp_MSmarkreinit' and type = 'P')
      DROP PROCEDURE sp_MSmarkreinit
go

IF EXISTS (select * from sysobjects where
   name = 'sp_browsereplcmds' and type = 'P')
      DROP PROCEDURE sp_browsereplcmds
go

IF EXISTS (select * from sysobjects where
   name = 'sp_dumpparamcmd' and type = 'P')
      DROP PROCEDURE sp_dumpparamcmd
go

IF EXISTS (select * from sysobjects where
   name = 'sp_MSbrowsesnapshotfolder' and type = 'P')
      DROP PROCEDURE sp_MSbrowsesnapshotfolder
go

IF EXISTS (select * from sysobjects where
   name = 'sp_MSquery_syncstates' and type = 'P')
      DROP PROCEDURE sp_MSquery_syncstates
go

IF EXISTS (select * from sysobjects where
   name = 'sp_MSset_syncstate' and type = 'P')
      DROP PROCEDURE sp_MSset_syncstate

IF EXISTS (select * from sysobjects where
   name = 'sp_MSdist_adjust_identity' and type = 'P')
      DROP PROCEDURE sp_MSdist_adjust_identity

IF EXISTS (select * from sysobjects where
   name = 'sp_MSchange_subscription_dts_info' and type = 'P')
      DROP PROCEDURE sp_MSchange_subscription_dts_info

IF EXISTS (select * from sysobjects where
   name = 'sp_MSget_subscription_dts_info' and type = 'P')
      DROP PROCEDURE sp_MSget_subscription_dts_info
go

IF EXISTS (select * from sysobjects where
   name = 'sp_MSenumdistributionagentproperties' and type = 'P')
      DROP PROCEDURE sp_MSenumdistributionagentproperties

IF EXISTS (select * from sysobjects where
   name = 'sp_MSenum_merge_agent_properties' and type = 'P')
      DROP PROCEDURE sp_MSenum_merge_agent_properties

IF EXISTS (select * from sysobjects where
   name = 'sp_MSinsert_identity' and type = 'P')
      DROP PROCEDURE sp_MSinsert_identity

IF EXISTS (select * from sysobjects where
   name = 'sp_MSadjust_pub_identity' and type = 'P')
      DROP PROCEDURE sp_MSadjust_pub_identity    

IF EXISTS (select * from sysobjects where
   name = 'sp_MScheck_pub_identity' and type = 'P')
      DROP PROCEDURE sp_MScheck_pub_identity    

IF EXISTS (select * from sysobjects where
   name = 'sp_dropanonymoussubscription' and type = 'P')
      DROP PROCEDURE sp_dropanonymoussubscription

IF EXISTS (select * from sysobjects where
   name = 'sp_MSdrop_anonymous_entry' and type = 'P')
      DROP PROCEDURE sp_MSdrop_anonymous_entry

IF EXISTS (select * from sysobjects where
   name = 'sp_MSadddynamicsnapshotjobatdistributor' and type = 'P')
      DROP PROCEDURE sp_MSadddynamicsnapshotjobatdistributor

IF EXISTS (select * from sysobjects where
   name = 'sp_MSdeleterepljob' and type = 'P')
      DROP PROCEDURE sp_MSdeleterepljob

IF EXISTS (select * from sysobjects where
   name = 'sp_MSdeletefoldercontents' and type = 'P')
      DROP PROCEDURE sp_MSdeletefoldercontents

IF EXISTS (select * from sysobjects where
   name = 'sp_MSinvalidate_snapshot' and type = 'P')
      DROP PROCEDURE sp_MSinvalidate_snapshot

IF EXISTS (select * from sysobjects where
   name = 'sp_MSrepl_init_backup_lsns' and type = 'P')
      DROP PROCEDURE sp_MSrepl_init_backup_lsns

IF EXISTS (select * from sysobjects where
   name = 'sp_MSispublicationqueued' and type = 'P')
      DROP PROCEDURE sp_MSispublicationqueued

if exists (select * from sysobjects
     where type = 'FN'
            and name = 'fn_MSmask_agent_type')
     drop function dbo.fn_MSmask_agent_type

if exists (select * from sysobjects 
        where type = 'P' and
        name = 'sp_MSwritemergeperfcounter')
        drop procedure sp_MSwritemergeperfcounter

if exists (select * from sysobjects 
        where type = 'P' and
        name = 'sp_MSgetlasthistorytimestamp')
        drop procedure sp_MSgetlasthistorytimestamp

if exists (select * from sysobjects 
        where type = 'P' and
        name = 'sp_MSlog_agent_cancel')
        drop procedure sp_MSlog_agent_cancel

if exists ( select * from sysobjects
    where type = 'P '
        and name = 'sp_MSislogreaderjobnamegenerated')
    drop procedure dbo.sp_MSislogreaderjobnamegenerated

if exists ( select * from sysobjects
    where type = 'P '
        and name = 'sp_MSisqueuereaderjobnamegenerated')
    drop procedure dbo.sp_MSisqueuereaderjobnamegenerated

if exists ( select * from sysobjects 
    where type = 'P '
        and name = 'sp_MSissnapshotjobnamegenerated')
    drop procedure dbo.sp_MSissnapshotjobnamegenerated

if exists ( select * from sysobjects
    where type = 'P ' 
        and name = 'sp_MSisdistributionjobnamegenerated')
    drop procedure dbo.sp_MSisdistributionjobnamegenerated

if exists ( select * from sysobjects
    where type = 'P '
        and name = 'sp_MSismergejobnamegenerated')
    drop procedure dbo.sp_MSismergejobnamegenerated
go


declare @dbname sysname
select  @dbname = db_name()
execute('dump transaction ' +@dbname+ ' with no_log')
go

raiserror('Creating procedure sp_MSislogreaderjobnamegenerated', 0,1) with nowait
go
--
-- Name: sp_MSislogreaderjobnamegenerated
--
-- Descriptions: This procedure checks whether a given job id corresponds to
--               a logreader agent job with a name generated by replication. 
--               If so, a return value of zero will be returned, otherwise
--               a value of one will be returned to the caller.
-- 
-- Notes: 1) For this procedure to be effective, it must match the current
--           logreader agent name generation algorithm. Note that the 
--           algorithm used for matching auto-generated job name is not 
--           exact. (See sp_MSadd_logreader_agent instdist.sql)
--        2) This procedure is supposed to be executed at the distributor
--           where the publisher name and the publisher database name
--           are supplied through the RPC link.
--        3) There are two distinct code paths for the generation of 
--           the logreader name, one uses the agent id, and the other
--           uses a guid via the fn_repluniquename function.
--
-- Parameters: @publisher    sysname
--             @publisher_db sysname 
--             @jobid        uniqueidentifier
--
-- Returns: 0 - If the specified jobid corresponds to a logreader job with
--              a generated name.
--          1 - Otherwise
--
-- Security: This is an internal system procedure.
--
create procedure dbo.sp_MSislogreaderjobnamegenerated(
    @publisher     sysname,
    @publisher_db  sysname,
    @job_id        uniqueidentifier
    ) 
as
begin
    set nocount on

    declare @generated_job_name nvarchar(4000)
    declare @generated_job_name_length int
    declare @job_name sysname

    select @job_name = null    
    select @job_name = name
      from msdb.dbo.sysjobs_view 
     where job_id = @job_id

    if @job_name is null
    begin
        goto MISMATCH
    end

    -- First of all, make sure that the job is indeed a logreader agent
    -- job (there should be a step with LogReader as the subsystem in 
    -- the job)
    if not exists (select * 
                     from msdb.dbo.sysjobsteps
                    where job_id = @job_id
                      and upper(subsystem collate SQL_Latin1_General_CP1_CS_AS) = N'LOGREADER')
    begin
        goto MISMATCH
    end
    
    -- 1) Try doing a match for a name generated based on agentid
    select @generated_job_name = left(@publisher, 43) + N'-' 
                               + left(@publisher_db, 43) + N'-'
                               + N'[0-9]%'

    if @job_name like @generated_job_name 
    begin
        return 0
    end
        
    -- 2) Try doing a match for a name generated using a guid, see fn_repluniquename
        
    select @generated_job_name = left(@publisher, 16) + N'-' 
                               + left(@publisher_db, 16) + N'-'

    select @generated_job_name_length = len(@generated_job_name)

    -- Try matching the prefix of the job name
    if left(@job_name, @generated_job_name_length) = @generated_job_name
    begin
        -- Checks if the tail end of the job name matches a hexadecimal guid 
        if upper(right(@job_name, len(@job_name) - @generated_job_name_length) collate SQL_Latin1_General_CP1_CS_AS)
            like N'[0-9A-F][0-9A-F][0-9A-F][0-9A-F][0-9A-F][0-9A-F][0-9A-F][0-9A-F][0-9A-F][0-9A-F][0-9A-F][0-9A-F][0-9A-F][0-9A-F][0-9A-F][0-9A-F][0-9A-F][0-9A-F][0-9A-F][0-9A-F][0-9A-F][0-9A-F][0-9A-F][0-9A-F][0-9A-F][0-9A-F][0-9A-F][0-9A-F][0-9A-F][0-9A-F][0-9A-F][0-9A-F]'
        begin
            return 0
        end
        else
        begin
            goto MISMATCH
        end
    end

MISMATCH:
    if @job_name is not null
    begin
        raiserror(21695, -1, -1, @job_name)
    end
    return 1
end
go
exec sp_MS_marksystemobject 'dbo.sp_MSislogreaderjobnamegenerated'
raiserror('Creating procedure sp_MSisqueuereaderjobnamegenerated', 0,1) with nowait
go
--
-- Name: sp_MSisqueuereaderjobnamegenerated
--
-- Descriptions: This procedure checks whether a given job id corresponds to
--               a queuereader agent job with a name generated by replication. 
--               If so, a return value of zero will be returned, otherwise
--               a value of one will be returned to the caller.
-- 
-- Notes: 1) For this procedure to be effective, it must match the current
--           queuereader agent name generation algorithm. Note that the 
--           algorithm used for matching auto-generated job name is not 
--           exact. (See sp_MSadd_qreader_agent instdist.sql)
--        2) This procedure is supposed to be executed at the distributor.
--
-- Parameters: @job_id        uniqueidentifier
--
-- Returns: 0 - If the specified jobid corresponds to a queuereader job with
--              a generated name.
--          1 - Otherwise
--
-- Security: This is an internal system procedure.
--
create procedure dbo.sp_MSisqueuereaderjobnamegenerated (
    @job_id uniqueidentifier
    )
as
begin
    set nocount on

    declare @job_name sysname
    declare @generated_job_name nvarchar(4000)

    select @job_name = null
    select @job_name = name
      from msdb.dbo.sysjobs_view
     where job_id = @job_id
    
    -- Makes sure that the given job_id refers to an existing job
    if @job_name is null
    begin
        goto MISMATCH
    end

    -- Checks to make sure that the given job id corresponds to a queuereader
    -- job (i.e. it has a queue reader job step)
    if not exists (select * 
                     from msdb.dbo.sysjobsteps
                    where job_id = @job_id
                      and upper(subsystem collate SQL_Latin1_General_CP1_CS_AS) = N'QUEUEREADER')
    begin
        goto MISMATCH
    end

    -- QueueReader job name is generated based on the server name of 
    -- the distributor and the distribution database id. Here,
    -- we assume that this procedure is executed in the context of a
    -- distribution database so we can just use @@servername and
    -- db_name() to grab these two pieces of information

    select @generated_job_name = quotename(@@servername) + '.' + cast(db_id() as nvarchar)
    
    if @job_name = @generated_job_name
    begin    
        return 0
    end

MISMATCH:
    if @job_name is not null
    begin
        raiserror(21695, -1, -1, @job_name)
    end
    return 1
end
go
exec sp_MS_marksystemobject 'dbo.sp_MSisqueuereaderjobnamegenerated'

raiserror('Creating procedure sp_MSissnapshotjobnamegenerated', 0,1) with nowait
go
--
-- Name: sp_MSissnapshotjobnamegenerated
--
-- Descriptions: This procedure checks whether a given job id corresponds to
--               a snapshot agent job with a name generated by replication. 
--               If so, a return value of zero will be returned, otherwise
--               a value of one will be returned to the caller.
-- 
-- Notes: 1) For this procedure to be effective, it must match the current
--           snapshot agent name generation algorithm. Note that the 
--           algorithm used for matching auto-generated job name is not 
--           exact. (See sp_MSadd_snapshot_agent instdist.sql)
--        2) This procedure is supposed to be executed at the distributor.
--           The @publisher, @publisher_db, and @publication parameters
--           are supposed to be passed through the RPC link from the 
--           publisher. 
--        3) There are two distinct code paths for the generation of 
--           the snapshot job name, one uses the agent id, and the other
--           uses a guid via the fn_repluniquename function.        
--
-- Parameters: @publisher     sysname
--             @publisher_db  sysname
--             @publication   sysname
--             @job_id        uniqueidentifier
--
-- Returns: 0 - If the specified jobid corresponds to a snapshot job with
--              a generated name.
--          1 - Otherwise
--
-- Security: This is an internal system procedure.
--
create procedure dbo.sp_MSissnapshotjobnamegenerated (
    @publisher     sysname,
    @publisher_db  sysname,
    @publication   sysname,
    @job_id        uniqueidentifier    
    )
as
begin
    set nocount on
    declare @generated_job_name nvarchar(4000)
    declare @generated_job_name_length int
    declare @job_name sysname

    -- First, make sure that the given job id corresponds to a job
    select @job_name = null
    select @job_name = name 
      from msdb.dbo.sysjobs_view
     where job_id = @job_id

    if @job_name is null
    begin
        goto MISMATCH
    end

    -- Checks whether the specified job id corresponds to a snapshot agent
    -- job (i.e. the job contains snapshot subsystem steps)
    if not exists (select * 
                     from msdb.dbo.sysjobsteps
                    where job_id = @job_id
                      and upper(subsystem collate SQL_Latin1_General_CP1_CS_AS) = N'SNAPSHOT')
    begin
        goto MISMATCH
    end                     
    
    -- 1) Try doing a match for a generated snapshot job name based on agentid
    select @generated_job_name = left(@publisher, 28) + N'-'
                               + left(@publisher_db, 28) + N'-'
                               + left(@publication, 28) + N'-'
                               + N'[0-9]%'

    if @job_name like @generated_job_name 
    begin
        return 0
    end     

    -- 2) Try doing a match for a generated snapshot job name based on 
    -- uniqueidentifier, see fn_repluniquename
    select @generated_job_name = left(@publisher, 16) + N'-'
                               + left(@publisher_db, 16) + N'-'
                               + left(@publication, 16) + N'-'

    select @generated_job_name_length = len(@generated_job_name)
    
    -- Try matching the prefix of the job name
    if left(@job_name, @generated_job_name_length) = @generated_job_name
    begin
        -- Checks if the tail end of the job name matches a hexadecimal guid
        if upper(right(@job_name, len(@job_name) - @generated_job_name_length) collate SQL_Latin1_General_CP1_CS_AS)
            like N'[0-9A-F][0-9A-F][0-9A-F][0-9A-F][0-9A-F][0-9A-F][0-9A-F][0-9A-F][0-9A-F][0-9A-F][0-9A-F][0-9A-F][0-9A-F][0-9A-F][0-9A-F][0-9A-F][0-9A-F][0-9A-F][0-9A-F][0-9A-F][0-9A-F][0-9A-F][0-9A-F][0-9A-F][0-9A-F][0-9A-F][0-9A-F][0-9A-F][0-9A-F][0-9A-F][0-9A-F][0-9A-F]'
        begin
            return 0
        end
        else
        begin
            goto MISMATCH
        end
    end

MISMATCH:
    if @job_name is not null
    begin
        raiserror(21695, -1, -1, @job_name)
    end
    return 1

end
go
exec sp_MS_marksystemobject 'dbo.sp_MSissnapshotjobnamegenerated'

raiserror('Creating procedure sp_MSisdistributionjobnamegenerated', 0,1) with nowait
go
--
-- Name: sp_MSisdistributionjobnamegenerated
--
-- Descriptions: This procedure checks whether a given job id corresponds to
--               a distribution agent job with a name generated by replication. 
--               If so, a return value of zero will be returned, otherwise
--               a value of one will be returned to the caller.
-- 
-- Notes: 1) For this procedure to be effective, it must match the current
--           distribution agent name generation algorithm. Note that the 
--           algorithm used for matching auto-generated job name is not 
--           exact. (See sp_MSadd_distribution_agent instdist.sql)
--        2) This procedure is supposed to be executed at the distributor.
--           The @publisher, @publisher_db, and @publication parameters
--           are supposed to be passed through the RPC link from the 
--           publisher.
--        3) There are two distinct code paths for the generation of 
--           the distribution job name, one uses the agent id, and the other
--           uses a guid via the fn_repluniquename function.        
--
-- Parameters: @publisher     sysname
--             @publisher_db  sysname
--             @publication   sysname (This can be null for shared agent)
--             @subscriber    sysname
--             @job_id        uniqueidentifier
--
-- Returns: 0 - If the specified jobid corresponds to a snapshot job with
--              a generated name.
--          1 - Otherwise
--
-- Security: This is an internal system procedure.
--
create procedure dbo.sp_MSisdistributionjobnamegenerated (
    @publisher        sysname,
    @publisher_db     sysname,
    @publication      sysname,
    @subscriber       sysname,
    @job_id           uniqueidentifier
    )
as
begin
    set nocount on

    declare @generated_job_name nvarchar(4000)
    declare @generated_job_name_length int
    declare @job_name sysname
    
    select @job_name = null
    select @job_name = name
      from msdb.dbo.sysjobs_view
     where job_id = @job_id

    if @job_name is null
    begin
        goto MISMATCH
    end
    
    -- First of all, make sure that the job is indeed a logreader agent
    -- job (there should be a step with LogReader as the subsystem in the
    -- job)
    if not exists (select *
                     from msdb.dbo.sysjobsteps
                    where job_id = @job_id
                      and upper(subsystem collate SQL_Latin1_General_CP1_CS_AS) = N'DISTRIBUTION')
    begin
        goto MISMATCH
    end

    -- 1) Try doing a match for a name generated based on agentid
    if @publication is not null and (lower(@publication)<>'all')
    begin
        select @generated_job_name = left(@publisher, 21) + N'-'
                                   + left(@publisher_db, 21) + N'-'
                                   + left(@publication, 21) + N'-'
                                   + left(@subscriber, 21) + N'-' 
                                   + N'[0-9]%'
    end
    else
    begin
        select @generated_job_name = left(@publisher, 28) + N'-'
                                   + left(@publisher_db, 28) + N'-'
                                   + left(@subscriber, 28) + N'-'
                                   + N'[0-9]%'
    end
    
    if @job_name like @generated_job_name
    begin
        return 0
    end

    -- 2) Try doing a match for a neam generated using a guid, see fn_repluniquename

    if @publication is not null and (lower(@publication)<>'all')
    begin
        select @generated_job_name = left(@publisher, 16) + N'-'
                                   + left(@publisher_db, 16) + N'-'
                                   + left(@publication, 16) + N'-'
                                   + left(@subscriber, 16) + N'-'
    end
    else
    begin
        select @generated_job_name = left(@publisher, 16) + N'-'
                                   + left(@publisher_db, 16) + N'-'
                                   + left(@subscriber, 16) + N'-'
    end

    select @generated_job_name_length = len(@generated_job_name)

    -- Try matching the prefix of the job name
    if left(@job_name, @generated_job_name_length) = @generated_job_name
    begin
        -- Checks if the tail end of the job name matches a hexadecimal guid 
        if upper(right(@job_name, len(@job_name) - @generated_job_name_length) collate SQL_Latin1_General_CP1_CS_AS)
            like N'[0-9A-F][0-9A-F][0-9A-F][0-9A-F][0-9A-F][0-9A-F][0-9A-F][0-9A-F][0-9A-F][0-9A-F][0-9A-F][0-9A-F][0-9A-F][0-9A-F][0-9A-F][0-9A-F][0-9A-F][0-9A-F][0-9A-F][0-9A-F][0-9A-F][0-9A-F][0-9A-F][0-9A-F][0-9A-F][0-9A-F][0-9A-F][0-9A-F][0-9A-F][0-9A-F][0-9A-F][0-9A-F]'
        begin
            return 0
        end
        else
        begin
            goto MISMATCH
        end
    end

MISMATCH:
    if @job_name is not null
    begin
        raiserror(21695, -1, -1, @job_name)
    end
    return 1

end
go
exec sp_MS_marksystemobject 'dbo.sp_MSisdistributionjobnamegenerated'

raiserror('Creating procedure sp_MSismergejobnamegenerated', 0,1) with nowait
go
--
-- Name: sp_MSismergejobnamegenerated
--
-- Descriptions: This procedure checks whether a given job id corresponds to
--               a merge agent job with a name generated by replication. 
--               If so, a return value of zero will be returned, otherwise
--               a value of one will be returned to the caller.
-- 
-- Notes: 1) For this procedure to be effective, it must match the current
--           merge agent name generation algorithm. Note that the 
--           algorithm used for matching auto-generated job name is not 
--           exact. (See sp_MSadd_merge_agent instdist.sql)
--        2) This procedure is supposed to be executed at the distributor.
--           The @publisher, @publisher_db, and @publication parameters
--           are supposed to be passed through the RPC link from the 
--           publisher.
--        3) There are two distinct code paths for the generation of 
--           the merge job name, one uses the agent id, and the other
--           uses a guid via the fn_repluniquename function.        
--
-- Parameters: @publisher     sysname
--             @publisher_db  sysname
--             @publication   sysname (This can be null for shared agent)
--             @subscriber    sysname
--             @job_id        uniqueidentifier
--
-- Returns: 0 - If the specified jobid corresponds to a snapshot job with
--              a generated name.
--          1 - Otherwise
--
-- Security: This is an internal system procedure.
--
create procedure dbo.sp_MSismergejobnamegenerated (
    @publisher    sysname,
    @publisher_db sysname,
    @publication  sysname,
    @subscriber   sysname,
    @job_id       uniqueidentifier        
    )
as
begin
    set nocount on
    
    declare @generated_job_name nvarchar(4000)
    declare @generated_job_name_length int
    declare @job_name sysname

    select @job_name = null
    select @job_name = name
      from msdb.dbo.sysjobs_view
     where job_id = @job_id

    if @job_name is null
    begin
        goto MISMATCH
    end

    -- First of all, make sure that the job is indeed a merge agent
    -- job (there should be a step with Merge as the subsystem in the job)
    if not exists (select *
                     from msdb.dbo.sysjobsteps
                    where job_id = @job_id
                      and upper(subsystem collate SQL_Latin1_General_CP1_CS_AS) = N'MERGE')
    begin
       goto MISMATCH 
    end

    -- 1) Try doing a match for a name generated based on agentid
    select @generated_job_name = left(@publisher, 21) + N'-'
                               + left(@publisher_db, 21) + N'-'
                               + left(@publication, 21) + N'-'
                               + left(@subscriber, 21) + N'-'
                               + N'[0-9]%'

    if @job_name like @generated_job_name
    begin
        return 0
    end
    
    -- 2) Try doing a match for a name generated using a guid, see fn_repluniquename
    select @generated_job_name = left(@publisher, 16) + N'-'
                               + left(@publisher_db, 16) + N'-'
                               + left(@publication, 16) + N'-'
                               + left(@subscriber, 16) + N'-'
    
    select @generated_job_name_length = len(@generated_job_name)

    -- Try matching the prefix of the job name
    if left(@job_name, @generated_job_name_length) = @generated_job_name
    begin
        -- Checks if the tail end of the job name matches a hexadecimal guid 
        if upper(right(@job_name, len(@job_name) - @generated_job_name_length) collate SQL_Latin1_General_CP1_CS_AS)
            like N'[0-9A-F][0-9A-F][0-9A-F][0-9A-F][0-9A-F][0-9A-F][0-9A-F][0-9A-F][0-9A-F][0-9A-F][0-9A-F][0-9A-F][0-9A-F][0-9A-F][0-9A-F][0-9A-F][0-9A-F][0-9A-F][0-9A-F][0-9A-F][0-9A-F][0-9A-F][0-9A-F][0-9A-F][0-9A-F][0-9A-F][0-9A-F][0-9A-F][0-9A-F][0-9A-F][0-9A-F][0-9A-F]'
        begin
            return 0
        end
        else
        begin
            goto MISMATCH
        end
    end

MISMATCH:
    if @job_name is not null
    begin
        raiserror(21695, -1, -1, @job_name)
    end
    return 1
end
go
exec sp_MS_marksystemobject 'dbo.sp_MSismergejobnamegenerated'

-- This function is used internally by other stored procedures to mark the agent type
-- for anonymous agent before passing it to sp_MSupdate_replication_status, so anonymous
-- agent status can be filtered out from repl monitor. Only distribution agents and merge
-- agents should use this function. 
raiserror(15339,-1,-1,'fn_MSmask_agent_type')
go
create function dbo.fn_MSmask_agent_type(
    @agent_id int,
	@agent_type int
    ) returns int
as
begin
	declare @anonymous_mask int
	select @anonymous_mask = 0x80000000
	if @agent_type = 3 -- If dist agent
	begin
		if exists (select * from MSdistribution_agents where id = @agent_id and 
			subscriber_name is not null)
			select @agent_type = 3 | @anonymous_mask
		else
			select @agent_type = 3 
	end
	else if @agent_type = 4 -- if merge agent
	begin
		if exists (select * from MSmerge_agents where id = @agent_id and 
			subscriber_name is not null)
			select @agent_type = 4 | @anonymous_mask
		else
			select @agent_type = 4 
	end
	-- if other agents, @agent_type will not change.
	return @agent_type
end
go

raiserror(15339,-1,-1,'sp_MScheck_pull_access')
GO

CREATE PROCEDURE sp_MScheck_pull_access (
    @agent_id int = 0,
    @agent_type int = 0, -- 0 is tran; 1 is merge
    @publication_id int = 0,
    @raise_fatal_error bit = 1
        ) AS

    declare @retcode int

    -- sysadmin or db_owner have access
    if is_srvrolemember('sysadmin') = 1 or 
        is_member('db_owner') = 1
        return 0

    -- Need login_time to uniquely identify a connection.
    declare @login_time datetime
    select @login_time = login_time from master..sysprocesses where spid = @@spid

    -- For merge change to use publication_id
    if @agent_id <> 0 and @agent_type = 1
    begin
        select @publication_id = p.publication_id from
                MSmerge_agents a, MSpublications p where
                a.id = @agent_id and
                a.publisher_id = p.publisher_id and
                a.publisher_db = p.publisher_db and
                a.publication = p.publication
        select @agent_id = 0
    end

    -- In cache, return success
    if exists (select * from tempdb.dbo.MSdistributor_access where 
        spid = @@spid and
        login_time = @login_time and
        db_id = db_id() and
        (publication_id = @publication_id and
        agent_id = @agent_id and
        agent_type = @agent_type) or
        -- All 0s is used by sp_MSadd_repl_error, which just require the 
        -- login to be in cache regardless of the publication id and agent_id.
        -- This means that once a agent get into the distribution db, it
        -- can add any error.
        (@publication_id = 0 and @agent_id = 0 and @agent_type = 0))
        return (0)

    -- Cover sp_MSadd_repl_error case
    if @publication_id = 0 and @agent_id = 0 and @agent_type = 0
    begin
        RAISERROR (14126, 11, -1)
        return (1)
    end

    declare @isntname bit
    declare @offensive_pub_id int

    -- Check to see if the login is NT login
    select @isntname = isntname from master..syslogins where
        sid = suser_sid()
    -- If the login does not exists, check to see if the login is a NT login that
    -- has access to the server.
    if @isntname is null
    begin
        -- If it is an NT login
        if suser_sid() is not null
            select @isntname = 1
        -- If it is not an NT login
        else
            select @isntname = 0
    end

    -- Check security based on agent_id
    -- We know it is distribution agent. See above.
    if @agent_id <> 0 
    begin
        select top 1 @offensive_pub_id = s.publication_id from MSsubscriptions s where 
            s.agent_id = @agent_id and
            not exists (select * from MSpublication_access l where
                l.publication_id = s.publication_id and
			-- Current login has no access
            (suser_sid(l.login) = suser_sid() or (@isntname = 1 and exists 
                (select * from master..syslogins where 
                    sid = suser_sid(l.login) and isntgroup = 1 and is_member(l.login) = 1))))
        
        if @offensive_pub_id is not null
            goto NO_ACCESS
    end
    -- Check security based on publication_id
    else
    begin
        declare @publisher_id smallint
    
        if not exists (select * from MSpublication_access l where
            l.publication_id = @publication_id and
            (suser_sid(l.login) = suser_sid() or (@isntname = 1 and exists 
                (select * from master..syslogins where 
                    sid = suser_sid(l.login) and isntgroup = 1 and is_member(l.login) = 1))))
        begin
            select @offensive_pub_id = @publication_id
            goto NO_ACCESS
        end
    end

    -- If we are here, we know that the connection has access and is not in the cache
    -- add it in to the cache.
        
    -- Clear the cache to keep it small.
    exec @retcode = dbo.sp_MSflush_access_cache
    if @retcode <> 0 or @@error <> 0
        return (1)
        

    insert tempdb.dbo.MSdistributor_access
        (spid, db_id, agent_id, agent_type, publication_id, login_time) values
        (@@spid, db_id(), @agent_id, @agent_type, @publication_id, @login_time)

    if @@error <> 0
        return (1)

    return (0)

NO_ACCESS:

    -- We don't have access if we reach here, return error
    declare @login sysname
    select @login = suser_sname(suser_sid())
    declare @publication sysname
    select @publication = publication from MSpublications where publication_id = @offensive_pub_id
    if @raise_fatal_error = 1
         raiserror(21049, 16, -1, @login, @publication);
    else
         raiserror(21049, 10, -1, @login, @publication);
    return(1)

GO


raiserror(15339,-1,-1,'sp_MSquery_syncstates')
GO
create procedure sp_MSquery_syncstates
@publisher_id smallint, 
@publisher_db sysname
as
	declare @retcode int

    -- note:  obtain publisher_id via call to sp_MSvalidate_distpublisher

	select publication_id from MSsync_states 
	where publisher_id = @publisher_id 
	and publisher_db = @publisher_db

go


raiserror(15339,-1,-1,'sp_MSset_syncstate')
GO
create procedure sp_MSset_syncstate
@publisher_id smallint, 
@publisher_db sysname, 
@article_id int, 
@sync_state int,  
@xact_seqno varbinary(16)
as

declare @publication_id int

select top 1 @publication_id = s.publication_id 
from MSsubscriptions s
where 
s.publisher_id = @publisher_id and
s.publisher_db = @publisher_db and
s.article_id = @article_id     and
s.subscription_seqno < @xact_seqno


if @publication_id is not null
begin
	if( @sync_state = 1 )
	begin
		if not exists( select * from MSsync_states 
		               where publisher_id = @publisher_id and
					   publisher_db = @publisher_db and
					   publication_id = @publication_id )
		begin
			insert into MSsync_states( publisher_id, publisher_db, publication_id )
			values( @publisher_id, @publisher_db, @publication_id )
		end
	end
	else if @sync_state = 0 
	begin
		
		delete MSsync_states 
		where 
		publisher_id = @publisher_id and
		publisher_db = @publisher_db and
		publication_id = @publication_id 

		-- activate the subscription(s) so the distribution agent can start processing
		declare @automatic int
		declare @active int	
		declare @initiated int

		select @automatic = 1
		select @active = 2
		select @initiated = 3

		-- set status to active, ss_cplt_seqno = commit LSN of xact containing
		-- syncdone token.  
		--
		-- VERY IMPORTANT:  We can only do this because we know that the publisher
		-- tables are locked in the same transaction that writes the SYNCDONE token.
		-- If the tables were NOT locked, we could get into a situation where data
		-- in the table was changed and committed between the time the SYNCDONE token was
		-- written and the time the SYNCDONE xact was committed.  This would cause the
		-- logreader to replicate the xact with no compensation records, but the advance
		-- of the ss_cplt_seqno would cause the dist to skip that command since only commands
		-- with the snapshot bit set will be processed if they are <= ss_cplt_seqno.
		--
		update MSsubscriptions 
		set status = @active,
			subscription_time = getdate(),
			ss_cplt_seqno = @xact_seqno		
		where
			publisher_id = @publisher_id and
			publisher_db = @publisher_db and
			publication_id = @publication_id and
			sync_type = @automatic and
			status in( @initiated )
	end
end
go

raiserror(15339,-1,-1,'sp_MSadd_repl_command')
go
CREATE PROCEDURE sp_MSadd_repl_command
@publisher_id smallint = NULL,
@publisher_db sysname,
@xact_id varbinary(16) = 0x0,
@xact_seqno varbinary(16) = 0x0,
@originator sysname = NULL,
@originator_db sysname = NULL,
@article_id int = NULL,
@command_id int = 1,
@type int = NULL,
@partial_command bit = NULL,
@command varbinary(1024) = NULL,
@publisher sysname = NULL


AS

   SET NOCOUNT ON

   DECLARE @date datetime
   DECLARE @publisher_database_id int
   declare @originator_id int

   SELECT @date = GETDATE()

   if @publisher_id is NULL
		select @publisher_id = srvid from master..sysservers where
			UPPER(srvname) = UPPER(@publisher)

    -- Get publisher database id.
    SELECT @publisher_database_id = id from MSpublisher_databases where publisher_id = @publisher_id and 
        publisher_db = @publisher_db
    
   /* 
   ** To minimize contention, snapshot does not include this SP call
   ** inside a transaction. We have to insert to MSrepl_transactions table
   ** first to ensure clean up stored precedures to work, which only use 
   ** MSrepl_transactions table but NOT MSrepl_commands table to find transactions
   ** to be deleted.
   */

   IF @command_id = 1
   BEGIN
      INSERT INTO MSrepl_transactions VALUES (@publisher_database_id,
         @xact_id,  @xact_seqno, @date)
      IF @@ERROR <> 0
         RETURN 1
   END

   IF @command IS NOT NULL
   begin
      if @originator <> N'' and @originator_db <> N'' and @originator is not null and @originator_db is not null 
      begin
        set @originator_id = null select @originator_id = id from MSrepl_originators where
            publisher_database_id = @publisher_database_id and UPPER(srvname) = UPPER(@originator) and
            dbname = @originator_db
        if @originator_id is null
        begin
            insert into MSrepl_originators (publisher_database_id, srvname, dbname) values
                (@publisher_database_id, @originator, @originator_db)
            select @originator_id = @@identity
        end
      end
      else
        select @originator_id = 0
      

	  if( @type in( 37,38 ) )
	  begin
	  	  declare @syncstat int
		  select @syncstat = 38 - @type
		  exec sp_MSset_syncstate @publisher_id, @publisher_db, @article_id, @syncstat, @xact_seqno 
	  end

      INSERT INTO MSrepl_commands VALUES (@publisher_database_id, @xact_seqno,
        @type, @article_id, @originator_id, @command_id, @partial_command, @command)
    end

    IF @@ERROR <> 0
      RETURN (1)

GO  


raiserror(15339,-1,-1,'sp_MSadd_repl_commands27')
GO
CREATE PROCEDURE sp_MSadd_repl_commands27
@publisher_id smallint,
@publisher_db sysname,
@xact_id varbinary(16) = 0x0,
@xact_seqno varbinary(16) = 0x0,
@originator sysname,
@originator_db sysname,
@article_id int,
@command_id int,
@type int = 0,
@partial_command bit,
@command varbinary(1024),

@1xact_id varbinary(16) = 0x0,

@1xact_seqno varbinary(16) = 0x0,
@1originator sysname = NULL,
@1originator_db sysname = NULL,
@1article_id int = 0,
@1command_id int = 0,
@1type int = 0,
@1partial_command bit = 0,
@1command varbinary(1024) = NULL,

@2xact_id varbinary(16) = 0x0,

@2xact_seqno varbinary(16) = 0x0,
@2originator sysname = NULL,
@2originator_db sysname = NULL,
@2article_id int = 0,
@2command_id int = 0,
@2type int = 0,
@2partial_command bit = 0,
@2command varbinary(1024) = NULL,

@3xact_id varbinary(16) = 0x0,

@3xact_seqno varbinary(16) = 0x0,
@3originator sysname = NULL,
@3originator_db sysname = NULL,
@3article_id int = 0,
@3command_id int = 0,
@3type int = 0,
@3partial_command bit = 0,
@3command varbinary(1024) = NULL,

@4xact_id varbinary(16) = 0x0,

@4xact_seqno varbinary(16) = 0x0,
@4originator sysname = NULL,
@4originator_db sysname = NULL,
@4article_id int = 0,
@4command_id int = 0,
@4type int = 0,
@4partial_command bit = 0,
@4command varbinary(1024) = NULL,

@5xact_id varbinary(16) = 0x0,

@5xact_seqno varbinary(16) = 0x0,
@5originator sysname = NULL,
@5originator_db sysname = NULL,
@5article_id int = 0,
@5command_id int = 0,
@5type int = 0,
@5partial_command bit = 0,
@5command varbinary(1024) = NULL,

@6xact_id varbinary(16) = 0x0,

@6xact_seqno varbinary(16) = 0x0,
@6originator sysname = NULL,
@6originator_db sysname = NULL,
@6article_id int = 0,
@6command_id int = 0,
@6type int = 0,
@6partial_command bit = 0,
@6command varbinary(1024) = NULL,

@7xact_id varbinary(16) = 0x0,

@7xact_seqno varbinary(16) = 0x0,
@7originator sysname = NULL,
@7originator_db sysname = NULL,
@7article_id int = 0,
@7command_id int = 0,
@7type int = 0,
@7partial_command bit = 0,
@7command varbinary(1024) = NULL,

@8xact_id varbinary(16) = 0x0,

@8xact_seqno varbinary(16) = 0x0,
@8originator sysname = NULL,
@8originator_db sysname = NULL,
@8article_id int = 0,
@8command_id int = 0,
@8type int = 0,
@8partial_command bit = 0,
@8command varbinary(1024) = NULL,

@9xact_id varbinary(16) = 0x0,

@9xact_seqno varbinary(16) = 0x0,
@9originator sysname = NULL,
@9originator_db sysname = NULL,
@9article_id int = 0,
@9command_id int = 0,
@9type int = 0,
@9partial_command bit = 0,
@9command varbinary(1024) = NULL,

@10xact_id varbinary(16) = 0x0,

@10xact_seqno varbinary(16) = 0x0,
@10originator sysname = NULL,
@10originator_db sysname = NULL,
@10article_id int = 0,
@10command_id int = 0,
@10type int = 0,
@10partial_command bit = 0,
@10command varbinary(1024) = NULL,

@11xact_id varbinary(16) = 0x0,

@11xact_seqno varbinary(16) = 0x0,
@11originator sysname = NULL,
@11originator_db sysname = NULL,
@11article_id int = 0,
@11command_id int = 0,
@11type int = 0,
@11partial_command bit = 0,
@11command varbinary(1024) = NULL,

@12xact_id varbinary(16) = 0x0,

@12xact_seqno varbinary(16) = 0x0,
@12originator sysname = NULL,
@12originator_db sysname = NULL,
@12article_id int = 0,
@12command_id int = 0,
@12type int = 0,
@12partial_command bit = 0,
@12command varbinary(1024) = NULL,

@13xact_id varbinary(16) = 0x0,

@13xact_seqno varbinary(16) = 0x0,
@13originator sysname = NULL,
@13originator_db sysname = NULL,
@13article_id int = 0,
@13command_id int = 0,
@13type int = 0,
@13partial_command bit = 0,
@13command varbinary(1024) = NULL,

@14xact_id varbinary(16) = 0x0,

@14xact_seqno varbinary(16) = 0x0,
@14originator sysname = NULL,
@14originator_db sysname = NULL,
@14article_id int = 0,
@14command_id int = 0,
@14type int = 0,
@14partial_command bit = 0,
@14command varbinary(1024) = NULL,

@15xact_id varbinary(16) = 0x0,

@15xact_seqno varbinary(16) = 0x0,
@15originator sysname = NULL,
@15originator_db sysname = NULL,
@15article_id int = 0,
@15command_id int = 0,
@15type int = 0,
@15partial_command bit = 0,
@15command varbinary(1024) = NULL,

@16xact_id varbinary(16) = 0x0,

@16xact_seqno varbinary(16) = 0x0,
@16originator sysname = NULL,
@16originator_db sysname = NULL,
@16article_id int = 0,
@16command_id int = 0,
@16type int = 0,
@16partial_command bit = 0,
@16command varbinary(1024) = NULL,

@17xact_id varbinary(16) = 0x0,

@17xact_seqno varbinary(16) = 0x0,
@17originator sysname = NULL,
@17originator_db sysname = NULL,
@17article_id int = 0,
@17command_id int = 0,
@17type int = 0,
@17partial_command bit = 0,
@17command varbinary(1024) = NULL,

@18xact_id varbinary(16) = 0x0,

@18xact_seqno varbinary(16) = 0x0,
@18originator sysname = NULL,
@18originator_db sysname = NULL,
@18article_id int = 0,
@18command_id int = 0,
@18type int = 0,
@18partial_command bit = 0,
@18command varbinary(1024) = NULL,

@19xact_id varbinary(16) = 0x0,

@19xact_seqno varbinary(16) = 0x0,
@19originator sysname = NULL,
@19originator_db sysname = NULL,
@19article_id int = 0,
@19command_id int = 0,
@19type int = 0,
@19partial_command bit = 0,
@19command varbinary(1024) = NULL,

@20xact_id varbinary(16) = 0x0,

@20xact_seqno varbinary(16) = 0x0,
@20originator sysname = NULL,
@20originator_db sysname = NULL,
@20article_id int = 0,
@20command_id int = 0,
@20type int = 0,
@20partial_command bit = 0,
@20command varbinary(1024) = NULL,

@21xact_id varbinary(16) = 0x0,

@21xact_seqno varbinary(16) = 0x0,
@21originator sysname = NULL,
@21originator_db sysname = NULL,
@21article_id int = 0,
@21command_id int = 0,
@21type int = 0,
@21partial_command bit = 0,
@21command varbinary(1024) = NULL,

@22xact_id varbinary(16) = 0x0,

@22xact_seqno varbinary(16) = 0x0,
@22originator sysname = NULL,
@22originator_db sysname = NULL,
@22article_id int = 0,
@22command_id int = 0,
@22type int = 0,
@22partial_command bit = 0,
@22command varbinary(1024) = NULL,

@23xact_id varbinary(16) = 0x0,

@23xact_seqno varbinary(16) = 0x0,
@23originator sysname = NULL,
@23originator_db sysname = NULL,
@23article_id int = 0,
@23command_id int = 0,
@23type int = 0,
@23partial_command bit = 0,
@23command varbinary(1024) = NULL,

@24xact_id varbinary(16) = 0x0,

@24xact_seqno varbinary(16) = 0x0,
@24originator sysname = NULL,
@24originator_db sysname = NULL,
@24article_id int = 0,
@24command_id int = 0,
@24type int = 0,
@24partial_command bit = 0,
@24command varbinary(1024) = NULL,

@25xact_id varbinary(16) = 0x0,

@25xact_seqno varbinary(16) = 0x0,
@25originator sysname = NULL,
@25originator_db sysname = NULL,
@25article_id int = 0,
@25command_id int = 0,
@25type int = 0,
@25partial_command bit = 0,
@25command varbinary(1024) = NULL,

@26xact_id varbinary(16) = 0x0,

@26xact_seqno varbinary(16) = 0x0,
@26originator sysname = NULL,
@26originator_db sysname = NULL,
@26article_id int = 0,
@26command_id int = 0,
@26type int = 0,
@26partial_command bit = 0,
@26command varbinary(1024) = NULL

AS

    SET NOCOUNT ON

    DECLARE @publisher_database_id int
    DECLARE @date datetime
    declare @originator_id int
	declare @syncstat int

    SELECT @date = GETDATE()

    -- Get publisher database id.
    SELECT @publisher_database_id = id from MSpublisher_databases where publisher_id = @publisher_id and 
        publisher_db = @publisher_db
    
    -- First insert into MS_repl_transactions
    IF @command_id = 1
      INSERT INTO MSrepl_transactions VALUES (@publisher_database_id,
         @xact_id,  @xact_seqno, @date)

    IF @1xact_id = 0x0
      goto INSERT_CMDS
    IF @1command_id = 1
      INSERT INTO MSrepl_transactions VALUES (@publisher_database_id,
         @1xact_id,  @1xact_seqno, @date)

    IF @2xact_id = 0x0
      goto INSERT_CMDS
    IF @2command_id = 1
      INSERT INTO MSrepl_transactions VALUES (@publisher_database_id,
         @2xact_id,  @2xact_seqno, @date)
    
    IF @3xact_id = 0x0
      goto INSERT_CMDS
    IF @3command_id = 1
      INSERT INTO MSrepl_transactions VALUES (@publisher_database_id,
         @3xact_id,  @3xact_seqno, @date)

    IF @4xact_id = 0x0
      goto INSERT_CMDS
    IF @4command_id = 1
      INSERT INTO MSrepl_transactions VALUES (@publisher_database_id,
        @4xact_id,  @4xact_seqno, @date)

    IF @5xact_id = 0x0
      goto INSERT_CMDS

    IF @5command_id = 1
      INSERT INTO MSrepl_transactions VALUES (@publisher_database_id,
         @5xact_id,  @5xact_seqno, @date)

    IF @6xact_id = 0x0
      goto INSERT_CMDS
    IF @6command_id = 1
      INSERT INTO MSrepl_transactions VALUES (@publisher_database_id,
         @6xact_id,  @6xact_seqno, @date)

    IF @7xact_id = 0x0
      goto INSERT_CMDS
    IF @7command_id = 1
      INSERT INTO MSrepl_transactions VALUES (@publisher_database_id,
         @7xact_id,  @7xact_seqno, @date)

    IF @8xact_id = 0x0
      goto INSERT_CMDS
    IF @8command_id = 1
      INSERT INTO MSrepl_transactions VALUES (@publisher_database_id,
         @8xact_id,  @8xact_seqno, @date)

    IF @9xact_id = 0x0
      goto INSERT_CMDS
    IF @9command_id = 1
      INSERT INTO MSrepl_transactions VALUES (@publisher_database_id,
         @9xact_id,  @9xact_seqno, @date)

    IF @10xact_id = 0x0
      goto INSERT_CMDS
    IF @10command_id = 1
      INSERT INTO MSrepl_transactions VALUES (@publisher_database_id,
         @10xact_id,  @10xact_seqno, @date)

    IF @11xact_id = 0x0
      goto INSERT_CMDS
    IF @11command_id = 1
      INSERT INTO MSrepl_transactions VALUES (@publisher_database_id,
         @11xact_id,  @11xact_seqno, @date)

    IF @12xact_id = 0x0
      goto INSERT_CMDS
    IF @12command_id = 1
      INSERT INTO MSrepl_transactions VALUES (@publisher_database_id,
         @12xact_id,  @12xact_seqno, @date)

    IF @13xact_id = 0x0
      goto INSERT_CMDS
    IF @13command_id = 1
      INSERT INTO MSrepl_transactions VALUES (@publisher_database_id,
         @13xact_id,  @13xact_seqno, @date)

    IF @14xact_id = 0x0
      goto INSERT_CMDS
    IF @14command_id = 1
      INSERT INTO MSrepl_transactions VALUES (@publisher_database_id,
         @14xact_id,  @14xact_seqno, @date)

    IF @15xact_id = 0x0
      goto INSERT_CMDS
    IF @15command_id = 1
      INSERT INTO MSrepl_transactions VALUES (@publisher_database_id,
         @15xact_id,  @15xact_seqno, @date)

    IF @16xact_id = 0x0
      goto INSERT_CMDS
    IF @16command_id = 1
      INSERT INTO MSrepl_transactions VALUES (@publisher_database_id,
         @16xact_id,  @16xact_seqno, @date)

    IF @17xact_id = 0x0
      goto INSERT_CMDS
    IF @17command_id = 1
      INSERT INTO MSrepl_transactions VALUES (@publisher_database_id,
         @17xact_id,  @17xact_seqno, @date)

    IF @18xact_id = 0x0
      goto INSERT_CMDS
    IF @18command_id = 1
      INSERT INTO MSrepl_transactions VALUES (@publisher_database_id,
         @18xact_id,  @18xact_seqno, @date)

    IF @19xact_id = 0x0
      goto INSERT_CMDS
    IF @19command_id = 1
      INSERT INTO MSrepl_transactions VALUES (@publisher_database_id,
         @19xact_id,  @19xact_seqno, @date)

    IF @20xact_id = 0x0
      goto INSERT_CMDS
    IF @20command_id = 1
      INSERT INTO MSrepl_transactions VALUES (@publisher_database_id,
         @20xact_id,  @20xact_seqno, @date)

    IF @21xact_id = 0x0
      goto INSERT_CMDS
    IF @21command_id = 1
      INSERT INTO MSrepl_transactions VALUES (@publisher_database_id,
         @21xact_id,  @21xact_seqno, @date)

    IF @22xact_id = 0x0
      goto INSERT_CMDS
    IF @22command_id = 1
      INSERT INTO MSrepl_transactions VALUES (@publisher_database_id,
         @22xact_id,  @22xact_seqno, @date)

    IF @23xact_id = 0x0
      goto INSERT_CMDS
    IF @23command_id = 1
      INSERT INTO MSrepl_transactions VALUES (@publisher_database_id,
         @23xact_id,  @23xact_seqno, @date)

    IF @24xact_id = 0x0
      goto INSERT_CMDS
    IF @24command_id = 1
      INSERT INTO MSrepl_transactions VALUES (@publisher_database_id,
         @24xact_id,  @24xact_seqno, @date)

    IF @25xact_id = 0x0
      goto INSERT_CMDS
    IF @25command_id = 1
      INSERT INTO MSrepl_transactions VALUES (@publisher_database_id,
         @25xact_id,  @25xact_seqno, @date)

    IF @26xact_id = 0x0
      goto INSERT_CMDS
    IF @26command_id = 1
      INSERT INTO MSrepl_transactions VALUES (@publisher_database_id,
         @26xact_id,  @26xact_seqno, @date)

INSERT_CMDS:

    -- Get the originator_id for the first command 
    if @originator <> N'' and @originator_db <> N'' and @originator is not null and @originator_db is not null 
    begin 
        set @originator_id = null select @originator_id = id from MSrepl_originators where
            publisher_database_id = @publisher_database_id and UPPER(srvname) = UPPER(@originator) and
            dbname = @originator_db
        if @originator_id is null
        begin
            insert into MSrepl_originators (publisher_database_id, srvname, dbname) values
                (@publisher_database_id, @originator, @originator_db)
            select @originator_id = @@identity
        end
    end
    else
        select @originator_id = 0

    -- Now insert into MSrepl_commands
    IF @command IS NOT NULL
	begin
		if( @type in( 37,38 ) )
		begin
		  select @syncstat = 38 - @type
		  exec sp_MSset_syncstate @publisher_id, @publisher_db, @article_id, @syncstat, @xact_seqno
		end

        INSERT INTO MSrepl_commands VALUES (@publisher_database_id, 
            @xact_seqno,@type, @article_id, 
            @originator_id, 
            @command_id, @partial_command, @command)
	end

    IF @1xact_id = 0x0
      return

    IF @1command IS NOT NULL
    begin
            if @1originator <> N'' and @1originator_db <> N'' and @1originator is not null and @1originator_db is not null 
            begin 
                set @originator_id = null select @originator_id = id from MSrepl_originators where
                    publisher_database_id = @publisher_database_id and UPPER(srvname) = UPPER(@1originator) and
                    dbname = @1originator_db
                if @originator_id is null
                begin
                    insert into MSrepl_originators (publisher_database_id, srvname, dbname) values
                        (@publisher_database_id, @1originator, @1originator_db)
                    select @originator_id = @@identity
                end
            end
            else
                select @originator_id = 0
    
		if( @type in( 37,38 ) )
		begin
		  select @syncstat = 38 - @1type
		  exec sp_MSset_syncstate @publisher_id, @publisher_db, @1article_id, @syncstat, @1xact_seqno
		end

        INSERT INTO MSrepl_commands VALUES (@publisher_database_id, 
            @1xact_seqno,@1type, @1article_id, 
            @originator_id, 
            @1command_id, @1partial_command, @1command)
    end

    IF @2xact_id = 0x0
      return
    IF @2command IS NOT NULL
    begin
            if @2originator <> N'' and @2originator_db <> N'' and @2originator is not null and @2originator_db is not null 
            begin 
                set @originator_id = null select @originator_id = id from MSrepl_originators where
                    publisher_database_id = @publisher_database_id and UPPER(srvname) = UPPER(@2originator) and
                    dbname = @2originator_db
                if @originator_id is null
                begin
                    insert into MSrepl_originators (publisher_database_id, srvname, dbname) values
                        (@publisher_database_id, @2originator, @2originator_db)
                    select @originator_id = @@identity
                end
            end
            else
                select @originator_id = 0
    
		if( @type in( 37,38 ) )
		begin
		  select @syncstat = 38 - @2type
		  exec sp_MSset_syncstate @publisher_id, @publisher_db, @2article_id, @syncstat, @2xact_seqno 
		end

        INSERT INTO MSrepl_commands VALUES (@publisher_database_id, 
            @2xact_seqno,@2type, @2article_id, 
            @originator_id, 
            @2command_id, @2partial_command, @2command)
    end

    IF @3xact_id = 0x0
      return
    IF @3command IS NOT NULL
    begin
            if @3originator <> N'' and @3originator_db <> N'' and @3originator is not null and @3originator_db is not null 
            begin 
                set @originator_id = null select @originator_id = id from MSrepl_originators where
                    publisher_database_id = @publisher_database_id and UPPER(srvname) = UPPER(@3originator) and
                    dbname = @3originator_db
                if @originator_id is null
                begin
                    insert into MSrepl_originators (publisher_database_id, srvname, dbname) values
                        (@publisher_database_id, @3originator, @3originator_db)
                    select @originator_id = @@identity
                end
            end
            else
                select @originator_id = 0

		if( @type in( 37,38 ) )
		begin
		  select @syncstat = 38 - @3type
		  exec sp_MSset_syncstate @publisher_id, @publisher_db, @3article_id, @syncstat, @3xact_seqno 
		end
    
        INSERT INTO MSrepl_commands VALUES (@publisher_database_id, 
            @3xact_seqno,@3type, @3article_id, 
            @originator_id, 
            @3command_id, @3partial_command, @3command)
    end

    IF @4xact_id = 0x0
      return
    IF @4command IS NOT NULL
    begin
            if @4originator <> N'' and @4originator_db <> N'' and @4originator is not null and @4originator_db is not null 
            begin 
                set @originator_id = null select @originator_id = id from MSrepl_originators where
                    publisher_database_id = @publisher_database_id and UPPER(srvname) = UPPER(@4originator) and
                    dbname = @4originator_db
                if @originator_id is null
                begin
                    insert into MSrepl_originators (publisher_database_id, srvname, dbname) values
                        (@publisher_database_id, @4originator, @4originator_db)
                    select @originator_id = @@identity
                end
            end
            else
                select @originator_id = 0

		if( @type in( 37,38 ) )
		begin
		  select @syncstat = 38 - @4type
		  exec sp_MSset_syncstate @publisher_id, @publisher_db, @4article_id, @syncstat, @4xact_seqno 
		end
    
        INSERT INTO MSrepl_commands VALUES (@publisher_database_id, 
            @4xact_seqno,@4type, @4article_id, 
            @originator_id, 
            @4command_id, @4partial_command, @4command)
    end

    IF @5xact_id = 0x0
      return
    IF @5command IS NOT NULL
    begin
            if @5originator <> N'' and @5originator_db <> N'' and @5originator is not null and @5originator_db is not null 
            begin 
                set @originator_id = null select @originator_id = id from MSrepl_originators where
                    publisher_database_id = @publisher_database_id and UPPER(srvname) = UPPER(@5originator) and
                    dbname = @5originator_db
                if @originator_id is null
                begin
                    insert into MSrepl_originators (publisher_database_id, srvname, dbname) values
                        (@publisher_database_id, @5originator, @5originator_db)
                    select @originator_id = @@identity
                end
            end
            else
                select @originator_id = 0
    
		if( @type in( 37,38 ) )
		begin
		  select @syncstat = 38 - @5type
		  exec sp_MSset_syncstate @publisher_id, @publisher_db, @5article_id, @syncstat, @5xact_seqno 
		end

        INSERT INTO MSrepl_commands VALUES (@publisher_database_id, 
            @5xact_seqno,@5type, @5article_id, 
            @originator_id, 
            @5command_id, @5partial_command, @5command)
    end

    IF @6xact_id = 0x0
      return
    IF @6command IS NOT NULL
    begin
            if @6originator <> N'' and @6originator_db <> N'' and @6originator is not null and @6originator_db is not null 
            begin 
                set @originator_id = null select @originator_id = id from MSrepl_originators where
                    publisher_database_id = @publisher_database_id and UPPER(srvname) = UPPER(@6originator) and
                    dbname = @6originator_db
                if @originator_id is null
                begin
                    insert into MSrepl_originators (publisher_database_id, srvname, dbname) values
                        (@publisher_database_id, @6originator, @6originator_db)
                    select @originator_id = @@identity
                end
            end
            else
                select @originator_id = 0

		if( @type in( 37,38 ) )
		begin
		  select @syncstat = 38 - @6type
		  exec sp_MSset_syncstate @publisher_id, @publisher_db, @6article_id, @syncstat, @6xact_seqno 
		end
    
        INSERT INTO MSrepl_commands VALUES (@publisher_database_id, 
            @6xact_seqno,@6type, @6article_id, 
            @originator_id, 
            @6command_id, @6partial_command, @6command)
    end

    IF @7xact_id = 0x0
      return
    IF @7command IS NOT NULL
    begin
            if @7originator <> N'' and @7originator_db <> N'' and @7originator is not null and @7originator_db is not null 
            begin 
                set @originator_id = null select @originator_id = id from MSrepl_originators where
                    publisher_database_id = @publisher_database_id and UPPER(srvname) = UPPER(@7originator) and
                    dbname = @7originator_db
                if @originator_id is null
                begin
                    insert into MSrepl_originators (publisher_database_id, srvname, dbname) values
                        (@publisher_database_id, @7originator, @7originator_db)
                    select @originator_id = @@identity
                end
            end
            else
                select @originator_id = 0
    
		if( @type in( 37,38 ) )
		begin
		  select @syncstat = 38 - @7type
		  exec sp_MSset_syncstate @publisher_id, @publisher_db, @7article_id, @syncstat, @7xact_seqno 
		end

        INSERT INTO MSrepl_commands VALUES (@publisher_database_id, 
            @7xact_seqno,@7type, @7article_id, 
            @originator_id, 
            @7command_id, @7partial_command, @7command)
    end

    IF @8xact_id = 0x0
      return
    IF @8command IS NOT NULL
    begin
            if @8originator <> N'' and @8originator_db <> N'' and @8originator is not null and @8originator_db is not null 
            begin 
                set @originator_id = null select @originator_id = id from MSrepl_originators where
                    publisher_database_id = @publisher_database_id and UPPER(srvname) = UPPER(@8originator) and
                    dbname = @8originator_db
                if @originator_id is null
                begin
                    insert into MSrepl_originators (publisher_database_id, srvname, dbname) values
                        (@publisher_database_id, @8originator, @8originator_db)
                    select @originator_id = @@identity
                end
            end
            else
                select @originator_id = 0
    
		if( @type in( 37,38 ) )
		begin
		  select @syncstat = 38 - @8type
		  exec sp_MSset_syncstate @publisher_id, @publisher_db, @8article_id, @syncstat, @8xact_seqno 
		end

        INSERT INTO MSrepl_commands VALUES (@publisher_database_id, 
            @8xact_seqno,@8type, @8article_id, 
            @originator_id, 
            @8command_id, @8partial_command, @8command)
    end

    IF @9xact_id = 0x0
      return
    IF @9command IS NOT NULL
    begin
            if @9originator <> N'' and @9originator_db <> N'' and @9originator is not null and @9originator_db is not null 
            begin 
                set @originator_id = null select @originator_id = id from MSrepl_originators where
                    publisher_database_id = @publisher_database_id and UPPER(srvname) = UPPER(@9originator) and
                    dbname = @9originator_db
                if @originator_id is null
                begin
                    insert into MSrepl_originators (publisher_database_id, srvname, dbname) values
                        (@publisher_database_id, @9originator, @9originator_db)
                    select @originator_id = @@identity
                end
            end
            else
                select @originator_id = 0
    
		if( @type in( 37,38 ) )
		begin
		  select @syncstat = 38 - @9type
		  exec sp_MSset_syncstate @publisher_id, @publisher_db, @9article_id, @syncstat, @9xact_seqno 
		end

        INSERT INTO MSrepl_commands VALUES (@publisher_database_id, 
            @9xact_seqno,@9type, @9article_id, 
            @originator_id, 
            @9command_id, @9partial_command, @9command)
    end

    IF @10xact_id = 0x0
      return
    IF @10command IS NOT NULL
    begin
            if @10originator <> N'' and @10originator_db <> N'' and @10originator is not null and @10originator_db is not null 
            begin 
                set @originator_id = null select @originator_id = id from MSrepl_originators where
                    publisher_database_id = @publisher_database_id and UPPER(srvname) = UPPER(@10originator) and
                    dbname = @10originator_db
                if @originator_id is null
                begin
                    insert into MSrepl_originators (publisher_database_id, srvname, dbname) values
                        (@publisher_database_id, @10originator, @10originator_db)
                    select @originator_id = @@identity
                end
            end
            else
                select @originator_id = 0
    
		if( @type in( 37,38 ) )
		begin
		  select @syncstat = 38 - @10type
		  exec sp_MSset_syncstate @publisher_id, @publisher_db, @10article_id, @syncstat, @10xact_seqno 
		end

        INSERT INTO MSrepl_commands VALUES (@publisher_database_id, 
            @10xact_seqno,@10type, @10article_id, 
            @originator_id, 
            @10command_id, @10partial_command, @10command)
    end

    IF @11xact_id = 0x0
      return
    IF @11command IS NOT NULL
    begin
            if @11originator <> N'' and @11originator_db <> N'' and @11originator is not null and @11originator_db is not null 
            begin 
                set @originator_id = null select @originator_id = id from MSrepl_originators where
                    publisher_database_id = @publisher_database_id and UPPER(srvname) = UPPER(@11originator) and
                    dbname = @11originator_db
                if @originator_id is null
                begin
                    insert into MSrepl_originators (publisher_database_id, srvname, dbname) values
                        (@publisher_database_id, @11originator, @11originator_db)
                    select @originator_id = @@identity
                end
            end
            else
                select @originator_id = 0
    
		if( @type in( 37,38 ) )
		begin
		  select @syncstat = 38 - @11type
		  exec sp_MSset_syncstate @publisher_id, @publisher_db, @11article_id, @syncstat, @11xact_seqno 
		end

        INSERT INTO MSrepl_commands VALUES (@publisher_database_id, 
            @11xact_seqno,@11type, @11article_id, 
            @originator_id, 
            @11command_id, @11partial_command, @11command)
    end

    IF @12xact_id = 0x0
      return
    IF @12command IS NOT NULL
    begin
            if @12originator <> N'' and @12originator_db <> N'' and @12originator is not null and @12originator_db is not null 
            begin 
                set @originator_id = null select @originator_id = id from MSrepl_originators where
                    publisher_database_id = @publisher_database_id and UPPER(srvname) = UPPER(@12originator) and
                    dbname = @12originator_db
                if @originator_id is null
                begin
                    insert into MSrepl_originators (publisher_database_id, srvname, dbname) values
                        (@publisher_database_id, @12originator, @12originator_db)
                    select @originator_id = @@identity
                end
            end
            else
                select @originator_id = 0
    
		if( @type in( 37,38 ) )
		begin
		  select @syncstat = 38 - @12type
		  exec sp_MSset_syncstate @publisher_id, @publisher_db, @12article_id, @syncstat, @12xact_seqno 
		end

        INSERT INTO MSrepl_commands VALUES (@publisher_database_id, 
            @12xact_seqno,@12type, @12article_id, 
            @originator_id, 
            @12command_id, @12partial_command, @12command)
    end


    IF @13xact_id = 0x0
      return
    IF @13command IS NOT NULL
    begin
            if @13originator <> N'' and @13originator_db <> N'' and @13originator is not null and @13originator_db is not null 
            begin 
                set @originator_id = null select @originator_id = id from MSrepl_originators where
                    publisher_database_id = @publisher_database_id and UPPER(srvname) = UPPER(@13originator) and
                    dbname = @13originator_db
                if @originator_id is null
                begin
                    insert into MSrepl_originators (publisher_database_id, srvname, dbname) values
                        (@publisher_database_id, @13originator, @13originator_db)
                    select @originator_id = @@identity
                end
            end
            else
                select @originator_id = 0
    
		if( @type in( 37,38 ) )
		begin
		  select @syncstat = 38 - @13type
		  exec sp_MSset_syncstate @publisher_id, @publisher_db, @13article_id, @syncstat, @13xact_seqno 
		end

        INSERT INTO MSrepl_commands VALUES (@publisher_database_id, 
            @13xact_seqno,@13type, @13article_id, 
            @originator_id, 
            @13command_id, @13partial_command, @13command)
    end

    IF @14xact_id = 0x0
      return
    IF @14command IS NOT NULL
    begin
            if @14originator <> N'' and @14originator_db <> N'' and @14originator is not null and @14originator_db is not null 
            begin 
                set @originator_id = null select @originator_id = id from MSrepl_originators where
                    publisher_database_id = @publisher_database_id and UPPER(srvname) = UPPER(@14originator) and
                    dbname = @14originator_db
                if @originator_id is null
                begin
                    insert into MSrepl_originators (publisher_database_id, srvname, dbname) values
                        (@publisher_database_id, @14originator, @14originator_db)
                    select @originator_id = @@identity
                end
            end
            else
                select @originator_id = 0
    
		if( @type in( 37,38 ) )
		begin
		  select @syncstat = 38 - @14type
		  exec sp_MSset_syncstate @publisher_id, @publisher_db, @14article_id, @syncstat, @14xact_seqno 
		end

        INSERT INTO MSrepl_commands VALUES (@publisher_database_id, 
            @14xact_seqno,@14type, @14article_id, 
            @originator_id, 
            @14command_id, @14partial_command, @14command)
    end


    IF @15xact_id = 0x0
      return
    IF @15command IS NOT NULL
    begin
            if @15originator <> N'' and @15originator_db <> N'' and @15originator is not null and @15originator_db is not null 
            begin 
                set @originator_id = null select @originator_id = id from MSrepl_originators where
                    publisher_database_id = @publisher_database_id and UPPER(srvname) = UPPER(@15originator) and
                    dbname = @15originator_db
                if @originator_id is null
                begin
                    insert into MSrepl_originators (publisher_database_id, srvname, dbname) values
                        (@publisher_database_id, @15originator, @15originator_db)
                    select @originator_id = @@identity
                end
            end
            else
                select @originator_id = 0
    
		if( @type in( 37,38 ) )
		begin
		  select @syncstat = 38 - @15type
		  exec sp_MSset_syncstate @publisher_id, @publisher_db, @15article_id, @syncstat, @15xact_seqno 
		end

        INSERT INTO MSrepl_commands VALUES (@publisher_database_id, 
            @15xact_seqno,@15type, @15article_id, 
            @originator_id, 
            @15command_id, @15partial_command, @15command)
    end

    IF @16xact_id = 0x0
      return
    IF @16command IS NOT NULL
    begin
            if @16originator <> N'' and @16originator_db <> N'' and @16originator is not null and @16originator_db is not null 
            begin 
                set @originator_id = null select @originator_id = id from MSrepl_originators where
                    publisher_database_id = @publisher_database_id and UPPER(srvname) = UPPER(@16originator) and
                    dbname = @16originator_db
                if @originator_id is null
                begin
                    insert into MSrepl_originators (publisher_database_id, srvname, dbname) values
                        (@publisher_database_id, @16originator, @16originator_db)
                    select @originator_id = @@identity
                end
            end
            else
                select @originator_id = 0
    
		if( @type in( 37,38 ) )
		begin
		  select @syncstat = 38 - @16type
		  exec sp_MSset_syncstate @publisher_id, @publisher_db, @16article_id, @syncstat, @16xact_seqno 
		end

        INSERT INTO MSrepl_commands VALUES (@publisher_database_id, 
            @16xact_seqno,@16type, @16article_id, 
            @originator_id, 
            @16command_id, @16partial_command, @16command)
    end


    IF @17xact_id = 0x0
      return
    IF @17command IS NOT NULL
    begin
            if @17originator <> N'' and @17originator_db <> N'' and @17originator is not null and @17originator_db is not null 
            begin 
                set @originator_id = null select @originator_id = id from MSrepl_originators where
                    publisher_database_id = @publisher_database_id and UPPER(srvname) = UPPER(@17originator) and
                    dbname = @17originator_db
                if @originator_id is null
                begin
                    insert into MSrepl_originators (publisher_database_id, srvname, dbname) values
                        (@publisher_database_id, @17originator, @17originator_db)
                    select @originator_id = @@identity
                end
            end
            else
                select @originator_id = 0
    
		if( @type in( 37,38 ) )
		begin
		  select @syncstat = 38 - @17type
		  exec sp_MSset_syncstate @publisher_id, @publisher_db, @17article_id, @syncstat, @17xact_seqno 
		end

        INSERT INTO MSrepl_commands VALUES (@publisher_database_id, 
            @17xact_seqno,@17type, @17article_id, 
            @originator_id, 
            @17command_id, @17partial_command, @17command)
    end


    IF @18xact_id = 0x0
      return
    IF @18command IS NOT NULL
    begin
            if @18originator <> N'' and @18originator_db <> N'' and @18originator is not null and @18originator_db is not null 
            begin 
                set @originator_id = null select @originator_id = id from MSrepl_originators where
                    publisher_database_id = @publisher_database_id and UPPER(srvname) = UPPER(@18originator) and
                    dbname = @18originator_db
                if @originator_id is null
                begin
                    insert into MSrepl_originators (publisher_database_id, srvname, dbname) values
                        (@publisher_database_id, @18originator, @18originator_db)
                    select @originator_id = @@identity
                end
            end
            else
                select @originator_id = 0
    
		if( @type in( 37,38 ) )
		begin
		  select @syncstat = 38 - @18type
		  exec sp_MSset_syncstate @publisher_id, @publisher_db, @18article_id, @syncstat, @18xact_seqno 
		end

        INSERT INTO MSrepl_commands VALUES (@publisher_database_id, 
            @18xact_seqno,@18type, @18article_id, 
            @originator_id, 
            @18command_id, @18partial_command, @18command)
    end


    IF @19xact_id = 0x0
      return
    IF @19command IS NOT NULL
    begin
            if @19originator <> N'' and @19originator_db <> N'' and @19originator is not null and @19originator_db is not null 
            begin 
                set @originator_id = null select @originator_id = id from MSrepl_originators where
                    publisher_database_id = @publisher_database_id and UPPER(srvname) = UPPER(@19originator) and
                    dbname = @19originator_db
                if @originator_id is null
                begin
                    insert into MSrepl_originators (publisher_database_id, srvname, dbname) values
                        (@publisher_database_id, @19originator, @19originator_db)
                    select @originator_id = @@identity
                end
            end
            else
                select @originator_id = 0
    
		if( @type in( 37,38 ) )
		begin
		  select @syncstat = 38 - @19type
		  exec sp_MSset_syncstate @publisher_id, @publisher_db, @19article_id, @syncstat, @19xact_seqno 
		end

        INSERT INTO MSrepl_commands VALUES (@publisher_database_id, 
            @19xact_seqno,@19type, @19article_id, 
            @originator_id, 
            @19command_id, @19partial_command, @19command)
    end


    IF @20xact_id = 0x0
      return
    IF @20command IS NOT NULL
    begin
            if @20originator <> N'' and @20originator_db <> N'' and @20originator is not null and @20originator_db is not null 
            begin 
                set @originator_id = null select @originator_id = id from MSrepl_originators where
                    publisher_database_id = @publisher_database_id and UPPER(srvname) = UPPER(@20originator) and
                    dbname = @20originator_db
                if @originator_id is null
                begin
                    insert into MSrepl_originators (publisher_database_id, srvname, dbname) values
                        (@publisher_database_id, @20originator, @20originator_db)
                    select @originator_id = @@identity
                end
            end
            else
                select @originator_id = 0
    
		if( @type in( 37,38 ) )
		begin
		  select @syncstat = 38 - @20type
		  exec sp_MSset_syncstate @publisher_id, @publisher_db, @20article_id, @syncstat, @20xact_seqno 
		end

        INSERT INTO MSrepl_commands VALUES (@publisher_database_id, 
            @20xact_seqno,@20type, @20article_id, 
            @originator_id, 
            @20command_id, @20partial_command, @20command)
    end

    IF @21xact_id = 0x0
      return
    IF @21command IS NOT NULL
    begin
            if @21originator <> N'' and @21originator_db <> N'' and @21originator is not null and @21originator_db is not null 
            begin 
                set @originator_id = null select @originator_id = id from MSrepl_originators where
                    publisher_database_id = @publisher_database_id and UPPER(srvname) = UPPER(@21originator) and
                    dbname = @21originator_db
                if @originator_id is null
                begin
                    insert into MSrepl_originators (publisher_database_id, srvname, dbname) values
                        (@publisher_database_id, @21originator, @21originator_db)
                    select @originator_id = @@identity
                end
            end
            else
                select @originator_id = 0
    
		if( @type in( 37,38 ) )
		begin
		  select @syncstat = 38 - @21type
		  exec sp_MSset_syncstate @publisher_id, @publisher_db, @21article_id, @syncstat, @21xact_seqno 
		end

        INSERT INTO MSrepl_commands VALUES (@publisher_database_id, 
            @21xact_seqno,@21type, @21article_id, 
            @originator_id, 
            @21command_id, @21partial_command, @21command)
    end

    IF @22xact_id = 0x0
      return
    IF @22command IS NOT NULL
    begin
            if @22originator <> N'' and @22originator_db <> N'' and @22originator is not null and @22originator_db is not null 
            begin 
                set @originator_id = null select @originator_id = id from MSrepl_originators where
                    publisher_database_id = @publisher_database_id and UPPER(srvname) = UPPER(@22originator) and
                    dbname = @22originator_db
                if @originator_id is null
                begin
                    insert into MSrepl_originators (publisher_database_id, srvname, dbname) values
                        (@publisher_database_id, @22originator, @22originator_db)
                    select @originator_id = @@identity
                end
            end
            else
                select @originator_id = 0
        end
    
		if( @type in( 37,38 ) )
		begin
		  select @syncstat = 38 - @22type
		  exec sp_MSset_syncstate @publisher_id, @publisher_db, @22article_id, @syncstat, @22xact_seqno 
		end

        INSERT INTO MSrepl_commands VALUES (@publisher_database_id, 
            @22xact_seqno,@22type, @22article_id, 
            @originator_id, 
            @22command_id, @22partial_command, @22command)


    IF @23xact_id = 0x0
      return
    IF @23command IS NOT NULL
    begin
            if @23originator <> N'' and @23originator_db <> N'' and @23originator is not null and @23originator_db is not null 
            begin 
                set @originator_id = null select @originator_id = id from MSrepl_originators where
                    publisher_database_id = @publisher_database_id and UPPER(srvname) = UPPER(@23originator) and
                    dbname = @23originator_db
                if @originator_id is null
                begin
                    insert into MSrepl_originators (publisher_database_id, srvname, dbname) values
                        (@publisher_database_id, @23originator, @23originator_db)
                    select @originator_id = @@identity
                end
            end
            else
                select @originator_id = 0
    
		if( @type in( 37,38 ) )
		begin
		  select @syncstat = 38 - @23type
		  exec sp_MSset_syncstate @publisher_id, @publisher_db, @23article_id, @syncstat, @23xact_seqno 
		end

        INSERT INTO MSrepl_commands VALUES (@publisher_database_id, 
            @23xact_seqno,@23type, @23article_id, 
            @originator_id, 
            @23command_id, @23partial_command, @23command)
    end

    IF @24xact_id = 0x0
      return
    IF @24command IS NOT NULL
    begin
            if @24originator <> N'' and @24originator_db <> N'' and @24originator is not null and @24originator_db is not null 
            begin 
                set @originator_id = null select @originator_id = id from MSrepl_originators where
                    publisher_database_id = @publisher_database_id and UPPER(srvname) = UPPER(@24originator) and
                    dbname = @24originator_db
                if @originator_id is null
                begin
                    insert into MSrepl_originators (publisher_database_id, srvname, dbname) values
                        (@publisher_database_id, @24originator, @24originator_db)
                    select @originator_id = @@identity
                end
            end
            else
                select @originator_id = 0
    
		if( @type in( 37,38 ) )
		begin
		  select @syncstat = 38 - @24type
		  exec sp_MSset_syncstate @publisher_id, @publisher_db, @24article_id, @syncstat, @24xact_seqno 
		end

        INSERT INTO MSrepl_commands VALUES (@publisher_database_id, 
            @24xact_seqno,@24type, @24article_id, 
            @originator_id, 
            @24command_id, @24partial_command, @24command)
    end


    IF @25xact_id = 0x0
      return
    IF @25command IS NOT NULL
    begin
            if @25originator <> N'' and @25originator_db <> N'' and @25originator is not null and @25originator_db is not null 
            begin 
                set @originator_id = null select @originator_id = id from MSrepl_originators where
                    publisher_database_id = @publisher_database_id and UPPER(srvname) = UPPER(@25originator) and
                    dbname = @25originator_db
                if @originator_id is null
                begin
                    insert into MSrepl_originators (publisher_database_id, srvname, dbname) values
                        (@publisher_database_id, @25originator, @25originator_db)
                    select @originator_id = @@identity
                end
            end
            else
                select @originator_id = 0
    
		if( @type in( 37,38 ) )
		begin
		  select @syncstat = 38 - @25type
		  exec sp_MSset_syncstate @publisher_id, @publisher_db, @25article_id, @syncstat, @25xact_seqno 
		end

        INSERT INTO MSrepl_commands VALUES (@publisher_database_id, 
            @25xact_seqno,@25type, @25article_id, 
            @originator_id, 
            @25command_id, @25partial_command, @25command)
    end


    IF @26xact_id = 0x0
      return
    IF @26command IS NOT NULL
    begin
            if @26originator <> N'' and @26originator_db <> N'' and @26originator is not null and @26originator_db is not null 
            begin 
                set @originator_id = null select @originator_id = id from MSrepl_originators where
                    publisher_database_id = @publisher_database_id and UPPER(srvname) = UPPER(@26originator) and
                    dbname = @26originator_db
                if @originator_id is null
                begin
                    insert into MSrepl_originators (publisher_database_id, srvname, dbname) values
                        (@publisher_database_id, @26originator, @26originator_db)
                    select @originator_id = @@identity
                end
            end
            else
                select @originator_id = 0
    
		if( @type in( 37,38 ) )
		begin
		  select @syncstat = 38 - @26type
		  exec sp_MSset_syncstate @publisher_id, @publisher_db, @26article_id, @syncstat, @26xact_seqno 
		end

        INSERT INTO MSrepl_commands VALUES (@publisher_database_id, 
            @26xact_seqno,@26type, @26article_id, 
            @originator_id, 
            @26command_id, @26partial_command, @26command)
    end


    IF @@ERROR <> 0
      return (1)
GO

raiserror(15339,-1,-1,'sp_MSadd_repl_commands27hp6x')
GO

CREATE PROCEDURE sp_MSadd_repl_commands27hp6x
@publisher_id smallint,
@publisher_db sysname,
@data varbinary( 1575 ),
@1data varbinary(1575) = NULL,
@2data varbinary(1575) = NULL,
@3data varbinary(1575) = NULL,
@4data varbinary(1575) = NULL,
@5data varbinary(1575) = NULL,
@6data varbinary(1575) = NULL,
@7data varbinary(1575) = NULL,
@8data varbinary(1575) = NULL,
@9data varbinary(1575) = NULL,
@10data varbinary(1575) = NULL,
@11data varbinary(1575) = NULL,
@12data varbinary(1575) = NULL,
@13data varbinary(1575) = NULL,
@14data varbinary(1575) = NULL,
@15data varbinary(1575) = NULL,
@16data varbinary(1575) = NULL,
@17data varbinary(1575) = NULL,
@18data varbinary(1575) = NULL,
@19data varbinary(1575) = NULL,
@20data varbinary(1575) = NULL,
@21data varbinary(1575) = NULL,
@22data varbinary(1575) = NULL,
@23data varbinary(1575) = NULL,
@24data varbinary(1575) = NULL,
@25data varbinary(1575) = NULL,
@26data varbinary(1575) = NULL
AS

    SET NOCOUNT ON

    DECLARE @xact_id    varbinary(10)
    DECLARE @xact_seqno varbinary(10)
    DECLARE @article_id int
    DECLARE @command_id int
    DECLARE @type       int
    DECLARE @partial_command bit
    DECLARE @command    varbinary(1024)

    DECLARE @originator sysname
    DECLARE @originator_db sysname

    DECLARE @publisher_database_id int
    DECLARE @date datetime
    declare @originator_id int

    DECLARE @cmd_data_len  smallint
    DECLARE @orig_srv_len smallint
    DECLARE @orig_db_len  smallint

    SELECT @date = GETDATE()

    -- Get publisher database id.
    SELECT @publisher_database_id = id from MSpublisher_databases where publisher_id = @publisher_id and 
        publisher_db = @publisher_db

    -- First insert into MS_repl_transactions
    IF convert( int, substring( @data, 25, 4 ) ) = 1
      INSERT INTO MSrepl_transactions VALUES (@publisher_database_id,
         substring( @data, 1, 6 ), substring( @data, 11, 8 ), @date)

    IF @1data is null
      goto INSERT_CMDS
    IF convert( int, substring( @1data, 25, 4 ) ) = 1
      INSERT INTO MSrepl_transactions VALUES (@publisher_database_id,
         substring( @1data, 1, 6 ), substring( @1data, 11, 8 ), @date)

    IF @2data is null
      goto INSERT_CMDS
    IF convert( int, substring( @2data, 25, 4 ) ) = 1
      INSERT INTO MSrepl_transactions VALUES (@publisher_database_id,
         substring( @2data, 1, 6 ), substring( @2data, 11, 8 ), @date)
    
    IF @3data is null
      goto INSERT_CMDS
    IF convert( int, substring( @3data, 25, 4 ) ) = 1
      INSERT INTO MSrepl_transactions VALUES (@publisher_database_id,
         substring( @3data, 1, 6 ), substring( @3data, 11, 8 ), @date)

    IF @4data is null
      goto INSERT_CMDS
    IF convert( int, substring( @4data, 25, 4 ) ) = 1
      INSERT INTO MSrepl_transactions VALUES (@publisher_database_id,
         substring( @4data, 1, 6 ), substring( @4data, 11, 8 ), @date)

    IF @5data is null
      goto INSERT_CMDS
    IF convert( int, substring( @5data, 25, 4 ) ) = 1
      INSERT INTO MSrepl_transactions VALUES (@publisher_database_id,
         substring( @5data, 1, 6 ), substring( @5data, 11, 8 ), @date)

    IF @6data is null
      goto INSERT_CMDS
    IF convert( int, substring( @6data, 25, 4 ) ) = 1
      INSERT INTO MSrepl_transactions VALUES (@publisher_database_id,
         substring( @6data, 1, 6 ), substring( @6data, 11, 8 ), @date)

    IF @7data is null
      goto INSERT_CMDS
    IF convert( int, substring( @7data, 25, 4 ) ) = 1
      INSERT INTO MSrepl_transactions VALUES (@publisher_database_id,
         substring( @7data, 1, 6 ), substring( @7data, 11, 8 ), @date)

    IF @8data is null
      goto INSERT_CMDS
    IF convert( int, substring( @8data, 25, 4 ) ) = 1
      INSERT INTO MSrepl_transactions VALUES (@publisher_database_id,
         substring( @8data, 1, 6 ), substring( @8data, 11, 8 ), @date)

    IF @9data is null
      goto INSERT_CMDS
    IF convert( int, substring( @9data, 25, 4 ) ) = 1
      INSERT INTO MSrepl_transactions VALUES (@publisher_database_id,
         substring( @9data, 1, 6 ), substring( @9data, 11, 8 ), @date)

    IF @10data is null
      goto INSERT_CMDS
    IF convert( int, substring( @10data, 25, 4 ) ) = 1
      INSERT INTO MSrepl_transactions VALUES (@publisher_database_id,
         substring( @10data, 1, 6 ), substring( @10data, 11, 8 ), @date)

    IF @11data is null
      goto INSERT_CMDS
    IF convert( int, substring( @11data, 25, 4 ) ) = 1
      INSERT INTO MSrepl_transactions VALUES (@publisher_database_id,
         substring( @11data, 1, 6 ), substring( @11data, 11, 8 ), @date)

    IF @12data is null
      goto INSERT_CMDS
    IF convert( int, substring( @12data, 25, 4 ) ) = 1
      INSERT INTO MSrepl_transactions VALUES (@publisher_database_id,
         substring( @12data, 1, 6 ), substring( @12data, 11, 8 ), @date)

    IF @13data is null
      goto INSERT_CMDS
    IF convert( int, substring( @13data, 25, 4 ) ) = 1
      INSERT INTO MSrepl_transactions VALUES (@publisher_database_id,
         substring( @13data, 1, 6 ), substring( @13data, 11, 8 ), @date)

    IF @14data is null
      goto INSERT_CMDS
    IF convert( int, substring( @14data, 25, 4 ) ) = 1
      INSERT INTO MSrepl_transactions VALUES (@publisher_database_id,
         substring( @14data, 1, 6 ), substring( @14data, 11, 8 ), @date)

    IF @15data is null
      goto INSERT_CMDS
    IF convert( int, substring( @15data, 25, 4 ) ) = 1
      INSERT INTO MSrepl_transactions VALUES (@publisher_database_id,
         substring( @15data, 1, 6 ), substring( @15data, 11, 8 ), @date)

    IF @16data is null
      goto INSERT_CMDS
    IF convert( int, substring( @16data, 25, 4 ) ) = 1
      INSERT INTO MSrepl_transactions VALUES (@publisher_database_id,
         substring( @16data, 1, 6 ), substring( @16data, 11, 8 ), @date)

    IF @17data is null
      goto INSERT_CMDS
    IF convert( int, substring( @17data, 25, 4 ) ) = 1
      INSERT INTO MSrepl_transactions VALUES (@publisher_database_id,
         substring( @17data, 1, 6 ), substring( @17data, 11, 8 ), @date)

    IF @18data is null
      goto INSERT_CMDS
    IF convert( int, substring( @18data, 25, 4 ) ) = 1
      INSERT INTO MSrepl_transactions VALUES (@publisher_database_id,
         substring( @18data, 1, 6 ), substring( @18data, 11, 8 ), @date)

    IF @19data is null
      goto INSERT_CMDS
    IF convert( int, substring( @19data, 25, 4 ) ) = 1
      INSERT INTO MSrepl_transactions VALUES (@publisher_database_id,
         substring( @19data, 1, 6 ), substring( @19data, 11, 8 ), @date)

    IF @20data is null
      goto INSERT_CMDS
    IF convert( int, substring( @20data, 25, 4 ) ) = 1
      INSERT INTO MSrepl_transactions VALUES (@publisher_database_id,
         substring( @20data, 1, 6 ), substring( @20data, 11, 8 ), @date)

    IF @21data is null
      goto INSERT_CMDS
    IF convert( int, substring( @21data, 25, 4 ) ) = 1
      INSERT INTO MSrepl_transactions VALUES (@publisher_database_id,
         substring( @21data, 1, 6 ), substring( @21data, 11, 8 ), @date)

    IF @22data is null
      goto INSERT_CMDS
    IF convert( int, substring( @22data, 25, 4 ) ) = 1
      INSERT INTO MSrepl_transactions VALUES (@publisher_database_id,
         substring( @22data, 1, 6 ), substring( @22data, 11, 8 ), @date)

    IF @23data is null
      goto INSERT_CMDS
    IF convert( int, substring( @23data, 25, 4 ) ) = 1
      INSERT INTO MSrepl_transactions VALUES (@publisher_database_id,
         substring( @23data, 1, 6 ), substring( @23data, 11, 8 ), @date)

    IF @24data is null
      goto INSERT_CMDS
    IF convert( int, substring( @24data, 25, 4 ) ) = 1
      INSERT INTO MSrepl_transactions VALUES (@publisher_database_id,
         substring( @24data, 1, 6 ), substring( @24data, 11, 8 ), @date)

    IF @25data is null
      goto INSERT_CMDS
    IF convert( int, substring( @25data, 25, 4 ) ) = 1
      INSERT INTO MSrepl_transactions VALUES (@publisher_database_id,
         substring( @25data, 1, 6 ), substring( @25data, 11, 8 ), @date)

    IF @26data is null
      goto INSERT_CMDS
    IF convert( int, substring( @26data, 25, 4 ) ) = 1
      INSERT INTO MSrepl_transactions VALUES (@publisher_database_id,
         substring( @26data, 1, 6 ), substring( @26data, 11, 8 ), @date)

INSERT_CMDS:

    if datalength( @data ) > 39
    begin
        -- Get the originator_id for the first command 
        select @cmd_data_len = substring( @data, 34, 2 )
        select @orig_srv_len = substring( @data, 36, 2 )
        select @orig_db_len = substring( @data, 38, 2 )

        if @orig_srv_len <> 0 and @orig_db_len <> 0 
        begin 
            set @originator_id = null 
            select @originator_id = id from MSrepl_originators where
                publisher_database_id = @publisher_database_id 
                and UPPER(srvname) = UPPER(convert(sysname, substring( @data, 40 + @cmd_data_len, @orig_srv_len )))
                and dbname = substring( @data, 40 + @cmd_data_len + @orig_srv_len, @orig_db_len )
            if @originator_id is null
            begin
                insert into MSrepl_originators (publisher_database_id, srvname, dbname) values
                    (@publisher_database_id, substring( @data, 40 + @cmd_data_len, @orig_srv_len ), substring( @data, 40 + @cmd_data_len + @orig_srv_len, @orig_db_len ))
                select @originator_id = @@identity
            end
        end
        else
            select @originator_id = 0

        INSERT INTO MSrepl_commands VALUES (@publisher_database_id, 
            substring(@data,11,8),
            substring(@data,29,4), 
            substring(@data,21,4), 
            @originator_id, 
            substring(@data,25,4), 
            convert(bit,substring(@data,33,1)), 
            substring(@data,40,@cmd_data_len) )
    end
    
    IF @1data is null
      return
    IF datalength( @1data ) > 39
    begin
        -- Get the originator_id for the first command 
        select @cmd_data_len = substring( @1data, 34, 2 )
        select @orig_srv_len = substring( @1data, 36, 2 )
        select @orig_db_len = substring( @1data, 38, 2 )
        if @orig_srv_len <> 0 and @orig_db_len <> 0 
        begin 
            set @originator_id = null 
            select @originator_id = id from MSrepl_originators where
                publisher_database_id = @publisher_database_id 
                and UPPER(srvname) = UPPER(convert(sysname, substring( @1data, 40 + @cmd_data_len, @orig_srv_len )))
                and dbname = substring( @1data, 40 + @cmd_data_len + @orig_srv_len, @orig_db_len )
            if @originator_id is null
            begin
                insert into MSrepl_originators (publisher_database_id, srvname, dbname) values
                    (@publisher_database_id, substring( @1data, 40 + @cmd_data_len, @orig_srv_len ), substring( @1data, 40 + @cmd_data_len + @orig_srv_len, @orig_db_len ))
                select @originator_id = @@identity
            end
        end
        else
            select @originator_id = 0

        -- Now insert into MSrepl_commands

        INSERT INTO MSrepl_commands VALUES (@publisher_database_id, 
            substring(@1data,11,8),
            substring(@1data,29,4), 
            substring(@1data,21,4), 
            @originator_id, 
            substring(@1data,25,4), 
            convert(bit,substring(@1data,33,1)), 
            substring(@1data,40,@cmd_data_len) )
    end

    IF @2data is null
      return
    IF datalength( @2data ) > 39
    begin
        -- Get the originator_id for the first command 
        select @cmd_data_len = substring( @2data, 34, 2 )
        select @orig_srv_len = substring( @2data, 36, 2 )
        select @orig_db_len = substring( @2data, 38, 2 )
        if @orig_srv_len <> 0 and @orig_db_len <> 0 
        begin 
            set @originator_id = null 
            select @originator_id = id from MSrepl_originators where
                publisher_database_id = @publisher_database_id 
                and UPPER(srvname) = UPPER(convert(sysname, substring( @2data, 40 + @cmd_data_len, @orig_srv_len )))
                and dbname = substring( @2data, 40 + @cmd_data_len + @orig_srv_len, @orig_db_len )
            if @originator_id is null
            begin
                insert into MSrepl_originators (publisher_database_id, srvname, dbname) values
                    (@publisher_database_id, substring( @2data, 40 + @cmd_data_len, @orig_srv_len ), substring( @2data, 40 + @cmd_data_len + @orig_srv_len, @orig_db_len ))
                select @originator_id = @@identity
            end
        end
        else
            select @originator_id = 0

        -- Now insert into MSrepl_commands

        INSERT INTO MSrepl_commands VALUES (@publisher_database_id, 
            substring(@2data,11 ,8),
            substring(@2data,29 ,4), 
            substring(@2data,21 ,4), 
            @originator_id, 
            substring(@2data,25 ,4), 
            convert(bit,substring(@2data,33 ,1)), 
            substring(@2data,40,@cmd_data_len) )
    end

    IF @3data is null
      return
    IF datalength( @3data ) > 39
    begin
        -- Get the originator_id for the first command 
        select @cmd_data_len = substring( @3data, 34, 2 )
        select @orig_srv_len = substring( @3data, 36, 2 )
        select @orig_db_len = substring( @3data, 38, 2 )
        if @orig_srv_len <> 0 and @orig_db_len <> 0 
        begin 
            set @originator_id = null 
            select @originator_id = id from MSrepl_originators where
                publisher_database_id = @publisher_database_id 
                and UPPER(srvname) = UPPER(convert(sysname, substring( @3data, 40 + @cmd_data_len, @orig_srv_len )))
                and dbname = substring( @3data, 40 + @cmd_data_len + @orig_srv_len, @orig_db_len )
            if @originator_id is null
            begin
                insert into MSrepl_originators (publisher_database_id, srvname, dbname) values
                    (@publisher_database_id, substring( @3data, 40 + @cmd_data_len, @orig_srv_len ), substring( @3data, 40 + @cmd_data_len + @orig_srv_len, @orig_db_len ))
                select @originator_id = @@identity
            end
        end
        else
            select @originator_id = 0

        -- Now insert into MSrepl_commands

        INSERT INTO MSrepl_commands VALUES (@publisher_database_id, 
            substring(@3data,11 ,8),
            substring(@3data,29 ,4), 
            substring(@3data,21 ,4), 
            @originator_id, 
            substring(@3data,25 ,4), 
            convert(bit,substring(@3data,33 ,1)), 
            substring(@3data,40,@cmd_data_len) )
    end

    IF @4data is null
      return
    IF datalength( @4data ) > 39
    begin
        -- Get the originator_id for the first command 
        select @cmd_data_len = substring( @4data, 34, 2 )
        select @orig_srv_len = substring( @4data, 36, 2 )
        select @orig_db_len = substring( @4data, 38, 2 )
        if @orig_srv_len <> 0 and @orig_db_len <> 0 
        begin 
            set @originator_id = null 
            select @originator_id = id from MSrepl_originators where
                publisher_database_id = @publisher_database_id 
                and UPPER(srvname) = UPPER(convert(sysname, substring( @4data, 40 + @cmd_data_len, @orig_srv_len )))
                and dbname = substring( @4data, 40 + @cmd_data_len + @orig_srv_len, @orig_db_len )
            if @originator_id is null
            begin
                insert into MSrepl_originators (publisher_database_id, srvname, dbname) values
                    (@publisher_database_id, substring( @4data, 40 + @cmd_data_len, @orig_srv_len ), substring( @4data, 40 + @cmd_data_len + @orig_srv_len, @orig_db_len ))
                select @originator_id = @@identity
            end
        end
        else
            select @originator_id = 0

        -- Now insert into MSrepl_commands

        INSERT INTO MSrepl_commands VALUES (@publisher_database_id, 
            substring(@4data,11 ,8),
            substring(@4data,29 ,4), 
            substring(@4data,21 ,4), 
            @originator_id, 
            substring(@4data,25 ,4), 
            convert(bit,substring(@4data,33 ,1)), 
            substring(@4data,40,@cmd_data_len) )
    end

    IF @5data is null
      return
    IF datalength( @5data ) > 39
    begin
        -- Get the originator_id for the first command 
        select @cmd_data_len = substring( @5data, 34, 2 )
        select @orig_srv_len = substring( @5data, 36, 2 )
        select @orig_db_len = substring( @5data, 38, 2 )
        if @orig_srv_len <> 0 and @orig_db_len <> 0 
        begin 
            set @originator_id = null 
            select @originator_id = id from MSrepl_originators where
                publisher_database_id = @publisher_database_id 
                and UPPER(srvname) = UPPER(convert(sysname, substring( @5data, 40 + @cmd_data_len, @orig_srv_len )))
                and dbname = substring( @5data, 40 + @cmd_data_len + @orig_srv_len, @orig_db_len )
            if @originator_id is null
            begin
                insert into MSrepl_originators (publisher_database_id, srvname, dbname) values
                    (@publisher_database_id, substring( @5data, 40 + @cmd_data_len, @orig_srv_len ), substring( @5data, 40 + @cmd_data_len + @orig_srv_len, @orig_db_len ))
                select @originator_id = @@identity
            end
        end
        else
            select @originator_id = 0

        -- Now insert into MSrepl_commands

        INSERT INTO MSrepl_commands VALUES (@publisher_database_id, 
            substring(@5data,11 ,8),
            substring(@5data,29 ,4), 
            substring(@5data,21 ,4), 
            @originator_id, 
            substring(@5data,25 ,4), 
            convert(bit,substring(@5data,33 ,1)), 
            substring(@5data,40,@cmd_data_len) )
    end

    IF @6data is null
      return
    IF datalength( @6data ) > 39
    begin
        -- Get the originator_id for the first command 
        select @cmd_data_len = substring( @6data, 34, 2 )
        select @orig_srv_len = substring( @6data, 36, 2 )
        select @orig_db_len = substring( @6data, 38, 2 )
        if @orig_srv_len <> 0 and @orig_db_len <> 0 
        begin 
            set @originator_id = null 
            select @originator_id = id from MSrepl_originators where
                publisher_database_id = @publisher_database_id 
                and UPPER(srvname) = UPPER(convert(sysname, substring( @6data, 40 + @cmd_data_len, @orig_srv_len )))
                and dbname = substring( @6data, 40 + @cmd_data_len + @orig_srv_len, @orig_db_len )
            if @originator_id is null
            begin
                insert into MSrepl_originators (publisher_database_id, srvname, dbname) values
                    (@publisher_database_id, substring( @6data, 40 + @cmd_data_len, @orig_srv_len ), substring( @6data, 40 + @cmd_data_len + @orig_srv_len, @orig_db_len ))
                select @originator_id = @@identity
            end
        end
        else
            select @originator_id = 0

        -- Now insert into MSrepl_commands

        INSERT INTO MSrepl_commands VALUES (@publisher_database_id, 
            substring(@6data,11 ,8),
            substring(@6data,29 ,4), 
            substring(@6data,21 ,4), 
            @originator_id, 
            substring(@6data,25 ,4), 
            convert(bit,substring(@6data,33 ,1)), 
            substring(@6data,40,@cmd_data_len) )
    end

    IF @7data is null
      return
    IF datalength( @7data ) > 39
    begin
        -- Get the originator_id for the first command 
        select @cmd_data_len = substring( @7data, 34, 2 )
        select @orig_srv_len = substring( @7data, 36, 2 )
        select @orig_db_len = substring( @7data, 38, 2 )
        if @orig_srv_len <> 0 and @orig_db_len <> 0 
        begin 
            set @originator_id = null 
            select @originator_id = id from MSrepl_originators where
                publisher_database_id = @publisher_database_id 
                and UPPER(srvname) = UPPER(convert(sysname, substring( @7data, 40 + @cmd_data_len, @orig_srv_len )))
                and dbname = substring( @7data, 40 + @cmd_data_len + @orig_srv_len, @orig_db_len )
            if @originator_id is null
            begin
                insert into MSrepl_originators (publisher_database_id, srvname, dbname) values
                    (@publisher_database_id, substring( @7data, 40 + @cmd_data_len, @orig_srv_len ), substring( @7data, 40 + @cmd_data_len + @orig_srv_len, @orig_db_len ))
                select @originator_id = @@identity
            end
        end
        else
            select @originator_id = 0

        -- Now insert into MSrepl_commands

        INSERT INTO MSrepl_commands VALUES (@publisher_database_id, 
            substring(@7data,11 ,8),
            substring(@7data,29 ,4), 
            substring(@7data,21 ,4), 
            @originator_id, 
            substring(@7data,25 ,4), 
            convert(bit,substring(@7data,33 ,1)), 
            substring(@7data,40,@cmd_data_len) )
    end

    IF @8data is null
      return
    IF datalength( @8data ) > 39
    begin
        -- Get the originator_id for the first command 
        select @cmd_data_len = substring( @8data, 34, 2 )
        select @orig_srv_len = substring( @8data, 36, 2 )
        select @orig_db_len = substring( @8data, 38, 2 )
        if @orig_srv_len <> 0 and @orig_db_len <> 0 
        begin 
            set @originator_id = null 
            select @originator_id = id from MSrepl_originators where
                publisher_database_id = @publisher_database_id 
                and UPPER(srvname) = UPPER(convert(sysname, substring( @8data, 40 + @cmd_data_len, @orig_srv_len )))
                and dbname = substring( @8data, 40 + @cmd_data_len + @orig_srv_len, @orig_db_len )
            if @originator_id is null
            begin
                insert into MSrepl_originators (publisher_database_id, srvname, dbname) values
                    (@publisher_database_id, substring( @8data, 40 + @cmd_data_len, @orig_srv_len ), substring( @8data, 40 + @cmd_data_len + @orig_srv_len, @orig_db_len ))
                select @originator_id = @@identity
            end
        end
        else
            select @originator_id = 0

        -- Now insert into MSrepl_commands

        INSERT INTO MSrepl_commands VALUES (@publisher_database_id, 
            substring(@8data,11 ,8),
            substring(@8data,29 ,4), 
            substring(@8data,21 ,4), 
            @originator_id, 
            substring(@8data,25 ,4), 
            convert(bit,substring(@8data,33 ,1)), 
            substring(@8data,40,@cmd_data_len) )
    end

    IF @9data is null
      return
    IF datalength( @9data ) > 39
    begin
        -- Get the originator_id for the first command 
        select @cmd_data_len = substring( @9data, 34, 2 )
        select @orig_srv_len = substring( @9data, 36, 2 )
        select @orig_db_len = substring( @9data, 38, 2 )
        if @orig_srv_len <> 0 and @orig_db_len <> 0 
        begin 
            set @originator_id = null 
            select @originator_id = id from MSrepl_originators where
                publisher_database_id = @publisher_database_id 
                and UPPER(srvname) = UPPER(convert(sysname, substring( @9data, 40 + @cmd_data_len, @orig_srv_len )))
                and dbname = substring( @9data, 40 + @cmd_data_len + @orig_srv_len, @orig_db_len )
            if @originator_id is null
            begin
                insert into MSrepl_originators (publisher_database_id, srvname, dbname) values
                    (@publisher_database_id, substring( @9data, 40 + @cmd_data_len, @orig_srv_len ), substring( @9data, 40 + @cmd_data_len + @orig_srv_len, @orig_db_len ))
                select @originator_id = @@identity
            end
        end
        else
            select @originator_id = 0

        -- Now insert into MSrepl_commands

        INSERT INTO MSrepl_commands VALUES (@publisher_database_id, 
            substring(@9data,11 ,8),
            substring(@9data,29 ,4), 
            substring(@9data,21 ,4), 
            @originator_id, 
            substring(@9data,25 ,4), 
            convert(bit,substring(@9data,33 ,1)), 
            substring(@9data,40,@cmd_data_len) )
    end

    IF @10data is null
      return
    IF datalength( @10data ) > 39
    begin
        -- Get the originator_id for the first command 
        select @cmd_data_len = substring( @10data, 34, 2 )
        select @orig_srv_len = substring( @10data, 36, 2 )
        select @orig_db_len = substring( @10data, 38, 2 )
        if @orig_srv_len <> 0 and @orig_db_len <> 0 
        begin 
            set @originator_id = null 
            select @originator_id = id from MSrepl_originators where
                publisher_database_id = @publisher_database_id 
                and UPPER(srvname) = upper(convert(sysname, substring( @10data, 40 + @cmd_data_len, @orig_srv_len )))
                and dbname = substring( @10data, 40 + @cmd_data_len + @orig_srv_len, @orig_db_len )
            if @originator_id is null
            begin
                insert into MSrepl_originators (publisher_database_id, srvname, dbname) values
                    (@publisher_database_id, substring( @10data, 40 + @cmd_data_len, @orig_srv_len ), substring( @10data, 40 + @cmd_data_len + @orig_srv_len, @orig_db_len ))
                select @originator_id = @@identity
            end
        end
        else
            select @originator_id = 0

        -- Now insert into MSrepl_commands

        INSERT INTO MSrepl_commands VALUES (@publisher_database_id, 
            substring(@10data,11 ,8),
            substring(@10data,29 ,4), 
            substring(@10data,21 ,4), 
            @originator_id, 
            substring(@10data,25 ,4), 
            convert(bit,substring(@10data,33 ,1)), 
            substring(@10data,40,@cmd_data_len) )
    end

    IF @11data is null
      return
    IF datalength( @11data ) > 39
    begin
        -- Get the originator_id for the first command 
        select @cmd_data_len = substring( @11data, 34, 2 )
        select @orig_srv_len = substring( @11data, 36, 2 )
        select @orig_db_len = substring( @11data, 38, 2 )
        if @orig_srv_len <> 0 and @orig_db_len <> 0 
        begin 
            set @originator_id = null 
            select @originator_id = id from MSrepl_originators where
                publisher_database_id = @publisher_database_id 
                and UPPER(srvname) = upper(convert(sysname, substring( @11data, 40 + @cmd_data_len, @orig_srv_len )))
                and dbname = substring( @11data, 40 + @cmd_data_len + @orig_srv_len, @orig_db_len )
            if @originator_id is null
            begin
                insert into MSrepl_originators (publisher_database_id, srvname, dbname) values
                    (@publisher_database_id, substring( @11data, 40 + @cmd_data_len, @orig_srv_len ), substring( @11data, 40 + @cmd_data_len + @orig_srv_len, @orig_db_len ))
                select @originator_id = @@identity
            end
        end
        else
            select @originator_id = 0

        -- Now insert into MSrepl_commands

        INSERT INTO MSrepl_commands VALUES (@publisher_database_id, 
            substring(@11data,11 ,8),
            substring(@11data,29 ,4), 
            substring(@11data,21 ,4), 
            @originator_id, 
            substring(@11data,25 ,4), 
            convert(bit,substring(@11data,33 ,1)), 
            substring(@11data,40,@cmd_data_len) )
    end

    IF @12data is null
      return
    IF datalength( @12data ) > 39
    begin
        -- Get the originator_id for the first command 
        select @cmd_data_len = substring( @12data, 34, 2 )
        select @orig_srv_len = substring( @12data, 36, 2 )
        select @orig_db_len = substring( @12data, 38, 2 )
        if @orig_srv_len <> 0 and @orig_db_len <> 0 
        begin 
            set @originator_id = null 
            select @originator_id = id from MSrepl_originators where
                publisher_database_id = @publisher_database_id 
                and UPPER(srvname) = upper(convert(sysname, substring( @12data, 40 + @cmd_data_len, @orig_srv_len )))
                and dbname = substring( @12data, 40 + @cmd_data_len + @orig_srv_len, @orig_db_len )
            if @originator_id is null
            begin
                insert into MSrepl_originators (publisher_database_id, srvname, dbname) values
                    (@publisher_database_id, substring( @12data, 40 + @cmd_data_len, @orig_srv_len ), substring( @12data, 40 + @cmd_data_len + @orig_srv_len, @orig_db_len ))
                select @originator_id = @@identity
            end
        end
        else
            select @originator_id = 0

        -- Now insert into MSrepl_commands

        INSERT INTO MSrepl_commands VALUES (@publisher_database_id, 
            substring(@12data,11 ,8),
            substring(@12data,29 ,4), 
            substring(@12data,21 ,4), 
            @originator_id, 
            substring(@12data,25 ,4), 
            convert(bit,substring(@12data,33 ,1)), 
            substring(@12data,40,@cmd_data_len) )
    end


    IF @13data is null
      return
    IF datalength( @13data ) > 39
    begin
        -- Get the originator_id for the first command 
        select @cmd_data_len = substring( @13data, 34, 2 )
        select @orig_srv_len = substring( @13data, 36, 2 )
        select @orig_db_len = substring( @13data, 38, 2 )
        if @orig_srv_len <> 0 and @orig_db_len <> 0 
        begin 
            set @originator_id = null 
            select @originator_id = id from MSrepl_originators where
                publisher_database_id = @publisher_database_id 
                and UPPER(srvname) = upper(convert(sysname, substring( @13data, 40 + @cmd_data_len, @orig_srv_len )))
                and dbname = substring( @13data, 40 + @cmd_data_len + @orig_srv_len, @orig_db_len )
            if @originator_id is null
            begin
                insert into MSrepl_originators (publisher_database_id, srvname, dbname) values
                    (@publisher_database_id, substring( @13data, 40 + @cmd_data_len, @orig_srv_len ), substring( @13data, 40 + @cmd_data_len + @orig_srv_len, @orig_db_len ))
                select @originator_id = @@identity
            end
        end
        else
            select @originator_id = 0

        -- Now insert into MSrepl_commands

        INSERT INTO MSrepl_commands VALUES (@publisher_database_id, 
            substring(@13data,11 ,8),
            substring(@13data,29 ,4), 
            substring(@13data,21 ,4), 
            @originator_id, 
            substring(@13data,25 ,4), 
            convert(bit,substring(@13data,33 ,1)), 
            substring(@13data,40,@cmd_data_len) )
    end

    IF @14data is null
      return
    IF datalength( @14data ) > 39
    begin
        -- Get the originator_id for the first command 
        select @cmd_data_len = substring( @14data, 34, 2 )
        select @orig_srv_len = substring( @14data, 36, 2 )
        select @orig_db_len = substring( @14data, 38, 2 )
        if @orig_srv_len <> 0 and @orig_db_len <> 0 
        begin 
            set @originator_id = null 
            select @originator_id = id from MSrepl_originators where
                publisher_database_id = @publisher_database_id 
                and UPPER(srvname) = upper(convert(sysname, substring( @14data, 40 + @cmd_data_len, @orig_srv_len )))
                and dbname = substring( @14data, 40 + @cmd_data_len + @orig_srv_len, @orig_db_len )
            if @originator_id is null
            begin
                insert into MSrepl_originators (publisher_database_id, srvname, dbname) values
                    (@publisher_database_id, substring( @14data, 40 + @cmd_data_len, @orig_srv_len ), substring( @14data, 40 + @cmd_data_len + @orig_srv_len, @orig_db_len ))
                select @originator_id = @@identity
            end
        end
        else
            select @originator_id = 0

        -- Now insert into MSrepl_commands

        INSERT INTO MSrepl_commands VALUES (@publisher_database_id, 
            substring(@14data,11 ,8),
            substring(@14data,29 ,4), 
            substring(@14data,21 ,4), 
            @originator_id, 
            substring(@14data,25 ,4), 
            convert(bit,substring(@14data,33 ,1)), 
            substring(@14data,40,@cmd_data_len) )
    end


    IF @15data is null
      return
    IF datalength( @15data ) > 39
    begin
        -- Get the originator_id for the first command 
        select @cmd_data_len = substring( @15data, 34, 2 )
        select @orig_srv_len = substring( @15data, 36, 2 )
        select @orig_db_len = substring( @15data, 38, 2 )
        if @orig_srv_len <> 0 and @orig_db_len <> 0 
        begin 
            set @originator_id = null 
            select @originator_id = id from MSrepl_originators where
                publisher_database_id = @publisher_database_id 
                and UPPER(srvname) = upper(convert(sysname, substring( @15data, 40 + @cmd_data_len, @orig_srv_len )))
                and dbname = substring( @15data, 40 + @cmd_data_len + @orig_srv_len, @orig_db_len )
            if @originator_id is null
            begin
                insert into MSrepl_originators (publisher_database_id, srvname, dbname) values
                    (@publisher_database_id, substring( @15data, 40 + @cmd_data_len, @orig_srv_len ), substring( @15data, 40 + @cmd_data_len + @orig_srv_len, @orig_db_len ))
                select @originator_id = @@identity
            end
        end
        else
            select @originator_id = 0

        -- Now insert into MSrepl_commands

        INSERT INTO MSrepl_commands VALUES (@publisher_database_id, 
            substring(@15data,11 ,8),
            substring(@15data,29 ,4), 
            substring(@15data,21 ,4), 
            @originator_id, 
            substring(@15data,25 ,4), 
            convert(bit,substring(@15data,33 ,1)), 
            substring(@15data,40,@cmd_data_len) )
    end

    IF @16data is null
      return
    IF datalength( @16data ) > 39
    begin
        -- Get the originator_id for the first command 
        select @cmd_data_len = substring( @16data, 34, 2 )
        select @orig_srv_len = substring( @16data, 36, 2 )
        select @orig_db_len = substring( @16data, 38, 2 )
        if @orig_srv_len <> 0 and @orig_db_len <> 0 
        begin 
            set @originator_id = null 
            select @originator_id = id from MSrepl_originators where
                publisher_database_id = @publisher_database_id 
                and UPPER(srvname) = upper(convert(sysname, substring( @16data, 40 + @cmd_data_len, @orig_srv_len )))
                and dbname = substring( @16data, 40 + @cmd_data_len + @orig_srv_len, @orig_db_len )
            if @originator_id is null
            begin
                insert into MSrepl_originators (publisher_database_id, srvname, dbname) values
                    (@publisher_database_id, substring( @16data, 40 + @cmd_data_len, @orig_srv_len ), substring( @16data, 40 + @cmd_data_len + @orig_srv_len, @orig_db_len ))
                select @originator_id = @@identity
            end
        end
        else
            select @originator_id = 0

        -- Now insert into MSrepl_commands

        INSERT INTO MSrepl_commands VALUES (@publisher_database_id, 
            substring(@16data,11 ,8),
            substring(@16data,29 ,4), 
            substring(@16data,21 ,4), 
            @originator_id, 
            substring(@16data,25 ,4), 
            convert(bit,substring(@16data,33 ,1)), 
            substring(@16data,40,@cmd_data_len) )
    end


    IF @17data is null
      return
    IF datalength( @17data ) > 39
    begin
        -- Get the originator_id for the first command 
        select @cmd_data_len = substring( @17data, 34, 2 )
        select @orig_srv_len = substring( @17data, 36, 2 )
        select @orig_db_len = substring( @17data, 38, 2 )
        if @orig_srv_len <> 0 and @orig_db_len <> 0 
        begin 
            set @originator_id = null 
            select @originator_id = id from MSrepl_originators where
                publisher_database_id = @publisher_database_id 
                and UPPER(srvname) = upper(convert(sysname, substring( @17data, 40 + @cmd_data_len, @orig_srv_len )))
                and dbname = substring( @17data, 40 + @cmd_data_len + @orig_srv_len, @orig_db_len )
            if @originator_id is null
            begin
                insert into MSrepl_originators (publisher_database_id, srvname, dbname) values
                    (@publisher_database_id, substring( @17data, 40 + @cmd_data_len, @orig_srv_len ), substring( @17data, 40 + @cmd_data_len + @orig_srv_len, @orig_db_len ))
                select @originator_id = @@identity
            end
        end
        else
            select @originator_id = 0

        -- Now insert into MSrepl_commands

        INSERT INTO MSrepl_commands VALUES (@publisher_database_id, 
            substring(@17data,11 ,8),
            substring(@17data,29 ,4), 
            substring(@17data,21 ,4), 
            @originator_id, 
            substring(@17data,25 ,4), 
            convert(bit,substring(@17data,33 ,1)), 
            substring(@17data,40,@cmd_data_len) )
    end


    IF @18data is null
      return
    IF datalength( @18data ) > 39
    begin
        -- Get the originator_id for the first command 
        select @cmd_data_len = substring( @18data, 34, 2 )
        select @orig_srv_len = substring( @18data, 36, 2 )
        select @orig_db_len = substring( @18data, 38, 2 )
        if @orig_srv_len <> 0 and @orig_db_len <> 0 
        begin 
            set @originator_id = null 
            select @originator_id = id from MSrepl_originators where
                publisher_database_id = @publisher_database_id 
                and UPPER(srvname) = upper(convert(sysname, substring( @18data, 40 + @cmd_data_len, @orig_srv_len )))
                and dbname = substring( @18data, 40 + @cmd_data_len + @orig_srv_len, @orig_db_len )
            if @originator_id is null
            begin
                insert into MSrepl_originators (publisher_database_id, srvname, dbname) values
                    (@publisher_database_id, substring( @18data, 40 + @cmd_data_len, @orig_srv_len ), substring( @18data, 40 + @cmd_data_len + @orig_srv_len, @orig_db_len ))
                select @originator_id = @@identity
            end
        end
        else
            select @originator_id = 0

        -- Now insert into MSrepl_commands

        INSERT INTO MSrepl_commands VALUES (@publisher_database_id, 
            substring(@18data,11 ,8),
            substring(@18data,29 ,4), 
            substring(@18data,21 ,4), 
            @originator_id, 
            substring(@18data,25 ,4), 
            convert(bit,substring(@18data,33 ,1)), 
            substring(@18data,40,@cmd_data_len) )
    end


    IF @19data is null
      return
    IF datalength( @19data ) > 39
    begin
        -- Get the originator_id for the first command 
        select @cmd_data_len = substring( @19data, 34, 2 )
        select @orig_srv_len = substring( @19data, 36, 2 )
        select @orig_db_len = substring( @19data, 38, 2 )
        if @orig_srv_len <> 0 and @orig_db_len <> 0 
        begin 
            set @originator_id = null 
            select @originator_id = id from MSrepl_originators where
                publisher_database_id = @publisher_database_id 
                and UPPER(srvname) = upper(convert(sysname, substring( @19data, 40 + @cmd_data_len, @orig_srv_len )))
                and dbname = substring( @19data, 40 + @cmd_data_len + @orig_srv_len, @orig_db_len )
            if @originator_id is null
            begin
                insert into MSrepl_originators (publisher_database_id, srvname, dbname) values
                    (@publisher_database_id, substring( @19data, 40 + @cmd_data_len, @orig_srv_len ), substring( @19data, 40 + @cmd_data_len + @orig_srv_len, @orig_db_len ))
                select @originator_id = @@identity
            end
        end
        else
            select @originator_id = 0

        -- Now insert into MSrepl_commands

        INSERT INTO MSrepl_commands VALUES (@publisher_database_id, 
            substring(@19data,11 ,8),
            substring(@19data,29 ,4), 
            substring(@19data,21 ,4), 
            @originator_id, 
            substring(@19data,25 ,4), 
            convert(bit,substring(@19data,33 ,1)), 
            substring(@19data,40,@cmd_data_len) )
    end


    IF @20data is null
      return
    IF datalength( @20data ) > 39
    begin
        -- Get the originator_id for the first command 
        select @cmd_data_len = substring( @20data, 34, 2 )
        select @orig_srv_len = substring( @20data, 36, 2 )
        select @orig_db_len = substring( @20data, 38, 2 )
        if @orig_srv_len <> 0 and @orig_db_len <> 0 
        begin 
            set @originator_id = null 
            select @originator_id = id from MSrepl_originators where
                publisher_database_id = @publisher_database_id 
                and UPPER(srvname) = upper(convert(sysname, substring( @20data, 40 + @cmd_data_len, @orig_srv_len )))
                and dbname = substring( @20data, 40 + @cmd_data_len + @orig_srv_len, @orig_db_len )
            if @originator_id is null
            begin
                insert into MSrepl_originators (publisher_database_id, srvname, dbname) values
                    (@publisher_database_id, substring( @20data, 40 + @cmd_data_len, @orig_srv_len ), substring( @20data, 40 + @cmd_data_len + @orig_srv_len, @orig_db_len ))
                select @originator_id = @@identity
            end
        end
        else
            select @originator_id = 0

        -- Now insert into MSrepl_commands

        INSERT INTO MSrepl_commands VALUES (@publisher_database_id, 
            substring(@20data,11 ,8),
            substring(@20data,29 ,4), 
            substring(@20data,21 ,4), 
            @originator_id, 
            substring(@20data,25 ,4), 
            convert(bit,substring(@20data,33 ,1)), 
            substring(@20data,40,@cmd_data_len) )
    end

    IF @21data is null
      return
    IF datalength( @21data ) > 39
    begin
        -- Get the originator_id for the first command 
        select @cmd_data_len = substring( @21data, 34, 2 )
        select @orig_srv_len = substring( @21data, 36, 2 )
        select @orig_db_len = substring( @21data, 38, 2 )
        if @orig_srv_len <> 0 and @orig_db_len <> 0 
        begin 
            set @originator_id = null 
            select @originator_id = id from MSrepl_originators where
                publisher_database_id = @publisher_database_id 
                and UPPER(srvname) = upper(convert(sysname, substring( @21data, 40 + @cmd_data_len, @orig_srv_len )))
                and dbname = substring( @21data, 40 + @cmd_data_len + @orig_srv_len, @orig_db_len )
            if @originator_id is null
            begin
                insert into MSrepl_originators (publisher_database_id, srvname, dbname) values
                    (@publisher_database_id, substring( @21data, 40 + @cmd_data_len, @orig_srv_len ), substring( @21data, 40 + @cmd_data_len + @orig_srv_len, @orig_db_len ))
                select @originator_id = @@identity
            end
        end
        else
            select @originator_id = 0

        -- Now insert into MSrepl_commands

        INSERT INTO MSrepl_commands VALUES (@publisher_database_id, 
            substring(@21data,11 ,8),
            substring(@21data,29 ,4), 
            substring(@21data,21 ,4), 
            @originator_id, 
            substring(@21data,25 ,4), 
            convert(bit,substring(@21data,33 ,1)), 
            substring(@21data,40,@cmd_data_len) )
    end

    IF @22data is null
      return
    IF datalength( @22data ) > 39
    begin
        -- Get the originator_id for the first command 
        select @cmd_data_len = substring( @22data, 34, 2 )
        select @orig_srv_len = substring( @22data, 36, 2 )
        select @orig_db_len = substring( @22data, 38, 2 )
        if @orig_srv_len <> 0 and @orig_db_len <> 0 
        begin 
            set @originator_id = null 
            select @originator_id = id from MSrepl_originators where
                publisher_database_id = @publisher_database_id 
                and UPPER(srvname) = upper(convert(sysname, substring( @22data, 40 + @cmd_data_len, @orig_srv_len )))
                and dbname = substring( @22data, 40 + @cmd_data_len + @orig_srv_len, @orig_db_len )
            if @originator_id is null
            begin
                insert into MSrepl_originators (publisher_database_id, srvname, dbname) values
                    (@publisher_database_id, substring( @22data, 40 + @cmd_data_len, @orig_srv_len ), substring( @22data, 40 + @cmd_data_len + @orig_srv_len, @orig_db_len ))
                select @originator_id = @@identity
            end
        end
        else
            select @originator_id = 0

        -- Now insert into MSrepl_commands

        INSERT INTO MSrepl_commands VALUES (@publisher_database_id, 
            substring(@22data,11 ,8),
            substring(@22data,29 ,4), 
            substring(@22data,21 ,4), 
            @originator_id, 
            substring(@22data,25 ,4), 
            convert(bit,substring(@22data,33 ,1)), 
            substring(@22data,40,@cmd_data_len) )
    end

    IF @23data is null
      return
    IF datalength( @23data ) > 39
    begin
        -- Get the originator_id for the first command 
        select @cmd_data_len = substring( @23data, 34, 2 )
        select @orig_srv_len = substring( @23data, 36, 2 )
        select @orig_db_len = substring( @23data, 38, 2 )
        if @orig_srv_len <> 0 and @orig_db_len <> 0 
        begin 
            set @originator_id = null 
            select @originator_id = id from MSrepl_originators where
                publisher_database_id = @publisher_database_id 
                and UPPER(srvname) = upper(convert(sysname, substring( @23data, 40 + @cmd_data_len, @orig_srv_len )))
                and dbname = substring( @23data, 40 + @cmd_data_len + @orig_srv_len, @orig_db_len )
            if @originator_id is null
            begin
                insert into MSrepl_originators (publisher_database_id, srvname, dbname) values
                    (@publisher_database_id, substring( @23data, 40 + @cmd_data_len, @orig_srv_len ), substring( @23data, 40 + @cmd_data_len + @orig_srv_len, @orig_db_len ))
                select @originator_id = @@identity
            end
        end
        else
            select @originator_id = 0

        -- Now insert into MSrepl_commands

        INSERT INTO MSrepl_commands VALUES (@publisher_database_id, 
            substring(@23data,11 ,8),
            substring(@23data,29 ,4), 
            substring(@23data,21 ,4), 
            @originator_id, 
            substring(@23data,25 ,4), 
            convert(bit,substring(@23data,33 ,1)), 
            substring(@23data,40,@cmd_data_len) )
    end

    IF @24data is null
      return
    IF datalength( @24data ) > 39
    begin
        -- Get the originator_id for the first command 
        select @cmd_data_len = substring( @24data, 34, 2 )
        select @orig_srv_len = substring( @24data, 36, 2 )
        select @orig_db_len = substring( @24data, 38, 2 )
        if @orig_srv_len <> 0 and @orig_db_len <> 0 
        begin 
            set @originator_id = null 
            select @originator_id = id from MSrepl_originators where
                publisher_database_id = @publisher_database_id 
                and UPPER(srvname) = upper(convert(sysname, substring( @24data, 40 + @cmd_data_len, @orig_srv_len )))
                and dbname = substring( @24data, 40 + @cmd_data_len + @orig_srv_len, @orig_db_len )
            if @originator_id is null
            begin
                insert into MSrepl_originators (publisher_database_id, srvname, dbname) values
                    (@publisher_database_id, substring( @24data, 40 + @cmd_data_len, @orig_srv_len ), substring( @24data, 40 + @cmd_data_len + @orig_srv_len, @orig_db_len ))
                select @originator_id = @@identity
            end
        end
        else
            select @originator_id = 0

        -- Now insert into MSrepl_commands

        INSERT INTO MSrepl_commands VALUES (@publisher_database_id, 
            substring(@24data,11 ,8),
            substring(@24data,29 ,4), 
            substring(@24data,21 ,4), 
            @originator_id, 
            substring(@24data,25 ,4), 
            convert(bit,substring(@24data,33 ,1)), 
            substring(@24data,40,@cmd_data_len) )
    end


    IF @25data is null
      return
    IF datalength( @25data ) > 39
    begin
        -- Get the originator_id for the first command 
        select @cmd_data_len = substring( @25data, 34, 2 )
        select @orig_srv_len = substring( @25data, 36, 2 )
        select @orig_db_len = substring( @25data, 38, 2 )
        if @orig_srv_len <> 0 and @orig_db_len <> 0 
        begin 
            set @originator_id = null 
            select @originator_id = id from MSrepl_originators where
                publisher_database_id = @publisher_database_id 
                and UPPER(srvname) = upper(convert(sysname, substring( @25data, 40 + @cmd_data_len, @orig_srv_len )))
                and dbname = substring( @25data, 40 + @cmd_data_len + @orig_srv_len, @orig_db_len )
            if @originator_id is null
            begin
                insert into MSrepl_originators (publisher_database_id, srvname, dbname) values
                    (@publisher_database_id, substring( @25data, 40 + @cmd_data_len, @orig_srv_len ), substring( @25data, 40 + @cmd_data_len + @orig_srv_len, @orig_db_len ))
                select @originator_id = @@identity
            end
        end
        else
            select @originator_id = 0

        -- Now insert into MSrepl_commands

        INSERT INTO MSrepl_commands VALUES (@publisher_database_id, 
            substring(@25data,11 ,8),
            substring(@25data,29 ,4), 
            substring(@25data,21 ,4), 
            @originator_id, 
            substring(@25data,25 ,4), 
            convert(bit,substring(@25data,33 ,1)), 
            substring(@25data,40,@cmd_data_len) )
    end


    IF @26data is null
      return
    IF datalength( @26data ) > 39
    begin
        -- Get the originator_id for the first command 
        select @cmd_data_len = substring( @26data, 34, 2 )
        select @orig_srv_len = substring( @26data, 36, 2 )
        select @orig_db_len = substring( @26data, 38, 2 )
        if @orig_srv_len <> 0 and @orig_db_len <> 0 
        begin 
            set @originator_id = null 
            select @originator_id = id from MSrepl_originators where
                publisher_database_id = @publisher_database_id 
                and UPPER(srvname) = upper(convert(sysname, substring( @26data, 40 + @cmd_data_len, @orig_srv_len )))
                and dbname = substring( @26data, 40 + @cmd_data_len + @orig_srv_len, @orig_db_len )
            if @originator_id is null
            begin
                insert into MSrepl_originators (publisher_database_id, srvname, dbname) values
                    (@publisher_database_id, substring( @26data, 40 + @cmd_data_len, @orig_srv_len ), substring( @26data, 40 + @cmd_data_len + @orig_srv_len, @orig_db_len ))
                select @originator_id = @@identity
            end
        end
        else
            select @originator_id = 0

        -- Now insert into MSrepl_commands

        INSERT INTO MSrepl_commands VALUES (@publisher_database_id, 
            substring(@26data,11 ,8),
            substring(@26data,29 ,4), 
            substring(@26data,21 ,4), 
            @originator_id, 
            substring(@26data,25 ,4), 
            convert(bit,substring(@26data,33 ,1)), 
            substring(@26data,40,@cmd_data_len) )
    end


    IF @@ERROR <> 0
      return (1)
GO
--
-- Name:    
--          sp_MSadd_repl_commands27hp
--          
-- Description: 
--          logreader agent writes to MSrepl_transactions/MSrepl_commands table through this sp
--  
-- Security: 
--          not granted to public, lives in distribution db of which logreader agent should be dbo 
--
-- Returns:  	0 : success
--		1 : failure          
--      
-- Owner:   
--          qunguo
--
--
raiserror(15339,-1,-1,'sp_MSadd_repl_commands27hp')
GO
CREATE PROCEDURE sp_MSadd_repl_commands27hp
@publisher_id smallint,
@publisher_db sysname,
@data varbinary( 1575 ),
@1data varbinary(1575) = NULL,
@2data varbinary(1575) = NULL,
@3data varbinary(1575) = NULL,
@4data varbinary(1575) = NULL,
@5data varbinary(1575) = NULL,
@6data varbinary(1575) = NULL,
@7data varbinary(1575) = NULL,
@8data varbinary(1575) = NULL,
@9data varbinary(1575) = NULL,
@10data varbinary(1575) = NULL,
@11data varbinary(1575) = NULL,
@12data varbinary(1575) = NULL,
@13data varbinary(1575) = NULL,
@14data varbinary(1575) = NULL,
@15data varbinary(1575) = NULL,
@16data varbinary(1575) = NULL,
@17data varbinary(1575) = NULL,
@18data varbinary(1575) = NULL,
@19data varbinary(1575) = NULL,
@20data varbinary(1575) = NULL,
@21data varbinary(1575) = NULL,
@22data varbinary(1575) = NULL,
@23data varbinary(1575) = NULL,
@24data varbinary(1575) = NULL,
@25data varbinary(1575) = NULL,
@26data varbinary(1575) = NULL
AS

    SET NOCOUNT ON
	declare @publisher_database_id int
	
    -- Get publisher database id.
    SELECT @publisher_database_id = id from MSpublisher_databases where publisher_id = @publisher_id and 
	    publisher_db = @publisher_db

    DECLARE @date datetime
			,@x int
			,@tempdata varbinary(1575)
			,@seqno varbinary(16)

	DECLARE @artid      int
    		,@cmd_type   int
    		,@originator sysname
    		,@originator_db sysname
    		,@originator_id int
    		,@cmd_data_len  smallint
    		,@orig_srv_len smallint
    		,@orig_db_len  smallint

    SELECT @date = GETDATE()

	select @x = 0
	select @tempdata = null
	while @x <= 26
	begin
		select @tempdata = CASE @x
			when 0 then @data
			when 1 then @1data
			when 2 then @2data
			when 3 then @3data
			when 4 then @4data
			when 5 then @5data
			when 6 then @6data
			when 7 then @7data
			when 8 then @8data
			when 9 then @9data
			when 10 then @10data
			when 11 then @11data
			when 12 then @12data
			when 13 then @13data
			when 14 then @14data
			when 15 then @15data
			when 16 then @16data
			when 17 then @17data
			when 18 then @18data
			when 19 then @19data
			when 20 then @20data
			when 21 then @21data
			when 22 then @22data
			when 23 then @23data
			when 24 then @24data
			when 25 then @25data
			when 26 then @26data
	end

	if @tempdata is NULL
		goto END_CMDS

	select @seqno = substring(@tempdata, 11, 10) 	
    IF convert( int, substring( @tempdata, 25, 4 ) ) = 1  
	    	INSERT INTO MSrepl_transactions VALUES (@publisher_database_id,
        		 substring( @tempdata, 1, 10 ), @seqno, @date)

	-- command not empty
    IF datalength( @tempdata ) > 39
    begin
        -- Get the originator_id for the first command 
        select @cmd_data_len = substring( @tempdata, 34, 2 )
        select @orig_srv_len = substring( @tempdata, 36, 2 )
        select @orig_db_len = substring( @tempdata, 38, 2 )
        if @orig_srv_len <> 0 and @orig_db_len <> 0 
        begin 
            set @originator_id = null 
            select @originator_id = id from MSrepl_originators where
                publisher_database_id = @publisher_database_id 
                and UPPER(srvname) = upper(convert(sysname, substring( @tempdata, 40 + @cmd_data_len, @orig_srv_len )))
                and dbname = substring( @tempdata, 40 + @cmd_data_len + @orig_srv_len, @orig_db_len )
            if @originator_id is null
            begin
                insert into MSrepl_originators (publisher_database_id, srvname, dbname) values
                    (@publisher_database_id, substring( @tempdata, 40 + @cmd_data_len, @orig_srv_len ), substring( @tempdata, 40 + @cmd_data_len + @orig_srv_len, @orig_db_len ))
                select @originator_id = @@identity
            end
        end
        else
            select @originator_id = 0

        -- Now insert into MSrepl_commands
		select @cmd_type = substring(@tempdata,29,4)
		if( @cmd_type in( 37,38 ) )
		begin
			select @artid = substring(@tempdata,21,4)
			select @cmd_type = 38 - @cmd_type
			exec sp_MSset_syncstate @publisher_id, @publisher_db, @artid, @cmd_type, @seqno
			select @cmd_type = (38 - @cmd_type) | 0x80000000
		end

		if (@cmd_data_len > 0)
			INSERT INTO MSrepl_commands (publisher_database_id, xact_seqno, type, article_id, originator_id, command_id, partial_command, command)
				VALUES (@publisher_database_id, 
				@seqno,
				@cmd_type, 
				substring(@tempdata,21 ,4), 
				@originator_id, 
				substring(@tempdata,25 ,4), 
				convert(bit,substring(@tempdata,33 ,1)), 
				substring(@tempdata,40,@cmd_data_len))

    end
	select @x = @x + 1

end

END_CMDS:
    IF @@ERROR <> 0
      return (1)
go
--
-- Name:    
--          sp_MSadd_repl_commands27hp_mcit
--          
-- Description: 
--          logreader agent writes to MSrepl_transactions/MSrepl_commands table through this sp
--			when -MaxCmdsInTran is specified at command line and distribution db is at least 80sp3
--  
-- Security: 
--          not granted to public, lives in distribution db of which logreader agent should be dbo 
--
-- Returns:  	0 : success
--		1 : failure          
--      
-- Owner:   
--          qunguo
--
--

raiserror(15339,-1,-1,'sp_MSadd_repl_commands27hp_mcit')
GO
CREATE PROCEDURE sp_MSadd_repl_commands27hp_mcit
@publisher_id smallint,
@publisher_db sysname,
@data varbinary( 1575 ),
@1data varbinary(1575) = NULL,
@2data varbinary(1575) = NULL,
@3data varbinary(1575) = NULL,
@4data varbinary(1575) = NULL,
@5data varbinary(1575) = NULL,
@6data varbinary(1575) = NULL,
@7data varbinary(1575) = NULL,
@8data varbinary(1575) = NULL,
@9data varbinary(1575) = NULL,
@10data varbinary(1575) = NULL,
@11data varbinary(1575) = NULL,
@12data varbinary(1575) = NULL,
@13data varbinary(1575) = NULL,
@14data varbinary(1575) = NULL,
@15data varbinary(1575) = NULL,
@16data varbinary(1575) = NULL,
@17data varbinary(1575) = NULL,
@18data varbinary(1575) = NULL,
@19data varbinary(1575) = NULL,
@20data varbinary(1575) = NULL,
@21data varbinary(1575) = NULL,
@22data varbinary(1575) = NULL,
@23data varbinary(1575) = NULL,
@24data varbinary(1575) = NULL,
@25data varbinary(1575) = NULL,
@26data varbinary(1575) = NULL
AS

    SET NOCOUNT ON


    DECLARE @publisher_database_id int

    -- Get publisher database id.
    SELECT @publisher_database_id = id from MSpublisher_databases where publisher_id = @publisher_id and 
	    publisher_db = @publisher_db
	
    DECLARE @max_offset  binary(4)
    		,@seqno  varbinary(16)
    		,@max_seqno  varbinary(16)
    		,@date datetime
    		,@x int
    		,@tempdata varbinary(1575)
    		,@prevdata varbinary(1575)

	DECLARE @artid      int
    		,@cmd_type   int
    		,@originator sysname
    		,@originator_db sysname
    		,@originator_id int
    		,@cmd_data_len  smallint
    		,@orig_srv_len smallint
    		,@orig_db_len  smallint

	SELECT @date = GETDATE()
	select @max_offset = 0

    -- First insert into MS_repl_transactions
   	select @max_seqno = max(xact_seqno) from MSrepl_transactions 
				where publisher_database_id = @publisher_database_id 
	if substring( @data, 11, 10 ) = substring( @max_seqno, 1, 10 ) -- same tran
	begin
		IF convert( int, substring( @data, 25, 4 ) ) = 1 
			select @max_offset = substring(@max_seqno, 11, 4) + 1 -- increment offset
		else
			select @max_offset = substring(@max_seqno, 11, 4) -- keep the same offset
		if (@max_offset > 0)
			select @seqno = substring( @data, 11, 10 ) + @max_offset
		else
			select @seqno = substring( @data, 11, 10 )
	end
	else
		select @seqno = substring( @data, 11, 10 )

	if @max_offset is NULL
		select @max_offset  = 0
	select @max_offset  = @max_offset + 1


	select @x = 0
	select @tempdata = @data
	while @x <= 26
	begin
		select @prevdata = @tempdata	
		select @tempdata = CASE @x
			when 0 then @data
			when 1 then @1data
			when 2 then @2data
			when 3 then @3data
			when 4 then @4data
			when 5 then @5data
			when 6 then @6data
			when 7 then @7data
			when 8 then @8data
			when 9 then @9data
			when 10 then @10data
			when 11 then @11data
			when 12 then @12data
			when 13 then @13data
			when 14 then @14data
			when 15 then @15data
			when 16 then @16data
			when 17 then @17data
			when 18 then @18data
			when 19 then @19data
			when 20 then @20data
			when 21 then @21data
			when 22 then @22data
			when 23 then @23data
			when 24 then @24data
			when 25 then @25data
			when 26 then @26data
		end
		
		IF @tempdata is null
      		goto END_CMDS

		if(@x = 0)
			goto SKIP_SEQNO

		if(substring( @tempdata, 11, 10 ) = substring( @prevdata, 11, 10 )) --same tran
		begin
	    	IF convert( int, substring( @tempdata, 25, 4 ) ) = 1  --only happens with -MaxCmdsInTran 
			begin
				select @seqno = substring( @tempdata, 11, 10 ) + @max_offset
				select @max_offset  = @max_offset + 1
			end
		end
		else
			select @seqno = substring( @tempdata, 11, 10 ) 

SKIP_SEQNO:
		-- first command in tran
    IF convert( int, substring( @tempdata, 25, 4 ) ) = 1  
	    	INSERT INTO MSrepl_transactions VALUES (@publisher_database_id,
        		 substring( @tempdata, 1, 10 ), @seqno, @date)

	-- command not empty
    IF datalength( @tempdata ) > 39
    begin
        -- Get the originator_id for the first command 
        select @cmd_data_len = substring( @tempdata, 34, 2 )
        select @orig_srv_len = substring( @tempdata, 36, 2 )
        select @orig_db_len = substring( @tempdata, 38, 2 )
        if @orig_srv_len <> 0 and @orig_db_len <> 0 
        begin 
            set @originator_id = null 
            select @originator_id = id from MSrepl_originators where
                publisher_database_id = @publisher_database_id 
                and UPPER(srvname) = upper(convert(sysname, substring( @tempdata, 40 + @cmd_data_len, @orig_srv_len )))
                and dbname = substring( @tempdata, 40 + @cmd_data_len + @orig_srv_len, @orig_db_len )
            if @originator_id is null
            begin
                insert into MSrepl_originators (publisher_database_id, srvname, dbname) values
                    (@publisher_database_id, substring( @tempdata, 40 + @cmd_data_len, @orig_srv_len ), substring( @tempdata, 40 + @cmd_data_len + @orig_srv_len, @orig_db_len ))
                select @originator_id = @@identity
            end
        end
        else
            select @originator_id = 0

        -- Now insert into MSrepl_commands
		select @cmd_type = substring(@tempdata,29,4)
		if( @cmd_type in( 37,38 ) )
		begin
			select @artid = substring(@tempdata,21,4)
			select @cmd_type = 38 - @cmd_type
			exec sp_MSset_syncstate @publisher_id, @publisher_db, @artid, @cmd_type, @seqno
			select @cmd_type = (38 - @cmd_type) | 0x80000000
		end

		if (@cmd_data_len > 0)
		INSERT INTO MSrepl_commands (publisher_database_id, xact_seqno, type, article_id, originator_id, command_id, partial_command, command)
			VALUES (@publisher_database_id, 
			@seqno,
			@cmd_type, 
			substring(@tempdata,21 ,4), 
			@originator_id, 
			substring(@tempdata,25 ,4), 
			convert(bit,substring(@tempdata,33 ,1)), 
			substring(@tempdata,40,@cmd_data_len))
    end

		select @x = @x + 1

	end

END_CMDS:
    IF @@ERROR <> 0
		return (1)



go


raiserror(15339,-1,-1,'sp_MSvalidate_distpublisher')
go
CREATE PROCEDURE sp_MSvalidate_distpublisher
@publisher sysname,
@publisher_id smallint = NULL OUTPUT
as

    set nocount on

    declare @distribution_db sysname
    declare @retcode int

    -- Check if publisher is a defined as a distribution publisher at this distributor
    select @publisher_id = srvid from master.dbo.sysservers where UPPER(srvname) = UPPER(@publisher) 
    if @publisher_id is NULL
    begin
        raiserror (14080, 11, -1)
        return (1)
    end

    if not exists (select * from msdb..MSdistpublishers where UPPER(name) = UPPER(@publisher))
    begin
        raiserror (14080, 11, -1)
        return (1)
    end


    -- Check if client is in the correct distribution database
    exec @retcode = dbo.sp_helpdistributor @publisher = @publisher, @distribdb = @distribution_db OUTPUT
    if @@error <> 0 OR @retcode <> 0
    begin
        raiserror (14071, 16, -1)
        return (1)
    end

    -- Check if publisher is associated with a distribution database
    if @distribution_db is NULL
    begin
        raiserror (14071, 16, -1)
        return(1)
    end

    -- Check if client is in the distribution database 
    if @distribution_db <> db_name()
    begin
        raiserror(14071, 16, -1)
        return(1)
    end

go

raiserror(15339,-1,-1,'sp_MSdrop_distribution_agent')
GO
CREATE PROCEDURE sp_MSdrop_distribution_agent (
    @publisher_id smallint,
    @publisher_db sysname,
    @publication sysname,
    @subscriber_id smallint,
    @subscriber_db sysname,
    @subscription_type int,
    @keep_for_last_run          bit = 0
) 
AS
BEGIN

    SET NOCOUNT ON

    /*
    ** Declarations.
    */
    DECLARE @stopcode       int
            ,@retcode        int
            ,@job_id         binary(16)
            ,@is_continuous  bit
            ,@local_job      bit
            ,@publisher      sysname
            ,@schedule_name  sysname
            ,@job_command    nvarchar(512)
            ,@name           nvarchar(100)
            ,@agent_id       int
            ,@queue_id      sysname
            ,@qservicestatus int
            ,@qservername   nvarchar(255)
            ,@subscriber    sysname
    select @stopcode = 1
            ,@qservername = queue_server
            ,@job_id = job_id, @local_job = local_job, @name = name, @agent_id = id,
            @queue_id = queue_id
    FROM MSdistribution_agents WHERE
        publisher_id = @publisher_id AND
        publisher_db = @publisher_db AND
        publication = @publication and
        subscriber_id = @subscriber_id and
        subscriber_db = @subscriber_db and
        subscription_type = @subscription_type
    
    -- Delete Perfmon instance
    dbcc deleteinstance ("SQL Replication Distribution", @name)

    select @publisher = srvname from master..sysservers where srvid = @publisher_id

    select @subscriber = srvname from master..sysservers where srvid = @subscriber_id
    -- Return if not exists
    IF @local_job IS NULL
        RETURN(0)

    BEGIN TRAN

    if ((@queue_id is not null) and (substring(@queue_id, 1, 10) != N'mssqlqueue'))
    begin
        --
        -- Check if the MSMQ service is running, if not running, return with error
        -- BYPASS the check for clusters
        --
        if ( SERVERPROPERTY('IsClustered') = 0 )
        begin
            exec @retcode = master.dbo.xp_controlqueueservice 
                                @control_command = 1,
                                @return_result = @qservicestatus output
            if (@retcode != 0 or @@error != 0)
            begin
                raiserror('sp_MSdrop_distribution_agent(debug): xp_controlqueueservice failed in check mode', 16, 1)
                GOTO UNDO
            end
            
            if (@qservicestatus != 1)
            begin
                raiserror('sp_MSdrop_distribution_agent(debug): MSMQ service not running', 16, 1)
                GOTO UNDO
            end
        end

        --
        -- delete the local private queue
        --          
        exec @retcode = master.dbo.xp_deleteprivatequeue @qservername, @queue_id
        IF @@ERROR != 0 or @retcode != 0
        BEGIN
            RAISERROR('Debug: xp_deleteprivatequeue failed', -1, -1) WITH NOWAIT
            GOTO UNDO
        END
    end

    IF @local_job = 1 and @keep_for_last_run = 0
    BEGIN
        IF EXISTS (SELECT * FROM msdb..sysjobs_view WHERE job_id = @job_id)
        BEGIN
            -- Checks if the job name matches one that is generated 
            -- by replication
            EXEC @retcode = dbo.sp_MSisdistributionjobnamegenerated
                                @publisher = @publisher,
                                @publisher_db = @publisher_db,
                                @publication = @publication,
                                @subscriber = @subscriber,
                                @job_id = @job_id
            IF @@ERROR <> 0
                GOTO UNDO
            
            -- Only drop the job if the name was generated
            IF @retcode = 0
            BEGIN
                EXEC @retcode = msdb.dbo.sp_delete_job @job_id = @job_id
                IF @@ERROR <> 0 or @retcode <> 0
                    GOTO UNDO
            END
        END
    END

    IF @local_job = 1 and @keep_for_last_run = 1
    BEGIN
            select @job_command=command from msdb.dbo.sysjobsteps where job_id=@job_id and step_id=2

            if PATINDEX('%-[Cc][Oo][Nn][Tt][Ii][Nn][Uu][Oo][Uu][Ss]%', @job_command) > 0
                begin
                    select @is_continuous = 1
                    create table #sqlstatus(status nvarchar(20))
                    insert into #sqlstatus (status) exec master.dbo.xp_servicecontrol 'QUERYSTATE', 'SQLServerAgent'
                    if exists (select * from #sqlstatus where status='Running.') 
                            exec @stopcode = msdb.dbo.sp_stop_job @job_id = @job_id
                                 if @@ERROR<>0 GOTO UNDO
                    drop table #sqlstatus   
                    if @stopcode=0 
                        waitfor delay '00:00:30'
                end
            
            EXEC @retcode = msdb.dbo.sp_update_job @job_id=@job_id, @delete_level=3 -- NOTE: Run once, success or failure!
            IF @@ERROR <> 0 or @retcode <> 0
                GOTO UNDO
        
            EXEC @retcode = msdb.dbo.sp_delete_jobstep @job_id=@job_id, @step_id=3
            IF @@ERROR <> 0 or @retcode <> 0
                GOTO UNDO
            EXEC @retcode = msdb.dbo.sp_delete_jobstep @job_id=@job_id, @step_id=1
            IF @@ERROR <> 0 or @retcode <> 0
                GOTO UNDO

            select @job_command=command from msdb.dbo.sysjobsteps where job_id=@job_id and step_id=1        
            select @job_command = @job_command + ' -UnSubscribe 0 '  -- currently the value does not really matter
            
            EXEC @retcode = msdb.dbo.sp_update_jobstep @job_id=@job_id, @step_id=1, 
                                @on_success_action=1, 
                                @on_fail_action=2, 
                                @command=@job_command
            IF @@ERROR <> 0 or @retcode <> 0
                GOTO UNDO

            
            select @schedule_name = formatmessage(20532)
            EXEC @retcode = msdb.dbo.sp_update_jobschedule @job_id=@job_id, @name=@schedule_name, @freq_subday_type = 2, @freq_subday_interval=30
            IF @@ERROR<>0 or @retcode<>0
                GOTO UNDO
            
            if (@is_continuous  = 1) and (@stopcode = 0)
                begin
                    EXEC @retcode = msdb.dbo.sp_start_job @job_id=@job_id
                     if @@ERROR<>0 
                        GOTO UNDO
                end
            /*
            ** The last run of this job will be as scheduled
            */
    END

    -- Remove agent entry
    DELETE MSdistribution_agents WHERE id = @agent_id
    IF @@ERROR <> 0 
        GOTO UNDO

    -- Remove associated history 
    DELETE MSdistribution_history WHERE agent_id = @agent_id
    IF @@ERROR <> 0 
        GOTO UNDO

    -- Update global replication status table
    EXEC dbo.sp_MSupdate_replication_status
        @publisher,
        @publisher_db,
        @publication,
        @agent_type = 3,
        @agent_name = @name,
        @status = -1    -- delete status

    COMMIT TRAN

    RETURN(0)

UNDO:
    if @@TRANCOUNT = 1
        ROLLBACK TRAN
    else
        COMMIT TRAN
    return(1)
END
GO

raiserror(15339,-1,-1,'sp_MSdrop_distribution_agentid')
GO
CREATE PROCEDURE sp_MSdrop_distribution_agentid (
    @agent_id int
) AS


    SET NOCOUNT ON

    /*
    ** Declarations.
    */
    DECLARE @name           nvarchar(100)
    DECLARE @publisher      sysname
    DECLARE @publisher_db   sysname
    DECLARE @publication    sysname

    SELECT @name = name, @publisher = srvname, @publisher_db = publisher_db, @publication = publication FROM 
        MSdistribution_agents, master..sysservers WHERE 
        id = @agent_id and
        srvid = publisher_id
    
    -- Delete Perfmon instance
    dbcc deleteinstance ("SQL Replication Distribution", @name)

	-- Mask agent type, do this before deletion of the row
	declare @agent_type int
	set @agent_type = dbo.fn_MSmask_agent_type (@agent_id, 3)

    -- Remove agent entry
    DELETE MSdistribution_agents WHERE id = @agent_id
    IF @@ERROR <> 0 
        return 1


    -- Update global replication status table
    EXEC dbo.sp_MSupdate_replication_status
        @publisher,
        @publisher_db,
        @publication,
        @publication_type = 1,
        @agent_type = @agent_type,
        @agent_name = @name,
        @status = -1    -- delete status

    return 0

GO

raiserror(15339,-1,-1,'sp_MSdrop_qreader_agent')
GO
CREATE PROCEDURE sp_MSdrop_qreader_agent (
    @agent_id int
) AS
BEGIN
    SET NOCOUNT ON
    --
    -- Declarations.
    --
    DECLARE @retcode        int
    DECLARE @job_id         binary(16)
    DECLARE @name           nvarchar(100)
    DECLARE @database       sysname

    select @database = db_name()

    -- get the agent and job ids
    SELECT @job_id = job_id, @name = name
    FROM MSqreader_agents 
    WHERE id = @agent_id        

    if (@agent_id is NULL)
        return (0)
                    
    -- Delete Perfmon instance
    dbcc deleteinstance ('SQL Replication QueueReader', @name)

    BEGIN TRAN sp_MSdrop_qreader_agent

    -- delete job for the agent
    IF EXISTS (SELECT * FROM msdb..sysjobs_view WHERE job_id = @job_id)
    BEGIN
        -- Checks if the job name was generated
        EXEC @retcode = dbo.sp_MSisqueuereaderjobnamegenerated
                            @job_id = @job_id

        IF @@ERROR != 0 
            GOTO UNDO

        -- Only drop the job if the name was generated
        IF @retcode = 0
        BEGIN
            EXEC @retcode = msdb.dbo.sp_delete_job @job_id = @job_id
            IF (@@ERROR != 0 or @retcode != 0)
                GOTO UNDO
        END
    END

    -- Remove agent entry
    DELETE MSqreader_agents WHERE id = @agent_id        
    IF (@@ERROR != 0)
        GOTO UNDO

    -- Remove associated history 
    DELETE MSqreader_history 
    WHERE agent_id = @agent_id 
    IF (@@ERROR != 0)
        GOTO UNDO

    -- Update global replication status table
    EXEC dbo.sp_MSupdate_replication_status
        @@servername,
        @database,
        'ALL',
        @agent_type = 9,
        @agent_name = @name,
        @status = -1    -- delete status

    COMMIT TRAN sp_MSdrop_qreader_agent
    RETURN(0)

UNDO:
    ROLLBACK TRAN sp_MSdrop_qreader_agent
    return(1)
END
GO

raiserror(15339,-1,-1,'sp_MSdrop_qreader_history')
GO
CREATE PROCEDURE sp_MSdrop_qreader_history (
    @publication_id int
) AS
BEGIN
	SET NOCOUNT ON

	-- Remove associated history 
	DELETE MSqreader_history 
	WHERE publication_id = @publication_id 
	IF (@@ERROR != 0)
		return (1)
	else
		return 0
END
GO

raiserror(15339,-1,-1,'sp_MSdrop_merge_agentid')
GO
CREATE PROCEDURE sp_MSdrop_merge_agentid (
    @agent_id int
) AS


    SET NOCOUNT ON

    /*
    ** Declarations.
    */
    DECLARE @name           nvarchar(100)
    DECLARE @publisher      sysname
    DECLARE @publisher_db   sysname
    DECLARE @publication    sysname

    SELECT @name = name, @publisher = srvname, @publisher_db = publisher_db, @publication = publication FROM 
        MSmerge_agents, master..sysservers WHERE 
        id = @agent_id and
        srvid = publisher_id
    
    -- Delete Perfmon instance
    dbcc deleteinstance ("SQL Replication Merge", @name)

	-- Mask agent type, do this before delete the row.
	declare @agent_type int
	set @agent_type = dbo.fn_MSmask_agent_type (@agent_id, 4)

    -- Remove agent entry
    DELETE MSmerge_agents WHERE id = @agent_id
    IF @@ERROR <> 0 
        return 1


    -- Update global replication status table
    EXEC dbo.sp_MSupdate_replication_status
        @publisher,
        @publisher_db,
        @publication,
        @agent_type = @agent_type,
        @agent_name = @name,
        @status = -1    -- delete status

    return 0

GO

raiserror(15339,-1,-1,'sp_MSadd_qreader_agent')
GO
CREATE PROCEDURE sp_MSadd_qreader_agent (
    @name nvarchar(100) = NULL,
    @agent_id int = NULL OUTPUT,
    @agent_jobid binary(16) = NULL OUTPUT) 
AS
BEGIN
	SET NOCOUNT ON

	DECLARE @retcode				int
			,@profile_id			int
			,@category_name			sysname
			,@database				sysname

	-- these are defaults used for sp_MSadd_repl_job
			,@frequency_type int,
			@frequency_interval int,
			@frequency_relative_interval int,
			@frequency_recurrence_factor int,
			@frequency_subday int,
			@frequency_subday_interval int,
			@active_start_time_of_day int,
			@active_end_time_of_day int,
			@active_start_date int,
			@active_end_date int,
			@retryattempts int,
			@retrydelay int,
			@command nvarchar(4000)
			,@jobname sysname
			,@agent_name nvarchar(100)

	SELECT
		@frequency_type = 64,
		@frequency_interval = 1,
		@frequency_relative_interval = 1,
		@frequency_recurrence_factor  = 0,
		@frequency_subday = 4,
		@frequency_subday_interval = 5,
		@active_start_time_of_day = 0,
		@active_end_time_of_day = 235959,
		@active_start_date = 0,
		@active_end_date = 99991231,
		@retryattempts = 10,
		@retrydelay = 1

	--
	-- initialize
	--
	select @database = db_name()
			,@agent_id = NULL
			,@agent_jobid = NULL

	--
	-- Check for Agent entry
	--
	select top 1 @agent_id = id, @agent_name = name
	from dbo.MSqreader_agents

	--
	-- Check if we have any queue reader jobs for this database
	--
	select @agent_jobid = job.job_id
			,@jobname = job.name 
	from msdb..sysjobs as job join msdb..sysjobsteps as step 
		on job.job_id = step.job_id 
			and job.category_id = 19
			and UPPER(job.originating_server) = UPPER(CONVERT(sysname, SERVERPROPERTY('ServerName')))
			and step.subsystem = N'QueueReader' 
			and step.database_name = @database

	--
	-- begin tran
	--
	BEGIN TRAN sp_MSadd_qreader_agent
	
	--
	-- Check if we need to proceed
	-- add agent entry and job entry as required
	--
	if ((@agent_id IS NOT NULL) and (@agent_jobid IS NOT NULL))
	begin
		--
		-- we have an entry in MSqreader_agents and an entry in 
		-- msdb..sysjobs, make sure the names and jobid match
		--
		if (@agent_name != @jobname)
		begin
			--
			-- Update the agent name to be same as the job name
			--
			UPDATE MSqreader_agents SET name = @jobname WHERE id = @agent_id
			IF (@@ERROR != 0)
				GOTO UNDO
		end

		if not exists (select * from MSqreader_agents
			where id = @agent_id and job_id = @agent_jobid)
		begin
			--
			-- Update the agent job_id if necessary
			--
			UPDATE MSqreader_agents SET job_id = @agent_jobid WHERE id = @agent_id
			IF (@@ERROR != 0)
				GOTO UNDO
		end

		COMMIT TRAN sp_MSadd_qreader_agent
		RETURN(0)
	end

	--
	-- prepare the command
	-- Since this will always run on NT, use integrated security
	--
	select @command = N'-Distributor ' + quotename(@@SERVERNAME) 
					+ N' -DistributionDB ' + quotename(@database) 
					+ N' -DistributorSecurityMode 1 '
	
	SELECT @profile_id = profile_id
	FROM msdb..MSagent_profiles
	WHERE agent_type = 9
	AND def_profile = 1

	IF @profile_id IS NULL
		GOTO UNDO

	--
	-- Set the name
	--
	if (@name is NULL)
	begin
		select @name = case 
			when (@agent_name IS NULL and @jobname IS NULL) 
				then quotename(@@servername) + '.' + cast(db_id() as nvarchar)
			when (@jobname IS NOT NULL)
				then cast(@jobname as nvarchar(100))
				else @agent_name
			end
	end
	else
	begin
		--
		-- we will override the user specified name if
		-- a job already exists
		--
		if (@jobname IS NOT NULL and @jobname != @name)
			select name = cast(@jobname as nvarchar(100))
	end
	
	--
	-- Insert row and Add Perfmoon instance only if needed
	--
	if (@agent_id IS NULL)
	begin
		INSERT INTO MSqreader_agents (name, profile_id) VALUES (@name, @profile_id)
		IF (@@ERROR != 0)
			GOTO UNDO
		SELECT @agent_id = @@IDENTITY
		dbcc addinstance ('SQL Replication QueueReader', @name)
	end
	else
	begin
		--
		-- update Agent name if necessary
		--
		if not exists (select * from MSqreader_agents 
			where id = @agent_id and name = @name) 
		begin
			UPDATE MSqreader_agents SET name = @name WHERE id = @agent_id
			IF (@@ERROR != 0)
				GOTO UNDO
		end
	end

	--
	-- add the job if necessary
	-- For DMO scripting
	-- if the corresponding job for this agent does not exist we will 
	-- proceed and create the job (This is for the case when the user 
	-- generated the script at the publisher but did not re-create 
	-- repl jobs at the distributor.)
	--
	if (@agent_jobid IS NULL)
	begin
		-- Get Qreader category name (assumes category_id = 19)
		select @category_name = name FROM msdb.dbo.syscategories where category_id = 19
		
		EXECUTE @retcode = dbo.sp_MSadd_repl_job
			@name = @name,
			@subsystem = 'QueueReader',
			@server = @@SERVERNAME,
			@databasename = @database,
			@enabled = 1,
			@freqtype = @frequency_type,
			@freqinterval = @frequency_interval,
			@freqsubtype = @frequency_subday,
			@freqsubinterval = @frequency_subday_interval,
			@freqrelativeinterval = @frequency_relative_interval,
			@freqrecurrencefactor = 0,
			@activestartdate = @active_start_date,
			@activeenddate = @active_end_date,
			@activestarttimeofday = @active_start_time_of_day,
			@activeendtimeofday = @active_end_time_of_day,
			@nextrundate = 0,
			@nextruntime = 0,
			@runpriority = 0,
			@emailoperatorname = NULL,
			@retryattempts = @retryattempts,
			@retrydelay = @retrydelay,
			@command = @command,
			@loghistcompletionlevel = 0,
			@emailcompletionlevel = 0,
			@description = 'Reads queues for Queued updating subscriptions',
			@category_name = @category_name,
			@failure_detection = 1,
			@agent_id = @agent_id,
			@job_id = @agent_jobid OUTPUT

		IF (@@ERROR != 0 or @retcode != 0)
			GOTO UNDO
	end
	
	-- update agents table with the job id
	UPDATE MSqreader_agents SET job_id = @agent_jobid WHERE id = @agent_id
	IF (@@ERROR != 0)
		GOTO UNDO

	-- Update global replication status table
	EXEC @retcode = dbo.sp_MSupdate_replication_status
		@@servername,
		@database,
		'ALL',
		@agent_type = 9,
		@agent_name = @name,
		@status = 0     -- not running status
	IF (@@ERROR != 0 or @retcode != 0)
		GOTO UNDO

	COMMIT TRAN sp_MSadd_qreader_agent
	RETURN(0)

UNDO:
	--
	-- Since this proc is called from other SPs, doing
	-- a ROLLBACK can roll all the way to the top 
	-- so check for that and commit and return error code.
	-- the top level calling SP should do proper rollback
	-- based on returned error code
	--
    if (@@TRANCOUNT = 1)
        ROLLBACK TRAN sp_MSadd_qreader_agent
    else
        COMMIT TRAN sp_MSadd_qreader_agent
	return(1)
END
GO

raiserror(15339,-1,-1,'sp_MSadd_distribution_agent')
GO
CREATE PROCEDURE sp_MSadd_distribution_agent (
    @name sysname = NULL,
    @publisher_id smallint,
    @publisher_db sysname,
    @publication sysname,  
    @subscriber_id smallint,
    @subscriber_db sysname,
    @subscription_type int, -- have to have it to identify a distribution agent.
    @local_job bit, 

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

    @retryattempts int = 10,
    @retrydelay int = 1,
    
    @command nvarchar(4000) = NULL,
    @agent_id int = NULL OUTPUT,
    @distribution_jobid binary(16) = NULL OUTPUT,
	@update_mode int = 0, 

    -- Agent offload
    @offloadagent bit = 0,
    @offloadserver sysname = NULL,

	@dts_package_name sysname = NULL,
	@dts_package_password nvarchar(524) = NULL,
	@dts_package_location int = 0
) 
AS
BEGIN
    
	SET NOCOUNT ON

	/*
	** Declarations.
	*/
	DECLARE @retcode            int
		,@database           sysname
		,@profile_id         int
		,@distribution_type  int
		,@publisher          sysname
		,@category_name      sysname
		,@subscriber         sysname
		,@publisher_database_id int
		,@queue_id 			sysname
		,@qservicestatus	int
		,@tries				tinyint
		,@queue_server		sysname

    /*
    ** Initializations
    */
    select @database = DB_NAME()
    
	-- Check the existance of the package if it is at the distributor side.
	if @dts_package_name is not null and @dts_package_location = 0
	begin
		exec @retcode = dbo.sp_MSrepl_validate_dts_package
			@name = @dts_package_name
		IF @@ERROR <> 0 or @retcode <> 0
			return (1)
	end

	-- if @name is not null, the proc is from DMO scripting
	-- check to see if the job is there or not, if not, reset @job_existing and
	-- @name values. This is for the case when the user generate the script at
	-- the publisher but did not re-create repl jobs at the distributor.
	if @local_job = 1 and @name is not null and 
       @name <> N''
	begin
		if not exists (select * from msdb..sysjobs_view where 
			name = @name and
			UPPER(originating_server) = UPPER(CONVERT(sysname, SERVERPROPERTY('ServerName'))))
		begin
			set @name = null
		end
	end

    BEGIN TRAN

    -- Try to drop it first
    EXEC @retcode = dbo.sp_MSdrop_distribution_agent 
        @publisher_id = @publisher_id,
        @publisher_db = @publisher_db,
        @publication = @publication,
        @subscriber_id = @subscriber_id,
        @subscriber_db = @subscriber_db,
        @subscription_type = @subscription_type
    IF @@ERROR <> 0 or @retcode <> 0
        GOTO UNDO

    /* Code for distribution agent type in MSagent_profiles */
    SELECT @distribution_type = 3

    SELECT @profile_id = profile_id
    FROM msdb..MSagent_profiles
    WHERE agent_type = @distribution_type
        AND def_profile = 1

    IF @profile_id IS NULL
        GOTO UNDO

    select @publisher = srvname from master..sysservers where srvid = @publisher_id
    select @subscriber = srvname from master..sysservers where srvid = @subscriber_id
    select @publisher_database_id = id from MSpublisher_databases where 
        publisher_id = @publisher_id and
        publisher_db = @publisher_db

	-- Create queue if needed. (queued or failover mode)
	if (@update_mode in (2,3))
	begin
		--
		-- Check if the MSMQ service is running
		-- BYPASS the check for clusters
		--
		if ( SERVERPROPERTY('IsClustered') = 0 )
		begin
			exec @retcode = master.dbo.xp_controlqueueservice 
								@control_command = 1,
								@return_result = @qservicestatus output
			if (@retcode != 0 or @@error != 0)
			begin
				raiserror('sp_MSadd_distribution_agent(debug): xp_controlqueueservice failed in check mode', 16, 1)
				GOTO UNDO
			end

			if (@qservicestatus != 1)
			begin
				raiserror('sp_MSadd_distribution_agent(debug): MSMQ service not running. Start MSMQ services and retry subscription creation', 16, 1)
				GOTO UNDO
			end

			/***************************************************
			***** For NOW we will not AUTOSTART MSMQ services
			****************************************************
			if (@qservicestatus != 1)
			begin
				-- Queue service is not running. Try starting it only if it is
				-- stopped. Otherwise, return with error (we do not want to 
				-- handle the cases for Pause/Pending/Continue states)
				if (@qservicestatus = 2)
				begin
					-- start the service
					exec @retcode = master.dbo.xp_controlqueueservice 
										@control_command = 2,
										@return_result = @qservicestatus output
					if (@retcode != 0 or @@error != 0)
					begin
						raiserror('sp_MSadd_distribution_agent(debug): xp_controlqueueservice failed in start mode', 16, 1)
						GOTO UNDO
					end

					-- check status (try 3 times with 2 sec delays)
					select @tries = 0
					while ((@qservicestatus != 1) and (@tries < 3))
					begin
						WAITFOR DELAY '00:00:02'
						select @tries = @tries + 1
						
						exec @retcode = master.dbo.xp_controlqueueservice 
											@control_command = 1,
											@return_result = @qservicestatus output
						if (@retcode != 0 or @@error != 0)
						begin
							raiserror('sp_MSadd_distribution_agent(debug): xp_controlqueueservice failed in check mode', 16, 1)
							GOTO UNDO
						end					
					end

					-- Did the service start
					if (@qservicestatus != 1)
					begin
						raiserror('sp_MSadd_distribution_agent(debug): MSMQ service not running (delayed)', 16, 1)
						GOTO UNDO
					end
				end
				else
				begin
					raiserror('sp_MSadd_distribution_agent(debug): MSMQ service not running (in transient state)', 16, 1)
					GOTO UNDO
				end
			end
			***************************************************/
		end

		--
		-- create local private queue
		--
		select @queue_id = cast(NEWID() as sysname)
		select @queue_server = @queue_id
		exec @retcode = master.dbo.xp_createprivatequeue @queue_server OUTPUT
		IF @@ERROR != 0 or @retcode != 0
		BEGIN
			select @queue_id = NULL
					,@queue_server = NULL
			RAISERROR('Debug: xp_createprivatequeue failed', -1, -1) WITH NOWAIT
		    GOTO UNDO
		END
	end
	else if (@update_mode in (4,5))
	begin
		--
		-- SQL Queue being used
		-- From SQL2000SP3 onwards - we will also store Queue version in this column
		-- This version will be set by the subscriber correctly on subscriber metadata
		-- The metadata on distributor will be not be changed - as it is not used here
		--
		select @queue_id = N'mssqlqueue'
	end

	
    /* 
    ** Insert row
    */
    INSERT INTO MSdistribution_agents (name, publisher_database_id, publisher_id, publisher_db, publication, 
            subscriber_id, subscriber_db, subscription_type, local_job, 
            subscription_guid, profile_id, queue_id, queue_server,
			dts_package_name, dts_package_password, dts_package_location)
        VALUES ('',@publisher_database_id, @publisher_id, @publisher_db, @publication, 
            @subscriber_id, @subscriber_db, @subscription_type, @local_job, 
            newid(), @profile_id, @queue_id, @queue_server,
			@dts_package_name, @dts_package_password, @dts_package_location)
    IF @@ERROR <> 0
        GOTO UNDO
    
    SELECT @agent_id = @@IDENTITY

    -- Add Perfmoon instance
    dbcc addinstance ("SQL Replication Distribution", @name)

    -- Set agent name
    if @subscriber is NULL select @subscriber = ''
    if @subscriber_db is NULL select @subscriber_db =''
	
	declare @job_existing bit
    
    IF @name IS NULL OR @name = N''
    BEGIN
        /*
        ** Sacrifice 1-2 character from each of (@publisher,@publication,
        ** @publisher_db,subscriber) to allow 4 more indentity digits in
        ** the distribution agent name. This will hopefully provide better
        ** guarantee of agent name uniqueness.
        */
        if @publication is NOT NULL and (LOWER(@publication)<>'all')
            SELECT @name = CONVERT(nvarchar(21),@publisher ) + '-' + 
                CONVERT(nvarchar(21),@publisher_db) + '-' + 
                CONVERT(nvarchar(21),@publication) + '-' + 
                CONVERT(nvarchar(21),@subscriber) + '-' +
                CONVERT(nvarchar, @@IDENTITY)
        else
            SELECT @name = CONVERT(nvarchar(28),@publisher ) + '-' + 
                CONVERT(nvarchar(28),@publisher_db) + '-' + 
                CONVERT(nvarchar(28),@subscriber) + '-' + 
                CONVERT(nvarchar, @@IDENTITY)

		select @job_existing = 0
    END
	else
		select @job_existing = 1

    -- If creating a new job and the generated name already exists, re-generate the name with a 
    -- guid appended
    IF  @job_existing = 0
    BEGIN
        IF EXISTS (SELECT * FROM msdb..sysjobs_view 
                    WHERE name = @name 
                      AND UPPER(originating_server) = UPPER(CONVERT(sysname, SERVERPROPERTY('ServerName'))))
        BEGIN
			if @publication is NOT NULL and (LOWER(@publication)<>'all')
				SELECT @name = fn_repluniquename(newid(), @publisher, @publisher_db, 
					@publication, @subscriber)
			else
				SELECT @name = fn_repluniquename(newid(), @publisher, @publisher_db, 
					@subscriber, null)
        END            
    END

    IF @local_job = 1
    BEGIN
		if @job_existing = 0
		begin
	--    *******WORKAROUND*******
			DECLARE @nullchar nchar(20)
			SELECT @nullchar = NULL
	--    *******WORKAROUND*******
			-- Get Distribution category name (assumes category_id = 10)
			select @category_name = name FROM msdb.dbo.syscategories where category_id = 10

			if @frequency_recurrence_factor is null
				select @frequency_recurrence_factor = 0

			EXECUTE @retcode = dbo.sp_MSadd_repl_job
			@name = @name,
			@subsystem = 'Distribution',
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
			@nextrundate = 0,
			@nextruntime = 0,
			@runpriority = 0,
			@emailoperatorname = NULL,
			@retryattempts = @retryattempts,
			@retrydelay = @retrydelay,
			@command = @command,
			@loghistcompletionlevel = 0,
			@emailcompletionlevel = 0,
			@description = NULL,
			@category_name = @category_name,
			@failure_detection = 1,
			@agent_id = @agent_id,
			@job_id = @distribution_jobid OUTPUT

		   IF @@ERROR <> 0 or @retcode <> 0
				GOTO UNDO
		end
		else
		begin
			select @distribution_jobid = job_id from msdb..sysjobs_view where 
				name = @name and
				UPPER(originating_server) = UPPER(CONVERT(sysname, SERVERPROPERTY('ServerName')))
			if @distribution_jobid IS NULL
			begin
				-- Message from msdb.dbo.sp_verify_job_identifiers
				RAISERROR(14262, -1, -1, 'Job', @name)          
				GOTO UNDO
			end
		end
    END
    ELSE 
    BEGIN
        -- Generate a job GUID for remote agents. This will be used by the UI to uniquely
        -- identify rows returned by the enums
        set @distribution_jobid = newid();
    END

    UPDATE MSdistribution_agents SET name = @name,
        job_id = @distribution_jobid WHERE
        id = @agent_id

    IF @@ERROR <> 0
        GOTO UNDO

	-- Don't call agent offload stuff for virtual agents.
    IF @local_job = 1 and @subscription_type = 0
    BEGIN    
        -- Add offload parameter to agent command line if necessary
        IF @offloadagent = 1 
        BEGIN
            EXEC @retcode = sp_MSenableagentoffload @job_id = @distribution_jobid,
                                           @offloadserver = @offloadserver
        END
        ELSE
        BEGIN
            EXEC @retcode = sp_MSdisableagentoffload @job_id = @distribution_jobid,
                                            @offloadserver = @offloadserver
        END
        IF @@ERROR <> 0 OR @retcode <> 0
            GOTO UNDO

    END

    -- Update global replication status table
    EXEC @retcode = dbo.sp_MSupdate_replication_status
        @publisher,
        @publisher_db,
        @publication,
        @agent_type = 3,
        @agent_name = @name,
        @status = 0     -- not running status

    IF @@ERROR <> 0 OR @retcode <> 0
        GOTO UNDO

    COMMIT TRAN

    RETURN(0)
UNDO:
	--
	-- delete the MSMQ queue if necessary
	--
	if (@update_mode in (2,3) and @queue_server IS NOT NULL and @queue_id IS NOT NULL)
	begin
		exec master.dbo.xp_deleteprivatequeue @queue_server, @queue_id
	end
	
    if @@TRANCOUNT = 1
        ROLLBACK TRAN
    else
        COMMIT TRAN
    return(1)
END
GO

raiserror(15339,-1,-1,'sp_MSdrop_agent_entry')
GO
/*
** This one is reserved for future use.
*/
CREATE PROCEDURE sp_MSdrop_agent_entry (
@pub_srvid      smallint,
@pub_db_name    sysname,
@publication    sysname,
@sub_srvid      smallint,
@sub_db_name    sysname
) AS
delete from MSmerge_agents where publisher_id = @pub_srvid AND publisher_db = @pub_db_name AND publication=@publication
                                    AND subscriber_id = @sub_srvid AND subscriber_db = @sub_db_name
if @@ERROR<>0 return (1)
return (0)
GO


raiserror(15339,-1,-1,'sp_MSdrop_merge_agent')
GO
CREATE PROCEDURE sp_MSdrop_merge_agent (
    @publisher          sysname,
    @publisher_db       sysname,
    @publication        sysname,
    @subscriber         sysname,
    @subscriber_db      sysname,
    @keep_for_last_run  bit = 0 -- if the agent needs to stay to run one more time; default is NO
) AS


    SET NOCOUNT ON

    /*
    ** Declarations.
    */
    DECLARE @retcode    int
    DECLARE @job_id     binary(16)
    DECLARE @local_job  bit
    DECLARE @publisher_id smallint
    DECLARE @subscriber_id smallint
    DECLARE @job_command nvarchar(512)
    DECLARE @name nvarchar(100)
    DECLARE @agent_id   int

    /*
    ** Initializations
    */
    -- Get subscriber info
    select @subscriber_id = srvid from master..sysservers where UPPER(srvname) = UPPER(@subscriber)
    select @publisher_id = srvid from master..sysservers where UPPER(srvname) = UPPER(@publisher)


    SELECT @job_id = job_id, @local_job = local_job, @name = name, @agent_id = id FROM MSmerge_agents (updlock holdlock) 
    WHERE
        publisher_id = @publisher_id AND
        publisher_db = @publisher_db AND
        publication = @publication and
        subscriber_id = @subscriber_id and
        subscriber_db = @subscriber_db 

    -- Delete Perfmon instance
    dbcc deleteinstance ("SQL Replication Merge", @name)

    -- Return if not exists
    IF @local_job IS NULL
        RETURN(0)

    BEGIN TRAN

    IF @keep_for_last_run = 0
    BEGIN
        if @local_job=1
        begin
            IF EXISTS (SELECT * FROM msdb..sysjobs_view WHERE job_id = @job_id)
            begin
                -- Checks if the job name matches one that is generated
                -- by replication
                EXEC @retcode = dbo.sp_MSismergejobnamegenerated
                                    @publisher = @publisher,
                                    @publisher_db = @publisher_db,
                                    @publication = @publication,
                                    @subscriber = @subscriber,
                                    @job_id = @job_id
                IF @@ERROR <> 0
                    GOTO UNDO
                
                -- Only drop the job if the name was generated
                IF @retcode = 0
                BEGIN
                    EXEC @retcode = msdb.dbo.sp_delete_job @job_id = @job_id
                    IF @@ERROR <> 0 or @retcode <> 0
                        GOTO UNDO
                END
            end
        end
    END

    IF @local_job = 1 and @keep_for_last_run = 1
    BEGIN
        IF EXISTS (SELECT * FROM msdb..sysjobs_view WHERE job_id = @job_id)
        BEGIN
            EXEC @retcode = msdb.dbo.sp_update_job @job_id=@job_id, @delete_level=3 -- NOTE: Only once, success or failure!
            IF @@ERROR <> 0 or @retcode <> 0
                GOTO UNDO
            EXEC @retcode = msdb.dbo.sp_delete_jobstep @job_id=@job_id, @step_id=3
            IF @@ERROR <> 0 or @retcode <> 0
                GOTO UNDO
            EXEC @retcode = msdb.dbo.sp_delete_jobstep @job_id=@job_id, @step_id=1
            IF @@ERROR <> 0 or @retcode <> 0
                GOTO UNDO

            select @job_command=command from msdb.dbo.sysjobsteps where job_id=@job_id and step_id=1        
            select @job_command = @job_command + ' -AgentType 4 '
            
            EXEC @retcode = msdb.dbo.sp_update_jobstep @job_id=@job_id, @step_id=1, 
                @on_success_action = 1,
                @on_fail_action = 2,
                @command=@job_command
            IF @@ERROR <> 0 or @retcode <> 0
                GOTO UNDO
        END
    END

    DELETE MSmerge_agents WHERE id = @agent_id
    IF @@ERROR <> 0 
        GOTO UNDO

    -- Remove history       
    DELETE MSmerge_history WHERE agent_id = @agent_id 
    IF @@ERROR <> 0 
        GOTO UNDO

    -- Update global replication status table
    EXEC dbo.sp_MSupdate_replication_status
        @publisher,
        @publisher_db,
        @publication,
        @agent_type = 4,
        @agent_name = @name,
        @status = -1    -- delete status 

    COMMIT TRAN

    RETURN(0)

UNDO:
    if @@TRANCOUNT = 1
        ROLLBACK TRAN
    else
        COMMIT TRAN
    return(1)
GO

raiserror(15339,-1,-1,'sp_MSgetagentoffloadinfo')
GO
CREATE PROCEDURE sp_MSgetagentoffloadinfo (
    @job_id     VARBINARY(16)
    ) AS

    SET NOCOUNT ON
    DECLARE @agenttype NVARCHAR(20)
    DECLARE @offload_enabled bit
    DECLARE @offload_server  sysname
    DECLARE @agent_table     sysname  -- For use in error message
    DECLARE @independent_agent bit

    SELECT @agenttype = NULL
    SELECT @agent_table = RTRIM(@@SERVERNAME) + N'.dbo.'
    SELECT @independent_agent = 0
        
    SELECT @agenttype = LOWER(subsystem collate SQL_Latin1_General_CP1_CS_AS)
      FROM msdb..sysjobsteps
     WHERE job_id = @job_id
       AND LOWER(subsystem collate SQL_Latin1_General_CP1_CS_AS) IN (N'distribution', N'merge')

    IF @agenttype IS NULL
    BEGIN
        RAISERROR(21134, 16, -1)
        RETURN 1
    END

    IF @agenttype = N'distribution'
    BEGIN
        SELECT @offload_enabled = offload_enabled, 
               @offload_server = offload_server 
          FROM dbo.MSdistribution_agents da
    INNER JOIN dbo.MSsubscriptions s 
            ON da.id = s.agent_id
         WHERE job_id = @job_id        
        SELECT @agent_table = @agent_table + N'MSdistribution_agents'
    END
    ELSE
    BEGIN
        SELECT @offload_enabled = offload_enabled, 
               @offload_server = offload_server
          FROM dbo.MSmerge_agents
         WHERE job_id = @job_id 
        SELECT @agent_table = @agent_table + N'MSmerge_agents'
    END

    IF @@ROWCOUNT = 0
    BEGIN
        RAISERROR(21135, 16, -1, @agent_table)
        RETURN 1
    END

    IF @agenttype = N'distribution'
    BEGIN
        SELECT 'offload_enabled' = @offload_enabled,
               'offload_server' = @offload_server,
               'independent_agent' = @independent_agent
    END
    ELSE
    BEGIN
        SELECT 'offload_enabled' = @offload_enabled,
               'offload_server' = @offload_server
    END

    RETURN 0
GO

raiserror(15339,-1,-1,'sp_MSadd_merge_agent')
GO
CREATE PROCEDURE sp_MSadd_merge_agent (
-- not null if from scripting
    @name                           sysname = NULL,
    @publisher                      sysname,                    /* Publisher server */
    @publisher_db                   sysname,                    /* Publisher database */
    @publication                    sysname,                    /* Publication name */
    @subscriber                     sysname,                    /* Subscriber server */
    @subscriber_db                  sysname,                    /* Subscription database */
    @local_job                      bit,
    @frequency_type                 int = NULL,
    @frequency_interval             int = NULL,             
    @frequency_relative_interval    int = NULL, 
    @frequency_recurrence_factor    int = NULL, 
    @frequency_subday               int = NULL,
    @frequency_subday_interval      int = NULL,    
    @active_start_time_of_day       int = NULL, 
    @active_end_time_of_day         int = NULL,         
    @active_start_date              int = NULL, 
    @active_end_date                int = NULL,
    @optional_command_line          nvarchar(255) = '',     /* Optional command line arguments */
    @merge_jobid                    binary(16) = NULL OUTPUT,
    -- Agent offload
    @offloadagent                   bit = 0,
    @offloadserver                  sysname = NULL,
    @subscription_type              int = 0 -- 0 = push, 1 = pull
    ) AS

    SET NOCOUNT ON

    /*
    ** Declarations.
    */
    declare @retcode        int
    DECLARE @publisher_id   smallint
    DECLARE @subscriber_id  smallint
    DECLARE @profile_id     int
    DECLARE @merge_type     int
    DECLARE @command        nvarchar(4000)

    DECLARE @subscriber_security_mode       int                 /* 0 standard; 1 integrated */
    DECLARE @subscriber_login               sysname 
    DECLARE @subscriber_password            nvarchar(524) 
    DECLARE @subscriber_datasource_type     int     /* 0 SQL Server, 1 ODBC, 2 Jet, 3 OLEDB */
    DECLARE @distributor                    sysname 
    DECLARE @distributor_security_mode      int                     /* 0 standard; 1 integrated */
    DECLARE @distributor_login              sysname 
    DECLARE @distributor_password           nvarchar(524)
    DECLARE @database                       sysname
    DECLARE @agent_id                       int
    DECLARE @category_name                  sysname
    DECLARE @dsn_subscriber                 tinyint
    DECLARE @jet_subscriber                 tinyint
    DECLARE @oledb_subscriber               tinyint
	DECLARE @exchange_subscriber            tinyint
	DECLARE @oracle_subscriber              tinyint
	DECLARE @db2universal_subscriber        tinyint
    DECLARE @platform_nt                    binary
	DECLARE @provider_name					sysname

    set @subscriber_security_mode = 1
    set @subscriber_login = NULL
    set @subscriber_password = NULL
    set @distributor = @@SERVERNAME

    set @dsn_subscriber = 1    /* Const: subscriber type 'dsn' */ 
    set @jet_subscriber = 2   
    set @oledb_subscriber = 3 
	set @exchange_subscriber = 4
	set @oracle_subscriber = 5 
	set @db2universal_subscriber = 6

    set @platform_nt = 0x1  
    
    -- Set null @optional_command_line to empty string to avoid string concat problem
    if @optional_command_line is null
        set @optional_command_line = ''
    else
        set @optional_command_line = N' ' + LTRIM( RTRIM(@optional_command_line) ) + N' '

    -- Get subscriber security context
    select  @subscriber_security_mode = security_mode,
            @subscriber_login = login,
            @subscriber_password = password
        from MSsubscriber_info where
            UPPER(publisher) = UPPER(@publisher) and
            UPPER(subscriber) = UPPER(@subscriber)
            
    -- Always use integrated security on winNT
    if (@platform_nt = platform() & @platform_nt )
        set @distributor_security_mode = 1
    else
    begin
        select  @distributor_security_mode = 0,
                @distributor_login  = login,
                @distributor_password = password
            from msdb..MSdistpublishers where UPPER(name) = UPPER(@@servername)
    end
    
    /*
    ** Initializations
    */
    -- Get subscriber info
    select @subscriber_id = srvid from master..sysservers where UPPER(srvname) = UPPER(@subscriber)
    select @publisher_id = srvid from master..sysservers where UPPER(srvname) = UPPER(@publisher)

    select @subscriber_datasource_type = type
        from MSsubscriber_info 
        where UPPER(publisher) = UPPER(@publisher) and UPPER(subscriber) = UPPER(@subscriber)

	/*
	** Jet and Oracle subscribers are actually added to MSsubscriber_info as OLE DB subscribers,
	** since they can be used in transactional replication also.
	** Map the type to Jet or Oracle based on OLE DB provider name.
	*/
	if (@subscriber_datasource_type = @oledb_subscriber) 
	BEGIN
		select @provider_name = providername from master..sysservers where UPPER(srvname) = UPPER(@subscriber)
		if (upper(@provider_name) = 'MICROSOFT.JET.OLEDB.4.0')
			select @subscriber_datasource_type = @jet_subscriber
		else if (upper(@provider_name) = 'MSDAORA')
			select @subscriber_datasource_type = @oracle_subscriber
		else if (upper(@provider_name) = 'DB2OLEDB')
			select @subscriber_datasource_type = @db2universal_subscriber
	END
    
	if (@subscriber_datasource_type IS NULL)
        select @subscriber_datasource_type = 0

	-- if @name is not null, the proc is from DMO scripting
	-- check to see if the job is there are not, if not, reset @job_existing and
	-- @name values. This is for the case when the user generate the script at
	-- the publisher but did not re-create repl jobs at the distributor.
	if @local_job = 1 and @name is not null and 
       @name <> N''
	begin
		if not exists (select * from msdb..sysjobs_view where 
			name = @name and
			UPPER(originating_server) = UPPER(CONVERT(sysname, SERVERPROPERTY('ServerName'))))
		begin
			set @name = null
		end
	end

    BEGIN TRAN

    -- Try to drop it first
    EXEC dbo.sp_MSdrop_merge_agent 
        @publisher = @publisher,
        @publisher_db = @publisher_db,
        @publication = @publication,
        @subscriber = @subscriber,
        @subscriber_db = @subscriber_db
          
    IF @@ERROR <> 0
        GOTO UNDO

    /* Code for merge agent type in MSagent_profiles */
    SELECT @merge_type = 4

    SELECT @profile_id = profile_id
    FROM msdb..MSagent_profiles
    WHERE agent_type = @merge_type
        AND def_profile = 1

    IF @profile_id IS NULL
        RETURN (1)

    /* 
    ** Insert row
    */
    INSERT INTO MSmerge_agents (name, publisher_id, publisher_db, publication, 
         subscriber_id, subscriber_db, local_job, profile_id)
         VALUES ('',@publisher_id, @publisher_db, @publication, 
         @subscriber_id, @subscriber_db, @local_job, @profile_id)
    IF @@ERROR <> 0
        GOTO UNDO

    set @agent_id = @@IDENTITY
    
    if @frequency_type is NULL
        set @frequency_type = 4     /* Daily */
    if @frequency_interval is NULL
        set @frequency_interval = 1
    if @frequency_relative_interval is NULL
        set @frequency_relative_interval = 1
    if @frequency_recurrence_factor is NULL
        set @frequency_recurrence_factor = 0
    if @frequency_subday is NULL
        set @frequency_subday = 8   /* Hour */
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

	declare @job_existing bit
    IF @name IS NULL OR @name = N''
	begin
        SELECT @name = CONVERT(nvarchar(21),@publisher ) + '-' + CONVERT(nvarchar(21),@publisher_db) + '-' + 
                        CONVERT(nvarchar(21),@publication) + '-' + CONVERT(nvarchar(21),@subscriber) + '-' +
                            CONVERT(nvarchar, @@IDENTITY)
		select @job_existing = 0
	end
	else
		select @job_existing = 1
    
	-- If creating a new job and the generated name already exists, re-generate the name with a 
    -- guid appended
    IF  @job_existing = 0
    BEGIN
        IF EXISTS (SELECT * FROM msdb..sysjobs_view 
                    WHERE name = @name 
                      AND UPPER(originating_server) = UPPER(CONVERT(sysname, SERVERPROPERTY('ServerName'))))
        BEGIN
			SELECT @name = fn_repluniquename(newid(), @publisher, @publisher_db, 
				@publication, @subscriber)
        END            
    END

	-- Add Perfmoon instance
    dbcc addinstance ("SQL Replication Merge", @name)

    IF @local_job = 1
    BEGIN
		if @job_existing = 0
		begin

			/* Construct task command */

			select @command = '-Publisher ' + QUOTENAME(@publisher) + ' -PublisherDB ' + QUOTENAME(@publisher_db) + ' '
			select @command = @command + '-Publication ' + QUOTENAME(@publication) + ' '
			select @command = @command + '-Subscriber ' + QUOTENAME(@subscriber)  + ' '

			if (@subscriber_datasource_type = 0)
				select @command = @command + '-SubscriberDB ' + QUOTENAME(@subscriber_db) + ' '
        
			if (@subscriber_datasource_type <> 0)
				select @command = @command + '-SubscriberType ' + convert(nvarchar(10),@subscriber_datasource_type) + ' '
    
			select @command = @command + @optional_command_line
			select @command = @command + '-Distributor ' + QUOTENAME(@distributor) + ' '

			select @command = @command + '-DistributorSecurityMode ' + 
				convert(nvarchar(10),@distributor_security_mode) +  ' ' 
			if @distributor_security_mode <> 1
			begin
				if @distributor_login is not NULL
					select @command = @command + '-DistributorLogin ' + @distributor_login + ' '
				if @distributor_password is not NULL
					select @command = @command + '-DistributorEncryptedPassword ' + quotename(@distributor_password) + ' '
			end

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
					@category_name = @category_name,
					@failure_detection = 1,
					@agent_id = @agent_id,
					@retryattempts = 10,
					@retrydelay = 1,
					@job_id = @merge_jobid OUTPUT
            
			if @@ERROR <> 0 or @retcode <> 0
				goto UNDO
		end
		else
		begin
			select @merge_jobid = job_id from msdb..sysjobs_view where 
				name = @name and
				UPPER(originating_server) = UPPER(CONVERT(sysname, SERVERPROPERTY('ServerName')))
			if @merge_jobid IS NULL
			begin
				-- Message from msdb.dbo.sp_verify_job_identifiers
				RAISERROR(14262, -1, -1, 'Job', @name)          
				GOTO UNDO
			end
		end
    END /* for local_job = 1 */
    ELSE 
    BEGIN
        -- Generate a job GUID for remote agents. This will be used by the UI to uniquely
        -- identify rows returned by the enums
        set @merge_jobid = newid();
    END
            
    UPDATE MSmerge_agents SET name = @name,
        job_id = @merge_jobid WHERE
        id = @agent_id

    IF @@ERROR <> 0
        GOTO UNDO


    IF @subscription_type = 0
    BEGIN
        -- Add offload parameter to agent command line if necessary
        IF @offloadagent = 1 
        BEGIN
            EXEC @retcode = sp_MSenableagentoffload @job_id = @merge_jobid,
                                            @offloadserver = @offloadserver
        END
        ELSE
        BEGIN
            EXEC @retcode = sp_MSdisableagentoffload @job_id = @merge_jobid,
                                            @offloadserver = @offloadserver 
        END
        IF @@ERROR <> 0 OR @retcode <> 0
            GOTO UNDO

    END

    -- Update global replication status table
    EXEC dbo.sp_MSupdate_replication_status
        @publisher,
        @publisher_db,
        @publication,
		@publication_type = 1, -- Merge 
        @agent_type = 4,
        @agent_name = @name,
        @status = 0     -- not running status

    COMMIT TRAN

    RETURN(0)

UNDO:
    if @@TRANCOUNT = 1
        ROLLBACK TRAN
    else
        COMMIT TRAN
    return(1)
GO

raiserror(15339,-1,-1,'sp_MSdrop_subscription')
GO
CREATE PROCEDURE sp_MSdrop_subscription
@publisher sysname,
@publisher_db sysname,
@subscriber sysname,
@article_id int = NULL,
@subscriber_db sysname = NULL,
@publication sysname = NULL,
@article sysname = NULL

as

    set nocount on

    declare @publisher_id smallint
    declare @subscriber_id smallint
    declare @name nvarchar (100)
    declare @retcode int
    declare @push tinyint
    declare @anonymous tinyint
    declare @keep_for_last_run bit
    declare @virtual smallint
    declare @virtual_anonymous smallint
    declare @independent_agent bit
    declare @publication_id int
    declare @subscription_type int
    declare @thirdparty_flag bit
    declare @id             int
	declare @publication_name sysname
	declare @queued_sub_precount int

    select @push = 0        -- const: push subscription type 
    select @anonymous = 2   -- const: push subscription type 
    select @virtual = -1    -- const: virtual subscriber id 
    select @virtual_anonymous = -2  -- const: virtual anonymous subscriber id 

    -- Select the current count of the queued subscribers prior to 
    -- dropping this subscription
    select @queued_sub_precount = count(*) from dbo.MSsubscriptions where update_mode in (2,3,4,5)

	-- Save off name for dummy status row
	select @publication_name = @publication

    -- Check if publisher is a defined as a distribution publisher in the current database
    exec @retcode = dbo.sp_MSvalidate_distpublisher @publisher, @publisher_id OUTPUT
    if @retcode <> 0
    begin
        return(1)
    end

    -- Check if subscriber exists
    if @subscriber is null
    begin
        select @subscriber_id = @virtual
        -- hardcoded in sp_MSadd_subscription
        select @subscriber_db = 'virtual'
    end
    else
        select @subscriber_id = srvid from master..sysservers, MSsubscriber_info where 
            UPPER(srvname) = UPPER(@subscriber) and
            UPPER(subscriber) = UPPER(@subscriber) and
            UPPER(publisher) = UPPER(@publisher)
    if @subscriber_id is NULL
    begin
        raiserror (20032, 16, -1, @subscriber, @publisher) 
        return (1)
    end

    -- If publication exists this is a post 6.x publisher
    if @publication is not NULL
    begin
        select @publication_id = publication_id,
               @thirdparty_flag = thirdparty_flag
            from MSpublications where
            publisher_id = @publisher_id and
            publisher_db = @publisher_db and
            publication = @publication
            
        -- Get article_id 
        if @article is not NULL and @article_id = 0
        begin
            select @article_id = article_id from MSarticles where 
                publisher_id = @publisher_id and
                publisher_db = @publisher_db and
                publication_id = @publication_id and
                article = @article
        end
        -- Check that subscription exists
        -- Only do the check for post 6x publisher
        if not exists (select * from MSsubscriptions where 
            publisher_id = @publisher_id and 
            publisher_db = @publisher_db and 
            publication_id = @publication_id and
            subscriber_id = @subscriber_id and
            subscriber_db = @subscriber_db)
        begin
            if @thirdparty_flag = 1
            begin
                raiserror (14050, 16, -1)
                return(1)
            end
            else
                return (0)
        end
    end

    -- get the subscription type
    -- used when dropping dist agent
    select @subscription_type = subscription_type, 
        @independent_agent = independent_agent
        from MSsubscriptions where
        publisher_id = @publisher_id and
        publisher_db = @publisher_db and
        (publication_id = @publication_id or
         @publication_id is NULL) and
        (@article_id is NULL or
        article_id = @article_id) and
        (subscriber_id = @subscriber_id and
        (subscriber_db = @subscriber_db or @subscriber_id = @virtual))

    begin transaction
    save transaction MSdrop_subscription

    -- Delete the subscription 
    -- For anonymous type, delete virtual anonymous subscription also
    -- if deleting the  virtual subscription 
    -- (since there can be only one subscriber_id per article, subscriber_db doesn't matter)
    delete from MSsubscriptions where
        publisher_id = @publisher_id and
        publisher_db = @publisher_db and
        (publication_id = @publication_id or
         @publication_id is NULL) and
        (@article_id is NULL or
        article_id = @article_id) and
        ((subscriber_id = @subscriber_id and
        (subscriber_db = @subscriber_db or @subscriber_id = @virtual)) or
        -- Delete virtual anonymous subscription 
        -- if deleting virtual subscription for a anonymous publication
       (@subscriber_id = @virtual and subscriber_id = @virtual_anonymous))

    if @@error <> 0
    begin
        if @@trancount > 0
        begin
            rollback transaction MSdrop_subscription
            commit transaction  -- to finish off the tran we started in this proc (though 
                            -- work was rolled back to savepoint)
        end
        return 1
    end
	
    -- If it is the last subscription for the distribution agent, drop the dist agent
    if not exists (select * from MSsubscriptions    where
        publisher_id = @publisher_id and
        publisher_db = @publisher_db and
        (publication_id = @publication_id or
        @publication_id is NULL or
         @independent_agent = 0 ) and
        independent_agent = @independent_agent and
        subscriber_id = @subscriber_id and
        subscriber_db = @subscriber_db and
        subscription_type = @subscription_type)
    begin
        -- Harded coded in sp_MSadd_subscription.
        if @independent_agent = 0
            select @publication = 'ALL'
        /*
        ** Get agentid to check history record
        */
	    select @id=id from MSdistribution_agents where 
        publisher_id = @publisher_id and
        publisher_db = @publisher_db and
        publication = @publication and
        subscriber_id = @subscriber_id and
        subscriber_db = @subscriber_db

    /*
    ** If the subscription has not yet been synced, there is no need for subscriber side cleanup 
    ** therefore no need for the last agent run.
    */
    if exists (select * from MSdistribution_history where agent_id = @id)
        select @keep_for_last_run = 0 -- default is not to do cleanup
    else 
        select @keep_for_last_run = 0


    /*
    ** Delete distribution task.
    */
        execute @retcode = dbo.sp_MSdrop_distribution_agent 
            @publisher_id = @publisher_id,
            @publisher_db = @publisher_db,
            @publication = @publication,
            @subscriber_id = @subscriber_id,
            @subscriber_db = @subscriber_db,
            @subscription_type = @subscription_type,
            @keep_for_last_run = @keep_for_last_run  

        if @@error <> 0 or @retcode <> 0
        begin
            if @@trancount > 0
            begin
                rollback transaction MSdrop_subscription
                commit transaction  -- to finish off the tran we started in this proc (though 
                                -- work was rolled back to savepoint)
            end
            return 1
        end
    end

    
    -- Delete anonymous agents that are not in subscription table anymore
    -- It is due to dropping articles. Don't raise messages
    if @subscriber_id = @virtual
    begin
        delete MSdistribution_agents where
            anonymous_agent_id is not null and 
            not exists (select * from MSsubscriptions s where
                s.agent_id = anonymous_agent_id)


        if @@error <> 0
        begin
            if @@trancount > 0
            begin
                rollback transaction MSdrop_subscription
                commit transaction  -- to finish off the tran we started in this proc (though 
                                -- work was rolled back to savepoint)
            end
            return 1
        end
    end


	-- delete any rows in syncstate tracking table

	delete MSsync_states where 
		publisher_id = @publisher_id and
		publisher_db = @publisher_db and
		publication_id = @publication_id 

    if @@error <> 0
    begin
        if @@trancount > 0
        begin
            rollback transaction MSdrop_subscription
            commit transaction  -- to finish off the tran we started in this proc (though 
                            -- work was rolled back to savepoint)
        end
        return 1
    end


    commit transaction

    --  Add dummy distribution aent row entry for publication.  This will allow the status
	--  for the shared distribution agent to be restricted
	if @publication_name IS NOT NULL
	begin
		EXEC dbo.sp_MSupdate_replication_status
			@publisher,
		    @publisher_db,
		    @publication_name, 
			@agent_type = 3,   
			@agent_name = NULL, 
			@status = -1	-- delete
	end

    -- Refresh global status table. 
    EXEC dbo.sp_MSupdate_replication_status
        @publisher,
        @publisher_db,
        @publication = '%',	-- refresh the publisher node.
		@agent_type = NULL,	-- Not used	with @status = -2
		@agent_name = NULL, -- Not used with @status = -2
        @status = -2    -- refresh status

	-- Check to see if we need to drop the qreader agent
	if (@@error = 0 and @queued_sub_precount = 1 and
		not exists (select * from dbo.MSsubscriptions where update_mode in (2,3,4,5)))
	begin
		declare @agent_id int
		
		select top 1 @agent_id = id from dbo.MSqreader_agents
		if (@agent_id is not null)
			execute dbo.sp_MSdrop_qreader_agent @agent_id
	end    

GO

raiserror(15339,-1,-1,'sp_MSadd_subscription')
GO
CREATE PROCEDURE sp_MSadd_subscription
@publisher sysname,
@publisher_db sysname,
@subscriber sysname,       
@article_id int = NULL,
@subscriber_db sysname = NULL,
@status tinyint,                    -- 0 = inactive, 1 = subscribed, 2 = active 
@subscription_seqno varbinary(16),  -- publisher's database sequence number 

-- Post 6.5 parameters
@publication sysname = NULL,    -- 6.x publishers will not provide this
@article sysname = NULL,
@subscription_type tinyint = 0,     -- 0 = push, 1 = pull, 2 = anonymous 
@sync_type tinyint = 0,             -- 0 = none  1 = automatic snaphot  2 = no intial snapshot
@snapshot_seqno_flag bit = 0,       -- 1 = subscription seqno is the snapshot seqno

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
@optional_command_line nvarchar(4000) = '',

-- synctran
@update_mode tinyint = 0, -- 0 = read only, 1 = sync tran, 2 = queued tran, 
						  -- 3 = failover, 4 = sqlqueued tran, 5 = sqlqueued failover
@loopback_detection bit = 0,
@distribution_jobid binary(16) = NULL OUTPUT,

-- agent offload
@offloadagent  bit = 0,
@offloadserver sysname = NULL,

-- If agent is already created, the package name will be ignored.		 
@dts_package_name sysname = NULL,
@dts_package_password nvarchar(524) = NULL,
@dts_package_location	int = 0,
@distribution_job_name sysname = NULL

as

    set nocount on
    declare @publisher_id smallint
    declare @subscriber_id smallint
    declare @command nvarchar (4000)
    declare @type tinyint
    declare @database sysname
    declare @long_name nvarchar (255)
    declare @retcode int
    declare @login sysname
    declare @password nvarchar(524)
    declare @retryattempts int
    declare @retrydelay int
    declare @virtual smallint                       -- const: virtual subscriber id 
    declare @virtual_anonymous smallint                 -- const: virtual anonymous subscriber id 
    declare @publication_str nvarchar (32)
    declare @agent_id int
    declare @publication_id int
    declare @independent_agent bit
    declare @allow_pull bit
    declare @active tinyint

    declare @flushfrequency int 
    declare @frequencytype int
    declare @frequencyinterval int 
    declare @frequencyrelativeinterval int
    declare @frequencyrecurrencefactor int 
    declare @frequencysubday int 
    declare @frequencysubdayinterval int
    declare @activestarttimeofday int
    declare @activeendtimeofday int
    declare @activestartdate int 
    declare @activeenddate int 
    DECLARE @dsn_subscriber tinyint
    DECLARE @jet_subscriber tinyint
    DECLARE @oledb_subscriber tinyint
    declare @thirdparty_flag bit

    DECLARE @distributor_security_mode      int                     /* 0 standard; 1 integrated */
    DECLARE @distributor_login              sysname 
    DECLARE @distributor_password           nvarchar(524)
    DECLARE @publisher_database_id int
    DECLARE @platform_nt binary
    declare @anonymous_agent_id int
	DECLARE @agent_name nvarchar(100)
	DECLARE @publication_name sysname

	-- Store off publication name for dummy monitor row
	select @publication_name = @publication

    -- Defined in sqlrepl.h
    -- Set null @optional_command_line to empty string to avoid string concat problem
    if @optional_command_line is null
        set @optional_command_line = ''
    else
        set @optional_command_line = N' ' + LTRIM( RTRIM(@optional_command_line) ) + N' '

    select @dsn_subscriber = 1    /* Const: subscriber type 'dsn' */ 
    select @jet_subscriber = 2   
    select @oledb_subscriber = 3   

    select @virtual = -1
    select @virtual_anonymous = -2

    select @active = 2

    select @platform_nt = 0x1

    -- Check if publisher is a defined as a distribution publisher in the current database
    exec @retcode = dbo.sp_MSvalidate_distpublisher @publisher, @publisher_id OUTPUT
    if @retcode <> 0 or @@error <> 0
    begin
        return(1)
    end

    -- Check if subscriber exists
    if @subscriber is null
    begin
      select @subscriber_id = @virtual
      -- The following 2 variables are hardcoded in sp_MSget_repl_cmds_anonymous 
      select @subscriber_db = 'virtual'
      select @subscription_type = 0
    end
    else
        select @subscriber_id = srvid from master..sysservers, MSsubscriber_info where 
            UPPER(srvname) = UPPER(@subscriber) and
            UPPER(subscriber) = UPPER(@subscriber) and
            UPPER(publisher) = UPPER(@publisher)
    if @subscriber_id is NULL
    begin
        raiserror (20032, 16, -1, @subscriber, @publisher) 
        return (1)
    end
    -- Special logic for 6.5 publisher.
    -- If publisher_id, publisher_db pair is not in MSpublisher_databases then add it.  This will be used
    -- to store a publisher_database_id in the MSrepl_transactions and MSrepl_commands table.
    if @publication is null
    begin
    	if not exists (select * from MSpublisher_databases where publisher_id = @publisher_id and
        	publisher_db = @publisher_db)
    	begin
        	insert into MSpublisher_databases (publisher_id, publisher_db) values (@publisher_id, @publisher_db)
        	if @@error <> 0
            	goto UNDO
    	end
    end
	
	-- Get publisher_database_id
    select @publisher_database_id = id from MSpublisher_databases where publisher_id = @publisher_id and
        publisher_db = @publisher_db
    if @@error <> 0
        return 1

    -- If publication exists this is a post 6.x publisher
    if @publication is not NULL
    begin
        select @publication_id = publication_id, 
            @independent_agent = independent_agent, @allow_pull = allow_pull,
            @thirdparty_flag = thirdparty_flag from 
            MSpublications where 
            publisher_id = @publisher_id and
            publisher_db = @publisher_db and
            publication = @publication
        if @publication_id is NULL
        begin
            raiserror (20026, 11, -1, @publication)
            return (1)
        end

        -- Check if article_id exists
        if @article_id is not NULL 
        begin
            if not exists (select * from MSarticles where 
                publisher_id = @publisher_id and
                publisher_db = @publisher_db and
                article_id = @article_id)
            begin
                raiserror (20027, 11, -1, @article) 
                return (1)
            end
        end

        -- Check if article exists
        if @article is not NULL and @article_id is NULL
        begin
            select @article_id = article_id from MSarticles where 
                publisher_id = @publisher_id and
                publisher_db = @publisher_db and
                article = @article
            if @article_id is NULL
            begin
                raiserror (20027, 11, -1, @article) 
                return (1)
            end
        end
    end
    else
    begin   -- Set 6.x publishing values
        select @publication_id = 0
        select @independent_agent = 0
        select @allow_pull = 0
        select @thirdparty_flag = 0
    end

    -- Make sure subscription does not already exist
    if exists (select * from MSsubscriptions where 
        publisher_id = @publisher_id and 
        publisher_db = @publisher_db and 
        publication_id = @publication_id and
        article_id = @article_id and
        subscriber_id = @subscriber_id and
        subscriber_db = @subscriber_db)
    begin
        if @thirdparty_flag = 1
        begin
            raiserror (14058, 16, -1)
            return(1)
        end
        else
        begin
            exec @retcode = dbo.sp_MSdrop_subscription
                @publisher = @publisher,
                @publisher_db = @publisher_db,
                @subscriber = @subscriber,
                @article_id = @article_id,
                @subscriber_db = @subscriber_db,
                @publication = @publication,
                @article = @article
            if @retcode <> 0 or @@error <> 0
            begin
                return(1)
            end
        end
    end

    -- Check to see if we need to add a new distribution agent for the subscription.
    -- It is database wide for non independent agent publications, and publication wide otherwise.
    -- Check to see if the distribution agent for this subscription is already added.

    select @agent_id = NULL
    select @agent_id = agent_id from 
        MSsubscriptions where
        publisher_id = @publisher_id and
        publisher_db = @publisher_db and
        subscription_type = @subscription_type and
        (publication_id = @publication_id or @independent_agent = 0) and
        independent_agent = @independent_agent and 
        subscriber_id = @subscriber_id and
        subscriber_db = @subscriber_db

    if @subscriber_id = @virtual
    begin
        select @anonymous_agent_id = agent_id from 
            MSsubscriptions where
            publisher_id = @publisher_id and
            publisher_db = @publisher_db and
            subscription_type = @subscription_type and
            (publication_id = @publication_id or @independent_agent = 0) and
            independent_agent = @independent_agent and 
            subscriber_id = @virtual_anonymous and
            subscriber_db = @subscriber_db
    end
    
    -- Always use integrated security on winNT
    if (@platform_nt = platform() & @platform_nt )
        set @distributor_security_mode = 1
    else
    begin
        select  @distributor_security_mode = 0,
                @distributor_login  = login,
                @distributor_password = password
            from msdb..MSdistpublishers where UPPER(name) = UPPER(@@servername)
	end

    --Get default task parameter values from MSsubscriber_info 
    select @type = type
    from MSsubscriber_info 
    where UPPER(publisher) = UPPER(@publisher) and UPPER(subscriber) = UPPER(@subscriber)

	-- Only SQL Server and OLEDB subscriber support dts
	if @dts_package_name is not null and @type not in (0, @oledb_subscriber)
	begin
		-- Only sqlserver or oledb sub are allowed
		raiserror(21170, 16, -1)
		return 1
	end

    begin tran
    save transaction MSadd_subscription

    if @agent_id is NOT NULL
    begin
        select @distribution_jobid = job_id from MSdistribution_agents
            where id = @agent_id
    end
    else
    begin


        -- Create distribution agent
        -- Do not create local job if
        -- 1. virtual subscription 
        -- 2. no subscriber information, return (6.x legacy)
        -- 3. pull (this sp will not be called for anonymous subscription)

        declare @local_job bit

        if @subscriber_id = @virtual or 
            not exists (select * from MSsubscriber_info where
                UPPER(publisher) = UPPER(@publisher) and UPPER(subscriber) = UPPER(@subscriber)) OR 
            @subscription_type = 1 

            select @local_job = 0
        else
            select @local_job = 1

        -- 'ALL' is reserved for indication all publications
        -- Hardcoded in sp_MSenum*... 
        -- Note! @publication is overwritten
        
        if @independent_agent = 0
            select @publication = 'ALL'

        if @local_job = 1
        begin
            select 
                @frequencytype = frequency_type,
                @frequencyinterval = frequency_interval,
                @frequencyrelativeinterval = frequency_relative_interval,
                @frequencyrecurrencefactor = frequency_recurrence_factor,
                @frequencysubday = frequency_subday,
                @frequencysubdayinterval = frequency_subday_interval,
                @activestarttimeofday = active_start_time_of_day,
                @activeendtimeofday = active_end_time_of_day,
                @activestartdate = active_start_date,
                @activeenddate = active_end_date
            from MSsubscriber_schedule 
            where UPPER(publisher) = UPPER(@publisher) and UPPER(subscriber) = UPPER(@subscriber) and agent_type = 0    

            if @frequency_type is null
                select @frequency_type = @frequencytype

            if @frequency_interval  is null
                select  @frequency_interval = @frequencyinterval

            if @frequency_relative_interval is null
                select  @frequency_relative_interval = @frequencyrelativeinterval

            if @frequency_recurrence_factor is null
                select  @frequency_recurrence_factor = @frequencyrecurrencefactor

            if @frequency_subday is null
                select  @frequency_subday = @frequencysubday

            if @frequency_subday_interval is null
                select  @frequency_subday_interval = @frequencysubdayinterval

            if @active_start_time_of_day is null
                select  @active_start_time_of_day = @activestarttimeofday

            if @active_end_time_of_day is null
                select  @active_end_time_of_day = @activeendtimeofday

            if @active_start_date is null
                select  @active_start_date = @activestartdate

            if @active_end_date is null
                select  @active_end_date = @activeenddate

            -- Construct task command 
            select @command = '-Subscriber ' + QUOTENAME(@subscriber)  + ' '

			declare @dsn_dbname sysname
		    SELECT @dsn_dbname = formatmessage(20586)
            -- DSN subscribers don't have a subscriber db name.
            if @subscriber_db is not NULL --AND @type NOT IN( @dsn_subscriber,@jet_subscriber, @oledb_subscriber)
			-- 7.0 publisher still uses DSN. 8.0 publisher use localized '(default destination)'
			-- ActiveX may use unlocalized '(default destination)'
			AND @subscriber_db NOT IN( N'(default destination)', N'DSN', @dsn_dbname)
			begin
                select @command = @command  + '-SubscriberDB ' + QUOTENAME(@subscriber_db) + ' '
			end
            select @command = @command + '-Publisher ' + QUOTENAME(@publisher) + ' '
            select @command = @command + '-Distributor ' + QUOTENAME(@@SERVERNAME) + ' '

            select @command = @command + '-DistributorSecurityMode ' + 
                convert(nvarchar(10),@distributor_security_mode) +  ' ' 
            if @distributor_security_mode <> 1
            begin
                if @distributor_login is not NULL
                    select @command = @command + '-DistributorLogin ' + @distributor_login + ' '
                if @distributor_password is not NULL
                    select @command = @command + '-DistributorEncryptedPassword ' + quotename(@distributor_password) + ' '
            end

            if @independent_agent = 1
                select @command = @command +'-Publication ' + QUOTENAME(@publication) + ' '

            if @publisher_db is not NULL
                select @command = @command + '-PublisherDB ' + QUOTENAME(@publisher_db) + ' '

            if @type = @dsn_subscriber or @type = @oledb_subscriber
              select @command = @command + '-SubscriberType ' + convert (nvarchar(10),@type) + ' '
			
			if @dts_package_name is not null
              select @command = @command + '-UseDTS '
			

            -- 64 is auto-start. Agents should be in continuous mode. sp_MSadd_repl_job will append "-Continuous" to the end of command line

            if datalength(@command) + datalength(@optional_command_line) > 8000
            begin
                RAISERROR(20018, 16, -1)
                RETURN(1)
            end
            select @command = @command + @optional_command_line
            
            execute @retcode = dbo.sp_MSadd_distribution_agent
                @publisher_id = @publisher_id,
                @publisher_db = @publisher_db,
                @publication = @publication,
                @subscriber_id = @subscriber_id,
                @subscriber_db = @subscriber_db,
                @subscription_type = @subscription_type,
                @local_job = @local_job,
                @frequency_type = @frequency_type,
                @frequency_interval = @frequency_interval,
                @frequency_subday = @frequency_subday,
                @frequency_subday_interval = @frequency_subday_interval,
                @frequency_relative_interval = @frequency_relative_interval,
                @frequency_recurrence_factor = @frequency_recurrence_factor,
                @active_start_date = @active_start_date,
                @active_end_date = @active_end_date,
                @active_start_time_of_day = @active_start_time_of_day,
                @active_end_time_of_day = @active_end_time_of_day,
                @command = @command,
                @agent_id = @agent_id OUTPUT,
                @distribution_jobid = @distribution_jobid OUTPUT,
				@update_mode = @update_mode,
                @offloadagent = @offloadagent,
                @offloadserver = @offloadserver,
				@dts_package_name = @dts_package_name,
				@dts_package_password = @dts_package_password,
				@dts_package_location = @dts_package_location,
				@name = @distribution_job_name


            if @@error <> 0 or @retcode <> 0
                goto UNDO
        end
        else
        begin
            execute @retcode = dbo.sp_MSadd_distribution_agent
                @publisher_id = @publisher_id,
                @publisher_db = @publisher_db,
                @publication = @publication,
                @subscriber_id = @subscriber_id,
                @subscriber_db = @subscriber_db,
                @subscription_type = @subscription_type,
                @local_job = @local_job,
                @agent_id = @agent_id OUTPUT,
                @distribution_jobid = @distribution_jobid OUTPUT,
				@update_mode = @update_mode,
                @offloadagent = @offloadagent,
                @offloadserver = @offloadserver 
				
				-- Only push has distributor side package.

            if @@error <> 0 or @retcode <> 0
                goto UNDO
        end

        if @subscriber_id = @virtual
        begin
            execute @retcode = dbo.sp_MSadd_distribution_agent
                @publisher_id = @publisher_id,
                @publisher_db = @publisher_db,
                @publication = @publication,
                @subscriber_id = @virtual_anonymous,
                @subscriber_db = @subscriber_db,
                @subscription_type = @subscription_type,
                @local_job = @local_job,
                @agent_id = @anonymous_agent_id OUTPUT,
                @distribution_jobid = @distribution_jobid OUTPUT,
				@update_mode = @update_mode
                -- No need to specify offload parameters for virtual agents
                -- No need to specify package name for virtual agents
        end
    end

    insert into MSsubscriptions values (@publisher_database_id, @publisher_id, @publisher_db, @publication_id,
        @article_id, @subscriber_id, @subscriber_db, @subscription_type, @sync_type, @status, 
        @subscription_seqno, @snapshot_seqno_flag, @independent_agent, getdate(), 
        -- synctran
        @loopback_detection, @agent_id, @update_mode, @subscription_seqno, @subscription_seqno)
    if @@error <> 0
        goto UNDO

    -- For shiloh, always add virtual anonymous entry for attach logic
	-- If anonymous publication, add "virtual anonymous" subscription
    -- when adding the virtual subscription
    if @subscriber_id = @virtual
    begin
        insert into MSsubscriptions values (@publisher_database_id, @publisher_id, @publisher_db, @publication_id,
            @article_id, @virtual_anonymous, @subscriber_db, @subscription_type, @sync_type, @status, 
            @subscription_seqno, @snapshot_seqno_flag, @independent_agent, getdate(), 
            -- synctran
            @loopback_detection, @anonymous_agent_id, @update_mode, @subscription_seqno, @subscription_seqno)
        if @@error <> 0
            goto UNDO
    end

	-- Check to see if we need to add a new qreader agent
	if (@update_mode in (2,3,4,5))
	begin
		--
		-- we can have only one agent for the distribution database
		--
		if not exists (select * from dbo.MSqreader_agents) 
		begin
			execute @retcode = dbo.sp_MSadd_qreader_agent
			if (@retcode != 0 or @@error != 0)
				goto UNDO
		end
	end
	
    commit transaction

    --  Add dummy distribution aent row entry for publication.  This will allow the status
	--  for the shared distribution agent to be restricted
	if @publication_name IS NOT NULL
	begin
	    select @agent_name = name from MSdistribution_agents where id = @agent_id

		if @agent_name IS NOT NULL
			EXEC dbo.sp_MSupdate_replication_status
				@publisher,
			    @publisher_db,
			    @publication_name, 
				@agent_type = 3,   
				@agent_name = @agent_name, 
				@status = -3	-- Use current agent_status
	end

    -- Refresh global status table. 
    EXEC dbo.sp_MSupdate_replication_status
        @publisher,
        @publisher_db,
        @publication = '%',	-- refresh the publisher node.
		@agent_type = NULL,	-- Not used	with @status = -2
		@agent_name = NULL, -- Not used with @status = -2
        @status = -2    -- refresh status

    return(0)

UNDO:
    if @@TRANCOUNT > 0
    begin
        ROLLBACK TRAN MSadd_subscription
        COMMIT TRAN
    end
    return(1)

GO

raiserror(15339,-1,-1,'sp_MSupdate_subscription')
GO
CREATE PROCEDURE sp_MSupdate_subscription
@publisher sysname,
@publisher_db sysname,
@subscriber sysname,
@article_id int,
@status int,
@subscription_seqno varbinary(16),
--post 6x
@destination_db sysname = '%'

as
    set nocount on
    declare @publisher_id smallint  
    declare @subscriber_id smallint
    declare @automatic tinyint
    declare @snapshot_seqno_flag bit
    declare @virtual smallint 
    declare @virtual_anonymous smallint 
    declare @retcode int
    declare @active tinyint
    declare @subscribed tinyint
    declare @agent_id int
    declare @sync_type tinyint
    declare @virtual_agent_id int
    declare @publication_id int

    select @automatic = 1
    select @virtual = - 1
    select @virtual_anonymous = - 2
    select @active = 2
    select @subscribed = 1

    -- Check if publisher is a defined as a distribution publisher in the current database
    exec @retcode = dbo.sp_MSvalidate_distpublisher @publisher, @publisher_id OUTPUT
    if @retcode <> 0
    begin
        return(1)
    end

    -- Check if subscriber exists
    if @subscriber is null
    begin
        select @subscriber_id = @virtual
        select @destination_db = '%'
    end
    else
        select @subscriber_id = srvid from master..sysservers, MSsubscriber_info where 
            UPPER(srvname) = UPPER(@subscriber) and
            UPPER(subscriber) = UPPER(@subscriber) and
            UPPER(publisher) = UPPER(@publisher)
    if @subscriber_id is NULL
    begin
        raiserror (20032, 16, -1, @subscriber, @publisher) 
        return (1)
    end

    begin tran
    save transaction MSupdate_subscription

    if @status = @active
    begin
        -- Activating the subscription
        /*
        **  It will be used by:
        **  1. no_sync subscriptions
        **  2. subscriptions on immediate_sync pub that are activate 
        **  using virtual subscritpions's snapshots.
        **  3. snapshot agents for 6.5 publishers
        */
        -- Get agent_id etc
        select @agent_id = agent_id, @sync_type = sync_type,
            @publication_id = publication_id
            from MSsubscriptions where
            publisher_id = @publisher_id and
            publisher_db = @publisher_db and
            article_id = @article_id and
            subscriber_id = @subscriber_id and 
            -- Use equal so 6.x publisher will get nothing (since @destination_db is '%')
            subscriber_db = @destination_db

        -- If immediate_sync publication and sync type is auto_sync
        -- Set the subscription_seqno and snapshot_seqno to be of the virtual subscription 
        -- for real subscription when activating the subscription.
        -- We have to do it for the whole publication to prevent the
        -- distribution agent from picking up partial snapshot transaction
        if  @subscriber IS NOT NULL AND
            @sync_type = @automatic and
            exists (select * from MSpublications p where
                -- publication_id is unique across dist db
                p.publication_id = @publication_id and
                p.immediate_sync = 1 
                )
        begin
            -- Get virtual agent_id
            select @virtual_agent_id = agent_id from MSsubscriptions where
                publisher_id = @publisher_id and
                publisher_db = @publisher_db and
                article_id = @article_id and
                subscriber_id = @virtual

            -- Note it is possible that the virtual subscriptions
            -- were deactivated during clean up.
            /* Update the subscription table for the whole publication */
			-- Note: You need to change sp_MSreset_subscription_seqno when you 
			-- change this query
            update MSsubscriptions  set 
                snapshot_seqno_flag =  
                    (select subscription_seqno from MSsubscriptions rs2
                        where
                        rs2.agent_id = @virtual_agent_id and
                        rs2.article_id = rs1.article_id),
                status =    
                    (select status from MSsubscriptions rs2
                        where
                        rs2.agent_id = @virtual_agent_id and
                        rs2.article_id = rs1.article_id),
                -- Use current date rather than virtual sub date for the
                -- calculation in cleanup 
                subscription_time = getdate(),
                subscription_seqno = 
                    (select subscription_seqno from MSsubscriptions rs2
                        where
                        rs2.agent_id = @virtual_agent_id and
                        rs2.article_id = rs1.article_id),
                publisher_seqno = 
                    (select publisher_seqno from MSsubscriptions rs2
                        where
                        rs2.agent_id = @virtual_agent_id and
                        rs2.article_id = rs1.article_id),
				ss_cplt_seqno = 
                    (select ss_cplt_seqno from MSsubscriptions rs2
                        where
                        rs2.agent_id = @virtual_agent_id and
                        rs2.article_id = rs1.article_id)
                from MSsubscriptions rs1 where
                    agent_id = @agent_id and
                    sync_type = @automatic and
                    status = @subscribed            
            if @@ERROR <> 0
                goto UNDO
        end
        else
        begin
            update MSsubscriptions set status = @status, subscription_time = getdate(), 
                publisher_seqno = @subscription_seqno, ss_cplt_seqno = @subscription_seqno,
                -- Have to do this. Refer to anonymous agent "no init sync" option logic above
                -- and sp_MSset_snapshot_seqno.
                snapshot_seqno_flag = 0 
                where
                  publisher_id = @publisher_id and
                  publisher_db = @publisher_db and
                  article_id = @article_id and
                  ((@subscriber_id <> @virtual and (subscriber_id = @subscriber_id and ((@destination_db = N'%') or (subscriber_db = @destination_db)) )) or
                  -- Activate virtual_anonymous but NOT virtual
                  -- This is for no init option for anonymous agent
                  -- Refer to sp_addsubscription , sp_MSget_repl_cmds_anonymous
                  -- and sp_MSset_snapshot_seqno
                  (@subscriber_id =  @virtual and subscriber_id = @virtual_anonymous))
            if @@error <> 0
                goto UNDO
        
            -- For 6.5 publishers.
            -- Snapshot agents of 6.5 publishers will call sp_changesubstatus which will
            -- RPC this stored procedure to activate the subscription. The RPC calls are
            -- not in one transaction.
            -- We have to do it for the whole publication to prevent the
            -- distribution agent from picking up partial snapshot transaction

            -- Get publication_id 
            -- The publication_id and sync type are set by SNAPSHOT agent 
            -- calling sp_MSset_snapshot_xact_seqno
            -- Don't do it if @subscriber_id is virtual to prevent virtual sub
            -- to be activated.
            if @destination_db = '%' and @subscriber_id <> @virtual
            begin
                declare @publication_id_6x int
                -- Get the publication_id.
                -- Note that if the sync_type is not automatic, the publication_id
                -- will be null. In this case, we will not do the later
                -- update (we don't need to)
                select top 1 @publication_id_6x = publication_id from MSsubscriptions 
                    where   publisher_id = @publisher_id and
                            publisher_db = @publisher_db and
                            subscriber_id = @subscriber_id and 
                            sync_type = @automatic and
                            article_id = @article_id

                if @publication_id_6x <> NULL
                begin
                    update MSsubscriptions set status = @status, subscription_time = getdate() 
                        where
                          publisher_id = @publisher_id and
                          publisher_db = @publisher_db and
                          subscriber_id = @subscriber_id and 
                          sync_type = @automatic and
                          publication_id = @publication_id_6x and
                          status <> @status
                    if @@error <> 0
                        goto UNDO
                end
            end
        end
    end -- End activating the subscription
    else
    begin -- Deactivating the subscription or change it from 'subscribed' to 'initiated'
        /*
        **  If @status is @active, it will be used by:
        **  sp_reinitsubscription at publisher to reset the subscription status to 'subscribed'
        **  If @status is @initiated (2), it will be used by snapshot agent with 
		**  sp_MSactivate_auto_sub => sp_changesubstatus.
		*/
        update MSsubscriptions set status = @status, 
								   publisher_seqno = @subscription_seqno, 
								   ss_cplt_seqno = @subscription_seqno
            where
            publisher_id = @publisher_id and
            publisher_db = @publisher_db and
            article_id = @article_id and
            ((@subscriber_id <> @virtual and (subscriber_id = @subscriber_id and ((@destination_db = N'%') or (subscriber_db = @destination_db)) )) or
            -- Deactivating both virtual and virtual anonymous
            (@subscriber_id =  @virtual and (subscriber_id = @virtual or (subscriber_id = @virtual_anonymous and
			-- When changing to @initiated, do not change activated virtual_anonymous_subscription.
			(@status = @subscribed or snapshot_seqno_flag = 0)))))

        if @@error <> 0
            goto UNDO
    end

    
    commit transaction
    return (0)

UNDO:
    if @@TRANCOUNT > 0
    begin
        ROLLBACK TRAN MSupdate_subscription
        COMMIT TRAN
    end
    return(1)
GO


declare @dbname sysname
select  @dbname = db_name()
execute('dump transaction ' +@dbname+ ' with no_log')

go

/*
**  Note: sp_MSget_repl_commands and sp_MSget_repl_count have very similar
**  queries. Any changes to one of them should be applied to all others.
*/

raiserror(15339,-1,-1,'sp_MSget_repl_commands')
GO
CREATE PROCEDURE sp_MSget_repl_commands
@agent_id int,
@last_xact_seqno varbinary(16),
@get_count bit = 0,
@compatibility_level int = 7000000
as

    set nocount on

    declare @active_status tinyint
    declare @initiate_status tinyint
    declare @snapshot_bit int
    declare @synctran_type int
    declare @read_only tinyint
    declare @retcode int
    declare @publisher_database_id int
    declare @originator_id int
    declare @subscriber sysname
    declare @subscriber_db sysname
    declare @subscriber_id smallint
    declare @publisher_db sysname
    declare @publisher_id smallint
    declare @max_xact_seqno varbinary(16)
    declare @concurrent int
    declare @concurrent_c int

    select @read_only = 0
    select @active_status = 2
    select @initiate_status = 3
    select @snapshot_bit = 0x80000000
    -- in sqlrepl.h
    select @synctran_type = @snapshot_bit | 9
    select @concurrent = 3
    select @concurrent_c = 4

    -- Security Check
    -- @agent_id might be null when it comes from sp_MSget_repl_cmd_anonymous
    if @agent_id is not null
    begin
        exec @retcode = dbo.sp_MScheck_pull_access
            @agent_id = @agent_id,
            @agent_type = 0 -- distribution agent
        if @@error <> 0 or @retcode <> 0
            return (1)
    end
    
    -- Get publisher database id etc.
    SELECT @publisher_database_id = publisher_database_id,
        @publisher_db = publisher_db,
        @publisher_id = publisher_id,
        @subscriber_id = subscriber_id, @subscriber_db = subscriber_db
        from MSdistribution_agents where id = @agent_id

    -- Get the last xact_seqno on the pub db FIRST. It will
    -- be used as the upper bound for differnt queries. We have to do
    -- this to prevent transactions on new or changed subscriptions or
    -- with new orignator_id being skipped eigher by preselected query or
    -- preselected originator_id.
    -- Have to have readpast here to prevent the query be blocked by logreader
    -- (even before the first row to the dist agent).
    --
    -- Note:  DO NOT consider distcmds inserted for a concurrent snapshot
    -- These represent 'forward in time' xacts.  Skipping past these xacts
    -- can cause lost transactions!
    --
    -- Note2: consider adding new MSrepl_commands idx with keys:  
    -- publisher_database_id, command_id, type, xact_seqno
    --
    -- Note3: might be able to use replpostcmd + a LSN mapping token to 
    -- allow SS agent to post sync cmds to log instead of dist db.
    --
    select @max_xact_seqno = max(xact_seqno) from MSrepl_commands (READPAST)
      where 
         publisher_database_id = @publisher_database_id and
         command_id = 1 and
         type <> -2147483611

    -- If there's nothing to do, return here to avoid more queries.
    if @max_xact_seqno = @last_xact_seqno
    begin
        if @get_count = 1
        begin
            select 
                'undelivered_commands' = convert(int, 0), 
                'undelivered_transactions' = convert(int, 0) 
        end
        else
        begin
            select rc.xact_seqno, rc.partial_command, rc.type, 
                rc.command_id, rc.command
                from                
                    MSrepl_commands rc
                where 0 = 1
            select @max_xact_seqno
        end
        return 0
    end

    -- Get subscriber name
    select @subscriber = srvname from master..sysservers where
        srvid = @subscriber_id
        
    -- Note: if no originator id in the table, it will be 0, so that no loop back
    -- detection will be done!.
    -- Since the logreader will insert into the MSrepl_originators table,
    -- this query has to be later then get max seqno query!!!!!
    --select @originator_id = 0
    select @originator_id = ISNULL(id, 0) from MSrepl_originators where
        publisher_database_id = @publisher_database_id and
        UPPER(srvname) = UPPER(@subscriber) and
        dbname = @subscriber_db

    if @get_count = 1
    begin
        select 
            'undelivered_commands' = count(*), 
            'undelivered_transactions' = count(distinct xact_seqno) from

        MSrepl_commands rc JOIN MSsubscriptions s
        ON (rc.article_id = s.article_id AND rc.publisher_database_id=s.publisher_database_id )
        
        where

        s.agent_id = @agent_id and
        s.status = @active_status and
        rc.publisher_database_id = @publisher_database_id and
        s.publisher_database_id = @publisher_database_id and
        rc.xact_seqno > @last_xact_seqno and
        rc.xact_seqno <= @max_xact_seqno and
        -- If log based transaction, we do
        -- 1. only select tran later than sub pub seqno
        -- 2. loopback detection
        (((rc.type & @snapshot_bit) <> @snapshot_bit and
        rc.xact_seqno > s.publisher_seqno and
        rc.xact_seqno > s.ss_cplt_seqno and
        --
        -- Loopback detection
        --
        (s.loopback_detection = 0 or
            (@originator_id != 0 and rc.originator_id <> @originator_id))) or 
        -- If snapshot transaction, we do
        -- 1. filter out the  snapshot transactions that were inserted later that is not
        -- the subscription's snapshot transaction
        -- 2. filter out trigger generation command for non synctran subscription.
        -- Note: don't do loop back detection.
        ((rc.type & @snapshot_bit) = @snapshot_bit and 
        rc.xact_seqno >= s.subscription_seqno and 
        rc.xact_seqno <= s.ss_cplt_seqno and
        (s.update_mode <> @read_only or rc.type <> @synctran_type))) and
        -- Filter out the new command types that we have introduced after 7.0
        (@compatibility_level > 7000000 or
        (rc.type & ~@snapshot_bit) not in 
        (25, 40, 45, 50, 51, 52, 53, 54, 55, 56 ,57, 58, 68, 69))
                
        return(0)
    end

    -- if this agent is servicing any inactive concurrent sync articles
    -- then return no rows.  The concurrent sync article will be activated
    -- when the SYNCDONE token is written to the distribution db by the logreader
    -- at this point, all log records associated with the sync will be present in 
    -- MSrepl_commands

    if exists( SELECT * FROM MSsubscriptions s JOIN MSpublications p 
               ON(  s.publisher_id = p.publisher_id and
                    s.publisher_db = p.publisher_db and
                    s.publication_id = p.publication_id )
               WHERE
                s.agent_id = @agent_id and
                s.status = @initiate_status and
                (p.sync_method = @concurrent or p.sync_method = @concurrent_c) )
    begin
        select rc.xact_seqno, rc.partial_command, rc.type, 
            rc.command_id, rc.command
            from                
                MSrepl_commands rc
            where 0 = 1
        select @last_xact_seqno
        return 0
    end

    -- Decide on a best query method.
    -- Note: The order of the following queries is important and
    -- not abitrary.
    
    -- Get subscription info
    declare @num_non_active int
    declare @num_article int
    declare @num_loopback int
    declare @max_sub_seqno varbinary(16)
    declare @max_pub_seqno varbinary(16)


    select 
        @num_non_active = sum(case when status <> @active_status then 1 else 0 end),
        @num_article = count(*),
        @num_loopback   = sum(case when loopback_detection <> 0 then 1 else 0 end),
        @max_sub_seqno  = max(subscription_seqno),
        @max_pub_seqno = max(publisher_seqno)
        from MSsubscriptions where
            agent_id = @agent_id

    --select @num_non_active, @num_loopback, @max_sub_seqno
    
    if  @last_xact_seqno < @max_sub_seqno or  
        @last_xact_seqno < @max_pub_seqno or 
        @num_non_active <> 0
    -- The agent is still working on snapshot transactions. Need a full join in this case
    begin

        -- Need a work table to remember the set of snapshot transaction 
        -- sequence numbers that need to be applied by this agent, this 
        -- table of subscription sequence numbers can then be used to make 
        -- sure that snapshot control (header/trailer) commands associated with 
        -- incremental snapshot commands are enumerated
        declare @snapshot_seqnos table (subscription_seqno varchar(16) primary key)
        insert into @snapshot_seqnos 
        select distinct subscription_seqno
          from MSsubscriptions
         where agent_id = @agent_id 
           and subscription_seqno > @last_xact_seqno
    
        -- no loopback    
        if @originator_id = 0
        begin
            -- Join with every thing but no loop back
            select rc.xact_seqno, rc.partial_command, rc.type, 
                rc.command_id, rc.command
                from                
                    MSrepl_commands rc JOIN MSsubscriptions s
                -- At end, we use the FASTFIRSTROW option which tends to force
                -- a nested inner loop join driven from MSrepl_commands
                ON (rc.article_id = s.article_id AND rc.publisher_database_id=s.publisher_database_id )
                
                where

                s.agent_id = @agent_id and
                s.status = @active_status and
                rc.publisher_database_id = @publisher_database_id and
                s.publisher_database_id = @publisher_database_id and
                rc.xact_seqno > @last_xact_seqno and
                rc.xact_seqno <= @max_xact_seqno and
                -- If log based transaction, we do
                -- 1. only select tran later than sub pub seqno
                -- 2. only select tran later than ss_cplt_seqno 
                (((rc.type & @snapshot_bit) <> @snapshot_bit and
                rc.xact_seqno > s.publisher_seqno and
                rc.xact_seqno > s.ss_cplt_seqno ) 
                or 
                -- If snapshot transaction, we do
                -- 1. filter out the  snapshot transactions that were inserted later that is not
                -- the subscription's snapshot transaction
                -- 2. filter out trigger generation command for non synctran subscription.
                -- Note: don't do loop back detection.
                ((rc.type & @snapshot_bit) = @snapshot_bit and 
                ((rc.xact_seqno >= s.subscription_seqno and 
                  rc.xact_seqno <= s.ss_cplt_seqno) or 
                 (rc.xact_seqno in (select subscription_seqno from @snapshot_seqnos) and (rc.type & ~@snapshot_bit) in (25, 50, 51, 52, 53, 54, 55, 56 ,57, 58))) and
                (s.update_mode <> @read_only or rc.type <> @synctran_type))) and
                -- Filter out the new command types that we have introduced after 7.0
                (@compatibility_level > 7000000 or
                (rc.type & ~@snapshot_bit) not in 
                (25, 40, 45, 50, 51, 52, 53, 54, 55, 56 ,57, 58, 68, 69))
                order by rc.xact_seqno, rc.command_id asc
                OPTION (FAST 1)
        end
        else
        begin
            -- Join with every thing with loop back
            select rc.xact_seqno, rc.partial_command, rc.type, 
                rc.command_id, rc.command
                from                
                    MSrepl_commands rc JOIN MSsubscriptions s
                -- At end, we use the FASTFIRSTROW option which tends to force
                -- a nested inner loop join driven from MSrepl_commands
                ON (rc.article_id = s.article_id AND rc.publisher_database_id=s.publisher_database_id )
                
                where

                s.agent_id = @agent_id and
                s.status = @active_status and
                rc.publisher_database_id = @publisher_database_id and
                s.publisher_database_id = @publisher_database_id and
                rc.xact_seqno > @last_xact_seqno and
                rc.xact_seqno <= @max_xact_seqno and
                -- If log based transaction, we do
                -- 1. only select tran later than sub pub seqno
                -- 2. loopback detection
                (((rc.type & @snapshot_bit) <> @snapshot_bit and
                rc.xact_seqno > s.publisher_seqno and
                rc.xact_seqno > s.ss_cplt_seqno and
                --
                -- Loopback detection
                --
                (s.loopback_detection = 0 or
                    rc.originator_id <> @originator_id)) or 
                -- If snapshot transaction, we do
                -- 1. filter out the  snapshot transactions that were inserted later that is not
                -- the subscription's snapshot transaction
                -- 2. filter out trigger generation command for non synctran subscription.
                -- Note: don't do loop back detection.
                ((rc.type & @snapshot_bit) = @snapshot_bit and 
                ((rc.xact_seqno >= s.subscription_seqno and 
                  rc.xact_seqno <= s.ss_cplt_seqno) or 
                 (rc.xact_seqno in (select subscription_seqno from @snapshot_seqnos) and (rc.type & ~@snapshot_bit) in (25, 50, 51, 52, 53, 54, 55, 56 ,57, 58))) and
                (s.update_mode <> @read_only or rc.type <> @synctran_type))) and
                -- Filter out the new command types that we have introduced after 7.0
                (@compatibility_level > 7000000 or
                (rc.type & ~@snapshot_bit) not in 
                (25, 40, 45, 50, 51, 52, 53, 54, 55, 56 ,57, 58, 68, 69))
                order by rc.xact_seqno, rc.command_id asc
                OPTION (FAST 1)
            end
    end
    -- The agent has finished snapshot transactions but it has loopback detection.
    else if @num_loopback <> 0 and @originator_id <> 0
    begin
        -- Join plus loopback
        select rc.xact_seqno, rc.partial_command, rc.type, 
            rc.command_id, rc.command
            from                
                MSrepl_commands rc JOIN MSsubscriptions s
            -- At end, we use the FASTFIRSTROW option which tends to force
            -- a nested inner loop join driven from MSrepl_commands
            ON (rc.article_id = s.article_id)
            
            where

            s.agent_id = @agent_id and
            rc.publisher_database_id = @publisher_database_id and
            rc.xact_seqno > @last_xact_seqno and
            rc.xact_seqno <= @max_xact_seqno and
            (rc.type & @snapshot_bit) <> @snapshot_bit and
            (rc.type & ~@snapshot_bit) not in ( 37, 38 ) and
            --
            -- Loopback detection
            --
            (s.loopback_detection = 0 or
            rc.originator_id <> @originator_id) 
            order by rc.xact_seqno, rc.command_id asc
            OPTION (FAST 1)
    end
    -- The agent has finished snapshot transactions. It has NO loopback detection.
    else if @num_article <> (select count(*) from MSarticles  a where
        publisher_id = @publisher_id and
        publisher_db = @publisher_db)
    -- Not a full subscription, do mini join
    begin
        -- Mini join along. Only agent_id and article_id columns in MSsubscriptions
        -- are used. So only index pages are needed for the join.
        select rc.xact_seqno, rc.partial_command, rc.type, 
        rc.command_id, rc.command
        from                
            MSrepl_commands rc JOIN MSsubscriptions s
        -- At end, we use the FASTFIRSTROW option which tends to force
        -- a nested inner loop join driven from MSrepl_commands
        ON (rc.article_id = s.article_id)
        where
        s.agent_id = @agent_id and
        rc.publisher_database_id = @publisher_database_id and
        rc.xact_seqno > @last_xact_seqno and
        rc.xact_seqno <= @max_xact_seqno and
        (rc.type & @snapshot_bit) <> @snapshot_bit and
        (rc.type & ~@snapshot_bit) not in ( 37, 38 ) 
        order by rc.xact_seqno, rc.command_id asc
        OPTION (FAST 1)
    end
    else
    -- The query will fly if we reach here!! No join is needed.
    -- It is a full sub to pub db, the dist agent is beyond snapshots, 
    -- all sub are active and no loopback detection. 
    begin
        -- no join.
        select rc.xact_seqno, rc.partial_command, rc.type, 
        rc.command_id, rc.command
        from                
            MSrepl_commands rc 
        where
        rc.publisher_database_id = @publisher_database_id and
        rc.xact_seqno > @last_xact_seqno and
        rc.xact_seqno <= @max_xact_seqno and
        (rc.type & @snapshot_bit) <> @snapshot_bit and
        (rc.type & ~@snapshot_bit) not in ( 37, 38 ) 
        order by rc.xact_seqno, rc.command_id asc
    end 

    -- Return the max seqno of this batch to distribution agent.
    select @max_xact_seqno

GO



raiserror(15339,-1,-1,'sp_MSget_repl_cmds_anonymous')
GO
CREATE PROCEDURE sp_MSget_repl_cmds_anonymous
@agent_id int,
@last_xact_seqno varbinary(16),
@no_init_sync bit = 0,
@get_count bit = 0,
@compatibility_level int = 7000000

as

   set nocount on

   declare @virtual_agent_id int    /* virtual sub agent id */
   declare @anonymous_agent_id int  /* virtual anonymous agent id */

    -- Note @agent_id will be overwritten later.
    select  @virtual_agent_id =   virtual_agent_id,
            @anonymous_agent_id = anonymous_agent_id
        from MSdistribution_agents where
            id = @agent_id
    
    -- Return error if agent entry does not exists (being deleted).
    if @virtual_agent_id is null
    begin
        raiserror(21072, 16, -1)
        return(1)
    end

    -- If no init sync, use anonymous account to start immediately.
    -- If first time or right after reinit,  use virtual account. 
    -- otherwise use virtual anonymous account
    if  @no_init_sync = 1 
        select @agent_id = @anonymous_agent_id
    else if @last_xact_seqno = 0x00 
        select @agent_id = @virtual_agent_id
    else
        select @agent_id = @anonymous_agent_id
    -- Call main procedure to get commands
    exec dbo.sp_MSget_repl_commands 
        @agent_id = @agent_id,
        @last_xact_seqno = @last_xact_seqno,
        @get_count = @get_count,
        @compatibility_level = @compatibility_level
GO



raiserror(15339,-1,-1,'sp_MSanonymous_status')
GO
CREATE PROCEDURE sp_MSanonymous_status
@agent_id           int,
@no_init_sync       int = 0,
@last_xact_seqno varbinary(16)
as

   set nocount on

   declare @virtual_agent_id int    /* virtual sub agent id */
   declare @anonymous_agent_id int  /* virtual anonymous agent id */

    -- Note @agent_id will be overwritten later.
    select  @virtual_agent_id =   virtual_agent_id,
            @anonymous_agent_id = anonymous_agent_id
        from MSdistribution_agents where
            id = @agent_id
    
    -- Return error if agent entry does not exists (being deleted).
    if @virtual_agent_id is null
    begin
        raiserror(21072, 16, -1)
        return(1)
    end

    -- If no init sync, use anonymous account to start immediately.
    -- If first time, or still working on the first snapshot, or just finished
    -- the first snapshot, use virtual account. This is to cover the case
    -- of multiple snapshot transactions (for example, one per article) in the first
    -- snapshot.
    -- otherwise use virtual anonymous account
    if  @no_init_sync = 1 
        select @agent_id = @anonymous_agent_id
    else if @last_xact_seqno = 0x00 
        select @agent_id = @virtual_agent_id
    else
        select @agent_id = @anonymous_agent_id
    
    -- Call main procedure to get status
    exec dbo.sp_MSsubscription_status
        @agent_id = @agent_id
GO

raiserror(15339,-1,-1,'sp_MSadd_anonymous_agent')
GO
CREATE PROCEDURE sp_MSadd_anonymous_agent
@publisher_id       smallint,
@publisher_db       sysname,
@publication        sysname,
@subscriber_db      sysname,
@subscriber_name    sysname,
@anonymous_subid    uniqueidentifier output,
@agent_id           int output,
@reinitanon         bit = 0

as

/*
** This stored procedure does not really add a job at distribution database;
** if add a row in MSdistribution_agent table for anonymous subscription for the 
** purpose of history logging
*/

   set nocount on
   declare @distribution_type smallint
   declare @profile_id int
   declare @subscriber_id smallint
   declare @retcode int
   declare @publication_id int
   declare @virtual_agent_id int
   declare @anonymous_agent_id int
   declare @virtual smallint
   declare @virtual_anonymous smallint
   declare @new_agent_id int
   declare @anonymous int
   declare @publisher_database_id int
   declare @allow_anonymous bit
   declare @publication_type int
   declare @merge_publication_type int
   
   select @publication_type = NULL
   select @merge_publication_type = 2
   
   select @virtual = -1
   select @virtual_anonymous = -2
   select @anonymous = 2
   
    -- Check to see if the publication is valid and allow anonymous
    select @publication_id = publication_id, @allow_anonymous = allow_anonymous, @publication_type = publication_type
		from MSpublications where
        publisher_id = @publisher_id and
        publisher_db = @publisher_db and
        publication = @publication 

    if @publication_id is null
    begin
        RAISERROR (21040, 16, -1, @publication)
        return 1
    end

	if @publication_type = @merge_publication_type
	begin
		RAISERROR(21132, 16, -1, @publication)
		return 1
	end

    if @allow_anonymous = 0
    begin
        RAISERROR (21084, 16, -1, @publication)
        return 1   	
    end

	if @subscriber_name is null
		select @subscriber_name = N''

    -- Get virtual ids
    select top 1 @virtual_agent_id = agent_id, 
        @publisher_database_id = publisher_database_id from MSsubscriptions where
        publisher_id = @publisher_id and
        publisher_db = @publisher_db and
        publication_id = @publication_id and
        subscriber_id = @virtual

    select top 1 @anonymous_agent_id = agent_id from MSsubscriptions where
        publisher_id = @publisher_id and
        publisher_db = @publisher_db and
        publication_id = @publication_id and
        subscriber_id = @virtual_anonymous


    -- Security check
    exec @retcode = dbo.sp_MScheck_pull_access
        @agent_id =  @anonymous_agent_id,
        @agent_type = 0 -- distribution agent   
    if @retcode <> 0 or @@error <> 0
        return (1)

    /*
    **  To return two more parameters for the purpose of anonymous monitoring
    ** 
    ** If @anonymous_subid is null, this is a new anonymous subscription; A new row would be inserted in MSdistribution_agents.
    ** And its id (identity) and newly generated ID will be returned; The new ID would be used in subscriber side.
    */
    select @subscriber_id = 0   -- for anonymous subscribers, ID is always 0

    select @agent_id = id from MSdistribution_agents 
        where anonymous_subid = @anonymous_subid
        
    
    IF @agent_id is null
        BEGIN
            if @anonymous_subid is not NULL and @anonymous_subid <> 0x00
               and @reinitanon = 0
            begin
                -- Agent has be cleaned up, return error.
                raiserror(21072, 16, -1)
                return(1)
            end
            -- Generate a new subid only when the subscription is not 
            -- reinitialized
            if @reinitanon = 0
            begin
                select @anonymous_subid = newid()
            end
            SELECT @distribution_type = 3

            SELECT @profile_id = profile_id
            FROM msdb..MSagent_profiles
            WHERE agent_type = @distribution_type
                AND def_profile = 1

            IF @profile_id IS NULL
            RETURN (1)

            INSERT into MSdistribution_agents (name, publisher_database_id, publisher_id, publisher_db, publication, 
                        subscriber_id, subscriber_db, subscription_type, local_job, job_id, subscription_guid, profile_id, anonymous_subid, 
                        subscriber_name, virtual_agent_id, anonymous_agent_id)
                        
                 VALUES (convert(nvarchar(40), @anonymous_subid), @publisher_database_id, @publisher_id, @publisher_db, @publication, 
                            @subscriber_id, @subscriber_db, @anonymous, 0, @anonymous_subid,
                            @anonymous_subid, @profile_id, @anonymous_subid, @subscriber_name,
                            @virtual_agent_id, @anonymous_agent_id)
            select @agent_id = @@identity
        END
        
GO


raiserror(15339,-1,-1,'sp_MSsubscription_status')
GO
CREATE PROCEDURE sp_MSsubscription_status
@agent_id int
as

    set nocount on

	declare @retcode tinyint
    declare @status tinyint
    declare @inactive tinyint
    declare @active tinyint
    declare @subscribed tinyint
    declare @initiated tinyint
    declare @article_id int
    declare @publication sysname
    declare @article sysname
    declare @msg nvarchar(255)
    declare @automatic tinyint
    declare @none tinyint
	declare @success int
	declare @retention int
	declare @last_sync datetime
	declare @publication_id int

	select @success = 2
    select @inactive = 0
    select @subscribed = 1
    select @active = 2
    select @initiated = 3
    select @automatic = 1
	select @none = 2

	-- Security Check
	exec @retcode = dbo.sp_MScheck_pull_access @agent_id = @agent_id,	-- agent id
										        @agent_type = 0 		-- only called by distribution agent
    if @@error <> 0 or @retcode <> 0
    begin
        return (1)
    end
        
    -- If one article is inactive, and no_sync subscription fail.
    if exists (select * from MSsubscriptions where
        status = @inactive and
        sync_type = @none and
        agent_id = @agent_id)
    begin
        -- The subscription was deactivated.
        raiserror(21074, 16,-1)
        return(1)
    end
	
	-- If one article is inactive, fail.
    if exists (select * from MSsubscriptions where
        status = @inactive and
        sync_type = @automatic and
        agent_id = @agent_id)
    begin
        -- The subscription was deactivated.
        raiserror(21074, 16,-1)
        return(1)
    end

    select top 1 @article_id = article_id,
		@publication_id = publication_id
	    from MSsubscriptions where
        agent_id = @agent_id and
        sync_type = @automatic and
        status = @subscribed

    if @publication_id is not null
    begin
		-- Get the publication name to use later in the formated message
		select @publication = publication from MSpublications where
			publication_id = @publication_id

        -- If there's more than one article in subscribed state
        -- Send a general waiting message.
        -- Otherwise, indicate the article name
        if exists (select * from MSsubscriptions where
            agent_id = @agent_id and
            status = @subscribed and
            sync_type = @automatic and
            article_id <> @article_id)
        begin
			-- Snapshot not available message
			if @publication is not null
	            select @msg = formatmessage(21075, @publication)
			else -- It is null for 6.5
	            select @msg = formatmessage(21088)
        end
        else
        begin
            -- article_id is unique across pub db for tran
			-- but merge article may use the same id
            select @article = article from MSarticles where
                article_id = @article_id and
				publication_id = @publication_id
            -- It is null for 6.5
            if @article is not null
                select @msg = formatmessage(21076, @article)
            else
			begin
				-- Snapshot not available message
				if @publication is not null
					select @msg = formatmessage(21075, @publication)
				else -- It is null for 6.5
					select @msg = formatmessage(21088)
			end
        end

        -- If one article is active, the status is active
        if exists ( select * from MSsubscriptions where
            agent_id = @agent_id and
            sync_type = @automatic and
            status = @active)
            set @status = @active
        else
            set @status = @subscribed
    end
	else
	-- For concurrent snapshot, logreader has to run first.
	begin
 		select top 1 @publication_id = publication_id, @status = status from MSsubscriptions s where
        		s.status = @initiated and
		        s.agent_id = @agent_id and
        		s.sync_type = @automatic

		if @publication_id is not null
		begin
			select @publication = publication from MSpublications where
				publication_id = @publication_id
			select @msg = formatmessage(21388, @publication)
		end
	end

    -- If nothing returned, all articles are active.
    select 'msg' = @msg, 'status' = @status 
        where @msg is not null

GO




raiserror(15339,-1,-1,'sp_MSget_last_transaction')
GO
CREATE PROCEDURE sp_MSget_last_transaction
@publisher_id int = NULL,
@publisher_db sysname,
@publisher sysname = NULL,
@max_xact_seqno varbinary(16) = NULL output
,@for_truncate bit = 0

AS
	declare @publisher_database_id int
	declare @max_xact_id varbinary(16)
	declare @sync_bit int
	declare @sync_with_backup bit
	
	set nocount on 
    
	SELECT @sync_bit = 32

	if @publisher_id is NULL
		select @publisher_id = srvid from master..sysservers where
			UPPER(srvname) = UPPER(@publisher)

	-- Get publisher database id.
	SELECT @publisher_database_id = id from MSpublisher_databases where publisher_id = @publisher_id and 
		publisher_db = @publisher_db
    
	if exists ( select * from master.dbo.sysdatabases where 
			name = db_name() and
			category & @sync_bit = 0) 
		select @sync_with_backup = 0
	else
		select @sync_with_backup = 1



	if @for_truncate = 0
	begin
		select top 1 @max_xact_id = rt.xact_id, @max_xact_seqno = rt.xact_seqno
		  from
		  MSrepl_transactions rt
		  where 
			 rt.publisher_database_id = @publisher_database_id and
			 not xact_id = 0x0
			 order by xact_seqno desc
	end
	-- If (1) requesting truncate lsn (distbackuplsn), (2) sync with backup is set
	-- query the values from MSrepl_backup_lsn
	else if	@sync_with_backup = 1
	begin
		-- Get the last backed up lsn if available.
		select top 1 @max_xact_id = valid_xact_id, @max_xact_seqno = valid_xact_seqno
		  from
		  MSrepl_backup_lsns 
		  where 
			 publisher_database_id = @publisher_database_id 
	end
	
	-- If @publisher is not null, we are calling this sp from sp_replrestart
	-- Don't return result set.
	if @publisher is null
		select @max_xact_id, @max_xact_seqno 
			-- Don't return any result when requsting a truncate lsn and
			-- the database is not in 'sync with backup' mode, which signal the 
			-- distribution agent to use last dist lsn to call sp_repldone.
			where not (@sync_with_backup = 0 and @for_truncate = 1)
  
GO

raiserror(15339,-1,-1,'sp_MSadd_subscriber_info')
GO
CREATE PROCEDURE sp_MSadd_subscriber_info
@publisher sysname,
@subscriber sysname,
@type tinyint = 0,
@login sysname = 'sa',
@password nvarchar(524) = NULL,
@commit_batch_size int = 100,
@status_batch_size int = 100,
@flush_frequency int = 0,
@frequency_type int = 4,
@frequency_interval int = 1,
@frequency_relative_interval int = 1,
@frequency_recurrence_factor int = 0,
@frequency_subday int = 4,
@frequency_subday_interval int = 5,
@active_start_time_of_day int = 0,
@active_end_time_of_day int = 235959,
@active_start_date int = 0,
@active_end_date int = 99991231,
@retryattempts int = 0,    
@retrydelay int = 0,
@description nvarchar (255) = NULL,
@security_mode int = 1, /* 0 standard; 1 integrated */
@encrypted_password bit = 0

AS
   set nocount on

   declare @retcode int
   declare @oledbprovider nvarchar(256)
   declare @platform_nt binary

   select @platform_nt = 0x1

    IF (UPPER(@subscriber) = UPPER(@@SERVERNAME) and ( @platform_nt != platform() & @platform_nt ) and @security_mode = 1)
        BEGIN
            RAISERROR(21038, 16, -1)
            RETURN (1)
        END

/* Add the subscriber to sysservers as a RPC server, if it does not
   ** already exist.
   */
   if not exists (select * from  master..sysservers where  UPPER(srvname) = UPPER(@subscriber))
      begin
          exec @retcode = dbo.sp_addserver @subscriber
          if @retcode <> 0
             return 1
      end
   
    -- Encrypt the password
    IF @encrypted_password = 0
    BEGIN
        EXEC @retcode = master.dbo.xp_repl_encrypt @password OUTPUT
        IF @@error <> 0 OR @retcode <> 0
            return 1
    END

    if (@type = 3)
    begin
        select @oledbprovider = providername from master..sysservers where UPPER(srvname) = UPPER(@subscriber)
        if (@oledbprovider = 'sqloledb')
            select @security_mode = 1
        else
            select @security_mode = 0
    end

   /* Delete any existing row */
   delete from MSsubscriber_info where UPPER(publisher) = UPPER(@publisher) and UPPER(subscriber) = UPPER(@subscriber)
   if @@error <> 0
     return 1
   delete from MSsubscriber_schedule where UPPER(publisher) = UPPER(@publisher) and UPPER(subscriber) = UPPER(@subscriber)
   if @@error <> 0
     return 1

   begin tran
   save TRAN addsub_info
 
   insert MSsubscriber_info (publisher, subscriber, type, login, password, description, security_mode)
         values (@publisher, @subscriber, @type, @login, @password, @description, @security_mode)
    if @@error <> 0
    goto UNDO

    /*
    ** Schedule information is added for backward compartibility reason, agent_type = 0
    */
   insert MSsubscriber_schedule values(@publisher, @subscriber, 0, @frequency_type,
                                        @frequency_interval,
                                        @frequency_relative_interval,
                                        @frequency_recurrence_factor ,
                                        @frequency_subday ,
                                        @frequency_subday_interval,
                                        @active_start_time_of_day,
                                        @active_end_time_of_day ,
                                        @active_start_date ,
                                        @active_end_date )
    if @@error <> 0
    goto UNDO
    COMMIT TRAN

    Return (0)
UNDO:
    if @@TRANCOUNT > 0
    begin
        ROLLBACK TRAN addsub_info
        COMMIT TRAN
    end
    return (1)
GO

raiserror(15339,-1,-1,'sp_MSadd_subscriber_schedule')
GO
CREATE PROCEDURE sp_MSadd_subscriber_schedule
@publisher sysname,
@subscriber sysname,
@agent_type smallint = 0,   -- 0 for distribution agent, 1 for merge agent
@frequency_type int = 4,
@frequency_interval int = 1,
@frequency_relative_interval int = 1,
@frequency_recurrence_factor int = 0,
@frequency_subday int = 4,
@frequency_subday_interval int = 5,
@active_start_time_of_day int = 0,
@active_end_time_of_day int = 235959,
@active_start_date int = 0,
@active_end_date int = 99991231

AS
   set nocount on

   declare @retcode int

   /* Add the subscriber to sysservers as a RPC server, if it does not
   ** already exist.
   */
   if not exists (select * from  master..sysservers where  UPPER(srvname) = UPPER(@subscriber))
      begin
          exec @retcode = dbo.sp_addserver @subscriber
          if @retcode <> 0
             return 1
      end

   /* Delete any existing row */
   if exists (select * from MSsubscriber_schedule where
       UPPER(publisher) = UPPER(@publisher) and UPPER(subscriber) = UPPER(@subscriber) and agent_type=@agent_type)
       begin
           delete from MSsubscriber_schedule 
           where UPPER(publisher) = UPPER(@publisher) and UPPER(subscriber) = UPPER(@subscriber) and agent_type=@agent_type
          if @@error <> 0
             return 1
       end
 
   insert MSsubscriber_schedule (publisher, subscriber, agent_type, 
      frequency_type, frequency_interval, frequency_relative_interval,
      frequency_recurrence_factor, frequency_subday, frequency_subday_interval,
      active_start_time_of_day, active_end_time_of_day, active_start_date,
      active_end_date)
      
      values (@publisher, @subscriber, @agent_type, 
      @frequency_type, @frequency_interval, @frequency_relative_interval,
      @frequency_recurrence_factor, @frequency_subday, @frequency_subday_interval,
      @active_start_time_of_day, @active_end_time_of_day, @active_start_date,
      @active_end_date)
   if @@error <> 0
      return 1
GO



raiserror(15339,-1,-1,'sp_MSupdate_subscriber_info')
GO
CREATE PROCEDURE sp_MSupdate_subscriber_info
@publisher sysname,
@subscriber sysname,
@type tinyint = NULL,
@login sysname = NULL,
@password nvarchar(524) = '%',
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
@retryattempts int = NULL,
@retrydelay int = NULL,
@description nvarchar (255) = NULL,
@security_mode int = NULL

AS
   set nocount on
   
   declare @cmd1 nvarchar (255)
   declare @retcode int
   declare @platform_nt binary

   select @platform_nt = 0x1

   IF (UPPER(@subscriber) = UPPER(@@SERVERNAME) and ( @platform_nt != platform() & @platform_nt ) and @security_mode = 1)
        BEGIN
            RAISERROR(21038, 16, -1)
            RETURN (1)
        END


   begin transaction
   save transaction update_subscriber
   
   /* Check if subscriber exists */
   if not exists (select * from MSsubscriber_info 
                  where UPPER(publisher) = UPPER(@publisher) and UPPER(subscriber) = UPPER(@subscriber))
       goto FAILED

   if not exists (select * from MSsubscriber_schedule 
                  where UPPER(publisher) = UPPER(@publisher) and UPPER(subscriber) = UPPER(@subscriber) and agent_type = 0)
       goto FAILED    
   
   if @type is not NULL
      update MSsubscriber_info set type = @type 
        where UPPER(publisher) = UPPER(@publisher) and UPPER(subscriber) = UPPER(@subscriber)
      if @@error <> 0
         goto FAILED
   
   if @security_mode is not NULL
      update MSsubscriber_info set security_mode = @security_mode 
        where UPPER(publisher) = UPPER(@publisher) and UPPER(subscriber) = UPPER(@subscriber)
      if @@error <> 0
         goto FAILED
  
   if @login is not NULL
      update MSsubscriber_info set login = @login 
        where UPPER(publisher) = UPPER(@publisher) and UPPER(subscriber) = UPPER(@subscriber)
      if @@error <> 0
         goto FAILED
   
   if @password <> '%'
   begin
        -- Encrypt the password
        EXEC @retcode = master.dbo.xp_repl_encrypt @password OUTPUT
        IF @@error <> 0 OR @retcode <> 0
            goto FAILED
        update MSsubscriber_info set password = @password 
            where UPPER(publisher) = UPPER(@publisher) and UPPER(subscriber) = UPPER(@subscriber)
        if @@error <> 0
            goto FAILED
   end
 
   
   if @frequency_type is not NULL
      update MSsubscriber_schedule set frequency_type = @frequency_type 
        where  UPPER(publisher) = UPPER(@publisher) and UPPER(subscriber) = UPPER(@subscriber) and agent_type = 0
      if @@error <> 0
         goto FAILED
   
   if @frequency_interval is not NULL
      update MSsubscriber_schedule set frequency_interval = @frequency_interval 
        where UPPER(publisher) = UPPER(@publisher) and UPPER(subscriber) = UPPER(@subscriber) and agent_type = 0
      if @@error <> 0
         goto FAILED
   
   if @frequency_relative_interval is not NULL
      update MSsubscriber_schedule set frequency_relative_interval = @frequency_relative_interval 
      where UPPER(publisher) = UPPER(@publisher) and UPPER(subscriber) = UPPER(@subscriber) and agent_type = 0
       if @@error <> 0
         goto FAILED
   
   if @frequency_recurrence_factor is not NULL
      update MSsubscriber_schedule set frequency_recurrence_factor = @frequency_recurrence_factor 
        where UPPER(publisher) = UPPER(@publisher) and UPPER(subscriber) = UPPER(@subscriber) and agent_type = 0
      if @@error <> 0
         goto FAILED
   
   if @frequency_subday is not NULL
      update MSsubscriber_schedule set frequency_subday = @frequency_subday 
        where UPPER(publisher) = UPPER(@publisher) and UPPER(subscriber) = UPPER(@subscriber) and agent_type = 0
      if @@error <> 0
         goto FAILED
   
   if @frequency_subday_interval is not NULL
      update MSsubscriber_schedule set frequency_subday_interval = @frequency_subday_interval 
        where UPPER(publisher) = UPPER(@publisher) and UPPER(subscriber) = UPPER(@subscriber) and agent_type = 0
      if @@error <> 0
         goto FAILED
   
   if @active_start_time_of_day is not NULL
      update MSsubscriber_schedule set active_start_time_of_day = @active_start_time_of_day 
        where UPPER(publisher) = UPPER(@publisher) and UPPER(subscriber) = UPPER(@subscriber) and agent_type = 0
      if @@error <> 0
         goto FAILED
   
   if @active_end_time_of_day is not NULL
      update MSsubscriber_schedule set active_end_time_of_day = @active_end_time_of_day 
        where UPPER(publisher) = UPPER(@publisher) and UPPER(subscriber) = UPPER(@subscriber) and agent_type = 0
      if @@error <> 0
         goto FAILED
   
   if @active_start_date is not NULL
      update MSsubscriber_schedule set active_start_date = @active_start_date 
        where UPPER(publisher) = UPPER(@publisher) and UPPER(subscriber) = UPPER(@subscriber) and agent_type = 0
      if @@error <> 0
         goto FAILED
   
   if @active_end_date is not NULL
      update MSsubscriber_schedule set active_end_date = @active_end_date 
      where UPPER(publisher) = UPPER(@publisher) and UPPER(subscriber) = UPPER(@subscriber) and agent_type = 0
      if @@error <> 0
         goto FAILED
   
   if @description is not NULL
      update MSsubscriber_info set description = @description 
        where UPPER(publisher) = UPPER(@publisher) and UPPER(subscriber) = UPPER(@subscriber)
      if @@error <> 0
         goto FAILED

    if @security_mode is not NULL
      update MSsubscriber_info set security_mode = @security_mode 
        where UPPER(publisher) = UPPER(@publisher) and UPPER(subscriber) = UPPER(@subscriber)
      if @@error <> 0
         goto FAILED

   commit transaction
   return (0)
   
FAILED:
    if @@trancount > 0
    begin
        rollback transaction update_subscriber
        commit tran -- to finish off the tran we started in this proc (though 
                    -- work was rolled back to savepoint)
    end
   return (1)
GO

raiserror(15339,-1,-1,'sp_MScheck_Jet_Subscriber')
GO
CREATE PROCEDURE sp_MScheck_Jet_Subscriber
@subscriber				sysname,
@is_jet					int OUTPUT,
@Jet_datasource_path	sysname OUTPUT
AS

select @is_jet = 0
IF EXISTS (select * from master..sysservers where UPPER(srvname) = UPPER(@subscriber)
                and upper(providername) = 'MICROSOFT.JET.OLEDB.4.0')
begin
	select @is_jet = 1
	select @Jet_datasource_path = datasource from master..sysservers where UPPER(srvname) = UPPER(@subscriber)
end
return (0)
GO

/*
** this procedure is to check if merge agent is has expired based on retention
** period. Note that if it does, a reinitialization would make it work.
*/
raiserror(15339,-1,-1,'sp_MScheckretention')
GO
CREATE PROCEDURE sp_MScheckretention
@agent_id				int,
@schemachangever		int
AS
declare 	@publisher_id			int
declare 	@publisher_db		sysname
declare 	@publication		sysname
declare		@expired			int
declare		@min_valid_day		datetime
declare		@retention			int
declare 	@success			int

select @expired  = 0
select @success = 2

select @publisher_id=publisher_id, @publisher_db=publisher_db, @publication=publication 
from MSmerge_agents 
where id = @agent_id

select @retention = retention 
from MSpublications 
where publisher_id=@publisher_id and publisher_db=@publisher_db and publication=@publication 

if @retention is not NULL and @retention > 0 and @schemachangever >0
begin
	select @min_valid_day = dateadd(day, @retention * (-1), getdate()) 
	if exists (select * from MSmerge_history where agent_id=@agent_id) 
			and not exists (select * from MSmerge_history where agent_id=@agent_id and time > @min_valid_day)
		select @expired = 1
end
select @expired 
GO

raiserror(15339,-1,-1,'sp_MSupdate_subscriber_schedule')
GO
CREATE PROCEDURE sp_MSupdate_subscriber_schedule
@publisher sysname,
@subscriber sysname,
@agent_type tinyint = NULL,
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

AS
   set nocount on
   
   declare @cmd1 nvarchar (255)
   declare @retcode int
   

   begin transaction
   save transaction update_subscriber_schedule
   
   /* Check if subscriber exists */
   if not exists (select * from MSsubscriber_info 
            where UPPER(publisher) = UPPER(@publisher) and UPPER(subscriber) = UPPER(@subscriber))
       goto FAILED
       
    if not exists (select * from MSsubscriber_schedule 
        where UPPER(publisher) = UPPER(@publisher) and UPPER(subscriber) = UPPER(@subscriber) and agent_type = @agent_type)
       goto FAILED
    
   
   if @frequency_type is not NULL
      update MSsubscriber_schedule set frequency_type = @frequency_type 
      where UPPER(publisher) = UPPER(@publisher) and UPPER(subscriber) = UPPER(@subscriber) and agent_type = @agent_type
      if @@error <> 0
         goto FAILED
   
   if @frequency_interval is not NULL
      update MSsubscriber_schedule set frequency_interval = @frequency_interval 
      where UPPER(publisher) = UPPER(@publisher) and UPPER(subscriber) = UPPER(@subscriber) and agent_type = @agent_type
      if @@error <> 0
         goto FAILED
   
   if @frequency_relative_interval is not NULL
      update MSsubscriber_schedule set frequency_relative_interval = @frequency_relative_interval 
      where UPPER(publisher) = UPPER(@publisher) and UPPER(subscriber) = UPPER(@subscriber) and agent_type = @agent_type
      if @@error <> 0
         goto FAILED
   
   if @frequency_recurrence_factor is not NULL
      update MSsubscriber_schedule set frequency_recurrence_factor = @frequency_recurrence_factor 
      where UPPER(publisher) = UPPER(@publisher) and UPPER(subscriber) = UPPER(@subscriber) and agent_type = @agent_type
       if @@error <> 0
         goto FAILED
   
   if @frequency_subday is not NULL
      update MSsubscriber_schedule set frequency_subday = @frequency_subday 
      where UPPER(publisher) = UPPER(@publisher) and UPPER(subscriber) = UPPER(@subscriber) and agent_type = @agent_type
      if @@error <> 0
         goto FAILED
   
   if @frequency_subday_interval is not NULL
      update MSsubscriber_schedule set frequency_subday_interval = @frequency_subday_interval 
      where UPPER(publisher) = UPPER(@publisher) and UPPER(subscriber) = UPPER(@subscriber) and agent_type = @agent_type
      if @@error <> 0
         goto FAILED
   
   if @active_start_time_of_day is not NULL
      update MSsubscriber_schedule set active_start_time_of_day = @active_start_time_of_day 
      where UPPER(publisher) = UPPER(@publisher) and UPPER(subscriber) = UPPER(@subscriber) and agent_type = @agent_type
      if @@error <> 0
         goto FAILED
   
   if @active_end_time_of_day is not NULL
      update MSsubscriber_schedule set active_end_time_of_day = @active_end_time_of_day 
      where UPPER(publisher) = UPPER(@publisher) and UPPER(subscriber) = UPPER(@subscriber) and agent_type = @agent_type
      if @@error <> 0
         goto FAILED
   
   if @active_start_date is not NULL
      update MSsubscriber_schedule set active_start_date = @active_start_date 
      where UPPER(publisher) = UPPER(@publisher) and UPPER(subscriber) = UPPER(@subscriber) and agent_type = @agent_type
      if @@error <> 0
         goto FAILED
   
   if @active_end_date is not NULL
      update MSsubscriber_schedule set active_end_date = @active_end_date 
      where UPPER(publisher) = UPPER(@publisher) and UPPER(subscriber) = UPPER(@subscriber) and agent_type = @agent_type
      if @@error <> 0
         goto FAILED

   commit transaction
   return (0)
   
FAILED:
    if @@trancount > 0
    begin
        rollback transaction update_subscriber_schedule
        commit transaction      -- to finish off the tran we started in this proc (though 
                                -- work was rolled back to savepoint)
    end
   return (1)
GO


raiserror(15339,-1,-1,'sp_MSdrop_subscriber_info')
GO
CREATE PROCEDURE sp_MSdrop_subscriber_info
@publisher sysname,
@subscriber sysname

AS
    set nocount on

    declare @srvid smallint
    declare @publisher_id smallint
    declare @publisher_db sysname
  
    if exists (select * from MSsubscriber_info where
        UPPER(subscriber) = UPPER(@subscriber))
    begin

        select @srvid = srvid from master..sysservers where lower(srvname) = lower(@subscriber)

        -- For SQL server publishers, drop the existing subscriptions.
        -- This has to be done for 65 upgrade.
        -- For third party, check for error.
        if exists (select * from msdb..MSdistpublishers where 
            lower(name) = lower(@publisher) and
            thirdparty_flag = 0)
        begin
            -- This is needed for 6.5 upgrade.
            -- Remove subscription entries for this publisher and subscriber pair
            -- Get dist publisher ID
            exec dbo.sp_MSvalidate_distpublisher @publisher, @publisher_id OUTPUT
            delete MSsubscriptions where subscriber_id = @srvid and 
                publisher_id = @publisher_id
        end
        else
        begin
            if exists (select * from MSsubscriptions where subscriber_id = @srvid)
            begin
                raiserror(20100, 16, -1, @subscriber)
                return (1)
            end
        end

        delete MSsubscriber_info where UPPER(publisher) = UPPER(@publisher) and UPPER(subscriber) = UPPER(@subscriber)
        if @@error <> 0
            return 1
        delete MSsubscriber_schedule where UPPER(publisher) = UPPER(@publisher) and UPPER(subscriber) = UPPER(@subscriber)
        if @@error <> 0
            return 1    
    end
GO

-- delete the agent rows that are orphaned for some external reasons, e.g., publishing database dropped,
-- the agent entry for anonymous TRAN/MERGE subscriptions. 
-- Can be called directly by user to explicitly cleanup metadata in distribution database

raiserror(15339,-1,-1,'sp_MScleanup_agent_entry')
GO
CREATE PROCEDURE sp_MScleanup_agent_entry
AS
    
    declare @min_valid_day 		datetime

	declare @publisher_id 		int
	declare @subscriber_id 		int
	declare @publication 		sysname
	declare @publisher_db 		sysname
	declare @subscriber_db 		sysname
	declare @retention 			int
	declare @publication_type 	int
	declare @agent_id			int
		, @num_dropped	int
		, @retcode int

    set nocount on
	select @num_dropped = 0

	declare PC CURSOR LOCAL FAST_FORWARD for 
		select distinct publisher_id, publisher_db, publication, retention, publication_type from MSpublications
			where retention<>0
	open PC
	fetch PC into @publisher_id, @publisher_db, @publication, @retention, @publication_type
	while (@@fetch_status <> -1)
    begin    
		if @publication_type = 2  --merge publication
		begin
    		select @min_valid_day = dateadd(day, @retention * (-2), getdate()) 

		    declare hC CURSOR LOCAL FAST_FORWARD FOR 
				select id from MSmerge_agents where creation_date < @min_valid_day
    				and not exists (select * from MSmerge_history where agent_id = id and time > @min_valid_day)
    				and publisher_id=@publisher_id
    				and publisher_db = @publisher_db
    				and publication = @publication   
	    			-- Only do this for anonymous agents
					and subscriber_name is not null         
			for read only
			open hC
			fetch hC into @agent_id
			while (@@fetch_status <> -1)
			begin
				exec @retcode = dbo.sp_MSdrop_merge_agentid @agent_id
				if @retcode <> 0 or @@error <> 0
					return (1)
				select @num_dropped = @num_dropped + 1
				fetch hC into @agent_id
			end
			close hC
			deallocate hC
		end
   		else if @publication_type in (0,1) --Tran level publication
  			begin  
    			select @min_valid_day = dateadd(hour, @retention * (-1), getdate())    
				-- Only do this for anonymous agents
			    declare hC CURSOR LOCAL FAST_FORWARD FOR 
					select id from MSdistribution_agents where creation_date < @min_valid_day
						and not exists (select * from MSdistribution_history where agent_id = id and time > @min_valid_day)
						and publisher_id=@publisher_id
    					and publisher_db = @publisher_db
    					and publication = @publication            
	    				-- Only do this for anonymous agents
						and subscriber_name is not null         	            	
				for read only
				open hC
				fetch hC into @agent_id
				while (@@fetch_status <> -1)
				begin
					exec @retcode = dbo.sp_MSdrop_distribution_agentid @agent_id
					if @retcode <> 0 or @@error <> 0
						return (1)
					select @num_dropped = @num_dropped + 1
					fetch hC into @agent_id
				end
			close hC
			deallocate hC
        	end
      	fetch PC into @publisher_id, @publisher_db, @publication, @retention, @publication_type
    end
    close PC
    deallocate PC
	if @num_dropped > 0
		RAISERROR(20597, 10, -1, @num_dropped) 
   	return (0)
FAILURE:
    close PC
    deallocate PC
   	return (1)		
GO

raiserror(15339,-1,-1,'sp_MShelp_subscription_status')
GO
CREATE PROCEDURE sp_MShelp_subscription_status(
@publisher          sysname,
@publisher_db       sysname,
@publication        sysname,
@subscriber         sysname,
@subscriber_db      sysname,
@retention          int,
@out_of_date        int OUTPUT,
@independent_agent  bit = 0
)AS

declare @subscriber_id          int
declare @publisher_id           int
declare @publication_id         int
declare @retcode                int
declare @agent_id               int
declare @min_valid_day          datetime
declare @subscription_time      datetime
declare @last_history			datetime
declare @last_status			int

select @out_of_date = 0 -- Default value set to in-sync
select @publisher_id = srvid from master..sysservers where UPPER(srvname) = UPPER(@publisher)
select @subscriber_id = srvid from master..sysservers where UPPER(srvname)=UPPER(@subscriber)

select  @publication_id = publication_id
        from MSpublications where
        publisher_id = @publisher_id and
        publisher_db = @publisher_db and
        publication = @publication

select @subscription_time = subscription_time
        from MSsubscriptions where
            publisher_id = @publisher_id and
            publisher_db = @publisher_db and
            publication_id = @publication_id and
            subscriber_id = @subscriber_id and
            subscriber_db = @subscriber_db
            
select @min_valid_day = dateadd(hour, -@retention, getdate())
        
BEGIN TRAN
    select @agent_id = id from MSdistribution_agents 
        where   publisher_id = @publisher_id and 
                publisher_db = @publisher_db and 
                ((publication = @publication and @independent_agent = 1 ) 
                    or (LOWER(publication) = 'all' and @independent_agent = 0)) and
                subscriber_id = @subscriber_id and  
                subscriber_db = @subscriber_db

    if @agent_id is NOT NULL
        begin
        	select Top 1 @last_status = runstatus, @last_history = time 
        		from MSdistribution_history where agent_id = @agent_id
        			order by timestamp DESC
        			
			-- if failure then get the last success; if any; else use the existing value        			
			
        	if @last_status = 6 and EXISTS (select * from MSdistribution_history where agent_id = @agent_id and runstatus = 2) 
        		select Top 1 @last_history = time 
        			from MSdistribution_history where agent_id = @agent_id and runstatus = 2
        				order by timestamp DESC	
        	
            if EXISTS (select * from MSdistribution_history where agent_id = @agent_id) and (@last_history < @min_valid_day)
                and (@retention <> 0)
                select @out_of_date = 1
            else 
                if (not EXISTS (select * from MSdistribution_history where agent_id = @agent_id)) and
                        (@subscription_time < @min_valid_day) and (@retention <> 0)
                select @out_of_date = 1
        end
        
COMMIT TRAN
return (0)

FAILURE:
    if @@TRANCOUNT = 1
        ROLLBACK TRAN
    else
        COMMIT TRAN
    return (1)
GO



raiserror(15339,-1,-1,'sp_MShelp_subscriber_info')
GO
CREATE PROCEDURE sp_MShelp_subscriber_info
@publisher sysname = '%',
@subscriber sysname = '%',
@found int = NULL    OUTPUT,
@show_password bit = 1

AS
   set nocount on
   
   DECLARE @no_rows bit

	-- push agents (dist or merge) may call this.
	-- raise an message indicating that users may forget to specify -SubscriptionType
	if is_member(N'db_owner') <> 1
	begin
		raiserror (20604, 16, -1)
		return 1
	end

    /*
    ** Initializations.
    */
    IF @found is NULL
    BEGIN
        SELECT @no_rows=0
    END
    ELSE
    BEGIN
        SELECT @no_rows=1
    END

   if exists (select * from MSsubscriber_info 
               where (@publisher = '%' or UPPER(publisher) = UPPER(@publisher)) 
                 and (@subscriber = '%' or UPPER(subscriber) = UPPER(@subscriber)))
   begin
        select @found = 1
        if @no_rows <>0 return(0)
   end
   else
   begin
        select @found = 0
        if @no_rows <>0 return(0)
   end

   if exists (select * from MSsubscriber_schedule 
               where (@publisher = N'%' or UPPER(publisher) = UPPER(@publisher))
                 and (@subscriber = N'%' or UPPER(subscriber) = UPPER(@subscriber)))
    begin
    
     select Sinfo.publisher,
            Sinfo.subscriber,
            Sinfo.type,
            Sinfo.login,
            case when @show_password = 1 then Sinfo.password
            else convert(sysname, NULL) end,
            100,  -- commit_batch_size, no longer supported
            100,  -- status_batch_size, no longer supported
            1,    -- flush_frequency, no longer supported
            sch1.frequency_type, 
            sch1.frequency_interval,
            sch1.frequency_relative_interval,
            sch1.frequency_recurrence_factor,
            sch1.frequency_subday,
            sch1.frequency_subday_interval,
            sch1.active_start_time_of_day,
            sch1.active_end_time_of_day,
            sch1.active_start_date,
            sch1.active_end_date,
            4, -- retryattempt, no longer exist
            4,  -- retrydelay, no longer exist
            Sinfo.description,
            Sinfo.security_mode,
            sch2.frequency_type, 
            sch2.frequency_interval,
            sch2.frequency_relative_interval,
            sch2.frequency_recurrence_factor,
            sch2.frequency_subday,
            sch2.frequency_subday_interval,
            sch2.active_start_time_of_day,
            sch2.active_end_time_of_day,
            sch2.active_start_date,
            sch2.active_end_date
            
    from (MSsubscriber_info as Sinfo LEFT OUTER JOIN MSsubscriber_schedule as sch1 
        on UPPER(Sinfo.publisher)=UPPER(sch1.publisher) AND UPPER(Sinfo.subscriber)=UPPER(sch1.subscriber) and sch1.agent_type=0)
        LEFT OUTER JOIN MSsubscriber_schedule as sch2
            on UPPER(Sinfo.publisher)=UPPER(sch2.publisher) AND UPPER(Sinfo.subscriber)=UPPER(sch2.subscriber) 
                    and sch2.agent_type=1
    where (@publisher = N'%' or UPPER(Sinfo.publisher) = UPPER(@publisher)) and 
          (@subscriber = N'%' or UPPER(Sinfo.subscriber) = UPPER(@subscriber))                 
    
    end
GO

raiserror(15339,-1,-1,'sp_MSdistribution_counters')
go
CREATE PROCEDURE sp_MSdistribution_counters
@publisher sysname      /* publication server name */
AS

    set nocount on

    declare @publisher_id smallint
    declare @subscriber_id smallint
    declare @active_status tinyint
    declare @snapshot_bit int
    declare @undelivered_commands int
    declare @delivered_commands int
    declare @delivery_rate float
    declare @delivery_latency int
    declare @xact_seqno varbinary(16)
    declare @agent_id int
    
    select @active_status = 2
    select @snapshot_bit = 0x80000000


    -- Make sure publisher is defined on distributor
    --
    select @publisher_id = srvid from master..sysservers where UPPER(srvname) = UPPER(@publisher)
    if @publisher_id is null
       return (1)

    create table #dist_trans (subscriber_id smallint NOT NULL, undelivered_commands int NOT NULL, 
        delivered_commands int NOT NULL, delivery_rate float NOT NULL, 
        delivery_latency int NOT NULL)

    declare hc CURSOR LOCAL FAST_FORWARD FOR select distinct agent_id
        from MSsubscriptions
        where
        publisher_id = @publisher_id and
        subscriber_id >= 0 and
        status = 2
        for read only

    open hc
    fetch hc into  @agent_id
    while (@@fetch_status <> -1)
    begin
        -- Get the lastest numbers from distribution_history
        select  @xact_seqno = NULL

        -- Get latest seqno, rate and latency
        set rowcount 1
        select  @xact_seqno = xact_seqno,
--              @delivered_commands = delivered_commands,
                @delivery_rate = current_delivery_rate,
                @delivery_latency = current_delivery_latency
            -- from MSdistribution_history  (READPAST)
            from MSdistribution_history 
            where
            agent_id = @agent_id and
            xact_seqno <> 0x0
            order by timestamp DESC
        set rowcount 0

        if @xact_seqno IS NULL
            select  @xact_seqno = 0x00,
                    @delivery_rate = 0,
                    @delivery_latency = 0


        set rowcount 1
        select @subscriber_id = subscriber_id FROM MSsubscriptions
            where agent_id = @agent_id
        set rowcount 0
        
        -- Get the delivered trans number
        select @delivered_commands = 0
        select @delivered_commands = isnull(count(*), 0)
            from
            -- MSrepl_commands rc (READPAST), MSsubscriptions s
            MSrepl_commands rc, MSsubscriptions s
            where
            /*
            ** Query from sp_MSget_repl_commands
            */
            s.agent_id = @agent_id and
            s.status = @active_status and
            rc.publisher_database_id = s.publisher_database_id and
--          rc.publisher_id = s.publisher_id and
--          rc.publisher_db = s.publisher_db and
            rc.xact_seqno <= @xact_seqno and
            rc.article_id = s.article_id and
            rc.partial_command = 0
            and
            ((rc.xact_seqno >= s.subscription_seqno and (rc.type & @snapshot_bit) <> @snapshot_bit) or
            rc.xact_seqno = s.subscription_seqno)

        -- Get the undelivered trans number
        select @undelivered_commands = 0
        select @undelivered_commands = isnull(count(*), 0)
            from
            -- MSrepl_commands rc (READPAST), MSsubscriptions s
            MSrepl_commands rc , MSsubscriptions s
            where
            /*
            ** Query from sp_MSget_repl_commands
            */
            s.agent_id = @agent_id and
            s.status = @active_status and
            rc.publisher_database_id = s.publisher_database_id and
            rc.xact_seqno > @xact_seqno and
            rc.article_id = s.article_id and
            rc.partial_command = 0
            and
            ((rc.xact_seqno >= s.subscription_seqno and (rc.type & @snapshot_bit) <> @snapshot_bit) or
            rc.xact_seqno = s.subscription_seqno)

        insert into #dist_trans values (@subscriber_id, @undelivered_commands,
            @delivered_commands, @delivery_rate, @delivery_latency)
        
        fetch hc into  @agent_id
    end

    close hc
    deallocate hc

    select 'subscriber' = srvname, 
            'delivered commands' = sum(delivered_commands),
            'undelivered_commands' = sum(undelivered_commands),
            'delivery_rate' = sum(delivery_rate),
            'delivery_latency' = (select isnull(avg(delivery_latency), 0) from #dist_trans, master.dbo.sysservers where
                srvname = s1.srvname and delivery_latency > 0)
        from #dist_trans, master.dbo.sysservers s1
        where subscriber_id = srvid
        group by srvname

    drop table #dist_trans
        
GO

raiserror(15339,-1,-1,'sp_MSremove_published_jobs')
go
CREATE PROCEDURE sp_MSremove_published_jobs
@server sysname,
@database sysname
AS
    -- 6.5 publisher and 7.0 publisher will call this
    -- publisher_database_id will be drop in sp_MSdrop_publication.
    return(0)
go

raiserror(15339,-1,-1,'sp_MSset_snapshot_xact_seqno')
go

CREATE PROCEDURE sp_MSset_snapshot_xact_seqno
@publisher_id int,
@publisher_db sysname,
@article_id int, 
@xact_seqno varbinary(16),
@reset bit = 0,         /* @reset = 1 is used for Scheduled Snapshot publications by snapshot */
@publication sysname = NULL,
@publisher_seqno varbinary(16) = 0x00,
@ss_cplt_seqno varbinary(16) = NULL
/* 
** Required for 6x publishers!
*/
AS

    DECLARE @virtual smallint     /* const: virtual subscriber id */
    DECLARE @virtual_anonymous smallint /* const: virtual anonymous subscriber id */
    DECLARE @old_xact_seqno varbinary(16)
    DECLARE @old_publisher_seqno varbinary(16)
    DECLARE @subscribed tinyint
    DECLARE @automatic tinyint
    DECLARE @old_snapshot_seqno_flag bit
    DECLARE @publication_id int
	DECLARE @initiated tinyint

    SELECT @virtual = -1
    SELECT @virtual_anonymous = -2
    SELECT @subscribed = 1
    SELECT @automatic = 1
	SELECT @initiated = 3
	
	if @ss_cplt_seqno is null 
	begin
		select @ss_cplt_seqno = @xact_seqno;
	end

    -- 6.5 only!!! @publication is not null only if the publisher is 6.5 sever!
    -- Set the publication_id and sync_type in MSsubscriptions.
    -- It will be used in sp_MSupdate_subscriptions 
    IF @publication IS NOT NULL
    BEGIN
        -- Get the publication id
        SELECT @publication_id = publication_id FROM MSpublications
            WHERE   publisher_id = @publisher_id AND
                    publisher_db = @publisher_db AND    
                    publication  = @publication

        -- Set the pubid and the sync_type
        -- Avoid update rows with no change to reduce update locks.
        
        UPDATE MSsubscriptions SET publication_id = @publication_id
            WHERE   publisher_id = @publisher_id AND
                    publisher_db = @publisher_db AND    
                    article_id  = @article_id and
                    status = @subscribed and
                    publication_id <> @publication_id
        
        -- Have to do this to avoid no sync subs from 6.5 publisher being
        -- updated.
        UPDATE MSsubscriptions SET sync_type = @automatic
            WHERE   publisher_id = @publisher_id AND
                    publisher_db = @publisher_db AND    
                    article_id  = @article_id and
                    status = @subscribed and
                    sync_type <> @automatic
    END

    begin tran
    save TRANSACTION MSset_snapshot_xact_seqno

    /* 
    ** Set snapshot_xact_seqno for all new subscriptions,
    ** plus the virtual subscription or all subscriptions if @reset = 1
    ** Note virtual anonymous subscription will not be set
    ** (2 virtual subscriptions of anonymous publication will be activated
    ** immediately without snapshot
    ** 
    ** @reset = 1 is used for Scheduled Snapshot publications by snapshot
    */
    UPDATE MSsubscriptions SET subscription_seqno = @xact_seqno,
        publisher_seqno = @publisher_seqno,
        snapshot_seqno_flag = 1,
        subscription_time = getdate(),
		ss_cplt_seqno = @ss_cplt_seqno
      WHERE 
         MSsubscriptions.publisher_id = @publisher_id and
         MSsubscriptions.publisher_db = @publisher_db and
         MSsubscriptions.article_id = @article_id and 
         /* virtual subscriptions are automatic sync type */
         MSsubscriptions.sync_type = @automatic and 
         (MSsubscriptions.status in(@subscribed,@initiated) or 
         MSsubscriptions.subscriber_id = @virtual or
         -- Set for virtual anonymous account if snapshot_seqno_flag
         -- is 0.
         -- The virtual anonymous account is activated immediately at subscription
         -- time for no init option for anonymous agent.
         (MSsubscriptions.subscriber_id = @virtual_anonymous and 
         (MSsubscriptions.snapshot_seqno_flag = 0 or 
		 MSsubscriptions.status in(@subscribed,@initiated))) or
         @reset = 1) 

    IF @@ERROR <> 0
    BEGIN
        if @@trancount > 0
        begin
            ROLLBACK TRANSACTION MSset_snapshot_xact_seqno
            commit tran
        end
        RETURN (1)
    END

    COMMIT TRANSACTION
GO


raiserror(15339,-1,-1,'sp_MSdrop_article')
go
CREATE PROCEDURE sp_MSdrop_article
@publisher sysname,
@publisher_db sysname,
@publication sysname,
@article sysname

as

    set nocount on

    declare @publisher_id smallint
    declare @publication_id int
    declare @article_id int
    declare @retcode int
    declare @thirdparty_flag bit
    declare @immediate_sync bit

    -- Check if publisher is a defined as a distribution publisher in the current database
    exec @retcode = dbo.sp_MSvalidate_distpublisher @publisher, @publisher_id OUTPUT
    if @retcode <> 0
    begin
        return(1)
    end

    -- Make sure publication exists
    select @publication_id = publication_id, @thirdparty_flag = thirdparty_flag,
        @immediate_sync = immediate_sync
        from MSpublications where 
        publication = @publication and
        publisher_id = @publisher_id and 
        publisher_db = @publisher_db
    if @publication_id is NULL
    begin
        raiserror(20026, 16, -1, @publication)
        return (1)
    end

    -- Make sure article exists
    declare @source_object sysname
    select @article_id = article_id, @source_object = source_object
        from MSarticles where 
        publication_id = @publication_id and
        publisher_id = @publisher_id and 
        publisher_db = @publisher_db and 
        article = @article
    if @article_id is NULL
    begin
        if @thirdparty_flag = 1
        begin
            raiserror(20027, 16, -1, @article)
            return (1)
        end
        else
            return (0)
    end

    -- Check to make sure that there are no subscriptions on the article
    if exists (select * from MSsubscriptions where 
        publisher_id = @publisher_id and
        publisher_db = @publisher_db and
        publication_id = @publication_id and
        article_id = @article_id and
        subscriber_id >= 0)             -- ignore virtual subscriptions
    begin
        raiserror(14046, 16, -1)
        return(1)
    end

    begin tran
    save tran MSdrop_article

    -- For third party publications drop immediate sync and anonymous virtual subscriptions
    -- SQL Server publications will do this via RPC calls to sp_MSadd_subscription
    if @thirdparty_flag = 1 and @immediate_sync = 1
    begin
        begin
            exec @retcode = dbo.sp_MSdrop_subscription
                @publisher = @publisher,
                @publisher_db = @publisher_db,
                @publication = @publication,
                @article_id = @article_id,
                @subscriber = NULL                  -- virtual subscription
            if @retcode <> 0 or @@error <> 0
            begin
                if @@trancount > 0
                begin
                    rollback tran MSdrop_article
                    commit tran
                end
                return (1)
            end
        end
    end

    delete from MSarticles where
        publisher_id = @publisher_id and
        publisher_db = @publisher_db and
        publication_id = @publication_id and
        article_id = @article_id
    if @@error <> 0
    begin
        if @@trancount > 0
        begin
            rollback tran MSdrop_article
            commit tran
        end
        return (1)
    end

	if not exists (select * from MSarticles  where 
        publisher_id = @publisher_id and
        publisher_db = @publisher_db and
        source_object = @source_object)
	begin
		delete MSrepl_identity_range where 
            publisher = @publisher and
            publisher_db = @publisher_db and
            tablename = @source_object
		if @@ERROR <> 0 begin
			if @@trancount > 0
				ROLLBACK TRAN
			RETURN (1)
		end
	end

    commit tran
go

raiserror(15339,-1,-1,'sp_MSdrop_snapshot_agent')
GO
CREATE PROCEDURE sp_MSdrop_snapshot_agent (
    @publisher sysname,
    @publisher_db sysname,
    @publication sysname
) AS


    SET NOCOUNT ON

    /*
    ** Declarations.
    */
    DECLARE @retcode    int
    DECLARE @job_id     binary(16)
    DECLARE @local_job  bit
    DECLARE @publisher_id smallint
    DECLARE @name       nvarchar(100)
    DECLARE @agent_id   int

    /*
    ** Initializations
    */
    select @publisher_id = srvid from master..sysservers where
        UPPER(srvname) = UPPER(@publisher)



    SELECT @job_id = job_id, @local_job = local_job, @name = name, @agent_id = id  FROM MSsnapshot_agents WHERE
        publisher_id = @publisher_id AND
        publisher_db = @publisher_db AND
        publication = @publication

    -- Delete Perfmon instance
    dbcc deleteinstance ("SQL Replication Snapshot", @name)

    -- Return if not exists
    IF @local_job IS NULL
        RETURN(0)

    BEGIN TRAN

    IF @local_job = 1
    BEGIN
        -- Don't drop the job for third party publications.
        if exists (select * from msdb..MSdistpublishers where 
            UPPER(name) = UPPER(@publisher) and
            thirdparty_flag = 0)
        begin                           
            IF EXISTS (SELECT * FROM msdb..sysjobs_view WHERE job_id = @job_id)
            BEGIN
                -- Checks if job name was generated by replication
                EXEC @retcode = dbo.sp_MSissnapshotjobnamegenerated
                                    @publisher = @publisher,
                                    @publisher_db = @publisher_db,
                                    @publication = @publication,
                                    @job_id = @job_id
                IF @@ERROR <> 0 
                    GOTO UNDO
                
                -- Only drop the job if the name was generated
                IF @retcode = 0                
                BEGIN
                    EXEC @retcode = msdb.dbo.sp_delete_job @job_id = @job_id
                    IF @@ERROR <> 0 or @retcode <> 0
                        GOTO UNDO
                END
            END
        end
    END

    DELETE MSsnapshot_agents WHERE id = @agent_id
    IF @@ERROR <> 0 
        GOTO UNDO

    -- Remove history
    DELETE MSsnapshot_history WHERE agent_id = @agent_id
    IF @@ERROR <> 0 
        GOTO UNDO

    IF @@ERROR <> 0 
        GOTO UNDO

    -- Update global replication status table
    EXEC dbo.sp_MSupdate_replication_status
        @publisher,
        @publisher_db,
        @publication,
        @agent_type = 1,
        @agent_name = @name,
        @status = -1    -- delete status

    COMMIT TRAN

    RETURN(0)

UNDO:
    if @@TRANCOUNT = 1
        ROLLBACK TRAN
    else
        COMMIT TRAN
    return(1)
GO


raiserror(15339,-1,-1,'sp_MSdrop_logreader_agent')
GO
CREATE PROCEDURE sp_MSdrop_logreader_agent (
    @publisher sysname,
    @publisher_db sysname,
    @publication sysname  --Only used by 3rd party publisher
) AS


    SET NOCOUNT ON

    /*
    ** Declarations.
    */
    DECLARE @retcode    int
    DECLARE @job_id     binary(16)
    DECLARE @local_job  bit
    DECLARE @publisher_id smallint
    DECLARE @name       nvarchar(100)
    DECLARE @agent_id   int

    /*
    ** Initializations
    */
    select @publisher_id = srvid from master..sysservers where
        UPPER(srvname) = UPPER(@publisher)


    SELECT @job_id = job_id, @local_job = local_job, @name = name, @agent_id = id FROM MSlogreader_agents WHERE
        publisher_id = @publisher_id AND
        publisher_db = @publisher_db AND
        publication = @publication

    -- Delete Perfmon instance
    dbcc deleteinstance ("SQL Replication Logreader", @name)

    -- Return if not exists
    IF @local_job IS NULL
        RETURN(0)

    BEGIN TRAN

    IF @local_job = 1
    BEGIN
        -- Don't drop the job for third party publications.
        if exists (select * from msdb..MSdistpublishers where 
            UPPER(name) = UPPER(@publisher) and
            thirdparty_flag = 0)
        begin                           
            IF EXISTS (SELECT * FROM msdb..sysjobs_view WHERE job_id = @job_id)
            BEGIN
                -- Checks if the job name matches one that is generated 
                -- by replication
                EXEC @retcode = dbo.sp_MSislogreaderjobnamegenerated
                                    @publisher = @publisher,
                                    @publisher_db = @publisher_db,
                                    @job_id = @job_id
                IF @@ERROR <> 0 
                    GOTO UNDO
                
                -- Only drop the job if the name was generated
                IF @retcode = 0
                BEGIN
                    EXEC @retcode = msdb.dbo.sp_delete_job @job_id = @job_id
                    IF @@ERROR <> 0 or @retcode <> 0
                        GOTO UNDO
                END
            END
        end
    END

    DELETE MSlogreader_agents WHERE id = @agent_id
    IF @@ERROR <> 0 
        GOTO UNDO

    -- Remove history
    DELETE MSlogreader_history WHERE
        agent_id = @agent_id

    IF @@ERROR <> 0 
        GOTO UNDO

    -- Update global replication status table
    EXEC dbo.sp_MSupdate_replication_status
        @publisher,
        @publisher_db,
        @publication,
        @agent_type = 2,
        @agent_name = @name,
        @status = -1    -- delete status

    COMMIT TRAN

    RETURN(0)

UNDO:
    if @@TRANCOUNT = 1
        ROLLBACK TRAN
    else
        COMMIT TRAN
    return(1)
GO

raiserror(15339,-1,-1,'sp_MSdrop_publication')
go
CREATE PROCEDURE sp_MSdrop_publication
@publisher sysname,
@publisher_db sysname,
@publication sysname
as

    set nocount on

    declare @publisher_id smallint
    declare @publication_id int
    declare @retcode int
    declare @article sysname
    declare @thirdparty_flag bit
    DECLARE @working_dir nvarchar(255)
    DECLARE @pub_dir nvarchar(255)


    -- Check if publisher is a defined as a distribution publisher in the current database
    exec @retcode = dbo.sp_MSvalidate_distpublisher @publisher, @publisher_id OUTPUT
    if @retcode <> 0
    begin
        return(1)
    end

    -- Make sure publication exists
    select @publication_id = publication_id, @thirdparty_flag = thirdparty_flag 
        from MSpublications where publication = @publication and
        publisher_id = @publisher_id and publisher_db = @publisher_db
    if @publication_id is NULL
    begin
        -- We don't know whether or not it is a third party or not so we can not 
        -- return error.
        -- raiserror(20026, 16, -1, @publication)
        -- return (1)
        return (0)
    end

    -- Make sure that there are no subscriptions on the publication.
    if exists (select * from MSsubscriptions s, MSpublications p where 
        p.publisher_id = @publisher_id and
        p.publisher_db = @publisher_db and
        p.publication = @publication and
        s.publisher_id = @publisher_id and
        s.publisher_db = @publisher_db and
        s.publication_id = p.publication_id and
        s.subscriber_id >= 0)               -- ignore virtual subscriptions
    begin
        raiserror(14005, 16, -1)
        return(1)
    end

    SELECT @working_dir = working_directory FROM msdb..MSdistpublishers
        where UPPER(name) = UPPER(@publisher)

    IF @working_dir IS NOT NULL
    BEGIN

		-- Remove the pub dir under UNC and FTP if it exists
		-- Note: sp_MSreplremoveuncdir will convert unc path to local path.
		-- This is required. Otherwise we will see 'Access denied' error.
        SELECT @pub_dir = @working_dir + '\unc\' + 
                    fn_replcomposepublicationsnapshotfolder(@publisher,@publisher_db,@publication) collate database_default
		exec @retcode = sp_MSreplremoveuncdir @pub_dir
		if @retcode <> 0 or @@error <> 0
			return(1)


        SELECT @pub_dir = @working_dir + '\ftp\' + 
                    fn_replcomposepublicationsnapshotfolder(@publisher,@publisher_db,@publication) collate database_default
		exec @retcode = sp_MSreplremoveuncdir @pub_dir
		if @retcode <> 0 or @@error <> 0
			return(1)
    END

    begin tran
    save tran MSdrop_publication

    -- Delete all articles if a third party publication
    if @thirdparty_flag = 1 
    begin
        -- Delete all articles in the publication
        declare hCarticles CURSOR LOCAL FAST_FORWARD FOR select article from MSarticles where 
            publisher_id = @publisher_id and
            publisher_db = @publisher_db and
            publication_id = 
                (select publication_id from MSpublications where 
                    publisher_id = @publisher_id and
                    publisher_db = @publisher_db and
                    publication = @publication)
        open hCarticles
        fetch hCarticles into @article
        while (@@fetch_status <> -1)
        begin
            exec @retcode = dbo.sp_MSdrop_article @publisher, @publisher_db, @publication, @article
            if @retcode != 0 or @@error != 0
            begin
                close hCarticles
                deallocate hCarticles
                if @@trancount > 0
                begin
                    rollback tran MSdrop_publication
                    commit tran
                end
                return (1)
            end
                
            fetch hCarticles into @article
        end
        close hCarticles
        deallocate hCarticles
    end

    delete from MSpublications where 
        publisher_id = @publisher_id and
        publisher_db = @publisher_db and
        publication = @publication
    if @@error <> 0
    begin
        if @@trancount > 0
        begin
            rollback tran MSdrop_publication
            commit tran
        end
        raiserror (14006, 16, -1)
        return (1)
    end

    -- Drop snapshot agent
    exec @retcode = dbo.sp_MSdrop_snapshot_agent
            @publisher = @publisher,
            @publisher_db = @publisher_db,
            @publication = @publication
    if @@ERROR<> 0 or @retcode <> 0
    begin
        if @@trancount > 0
        begin
            rollback tran MSdrop_publication
            commit tran
        end
        return (1)
    end

    -- Drop the logreader agent if
    -- 1. thirdparty publisher OR 
    -- 2. no publication left in the publisher database
    if @thirdparty_flag = 1 OR
        not exists (select * from MSpublications where 
            publisher_id = @publisher_id and
            publisher_db = @publisher_db)
    begin
        exec @retcode = dbo.sp_MSdrop_logreader_agent
                @publisher = @publisher,
                @publisher_db = @publisher_db,
                @publication = @publication
        if @@ERROR<> 0 or @retcode <> 0
        begin
            if @@trancount > 0
            begin
                rollback tran MSdrop_publication
                commit tran
            end
            return (1)
        end
    end

    -- Delete anonymous agents
    delete MSdistribution_agents where
        publisher_id = @publisher_id and
        publisher_db = @publisher_db and
        publication = @publication
    if @@ERROR<> 0 or @retcode <> 0
    begin
        if @@trancount > 0
            rollback tran MSdrop_publication
        return (1)
    end

    delete MSmerge_agents where
        publisher_id = @publisher_id and
        publisher_db = @publisher_db and
        publication = @publication
    if @@ERROR<> 0 or @retcode <> 0
    begin
        if @@trancount > 0
            rollback tran MSdrop_publication
        return (1)
    end

    -- Cleanup publication access list table
    delete MSpublication_access where
        publication_id = @publication_id
    if @@ERROR<> 0 or @retcode <> 0
    begin
        if @@trancount > 0
            rollback tran MSdrop_publication
        return (1)
    end

    -- Remove publisher_id, publisher_db pair if no other publication is using it. 
    if not exists (select * from MSpublications where publisher_id = @publisher_id and
        publisher_db = @publisher_db)
    begin
        declare @publisher_database_id int

        select @publisher_database_id = id from MSpublisher_databases where 
            publisher_id = @publisher_id and 
            publisher_db = @publisher_db

        delete from MSrepl_backup_lsns where 
            publisher_database_id = @publisher_database_id

        delete from MSpublisher_databases where 
            publisher_id = @publisher_id and publisher_db = @publisher_db
        if @@error <> 0
        begin
            if @@trancount > 0
            begin
                rollback tran MSdrop_publication
                commit tran
            end
            return (1)
        end

        -- Cleaning up MSrepl_originators
        delete MSrepl_originators where
            publisher_database_id = @publisher_database_id
        if @@error <> 0
        begin
            if @@trancount > 0
                rollback tran MSdrop_publication
            return (1)
        end

    end

    commit tran
go
raiserror(15339,-1,-1,'sp_MSadd_snapshot_agent')
GO
CREATE PROCEDURE sp_MSadd_snapshot_agent (
    @name nvarchar(100) = NULL,
    @publisher sysname,
    @publisher_db sysname,
    @publication sysname,  
    @publication_type int = 0,              -- 0 Transactional 1 Snapshot 2 Merge
    @local_job bit,  
    @freqtype  int = 4 ,                  /* 4== Daily */
    @freqinterval int  = 1,             /* Every day */
    @freqsubtype int =  4,                 /* Sub interval = Minute */
    @freqsubinterval int = 5,              /* Every five minutes */
    @freqrelativeinterval int = 1, 
    @freqrecurrencefactor int = 0, 
    @activestartdate int = 0,             /* 12:00 am - 11:59 pm */
    @activeenddate int =99991231 ,         /* No start date */    
    @activestarttimeofday int = 0,         
    @activeendtimeofday int = 235959,     /* No end time */    
    @command nvarchar(4000) = NULL,
    @job_existing bit = 0,   -- for 6x publisher
    @snapshot_jobid binary(16) = NULL OUTPUT
) AS


    SET NOCOUNT ON

    /*
    ** Declarations.
    */
    DECLARE @retcode            int
    DECLARE @publisher_id       smallint
    DECLARE @profile_id         int
    DECLARE @snapshot_type      int
    DECLARE @databasename       sysname
    DECLARE @agent_id           int

    DECLARE @distributor_security_mode      int                     /* 0 standard; 1 integrated */
    DECLARE @distributor_login              sysname 
    DECLARE @distributor_password           nvarchar(524)
    DECLARE @category_name      sysname
    DECLARE @platform_nt        binary

    /*
    ** Initializations
    */
    select @platform_nt = 0x1

    select @publisher_id = srvid from master..sysservers where
        UPPER(srvname) = UPPER(@publisher)

    -- Always use integrated security on winNT
    if (@platform_nt = platform() & @platform_nt)
        set @distributor_security_mode = 1
    else
    begin
        select  @distributor_security_mode = 0,
                @distributor_login  = login,
                @distributor_password = password
            from msdb..MSdistpublishers where UPPER(name) = UPPER(@@servername)
    end

    select @command = @command + ' -DistributorSecurityMode ' + 
        convert(nvarchar(10),@distributor_security_mode) +  ' ' 
    if @distributor_security_mode <> 1
    begin
        if @distributor_login is not NULL
            select @command = @command + '-DistributorLogin ' + @distributor_login + ' '
        if @distributor_password is not NULL
            select @command = @command + '-DistributorEncryptedPassword ' + quotename(@distributor_password) + ' '
    end

    -- if @name is not null and @job_existing = 1, the proc is from DMO scripting
    -- check to see if the job is there or not, if not, reset @job_existing
    -- value. This is for the case when the user generate the script at
    -- the publisher but did not re-create repl jobs at the distributor.
    if @local_job = 1 and @job_existing = 1 and @name is not null and 
       @name <> N''
    begin
        if not exists (select * from msdb..sysjobs_view where 
            name = @name and
            UPPER(originating_server) = UPPER(CONVERT(sysname, SERVERPROPERTY('ServerName'))))
        begin
            set @job_existing = 0
            set @name = null
        end
    end

    BEGIN TRAN
    
    /* Code for snapshot agent type in MSagent_profiles */
    SELECT @snapshot_type = 1

    -- Get the default profile ID for the snapshot agent type. If a third party publication
    -- no profile is used.
    if exists (select * from MSpublications where 
                publisher_id = @publisher_id and
                publisher_db = @publisher_db and
                publication = @publication and
                thirdparty_flag = 1)
    begin
        set @profile_id = 0
    end
    else
    begin
         SELECT @profile_id = profile_id FROM msdb..MSagent_profiles WHERE 
            agent_type = @snapshot_type and
            def_profile = 1
    end


    if not exists (select * from MSsnapshot_agents where
        publisher_id = @publisher_id and
        publisher_db = @publisher_db and
        publication = @publication)
    begin
        /* 
        ** Insert row
        */
        INSERT INTO MSsnapshot_agents (name, publisher_id, publisher_db, publication, publication_type,
                                local_job, profile_id)
             VALUES ('',@publisher_id, @publisher_db, @publication, @publication_type, @local_job, @profile_id)
        IF @@ERROR <> 0
            GOTO UNDO

        set @agent_id = @@IDENTITY
    end
    else
        select @agent_id = id from MSsnapshot_agents where
            publisher_id = @publisher_id and
            publisher_db = @publisher_db and
            publication = @publication

    DECLARE @name_is_generated bit
    SELECT @name_is_generated = 0     
    IF @name IS NULL OR @name = N''
    BEGIN
        SELECT @name_is_generated = 1
        SELECT @name = CONVERT(nvarchar(28),@publisher ) + '-' + CONVERT(nvarchar(28),@publisher_db) + '-' + 
                        CONVERT(nvarchar(28),@publication) + '-'  + CONVERT(nvarchar, @agent_id)
    END

    -- If the generated name already exists, re-generate the name with a 
    -- guid appended
    IF @name_is_generated = 1
    BEGIN
        IF EXISTS (SELECT * FROM msdb..sysjobs_view 
                    WHERE name = @name 
                      AND UPPER(originating_server) = UPPER(CONVERT(sysname, SERVERPROPERTY('ServerName'))))
        BEGIN
            SELECT @name = fn_repluniquename(newid(), @publisher, @publisher_db, 
                @publication, null)
        END            
    END

    -- Add Perfmon instance
    dbcc addinstance ("SQL Replication Snapshot", @name)

    IF @local_job = 1 and @job_existing = 0
    BEGIN

    -- ********WORKAROUND********
        DECLARE @nullchar nchar(20)
        SELECT @nullchar = NULL
    -- ********WORKAROUND********

        set @databasename = db_name()
        -- Get Snapshot category name (assumes category_id = 15)
        select @category_name = name FROM msdb.dbo.syscategories where category_id = 15

        EXECUTE @retcode = dbo.sp_MSadd_repl_job 
            @name = @name, 
            @subsystem = 'Snapshot', 
            @server = @publisher, 
            @databasename = @databasename, 
            @enabled = 1, 
            @freqtype = @freqtype, 
            @freqinterval = @freqinterval, 
            @freqsubtype = @freqsubtype, 
            @freqsubinterval = @freqsubinterval, 
            @freqrelativeinterval = @freqrelativeinterval, 
            @freqrecurrencefactor = @freqrecurrencefactor, 
            @activestartdate = @activestartdate, 
            @activeenddate = @activeenddate, 
            @activestarttimeofday = @activestarttimeofday, 
            @activeendtimeofday = @activeendtimeofday, 
            @nextrundate = 0,
            @nextruntime = 0,
            @runpriority = 0,
            @emailoperatorname = @nullchar,
            @retryattempts = 10, 
            @retrydelay = 1, 
            @command = @command, 
            @loghistcompletionlevel = 0, 
            @emailcompletionlevel = 0, 
            @description = @nullchar,
            @tagadditionalinfo = @nullchar,
            @tagobjectid = 0, 
            @tagobjecttype = 0, 
            @category_name = @category_name,
            @failure_detection = 1,
            @agent_id = @agent_id,
            @job_id = @snapshot_jobid OUTPUT

  
       IF @@ERROR <> 0 or @retcode <> 0
            GOTO UNDO
    END

    if @local_job = 1 and @job_existing = 1 
    begin
        if @snapshot_jobid is null
        begin
            select @snapshot_jobid = job_id from msdb..sysjobs_view where 
                name = @name and
                UPPER(originating_server) = UPPER(CONVERT(sysname, SERVERPROPERTY('ServerName')))
            if @snapshot_jobid IS NULL
            begin
                -- Message from msdb.dbo.sp_verify_job_identifiers
                RAISERROR(14262, -1, -1, 'Job', @name)          
                GOTO UNDO
            end
        end
        else
        begin
            if not exists (select * from msdb..sysjobs_view where 
                job_id = @snapshot_jobid and
                UPPER(originating_server) = UPPER(CONVERT(sysname, SERVERPROPERTY('ServerName'))))
            begin
                -- Message from msdb.dbo.sp_verify_job_identifiers
                RAISERROR(14262, -1, -1, 'Job', @name)          
                GOTO UNDO
            end
        end
    end

/* Moved up
    -- Get the job id if it already exists
    if @local_job = 1 and @job_existing = 1 
    begin
        select @snapshot_jobid = job_id from msdb..sysjobs_view where 
            job_id = @snapshot_jobid and
            UPPER(originating_server) = UPPER(CONVERT(sysname, SERVERPROPERTY('ServerName')))
        if @snapshot_jobid IS NULL
        begin
            -- Message from msdb.dbo.sp_verify_job_identifiers
            RAISERROR(14262, -1, -1, 'Job', @name)          
            GOTO UNDO
        end
    end
*/

    -- Generate a job GUID for remote agents. This will be used by the UI to uniquely
    -- identify rows returned by the enums
    if @local_job = 0
    begin
        -- Third party publication will pass in snapshot agent name which is created as
        -- a SQLServerAgent job.
        if @name is not null 
            select @snapshot_jobid = job_id from msdb..sysjobs_view where
                name = @name
        if @snapshot_jobid is null
            set @snapshot_jobid = newid()
        -- Reset @local_job to 1 so that repl monitor can start the job.
        -- In sp_MSdrop_snapshot_agent, we will not drop the job if the publication 
        -- is from third party.
        else
            set @local_job = 1
    end

    -- Caution: @local job might be changed from the passed in value.
    UPDATE MSsnapshot_agents SET 
        name = @name,
        job_id = @snapshot_jobid,
        -- Update the following fields because the row maybe added before this sp call
        -- by sp_MSadd_publication.
        publication_type = @publication_type,
        local_job = @local_job, 
        profile_id = @profile_id
        WHERE
        id = @agent_id

    IF @@ERROR <> 0
        GOTO UNDO

    -- Update global replication status table
    EXEC dbo.sp_MSupdate_replication_status
        @publisher,
        @publisher_db,
        @publication,
        @publication_type,
        @agent_type = 1,
        @agent_name = @name,
        @status = 0     -- not running status

    COMMIT TRAN

    RETURN(0)

UNDO:
    if @@TRANCOUNT = 1
        ROLLBACK TRAN
    else
        COMMIT TRAN
    return(1)
GO

raiserror(15339,-1,-1,'sp_MSadd_logreader_agent')
GO
CREATE PROCEDURE sp_MSadd_logreader_agent (
    @name nvarchar(100) = NULL,
    @publisher sysname,
    @publisher_db sysname,
    @publication sysname,   --Only used by 3rd party publisher
    @local_job bit,
    @job_existing bit = 0,
    @job_id binary(16) = NULL
) AS


    SET NOCOUNT ON

    /*
    ** Declarations.
    */
    DECLARE @retcode            int
    DECLARE @agent_args         nvarchar(255)
    DECLARE @publisher_id       smallint
    DECLARE @profile_id         int
    DECLARE @logreader_type     int
    DECLARE @databasename       sysname
    DECLARE @agent_id           int
    DECLARE @distributor_security_mode      int                     /* 0 standard; 1 integrated */
    DECLARE @distributor_login              sysname 
    DECLARE @distributor_password           nvarchar(524)
    DECLARE @category_name      sysname
    DECLARE @platform_nt binary

    /*
    ** Initializations
    */
    select @platform_nt = 0x1

    select @publisher_id = srvid from master..sysservers where
        UPPER(srvname) = UPPER(@publisher)
    
    -- Always use integrated security on winNT
    if (@platform_nt = platform() & @platform_nt)
        set @distributor_security_mode = 1
    else
    begin
        select  @distributor_security_mode = 0,
                @distributor_login  = login,
                @distributor_password = password
            from msdb..MSdistpublishers where UPPER(name) = UPPER(@@servername)
	end

	-- if @name is not null and @job_existing = 1, the proc is from DMO scripting
	-- check to see if the job is there are not, if not, reset @job_existing and
	-- @name values. This is for the case when the user generate the script at
	-- the publisher but did not re-create repl jobs at the distributor.
	if @local_job = 1 and @job_existing = 1 and @name is not null and 
       @name <> N''
	begin
		if not exists (select * from msdb..sysjobs_view where 
			name = @name and
			UPPER(originating_server) = UPPER(CONVERT(sysname, SERVERPROPERTY('ServerName'))))
		begin
			set @job_existing = 0
			set @name = null
		end
	end

    BEGIN TRAN

    -- If creating locally, try to drop it first
    IF @local_job = 1 and @job_existing = 0
    begin
        EXEC dbo.sp_MSdrop_logreader_agent 
            @publisher = @publisher,
            @publisher_db = @publisher_db,
            @publication = @publication  
        IF @@ERROR <> 0
            GOTO UNDO
    end

    /* Code for log reader agent type in MSagent_profiles */
    SELECT @logreader_type = 2

    -- Get the default profile ID for the logreader agent type. If a third party publication
    -- no profile is used.
    if exists (select * from MSpublications where 
                publisher_id = @publisher_id and
                publisher_db = @publisher_db and
                publication = @publication and
                thirdparty_flag = 1)
    begin
        set @profile_id = 0
    end
    else
    begin
        SELECT @profile_id = profile_id FROM msdb..MSagent_profiles WHERE 
            agent_type = @logreader_type and
            def_profile = 1
    end

    /* 
    ** Insert row
    */
    INSERT INTO MSlogreader_agents (name, publisher_id, publisher_db, publication, 
                    local_job, profile_id)
         VALUES ('',@publisher_id, @publisher_db, @publication, @local_job, @profile_id)
    IF @@ERROR <> 0
        GOTO UNDO

    set @agent_id = @@IDENTITY
        
    DECLARE @name_is_generated bit
    SELECT @name_is_generated = 0     
    IF @name IS NULL OR @name = N''
    BEGIN
        SELECT @name_is_generated = 1
        SELECT @name = CONVERT(nvarchar(43),@publisher ) + '-' + CONVERT(nvarchar(43),@publisher_db) + '-' + CONVERT(nvarchar, @@IDENTITY)
    END

    -- If the generated name already exists, re-generate the name with a 
    -- guid appended
    IF @name_is_generated = 1
    BEGIN
        IF EXISTS (SELECT * FROM msdb..sysjobs_view 
                    WHERE name = @name 
                      AND UPPER(originating_server) = UPPER(CONVERT(sysname, SERVERPROPERTY('ServerName'))))
        BEGIN
	        SELECT @name = fn_repluniquename(newid(), @publisher, @publisher_db, null, null)
        END            
    END
    
    -- Add Perfmon instance
    dbcc addinstance ("SQL Replication Logreader", @name)

    IF @local_job = 1 and @job_existing = 0
    BEGIN            
        SELECT @agent_args = '-Publisher ' + QUOTENAME(@publisher)
        SELECT @agent_args = @agent_args + ' -PublisherDB ' + QUOTENAME(@publisher_db)
        SELECT @agent_args = @agent_args + ' -Distributor ' + QUOTENAME(@@SERVERNAME)

        select @agent_args = @agent_args + ' -DistributorSecurityMode ' + 
            convert(nvarchar(10),@distributor_security_mode) +  ' ' 
        if @distributor_security_mode <> 1
        begin
            if @distributor_login is not NULL
                select @agent_args = @agent_args + '-DistributorLogin ' + @distributor_login + ' '
            if @distributor_password is not NULL
                select @agent_args = @agent_args + '-DistributorEncryptedPassword ' + quotename(@distributor_password) + ' '
        end

--    *******WORKAROUND*******
        DECLARE @nullchar nchar(20)
        SELECT @nullchar = NULL
--    *******WORKAROUND*******

        set @databasename = db_name()
        -- Get Logreader category name (assumes category_id = 13)
        select @category_name = name FROM msdb.dbo.syscategories where category_id = 13

        EXECUTE @retcode = dbo.sp_MSadd_repl_job
        @name = @name,
        @subsystem = 'LogReader',
        @server = @publisher,
        @databasename = @databasename,
        @enabled = 1,
        @freqtype = 64,       /* Auto-Start */
        @freqinterval                   = 1,
        @freqsubtype                    = 1,
        @freqsubinterval                = 1,
        @freqrelativeinterval= 1,
        @freqrecurrencefactor   = 1,
        @activestartdate                = 0,
        @activeenddate                  = 0,
        @activestarttimeofday   = 0,
        @activeendtimeofday     = 0,
        @nextrundate                    = 12355,
        @nextruntime                    = 13423,
        @runpriority                    = 0,
        @emailoperatorname              = @nullchar,
        @retryattempts = 10,            
        @retrydelay = 1,    
        @command = @agent_args,
        @loghistcompletionlevel = 0,
        @category_name = @category_name,
        @failure_detection = 1,
        @agent_id = @agent_id,
        @job_id = @job_id OUTPUT

  
       IF @@ERROR <> 0 or @retcode <> 0
            GOTO UNDO
    END

    if @local_job = 1 and @job_existing = 1 
    begin
		if @job_id is null
		begin
			select @job_id = job_id from msdb..sysjobs_view where 
				name = @name and
				UPPER(originating_server) = UPPER(CONVERT(sysname, SERVERPROPERTY('ServerName')))
			if @job_id IS NULL
			begin
				-- Message from msdb.dbo.sp_verify_job_identifiers
				RAISERROR(14262, -1, -1, 'Job', @name)          
				GOTO UNDO
			end
		end
		else
		begin
			if not exists (select * from msdb..sysjobs_view where 
				job_id = @job_id and
				UPPER(originating_server) = UPPER(CONVERT(sysname, SERVERPROPERTY('ServerName'))))
			begin
				-- Message from msdb.dbo.sp_verify_job_identifiers
				RAISERROR(14262, -1, -1, 'Job', @name)          
				GOTO UNDO
			end
		end
    end

    -- Generate a job GUID for remote agents. This will be used by the UI to uniquely
    -- identify rows returned by the enums
    if @local_job = 0
    begin
		-- Third party publication will pass in logreader agent name which is created as
		-- a SQLServerAgent job.
		if @name is not null 
			select @job_id = job_id from msdb..sysjobs_view where
				name = @name
		if @job_id is null
			set @job_id = newid()
		-- Reset @local_job to 1 so that repl monitor can start the job.
		-- In sp_MSdrop_logreader_agent, we will not drop the job if the publication 
		-- is from third party.
		else
			set @local_job = 1
    end

    UPDATE MSlogreader_agents SET name = @name,
        job_id = @job_id WHERE
        id = @agent_id
    IF @@ERROR <> 0
        GOTO UNDO

    -- Update global replication status table
    EXEC dbo.sp_MSupdate_replication_status
        @publisher,
        @publisher_db,
        @publication,
        @agent_type = 2,
        @agent_name = @name,
        @status = 0     -- not running status


    COMMIT TRAN

    RETURN(0)

UNDO:
    if @@TRANCOUNT = 1
        ROLLBACK TRAN
    else
        COMMIT TRAN
    return(1)
GO

raiserror(15339,-1,-1,'sp_MSadd_publication')
go
CREATE PROCEDURE sp_MSadd_publication (
	@publisher sysname,
	@publisher_db sysname,
	@publication sysname,
	@publication_id int = 0,                    -- REMOVE
	@publication_type int = 1,                  -- 0 = Transactional 1 = Snapshot  2 = Merge
	@independent_agent bit = 0,
	@immediate_sync bit = 0,
	@allow_push bit = 1,
	@allow_pull bit = 0,
	@allow_anonymous bit = 0,
	@snapshot_agent nvarchar(100) = NULL,
	@logreader_agent nvarchar (100) = NULL,
	@description nvarchar(255) = NULL,
	@retention int =60,
	@vendor_name nvarchar(100) = 'Microsoft SQL Server',
	@sync_method int = 0,
	@allow_subscription_copy bit = 0,
	@thirdparty_options int = NULL,
 	@allow_queued_tran bit = 0,
 	@queue_type int = NULL
)
as
BEGIN
    set nocount on

	declare @thirdparty_flag bit                    -- 0 = SQL Server 1 = Third Party
			,@publisher_id smallint
			,@retcode int
			,@platform_nt binary
			,@platform_desktop int
			,@agentname nvarchar(100)
			,@max_distretention int

	select @platform_nt = 0x1
			,@platform_desktop = 0x100

    -- Check if publisher is a defined as a distribution publisher in the current database
    exec @retcode = dbo.sp_MSvalidate_distpublisher @publisher, @publisher_id OUTPUT
    if @retcode <> 0
    begin
        return(1)
    end

    EXEC @retcode = sp_helpdistributor @max_distretention = @max_distretention OUTPUT
    if @retcode <>0
    begin
    	return (1)
    end

    -- Get third party flag
    select @thirdparty_flag = thirdparty_flag from msdb..MSdistpublishers
        where UPPER(name) = UPPER(@publisher)
    
    /*
    ** Parameter Check: @publication. (For 3rd party publications.)
    ** The @publication name must conform to the rules for identifiers,
    ** and must not be the keyword 'all'.
    */

    IF @publication IS NULL
        BEGIN
            RAISERROR (14043, 16, -1, '@publication')
            RETURN (1)
        END

	exec @retcode = dbo.sp_MSreplcheck_name @publication
    if @@ERROR <> 0 or @retcode <> 0
        return(1)

    IF LOWER (@publication) = 'all'
        BEGIN
            RAISERROR (14034, 16, -1)
            RETURN (1)
        END


    -- Parameter Check: @publication_type
    -- Make sure that the publication type is one of the following:
    -- 0  transactional
    -- 1  snapshot
    -- 2  merge
    if @publication_type not in (0,1,2)
    begin
        raiserror(20033, 16, -1)
        return (1)
    end

	-- disable tran/queued publishing on Win9x
	if (@publication_type = 0 or @allow_queued_tran = 1) and (platform() & @platform_nt != @platform_nt)
	begin
		-- Note 21052 was deleted and then changed. This message should go into messages.sql post shiloh
		--raiserror(21052, 16, -1)
		raiserror('Distributor for transactional or queued publications has to run on Windows NT platforms only.', 16, 1)
		return (1)
	end

    if (@publication_type = 0) and (platform() & @platform_desktop = @platform_desktop)
    begin
        raiserror(21108, 16, -1)
        return (1)
    end

    -- Parameter Check: @immediate_sync
    -- The publication must support independent_agent to support immediate_sync
    if @immediate_sync = 1 and @independent_agent != 1
    begin
        raiserror(21022, 16, -1)
        return (1)
    end

    -- Parameter Check: @allow_anonymous
    -- The publication must support immediate_sync to support anonymous.
    if @allow_anonymous = 1 and @immediate_sync != 1
    begin
        raiserror(20011, 16, -1)
        return (1)
    end
    
    -- Make sure publication does not already exist
    if exists (select * from MSpublications where publication = @publication and
        publisher_id = @publisher_id and publisher_db = @publisher_db)
    begin
        if @thirdparty_flag = 1
        begin
            raiserror(14016, 16, -1, @publication)
            return (1)
        end
        else
        begin
            exec @retcode = dbo.sp_MSdrop_publication 
                @publisher = @publisher,
                @publisher_db = @publisher_db,
                @publication = @publication
            if @@error <> 0 or @retcode <> 0
                return (1)
        end
    end
 
 	--
 	-- For MSMQ queue type - Distributor needs to support MSMQ 2.0
 	--
 	if (@queue_type = 1 and @allow_queued_tran = 1)
 	begin
 		--
 		-- Now we use xp_MSver to detect NT OS version
 		-- MSMQ subscription only allowed for platforms that support MSMQ 2.0
 		-- version 5.0.2195 or higher
 		--
 		create table #tosversion ( propid int, propname sysname collate database_default, value int, charvalue nvarchar(255) collate database_default)
 		insert into #tosversion (propid, propname, value, charvalue)
 			exec master.dbo.xp_msver N'WindowsVersion'
 
 		declare @vervalue int
 			,@lobyte tinyint
 			,@hibyte tinyint
 			,@loword smallint
 			,@hiword smallint
 
 		--
 		-- low order byte of low order word = OSmajor, high order byte of low order word = OSminor
 		-- high order word = OSbuild
 		--
 		select @vervalue = value from #tosversion where propname = N'WindowsVersion'
 		select @loword = (@vervalue & 0xffff)
 				,@hiword = (@vervalue / 0x10000) & 0xffff
 		select @lobyte = @loword & 0xff
 				,@hibyte = (@loword / 100) & 0xff
 		drop table #tosversion
 
 		--
 		-- check for OS major version
 		--
 		if (@lobyte < 5)
 		begin
 			raiserror(21334, 16, 4, '2.0')
 			return (1)
 		end
 
 		--
 		-- check for OS build version
 		--
 		if (@lobyte = 5 and @hiword < 2195)
 		begin
 			raiserror(21334, 16, 5, '2.0')
 			return (1)
 		end
 	end
	
    begin tran
    save tran MSadd_publication

    insert into MSpublications values (@publisher_id, @publisher_db, @publication, 
        @publication_type, @thirdparty_flag, @independent_agent, @immediate_sync, @allow_push,
        @allow_pull, @allow_anonymous, @description, @vendor_name, @retention, 
		@sync_method, @allow_subscription_copy, @thirdparty_options, @allow_queued_tran)
    if @@error <> 0
        goto UNDO

    -- Enable the distribution cleanup agent if transactional or snapshot publicational
    if @publication_type = 0 or @publication_type = 1
    begin
		select @agentname = name from msdb..sysjobs j, msdb..sysjobsteps s where 
			j.job_id = s.job_id and
			j.category_id = 11 and
			s.database_name = db_name()

        exec @retcode = msdb.dbo.sp_update_job @job_name=@agentname, @enabled=1
        if @@error <> 0 or @retcode <> 0
            goto UNDO
    end

    -- Add snapshot and logreader agent
	
	-- Always add a non local snapshot agent. This is to cover the case
	-- when there's no SQLServerAgent job for the snapshot agent (For example, in Access).
	-- The agent entry is needed for initance check.
	-- sp_addpublication_snapshot will drop the entry and recreat it.
    exec @retcode = dbo.sp_MSadd_snapshot_agent
        @name = @snapshot_agent,
        @publisher = @publisher,
        @publisher_db = @publisher_db,
        @publication = @publication,
        @publication_type = @publication_type,
        @local_job = 0
    if @@error <> 0 or @retcode <> 0
        goto UNDO


    -- If null is passed in, we know that the agent is created already. (For SQL server).
    -- If not null is passed in, add the agents without creating local jobs (For third party).
    if @logreader_agent is not null
    begin
        exec @retcode = dbo.sp_MSadd_logreader_agent
            @name = @logreader_agent,
            @publisher = @publisher,
            @publisher_db = @publisher_db,
            @publication = @publication,
            @local_job = 0
        if @@error <> 0 or @retcode <> 0
            goto UNDO
    end

    -- If publisher_id, publisher_db pair is not in MSpublisher_databases then add it.  This will be used
    -- to store a publisher_database_id in the MSrepl_transactions and MSrepl_commands table.
    if not exists (select * from MSpublisher_databases where publisher_id = @publisher_id and
        publisher_db = @publisher_db)
    begin
        insert into MSpublisher_databases (publisher_id, publisher_db) values (@publisher_id, @publisher_db)
        if @@error <> 0
            goto UNDO
        insert into MSrepl_backup_lsns (publisher_database_id) values (@@identity)
        if @@error <> 0
            goto UNDO
    end

    commit tran

    return(0)

UNDO:
    if @@TRANCOUNT > 0
    begin
        ROLLBACK TRAN MSadd_publication
        COMMIT TRAN
    end
    return(1)
END
GO
 
/* 
**  History runstatus values defined in sqlrepl.h
**
**  Start       1
**  Succeed     2
**  Inprogress  3
**  Idle        4
**  Retry       5
**  Failure     6
*/
GO

raiserror(15339,-1,-1,'sp_MSrepl_raiserror')
go
create proc sp_MSrepl_raiserror
@agent sysname,
@agent_name nvarchar(100),
@status int,
@message nvarchar(255),
@subscriber sysname = NULL,
@publication sysname = NULL,
@article sysname = NULL
as
    if @status = 2      --Succeeded
        raiserror (14150, 10, -1, @agent, @agent_name, @message)
    else if @status = 5 --Retry Failure
        raiserror (14152, 10, -1, @agent, @agent_name, @message)
    else if @status = 6 --Failure
    begin
        raiserror (14151, 18, -1, @agent, @agent_name, @message)
    end
    else if @status = 7
    begin
        raiserror (20574, 10, -1, @subscriber, @article, @publication)
    end
    else if @status = 8
    begin
        raiserror (20575, 10, -1, @subscriber, @article, @publication)
    end
    else if @status = 9
    begin
        raiserror (14158, 10, -1, @agent, @agent_name, @message)
    end
go

raiserror(15339,-1,-1,'sp_MSget_new_errorid')
GO

CREATE PROCEDURE sp_MSget_new_errorid
@errorid int OUTPUT,
@xact_seqno varbinary(16) = NULL,
@command_id int = NULL
AS
    set nocount on

    SELECT @errorid = NULL

    BEGIN TRAN sp_MSget_new_errorid

    SET ROWCOUNT 1
    SELECT @errorid = id FROM MSrepl_errors (UPDLOCK PAGLOCK)
        ORDER BY id DESC
    SET ROWCOUNT 0

    IF @errorid IS NULL
        SELECT @errorid = 1
    ELSE
        SELECT @errorid = @errorid + 1

    INSERT INTO MSrepl_errors VALUES (@errorid, 
        GETDATE(), NULL, /* Error with type NULL is placeholder, refer to sp_MSget_repl_error */
        NULL, NULL, NULL, NULL, @xact_seqno, @command_id)

    /* return an 0 error_id if failed to insert the row */
    IF @@ERROR <> 0
        SELECT @errorid = 0

    SELECT @errorid

    COMMIT TRAN
GO   

raiserror(15339,-1,-1,'sp_MSadd_qreader_history')
go
CREATE PROCEDURE sp_MSadd_qreader_history (
	@agent_id int,
	@pubid int = NULL,
	@runstatus int, 
	@comments nvarchar(255) = NULL,
	@transaction_id nvarchar(40) = NULL,
	@transaction_status int = 0,
	@transactions_processed int =0,
	@commands_processed int = 0,
	@seconds_elapsed int = 0,
	@subscriber sysname = NULL,
	@subscriberdb sysname = NULL,
	@perfmon_increment bit = 1,
	@log_error bit = 0,
	@update_existing_row bit = 0,
	@do_raiserror bit = 1)
AS
BEGIN
	DECLARE @current_time datetime
			,@start_time datetime
			,@duration int
			,@agent_name nvarchar(100)
			,@publisher sysname
			,@publisher_db sysname
			,@publication sysname
			,@lastrow_timestamp timestamp
			,@retcode int
			,@cmdprocessed_rate float
			,@transaction_rate float
			,@error_id int
			,@idle int
			,@succeed int
			,@startup int
			,@retry int
			,@failure int
			,@inprogress int
			,@database sysname
			,@statobjid int
			,@agentclassname sysname

	--
	-- Status const defined in sqlrepl.h 
	--
	select @startup = 1
			,@succeed = 2
			,@inprogress = 3
			,@idle = 4
			,@retry = 5
			,@failure = 6

	-- intializations
	if (@pubid = 0)
		select @pubid = NULL
	if (@comments = '')
		select @comments = NULL
	if (@transaction_id = '')
		select @transaction_id = NULL
	if (@commands_processed is NULL)
		select @commands_processed = 0
	if (@subscriber = '')
		select @subscriber = NULL
	if (@subscriberdb = '')
		select @subscriberdb = NULL		

	SELECT @database = db_name()
			,@current_time = GETDATE()

	-- Get named information
	select @agent_name = name from MSqreader_agents where id = @agent_id
	if (@agent_name IS NULL)
	begin
		--
		-- When Queue reader is shutting down due to the last queued subscription
		-- being dropped it may happen that before the Queue reader logs the shutdown 
		-- message, the subscription drop process deletes the agent entry from MSqreader_agents
		--
		select @agent_name = quotename(@@servername) + '.' + cast(db_id() as nvarchar)
	end
	if (@pubid is NULL)
	begin
		select @publisher = NULL
				,@publisher_db = NULL
				,@publication = NULL
	end
	else
	begin
		select @publisher = a.srvname, @publisher_db = b.publisher_db, @publication = b.publication
		from master..sysservers a, MSpublications b
		where
		    b.publisher_id= @pubid and
		    b.publisher_id = a.srvid
	end

	-- Update Perfmon counter
	if @perfmon_increment = 1
	begin
		if @runstatus = @startup
			dbcc incrementinstance ("SQL Replication Agents", "Running", "QueueReader", 1)
		else if (@runstatus = @succeed or @runstatus = @retry or @runstatus = @failure)
			dbcc incrementinstance ("SQL Replication Agents", "Running", "QueueReader", -1)
	end

	-- Get start_time for latest agent run
	IF (@runstatus = @startup)
		SELECT @start_time = @current_time
	ELSE
	BEGIN
		SELECT TOP 1 @start_time = start_time, @lastrow_timestamp = timestamp
		FROM MSqreader_history (rowlock)
		WHERE 
		agent_id = @agent_id
		ORDER BY timestamp DESC

		if (@start_time is NULL)
		begin
			select @runstatus = @startup,
				@start_time = @current_time
		end
	END

	-- Calculate agent run duration
	SELECT @duration = DATEDIFF(second, @start_time, @current_time) 

	-- Calculate rate of processing
	IF (@seconds_elapsed IS NOT NULL and @seconds_elapsed > 0)
	BEGIN
		SELECT @cmdprocessed_rate = (@commands_processed * 1.0)/@seconds_elapsed
				,@transaction_rate = (@transactions_processed * 1.0)/@seconds_elapsed
	END
	ELSE
	BEGIN
		SELECT @cmdprocessed_rate = 0.0
				,@transaction_rate = 0.0
	END

	-- Set Perfmon counters
	if @runstatus = @idle or @runstatus = @inprogress
	begin
		dbcc addinstance ("SQL Replication QueueReader", @agent_name)
--		dbcc incrementinstance ("SQL Replication QueueReader", "QueueReader:Delivered Cmds/sec", @agent_name, @cmdprocessed_rate)
--		dbcc incrementinstance ("SQL Replication QueueReader", "QueueReader:Delivered Trans/sec", @agent_name, @transaction_rate)
	end

	--
	-- Set error id to 0 unless the user want to log errors associate with this 
	-- history message.
	--
	IF (@log_error = 1)
	begin
		select @runstatus = @failure
		EXEC dbo.sp_MSget_new_errorid @error_id OUTPUT
	end
	ELSE
		SELECT @error_id = 0	

	--
	-- @comments should contain message at all times
	--
	if (@comments is null)
		select @comments = N'no comment specified'
	
	-- Insert idle record or update if history record is already 'idle'
	IF (@runstatus = @idle or @update_existing_row = 1)
	begin
		-- Attempt to update the last row if it is IDLE
		UPDATE MSqreader_history 
		SET 	publication_id = @pubid,
				runstatus = @runstatus, 
				time = @current_time, 
				duration = @duration,
				comments = @comments,
				transaction_id = @transaction_id,
				transaction_status = @transaction_status,
				transactions_processed = @transactions_processed,
				commands_processed = @commands_processed,
				delivery_rate = @cmdprocessed_rate,
				transaction_rate = @transaction_rate,
				subscriber = @subscriber,
				subscriberdb = @subscriberdb,
				error_id = case @error_id when 0 then error_id else @error_id end
				WHERE
				agent_id = @agent_id and
				timestamp = @lastrow_timestamp and
				runstatus = @runstatus

		-- Insert idle record if there is not one
		if (@@ROWCOUNT = 0)
		begin
			INSERT INTO MSqreader_history(agent_id, publication_id, runstatus, start_time, time, 
					duration, comments, transaction_id, transaction_status, 
					transactions_processed, commands_processed, delivery_rate, 
					transaction_rate, subscriber, subscriberdb, error_id)
			VALUES(@agent_id, @pubid, @runstatus, @start_time, @current_time, 
					@duration, @comments, @transaction_id, @transaction_status,
					@transactions_processed, @commands_processed, @cmdprocessed_rate, 
					@transaction_rate, @subscriber, @subscriberdb, @error_id)
		end
	end
	else
	begin
		INSERT INTO MSqreader_history(agent_id, publication_id, runstatus, start_time, time, 
				duration, comments, transaction_id, transaction_status, 
				transactions_processed, commands_processed, delivery_rate,
				transaction_rate, subscriber, subscriberdb, error_id)
		VALUES(@agent_id, @pubid, @runstatus, @start_time, @current_time, 
				@duration, @comments, @transaction_id, @transaction_status, 
				@transactions_processed, @commands_processed, @cmdprocessed_rate, 
				@transaction_rate, @subscriber, @subscriberdb, @error_id)
	end

	--
	-- Update global replication agent status table
	--		
	exec @retcode = dbo.sp_MSupdate_replication_status 
		@@servername, 
		@database,
		@publication = 'ALL',
		@agent_type = 9,
		@agent_name = @agent_name,
		@status = @runstatus
	if (@retcode != 0 and @@error != 0)
		return 1

	-- Raise the appropriate error
	if (@do_raiserror = 1)
	begin
		select @agentclassname = formatmessage(14581)
		exec dbo.sp_MSrepl_raiserror @agentclassname, @agent_name, @runstatus, @comments
	end

	IF (@@ERROR != 0)
		RETURN (1)
END
GO   

raiserror(15339,-1,-1,'sp_MSadd_snapshot_history')
go
CREATE PROCEDURE sp_MSadd_snapshot_history (
	@agent_id int,
	@runstatus int, 
	@comments nvarchar(255),
	@delivered_transactions int = 0,    
	@delivered_commands int = 0,        
	@log_error bit = 0,
	@perfmon_increment bit = 1,
	@update_existing_row bit = 0,
	@do_raiserror bit = 1,
    @start_time_string nvarchar(25) = null
)
AS
BEGIN

	DECLARE @current_time datetime
			,@start_time datetime
			,@duration int
			,@delivery_rate float
			,@error_id int
			,@retcode int
			,@idle int
			,@succeed int
			,@startup int
			,@retry int
			,@failure int
			,@inprogress int
			,@lastrow_timestamp timestamp
			,@publisher sysname
			,@publisher_db sysname
			,@publication sysname
			,@agent_name nvarchar(100)
			,@perfmon_delivery_rate int
			,@agentclassname sysname

	/* 
	** Status const defined in sqlrepl.h 
	*/
	select @startup = 1
			,@succeed = 2
			,@inprogress = 3
			,@idle = 4
			,@retry = 5
			,@failure = 6
			,@current_time = GETDATE()

    -- Get named information 
    select @publisher = srvname, @publisher_db = publisher_db, @publication = publication,
        @agent_name = name from master..sysservers, MSsnapshot_agents where
        id = @agent_id and
        publisher_id = srvid

    -- Update Perfmon counter
    if @perfmon_increment = 1
    begin
        if @runstatus = @startup
            dbcc incrementinstance ("SQL Replication Agents", "Running", "Snapshot", 1)
        else if (@runstatus = @succeed or @runstatus = @retry or @runstatus = @failure)
            dbcc incrementinstance ("SQL Replication Agents", "Running", "Snapshot", -1)
    end

    /* Get start_time for latest agent run */
    IF @runstatus <> 1  -- Start status
    BEGIN
        
        IF @start_time_string IS NULL OR @start_time_string = N''
        BEGIN
            SELECT TOP 1 @start_time = start_time, @lastrow_timestamp = timestamp
                FROM MSsnapshot_history (rowlock)
                WHERE 
                agent_id = @agent_id
                ORDER BY timestamp DESC
        END
        ELSE
        BEGIN
            SELECT @start_time = @start_time_string
        END
    END
    ELSE
    BEGIN
        WAITFOR DELAY '000:00:01'
        SELECT @current_time = DATEADD(ms, CONVERT(INT, 1000.0 * (RAND(@@spid) + RAND() + RAND())/3.0), @current_time)
        SELECT @start_time = @current_time
    END
    /* Calculate agent run duration */
    SELECT @duration = DATEDIFF(second, @start_time, @current_time) 

    /* Calculate delivery_rate */
    IF @duration <> 0 
       SELECT @delivery_rate = (@delivered_commands * 1.0)/@duration 
    ELSE
       SELECT @delivery_rate = 0

    -- Set Perfmon counters
    if @runstatus = @idle or @runstatus = @inprogress
    begin
        dbcc addinstance ("SQL Replication Snapshot", @agent_name)
        dbcc incrementinstance ("SQL Replication Snapshot", "Snapshot:Delivered Cmds/sec", @agent_name, @delivered_commands)
		dbcc incrementinstance ("SQL Replication Snapshot", "Snapshot:Delivered Trans/sec", @agent_name, @delivered_transactions)
    end

    /* 
    ** Set error id to 0 unless the user want to log errors associate with this 
    ** history message.
    */
    SELECT @error_id = 0
    IF @log_error = 1
        -- Ignore errors here. @error_id will be set to 0 in case of errors  
        EXEC dbo.sp_MSget_new_errorid @error_id OUTPUT

    -- Insert idle record or update if history record is already 'idle'
    IF @runstatus = @idle or @update_existing_row = 1
    begin
        -- Attempt to update the last row if it is IDLE
        UPDATE MSsnapshot_history SET runstatus = @runstatus, time = @current_time, duration = @duration,
            comments = @comments,
            delivered_transactions = @delivered_transactions,
            delivered_commands = @delivered_commands,
            delivery_rate = @delivery_rate,
			error_id = case @error_id when 0 then error_id else @error_id end    
            WHERE
            agent_id = @agent_id and
            timestamp = @lastrow_timestamp and
            runstatus = @runstatus

        -- Insert idle record if there is not one
        if @@ROWCOUNT = 0
        begin
            INSERT INTO MSsnapshot_history VALUES (@agent_id, @runstatus, @start_time, 
            @current_time, @duration, @comments, @delivered_transactions, @delivered_commands, 
            @delivery_rate, @error_id, NULL)
        end
    end
    else
    begin
        INSERT INTO MSsnapshot_history VALUES (@agent_id, @runstatus, @start_time, 
            @current_time, @duration, @comments, @delivered_transactions, @delivered_commands, 
            @delivery_rate, @error_id, NULL)
    end

    -- Update global replication agent status table
    exec dbo.sp_MSupdate_replication_status 
        @publisher, 
        @publisher_db,
        @publication,
        @agent_type = 1,
        @agent_name = @agent_name,
        @status = @runstatus

	-- Raise the appropriate error
	if @do_raiserror = 1
	begin
		select @agentclassname = formatmessage(14551)
		exec dbo.sp_MSrepl_raiserror @agentclassname, @agent_name, @runstatus, @comments
	end

    IF @@ERROR <> 0
       RETURN (1)

    if @runstatus = 1
    begin
        select 'start_time' = convert(nvarchar(12), @start_time, 112) +
            substring(convert(nvarchar(24), @start_time, 121), 11, 13)
    end
END
GO   


raiserror(15339,-1,-1,'sp_MSadd_logreader_history')
go
CREATE PROCEDURE sp_MSadd_logreader_history (
	@agent_id int,
	@runstatus int,
	@comments nvarchar(255),
	@xact_seqno varbinary(16) = NULL,
	@delivery_time int = 0,                 -- Current delivery time (milliseconds)
	@delivered_transactions int = 0,        -- Running total of session
	@delivered_commands int = 0,            -- Running total of session
	@delivery_latency int = 0,              -- Current latency 
	@log_error bit = 0,
	@perfmon_increment bit = 1,
	@update_existing_row bit = 0,
	@do_raiserror bit = 1
)
AS
BEGIN

	DECLARE @current_time datetime
			,@start_time datetime
			,@duration int
			,@average_commands int
			,@delivery_rate float
			,@error_id int
			,@retcode int
			,@idle int
			,@succeed int
			,@startup int
			,@retry int
			,@inprogress int
			,@failure int
			,@lastrow_timestamp timestamp
			,@publisher sysname
			,@publisher_db sysname
			,@publication sysname
			,@agent_name nvarchar(100)
			,@last_delivered_commands int
			,@last_delivered_transactions int
			,@latest_delivered_commands int
			,@latest_delivered_transactions int
			,@latest_delivery_rate int
			,@last_delivery_rate int             -- int for perfmon
			,@last_delivery_latency int
			,@last_delivery_time int
			,@avg_delivery_rate float
			,@avg_delivery_latency int
			,@total_delivery_time int
			,@agentclassname sysname

	/* 
	** Status const defined in sqlrepl.h 
	*/
	select @startup = 1
			,@succeed = 2
			,@inprogress = 3
			,@idle = 4
			,@retry = 5
			,@failure = 6
			,@current_time = GETDATE()

    -- Update Perfmon counter
    if @perfmon_increment = 1
    begin
        if @runstatus = @startup
            dbcc incrementinstance ("SQL Replication Agents", "Running", "Logreader", 1)
        else if (@runstatus = @succeed or @runstatus = @retry or @runstatus = @failure)
            dbcc incrementinstance ("SQL Replication Agents", "Running", "Logreader", -1)
    end

    /* Get start_time for latest agent run */
    IF @runstatus <> 1  -- Startup status
    BEGIN
        SELECT TOP 1 @start_time = start_time, 
            @lastrow_timestamp = timestamp, 
            @last_delivered_commands = isnull(delivered_commands, 0),
            @last_delivered_transactions = isnull(delivered_transactions, 0),
            @last_delivery_latency = isnull(delivery_latency, 0),
            @last_delivery_time = isnull(delivery_time, 0),
            @last_delivery_rate = isnull(delivery_rate, 0)
        FROM MSlogreader_history (rowlock)
            WHERE agent_id = @agent_id
                ORDER BY timestamp DESC
    END
    ELSE
    BEGIN
        SELECT @start_time = @current_time
        SET @last_delivered_commands = 0
        SET @last_delivered_transactions = 0
        SET @last_delivery_latency = 0
        SET @last_delivery_time = 0
        SET @last_delivery_rate = 0
        SET @last_delivery_latency = 0
    END

    /* Use the current time if no corresponding start_up message logged */
    IF @start_time is NULL
       SELECT @start_time = @current_time

    -- Calculate number of transactions in this history
    set @latest_delivered_commands = @delivered_commands - @last_delivered_commands

    -- Calculate number of commands in this history
    set @latest_delivered_transactions = @delivered_transactions - @last_delivered_transactions

    /* Calculate agent run duration */
    SELECT @duration = DATEDIFF(second, @start_time, @current_time) 

    -- Calculate total delivery_time 
    if @latest_delivered_commands <> 0      -- Work around for Logreader passing in @delivery_time on shutdown.
        SELECT @total_delivery_time = @delivery_time + @last_delivery_time
    else
        SELECT @total_delivery_time = @last_delivery_time

    -- Calculate average delivery_rate of the session
    IF @latest_delivered_commands <> 0 and @total_delivery_time <> 0
    BEGIN
        SELECT @avg_delivery_rate = (@delivered_commands * 1.0)/(@total_delivery_time/1000.0)

        -- Current history delivery rate
        if @delivery_time <> 0
            SELECT @latest_delivery_rate = (@latest_delivered_commands * 1.0)/(@delivery_time/1000.0)
        else 
            SELECT @latest_delivery_rate = 0
    END
    ELSE
    BEGIN
        SELECT @avg_delivery_rate = @last_delivery_rate
        SELECT @latest_delivery_rate = 0
    END

    -- Calculate the average delivery_latency of the session
    if @latest_delivered_commands <> 0      -- Work around for Logreader passing in @delivery_latency on shutdown.
    BEGIN
        IF @delivery_latency <> 0
            IF @last_delivery_latency <> 0
                SELECT @avg_delivery_latency = (@delivery_latency + @last_delivery_latency)/2
            ElSE
                SELECT @avg_delivery_latency = @delivery_latency
        ELSE
            SELECT @avg_delivery_latency = 0
    END
    ELSE
    BEGIN
        SELECT @avg_delivery_latency = @last_delivery_latency

        -- Ignore latency value if no commands
        SELECT @delivery_latency = 0    
    END

    /*
    ** Calculate average number of commands per transaction
    */
    IF @delivered_commands <> 0
       SELECT @average_commands = @delivered_commands/@delivered_transactions
    ELSE

       SELECT @average_commands = 0

    -- Set Perfmon counters
    select @agent_name = name from MSlogreader_agents where id = @agent_id
    if @runstatus = @idle or @runstatus = @inprogress
    begin
        dbcc addinstance ("SQL Replication Logreader", @agent_name)
        dbcc incrementinstance ("SQL Replication Logreader", "Logreader:Delivered Trans/sec", @agent_name, @latest_delivered_transactions)
        dbcc incrementinstance ("SQL Replication Logreader", "Logreader:Delivered Cmds/sec", @agent_name, @latest_delivered_commands)
        dbcc setinstance ("SQL Replication Logreader", "Logreader:Delivery Latency", @agent_name, @delivery_latency)
    end
    else
    begin
        dbcc addinstance ("SQL Replication Logreader", @agent_name)
        dbcc setinstance ("SQL Replication Logreader", "Logreader:Delivery Latency", @agent_name, 0)
    end

    /* 
    ** Set error id to 0 unless the user want to log errors associate with this 
    ** history message.
    */
    SELECT @error_id = 0
    IF @log_error = 1
        -- Ignore errors here. @error_id will be set to 0 in case of errors  
        EXEC dbo.sp_MSget_new_errorid @error_id OUTPUT

    -- Insert idle record or update if history record is already 'idle'
    IF @runstatus = @idle or @update_existing_row = 1
    begin
        -- Attempt to update the last row if it is IDLE
        if (@runstatus = @idle)
        begin
            UPDATE MSlogreader_history SET runstatus = @runstatus, time = @current_time,
            duration = @duration,comments = @comments,
			error_id = case @error_id when 0 then error_id else @error_id end
            WHERE
            agent_id = @agent_id and
            timestamp = @lastrow_timestamp and
            ( runstatus = @runstatus or 
            (@update_existing_row = 1 and runstatus in (@idle, @inprogress) and @runstatus in (@idle, @inprogress)) )
        end
        else
        begin
            UPDATE MSlogreader_history SET runstatus = @runstatus, start_time = @start_time, 
            time = @current_time,
            duration = @duration, comments = @comments,
            xact_seqno = @xact_seqno,
            delivery_time = @total_delivery_time,
            delivered_transactions = @delivered_transactions,
            delivered_commands = @delivered_commands,
            average_commands = @average_commands,
            delivery_rate = @avg_delivery_rate,
            delivery_latency = @avg_delivery_latency,
			error_id = case @error_id when 0 then error_id else @error_id end
			WHERE
            agent_id = @agent_id and
            timestamp = @lastrow_timestamp and
            ( runstatus = @runstatus or 
            (@update_existing_row = 1 and runstatus in (@idle, @inprogress) and @runstatus in (@idle, @inprogress)) )
        end

        -- Insert idle record if there is not one
        if @@ROWCOUNT = 0
        begin
            -- Use last values because nothing was done
            INSERT INTO MSlogreader_history VALUES (@agent_id, @runstatus, @start_time, @current_time, 
                @duration, @comments,  
                @xact_seqno, @last_delivery_time, @delivered_transactions, @delivered_commands,
                @average_commands, @avg_delivery_rate, @last_delivery_latency, @error_id, NULL)
        end
    end
    else
    begin
        INSERT INTO MSlogreader_history VALUES (@agent_id, @runstatus, @start_time, @current_time, 
            @duration, @comments, 
            @xact_seqno, @total_delivery_time, @delivered_transactions, @delivered_commands,
            @average_commands, @avg_delivery_rate, @avg_delivery_latency, @error_id, NULL)
    end

    -- Get named information 
    select @publisher = srvname, @publisher_db = publisher_db, @publication = publication,
        @agent_name = name from master..sysservers, MSlogreader_agents where
        id = @agent_id and
        publisher_id = srvid

    -- Update global replication agent status table
    exec dbo.sp_MSupdate_replication_status 
        @publisher, 
        @publisher_db,
        @publication = 'ALL',
        @agent_type = 2,
        @agent_name = @agent_name,
        @status = @runstatus

	-- Raise the appropriate error
	if @do_raiserror = 1
	begin
		select @agentclassname = formatmessage(14552)
		exec dbo.sp_MSrepl_raiserror @agentclassname, @agent_name, @runstatus, @comments
	end

    IF @@ERROR <> 0
    BEGIN
       RETURN (1)
    END
END
GO      

raiserror(15339,-1,-1,'sp_MSadd_distribution_history')
go
CREATE PROCEDURE sp_MSadd_distribution_history (
	@agent_id int,
	@runstatus int, 
	@comments nvarchar(255),
	@xact_seqno binary(16) = 0x00,      -- We use binary(16)to pad it out for the below compare
	@delivered_transactions int = 0,        -- Running total for the session
	@delivered_commands int = 0,            -- Running total for the session
	@delivery_rate float = 0,               -- Last rate (cmds/sec)
	@log_error bit = 0,
	@perfmon_increment bit = 1,
	@xactseq varbinary(16) = NULL,      
	@command_id int = NULL,
	@update_existing_row bit = 0,
	@updateable_row bit = 1,		-- used to override history verbose level to decide
									-- whether the row being added can be updated by another.	
	@do_raiserror bit = 1
)
AS
BEGIN

	set nocount on

	DECLARE @current_time datetime
			,@start_time datetime
			,@entry_time datetime
			,@duration int                   -- milliseconds
			,@delivery_latency int
			,@average_commands int
			,@total_cmds int
			,@publisher_id smallint
			,@publisher_db sysname
			,@publication sysname
			,@publisher sysname
			,@subscriber_id smallint
			,@subscriber sysname
			,@subscriber_db sysname
			,@article sysname
			,@article_id int
			,@publication_id int
			,@publisher_database_id int

			,@agent_name nvarchar(100)
			,@error_id int 
			,@startup int
			,@succeed int
			,@inprogress int
			,@retry int
			,@failure int
			,@validation_failure int
			,@validation_success int, @error_skipped int
			,@requested_shutdown int
			,@raiserror_status int
			,@idle int
			,@lastrow_timestamp timestamp
			,@lastrow_xact_seqno binary(16)
			,@new_delivered_commands int
			,@new_delivered_transactions int
			,@retcode int
			,@last_delivery_rate float
			,@last_delivery_latency int
			,@avg_delivery_rate float
			,@avg_delivery_latency int
			,@perfmon_delivery_rate int
			,@existing_row_updateble bit
			,@this_row_updateable bit
			,@agentclassname sysname
			,@MAXINT int

	/* 
	** Status const defined in sqlrepl.h 
	*/
	select @startup = 1
			,@succeed = 2
			,@inprogress = 3
			,@idle = 4
			,@retry = 5
			,@failure = 6
			,@validation_failure = 7
			,@validation_success = 8
			,@requested_shutdown = 9
			,@error_skipped = 10
			,@MAXINT = 2147483647

    -- To prevent cleanup up being messed up by invalid history message, only log
    -- valid history message. 
    if @runstatus > 10 or @runstatus < 1
    begin
        --Invalid history message logged
        RAISERROR (21079, 16, -1, @runstatus)
        return (1)
    end

    select @existing_row_updateble = 1
    select @this_row_updateable = 1

    select @raiserror_status = @runstatus
    if (@runstatus = @validation_failure or @runstatus = @validation_success 
		or @runstatus = @requested_shutdown or @runstatus = @error_skipped)
    begin
        select @runstatus = @inprogress
        select @this_row_updateable = 0
    end

	if (@updateable_row = 0)
	begin
		select @this_row_updateable = 0
	end
    
    -- Security Check
    exec @retcode = dbo.sp_MScheck_pull_access
        @agent_id = @agent_id,
        @agent_type = 0 -- distribution agent
    if @@error <> 0 or @retcode <> 0
        return (1)

    SELECT @current_time = GETDATE()

    -- Update Perfmon counter
    if @perfmon_increment = 1
    begin
        if @runstatus = @startup
            dbcc incrementinstance ("SQL Replication Agents", "Running", "Distribution", 1)
        else if (@runstatus = @succeed or @runstatus = @retry or @runstatus = @failure)
            dbcc incrementinstance ("SQL Replication Agents", "Running", "Distribution", -1)
    end

    -- Get agent name, publisher id and publisher_db
    select @agent_name = name, 
        @publisher_database_id = publisher_database_id,
        @publisher_id = publisher_id, @publisher_db = publisher_db,
        @publication =  publication, @subscriber_id = subscriber_id, @subscriber_db = subscriber_db
        from MSdistribution_agents
        where id = @agent_id
    select @publisher = srvname from master..sysservers where srvid = @publisher_id
    select @subscriber = srvname from master..sysservers where srvid = @subscriber_id

    /* Get start_time and xact_seqno for latest agent run */
    IF @runstatus <> 1   
    BEGIN
          
        SELECT TOP 1 
            @lastrow_xact_seqno = xact_seqno,
            @start_time = start_time, 
            @total_cmds = total_delivered_commands,
            @lastrow_timestamp = timestamp, 
            @new_delivered_transactions = @delivered_transactions - delivered_transactions,
            @new_delivered_commands = @delivered_commands - delivered_commands,
            @last_delivery_rate = delivery_rate,
            @last_delivery_latency = delivery_latency,
            @existing_row_updateble = updateable_row
        FROM MSdistribution_history (rowlock)
            WHERE agent_id = @agent_id 
            ORDER BY timestamp  DESC

        /* 
        ** Check the case where the user did not pass in the proper values
        ** for delivered commands and transactions (this leads to negative
        ** new command/tran counts).
        */
        if ( @new_delivered_commands < 0)
            SELECT @new_delivered_commands = 0

        if ( @new_delivered_transactions < 0 )
            SELECT @new_delivered_transactions = 0

    END
    ELSE
    BEGIN
        -- At least get running total of commands over all sessions.
        SELECT TOP 1 
            @lastrow_xact_seqno = xact_seqno,
            @total_cmds = total_delivered_commands
            FROM MSdistribution_history  (rowlock)
            WHERE agent_id = @agent_id
            ORDER BY timestamp  DESC
        SELECT @start_time = @current_time
        SELECT @new_delivered_commands = @delivered_commands
        SELECT @new_delivered_transactions = @delivered_transactions
        SELECT @last_delivery_rate = 0
        SELECT @last_delivery_latency = 0
    END

    IF @total_cmds IS NULL
        SELECT @total_cmds = 0

    /* Use the current time if no corresponding start_up message logged */
    IF @start_time is NULL
       SELECT @start_time = @current_time

    /* Calculate agent run duration */
    SELECT @duration = DATEDIFF(second, @start_time, @current_time) 
    
    IF @delivered_commands <> 0
       SELECT @average_commands = @delivered_commands/@delivered_transactions
    ELSE
       SELECT @average_commands = 0

    -- Get the entry time of the last distributed transaction
    if @xact_seqno <> 0x00 and @new_delivered_commands <> 0
        -- SELECT @entry_time = entry_time FROM MSrepl_transactions (READPAST)
        SELECT @entry_time = entry_time FROM MSrepl_transactions 
           WHERE xact_seqno = @xact_seqno and
                publisher_database_id = @publisher_database_id

    -- Calculate the latency of the last distributed transaction
    IF @entry_time IS NOT NULL
	begin
	   -- Calculte diff in minutes.
	   declare @diff_min int
	   select @diff_min = DATEDIFF(minute, @entry_time, @current_time)
	   if @diff_min > 16666
			select @delivery_latency = 999999999
       else 
			select @delivery_latency = DATEDIFF(millisecond, @entry_time, @current_time)
	end
    ELSE
       SELECT @delivery_latency = 0

    -- Calculate the average delivery latency of the session
    IF @last_delivery_latency = 0
        SET @avg_delivery_latency = @delivery_latency
    ELSE IF @delivery_latency = 0
        SET @avg_delivery_latency = @last_delivery_latency
    ELSE
        SET @avg_delivery_latency = (@delivery_latency + @last_delivery_latency)/2

    -- Calculate average delivery rate of the session

    IF @last_delivery_rate = 0
        SET @avg_delivery_rate = @delivery_rate
    ELSE IF @delivery_rate = 0 or @new_delivered_commands = 0
        SET @avg_delivery_rate = @last_delivery_rate
    ELSE
        SET @avg_delivery_rate = (@delivery_rate + @last_delivery_rate)/2.0     

	/* Calculate grand total of delivered trans across sessions, check
	** to make sure the result does not overflow integer column  
	*/
    if (@total_cmds > @MAXINT  - @new_delivered_commands)
		SET @total_cmds = @MAXINT
	else
		SET @total_cmds = @total_cmds + @new_delivered_commands

    -- Set Perfmon counters
    if @runstatus = @idle or @runstatus = @inprogress
    begin
        dbcc addinstance ("SQL Replication Distribution", @agent_name)
        dbcc incrementinstance ("SQL Replication Distribution", "Dist:Delivered Trans/sec", @agent_name, @new_delivered_transactions)
        dbcc incrementinstance ("SQL Replication Distribution", "Dist:Delivered Cmds/sec", @agent_name, @new_delivered_commands)
        dbcc setinstance ("SQL Replication Distribution", "Dist:Delivery Latency", @agent_name, @delivery_latency)
    end
    else
    begin /* Reset latency counter */
        dbcc addinstance ("SQL Replication Distribution", @agent_name)
        dbcc setinstance ("SQL Replication Distribution", "Dist:Delivery Latency", @agent_name, 0)
    end

    /* 
    ** Set error id to 0 unless the user want to log errors associate with this 
    ** history message.
    */
    SELECT @error_id = 0
    IF @log_error = 1
        -- Ignore errors here. @error_id will be set to 0 in case of errors  
        EXEC dbo.sp_MSget_new_errorid @error_id OUTPUT, @xactseq, @command_id
    
    -- @xact_seqno may be uninitialized for the first several messages after
    -- the start-up of the distribtion agent. Get the correct value in that case. 
    -- We must do this because distribution cleanup will use the lastest xact_seqno
    -- as cleanup boundary.
    -- Note: @last_xact_seqno might be NULL
    -- Only do this if @xact_seqno is 0, since a smaller xact_seqno might be logged due
    -- to reinited sub for immediate_sync pub.
    -- This will prevent history being messed up by one gabage history entry.
    if @xact_seqno = 0x00 and @lastrow_xact_seqno is not null
        select @xact_seqno = @lastrow_xact_seqno 

    -- Insert idle record or update if history record is already 'idle'
    IF (@existing_row_updateble = 1) and (@runstatus = @idle or @update_existing_row = 1)
    begin

        -- Attempt to update the last row if it is IDLE
        if (@runstatus = @idle)
        begin
            UPDATE MSdistribution_history SET runstatus = @runstatus, time = @current_time,
            duration = @duration, comments = @comments,
            xact_seqno = @xact_seqno, updateable_row = @this_row_updateable,
			error_id = case @error_id when 0 then error_id else @error_id end
            WHERE
            agent_id = @agent_id and
            timestamp = @lastrow_timestamp and
            ( runstatus = @runstatus or 
            (@update_existing_row = 1 and runstatus in (@idle, @inprogress) and @runstatus in (@idle, @inprogress)) )
        end
        else
        begin
            -- Attempt to update the last row if it is IDLE
            UPDATE MSdistribution_history SET runstatus = @runstatus, start_time = @start_time,
                time = @current_time,
                duration = @duration,
                xact_seqno = @xact_seqno,
                comments = @comments,
                delivered_transactions = @delivered_transactions,
                delivered_commands = @delivered_commands,
                average_commands = @average_commands,
                delivery_rate = @avg_delivery_rate,
                delivery_latency = @avg_delivery_latency,
                total_delivered_commands = @total_cmds,
                current_delivery_rate = @delivery_rate,
                current_delivery_latency = @delivery_latency,
                updateable_row = @this_row_updateable,
				error_id = case @error_id when 0 then error_id else @error_id end
                WHERE
                agent_id = @agent_id and
                timestamp = @lastrow_timestamp and
                ( runstatus = @runstatus or 
                (@update_existing_row = 1 and runstatus in (@idle, @inprogress) and @runstatus in (@idle, @inprogress)) )
        end
    
        -- Insert idle record if there is not one
        if @@ROWCOUNT = 0
        begin
            INSERT INTO MSdistribution_history (agent_id, runstatus, start_time, time, duration, comments, xact_seqno,
                delivered_transactions, delivered_commands, average_commands, delivery_rate, delivery_latency,
                total_delivered_commands, error_id, timestamp, current_delivery_rate, current_delivery_latency, updateable_row)
            VALUES (@agent_id, @runstatus, @start_time, @current_time, 
                @duration, @comments, @xact_seqno, @delivered_transactions, 
                @delivered_commands, @average_commands, @avg_delivery_rate,
                @avg_delivery_latency, @total_cmds, @error_id, NULL, @delivery_rate, @delivery_latency, @this_row_updateable)
        end
    end
    else
    begin
        INSERT INTO MSdistribution_history (agent_id, runstatus, start_time, time, duration, comments, xact_seqno,
                delivered_transactions, delivered_commands, average_commands, delivery_rate, delivery_latency,
                total_delivered_commands, error_id, timestamp, current_delivery_rate, current_delivery_latency, updateable_row)
        VALUES (@agent_id, @runstatus, @start_time, @current_time, 
            @duration, @comments, @xact_seqno, @delivered_transactions, 
            @delivered_commands, @average_commands, @avg_delivery_rate,
            @avg_delivery_latency, @total_cmds, @error_id, NULL, @delivery_rate, @delivery_latency, @this_row_updateable)
    end

	-- Refresh repl monitor
	declare @agent_type int
	set @agent_type = dbo.fn_MSmask_agent_type (@agent_id, 3)

    -- Update global replication agent status table
    exec dbo.sp_MSupdate_replication_status 
        @publisher, 
        @publisher_db,
        @publication,
        @agent_type = @agent_type,
        @agent_name = @agent_name,
        @status = @runstatus

    if (@raiserror_status = @validation_failure or @raiserror_status = @validation_success or
		@raiserror_status = @error_skipped)
    begin
        -- Get the "real" publication name (as opposed to 'ALL') and article name
        select @article_id = article_id from MSrepl_commands
        where publisher_database_id = @publisher_database_id
        and xact_seqno = @xactseq
        and command_id = @command_id
    
        select @publication = mp.publication, @publication_id = mp.publication_id
        from MSpublications as mp, MSsubscriptions as ms
        where mp.publisher_id = ms.publisher_id
        and mp.publisher_db = ms.publisher_db
        and mp.publication_id = ms.publication_id
        and ms.publisher_id = @publisher_id
        and ms.publisher_db = @publisher_db
        and ms.subscriber_id = @subscriber_id
        and ms.subscriber_db = @subscriber_db
        and ms.article_id = @article_id

        select @article = article
        from MSarticles
        where article_id = @article_id
        and publisher_id = @publisher_id
        and publisher_db = @publisher_db
        and publication_id = @publication_id
    end

	-- Raise the appropriate error
	if @do_raiserror = 1
	begin
		select @agentclassname = formatmessage(14553)
		exec dbo.sp_MSrepl_raiserror @agentclassname, @agent_name, @raiserror_status, @comments, @subscriber=@subscriber, @publication=@publication, @article=@article
	end
    
    IF @@ERROR <> 0
       RETURN (1)
END
GO   

raiserror(15339,-1,-1,'sp_MSsubscription_cleanup')
GO
CREATE PROCEDURE sp_MSsubscription_cleanup
    @cutoff_time datetime
as
begin
    set nocount on
	
	declare @ACTIVE 	tinyint,
    		@INACTIVE 	tinyint,
    		@SUBSCRIBED tinyint,
    		@VIRTUAL 	smallint

    declare @retcode 		int,
			@max_time 		datetime,
			@agent_id 		int,
		    @num_dropped 	int

    select @ACTIVE 				= 2
    select @INACTIVE 			= 0
    select @SUBSCRIBED 			= 1
    select @VIRTUAL 			= -1

    select @max_time = dateadd(hour, 1, getdate())

    -- Refer to sp_MSmaximun_cleanup_xact_seqno to understand the logic
    -- in this sp. If you change the logic here, you may need to change
    -- that sp as well.

    -- Deactivate real subscriptions for agents that are working on 
    -- transactions that are older than @retention
    -- update all the subscriptions for those agents, including
    -- subscriptions that are in subscribed state!
    update MSsubscriptions  
        set status = @INACTIVE 
        where agent_id in (
						select derivedInfo.agent_id 
							from (
								-- Here we are retrieving the agent id, publisher database id, 
								-- min subscription sequence number, and the transaction seqno 
								-- related to the max timestamp row in the history table. this is
								-- important since the tran seqno can go back to lower values in 
								-- the case of reinit with immediate sync.
								select s.agent_id as agent_id,
									s.publisher_database_id as publisher_database_id,
									min(s.subscription_seqno) as subscription_seqno,
									isnull(h.xact_seqno, 0x0) as xact_seqno
								from MSsubscriptions s
									left join (MSdistribution_history h (REPEATABLEREAD)
											join (select agent_id, 
														max(timestamp) as timestamp
													from MSdistribution_history (REPEATABLEREAD)
													group by agent_id) as h2 
												on h.agent_id = h2.agent_id 
													and h.timestamp = h2.timestamp)
										on s.agent_id = h.agent_id
								where s.status = @ACTIVE                       
									and s.subscriber_id >= 0 	-- Only well-known agent
								group by s.agent_id,            -- agent and pubdbid as a pair can never be differnt
									s.publisher_database_id,      
									isnull(h.xact_seqno, 0x0)	-- because of join above we can include this
								) derivedInfo
							where @cutoff_time >= (
								                -- Get the entry_time of the first tran that cannot be
								                -- cleaned up normally because of this agent.
								                -- Use history if it's larger and it is not null (exists)
								                case  when derivedInfo.xact_seqno >= derivedInfo.subscription_seqno 
								                then
													-- Have to join with commands table because transactions that
													-- does not have commands will not be picked up by
													-- sp_MSget_repl_commands
								                    isnull((select top 1 entry_time 
																from MSrepl_transactions t,
																	MSrepl_commands c 
																where t.publisher_database_id = derivedInfo.publisher_database_id
								                        				and c.publisher_database_id = derivedInfo.publisher_database_id
																		and c.xact_seqno = t.xact_seqno 
																		-- history xact_seqno can be cleaned up
																		and t.xact_seqno > isnull(derivedInfo.xact_seqno,0x0)
								                        				and c.xact_seqno > isnull(derivedInfo.xact_seqno,0x0)
								                        		order by t.xact_seqno asc), @max_time)
								                else
								                    isnull((select top 1 entry_time 
																from MSrepl_transactions t,
																	MSrepl_commands c 
																where t.publisher_database_id = derivedInfo.publisher_database_id 
																	and c.publisher_database_id = derivedInfo.publisher_database_id 
																	and c.xact_seqno = t.xact_seqno 
																	-- sub xact_seqno cannot be cleaned up
																	and t.xact_seqno >= derivedInfo.subscription_seqno 
																	and c.xact_seqno >= derivedInfo.subscription_seqno				
								                        		order by t.xact_seqno asc), @max_time)
								                end))

    if @@rowcount <> 0
        RAISERROR(21011, 10, -1) 

    -- Dropping all the aonymous agents that are working on
    -- transactions that are older than @retention
    -- No message raised.
	-- Don't drop agents that do not have history (true for new agents).
    -- For each publisher/publisherdb pair do cleanup
    declare hC CURSOR LOCAL FAST_FORWARD FOR 
		select distinct derivedInfo.agent_id 
			from (
				-- Here we are retrieving the agent id, publisher database id, 
				-- min subscription sequence number, and the transaction seqno 
				-- related to the max timestamp row in the history table. this is
				-- important since the tran seqno can go back to lower values in 
				-- the case of reinit with immediate sync.
				select msda.id as agent_id,
						msda.publisher_database_id as publisher_database_id,
						min(s.subscription_seqno) as subscription_seqno, 
						h.xact_seqno as xact_seqno
					from MSsubscriptions s 
						join MSdistribution_agents msda
							on s.agent_id = msda.virtual_agent_id 
						join (MSdistribution_history h (REPEATABLEREAD)
								join (select agent_id,
											max(timestamp) as timestamp
										from MSdistribution_history (REPEATABLEREAD)
										group by agent_id) as h2
									on h.agent_id = h2.agent_id
										and h.timestamp = h2.timestamp)
							on msda.id = h.agent_id
					where s.status = @ACTIVE                			
					group by msda.id, 						-- agent and pubdbid as a pair can never be differnt
						msda.publisher_database_id, 
						h.xact_seqno
				) derivedInfo
       		where @cutoff_time >= (
				                -- Get the entry_time of the first tran that cannot be
				                -- cleaned up normally because of this agent.
				                -- Use history if it's larger and it is not null (exists)
				                case  when derivedInfo.xact_seqno > 0x00
				                then
									-- does not have commands will not be picked up by
									-- sp_MSget_repl_commands
				                    isnull((select top 1 entry_time 
												from MSrepl_transactions t,
													MSrepl_commands c 
												where t.publisher_database_id = derivedInfo.publisher_database_id
													and c.publisher_database_id = derivedInfo.publisher_database_id
													and c.xact_seqno = t.xact_seqno 
													-- history xact_seqno can be cleaned up
													and t.xact_seqno > derivedInfo.xact_seqno 
													and c.xact_seqno > derivedInfo.xact_seqno
												order by t.xact_seqno asc), @max_time)
				                else
				                    isnull((select top 1 entry_time 
												from MSrepl_transactions t,
													MSrepl_commands c 
												where t.publisher_database_id = derivedInfo.publisher_database_id 
													and c.publisher_database_id = derivedInfo.publisher_database_id 
													and c.xact_seqno = t.xact_seqno
													-- sub xact_seqno cannot be cleaned up
													and t.xact_seqno >= derivedInfo.subscription_seqno 
													and c.xact_seqno >= derivedInfo.subscription_seqno
												order by t.xact_seqno asc), @max_time)
				             	end)
    for read only
	select @num_dropped = 0
    open hC
    fetch hC into @agent_id
    while (@@fetch_status <> -1)
    begin
		exec @retcode = dbo.sp_MSdrop_distribution_agentid @agent_id
		if @retcode <> 0 or @@error <> 0
			return (1)
		select @num_dropped = @num_dropped + 1
	    fetch hC into @agent_id
	end
	if @num_dropped > 0
        RAISERROR(20597, 10, -1, @num_dropped) 

    -- Deactivating subscriptions virtual subscriptions that are older then @retention.
    update MSsubscriptions  
		set status = @SUBSCRIBED
		-- Only change active subscriptions!
        where status = @ACTIVE
	        and subscriber_id = @VIRTUAL 
			-- Get the entry_time of the first tran that cannot be
	        -- cleaned up normally because of this subscription.
			and @cutoff_time >= isnull((select top 1 entry_time 
											from MSrepl_transactions t 
											where t.publisher_database_id = MSsubscriptions.publisher_database_id 
												and xact_seqno >= MSsubscriptions.subscription_seqno
					                		order by t.xact_seqno asc), @max_time)
	if @@rowcount <> 0
    	RAISERROR(21077, 10, -1)
end
GO

raiserror(15339,-1,-1,'sp_MSreplremoveuncdir')
GO
CREATE PROCEDURE sp_MSreplremoveuncdir
@dir nvarchar(260)
as

    set nocount on

    declare @retcode int
	declare @local_dir nvarchar(260)
	declare @cmd nvarchar(1000)
	declare @machinename sysname
    /* 
    ** We have to convert UNC to drive, otherwise will get 'Access denied' error in xp_cmdshell
    */
	select @machinename = convert(sysname, SERVERPROPERTY('machinename'))
    EXEC @retcode = master.dbo.sp_MSunc_to_drive @unc_path = @dir, 
        @local_server = @machinename, @local_path = @local_dir OUTPUT
    IF @retcode <> 0 or @@ERROR <> 0 
        RETURN(1)

    /*
    ** Delete directory in the distributor's directory.
    ** On Win9x, we have to use deltree instead
    */
    declare @platform_nt int 
    select @platform_nt = 0x1
    IF (( platform() & @platform_nt = @platform_nt))
    BEGIN 
        SELECT @cmd = 'if exist "' + fn_escapecmdshellsymbolsremovequotes(@local_dir) collate database_default + '" rmdir /S /Q ' + '"' + fn_escapecmdshellsymbolsremovequotes(@local_dir) collate database_default + '"'
    END
    ELSE
    BEGIN
        -- Don't need if exists check on Win9x but we do need 
        -- to remove the trailing slash
        IF SUBSTRING(@local_dir, LEN(@local_dir), 1) = N'\'
        BEGIN
            SELECT @local_dir = LEFT(@local_dir, LEN(@local_dir)-1)
        END
        SELECT @cmd = 'deltree /Y ' + '"' + fn_escapecmdshellsymbolsremovequotes(@local_dir) collate database_default + '"'
    END

    EXECUTE  @retcode = master..xp_cmdshell @cmd, NO_OUTPUT
    IF @retcode <> 0 or @@ERROR <> 0 
	begin
		raiserror(20015, 16, -1, @dir)
        RETURN(1)
	end
go

raiserror(15339,-1,-1,'sp_MSdrop_snapshot_dirs')
GO
CREATE PROCEDURE sp_MSdrop_snapshot_dirs
as
	declare @retcode int
    declare @snapshot_bit int
    declare @directory_type int
    declare @alt_directory_type int
    declare @publisher_database_id int
		
    declare @dir nvarchar(512)
	declare @command_id int
	declare @xact_seqno varbinary(16)
    
	select @snapshot_bit = 0x80000000
    select @directory_type = 7
    select @alt_directory_type = 25

	declare  hCdirs  CURSOR LOCAL FAST_FORWARD FOR select CONVERT(nvarchar(512), command),
		xact_seqno, command_id, publisher_database_id
		from MSrepl_commands where
		((type & ~@snapshot_bit) = @directory_type) or
        ((type & ~@snapshot_bit) = @alt_directory_type)
	for read only

    open hCdirs
    fetch hCdirs into @dir, @xact_seqno, @command_id, @publisher_database_id
    while (@@fetch_status <> -1)
    begin
 		-- Need to map unc to local drive for access problem
        exec @retcode = dbo.sp_MSreplremoveuncdir @dir
        /* Abort the operation if the delete fails */
        if (@retcode <> 0 or @@error <> 0)
            return (1)

		delete MSrepl_commands where 
			publisher_database_id = @publisher_database_id and
			xact_seqno = @xact_seqno and
			command_id = @command_id

	    fetch hCdirs into @dir, @xact_seqno, @command_id, @publisher_database_id
    end
    close hCdirs
    deallocate hCdirs
GO

raiserror(15339,-1,-1,'sp_MSfast_delete_trans')
GO
CREATE PROCEDURE sp_MSfast_delete_trans
as
	declare @retcode int

	EXEC @retcode = sp_MSdrop_snapshot_dirs
	if( @retcode <> 0 or @@error <> 0 )
		return 1

	truncate table MSrepl_commands
	truncate table MSrepl_transactions

GO

raiserror(15339,-1,-1,'sp_MSdelete_dodelete')
go
-- New delete stored procedure WITH RECOMPILE
CREATE PROCEDURE sp_MSdelete_dodelete
	@publisher_database_id int,
	@max_xact_seqno varbinary(16),
	@last_xact_seqno varbinary(16),
	@last_log_xact_seqno varbinary(16)
WITH RECOMPILE
	as
		delete MSrepl_transactions WITH (PAGLOCK) from MSrepl_transactions where
				publisher_database_id = @publisher_database_id and
				xact_seqno <= @max_xact_seqno and
				xact_seqno <> @last_xact_seqno and
				xact_seqno <> @last_log_xact_seqno and
				-- use nolock to avoid deadlock
				not exists (select * from MSrepl_commands c (nolock) where
					c.publisher_database_id = @publisher_database_id and
					c.xact_seqno = MSrepl_transactions.xact_seqno)
GO

raiserror(15339,-1,-1,'sp_MSdelete_publisherdb_trans')
GO
CREATE PROCEDURE sp_MSdelete_publisherdb_trans
    @publisher_database_id int,
    @max_xact_seqno varbinary(16),
	@max_cutoff_time datetime,
    @num_transactions int OUTPUT,
    @num_commands int OUTPUT
    as

	set nocount on
    
	declare @snapshot_bit int
	declare @replpost_bit int
    declare @directory_type int
    declare @alt_directory_type int
    declare @scriptexec_type int
    declare @last_xact_seqno varbinary(16)
    declare @last_log_xact_seqno varbinary(16)
    declare @max_immediate_sync_seqno varbinary(16)
    declare @dir nvarchar(512)
    declare @row_count int
    declare @batchsize int
    declare @retcode int            /* Return value of xp_cmdshell */
	declare @has_immediate_sync bit
	declare @xact_seqno varbinary(16)
	declare @command_id int
	declare @type int
	declare @directory nvarchar(1024)

    select @snapshot_bit = 0x80000000
select @replpost_bit = 0x40000000
    select @directory_type = 7
    select @alt_directory_type = 25
select @scriptexec_type = 46
    select @num_transactions = 0
    select @num_commands = 0

	-- If transactions for immediate_sync publications will not be cleanup up until
	-- they are older that max retention, except for snapshot transactions.
	-- Snapshot transactions for immediate_sync publication will be cleanup up if it is
	-- not used by any subscriptions (including virtual and virtual immediate_syncymous
	-- subscriptions. Both will be reset by snapshot agent every time if the 
	-- publication is snapshot type.) The special logic for snapshot transactions
	-- is mostly for snapshop publications. It is to cleaup up the snapshot files 
	-- ASAP and not to wait for max retention.
	-- We don't need to do this for non-immediate_syncymous publications since the snapshot
	-- trans for them will be removed as soon as they are distributed and min '
	-- retention is reached.

	-- Detect if there are immediate_syncymous publications in this publishing db.
	if exists (select * from MSsubscriptions where
			publisher_database_id = @publisher_database_id and
			subscriber_id < 0)
		select @has_immediate_sync = 1
	else
		select @has_immediate_sync = 0

	if @has_immediate_sync = 1
	begin
		-- if @max_immediate_sync_seqno is null, not row will be deleted based on that.
		select @max_immediate_sync_seqno = max(xact_seqno) from MSrepl_transactions where
            publisher_database_id = @publisher_database_id and
			entry_time <= @max_cutoff_time
	end

    -- Note delete commands first since transaction table will be used for
    -- geting @max_xact_seqno (see sp_MSmaximum_cleanup_seqno).
    -- Delete all directories stored in directory command.
	if @has_immediate_sync = 0
		declare  hCdirs  CURSOR LOCAL FAST_FORWARD FOR select CONVERT(nvarchar(512), command),
			xact_seqno, command_id, type
			from MSrepl_commands where
			publisher_database_id = @publisher_database_id and
			xact_seqno <= @max_xact_seqno and   
			((type & ~@snapshot_bit) = @directory_type or
            (type & ~@snapshot_bit) = @alt_directory_type)
		for read only
	else
		declare  hCdirs  CURSOR LOCAL FAST_FORWARD FOR select CONVERT(nvarchar(512), command),
			xact_seqno, command_id, type
			from MSrepl_commands c where
			publisher_database_id = @publisher_database_id and
			((type & ~@snapshot_bit) = @directory_type  or
			 (type & ~@snapshot_bit) = @alt_directory_type or
			 (type & ~@replpost_bit) = @scriptexec_type) and
			xact_seqno <= @max_xact_seqno and  
			(
			-- Select the row if it is older than max retention.
			xact_seqno <= @max_immediate_sync_seqno or 
			-- Select the row if it is not used by any subscriptions.
			not exists (select * from MSsubscriptions s where
				s.publisher_database_id = @publisher_database_id and
				s.subscription_seqno = c.xact_seqno) OR
			-- Select the row if it is not for immediate_sync publications
			-- Note: directory command have article id 0 so it is not useful
			not exists (select * from MSpublications p where
				p.publication_id = (select top 1 s.publication_id 
					from MSsubscriptions s where
					s.publisher_database_id = @publisher_database_id and
					s.subscription_seqno = c.xact_seqno) and
				p.immediate_sync = 1)
			)
		for read only

    open hCdirs
    fetch hCdirs into @dir, @xact_seqno, @command_id, @type
    while (@@fetch_status <> -1)
    begin
	if( (@type & ~@replpost_bit) = @scriptexec_type) -- script exec command, need to map to the right path.
		select @dir = left(@dir,len(@dir) - charindex(N'\', reverse(@dir)))		
	-- Need to map unc to local drive for access problem
        exec @retcode = dbo.sp_MSreplremoveuncdir @dir
        /* Abort the operation if the delete fails */
        if (@retcode <> 0 or @@error <> 0)
            return (1)

		delete MSrepl_commands where 
			publisher_database_id = @publisher_database_id and
			xact_seqno = @xact_seqno and
			command_id = @command_id
        -- Update output parameter
        select @num_commands = @num_commands + @@rowcount

	    fetch hCdirs into @dir, @xact_seqno, @command_id, @type
    end
    close hCdirs
    deallocate hCdirs


    -- Delete all commans less than or equal to the @max_xact_seqno
    -- Delete in batch to reduce the transaction size
    set rowcount 2000
    WHILE 1 = 1
    BEGIN
		if @has_immediate_sync = 0
			DELETE MSrepl_commands WITH (PAGLOCK) where
				publisher_database_id = @publisher_database_id and
				xact_seqno <= @max_xact_seqno
		else
			-- Use nolock hint on subscription table to avoid deadlock
			-- with snapshot agent.
			DELETE MSrepl_commands WITH (PAGLOCK) where
				publisher_database_id = @publisher_database_id and
				xact_seqno <= @max_xact_seqno and
				-- Don't delete directory commands. It is deleted ealier.
				-- We have to do this because we use (nolock) hint. we have to make sure
				-- we don't delete dir command when the file is not cleaned up in the code
				-- above.
				(type & ~@snapshot_bit) <> @directory_type and
				(
				-- Select the row if it is older than max retention.
				xact_seqno <= @max_immediate_sync_seqno or 
				-- Select the row if it is not for immediate_sync article
				-- We know the command is for immediate_sync publication if
				-- the snapshot tran include articles that has virtual
				-- subscritptions. (use subscritpion table to avoid join with
				-- article and publication table)
				not exists (select * from MSsubscriptions s (nolock) where
					s.publisher_database_id = @publisher_database_id and
					s.article_id = MSrepl_commands.article_id and
					s.subscriber_id < 0) or
				-- Select the row if it is snapshot tran and 
				-- not used by any subscriptions.
				-- Delete the snapshot commands if there's no subscriptions that are not 
				-- virtual anonymous have smaller or equal subscription_seqno than 
				-- the command's xact_seqno.
				((type & @snapshot_bit) <> 0 and
				not exists (select * from MSsubscriptions s (nolock) where
					s.publisher_database_id = @publisher_database_id and
					s.subscription_seqno <= MSrepl_commands.xact_seqno and
					s.subscriber_id <> -2))
				)

		select @row_count = @@rowcount
        -- Update output parameter
        select @num_commands = @num_commands + @row_count
    
        IF @row_count = 0 -- passed the result set.  We're done
            BREAK
    END

    -- Optimized query to get the max transaction row
    set rowcount 1
    select @last_log_xact_seqno = xact_seqno from MSrepl_transactions
        where
            publisher_database_id = @publisher_database_id and
            xact_id <> 0x0  -- not initial sync transaction
            order by xact_seqno desc

    select @last_xact_seqno = xact_seqno from MSrepl_transactions
        where
            publisher_database_id = @publisher_database_id
            order by xact_seqno desc
    set rowcount 0

    -- Remove all transactions less than or equal to the @max_xact_seqno and leave the 
    -- last transaction row
    -- Note @max_xact_seqno might be null, in this case don't do any thing.
    -- Delete in batchs to reduce the transaction size
    set rowcount 5000
    -- Delete all commans less than or equal to the @max_xact_seqno
    -- Delete  rows to reduce the transaction size
    WHILE 1 = 1
    BEGIN
		if @has_immediate_sync = 0
			delete MSrepl_transactions WITH (PAGLOCK) from MSrepl_transactions where
				publisher_database_id = @publisher_database_id and
				xact_seqno <= @max_xact_seqno and
				xact_seqno <> @last_xact_seqno and
				xact_seqno <> @last_log_xact_seqno
		else
			exec dbo.sp_MSdelete_dodelete @publisher_database_id, @max_xact_seqno, 
				@last_xact_seqno, @last_log_xact_seqno 

        select @row_count = @@rowcount

        -- Update output parameter
        select @num_transactions = @num_transactions + @row_count
        if @row_count = 0
            BREAK
    END
    set rowcount 0
GO

raiserror(15339,-1,-1,'sp_MSmaximum_cleanup_seqno')
go
CREATE PROCEDURE sp_MSmaximum_cleanup_seqno
    @publisher_database_id int,
    @min_cutoff_time datetime,
    @max_cleanup_xact_seqno varbinary(16) OUTPUT
    as

    declare @min_sub_xact_seqno varbinary(16)
    declare @min_history_xact_seqno varbinary(16)
    declare @active int
    declare @initiated int
	declare @max_seqno varbinary(16)
    
    -- @max_seqn is to avoid warnging message from server on null values in aggregation.
    select @max_seqno = 0xffffffffffffffffffffffffffffffff

    set nocount on

    select @active = 2
	select @initiated = 3

    select  
        -- Get the min history xact_seqno that are large then or equal to starting
        -- sub seqno
        @min_history_xact_seqno = min(seqno.xact_seqno), 
        -- Get the min starting sub xact_seqno without larger history xact_seqno or without
        -- any history at all.
        @min_sub_xact_seqno = min(seqno.subscription_seqno)
        from
            -- seqno stores min sub seqno , min history seqno and choose_sub
            (select 
                -- If history is larger and it is not null
                -- use history.
                case when dh.xact_seqno > = sh.subscription_seqno 
                then dh.xact_seqno
                -- Don't use dh in else
                else @max_seqno
                end,

                -- If history is larger and it is not null
                -- use history.
                case when dh.xact_seqno > = sh.subscription_seqno 
                -- Don't use sh
                then @max_seqno
                else sh.subscription_seqno
                end

                from 
                    (select s.agent_id, s.subscription_seqno, max(isnull(h.timestamp,0x00))
                    from 
                        -- s stores the agent id and min subscription_seqno for
                        -- active subscriptions on non immediate_sync subscriptions
                        (select a.id, min(s2.subscription_seqno) from
                            MSsubscriptions s2 
                            join MSdistribution_agents a
                            on (a.id = s2.agent_id) 
                            where
                            s2.status in( @active, @initiated ) and
                            /* Note must filter out virtual anonymous agents !!!
								a.subscriber_id <> @virtual_anonymous and */
							-- filter out subscriptions to immediate_sync publications
							not exists (select * from MSpublications p where
								s2.publication_id = p.publication_id and
								p.immediate_sync = 1) and
                            a.publisher_database_id = @publisher_database_id
                            group by a.id)
                        s (agent_id, subscription_seqno)
                        left join MSdistribution_history h
                        on (h.agent_id = s.agent_id)
                        group by s.agent_id, s.subscription_seqno)
                    sh (agent_id, subscription_seqno, timestamp)
                    left join MSdistribution_history dh 
                    on (dh.agent_id = sh.agent_id and dh.timestamp = sh.timestamp))
                    seqno (xact_seqno, subscription_seqno)



/*  This version might be faster.. Need experiments.


    -- Get the min history xact_seqno that are large then or equal to starting
    -- sub seqno
    select @min_history_xact_seqno = min(dh.xact_seqno) from
        -- h stores the agent_ids and last xact_seqno for the publisher_db 
        (select h2.agent_id, max(h2.timestamp) 
            from MSdistribution_history h2
            join MSdistribution_agents a
                on (a.id = h2.agent_id)
            where
                a.publisher_database_id = @publisher_database_id
                group by h2.agent_id)
        h (agent_id, timestamp) 
        -- dh stores timestamp and xact_seqno association
        join MSdistribution_history dh 
            on (dh.agent_id = h.agent_id and dh.timestamp = h.timestamp)
        where   
            -- Only select history xact seqno larger then or equal to
            -- subscription start up seqno.
            -- Excluding agents with no active subscriptions. 
            dh.xact_seqno >=
                (select min(s.subscription_seqno) from MSsubscritions s where
                    -- Including anonymous agents
                    (s.agent_id = a. agent_id or s.agent_id = a.anonymous_agent_id) and
                    s.status = @active)
            
    -- Get the min starting sub xact_seqno without larger history xact_seqno or without
    -- any history at all.
    -- This will happen if the subscription is reinited
    -- excluding virtual anonymous subscriptions.
    select @min_sub_xact_seqno = min(s.subscription_seqno) from
        MSsubscriptions s
        -- left join so that subscription without history will be included. 
        left join ((select h2.agent_id, max(h2.timestamp) 
            from MSdistribution_history h2
            join MSdistribution_agents a
                on (a.id = h2.agent_id)
            where
                a.publisher_database_id = @publisher_database_id
                group by h2.agent_id)
            h (agent_id, timestamp) 
        -- dh stores timestamp and xact_seqno association
        join MSdistribution_history dh 
            on (dh.agent_id = h.agent_id and dh.timestamp = h.timestamp))
            on (s.agent_id = h.agent_id)
        where
        s.status = @active and
        s.subscriber_id <> @virtual_anonymous and
        s.publisher_database_id = @publisher_database_id and
        -- select only subs that has a larger starting seqno than history last seqno
        -- or with no history
        s.subscription_seqno > isnull(dh.xact_seqno, 0x0)
*/  
    
    /* 
    ** Optimized query to get the maximum cleanup xact_seqno
    */
    /* 
    ** If the query below returns nothing, nothing can be deleted.
    ** Reset @max_cleanup_xact_seqno to 0.
    */
    select @max_cleanup_xact_seqno = 0x00
    -- Use top 1 to avoid warning message of "Null in aggregate..." which will make
    -- sqlserver agent job having failing status
    select top 1 @max_cleanup_xact_seqno = xact_seqno
        from MSrepl_transactions
        where
            publisher_database_id = @publisher_database_id and
            (@min_history_xact_seqno IS NULL or
            -- Delete the history xact since it is distributed already.
            xact_seqno <= @min_history_xact_seqno) and
            (@min_sub_xact_seqno IS NULL or
            -- Don't delete the sub xact since it is not distributed yet.
            xact_seqno < @min_sub_xact_seqno) and
            entry_time <= @min_cutoff_time
            order by xact_seqno desc

GO

raiserror(15339,-1,-1,'sp_MSdistribution_delete')
go
CREATE PROCEDURE sp_MSdistribution_delete
    @retention int = 0,
	-- Used for anon publications.
	@max_cutoff_time datetime
    as
    declare @min_cutoff_time datetime
    declare @subscriber sysname
    declare @subscriber_db sysname
    declare @max_cleanup_xact_seqno varbinary(16)   
    declare @num_transactions int
    declare @num_commands int
    declare @start_time datetime
    declare @num_seconds int
    declare @rate int
    declare @retcode int
    declare @publisher_database_id int

    set nocount on

    select @num_transactions = 0
    select @num_commands = 0

    select @start_time = getdate()
    select @min_cutoff_time = dateadd(hour, -@retention, getdate())

    -- For each publisher/publisherdb pair do cleanup
    declare hC CURSOR LOCAL FAST_FORWARD FOR select distinct publisher_database_id
        from MSrepl_transactions
        for read only
    -- With ANSI Defaults ON, the cursor will automatically
    -- be closed on commit.   Since this proc gets called recursively, 
    -- this can happen.  So check before opening. 
    IF CURSOR_STATUS('local','hC') = -1
    open hC

    fetch hC into @publisher_database_id 
    while (@@fetch_status <> -1)
    begin

        -- Find the maximum transaction to delete
        exec @retcode = dbo.sp_MSmaximum_cleanup_seqno @publisher_database_id, @min_cutoff_time, @max_cleanup_xact_seqno OUTPUT
        if @retcode <> 0
            goto FAIL           

        -- Delete transactions and commands
        exec @retcode = dbo.sp_MSdelete_publisherdb_trans @publisher_database_id, 
			@max_cleanup_xact_seqno, @max_cutoff_time,
            @num_transactions OUTPUT, @num_commands OUTPUT
        if @retcode <> 0
            goto FAIL

        IF CURSOR_STATUS('local','hC') = -1
            open hC
        
        fetch hC into @publisher_database_id 
    end
    close hC
    deallocate hC

    select @num_seconds = datediff(second, @start_time, getdate())
    if @num_seconds <> 0 
      select @rate = (@num_transactions+@num_commands)/@num_seconds
    else
      select @rate = 0

   RAISERROR(21010, 10, -1, @num_transactions, @num_commands, @num_seconds, @rate)

   return 0

FAIL:
   close hC
   deallocate hC
   return 1
GO


raiserror(15339,-1,-1,'sp_MSdistribution_cleanup')
GO
CREATE PROCEDURE sp_MSdistribution_cleanup
    @min_distretention int = 0,
    @max_distretention int = 24
    as

    declare @retcode int
    declare @agent_name nvarchar(255)
    declare @agent_type nvarchar(100)
    declare @message nvarchar(255)
	declare @cutoff_time datetime

     -- Check for invalid parameter values 
    if @min_distretention < 0 or @max_distretention < 0
    begin
        RAISERROR(14106, 16, -1)
        return (1)
    end

	-- Note: we need to use the same cut_off time for sp_MSsubscription_cleanup
	-- and sp_MSdistribution_delete since sp_MSsubscription_cleanup need to disable
	-- all the dist agents that are lag behind (their pending trans will be removed)
    select @cutoff_time = dateadd(hour, -@max_distretention, getdate())

    -- Deactive any subscriptions which have been inactive beyond the maximum retention
    exec @retcode = dbo.sp_MSsubscription_cleanup @cutoff_time
    if @retcode <> 0
        goto FAIL
 
    -- Remove transactions and commands
    exec @retcode = dbo.sp_MSdistribution_delete @min_distretention, 
		-- used to cleanup trans for anon publications.
		@cutoff_time
    if @retcode <> 0
        goto FAIL

    -- Update statistics on cleaned tables with norecompute flag
    -- to both update the statistics periodically and 
    -- to ensure that they are not updated too frequently
    -- since this slows performance.
    --
    -- Update statistics can only be performed when not in
    -- not in a tracation so predicate by transaction level
    -- to avoid error.
    --
    if @@trancount = 0
    begin
        UPDATE STATISTICS MSrepl_commands WITH NORECOMPUTE
        UPDATE STATISTICS MSrepl_transactions WITH NORECOMPUTE
    end

    return(0)

FAIL:
    -- Raise the Agent Failure error
    set @agent_type  = formatmessage(20543)
    SELECT @agent_name = db_name() + @agent_type
    set @message  = formatmessage(20552)
    exec dbo.sp_MSrepl_raiserror @agent_type, @agent_name, 5, @message
    return (1)  

GO

raiserror(15339,-1,-1,'sp_MShistory_cleanup')
GO
CREATE PROCEDURE sp_MShistory_cleanup
@history_retention int = 24
as
    declare @cutoff_time datetime
    declare @start_time datetime
    declare @num_snapshot_rows int
    declare @num_logreader_rows int
    declare @num_distribution_rows int
    declare @num_replerror_rows int
    declare @num_queuereader_rows int
		,@num_alert_rows int
    declare @num_milliseconds int
    declare @num_seconds float
    declare @seconds_str nvarchar(10)
    declare @rate int
    declare @retcode int
    declare @total_rows int
    declare @num_merge_rows int
    declare @agent_name nvarchar(255)
    declare @agent_type nvarchar(100)
    declare @message nvarchar(255)
    declare @agent_id int
    declare @temp_error int

    set nocount on

    /* Check for invalid parameter values */
    if @history_retention < 0
    BEGIN
        RAISERROR(14106, 16, -1)
        RETURN (1)
    END
    
    -- Get start time for statistics at the end
    select @start_time = getdate()

    select @num_snapshot_rows = 0
    select @num_logreader_rows = 0
    select @num_distribution_rows = 0
    select @num_merge_rows = 0
    select @num_replerror_rows = 0
    select @num_queuereader_rows = 0

    -- Get cutoff time
    select @cutoff_time = dateadd(hour, -@history_retention, getdate())

    -- Delete sp_MSsnapshot_history (leave at least one row for monitoring)
    delete MSsnapshot_history where 
        time <= @cutoff_time and
        timestamp not in (select max(timestamp) from MSsnapshot_history 
            group by agent_id)
    select @temp_error = @@error, @num_snapshot_rows = @num_snapshot_rows + @@rowcount
    if @temp_error <> 0
        goto FAIL

    -- Delete sp_MSsnapshot_history that no longer has an MSsnapshot_agent entry
    delete from MSsnapshot_history where not exists (select * from MSsnapshot_agents
        where id = agent_id)
    select @temp_error = @@error, @num_snapshot_rows = @num_snapshot_rows + @@rowcount
    if @temp_error <> 0
        goto FAIL

    -- Delete sp_MSlogreader_history (leave at least one row for monitoring)
    delete MSlogreader_history where 
        time <= @cutoff_time and
        timestamp not in (select max(timestamp) from MSlogreader_history 
            group by agent_id)
    select @temp_error = @@error, @num_logreader_rows = @num_logreader_rows + @@rowcount
    if @temp_error <> 0
        goto FAIL

    -- Delete sp_MSlogreader_history that no longer has an MSlogreader_agent entry
    delete from MSlogreader_history where not exists (select * from MSlogreader_agents
        where id = agent_id)
    select @temp_error = @@error, @num_logreader_rows = @num_logreader_rows + @@rowcount
    if @temp_error <> 0
        goto FAIL

    -- Delete sp_MSdistribution_history (leave at least one row for monitoring)
    -- Leave last record ONLY if the agent is not anonymous.  The current logic is to remove all history for anonymous
    -- subscription, the agent definition will also be removed below.
    delete MSdistribution_history where 
        time <= @cutoff_time and
        timestamp not in (select max(timestamp) from MSdistribution_history group by agent_id)
    select @temp_error = @@error, @num_distribution_rows = @num_distribution_rows + @@rowcount
    if @temp_error <> 0
        goto FAIL

    -- Delete sp_MSdistribution_history that no longer has an MSdistribution_agent entry
    delete MSdistribution_history from MSdistribution_history dh where not exists (select * from MSdistribution_agents
        where id = dh.agent_id)
    select @temp_error = @@error, @num_distribution_rows = @num_distribution_rows + @@rowcount
    if @temp_error <> 0
        goto FAIL

    -- Delete MSqreader_history (leave at least one row for monitoring)
    delete MSqreader_history where 
        time <= @cutoff_time and
        timestamp not in (select max(timestamp) from MSqreader_history 
            group by agent_id)
    select @temp_error = @@error, @num_queuereader_rows = @num_queuereader_rows + @@rowcount
    if @temp_error <> 0
        goto FAIL

    -- Delete sp_MSlogreader_history that no longer has an MSlogreader_agent entry
    delete from MSqreader_history where not exists (select * from MSqreader_agents
        where id = agent_id)
    select @temp_error = @@error, @num_queuereader_rows = @num_queuereader_rows + @@rowcount
    if @temp_error <> 0
        goto FAIL

    -- Delete sp_MSmerge_history (leave at least one row for monitoring)
    -- Leave last record ONLY if the agent is not anonymous.  The current logic is to remove all history for anonymous
    -- subscription, the agent definition will also be removed below.
    delete from MSmerge_history where 
        time <= @cutoff_time and
        timestamp not in (select max(timestamp) from MSmerge_history group by agent_id)
    select @temp_error = @@error, @num_merge_rows = @num_merge_rows + @@rowcount
    if @temp_error <> 0
        goto FAIL

    -- Delete sp_MSmerge_history that no longer has an MSmerge_agent entry
    delete from MSmerge_history where not exists (select * from MSmerge_agents where id = agent_id)
    select @temp_error = @@error, @num_merge_rows = @num_merge_rows + @@rowcount
    if @temp_error <> 0
        goto FAIL

    -- Delete MSrepl_error entries
    delete from MSrepl_errors where time <= @cutoff_time 
    select @temp_error = @@error, @num_replerror_rows = @@rowcount
    if @temp_error <> 0
        goto FAIL
	
	-- Delete sysreplicationalerts table
    delete from msdb..sysreplicationalerts where time <= @cutoff_time 
    select @temp_error = @@error, @num_alert_rows = @@rowcount
    if @temp_error <> 0
        goto FAIL

    -- Calculate statistics for number of rows deleted
    select @num_milliseconds = datediff(millisecond, @start_time, getdate())
    if @num_milliseconds <> 0
        select @num_seconds = @num_milliseconds*1.0/1000
    else 
        select @num_seconds = 0

    select @total_rows = @num_snapshot_rows + @num_logreader_rows + 
        @num_distribution_rows +  @num_merge_rows + @num_replerror_rows + @num_alert_rows

    if @num_seconds <> 0 
        select @rate = @total_rows/@num_seconds
    else
        select @rate = @total_rows

    select @seconds_str = CONVERT(nchar(10), @num_seconds)

    RAISERROR(14108, 10, -1, @num_merge_rows, 'MSmerge_history')
    RAISERROR(14108, 10, -1, @num_snapshot_rows, 'MSsnapshot_history')
    RAISERROR(14108, 10, -1, @num_logreader_rows, 'MSlogreader_history')
    RAISERROR(14108, 10, -1, @num_distribution_rows, 'MSdistribution_history')
    RAISERROR(14108, 10, -1, @num_queuereader_rows, 'MSqreader_history')
    RAISERROR(14108, 10, -1, @num_replerror_rows, 'MSrepl_errors')
    RAISERROR(14108, 10, -1, @num_alert_rows, 'sysreplicationalerts')
	RAISERROR(14149, 10, -1, @total_rows, @seconds_str, @rate)
    
    return 0

FAIL:
    -- Raise the Agent Failure error
    set @agent_type  = formatmessage(20544)
    SELECT @agent_name = db_name() + @agent_type
    set @message  = formatmessage(20553)
    exec dbo.sp_MSrepl_raiserror @agent_type, @agent_name, 5, @message

    return (1)

GO

raiserror(15339,-1,-1,'sp_MSget_repl_version')
GO
CREATE PROCEDURE sp_MSget_repl_version
@major_version int = 0 OUTPUT,
@minor_version int = 0 OUTPUT,
@revision int = 0 OUTPUT

as
SELECT @major_version = major_version,
       @minor_version = minor_version,
       @revision = revision FROM MSrepl_version
GO

raiserror(15339,-1,-1,'sp_MSenum_subscriptions')
GO
create procedure sp_MSenum_subscriptions
@publisher sysname,
@publisher_db sysname,
@publication sysname,
@exclude_anonymous bit = 0
as

    declare @subscriber sysname
    declare @subscriber_id smallint
    declare @subscriber_db sysname
    declare @subscriber_name sysname
    declare @type int
    declare @status int
    declare @distribution_agent nvarchar(100)
    declare @publisher_id smallint
    declare @independent_agent bit
    declare @offload_enabled bit
    declare @offload_server sysname 

    declare @start_time nvarchar(24)
    declare @time nvarchar(24)
    declare @duration int
    declare @comments nvarchar(255)
    declare @delivery_time int
    declare @delivered_transactions int
    declare @delivered_commands int
    declare @average_commands int
    declare @delivery_rate int
    declare @delivery_latency int
    declare @error_id int
    declare @publication_id int
    declare @job_id binary(16)
    declare @agent_id int
    declare @local_job bit
    declare @profile_id int
    declare @last_timestamp binary(8)
			,@subscriber_type tinyint

    set nocount on

    select @publisher_id = srvid from master..sysservers where
       UPPER(srvname) = UPPER(@publisher)

    select @publication_id = publication_id from MSpublications  where 
            publisher_id = @publisher_id and
            publisher_db = @publisher_db and
            publication = @publication and
            (publication_type = 0 or publication_type = 1)

    create table #subscriptions (subscriber sysname NOT NULL,  status int NOT NULL, 
        subscriber_db sysname NOT NULL,
        type tinyint NOT NULL, distribution_agent nvarchar(100) NOT NULL, last_action nvarchar(255) NULL, 
        action_time nvarchar(24) NULL, start_time nvarchar(24) NULL, duration int NULL, 
        delivery_rate float NULL,
        delivery_latency int NULL, delivered_transactions int NULL, 
        delivered_commands int NULL,
        delivery_time int NULL, average_commands int NULL, 
        error_id int NULL, 
        job_id binary(16) NULL, local_job bit NULL, profile_id int NOT NULL,
        agent_id int NOT NULL, last_timestamp binary(8) NOT NULL, offload_enabled bit NOT NULL, 
        offload_server sysname NULL, subscriber_type tinyint NULL)
    
    -- This is to force all queries to return rows ordered by job_id
	-- Note: There might be dist agents left for cleaning up sub, in this case
	-- they are not in sub table and we don't want to show them
    create unique clustered index ucsubscriptions ON #subscriptions (agent_id)
    declare hC CURSOR LOCAL FAST_FORWARD FOR select id, name, subscriber_id, subscriber_db,
        job_id, local_job, subscription_type, profile_id, subscriber_name, offload_enabled,
        offload_server 
        from MSdistribution_agents a
        where exists (select * from MSsubscriptions s where
			(a.id = s.agent_id or a.anonymous_agent_id = s.agent_id) and
			s.publisher_id = @publisher_id and
			s.publisher_db = @publisher_db and
			-- For 6.x publisher, we don't know the association between the publication
			-- and subscriptions. Show every dist agent under each publication.
			(s.publication_id = @publication_id or s.publication_id = 0 ) and
			(a.subscriber_id >= 0  or a.subscriber_id is NULL)) and 
			(@exclude_anonymous = 0 or a.anonymous_agent_id is null)
        for read only

    -- declare hC CURSOR LOCAL FAST_FORWARD FOR select a.id, a.name, a.subscriber_id, ms.subscriber_db,
    --  a.job_id, a.local_job, ms.subscription_type, a.profile_id, a.subscriber_name
    --    from MSdistribution_agents a, master..sysservers s, MSsubscriptions ms
    --    where
    --    a.publisher_id = @publisher_id and
    --    a.publisher_db = @publisher_db and
    --  (a.publication = @publication or a.publication = 'ALL') and
    --  a.subscriber_id >= 0 and
    --  ms.publisher_db = @publisher_db and
    --  ms.publication_id = @publication_id and
    --  ms.subscriber_id = a.subscriber_id and
    --  ms.subscriber_db = a.subscriber_db and
    --  s.srvid = ms.subscriber_id
    --  for read only

    open hC
    fetch hC into  @agent_id, @distribution_agent, @subscriber_id, @subscriber_db,
        @job_id, @local_job, @type, @profile_id, @subscriber_name, @offload_enabled, 
        @offload_server
    while (@@fetch_status <> -1)
    begin
        /* Stuff in the values for no history case */
        select @status = 0, 
            @start_time = NULL,
            @time = NULL, @duration = NULL, @comments = NULL,
            @delivery_time = NULL, @delivered_transactions = NULL,
            @delivered_commands = NULL, @average_commands = NULL,
            @delivery_rate = NULL, @delivery_latency = NULL,
            @error_id = NULL,
            @last_timestamp = 0x00000000

        -- Get the status of the agent
        select @status = runstatus, 
            @start_time = convert(nvarchar(12), start_time, 112) +
                          substring(convert(nvarchar(24), start_time, 121), 11, 13),
            @time = convert(nvarchar(12), time, 112) +
                    substring(convert(nvarchar(24), time, 121), 11, 13), 
            @duration = duration, 
            @comments = comments,
            @delivery_time = 0, @delivered_transactions = delivered_transactions,
            @delivered_commands = delivered_commands, @average_commands = average_commands,
            -- Note: return average rate here !!! delivery_rate column is current rate
            @delivery_rate = delivery_rate,
            @delivery_latency = delivery_latency,
            @error_id = error_id, @last_timestamp = timestamp
            from MSdistribution_history
            where
                agent_id = @agent_id and
                timestamp = (select max(timestamp) from MSdistribution_history 
                    where 
                    agent_id = @agent_id)

        -- For anonymous subscriptions, @subscriber_name is not NULL
         if @subscriber_name is NULL
		 begin
            select @subscriber = srvname from master..sysservers where srvid=@subscriber_id
			select @subscriber_type = type from MSsubscriber_info where
				UPPER(publisher) = UPPER(@publisher) and
				UPPER(subscriber) = UPPER(@subscriber)
         end
		 else 
		 begin
			select @subscriber = @subscriber_name
			select @subscriber_db = @subscriber_db + '-' + convert(nvarchar(12), @agent_id)
			-- Don't know the subscriber type for anonymous
		 end

        insert into #subscriptions values ( @subscriber, @status, @subscriber_db,
            @type, @distribution_agent, @comments, @time, @start_time, @duration,
            @delivery_rate, @delivery_latency, @delivered_transactions, 
            @delivered_commands,  @delivery_time, @average_commands,
            @error_id, @job_id, @local_job, @profile_id, @agent_id, @last_timestamp,
            @offload_enabled, @offload_server, @subscriber_type)

        fetch hC into  @agent_id, @distribution_agent, @subscriber_id, @subscriber_db,
            @job_id, @local_job, @type, @profile_id, @subscriber_name, @offload_enabled,
            @offload_server
      end

    select * from #subscriptions order by job_id asc 

    drop table #subscriptions
    close hC
    deallocate hC
go


raiserror(15339,-1,-1,'sp_MSIfExistsSubscription')
GO
create procedure sp_MSIfExistsSubscription
@publisher sysname,
@publisher_db sysname,
@publication sysname,
@type int /* replication type, 1 - transactional/snapshot, 2 - merge */
as
    declare @publisher_id smallint
    declare @publication_id int

	if @type not in (1,2)
	begin
		RAISERROR(21055, 16, -1, '@type','sp_MSIfExistsSubscription')
		RETURN (1)
	end

    set nocount on

    select @publisher_id = srvid from master..sysservers where
       UPPER(srvname) = UPPER(@publisher)

	if @type = 1
	begin
		select @publication_id = publication_id from MSpublications  where 
				publisher_id = @publisher_id and
				publisher_db = @publisher_db and
				publication = @publication and
				(publication_type = 0 or publication_type = 1)
    
		select TOP 1 1 from MSdistribution_agents a
			where exists (select * from MSsubscriptions s where
				(a.id = s.agent_id or a.anonymous_agent_id = s.agent_id) and
				s.publisher_id = @publisher_id and
				s.publisher_db = @publisher_db and
				-- For 6.x publisher, we don't know the association between the publication
				-- and subscriptions. Show every dist agent under each publication.
				(s.publication_id = @publication_id or s.publication_id = 0 ) and
				(a.subscriber_id >= 0  or a.subscriber_id is NULL))
	end
	else
	begin
		select @publication_id = publication_id from MSpublications  where 
				publisher_id = @publisher_id and
				publisher_db = @publisher_db and
				publication = @publication and
				publication_type = 2 -- Merge 
    
		select TOP 1 1 from MSmerge_agents 
			where publisher_id = @publisher_id and 
				publisher_db = @publisher_db and 
				publication = @publication
	end
go


raiserror(15339,-1,-1,'sp_MSenum_snapshot')
go
create procedure sp_MSenum_snapshot
@name nvarchar(100) = '%',
@show_distdb bit = 0
as
    set nocount on

    declare @publisher sysname
    declare @publisher_db sysname
    declare @publication sysname
    declare @publication_id int
    declare @snapshot_agent nvarchar(100)
    declare @status int
    declare @start_time nvarchar(24)
    declare @time nvarchar(24)
    declare @duration int
    declare @comments nvarchar(255)
    declare @delivered_transactions int
    declare @delivered_commands int
    declare @delivery_rate int
    declare @publisher_id smallint
    declare @error_id int
    declare @job_id binary(16)
    declare @local_job bit
    declare @profile_id int
    declare @agent_id int
    declare @last_timestamp binary(8)


    create table #snapshot_agent (name nvarchar(100) NOT NULL, status int NOT NULL,
        publisher sysname NOT NULL, publisher_db sysname NOT NULL, publication sysname NOT NULL,
        start_time nvarchar(24)  NULL, time nvarchar(24)  NULL, duration int NULL, 
        comments nvarchar(255) NULL, delivered_transactions int NULL, delivered_commands int NULL,
        delivery_rate float  NULL, error_id int NULL, job_id binary(16) NULL, local_job bit NOT NULL,
        profile_id int NOT NULL, agent_id int NOT NULL, last_timestamp binary(8) NOT NULL)
  

    declare hC  CURSOR LOCAL FAST_FORWARD FOR
         select srvname, sa.publisher_db, sa.publication, sa.name, sa.publisher_id,
            sa.local_job, sa.job_id, sa.profile_id, sa.id
            from
            MSsnapshot_agents sa, master..sysservers
            where 
            name LIKE @name and
            srvid = sa.publisher_id
        for read only

    OPEN hC
    FETCH hC INTO @publisher, @publisher_db, @publication, @snapshot_agent, @publisher_id,
        @local_job, @job_id, @profile_id, @agent_id
    WHILE (@@fetch_status <> -1)
        begin
     
        -- Get the publication id
        select @publication_id = isnull(publication_id, 0) from MSpublications where
            publisher_id = @publisher_id and
            publisher_db = @publisher_db and
            publication = @publication
            
        -- Stuff in the values for no history case 
        select @status = 0, 
            @start_time = NULL,
            @time = NULL, @duration = NULL, @comments = NULL,
            @delivered_commands = NULL, 
            @delivery_rate = NULL, 
            @error_id = NULL,
            @last_timestamp = 0x00000000        
       
        -- Get the status of the agent
        select @status = runstatus, 
            @start_time = convert(nvarchar(12), start_time, 112) + 
                          substring(convert(nvarchar(24), start_time, 121), 11, 13), 
            @time = convert(nvarchar(12), time, 112) + 
                    substring(convert(nvarchar(24), time, 121), 11, 13), 
            @duration = duration, 
            @comments = comments,
            @delivered_transactions = delivered_transactions,
            @delivered_commands = delivered_commands,
            @delivery_rate = delivery_rate, 
            @error_id = error_id, 
            @last_timestamp = timestamp
            from MSsnapshot_history
            where
            agent_id = @agent_id and
            timestamp = (select top 1 timestamp from MSsnapshot_history where           
                agent_id = @agent_id
                order by timestamp DESC) 
    
        insert into #snapshot_agent values (@snapshot_agent, @status, @publisher,
            @publisher_db, @publication, @start_time, @time, @duration, @comments,
            @delivered_transactions, @delivered_commands, @delivery_rate, @error_id, @job_id, 
            @local_job, @profile_id, @agent_id, @last_timestamp)

        FETCH hC INTO @publisher, @publisher_db, @publication, @snapshot_agent,
            @publisher_id, @local_job, @job_id, @profile_id, @agent_id
        end

    if @show_distdb = 0
        select * from #snapshot_agent 
    else 
        select 'dbname' = DB_NAME(), * from #snapshot_agent

    drop table #snapshot_agent
    close hC
    deallocate hC

GO

raiserror(15339,-1,-1,'sp_MSenum_snapshot_s')
go
create procedure sp_MSenum_snapshot_s
@name nvarchar(100),
@hours int = 0, /* @hours < 0 will return TOP 100 */
@session_type int = 1 /* Return all sessions */
as
    set nocount on

	declare @agent_id int
    declare @succeed int
    declare @retry int
    declare @failure int
    declare @min_time datetime
    declare @independent_agent bit
    declare @publisher_id smallint
    declare @publisher_db sysname
    declare @publication sysname
    declare @start_agent_comment nvarchar(100)
    declare @initializing int
    declare @latest_session_timestamps table (timestamp binary(8) primary key, action_count int)

    /* 
    ** Status const defined in sqlrepl.h 
    */
    select @succeed = 2
    select @retry = 5
    select @failure = 6
    select @initializing = 1
    select @start_agent_comment = formatmessage(20529)


    SELECT @publisher_id = publisher_id, @publisher_db = publisher_db, 
        @publication = publication, @agent_id = id
        from
        MSsnapshot_agents 
        where 
        name = @name 

    insert into @latest_session_timestamps 
        select max(timestamp), count(*)
          from MSsnapshot_history
         where (runstatus <> @initializing or
                comments <> @start_agent_comment) 
      group by agent_id, start_time
        having agent_id = @agent_id

    /* Get date starting point */
    IF @hours < 0
    BEGIN
        select top 100 sh1.runstatus, 
            'start_time' = convert(nvarchar(12), sh1.start_time, 112) + 
                           substring(convert(nvarchar(24), sh1.start_time, 121), 11, 13), 
            'time' = convert(nvarchar(12), sh1.time, 112) + 
                     substring(convert(nvarchar(24), sh1.time, 121), 11, 13), 
            sh1.comments, sh1.duration,
            sh1.delivery_rate, sh1.delivered_commands,
            'action_count' = lst.action_count,
            sh1.error_id
            from MSsnapshot_history sh1
            inner join @latest_session_timestamps lst
            on sh1.timestamp = lst.timestamp
            where
            sh1.agent_id = @agent_id and
            ((@session_type = 1)  or
            sh1.runstatus = @failure) 
            order by sh1.timestamp desc
    END
    ELSE
    BEGIN
        IF @hours = 0
        BEGIN
            select @min_time = NULL
        END
        ELSE
        BEGIN
            select @min_time = dateadd(hour, -@hours, getdate())
        END
        select sh1.runstatus, 
            'start_time' = convert(nvarchar(12), sh1.start_time, 112) + 
                           substring(convert(nvarchar(24), sh1.start_time, 121), 11, 13), 
            'time' = convert(nvarchar(12), sh1.time, 112) + 
                     substring(convert(nvarchar(24), sh1.time, 121), 11, 13), 
            sh1.comments, sh1.duration,
            sh1.delivery_rate, sh1.delivered_commands,
            'action_count' = lst.action_count,
            sh1.error_id
            from MSsnapshot_history sh1
            inner join @latest_session_timestamps lst
            on sh1.timestamp = lst.timestamp
            where
            sh1.agent_id = @agent_id and
            ((@session_type = 1)  or
            sh1.runstatus = @failure) and
            (sh1.time >= @min_time OR @min_time IS NULL)
            order by sh1.timestamp desc
    END

GO


raiserror(15339,-1,-1,'sp_MSenum_snapshot_sd')
go
create procedure sp_MSenum_snapshot_sd
@name nvarchar(100),
@time datetime = NULL
as
    set nocount on

    declare @start_time datetime
    declare @time_up datetime
    declare @publisher_id smallint
    declare @publisher_db sysname
    declare @publication sysname

    IF @time IS NULL
        select @time = GETDATE()
    /* 
    ** If @name is given, get its publisher and subscriber pair
    ** Note: param will be overwritten
    ** If @name is NOT given, use provided param.
    */
    SELECT @publisher_id = pub.publisher_id, @publisher_db = pub.publisher_db, 
        @publication = pub.publication
        from
        MSsnapshot_agents agent, MSpublications pub
        where 
        name LIKE @name and
        agent.publisher_id = pub.publisher_id and
        agent.publication = pub.publication and
        agent.publisher_db = pub.publisher_db
    
    /*
    ** Minute-approximate @time can be used.
    **
    ** Note: The select only return datetime data with minute precisio
    */
    IF  DATEPART(second, @time) = 0 AND
        DATEPART(millisecond, @time) = 0
    BEGIN
        SELECT @time_up = DATEADD(second, +59, @time)
        SELECT @time_up = DATEADD(millisecond, +999, @time)
    END
    ELSE
        SELECT @time_up = @time
        

    select top 1 @start_time = sh.start_time            
         from MSsnapshot_history sh, MSsnapshot_agents sa
        where
        sa.publisher_id = @publisher_id and
        sa.publisher_db = @publisher_db and
        sa.publication  = @publication and
        sh.agent_id = sa.id and
        sh.time <= @time_up 
        order by sh.timestamp DESC

    select sh.runstatus, 
        'time' = convert(nvarchar(12), sh.time, 112) + 
                 substring(convert(nvarchar(24), sh.time, 121), 11, 13), 
        sh.comments, 
        sh.duration, 
        sh.delivery_rate, 
        sh.delivered_commands,
        sa.name, 
        sh.error_id         
        from MSsnapshot_history sh, MSsnapshot_agents sa
        where
        sa.publisher_id = @publisher_id and
        sa.publisher_db = @publisher_db and
        sa.publication = @publication and 
        sh.agent_id = sa.id and
        sh.start_time = @start_time 
        order by sh.timestamp desc
GO


raiserror(15339,-1,-1,'sp_MSenum_logreader')
go
create procedure sp_MSenum_logreader
@name nvarchar(100) = '%',
@show_distdb bit = 0
as
    set nocount on

    declare @publisher sysname
    declare @publisher_db sysname
    declare @logreader_agent nvarchar(100)
    declare @status int
    declare @start_time nvarchar(24)
    declare @time nvarchar(24)
    declare @duration int
    declare @comments nvarchar(255)
    declare @delivery_time int
    declare @delivered_transactions int
    declare @delivered_commands int
    declare @average_commands int
    declare @delivery_rate int
    declare @delivery_latency int
    declare @error_id int
    declare @job_id binary(16)
    declare @local_job bit
    declare @profile_id int
    declare @agent_id int
    declare @last_timestamp binary(8)


    create table #logreader_agent (name nvarchar(100) NOT NULL, status int NOT NULL,
        publisher sysname NOT NULL, publisher_db sysname NOT NULL,
        start_time nvarchar(24)  NULL, time nvarchar(24)  NULL, duration int  NULL, 
        comments nvarchar(255) NULL, delivery_time int NULL, 
        delivered_transactions int  NULL, delivered_commands int NULL, 
        average_commands int  NULL, delivery_rate int NULL, 
        delivery_latency int NULL, error_id int NULL, job_id binary(16) NULL,
        local_job bit NULL, profile_id int NOT NULL, agent_id int NOT NULL, last_timestamp binary(8) NOT NULL)  
   
    declare hC  CURSOR LOCAL FAST_FORWARD FOR
         select server.srvname, agent.publisher_db, name, 
            local_job, job_id, agent.profile_id, agent.id
            from
            MSlogreader_agents agent, master..sysservers server
            where 
            name LIKE @name and
            server.srvid = agent.publisher_id
        
        for read only

    OPEN hC
    FETCH hC INTO @publisher, @publisher_db, @logreader_agent, 
        @local_job, @job_id, @profile_id, @agent_id
    WHILE (@@fetch_status <> -1)
        begin

        /* Stuff in the values for no history case */
        select @status = 0, 
            @start_time = NULL,
            @time = NULL, @duration = NULL, @comments = NULL,
            @delivery_time = NULL, @delivered_transactions = NULL,
            @delivered_commands = NULL, @average_commands = NULL,
            @delivery_rate = NULL, @delivery_latency = NULL,
            @error_id = NULL,
            @last_timestamp = 0x00000000

        -- Get the status of the agent
        select @status = lh.runstatus, 
            @start_time = convert(nvarchar(12), start_time, 112) +
                          substring(convert(nvarchar(24), start_time, 121), 11, 13),
            @time = convert(nvarchar(12), time, 112) +
                    substring(convert(nvarchar(24),  time, 121), 11, 13), 
            @duration = duration, 
            @comments = comments,
            @delivery_time = delivery_time, @delivered_transactions = delivered_transactions,
            @delivered_commands = delivered_commands, @average_commands = average_commands,
            @delivery_rate = delivery_rate, @delivery_latency = delivery_latency,
            @error_id = error_id, @last_timestamp = timestamp
            from MSlogreader_history lh
            where
            lh.agent_id = @agent_id and
            lh.timestamp = (select max(timestamp) from MSlogreader_history
                where
                agent_id = lh.agent_id)

        insert into #logreader_agent values (@logreader_agent, @status, @publisher,
            @publisher_db, @start_time, @time, @duration, @comments,
            @delivery_time, @delivered_transactions, @delivered_commands, @average_commands,
            @delivery_rate, @delivery_latency, @error_id, @job_id, @local_job,
            @profile_id, @agent_id, @last_timestamp)

        FETCH hC INTO @publisher, @publisher_db, @logreader_agent, 
            @local_job, @job_id, @profile_id, @agent_id
        end

    if @show_distdb = 0
        select * from #logreader_agent 
    else 
        select 'dbname' = DB_NAME(), * from #logreader_agent

    drop table #logreader_agent
    close hC
    deallocate hC
GO


raiserror(15339,-1,-1,'sp_MSenum_logreader_s')
go

create procedure sp_MSenum_logreader_s
@name nvarchar(100),
@hours int = 0, /* @hours < 0 will return TOP 100 */
@session_type int = 1 /* Return all sessions */
as
    set nocount on

    declare @succeed int
    declare @agent_id int
    declare @retry int
    declare @failure int                                 
    declare @min_time datetime

    if @session_type  not in (1,2)
    begin
        return(1)
    end 

	select @agent_id  = (select top 1 id from MSlogreader_agents where name = @name) 
    /* 
    ** Status const defined in sqlrepl.h 
    */
    select @succeed = 2
    select @retry = 5
    select @failure = 6

    /* Get date starting point */
    IF @hours < 0
    BEGIN
        select top 100 runstatus, 
                'start_time' = convert(nvarchar(12), start_time, 112) + 
                               substring(convert(nvarchar(24), start_time, 121), 11, 13), 
                'time' = convert(nvarchar(12), time, 112) +
                         substring(convert(nvarchar(24), time, 121), 11, 13), 
                comments, duration, delivery_rate, delivery_latency,
            delivery_time,  delivered_transactions, delivered_commands, average_commands, 
            'action_count' = (select count(*) from MSlogreader_history where
                start_time = rh.start_time and agent_id=@agent_id),
            error_id
            from MSlogreader_history rh
            where
            rh.agent_id = @agent_id and
            ((@session_type = 1 and (runstatus = @succeed or
                runstatus = @retry or
                timestamp = (select max(timestamp) from MSlogreader_history rh2 where
                    rh2.agent_id = rh.agent_id))) or
            runstatus = @failure) 
            order by timestamp desc
    END
    ELSE
    BEGIN
        IF @hours = 0
        BEGIN
            select @min_time = NULL
        END
        ELSE
        BEGIN
            select @min_time = dateadd(hour, -@hours, getdate())
        END
        select  runstatus, 
                'start_time' = convert(nvarchar(12), start_time, 112) + 
                               substring(convert(nvarchar(24), start_time, 121), 11, 13), 
                'time' = convert(nvarchar(12), time, 112) +
                         substring(convert(nvarchar(24), time, 121), 11, 13), 
                comments, duration, delivery_rate, delivery_latency,
            delivery_time,  delivered_transactions, delivered_commands, average_commands, 
            'action_count' = (select count(*) from MSlogreader_history where
                start_time = rh.start_time),
            error_id
            from MSlogreader_history rh
            where
            rh.agent_id = (select top 1 id from MSlogreader_agents where name = @name) and
            ((@session_type = 1 and (runstatus = @succeed or
                runstatus = @retry or
                timestamp = (select max(timestamp) from MSlogreader_history rh2 where
                    rh2.agent_id = rh.agent_id))) or
            runstatus = @failure) and
            (time >= @min_time OR @min_time IS NULL)
            order by timestamp desc
    END

GO

raiserror(15339,-1,-1,'sp_MSenum_logreader_sd')
go

create procedure sp_MSenum_logreader_sd
@name nvarchar(100),
@time datetime = NULL
as
    set nocount on

    declare @start_time datetime
    declare @time_up datetime

    IF @time IS NULL
        select @time = GETDATE()
    /*
    ** Minute-approximate @time can be used.
    ** Note: The select only return datetime data with minute precision
    */
    IF  DATEPART(second, @time) = 0 AND
        DATEPART(millisecond, @time) = 0
    BEGIN
        SELECT @time_up = DATEADD(second, +59, @time)
        SELECT @time_up = DATEADD(millisecond, +999, @time)
    END
    ELSE
        SELECT @time_up = @time
        

    select  top 1 @start_time = start_time          
         from MSlogreader_history rh
        where
        rh.agent_id = (select top 1 id from MSlogreader_agents where name = @name) and
        time <= @time_up 
        order by timestamp DESC

    select  runstatus, 
            'time' = convert(nvarchar(12), time, 112) +
                     substring(convert(nvarchar(24), time, 121), 11, 13), 
            comments,duration, delivery_rate, delivery_latency,
        delivery_time,  delivered_transactions, delivered_commands, average_commands, 
        error_id        
        from MSlogreader_history rh
        where
        rh.agent_id = (select top 1 id from MSlogreader_agents where name = @name) and
        start_time = @start_time 
        order by timestamp desc
GO

raiserror(15339,-1,-1,'sp_MSenum_qreader')
go
create procedure sp_MSenum_qreader (
	@name nvarchar(100) = '%',
	@show_distdb bit = 0)
as
begin
	set nocount on

	declare @agent_name nvarchar(100)
	declare @status int
	declare @start_time nvarchar(24)
	declare @time nvarchar(24)
	declare @duration int
	declare @comments nvarchar(255)
	declare @transactions_processed int
	declare @commands_processed int
	declare @average_commands int
	declare @delivery_rate int
	declare @delivery_latency int
	declare @error_id int
	declare @job_id binary(16)
	declare @agent_id int
	declare @profile_id int
	declare @last_timestamp binary(8)
	declare @first_timestamp binary(8)


	create table #qreader_agent (name nvarchar(100) NOT NULL, status int NOT NULL,
		start_time nvarchar(24) NULL, time nvarchar(24) NULL, duration int NULL,
		comments nvarchar(255) NULL, 
		transactions_processed int NULL, commands_processed int NULL, 
        average_commands int NULL, delivery_rate int NULL, delivery_latency int NULL,
		error_id INT NULL, job_id binary(16) NULL, 
		profile_id int NULL, agent_id int NOT NULL, local_timestamp binary(8) NOT NULL)

	declare hC CURSOR LOCAL FAST_FORWARD FOR
		select id, name, job_id, profile_id
		from MSqreader_agents 
		where name = case when ((@name = '%') or (@name is NULL)) then name else @name end
		for read only

	OPEN hC
	FETCH hC INTO @agent_id, @agent_name, @job_id, @profile_id
	WHILE (@@fetch_status <> -1)
	begin       
		--
		-- Initialize
		--
		select @status = 0, 
			@delivery_latency = 0

		--
		-- select the last timestamp
		--
		select @last_timestamp = max(timestamp) from MSqreader_history 
			where agent_id = @agent_id

		--
		-- select the last time the agent was started
		--
		select @first_timestamp = max(timestamp) from MSqreader_history
			where agent_id = @agent_id and runstatus = 1
			
		--
		-- Get start time, duration
		--
		select @start_time = convert(nvarchar(12), start_time, 112) +
							substring(convert(nvarchar(24), start_time, 121), 11, 13)
		from MSqreader_history
			where agent_id = @agent_id and timestamp = @first_timestamp
			
		--
		-- Compute the transaction processed, commands processed,
		-- avg commands, delivery rate
		--
		select @transactions_processed = sum(ISNULL(transactions_processed, 0)) 
				,@commands_processed = sum(ISNULL(commands_processed, 0))
				,@average_commands =  avg(ISNULL(commands_processed, 0))
				,@delivery_rate = cast(avg(ISNULL(delivery_rate, 0.0)) as int)
			from MSqreader_history
			where agent_id = @agent_id 
				and timestamp >= @first_timestamp and timestamp <= @last_timestamp
				and transactions_processed > 0
				
		--
		-- Get the duration, time, status, comments, error from last log
		--
		select 
			@duration = duration,
			@time = convert(nvarchar(12), time, 112) +
							substring(convert(nvarchar(24), time, 121), 11, 13),
			@status = isnull(runstatus, 0),
			@comments = comments,
			@error_id = error_id
		from MSqreader_history
		where 
			agent_id = @agent_id and
			timestamp = @last_timestamp
            
		insert into #qreader_agent values(@agent_name, @status, @start_time, 
			@time, @duration, @comments, @transactions_processed, @commands_processed, 
			@average_commands, @delivery_rate, @delivery_latency,
			@error_id, @job_id, @profile_id, @agent_id, isnull(@last_timestamp,0x00))            

		FETCH hC INTO @agent_id, @agent_name, @job_id, @profile_id
	end

	if @show_distdb = 0
		select * from #qreader_agent 
	else 
		select 'dbname' = DB_NAME(), * from #qreader_agent

	drop table #qreader_agent
	close hC
	deallocate hC
end
GO


raiserror(15339,-1,-1,'sp_MSenum_qreader_s')
go
create procedure sp_MSenum_qreader_s (
	@publication_id int = 0, 
	@hours int = 0, /* @hours < 0 will return TOP 100 */
	@session_type int = 1 /* Return all sessions */
)
as
begin
	set nocount on

	declare @succeed int
			,@retry int
			,@failure int
			,@min_time datetime
			,@agent_id int
			,@maxtimestamp timestamp
			,@session_start timestamp
			,@next_session_start timestamp
			,@session_end timestamp
			,@final_ts timestamp

			,@status int,
			@start_time nvarchar(24), 
			@time nvarchar(24), 
			@comments nvarchar(255), 
			@duration int, 
			@delivery_rate int, 
			@delivery_latency int,
			@transactions_processed int, 
			@commands_processed int, 
	        @average_commands int, 
	        @action_count int, 
	        @error_id int,
	        @start_datetime datetime,
	        @end_datetime datetime
	
	if @session_type  not in (1,2)
	begin
		return(1)
	end
	
	/* 
	** Status const defined in sqlrepl.h 
	*/
	select @succeed = 2
	select @retry = 5
	select @failure = 6

	-- create the table to store sessions
	create table #qreader_session (status int NOT NULL,
		start_time nvarchar(24) NOT NULL, time nvarchar(24) NOT NULL, comments nvarchar(255) NULL, 
		duration int NULL, delivery_rate int NULL, delivery_latency int NULL,
		publication_id int NULL, transactions_processed int NULL, commands_processed int NULL, 
        average_commands int NULL, action_count int NULL, error_id INT NULL, local_timestamp binary(8) NOT NULL)
		
	-- get the agent id
	select TOP 1 @agent_id = agent_id from MSqreader_history 

	--
	-- If Min time specified, initilialize it
	--
	IF (@hours < 1)
		select @min_time = NULL
	ELSE
		select @min_time = dateadd(hour, -@hours, getdate())

	-- initialize
	select @delivery_latency = 0
			,@next_session_start = NULL
			,@session_end = NULL
			,@final_ts = max(timestamp) 
	from MSqreader_history
	
	-- Get the session details
	while (@session_end != @final_ts)
	begin
		--
		-- Mark the beginning of a new session
		--
		if (@next_session_start is NULL)
		begin
			select @session_start = min(timestamp) from MSqreader_history
				where agent_id = @agent_id and runstatus = 1
		end
		else
		begin
			select @session_start = @next_session_start 
		end

		--
		-- update @next_session_start
		--
		select @next_session_start = ISNULL(min(timestamp), @final_ts) 
		from MSqreader_history
		where agent_id = @agent_id and timestamp > @session_start and runstatus = 1

		--
		-- find session end based on @next_session_start
		--
		if (@next_session_start = @final_ts)
			select @session_end = @final_ts
		else
		begin
			select @session_end = isnull(max(timestamp), @next_session_start)
			from MSqreader_history
			where agent_id = @agent_id and
				timestamp > @session_start and 
				timestamp < @next_session_start
		end
		
		--
		-- get start time for this session
		--
		select @start_datetime = start_time, 
			@start_time = convert(nvarchar(12), start_time, 112) +
						substring(convert(nvarchar(24), start_time, 121), 11, 13)
		from MSqreader_history						
		where agent_id = @agent_id and timestamp = @session_start						

		--
		-- do we need to process this session 
		--
		if (@start_time IS NULL)
		begin
			--
			-- Check if we are done with all sessions
			--
			if (@session_end = @final_ts)
				break
			else
				continue
		end

		--
		-- get status, end time, comments, error id for this session
		--
		select @status = runstatus,
			@end_datetime = time,
			@time = convert(nvarchar(12), time, 112) +
					substring(convert(nvarchar(24), time, 121), 11, 13), 
			@comments = comments, 
	        @error_id = ISNULL(error_id, 0) 
		from MSqreader_history						
		where agent_id = @agent_id and timestamp = @session_end						

		--
		-- do we need to continue this session - min time check
		--
		if ((@min_time is NOT NULL) and (@min_time > @end_datetime))
		begin
			--
			-- Check if we are done with all sessions
			--
			if (@session_end = @final_ts)
				break
			else
				continue
		end

		--
		-- get duration, action count, tran processed, cmds processed, avg cmds, etc
		-- for this session
		--
		select @duration = DATEDIFF(second, @start_datetime, @end_datetime)
		select @action_count = ISNULL(count(*), 0)
			from MSqreader_history
			where agent_id = @agent_id 
				and timestamp >= @session_start and timestamp <= @session_end

		select @transactions_processed = sum(ISNULL(transactions_processed, 0)) 
				,@commands_processed = sum(ISNULL(commands_processed, 0))
				,@average_commands =  avg(ISNULL(commands_processed, 0))
				,@delivery_rate = cast(avg(ISNULL(delivery_rate, 0.0)) as int)
			from MSqreader_history
			where agent_id = @agent_id 
				and timestamp >= @session_start and timestamp <= @session_end
				and transactions_processed > 0

		--
		-- insert into #qreader_session
		--
		insert into	#qreader_session values(@status, @start_time, @time, @comments, 
			@duration, @delivery_rate, @delivery_latency, NULL, @transactions_processed, 
			@commands_processed, @average_commands, @action_count, @error_id, @session_end)

		--
		-- Check if we are done with all sessions
		--
		if (@session_end = @final_ts)
			break
	end

	-- return results
	
	if (@hours < 0)
		select top 100 
			status,
			start_time,
			time, 
			comments, 
			duration,
			delivery_rate,
			delivery_latency,
			publication_id,
			transactions_processed, 
			commands_processed, 
			average_commands, 
			action_count, 
			error_id
		from #qreader_session
		where (@session_type = 2 and (status = @failure)) or 
				(@session_type = 1)
		order by local_timestamp desc
	else
		select 
			status,
			start_time,
			time, 
			comments, 
			duration,
			delivery_rate,
			delivery_latency,
			publication_id,
			transactions_processed, 
			commands_processed, 
			average_commands, 
			action_count, 
			error_id
		from #qreader_session		
		where (@session_type = 2 and (status = @failure)) or 
				(@session_type = 1)
		order by local_timestamp desc
end
GO


raiserror(15339,-1,-1,'sp_MSenum_qreader_sd')
go
create procedure sp_MSenum_qreader_sd (
	@publication_id int = 0, 
	@time datetime = NULL)
as
begin
	set nocount on

	declare @time_up datetime
			,@agent_id int
			,@final_ts timestamp
			,@initial_ts timestamp
			,@session_start timestamp
			,@next_session_start timestamp
			,@session_end timestamp

	if (@publication_id = 0)
		select @publication_id = NULL
		
	IF @time IS NULL
		select @time = GETDATE()

	/*
	** Minute-approximate @time can be used.
	** Note: The select only return datetime data with minute precision
	*/
	IF ( (DATEPART(second, @time) = 0) AND
			(DATEPART(millisecond, @time) = 0) )
	BEGIN
		SELECT @time_up = DATEADD(second, +59, @time)
		SELECT @time_up = DATEADD(millisecond, +999, @time)
	END
	ELSE
		SELECT @time_up = @time

	--
	-- Get the agent id
	--
	select TOP 1 @agent_id = agent_id from MSqreader_history 

	--
	-- Get the session start, next session start timestamps
	--
	select @initial_ts = min(timestamp), @final_ts = max(timestamp) from MSqreader_history
	
	select @session_start = ISNULL(max(timestamp), @initial_ts) from MSqreader_history
			where agent_id = @agent_id and time <= @time_up and runstatus = 1
			
	select @next_session_start = ISNULL(min(timestamp), @final_ts) from MSqreader_history
			where agent_id = @agent_id and timestamp > @session_start and runstatus = 1

	--
	-- find session end based on @next_session_start
	--
	if (@next_session_start = @final_ts)
		select @session_end = @final_ts
	else
	begin
		select @session_end = max(timestamp)
		from MSqreader_history
		where agent_id = @agent_id and
			timestamp > @session_start and 
			timestamp < @next_session_start
	end
	
	--
	-- Do the select now
	--
	select  runstatus, 
		'time' = convert(nvarchar(12), time, 112) +
					substring(convert(nvarchar(24), time, 121), 11, 13), 
		comments, 
	    transaction_id, 
	    transaction_status,
	    commands_processed,
	    subscriber,
	    subscriberdb,
		'error_id' = ISNULL(error_id, 0)
	from MSqreader_history
	where
		agent_id = @agent_id and
		timestamp >= @session_start and
		timestamp <= @session_end
	order by timestamp desc
end
GO

raiserror(15339,-1,-1,'sp_MSenum_distribution')
go
create procedure sp_MSenum_distribution
@name nvarchar(100) = '%',
@show_distdb bit = 0,
@exclude_anonymous bit = 0
as
    set nocount on

    declare @publisher sysname
    declare @publisher_id smallint
    declare @publisher_db sysname
    declare @publication sysname
    declare @subscriber sysname
    declare @subscriber_id smallint
    declare @subscriber_db sysname
    declare @subscriber_name sysname
    declare @distribution_agent nvarchar(100)
    declare @status int
    declare @start_time nvarchar(24)
    declare @time nvarchar(24)
    declare @duration int
    declare @comments nvarchar(255)
    declare @delivery_time int
    declare @delivered_transactions int
    declare @delivered_commands int
    declare @average_commands int
    declare @delivery_rate int
    declare @delivery_latency int   
    declare @subscription_type int
    declare @error_id int
    declare @job_id binary(16)
    declare @local_job bit
    declare @agent_id int
    declare @profile_id int
    declare @last_timestamp binary(8)
    declare @offload_enabled bit
    declare @offload_server  sysname
		,@subscriber_type tinyint


    create table #distribution_agent (name nvarchar(100) NOT NULL, status int NOT NULL,
        publisher sysname NOT NULL, publisher_db sysname NOT NULL, publication sysname NULL,
        subscriber sysname NULL, subscriber_db sysname NULL,subscription_type int NULL, 
        start_time nvarchar(24) NULL, time nvarchar(24) NULL, duration int NULL, 
        comments nvarchar(255) NULL, delivery_time int NULL, 
        delivered_transactions int NULL, delivered_commands int NULL, 
        average_commands int NULL, delivery_rate int NULL, delivery_latency int NULL,
        error_id int NULL, job_id binary(16) NULL, local_job bit NOT NULL,
        profile_id int NOT NULL, agent_id int NOT NULL, last_timestamp binary(8) NOT NULL, 
		offload_enabled BIT NOT NULL, offload_server sysname NULL,
		subscriber_type tinyint NULL)

    /* excluding virtual subscriptions */
    declare hC CURSOR LOCAL FAST_FORWARD FOR
        select id, name, publisher_id, publisher_db, publication, 
            subscriber_id, subscriber_db, subscription_type, local_job, job_id,
            profile_id, subscriber_name, offload_enabled, offload_server
            from
            MSdistribution_agents 
            where 
			--No virtual subscription wanted
            name LIKE @name and (subscriber_id is NULL or subscriber_id>=0) and
			(@exclude_anonymous = 0 or anonymous_agent_id is null)
        for read only


    OPEN hC
    FETCH hC INTO @agent_id, @distribution_agent, @publisher_id, @publisher_db, @publication,
        @subscriber_id, @subscriber_db, @subscription_type, @local_job, @job_id, @profile_id, @subscriber_name, @offload_enabled, @offload_server
    WHILE (@@fetch_status <> -1)
        begin
        
        /* Stuff in the values for no history case */
        select @status = 0, 
            @start_time = NULL,
            @time = NULL, @duration = NULL, @comments = NULL,
            @delivery_time = NULL, @delivered_transactions = NULL,
            @delivered_commands = NULL, @average_commands = NULL,
            @delivery_rate = NULL, @delivery_latency = NULL,
            @error_id = NULL,
            @last_timestamp = 0x00000000

        select @status = isnull(runstatus, 0),
            @start_time = convert(nvarchar(12), start_time, 112) +
                          substring(convert(nvarchar(24), start_time, 121), 11, 13),
            @time = convert(nvarchar(12), time, 112) +
                    substring(convert(nvarchar(24), time, 121), 11, 13), 
            @duration = duration, 
            @comments = comments,
            @delivery_time = 0, @delivered_transactions = delivered_transactions,
            @delivered_commands = delivered_commands, @average_commands = average_commands,
            @delivery_rate = delivery_rate,
            @delivery_latency = delivery_latency,
            @error_id = error_id, @last_timestamp = timestamp   
            from MSdistribution_history
            where
            agent_id = @agent_id and
            timestamp = (select max(timestamp) from MSdistribution_history 
                where agent_id = @agent_id)
            
            select @publisher = srvname from master..sysservers where srvid = @publisher_id
        IF @subscriber_name is NULL
		begin
                select @subscriber = srvname from master..sysservers where srvid=@subscriber_id 
				select @subscriber_type = type from MSsubscriber_info where
					UPPER(publisher) = UPPER(@publisher) and
					UPPER(subscriber) = UPPER(@subscriber)

		end
		ELSE 
            begin
                select @subscription_type = 2
                select @subscriber = @subscriber_name
                select @subscriber_db = @subscriber_db + '-' + convert(nvarchar(12), @agent_id)
            end
            
        insert into #distribution_agent values (@distribution_agent,
            @status, @publisher,
            @publisher_db, @publication, @subscriber, @subscriber_db, @subscription_type, 
            @start_time, @time, @duration, @comments,
            @delivery_time, @delivered_transactions, @delivered_commands, @average_commands,
            @delivery_rate, @delivery_latency, @error_id, @job_id, 
            @local_job, @profile_id, @agent_id, @last_timestamp, @offload_enabled, 
			@offload_server, @subscriber_type)

        FETCH hC INTO @agent_id, @distribution_agent, @publisher_id, @publisher_db, @publication,
            @subscriber_id, @subscriber_db, @subscription_type, @local_job, @job_id, 
            @profile_id, @subscriber_name, @offload_enabled, @offload_server
        end

    if @show_distdb = 0
        select * from #distribution_agent 
    else 
        select 'dbname' = DB_NAME(), * from #distribution_agent

    drop table #distribution_agent
    close hC
    deallocate hC

GO


raiserror(15339,-1,-1,'sp_MSenum_distribution_s')
go
create procedure sp_MSenum_distribution_s
@name nvarchar(100), 
@hours int = 0, /* @hours < 0 will return TOP 100 */
@session_type int = 1 /* Return all sessions */
as
    set nocount on

    declare @succeed int
    declare @retry int
    declare @failure int
    declare @min_time datetime
    declare @agent_id int

    /* 
    ** Status const defined in sqlrepl.h 
    */
    select @succeed = 2
    select @retry = 5
    select @failure = 6

    select @agent_id = id from MSdistribution_agents where
        name = @name


    /* Get date starting point */
    IF @hours < 0
    BEGIN
        select top 100 runstatus, 
            'start_time' = convert(nvarchar(12), start_time, 112) +
                           substring(convert(nvarchar(24), start_time, 121), 11, 13), 
            'time' = convert(nvarchar(12), time, 112) +
                     substring(convert(nvarchar(24), time, 121), 11, 13), 
            comments, duration, 
            delivery_rate,
            delivery_latency,
            0, /*delivery_time */   
            delivered_transactions, delivered_commands, average_commands, 
            'action_count' = (select count(*) from MSdistribution_history where
                start_time = rh.start_time and agent_id = @agent_id),
            error_id
            from MSdistribution_history rh
            where
            agent_id = @agent_id and
            ((@session_type = 1 and
            (runstatus = @succeed or
            runstatus = @retry or
            timestamp = (select max(timestamp) from MSdistribution_history rh2 where
                rh2.agent_id = @agent_id))) or 
            runstatus = @failure)
            order by timestamp desc
    END
    ELSE
    BEGIN
        IF @hours = 0
        BEGIN
            select @min_time = NULL
        END
        ELSE
        BEGIN
            select @min_time = dateadd(hour, -@hours, getdate())
        END
        select  runstatus, 
            'start_time' = convert(nvarchar(12), start_time, 112) +
                           substring(convert(nvarchar(24), start_time, 121), 11, 13), 
            'time' = convert(nvarchar(12), time, 112) +
                     substring(convert(nvarchar(24), time, 121), 11, 13), 
            comments, duration, 
            delivery_rate,
            delivery_latency,
            0, /*delivery_time */   
            delivered_transactions, delivered_commands, average_commands, 
            'action_count' = (select count(*) from MSdistribution_history where
                start_time = rh.start_time and agent_id = @agent_id),
            error_id
            from MSdistribution_history rh
            where
            agent_id = @agent_id and
            ((@session_type = 1 and
            (runstatus = @succeed or
            runstatus = @retry or
            timestamp = (select max(timestamp) from MSdistribution_history rh2 where
                rh2.agent_id = @agent_id))) or 
            runstatus = @failure) and
            (time >= @min_time or @min_time IS NULL)
            order by timestamp desc
    END

GO


raiserror(15339,-1,-1,'sp_MSenum_distribution_sd')
go
create procedure sp_MSenum_distribution_sd
@name nvarchar(100),
@time datetime = NULL
as
    set nocount on

    declare @start_time datetime
    declare @time_up datetime
    declare @agent_id int

    IF @time IS NULL
        select @time = GETDATE()
    
    select @agent_id = id from MSdistribution_agents where
        name = @name

    /*
    ** Minute-approximate @time can be used.
    ** Note: The select only return datetime data with minute precision
    */
    IF  DATEPART(second, @time) = 0 AND
        DATEPART(millisecond, @time) = 0
    BEGIN
        SELECT @time_up = DATEADD(second, +59, @time)
        SELECT @time_up = DATEADD(millisecond, +999, @time)
    END
    ELSE
        SELECT @time_up = @time
        

    select top 1 @start_time = start_time           
         from MSdistribution_history rh
        where
        rh.agent_id = @agent_id and
        time <= @time_up
        order by timestamp DESC

    select  runstatus, 
        'time' = convert(nvarchar(12), time, 112) +
                 substring(convert(nvarchar(24), time, 121), 11, 13), 
        comments, duration, 
        delivery_rate,
        delivery_latency,
        /* delivery_time */ 0,  
        delivered_transactions, delivered_commands, average_commands, 
        error_id            
        from MSdistribution_history rh
        where
        rh.agent_id = @agent_id and
        start_time = @start_time
        order by timestamp desc
GO


raiserror(15339,-1,-1,'sp_MSadd_merge_history')
go
CREATE PROCEDURE sp_MSadd_merge_history (
	@agent_id       int,        
	@runstatus      int, 
	@comments       nvarchar(255),
	@delivery_time  int = 0,                    /* Milliseconds */
	@publisher_insertcount  int = 0,
	@publisher_updatecount  int = 0,
	@publisher_deletecount  int = 0,
	@publisher_conflictcount int = 0,
	@subscriber_insertcount int = 0,
	@subscriber_updatecount int = 0,
	@subscriber_deletecount int = 0,
	@subscriber_conflictcount int = 0,
	@log_error bit = 0,
	@perfmon_increment bit = 1,
	@update_existing_row bit = 0,
	@updateable_row bit = 1, 	-- used to override history verbose level to decide
					-- whether the row being added can be updated by another.	
	@do_raiserror bit = 1
)
AS
BEGIN

	DECLARE @current_time datetime
			,@start_time datetime
			,@duration int
			,@delivery_rate float
			,@perfmon_delivery_rate int
			,@perfmon_conflict_count int
			,@delivered_rows int
			,@changes int
			,@delivery_time_old  int
			,@delivered_rows_old int
			,@publisher_insertcount_old  int 
			,@publisher_updatecount_old  int 
			,@publisher_deletecount_old  int 
			,@publisher_conflictcount_old int 
			,@subscriber_insertcount_old int 
			,@subscriber_updatecount_old int 
			,@subscriber_deletecount_old int 
			,@subscriber_conflictcount_old int 
			,@publisher_id smallint
			,@subscriber_id smallint
			,@error_id int 
			,@startup int
			,@succeed int
			,@retry int
			,@inprogress int
			,@failure int
			,@idle int
			,@lastrow_timestamp timestamp
			,@agent_name nvarchar(100)
			,@publisher sysname
			,@publisher_db sysname
			,@publication sysname
			,@retcode int
			,@existing_row_updateble bit
			,@this_row_updateable bit
			,@agentclassname sysname
			,@lastrunstatus int

	-- Security Check
	exec @retcode = dbo.sp_MScheck_pull_access
    		@agent_id = @agent_id,
			@agent_type = 1 -- merge agent
	if @@error <> 0 or @retcode <> 0
	        return (1)

	/* 
	** Status const defined in sqlrepl.h 
	*/
	select @startup = 1
			,@succeed = 2
			,@inprogress = 3
			,@idle = 4
			,@retry = 5
			,@failure = 6
			,@delivery_time_old  = 0
			,@publisher_insertcount_old   = 0
			,@publisher_updatecount_old   = 0
			,@publisher_deletecount_old   = 0
			,@publisher_conflictcount_old  = 0
			,@subscriber_insertcount_old  = 0
			,@subscriber_updatecount_old  = 0
			,@subscriber_deletecount_old  = 0
			,@subscriber_conflictcount_old  = 0
			,@existing_row_updateble = 1
			,@this_row_updateable = 1

	if (@updateable_row = 0)
	begin
		select @this_row_updateable = 0
	end

    SELECT @current_time = GETDATE()

    -- Update Perfmon counter
    if @perfmon_increment = 1
    begin
        if @runstatus = @startup
            dbcc incrementinstance ("SQL Replication Agents", "Running", "Merge", 1)
        else if (@runstatus = @succeed or @runstatus = @retry or @runstatus = @failure)
            dbcc incrementinstance ("SQL Replication Agents", "Running", "Merge", -1)
    end

    SELECT @agent_name = name, @publisher_id = publisher_id, @publisher_db = publisher_db, 
        @publication = publication from MSmerge_agents where id = @agent_id
    SELECT @publisher = srvname from master..sysservers where srvid = @publisher_id

	IF @runstatus = @inprogress or @runstatus = @idle
		BEGIN
            SELECT TOP 1 @start_time = start_time, 
					@lastrow_timestamp = timestamp,
					@publisher_insertcount_old = publisher_insertcount ,
                    @publisher_updatecount_old = publisher_updatecount, 
                    @publisher_deletecount_old = publisher_deletecount,
                    @publisher_conflictcount_old = publisher_conflictcount,
                    @subscriber_insertcount_old = subscriber_insertcount, 
                    @subscriber_updatecount_old = subscriber_updatecount,
                    @subscriber_deletecount_old = subscriber_deletecount,
                    @subscriber_conflictcount_old = subscriber_conflictcount,
                    @delivery_time_old = delivery_time,
					@existing_row_updateble = updateable_row
            FROM MSmerge_history (rowlock)
            WHERE  agent_id = @agent_id ORDER BY timestamp DESC
        
            select @delivered_rows_old = @publisher_insertcount_old + 
                             @publisher_updatecount_old +
                             @publisher_deletecount_old +
                             @subscriber_updatecount_old +
                             @subscriber_insertcount_old +
                             @subscriber_deletecount_old 
        END
	ELSE IF @runstatus <> 1 --1 is the Start status
		BEGIN
			SELECT TOP 1 @start_time = start_time, 
						@lastrow_timestamp = timestamp,
						@lastrunstatus = runstatus
			FROM MSmerge_history (rowlock)
			WHERE  agent_id = @agent_id ORDER BY timestamp DESC

			if (@lastrunstatus = @succeed or @lastrunstatus = @failure or @lastrunstatus = @retry)
			begin
				select @start_time = @current_time
			end
		END
    ELSE
		BEGIN
			SELECT @start_time = @current_time
		END

    /* Use the current time if no corresponding start_up message logged */
    IF @start_time IS NULL
       SELECT @start_time = @current_time

    /* Calculate agent run duration */
    SELECT @duration = DATEDIFF(second, @start_time, @current_time) 

	if (@start_time = @current_time and (@runstatus = @succeed or @runstatus = @failure or @runstatus = @retry))
    begin
		declare @logintime datetime
		select @logintime = NULL

		select @logintime = (select top 1 login_time from master.dbo.sysprocesses (NOLOCK) where spid = @@spid)

		set @start_time = @logintime
		if (@logintime is not null)
		begin
			select @duration = DATEDIFF(second, @logintime, @current_time)
		end
	end
                             
    select @delivered_rows = @publisher_insertcount + 
                             @publisher_updatecount +
                             @publisher_deletecount +
                             @subscriber_updatecount +
                             @subscriber_insertcount +
                             @subscriber_deletecount 

    -- Set Perfmon counters
    if @runstatus = @idle or @runstatus = @inprogress
    begin
        dbcc addinstance ("SQL Replication Merge", @agent_name)

		set @changes = @publisher_insertcount + @publisher_updatecount + @publisher_deletecount                             
        dbcc incrementinstance ("SQL Replication Merge", "Downloaded Changes", @agent_name, @changes)

		set @changes = @subscriber_updatecount + @subscriber_insertcount + @subscriber_deletecount 
        dbcc incrementinstance ("SQL Replication Merge", "Uploaded Changes", @agent_name, @changes)

        set @perfmon_conflict_count = @publisher_conflictcount + @subscriber_conflictcount
        dbcc incrementinstance ("SQL Replication Merge", "Conflicts", @agent_name, @perfmon_conflict_count)
    end

    if @runstatus = @inprogress  or @runstatus = @idle			-- if it is in progress, then do incremental change
    begin
        select @publisher_insertcount = @publisher_insertcount_old + @publisher_insertcount
        select      @publisher_updatecount = @publisher_updatecount_old + @publisher_updatecount
        select      @publisher_deletecount = @publisher_deletecount_old + @publisher_deletecount
        select      @publisher_conflictcount = @publisher_conflictcount_old + @publisher_conflictcount
        select      @subscriber_insertcount = @subscriber_insertcount_old + @subscriber_insertcount
        select     @subscriber_updatecount = @subscriber_updatecount_old + @subscriber_updatecount
        select     @subscriber_deletecount = @subscriber_deletecount_old + @subscriber_deletecount
        select     @subscriber_conflictcount = @subscriber_conflictcount_old + @subscriber_conflictcount

        select  @delivery_time = @delivery_time_old + @delivery_time
        select @delivered_rows = @delivered_rows + @delivered_rows_old
    end
    
    IF @duration <> 0 
       SELECT @delivery_rate = (@delivered_rows * 1.0) / @duration
    ELSE
       SELECT @delivery_rate = 0

	/* 
    ** Set error id to 0 unless the user want to log errors associate with this 
    ** history message.
    */
    SELECT @error_id = 0
    IF @log_error = 1
	BEGIN
        -- Ignore errors here. @error_id will be set to 0 in case of errors  
        EXEC dbo.sp_MSget_new_errorid @error_id OUTPUT
	END

    -- Insert idle record or update if history record is already 'idle'
    IF (@existing_row_updateble = 1) and (@runstatus = @idle or @update_existing_row = 1)
    begin
        -- Attempt to update the last row if it is IDLE
        UPDATE MSmerge_history SET runstatus = @runstatus, time = @current_time, duration = @duration,
            comments = @comments,
            delivery_time = @delivery_time, 
            delivery_rate = @delivery_rate, 
            publisher_insertcount = @publisher_insertcount,
            publisher_updatecount = @publisher_updatecount,
            publisher_deletecount = @publisher_deletecount,
            publisher_conflictcount = @publisher_conflictcount,
            subscriber_insertcount = @subscriber_insertcount,
            subscriber_updatecount = @subscriber_updatecount,
            subscriber_deletecount = @subscriber_deletecount,
            subscriber_conflictcount = @subscriber_conflictcount,
			updateable_row = @this_row_updateable,
			error_id = case @error_id when 0 then error_id else @error_id end    
            WHERE
            agent_id = @agent_id and
            timestamp = @lastrow_timestamp and
            (runstatus = @runstatus or 
			(@update_existing_row = 1 and runstatus in (@idle, @inprogress) and @runstatus in (@idle, @inprogress)))

        -- Insert idle record if there is not one
        if @@ROWCOUNT = 0
            INSERT INTO MSmerge_history
			(
			agent_id, runstatus, start_time, time, duration, comments, delivery_time, delivery_rate, publisher_insertcount,
			publisher_updatecount, publisher_deletecount, publisher_conflictcount, subscriber_insertcount, subscriber_updatecount,
			subscriber_deletecount, subscriber_conflictcount, error_id, timestamp, updateable_row
			)
			VALUES 
			(
			@agent_id, @runstatus, @start_time, @current_time, 
			@duration, @comments,  @delivery_time, @delivery_rate, 
	        @publisher_insertcount, @publisher_updatecount, @publisher_deletecount, @publisher_conflictcount, 
		    @subscriber_insertcount, @subscriber_updatecount, @subscriber_deletecount, @subscriber_conflictcount, 
			@error_id, NULL, @this_row_updateable
			)
    end
    else
    begin
        INSERT INTO MSmerge_history 
		(
			agent_id, runstatus, start_time, time, duration, comments, delivery_time, delivery_rate, publisher_insertcount,
			publisher_updatecount, publisher_deletecount, publisher_conflictcount, subscriber_insertcount, subscriber_updatecount,
			subscriber_deletecount, subscriber_conflictcount, error_id, timestamp, updateable_row
		)
		VALUES 
		(
		@agent_id, @runstatus, @start_time, @current_time, 
        @duration, @comments, @delivery_time, @delivery_rate, 
        @publisher_insertcount, @publisher_updatecount, @publisher_deletecount, @publisher_conflictcount, 
        @subscriber_insertcount, @subscriber_updatecount, @subscriber_deletecount, @subscriber_conflictcount, 
        @error_id, NULL, @this_row_updateable
		)
    end

	-- Refresh repl monitor
	declare @agent_type int
	set @agent_type = dbo.fn_MSmask_agent_type (@agent_id, 4)

    -- Update global replication agent status table
    exec dbo.sp_MSupdate_replication_status 
        @publisher, 
        @publisher_db,
        @publication,
        @publication_type = 2,
        @agent_type = @agent_type,
        @agent_name = @agent_name,
        @status = @runstatus

	-- Raise the appropriate error
	if @do_raiserror = 1
	begin
		select @agentclassname = formatmessage(14554)
		exec dbo.sp_MSrepl_raiserror agentclassname, @agent_name, @runstatus, @comments
	end

    IF @@ERROR <> 0
        RETURN (1)

    RETURN (0)
END
GO   

raiserror(15339,-1,-1,'sp_MSenum_merge')
go
create procedure sp_MSenum_merge
@name nvarchar(100) = '%',
@show_distdb bit = 0,
@exclude_anonymous bit = 0
as
    set nocount on

    declare @publisher sysname
    declare @publisher_id smallint
    declare @publisher_db sysname
    declare @subscriber sysname
    declare @subscriber_id smallint
    declare @subscriber_db sysname
    declare @subscriber_name sysname
    declare @subscription_type int
    declare @publication sysname
    declare @status int
    declare @start_time nvarchar(24)
    declare @time nvarchar(24)
    declare @duration int
    declare @comments nvarchar(255)
    declare @publisher_insertcount int
    declare @publisher_updatecount int
    declare @publisher_deletecount int
    declare @publisher_conflictcount int
    declare @subscriber_insertcount int
    declare @subscriber_updatecount int
    declare @subscriber_deletecount int
    declare @subscriber_conflictcount int
    declare @delivery_rate int
    declare @agent_name nvarchar(100)
    declare @error_id int
    declare @job_id binary(16)
    declare @local_job bit
    declare @profile_id int
    declare @agent_id int
    declare @last_timestamp binary(8)
    declare @offload_enabled bit
    declare @offload_server  sysname
		,@subscriber_type tinyint


    create table #merge_agent (name nvarchar(100) NOT NULL, status int NOT NULL,
        publisher sysname NOT NULL, publisher_db sysname NOT NULL, publication sysname NULL,
        subscriber sysname NOT NULL, subscriber_db sysname NOT NULL, subscription_type int NULL,
        start_time nvarchar(24) NULL, time nvarchar(24) NULL, duration int NULL, 
        comments nvarchar(255) NULL, delivery_rate int NULL,
        publisher_insertcount int NULL, publisher_updatecount int NULL, publisher_deletecount int NULL,
        publisher_conficts int NULL, 
        subscriber_insertcount int NULL, subscriber_updatecount int NULL, subscriber_deletecount int NULL,
        subscriber_conficts int NULL, error_id int NULL, job_id binary(16) NULL,
        local_job bit NULL, profile_id int NOT NULL, agent_id int NOT NULL, last_timestamp binary(8) NOT NULL,
        offload_enabled bit NOT NULL, offload_server sysname NULL,
		subscriber_type tinyint NULL)

    declare hC CURSOR LOCAL FAST_FORWARD FOR
        select p.publisher_id, a.subscriber_id, a.publisher_db, a.subscriber_db, 
            p.publication, a.name, a.local_job, a.job_id, a.profile_id, a.id, a.subscriber_name, 
            offload_enabled, offload_server
            from MSmerge_agents a, MSpublications p
            where 
            a.name LIKE @name and
            a.publisher_id = p.publisher_id and
            a.publisher_db = p.publisher_db and
            a.publication = p.publication and
			(@exclude_anonymous = 0 or a.subscriber_name is null)

        for read only


    OPEN hC
    FETCH hC INTO @publisher_id, @subscriber_id, @publisher_db, @subscriber_db,
        @publication, @agent_name, @local_job, @job_id, @profile_id, @agent_id, @subscriber_name, 
        @offload_enabled, @offload_server

    WHILE (@@fetch_status <> -1)
    begin

        /* Initialize the values for no history case */
        select @status = 0,
            @start_time = NULL,
            @time = NULL, 
            @duration = NULL, 
            @comments = NULL,
            @publisher_insertcount = 0,
            @publisher_deletecount = 0,
            @publisher_updatecount = 0,
            @publisher_conflictcount = 0,
            @subscriber_insertcount = 0,
            @subscriber_deletecount = 0,
            @subscriber_updatecount = 0,
            @subscriber_conflictcount = 0,
            @delivery_rate = 0,
            @error_id = NULL, 
            @last_timestamp = 0x00000000

        select @status = isnull(runstatus,0),
            @start_time = convert(nvarchar(12), start_time, 112) +
                          substring(convert(nvarchar(24), start_time, 121), 11, 13),
            @time = convert(nvarchar(12), time, 112) +
                    substring(convert(nvarchar(24), time, 121), 11, 13), 
            @duration = duration, 
            @comments = comments,
            @publisher_insertcount = publisher_insertcount,
            @publisher_deletecount = publisher_deletecount,
            @publisher_updatecount =  publisher_updatecount,
            @publisher_conflictcount =  publisher_conflictcount,
            @subscriber_insertcount = subscriber_insertcount,
            @subscriber_deletecount = subscriber_deletecount,
            @subscriber_updatecount =  subscriber_updatecount,
            @subscriber_conflictcount =  subscriber_conflictcount,
            -- Note: return average rate here !!! delivery_rate column is current rate
            @delivery_rate = 
                case    when duration <> 0 then 
                            (publisher_insertcount + publisher_updatecount +
                            publisher_deletecount + subscriber_insertcount + 
                            subscriber_updatecount + subscriber_deletecount)/duration
                        when duration = 0 then 0
                end, 
            @error_id = error_id, @last_timestamp = timestamp
            from MSmerge_history
            where
                agent_id = @agent_id and
                timestamp = (select max(timestamp) from MSmerge_history mh2
                    where mh2.agent_id = @agent_id)

        select @publisher = srvname from master..sysservers where srvid = @publisher_id

        -- For non anonymous agents, @subscriber_name is null 
        if @subscriber_name is NULL
            begin
                select @subscriber = srvname from master..sysservers where srvid = @subscriber_id
                if @local_job = 1 select @subscription_type = 0
                    else select @subscription_type = 1
				select @subscriber_type = type from MSsubscriber_info where
					UPPER(publisher) = UPPER(@publisher) and
					UPPER(subscriber) = UPPER(@subscriber)
            end
        else 
            begin
                select @subscriber = @subscriber_name
                select @subscriber_db = @subscriber_db + '-' +  convert(nvarchar(12), @agent_id)
                select @subscription_type = 2   -- anonymous type
            end
        
        insert into #merge_agent values (@agent_name, @status, @publisher,
            @publisher_db, @publication, @subscriber, @subscriber_db, @subscription_type,
            @start_time, @time, @duration, @comments, @delivery_rate,
            @publisher_insertcount, @publisher_updatecount, @publisher_deletecount, 
            @publisher_conflictcount,
            @subscriber_insertcount, @subscriber_updatecount, @subscriber_deletecount, 
            @subscriber_conflictcount,
            @error_id, @job_id, @local_job, @profile_id, @agent_id, @last_timestamp,
            @offload_enabled, @offload_server, @subscriber_type)

        FETCH hC INTO @publisher_id, @subscriber_id, @publisher_db, @subscriber_db,
            @publication, @agent_name, @local_job, @job_id, @profile_id,
            @agent_id, @subscriber_name, @offload_enabled, @offload_server
        end

    if @show_distdb = 0
        select * from #merge_agent 
    else 
        select 'dbname' = DB_NAME(), * from #merge_agent

    drop table #merge_agent
    close hC
    deallocate hC

GO


raiserror(15339,-1,-1,'sp_MSenum_merge_s')
go

create procedure sp_MSenum_merge_s
@name nvarchar(100), 
@hours int = 0, /* @hours < 0 will return TOP 100 */
@session_type int = 1 /* Return all sessions */
as
    set nocount on

    declare @succeed int
    declare @agent_id int
    declare @retry int
    declare @failure int
    declare @min_time datetime

    /* 
    ** Status const defined in sqlrepl.h 
    */
    select @succeed = 2
    select @retry = 5
    select @failure = 6

    select @agent_id = id from MSmerge_agents where name = @name

    /* Get date starting point */
    IF @hours < 0
    BEGIN
        select top 100 runstatus, 
            'start_time' = convert(nvarchar(12), start_time, 112) +
                           substring(convert(nvarchar(24), start_time, 121), 11, 13), 
            'time' = convert(nvarchar(12), time, 112) +
                     substring(convert(nvarchar(24), time, 121), 11, 13), 
            comments, duration, 
            -- Note: return average rate here !!! delivery_rate column is current rate
            case    when duration <> 0 then 
                            (publisher_insertcount + publisher_updatecount +
                            publisher_deletecount + subscriber_insertcount + 
                            subscriber_updatecount + subscriber_deletecount)/duration
                    when duration = 0 then 0
            end, 
            publisher_insertcount, publisher_updatecount, publisher_deletecount, publisher_conflictcount,
            subscriber_insertcount, subscriber_updatecount, subscriber_deletecount, subscriber_conflictcount,
            'action_count' = (select count(*) from MSmerge_history where
                start_time = rh.start_time and agent_id = @agent_id),
            error_id
            from MSmerge_history rh
            where
            agent_id = @agent_id and
            ((@session_type = 1 and
            (runstatus = @succeed or
            runstatus = @retry or
            timestamp = (select max(timestamp) from MSmerge_history rh2 where
                rh2.agent_id = @agent_id))) or 
            runstatus = @failure)
            order by timestamp desc
    END
    ELSE
    BEGIN
        IF @hours = 0
        BEGIN
            select @min_time = NULL
        END
        ELSE
        BEGIN
            select @min_time = dateadd(hour, -@hours, getdate())
        END
        select  runstatus, 
            'start_time' = convert(nvarchar(12), start_time, 112) +
                           substring(convert(nvarchar(24), start_time, 121), 11, 13), 
            'time' = convert(nvarchar(12), time, 112) +
                     substring(convert(nvarchar(24), time, 121), 11, 13), 
            comments, duration, 
            -- Note: return average rate here !!! delivery_rate column is current rate
            case    when duration <> 0 then 
                            (publisher_insertcount + publisher_updatecount +
                            publisher_deletecount + subscriber_insertcount + 
                            subscriber_updatecount + subscriber_deletecount)/duration
                    when duration = 0 then 0
            end, 
            publisher_insertcount, publisher_updatecount, publisher_deletecount, publisher_conflictcount,
            subscriber_insertcount, subscriber_updatecount, subscriber_deletecount, subscriber_conflictcount,
            'action_count' = (select count(*) from MSmerge_history where
                start_time = rh.start_time and agent_id = @agent_id),
            error_id
            from MSmerge_history rh
            where
            agent_id = @agent_id and
            ((@session_type = 1 and
            (runstatus = @succeed or
            runstatus = @retry or
            timestamp = (select max(timestamp) from MSmerge_history rh2 where
                rh2.agent_id = @agent_id))) or 
            runstatus = @failure) and
            (time >= @min_time or @min_time IS NULL)
            order by timestamp desc
    END

GO

raiserror(15339,-1,-1,'sp_MSenum_merge_sd')
go

create procedure sp_MSenum_merge_sd
@name nvarchar(100),
@time datetime = NULL
as
    set nocount on

    declare @start_time datetime
    declare @agent_id int
    declare @time_up datetime

    select @agent_id = id from MSmerge_agents where name=@name
    
    IF @time IS NULL
        select @time = GETDATE()

    /*
    ** Minute-approximate @time can be used.
    ** Note: The select only return datetime data with minute precision
    */
    IF  DATEPART(second, @time) = 0 AND
        DATEPART(millisecond, @time) = 0
    BEGIN
        SELECT @time_up = DATEADD(second, +59, @time)
        SELECT @time_up = DATEADD(millisecond, +999, @time)
    END
    ELSE
        SELECT @time_up = @time
        

    select top 1 @start_time = start_time           
         from MSmerge_history rh
        where
        rh.agent_id = @agent_id and
        time <= @time_up
        order by timestamp DESC

    select  runstatus, 
            'time' = convert(nvarchar(12), time, 112) + 
                     substring(convert(nvarchar(24), time, 121), 11, 13),
            comments, duration, 
        -- Note: return average rate here !!! delivery_rate column is current rate
        case    when duration <> 0 then 
                        (publisher_insertcount + publisher_updatecount +
                        publisher_deletecount + subscriber_insertcount + 
                        subscriber_updatecount + subscriber_deletecount)/duration
                when duration = 0 then 0
        end, 
        publisher_insertcount, publisher_updatecount, publisher_deletecount, publisher_conflictcount,
        subscriber_insertcount, subscriber_updatecount, subscriber_deletecount, subscriber_conflictcount,
        error_id            
        from MSmerge_history rh
        where
        rh.agent_id = @agent_id and
        start_time = @start_time
        order by timestamp desc
GO

raiserror(15339,-1,-1,'sp_MSenableagentoffload')
GO
CREATE PROCEDURE sp_MSenableagentoffload (
    @job_id             VARBINARY(16),
    @offloadserver      sysname = NULL
    ) AS

    SET NOCOUNT ON

    /*
    **  Declarations
    */

    DECLARE @agent_id          INT
    DECLARE @subscription_type INT
    DECLARE @agenttype         NVARCHAR(20)
    DECLARE @agent_table       sysname 
    DECLARE @offloadserverwasnull INT
    DECLARE @retcode           INT
    
    SELECT @agent_id = NULL
    SELECT @subscription_type = 0
    SELECT @agenttype = NULL    
    SELECT @agent_table = RTRIM(@@SERVERNAME) + '.' + db_name() + N'.dbo.'

    -- get the agent type from sysjobsteps table (subsystem) 
    SELECT @agenttype = LOWER(subsystem collate SQL_Latin1_General_CP1_CS_AS) 
      FROM msdb..sysjobsteps 
     WHERE job_id = @job_id
       AND LOWER(subsystem collate SQL_Latin1_General_CP1_CS_AS) IN (N'distribution', N'merge') 
    
    -- validate the agent type, it has to be non null
    IF @agenttype IS NULL
    BEGIN
        RAISERROR(21134, 16, -1)
        RETURN 1
    END

    -- Make sure that the given offload server does not contain
    -- invalid characters
    EXEC @retcode = sp_MSreplcheckoffloadserver @offloadserver
    IF @retcode <> 0 OR @@error <> 0
    BEGIN
        RETURN (1)
    END

    -- validate the existence of the job_id in the agent table and get 
    -- the value of the subscription type and agentid at the same time
    IF @agenttype = N'distribution'
    BEGIN
        SELECT @subscription_type = subscription_type,
               @agent_id = id  
          FROM dbo.MSdistribution_agents
         WHERE job_id = @job_id
        SELECT @agent_table = @agent_table + 'MSdistribution_agents'
    END
    ELSE 
    BEGIN
        SELECT @subscription_type = ms.subscription_type,
               @agent_id = ma.id
          FROM dbo.MSmerge_agents ma 
    INNER JOIN dbo.MSpublications mp 
            ON (ma.publisher_id = mp.publisher_id) 
           AND (ma.publisher_db = mp.publisher_db) 
           AND (ma.publication = mp.publication)
    INNER JOIN dbo.MSmerge_subscriptions ms
            ON (ma.publisher_id = ms.publisher_id)
           AND (ma.publisher_db = ms.publisher_db)
           AND (mp.publication_id = ms.publication_id)
           AND (ma.subscriber_id = ms.subscriber_id)
           AND (ma.subscriber_db = ms.subscriber_db)
     WHERE @job_id = ma.job_id
        SELECT @agent_table = @agent_table + 'MSmerge_agents'
    END

    IF @agent_id IS NULL
    BEGIN
        RAISERROR(21135, 16, -1, @agent_table)
        RETURN 1
    END 
    ELSE IF @@ROWCOUNT > 1
    BEGIN
        RAISERROR(21136, 16, -1, @agent_table)
        RETURN 1
    END

    -- raise error if subscription type is not push
    IF @subscription_type <> 0
    BEGIN
        RAISERROR(21137, 16, -1)
        RETURN 1
    END

    -- raise error if offload server name is the same as the
    -- distributor's name
    IF LOWER(@@SERVERNAME) = LOWER(@offloadserver)
    BEGIN
        RAISERROR(21138, 16, -1)
        RETURN 1
    END

    -- if the offload server name is NULL, try to obtain the offload server
    -- name from the agent table
    IF (@offloadserver IS NULL) OR (@offloadserver = N'')
    BEGIN
        SELECT @offloadserverwasnull = 1
        IF LOWER(@agenttype collate SQL_Latin1_General_CP1_CS_AS) = N'distribution'
        BEGIN
            SELECT @offloadserver = offload_server 
              FROM dbo.MSdistribution_agents
             WHERE id = @agent_id
        END
        ELSE
        BEGIN
            SELECT @offloadserver = offload_server
              FROM dbo.MSmerge_agents
             WHERE id = @agent_id
        END
    END 
    ELSE
    BEGIN
        SELECT @offloadserverwasnull = 0
    END

    -- if offload server name is still NULL, use the subscriber as the target 
    -- server
    IF (@offloadserver IS NULL) OR (@offloadserver = N'')
    BEGIN
        IF LOWER(@agenttype collate SQL_Latin1_General_CP1_CS_AS) = N'distribution'
        BEGIN
            SELECT @offloadserver = ss.srvname 
              FROM master.dbo.sysservers ss 
        INNER JOIN dbo.MSdistribution_agents da 
                ON ss.srvid = da.subscriber_id
             WHERE @agent_id = da.id
        END
        ELSE
        BEGIN
            SELECT @offloadserver = ss.srvname
              FROM master.dbo.sysservers ss 
        INNER JOIN dbo.MSmerge_agents ma
                ON ss.srvid = ma.subscriber_id
             WHERE @agent_id = ma.id
        END
    END

    IF (@offloadserver IS NULL) OR (@offloadserver = N'') 
    BEGIN
        RAISERROR(21139, 16, -1)
        RETURN 1
    END
    ELSE IF LOWER(@offloadserver) = LOWER(@@SERVERNAME) 
    BEGIN
        IF @offloadserverwasnull = 1
        BEGIN
            RAISERROR(21261, 16, -1)
        END
        ELSE
        BEGIN
            RAISERROR(21140, 16, -1)
        END
        RETURN 1
    END

    BEGIN TRANSACTION enable_offload
    
    -- Update the agent table with the new offload settings
    IF LOWER(@agenttype collate SQL_Latin1_General_CP1_CS_AS) = N'distribution'
    BEGIN
        UPDATE MSdistribution_agents
           SET offload_enabled = 1,
               offload_server = @offloadserver
         WHERE id = @agent_id
        IF @@ERROR <> 0
            GOTO Failure
    END
    ELSE
    BEGIN
        UPDATE MSmerge_agents
           SET offload_enabled = 1,
               offload_server = @offloadserver
         WHERE id = @agent_id
        IF @@ERROR <> 0
            GOTO Failure
    END    

    -- Add the offload parameter
    EXEC sp_MSaddoffloadparameter @offloadserver = @offloadserver,
                                  @job_id = @job_id,
                                  @agenttype = @agenttype
    
    IF @@ERROR <> 0
        GOTO Failure
    COMMIT TRANSACTION enable_offload
    RETURN 0
Failure:
    ROLLBACK TRANSACTION enable_offload
    RETURN 1
GO

raiserror(15339,-1,-1,'sp_MSdisableagentoffload')
GO
CREATE PROCEDURE sp_MSdisableagentoffload (
    @job_id         VARBINARY(16),
    @offloadserver  sysname = NULL
    ) AS
    
    SET NOCOUNT ON
    
    DECLARE @agent_id    INT
    DECLARE @agenttype   NVARCHAR(20)

    SELECT @agent_id = NULL
    SELECT @agenttype = NULL

    -- Obtain the agent type from the sysjobssteps table
    SELECT @agenttype = LOWER(subsystem collate SQL_Latin1_General_CP1_CS_AS) 
      FROM msdb..sysjobsteps
     WHERE job_id = @job_id
       AND LOWER(subsystem collate SQL_Latin1_General_CP1_CS_AS) IN (N'merge', N'distribution')

    -- validate the agent type, it has to be either 'merge' or 'distribution'
    IF @agenttype IS NULL
    BEGIN
        RAISERROR(21134, 16, -1)
        RETURN 1
    END

    -- don't check the subscription type 
    BEGIN TRANSACTION disable_offload
    
    -- Update the agent table with the new offload settings
    IF @agenttype = N'distribution'
    BEGIN
        IF @offloadserver IS NULL -- Leave the existing offload server alone
        BEGIN
            UPDATE MSdistribution_agents
               SET offload_enabled = 0
             WHERE job_id = @job_id
            IF @@ERROR <> 0
                GOTO Failure
        END
        ELSE
        BEGIN
            UPDATE MSdistribution_agents
               SET offload_enabled = 0,
                   offload_server = @offloadserver
             WHERE job_id = @job_id            
            IF @@ERROR <> 0
                GOTO Failure
        END    


    END
    ELSE
    BEGIN
        IF @offloadserver IS NULL -- Leave the existing offload server alone
        BEGIN
            UPDATE MSmerge_agents
               SET offload_enabled = 0
             WHERE job_id = @job_id
            IF @@ERROR <> 0
                GOTO Failure
        END
        ELSE
        BEGIN
            UPDATE MSmerge_agents
               SET offload_enabled = 0,
                   offload_server = @offloadserver
             WHERE job_id = @job_id
            IF @@ERROR <> 0
                GOTO Failure
        END
    END    

    -- Call stored procedure to remove -offload parameter from the 
    -- agent command line

    EXEC sp_MSremoveoffloadparameter @job_id = @job_id, 
                                     @agenttype = @agenttype
    IF @@ERROR <> 0
        GOTO Failure
    COMMIT TRANSACTION disable_offload

    RETURN 0
Failure:

    ROLLBACK TRANSACTION disable_offload
    RETURN (1)

GO
    
raiserror(15339,-1,-1,'sp_MSadd_repl_error')
GO

CREATE PROCEDURE sp_MSadd_repl_error (
@id                 int,
@error_type_id      int,
@source_type_id     int,
@source_name        sysname,
@error_code         sysname,
@error_text         ntext
)
AS
    declare @retcode int
	declare @xact_seqno varbinary(16)
	declare @command_id int

    -- Security Check
    -- require the login to be in cache regardless of the publication id and agent_id.
    -- This means that once a agent get into the distribution db, it
    -- can add any error.   
    exec @retcode = dbo.sp_MScheck_pull_access
    if @@error <> 0 or @retcode <> 0
        return (1)

	select @xact_seqno = xact_seqno, @command_id = command_id from MSrepl_errors where
		id = @id and xact_seqno is not null
    
	INSERT INTO MSrepl_errors VALUES (@id, getdate(), @error_type_id, @source_type_id,
        @source_name, @error_code, @error_text, @xact_seqno, @command_id)

    IF @@ERROR <> 0
    BEGIN
       RETURN (1)
    END

    return (0)
GO   


raiserror(15339,-1,-1,'sp_MSadd_repl_alert')
GO

CREATE PROCEDURE sp_MSadd_repl_alert (
@agent_type         int,
@agent_id           int,
@error_id           int,
@alert_error_code   int,
@xact_seqno         varbinary(16),      
@command_id         int,
@publisher          sysname,
@publisher_db       sysname,
@subscriber         sysname,
@subscriber_db      sysname,
@alert_error_text   ntext
)
AS
    SET NOCOUNT ON

    declare @retcode int
    declare @article sysname
    declare @article_id int
    declare @destination_object sysname
    declare @source_object sysname
    declare @publisher_id int
    declare @publication sysname
    declare @publication_id int
    declare @publication_type int
    declare @subscriber_id int
    declare @publisher_database_id int
    declare @agent_type2 int

    -- Security Check
    if @agent_type = 3
        select @agent_type2 = 0 -- distribution
    else if @agent_type = 4
        select @agent_type2 = 1 -- merge

    if @agent_type2 is not null 
    begin
        exec @retcode = dbo.sp_MScheck_pull_access
                @agent_id = @agent_id,
                @agent_type = @agent_type2
        if @@error <> 0 or @retcode <> 0
            return (1)
    end
    else
    begin
        if is_member('db_owner') = 0
        begin
            RAISERROR (14126, 16, -1)
            return(1)
        end
    end

    select @publisher_id = srvid from master..sysservers where UPPER(srvname) = UPPER(@publisher)
    select @subscriber_id = srvid from master..sysservers where UPPER(srvname) = UPPER(@subscriber)
    
    select @publisher_database_id = id from MSpublisher_databases 
    where publisher_id = @publisher_id and publisher_db = @publisher_db

    select @article_id = article_id from MSrepl_commands
    where publisher_database_id = @publisher_database_id
    and xact_seqno = @xact_seqno
    and command_id = @command_id

    select @publication = mp.publication, @publication_id = mp.publication_id, @publication_type = mp.publication_type
    from MSpublications as mp, MSsubscriptions as ms
    where mp.publisher_id = ms.publisher_id
    and mp.publisher_db = ms.publisher_db
    and mp.publication_id = ms.publication_id
    and ms.publisher_id = @publisher_id
    and ms.publisher_db = @publisher_db
    and ms.subscriber_id = @subscriber_id
    and ms.subscriber_db = @subscriber_db
    and ms.article_id = @article_id

    select @article = article, @destination_object = destination_object, @source_object = source_object 
    from MSarticles
    where article_id = @article_id
        and publisher_id = @publisher_id
        and publisher_db = @publisher_db
        and publication_id = @publication_id

     INSERT INTO msdb.dbo.sysreplicationalerts (status, agent_type , agent_id, error_id, alert_error_code, time, publisher,
                                publisher_db, publication, publication_type, subscriber, subscriber_db,
                                article, destination_object, source_object, alert_error_text)
                VALUES (0, @agent_type, @agent_id, @error_id, @alert_error_code, getdate(), @publisher, 
                        @publisher_db, @publication, @publication_type, @subscriber, @subscriber_db, 
                        @article, @destination_object, @source_object, @alert_error_text)
    
    IF @@ERROR <> 0
    BEGIN
       RETURN (1)
    END

    return (0)
GO   

raiserror(15339,-1,-1,'sp_MSadd_replmergealert')
GO

CREATE PROCEDURE sp_MSadd_replmergealert (
@agent_type         int,
@agent_id           int,
@error_id           int,
@alert_error_code   int,
@publisher          sysname,
@publisher_db       sysname,
@publication        sysname,
@publication_type   int,
@subscriber         sysname,
@subscriber_db      sysname,
@article            sysname,
@destination_object sysname,
@source_object      sysname,
@alert_error_text   ntext
)
AS
    SET NOCOUNT ON
            
    INSERT INTO msdb.dbo.sysreplicationalerts (status, agent_type , agent_id, error_id, alert_error_code, time, publisher,
                                publisher_db, publication, publication_type, subscriber, subscriber_db,
                                article, destination_object, source_object, alert_error_text)
                VALUES (0, @agent_type, @agent_id, @error_id, @alert_error_code, getdate(), @publisher, 
                        @publisher_db, @publication, @publication_type, @subscriber, @subscriber_db, 
                        @article, @destination_object, @source_object, @alert_error_text)
    
    IF @@ERROR <> 0
    BEGIN
       RETURN (1)
    END

    return (0)
GO   


raiserror(15339,-1,-1,'sp_MSget_repl_error')
GO

create procedure sp_MSget_repl_error (
@id int
)
as
    set nocount on
    select  source_type_id, source_name, error_code, error_text, 
            convert(nvarchar(12), time, 112) + 
            substring(convert(nvarchar(24), time, 121), 11, 13),
            error_type_id, 
			'has_xact_seqno' = case when xact_seqno is null or xact_seqno = 0x0
				then convert(bit, 0) else convert(bit, 1) end,
			xact_seqno, command_id
        from MSrepl_errors
        where
            id = @id and
            -- rows with error_type_id are placeholders
            error_type_id IS NOT NULL
        order by time ASC
GO


raiserror(15339,-1,-1,'sp_MSdist_activate_auto_sub')
go
CREATE PROCEDURE sp_MSdist_activate_auto_sub
@publisher_id int,
@publisher_db sysname,
@article_id int

as
    
  declare @automatic tinyint
  declare @active tinyint
  declare @subscribed tinyint

   set nocount on

    select @automatic = 1

    select @subscribed = 1
    select @active = 2

    begin transaction MSdist_activate_auto_sub

       update MSsubscriptions set status = @active,
            subscription_time = getdate()
           where
              publisher_id = @publisher_id and
              publisher_db = @publisher_db and
              article_id = @article_id and
              sync_type = @automatic and
              status in( @subscribed )

       if @@ERROR <> 0
          begin
          if @@trancount > 0
            rollback transaction MSdist_activate_auto_sub
          return (1)
          end

   commit transaction

GO

raiserror(15339,-1,-1,'sp_MSlock_auto_sub')
go
CREATE PROCEDURE sp_MSlock_auto_sub
@publisher_id int,
@publisher_db sysname,
@publication sysname,
@reset bit = 0  /* @reset = 1 is used for Scheduled Snapshot publications by snapshot */

as
    
  /* This sp only work for 7.0 publisher since it use the publication name */  
   set nocount on

    DECLARE @virtual smallint     /* const: virtual subscriber id */
    DECLARE @virtual_anonymous smallint /* const: virtual anonymous subscriber id */
    DECLARE @subscribed tinyint
    DECLARE @automatic tinyint
    DECLARE @publication_id int
    DECLARE @counter int
    DECLARE @independent_agent bit
    DECLARE @active tinyint

    SELECT @virtual = -1
    SELECT @virtual_anonymous = -2
    SELECT @subscribed = 1
    SELECT @active = 2
    SELECT @automatic = 1

    select @publication_id = publication_id , @independent_agent = independent_agent
        from MSpublications 
        where 
        publisher_id = @publisher_id and
        publisher_db = @publisher_db and
        publication = @publication 


    /* 
    ** Set exclusive lock on the rows that will be updated to prevent deadlock 
    **      in snapshot agent.
    ** Note: using UPDATE lock may cause deadlock with sp_MSget_repl_commands as following
    ** 1. The distribution agent gets shared lock on MSsubscriptions.
    ** 2. The snapshot agent gets update lock on MSsubscriptions.
    ** 3. The snapshot agent gets exclusive lock on MSrepl_commands (inserting into the table)
    ** 4. The distribution agent waits to get shared lock on MSrepl_commands
    ** 5. The snapshot agent waits to convert update lock to exclusive lock on MSrepl_subscriptions (updating the table).
    */
    --SELECT @counter = COUNT(*) FROM MSsubscriptions (ROWLOCK UPDLOCK)
    -- 1. Avoid defered updates: Don't update fields in the clusted index
    -- 2. Avoid updating fields in the where clause 
    UPDATE MSsubscriptions SET update_mode = update_mode 
      WHERE 
         publisher_id = @publisher_id and
         publisher_db = @publisher_db and
         publication_id = @publication_id and 
         /* virtual subscriptions are automatic sync type */
         sync_type = @automatic and 
         (status = @subscribed or 
         subscriber_id = @virtual or
         subscriber_id = @virtual_anonymous or
         @reset = 1) 
GO

raiserror(15339,-1,-1,'sp_MSget_new_xact_seqno')
go
CREATE PROCEDURE sp_MSget_new_xact_seqno
@publisher_id int,
@publisher_db sysname,
@len    tinyint

AS
   declare @new_xact_seqno varbinary(16)
   declare @old_xact_seqno varbinary(16)
   declare @tag int
   declare @datalen tinyint
   declare @publisher_database_id int

   set nocount on 
   select @old_xact_seqno = NULL

    -- Get publisher database id.
    SELECT @publisher_database_id = id from MSpublisher_databases where publisher_id = @publisher_id and 
        publisher_db = @publisher_db

   set rowcount 1
   select @old_xact_seqno = rt.xact_seqno
      from
      -- Prevent inserts
      MSrepl_transactions rt (HOLDLOCK PAGLOCK UPDLOCK)
      where 
         rt.publisher_database_id = @publisher_database_id 
         order by xact_seqno desc
   set rowcount 0

   
   if @old_xact_seqno IS NULL
   begin
        /* if nothing got selected, lock the entire table 
        ** Don't return meta data !!
        */
       select @old_xact_seqno = rt.xact_seqno
          from
          MSrepl_transactions rt (HOLDLOCK TABLOCKX)
          where 0 = 1

        select @old_xact_seqno = subscription_seqno from MSsubscriptions 
        where
            publisher_database_id = @publisher_database_id and
            subscription_seqno = (select MAX(subscription_seqno) from MSsubscriptions rs2
            where
                rs2.publisher_database_id = @publisher_database_id)
   end

    select @datalen = datalength(@old_xact_seqno) 
    /* Plus one to the tag */
    if @datalen = @len
    begin
        select @tag = convert( int, convert( binary(4), substring( convert( nvarchar, @old_xact_seqno ), @datalen/2 - 2 + 1,2 ) ) )
        
        if @tag = 0xffffffff
        begin
            raiserror(21018, 16, -1)
            return(1)
        end
        /* avoid arithmatic overflow */
        if @tag = 0x7fffffff
            select @tag = 0x80000000
        else 
            select @tag = @tag + 1

        select @new_xact_seqno = 
        convert( varbinary, substring( convert(nvarchar, @old_xact_seqno), 1, @datalen/2-2)) +
        convert( VARBINARY(4), @tag )

    end
    /* Add a tag */
    else
    begin
        if @datalen + 4 <> @len
        begin
            -- We are in trouble if we reach here.
            return(1)
        end
        select @tag = 1
        select @new_xact_seqno = 
            @old_xact_seqno + CONVERT(VARBINARY(4), @tag) 
    end

   select @new_xact_seqno
GO



raiserror(15339,-1,-1,'sp_MSchange_publication')
go
 CREATE PROCEDURE sp_MSchange_publication (
 	@publisher sysname,
 	@publisher_db sysname,
 	@publication sysname,
 	@property sysname,
 	@value nvarchar(255)
 	)
as
BEGIN
    set nocount on
    
 	declare @publisher_id smallint
 			,@publication_type int
 			,@retcode int
 			,@max_distretention int
 			,@retention_value int
 			,@cmd    nvarchar(255)
 			,@cmd2   nvarchar(255)
 			,@cmd3   nvarchar(255)

    -- Check if publisher is a defined as a distribution publisher in the current database
    exec @retcode = dbo.sp_MSvalidate_distpublisher @publisher, @publisher_id OUTPUT
    if @retcode <> 0
    begin
        return(1)
    end

    /* Charater properties  */

    begin tran

    IF LOWER(@property collate SQL_Latin1_General_CP1_CS_AS) ='description'
    BEGIN
        UPDATE MSpublications SET description = @value
            WHERE   publisher_id = @publisher_id AND
                    publisher_db = @publisher_db AND
                    publication = @publication
        IF @@ERROR <> 0 
            goto UNDO
    END
    ELSE IF LOWER(@property collate SQL_Latin1_General_CP1_CS_AS) IN ('snapshot_agent')
    BEGIN
        -- local job name is internal and should not be changed
        if exists (select * from MSsnapshot_agents where
            publisher_id = @publisher_id and
            publication = @publication and
            publisher_db = @publisher_db and
            local_job = 1)
        begin
            raiserror(21030, 16, -1)
            goto UNDO
        end

        -- Drop and recreate
        exec @retcode = dbo.sp_MSdrop_snapshot_agent
            @publisher = @publisher,
            @publisher_db = @publisher_db,
            @publication = @publication

        IF @@ERROR <> 0 or @retcode <> 0
            goto UNDO

        exec @retcode = dbo.sp_MSadd_snapshot_agent
            @name = @value,
            @publisher = @publisher,
            @publisher_db = @publisher_db,
            @publication = @publication,
            @local_job = 0

        IF @@ERROR <> 0 or @retcode <> 0
            goto UNDO
    END
    ELSE IF LOWER(@property collate SQL_Latin1_General_CP1_CS_AS) IN ('logreader_agent')
    BEGIN
        -- local job name is internal and should not be changed
        if exists (select * from MSlogreader_agents where
            publisher_id = @publisher_id and
            publication = @publication and
            publisher_db = @publisher_db and
            local_job = 1)
        begin
            raiserror(21030, 16, -1)
            goto UNDO
        end

        -- Drop and recreate
        exec @retcode = dbo.sp_MSdrop_logreader_agent
            @publisher = @publisher,
            @publisher_db = @publisher_db,
            @publication = @publication

        IF @@ERROR <> 0 or @retcode <> 0
            goto UNDO

        exec @retcode = dbo.sp_MSadd_logreader_agent
            @name = @value,
            @publisher = @publisher,
            @publisher_db = @publisher_db,
            @publication = @publication,
            @local_job = 0

        IF @@ERROR <> 0 or @retcode <> 0
            goto UNDO
    END
    ELSE if LOWER(@property collate SQL_Latin1_General_CP1_CS_AS) IN ('retention')
    BEGIN
    	select @retention_value = convert(int, @value)
		select @publication_type = publication_type
			from MSpublications
			WHERE   publisher_id = @publisher_id AND
                    publisher_db = @publisher_db AND
                    publication = @publication
        UPDATE MSpublications set retention=@retention_value 
        WHERE   publisher_id = @publisher_id AND
                    publisher_db = @publisher_db AND
                    publication = @publication
        if @@ERROR<>0
        		goto UNDO
    END
 	ELSE if LOWER(@property collate SQL_Latin1_General_CP1_CS_AS) = ('queue_type')
 	BEGIN
 		--
 		-- If we have come here, it is for MSMQ queue type.
 		-- Distributor needs to support MSMQ 2.0 - Just check that
 		--
 		if (convert(int, @value) = 1)
 		begin
 			--
 			-- Now we use xp_MSver to detect NT OS version
 			-- MSMQ subscription only allowed for platforms that support MSMQ 2.0
 			-- version 5.0.2195 or higher
 			--
 			create table #tosversion ( propid int, propname sysname collate database_default, value int, charvalue nvarchar(255) collate database_default)
 			insert into #tosversion (propid, propname, value, charvalue)
 				exec master.dbo.xp_msver N'WindowsVersion'
 
 			declare @vervalue int
 				,@lobyte tinyint
 				,@hibyte tinyint
 				,@loword smallint
 				,@hiword smallint
 
 			--
 			-- low order byte of low order word = OSmajor, high order byte of low order word = OSminor
 			-- high order word = OSbuild
 			--
 			select @vervalue = value from #tosversion where propname = N'WindowsVersion'
 			select @loword = (@vervalue & 0xffff)
 					,@hiword = (@vervalue / 0x10000) & 0xffff
 			select @lobyte = @loword & 0xff
 					,@hibyte = (@loword / 100) & 0xff
 			drop table #tosversion
 
 			--
 			-- check for OS major version
 			--
 			if (@lobyte < 5)
 			begin
 				raiserror(21334, 16, 6, '2.0')
 				goto UNDO
 			end
 
 			--
 			-- check for OS build version
 			--
 			if (@lobyte = 5 and @hiword < 2195)
 			begin
 				raiserror(21334, 16, 7, '2.0')
 				goto UNDO
 			end
 		end
 	END
    ELSE
    BEGIN
        SELECT @cmd = ''
        SELECT @cmd = @cmd + 'UPDATE MSpublications '
        SELECT @cmd = @cmd + '   SET ' + LOWER(@property collate SQL_Latin1_General_CP1_CS_AS) + ' = '
        /* @value can be 255 nchars, so don't append it */
        SELECT @cmd2 = ' WHERE publisher_id = ' + STR(@publisher_id)
        SELECT @cmd2 =  @cmd2 + ' AND publisher_db = ' + quotename(@publisher_db,'''')
        SELECT @cmd2 =  @cmd2 + ' AND publication = '  + quotename(@publication, '''')
        EXECUTE (@cmd + @value + @cmd2)
        IF @@ERROR <> 0 
            goto UNDO
    END

    COMMIT TRAN

    RETURN(0)

UNDO:
    IF @@TRANCOUNT = 1
        ROLLBACK TRAN
    ELSE
        COMMIT TRAN   
    RETURN (1)
END
go


raiserror(15339,-1,-1,'sp_MSadd_article')
go
CREATE PROCEDURE sp_MSadd_article
@publisher sysname,
@publisher_db sysname,
@publication sysname,
@article sysname,
@article_id int = NULL,
@destination_object sysname = NULL,
@source_object sysname = NULL,
@description nvarchar(255) = NULL,
@source_owner   sysname = NULL
as

    set nocount on

    declare @publisher_id smallint
    declare @publication_id int
    declare @retcode int
    declare @thirdparty_flag bit
    declare @immediate_sync bit
    declare @allow_anonymous bit
    declare @subscription_seqno binary(16)
    declare @subscribed tinyint
    declare @active tinyint

    select @subscribed = 1  
    select @active = 2
        
    -- Check if publisher is a defined as a distribution publisher in the current database
    exec @retcode = dbo.sp_MSvalidate_distpublisher @publisher, @publisher_id OUTPUT
    if @retcode <> 0
    begin
        return(1)
    end

    -- Get publication id
    select @publication_id = publication_id,  
        @thirdparty_flag = thirdparty_flag,
        @immediate_sync = immediate_sync, @allow_anonymous = allow_anonymous 
        from MSpublications where
        publisher_id = @publisher_id and 
        publisher_db = @publisher_db and
        publication = @publication
    if @publication_id is NULL
    begin
        raiserror (20026, 11, -1, @publication)
        return (1)
    end

    -- Make sure article does not already exist
    if exists (select * from MSarticles where publication_id = @publication_id and
        publisher_id = @publisher_id and publisher_db = @publisher_db and article = @article)
    begin
        if @thirdparty_flag = 1
        begin
            raiserror (14030, 16, -1, @article, @publication)
            return (1)
        end
        else
        begin
            exec @retcode = dbo.sp_MSdrop_article
                @publisher = @publisher,
                @publisher_db = @publisher_db,
                @publication = @publication,
                @article = @article
            if @retcode <> 0 or @@error <> 0
            begin
                return (1)
            end
        end
    end

	-- If it is a third party publication - check if a subscription exists
	-- for the publication already. If it does then we cannot add any
	-- articles - the existing subscriptions will have to dropped first and then
	-- resubscribed
	-- excluding virtual subscriptions.
	if (@thirdparty_flag = 1)
	begin
		if exists (select * from MSsubscriptions where 
				publisher_id = @publisher_id and 
				publisher_db = @publisher_db and 
				publication_id = @publication_id and
				subscriber_id >= 0)
		begin
			raiserror(21131, 16, -1, @publication)
			return (1)
		end
	end

    begin tran
    save tran MSadd_article

	-- Generate new article id when one is not provided by a 
	-- third party publisher or merge publication
	if @article_id is NULL
	begin
		if (@thirdparty_flag = 1)
		begin
			-- Generate unique id per publisher
			select @article_id = max(article_id) + 1 from MSarticles where 
				publisher_id = @publisher_id
		end
		else
		begin
			-- 6.5 behavior : retain for compatibility
			-- NOTE: article_id is incremented per publisher/publisher_db/publication
			select @article_id = max(article_id) + 1 from MSarticles where 
				publisher_id = @publisher_id and
				publisher_db = @publisher_db and
				publication_id = @publication_id
		end

		if @article_id is null
			select @article_id = 1
	end
	else
	begin
		--
		-- for third party publisher - validate the article id
		--
		if (@thirdparty_flag = 1)
		begin
			if exists (select * from MSarticles where
					article_id = @article_id and
					publisher_id = @publisher_id and
					publisher_db = @publisher_db and
					publication_id = @publication_id)
			begin
				if @@trancount > 0
				begin
					rollback tran MSadd_article
					commit tran
				end
				raiserror (14155, 16, 2)
				return (1)
			end
		end
	end

    insert into MSarticles values (@publisher_id, @publisher_db, @publication_id,
        @article, @article_id, @destination_object, @source_owner, @source_object, @description)
    if @@error <> 0
    begin
        if @@trancount > 0
        begin
            rollback tran MSadd_article
            commit tran
        end
        return (1)
    end

    -- For third party publications create immediate sync and anonymous virtual subscription
    -- with 'subscribed' status and then change anonymous virtual to 'active' status
    -- SQL Server publications will do this via RPC calls to sp_MSadd_subscription
    if @thirdparty_flag = 1 
    begin
        select @subscription_seqno = 0x00  
        if @immediate_sync = 1
        begin
			-- @status passed to sp_MSadd_subscription should always be @subscribed.
            exec @retcode = dbo.sp_MSadd_subscription
                @publisher = @publisher,
                @publisher_db = @publisher_db,
                @publication = @publication,
                @article_id = @article_id,
                @subscriber = NULL,                 -- virtual subscription
                @status = @subscribed,              
                @subscription_seqno = @subscription_seqno,
                @sync_type = 1  -- virtual subscriptions are automatic sync type 
            if @retcode <> 0 or @@error <> 0
            begin
                if @@trancount > 0
                begin
                    rollback tran MSadd_article
                    commit tran
                end
                return (1)
            end
			-- For SQL publications, we have logic to immediately active the 
			-- virtual anonymous subscription to no_sync subscriptions. However, this
			-- feature is not exposed (You need to pass undocumented command line arg 
			-- '-NoInitialSync' to the distribution agent for the anonymous subscription).
			-- Do the same for 3rd party publications

			if @allow_anonymous = 1
			begin
/*
@publisher sysname,
@publisher_db sysname,
@subscriber sysname,
@article_id int,
@status int,
@subscription_seqno varbinary(16),
--post 6x
@destination_db sysname = '%'
*/
				exec @retcode = dbo.sp_MSupdate_subscription
					@publisher = @publisher,
					@publisher_db = @publisher_db,
					@subscriber = NULL,                 -- virtual subscription
					@article_id = @article_id,
					@status = @active,              
					@subscription_seqno = @subscription_seqno,
					@destination_db = '%' -- For virtual sub, @destination_db is not used. Can pass in anything
				if @retcode <> 0 or @@error <> 0
				begin
					if @@trancount > 0
					begin
						rollback tran MSadd_article
						commit tran
					end
					return (1)
				end
			end
        end
    end

    commit tran
go

raiserror(15339,-1,-1,'sp_MSchange_article')
go
CREATE PROCEDURE sp_MSchange_article
@publisher sysname,
@publisher_db sysname,
@publication sysname,
@article sysname,
@article_id int,
@property nvarchar(20) = NULL,
@value nvarchar(255) = NULL
AS
	DECLARE @retcode int
	DECLARE @publisher_id smallint
	DECLARE @publication_id int
	declare @tablename sysname

	-- Get publisher id

    exec @retcode = dbo.sp_MSvalidate_distpublisher @publisher, @publisher_id OUTPUT
    if @retcode <> 0
    begin
        return(1)
    end

	-- lower case property
	select @property = lower (@property)
    
	-- Get publication id

    select @publication_id = publication_id
        from MSpublications where
        publisher_id = @publisher_id and 
        publisher_db = @publisher_db and
        publication = @publication
    if @publication_id is NULL
    begin
        raiserror (20026, 11, -1, @publication)
        return (1)
    end

	if @property = N'description'     
	begin
		update MSarticles set description = @value
		where publisher_id = @publisher_id
		and publisher_db = @publisher_db
		and publication_id = @publication_id
		and article = @article
		and article_id = @article_id
		if @@error <> 0
		begin
			return 1
		end
	end
	else if @property in( N'dest_table', N'dest_object' )
	begin
		update MSarticles set destination_object = @value
		where publisher_id = @publisher_id
		and publisher_db = @publisher_db
		and publication_id = @publication_id
		and article = @article
		and article_id = @article_id
		if @@error <> 0
		begin
			return 1
		end
	end
	else if @property = 'identity_range'
	begin
		declare @range bigint
		select @range = convert(bigint, @value)
		select @tablename = source_object from MSarticles 
			where publisher_id = @publisher_id
			and publisher_db = @publisher_db
			and publication_id = @publication_id
			and article = @article
			and article_id = @article_id

		update MSrepl_identity_range set range = @range where
			publisher = @publisher and
			publisher_db = @publisher_db and
			tablename = @tablename
		if @@error <> 0
		begin
			return 1
		end
	end
	else if @property = 'threshold'
	begin
		declare @threshold int
		select @threshold = convert(int, @value)
		select @tablename = source_object from MSarticles 
			where publisher_id = @publisher_id
			and publisher_db = @publisher_db
			and publication_id = @publication_id
			and article = @article
			and article_id = @article_id

		update MSrepl_identity_range set threshold = @threshold where
			publisher = @publisher and
			publisher_db = @publisher_db and
			tablename = @tablename
		if @@error <> 0
		begin
			return 1
		end
	end
	else
	begin
		return 1
	end
go


raiserror(15339,-1,-1,'sp_MShelp_publication')
go   
CREATE PROCEDURE sp_MShelp_publication (
@publisher sysname,
@publisher_db sysname = '%',
@publication sysname = '%')
as
BEGIN
    set nocount on
    declare @queued_agent sysname
    declare @retcode int
    declare @pubid int

    SELECT @retcode = 0

    /*
    ** Create a temp table of pubids identifying publications that the current user has access to
    */
    CREATE TABLE #accessiblepubs (pubid int)

    DECLARE hC  CURSOR LOCAL FAST_FORWARD FOR 
        SELECT publication_id FROM MSpublications WHERE publication like @publication
    OPEN hC
    FETCH hC INTO @pubid
    WHILE (@@fetch_status <> -1)
    BEGIN
        IF is_member(N'db_owner') <> 1 AND is_member(N'replmonitor') <> 1
        BEGIN
            exec @retcode = sp_MScheck_pull_access
                @publication_id = @pubid,
                @raise_fatal_error = 0
	END			
        IF (is_member(N'db_owner') = 1) OR
           (is_member(N'replmonitor') = 1) OR
           (@retcode = 0 AND @@error = 0)
           INSERT INTO #accessiblepubs values(@pubid)

        FETCH hC INTO @pubid
    END
    CLOSE hC
    DEALLOCATE hC
    
    if @publisher_db != '%' and @publication != '%' and not exists (select * from MSpublications where
        publisher_id = (select srvid from master..sysservers where UPPER(srvname) = UPPER(@publisher)) and
        ((@publisher_db = N'%') or (publisher_db = @publisher_db)) and
        publication like @publication)
    begin
        raiserror(20026, 16, -1, @publication)
        return(1)
    end

    select @queued_agent = name from MSqreader_agents 
    select p.publisher_db, p.publication, p.publication_id, p.publication_type, 
        --thirdparty_flag, 
        independent_agent,
        immediate_sync, allow_push, allow_pull, allow_anonymous, 'snapshot_agent' = s.name,
        'logreader_agent' = l.name, p.description, vendor_name 
        -- queue reader agent only if we have valid queued subscription
        ,'queuereader agent' = case 
        	when (exists (select * from MSsubscriptions sub where sub.publisher_id = p.publisher_id and
						sub.publisher_db = p.publisher_db and sub.publication_id = p.publication_id and
						(sub.update_mode in (2,3,4,5)))) 
			then @queued_agent else NULL end
		,'thirdparty_options' = thirdparty_options
		,'snapshot_jobid' = j.job_id
        from #accessiblepubs a
        LEFT OUTER JOIN MSpublications p
        ON
        p.publication_id = a.pubid 
        LEFT OUTER JOIN MSsnapshot_agents s
        ON
        s.publisher_id = p.publisher_id and
        s.publisher_db = p.publisher_db and
        s.publication = p.publication
        LEFT OUTER JOIN MSlogreader_agents l
        ON
        (l.publisher_id = p.publisher_id and
        l.publisher_db = p.publisher_db and
        p.publication_type = 0 and              -- Only Transactional Publication has a  Log Reader
        (l.publication = p.publication OR
         thirdparty_flag = 0))
		LEFT OUTER JOIN msdb..sysjobs_view j
		ON
		s.job_id = j.job_id
      where 
        p.publisher_id = (select srvid from master..sysservers where UPPER(srvname) = UPPER(@publisher)) and
        ((@publisher_db = N'%') or (p.publisher_db = @publisher_db)) and
        p.publication like @publication
END
go

raiserror(15339,-1,-1,'sp_MShelp_article')
go
CREATE PROCEDURE sp_MShelp_article 
@publisher sysname,
@publisher_db sysname,
@publication sysname,        
@article sysname = '%'
as

    set nocount on

    select article, article_id, source_object, description, source_owner from MSarticles a where 
        a.publisher_id = (select srvid from master..sysservers where UPPER(srvname) = UPPER(@publisher)) and 
        a.publisher_db = @publisher_db and
        a.publication_id = (select publication_id from MSpublications where 
            publisher_id = a.publisher_id and
            publisher_db = a.publisher_db and
            publication = @publication) and
        a.article like @article
go

raiserror(15339,-1,-1,'sp_MShelp_subscription')
go
CREATE PROCEDURE sp_MShelp_subscription 
@publisher sysname,
@publisher_db sysname,
@publication sysname,        
@subscriber sysname = '%',              
@subscriber_db sysname = '%'
as
set nocount on

    select distinct ss.srvname + ':' + s.subscriber_db, ss.srvname, s.subscriber_db, s.subscription_type, 
        sync_type, status, agent.name, agent.job_id from 
        MSsubscriptions s, master..sysservers ss, MSdistribution_agents agent where 
        s.publisher_id = (select srvid from master..sysservers where UPPER(srvname) = UPPER(@publisher)) and 
        s.publisher_db = @publisher_db and
        s.publication_id = (select publication_id from MSpublications where 
            publisher_id = s.publisher_id and
            publisher_db = s.publisher_db and
            publication = @publication) and
        ((@subscriber_db = N'%') or (s.subscriber_db = @subscriber_db)) and
        s.subscriber_id = ss.srvid and
        ((@subscriber = N'%') or (UPPER(ss.srvname) = UPPER(@subscriber))) and
        s.subscriber_id >= 0 and                    -- ignore virtual subscriptions
        s.agent_id = agent.id
go

raiserror(15339,-1,-1,'sp_MSadd_subscription_3rd')
go
CREATE PROCEDURE sp_MSadd_subscription_3rd
@publisher sysname,
@publisher_db sysname,
@publication sysname,
@subscriber sysname,       
@subscriber_db sysname = NULL,
@status tinyint,                    -- 0 = inactive, 1 = subscribed, 2 = active 
@subscription_type tinyint = 0,     -- 0 = push, 1 = pull, 2 = anonymous 
@sync_type tinyint = 2,             -- 0 = none  1 = automatic snaphot  2 = no intial snapshot

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

@distribution_jobid binary(8) = NULL OUTPUT

as
    set nocount on

    declare @retcode int
    declare @publication_id int
    declare @article_id int
    declare @virtual_id smallint
    declare @publisher_id smallint
    declare @immediate_sync bit
    declare @allow_push bit
    declare @allow_pull bit
    declare @allow_anonymous bit
    declare @subscription_seqno binary(16)

    select @virtual_id = -1

    -- Check if publisher is a defined as a distribution publisher in the current database
    exec @retcode = dbo.sp_MSvalidate_distpublisher @publisher, @publisher_id OUTPUT
    if @retcode <> 0
    begin
        return(1)
    end

    -- Get publication information
    select @publication_id = publication_id, @immediate_sync = immediate_sync,
        @allow_push = allow_push, @allow_pull = allow_pull, @allow_anonymous = allow_anonymous
        from MSpublications where
        publisher_id = @publisher_id and
        publisher_db = @publisher_db and
        publication = @publication
    if @publication_id is null
    begin
        raiserror(14016, 16, -1, @publication)
        return (1)
    end

    -- Check if publication supports subscription type
    if @subscription_type = 0 and @allow_push != 1
    begin
        raiserror(20034, 16, -1, @publication, 'push')
        return (1)
    end
    else if @subscription_type = 1 and @allow_pull != 1
    begin
        raiserror(20034, 16, -1, @publication, 'pull')
        return (1)
    end
    else if @subscription_type = 2 and @allow_anonymous != 1
    begin
        raiserror(20034, 16, -1, @publication, 'anonymous')
        return (1)
    end

    begin tran
    save tran MSadd_subscription_3rd

    -- Add a subscription for each article in the publication
    declare hCMSadd_subscription_3rd CURSOR LOCAL FAST_FORWARD FOR 
        select article_id from MSarticles a where
            a.publisher_id = @publisher_id and
            a.publisher_db = @publisher_db and
            a.publication_id = @publication_id
        for read only

    open hCMSadd_subscription_3rd
    fetch hCMSadd_subscription_3rd into @article_id
        
    while (@@fetch_status <> -1)
    begin
        if @immediate_sync = 1
            select @subscription_seqno = subscription_seqno from MSsubscriptions where
                publisher_id = @publisher_id and
                publisher_db = @publisher_db and
                article_id = @article_id and
                subscriber_id = @virtual_id 
        else
            select @subscription_seqno = 0x00 

        exec @retcode = dbo.sp_MSadd_subscription
            @publisher = @publisher,
            @publisher_db = @publisher_db,
            @publication = @publication,        -- Must provide this
            @article_id = @article_id,
            @subscriber = @subscriber,       
            @subscriber_db = @subscriber_db,
            @status = @status,
            @subscription_seqno = @subscription_seqno,
            @subscription_type = @subscription_type,
            @sync_type = @sync_type,

            @frequency_type = @frequency_type,
            @frequency_interval = @frequency_interval,
            @frequency_relative_interval = @frequency_relative_interval,
            @frequency_recurrence_factor = @frequency_recurrence_factor,
            @frequency_subday = @frequency_subday,
            @frequency_subday_interval = @frequency_subday_interval,
            @active_start_time_of_day = @active_start_time_of_day,
            @active_end_time_of_day = @active_end_time_of_day,
            @active_start_date = @active_start_date,
            @active_end_date = @active_end_date,

            @distribution_jobid = @distribution_jobid output
        if @retcode != 0 or @@error != 0
        begin
            close hCMSadd_subscription_3rd
            deallocate hCMSadd_subscription_3rd
            if @@trancount > 0
            begin
                rollback tran MSadd_subscription_3rd
                commit tran
            end
            return(1)
        end

        fetch hCMSadd_subscription_3rd into @article_id
    end

    close hCMSadd_subscription_3rd
    deallocate hCMSadd_subscription_3rd

    -- If article_id is null, there were no articles defined for the publication
    if @article_id is NULL
    begin
        raiserror(14009, 16, -1, @publication)
        if @@trancount > 0
        begin
            rollback tran MSadd_subscription_3rd
            commit tran
        end
        return (1)
    end

    commit tran

go

raiserror(15339,-1,-1,'sp_MSdrop_subscription_3rd')
go
CREATE PROCEDURE sp_MSdrop_subscription_3rd
@publisher sysname,
@publisher_db sysname,
@publication sysname,
@subscriber sysname,       
@subscriber_db sysname = NULL

as
    set nocount on

    declare @retcode int
    declare @article_id int
    declare @publisher_id smallint
    declare @publication_id int

    -- Check if publisher is a defined as a distribution publisher in the current database
    exec @retcode = dbo.sp_MSvalidate_distpublisher @publisher, @publisher_id OUTPUT
    if @retcode <> 0
    begin
        return(1)
    end

    -- Get publication information
    select @publication_id = publication_id from MSpublications where
        publisher_id = @publisher_id and
        publisher_db = @publisher_db and
        publication = @publication
    if @publication_id is null
    begin
        raiserror(14016, 16, -1, @publication)
        return (1)
    end

    begin tran
    save tran MSdrop_subscription_3rd

    -- Drop the subscription for each article in the publication
    if lower(@subscriber) = 'all' and lower(@subscriber_db) = 'all'
    begin
        declare hCMSdrop_subscription_3rd CURSOR LOCAL FAST_FORWARD FOR 
            select a.article_id, srv.srvname, sub.subscriber_db 
                from MSarticles a, MSsubscriptions sub, master..sysservers srv where
                a.publisher_id = @publisher_id and
                a.publisher_db = @publisher_db and
                a.publication_id = @publication_id and
                sub.article_id = a.article_id and
                sub.publisher_id = @publisher_id and
                sub.publisher_db = @publisher_db and
                sub.publication_id = @publication_id and
                srv.srvid = sub.subscriber_id and
                sub.subscriber_id >= 0
            union
            -- For virtual subscriptions
            select a.article_id, convert(sysname, null), convert(sysname, null)
                from MSarticles a where
                a.publisher_id = @publisher_id and
                a.publisher_db = @publisher_db and
                a.publication_id = @publication_id and
                exists (select * from MSsubscriptions sub where
                    sub.article_id = a.article_id and
                    sub.publisher_id = @publisher_id and
                    sub.publisher_db = @publisher_db and
                    sub.publication_id = @publication_id and
                    sub.subscriber_id <0 )
            for read only
    end
    else
        declare hCMSdrop_subscription_3rd CURSOR LOCAL FAST_FORWARD FOR 
            select article_id, @subscriber, @subscriber_db from MSarticles a where
                a.publisher_id = @publisher_id and
                a.publisher_db = @publisher_db and
                a.publication_id = @publication_id
            for read only

    open hCMSdrop_subscription_3rd
    fetch hCMSdrop_subscription_3rd into @article_id, @subscriber, @subscriber_db
        
    while (@@fetch_status <> -1)
    begin
        exec @retcode = dbo.sp_MSdrop_subscription
            @publisher = @publisher,
            @publisher_db = @publisher_db,
            @publication = @publication,        -- Must provide this
            @article_id = @article_id,
            @subscriber = @subscriber,       
            @subscriber_db = @subscriber_db
        if @retcode != 0 or @@error != 0
        begin
            close hCMSdrop_subscription_3rd
            deallocate hCMSdrop_subscription_3rd
            if @@trancount > 0
            begin
                rollback tran MSdrop_subscription_3rd
                commit tran
            end
            return (1)
        end

       fetch hCMSdrop_subscription_3rd into @article_id, @subscriber, @subscriber_db
    end

    close hCMSdrop_subscription_3rd
    deallocate hCMSdrop_subscription_3rd
    commit tran
go

raiserror(15339,-1,-1,'sp_MSactivate_subscriptions')
go

CREATE PROCEDURE sp_MSactivate_subscriptions
@publisher_id int,
@publisher_db sysname,
@publication_id int, 
@xact_seqno varbinary(16),
@reset bit = 0      /* @reset = 1 is used for Scheduled Snapshot publications by snapshot */
AS

    declare @article_id int
    declare @retcode int

    declare hCseqno_3rd CURSOR LOCAL FAST_FORWARD FOR 
        select article_id from MSarticles a where
            a.publisher_id = @publisher_id and
            a.publisher_db = @publisher_db and
            a.publication_id = @publication_id
        for read only

    open hCseqno_3rd
    fetch hCseqno_3rd into @article_id
        
    while (@@fetch_status <> -1)
    begin
        select @article_id
        select @xact_seqno
        exec @retcode = dbo.sp_MSset_snapshot_xact_seqno
            @publisher_id = @publisher_id,
            @publisher_db = @publisher_db,
            @article_id = @article_id,
            @xact_seqno = @xact_seqno,
            @reset = @reset
        if @retcode != 0 or @@error != 0
        begin
            close hCseqno_3rd
            deallocate hCseqno_3rd
            return(1)
        end

        -- Activate the subscriptions
        exec @retcode = dbo.sp_MSdist_activate_auto_sub
            @publisher_id = @publisher_id,
            @publisher_db = @publisher_db,
            @article_id = @article_id
        if @retcode != 0 or @@error != 0
        begin
            close hCseqno_3rd
            deallocate hCseqno_3rd
            return(1)
        end

        fetch hCseqno_3rd into @article_id
    end

    close hCseqno_3rd
    deallocate hCseqno_3rd
GO
raiserror(15339,-1,-1,'sp_MSdrop_merge_subscription')
GO

CREATE PROCEDURE sp_MSdrop_merge_subscription
@publisher          sysname,
@publisher_db       sysname,
@publication        sysname,
@subscriber         sysname,
@subscriber_db      sysname,
@subscription_type  nvarchar(15) = 'push'           /* Subscription type - push, pull, both */ 

as

    set nocount on

    declare @publisher_id smallint
    declare @subscriber_id smallint
    declare @retcode int
    declare @publication_id int
    declare @job_id binary(16)
    declare @thirdparty_flag bit
    declare @id                 int
    declare @keep_for_last_run  bit

    -- Check if publisher is a defined as a distribution publisher in the current database
    exec @retcode = dbo.sp_MSvalidate_distpublisher @publisher, @publisher_id OUTPUT
    if @retcode <> 0
    begin
        return(1)
    end

    -- Get the publication information 
    select @publication_id = publication_id,
        @thirdparty_flag = thirdparty_flag
        from MSpublications where
        publisher_id = @publisher_id and
        publisher_db = @publisher_db and
        publication = @publication
    if @publication_id is NULL
    begin
    	raiserror(20026, 16, -1, @publication)
        return (1)
    end

    -- Perform PAL check with retrieved @publication_id
    exec @retcode = dbo.sp_MScheck_pull_access
        @agent_type = 1, -- merge agent
        @publication_id = @publication_id
    if @@error <> 0 or @retcode <> 0
	begin    
		RAISERROR (15247, 11, -1)
		return (1)
	end
    

    -- Check if subscriber exists
    select @subscriber_id = srvid from master..sysservers where UPPER(srvname) = UPPER(@subscriber) 
    if @subscriber_id is NULL
    begin
        raiserror (20032, 16, -1, @subscriber, @publisher) 
        return (1)
    end

    -- Check that subscription exists
    if not exists (select * from MSmerge_subscriptions where 
        publisher_id = @publisher_id and 
        publisher_db = @publisher_db and 
        publication_id = @publication_id and
        subscriber_id = @subscriber_id and
        subscriber_db = @subscriber_db)
    begin
        if @thirdparty_flag = 1
        begin
            --UNDONE : Add this back again when we add pull subscriptions metedata at the distributor
            --raiserror (14050, 10, -1)
            return(1)
        end
        else
            return (0)
    end

    begin tran
    save transaction MSdrop_merge_subscription

    -- Delete the subscription 
    -- For anonymous type, delete virtual anonymous subscription also
    -- if deleting the  virtual subscription 
    -- (since there can be only one subscriber_id per article, subscriber_db doesn't matter)
    delete from MSmerge_subscriptions where
        publisher_id = @publisher_id and
        publisher_db = @publisher_db and
        publication_id = @publication_id and
        subscriber_id = @subscriber_id and
        subscriber_db = @subscriber_db
    if @@error <> 0
    begin
        goto FAILURE
    end

    /*
    ** Get agentid to check history record
    */
    select @id=id from MSmerge_agents where 
        publisher_id = @publisher_id and
        publisher_db = @publisher_db and
        publication = @publication and
        subscriber_id = @subscriber_id and
        subscriber_db = @subscriber_db

    /*
    ** If the subscription has not yet been synced, there is no need for subscriber side cleanup 
    ** therefore no need for the last agent run.
    */
    if exists (select * from MSmerge_history where agent_id = @id) and @subscription_type='push'
        select @keep_for_last_run = 0 -- cleanup code is not activated.
    else 
        select @keep_for_last_run = 0
    
    /*
    ** Delete Merge agent and meta data, if it exists
    */
    EXECUTE @retcode = dbo.sp_MSdrop_merge_agent 
        @publisher = @publisher,
        @publisher_db = @publisher_db,
        @publication = @publication,
        @subscriber = @subscriber,
        @subscriber_db = @subscriber_db,
        @keep_for_last_run = @keep_for_last_run
    if @@error <> 0 or @retcode <> 0
    begin
        goto FAILURE
    end

    commit transaction
    return 0
FAILURE:
    if @@trancount > 0
    begin   
        ROLLBACK TRANSACTION MSdrop_merge_subscription
        COMMIT TRANSACTION
    end
    return 1
        
GO

raiserror(15339,-1,-1,'sp_MSadd_merge_subscription')
GO
CREATE PROCEDURE sp_MSadd_merge_subscription
@publisher sysname,
@publisher_db sysname,
@publication sysname,
@subscriber sysname,       
@subscriber_db sysname,
@subscription_type tinyint = 0,     -- 0 = push, 1 = pull
@sync_type tinyint = 1,             -- 0 = none  1 = automatic snaphot  2 = no intial snapshot
@status tinyint = 1,                -- 0 = inactive, 1 = subscribed, 2 = active 
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
@optional_command_line nvarchar(4000) = NULL,
-- Job name, used in scripting.
@agent_name sysname = NULL,
@merge_jobid binary(16) = NULL OUTPUT,
-- Agent offload
@offloadagent bit = 0,
@offloadserver sysname = NULL
as

    set nocount on

    declare @publisher_id smallint
    declare @subscriber_id smallint
    declare @publication_id int
    declare @retcode int

    -- default values 
    declare @flushfrequency int 
    declare @frequencytype int
    declare @frequencyinterval int 
    declare @frequencyrelativeinterval int
    declare @frequencyrecurrencefactor int 
    declare @frequencysubday int 
    declare @frequencysubdayinterval int
    declare @activestarttimeofday int
    declare @activeendtimeofday int
    declare @activestartdate int 
    declare @activeenddate int 
    declare @push int
    declare @local_job bit
    declare @thirdparty_flag bit

    select @push = 0

    -- Check if publisher is a defined as a distribution publisher in the current database
    exec @retcode = dbo.sp_MSvalidate_distpublisher @publisher, @publisher_id OUTPUT
    if @retcode <> 0
    begin
        return(1)
    end

    -- Get the publication information 
    select @publication_id = publication_id,
        @thirdparty_flag = thirdparty_flag from 
        MSpublications where 
        publisher_id = @publisher_id and
        publisher_db = @publisher_db and
        publication = @publication
    if @publication_id is NULL
    begin
        raiserror (20026, 11, -1, @publication)
        return (1)
    end

    -- Perform PAL check with retrieved @publication_id
    exec @retcode = dbo.sp_MScheck_pull_access
        @agent_type = 1, -- merge agent
        @publication_id = @publication_id
    if @@error <> 0 or @retcode <> 0
	begin    
		RAISERROR (15247, 11, -1)
		return (1)
	end
	
    -- Get subscriber info
    select @subscriber_id = srvid from master..sysservers where UPPER(srvname) = UPPER(@subscriber)

    -- Make sure subscription does not already exist
    if exists (select * from MSmerge_subscriptions where 
        publisher_id = @publisher_id and 
        publisher_db = @publisher_db and 
        publication_id = @publication_id and
        subscriber_id = @subscriber_id and
        subscriber_db = @subscriber_db)
    begin
        if @thirdparty_flag = 1
        begin
            raiserror (14058, 16, -1)
            return(1)
        end
        else
        begin
            exec @retcode = dbo.sp_MSdrop_merge_subscription 
                @publisher = @publisher,
                @publisher_db = @publisher_db,
                @publication = @publication,
                @subscriber = @subscriber,
                @subscriber_db = @subscriber_db,
                @subscription_type  = @subscription_type
            if @retcode <> 0 or @@error <> 0
            begin
                return (1)
            end
        end
    end

    --Get default task parameter values from MSsubscriber_info 
    
    select @frequencytype = frequency_type,
        @frequencyinterval = frequency_interval,
        @frequencyrelativeinterval = frequency_relative_interval,
        @frequencyrecurrencefactor = frequency_recurrence_factor,
        @frequencysubday = frequency_subday,
        @frequencysubdayinterval = frequency_subday_interval,
        @activestarttimeofday = active_start_time_of_day,
        @activeendtimeofday = active_end_time_of_day,
        @activestartdate = active_start_date,
        @activeenddate = active_end_date
    from MSsubscriber_schedule 
    where UPPER(publisher) = UPPER(@publisher) and UPPER(subscriber) = UPPER(@subscriber) and agent_type = 1

    if @frequency_type is null
        select @frequency_type = @frequencytype

    if @frequency_interval  is null
        select  @frequency_interval = @frequencyinterval

    if @frequency_relative_interval is null
        select  @frequency_relative_interval = @frequencyrelativeinterval

    if @frequency_recurrence_factor is null
        select  @frequency_recurrence_factor = @frequencyrecurrencefactor

    if @frequency_subday is null
        select  @frequency_subday = @frequencysubday

    if @frequency_subday_interval is null
        select  @frequency_subday_interval = @frequencysubdayinterval

    if @active_start_time_of_day is null
        select  @active_start_time_of_day = @activestarttimeofday

    if @active_end_time_of_day is null
        select  @active_end_time_of_day = @activeendtimeofday

    if @active_start_date is null
        select  @active_start_date = @activestartdate

    if @active_end_date is null
        select  @active_end_date = @activeenddate

    begin transaction 

    -- If push and agent name is not passed in, create local job.
    if @subscription_type = @push
        select @local_job = 1
    else
        select @local_job = 0

    insert into MSmerge_subscriptions values (@publisher_id, @publisher_db, @publication_id,
        @subscriber_id, @subscriber_db, @subscription_type, @sync_type, @status, 
        getdate())  -- need to store GUID?
    if @@error <> 0
    begin
        goto FAILURE
    end

    -- Create Merge Agent
    exec @retcode = dbo.sp_MSadd_merge_agent
        @name = @agent_name, 
        @publisher = @publisher,
        @publisher_db = @publisher_db,
        @publication = @publication,
        @subscriber = @subscriber,
        @subscriber_db = @subscriber_db,
        @local_job = @local_job,
        @frequency_type  = @frequency_type,                         
        @frequency_interval = @frequency_interval, 
        @frequency_relative_interval = @frequency_relative_interval, 
        @frequency_recurrence_factor = @frequency_recurrence_factor, 
        @frequency_subday = @frequency_subday, 
        @frequency_subday_interval = @frequency_subday_interval,
        @active_start_time_of_day = @active_start_time_of_day, 
        @active_end_time_of_day = @active_end_time_of_day,         
        @active_start_date = @active_start_date, 
        @active_end_date = @active_end_date,
        @optional_command_line = @optional_command_line,
        @merge_jobid = @merge_jobid OUTPUT,
        @offloadagent = @offloadagent,
        @offloadserver = @offloadserver,
        @subscription_type = @subscription_type

    if @retcode <> 0 or @@error <> 0
    begin
        goto FAILURE
    end
    
    commit transaction
    return (0)

FAILURE:
    /* UNDONE : This code is specific to 6.X nested transaction semantics */
    if @@TRANCOUNT = 1 
        ROLLBACK TRANSACTION 
    else
        COMMIT TRANSACTION 
    RETURN (1)
    
GO

raiserror(15339,-1,-1,'sp_MSenum_merge_subscriptions')
GO
create procedure sp_MSenum_merge_subscriptions
@publisher sysname,
@publisher_db sysname,
@publication sysname,
@exclude_anonymous bit = 0

as

    declare @subscriber sysname
    declare @subscriber_db sysname
    declare @subscriber_name sysname
    declare @type int
    declare @status int
    declare @agent_name nvarchar(100)
    declare @subscriber_id smallint
    declare @publisher_id smallint
    declare @start_time nvarchar(24)
    declare @time nvarchar(24)
    declare @duration int
    declare @comments nvarchar(255)
    declare @delivery_rate float
    declare @error_id int
    declare @publication_id int
    declare @publisher_insertcount int
    declare @publisher_updatecount int
    declare @publisher_deletecount int
    declare @publisher_conflictcount int
    declare @subscriber_insertcount int
    declare @subscriber_updatecount int
    declare @subscriber_deletecount int
    declare @subscriber_conflictcount int
    declare @job_id binary(16)
    declare @local_job bit
    declare @profile_id int
    declare @agent_id int
    declare @last_timestamp binary(8)
    declare @offload_enabled bit
    declare @offload_server sysname
		,@subscriber_type tinyint

    set nocount on


    select @publisher_id = srvid from master..sysservers where
       UPPER(srvname) = UPPER(@publisher)

    select @publication_id = publication_id from MSpublications  where 
            publisher_id = @publisher_id and
            publisher_db = @publisher_db and
            publication = @publication and
            publication_type = 2 -- Merge 

    create table #merge_subscriptions (subscriber sysname NOT NULL,  status int NOT NULL, 
        subscriber_db sysname NOT NULL, type int NOT NULL, agent_name nvarchar(100) NOT NULL, last_action nvarchar(255) NULL, 
        action_time nvarchar(24) NULL, start_time nvarchar(24) NULL, duration int NULL, 
        delivery_rate float NULL,
        publisher_insertcount int NULL, publisher_updatecount int NULL, publisher_deletecount int NULL,
        publisher_conficts int NULL, 
        subscriber_insertcount int NULL, subscriber_updatecount int NULL, subscriber_deletecount int NULL,
        subscriber_conficts int NULL, error_id int NULL, job_id binary(16) NULL,
        local_job bit NULL, profile_id int NOT NULL, 
        agent_id int NOT NULL, last_timestamp binary(8) NOT NULL, offload_enabled bit NOT NULL, 
		offload_server sysname NULL, subscriber_type tinyint NULL)
    
    -- This is to force all queries to return rows ordered by job_id
    create unique clustered index ucmerge_subscriptions ON #merge_subscriptions (agent_id)

    declare hC CURSOR LOCAL FAST_FORWARD FOR select subscriber_id, subscriber_db, name, job_id, local_job, profile_id, id, subscriber_name,
                                                    offload_enabled, offload_server
                                from MSmerge_agents 
                                 where publisher_id = @publisher_id and publisher_db = @publisher_db and publication = @publication  and 
									(@exclude_anonymous = 0 or subscriber_name is null)
                            for read only
    open hC
    fetch hC into  @subscriber_id, @subscriber_db, @agent_name, @job_id, @local_job, @profile_id, @agent_id, @subscriber_name, @offload_enabled,
                   @offload_server
    while (@@fetch_status <> -1)
    begin

        if @subscriber_name is not NULL 
            begin
                select @subscriber = @subscriber_name
                select @subscriber_db = @subscriber_db + '-' + convert(nvarchar(12), @agent_id)
                select @type = 2   --anonymous subscription
            end
        else
            begin
                select @subscriber = srvname from master..sysservers where srvid=@subscriber_id
                select @type = subscription_type from MSmerge_subscriptions 
                    where publisher_id = @publisher_id and
                        publisher_db = @publisher_db and
                        publication_id = @publication_id and
                        subscriber_id = @subscriber_id and
                        subscriber_db = @subscriber_db
				select @subscriber_type = type from MSsubscriber_info where
					UPPER(publisher) = UPPER(@publisher) and
					UPPER(subscriber) = UPPER(@subscriber)
            end
            
        -- Get the status of the agent
        select @status = 0 
        select  @start_time = NULL,
            @time = NULL, 
            @duration = NULL, 
            @comments = NULL,
            @publisher_insertcount = NULL,
            @publisher_deletecount = NULL,
            @publisher_updatecount =  NULL,
            @publisher_conflictcount =  NULL,
            @subscriber_insertcount = NULL,
            @subscriber_deletecount = NULL,
            @subscriber_updatecount =  NULL,
            @subscriber_conflictcount =  NULL,
            @delivery_rate = NULL, 
            @error_id = NULL,
            @last_timestamp = 0x00000000
                
        select @status = isnull(runstatus,0),
            @start_time = convert(nvarchar(12), start_time, 112) +
                          substring(convert(nvarchar(24), start_time, 121), 11, 13),
            @time = convert(nvarchar(12), time, 112) +
                    substring(convert(nvarchar(24), time, 121), 11, 13), 
            @duration = duration, 
            @comments = comments,
            @publisher_insertcount = publisher_insertcount,
            @publisher_deletecount = publisher_deletecount,
            @publisher_updatecount =  publisher_updatecount,
            @publisher_conflictcount =  publisher_conflictcount,
            @subscriber_insertcount = subscriber_insertcount,
            @subscriber_deletecount = subscriber_deletecount,
            @subscriber_updatecount =  subscriber_updatecount,
            @subscriber_conflictcount =  subscriber_conflictcount,
            -- Note: return average rate here !!! delivery_rate column is current rate
            @delivery_rate = 
                case    when duration <> 0 then 
                            (publisher_insertcount + publisher_updatecount +
                            publisher_deletecount + subscriber_insertcount + 
                            subscriber_updatecount + subscriber_deletecount)/duration
                        when duration = 0 then 0
                end, 
            @error_id = error_id, @last_timestamp = timestamp
            from MSmerge_history
            where
                agent_id = @agent_id and
                timestamp = (select max(timestamp) from MSmerge_history 
                    where agent_id = @agent_id)
/* Not currently working Build 351
                timestamp = (select top 1 timestamp from MSmerge_history 
                    where agent_id = @agent_id
                    order by timestamp DESC) 
*/
        
            insert into #merge_subscriptions values ( @subscriber, @status, @subscriber_db,
                @type, @agent_name, @comments, @time, @start_time, @duration,
                @delivery_rate, 
                @publisher_insertcount, @publisher_updatecount, @publisher_deletecount, 
                @publisher_conflictcount,
                @subscriber_insertcount, @subscriber_updatecount, @subscriber_deletecount, 
                @subscriber_conflictcount,
                @error_id, @job_id, @local_job, @profile_id, @agent_id, @last_timestamp,
                @offload_enabled, @offload_server, @subscriber_type)
        

        fetch hC into  @subscriber_id, @subscriber_db, @agent_name, @job_id, @local_job, @profile_id, @agent_id, @subscriber_name,
                       @offload_enabled, @offload_server
      end

    select * from #merge_subscriptions order by job_id asc

    drop table #merge_subscriptions
    close hC
    deallocate hC

go

raiserror(15339,-1,-1,'sp_update_agent_profile')
GO

-- Update the profile for an agent
CREATE PROCEDURE sp_update_agent_profile (
    @agent_type     int,
    @agent_id       int,
    @profile_id int
)
AS
    SET NOCOUNT ON

    DECLARE @proc               nvarchar(255)

    DECLARE @snapshot_type          int
    DECLARE @logreader_type         int
    DECLARE @distribution_type      int
    DECLARE @merge_type         int
    DECLARE	@qreader_type			int

    SELECT @snapshot_type = 1
    SELECT @logreader_type = 2
    SELECT @distribution_type = 3
    SELECT @merge_type = 4
    SELECT @qreader_type = 9

    IF @agent_type NOT IN (@snapshot_type, @logreader_type, @distribution_type, @merge_type, @qreader_type)
        RETURN (1) 

    /* The profile must be defined for the agent type in MSagent_profiles table */
    IF NOT EXISTS ( select * from msdb..MSagent_profiles
            where profile_id = @profile_id
            and agent_type = @agent_type )
        RETURN (1)
	
	-- The system 'SkipErrors' profile is for sql subscribers only.
	if @distribution_type = @agent_type and @profile_id = 14
	begin
		declare @subscriber_id int, @publisher_id int
		select top 1 @publisher_id = publisher_id, @subscriber_id = subscriber_id from
			MSsubscriptions where agent_id = @agent_id
		declare @subscriber sysname, @publisher sysname
		select @publisher = srvname from master..sysservers where srvid = @publisher_id
		select @subscriber = srvname from master..sysservers where srvid = @subscriber_id

		-- Use 'exists' not 'not exists' to take care null @publisher or @subscriber
		if exists (select * from MSsubscriber_info where
			upper(publisher) = upper(@publisher) and
			upper(subscriber) = upper(@subscriber) and
			type <> 0)
		begin
			raiserror(20603, 16, -1)
			return 1
		end
	end
	
	SELECT @proc = 'UPDATE ' +
        CASE @agent_type
           WHEN @snapshot_type THEN 'MSsnapshot_agents'
           WHEN @logreader_type THEN 'MSlogreader_agents'
           WHEN @distribution_type THEN 'MSdistribution_agents'
           WHEN @merge_type THEN 'MSmerge_agents'
           WHEN @qreader_type THEN 'MSqreader_agents'
        END
        + ' SET profile_id = ' + convert(nvarchar(10), @profile_id)
        + ' WHERE id = ' + convert(nvarchar(10), @agent_id)

    EXECUTE (@proc)

    IF @@ERROR <> 0 
        RETURN (1)
GO


raiserror(15339,-1,-1,'sp_MSprofile_in_use')
GO

CREATE PROCEDURE sp_MSprofile_in_use (
    @tablename          nvarchar(255),
    @profile_id int
)
AS
    DECLARE @usage_count int

    IF @tablename IS NULL OR @profile_id IS NULL
        return 1 ;

    IF @tablename = 'MSsnapshot_agents'
        SELECT @usage_count = count(*) FROM MSsnapshot_agents
        WHERE profile_id = @profile_id
    ELSE IF @tablename = 'MSlogreader_agents'
            SELECT @usage_count = count(*) FROM MSlogreader_agents
            WHERE profile_id = @profile_id
        ELSE IF @tablename = 'MSdistribution_agents'
                SELECT @usage_count = count(*) FROM MSdistribution_agents
                WHERE profile_id = @profile_id
            ELSE IF @tablename = 'MSmerge_agents'
                    SELECT @usage_count = count(*) FROM MSmerge_agents 
                    WHERE profile_id = @profile_id
                ELSE 
                    SELECT @usage_count = 0

    IF @usage_count = 0
        RETURN -1
    ELSE
        RETURN 0
GO


raiserror(15339,-1,-1,'sp_MSreset_subscription')
GO
CREATE PROCEDURE sp_MSreset_subscription (
    @publisher sysname,
    @publisher_db sysname,
    @publication sysname,  
    @subscriber sysname,
    @subscriber_db sysname,
    @subscription_type int  -- have to have it to identify a distribution agent.
) AS


    SET NOCOUNT ON

    /*
    ** Declarations.
    */
    DECLARE @retcode            int
    DECLARE @publisher_id       smallint
    DECLARE @subscriber_id      smallint
    DECLARE @virtual            smallint
	declare @publication_id		int
	declare @immediate_sync		bit


    /*
    ** Initializations
    */
    select @virtual = -1

    select @publisher_id = srvid from master..sysservers where 
        UPPER(srvname) = UPPER(@publisher)

    select @subscriber_id = srvid from master..sysservers where 
        UPPER(srvname) = UPPER(@subscriber) 

	select @publication_id = publication_id, @immediate_sync = immediate_sync
		from MSpublications where
        publisher_id = @publisher_id AND
        publisher_db = @publisher_db AND
        publication = @publication

    if @subscriber is NULL
        select @subscriber_id = @virtual

	-- No need to have 2 updates in one transaction.
	if @immediate_sync = 1
	begin
		UPDATE MSdistribution_agents SET subscription_guid = newid()
			WHERE
			publisher_id = @publisher_id AND
			publisher_db = @publisher_db AND
			publication = @publication and
			subscriber_id = @subscriber_id and
			subscriber_db = @subscriber_db and
			subscription_type = @subscription_type

		IF @@ERROR <> 0
			GOTO UNDO
	end

	UPDATE MSsubscriptions set subscription_time = getdate() 
        WHERE
        publisher_id = @publisher_id AND
        publisher_db = @publisher_db AND
        publication_id = @publication_id and
        subscriber_id = @subscriber_id and
        subscriber_db = @subscriber_db and
        subscription_type = @subscription_type

    IF @@ERROR <> 0
        GOTO UNDO

    RETURN(0)

UNDO:
    return(1)
GO

raiserror(15339,-1,-1,'sp_MSget_subscription_guid')
GO
CREATE PROCEDURE sp_MSget_subscription_guid (
@agent_id int )
as
begin
	set nocount on

	-- You need to make change to sp_MShelp_distribution_agentid when changing
	-- this.	
	-- Get subscription_guid
	select a1.subscription_guid
	from MSdistribution_agents a1
	where
	-- for non anonymous agents
	((a1.virtual_agent_id is null and a1.id = @agent_id) or
	(   -- for anonymous agents
		a1.id = (select virtual_agent_id from MSdistribution_agents a2 where
			a2.id = @agent_id)) -- virtual account
	) 
end            
GO


raiserror(15339,-1,-1,'sp_MSreset_subscription_seqno')
GO
CREATE PROCEDURE sp_MSreset_subscription_seqno (
@agent_id int,
@get_snapshot bit )
as
	set nocount on

	declare @publication_id int
	declare @sub_agent_id int
	declare @virtual_anonymous smallint
	declare @virtual smallint
	declare @retcode int
	declare @automatic tinyint

	select @automatic = 1
	select @virtual = -1
	select @virtual_anonymous = -2

	-- Security Check
    exec @retcode = dbo.sp_MScheck_pull_access
        @agent_id = @agent_id,
        @agent_type = 0 -- distribution agent
    if @@error <> 0 or @retcode <> 0
        return (1)

	-- Get version agent_id
	select top 1 @sub_agent_id = s2.agent_id from MSsubscriptions s1,
		MSsubscriptions s2 where
		s1.publisher_id = s2.publisher_id and
		s1.publisher_db = s2.publisher_db and
		s1.publication_id = s2.publication_id and
		s1.agent_id = @agent_id and
		s2.subscriber_id = 
			case @get_snapshot when 0 
				then @virtual_anonymous
				else @virtual
			end 
	
	-- If there are no virtual subscriptions defined. Don't reset.
	-- This might happen when the distribution agent tries to 
	-- reset an subscription on a non immediate_sync publication 
	-- (this can
	-- only happen when the publication is changed from immediate_sync to non
	-- immdiate_sync after the distribution agent has queried the immediate_sync
	-- property)
	if @sub_agent_id = 0
		return 0

	-- 'no_sync' subscriptions are handled differently
	if exists (select * from MSsubscriptions where agent_id = @agent_id and 
		sync_type <> @automatic)
	begin
		-- If @get_snapshot = 0, the distribution agent is process the attached
		-- subscription for the first time. Set subscription_seqno to zero so that
		-- all changes that are not in the subscription copy will be picked up.
		-- Otherwise, do noting.
		if @get_snapshot = 0
		begin
			update MSsubscriptions  set 
				-- Use current date rather than virtual sub date for the
				-- calculation in cleanup 
				subscription_time = getdate(),
				-- lsn should be ten bytes long. We will not be here
				-- if the publisher is 6.x since 6x publisher does not
				-- support immediate_sync (thus does not support subscription copy as well)
				subscription_seqno = 0x00000000000000000000,
				publisher_seqno = 0x00000000000000000000,
				ss_cplt_seqno = 0x00000000000000000000
				from MSsubscriptions rs1 where
					agent_id = @agent_id 
		end		
		return 0
	end

	-- Reset the subscription status to be that of the virtual_anonymous subscription.
	-- Thus, only the snapshot transactions that are later than the subscriber transaction
	-- timestamp will be picked up (i.e., new article or schema change article.)
    update MSsubscriptions  set 
        snapshot_seqno_flag =  
            (select snapshot_seqno_flag from MSsubscriptions rs2
                where
                rs2.agent_id = @sub_agent_id and
                rs2.article_id = rs1.article_id),
        status =    
            (select status from MSsubscriptions rs2
                where
                rs2.agent_id = @sub_agent_id and
                rs2.article_id = rs1.article_id),
        -- Use current date rather than virtual sub date for the
        -- calculation in cleanup 
        subscription_time = getdate(),
        subscription_seqno = 
            (select subscription_seqno from MSsubscriptions rs2
                where
                rs2.agent_id = @sub_agent_id and
                rs2.article_id = rs1.article_id),
        publisher_seqno = 
            (select publisher_seqno from MSsubscriptions rs2
                where
                rs2.agent_id = @sub_agent_id and
                rs2.article_id = rs1.article_id),
		ss_cplt_seqno = 
            (select ss_cplt_seqno from MSsubscriptions rs2
                where
                rs2.agent_id = @sub_agent_id and
                rs2.article_id = rs1.article_id)
        from MSsubscriptions rs1 where
            agent_id = @agent_id
        
	if @@ERROR <> 0
        return 1
GO


raiserror(15339,-1,-1,'sp_MShelp_profile')
GO

CREATE PROCEDURE sp_MShelp_profile (        
    @agent_id   int,
    @agent_type int,
    @profile_name sysname = NULL
)
as
    declare @profile_id int
    declare @snapshot_type int
    declare @logreader_type int
    declare @distribution_type int
    declare @merge_type int
    declare @qreader_type int

    select @snapshot_type = 1
    select @logreader_type = 2
    select @distribution_type = 3
    select @merge_type = 4
    select @qreader_type = 9

    select @profile_id = NULL

    if (@profile_name is not null) and (rtrim(ltrim(@profile_name)) <> '')
    begin
        select @profile_id = profile_id from msdb..MSagent_profiles where
            agent_type = @agent_type and profile_name = @profile_name

		/* raise error if profile not found */
		if (@profile_id is null)
		begin
			raiserror(21123, 16, -1, @profile_name)
			return (1)
		end
    end
    
    -- if profile name not specified, use default.
    if (@profile_id is null)
    begin
        if @agent_type = @snapshot_type 
        begin
            if @agent_id = 0
                select @profile_id = profile_id from msdb..MSagent_profiles where
                    agent_type = @agent_type and def_profile = 1
            else
                select @profile_id = profile_id from MSsnapshot_agents
                    where id = @agent_id
        end
        else if @agent_type = @logreader_type
        begin
            if @agent_id = 0
                select @profile_id = profile_id from msdb..MSagent_profiles where
                    agent_type = @agent_type and def_profile = 1
            else
                select @profile_id = profile_id from MSlogreader_agents
                    where id = @agent_id
        end
        else if @agent_type = @distribution_type
        begin
            if @agent_id = 0
                select @profile_id = profile_id from msdb..MSagent_profiles where
                    agent_type = @agent_type and def_profile = 1
            else
                select @profile_id = profile_id from MSdistribution_agents
                    where id = @agent_id
        end
        else if @agent_type = @merge_type
        begin
            if @agent_id = 0
                select @profile_id = profile_id from msdb..MSagent_profiles where
                    agent_type = @agent_type and def_profile = 1
            else
                select @profile_id = profile_id from MSmerge_agents
                    where id = @agent_id
        end
        else if @agent_type = @qreader_type
        begin
            if @agent_id = 0
                select @profile_id = profile_id from msdb..MSagent_profiles where
                    agent_type = @agent_type and def_profile = 1
            else
                select @profile_id = profile_id from MSqreader_agents
                    where id = @agent_id
        end
    end
    
    select profile_id, parameter_name, value 
        from msdb..MSagent_parameters
        where profile_id = @profile_id
GO

raiserror(15339,-1,-1,'sp_MShelp_snapshot_agentid')
GO

CREATE PROCEDURE sp_MShelp_snapshot_agentid (
    @publisher_id       smallint,
    @publisher_db       sysname,
    @publication        sysname,
    @job_id             binary(16) = NULL
)
AS
    set nocount on
    declare @retcode int
    declare @publisher sysname
    declare @description nvarchar(255)

    -- Check if agent exists, if not and there is an 6.x tasks then create one
    if @publication is not null and @publication <> '' and not exists (select * from MSsnapshot_agents where
            publisher_id = @publisher_id and
            publisher_db = @publisher_db and
            publication = @publication)
    begin
        -- Do it only if the agent name is valid. It will be the case if
        -- the agent is launched by SQL Server Agent
        if exists (select * from msdb..sysjobs_view where
            job_id = @job_id)
        begin
            select @publisher = srvname from master..sysservers where srvid = @publisher_id
            begin tran
            exec @retcode = dbo.sp_MSadd_snapshot_agent
                @publisher = @publisher, 
                @publisher_db = @publisher_db,
                @publication = @publication,
                @local_job = 1,
                @job_existing = 1,
                @snapshot_jobid = @job_id
            if @@ERROR<> 0 or @retcode <> 0
                goto UNDO

            -- Add a publication definition so it shows up in monitoring procs
            set @description = formatmessage(20555)
            exec @retcode = dbo.sp_MSadd_publication
                @publisher = @publisher,
                @publisher_db = @publisher_db,
                @publication = @publication,
                @publication_type = 1,              -- Make all 6.x pubs transactional
                @description = @description     -- 6.x publication description

            if @@ERROR<> 0 or @retcode <> 0
                goto UNDO
            commit tran
        end
    end

    select id, name from MSsnapshot_agents  where 
        publisher_id = @publisher_id and
        publisher_db = @publisher_db and
        publication = @publication

    return(0)

UNDO:
    if @@TRANCOUNT = 1
        ROLLBACK TRAN
    else
        COMMIT TRAN
    return(1)
GO

raiserror(15339,-1,-1,'sp_MShelp_logreader_agentid')
GO

CREATE PROCEDURE sp_MShelp_logreader_agentid (
    @publisher_id       smallint,
    @publisher_db       sysname
)
AS
    set nocount on
    declare @retcode int
    declare @publisher sysname
    declare @job_id binary(16)
    declare @qv_package	varchar(20)
    declare @desk_top		int
    declare @license_value int
    declare @qv_value_package int

	select @qv_package = '845129433'
	select @license_value = 0 
	select @desk_top = 3

	exec @qv_value_package = master.dbo.sp_MSinstance_qv @qv_package
	if @@ERROR<>0 
	begin
		raiserror(20089, 16, -1)
		return (1)
	end
	if @qv_value_package = 1		 --- 1 means desktop
		select @license_value = @desk_top   -- to be consistent with all other compenents.
	
    -- Check if agent exists, if not and there is an 6.x tasks then create one
    if not exists (select * from MSlogreader_agents where
            publisher_id = @publisher_id and
            publisher_db = @publisher_db)
    begin
        select @publisher = srvname from master..sysservers where srvid = @publisher_id

        -- Do it only if the agent name is valid. It will be the case if
        -- the agent is launched by SQL Server Agent
        select @job_id = id.job_id from msdb..systasks_view v,
            msdb..systaskids id
            where 
            v.server = @publisher and           
            v.databasename = @publisher_db and
            v.subsystem = 'LogReader' and
            v.id = id.task_id

        if @job_id is not NULL
        begin
            exec @retcode = dbo.sp_MSadd_logreader_agent
                @publisher = @publisher, 
                @publisher_db = @publisher_db,
                -- 'ALL' is Used in sp_addpublication as well
                @publication = 'ALL',
                @local_job = 1,
                @job_existing = 1,
                @job_id = @job_id
            if @@ERROR<> 0 or @retcode <> 0
                return(1)
        end
    end
  
    select id, name, @license_value from MSlogreader_agents where 
        publisher_id = @publisher_id and 
        publisher_db = @publisher_db

    return(0)

GO

/*
** This procedure is to add an agent row in MSmerge_agents for an anonymous subscription,
** if it is not already there. If it is, return the agentid and agent name for monitoring
** purpose.
*/
raiserror(15339,-1,-1,'sp_MSadd_merge_anonymous_agent')
GO

CREATE PROCEDURE sp_MSadd_merge_anonymous_agent (
    @publisher_id       smallint,
    @publisher_db       sysname,
    @publication        sysname,
    @subscriber_db      sysname,
    @subscriber_name    sysname,
    @subid              uniqueidentifier, 
    @first_anonymous	int		-- 0 means this is the first time for this anonymous agent being ran.
)
AS
    declare @min_valid_day  datetime
    declare @merge_type     int
    declare @profile_id     int
    declare @subscriber_id  smallint
    declare @agent_name     sysname
    declare @agent_id       int
    declare @retcode        int
    declare @publication_id int
    declare @not_exist      bit
    declare @last_status	int
	declare @last_history	datetime
	declare @merge_jobid	uniqueidentifier
	declare @by_pass		bit
    declare @retention		int
    declare @success		int
	declare @expired		int
	declare @dropped		int
	declare @allow_anonymous bit

	select @dropped = 0
	select @expired = 0
	select @success = 2
	select @by_pass = 0

/*
** This stored procedure does not really add a job at distribution database;
** if add a row in MSmerge_agent table for anonymous subscription for the 
** purpose of history logging
*/

    -- Check to see if the publication is valid and allow anonymous
    select @publication_id = publication_id, @allow_anonymous = allow_anonymous, @retention = retention from MSpublications where
        publisher_id = @publisher_id and
        publisher_db = @publisher_db and
        publication = @publication

    if @publication_id is null
    begin
        RAISERROR (21040, 16, -1, @publication)
        return 1
    end

	if @allow_anonymous = 0
    begin
    	RAISERROR (21084, 16, -1, @publication)
        return 1
    end

	if @subscriber_name is null
		select @subscriber_name = N''

    if @retention is NULL or @retention =0
    	select @by_pass = 1

    -- Security check
    exec @retcode = dbo.sp_MScheck_pull_access
        @publication_id = @publication_id, @agent_type = 1
    if @retcode <> 0 or @@error <> 0
        return (1)

    select @not_exist = 0
    SELECT @merge_type = 4
    select @subscriber_id = 0  -- For anonymous subscribers, ID is always 0 

    SELECT @profile_id = profile_id
    FROM msdb..MSagent_profiles
    WHERE agent_type = @merge_type
        AND def_profile = 1

    IF @profile_id IS NULL
        RETURN (1)

	/*
	** This is to handle Jet only
	*/
    IF @subid = '00000000-0000-0000-0000-000000000000'
    begin
    	select @subid = anonymous_subid from MSmerge_agents 
    			where publisher_id=@publisher_id and 
    				  publisher_db = @publisher_db and 
    				  publication = @publication and 
    				  subscriber_name = @subscriber_name 
    				  and subscriber_db = @subscriber_db
    	if @subid = '00000000-0000-0000-0000-000000000000'
    		select @subid = newid()
    	else
    		select @first_anonymous = 1   -- for Jet, schemaversion should not be 0 in this path.
    end
         
    IF NOT EXISTS (select * from MSmerge_agents where anonymous_subid=@subid)
    begin

    	if @first_anonymous <= 0   --only add agent entry for initial subscription only. 
    	begin
        	select @not_exist = 1

        	-- Generate a job GUID for remote agents. This will be used by the UI to uniquely
        	-- identify rows returned by the enums
        	set @merge_jobid = newid();

        	insert into MSmerge_agents (name, publisher_id, publisher_db, publication, 
            		    subscriber_id, subscriber_db, anonymous_subid, job_id, profile_id, subscriber_name)
	            	VALUES (convert(nvarchar(40), @subid), @publisher_id, @publisher_db, @publication, 
    	            	    @subscriber_id, @subscriber_db, @subid, @merge_jobid, @profile_id, @subscriber_name)
    	end
    	else
    		select @dropped  =1
    end
    
    select @agent_id = id, @agent_name = name from MSmerge_agents 
        where anonymous_subid=@subid  -- subid guarantees uniqueness
    
	if @by_pass = 0 --by pass the checking if retention is NULL or 0
	begin
    	select @min_valid_day = dateadd(day, -@retention, getdate())
    	
    	select Top 1 @last_status = runstatus, @last_history = time from MSmerge_history where agent_id = @agent_id
        			order by time DESC
        --failures and in-progress messages do not count, if there were previous successes.			
        if (@last_status = 6 or @last_status = 3) and EXISTS (select * from MSmerge_history where agent_id = @agent_id and runstatus = 2) 
        		select Top 1 @last_history = time from MSmerge_history where agent_id = @agent_id and runstatus = 2
        				order by time DESC	
    	/*
    	** This anonymous subscription is gone for too long to be efficiently reconciled. Either reinitialization or
    	** re-deployment of this subscription is needed. Merge agent will fail.
    	*/
    	if @last_history < @min_valid_day and @first_anonymous <> 0	--do not check for re-initialized replicas.
        			select @expired = 1
   end

    select @agent_id, @agent_name, @expired where @dropped = 0 --return empty result set 
        
GO


raiserror(15339,-1,-1,'sp_MShelp_merge_agentid')
GO

CREATE PROCEDURE sp_MShelp_merge_agentid (
    @publisher_id       smallint,
    @publisher_db       sysname,
    @publication        sysname,
    @subscriber_id      smallint,
    @subscriber_db      sysname
)
AS
	declare @publisher		sysname
	declare @subscriber		sysname
	declare @expired		int
    declare @agent_id 		int
    declare @name 			sysname
    declare @retention 		int
    declare @last_status	int
    declare @last_history	datetime
    declare @min_valid_day 	datetime
    declare @reinited 		int
    declare @status 		int
    declare @success		int
    declare @publication_id	int
	declare @subscriber_datasource_type int
	declare @sql_subscriber	int
    
	select @expired = 0
    select @reinited = 4
    select @success = 2

	select @subscriber_datasource_type = 0
	select @sql_subscriber = 0

	if not EXISTS (select * from MSpublications 
		where publisher_id=@publisher_id 
		and publisher_db = @publisher_db
		and publication = @publication
		and publication_type = 2) -- merge publication is gone
	begin
		select 1, @publication, 1, 0 --third column = 1 means publication is gone, making the other values meanningless.
		return (1)
	end

   	select @publication_id = publication_id 
		from MSpublications
		where publisher_id = @publisher_id and
			  publisher_db = @publisher_db and
			  publication = @publication

	-- Get subscriber info
    select @subscriber = srvname from master..sysservers where srvid = @subscriber_id
	select @publisher = srvname from master..sysservers where srvid = @publisher_id

    select @subscriber_datasource_type = type
        from MSsubscriber_info 
        where UPPER(publisher) = UPPER(@publisher) and UPPER(subscriber) = UPPER(@subscriber)

	if (@subscriber_datasource_type = @sql_subscriber)
	begin
		select @status = status from MSmerge_subscriptions where
			publisher_id = @publisher_id and 
			publisher_db = @publisher_db and 
			publication_id = @publication_id and
			subscriber_id = @subscriber_id and
			subscriber_db = @subscriber_db

		select @agent_id = id, @name = name from MSmerge_agents 
	        where publisher_id = @publisher_id 
			and publisher_db = @publisher_db
			and publication = @publication
			and subscriber_id = @subscriber_id
			and subscriber_db = @subscriber_db
	end
	else
	begin
		select @status = status from MSmerge_subscriptions where
			publisher_id = @publisher_id and 
			publisher_db = @publisher_db and 
			publication_id = @publication_id and
			subscriber_id = @subscriber_id

		select @agent_id = id, @name = name from MSmerge_agents 
	        where publisher_id = @publisher_id 
			and publisher_db = @publisher_db
			and publication = @publication
			and subscriber_id = @subscriber_id
	end

    -- Security check. Do it here to let the agent fail at the beginning
    if @agent_id is not null
    begin
        exec dbo.sp_MScheck_pull_access @agent_id = @agent_id, @agent_type = 1 -- merge agent
        select @retention = retention 
			from MSpublications 
			where publisher_id=@publisher_id and publisher_db=@publisher_db and publication=@publication 

		if @retention is not NULL and @retention > 0
		begin
			select @min_valid_day = dateadd(day, @retention * (-1), getdate()) 
			select Top 1 @last_status = runstatus, @last_history = time 
        			from MSmerge_history where agent_id = @agent_id
        				order by time DESC
        	if @last_status = 6 and EXISTS (select * from MSmerge_history where  agent_id = @agent_id and runstatus = 2) 
        		select Top 1 @last_history = time from MSmerge_history where agent_id = @agent_id and runstatus = 2
        						order by time DESC	
			if @last_history < @min_valid_day and @status <> @reinited
				select @expired = 1
		end
	end

select @agent_id, @name, 0, @expired where @agent_id is not NULL
GO

raiserror(15339,-1,-1,'sp_MSdistpublisher_cleanup')
GO

CREATE PROCEDURE sp_MSdistpublisher_cleanup 
@publisher sysname
as

    set nocount on
    declare @publisher_id smallint
    declare @job_id binary(16)
    declare @retcode int
    
    -- Delete agents
    -- Get the publisher id
    -- Check if publisher is a defined as a distribution publisher in the current database
    exec @retcode = dbo.sp_MSvalidate_distpublisher @publisher, @publisher_id OUTPUT
    if @retcode <> 0
    begin
        return(1)
    end
    
    -- Dropping local jobs
    -- Use union in 'select'. Insensitive cursor will be used automatically.
    DECLARE hCagents CURSOR LOCAL FAST_FORWARD FOR
            SELECT job_id 
                FROM MSsnapshot_agents
                WHERE publisher_id = @publisher_id and local_job = 1
        UNION
            SELECT job_id
                FROM MSlogreader_agents
                WHERE publisher_id = @publisher_id and local_job = 1
        UNION
            SELECT job_id 
                FROM MSdistribution_agents
                WHERE publisher_id = @publisher_id and local_job = 1
        UNION
            SELECT job_id
                FROM MSmerge_agents
                WHERE publisher_id = @publisher_id  and local_job = 1
        FOR READ ONLY

    OPEN hCagents
    FETCH hCagents INTO @job_id
   
    WHILE (@@fetch_status <> -1)
    BEGIN
        IF EXISTS (SELECT * FROM msdb..sysjobs_view WHERE job_id = @job_id)
        BEGIN
            exec @retcode = msdb.dbo.sp_delete_job @job_id = @job_id
            if @retcode <> 0 or @@error <> 0
                return(1)
        END
        FETCH hCagents INTO @job_id 
    end

    -- Clean up the tables, including
    --  4 Agent tables
    --  2 subscription tables
    --  article table
    --  publication table
    --  2 subscriber table
    -- The order is to avoid breaking monitoring


    delete MSpublisher_databases where publisher_id = @publisher_id
    if @@error <> 0 
        return (1) 

    delete MSpublications where publisher_id = @publisher_id
    if @@error <> 0 
        return (1) 

    delete MSarticles where publisher_id = @publisher_id
    if @@error <> 0 
        return (1) 

    delete MSsubscriptions where publisher_id = @publisher_id
    if @@error <> 0 
        return (1) 

    delete MSmerge_subscriptions where publisher_id = @publisher_id
    if @@error <> 0 
        return (1) 

    delete MSsnapshot_agents where publisher_id = @publisher_id
    if @@error <> 0 
        return (1) 
    
    delete MSlogreader_agents where publisher_id = @publisher_id
    if @@error <> 0 
        return (1) 

    delete MSdistribution_agents where publisher_id = @publisher_id
    if @@error <> 0 
        return (1) 

    delete MSmerge_agents where publisher_id = @publisher_id
    if @@error <> 0 
        return (1) 

    delete MSsubscriber_info where UPPER(publisher) = UPPER(@publisher)
    if @@error <> 0 
        return (1) 

    delete MSsubscriber_schedule where UPPER(publisher) = UPPER(@publisher)
    if @@error <> 0 
        return (1) 

    delete MSpublication_access where not exists (select * from MSpublications p where
		p.publication_id = MSpublication_access.publication_id)
    if @@error <> 0 
        return (1) 

    delete MSrepl_originators where 
        not exists (select * from MSpublisher_databases p
            where p.id = MSrepl_originators.publisher_database_id )
    if @@error <> 0 
        return (1) 

    -- Force a refresh of the replication status temp table.
    if (select object_id('tempdb.dbo.MSreplication_agent_status')) is not NULL
        delete tempdb.dbo.MSreplication_agent_status
GO

raiserror(15339,-1,-1,'sp_MSenum_replication_status')
GO

create procedure sp_MSenum_replication_status
as
    declare @anonymous_mask int
    declare @db_name sysname
    declare @distbit int
    declare @monitor bit
    declare @cmd nvarchar(255)

    select @anonymous_mask = 0x80000000
    select @distbit = 16
    select @monitor = 0
   
    -- User must have permission to monitor at least 1 distribution database     
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
        declare @has_pm int
        select @cmd = quotename(@db_name) + '.dbo.sp_executesql'
        exec @cmd
            N'if is_member(N''db_owner'') = 1 or is_member(N''replmonitor'') = 1 set @has_pm = 1', 
            N'@has_pm bit output',
            @has_pm output
 
        -- Set @monitor to 1 if user has permission to monitor
        if @has_pm = 1
            select @monitor = 1

        fetch next from hCdatabase into @db_name
    end
    close hCdatabase
    deallocate hCdatabase

    -- Don't return results if user doesn't have permission to monitor
    -- at least 1 distribution database
    if @monitor = 0
        return

    select 'publisher' = srvname, 'publisher_db' = sa.publisher_db, 
        'publication' = sa.publication, 'publication_type' = sa.publication_type,
        'agent_type' = 1, 'status' = runstatus, 'agent_name' = sa.name from 
        MSsnapshot_history sh1, master..sysservers, MSsnapshot_agents sa
        where 
        sh1.timestamp = (select max(timestamp) from MSsnapshot_history sh2 where
            sh2.agent_id = sa.id) and
        srvid = sa.publisher_id 
    UNION
    select srvname, sa.publisher_db, sa.publication, sa.publication_type, 
        1, 0, sa.name from 
        master..sysservers, MSsnapshot_agents sa
        where 
        srvid = sa.publisher_id and
        not exists (select * from MSsnapshot_history sh where sh.agent_id = sa.id)
    UNION
    select srvname, la.publisher_db, 'ALL', 0, 2, runstatus, la.name from
        MSlogreader_history lh1, MSlogreader_agents la, master..sysservers
        where timestamp = (select max(timestamp) from 
            MSlogreader_history lh2 where
            lh2.agent_id = la.id) and
            srvid = la.publisher_id
    UNION
    select srvname, la.publisher_db, 'ALL', 0, 2, 0, la.name from
        MSlogreader_agents la, master..sysservers
        where
            srvid = la.publisher_id and
            not exists (select * from MSlogreader_history lh where lh.agent_id = la.id)
    UNION
    select srvname, da.publisher_db, da.publication, p.publication_type, 3, runstatus, da.name from 
            MSdistribution_history dh1, master..sysservers, 
            MSdistribution_agents da, MSpublications p, MSsubscriptions s
            where timestamp = (select max(timestamp) from 
                MSdistribution_history dh2 where
                dh2.agent_id = da.id) and
                srvid = da.publisher_id and
                s.agent_id = da.id and
                p.publication_id = s.publication_id
    UNION
    select srvname, da.publisher_db, da.publication, p.publication_type, 3, 0, da.name from 
            master..sysservers, 
            MSdistribution_agents da,
            MSpublications p,
            MSsubscriptions s
            where 
                srvid = da.publisher_id and
                not exists (select * from MSdistribution_history dh where dh.agent_id = da.id) and
                s.agent_id = da.id and
                p.publication_id = s.publication_id
    UNION	-- Load distribution dummy rows
	-- The select below will return dumplicates but it will be eliminated by union operator.
    select srvname, da.publisher_db, p.publication, p.publication_type, 
			case	when da.anonymous_agent_id is not null then 3 | @anonymous_mask
					else 3
			end,
			runstatus, da.name from 
            MSdistribution_history dh1, master..sysservers, 
            MSdistribution_agents da, MSpublications p, MSsubscriptions s
            where timestamp = (select max(timestamp) from 
                MSdistribution_history dh2 where
                dh2.agent_id = da.id) and
                srvid = da.publisher_id and
                s.agent_id = da.id and
                p.publication_id = s.publication_id
    UNION -- Load distrbution dummy_rows
    select srvname, da.publisher_db, p.publication, p.publication_type, 3, 0, da.name from 
            master..sysservers, 
            MSdistribution_agents da,
            MSpublications p,
            MSsubscriptions s
            where 
                srvid = da.publisher_id and
                not exists (select * from MSdistribution_history dh where dh.agent_id = da.id) and
                s.agent_id = da.id and
                p.publication_id = s.publication_id
    UNION
    select srvname, ma.publisher_db, ma.publication, 2,
		case	when ma.subscriber_name is not null then 4 | @anonymous_mask
				else 4
		end,
		runstatus, ma.name from 
        MSmerge_history mh1, master..sysservers, MSmerge_agents ma
        where timestamp = (select max(timestamp) from
            MSmerge_history mh2 where
            mh2.agent_id = ma.id) and
            srvid = ma.publisher_id 

    UNION
    select srvname, ma.publisher_db, ma.publication, 2, 4, 0, ma.name from 
        master..sysservers, MSmerge_agents ma
        where 
            srvid = ma.publisher_id and
            not exists (select * from MSmerge_history mh where mh.agent_id = ma.id)

	UNION -- queue reader        
	select 'publisher'= @@servername, 'publisher_db' = db_name(), 'publication' = 'ALL', 
			'publication_type' = 0, 'agent_type' = 9, 'status' = runstatus, 'agent_name' = la.name 
	from MSqreader_history lh1, MSqreader_agents la
	where lh1.timestamp = 
			(select max(timestamp) from MSqreader_history lh2 
			where lh2.agent_id = la.id) 

    order by publisher, publisher_db, publication

go

raiserror(15339,-1,-1,'sp_MSagent_stethoscope')
GO
CREATE PROCEDURE sp_MSagent_stethoscope (
	@heartbeat_interval int = 10  --minutes
)
as
BEGIN
	declare @current_time datetime
			,@agent_name nvarchar(100)
			,@agent_id int
			,@job_id binary(16)
			,@start_time datetime
			,@duration int
			,@comments nvarchar(255)
			,@publisher_id smallint
			,@publisher sysname
			,@publisher_db sysname
			,@heartbeat_failure bit
			,@snapshot_type int
			,@logreader_type int
			,@distribution_type int
			,@merge_type int
			,@qreader_type int
			,@histverboselevel tinyint

	--
	-- initialize
	--
	set nocount on
	select @snapshot_type = 1
			,@logreader_type = 2
			,@distribution_type = 3
			,@merge_type = 4
			,@qreader_type = 9
			,@heartbeat_failure = 0
			,@current_time = getdate()
			,@comments = formatmessage(20554, @heartbeat_interval)

    -- If a running snapshot agent has not logged a history message within the specified
    -- heartbeat_interval then raise a agent suspect error
    declare hC_snapshot_suspect CURSOR LOCAL FAST_FORWARD for 
        select sh1.agent_id, sh1.start_time from MSsnapshot_history sh1 where
            (sh1.runstatus = 1 or sh1.runstatus = 3 or sh1.runstatus = 4) and
            dateadd(minute, @heartbeat_interval, sh1.time) < @current_time and
            sh1.timestamp = (select max(timestamp) from MSsnapshot_history where
                agent_id= sh1.agent_id)
        for read only

    open hC_snapshot_suspect
    fetch hC_snapshot_suspect into @agent_id, @start_time
    while (@@fetch_status <> -1)
    begin

        set @heartbeat_failure = 1

        -- Get the agent name
        select @agent_name = name, @job_id = job_id from MSsnapshot_agents where id = @agent_id

        -- Log a "No action" message on behalf of the agent
        exec dbo.sp_MSadd_snapshot_history
            @agent_id = @agent_id,
            @runstatus = 6,     -- Failure status
            @comments = @comments,
			@do_raiserror = 0

        fetch hC_snapshot_suspect into @agent_id, @start_time
    end
    close hC_snapshot_suspect
    deallocate hC_snapshot_suspect


    -- If a running logreader agent has not logged a history message within the specified
    -- heartbeat_interval then raise a agent suspect error
    declare hC_logreader_suspect CURSOR LOCAL FAST_FORWARD for 
        select la.id, sh1.start_time from MSlogreader_agents la, MSlogreader_history sh1 where
            (sh1.runstatus = 1 or sh1.runstatus = 3 or sh1.runstatus = 4) and
            dateadd(minute, @heartbeat_interval, sh1.time) < @current_time and
            sh1.timestamp = (select max(timestamp) from MSlogreader_history where
                agent_id= sh1.agent_id) and
            la.id = sh1.agent_id
        for read only

    open hC_logreader_suspect
    fetch hC_logreader_suspect into @agent_id, @start_time
    while (@@fetch_status <> -1)
    begin
        set @heartbeat_failure = 1

        -- Get the agent name
        select @agent_name = name, @job_id = job_id from MSlogreader_agents where id = @agent_id

        -- Log a "No action" message on behalf of the agent
        select @publisher_id = publisher_id, @publisher_db = publisher_db from MSlogreader_agents where id = @agent_id
        select @publisher = srvname from master..sysservers where srvid = @publisher_id
        exec dbo.sp_MSadd_logreader_history
            @agent_id = @agent_id,
            @runstatus = 6,     -- Failure status
            @comments = @comments,
			@do_raiserror = 0

        fetch hC_logreader_suspect into @agent_id, @start_time
    end
    close hC_logreader_suspect
    deallocate hC_logreader_suspect

    -- If a running distribution agent has not logged a history message within the specified
    -- heartbeat_interval then raise a agent suspect error
    declare hC_distribution_suspect CURSOR LOCAL FAST_FORWARD for 
        select sh1.agent_id, sh1.start_time from MSdistribution_history sh1 where
            (sh1.runstatus = 1 or sh1.runstatus = 3 or sh1.runstatus = 4) and
            dateadd(minute, @heartbeat_interval, sh1.time) < @current_time and
            sh1.timestamp = (select max(timestamp) from MSdistribution_history where
                agent_id= sh1.agent_id)
        for read only

    open hC_distribution_suspect
    fetch hC_distribution_suspect into @agent_id, @start_time
    while (@@fetch_status <> -1)
    begin
		-- Get the agent name
		select @heartbeat_failure = 1
		select @agent_name = name, @job_id = job_id from MSdistribution_agents where id = @agent_id

		-- Log a "No action" message on behalf of the agent
		exec dbo.sp_MSadd_distribution_history
			@agent_id = @agent_id,
			@runstatus = 6,     -- Failure status
			@comments = @comments,
			@do_raiserror = 0
        fetch hC_distribution_suspect into @agent_id, @start_time
    end
    close hC_distribution_suspect
    deallocate hC_distribution_suspect

    -- If a running merge agent has not logged a history message within the specified
    -- heartbeat_interval then raise a agent suspect error
    declare hC_merge_suspect CURSOR LOCAL FAST_FORWARD for 
        select sh1.agent_id, sh1.start_time from MSmerge_history sh1 where
            (sh1.runstatus = 1 or sh1.runstatus = 3 or sh1.runstatus = 4) and
            dateadd(minute, @heartbeat_interval, sh1.time) < @current_time and
            sh1.timestamp = (select max(timestamp) from MSmerge_history where
                agent_id= sh1.agent_id)
        for read only

    open hC_merge_suspect
    fetch hC_merge_suspect into @agent_id, @start_time
    while (@@fetch_status <> -1)
    begin
        set @heartbeat_failure = 1

        -- Get the agent name
        select @agent_name = name, @job_id = job_id from MSmerge_agents where id = @agent_id

        -- Log a "No action" message on behalf of the agent
        exec dbo.sp_MSadd_merge_history
            @agent_id = @agent_id,
            @runstatus = 6,     -- Failure status
            @comments = @comments,
			@do_raiserror = 0

        fetch hC_merge_suspect into @agent_id, @start_time
    end
    close hC_merge_suspect
    deallocate hC_merge_suspect

    -- If a running queuereader agent has not logged a history message within the specified
    -- heartbeat_interval then raise a agent suspect error
    declare hC_qrdr_suspect CURSOR LOCAL FAST_FORWARD for 
        select sh1.agent_id, sh1.start_time from MSqreader_history sh1 where
            (sh1.runstatus = 1 or sh1.runstatus = 3 or sh1.runstatus = 4) and
            dateadd(minute, @heartbeat_interval, sh1.time) < @current_time and
            sh1.timestamp = (select max(timestamp) from MSqreader_history where
                agent_id= sh1.agent_id)
        for read only

    open hC_qrdr_suspect
    fetch hC_qrdr_suspect into @agent_id, @start_time
    while (@@fetch_status <> -1)
    begin
        set @heartbeat_failure = 1

        -- Get the agent name
        select @agent_name = name, @job_id = job_id from MSqreader_agents where id = @agent_id

        -- Log a "No action" message on behalf of the agent
        exec dbo.sp_MSadd_qreader_history
            @agent_id = @agent_id,
            @runstatus = 6,     -- Failure status
            @comments = @comments,
			@do_raiserror = 0

        fetch hC_qrdr_suspect into @agent_id, @start_time
    end
    close hC_qrdr_suspect
    deallocate hC_qrdr_suspect

    -- Log all is fine message
    if @heartbeat_failure = 0
        -- "Detected heartbeat for all running Replication Agents"
		set @comments = formatmessage(20556)    
	else
        -- "Could not detected heartbeat for all running Replication Agents"
		set @comments = formatmessage(20580)    

    raiserror (20554, 10, -1, @heartbeat_interval)
END
GO

raiserror(15339,-1,-1,'sp_MSlock_distribution_agent')
GO

CREATE PROCEDURE sp_MSlock_distribution_agent (
    @id int,
    @mode int = 1 -- 0: shared  1: exclusive
) AS


    SET         NOCOUNT ON
    DECLARE     @active tinyint
    declare     @count  int
    select @active = 2
    if @mode = 0
        select @count = count(*) from MSsubscriptions (ROWLOCK REPEATABLEREAD) where agent_id = @id and status = @active
    else
        select @count = count(*) from MSsubscriptions (ROWLOCK UPDLOCK) where agent_id = @id and status = @active
GO

raiserror(15339,-1,-1,'sp_MSdetect_nonlogged_shutdown')
GO
create procedure sp_MSdetect_nonlogged_shutdown
@subsystem nvarchar(60),
@agent_id int
as
    declare @job_id binary(16)
    declare @agent_name nvarchar(100)
    declare @message nvarchar(1024)
    declare @retcode int
    declare @runstatus int

    -- Detect if the agent was shutdown without a logged reason
    if UPPER(@subsystem collate SQL_Latin1_General_CP1_CS_AS) = 'SNAPSHOT'
    begin
        if exists (select runstatus from MSsnapshot_history where 
            agent_id = @agent_id and
            runstatus <> 2 and 
--CAC       runstatus <> 5 and 
            runstatus <> 6 and
            timestamp = (select max(timestamp) from MSsnapshot_history where agent_id = @agent_id))
            begin
                select @job_id = job_id, @agent_name = name from MSsnapshot_agents where id = @agent_id
            end
    end
    else if UPPER(@subsystem collate SQL_Latin1_General_CP1_CS_AS) = 'LOGREADER'
    begin
        if exists (select runstatus from MSlogreader_history where 
            agent_id = @agent_id and
            runstatus <> 2 and 
--CAC           runstatus <> 5 and 
            runstatus <> 6 and
            timestamp = (select max(timestamp) from MSlogreader_history where agent_id = @agent_id))
            begin
                select @job_id = job_id, @agent_name = name from MSlogreader_agents where id = @agent_id
            end
    end
    else if UPPER(@subsystem collate SQL_Latin1_General_CP1_CS_AS) = 'DISTRIBUTION'
    begin
        if exists (select runstatus from MSdistribution_history where 
            agent_id = @agent_id and
            runstatus <> 2 and 
--CAC           runstatus <> 5 and 
            runstatus <> 6 and
            timestamp = (select max(timestamp) from MSdistribution_history where agent_id = @agent_id))
            begin
                select @job_id = job_id, @agent_name = name from MSdistribution_agents where id = @agent_id
            end
    end
    else if UPPER(@subsystem collate SQL_Latin1_General_CP1_CS_AS) = 'MERGE'
    begin
        if exists (select runstatus from MSmerge_history where 
            agent_id = @agent_id and
            runstatus <> 2 and 
--CAC           runstatus <> 5 and 
            runstatus <> 6 and
            timestamp = (select max(timestamp) from MSmerge_history where agent_id = @agent_id))
            begin
                select @job_id = job_id, @agent_name = name from MSmerge_agents where id = @agent_id
            end
    end
    else if UPPER(@subsystem collate SQL_Latin1_General_CP1_CS_AS) = 'QUEUEREADER'
    begin
        if exists (select runstatus from MSqreader_history where 
            agent_id = @agent_id and
            runstatus <> 2 and 
--CAC       runstatus <> 5 and 
            runstatus <> 6 and
            timestamp = (select max(timestamp) from MSqreader_history where agent_id = @agent_id))
            begin
                select @job_id = job_id, @agent_name = name from MSqreader_agents where id = @agent_id
            end
    end

    -- If no job_id assume shutdown was logged properly
    if @job_id is null
        return 0

    -- Get last message from SQL Agent History table
    create table #JobHistory (
        instance_id int NOT NULL, 
        job_id uniqueidentifier NOT NULL,
        job_name nvarchar(100) NOT NULL,
        step_id int NOT NULL,
        step_name nvarchar(100) NOT NULL, 
        sql_message_id int NOT NULL,
        sql_severity int NOT NULL,
        message nvarchar(1024) NOT NULL,
        run_status int NOT NULL,
        run_date int NOT NULL,
        run_time int NOT NULL,
        run_duration int NOT NULL,
        operator_emailed sysname NULL,
        operator_netsent sysname NULL,
        operator_paged sysname NULL,
        retries_attempted int NOT NULL,
        server sysname NOT NULL
    )
    if @@error <> 0
        return 1

    -- Insert last history for step_id 2 (Agent running)
    set rowcount 1
    insert into #JobHistory exec msdb.dbo.sp_help_jobhistory @job_id = @job_id, @step_id = 2, 
        @mode = 'FULL'          

    -- Get the last history
    select @message = message, @runstatus = run_status from #JobHistory

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

    -- If no message, provide a default message
	-- Also overwrite all inprogress messages to be "See SQL Agent history log".
	-- This is to prevent "Agent running. See monitor" to be logged into repl monitor.
	-- In this case (the last job history message is InProgress), we know that
	-- there have been failures of SQL Server Agent history logging.
	-- In fact, the only possible "in progress" msg in SQL Agent job step
	-- history for push jobs is "Agent running. See monitor". It is confusing that those
	-- messages showed up in repl monitor.
    if @message is null or @runstatus = 3
        select @message = formatmessage(20557, @agent_name)

    if UPPER(@subsystem collate SQL_Latin1_General_CP1_CS_AS) = 'SNAPSHOT'
        exec @retcode = dbo.sp_MSadd_snapshot_history @agent_id = @agent_id, @runstatus = @runstatus,
                @comments = @message
    else if UPPER(@subsystem collate SQL_Latin1_General_CP1_CS_AS) = 'LOGREADER'
        exec @retcode = dbo.sp_MSadd_logreader_history @agent_id = @agent_id, @runstatus = @runstatus,
                @comments = @message
    else if UPPER(@subsystem collate SQL_Latin1_General_CP1_CS_AS) = 'DISTRIBUTION'
        exec @retcode = dbo.sp_MSadd_distribution_history @agent_id = @agent_id, @runstatus = @runstatus,
                @comments = @message
    else if UPPER(@subsystem collate SQL_Latin1_General_CP1_CS_AS) = 'MERGE'
        exec @retcode = dbo.sp_MSadd_merge_history @agent_id = @agent_id, @runstatus = @runstatus,
                @comments = @message
    else if UPPER(@subsystem collate SQL_Latin1_General_CP1_CS_AS) = 'QUEUEREADER'
        exec @retcode = dbo.sp_MSadd_qreader_history @agent_id = @agent_id, @runstatus = @runstatus,
                @comments = @message

    if @@error <> 0 or @retcode <> 0
        return 1

    drop table #JobHistory

GO

raiserror(15339,-1,-1,'sp_MSenumerate_PAL')
GO

CREATE PROCEDURE sp_MSenumerate_PAL (
    @publisher sysname,
    @publisher_db sysname,
    @publication sysname) 
AS
    declare @publication_id int
    declare @publisher_id smallint
    declare @retcode int
    
    -- Check if publisher is a defined as a distribution publisher in the current database
    exec @retcode = dbo.sp_MSvalidate_distpublisher @publisher, @publisher_id OUTPUT
    if @retcode <> 0
    begin
        return(1)
    end

    select @publication_id = publication_id from MSpublications where 
        publisher_id = @publisher_id and
        publisher_db = @publisher_db and
        publication = @publication

    -- Publication does not exist
    if @publication_id is null
    begin
        return (1)
    end

    select login from MSpublication_access where
                publication_id = @publication_id
GO
    


raiserror(15339,-1,-1,'sp_MSpublication_access')
GO

CREATE PROCEDURE sp_MSpublication_access (
    @publisher sysname,
    @publisher_db sysname = NULL,
    @publication sysname = NULL,
    @login sysname = NULL,
    @operation nvarchar(20), -- Can be add/drop/check/help/get_publications/get_logins
    @has_access bit = 0 output, -- Used only in check
    @skip bit = 0
        ) AS
-- This sp can be called repeatedly.
    
    declare @publisher_id smallint
    declare @retcode int
    declare @publication_id int
    declare @isntname bit
    declare @server_access bit
    declare @privilege nchar(21)
    declare @rowcount int

    -- Check if publisher is a defined as a distribution publisher in the current database
    exec @retcode = dbo.sp_MSvalidate_distpublisher @publisher, @publisher_id OUTPUT
    if @retcode <> 0
    begin
        return(1)
    end

    -- Check to see if the login exists and if the login is NT login
    select @isntname = isntname from master..syslogins where
        sid = suser_sid(@login) and
        hasaccess = 1

    -- Get the publication id 
    select @publication_id = publication_id from MSpublications where 
        publisher_id = @publisher_id and
        publisher_db = @publisher_db and
        publication = @publication

    -- Publication does not exist
    if @publication_id is null and
        @operation in ('add','drop','check','help')
    begin
        raiserror (20026, 16, -1, @publication)
        return (1)
    end

    if @operation = 'add'
    begin
        -- Login does not have access
        if @isntname is null
        begin
            if @skip = 0
            begin
                raiserror(21048, 16, -1, @login, @@servername) 
                return (1)
            end
            else
                return (0)
        end

        -- Add login to the access list if it does not exist
        if not exists (select * from MSpublication_access where
            publication_id = @publication_id and
            login = @login)
        begin
            insert MSpublication_access (publication_id, login)
                values (@publication_id,@login)
            if  @@error <> 0
                return(1)
        end
    end
    else if @operation = 'drop'
    begin
        if @isntname is null and not exists (select * from MSpublication_access where
                publication_id = @publication_id and
                login = @login) 
        begin
            raiserror(15007,10,-1,@login)
            return 1
        end
        -- Do check existense when dropping since the login might be dropped
        -- outside replication already.
        delete MSpublication_access where
                publication_id = @publication_id and
                login = @login
        select @rowcount = @@rowcount


        if isnull(@rowcount, 0) > 0
        begin
            -- Flush the cache for this publication id
            if exists (select * from tempdb..sysobjects where name = 'MSdistributor_access')
            begin
                delete tempdb..MSdistributor_access
                 where (publication_id = @publication_id 
                        or (agent_type = 0 -- Distribution agents 
                            and agent_id in 
                            (select agent_id from MSsubscriptions s
                              where s.publication_id = @publication_id)))
                   and db_id = db_id()
                if @@error <> 0
                    return(1)
            end
        end

    end
    else if @operation = 'check'
    begin
        -- Cover the case when
        -- the NT user is not in syslogins
        if @isntname is null and suser_sid(@login) is not null
            select @isntname = 1

        -- If the login is valid NT login, call set user
        if @isntname = 1
        begin
            setuser @login
            if @@error <> 0
            begin
                raiserror (21142, 16, -1, @@servername, @login)
                return(1)
            end
        end
        if exists (select * from MSpublication_access l where
            publication_id = @publication_id and
            (l.login = @login or (@isntname = 1 and exists (select * from master..syslogins
                where sid = suser_sid(l.login) and isntgroup = 1 and is_member(l.login) = 1))))
            set @has_access = 1
        else
            set @has_access = 0
        if @isntname = 1
        begin
            setuser
            if @@error <> 0
                return(1)
        end        
    end
    else if @operation = 'help'
    begin
        select login from MSpublication_access where
                    publication_id = @publication_id and
                    login like @login
    end
    else if @operation = 'get_publications'
    begin
        -- Avoid setuser failure and cover the case of that 
        -- the NT user is not in syslogins
        if @isntname is null and suser_sid(@login) is not null
        begin
            exec @retcode = master.dbo.xp_logininfo
                @login, N'all', @privilege output
            if @privilege is not null
                select @isntname = 1
        end

        -- If the login is valid NT login, call set user
        if @isntname = 1
        begin
            setuser @login
            -- If the login is invalid, don't return any result.
            if @@error <> 0
            begin
                raiserror (21142, 16, -1, @@servername, @login)
                return(0)
            end
        end
        select p.publisher_db, p.publication from MSpublication_access l,
            MSpublications p where
            -- Get all the non default publications that have the login in the access list
            (
            -- If login match or there is an NT group in the access list and @login is integrated
            (l.login = @login or ( @isntname = 1 and exists (select * from master..syslogins
                where sid = suser_sid(l.login) and isntgroup = 1 and is_member(l.login) = 1))) and
            l.publication_id = p.publication_id and
            p.publisher_id = @publisher_id
            ) 
        if @isntname = 1
        begin
            setuser
            if @@error <> 0
                return(1)
        end        
    end
    else if @operation = 'get_logins'
    begin
        select loginname from master..syslogins where
            hasaccess = 1
    end
GO


raiserror(15339,-1,-1,'sp_MSdrop_6x_publication')
GO

-- This stored procedure is called by sp_droptask when 6.x publications are dropped.
create procedure sp_MSdrop_6x_publication
@job_id UNIQUEIDENTIFIER
as
    declare @publisher sysname
    declare @publisher_db sysname
    declare @publication sysname
    declare @retcode int

    -- Get publication information
    select @publisher = srvname, @publisher_db = publisher_db, @publication = publication from 
        MSsnapshot_agents, master..sysservers where
        job_id = @job_id and
        srvid = publisher_id

    -- Remove the publication and snapshot agent
    exec @retcode = dbo.sp_MSdrop_publication
        @publisher = @publisher,
        @publisher_db = @publisher_db,
        @publication = @publication 
    if @@ERROR <> 0 or @retcode <> 0
        return 1
GO

raiserror(15339,-1,-1,'sp_MShelp_distribution_agentid')
GO

CREATE PROCEDURE sp_MShelp_distribution_agentid
@publisher_id smallint,
@publisher_db sysname,
@publication sysname = NULL,
@subscriber_id smallint,
@subscriber_db sysname,
@subscription_type int, /* 0 = push 1 = pull 2=anonymous, */
-- For anonymous only
@subscriber_name    sysname = NULL,
@anonymous_subid    uniqueidentifier = NULL,
@reinitanon         bit = 0

as

    set nocount on

	declare @independent_agent bit
    declare @xact_seqno_length int
    declare @agent_id int
    declare @third_party_flag bit
    declare @retcode int
    declare @anonymous int
    declare @sub_agent_id int
	declare @allow_subscription_copy bit
	declare @immediate_sync bit

    select @anonymous = 2
    
	if @publication is null
		select @independent_agent = 0
	else
		select @independent_agent = 1

    select  top 1
        @third_party_flag = thirdparty_flag,
		@allow_subscription_copy = allow_subscription_copy,
		@immediate_sync = immediate_sync
        from MSpublications where
        publisher_id = @publisher_id and
        publisher_db = @publisher_db and
		publication = @publication or 
		(@publication is null and independent_agent = 0)

	-- Get agent id
	if @subscription_type = @anonymous
    begin
        exec @retcode = dbo.sp_MSadd_anonymous_agent
            @publisher_id   = @publisher_id,
            @publisher_db   = @publisher_db,
            @publication    = @publication,
            @subscriber_db  = @subscriber_db,
            @subscriber_name = @subscriber_name,
            @anonymous_subid =  @anonymous_subid output,
            @agent_id = @agent_id output,
            @reinitanon = @reinitanon
        if @@error <> 0 or @retcode <> 0
            return (1)

		-- Refer to sp_MSget_subscription_guid
        select @sub_agent_id = virtual_agent_id from
            MSdistribution_agents where
            id = @agent_id
    end 
    else
    begin
        select @agent_id = id
        from MSdistribution_agents where
             publisher_id = @publisher_id and
             publisher_db = @publisher_db and
             (publication = @publication or
             (@publication is null and publication = N'ALL')) and
             subscription_type = @subscription_type and
             subscriber_id = @subscriber_id and
             subscriber_db = @subscriber_db

		-- If cannont find the agent entry, ignore @subscriber_db and try again 
		-- for non SQL subscribers
		-- Note that this preserved backward compatibility for 7.0 publisher, 7.0 pull distribution agent or 6.5 pub.
		-- In 7.0, we hard code name 'DSN'.
		-- In 6.5 pub, the db name is real database name.
		-- In 8.0, distribution agent sends in unlocalized '(default destination)' as default db name for 
		-- non SQL subscribers..
		if @agent_id is null 
		begin
			declare @publisher sysname
			declare @subscriber sysname
			select @publisher = srvname from master..sysservers where
				srvid = @publisher_id
			select @subscriber = srvname from master..sysservers where
				srvid = @subscriber_id
			if exists (select * from MSsubscriber_info where
				publisher = @publisher and
				subscriber = @subscriber and
				type <> 0)
			begin
				select @agent_id = id
				from MSdistribution_agents where
					 publisher_id = @publisher_id and
					 publisher_db = @publisher_db and
					 (publication = @publication or
					 (@publication is null and publication = N'ALL')) and
					 subscription_type = @subscription_type and
					 subscriber_id = @subscriber_id 
			end
		end

        select @sub_agent_id = @agent_id
    end

	-- If cannot find the publication and the agent, raise error
	-- saying invalid publication.
    -- Note: can not fail if publication not exists but agent exists
    -- It is an upgrade case. 
    if @third_party_flag is null and @agent_id is null
    begin
        -- The publication(s) does not exist
        RAISERROR (21073, 16, -1)
        return(1)
    end

    if @agent_id is null
    begin
		-- Raise a special error for a common error case: user specified publication
		-- name for non independent agent publication.
        -- If the specified publication name is in MSpublications table then
        -- the publication is configured to use a non-independent distribution
        -- agent. Raise a different error if this is the case
        if @publication is not null and 
            exists (select * from MSpublications 
                    where publication = @publication and 
                          publisher_id = @publisher_id and
                          publisher_db = @publisher_db and
                          independent_agent = 0)  
        begin
            RAISERROR (21133, 16, -1, @publication)
        end
        else
        begin
            -- Invalid subscription
            RAISERROR (21056, 16, -1, @publication)
        end
        return(1)
    end

	-- Reset null properties
    -- It is an upgrade case. 
    if @third_party_flag is null 
        select @third_party_flag = 0
	if @allow_subscription_copy is null
		select @allow_subscription_copy = 0

	/*
	** Get the time when the subscription is active and succeed.
	*/
	/*
	select Top 1 @last_status=runstatus, @last_sync = time from MSdistribution_history 
		where agent_id = @agent_id order by timestamp DESC
	
	if @last_status = 6 and EXISTS (select * from MSdistribution_history where agent_id = @agent_id and runstatus = @success) 
        		select Top 1 @last_sync = time from MSdistribution_history where agent_id = @agent_id and runstatus = @success
        				order by timestamp DESC	

    if @last_sync is not NULL and @independent_agent = 1 --by pass the retention check for non-independent agnt
	begin
    	if (@last_sync < dateadd(hour, -@retention, getdate()))
           and (@retention <> 0)
 				select @expired = 1 
	end
	*/

    /* 
    ** Avoid returning a NULL value 
    ** Otherwise, distribution agent may fail
    */
    select @xact_seqno_length = 0

    /* 
    **  Get the lengh of xact_seqno
    **   Currently, unique across the publisher
    */
    select top 1 @xact_seqno_length = DATALENGTH(subscription_seqno)
    from MSsubscriptions s where
        agent_id = @sub_agent_id

    /* xact_seqno for snapshot trans are longer for native publishers*/
    if @third_party_flag = 0
    begin
        if @xact_seqno_length = 8 or @xact_seqno_length = 10
            select @xact_seqno_length = @xact_seqno_length + 4
    end

    -- Security check. Do it here to let the agent fail at the beginning
    exec @retcode = dbo.sp_MScheck_pull_access
        @agent_id = @sub_agent_id,
        @agent_type = 0 -- distribution agent
    if @@error <> 0 or @retcode <> 0
        return (1)
	
	-- Get update_mode
	declare @update_mode int
	
	-- Use max because:
	-- One agent can have mixed read only (0) and synctran (1) subscriptions. 
	-- The update mode value
	-- is used in subscriber triggers. It is ok to set update mode to synctran
	-- in mixed case because the triggers will not be create for read only.
	-- Queued mode require independent agent.
	select @update_mode = max(update_mode) from MSsubscriptions where
		agent_id = @agent_id
	
	-- For anonymous agents, update_mode is read only.
	if @update_mode is null
		set @update_mode = 0

	-- Get attach_version guid
	declare @attach_version binary(16)
	if @allow_subscription_copy <> 0
	begin
		declare @publication_id int
		declare @virtual_agent_id int
		declare @virtual smallint
		set @virtual = -1

		-- Get publication_id
		select @publication_id = publication_id
			from MSpublications where
			publisher_id = @publisher_id and
			publisher_db = @publisher_db and
			publication = @publication 

		if @publication_id is null
		begin
			RAISERROR (21040, 16, -1, @publication)
			return 1
		end

		-- Get version agent_id
		select top 1 @virtual_agent_id = agent_id from MSsubscriptions where
			publisher_id = @publisher_id and
			publisher_db = @publisher_db and
			publication_id = @publication_id and
			subscriber_id = @virtual

		select @attach_version = subscription_guid from MSdistribution_agents
			where id = @virtual_agent_id
	end
	else
		-- set a irrelevent guid. It should never be used.
		select @attach_version = newid()

	-- Get subscription guid
	-- Use sub_agent_id so that both anonymous and well-known work.
	-- Refer to sp_MSget_subscription_guid. You need to make change to that sp when changing
	-- this.
	declare @subscription_guid binary(16)
	select @subscription_guid = subscription_guid from MSdistribution_agents where
		id = @sub_agent_id

    select 
        'xact_seqno_length' = @xact_seqno_length,
        'agent_id' = @agent_id,
        'agent_name' = name,
        'anonymous subid' = anonymous_subid,
        'expired ' = convert(int, 0),
		'dts_package_name' = dts_package_name,
		'dts_package_password' = dts_package_password,
		'dts_package_location' = dts_package_location,
		'immediate_sync' = @immediate_sync,
		'allow_subscription_copy' = @allow_subscription_copy,
		'queue_id' = queue_id,
		'update_mode' = @update_mode,
		'attach_version' = @attach_version,
		'subscription_guid' = @subscription_guid,
		'queue_server' = queue_server
		
        from MSdistribution_agents where id = @agent_id

GO

raiserror(15339,-1,-1,'sp_MScheck_tran_retention')
GO

CREATE PROCEDURE sp_MScheck_tran_retention
@xact_seqno varbinary(16),
@agent_id int
as

    set nocount on

	declare @retcode tinyint
	declare @date datetime
	declare @retention int
	declare	@expired int
	declare @publisher_database_id int

	-- Security Check
	exec @retcode = dbo.sp_MScheck_pull_access @agent_id = @agent_id,	-- agent id
										        @agent_type = 0 		-- only called by distribution agent
    if @@error <> 0 or @retcode <> 0
    begin
        return (1)
    end

	select @publisher_database_id = publisher_database_id from MSdistribution_agents
		where id = @agent_id

	select @date = entry_time from MSrepl_transactions where
		xact_seqno = @xact_seqno and
		publisher_database_id = @publisher_database_id

	select @retention = max_distretention from msdb..MSdistributiondbs where
		name = db_name()

	if (@date is not null and datediff(minute, @date, getdate()) < @retention*60) or
		-- For 'sync with backup' dist db where
		-- the dist db might be restored to a previous version so that the subscriber's
		-- xact_seqno is larger.
	   (@date is null and not exists (select * from MSrepl_transactions where
		xact_seqno >= @xact_seqno and
		publisher_database_id = @publisher_database_id))
		select @expired = 0
	else
		select @expired = 1
	
	select N'expired' = @expired

GO

raiserror(15339,-1,-1,'sp_MSmarkreinit')
GO
CREATE PROCEDURE sp_MSmarkreinit
@publisher sysname,
@publisher_db sysname,
@publication sysname,
@subscriber sysname,       
@subscriber_db sysname,
@reset_reinit	int
AS
	set nocount on

    declare @publisher_id smallint
    declare @subscriber_id smallint
    declare @publication_id int
    declare @retcode int
	declare @reinited int
	declare @unreinited int
	declare @status int
 
	select @reinited = 4  -- status=4 means this subscription has been reinited
	select @unreinited = 1 -- status=1 means this subscription not reinited
    select @retcode = 0

	if @reset_reinit = 1
		select @status = @reinited
	else
		select @status = @unreinited
	
-- Check if publisher is a defined as a distribution publisher in the current database
    exec @retcode = dbo.sp_MSvalidate_distpublisher @publisher, @publisher_id OUTPUT
    if @retcode <> 0
    begin
        return(1)
    end

    -- Get the publication information 
    select @publication_id = publication_id
		from MSpublications where 
        publisher_id = @publisher_id and
        publisher_db = @publisher_db and
        publication = @publication
    if @publication_id is NULL
    begin
        raiserror (20026, 11, -1, @publication)
        return (1)
    end

    -- Perform PAL check with retrieved @publication_id
    exec @retcode = dbo.sp_MScheck_pull_access
        @agent_type = 1,
        @publication_id = @publication_id
    if @@error <> 0 or @retcode <> 0
        return (1)

    -- Get subscriber info
    select @subscriber_id = srvid from master..sysservers where UPPER(srvname) = UPPER(@subscriber)

	update MSmerge_subscriptions set status = @status where
		publisher_id = @publisher_id and 
        publisher_db = @publisher_db and 
        publication_id = @publication_id and
        subscriber_id = @subscriber_id and
        subscriber_db = @subscriber_db
    if @@error<>0 
    	return (1)
GO    	

raiserror('Creating procedure sp_MSfetchAdjustidentityrange', 0,1)
GO

CREATE PROCEDURE sp_MSfetchAdjustidentityrange 
	@publisher			sysname,
	@publisher_db		sysname,
	@tablename			sysname,
	@adjust_only		bit = 0,
	@for_publisher		tinyint = 0, --0 for subscriber, 1 for publisher, 2 for republisher
	@range				bigint = 0 output, -- This parameter is used as input for publisher but output for subscriber
	@next_seed			bigint = 0 output,
	@threshold			int = 0 output
as
	declare @tmp int
	declare @publication_id int
	declare @got_access bit
	declare @publisher_id int
	declare @retcode int

    -- Security check
    SELECT @publisher_id = NULL 
    SELECT @publisher_id = srvid 
      FROM master..sysservers
     WHERE UPPER(@publisher) = UPPER(srvname)  
    IF @publisher_id IS  NULL
    BEGIN
        RAISERROR(21169, 16, -1, @publisher, @@SERVERNAME, @publisher)    
    END

    if not exists (select * from 
        MSpublications where 
        publisher_id = @publisher_id and
        publisher_db = @publisher_db)
    begin
        raiserror (20026, 11, -1, 'any')
        return (1)
    end

    declare publications_cursor CURSOR LOCAL FAST_FORWARD 
        for select publication_id from MSpublications where publisher_id = @publisher_id and publisher_db = @publisher_db

    select @got_access = 0
    open publications_cursor
    fetch publications_cursor into @publication_id
    while (@@fetch_status <> -1)
    begin
        exec @retcode = dbo.sp_MScheck_pull_access
            @agent_type = 1, -- merge agent
            @publication_id = @publication_id
        if (@retcode = 0 and @got_access = 0)
            select @got_access = 1
        fetch publications_cursor into @publication_id
    end
    close publications_cursor
    deallocate publications_cursor

    if @got_access = 0
    begin
		RAISERROR (15247, 11, -1)
		return (1)
    end
    -- end security check

    
	if @adjust_only=0
		select identity_support, next_seed, range, threshold from MSrepl_identity_range
			where  tablename=@tablename and LOWER(publisher)=LOWER(@publisher) and publisher_db=@publisher_db

	-- Note: there might be multiple sessions calling this sp at the same time
	-- Open a transaction so that the update row will be locked so that no one else can
	-- process this row.
	begin tran
    save TRAN sp_MSfetchAdjustidentityrange
	select @tmp = 1 from MSrepl_identity_range (tablockx holdlock) where 1 = 2
	if @for_publisher=2 --republishing scenario
	begin
		update MSrepl_identity_range set max_identity=@next_seed + @range, next_seed=@next_seed
			where tablename=@tablename and LOWER(publisher)=LOWER(@publisher) and publisher_db=@publisher_db			
	end
	else
	begin    
		update MSrepl_identity_range set next_seed = case @for_publisher
			-- use subscriber's range 
			when 0 then next_seed + range
			-- use @range sent in by the publisher
			else next_seed + @range
			end
		where tablename=@tablename and LOWER(publisher)=LOWER(@publisher) and publisher_db=@publisher_db
	end

	-- for tran pub, max_identity is null
	if @@ERROR<>0 OR exists (select * from MSrepl_identity_range where ABS(next_seed)>ABS(max_identity))
	begin
		raiserror(21195, 16, -1)
		goto UNDO
	end

	select @next_seed = next_seed, @range = range, @threshold = threshold from MSrepl_identity_range
		where tablename=@tablename and LOWER(publisher)=LOWER(@publisher) and publisher_db=@publisher_db
	
	commit tran
	return 0

UNDO:
    if @@TRANCOUNT > 0
    begin
        ROLLBACK TRAN sp_MSfetchAdjustidentityrange
        COMMIT TRAN
    end
    return(1)

go			
exec dbo.sp_MS_marksystemobject sp_MSfetchAdjustidentityrange 
go
grant exec on dbo.sp_MSfetchAdjustidentityrange to public
go

raiserror(15339,-1,-1,'sp_MSreinit_subscription')
GO
CREATE PROCEDURE sp_MSreinit_subscription
@publisher_name sysname,
@publisher_db sysname,
@publication sysname = 'all',
@subscriber_name    sysname = 'all',
@subscriber_db sysname = 'all'
as
    set nocount on
    declare @proc nvarchar(2048)
    declare @retcode int

    if @publisher_name IS NULL or NOT EXISTS (select * from master..sysservers as ss, MSpublications as msp
        where lower(ss.srvname) = lower(@publisher_name) and msp.publisher_id = ss.srvid)
    begin
        return (1)
    end

    if @publisher_db IS NULL
        select @publisher_db = ''

    select @proc = @publisher_name + '.' + @publisher_db + '.dbo.sp_reinitsubscription '
    exec @retcode = @proc @publication, 'all', @subscriber_name, @subscriber_db

    return (@retcode)
go

   -- View for delivered and undelivered commands.   RHS  6-4-98
   -- Since the view is likely to change, just recreate it each time.
   IF EXISTS (SELECT * FROM sysobjects where name='MSdistribution_status' and type='V')
    DROP VIEW dbo.MSdistribution_status

    /****************************************************************************/
    raiserror('Creating view MSdistribution_status', 0,1)
        /****************************************************************************/    
go

CREATE VIEW MSdistribution_status (article_id,agent_id,UndelivCmdsInDistDB,DelivCmdsInDistDB)
as
-- Note that this view does not account for (i.e. exclude from counts) commands that do not need to be delivered 
-- because of loopback or syncronous updating subscribers, nor subscriptions never activated.
-- It also may not be exact due to use of NOLOCK - so that it does not cause blocking or deadlock issues.
SELECT t.article_id,s.agent_id,
'UndelivCmdsInDistDB'=SUM(CASE WHEN xact_seqno > h.maxseq THEN 1 ELSE 0 END),
'DelivCmdsInDistDB'=SUM(CASE WHEN xact_seqno <=  h.maxseq THEN 1 ELSE 0 END)
FROM	(SELECT	article_id,publisher_database_id, xact_seqno
	FROM MSrepl_commands (NOLOCK) ) as t
JOIN (SELECT agent_id,article_id,publisher_database_id FROM MSsubscriptions (NOLOCK) ) AS s 
ON (t.article_id = s.article_id AND t.publisher_database_id=s.publisher_database_id )
JOIN (SELECT agent_id,'maxseq'= isnull(max(xact_seqno),0x0) FROM MSdistribution_history (NOLOCK) GROUP BY agent_id) as h
ON (h.agent_id=s.agent_id)
GROUP BY t.article_id,s.agent_id
go
    
EXEC dbo.sp_MS_marksystemobject 'MSdistribution_status'
-- As this view can add considerable overhead when queried, it intentionally is not granted public access by default.
-- A site may so grant it if it wants to of course>
GRANT SELECT ON MSdistribution_status to dbo
go


raiserror(15339,-1,-1,'sp_browsereplcmds')
GO

create procedure sp_browsereplcmds 
@xact_seqno_start nchar(22) = NULL, 
@xact_seqno_end nchar(22) = NULL,
@originator_id int = NULL,
@publisher_database_id int = NULL,
@article_id int = NULL,
@command_id int = NULL,
@results_table sysname = NULL
as
declare @query nvarchar( 4000 )
declare @dbname sysname

if( @command_id is not null )
begin
    if( @xact_seqno_start is null or @publisher_database_id is null )
    begin
        raiserror( 21110, 16, -1 )
        return 1
    end
    else if @xact_seqno_start != @xact_seqno_end 
    begin
        raiserror( 21109, 16, -1 )
        return 1
    end
end

if @results_table is not null
begin
	select @query = N'create table ' + @results_table + N'('
	select @query = @query + N'xact_seqno varbinary(16) null,'
	select @query = @query + N'originator_id int null,'
	select @query = @query + N'publisher_database_id int null,'
	select @query = @query + N'article_id int null,'
	select @query = @query + N'type int null,'
	select @query = @query + N'command nvarchar( 1024 ) null )'

	exec ( @query )
	if @@error <> 0
	begin
		return 1
	end
end

if @xact_seqno_start is null
begin
    select @xact_seqno_start = N'0x00000000000000000000'
end
if @xact_seqno_end is null
begin
    select @xact_seqno_end = N'0xFFFFFFFFFFFFFFFFFFFF'
end

select @query = N'select xact_seqno, convert( int, originator_id ), convert( int, publisher_database_id ), convert(int, article_id), convert( int, type ), convert( int, partial_command ), command from MSrepl_commands '

if @command_id is not null
begin
    select @query = @query + N'where xact_seqno = ' + @xact_seqno_start  
end
else
begin
    select @query = @query + N'where xact_seqno >= ' + @xact_seqno_start + N' and xact_seqno <= ' + @xact_seqno_end 
end

if @originator_id is not null
begin
    select @query = @query + N' and originator_id = ' + convert( nvarchar, @originator_id )
end

if @publisher_database_id is not null
begin
    select @query = @query + N' and publisher_database_id = ' + convert( nvarchar, @publisher_database_id )
end

if @article_id is not null
begin
    select @query = @query + N' and article_id = ' + convert( nvarchar, @article_id )
end

if @command_id is not null
begin
	-- No need to use article_id and originator_id
    select @query = @query + N' and command_id >= ' + convert( nvarchar, @command_id )
    select @query = @query + N' and command_id <= ( select min( command_id ) from MSrepl_commands c '
    select @query = @query + N' where c.xact_seqno = ' + @xact_seqno_start  
    select @query = @query + N' and c.publisher_database_id = ' + convert( nvarchar, @publisher_database_id )
    select @query = @query + N' and c.command_id >= ' + convert( nvarchar, @command_id )
    select @query = @query + N' and c.partial_command = 0 )'  
end

select @query = @query + N' order by originator_id, publisher_database_id, xact_seqno, article_id, command_id asc'

select @dbname = db_name()

if @results_table is not null
begin
	declare @q2 nvarchar(4000)
	select @query = replace( @query, '''', '''''' )
	select @q2 = N'insert into ' + @results_table + N' exec master..xp_printstatements N'''+ @query + N''',N''' + @dbname  +''''
	exec (@q2)
end
else
begin
	exec master..xp_printstatements @query, @dbname
end
go



raiserror(15339,-1,-1,'sp_dumpparamcmd')
GO

create procedure sp_dumpparamcmd
@originator_id int,
@publisher_database_id int,
@article_id int,
@xact_seqno nchar(22)
as
declare @query nvarchar(2048)
declare @dbname sysname

select @query = N'select convert(int, partial_command) , command from MSrepl_commands '
select @query = @query + 'where type = 30 and xact_seqno = ' + @xact_seqno
select @query = @query + N' and originator_id = ' + convert( nvarchar, @originator_id )
select @query = @query + N' and publisher_database_id = ' + convert( nvarchar, @publisher_database_id )
select @query = @query + N' and article_id = ' + convert( nvarchar, @article_id )
select @query = @query + N' order by command_id asc'
select @dbname = db_name()

exec master..xp_displayparamstmt @query, @dbname, 1
go

raiserror(15339,-1,-1,'sp_MSbrowsesnapshotfolder')
GO

create procedure sp_MSbrowsesnapshotfolder (
    @publisher     sysname,
    @publisher_db  sysname,
    @article_id    int,
    @subscriber    sysname = NULL,
    @subscriber_db sysname = NULL
    )
AS
    SET NOCOUNT ON


    DECLARE @alt_directory_type     INT
    DECLARE @directory_type         INT
    DECLARE @publisher_id           INT
    DECLARE @publisher_database_id  INT
    DECLARE @subscriber_id          INT
    DECLARE @snapshot_bit           INT
    DECLARE @snapshot_mask          INT
    DECLARE @xact_seqno             VARBINARY(16)
    DECLARE @sync_init              INT
    DECLARE @sync_done              INT

    SELECT @alt_directory_type = 25
    SELECT @directory_type = 7
    SELECT @subscriber_id = NULL
    SELECT @snapshot_bit = 0x80000000
    SELECT @snapshot_mask = ~@snapshot_bit
    SELECT @xact_seqno = NULL
    SELECT @sync_init = 37
    SELECT @sync_done = 38

    SELECT @publisher_id = srvid 
      FROM master.dbo.sysservers 
     WHERE UPPER(@publisher) = UPPER(srvname)

    SELECT @publisher_database_id = publisher_database_id 
      FROM MSsubscriptions
     WHERE publisher_id = @publisher_id
       AND publisher_db = @publisher_db
       AND article_id = @article_id  


    -- @subscriber is null implies @subscriber_db is null also because 
    -- this sp can only be called by sp_browsesnapshotfolder
    IF @subscriber IS NULL
    BEGIN
        SELECT @xact_seqno = MAX(xact_seqno) 
          FROM MSrepl_commands
         WHERE publisher_database_id = @publisher_database_id
           AND article_id = @article_id
           AND (type & @snapshot_bit) <> 0            
           AND (type & @snapshot_mask) <> @sync_init
           AND (type & @snapshot_mask) <> @sync_done
    END
    ELSE 
    BEGIN
        -- Both @subscriber and @subscriber_db are non-null
        SELECT @subscriber_id = srvid 
          FROM master.dbo.sysservers
         WHERE UPPER(@subscriber) = UPPER(srvname)
        
        IF @subscriber_id IS NULL
        BEGIN
            RAISERROR(21150, 16, -1)  
            RETURN 1
        END
        
        SELECT @xact_seqno = subscription_seqno 
          FROM MSsubscriptions
         WHERE publisher_database_id = @publisher_database_id
           AND publisher_id = @publisher_id 
           AND article_id = @article_id
           AND subscriber_id = @subscriber_id
           AND subscriber_db = @subscriber_db

        IF @xact_seqno IS NULL
        BEGIN
            RAISERROR(14055, 16, -1)
            RETURN 1
        END                  
    END

    SELECT 'snapshot_folder' = CONVERT(NVARCHAR(255), command) 
      FROM MSrepl_commands 
     WHERE publisher_database_id = @publisher_database_id
       AND (type & @snapshot_bit) <> 0
       AND xact_seqno = @xact_seqno
       AND (((type & ~@snapshot_bit) = @alt_directory_type) OR
            ((type & ~@snapshot_bit) = @directory_type))
  ORDER BY command_id ASC
    IF @@ERROR <> 0
    BEGIN
        RETURN 1
    END
    ELSE
    BEGIN
        RETURN 0
    END
GO

raiserror(15339,-1,-1,'sp_MSchange_subscription_dts_info')
GO

CREATE PROCEDURE sp_MSdist_adjust_identity
	@agent_id	int,
	@tablename	sysname
as	
	declare @publisher sysname
	declare @publisher_db sysname
	declare @publisher_id smallint
	declare @publication sysname
	declare @next_seed bigint
	declare @range bigint
	declare @threshold int
	declare @retcode int

	-- Security check.
    exec @retcode = dbo.sp_MScheck_pull_access
        @agent_id = @agent_id,
        @agent_type = 0 -- distribution agent
    if @@error <> 0 or @retcode <> 0
        return (1)

	select @publication = publication, @publisher_id = publisher_id,
		@publisher_db = publisher_db from MSdistribution_agents where
		id = @agent_id

	select @publisher = srvname from master..sysservers where 
		srvid = @publisher_id
	-- Get the publication id.
	-- Note: auto identity range is only supported for queued tran pub
	-- which implies independent agent.
	declare @publication_id int
	select @publication_id = publication_id from MSpublications	where
		publication =  @publication and
		publisher_id = @publisher_id and
		publisher_db = @publisher_db

	-- Get the source object name
	declare @src_object sysname
	select @src_object = source_object from MSarticles where
		publication_id = @publication_id and
		destination_object = @tablename

	if @src_object is not null
	begin
		exec @retcode = dbo.sp_MSfetchAdjustidentityrange
			@publisher = @publisher,
			@publisher_db = @publisher_db,
			@tablename = @src_object,
			@adjust_only = 1,
			@for_publisher = 0,
			@next_seed = @next_seed output,
			@range = @range output,
			@threshold = @threshold output
		if @@error <> 0 or @retcode <> 0
			return 1
	end

	-- Return nothing if the table is not found in the table collection served by
	-- the distribution agent.
	select 'next_seed' = @next_seed, 'range' = @range, 'threshold' = @threshold
		where @next_seed is not null 
go			

raiserror(15339,-1,-1,'sp_MSdist_adjust_identity')
GO

CREATE PROCEDURE sp_MSchange_subscription_dts_info (
	@job_id varbinary(16),
    @dts_package_name sysname,
	@dts_package_password nvarchar(524),
	@dts_package_location int,
	@change_password bit

    ) AS

    /*
    ** Declarations.
    */
	declare @subscriber sysname
	declare @publisher sysname
	declare @subscriber_id smallint
	declare @publisher_id smallint

    /*
    ** Initializations.
    */
    SET NOCOUNT ON
    
	select @subscriber_id = subscriber_id, @publisher_id = publisher_id 
		from MSdistribution_agents where 
		job_id = @job_id
	
	select @subscriber = srvname from master..sysservers where srvid = @subscriber_id
	select @publisher = srvname from master..sysservers where srvid = @publisher_id

	declare @oledb_subscriber tinyint
	select @oledb_subscriber = 3
	
	-- Only SQL Server and OLEDB subscriber support dts
	if not exists (select * from MSsubscriber_info where 
		UPPER(publisher) = UPPER(@publisher) and 
		UPPER(subscriber) = UPPER(@subscriber) and
		(type = 0 or type = @oledb_subscriber))
	begin
		raiserror(21170, 16, -1)
		return 1
	end
	
	
	update MSdistribution_agents set
		dts_package_name = case 
			when @dts_package_name is null then dts_package_name
			when @dts_package_name = N'' then null
			else @dts_package_name
			end, 
		dts_package_password = case @change_password
			when 0 then dts_package_password
			else @dts_package_password
			end, 
		dts_package_location = case
			when @dts_package_location is null then dts_package_location
			else @dts_package_location
			end
		where
			job_id = @job_id

    RETURN (0)
go

raiserror(15339,-1,-1,'sp_MSrefresh_anonymous')
GO
CREATE PROCEDURE sp_MSrefresh_anonymous (
@publication			sysname,
@publisher				sysname,
@publisher_db			sysname
)AS

declare @retcode 		int
declare @publisher_id	int
declare @success		int
declare @agent_id		int

SELECT @publisher_id = NULL 
SELECT @publisher_id = srvid FROM master..sysservers WHERE UPPER(@publisher) = UPPER(srvname)  
IF @publisher_id IS NULL
    BEGIN
        RAISERROR(21169, 16, -1, @publisher, @@SERVERNAME, @publisher)    
        return (1)
    END
select @success = 2 --agent history status

select @agent_id = id from MSmerge_agents where 
	anonymous_subid is not NULL and --touch anonymous only
	publication like @publication and 
	publisher_id=@publisher_id and 
	publisher_db=@publisher_db

set rowcount 1
update MSmerge_history set time=getdate() where agent_id=@agent_id and runstatus=@success
if @@ERROR<>0
	return (1)
GO

raiserror(15339,-1,-1,'sp_MScheck_pub_identity')
GO
CREATE PROCEDURE sp_MScheck_pub_identity (
@publisher			sysname,
@publisher_db		sysname,
@tablename			sysname, 
@current_max		bigint  = NULL OUTPUT,
@pub_range			bigint  = NULL OUTPUT,
@threshold			int  = NULL OUTPUT,
@range				bigint  = NULL OUTPUT,
@next_seed			bigint  = NULL OUTPUT,
@max_identity		bigint = NULL OUTPUT
)AS

	declare @retcode		int

	if @current_max is not NULL
	begin
		select @current_max=current_max from MSrepl_identity_range 
			where tablename=@tablename and LOWER(publisher)=LOWER(@publisher) and publisher_db=@publisher_db
		if @@ERROR<>0	
			return (1)
	end

	if @max_identity is not NULL
	begin
		select @max_identity=max_identity from MSrepl_identity_range 
			where tablename=@tablename and LOWER(publisher)=LOWER(@publisher) and publisher_db=@publisher_db
		if @@ERROR<>0	
			return (1)
	end

	if @pub_range is not NULL
	begin
		select @pub_range=pub_range from MSrepl_identity_range 
			where tablename=@tablename and LOWER(publisher)=LOWER(@publisher) and publisher_db=@publisher_db
		if @@ERROR<>0	
			return (1)
	end

	if @threshold is not NULL
	begin
		select @threshold=threshold from MSrepl_identity_range 
			where tablename=@tablename and LOWER(publisher)=LOWER(@publisher) and publisher_db=@publisher_db
		if @@ERROR<>0	
			return (1)
	end
	if @next_seed is not NULL
	begin
		select @next_seed=next_seed from MSrepl_identity_range 
			where tablename=@tablename and LOWER(publisher)=LOWER(@publisher) and publisher_db=@publisher_db
		if @@ERROR<>0	
			return (1)
	end
	if @range is not NULL
	begin
		select @range=range from MSrepl_identity_range 
			where tablename=@tablename and LOWER(publisher)=LOWER(@publisher) and publisher_db=@publisher_db
		if @@ERROR<>0	
			return (1)
	end

return (0)
GO

raiserror(15339,-1,-1,'sp_MSadjust_pub_identity')
GO

CREATE PROCEDURE sp_MSadjust_pub_identity (
@publisher			sysname,
@publisher_db		sysname,
@tablename			sysname,
@current_max		int  = NULL,
@threshold			int  = NULL,
@range				int = NULL,
@next_seed			int  = NULL
)AS

	declare @retcode		int
	if @current_max is NOT NULL
	begin
		update MSrepl_identity_range set current_max=@current_max 
			where tablename=@tablename and LOWER(publisher)=LOWER(@publisher) and publisher_db=@publisher_db
		if @@ERROR<>0	
			return (1)
		if exists (select * from MSrepl_identity_range where max_identity is not NULL 
			and ABS(current_max) > ABS(max_identity))
		begin
			raiserror(21195, 16, -1)
			return (1)
		end
	end
	if @threshold is NOT NULL
	begin
	update MSrepl_identity_range set threshold=@threshold 
		where tablename=@tablename and LOWER(publisher)=LOWER(@publisher) and publisher_db=@publisher_db
	if @@ERROR<>0	
		return (1)
	end
	if @next_seed is NOT NULL
	begin
	update MSrepl_identity_range set next_seed=@next_seed 
		where tablename=@tablename and LOWER(publisher)=LOWER(@publisher) and publisher_db=@publisher_db
	if @@ERROR<>0
		return (1)
	end
	if @range is NOT NULL
	begin
	update MSrepl_identity_range set range=@range 
		where tablename=@tablename and LOWER(publisher)=LOWER(@publisher) and publisher_db=@publisher_db	
	if @@ERROR<>0
		return (1)
	end
return (0)
GO

raiserror(15339,-1,-1,'sp_MSinsert_identity')
GO

CREATE PROCEDURE sp_MSinsert_identity (
	@publisher 			sysname,
	@publisher_db 		sysname,
	@tablename 			sysname,
	@identity_support	int,
	@pub_identity_range bigint,
	@identity_range 	bigint,
	@threshold 			int,
	@next_seed			bigint,
	@max_identity		bigint
    ) AS
    
	declare @pub_seed 		bigint	
	declare @current_max 	bigint
	if not exists (select * from MSrepl_identity_range 
			where tablename=@tablename and LOWER(publisher)=LOWER(@publisher) and publisher_db=@publisher_db)
	begin
		select @pub_seed = @pub_identity_range + @next_seed
		select @current_max = @pub_seed - 1
		insert MSrepl_identity_range(publisher, publisher_db, tablename, identity_support, next_seed, pub_range, range, max_identity, threshold, current_max	)
				values (@publisher, @publisher_db, @tablename, @identity_support, @pub_seed,  @pub_identity_range, @identity_range, @max_identity, @threshold, @current_max)
		if @@ERROR<>0
			return 1
	end
	else if 1 > 1 --disable this segment for now.
		begin --adjust republisher's resource table
			select @pub_seed = @pub_identity_range - 1
			/* update range, threshold at republisher as needed. Max and next_seed has been set already. */
			update MSrepl_identity_range set	range = @identity_range,
												pub_range = @pub_identity_range,
												threshold=@threshold, 
												next_seed=next_seed + @pub_identity_range,
												current_max=next_seed + @pub_seed --new next_seed not yet picked up
			where tablename=@tablename and LOWER(publisher)=LOWER(@publisher) and publisher_db=@publisher_db
			if @@ERROR<>0
				return (1)
		end
GO

raiserror(15339,-1,-1,'sp_MSget_subscription_dts_info')
GO

CREATE PROCEDURE sp_MSget_subscription_dts_info (
	@job_id varbinary(16)

    ) AS

    /*
    ** Declarations.
    */

    /*
    ** Initializations.
    */
    SET NOCOUNT ON

	select dts_package_name, dts_package_location 
		from MSdistribution_agents where
        job_id = @job_id

    RETURN (0)
go

raiserror(15339, -1, -1, 'sp_MSenumdistributionagentproperties')
GO

CREATE PROCEDURE sp_MSenumdistributionagentproperties (
    @publisher        sysname,
    @publisher_db     sysname,
    @publication      sysname
    ) AS
    DECLARE @independent_agent bit 
    DECLARE @publisher_id int  -- Server id of the Publisher with respect to the Distributor
   
    SELECT @publisher_id = NULL 
    SELECT @publisher_id = srvid 
      FROM master..sysservers
     WHERE UPPER(@publisher) = UPPER(srvname)  
    
    IF @publisher_id IS NULL
    BEGIN
        RAISERROR(21169, 16, -1, @publisher, @@SERVERNAME, @publisher)    
    END

    IF @publication <> '%' -- A publication name is specified 
    BEGIN
        -- Determine whether the given publication shares an 
        -- agent with other publicaitons in the same database
        -- or not
        SELECT @independent_agent = 0
        SELECT @independent_agent = independent_agent 
          FROM MSpublications
         WHERE publisher_id = @publisher_id
           AND publisher_db = @publisher_db
           AND publication = @publication  
        
        IF @independent_agent IS NULL
        BEGIN
            RAISERROR(20026, 16, -1)
        END

        IF @independent_agent = 0 
        BEGIN
            -- If the publication shares an agent with 
            -- other publications, change the publication
            -- name to 'ALL' before querying the MSdistribution_agents
            -- table
            SELECT @publication = N'ALL'                
        END

        SELECT job_id, offload_enabled, offload_server, 
               dts_package_name, dts_package_location,
			   -- status of this agent, only useful in detecting
			   -- whether or not the agent has be deactivated by cleanup
			   -- If so, all the rows in MSsubscriptions will be 0
			   (select top 1 s.status from MSsubscriptions s where
					s.agent_id = a.id)
          FROM MSdistribution_agents a
         WHERE a.publisher_id = @publisher_id 
           AND a.publisher_db = @publisher_db
           AND a.publication = @publication
    END
    ELSE
    BEGIN
        SELECT job_id, offload_enabled, offload_server, 
               dts_package_name, dts_package_location,
			   -- status of this agent, only useful in detecting
			   -- whether or not the agent has be deactivated by cleanup
			   -- If so, all the rows in MSsubscriptions will be 0
			   (select top 1 s.status from MSsubscriptions s where
					s.agent_id = a.id)
          FROM MSdistribution_agents a
         WHERE a.publisher_id = @publisher_id 
           AND a.publisher_db = @publisher_db
    END
GO
    
raiserror(15339, -1, -1, 'sp_MSenum_merge_agent_properties')
GO
CREATE PROCEDURE sp_MSenum_merge_agent_properties (
    @publisher        sysname,
    @publisher_db     sysname,
    @publication      sysname
    ) AS
    
    DECLARE @publisher_id int  -- Server id of the Publisher with respect to the Distributor
    declare @publication_id int
    declare @retcode int

    SELECT @publisher_id = NULL 
    SELECT @publisher_id = srvid 
      FROM master..sysservers
     WHERE UPPER(@publisher) = UPPER(srvname)  

    IF @publisher_id IS  NULL
    BEGIN
        RAISERROR(21169, 16, -1, @publisher, @@SERVERNAME, @publisher)    
    END

    select @publication_id = publication_id from 
        MSpublications where 
        publisher_id = @publisher_id and
        publisher_db = @publisher_db and
        publication = @publication
    if @publication_id is NULL
    begin
        raiserror (20026, 11, -1, @publication)
        return (1)
    end
    
    exec @retcode = dbo.sp_MScheck_pull_access
        @agent_type = 1, -- merge agent
        @publication_id = @publication_id
    if @@error <> 0 or @retcode <> 0
	begin    
		RAISERROR (15247, 11, -1)
		return (1)
	end

    SELECT job_id, offload_enabled, offload_server 
      FROM MSmerge_agents
     WHERE publisher_id = @publisher_id 
       AND publisher_db = @publisher_db
       AND (@publication = N'%' OR publication = @publication)
GO

raiserror(15339, -1, -1, 'sp_dropanonymoussubscription')
GO
CREATE PROCEDURE sp_dropanonymoussubscription
@agent_id int,
@type int -- 1 tran sub, 2 merge sub
as
	declare @retcode int
	if @type not in (1,2)
	begin
		raiserror(20587, 16, -1, '@type', 'sp_dropanonymoussubscription')
		return (1)
	end
	-- If tran
	if @type = 1
	begin
		if not exists (select * from MSdistribution_agents where
			id = @agent_id and
			subscriber_name is not null)
		begin
			RAISERROR (14055, 11, -1)
			return(1)
		end
		exec @retcode = dbo.sp_MSdrop_distribution_agentid @agent_id
		if @retcode <> 0 or @@error <> 0
			return 1
	end
	else
	begin
		if not exists (select * from MSmerge_agents where
			id = @agent_id and
			subscriber_name is not null)
		begin
			RAISERROR (14055, 11, -1)
			return(1)
		end
		exec @retcode = dbo.sp_MSdrop_merge_agentid @agent_id
		if @retcode <> 0 or @@error <> 0
			return 1
	end
go

raiserror(15339, -1, -1, 'sp_MSdrop_anonymous_entry')
GO
CREATE PROCEDURE sp_MSdrop_anonymous_entry
@subid uniqueidentifier,
@login sysname,
@type int -- 1 tran sub, 2 merge sub
as
	declare @sid varbinary(85)
	declare @agent_id int, @retcode int
	set nocount on 
	if @type not in (1,2)
	begin
		raiserror(20587, 16, -1, '@type', 'sp_MSdrop_anonymous_entry')
		return (1)
	end
	-- If tran
	if @type = 1
	begin
		select @sid = sid from MSdistribution_agents where
			anonymous_subid = @subid
	end
	else
	begin
		select @sid = sid from MSmerge_agents where
			anonymous_subid = @subid
	end
	if @sid is null
	begin
		RAISERROR (14055, 11, -1)
		return(1)
	end
	-- null login means no security check needed
	if @login is not null and suser_sid(@login) <> @sid
	begin
		set @login = suser_sname(@sid)
		RAISERROR (20596, 11, -1, @login)
		RETURN (1)
	end

	if @type = 1
	begin
		select @agent_id = id from MSdistribution_agents where anonymous_subid = @subid
		if @agent_id is not null
		begin
			exec @retcode = dbo.sp_MSdrop_distribution_agentid @agent_id
			if @retcode <> 0 or @@error <> 0
				return 1
		end
	end
	else
	begin
		select @agent_id = id from MSmerge_agents where anonymous_subid = @subid
		if @agent_id is not null
		begin
			exec @retcode = dbo.sp_MSdrop_merge_agentid @agent_id
			if @retcode <> 0 or @@error <> 0
				return 1
		end
	end
go

raiserror(15339, -1, -1, 'sp_MSadddynamicsnapshotjobatdistributor')
go
--
-- Name: sp_MSadddynamicsnapshotjobatdistributor
--
-- Description: This function is called by sp_MSaddmergedynamicsnapshotjob 
--              at the publisher to set up a dynamic snapshot job in msdb
--              at the distributor. 
-- Notes: This procedure will only perform implicit checking for scheduling 
--        parameters as most parameters are expected to have been checked 
--        in sp_MSaddmergedynamicsnapshotjob
--
-- Parameters: @regular_snapshot_jobid uniqueidentifier (mandatory)
--             @dynamic_filter_login sysname (optional, default null)
--             @dynamic_filter_hostname sysname (optional, default null)
--             @dynamic_snapshot_location nvarchar(255) (mandatory)
--             @dynamic_snapshot_jobid uniqueidentifier (mandatory)
--             Scheduling information:
--             @freqtype int (optional, default 4 == Daily)
--             @freqinterval int (optional, default 1 == Every day)
--             @freqsubtype int (optional, default 4 (Sub interval = Minute))
--             @freqsubinterval int (optional, default 5 == Every five minutes)
--             @freqrelativeinterval int (optional, default 1) 
--             @freqrecurrencefactor int (optional, default 0) 
--             @activestartdate int (optional, default 0 == Today)
--             @activeenddate int (optional, default 99991231) 
--             @activestarttimeofday int (optional, default 0 == Now)        
--             @activeendtimeofday int (optional, default 235959)
--
-- Returns: 0 - succeeded
--          1 - failed
--
-- Security: Only members of the 'sysadmin' server role and members of the 
--           'db_owner' database role at the distributor can call this 
--           procedure. This procedure is intended to be called through 
--           the distributor_admin remote login in the case where
--           the distributor is a different machine from the publisher. 
--
create procedure sp_MSadddynamicsnapshotjobatdistributor (
    @regular_snapshot_jobid uniqueidentifier,
    @dynamic_filter_login sysname = null,
    @dynamic_filter_hostname sysname = null,
    @dynamic_snapshot_location nvarchar(255),
    @dynamic_snapshot_jobname sysname output,
    @dynamic_snapshot_jobid uniqueidentifier output,

    -- Scheduling information
    @freqtype               int = 4,
    @freqinterval           int = 1,
    @freqsubtype            int = 4,
    @freqsubinterval        int = 5,
    @freqrelativeinterval   int = 1, 
    @freqrecurrencefactor   int = 0,
    @activestartdate        int = 0,
    @activeenddate          int = 99991231,
    @activestarttimeofday   int = 0, 
    @activeendtimeofday     int = 235959
    )
as
begin
    set nocount on

    declare @retcode int
    declare @agent_command_line nvarchar(4000)
    declare @agent_id int
    declare @db_name sysname    
    declare @category_name sysname
    declare @nullchar nchar(20)

    declare @dynamicfilterloginparam nvarchar(50)
    declare @dynamicfilterhostnameparam nvarchar(50)
    declare @dynamicsnapshotlocationparam nvarchar(50)
    
    select @retcode = 0
    select @agent_command_line = null
    select @agent_id = null
    select @db_name = db_name()
    select @category_name = name 
      from msdb.dbo.syscategories 
     where category_id = 15
    select @nullchar = null

    select @dynamicfilterloginparam = N' -DynamicFilterLogin '
    select @dynamicfilterhostnameparam = N' -DynamicFilterHostName '
    select @dynamicsnapshotlocationparam = N' -DynamicSnapshotLocation '

    -- Get the regular snapshot agent command line
    select @agent_command_line = command 
      from msdb..sysjobsteps
     where job_id = @regular_snapshot_jobid
       and subsystem = N'Snapshot'
       and step_id = 2
        
    if @agent_command_line is null
    begin
        raiserror(21319, 11, -1)        
        return 1        
    end  
    
    -- Get the agent id    
    select @agent_id = id
      from MSsnapshot_agents
     where job_id = @regular_snapshot_jobid

    if @agent_id is null
    begin
        raiserror(21325, 11, -1)
        return 1
    end

    if @dynamic_snapshot_jobname is null or @dynamic_snapshot_jobname = N''
    begin
        -- Get the job name of the regular snapshot job. This is going to be used
        -- to derive a uniquefied job name for the dynamic snapshot job
        select @dynamic_snapshot_jobname = name 
          from msdb..sysjobs 
         where job_id = @regular_snapshot_jobid
    
        select @dynamic_snapshot_jobname = N'dyn_' + left(@dynamic_snapshot_jobname,88) + convert(nvarchar(36), newid()) 
    end

    if @dynamic_filter_login is not null and @dynamic_filter_login <> N''
    begin
        select @agent_command_line = @agent_command_line + @dynamicfilterloginparam + N'[' + rtrim(@dynamic_filter_login) + N']' 
    end

    if @dynamic_filter_hostname is not null and @dynamic_filter_hostname <> N''
    begin
        select @agent_command_line = @agent_command_line + @dynamicfilterhostnameparam + N'[' + rtrim(@dynamic_filter_hostname) + N']' 
    end

    -- @dynamic_snapshot_location is assumed to be non-empty
    select @agent_command_line = @agent_command_line + @dynamicsnapshotlocationparam + N'[' + @dynamic_snapshot_location + N']'

    -- Add the job
    exec @retcode = dbo.sp_MSadd_repl_job
         @name = @dynamic_snapshot_jobname,
         @subsystem = 'Snapshot',
         @server = @@servername,
         @databasename = @db_name,
         @enabled = 1,
         @freqtype = @freqtype,
         @freqinterval = @freqinterval,
         @freqsubtype = @freqsubtype,
         @freqsubinterval = @freqsubinterval,
         @freqrecurrencefactor = @freqrecurrencefactor,
         @activestartdate = @activestartdate,
         @activeenddate = @activeenddate,
         @activestarttimeofday = @activestarttimeofday,
         @activeendtimeofday = @activeendtimeofday,
         @nextrundate = 0,
         @nextruntime = 0,
         @runpriority = 0,
         @emailoperatorname = @nullchar,
         @retryattempts = 10,
         @retrydelay = 1,
         @command = @agent_command_line,
         @loghistcompletionlevel = 0,
         @emailcompletionlevel = 0,
         @description = @nullchar,
         @tagobjectid = 0,
         @tagobjecttype = 0,
         @category_name = @category_name,
         @failure_detection = 1,
         @agent_id = @agent_id,
         @job_id = @dynamic_snapshot_jobid output            

    return @retcode
end
go

raiserror(15339, -1, -1, 'sp_MSdeleterepljob')
go
--
-- Name: sp_MSdeleterepljob
--
-- Description: This is a lightweight wrapper of sp_delete_job to be used
--              by remote publishers.
--
-- Parameter: @job_id uniqueidentifier (mandatory)
--
-- Returns 0 - succeeded
--         1 - failed
-- 
-- Security: Only members of the sysadmin server role and members of the 
-- db_owner role of the distribution database can execute this function. This
-- procedure is intended to be called through the distribution_admin remote 
-- login from remote publishers
--
create procedure sp_MSdeleterepljob (
    @job_id uniqueidentifier
    )
as
begin
    set nocount on
    declare @retcode int
    declare @job_name sysname 

    select @retcode = 0
    exec @retcode = msdb..sp_delete_job @job_id = @job_id

    return @retcode
end
go

raiserror(15339, -1, -1, 'sp_MSdeletefoldercontents')
go
--
-- Name: sp_MSdeletefoldercontents
--
-- Description: This is a lighweight wrapper for deleting all files in the
--              specified directory. This procedure is meant to be called by 
--              a remote publisher for deleting files in the distributor's 
--              context.
--
-- Parameter: @folder nvarchar(255) (mandatory)
--
-- Returns 0 - succeeded
--         1 - failed
--
-- Security: Only members of the sysadmin server role and members of the 
-- db_owner role of the distribution database can execute this function. This
-- procedure is intended to be called through the distribution_admin remote 
-- login from remote publishers
--
create procedure sp_MSdeletefoldercontents (
    @folder nvarchar(255)
    )
as
begin
    set nocount on

    declare @command_prefix nvarchar(4000)
    declare @command nvarchar(4000)
    declare @retcode int

    select @retcode = 0
    if len(@folder) = 0 or @folder is null
    begin
        return 0
    end

    -- \ terminate path
    if substring(@folder, len(@folder), 1) <> N'\'
    begin
        select @folder = @folder + N'\'
    end 

    if (platform() & 0x1) = 0x1 
    begin
        select @command_prefix = 'del /q /f "' + fn_escapecmdshellsymbolsremovequotes(@folder) collate database_default
    end
    else
    begin
        -- Win9x 'del' command does not support the /q and /f switches
        select @command_prefix = 'del "' + fn_escapecmdshellsymbolsremovequotes(@folder) collate database_default
    end

    -- Hardwired merge system table files without embedded _
    set @command = @command_prefix + N'sysmergesubsetfilters*.sch"'
    exec @retcode = master..xp_cmdshell @command, no_output

    set @command = @command_prefix + N'sysmergesubsetfilters*.bcp"'
    exec @retcode = master..xp_cmdshell @command, no_output
    
    -- .sch extensio
    set @command = @command_prefix + N'*_*.sch"'
    exec @retcode = master..xp_cmdshell @command, no_output

    -- .bcp extension
    set @command = @command_prefix + N'*_*.bcp"'
    exec @retcode = master..xp_cmdshell @command, no_output

    -- .idx extension
    set @command = @command_prefix + N'*_*.idx"'
    exec @retcode = master..xp_cmdshell @command, no_output

    -- .sql extension
    set @command = @command_prefix + N'*_*.sql"'
    exec @retcode = master..xp_cmdshell @command, no_output

    -- snapshot.cab
    set @command = @command_prefix + N'snapshot.cab"'
    exec @retcode = master..xp_cmdshell @command, no_output

    -- .pre extension
    set @command = @command_prefix + N'snapshot.pre"'
    exec @retcode = master..xp_cmdshell @command, no_output

    -- .trg extension
    set @command = @command_prefix + N'*_*.trg"'
    exec @retcode = master..xp_cmdshell @command, no_output

    -- .xpp extension
    set @command = @command_prefix + N'*_*.xpp"'
    exec @retcode = master..xp_cmdshell @command, no_output

    -- .cft extension
    set @command = @command_prefix + N'*_*.cft"'
    exec @retcode = master..xp_cmdshell @command, no_output

    -- .dri extension
    set @command = @command_prefix + N'*_*.dri"'
    exec @retcode = master..xp_cmdshell @command, no_output

Failure:

    return @retcode

end
go

CREATE PROCEDURE sp_MSinvalidate_snapshot
@publisher sysname,
@publisher_db sysname,
@publication sysname

as
    set nocount on
    declare @publisher_id smallint  
    declare @automatic tinyint
    declare @virtual smallint 
    declare @retcode int
    declare @active tinyint
		, @initiated tinyint
		, @subscribed tinyint
    declare @publication_id int

    select @automatic = 1
    select @virtual = - 1
    select @active = 2
		, @initiated = 3
		, @subscribed = 1

    -- Check if publisher is a defined as a distribution publisher in the current database
    exec @retcode = dbo.sp_MSvalidate_distpublisher @publisher, @publisher_id OUTPUT
    if @retcode <> 0
    begin
        return(1)
    end

    -- Make sure publication exists
    select @publication_id = publication_id
        from MSpublications where publication = @publication and
        publisher_id = @publisher_id and publisher_db = @publisher_db

	-- Set the virtual subscription status to be 'subscribed' so that
	-- new subscription will wait for the next snapshot.
	update MSsubscriptions set status = @subscribed where 
		publication_id = @publication_id and
		sync_type = @automatic and
		status in (@active, @initiated) and
		subscriber_id = @virtual

	return (0)
GO

create procedure sp_MSrepl_init_backup_lsns
as
	-- The stored procedure is called by sp_replicationoption when changing a dist
	-- db to 'sync with backup' mode
	set nocount on
	
	-- Set the truncate lsns to null. By doing this
	-- the distribution agent will stop calling sp_repldone untill a dist db
	-- backup is done.
	update MSrepl_backup_lsns set valid_xact_seqno = NULL,
		valid_xact_id = NULL
	if @@error <> 0
		return 1
	return 0
go

--
-- Name: sp_MSispublicationqueued
--
-- Description: This procedure is invoked by sp_MShelp_replication_status 
--				to find out if the specified publication supports queued
--				updating subscribers. 
--
-- Parameter: 
--				@publisher sysname (mandatory)
--				@publisher_db sysname (mandatory)
--				@publication sysname (mandatory)
--				@allow_queued_tran bit OUTPUT (mandatory)
--
-- Returns 0 - succeeded
--         1 - failed
--
-- Security: Only members of the sysadmin server role and members of the 
-- db_owner role of the distribution database can execute this function.
--
raiserror(15339,-1,-1,'sp_MSispublicationqueued')
go
create procedure sp_MSispublicationqueued (
	@publisher sysname
	,@publisher_db sysname
	,@publication sysname
	,@allow_queued_tran bit OUTPUT
	)
as
begin
	--
	-- get the queued tran state for the publication
	--
	if exists (select * from dbo.sysobjects where name = N'MSpublications')
	begin
		select @allow_queued_tran = pub.allow_queued_tran 
		from (dbo.MSpublications as pub join master.dbo.sysservers as srv
				on pub.publisher_id = srv.srvid)
		where UPPER(srv.srvname) = UPPER(@publisher)
			and pub.publisher_db = @publisher_db
			and pub.publication = @publication
	end
	else
		select @allow_queued_tran = 0

	--
	-- all done
	--
	return 0
end
go

raiserror(15339,-1,-1,'sp_MSlog_agent_cancel')
go
create procedure sp_MSlog_agent_cancel
@job_id binary(16),
@category_id int,
@message nvarchar(1024)
as
	-- This stored procedure is called by msdb proc, sp_sqlagent_log_jobhistory to
	-- log a agent cancel message to repl monitor (agent history tables) when the
	-- agent fails to log a complete message to repl monitor directly. 
	-- sp_MSdetect_nonlogged_shutdown would not help in this case, because that step
	-- will not be executed because the job is canceled before the step.
	declare @agent_id int

    if @category_id = 15
    begin
		-- Get agent_id
        select @agent_id = id from MSsnapshot_agents where job_id = @job_id
        if exists (select runstatus from MSsnapshot_history where 
            agent_id = @agent_id and
            runstatus <> 2 and 
			runstatus <> 5 and 
            runstatus <> 6 and
            timestamp = (select max(timestamp) from MSsnapshot_history where agent_id = @agent_id))
        begin
			-- Log success message.
			exec dbo.sp_MSadd_snapshot_history @agent_id = @agent_id, @runstatus = 2,
					@comments = @message
        end
    end
    else if @category_id = 13
    begin
		-- Get agent_id
        select @agent_id = id from MSlogreader_agents where job_id = @job_id
        if exists (select runstatus from MSlogreader_history where 
            agent_id = @agent_id and
            runstatus <> 2 and 
			runstatus <> 5 and 
            runstatus <> 6 and
            timestamp = (select max(timestamp) from MSlogreader_history where agent_id = @agent_id))
            begin
				-- Log success message.
				exec dbo.sp_MSadd_logreader_history @agent_id = @agent_id, @runstatus = 2,
						@comments = @message
            end
    end
    else if @category_id = 10
    begin
		-- Get agent_id
        select @agent_id = id from MSdistribution_agents where job_id = @job_id
        if exists (select runstatus from MSdistribution_history where 
            agent_id = @agent_id and
            runstatus <> 2 and 
			runstatus <> 5 and 
            runstatus <> 6 and
            timestamp = (select max(timestamp) from MSdistribution_history where agent_id = @agent_id))
            begin
				-- Log success message.
				exec dbo.sp_MSadd_distribution_history @agent_id = @agent_id, @runstatus = 2,
						@comments = @message
            end
    end
    else if @category_id = 14
    begin
		-- Get agent_id
        select @agent_id = id from MSmerge_agents where job_id = @job_id
        if exists (select runstatus from MSmerge_history where 
            agent_id = @agent_id and
            runstatus <> 2 and 
			runstatus <> 5 and 
            runstatus <> 6 and
            timestamp = (select max(timestamp) from MSmerge_history where agent_id = @agent_id))
            begin
				-- Log success message.
				exec dbo.sp_MSadd_merge_history @agent_id = @agent_id, @runstatus = 2,
						@comments = @message
            end
    end
    else if @category_id = 19
    begin
		-- Get agent_id
        select @agent_id = id from MSqreader_agents where job_id = @job_id
        if exists (select runstatus from MSqreader_history where 
            agent_id = @agent_id and
            runstatus <> 2 and 
			runstatus <> 5 and 
            runstatus <> 6 and
            timestamp = (select max(timestamp) from MSqreader_history where agent_id = @agent_id))
            begin
				-- Log success message.
				exec dbo.sp_MSadd_qreader_history @agent_id = @agent_id, @runstatus = 2,
						@comments = @message
            end
    end

GO

create procedure sp_MSwritemergeperfcounter (
	@agent_id int,
	@thread_num int,
	@counter_desc nvarchar(100),
	@counter_value int
	)
AS
    -- only sysadmin or db_owner have access to call this function
    if is_member('db_owner') <> 1
        return 1
        
	if (not exists (select * from sysobjects where name = 'MSmerge_perfcounters'))
	begin
		create table MSmerge_perfcounters
		(
			agent_id int NOT NULL,
			thread_num int NULL,
			counter_desc nvarchar(100) NOT NULL,
			counter_value int NOT NULL,
			cur_time datetime NOT NULL
		)
	end

	insert into MSmerge_perfcounters values (@agent_id, @thread_num, @counter_desc, @counter_value, getdate())

	return 0
go
EXEC dbo.sp_MS_marksystemobject 'sp_MSwritemergeperfcounter'
go
grant execute on sp_MSwritemergeperfcounter to public
go


create procedure sp_MSgetlasthistorytimestamp(
    @publisher     sysname,
    @publisher_db  sysname,
    @publication   sysname,
    @subscriber    sysname = NULL,
    @subscriber_db sysname = NULL,
    @last_history_logged datetime = NULL OUTPUT
	)
AS
	declare @agent_id int
   	declare @publisher_id int
   	declare @subscriber_id int
   	declare @last_status int
   	
	select @publisher_id = srvid from master..sysservers where
		UPPER(srvname) = UPPER(@publisher)

	select @subscriber_id = srvid from master..sysservers where
		UPPER(srvname) = UPPER(@subscriber)

    select @agent_id = id from MSmerge_agents 
        where publisher_id = @publisher_id and 
        	publisher_db = @publisher_db and 
        	subscriber_id = @subscriber_id and
        	subscriber_db = @subscriber_db 
        	and publication = @publication
	
	select Top 1 @last_status = runstatus, @last_history_logged = time from MSmerge_history where agent_id = @agent_id
    			order by time DESC
    --failures and in-progress messages do not count, if there were previous successes.			
    if (@last_status = 6 or @last_status = 3) and EXISTS (select * from MSmerge_history where agent_id = @agent_id and runstatus = 2) 
    	select Top 1 @last_history_logged = time from MSmerge_history where agent_id = @agent_id and runstatus = 2
    		order by time DESC	
	if @last_history_logged IS NULL
		return 1
	else
		return 0

go

EXEC dbo.sp_MS_marksystemobject 'sp_MSgetlasthistorytimestamp'
go
grant execute on sp_MSgetlasthistorytimestamp to public
go

/****************************************************************************/
print ''
print 'Adding user ''guest''.'
print ''
/****************************************************************************/
if not exists (select * from sysusers where
	name = N'guest' and
	hasdbaccess = 1)
	EXEC  dbo.sp_adduser 'guest'

/****************************************************************************/
print ''
print 'Adding role ''replmonitor''.'
print ''
/****************************************************************************/
if not exists (select * from sysusers where
	name = N'replmonitor' and
	issqlrole = 1)
	EXEC  dbo.sp_addrole 'replmonitor'


grant execute on dbo.sp_MSdistribution_counters to public
GO 
grant execute on dbo.sp_MShelp_profile to public
GO
grant execute on dbo.sp_MShelp_subscriber_info to public
GO

-- Stored procedures used by dist and merge agents. They are granted to public

grant execute on dbo.sp_MSmarkreinit to public
go

-- Procedures to retrieve actual data. Need security check inside
grant execute on dbo.sp_MSget_repl_commands to public
GO
grant execute on dbo.sp_MSget_repl_cmds_anonymous to public
GO

-- Procedures to modify meta data. Need security check inside.
grant execute on dbo.sp_MSadd_distribution_history to public
grant execute on dbo.sp_MSadd_repl_error to public
grant execute on dbo.sp_MSadd_repl_alert to public
grant execute on dbo.sp_MSadd_replmergealert to public
grant execute on dbo.sp_MSadd_merge_history to public
grant execute on dbo.sp_MSadd_anonymous_agent to public
grant execute on dbo.sp_MSadd_merge_anonymous_agent to public
grant execute on dbo.sp_MSdist_adjust_identity to public
GO

-- Procedures to retrieve meta data. No security check inside.
grant execute on dbo.sp_MSget_subscription_guid to public
grant execute on dbo.sp_MSreset_subscription_seqno to public
grant execute on dbo.sp_MSanonymous_status to public
grant execute on dbo.sp_MSsubscription_status to public
grant execute on dbo.sp_MShelp_merge_agentid to public
grant execute on dbo.sp_MShelp_distribution_agentid to public
grant execute on dbo.sp_MScheck_tran_retention to public
grant execute on dbo.sp_MSenum_merge_agent_properties to public
grant execute on dbo.sp_MSrepl_raiserror to public
-- sp_MShelp_publication is used by the distribution control add anonymous
-- subscription logic to ascertain the existence of a publication 
grant execute on dbo.sp_MShelp_publication to public
-- sp_MSenum_replication_status to load repl monitor status table
-- The status table is global and shared by all users. A user in
-- replmonitor role in any dist db may load the table, the proc
-- has to be granted to public.
grant execute on sp_MSenum_replication_status to public
go

-- grant monitoring sps to replmonitor
-- GRANT exec on sp_MShelp_publication to replmonitor 
GRANT exec on sp_MSenum_subscriptions to replmonitor 
GRANT exec on sp_MSIfExistsSubscription to replmonitor 
GRANT exec on sp_MSenum_merge_subscriptions to replmonitor 
GRANT exec on sp_MSenum_distribution to replmonitor 
GRANT exec on sp_MSenum_merge to replmonitor 
GRANT exec on sp_MSenum_snapshot to replmonitor 
GRANT exec on sp_MSenum_logreader to replmonitor
GRANT exec on sp_MSenum_qreader to replmonitor 
GRANT exec on sp_MSenum_snapshot_s to replmonitor 
GRANT exec on sp_MSenum_logreader_s to replmonitor
GRANT exec on sp_MSenum_distribution_s to replmonitor
GRANT exec on sp_MSenum_merge_s to replmonitor 
GRANT exec on sp_MSenum_qreader_s to replmonitor 
GRANT exec on sp_MSenum_snapshot_sd to replmonitor 
GRANT exec on sp_MSenum_logreader_sd to replmonitor
GRANT exec on sp_MSenum_distribution_sd to replmonitor
GRANT exec on sp_MSenum_merge_sd to replmonitor
GRANT exec on sp_MSenum_qreader_sd to replmonitor
GRANT exec on sp_MSget_repl_error to replmonitor
go


declare @dbname sysname
select  @dbname = db_name()
execute('dump transaction ' +@dbname+ ' with no_log')
go
checkpoint

go

exec dbo.sp_MS_upd_sysobj_category 2  --Now do catalog updates.

go

EXEC dbo.sp_configure 'allow updates', 0
GO

reconfigure with override
GO
-- - ----
