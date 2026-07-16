/*
** repltran.sql            1997/02/12 22:03
**
**
** Copyright Microsoft, Inc. 1998-2000
** All Rights Reserved.
*/


use master
go

dump tran master with no_log
go

exec dbo.sp_configure 'update',1
go
reconfigure with override
go

set ANSI_NULLS off
go

-- sp_MS_upd_sysobj_category is obsolete, use sp_MS_marksystemobject instead
-- exec dbo.sp_MS_upd_sysobj_category 1 --Capture time for use at the end
-- go

if exists (select * from sysobjects
    where type = 'P '
            and name = 'sp_MSdrop_repltran')
begin
    drop procedure sp_MSdrop_repltran
end

/*
** Create stored procedures to drop the stored procedures
** created by this script
*/
 

print ''
print 'Creating procedure sp_MSdrop_repl_tran.'
go
create procedure sp_MSdrop_repltran
as

    if exists( select * from sysobjects 
        where type = 'P '
            and name = 'sp_MSsetfilterparent' )
        drop procedure sp_MSsetfilterparent

    if exists( select * from sysobjects 
        where type = 'P '
            and name = 'sp_MSdoesfilterhaveparent' )
        drop procedure sp_MSdoesfilterhaveparent

    if exists( select * from sysobjects 
        where type = 'P '
            and name = 'sp_MSsetfilteredstatus' )
        drop procedure sp_MSsetfilteredstatus

    if exists ( select * from sysobjects 
        where type = 'P '
            and name = 'sp_MSreplsup_table_has_pk' )
        DROP PROC sp_MSreplsup_table_has_pk

    if exists (select * from sysobjects
        where type = 'P '
                and name = 'sp_MScreate_pub_tables')
        drop procedure sp_MScreate_pub_tables

    if exists (select * from sysobjects
        where type = 'P '
                and name = 'sp_MSdrop_expired_subscription')
        drop procedure sp_MSdrop_expired_subscription
    
    if exists (select * from sysobjects
            where type = 'P '
                and name = 'sp_replsync')
        drop procedure sp_replsync

    if exists (select * from sysobjects
            where type = 'P '
                and name = 'sp_enumfullsubscribers')
        drop procedure sp_enumfullsubscribers
    
    if exists (select * from sysobjects
        where type = 'P '
                and name = 'sp_MSaddexecarticle')
        drop procedure sp_MSaddexecarticle
    

    dump tran master with no_log
    

    if exists (select * from sysobjects
            where type = 'P '
                and name = 'sp_addarticle')
        drop procedure sp_addarticle
    
    if exists (select * from sysobjects
            where type = 'P '
                and name = 'sp_MSaddschemaarticle')
        drop procedure sp_MSaddschemaarticle

    if exists (select * from sysobjects
            where type = 'P '
                and name = 'sp_MSchangeschemaarticle')
        drop procedure sp_MSchangeschemaarticle

    if exists (select * from sysobjects
            where type = 'P '
                and name = 'sp_MSgettranconflictname')
        drop procedure sp_MSgettranconflictname    

    if exists (select * from sysobjects
            where type = 'P '
                and name = 'sp_MSretrieve_publication')
        drop procedure sp_MSretrieve_publication    

    if exists (select * from sysobjects
            where type = 'P '
                and name = 'sp_MSmaketrancftproc')
        drop procedure sp_MSmaketrancftproc    

    if exists (select * from sysobjects
        where type = 'P '
                and name = 'sp_articlecolumn')
        drop procedure sp_articlecolumn
    
    dump tran master with no_log
    

    if exists (select * from sysobjects
            where type = 'P '
                and name = 'sp_articlefilter')
        drop procedure sp_articlefilter
       


    if exists (select * from sysobjects
        where type = 'P '
                and name = 'sp_MSarticlecol')
        drop procedure sp_MSarticlecol
    

    dump tran master with no_log
    

    if exists (select * from sysobjects
        where type = 'P '
                and name = 'sp_MSarticlecolstatus')
        drop procedure sp_MSarticlecolstatus
    
    if exists (select * from sysobjects
            where type = 'P '
                and name = 'sp_MSscript_article_view')
        drop procedure sp_MSscript_article_view 

    if exists (select * from sysobjects
            where type = 'P '
                and name = 'sp_articleview')
        drop procedure sp_articleview
    

    dump tran master with no_log
    

    if exists (select * from sysobjects
            where type = 'P '
                and name = 'sp_addpublication')
        drop procedure sp_addpublication
    

    dump tran master with no_log
    

    if exists (select * from sysobjects
            where type = 'P '
                and name = 'sp_addsubscription')
        drop procedure sp_addsubscription
    

    IF EXISTS (SELECT * FROM sysobjects
            WHERE type = 'P '
                AND name = 'sp_changearticle')
        DROP PROCEDURE sp_changearticle
    

    dump tran master with no_log
    

    IF EXISTS (SELECT * FROM sysobjects
            WHERE type = 'P '
                AND name = 'sp_changepublication')
        DROP PROCEDURE sp_changepublication
    


    IF EXISTS (SELECT * FROM sysobjects
            WHERE type = 'P '
                AND name = 'sp_changesubscription')
        DROP PROCEDURE sp_changesubscription
    

    dump tran master with no_log
    

    if exists (select * from sysobjects
            where type = 'P '
                and name = 'sp_MShcchangesubstatus1')
        drop procedure sp_MShcchangesubstatus1
    

    if exists (select * from sysobjects
            where type = 'P '
                and name = 'sp_MShcchangesubstatus2')
        drop procedure sp_MShcchangesubstatus2
    

    if exists (select * from sysobjects
            where type = 'P '
                and name = 'sp_MShcchangesubstatus3')
        drop procedure sp_MShcchangesubstatus3
    

    dump tran master with no_log
    

    if exists (select * from sysobjects
            where type = 'P '
                and name = 'sp_changesubstatus')
        drop procedure sp_changesubstatus
    

    if exists (select * from sysobjects
            where type = 'P '
                and name = 'sp_droparticle')
        drop procedure sp_droparticle
    

    dump tran master with no_log
    

    if exists (select * from sysobjects
            where type = 'P '
                and name = 'sp_droppublication')
        drop procedure sp_droppublication
    

    if exists (select * from sysobjects
            where type = 'P '
                and name = 'sp_dropsubscription')
        drop procedure sp_dropsubscription
    

    dump tran master with no_log
    

    if exists (select * from sysobjects
            where type = 'P '
                and name = 'sp_helparticle')
        drop procedure sp_helparticle
    

    dump tran master with no_log
    

    if exists (select * from sysobjects
            where type = 'P '
                and name = 'sp_helparticlecolumns')
        drop procedure sp_helparticlecolumns
    

    if exists (select * from sysobjects
            where type = 'P '
                and name = 'sp_helppublication')
        drop procedure sp_helppublication
    
	    
    if exists (select * from sysobjects
            where type = 'P '
                and name = 'sp_MSaddpub_snapshot')
        drop procedure sp_MSaddpub_snapshot

    dump tran master with no_log
    

    if exists (select * from sysobjects
            where type = 'P '
                and name = 'sp_helpsubscription')
        drop procedure sp_helpsubscription
    

    if exists (select * from sysobjects
            where type = 'P '
                and name = 'sp_subscribe')
        drop procedure sp_subscribe
    

    if exists (select * from sysobjects
            where type = 'P '
                and name = 'sp_unsubscribe')
        drop procedure sp_unsubscribe
    

    if exists (select * from sysobjects
            where type = 'P '
                and name = 'sp_refreshsubscriptions')
        drop procedure sp_refreshsubscriptions
    

    dump tran master with no_log
    

    if exists (select * from sysobjects
            where type = 'P '
                and name = 'sp_MSpublishdb')
        drop procedure sp_MSpublishdb
    

    if exists (select * from sysobjects
            where type = 'P '
                and name = 'sp_MSactivate_auto_sub')
        drop procedure sp_MSactivate_auto_sub
    

    if exists (select * from sysobjects
            where type = 'P '
                and name = 'sp_MSget_synctran_commands')
        drop procedure sp_MSget_synctran_commands


    if exists (select * from sysobjects
        where type = 'P '
                and name = 'sp_MSdrop_pub_tables')
    begin
        -- Don't drop the system tables here. repltran.sql should not
        -- delete any data in the master database.
        -- exec dbo.sp_MSdrop_pub_tables
        drop procedure sp_MSdrop_pub_tables
    end

    -- SyncTran
    if exists (select * from sysobjects
        where type = 'P '
                and name = 'sp_MSis_col_replicated')
        drop procedure  sp_MSis_col_replicated

    if exists (select * from sysobjects
        where type = 'P '
                and name = 'sp_MSis_pk_col')
        drop procedure  sp_MSis_pk_col

   if exists (select * from sysobjects
        where type = 'P '
                and name = 'sp_MSscript_compensating_send')
        drop procedure sp_MSscript_compensating_send 

   if exists (select * from sysobjects
        where type = 'P '
                and name = 'sp_MSscript_insert_statement')
        drop procedure sp_MSscript_insert_statement 

	if exists (select * from sysobjects
	    where type = 'P' and name = 'sp_script_insertforcftresolution')
	drop procedure sp_script_insertforcftresolution

   if exists (select * from sysobjects
        where type = 'P '
                and name = 'sp_MSscript_insert_subwins')
        drop procedure sp_MSscript_insert_subwins 

   if exists (select * from sysobjects
        where type = 'P '
                and name = 'sp_MSscript_insert_pubwins')
        drop procedure sp_MSscript_insert_pubwins 

   if exists (select * from sysobjects
        where type = 'P '
                and name = 'sp_MSscript_validate_subscription')
        drop procedure sp_MSscript_validate_subscription 

   if exists (select * from sysobjects
        where type = 'P '
                and name = 'sp_MSvalidate_subscription')
        drop procedure sp_MSvalidate_subscription 

   if exists (select * from sysobjects
        where type = 'P '
                and name = 'sp_MSscript_update_statement')
        drop procedure sp_MSscript_update_statement

   if exists (select * from sysobjects
        where type = 'P '
                and name = 'sp_MSscript_update_subwins')
        drop procedure sp_MSscript_update_subwins 

   if exists (select * from sysobjects
        where type = 'P '
                and name = 'sp_MSscript_update_pubwins')
        drop procedure sp_MSscript_update_pubwins 

   if exists (select * from sysobjects
        where type = 'P '
                and name = 'sp_MSscriptinsertconflictfinder')                
        drop procedure sp_MSscriptinsertconflictfinder
        
   if exists (select * from sysobjects
        where type = 'P '
                and name = 'sp_MSscriptupdateconflictfinder')
        drop procedure sp_MSscriptupdateconflictfinder

   if exists (select * from sysobjects
        where type = 'P '
                and name = 'sp_MSscriptdelconflictfinder')                
        drop procedure sp_MSscriptdelconflictfinder

   if exists (select * from sysobjects
        where type = 'P '
                and name = 'sp_scriptpubwinsrefreshcursorvars')                
        drop procedure sp_scriptpubwinsrefreshcursorvars
        
   if exists (select * from sysobjects
        where type = 'P '
                and name = 'sp_MSscript_delete_statement')
        drop procedure sp_MSscript_delete_statement

   if exists (select * from sysobjects
        where type = 'P '
                and name = 'sp_MSscript_delete_subwins')
        drop procedure sp_MSscript_delete_subwins 

   if exists (select * from sysobjects
        where type = 'P '
                and name = 'sp_MSscript_compensating_insert')
        drop procedure sp_MSscript_compensating_insert 

   if exists (select * from sysobjects
        where type = 'P '
                and name = 'sp_MSscript_delete_pubwins')
        drop procedure sp_MSscript_delete_pubwins 

   if exists (select * from sysobjects
        where type = 'P '
                and name = 'sp_MSscript_beginproc')
        drop procedure sp_MSscript_beginproc

   if exists (select * from sysobjects
        where type = 'P '
                and name = 'sp_MSscript_security')
        drop procedure sp_MSscript_security

   if exists (select * from sysobjects
        where type = 'P '
                and name = 'sp_MSscript_endproc')
        drop procedure sp_MSscript_endproc

  if exists (select * from sysobjects
        where type = 'P '
                and name = 'sp_MStable_not_modifiable')
        drop procedure sp_MStable_not_modifiable

	if exists (select * from sysobjects
        where type = 'P '
                and name = 'sp_MSscript_ExecutionMode_stmt')
        drop procedure sp_MSscript_ExecutionMode_stmt

	if exists (select * from sysobjects
        where type = 'P '
                and name = 'sp_MSscript_sync_ins_proc')
        drop procedure sp_MSscript_sync_ins_proc

   if exists (select * from sysobjects
        where type = 'P '
                and name = 'sp_MSscript_sync_upd_proc')
        drop procedure sp_MSscript_sync_upd_proc 

   if exists (select * from sysobjects
        where type = 'P '
                and name = 'sp_MSscript_sync_del_proc')
        drop procedure sp_MSscript_sync_del_proc

   if exists (select * from sysobjects
        where type = 'P '
                and name = 'sp_MSscript_pub_upd_trig')
        drop procedure sp_MSscript_pub_upd_trig

   if exists (select * from sysobjects
        where type = 'P '
                and name = 'sp_MSmakeconflicttable')
        drop procedure sp_MSmakeconflicttable 

   if exists (select * from sysobjects
        where type = 'P '
                and name = 'sp_scriptsubconflicttable')
        drop procedure sp_scriptsubconflicttable 

   if exists (select * from sysobjects
        where type = 'P '
                and name = 'sp_MSgen_sync_tran_procs')
        drop procedure sp_MSgen_sync_tran_procs 

   if exists (select * from sysobjects
        where type = 'P '
                and name = 'sp_MSis_identity_insert')
        drop procedure sp_MSis_identity_insert 

    if exists (select * from sysobjects
        where type = 'P '
                and name = 'sp_MSmark_proc_norepl')
        drop procedure sp_MSmark_proc_norepl 

    if exists (select * from sysobjects
        where type = 'P '
                and name = 'sp_articlesynctranprocs')
        drop procedure sp_articlesynctranprocs

    if exists (select * from sysobjects
        where type = 'P '
                and name = 'sp_reinitsubscription')
        drop procedure sp_reinitsubscription

    dump tran master with no_log

    if exists( select * from sysobjects 
        where type = 'P ' and name = N'sp_MSareallcolumnscomputed')
    begin
        drop procedure sp_MSareallcolumnscomputed
    end

    if exists( select * from sysobjects 
        where type = 'P ' and name = N'sp_gettypestring' )
    begin
        drop procedure sp_gettypestring
    end

    if exists( select * from sysobjects 
        where type = 'P ' and name = N'sp_MSgettypestringudt' )
    begin
        drop procedure sp_MSgettypestringudt
    end

    if exists( select * from sysobjects 
        where type = 'P ' and name = N'sp_scriptpkwhereclause' )
    begin
        drop procedure sp_scriptpkwhereclause
    end

    if exists( select * from sysobjects 
        where type = 'P ' and name = N'sp_MSscript_missing_row_check' )
    begin
        drop procedure sp_MSscript_missing_row_check
    end

    if exists( select * from sysobjects 
        where type = 'P ' and name = N'sp_scriptupdateparams' )
    begin
        drop procedure sp_scriptupdateparams
    end

    if exists( select * from sysobjects 
        where type = 'P ' and name = N'sp_scriptreconwhereclause' )
    begin
        drop procedure sp_scriptreconwhereclause
    end

    if exists( select * from sysobjects 
        where type = 'P ' and name = N'sp_script_reconciliation_insproc' )
    begin
        drop procedure sp_script_reconciliation_insproc
    end

    if exists( select * from sysobjects 
        where type = 'P ' and name = N'sp_script_reconciliation_delproc' )
    begin
        drop procedure sp_script_reconciliation_delproc
    end

    if exists( select * from sysobjects 
        where type = 'P ' and name = N'sp_script_reconciliation_xdelproc' )
    begin
        drop procedure sp_script_reconciliation_xdelproc
    end

    if exists( select * from sysobjects 
        where type = 'P ' and name = N'sp_scriptinsproc' )
    begin
        drop procedure sp_scriptinsproc
    end

    if exists( select * from sysobjects 
        where type = 'P ' and name = N'sp_scriptdelproc' )
    begin
        drop procedure sp_scriptdelproc
    end

    if exists( select * from sysobjects 
        where type = 'P ' and name = N'sp_scriptxdelproc' )
    begin
        drop procedure sp_scriptxdelproc
    end

    if exists( select * from sysobjects 
        where type = 'P ' and name = N'sp_scriptupdproc' )
    begin
        drop procedure sp_scriptupdproc
    end

    if exists( select * from sysobjects 
        where type = 'P ' and name = N'sp_scriptxupdproc' )
    begin
        drop procedure sp_scriptxupdproc
    end

    if exists ( select * from sysobjects 
        where type = 'P ' and name = 'sp_scriptmappedupdproc' )
    begin
        drop procedure sp_scriptmappedupdproc
    end

    if exists ( select * from sysobjects 
        where type = 'P ' and name = 'sp_scriptdynamicupdproc' )
    begin
        drop procedure sp_scriptdynamicupdproc
    end

    if exists ( select * from sysobjects 
        where type = 'P ' and name = 'sp_MSscriptmvastablenci' )
    begin
        drop procedure sp_MSscriptmvastablenci
    end

    if exists ( select * from sysobjects 
        where type = 'P ' and name = 'sp_MSscriptmvastablepkc' )
    begin
        drop procedure sp_MSscriptmvastablepkc
    end

    if exists ( select * from sysobjects 
        where type = 'P ' and name = 'sp_MSscriptmvastableidx' )
    begin
        drop procedure sp_MSscriptmvastableidx
    end

    if exists ( select * from sysobjects 
        where type = 'P ' and name = 'sp_MSscriptmvastable' )
    begin
        drop procedure sp_MSscriptmvastable
    end

    if exists ( select * from sysobjects 
        where type = 'P ' and name = 'sp_fetchshowcmdsinput' )
    begin
        drop procedure sp_fetchshowcmdsinput
    end

    if exists ( select * from sysobjects 
        where type = 'P ' and name = 'sp_replshowcmds' )
    begin
        drop procedure sp_replshowcmds
    end

    if exists ( select * from sysobjects 
        where type = 'P ' and name = 'sp_publication_validation' )
    begin
        drop procedure sp_publication_validation
    end

    if exists ( select * from sysobjects 
        where type = 'P ' and name = 'sp_marksubscriptionvalidation' )
    begin
        drop procedure sp_marksubscriptionvalidation
    end

    if exists ( select * from sysobjects 
        where type = 'P ' and name = 'sp_article_validation' )
    begin
        drop procedure sp_article_validation
    end

    if exists ( select * from sysobjects 
        where type = 'P ' and name = 'sp_MSdrop_6x_replication_agent' )
    begin
        drop procedure sp_MSdrop_6x_replication_agent
    end

    if exists ( select * from sysobjects 
        where type = 'P ' and name = 'sp_MSget_article_column_list' )
    begin
        drop procedure sp_MSget_article_column_list
    end

    if exists ( select * from sysobjects 
        where type = 'P ' and name = 'sp_MSpub_adjust_identity' )
    begin
        drop procedure sp_MSpub_adjust_identity
    end

    if exists ( select * from sysobjects 
        where type = 'P ' and name = 'sp_helparticledts' )
    begin
        drop procedure sp_helparticledts
    end

    if exists ( select * from sysobjects 
        where type = 'P ' and name = 'sp_changesubscriptiondtsinfo' )
    begin
        drop procedure sp_changesubscriptiondtsinfo
    end

    if exists ( select * from sysobjects 
        where type = 'P ' and name = 'sp_script_synctran_commands' )
    begin
        drop procedure sp_script_synctran_commands
    end

    if exists ( select * from sysobjects 
        where type = 'P ' and name = 'sp_MScomputearticlescreationorder' )
    begin
        drop procedure sp_MScomputearticlescreationorder
    end

    if exists ( select * from sysobjects 
        where type = 'P ' and name = 'sp_MScomputeunresolvedrefs' )
    begin
        drop procedure sp_MScomputeunresolvedrefs
    end

    if exists ( select * from sysobjects 
	        where type = 'P ' and name = 'sp_MShelptranconflictpublications' )
        drop procedure sp_MShelptranconflictpublications

    if exists ( select * from sysobjects 
	        where type = 'P ' and name = 'sp_MShelptranconflictcounts' )
        drop procedure sp_MShelptranconflictcounts

    if exists ( select * from sysobjects 
	        where type = 'P ' and name = 'sp_MSgettranconflictrow' )
        drop procedure sp_MSgettranconflictrow

    if exists ( select * from sysobjects 
	        where type = 'P ' and name = 'sp_MSgettrancftsrcrow' )
        drop procedure sp_MSgettrancftsrcrow

    if exists ( select * from sysobjects 
	        where type = 'P ' and name = 'sp_MSdeletetranconflictrow' )
        drop procedure sp_MSdeletetranconflictrow

    if exists ( select * from sysobjects
            where type = 'P ' and name = 'sp_MSexternalfkreferences' )
        drop procedure sp_MSexternalfkreferences    

	if exists ( select * from sysobjects
            where type = 'P ' and name = 'sp_MSgetarticlereinitvalue' )
        drop procedure sp_MSgetarticlereinitvalue    

	if exists ( select * from sysobjects
            where type = 'P ' and name = 'sp_MSispkupdateinconflict' )
        drop procedure sp_MSispkupdateinconflict    

	if exists ( select * from sysobjects
            where type = 'P ' and name = 'sp_MSisnonpkukupdateinconflict' )
        drop procedure sp_MSisnonpkukupdateinconflict    

	if exists ( select * from sysobjects
            where type = 'P ' and name = 'sp_dropanonymousagent' )
        drop procedure sp_dropanonymousagent    

	if exists ( select * from sysobjects
            where type = 'P ' and name = 'sp_ivindexhasnullcols' )
        drop procedure sp_ivindexhasnullcols    

	if exists (select * from sysobjects
			where type = 'FN' and name = 'fn_sqlvarbasetostr')
	     drop function fn_sqlvarbasetostr

	if exists ( select * from sysobjects
            where type = 'P ' and name = 'sp_replrestart' )
        drop procedure sp_replrestart    

	if exists ( select * from sysobjects
            where type = 'P ' and name = 'sp_MSreinit_article' )
        drop procedure sp_MSreinit_article    

    if exists ( select * from sysobjects
            where type = 'P ' and name = 'sp_replqueuemonitor' )
        drop procedure sp_replqueuemonitor    

    if exists ( select * from sysobjects
            where type = 'P ' and name = 'sp_replsqlqgetrows' )
        drop procedure sp_replsqlqgetrows

	if exists (select * from sysobjects
	    where type = 'P' and name = 'sp_repldeletequeuedtran')
	drop procedure sp_repldeletequeuedtran

	if exists ( select * from sysobjects
            where type = 'P ' and name = 'sp_MSrepl_schema' )
        drop procedure sp_MSrepl_schema    

	if exists ( select * from sysobjects
            where type = 'P ' and name = 'sp_MSpost_auto_proc' )
        drop procedure sp_MSpost_auto_proc    

	if exists ( select * from sysobjects
            where type = 'P ' and name = 'sp_MSreplupdateschema' )
        drop procedure sp_MSreplupdateschema    

	if exists ( select * from sysobjects
            where type = 'P ' and name = 'sp_MSdefer_check' )
        drop procedure sp_MSdefer_check    

	if exists ( select * from sysobjects
            where type = 'P ' and name = 'sp_MSreenable_check' )
        drop procedure sp_MSreenable_check    

	if exists ( select * from sysobjects
            where type = 'P ' and name = 'sp_getqueuedrows' )
        drop procedure sp_getqueuedrows    

	if exists ( select * from sysobjects
            where type = 'P ' and name = 'sp_MSprep_exclusive' )
        drop procedure sp_MSprep_exclusive    

	if exists ( select * from sysobjects
	    where type = 'P ' and name = 'sp_verify_publication' )
	drop procedure sp_verify_publication

    if exists ( select * from sysobjects
        where type = 'P ' and name = 'sp_scriptpublicationcustomprocs')
    drop procedure sp_scriptpublicationcustomprocs

    if exists (select * from sysobjects
        where type = 'P' and name = 'sp_repltablehasnonpkuniquekey')
    drop procedure sp_repltablehasnonpkuniquekey

    if exists (select * from sysobjects
        where type = 'P' and name = 'sp_replscriptuniquekeywhereclause')
    drop procedure sp_replscriptuniquekeywhereclause

    if exists (select * from sysobjects
        where type = 'P' and name = 'sp_getqueuedarticlesynctraninfo')
    drop procedure sp_getqueuedarticlesynctraninfo

    if exists (select * from sysobjects
        where type = 'P' and name = 'sp_getsqlqueueversion')
    drop procedure sp_getsqlqueueversion

	dump tran master with no_log
go
 
EXEC dbo.sp_MS_marksystemobject sp_MSdrop_repltran
GO

EXEC dbo.sp_MSdrop_repltran
GO

/* Create and execute dbo.sp_MSdrop_pub_tables */

print ''
print 'Creating procedure sp_MSdrop_pub_tables'
go
CREATE PROCEDURE sp_MSdrop_pub_tables
AS
        
    begin tran
    save TRAN sp_drop_central_pub_tables
    
    /* drop 'sysarticles' */
    IF exists (select * from sysobjects where name = 'sysarticles')
    BEGIN
        DROP TABLE sysarticles
        IF @@ERROR <> 0
        BEGIN
            if @@trancount > 0
            begin
                ROLLBACK TRAN sp_drop_central_pub_tables
                commit tran
            end
            RETURN(1)
        END
    END

    /* drop 'sysschemaarticles' */
    IF exists (select * from sysobjects where name = 'sysschemaarticles')
    BEGIN
        DROP TABLE sysschemaarticles
        IF @@ERROR <> 0
        BEGIN
            if @@trancount > 0
            begin
                ROLLBACK TRAN sp_drop_central_pub_tables
                commit tran
            end
            RETURN (1)
        END
    END

    /* drop 'sysextendedarticlesview' */
    IF exists (select * from sysobjects where name = 'sysextendedarticlesview')
    BEGIN
        DROP VIEW sysextendedarticlesview
        IF @@ERROR <> 0
        BEGIN
            if @@trancount > 0
            begin
                ROLLBACK TRAN sp_drop_central_pub_tables
                commit tran
            end
            RETURN (1)
        END
    END


    /* drop 'syspublications' */
    IF exists (select * from sysobjects where name = 'syspublications')
    BEGIN
        DROP TABLE syspublications
        IF @@ERROR <> 0
        BEGIN
            if @@trancount > 0
            begin
                ROLLBACK TRAN sp_drop_central_pub_tables
                commit tran
            end
            RETURN(1)
        END
    END

    /* drop 'syssubscriptions' */
    IF exists (select * from sysobjects where name = 'syssubscriptions')
    BEGIN
        DROP TABLE syssubscriptions
        IF @@ERROR <> 0
        BEGIN
            if @@trancount > 0
            begin
                ROLLBACK TRAN sp_drop_central_pub_tables
                commit tran
            end
            RETURN(1)
        END
    END

    -- SyncTran
    /* drop 'sysarticleupdates' */
    IF exists (select * from sysobjects where name = 'sysarticleupdates')
    BEGIN
        DROP TABLE sysarticleupdates
        IF @@ERROR <> 0
        BEGIN
            if @@trancount > 0
            begin
                ROLLBACK TRAN sp_drop_central_pub_tables
                commit tran
            end
            RETURN(1)
        END
    END

    IF exists (select * from sysobjects where name = 'MSpub_identity_range')
    BEGIN
        DROP TABLE MSpub_identity_range
        IF @@ERROR <> 0
        BEGIN
            if @@trancount > 0
            begin
                ROLLBACK TRAN sp_drop_central_pub_tables
                commit tran
            end
            RETURN(1)
        END
    END
    -- end SyncTran

    IF exists (select * from sysobjects where name = 'systranschemas' and uid = 1)
    BEGIN
        DROP TABLE dbo.systranschemas
        IF @@ERROR <> 0
        BEGIN
            if @@trancount > 0
            begin
                ROLLBACK TRAN sp_drop_central_pub_tables
                commit tran
            end
            RETURN(1)
        END
    END

    COMMIT TRAN
GO
 
EXEC dbo.sp_MS_marksystemobject sp_MSdrop_pub_tables
GO

dump tran master with no_log
go

--print ''
--print 'Executing procedure dbo.sp_MSdrop_pub_tables.'
--go
--exec dbo.sp_MSdrop_pub_tables
--go

--dump tran master with no_log
--go

/* Create and execute dbo.sp_MScreate_pub_tables */

dump tran master with no_log
go

print ''
print 'Creating procedure sp_MSarticlecolstatus'
go
CREATE PROCEDURE sp_MSarticlecolstatus (
    @artid int,
    @tabid int,
    @colid int,
    @type nvarchar (10),      /* 'publish', 'nonsqlsub' */
    @status bit OUTPUT)
    AS

    SELECT @status = 0

    IF LOWER(@type collate SQL_Latin1_General_CP1_CS_AS) = N'nonsqlsub'
    BEGIN

		----------------------------------------------------------
		-- Check all active or subscribed articles for the column.
        ----------------------------------------------------------

		IF EXISTS( SELECT sub.artid FROM sysarticles art, syssubscriptions sub, syspublications sp, master.dbo.sysservers ss
				   WHERE art.objid = @tabid
				   AND art.artid <> @artid
				   AND sub.artid = art.artid
				   AND ss.srvid = sub.srvid
				   AND sp.pubid = art.pubid
				   AND ( ( sub.status in(1,2) AND (ss.srvproduct = N'MSREPL-NONSQL' OR sp.allow_anonymous = 1) ) 
				         OR sub.status = 3 )
				   AND CONVERT(bit, CONVERT( varbinary, SUBSTRING( CONVERT( nvarchar, art.columns ), 16 - FLOOR((@colid-1)/16),1 )) & POWER(2, ((@colid-1)%16))) = 1 )
		BEGIN
			SELECT @status = 1
		END
    END
    ELSE
    BEGIN
    
		-----------------------------------------------------------
		-- Check all articles for the column.
        -----------------------------------------------------------

		IF EXISTS( SELECT artid FROM sysarticles 
                   WHERE objid = @tabid
                   AND artid <> @artid
				   AND CONVERT(bit, CONVERT( varbinary, SUBSTRING( CONVERT( nvarchar, columns ), 16 - FLOOR((@colid-1)/16),1 )) & POWER(2, ((@colid-1)%16))) = 1 )
		BEGIN
			SELECT @status = 1
		END
    END

    RETURN (0)
GO
 
EXEC dbo.sp_MS_marksystemobject sp_MSarticlecolstatus
GO


print ''
print 'Creating procedure sp_MSarticlecol'
go
CREATE PROCEDURE sp_MSarticlecol (
    @artid int,
    @colid smallint = NULL,
    @type nvarchar(10),      /* 'publish', 'nonsqlsub' */
    @operation nvarchar(5))  /* 'add', 'drop' */
    AS

    /*
    ** Declarations.
    */
    DECLARE @cmd nvarchar(255)
    DECLARE @cmd1 nvarchar(255)
    DECLARE @columns binary(32)    /* Temporary storage for the converted column */
    DECLARE @tabid int        /* Article base table id */
    DECLARE @retcode int
    DECLARE @status bit
    DECLARE @publish smallint        /* Constant: 0x1000 */
    DECLARE @nonsqlsub smallint        /* Constant: 0x2000 */
	DECLARE @initiated smallint			/* Constant: 0x4000 */
	DECLARE @repldts smallint			/* Constant: 0x8000 */
    DECLARE @tinycolid tinyint, @allow_dts bit, @pubid int  /* hydra compatible colid */

    if @colid >= 256
    begin
	raiserror(21395, 16, -1)
        RETURN (1)
    end

    SELECT @tinycolid = @colid

    SELECT @tabid = objid, @pubid = pubid FROM sysarticles WHERE artid = @artid

	select @allow_dts = allow_dts from syspublications where pubid = @pubid


    SELECT @publish = 0x1000
    SELECT @nonsqlsub = 0x2000
	SELECT @initiated = 0x4000
	if @allow_dts = 1
		select @repldts = 0x8000
	else
		select @repldts = 0x0000

	-- loop through all columns in the article

    IF @colid IS NULL
    BEGIN
       DECLARE hCartcol CURSOR LOCAL FAST_FORWARD FOR
            SELECT colid FROM syscolumns, sysarticles
                WHERE artid = @artid
                AND id = @tabid
                AND convert(bit, convert( varbinary, substring( convert( nvarchar, columns ), 16 - floor((colid-1)/16),1 )) & power( 2, ((colid-1)%16))) = 1
    END
    ELSE
    BEGIN
       DECLARE hCartcol CURSOR LOCAL FAST_FORWARD FOR 
            SELECT colid FROM syscolumns WHERE id = @tabid
                AND colid = @colid
    END


    OPEN hCartcol

    FETCH hCartcol INTO @colid

    WHILE (@@fetch_status <> -1)
    BEGIN

       IF LOWER(@operation collate SQL_Latin1_General_CP1_CS_AS) = N'add'
       BEGIN
          IF LOWER(@type collate SQL_Latin1_General_CP1_CS_AS) = N'publish'
          BEGIN
             UPDATE syscolumns
             SET colstat = colstat | @publish
             WHERE id = @tabid
             AND colid = @colid
          END
          ELSE
          BEGIN
             UPDATE syscolumns
             SET colstat = colstat | @nonsqlsub | @repldts
             WHERE id = @tabid
             AND colid = @colid
          END
       END
       ELSE /* drop */
       BEGIN
          /*
          ** Is there another non-sql server subscription on the column?
          ** Or another article publishing the column?
          */
          EXEC @retcode = dbo.sp_MSarticlecolstatus @artid, @tabid, @colid,
          @type, @status OUTPUT

          IF @@error <> 0 OR @retcode <> 0
          BEGIN
             CLOSE hCartcol
            DEALLOCATE hCartcol
            RETURN (1)
          END

          IF (@status = 0)
          BEGIN
             IF LOWER(@type collate SQL_Latin1_General_CP1_CS_AS) = N'publish'
             BEGIN
                /* Clear 'publish' bit */
                UPDATE syscolumns
                SET colstat = colstat & ~@publish
                WHERE id = @tabid
                AND colid = @colid
             END
             ELSE
             BEGIN
                /* Clear 'non-sql server subscription' bit */
                UPDATE syscolumns
                SET colstat = colstat & ~@nonsqlsub & ~@repldts
                WHERE id = @tabid
                AND colid = @colid
             END
          END
       END

       FETCH hCartcol INTO @colid

    END


    CLOSE hCartcol
    DEALLOCATE hCartcol

GO

EXEC dbo.sp_MS_marksystemobject sp_MSarticlecol
GO

print ''
print 'Creating procedure sp_MScreate_pub_tables'
go
CREATE PROCEDURE sp_MScreate_pub_tables
AS
    DECLARE @fError int
    SELECT @fError = 0

    -- enable 'create tables as pseudo system tables

    -- sp_MS_upd_sysobj_category is obsolete, use sp_MS_marksystemobject instead
    -- exec dbo.sp_MS_upd_sysobj_category 1


    /* 
    ** Msg 226, Level 16, State 9
    ** CREATE TABLE system-table command not allowed within multi-statement transaction.
    */
    /*
    BEGIN TRAN sp_create_central_pub_tables
    */
    
    /* Creating 'sysarticles' */
    IF not exists (select * from sysobjects where name = 'sysarticles')
    BEGIN
        create table dbo.sysarticles
        (
        artid               int                 identity NOT NULL,
        columns             varbinary(32)       NULL,
        creation_script     nvarchar(255)       NULL,
        del_cmd             nvarchar(255)       NULL,
        description         nvarchar(255)       NULL,
        dest_table          sysname             NOT NULL,
        filter              int                 NOT NULL,
        filter_clause       ntext               NULL,
        ins_cmd             nvarchar(255)       NULL,
        name                sysname             NOT NULL,
        objid               int                 NOT NULL,
        pubid               int                 NOT NULL,
        pre_creation_cmd    tinyint             NOT NULL,
        status              tinyint             NOT NULL,
        sync_objid          int                 NOT NULL,
        type                tinyint             NOT NULL,
        upd_cmd             nvarchar(255)       NULL,
        schema_option       binary(8)           NULL,
        dest_owner          sysname             NULL
        -- Note: Please update sysextendedarticlesview whenever
        -- there is a schema change in sysarticles
        )

        EXEC dbo.sp_MS_marksystemobject 'sysarticles'

        IF @@error<>0
        BEGIN
            GOTO ERROR
        END

        create unique nonclustered index unc1sysarticles
            on sysarticles(artid, pubid) 
        
        IF @@error<>0
        BEGIN
            GOTO ERROR
        END

    END

    /* Creating 'sysschemaarticles' */
    IF not exists (select * from sysobjects where name = 'sysschemaarticles')
    BEGIN
        create table dbo.sysschemaarticles
        (
        artid               int                 NOT NULL,
        creation_script     nvarchar(255)       NULL,
        description         nvarchar(255)       NULL,
        dest_object         sysname             NOT NULL,
        name                sysname             NOT NULL,
        objid               int                 NOT NULL,
        pubid               int                 NOT NULL,
        pre_creation_cmd    tinyint             NOT NULL,
        status              int                 NOT NULL,
        type                tinyint             NOT NULL,
        schema_option       binary(8)           NULL,
        dest_owner          sysname             NULL
        )
        
        IF @@error<>0
        BEGIN
            GOTO ERROR
        END

        EXEC dbo.sp_MS_marksystemobject 'sysschemaarticles'

        IF @@error<>0
        BEGIN
            GOTO ERROR
        END

        create unique nonclustered index unc1sysschemaarticles
            on sysschemaarticles(artid, pubid)

        IF @@error<>0
        BEGIN
            GOTO ERROR
        END
        
    END

    /* Creating 'sysextendedarticlesview' */
    IF not exists (select * from sysobjects where name = 'sysextendedarticlesview')
    BEGIN
        exec ('create view dbo.sysextendedarticlesview
               as
               select * from sysarticles
               union all
               select artid, NULL, creation_script, NULL, description,
               dest_object, NULL, NULL, NULL, name, objid, pubid, 
               pre_creation_cmd, status, NULL, type, NULL, 
               schema_option, dest_owner from sysschemaarticles
               go')

        IF @@error<>0
        BEGIN
            GOTO ERROR
        END 

        EXEC dbo.sp_MS_marksystemobject 'sysextendedarticlesview'

        IF @@error<>0
        BEGIN
            GOTO ERROR
        END

    END

    /* Creating 'syspublications' */
    IF NOT EXISTS (select * from sysobjects where name = 'syspublications')
    BEGIN
        CREATE TABLE dbo.syspublications (
        description                 nvarchar(255)   NULL,
        name                        sysname         NOT NULL,
        pubid                       int    identity NOT NULL,
        repl_freq                   tinyint         NOT NULL,
        status                      tinyint         NOT NULL,
        sync_method                 tinyint         NOT NULL,
        snapshot_jobid              binary(16)		NULL,
        independent_agent           bit             NOT NULL,
        immediate_sync              bit             NOT NULL,
        enabled_for_internet        bit             NOT NULL,
        allow_push                  bit             NOT NULL,
        allow_pull                  bit             NOT NULL,
        allow_anonymous             bit             NOT NULL,
        immediate_sync_ready        bit             NOT NULL,
        -- SyncTran
		allow_sync_tran             bit             NOT NULL,
        autogen_sync_procs          bit             NOT NULL,
        retention                   int             NULL,
		-- The following are post 7.0
        allow_queued_tran           bit   default 0	not null, 
        -- portable snapshot support
        snapshot_in_defaultfolder           bit   default 1 NOT NULL,         
        alt_snapshot_folder         nvarchar(255)   NULL,
        -- snapshot pre/post- command
        pre_snapshot_script         nvarchar(255)   NULL,
        post_snapshot_script        nvarchar(255)   NULL,
        -- Snapshot compression
        compress_snapshot           bit   default 0 NOT NULL,          
        -- Post 7.0 Ftp support
        ftp_address                 sysname         NULL,
        ftp_port                    int   default 21 NOT NULL,
        ftp_subdirectory            nvarchar(255)   NULL,
        ftp_login                   sysname         NULL default N'anonymous',
        ftp_password                nvarchar(524)   NULL,
		allow_dts		bit default 0 not null,
		allow_subscription_copy		bit default 0 not null,
		centralized_conflicts		bit				NULL, -- 0 False, 1 True
		conflict_retention			int				NULL, -- 60
		conflict_policy				int 			NULL, -- 1 = PubWins, 2 = SubWins, 3 = Reinit
		queue_type					int				NULL,  -- 1 = MSMQ, 2 = SQL
		ad_guidname					sysname			NULL,
		backward_comp_level	int default 10 not NULL -- default is sphinx
        )

        EXEC dbo.sp_MS_marksystemobject 'syspublications'

        IF @@ERROR <> 0
        BEGIN
            GOTO ERROR
        END

        create unique clustered index uc1syspublications
            on syspublications (pubid) 
        IF @@ERROR <> 0
        BEGIN
            GOTO ERROR
        END

        create unique nonclustered index unc2syspublications
            on syspublications (name)

        IF @@ERROR <> 0
        BEGIN
            GOTO ERROR
        END

    END

       /* Creating 'syssubscriptions' */
    IF not exists (select * from sysobjects where name = 'syssubscriptions')
    BEGIN

        CREATE TABLE dbo.syssubscriptions
        (
        artid                    int                NOT NULL,
        srvid                    smallint        NOT NULL,
        dest_db                    sysname        NOT NULL,
        status                    tinyint            NOT NULL,
        sync_type                tinyint            NOT NULL,
        login_name                sysname        NOT NULL,
        subscription_type        int                NOT NULL,
        distribution_jobid      binary(16)          NULL,
        timestamp NOT NULL,
        -- SyncTran
        update_mode             tinyint            NOT NULL, -- 0 (read only), 1 (Sync Tran), 
		                                                     -- Queued Tran
															 -- 2 (Queued Tran) , 3 (Failover), 4(sqlqueued), 5(sqlqueued failover)
        loopback_detection      bit NOT NULL,
  		queued_reinit		   bit DEFAULT 0 NOT NULL 
      )

        EXEC dbo.sp_MS_marksystemobject 'syssubscriptions'

        IF @@ERROR <> 0
        BEGIN
            GOTO ERROR
        END

        create unique nonclustered index unc1syssubscriptions
            on syssubscriptions (artid, srvid, dest_db)

        IF @@ERROR <> 0
        BEGIN
            GOTO ERROR
        END

    END

    -- SyncTran
    /* Creating 'sysarticleupdates' */

    IF not exists (select * from sysobjects where name = 'sysarticleupdates')
    BEGIN

        CREATE TABLE dbo.sysarticleupdates
        (
        artid                  int       NOT NULL,
        pubid                  int       NOT NULL,
        sync_ins_proc          int       NOT NULL,     -- ID of sproc handling Insert Sync Transactions
        sync_upd_proc          int       NOT NULL,     -- ID of sproc handling Update Sync Transactions
        sync_del_proc          int       NOT NULL,     -- ID of sproc handling Delete Sync Transactions
        autogen                bit       NOT NULL,
		sync_upd_trig          int       NOT NULL,     -- Note 7.0 upgrade issue
		conflict_tableid	   int		 NULL,		   -- ID of conflict table for this article
		ins_conflict_proc	   int		 NULL,		   -- ID of sproc to log conflicts
		identity_support	   bit default 0 not null  -- Whether or not do auto identity range 
		)     

        IF @@ERROR <> 0
        BEGIN
            GOTO ERROR
        END


        -- mark the index as a system object
        exec dbo.sp_MS_marksystemobject 'sysarticleupdates'

        IF @@ERROR <> 0
        BEGIN
            GOTO ERROR
        END

        create unique nonclustered index unc1sysarticleupdates
            on sysarticleupdates (artid, pubid)

        IF @@ERROR <> 0
        BEGIN
            GOTO ERROR
        END
    END
    -- end SyncTran


    IF not exists (select * from sysobjects where name = 'MSpub_identity_range')
    BEGIN
        CREATE TABLE dbo.MSpub_identity_range
        (
			objid int not null,
			range bigint not null,
			pub_range bigint not null,
            current_pub_range bigint not null,
			threshold int not null,
			last_seed bigint null -- It will be not when uninitialized.
		)     

        IF @@ERROR <> 0
        BEGIN
            GOTO ERROR
        END


        -- mark the index as a system object
        exec dbo.sp_MS_marksystemobject 'MSpub_identity_range'

        IF @@ERROR <> 0
        BEGIN
            GOTO ERROR
        END

        create unique nonclustered index unc1MSpub_identity_range
            on MSpub_identity_range (objid)

        IF @@ERROR <> 0
        BEGIN
            GOTO ERROR
        END
    END

    IF not exists (select * from sysobjects where name = 'systranschemas' and uid = 1)
    BEGIN
        CREATE TABLE dbo.systranschemas
        (
			tabid int not null,
			startlsn binary(10) not null,
			endlsn binary(10) not null
	)     

        IF @@ERROR <> 0
        BEGIN
            GOTO ERROR
        END

        -- mark the index as a system object
        exec dbo.sp_MS_marksystemobject 'systranschemas'

        IF @@ERROR <> 0
        BEGIN
            GOTO ERROR
        END

        create unique clustered index uncsystranschemas
            on systranschemas (startlsn)

        IF @@ERROR <> 0
        BEGIN
            GOTO ERROR
        END
    END

CLEANUP:

    -- disable 'create tables as pseudo system tables
    -- sp_MS_upd_sysobj_category is obsolete, use sp_MS_marksystemobject instead
    -- exec dbo.sp_MS_upd_sysobj_category 2
    RETURN( @fError )

ERROR:

    select @fError = 1
    GOTO CLEANUP

GO
 
EXEC dbo.sp_MS_marksystemobject sp_MScreate_pub_tables
GO

dump tran master with no_log
go

/*
** Create replication stored procedures.
** Part 2:  create all other stored procedures.
*/

create proc sp_MSsetfilterparent @filter_name nvarchar(386), @parent_id int
as
   -- SQL SERVER 7.0 ONLY update sysobjects, set parent id = underlying
   -- object id

    declare @retcode int
    exec @retcode = dbo.sp_MSreplcheck_publish
    if @@ERROR <> 0 or @retcode <> 0
        return(1)

    -- Don't bother to do anything if filter name is null or empty
    if @filter_name is null or @filter_name = N''
        return 0


   BEGIN TRAN

   exec dbo.sp_replupdateschema @filter_name 
   update sysobjects set parent_obj = @parent_id where id = object_id( @filter_name )
   exec dbo.sp_replupdateschema @filter_name 

   COMMIT TRAN

go


EXEC dbo.sp_MS_marksystemobject sp_MSsetfilterparent
GO

create proc sp_MSdoesfilterhaveparent @filter_id int
as
    declare @retcode int
    exec @retcode = dbo.sp_MSreplcheck_publish
    if @@ERROR <> 0 or @retcode <> 0
        return(1)

    if exists ( select * from sysobjects
                where id = @filter_id and
                parent_obj <> 0 )
    BEGIN
        return 1
    END
    ELSE
    BEGIN
        return 0
    END
go

EXEC dbo.sp_MS_marksystemobject sp_MSdoesfilterhaveparent
GO


create proc sp_MSsetfilteredstatus @object_id int
as
    declare @qualified_name nvarchar(512)

    declare @retcode int
    exec @retcode = dbo.sp_MSreplcheck_publish
    if @@ERROR <> 0 or @retcode <> 0
        return(1)

    exec dbo.sp_MSget_qualified_name @object_id, @qualified_name output

   BEGIN TRANSACTION
   
   exec dbo.sp_replupdateschema @qualified_name
        
   if exists( select * from sysobjects where type = 'RF' and parent_obj = @object_id )
      or exists( select * from sysarticles where objid = @object_id and ( upd_cmd like 'CALL%' OR upd_cmd like 'XCALL%' ) 
	  or exists( select * from sysarticles sa, syssubscriptions ss where sa.artid = ss.artid and ss.status = 3) )
   begin
       update sysobjects set replinfo = replinfo | 32 where id = @object_id
   end
   else
   begin
       update sysobjects set replinfo = replinfo & ~32 where id = @object_id
   end

   exec dbo.sp_replupdateschema @qualified_name

   COMMIT TRANSACTION
   
go

EXEC dbo.sp_MS_marksystemobject sp_MSsetfilteredstatus
GO

CREATE PROCEDURE sp_MSretrieve_publication 
@publication sysname
AS
declare @retcode int
/*
** Security Check
*/
exec @retcode = dbo.sp_MSreplcheck_publish
if @@ERROR <> 0 or @retcode <> 0
	return(1)

select 'Name' = name, 
		'database ' = db_name(), 
		'publisher' = @@SERVERNAME, 
		'type' = case when LOWER(repl_freq)=1 then 'Snapshot' else 'Transactional' end, 
		'description ' = description, 
		'status ' = status,  
		'allow known pull subscription' = allow_pull, 
		'allow immediate-updating subscription ' = allow_sync_tran,
		'allow anonymous ' = allow_anonymous,  
		'allow queued-updating subscription ' = allow_queued_tran, 
		'allow snapshot files FTP downloading' = enabled_for_internet, 
		'third party' = sync_method 
	from syspublications
	where name = @publication
go

EXEC dbo.sp_MS_marksystemobject sp_MSretrieve_publication
GO



CREATE PROCEDURE sp_MSreplsup_table_has_pk @tabid INT
as

-- if it's a table, check that it has a PK
-- if it's a view, see if it has an index ( MVs must have a unique CI )

    IF EXISTS (SELECT so1.* FROM sysobjects so1, sysobjects so2
                   WHERE so1.parent_obj = @tabid
                   AND so1.xtype = 'PK'
				   AND so2.id = so1.parent_obj
				   AND so2.xtype = 'U')
	BEGIN
		RETURN 1
	END

	IF EXISTS (SELECT * from sysobjects so, sysindexes si
					WHERE so.id = @tabid
					AND so.xtype = 'V'
					AND si.id = so.id )
	BEGIN
		-- evaluate keys, make sure none are nullable
		DECLARE @indkey int
		DECLARE @objname nvarchar(256)

		SELECT @indkey = 1
		select @objname = QUOTENAME(user_name(OBJECTPROPERTY(@tabid, 'OwnerId'))) collate database_default + N'.' + QUOTENAME(object_name( @tabid )) collate database_default 

		WHILE @indkey <= 16 and index_col( @objname, 1, @indkey ) is not null
		BEGIN
			IF NOT EXISTS( SELECT * FROM syscolumns 
						WHERE id = @tabid
						AND name = index_col( @objname, 1, @indkey )
						AND isnullable = 0 )
			BEGIN
				RETURN 0
			END

			SELECT @indkey = @indkey + 1
		END
		RETURN 1
	END
	ELSE
	BEGIN
        RETURN 0
	END
go

EXEC dbo.sp_MS_marksystemobject sp_MSreplsup_table_has_pk
GO

CREATE PROCEDURE sp_replsync (
    @publisher sysname,    
    @publisher_db sysname,        
    @publication sysname,    
    @article sysname = '%' 
    ) AS

    SET NOCOUNT ON
    RAISERROR (21023, 16, -1,'sp_replsync')
    RETURN(1)
GO

EXEC dbo.sp_MS_marksystemobject sp_replsync
GO


print ''
print 'Creating procedure sp_enumfullsubscriber'
go

CREATE PROCEDURE sp_enumfullsubscribers (
        @publication sysname = '%'      /* The publication name */
    ) AS

    /*
    ** Declarations.
    */

    DECLARE @retcode int

    /*
    ** Security Check
    */
    exec @retcode = dbo.sp_MSreplcheck_publish
    if @@ERROR <> 0 or @retcode <> 0
        return(1)

    /*
    ** Parameter Check: @publication.
    ** Check to make sure that the publication exists and that it conforms
    ** to the rules for identifiers.
    */

    IF @publication IS NOT NULL
        BEGIN

            IF @publication <> '%'
                BEGIN
                    EXECUTE @retcode = dbo.sp_validname @publication

                    IF @retcode <> 0
                    RETURN (1)
                END

            IF NOT EXISTS (SELECT * FROM syspublications WHERE name LIKE @publication)
                BEGIN
                    RAISERROR (20026, 11, -1, @publication)
                    RETURN (1)
                END

        END

    ELSE
        BEGIN
            RAISERROR (14043, 16, -1, '@publication')
            RETURN (1)
        END

    /*
    ** Select all subscribers who subscribe to all articles in the desired
    ** publication.
    */

    SELECT DISTINCT 'subscriber' = sv.srvname
      FROM syspublications p,
           sysextendedarticlesview s,
           syssubscriptions ss,
           master..sysservers sv
     WHERE p.name LIKE @publication collate database_default
       AND p.pubid = s.pubid
       AND s.artid = ss.artid
       AND ss.srvid = sv.srvid
       AND NOT EXISTS (SELECT *
                         FROM sysextendedarticlesview s2
                        WHERE s2.pubid = p.pubid
                          AND NOT EXISTS (SELECT *
                                            FROM syssubscriptions ss2,
                                                 master..sysservers sv2
                                           WHERE s2.artid = ss2.artid
                                             AND ss2.srvid = sv2.srvid
                                             AND sv2.srvid = sv.srvid))
go
 

EXEC dbo.sp_MS_marksystemobject sp_enumfullsubscribers
GO

print ''
print 'Creating procedure sp_addpublication.'
go


CREATE PROCEDURE sp_addpublication (
    @publication			sysname,                          /* publication name */
    @taskid					int = 0,                          /* backward compatible */
    @restricted				nvarchar (10) = 'false',          /* publication security */
    @sync_method			nvarchar(13) = 'native',          /* (bcp) native, (bcp) character */
    @repl_freq				nvarchar(10) = 'continuous',      /* continuous, snapshot */
    @description			nvarchar (255) = NULL,            /* publication description */
    @status					nvarchar(8) = 'inactive',         /* publication status; 0=inactive, 1=active */
    @independent_agent		nvarchar(5) = 'false',            /* true or false */
    @immediate_sync			nvarchar(5) = 'false',            /* true or false */
    @enabled_for_internet	nvarchar(5) = 'false',            /* true or false */
    @allow_push				nvarchar(5) = 'true',             /* true or false */
    @allow_pull				nvarchar(5) = 'false',            /* true or false */
    @allow_anonymous		nvarchar(5) = 'false',            /* true or false */
    -- SyncTran
    @allow_sync_tran		nvarchar(5) = 'false',            /* true or false */
    @autogen_sync_procs		nvarchar(5) = 'true',             /* auto gen sync tran procs per article */
    @retention				int = 336,                        /* 14  days */
    @allow_queued_tran      nvarchar(5) = 'false',
    -- Portable Snapshot
    @snapshot_in_defaultfolder      nvarchar(5) = 'true',
    @alt_snapshot_folder    nvarchar(255) = NULL,
    -- Snapshot pre/post- commands
    @pre_snapshot_script    nvarchar(255) = NULL,
    @post_snapshot_script   nvarchar(255) = NULL,
    -- Snapshot compression
    @compress_snapshot      nvarchar(5) = 'false',
    -- Post 7.0 FTP
    @ftp_address            sysname = NULL,
    @ftp_port                   int = 21,
    @ftp_subdirectory       nvarchar(255) = NULL,
    @ftp_login              sysname = N'anonymous',
    @ftp_password           sysname = NULL,
    @allow_dts				nvarchar(5)	= 'false',
	@allow_subscription_copy nvarchar(5) = 'false',
	@conflict_policy		nvarchar(100) = NULL, 	-- NULL, 'pub wins', 'sub reinit', 'sub wins'
	@centralized_conflicts	nvarchar(5) = NULL, 	-- NULL, 'true', 'false'
	@conflict_retention		int = 14,
	@queue_type				nvarchar(10) = NULL,	-- NULL, 'msmq', 'sql'
	@add_to_active_directory	nvarchar(10) = 'false',
	@logreader_job_name sysname = NULL,
	@qreader_job_name sysname = NULL
	) 
AS
BEGIN

    SET NOCOUNT ON

    /*
    ** Declarations.
    */

    DECLARE @retcode    int         /* return code value for procedure execution */
    DECLARE @rfid tinyint           /* identifier for replication frequency */
    DECLARE @publish_bit smallint   /* publication bit (flag) in sysobjects */
    DECLARE @smid tinyint           /* identifier for sync method */
    DECLARE @statid tinyint         /* status id based on @status */
    DECLARE @subs_type_id tinyint   /* subscription type id based on @subscription_type */
    DECLARE @distributor sysname
    DECLARE @distribdb sysname
    DECLARE @distproc nvarchar (255)
    DECLARE @agentname nvarchar (40)
    DECLARE @dbname sysname
    DECLARE @mergepublish_bit smallint
    DECLARE @found int
    DECLARE @independent_agent_id bit
    DECLARE @immediate_sync_id bit
    DECLARE @enabled_for_internet_id bit
    DECLARE @allow_push_id bit
    DECLARE @allow_pull_id bit
    DECLARE @allow_anonymous_id bit
    DECLARE @pubid int
    declare @distgroup sysname
    DECLARE @enc_ftp_password nvarchar(524)
	DECLARE @ad_guidname	sysname
	
    -- SyncTran
    DECLARE @allow_sync_tran_id bit
    DECLARE @allow_queued_tran_id bit
    DECLARE @autogen_sync_procs_id bit
	DECLARE @conflict_policy_id int
	DECLARE @centralized_conflicts_bit bit
			, @queue_type_val int
	
    -- Portable snapshot
    DECLARE @snapshot_in_defaultfolder_bit int 

    -- Snapshot compression
    DECLARE @compress_snapshot_bit bit

    declare @qv_replication varchar(10)
	declare @qv_replication_unlimited integer
	declare @qv_value_replication integer

	declare @backward_comp_level int
	select @backward_comp_level = 10 -- default to sphinx
	select @allow_sync_tran_id = 0
			,@autogen_sync_procs_id = 0
			,@allow_queued_tran_id = 0
			,@qv_replication = '2745196162'
			,@qv_replication_unlimited = 0
	
	/*
	** The default value for TRAN publication is always 72 hours
	*/
	if @retention is NULL
	BEGIN
		RAISERROR(20081, 16, -1, 'retention')
		RETURN (1)
	END
	
    /*
    **  A @retention value of zero means an infinite retention period
    */
	if @retention < 0
	BEGIN
		RAISERROR (20050, 16, -1, 1)
        RETURN(1)
	END

    SELECT @publish_bit         = 32
    SELECT @mergepublish_bit    = 4

    /*
    ** Security Check
    */

    exec @retcode = dbo.sp_MSreplcheck_publish
    if @@ERROR <> 0 or @retcode <> 0
        return(1)

    /*
    ** Check to see if the database has been activated for publication.
    */

    IF (SELECT category & 1
          FROM master..sysdatabases
         WHERE name = DB_NAME() collate database_default) = 0

    BEGIN
        RAISERROR (14013, 16, -1)
        RETURN (1)
    END

    IF @taskid <> 0
    BEGIN
        -- No longer supported
        RAISERROR (21023, 16, -1,'@taskid')
        RETURN(1)
    END

    /*
    ** Parameter Check: @publication.
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

    /*
    **  Check if the publication already exists.
    **  1. Check transaction-level publications
    **  2. Check merge publications
    */

    IF EXISTS (SELECT * FROM syspublications WHERE name = @publication)
        BEGIN
            RAISERROR (14016, 16, -1, @publication)
            RETURN (1)
        END
    
    if (select category & @mergepublish_bit from master..sysdatabases where name = DB_NAME() collate database_default) <> 0
        begin
            EXEC @retcode = dbo.sp_helpmergepublication @publication, @found output

            IF @@ERROR <> 0 OR @retcode <> 0
            BEGIN
                RETURN (1)
            END

            IF @found <> 0 
            BEGIN
                RAISERROR (20025, 16, -1, @publication)
                RETURN (1)
            END
        end

    /*
    ** Get distribution server information for remote RPC
    ** agent verification.
    */
    EXEC @retcode = dbo.sp_helpdistributor @rpcsrvname = @distributor OUTPUT,
                 @distribdb = @distribdb OUTPUT

    IF @@error <> 0 OR @retcode <> 0
        BEGIN
        RAISERROR (14071, 16, -1)
            RETURN (1)
    END


    /*
    ** Parameter Check: @sync_method
    ** The synchronization method must be one of the following:
    **
    **      0  [bcp] native
    **      1  [bcp] character
	**		2  dump database
	**		3  concurrent
	**		4  concurrent character
    */

    SELECT @sync_method = LOWER(@sync_method collate SQL_Latin1_General_CP1_CS_AS)										

    IF @sync_method IS NULL OR @sync_method NOT IN ('native', 'character', 'bcp native', 'bcp character', 'dump database', 'concurrent', 'concurrent_c')
        BEGIN
            RAISERROR (14014, 16, -1)
            RETURN (1)
        END

	IF @sync_method = 'concurrent_c'
		SELECT @smid = 4
	ELSE IF @sync_method = 'concurrent'
		SELECT @smid = 3
	ELSE IF @sync_method = 'dump database'
	begin
		SELECT @smid = 2				   
		select @backward_comp_level = 40 -- not sure if we are using this, but has to be shiloh feature
	end
    ELSE IF @sync_method IN ('character', 'bcp character')
        SELECT @smid = 1
    ELSE 
        SELECT @smid = 0

    /*
    ** Parameter Check: @repl_freq.
    ** Make sure that the replication frequency is one of the following:
    **
    **  id  frequency
    **  ==  ==========
    **   0  continuous
    **   1  snapshot
    */

    SELECT @repl_freq = LOWER(@repl_freq collate SQL_Latin1_General_CP1_CS_AS)
    IF @repl_freq IS NULL OR @repl_freq NOT IN ('continuous', 'snapshot')
        BEGIN
            RAISERROR (14015, 16, -1)
            RETURN (1)
        END

    IF @repl_freq = 'snapshot' SELECT @rfid = 1
    ELSE SELECT @rfid = 0

    -- disable tran publishing on REPLICATION_LIMITED sku
	exec @qv_value_replication = master.dbo.sp_MSinstance_qv @qv_replication 	
	if (@rfid = 0) and ( @qv_value_replication != @qv_replication_unlimited ) 
    begin
        raiserror(21108, 16, -1)
        return (1)
    end

    /*
    ** Parameter Check:  @restricted.
    */

    IF (@restricted IS NULL) OR (LOWER(@restricted collate SQL_Latin1_General_CP1_CS_AS) NOT IN ('true', 'false'))
        BEGIN
            RAISERROR (14017, 16, -1)
            RETURN (1)
        END

    /*
    ** Restricted publications are no longer supported
    */
    IF LOWER(@restricted collate SQL_Latin1_General_CP1_CS_AS) = 'true'
    BEGIN
        RAISERROR (14147, 16, -1)
        RETURN(1)
    END

    /*
    ** Parameter Check:  @status.
    ** The @status value can be:
    **
    **      statid  status
    **      ======  ========
    **           0  inactive
    **           1  active
    */

    IF @status IS NULL OR LOWER(@status collate SQL_Latin1_General_CP1_CS_AS) NOT IN ('inactive', 'active')
        BEGIN
            RAISERROR (14012, 16, -1)
            RETURN (1)
        END

    IF LOWER(@status collate SQL_Latin1_General_CP1_CS_AS) = 'active' 
	begin
		SELECT @statid = 1
	end
    ELSE 
	begin
		SELECT @statid = 0
	end

    /*
    ** Parameter Check:  @independent_agent.
    */

    IF @independent_agent IS NULL OR LOWER(@independent_agent collate SQL_Latin1_General_CP1_CS_AS) NOT IN ('true', 'false')
        BEGIN
            RAISERROR (14148, 16, -1, '@independent_agent')
            RETURN (1)
        END

    IF LOWER(@independent_agent collate SQL_Latin1_General_CP1_CS_AS) = 'true' SELECT @independent_agent_id = 1
    ELSE SELECT @independent_agent_id = 0

    /*
    ** Parameter Check:  @immediate_sync.
    */

    IF @immediate_sync IS NULL OR LOWER(@immediate_sync collate SQL_Latin1_General_CP1_CS_AS) NOT IN ('true', 'false')
        BEGIN
            RAISERROR (14148, 16, -1, '@immediate_sync')
            RETURN (1)
        END

    IF LOWER(@immediate_sync collate SQL_Latin1_General_CP1_CS_AS) = 'true' SELECT @immediate_sync_id = 1
    ELSE SELECT @immediate_sync_id = 0

    /*
    ** Parameter Check:  @enabled_for_internet.
    */

    IF @enabled_for_internet IS NULL OR LOWER(@enabled_for_internet collate SQL_Latin1_General_CP1_CS_AS) NOT IN ('true', 'false')
        BEGIN
            RAISERROR (14148, 16, -1, '@enabled_for_internet')
            RETURN (1)
        END

    IF LOWER(@enabled_for_internet collate SQL_Latin1_General_CP1_CS_AS) = 'true' SELECT @enabled_for_internet_id = 1
    ELSE SELECT @enabled_for_internet_id = 0

    IF @enabled_for_internet_id = 1 AND (@alt_snapshot_folder IS NULL OR
        @alt_snapshot_folder = N'')
        BEGIN
            RAISERROR (21159, 16, -1)
            RETURN (1) 
        END

    /*
    ** Parameter Check:  @allow_push.
    */

    IF @allow_push IS NULL OR LOWER(@allow_push collate SQL_Latin1_General_CP1_CS_AS) NOT IN ('true', 'false')
        BEGIN
            RAISERROR (14148, 16, -1, '@allow_push')
            RETURN (1)
        END
    IF LOWER(@allow_push collate SQL_Latin1_General_CP1_CS_AS) = 'true' SELECT @allow_push_id = 1
    ELSE SELECT @allow_push_id = 0

    /*
    ** Parameter Check:  @allow_pull.
    */

    IF @allow_pull IS NULL OR LOWER(@allow_pull collate SQL_Latin1_General_CP1_CS_AS) NOT IN ('true', 'false')
        BEGIN
            RAISERROR (14148, 16, -1, '@allow_pull')
            RETURN (1)
        END
    IF LOWER(@allow_pull collate SQL_Latin1_General_CP1_CS_AS) = 'true' SELECT @allow_pull_id = 1
    ELSE SELECT @allow_pull_id = 0

    /*
    ** Parameter Check:  @allow_anonymous.
    */

    IF @allow_anonymous IS NULL OR LOWER(@allow_anonymous collate SQL_Latin1_General_CP1_CS_AS) NOT IN ('true', 'false')
        BEGIN
            RAISERROR (14148, 16, -1, '@allow_anonymous')
            RETURN (1)
        END
    IF LOWER(@allow_anonymous collate SQL_Latin1_General_CP1_CS_AS) = 'true' SELECT @allow_anonymous_id = 1
    ELSE SELECT @allow_anonymous_id = 0

    /* Immediate_sync publications have to be independent_agent */
    IF @immediate_sync_id = 1 AND @independent_agent_id = 0
    BEGIN
            RAISERROR (21022, 16, -1)
            RETURN (1)
    END

    /*
    ** Parameter Check:  @add_to_active_directory.
    */

    if LOWER(@add_to_active_directory collate SQL_Latin1_General_CP1_CS_AS) NOT IN ('true', 'false')
        BEGIN
            RAISERROR (14148, 16, -1, '@add_to_active_directory')
            RETURN (1)
        END

   /* Is AD supported? */
   DECLARE @retval  INT
   EXECUTE @retval = master.dbo.xp_MSADEnabled
   if (@retval <> 0) and LOWER(@add_to_active_directory collate SQL_Latin1_General_CP1_CS_AS)='true'
   begin
		RAISERROR(21253, 16, -1)
		RETURN (1)
   end

    /* 
    ** Non-immediate sync do not support anonymous subscriptions.
    */
    IF @immediate_sync_id = 0 AND @allow_anonymous_id = 1
    BEGIN
            RAISERROR (20011, 16, -1)
            RETURN (1)
    END

    -- SyncTran
    /*
    ** Parameter Check:  @allow_sync_tran
    */

    IF @allow_sync_tran IS NULL OR LOWER(@allow_sync_tran collate SQL_Latin1_General_CP1_CS_AS) NOT IN ('true', 'false')
    BEGIN
        RAISERROR (14148, 16, -1, '@allow_sync_tran')
        RETURN (1)
    END

    /*
    ** Parameter Check:  @allow_queued_tran
    */

    IF @allow_queued_tran IS NULL OR LOWER(@allow_queued_tran collate SQL_Latin1_General_CP1_CS_AS) NOT IN ('true', 'false')
    BEGIN
        RAISERROR (14148, 16, -1, '@allow_queued_tran')
        RETURN (1)
    END

    IF LOWER(@allow_sync_tran collate SQL_Latin1_General_CP1_CS_AS) = 'true' 
    BEGIN
		-- If we are doing sync tran, we need independent agents
		-- override the user input
        SELECT @allow_sync_tran_id = 1
			,@independent_agent = 'true'
			,@independent_agent_id = 1
			,@backward_comp_level = 40 -- immediate update needs to have the new sp_addsynctriggers stored proc
    END
    ELSE 
    BEGIN
        SELECT @allow_sync_tran_id = 0
    END

    IF LOWER(@allow_queued_tran collate SQL_Latin1_General_CP1_CS_AS) = 'true' 
    BEGIN
		-- If we are doing queued tran, we need independent agents
		-- override the user input
        SELECT @allow_queued_tran_id = 1
			,@independent_agent = 'true'
			,@independent_agent_id = 1
			,@backward_comp_level = 40 -- queued compenents not avaliable prior to shiloh
    END
    ELSE 
    BEGIN
        SELECT @allow_queued_tran_id = 0
    END

    --Parameter Check:  @autogen_sync_procs
    IF @autogen_sync_procs IS NULL OR LOWER(@autogen_sync_procs collate SQL_Latin1_General_CP1_CS_AS) NOT IN ('true', 'false')
    BEGIN								 
        RAISERROR (14148, 16, -1, '@autogen_sync_procs')
        RETURN (1)
    END

	--
	-- For publications that allow updating subscribers (immediate/queued)
	-- this option has to be true at all times, for others
	-- it should be false. This flag is not of any value currently
	-- as we do not have any provision for accepting custom generated
	-- synctan proc names for an article. For now, we will override
	-- the user supplied value
	--
	select @autogen_sync_procs_id = case 
		when (@allow_sync_tran_id = 0 and @allow_queued_tran_id = 0) then 0
		else 1
	end
	
    -- Portable snapshot
    IF @snapshot_in_defaultfolder IS NULL OR LOWER(@snapshot_in_defaultfolder collate SQL_Latin1_General_CP1_CS_AS) NOT IN ('true', 'false')
    BEGIN
        RAISERROR (14148, 16, -1, '@snapshot_in_defaultfolder')
        RETURN (1)
    END
    
    IF LOWER(@snapshot_in_defaultfolder collate SQL_Latin1_General_CP1_CS_AS) = 'true'
    BEGIN
        SELECT @snapshot_in_defaultfolder_bit = 1
    END
    ELSE
    BEGIN
        SELECT @snapshot_in_defaultfolder_bit = 0
    END

    -- Pre/Post snapshot commands
    -- If @sync_method is character mode bcp, this would indicate that
    -- this publication may support non-SQL Server subscribers. In this 
    -- case, pre- and post- snapshot commands are not allowed.
    IF @smid = 1 AND 
        ((@pre_snapshot_script IS NOT NULL AND @pre_snapshot_script <> '') OR
         (@post_snapshot_script IS NOT NULL AND @post_snapshot_script <> ''))
    BEGIN
        RAISERROR (21151, 16, -1)
        RETURN (1)
    END
    
    -- Parameter check - @compress_snapshot
    -- @compress_snapshot can be 1 if @alt_snapshot_folder is non-null
    IF LOWER(@compress_snapshot collate SQL_Latin1_General_CP1_CS_AS) NOT IN ('true', 'false')
    BEGIN
        RAISERROR (14148, 16, -1, '@compress_snapshot')
        RETURN (1)
    END
    
    IF LOWER(@compress_snapshot collate SQL_Latin1_General_CP1_CS_AS) = 'true'
    BEGIN
        SELECT @compress_snapshot_bit = 1
    END
    ELSE
    BEGIN
        SELECT @compress_snapshot_bit = 0
    END

    -- Snapshot compression can only be enabled if an alternate 
    -- snapshot generation folder exists or the publication
    -- is enabled for internet.
    IF (@compress_snapshot_bit = 1 AND 
        (@alt_snapshot_folder IS NULL OR @alt_snapshot_folder = N'') AND
        (LOWER(@enabled_for_internet collate SQL_Latin1_General_CP1_CS_AS) = N'false'))
    BEGIN
        RAISERROR (21157, 16, -1)
        RETURN (1)
    END    

    -- Parameter check: ftp_address
    -- If the publication is enabled for internet, ftp_address cannot be null
    IF @enabled_for_internet_id = 1 AND (@ftp_address IS NULL OR @ftp_address = N'')
    BEGIN
        RAISERROR (21158, 16, -1)
        RETURN (1)
    END     

    -- Parameter check: ftp_port
    IF @ftp_port IS NULL
    BEGIN
        RAISERROR (21160, 16, -1)
    END

	-- Parameter check : DTS
	declare @allow_dts_id bit
    IF @allow_dts IS NULL OR LOWER(@allow_dts collate SQL_Latin1_General_CP1_CS_AS) NOT IN ('true', 'false')
    BEGIN
        RAISERROR (14148, 16, -1, '@allow_dts')
        RETURN (1)
    END

    -- Encrypt ftp password before putting it into the syspublications
    -- table if one is provided
    SELECT @enc_ftp_password = NULL
    IF @ftp_password IS NOT NULL
    BEGIN
        SELECT @enc_ftp_password = @ftp_password 
        EXEC @retcode = master.dbo.xp_repl_encrypt @enc_ftp_password OUTPUT
        IF @retcode <> 0
        BEGIN
            RETURN (1)
        END
    END    

    IF LOWER(@allow_dts collate SQL_Latin1_General_CP1_CS_AS) = 'true' SELECT @allow_dts_id = 1
    ELSE SELECT @allow_dts_id = 0

	-- To allow DTS, the publication has to be
	-- 1. independent agent
	-- 2. char bcp

	if @allow_dts_id = 1
	begin
		if @smid NOT IN ( 1, 4 )
		begin
			-- 'The publication has to be in char bcp mode.'
			raiserror(21172, 16, -1)
			return(1)
		end
		if @independent_agent_id = 0
		begin
			-- 'The publication has to be independent agent.'
			raiserror(21173, 16, -1)
			return(1)		
		end
		if @allow_sync_tran_id = 1 or @allow_queued_tran_id = 1
		begin
			raiserror(21180, 16, -1)
			return(1)
		end
	end

	declare @allow_subscription_copy_id bit
    IF LOWER(@allow_subscription_copy collate SQL_Latin1_General_CP1_CS_AS) = 'true' SELECT @allow_subscription_copy_id = 1
    ELSE SELECT @allow_subscription_copy_id = 0

	-- To allow subscription copy, the publication has to be
	-- 1. immediate_sync
	if @allow_subscription_copy_id = 1
	begin
		if @immediate_sync_id <> 1
		begin
			raiserror(21210, 16, -1)
			return(1)
		end
	end

	--
	-- Check parameters for @conflict_policy, @centralized_conflicts, @conflict_retention
	-- for queued publications
	--
	if (@allow_queued_tran_id = 1)
	begin
		--
		-- set default conflict_policy if required
		--
		if (@conflict_policy IS NULL)
		begin
			--
			-- if it is snapshot based, then the default policy is 'sub reinit'
			-- else the default policy is 'pub wins'
			--
			select @conflict_policy = case when (@rfid = 1) then 'sub reinit' 
										else 'pub wins' end
		end
		
		if (LOWER(@conflict_policy collate SQL_Latin1_General_CP1_CS_AS) = 'sub reinit')
			select @conflict_policy_id = 3
		else if (LOWER(@conflict_policy collate SQL_Latin1_General_CP1_CS_AS) = 'pub wins')
			select @conflict_policy_id = 1
		else if (LOWER(@conflict_policy collate SQL_Latin1_General_CP1_CS_AS) = 'sub wins')
			select @conflict_policy_id = 2
		else
		begin
			raiserror (21184, 16, 2, '@conflict_policy', 'sub reinit', 'pub wins', 'sub wins')
			return (1)
		end

		--
		-- Check snapshot permissible values
		--
		if ((@rfid = 1) and (@conflict_policy_id = 1))
		begin
			raiserror (21270, 16, 1, '@conflict_policy', @conflict_policy)
			return (1)
		end
		
		--
		-- set default centralized_conflicts if required
		--
		if (@centralized_conflicts IS NULL)
			select @centralized_conflicts = 'true'
		
		if (LOWER(@centralized_conflicts collate SQL_Latin1_General_CP1_CS_AS) = 'true')
			select @centralized_conflicts_bit = 1
		else if (LOWER(@centralized_conflicts collate SQL_Latin1_General_CP1_CS_AS) = 'false')
			select @centralized_conflicts_bit = 0
		else
		begin
			raiserror (14148, 16, -1, '@centralized_conflicts')
			return (1)
		end

		--
		-- Check snapshot permissible values
		--
		if ((@rfid = 1) and (@centralized_conflicts_bit = 0))
		begin
			raiserror (21270, 16, 1, '@centralized_conflicts', @centralized_conflicts)
			return (1)
		end
		
		if (@conflict_retention IS NULL)
			select @conflict_retention = 14
		else if (@conflict_retention < 0)
		begin
			raiserror(20050, 16, -1, 0)
			return (1)
		end

		if ((@queue_type IS NULL) or (LOWER(@queue_type collate SQL_Latin1_General_CP1_CS_AS) = 'sql'))
			select @queue_type_val = 2
		else if (LOWER(@queue_type collate SQL_Latin1_General_CP1_CS_AS) = 'msmq')
			select @queue_type_val = 1
		else
		begin
			raiserror (21184, 16, 3, '@queue_type', 'msmq', 'sql', 'NULL')
			return (1)
		end
	end

    /*
    ** Get distribution server information for remote RPC call.
    */
    EXECUTE @retcode = dbo.sp_helpdistributor @rpcsrvname = @distributor OUTPUT,
       @distribdb   = @distribdb OUTPUT
    IF @@ERROR <> 0 or @retcode <> 0
    BEGIN
        GOTO UNDO
    END

    /*
    **  Add publication to syspublications.
    */
    begin tran
    save TRAN sp_addpublication

    select @dbname = db_name()
    
    /*
    ** Construct Log Reader agent name.
    */

	declare @job_existing bit

    -- Create logreader task for the first log based or allow queued publication.
    -- We need logreader for queued publication to do idenity range management.
    IF  (@rfid = 0 or @allow_queued_tran_id = 1)  and NOT EXISTS 
        (SELECT * FROM syspublications where repl_freq = 0 or allow_queued_tran = 1) 
    BEGIN
		-- Clear repl dbtable fields. This will avoid unnecessary log scan in the 
		-- logreader at the first time it runs.
		--
		-- sp_droppublication will clear the fields when dropping the last publication, 
		-- however, it is after the transaction deleting syspublication table being
		-- committed, thus not guaranteed.
		-- 
		-- We also need this logic for upgraded 7.0 databases where we don't clear
		-- distbackuplsn and distlastlsn fields in unpublishing.
		--
		/* ensure we can get in as logreader */
	    exec @retcode = dbo.sp_replflush
        IF @@ERROR <> 0 or @retcode <> 0
            GOTO UNDO

		/* unmark all xacts marked for replication */
		exec @retcode = dbo.sp_repldone NULL, NULL, 0, 0, 1
        IF @@ERROR <> 0 or @retcode <> 0
            GOTO UNDO
    
	    /* release our hold on the db as logreader */
	    EXEC @retcode = dbo.sp_replflush
        IF @@ERROR <> 0 or @retcode <> 0
            GOTO UNDO

		-- Run checkpoint to make sp_repldone result durable (write repl dbtable fields
		-- into the checkpoint record).
		checkpoint
        IF @@ERROR <> 0
            GOTO UNDO


		if @logreader_job_name is null
			select @job_existing = 0
		else
			select @job_existing = 1

        /*
        ** Schedule Log Reader agent for the database
		** If @logreader_job_name is not null
        */
        SELECT @distproc = RTRIM(@distributor) + '.' + @distribdb +'.dbo.sp_MSadd_logreader_agent'

        EXECUTE @retcode = @distproc
			@name = @logreader_job_name,
            @publisher = @@SERVERNAME,
            @publisher_db = @dbname,
            @publication = 'ALL',  
            @local_job = 1,
			@job_existing = @job_existing 

        IF @@ERROR <> 0 or @retcode <> 0
            GOTO UNDO
    END            

    INSERT syspublications(description, name, repl_freq,
                           status, sync_method, snapshot_jobid, independent_agent,
                           immediate_sync, enabled_for_internet, 
                           allow_push, allow_pull, allow_anonymous, immediate_sync_ready,
                           -- SyncTran
                           allow_sync_tran, autogen_sync_procs, retention, allow_queued_tran,
                           snapshot_in_defaultfolder, alt_snapshot_folder, pre_snapshot_script, 
                           post_snapshot_script, compress_snapshot, ftp_address, ftp_port, 
                           ftp_subdirectory, ftp_login, ftp_password, allow_dts, 
						   allow_subscription_copy, centralized_conflicts, conflict_retention, 
						   conflict_policy, queue_type, backward_comp_level)

    VALUES (@description, @publication, @rfid, @statid, @smid, NULL, 
            @independent_agent_id, 
            @immediate_sync_id, @enabled_for_internet_id, @allow_push_id,
            @allow_pull_id, @allow_anonymous_id, 0,
            -- SyncTran
            @allow_sync_tran_id, @autogen_sync_procs_id, @retention, @allow_queued_tran_id,
            @snapshot_in_defaultfolder_bit, @alt_snapshot_folder, @pre_snapshot_script,
            @post_snapshot_script, @compress_snapshot_bit, @ftp_address, @ftp_port, 
            @ftp_subdirectory, @ftp_login, @enc_ftp_password, 
			@allow_dts_id, @allow_subscription_copy_id, @centralized_conflicts_bit, @conflict_retention, 
			@conflict_policy_id, @queue_type_val, @backward_comp_level)

    IF @@ERROR <> 0
    BEGIN
        RAISERROR (14018, 16, -1)
        GOTO UNDO
    END

    SELECT @pubid = @@IDENTITY

    DECLARE @false bit
    SELECT @false = 0

    DECLARE @null sysname
    SELECT @null = NULL

    /*
    ** Add the publication to the distributor side
    */
    SELECT @distproc = RTRIM(@distributor) + '.' + @distribdb + 
        '.dbo.sp_MSadd_publication'
    EXECUTE @retcode = @distproc
    @publisher = @@SERVERNAME,
    @publisher_db = @dbname,
    @publication = @publication,
    @publication_type = @rfid,
    @independent_agent = @independent_agent_id,
    @immediate_sync = @immediate_sync_id,
    @allow_push = @allow_push_id,
    @allow_pull = @allow_pull_id,
    @allow_anonymous = @allow_anonymous_id,
    @snapshot_agent = @null,
    @logreader_agent = @agentname,
    @description = @description,
    @retention = @retention,
	@sync_method = @smid,
	@allow_subscription_copy = @allow_subscription_copy_id,
	@allow_queued_tran = @allow_queued_tran_id,
	@queue_type = @queue_type_val

    IF @@ERROR <> 0 or @retcode <> 0
        BEGIN
            GOTO UNDO
        END

	if @qreader_job_name is not null
	begin
		--
		-- Schedule Queue Reader agent for the database
		--
		SELECT @distproc = RTRIM(@distributor) + '.' + @distribdb +'.dbo.sp_MSadd_qreader_agent'
		EXECUTE @retcode = @distproc @name = @qreader_job_name
		IF @@ERROR <> 0 or @retcode <> 0
		GOTO UNDO
	end	

    -- Populate the initial list.
	exec @retcode = dbo.sp_grant_publication_access 
		@publication = @publication,
		@login = null,
		@reserved = 'init'
	IF @@error <> 0 OR @retcode <> 0
		GOTO UNDO

    COMMIT TRAN

	declare @returnstring nvarchar(512) 
	set @returnstring = N''
	if LOWER(@add_to_active_directory collate SQL_Latin1_General_CP1_CS_AS)='true'
    begin
    	--no error checking needed here.    
		create table #guid_name_for_active_directory(ad_guidname sysname collate database_default null)
		if @@ERROR<>0
		begin
    		goto FAILURE 					
		end
		insert into #guid_name_for_active_directory exec @retcode=master.dbo.sp_ActiveDirectory_Obj 'CREATE', 'PUBLICATION', @publication, @dbname
		if @retcode <> 0 or @@ERROR<>0
    	begin
			set @returnstring = (select TOP 1 ad_guidname from #guid_name_for_active_directory)
    		goto FAILURE 					
	   	end
    	select TOP 1 @ad_guidname = ad_guidname from #guid_name_for_active_directory
    	if @ad_guidname is not NULL
    	begin
    		update syspublications set ad_guidname=@ad_guidname where pubid=@pubid
    		if @@ERROR<>0
    			goto FAILURE
    	end
		drop table #guid_name_for_active_directory
    end
	RETURN(0)
FAILURE:
	drop table #guid_name_for_active_directory
	if @returnstring is NULL
		select @returnstring = N''
	raiserror(21363, 16, -1, @publication, @returnstring)
    return (1)   
UNDO:
    IF @@TRANCOUNT > 0
    begin
        ROLLBACK TRAN sp_addpublication
        COMMIT TRAN   
    end
    return 1
END
go
 
EXEC dbo.sp_MS_marksystemobject sp_addpublication
GO

print ''
print 'Creating procedure sp_changepublication'
go

CREATE PROCEDURE sp_changepublication (
    @publication sysname = NULL,        /* Publication name */
    @property nvarchar(50) = NULL,           /* The property to change */
    @value nvarchar(255) = NULL,              /* The new property value */
	@force_invalidate_snapshot bit = 0,	/* Force invalidate existing snapshot */
	@force_reinit_subscription bit = 0	/* Force reinit subscription */
) 
AS
BEGIN
    SET NOCOUNT ON

    /*
    ** Declarations.
    */

	DECLARE @cmd nvarchar(255)
			,@cmd2 nvarchar(255)
			,@pubid int
			,@replfreqid tinyint
			,@retcode int
			,@statusid tinyint
			,@syncmethodid tinyint
			,@db_name	sysname
			,@distributor sysname
			,@distproc nvarchar (255)
			,@subscribed int    
			,@virtual_id smallint
			,@prev_value_bit bit
			,@value_bit bit
			,@allow_anonymous bit
			,@push int
			,@pull int
			,@independent_agent bit
			,@immediate_sync bit
			,@distribdb sysname
			,@dbname sysname
			,@taskid int
			,@add_virtual_back bit
			,@alt_snapshot_folder nvarchar(255)
			,@enabled_for_internet bit
			,@ftp_address sysname
			,@snapshot_in_defaultfolder bit
			,@allow_dts bit
			,@in_ActiveD	bit
			,@ad_guidname	sysname
			,@enc_ftp_password nvarchar(524)
			,@conflict_policy_id int
			,@centralized_conflicts_bit bit
			,@conflict_retention int
			,@queue_type int
			,@allow_sync_tran bit
			,@allow_queued_tran bit
			
	SELECT @add_virtual_back = 0
			,@push = 0
			,@pull = 1
			,@alt_snapshot_folder = NULL
			,@subscribed = 1
			,@virtual_id = -1

    /*
    ** Security Check
    */

    exec @retcode = dbo.sp_MSreplcheck_publish
    if @@ERROR <> 0 or @retcode <> 0
        return(1)

    /*
    ** Check to see if the database has been activated for publication.
    */

    IF (SELECT category & 1
          FROM master..sysdatabases
         WHERE name = DB_NAME() collate database_default) = 0

    BEGIN
        RAISERROR (14013, 16, -1)
        RETURN (1)
    END

    select @db_name=db_name()
    
    /*
    ** Parameter Check:  @property.
    ** If the @property parameter is NULL, print the options.
    */

    IF @property IS NULL
        BEGIN
            CREATE TABLE #tab1 (properties sysname collate database_default not null)
            INSERT INTO #tab1 VALUES ('description')
            --INSERT INTO #tab1 VALUES ('taskid')
            INSERT INTO #tab1 VALUES ('sync_method')
            INSERT INTO #tab1 VALUES ('status')
            INSERT INTO #tab1 VALUES ('repl_freq')
            INSERT INTO #tab1 VALUES ('independent_agent')
            INSERT INTO #tab1 VALUES ('immediate_sync')
            INSERT INTO #tab1 VALUES ('enabled_for_internet')
            INSERT INTO #tab1 VALUES ('allow_push')
            INSERT INTO #tab1 VALUES ('allow_pull')
            INSERT INTO #tab1 VALUES ('allow_anonymous')
            INSERT INTO #tab1 VALUES ('retention')
            INSERT INTO #tab1 VALUES ('snapshot_in_defaultfolder')
            INSERT INTO #tab1 VALUES ('alt_snapshot_folder')
            INSERT INTO #tab1 VALUES ('pre_snapshot_script')
            INSERT INTO #tab1 VALUES ('post_snapshot_script')
            INSERT INTO #tab1 VALUES ('compress_snapshot')
            INSERT INTO #tab1 VALUES ('ftp_address')
            INSERT INTO #tab1 VALUES ('ftp_port')
            INSERT INTO #tab1 VALUES ('ftp_subdirectory')
            INSERT INTO #tab1 VALUES ('ftp_login')
            INSERT INTO #tab1 VALUES ('ftp_password')
            INSERT INTO #tab1 VALUES ('allow_subscription_copy')
            INSERT INTO #tab1 VALUES ('conflict_policy')
            INSERT INTO #tab1 VALUES ('centralized_conflicts')
            INSERT INTO #tab1 VALUES ('conflict_retention')
            INSERT INTO #tab1 VALUES ('queue_type')
            INSERT INTO #tab1 VALUES ('publish_to_ActiveDirectory')
            PRINT ''
            SELECT * FROM #tab1
            RETURN (0)
        END

    /*
    ** Parameter Check:  @publication.
    ** Make sure that the publication exists.
    */

    IF @publication IS NULL
        BEGIN
            RAISERROR (14043, 16, -1, '@publication')
            RETURN (1)
        END

    EXECUTE @retcode = dbo.sp_validname @publication

    IF @@ERROR <> 0 OR @retcode <> 0
    RETURN (1)

    SELECT @allow_anonymous = allow_anonymous, @pubid = pubid, 
    	@ad_guidname=ad_guidname, --with NULL value if this publication is not in AD
    	@replfreqid = repl_freq,
        @immediate_sync = immediate_sync,
        @independent_agent = independent_agent,
        @syncmethodid = sync_method,
        @alt_snapshot_folder = alt_snapshot_folder,
        @enabled_for_internet = enabled_for_internet,
        @ftp_address = ftp_address,
		@allow_dts = allow_dts
		,@queue_type = queue_type
        ,@snapshot_in_defaultfolder = snapshot_in_defaultfolder
		,@in_ActiveD = case when ad_guidname is NULL then 0 else 1 end 
		,@allow_sync_tran = allow_sync_tran
		,@allow_queued_tran = allow_queued_tran
        FROM syspublications 
        WHERE name = @publication

    IF @pubid IS NULL
        BEGIN
            RAISERROR (20026, 11, -1, @publication)
            RETURN (1)
        END
    ELSE

    /*
    ** Parameter Check:  @property.
    ** Check to make sure that @property is a valid property in
    ** syspublications.
    */

    IF LOWER(@property collate SQL_Latin1_General_CP1_CS_AS) NOT IN ( 'taskid','description', 'sync_method',
     'status', 'repl_freq','immediate_sync', 'independent_agent', 
     'enabled_for_internet', 'allow_push', 'allow_pull', 'allow_anonymous', 'retention',
     'snapshot_in_defaultfolder', 'alt_snapshot_folder', 'pre_snapshot_script', 'post_snapshot_script', 
     'compress_snapshot', 'ftp_address', 'ftp_port', 'ftp_subdirectory',
     'ftp_login', 'ftp_password','allow_subscription_copy','conflict_policy',
     'centralized_conflicts','conflict_retention','queue_type','publish_to_activedirectory')
        BEGIN
            RAISERROR (21183, 16, -1, @property)
            RETURN (1)
        END

    /*
    ** Parameter Check:
    ** If sync_method of the publication is character mode (an indication that it supports
    ** third party Subscribers), pre/post-snapshot setting must be null   
    **
    */
    IF @syncmethodid = 1 
    BEGIN
        IF (LOWER(@property collate SQL_Latin1_General_CP1_CS_AS) = 'pre_snapshot_script' OR
            LOWER(@property collate SQL_Latin1_General_CP1_CS_AS) = 'post_snapshot_script') AND
            @value IS NOT NULL AND @value <> ''
        BEGIN
            RAISERROR (21151, 16, -1)
            RETURN (1)
        END   
    END

    /*
    ** Parameter Check:
    ** If the Publication's alt_snapshot_folder setting is null, 
    ** snapshot compression cannot be enabled
    */
    IF (@alt_snapshot_folder IS NULL OR @alt_snapshot_folder = '') 
        AND LOWER(@property collate SQL_Latin1_General_CP1_CS_AS) = 'compress_snapshot'
        AND LOWER(@value collate SQL_Latin1_General_CP1_CS_AS) = 'true'   
    BEGIN
        RAISERROR (21157, 16, -1)        
        RETURN(1)
    END

    /* 
    ** Parameter Check:
    ** If enabled_for_internet is set to true, the publication must have a non-null
    ** ftp_address.
    */
    IF LOWER(@property collate SQL_Latin1_General_CP1_CS_AS) = N'enabled_for_internet' AND
       LOWER(@value collate SQL_Latin1_General_CP1_CS_AS) = N'true' AND 
       (@ftp_address IS NULL OR @ftp_address = N'')
    BEGIN
        RAISERROR(21158, 16, -1)
        RETURN (1)
    END

    /*
    ** .. and ftp_address cannot be null if the publication is enabled for 
    ** internet.
    */
/*
    IF @enabled_for_internet = 1 AND
      (LOWER(@property collate SQL_Latin1_General_CP1_CS_AS) = N'ftp_address'
        AND (@value IS NULL OR @value = N''))
    BEGIN
        RAISERROR(21158, 16, -1)
        RETURN (1)
    END
*/
    /*
    ** .. and 'alternate snapshot folder' is not null
    **
    */
    IF LOWER(@property collate SQL_Latin1_General_CP1_CS_AS) = N'enabled_for_internet' AND
        LOWER(@value collate SQL_Latin1_General_CP1_CS_AS) = N'true' AND
       (@alt_snapshot_folder IS NULL OR @alt_snapshot_folder = N'')
    BEGIN
        RAISERROR(21159, 16, -1)
        RETURN (1)
    END 

    /* 
    ** Parameter Check:
    ** If the publication is enabled for internet, the publication must
    ** have a non-null alternate snapshot folder and the 
    ** snapshot_in_defaultfolder property must be 0.
    */
/*
    IF @enabled_for_internet = 1 AND 
       ((LOWER(@property collate SQL_Latin1_General_CP1_CS_AS) = N'alt_snapshot_folder'
        AND (@value IS NULL OR @value = N'')))
    BEGIN
        RAISERROR(21159, 16, -1)
        RETURN (1)
    END  
*/

    /*
    ** Parameter Check:
    ** 'ftp_port' cannot be null
    */
    IF LOWER(@property collate SQL_Latin1_General_CP1_CS_AS) = N'ftp_port' AND @value IS NULL
    BEGIN
        RAISERROR (14043, 16, -1, @property)
        RETURN (1)
    END

	-- Check to see if there are snapshot and subscription needs to be reinited.
	declare @need_new_snapshot bit
		,@need_reinit_subscription bit
		,@active tinyint

	select @active = 2
	select @need_new_snapshot = 0
	select @need_reinit_subscription = 0

	if LOWER(@property collate SQL_Latin1_General_CP1_CS_AS) in ('snapshot_in_defaultfolder', 'alt_snapshot_folder',
		'pre_snapshot_script', 'post_snapshot_script', 'compress_snapshot', 
		'ftp_address','ftp_port','ftp_subdirectory','ftp_login','ftp_password',
		'enabled_for_internet')
	begin
		select @need_new_snapshot = 1
	end
	else if LOWER(@property collate SQL_Latin1_General_CP1_CS_AS) = 'sync_method'
	begin
		-- If changing to or from concurrent, must reinit subscription.
		if EXISTS( select * from syspublications sp
			where sp.pubid = @pubid and 
			(sp.sync_method in (3,4) or LOWER(@value collate SQL_Latin1_General_CP1_CS_AS) in ('concurrent', 'concurrent_c'))) 
		BEGIN
			select @need_new_snapshot = 1
			select @need_reinit_subscription = 1			
		END
		else
			select @need_new_snapshot = 1
	end
	else if LOWER(@property collate SQL_Latin1_General_CP1_CS_AS) = 'repl_freq'
	BEGIN
		select @need_new_snapshot = 1
		select @need_reinit_subscription = 1			
	END
	
	-- Have to call this stored procedure to invalidate existing snapshot or reint
	-- subscriptions if needed
	EXECUTE @retcode  = dbo.sp_MSreinit_article
		@publication = @publication, 
		@need_new_snapshot = @need_new_snapshot,
		@need_reinit_subscription = @need_reinit_subscription
		,@force_invalidate_snapshot = @force_invalidate_snapshot	/* Force invalidate existing snapshot */
		,@force_reinit_subscription = @force_reinit_subscription	/* Force reinit subscription */
		,@check_only = 1
	IF @@ERROR <> 0 OR @retcode <> 0
		return (1)

    /*
    ** Change the property.
    */
    begin tran
    save TRAN sp_changepublication

    IF LOWER(@property collate SQL_Latin1_General_CP1_CS_AS) ='description'
        BEGIN
            UPDATE syspublications SET description = @value
                WHERE pubid = @pubid
            IF @@ERROR <> 0 GOTO UNDO
        END
        
    IF LOWER(@property collate SQL_Latin1_General_CP1_CS_AS) ='retention'
        BEGIN
        	if @value is NULL 
        		BEGIN
        			RAISERROR(20081, 16, -1, @property)
        			GOTO UNDO
        		END
        		
            UPDATE syspublications SET retention = convert(int, @value)
                WHERE pubid = @pubid
            IF @@ERROR <> 0 GOTO UNDO
        END
   

   if LOWER(@property collate SQL_Latin1_General_CP1_CS_AS) = 'publish_to_activedirectory'
   		BEGIN
        if LOWER(@value collate SQL_Latin1_General_CP1_CS_AS) NOT IN ('true', 'false')
        	BEGIN
            	RAISERROR (14137, 16, -1)
            	GOTO UNDO
        	END

	    /* Is AD supported? */
	    DECLARE @retval  INT
	    EXECUTE @retval = master.dbo.xp_MSADEnabled
	    if (@retval <> 0)
	    begin
			RAISERROR(21254, 16, -1, @publication)
			RETURN (1)
	    end

   		if @in_ActiveD=0 and LOWER(@value collate SQL_Latin1_General_CP1_CS_AS)='true'
	   		BEGIN
				create table #guid_name_for_active_directory(ad_guidname sysname collate database_default null)
				if @@ERROR<>0
				begin
		    		raiserror(21363, 16, -1, @publication, N'')
    				GOTO UNDO									
				end
				insert into #guid_name_for_active_directory exec @retcode=master.dbo.sp_ActiveDirectory_Obj 'CREATE', 'PUBLICATION', @publication, @db_name
				if @retcode <> 0 or @@ERROR<>0
		    	begin
					declare @errorstring nvarchar(512)
					select @errorstring = (select TOP 1 ad_guidname from #guid_name_for_active_directory) 
					drop table #guid_name_for_active_directory
					if @errorstring is NULL
						select @errorstring=N''
		    		raiserror(21363, 16, -1, @publication, @errorstring)
    				GOTO UNDO					
	   			end
	    		select TOP 1 @ad_guidname = ad_guidname from #guid_name_for_active_directory

    			if @ad_guidname is not NULL
	    		begin
    				update syspublications set ad_guidname=@ad_guidname where pubid=@pubid
    				if @@ERROR<>0
    				begin
						drop table #guid_name_for_active_directory
			    		raiserror(21363, 16, -1, @publication, N'')
    					GOTO UNDO					
    				end
	    		end
	    		drop table #guid_name_for_active_directory
   			END
   		else if @in_ActiveD=1 and LOWER(@value collate SQL_Latin1_General_CP1_CS_AS)='false'
   			BEGIN
				exec @retcode=master.dbo.sp_ActiveDirectory_Obj 'DELETE', 'PUBLICATION', @publication, @db_name, @ad_guidname
				if @@ERROR<>0 or @retcode<>0
				begin
					raiserror(21369, 16, -1, @publication)	
					goto UNDO
				end
				update syspublications set ad_guidname=NULL where pubid=@pubid
				if @@ERROR<>0
				begin
					raiserror(21369, 16, -1, @publication)	
					goto UNDO
				end
   			END
	   END

    IF LOWER(@property collate SQL_Latin1_General_CP1_CS_AS) = 'taskid'
       BEGIN
            -- No longer supported
            RAISERROR (21023, 16, -1,'@taskid')
            goto UNDO
       END

    IF LOWER(@property collate SQL_Latin1_General_CP1_CS_AS) = 'sync_method'
        BEGIN

            /*
            ** Check for a valid synchronization method.
            */

            IF LOWER(@value collate SQL_Latin1_General_CP1_CS_AS) NOT IN ('native', 'character', 'bcp native', 'bcp character', 'concurrent', 'concurrent_c')
                BEGIN
                    RAISERROR (14014, 16, -1)
                    GOTO UNDO
                END

	        /*
            ** Determine the integer value for the sync_method.
            */

            IF LOWER(@value collate SQL_Latin1_General_CP1_CS_AS) IN ('native', 'bcp native')
                SELECT @syncmethodid = 0
            ELSE IF LOWER(@value collate SQL_Latin1_General_CP1_CS_AS) IN ('character', 'bcp character')
                SELECT @syncmethodid = 1
			ELSE IF LOWER(@value collate SQL_Latin1_General_CP1_CS_AS) IN ( 'concurrent' )
				SELECT @syncmethodid = 3
			ELSE IF LOWER(@value collate SQL_Latin1_General_CP1_CS_AS) IN ( 'concurrent_c' )
				SELECT @syncmethodid = 4

			if @syncmethodid NOT IN (1,4) and @allow_dts = 1
			begin
				raiserror(21172, 16, -1)
				GOTO UNDO
			end

			-- Non sql subscribers can only use char bcp (not concurrent)
			if @syncmethodid <> 1
			begin
				IF EXISTS( select * from syspublications sp, syssubscriptions ss, 
							sysarticles sa, master..sysservers srv
						   where sp.pubid = @pubid 
						   and sp.pubid = sa.pubid
						   and sa.artid = ss.artid
						   and srv.srvid = ss.srvid
						   and srv.srvproduct = N'MSREPL-NONSQL' collate database_default)
				BEGIN
					RAISERROR(20593, 16, -1, @publication )
					GOTO UNDO
				END			 
			end

			if exists (select * from syspublications where
				pubid = @pubid and
				sync_method <> @syncmethodid)
			begin
				/*
				** Update the publication with the new synchronization method.
				*/

				/*
				** If we switch to character mode bcp (an indication that this 
				** publication may support non-SQL Server subscribers) for this 
				** publication, the pre/post snapshot commands settings should be
				** nullified  
				*/    
				IF @syncmethodid = 1
				BEGIN

					UPDATE syspublications 
					SET sync_method = @syncmethodid, pre_snapshot_script = NULL,
						post_snapshot_script = NULL
					WHERE pubid = @pubid

				END    
				ELSE
				BEGIN
					UPDATE syspublications
					   SET sync_method = @syncmethodid
					 WHERE pubid = @pubid
				END

	            IF @@ERROR <> 0 GOTO UNDO
			end            
        END

    IF LOWER(@property collate SQL_Latin1_General_CP1_CS_AS) = 'status'
        BEGIN
            
            /*
            ** Check to make sure that we have a valid status.
            */

            IF LOWER(@value collate SQL_Latin1_General_CP1_CS_AS) NOT IN ('active', 'inactive')
                BEGIN
                    RAISERROR (14012, 16, -1)
                    GOTO UNDO
                END

            /*
            ** Determine the integer value for the status.
            */

            IF LOWER(@value collate SQL_Latin1_General_CP1_CS_AS) = 'active'
                SELECT @statusid = 1
            ELSE
                SELECT @statusid = 0

            /* If status changed */
            IF EXISTS (SELECT * FROM syspublications
                WHERE  pubid = @pubid  AND
                 status <> @statusid)
            BEGIN
    
                /* 
                ** If change the status of the publication,
                ** virtual anonymous subscription have to be recreated.
                **
                */
                IF @allow_anonymous = 1
                BEGIN
                    /* Drop virtual subscriptions */
                    EXEC @retcode = dbo.sp_dropsubscription 
                        @publication = @publication, 
                        @article = 'all', 
                        @subscriber = NULL,
                        @reserved = 'internal'
                    IF @@ERROR <> 0 OR @retcode <> 0
                    BEGIN
                        GOTO UNDO
                    END
                END

                /*
                ** Update the publication with the new status.
                */

                UPDATE syspublications
                   SET status = @statusid
                 WHERE pubid = @pubid

                IF @@ERROR <> 0 
                BEGIN
                    GOTO UNDO                
                END
                
                IF @allow_anonymous = 1
                    SELECT @add_virtual_back = 1
            END
        END

    IF LOWER(@property collate SQL_Latin1_General_CP1_CS_AS) = 'repl_freq'
        BEGIN

            /*
            ** Check for a valid replication frequency value.
            */

            IF LOWER(@value collate SQL_Latin1_General_CP1_CS_AS) NOT IN ('continuous', 'snapshot')
                BEGIN
                    RAISERROR (14015, 16, -1)
                    GOTO UNDO
                END


            /*
            ** Determine the integer value for the replication frequency.
            */

            IF LOWER(@value collate SQL_Latin1_General_CP1_CS_AS) = 'continuous'
                SELECT @replfreqid = 0
            ELSE
                SELECT @replfreqid = 1

            /*
            ** Only unsubscribed publications may have this modified.
            */
            IF EXISTS (SELECT * FROM syssubscriptions s
                       INNER JOIN sysextendedarticlesview a on s.artid = a.artid
                        WHERE s.status <> @subscribed
                          AND s.srvid >= 0 
                          AND a.pubid = @pubid)
            BEGIN
                RAISERROR (14033, 11, -1)
                GOTO UNDO
            END



/*

            IF EXISTS (SELECT * FROM syssubscriptions
            WHERE 
                status <> @subscribed AND
                srvid >= 0 AND
                artid IN (SELECT artid FROM sysextendedarticlesview where pubid
               = @pubid))
            BEGIN
                RAISERROR (14033, 11, -1)
                GOTO UNDO
            END

*/
            IF @immediate_sync = 1
            BEGIN
                /* Drop virtual subscriptions */
                EXEC @retcode = dbo.sp_dropsubscription 
                    @publication = @publication, 
                    @article = 'all', 
                    @subscriber = NULL,
                    @reserved = 'internal'
                IF @@ERROR <> 0 OR @retcode <> 0
                BEGIN
                    GOTO UNDO                
                END
            END
            /*
            ** Update the publication with the new replication frequency.
            */

            UPDATE syspublications
               SET repl_freq = @replfreqid
             WHERE pubid = @pubid

            IF @@ERROR <> 0 
            BEGIN
                GOTO UNDO
            END

            IF @immediate_sync = 1
                SELECT @add_virtual_back = 1
        END

    IF LOWER(@property collate SQL_Latin1_General_CP1_CS_AS) = N'alt_snapshot_folder'
        BEGIN
            -- If the alt_snapshot_folder is set to '' or NULL,
            -- set the compress_snapshot bit to 0 and disable
            -- internet support  
            IF @value IS NULL OR @value = N''
            BEGIN
                UPDATE syspublications
                   SET alt_snapshot_folder = @value,
                       compress_snapshot = 0,
                       enabled_for_internet = 0
                 WHERE pubid = @pubid
            END
            ELSE
            BEGIN
                UPDATE syspublications
                   SET alt_snapshot_folder = @value
                 WHERE pubid = @pubid

            END
            IF @@error <> 0
            BEGIN
               GOTO UNDO
            END

        END

    IF LOWER(@property collate SQL_Latin1_General_CP1_CS_AS) = N'pre_snapshot_script'
        BEGIN
            UPDATE syspublications
               SET pre_snapshot_script = @value
             WHERE pubid = @pubid
            IF @@error <> 0
            BEGIN
               GOTO UNDO
            END
        END

    IF LOWER(@property collate SQL_Latin1_General_CP1_CS_AS) = N'post_snapshot_script'
        BEGIN
            UPDATE syspublications
               SET post_snapshot_script = @value
             WHERE pubid = @pubid
            IF @@error <> 0
            BEGIN
               GOTO UNDO
            END
        END

    IF LOWER(@property collate SQL_Latin1_General_CP1_CS_AS) = N'ftp_address'
        BEGIN
    
            IF @value IS NULL OR @value = N''
            BEGIN
                UPDATE syspublications
                   SET ftp_address = @value,
                       enabled_for_internet = 0
                 WHERE pubid = @pubid
                IF @@error <> 0
                BEGIN
                    GOTO UNDO
                END
            END
            ELSE
            BEGIN
                UPDATE syspublications
                   SET ftp_address = @value
                 WHERE pubid = @pubid
                IF @@error <> 0
                BEGIN
                    GOTO UNDO
                END
            END
        END
            
    IF LOWER(@property collate SQL_Latin1_General_CP1_CS_AS) = N'ftp_port'
        BEGIN
            UPDATE syspublications
               SET ftp_port = CONVERT(int, @value)
             WHERE pubid = @pubid
            IF @@error <> 0
            BEGIN
               GOTO UNDO
            END
        END

    IF LOWER(@property collate SQL_Latin1_General_CP1_CS_AS) = N'ftp_subdirectory'
        BEGIN
            UPDATE syspublications
               SET ftp_subdirectory = @value
             WHERE pubid = @pubid
            IF @@error <> 0
            BEGIN
               GOTO UNDO
            END
        END

    IF LOWER(@property collate SQL_Latin1_General_CP1_CS_AS) = N'ftp_login'
        BEGIN
            UPDATE syspublications
               SET ftp_login = @value
             WHERE pubid = @pubid
            IF @@error <> 0
            BEGIN
               GOTO UNDO
            END
        END

    IF LOWER(@property collate SQL_Latin1_General_CP1_CS_AS) = N'ftp_password'
        BEGIN
            SELECT @enc_ftp_password = NULL
            IF @value IS NOT NULL
            BEGIN
                SELECT @enc_ftp_password = @value
                EXEC @retcode = master.dbo.xp_repl_encrypt @enc_ftp_password OUTPUT
                IF @retcode <> 0
                BEGIN
                    GOTO UNDO
                END
            END
            UPDATE syspublications
               SET ftp_password = @enc_ftp_password
             WHERE pubid = @pubid
            IF @@error <> 0
            BEGIN
               GOTO UNDO
            END
        END

    IF LOWER(@property collate SQL_Latin1_General_CP1_CS_AS) IN ('independent_agent', 'immediate_sync','enabled_for_internet',
            'allow_push', 'allow_pull', 'allow_anonymous', 'snapshot_in_defaultfolder', 
			'compress_snapshot', 'allow_subscription_copy')
    BEGIN

    
        /*
        ** Check for a valid  value.
        */

        IF LOWER(@value collate SQL_Latin1_General_CP1_CS_AS) NOT IN ('true', 'false')
        BEGIN
            RAISERROR (14137, 16, -1)
            GOTO UNDO
        END

        /*
        ** set value bit
        */
        IF LOWER(@value collate SQL_Latin1_General_CP1_CS_AS) = 'true'
            SELECT @value_bit = 1
        ELSE 
            SELECT @value_bit = 0


		IF LOWER(@property collate SQL_Latin1_General_CP1_CS_AS) = 'independent_agent'
		BEGIN
			SELECT @prev_value_bit = independent_agent
			FROM syspublications 
			WHERE name = @publication

			IF @prev_value_bit <> @value_bit
			BEGIN

				IF @immediate_sync = 1 AND @value_bit = 0
				BEGIN
					RAISERROR (21022, 16, -1)
					GOTO UNDO
				END    

			/* 
			** no subscriptions are allowed
			*/
			IF EXISTS (SELECT * FROM syssubscriptions ss, sysextendedarticlesview sa
					WHERE ss.artid = sa.artid
						AND   sa.pubid = @pubid
						AND   ss.srvid <> @virtual_id )
			BEGIN
				RAISERROR (20013, 16, -1, @property)
				GOTO UNDO
			END

			--
			-- No share agents for DTS/Updating publications
			--
			if (@value_bit = 0 and 
				(@allow_dts = 1 or @allow_sync_tran = 1 or @allow_queued_tran = 1))			
			begin
				raiserror(21173, 16, -1)
				return(1)
			end

			/* Update the publication type */
			UPDATE syspublications 
			SET independent_agent = @value_bit
			WHERE pubid = @pubid
			IF @@error <> 0
			BEGIN
			GOTO UNDO
			END
			END
		END

        IF LOWER(@property collate SQL_Latin1_General_CP1_CS_AS) = 'immediate_sync'
        BEGIN


            SELECT @prev_value_bit = immediate_sync
              FROM syspublications 
             WHERE name = @publication

            IF @prev_value_bit <> @value_bit
            BEGIN

               IF @independent_agent = 0 AND @value_bit = 1
               BEGIN
                    RAISERROR (21022, 16, -1)
                    GOTO UNDO
               END    

               /* 
               ** The publication has to be immediate_sync type to
               ** allow anonymous subscriptions
               */
                IF @value_bit = 0 AND
                    EXISTS (SELECT * FROM syspublications
                        WHERE pubid = @pubid
                        AND   allow_anonymous = 1 )
                BEGIN
                    RAISERROR (20011, 16, -1, @property)
                    GOTO UNDO
                END

            
                /* 
                ** If turn on immediate_sync, we need to add virtual subscriptions,
                ** Otherwise, we need to drop them
                ** When adding, we need to change publication bit first
                ** When dropping, we need to change publication bit second
                */
                IF @value_bit = 0
                BEGIN
                    -- Drop virtual subscriptions 
                    EXEC @retcode = dbo.sp_dropsubscription 
                        @publication = @publication, 
                        @article = 'all', 
                        @subscriber = NULL,
                        @reserved = 'internal'
                    IF @@ERROR <> 0 OR @retcode <> 0
                    BEGIN
                        GOTO UNDO
                    END

                    -- Reset the immediate_sync ready bit
                    UPDATE syspublications 
                        SET immediate_sync_ready = 0
                        WHERE pubid = @pubid

                END

                /* Update the publication type */
                UPDATE syspublications 
                    SET immediate_sync = @value_bit
                    WHERE pubid = @pubid
                IF @@error <> 0
                BEGIN
                    GOTO UNDO
                END


                IF @value_bit = 1
                    SELECT @add_virtual_back = 1
            END
        END

        IF LOWER(@property collate SQL_Latin1_General_CP1_CS_AS) = 'allow_anonymous'
        BEGIN

            SELECT @prev_value_bit = allow_anonymous
              FROM syspublications 
             WHERE name = @publication

            IF @prev_value_bit <> @value_bit
            BEGIN
                /* 
                ** The publication has to be immediate_sync type to
                ** allow anonymous subscriptions
                */
                IF @value_bit = 1 AND
                    NOT EXISTS (SELECT * FROM syspublications
                        WHERE pubid = @pubid
                        AND   immediate_sync = 1 )
                BEGIN
                    RAISERROR (20011, 16, -1, @property)
                    GOTO UNDO
                END
                
                

                /* Drop virtual subscriptions */
                EXEC @retcode = dbo.sp_dropsubscription 
                    @publication = @publication, 
                    @article = 'all', 
                    @subscriber = NULL,
                    @reserved = 'internal'
                IF @@ERROR <> 0 OR @retcode <> 0
                BEGIN
                    GOTO UNDO
                END

                /* Update the publication type */
                UPDATE syspublications 
                    SET allow_anonymous = @value_bit
                    WHERE pubid = @pubid
                IF @@error <> 0
                BEGIN
                   GOTO UNDO
                END

                /* 
                ** add virtual subscriptions back again to enable 
                ** anonymous subscription.
                */
                SELECT @add_virtual_back = 1

            END

        END

        IF LOWER(@property collate SQL_Latin1_General_CP1_CS_AS) = 'enabled_for_internet'
        BEGIN

            UPDATE syspublications 
               SET enabled_for_internet = @value_bit
             WHERE pubid = @pubid

            IF @@error <> 0
            BEGIN
               GOTO UNDO
            END
        END

        IF LOWER(@property collate SQL_Latin1_General_CP1_CS_AS) = 'allow_push'
        BEGIN

           /* 
           ** If turn it off, make sure there's no push subscriptions left
           */
           IF @value_bit = 0 AND
            EXISTS (SELECT * FROM syssubscriptions ss, sysextendedarticlesview sa
                    WHERE ss.artid = sa.artid
                    AND   sa.pubid = @pubid
                    AND      ss.subscription_type = @push
                    AND   ss.srvid <> @virtual_id )
            BEGIN
                RAISERROR (20012, 16, -1)
                GOTO UNDO
            END

            
            /* Update the publication type */
            UPDATE syspublications 
                SET allow_push = @value_bit
                WHERE pubid = @pubid
            IF @@error <> 0
            BEGIN
               GOTO UNDO
            END
        END

        IF LOWER(@property collate SQL_Latin1_General_CP1_CS_AS) = 'allow_pull'
        BEGIN
           /* 
           ** If turn it off, make sure there's no pull subscriptions left
           */
           IF @value_bit = 0 AND
            EXISTS (SELECT * FROM syssubscriptions ss, sysextendedarticlesview sa
                    WHERE ss.artid = sa.artid
                    AND   sa.pubid = @pubid
                    AND      ss.subscription_type = @pull
                    AND   ss.srvid <> @virtual_id )
            BEGIN
                RAISERROR (20013, 16, -1, @property)
                GOTO UNDO
            END
            /* Update the publication type */
            UPDATE syspublications 
                SET allow_pull = @value_bit
                WHERE pubid = @pubid
            IF @@error <> 0
            BEGIN
               GOTO UNDO
            END
        END

        IF LOWER(@property collate SQL_Latin1_General_CP1_CS_AS) = 'snapshot_in_defaultfolder'
        BEGIN
            -- snapshot_in_defaultfolder = 1 is only meaningful when
            -- alt_snapshot_folder is non-null, otherwise 
            -- a copy of the snapshot files is always kept
            -- at the publisher's working directory 
    
            UPDATE syspublications 
               SET snapshot_in_defaultfolder = @value_bit
             WHERE pubid = @pubid
            IF @@error <> 0
            BEGIN
                GOTO UNDO
            END
        END

        IF LOWER(@property collate SQL_Latin1_General_CP1_CS_AS) = 'compress_snapshot'
        BEGIN

            UPDATE syspublications
               SET compress_snapshot = @value_bit
             WHERE pubid = @pubid
            IF @@error <> 0
            BEGIN
                GOTO UNDO
            END
        END

        IF LOWER(@property collate SQL_Latin1_General_CP1_CS_AS) = 'allow_subscription_copy'
        BEGIN
			if @value_bit = 1 and @immediate_sync = 0
			begin
				raiserror(21210, 16, -1)
				goto UNDO
			end

            UPDATE syspublications
               SET allow_subscription_copy = @value_bit
             WHERE pubid = @pubid
            IF @@error <> 0
            BEGIN
                GOTO UNDO
            END
        END
    END

    /* Update publication property at the distributor side if necessary */
    IF LOWER(@property collate SQL_Latin1_General_CP1_CS_AS) IN ('description', 'repl_freq', 'independent_agent',
        'immediate_sync', 'allow_push',
        'allow_pull', 'allow_anonymous','retention', 'allow_subscription_copy')
    BEGIN
        /* Translate the property names and values  */
        IF LOWER(@property collate SQL_Latin1_General_CP1_CS_AS) = 'repl_freq'
        BEGIN
            SELECT @property = 'publication_type'
            SELECT @value = STR(@replfreqid)
        END

        /* Translate values */
        IF LOWER(@value collate SQL_Latin1_General_CP1_CS_AS) = 'true'
            SELECT @value = '1'
        ELSE IF LOWER(@value collate SQL_Latin1_General_CP1_CS_AS) = 'false'
            SELECT @value = '0'

        /*
        ** Get distribution server information for remote RPC call.
        */
        EXECUTE @retcode = dbo.sp_helpdistributor @rpcsrvname = @distributor OUTPUT,
           @distribdb   = @distribdb OUTPUT
        IF @@ERROR <> 0 or @retcode <> 0
            BEGIN
                GOTO UNDO
            END

        SELECT @dbname =  DB_NAME()
        
        SELECT @distproc = RTRIM(@distributor) + '.' + @distribdb + 
            '.dbo.sp_MSchange_publication'
    
        EXECUTE @retcode = @distproc
            @publisher = @@SERVERNAME,
            @publisher_db = @dbname,
            @publication = @publication,
            @property = @property,
            @value = @value

        IF @@ERROR <> 0 OR @retcode <> 0
        BEGIN
            GOTO UNDO
        END
    END
    
    IF @add_virtual_back = 1    
    BEGIN
        /* Add virtual subscriptions back*/
        EXEC @retcode = dbo.sp_addsubscription 
            @publication = @publication, 
            @article = 'all',
            @subscriber = NULL,
            @destination_db = 'virtual',
            @sync_type = 'automatic',
            @status = NULL, 
            @reserved = 'internal'
        IF @@ERROR <> 0 OR @retcode <> 0
        BEGIN
            GOTO UNDO                    
        END
    END

	--
	-- Queued properties
	--
	IF (LOWER(@property collate SQL_Latin1_General_CP1_CS_AS) IN ('conflict_policy', 'centralized_conflicts', 'conflict_retention', 'queue_type'))
	BEGIN
		--
		-- we will consider changes only if the publication supports queued operations
		--
		if exists (select * from syspublications 
				where pubid = @pubid and allow_queued_tran = 1)
		BEGIN
			IF (LOWER(@property collate SQL_Latin1_General_CP1_CS_AS) = 'conflict_policy')
			BEGIN
				if (LOWER(@value collate SQL_Latin1_General_CP1_CS_AS) = 'sub reinit')
					select @conflict_policy_id = 3
				else if (LOWER(@value collate SQL_Latin1_General_CP1_CS_AS) = 'pub wins')
					select @conflict_policy_id = 1
				else if (LOWER(@value collate SQL_Latin1_General_CP1_CS_AS) = 'sub wins')
					select @conflict_policy_id = 2
				else
				BEGIN
					raiserror (21184, 16, 3, 'conflict_policy', 'sub reinit', 'pub wins', 'sub wins')
					GOTO UNDO                    
				END

				--
				-- cannot change this parameter once we have subscriptions
				--
				IF EXISTS (SELECT * FROM syssubscriptions ss, sysextendedarticlesview sa
								WHERE ss.artid = sa.artid
								AND   sa.pubid = @pubid)
				BEGIN
					RAISERROR (21268, 16, 1)
					GOTO UNDO
				END

				--
				-- Check snapshot permissible values
				--
				if ((@replfreqid = 1) and (@conflict_policy_id = 1))
				begin
					raiserror (21270, 16, 1, '@conflict_policy', @value)
					GOTO UNDO                    
				end
				
				UPDATE syspublications
				SET conflict_policy = @conflict_policy_id
				WHERE pubid = @pubid
				IF @@error <> 0
				BEGIN
					GOTO UNDO
				END
			END

			IF (LOWER(@property collate SQL_Latin1_General_CP1_CS_AS) = 'centralized_conflicts')
			BEGIN
				if (LOWER(@value collate SQL_Latin1_General_CP1_CS_AS) = 'true')
					select @centralized_conflicts_bit = 1
				else if (LOWER(@value collate SQL_Latin1_General_CP1_CS_AS) = 'false')
					select @centralized_conflicts_bit = 0
				else
				begin
					raiserror (14148, 16, 3, 'centralized_conflicts')
					GOTO UNDO                    
				end

				--
				-- Check snapshot permissible values
				--
				if ((@replfreqid = 1) and (@centralized_conflicts_bit = 0))
				begin
					raiserror (21270, 16, 1, '@centralized_conflicts', @value)
					GOTO UNDO                    
				end

				--
				-- cannot change this parameter once we have subscriptions
				--
				IF EXISTS (SELECT * FROM syssubscriptions ss, sysextendedarticlesview sa
								WHERE ss.artid = sa.artid
								AND   sa.pubid = @pubid)
				BEGIN
					RAISERROR (21268, 16, 2)
					GOTO UNDO
				END

				UPDATE syspublications
				SET centralized_conflicts = @centralized_conflicts_bit
				WHERE pubid = @pubid
				IF @@error <> 0
				BEGIN
					GOTO UNDO
				END
			END

			IF (LOWER(@property collate SQL_Latin1_General_CP1_CS_AS) = 'conflict_retention')
			BEGIN
				select @conflict_retention = CAST(@value as integer)
				if (@@error != 0) or (@conflict_retention < 0)
				BEGIN
					raiserror(20050, 16, -1, 0)
					GOTO UNDO                    
				END
				if (@conflict_retention IS NULL)
					select @conflict_retention = 60

				UPDATE syspublications
				SET conflict_retention = @conflict_retention
				WHERE pubid = @pubid
				IF @@error <> 0
				BEGIN
					GOTO UNDO
				END
			END
			
			IF (LOWER(@property collate SQL_Latin1_General_CP1_CS_AS) = 'queue_type')
			BEGIN				
				IF (CAST(@value as integer) NOT IN (1,2))
				BEGIN
					RAISERROR(21267, 16, 1, '1,2')
					GOTO UNDO
				end

				IF (CAST(@value as integer) != @queue_type)
				BEGIN
					select @queue_type = CAST(@value as integer)
					IF EXISTS (SELECT * FROM syssubscriptions ss, sysextendedarticlesview sa
									WHERE ss.artid = sa.artid
									AND   sa.pubid = @pubid)
					BEGIN
						RAISERROR (21268, 16, 3)
						GOTO UNDO
					END

					UPDATE syspublications
					SET queue_type = @queue_type
					WHERE pubid = @pubid
					IF @@error <> 0
					BEGIN
						GOTO UNDO
					END

					--
					-- For MSMQ queue_type - Check if the distributor supports it
					--
					if (@queue_type = 1)
					begin
						EXECUTE @retcode = dbo.sp_helpdistributor @rpcsrvname = @distributor OUTPUT,
												@distribdb   = @distribdb OUTPUT
						IF @@ERROR <> 0 or @retcode <> 0
						BEGIN
							GOTO UNDO
						END

						SELECT @dbname =  DB_NAME()
								,@distproc = RTRIM(@distributor) + '.' + @distribdb + 
											N'.dbo.sp_MSchange_publication'

						EXECUTE @retcode = @distproc
										@publisher = @@SERVERNAME,
										@publisher_db = @dbname,
										@publication = @publication,
										@property = @property,
										@value = @value

						IF @@ERROR <> 0 OR @retcode <> 0
						BEGIN
							GOTO UNDO
						END
					end
				END
			END			
		END
	END

	
	-- Have to call this stored procedure to invalidate existing snapshot or reint
	-- subscriptions if needed
	EXECUTE @retcode  = dbo.sp_MSreinit_article
		@publication = @publication, 
		@need_new_snapshot = @need_new_snapshot,
		@need_reinit_subscription = @need_reinit_subscription
		,@force_invalidate_snapshot = @force_invalidate_snapshot	/* Force invalidate existing snapshot */
		,@force_reinit_subscription = @force_reinit_subscription	/* Force reinit subscription */
	IF @@ERROR <> 0 OR @retcode <> 0
		GOTO UNDO

	COMMIT TRAN sp_changepublication

	--update its registration in active directory
	if @in_ActiveD=1 and LOWER(@property collate SQL_Latin1_General_CP1_CS_AS) IN ('description','allow_pull', 'allow_anonymous')
	begin
		create table #guid_name_for_ADupdate(ad_guidname sysname collate database_default null)
		if @@ERROR<>0
		begin
            goto FAILURE
		end
		insert into #guid_name_for_ADupdate exec @retcode = master.dbo.sp_ActiveDirectory_Obj N'UPDATE', N'PUBLICATION', @publication, @db_name, @ad_guidname
		if @@ERROR<>0 or @retcode<>0
    	begin
    		goto FAILURE 					
	   	end
    	select TOP 1 @ad_guidname = ad_guidname from #guid_name_for_ADupdate
    	if @ad_guidname is not NULL
    	begin
    		update syspublications set ad_guidname=@ad_guidname where pubid=@pubid
    		if @@ERROR<>0
    			goto FAILURE
    	end
	    drop table #guid_name_for_ADupdate
    end

    /*
    ** Return succeed.
    */

    RAISERROR (14077, 10, -1)
    RETURN (0)
FAILURE:
	drop table #guid_name_for_ADupdate
    raiserror(21371, 10, -1, @publication)
    return (1)   

UNDO:
    IF @@TRANCOUNT > 0
    begin 
        ROLLBACK TRAN sp_changepublication
        COMMIT TRAN
    end
END
GO
 
EXEC dbo.sp_MS_marksystemobject sp_changepublication
GO

print ''
print 'Creating procedure sp_changesubscription'
GO
/* This function should be disallowed */
CREATE PROCEDURE sp_changesubscription (
    @publication sysname = NULL,        /* Publication name */
    @article sysname = NULL,            /* Article name */
    @subscriber sysname,              /* Subscriber name */
    @property nvarchar(15) = NULL,           /* The property to change */
    @value nvarchar(255) = NULL              /* The new property value */
    ) AS

    SET NOCOUNT ON
    RAISERROR (21023, 16, -1,'sp_changesubscription')
    RETURN(1)
go
 
dump tran master with no_log
go

EXEC dbo.sp_MS_marksystemobject sp_changesubscription
GO


print ''
print 'Creating procedure sp_helparticle'
go

CREATE PROCEDURE sp_helparticle (
    @publication sysname,         /* The publication name */
    @article sysname = '%',       /* The article name */
    @returnfilter bit = 1         /* Return filter flag */
    ) AS

    SET NOCOUNT ON

    /*
    ** Declarations.
    */

    DECLARE @pubid int
    DECLARE @retcode int
    DECLARE @subscriber_bit smallint
    DECLARE @publish_bit int
    DECLARE @source_object  sysname
    DECLARE @source_owner   sysname
    DECLARE @username       sysname
    
    SELECT @publish_bit = 1
    SELECT @username = suser_sname()

    /*
    ** Parameter Check:  @publication.
    ** Check to make sure that publication exists.
    */

    IF @publication IS NULL
        BEGIN
            RAISERROR (14043, 16, -1, '@publication')
            RETURN (1)
        END

    EXECUTE @retcode = dbo.sp_validname @publication

    IF @retcode <> 0
        RETURN (1)

    IF NOT EXISTS (SELECT * FROM syspublications WHERE name = @publication)
        BEGIN
            RAISERROR (20026, 11, -1, @publication)
            RETURN (1)
        END

    /*
    ** Security Check. Restrict to 'sysadmin', DBO of publishing database, PAL
    */
    IF is_member(N'db_owner') <> 1
    BEGIN
        exec @retcode = sp_MSreplcheck_pull
            @publication = @publication,
            @given_login = @username
        IF @retcode <> 0 OR @@error <> 0
            RETURN (1)
    END
    
    /*
    ** Check if the database is published.
    */
    IF NOT EXISTS (SELECT * FROM master..sysdatabases
        WHERE name = db_name() collate database_default
        AND (category & @publish_bit) = @publish_bit)
        RETURN(0)

    /*
    ** Initializations.
    */

    SELECT @subscriber_bit = 4

    IF @publication IS NOT NULL
        SELECT @pubid = pubid FROM syspublications WHERE name = @publication

    /*
    ** Create a temporary table to hold all information.
    */

    CREATE TABLE #tab1 (
        artid               int             NOT NULL,
        columns             varbinary(32)   NULL,
        creation_script     nvarchar(255)   collate database_default null,
        del_cmd             nvarchar(255)   collate database_default null,
        description         nvarchar(255)   collate database_default null,
        dest_table          sysname         collate database_default null,
        old_filter          int             NULL,
        ins_cmd             nvarchar(255)   collate database_default null,
        name                sysname         collate database_default not null,
        objid               int             NOT NULL,
        pubid               int             NOT NULL,
        status              tinyint         NOT NULL,
        sync_objid          int             NULL,
        type                smallint        NOT NULL,
        upd_cmd             nvarchar(255)   collate database_default null,
        source_table        nvarchar(257)   collate database_default null,      /* converted from objid */
        filter              nvarchar(257)   collate database_default null,      /* converted from old_filter */
        sync_object         nvarchar(257)   collate database_default null,      /* converted from sync_objid */
        vpartition          bit             NULL,      /* computed */
        pre_creation_cmd    tinyint     NOT NULL,
        filter_clause       ntext           NULL,
        schema_option       binary(8)       NULL,
        dest_owner          sysname         collate database_default null,
        source_owner        sysname         collate database_default null,   /* these two columns are for 7.0 use only */
        unqua_source_object sysname         collate database_default null,   /* column source_table stays due to backward compatibility */
        sync_object_owner   sysname         collate database_default null,
        unqua_sync_object   sysname         collate database_default null,
        filter_owner        sysname         collate database_default null,
        unqua_filter        sysname         collate database_default null
    )

    CREATE UNIQUE INDEX idx1 ON #tab1 (name, pubid)

    /*
    ** Parameter Check:  @article.
    ** Check to make sure that the article exists, that it conforms
    ** to the rules for identifiers, and that it isn't NULL.
    */

    IF @article IS NULL
        BEGIN
            RAISERROR (14043, 16, -1, '@article')
            RETURN (1)
        END

    IF @article <> '%'
        BEGIN

            /*
            EXECUTE @retcode = dbo.sp_validname @article

            IF @retcode <> 0
            RETURN (1)
            */

            IF NOT EXISTS (SELECT *
                             FROM sysextendedarticlesview
                            WHERE name = @article
                              AND pubid IN (SELECT pubid
                                              FROM syspublications
                                             WHERE name = @publication))
                BEGIN
                    RAISERROR (20027, 11, -1, @article)
                    RETURN (1)
                END

        END

        
    IF @returnfilter = 1
    BEGIN
        INSERT INTO #tab1 (artid, columns, creation_script, del_cmd,
                           description, dest_table, old_filter,
                           ins_cmd, name, objid, pubid, status,
                           sync_objid, type, upd_cmd, source_table,
                           filter, vpartition, pre_creation_cmd,
               filter_clause, schema_option, dest_owner, source_owner, unqua_source_object, 
               sync_object_owner, unqua_sync_object, filter_owner, unqua_filter)
               
         (SELECT artid, columns, creation_script, del_cmd, a.description,
                 dest_table, filter, ins_cmd, a.name, objid, a.pubid,
                 a.status, sync_objid, a.type, upd_cmd, NULL, NULL, 0,
                a.pre_creation_cmd, a.filter_clause, a.schema_option, a.dest_owner, 
                user_name(o.uid), o.name, 
                user_name(sync.uid), sync.name,
                user_name(fltr.uid), fltr.name
            FROM syspublications b, 
                 sysobjects o, 
                 sysextendedarticlesview a 
          LEFT JOIN sysobjects sync on a.sync_objid = sync.id
          LEFT JOIN sysobjects fltr on a.filter = fltr.id
           WHERE a.name LIKE @article
             AND a.objid = o.id
             AND a.pubid = b.pubid
             AND b.name = @publication)
    END
    ELSE
    BEGIN
        INSERT INTO #tab1 (artid, columns, creation_script, del_cmd,
                           description, dest_table, old_filter,
                           ins_cmd, name, objid, pubid, status,
                           sync_objid, type, upd_cmd, source_table,
                           filter, vpartition, pre_creation_cmd,
               filter_clause, schema_option, dest_owner, source_owner, unqua_source_object, 
               sync_object_owner, unqua_sync_object, filter_owner, unqua_filter)
         (SELECT artid, columns, creation_script, del_cmd, a.description,
                 dest_table, filter, ins_cmd, a.name, objid, a.pubid,
                 a.status, sync_objid, a.type, upd_cmd, NULL, NULL, 0,
                 a.pre_creation_cmd, NULL, schema_option, dest_owner, 
                 user_name(o.uid), o.name,
                 user_name(sync.uid), sync.name,
                 user_name(fltr.uid), fltr.name
           FROM syspublications b, 
                sysobjects o, 
                sysextendedarticlesview a 
           LEFT JOIN sysobjects fltr on a.filter = fltr.id
           LEFT JOIN sysobjects sync on a.sync_objid = sync.id
           WHERE a.name LIKE @article
             AND a.objid = o.id
             AND a.pubid = b.pubid
             AND b.name = @publication)
    END

    UPDATE #tab1
       SET source_table = QUOTENAME(u.name) + '.' + QUOTENAME(o.name)
      FROM #tab1, sysobjects o, sysusers u
     WHERE o.id = #tab1.objid
       AND o.uid = u.uid

    UPDATE #tab1
        SET unqua_sync_object = sysobjects.name
        from sysobjects 
        where sysobjects.id = sync_objid

    UPDATE #tab1
       SET sync_object = QUOTENAME(sysusers.name) + '.' + QUOTENAME(sysobjects.name)
      FROM sysobjects, sysusers
     WHERE sysobjects.id = sync_objid
       AND sysobjects.uid = sysusers.uid

    UPDATE #tab1 SET filter = (SELECT sysusers.name + '.' + sysobjects.name
                                 FROM sysobjects, sysusers
                                WHERE sysobjects.id = #tab1.old_filter
                                  AND sysobjects.uid = sysusers.uid)
      FROM #tab1

    DECLARE hC  CURSOR LOCAL FAST_FORWARD FOR SELECT name, pubid FROM #tab1
    OPEN hC
    FETCH hC INTO @article, @pubid
    WHILE (@@fetch_status <> -1)
        BEGIN
            IF EXISTS (SELECT *
                         FROM sysextendedarticlesview a, syscolumns b
                         WHERE 
                          ( 
                           convert(bit, convert( varbinary, substring( convert( nvarchar, a.columns ), 16 - floor((colid-1)/16),1 )) & power( 2, ((colid-1)%16))) = 0
                           OR convert(bit, convert( varbinary, substring( convert( nvarchar, a.columns ), 16 - floor((colid-1)/16),1 )) & power( 2, ((colid-1)%16))) IS NULL
                          )
                          AND a.objid = b.id
                          AND a.name = @article
                          AND a.pubid = @pubid)

                UPDATE #tab1
                   SET vpartition = 1
                 WHERE name = @article
                   AND pubid = @pubid

            FETCH hC INTO @article, @pubid
        END
    CLOSE hC
    DEALLOCATE hC

    SELECT 'article id'                = art.artid,
       'article name'              = name,
       'base object'                = source_table,
       'destination object'         = dest_table,
       'synchronization object'    = sync_object,
       'type'                      = case 
                                        when objectproperty(art.objid, 'IsSchemaBound') = 1 and type <> 0x80 then 0x0100 | convert(smallint, type)
                                        else type 
                                     end,    
	   -- bit 32 indicates whether or not timestamp is included in partition for queue publications
	   -- It is internal and should be hidden from DMO scripting, since it is not allowed to 
	   -- be set in sp_addarticle
	   -- sp_helparticlecolumns will use that bit to return proper information.
       'status'                    = status & ~32,
       'filter'                    = filter,
       'description'               = description,
       'insert_command'            = ins_cmd,
       'update_command'            = upd_cmd,
       'delete_command'            = del_cmd,
       'creation script path'      = creation_script,
       'vertical partition'        = vpartition,
       'pre_creation_cmd'       = pre_creation_cmd,
	   -- filter_clause is null when @return_filter is 0
       'filter_clause'           = filter_clause,
       'schema_option'            = schema_option,
       'dest_owner'             = dest_owner,
       'source_owner'           = source_owner,
       'unqua_source_object'    = unqua_source_object,
       'sync_object_owner'      = sync_object_owner,
       'unqualified_sync_object' = unqua_sync_object,
       'filter_owner'           = filter_owner,
       'unqua_filter'           = unqua_filter,
	   'auto_identity_range'	= isnull(artupd.identity_support, 0),
	   'publisher_identity_range' = abs(iden.pub_range),
	   'identity_range'	= abs(iden.range),
	   'threshold' = iden.threshold
      FROM #tab1 art
		left join sysarticleupdates artupd on art.artid = artupd.artid
		left join MSpub_identity_range iden on art.objid = iden.objid
      ORDER BY 2

    RETURN (0)
go

dump tran master with no_log
go

EXEC dbo.sp_MS_marksystemobject sp_helparticle
GO


print ''
print 'Creating procedure sp_MSis_col_replicated'
go
create procedure sp_MSis_col_replicated @publication sysname, 
    @article sysname, 
    @coltype nvarchar(10) = 'timestamp',  -- identity or timestamp or rowguid
    @colname sysname = NULL OUTPUT 
as
    declare @word tinyint, 
        @bit tinyint, 
        @mask binary(2), 
        @mval int,
        @colword binary(2), 
        @columns binary(32),
        @firstcol tinyint, 
        @colid smallint,
        @tabid int,
        @pubid int
        

    select @colname = NULL

    select @pubid = pubid from syspublications where name = @publication

    select @tabid = objid from sysarticles 
        where name = @article and pubid = @pubid
    
    if @coltype = 'timestamp'
    begin
        if ObjectProperty(@tabid, 'TableHasTimestamp') = 1 
        begin

            select @colname = name, @colid = colid from syscolumns 
                where id = @tabid and type_name(xtype) = 'timestamp' 
            
            if @colname is not NULL
            begin                       
                -- check if  timestamp is replicated
                --  Obtain the byte offset and the bit offset, then set the
                select @columns=columns from sysarticles where name = @article and pubid = @pubid
                select @word = CONVERT(tinyint, 16 - FLOOR((@colid-1)/16))
                select @bit = (@colid-1) % 16
                select @mval = POWER(2, @bit)
                select @mask = convert( binary(2), substring( convert( nchar(2), convert( binary(4), @mval ) ), 2, 1 ) )                                 
    
                -- Fish out the byte we're interested in and save it in a
                -- a temporary local variable.  
                select @colword = convert( binary(2), SUBSTRING( convert(nchar(16),@columns), @word, 1) )
    
                if convert( smallint, @colword ) & convert( smallint, @mask) = 0 
                begin
                    select @colname = NULL
                    return (0)
                end
                else
                    return (1)
            end
            else
            begin
                select @colname = NULL
                return (0)
            end
        end
        else
        begin
            select @colname = NULL
            return (0)
        end
    end
    else if @coltype = 'identity'
    begin
        if ObjectProperty(@tabid, 'TableHasIdentity') = 1 
        begin
            select @colname = name, @colid = colid from syscolumns 
            where id = @tabid and ColumnProperty(@tabid, name, 'IsIdentity') = 1
            
            if @colname is not NULL
            begin                       
                -- check if column is replicated
                --  Obtain the byte offset and the bit offset, then set the
                select @columns=columns from sysarticles where name = @article and pubid = @pubid
                select @word = CONVERT(tinyint, 16 - FLOOR((@colid-1)/16))
                select @bit = (@colid-1) % 16
                select @mval = POWER(2, @bit)
                select @mask = convert( binary(2), substring( convert( nchar(2), convert( binary(4), @mval ) ), 2, 1 ) )                                 

                -- Fish out the byte we're interested in and save it in a
                -- a temporary local variable.  
                select @colword = convert( binary(2), SUBSTRING( convert(nchar(16),@columns), @word, 1) )
                
                if convert( smallint, @colword ) & convert( smallint, @mask) = 0 
                begin
                    select @colname = NULL
                    return (0)
                end
                else
                    return (1)
            end
            else
            begin
                select @colname = NULL
                return (0)
            end
        end
	end
    else if @coltype = 'rowguid'
    begin
        if ObjectProperty(@tabid, 'TableHasRowGuid') = 1 
        begin
            select @colname = name, @colid = colid from syscolumns 
            where id = @tabid and ColumnProperty(@tabid, name, 'IsRowGuidCol') = 1
            
            if @colname is not NULL
            begin                       
                -- check if column is replicated
                --  Obtain the byte offset and the bit offset, then set the
                select @columns=columns from sysarticles where name = @article and pubid = @pubid
                select @word = CONVERT(tinyint, 16 - FLOOR((@colid-1)/16))
                select @bit = (@colid-1) % 16
                select @mval = POWER(2, @bit)
                select @mask = convert( binary(2), substring( convert( nchar(2), convert( binary(4), @mval ) ), 2, 1 ) )                                 

                -- Fish out the byte we're interested in and save it in a
                -- a temporary local variable.  
                select @colword = convert( binary(2), SUBSTRING( convert(nchar(16),@columns), @word, 1) )
                
                if convert( smallint, @colword ) & convert( smallint, @mask) = 0 
                begin
                    select @colname = NULL
                    return (0)
                end
                else
                    return (1)
            end
            else
            begin
                select @colname = NULL
                return (0)
            end
        end

        else
        begin
            select @colname = NULL
            return (0)
        end
    end
	else
    begin
        select @colname = NULL
        return (0)    
    end
go

EXEC dbo.sp_MS_marksystemobject sp_MSis_col_replicated
GO

print ''
print 'Creating procedure sp_articlecolumn'
go
CREATE PROCEDURE sp_articlecolumn (
        @publication sysname,           /* The publication name */
        @article sysname,               /* The article name */
        @column sysname = NULL,         /* The column name */
        @operation nvarchar(4) = N'add'      /* Add or delete a column */
        -- synctran
        , @refresh_synctran_procs bit = 1      -- refresh synctran procs or not
		, @ignore_distributor bit = 0
		-- DDL
		, @change_active int = 0
		, @force_invalidate_snapshot bit = 0	/* Force invalidate existing snapshot */
		, @force_reinit_subscription bit = 0	/* Force reinit subscription */

        ) 
AS
BEGIN

    /*
    ** Declarations.
    */

	DECLARE @bit tinyint                /* Bit offset */
			,@word tinyint               /* word offset */
			,@cnt tinyint, @idx tinyint  /* Loop counter, index */
			,@columns binary(32)         /* Temporary storage for the converted column */
			,@mask binary(2)              /* Bit mask to set the bit on */
			,@mval int
			,@newword binary(2)
			,@oldword binary(2)
			,@pubid int                  /* Publication identification number */
			,@retcode int                /* Return code for stored procedures */
			,@artid int
			,@active tinyint
			,@objid int            /* Article base table id */    
			,@tablename  sysname
			,@fSynctranColChanged bit
			,@pkkey sysname
			,@indid int
			,@index_cnt int

	select @active = 2
			,@fSynctranColChanged = 0

    /*
    ** Security Check
    */
    exec @retcode = dbo.sp_MSreplcheck_publish
    if @@ERROR <> 0 or @retcode <> 0
        return(1)

    /*
    ** Check to see if the database has been activated for publication.
	** Do not check if @ignore_distributor indicates brute force cleanup.
    */

    IF ( (SELECT category & 1
          FROM master..sysdatabases
         WHERE name = DB_NAME() collate database_default) = 0 )  and ( @ignore_distributor = 0 )

    BEGIN
        RAISERROR (14013, 16, -1)
        RETURN (1)
    END

    /*
    ** Parameter Check:  @publication.
    ** Make sure that the publication exists and that it conforms to the
    ** rules for identifiers.
    */

    IF @publication IS NULL
        BEGIN
            RAISERROR (14043, 16, -1, N'@publication')
            RETURN (1)
        END

    EXECUTE @retcode = dbo.sp_validname @publication

    IF @retcode <> 0
            RETURN (1)

	declare @allow_queued_tran bit
	declare @allow_sync_tran bit

    SELECT @pubid = pubid, 
		@allow_sync_tran = allow_sync_tran,
		@allow_queued_tran = allow_queued_tran
		FROM syspublications WHERE name = @publication

    IF @pubid IS NULL
        BEGIN
            RAISERROR (20026, 11, -1, @publication)
            RETURN (1)
        END
    ELSE

    /*
    ** Parameter Check:  @article.
    ** Check to make sure that the article exists in the publication.
    */

    IF @article IS NULL
        BEGIN
            RAISERROR (14043, 16, -1, N'@article')
            RETURN (1)
        END

    /*
    EXECUTE @retcode = dbo.sp_validname @article

    IF @@ERROR <> 0 OR @retcode <> 0
    RETURN (1)
    */

    /*
    ** Make sure the article exists.
    */
    SELECT @artid = artid FROM sysarticles
       WHERE pubid = @pubid AND name = @article
    IF @artid IS NULL
        BEGIN
            RAISERROR (20027, 11, -1, @article)
            RETURN (1)
        END


    /*
    ** Error out if this is a not a table based article
    */
    IF NOT EXISTS ( SELECT * FROM sysarticles WHERE artid = @artid
                      AND pubid = @pubid
                      AND (type & 1) = 1 )
        BEGIN
            RAISERROR (14112, 11, -1 )
            RETURN (1)
        END

    /*
    ** Parameter Check:  @column.
    ** Check to make sure that the column exists and conforms to the rules
    ** for identifiers.
    */

    /*
    IF @column IS NOT NULL
        BEGIN
            EXECUTE @retcode = dbo.sp_validname @column
            IF @@ERROR <> 0 OR @retcode <> 0
            RETURN (1)
        END
    */

    /*
    ** Parameter Check:  @operation.
    ** The operation can be either 'add' or 'drop'.
    */

    IF LOWER(@operation collate SQL_Latin1_General_CP1_CS_AS) NOT IN (N'add', N'drop')
        BEGIN
            RAISERROR (14019, 16, -1)
            RETURN (1)
        END
        
    SELECT @objid = (SELECT objid FROM sysarticles WHERE artid = @artid)
    SELECT @tablename = OBJECT_NAME(@objid)
   
	if @column is not null
	begin
		declare @colid	smallint
		select @colid=colid from syscolumns where id=@objid and name=@column
		if @colid is null
		begin
            RAISERROR (14020, 16, -1)
            RETURN (1)
		end

	if LOWER(@operation collate SQL_Latin1_General_CP1_CS_AS) = 'drop'
	begin		
		-- Vertical partition is only allowed on table-based article, not IV->table
	    	IF OBJECTPROPERTY(@objid, 'IsTable') <> 1
	        BEGIN
        	    RAISERROR (14112, 11, -1 )
           	    RETURN (1)
	        END
		-- PK column has to be included in vertical partition
		select @indid = indid from sysindexes where id = @objid and (status & 2048) <> 0    /* PK index */
		select @index_cnt = 1
		while (@index_cnt <= 16)
			begin
				select @pkkey = INDEX_COL(@tablename, @indid, @index_cnt)
				if @pkkey is NULL
					break
				if @pkkey=@column
					begin
						raiserror(21250, 16, -1, @column)
						return (1)
					end
				select @index_cnt = @index_cnt + 1
			end
	end

		-- If the publication is allow_sync_tran, we cannot drop the timestamp
		-- column from the partition.
		if (@allow_sync_tran = 1 or @allow_queued_tran = 1) and LOWER(@operation collate SQL_Latin1_General_CP1_CS_AS) = N'drop'
		begin
			if N'msrepl_tran_version' = @column
            BEGIN
                RAISERROR (21080, 16, -1)
                RETURN (1)
            END
		end

		-- Only columns that have default values can be outside the partition
		-- Note: do check error if it is schema change.
		if @change_active = 0 and LOWER(@operation collate SQL_Latin1_General_CP1_CS_AS)=N'drop' and 
			(@allow_queued_tran = 1 or @allow_sync_tran = 1) and
			ColumnProperty(@objid, @column, N'IsIdentity') <> 1 and
			-- 189 is timestamp.
			not exists (select * from syscolumns where id = @objid and 
				name=@column and (isnullable=1 or xtype = 189)) and
			not exists (select * from sysconstraints where id=@objid and 
				colid=@colid and status & 5 = 5)
		BEGIN
			RAISERROR(21165, 16, -1, @column)
			return (1)
		END
	end

	-- @ignore_distributor is set to 1 when removing replication forcefully. In that
	-- case, no need to check or reinit
	if @ignore_distributor = 0
	begin
		-- Check if there are snapshot or subscriptions and raiserror if needed.
		EXECUTE @retcode  = dbo.sp_MSreinit_article
			@publication = @publication, 
			@article = @article,
			@need_new_snapshot = 1,
			@need_reinit_subscription = 1
			,@force_invalidate_snapshot = @force_invalidate_snapshot	/* Force invalidate existing snapshot */
			,@force_reinit_subscription = @force_reinit_subscription	/* Force reinit subscription */
			,@check_only = 1
		IF @@ERROR <> 0 OR @retcode <> 0
			return (1)
	end

	begin tran
    save TRANSACTION articlecolumn

    /*
    ** Make sure that the columns column is not NULL.
    */

--    SELECT @zero = 0x00

    SELECT @columns = columns
      FROM sysarticles
     WHERE artid = @artid

    IF @columns IS NULL
        UPDATE sysarticles
           SET columns = 0x00
         WHERE artid = @artid

    /*
    ** If no columns are specified, or if NULL is specified, set all
    ** the bits in the 'columns' column so all columns will be included.
    */

    IF @column IS NULL
    BEGIN
       DECLARE hCartcolumn CURSOR LOCAL FAST_FORWARD FOR
            SELECT name FROM syscolumns where
				id = @objid
    END
	ELSE
    BEGIN
       DECLARE hCartcolumn CURSOR LOCAL FAST_FORWARD FOR 
            SELECT @column
	END


    OPEN hCartcolumn

    FETCH hCartcolumn INTO @column

	WHILE (@@fetch_status <> -1)
	BEGIN

		DECLARE @columnid smallint   /* Columnid-1 = bit to set */
		/*
		** Get the column id for this column.  We'll use the column id
		** to determine the bit in the 'columns' column.  The bit we want
		** is equal to the columnid - 1.
		*/

		SELECT @columnid = colid
		FROM syscolumns
		WHERE id = @objid AND name = @column

		IF ((@@error <> 0) OR (@columnid IS NULL))
		BEGIN
			if @@trancount > 0
			begin
				ROLLBACK TRANSACTION articlecolumn
				commit tran
			end
			RAISERROR (14020, 16, -1)
			RETURN (1)
		END


		if @allow_queued_tran = 1 and 
		exists (select * from syscolumns WHERE id = @objid and xtype = 189 and name = @column)
		begin
			--
			-- For queued publication, don't mark the timestamp column in the column bitmap
			-- Refer to sp_helparticlecolumns
			--
			IF lower(@operation collate SQL_Latin1_General_CP1_CS_AS) = N'add'
				-- Set bit to indicate the timestamp column should be scripted out
				-- Also need to set to use explicit column name list at the same time.
				update sysarticles set status = (status | 32) | 8  where artid = @artid
			else
				-- Clear the bit
				update sysarticles set status = status & ~32 where artid = @artid

			if @@error <> 0
			BEGIN
				if @@trancount > 0
				begin
					ROLLBACK TRANSACTION articlecolumn
					commit tran
				end
				RETURN (1)
			END

			-- mark for synctran proc refresh
			select @fSynctranColChanged = 1			
		end
		else
		begin

			/*
			** Obtain the byte offset and the bit offset, then set the
			** mask column for the bit we want to turn on.
			*/

			SELECT @word = CONVERT(tinyint, 16 - FLOOR((@columnid-1)/16))
			SELECT @bit = (@columnid-1) % 16

			IF LOWER(@operation collate SQL_Latin1_General_CP1_CS_AS) = N'add'
				SELECT @mval = POWER(2, @bit)
			ELSE
				SELECT @mval = ~POWER(2, @bit)

			select @mask = convert( binary(2), substring( convert( nchar(2), convert( binary(4), @mval ) ), 2, 1 ) )

			/*
			** Save the columns column in a temporary local variable so we
			** can twiddle the bit and then put it back into the table.
			*/

			SELECT @columns = columns
			FROM sysarticles
			WHERE name = @article AND pubid = @pubid
			if(@change_active = 2) -- Only post if it came from sp_repladd(drop)column
			begin
				exec sp_replpostcmd 0, @pubid, @artid, 51, @columns
			end

			/*
			** Fish out the byte we're interested in and save it in a
			** a temporary local variable.  If it's NULL, just set it
			** to 0.  Then apply the bitwise operator OR to twiddle the
			** bit in the old byte and save it in another temporary
			** local variable @newbyte.
			*/
			SELECT @oldword = CONVERT( binary(2), SUBSTRING( CONVERT( nvarchar,@columns), @word, 1) )

			IF @oldword IS NULL SELECT @oldword = 0x0000

			IF LOWER(@operation collate SQL_Latin1_General_CP1_CS_AS) = N'add'
				SELECT @newword = CONVERT(binary(2), convert(smallint, @oldword) | @mask)
			ELSE
				SELECT @newword = CONVERT(binary(2), convert(smallint, @oldword ) & @mask)

			SELECT @columns = CONVERT(binary(32), STUFF( convert(nchar(16),@columns), @word, 1, convert( nchar(1), @newword)))
			SELECT @idx = @idx + 1

			/*
			** Update the sysarticles table.  Set the bit appropriately for the selected column
			*/

			UPDATE sysarticles
			SET columns = @columns
			WHERE name = @article
			AND pubid = @pubid

			IF @@error <> 0
			BEGIN
				if @@trancount > 0
				begin
					ROLLBACK TRANSACTION articlecolumn
					commit tran
				end
				RAISERROR (14021, 16, -1)
				RETURN (1)
			END

			/* 
			** if the status has changed, call sp_MSarticlecol to update the publication
			** status as appropriate.
			*/

			IF @oldword != @newword
			BEGIN
				/* Update column published status */
				EXECUTE @retcode = dbo.sp_MSarticlecol @artid, @columnid,
										N'publish', @operation
				IF (@@error <> 0 OR @retcode <> 0)
				BEGIN
					if @@trancount > 0
					begin
						ROLLBACK TRANSACTION articlecolumn
						commit tran
					end
					RAISERROR (14021, 16, -1)
					RETURN (1)
				END
				select @fSynctranColChanged = 1
			END

		end -- end of if else block

		-- fetch the next column
		FETCH hCartcolumn INTO @column

	END -- end of while block

    -- Synctran
    /*
    ** If publication is enabled for Synctran and sprocs are auto-generated - regenerate them
    */
	declare @autogen_sync_procs_id bit
		,@ins_proc_id int, @upd_proc_id int, @del_proc_id int, @upd_trig_id int
		,@ins_proc sysname, @upd_proc sysname, @del_proc sysname, @owner sysname, @objname sysname
		,@upd_trig sysname
		,@sync_pubid int
		,@conflict_table_id int, @ins_conflict_proc int
		,@cmd nvarchar(4000)

    select @autogen_sync_procs_id = autogen_sync_procs, @sync_pubid = pubid
    from syspublications where name = @publication

    if  @autogen_sync_procs_id = 1 and @refresh_synctran_procs = 1 and @fSynctranColChanged = 1
    begin
        -- Drop existing synctran procs
        select @owner = user_name(OBJECTPROPERTY(objid, N'OwnerId')) from sysarticles a, syspublications p
        where a.name = @article and
              p.name = @publication and
              a.pubid = p.pubid

        select 	@ins_proc_id = sync_ins_proc, 
        		@upd_proc_id = sync_upd_proc, 
        		@del_proc_id = sync_del_proc, 
				@upd_trig_id = sync_upd_trig,
				@conflict_table_id = conflict_tableid,
				@ins_conflict_proc = ins_conflict_proc
        from sysarticleupdates
	        where pubid = @pubid and artid = @artid

        if @ins_proc_id is not null
        begin
            select @objname = object_name(@ins_proc_id)     
            exec @retcode = dbo.sp_MSdrop_object
                @object_name = @objname,
                @object_owner = @owner
            if @@error <> 0 or @retcode <> 0
                goto UNDO
        end

        if @upd_proc_id is not null
        begin
            select @objname = object_name(@upd_proc_id)     
            exec @retcode = dbo.sp_MSdrop_object
                @object_name = @objname,
                @object_owner = @owner
            if @@error <> 0 or @retcode <> 0
                goto UNDO
        end

        if @del_proc_id is not null
        begin
            select @objname = object_name(@del_proc_id)     
            exec @retcode = dbo.sp_MSdrop_object
                @object_name = @objname,
                @object_owner = @owner
            if @@error <> 0 or @retcode <> 0
                goto UNDO
        end

		if @upd_trig_id is not null
        begin
            select @objname = object_name(@upd_trig_id)     
            exec @retcode = dbo.sp_MSdrop_object
                @object_name = @objname,
                @object_owner = @owner
            if @@error <> 0 or @retcode <> 0
                goto UNDO
        end

		if (@conflict_table_id is not null)
		begin
			select @objname = object_name(@conflict_table_id)     
			exec @retcode = dbo.sp_MSdrop_object
				@object_name = @objname,
				@object_owner = @owner
			if (@@error != 0 or @retcode != 0)
                goto UNDO
		end

		if (@ins_conflict_proc is not null)
		begin
			select @objname = object_name(@ins_conflict_proc)     
			exec @retcode = dbo.sp_MSdrop_object
				@object_name = @objname,
				@object_owner = @owner
			if (@@error != 0 or @retcode != 0)
                goto UNDO
		end
		
        -- Now generate new ones        
        select @ins_proc = N'sp_MSsync_ins_' + SUBSTRING(RTRIM(@article), 1, 100) + N'_' + rtrim(convert(varchar, @sync_pubid))
        select @upd_proc = N'sp_MSsync_upd_' + SUBSTRING(RTRIM(@article), 1, 100) + N'_' + rtrim(convert(varchar, @sync_pubid))
        select @del_proc = N'sp_MSsync_del_' + SUBSTRING(RTRIM(@article), 1, 100) + N'_' + rtrim(convert(varchar, @sync_pubid))
        select @upd_trig = N'sp_MSsync_upd_trig_' + SUBSTRING(RTRIM(@article), 1, 100) + N'_' + rtrim(convert(varchar, @sync_pubid))

        -- check uniqueness of names and revert to ugly guid-based name if friendly name already exists
        if exists (select name from sysobjects where name in (@ins_proc, @upd_proc, @del_proc))
        begin
            declare @guid_name nvarchar(36)
            select @guid_name =  convert (nvarchar(36), newid())
            -- remove '-' from guid name because rpc can't handle '-'
            select @guid_name = replace (@guid_name,N'-',N'_')
            select @ins_proc = N'sp_MSsync_ins_' + @guid_name
            select @upd_proc = N'sp_MSsync_upd_' + @guid_name
            select @del_proc = N'sp_MSsync_del_' + @guid_name
            select @upd_trig = N'sp_MSsync_upd_trig' + @guid_name
        end

        if @ins_proc IS NULL
        begin
            RAISERROR (14043, 11, -1, N'@ins_proc')
            goto UNDO
        end

        if @upd_proc IS NULL
        begin
            RAISERROR (14043, 11, -1, N'@upd_proc')
            goto UNDO
        end

        if @del_proc IS NULL
        begin
            RAISERROR (14043, 11, -1, N'@del_proc')
            goto UNDO
        end

        if @upd_trig IS NULL
        begin
            RAISERROR (14043, 11, -1, N'@del_proc')
            goto UNDO
        end

        exec @retcode = dbo.sp_MSgen_sync_tran_procs @publication, @article, @ins_proc, @upd_proc, @del_proc, @upd_trig

        IF @@ERROR <> 0 OR @retcode <> 0
            goto UNDO

        --retrieve sproc id's, fail if they don't exist
        SELECT @ins_proc_id = id FROM sysobjects WHERE name = @ins_proc
        SELECT @upd_proc_id = id FROM sysobjects WHERE name = @upd_proc
        SELECT @del_proc_id = id FROM sysobjects WHERE name = @del_proc
        SELECT @upd_trig_id = id FROM sysobjects WHERE name = @upd_trig

        IF (@ins_proc_id IS NULL) OR (@upd_proc_id IS NULL) OR (@del_proc_id IS NULL)
        BEGIN
            if @ins_proc_id IS NULL RAISERROR (20500, 16, 1, @ins_proc)
            if @upd_proc_id IS NULL RAISERROR (20500, 16, 1, @upd_proc)
            if @del_proc_id IS NULL RAISERROR (20500, 16, 1, @del_proc)
            if @upd_trig_id IS NULL RAISERROR (20500, 16, 1, @upd_trig)
            goto UNDO
        END

        -- perform update in sysarticleupdates
        update sysarticleupdates set sync_ins_proc = @ins_proc_id, sync_upd_proc = @upd_proc_id, 
            sync_del_proc = @del_proc_id,
            sync_upd_trig = @upd_trig_id
        where pubid = @pubid and artid = @artid
		if @@error <> 0
			goto UNDO


		--
		-- create the conflict tran table and table if necessary
		--
		if (@allow_queued_tran = 1)
		begin
			exec @retcode = dbo.sp_MSmakeconflicttable @article, @publication, 0
			IF (@@ERROR != 0 OR @retcode != 0)
	            goto UNDO
			exec @retcode = dbo.sp_MSmaketrancftproc @article, @publication
			IF (@@ERROR != 0 OR @retcode != 0)
	            goto UNDO
		end 
		
        IF @@ERROR <> 0
        BEGIN
            RAISERROR (20501, 16, -1)
            goto UNDO
         END
    end
    -- end synctran

	-------------------------------------------------------------------
	-- active article fixups
	-------------------------------------------------------------------

	if @change_active<> 0 and @fSynctranColChanged = 1 or
		-- Besides schema change, we automatically refresh article view if there are 
		-- subscriptions. We don't refresh the article view otherwise to avoid the view
		-- being dropped and recreated when adding columns into the partition during
		-- the creation of the article.
		exists (select * from syssubscriptions where artid = @artid and
			srvid >= 0)
	BEGIN
		-----------------------------------
		-- regenerate the article view  
		-----------------------------------

		declare @view_name nvarchar(386)
		declare @filter_clause nvarchar(4000)
		declare @sync_objid int
		declare @art_type tinyint

		select @sync_objid = sa.sync_objid, @filter_clause = sa.filter_clause, @art_type = sa.type
							 FROM sysarticles sa JOIN syspublications sp ON sa.pubid = sp.pubid
							 WHERE sa.name = @article 
							 AND sp.name = @publication
		-- Only invoke sp_articleview if not manual view and not manual filter
		if ( @art_type & 0x4 <> 4 and @art_type & 0x2 <> 2 )
		begin 
			select @view_name = object_name( @sync_objid )

			exec @retcode = dbo.sp_articleview @publication = @publication, 
											@article = @article,
											@view_name = @view_name,
											@filter_clause = @filter_clause,
											@change_active = @change_active,
											@force_invalidate_snapshot = @force_invalidate_snapshot,
											@force_reinit_subscription = @force_reinit_subscription

			IF @@ERROR <> 0 OR @retcode <> 0
        		    goto UNDO
		end
	END

	-- sp_repldropcolumn used @change_active = 2 to prepare, don't invalidate or reinitialize
	if @change_active <> 2 	and
		-- @ignore_distributor is set to 1 when removing replication forcefully. In that
		-- case, no need to check or reinit
		@ignore_distributor = 0
	begin
		-- Have to call this stored procedure to invalidate existing snapshot or reint
		-- subscriptions if needed
        EXECUTE @retcode  = dbo.sp_MSreinit_article
            @publication = @publication, 
            @article = @article,
			@need_new_snapshot = 1,
			@need_reinit_subscription = 1
			,@force_invalidate_snapshot = @force_invalidate_snapshot	/* Force invalidate existing snapshot */
			,@force_reinit_subscription = @force_reinit_subscription	/* Force reinit subscription */
        IF @@ERROR <> 0 OR @retcode <> 0
			GOTO UNDO
	end

    /*
    ** Force the article cache to be refreshed with the new definition.
	** Nothing to flush if brute force cleanup.
    */
	if ( @ignore_distributor = 0 )
		EXECUTE dbo.sp_replflush


    COMMIT TRANSACTION
END
return (0)
UNDO:
	if @@trancount > 0
    begin
        ROLLBACK TRANSACTION articleview
        commit tran
    end
    RETURN (1)
go
 
EXEC dbo.sp_MS_marksystemobject sp_articlecolumn
GO

print ''
print 'Creating procedure sp_helparticlecolumns'
go
CREATE PROCEDURE sp_helparticlecolumns (
    @publication sysname,            /* The publication name */
    @article    sysname              /* The article name */
    ) AS

    /*
    ** Declarations.
    */

    DECLARE @columns binary(32)
    DECLARE @pubid int
    DECLARE @retcode int
    DECLARE @username sysname

    SELECT @username = suser_sname()

    /*
    ** Parameter Check: @article.
    ** The @article name must conform to the rules for identifiers.
    */

    IF @article IS NULL
        BEGIN
            RAISERROR (14043, 16, -1, '@article')
            RETURN (1)
        END
    
    /*
    EXECUTE @retcode = dbo.sp_validname @article

    IF @retcode <> 0
    RETURN (1)
    */

    /*
    ** Parameter Check: @publication.
    ** The @publication name must conform to the rules for identifiers.
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
    ** Security Check. Restrict to 'sysadmin', DBO of publishing database, PAL
    */
    IF is_member(N'db_owner') <> 1
    BEGIN
        exec @retcode = sp_MSreplcheck_pull
            @publication = @publication,
            @given_login = @username
        IF @retcode <> 0 OR @@error <> 0
            RETURN (1)
    END
    
    /*
    ** Get the pubid.
    */

    SELECT @pubid = pubid FROM syspublications WHERE name = @publication

    IF @pubid IS NULL
        BEGIN
            RAISERROR (14043, 11, -1, '@pubid')
            RETURN (1)
        END

    /*
    ** Parameter Check:  @article, @publication.
    ** Check to make sure that the article exists in this publication.
    */

    IF NOT EXISTS (SELECT *
                     FROM sysextendedarticlesview
                    WHERE pubid = @pubid
                      AND name = @article)
        BEGIN
            RAISERROR (20027, 11, -1, @article)
            RETURN (1)
        END


    /*
    ** Error out if this is a not a table based article
    */
    IF NOT EXISTS ( SELECT * FROM sysarticles WHERE name = @article
                          AND pubid = @pubid
                          AND (type & 1) = 1 )
        BEGIN
            RAISERROR (14112, 11, -1 )
            RETURN (1)
        END

	declare @status tinyint
	declare @objid int

    SELECT @columns = columns, @status = status, @objid = objid
      FROM sysarticles
     WHERE name = @article
       AND pubid = @pubid

	-- Get the timestamp column id

    SELECT 'column id' = colid,
           'column'    = name,
		   -- 189 is timestamp col
		   -- When the status is set, return timestamp col as published to DMO 
		   -- although it is not in the bitmap used by
		   -- the logreader. Thus, the timestmap will be scripted out and created at the subscriber
		   -- but the value will be generated by subscriber not the logreader.
		   -- 32 is the status bit of keeping timestamp
		   'published' = case xtype when 189
				then convert(bit, @status & 32)
				else convert(bit, 0) end |
				convert(bit, convert( varbinary, substring( convert( nvarchar, @columns ), 16 - floor((colid-1)/16),1 )) & power( 2, ((colid-1)%16)))
	  FROM syscolumns
     WHERE id = @objid
go
 
EXEC dbo.sp_MS_marksystemobject sp_helparticlecolumns
GO

print ''
print 'Creating procedure sp_helppublication'
go


CREATE PROCEDURE sp_helppublication (
        @publication sysname = '%',     /* The publication name */
        @found int = 23456 OUTPUT            /* a flag indicate returning row */
        ) AS

    SET NOCOUNT ON

    /*
    ** Declarations.
    */

    DECLARE @pubid      int
    DECLARE @has_subscription bit
    DECLARE @retcode int
    DECLARE @no_row bit
    DECLARE @publish_bit int
    DECLARE @pubname sysname
    DECLARE @username sysname
    
    SELECT @publish_bit = 1
    SELECT @username = suser_sname()
    SELECT @retcode = 0
    
    /*
    ** Check if the database is published.
    */
    IF NOT EXISTS (SELECT * FROM master.dbo.sysdatabases
        WHERE name = db_name() collate database_default
        AND (category & @publish_bit) = @publish_bit)
        RETURN(0)

    /*
    ** Initializations.
    */
    IF @found = 23456 
    BEGIN
        SELECT @no_row=0
    END
    ELSE
    BEGIN
        SELECT @no_row=1
    END

    /*
    ** Parameter Check:  @publication.
    ** Check to make sure that there are some publications
    ** to display.
    */

    IF @publication IS NULL
        BEGIN
            RAISERROR (14043, 16, -1, '@publication')
            RETURN (1)
        END
    
    IF @publication <> '%'
        BEGIN
            
            EXECUTE @retcode = dbo.sp_validname @publication

            IF @retcode <> 0
            RETURN (1)
        END

    IF  NOT EXISTS (SELECT * FROM syspublications
        WHERE name like @publication)

    BEGIN
        SELECT @found = 0
        RETURN (0) 
    END
    ELSE
    BEGIN
        SELECT @found = 1
        IF @no_row <>0
            RETURN(0)
    END

    /*
    ** Create a temp table of pubids identifying publications that the current user has access to
    */
    CREATE TABLE #accessiblepubs (pubid int)

    DECLARE hC  CURSOR LOCAL FAST_FORWARD FOR 
        SELECT pubid, name FROM syspublications WHERE name like @publication
    OPEN hC
    FETCH hC INTO @pubid, @pubname
    WHILE (@@fetch_status <> -1)
    BEGIN
        IF is_member(N'db_owner') <> 1
        BEGIN
            exec @retcode = sp_MSreplcheck_pull
                @publication = @pubname,
                @raise_fatal_error = 0,
                @given_login = @username
	END			
        IF (is_member(N'db_owner') = 1) OR (@retcode = 0 AND @@error = 0)
            INSERT INTO #accessiblepubs values(@pubid)

        FETCH hC INTO @pubid, @pubname
    END
    CLOSE hC
    DEALLOCATE hC

    /*
    ** Join the table of accessible pubids to the publication entries retrieved from syspublications
    */

    SELECT 'pubid'                  = outter.pubid,
           'name'                   = name,
           'restricted'             = 0,
           'status'                 = status,
           -- using 'task' is for backward compatibilty
           'task'                   = convert(int, 1),
           'replication frequency'  = repl_freq,
           'synchronization method' = sync_method,
           'description'            = description,
           'immediate_sync'            = immediate_sync,
           'enabled_for_internet'    = enabled_for_internet,
           'allow_push'             = allow_push,
           'allow_pull'             = allow_pull,
           'allow_anonymous'        = allow_anonymous,
           'independent_agent'        = independent_agent,
           'immediate_sync_ready'    = immediate_sync_ready,
           -- SyncTran
           'allow_sync_tran'        = allow_sync_tran,
           'autogen_sync_procs'        = autogen_sync_procs,
           'snapshot_jobid'         = snapshot_jobid,
           'retention'              = retention,
           'has subscription'       = case when EXISTS (select * from syssubscriptions where artid in 
            						  (select artid from sysextendedarticlesview where pubid = outter.pubid ) )
									  then 1 else 0 end,
           'allow_queued_tran'      = allow_queued_tran,
           -- Portable snapshot
           'snapshot_in_defaultfolder'      = snapshot_in_defaultfolder,
           'alt_snapshot_folder'    = alt_snapshot_folder,
           -- Pre/post-snapshot commands
           'pre_snapshot_script'    = pre_snapshot_script,
           'post_snapshot_script'   = post_snapshot_script,
           -- Snapshot compression
           'compress_snapshot'      = compress_snapshot,
           -- Post 7.0 ftp support
           'ftp_address'            = ftp_address,
           'ftp_port'               = ftp_port,
           'ftp_subdirectory'       = ftp_subdirectory,
           'ftp_login'              = ftp_login,
		   'allow_dts'				= allow_dts,
		   'allow_subscription_copy'  = allow_subscription_copy,
		   -- 7.5 Queued updates
		   'centralized_conflicts' 	= centralized_conflicts, 
		   'conflict_retention'		= conflict_retention, 
		   'conflict_policy'		= conflict_policy,
		   'queue_type'				= queue_type,
		'backward_comp_level' = backward_comp_level,
		'publish_to_AD' =		case when ad_guidname is NULL then 0 else 1 end 
      FROM syspublications outter, #accessiblepubs acc
     WHERE name LIKE @publication
        and outter.pubid = acc.pubid
     ORDER BY name

    RETURN (0)
go
 
EXEC dbo.sp_MS_marksystemobject sp_helppublication
GO

-- sp_helppublication_snapshot not used anymore

print ''
print 'Creating procedure sp_helpsubscription'
go

CREATE PROCEDURE sp_helpsubscription
    @publication sysname = '%',    /* The publication name */
    @article sysname = '%',        /* The article name */
    @subscriber sysname = N'%',      /* The subscriber name */
    @destination_db sysname = '%',
    @found int = 23456 OUTPUT
    AS

    SET NOCOUNT ON

    /*
    ** Declarations.
    */

    DECLARE @retcode int
    DECLARE @subscriber_bit smallint
    DECLARE @no_row bit
    DECLARE @srvid smallint
    DECLARE @pubid int
    DECLARE @artid int
    DECLARE @immediate_sync bit
    DECLARE @subscription_type_id int
    DECLARE @sync_typeid int
    DECLARE @publish_bit int
    DECLARE @orig_publication sysname    
    DECLARE @full_subscription bit

    DECLARE @distributor    sysname
    DECLARE @distributiondb sysname
    DECLARE @distproc       NVARCHAR(255)
    DECLARE @dbname         sysname    

    SELECT @publish_bit = 1
    SELECT @distributor = NULL
    SELECT @distributiondb = NULL
    SELECT @distproc = NULL
    SELECT @dbname = NULL
    SELECT @orig_publication = @publication

    /* Security check. To public. */

    /*
    ** Check if the database is published.
    */
    IF NOT EXISTS (SELECT * FROM master..sysdatabases
                    WHERE name = db_name() collate database_default
                      AND (category & @publish_bit) = @publish_bit)
        RETURN(0)

    /*
    ** Initializations of @now_row.
    */
    IF @found = 23456 
    BEGIN
        SELECT @no_row=0
    END
    ELSE
    BEGIN
        SELECT @no_row=1
    END

    /*
    ** Initializations.
    */
    SELECT @subscriber_bit = 4

    /*
    ** Parameter Check:  @subscriber.
    */
    IF @subscriber IS NULL
        BEGIN
            RAISERROR (14043, 16, -1, '@subscriber')
            RETURN (1)
        END

    /*
    ** Parameter Check:  @subscriber.
    ** Check if remote server is defined as a subscription server, and
    ** that the name conforms to the rules for identifiers.
    */

    IF @subscriber <> '%'
        BEGIN

            EXECUTE @retcode = dbo.sp_validname @subscriber
            select @subscriber = UPPER(@subscriber)

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
    ** Parameter Check:  @publication.
    ** If the publication name is specified, check to make sure that it
    ** conforms to the rules for identifiers and that the publication
    ** actually exists.  Disallow NULL.
    */

    IF @publication IS NULL
        BEGIN
            RAISERROR (14043, 16, -1, '@publication')
            RETURN (1)
        END

    IF @publication <> '%'
        BEGIN

            EXECUTE @retcode = dbo.sp_validname @publication

            IF @retcode <> 0
                RETURN (1)

            IF NOT EXISTS (SELECT * FROM syspublications WHERE name = @publication)
                BEGIN
                   RAISERROR (20026, 11, -1, @publication)
                   RETURN (1)
                END

        END

    /*
    ** Parameter Check:  @article.
    ** If the article name is specified, check to make sure that it
    ** conforms to the rules for identifiers and that the article
    ** actually exists.  Disallow NULL.
    **
    ** If @article is 'all', only return one entry for the whole publication
    ** for full subscriptions (subscriptions inlcluding all the articles in a
    ** publication).
    ** 
    */

    IF @article IS NULL
        BEGIN
            RAISERROR (14043, 16, -1, '@article')
            RETURN (1)
        END

    IF LOWER(@article) <> 'all' 
    BEGIN
        IF @article <> '%'
            BEGIN
                
                /*
                EXECUTE @retcode = dbo.sp_validname @article

                IF @retcode <> 0
                RETURN (1)
                */

                IF NOT EXISTS (SELECT *
                                 FROM sysextendedarticlesview
                                WHERE name = @article
                                  AND pubid IN (SELECT pubid
                                                  FROM syspublications
                                                 WHERE name LIKE @publication))
                    BEGIN
                        RAISERROR (20027, 11, -1, @article)
                        RETURN (1)
                    END

            END


        IF EXISTS (SELECT * 
              FROM syssubscriptions sub,
                   master..sysservers ss,
                   syspublications pub,
                   sysextendedarticlesview art
             WHERE ((@subscriber = N'%') OR (ss.srvname = @subscriber collate database_default))
               AND sub.srvid = ss.srvid
               AND pub.name LIKE @publication
               AND art.name LIKE @article
               AND art.pubid = pub.pubid
               AND sub.artid = art.artid
               AND ((@destination_db = N'%') OR (sub.dest_db = @destination_db))
               AND (sub.login_name = suser_sname(suser_sid()) OR 
                    is_srvrolemember('sysadmin') = 1 OR
                    is_member ('db_owner') = 1)
                )

        BEGIN
            SELECT @found = 1
            IF @no_row <> 0 RETURN (0)
        END
        ELSE
        BEGIN
            SELECT @found = 0
            RETURN(0)
        END
    END

/*
        SELECT 'subscriber'           = ss.srvname,
               'publication'          = pub.name,
               'article'              = art.name,
               'destination database' = sub.dest_db,
               'subscription status'  = sub.status,
               'synchronization type' = sub.sync_type
          FROM syssubscriptions sub,
               master..sysservers ss,
               syspublications pub,
               sysextendedarticlesview art
         WHERE UPPER(ss.srvname) LIKE UPPER(@subscriber) collate database_default
           AND sub.srvid = ss.srvid
           AND pub.name LIKE @publication collate database_default
           AND art.name LIKE @article collate database_default
           AND art.pubid = pub.pubid
           AND sub.artid = art.artid
           AND (sub.login_name = suser_sname(suser_sid()) collate database_default OR 
                    is_srvrolemember('sysadmin') = 1 OR
                    is_member ('db_owner') = 1)
                )
         ORDER BY subscriber, publication, article
*/    

    CREATE TABLE #helpsubscription 
    (
    /* Info that will be returned */
    subscriber sysname collate database_default not null,
    publication sysname collate database_default not null,
    article sysname collate database_default not null,
    destination_db sysname collate database_default not null,
    status tinyint NOT NULL,
    sync_type tinyint NOT NULL,
    subscription_type int NOT NULL,
    full_subscription bit NOT NULL, /* full subscription or not */
    distribution_jobid binary(16) NULL,
    subscription_name nvarchar(255) collate database_default not null,
    -- SyncTran
    update_mode int NOT NULL,
    loopback_detection bit not null
    )


    /* Open a CURSOR LOCAL FOR subscriber/destination_db and publication pair 
    **
    ** Get subscriptions
    ** sa or dbo can see every subscriptions while
    ** others only see their own.
    */

    /* 
    ** Performance Optimization: Eliminate the 'LIKE' clause for publication name.
    **                           Empirical evidence shows almost 50% speed improvement when
    **                           opening the cursor if publication name is provided.
    */
    IF (@publication <> '%')
        DECLARE hChelpsubscription_pub CURSOR LOCAL FAST_FORWARD FOR
            SELECT DISTINCT ss.srvname,
                   pub.name,
                   sub.dest_db,
                   pub.pubid,
                   sub.srvid,
                   pub.immediate_sync
              FROM syssubscriptions sub,
                   master..sysservers ss,
                   syspublications pub,
                   sysextendedarticlesview art
             WHERE ((@subscriber = N'%') OR (UPPER(ss.srvname) = UPPER(@subscriber) collate database_default))
               AND sub.srvid = ss.srvid
               AND pub.name = @publication collate database_default
               AND art.pubid = pub.pubid
               AND sub.artid = art.artid
               AND ((@destination_db = N'%') OR (sub.dest_db = @destination_db))
               AND (sub.login_name = suser_sname(suser_sid()) OR 
                        is_srvrolemember('sysadmin') = 1 OR
                        is_member ('db_owner') = 1)       
               FOR READ ONLY
    ELSE 
        DECLARE hChelpsubscription_pub CURSOR LOCAL FAST_FORWARD FOR
            SELECT DISTINCT ss.srvname,
                   pub.name,
                   sub.dest_db,
                   pub.pubid,
                   sub.srvid,
                   pub.immediate_sync
              FROM syssubscriptions sub,
                   master..sysservers ss,
                   syspublications pub,
                   sysextendedarticlesview art
             WHERE ((@subscriber = N'%') OR (UPPER(ss.srvname) = UPPER(@subscriber) collate database_default))
               AND sub.srvid = ss.srvid
               AND art.pubid = pub.pubid
               AND sub.artid = art.artid
               AND ((@destination_db = N'%') OR (sub.dest_db = @destination_db))
               AND (sub.login_name = suser_sname(suser_sid()) OR 
                        is_srvrolemember('sysadmin') = 1 OR
                        is_member ('db_owner') = 1)       
               FOR READ ONLY
 
    OPEN hChelpsubscription_pub
    FETCH hChelpsubscription_pub INTO @subscriber, @publication, 
        @destination_db, @pubid, @srvid, @immediate_sync
        
    WHILE (@@fetch_status <> -1)
    BEGIN

        /* 
        ** Is it a full subscription ? i.e. Does it include all the articles? 
        **
        */

        IF NOT EXISTS (SELECT * FROM sysextendedarticlesview art WHERE
                art.pubid = @pubid and 
                NOT EXISTS (SELECT * from syssubscriptions sub WHERE
                    sub.artid = art.artid and
					sub.srvid = @srvid and
					sub.dest_db = @destination_db))
        BEGIN
            /* Do all the subscriptions on the publication have same
            ** sync_type and subscription_type ?
            */
  
              /* 
            ** Get subscription type on the publication
            */ 
            SELECT @subscription_type_id = subs.subscription_type,
                @sync_typeid = subs.sync_type 
                FROM 
                sysextendedarticlesview art, syssubscriptions subs  
                WHERE
                art.pubid = @pubid AND
                subs.srvid = @srvid AND
                subs.dest_db = @destination_db AND
                subs.artid = art.artid


            /* 
            ** if the subscription all have the same subscription type
            ** and sync_type
            */
            IF NOT EXISTS (SELECT * from 
                sysextendedarticlesview art, syssubscriptions subs where 
                art.pubid = @pubid AND
                subs.srvid = @srvid AND
                subs.dest_db = @destination_db AND
                subs.artid = art.artid AND
                (subscription_type <> @subscription_type_id OR
                sync_type <> @sync_typeid))
                

                SELECT @full_subscription = 1
            ELSE
                SELECT @full_subscription = 0
        END
        ELSE
        BEGIN
            SELECT @full_subscription = 0
        END
            
        /* 
        ** If it is a full subscription and the @article is 'all',
        ** only return one entry for the whole publication.
        ** Always return one row per publication if @article is 'ALL'
        */
        IF    LOWER(@article) = 'all'
        BEGIN    
            INSERT INTO #helpsubscription 
                SELECT TOP 1 @subscriber, @publication, @article, @destination_db,
                    sub.status, sub.sync_type, sub.subscription_type,
                    @full_subscription, sub.distribution_jobid,
                    @subscriber + ':' + @destination_db  ,
                    -- NOTE: For Queued case: we will always return 2/3 for the 4/5 case
                    -- since we overload update_mode based on queue_type
                    case 	when sub.update_mode = 4 then 2
                    		when sub.update_mode = 5 then 3
                    		else sub.update_mode
                    end,
                    sub.loopback_detection
                    -- end SyncTran
                    FROM syssubscriptions sub, sysextendedarticlesview art 
                    WHERE sub.srvid = @srvid AND
                        sub.dest_db = @destination_db AND
                        sub.artid = art.artid and
                        art.pubid = @pubid
        END
        ELSE
        BEGIN
            /*
            ** Get subscriptions
            ** sa or dbo can see every subscriptions while
            ** others only see their own.
            */

            INSERT INTO #helpsubscription 
                SELECT    @subscriber, @publication, art.name, @destination_db,
                    sub.status, sub.sync_type, sub.subscription_type,
                    @full_subscription, sub.distribution_jobid,
                    @subscriber + ':' + @destination_db + ':' + art.name,
                    -- NOTE: For Queued case: we will always return 2/3 for the 4/5 case
                    -- since we overload update_mode based on queue_type
                    case 	when sub.update_mode = 4 then 2
                    		when sub.update_mode = 5 then 3
                    		else sub.update_mode
                    end,
                    sub.loopback_detection
                    -- end SyncTran
                    FROM
                    syssubscriptions sub, sysextendedarticlesview art WHERE
                        sub.srvid = @srvid AND
                        sub.dest_db = @destination_db AND
                        art.pubid = @pubid AND
                        art.name LIKE @article AND
                        sub.artid = art.artid AND
                        (sub.login_name = suser_sname(suser_sid()) OR 
                         is_srvrolemember('sysadmin') = 1 OR
                         is_member ('db_owner') = 1)     
        END
        FETCH hChelpsubscription_pub INTO @subscriber, @publication, 
            @destination_db, @pubid, @srvid, @immediate_sync
    END

    CLOSE hChelpsubscription_pub
    DEALLOCATE hChelpsubscription_pub

    CREATE TABLE #dist_agent_properties
    (
        job_id					VARBINARY(16) NOT NULL,
        offload_enabled			bit NULL,
        offload_server			sysname collate database_default null,
        dts_package_name		sysname collate database_default null,
        dts_package_location	int NULL,
		status					int NULL  
    )

    EXEC @retcode = dbo.sp_helpdistributor @rpcsrvname = @distributor OUTPUT,
                                           @distribdb = @distributiondb OUTPUT
    IF @retcode <> 0
        RETURN @retcode

    SELECT @distributor = RTRIM(@distributor)

    -- Get distribution agent properties 
    SELECT @distproc = @distributor + '.' + @distributiondb + '.dbo.sp_MSenumdistributionagentproperties'

    SELECT @dbname = db_name()

    INSERT INTO #dist_agent_properties
    	EXEC @retcode = @distproc @publisher 	= @@SERVERNAME, 
                                @publisher_db	= @dbname, 
                                @publication 	= @orig_publication            

    /*
    ** Get subscriptions
    */
    SELECT 'subscriber'           = hs.subscriber,
           'publication'          = hs.publication,
           'article'              = hs.article,
           'destination database' = hs.destination_db,
           'subscription status'  = case
				-- distributionstatus = 0 means that the subscription has been deactivated.  
				when hs.status = 2 and ap.status = 0 then 0
				else hs.status
				end,
           'synchronization type' = hs.sync_type,
           'subscription type'    = hs.subscription_type,
           'full subscription'    = hs.full_subscription,
           'subscription_name'      = hs.subscription_name,
              -- SyncTran
           'update mode'          = hs.update_mode,
           'distribution job id' = hs.distribution_jobid,
           'loopback_detection'  = hs.loopback_detection,
           'offload_enabled'     = ap.offload_enabled,
           'offload_server'      = ap.offload_server,
           'dts_package_name'    = ap.dts_package_name,
           'dts_package_location' = ap.dts_package_location
      FROM #helpsubscription hs
      LEFT OUTER JOIN #dist_agent_properties ap
      ON hs.distribution_jobid = ap.job_id  
      ORDER BY subscriber, publication, article

    DROP TABLE #dist_agent_properties
go
 
EXEC dbo.sp_MS_marksystemobject sp_helpsubscription
GO

print ''
print 'Creating procedure sp_articlefilter'
go
create procedure sp_articlefilter (
	@publication sysname,           /* publication name */
	@article sysname,             /* article name */
	@filter_name nvarchar (386) = NULL,     /* name of filter procedure*/
	@filter_clause ntext = NULL,               /* article's filter clause */
	@force_invalidate_snapshot bit = 0,	/* Force invalidate existing snapshot */
	@force_reinit_subscription bit = 0	/* Force reinit subscription */
)
as
BEGIN
	declare @pubid smallint
			,@table_name sysname
			,@user_name sysname
			,@qualified_table_name nvarchar (258)
			,@filter_id int
			,@type tinyint        
			,@previous_proc nvarchar(386)
			,@retcode int
			,@site sysname
			,@db sysname
			,@owner sysname
			,@object nvarchar(386)
			,@artid int
			,@active tinyint
			,@obid int
			,@view_id int
			,@cmd nvarchar(4000)
			,@allow_sync_tran bit
			,@allow_queued_tran bit

    select @active = 2

    /*
    ** Security Check.
    */
    exec @retcode = dbo.sp_MSreplcheck_publish
    if @@ERROR <> 0 or @retcode <> 0
        return(1)

    /*
    ** Parameter Check:  @publication.
    ** Make sure that the publication exists and that it conforms to the
    ** rules for identifiers.
    */
    if @publication is null
           begin
              RAISERROR (14043, 16, -1, '@publication')
              return (1)
           END
    
    execute @retcode = dbo.sp_validname @publication
    if @retcode <> 0
    RETURN (1)

	select @pubid = pubid
		,@allow_sync_tran = allow_sync_tran
		,@allow_queued_tran = allow_queued_tran
	from syspublications where name = @publication

        if @pubid is null
           begin
            RAISERROR (20026, 11, -1, @publication)
            return (1)
           end

    /*
    ** Parameter Check:  @article.
    ** Check to make sure that the article exists in the publication.
    */

    if @article is null
       begin
              RAISERROR (14043, 16, -1, '@article')
              return (1)
           end
        /*
        execute @retcode = dbo.sp_validname @article
        if @retcode <> 0
       return (1)
       */

    /*
    ** Get the article information.
    */
    select @artid = art.artid, @table_name = so.name, @type = art.type,
       @filter_id = art.filter, @user_name = USER_NAME(so.uid)
		,@view_id = ISNULL(art.sync_objid, art.objid)
       from sysarticles art, sysobjects so
       where art.pubid = @pubid
       and art.name = @article
       and art.objid = so.id

    /*
    ** Fail if there is no article information.
    */
    if @artid is null
       begin
              RAISERROR (20027, 11, -1, @article)
              return (1)
       end

        /*
        ** Error out if this is a not a table based article
        */
        IF NOT EXISTS ( SELECT * FROM sysarticles WHERE artid = @artid
                          AND pubid = @pubid
                          AND (type & 1) = 1 )
        BEGIN
            RAISERROR (14112, 11, -1 )
            RETURN (1)
        END



    /*
    ** Make sure a valid @filter_name was provided and it is
    ** a valid name.
    */
    if datalength(@filter_clause) > 0  
    begin

        /*
        ** Make sure a valid @filter_name was provided and it is
        ** a valid name.
        */

        if @filter_name is null
        begin
           RAISERROR (14043, 16, -1, '@filter_name')
           return (1)
        end
        
        select @object = PARSENAME( @filter_name, 1 )
        select @owner  = PARSENAME( @filter_name, 2 )
        select @db     = PARSENAME( @filter_name, 3 )
        select @site   = PARSENAME( @filter_name, 4 )

         if @object IS NULL
               return 1

		if @owner is NULL
			select @owner = user_name()
		select @object = quotename(@owner) + N'.' + quotename(@object)
    end

	-- Check if there are snapshot or subscriptions and raiserror if needed.
    EXECUTE @retcode  = dbo.sp_MSreinit_article
        @publication = @publication, 
        @article = @article,
		@need_new_snapshot = 1,
		@need_reinit_subscription = 1
		,@force_invalidate_snapshot = @force_invalidate_snapshot	/* Force invalidate existing snapshot */
		,@force_reinit_subscription = @force_reinit_subscription	/* Force reinit subscription */
		,@check_only = 1
    IF @@ERROR <> 0 OR @retcode <> 0
		return 1

	begin tran
    save TRANSACTION articlefilter

    /*
    ** If the article has a generated filter (not manually created), then
    ** drop the current filter before creating the new one.
    */
    if ((@type & 0x3) <> 0x3) and @filter_id <> 0
       begin
          if exists (select * from sysobjects where id = @filter_id
                and type = 'RF')
         begin
			exec dbo.sp_MSget_qualified_name @filter_id, @previous_proc output
			exec ('drop procedure ' + @previous_proc)
			if @@error <> 0
			   goto UNDO
         end

       end


    /*
    ** make an owner qualified table name for these operations name
    */

    select @qualified_table_name = quotename(@user_name) + '.' + quotename(@table_name)

    -- Drop replication filter if it exists.
    -- Note: upgrade needs this logic
    if datalength(@filter_clause) > 0
        and exists (select * from sysobjects where id = object_id(@object)
                and type = 'RF')
    begin
          exec ('drop procedure ' + @object)
        if @@error <> 0
           goto UNDO
    end


    /*
    ** If there is a @filter_clause, create the new filter and
    ** update the article filter id and filter_clause.
    **/
    if datalength(@filter_clause) > 0
       begin
		declare @subst_clause nvarchar(4000)
		select @subst_clause = @filter_clause

		exec @retcode = sp_MSsubst_filter_names @user_name, @table_name, @subst_clause output
		if @retcode <> 0 or @@error <> 0
			goto UNDO
        exec ('create procedure ' + @object +
            ' for replication as ' +
            'if exists (select * from ' + @qualified_table_name +
            ' where ' + @subst_clause +
            ') return 1 else return 0')
        if @@error <> 0
           goto UNDO

		if (@user_name in ('dbo','INFORMATION_SCHEMA'))
		begin
			exec @retcode = dbo.sp_MS_marksystemobject @object
			if @@error <> 0 
				goto UNDO
		end

        select @filter_id = id  from sysobjects where id = object_id(@object)
            and type = 'RF'
        if @filter_id is null or @filter_id = 0
           begin
              RAISERROR (15001, 11, -1, @object)
              goto UNDO
           end

        /*
        ** Update article
        */
        update sysarticles set filter = @filter_id,
           filter_clause = @filter_clause
           where pubid = @pubid
              and name = @article
		if @@error <> 0
			goto UNDO

       -------------------------------------------------------------
       -- SQL SERVER 7.0 ONLY: update sysobjects, set parent id = underlying
       -- object id
       -------------------------------------------------------------

        select @obid = object_id( @qualified_table_name )
        EXEC @retcode = dbo.sp_MSsetfilterparent @object, @obid
		if @retcode <> 0 or @@error <> 0
			goto UNDO
        EXEC @retcode = dbo.sp_MSsetfilteredstatus @obid
		if @retcode <> 0 or @@error <> 0
			goto UNDO

       end
    else
    BEGIN
        /*
        ** Clear the filter id and filter_clause.
        */
        update sysarticles set filter = 0,
           filter_clause = NULL
           where pubid = @pubid
              and name = @article
		if @@error <> 0
			goto UNDO

        ---------------------------------------------------
        -- SQL SERVER 7.0 ONLY:  remove parent_id from filter proc
        ---------------------------------------------------

        select @obid = object_id( @qualified_table_name )
        if exists ( select * from sysobjects where name = @object
                and type = 'RF')
        begin
		    EXEC @retcode = dbo.sp_MSsetfilterparent @object, 0
        	if @retcode <> 0 or @@error <> 0
				goto UNDO
		end
		EXEC @retcode = dbo.sp_MSsetfilteredstatus @obid
		if @retcode <> 0 or @@error <> 0
			goto UNDO
    END

	-- Have to call this stored procedure to invalidate existing snapshot or reint
	-- subscriptions if needed
    EXECUTE @retcode  = dbo.sp_MSreinit_article
        @publication = @publication, 
        @article = @article,
		@need_new_snapshot = 1,
		@need_reinit_subscription = 1
		,@force_invalidate_snapshot = @force_invalidate_snapshot	/* Force invalidate existing snapshot */
		,@force_reinit_subscription = @force_reinit_subscription	/* Force reinit subscription */
    IF @@ERROR <> 0 OR @retcode <> 0
		GOTO UNDO

    /*
    ** Force the article cache to be refreshed with the new definition.
    */
    EXECUTE dbo.sp_replflush
    COMMIT TRANSACTION
	return 0
UNDO:
	if @@trancount > 0
    begin
        ROLLBACK TRANSACTION articlefilter
        commit tran
    end
    RETURN (1)
END
go
 
dump tran master with no_log
go

EXEC dbo.sp_MS_marksystemobject sp_articlefilter
GO

create procedure sp_MSscript_article_view 
@artid int,
@view_name sysname, 
@include_timestamps bit
as
declare @base_objid int
declare @columns varbinary(32)
declare @user_name sysname
declare @table_name sysname
declare @qualified_table_name nvarchar(520)
declare @filter_clause nvarchar(4000)

declare @cmdfrag nvarchar(4000)
declare @separator nvarchar(1)
declare @colname sysname

declare @retcode int

select @table_name = so.name,
	   @base_objid = art.objid,
	   @columns = art.columns,
	   @user_name = USER_NAME(so.uid),
	   @table_name = so.name,
	   @qualified_table_name = QUOTENAME(USER_NAME(so.uid)) + '.' + QUOTENAME(so.name),
	   @filter_clause = art.filter_clause
	   from sysarticles art, sysobjects so
	   where art.artid = @artid
	   and art.objid = so.id

create table #tempcmd( c1 int identity NOT NULL, cmdfrag nvarchar(4000) collate database_default )

insert into #tempcmd (cmdfrag) values ( N'create view ' + QUOTENAME(@view_name) + N'as select ' )

create table #tmp (colid int NOT NULL primary key, name sysname collate database_default not null, published bit NOT NULL)

insert into #tmp select colid, name,
	convert(bit, convert( varbinary, substring( convert( nvarchar(16), @columns ), 16 - floor((colid-1)/16),1 )) & power( 2, ((colid-1)%16)))
	from syscolumns
	where id = @base_objid

if 1 = @include_timestamps
begin
	update #tmp set published = 1 where colid = (select colid from syscolumns c
		where c.id = @base_objid and c.xtype = 189)
end

declare hc  CURSOR LOCAL FAST_FORWARD FOR select name from #tmp
    where published = 1 order by colid asc
open hc
fetch hc into @colname

select @cmdfrag = N''
select @separator = N''

while (@@fetch_status <> -1)
begin
	if datalength( @cmdfrag ) > 3500 
	begin
		insert into #tempcmd(cmdfrag) values (@cmdfrag)
		select @cmdfrag = N''
	end
	select @cmdfrag = @cmdfrag + @separator + quotename(@colname)

	select @separator = N','
	fetch hc into @colname
end            
close hc
deallocate hc

insert into #tempcmd( cmdfrag ) values (@cmdfrag) 

insert into #tempcmd( cmdfrag ) values (N' from ')
insert into #tempcmd( cmdfrag ) values (@qualified_table_name)


insert into #tempcmd( cmdfrag ) values (N' where permissions(' + 
	convert(nvarchar(10), @base_objid)  + ') & 1 = 1 ')

if( @filter_clause is not null and datalength( @filter_clause ) > 0 )
begin
	exec @retcode = sp_MSsubst_filter_names @user_name, @table_name, @filter_clause output
	if @retcode <> 0 or @@error <> 0
		return 1		
	insert into #tempcmd( cmdfrag ) values ('and (' + @filter_clause + ')')
end

select cmdfrag from #tempcmd order by c1 asc

return 0
go

EXEC dbo.sp_MS_marksystemobject sp_MSscript_article_view 
GO


print ''
print 'Creating procedure sp_articleview'
go
create procedure sp_articleview (
	@publication sysname,        /* Publication name */
	@article sysname,          /* Article name */
	@view_name nvarchar (386) = NULL,  /* View name */
	@filter_clause ntext = NULL            /* Article's filter clause */
	,@change_active int = 0
	,@force_invalidate_snapshot bit = 0	/* Force invalidate existing snapshot */
	,@force_reinit_subscription bit = 0	/* Force reinit subscription */
)
as
BEGIN
	declare @pubid smallint
			,@table_name sysname
			,@user_id int
			,@user_name sysname
			,@columns varbinary (32)
			,@name sysname
			,@retcode int
			,@view_id int
			,@type tinyint
			,@table_id int
			,@previous_view sysname
			,@quoted_prev_view sysname
			,@colid int
			,@object sysname
			,@quoted_object nvarchar(512)
			,@artid int
			,@active tinyint
			,@allow_sync_tran bit
			,@allow_queued_tran bit
			,@filter_id int

    select @active = 2

    /*
    ** Security Check.
    */
    exec @retcode = dbo.sp_MSreplcheck_publish
    if @@ERROR <> 0 or @retcode <> 0
        return(1)

    /*
    ** Parameter Check:  @publication.
    ** Make sure that the publication exists and that it conforms to the
    ** rules for identifiers.
    */
    if @publication is null
           begin
              RAISERROR (14043, 16, -1, '@publication')
              return (1)
           END

    execute @retcode = dbo.sp_validname @publication
    if @retcode <> 0
            RETURN (1)

	select @pubid = pubid
		,@allow_sync_tran = allow_sync_tran
		,@allow_queued_tran = allow_queued_tran		
	from syspublications where name = @publication
	if @pubid is null
	begin
		RAISERROR (20026, 11, -1, @publication)
		return (1)
	end

    /*
    ** Parameter Check:  @article.
    ** Check to make sure that the article exists in the publication.
    */

    if @article is null
       begin
              RAISERROR (14043, 16, -1, '@article')
              return (1)
           end
    
    /*
        execute @retcode = dbo.sp_validname @article
        if @retcode <> 0
       return (1)
       */

    /*
    ** Get the article information.
    */
	declare @status tinyint
	declare @objid int
    select @artid = art.artid, @table_name = so.name,
       @user_id = uid, @user_name = USER_NAME(so.uid),
       @columns = art.columns, @type = art.type,
	   @status = art.status,
	   @objid = art.objid,
       @view_id = art.sync_objid, @table_id = art.objid
		,@type = art.type
		,@filter_id = art.filter
       from sysarticles art, sysobjects so
       where art.pubid = @pubid
       and art.name = @article
       and art.objid = so.id

    /*
    ** Fail if there is no article information.
    */
    if @artid is null
       begin
              RAISERROR (20027, 11, -1, @article)
              return (1)
       end

        /*
        ** Error out if this is a not a table based article
        */
        IF NOT EXISTS ( SELECT * FROM sysarticles WHERE artid = @artid
                          AND pubid = @pubid
                          AND (type & 1) = 1 )
            BEGIN
                RAISERROR (14112, 11, -1 )
                RETURN (1)
            END
   
    
	-- Special handling for timestamp column for queued publication.
	-- Although timestamp values are not needed, they have to be presented in bcp files. Otherwise
	-- bcp in will fail with data file format error.

	declare @include_timestamps bit
	select @include_timestamps = 0
	
	if @allow_queued_tran = 1 and @status & 32 <> 0
	begin
		select @include_timestamps = 1
	end
	
    /* Break out the specified view name and get the non-ownerqual'd name, then validate that. */
    select @object = PARSENAME( @view_name, 1 )
 
    if @object IS NULL
	begin
		-- generate view name
		declare @viewname varchar(255)
		declare @guid uniqueidentifier
		set @guid = CONVERT(varbinary(16), LEFT(NEWID(),8))
		exec @retcode = master.dbo.xp_varbintohexstr @guid, @viewname OUTPUT
		if @@ERROR <> 0 OR @retcode <> 0
			return (1)
		set @viewname = 'syncobj_' + @viewname
		set @object = @viewname
	end


	select @quoted_object = QUOTENAME(@object)

    execute @retcode = dbo.sp_validname @object
    if @retcode <> 0
        return (1)

	-- Check if there are snapshot or subscriptions and raiserror if needed.
    EXECUTE @retcode  = dbo.sp_MSreinit_article
        @publication = @publication, 
        @article = @article,
		@need_new_snapshot = 1,
		@need_reinit_subscription = 1
		,@force_invalidate_snapshot = @force_invalidate_snapshot	/* Force invalidate existing snapshot */
		,@force_reinit_subscription = @force_reinit_subscription	/* Force reinit subscription */
		,@check_only = 1
    IF @@ERROR <> 0 OR @retcode <> 0
		return 1

CreateView:
	begin tran
    save TRANSACTION articleview

	/*
	** If the article has a generated view (not manually created), then
	** drop the current view before creating the new one.
	*/
	if ((@type & 0x5) <> 0x5) and @view_id <> 0
			and @view_id <> @table_id
	begin
		select @previous_view = object_name (@view_id)
		if @previous_view is not null and
				exists (select * from sysobjects where name = @previous_view
				and type = 'V')
		begin
			select @quoted_prev_view = QUOTENAME(@previous_view)
			exec ('drop view ' + @quoted_prev_view)
			if @@error <> 0
				goto UNDO
		end
	end

    /*
    ** Construct and execute the view creation command.
    */
    -- Drop the existing view.
    -- Note: upgrade needs this logic
    if datalength(@filter_clause) > 0 and
        exists (select * from sysobjects where id = object_id(@object)
    and type = 'V') 
    begin
		exec ('drop view ' + @quoted_object)
		if @@error <> 0
			goto UNDO
	end

    ---------------------------------------------
	--  Update article definition 
	--  Set @filter_clause value
    ---------------------------------------------

    if datalength(@filter_clause) > 0
	begin
       update sysarticles set filter_clause = @filter_clause
          where pubid = @pubid
          and name = @article
		if @@error <> 0
			goto UNDO
	end
    else
	begin
       update sysarticles set filter_clause = NULL
          where pubid = @pubid
          and name = @article
		if @@error <> 0
			goto UNDO
	end


	-----------------------------------------------------------
	-- create the view
	-----------------------------------------------------------

	declare @cmd nvarchar(2000)
	declare @dbname sysname

	select @cmd = N'exec sp_MSscript_article_view ' + cast(@artid as nvarchar(20)) 
				+ N',N' + quotename(@object,'''') +  
				+ N',' + cast(@include_timestamps as nvarchar(1))
	select @dbname = db_name()
	
	exec @retcode = master..xp_execresultset @cmd, @dbname
	if @@error <> 0 or @retcode <> 0
		goto UNDO

	-----------------------------------------------------------
	-- grant the permission of the view to public so that non
	-- db_owner can do validation.
	-----------------------------------------------------------
	select @cmd = 'grant select on ' + QUOTENAME(@object) + ' to public'
	exec (@cmd)
	if @@error <> 0
		goto UNDO


	-----------------------------------------------------------
    -- Update the article's sync_objid with the new view id
    -----------------------------------------------------------

    select @view_id = id from sysobjects where name = @object and type = 'V'
    if @view_id is null or @view_id = 0
    begin
        RAISERROR (15001, 11, -1, @object)
		goto UNDO
    end
	else
	begin
		if (@user_name in ('dbo','INFORMATION_SCHEMA'))
		    EXEC dbo.sp_MS_marksystemobject @object
	end

    ---------------------------------------------
	--  Update article definition 
	--  Set new sync_objid 
	---------------------------------------------

    update sysarticles set sync_objid = @view_id
      where pubid = @pubid
      and name = @article
	if @@error <> 0 
		goto UNDO

	-- sp_repldropcolumn used @change_active = 2 to prepare, don't invalidate or reinitialize
	if @change_active <> 2
	begin
		-- Have to call this stored procedure to invalidate existing snapshot or reint
		-- subscriptions if needed
        EXECUTE @retcode  = dbo.sp_MSreinit_article
            @publication = @publication, 
            @article = @article,
			@need_new_snapshot = 1,
			@need_reinit_subscription = 1
			,@force_invalidate_snapshot = @force_invalidate_snapshot	/* Force invalidate existing snapshot */
			,@force_reinit_subscription = @force_reinit_subscription	/* Force reinit subscription */
        IF @@ERROR <> 0 OR @retcode <> 0
			GOTO UNDO
	end

    /*
    ** Force the article cache to be refreshed with the new definition.
    */
    EXECUTE dbo.sp_replflush
    COMMIT TRANSACTION

	--
	-- Validate that the new view does not exclude the horizontal filter
	--
	if ((@allow_sync_tran = 1 or @allow_queued_tran = 1) and
		(datalength(@filter_clause) > 0))
	begin
		select @cmd = N'select top 0 * into #dummy from ' + 
			quotename(@user_name) + N'.' + quotename(object_name(@view_id)) +
			N' where ' + cast(@filter_clause as nvarchar(4000))
		exec (@cmd)
		if (@@error != 0)
		begin
			--
			-- The row filter does not work for the current view
			--
			declare @h_filter nvarchar(4000)
			select @h_filter = cast(@filter_clause as nvarchar(4000))
			raiserror(21392, 16, 1, @h_filter, @object, @article, @publication)
			
			--
			-- drop the filter if not manually generated 
			--
			if ((@type & 0x3) <> 0x3) and @filter_id <> 0
			begin
				if exists (select * from sysobjects where id = @filter_id and type = 'RF')
				begin
					declare @filter_proc nvarchar(386)
					exec dbo.sp_MSget_qualified_name @filter_id, @filter_proc output
					exec ('drop procedure ' + @filter_proc)

					update dbo.sysarticles set filter = 0, filter_clause = NULL
						where pubid = @pubid and name = @article

					raiserror(21393, 16, 1, @h_filter, @article, @publication)
				end
			end
			return 1
		end
	end

	return 0
UNDO:
	if @@trancount > 0
    begin
        ROLLBACK TRANSACTION articleview
        commit tran
    end
    RETURN (1)
END
go
 
EXEC dbo.sp_MS_marksystemobject sp_articleview
GO

dump tran master with no_log
go

print ''
print 'Creating procedure sp_MSaddexearticle'
go
CREATE PROCEDURE sp_MSaddexecarticle
    @publication sysname,               /* publication name */
    @article     sysname,             /* article name */
    @source_proc nvarchar (92),                 /* table name */
    @destination_proc sysname = NULL,           /* destination table name */
    @type sysname = NULL,                       /* article type */
    @creation_script nvarchar (127) = NULL,           /* article schema script */
    @description nvarchar (255) = NULL,                 /* article description */
    @pre_creation_cmd nvarchar(10) = 'drop',           /* 'none', 'drop', 'delete', 'truncate' */
    @schema_option binary(8) = NULL,    /* script out stored procedure */
    @destination_owner sysname,
    @article_id int OUTPUT

    AS


    SET NOCOUNT ON

    /* variables for SP_NAMECRACK */

    DECLARE @site sysname
    DECLARE @db sysname
    DECLARE @owner sysname
    DECLARE @object sysname

    DECLARE @retcode   int

    DECLARE @procid    int
    DECLARE @procnum   smallint
    DECLARE @pubid     int
    DECLARE @precmdid  int

    DECLARE @typeid      smallint
    DECLARE @publish_bit smallint
    DECLARE @incompatible_typeid smallint

    DECLARE @cmd nvarchar(255)
    DECLARE @sysobj_colname  sysname

    SELECT  @typeid      = 24


    SELECT @sysobj_colname = 'replinfo'
    SELECT @publish_bit = 1


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
    
    /*
    EXECUTE @retcode = dbo.sp_validname @article

    IF @retcode <> 0
    return(1)
    */

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
    ** Parameter Check: @source_proc.
    ** Check to see that the @source_proc is local, that it conforms
    ** to the rules for identifiers, and that it is a procedure
    */

    IF @source_proc IS NULL
    BEGIN
        RAISERROR (14043, 16, -1, '@source_proc')
        RETURN (1)
    END

   select @object = PARSENAME( @source_proc, 1 )
   select @owner  = PARSENAME( @source_proc, 2 )
   select @db     = PARSENAME( @source_proc, 3 )
   select @site   = PARSENAME( @source_proc, 4 )

   if @object IS NULL
         return 1


    IF @source_proc LIKE '%.%.%' AND @db <> DB_NAME()
    BEGIN
        RAISERROR (14004, 16, -1, @source_proc)
		RETURN (1)
    END
    

    /*
    **  Get the id of the @source_proc
    */

    SELECT @procid = id
      FROM sysobjects
     WHERE id = OBJECT_ID(@source_proc)
     AND   type = 'P'

    IF @procid IS NULL
    BEGIN
        RAISERROR (14027, 11, -1, @source_proc)
        RETURN (1)
    END

    /*
    ** Parameter Check:  @destination_proc.
    ** If the destination proc is not specified, assume it's the same
    ** as the source. 
    */
    
    IF @destination_proc IS NULL
    BEGIN
        -- Perform parsing only if the destination_proc parameter is not provided
        SELECT @destination_proc = @source_proc

	    select @object = PARSENAME( @destination_proc, 1 )
	    select @owner  = PARSENAME( @destination_proc, 2 )
	    select @db     = PARSENAME( @destination_proc, 3 )
	    select @site   = PARSENAME( @destination_proc, 4 )

	    if @object IS NULL
		     return 1 
    END

    /*
    ** Get the pubid.
    */

    SELECT @pubid = pubid FROM syspublications WHERE name = @publication

    IF @pubid IS NULL
        BEGIN
            RAISERROR (14027, 11, -1, @publication)
            RETURN (1)
        END

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
    ** Set the precmdid.  The default type is 'drop'.
    **
    **      @precmdid   pre_creation_cmd
    **      =========   ================
    **            0     none
    **          1     drop
    */
    IF LOWER(@pre_creation_cmd collate SQL_Latin1_General_CP1_CS_AS) NOT IN ('none', 'drop')
       BEGIN
          RAISERROR (14111, 16, -1)
          RETURN (1)
       END

    /*
    ** Determine the integer value for the pre_creation_cmd.
    */

    IF LOWER(@pre_creation_cmd collate SQL_Latin1_General_CP1_CS_AS) = 'none'
       SELECT @precmdid = 0
    ELSE IF LOWER(@pre_creation_cmd collate SQL_Latin1_General_CP1_CS_AS) = 'drop'
       SELECT @precmdid = 1

    /*  Determine 'type' value for article.
    **
    **            8     proc exec
    **           24     serializable proc exec
    */

    IF @type IS NULL
    BEGIN
        SELECT @type = 'serializable proc exec'
    END
    ELSE IF LOWER(@type collate SQL_Latin1_General_CP1_CS_AS) NOT IN ('proc exec', 'serializable proc exec')
    BEGIN
            RAISERROR (14118, 16, -1)
            RETURN (1)
    END

    IF LOWER(@type collate SQL_Latin1_General_CP1_CS_AS) = 'proc exec'
    BEGIN
       SELECT @typeid = 8
       SELECT @incompatible_typeid = 24
    END
    ELSE IF LOWER(@type collate SQL_Latin1_General_CP1_CS_AS) = 'serializable proc exec'
    BEGIN
       SELECT @typeid = 24
       SELECT @incompatible_typeid = 8
    END

    -- make sure we haven't already created an article of a different type
    -- on this proc

    IF EXISTS ( select * from sysobjects where id = @procid
                and replinfo & @incompatible_typeid = @incompatible_typeid )
    BEGIN
       RAISERROR (21024, 16, -1, @source_proc )
       RETURN(1)
    END

    /*
    ** Parameter Check:  @creation_script and @schema_option
    ** @schema_option is null, set the default value
    */
    IF @schema_option IS NULL
    BEGIN
        SELECT @schema_option = 1
    /* 
        RAISERROR (14043, 16, -1, '@schema_option')
        RETURN (1)
        */
    END

    IF @schema_option <> 0x0000000000000000 AND 
       @schema_option <> 0x0000000000000001 AND
       @schema_option <> 0x0000000000002000 AND
       @schema_option <> 0x0000000000002001  
    BEGIN
        RAISERROR (20014, 10, -1)
        RETURN (1)
    END

    /*
    **  Add article to sysarticles and update sysobjects category bit.
    */

    begin tran
    save TRAN sp_MSaddexecarticle
        INSERT sysarticles (columns, creation_script, del_cmd, description,
                            dest_table, filter, filter_clause, ins_cmd, name,
                objid, pre_creation_cmd, pubid,
                            status, sync_objid, type, upd_cmd, schema_option,
                            dest_owner)
        VALUES (0, @creation_script, NULL, @description,
                @destination_proc, 0, '', NULL, @article,
                @procid, @precmdid, @pubid,
                0, @procid, @typeid, NULL, @schema_option,
                @destination_owner)

        IF @@ERROR <> 0
        BEGIN
            if @@trancount > 0
            begin
                ROLLBACK TRAN sp_MSaddexecarticle
                commit tran
            end
            RETURN (1)
        END

        SELECT @article_id = @@IDENTITY

        select @cmd = 'UPDATE sysobjects SET ' + @sysobj_colname
        select @cmd = @cmd + ' = ' + @sysobj_colname + ' | ' + CONVERT( nvarchar, @publish_bit )
        select @cmd = @cmd + ' WHERE id = (SELECT objid FROM sysarticles WHERE name = '''
        select @cmd = @cmd + @article + ''' and pubid = ' + CONVERT( nvarchar, @pubid ) + ')'

        EXEC (@cmd)

        IF @@ERROR <> 0
        BEGIN
            if @@trancount > 0
            begin
                ROLLBACK TRAN sp_MSaddexecarticle
                commit tran
            end
            RETURN (1)
        END


    COMMIT TRAN
go
 
EXEC dbo.sp_MS_marksystemobject sp_MSaddexecarticle
GO

print ''
print 'Creating procedure sp_MSaddschemaarticle'
go

CREATE PROCEDURE sp_MSaddschemaarticle
    @publication        sysname,        /* Name of the publciation */
    @article            sysname,        /* Name of the article */
    @source_object      sysname,        /* Name of object to be replicated */
    @destination_object sysname,        /* Name of the object created on the subscriber */
    @type               tinyint,        /* Must be one of 0x20, 0x40, or 0x80 */
    @creation_script    nvarchar(255),  /* custom creation script for the article */
    @description        nvarchar(255),  /* article description */
    @pre_creation_cmd   nvarchar(10),   /* must be 'none' or 'drop' */
    @schema_option      binary(8),
    @destination_owner  sysname,        /* owner of the article object on the subscriber */
    @status             tinyint, 
    @artid              int OUTPUT
AS
    SET NOCOUNT ON
    DECLARE @retcode int
        
    DECLARE @source_owner           sysname
    DECLARE @object                 sysname
    DECLARE @bInTran                bit
    DECLARE @pubid                  int
    DECLARE @source_objid           int
    DECLARE @pre_creation_cmdid     tinyint
    
    /* Variables for setting up RPC call to the Distributor */
    DECLARE @distproc               nvarchar(2000)
    DECLARE @distributor            sysname
    DECLARE @distributiondb         sysname
    DECLARE @dbname                 sysname
    DECLARE @valid_schema_options   int
    
    SELECT @bInTran = 0

    SELECT @source_owner = PARSENAME(@source_object, 2)
    SELECT @object = PARSENAME(@source_object, 1)

    /* Note that @article & @publication has been by sp_addarticle 
       as non-null */
        
    /*
    ** Get the pubid of the publication
    */
    SELECT @pubid = NULL
    SELECT @pubid = pubid
      FROM syspublications
     WHERE name = @publication

    IF @pubid IS NULL
    BEGIN
        RAISERROR (14027, 11, -1, @publication)
        RETURN (1)
    END

    /*
    ** Get the source object id
    */
    SELECT @source_objid = NULL
    SELECT @source_objid = OBJECT_ID(@source_object)    

    /*
    **  Destination object name
    */
    IF @destination_object IS NULL
        SELECT @destination_object = @source_object

    /*
    ** Parameter check: @type
    ** @type must correspond to the object type of the source object
    **
    ** @type = 0x20 => source object type = 'P'
    ** @type = 0x40 => source object type = 'V'
    ** @type = 0x80 => source object type = 'FN' OR 'TF' OR 'IF'
    */
    IF @type = 0x20
    BEGIN
        IF NOT EXISTS (SELECT *
                         FROM sysobjects
                        WHERE id = @source_objid
                          AND xtype = 'P ')
        BEGIN
            RAISERROR(21219, 16, -1)
            RETURN (1)
        END
    END
    ELSE IF @type = 0x40
    BEGIN
        IF NOT EXISTS (SELECT *
                         FROM sysobjects 
                        WHERE id = @source_objid
                          AND xtype = 'V ')
        BEGIN
            RAISERROR(21221, 16, -1)
            RETURN (1)
        END
    END   
    ELSE IF @type = 0x80
    BEGIN
        IF NOT EXISTS (SELECT *
                         FROM sysobjects 
                        WHERE id = @source_objid
                          AND (xtype in ('FN','TF','IF')))
        BEGIN
            RAISERROR(21228, 16, -1)            
            RETURN (1)
        END
    END


    /*
    ** Parameter check: @schema_option
    ** @schema_option can only contain the bits 0x0000000000000001 and
    ** 0x0000000000002000
    ** for schema only articles except view. View articles can contain 
    ** the options 0x0000000000000010, 0x0000000000000020, and 
    ** 0x0000000000000100 in addition to the aforementioned options.
    */
    IF @type = 0x40
    BEGIN

        -- Since only the lower 32 bits of @schema_option are
        -- currently used, the following check is sufficient.
        -- Note that @schema_option should have been padded out by now
        DECLARE @schema_option_lodword int
        SELECT @valid_schema_options = 0x2151
        SELECT @schema_option_lodword = fn_replgetbinary8lodword(@schema_option)
        IF (@schema_option_lodword & ~@valid_schema_options) <> 0
        BEGIN
            RAISERROR (21229, 16, -1)
            RETURN (1)
        END
    END
    ELSE IF @schema_option NOT IN (0x0000000000000000,
                                   0x0000000000000001,
                                   0x0000000000002000,
                                   0x0000000000002001)
    BEGIN
        RAISERROR (21222, 16, -1)
        RETURN (1)
    END 
    
    /*
    ** Parameter check: @pre_creation_command must be
    ** 'drop' (id = 1) or 'none' (id = 0)
    */
    SELECT @pre_creation_cmd = LOWER(@pre_creation_cmd collate SQL_Latin1_General_CP1_CS_AS)
    IF @pre_creation_cmd NOT IN (N'none', N'drop')
    BEGIN
        RAISERROR(21223, 16, -1)
        RETURN (1)
    END
    
    IF @pre_creation_cmd = N'none'
        SELECT @pre_creation_cmdid = 0
    ELSE IF @pre_creation_cmd = N'drop'
        SELECT @pre_creation_cmdid = 1
    
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

    BEGIN TRANSACTION sp_MSaddschemaarticle
    SAVE TRANSACTION sp_MSaddschemaarticle
    SELECT @bInTran = 1    

    -- Add a dummy record to sysarticles to reserve an artid
    INSERT sysarticles (dest_table, filter, name, objid, pubid, 
                        pre_creation_cmd, status, sync_objid, type)  
    VALUES (@destination_object, N'', @article, @source_objid, @pubid,
            @pre_creation_cmdid, @status, @source_objid, @type)

    IF @@ERROR <> 0
        GOTO Failure

    SELECT @artid = @@IDENTITY   

    -- Now that we have reserved an artid in sysarticles,
    -- we can remove the dummy record
    
    DELETE sysarticles WHERE artid = @artid AND pubid = @pubid

    IF @@ERROR <> 0
        GOTO Failure

    -- Insert a record into sysschemaarticles to represent this
    -- schema only article
    INSERT sysschemaarticles 
    VALUES (@artid, @creation_script, @description, @destination_object,
            @article, @source_objid, @pubid, @pre_creation_cmdid, @status,
            @type, @schema_option, @destination_owner)

    IF @@ERROR <> 0
        GOTO Failure

    -- Make a bit in replinfo to prevent the source object from
    -- being dropped
    UPDATE sysobjects SET replinfo = replinfo | 0x00000200 WHERE id = @source_objid
    
    IF @@ERROR <> 0
        GOTO Failure       

    COMMIT TRANSACTION  

    RETURN (0)
Failure:

    IF @bInTran = 1
    BEGIN
        ROLLBACK TRANSACTION sp_MSaddschemaarticle
        COMMIT TRANSACTION
    END
    RETURN (1)
go

EXEC dbo.sp_MS_marksystemobject sp_MSaddschemaarticle
GO

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
 
/*
** Create replication stored procedures.
** Part 1:  create codependent procedures.
*/

EXEC dbo.sp_MS_marksystemobject sp_addarticle
GO

print ''
print 'Creating procedure sp_MSgettranconflictname'
go
CREATE PROCEDURE sp_MSgettranconflictname (
@publication sysname,
@source_object nvarchar(540),
@str_prefix nvarchar(30) = NULL,
@conflict_table sysname = NULL OUTPUT)
AS
begin
	declare @objid 				int
	declare @retcode			int
	declare @object_name		sysname
	declare @name_out			sysname
	declare @pubid				int
	declare @article			sysname
	declare @artid				int
	declare @prefixlen			int

	if (@str_prefix is NULL)
		select @str_prefix = 'conflict_'

	select @prefixlen = len(@str_prefix)

	select @pubid=pubid from syspublications 
		where name=@publication

	select @objid = object_id(@source_object)
	select @artid = artid, @article=name from sysarticles 
		where objid = @objid and pubid=@pubid

	if len(@publication) + len(@article) > 128 - @prefixlen -1	 -- SYSNAME minus prefix len
	begin
		select @object_name = @str_prefix + 
			convert(nvarchar(59), @publication) + 
			'_' + convert(nvarchar(59), @article)
	end
	else
	begin
		select @object_name = @str_prefix + @publication + '_' + @article
	end
	select @conflict_table = @object_name
	exec @retcode = dbo.sp_MSuniqueobjectname @object_name, @conflict_table OUTPUT
end
GO
EXEC dbo.sp_MS_marksystemobject sp_MSgettranconflictname
GO

raiserror('Creating procedure sp_MSmaketrancftproc', 0,1)
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
	else if (lower(@ccoltype collate SQL_Latin1_General_CP1_CS_AS) in ('bit','bigint','int','smallint','tinyint','decimal','numeric'))
		select @compinsterm = N' '' + CAST(' + @valterm + N' as nvarchar) '
	else if (lower(@ccoltype collate SQL_Latin1_General_CP1_CS_AS) in ('float','real'))
		select @compinsterm = N' '' + CONVERT(nvarchar(60),' + @valterm + N', 2) '
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
go

print ''
print 'Creating procedure sp_changesubstatus'
go
CREATE PROCEDURE sp_changesubstatus (
    @publication sysname = '%',    /* publication name */
    @article sysname = '%',        /* article name */
    @subscriber sysname = '%',      /* subscriber name */
    @status sysname,                /* subscription status */
    @previous_status sysname=NULL,  /* previous subscription status */
    @destination_db sysname = '%',   /* destination database name */

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
    @distribution_jobid binary(16) = NULL OUTPUT,
    @from_auto_sync bit = 0,
    @ignore_distributor bit = 0,
    -- Agent offload
    @offloadagent bit = 0,
    @offloadserver sysname = NULL,
	@dts_package_name sysname = NULL,
	@dts_package_password nvarchar(524) = NULL,
	@dts_package_location int = 0,
    @schemastabilityonly int = 0,
	@distribution_job_name sysname = NULL

) AS

    SET NOCOUNT ON
    DECLARE @inactive tinyint
    DECLARE @subscribed tinyint
    DECLARE @active tinyint
	DECLARE @initiated tinyint
    DECLARE @public tinyint
    DECLARE @replicate_bit smallint
    DECLARE @msg nvarchar(255)
    DECLARE @prevstatid tinyint
    DECLARE @artid int
    DECLARE @tabid int
    DECLARE @srvid smallint
    DECLARE @statusid tinyint
    DECLARE @distributor sysname
    DECLARE @distribdb sysname
    DECLARE @distproc nvarchar (255)
    DECLARE @pub_db sysname
    DECLARE @dest_db sysname
    DECLARE @sub_name sysname
    DECLARE @sub_status tinyint
    DECLARE @sub_ts varbinary (16)
    DECLARE @non_sql_flag bit
    DECLARE @qcmd nvarchar (4000)
    DECLARE @cmd1 nvarchar (255)
    DECLARE @cmd2 nvarchar (255)
    DECLARE @cmd3 nvarchar (255)
    DECLARE @retcode int
    DECLARE @repl_freq tinyint
    DECLARE @art_type tinyint
    DECLARE @proccmd  nvarchar(255)
    DECLARE @procnum  smallint
    DECLARE @finished_real bit
    DECLARE @finished_virtual bit
    DECLARE @virtual_id smallint
    DECLARE @immediate_sync bit
    DECLARE @enabled_for_internet bit
    DECLARE @allow_anonymous bit
    DECLARE @subscription_type int
    DECLARE @xact_seqno binary(10)
    DECLARE @sync_type tinyint
    DECLARE @automatic tinyint
    DECLARE @bcp_char tinyint	
    DECLARE @concurrent_char tinyint	

    DECLARE @art_change bit
    declare @login_name sysname

	DECLARE @pubid int
	DECLARE @syncinit_lsn binary(10)

	DECLARE @f_syncstat_posted bit

    -- synctran
    DECLARE @update_mode tinyint
    DECLARE @art_name sysname
    declare @synctran tinyint
    declare @no_distproc bit
    declare @loopback_detection bit
	
    /*
    ** Initializations.
    */
    select @synctran = 1
			
    SELECT @automatic = 1
    SELECT @inactive = 0        /* Const: subscription status 'inactive' */
    SELECT @subscribed = 1      /* Const: subscription status 'subscribed' */
    SELECT @active = 2          /* Const: subscription status 'active' */
	SELECT @initiated = 3        /* Const: subscription status 'initiated' */
    SELECT @public = 0          /* Const: publication status 'public' */
    SELECT @pub_db = DB_NAME()
    SELECT @virtual_id = -1
    SELECT @art_change = 0
    select @bcp_char = 1
    select @concurrent_char = 4	

	SELECT @f_syncstat_posted = 0

    SELECT @replicate_bit = 2

    /* 
    ** Security Check.
    ** We use login_name stored in syssubscriptions to manage security 
    */

    /*
    ** Parameter Check:  @publication
    ** Check to make sure that the publication exists, that it's not NULL,
    ** and that it conforms to the rules for identifiers.
    */

    IF @publication IS NULL
        BEGIN
            RAISERROR (14043, 16, -1, '@publication')
            RETURN (1)
        END

    IF @publication <> '%'
        BEGIN
            EXECUTE @retcode = dbo.sp_validname @publication
            IF @@ERROR <> 0 OR @retcode <> 0
            RETURN (1)
        END

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

    IF @article IS NULL
        BEGIN
            RAISERROR (14043, 16, -1, '@article')
            RETURN (1)
        END

    /*
    IF @article <> '%'
        BEGIN
            EXECUTE @retcode = dbo.sp_validname @article
            IF @@ERROR <> 0 OR @retcode <> 0
            RETURN (1)
        END
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

    /*
    ** Parameter Check:  @subscriber
    ** Check to make sure that the subscriber exists, that it is not NULL,
    ** and that it conforms to the rules for identifiers.
    ** Null subscriber represents virtual subscriptions
    */

    IF @subscriber IS NOT NULL AND @subscriber <> '%'
    BEGIN    
        EXECUTE @retcode = dbo.sp_validname @subscriber
        IF @@ERROR <> 0 OR @retcode <> 0
        RETURN (1)

        IF NOT EXISTS (SELECT *
                         FROM master..sysservers
                        WHERE UPPER(srvname) = UPPER(@subscriber) collate database_default
                          AND (srvstatus & 4) <> 0)

            BEGIN
                RAISERROR (14063, 11, -1)
                RETURN (1)
            END
    END

    /*
    ** Parameter Check: @status.
    ** Set the @statusid according to the @status value.  Values can be
    ** any of the following:
    **
    **      status      statusid
    **      =========   ========
    **      inactive           0
    **      subscribed         1
    **      active             2
	**		initiated          3
    */

    IF LOWER(@status collate SQL_Latin1_General_CP1_CS_AS) NOT IN ('active', 'subscribed', 'inactive', 'initiated')
        BEGIN
            RAISERROR (14065, 16, -1)
        RETURN (1)
        END

	IF LOWER(@status collate SQL_Latin1_General_CP1_CS_AS) IN ('initiated')
		SELECT @statusid = @initiated
    ELSE IF LOWER(@status collate SQL_Latin1_General_CP1_CS_AS) IN ('active')
        SELECT @statusid = @active
    ELSE IF LOWER(@status collate SQL_Latin1_General_CP1_CS_AS) IN ('subscribed')
        SELECT @statusid = @subscribed
    ELSE
        SELECT @statusid = @inactive

    /*
    ** Parameter Check: @previous_status.
    ** Set the @prevstatid according to the @previous_status value.
    ** Values can be any of the following:
    **
    **      previous_status      prevstatid
    **      ===============      ==========
    **      inactive                      0
    **      subscribed                    1
    **      active                        2
	**		initiated					  3
    */

    IF @previous_status IS NOT NULL
    BEGIN
        IF LOWER(@previous_status collate SQL_Latin1_General_CP1_CS_AS) NOT IN ('initiated','active', 'subscribed', 'inactive')
        BEGIN
            RAISERROR (14066, 16, -1)
            RETURN (1)
        END

        IF LOWER(@status collate SQL_Latin1_General_CP1_CS_AS) = LOWER(@previous_status collate SQL_Latin1_General_CP1_CS_AS)
        BEGIN
            RAISERROR (14067, 16, -1)
            RETURN (1)
        END

		IF LOWER(@previous_status collate SQL_Latin1_General_CP1_CS_AS) IN ('initiated')
			SELECT @prevstatid = @initiated
        ELSE IF LOWER(@previous_status collate SQL_Latin1_General_CP1_CS_AS) IN ('active')
            SELECT @prevstatid = @active
        ELSE IF LOWER(@previous_status collate SQL_Latin1_General_CP1_CS_AS) IN ('subscribed')
            SELECT @prevstatid = @subscribed
        ELSE
           SELECT @prevstatid = @inactive
    END

    /*
    ** Parameter Check: @destination_db.
    ** Set @destination_db to current database if not specified.  Make
    ** sure that the @destination_db conforms to the rules for identifiers.
    */

    IF @destination_db <> '%' 
    BEGIN
		EXECUTE @retcode = dbo.sp_validname @destination_db
		IF @retcode <> 0
		RETURN (1)
    END

    /*
    ** Get distribution server information for remote RPC
    ** subscription calls.
    ** if @ignore_distributor = 1, we are in bruteforce cleanup mode, don't do RPC.
    */
    if @ignore_distributor = 1 
        select @no_distproc = 1
    else
        select @no_distproc = 0

    IF @no_distproc = 0 --and @from_auto_sync = 0 
    BEGIN
        EXEC @retcode = dbo.sp_helpdistributor @rpcsrvname = @distributor OUTPUT,
                                           @distribdb = @distribdb OUTPUT

        IF @@ERROR <> 0
        BEGIN
            RAISERROR (14071, 16, -1)
            RETURN (1)
        END

        IF @retcode <> 0 OR @distribdb IS NULL OR @distributor IS NULL
        BEGIN
            RAISERROR (14071, 16, -1)
            RETURN (1)
        END
    END


    create table #sysextendedarticlesview
    (
    artid               int                 NULL,
    columns             varbinary(32)       NULL,
    creation_script     nvarchar(255)       collate database_default null,
    del_cmd             nvarchar(255)       collate database_default null,
    description         nvarchar(255)       collate database_default null,
    dest_table          sysname             collate database_default null,
    filter              int                 NULL,
    filter_clause       ntext               NULL,
    ins_cmd             nvarchar(255)       collate database_default null,
    name                sysname             collate database_default null,
    objid               int                 NULL,
    pubid               int                 NULL,
    pre_creation_cmd    tinyint             NULL,
    status              tinyint             NULL,
    sync_objid          int                 NULL,
    type                tinyint             NULL,
    upd_cmd             nvarchar(255)       collate database_default null,
    schema_option       binary(8)           NULL,
    dest_owner          sysname             collate database_default null
    )

    insert into #sysextendedarticlesview select * from sysextendedarticlesview

    begin tran
    save TRANSACTION changesubstatus

        SELECT @finished_virtual = 0
        SELECT @finished_real = 0

        /* 
        ** If @subscriber is null, don't process real subscriptions
        ** If @subscriber is not null and '%', don't process virtual subscriptions
        */
        IF @subscriber IS NULL SELECT @finished_real = 1
        ELSE IF @subscriber <> '%'  SELECT @finished_virtual = 1

        WHILE (@finished_real = 0 OR @finished_virtual = 0)
        BEGIN
            /*
            ** Declare cursor containing subscriptions to be updated.
            */
            IF @finished_real = 0
            BEGIN
                IF @previous_status IS NOT NULL
                BEGIN
                    DECLARE hCsubstatus CURSOR LOCAL SCROLL_LOCKS FOR
                        SELECT sub.artid,
                               art.objid,
                               sub.srvid,
                               ss.srvname,
                               sub.dest_db,
                               sub.status,
                           case when ss.srvproduct = 'MSREPL-NONSQL' or
								pub.allow_dts = 1
								then 1
                           else 0 end,
                           pub.repl_freq,
                               art.type,
                           pub.immediate_sync,
                           pub.enabled_for_internet,
                           pub.allow_anonymous,
                           sub.subscription_type,
                           sub.sync_type,
                           sub.update_mode,
                           art.name,
                           sub.login_name,
                           sub.loopback_detection,
						   pub.pubid
                          FROM syssubscriptions sub,
                               #sysextendedarticlesview art,
                               syspublications pub,
                               master..sysservers ss
                         WHERE pub.name LIKE @publication collate database_default
                           AND art.name LIKE @article collate database_default
                           AND ((@subscriber = N'%') OR (UPPER(ss.srvname) = UPPER(@subscriber) collate database_default))
                           AND sub.srvid = ss.srvid
                           AND sub.artid = art.artid
                           AND art.pubid = pub.pubid
                           AND sub.status = @prevstatid
                           AND ((@destination_db = N'%') OR (sub.dest_db = @destination_db collate database_default))
                END
                ELSE
                BEGIN
                    DECLARE hCsubstatus CURSOR LOCAL SCROLL_LOCKS FOR
                        SELECT sub.artid,
                               art.objid,
                               sub.srvid,
                               ss.srvname,
                               sub.dest_db,
                               sub.status,
                           case when ss.srvproduct = 'MSREPL-NONSQL' or
								pub.allow_dts = 1
								then 1
                           else 0 end,
                           pub.repl_freq,
                               art.type,
                           pub.immediate_sync,
                           pub.enabled_for_internet,
                           pub.allow_anonymous,
                           sub.subscription_type,
                           sub.sync_type,
                           sub.update_mode,
                           art.name,
                           sub.login_name,
                           sub.loopback_detection,
						   pub.pubid
                          FROM syssubscriptions sub,
                               #sysextendedarticlesview art,
                               syspublications pub,
                               master..sysservers ss
                         WHERE pub.name LIKE @publication collate database_default
                           AND art.name LIKE @article collate database_default
                           AND ((@subscriber = N'%') OR (UPPER(ss.srvname) = UPPER(@subscriber) collate database_default))
                           AND sub.srvid = ss.srvid
                           AND sub.artid = art.artid
                           AND art.pubid = pub.pubid
                           AND ((@destination_db = N'%') OR (sub.dest_db = @destination_db))
                END		   
                SELECT @finished_real = 1
            END

            ELSE IF @finished_virtual = 0  
            BEGIN
                DECLARE @sub_bit smallint
                DECLARE @null_name sysname

                SELECT @sub_bit = 4
                SELECT @null_name = NULL

                /*
                ** Treat anonymous virtual subscription as DSN subscriber.
                ** This will cause sp_MSarticlecol being called in sp_changesubstatus
                */
                DECLARE hCsubstatus CURSOR LOCAL SCROLL_LOCKS FOR
                    SELECT sub.artid,
                           art.objid,
                           sub.srvid,
                           @null_name,              /* subscriber name. NULL for virtual */
                           sub.dest_db,
                           sub.status,
                      case when (pub.allow_anonymous = 1 and (pub.sync_method = @bcp_char or pub.sync_method = @concurrent_char)) or
							pub.allow_dts = 1 then 1
                       else 0 end, /*indicate dsn or not */ 
                       pub.repl_freq,
                       art.type,
                       pub.immediate_sync,
                       pub.enabled_for_internet,
                       pub.allow_anonymous,
                       sub.subscription_type,
                       sub.sync_type,
                       sub.update_mode,
                       art.name,
                       login_name,
                       sub.loopback_detection,
					   pub.pubid

                      FROM syssubscriptions sub,
                           #sysextendedarticlesview art,
                           syspublications pub
                     WHERE pub.name LIKE @publication
                       AND art.name LIKE @article
                       AND sub.srvid = -1
                       AND sub.artid = art.artid
                       AND art.pubid = pub.pubid
                SELECT @finished_virtual = 1
            END

            OPEN hCsubstatus
            FETCH hCsubstatus INTO @artid, @tabid, @srvid, @sub_name, @dest_db,
                @sub_status, @non_sql_flag, @repl_freq, @art_type,
                @immediate_sync, @enabled_for_internet,
                @allow_anonymous, @subscription_type, @sync_type, @update_mode,
                @art_name, @login_name, @loopback_detection,@pubid


            WHILE (@@fetch_status <> -1)
            BEGIN

                IF  suser_sname(suser_sid()) <> @login_name AND is_srvrolemember('sysadmin') <> 1  
                    AND is_member ('db_owner') <> 1
                BEGIN
                    CLOSE hCsubstatus
                    DEALLOCATE hCsubstatus
                    if @@trancount > 0
                    begin
                        ROLLBACK TRANSACTION changesubstatus
                        commit tran
                    end
                    RAISERROR (14126, 11, -1)
                    RETURN (1)
                END
                /*
				** condition 1:
                ** If current status is same as new status, and status is not 'initiated' do nothing.
				** If both old and new status = 'initiated', this indicates that the 
				** snapshot agent previously bombed out between the initiation and activation stages and
				** is now again trying to sync the publication.
				**
				** condition 2:
                ** @auto_sync_only is used by snapshot for immediate_sync
                ** publications.
				**
				** condition 3:
				** Because sp_MSactivate_auto_sub (and thus the snapshot agent)
				** calls this procedure for all subscriptions, we need to ignore
				** the real subscriptions that are already active so that they won't be
				** transitioned to the initiated state.  If we don't do this, those
				** subscriptions will be resynced using the new snapshot.
				** 
				** however, we DO want a new snapshot to be generated for virtual
				** subscriptions to active publications.
				**
                */
                IF  (@sub_status = @statusid AND @sub_status <> @initiated ) OR
                    (@from_auto_sync = 1 AND @sync_type <> @automatic) OR
					(@sub_status = @active AND @statusid = @initiated AND @srvid <> -1 AND @from_auto_sync = 1)
                BEGIN
                    FETCH hCsubstatus INTO @artid, @tabid, @srvid, @sub_name,
                       @dest_db, @sub_status, @non_sql_flag, @repl_freq, @art_type, 
                       @immediate_sync, @enabled_for_internet,
                       @allow_anonymous, @subscription_type, @sync_type, @update_mode,
                       @art_name, @login_name, @loopback_detection, @pubid

                    CONTINUE
                END

				-- If changing a virtual subscription to 'subscribed' status
				-- change the immediate_sync_ready bit
				if @statusid = @subscribed and @sub_name is NULL
				begin
					UPDATE syspublications SET immediate_sync_ready = 0 WHERE 
						pubid = @pubid and
						immediate_sync_ready <> 0
                    IF @@ERROR <> 0
                    BEGIN
                      CLOSE hCsubstatus
                      DEALLOCATE hCsubstatus
                      if @@trancount > 0
                        begin
                            ROLLBACK TRANSACTION changesubstatus
                            commit tran
                        end
                      RETURN (1)
                    END
				end


				-- acquire schema lock, mark rollback point in order to allow
				-- for 'unflush' of proc cache

                declare @qualified_name nvarchar(512)

                exec dbo.sp_MSget_qualified_name @tabid, @qualified_name output
                exec dbo.sp_replupdateschema @qualified_name, @schemastabilityonly

                /*
                ** Update syssubscription status
                */
                UPDATE syssubscriptions
                       SET status = @statusid
                       FROM syssubscriptions sub,
                           sysextendedarticlesview art,
                           syspublications pub
                       WHERE pub.name LIKE @publication
                            AND art.artid = @artid
                            AND sub.srvid = @srvid
                            AND sub.artid = @artid
                            AND art.pubid = pub.pubid
                            AND sub.dest_db = @dest_db
                if @@ERROR <> 0
                               BEGIN
                               CLOSE hCsubstatus
                               DEALLOCATE hCsubstatus
                                if @@trancount > 0
                                begin
                                    ROLLBACK TRANSACTION changesubstatus
                                    commit tran
                                end
                                RAISERROR (14053, 16, -1)
                                   RETURN (1)
                               END

				--
				-- Subscription reinitialization processing for Immediate 
				-- and Queued publications
				--
				if (@update_mode in (1,2,3,4,5))
				begin
					select @retcode = 0
					IF ((@statusid != @active) AND (@sub_status = @active))
					begin
						--
						-- If we are going from active state to subscribed
						-- set the reinit column so that no more updates from
						-- subscriber are applied until (re)activation
						--
						update dbo.syssubscriptions
						set queued_reinit = 1
						where 
							artid = @artid 
							and srvid = @srvid
							and dest_db = @dest_db
					end
					ELSE IF ((@statusid = @active) AND (@sub_status != @active ))
					begin
						--
						-- If we are going from subscribed state to active state
						--
						if (@update_mode = 1)
						begin
							--
							-- Sync tran case : reset the reinit column
							--
							update dbo.syssubscriptions
							set queued_reinit = 0
							where 
								artid = @artid 
								and srvid = @srvid
								and dest_db = @dest_db
						end
						--
						-- For queued case : we do not need to send compensating
						-- command anymore, sp_addqueued_artinfo will do the 
						-- queue reinitialization for all types of queued
						-- subscriptions
						--
					end					

					--
					-- Check for error
					--
					if (@@error != 0 or @retcode != 0)
					begin
						CLOSE hCsubstatus
						DEALLOCATE hCsubstatus
						if @@trancount > 0
						begin
							ROLLBACK TRANSACTION changesubstatus
							commit tran
						end
						RAISERROR (14053, 16, -1)
						RETURN (1)
					end
				end

                /*
                ** Get timestamp of subscription.
                */
                EXEC @retcode = dbo.sp_replincrementlsn_internal @xact_seqno OUTPUT
                IF @@ERROR <> 0 or @retcode <> 0
                            BEGIN
                               CLOSE hCsubstatus
                               DEALLOCATE hCsubstatus
                               if @@trancount > 0
                                begin
                                    ROLLBACK TRANSACTION changesubstatus
                                    commit tran
                                end
                               RETURN (1)
                            END
                select @sub_ts = @xact_seqno


                IF @sub_ts IS NULL
                            BEGIN
                               CLOSE hCsubstatus
                               DEALLOCATE hCsubstatus
                               if @@trancount > 0
                                begin
                                    ROLLBACK TRANSACTION changesubstatus
                                    commit tran
                                end
                                RAISERROR (14053, 16, -1)
                               RETURN (1)
                            END
				
				-------------------------------------------------------------------
				-- If initiating the subscription, toss a SYNCINIT token into the 
				-- log for the article and return LSN as a results set
				--
				-- Note:  This should come after the subscription LSN is obtained.
				-- in order to assure proper application of SYNSTAT tokens in the
				-- distribution database
				-------------------------------------------------------------------

				IF @statusid = @initiated --and @sub_status <> @initiated
				BEGIN
					-- set filtered status.  Must log old text information during initiated state
					-- in order to support update splitting

					exec sp_MSsetfilteredstatus @tabid

					-- set nonsqlsub status.  must prevent UPDATETEXT operations during
					-- initiated state

                    exec sp_MSarticlecol @artid, NULL,N'nonsqlsub', N'add'
					exec sp_replpostsyncstatus @pubid, @artid, 1, @syncinit_lsn output
					if @f_syncstat_posted = 0
					begin
						select @pubid, @artid, @syncinit_lsn
						select @f_syncstat_posted = 1
					end
				END

				-------------------------------------------------------------------
				-- If changing the state FROM initiated, post a SYNCDONE token to the 
				-- log for the article. 
				-------------------------------------------------------------------
				IF @sub_status = @initiated and @statusid <> @initiated
				BEGIN
					-- reset filtered status to normal value

					exec sp_MSsetfilteredstatus @tabid

					-- clear nonsqlsub status for this article.

                    exec sp_MSarticlecol @artid, NULL,N'nonsqlsub', N'drop'

					--if @f_syncstat_posted = 0
					--begin
						exec sp_replpostsyncstatus @pubid, @artid, 0, @syncinit_lsn output
					--	select @f_syncstat_posted = 1
					--end
				END

                /*
                ** If activating subscription, update sysextendedarticlesview, sysobjects and
                ** MSrepl_subscriptions.
                */
                IF @statusid in ( @active, @initiated )
                BEGIN
                    
                    /*
                    ** Update status of article to show it has been activated.
                    */
                    IF @repl_freq = 0 and EXISTS (SELECT * FROM sysextendedarticlesview WHERE artid = @artid
                        AND status & 1 <> 1)
                    BEGIN
                        -- At most one row will be updated in the following two updates as the artid is unique
                        -- among both sysarticles and sysschemaarticles
                        UPDATE sysarticles SET status = status | 1 WHERE artid = @artid
                        IF @@ERROR <> 0
                            BEGIN
                                CLOSE hCsubstatus
                                DEALLOCATE hCsubstatus
                                if @@trancount > 0
                                begin
                                    ROLLBACK TRANSACTION changesubstatus
                                    commit tran
                                end
                                RAISERROR (14069, 16, -1)
                                RETURN (1)
                            END
                        UPDATE sysschemaarticles SET status = status | 1 WHERE artid = @artid
                        IF @@ERROR <> 0
                            BEGIN
                                CLOSE hCsubstatus
                                DEALLOCATE hCsubstatus
                                if @@trancount > 0
                                begin
                                    ROLLBACK TRANSACTION changesubstatus
                                    commit tran
                                end
                                RAISERROR (14069, 16, -1)
                                RETURN (1)
                            END
                        SELECT @art_change = 1
                    END

                        /*
                        ** Turn the replication flag on for this object in the
                        ** sysobjects table (make it logbased).
                        */

                    if @repl_freq = 0
                      BEGIN
                        UPDATE sysobjects SET replinfo = replinfo | @replicate_bit
                        WHERE id = ( SELECT objid FROM sysextendedarticlesview WHERE artid = @artid )
                      END

                      IF @@ERROR <> 0
                      BEGIN
                          CLOSE hCsubstatus
                          DEALLOCATE hCsubstatus
                          if @@trancount > 0
                            begin
                                ROLLBACK TRANSACTION changesubstatus
                                commit tran
                            end
                          RAISERROR (14068, 16, -1)
                          RETURN (1)
                      END

                END

                /*
                ** Update status of all columns if subscriber is non-SQL Server.
                */
                IF @non_sql_flag <> 0 AND ( @art_type & 1 ) = 1
                BEGIN
                    IF @statusid = @subscribed OR @statusid = @active
                    BEGIN

                        EXEC @retcode = dbo.sp_MSarticlecol @artid, NULL,
                                                          'nonsqlsub', 'add'
                        IF @@ERROR <> 0 OR @retcode <> 0
                        BEGIN
                            CLOSE hCsubstatus
                            DEALLOCATE hCsubstatus
                            if @@trancount > 0
                            begin
                                ROLLBACK TRANSACTION changesubstatus
                                commit tran
                            end
                            RAISERROR (14068, 16, -1)
                            RETURN (1)
                        END


                    END
                    ELSE IF @statusid = @inactive
                    BEGIN

                        EXEC @retcode = dbo.sp_MSarticlecol @artid, NULL,
                                                          'nonsqlsub', 'drop'
                        IF @@ERROR <> 0 OR @retcode <> 0
                        BEGIN
                          CLOSE hCsubstatus
                          DEALLOCATE hCsubstatus
                          if @@trancount > 0
                            begin
                                ROLLBACK TRANSACTION changesubstatus
                                commit tran
                            end
                          RAISERROR (14068, 16, -1)
                          RETURN (1)
                        END
                    END
                END

				
                /*
                ** If deactivating subscription, update sysextendedarticlesview, sysobjects and
                ** MSrepl_subscriptions.
                */

                IF @statusid NOT IN( @active, @initiated ) AND @sub_status IN ( @active, @initiated )
                BEGIN
                    /*
                    ** Set the article status to 'inactive' if there are
                    ** no other active subscriptions on it.
                    */
                    IF NOT EXISTS (SELECT * FROM syssubscriptions WHERE
                       artid = @artid AND status = @active)
                    BEGIN
                        IF EXISTS (SELECT * FROM sysextendedarticlesview WHERE artid = @artid
                            AND status & 1 = 1)
                        BEGIN
                            -- At most one row will be updated in the following two updates as the artid is unique
                            -- among both sysarticles and sysschemaarticles
                            UPDATE sysarticles SET status = status & ~1 WHERE
                                artid = @artid
                            IF @@ERROR <> 0
                            BEGIN
                                CLOSE hCsubstatus
                                DEALLOCATE hCsubstatus
                                if @@trancount > 0
                                begin
                                    ROLLBACK TRANSACTION changesubstatus
                                    commit tran
                                end
                                RAISERROR (14069, 16, -1)
                                RETURN (1)
                            END
                            UPDATE sysschemaarticles SET status = status & ~1 WHERE
                                artid = @artid
                            IF @@ERROR <> 0
                            BEGIN
                                CLOSE hCsubstatus
                                DEALLOCATE hCsubstatus
                                if @@trancount > 0
                                begin
                                    ROLLBACK TRANSACTION changesubstatus
                                    commit tran
                                end
                                RAISERROR (14069, 16, -1)
                                RETURN (1)
                            END

                            SELECT @art_change = 1
                        END
                    END

                    /*
                    ** Set the object replication bits  to 'inactive' if
                    ** there are no other active subscriptions on the
                    ** table.
                    */
                    IF NOT EXISTS (SELECT * FROM syssubscriptions WHERE
                        artid IN (SELECT sa.artid FROM sysextendedarticlesview sa, syspublications sp WHERE
                        sa.objid = @tabid and sa.pubid = sp.pubid and sp.repl_freq = 0) AND status = @active)
                    BEGIN
                        UPDATE sysobjects SET replinfo =  replinfo & ~@replicate_bit
                        WHERE id = (SELECT objid FROM sysextendedarticlesview WHERE artid = @artid )

                        IF @@ERROR <> 0
                        BEGIN
                           CLOSE hCsubstatus
                            DEALLOCATE hCsubstatus
                            RAISERROR (14068, 16, -1)
                            if @@trancount > 0
                            begin
                                ROLLBACK TRANSACTION changesubstatus
                                commit tran
                            end
                            RETURN (1)
                        END
                    END
                END

				-- Note:  Not only do we need to have the replupdateschema already executed
				-- so we can handle rollbacks, we also need to
                -- acquire the schema lock before RPC to the distributor to avoid livelock
                -- with snapshot agents. Snapshot agents acquire lock on user table before
                -- updating the distribution db.

                if @no_distproc = 0
                begin
                    /*
                    ** Add the active subscription to the distributor's
                    ** subscriptions table if changing status from @inactive
                    */
                    IF @sub_status = @inactive 
                    -- From inactive to subscribed or active
                    BEGIN

                        DECLARE @null_char sysname
                        SELECT @null_char = NULL

                        DECLARE @zero_bit bit
                        SELECT @zero_bit = 0

                        SELECT @distproc = RTRIM(@distributor) + '.' + RTRIM(@distribdb) + '.dbo.sp_MSadd_subscription'
                        EXEC @retcode = @distproc @@SERVERNAME, @pub_db, @sub_name, 
                            @artid, @dest_db, @statusid, @sub_ts,
                            @publication, 
                            @null_char, /* Pass null to @article, we already gave @artid */
                            @subscription_type,
                            --@immediate_sync, 
                            @sync_type, 
                            @zero_bit,
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
                            @optional_command_line = @optional_command_line,
                            -- synctran
                            @update_mode = @update_mode,
                            @loopback_detection = @loopback_detection,
                            @distribution_jobid = @distribution_jobid OUTPUT,
                            @offloadagent = @offloadagent,
                            @offloadserver = @offloadserver,
							@dts_package_name = @dts_package_name,
							@dts_package_password = @dts_package_password,
							@dts_package_location = @dts_package_location,
							@distribution_job_name = @distribution_job_name

                        IF @@ERROR <> 0 OR @retcode <> 0
                        BEGIN
                            CLOSE hCsubstatus
                            DEALLOCATE hCsubstatus
                            RAISERROR (14070, 16, -1)
                            if @@trancount > 0
                            begin
                                ROLLBACK TRANSACTION changesubstatus
                                commit tran
                            end
                            RETURN (1)
                        END
                    END
                    ELSE
                    -- From subscribed or active to others
                    BEGIN
                        /*
                        ** Drop the deactivated subscription from the distributor's
                        ** subscriptions table.
                        */
                        IF @statusid = @inactive
                        -- From subscribed to inactive or from active to inactive
                        BEGIN
                            SELECT @distproc = RTRIM(@distributor) + '.' + RTRIM(@distribdb) + '.dbo.sp_MSdrop_subscription'
                            EXEC @retcode = @distproc @@SERVERNAME, @pub_db, @sub_name,  @artid, @dest_db, @publication
                            IF @@ERROR <> 0 OR @retcode <> 0
                            BEGIN
                                CLOSE hCsubstatus
                                DEALLOCATE hCsubstatus
                                RAISERROR (14070, 16, -1)
                                if @@trancount > 0
                                begin
                                    ROLLBACK TRANSACTION changesubstatus
                                    commit tran
                                end
                                RETURN (1)
                            END
                        END
                        ELSE 
                        -- From subscribed to initiated to active or from active to subscribed.
                        BEGIN
                            -- Don't do it if activating the subscription for snapshot agent.
                            --IF NOT (@from_auto_sync = 1 AND @statusid in(@active, @initiated) )
                            IF NOT (@from_auto_sync = 1 AND @statusid in(@active) )
                            BEGIN
                                SELECT @distproc = RTRIM(@distributor) + '.' + RTRIM(@distribdb) + '.dbo.sp_MSupdate_subscription'
                                EXEC @retcode = @distproc @@SERVERNAME, @pub_db, @sub_name, @artid, @statusid, @sub_ts, @dest_db
                                IF @@ERROR <> 0 OR @retcode <> 0
                                BEGIN
                                    CLOSE hCsubstatus
                                    DEALLOCATE hCsubstatus
                                    RAISERROR (14070, 16, -1)
                                    if @@trancount > 0
                                    begin
                                        ROLLBACK TRANSACTION changesubstatus
                                        commit tran
                                    end
                                    RETURN (1)
                                END
                            END
                        END
                    END
                end

                /*
                ** Set internal object replication bit  to 'inactive' if
                ** there are no other active subscriptions on the
                ** table.
                */

                IF @statusid = @inactive AND @sub_status IN (@active,@initiated) AND
                    NOT EXISTS (SELECT * FROM syssubscriptions WHERE
                    artid IN (SELECT artid FROM sysextendedarticlesview WHERE
                    objid = @tabid) AND status IN (@active,@initiated) )
                BEGIN
                       /*
                       ** If it's a procedure execution article, clear proc status bits
                       */
                       IF (@art_type & 8 ) = 8
                       BEGIN
                           UPDATE sysobjects SET replinfo = replinfo & ~24 WHERE id = @tabid
                       END
                END


                /* Turn on object replication */

                ELSE IF @statusid = @active
                BEGIN
                       IF (@art_type & 24 ) = 24
                       BEGIN

                           UPDATE sysobjects SET replinfo = replinfo | 24 WHERE id = @tabid
                       END
                       ELSE IF( @art_type & 8 ) = 8
                       BEGIN
                           UPDATE sysobjects SET replinfo = replinfo | 8 WHERE id = @tabid
                       END
                END


                exec dbo.sp_MSget_qualified_name @tabid, @qualified_name output
                exec dbo.sp_replupdateschema @qualified_name, @schemastabilityonly

               /*
               ** Get next row.
               */
               FETCH hCsubstatus INTO @artid, @tabid, @srvid, @sub_name, @dest_db,
               @sub_status, @non_sql_flag, @repl_freq, @art_type ,  
               @immediate_sync, @enabled_for_internet,
               @allow_anonymous, @subscription_type, @sync_type, @update_mode,
                @art_name, @login_name, @loopback_detection, @pubid

          
                                    
           END  -- end while for cursor

           CLOSE hCsubstatus
           DEALLOCATE hCsubstatus
        
        END -- end while for virtual and real

        -- force refresh of article cache
        -- Only do it if necessary
        -- No need on brute force cleanup
        IF ( @art_change = 1 ) and ( @ignore_distributor = 0 )
            EXECUTE dbo.sp_replflush

    COMMIT TRANSACTION
    drop table #sysextendedarticlesview
    RETURN(0)
go
 
EXEC dbo.sp_MS_marksystemobject sp_changesubstatus
GO

print ''
print 'Creating procedure sp_addsubscription'
go
CREATE PROCEDURE sp_addsubscription (
    @publication sysname,                            /* publication name */
    @article sysname = 'all',                        /* article name */
    @subscriber sysname = NULL,                        /* subscriber name */
    @destination_db sysname = NULL,                /* destination database */
    @sync_type nvarchar (15) = 'automatic',                /* subscription sync type */
    @status sysname = NULL,                            /* subscription status */
    @subscription_type nvarchar(4) = 'push',                /* subscription type:
                                                        ** 'push' or 'pull' */
    -- SyncTran
    @update_mode           nvarchar(30)    = 'read only',    -- Can be 'read only', 'sync tran', 'queued tran', 'failover'
    @loopback_detection nvarchar(5) = NULL, -- 'true' or 'false'
    -- end SyncTran

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
    
    @reserved nvarchar(10) = NULL,          /* reserved, used when calling from other system */
                                            /* stored procedures, it will be set to 'internal'.*/
                                            /* It should never be used directly */
    @enabled_for_syncmgr nvarchar(5) = 'false', /* Enabled for SYNCMGR: true or false */
    -- Agent offload
    @offloadagent bit = 0,
    @offloadserver sysname = NULL,
    -- End of agent offload
	-- DTS package name
	@dts_package_name sysname  = NULL,	/* value will be sent and validated at distributor */                                  
 	@dts_package_password  sysname = NULL,
	@dts_package_location nvarchar(12) = N'distributor',
	@distribution_job_name sysname = NULL
   ) AS

    SET NOCOUNT ON

    /*
    ** Declarations.
    */

    DECLARE @artid int
    DECLARE @pre_creation_cmd tinyint
    DECLARE @none tinyint
    DECLARE @automatic tinyint
    DECLARE @cmd nvarchar(255)
    DECLARE @cmd2 nvarchar(255)
    DECLARE @inactive tinyint
    DECLARE @active tinyint
    DECLARE @subscribed tinyint
    DECLARE @manual tinyint
    DECLARE @pubid int
    DECLARE @retcode int
    DECLARE @srvid smallint
    DECLARE @subscriber_bit smallint
    DECLARE @sync_typeid tinyint
    DECLARE @non_sql_flag bit
    DECLARE @truncate tinyint
    DECLARE @sync_method tinyint
    DECLARE @char_bcp tinyint
    DECLARE @concurrent tinyint
	DECLARE @concurrent_char tinyint
    DECLARE @internal nvarchar(10)
    DECLARE @status_id tinyint
    DECLARE @virtual_id smallint
    DECLARE @subscription_type_id int /* 0 push, 1 pull */
    DECLARE @immediate_sync bit    /* publication type */
    DECLARE @count_subs int
    DECLARE @count_arts int
    DECLARE @distribution_jobid binary(16)
    DECLARE @pubstatus tinyint
    DECLARE @allow_anonymous bit
    DECLARE @immediate_sync_ready bit
    declare @loopback_detection_id bit
    declare @independent_agent_id bit
    DECLARE @platform_nt binary
    		,@artsrctabid int

    DECLARE @dsn_dbname sysname
    DECLARE @dts_package_enc_password nvarchar(524)

    -- SyncTran
    DECLARE @allow_sync_tran_id bit
    DECLARE @allow_queued_tran_id bit
    DECLARE @update_mode_id     tinyint -- 0 = read only, 1 = sync tran, 2 = queued tran, 3 = failover
										-- 4 = sqlqueued tran, 5 = sqlqueued failover
	DECLARE	@publication_queue_type int 
    -- end SyncTran

    /*
    ** Initializations.
    */

    SELECT @none = 2            /* Const: synchronization type 'none' */
    SELECT @automatic = 1       /* Const: synchronization type 'automatic' */
    SELECT @manual = 0          /* Const: synchronization type 'manual' */
    SELECT @inactive = 0        /* Const: subscription status 'inactive' */
    SELECT @subscribed = 1        /* Const: subscription status 'subscribed' */
    SELECT @active = 2        /* Const: subscription status 'arctive' */
    SELECT @subscriber_bit = 4  /* Const: subscription server status */
    SELECT @truncate = 3    /* Const: truncate pre-creation command */
    SELECT @char_bcp = 1    /* Const: character bcp sync method */
    SELECT @concurrent = 3  /* Const: concurrent sync method */
    SELECT @concurrent_char = 4  /* Const: concurrent char mode sync method */
	SELECT @virtual_id = -1 /* Const: virtual subscriber id */
    SELECT @internal = 'internal' /* Const: Flag of calling internally from system */
                                  /* stored procedures     */
	
	-- Change it  in 7.5 to avoid confusion, expecially in ole db case
    -- SELECT @dsn_dbname = 'DSN'
    SELECT @dsn_dbname = formatmessage(20586)
    SELECT @platform_nt = 0x1
 
    /*
    ** Parameter Check: @publication.
    ** Check to make sure that the publication exists and that it conforms
    ** to the rules for identifiers.
    ** set subscription_type for the publication
    */

    IF @publication IS NOT NULL
        BEGIN
            
            EXECUTE @retcode = dbo.sp_validname @publication

            IF @retcode <> 0
        RETURN (1)

            IF NOT EXISTS (SELECT * FROM syspublications WHERE name = @publication)
                BEGIN
                    RAISERROR (20026, 11, -1, @publication)
                    RETURN (1)
                END

        END

    /*
    ** Parameter Check: @subscription_type
    ** Valid values:
    ** push
    ** pull
    **
    */

    IF LOWER(@subscription_type collate SQL_Latin1_General_CP1_CS_AS) NOT IN ('push', 'pull')
        BEGIN
            RAISERROR (14128, 16, -1)    
            RETURN (1)
        END

    IF LOWER(@subscription_type collate SQL_Latin1_General_CP1_CS_AS) = 'push'
        SELECT @subscription_type_id = 0
    ELSE 
        SELECT @subscription_type_id = 1

    /*
    ** Parameter Check: @offloadagent
    ** Valid values: 0 or 1 
    ** If @offloadagent = 1 then @subscription_type must be 'push'
    */
    IF (@offloadagent = 1 AND LOWER(@subscription_type collate SQL_Latin1_General_CP1_CS_AS) <> 'push')
    BEGIN
        RAISERROR(21138, 16, -1)
        RETURN (1)
    END 


    /*
    ** Parameter Check: @offloadserver
    ** Make sure that @offlaod server doesn't contain any invalid characters
    */
    EXEC @retcode = sp_MSreplcheckoffloadserver @offloadserver
    IF @retcode<>0 OR @@error<>0
        RETURN (1)
	/*
    ** Security Check.
    */

    IF @subscription_type_id = 0 
    BEGIN
        exec @retcode = dbo.sp_MSreplcheck_publish
        if @@ERROR <> 0 or @retcode <> 0
            return(1)
    END
    ELSE
    BEGIN
        exec @retcode = dbo.sp_MSreplcheck_pull @publication
        if @@ERROR <> 0 or @retcode <> 0
            return(1)
    END

   declare @allow_dts bit

   SELECT @pubid = pubid, @sync_method = sync_method, 
        @immediate_sync = immediate_sync, @pubstatus = status, 
        @allow_anonymous = allow_anonymous, 
        @immediate_sync_ready = immediate_sync_ready,
        -- SyncTran
        @allow_sync_tran_id = allow_sync_tran,
        @allow_queued_tran_id = allow_queued_tran,
        @independent_agent_id = independent_agent,
		@allow_dts = allow_dts
		,@publication_queue_type = queue_type
    FROM syspublications WHERE name = @publication

    select @srvid = srvid from master..sysservers where UPPER(srvname)=UPPER(@subscriber) collate database_default

    if exists (select name from sysobjects where name='sysmergesubscriptions')
        begin
            IF exists (select name from sysextendedarticlesview where pubid=@pubid and 
                objid in (select objid from sysmergeextendedarticlesview where 
                    pubid in (select pubid from sysmergesubscriptions where db_name=@destination_db and srvid=@srvid)))
            begin
                RAISERROR(21281, 16, -1, @publication, @destination_db)
                return (1)
            end
        end


    IF @pubid IS NULL
        BEGIN
            RAISERROR (14043, 16, -1, '@pubid')
            RETURN (1)
        END

	/* 
	** If publication is of concurrent sync, then all articles must
	** be subscribed to
	*/
	IF @sync_method IN( @concurrent, @concurrent_char) AND
	   LOWER(@article) != 'all' AND
	   @reserved != @internal
	BEGIN
		RAISERROR( 14100, 16, -1 )
		RETURN (1)
	END

    /* 
    ** Check to see if the desired subscription type is allowed
    */
    /* 
    ** push 
    ** Virtual subscriptions are always push type
    */
    IF @subscription_type_id = 0 AND @subscriber IS NOT NULL
    BEGIN
        IF NOT EXISTS (SELECT * from syspublications where
            allow_push = 1 AND
            pubid = @pubid)
        BEGIN
            RAISERROR (20012, 16, -1, @subscription_type, @publication)    
            RETURN (1)
        END
    END
        
    /* pull */
    IF @subscription_type_id = 1 AND @subscriber IS NOT NULL
    BEGIN
        IF NOT EXISTS (SELECT * from syspublications where
            allow_pull = 1 AND
            pubid = @pubid)
        BEGIN
            RAISERROR (20012, 16, -1, @subscription_type, @publication)    
            RETURN (1)
        END
    END

 /*
    ** Parameter Check: @subscriber.
    **
    ** Check if the server exists and that it is a subscription server.
    **
    ** @subscriber is NULL represent virtual subscription, which is not allowed
    ** in following case:
    ** 1. Non-immediate-sync publication
    ** 2. the stored procedure is not in the internal usage mode 
    **        (called by system stored procedures)
    ** 3. non push mode
    ** 
    */

    IF  @subscriber IS NULL AND (
        @immediate_sync = 0 OR
        @subscription_type_id <> 0 OR
        @reserved <> @internal)
        BEGIN
            RAISERROR (14043, 16, -1, '@subscriber')
            RETURN (1)
        END


    IF @subscriber IS NULL
        BEGIN
        /* set virtual subscriber ID */
            SELECT @srvid = @virtual_id 
            select @non_sql_flag = 0
        END
    ELSE
        BEGIN
            /* validate name and get subscriber ID  and server status  */
            EXECUTE @retcode = dbo.sp_validname @subscriber

            IF @retcode <> 0
            RETURN (1)

			select @srvid = null
            SELECT @srvid = srvid, @non_sql_flag = 
                case when srvproduct = N'MSREPL-NONSQL' then 1
                else 0 end
              FROM master..sysservers
             WHERE UPPER(srvname) = UPPER(@subscriber) collate database_default
               AND (srvstatus & @subscriber_bit) <> 0

            IF @srvid IS NULL
                BEGIN
                    RAISERROR (14010, 16, -1)
                   RETURN (1)
                END
        END

    /*
    ** Parameter Check: @destination_db.
    ** @destination_db can not be all. 
    ** Set @destination_db to current database if not specified.  Make
    ** sure that the @destination_db conforms to the rules for identifiers.
    */

    if LOWER(@destination_db) = 'all'
    BEGIN
        RAISERROR (14032, 16, -1, '@destination_db')
        RETURN (1)
    END

    IF @destination_db IS not NULL
	begin
		EXECUTE @retcode = dbo.sp_validname @destination_db
		IF @retcode <> 0
		RETURN (1)
	end

    /*
    ** Parameter Check:  @article
    */

    /* @article can not be null     */
    IF @article IS NULL
        BEGIN
            RAISERROR (14043, 16, -1, '@article')
            RETURN (1)
        END

	-- Queued Tran
    -- SyncTran
    /*
    ** Parameter check: @update_mode
    */
    IF @update_mode IS NULL OR LOWER(@update_mode collate SQL_Latin1_General_CP1_CS_AS) NOT IN ('read only', 'sync tran', 'queued tran', 'failover')
    BEGIN
        RAISERROR (20502, 16, -1, '@update_mode')
        RETURN (1)
    END

    IF (LOWER(@update_mode collate SQL_Latin1_General_CP1_CS_AS) = 'sync tran') 
    BEGIN
        SELECT @update_mode_id = 1
       
        -- Check if publication allows this option
        IF @allow_sync_tran_id <> 1
        BEGIN
            RAISERROR (20503, 16, -1, '@update_mode', 'sp_addsubscription','sync tran')
            RETURN (1)
        END
    END
    ELSE IF (LOWER(@update_mode collate SQL_Latin1_General_CP1_CS_AS) = 'queued tran')
    BEGIN    	
		SELECT @update_mode_id = case 
			when (@publication_queue_type = 2) then 4
			else 2 end
       
        -- Check if publication allows this option
        -- If the publication allow synctran, it allows queued tran.
        IF @allow_queued_tran_id <> 1
        BEGIN
            RAISERROR (20503, 16, -1, '@update_mode', 'sp_addsubscription', 'queued tran')
            RETURN (1)
        END
    END
    ELSE IF (LOWER(@update_mode collate SQL_Latin1_General_CP1_CS_AS) = 'failover')
    BEGIN
		SELECT @update_mode_id = case
			when (@publication_queue_type = 2) then 5
			else 3 end
       
        -- Check if publication allows this option
        IF @allow_sync_tran_id <> 1
        BEGIN
            RAISERROR (20503, 16, -1, '@update_mode', 'sp_addsubscription', 'sync tran')
            RETURN (1)
        END

        -- Check if publication allows this option
        IF @allow_queued_tran_id <> 1
        BEGIN
            RAISERROR (20503, 16, -1, '@update_mode', 'sp_addsubscription','queued tran')
            RETURN (1)
        END
    END
    ELSE 
    BEGIN
        SELECT @update_mode_id = 0
    END
    -- end SyncTran
    -- end Queued Tran

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
		if	@subscription_type_id != 0
		begin
			RAISERROR(21181, 16, -1)    
			RETURN (1)
		end
		if	@allow_dts = 0
		begin
			RAISERROR(21178, 16, -1)    
			RETURN (1)
		end
	end
	
	/** For immediate_sync publication, @article has to be 'all'     */
    IF NOT @reserved = @internal AND @immediate_sync = 1
        AND NOT LOWER(@article) = 'all'
        BEGIN
            RAISERROR (14122, 16, -1)
            RETURN (1)
        END

    /* 
    ** For full subscription, check to see if  subscriptions
    ** to ALL the articles exist before expanding parameter @article.
    **
    */
    IF LOWER(@article) = 'all' AND @reserved <> @internal AND
        EXISTS (SELECT * FROM syspublications WHERE pubid = @pubid)
    BEGIN
        SELECT @count_arts = count(*) FROM sysextendedarticlesview art
            WHERE art.pubid = @pubid 

		if @count_arts = 0
		BEGIN
            RAISERROR (14124, 16, -1)
            RETURN(1)
        END

        SELECT @count_subs = count(*) FROM syssubscriptions sub, 
                  sysextendedarticlesview art
            WHERE sub.srvid = @srvid
              AND sub.srvid >= 0
              AND sub.dest_db = @destination_db --or @non_sql_flag <> 0)
              AND sub.artid = art.artid
              AND art.pubid = @pubid

        IF @count_arts = @count_subs
        BEGIN
              RAISERROR (14058, 16, -1)
              RETURN (1)
        END
    END

    /* 
    ** Real subscription to inactive publicaton is not allowed
    ** Note, subscriptions to the new article will be added automatically
    ** for immediate_sync publications. At that time, the publication may not
    ** be active.
    */

    IF  @srvid <> @virtual_id AND @pubstatus = 0 AND @reserved <> @internal
        BEGIN
            RAISERROR (21000, 16, -1)
            RETURN (1)
        END


	-- If the publication is 'allow_dts', push subscription has to specify a DTS package.
	-- Error check that disallow ODBC subscriber to subscriber with DTS package
	-- is at the distributor.
	-- Show dts error first, otherwise user will get 21060 below which is confusing
	IF @allow_dts <> 0 and @dts_package_name is null and @subscriber IS not NULL and
		@reserved is null and @subscription_type_id = 0
	begin
		raiserror(21213, 16, -1)
		return(1)
	end

    /* 
    ** Do special things for DSN subscribers.
    */
    IF @subscriber IS NOT NULL AND @non_sql_flag <> 0
    BEGIN
		-- DSN or oledb subscriber not using DTS 
		-- cannot subscribe to native mode or concurrent snapshot publication
        IF @sync_method <> @char_bcp and @dts_package_name is null
        BEGIN
            RAISERROR (14095, 16, -1, @publication, @subscriber)
            RETURN (1)
        END

        -- DSN subscriber cannot subscribe with 'Sync Update'
        IF @update_mode_id <> 0
        BEGIN
            RAISERROR (21032, 16, -1, @subscriber)
            RETURN (1)
        END

        -- DSN subscriber cannot subscribe to article using custom procs
        -- or articles using parameterized statements
        -- ( only run this test during execs when the article name is actually specified )
        IF( LOWER( @article ) <> 'all' )
        BEGIN
            --IF EXISTS ( select * from sysextendedarticlesview sa, syspublications sp
                        --where sa.pubid = sp.pubid 
                        --and sp.name = @publication
                        --and sa.name = @article
                        --and ( ins_cmd like '%call%' or upd_cmd like '%call%' or del_cmd like '%call%' ) )
            --BEGIN
                --RAISERROR(21051, 16, -1, @subscriber)
                --RETURN (1)
            --END
			
			declare @art_status tinyint

			select @art_status = sa.status, @artsrctabid = sa.objid 
			from sysarticles sa, syspublications sp
				where sa.pubid = sp.pubid 
				and sp.name = @publication
				and sa.name = @article

			-- OLEDB or ODBC subscriber can not subscribe to article with parameterized command 
			-- unless using DTS 
            IF @dts_package_name is null and @art_status & 16 = 16 
            BEGIN
                RAISERROR(21060, 16, -1, @subscriber)
                RETURN (1)
            END

			-- OLEDB or ODBC subscribers can not subscriber to article with subscriber managed
			-- timestamp column
			if @art_status & 32 = 32
			begin
				raiserror(21249, 16, -1, @article, @publication)
				return (1)
			end

        END
    END

    -- DNS may define db.  If no db given, specify that DSN default should be used.
    -- use internal values
	if @subscriber IS NOT NULL and @destination_db is NULL
	begin
		IF @non_sql_flag <> 0 
			SELECT @destination_db = @dsn_dbname
		else
			SELECT @destination_db = DB_NAME()
	end

	-- if we're subscribing to a dump type publication, error
	-- out if this subscriber has any other subscriptions to publications
	-- other than this one

	IF @sync_method = 2
	BEGIN
		IF EXISTS( SELECT * FROM syssubscriptions sub, sysextendedarticlesview art
				WHERE sub.srvid = @srvid
				  AND sub.srvid >= 0
				  AND sub.dest_db = @destination_db
				  AND sub.artid = art.artid
				  AND art.pubid != @pubid )
		BEGIN
			RAISERROR(21144, 16, -1)
			RETURN 1
		END
	END

	-- else if we're subscribing to a char or native mode publication, 
	-- error out if the subscriber is subscribed to any dump type publications
	ELSE
	BEGIN
		IF EXISTS( SELECT * FROM syssubscriptions sub, sysextendedarticlesview art, syspublications pub
				WHERE sub.srvid = @srvid
				  AND sub.srvid >= 0
				  AND sub.dest_db = @destination_db
				  AND sub.artid = art.artid
				  AND art.pubid != @pubid
				  AND pub.pubid = art.pubid
				  AND pub.sync_method = 2 )

		BEGIN
			RAISERROR(21145, 16, -1, @publication )
			RETURN 1
		END
	END


    IF LOWER(@article) = 'all' 
    /*
    ** Get all articles in the publication that are not subscribed to
    ** by the @subscriber
    */
    BEGIN
            /*
            ** Make the operation atomic. This is to prevent multiple subscription_type
            ** from one subscriber on an immediate_sync publication
            */
            BEGIN TRAN 

            DECLARE hCx CURSOR LOCAL FAST_FORWARD FOR  SELECT DISTINCT a.name
                FROM sysextendedarticlesview a, syspublications b  
                WHERE a.pubid = b.pubid 
                AND b.name = @publication
                AND NOT EXISTS (SELECT * from syssubscriptions s 
                    WHERE s.artid = a.artid AND s.status <> 0 AND s.srvid = @srvid
                    AND s.dest_db = @destination_db)
            FOR READ ONLY

            EXECUTE (@cmd + @cmd2)
            OPEN hCx
            FETCH hCx INTO @article

            WHILE (@@fetch_status <> -1)
                BEGIN
                    EXECUTE @retcode = dbo.sp_addsubscription 
                                @publication       = @publication,
                                @article        = @article,
                                @subscriber     = @subscriber,
                                @destination_db = @destination_db,
                                @sync_type      = @sync_type,
								@status			= @status,
                                @subscription_type = @subscription_type,
                                @reserved       = @internal,
                                -- SyncTran
                                @update_mode    = @update_mode,      
                                -- end SyncTran
								@loopback_detection = @loopback_detection,
                                @frequency_type  = @frequency_type,
                                @frequency_interval  = @frequency_interval,
                                @frequency_relative_interval  = @frequency_relative_interval,
                                @frequency_recurrence_factor  = @frequency_recurrence_factor,
                                @frequency_subday  = @frequency_subday,
                                @frequency_subday_interval  = @frequency_subday_interval,
                                @active_start_time_of_day  = @active_start_time_of_day,
                                @active_end_time_of_day  = @active_end_time_of_day,
                                @active_start_date  = @active_start_date,
                                @active_end_date  = @active_end_date,
                                @optional_command_line = @optional_command_line,
                                @offloadserver = @offloadserver,
                                @offloadagent = @offloadagent,
								@dts_package_name = @dts_package_name,
								@dts_package_password = @dts_package_password,
								@dts_package_location = @dts_package_location,
								@distribution_job_name = @distribution_job_name
    

                    IF @@error <> 0 OR @retcode <> 0
                    BEGIN
                       CLOSE hCx
                       DEALLOCATE hCx
                       if @@trancount > 0
                            ROLLBACK TRAN 
                       RETURN (1)
                    END
                    FETCH hCx INTO @article
                END
            CLOSE hCx
            DEALLOCATE hCx

            COMMIT TRAN

            RETURN (0)
        END

   
    /* After 'all' being expanded, check to make sure that the article exists, 
    ** is not NULL, and conforms to the rules for identifiers.
    */
    /*
    EXECUTE @retcode = dbo.sp_validname @article
    IF @retcode <> 0
    RETURN (1)
    */

	declare @dest_owner sysname

    SELECT @artid = artid, @pre_creation_cmd = pre_creation_cmd,
		@dest_owner = dest_owner
    FROM sysextendedarticlesview
    WHERE name = @article
    AND pubid = @pubid

    IF NOT EXISTS (SELECT *
                             FROM sysextendedarticlesview
                            WHERE artid = @artid
                              AND pubid = @pubid)
        BEGIN
            RAISERROR (20027, 11, -1, @article)
            RETURN (1)
        END


    /*
    ** If the subscriber is an ODBC DSN, do not allow subscriptions to
    ** articles with a "truncate" pre_creation_cmd.
    */
    IF @non_sql_flag <> 0 AND @pre_creation_cmd = @truncate
        BEGIN
            RAISERROR (14094, 16, -1, @article, @subscriber)
            RETURN (1)
        END

    IF @non_sql_flag <> 0 AND @dest_owner is not null and @dest_owner <> N''
        BEGIN
			--RAISERROR (21039, 16, -1, @article, @subscriber)
			-- YWU: UNDONE fix the message after Beta2
			RAISERROR (21039, 16, -1)
            RETURN (1)
        END

   /*
   ** Parameter Check: @sync_type.
   ** Set sync_typeid based on the @sync_type specified.
   **
   **   sync_typeid     sync_type
   **   ===========     =========
   **             0     manual
   **             1     automatic
   **             2     none
   */


   IF LOWER(@sync_type collate SQL_Latin1_General_CP1_CS_AS) NOT IN ('automatic', 'manual', 'none')
       BEGIN
           RAISERROR (14052, 16, -1)
           RETURN (1)
       END

   IF LOWER(@sync_type collate SQL_Latin1_General_CP1_CS_AS) = 'manual'
       BEGIN
           RAISERROR (14123, 16, -1)
           RETURN (1)
       END


   IF LOWER(@sync_type collate SQL_Latin1_General_CP1_CS_AS) = 'automatic'
   BEGIN
        SELECT @sync_typeid = @automatic
   END
   ELSE
   BEGIN
        SELECT @sync_typeid = @none
   END


    /*
    ** Parameter Check: @status
    ** If the publication is immediate_sync type and sync_type is automatic
    ** the status has to be NULL.
    ** Note for 6x backward compatibility, don't do the check for non immediate_sync
    ** publication
    */
    IF @immediate_sync = 1 and @sync_typeid = @automatic AND 
        @status IS NOT NULL
    BEGIN
          RAISERROR (14129, 16, -1)
          RETURN (1)
    END

    /*
    ** Parameter Check:  @loopback_detection
    */
    IF @loopback_detection is not null and LOWER(@loopback_detection collate SQL_Latin1_General_CP1_CS_AS) 
        NOT IN ('true', 'false')
    BEGIN
        RAISERROR (14148, 16, -1, '@loopback_detection')
        RETURN (1)
    END

    IF  LOWER(@loopback_detection collate SQL_Latin1_General_CP1_CS_AS) = 'true'  
        SELECT @loopback_detection_id = 1
    ELSE IF LOWER(@loopback_detection collate SQL_Latin1_General_CP1_CS_AS) = 'false' 
        SELECT @loopback_detection_id = 0
    ELSE 
    -- if @loopback_detection is null, we will chose the value
    begin
	    -- turn on loopback detection for sync and queued
		if @update_mode_id in (1,2,3,4,5) 
            select @loopback_detection_id = 1
        else
            select @loopback_detection_id = 0
    end

	select @dts_package_enc_password = @dts_package_password
	if @dts_package_password is not null
	begin
		EXEC @retcode = master.dbo.xp_repl_encrypt @dts_package_enc_password OUTPUT
		IF @@error <> 0 OR @retcode <> 0
			return 1
	end

	--
	-- For updating subscriptions (immediate)
	-- Check if there exists an subscription to the same
	-- dest_db which contain at least one article which has 
	-- the same source_table as the current article - 
	-- If yes then raise a warning
	-- NOTE : this restriction is due to the fact that loopback
	-- detection happens at database level and hence for updating
	-- subscriptions, we can lose the updates made in one subscription
	-- w.r.t. the other subscription
	--
	if (@update_mode_id = 1)
	begin
		if exists (select * from dbo.syssubscriptions 
			where srvid = @srvid and dest_db = @destination_db and artid in 
				(select artid from dbo.sysarticles 
					where objid = (select objid from sysarticles where artid = @artid)))
		begin
			raiserror(21293, 10, 1, @article, @destination_db)
		end
	end

    /*
    ** Add subscription to syssubscriptions
    */
    begin tran
    save TRAN addsubscription

    /*
    ** If no subscription exists, add it to syssubscriptions.
    */
    IF NOT EXISTS (SELECT *
                     FROM syssubscriptions
                    WHERE srvid = @srvid
                      AND artid = @artid
                      AND dest_db = @destination_db )--or @non_sql_flag <> 0))
        BEGIN
       INSERT syssubscriptions (artid,
                                    srvid,
                                    dest_db,
                                    login_name,
                                    status,
                                    sync_type,
                                    subscription_type,
                                    distribution_jobid,
                                    -- SyncTran
                                    update_mode,
                                    loopback_detection,
                                    queued_reinit)
                                 /*  timestamp) */
       VALUES (@artid,
                   @srvid,
                   @destination_db,    
                   suser_sname(suser_sid()),
                   @inactive,
                   @sync_typeid,
                   @subscription_type_id,
                   0,
                   -- SyncTran
                   @update_mode_id,
                   @loopback_detection_id,
                   1)
           /*  NULL) */

       IF @@ERROR <> 0
           BEGIN
                if @@trancount > 0
                begin
                    ROLLBACK TRAN  addsubscription
                    commit tran
                end
                RAISERROR (14057, 16, -1)
                RETURN (1)
           END
        END
    ELSE
       BEGIN
          RAISERROR (14058, 16, -1)
          if @@trancount > 0
            begin
                ROLLBACK TRAN  addsubscription
                commit tran
            end
          RETURN (1)
       END

    /*
    ** If the @status was not provided determine the default value.
    ** If the @sync_type = 'none' then the subscription defaults to 'active'.
    ** Else the subscription defaults to 'subscribed'.
    */
    IF @status IS NULL
    BEGIN
        IF @sync_typeid = @none    
            SELECT @status = 'active'
        ELSE
            SELECT @status = 'subscribed'
    END


    /*
    ** Set publication subscription status.
    */
    EXEC @retcode = dbo.sp_changesubstatus
    @publication = @publication,
    @article     = @article,
    @subscriber  = @subscriber,
    @status      = @status,
    @destination_db = @destination_db,
    
    @frequency_type  = @frequency_type,
    @frequency_interval  = @frequency_interval,
    @frequency_relative_interval  = @frequency_relative_interval,
    @frequency_recurrence_factor  = @frequency_recurrence_factor,
    @frequency_subday  = @frequency_subday,
    @frequency_subday_interval  = @frequency_subday_interval,
    @active_start_time_of_day  = @active_start_time_of_day,
    @active_end_time_of_day  = @active_end_time_of_day,
    @active_start_date  = @active_start_date,
    @active_end_date  = @active_end_date,
    @optional_command_line = @optional_command_line,
    @distribution_jobid = @distribution_jobid OUTPUT,
    @offloadagent = @offloadagent,
    @offloadserver = @offloadserver,
	@dts_package_name = @dts_package_name,
	@dts_package_password = @dts_package_enc_password,
	@dts_package_location = @dts_package_location_id,
	@distribution_job_name = @distribution_job_name  
    
	IF @@error <> 0 OR @retcode <> 0
    BEGIN
        if @@trancount > 0
        begin
            ROLLBACK TRAN  addsubscription
            commit tran
        end
       RAISERROR (14057, 16, -1)
       RETURN (1)
    END

    UPDATE syssubscriptions SET 
        distribution_jobid = @distribution_jobid where
        artid = @artid AND
        srvid = @srvid AND
        dest_db = @destination_db            

    IF @@error <> 0
    BEGIN
        if @@trancount > 0
        begin
            ROLLBACK TRAN  addsubscription
            commit tran
        end
       RETURN (1)
    END


    /*
    ** If possible, activate the real subscriptions on immediate_sync publication
    ** immediately. Also, activate the virtual subscriptions on 
    ** anonymous publications immediately.
    ** We change the subscription status from 'subscribed' to 'active' so that 
    ** sp_MSupdate_subscription will be called, which will set the subscription's
    ** xactid_ts to the snapshot xactid_ts of virtual subscriptions. This means that
    ** we have to call sp_changesubstatus again here. We can not combine two calls 
    ** into ONE !!!
    **
    ** Activate the subscription immediately if 
    ** 1. The publication is immediate_sync type
    ** 2. sync_type is 'automatic'
    ** AND
    ** 1. The subscription is real
    ** 2. The snapshot has completed once
    ** 3. The subscription is the last subscription added to the publication (subscription for
    ** the last article). This is to guarantee the subscription status of all the articles
    ** in the publication be activate in one transaction at the distributor. This is
    ** to prevent the distribution agent from picking up partial subscriptions. 
    ** Note that this SP will be called with @article = 'all'
    ** OR
    ** 1. The publication is active
    ** 2. The publication is allow_anonymous
    ** 3. The subscription is virtual
    ** 
    */
    
    IF  @sync_typeid = @automatic AND @immediate_sync = 1 AND
        
        ((@srvid <> @virtual_id AND 
        @immediate_sync_ready = 1 AND
        NOT EXISTS (select * from sysextendedarticlesview art where
                    art.pubid = @pubid and
                    not exists (select * from syssubscriptions sub
                        where sub.artid = art.artid and
                              sub.srvid = @srvid and
                              sub.dest_db = @destination_db))) OR

        (@pubstatus = 1 and @srvid = @virtual_id and @allow_anonymous = 1))
    BEGIN
        DECLARE @article_ex sysname
        IF @srvid <> @virtual_id
            SELECT @article_ex = '%'
        ELSE
            SELECT @article_ex = @article

        /*
        ** Set publication subscription status.
        */
        EXEC @retcode = dbo.sp_changesubstatus
        @publication = @publication,
        @article     = @article_ex,
        @subscriber  = @subscriber,
        @status      = 'active',
        @destination_db = @destination_db,
        @offloadagent = @offloadagent,
        @offloadserver = @offloadserver

        IF @@error <> 0 OR @retcode <> 0
        BEGIN
            if @@trancount > 0
            begin
                ROLLBACK TRAN  addsubscription
                commit tran
            end
           RAISERROR (14057, 16, -1)
           RETURN (1)
        END
    END

    /* Conditional support for MobileSync */
    if LOWER(@enabled_for_syncmgr collate SQL_Latin1_General_CP1_CS_AS) = 'true'
    BEGIN
        /* MobileSync Support */
        declare @distributor_server                 sysname
        declare @distributor_security_mode          int
        declare @distributor_login                  sysname
        declare @distributor_password               sysname
        declare @publisher_db sysname
        
        set @publisher_db = DB_NAME()
        /* 
        ** The registry entry needs to be created only for push subscriptions -  
        ** i.e - need not be called when a pull subscription is created at the 
        ** subscriber and sp_addmergesubscription is being called then.
        */
        IF LOWER(@subscription_type collate SQL_Latin1_General_CP1_CS_AS) = 'push'
        BEGIN
            EXECUTE @retcode = dbo.sp_helpdistributor
                @distributor = @distributor_server OUTPUT               /* Distributor RPC server name */

            IF @@ERROR <> 0 or @retcode <> 0
                BEGIN
                    if @@trancount > 0
                        ROLLBACK TRAN  addsubscription
                    RAISERROR (14057, 16, -1)
                    RETURN (1)
                END

            -- Always use integrated security on winNT
            if (@platform_nt = platform() & @platform_nt )
                begin
                    set @distributor_security_mode = 1
                end
            -- For Win9x the dist publisher and distributor are the same machine                
            else
                begin
                    select  @distributor_security_mode = 0,
                        @distributor_login  = login,
                        @distributor_password = password
                    from msdb..MSdistpublishers where UPPER(name) = UPPER(@@servername) collate database_default
                end


            /* Call sp_MSregistersubscription so that the subscription can be synchronized via Onestop etc. */
            declare @subscription_id uniqueidentifier
            set @subscription_id = convert(uniqueidentifier, @distribution_jobid)
            exec @retcode = dbo.sp_MSregistersubscription @replication_type = 1,
                                    @publisher = @@SERVERNAME,
                                    @publisher_db = @publisher_db,
                                    @publication = @publication,
                                    @subscriber = @subscriber,
                                    @subscriber_db = @destination_db,
                                    @distributor = @distributor_server,
                                    @distributor_security_mode = @distributor_security_mode,
                                    @distributor_login = @distributor_login,
                                    @distributor_password = @distributor_password,
                                    @subscription_id = @subscription_id,
                                    @independent_agent = @independent_agent_id,
                                    @subscription_type = @subscription_type_id


            IF @@ERROR <> 0 or @retcode <> 0
                BEGIN
                    if @@trancount > 0
                        ROLLBACK TRAN  addsubscription
                    RAISERROR (14057, 16, -1)
                    RETURN (1)
                END
        END
    END
    COMMIT TRAN
go
 
EXEC dbo.sp_MS_marksystemobject sp_addsubscription
GO

print ''
print 'Creating procedure sp_MSchangeschemaarticle'
GO
CREATE PROCEDURE sp_MSchangeschemaarticle (
    @pubid int,
    @artid int,
    @property sysname,
    @value nvarchar(255)
    ) AS
    SET NOCOUNT ON
    DECLARE @retcode int
    DECLARE @pre_creation_cmdid tinyint
    DECLARE @statusid int
    DECLARE @schema_option_table_created bit
    DECLARE @creation_script nvarchar(255)
    DECLARE @type tinyint
    DECLARE @schema_option binary(8)
    DECLARE @valid_schema_options int

    SELECT @type = type 
      FROM sysextendedarticlesview
     WHERE artid = @artid
       AND pubid = @pubid 

    SELECT @schema_option_table_created = 0

    /* 
    ** The pubid and artid passed into this procedure from sp_changearticle
    ** have to be valid by now.
    */
    
    /*
    ** Parameter check: @property
    */
    SELECT @property = LOWER(@property collate SQL_Latin1_General_CP1_CS_AS)
    IF @property NOT IN ('description',
                         'dest_object',
                         'creation_script',
                         'pre_creation_cmd',
                         'schema_option',
                         'destination_owner')
    BEGIN
        RAISERROR(21224, 16, -1, @property)
        RETURN (1)
    END
                         
    -- Since all property changes will take the form of 
    -- simple update stataments, no transaction will be 
    -- started. 

    IF @property = N'description'
    BEGIN
        UPDATE sysschemaarticles 
           SET description = @value
         WHERE artid = @artid
           AND pubid = @pubid

        IF @@ERROR <> 0
            RETURN (1)
    END
    ELSE IF @property = N'dest_object'
    BEGIN
        UPDATE sysschemaarticles
           SET dest_object = @value
         WHERE artid = @artid
           AND pubid = @pubid 

        IF @@ERROR <> 0
            RETURN (1)
    END
    ELSE IF @property = N'creation_script'
    BEGIN
        UPDATE sysschemaarticles 
           SET creation_script = @value
         WHERE artid = @artid
           AND pubid = @pubid

        IF @@ERROR <> 0
            RETURN (1)
    END
    ELSE IF @property = N'pre_creation_cmd'
    BEGIN
        /* 
        ** Validate the given value for
        ** the property. It has to be either 
        ** 'none' or 'drop' case-insensitive.
        */
        SELECT @value = LOWER(@value collate SQL_Latin1_General_CP1_CS_AS)
        IF @value NOT IN ('none', 'drop')
        BEGIN
            RAISERROR(21223, 16, -1)
            RETURN (1)
        END

        IF @value = N'none'
            SELECT @pre_creation_cmdid = 0
        ELSE IF @value = N'drop'
            SELECT @pre_creation_cmdid = 1
        
        UPDATE sysschemaarticles
           SET pre_creation_cmd = @pre_creation_cmdid
         WHERE artid = @artid
           AND pubid = @pubid
        
        IF @@ERROR <> 0
            RETURN (1)

    END
    ELSE IF @property = N'schema_option'    
    BEGIN
        
        IF @value IS NULL
        BEGIN
            RAISERROR(14146, 16,1)
            RETURN (1)
        END

        CREATE TABLE #tab_changeschemaarticle (value varbinary(8) NULL)
        IF @@ERROR <> 0
        BEGIN
           RETURN (1)
        END

        EXEC ('insert #tab_changeschemaarticle values (' + 
            @value + ')')

        IF @@ERROR <> 0
        BEGIN
            DROP TABLE #tab_changeschemaarticle 
            RETURN (1)
        END
        
        SELECT @schema_option = fn_replprepadbinary8(value) 
          FROM #tab_changeschemaarticle
        /*
        ** schema_option can only contain the bits 0x0000000000000001 and
        ** 0x0000000000002000
        ** for schema only articles except view. View articles can contain 
        ** the options 0x0000000000000010, 0x0000000000000020, 
        ** and 0x0000000000000100 in addition to the aforementioned options.
        */
        IF @type = 0x40
        BEGIN

            -- Since only the lower 32 bits of @schema_option are
            -- currently used, the following check is sufficient.
            -- Note that @schema_option should have been padded by now.
            DECLARE @schema_option_lodword int
            SELECT @valid_schema_options = 0x2151
            SELECT @schema_option_lodword = fn_replgetbinary8lodword(@schema_option)
            IF (@schema_option_lodword & ~@valid_schema_options) <> 0
            BEGIN
                RAISERROR (21229, 16, -1)
                RETURN (1)
            END
        END
        ELSE IF @schema_option NOT IN (0x0000000000000000,
                                       0x0000000000000001,
                                       0x0000000000002000,
                                       0x0000000000002001)
        BEGIN
            DROP TABLE #tab_changeschemaarticle
            RAISERROR (21222, 16, -1)
            RETURN (1)
        END 

        IF EXISTS (SELECT * FROM #tab_changeschemaarticle
                    WHERE value = 0x0000000000000000)
        BEGIN
        
            SELECT @creation_script = NULL
            SELECT @creation_script = creation_script
              FROM sysschemaarticles
             WHERE artid = @artid
               AND pubid = @pubid
/*            
            IF @creation_script IS NULL OR
               @creation_script = N''
            BEGIN
                RAISERROR(21218, 16, -1)
                DROP TABLE #tab_changeschemaarticle
                RETURN (1)
            END
*/
        END
            
        UPDATE sysschemaarticles
           SET schema_option = tab.value
          FROM #tab_changeschemaarticle tab
         WHERE artid = @artid 
           AND pubid = @pubid         
            
        IF @@ERROR <> 0
        BEGIN
            DROP TABLE #tab_changeschemaarticle
            RETURN (1)
        END    

        DROP TABLE #tab_changeschemaarticle

        IF @@ERROR <> 0
            RETURN (1)
    END
    ELSE IF @property = N'destination_owner'
    BEGIN
        
        UPDATE sysschemaarticles
           SET dest_owner = @value
         WHERE artid = @artid
           AND pubid = @pubid

        IF @@ERROR <> 0
            RETURN (1)
    END    

    RAISERROR (14025, 10, -1)
    RETURN (0)
GO

EXEC dbo.sp_MS_marksystemobject sp_MSchangeschemaarticle
GO

print ''
print 'Creating procedure sp_changearticle'
GO
CREATE PROCEDURE sp_changearticle (
    @publication sysname = NULL,        /* Publication name */
    @article sysname = NULL,            /* Article name */
    @property nvarchar(20) = NULL,      /* The property to change */
    @value nvarchar(255) = NULL,        /* The new property value */
	@force_invalidate_snapshot bit = 0,	/* Force invalidate existing snapshot */
	@force_reinit_subscription bit = 0	/* Force reinit subscription */
) AS
BEGIN

    SET NOCOUNT ON

    /*
    ** Declarations.
    */

	DECLARE @artid int
			,@cmd1 nvarchar(512)
			,@cmd2 nvarchar(512)
			,@db sysname
			,@filter int
			,@object sysname
			,@owner sysname
			,@pubid int
			,@retcode int
			,@site sysname
			,@sync_objid int
			,@typeid tinyint
			,@old_typeid tinyint
			,@precmdid tinyint
			,@active tinyint
			,@virtual_id smallint
			,@article_type tinyint

			,@objid    int
			,@objtype  nchar(2)
			,@old_filter_name sysname

			,@distributor sysname
			,@distribdb sysname
			,@dbname sysname
			,@distproc nvarchar (255)
			,@dts_part nvarchar(50)
			,@no_dts_part nvarchar(50)
			,@backward_comp_level int
			,@allow_dts bit
			,@allow_queued_tran bit

	select @backward_comp_level = 10 -- default to sphinx
			,@dts_part = N'dts horizontal partitions'
			,@no_dts_part = N'no dts horizontal partitions'
			,@active = 2
			,@virtual_id = -1

    /*
    ** Security Check
    */
    exec @retcode = dbo.sp_MSreplcheck_publish
    if @@ERROR <> 0 or @retcode <> 0
        return(1)

    /*
    ** Check to see if the database has been activated for publication.
    */

    IF (SELECT category & 1
          FROM master..sysdatabases
         WHERE name = DB_NAME() collate database_default) = 0

    BEGIN
            RAISERROR (14013, 16, -1)
            RETURN (1)
        END


    /*
    ** Parameter Check:  @publication.
    ** Make sure that the publication exists.
    */

    IF @publication IS NULL
        BEGIN
            RAISERROR (14043, 16, -1, '@publication')
            RETURN (1)
        END

    EXECUTE @retcode = dbo.sp_validname @publication

    IF @@ERROR <> 0 OR @retcode <> 0
    RETURN (1)

	SELECT @pubid = pubid
		,@allow_dts = allow_dts
		,@allow_queued_tran = allow_queued_tran
	FROM syspublications 
	WHERE name = @publication

    IF @pubid IS NULL
        BEGIN
            RAISERROR (20026, 11, -1, @publication)
            RETURN (1)
        END

    /*
    ** Check to see that the article exists in sysextendedarticlesview.
    ** Fetch the article identification number.
    */

    IF @article IS NULL
        BEGIN
            RAISERROR (14043, 16, -1, '@article')
            RETURN (1)
        END

    /*
    EXECUTE @retcode = dbo.sp_validname @article

    IF @retcode <> 0
    RETURN (1)
    */
    SELECT @artid = artid, @article_type = type, @objid = objid 
      FROM sysextendedarticlesview
     WHERE name = @article
       AND pubid = @pubid
    IF @artid IS NULL
        BEGIN
            RAISERROR (20027, 11, -1, @article)
            RETURN (1)
        END


    /*
    ** Get the object id and type from sysobjects
    */

    SELECT @objtype = type
       FROM sysobjects
       WHERE id = @objid

    IF @objtype IS NULL
    BEGIN
        RAISERROR( 20027, 11, -1, @article )
        RETURN( 1 )
    END

    /*
    ** Parameter Check:  @property.
    ** If the @property parameter is NULL, print the options.
    */

    IF @property IS NULL
        BEGIN
            CREATE TABLE #tab1 (properties sysname collate database_default not null)
            INSERT INTO #tab1 VALUES ('description')
            INSERT INTO #tab1 VALUES ('sync_object (log based article only)')
            INSERT INTO #tab1 VALUES ('type')
            INSERT INTO #tab1 VALUES ('ins_cmd (log based article only)')
            INSERT INTO #tab1 VALUES ('del_cmd (log based article only)')
            INSERT INTO #tab1 VALUES ('upd_cmd (log based article only)')
            INSERT INTO #tab1 VALUES ('filter (log based article only)')
            INSERT INTO #tab1 VALUES ('dest_table (log based article only)')
            INSERT INTO #tab1 VALUES ('dest_object')
            INSERT INTO #tab1 VALUES ('creation_script')
            INSERT INTO #tab1 VALUES ('pre_creation_cmd')
            INSERT INTO #tab1 VALUES ('status')
            INSERT INTO #tab1 VALUES ('schema_option')
            INSERT INTO #tab1 VALUES ('destination_owner')
   			INSERT INTO #tab1 VALUES ('pub_identity_range (log based article only)')
			INSERT INTO #tab1 VALUES ('identity_range (log based article only)')
			INSERT INTO #tab1 VALUES ('threshold (log based article only)')
            PRINT ''
            SELECT * FROM #tab1
            RETURN (0)
        END

    /*
    ** At this point, we have completed all the validations and 
    ** preprocessings common to both regular and schema only articles 
    ** so we call a different proceudre here to handle the schema only
    ** articles differently.
    */
    
    IF @article_type in (0x20, 0x40, 0x80)
    BEGIN
        EXEC @retcode = sp_MSchangeschemaarticle 
                @pubid = @pubid,
                @artid = @artid,
                @property = @property,
                @value = @value    
        RETURN @retcode
    END  

    IF @objtype = 'U' AND LOWER(@property collate SQL_Latin1_General_CP1_CS_AS) NOT IN 
                                                  ('description',
                                                   'sync_object',
                                                   'type',
                                                   'ins_cmd',
                                                   'del_cmd',
                                                   'upd_cmd',
                                                   'filter',
                                                   'dest_table',
                                                   'dest_object',
                                                   'creation_script',
                                                   'pre_creation_cmd',
                                                   'status',
                                                   'schema_option',
                                                   'destination_owner',
                                                    'pub_identity_range',
                                                    'identity_range',
                                                    'threshold')
        BEGIN
            RAISERROR (21183, 16, -1, @property)
            RETURN (1)
        END

    IF @objtype = 'P' AND LOWER(@property collate SQL_Latin1_General_CP1_CS_AS) NOT IN 
                                                  ('description',
												   'dest_object',
                                                   'dest_table',
                                                   'creation_script',
                                                   'pre_creation_cmd',
                                                   'schema_option',
                                                   'destination_owner')
        BEGIN
            RAISERROR (14110, 16, -1)
            RETURN (1)
        END


    /* dest_object and 'dest_table' are same */
    IF LOWER(@property collate SQL_Latin1_General_CP1_CS_AS) = 'dest_object'
        SELECT @property = 'dest_table' 

	
	IF (@allow_dts = 1 or @allow_queued_tran = 1) and LOWER(@property collate SQL_Latin1_General_CP1_CS_AS) IN ('ins_cmd', 'del_cmd', 'upd_cmd' )
	begin
		raiserror(21175, 16, -1)
		return (1)
	end
	
	/*
	** Check to make sure that we have a valid type for status
	*/
    IF LOWER(@property collate SQL_Latin1_General_CP1_CS_AS) = 'status'
    BEGIN
		IF LOWER(@value collate SQL_Latin1_General_CP1_CS_AS) IN ('not owner qualified', 'owner qualified')
		BEGIN
			RAISERROR (21023, 16, -1,@value)
			RETURN (1)
		END

		IF LOWER(@value collate SQL_Latin1_General_CP1_CS_AS) NOT IN ('no column names', 'include column names', 'string literals', 'parameters',
			@dts_part, @no_dts_part )
		BEGIN
			RAISERROR (14097, 16, -1)
			RETURN (1)
		END

		IF	LOWER(@value collate SQL_Latin1_General_CP1_CS_AS) in (@dts_part,@no_dts_part)
		begin
			if @allow_dts = 0
			begin
				-- Invalid status for non dts pub
				raiserror(20592, 16, -1)
				RETURN (1)
			end
		end
		else
		begin
			if @allow_dts = 1
			begin
				-- Invalid status for dts pub
				raiserror(20591, 16, -1)
				RETURN (1)
			end
		end
	end
	
	IF LOWER(@property collate SQL_Latin1_General_CP1_CS_AS) IN ( 'ins_cmd', 'del_cmd', 'upd_cmd' )
	BEGIN
		if exists (select * from syspublications 
		where
		pubid = @pubid and sync_method = 3) and lower(@value) not like '%call%'
		BEGIN
			RAISERROR( 21154, 16, -1, @article )
			return 1
		END
	END

	declare @need_new_snapshot bit
		,@need_reinit_subscription bit

	select @need_new_snapshot = 0
	select @need_reinit_subscription = 0

	if LOWER(@property collate SQL_Latin1_General_CP1_CS_AS) in ( N'ins_cmd', N'del_cmd', N'upd_cmd', 
        N'dest_table', N'destination_owner' ,N'type',N'filter',  
		N'pre_creation_cmd', N'schema_option') or 
		(LOWER(@property collate SQL_Latin1_General_CP1_CS_AS) = 'status' and LOWER(@value collate SQL_Latin1_General_CP1_CS_AS) in (@dts_part,
		@no_dts_part))
	begin
		select @need_new_snapshot = 1
		select @need_reinit_subscription = 1
	end
	else if LOWER(@property collate SQL_Latin1_General_CP1_CS_AS) in ('sync_object',
		'creation_script')
	begin
		select @need_new_snapshot = 1
	end

	-- Have to call this stored procedure to invalidate existing snapshot or reint
	-- subscriptions if needed
	EXECUTE @retcode  = dbo.sp_MSreinit_article
		@publication = @publication, 
		@article = @article,
		@need_new_snapshot = @need_new_snapshot,
		@need_reinit_subscription = @need_reinit_subscription
		,@force_invalidate_snapshot = @force_invalidate_snapshot	/* Force invalidate existing snapshot */
		,@force_reinit_subscription = @force_reinit_subscription	/* Force reinit subscription */
		,@check_only = 1
	IF @@ERROR <> 0 OR @retcode <> 0
		return(1)

    /*
    ** Change the property.
    */

    begin tran
    save TRAN sp_changearticle

        IF LOWER(@property collate SQL_Latin1_General_CP1_CS_AS) IN ( 'description', 'ins_cmd', 'del_cmd', 'upd_cmd', 'dest_table', 'creation_script', 'dest_object')
            BEGIN


            /*
            ** Check the validity of the destination object.  NULL should
            ** get converted to the source object name.  Destination object
            ** names can be owner qualified, but not database qualified.
            */

            IF LOWER(@property collate SQL_Latin1_General_CP1_CS_AS) = 'dest_table' OR LOWER(@property collate SQL_Latin1_General_CP1_CS_AS) = 'dest_object'
                BEGIN
                    IF @value IS NULL
                        SELECT @value = object_name(objid)
                          FROM sysarticles
                         WHERE artid = @artid
                           AND pubid = @pubid
                END

            SELECT @cmd1 = 'UPDATE sysarticles '

            IF @value IS NULL
            BEGIN
                    SELECT @cmd1 = @cmd1 + '   SET ' + LOWER(@property collate SQL_Latin1_General_CP1_CS_AS) + ' = NULL'
                SELECT @cmd2 = ' WHERE artid = ' + STR(@artid)
                SELECT @cmd2 = @cmd2 + '   AND pubid = ' + STR(@pubid)
                EXECUTE (@cmd1 + @cmd2)
            END
            ELSE
            BEGIN
                
                SELECT @cmd1 = @cmd1 + '   SET ' + LOWER(@property collate SQL_Latin1_General_CP1_CS_AS) + ' = ''' + @value + ''''
                SELECT @cmd2 = ' WHERE artid = ' + STR(@artid)
                SELECT @cmd2 = @cmd2 + '   AND pubid = ' + STR(@pubid)
                EXECUTE (@cmd1 + @cmd2)
            END

            IF LOWER(@property collate SQL_Latin1_General_CP1_CS_AS) = 'upd_cmd'
            BEGIN
                IF ( 0 <> ( SELECT PATINDEX( '%[789].[0-9]%', @@version ) ) ) OR
                   ( 0 <> ( SELECT PATINDEX( '%[1-9][0-9].[0-9]%', @@version ) ) )
                BEGIN
                    exec dbo.sp_MSsetfilteredstatus @objid
                END

            END

            IF @@ERROR <> 0 
                BEGIN
                    if @@trancount > 0
                    begin
                        ROLLBACK TRAN sp_changearticle
                        commit tran
                    end
                    RETURN (1)
                END
            END

        IF LOWER(@property collate SQL_Latin1_General_CP1_CS_AS) = 'sync_object'
            BEGIN

                /*
                ** Check for a valid synchronization object.
                */

                IF @value IS NULL
                    BEGIN
                        RAISERROR (14043, 16, -1, '@value')
                        if @@trancount > 0
                        begin
                            ROLLBACK TRAN sp_changearticle
                            commit tran
                        end
                        RETURN (1)
                    END

                IF @value LIKE '%.%.%' OR @value LIKE '%.%'
                BEGIN
                  select @object = PARSENAME( @value, 1 )
                  select @owner = PARSENAME(  @value, 2 )
                  select @db = PARSENAME(  @value, 3 )
                  select @site = PARSENAME(  @value, 4 )

                  if @object IS NULL
                        return 1
                END


                SELECT @sync_objid = OBJECT_ID(@value)
                IF @sync_objid IS NULL
                    BEGIN
                        RAISERROR (15001, 11, -1, @value)
                        if @@trancount > 0
                        begin
                            ROLLBACK TRAN sp_changearticle
                            commit tran
                        end
                        RETURN (1)
                    END

                IF NOT EXISTS (SELECT *
                                 FROM sysobjects
                                WHERE type IN ('U', 'V')
                                  AND id = @sync_objid)

                    BEGIN
                        RAISERROR (14031, 16, -1)
                        if @@trancount > 0
                        begin
                            ROLLBACK TRAN sp_changearticle
                            commit tran
                        end
                        RETURN (1)
                    END

                /*
                ** Update the article with the new synchronization object.
                */

                UPDATE sysarticles
                   SET sync_objid = @sync_objid
                 WHERE artid = @artid
                   AND pubid = @pubid

                IF @@ERROR <> 0 
                BEGIN
                    if @@trancount > 0
                    begin
                        ROLLBACK TRAN sp_changearticle
                        commit tran
                    end
                    RETURN (1)
                END

            END

        IF LOWER(@property collate SQL_Latin1_General_CP1_CS_AS) = 'type'
            BEGIN

                /*
                ** Check to make sure that we have a valid type.
                */

            IF LOWER(@value collate SQL_Latin1_General_CP1_CS_AS) NOT IN ('logbased', 'logbased manualfilter', 'logbased manualview', 'logbased manualboth')
                    BEGIN
                        RAISERROR (14023, 16, -1)
                        if @@trancount > 0
                        begin
                            ROLLBACK TRAN sp_changearticle
                            commit tran
                        end
                        RETURN (1)
                    END

                /*
                ** Determine the integer value for the type.
                */
            IF LOWER(@value collate SQL_Latin1_General_CP1_CS_AS) IN ('logbased', 'indexed view logbased')
            SELECT @typeid = 1
            ELSE IF LOWER(@value collate SQL_Latin1_General_CP1_CS_AS) IN ('logbased manualfilter', 'indexed view logbased manualfilter')
            SELECT @typeid = 3
            ELSE IF LOWER(@value collate SQL_Latin1_General_CP1_CS_AS) IN ('logbased manualview', 'indexed view logbased manualview')
            SELECT @typeid = 5
            ELSE IF LOWER(@value collate SQL_Latin1_General_CP1_CS_AS) IN ('logbased manualboth', 'indexed view logbased manualboth')
            SELECT @typeid = 7

                /*
                ** Update the article with the new type.
                */

                UPDATE sysarticles
                   SET type = @typeid
                 WHERE artid = @artid
                   AND pubid = @pubid

                IF @@ERROR <> 0 
                BEGIN
                    if @@trancount > 0
                    begin   
                        ROLLBACK TRAN sp_changearticle
                        commit tran
                    end
                    RETURN (1)
                END


            END

        IF LOWER(@property collate SQL_Latin1_General_CP1_CS_AS) = 'filter'
            BEGIN

                /*
                ** Check for a valid filter value.
                */

                IF @value IS NOT NULL
                    BEGIN

                        IF @value LIKE '%.%.%' OR @value LIKE '%.%'
                        BEGIN
                           select @object = PARSENAME( @value, 1 )
                           select @owner = PARSENAME(  @value, 2 )
                           select @db = PARSENAME(  @value, 3 )
                           select @site = PARSENAME(  @value, 4 )

                           if @object IS NULL
                                 return 1
                        END

                    END

                SELECT @filter = OBJECT_ID(@value)

                IF @value IS NOT NULL
                    BEGIN

                        IF @filter IS NULL
                            BEGIN
                                RAISERROR (15001, 11, -1, @value)
                                if @@trancount > 0
                                begin
                                    ROLLBACK TRAN sp_changearticle
                                    commit tran
                                end
                                RETURN (1)
                            END

                        IF NOT EXISTS (SELECT *
                                         FROM sysobjects
                                        WHERE type = 'RF'
                                          AND id = @filter)

                            BEGIN
                                RAISERROR (14049, 16, -1)
                                if @@trancount > 0
                                begin
                                    ROLLBACK TRAN sp_changearticle
                                    commit tran
                                end
                                RETURN (1)
                            END

                    END

                IF @value IS NULL SELECT @filter = 0

                -----------------------------
                -- save off the old filter
                -----------------------------

                SELECT @old_filter_name = object_name( filter )
                FROM sysarticles WHERE artid = @artid
                AND pubid = @pubid

                IF @@ERROR <> 0 
                BEGIN
                    if @@trancount > 0
                    begin
                        ROLLBACK TRAN sp_changearticle
                        commit tran
                    end
                    RETURN (1)
                END

                --------------------------------------------
                -- Update the article with the new filter.
                --------------------------------------------

                UPDATE sysarticles
                   SET filter = @filter
                 WHERE artid = @artid
                   AND pubid = @pubid

                IF @@ERROR <> 0 
                BEGIN
                    if @@trancount > 0
                    begin
                        ROLLBACK TRAN sp_changearticle
                        commit tran
                    end
                    RETURN (1)
                END

                -- SQL SERVER > 7.x ONLY  disassociate old filter with table
                -- and associate new one

                IF ( 0 <> ( SELECT PATINDEX( '%[789].[0-9]%', @@version ) ) ) OR
                   ( 0 <> ( SELECT PATINDEX( '%[1-9][0-9].[0-9]%', @@version ) ) )   
                BEGIN

                    ------------------------------------------
                    -- disassociate table from old filter proc
                    ------------------------------------------

                    EXEC dbo.sp_MSsetfilterparent @old_filter_name, 0

                    IF @@ERROR <> 0
                    BEGIN
                        if @@trancount > 0
                        begin
                            ROLLBACK TRAN sp_changearticle
                            commit tran
                        end
                        RETURN (1)
                    END

                    ------------------------------------------------------
                    -- set the parent of the filter proc to this object_id
                    ------------------------------------------------------

                    EXEC dbo.sp_MSsetfilterparent @value, @objid

                    IF @@ERROR <> 0
                    BEGIN
                        if @@trancount > 0
                        begin
                            ROLLBACK TRAN sp_changearticle
                            commit tran
                        end
                        RETURN (1)
                    END
                END

            END

        IF LOWER(@property collate SQL_Latin1_General_CP1_CS_AS) = 'pre_creation_cmd'
            BEGIN

                /*
                ** Check to make sure that we have a valid pre_creation_cmd.
                */
            IF @objtype = 'P' and LOWER(@value collate SQL_Latin1_General_CP1_CS_AS) NOT IN ('none', 'drop')
                BEGIN
                    RAISERROR ( 14111, 16, -1 )
                    if @@trancount > 0
                    begin   
                        ROLLBACK TRAN sp_changearticle
                        commit tran
                    end
                    RETURN (1)
                END

                IF LOWER(@value collate SQL_Latin1_General_CP1_CS_AS) NOT IN ('none', 'drop', 'delete', 'truncate')
                    BEGIN
                        RAISERROR (14061, 16, -1)
                        if @@trancount > 0
                        begin
                            ROLLBACK TRAN sp_changearticle
                            commit tran
                        end
                        RETURN (1)
                    END

                /*
                ** Determine the integer value for the type.
                */

                IF LOWER(@value collate SQL_Latin1_General_CP1_CS_AS) = 'none'
                    SELECT @precmdid = 0
                ELSE IF LOWER(@value collate SQL_Latin1_General_CP1_CS_AS) = 'drop'
                    SELECT @precmdid = 1
                ELSE IF LOWER(@value collate SQL_Latin1_General_CP1_CS_AS) = 'delete'
                    SELECT @precmdid = 2
                ELSE IF LOWER(@value collate SQL_Latin1_General_CP1_CS_AS) = 'truncate'
                    SELECT @precmdid = 3

                /*
                ** Update the article with the new pre_creation_cmd.
                */
                UPDATE sysarticles
                   SET pre_creation_cmd = @precmdid
                 WHERE artid = @artid
                   AND pubid = @pubid

                IF @@ERROR <> 0 
                    BEGIN
                        if @@trancount > 0
                        begin
                            ROLLBACK TRAN sp_changearticle
                            commit tran
                        end
                        RETURN (1)
                    END

            END

        IF LOWER(@property collate SQL_Latin1_General_CP1_CS_AS) = 'status'
            BEGIN
                /*
                ** Determine the integer value for the type.
                */
                IF LOWER(@value collate SQL_Latin1_General_CP1_CS_AS) = 'not owner qualified'
                    UPDATE sysarticles 
                    SET status = status & ~4
                    WHERE artid = @artid
                                  AND pubid = @pubid

                ELSE IF LOWER(@value collate SQL_Latin1_General_CP1_CS_AS) = 'owner qualified'
                    UPDATE sysarticles 
                    SET status = status | 4
                    WHERE artid = @artid
                                  AND pubid = @pubid
                     
                ELSE IF LOWER(@value collate SQL_Latin1_General_CP1_CS_AS) = 'no column names'
                    UPDATE sysarticles 
                    SET status = status & ~8
                    WHERE artid = @artid
                                  AND pubid = @pubid
                     
                ELSE IF LOWER(@value collate SQL_Latin1_General_CP1_CS_AS) = 'include column names'
                    UPDATE sysarticles 
                    SET status = status | 8
                    WHERE artid = @artid
                                  AND pubid = @pubid

                ELSE IF LOWER(@value collate SQL_Latin1_General_CP1_CS_AS) = 'string literals'
                    UPDATE sysarticles 
                    SET status = status & ~16
                    WHERE artid = @artid
                                  AND pubid = @pubid
                     
                ELSE IF LOWER(@value collate SQL_Latin1_General_CP1_CS_AS) = 'parameters'
                    UPDATE sysarticles 
                    SET status = status | 16
                    WHERE artid = @artid
                                  AND pubid = @pubid
                ELSE IF LOWER(@value collate SQL_Latin1_General_CP1_CS_AS) = @dts_part
				begin
					if exists (select * from sysarticles where
						artid = @artid and
						status & 64 = 0)
					begin
						UPDATE sysarticles 
							SET status = status | 64,
								upd_cmd = N'XCALL sp_MSXpd_' + @article
							WHERE artid = @artid
					end
				end
                ELSE IF LOWER(@value collate SQL_Latin1_General_CP1_CS_AS) = @no_dts_part
				begin
					if exists (select * from sysarticles where
						artid = @artid and
						status & 64 <> 0)
					begin
						UPDATE sysarticles 
							SET status = status & ~64,
								upd_cmd = N'CALL sp_MSupd_' + @article
							WHERE artid = @artid
					end
                end
                IF @@ERROR <> 0 
                    BEGIN
                        if @@trancount > 0
                        begin
                            ROLLBACK TRAN sp_changearticle
                            commit tran
                        end
                        RETURN (1)
                    END
            END

        IF LOWER(@property collate SQL_Latin1_General_CP1_CS_AS) = 'schema_option'
            BEGIN
                IF @value IS NULL
                    BEGIN
                        RAISERROR(14146, 16,1)
                        if @@trancount > 0
                        begin
                            ROLLBACK TRAN sp_changearticle
                            commit tran
                        end
                        RETURN (1)
                    END

                CREATE TABLE #tab_changearticle (value varbinary(8) NULL)
                                     
                IF @@ERROR <> 0 
                    BEGIN
                        if @@trancount > 0
                        begin
                            ROLLBACK TRAN sp_changearticle
                            commit tran
                        end
                        RETURN (1)
                    END

                EXEC ('insert #tab_changearticle values (' + 
                        @value +')' )
                                     
                IF @@ERROR <> 0 
                    BEGIN
                        if @@trancount > 0
                        begin
                            ROLLBACK TRAN sp_changearticle
                            commit tran
                        end
                        RETURN (1)
                    END
                
                IF @objtype = 'P' AND EXISTS (SELECT * from #tab_changearticle 
                    WHERE value <> 0x0000000000000000 AND
                          value <> 0x0000000000000001 )
                    BEGIN
                        RAISERROR ( 20014, 16, -1 )
                        if @@trancount > 0
                        begin
                            ROLLBACK TRAN sp_changearticle
                            commit tran
                        end
                        RETURN (1)
                    END

				--
				-- For queued updating publications
				-- DRI option has to be included
				--
				if ((@allow_queued_tran = 1) and 
					exists (select * from #tab_changearticle where 
						fn_replgetbinary8lodword(fn_replprepadbinary8(value)) & 0x8000 = 0))
				BEGIN
					RAISERROR (21394, 16, 2)
					if @@trancount > 0
					begin
						ROLLBACK TRAN sp_changearticle
						commit tran
					end
					RETURN (1)
				END

                -- Seems to be a good place to check and see if using 
                -- collation 0x00001000 or extended property 0x00002000
	            declare @schema_option_int int
	            select @schema_option_int  = 
                    fn_replgetbinary8lodword(fn_replprepadbinary8(value)) 
                from #tab_changearticle
	            if ((@schema_option_int & 0x000001000 <> 0) or 
                    (@schema_option_int & 0x000002000 <> 0))
		        select @backward_comp_level = 40
                -- End 
               
                UPDATE sysarticles 
                   SET schema_option = fn_replprepadbinary8(tab.value) 
                  FROM #tab_changearticle tab 
                 WHERE artid = @artid
                   AND pubid = @pubid
                DROP TABLE #tab_changearticle 
                                     
                IF @@ERROR <> 0 
                    BEGIN
                        if @@trancount > 0
                        begin
                            ROLLBACK TRAN sp_changearticle
                            commit tran
                        end
                        RETURN (1)
                    END

            END

        IF LOWER(@property collate SQL_Latin1_General_CP1_CS_AS) = 'destination_owner'
            BEGIN
                IF @value IS NOT NULL
                BEGIN
                    EXECUTE @retcode = dbo.sp_validname @value

                    IF @retcode <> 0
                    BEGIN
                        if @@trancount > 0
                        begin
                            ROLLBACK TRAN sp_changearticle
                            commit tran
                        end
                        RETURN (1)
                    END
                END

                UPDATE sysarticles SET dest_owner = @value from 
                    sysarticles WHERE artid = @artid
                                  AND pubid = @pubid
                                     
                IF @@ERROR <> 0 
                    BEGIN
                        if @@trancount > 0
                        begin
                            ROLLBACK TRAN sp_changearticle
                            commit tran
                        end
                        RETURN (1)
                    END

            END

	       
	    if  LOWER(@property collate SQL_Latin1_General_CP1_CS_AS) = 'pub_identity_range'
        begin
            if not exists (select * from sysarticleupdates where artid = @artid and
                identity_support = 1)
            begin
                raiserror(21235, 16, -1, @property)
                goto UNDO
            end

            declare @pub_range bigint
            select @pub_range = convert(bigint, @value) 
            if @pub_range < 0
            begin
                raiserror(21232, 16, -1)
                goto UNDO
            end

            if exists (select * from MSpub_identity_range where objid = @objid and
                pub_range < 0)
                select @pub_range = @pub_range * -1
			
            update MSpub_identity_range set
                pub_range = @pub_range 
                where objid=@objid
            if @@error < 0
                goto UNDO
        end
                
	    if  LOWER(@property collate SQL_Latin1_General_CP1_CS_AS) = 'identity_range'
        begin
            if not exists (select * from sysarticleupdates where artid = @artid and
                identity_support = 1)
            begin
                raiserror(21235, 16, -1, @property)
                goto UNDO
            end

            declare @range bigint
            select @range = convert(bigint, @value) 
            if @range < 0
            begin
                raiserror(21232, 16, -1)
                goto UNDO
            end

            if exists (select * from MSpub_identity_range where objid = @objid and
                range < 0)
                select @range = @range * -1
			
            update MSpub_identity_range set
                range = @range 
                where objid=@objid
            if @@error < 0
                goto UNDO

            -- Distributor side data will be changed later by sp_MSchange_article.
        end

		-- Check to see if the range is too big.
		-- Must be down after the change. If the check fails, the transaction
		-- will be rolled back.
		if  LOWER(@property collate SQL_Latin1_General_CP1_CS_AS) in ('pub_identity_range', 'identity_range')
		begin
			declare @pub_identity_range bigint, @identity_range int
			select @pub_identity_range = pub_range, 
				@identity_range = range from MSpub_identity_range where
				objid = @objid 

			declare @xtype int, @xprec int, @max_range bigint
			select @xtype=xtype, @xprec=xprec from syscolumns where id=@objid and 
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
		
			declare @source_table nvarchar (386)
			exec @retcode = dbo.sp_MSget_qualified_name @objid, @source_table output
			if @retcode <> 0 or @@error <> 0
				goto UNDO
			if @pub_identity_range * 2 + @identity_range > (@max_range - IDENT_CURRENT(@source_table))
				begin
					raiserror(21290, 16, -1)
					goto UNDO
				end
		end

        if  LOWER(@property collate SQL_Latin1_General_CP1_CS_AS) = 'threshold'
        begin
            if not exists (select * from sysarticleupdates where artid = @artid and
                identity_support = 1)
            begin
                raiserror(21235, 16, -1, @property)
                goto UNDO
            end

            declare @threshold bigint
            select @threshold = convert(int, @value) 
            if @threshold < 1 or @threshold > 100
            begin
                raiserror(21233, 16, -1)
                goto UNDO
            end

            update MSpub_identity_range set
                threshold = @threshold
                where objid=@objid
            if @@error < 0
                goto UNDO
            -- Distributor side data will be changed later by sp_MSchange_article.
        end

		-------------------------------------------------------------------------
		-- some info on articles is also stored at the distributor.
		-- update info at distributor if these properties change
		-------------------------------------------------------------------------

		if LOWER(@property collate SQL_Latin1_General_CP1_CS_AS) in ( N'description', N'dest_table', N'dest_object', 
            'identity_range', 'threshold' )
		BEGIN
			/*
			** Get distribution server information for remote RPC call.
			*/
			EXECUTE @retcode = dbo.sp_helpdistributor @rpcsrvname = @distributor OUTPUT,
			   @distribdb   = @distribdb OUTPUT
			IF @@ERROR <> 0 or @retcode <> 0
			BEGIN
				RAISERROR (14071, 16, -1)
				if @@trancount > 0
				begin
					ROLLBACK TRAN sp_changearticle
					commit tran
				end
				RETURN (1)
			END

			SELECT @dbname =  DB_NAME()

			SELECT @distproc = RTRIM(@distributor) + '.' + @distribdb + 
				'.dbo.sp_MSchange_article'
			EXECUTE @retcode = @distproc
				@publisher = @@SERVERNAME,
				@publisher_db = @dbname,
				@publication = @publication,
				@article = @article,
				@article_id = @artid,
				@property = @property,
				@value = @value


			IF @@ERROR <> 0 OR @retcode <> 0
			BEGIN
				if @@trancount > 0
				begin
					ROLLBACK TRAN sp_changearticle
					commit tran
				end
				RETURN (1)
			END
		END

		-- Have to call this stored procedure to invalidate existing snapshot or reint
		-- subscriptions if needed
		EXECUTE @retcode  = dbo.sp_MSreinit_article
			@publication = @publication, 
			@article = @article,
			@need_new_snapshot = @need_new_snapshot,
			@need_reinit_subscription = @need_reinit_subscription
			,@force_invalidate_snapshot = @force_invalidate_snapshot	/* Force invalidate existing snapshot */
			,@force_reinit_subscription = @force_reinit_subscription	/* Force reinit subscription */
		IF @@ERROR <> 0 OR @retcode <> 0
			GOTO UNDO


if @backward_comp_level > 10
	update syspublications set backward_comp_level = @backward_comp_level where pubid = @pubid
    COMMIT TRAN

    /*
    ** Force the article cache to be refreshed with the new definition.
    */
    EXECUTE dbo.sp_replflush

    /*
    ** Return succeed.
    */

    RAISERROR (14025, 10, -1)
    RETURN (0)

UNDO:
    if @@TRANCOUNT > 0
    begin
        ROLLBACK TRAN sp_changearticle
        COMMIT TRAN
    end
    return(1)
END
go
 
dump tran master with no_log
go

EXEC dbo.sp_MS_marksystemobject sp_changearticle
GO

print ''
print 'Creating procedure sp_droparticle'
go

CREATE PROCEDURE sp_droparticle(
	@publication sysname,     /* The publication name */
	@article sysname,          /* The article name */
	@ignore_distributor bit = 0,	
	@force_invalidate_snapshot bit = 0	/* Force invalidate existing snapshot */

) 
AS
BEGIN
    /*
    ** Declarations.
    */

    DECLARE @cmd nvarchar(255)
    DECLARE @objid int
    DECLARE @pubid int
    DECLARE @publish_bit smallint
    DECLARE @retcode int
    DECLARE @filter_name sysname
    DECLARE @view_name sysname
    DECLARE @type tinyint
    DECLARE @procnum smallint
    DECLARE @virtual_id smallint
    DECLARE @push tinyint
    DECLARE @distributor sysname
    DECLARE @distribdb sysname
    DECLARE @distproc nvarchar (255)
    DECLARE @dbname sysname
    -- SyncTran
    DECLARE @allow_sync_tran_id bit
    DECLARE @allow_queued_tran_id bit
    declare @artid int, @insproc_id int, @updproc_id int, @delproc_id int, @updtrig_id int
    declare @filter_id int
    declare @view_id int
	declare @tran_conflict_tabid int
	declare @tran_conflict_procid int

    SET NOCOUNT ON

    /*
    ** Initializations.
    */

    SELECT @virtual_id = -1     /* Const: virtual subscriber id */
    SELECT @publish_bit = 1


    /*
    ** Security Check.
    */
    exec @retcode = dbo.sp_MSreplcheck_publish
    if @@ERROR <> 0 or @retcode <> 0
        return(1)

    /*
    ** Parameter Check: @publication.
    ** The @publication name must conform to the rules for identifiers.
    */

    IF @publication IS NULL
        BEGIN
            RAISERROR (14043, 16, -1, '@publication')
            RETURN (1)
        END

    EXECUTE @retcode = dbo.sp_validname @publication

    IF @retcode <> 0
    RETURN (1)

    IF NOT EXISTS (SELECT * FROM syspublications WHERE name = @publication)
        BEGIN
            RAISERROR (20026, 11, -1, @publication)
            RETURN (1)
        END


    /*
    ** Get the @pubid.
    */

    -- SyncTran
    --SELECT @pubid = pubid FROM syspublications WHERE name = @publication
    SELECT @pubid = pubid, @allow_sync_tran_id = allow_sync_tran,
		@allow_queued_tran_id = allow_queued_tran
    FROM syspublications WHERE name = @publication

    /*
    ** Parameter Check:  @article.
    ** If the @article is 'all', drop all articles for the specified
    ** publication (@publication).
    */

    IF LOWER(@article) = 'all'
        BEGIN
			-- If drop all articles, set force flag to true
			select @force_invalidate_snapshot = 1
            DECLARE hC  CURSOR LOCAL FAST_FORWARD FOR 
                SELECT DISTINCT  name FROM sysextendedarticlesview 
                    WHERE pubid = @pubid
            OPEN hC
            FETCH hC INTO @article
            WHILE (@@fetch_status <> -1)
                BEGIN
                    EXECUTE dbo.sp_droparticle 
                        @publication = @publication, 
                        @article = @article,
                        @ignore_distributor = @ignore_distributor,
						@force_invalidate_snapshot = @force_invalidate_snapshot

                    FETCH hC INTO @article
                END
            CLOSE hC
            DEALLOCATE hC
            RETURN (0)
        END

    /*
    ** Parameter Check: @article.
    ** The @article name must conform to the rules for identifiers.
    */

    IF @article IS NULL
        BEGIN
            RAISERROR (14043, 16, -1, '@article')
            RETURN (1)
        END

    /*
    EXECUTE @retcode = dbo.sp_validname @article

    IF @retcode <> 0
    RETURN (1)
    */

    /*
    ** Ascertain the existence of the article.
    */

    IF NOT EXISTS (SELECT *
                     FROM sysextendedarticlesview
                    WHERE name = @article
                      AND pubid = @pubid)
        BEGIN
            RAISERROR (20027, 11, -1, @article)
        RETURN (1)
        END

    /*
    ** Check to make sure that there are no 'real' subscriptions on the article.
    */

    IF EXISTS (SELECT *
                 FROM syssubscriptions, sysextendedarticlesview
                WHERE sysextendedarticlesview.name = @article
                  AND sysextendedarticlesview.pubid = @pubid
                  AND sysextendedarticlesview.artid = syssubscriptions.artid
                  AND syssubscriptions.srvid <> @virtual_id)
        BEGIN
            RAISERROR (14046, 16, -1)
            RETURN (1)
        END

    -- 
    -- If SyncTran/QueuedTran enabled
    -- retrieve info from sysarticle updates
    --
    if (@allow_sync_tran_id = 1 or @allow_queued_tran_id = 1)
    begin
        select @artid = artid from sysarticles where name = @article and pubid = @pubid
        select @insproc_id = sync_ins_proc, @updproc_id = sync_upd_proc, @delproc_id = sync_del_proc,
			@updtrig_id = sync_upd_trig,
			@tran_conflict_tabid = conflict_tableid,
			@tran_conflict_procid = ins_conflict_proc
        from sysarticleupdates
        where artid = @artid and pubid = @pubid 
    end
    -- end SyncTran

    /*
    ** Retrieve the object id of the underlying object,
    ** article id, and article type. Note that the 
    ** subsequent code relies on the values of the variables in
    ** the select list. Please do not remove any variable from 
    ** the seletc list unless you make sure that all the subsequent
    ** references to the variable are accounted for.  
    */
 
    SELECT @artid = artid, @objid = objid, @type = type
      FROM sysextendedarticlesview
     WHERE name = @article
       AND pubid = @pubid

    begin tran
    save TRAN droparticle

		-- @ignore_distributor is set to 1 when removing replication forcefully. In that
		-- case, no need to check or reinit
		if @ignore_distributor = 0
		begin
			-- Have to call this stored procedure to invalidate existing snapshot
			-- if there are any. immediate_sync_ready bit would be changed or error will be railsed.
			EXECUTE @retcode  = dbo.sp_MSreinit_article
				@publication = @publication, 
				@need_new_snapshot = 1,
				@force_invalidate_snapshot = @force_invalidate_snapshot
			IF @@ERROR <> 0 OR @retcode <> 0
				GOTO UNDO
		end

        /* Drop virtual subscription first for @immediate_sync publications
         */
        if EXISTS (SELECT * FROM syspublications WHERE
            name = @publication    AND
            immediate_sync = 1)
        BEGIN
            EXECUTE @retcode  = dbo.sp_dropsubscription 
                @publication = @publication, 
                @article = @article,
                @subscriber = NULL,
                @ignore_distributor = @ignore_distributor,
                @reserved = 'internal'
            IF @@ERROR <> 0 OR @retcode <> 0
            BEGIN
                if @@trancount > 0
                begin
                    ROLLBACK TRAN droparticle
                    commit tran
                end
                RETURN (1)
            END
        END

        /* Drop article at the distributor side */
        /*
        ** if @ignore_distributor = 1, we are in bruteforce cleanup mode, don't do RPC.
        */
        if @ignore_distributor = 0
        begin

            /*
            ** Get distribution server information for remote RPC call.
            */
            EXECUTE @retcode = dbo.sp_helpdistributor @rpcsrvname = @distributor OUTPUT,
               @distribdb   = @distribdb OUTPUT
            IF @@ERROR <> 0 or @retcode <> 0
                BEGIN
                    RETURN (1)
                END

            SELECT @dbname =  DB_NAME()
        
            SELECT @distproc = RTRIM(@distributor) + '.' + @distribdb + 
                '.dbo.sp_MSdrop_article'
            EXECUTE @retcode = @distproc
                @publisher = @@SERVERNAME,
                @publisher_db = @dbname,
                @publication = @publication,
                @article = @article

            IF @@ERROR <> 0 OR @retcode <> 0
            BEGIN
                if @@trancount > 0
                    ROLLBACK TRAN 
                RETURN (1)
            END
        end

        IF @type IN (0x20, 0x40, 0x80)
        BEGIN
            -- Handle the schema only articles a little bit differently from 
            -- other articles as they are simpler objects. 

            -- Note that we have already obtained the article id earlier 
            -- so we can use that to delete the corresponding record
            -- in sysschemaarticles
            
            DELETE sysschemaarticles WHERE artid = @artid and pubid = @pubid

            -- If the object is no longer published as an schema only
            -- article, unmark its published for schema only bit (512) in 
            -- sysobjects/replinfo so that it can be dropped by the user.
            -- Note that we need to check sysmergeschemaarticles too.


            -- Note that we have obtained the object id for the undelying 
            -- object of this article already.

            IF NOT EXISTS (SELECT * 
                             FROM sysschemaarticles 
                            WHERE objid = @objid)
            BEGIN
                SELECT @publish_bit = 512
                IF NOT EXISTS (SELECT * 
                                 FROM sysobjects 
                                WHERE name = 'sysmergeschemaarticles')
                BEGIN
                    UPDATE sysobjects 
                       SET replinfo = replinfo & ~@publish_bit
                    WHERE id = @objid 
                END
                ELSE IF NOT EXISTS (SELECT * 
                                      FROM sysmergeschemaarticles
                                     WHERE objid = @objid)
                BEGIN
                    UPDATE sysobjects 
                       SET replinfo = replinfo & ~@publish_bit
                    WHERE id = @objid 
                END
            END  
        END
        ELSE
        BEGIN
        
            /*
            **  Delete article from sysarticles and clear publish bit in
            **  sysobjects.
            */


            /*
            ** If this article is the only one that references this object,
            ** then we can safely turn off the publish bit in sysobjects.
            */

            IF NOT EXISTS (SELECT *
                             FROM sysarticles
                            WHERE objid = @objid
                              AND NOT (name = @article AND pubid = @pubid))
                BEGIN

                UPDATE sysobjects SET replinfo = replinfo & ~ @publish_bit 
                    WHERE id = (SELECT objid FROM sysarticles WHERE name = @article 
                        AND pubid =  @pubid) 

			    /*
                EXEC (@cmd)

                IF @@ERROR <> 0
                    BEGIN
                        if @@trancount > 0
                            ROLLBACK TRAN
                        RAISERROR (14047, 16, -1, @article)
                        RETURN (1)
                    END
			    */

                END

            /*
            ** Drop article view if not logbased manualview (type = 5)
            */
            IF (@type & 5) = 1
            BEGIN    
                SELECT @view_id = sysobjects.id
                  FROM sysarticles, sysobjects
                 WHERE sysarticles.name = @article
                   AND pubid = @pubid
                   AND sync_objid = sysobjects.id
                   AND sysobjects.type = 'V'
                exec sp_MSget_qualified_name @view_id, @view_name OUTPUT

            END

            /*
            ** Drop article filter if not logbased manualfilter (type = 3)
            */
            IF (@type & 3) = 1
            BEGIN    
                SELECT @filter_id = sysobjects.id
                  FROM sysarticles, sysobjects
                 WHERE sysarticles.name = @article
                   AND pubid = @pubid
                   AND filter = sysobjects.id
                   AND sysobjects.type = 'RF'

                exec sp_MSget_qualified_name @filter_id, @filter_name OUTPUT
       
            END


            IF( @type & 3 ) = 3
            BEGIN
                select @filter_id =  filter from sysarticles
                where name = @article and pubid = @pubid

                exec sp_MSget_qualified_name @filter_id, @filter_name OUTPUT

                if @filter_name is not null
                    EXEC dbo.sp_MSsetfilterparent @filter_name, 0
            
                -- Clear base table dependency on the filter
                EXEC dbo.sp_MSsetfilteredstatus @objid

                -- This is a manual filter, we should not drop it automatically
                -- since it is not created by us.
                -- Set @filter_id to null so the object will not be dropped later.
                select @filter_name = null
 
            END


            /*
            ** If this is a table based article, Drop all article columns.
            ** This is done to force all Text\Image column status to be updated.
            */

            IF (@type & 8) != 8
            BEGIN

	            -- propagate @ignore_distributor to sp_articlecolumn to allow forced cleanup
                EXECUTE @retcode  = dbo.sp_articlecolumn @publication, @article,
                @operation = 'drop', @ignore_distributor = @ignore_distributor
                -- synctran
                , @refresh_synctran_procs = 0
				, @force_invalidate_snapshot = @force_invalidate_snapshot
                IF @@ERROR <> 0 OR @retcode <> 0
                BEGIN
                    if @@trancount > 0
                    begin
                        ROLLBACK TRAN droparticle
                        commit tran
                    end
                    RETURN (1)
                END
            END


            /*
            ** Remove the row from sysarticles.
            */
            DELETE
              FROM sysarticles
             WHERE name = @article
               AND pubid = @pubid

            IF @@ERROR <> 0
            BEGIN
                if @@trancount > 0
                    ROLLBACK TRAN 
                RAISERROR (14047, 16, -1, @article)
                RETURN (1)
            END

            -- SyncTran
            /*
            ** Drop associated sync tran procs and entries in sysarticle updates
            */
            if (@allow_sync_tran_id = 1 or @allow_queued_tran_id = 1)
            begin
                exec @retcode = dbo.sp_MSdrop_object 
                    @object_id = @insproc_id
                if @retcode <> 0 or @@error <> 0
                    goto UNDO

                exec @retcode = dbo.sp_MSdrop_object 
                    @object_id = @updproc_id
                if @retcode <> 0 or @@error <> 0
                    goto UNDO

                exec @retcode = dbo.sp_MSdrop_object 
                    @object_id = @delproc_id
                if @retcode <> 0 or @@error <> 0
                    goto UNDO
            
			    if @updtrig_id is not null
			    begin
				    exec @retcode = dbo.sp_MSdrop_object 
					    @object_id = @updtrig_id
				    if @retcode <> 0 or @@error <> 0
					    goto UNDO
                end

			    -- drop conflict tables as necessary
			    if @tran_conflict_tabid is not null
			    begin
				    exec @retcode = dbo.sp_MSdrop_object 
					    @object_id = @tran_conflict_tabid
				    if @retcode <> 0 or @@error <> 0
					    goto UNDO
                end

			    if @tran_conflict_procid is not null
			    begin
				    exec @retcode = dbo.sp_MSdrop_object 
					    @object_id = @tran_conflict_procid
				    if @retcode <> 0 or @@error <> 0
					    goto UNDO
                end

                delete from sysarticleupdates where artid = @artid and pubid = @pubid
                if @@ERROR <> 0 
                begin
                    if @@trancount > 0
                        ROLLBACK TRAN
                    RETURN (1)

                end

			    -- Cleanup MSpub_identity_range if needed.
			    if not exists (select * from sysarticles where objid = @objid)
			    begin
					if exists (select * from MSpub_identity_range where objid = @objid)
					begin
						-- Drop the identity range constraits.
						-- RESEED and change constraint
						exec @retcode = dbo.sp_MSreseed
							@objid =  @objid,
							-- next_seed and range can be anything.
							@next_seed = 10,
							@range = 10,
							@is_publisher = -1,
							@check_only = 1,
							@drop_only = 1
						IF @retcode <> 0 or @@ERROR <> 0 
							GOTO UNDO

						delete MSpub_identity_range where objid = @objid
						if @@ERROR <> 0 
							GOTO UNDO
				    end
			    end
            -- end SyncTran
            end
	end
    COMMIT TRAN

    IF @view_name IS NOT NULL
	BEGIN
        -- @view_name is already quoted.
		SELECT @cmd = 'drop view ' + @view_name
		exec (@cmd)
	END

    IF @filter_name IS NOT NULL
	BEGIN
        -- @filter_name is already quoted.
		SELECT @cmd = 'drop proc ' + @filter_name
		exec (@cmd)
	END
    /*
    ** Force the article cache to be refreshed; only if needed
    */
	if ( @ignore_distributor = 0 )
		EXECUTE dbo.sp_replflush

    return (0)

UNDO:

	if @@trancount > 0
    begin
        ROLLBACK TRANSACTION droparticle
        commit tran
    end
    RETURN (1)
END
go
 
EXEC dbo.sp_MS_marksystemobject sp_droparticle
GO

print ''
print 'Creating procedure sp_droppublication'
go

CREATE PROCEDURE sp_droppublication(
        @publication sysname,       /* The publication name */
        @ignore_distributor bit = 0
        ) AS

    /*
    ** Declarations.
    */

    DECLARE @article sysname
    DECLARE @cmd nvarchar(255)
    DECLARE @retcode int
    DECLARE @distributor sysname
    DECLARE @distribdb sysname
    DECLARE @distproc nvarchar (255)
    DECLARE @agentname nvarchar (40)
    DECLARE @dbname sysname
    DECLARE @virtual_id smallint
	DECLARE @ad_guidname sysname
    DECLARE @alt_snapshot_folder nvarchar(255)
    DECLARE @pub_alt_snapshot_folder nvarchar(255)
	
    SELECT @virtual_id = -1
    select @dbname = db_name()
	select @ad_guidname = NULL
    /*
    ** Security check
    */
    exec @retcode = dbo.sp_MSreplcheck_publish
    if @@ERROR <> 0 or @retcode <> 0
        return(1)

    /*
    ** Parameter Check:  @publication.
    ** If the @publication is 'all', drop all publications.  Otherwise,
    ** make sure the @publication is a valid non-null identifier.
    ** Delete the logreader agent after all the publications have been 
    ** removed.
    */

    IF LOWER(@publication) = 'all'
        BEGIN
            DECLARE hC1  CURSOR LOCAL FAST_FORWARD FOR 
                SELECT DISTINCT name FROM syspublications 
                    WHERE pubid NOT IN 
                        (SELECT pubid FROM sysextendedarticlesview WHERE artid IN 
                            (SELECT artid FROM syssubscriptions WHERE srvid <> @virtual_id))
            OPEN hC1
            FETCH hC1 INTO @publication
            WHILE (@@fetch_status <> -1)
                BEGIN
                    EXECUTE dbo.sp_droppublication @publication,
                        @ignore_distributor = @ignore_distributor
                    FETCH hC1 INTO @publication
                END
            CLOSE hC1
            DEALLOCATE hC1
            RETURN (0)
        END

    IF @publication IS NULL
        BEGIN
            RAISERROR (14003, 16, -1)
            RETURN (1)
        END

    EXECUTE @retcode = dbo.sp_validname @publication

    IF @retcode <> 0
    RETURN (1)

    /*
    ** Ascertain the existence of the publication and get the taskid.
    */
    IF NOT EXISTS (SELECT *
                     FROM syspublications
                    WHERE name = @publication)
    BEGIN
        RAISERROR (20026, 11, -1, @publication)
        RETURN (1)
    END

    /*
    ** Check to make sure that there are no subscriptions on the publication.
    */

    IF EXISTS (SELECT *
                 FROM syssubscriptions a, sysextendedarticlesview b, syspublications c
                WHERE c.name = @publication
                  AND c.pubid = b.pubid
                  AND b.artid = a.artid
                  AND a.srvid <>@virtual_id)
        BEGIN
            RAISERROR (14005, 16, -1)
            RETURN (1)
        END

    /*
    ** Delete all articles from the publication.
    */

    EXECUTE dbo.sp_droparticle @publication = @publication, 
        @article = N'all',
        @ignore_distributor = @ignore_distributor
		, @force_invalidate_snapshot = 1
    IF @@ERROR <> 0 OR  @retcode <> 0
		RETURN (1)

	select @ad_guidname = ad_guidname,
           @alt_snapshot_folder = alt_snapshot_folder 
      from syspublications 
     where name=@publication

    BEGIN TRAN

    /*
    ** Delete publication from syspublications.
    */

    DELETE FROM syspublications WHERE name = @publication

    IF @@ERROR <> 0
        GOTO UNDO

    /*
    ** if @ignore_distributor = 1, we are in bruteforce cleanup mode, don't do RPC.
    */
    if @ignore_distributor = 0
    begin

        /*
        ** Get distribution server information for remote RPC call.
        */

        EXEC @retcode = dbo.sp_helpdistributor @rpcsrvname = @distributor OUTPUT,
                                           @distribdb = @distribdb OUTPUT

        IF @@ERROR <> 0 OR  @retcode <> 0
            BEGIN
                RAISERROR (14071, 16, -1)
                RETURN (1)
            END

        /*
        ** Delete sync agent of Publication if it exists.
        */
        SELECT @distproc = RTRIM(@distributor) + '.' + @distribdb + '.dbo.sp_MSdrop_snapshot_agent'
        EXECUTE @retcode = @distproc 
            @publisher = @@SERVERNAME,
            @publisher_db = @dbname,
            @publication = @publication

        IF @@ERROR <> 0 or @retcode <> 0
            GOTO UNDO

        IF NOT EXISTS (SELECT * FROM syspublications  where repl_freq = 0)
            BEGIN
                /*
                ** Delete logreader agent, continue if drop is not successful
                */
                SELECT @distproc = RTRIM(@distributor) + '.' + @distribdb + '.dbo.sp_MSdrop_logreader_agent'
                EXECUTE @retcode = @distproc @publisher = @@SERVERNAME,
                    @publisher_db = @dbname,
                    -- 'ALL' is used in sp_addpublication.
                    @publication = 'ALL'
                IF @@ERROR <> 0 or @retcode <> 0
                    GOTO UNDO
            END

        /*
        ** Delete the publication at the distribution server
        */
        SELECT @distproc = RTRIM(@distributor) + '.' + @distribdb + 
            '.dbo.sp_MSdrop_publication'
        EXECUTE @retcode = @distproc
            @publisher = @@SERVERNAME,
            @publisher_db = @dbname,
            @publication = @publication
        IF @@ERROR <> 0 or @retcode <> 0
            GOTO UNDO
        
        /*
        ** If alternate snapshot folder is specified for this publication,
        ** try to remove the publication's snapshot folder underneath the
        ** the alternate snapshot location in Distributor's context
        */
        if @alt_snapshot_folder is not null and
           @alt_snapshot_folder <> N''
        begin

            /* Append publication specific folder name */
            if substring(@alt_snapshot_folder,len(@alt_snapshot_folder),1)<>
                N'\'
            begin
                select @alt_snapshot_folder = @alt_snapshot_folder + N'\'
            end 

            -- UNC version
            select @pub_alt_snapshot_folder = @alt_snapshot_folder + N'unc\' + fn_replcomposepublicationsnapshotfolder(@@servername,db_name(),@publication) collate database_default
            select @distproc = fn_replquotename(RTRIM(@distributor)) collate database_default + N'.'  + fn_replquotename(@distribdb) collate database_default + 
                N'.dbo.sp_MSreplremoveuncdir'
            -- Ignore errors as the snapshot folder may not exist at all
            EXECUTE @distproc
                @dir = @pub_alt_snapshot_folder

            -- FTP-enabled version
            select @pub_alt_snapshot_folder = @alt_snapshot_folder + N'ftp\' + fn_replcomposepublicationsnapshotfolder(@@servername,db_name(),@publication) collate database_default
            select @distproc = fn_replquotename(RTRIM(@distributor)) collate database_default + N'.'  + fn_replquotename(@distribdb) collate database_default + 
                N'.dbo.sp_MSreplremoveuncdir'
            -- Ignore errors as the snapshot folder may not exist at all
            EXECUTE @distproc
                @dir = @pub_alt_snapshot_folder
        end
    end

	DECLARE @retval  INT
	EXECUTE @retval = master.dbo.xp_MSADEnabled
    if @ad_guidname is not NULL 
    begin
    	if @retval = 0
		begin
    		exec @retcode=master.dbo.sp_ActiveDirectory_Obj 'DELETE', 'PUBLICATION', @publication, @dbname, @ad_guidname
			if @@ERROR<>0 or @retcode<>0
			begin
				raiserror(21369, 16, -1, @publication)
				goto UNDO
			end
    	end
    	else
    	begin
			RAISERROR(21254, 16, -1, @publication)
    		GOTO UNDO
    	end
    end

    COMMIT TRAN

	-- Since we drop publisher_database_id in sp_MSdrop_publication at the distribution db when
	-- dropping the last tran (snapshot) publication, we should call repldone here to clear
	-- repl counters and lsns. This will ensure the correctness of repl counters and avoid
	-- unnecessary log scan in the logreader if it is created again after this.
	-- Ignore all errors.
	if not exists (select * from syspublications)
	begin
		DECLARE @replicate_bit	smallint
		SELECT @replicate_bit = 2

		-- Used for attach and restored db.
		-- sysservers table in master db might be changed so that
		-- sp_dropsubscription won't work, which left repl bits marked in
		-- sysobjects.
		-- We have to unmark them before calling sp_repldone, otherwise
		-- A new transaction updating those objects will be considered
		-- as repl tran. It will set the truncation point to not null, which will
		-- prevent log truncation.
		UPDATE sysobjects SET replinfo =  replinfo & ~@replicate_bit

		/* ensure we can get in as logreader */
	    exec dbo.sp_replflush

		/* clear repl dbtable fields unmark all xacts marked for replication */
		exec dbo.sp_repldone NULL, NULL, 0, 0, 1
    
	    /* release our hold on the db as logreader */
	    EXEC dbo.sp_replflush

		-- Run checkpoint to make sp_repldone result durable (write repl dbtable fields
		-- into the checkpoint record).
		checkpoint
	end	    

    return (0)  
    
UNDO:
    if @@TRANCOUNT = 1
        ROLLBACK TRAN
    else
        COMMIT TRAN
    return(1)
GO
 
EXEC dbo.sp_MS_marksystemobject sp_droppublication
GO

print ''
print 'Creating procedure sp_dropsubscription'
go
CREATE PROCEDURE sp_dropsubscription (
    @publication sysname = NULL,   /* The publication name */
    @article sysname = NULL,       /* The article name */
    @subscriber sysname,           /* The subscriber name */
    @destination_db sysname =NULL,                /* Name of the destination database */
                                        /* If null, all the subscriptions from that
                                            subscriber will be dropped */
    @ignore_distributor bit = 0,

    @reserved nvarchar(10) = NULL            /* reserved, used when calling from other system */
                                            /* stored procedures, it will be set to 'internal'.*/
                                            /* It should never be used directly */
    ) AS

    /*
    ** Declarations.
    */

    DECLARE @subscriber_bit smallint
    DECLARE @cmd nvarchar(255)
    DECLARE @srvid smallint
    DECLARE @artid int
    DECLARE @retcode int
    DECLARE @active tinyint
    DECLARE @internal nvarchar(10)
    DECLARE @expand_article nvarchar(10)
    DECLARE @push tinyint
    DECLARE @virtual_id smallint
    DECLARE @login_name sysname
    DECLARE @immediate_sync bit
    DECLARE @subscription_type int
    DECLARE @qualified_subscription_name nvarchar(512)
	DECLARE @sync_method tinyint
	DECLARE @concurrent tinyint
	DECLARE @concurrent_char tinyint

    /*
    ** Initializations.
    */
    SET NOCOUNT ON
    SELECT @subscriber_bit = 4  /* Const: subscription server status */
    SELECT @active = 2          /* Const: subscription status 'active' */
    SELECT @push = 0        /* Const: push publication type */
    SELECT @virtual_id = -1 /* Const: virtual subscriber id */
    SELECT @internal = 'internal' /* Const: Flag of calling internally from system */
                                  /* stored procedures     */
    SELECT @expand_article = 'expand_art' 
        /* Const: Flag of calling after expand 'all' for @article  */
    SELECT @concurrent = 3
    SELECT @concurrent_char = 4

    /* 
    ** Security Check.
    ** We use login_name stored in syssubscriptions to manage security 
    */

    -- Test distributor RPC connection before open the cursor

    /*
    ** if @ignore_distributor = 1, we are in bruteforce cleanup mode, don't do RPC.
    */
    if @ignore_distributor = 0
    begin
        declare @distributor sysname
        EXEC @retcode = dbo.sp_helpdistributor @rpcsrvname = @distributor OUTPUT
        if @@ERROR <> 0 or @retcode <> 0
            return(1)
    end

    /*
    ** If the @subscriber is 'all', the user wants to cancel all subscriptions
    ** to the specified article(s).
    */

    IF LOWER(@subscriber) = 'all'
        BEGIN
            DECLARE hCdrop_subscription1  CURSOR LOCAL FAST_FORWARD FOR 
                SELECT DISTINCT srvname 
                    FROM master..sysservers a, syssubscriptions b 
                    WHERE srvstatus & @subscriber_bit <> 0 
                    AND a.srvid = b.srvid

    -- With ANSI Defaults ON, the cursor will automatically
    -- be closed on commit.   Since this proc gets called recursively, 
    -- this can happen.  So check before opening. 
    IF CURSOR_STATUS('local','hCdrop_subscription1') = -1
            OPEN hCdrop_subscription1

			-- must owner qual proc invoke to exec inside server on restore/attach cleanup
            FETCH hCdrop_subscription1 INTO @subscriber
            WHILE (@@fetch_status <> -1)
                BEGIN
                    EXECUTE dbo.sp_dropsubscription 
                        @publication = @publication,
                        @article = @article,
                        @subscriber  = @subscriber,
                        @destination_db = 'all',
                        @ignore_distributor = @ignore_distributor,
                        @reserved = @reserved

        IF CURSOR_STATUS('local','hCdrop_subscription1') = -1
                OPEN hCdrop_subscription1
                FETCH hCdrop_subscription1 INTO @subscriber
                END
            CLOSE hCdrop_subscription1
            DEALLOCATE hCdrop_subscription1
            RETURN (0)
        END

    
    
    /*
    ** Parameter Check: @subscriber.
    **
    ** Check if the server exists and that it is a subscription server.
    **
    */
    IF @subscriber IS NULL
        BEGIN
            SELECT @srvid = @virtual_id 
        END
    ELSE
        BEGIN
            /* validate name and get subscriber ID  and server status  */
            EXECUTE @retcode = dbo.sp_validname @subscriber
            IF @retcode <> 0
            RETURN (1)

            SELECT @srvid = srvid
              FROM master..sysservers
             WHERE UPPER(srvname) = UPPER(@subscriber) collate database_default
               AND (srvstatus & @subscriber_bit) <> 0

            IF @srvid IS NULL
                BEGIN
                    RAISERROR (14010, 16, -1)
                    RETURN (1)
                END
        END

	-- Have to check @destination_db before expanding publications and articles
	-- Otherwise, the error will not be caught because the cursor will return zero row.
	if @destination_db is not null and LOWER(@destination_db) <> 'all' 
	begin
		if not exists (select * from syssubscriptions where
			srvid = @srvid and
			dest_db = @destination_db)
		begin
            RAISERROR (14055, 11, -1)
            RETURN (1)
		end
	end

    /*
    ** If the @publication is 'all', the user wants to cancel all subscriptions
    ** for all publications associated with the specified @subscriber.
    */

    IF LOWER(@publication) = 'all'
        BEGIN
            DECLARE hCdrop_subscription2  CURSOR LOCAL FAST_FORWARD FOR 
                SELECT DISTINCT a.name 
                    FROM syspublications a, sysextendedarticlesview b,  syssubscriptions c 
                    WHERE c.srvid = @srvid
					-- @destination_db will not be expanded before @publication is expanded.
					AND (c.dest_db = @destination_db 
					or @destination_db is null
					or LOWER(@destination_db) = 'all')
                    AND a.pubid = b.pubid 
                    AND b.artid = c.artid 
                    
            OPEN hCdrop_subscription2
            FETCH hCdrop_subscription2 INTO @publication
            WHILE (@@fetch_status <> -1)
                BEGIN
                    EXECUTE dbo.sp_dropsubscription @publication = @publication,
                                                @article     = 'all',
                                                @subscriber  = @subscriber,
                                                @destination_db = @destination_db,
                                                @ignore_distributor = @ignore_distributor,
                                                @reserved = @reserved

                    FETCH hCdrop_subscription2 INTO @publication
                END
            CLOSE hCdrop_subscription2
            DEALLOCATE hCdrop_subscription2
            RETURN (0)
        END

    /*
    ** Parameter Check: @publication.
    ** Check to make sure that the publication exists and that it conforms
    ** to the rules for identifiers.
    */

    IF @publication IS NULL
        BEGIN
            RAISERROR (14043, 16, -1, '@publication')
            RETURN (1)
        END

    EXECUTE @retcode = dbo.sp_validname @publication

    IF @retcode <> 0
    RETURN (1)

    IF NOT EXISTS (SELECT * FROM syspublications WHERE name = @publication)
        BEGIN
            RAISERROR (20026, 11, -1, @publication)
            RETURN (1)
        END

    /* Get subscription type of the publication */
    SELECT @immediate_sync = immediate_sync, @sync_method = sync_method
        FROM syspublications WHERE name = @publication

    /*
    ** Parameter Check:  @article
    */

    /* @article can not be null     */
    IF @article IS NULL
        BEGIN
            RAISERROR (14043, 16, -1, '@article')
            RETURN (1)
        END


	/* 
	** If publication is of concurrent sync, then all articles must
	** be unsubscribed to
	*/
	/*IF @sync_method in (@concurrent, @concurrent_char) AND
	   LOWER(@article) != 'all' AND
	   @reserved NOT IN( @expand_article, @internal )
	BEGIN
		RAISERROR( 14102, 16, -1 )
		RETURN (1)
	END*/

    /** For immediate_sync publication, @article has to be 'all'     */
    -- Relax this constraint since users will need to do this before dropping
    -- an article
    /*
    IF @reserved <> @internal AND @reserved <> @expand_article
        AND @immediate_sync = 1
        AND NOT LOWER(@article) = 'all'
        BEGIN
            RAISERROR (14122, 16, -1)
            RETURN (1)
        END
    */

    /*
    ** If the @article is 'all', the user wants to cancel all
    ** subscriptions on this publisher associated with the given @subscriber
    ** and @publication.
    */

    IF LOWER(@article) = 'all'
        BEGIN

            /* Make the operation automic for immediate_sync publications */
            BEGIN TRAN

            IF @reserved IS NULL
                SELECT @reserved = @expand_article

            DECLARE hCdrop_subscription3  CURSOR LOCAL FAST_FORWARD FOR
                SELECT DISTINCT art.name 
                    FROM sysextendedarticlesview art, syssubscriptions sub, syspublications pub 
                    WHERE sub.srvid = @srvid
					-- @destination_db will not be expanded before @article is expanded.
					AND (sub.dest_db = @destination_db 
					or @destination_db is null
					or LOWER(@destination_db) = 'all')
                    AND sub.artid = art.artid
                    AND art.pubid = pub.pubid
                    AND pub.name = @publication 
                    
            OPEN hCdrop_subscription3
            FETCH hCdrop_subscription3 INTO @article
            WHILE (@@fetch_status <> -1)
                BEGIN
                    EXECUTE @retcode = dbo.sp_dropsubscription 
                        @publication = @publication,
                        @article = @article,
                        @subscriber = @subscriber,
                        @destination_db = @destination_db,
                        @ignore_distributor = @ignore_distributor,
                        @reserved = @reserved
                    IF @@error<>0 OR @retcode <> 0
                    BEGIN
                        CLOSE hCdrop_subscription3
                        DEALLOCATE hCdrop_subscription3
                        GOTO UNDO                        
                    END
                    FETCH hCdrop_subscription3 INTO @article
                END
            CLOSE hCdrop_subscription3
            DEALLOCATE hCdrop_subscription3

            COMMIT TRAN
            RETURN (0)
        END

    /*
    ** Parameter Check: @article
    ** Check if the article exists.
    */

    /*
    EXECUTE @retcode = dbo.sp_validname @article

    IF @retcode <> 0
    RETURN (1)
    */

    SELECT @artid = artid
      FROM sysextendedarticlesview art, syspublications pub
     WHERE pub.name = @publication
       AND art.name = @article
       AND art.pubid = pub.pubid

    IF @artid IS NULL
        BEGIN
            RAISERROR (20027, 11, -1, @article)
        RETURN (1)
        END


    /*
    ** Parameter Check: @destination_db.
    ** Set @destination_db to current database if not specified.  Make
    ** sure that the @destination_db conforms to the rules for identifiers.
    */

    IF @destination_db IS NULL
    BEGIN
        /*
        ** Check if the subscription exists.
        */

        IF NOT EXISTS (SELECT *
                         FROM syssubscriptions
                        WHERE srvid = @srvid
                          AND artid = @artid)
        BEGIN    
                RAISERROR (14055, 11, -1)
                RETURN (1)
        END
        ELSE

        SELECT @destination_db = 'all' 
    END
    ELSE
    BEGIN
		EXECUTE @retcode = dbo.sp_validname @destination_db
		IF @retcode <> 0
		RETURN (1)
    END

    IF LOWER(@destination_db) = 'all' 
        BEGIN
            DECLARE hCdropsub4  CURSOR LOCAL FAST_FORWARD FOR 
                SELECT DISTINCT dest_db
                    FROM syssubscriptions 
                    WHERE srvid = @srvid
                    AND artid = @artid
            OPEN hCdropsub4
            FETCH hCdropsub4 INTO @destination_db
            WHILE (@@fetch_status <> -1)
                BEGIN
                    EXECUTE dbo.sp_dropsubscription 
                        @publication = @publication,
                        @article = @article,
                        @subscriber = @subscriber,
                        @destination_db = @destination_db,
                        @ignore_distributor = @ignore_distributor,
                        @reserved = @reserved
                    FETCH hCdropsub4 INTO @destination_db
                END
            CLOSE hCdropsub4
            DEALLOCATE hCdropsub4
            RETURN (0)
        END

    /*
    ** Dropping virtual subscriptions is not allowed
    ** in following case:
    ** 1. non sa or dbo user
    ** 2. the stored procedure is not in internal usage mode 
    **        (called by system stored procedures)
    **
    ** Note: Only immediate_sync publications have virtual subscriptions
    ** 
    */

    IF  @srvid = @virtual_id  AND  (
        @reserved <> @internal)
        BEGIN
            RAISERROR (14056, 16, -1)
            RETURN (1)
        END

    /*
    ** Check if the subscription exists.
    */

    IF NOT EXISTS (SELECT *
                     FROM syssubscriptions
                    WHERE srvid = @srvid
                      AND artid = @artid
                      AND dest_db = @destination_db)
    BEGIN
            RAISERROR (14055, 11, -1)
            RETURN (1)
    END


    /* Check the current login id. It is valid only when
    ** 1. sa or dbo
    ** 2. same as the one who add the subscription.
    */
    SELECT @login_name = login_name 
         FROM syssubscriptions
        WHERE srvid = @srvid
          AND artid = @artid
          AND dest_db = @destination_db

    IF  suser_sname(suser_sid()) <> @login_name AND is_srvrolemember('sysadmin') <> 1  
        AND is_member ('db_owner') <> 1
    BEGIN
            SELECT @qualified_subscription_name = @subscriber + N':' + @destination_db
            RAISERROR(21120, 11, -1, @qualified_subscription_name, @publication)
            RETURN (1)
    END


    begin tran
    save TRANSACTION dropsubscription

        /* If dropping virtual subscriptions, reset immediate_sync_ready bit */
        IF @srvid = @virtual_id
        BEGIN
            UPDATE syspublications SET immediate_sync_ready = 0
                WHERE
                    name = @publication and
                    immediate_sync = 1 and
                    immediate_sync_ready = 1
            IF @@ERROR <> 0
                goto UNDO
        END

        /*
        ** Change the status of the subscription to 'inactive'.
        */

        EXECUTE @retcode = dbo.sp_changesubstatus @publication = @publication,
                                              @article = @article,
                                              @subscriber = @subscriber,
                                              @status = 'inactive',
                                              @destination_db = @destination_db,
                                              @ignore_distributor = @ignore_distributor
        IF @@ERROR <> 0 OR @retcode <> 0
        BEGIN
            if @@trancount > 0
            begin
                ROLLBACK TRANSACTION dropsubscription
                commit tran
            end
            RETURN (1)
        END

    /* Read the subscription_type befor removing the syssubscriptions row */
    select @subscription_type = subscription_type from syssubscriptions
        WHERE artid = @artid
        AND srvid = @srvid
        AND dest_db = @destination_db
    /*
    ** Remove subscription from syssubscriptions.
    */
    DELETE syssubscriptions
     WHERE artid = @artid
       AND srvid = @srvid
       AND dest_db = @destination_db

    IF @@ERROR <> 0
    BEGIN
        if @@trancount > 0
        begin
            ROLLBACK TRANSACTION dropsubscription
            commit tran
        end
        RETURN (1)
    END

    /* Call sp_MSunregistersubscription so that the reg entries get deleted (for push subscriptions) */
    if @subscription_type = @push
        begin
            declare @publisher_db sysname
            set @publisher_db = DB_NAME()
            exec @retcode = dbo.sp_MSunregistersubscription @publisher = @@SERVERNAME,
                                @publisher_db = @publisher_db,
                                @publication = @publication,
                                @subscriber = @subscriber,
                                @subscriber_db = @destination_db

            IF @retcode<>0 or @@ERROR<>0
                GOTO UNDO
        end             
  
    COMMIT TRANSACTION
    RETURN (0)

UNDO:
    IF @@TRANCOUNT = 1
        ROLLBACK TRAN
    ELSE
        COMMIT TRAN
    RETURN(1)
go
 
EXEC dbo.sp_MS_marksystemobject sp_dropsubscription
GO

print ''
print 'Creating procedure sp_subscribe'
go
CREATE PROCEDURE sp_subscribe (
    @publication sysname,          /* publication name */
    @article sysname = 'all',          /* article name */
    @destination_db sysname = NULL,  /* subscriber database */
    @sync_type nvarchar (15) = 'automatic' /* subscription sync type */
    ) AS

    -- New 7.0 sp_addsubscription parameters
    DECLARE @subscriber                  sysname
    DECLARE @status                      sysname
    DECLARE @subscription_type           nvarchar(4)
    DECLARE @update_mode                 nvarchar(15)
    DECLARE @loopback_detection          nvarchar(5)
    DECLARE @enabled_for_syncmgr         nvarchar(5)
    DECLARE @retcode                     int

    SET NOCOUNT ON

    -- sp_subscribe has to be called from a remote subscriber 
    -- If not, we state that it is unsupported
    SELECT @subscriber = @@REMSERVER
    IF @subscriber IS NULL
    BEGIN
      RAISERROR (21023, 16, -1,'sp_subscribe')
      RETURN(1)
    END
    
    SELECT @status = NULL
    SELECT @subscription_type = 'push'
    SELECT @update_mode = 'read only'
    SELECT @loopback_detection = 'false'
    SELECT @enabled_for_syncmgr = 'false'

    -- Call sp_addsubscription to do the actual work
    EXEC @retcode = dbo.sp_addsubscription @publication = @publication,
                                           @article = @article,
                                           @destination_db = @destination_db,
                                           @sync_type = @sync_type,
                                           @subscriber = @subscriber,
                                           @status = @status,
                                           @subscription_type = @subscription_type,
                                           @update_mode = @update_mode,
                                           @loopback_detection = @loopback_detection,
                                           @enabled_for_syncmgr = @enabled_for_syncmgr
                                        
    RETURN @retcode   
go
 
EXEC dbo.sp_MS_marksystemobject sp_subscribe
GO

print ''
print 'Creating procedure sp_unsubscribe'
go
CREATE PROCEDURE sp_unsubscribe (
    @publication sysname = NULL,       /* publication name */
    @article sysname = NULL            /* article name */
    ) AS

    -- New 7.0 sp_dropsubscription parameters
    DECLARE @subscriber     sysname
    DECLARE @destination_db sysname    
    DECLARE @retcode        int 

    SET NOCOUNT ON
    
    -- sp_unsubscribe has to be callled from a remote subscriber
    -- If not, we state that it is unsupported
    SELECT @subscriber = @@REMSERVER
    IF @subscriber IS NULL
    BEGIN
        RAISERROR (21023, 16, -1,'sp_unsubscribe')
        RETURN(1)
    END

    -- 6.5 didn't support having multiple databases on the same subscriber
    -- subscribing to the same publication so here, all subscriptions to the
    -- same publication will be dropped 
    SELECT @destination_db = NULL
    
    -- Call sp_dropsubscription to do the real work
    EXEC @retcode = sp_dropsubscription @publication = @publication,
                                        @article = @article,
                                        @subscriber = @subscriber,
                                        @destination_db = @destination_db
    RETURN @retcode
    
go
 
EXEC dbo.sp_MS_marksystemobject sp_unsubscribe
GO

print ''
print 'Creating procedure sp_refreshsubscriptions'
go

CREATE PROCEDURE sp_refreshsubscriptions (
    @publication sysname       /* Publication name */
    ) AS

    SET NOCOUNT ON

    /*
    ** Declarations.
    */

    DECLARE @article  sysname 
    DECLARE @subscriber sysname
    DECLARE @dest_db sysname
    DECLARE @retcode int
    DECLARE @pubid int
    DECLARE @immediate_sync bit 
    DECLARE @no_sync tinyint
    DECLARE @subscription_type_id int
    DECLARE @subscription_type nvarchar(4)
    DECLARE @virtual smallint
    DECLARE @srvid smallint
    DECLARE @sync_typeid int
    DECLARE @automatic tinyint
    DECLARE @sync_type nvarchar(9)

    SELECT @no_sync = 2
    SELECT @virtual = -1
    SELECT @automatic = 1
    /*
    ** Security Check
    */
    exec @retcode = dbo.sp_MSreplcheck_publish
    if @@ERROR <> 0 or @retcode <> 0
        return(1)

    /*
    ** Check to see if the database has been activated for publication.
    */

    IF (SELECT category & 1
          FROM master..sysdatabases
         WHERE name = DB_NAME() collate database_default) = 0

    BEGIN
            RAISERROR (14013, 16, -1)
        RETURN (1)
    END


    /*
    ** Parameter Check:  @publication.
    ** Make sure that the publication exists
    */

    IF @publication IS NULL
        BEGIN
            RAISERROR (14043, 16, -1, '@publication')
            RETURN (1)
        END

    EXECUTE @retcode = dbo.sp_validname @publication

    IF @@ERROR <> 0 OR @retcode <> 0
    RETURN (1)

    SELECT @pubid = pubid
        FROM syspublications WHERE name = @publication

    IF @pubid IS NULL
        BEGIN
            RAISERROR (20026, 11, -1, @publication)
            RETURN (1)
        END
    
    
    /* Add real subscription to the new articles  */
    /* Open a cursor on all the pending subscriptions, that is */
    /* All the subscriptions on the publication that */
    /* are not on an article in the publication. */
    /* not including virtual subscriptions */

    DECLARE hCrefreshsubscriptions CURSOR LOCAL FAST_FORWARD FOR
        SELECT DISTINCT art1.name, subs1.dest_db, subs1.srvid
            FROM syssubscriptions subs1, sysextendedarticlesview art1
            WHERE art1.pubid = @pubid AND
                  subs1.srvid <> @virtual AND
                  EXISTS (SELECT * FROM syssubscriptions subs2, sysextendedarticlesview art2
                    WHERE subs2.srvid = subs1.srvid AND
                          subs2.dest_db = subs1.dest_db AND
                          subs2.artid = art2.artid AND
                          art2.pubid = @pubid) AND
                  NOT EXISTS ( SELECT * FROM syssubscriptions subs3 
                    WHERE  subs3.artid = art1.artid AND
                           subs3.srvid = subs1.srvid AND
                           subs3.dest_db = subs1.dest_db)
    FOR READ ONLY
    OPEN hCrefreshsubscriptions
    FETCH hCrefreshsubscriptions INTO @article,  @dest_db, @srvid
            
    
    WHILE (@@fetch_status <> -1)
    BEGIN

        /* 
        ** Get subscription type on the publication
        */ 
        SELECT @subscription_type_id = subs.subscription_type,
            @sync_typeid = subs.sync_type
         from 
            sysextendedarticlesview art, syssubscriptions subs where 
            art.pubid = @pubid AND
            subs.srvid = @srvid AND
            subs.dest_db = @dest_db AND
            subs.artid = art.artid

        /* 
        ** only do it if the subscription all have the same subscription type
        ** and sync_type
        */
        IF NOT EXISTS (SELECT * from 
            sysextendedarticlesview art, syssubscriptions subs where 
            art.pubid = @pubid AND
            subs.srvid = @srvid AND
            subs.dest_db = @dest_db AND
            subs.artid = art.artid AND
            (subscription_type <> @subscription_type_id OR
            sync_type <> @sync_typeid))
        BEGIN
            IF @subscription_type_id = 0
                SELECT @subscription_type = 'push'
            ELSE
                SELECT @subscription_type = 'pull'

            if @sync_typeid = @automatic
                SELECT @sync_type = 'automatic'
            else
                SELECT @sync_type = 'none'

            /* 
            ** Get the server name
            */
            SELECT @subscriber = srvname FROM master.dbo.sysservers 
                WHERE srvid = @srvid

            EXECUTE @retcode  = dbo.sp_addsubscription 
                        @publication = @publication, 
                        @article = @article, 
                        @subscriber = @subscriber, 
                        @destination_db = @dest_db, 
                        @sync_type = @sync_type, 
                        @status = NULL, 
                        @subscription_type = @subscription_type,
                        @reserved = 'internal'
            IF @@ERROR <> 0 OR @retcode <> 0
            BEGIN
                CLOSE hCrefreshsubscriptions
                DEALLOCATE hCrefreshsubscriptions
                RETURN (1)
            END
        END
        FETCH hCrefreshsubscriptions INTO @article, @dest_db, @srvid
    END
    
    CLOSE hCrefreshsubscriptions
    DEALLOCATE hCrefreshsubscriptions

GO
 
EXEC dbo.sp_MS_marksystemobject sp_refreshsubscriptions
GO

print ''
print 'Creating procedure sp_MSpublishdb'
go

CREATE PROCEDURE sp_MSpublishdb(
      @value     sysname,
      @ignore_distributor bit = 0
    ) AS

    SET NOCOUNT ON

    /*
    ** Declarations.
    */
    declare @quoted_db      sysname
    declare @db_name        sysname
    declare @command        nvarchar(255)
    declare @description    nvarchar(500)
    declare @category_name  nvarchar(100)
    DECLARE @agentname      nvarchar(300)
    DECLARE @dbname         sysname 
    DECLARE @retcode        int
    DECLARE @distributor    sysname
    DECLARE @distribdb      sysname
    DECLARE @distproc       nvarchar (255)
    /*
    ** Initialization
    */

    SELECT @dbname = DB_NAME()

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
    ** if @ignore_distributor = 1, we are in bruteforce cleanup mode, don't do RPC.
    */
    if @ignore_distributor = 0
    begin
        /*
        ** Test to see if the distributor is installed and online.
        */
        EXECUTE @retcode = dbo.sp_helpdistributor @rpcsrvname = @distributor OUTPUT,
           @distribdb   = @distribdb OUTPUT

        IF @@ERROR <> 0 or @retcode <> 0 or @distributor IS NULL or @distribdb IS NULL
        BEGIN
            IF LOWER(@value collate SQL_Latin1_General_CP1_CS_AS) = 'true'
                RAISERROR (20028, 16, -1)
            ELSE
                RAISERROR (20029, 16, -1)
            RETURN (1)
        END
    end

    /*
    ** Enable the database for publishing.
    */
    IF LOWER(@value collate SQL_Latin1_General_CP1_CS_AS) = 'true'
    BEGIN

        /*
        ** Drop and then create central publish tables
        */

        /* 
        ** Drop first if exists
        */

        EXEC @retcode = dbo.sp_MSdrop_pub_tables
        IF @@ERROR <> 0 or @retcode <> 0
        BEGIN
            return (1)
        END

        /*
        ** Create central publish tables
        */

        EXEC @retcode = dbo.sp_MScreate_pub_tables
        IF @@ERROR <> 0 or @retcode <> 0
        BEGIN
            return (1)
        END
    END

    ELSE    /* Disable the database for publishing. */
    BEGIN
        /*
        ** Remove all subscriptions in the database.
		** WARNING : must owner qualify proc calls for these to run inside server on restore/attach
        */
        EXEC @retcode = dbo.sp_dropsubscription @publication = 'all',
            @article = 'all', @subscriber = 'all', 
            @ignore_distributor = @ignore_distributor
        IF @@ERROR <> 0 or @retcode <> 0
        BEGIN
            return (1)
        END

		-- Used for attach and restored db.
		-- sysservers table in master db might be changed so that
		-- sp_dropsubscription won't work. Delete the table directly.

		delete syssubscriptions where srvid >= 0
        IF @@ERROR <> 0 
        BEGIN
            return (1)
        END

        /*
        ** Remove all publications and articles in the database.
		** sp_droppublication will also forcefully unmark repl bits in sysobjects
		** and call sp_repldone when dropping the last
		** publication.
        */
        EXEC @retcode = dbo.sp_droppublication @publication = 'all', 
            @ignore_distributor = @ignore_distributor
        IF @@ERROR <> 0 or @retcode <> 0
        BEGIN
            return (1)
		END

	    /* 
		** Drop central publish tables
	    */ 
		EXEC @retcode = dbo.sp_MSdrop_pub_tables
		IF @@ERROR <> 0 or @retcode <> 0
	    BEGIN
		    return (1)
	    END

      END
    return (0)
GO
 
EXEC dbo.sp_MS_marksystemobject sp_MSpublishdb
GO

print ''
print 'Creating procedure sp_MSactivate_auto_sub'
go

CREATE PROCEDURE sp_MSactivate_auto_sub (
    @publication sysname,        /* Publication name */
    @article sysname,
	@status sysname = 'active',
    @schemastabilityonly int = 0
    ) AS

    SET NOCOUNT ON

    DECLARE @retcode int

    /*
    ** Security Check.
    */
	exec @retcode = dbo.sp_MSreplcheck_publish
	if @@ERROR <> 0 or @retcode <> 0
		return(1)

    /*
    ** Check to see if the database has been activated for publication.
    */

    IF (SELECT category & 1
          FROM master..sysdatabases
         WHERE name = DB_NAME() collate database_default) = 0

    BEGIN
        RAISERROR (14013, 16, -1)
        RETURN (1)
    END

	-- parameter check: @status:  

	IF LOWER(@status collate SQL_Latin1_General_CP1_CS_AS) not in (N'active', N'initiated')
	BEGIN
		RAISERROR(21156, 16, -1)
		RETURN 1
	END

    /*
    ** Parameter Check:  @publication.
    ** Make sure that the publication exists and the publication is not push type
    */

    IF @publication IS NULL
        BEGIN
            RAISERROR (14043, 16, -1, '@publication')
            RETURN (1)
        END

    EXECUTE @retcode = dbo.sp_validname @publication
    IF @@ERROR <> 0 OR @retcode <> 0
        RETURN (1)
    
    BEGIN TRAN

	IF @status = N'active'
	BEGIN
		UPDATE syspublications SET immediate_sync_ready = 1 
			WHERE
				name = @publication AND
				immediate_sync = 1 AND
				immediate_sync_ready <> 1
		IF @@ERROR <> 0
		BEGIN
			GOTO UNDO
			RETURN (1)
		END
	END

    EXECUTE @retcode = dbo.sp_changesubstatus 
        @publication = @publication,
        @article = @article,
        @status = @status,
        @from_auto_sync = 1,
        @schemastabilityonly = @schemastabilityonly

    IF @@ERROR <> 0 OR @retcode <> 0
    BEGIN
        GOTO UNDO
        RETURN (1)
    END
    
    COMMIT TRAN
    RETURN(0)

UNDO:
    IF @@TRANCOUNT = 1
        ROLLBACK TRAN
    ELSE
        COMMIT TRAN

GO

EXEC dbo.sp_MS_marksystemobject sp_MSactivate_auto_sub
GO

raiserror('Creating procedure sp_MSget_synctran_commands', 0,1)
GO
CREATE PROCEDURE sp_MSget_synctran_commands(
    @publication sysname    /* publication name */,
    @article sysname = 'all',
    @command_only bit = 0   /* 0 if called by snapshot agent, 1 if called by sp_script_..., */
) AS
BEGIN
    SET NOCOUNT ON
    DECLARE @artid int
			,@tabid int
			,@retcode int
			,@art_type tinyint        
			,@filter_id int
			,@filter_clause nvarchar(4000)
			,@columns binary(32)
			,@distributor sysname
			,@pubid int
			,@art_name sysname 
			,@posted_synctran_artid int
			,@dest_table sysname 
			,@dest_owner sysname
			,@proc_owner sysname

			,@ts_col sysname
			,@replcmd nvarchar(4000)
			,@insproc sysname
			,@updproc sysname
			,@delproc sysname
			,@cftproc sysname
			,@cft_table sysname
			,@is_synctran bit
			,@is_queued bit
			,@identity_col sysname
			,@identity_prop tinyint
			,@identity_support bit


    /*
    ** Initializations.
    */
    select @posted_synctran_artid = 0 
	select @identity_support = 0

    /* 
    ** Security Check.
    ** We use login_name stored in syssubscriptions to manage security 
    ** Do a relaxed security check here.
    */
    exec @retcode = dbo.sp_MSreplcheck_publish
    if @@ERROR <> 0 or @retcode <> 0
        return(1)

    /*
    ** Parameter Check:  @publication
    ** Check to make sure that the publication exists, that it's not NULL,
    ** and that it conforms to the rules for identifiers.
    */

    IF @publication IS NULL
        BEGIN
            RAISERROR (14043, 16, -1, '@publication')
            RETURN (1)
        END

    EXECUTE @retcode = dbo.sp_validname @publication
    IF @@ERROR <> 0 OR @retcode <> 0
    RETURN (1)

	declare @independent_agent bit
	SELECT @pubid = pubid,
			@independent_agent = independent_agent,
			@is_synctran = allow_sync_tran,
			@is_queued = allow_queued_tran
	FROM syspublications 
	WHERE name = @publication

    IF @pubid IS NULL
    BEGIN
        RAISERROR (20026, 11, -1, @publication)
        RETURN (1)
    END

    -- If the publication does not allow sync tran or queued tran return nothing
    IF (@is_synctran = 0 AND @is_queued = 0)
        RETURN(0)

	--
	-- get the distributor details for this publisher
	--
	exec @retcode = dbo.sp_helpdistributor @distributor = @distributor OUTPUT
	if (@@ERROR != 0 OR @retcode != 0 or @distributor IS NULL)
	begin
		raiserror('sp_MSget_synctran_commands(debug): could not get distributor info', 16, 1)
		RETURN (1)
	end

    CREATE TABLE #art_commands (artid int NOT NULL, commands nvarchar(4000) collate database_default null, id int identity NOT NULL)
    
    declare @all_article bit 

    if lower(@article) = 'all'
        select @all_article = 1
    else
        select @all_article = 0

	-- Construct ver check cmd
	declare @ver_check_cmd nvarchar(4000)
	-- Construct message.
	select @ver_check_cmd = formatmessage(21273)
	select @ver_check_cmd = '''' + replace(@ver_check_cmd, '''', '''''') + ''''
	select @ver_check_cmd = 'if @@microsoftversion<0x07320000 raiserror(' + 
		@ver_check_cmd + ',16, -1)'

    DECLARE hCsynctran_arts CURSOR LOCAL FAST_FORWARD FOR
        SELECT art.artid,
               art.objid,
               
               art.dest_table,
			   art.dest_owner,
			   art.name,
			   art.type,
			   art.filter,
			   art.columns
          FROM sysarticles art,
               syspublications pub
         WHERE pub.pubid = @pubid and
               pub.pubid = art.pubid and
               (art.type & 0x1) = 1 and
               (art.name = @article or
               @all_article = 1)
    FOR READ ONLY

    OPEN hCsynctran_arts

	FETCH hCsynctran_arts INTO @artid, @tabid, @dest_table, @dest_owner, @art_name, 
		@art_type, @filter_id, @columns
	
    WHILE (@@fetch_status <> -1)
    BEGIN

    /*
    ** Determine conflict detection method 
    */
        -- Determine if table has timestamp property
        select @ts_col = NULL
        if ObjectProperty(@tabid, 'TableHasTimestamp') = 1 
        begin
            exec dbo.sp_MSis_col_replicated @publication, @art_name, 
                'timestamp', @ts_col OUTPUT
        end

        select @posted_synctran_artid = @artid

        select @insproc = null, @updproc = null, @delproc = null

        -- Get sproc names and owner name of the sprocs
        -- Note artid is unique
        select @insproc = o.name, @proc_owner = u.name from sysobjects o, sysarticleupdates a, sysusers u
        where a.artid = @artid and a.sync_ins_proc = o.id and
            u.uid = o.uid

        select @updproc = o.name from sysobjects o, sysarticleupdates a
        where a.artid = @artid and a.sync_upd_proc = o.id
    
        select @delproc = o.name from sysobjects o, sysarticleupdates a
        where a.artid = @artid and a.sync_del_proc = o.id 

        select @cftproc = o.name from sysobjects o, sysarticleupdates a
        where a.artid = @artid and a.ins_conflict_proc = o.id 
        
        if @insproc IS NULL
        begin
            CLOSE hCsynctran_arts
            DEALLOCATE hCsynctran_arts
            RAISERROR (14043, 11, -1, '@insproc')
            RETURN (1)
        end

        if @updproc IS NULL 
        begin
            CLOSE hCsynctran_arts
            DEALLOCATE hCsynctran_arts
            RAISERROR (14043, 11, -1, '@updproc')
            RETURN (1)
        end

        if @delproc IS NULL
        begin
            CLOSE hCsynctran_arts
            DEALLOCATE hCsynctran_arts
            RAISERROR (14043, 11, -1, '@delproc')
            RETURN (1)
        end

        if (@cftproc IS NULL)
        begin
            if (@is_queued = 1)
            begin
                CLOSE hCsynctran_arts
                DEALLOCATE hCsynctran_arts
                RAISERROR (14043, 11, -1, '@cftproc')
                RETURN (1)
            end        	
        end

        -- Determine if published table has identity  col
        select @identity_col = NULL
        select @identity_support = 0
        if ObjectProperty(@tabid, 'TableHasIdentity') = 1 
            exec @retcode = dbo.sp_MSis_col_replicated @publication, @art_name, 'identity', @identity_col OUTPUT
		if @identity_col is not null
			select @identity_support = identity_support from sysarticleupdates where artid = @artid
                
        -- Horizontal partition
        select @filter_clause = 'null'
        if @filter_id <> 0
        begin
            -- We don't handle manual filters;  allow all updates
            if ((@art_type & 0x3) <> 0x3) 
                select @filter_clause = RTRIM(LTRIM(CONVERT(nvarchar(4000), filter_clause)))
                     from sysarticles where artid = @artid
        end
	
        declare @fullname nvarchar(512)
        declare @indkey       int
        declare @indid        int
        declare @key          sysname
        declare @col          sysname
        declare @this_col	  int
        declare @src_cols	  int
        declare @primary_key_bitmap varbinary(4000)
        declare @byte varbinary(1)
        declare @i_byte			int
        declare @num_bytes		int
        declare @i_bit			tinyint	
        declare @bitmap_str	varchar(8000)
        declare @bitmap			varbinary(4000)


        -- Get qualified name
        exec dbo.sp_MSget_qualified_name @tabid, @fullname output

        -- Get number of columns in the partition.
        exec dbo.sp_MSget_col_position @tabid, @columns, @key, @col output, 
        	@this_col output, 
        	1, -- Get num of columns in the partition.
        	@src_cols output
        select @num_bytes = @src_cols / 8 + 1
	
        -- Set varbinary length
        set @byte = 0
        set @primary_key_bitmap = @byte
        set @i_byte = 1
        while @i_byte < @num_bytes
        begin
        	set @primary_key_bitmap = @primary_key_bitmap + @byte
        	set @i_byte = @i_byte + 1
        end
	
        -- get index id
        exec @indid = dbo.sp_MStable_has_unique_index @tabid
        set @indkey = 1
        while @indkey < 16 and index_col(@fullname, @indid, @indkey) is not null
        begin
            set @key = index_col(@fullname, @indid, @indkey)
            exec dbo.sp_MSget_col_position @tabid, @columns, @key, @col output, @this_col output
			set @i_byte = 1 + (@this_col-1) / 8
			set @i_bit  = power(2, (@this_col-1) % 8 )
		    set @primary_key_bitmap 
                = substring(@primary_key_bitmap, 1, @i_byte - 1)
                + convert(binary(1), substring(@primary_key_bitmap, @i_byte, 1) | @i_bit)
                + substring(@primary_key_bitmap, @i_byte + 1, @num_bytes - @i_byte)
			select @indkey = @indkey + 1
        end
        exec @retcode = master..xp_varbintohexstr @primary_key_bitmap, @bitmap_str output
        if @retcode <> 0 or @@error <> 0
        	return 1
        if @dest_owner is null 
        begin
        	select @dest_owner = N'null'
        end
        --
        -- If we are processing queued publications, insert a command
        -- to populate MSsubsciption_articles for this article
        --
        if (@is_queued = 1)
        begin
        	select @cft_table = OBJECT_NAME(conflict_tableid) 
        	from sysarticleupdates
        	where artid = @artid and pubid = @pubid

        	if (@cft_table IS NULL)
        	begin
        		CLOSE hCsynctran_arts
        		DEALLOCATE hCsynctran_arts
        		raiserror('Debug: article %s in publication % should have valid conflict table', 
        			16, 1, @art_name, @publication)
        		return 1				
        	end

        	--
        	-- add another command
        	--
        	select @replcmd = '{call sp_addqueued_artinfo (' + 
        		cast(@artid as nvarchar(10)) collate database_default + ', N' +
        		quotename(@art_name,'''') collate database_default + ', N' + 				
        		quotename(@@SERVERNAME,'''') collate database_default + ', N' +   
        		quotename(db_name(),'''') collate database_default + ', N' + 
        		quotename(@publication,'''') collate database_default + ', N' +  
        		quotename(@dest_table,'''') collate database_default + ', N' + 
        		quotename(@dest_owner,'''') collate database_default + ', N' +   
        		quotename(@cft_table,'''') collate database_default + ', ' +
        		master.dbo.fn_varbintohexstr(@columns) collate database_default + ' )}'
        	
        	-- Must add ver check cmd for each article since user can subscribe
        	-- to just one article.	
        	insert into #art_commands values (@artid, @ver_check_cmd)						
        	insert into #art_commands values (@artid, @replcmd)						
        end
        --
        -- insert the command to generate the triggers
        -- for Sp3 or later subscribers
        --
        select @replcmd = 'if (@@microsoftversion >= 0x080002C0) begin ' + 
              'exec sp_addsynctriggers N' + 
        	quotename(@dest_table,'''') + ', N' + 
        	quotename(@dest_owner,'''') + ', N' +  
        	quotename(@@SERVERNAME,'''') + ', N' +   
        	quotename(db_name(),'''') + ', N' + 
        	quotename(@publication,'''') + ', N' +  
        	quotename(@insproc,'''') + ', N' +   
        	quotename(@updproc,'''') + ', N' +   
        	quotename(@delproc,'''') + ', N' + 
        	ISNULL(quotename(@cftproc,''''), '''null''')  + ', N' + 
        	quotename(@proc_owner,'''') + ', N' + 
        	ISNULL(quotename(@identity_col,''''),'''null''') + ', N' + 
        	ISNULL(quotename(@ts_col,''''), '''null''') + ', N''' + 
        	replace(@filter_clause,'''', '''''')  + ''', ' + 
        	@bitmap_str   + ', ' + 
        	convert(nvarchar(2), @identity_support)  + ',' +
        	convert(nvarchar(2), @independent_agent) + ',N' +
        	quotename(@distributor,'''') +  ', ' +
        	'2 ' + 
        	'end '
        -- Must add ver check cmd for each article since user can subscribe
        -- to just one article.	
        insert into #art_commands values (@artid, @ver_check_cmd) 
        insert into #art_commands values (@artid, @replcmd)
        --
        -- insert the command to generate the triggers
        -- for pre Sp3 subscribers
        --
        select @replcmd = 'if (@@microsoftversion < 0x080002C0) begin ' + 
              'exec sp_addsynctriggers N' + 
        	quotename(@dest_table,'''') + ', N' + 
        	quotename(@dest_owner,'''') + ', N' +  
        	quotename(@@SERVERNAME,'''') + ', N' +   
        	quotename(db_name(),'''') + ', N' + 
        	quotename(@publication,'''') + ', N' +  
        	quotename(@insproc,'''') + ', N' +   
        	quotename(@updproc,'''') + ', N' +   
        	quotename(@delproc,'''') + ', N' + 
        	ISNULL(quotename(@cftproc,''''), '''null''')  + ', N' + 
        	quotename(@proc_owner,'''') + ', N' + 
        	ISNULL(quotename(@identity_col,''''),'''null''') + ', N' + 
        	ISNULL(quotename(@ts_col,''''), '''null''') + ', N''' + 
        	replace(@filter_clause,'''', '''''')  + ''', ' + 
        	@bitmap_str   + ', ' + 
        	convert(nvarchar(2), @identity_support)  + ',' +
        	convert(nvarchar(2), @independent_agent) + ',N' +
        	quotename(@distributor,'''')  +
        	' end '
        -- Must add ver check cmd for each article since user can subscribe
        -- to just one article.	
        insert into #art_commands values (@artid, @ver_check_cmd) 
        insert into #art_commands values (@artid, @replcmd)

        FETCH hCsynctran_arts INTO @artid, @tabid, @dest_table, @dest_owner, @art_name, 
        	@art_type, @filter_id, @columns
    end

    -- end SyncTran
    if @command_only = 0 
        select * from #art_commands order by id
    else
        select commands from #art_commands order by id

    CLOSE hCsynctran_arts
    DEALLOCATE hCsynctran_arts

    return 0
END
go
 
EXEC dbo.sp_MS_marksystemobject sp_MSget_synctran_commands
GO

--
-- Name: sp_script_synctran_commands
--
-- Description: This SP is used by customers to generate the synctran commands 
-- to be executed on subscriber for manual initialization updating subscriptions. 
-- This is needed for the case when the subscription synchronization is not automatic.
-- Invoked on the publisher
--
-- Parameter: Refer to the comments in the create procedure statement
--
-- Returns: 1 or 0   0 = success
--
-- Security: Public procedure - does publisher security check. 
--
raiserror('Creating procedure sp_script_synctran_commands', 0,1)
GO
CREATE PROCEDURE sp_script_synctran_commands(
    @publication sysname,    /* publication name */
    @article sysname = 'all'    /* article name, all means all article */
) 
AS
begin
    declare @retcode int

    --
    -- security check
    --
    exec @retcode = dbo.sp_MSreplcheck_publish
    if @@error <> 0 or @retcode <> 0
    begin
        return (1)
    end
    --
    -- Generate the scripts by calling internal SP
    --
    exec @retcode = dbo.sp_MSget_synctran_commands 
        @publication = @publication,
        @article = @article,
        @command_only = 1
    if @retcode <> 0 or @@error <> 0
        return (1)
end
go
EXEC dbo.sp_MS_marksystemobject sp_script_synctran_commands
GO

print ''
print 'Creating procedure sp_MSaddpub_snapshot'
go
CREATE PROCEDURE sp_MSaddpub_snapshot (
    @publication sysname,    
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
    @newagentid int = 0 OUTPUT,
    @snapshot_job_name nvarchar(100) = null
) AS


    SET NOCOUNT ON

    /*
    ** Declarations.
    */
    DECLARE @retcode            int
    DECLARE @distributor        sysname
    DECLARE @distribdb          sysname
    DECLARE @distproc           nvarchar (255)
    DECLARE @agentname          nvarchar(100)
    DECLARE @database           sysname
    DECLARE @newid              int
    DECLARE @mergepublish_bit   smallint
    DECLARE @centralpublish_bit int
    DECLARE @fFoundPublication  int
    DECLARE @agent_args         nvarchar(4000)
    DECLARE @snapshot_jobid     binary(16)
    DECLARE @dist_rpcname       sysname
    DECLARE @publication_type   int
    DECLARE @job_existing       bit

    /*
    ** Initializations
    */
    select @mergepublish_bit    = 4
    select @centralpublish_bit  = 1
    select @fFoundPublication   = 0
    if (@snapshot_job_name is null) or (@snapshot_job_name = N'')
    begin
        select @job_existing = 0
    end 
    else
    begin
        select @job_existing = 1
    end

    EXEC @retcode = dbo.sp_helppublication @publication, @fFoundPublication output

    IF @@ERROR <> 0 OR @retcode <> 0
    BEGIN
        RETURN (1)
    END
        
    IF @fFoundPublication = 0 
    BEGIN
        SELECT @newagentid = 0
        RETURN (0)
    END

        
    /* 
    ** Make sure the publication does not already have a agent.
    */
    IF EXISTS (SELECT * FROM syspublications WHERE name = @publication and snapshot_jobid <> NULL)
    BEGIN
        RAISERROR (14101, 11, -1, @publication)
        RETURN(1)
    END

    /* Get publication_type */
    SELECT @publication_type = repl_freq from syspublications WHERe name = @publication
    
    /*
    ** Get distributor information
    */
    EXEC @retcode = dbo.sp_helpdistributor @distributor = @distributor OUTPUT, 
        @distribdb = @distribdb OUTPUT,
        @rpcsrvname = @dist_rpcname OUTPUT
    IF @@error <> 0 OR @retcode <> 0 or @distributor IS NULL OR @distribdb IS NULL
    BEGIN
        RAISERROR (14071, 16, -1)
        RETURN (1)
    END

    SELECT @database = DB_NAME()

    SELECT @distproc = RTRIM(@dist_rpcname) + '.' + @distribdb + '.dbo.sp_MSadd_snapshot_agent'
    
    SELECT @agent_args = '-Publisher ' + QUOTENAME(@@SERVERNAME)
    SELECT @agent_args = @agent_args + ' -PublisherDB ' + QUOTENAME(@database)
    SELECT @agent_args = @agent_args + ' -Distributor ' + QUOTENAME(@distributor)
    SELECT @agent_args = @agent_args + ' -Publication ' + QUOTENAME(@publication)

    BEGIN TRAN

    EXECUTE @retcode = @distproc 
        @name = @snapshot_job_name,
        @publisher = @@SERVERNAME,
        @publisher_db = @database,
        @publication = @publication,  
        @publication_type = @publication_type,
        @local_job = 1,  

        @freqtype = @freqtype, 
        @freqinterval = @freqinterval, 
        @freqsubtype = @freqsubtype, 
        @freqsubinterval = @freqsubinterval, 
        @freqrelativeinterval = @freqrelativeinterval, 
        @freqrecurrencefactor = @freqrecurrencefactor, 
        @activestartdate = @activestartdate, 
        @activeenddate = @activeenddate, 
        @activestarttimeofday = @activestarttimeofday, 
        @activeendtimeofday =  @activeendtimeofday,
        @command = @agent_args,
        @snapshot_jobid = @snapshot_jobid OUTPUT,
        @job_existing = @job_existing
  
   IF @@ERROR <> 0 or @retcode <> 0
        GOTO UNDO

    -- Legacy, use non zero taskid to indicate agent already created at the distributor.
    UPDATE syspublications set snapshot_jobid =  @snapshot_jobid
        WHERE name =  @publication 

    IF @@ERROR <> 0 
        GOTO UNDO

    -- This is the output parameter to indicate agent created.
    SELECT  @newagentid = 1
 
    COMMIT TRAN

    return (0)  
    
UNDO:
    if @@TRANCOUNT = 1
        ROLLBACK TRAN
    else
        COMMIT TRAN
    return(1)
GO
 
EXEC dbo.sp_MS_marksystemobject sp_MSaddpub_snapshot
GO

dump tran master with no_log
GO

/*
** SyncTran support procs
*/

print ''
print 'Creating procedure sp_MSis_pk_col'
go
create proc sp_MSis_pk_col @source_table sysname, @colname sysname, @indid int
as
begin

    declare @indkey int
    select @indkey = 1

    while @indkey < 16 and index_col(@source_table, @indid, @indkey) is not null
    begin
        if index_col(@source_table, @indid, @indkey) = @colname
            return (1)

        select @indkey = @indkey + 1
    end

    return (0)
end
GO
EXEC dbo.sp_MS_marksystemobject sp_MSis_pk_col
GO

print ''
print 'Creating procedure sp_MSmark_proc_norepl'
go

create procedure sp_MSmark_proc_norepl
    @procname nvarchar(517)
as
    set nocount on

    -- CHECK PERMISSIONS (MUST BE DBO) --
    if not (is_member('db_owner')=1 or is_srvrolemember('sysadmin') = 1) 
    begin
        raiserror(20521,0,1)
        return 1
    end

    -- CHECK THE OBJECT NAME --
    if object_id(@procname, 'local') is null
    begin
        raiserror(20522,0,1,@procname)
        return 1
    end

    -- DO THE UPDATE --
    begin tran
    exec dbo.sp_replupdateschema @procname
    update sysobjects set replinfo = replinfo | 0x40
                        where id = object_id(@procname, 'local')
    exec dbo.sp_replupdateschema @procname
    commit tran
    return @@error 
go

EXEC dbo.sp_MS_marksystemobject sp_MSmark_proc_norepl
GO

create procedure sp_MSdrop_expired_subscription
AS
/*
** This stored procedure is to periodically check the status of all the subscriptions 
** of every merge publication. If any of them is out-of-date, i.e., has lost contact
** with publisher for a certain length of time, we can declare the death of that replica
** and cleanup their traces at the publisher side
*/
declare @independent_agent  bit
declare @article            sysname
declare @publication        sysname
declare @pubid              int
declare @artid              int
declare @publisher          sysname
declare @subscriber         sysname
declare @subscriber_id      smallint
declare @subscriber_db      sysname
declare @publisher_db       sysname
declare @out_of_date        int
declare @distributor        sysname
declare @distribdb          sysname
declare @retention          int  -- in days         
declare @retcode            smallint
declare @distproc           nvarchar(255)
declare @localproc          nvarchar(255)
declare @msg                nvarchar(255)
declare @open_cursor        nvarchar(400)

    /*
    ** Security Check
    */
EXEC @retcode = dbo.sp_MSreplcheck_publish
    IF @@ERROR <> 0 or @retcode <> 0
        return (1)

    /*
    ** Get distribution server information for remote RPC call.
    */
EXECUTE @retcode = dbo.sp_helpdistributor @rpcsrvname = @distributor OUTPUT,
     @distribdb   = @distribdb OUTPUT
IF @@ERROR <> 0 or @retcode <> 0
    BEGIN
        RAISERROR (20036, 16, -1)
        return (1)
    END

    
SELECT @distproc = RTRIM(@distributor) + '.' + RTRIM(@distribdb) + '.dbo.sp_MShelp_subscription_status '
select @publisher = @@SERVERNAME
select @publisher_db = db_name()

declare PC CURSOR LOCAL FAST_FORWARD for select DISTINCT name, pubid, independent_agent, retention from syspublications p
    open PC
    fetch PC into @publication, @pubid, @independent_agent, @retention
    WHILE (@@fetch_status <> -1)
        BEGIN
            -- Don't do anything if the retention is zero, this means
            -- subscriptions to the publication will never expire
            IF @retention = 0
            BEGIN
                GOTO ZERO_RETENTION
            END
            declare SC CURSOR LOCAL FAST_FORWARD for select s.srvid, s.dest_db, a.name from syssubscriptions s, sysextendedarticlesview a 
                where a.pubid= @pubid and s.artid = a.artid and s.srvid<>-1 
                for read only
            open SC
            fetch SC into @subscriber_id, @subscriber_db, @article
            WHILE (@@fetch_status <> -1)
                BEGIN
                    select @subscriber=srvname from master..sysservers where srvid=@subscriber_id
                    exec @retcode = @distproc @publisher = @publisher, 
                                    @publisher_db = @publisher_db, 
                                    @publication = @publication, 
                                    @subscriber = @subscriber, 
                                    @subscriber_db = @subscriber_db,
                                    @retention = @retention,
                                    @out_of_date = @out_of_date OUTPUT,
                                    @independent_agent = @independent_agent
                    if @retcode<>0 or @@ERROR<>0 
                        begin
                            close SC
                            deallocate SC
                            close PC
                            deallocate PC
                            return (1)
                        end
                    IF (@out_of_date = 1)
                        begin
                            exec @retcode = dbo.sp_dropsubscription   -- publisher_db.dbo.sp_dropsubscription
                                @publication = @publication,
                                @article = @article,
                                @subscriber = @subscriber,
                                @destination_db = @subscriber_db,
                                @reserved = 'internal'
                            if @retcode <>0 or @@ERROR<>0
                                begin
                                    close SC
                                    deallocate SC
                                    close PC
                                    deallocate PC
                                    return (1)
                                end
                            raiserror(14157, 10, -1, @subscriber, @publication) 
                        end
                    fetch SC into @subscriber_id, @subscriber_db, @article
                END
            CLOSE SC
            DEALLOCATE SC
    ZERO_RETENTION:
            fetch PC into @publication, @pubid, @independent_agent, @retention
        END
    CLOSE PC
    DEALLOCATE PC

GO
EXEC dbo.sp_MS_marksystemobject sp_MSdrop_expired_subscription
go


-- synctran supporting procs
raiserror('Creating procedure sp_MSscript_validate_subscription', 0,1)
go
create procedure sp_MSscript_validate_subscription (
    @publication sysname,
	@article sysname)
as
BEGIN
    declare @cmd          nvarchar(4000)
	declare @pubid int
	declare @artid int
	select @pubid = pubid from syspublications where name = @publication
	select @artid = artid from sysarticles where pubid = @pubid and name = @article

	select @cmd = N'
	' + N'--
	' + N'-- Check for subscription validation
	' + N'--
	exec @retcode = dbo.sp_MSvalidate_subscription @orig_server, @orig_db, '
			+ convert(nvarchar(10), @artid) + N'
	if (@retcode != 0 or @@error != 0)
		return -1'

    insert into #proctext(procedure_text) values(@cmd)
	return 0		
END                    
go
EXEC dbo.sp_MS_marksystemobject sp_MSscript_validate_subscription
GO


-- synctran supporting procs
raiserror('Creating procedure sp_MSvalidate_subscription', 0,1)
go
create procedure sp_MSvalidate_subscription
    @subscriber sysname,
	@subscriber_db sysname,
	@artid int
as
 
	declare @srvid smallint
	select @srvid = srvid from master..sysservers where UPPER(srvname) = UPPER(@subscriber) collate database_default
	if not exists (select * from syssubscriptions where artid = @artid and 
		srvid = @srvid and dest_db = @subscriber_db)
	begin
		--  The subscription has been dropped from the publisher. Please run sp_subscription_cleanup to cleanup the triggers.
		exec sp_MSreplraiserror 21161
		return -1
	end                    
go
EXEC dbo.sp_MS_marksystemobject sp_MSvalidate_subscription
GO


raiserror('Creating procedure sp_MSscript_insert_statement', 0,1)
go
create procedure sp_MSscript_insert_statement(
    @objid int,
    @columns binary(32),
	@identity_insert bit = 0,
	@queued_pub bit = 0
	)
as
BEGIN
	declare @cmd          nvarchar(4000)
	declare @qualname     nvarchar(512)
	declare @colname      sysname
	declare @ccoltype     sysname
	declare @this_col     int
	declare @rc           int
	declare @num_col	  int
	declare @column_string nvarchar(4000)
			,@var_string nvarchar(4000)
	
    
	exec sp_MSget_qualified_name @objid, @qualname OUTPUT

	--
	-- start scripting
	--
	select @cmd = N'
	' + N'--
	' + N'-- detection/conflict resolution stage
	' + N'--'
	
	if (@queued_pub = 1)
	begin
		select @cmd = @cmd + N'
	if (@execution_mode = @QPubWins)
		save tran cftpass'
	end
	insert into #proctext(procedure_text) values( @cmd) 
    
	--
	-- set indentity_insert on
	--
	if @identity_insert = 1
	begin
		-- Only to call set if identity is not marked for 'not for repl'
		-- This is to avoid security failure of 'SET' for PAL users
		if not exists (select * from syscolumns where id = @objid and
			ColumnProperty(id, name, 'IsIdNotForRepl') = 1)
		begin
			select @cmd = N'
	set identity_insert ' + @qualname + ' on'
			insert into #proctext(procedure_text) values( @cmd )
		end
	end

	--
	-- prepare the insert statement now
	--
	select @cmd = N'
	insert into ' + @qualname + N'( '
	insert into #proctext(procedure_text) values( @cmd )
	-- Generate strings for col names and variables
	select @num_col = 0
	select @cmd = N''

	DECLARE hCColid CURSOR LOCAL FAST_FORWARD FOR 
	select colid from syscolumns where id = @objid order by colid asc

	OPEN hCColid

	FETCH hCColid INTO @this_col

	WHILE (@@fetch_status != -1)
	begin
		exec @rc = dbo.sp_MSget_colinfo @objid, @this_col, @columns, 0, @colname output, @ccoltype output
		if @rc = 0  and EXISTS (select name from syscolumns where id=@objid and colid=@this_col and iscomputed<>1)
		begin
            if rtrim(@ccoltype) not like N'timestamp' and 
				not (ColumnProperty(@objid, @colname, 'IsIdentity') = 1 and 
					@identity_insert = 0)
            begin
				select @num_col = @num_col + 1
				if @num_col > 1
					select @cmd = @cmd + N', '
				select @cmd = @cmd + QUOTENAME(@colname)			
				exec dbo.sp_MSflush_command @cmd output, 1
			end
		end
		FETCH hCColid INTO @this_col
	end
	CLOSE hCColid

	-- Script end of colmn names
	select @cmd = N' )'
	insert into #proctext(procedure_text) values( @cmd )

	
	-- Script column value string
	if @num_col > 0
	begin
		select @cmd = N'
	values ( '
		insert into #proctext(procedure_text) values( @cmd )
		-- Script column value string
		select @num_col = 0
		select @cmd = N''

		OPEN hCColid

		FETCH hCColid INTO @this_col

		WHILE (@@fetch_status != -1)
		begin
			exec @rc = dbo.sp_MSget_colinfo @objid, @this_col, @columns, 0, @colname output, @ccoltype output
			if @rc = 0  and EXISTS (select name from syscolumns where id=@objid and colid=@this_col and iscomputed<>1)
			begin
				if rtrim(@ccoltype) not like N'timestamp' and 
					not (ColumnProperty(@objid, @colname, 'IsIdentity') = 1 and 
						@identity_insert = 0)
				begin
					select @num_col = @num_col + 1
					if @num_col > 1
						select @cmd = @cmd + N', '
					select @cmd = @cmd + N'@c' + cast(@this_col as nvarchar(4))				
					exec dbo.sp_MSflush_command @cmd output, 1
				end
			end
			FETCH hCColid INTO @this_col
		end
		CLOSE hCColid
		
		-- Script end of column value string
		select @cmd = N' )
	'
		insert into #proctext(procedure_text) values( @cmd )
	end
	else
	begin
		-- This is to set @@rowcount.
		insert into #proctext(procedure_text) values( N' 
	select @retcode = @retcode')
	end
	
	--
	-- set the rowcount and error
	--
	select @cmd = N'
	select @rowcount = @@ROWCOUNT, @error = @@ERROR 
	'
	insert into #proctext(procedure_text) values( @cmd )

	--
	-- set indentity_insert off
	--
	if @identity_insert = 1
	begin
		-- Only to call set if identity is not marked for 'not for repl'
		-- This is to avoid security failure of 'SET' for PAL users
		if not exists (select * from syscolumns where id = @objid and
			ColumnProperty(id, name, 'IsIdNotForRepl') = 1)
		begin
			select @cmd = N'
	set identity_insert ' + @qualname + ' off'
			insert into #proctext(procedure_text) values( @cmd )
		end
	end


	if (@queued_pub = 1)
	begin
		select @cmd = N'
	if (@execution_mode = @QPubWins)
		rollback tran cftpass'
		insert into #proctext(procedure_text) values( @cmd )
	end
	
	--
	-- all done 
	-- 
	return 0
END
go

EXEC dbo.sp_MS_marksystemobject sp_MSscript_insert_statement
GO

--
-- sp_script_insertforcftresolution
--
-- Owner: KaushikC
--
-- Description: this stored procedure is used for scripting of synctran 
-- procedures and scripts the code that generates the insert command 
-- to resolve conflicts in a subscriber wins resolution. It is used by
-- sp_script_insert_subwins, sp_script_update_subwins
-- Executed on publisher database.
--
-- Parameters:  
--		as defined in the create proc statement
--
-- Results:
--	SQL script specific to the article
--
-- Returns:
-- 		0 if success
--		1 if failure
--
-- Security: internal helper procedure - not granted to public 
--
raiserror('Creating procedure sp_script_insertforcftresolution', 0,1)
go
create procedure sp_script_insertforcftresolution 
(
	@objid int				-- object id
	,@columns binary(32)		-- columns replicated
	,@identity_insert bit		-- enable identity insert
	,@prefix nvarchar(10)=N'@c' -- prefix
	,@suffix nvarchar(10)=NULL  -- suffix
)
as
begin
	declare @cmd nvarchar(4000)
			,@qualname nvarchar(512)
			,@column_string nvarchar(4000)
			,@var_string nvarchar(4000)
			,@colname      sysname
			,@ccoltype     sysname
			,@this_col     int
			,@rc           int
			,@num_col	  int
	declare @worktab  table( c1 int identity NOT NULL, procedure_text nvarchar(4000) collate database_default null)
	declare @worktab2 table( c1 int identity NOT NULL, procedure_text nvarchar(4000) collate database_default null)

	--
	-- initialize
	--
	exec sp_MSget_qualified_name @objid, @qualname OUTPUT
	--
	-- prepare the assignments and column list for 
	-- insert statement  
	--
	select @num_col = 0
	DECLARE hCColid CURSOR LOCAL FAST_FORWARD FOR 
	select colid from syscolumns where id = @objid order by colid asc

	OPEN hCColid
	FETCH hCColid INTO @this_col
	WHILE (@@fetch_status != -1)
	begin
		exec @rc = dbo.sp_MSget_colinfo @objid, @this_col, @columns, 0, @colname output, @ccoltype output
		if @rc = 0  and EXISTS (select name from syscolumns where id=@objid and colid=@this_col and iscomputed<>1)
		begin
			if rtrim(@ccoltype) not like N'timestamp' 
			begin
				select @num_col = @num_col + 1
					,@column_string = quotename(@colname)
					,@var_string = @prefix + cast(@this_col as nvarchar(4))
				if (@suffix is not null)
					select @var_string = @var_string + @suffix
				
				if (@num_col > 1)
				begin
					select @column_string = N', ' + @column_string
						,@var_string = N', ' +@var_string 
				end
				insert into @worktab(procedure_text) values( @column_string )				
				insert into @worktab2(procedure_text) values( @var_string )				
			end
		end
		FETCH hCColid INTO @this_col
	end
	CLOSE hCColid
	DEALLOCATE hCColid

	if (@num_col > 0)
	begin
		if (@identity_insert = 1)
		begin
			-- Only to call set if identity is not marked for 'not for repl'
			-- This is to avoid security failure of 'SET' for PAL users
			if not exists (select * from syscolumns where id = @objid and
				ColumnProperty(id, name, 'IsIdNotForRepl') = 1)
			begin
				select @cmd = N'
			set identity_insert ' + @qualname + N' on '
				insert into #proctext(procedure_text) values( @cmd )
			end
		end

		select @cmd = N'
			insert into ' + @qualname + N'( '
		insert into #proctext(procedure_text) values( @cmd )
		insert into #proctext(procedure_text) 
			select procedure_text from @worktab order by c1 asc
		select @cmd = N' )
			values ( '
		insert into #proctext(procedure_text) values( @cmd )
		insert into #proctext(procedure_text) 
			select procedure_text from @worktab2 order by c1 asc
		select @cmd = N' )'
		insert into #proctext(procedure_text) values( @cmd )

		if (@identity_insert = 1)
		begin
			-- Only to call set if identity is not marked for 'not for repl'
			-- This is to avoid security failure of 'SET' for PAL users
			if not exists (select * from syscolumns where id = @objid and
				ColumnProperty(id, name, 'IsIdNotForRepl') = 1)
			begin
				select @cmd = N'
			set identity_insert ' + @qualname + N' off '
				insert into #proctext(procedure_text) values( @cmd )
			end
		end
	end
	--
	-- all done
	-- 
	return 0
end
go
exec dbo.sp_MS_marksystemobject sp_script_insertforcftresolution
go

--
-- sp_MSscript_insert_subwins
--
-- Owner: KaushikC
--
-- Description: this stored procedure is used for scripting of synctran 
-- procedures and scripts the code that generates the compensating 
-- commands to resolve all the conflicts in a subscriber wins resolution 
-- policy for INSERT commands. Executed on publisher database.
--
-- Parameters:  
--		as defined in the create proc statement
--
-- Results:
--	SQL script specific to the article
--
-- Returns:
-- 		0 if success
--		1 if failure
--
-- Security: internal helper procedure - not granted to public 
--
raiserror('Creating procedure sp_MSscript_insert_subwins', 0,1)
go
create procedure sp_MSscript_insert_subwins 
(
	@publication sysname		-- publication name
	,@article sysname			-- article name
	,@objid int				-- object id
	,@columns binary(32)		-- columns replicated
	,@identity_insert bit		-- enable identity insert
)
as
begin
	declare @cmd nvarchar(4000)
			,@qualname nvarchar(512)
			,@rc           int
			,@fhasnonpkuniquekeys int

	exec sp_MSget_qualified_name @objid, @qualname OUTPUT
	--
	--  check if this article has non PK unique keys
	--
	exec @fhasnonpkuniquekeys = dbo.sp_repltablehasnonpkuniquekey @tabid = @objid
	--
	-- start scripting
	--
	select @cmd = N'
	if (@execution_mode = @QSubWins)
	begin
		'+N'--
		'+N'-- Subscriber wins resolution
		'+N'-- '
	insert into #proctext(procedure_text) values( @cmd )
	--
	-- script this block if the article has non PK unique keys
	--
	if (@fhasnonpkuniquekeys = 1)
	begin
		select @cmd = N'
		if (@cftcase = 22)
		begin
			'+N'--
			'+N'-- delete rows with values of non PK keys
			'+N'-- '
		insert into #proctext(procedure_text) values( @cmd )
		--
		-- script delete rows with values for non PK keys
		--
		select @cmd = N'
			delete ' + @qualname 
		insert into #proctext(procedure_text) values( @cmd )
		exec @rc = sp_replscriptuniquekeywhereclause @tabid = @objid
					,@columns = @columns
					,@prefix = N'@c' 
					,@suffix = NULL
					,@mode = 7
		--
		-- continue scripting
		--
		select @cmd = N'
		end'
		insert into #proctext(procedure_text) values( @cmd )
	end
	--
	-- continue scripting
	--
	select @cmd = N'
		if (@cftcase = 21)
		begin
			'+N'--
			'+N'-- delete rows with values of all keys
			'+N'-- '
	insert into #proctext(procedure_text) values( @cmd )
	--
	-- script delete rows with values of all keys 
	--
	select @cmd = N'
			delete ' + @qualname 
	insert into #proctext(procedure_text) values( @cmd )
	exec @rc = sp_replscriptuniquekeywhereclause @tabid = @objid
				,@columns = @columns
				,@prefix = N'@c' 
				,@suffix = NULL
				,@mode = 6
	--
	-- continue scripting
	--
	select @cmd = N'
		end
		if (@cftcase in (21,22))
		begin
			'+N'--
			'+N'-- insert row
			'+N'-- '
	insert into #proctext(procedure_text) values( @cmd )
	--
	-- script insert row  
	--
	exec @rc = sp_script_insertforcftresolution 
			@objid = @objid
			,@columns = @columns
			,@identity_insert = @identity_insert
			,@prefix = N'@c'
			,@suffix = NULL
	--
	-- continue scripting
	--
	select @cmd = N'
		end

		'+N'--
		'+N'-- --------------------------------------------------------------------
		'+N'-- all done for conflict resolution for Subscriber Wins policy
		'+N'-- --------------------------------------------------------------------
		'+N'--
	end'
	insert into #proctext(procedure_text) values( @cmd )
	--
	-- all done
	--
	return 0
end
go
exec dbo.sp_MS_marksystemobject sp_MSscript_insert_subwins
go

--
-- proc to test if we need to turn on identity insert
--
raiserror('Creating procedure sp_MSis_identity_insert', 0,1)
go
create procedure sp_MSis_identity_insert
@publication sysname,
@article sysname,
@identity_insert bit output,
@artid int = NULL	-- If pass in @artid, you don't need to pass in 
					-- @publication and @article
as
	declare @pubid int, @source_objid int
		,@columns      binary(32)
	
	select @identity_insert = 0

	-- Get @artid if not there
	-- If the publication is not queued
	if @artid is null
	begin
		select @pubid = pubid from syspublications where name = @publication
		select @artid = artid from sysarticles where
			pubid = @pubid and
			name = @article
	end		

	-- Get @pubid from @artid
	if @pubid is null
		select @pubid = pubid	from sysarticles where 
			artid = @artid

	if exists (select * from syspublications where
		pubid = @pubid and
		allow_queued_tran = 1)
	begin
		select @source_objid = objid, @columns = columns from sysarticles where
			artid = @artid and
			OBJECTPROPERTY(objid, 'tablehasidentity') = 1
		if @source_objid is not null
		begin
			declare @colid smallint, @in_partition int
			select @colid = colid from syscolumns where id = @source_objid and
				COLUMNPROPERTY(@source_objid, name, 'IsIdentity') = 1
			exec @in_partition = sp_isarticlecolbitset @colid, @columns
			if @in_partition = 1
				select @identity_insert = 1
		end
	end
	return @identity_insert
go

EXEC dbo.sp_MS_marksystemobject sp_MSis_identity_insert
GO

--
-- proc that scripts the sending of a compensating command
-- used by the compensating code generation SPs
--
raiserror('Creating procedure sp_MSscript_compensating_send', 0,1)
go
create procedure sp_MSscript_compensating_send (
	@pubid int,
	@artid int,
	@cmdstate int = 0,
	@setprefix bit = 1)
AS
BEGIN
	declare @cmd nvarchar(4000)
	
	select @cmd = N'
			' + N'--
			' + N'-- sending of compensating command
			' + N'--'
	insert into #proctext(procedure_text) values( @cmd )

	select @cmd = N'
			exec @retcode = dbo.sp_MSadd_compensating_cmd
				@orig_srv = @orig_server
				,@orig_db = @orig_db
				,@command = @cmd
				,@article_id = ' + CAST(@artid as nvarchar(4)) + N'
				,@publication_id = ' + CAST(@pubid as nvarchar(4)) + N'
				,@cmdstate = ' + CAST(@cmdstate as nvarchar(4)) + N'
				,@mode = 0
				,@setprefix = ' + CAST(@setprefix as nvarchar(4))
	insert into #proctext(procedure_text) values( @cmd )

	select @cmd = N'
			if (@@error != 0 or @retcode != 0)
				return -1'
	insert into #proctext(procedure_text) values( @cmd )

	--
	-- all done
	--
	return 0	
END
go

EXEC dbo.sp_MS_marksystemobject sp_MSscript_compensating_send
GO

--
-- sp_MSscriptinsertconflictfinder
--
-- Owner: KaushikC
--
-- Description: this stored procedure is used for scripting of synctran procedures
-- and scripts the code that is a state machine and finds the exact nature of conflict
-- for INSERT operations and then assigns it a unique conflict identity.  
-- Executed on publisher database.
--
-- Parameters:  
--		as defined in the create proc statement
--
-- Results:
--	SQL script specific to the article
--
-- Returns:
-- 		0 if success
--		1 if failure
--
-- Security: internal helper procedure - not granted to public 
--
raiserror('Creating procedure sp_MSscriptinsertconflictfinder', 0,1)
go
create procedure sp_MSscriptinsertconflictfinder 
(
	@publication sysname		-- publication name
	,@article sysname			-- article name
	,@objid int				-- object id
	,@columns binary(32)		-- columns replicated
)
as
begin
	declare 
			@rc int
			,@cmd nvarchar(4000)
			,@artid int
			,@pubid int
			,@qualname nvarchar(512)
			,@fhasnonpkuniquekeys int

	--
	-- initialize the vars we will use
	--
	select @pubid = pubid 
	from syspublications 
	where name = @publication
	select @artid = artid
	from sysarticles 
	where name = @article 
		and pubid = @pubid
	exec sp_MSget_qualified_name @objid, @qualname OUTPUT
	--
	--  check if this article has non PK unique keys
	--
	exec @fhasnonpkuniquekeys = dbo.sp_repltablehasnonpkuniquekey @tabid = @objid
	--
	-- start scripting
	--
	select @cmd = N'
	
	'+N'--
	'+N'-- --------------------------------------------------------------------
	'+N'-- This is the crux of the proc for conflict resolution 
	'+N'-- This code block is essentially a state machine
	'+N'-- where we ascertain the state of resolution
	'+N'-- The actions of this resolution varies for the policy
	'+N'-- The comments for each state outline the policy
	'+N'-- specific actions 
	'+N'-- --------------------------------------------------------------------
	'+N'--'
	insert into #proctext(procedure_text) values( @cmd )
	--
	-- continue scripting
	--
	select @cmd = N'
	if (@execution_mode in (@QPubWins, @QSubWins))
	begin
		'+N'--
		'+N'-- initialize the conflict case
		'+N'--
		select @cftcase = 0

		if (@rowcount = 0)
		begin
			'+N'--
			'+N'-- we had conflict for this command
			'+N'--
			if (@error in (547, 2601, 2627))
			begin'
	insert into #proctext(procedure_text) values( @cmd )
	select @cmd = N'
				'+N'--
				'+N'-- Conflict due to unique key/constraint
				'+N'--'
	insert into #proctext(procedure_text) values( @cmd )
	--
	-- script row check with PK
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
					'+N'--
					'+N'-- case 21: A row with same PK already exists
					'+N'-- PubWins -----------------------------------------------------------
					'+N'-- generate delete compensating action for row with PK
					'+N'-- generate delete + insert compensating action with values for all unique keys 
					'+N'-- SubWins -----------------------------------------------------------
					'+N'-- delete rows with values of all keys
					'+N'-- insert row with values
					'+N'--
					select @cftcase = 21 
				end'
	insert into #proctext(procedure_text) values( @cmd )
	--
	-- script this block if the article has non PK unique keys
	--
	if (@fhasnonpkuniquekeys = 1)
	begin
		select @cmd = N'
				else
				begin
					'+N'--
					'+N'-- case 22: A row with same nonPK key(s) already exists
					'+N'-- PubWins -----------------------------------------------------------
					'+N'-- generate delete compensating action for row with PK
					'+N'-- generate delete + insert compensating action with values for non PK keys 
					'+N'-- SubWins -----------------------------------------------------------
					'+N'-- delete rows with values of non PK keys
					'+N'-- insert row with values
					'+N'--
					select @cftcase = 22 
				end'
		insert into #proctext(procedure_text) values( @cmd )
	end
	--
	-- continue scripting
	--
	select @cmd = N'
			end
		end
		else if (@execution_mode = @QPubWins)
		begin
			'+N'--
			'+N'-- we had no conflict for this command
			'+N'-- We need to process this block only in the Publisher Wins cases
			'+N'--

			'+N'--
			'+N'-- case 23: No conflict
			'+N'-- PubWins -----------------------------------------------------------
			'+N'-- generate delete compensating action with PK
			'+N'-- 
			select @cftcase = 23
		end	
	end'
	insert into #proctext(procedure_text) values( @cmd )
	--
	-- continue scripting
	--
	select @cmd = N'

	'+N'--
	'+N'-- --------------------------------------------------------------------
	'+N'-- Now the generation phase
	'+N'-- Use the conflict case value to decide what to do
	'+N'-- --------------------------------------------------------------------
	'+N'--'
	insert into #proctext(procedure_text) values( @cmd )
	--
	-- all done
	--
	return 0
end
go
exec dbo.sp_MS_marksystemobject sp_MSscriptinsertconflictfinder
go

--
-- sp_MSscript_insert_pubwins
--
-- Owner: KaushikC
--
-- Description: this stored procedure is used for scripting of synctran 
-- procedures and scripts the code that generates the compensating 
-- commands to resolve all the conflicts in a publisher wins resolution 
-- policy for INSERT commands. Executed on publisher database.
--
-- Parameters:  
--		as defined in the create proc statement
--
-- Results:
--	SQL script specific to the article
--
-- Returns:
-- 		0 if success
--		1 if failure
--
-- Security: internal helper procedure - not granted to public 
--
raiserror('Creating procedure sp_MSscript_insert_pubwins', 0,1)
go
create procedure sp_MSscript_insert_pubwins 
(
	@publication sysname		-- publication name
	,@article sysname			-- article name
	,@objid int				-- object id
	,@columns binary(32)		-- columns replicated
)
as
begin
	declare @cmd nvarchar(4000)
			,@artid int
			,@pubid int
			,@dest_table sysname
			,@dest_owner nvarchar(260)
			,@rc           int
			,@qualname nvarchar(512)
			,@fhasnonpkuniquekeys int

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
	--  check if this article has non PK unique keys
	--
	exec @fhasnonpkuniquekeys = dbo.sp_repltablehasnonpkuniquekey @tabid = @objid
	--
	-- start scripting
	--
	select @cmd = N'
	if (@execution_mode = @QPubWins)
	begin
		'+N'--
		'+N'-- Publisher wins resolution
		'+N'-- '
	insert into #proctext(procedure_text) values( @cmd )
	--
	-- declare fetch variables for cursor
	--
	exec @rc = sp_scriptpubwinsrefreshcursorvars @objid
	--
	-- continue scripting
	--
	select @cmd = N'

		'+N'--
		'+N'-- --------------------------------------------------------------------
		'+N'-- Perform single row delete generations first
		'+N'-- --------------------------------------------------------------------
		'+N'--'
	insert into #proctext(procedure_text) values( @cmd )
	--
	-- continue scripting
	--
	select @cmd = N'

		'+N'--
		'+N'-- Generate DELETE for PK
		'+N'--
		if (@cftcase in (21,22,23))
		begin'
	insert into #proctext(procedure_text) values( @cmd )
	--
	-- Generate the delete compensating code
	--
	select @cmd = N'
			select @cmd = ''DELETE ' + master.dbo.fn_MSgensqescstr(@dest_owner) collate database_default 
		+ quotename(master.dbo.fn_MSgensqescstr(@dest_table) collate database_default) + N' '' + '
	insert into #proctext(procedure_text) values( @cmd )
	exec dbo.sp_MSscript_where_clause @objid, @columns, 'qcft_comp', NULL, 0, 'ins'
	--
	-- generate the send command
	--
	exec sp_MSscript_compensating_send @pubid, @artid, 0, 1
	--
	-- continue scripting
	--
	select @cmd = N'
		end

		'+N'--
		'+N'-- --------------------------------------------------------------------
		'+N'-- Perform refresh(delete+insert) generations next
		'+N'-- --------------------------------------------------------------------
		'+N'--'
	insert into #proctext(procedure_text) values( @cmd )
	--
	-- script this block if the article has non PK unique keys
	--
	if (@fhasnonpkuniquekeys = 1)
	begin
		select @cmd = N'

		'+N'--
		'+N'-- Generate delete+insert for values of non PK keys
		'+N'--
		if (@cftcase = 22)
		begin'
		insert into #proctext(procedure_text) values( @cmd )
		--
		-- generate delete compensating command for values of non PK unique keys
		--
		select @cmd = N'
			select @cmd = ''DELETE ' + master.dbo.fn_MSgensqescstr(@dest_owner) collate database_default 
					+ quotename(master.dbo.fn_MSgensqescstr(@dest_table) collate database_default) + N' '' + '
		insert into #proctext(procedure_text) values( @cmd )
		exec @rc = sp_replscriptuniquekeywhereclause @tabid = @objid
					,@columns = @columns
					,@prefix = N'@c' 
					,@suffix = NULL
					,@mode = 5
		--
		-- script the sending command
		--
		exec sp_MSscript_compensating_send @pubid, @artid, 0, 1
		--
		-- script the refresh commands for values of non PK unique keys
		--
		exec @rc = dbo.sp_MSscript_compensating_insert @publication, @article, @objid, @columns, 3, 0
		if (@rc != 0 or @@error != 0)
			return 1
		--
		-- continue scripting
		--
		select @cmd = N'
		end'
		insert into #proctext(procedure_text) values( @cmd )
	end
	--
	-- continue scripting
	--
	select @cmd = N'
		'+N'--
		'+N'-- Generate delete+insert for values of all keys
		'+N'--
		if (@cftcase = 21)
		begin'
	insert into #proctext(procedure_text) values( @cmd )
	--
	-- generate delete compensating command for values of all unique keys
	--
	select @cmd = N'
			select @cmd = ''DELETE ' + master.dbo.fn_MSgensqescstr(@dest_owner) collate database_default 
		+ quotename(master.dbo.fn_MSgensqescstr(@dest_table) collate database_default) + N' '' + '
	insert into #proctext(procedure_text) values( @cmd )
	exec @rc = sp_replscriptuniquekeywhereclause @tabid = @objid
				,@columns = @columns
				,@prefix = N'@c' 
				,@suffix = NULL
				,@mode = 4
	--
	-- script the sending command
	--
	exec sp_MSscript_compensating_send @pubid, @artid, 0, 1
	--
	-- script the refresh commands for values of all unique keys
	--
	exec @rc = dbo.sp_MSscript_compensating_insert @publication, @article, @objid, @columns, 5, 0
	if (@rc != 0 or @@error != 0)
		return 1
	--
	-- continue scripting
	--
	select @cmd = N'
		end
		'+N'--
		'+N'-- --------------------------------------------------------------------
		'+N'-- all done for conflict resolution for Publisher Wins policy
		'+N'-- --------------------------------------------------------------------
		'+N'--
	end'
	insert into #proctext(procedure_text) values( @cmd )
	--
	-- all done
	--
	return 0
end
go
exec dbo.sp_MS_marksystemobject sp_MSscript_insert_pubwins
go

raiserror('Creating procedure sp_MSscript_update_statement', 0,1)
go
create procedure sp_MSscript_update_statement (
	@publication sysname,
	@article     sysname, 
	@objid int,
	@columns binary(32),
	@queued_pub bit = 0
)
as
BEGIN
	declare @cmd			nvarchar(4000)
			,@cmd2			nvarchar(4000)
			,@qualname		nvarchar(512)
			,@colname		sysname
			,@typestring	nvarchar(4000)
			,@spacer		nvarchar(1)
			,@ccoltype		sysname
			,@this_col		int
			,@rc			int
			,@column		nvarchar(4000)
			,@num_col		int
			,@bitstr nvarchar(20)
			,@bytestr nvarchar(20)
			,@art_col		int -- position in the article partition.
			,@isset			int
			,@timestamp_subscribed bit
			,@pubid			int

	select @pubid = pubid from syspublications where name = @publication

	if exists (select * from sysarticles where pubid = @pubid and
		name = @article and
		status & 32 <> 0)
		select @timestamp_subscribed = 1
	else
		select @timestamp_subscribed = 0
	
	--
	-- Start scripting
	--
	select @cmd = N'
	' + N'--
	' + N'-- detection/conflict resolution stage
	' + N'--'
	
	if (@queued_pub = 1)
	begin
		select @cmd = @cmd + N'
	if (@execution_mode = @QPubWins)
		save tran cftpass
	'
	end
	insert into #proctext(procedure_text) values(@cmd)
	
	--
	-- Generate the update statement
	--
	exec sp_MSget_qualified_name @objid, @qualname OUTPUT
	select @cmd2 = N'
	update ' + @qualname + N' set
	'

	select @spacer = N' 
		'
	select @cmd = N''
	exec dbo.sp_MSpad_command @cmd output, 8
	
	select @num_col = 0
	select @art_col = 0

	DECLARE hCColid CURSOR LOCAL FAST_FORWARD FOR 
	select colid from syscolumns where id = @objid order by colid asc

	OPEN hCColid
	FETCH hCColid INTO @this_col
	WHILE (@@fetch_status <> -1)
	begin
		-- Get the ordinal of the article partition or not.
		exec @isset = dbo.sp_isarticlecolbitset @this_col, @columns
		if @isset = 0
		begin
			-- Special handling of a timestamp col in a queued tran publication
			-- See sp_helparticlecolumns : xtype 189 is timestamp
			if ((@timestamp_subscribed = 1) and 
					exists ( select * from dbo.syscolumns where id = @objid and colid = @this_col and xtype = 189))
				select @art_col = @art_col + 1
		end
		else
			select @art_col = @art_col + 1

		exec @rc = dbo.sp_MSget_colinfo @objid, @this_col, @columns, 0, @colname output, @ccoltype output
		if @rc = 0 and EXISTS (select name from syscolumns where id=@objid and colid=@this_col and iscomputed<>1)
		begin
			if rtrim(@ccoltype) not like N'timestamp' and ColumnProperty(@objid, @colname, 'IsIdentity') != 1
			begin
				if @cmd2 is not null
				begin
					exec dbo.sp_MSflush_command @cmd2 output, 1, 8
					select @cmd2 = null
				end

				select @num_col = @num_col + 1
				-- Optimization:
				-- Get null or actual column name
				-- Note: the output is quoted.
				exec dbo.sp_MSget_synctran_column 
					@ts_col = null,
					@op_type = null , -- 'ins, 'upd', 'del'
					@is_new = null,
					@primary_key_bitmap = null,
					@colname = @colname,
					@this_col = @this_col,
					@column = @column output,
					@from_proc = 1,
					@art_col = @art_col -- position in the partition.

				select @cmd = @cmd + @spacer + QUOTENAME(@colname) + N' = ' + @column 			    
				select @spacer = N','

				--
				-- flush command if necessary
				--
				exec dbo.sp_MSflush_command @cmd output, 1, 8
			end
		end
		FETCH hCColid INTO @this_col
	end
	CLOSE hCColid
	DEALLOCATE hCColid

	-- save off cmd fragment
	if @num_col > 0
	begin
		--
		-- Add the where clause based on the update mode
		--
		select @colname = 'msrepl_tran_version'
		exec dbo.sp_MSscript_where_clause @objid, @columns, 'upd version', @colname, 4
	end 
	else
	-- set the @@rowcount
		insert into #proctext(procedure_text) values( N' select @retcode = @retcode
	')

	--
	-- continue with rest of scripting
	--
	select @cmd = N'
	select @rowcount = @@ROWCOUNT, @error = @@ERROR
	'

	if (@queued_pub = 1)
	begin
		select @cmd = @cmd + N'
	if (@execution_mode = @QPubWins)
		rollback tran cftpass'
	end
	insert into #proctext(procedure_text) values(@cmd)
	--
	-- Queued specific case
	--
	if (@queued_pub = 1)
	begin
		--
		-- script the assignment of new values based on bitmask
		--
		select @num_col = 0
				,@art_col = 0
				,@cmd = N'
	' + N'--
	' + N'-- for conflict resolution - assign the NEW values based on bitmap
	' + N'--
	if (@execution_mode in (@QPubWins, @QSubWins))
	begin 	
		select '
		insert into #proctext(procedure_text) values(@cmd)	

		DECLARE hCColid CURSOR LOCAL FAST_FORWARD FOR 
			select colid from dbo.syscolumns where id = @objid order by colid asc

		OPEN hCColid
		FETCH hCColid INTO @this_col
		WHILE (@@fetch_status != -1)
		begin
			-- Get the ordinal of the article partition or not.
			exec @isset = dbo.sp_isarticlecolbitset @this_col, @columns
			if @isset = 0
			begin
				if ((@timestamp_subscribed = 1) and 
						exists ( select * from dbo.syscolumns where id = @objid and colid = @this_col and xtype = 189))
					select @art_col = @art_col + 1
			end
			else
				select @art_col = @art_col + 1

			exec @rc = dbo.sp_MSget_colinfo @objid, @this_col, @columns, 0, @colname output, @ccoltype output
			if ((@rc = 0) 
				and EXISTS (select name from dbo.syscolumns where id=@objid and colid=@this_col and iscomputed != 1) 
				and (rtrim(@ccoltype) != N'timestamp'))
			begin
				select @num_col = @num_col + 1
						,@bytestr = cast((1 + (@art_col-1) / 8 ) as nvarchar)
						,@bitstr =  cast( power(2, (@art_col-1) % 8 ) as nvarchar)

				select @cmd = N'@c' + cast(@this_col as nvarchar(10)) + N' = case substring(@bitmap,' + 
					@bytestr + N',1) & ' + @bitstr + N' when ' + @bitstr + 
					N' then @c' + cast(@this_col as nvarchar(4)) + 
					N' else @c' + cast(@this_col as nvarchar(4)) + N'_old end '

				if (@num_col = 1)
				begin
					select @cmd = N'
				' + @cmd
				end
				else
				begin
					select @cmd = N'
				, ' + @cmd
				end
				insert into #proctext(procedure_text) values(@cmd)	
			end
			--
			-- fetch next row
			--
			FETCH hCColid INTO @this_col
		end
		CLOSE hCColid
		DEALLOCATE hCColid
		--
		-- continue with scripting
		--
		select @cmd = N'
	end' 	
		insert into #proctext(procedure_text) values(@cmd)	
	end
	--
	-- all done
	--
	return 0
END
go
exec dbo.sp_MS_marksystemobject sp_MSscript_update_statement
GO

--
-- sp_scriptpubwinsrefreshcursorvars
--
-- Owner: KaushikC
--
-- Description: this stored procedure is used for scripting of synctran 
-- procedures and scripts the code that generates variable declarations
-- used for compensating refresh curors in a publisher wins cases. 
-- Executed on publisher database.
--
-- Parameters:  
--		as defined in the create proc statement
--
-- Results:
--	SQL script specific to the article
--
-- Returns:
-- 		0 if success
--		1 if failure
--
-- Security: internal helper procedure - not granted to public 
--
raiserror('Creating procedure sp_scriptpubwinsrefreshcursorvars', 0,1)
go
create procedure sp_scriptpubwinsrefreshcursorvars 
(
	@objid int				-- object id
)
as
begin
	declare
			@rc           int
			,@cmd nvarchar(4000)
			,@colname      sysname
			,@ccoltype     sysname
			,@this_col     int
			,@typestring nvarchar(100)
 			,@spacer nvarchar(5)
			,@isset int
			,@pkcolumns varbinary(32)

	select @cmd = N'
		declare '
		,@spacer = N''
	exec dbo.sp_getarticlepkcolbitmap @objid, @pkcolumns output
	declare #hccolid cursor local fast_forward for 
		select colid from syscolumns where id = @objid order by colid asc
	open #hccolid
	fetch #hccolid into @this_col
	while (@@fetch_status != -1)
	begin
		exec @isset = dbo.sp_isarticlecolbitset @this_col, @pkcolumns
		if @isset != 0 and exists ( select name from syscolumns where id=@objid and colid=@this_col and iscomputed !=1 ) 
		begin
			exec dbo.sp_gettypestring @objid, @this_col, @typestring output
			select @cmd = @cmd + @spacer + N'@pkc' + convert( nvarchar, @this_col ) + N' ' + @typestring 
					,@spacer = N','

			if len( @cmd ) > 3000
			begin
				insert into #proctext(procedure_text) values( @cmd )
				select @cmd = N''
			end
		end
		fetch #hccolid into @this_col
	end
	close #hccolid
	deallocate #hccolid
	if len(@cmd) > 0
		insert into #proctext(procedure_text) values( @cmd )
	--
	-- all done
	--
	return 0
end
go
exec dbo.sp_MS_marksystemobject sp_scriptpubwinsrefreshcursorvars
go

--
--
-- sp_MSscript_update_subwins
--
-- Owner: KaushikC
--
-- Description: this stored procedure is used for scripting of synctran 
-- procedures and scripts the code that generates the compensating 
-- commands to resolve all the conflicts in a subscriber wins resolution 
-- policy. Executed on publisher database.
--
-- Parameters:  
--		as defined in the create proc statement
--
-- Results:
--	SQL script specific to the article
--
-- Returns:
-- 		0 if success
--		1 if failure
--
-- Security: internal helper procedure - not granted to public 
--
raiserror('Creating procedure sp_MSscript_update_subwins', 0,1)
go
create procedure sp_MSscript_update_subwins 
(
	@publication sysname		-- publication name
	,@article sysname			-- article name
	,@objid int				-- object id
	,@columns binary(32)		-- columns replicated
	,@identity_insert bit
)
AS
BEGIN
	declare @cmd nvarchar(4000)
			,@artid int
			,@pubid int
			,@qualname nvarchar(512)
			,@rc           int
			,@fhasnonpkuniquekeys int

	--
	-- initialize the vars we will use
	--
	exec sp_MSget_qualified_name @objid, @qualname OUTPUT
	--
	--  check if this article has non PK unique keys
	--
	exec @fhasnonpkuniquekeys = dbo.sp_repltablehasnonpkuniquekey @tabid = @objid
	--
	-- start scripting
	--
	select @cmd = N'
	if (@execution_mode = @QSubWins)
	begin
		' + N'--
		' + N'-- Subscriber wins resolution
		' + N'-- 
		if (@cftcase in (10,11,14,15,18,20,21,22))
		begin
			'+N'--
			'+N'-- delete the row with OLD_PK
			'+N'--'
	insert into #proctext(procedure_text) values( @cmd )
	--
	-- script delete with PK=OLD_PK
	--
	select @cmd = N'
			delete ' + @qualname 
	insert into #proctext(procedure_text) values( @cmd )
	exec dbo.sp_MSscript_where_clause @objid, @columns, 'upd version', NULL, 0
	--
	-- continue scripting
	--
	select @cmd = N'
		end'
	insert into #proctext(procedure_text) values( @cmd )
	--
	-- if the table has non PK unique keys
	-- generate the commands for non PK keys
	--
	if (@fhasnonpkuniquekeys = 1)
	begin
		select @cmd = N'
		if (@cftcase in (17,20,22,23))
		begin
			'+N'--
			'+N'-- delete with NEW values of non PK keys
			'+N'--'
		insert into #proctext(procedure_text) values( @cmd )
		--
		-- script delete with NEW values of non PK keys
		--
		select @cmd = N'
			delete ' + @qualname 
		insert into #proctext(procedure_text) values( @cmd )
		exec @rc = sp_replscriptuniquekeywhereclause @tabid = @objid
					,@columns = @columns
					,@prefix = N'@c' 
					,@suffix = NULL
					,@mode = 7
		--
		-- continue scripting
		--
		select @cmd = N'
		end'
		insert into #proctext(procedure_text) values( @cmd )
	end
	--
	-- continue scripting
	--
	select @cmd = N'
		if (@cftcase in (15,16))
		begin
			'+N'--
			'+N'-- delete with NEW values of all keys
			'+N'--'
	insert into #proctext(procedure_text) values( @cmd )
	--
	-- script delete with NEW values of all keys
	--
	select @cmd = N'
			delete ' + @qualname 
	insert into #proctext(procedure_text) values( @cmd )
	exec @rc = sp_replscriptuniquekeywhereclause @tabid = @objid
				,@columns = @columns
				,@prefix = N'@c' 
				,@suffix = NULL
				,@mode = 6
	--
	-- continue scripting
	--
	select @cmd = N'
		end
		if (@cftcase in (10,11,12,13,14,15,16,17,18,20,21,22,23,24))
		begin
			'+N'--
			'+N'-- insert with NEW values of all keys
			'+N'--'
	insert into #proctext(procedure_text) values( @cmd )
	--
	--  
	-- generate insert statement with NEW values 
	--
	exec @rc = sp_script_insertforcftresolution 
			@objid = @objid
			,@columns = @columns
			,@identity_insert = @identity_insert
			,@prefix = N'@c'
			,@suffix = NULL
	--
	-- continue scripting
	--
	select @cmd = N'
		end

		' + N'--
		' + N'-- --------------------------------------------------------------------
		' + N'-- all done for conflict resolution for Subscriber Wins policy
		' + N'-- --------------------------------------------------------------------
		' + N'--
	end'
	insert into #proctext(procedure_text) values( @cmd )
	--
	-- all done
	--
	return 0
END
go
exec dbo.sp_MS_marksystemobject sp_MSscript_update_subwins
go

--
-- sp_MSscriptupdateconflictfinder
--
-- Owner: KaushikC
--
-- Description: this stored procedure is used for scripting of synctran procedures
-- and scripts the code that is a state machine and finds the exact nature of conflict
-- for UPDATE operations and then assigns it a unique conflict identity.  
-- Executed on publisher database.
--
-- Parameters:  
--		as defined in the create proc statement
--
-- Results:
--	SQL script specific to the article
--
-- Returns:
-- 		0 if success
--		1 if failure
--
-- Security: internal helper procedure - not granted to public 
--
raiserror('Creating procedure sp_MSscriptupdateconflictfinder', 0,1)
go
create procedure sp_MSscriptupdateconflictfinder 
(
	@publication sysname		-- publication name
	,@article sysname			-- article name
	,@objid int				-- object id
	,@columns binary(32)		-- columns replicated
)
as
begin
	declare 
			@rc int
			,@cmd nvarchar(4000)
			,@artid int
			,@pubid int
			,@qualname nvarchar(512)
			,@fhasnonpkuniquekeys int

	--
	-- initialize the vars we will use
	--
	select @pubid = pubid 
	from syspublications 
	where name = @publication
	select @artid = artid
	from sysarticles 
	where name = @article 
		and pubid = @pubid
	exec sp_MSget_qualified_name @objid, @qualname OUTPUT
	--
	--  check if this article has non PK unique keys
	--
	exec @fhasnonpkuniquekeys = dbo.sp_repltablehasnonpkuniquekey @tabid = @objid
	--
	-- start scripting
	--
	select @cmd = N'
	' + N'--
	' + N'-- --------------------------------------------------------------------
	' + N'-- This is the crux of the proc for conflict resolution 
	' + N'-- This code block is essentially a state machine
	' + N'-- where we ascertain the state of resolution
	' + N'-- The actions of this resolution varies for the policy
	' + N'-- The comments for each state outline the policy
	' + N'-- specific actions (I have only outlined Pub Wins for
	' + N'-- now)
	' + N'-- --------------------------------------------------------------------
	' + N'--'
	insert into #proctext(procedure_text) values( @cmd )
	select @cmd = N'
	if (@execution_mode in (@QPubWins, @QSubWins))
	begin 
		declare @fpkeyupdated int'
	insert into #proctext(procedure_text) values( @cmd )
	--
	-- non PK unique keys specific scripting
	--
	if (@fhasnonpkuniquekeys = 1)
	begin
		select @cmd = N'
		declare @fnpukeyupdated int'
		insert into #proctext(procedure_text) values( @cmd )
	end
	--
	-- continue scripting
	--
	select @cmd = N'
		' + N'--
		' + N'-- initialize the conflict case
		' + N'--
		select @cftcase = 0 '
	insert into #proctext(procedure_text) values( @cmd )
	--
	-- script the PK update check
	--
	select @cmd = N'
		exec @fpkeyupdated = dbo.sp_MSispkupdateinconflict ' + 
		cast(@pubid as nvarchar(10)) + N', ' + cast(@artid as nvarchar(10)) + N', @bitmap'
	insert into #proctext(procedure_text) values( @cmd )
	select @cmd = N'
		if (@fpkeyupdated = -1)
			return -1'
	insert into #proctext(procedure_text) values( @cmd )
	--
	-- script non PK unique key update check
	--
	if (@fhasnonpkuniquekeys = 1)
	begin
		select @cmd = N'
		exec @fnpukeyupdated = dbo.sp_MSisnonpkukupdateinconflict ' + 
		cast(@pubid as nvarchar(10)) + N', ' + cast(@artid as nvarchar(10)) + N', @bitmap'
		insert into #proctext(procedure_text) values( @cmd )
		select @cmd = N'
		if (@fnpukeyupdated = -1)
			return -1'
		insert into #proctext(procedure_text) values( @cmd )
	end
	--
	-- continue scripting
	--
	select @cmd = N'
		if (@rowcount = 0)
		begin
			' + N'--
			' + N'-- we had conflict for this command
			' + N'--'
	insert into #proctext(procedure_text) values( @cmd )
	if (@fhasnonpkuniquekeys = 1)
	begin
		select @cmd = N'
			if (@error in (547, 2601, 2627) or (@fpkeyupdated = 1) or (@fnpukeyupdated = 1)) '
	end
	else
	begin
		select @cmd = N'
			if (@error in (547, 2601, 2627) or (@fpkeyupdated = 1)) '
	end
	insert into #proctext(procedure_text) values( @cmd )
	--
	-- continue scripting
	--
	select @cmd = N'
			begin
				' + N'--
				' + N'-- Conflict due to unique key/constraint
				' + N'--'
	insert into #proctext(procedure_text) values( @cmd )
	select @cmd = N'
				if (@fpkeyupdated = 1)
				begin
					' + N'--
					' + N'-- PK is being updated 
					' + N'--'
	insert into #proctext(procedure_text) values( @cmd )
	--
	-- script check for rows with all keys with OLD values
	--
	--if (row exists with pk = OLD_PK or non PK unique keys = OLD values)
	select @cmd = N'
					if exists (select * from ' + @qualname 
	insert into #proctext(procedure_text) values( @cmd )
	exec @rc = sp_replscriptuniquekeywhereclause @tabid = @objid
				,@columns = @columns
				,@prefix = N'@c' 
				,@suffix = N'_old'
				,@mode = 6
	insert into #proctext(procedure_text) values( N' )')
	--
	-- continue scripting
	--
	select @cmd = N'
					begin
						' + N'--
						' + N'-- case 14: row(s) with OLD key values exist(s) 
						' + N'-- (and rows with NEW key values do not exist)
						' + N'-- PubWins -----------------------------------------------------------
						' + N'-- generate delete + insert compensating action with OLD values for all unique keys 
						' + N'-- generate delete compensating action for row with PK = NEW_PK 
						' + N'-- SubWins -----------------------------------------------------------
						' + N'-- delete row with PK=OLD_PK
						' + N'-- insert row with NEW values (use bitmap)
						' + N'--
						select @cftcase = 14
					end'
	insert into #proctext(procedure_text) values( @cmd )
	--
	-- script check for rows with all keys with NEW values (use bitmap)
	--
	--if (row exists with pk = NEW_PK or non PK unique keys = NEW values)
	select @cmd = N'
					if exists (select * from ' + @qualname 
	insert into #proctext(procedure_text) values( @cmd )
	exec @rc = sp_replscriptuniquekeywhereclause @tabid = @objid
				,@columns = @columns
				,@prefix = N'@c' 
				,@suffix = NULL
				,@mode = 6
	insert into #proctext(procedure_text) values( N' )')
	--
	-- continue scripting
	--
	select @cmd = N'
					begin
						' + N'--
						' + N'-- row with NEW key values exist(s)
						' + N'--
						if (@cftcase = 14)
						begin
							' + N'--
							' + N'-- case 15: rows exist with NEW key values and OLD key values
							' + N'-- PubWins -----------------------------------------------------------
							' + N'-- generate delete + insert compensating action with OLD values for all unique keys 
							' + N'-- generate delete + insert compensating action with NEW values for all unique keys 
							' + N'-- SubWins -----------------------------------------------------------
							' + N'-- delete row with PK=OLD_PK
							' + N'-- delete rows with NEW values of all keys
							' + N'-- insert row with NEW values (use bitmap)
							' + N'--
							select @cftcase = 15 
						end'
	insert into #proctext(procedure_text) values( @cmd )
	select @cmd = N'
						else
						begin
							' + N'--
							' + N'-- case 16: rows exist with NEW key values and 
							' + N'-- row does not exist for OLD values
							' + N'-- PubWins -----------------------------------------------------------
							' + N'-- generate delete compensating action for row with PK = OLD_PK 
							' + N'-- generate delete + insert compensating action with NEW values for all unique keys 
							' + N'-- SubWins -----------------------------------------------------------
							' + N'-- delete rows with NEW values of all keys
							' + N'-- insert row with NEW values (use bitmap)
							' + N'--
							select @cftcase = 16 
						end
					end'
	insert into #proctext(procedure_text) values( @cmd )
	select @cmd = N'
					else
					begin
						' + N'--
						' + N'-- row with NEW key values does not exist
						' + N'--
						if (@cftcase = 0)
						begin
							' + N'--
							' + N'-- case 12 : no existing rows with OLD key values or NEW or new key values
							' + N'-- PubWins -----------------------------------------------------------
							' + N'-- generate delete compensating action with PK = OLD_PK
							' + N'-- generate delete compensating action with PK = NEW_PK
							' + N'-- SubWins -----------------------------------------------------------
							' + N'-- insert row with NEW values (use bitmap)
							' + N'--
							select @cftcase = 12 
						end'
	insert into #proctext(procedure_text) values( @cmd )
	select @cmd = N'
						else
						begin
							' + N'--
							' + N'-- case 14: row(s) with OLD key values exist(s) 
							' + N'-- (and rows with NEW key values do not exist)
							' + N'-- PubWins -----------------------------------------------------------
							' + N'-- generate delete + insert compensating action with OLD values for all unique keys 
							' + N'-- generate delete compensating action for row with PK = NEW_PK 
							' + N'-- SubWins -----------------------------------------------------------
							' + N'-- delete row with PK=OLD_PK
							' + N'-- insert row with NEW values (use bitmap)
							' + N'--
							select @cftcase = 14
						end
					end
				end'
	insert into #proctext(procedure_text) values( @cmd )
	--
	-- script this block if the article has non PK unique keys
	--
	if (@fhasnonpkuniquekeys = 1)
	begin
		--
		-- continue scripting
		--
		select @cmd = N'
				else if (@fnpukeyupdated = 1)
				begin
					'+N'-- 
					'+N'-- non PK unique keys are being updated but PK is not updated
					'+N'-- OLD_PK == NEW_PK in these cases
					'+N'--'
		insert into #proctext(procedure_text) values( @cmd )
		--
		-- script the pkrowexists assignment
		--
		select @cmd = N'
					declare @pkrowexist bit
					
					if exists (select * from ' + @qualname 
		insert into #proctext(procedure_text) values( @cmd )
		exec dbo.sp_MSscript_where_clause @objid, @columns, 'upd version', NULL, 0
		select @cmd =  N' )
						select @pkrowexist = 1 '
		insert into #proctext(procedure_text) values( @cmd )
		--
		-- script check for rows with non PK keys with OLD values
		--
		-- if (rows exist with OLD values of non PK unique keys values)
		select @cmd = N'
					if exists (select * from ' + @qualname 
		insert into #proctext(procedure_text) values( @cmd )
		exec @rc = sp_replscriptuniquekeywhereclause @tabid = @objid
					,@columns = @columns
					,@prefix = N'@c' 
					,@suffix = N'_old'
					,@mode = 7
		insert into #proctext(procedure_text) values( N' )')
		--
		-- continue scripting
		--
		select @cmd = N'
					begin
						if (@pkrowexist = 1)
						begin
							'+N'--
							'+N'-- case 10: rows exist with OLD non PK key values
							'+N'-- (and rows with NEW non PK key values do not exist)
							'+N'-- and row with OLD_PK exists
							'+N'-- PubWins -----------------------------------------------------------
							'+N'-- generate delete + insert compensation action with OLD values for all keys 
							'+N'-- generate delete compensating action with NEW values for non PK keys
							'+N'-- SubWins -----------------------------------------------------------
							'+N'-- delete row with PK=OLD_PK
							'+N'-- insert row with NEW values (use bitmap)
							'+N'--
							select @cftcase = 10
						end'
		insert into #proctext(procedure_text) values( @cmd )
		select @cmd = N'
						else
						begin
							'+N'--
							'+N'-- case 21: rows exist with OLD non PK key values
							'+N'-- (and rows with NEW non PK key values do not exist)
							'+N'-- and row with OLD_PK does not exist
							'+N'-- PubWins -----------------------------------------------------------
							'+N'-- generate delete with PK = OLD_PK
							'+N'-- generate delete + insert compensation action with OLD values for non PK keys 
							'+N'-- generate delete compensating action with NEW values for non PK keys
							'+N'-- SubWins -----------------------------------------------------------
							'+N'-- delete row with PK=OLD_PK
							'+N'-- insert row with NEW values (use bitmap)
							'+N'--
							select @cftcase = 21
						end
					end '
		insert into #proctext(procedure_text) values( @cmd )
		--
		-- script check for rows with non PK keys with NEW values (use bitmap)
		--
		-- if (rows exist with NEW values of non PK unique keys values)
		select @cmd = N'
					if exists (select * from ' + @qualname 
		insert into #proctext(procedure_text) values( @cmd )
		exec @rc = sp_replscriptuniquekeywhereclause @tabid = @objid
					,@columns = @columns
					,@prefix = N'@c' 
					,@suffix = NULL
					,@mode = 7
		insert into #proctext(procedure_text) values( N' )')
		--
		-- continue scripting
		--
		select @cmd = N'
					begin
						'+N'--
						'+N'-- find the type of conflict
						'+N'--
						if (@cftcase in (10,21))
						begin
							if (@pkrowexist = 1)
							begin
								'+N'--
								'+N'-- case 20: rows exist with OLD and NEW values of non PK keys
								'+N'-- and row with OLD_PK exists
								'+N'-- PubWins -----------------------------------------------------------
								'+N'-- generate delete + insert compensation action with OLD values for all keys 
								'+N'-- generate delete + insert compensation action with NEW values for non PK keys 
								'+N'-- SubWins -----------------------------------------------------------
								'+N'-- delete row with PK=OLD_PK
								'+N'-- delete row with NEW values for non PK keys
								'+N'-- insert row with NEW values (use bitmap)
								'+N'--
								select @cftcase = 20 
							end '
		insert into #proctext(procedure_text) values( @cmd )
		select @cmd = N'
							else
							begin
								'+N'--
								'+N'-- case 22: rows exist with OLD and NEW values of non PK keys
								'+N'-- and row with OLD_PK does not exist
								'+N'-- PubWins -----------------------------------------------------------
								'+N'-- generate delete with PK = OLD_PK
								'+N'-- generate delete + insert compensation action with OLD values for non PK keys 
								'+N'-- generate delete + insert compensation action with NEW values for non PK keys 
								'+N'-- SubWins -----------------------------------------------------------
								'+N'-- delete row with PK=OLD_PK
								'+N'-- delete row with NEW values for non PK keys
								'+N'-- insert row with NEW values (use bitmap)
								'+N'--
								select @cftcase = 22 
							end
						end '
		insert into #proctext(procedure_text) values( @cmd )
		select @cmd = N'
						else
						begin
							if (@pkrowexist = 1)
							begin
								'+N'--
								'+N'-- case 17: rows exist with NEW values of non PK keys  
								'+N'-- and row does not exist with OLD values of non PK keys
								'+N'-- and row with OLD_PK exists
								'+N'-- PubWins -----------------------------------------------------------
								'+N'-- generate delete compensating action with OLD values for non PK keys 
								'+N'-- generate delete + insert compensation action with NEW values for all keys 
								'+N'-- SubWins -----------------------------------------------------------
								'+N'-- delete row with NEW values for non PK keys
								'+N'-- insert row with NEW values (use bitmap)
								'+N'--
								select @cftcase = 17 
							end '
		insert into #proctext(procedure_text) values( @cmd )
		select @cmd = N'
							else
							begin
								'+N'--
								'+N'-- case 23: rows exist with NEW values of non PK keys  
								'+N'-- and row does not exist with OLD values of non PK keys
								'+N'-- and row with OLD_PK does not exist
								'+N'-- PubWins -----------------------------------------------------------
								'+N'-- delete row with PK=OLD_PK
								'+N'-- generate delete compensating action with OLD values for non PK keys 
								'+N'-- generate delete + insert compensation action with NEW values for non PK keys 
								'+N'-- SubWins -----------------------------------------------------------
								'+N'-- delete row with NEW values for non PK keys
								'+N'-- insert row with NEW values (use bitmap)
								'+N'--
								select @cftcase = 23 
							end
						end
					end '
		insert into #proctext(procedure_text) values( @cmd )
		select @cmd = N'
					else
					begin
						'+N'--
						'+N'-- row does not exist with NEW values of non PK keys
						'+N'--
						if (@cftcase = 0)
						begin
							if (@pkrowexist = 1)
							begin
								'+N'--
								'+N'-- case 18 : no existing rows with OLD or NEW values of non PK keys
								'+N'-- and row with OLD_PK exists
								'+N'-- PubWins -----------------------------------------------------------
								'+N'-- delete row with PK=OLD_PK
								'+N'-- generate delete compensating action with OLD values for non PK keys 
								'+N'-- generate delete compensating action with NEW values for non PK keys 
								'+N'-- generate insert with PK = OLD_PK
								'+N'-- SubWins -----------------------------------------------------------
								'+N'-- insert row with NEW values (use bitmap)
								'+N'--
								select @cftcase = 18 
							end '
		insert into #proctext(procedure_text) values( @cmd )
		select @cmd = N'
							else
							begin
								'+N'--
								'+N'-- case 24 : no existing rows with OLD or NEW values of non PK keys
								'+N'-- and row with OLD_PK does not exist
								'+N'-- PubWins -----------------------------------------------------------
								'+N'-- delete row with PK=OLD_PK
								'+N'-- generate delete compensating action with OLD values for non PK keys 
								'+N'-- generate delete compensating action with NEW values for non PK keys 
								'+N'-- SubWins -----------------------------------------------------------
								'+N'-- insert row with NEW values (use bitmap)
								'+N'--
								select @cftcase = 24 
							end
						end
					end
				end '
		insert into #proctext(procedure_text) values( @cmd )
	end
	--
	-- continue scripting
	--
	select @cmd = N'
			end
			else
			begin
				' + N'--
				' + N'-- Conflict due non key column change or row deleted
				' + N'--'
	insert into #proctext(procedure_text) values( @cmd )
	--
	-- script check for rows with pk = OLD_PK
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
					' + N'-- case 11: row exists
					' + N'-- PubWins -----------------------------------------------------------
					' + N'-- generate delete + insert compensating action with PK = OLD_PK
					' + N'-- SubWins -----------------------------------------------------------
					' + N'-- delete row with PK=OLD_PK
					' + N'-- insert row with NEW values (use bitmap)
					' + N'--
					select @cftcase = 11
				end'
	insert into #proctext(procedure_text) values( @cmd )
	select @cmd = N'
				else
				begin
					' + N'--
					' + N'-- case 13: row does not exist
					' + N'-- PubWins -----------------------------------------------------------
					' + N'-- generate delete compensating action with PK = OLD_PK
					' + N'-- SubWins -----------------------------------------------------------
					' + N'-- insert row with NEW values (use bitmap)
					' + N'--
					select @cftcase = 13
				end
			end
		end'
	insert into #proctext(procedure_text) values( @cmd )
	select @cmd = N'
		else if (@execution_mode = @QPubWins)
		begin
			' + N'--
			' + N'-- we had no conflict for this command
			' + N'-- We need to process this block only in the Publisher Wins cases
			' + N'--'
	insert into #proctext(procedure_text) values( @cmd )
	select @cmd = N'
			if (@fpkeyupdated = 1)
			begin
				' + N'--
				' + N'-- PK is being updated
				' + N'-- PubWins -----------------------------------------------------------
				' + N'-- generate delete + insert compensating action with OLD values for all unique keys 
				' + N'-- generate delete compensating action with PK=NEW_PK
				' + N'-- 
				select @cftcase = 1
			end'
	insert into #proctext(procedure_text) values( @cmd )
	select @cmd = N'
			else
			begin
				' + N'--
				' + N'-- non PK column updated
				' + N'-- PubWins -----------------------------------------------------------
				' + N'-- generate delete + insert compensating action with OLD values for all unique keys
				' + N'--
				select @cftcase = 3
			end
		end
	end'
	insert into #proctext(procedure_text) values( @cmd )
	--
	-- all done
	--
	return 0	
end
go
exec dbo.sp_MS_marksystemobject sp_MSscriptupdateconflictfinder
go

--
-- sp_MSscript_update_pubwins
--
-- Owner: KaushikC
--
-- Description: this stored procedure is used for scripting of synctran 
-- procedures and scripts the code that generates the compensating 
-- commands to resolve all the conflicts in a publisher wins resolution 
-- policy for UPDATE commands. Executed on publisher database.
--
-- Parameters:  
--		as defined in the create proc statement
--
-- Results:
--	SQL script specific to the article
--
-- Returns:
-- 		0 if success
--		1 if failure
--
-- Security: internal helper procedure - not granted to public 
--
raiserror('Creating procedure sp_MSscript_update_pubwins', 0,1)
go
create procedure sp_MSscript_update_pubwins 
(
	@publication sysname		-- publication name
	,@article sysname			-- article name
	,@objid int				-- object id
	,@columns binary(32)		-- columns replicated
)
as
begin
	declare @cmd nvarchar(4000)
			,@artid int
			,@pubid int
			,@qualname nvarchar(512)
			,@dest_table sysname
			,@dest_owner nvarchar(260)
			,@rc           int
			,@fhasnonpkuniquekeys int

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
	--  check if this article has non PK unique keys
	--
	exec @fhasnonpkuniquekeys = dbo.sp_repltablehasnonpkuniquekey @tabid = @objid
	--
	-- start scripting
	--
	select @cmd = N'
	
	' + N'-- 
	' + N'--  --------------------------------------------------------------------
	' + N'--  Now the generation phase
	' + N'--  Use the conflict case value to decide what to do
	' + N'--  --------------------------------------------------------------------
	' + N'--
	'
	insert into #proctext(procedure_text) values( @cmd )
	select @cmd = N'
	
	if (@execution_mode = @QPubWins)
	begin
		' + N'-- 
		' + N'--  Publisher wins resolution
		' + N'--  
		'
	insert into #proctext(procedure_text) values( @cmd )
	--
	-- declare fetch variables for cursor
	--
	exec @rc = sp_scriptpubwinsrefreshcursorvars @objid
	--
	-- continue scripting
	--
	select @cmd = N'
		' + N'-- 
		' + N'--  --------------------------------------------------------------------
		' + N'--  Perform single row delete generations first
		' + N'--  --------------------------------------------------------------------
		' + N'-- 
		'
	insert into #proctext(procedure_text) values( @cmd )
	select @cmd = N'
		' + N'-- 
		' + N'--  Generate DELETE for PK = OLD_PK
		' + N'-- 
		if (@cftcase in (11,12,13,16,18,21,22,23,24))
		begin'
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
		' + N'-- 
		' + N'--  Generate DELETE for PK = NEW_PK 
		' + N'-- 
		if (@cftcase in (1,12,14))
		begin'
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
		end'
	insert into #proctext(procedure_text) values( @cmd )
	--
	-- this scripting is specific to non PK unique keys
	--
	if (@fhasnonpkuniquekeys = 1)
	begin
		--
		-- continue scripting
		--
		select @cmd = N'

		'+N'--
		'+N'-- Generate delete for OLD values of non PK keys
		'+N'--
		if (@cftcase in (17,18,23,24))
		begin'
		insert into #proctext(procedure_text) values( @cmd )
		--
		-- generate delete compensating command for OLD values of non PK unique keys
		--
		select @cmd = N'
			select @cmd = ''DELETE ' + master.dbo.fn_MSgensqescstr(@dest_owner) collate database_default 
					+ quotename(master.dbo.fn_MSgensqescstr(@dest_table) collate database_default) + N' '' + '
		insert into #proctext(procedure_text) values( @cmd )
		exec @rc = sp_replscriptuniquekeywhereclause @tabid = @objid
				,@columns = @columns
				,@prefix = N'@c' 
				,@suffix = N'_old'
				,@mode = 5
		--
		-- script the sending command
		--
		exec sp_MSscript_compensating_send @pubid, @artid, 0, 1
		--
		-- continue scripting
		--
		select @cmd = N'
		end

		'+N'--
		'+N'-- Generate delete for NEW values of non PK keys
		'+N'--
		if (@cftcase in (10,18,21,24))
		begin'
		insert into #proctext(procedure_text) values( @cmd )
		--
		-- generate delete compensating command for NEW values of non PK unique keys
		--
		select @cmd = N'
			select @cmd = ''DELETE ' + master.dbo.fn_MSgensqescstr(@dest_owner) collate database_default 
					+ quotename(master.dbo.fn_MSgensqescstr(@dest_table) collate database_default) + N' '' + '
		insert into #proctext(procedure_text) values( @cmd )
		exec @rc = sp_replscriptuniquekeywhereclause @tabid = @objid
					,@columns = @columns
					,@prefix = N'@c' 
					,@suffix = NULL
					,@mode = 5
		--
		-- script the sending command
		--
		exec sp_MSscript_compensating_send @pubid, @artid, 0, 1
		--
		-- continue scripting
		--
		select @cmd = N'
		end

		' + N'-- 
		' + N'--  --------------------------------------------------------------------
		' + N'--  Perform refresh(delete+insert) generations next
		' + N'--  --------------------------------------------------------------------
		' + N'-- 
		
		' + N'-- 
		' + N'--  Generate delete+insert for OLD values of non PK keys
		' + N'-- 
		if (@cftcase in (21,22))
		begin'
		insert into #proctext(procedure_text) values( @cmd )
		--
		-- generate delete compensating command for OLD values of non PK unique keys
		--
		select @cmd = N'
			select @cmd = ''DELETE ' + master.dbo.fn_MSgensqescstr(@dest_owner) collate database_default 
					+ quotename(master.dbo.fn_MSgensqescstr(@dest_table) collate database_default) + N' '' + '
		insert into #proctext(procedure_text) values( @cmd )
		exec @rc = sp_replscriptuniquekeywhereclause @tabid = @objid
				,@columns = @columns
				,@prefix = N'@c' 
				,@suffix = N'_old'
				,@mode = 5
		--
		-- script the sending command
		--
		exec sp_MSscript_compensating_send @pubid, @artid, 0, 1
		--
		-- script the refresh commands for OLD values of non PK unique keys
		--
		exec @rc = dbo.sp_MSscript_compensating_insert @publication, @article, @objid, @columns, 2, 0
		if (@rc != 0 or @@error != 0)
			return 1
		--
		-- continue scripting
		--
		select @cmd = N'
		end
		' + N'-- 
		' + N'--  Generate delete+insert for NEW values of non PK keys
		' + N'-- 
		if (@cftcase in (20,22,23))
		begin'
		insert into #proctext(procedure_text) values( @cmd )
		--
		-- generate delete compensating command for NEW values of non PK unique keys
		--
		select @cmd = N'
			select @cmd = ''DELETE ' + master.dbo.fn_MSgensqescstr(@dest_owner) collate database_default 
					+ quotename(master.dbo.fn_MSgensqescstr(@dest_table) collate database_default) + N' '' + '
		insert into #proctext(procedure_text) values( @cmd )
		exec @rc = sp_replscriptuniquekeywhereclause @tabid = @objid
					,@columns = @columns
					,@prefix = N'@c' 
					,@suffix = NULL
					,@mode = 5
		--
		-- script the sending command
		--
		exec sp_MSscript_compensating_send @pubid, @artid, 0, 1
		--
		-- script the refresh commands for NEW values of non PK unique keys
		--
		exec @rc = dbo.sp_MSscript_compensating_insert @publication, @article, @objid, @columns, 3, 0
		if (@rc != 0 or @@error != 0)
			return 1
		--
		-- continue scripting
		--
		select @cmd = N'
		end'
		insert into #proctext(procedure_text) values( @cmd )
	end
	--
	-- continue scripting
	--
	select @cmd = N'

		' + N'-- 
		' + N'--  Generate delete+insert for OLD values of all keys
		' + N'-- 
		if (@cftcase in (1,3,10,14,15,20))
		begin'
	insert into #proctext(procedure_text) values( @cmd )
	--
	-- generate delete compensating command for OLD values of all unique keys
	--
	select @cmd = N'
			select @cmd = ''DELETE ' + master.dbo.fn_MSgensqescstr(@dest_owner) collate database_default 
		+ quotename(master.dbo.fn_MSgensqescstr(@dest_table) collate database_default) + N' '' + '
	insert into #proctext(procedure_text) values( @cmd )
	exec @rc = sp_replscriptuniquekeywhereclause @tabid = @objid
				,@columns = @columns
				,@prefix = N'@c' 
				,@suffix = N'_old'
				,@mode = 4
	--
	-- script the sending command
	--
	exec sp_MSscript_compensating_send @pubid, @artid, 0, 1
	--
	-- script the refresh commands for OLD values of all unique keys
	--
	exec @rc = dbo.sp_MSscript_compensating_insert @publication, @article, @objid, @columns, 4, 0
	if (@rc != 0 or @@error != 0)
		return 1
	--
	-- continue scripting
	--
	select @cmd = N'
		end
		' + N'-- 
		' + N'--  Generate delete+insert for NEW values of all keys
		' + N'-- 
		if (@cftcase in (15,16,17))
		begin'
	insert into #proctext(procedure_text) values( @cmd )
	--
	-- generate delete compensating command for NEW values of all unique keys
	--
	select @cmd = N'
			select @cmd = ''DELETE ' + master.dbo.fn_MSgensqescstr(@dest_owner) collate database_default 
		+ quotename(master.dbo.fn_MSgensqescstr(@dest_table) collate database_default) + N' '' + '
	insert into #proctext(procedure_text) values( @cmd )
	exec @rc = sp_replscriptuniquekeywhereclause @tabid = @objid
				,@columns = @columns
				,@prefix = N'@c' 
				,@suffix = NULL
				,@mode = 4
	--
	-- script the sending command
	--
	exec sp_MSscript_compensating_send @pubid, @artid, 0, 1
	--
	-- script the refresh commands for NEW values of all unique keys
	--
	exec @rc = dbo.sp_MSscript_compensating_insert @publication, @article, @objid, @columns, 5, 0
	if (@rc != 0 or @@error != 0)
		return 1
	--
	-- continue scripting
	--
	select @cmd = N'
		end

		' + N'-- 
		' + N'--  --------------------------------------------------------------------
		' + N'--  Perform single row insert generations next
		' + N'--  --------------------------------------------------------------------
		' + N'-- 

		' + N'-- 
		' + N'--  Generate INSERT for PK = OLD_PK
		' + N'-- 
		if (@cftcase in (11,18))
		begin'
	insert into #proctext(procedure_text) values( @cmd )
	--
	-- script compensating insert with OLD_PK
	--
	exec dbo.sp_MSscript_compensating_insert @publication, @article, @objid, @columns, 1, 0
	--
	-- continue scripting
	--
	select @cmd = N'
		end

		' + N'-- 
		' + N'--  --------------------------------------------------------------------
		' + N'--  all done for conflict resolution for Publisher Wins policy
		' + N'--  --------------------------------------------------------------------
		' + N'-- 
	end'
	insert into #proctext(procedure_text) values( @cmd )
	--
	-- all done
	--
	return 0	
end
go
exec dbo.sp_MS_marksystemobject sp_MSscript_update_pubwins
go

raiserror('Creating procedure sp_MSscript_delete_statement', 0,1)
go
create procedure sp_MSscript_delete_statement (
	@publication sysname,
	@article     sysname, 
	@objid int,
	@columns binary(32),
	@queued_pub bit = 0
)
as
BEGIN
	declare @cmd          nvarchar(4000)
	declare @qualname     nvarchar(512)

	exec sp_MSget_qualified_name @objid, @qualname OUTPUT

	--
	-- start scripting
	--
	select @cmd = N'
	' + N'--
	' + N'-- detection/conflict resolution stage
	' + N'--'
	
	if (@queued_pub = 1)
	begin
		select @cmd = @cmd + N'
	if (@execution_mode = @QPubWins)
		save tran cftpass
	'
	end
	insert into #proctext(procedure_text) values( @cmd )

	--
	-- delete statement
	--
	select @cmd = N'
	delete ' + @qualname 
	insert into #proctext(procedure_text) values( @cmd )
	exec dbo.sp_MSscript_where_clause @objid, @columns, 'upd version', 'msrepl_tran_version', 4

	--
	-- continue with scripting
	--
	select @cmd = N'
	select @rowcount = @@ROWCOUNT, @error = @@ERROR
	'

	if (@queued_pub = 1)
	begin
		select @cmd = @cmd + N'
	if (@execution_mode = @QPubWins)
		rollback tran cftpass
	'
	end
	insert into #proctext(procedure_text) values( @cmd )

	--
	-- all done
	--
	return 0
END
go

EXEC dbo.sp_MS_marksystemobject sp_MSscript_delete_statement
GO

--
-- sp_MSscript_delete_subwins
--
-- Owner: KaushikC
--
-- Description: this stored procedure is used for scripting of synctran 
-- procedures and scripts the code that generates the compensating 
-- commands to resolve all the conflicts in a subscriber wins resolution 
-- policy for DELETE commands. Executed on publisher database.
--
-- Parameters:  
--		as defined in the create proc statement
--
-- Results:
--	SQL script specific to the article
--
-- Returns:
-- 		0 if success
--		1 if failure
--
-- Security: internal helper procedure - not granted to public 
--
raiserror('Creating procedure sp_MSscript_delete_subwins', 0,1)
go
create procedure sp_MSscript_delete_subwins 
(
	@publication sysname		-- publication name
	,@article sysname			-- article name
	,@objid int				-- object id
	,@columns binary(32)		-- columns replicated
)
as
begin
	declare @cmd nvarchar(4000)
			,@qualname nvarchar(512)

	exec sp_MSget_qualified_name @objid, @qualname OUTPUT
	--
	-- start scripting
	--
	select @cmd = N'
	if (@execution_mode = @QSubWins)
	begin
		'+N'--
		'+N'-- Subscriber wins resolution
		'+N'-- 
		if (@cftcase = 31)
		begin
			'+N'--
			'+N'-- delete row with PK
			'+N'-- '
	insert into #proctext(procedure_text) values( @cmd )
	--
	-- generate the delete statement
	--
	select @cmd = N'
			delete ' + @qualname 
	insert into #proctext(procedure_text) values( @cmd )
	exec dbo.sp_MSscript_where_clause @objid, @columns, 'upd version', NULL, 0
	--
	-- continue with scripting
	--
	select @cmd = N'			
		end

		'+N'--
		'+N'-- --------------------------------------------------------------------
		'+N'-- all done for conflict resolution for Subscriber Wins policy
		'+N'-- --------------------------------------------------------------------
		'+N'--
	end'
	insert into #proctext(procedure_text) values( @cmd )	
	--
	-- all done
	--
	return 0
end
go
exec dbo.sp_MS_marksystemobject sp_MSscript_delete_subwins
go

--
-- sp_MSscriptdelconflictfinder
--
-- Owner: KaushikC
--
-- Description: this stored procedure is used for scripting of synctran procedures
-- and scripts the code that is a state machine and finds the exact nature of conflict
-- for DELETE operations and then assigns it a unique conflict identity.  
-- Executed on publisher database.
--
-- Parameters:  
--		as defined in the create proc statement
--
-- Results:
--	SQL script specific to the article
--
-- Returns:
-- 		0 if success
--		1 if failure
--
-- Security: internal helper procedure - not granted to public 
--
raiserror('Creating procedure sp_MSscriptdelconflictfinder', 0,1)
go
create procedure sp_MSscriptdelconflictfinder 
(
	@publication sysname		-- publication name
	,@article sysname			-- article name
	,@objid int				-- object id
	,@columns binary(32)		-- columns replicated
)
as
begin
	declare 
			@rc int
			,@cmd nvarchar(4000)
			,@artid int
			,@pubid int
			,@qualname nvarchar(512)
			,@fhasnonpkuniquekeys int

	--
	-- initialize the vars we will use
	--
	select @pubid = pubid 
	from syspublications 
	where name = @publication
	select @artid = artid
	from sysarticles 
	where name = @article 
		and pubid = @pubid
	exec sp_MSget_qualified_name @objid, @qualname OUTPUT
	--
	--  check if this article has non PK unique keys
	--
	exec @fhasnonpkuniquekeys = dbo.sp_repltablehasnonpkuniquekey @tabid = @objid
	--
	-- start scripting
	--
	select @cmd = N'
	'+N'--
	'+N'-- --------------------------------------------------------------------
	'+N'-- This is the crux of the proc for conflict resolution 
	'+N'-- This code block is essentially a state machine
	'+N'-- where we ascertain the state of resolution
	'+N'-- The actions of this resolution varies for the policy
	'+N'-- The comments for each state outline the policy
	'+N'-- specific actions 
	'+N'-- --------------------------------------------------------------------
	'+N'--
	'
	insert into #proctext(procedure_text) values( @cmd )
	--
	-- continue scripting
	--
	select @cmd = N'
	if (@execution_mode in (@QPubWins, @QSubWins))
	begin
		'+N'--
		'+N'-- initialize the conflict case
		'+N'--
		select @cftcase = 0

		if (@rowcount = 0)
		begin
			'+N'--
			'+N'-- row was deleted or updated
			'+N'--'
	insert into #proctext(procedure_text) values( @cmd )
	--
	-- script row exists with OLD_PK
	--
	select @cmd = N'
			if exists (select * from ' + @qualname 
	insert into #proctext(procedure_text) values( @cmd )
	exec dbo.sp_MSscript_where_clause @objid, @columns, 'upd version', NULL, 0
	insert into #proctext(procedure_text) values( N'			)')
	--
	-- continue scripting
	--
	select @cmd = N'
			begin
				'+N'--
				'+N'-- Case 31: Conflict as row was updated
				'+N'-- PubWins -----------------------------------------------------------
				'+N'-- generate delete + insert compensating action with values for all unique keys 
				'+N'-- SubWins -----------------------------------------------------------
				'+N'-- delete row with PK
				'+N'--
				select @cftcase = 31
			end'
	insert into #proctext(procedure_text) values( @cmd )
	--
	-- continue scripting
	--
	select @cmd = N'
			else
			begin
				'+N'--
				'+N'-- Case 33: Conflict as row does not exist
				'+N'-- PubWins -----------------------------------------------------------
				'+N'-- do nothing
				'+N'-- SubWins -----------------------------------------------------------
				'+N'-- do nothing
				'+N'--
				select @cftcase = 33
			end
		end'
	insert into #proctext(procedure_text) values( @cmd )
	--
	-- continue scripting
	--
	select @cmd = N'
		else if (@execution_mode = @QPubWins)
		begin
			'+N'--
			'+N'-- we had no conflict for this command
			'+N'-- We need to process this block only in the Publisher Wins cases
			'+N'--

			'+N'--
			'+N'-- case 30: No conflict - we have to undo the delete
			'+N'-- PubWins -----------------------------------------------------------
			'+N'-- generate delete + insert compensating action with values for all unique keys 
			'+N'-- 
			select @cftcase = 30
		end	
	end'
	insert into #proctext(procedure_text) values( @cmd )
	--
	-- continue scripting
	--
	select @cmd = N'

	'+N'--
	'+N'-- --------------------------------------------------------------------
	'+N'-- Now the generation phase
	'+N'-- Use the conflict case value to decide what to do
	'+N'-- --------------------------------------------------------------------
	'+N'--'
	insert into #proctext(procedure_text) values( @cmd )
	--
	-- all done
	--
	return 0
end
go
exec dbo.sp_MS_marksystemobject sp_MSscriptdelconflictfinder
go

--
--
-- sp_MSscript_compensating_insert
--
-- Owner: KaushikC
--
-- Description: this stored procedure is used for scripting of synctran 
-- procedures and scripts the code for insert compensating command
-- and refresh (delete+insert for selected rowset) compensating 
-- command to resolve conflicts in a publisher wins resolution 
-- policy. Executed on publisher database.
--
-- Parameters:  
--		as defined in the create proc statement
--
-- Results:
--	SQL script specific to the article
--
-- Returns:
-- 		0 if success
--		1 if failure
--
-- Security: internal helper procedure - not granted to public 
--
raiserror('Creating procedure sp_MSscript_compensating_insert', 0,1)
go
create procedure sp_MSscript_compensating_insert 
(
	@publication sysname 	-- publication name
	,@article sysname 		-- article name
	,@objid int			-- table object id
	,@columns binary(32)	-- columns replicated
	,@proctype tinyint		-- what are we scripting 		
	-- 0 = use new_pk
	-- 1 = use old_pk
	-- 2 = use old nonpkkeys
	-- 3 = use new nonpkkeys
	-- 4 = use oldallkeys
	-- 5 = use newallkeys
	,@fdodeclare bit = 1	-- 0 = do not script declares for non PK unique key processing
)
as
begin
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
			,@pkcolumns varbinary(32)
			,@fhasnonpkuniquekeys int
	declare @pkfetch table ( c1 int identity NOT NULL, procedure_text nvarchar(4000) collate database_default null)
	--
	-- constants
	--
	declare @typeusenew_pk tinyint
			,@typeuseold_pk tinyint
			,@typeuseoldnonpkkeys tinyint
			,@typeusenewnonpkkeys tinyint
			,@typeuseoldallkeys tinyint
			,@typeusenewallkeys tinyint
	--
	-- initialize constants
	--
	select @typeusenew_pk = 0
			,@typeuseold_pk = 1
			,@typeuseoldnonpkkeys = 2
			,@typeusenewnonpkkeys = 3
			,@typeuseoldallkeys = 4
			,@typeusenewallkeys = 5

	--
	-- validate @proctype
	--
	if (@proctype not in (@typeusenew_pk,@typeuseold_pk,@typeuseoldnonpkkeys,
		@typeusenewnonpkkeys,@typeuseoldallkeys,@typeusenewallkeys))
	begin
		-- raiserror invalid proctype
		return 1
	end
	--
	-- initialize the vars we will use
	--
	select @pubid = pubid from syspublications where name = @publication
	select @artid = artid, @dest_table = dest_table, 
		@dest_owner = dest_owner, @ins_cmd = ins_cmd from sysarticles 
	where name = @article and pubid = @pubid
	select @dest_owner = case when (@dest_owner IS NULL) then N''
				else quotename(@dest_owner) + N'.' end
			,@fhasnonpkuniquekeys = 0
	exec sp_MSget_qualified_name @objid, @qualname OUTPUT
	--
	-- Do we have non PK unique keys
	--
	exec @fhasnonpkuniquekeys = dbo.sp_repltablehasnonpkuniquekey @tabid = @objid
	--
	-- If we are generating refreshing commands
	-- we will be using cursors
	--
	if (@proctype in (@typeuseoldnonpkkeys,@typeusenewnonpkkeys
						,@typeuseoldallkeys,@typeusenewallkeys))
	begin
		--
		-- generate cursor to collect PK for selected rowset
		-- and then perform delete compensation followed by
		-- insert compensation
		--
 		declare @cmd2 nvarchar(4000)
			,@cmd3 nvarchar(4000)
			,@spacer nvarchar(5)
			,@typestring sysname
			,@isset int
			,@wheremode tinyint
			,@suffix nvarchar(10)
		declare @pkvars table ( c1 int identity NOT NULL, procedure_text nvarchar(4000) collate database_default null)
		declare @pkcols table ( c1 int identity NOT NULL, procedure_text nvarchar(4000) collate database_default null)

		--
		-- if the article has no non PK unique keys
		-- we should not be processing for @typeuseoldnonpkkeys,@typeusenewnonpkkeys
		--
		if (@fhasnonpkuniquekeys = 0 and 
			@proctype in (@typeuseoldnonpkkeys,@typeusenewnonpkkeys))
		begin
			-- error we should not generate these cases if there are no non PK unique keys
			return 1
		end
		--
		-- build some strings for PK columns and PK variables (@pkc1..)
		--
		exec dbo.sp_getarticlepkcolbitmap @objid, @pkcolumns output
		select @cmd = N''
			,@cmd2 = N''
			,@cmd3 = N''
			,@spacer = N''
		declare #hccolid cursor local fast_forward for 
			select colid, name from syscolumns where id = @objid order by colid asc
		open #hccolid
		fetch #hccolid into @this_col, @colname
		while (@@fetch_status != -1)
		begin
			exec @isset = dbo.sp_isarticlecolbitset @this_col, @pkcolumns
			if @isset != 0 and (@colname is not null)
			begin
				exec dbo.sp_gettypestring @objid, @this_col, @typestring output
				select @cmd = @cmd + @spacer + N'@pkc' + convert( nvarchar, @this_col ) + N' ' + @typestring 
						,@cmd2 = @cmd2 + @spacer + quotename(@colname)
						,@cmd3 = @cmd3 + @spacer + N'@pkc' + convert( nvarchar, @this_col )
				select @spacer = N','

				if len( @cmd ) > 3000
				begin
					insert into @pkvars(procedure_text) values( @cmd )
					select @cmd = N''
				end
				if len( @cmd2 ) > 3000
				begin
					insert into @pkcols(procedure_text) values( @cmd2 )
					select @cmd2 = N''
				end
				if len( @cmd3 ) > 3000
				begin
					insert into @pkfetch(procedure_text) values( @cmd3 )
					select @cmd3 = N''
				end
			end
			fetch #hccolid into @this_col, @colname
		end
		close #hccolid
		deallocate #hccolid
		if len(@cmd) > 0
			insert into @pkvars(procedure_text) values( @cmd )
		if len(@cmd2) > 0
			insert into @pkcols(procedure_text) values( @cmd2 )
		if len(@cmd3) > 0
			insert into @pkfetch(procedure_text) values( @cmd3 )
		--
		-- script the PK variable declare now
		--
		if (@fdodeclare = 1)
		begin
			select @cmd = N'
			declare '
			insert into #proctext(procedure_text) values( @cmd )
			insert into #proctext(procedure_text) 
				select procedure_text from @pkvars order by c1 asc
		end
		--
		-- script the cursor declare now
		--
		select @cmd = N'
			declare #hccompins cursor local fast_forward for 
				select distinct '
		insert into #proctext(procedure_text) values( @cmd )
		insert into #proctext(procedure_text) 
			select procedure_text from @pkcols order by c1 asc
		select @cmd = N'
			from ' + @qualname 
		insert into #proctext(procedure_text) values( @cmd )
		--
		-- script the where clause for the cursor
		-- based on @proctype
		--
		if (@proctype = @typeuseoldnonpkkeys) 
		begin
			select @wheremode = 7
				,@suffix = N'_old'
		end
  		else if (@proctype = @typeusenewnonpkkeys) 
  		begin
			select @wheremode = 7
				,@suffix = NULL
  		end
  		else if (@proctype = @typeuseoldallkeys) 
  		begin
			select @wheremode = 6
				,@suffix = N'_old'
  		end
  		else if (@proctype = @typeusenewallkeys) 
  		begin
			select @wheremode = 6
				,@suffix = NULL
		end
		exec @rc = sp_replscriptuniquekeywhereclause @tabid = @objid
					,@columns = @columns
					,@prefix = N'@c' 
					,@suffix = @suffix
					,@mode = @wheremode
		--
		-- script the cursor open and fetch
		--
		select @cmd = N'
			open #hccompins
			fetch #hccompins into '
		insert into #proctext(procedure_text) values( @cmd )
		insert into #proctext(procedure_text) 
			select procedure_text from @pkfetch order by c1 asc
		select @cmd = N'
			while (@@fetch_status != -1)
			begin '
		insert into #proctext(procedure_text) values( @cmd )
		--
		-- we are processing a refresh process
		-- issue a compensating delete for the row
		-- select in the cursor
		--
		select @cmd = N'
			' + '--
			' + '-- Issue a delete command for row selected in cursor
			' + '-- '
		insert into #proctext(procedure_text) values( @cmd )
		select @cmd = N'
			select @cmd = ''DELETE ' + master.dbo.fn_MSgensqescstr(@dest_owner) collate database_default 
			+ quotename(master.dbo.fn_MSgensqescstr(@dest_table) collate database_default) + N' '' + '
		insert into #proctext(procedure_text) values( @cmd )
		exec @rc = sp_replscriptuniquekeywhereclause @tabid = @objid
					,@columns = @columns
					,@prefix = N'@pkc' 
					,@suffix = NULL
					,@mode = 8
		--
		-- script the send for this command
		--
		exec sp_MSscript_compensating_send @pubid, @artid, 0, 1
		--
		-- continue scripting
		--
		select @cmd = N'
			' + '--
			' + '-- Issue a compensating insert for row selected in cursor
			' + '-- '
		insert into #proctext(procedure_text) values( @cmd )
	end
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
				else if (lower(@ccoltype collate SQL_Latin1_General_CP1_CS_AS) in ('bit','bigint','int','smallint','tinyint','decimal','numeric'))
				begin
					select @collen = 40
					select @cast_str = N' ISNULL(CAST(' + quotename(@colname) + N' as nvarchar), ''null'') '
					select @fragmentlen = len(@cast_str) + @collen
				end
				else if (lower(@ccoltype collate SQL_Latin1_General_CP1_CS_AS) in ('float','real'))
				begin
					select @collen = 60
					select @cast_str = N' ISNULL(CONVERT(nvarchar(60),' + quotename(@colname) + N',2), ''null'') '
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
							--
							-- script the where clause
							--
							if (@proctype in (@typeusenew_pk,@typeuseold_pk))
							begin
								--
								-- only PK unique key
								--
								if (@proctype = @typeuseold_pk)
									exec dbo.sp_MSscript_where_clause @objid, @columns, 'upd version', NULL, 0, 'del'
								else
									exec dbo.sp_MSscript_where_clause @objid, @columns, 'new_pk_q', NULL, 0, 'ins'
							end
							else
							begin
								--
								-- we are in the cursor for qualifying row
								-- 
								exec dbo.sp_scriptpkwhereclause @src_objid = @objid
											,@pkcolumns = @pkcolumns
											,@prefix = N'@pkc'
											,@artcolumns = @columns
											,@mode = 2
							end
							--
							-- Script the compensating send
							--
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
						--
						-- script the where clause
						--
						if (@proctype in (@typeusenew_pk,@typeuseold_pk))
						begin
							--
							-- only PK unique key
							--
							if (@proctype = @typeuseold_pk)
								exec dbo.sp_MSscript_where_clause @objid, @columns, 'upd version', NULL, 0, 'del'
							else
								exec dbo.sp_MSscript_where_clause @objid, @columns, 'new_pk_q', NULL, 0, 'ins'
						end
						else
						begin
							--
							-- we are in the cursor for qualifying row
							-- 
							exec dbo.sp_scriptpkwhereclause @src_objid = @objid
										,@pkcolumns = @pkcolumns
										,@prefix = N'@pkc'
										,@artcolumns = @columns
										,@mode = 2
						end
						--
						-- Script the compensating send
						--
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
						--
						-- script the where clause
						--
						if (@proctype in (@typeusenew_pk,@typeuseold_pk))
						begin
							--
							-- only PK unique key
							--
							if (@proctype = @typeuseold_pk)
								exec dbo.sp_MSscript_where_clause @objid, @columns, 'upd version', NULL, 0, 'del'
							else
								exec dbo.sp_MSscript_where_clause @objid, @columns, 'new_pk_q', NULL, 0, 'ins'
						end
						else
						begin
							--
							-- we are in the cursor for qualifying row
							-- 
							exec dbo.sp_scriptpkwhereclause @src_objid = @objid
										,@pkcolumns = @pkcolumns
										,@prefix = N'@pkc'
										,@artcolumns = @columns
										,@mode = 2
						end
						--
						-- Script the compensating send
						--
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
		--
		-- script the where clause
		--
		if (@proctype in (@typeusenew_pk,@typeuseold_pk))
		begin
			--
			-- only PK unique key
			--
			if (@proctype = @typeuseold_pk)
				exec dbo.sp_MSscript_where_clause @objid, @columns, 'upd version', NULL, 0, 'del'
			else
				exec dbo.sp_MSscript_where_clause @objid, @columns, 'new_pk_q', NULL, 0, 'ins'
		end
		else
		begin
			--
			-- we are in the cursor for qualifying row
			-- 
			exec dbo.sp_scriptpkwhereclause @src_objid = @objid
						,@pkcolumns = @pkcolumns
						,@prefix = N'@pkc'
						,@artcolumns = @columns
						,@mode = 2
		end
		--
		-- Script the compensating send
		--
		exec sp_MSscript_compensating_send @pubid, @artid, 0, @setprefix
	end
	--
	-- More scripting for refresh command processing modes
	--
	if (@proctype in (@typeuseoldnonpkkeys,@typeusenewnonpkkeys
					,@typeuseoldallkeys,@typeusenewallkeys))
	begin
		--
		-- script the cursor fetch
		--
		select @cmd = N'
			fetch #hccompins into '
		insert into #proctext(procedure_text) values( @cmd )
		insert into #proctext(procedure_text) 
			select procedure_text from @pkfetch order by c1 asc
		--
		-- script the cursor close and deallocate
		--
		select @cmd = N'
			end
			close #hccompins
			deallocate #hccompins '
		insert into #proctext(procedure_text) values( @cmd )
	end
	--
	-- all done
	--
	return 0
end
go
exec dbo.sp_MS_marksystemobject sp_MSscript_compensating_insert
go

--
-- sp_MSscript_delete_pubwins
--
-- Owner: KaushikC
--
-- Description: this stored procedure is used for scripting of synctran 
-- procedures and scripts the code that generates the compensating 
-- commands to resolve all the conflicts in a publisher wins resolution 
-- policy for DELETE commands. Executed on publisher database.
--
-- Parameters:  
--		as defined in the create proc statement
--
-- Results:
--	SQL script specific to the article
--
-- Returns:
-- 		0 if success
--		1 if failure
--
-- Security: internal helper procedure - not granted to public 
--
raiserror('Creating procedure sp_MSscript_delete_pubwins', 0,1)
go
create procedure sp_MSscript_delete_pubwins 
(
	@publication sysname		-- publication name
	,@article sysname			-- article name
	,@objid int				-- object id
	,@columns binary(32)		-- columns replicated
)
as
begin
	declare @cmd nvarchar(4000)
			,@artid int
			,@pubid int
			,@dest_table sysname
			,@dest_owner nvarchar(260)
			,@rc           int
			,@qualname nvarchar(512)
			,@fhasnonpkuniquekeys int

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
	if (@execution_mode = @QPubWins)
	begin
		'+N'--
		'+N'-- Publisher wins resolution
		'+N'-- '
	insert into #proctext(procedure_text) values( @cmd )
	--
	-- declare fetch variables for cursor
	--
	exec @rc = sp_scriptpubwinsrefreshcursorvars @objid
	--
	-- continue scripting
	--
	select @cmd = N'

		'+N'--
		'+N'-- --------------------------------------------------------------------
		'+N'-- Perform refresh(delete+insert) generations next
		'+N'-- --------------------------------------------------------------------
		'+N'--
		
		'+N'--
		'+N'-- Generate delete+insert for values of all keys
		'+N'--
		if (@cftcase in (30,31))
		begin'
	insert into #proctext(procedure_text) values( @cmd )
	--
	-- generate delete compensating command for OLD values of all unique keys
	--
	select @cmd = N'
			select @cmd = ''DELETE ' + master.dbo.fn_MSgensqescstr(@dest_owner) collate database_default 
		+ quotename(master.dbo.fn_MSgensqescstr(@dest_table) collate database_default) + N' '' + '
	insert into #proctext(procedure_text) values( @cmd )
	exec @rc = sp_replscriptuniquekeywhereclause @tabid = @objid
				,@columns = @columns
				,@prefix = N'@c' 
				,@suffix = N'_old'
				,@mode = 4
	--
	-- script the sending command
	--
	exec sp_MSscript_compensating_send @pubid, @artid, 0, 1
	--
	-- script the refresh commands for OLD values of all unique keys
	--
	exec @rc = dbo.sp_MSscript_compensating_insert @publication, @article, @objid, @columns, 4, 0
	if (@rc != 0 or @@error != 0)
		return 1
	--
	-- continue scripting
	--
	select @cmd = N'
		end
		'+N'--
		'+N'-- --------------------------------------------------------------------
		'+N'-- all done for conflict resolution for Publisher Wins policy
		'+N'-- --------------------------------------------------------------------
		'+N'--
	end'
	insert into #proctext(procedure_text) values( @cmd )
	--
	-- all done
	--
	return 0		
end
go
exec dbo.sp_MS_marksystemobject sp_MSscript_delete_pubwins
go

raiserror('Creating procedure sp_MSscript_beginproc', 0,1)
go
create procedure sp_MSscript_beginproc (
    @publication  sysname, 
    @article      sysname, 
    @procname     sysname,
    @source_objid int        output,
    @columns      binary(32) output)
as
BEGIN
    declare @cmd nvarchar(4000)
    declare @source_table sysname
    declare @owner sysname

    -- Retrieve underlying table name and replicated columns
    select @source_table = object_name(objid), @source_objid = objid, @columns = columns from sysarticles a, syspublications p
        where a.name = @article and
              p.name = @publication and
              a.pubid = p.pubid

    -- Get the object owner name
    select @owner = u.name from sysusers u, sysobjects o where 
        o.id = @source_objid and
        o.uid = u.uid
            
    if @source_table IS NULL
    begin
        raiserror (20506, 16, 1,  @source_table, 'sp_MSscript_beginproc')
        return 0
    end

    -- Construct proc name
    -- Create proc under the table owner account to preserve the ownership chain
    select @cmd = N'create procedure '+QUOTENAME(@owner)+ N'.'+ QUOTENAME(@procname) + N' (
	@orig_server sysname, @orig_db sysname,'
    exec dbo.sp_MSflush_command @cmd output, 1

    return 1
END
go

EXEC dbo.sp_MS_marksystemobject sp_MSscript_beginproc
GO

raiserror('Creating procedure sp_MSscript_security', 0,1)
go
create procedure sp_MSscript_security (
    @publication sysname)
as
BEGIN
    declare @cmd nvarchar(4000)
	
	select @cmd = N'
	' + N'--
	' + N'-- Check for security
	' + N'--
	exec @retcode = dbo.sp_MSreplcheck_pull @publication = '+ quotename(@publication) + N'
	if (@retcode != 0 or @@error != 0)
		return -1
	'
    insert into #proctext(procedure_text) values(@cmd)
END                    
go

EXEC dbo.sp_MS_marksystemobject sp_MSscript_security
GO

raiserror('Creating procedure sp_MSscript_endproc', 0,1)
go
create procedure sp_MSscript_endproc (
	@objid int, 
	@op_type varchar(3) = 'ins', -- 'ins', 'upd', 'del'
	@columns binary(32),
	@outvars nvarchar(4000),
	@queued_pub bit = 0
)
as
BEGIN
	declare @cmd nvarchar(4000)
	declare @qualname nvarchar(512)

	exec sp_MSget_qualified_name @objid, @qualname OUTPUT

	--
	-- start scripting
	--
	select @cmd = N'
	' + N'--
	' + N'-- decide the return code
	' + N'--
	if (@execution_mode = @immediate)
	begin
		if @error != 0
      		return -1
		-- Return special code to indicate the subscriber row needs to be
		-- refreshed.
		if @rowcount = 0
      		return 5
	end'
	insert into #proctext(procedure_text) values(@cmd)

	--
	-- operation specific stuff
	--
	if (@queued_pub = 1)
	begin
		if (@op_type = 'ins')
		begin
			select @cmd = N'
	if (@execution_mode = @QFirstPass)
	begin
		if (@rowcount = 0)
		begin
			if (@error in (547, 2601, 2627))
				return 2 -- insert conflict
			else
				return -1 -- error
		end
	end'
		end
		else if (@op_type = 'upd')
		begin
			select @cmd = N'
	if (@execution_mode = @QFirstPass)
	begin
		if (@rowcount = 0)
		begin
			if (@error in (0, 547, 2601, 2627))
				return 1 -- update conflict
			else
				return -1 -- error
		end
	end'
		end
		else if (@op_type = 'del')
		begin
			select @cmd = N'
	if (@execution_mode = @QFirstPass)
	begin
		if (@rowcount = 0)
		begin
			if (@error in (0, 547))
				return 3 -- delete conflict
			else
				return -1 -- error
		end
	end'
		end
		insert into #proctext(procedure_text) values(@cmd)
		
		--
		-- continue with scripting
		--
		select @cmd = N'
	
	if (@execution_mode in (@QPubWins, @QSubWins))
	begin		
		if (@@error != 0 or @retcode != 0)
			return -1 -- error
	end
    '
		insert into #proctext(procedure_text) values(@cmd)
	end

	--
	-- if we have output vars to assign do it now
	--
	if (@outvars is not null)
	begin   
		if @op_type = 'upd'
		begin
			--
			-- Script out pk var assigment that used in sp_MSscript_where_clause
			--
			exec dbo.sp_MSscript_pkvar_assignment @objid, @columns, 1, null, null, null, @queued_pub
			insert into #proctext(procedure_text) values(N'
	')
		end

		select @cmd = N'
	select ' + @outvars + N'
	from ' + @qualname 
		insert into #proctext(procedure_text) values( @cmd)
		insert into #proctext(procedure_text) values( N'
	')
	
		if (@op_type = 'ins')
			exec dbo.sp_MSscript_where_clause @objid, @columns, 'new pk', null, 4
		else if (@op_type = 'upd')
			exec dbo.sp_MSscript_where_clause @objid, @columns, 'old pk', null, 4
	end

	--
	-- Final part of the proc
	--
    select @cmd = N'
    
	' + N'--
	' + N'-- past all checks
	' + N'--
	return 0
END
'
	insert into #proctext(procedure_text) values(@cmd)
	
	--
	-- all done
	--
	return 0
END
go
exec dbo.sp_MS_marksystemobject sp_MSscript_endproc
go

raiserror('Creating procedure sp_MStable_not_modifiable', 0,1)
go
create proc sp_MStable_not_modifiable
    @objid   int,
    @columns binary(32)
as
    declare @colname      sysname
    declare @typestring   nvarchar(4000)
    declare @this_col     int
    declare @art_col      int
    declare @isset        int
    declare @found int, @repl_columns int

    select @art_col = 1
    select @found = 0, @repl_columns = 0

	DECLARE hCColid CURSOR LOCAL FAST_FORWARD FOR 
	select colid from syscolumns where id = @objid order by colid asc

	OPEN hCColid

	FETCH hCColid INTO @this_col

	WHILE (@@fetch_status <> -1)
    begin
        exec @isset = dbo.sp_isarticlecolbitset @this_col, @columns

        if @isset != 0 and EXISTS (select name from syscolumns where id=@objid and @this_col=colid and iscomputed<>1)
        begin
            select @repl_columns = @repl_columns + 1
            exec dbo.sp_MSget_type @objid, @this_col, @colname output, @typestring OUTPUT

            if @typestring = N'timestamp' or ColumnProperty(@objid, @colname, 'IsIdentity') = 1
                select @found = 1

        end
		FETCH hCColid INTO @this_col
    end
	CLOSE hCColid
	DEALLOCATE hCColid

    if @found = 1 and @repl_columns = 1
        return 1
    else
        return 0
go


EXEC dbo.sp_MS_marksystemobject sp_MStable_not_modifiable
GO

--
-- proc to script the various checks done for queued and
-- synctran execution prior to actual detection/resolution
-- For queued execution, we also check for Reinitialization
-- phase
--
raiserror('Creating procedure sp_MSscript_ExecutionMode_stmt', 0,1)
go
create procedure sp_MSscript_ExecutionMode_stmt (
	@publication sysname, 
	@article     sysname,
	@proctype	int = 0)		-- 0 insert, 1 delete, 2 update
as
begin
	declare @cmd		nvarchar(4000)
			,@artid		int
			,@pubid		int
			,@queued_pub bit

	select @pubid = pubid, @queued_pub = allow_queued_tran 
		from syspublications where name = @publication
	select @artid = artid from sysarticles where name = @article and pubid = @pubid

	--
	-- For queued execution check if we are in the phase of reinitialization
	--
	select @cmd = N'
	' + N'--
	' + N'-- Check if we are in the process of Reinitialization
	' + N'-- if yes then return
	' + N'--' 
	insert into #proctext(procedure_text) values( @cmd )

	select @cmd = N'
	exec @retcode = dbo.sp_MSgetarticlereinitvalue @orig_server, @orig_db, ' + 
	cast(@artid as nvarchar(5)) + N', @reinit output
	if (@retcode != 0 or @@error != 0)
		return -1 '
	insert into #proctext(procedure_text) values( @cmd )

	select @cmd = N'
	if (@reinit = 1) -- Resync state
	begin
		if (@execution_mode = @immediate)
			return -2'
	if (@queued_pub = 1)
	begin
		select @cmd = @cmd + N'
		else
			return 4 -- Queued Resync state'
	end
	select @cmd = @cmd + N'
	end
	'
	insert into #proctext(procedure_text) values( @cmd )
	
	--
	-- set loopback detection for immediate
	--
	select @cmd = N'
	if (@execution_mode = @immediate)
	begin
		' + N'--
		' + N'-- For immediate
		' + N'-- enable loopback detection
		' + N'--
		exec @retcode = dbo.sp_replsetoriginator_pal @orig_server, @orig_db, ''' 
			+ master.dbo.fn_MSgensqescstr(@publication) collate database_default + N'''
		if (@retcode != 0 or @@error != 0) 
			return -1
	end'
	insert into #proctext(procedure_text) values( @cmd )

	/********* no need to disable since we never enable
	if (@queued_pub = 1)
	begin
		--
		-- disable loopback for queued
		--
		select @cmd = N'
	else if (@execution_mode in (@QFirstPass, @QSubWins))
	begin
		' + N'--
		' + N'-- For queued
		' + N'-- disable loopback detection
		' + N'--
		exec @retcode = dbo.sp_replsetoriginator N''anull'', N''anull''
		if (@retcode != 0 or @@error != 0) 
			return -1
	end'
		insert into #proctext(procedure_text) values( @cmd )
	end
	**********/

	if (@queued_pub = 1)
	begin
		--
		-- Queued reinitialization mode execution
		--
		select @cmd = N'
	else if (@execution_mode = @QReinit)
	begin
		' + N'--
		' + N'-- For Queued reinitialization
		' + N'-- Set the Queue and subscription for reinit
		' + N'--'
		insert into #proctext(procedure_text) values( @cmd )

		select @cmd = N'
		exec @retcode = dbo.sp_reinitsubscription @publication = ''' 
			+ master.dbo.fn_MSgensqescstr(@publication) collate database_default + N''', @article = ''' +  
			master.dbo.fn_MSgensqescstr(@article) collate database_default + N''', @subscriber = @orig_server, @destination_db = @orig_db
		if (@retcode != 0 or @@error != 0)
			return -1
		else
			return 0
	end'

		insert into #proctext(procedure_text) values( @cmd )
	end

	--
	-- all done
	--
	return 0
end 
go
EXEC dbo.sp_MS_marksystemobject sp_MSscript_ExecutionMode_stmt
GO

--
-- Name: sp_MSscript_sync_ins_proc
--
-- Description: This procedure is used during the scripting of publisher 
-- synctran procedures. This SP generates script for the INSERT synctran 
-- procedure. Invoked on publisher during the article creation.
--
-- Parameter: Refer to the comments in the create procedure statement
--
-- Returns: 1 or 0   0 = success
--
-- Security: Public procedure - does publisher security check. 
--
raiserror('Creating procedure sp_MSscript_sync_ins_proc', 0,1)
go
create procedure sp_MSscript_sync_ins_proc (
    @publication sysname, 
    @article     sysname,
    @procname    sysname)
as
BEGIN
	declare @source_objid int
			,@colname sysname
			,@indid int
			,@cmd          nvarchar(4000)
			,@columns      binary(32)
			,@outvars      nvarchar(4000)
			,@rc           int
			,@error_cmd	tinyint
			,@identity_insert bit
			,@queued_pub bit

	set nocount on
	--
	-- security check
	--
	exec @rc = dbo.sp_MSreplcheck_publish
	if @@error <> 0 or @rc <> 0
	begin
		return (1)
	end
	--
	-- Create temp table
	--
	create table #proctext ( c1 int identity NOT NULL, procedure_text nvarchar(4000) collate database_default null)
	select @queued_pub = allow_queued_tran from syspublications where name = @publication

	--
	-- proc definition
	--
	exec @rc = dbo.sp_MSscript_beginproc @publication, @article, @procname, @source_objid output, @columns output
	if @rc = 0
	    return

	--
	-- construct parameter list
	--
	exec dbo.sp_MSscript_params @source_objid, @columns, null, 1,  @outvars output

	--
	-- add other parameters and start body of proc
	--
	exec dbo.sp_MSscript_procbodystart @queued_pub

	--
	-- script out security check
	--
	exec dbo.sp_MSscript_security @publication

	--
	-- script the execution mode checks
	--
	exec dbo.sp_MSscript_ExecutionMode_stmt @publication, @article, 0

	--
	-- script out subscription validation
	--
	exec dbo.sp_MSscript_validate_subscription @publication, @article

	--
	-- Work around for case where article has 1 col that is not user-modfied (identity, timestamp)
	-- *** Do we need to check this here - 
	-- *** we should be checking this when creating subscription
	-- 
	exec @rc = dbo.sp_MStable_not_modifiable @source_objid, @columns
	if @rc = 1
		select @error_cmd = 1
	else
	begin
		exec @indid = dbo.sp_MStable_has_unique_index @source_objid 
		if (@outvars != null and @indid = 0)
			-- no insert/update allowed if timestamp/identity col and no unique index
			select @error_cmd = 1
		else
			select @error_cmd = 0		
	end

	if (@error_cmd = 0)
	begin
		-- Continue generation
	
		-- Check to see if identity insert must be turned on
		-- i.e. Does the table has identity that are included in the partition?
		exec sp_MSis_identity_insert @publication, @article, @identity_insert output
		--
		-- script insert statemnt
		--
		exec dbo.sp_MSscript_insert_statement @source_objid, @columns, @identity_insert, @queued_pub

		--
		-- script queued specific stuff
		--
		if (@queued_pub = 1)
		begin
			--
			-- script Conflict finder
			--
			exec dbo.sp_MSscriptinsertconflictfinder @publication, @article, @source_objid, @columns
			--
			-- script Conflict resolution block for Publisher Wins case
			--
			exec dbo.sp_MSscript_insert_pubwins @publication, @article, @source_objid, @columns
			--
			-- script Conflict resolution block for Subscriber Wins case
			--
			exec dbo.sp_MSscript_insert_subwins @publication, @article, @source_objid, @columns, @identity_insert
		end
		
		--
		-- script closing 
		--
		exec dbo.sp_MSscript_endproc @source_objid, 'ins', @columns, @outvars, @queued_pub
	end
	else
	begin
		--
		-- Generate error command and finish
		--
		insert into #proctext(procedure_text) values( N'
	exec sp_MSreplraiserror 20516
END
')
	end
	              
	--
	-- send fragments to client
	--
	select procedure_text from #proctext order by c1 asc
END
go
EXEC dbo.sp_MS_marksystemobject sp_MSscript_sync_ins_proc
GO

--
-- Name: sp_MSscript_sync_upd_proc
--
-- Description: This procedure is used during the scripting of publisher 
-- synctran procedures. This SP generates script for the UPDATE 
-- synctran procedure. Invoked on publisher during the article creation.
--
-- Parameter: Refer to the comments in the create procedure statement
--
-- Returns: 1 or 0   0 = success
--
-- Security: Public procedure - does publisher security check. 
--
raiserror('Creating procedure sp_MSscript_sync_upd_proc', 0,1)
go
create procedure sp_MSscript_sync_upd_proc (
    @publication sysname, 
    @article     sysname,
    @procname    sysname)
as
BEGIN
	declare @source_objid int
			,@colname sysname
			,@indid int
			,@cmd          nvarchar(4000)
			,@columns      binary(32)
			,@outvars      nvarchar(4000)
			,@rc           int
			,@error_cmd	tinyint
			,@identity_insert bit
			,@queued_pub bit

	set nocount on
	--
	-- security check
	--
	exec @rc = dbo.sp_MSreplcheck_publish
	if @@error <> 0 or @rc <> 0
	begin
		return (1)
	end
	--
	-- Create temp table
	--
	create table #proctext ( c1 int identity NOT NULL, procedure_text nvarchar(4000) collate database_default null)
	select @queued_pub = allow_queued_tran from syspublications where name = @publication

	--
	-- proc definition
	--
	exec @rc = dbo.sp_MSscript_beginproc @publication, @article, @procname, @source_objid output, @columns output
	if @rc = 0
	    return

	--
	-- construct parameter list
	-- Script bitmap parameter
	--
	exec dbo.sp_MSscript_params @source_objid, @columns, null, 1,  @outvars output
	insert into #proctext(procedure_text) values( N',')
	exec dbo.sp_MSscript_params @source_objid, @columns, N'_old', 0, null
	insert into #proctext(procedure_text) values( N'
	,@bitmap varbinary(4000)')

	--
	-- add other parameters and start body of proc
	--
	exec dbo.sp_MSscript_procbodystart @queued_pub 

	--
	-- script out security check
	--
	exec dbo.sp_MSscript_security @publication

	--
	-- script the execution mode checks
	--
	exec dbo.sp_MSscript_ExecutionMode_stmt @publication, @article, 2

	--
	-- script out subscription validation
	--
	exec dbo.sp_MSscript_validate_subscription @publication, @article

	--
	-- Work around for case where article has 1 col that is not user-modfied (identity, timestamp)
	-- *** Do we need to check this here - 
	-- *** we should be checking this when creating subscription
	-- 
	exec @rc = dbo.sp_MStable_not_modifiable @source_objid, @columns
	if @rc = 1
		select @error_cmd = 1
	else
	begin
		exec @indid = dbo.sp_MStable_has_unique_index @source_objid 
		if (@outvars != null and @indid = 0)
			-- no insert/update allowed if timestamp/identity col and no unique index
			select @error_cmd = 1
		else
			select @error_cmd = 0		
	end

	if (@error_cmd = 0)
	begin
		-- Continue generation
		
		--
		-- script update statemnt
		--
		exec dbo.sp_MSscript_update_statement @publication, @article, @source_objid, @columns, @queued_pub

		--
		-- script queued specific stuff
		--
		if (@queued_pub = 1)
		begin
			-- Check to see if identity insert must be turned on
			-- i.e. Does the table has identity that are included in the partition?
			exec sp_MSis_identity_insert @publication, @article, @identity_insert output
			--
			-- script the conflict resolution logic common to all resolution policies
			--
			exec dbo.sp_MSscriptupdateconflictfinder @publication, @article, @source_objid, @columns
			--
			-- script Conflict resolution block for Publisher Wins case
			--
			exec dbo.sp_MSscript_update_pubwins @publication, @article, @source_objid, @columns
			--
			-- script Conflict resolution block for Subscriber Wins case
			--
			exec dbo.sp_MSscript_update_subwins @publication, @article, @source_objid, @columns, @identity_insert
		end

		--
		-- script closing 
		--
		exec dbo.sp_MSscript_endproc @source_objid, 'upd', @columns, @outvars, @queued_pub
	end
	else
	begin
		--
		-- Generate error command and finish
		--
		insert into #proctext(procedure_text) values( N'
	exec sp_MSreplraiserror 20516
END
')
	end
	              
	--
	-- send fragments to client
	--
	select procedure_text from #proctext order by c1 asc
END
go
EXEC dbo.sp_MS_marksystemobject sp_MSscript_sync_upd_proc
GO

--
-- Name: sp_MSscript_sync_del_proc
--
-- Description: This procedure is used during the scripting of publisher 
-- synctran procedures. This SP generates script for the DELETE 
-- synctran procedure. Invoked on publisher during the article creation.
--
-- Parameter: Refer to the comments in the create procedure statement
--
-- Returns: 1 or 0   0 = success
--
-- Security: Public procedure - does publisher security check. 
--
raiserror('Creating procedure sp_MSscript_sync_del_proc', 0,1)
go
create procedure sp_MSscript_sync_del_proc (
    @publication sysname, 
    @article     sysname,
    @procname    sysname)
as
BEGIN
	declare @source_objid int
	declare @colname sysname
	declare @indid int
	declare @cmd          nvarchar(4000)
	declare @columns      binary(32)
	declare @outvars      nvarchar(4000)
	declare @rc           int
	declare @error_cmd	tinyint
	declare @queued_pub bit

	set nocount on
	--
	-- security check
	--
	exec @rc = dbo.sp_MSreplcheck_publish
	if @@error <> 0 or @rc <> 0
	begin
		return (1)
	end
	--
	-- Create temp table
	--
	create table #proctext ( c1 int identity NOT NULL, procedure_text nvarchar(4000) collate database_default null)
	select @queued_pub = allow_queued_tran from syspublications where name = @publication

	--
	-- proc definition
	--
	exec @rc = dbo.sp_MSscript_beginproc @publication, @article, @procname, @source_objid output, @columns output
	if @rc = 0
	    return

	--
	-- construct parameter list
	--
	exec dbo.sp_MSscript_params @source_objid, @columns, N'_old', 0, null

	--
	-- add other parameters and start body of proc
	--
	exec dbo.sp_MSscript_procbodystart @queued_pub 

	--
	-- script out security check
	--
	exec dbo.sp_MSscript_security @publication

	--
	-- script the execution mode checks
	--
	exec dbo.sp_MSscript_ExecutionMode_stmt @publication, @article, 1

	--
	-- script out subscription validation
	--
	exec dbo.sp_MSscript_validate_subscription @publication, @article

	--
	-- Work around for case where article has 1 col that is not user-modfied (identity, timestamp)
	-- *** Do we need to check this here - 
	-- *** we should be checking this when creating subscription
	-- 
	exec @rc = dbo.sp_MStable_not_modifiable @source_objid, @columns
	if @rc = 1
		select @error_cmd = 1
	else
	begin
		exec @indid = dbo.sp_MStable_has_unique_index @source_objid 
		if (@outvars != null and @indid = 0)
			-- no insert/update allowed if timestamp/identity col and no unique index
			select @error_cmd = 1
		else
			select @error_cmd = 0		
	end

	if (@error_cmd = 0)
	begin
		-- Continue generation
		
		--
		-- script delete statemnt
		--
		exec dbo.sp_MSscript_delete_statement @publication, @article, @source_objid, @columns, @queued_pub

		--
		-- script queued specific stuff
		--
		if (@queued_pub = 1)
		begin
			--
			-- script the conflict resolution logic common to all resolution policies
			--
			exec sp_MSscriptdelconflictfinder @publication, @article, @source_objid, @columns
			--
			-- script Conflict resolution block for Publisher Wins case
			--
			exec dbo.sp_MSscript_delete_pubwins @publication, @article, @source_objid, @columns
			--
			-- script Conflict resolution block for Subscriber Wins case
			--
			exec dbo.sp_MSscript_delete_subwins @publication, @article, @source_objid, @columns
		end
		
		--
		-- script closing 
		--
		exec dbo.sp_MSscript_endproc @source_objid, 'del', @columns, @outvars, @queued_pub
	end
	else
	begin
		--
		-- Generate error command and finish
		--
		insert into #proctext(procedure_text) values( N'
	exec sp_MSreplraiserror 20516
END
')
	end
	              
	--
	-- send fragments to client
	--
	select procedure_text from #proctext order by c1 asc

END
go
EXEC dbo.sp_MS_marksystemobject sp_MSscript_sync_del_proc
GO

--
-- Name: sp_MSscript_pub_upd_trig
--
-- Description: This proc is used during the scripting of publisher synctran trigger 
-- used by updating subscribers to force row version change implicitly. This SP 
-- generates a script for UPDATE trigger.It is executed on publisher during 
-- the article creation phase.
--
-- Parameter: Refer to the comments in the create procedure statement
--
-- Returns: 1 or 0   0 = success
--
-- Security: Public procedure - does publisher security check. 
--
raiserror('Creating procedure sp_MSscript_pub_upd_trig', 0,1)
go
create procedure sp_MSscript_pub_upd_trig
(
    @publication sysname, 
    @article     sysname,
    @procname    sysname
)
as
begin
    declare @cmd       nvarchar(4000)
    declare @qualname  nvarchar(512)
    declare @objid	   int
    declare @columns   binary(32)
                ,@retcode int

    set nocount on
    --
    -- security check
    --
    exec @retcode = dbo.sp_MSreplcheck_publish
    if @@error <> 0 or @retcode <> 0
    begin
        return (1)
    end

    -- Create temp table
    create table #proctext ( c1 int identity NOT NULL, procedure_text nvarchar(4000) collate database_default null)


    -- Retrieve underlying table name and replicated columns
    select @objid = objid, @columns = columns from sysarticles a, syspublications p
        where a.name = @article and
              p.name = @publication and
              a.pubid = p.pubid

    exec sp_MSget_qualified_name @objid, @qualname OUTPUT

	-- Trigger should be invoked for repl processes as well.
	select @cmd = N'create trigger ' + QUOTENAME(@procname) + N' on ' + @qualname + N' '
    select @cmd = @cmd + N'for update as ' 

    exec dbo.sp_MSflush_command @cmd output, 1

    insert into #proctext(procedure_text) values(N'
')
    -- declare common local variables
	insert into #proctext(procedure_text) values 
		(N'declare @rc int
')
    insert into #proctext(procedure_text) values(N'select @rc = @@ROWCOUNT 

')
		
	-- Optimization. Return immediately if no row changed
	-- This must be at the beginning of the trigger to @@rowcount be overwritten.
    insert into #proctext(procedure_text) values(N'if @rc = 0 return 
')
    insert into #proctext(procedure_text) values(N'if update (msrepl_tran_version) return 
')

    -- update the version column of all the updated rows all at once.
	select @cmd = N'update ' + @qualname + N' set msrepl_tran_version = newid() from ' +
        @qualname + ', inserted '
    exec dbo.sp_MSflush_command @cmd output, 1
    insert into #proctext(procedure_text) values(N'
')
    exec dbo.sp_MSscript_where_clause @objid, @columns, 'version pk', null, 4

    insert into #proctext(procedure_text) values(N'
')
    -- send fragments to client
    select procedure_text from #proctext order by c1 asc
end
go
EXEC dbo.sp_MS_marksystemobject sp_MSscript_pub_upd_trig
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

dump tran master with no_log
go

--
-- sp_scriptsubconflicttable
--
-- This proc is used when the user is creating a nosync queued subscription.
-- It generates the script for creating conflict table on subscriber for a 
-- given queued subscription article. The SP is executed on the publisher.publisher_db 
-- and it generates the script which is executed on the subscriber.subscriber_db
-- See the docs for more information on creation of nosync queued subscription.
-- 
-- Parameters:
--    @publication    sysname - name of publication we are subscribing to
--    @article    sysname - name of the subscribed article
--
-- Return :
--    0 if successfull, 1 otherwise
--
-- Rowset
--    Return script to create the conflict table for the given article
--
print ''
print 'Creating procedure sp_scriptsubconflicttable'
go
create proc sp_scriptsubconflicttable (
	@publication sysname
	,@article sysname
	)
as
begin
	declare @retcode int

    --
    -- Security Check.
    --
	exec @retcode = dbo.sp_MSreplcheck_publish
	if (@@error != 0 or @retcode != 0)
		return (1)

	--
	-- Parameter Check: @publication.
	-- The @publication cannot be NULL and must conform to the rules
	-- for identifiers.
	--
	if (@publication IS NULL)
	begin
		raiserror (14043, 16, 2, '@publication')
		return (1)
	end
	exec @retcode = dbo.sp_validname @publication
	if (@retcode != 0)
		return (1)

	--
	-- Parameter Check: @article.
	-- The @article cannot be NULL and must conform to the rules
	-- for identifiers.
	--	
	if @article IS NULL
	begin
		raiserror (14043, 16, 3, '@article')
		return (1)
	end
	exec @retcode = dbo.sp_MSreplcheck_name @article
	if (@@error != 0 or @retcode != 0)
		return (1)

	if LOWER(@article) = 'all'
	begin
		raiserror (14032, 16, 2, '@article')
		return (1)
	end

	--
	-- now call the SP to generate the script
	--
	exec @retcode = dbo.sp_MSmakeconflicttable @article, @publication, 1
	return @retcode
end
go

EXEC dbo.sp_MS_marksystemobject sp_scriptsubconflicttable
GO

print ''
print 'Creating procedure sp_MSgen_sync_tran_procs'
go
create procedure sp_MSgen_sync_tran_procs (
	@publication    sysname,        -- table name 
	@article        sysname,
	@ins_proc       sysname,
	@upd_proc       sysname,
	@del_proc       sysname,
	@upd_trig		sysname
)
as
begin
    set nocount on

	declare @cmd nvarchar(4000)
			,@procname nvarchar(517)
			,@dbname sysname
			,@owner sysname
			,@retcode int

    select @owner = user_name(o.uid) from sysobjects o , sysarticles a where o.id=a.objid and a.name=@article

    -- We are now going to create procs, so start a transaction
    begin tran gen_procs
		
		-- Call out to individual create proc routines      
		select @dbname = db_name()
		select @cmd = N'sp_MSscript_sync_ins_proc ''' + master.dbo.fn_MSgensqescstr(@publication) collate database_default + 
				N''', ''' + master.dbo.fn_MSgensqescstr(@article) collate database_default  + 
				N''', ''' + master.dbo.fn_MSgensqescstr(@ins_proc) collate database_default + N''''
		exec @retcode = master.dbo.xp_execresultset @cmd, @dbname
		if (@@error != 0 or @retcode != 0)
		begin
			rollback tran gen_procs
			return 1
		end

		select @cmd = N'sp_MSscript_sync_upd_proc ''' + master.dbo.fn_MSgensqescstr(@publication) collate database_default + 
				N''', ''' + master.dbo.fn_MSgensqescstr(@article) collate database_default + 
				N''', ''' + master.dbo.fn_MSgensqescstr(@upd_proc) collate database_default + N''''
		exec @retcode = master.dbo.xp_execresultset @cmd, @dbname
		if (@@error != 0 or @retcode != 0)
		begin
			rollback tran gen_procs
			return 1
		end

		select @cmd = N'sp_MSscript_sync_del_proc ''' + master.dbo.fn_MSgensqescstr(@publication) collate database_default + 
				N''', ''' + master.dbo.fn_MSgensqescstr(@article) collate database_default  + 
				N''', ''' + master.dbo.fn_MSgensqescstr(@del_proc) collate database_default + N''''
		exec @retcode = master.dbo.xp_execresultset @cmd, @dbname
		if (@@error != 0 or @retcode != 0)
		begin
			rollback tran gen_procs
			return 1
		end

		select @cmd = N'sp_MSscript_pub_upd_trig ''' + master.dbo.fn_MSgensqescstr(@publication) collate database_default + 
				N''', ''' + master.dbo.fn_MSgensqescstr(@article) collate database_default  + 
				N''', ''' + master.dbo.fn_MSgensqescstr(@upd_trig) collate database_default + N''''
		exec @retcode = master.dbo.xp_execresultset @cmd, @dbname
		if (@@error != 0 or @retcode != 0)
		begin
			rollback tran gen_procs
			return 1
		end

		-- Grant permissions
		select @cmd = 'grant exec on ' + quotename(@owner) + '.' + quotename(@ins_proc) + ' to public'
		exec (@cmd)
		if (@@error != 0)
		begin
			rollback tran gen_procs
			return 1
		end
		select @cmd = 'grant exec on ' + quotename(@owner) + '.' + quotename(@upd_proc) + ' to public'
		exec (@cmd)
		if (@@error != 0)
		begin
			rollback tran gen_procs
			return 1
		end
		select @cmd = 'grant exec on ' + quotename(@owner) + '.' + quotename(@del_proc) + ' to public'
		exec (@cmd)
		if (@@error != 0)
		begin
			rollback tran gen_procs
			return 1
		end

		-- Mark procedures as system procs so they don't show up in the UI
		if @owner in ('dbo','INFORMATION_SCHEMA')
		begin
			select @procname = @owner + '.' + @ins_proc
			exec @retcode = dbo.sp_MS_marksystemobject @procname
			if (@@error != 0 or @retcode != 0)
			begin
				rollback tran gen_procs
				return 1
			end
			select @procname = @owner + '.' + @upd_proc
			exec @retcode = dbo.sp_MS_marksystemobject @procname
			if (@@error != 0 or @retcode != 0)
			begin
				rollback tran gen_procs
				return 1
			end
			select @procname = @owner + '.' + @del_proc
			exec @retcode = dbo.sp_MS_marksystemobject @procname
			if (@@error != 0 or @retcode != 0)
			begin
				rollback tran gen_procs
				return 1
			end
			select @procname = @owner + '.' + @upd_trig
			exec @retcode = dbo.sp_MS_marksystemobject @procname
			if (@@error != 0 or @retcode != 0)
			begin
				rollback tran gen_procs
				return 1
			end
		end

		-- Mark procedures to set 'NOT FOR REPL' bit
		select @procname = @owner + '.' + @ins_proc
		exec @retcode = dbo.sp_MSmark_proc_norepl @procname
		if (@@error != 0 or @retcode != 0)
		begin
			rollback tran gen_procs
			return 1
		end
		select @procname = @owner + '.' + @upd_proc
		exec @retcode = dbo.sp_MSmark_proc_norepl @procname
		if (@@error != 0 or @retcode != 0)
		begin
			rollback tran gen_procs
			return 1
		end
		select @procname = @owner + '.' + @del_proc
		exec @retcode = dbo.sp_MSmark_proc_norepl @procname
		if (@@error != 0 or @retcode != 0)
		begin
			rollback tran gen_procs
			return 1
		end

    -- Commit tran
    commit tran
end
go

EXEC dbo.sp_MS_marksystemobject sp_MSgen_sync_tran_procs
GO

print ''
print 'Creating procedure sp_articlesynctranprocs'
go

CREATE PROCEDURE sp_articlesynctranprocs
    @publication sysname,         -- publication name 
    @article sysname,              -- article name 
    @ins_proc sysname,       -- name of sproc supporting Sync Tran inserts associated with this article
    @upd_proc sysname,       -- name of sproc supporting Sync Tran updates associated with this article
    @del_proc sysname,       -- name of sproc supporting Sync Tran deletes associated with this article
    @autogen       nvarchar(5) = 'true', -- indicates wether or not to auto generate sprocs
    @upd_trig sysname
AS
    SET NOCOUNT ON

    -- Declarations.
    DECLARE @pubid int
    DECLARE @artid int
    DECLARE @retcode int
    DECLARE @autogen_id bit
    DECLARE @ins_proc_id int
    DECLARE @upd_proc_id int
    DECLARE @del_proc_id int
    DECLARE @upd_trig_id int
    
    /* 
    ** Security Check.
    */
    exec @retcode = dbo.sp_MSreplcheck_publish
    if @@ERROR <> 0 or @retcode <> 0
        return(1)
    
    -- Parameter Check: @article. The @article name cannot be NULL and must conform 
    -- to the rules for identifiers.
    IF @article IS NULL
        BEGIN
            RAISERROR (14043, 16, -1, '@article')
            RETURN (1)
        END

    EXECUTE @retcode = dbo.sp_validname @article
    IF @retcode <> 0
        RETURN(1)
    
    -- Parameter Check: @publication.
    -- The @publication name cannot be NULL and must conform to the rules
    -- for identifiers.
    IF @publication IS NULL
        BEGIN
            RAISERROR (14043, 16, -1, '@publication')
            RETURN (1)
        END

    EXECUTE @retcode = dbo.sp_validname @publication
    IF @retcode <> 0
        RETURN (1)

    -- Parameter Check: @ins_proc, @upd_proc, @del_proc, @upd_trig
    -- The sproc names cannot be NULL and must conform to the rules
    -- for identifiers

    IF @ins_proc IS NULL
        BEGIN
            RAISERROR (14043, 16, -1, '@ins_proc')
            RETURN (1)
        END

    EXECUTE @retcode = dbo.sp_validname @ins_proc
    IF @retcode <> 0
        RETURN (1)

    IF @upd_proc IS NULL
        BEGIN
            RAISERROR (14043, 16, -1, '@upd_proc')
            RETURN (1)
        END

    EXECUTE @retcode = dbo.sp_validname @upd_proc
    IF @retcode <> 0
        RETURN (1)

    IF @del_proc IS NULL
        BEGIN
            RAISERROR (14043, 16, -1, '@del_proc')
            RETURN (1)
        END

    EXECUTE @retcode = dbo.sp_validname @del_proc
    IF @retcode <> 0
        RETURN (1)

    IF @upd_trig IS NULL
        BEGIN
            RAISERROR (14043, 16, -1, '@upd_trig')
            RETURN (1)
        END

    EXECUTE @retcode = dbo.sp_validname @upd_trig
    IF @retcode <> 0
        RETURN (1)

    -- Parameter Check:  @autogen
    IF @autogen IS NULL OR LOWER(@autogen collate SQL_Latin1_General_CP1_CS_AS) NOT IN ('true', 'false')
    BEGIN
        RAISERROR (14148, 16, -1, '@autogen')
        RETURN (1)
    END

    IF LOWER(@autogen collate SQL_Latin1_General_CP1_CS_AS) = 'true' 
        SELECT @autogen_id = 1
    ELSE 
        SELECT @autogen_id = 0

    -- Retrieve pubid & artid
    SELECT @pubid = a.pubid, @artid = a.artid 
    FROM sysarticles a, syspublications p
    WHERE p.name = @publication AND a.name = @article AND
        a.pubid = p.pubid
    IF @pubid IS NULL OR @artid IS NULL
    BEGIN
        if @pubid IS NULL RAISERROR (20026, 16, 1, @publication)
        if @artid IS NULL RAISERROR (20026, 16, 1, @publication)
        RETURN (1)
    END

       BEGIN TRAN sp_articlesynctranprocs

        -- if @autogen is true, generate the sprocs
        IF @autogen_id = 1
        BEGIN
            EXECUTE @retcode =  dbo.sp_MSgen_sync_tran_procs @publication, @article, 
                @ins_proc, @upd_proc, @del_proc, @upd_trig
            IF @retcode <> 0
            BEGIN
                IF @@TRANCOUNT <> 0
                    ROLLBACK tran sp_articlesynctranprocs
                RETURN (1)
            END
        END

        --retrieve sproc id's, fail if they don't exist
        SELECT @ins_proc_id = id FROM sysobjects WHERE name = @ins_proc
        SELECT @upd_proc_id = id FROM sysobjects WHERE name = @upd_proc
        SELECT @del_proc_id = id FROM sysobjects WHERE name = @del_proc
        select @upd_trig_id = id FROM sysobjects WHERE name = @upd_trig

        IF (@ins_proc_id IS NULL) OR (@upd_proc_id IS NULL) OR (@del_proc_id IS NULL) OR
            (@upd_trig_id IS NULL)             
        BEGIN
            if @ins_proc_id IS NULL RAISERROR (20500, 16, 1, @ins_proc)
            if @upd_proc_id IS NULL RAISERROR (20500, 16, 1, @upd_proc)
            if @del_proc_id IS NULL RAISERROR (20500, 16, 1, @del_proc)
            if @upd_trig_id IS NULL RAISERROR (20500, 16, 1, @upd_trig)
            IF @@TRANCOUNT <> 0
                ROLLBACK tran sp_articlesynctranprocs
            RETURN (1)
        END

        -- perform insert into sysarticleupdates
        -- need to mark this as a system table, so this sproc can live in master db
        INSERT sysarticleupdates(pubid, artid, sync_ins_proc, sync_upd_proc, sync_del_proc, autogen, sync_upd_trig)
            VALUES (@pubid, @artid, @ins_proc_id, @upd_proc_id, @del_proc_id, @autogen_id, @upd_trig_id)

        IF @@ERROR <> 0
            BEGIN
                IF @@TRANCOUNT <> 0
                    ROLLBACK tran sp_articlesynctranprocs
                RETURN (1)
            END

    COMMIT TRAN
go

EXEC dbo.sp_MS_marksystemobject sp_articlesynctranprocs
GO

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
GO

dump tran master with no_log
GO



--------------------------------------------------------------------
--------------------------------------------------------------------

print ''
print 'Creating procedure sp_MSareallcolumnscomputed'
go
create procedure sp_MSareallcolumnscomputed @tabid int, @colbitmap binary(32)
as
declare @isset int
declare @retcode int
declare @this_col int

select @retcode = 1

DECLARE hCColid CURSOR LOCAL FAST_FORWARD FOR 
select colid from syscolumns where id = @tabid order by colid asc

OPEN hCColid

FETCH hCColid INTO @this_col

WHILE (@@fetch_status <> -1)
BEGIN
    exec @isset = dbo.sp_isarticlecolbitset @this_col, @colbitmap
    if @isset != 0 and EXISTS (select name from syscolumns where id=@tabid and @this_col=colid and iscomputed<>1)
	BEGIN 
		select @retcode = 0
		break
	END
	FETCH hCColid INTO @this_col
END
CLOSE hCColid
DEALLOCATE hCColid

return @retcode
GO

EXEC dbo.sp_MS_marksystemobject sp_MSareallcolumnscomputed
GO
-----------------------------------------------------------
-----------------------------------------------------------

print ''
print 'Creating procedure sp_MSgettypestringudt'
go

create procedure sp_MSgettypestringudt @tabid int, @colid int, @typestring nvarchar(255) output
as
declare @coltypename sysname
declare @coltype  tinyint
declare @colusertype smallint
declare @collen   smallint
declare @colprec  tinyint
declare @colscale tinyint

select @coltypename = type_name( sc.xusertype ), @colusertype = sc.xusertype, @coltype = sc.xtype,
       @collen = sc.length, @colprec = sc.xprec, @colscale = sc.xscale
from syscolumns sc 
where sc.id = @tabid
and sc.colid = @colid
--and st.xtype = sc.xtype
--and st.xtype = st.xusertype

select @typestring = @coltypename

-- if it's not a user defined type, script out length/prec/scale as necessary
if @colusertype = @coltype 
begin
	if @coltypename in (N'char', N'varchar', N'binary', N'varbinary')
	begin
		select @typestring = @typestring + N'(' + convert(nvarchar,@collen) + N')'
	end
	else if @coltypename in (N'nchar', N'nvarchar' )
	begin
		select @typestring = @typestring + N'(' + convert(nvarchar,@collen/2) + N')'
	end
	else if @coltype = 108 or @coltype = 106
	begin
		select @typestring = @typestring + N'(' + convert(nvarchar,@colprec) + N',' + convert(nvarchar,@colscale) + N')'
	end
	else if @coltype = 189
	begin
		select @typestring = N'binary(8)'
	end
end
    
go

EXEC dbo.sp_MS_marksystemobject sp_MSgettypestringudt
GO

--------------------------------------------------------------------
--------------------------------------------------------------------

print ''
print 'Creating procedure sp_gettypestring'
go

create procedure sp_gettypestring @tabid int, @colid int, @typestring nvarchar(255) output
as
declare @coltypename sysname
declare @coltype  tinyint
declare @colvar   bit
declare @collen   smallint
declare @colprec  tinyint
declare @colscale tinyint

select @coltypename = st.name, @coltype = st.xtype, @colvar = st.variable, 
       @collen = sc.length, @colprec = sc.xprec, @colscale = sc.xscale
from systypes st, syscolumns sc 
where sc.id = @tabid
and sc.colid = @colid
and st.xtype = sc.xtype
and st.xtype = st.xusertype

select @typestring = @coltypename

if @coltypename in (N'char', N'varchar', N'binary', N'varbinary')
begin
    select @typestring = @typestring + N'(' + convert(nvarchar,@collen) + N')'
end
else if @coltypename in (N'nchar', N'nvarchar' )
begin
    select @typestring = @typestring + N'(' + convert(nvarchar,@collen/2) + N')'
end
else if @coltype = 108 or @coltype = 106
begin
    select @typestring = @typestring + N'(' + convert(nvarchar,@colprec) + N',' + convert(nvarchar,@colscale) + N')'
end
else if @coltype = 189
begin
    select @typestring = N'binary(8)'
end
    
go

EXEC dbo.sp_MS_marksystemobject sp_gettypestring
GO

--------------------------------------------------------------------
--------------------------------------------------------------------

raiserror('Creating procedure sp_scriptpkwhereclause', 0,1)
go
create procedure sp_scriptpkwhereclause 
(
@src_objid int, 
@pkcolumns binary(32),
@prefix nvarchar(10) = N'@pkc',
@artcolumns binary(32) = NULL,
@mode tinyint = 1 -- 1 = use article ordering, 2 = column ordering
)
as
begin
    declare @this_col int
    declare @art_col int
    declare @spacer nvarchar(10)
    declare @isset int
    declare @cmd nvarchar(4000)

    declare @modeartorder tinyint
                ,@modecolorder tinyint

    select @modeartorder = 1
            ,@modecolorder = 2
            ,@art_col = 0
            ,@spacer = N' '
            ,@cmd = N'where'

    if (@mode not in (@modeartorder, @modecolorder))
        return 1

    -- create WHERE clause
    DECLARE hCColid CURSOR LOCAL FAST_FORWARD FOR 
    select colid from syscolumns where id = @src_objid order by colid asc

    OPEN hCColid

    FETCH hCColid INTO @this_col

    WHILE (@@fetch_status <> -1)
    begin
        if EXISTS (select name from syscolumns where id=@src_objid and @this_col=colid)
    	begin
    		-- If @artcolumns is not null, it is called from 
    		-- sp_scriptxupdproc or sp_scriptxdelproc
    		-- Use counter in article column bitmap
    		-- Otherwise use counter in pk bitmap
    		if @artcolumns is not null
    		begin
    			exec @isset = dbo.sp_isarticlecolbitset @this_col, @artcolumns
    			if @isset != 0
    				select @art_col = @art_col + 1
    		end
    		exec @isset = dbo.sp_isarticlecolbitset @this_col, @pkcolumns
    		if @isset != 0 
    		begin
    			if @artcolumns is null
    				select @art_col = @art_col + 1
			select @cmd = @cmd + @spacer + QUOTENAME(col_name( @src_objid, @this_col)) + N' = ' 
			--
			-- script the var assignment based on mode
			--
			if (@mode = @modeartorder)
        			select @cmd = @cmd + @prefix + convert( nvarchar, @art_col ) 
    			else
        			select @cmd = @cmd + @prefix + convert( nvarchar, @this_col ) 
    			select @spacer = N' and '
    			if len( @cmd ) > 3000
    			begin
    				insert into #proctext(procedure_text) values( @cmd )
    				select @cmd = N''
    			end
    		end
    	end
    	FETCH hCColid INTO @this_col
    end
    CLOSE hCColid
    DEALLOCATE hCColid

    insert into #proctext(procedure_text) values( @cmd )
end
go
EXEC dbo.sp_MS_marksystemobject sp_scriptpkwhereclause
GO

--------------------------------------------------------------------
--------------------------------------------------------------------

print ''
print 'sp_MSscript_missing_row_check'
go

create procedure sp_MSscript_missing_row_check 
as

-- Note this must be done immediately after the update or delete statement.
-- create WHERE clause

insert into #proctext(procedure_text) values( N'if @@rowcount = 0' )
begin
	insert into #proctext(procedure_text) values( N'	if @@microsoftversion>0x07320000' )
	insert into #proctext(procedure_text) values( N'		exec sp_MSreplraiserror 20598' )
end
go

EXEC dbo.sp_MS_marksystemobject sp_MSscript_missing_row_check
GO

--------------------------------------------------------------------
--------------------------------------------------------------------

print ''
print 'Create procedure sp_scriptupdateparams'
go

create procedure sp_scriptupdateparams @src_objid int, @artcolumns binary(32), 
@pkcolumns binary(32), -- If it is null we are called by sp_scriptxupdproc
@param_count int = NULL output
as
declare @this_col int
declare @art_col int
declare @spacer nvarchar(10)
declare @isset int
declare @cmd nvarchar(4000)
declare @typestring nvarchar(255)

-- add colval parameters
select @param_count = NULL
select @art_col = 1
select @spacer = N' '
select @cmd = ''

DECLARE hCColid CURSOR LOCAL FAST_FORWARD FOR 
select colid from syscolumns where id = @src_objid order by colid asc

OPEN hCColid

FETCH hCColid INTO @this_col

WHILE ( 1 = 1 )
begin
	if @@fetch_status = -1
	begin
		-- If called by sp_scriptxupdproc and it is the first time
		-- at the end of the cursor loop
		if @pkcolumns is null and @param_count is NULL
		begin
			-- Reset it so that we know we encountered cursor end once.
			select @param_count = 0
			-- Reopen cursor
			CLOSE hCColid
			OPEN hCColid
			FETCH hCColid INTO @this_col
			continue
		end
		else
			break;
	end
	exec @isset = dbo.sp_isarticlecolbitset @this_col, @artcolumns
	if @isset != 0 and EXISTS (select name from syscolumns where id=@src_objid and @this_col=colid and iscomputed<>1)
	begin
		exec dbo.sp_gettypestring @src_objid, @this_col, @typestring OUTPUT
		select @cmd = @cmd + @spacer + N'@c' + convert( nvarchar, @art_col ) + N' ' + @typestring 
		select @art_col = @art_col + 1
		select @spacer = N','

		if len( @cmd ) > 3000
		begin
		insert into #proctext(procedure_text) values( @cmd )
			select @cmd = N''
		end
	end
	FETCH hCColid INTO @this_col
end
CLOSE hCColid
DEALLOCATE hCColid

select @param_count = @art_col -1

-- add pkval parameters
-- If it is null we are called by sp_scriptxupdproc, no need for PK params
if @pkcolumns is not null
begin
	select @art_col = 1

	DECLARE hCColid CURSOR LOCAL FAST_FORWARD FOR 
	select colid from syscolumns where id = @src_objid order by colid asc

	OPEN hCColid

	FETCH hCColid INTO @this_col

	WHILE (@@fetch_status <> -1)
	begin
	   exec @isset = dbo.sp_isarticlecolbitset @this_col, @pkcolumns
	   if @isset != 0 and EXISTS (select name from syscolumns where id=@src_objid and @this_col=colid )
	   begin
			exec dbo.sp_gettypestring @src_objid, @this_col, @typestring OUTPUT
			select @cmd = @cmd + @spacer + N'@pkc' + convert( nvarchar, @art_col ) + N' ' + @typestring 
			select @art_col = @art_col + 1
			select @spacer = N','

			if len( @cmd ) > 3000
			begin
			insert into #proctext(procedure_text) values( @cmd )
				select @cmd = N''
			end
		end
		FETCH hCColid INTO @this_col
	end
	CLOSE hCColid
	DEALLOCATE hCColid
end

insert into #proctext(procedure_text) values ( @cmd )

go

EXEC dbo.sp_MS_marksystemobject sp_scriptupdateparams
GO


print ''
print 'Creating procedure sp_scriptreconwhereclause'
go

create procedure sp_scriptreconwhereclause @src_objid int, @pkcolumns binary(32), @artcolumns binary(32)
as
declare @this_col int
declare @art_col int
declare @spacer nvarchar(10)
declare @isset int
declare @cmd nvarchar(4000)

-- create WHERE clause

select @art_col = 1
select @spacer = N' '
select @cmd = N'where'

DECLARE hCColid CURSOR LOCAL FAST_FORWARD FOR 
select colid from syscolumns where id = @src_objid order by colid asc

OPEN hCColid

FETCH hCColid INTO @this_col

WHILE (@@fetch_status <> -1)
begin
	exec @isset = dbo.sp_isarticlecolbitset @this_col, @artcolumns
	if @isset != 0 and EXISTS (select name from syscolumns where id=@src_objid and @this_col=colid )
	begin
		exec @isset = dbo.sp_isarticlecolbitset @this_col, @pkcolumns
		if @isset != 0 
		begin
			select @cmd = @cmd + @spacer + QUOTENAME(col_name( @src_objid, @this_col)) + N' = @c' + convert( nvarchar, @art_col ) 
			select @spacer = N' and '

			if len( @cmd ) > 3000
			begin
				insert into #proctext(procedure_text) values( @cmd )
				select @cmd = N''
			end
		end
		select @art_col = @art_col + 1
	end
	FETCH hCColid INTO @this_col
end
CLOSE hCColid
DEALLOCATE hCColid

insert into #proctext(procedure_text) values( @cmd )

go

EXEC dbo.sp_MS_marksystemobject sp_scriptreconwhereclause
GO

--
-- Name: sp_script_reconciliation_insproc
--
-- Description: This procedure is used by Snapshot agent to script the custom 
-- command procedure for INSERT. This scripts a reconciliation custom 
-- proc - used only during initialization. 
-- Invoked on publisher.
--
-- Parameter: Refer to the comments in the create procedure statement
--
-- Returns: 1 or 0   0 = success
--
-- Security: Public procedure - does publisher security check. 
--
raiserror('Creating procedure sp_script_reconciliation_insproc', 0,1)
go
create procedure sp_script_reconciliation_insproc (
	@artid int)
as
BEGIN
declare @retcode int
declare @cmd          nvarchar(4000)
declare @dest_owner   nvarchar(255)
declare @dest_tabname sysname
declare @src_objid    int
declare @artcolumns   binary(32)
declare @pkcolumns    binary(32)
declare @ins_cmd      nvarchar(255)
declare @dest_proc    sysname
declare @this_col     int
declare @art_col      int
declare @isset        int

declare @typestring   nvarchar(255)
declare @spacer       nvarchar(1)
	, @identity_insert bit
	
--
-- security check
--
exec @retcode = dbo.sp_MSreplcheck_publish
if @@error <> 0 or @retcode <> 0
begin
    return (1)
end

if not exists( select * from sysarticles where artid = @artid AND (type & 1) = 1 )
begin
    raiserror (14155, 16, 1 )
    return 1
end

-------- create temp table for command fragments

create table #proctext ( c1 int identity NOT NULL, procedure_text nvarchar(4000) collate database_default null)

-------- get sysarticles information

select @dest_owner = dest_owner, @dest_tabname = dest_table, 
       @src_objid = objid, @artcolumns = columns, @ins_cmd = ins_cmd
from sysarticles
where artid = @artid

if @dest_owner is not null
begin
	select @dest_owner = QUOTENAME( @dest_owner ) + N'.'
end
else
begin
	select @dest_owner = N''
end

-- Check to see if identity insert must be turned on
-- i.e. Does the table has identity that are included in the partition?
exec sp_MSis_identity_insert null, null, @identity_insert output, @artid
--

-------- get dest proc name

if( 1 != charindex( N'CALL', upper(@ins_cmd collate SQL_Latin1_General_CP1_CS_AS) ) ) or @ins_cmd is null
begin
    raiserror (14156, 16, 1 )
    return 1
end

select @dest_proc = substring( @ins_cmd, 6, len( @ins_cmd ) - 4 )
select @cmd = N'create procedure ' + QUOTENAME(@dest_proc) + N';2'

-------- construct parameter list


select @art_col = 1
select @spacer = N' '

DECLARE hCColid CURSOR LOCAL FAST_FORWARD FOR 
select colid from syscolumns where id = @src_objid order by colid asc

OPEN hCColid

FETCH hCColid INTO @this_col

WHILE (@@fetch_status <> -1)
begin
   exec @isset = dbo.sp_isarticlecolbitset @this_col, @artcolumns
   if @isset != 0 and EXISTS (select name from syscolumns where id=@src_objid and @this_col=colid and iscomputed<>1)
   begin
        if len( @cmd ) > 3000
        begin
        insert into #proctext(procedure_text) values( @cmd )
            select @cmd = N''
        end

        exec dbo.sp_gettypestring @src_objid, @this_col, @typestring OUTPUT
        select @cmd = @cmd + @spacer + N'@c' + convert( nvarchar, @art_col ) + N' ' + @typestring 
        select @art_col = @art_col + 1
        select @spacer = N','
   end
   FETCH hCColid INTO @this_col
end
CLOSE hCColid
DEALLOCATE hCColid


-- save off cmd fragment

insert into #proctext(procedure_text) values( @cmd )

insert into #proctext(procedure_text) values( N'as' )

------- construct proc body

---- if already exists, apply as update

insert into #proctext(procedure_text) 
    values( N'if exists ( select * from ' + @dest_owner + QUOTENAME(@dest_tabname) )
exec dbo.sp_getarticlepkcolbitmap @src_objid, @pkcolumns output
exec dbo.sp_scriptreconwhereclause @src_objid, @pkcolumns, @artcolumns
insert into #proctext(procedure_text) values( N')' )
insert into #proctext(procedure_text) values (N'begin')


if( @artcolumns != @pkcolumns )
begin
	-- construct update 

	select @cmd = N'update ' + @dest_owner + QUOTENAME(@dest_tabname) + N' set'

	-- create SET clause

	select @art_col = 1
	select @spacer = N' '

	DECLARE hCColid CURSOR LOCAL FAST_FORWARD FOR 
	select colid from syscolumns where id = @src_objid order by colid asc

	OPEN hCColid

	FETCH hCColid INTO @this_col

	WHILE (@@fetch_status <> -1)
	begin
		exec @isset = dbo.sp_isarticlecolbitset @this_col, @artcolumns
		if @isset != 0  and EXISTS (select name from syscolumns where id=@src_objid and @this_col=colid and iscomputed<>1)
		begin
			exec @isset = dbo.sp_isarticlecolbitset @this_col, @pkcolumns
			if @isset = 0
			begin
				if not (@identity_insert = 1 and 
					columnproperty(@src_objid, col_name( @src_objid, @this_col), 'IsIdentity') = 1)
				begin
					select @cmd = @cmd + @spacer + QUOTENAME(col_name( @src_objid, @this_col)) + N' = @c' + convert( nvarchar, @art_col ) 
					select @spacer = N','

					if len( @cmd ) > 3000
					begin
						insert into #proctext(procedure_text) values( @cmd )
						select @cmd = N''
					end
				end
			end
			select @art_col = @art_col + 1
		end
		FETCH hCColid INTO @this_col
   	end
	CLOSE hCColid
	DEALLOCATE hCColid

	insert into #proctext(procedure_text) values( @cmd )

	exec dbo.sp_scriptreconwhereclause @src_objid, @pkcolumns, @artcolumns
end

-- all article columns are included in the PK, & PK already exists, do nothing
else 
begin
	insert into #proctext(procedure_text ) values( N'return' )
end


insert into #proctext(procedure_text) values (N'end')
insert into #proctext(procedure_text) values (N'else')
insert into #proctext(procedure_text) values (N'begin')

---- normal insert

-- set identity_insert on
if @identity_insert = 1
begin
	select @cmd = N'
set identity_insert ' + @dest_owner + QUOTENAME(@dest_tabname) + ' on'
	insert into #proctext(procedure_text) values( @cmd )
end

-- prepare the column list

select @cmd = N'insert into ' + @dest_owner + QUOTENAME(@dest_tabname) + N' ('
select @art_col = 1
select @spacer = N' '

DECLARE hCColid CURSOR LOCAL FAST_FORWARD FOR 
select colid from syscolumns where id = @src_objid order by colid asc

OPEN hCColid

FETCH hCColid INTO @this_col

WHILE (@@fetch_status <> -1)
begin
    exec @isset = dbo.sp_isarticlecolbitset @this_col, @artcolumns
    if @isset != 0 and EXISTS (select name from syscolumns where colid=@this_col and iscomputed<>1 and id = @src_objid)
    begin
        if len( @cmd ) > 3000
        begin
        insert into #proctext(procedure_text) values( @cmd )
            select @cmd = N''
        end

        select @cmd = @cmd + @spacer + QUOTENAME(col_name( @src_objid, @this_col))  
        select @art_col = @art_col + 1
        select @spacer = N','
    end
	FETCH hCColid INTO @this_col
end
CLOSE hCColid
DEALLOCATE hCColid

-- now the data parameter list

select @cmd = @cmd + N' ) values ('
select @art_col = 1
select @spacer = N' '

DECLARE hCColid CURSOR LOCAL FAST_FORWARD FOR 
select colid from syscolumns where id = @src_objid order by colid asc

OPEN hCColid

FETCH hCColid INTO @this_col

WHILE (@@fetch_status <> -1)
begin
    exec @isset = dbo.sp_isarticlecolbitset @this_col, @artcolumns
    if @isset != 0 and EXISTS (select name from syscolumns where colid=@this_col and iscomputed<>1 and id = @src_objid)
    begin
        if len( @cmd ) > 3000
        begin
        insert into #proctext(procedure_text) values( @cmd )
            select @cmd = N''
        end

        select @cmd = @cmd + @spacer + N'@c' + convert( nvarchar, @art_col ) 
        select @art_col = @art_col + 1
        select @spacer = N','
    end
	FETCH hCColid INTO @this_col
end
CLOSE hCColid
DEALLOCATE hCColid

-- finish up proc body

select @cmd = @cmd + N' )'

-- save off cmd fragement

insert into #proctext(procedure_text) values( @cmd )

-- set identity_insert off
if @identity_insert = 1
begin
	select @cmd = N'
set identity_insert ' + @dest_owner + QUOTENAME(@dest_tabname) + ' off'
	insert into #proctext(procedure_text) values( @cmd )
end

insert into #proctext(procedure_text) values (N'end')

-- send fragments to client

select procedure_text from #proctext order by c1 asc
END
go

EXEC dbo.sp_MS_marksystemobject sp_script_reconciliation_insproc
GO

--
-- Name: sp_script_reconciliation_delproc
--
-- Description: This procedure is used by Snapshot agent to script the custom command procedure 
-- for DELETE. This scripts a reconciliation custom proc - used only during initialization. 
-- Invoked on publisher.
--
-- Parameter: Refer to the comments in the create procedure statement
--
-- Returns: 1 or 0   0 = success
--
-- Security: Public procedure - does publisher security check. 
--
raiserror('Creating procedure sp_script_reconciliation_delproc', 0,1)
go
create procedure sp_script_reconciliation_delproc 
( 
	@artid int
)
as
begin
    declare @retcode int
    declare @cmd          nvarchar(4000)
    declare @dest_owner   nvarchar(255)
    declare @dest_tabname sysname
    declare @src_objid    int
    declare @pkcolumns    binary(32)
    declare @del_cmd      nvarchar(255)
    declare @dest_proc    sysname
    declare @this_col     int
    declare @art_col      int
    declare @isset        int

    declare @typestring   nvarchar(255)
    declare @spacer       nvarchar(10)

    --
    -- security check
    --
    exec @retcode = dbo.sp_MSreplcheck_publish
    if @@error <> 0 or @retcode <> 0
    begin
        return (1)
    end

    if not exists( select * from sysarticles where artid = @artid AND (type & 1) = 1 )
    begin
        raiserror (14155, 16, 1 )
        return 1
    end

    -------- create temp table for command fragments

    create table #proctext ( c1 int identity NOT NULL, procedure_text nvarchar(4000) collate database_default null)

    -- get sysarticles information

    select @dest_owner = dest_owner, @dest_tabname = dest_table, 
           @src_objid = objid, @del_cmd = del_cmd
    from sysarticles
    where artid = @artid

    if @dest_owner is not null
    begin
    	select @dest_owner = QUOTENAME( @dest_owner ) + N'.'
    end
    else
    begin
    	select @dest_owner = N''
    end

    -------- get dest proc name

    if( 1 != charindex( N'CALL', upper(@del_cmd collate SQL_Latin1_General_CP1_CS_AS) ) ) or @del_cmd is null
    begin
        raiserror (14156, 16, 1 )
        return 1
    end

    select @dest_proc = substring( @del_cmd, 6, len( @del_cmd ) - 4 )
    select @cmd = N'create procedure ' + QUOTENAME(@dest_proc) + N';2'


    -------- construct parameter list


    select @art_col = 1
    select @spacer = N' '

    exec dbo.sp_getarticlepkcolbitmap @src_objid, @pkcolumns output

    DECLARE hCColid CURSOR LOCAL FAST_FORWARD FOR 
    select colid from syscolumns where id = @src_objid order by colid asc

    OPEN hCColid

    FETCH hCColid INTO @this_col

    WHILE (@@fetch_status <> -1)
    begin
       exec @isset = dbo.sp_isarticlecolbitset @this_col, @pkcolumns
       if @isset != 0 and EXISTS (select name from syscolumns where id=@src_objid and @this_col=colid )
       begin
            if len( @cmd ) > 3000
            begin
            insert into #proctext(procedure_text) values( @cmd )
                select @cmd = N''
            end

            exec dbo.sp_gettypestring @src_objid, @this_col, @typestring OUTPUT
            select @cmd = @cmd + @spacer + N'@pkc' + convert( nvarchar, @art_col ) + N' ' + @typestring 
            select @art_col = @art_col + 1
            select @spacer = N','
       end
    	FETCH hCColid INTO @this_col
    end

    CLOSE hCColid
    DEALLOCATE hCColid

    -- save off 

    insert into #proctext(procedure_text) values( @cmd )
    insert into #proctext(procedure_text) values( N'as' )

    ------- construct proc body

    insert into #proctext(procedure_text) values( N'delete ' + @dest_owner + QUOTENAME(@dest_tabname) ) 

    exec dbo.sp_scriptpkwhereclause @src_objid, @pkcolumns

    -- flush to client

    select procedure_text from #proctext order by c1 asc
end
go

EXEC dbo.sp_MS_marksystemobject sp_script_reconciliation_delproc
GO

--
-- Name: sp_script_reconciliation_xdelproc
--
-- Description: This procedure is used by Snapshot agent to script the custom command procedure 
-- for DELETE in XCALL format. This scripts a reconciliation custom proc - used only during initialization. 
-- Invoked on publisher.
--
-- Parameter: Refer to the comments in the create procedure statement
--
-- Returns: 1 or 0   0 = success
--
-- Security: Public procedure - does publisher security check. 
--
raiserror('Creating procedure sp_script_reconciliation_xdelproc', 0,1)
go
create procedure sp_script_reconciliation_xdelproc 
(
    @artid int
)
as
begin
    declare @retcode int
    declare @cmd          nvarchar(4000)
    declare @dest_owner   nvarchar(255)
    declare @dest_tabname sysname
    declare @src_objid    int
    declare @columns    binary(32)
    declare @pkcolumns    binary(32)
    declare @del_cmd      nvarchar(255)
    declare @dest_proc    sysname
    declare @this_col     int
    declare @art_col      int
    declare @isset        int

    declare @typestring   nvarchar(255)
    declare @spacer       nvarchar(10)

    --
    -- security check
    --
    exec @retcode = dbo.sp_MSreplcheck_publish
    if @@error <> 0 or @retcode <> 0
    begin
        return (1)
    end

    if not exists( select * from sysarticles where artid = @artid AND (type & 1) = 1 )
    begin
        raiserror (14155, 16, 1 )
        return 1
    end

    -------- create temp table for command fragments

    create table #proctext ( c1 int identity NOT NULL, procedure_text nvarchar(4000) collate database_default null)

    -- get sysarticles information

    select @dest_owner = dest_owner, @dest_tabname = dest_table, 
           @src_objid = objid, @del_cmd = del_cmd, @columns = columns
    from sysarticles
    where artid = @artid

    if @dest_owner is not null
    begin
    	select @dest_owner = QUOTENAME( @dest_owner ) + N'.'
    end
    else
    begin
    	select @dest_owner = N''
    end

    -------- get dest proc name

    if( 1 != charindex( N'XCALL', upper(@del_cmd collate SQL_Latin1_General_CP1_CS_AS) ) ) or @del_cmd is null
    begin
        raiserror (14156, 16, 1 )
        return 1
    end

    select @dest_proc = substring( @del_cmd, 7, len( @del_cmd ) - 5 )
    select @cmd = N'create procedure ' + QUOTENAME(@dest_proc) + N';2'

    -------- construct parameter list


    select @art_col = 1
    select @spacer = N' '

    exec dbo.sp_getarticlepkcolbitmap @src_objid, @pkcolumns output

    DECLARE hCColid CURSOR LOCAL FAST_FORWARD FOR 
    select colid from syscolumns where id = @src_objid order by colid asc

    OPEN hCColid

    FETCH hCColid INTO @this_col

    WHILE (@@fetch_status <> -1)
    begin
       exec @isset = dbo.sp_isarticlecolbitset @this_col, @columns
       if @isset != 0 and EXISTS (select name from syscolumns where id=@src_objid and @this_col=colid and iscomputed<>1)
       begin
            if len( @cmd ) > 3000
            begin
            insert into #proctext(procedure_text) values( @cmd )
                select @cmd = N''
            end

            exec dbo.sp_gettypestring @src_objid, @this_col, @typestring OUTPUT
            select @cmd = @cmd + @spacer + N'@c' + convert( nvarchar, @art_col ) + N' ' + @typestring 
            select @art_col = @art_col + 1
            select @spacer = N','
       end
       FETCH hCColid INTO @this_col
    end

    CLOSE hCColid
    DEALLOCATE hCColid

    -- save off 

    insert into #proctext(procedure_text) values( @cmd )
    insert into #proctext(procedure_text) values( N'as' )

    ------- construct proc body

    insert into #proctext(procedure_text) values( N'delete ' + @dest_owner + QUOTENAME(@dest_tabname) ) 

    exec dbo.sp_scriptpkwhereclause @src_objid, @pkcolumns, N'@c', @columns

    -- flush to client

    select procedure_text from #proctext order by c1 asc
end
go
EXEC dbo.sp_MS_marksystemobject sp_script_reconciliation_xdelproc
GO

--
-- Name: sp_scriptinsproc
--
-- Description: This procedure is used by Snapshot agent to script the custom command procedure 
-- for INSERT for CALL format. Invoked on publisher.
--
-- Parameter: Refer to the comments in the create procedure statement
--
-- Returns: 1 or 0   0 = success
--
-- Security: Public procedure - does publisher security check. 
--
raiserror('Creating procedure sp_scriptinsproc', 0,1)
go
create procedure sp_scriptinsproc (
	@artid int)
as
BEGIN
declare @cmd          nvarchar(4000)
		,@dest_owner   nvarchar(255)
		,@dest_tabname sysname
		,@src_objid    int
		,@columns      binary(32)
		,@ins_cmd      nvarchar(255)
		,@dest_proc    sysname
		,@this_col     int
		,@art_col      int
		,@isset        int
		,@pubid		  int

		,@identity_insert bit
		,@rc int
		,@colname sysname
		,@ccoltype     sysname
		,@typestring   nvarchar(255)
		,@spacer       nvarchar(1)
		,@queued_check bit
		,@column_string nvarchar(4000)
		,@var_string nvarchar(4000)

set nocount on
--
-- security check
--
exec @rc = dbo.sp_MSreplcheck_publish
if @@error <> 0 or @rc <> 0
begin
    return (1)
end

if not exists( select * from sysarticles where artid = @artid AND (type & 1) = 1 )
begin
    raiserror (14155, 16, 1 )
    return 1
end

-------- create temp table for command fragments and insert column list

create table #proctext ( c1 int identity NOT NULL, procedure_text nvarchar(4000) collate database_default null)
create table #collisttab ( c1 int identity NOT NULL, procedure_text nvarchar(4000) collate database_default null)

-------- get sysarticles information

select @dest_owner = dest_owner, @dest_tabname = dest_table, 
       @src_objid = objid, @columns = columns, @ins_cmd = ins_cmd,
       @pubid = pubid
from sysarticles
where artid = @artid

-- Check to see if identity insert must be turned on
-- i.e. Does the table has identity that are included in the partition?
exec sp_MSis_identity_insert null, null, @identity_insert output, @artid
--

if @dest_owner is not null
begin
	select @dest_owner = QUOTENAME( @dest_owner ) + N'.'
end
else
begin
	select @dest_owner = N''
end

-- Check if this is a queued publication
select @queued_check = ISNULL(allow_queued_tran, 0) 
from syspublications
where pubid = @pubid

-------- get dest proc name

if( 1 != charindex( N'CALL', upper(@ins_cmd collate SQL_Latin1_General_CP1_CS_AS) ) ) or @ins_cmd is null
begin
    raiserror (14156, 16, 1 )
    return 1
end

select @dest_proc = substring( @ins_cmd, 6, len( @ins_cmd ) - 4 )
select @cmd = N'if exists (select * from sysobjects where type = ''P'' and name = ''' + replace(@dest_proc, N'''', N'''''') + N''')  drop proc ' + QUOTENAME(@dest_proc)
insert into #proctext(procedure_text) values( @cmd )
insert into #proctext(procedure_text) values( N'go' )
select @cmd = N'create procedure ' + QUOTENAME(@dest_proc)

-------- construct parameter list


select @art_col = 1
select @spacer = N' '

DECLARE hCColid CURSOR LOCAL FAST_FORWARD FOR 
select colid from syscolumns where id = @src_objid order by colid asc

OPEN hCColid

FETCH hCColid INTO @this_col

WHILE (@@fetch_status <> -1)
begin
   exec @isset = dbo.sp_isarticlecolbitset @this_col, @columns
   if @isset != 0 and EXISTS (select name from syscolumns where id=@src_objid and @this_col=colid and iscomputed<>1)
   begin
        if len( @cmd ) > 3000
        begin
        insert into #proctext(procedure_text) values( @cmd )
            select @cmd = N''
        end

        exec dbo.sp_gettypestring @src_objid, @this_col, @typestring OUTPUT
        select @cmd = @cmd + @spacer + N'@c' + convert( nvarchar, @art_col ) + N' ' + @typestring 
        select @art_col = @art_col + 1
        select @spacer = N','
   end
   FETCH hCColid INTO @this_col
end

CLOSE hCColid
DEALLOCATE hCColid

-- save off cmd fragment

insert into #proctext(procedure_text) values( @cmd )

select @cmd = N'
AS
BEGIN
'
insert into #proctext(procedure_text) values( @cmd )

------- construct proc body

-- Generate strings for col names and variables
select @art_col = 0
select @spacer = N' '

DECLARE hCColid CURSOR LOCAL FAST_FORWARD FOR 
select colid from syscolumns where id = @src_objid order by colid asc

OPEN hCColid

FETCH hCColid INTO @this_col

WHILE (@@fetch_status <> -1)
begin
	exec @rc = dbo.sp_MSget_colinfo @src_objid, @this_col, @columns, 1, @colname output, @ccoltype output
	if @rc = 0  and EXISTS (select name from syscolumns where id=@src_objid and colid=@this_col and iscomputed<>1)
	begin
		select @art_col = @art_col + 1
		if (@art_col = 1)
		begin
			select @column_string = QUOTENAME(@colname)
			select @var_string = N'@c' + cast(@art_col as nvarchar(4))
		end
		else
		begin
			select @column_string = @column_string + N', ' + QUOTENAME(@colname)
			select @var_string = @var_string + N', @c' + cast(@art_col as nvarchar(4))
		end

		-- transfer column list string to table if too large
		if (len(@column_string) > 3000)
		begin
			insert into #collisttab(procedure_text) values( @column_string )
			select @column_string = ' '
		end
	end
	FETCH hCColid INTO @this_col
end

CLOSE hCColid
DEALLOCATE hCColid

-- insert the remaining strings for column list and where clause
insert into #collisttab(procedure_text) values( @column_string )

--
-- If we are a part of queued publication then 
-- insert only if PK or other unique key(s) do not exist
--
if (@queued_check = 1)
begin
    select @cmd = N'
if not exists (select * from ' + @dest_owner + QUOTENAME(@dest_tabname) + N' '
    insert into #proctext(procedure_text) values( @cmd )
    exec @rc = sp_replscriptuniquekeywhereclause @tabid = @src_objid
                                                        ,@columns = @columns
                                                        ,@prefix = '@c' 
                                                        ,@mode = 1
    if (@@error != 0 or @rc != 0)
        return 1
    select @cmd = N')
BEGIN'
    insert into #proctext(procedure_text) values( @cmd )
end

-- set identity_insert on
if @identity_insert = 1
begin
	select @cmd = N'
	set identity_insert ' + @dest_owner + QUOTENAME(@dest_tabname) + ' on'
	insert into #proctext(procedure_text) values( @cmd )
end

--
-- prepare the insert statement now
--
select @cmd = N'
insert into ' +  @dest_owner + QUOTENAME(@dest_tabname)  + N'( '
insert into #proctext(procedure_text) values( @cmd )
insert into #proctext(procedure_text) 
	select procedure_text from #collisttab order by c1 asc
select @cmd = N' )'
insert into #proctext(procedure_text) values( @cmd )
if @art_col > 0
begin
	select @cmd = N'
values ( '
	insert into #proctext(procedure_text) values( @cmd )
	insert into #proctext(procedure_text) values( @var_string )
	select @cmd = N' )
'
	insert into #proctext(procedure_text) values( @cmd )
end

-- set identity_insert off
if @identity_insert = 1
begin
	select @cmd = N'
	set identity_insert ' + @dest_owner + QUOTENAME(@dest_tabname) + ' off'
	insert into #proctext(procedure_text) values( @cmd )
end

--
-- If we are a part of queued publication then 
-- add the block delimiter
--
drop table #collisttab
if (@queued_check = 1)
begin
	select @cmd = N'
END
END'
end
else
	select @cmd = N'
END'
insert into #proctext(procedure_text) values( @cmd )

-- send fragements to client

select procedure_text from #proctext order by c1 asc
END
go
EXEC dbo.sp_MS_marksystemobject sp_scriptinsproc
GO

--
-- Name: sp_scriptdelproc
--
-- Description: This procedure is used by Snapshot agent to script the custom command procedure 
-- for DELETE in CALL format. Invoked on publisher.
--
-- Parameter: Refer to the comments in the create procedure statement
--
-- Returns: 1 or 0   0 = success
--
-- Security: Public procedure - does publisher security check. 
--
raiserror('Creating procedure sp_scriptdelproc', 0,1)
go
create procedure sp_scriptdelproc 
(
    @artid int
)
as
begin
    declare @retcode int
    declare @cmd          nvarchar(4000)
    declare @dest_owner   nvarchar(255)
    declare @dest_tabname sysname
    declare @src_objid    int
    declare @pkcolumns    binary(32)
    declare @del_cmd      nvarchar(255)
    declare @dest_proc    sysname
    declare @this_col     int
    declare @art_col      int
    declare @isset        int, @pubid int

    declare @typestring   nvarchar(255)
    declare @spacer       nvarchar(10)

    --
    -- security check
    --
    exec @retcode = dbo.sp_MSreplcheck_publish
    if @@error <> 0 or @retcode <> 0
    begin
        return (1)
    end
    
    if not exists( select * from sysarticles where artid = @artid AND (type & 1) = 1 )
    begin
        raiserror (14155, 16, 1 )
        return 1
    end

    -------- create temp table for command fragments

    create table #proctext ( c1 int identity NOT NULL, procedure_text nvarchar(4000) collate database_default null)

    -- get sysarticles information

    select @dest_owner = dest_owner, @dest_tabname = dest_table, 
           @src_objid = objid, @del_cmd = del_cmd, @pubid = pubid
    from sysarticles
    where artid = @artid

    if @dest_owner is not null
    begin
    	select @dest_owner = QUOTENAME( @dest_owner ) + N'.'
    end
    else
    begin
    	select @dest_owner = N''
    end

    -------- get dest proc name

    if( 1 != charindex( N'CALL', upper(@del_cmd collate SQL_Latin1_General_CP1_CS_AS) ) ) or @del_cmd is null
    begin
        raiserror (14156, 16, 1 )
        return 1
    end

    select @dest_proc = substring( @del_cmd, 6, len( @del_cmd ) - 4 )
    select @cmd = N'if exists (select * from sysobjects where type = ''P'' and name = ''' + replace(@dest_proc, N'''', N'''''') + N''')  drop proc ' + QUOTENAME(@dest_proc)
    insert into #proctext(procedure_text) values( @cmd )
    insert into #proctext(procedure_text) values( N'go' )
    select @cmd = N'create procedure ' + QUOTENAME(@dest_proc)

    -------- construct parameter list


    select @art_col = 1
    select @spacer = N' '

    exec dbo.sp_getarticlepkcolbitmap @src_objid, @pkcolumns output

    DECLARE hCColid CURSOR LOCAL FAST_FORWARD FOR 
    select colid from syscolumns where id = @src_objid order by colid asc

    OPEN hCColid

    FETCH hCColid INTO @this_col

    WHILE (@@fetch_status <> -1)
    begin
       exec @isset = dbo.sp_isarticlecolbitset @this_col, @pkcolumns
       if @isset != 0 and EXISTS (select name from syscolumns where id=@src_objid and @this_col=colid )
       begin
            if len( @cmd ) > 3000
            begin
            insert into #proctext(procedure_text) values( @cmd )
                select @cmd = N''
            end

            exec dbo.sp_gettypestring @src_objid, @this_col, @typestring OUTPUT
            select @cmd = @cmd + @spacer + N'@pkc' + convert( nvarchar, @art_col ) + N' ' + @typestring 
            select @art_col = @art_col + 1
            select @spacer = N','
       end
    	FETCH hCColid INTO @this_col
    end

    CLOSE hCColid
    DEALLOCATE hCColid

    -- save off 

    insert into #proctext(procedure_text) values( @cmd )
    insert into #proctext(procedure_text) values( N'as' )

    ------- construct proc body

    insert into #proctext(procedure_text) values( N'delete ' + @dest_owner + QUOTENAME(@dest_tabname) ) 

    exec dbo.sp_scriptpkwhereclause @src_objid, @pkcolumns

    if exists (select * from syspublications where pubid = @pubid and allow_queued_tran = 0)
    	exec dbo.sp_MSscript_missing_row_check
    -- flush to client

    select procedure_text from #proctext order by c1 asc
end
go
EXEC dbo.sp_MS_marksystemobject sp_scriptdelproc
GO

--
-- Name: sp_scriptxdelproc
--
-- Description: This procedure is used by Snapshot agent to script the custom command procedure 
-- for DELETE in XCALL format. Invoked on publisher.
--
-- Parameter: Refer to the comments in the create procedure statement
--
-- Returns: 1 or 0   0 = success
--
-- Security: Public procedure - does publisher security check. 
--
raiserror('Creating procedure sp_scriptxdelproc', 0,1)
go
create procedure sp_scriptxdelproc 
(
    @artid int
)
as
begin
    declare @retcode int
    declare @cmd          nvarchar(4000)
    declare @dest_owner   nvarchar(255)
    declare @dest_tabname sysname
    declare @src_objid    int
    declare @columns    binary(32)
    declare @pkcolumns    binary(32)
    declare @del_cmd      nvarchar(255)
    declare @dest_proc    sysname
    declare @this_col     int
    declare @art_col      int
    declare @isset        int
    declare @pubid		  int
    declare @typestring   nvarchar(255)
    declare @spacer       nvarchar(10)
    declare @queued_check bit
    		,@qwhere_string nvarchar(4000)

    --
    -- security check
    --
    exec @retcode = dbo.sp_MSreplcheck_publish
    if @@error <> 0 or @retcode <> 0
    begin
        return (1)
    end
    
    if not exists( select * from sysarticles where artid = @artid AND (type & 1) = 1 )
    begin
        raiserror (14155, 16, 1 )
        return 1
    end

    -------- create temp table for command fragments

    create table #proctext ( c1 int identity NOT NULL, procedure_text nvarchar(4000) collate database_default null)

    -- get sysarticles information

    select @pubid = pubid, @dest_owner = dest_owner, @dest_tabname = dest_table, 
           @src_objid = objid, @del_cmd = del_cmd, @columns = columns
    from sysarticles
    where artid = @artid

    if @dest_owner is not null
    begin
    	select @dest_owner = QUOTENAME( @dest_owner ) + N'.'
    end
    else
    begin
    	select @dest_owner = N''
    end

    -- Check if this is a queued publication
    select @queued_check = ISNULL(allow_queued_tran, 0) 
    from syspublications
    where pubid = @pubid

    -------- get dest proc name

    if( 1 != charindex( N'XCALL', upper(@del_cmd collate SQL_Latin1_General_CP1_CS_AS) ) ) or @del_cmd is null
    begin
        raiserror (14156, 16, 1 )
        return 1
    end

    select @dest_proc = substring( @del_cmd, 7, len( @del_cmd ) - 5 )
    select @cmd = N'if exists (select * from sysobjects where type = ''P'' and name = ''' + replace(@dest_proc, N'''', N'''''') + N''')  drop proc ' + QUOTENAME(@dest_proc)
    insert into #proctext(procedure_text) values( @cmd )
    insert into #proctext(procedure_text) values( N'go' )
    select @cmd = N'create procedure ' + QUOTENAME(@dest_proc)

    -------- construct parameter list


    select @art_col = 1
    select @spacer = N' '

    exec dbo.sp_getarticlepkcolbitmap @src_objid, @pkcolumns output

    DECLARE hCColid CURSOR LOCAL FAST_FORWARD FOR 
    select colid from syscolumns where id = @src_objid order by colid asc

    OPEN hCColid

    FETCH hCColid INTO @this_col

    WHILE (@@fetch_status <> -1)
    begin
       exec @isset = dbo.sp_isarticlecolbitset @this_col, @columns
       if @isset != 0 and EXISTS (select name from syscolumns where id=@src_objid and @this_col=colid and iscomputed<>1)
       begin
            if len( @cmd ) > 3000
            begin
            insert into #proctext(procedure_text) values( @cmd )
                select @cmd = N''
            end

            exec dbo.sp_gettypestring @src_objid, @this_col, @typestring OUTPUT
            select @cmd = @cmd + @spacer + N'@c' + convert( nvarchar, @art_col ) + N' ' + @typestring 

    		--
    		-- Queued processing:if this is the row version column : need to add to where clause
    		--
    		if ((@queued_check = 1) and (col_name( @src_objid, @this_col) = N'msrepl_tran_version'))
    			select @qwhere_string = N' and msrepl_tran_version = @c' + convert( nvarchar, @art_col )

            select @art_col = @art_col + 1
            select @spacer = N','
       end
       FETCH hCColid INTO @this_col
    end

    CLOSE hCColid
    DEALLOCATE hCColid

    -- save off 

    insert into #proctext(procedure_text) values( @cmd )
    insert into #proctext(procedure_text) values( N'as' )

    ------- construct proc body

    insert into #proctext(procedure_text) values( N'delete ' + @dest_owner + QUOTENAME(@dest_tabname) ) 

    exec dbo.sp_scriptpkwhereclause @src_objid, @pkcolumns, N'@c', @columns
    if (@queued_check = 1)
    	insert into #proctext(procedure_text) values( @qwhere_string )
    else
    	exec dbo.sp_MSscript_missing_row_check

    -- flush to client

    select procedure_text from #proctext order by c1 asc
end
go
EXEC dbo.sp_MS_marksystemobject sp_scriptxdelproc
GO

--
-- Name: sp_scriptupdproc
--
-- Description: This procedure is used by Snapshot agent to script the custom command procedure 
-- for UPDATE in CALL format. Invoked on publisher.
--
-- Parameter: Refer to the comments in the create procedure statement
--
-- Returns: 1 or 0   0 = success
--
-- Security: Public procedure - does publisher security check. 
--
raiserror('Creating procedure sp_scriptupdproc', 0,1)
go
create procedure sp_scriptupdproc 
(
    @artid int
)
as
begin
    declare @retcode int
    declare @cmd          nvarchar(4000)
    declare @dest_owner   nvarchar(255)
    declare @dest_tabname sysname
    declare @src_objid    int
    declare @artcolumns   binary(32)
    declare @pkcolumns    binary(32)
    declare @upd_cmd      nvarchar(255)
    declare @dest_proc    sysname
    declare @this_col     int
    declare @art_col      int
    declare @pkart_col    int
    declare @isset        int
    declare @pkcomputed   int
    declare @typestring   nvarchar(255)
    declare @spacer       nvarchar(10)
    declare @pubid        int, @allow_queued_tran bit, @need_end bit

    --
    -- security check
    --
    exec @retcode = dbo.sp_MSreplcheck_publish
    if @@error <> 0 or @retcode <> 0
    begin
        return (1)
    end
    select @need_end = 0

    if not exists( select * from sysarticles where artid = @artid AND (type & 1) = 1 )
    begin
        raiserror (14155, 16, 1 )
        return 1
    end

    -------- create temp table for command fragments

    create table #proctext ( c1 int identity NOT NULL, procedure_text nvarchar(4000) collate database_default null)

    -------- get sysarticles information

    select @pubid = pubid, @dest_owner = dest_owner, @dest_tabname = dest_table, 
           @src_objid = objid, @artcolumns = columns, @upd_cmd = upd_cmd
    from sysarticles
    where artid = @artid

    if @dest_owner is not null
    begin
    	select @dest_owner = QUOTENAME( @dest_owner ) + N'.'
    end
    else
    begin
    	select @dest_owner = N''
    end

    -------- get dest proc name

    if( 1 != charindex( N'CALL', upper(@upd_cmd collate SQL_Latin1_General_CP1_CS_AS) ) ) or @upd_cmd is null
    begin
        raiserror (14156, 16, 1 )
        return 1
    end

    select @allow_queued_tran = allow_queued_tran from syspublications where pubid = @pubid 

    declare @keep_identity bit
    if @allow_queued_tran = 1 and OBJECTPROPERTY(@src_objid, 'tablehasidentity') = 1
        select @keep_identity = 1
    else
        select @keep_identity = 0

    select @dest_proc = substring( @upd_cmd, 6, len( @upd_cmd ) - 4 )
    select @cmd = N'if exists (select * from sysobjects where type = ''P'' and name = ''' + replace(@dest_proc, N'''', N'''''') + N''')  drop proc ' + QUOTENAME(@dest_proc)
    insert into #proctext(procedure_text) values( @cmd )
    insert into #proctext(procedure_text) values( N'go' )
    insert into #proctext( procedure_text ) values (  N'create procedure ' + QUOTENAME(@dest_proc) + N' ')

    -------- construct parameter list

    exec dbo.sp_getarticlepkcolbitmap @src_objid, @pkcolumns output

    exec dbo.sp_scriptupdateparams @src_objid, @artcolumns, @pkcolumns

    insert into #proctext(procedure_text) values ( N'as' )

    -------- now create the update statement

    -- construct test to see if pk has changed 
    -- only do this if the article has columns not included in the pk

    exec @pkcomputed = sp_MSareallcolumnscomputed @src_objid, @pkcolumns

    declare @pk_is_identity bit
    select @pk_is_identity = 0

    if @artcolumns != @pkcolumns and @pkcomputed = 0
    begin
        select @cmd = N'if'

        select @art_col = 1
        select @pkart_col = 1
        select @spacer = ' '

        DECLARE hCColid CURSOR LOCAL FAST_FORWARD FOR 
        select colid from syscolumns where id = @src_objid order by colid asc

        OPEN hCColid

        FETCH hCColid INTO @this_col

        select @pk_is_identity = 1
        WHILE (@@fetch_status <> -1)
        begin
            exec @isset = dbo.sp_isarticlecolbitset @this_col, @artcolumns
            if @isset != 0 and EXISTS (select name from syscolumns where id=@src_objid and @this_col=colid and iscomputed<>1)
            begin
                exec @isset = dbo.sp_isarticlecolbitset @this_col, @pkcolumns
                if @isset != 0
                begin
    				if not (@keep_identity = 1 and 
    					columnproperty(@src_objid, col_name( @src_objid, @this_col), 'IsIdentity') = 1)
    				begin
    					select @pk_is_identity = 0
    					select @cmd = @cmd + @spacer + N'@c'+convert( nvarchar, @art_col ) + N' = @pkc' + convert( nvarchar, @pkart_col ) 
    					select @spacer = N' and '
    					select @pkart_col = @pkart_col + 1
    					if len( @cmd ) > 3000
    					begin
    					insert into #proctext(procedure_text) values( @cmd )
    						select @cmd = N''
    					end
    				end
                end
                select @art_col = @art_col + 1
            end
            FETCH hCColid INTO @this_col
        end

        CLOSE hCColid
        DEALLOCATE hCColid

    	if @pk_is_identity = 0
    	begin
    		insert into #proctext(procedure_text) values( @cmd )

    		insert into #proctext(procedure_text) values( N'begin' )

    		-- construct update if pk hasn't changed

    		select @cmd = N'update ' + @dest_owner + QUOTENAME(@dest_tabname) + N' set'

    		-- create SET clause

    		select @art_col = 1
    		select @spacer = N' '

    		DECLARE hCColid CURSOR LOCAL FAST_FORWARD FOR 
    		select colid from syscolumns where id = @src_objid order by colid asc

    		OPEN hCColid

    		FETCH hCColid INTO @this_col
    		WHILE (@@fetch_status <> -1)
    		begin
    			exec @isset = dbo.sp_isarticlecolbitset @this_col, @artcolumns
    			if @isset != 0  and EXISTS (select name from syscolumns where id=@src_objid and @this_col=colid and iscomputed<>1)
    			begin
    				exec @isset = dbo.sp_isarticlecolbitset @this_col, @pkcolumns
    				if @isset = 0
    				begin
    					if not (@keep_identity = 1 and 
    						columnproperty(@src_objid, col_name( @src_objid, @this_col), 'IsIdentity') = 1)
    					begin
    						select @cmd = @cmd + @spacer + QUOTENAME(col_name( @src_objid, @this_col)) + N' = @c' + convert( nvarchar, @art_col ) 
    						select @spacer = N','

    						if len( @cmd ) > 3000
    						begin
    							insert into #proctext(procedure_text) values( @cmd )
    							select @cmd = N''
    						end
    					end
    				end
    				select @art_col = @art_col + 1
    			end
    			FETCH hCColid INTO @this_col
    		end
    		CLOSE hCColid
    		DEALLOCATE hCColid

    		insert into #proctext(procedure_text) values( @cmd )

    		exec dbo.sp_scriptpkwhereclause @src_objid, @pkcolumns

    		if @allow_queued_tran <> 1
    			exec dbo.sp_MSscript_missing_row_check

    		insert into #proctext(procedure_text) values( N'end' )
    		insert into #proctext(procedure_text) values( N'else' )
    		insert into #proctext(procedure_text) values( N'begin' )

    		select @need_end = 1

    	end
    end -- end if artcols != pkcols


    -- construct update if pk has changed

    select @cmd = N'update ' + @dest_owner + QUOTENAME(@dest_tabname) + N' set'

    -- create SET clause

    select @art_col = 1
    select @spacer = N' '

    DECLARE hCColid CURSOR LOCAL FAST_FORWARD FOR 
    select colid from syscolumns where id = @src_objid order by colid asc

    OPEN hCColid

    FETCH hCColid INTO @this_col
    WHILE (@@fetch_status <> -1)
    begin
        exec @isset = dbo.sp_isarticlecolbitset @this_col, @artcolumns
        if @isset != 0 and EXISTS (select name from syscolumns where id=@src_objid and @this_col=colid and iscomputed<>1)
        begin
    		if not (@keep_identity = 1 and 
    			columnproperty(@src_objid, col_name( @src_objid, @this_col), 'IsIdentity') = 1)
    		begin
    			select @cmd = @cmd + @spacer + QUOTENAME(col_name( @src_objid, @this_col)) + N' = @c' + convert( nvarchar, @art_col ) 
    			select @spacer = N','

    			if len( @cmd ) > 3000
    			begin
    			insert into #proctext(procedure_text) values( @cmd )
    				select @cmd = N''
    			end
    		end
    		select @art_col = @art_col + 1
        end
    	FETCH hCColid INTO @this_col
    end

    CLOSE hCColid
    DEALLOCATE hCColid

    insert into #proctext(procedure_text) values( @cmd )

    exec dbo.sp_scriptpkwhereclause @src_objid, @pkcolumns

    if @allow_queued_tran <> 1
    	exec dbo.sp_MSscript_missing_row_check

    if @need_end = 1
    	insert into #proctext(procedure_text) values( N'end' )
    -- flush to client

    select procedure_text from #proctext order by c1 asc
end
go
EXEC dbo.sp_MS_marksystemobject sp_scriptupdproc
GO

--
-- Name: sp_scriptmappedupdproc
--
-- Description: This procedure is used by Snapshot agent to script the custom command procedure 
-- for UPDATE in MCALL format. Invoked on publisher.
--
-- Parameter: Refer to the comments in the create procedure statement
--
-- Returns: 1 or 0   0 = success
--
-- Security: Public procedure - does publisher security check. 
--
raiserror('Creating procedure sp_scriptmappedupdproc', 0,1)
go
create procedure sp_scriptmappedupdproc 
(
    @artid int
)
as
begin
    declare @retcode int
    declare @cmd          nvarchar(4000)
    declare @dest_owner   nvarchar(255)
    declare @dest_tabname sysname
    declare @src_objid    int
    declare @artcolumns   binary(32)
    declare @pkcolumns    binary(32)
    declare @upd_cmd      nvarchar(255)
    declare @dest_proc    sysname
    declare @art_cols     int
    declare @this_col     int
    declare @art_col      int
    declare @pkart_col    int
    declare @isset        int
    declare @bytestr      nvarchar(10)
    declare @bitstr       nvarchar(10)
    declare @typestring   nvarchar(255)
    declare @spacer       nvarchar(10)
    declare @update_created  bit
    declare @pkcomputed   int
    declare @pubid        int, @allow_queued_tran bit

    --
    -- security check
    --
    exec @retcode = dbo.sp_MSreplcheck_publish
    if @@error <> 0 or @retcode <> 0
    begin
        return (1)
    end
    select @update_created	 = 0

    if not exists( select * from sysarticles where artid = @artid AND (type & 1) = 1 )
    begin
        raiserror (14155, 16, 1 )
        return 1
    end

    -------- create temp table for command fragments

    create table #proctext ( c1 int identity NOT NULL, procedure_text nvarchar(4000) collate database_default )

    -------- get sysarticles information

    select @dest_owner = dest_owner, @dest_tabname = dest_table, 
           @src_objid = objid, @artcolumns = columns, @upd_cmd = upd_cmd,
    	   @pubid = pubid
    from sysarticles
    where artid = @artid

    if @dest_owner is not null
    begin
    	select @dest_owner = QUOTENAME( @dest_owner ) + N'.'
    end
    else
    begin
    	select @dest_owner = N''
    end

    -------- get dest proc name

    if( 1 != charindex( N'MCALL', upper(@upd_cmd collate SQL_Latin1_General_CP1_CS_AS) ) ) or @upd_cmd is null
    begin
        raiserror (14156, 16, 1 )
        return 1
    end

    select @allow_queued_tran = allow_queued_tran from syspublications where pubid = @pubid 

    declare @keep_identity bit
    if @allow_queued_tran = 1 and OBJECTPROPERTY(@src_objid, 'tablehasidentity') = 1
        select @keep_identity = 1
    else
        select @keep_identity = 0

    select @dest_proc = substring( @upd_cmd, 7, len( @upd_cmd ) - 5 )
    select @cmd = N'if exists (select * from sysobjects where type = ''P''  and name = ''' + replace(@dest_proc, N'''', N'''''') + N''')  drop proc ' + QUOTENAME(@dest_proc)
    insert into #proctext(procedure_text) values( @cmd )
    insert into #proctext(procedure_text) values( N'go' )
    insert into #proctext( procedure_text ) values ( N'create procedure ' + QUOTENAME(@dest_proc) + N' ' )
      

    -------- construct parameter list

    exec dbo.sp_getarticlepkcolbitmap @src_objid, @pkcolumns output

    exec dbo.sp_scriptupdateparams @src_objid, @artcolumns, @pkcolumns

    ----- add changed data bitmap

    select @art_col = 1


    DECLARE hCColid CURSOR LOCAL FAST_FORWARD FOR 
    select colid from syscolumns where id = @src_objid order by colid asc

    OPEN hCColid

    FETCH hCColid INTO @this_col

    WHILE (@@fetch_status <> -1)
    begin
       exec @isset = dbo.sp_isarticlecolbitset @this_col, @artcolumns
       if @isset != 0 and EXISTS (select name from syscolumns where colid=@this_col and iscomputed<>1 and id = @src_objid)
       begin
            select @art_col = @art_col + 1
       end
       FETCH hCColid INTO @this_col
    end
    CLOSE hCColid
    DEALLOCATE hCColid

    -- Note that bitmap size is based on number of article columns
    -- (computed by loop above) not source table columns

    select @cmd = N',@bitmap binary(' + convert(nvarchar,1+(@art_col-1) / 8) + N')'

    insert into #proctext(procedure_text) values( @cmd )
    insert into #proctext(procedure_text) values( N'as' )


    -- construct IF statement to examine colbitmap and determine if a 
    -- primary key column has been updated.  

    -- do this only if the article contains columns not included in the pk
    -- and at least one of the columns in the PK is real ( i.e. not computed )

    -- note that if all the article columns are PK columns, we will
    -- construct the 'update all columns including PK columns' statement
    -- w/o a preceeding IF, and we will NOT construct the 'only update non-pk columns' 
    -- part of the procedure

    -- also note that this is pretty much worthless since 7.0 and above are
    -- guaranteed to NEVER generate an UPDATE if a PK columns is updated... oh well.
    declare @pk_is_identity bit
    select @pk_is_identity = 0

    exec @pkcomputed = sp_MSareallcolumnscomputed @src_objid, @pkcolumns

    if @artcolumns != @pkcolumns and @pkcomputed = 0
    begin
        select @art_col = 1
        select @spacer = N' '

        select @cmd = N'if'

    	DECLARE hCColid CURSOR LOCAL FAST_FORWARD FOR 
    	select colid from syscolumns where id = @src_objid order by colid asc

    	OPEN hCColid

    	FETCH hCColid INTO @this_col

    	select @pk_is_identity = 1

        WHILE (@@fetch_status <> -1)
        begin
            exec @isset = dbo.sp_isarticlecolbitset @this_col, @artcolumns
            if @isset != 0 and EXISTS (select name from syscolumns where id=@src_objid and @this_col=colid and iscomputed<>1)
            begin 
                exec @isset = dbo.sp_isarticlecolbitset @this_col, @pkcolumns
                if @isset != 0
                begin
    				if not (@keep_identity = 1 and 
    					columnproperty(@src_objid, col_name( @src_objid, @this_col), 'IsIdentity') = 1)
    				begin
    					select @pk_is_identity = 0
    					select @bytestr = convert( nvarchar, 1 + (@art_col-1) / 8 )
    					select @bitstr =  convert( nvarchar, power(2, (@art_col-1) % 8 ) )

    					select @cmd = @cmd + @spacer + N'substring(@bitmap,' + @bytestr + N',1) & ' + @bitstr +  
    							 N' = ' + @bitstr 
                    
    					select @spacer = N' or '

    					if len( @cmd ) > 3000
    					begin
    						insert into #proctext(procedure_text) values( @cmd )
    						select @cmd = N''
    					end
    				end
                end
                select @art_col = @art_col + 1
            end
    		FETCH hCColid INTO @this_col
        end
        CLOSE hCColid
        DEALLOCATE hCColid

        if @pk_is_identity = 0
            insert into #proctext(procedure_text) values( @cmd )

    end  -- if artcolumns != pkcolumns

    -- construct update statement including PK columns

    insert into #proctext(procedure_text) values( N'begin' )

    insert into #proctext(procedure_text) values( N'update ' + @dest_owner + QUOTENAME(@dest_tabname) + N' set' )

    -- create SET clause consisting of CASE statements

    select @art_col = 1
    select @spacer = N''

    DECLARE hCColid CURSOR LOCAL FAST_FORWARD FOR 
    select colid from syscolumns where id = @src_objid order by colid asc

    OPEN hCColid

    FETCH hCColid INTO @this_col

    WHILE (@@fetch_status <> -1)
    begin
        exec @isset = dbo.sp_isarticlecolbitset @this_col, @artcolumns
        if @isset != 0  and EXISTS (select name from syscolumns where colid=@this_col and iscomputed<>1 and id = @src_objid)
        begin
    		if not (@keep_identity = 1 and 
    			columnproperty(@src_objid, col_name( @src_objid, @this_col), 'IsIdentity') = 1)
    		begin
    			select @bytestr = convert( nvarchar, 1 + (@art_col-1) / 8 )
    			select @bitstr =  convert( nvarchar, power(2, (@art_col-1) % 8 ) )

    			insert into #proctext(procedure_text) values (
    				 @spacer + QUOTENAME(col_name( @src_objid, @this_col)) + N' = case substring(@bitmap,' + @bytestr + N',1) & ' + @bitstr +  
    				 N' when ' + @bitstr + N' then ' + N'@c'+ convert( nvarchar, @art_col ) + 
    				 N' else ' + QUOTENAME(col_name( @src_objid, @this_col)) + N' end' )

    			select @spacer = ',' 
    		end

            select @art_col = @art_col + 1
        end
    	FETCH hCColid INTO @this_col
    end
    CLOSE hCColid
    DEALLOCATE hCColid

    -- create where clause

    exec dbo.sp_scriptpkwhereclause @src_objid, @pkcolumns

    if @allow_queued_tran <> 1
    	exec dbo.sp_MSscript_missing_row_check

    -- construct UPDATE that does not set PK cols
    -- only do this if the article contains columns that are not included
    -- in the pk

    if @artcolumns != @pkcolumns  and @pkcomputed = 0 and @pk_is_identity = 0
    begin

        -- create SET clause consisting of CASE statements

        select @art_col = 1
        select @spacer = N''

        DECLARE hCColid CURSOR LOCAL FAST_FORWARD FOR 
        select colid from syscolumns where id = @src_objid order by colid asc

        OPEN hCColid

        FETCH hCColid INTO @this_col

        WHILE (@@fetch_status <> -1)
        begin
            exec @isset = dbo.sp_isarticlecolbitset @this_col, @artcolumns
            if @isset != 0  and EXISTS (select name from syscolumns where colid=@this_col and iscomputed<>1 and id = @src_objid)
            begin
                exec @isset = dbo.sp_isarticlecolbitset @this_col, @pkcolumns 
                if @isset = 0 
                begin
    				if not (@keep_identity = 1 and 
    					columnproperty(@src_objid, col_name( @src_objid, @this_col), 'IsIdentity') = 1)
    				begin
                		if (@update_created = 0)
                		begin
                			insert into #proctext(procedure_text) values( N'end' )
                			insert into #proctext(procedure_text) values( N'else' )
                			insert into #proctext(procedure_text) values( N'begin' )
    			    		insert into #proctext(procedure_text) values( N'update ' + @dest_owner + QUOTENAME(@dest_tabname) + N' set' )
    			    		select @update_created = 1
    					end
    					select @bytestr = convert( nvarchar, 1 + (@art_col-1) / 8 )
    					select @bitstr =  convert( nvarchar, power(2, (@art_col-1) % 8 ) )

    					insert into #proctext(procedure_text) values (
    						 @spacer + QUOTENAME(col_name( @src_objid, @this_col)) + N' = case substring(@bitmap,' + @bytestr + N',1) & ' + @bitstr +  
    						 N' when ' + @bitstr + N' then ' + N'@c'+ convert( nvarchar, @art_col ) + 
    						 N' else ' + QUOTENAME(col_name( @src_objid, @this_col)) + N' end' )

    					select @spacer = ',' 
    				end
                end
                select @art_col = @art_col + 1
            end
            FETCH hCColid INTO @this_col
        end
        CLOSE hCColid
        DEALLOCATE hCColid

        if @update_created = 1
    	begin
    		exec dbo.sp_scriptpkwhereclause @src_objid, @pkcolumns
    		if @allow_queued_tran <> 1
    			exec dbo.sp_MSscript_missing_row_check
    	end
    end

    insert into #proctext(procedure_text) values( N'end' )
    select procedure_text from #proctext order by c1 asc
end
go
EXEC dbo.sp_MS_marksystemobject sp_scriptmappedupdproc
GO

--
-- Name: sp_scriptdynamicupdproc
--
-- Description: This procedure is used by User to script the custom command procedure 
-- for UPDATE in MCALL format using EXEC() statements (avoids using CASE statements).
-- Invoked on publisher.
--
-- Parameter: Refer to the comments in the create procedure statement
--
-- Returns: 1 or 0   0 = success
--
-- Security: Public procedure - does publisher security check. 
--
raiserror('Creating procedure sp_scriptdynamicupdproc', 0,1)
go
create procedure sp_scriptdynamicupdproc 
(
    @artid int
)
as
    begin
    declare @retcode int
    declare @cmd          nvarchar(4000)
    declare @dest_owner   nvarchar(255)
    declare @dest_tabname sysname
    declare @src_objid    int
    declare @artcolumns   binary(32)
    declare @pkcolumns    binary(32)
    declare @upd_cmd      nvarchar(255)
    declare @dest_proc    sysname
    declare @art_cols     int
    declare @this_col     int
    declare @art_col      int
    declare @pk_col       int
    declare @pkart_col    int
    declare @isset        int
    declare @ispk         int
    declare @isidentity   bit
    declare @iscomputed   bit
    declare @bytestr      nvarchar(10)
    declare @bitstr       nvarchar(10)
    declare @typestring   nvarchar(255)
    declare @spacer_param nvarchar(10)
    declare @update_created  bit
    declare @pkcomputed   int
    declare @pubid        int, @allow_queued_tran bit

    set nocount on 

    --
    -- security check
    --
    exec @retcode = dbo.sp_MSreplcheck_publish
    if @@error <> 0 or @retcode <> 0
    begin
        return (1)
    end
    select @update_created	 = 0

    if not exists( select * from sysarticles where artid = @artid AND (type & 1) = 1 )
    begin
        raiserror (14155, 16, 1 )
        return 1
    end

    -------- create temp table for command fragments

    create table #proctext ( c1 int identity NOT NULL, procedure_text nvarchar(4000) collate database_default )
    create table #proctext_params ( c1 int identity NOT NULL, procedure_text nvarchar(4000) collate database_default )
    create table #proctext_paramdef ( c1 int identity NOT NULL, procedure_text nvarchar(4000) collate database_default )
    create table #proctext_pkparams ( c1 int identity NOT NULL, procedure_text nvarchar(4000) collate database_default )



    -------- get sysarticles information

    select @dest_owner = dest_owner, @dest_tabname = dest_table, 
           @src_objid = objid, @artcolumns = columns, @upd_cmd = upd_cmd,
    	   @pubid = pubid
    from sysarticles
    where artid = @artid

    if @dest_owner is not null
    begin
    	select @dest_owner = QUOTENAME( @dest_owner ) + N'.'
    end
    else
    begin
    	select @dest_owner = N''
    end

    -------- get dest proc name

    if( 1 != charindex( N'MCALL', upper(@upd_cmd) ) ) or @upd_cmd is null
    begin
        raiserror (14156, 16, 1 )
        return 1
    end

    select @allow_queued_tran = allow_queued_tran from syspublications where pubid = @pubid 

    declare @keep_identity bit
    if @allow_queued_tran = 1 and OBJECTPROPERTY(@src_objid, 'tablehasidentity') = 1
        select @keep_identity = 1
    else
        select @keep_identity = 0

    select @dest_proc = substring( @upd_cmd, 7, len( @upd_cmd ) - 5 )
    select @cmd = N'if exists (select * from sysobjects where type = ''P''  and name = ''' + replace(@dest_proc, N'''', N'''''') + N''')  drop proc ' + QUOTENAME(@dest_proc)
    insert into #proctext(procedure_text) values( @cmd )
    insert into #proctext(procedure_text) values( N'go' )
    insert into #proctext( procedure_text ) values ( N'create procedure ' + QUOTENAME(@dest_proc) + N' ' )
      

    -------- construct parameter list

    exec dbo.sp_getarticlepkcolbitmap @src_objid, @pkcolumns output

    exec dbo.sp_scriptupdateparams @src_objid, @artcolumns, @pkcolumns

    ----- add changed data bitmap

    select @art_col = 1
    select @pk_col = 1

    DECLARE hCColid CURSOR LOCAL FAST_FORWARD FOR 
    select colid from syscolumns where id = @src_objid order by colid asc

    OPEN hCColid

    FETCH hCColid INTO @this_col

    WHILE (@@fetch_status <> -1)
    begin
       exec @isset = dbo.sp_isarticlecolbitset @this_col, @artcolumns
       if @isset != 0 and EXISTS (select name from syscolumns where colid=@this_col and iscomputed<>1 and id = @src_objid)
       begin
            select @art_col = @art_col + 1
       end
       FETCH hCColid INTO @this_col
    end
    CLOSE hCColid
    DEALLOCATE hCColid

    -- Note that bitmap size is based on number of article columns
    -- (computed by loop above) not source table columns

    select @cmd = N',@bitmap binary(' + convert(nvarchar,1+(@art_col-1) / 8) + N')'

    insert into #proctext(procedure_text) values( @cmd )
    insert into #proctext(procedure_text) values( N'as' )



    -- Find out if pk is identity
    declare @pk_is_identity bit
    select @pk_is_identity = 0

    exec @pkcomputed = sp_MSareallcolumnscomputed @src_objid, @pkcolumns

    if @artcolumns != @pkcolumns and @pkcomputed = 0
    begin
        select @art_col = 1

    	DECLARE hCColid CURSOR LOCAL FAST_FORWARD FOR 
    	select colid from syscolumns where id = @src_objid order by colid asc

    	OPEN hCColid

    	FETCH hCColid INTO @this_col

    	select @pk_is_identity = 1

    	WHILE (@@fetch_status <> -1)
        begin
            exec @isset = dbo.sp_isarticlecolbitset @this_col, @artcolumns
            if @isset != 0 and EXISTS (select name from syscolumns where id=@src_objid and @this_col=colid and iscomputed<>1)
            begin 
                exec @isset = dbo.sp_isarticlecolbitset @this_col, @pkcolumns
                if @isset != 0
                begin
    				if not (@keep_identity = 1 and 
    					columnproperty(@src_objid, col_name( @src_objid, @this_col), 'IsIdentity') = 1)
    				begin
    					select @pk_is_identity = 0
    				end
                end
                select @art_col = @art_col + 1
            end
    		FETCH hCColid INTO @this_col
        end
    	CLOSE hCColid
    	DEALLOCATE hCColid
    end 

    -- construct UPDATE that does not set PK cols
    -- only do this if the article contains columns that are not included
    -- in the pk
    -- Note: we assume pk columns never change. pk changes will be replicated
    -- as delete insert.

    if @artcolumns != @pkcolumns  and @pkcomputed = 0 and @pk_is_identity = 0
    begin

        -- create SET clause consisting of CASE statements

        select @art_col = 1
        select @spacer_param = N''

    	DECLARE hCColid CURSOR LOCAL FAST_FORWARD FOR 
    	select colid from syscolumns where id = @src_objid order by colid asc

    	OPEN hCColid

    	FETCH hCColid INTO @this_col

    	WHILE (@@fetch_status <> -1)
        begin
            exec @isset = dbo.sp_isarticlecolbitset @this_col, @artcolumns
            if @isset != 0  
    		begin
                exec @ispk = dbo.sp_isarticlecolbitset @this_col, @pkcolumns
    			
    			if EXISTS (select name from syscolumns where colid=@this_col and iscomputed<>1 and id = @src_objid)
    				select @iscomputed = 0
    			else
    				select @iscomputed = 1
    			
    			if (@keep_identity = 1 and 
    					columnproperty(@src_objid, col_name( @src_objid, @this_col), 'IsIdentity') = 1)  
    				select @isidentity = 1
    			else
    				select @isidentity = 0
    				
    			-- If not pk, not computed and not identity	
    			if @ispk = 0 and @iscomputed = 0 and @isidentity = 0
                begin
                	if (@update_created = 0)
                	begin
    			    	insert into #proctext(procedure_text) values( 
    						N'declare @stmt nvarchar(4000), @spacer nvarchar(1)')

    			    	insert into #proctext(procedure_text) values( 
    						N'select @spacer =N''''')

    			    	insert into #proctext(procedure_text) values( 
    						N'select @stmt = N''update ' + 
    						replace(@dest_owner + QUOTENAME(@dest_tabname), N'''', N'''''' ) +
    						N' set ''')

    			    	select @update_created = 1
    				end

    				select @bytestr = convert( nvarchar, 1 + (@art_col-1) / 8 )
    				select @bitstr =  convert( nvarchar, power(2, (@art_col-1) % 8 ) )

    				insert into #proctext(procedure_text) values (
    					 N'if substring(@bitmap,' + @bytestr + N',1) & ' + @bitstr +  
    					 N' = ' + @bitstr)

    				insert into #proctext(procedure_text) values (N'begin')

    				-- Append statement
    				insert into #proctext(procedure_text) values (
    					 N'select @stmt = @stmt + @spacer + ' + 
    					 N'N''' + replace(QUOTENAME(col_name( @src_objid, @this_col)), N'''', N'''''') + N''' + ' +
    					 N'N''=@'+ convert( nvarchar, @art_col ) + N'''')

    				-- Set @spacer is the proc
    				insert into #proctext(procedure_text) values (
    					N'select @spacer = N'',''')

    				insert into #proctext(procedure_text) values (N'end')
                end
    			-- If pk or (not computed and not identity) add the param
    			if @ispk <> 0 or (@iscomputed = 0 and @isidentity = 0)
    			begin
    				-- Add to param list
    			    if (@ispk <> 0)
    				  begin
    				    -- Use primary key value
    				    insert into #proctext_params(procedure_text) values( 
    						@spacer_param + N'@pkc' + convert( nvarchar, @pk_col ))

    				    -- Increment primary key counter
    				    select @pk_col = @pk_col + 1;

    				  end
    				else
    				    -- Use column value
    					insert into #proctext_params(procedure_text) values( 
    						@spacer_param + N'@c' + convert( nvarchar, @art_col ))

    				-- Get type str
    				exec dbo.sp_gettypestring @src_objid, @this_col, @typestring OUTPUT

    				-- Append typedef
    				insert into #proctext_paramdef(procedure_text) values (
    					 @spacer_param + N'@' + convert( nvarchar, @art_col ) + 
    					 N' ' + @typestring )

    				select @spacer_param = ',' 
    			end

                select @art_col = @art_col + 1
            end
           	FETCH hCColid INTO @this_col
        end
    	CLOSE hCColid
    	DEALLOCATE hCColid

        if @update_created = 1
    	begin

    		-- Append statement of the start of where clause
    		insert into #proctext(procedure_text) values (
    			 N'	select @stmt = @stmt + N'' ')

    		-- Escape ' in the where clause
    		declare @low_mark int, @high_mark int
    		select @low_mark = max(c1) from #proctext
    		-- Pass in @artcolumns so that the where clause will use the ordinal in the
    		-- article bit map rather then one in pk bitmap. This is consistent with
    		-- the type def string.
    		-- UNDONE: change comments in sp_scriptpkwhereclause
    		-- Use prefix '@' to be consistent with type def string
    		exec dbo.sp_scriptpkwhereclause @src_objid, @pkcolumns, '@', @artcolumns
    		select @high_mark = max(c1) from #proctext
    		update #proctext set procedure_text = replace ( procedure_text, N'''', N'''''') 
    			where c1 > @low_mark and c1 <= @high_mark

    		-- Close the where clause
    		insert into #proctext(procedure_text) values (
    			 N'''')

    		-- Add call to sql_executesql and the param list
    		insert into #proctext(procedure_text) values( 
    			N'exec sp_executesql @stmt, N'' ')

    		-- Add param def
    		insert into #proctext(procedure_text) 
    			select procedure_text from #proctext_paramdef order by c1 asc

    		-- Close the param def
    		insert into #proctext(procedure_text) values (
    			 N''',')

    		-- Add param list
    		insert into #proctext(procedure_text) 
    			select procedure_text from #proctext_params order by c1 asc

    		if @allow_queued_tran <> 1
    			exec dbo.sp_MSscript_missing_row_check
    	end

    end

    select procedure_text from #proctext order by c1 asc
end
go
EXEC dbo.sp_MS_marksystemobject sp_scriptdynamicupdproc
GO

--
-- Name: sp_scriptxupdproc
--
-- Description: This procedure is used by Snapshot agent to script the custom command procedure 
-- for UPDATE in XCALL format. Invoked on publisher.
--
-- Parameter: Refer to the comments in the create procedure statement
--
-- Returns: 1 or 0   0 = success
--
-- Security: Public procedure - does publisher security check. 
--
raiserror('Creating procedure sp_scriptxupdproc', 0,1)
go
create procedure sp_scriptxupdproc @artid int
as
BEGIN
    declare @cmd          nvarchar(4000),
                @dest_owner   nvarchar(255),
                @dest_tabname sysname,
                @src_objid    int,
                @artcolumns   binary(32),
                @pkcolumns    binary(32),
                @upd_cmd      nvarchar(255),
                @dest_proc    sysname,
                @this_col     int,
                @art_col      int,
                --@pkart_col    int,
                @isset        int,
                @rc int,
                @fhasnonpkuniquekeys int,
                @pkcomputed   int,
                @typestring   nvarchar(255),
                @spacer       nvarchar(10),
                @pubid		  int, 
                @param_count  int
                ,@queued_check bit, @exists_else bit
                ,@qwhere_string nvarchar(4000)

    set nocount on
    --
    -- security check
    --
    exec @rc = dbo.sp_MSreplcheck_publish
    if @@error <> 0 or @rc <> 0
    begin
        return (1)
    end

    if not exists( select * from sysarticles where artid = @artid AND (type & 1) = 1 )
    begin
        raiserror (14155, 16, 1 )
        return 1
    end

    select @exists_else = 0
             ,@fhasnonpkuniquekeys = 0

    -------- create temp table for command fragments

    create table #proctext ( c1 int identity NOT NULL, procedure_text nvarchar(4000) collate database_default null)

    -------- get sysarticles information

    select @pubid = pubid, @dest_owner = dest_owner, @dest_tabname = dest_table, 
           @src_objid = objid, @artcolumns = columns, @upd_cmd = upd_cmd
    from sysarticles
    where artid = @artid

    if @dest_owner is not null
    begin
    	select @dest_owner = QUOTENAME( @dest_owner ) + N'.'
    end
    else
    begin
    	select @dest_owner = N''
    end

    -- Check if this is a queued publication
    select @queued_check = ISNULL(allow_queued_tran, 0) 
    from syspublications
    where pubid = @pubid

    -------- get dest proc name

    if( 1 != charindex( N'XCALL', upper(@upd_cmd collate SQL_Latin1_General_CP1_CS_AS) ) ) or @upd_cmd is null
    begin
        raiserror (14156, 16, 1 )
        return 1
    end

    declare @keep_identity bit
    if exists (select * from syspublications where pubid = @pubid and
    	allow_queued_tran = 1) and OBJECTPROPERTY(@src_objid, 'tablehasidentity') = 1
        select @keep_identity = 1
    else
        select @keep_identity = 0

    select @dest_proc = substring( @upd_cmd, 7, len( @upd_cmd ) - 5 )
    select @cmd = N'if exists (select * from sysobjects where type = ''P''  and name = ''' + replace(@dest_proc, N'''', N'''''') + N''')  drop proc ' + QUOTENAME(@dest_proc)
    insert into #proctext(procedure_text) values( @cmd )
    insert into #proctext(procedure_text) values( N'go' )
    insert into #proctext( procedure_text ) values (  N'create procedure ' + QUOTENAME(@dest_proc) + N' ')

    -------- construct parameter list

    exec dbo.sp_getarticlepkcolbitmap @src_objid, @pkcolumns output

    -- Send null as @pkcolumns. We don't need pk parameters.
    exec dbo.sp_scriptupdateparams @src_objid, @artcolumns, NULL, @param_count output

    insert into #proctext(procedure_text) values ( N'as' )

    --
    -- If we are a part of queued publication 
    --
    if (@queued_check = 1)
    begin
        --
        -- Check if we have non PK unique keys
        --
        exec @fhasnonpkuniquekeys = dbo.sp_repltablehasnonpkuniquekey @tabid = @src_objid
        if (@fhasnonpkuniquekeys = 1)
        begin
            --
            -- There are non PK unique keys
            -- update only if updated values of non PK unique key(s) do not exist
            --
            select @cmd = N'
if not exists (select * from ' + @dest_owner + QUOTENAME(@dest_tabname) + N' '
            insert into #proctext(procedure_text) values( @cmd )
            exec @rc = sp_replscriptuniquekeywhereclause @tabid = @src_objid
                                                            ,@columns = @artcolumns
                                                            ,@prefix = '@c' 
                                                            ,@mode = 2
                                                            ,@paramcount = @param_count
            if (@@error != 0 or @rc != 0)
                return 1
            select @cmd = N')
begin'
            insert into #proctext(procedure_text) values( @cmd )
        end
    end

    -------- now create the update statement

    -- construct test to see if pk has changed 
    -- only do this if the article has columns not included in the pk

    exec @pkcomputed = sp_MSareallcolumnscomputed @src_objid, @pkcolumns

    declare @pk_is_identity bit
    select @pk_is_identity = 0

    if @artcolumns != @pkcolumns and @pkcomputed = 0
    begin
        select @cmd = N'if'

        select @art_col = 1
        --select @pkart_col = 1
        select @spacer = ' '

        DECLARE hCColid CURSOR LOCAL FAST_FORWARD FOR 
        select colid from syscolumns where id = @src_objid order by colid asc

        OPEN hCColid

        FETCH hCColid INTO @this_col

        select @pk_is_identity = 1
        WHILE (@@fetch_status <> -1)
        begin
            exec @isset = dbo.sp_isarticlecolbitset @this_col, @artcolumns
            if @isset != 0 and EXISTS (select name from syscolumns where id=@src_objid and @this_col=colid and iscomputed<>1)
            begin
                exec @isset = dbo.sp_isarticlecolbitset @this_col, @pkcolumns
                if @isset != 0
                begin
    				if not (@keep_identity = 1 and 
    					columnproperty(@src_objid, col_name( @src_objid, @this_col), 'IsIdentity') = 1)
    				begin
    					select @pk_is_identity = 0
    					select @cmd = @cmd + @spacer + N'@c'+convert( nvarchar, @art_col + @param_count/2) + 
    						N' = @c' + convert( nvarchar, @art_col ) 
    					select @spacer = N' and '
    					--select @pkart_col = @pkart_col + 1
    					if len( @cmd ) > 3000
    					begin
    					insert into #proctext(procedure_text) values( @cmd )
    						select @cmd = N''
    					end
    				end
                end
                select @art_col = @art_col + 1
            end
            FETCH hCColid INTO @this_col
        end

        CLOSE hCColid
        DEALLOCATE hCColid

    	if @pk_is_identity = 0
    	begin
    		insert into #proctext(procedure_text) values( @cmd )

    		insert into #proctext(procedure_text) values( N'begin' )

    		-- construct update if pk hasn't changed
    		-- We know that there would be a least one column for the update below, even if
    		-- the columns outside the pk are identity or timestamp. Since identity and timestamp
    		-- will be mapped off unless it is queued tran. In that case, we have 'msrepl_tran_version'
    		select @cmd = N'update ' + @dest_owner + QUOTENAME(@dest_tabname) + N' set'

    		-- create SET clause

    		select @art_col = 1
    		select @spacer = N' '

    		DECLARE hCColid CURSOR LOCAL FAST_FORWARD FOR 
    		select colid from syscolumns where id = @src_objid order by colid asc

    		OPEN hCColid

    		FETCH hCColid INTO @this_col
    		WHILE (@@fetch_status <> -1)
    		begin
    			exec @isset = dbo.sp_isarticlecolbitset @this_col, @artcolumns
    			if @isset != 0  and EXISTS (select name from syscolumns where id=@src_objid and @this_col=colid and iscomputed<>1)
    			begin
    				exec @isset = dbo.sp_isarticlecolbitset @this_col, @pkcolumns
    				if @isset = 0
    				begin
    					if not (@keep_identity = 1 and 
    						columnproperty(@src_objid, col_name( @src_objid, @this_col), 'IsIdentity') = 1)
    					begin
    						select @cmd = @cmd + @spacer + QUOTENAME(col_name( @src_objid, @this_col)) + 
    							N' = @c' + convert( nvarchar, @art_col + @param_count/2) 
    						select @spacer = N','

    						if len( @cmd ) > 3000
    						begin
    							insert into #proctext(procedure_text) values( @cmd )
    							select @cmd = N''
    						end

    						--
    						-- Queued processing:if this is the row version column : need to add to where clause
    						--
    						if ((@queued_check = 1) and (col_name( @src_objid, @this_col) = N'msrepl_tran_version'))
    							select @qwhere_string = N' and msrepl_tran_version = @c' + convert( nvarchar, @art_col )						
    					end
    				end
    				select @art_col = @art_col + 1
    			end
    			FETCH hCColid INTO @this_col
    		end
    		CLOSE hCColid
    		DEALLOCATE hCColid

    		insert into #proctext(procedure_text) values( @cmd )

    		exec dbo.sp_scriptpkwhereclause @src_objid, @pkcolumns, N'@c', @artcolumns
    		if (@queued_check = 1)
    			insert into #proctext(procedure_text) values( @qwhere_string )
    		else
    			exec dbo.sp_MSscript_missing_row_check

    		insert into #proctext(procedure_text) values( N'end' )
    		insert into #proctext(procedure_text) values( N'else' )
    		insert into #proctext(procedure_text) values( N'begin' )

    		select @exists_else = 1

    	end
    end -- end if artcols != pkcols

    --
    -- If we are a part of queued publication then 
    -- update only if updated value of PK does not exist
    --
    if (@queued_check = 1 and @pk_is_identity = 0)
    begin
        select @cmd = N'
if not exists (select * from ' + @dest_owner + QUOTENAME(@dest_tabname) + N' '
        insert into #proctext(procedure_text) values( @cmd )
        exec @rc = sp_replscriptuniquekeywhereclause @tabid = @src_objid
                                                            ,@columns = @artcolumns
                                                            ,@prefix = '@c' 
                                                            ,@mode = 3
                                                            ,@paramcount = @param_count
        if (@@error != 0 or @rc != 0)
            return 1
        select @cmd = N')
begin'
        insert into #proctext(procedure_text) values( @cmd )
    end

    -- construct update if pk has changed
    select @cmd = N'update ' + @dest_owner + QUOTENAME(@dest_tabname) + N' set'

    -- create SET clause

    select @art_col = 1
    select @spacer = N' '

    DECLARE hCColid CURSOR LOCAL FAST_FORWARD FOR 
    select colid from syscolumns where id = @src_objid order by colid asc

    OPEN hCColid

    FETCH hCColid INTO @this_col
    WHILE (@@fetch_status <> -1)
    begin
        exec @isset = dbo.sp_isarticlecolbitset @this_col, @artcolumns
        if @isset != 0 and EXISTS (select name from syscolumns where id=@src_objid and @this_col=colid and iscomputed<>1)
        begin
    		if not (@keep_identity = 1 and 
    			columnproperty(@src_objid, col_name( @src_objid, @this_col), 'IsIdentity') = 1)
    		begin
    			select @cmd = @cmd + @spacer + QUOTENAME(col_name( @src_objid, @this_col)) + 
    				N' = @c' + convert( nvarchar, @art_col + @param_count/2 ) 
    			select @spacer = N','

    			if len( @cmd ) > 3000
    			begin
    			insert into #proctext(procedure_text) values( @cmd )
    				select @cmd = N''
    			end

    			--
    			-- Queued processing:if this is the row version column : need to add to where clause
    			--
    			if ((@queued_check = 1) and (col_name( @src_objid, @this_col) = N'msrepl_tran_version'))
    				select @qwhere_string = N' and msrepl_tran_version = @c' + convert( nvarchar, @art_col )						
    		end
    		select @art_col = @art_col + 1
        end
    	FETCH hCColid INTO @this_col
    end

    CLOSE hCColid
    DEALLOCATE hCColid

    insert into #proctext(procedure_text) values( @cmd )

    exec dbo.sp_scriptpkwhereclause @src_objid, @pkcolumns, N'@c', @artcolumns
    if (@queued_check = 1)
    begin
        insert into #proctext(procedure_text) values( @qwhere_string ) 
        if (@pk_is_identity = 0)
        begin
            select @cmd = N'
end'
            insert into #proctext(procedure_text) values( @cmd )
        end
    end
    else
    	exec dbo.sp_MSscript_missing_row_check

    if @exists_else = 1
    	insert into #proctext(procedure_text) values( N'end' )

    --
    -- End the if exists block for Queued publications
    --
    if (@queued_check = 1) and (@fhasnonpkuniquekeys = 1)
    begin
        select @cmd = N'
end'
        insert into #proctext(procedure_text) values( @cmd )
    end

    -- flush to client

    select procedure_text from #proctext order by c1 asc
END
go
EXEC dbo.sp_MS_marksystemobject sp_scriptxupdproc
GO

--------------------------------------------------------------------------
--------------------------------------------------------------------------

print ''
print 'Creating procedure sp_MSscriptmvastablenci'
go

create procedure sp_MSscriptmvastablenci @artid int
as
declare @cmd          nvarchar(4000)
declare @dest_owner   nvarchar(255)
declare @dest_tabname sysname
declare @src_objid    int
declare @constraint_name  sysname
declare @spacer		  nvarchar(1)
declare @srcobj		  nvarchar(1000)
declare @colname	  sysname
declare @indkey		  int
declare @indid		  int
declare @status		  int
declare @unique	      nvarchar(10)
declare @cmd_sep	  nvarchar(10)


-------- security check, db_owner
declare @retcode int
exec @retcode = dbo.sp_MSreplcheck_publish
if @@ERROR <> 0 or @retcode <> 0
    return(1)

-------- create temp table for command fragments

create table #proctext ( c1 int identity NOT NULL, procedure_text nvarchar(4000) collate database_default )

-------- get sysarticles information

select @dest_owner = dest_owner, @dest_tabname = dest_table, 
       @src_objid = objid
from sysarticles
where artid = @artid

if @dest_owner is not null
begin
	select @dest_owner = QUOTENAME( @dest_owner ) + N'.'
end
else
begin
	select @dest_owner = N''
end

select @srcobj = QUOTENAME( USER_NAME(OBJECTPROPERTY(@src_objid,'OwnerId'))) collate database_default + N'.' + QUOTENAME(object_name(@src_objid)) collate database_default
select @cmd_sep = N''

DECLARE hCIdx CURSOR LOCAL FAST_FORWARD FOR
select name, indid, status from sysindexes where id = @src_objid and indid > 1 order by indid asc

OPEN hCIdx
FETCH hCIdx INTO @constraint_name, @indid, @status

WHILE (@@fetch_status <> -1)
begin
	if @status & 2 = 2
	begin
		select @unique = N' unique '
	end
	else
	begin
		select @unique = N' '
	end

	insert into #proctext(procedure_text) values( @cmd_sep )
	select @cmd_sep = N'GO'

	select @cmd = N'create' + @unique + N'nonclustered index ' + QUOTENAME(@constraint_name) + N' on ' +@dest_owner + QUOTENAME(@dest_tabname) + N'('
	insert into #proctext(procedure_text) values( @cmd )

	select @spacer = N' '
	select @cmd = N''

	select @indkey = 1
	while (@indkey <= 16)
	begin	
		select @colname = index_col(@srcobj, @indid, @indkey)
		if (@colname is null)
		begin
			select @indkey = 16
		end
		else
		begin
			select @cmd = @cmd + @spacer + QUOTENAME(@colname)
			select @spacer = N','

			if len( @cmd ) > 3000
			begin
				insert into #proctext(procedure_text) values( @cmd )
				select @cmd = N''
			end
		end
		select @indkey = @indkey + 1
	end

	insert into #proctext(procedure_text) values( @cmd )
	insert into #proctext(procedure_text) values( N')' )
	
	FETCH hCIdx INTO @constraint_name, @indid, @status
end

CLOSE hCIdx
DEALLOCATE hCIdx
select procedure_text from #proctext order by c1 asc

go
EXEC dbo.sp_MS_marksystemobject sp_MSscriptmvastablenci
GO

print ''
print 'Creating procedure sp_MSscriptmvastablepkc'
go

create procedure sp_MSscriptmvastablepkc @artid int
as
declare @cmd          nvarchar(4000)
declare @dest_owner   nvarchar(255)
declare @dest_tabname sysname
declare @src_objid    int
declare @constraint_name  sysname
declare @spacer		  nvarchar(1)
declare @srcobj		  nvarchar(1000)
declare @colname	  sysname
declare @indkey		  int
declare @indid		  int

-------- security check, db_owner
declare @retcode int
exec @retcode = dbo.sp_MSreplcheck_publish
if @@ERROR <> 0 or @retcode <> 0
    return(1)

-------- create temp table for command fragments

create table #proctext ( c1 int identity NOT NULL, procedure_text nvarchar(4000) collate database_default )

-------- get sysarticles information

select @dest_owner = dest_owner, @dest_tabname = dest_table, 
       @src_objid = objid
from sysarticles
where artid = @artid

if @dest_owner is not null
begin
	select @dest_owner = QUOTENAME( @dest_owner ) + N'.'
end
else
begin
	select @dest_owner = N''
end

select @srcobj = QUOTENAME( USER_NAME(OBJECTPROPERTY(@src_objid,'OwnerId'))) collate database_default + N'.' + QUOTENAME(object_name(@src_objid)) collate database_default

select @constraint_name = name, @indid = indid from sysindexes where id = @src_objid and status & 16 <> 0

select @cmd = N'alter table ' + @dest_owner + QUOTENAME(@dest_tabname) collate database_default + N' add constraint ' + QUOTENAME(@constraint_name) collate database_default + N' primary key clustered ('
insert into #proctext(procedure_text) values( @cmd )

select @spacer = N' '
select @cmd = N''

select @indkey = 1
while (@indkey <= 16)
begin	
	select @colname = index_col(@srcobj, @indid, @indkey)
	if (@colname is null)
	begin
		select @indkey = 16
	end
	else
	begin
		select @cmd = @cmd + @spacer + QUOTENAME(@colname) collate database_default
		select @spacer = N','

		if len( @cmd ) > 3000
		begin
			insert into #proctext(procedure_text) values( @cmd )
			select @cmd = N''
		end
	end
	select @indkey = @indkey + 1
end

insert into #proctext(procedure_text) values( @cmd )

insert into #proctext(procedure_text) values( N')' )

select procedure_text from #proctext order by c1 asc

go
EXEC dbo.sp_MS_marksystemobject sp_MSscriptmvastablepkc
GO

print ''
print 'Creating procedure sp_MSscriptmvastableidx'
go

create procedure sp_MSscriptmvastableidx @artid int
as
declare @cmd          nvarchar(4000)
declare @dest_owner   nvarchar(255)
declare @dest_tabname sysname
declare @src_objid    int
declare @constraint_name  sysname
declare @spacer		  nvarchar(1)
declare @srcobj		  nvarchar(1000)
declare @colname	  sysname
declare @indkey		  int
declare @indid		  int

-------- security check, db_owner
declare @retcode int
exec @retcode = dbo.sp_MSreplcheck_publish
if @@ERROR <> 0 or @retcode <> 0
    return(1)

-------- create temp table for command fragments

create table #proctext ( c1 int identity NOT NULL, procedure_text nvarchar(4000) collate database_default )

-------- get sysarticles information

select @dest_owner = dest_owner, @dest_tabname = dest_table, 
       @src_objid = objid
from sysarticles
where artid = @artid

if @dest_owner is not null
begin
	select @dest_owner = QUOTENAME( @dest_owner ) + N'.'
end
else
begin
	select @dest_owner = N''
end

select @srcobj = QUOTENAME( USER_NAME(OBJECTPROPERTY(@src_objid,'OwnerId'))) collate database_default + N'.' + QUOTENAME(object_name(@src_objid)) collate database_default

select @constraint_name = name, @indid = indid from sysindexes where id = @src_objid and status & 16 <> 0

select @cmd = N'create unique clustered index ' + QUOTENAME(@constraint_name) + N' on ' +@dest_owner + QUOTENAME(@dest_tabname) + N'('
insert into #proctext(procedure_text) values( @cmd )

select @spacer = N' '
select @cmd = N''

select @indkey = 1
while (@indkey <= 16)
begin	
	select @colname = index_col(@srcobj, @indid, @indkey)
	if (@colname is null)
	begin
		select @indkey = 16
	end
	else
	begin
		select @cmd = @cmd + @spacer + QUOTENAME(@colname)
		select @spacer = N','

		if len( @cmd ) > 3000
		begin
			insert into #proctext(procedure_text) values( @cmd )
			select @cmd = N''
		end
	end
	select @indkey = @indkey + 1
end

insert into #proctext(procedure_text) values( @cmd )

insert into #proctext(procedure_text) values( N')' )

select procedure_text from #proctext order by c1 asc

go
EXEC dbo.sp_MS_marksystemobject sp_MSscriptmvastableidx
GO


print ''
print 'Creating procedure sp_MSscriptmvastable'
go

create procedure sp_MSscriptmvastable @artid int
as
declare @cmd          nvarchar(4000)
declare @dest_owner   nvarchar(255)
declare @dest_tabname sysname
declare @src_objid    int
declare @artcolumns   binary(32)
declare @schema_option binary(8)
declare @art_col	  int
declare @this_col	  int
declare @isset	      int
declare @use_base_type tinyint

declare @spacer		  nvarchar(1)
declare @nullability  nvarchar(10)
declare @typestring   nvarchar(255)
declare @col_name	  sysname

-------- security check, db_owner
declare @retcode int
exec @retcode = dbo.sp_MSreplcheck_publish
if @@ERROR <> 0 or @retcode <> 0
    return(1)

-------- create temp table for command fragments

create table #proctext ( c1 int identity NOT NULL, procedure_text nvarchar(4000) collate database_default )

-------- get sysarticles information

select @dest_owner = dest_owner, @dest_tabname = dest_table, 
       @src_objid = objid, @artcolumns = columns, 
	   @use_base_type = substring(schema_option,8,1) & 32
from sysarticles
where artid = @artid

if @dest_owner is not null
begin
	select @dest_owner = QUOTENAME( @dest_owner ) + N'.'
end
else
begin
	select @dest_owner = N''
end

-- script out CREATE TABLE statement

-- begin create table
select @cmd = N'create table ' + @dest_owner + QUOTENAME(@dest_tabname) + N'('
insert into #proctext(procedure_text) values( @cmd )

-- columns
select @art_col = 1
select @spacer = N' '

DECLARE hCColid CURSOR LOCAL FAST_FORWARD FOR 
select colid from syscolumns where id = @src_objid order by colid asc

OPEN hCColid

FETCH hCColid INTO @this_col

WHILE (@@fetch_status <> -1)
begin
   exec @isset = dbo.sp_isarticlecolbitset @this_col, @artcolumns
   select @col_name = name, 
          @nullability = case isnullable 
		  when 0 then N'NOT NULL' 
		  else N'NULL' end
		  from syscolumns where id=@src_objid and @this_col=colid 
   if @isset != 0 and @col_name is not null
   begin
		if @use_base_type <> 0
		begin
			exec dbo.sp_gettypestring @src_objid, @this_col, @typestring OUTPUT
		end
		else
		begin
			exec dbo.sp_MSgettypestringudt @src_objid, @this_col, @typestring OUTPUT
		end
        select @cmd = @spacer + QUOTENAME(@col_name) + N' ' + @typestring + N' ' + @nullability 
        insert into #proctext(procedure_text) values( @cmd )
		select @art_col = @art_col + 1
        select @spacer = N','
   end
   FETCH hCColid INTO @this_col
end

CLOSE hCColid
DEALLOCATE hCColid

-- end create table
insert into #proctext(procedure_text) values( N')' )

select procedure_text from #proctext order by c1 asc
go
EXEC dbo.sp_MS_marksystemobject sp_MSscriptmvastable
GO

--------------------------------------------------------------------------
--------------------------------------------------------------------------

print ''
print 'Creating procedure sp_fetchshowcmdsinput'
go
SET ARITHABORT ON
SET NUMERIC_ROUNDABORT OFF
SET CONCAT_NULL_YIELDS_NULL ON
SET QUOTED_IDENTIFIER ON
SET ANSI_NULLS ON
SET ANSI_PADDING ON
SET ANSI_WARNINGS ON
go
create procedure sp_fetchshowcmdsinput @numcmds int
as
create table #rcmds( article_id int NOT NULL, partial_command int NOT NULL, command varbinary(1024) NULL, 
xactid binary(10) NOT NULL, xact_seqno binary(10) NOT NULL, publication_id int NOT NULL, 
command_id int NOT NULL, command_type int NOT NULL, originator_srvname nvarchar(128) collate database_default null, 
originator_db nvarchar(128) collate database_default null)
insert into #rcmds exec dbo.sp_replcmds @numcmds
select convert( varbinary(16), xact_seqno ), 0, 0, article_id, command_type, partial_command, command from #rcmds order by xact_seqno, article_id, command_id asc
drop table #rcmds
go
SET ANSI_NULLS OFF
go
EXEC dbo.sp_MS_marksystemobject sp_fetchshowcmdsinput
GO

--------------------------------------------------------------------------
--------------------------------------------------------------------------

print ''
print 'Creating procedure sp_replshowcmds'
go

create procedure sp_replshowcmds @maxtrans int = 1
as
declare @query nvarchar(1024)
declare @dbname sysname
select @dbname = db_name()

select @query = 'execute dbo.sp_fetchshowcmdsinput ' + convert( nvarchar, @maxtrans )
execute master..xp_printstatements @query, @dbname
go

EXEC dbo.sp_MS_marksystemobject sp_replshowcmds
GO

print ''
print 'Creating procedure sp_article_validation'
go

create procedure sp_article_validation
@publication sysname,
@article sysname,
-- The following are values passed to the sp_table_validation call at the subscriber.
@rowcount_only smallint = 1,       
/* 
The @rowcount_only param is overloaded for shiloh release due to backward compatibility concerns.
In shiloh, the checksum functionality has changed.   So 7.0 subscribers will have the old checksum 
routines, which generate different CRC values, and do not have functionality for vertical partitions,
or logical table structures where column offsets differ (due to ALTER TABLEs that DROP and ADD columns).

In 7.0, this was a bit column.  0 meant do not do just a rowcount - do a checksum.  1 meant just do a 
rowcount.

For Shiloh, this parameter is changed to a smallint with these options:
0 - Do a 7.0 compatible checksum
1 - Do a rowcount check only
2 - Use new Shiloh checksum functionality.  Note that because 7.0 subscribers will 
take this parameter as a bit type, not a smallint, it will be interpreted as simply
ON.  That means that passing a 2, and having a 7.0 subscriber, will result in the 7.0
subscriber doing only rowcount validation.   The Shiloh subscribers will do both
rowcount and checksum.  If you want 7.0 subscribers to do checksum validation, use 
the value of 0 for this parameter.   Shiloh subscribers can do the 7.0 compatible 
checksum, but that checksum has the same 7.0 limitations for vertical partitions 
and differences in physical table structure.)
*/
              
@full_or_fast tinyint = 2,  -- full (value 0) does COUNT(*) 
                            -- fast (value 1) uses sysindexes.rows if table (not view); 
                            -- conditional fast (VALUE 2) , first tries fast method, but
                            -- reverts to full if fast method shows differences.
@shutdown_agent bit = 0,    -- If 1 will raise error 20578, which will signal subscriber synchronization agent to shutdown
                            -- immediately after successful validation
@subscription_level bit = 0		-- Whether or not the validation is only picked up by a set of subscribers
								-- that are specified by calls to sp_marksubscriptionvalidation.
, @reserved int = NULL			-- If not null, the sp is called from sp_publication_validation.
as

declare @publication_guid uniqueidentifier
declare @publication_id int
declare @article_guid uniqueidentifier
declare @article_id int
declare @source_name sysname
declare @source_owner sysname
declare @partition_view_id sysname, @table_id sysname
declare @sync_name sysname
declare @destination_table sysname
declare @destination_owner sysname
declare @columns varbinary(32) 
declare @command varchar (4096)
declare @retcode int
declare @actual_rowcount bigint
declare @actual_checksum numeric
declare @status int
declare @active int
declare @publish_bit int
declare @table_name sysname					-- base table name var to passed to sp_table_validation
	, @allow_dts bit
	, @dts_part int
    
set nocount on


set @active = 1
set @publish_bit = 1
set @dts_part = 64

-- Check if the database is published for transactional
if not exists (select * from master..sysdatabases where name = db_name() collate database_default and (category & @publish_bit) = @publish_bit)
begin
    raiserror(20026, 16, -1, @publication)
    return 1
end

-- Get Publication Information
select @publication_id = pubid, @allow_dts = allow_dts from syspublications where name = @publication
if @publication_id is null
begin
    raiserror(20026, 16, -1, @publication)
    return 1
end

-- Get Article Information
select @article_id = artid, @sync_name = OBJECT_NAME(sync_objid),@partition_view_id=sync_objid,
    @destination_table = dest_table, @destination_owner = dest_owner, 
	@status = status, @table_name = OBJECT_NAME(objid),@table_id=objid,
    @columns = columns from sysarticles where name = @article and pubid=@publication_id

if @article_id is null
begin
    raiserror(20027, 16, -1, @article)
    return 1
end

-- Security check
-- Only people have 'select all' permission on the base table can do validation
if permissions(@table_id) & 1 <> 1
begin
	declare @qual_name nvarchar(512)
	exec dbo.sp_MSget_qualified_name @table_id, @qual_name output
	raiserror(20623, 16, -1, @article, @qual_name)
	return 1
end

-- Make sure article status is 'active' 
if (@status & @active) <> @active
begin
    -- Article is not active
    raiserror(20523, 16, -1, @article)
    return 1
end


if @allow_dts = 1
begin
	if @rowcount_only <> 1
	begin
		raiserror(20612, 16, -1)
		return (1) 
	end
	-- For dts horizontal partitioned article, no validation is possible, do nothing or
	-- raise error.
	if (@status & @dts_part <> 0)
	begin
		-- sp_article_validation is called directly, raise error and fail
		if @reserved is null
		begin
			raiserror(20613, 16, -1)
			return (1) 
		end
		-- sp_article_validation is called by sp_publication_validation, 
		-- raise warning and contiue.
		else
		begin
			raiserror(20613, 10, -1)
			return (0)
		end
	end
end
			
	
	

-- Check if table has vertical partition OR horizontal partition
if exists (select * from sysarticles a, syscolumns b
    where
	(
	-- horizontal partition	exists if filter column is not zero
	a.filter <> 0
	
	OR
	--vertical partition
	 (CONVERT(bit, convert(binary(2), SUBSTRING(convert(nvarchar,a.columns), CONVERT(tinyint, 16 - FLOOR((colid-1)/16)), 1)) & POWER(2, ((colid-1)%16))) = 0
           OR CONVERT(bit, convert(binary(2), SUBSTRING(convert( nvarchar,a.columns), CONVERT(tinyint, 16 - FLOOR((colid-1)/16)), 1)) & POWER(2, ((colid-1)%16))) IS NULL)
	)
           AND a.objid = b.id
           AND a.name = @article
           AND a.pubid = @publication_id)
begin
    set @source_name = @sync_name
    select @source_owner= user_name(uid) from sysobjects where id=@partition_view_id

    -- Partitions only support new shiloh checksum functionality or row count validation.
    -- If 7.0 compatible checksum was asked for (@rowcount_only=0), it will be changed to 
    -- override specified value, making it truly only check rowcounts.   If shiloh checksum 
    -- was asked for, thats ok (@rowcount_only=2), thats ok and no need to change it.
    if (@rowcount_only = 0)
    	set @rowcount_only = 1
end

else

begin
  	set @source_name = @table_name
	select @source_owner= user_name(uid) from sysobjects where id=@table_id

end


begin tran -- The table validation and posting to the log MUST happen with a transaction

-- Get publisher's rowcount and/or checksum for the article
if @rowcount_only = 1
begin
    exec @retcode = dbo.sp_table_validation @table = @source_name, @expected_rowcount = @actual_rowcount OUTPUT,
        @rowcount_only = 1, @owner=@source_owner, @full_or_fast = 0, @table_name = @table_name   -- always do full count at publisher
    if @retcode <> 0 or @@error <> 0 
    begin
        commit tran
        return 1
    end
end
else  -- get checksum
begin
    exec @retcode = dbo.sp_table_validation @table = @source_name, @expected_rowcount = @actual_rowcount OUTPUT,
        @expected_checksum = @actual_checksum OUTPUT, @rowcount_only = @rowcount_only, @owner=@source_owner,
        @full_or_fast = 0, @table_name = @table_name   -- always do full count at publisher
    if @retcode <> 0 or @@error <> 0 
    begin
        commit tran
        return 1
    end
end

-- Post sp_table_validation on behalf of the article and send to subscribers
if @rowcount_only = 1
begin
    select @command = 'exec dbo.sp_table_validation @table = ''' + @destination_table + ''', @expected_rowcount = ' +
        convert(varchar(10), @actual_rowcount) + ', @rowcount_only = 1' +
        ', @full_or_fast = ' + convert(varchar(10), @full_or_fast) +
        ', @shutdown_agent = ' + convert(varchar(10), @shutdown_agent)
end
else
begin
    select @command = 'exec dbo.sp_table_validation @table = ''' + @destination_table + ''', @expected_rowcount = ' +
        convert(varchar(10), @actual_rowcount) + ', @expected_checksum = ' + 
        convert(varchar(100), @actual_checksum) + ', @rowcount_only = ' + convert(varchar(5),@rowcount_only) +
        ', @full_or_fast = ' + convert(varchar(10), @full_or_fast) +
        ', @shutdown_agent = ' + convert(varchar(10), @shutdown_agent)
end 

-- Add owner param if destination owner is not NULL
if (@destination_owner IS NOT NULL)
begin
	select @command = @command +
	', @owner = ''' + @destination_owner + ''''
end

declare @command_type int
if @subscription_level = 0
	select @command_type = 35 -- SQL Server Only command type
else
	select @command_type = 69 -- sub validation command

exec @retcode = dbo.sp_replpostcmd 
    0,              -- partial flag
    @publication_id, 
    @article_id, 
    @command_type,            -- SQL Server Only command type
    @command
if @retcode <> 0 or @@error <> 0
begin
    commit tran
    return 1
end

commit tran

Go

EXEC dbo.sp_MS_marksystemobject sp_article_validation

print ''
print 'Creating procedure sp_publication_validation'
go


create procedure sp_publication_validation
@publication sysname,
@rowcount_only smallint = 1,
/* 
The @rowcount_only param is overloaded for shiloh release due to backward compatibility concerns.
In shiloh, the checksum functionality has changed.   So 7.0 subscribers will have the old checksum 
routines, which generate different CRC values, and do not have functionality for vertical partitions,
or logical table structures where column offsets differ (due to ALTER TABLEs that DROP and ADD columns).

In 7.0, this was a bit column.  0 meant do not do just a rowcount - do a checksum.  1 meant just do a 
rowcount.

For Shiloh, this parameter is changed to a smallint with these options:
0 - Do a 7.0 compatible checksum
1 - Do a rowcount check only
2 - Use new Shiloh checksum functionality.  Note that because 7.0 subscribers will 
take this parameter as a bit type, not a smallint, it will be interpreted as simply
ON.  That means that passing a 2, and having a 7.0 subscriber, will result in the 7.0
subscriber doing only rowcount validation.   The Shiloh subscribers will do both
rowcount and checksum.  If you want 7.0 subscribers to do checksum validation, use 
the value of 0 for this parameter.   Shiloh subscribers can do the 7.0 compatible 
checksum, but that checksum has the same 7.0 limitations for vertical partitions 
and differences in physical table structure.)
*/

@full_or_fast tinyint = 2,  -- full (value 0) does COUNT(*) 
                            -- fast (value 1) uses sysindexes.rows if table (not view); 
                            -- conditional fast (VALUE 2) , first tries fast method, but
                            -- reverts to full if fast method shows differences.
@shutdown_agent bit = 0     -- Set for last article in publication, which will signal subscriber synchronization agent to shutdown
                            -- immediately after successful validation
as

set nocount on

declare @retcode tinyint
declare @publication_id int
declare @article sysname
declare @article2 sysname
declare @publish_bit int

    
set @publish_bit = 1

-- Security Check
-- No reason anyone but Sysadmin or dbo of publishing db should run this
exec @retcode = dbo.sp_MSreplcheck_publish
if @@error <> 0 or @retcode <> 0
begin
	return (1)
end

-- Check if the database is published for transactional
if not exists (select * from master..sysdatabases where name = db_name() collate database_default and (category & @publish_bit) = @publish_bit)
begin
    raiserror(20026, 16, -1, @publication)
    return 1
end

-- Get Publication Information
select @publication_id = pubid from syspublications where name = @publication
if @publication_id is null
begin
    raiserror(20026, 16, -1, @publication)
    return 1
end

-- Security Check will be done inside sp_article_validation
-- Security check
-- Only people have 'select all' permission on the base table can do validation
declare @table_id int

select top 1 @article = name, @table_id = objid from sysarticles where
	pubid = @publication_id and 
	(status & 1) <> 0 and   -- active articles only
	(type & 1) <> 0 and		-- only checksum tables/views.
	((permissions(objid) & 1) <> 1)

if @table_id is not null
begin
	declare @qual_name nvarchar(512)
	exec dbo.sp_MSget_qualified_name @table_id, @qual_name output
	raiserror(20623, 16, -1, @article, @qual_name)
	return 1
end

declare hC CURSOR LOCAL FAST_FORWARD for select name from sysarticles where pubid = @publication_id and
(status & 1) <> 0 and   -- active articles only
(type & 1) <> 0			-- only checksum tables/views.

open hC
fetch hC into @article
while (@@fetch_status <> -1)
begin
    set @article2 = @article

    -- Look ahead to next article
    fetch hC into @article

    -- If we are at the last article, pass the @shutdown_agent value
    if (@@fetch_status = -1) 
    begin
        exec @retcode = dbo.sp_article_validation @publication, @article2, @rowcount_only = @rowcount_only,
            @full_or_fast = @full_or_fast, @shutdown_agent = @shutdown_agent, @reserved = 1

    end
    else
        exec @retcode = dbo.sp_article_validation @publication, @article2, @rowcount_only = @rowcount_only,
            @full_or_fast = @full_or_fast, @reserved = 1
    
    if @retcode <> 0 or @@error <> 0
    begin
        close hC
        deallocate hC
        return 1
    end
end
close hC
deallocate hC
go

EXEC dbo.sp_MS_marksystemobject sp_publication_validation
GO


print ''
print 'Creating procedure sp_marksubscriptionvalidation'
go


CREATE PROCEDURE sp_marksubscriptionvalidation (
    @publication sysname,    /* publication name */
    @subscriber sysname,             /* subscriber name */
    @destination_db sysname   /* destination database name */
) AS

    DECLARE @retcode int, @pubid int

    DECLARE @artid int, @active tinyint
    DECLARE @srvid smallint
	DECLARE @non_sql_flag bit

  
    -- Initialization
    select @active = 2

    /* 
    ** Security Check.
    */
	exec @retcode = dbo.sp_MSreplcheck_publish
	if @@ERROR <> 0 or @retcode <> 0
		return(1)

    /* Validate names */

    EXECUTE @retcode = dbo.sp_validname @publication
    IF @@ERROR <> 0 OR @retcode <> 0
        RETURN (1)

    EXECUTE @retcode = dbo.sp_validname @subscriber
    IF @@ERROR <> 0 OR @retcode <> 0
        RETURN (1)

    EXECUTE @retcode = dbo.sp_validname @destination_db
    IF @@ERROR <> 0 OR @retcode <> 0
        RETURN (1)

    /*
    ** Parameter Check:  @publication
    ** Check to make sure that the publication exists, that it's not NULL,
    ** and that it conforms to the rules for identifiers.
    */
    SELECT @pubid = pubid FROM syspublications WHERE name = @publication
	if @pubid is null
	begin
        RAISERROR (20026, 16, -1, @publication)
        RETURN (1)
    END

    /*
    ** Parameter Check:  @subscriber
    ** Check to make sure that the subscriber exists
    */
    select @subscriber = UPPER(@subscriber)
        
	SELECT @srvid = srvid, @non_sql_flag = 
		case when srvproduct = N'MSREPL-NONSQL' then 1
		else 0 end
		FROM master..sysservers
		WHERE UPPER(srvname) = UPPER(@subscriber) collate database_default
		  AND (srvstatus & 4) <> 0
	if @srvid is null
    BEGIN
        RAISERROR (14063, 16, -1)
        RETURN (1)
    END

	if @non_sql_flag = 1
	begin
        RAISERROR (20614, 16, -1)
        RETURN (1)
	end

    -- Wrong dest_db will be caught by the following query

    -- Check to make sure the subscription exists 
    IF NOT EXISTS (SELECT *
          FROM syssubscriptions sub,
               sysextendedarticlesview art,
               syspublications pub
         WHERE pub.pubid = @pubid
           AND sub.srvid = @srvid
           AND sub.artid = art.artid
           AND art.pubid = pub.pubid
           AND sub.dest_db = @destination_db)
    BEGIN
        RAISERROR (14055, 16, -1)
        RETURN (1)
    END

	-- Select an article for that is actively subscribed.
	-- If none is found, do nothing
	select top 1 @artid = art.artid 
          FROM syssubscriptions sub,
               sysextendedarticlesview art
         WHERE sub.srvid = @srvid
           AND sub.artid = art.artid
           AND art.pubid = @pubid
           AND sub.dest_db = @destination_db
           AND sub.status = @active

	if @artid is null
		return 0

	declare @command nvarchar (1000)

	-- No need to quote them
	select @command = @subscriber + @destination_db
	exec @retcode = dbo.sp_replpostcmd 
		0,              -- partial flag
		@pubid, 
		@artid, 
		68,             -- subscription validation marker
		@command
	if @retcode <> 0 or @@error <> 0
		return 1

    RETURN(0)
go

EXEC dbo.sp_MS_marksystemobject sp_marksubscriptionvalidation
GO

print ''
print 'Creating procedure sp_dropanonymousagent'
go


CREATE PROCEDURE sp_dropanonymousagent
@subid uniqueidentifier,
@type int -- 1 tran sub, 2 merge sub
as
	set nocount on 
	declare @login sysname
	-- Null @login indicates sysadmin or db_owner
	if IS_SRVROLEMEMBER ('sysadmin') = 0 and is_member('db_owner') = 0
		select @login = suser_sname()
    /*
    ** Get distribution server information for remote RPC
    ** agent verification.
    */
    declare @distributor sysname
	declare @distribdb sysname
	declare @distproc nvarchar(1000)
	declare @retcode int

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
        '.dbo.sp_MSdrop_anonymous_entry'

	exec @retcode = @distproc 
		@subid = @subid,
		@login = @login,
		@type = @type

    IF @@error <> 0 OR @retcode <> 0
		RETURN (1)

    RETURN (0)
go

EXEC dbo.sp_MS_marksystemobject sp_dropanonymousagent
GO

print ''
print 'Creating procedure sp_replrestart'
go


CREATE PROCEDURE sp_replrestart 
AS

    SET NOCOUNT ON

    /*
    ** Declarations.
    */
	declare @retcode int
		,@lsn binary(10)
		,@dist_lsn binary(10)
		,@distributor sysname
		,@distribdb sysname
		,@distproc nvarchar(4000)
		,@dbname sysname
	/*
	** Initializations
	*/
	select @retcode = 0
	select @dbname = db_name()

	/*
	** Security
	*/
    exec @retcode = dbo.sp_MSreplcheck_publish
    if @@ERROR <> 0 or @retcode <> 0
        return(1)

	-- Make sure the database is published.
    IF (SELECT category & 1
          FROM master..sysdatabases
         WHERE name = @dbname collate database_default) = 0
    BEGIN
        RAISERROR (14013, 16, -1)
        RETURN (1)
    END

	-- Make sure that the log reader is not running
	-- Use 0 so that it will not hold the repl proc structure (the lock).
    exec @retcode = dbo.sp_replcmds 0
    if @@ERROR <> 0 or @retcode <> 0
	begin
		RAISERROR (20610, 16, -1, 'sp_replrestart')
        return(1)
	end

    /*
    ** Get distribution server information for remote RPC call.
    */

    EXEC @retcode = dbo.sp_helpdistributor @rpcsrvname = @distributor OUTPUT,
                                       @distribdb = @distribdb OUTPUT

    IF @@ERROR <> 0 OR  @retcode <> 0
    BEGIN
        RAISERROR (14071, 16, -1)
        RETURN (1)
    END

	-- Get max dist lsn
    SELECT @distproc = RTRIM(@distributor) + '.' + @distribdb + '.dbo.sp_MSget_last_transaction'
    EXECUTE @retcode = @distproc 
        @publisher = @@SERVERNAME,
        @publisher_db = @dbname,
        @max_xact_seqno = @dist_lsn output
	IF @@ERROR <> 0 or @retcode <> 0
		return -1

	if @dist_lsn is null
		set @dist_lsn = 0x0

	-- To safeguard the case when the logreader is started after the check later
	-- use a tran to prevent the logreader from picking up the new lsns
	begin tran

	while 1 = 1
	begin
		-- Get publisher's lsn
		EXEC @retcode = dbo.sp_replincrementlsn @lsn OUTPUT
		IF @@ERROR <> 0 or @retcode <> 0
			goto UNDO

		if @lsn > @dist_lsn
			break
	end

	/* Mark the new starting point of the replication.*/
	exec @retcode = dbo.sp_repldone NULL, NULL, 0, 0, 1
    IF @@ERROR <> 0 or @retcode <> 0
        GOTO UNDO

	/* release our hold on the db as logreader */
	EXEC @retcode = dbo.sp_replflush
    IF @@ERROR <> 0 or @retcode <> 0
		GOTO UNDO

	commit tran
	return 0

UNDO:
	if @@trancount <> 0
		rollback tran
go

EXEC dbo.sp_MS_marksystemobject sp_replrestart
GO


print ''
print 'Creating procedure sp_MSpub_adjust_identity'
go

CREATE PROCEDURE sp_MSpub_adjust_identity
@artid int = null
as
	set nocount on

	declare @retcode int
	declare @cmd nvarchar(1000)
	declare @objid int, @threshhold int
    declare @pub_range bigint, @next_seed bigint, @current_pub_range bigint
	declare	@last_seed bigint, @identity_so_far bigint, @threshold int, @range bigint
	declare @database sysname, @table_name sysname
	declare @qualname nvarchar(512)
    DECLARE @distributor sysname
    DECLARE @distribdb sysname

    /*
    ** Security Check.
    */
	exec @retcode = dbo.sp_MSreplcheck_publish
	if @@ERROR <> 0 or @retcode <> 0
		return(1)
	
	select @database = db_name()

    EXEC @retcode = dbo.sp_helpdistributor @rpcsrvname = @distributor OUTPUT,
                                       @distribdb = @distribdb OUTPUT
    IF @@ERROR <> 0
    BEGIN
        RAISERROR (14071, 16, -1)
        RETURN (1)
    END

    DECLARE adjust_identity CURSOR LOCAL FAST_FORWARD FOR
        SELECT art1.objid
          FROM sysarticles art1,
		       sysarticleupdates art2
		  where art1.artid = art2.artid and
			    art2.identity_support = 1 and
				(art1.artid = @artid or @artid is null)
    FOR READ ONLY

	OPEN adjust_identity		
    FETCH adjust_identity INTO @objid
    WHILE (@@fetch_status <> -1)
	begin
		select @table_name = object_name(@objid)
		exec @retcode = dbo.sp_MSget_qualified_name @objid, @qualname OUTPUT
		
		select @range = range, @pub_range = pub_range, @current_pub_range = current_pub_range, 
            @last_seed = last_seed, 
            @threshold = threshold from 
			MSpub_identity_range where objid=@objid
  
		select @identity_so_far = ident_current(@qualname)

		if @last_seed is null
		begin
			-- First time
    		select @last_seed = (@identity_so_far / @pub_range) * @pub_range
			-- We always reserve a new range for the publisher without reseeding 
			-- the publisher, and we guarantee to have more slots then 
			-- a full range initially for the publisher.
			if	(@pub_range > 0 and @last_seed < @identity_so_far) or
				(@pub_range < 0 and @last_seed > @identity_so_far)
				select @last_seed = @last_seed + @pub_range

			select @next_seed = @last_seed + @pub_range
			-- Initialize distribution side entry
			SELECT @cmd = RTRIM(@distributor) + '.' + RTRIM(@distribdb) + '.dbo.sp_MSinsert_identity'
			EXEC @retcode = @cmd
				@publisher = @@servername,
				@publisher_db = @database,
				@tablename = @table_name,
				@identity_support = 1,
				@pub_identity_range = 0, -- We don't need this at the distributor
				@identity_range = @range,
				@threshold 	= @threshold,
                -- Make sure we don't have gap at the beginning
				@next_seed	= @next_seed,
				@max_identity = null
			IF @@ERROR <> 0 OR @retcode <> 0
				GOTO UNDO
		    -- Add constraint only without reseeding.
		    exec @retcode = dbo.sp_MSreseed
			    @objid = @objid,
			    @next_seed = @last_seed,
			    @range = @pub_range,
			    @is_publisher = -1,
                @check_only = 1,
				@initial_setting = 1,
				@bound_value = @identity_so_far

		    IF @@ERROR <> 0 OR @retcode <> 0
			    GOTO UNDO
		    update MSpub_identity_range set last_seed = @last_seed where objid = @objid
		    IF @@ERROR <> 0
			    GOTO UNDO
		end
		else
		begin

			-- Leave one slot unused. This is to prevent violation of primary key constraint
			-- if the next value is used by a subscriber and the publisher has received it.
			-- It seems the pk constraint will be validated before this check.
			declare @actual_range int
			if @current_pub_range > 0
				select @actual_range = @current_pub_range -1
			else
				select @actual_range = @current_pub_range +1

			-- Calculate the current ratio
			if 100*(@identity_so_far - @last_seed)/@actual_range >= @threshold
			-- need bump up
			begin
				SELECT @cmd = RTRIM(@distributor) + '.' + RTRIM(@distribdb) + '.dbo.sp_MSfetchAdjustidentityrange'
				EXEC @retcode = @cmd
					@publisher = @@servername,
					@publisher_db = @database,
					@tablename = @table_name,
					@adjust_only = 1,
					@for_publisher = 1,
					@range = @pub_range,
					@next_seed = @next_seed output
				IF @@ERROR <> 0 OR @retcode <> 0
					GOTO UNDO

				select @last_seed = @next_seed - @pub_range
				
				update MSpub_identity_range set last_seed = @last_seed,
					current_pub_range = @pub_range
					where objid = @objid
				IF @@ERROR <> 0
					GOTO UNDO
				-- RESEED and change constraint
				exec @retcode = dbo.sp_MSreseed
					@objid = @objid,
					@next_seed = @last_seed,
					@range = @pub_range,
					@is_publisher = -1
				IF @@ERROR <> 0 OR @retcode <> 0
					GOTO UNDO
			end
		end

		FETCH adjust_identity INTO @objid
	end
	return 0
UNDO:
	-- No need to start a transaction.
    return 1
go

EXEC dbo.sp_MS_marksystemobject sp_MSpub_adjust_identity
GO


print ''
print 'Creating procedure sp_helparticledts'
go

CREATE PROCEDURE sp_helparticledts (
    @publication sysname,        /* Publication name */
    @article sysname	         /* Article name */
    ) AS

    SET NOCOUNT ON

    /*
    ** Declarations.
    */

    DECLARE @artid int
    DECLARE @pubid int
    DECLARE @retcode int
	declare @article_name sysname

   /*
    ** Check to see if the database has been activated for publication.
    */

    IF (SELECT category & 1
          FROM master..sysdatabases
         WHERE name = DB_NAME() collate database_default) = 0

    BEGIN
            RAISERROR (14013, 16, -1)
            RETURN (1)
    END


    /*
    ** Parameter Check:  @publication.
    ** Make sure that the publication exists.
    */

    IF @publication IS NULL
        BEGIN
            RAISERROR (14043, 16, -1, '@publication')
            RETURN (1)
        END

    EXECUTE @retcode = dbo.sp_validname @publication

    IF @@ERROR <> 0 OR @retcode <> 0
    RETURN (1)

	declare @allow_dts bit

    SELECT @pubid = pubid, @allow_dts = allow_dts	
		FROM syspublications WHERE name = @publication

    IF @pubid IS NULL
        BEGIN
            RAISERROR (20026, 11, -1, @publication)
            RETURN (1)
        END


	if @allow_dts = 0
	begin
		RAISERROR ('The publication ''%s'' does not allow DTS.', 11, -1, @publication)
		RETURN (1)
	end

    /*
    ** Check to see that the article exists in sysarticles.
    ** Fetch the article identification number.
    */

    IF @article IS NULL
        BEGIN
            RAISERROR (14043, 16, -1, '@article')
            RETURN (1)
        END

    /*
    EXECUTE @retcode = dbo.sp_validname @article

    IF @retcode <> 0
    RETURN (1)
    */

    SELECT @artid = artid, @article_name = name
      FROM sysarticles
     WHERE name = @article
       AND pubid = @pubid
    IF @artid IS NULL
        BEGIN
            RAISERROR (20027, 11, -1, @article)
            RETURN (1)
        END
	
	select 
		N'pre_script_ignore_error_task_name' = @article_name + N'_pre_ignore_error',
		N'pre_script_task_name' = @article_name + N'_pre',
		N'transformation_task_name' = @article_name,
		N'post_script_ignore_error_task_name' = @article_name + N'_post_ignore_error',
		N'post_script_task_name' = @article_name + N'_post'
go

EXEC dbo.sp_MS_marksystemobject sp_helparticledts
GO


print ''
print 'Creating procedure sp_changesubscriptiondtsinfo'
go

CREATE PROCEDURE sp_changesubscriptiondtsinfo (
    @job_id varbinary(16),
    @dts_package_name sysname = NULL,
	@dts_package_password sysname = NULL,
	@dts_package_location nvarchar(12) = NULL

    ) AS

    /*
    ** Declarations.
    */

    DECLARE @srvid smallint
    DECLARE @artid int
    DECLARE @retcode int
	declare @login_name sysname
	declare @update_mode int
	declare @subscription_type int
	declare @dts_package_location_id int

    /*
    ** Initializations.
    */
    SET NOCOUNT ON
    
	
    /* 
    ** Get subscription properties and do Security Check.
    ** We use login_name stored in syssubscriptions to manage security 
    */

	select @update_mode = update_mode, @login_name = login_name,
		@subscription_type = subscription_type,
		@artid = artid              
		FROM syssubscriptions s WHERE 
			s.distribution_jobid = @job_id

    /*
    ** Check if the subscription exists.
    */
    IF @update_mode is null
	BEGIN
        RAISERROR (14055, 11, -1)
        RETURN (1)
    END

	if	@update_mode != 0
	begin
		RAISERROR(21180, 16, -1)    
		RETURN (1)
	end

	-- Only push store DTS info at distributor.
	if @subscription_type <> 0
	begin
		RAISERROR(21181, 16, -1)    
		RETURN (1)
	end

	--Security check

    IF  suser_sname(suser_sid()) <> @login_name AND is_srvrolemember('sysadmin') <> 1  
        AND is_member ('db_owner') <> 1
    BEGIN
		-- Only members of the sysadmin fixed server role, db_owner fixed database role or the creator of the subscription can change this subscription property.'
        RAISERROR(21175, 11, -1)
        RETURN (1)
    END

    -- Get pubid
	declare @pubid int
	select @pubid = pubid from sysarticles where artid = @artid

    /* Get subscription type of the publication */
	if not exists (select * from syspublications where
		pubid = @pubid and
		allow_dts = 1)
	begin
		RAISERROR(21178, 16, -1)    
		RETURN (1)
	end

	if @dts_package_location is null
		select @dts_package_location_id = null
	else IF LOWER(@dts_package_location collate SQL_Latin1_General_CP1_CS_AS) = N'distributor' 
		select @dts_package_location_id = 0
	ELSE IF LOWER(@dts_package_location collate SQL_Latin1_General_CP1_CS_AS) = N'subscriber' 
		select @dts_package_location_id = 1
	ELSE 
	begin
		raiserror(20587, 16, -1, '@dts_package_location', 'sp_changesubscriptiondtsinfo')
		return(1)
	end

	-- Encrypt DTS package password
	declare @change_password bit

	if @dts_package_password is null
		select @change_password = 0
	else
		select @change_password = 1

	-- When user sends in empty string, reset it to null.
	-- Have to do this before scramble because the result may contains invalid
	-- unicode code points which are equael to some collation.
	if @dts_package_password = N''
		select @dts_package_password = NULL

	declare @enc_dts_package_password nvarchar(524)
        select @enc_dts_package_password = @dts_package_password

	if @enc_dts_package_password is not null
	begin
		EXEC @retcode = master.dbo.xp_repl_encrypt @enc_dts_package_password OUTPUT
		IF @@error <> 0 OR @retcode <> 0
			return 1
	end

    /*
    ** Get distribution server information for remote RPC
    ** agent verification.
    */
    declare @distributor sysname
	declare @distribdb sysname
	declare @distproc nvarchar(1000)

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
        '.dbo.sp_MSchange_subscription_dts_info'

	exec @retcode = @distproc 
		@job_id = @job_id,
		@dts_package_name = @dts_package_name,
		@dts_package_password = @enc_dts_package_password,
		@dts_package_location = @dts_package_location_id,
		@change_password = @change_password

    IF @@error <> 0 OR @retcode <> 0
		RETURN (1)

    RETURN (0)
go

EXEC dbo.sp_MS_marksystemobject sp_changesubscriptiondtsinfo
GO

print ''
print 'Creating procedure sp_MSdrop_6x_replication_agent'
go
create procedure sp_MSdrop_6x_replication_agent
@job_id UNIQUEIDENTIFIER,
@category_id int
as
    declare @distbit int
    declare @db_name sysname
    declare @cmd varchar(4000)

    select @distbit = 16

    declare hCdatabase CURSOR LOCAL FAST_FORWARD FOR
        select name from master.dbo.sysdatabases 
            where
            category & @distbit <> 0 
        for read only

    open hCdatabase
    fetch next from hCdatabase into @db_name
    while (@@fetch_status <> -1)
    begin

        if @category_id = 13
        begin
            select @cmd = 'delete from ' + @db_name + '.dbo.MSlogreader_agents where job_id = convert (uniqueidentifier, ''' +
                convert (varchar(100), @job_id) + ''')'
            exec (@cmd)
        end
        else if @category_id = 15   
        begin
            select @cmd = @db_name + '.dbo.sp_MSdrop_6x_publication'
            exec @cmd @job_id = @job_id
        end
        else
            return 0

        if @@ERROR <> 0
            return 1
        
        fetch next from hCdatabase into @db_name
    end
    close hCdatabase
    deallocate hCdatabase
go

EXEC dbo.sp_MS_marksystemobject sp_MSdrop_6x_replication_agent
GO

print ''
print 'Creating procedure sp_MSreinit_article'
go
create procedure sp_MSreinit_article (
	@publication sysname
	,@article sysname = N'%'
	,@need_new_snapshot bit = 0
	,@need_reinit_subscription bit = 0
	,@force_invalidate_snapshot bit	= 0
	,@force_reinit_subscription bit = 0
	,@check_only bit = 0
)
as
	declare @retcode int
		,@active tinyint
		,@subscribed tinyint
		,@artid int
		,@pubid int
		,@none tinyint
		,@immediate_sync_ready bit
		,@allow_anonymous bit

    -- Initialization
    select @active = 2
    select @subscribed = 1
    SELECT @none = 2            /* Const: synchronization type 'none' */
    select @active = 2
	select @pubid = pubid, @immediate_sync_ready = immediate_sync_ready,
		@allow_anonymous = allow_anonymous 
		from syspublications where name = @publication
	
	if @article = N'%'
		select @artid = 0
	else
		select @artid = artid from sysarticles where name = @article and pubid = @pubid

	begin tran 
	save tran sp_MSreinit_article

	if @need_new_snapshot = 1 and @immediate_sync_ready = 1
	begin
		-- If at publication level, we know that we should do it since 
		-- @immediate_sync_ready = 1
		-- If at article level, we only do it for the articles that have been
		-- processed by the snapshot agent, but not new articles.
		-- sp_addarticle calls this proc at publication level.
		-- It also make calls to sp_articlecolumn and sp_articleview which in turn
		-- call this sp. We don't want to do anything here with those calls.
		if @artid = 0 or exists (select * from syssubscriptions s where 
			s.srvid < 0 and
			s.status = @active and
			s.artid = @artid)
		begin
			-- Fail and raiserror error
			if @force_invalidate_snapshot = 0
			begin
				raiserror(20607, 16, -1)
				goto UNDO
			end

			if @check_only = 0
			begin
				UPDATE syspublications SET immediate_sync_ready = 0 WHERE 
					pubid = @pubid and
					immediate_sync_ready <> 0
                IF @@ERROR <> 0
					goto UNDO

				DECLARE @distributor sysname
					, @distribdb sysname
					, @distproc nvarchar (255)
					, @dbname sysname

				select @dbname = db_name()

				EXEC @retcode = dbo.sp_helpdistributor @rpcsrvname = @distributor OUTPUT,
												   @distribdb = @distribdb OUTPUT
				IF @retcode <> 0 OR @@ERROR <> 0
					goto UNDO

				IF @distribdb IS NULL OR @distributor IS NULL
				BEGIN
					RAISERROR (14071, 16, -1)
					goto UNDO
				END

				-- Deactivate virtual (but not virtual anonymous) subscriptions at the distributor
				SELECT @distproc = RTRIM(@distributor) + '.' + RTRIM(@distribdb) + '.dbo.sp_MSinvalidate_snapshot'
				EXEC @retcode = @distproc 
					@publisher = @@SERVERNAME, 
					@publisher_db = @dbname, 
					@publication = @publication

				IF @@ERROR <> 0 OR @retcode <> 0
					goto UNDO

				-- Raise a warning. Snapshot is invalidated. Need to run
				-- snapshot agent again..
				raiserror(20605, 10, -1)
			end
		end
	end
	
	if @need_reinit_subscription = 1
	begin
		-- Reinitialize the subscriptions if there are any.
		-- No need to reinit no_sync subscriptions.
		-- The query below works for an article or whole publication (@artid == 0)
		-- Including virtual subscriptions to take care anonymous.
		if exists (select * from syssubscriptions s where
			s.status = @active and
			-- Only include virtual subscription if allow anonymous
			(s.srvid >= 0 or (@allow_anonymous = 1 and @immediate_sync_ready = 1)) and
			s.sync_type <> @none and
			(s.artid = @artid or 
			(@artid = 0 and exists (select * from 
				syspublications p, sysarticles a where
				a.artid = s.artid and 
				a.pubid = p.pubid and
				p.pubid = @pubid))))
		begin
			-- Fail and raiserror error
			if @force_reinit_subscription = 0
			begin
				raiserror(20608, 16, -1)
				goto UNDO
			end

			if @check_only = 0
			begin
				EXEC @retcode = dbo.sp_reinitsubscription 
					@publication = @publication, 
					@article = @article,
					@subscriber = 'all',
					@for_schema_change = 1
				IF @@ERROR <> 0 OR @retcode <> 0
				BEGIN
					GOTO UNDO
				END
				-- Raise a warning. Subscriptions is reintialized.
				raiserror(20606, 10, -1)
			end
		end
	end

	COMMIT TRAN sp_MSreinit_article
	
	return 0
UNDO:
    IF @@TRANCOUNT > 0
    begin
        ROLLBACK TRAN sp_MSreinit_article
        COMMIT TRAN 
    end
    return 1
go

EXEC dbo.sp_MS_marksystemobject sp_MSreinit_article
GO


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
    DECLARE @retcode int

    SELECT @retcode = 0

    EXEC @retcode = sp_MSreplcheck_publish
    IF @@ERROR <> 0 OR @retcode <> 0
        return (1)

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
go

print ''
print 'Creating procedure sp_MScomputeunresolvedrefs'
go
CREATE PROCEDURE sp_MScomputeunresolvedrefs
    @publication sysname, -- Must provide the publication name
    @article     sysname = '%' -- '%' means all articles in the specified publication, otherwise an exact match is performed
AS
    SET NOCOUNT ON 
    DECLARE @pubid int 
    
    -- Parameter check: @publication

    IF @publication IS NULL
    BEGIN
        RAISERROR (14043, 16, -1, '@publication')
        RETURN (1)
    END

    SELECT @pubid = NULL 
    -- Get the pubid of the publication
    SELECT @pubid = pubid 
      FROM syspublications
     WHERE name = @publication
    
    IF @pubid IS NULL
    BEGIN
        RAISERROR (20026, 11, -1, @publication)
        RETURN (1)    
    END

    SELECT DISTINCT 
           'article' = a.name, 
           'dependent object' = o.name, 
           'dependent object owner' = u.name, 
           'dependent objectid' = o.id 
      FROM dbo.sysextendedarticlesview a
    INNER JOIN sysdepends dep
        ON a.objid = dep.id
       AND a.pubid = @pubid
       AND (@article = '%' OR name = @article)
       AND dep.depid NOT IN (SELECT objid FROM dbo.sysextendedarticlesview
                              WHERE pubid = @pubid 
                                AND (@article = '%' OR name = @article))
    INNER JOIN sysobjects o
        ON dep.depid = o.id
    INNER JOIN sysusers u
        ON u.uid = o.uid          
GO


exec dbo.sp_MS_marksystemobject sp_MScomputeunresolvedrefs
go
 
/*
 * Name :       sp_MShelptranconflictpublications
 * Called by:	sp_MShelpconflictpublications
 * Description: This sp returns a list of queued publications or subscriptions in the current
 *    database that may have conflicts. Results are ordered by publication
 *    name. * Parameters:  1. publication_type( sysname; '%'==ALL  | 'queued' )
 * Output Result Set has the following structure:
 *  
----------------------------------------------------------------------------------
 *      Name                Datatype                Description
 *  
----------------------------------------------------------------------------------
 *  a. name     (sysname)      Publication name
 *  b. publication_type  (varchar(9))  'merge' | 'queued' | 'immediate' (reserved)
 *  c. merge_pub_id   (uniqueidentifier) Merge publication identifier
 *  d. tran_pub_id  (integer)   Queued publication identifier 
 *  e. sub_agent_id    (integer)    Unique publication identifier on a tran subscriber
 *  NOTE: In case of queued tran publications, either d or e will have a value at any time
 *  and this will also indicate, if we are processing a subscriber of a publication (d 
 *  will be NULL and e will have a value) or if we are processing the publisher side (d
 *  will have a value and e will be NULL)
 */ 

raiserror('Creating procedure sp_MShelptranconflictpublications', 0,1)
GO

create procedure sp_MShelptranconflictpublications (
 	@publication_type	sysname = 'queued' )		-- '%'==ALL | 'queued'
as
begin
	set nocount on
	declare @merge_pub_id uniqueidentifier
	
	--
	-- validate
	--
	if (@publication_type NOT IN ('%', 'queued'))
	begin
		raiserror('sp_MShelptranconflictpublications(debug): Invalid @publication_type=%s specified', 16, 1, @publication_type)
		return (1)
	end
		
	--
	-- create a temp table for results
	--
 	create table #cftpublications ( publication sysname collate database_default, t_pub_id integer, s_agent_id integer)

 	--
 	-- process publisher info
 	--
 	if exists (select * from sysobjects where name = 'syspublications')
 	begin
 		insert into #cftpublications(publication, t_pub_id)
 			select name, pubid from syspublications
 		if (@@error != 0)
 		begin
			raiserror('sp_MShelptranconflictpublications(debug): insert for tran publications failed', 16, 1)
			return (1)
 		end
 	end

 	--
 	-- process subscriber info
 	--
 	if exists (select * from sysobjects where name = 'MSsubscription_agents')
 	begin
 		insert into #cftpublications(publication, s_agent_id)
 			select publication, id from MSsubscription_agents where update_mode in (2,3,4,5)
 	end

 	--
 	-- now do a select on the temp table
 	--
 	select	'name'				= publication,
 			'publication_type'	= N'queued',
 			'merge_pub_id' 		= @merge_pub_id,
 			'tran_pub_id' 		= t_pub_id,
 			'sub_agent_id'		= s_agent_id
 	from 	#cftpublications
 			
 	--
 	-- all done
 	--
 	return 0
end
go

exec dbo.sp_MS_marksystemobject sp_MShelptranconflictpublications
go

/*
 * Name :       sp_MShelptranconflictcounts
 * Description: This sp returns the count of conflicts (from each conflict table) in 
 *    each publication. Results can optionally be filtered to include only a 
 *    single publication. Results are always ordered by article name. Only 
 *    articles with non-zero conflict counts are returned.
 * Parameters:  1. Publication Name( sysname; default '%'==ALL PUBLICATIONS)
 * Output Result Set has the following structure:
 *  
----------------------------------------------------------------------------------
 *      Name                Datatype                Description
 *  
----------------------------------------------------------------------------------
 *  a. article    (nvarchar(256))      owner qualified Article name
 *  b. conflict_table  (sysname)   Associated conflict table (owner qualified)
 *  c. queued_source_proc (sysname)   Queued proc to get source row - sp_MSgettrancftsrcrow
 *  d. centralized_conflicts(bit)    Centralized (1) or Decentralized (0) 
 *            conflicts specified by the article
 *  e. conflict_count  (integer)           Count of (insert, update and delete) conflicts in 
 *            the conflict table for this article
 */
raiserror('Creating procedure sp_MShelptranconflictcounts', 0,1)
GO

create procedure sp_MShelptranconflictcounts ( 
	@publication_name sysname = '%' )
as 
begin
	set nocount on 

	declare @pubid int
			,@centralized_conflicts bit
			,@article sysname
			,@artid int
			,@conflict_table sysname
			,@cft_tabid int
			,@spname sysname
			,@cmd nvarchar(4000)
			,@conflicts_count int
			,@publisher sysname
			,@publisher_db sysname
			,@owner sysname

	select @spname = 'sp_MSgettrancftsrcrow'

	--
	-- create temp table for results
	--
	create table #result_list ( article nvarchar(256) collate database_default, conflict_table sysname collate database_default null,  
		centralized_conflicts bit, conflict_count integer)

	create table #conflict_list ( artid sysname collate database_default, conflict_count int, sub_agent_id int )

	-- 
	-- process publisher
	--
	if exists ( select * from sysobjects where name = 'sysarticles')
	begin
		--
		-- Walk through each publication that allows queued operation
		--
		if ( @publication_name = '%' )
			declare hCPubCursor CURSOR LOCAL FAST_FORWARD fast_forward for
				select pubid, centralized_conflicts
				from syspublications
				where allow_queued_tran = 1
		else
			declare hCPubCursor CURSOR LOCAL FAST_FORWARD fast_forward for
				select pubid, centralized_conflicts
				from syspublications
				where allow_queued_tran = 1
					and name = @publication_name

		open hCPubCursor
		fetch hCPubCursor into @pubid, @centralized_conflicts
		while ( @@fetch_status != -1 )
		begin
			--
			-- Walk through each article in this publication
			--
			declare hCArtCursor CURSOR LOCAL FAST_FORWARD fast_forward for
				select a.name, b.conflict_tableid, a.artid
				from sysarticles a join
					sysarticleupdates b on
						a.artid = b.artid and
						a.pubid = b.pubid
				where a.pubid = @pubid

			open hCArtCursor
			fetch hCArtCursor into @article, @cft_tabid, @artid
			while ( @@fetch_status != -1 )
			begin
				--
				-- get the owner qualified conflict table name
				--
				select @owner = QUOTENAME(user_name(OBJECTPROPERTY(@cft_tabid, 'OwnerId')))
				select @conflict_table = @owner + N'.' + QUOTENAME(OBJECT_NAME(@cft_tabid))

				--
				-- Get all the conflict counts
				--
				select @cmd = 'select ' + cast(@artid as nvarchar(10)) +  
					', count(*) from ' + @conflict_table + 
					' where conflict_type in (1, 5, 7) and pubid = ' + 
					cast(@pubid as nvarchar(10))
				insert into #conflict_list ( artid, conflict_count )
					exec ( @cmd )

				select @conflicts_count = NULLIF(conflict_count, 0)
				from #conflict_list
				where artid = @artid
				
				if (@conflicts_count > 0)
				begin
					--
					-- add a row to the #result_list
					--
					insert into #result_list ( article, conflict_table, centralized_conflicts, conflict_count )
						select @owner + N'.' + QUOTENAME(@article), @conflict_table, @centralized_conflicts, @conflicts_count
				end
				
				--
				-- fetch next row from hCArtCursor
				--
				fetch hCArtCursor into @article, @cft_tabid, @artid
			end
			close hCArtCursor
			deallocate hCArtCursor

			--
			-- fetch next row from hCPubCursor
			--
			fetch hCPubCursor into @pubid, @centralized_conflicts	
		end
		close hCPubCursor
		deallocate hCPubCursor
	end

	--
	-- process subscriber side
	--
	delete #conflict_list
	if exists ( select * from sysobjects where name = 'MSsubscription_articles')
	begin
		--
		-- Walk through each subscription that allows queued operation
		--
		if ( @publication_name = '%' )
			declare hCPubCursor CURSOR LOCAL FAST_FORWARD fast_forward for
				select id, 0, publisher, publisher_db 
				from MSsubscription_agents 
				where update_mode in (2,3,4,5)
		else
			declare hCPubCursor CURSOR LOCAL FAST_FORWARD fast_forward for
				select id, 0, publisher, publisher_db 
				from MSsubscription_agents 
				where update_mode in (2,3,4,5)
					and publication = @publication_name

		open hCPubCursor
		fetch hCPubCursor into @pubid, @centralized_conflicts, @publisher, @publisher_db
		while ( @@fetch_status != -1 )
		begin
			--
			-- Walk through each article in this subscribed publication
			--
			declare hCArtCursor CURSOR LOCAL FAST_FORWARD fast_forward for
				select a.article, OBJECT_ID(a.cft_table), a.artid
				from MSsubscription_articles a join
					MSsubscription_agents b on
						a.agent_id = b.id
				where b.id = @pubid

			open hCArtCursor
			fetch hCArtCursor into @article, @cft_tabid, @artid
			while ( @@fetch_status != -1 )
			begin
				--
				-- get the owner qualified conflict table name
				--
				select @owner = QUOTENAME(user_name(OBJECTPROPERTY(@cft_tabid, 'OwnerId')))
				select @conflict_table = @owner + N'.' + QUOTENAME(OBJECT_NAME(@cft_tabid))

				--
				-- Get all the conflict counts
				--
				select @cmd = 'select ' + cast(@artid as nvarchar(10)) +  
					', count(*), ' + cast(@pubid as nvarchar(10)) + 
					' from ' + @conflict_table + 
					' where conflict_type in (1, 5, 7) 
						and origin_datasource = ''' + @publisher + '.' + @publisher_db + ''''
					
				insert into #conflict_list ( artid, conflict_count, sub_agent_id )
					exec ( @cmd )

				select @conflicts_count = NULLIF(conflict_count, 0)
				from #conflict_list
				where artid = @artid and sub_agent_id = @pubid
				
				if (@conflicts_count > 0)
				begin
					--
					-- add a row to the #result_list
					--
					insert into #result_list ( article, conflict_table, centralized_conflicts, conflict_count )
						select @owner + N'.' + QUOTENAME(@article), @conflict_table, @centralized_conflicts, @conflicts_count
				end
				
				--
				-- fetch next row from hCArtCursor
				--
				fetch hCArtCursor into @article, @cft_tabid, @artid
			end
			close hCArtCursor
			deallocate hCArtCursor

			--
			-- fetch next row from hCPubCursor
			--
			fetch hCPubCursor into @pubid, @centralized_conflicts, @publisher, @publisher_db	
		end
		close hCPubCursor
		deallocate hCPubCursor
	end

	--
	-- do a select for results
	--
	select 	article,
			conflict_table,
			'queued_source_proc' = @spname,
			centralized_conflicts,
			conflict_count
	from #result_list

	--
	-- all done
	--
	return (0)
end
go

exec dbo.sp_MS_marksystemobject sp_MShelptranconflictcounts
go 

/*
 * Name :       sp_MSgettranconflictrow
 * Description: This sp returns a result set containing the requested conflict row(s) 
 *    for a queued publication. Result set ordered by transaction id and 
 *    row identifier.
 * Parameters:  
 *	  1. tran_id	nvarchar(70). ('%'==ALL transactions for the article)
 *    2. row_id ( uniqueidentifer or '%'==ALL rows for a given transaction)
 *    3. conflict_table    (sysname)
 * Output Result Set has the following structure:
 *  
----------------------------------------------------------------------------------
 *      Name                Datatype                Description
 *  
----------------------------------------------------------------------------------
 * returns the current row (all columns) from conflict table with specified tran_id, (row_id)insert_date
 */
raiserror('Creating procedure sp_MSgettranconflictrow', 0,1)
GO

create procedure sp_MSgettranconflictrow ( 
	@tran_id sysname = '%',						-- % = ALL
	@row_id sysname = '%',						-- % = ALL
	@conflict_table sysname)
as 
begin
	set nocount on
	declare @cmd nvarchar(4000)
	    ,@whcmd nvarchar(4000)
            ,@retcode int

        /*
        **  Security check.  restrict to 'sysadmin' and member of db_owner role
        */ 
        exec @retcode = dbo.sp_MSreplcheck_publish
        if @@ERROR <> 0 or @retcode <> 0
            return (1)

	select @cmd = N'select * from ' + @conflict_table 
	if (@tran_id != N'%')
	begin
		if (@whcmd is null)
			select @whcmd = N'tranid = ''' + @tran_id + N''''
		else
			select @whcmd = @whcmd + N' and tranid = ''' + @tran_id + N''''		
	end
	if (@row_id != N'%')
	begin
		if (@whcmd is null)
			select @whcmd = N'qcfttabrowid = ''' + @row_id + N''''
		else
			select @whcmd = @whcmd + N' and qcfttabrowid = ''' + @row_id + N''''
	end

	if (@whcmd is not null)
	begin
		select @cmd = @cmd + N' where ' + @whcmd
	end
	
	execute (@cmd)
end
go

exec dbo.sp_MS_marksystemobject sp_MSgettranconflictrow
go

/*
 * Name :       sp_MSgettrancftsrcrow
 * Description: This sp returns a result set containing the requested source row 
 *     pertaining to a respective conflict row in conflict table (same PK/unique key)
 *     for a queued publication. Result set ordered by transaction id and row identifier
 *	   for the conflict table.
 * Parameters:  1. tran_id (nvarchar(70))
 *	  2. row_id uniqueidentifer - cannot be null
 *    3. conflict_table (nvarchar(256) - owner qualified table name - [owner].[tabname]
 *	  4. is_subscriber bit=0						-- Publisher = 0, Subscriber = 1
 * Output Result Set has the following structure:
 *  
----------------------------------------------------------------------------------
 *      Name                Datatype                Description
 *  
----------------------------------------------------------------------------------
 * returns the current row (all columns) from from source table with same PK for the row in 
 * conflict table with specified tran_id, insert_date
 */
raiserror('Creating procedure sp_MSgettrancftsrcrow', 0,1)
GO

create procedure sp_MSgettrancftsrcrow ( 
	@tran_id sysname,
	@row_id sysname,
	@conflict_table nvarchar(256),
	@is_subscriber bit,
	@is_debug bit=0 )
as 
begin
	set nocount on
	declare @decllist nvarchar(4000)
			,@sellist nvarchar(4000)
			,@wherelist nvarchar(4000)
			,@cmd nvarchar(4000)
			,@cmdrow nvarchar(4000)
			,@srctable sysname
			,@srctabid int
			,@srcowner sysname
			,@columns  binary(32)
			,@indid int
			,@indkey int
			,@key sysname
			,@this_col int
			,@col sysname
			,@typestring nvarchar(60)
			,@dbname sysname
			,@retcode smallint
			,@unqualified_cft_tab sysname
			,@startoffset int

        /*
        **  Security check.  restrict to 'sysadmin' and member of db_owner role
        */ 
        exec @retcode = dbo.sp_MSreplcheck_publish
        if @@ERROR <> 0 or @retcode <> 0
            return (1)
			
	--
	-- validate
	--
	if ((@tran_id is null) or (@row_id is null) or 
		(@conflict_table is null) or (@is_subscriber is null))
	begin
		raiserror('sp_MSgettrancftsrcrow(debug): @tran_id,@row_id,@conflict_table,@is_subscriber cannot be null', 16, 1)
		return (1)
	end

	--
	-- check if the conflict table is owner qualified
	--
	select @startoffset = charindex(N'].[', @conflict_table, 0)
	select @unqualified_cft_tab = case when (@startoffset > 0) 
		then substring(@conflict_table, @startoffset + 2, len(@conflict_table) - @startoffset - 1)
		else quotename(@conflict_table) end
		
	--
	-- get the source table info
	--
	if (@is_subscriber = 1)
	begin
		select @srcowner = owner, @srctable = dest_table, 
			@srctabid = OBJECT_ID(dest_table), @columns = columns
		from MSsubscription_articles
		where quotename(cft_table) = @unqualified_cft_tab
	end
	else
	begin
		select @srcowner = user_name(OBJECTPROPERTY(objid,'OwnerId')), @srctable = OBJECT_NAME(objid), 
			@srctabid = objid, @columns = columns
		from sysarticles a join sysarticleupdates b on
			a.pubid = b.pubid and 
			a.artid = b.artid
		where b.conflict_tableid = OBJECT_ID(@conflict_table)
	end

    --
    -- create code for the following :
    -- select the row of conflict with given tranid and insertdate
    -- retrieve the values of the PK/UI columns for the source table from this row in cft_table
    -- select all columns from source table using the values in a where clause for PK/UI
    --

    --
    -- PK/UI check for source table
    --
	exec @indid = dbo.sp_MStable_has_unique_index @srctabid
	if (@indid = 0)
	begin
		raiserror('sp_MSgettrancftsrcrow(debug):source table %s does not have unique index', 16, 1, @srctable)
		return (1)
	end

	--
	-- create temp tables
	--
    create table #decltext ( c1 int identity NOT NULL, cmdtext nvarchar(4000) collate database_default null)
    create table #seltext ( c1 int identity NOT NULL, cmdtext nvarchar(4000) collate database_default null)
    create table #wheretext ( c1 int identity NOT NULL, cmdtext nvarchar(4000) collate database_default null)

	--
	-- walk through each column in PK/UI and build parts of code
	--
	select @indkey = 1
	while (@indkey <= 16)
	begin	
		select @key = index_col(@srctable, @indid, @indkey)
		if (@key is null)
		begin
			select @indkey = 16
		end
		else
		begin
			--
			-- get the column index in the source table for this index key
			--
			exec dbo.sp_MSget_col_position @srctabid, @columns, @key, @col output, @this_col output

			--
			-- get the typestring for this column in source table
			--
			exec dbo.sp_gettypestring @srctabid, @this_col, @typestring OUTPUT

			--
			-- build command strings
			--
			if (@decllist is NULL)
				select @decllist = N'declare @' + @col + N' ' + @typestring
			else
				select @decllist = N' ,@' + @col + N' ' + @typestring
			
			if (@sellist is NULL)
				select @sellist = N'select @' + @col + N' = ' + quotename(@key)
			else
				select @sellist = N' ,@' + @col + N' = ' + quotename(@key)
				
			if (@wherelist is NULL)
				select @wherelist = N'where ' + quotename(@key) + N' = @' + @col
			else
				select @wherelist = N' and ' + quotename(@key) + N' = @' + @col

			--
			-- store them in the temp tables
			--
			insert into #decltext(cmdtext) values(@decllist)
			insert into #seltext(cmdtext) values(@sellist)
			insert into #wheretext(cmdtext) values(@wherelist)
			
		end
		select @indkey = @indkey + 1
	end

    --
    -- Now put all the code in order in the codetext
    --
    if exists (select * from sysobjects where name = 'MSsrcrow_codetext')
    	drop table MSsrcrow_codetext
    	
    create table dbo.MSsrcrow_codetext ( step int identity NOT NULL, cmdtext nvarchar(4000) NULL)

    insert into MSsrcrow_codetext(cmdtext)
    	select cmdtext from #decltext order by c1
    insert into MSsrcrow_codetext(cmdtext) values (N' ')
    insert into MSsrcrow_codetext(cmdtext)
    	select cmdtext from #seltext order by c1
    select @cmd = N' 
	from ' 

	if (@startoffset > 0)
		select @cmd = @cmd + @conflict_table
	else
		select @cmd = @cmd + quotename(@srcowner) + N'.' + @unqualified_cft_tab
		
	select @cmd = @cmd + N'
	where tranid = ''' + @tran_id + ''' and qcfttabrowid = ''' + @row_id + ''' '
    insert into MSsrcrow_codetext(cmdtext) values (@cmd)
    select @cmd = N'select * from ' + quotename(@srcowner) + N'.' + quotename(@srctable) + N' '
    insert into MSsrcrow_codetext(cmdtext) values (@cmd)
    insert into MSsrcrow_codetext(cmdtext)
    	select cmdtext from #wheretext order by c1

	--
	-- now execute the code we just built
	--
	if (@is_debug = 0)
	begin
		--
		-- Build 139:
		-- NOTE xp_execresultset should work here but does not
		-- return for a long time. Using exec() - should revisit
		-- this for more stable builds
		--
		declare #srccursor cursor local FAST_FORWARD FOR 
		select cmdtext from MSsrcrow_codetext order by step 
		FOR READ ONLY

		select @cmd = N' '
		select @dbname = db_name()
		open #srccursor
		fetch #srccursor into @cmdrow
		while (@@FETCH_STATUS = 0)
		begin
			select @cmd = @cmd + @cmdrow
			fetch #srccursor into @cmdrow	
		end		
		close #srccursor
		deallocate #srccursor
		
		execute(@cmd)
		if (@@error != 0)
		begin
			raiserror('sp_MSgettrancftsrcrow(debug): execute() failed for [%s] in db [%s] ', 16, 1, @cmd, @dbname)
			return (1)
		end

	end
	else
		select cmdtext from MSsrcrow_codetext order by step 

	--
	-- all done
	--
	drop table MSsrcrow_codetext
	return 0
end
go

exec dbo.sp_MS_marksystemobject sp_MSgettrancftsrcrow
go

/*
 * Name :       sp_MSdeletetranconflictrow
 * Description: This sp deletes the requested conflict row(s) for a queued publication. 
 *    Can delete all conflicts in a transaction by specifying only tran_id.
 * Parameters:  1. tran_id	(nvarchar(70))
 *    2. row_id ( uniqueidentifier or '%'==ALL conflicts for a given transaction)
 * Output  None.
 *  
----------------------------------------------------------------------------------
 *      Name                Datatype                Description
 *  
----------------------------------------------------------------------------------
 */ 
raiserror('Creating procedure sp_MSdeletetranconflictrow', 0,1)
GO

create procedure sp_MSdeletetranconflictrow ( 
	@tran_id sysname,
	@row_id sysname = '%',						-- % = ALL
	@conflict_table sysname)
as 
begin
	set nocount on
	declare @cmd nvarchar(4000),
            @retcode int

        /*
        **  Security check.  restrict to 'sysadmin' and member of db_owner role
        */ 
        exec @retcode = dbo.sp_MSreplcheck_publish
        if @@ERROR <> 0 or @retcode <> 0
            return (1)

	if (@conflict_table is NULL)
	begin
		raiserror('sp_MSdeletetranconflictrow(debug) - @conflict_table cannot be null', 16, 1)
		return (1)
	end

	select @cmd = 'delete ' + @conflict_table +
		' where tranid = ''' + @tran_id + ''''

	if (@row_id != N'%')
	begin
		select @cmd = @cmd +
		' and qcfttabrowid = ''' + @row_id + ''''
	end
	
	execute (@cmd)
end
go

exec dbo.sp_MS_marksystemobject sp_MSdeletetranconflictrow
go


raiserror('Creating procedure sp_MSexternalfkreferences', 0,1)
go

create procedure sp_MSexternalfkreferences
    @publication sysname,
    @article     sysname
as
    declare @pubid int
    declare @objid int
    declare @retcode int

    exec @retcode = dbo.sp_MSreplcheck_publish
    if @@ERROR <> 0 or @retcode <> 0
        return (1)

    select @pubid = pubid from dbo.syspublications where name = @publication
    select @objid = objid from dbo.sysarticles where pubid = @pubid and name = @article

    select rkeyid, fkeyid from dbo.sysreferences
        where fkeyid = @objid
          and rkeyid not in (select objid from dbo.sysarticles where pubid = @pubid)      
go
exec dbo.sp_MS_marksystemobject sp_MSexternalfkreferences
go

--
-- Name: sp_MSgetarticlereinitvalue
--
-- Description: This proc is called by sync/queued tran generated article procs
-- to get the reinitialization status of a subscription for a given article
--
-- Parameter: Refer to the comments in the create procedure statement
--
-- Returns: 1 or 0   0 = success
--
-- Security: Public procedure - does PAL security check. 
--
raiserror('Creating procedure sp_MSgetarticlereinitvalue', 0,1)
go
create procedure sp_MSgetarticlereinitvalue (
	@subscriber 			sysname,
	@subscriberdb 		sysname,
	@artid	 			int, 
	@reinit		 		int output
)
as
begin
	set NOCOUNT ON
	declare @orig_srvid int
		,@retcode int
		,@publication sysname

	--
	-- PAL security check
	-- Get publication name using artid
	--
	select @publication = p.name
	from syspublications p join sysarticles a on p.pubid = a.pubid
	where a.artid = @artid
	if (@publication is null)
	begin
		return 1
	end
	exec @retcode = dbo.sp_MSreplcheck_pull @publication = @publication
	if @@error <> 0 or @retcode <> 0
	begin
		return (1)
	end
	--
	-- get the value of reinit flag
	--
	select @orig_srvid = srvid from master.dbo.sysservers where UPPER(srvname) = UPPER(@subscriber) collate database_default
	select @reinit = queued_reinit 
	from syssubscriptions 
	where 
		artid = @artid 
		and srvid = @orig_srvid
		and dest_db = @subscriberdb

	-- All done
	return 0
end
go

exec dbo.sp_MS_marksystemobject sp_MSgetarticlereinitvalue
go

--
-- Name: sp_MSispkupdateinconflict
--
-- Description: This procedure is be used by queued tran UPDATE conflict resolution SPs. It
-- takes as input a given article and the update bitmask and decides if 
-- PRIMARY KEY update is taking place returns the following return codes
--
-- Parameter: as defined below
--
-- Returns: 1 or 0, -1
--	-1 : Error in execution
-- 	 0 : Not a PK update
--	 1 : PK update
--
-- Security: Public procedure - publish security check inside. 
--
raiserror('Creating procedure sp_MSispkupdateinconflict', 0,1)
go
create proc sp_MSispkupdateinconflict (
	@pubid int
	,@artid int
	,@bitmap varbinary(4000)
)
as
begin
	declare @retcode int
		,@columns binary(32)
		,@tabname sysname
		,@tabid int
		,@indid int
		,@indkey int
		,@key sysname
		,@colid int
		,@isset int
		,@artcol int
		,@bytepos int
		,@bitpos int

	--
	-- security check
	--
	exec @retcode = dbo.sp_MSreplcheck_publish
	if @@ERROR != 0 or @retcode != 0
		return -1
	--
	-- initalize and validate
	--
	select @columns = [columns]
		,@tabid = objid
		,@indkey = 1
		,@artcol = 0
	from dbo.sysarticles
	where (artid = @artid) and (pubid = @pubid)

	if (@tabid is null)
	begin
		raiserror('sp_MSispkupdateinconflict(Debug): invalid pub and article id : %s.%s', 
				16, -1, @pubid, @artid)
		return -1
	end
	
	select @tabname = QUOTENAME(user_name(OBJECTPROPERTY(@tabid, 'OwnerId'))) collate database_default 
			+ N'.' + QUOTENAME(object_name( @tabid )) collate database_default

	--
	-- get the Primary Key Index
	--
	select @indid = i.indid 
	from dbo.sysindexes i 
	where ((i.status & 2048) != 0) and (i.id = @tabid)
	if (@indid is null)
	begin
		raiserror('sp_MSispkupdateinconflict(Debug): Cannot find primary key for %s', 
				16, -1, @tabname)
		return -1
	end
	
	--
	-- create an enumeration of all the columns that are part of PK
	--
	create table #pkcoltab(pkindex int identity, keyname sysname collate database_default not null)
	while (@indkey <= 16)
	begin
		select @key = index_col( @tabname, @indid, @indkey )
		if (@key is null)
			break
		else
			insert into #pkcoltab(keyname) values(@key)

		select @indkey = @indkey + 1
	end

	--
	-- now walk through each article col and if it is
	-- a part of PK, then check if the update bitmap bit 
	-- corresponding to any article column is set
	--
	DECLARE #hCColid CURSOR LOCAL FAST_FORWARD FOR 
		select colid, [name] from dbo.syscolumns 
		where id = @tabid order by colid asc

	OPEN #hCColid
	FETCH #hCColid INTO @colid, @key
	WHILE (@@fetch_status != -1)
	begin
		exec @isset = dbo.sp_isarticlecolbitset @colid, @columns
		if (@isset != 0)
		begin
			--
			-- this column is part of the article
			--
			select @artcol = @artcol + 1
			if exists (select * from #pkcoltab where keyname = @key)
			begin
				--
				-- this column is part of PK
				--
				select 	@bytepos = 1 + (@artcol-1) / 8 
					,@bitpos = power(2, (@artcol-1) % 8 )

				--
				-- if the update bitmap has bit set then
				-- then it is a PK update
				--
				if ((substring(@bitmap, @bytepos, 1) & @bitpos) = @bitpos)
					return 1
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
	-- if we have reached here then it mean the update does not
	-- affect PK columns, cleanup and return
	--
	return 0
end
go

EXEC dbo.sp_MS_marksystemobject sp_MSispkupdateinconflict
GO

--
-- Name: sp_MSisnonpkukupdateinconflict
--
-- Description: This procedure is by queued updating syctran procedures
-- to check if non PK unique index keys were updated in a given queued
-- UPDATE command
--
-- Parameter: as defined below
--
-- Returns: 1 or 0, -1
-- 1 = non PK unique key column(s) was(were) updated
-- 0 = non PK unique key column was not updated
-- -1 = processing error
--
-- Security: Public procedure - publish security check inside. 
--
raiserror('Creating procedure sp_MSisnonpkukupdateinconflict', 0,1)
go
create proc sp_MSisnonpkukupdateinconflict (
	@pubid int
	,@artid int
	,@bitmap varbinary(4000)
)
as
begin
	declare @retcode int
		,@columns binary(32)
		,@tabname sysname
		,@tabid int
		,@indid int
		,@indkey int
		,@key sysname
		,@colid int
		,@isset int
		,@artcol int
		,@bytepos int
		,@bitpos int
	declare @ukcoltab table(ukindex int identity, keyname sysname collate database_default not null)

	--
	-- security check
	--
	exec @retcode = dbo.sp_MSreplcheck_publish
	if @@ERROR != 0 or @retcode != 0
		return -1
	--
	-- initalize and validate
	--
	select @columns = [columns]
		,@tabid = objid
		,@artcol = 0
	from dbo.sysarticles
	where (artid = @artid) and (pubid = @pubid)
	--
	-- validate article
	--
	if (@tabid is null)
	begin
		raiserror(21344, 16, -1, '@pubid, @artid')
		return -1
	end
	--
	-- the table should have non PK unique keys
	--
	exec @retcode = dbo.sp_repltablehasnonpkuniquekey @tabid
	if (@retcode != 1)
	begin
		return 0
	end
	--
	-- get fully qualified table
	--
	select @tabname = QUOTENAME(user_name(OBJECTPROPERTY(@tabid, 'OwnerId'))) collate database_default 
			+ N'.' + QUOTENAME(object_name( @tabid )) collate database_default

	--
	-- get the non PK unique indices
	--
	declare #hcindid cursor local fast_forward for
		select indid from sysindexes 
		where id = @tabid 
			and (status & 2) != 0
			and (status & 2048) = 0
			and indid > 0 and indid < 255
		order by indid asc
	open #hcindid
	fetch #hcindid into @indid
	while (@@fetch_status != -1)
	begin
		--
		-- create an enumeration of all the columns 
		-- that are part of selected unique index
		--
		select @indkey = 1
		while (@indkey <= 16)
		begin
			select @key = index_col( @tabname, @indid, @indkey )
			if (@key is null)
				break
			else
			begin
				if not exists (select * from @ukcoltab where keyname = @key)
					insert into @ukcoltab(keyname) values(@key)
			end
			select @indkey = @indkey + 1
		end
		--
		-- fetch next index
		--
		fetch #hcindid into @indid
	end
	close #hcindid
	deallocate #hcindid
	--
	-- now walk through each article col and if it is
	-- a part of any of the unique keys, then check if the update bitmap bit 
	-- corresponding to any article column is set
	--
	declare #hccolid cursor local fast_forward for
		select colid, [name] from dbo.syscolumns 
		where id = @tabid order by colid asc

	open #hccolid
	fetch #hccolid INTO @colid, @key
	while (@@fetch_status != -1)
	begin
		exec @isset = dbo.sp_isarticlecolbitset @colid, @columns
		if (@isset != 0)
		begin
			--
			-- this column is part of the article
			--
			select @artcol = @artcol + 1
			if exists (select * from @ukcoltab where keyname = @key)
			begin
				--
				-- this column is part of an unique key
				--
				select @bytepos = 1 + (@artcol-1) / 8 
					,@bitpos = power(2, (@artcol-1) % 8 )
				--
				-- if the update bitmap has bit set then
				-- then it is a nonPK key update
				--
				if ((substring(@bitmap, @bytepos, 1) & @bitpos) = @bitpos)
					return 1
			end
		end		
		--
		-- get the next column
		--
		fetch #hccolid INTO @colid, @key
	end
	close #hccolid
	deallocate #hccolid
	--
	-- if we have reached here then it mean the update does not
	-- affect PK columns, cleanup and return
	--
	return 0
end
go
exec dbo.sp_MS_marksystemobject sp_MSisnonpkukupdateinconflict
go

--
-- sp_ivindexhasnullcols
--
-- Proc to validate a indexed view - prior to enabling a indexed view
-- ,this proc is used to make sure the I.V. clustered index is unique
-- and does contain any column that can be NULL
-- 
-- Parameters:
--
--	@viewname sysname 		name of the view
--	,@fhasnullcols bit 		value of 1 if view index has columns that allow NULL
--							value of 0 otherwise (returns 0 if error in execution)
--
-- Returns:
-- 		0 if success
--		1 if failure
--
create proc sp_ivindexhasnullcols (
	@viewname sysname
	,@fhasnullcols bit OUTPUT
)
as
begin
	declare	@f_ind_unique bit
			,@f_ind_clustered bit
			,@ivobject_id int
			,@indkey int
			,@key sysname

	--
	-- validate view object
	--
	select @ivobject_id = object_id(@viewname)
			,@fhasnullcols = 0
			
	if (@ivobject_id IS NULL or @ivobject_id = 0)
	begin
		raiserror('sp_ivindexhasnullcols(debug): invalid view object [%s]', 16, 1, @viewname)
		return 1
	end

	--
	-- get the clustered index and validate
	--
	select @f_ind_unique = case (status & 2) when 0 then 0 else 1 end
			,@f_ind_clustered = case (status & 16) when 0 then 0 else 1 end 
	from dbo.sysindexes
	where id = @ivobject_id and indid = 1
	
	if (@f_ind_unique != 1) or (@f_ind_clustered != 1)
	begin
		raiserror('sp_ivindexhasnullcols(debug): cannot find unique clustered index for the view [%s]', 16, 1, @viewname)
		return 1
	end
	
	--
	-- create an enumeration of all the columns that are part of the view index
	--
	create table #indcoltab(vindexcol int identity, keyname sysname collate database_default not null)
	select @indkey = 1
	while (@indkey <= 16)
	begin
		select @key = index_col( @viewname, 1, @indkey )
		if (@key is null)
			break
		else
			insert into #indcoltab(keyname) values(@key)

		select @indkey = @indkey + 1
	end

	--
	-- We should not have any column participating in this index
	-- that allows NULL if we do
	-- mark the output flag to TRUE
	--
	if exists (select * 
		from dbo.syscolumns 
		where id = @ivobject_id 
			and isnullable = 1
			and name in (select keyname from #indcoltab))
	begin
		select @fhasnullcols = 1
	end

	--
	-- all done, cleanup and return
	--
	drop table #indcoltab
	return 0
end
go

EXEC dbo.sp_MS_marksystemobject sp_ivindexhasnullcols
GO


--
-- fn_sqlvarbasetostr
--
-- UDF to generate string from a given sqlvariant using its base type.
-- This function is used by compensating commands and use special rules
-- for generating strings :
-- For datatypes - varchar, nvarchar, char, nchar, uniqueidenfier, 
-- datetime, smalldatetime, invalid date : The value is quoted with single
-- quotes and any embedded quotes are prefixed with single quote
-- For other datatypes - The value is not quoted
-- 
-- Parameters:
--	@ssvar sql_variant 		input sqlvariant parameter (could be NULL)
--
-- Returns:
-- 	nvarchar(4000) NULL		generated string. Is NULL if input is NULL
--
create function dbo.fn_sqlvarbasetostr (
	@ssvar sql_variant
)
returns nvarchar(4000)
as
begin
	declare @pstrout nvarchar(4000)
			,@basetype sysname

	select @basetype = CAST(SQL_VARIANT_PROPERTY ( @ssvar, 'BaseType' ) as nvarchar(255))
	if (@ssvar IS NOT NULL and @basetype IS NOT NULL)
	begin
		if (lower(@basetype collate SQL_Latin1_General_CP1_CS_AS) = 'varchar')
			select @pstrout = N'''' + REPLACE(CAST(@ssvar as nvarchar(4000)), '''', '''''') + N''''
		else if (lower(@basetype collate SQL_Latin1_General_CP1_CS_AS) = 'nvarchar')
			select @pstrout = N'N''' + REPLACE(CAST(@ssvar as nvarchar(4000)), '''', '''''') + N''''
		else if (lower(@basetype collate SQL_Latin1_General_CP1_CS_AS) = 'char')
			select @pstrout = N'''' + REPLACE(RTRIM(CAST(@ssvar as nvarchar(4000))), '''', '''''') + N''''
		else if (lower(@basetype collate SQL_Latin1_General_CP1_CS_AS) = 'nchar')
			select @pstrout = N'N''' + REPLACE(RTRIM(CAST(@ssvar as nvarchar(4000))), '''', '''''') + N''''
		else if (lower(@basetype collate SQL_Latin1_General_CP1_CS_AS) in ('binary','varbinary'))
			select @pstrout = master.dbo.fn_varbintohexsubstring(1, CAST(@ssvar as varbinary(8000)), 1, 0)
		else if (lower(@basetype collate SQL_Latin1_General_CP1_CS_AS) in ('bit','bigint','int','smallint','tinyint','decimal','numeric'))
			select @pstrout = CAST(@ssvar as nvarchar(40))
		else if (lower(@basetype collate SQL_Latin1_General_CP1_CS_AS) in ('float','real'))
			select @pstrout = CONVERT(nvarchar(60), @ssvar, 2)
		else if (lower(@basetype collate SQL_Latin1_General_CP1_CS_AS) in ('money','smallmoney'))
			select @pstrout = CONVERT(nvarchar(40), @ssvar, 2)
		else if (lower(@basetype collate SQL_Latin1_General_CP1_CS_AS) = 'uniqueidentifier')
			select @pstrout = N'''' + CAST(@ssvar as nvarchar(40)) + N''''
		else if (lower(@basetype collate SQL_Latin1_General_CP1_CS_AS) in ('datetime','smalldatetime'))
			select @pstrout = N'''' + CONVERT(nvarchar(40), @ssvar, 112) + N' ' + CONVERT(nvarchar(40), @ssvar, 114) + N''''
		else
			select @pstrout = N'''Invalid Datatype' + lower(@basetype collate SQL_Latin1_General_CP1_CS_AS) + N'(' + CAST(@ssvar as nvarchar) + N')'''
	end

	-- All done
	return @pstrout
end
go
exec dbo.sp_MS_marksystemobject fn_sqlvarbasetostr
go

--
-- sp_replqueuemonitor
--
-- Description: this stored procedure displays the messages stored in the 
--  	queue for a given subscription to a queued publication
--
-- Parameters:  
--    1. publisher (sysname, NULL for all publishers)
--    2. publisherdb (sysname, NULL for all publisherdbs)
--    3. publication (sysname , NULL for all publications)
--    4. tranid ( nvarchar(70) NULL for all transactions)
--	  5. queuetype (tinyint 0 for all types of queues, 1 for MSMQ, 2 for SQL)
--
-- Results:
--  Rows of Messages stored in the queue (all types) in the following format:
--	publisher 		sysname,
--	publisher_db 	sysname,
--	publication 	sysname,
--	tranid 			sysname,
--	commandlen 		int,
--	command 		nvarchar(4000)
-- The command is truncated (less than 4000 characters) if
--	1. The total rowsize exceeds the maximum of 8060 bytes
--	2. The SQL command spans multiple queue messages
-- The queue messages that do not contain SQL command or are part of a spanning
-- SQL command are not displayed
--
-- Returns:
-- 		0 if success
--		1 if failure
--
raiserror('Creating procedure sp_replqueuemonitor', 0,1)
go
create proc sp_replqueuemonitor (
	@publisher 		sysname = NULL
	,@publisherdb 	sysname = NULL
	,@publication 	sysname = NULL
	,@tranid		 	sysname = NULL
	,@queuetype		tinyint = 0	-- 0 = All Queues, 1 = MSMQ, 2 = SQL
)
as
begin
	set nocount on
	declare @retcode int
			,@queue_server sysname
			,@queue_id sysname
			,@data varbinary(8000)
			,@datalen int
			,@commandtype int
			,@cmdstate bit
			,@mesglen int
			,@command nvarchar(4000)
			,@partialindex int
			,@rowlen int
			,@comandlen int

	declare	@k_mesg_partial_state bit
			,@k_mesg_complete_state bit
			,@k_mesg_tran_cmd int
			,@k_max_rowlen int
			,@k_queuetype_all tinyint
			,@k_queuetype_msmq tinyint
			,@k_queuetype_sql tinyint

	create table #mesgs (mesgid int identity PRIMARY KEY, queuetype tinyint default 1, publisher sysname collate database_default, publisher_db sysname collate database_default, publication sysname collate database_default, 
							tranid sysname collate database_default, commandlen int, command ntext)

	--
	-- Check if need to look for subscriptions
	--
	if exists (select * from dbo.sysobjects where name = 'MSsubscription_agents')
	begin
		--
		-- Are there any qualifying subscriptions
		--
		if exists (select * from dbo.MSsubscription_agents where
				publisher = case when @publisher is NULL then publisher else UPPER(@publisher) end AND
				publisher_db = case when @publisherdb is NULL then publisher_db else @publisherdb end AND
				publication = case when @publication is NULL then publication else @publication end )
		begin
			--
			-- initialize
			--
			select 	@k_queuetype_all = 0
					,@k_queuetype_msmq = 1
					,@k_queuetype_sql = 2
					
			--
			-- MSMQ based
			--
			if (@queuetype in (@k_queuetype_all, @k_queuetype_msmq) and
				exists (select * from dbo.MSsubscription_agents where
					publisher = case when @publisher is NULL then publisher else UPPER(@publisher) end AND
					publisher_db = case when @publisherdb is NULL then publisher_db else @publisherdb end AND
					publication = case when @publication is NULL then publication else @publication end  AND
					update_mode IN (2,3) AND
					substring(queue_id, 1, 10) != N'mssqlqueue'))
			begin
				--
				-- enumerate each queue
				--
				create table #queues (publisher sysname collate database_default, publisher_db sysname collate database_default, publication sysname collate database_default, queue_id sysname collate database_default)
				declare #htempcursor cursor local for
					select publisher, publisher_db, publication, queue_server, queue_id 
					from dbo.MSsubscription_agents 
					where
						publisher = case when @publisher is NULL then publisher else UPPER(@publisher) end AND
						publisher_db = case when @publisherdb is NULL then publisher_db else @publisherdb end AND
						publication = case when @publication is NULL then publication else @publication end  AND
						update_mode IN (2,3) AND
						substring(queue_id, 1, 10) != N'mssqlqueue'

				open #htempcursor
				fetch #htempcursor into @publisher, @publisherdb, @publication, @queue_server, @queue_id
				while (@@fetch_status = 0)
				begin
					--
					-- add the queue server prefix
					--
					select @queue_id = N'DIRECT=OS:' + @queue_server + N'\PRIVATE$\' + @queue_id
					
					--
					-- Display all the messages in this queue
					--
					insert into #mesgs (publisher, publisher_db, publication, tranid, commandlen, command)
						exec @retcode = master.dbo.xp_displayqueuemesgs @publisher, @publisherdb, @publication, @queue_id, @tranid
					if (@retcode != 0 or @@error != 0)
						return 1

					--
					-- fetch next row
					--
					fetch #htempcursor into @publisher, @publisherdb, @publication, @queue_server, @queue_id
				end
				close #htempcursor
				deallocate #htempcursor
	
				--
				-- All MSMQ Queues processed
				--
				drop table #queues
			end
			
			--
			-- SQL Queued based
			--
			if (@queuetype in (@k_queuetype_all, @k_queuetype_sql) and
				exists (select * from dbo.MSsubscription_agents where
					publisher = case when @publisher is NULL then publisher else UPPER(@publisher) end AND
					publisher_db = case when @publisherdb is NULL then publisher_db else @publisherdb end AND
					publication = case when @publication is NULL then publication else @publication end  AND
					update_mode IN (4,5) AND
					substring(queue_id, 1, 10) = N'mssqlqueue'))
			begin
				--
				-- check if we have a queue
				--
				if exists (select * from dbo.sysobjects where name = 'MSreplication_queue')
				begin
					--
					-- initialize
					--
					select @mesglen = 0
							,@partialindex = 0
							,@k_mesg_partial_state = 1
							,@k_mesg_complete_state = 0
							,@k_mesg_tran_cmd = 1
							,@k_max_rowlen = 8000
					
					--
					-- select the messages that qualify
					--
											
					declare #htempcursor cursor local for
						select publisher, publisher_db, publication, tranid, datalen, data, commandtype, cmdstate
						from dbo.MSreplication_queue 
						where
							publisher = case when @publisher is NULL then publisher else UPPER(@publisher) end AND
							publisher_db = case when @publisherdb is NULL then publisher_db else @publisherdb end AND
							publication = case when @publication is NULL then publication else @publication end  AND
							tranid = case when @tranid IS NULL then tranid else @tranid end
					open #htempcursor
					fetch #htempcursor into @publisher, @publisherdb, @publication, @tranid, @datalen, @data, @commandtype, @cmdstate
					while (@@fetch_status = 0)
					begin
						--
						-- check the message state
						--
						if (@cmdstate = @k_mesg_partial_state)
							select @partialindex = @partialindex + 1
						select @mesglen = @mesglen + @datalen

						--
						-- process the body only for command type messages
						-- and if the command spans multiple rows, then
						-- display only the first row
						--
						if ((@commandtype = @k_mesg_tran_cmd) and
							((@cmdstate = @k_mesg_complete_state and @partialindex = 0) or
							(@cmdstate = @k_mesg_partial_state and @partialindex = 1)))
						begin
							--
							-- decode the command
							--
							exec @retcode = master.dbo.xp_decodequeuecmd @data, @command OUTPUT
							if (@retcode != 0 or @@error != 0)
								return 1
						end
						
						--
						-- Are processing the final row for this command
						--
						if (@cmdstate = @k_mesg_complete_state)
						begin
							--
							-- reset partial index
							--
							if (@partialindex > 0)
								select @partialindex = 0

							if (@command IS NOT NULL)
							begin
								--
								-- check if the command needs to truncated to fit the max rowsize
								--
								select @rowlen = 4 + DATALENGTH(@k_queuetype_sql) + 
												 DATALENGTH(@publisher) + DATALENGTH(@publisherdb) +
												 DATALENGTH(@publication) + DATALENGTH(@tranid) + 
												 DATALENGTH(@mesglen)
										,@comandlen = DATALENGTH(@command)
								if (@rowlen + @comandlen > @k_max_rowlen)
								begin
									select @comandlen = @k_max_rowlen - @rowlen
									select @comandlen = @comandlen / 2
									select @command = SUBSTRING(@command, 1, @comandlen)
								end
								
								insert into #mesgs (queuetype, publisher, publisher_db, publication, tranid, commandlen, command)
								values (@k_queuetype_sql, @publisher, @publisherdb, @publication, @tranid, @mesglen, @command)
								if (@retcode != 0 or @@error != 0)
									return 1

								select @command = NULL
							end

							--
							-- reset command len
							--
							if (@mesglen > 0)
								select @mesglen = 0
						end
						
						--
						-- fetch next row
						--
						fetch #htempcursor into @publisher, @publisherdb, @publication, @tranid, @datalen, @data, @commandtype, @cmdstate
					end
					close #htempcursor
					deallocate #htempcursor
				end 
	
				--
				-- All SQL Queues processed
				--
			end
		end
	end
	
	--
	-- return result
	--
	select 	queue = case when queuetype = @k_queuetype_msmq then N'MSMQ'
						when queuetype = @k_queuetype_sql then N'SQLQ' end 
			,publisher
			,publisher_db
			,publication
			,tranid
			,commandlen
			,command 
	from #mesgs
	order by mesgid
	
	--
	-- All done
	--
	drop table #mesgs
	return 0
end
go
exec dbo.sp_MS_marksystemobject sp_replqueuemonitor
go

--
-- sp_replsqlqgetrows
--
-- Description: this stored procedure returns the queued data stored in the 
-- 	MSreplication_queue for a specific subscription to a queued publication.
--	This SP is used by Queue Reader Agent to service SQL based Queues.
--
-- Parameters:  
--    1. publisher 		(sysname, NOT NULL)
--    2. publisherdb 	(sysname, NOT NULL)
--    3. publication 	(sysname, NOT NULL)
--
-- Results:
--  Rows of Queued Data stored in MSreplication_queue in the following format:
--	tranid				sysname
--	datalen				int
--	data				image
--	commandtype			int
--	insertdate			datetime
--	orderkey			bigint
--	cmdstate			bit
--
-- Returns:
-- 		0 if success
--		1 if failure
--
-- Security: Public procedure - does subscribe security check. 
--
raiserror('Creating procedure sp_replsqlqgetrows', 0,1)
go
create proc sp_replsqlqgetrows 
(
	@publisher sysname
	,@publisherdb sysname
	,@publication sysname
	,@batchsize int = 1000
)
as
begin
	declare @retcode int
	set nocount on
	--
	-- Security check
	--
	exec @retcode = dbo.sp_MSreplcheck_subscribe
	if @@error != 0 or @retcode != 0
		return 1
	--
	-- does the queue table exist
	--
	if exists (select * from dbo.sysobjects where name = 'MSreplication_queue')
	begin
		declare @totcommandcount bigint
				,@trancount bigint
		--
		-- does the tran info table exist
		--
		if not exists (select * from dbo.sysobjects where name = 'MSrepl_queuedtraninfo')
		begin
			--
			-- tran info table does not exist - create and populate it
			--
			exec @retcode = sp_MScreate_sub_tables
				@tran_sub_table = 0,
				@property_table = 0,
				@sqlqueue_table = 1
			if  (@@error != 0 or @retcode != 0)
				return 1
		end	
		--
		-- At this point both queue table and tran info table exist
		-- check the command count
		--
		select @totcommandcount = sum(commandcount)
			,@trancount = count(tranid)
		from dbo.MSrepl_queuedtraninfo with (READPAST)
		where publisher = UPPER(@publisher)
			and publisher_db = @publisherdb 
			and publication = @publication

		if (@trancount > 1 and @totcommandcount > @batchsize)
		begin
			--
			-- prepare a list of transactions to read
			--
			declare @tranid sysname
					,@batchcount bigint
					,@curtrancommandcount bigint
			declare @trantab table (tranid sysname primary key)

			select @batchcount = 0
			declare #htcdataseq cursor local for
				select tranid, commandcount
				from dbo.MSrepl_queuedtraninfo with (READPAST) 
				where publisher = UPPER(@publisher) 
					and publisher_db = @publisherdb 
					and publication = @publication
				order by maxorderkey asc
			open #htcdataseq
			fetch #htcdataseq into @tranid, @curtrancommandcount
			if (@@error != 0)
				return 1
			while (@@fetch_status != -1)
			begin
				--
				-- Are we done
				--
				if (@batchcount > @batchsize)
				begin
					--
					-- we are done selecting the transactions to process
					--
					break
				end
				else
				begin
					--
					-- include this transaction
					-- update the batch counter
					--
					insert into @trantab (tranid) values (@tranid)
					if (@@error != 0)
						return 1
					select @batchcount = @batchcount + @curtrancommandcount
				end
				--
				-- fetch next transaction to process
				--
				fetch #htcdataseq into @tranid, @curtrancommandcount
			end
			close #htcdataseq
			deallocate #htcdataseq
			if (@@error != 0)
				return 1
			--
			-- do the join for the select transactions
			-- select the transactions in the order they were committed (maxorderkey ascending).
			-- for each transaction - the commands are ordered using orderkey (ascending)
			--
			select q.tranid, q.datalen, q.data, q.commandtype, q.insertdate, q.orderkey, q.cmdstate 
			from (dbo.MSreplication_queue as q with (READPAST) 
				join (dbo.MSrepl_queuedtraninfo as t with (READPAST)
					join @trantab as tt
					on t.tranid = tt.tranid collate database_default) 
				on q.publisher = t.publisher
					and q.publisher_db = t.publisher_db 
					and q.publication = t.publication
					and q.tranid = t.tranid)
			where t.publisher = UPPER(@publisher)
				and t.publisher_db = @publisherdb 
				and t.publication = @publication
			order by t.maxorderkey asc, q.orderkey asc
		end
		else
		begin
			--
			-- do the join for all the transactions
			-- select the transactions in the order they were committed (maxorderkey ascending).
			-- for each transaction - the commands are ordered using orderkey (ascending)
			--
			select q.tranid, q.datalen, q.data, q.commandtype, q.insertdate, q.orderkey, q.cmdstate 
			from (dbo.MSreplication_queue as q with (READPAST) 
				join dbo.MSrepl_queuedtraninfo as t with (READPAST)
				on q.publisher = t.publisher
					and q.publisher_db = t.publisher_db 
					and q.publication = t.publication
					and q.tranid = t.tranid)
			where t.publisher = UPPER(@publisher)
				and t.publisher_db = @publisherdb 
				and t.publication = @publication
			order by t.maxorderkey asc, q.orderkey asc
		end
	end
	else
	begin
		--
		-- Queue table does not exist
		-- create empty rowset
		--
		declare @nomesgs TABLE (tranid sysname, datalen int, data varbinary(8000),
			commandtype int, insertdate datetime, orderkey bigint, cmdstate bit)
		select * from @nomesgs
	end	
	--
	-- check error
	--
	if (@@error != 0)
		return 1
	--
	-- All done
	--
	return 0
end
go
exec dbo.sp_MS_marksystemobject sp_replsqlqgetrows
go

--
-- sp_repldeletequeuedtran
--
-- Owner: KaushikC
--
-- Description: this stored procedure is invoked on subscriber by queue reader
-- agent and deletes a transaction from MSreplication_queue. It also removes
-- the entry from MSrepl_queuedtraninfo 
--
-- Parameters:  
--  Look at the create procedure definition
--
-- Returns:
--      0 if success
--      1 if failure
--
-- Security : Public access. Internal check for subscribe access
--
raiserror('Creating procedure sp_repldeletequeuedtran', 0,1)
go
create proc sp_repldeletequeuedtran 
(
    @publisher sysname
    ,@publisher_db sysname
    ,@publication sysname
    ,@tranid sysname
    ,@orderkeylow bigint
    ,@orderkeyhigh bigint
)
as
begin
    declare @retcode int
    set nocount on
    --
    -- Security check
    --
    exec @retcode = dbo.sp_MSreplcheck_subscribe
    if @@error != 0 or @retcode != 0
        return 1
    --
    -- validate inputs
    --
    if (@tranid is null 
            or @orderkeylow is null or @orderkeylow = 0 
            or @orderkeyhigh is null or @orderkeyhigh = 0
            or @orderkeyhigh < @orderkeylow)
        return 1
    --
    -- begin local transaction
    --
    begin transaction sp_repldeletequeuedtran
    save transaction sp_repldeletequeuedtran
    --
    -- delete rows from MSreplication_queue
    --
    delete dbo.MSreplication_queue with (rowlock)
    where publisher = UPPER(@publisher)
        and publisher_db = @publisher_db
        and publication = @publication
        and tranid = @tranid 
        and orderkey between @orderkeylow and @orderkeyhigh
    if (@@error != 0)
        goto Error
    --
    -- delete row from MSrepl_queuedtraninfo
    --
    delete dbo.MSrepl_queuedtraninfo with (rowlock)
    where publisher = UPPER(@publisher)
        and publisher_db = @publisher_db
        and publication = @publication
        and tranid = @tranid 
    if (@@error != 0)
        goto Error
    --
    -- commit local transaction
    --
    commit transaction sp_repldeletequeuedtran
    --
    -- all done
    --
    return 0

Error:
    rollback transaction sp_repldeletequeuedtran
    commit transaction
    return 1
end
go
exec dbo.sp_MS_marksystemobject sp_repldeletequeuedtran
go

--
-- sp_MSpost_auto_proc
--
-- Description: Helper store proc, used by schema replication.
--		Scripts out custom proc generation code and post to the log.
--
-- Returns:
-- 		0 if success
--		1 if failure
--
raiserror('Creating procedure sp_MSpost_auto_proc', 0,1)
go
create proc sp_MSpost_auto_proc 
		@pubid int, 
		@artid int, 
		@procname nvarchar(128)
as
begin
	declare @proctext nvarchar(4000)
	declare @retcode int
	
	set nocount on
	select @retcode = 0
	
    /*
    ** Security Check
    */
    exec @retcode = dbo.sp_MSreplcheck_publish
    if @@ERROR <> 0 or @retcode <> 0
        return(1)

	-- save the geneartion code
	create table #temptext (colidx int identity, col nvarchar(4000) collate database_default)
	insert #temptext (col) exec @procname @artid
	
	-- post to the log
	declare #trancolumn CURSOR LOCAL FAST_FORWARD for 
		select col from #temptext order by colidx
	open #trancolumn
	fetch #trancolumn into @proctext
	while (@@fetch_status <> -1)
	BEGIN
		if(@proctext = N'go') -- post the drop as one command
		begin
			exec @retcode = sp_replpostcmd 0, @pubid, @artid, 35, N' -- '
			if(@retcode <> 0) or (@@error <> 0)
				return 1
		end
		else
		begin
			select @proctext = @proctext + N' '
			exec @retcode = sp_replpostcmd 1, @pubid, @artid, 35, @proctext
			if(@retcode <> 0) or (@@error <> 0)
				return 1
		end
		fetch #trancolumn into @proctext
	END
	exec @retcode = sp_replpostcmd 0, @pubid, @artid, 35, N' --'
	if(@retcode <> 0) or (@@error <> 0)
		return 1
	close #trancolumn
	deallocate #trancolumn
	return 0
end
go
EXEC dbo.sp_MS_marksystemobject sp_MSpost_auto_proc
go
--
-- sp_MSrepl_schema 
--
-- Description: Helper store proc, used by schema replication.
--		constructs schema modification code and post to the log.
--
-- Returns:
-- 		0 if success
--		1 if failure
--
raiserror('Creating procedure sp_MSrepl_schema', 0,1)
go

create proc sp_MSrepl_schema @pubname sysname
				,@artid int 
				,@qual_source_object nvarchar(362) -- quoted table name
				,@column sysname -- column name, not quoted, as we need to search in syscolumns by it.
				,@operation int -- 0 is add, 1 is drop
				,@typetext nvarchar(3000) = NULL	
				,@schema_change_script nvarchar(4000) = NULL
as
begin
	declare @retcode int
	declare @pubid int
	declare @objid int
	declare @schema_option binary(8)
	declare @auto_gen int
	declare @cmd_type int
	declare @ins_cmd nvarchar(510)
	declare @del_cmd nvarchar(510)
	declare @upd_cmd nvarchar(510)
	declare @repub_command nvarchar(4000)
	declare @nopub_command nvarchar(4000)
	declare @prefix nvarchar(32)
	declare @post_cmd nvarchar(4000)
	declare @qual_column sysname
	declare @use_script bit
	declare @allow_dts bit
	
	set nocount on
	select @retcode = 0
	select @auto_gen = 2 -- auto generate custom procs
	select @cmd_type = 35 -- SQL statement
	select @qual_column = QUOTENAME(@column)
	select @objid = object_id(@qual_source_object)

    /*
    ** Security Check
    */
    exec @retcode = dbo.sp_MSreplcheck_publish
    if @@ERROR <> 0 or @retcode <> 0
        return(1)

	if (@schema_change_script is not NULL) and (len(@schema_change_script) > 0)
		select @use_script = 1
	else
		select @use_script = 0
	
	
	select @pubid = a.pubid, @schema_option = schema_option, @ins_cmd = ins_cmd, @del_cmd = del_cmd, @upd_cmd = upd_cmd, @allow_dts = allow_dts 
		from sysarticles a join syspublications p on a.pubid = p.pubid where artid = @artid
	
	if (@allow_dts = 1)
		goto SCRIPTONLY

	if(@operation = 0)
	begin
		select @repub_command = N'exec sp_repladdcolumn @source_object=N''' + @qual_source_object + N''',@column=N''' + replace(@column  , N'''', N'''''')
						+ N''',@typetext=N''' + replace(@typetext, N'''', N'''''') + N''' '
		select @nopub_command = N'else alter table ' + @qual_source_object + N' add ' + @qual_column + N' ' + @typetext + N' ' 
		select @prefix = N'if not exists '
	end
	else
	begin
		select @repub_command = N'exec sp_repldropcolumn @source_object=N''' + @qual_source_object + N''',@column=N''' + @column  + N''' '
		select @nopub_command = N'else alter table ' + @qual_source_object + N' drop column ' + @qual_column + N' '
		select @prefix = N'if exists '
	end
	if (@use_script = 1)--Need to pass the script file along if sub is republished.
		select @repub_command = @repub_command  + N',@schema_change_script=N''' + @schema_change_script + N''' '
	select @post_cmd = @prefix + N'(select * from syscolumns where name=''' + @column + ''' and id = object_id('''+ PARSENAME(@qual_source_object, 1) + ''')) begin '
	exec @retcode = sp_replpostcmd 1, @pubid, @artid, @cmd_type, @post_cmd 
	if(@retcode <> 0) or (@@error <> 0)
		return 1
	select @post_cmd = N'if exists (select * from sysobjects where name=''syspublications'') if exists (select * from sysarticles where objid=object_id('''+ PARSENAME(@qual_source_object, 1) + ''')) and @@microsoftversion >= 0x07320000 '
	exec @retcode = sp_replpostcmd 1, @pubid, @artid, @cmd_type, @post_cmd 
	if(@retcode <> 0) or (@@error <> 0)
		return 1
	exec @retcode = sp_replpostcmd 1, @pubid, @artid, @cmd_type, @repub_command
	if(@retcode <> 0) or (@@error <> 0)
		return 1
	exec @retcode = sp_replpostcmd 1, @pubid, @artid, @cmd_type, @nopub_command
	if(@retcode <> 0) or (@@error <> 0)
		return 1
	exec @retcode = sp_replpostcmd 1, @pubid, @artid, @cmd_type, @nopub_command
	if(@retcode <> 0) or (@@error <> 0)
		return 1
	exec @retcode = sp_replpostcmd 0, @pubid, @artid, @cmd_type, N' end '
	if(@retcode <> 0) or (@@error <> 0)
		return 1
	
	if ((convert(int, @schema_option) & @auto_gen) > 0)-- No script, but custom procs were auto-generated
	begin
		if(UPPER(LEFT(LTRIM(@ins_cmd), 4) collate SQL_Latin1_General_CP1_CS_AS) = UPPER('CALL' collate SQL_Latin1_General_CP1_CS_AS))
		begin
			exec @retcode = sp_MSpost_auto_proc @pubid, @artid, 'sp_scriptinsproc' 
			if(@retcode <> 0) or (@@error <> 0)
				return 1
		end
		if(UPPER(LEFT(LTRIM(@del_cmd), 4) collate SQL_Latin1_General_CP1_CS_AS) = UPPER('CALL' collate SQL_Latin1_General_CP1_CS_AS))
		begin
			exec @retcode = sp_MSpost_auto_proc @pubid, @artid, 'sp_scriptdelproc' 
			if(@retcode <> 0) or (@@error <> 0)
				return 1
		end
		else if(UPPER(LEFT(LTRIM(@del_cmd), 5) collate SQL_Latin1_General_CP1_CS_AS) = UPPER('XCALL' collate SQL_Latin1_General_CP1_CS_AS))
		begin
			exec @retcode = sp_MSpost_auto_proc @pubid, @artid, 'sp_scriptxdelproc' 
			if(@retcode <> 0) or (@@error <> 0)
				return 1
		end
		if(UPPER(LEFT(LTRIM(@upd_cmd), 4) collate SQL_Latin1_General_CP1_CS_AS) = UPPER('CALL' collate SQL_Latin1_General_CP1_CS_AS))
		begin
			exec @retcode = sp_MSpost_auto_proc @pubid, @artid, 'sp_scriptupdproc' 
			if(@retcode <> 0) or (@@error <> 0)
				return 1
		end
		else if(UPPER(LEFT(LTRIM(@upd_cmd), 5) collate SQL_Latin1_General_CP1_CS_AS) = UPPER('MCALL' collate SQL_Latin1_General_CP1_CS_AS))
		begin
			exec @retcode = sp_MSpost_auto_proc @pubid, @artid, 'sp_scriptmappedupdproc' 
			if(@retcode <> 0) or (@@error <> 0)
				return 1
		end
		else if(UPPER(LEFT(LTRIM(@upd_cmd), 5) collate SQL_Latin1_General_CP1_CS_AS) = UPPER('XCALL' collate SQL_Latin1_General_CP1_CS_AS))
		begin
			exec @retcode = sp_MSpost_auto_proc @pubid, @artid, 'sp_scriptxupdproc' 
			if(@retcode <> 0) or (@@error <> 0)
				return 1
		end
	end
SCRIPTONLY:

	if (@use_script = 1)
	begin
		exec @retcode = sp_addscriptexec @publication = @pubname, @scriptfile = @schema_change_script
		if @retcode<>0 or @@ERROR<>0
			return 1
	end 
	return 0
end
go
EXEC dbo.sp_MS_marksystemobject sp_MSrepl_schema 
go
--
-- sp_MSreplupdateschema
--
-- Description: Wrapper store proc, check for admin\dbowner credential before invoking sp_replupdateschema
--
-- Returns:
-- 		0 if success
--		1 if failure
--
raiserror('Creating procedure sp_MSreplupdateschema', 0,1)
go

create proc sp_MSreplupdateschema  @object_name sysname
as
begin
	declare @retcode int
	IF @object_name IS NULL
	BEGIN
		RAISERROR (14043, 16, -1, '@object_name')
		RETURN (1)
	END

	EXEC @retcode = dbo.sp_MSreplcheck_publish
	IF @@ERROR <> 0 or @retcode <> 0
        	return (1)

	exec dbo.sp_replupdateschema @object_name
	return 0
end
go
EXEC dbo.sp_MS_marksystemobject sp_MSreplupdateschema
go
--
-- sp_MSdefer_check
--
-- Description: disable constraints (Foreign Key and Check) and triggers during concurrent snapshot
--		and script enable cmds for later
--
-- Note: 	this stored procedure loops through the list of Foreign Key, Check constraints and Triggers
--		which are not disabled and not marked 'not for replicaiton', it uses 'alter table' to disable 
--		these entries (nocheck/disable), and copies the corresponding enable code into a temp table.
--		at the end, cmds in temp table is used to build a stored procedure which will be used by dist 
--		agent to enable these cnst/triggers at the end of concurrent snapshot. if it failed to create 
--		the stored procedure, a default one (sp_MSreenable_check) will be used, the key difference here
--		is the sp created here will only enable the ones we disabled here, while the default one will 
--		enable all in current table.
--
--		the sp created within sp_MSdefer_check will enable all the entries disabled by sp_MSdefer_check, 
--		then drop itself at the end.
--
-- Returns:
-- 		0 if success
--		1 if failure
--
raiserror('Creating procedure sp_MSdefer_check', 0,1)
go
create proc sp_MSdefer_check @objname sysname, @objowner sysname = NULL
as
	set nocount on
	declare @cnstname sysname
	declare @cnstid int
	declare @objid int
	declare @enable_cmd nvarchar(4000)
	declare @disable_cmd nvarchar(4000)
	declare @quotedproc nvarchar(240)
	declare @dest nvarchar(514)
	declare @dbname sysname
	declare @proc_exists bit

	if(@objowner is not null)
		select @dest = quotename(@objowner) + N'.' + quotename(@objname)
	else
		select @dest = quotename(@objname)

	declare @retcode int
	IF @objname IS NULL
	BEGIN
		RAISERROR (14043, 16, -1, '@objname')
		RETURN (1)
	END

	EXEC @retcode = dbo.sp_MSreplcheck_publish
	IF @@ERROR <> 0 or @retcode <> 0
        	return (1)

	select @objid = object_id(@dest)
	select @enable_cmd = N'sp_MSenable_' + convert(varchar(64), @objid)
	if exists(select name from sysobjects where name = @enable_cmd and ObjectProperty(id, 'IsProcedure') = 1)
		select @proc_exists = 1
	else
		select @proc_exists = 0

	select @quotedproc = quotename(@enable_cmd)
	select @enable_cmd = N'create proc ' + @quotedproc + N' as '
	create table #proccmd (c1 int identity, c2 nvarchar(3000) collate database_default)
	insert #proccmd (c2) values (@enable_cmd)
	
	declare ms_crs_cnst cursor local static for
	select name, id from sysobjects where parent_obj = @objid and 
		   ((OBJECTPROPERTY(id, 'CnstIsDisabled') = 0 and OBJECTPROPERTY(id, 'CnstIsNotRepl') = 0 and 
		    (OBJECTPROPERTY(id, 'IsCheckCnst') = 1 or OBJECTPROPERTY(id, 'IsForeignKey') = 1))
		or (ObjectProperty(id, 'IsTrigger') = 1 and OBJECTPROPERTY(id, 'ExecIsTriggerNotForRepl') = 0 and ObjectProperty(id, 'ExecIsTriggerDisabled') = 0))
	for read only

	open ms_crs_cnst
	fetch ms_crs_cnst into @cnstname, @cnstid
	while @@fetch_status >= 0
	begin
		if(ObjectProperty(@cnstid, 'IsTrigger') = 1)
		begin
			select @disable_cmd = N'alter table ' + @dest + N' disable trigger ' + quotename(@cnstname)
			select @enable_cmd = N'alter table ' + @dest + N' enable trigger '+quotename(@cnstname)
		end
		else
		begin
			select @disable_cmd = N'alter table ' + @dest + N' nocheck constraint ' + quotename(@cnstname)
			select @enable_cmd = N'alter table ' + @dest + N' check constraint ' + quotename(@cnstname)
		end
		insert #proccmd (c2) values (@enable_cmd)

		execute(@disable_cmd)
		fetch ms_crs_cnst into @cnstname, @cnstid
	end		--of major loop
	deallocate ms_crs_cnst
	if(@proc_exists = 1) -- don't try to recreate the proc
	begin 
		select N'exec ' + @quotedproc
		drop table #proccmd
		return 0
	end

	select @enable_cmd = N'drop proc ' + @quotedproc
	insert #proccmd (c2) values (@enable_cmd)
	select @enable_cmd = N'select c2 from #proccmd order by c1'
	select @dbname = db_name()
	exec @retcode = master..xp_execresultset @enable_cmd, @dbname
	if @@error <> 0 or @retcode <> 0 or @quotedproc is NULL
	begin
		declare @cmd_param nvarchar(4000)
		if (@objowner is null)
			select @cmd_param = N' @objname = N''' + @objname + N''''
		else
			select @cmd_param = N' @objname = N''' + @objname + N''', @objowner = N''' + @objowner + N''''
		select N'exec sp_MSreenable_check ' + @cmd_param
	end
	else
		select N'exec ' + @quotedproc
	drop table #proccmd
	return 0
go
EXEC dbo.sp_MS_marksystemobject sp_MSdefer_check
go
--
-- sp_MSreenable_check
--
-- Description: default sp to enable constraints (Foreign Key and Check) and triggers at 
--		the end of compensation mode in concurrent snapshot.
--
-- Note : 	this default sp doesn't get used unless we failed to construct a temp one at runtime.
--
-- Returns:
-- 		0 if success
--		1 if failure
--
raiserror('Creating procedure sp_MSreenable_check', 0,1)
go
create proc sp_MSreenable_check @objname sysname, @objowner sysname = NULL
as
	set nocount on
	
	declare @cnstname sysname
	declare @cnstid int
	declare @objid int
	declare @enable_cmd nvarchar(4000)
	declare @dest nvarchar(514)

	declare @retcode int
	IF @objname IS NULL
	BEGIN
		RAISERROR (14043, 16, -1, '@objname')
		RETURN (1)
	END

	if(@objowner is not null)
		select @dest = quotename(@objowner) + N'.' + quotename(@objname)
	else
		select @dest = quotename(@objname)

	EXEC @retcode = dbo.sp_MSreplcheck_publish
	IF @@ERROR <> 0 or @retcode <> 0
        	return (1)

	select @objid = object_id(@objname)
	
	declare ms_crs_cnst cursor local static for
	select name, id from sysobjects where parent_obj = @objid and 
		   ((OBJECTPROPERTY(id, 'CnstIsDisabled') = 1 and OBJECTPROPERTY(id, 'CnstIsNotRepl') = 0 and 
		    (OBJECTPROPERTY(id, 'IsCheckCnst') = 1 or OBJECTPROPERTY(id, 'IsForeignKey') = 1))
		or (ObjectProperty(id, 'IsTrigger') = 1 and OBJECTPROPERTY(id, 'ExecIsTriggerNotForRepl') = 0 and ObjectProperty(id, 'ExecIsTriggerDisabled') = 1))
	for read only

	open ms_crs_cnst
	fetch ms_crs_cnst into @cnstname, @cnstid
	while @@fetch_status >= 0
	begin
		if(ObjectProperty(@cnstid, 'IsTrigger') = 1)
			select @enable_cmd = N'alter table ' + @dest + N' enable trigger ' + quotename(@cnstname)
		else
			select @enable_cmd = N'alter table ' + @dest + N' check constraint ' + quotename(@cnstname)

		execute(@enable_cmd)
		fetch ms_crs_cnst into @cnstname, @cnstid
	end		--of major loop
	deallocate ms_crs_cnst
	return 0
go
EXEC dbo.sp_MS_marksystemobject sp_MSreenable_check
go

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
		where publisher = UPPER(@publisher) and
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
		where publisher = UPPER(@publisher) and
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
GO
--
-- sp_MSprep_exclusive
--
-- Description: Helper sp for schema change, acquires shc-m lock on the source table, 
--		and 'Exclusive' application lock on all the publications it belongs to.
--
-- Note : 	@objname should be owner qualified
-- Returns:
-- 		0 if success
--		1 if failure
--
raiserror('Creating procedure sp_MSprep_exclusive', 0,1)
go
create proc sp_MSprep_exclusive @objname sysname
as
	set nocount on
	declare @retcode int
	declare @objid int
	declare @tran_pubname sysname

	EXEC @retcode = dbo.sp_MSreplcheck_publish
	IF @@ERROR <> 0 or @retcode <> 0
		return (1)

	if @objname is NULL
	begin
		RAISERROR (14043, 16, -1, '@objname')
		return (1)
	end

	select @objid = object_id(@objname)
	if @objid is NULL
	begin
		raiserror(14027, 16, -1, @objname)
		return (1)
	end

	exec sp_replupdateschema @objname
	if @@ERROR<>0
		return (1)

	declare #trancolumn CURSOR LOCAL FAST_FORWARD for 
			select p.name from sysarticles a, syspublications p where a.objid=@objid
					and p.pubid = a.pubid
	open #trancolumn
	fetch #trancolumn into @tran_pubname
	while (@@fetch_status <> -1)
	BEGIN
		EXEC @retcode = sp_getapplock 	@Resource = @tran_pubname, 
						@LockMode = N'Exclusive', 
						@LockOwner = N'Transaction', 
						@LockTimeout = 0
		if @retcode = -1
		begin 
			raiserror(21386, 16, -1, @objname)
			goto FAILURE	
		end 
		if @@ERROR<>0 or @retcode < 0
			goto FAILURE
		fetch #trancolumn into @tran_pubname			
	END
	close #trancolumn
	deallocate #trancolumn
	return 0
FAILURE:
	close #trancolumn
	deallocate #trancolumn
	return (1)
go
EXEC dbo.sp_MS_marksystemobject sp_MSprep_exclusive
--
-- sp_verify_publication
--
-- Description: Invoked by user on a distributor server to perform a simple replication plumbing check.
--		Tests the connectivity of all the push subscriptions for a given publication.
--		(doesn't test pull or anonymous subscriptions)
--
-- Returns:
-- 		0 if success
--		1 if failure
--
raiserror('Creating procedure sp_verify_publication', 0,1)
go
create proc sp_verify_publication (
	@publisher sysname,		/*name of the publisher*/
	@publisher_db sysname,		/*the database for the publication*/
	@publication sysname,		/*name of the publication*/
	@reserved int = 0		/*reserved -- should not be used directly by user.
					  For internal use only.*/
)
AS
BEGIN
set nocount on

if( @reserved = 0 )
begin
  declare @proc nvarchar(255),
	  @distribution_db sysname,
	  @recurse_retcode int
  --
  --verify that this server is a distributor.
  --
  if (not exists( select * from msdb..sysobjects where name = 'MSdistpublishers') )
  begin
    RAISERROR(14114, 16, -1, @@SERVERNAME)
    return(1)
  end
  --
  --get the distribution database
  --
  select @distribution_db = distribution_db from msdb.dbo.MSdistpublishers where UPPER(name) = UPPER(@publisher) collate database_default
  if( @distribution_db is NULL )
  begin
    RAISERROR(21169, 16, -1, @publisher, @@SERVERNAME, @publisher)
    return(1)
  end

  select @proc = @distribution_db + '.dbo.sp_verify_publication'
  exec @recurse_retcode = @proc @publisher, @publisher_db, @publication, 1
  return(@recurse_retcode)
end

declare @publisher_id smallint,
	@subscriber sysname,
	@subscriber_db sysname,
	@type tinyint,
	@job_id binary(16),
	@publication_type int,
	@agent_type varchar(15),
	@command nvarchar(3200),
	@success varchar(300),
	@srvid smallint

select @srvid = srvid from master.dbo.sysservers where UPPER(srvname) = UPPER(@publisher) collate database_default
if @srvid is NULL
begin
  RAISERROR(21169, 16, -1, @publisher, @@SERVERNAME, @publisher)
  return(1)
end

select @publication_type = publication_type from MSpublications
  where publisher_id = @srvid and
  publisher_db = @publisher_db and
  publication = @publication

if @publication_type is NULL
begin
  RAISERROR(21332, 16, -1, @publication)
  return(1)
end

create table #T_VERIFICATION_RESULTS (
  subscriber sysname NOT NULL, subscriber_db sysname NOT NULL, type int NOT NULL,
  job_id binary(16) NULL, results varchar(300) NULL
)

-- Parameter Check: @publication_type
-- Make sure that the publication type is one of the following:
-- 0  transactional
-- 1  snapshot
-- 2  merge
if( @publication_type = 0 or @publication_type = 1 )
  begin
    select @agent_type = 'distribution'

    create table #T_SUBSCRIPTIONS (subscriber sysname NOT NULL,  status int NOT NULL, 
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

    insert #T_SUBSCRIPTIONS
      exec sp_MSenum_subscriptions @publisher, @publisher_db, @publication

    insert into #T_VERIFICATION_RESULTS (subscriber, subscriber_db, type, job_id)
	(select subscriber, subscriber_db, type, job_id from #T_SUBSCRIPTIONS)

    drop table #T_SUBSCRIPTIONS
  end
else if( @publication_type = 2 )
  begin
    select @agent_type = 'merge'

    create table #T_MERGE_SUBSCRIPTIONS (subscriber sysname NOT NULL,  status int NOT NULL, 
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

    insert #T_MERGE_SUBSCRIPTIONS
      exec sp_MSenum_merge_subscriptions @publisher, @publisher_db, @publication

    insert into #T_VERIFICATION_RESULTS (subscriber, subscriber_db, type, job_id)
	(select subscriber, subscriber_db, type, job_id from #T_MERGE_SUBSCRIPTIONS)

    drop table #T_MERGE_SUBSCRIPTIONS
  end
else
  begin
    drop table #T_VERIFICATION_RESULTS
    RAISERROR(20033, 16, -1)
    return(1)
  end

if( not exists( select * from #T_VERIFICATION_RESULTS ) )
begin
  --
  --if #T_VERIFICATION_RESULTS is empty, then there's no subscriptions
  --
  RAISERROR(14135, 16, -1, @publisher, @publisher_db, @publication)
  drop table #T_VERIFICATION_RESULTS
  return(1)
end

declare subscribers_cursor cursor LOCAL FAST_FORWARD for
select subscriber, subscriber_db, type, job_id
  from #T_VERIFICATION_RESULTS
  order by subscriber, subscriber_db

open subscribers_cursor
fetch next from subscribers_cursor
  into @subscriber, @subscriber_db, @type, @job_id
while @@FETCH_STATUS = 0
begin
  if( @type = 0 )
  begin
    --
    --local push subscription
    --
    select @command = ''
    select @success = 'unknown'
    select @command = command from msdb.dbo.sysjobsteps
      where job_id = @job_id and
	    subsystem = case @publication_type  -- 0 = Transactional 1 = Snapshot 2 = Merge
	      when 0 then N'Distribution'
	      when 1 then N'Distribution'
	      when 2 then N'Merge'
	    end

    exec master.dbo.xp_replproberemsrv 'local', @agent_type, @success OUTPUT, @command, 1 --(islocal)
    if( @@ERROR <> 0) return(1)
    if UPPER(@success collate SQL_Latin1_General_CP1_CS_AS) = 'FALSE'
      select 'subscriber' = @subscriber, 'subscriber database' = @subscriber_db,
	     'subscription type' = case @type
		    when 0 then 'push'
		    when 1 then 'pull'
		    when 2 then 'anonymous'
		    else 'unknown'
		  end
	     , 'results' = 'connection failed'
    else if( ( CHARINDEX('TRUE', UPPER(@success collate SQL_Latin1_General_CP1_CS_AS)) = 1 ) and (LEN(@success) = 4) )
      select @success = 'connection succeeded'
  end
  else
  begin
    --
    --non-push subscription, not supported
    --
    select @success = 'only push subscriptions can be verified with this stored procedure'
  end

  update #T_VERIFICATION_RESULTS set results = @success where
    subscriber = @subscriber and
    subscriber_db = @subscriber_db and
    type = @type and
    job_id = @job_id
  --
  --get next subscription
  --
  fetch next from subscribers_cursor
    into @subscriber, @subscriber_db, @type, @job_id
end
close subscribers_cursor
deallocate subscribers_cursor

select subscriber, subscriber_db as 'subscriber database', 'subscription type' =
  case type
    when 0 then 'push'
    when 1 then 'pull'
    when 2 then 'anonymous'
    else 'unknown'
  end
, results from #T_VERIFICATION_RESULTS where UPPER(results collate SQL_Latin1_General_CP1_CS_AS) != 'FALSE'

drop table #T_VERIFICATION_RESULTS
END
go
EXEC dbo.sp_MS_marksystemobject sp_verify_publication

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


raiserror('Creating procedure sp_repltablehasnonpkuniquekey',0,-1)
go
--
-- Name: sp_repltablehasnonpkuniquekey
--
-- Description: This procedure is by queued updating replication to check
-- if a given table has non PK unique index keys
--
-- Parameter: @tabid int
--
-- Returns: 1 or 0  1 = The table has one or more unique index that is not PK
--
-- Security: Internal procedure - exec permission not granted explicitly. 
--
create procedure sp_repltablehasnonpkuniquekey 
(
    @tabid int              -- id of the table
)
as
begin
    set nocount on
    declare @retcode int
    --
    -- security check - should be dbo or sysadmin
    --
    exec @retcode = dbo.sp_MSreplcheck_publish
    if @@ERROR != 0 or @retcode != 0
        return -1
    --
    -- process if the object is a table and has index
    --
    if (ObjectProperty(@tabid, 'IsTable') = 1) and (ObjectProperty(@tabid, 'TableHasIndex') = 1)
    begin
        --
        -- Set return flag if it is Unique key but not PK
        --
        if exists (select indid from sysindexes 
                where id = @tabid 
                    and indid > 0 and indid < 255
                    and (status & 2) != 0 and (status & 2048) = 0 )
        begin
            select @retcode = 1
        end
    end
    --
    -- all done
    --
    return @retcode
end
go
exec sp_MS_marksystemobject sp_repltablehasnonpkuniquekey
go

raiserror('Creating procedure sp_replscriptuniquekeywhereclause',0,-1)
go
--
-- Name: sp_replscriptuniquekeywhereclause
--
-- Description: This procedure is by queued updating replication to generate
-- where clause using all the unique keys (including PK)
--
-- Parameter: Refer to the comments in the create procedure statement
--
-- Returns: 1 or 0   0 = success
--
-- Security: Internal procedure - exec permission not granted explicitly. 
--
create procedure sp_replscriptuniquekeywhereclause 
(
    @tabid int                                  -- id of the table
    ,@columns binary(32)                 -- column map for the article
    ,@prefix nvarchar(10) = '@c'       -- prefix for the scripted column variables
    ,@suffix nvarchar(10) = null	   -- suffix for the scripted column variables
    ,@mode tinyint                           
    -- 1 = insert custom proc, 
    -- 2 = upd custom proc non PK, 
    -- 3 = upd custom proc PK only 
    -- 4 = compensating where all keys, 
    -- 5 = compensating where non PK keys, 
    -- 6 = refresh cursor all keys,
    -- 7 = refresh cursor non PK keys
    -- 8 = compensating where PK only
    ,@paramcount int = null              -- Total number of parameters - needed for mode = 2 and 3
 )
as
begin
    set nocount on
    declare @retcode int
                ,@indid int
                ,@indstatus int
                ,@indkey int
                ,@qualname nvarchar(512)
                ,@colname sysname
                ,@var sysname
                ,@artcol int
                ,@thiscol int
                ,@cmd nvarchar(4000)
                ,@findexstarted bit
                ,@fisfirstindex bit
    --
    -- constants
    --
                ,@modeinscustproc tinyint
                ,@modeupdcustprocnonpk tinyint
                ,@modeupdcustprocpkonly tinyint
                ,@modecompensatingallkeys tinyint
                ,@modecompensatingnonpkkeys tinyint
                ,@modecompensatingpkonly tinyint
                ,@moderefreshcursordeclareallkeys tinyint
                ,@moderefreshcursordeclarenonpkkeys tinyint

    --
    -- initialize
    --
    select @modeinscustproc = 1
            ,@modeupdcustprocnonpk = 2
            ,@modeupdcustprocpkonly = 3
            ,@modecompensatingallkeys = 4
            ,@modecompensatingnonpkkeys = 5
            ,@moderefreshcursordeclareallkeys = 6
            ,@moderefreshcursordeclarenonpkkeys = 7
            ,@modecompensatingpkonly = 8
    --
    -- security check - should be dbo or sysadmin
    --
    exec @retcode = dbo.sp_MSreplcheck_publish
    if @@error != 0 or @retcode != 0
        return (1)
    --
    -- process if the object is a table and has index
    --
    if (ObjectProperty(@tabid, 'IsTable') != 1) or (ObjectProperty(@tabid, 'TableHasIndex') != 1)
        return (1)
    --
    -- Get the qualified name of the table
    --
    exec @retcode = sp_MSget_qualified_name @tabid, @qualname OUTPUT
    if @@error != 0 or @retcode != 0 or @qualname is null
        return (1)
    --
    -- @columns cannot be null
    --
    if (@columns is null)
        return (1)
    --
    -- Check @mode
    --
    if (@mode not in (@modeinscustproc, @modeupdcustprocnonpk, @modeupdcustprocpkonly, 
                                @modecompensatingallkeys, @modecompensatingnonpkkeys, 
                                @moderefreshcursordeclareallkeys, @moderefreshcursordeclarenonpkkeys,
                                @modecompensatingpkonly))
    begin
        return (1)
    end
    --
    -- validate @paramcount
    --
    if ((@mode in (@modeupdcustprocnonpk,@modeupdcustprocpkonly)) and (@paramcount is null))
    begin
        return (1)
    end
    --
    -- enumerate indices
    -- The scripting will be done as follows :
    -- A) all keys will include PK and all unique keys
    --      where (pk1 = @cv and pk2 = @cw ...) or (ui1k1 = @cx and ui1k2 = @cy ...) or (u2k1 = @cz and ...) ...
    -- B) non PK keys will use only the unique keys that are not part of PK
    --      where (ui1k1 = @cx and ui1k2 = @cy ...) or (u2k1 = @cz and ...) ...
    --
    select @cmd = case when (@mode in (@modecompensatingallkeys, @modecompensatingnonpkkeys, @modecompensatingpkonly)) 
                            then N' '' where '
                            else N' where ' end
            ,@findexstarted = 0
            ,@fisfirstindex = 1
    declare #hcindid cursor local fast_forward for
        select indid, status from sysindexes 
                where id = @tabid and (status & 2) != 0
                    and indid > 0 and indid < 255
                    order by indid asc
    open #hcindid
    fetch #hcindid into @indid, @indstatus
    while (@@fetch_status != -1)
    begin
        --
        -- If we are in (@modeupdcustprocnonpk, @modecompensatingnonpkkeys, 
        -- @moderefreshcursordeclarenonpklkeys) mode then skip processing the PK index.
        -- If we are in (@modeupdcustprocpkonly, @modecompensatingpkonly) mode 
        -- skip processing the non PK index
        --
        if ((@mode in (@modeupdcustprocnonpk,@modecompensatingnonpkkeys,
                    @moderefreshcursordeclarenonpkkeys)) and (@indstatus & 2048) != 0) 
            or ((@mode in (@modeupdcustprocpkonly, @modecompensatingpkonly)) and (@indstatus & 2048) = 0)
        begin
            --
            -- fetch next unique index
            --
            fetch #hcindid into @indid, @indstatus
            continue
        end
        --
        -- Enumerate the keys in this index
        --
        select @indkey = 1
        while (@indkey <= 16)
        begin
            --
            -- get the column name for the key
            --
            select @colname = index_col(@qualname, @indid, @indkey)
            if (@colname is null) 
                break
            --
            -- check if this column is enabled for replication
            --
            select @artcol = 0
            exec dbo.sp_MSget_col_position @tabid, @columns, @colname, NULL, @artcol output, 0, NULL, @thiscol output
            if (@artcol > 0)
            begin
                --
                -- check if we are scripting the first key for this index
                --
                if (@findexstarted = 1)
                begin
                    select @cmd = case when (@mode in (@modecompensatingallkeys, @modecompensatingnonpkkeys, @modecompensatingpkonly)) 
                                            then @cmd + N' + '' and '
                                            else @cmd + N' and ' end
                end
                else
                begin
                    --
                    -- check if we are scripting the first index. 
                    --
                    if (@fisfirstindex = 0)
                    begin
                        select @cmd =  @cmd + N' or ' 
                    end
                    else
                    begin
                        select @fisfirstindex = 0
                    end
                    --
                    -- set @findexstarted while processing the first key
                    --
                    select @findexstarted = 1
                    select @cmd = @cmd + N' ( ' 
                end
                --
                -- script this column
                --
                if (@mode in (@modecompensatingallkeys, @modecompensatingnonpkkeys, @modecompensatingpkonly))
                begin
                    --
                    -- scripting a delete compensating command for synctran proc - we are building a dynamic string
                    -- case when @c<this_col> is null then '[col<this_col>] is null' else '[col<this_col>] = @c<this_col>' end
                    --
                    declare @ccoltype sysname

                    select @var = @prefix + cast(@thiscol as nvarchar(10))
                    if (@suffix is not null)
                        select @var = @var + @suffix
                    select @cmd = @cmd + N''' + case when ( ' + @var + N' is null) then  '' ' + quotename(@colname) + N' is null '' else '' ' + quotename(@colname)
                    exec dbo.sp_MSget_colinfo @tabid, @thiscol, @columns, 0, NULL, @ccoltype output
                    if (lower(@ccoltype collate SQL_Latin1_General_CP1_CS_AS) = 'varchar' )
                        select @cmd = @cmd + N' = '''''' + CAST( master.dbo.fn_MSgensqescstr(' + @var + N') collate database_default as varchar) + '''''''' end ' 
                    else if (lower(@ccoltype collate SQL_Latin1_General_CP1_CS_AS) = 'nvarchar')
                        select @cmd = @cmd + N' = N'''''' + master.dbo.fn_MSgensqescstr(' + @var + N') collate database_default + '''''''' end ' 
                    else if (lower(@ccoltype collate SQL_Latin1_General_CP1_CS_AS) = 'char')
                        select @cmd = @cmd + N' = '''''' + master.dbo.fn_MSgensqescstr(CAST(RTRIM(' + @var + N') as nvarchar)) collate database_default + '''''''' end ' 
                    else if (lower(@ccoltype collate SQL_Latin1_General_CP1_CS_AS) = 'nchar')
                        select @cmd = @cmd + N' = N'''''' + master.dbo.fn_MSgensqescstr(CAST(RTRIM(' + @var + N') as nvarchar)) collate database_default + '''''''' end ' 
                    else if (lower(@ccoltype collate SQL_Latin1_General_CP1_CS_AS) in ('binary','varbinary'))
                        select @cmd = @cmd + N' = '' + master.dbo.fn_varbintohexstr(' + @var + N') collate database_default end ' 
                    else if (lower(@ccoltype collate SQL_Latin1_General_CP1_CS_AS) in ('bit','bigint','int','smallint','tinyint','decimal','numeric'))
                        select @cmd = @cmd + N' = '' + CAST( ' + @var + N' as nvarchar) end ' 
                    else if (lower(@ccoltype collate SQL_Latin1_General_CP1_CS_AS) in ('float','real'))
                        select @cmd = @cmd + N' = '' + CONVERT(nvarchar(60), ' + @var + N' , 2) end ' 
                    else if (lower(@ccoltype collate SQL_Latin1_General_CP1_CS_AS) in ('money','smallmoney'))
                        select @cmd = @cmd + N' = '' + CONVERT(nvarchar(40), ' + @var + N' , 2) end ' 
                    else if (lower(@ccoltype collate SQL_Latin1_General_CP1_CS_AS) = 'uniqueidentifier')
                        select @cmd = @cmd + N' = '''''' + CAST( ' + @var + N' as nvarchar(40)) + '''''''' end ' 
                    else if (lower(@ccoltype collate SQL_Latin1_General_CP1_CS_AS) in ('datetime','smalldatetime'))
                        select @cmd = @cmd + N' = '''''' + CONVERT(nvarchar(40), ' + @var + N', 112) + N'' '' + CONVERT(nvarchar(40), ' + @var + N', 114) + '''''''' end ' 
                    else if (lower(@ccoltype collate SQL_Latin1_General_CP1_CS_AS) = 'sql_variant')
                        select @cmd = @cmd + N' = '' + master.dbo.fn_sqlvarbasetostr( ' + @var + N' ) collate database_default  end ' 
                    else
                        select @cmd = @cmd + N' = '' + CAST( ' + @var + N' as nvarchar) end ' 

                        --select @cmd = @cmd + N' = '' + ISNULL('''''''' + master.dbo.fn_MSgensqescstr(' + @var + N') collate database_default + '''''''', ''null'') '
                        --select @cmd = @cmd + N' = '' + ISNULL(''N'''''' + master.dbo.fn_MSgensqescstr(' + @var + N') collate database_default + '''''''', ''null'') '
                        --select @cmd = @cmd + N' = '' + ISNULL('''''''' + master.dbo.fn_MSgensqescstr(CAST(RTRIM(' + @var + N') as nvarchar)) collate database_default + '''''''', ''null'') '
                        --select @cmd = @cmd + N' = '' + ISNULL(''N'''''' + master.dbo.fn_MSgensqescstr(CAST(RTRIM(' + @var + N') as nvarchar)) collate database_default + '''''''', ''null'') '
                        --select @cmd = @cmd + N' = '' + ISNULL(master.dbo.fn_varbintohexstr(' + @var + N') collate database_default, ''null'') ' 
                        --select @cmd = @cmd + N' = '' + ISNULL(CAST(' + @var + N' as nvarchar), ''null'') '
                        --select @cmd = @cmd + N' = '' + ISNULL(CONVERT(nvarchar(40),' + @var + N', 2), ''null'') '
                        --select @cmd = @cmd + N' = '' + ISNULL('''''''' + CAST(' + @var + N' as nvarchar(40)) + '''''''', ''null'') '
                        --select @cmd = @cmd + N' = '' + ISNULL('''''''' + CONVERT(nvarchar(40), ' + @var + N', 112) + N'' '' + CONVERT(nvarchar(40), ' + @var + N', 114) + '''''''', ''null'') '	
                        --select @cmd = @cmd + N' = '' + ISNULL(master.dbo.fn_sqlvarbasetostr(' + @var + N' ) collate database_default, ''null'') '
                        --select @cmd = @cmd + N' = '' + ISNULL(CAST(' + @var + N' as nvarchar), ''null'') '
                end
                else
                begin
                    --
                    -- scripting for custom procs - static script
                    -- For publisher scripting - use @thiscol
                    -- For custom proc scripting - use @artcol
                    -- For Update custom proc scripting special cases - use variation of @artcol
                    --
                    select @var = case when (@mode in (@modeupdcustprocnonpk,@modeupdcustprocpkonly)) 
                                                    then @prefix + cast((@artcol + @paramcount/2) as nvarchar(10))
                                                when (@mode in (@moderefreshcursordeclareallkeys, @moderefreshcursordeclarenonpkkeys))
                                                    then @prefix + cast(@thiscol as nvarchar(10)) 
                                                else @prefix + cast(@artcol as nvarchar(10)) end
                    if (@suffix is not null)
                        select @var = @var + @suffix
                    --
                    -- Does the column allow NULLs
                    --
                    if (columnproperty( @tabid , @colname , 'AllowsNull' ) = 1)
                    begin
                        --
                        -- static scripting should handle NULL valued column
                        -- ((<@var> is null and <colname> is null) or (<@var> is not null and <colname> = <@var>)) 
                        --
                        select @cmd = @cmd + N'((' + @var + N' is null and ' + quotename(@colname) + N' is null) or (' 
                                                + @var + N' is not null and ' + quotename(@colname) + N' = ' + @var + N'))' 
                    end
                    else
                    begin
                        --
                        -- static scripting does not need to check for NULL values
                        -- <colname> = <@var>
                        --
                        select @cmd = @cmd + quotename(@colname) + N' = ' + @var
                    end
                    --
                    -- special processing for @modeupdcustprocnonpk
                    --
                    if (@mode = @modeupdcustprocnonpk)
                    begin
                        select @cmd = @cmd + N' and ' + @prefix + cast((@artcol + @paramcount/2) as nvarchar(10))
                        if (@suffix is not null)
                            select @cmd = @cmd + @suffix
                        select @cmd = @cmd + N' != ' + @prefix + cast(@artcol as nvarchar(10))
                        if (@suffix is not null)
                            select @cmd = @cmd + @suffix
                    end
                end
                --
                -- transfer command string to table if too large
                --
                if (len(@cmd) > 3000)
                    exec dbo.sp_MSflush_command @cmd output, 1, 0                
            end            
            --
            -- get the next key for the index
            --
            select @indkey = @indkey + 1
        end
        --
        -- done with current index
        --
        select @findexstarted = 0
                ,@cmd = case when (@mode in (@modecompensatingallkeys, @modecompensatingnonpkkeys, @modecompensatingpkonly)) 
                                        then @cmd + N' + '' ) '
                                        else @cmd + N' ) ' end
        --
        -- fetch next unique index
        --
        fetch #hcindid into @indid, @indstatus
    end
    close #hcindid
    deallocate #hcindid
    --
    -- Final flush
    --
    if (@mode in (@modecompensatingallkeys, @modecompensatingnonpkkeys, @modecompensatingpkonly))
        select @cmd = @cmd + N''''
    if (len(@cmd) > 0)
        exec dbo.sp_MSflush_command @cmd output, 1, 0                
    --
    -- all done
    --
    return 0
end
go
exec sp_MS_marksystemobject sp_replscriptuniquekeywhereclause
go

--
-- Name: sp_getqueuedarticlesynctraninfo
--
-- Description: This procedure is by Queue reader agent to query the article
-- 	metadata from the publisher - the name of synctran procedures, etc
--   Invoked on publishing database on publisher.
--
-- Parameter: Refer to the comments in the create procedure statement
--
-- Returns: 1 or 0   0 = success
--
-- Security: Public procedure - internal security check. 
--
raiserror('Creating procedure sp_getqueuedarticlesynctraninfo',0,-1)
go
create procedure sp_getqueuedarticlesynctraninfo 
(
    @publication sysname    -- publication - cannot be null
    ,@artid int                     -- article id - cannot be null
)
as
begin
    set nocount on
    declare @retcode int
                ,@owner sysname
                ,@synctraninsproc sysname
                ,@synctranupdproc sysname
                ,@synctrandelproc sysname
                ,@cftprocname sysname
    --
    -- security check - should be dbo or sysadmin
    --
    exec @retcode = dbo.sp_MSreplcheck_publish
    if @@error != 0 or @retcode != 0
        return 1
    if exists (select * from sysobjects where name = N'sysarticleupdates') 
        and exists (select * from sysobjects where name = N'syspublications') 
    begin
        --
        -- get the information needed for resultset
        --
        select user_name(objectproperty(a.sync_ins_proc, 'OwnerId'))
                ,object_name(a.sync_ins_proc)
                ,object_name(a.sync_upd_proc)
                ,object_name(a.sync_del_proc)
                ,object_name(a.ins_conflict_proc)
        from (sysarticleupdates as a join syspublications p
                    on a.pubid = p.pubid)
        where a.artid = @artid
            and p.name = @publication
    end
    else
    begin
        --
        -- replication not installed properly
        --
        return 1
    end
    --
    -- all done
    --
    return 0
end
go
exec sp_MS_marksystemobject sp_getqueuedarticlesynctraninfo
go

--
-- Name: sp_getsqlqueueversion
--
-- Description: This procedure is by Queue reader agent to retrieve the 
-- 	SQL queue version for a given subscription. Invoked on subscribing
--	database on subscriber.
--
-- Parameter: Refer to the comments in the create procedure statement
--
-- Returns: 1 or 0   0 = success
--
-- Security: Public procedure - internal security check. 
--
raiserror('Creating procedure sp_getsqlqueueversion',0,-1)
go
create procedure sp_getsqlqueueversion 
(
    @publisher sysname       -- pubisher - cannot be null
    ,@publisher_db sysname -- publisher_db - cannot be null
    ,@publication sysname    -- publication - cannot be null
    ,@version int output        -- version of the queue > 0
)
as
begin
    set nocount on
    declare @retcode int
                ,@queueidstring sysname

    --
    -- Security check
    --
    exec @retcode = dbo.sp_MSreplcheck_subscribe
    if @@error != 0 or @retcode != 0
        return 1
    --
    -- the subscription must be initialized
    --
    if exists (select * from sysobjects where name = 'MSsubscription_agents')
    begin
        --
        -- do the select for sql queues
        --
        select @queueidstring = substring(queue_id, 1, 10) 
                 ,@version = cast(substring(queue_id, 12, 10)  as int)
        from dbo.MSsubscription_agents
        where publisher = UPPER(@publisher) 
            and publisher_db = @publisher_db 
            and publication = @publication
            and update_mode in (4,5)
        if (@queueidstring = N'mssqlqueue')
        begin
            --
            -- found the entry
            --
            if (@version = 0)
                select @version = 1
        end
        else
        begin
            --
            -- No subscription exists
            --
            select @version = 0
            return 0
        end
    end
    else
    begin
        --
        -- No subscription exists
        --
        select @version = 0
        return 0
    end
    --
    -- all done
    --
    return 0
end
go
exec sp_MS_marksystemobject sp_getsqlqueueversion
go


---------------------------------------------------------------------------
---------------------------------------------------------------------------

grant execute on dbo.sp_scriptpublicationcustomprocs to public
grant execute on dbo.sp_enumfullsubscribers to public
grant execute on dbo.sp_addpublication to public
grant execute on dbo.sp_changepublication to public
grant execute on dbo.sp_changesubscription to public
grant execute on dbo.sp_articlecolumn to public
grant execute on dbo.sp_helparticle to public
grant execute on dbo.sp_helparticlecolumns to public
grant execute on dbo.sp_helppublication to public
grant execute on dbo.sp_publication_validation to public
grant execute on dbo.sp_marksubscriptionvalidation to public
grant execute on dbo.sp_article_validation to public
grant execute on dbo.sp_helpsubscription to public
grant execute on dbo.sp_MSscript_article_view to public
grant execute on dbo.sp_articlefilter to public
grant execute on dbo.sp_articleview to public
grant execute on dbo.sp_addarticle to public
--grant execute on dbo.sp_MSgettranconflictname to public
--grant execute on dbo.sp_MSmaketrancftproc to public
--grant execute on dbo.sp_MSmakeconflicttable to public
grant execute on dbo.sp_scriptsubconflicttable to public
grant execute on dbo.sp_changesubstatus to public
grant execute on dbo.sp_addsubscription to public
grant execute on dbo.sp_changearticle to public
grant execute on dbo.sp_droparticle to public
grant execute on dbo.sp_droppublication to public
grant execute on dbo.sp_dropsubscription to public
grant execute on dbo.sp_subscribe to public
grant execute on dbo.sp_unsubscribe to public
grant execute on dbo.sp_refreshsubscriptions to public
grant execute on dbo.sp_reinitsubscription to public
--grant exec on dbo.sp_articlesynctranprocs to public
go

--grant exec on dbo.sp_gettypestring to public
--grant exec on dbo.sp_scriptpkwhereclause to public
--grant exec on dbo.sp_scriptupdateparams to public
--grant exec on dbo.sp_scriptreconwhereclause to public
grant exec on dbo.sp_script_reconciliation_insproc to public
grant exec on dbo.sp_script_reconciliation_delproc to public
grant exec on dbo.sp_script_reconciliation_xdelproc to public
grant exec on dbo.sp_scriptinsproc to public
grant exec on dbo.sp_scriptdelproc to public
grant exec on dbo.sp_scriptxdelproc to public
grant exec on dbo.sp_scriptupdproc to public
grant exec on dbo.sp_scriptmappedupdproc to public
grant exec on dbo.sp_scriptdynamicupdproc to public
grant exec on dbo.sp_scriptxupdproc to public
grant exec on dbo.sp_MSscriptmvastablenci to public
grant exec on dbo.sp_MSscriptmvastablepkc to public
grant exec on dbo.sp_MSscriptmvastableidx to public
grant exec on dbo.sp_MSscriptmvastable to public
grant exec on dbo.sp_script_synctran_commands to public
grant exec on dbo.sp_MSget_synctran_commands to public
grant exec on dbo.sp_MSactivate_auto_sub to public
grant exec on dbo.sp_dropanonymousagent to public
go

--grant execute on dbo.sp_MSscript_compensating_send to public
--grant execute on dbo.sp_MSscript_insert_statement to public
--grant execute on dbo.sp_MSscript_insert_subwins to public
--grant execute on dbo.sp_MSscript_insert_pubwins to public
--grant execute on dbo.sp_MSscript_update_statement to public
--grant execute on dbo.sp_MSscript_update_subwins to public
--grant execute on dbo.sp_MSscript_update_pubwins to public
--grant execute on dbo.sp_MSscript_delete_statement to public
--grant execute on dbo.sp_MSscript_delete_subwins to public
--grant execute on dbo.sp_MSscript_compensating_insert to public
--grant execute on dbo.sp_MSscript_delete_pubwins to public
--grant execute on dbo.sp_MSscript_beginproc  to public
--grant execute on dbo.sp_MSscript_security  to public
--grant execute on dbo.sp_MSscript_endproc  to public
grant execute on dbo.sp_MSscript_sync_ins_proc  to public
grant execute on dbo.sp_MSscript_sync_upd_proc  to public
grant execute on dbo.sp_MSscript_sync_del_proc  to public
--grant execute on dbo.sp_MSscript_ExecutionMode_stmt to public
grant execute on dbo.sp_MSscript_pub_upd_trig  to public
--grant execute on dbo.sp_MSmark_proc_norepl to public
grant execute on dbo.sp_MSpub_adjust_identity to public
grant execute on dbo.sp_helparticledts to public
grant execute on dbo.sp_changesubscriptiondtsinfo to public
grant execute on dbo.sp_MSvalidate_subscription to public
grant exec on dbo.sp_MScomputearticlescreationorder to public
grant exec on dbo.sp_MScomputeunresolvedrefs to public
go

grant execute on dbo.sp_MShelptranconflictpublications to public
grant execute on dbo.sp_MShelptranconflictcounts to public
grant execute on dbo.sp_MSgettranconflictrow to public
grant execute on dbo.sp_MSgettrancftsrcrow to public
grant execute on dbo.sp_MSdeletetranconflictrow to public
grant execute on dbo.sp_MSgetarticlereinitvalue to public
--grant execute on dbo.sp_MSispkupdateinconflict to public
grant execute on dbo.sp_ivindexhasnullcols to public
grant execute on dbo.fn_sqlvarbasetostr to public
grant execute on dbo.sp_replrestart to public
grant execute on dbo.sp_replsqlqgetrows to public
grant execute on dbo.sp_repldeletequeuedtran to public
grant execute on dbo.sp_MSrepl_schema to public
grant execute on dbo.sp_MSpost_auto_proc to public
grant execute on dbo.sp_MSreplupdateschema to public
grant execute on dbo.sp_MSdefer_check to public
grant execute on dbo.sp_MSreenable_check to public
grant execute on dbo.sp_getqueuedrows to public
grant execute on dbo.sp_MSprep_exclusive to public
grant execute on dbo.sp_MSexternalfkreferences to public
grant execute on dbo.sp_getqueuedarticlesynctraninfo to public
grant execute on dbo.sp_getsqlqueueversion to public
go 

dump tran master with no_log
go
sp_configure 'allow updates',0
go
reconfigure with override
go

print ''
print 'Checking objects created by repltran.sql.'
go

--obsolete   exec dbo.sp_check_objects 'repl'
-- exec dbo.sp_MS_upd_sysobj_category 2  --set sysobjects.category | 2 based on crdate.
go


print ''
print 'repltran.sql completed successfully.'
go

dump tran master with no_log
go
checkpoint
go
