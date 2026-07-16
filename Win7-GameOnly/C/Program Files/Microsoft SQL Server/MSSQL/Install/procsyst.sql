/*
** ProcSyst.SQL
** Copyright Microsoft, Inc. 1994 - 2000
** All Rights Reserved.
*/

go
use master
go
checkpoint
go
set nocount on
set implicit_transactions off
set ansi_nulls off
set quoted_identifier on	-- Force all ye devs to do this correctly!
go

declare @vdt varchar(99)
select  @vdt = convert(varchar,getdate(),113)
raiserror('Starting Install\ProcSyst.SQL at  %s',0,1,@vdt) with nowait
go

print ' '
print 'Making sure that updates to system tables are allowed.'
go

declare  @int1			integer
--dbcc getvalue('current_version')  --1=4.21A ,400-406=6.0 ,407-?=6.5, currently 408=7.0
--select @dbcc_current_version = @@error

if (     object_id('sp_configure','P') IS NOT NULL
    AND  1 <> (select value from syscurconfigs where config = 102)
   )
	begin						--Query tree compatible
	exec @int1 = sp_configure 'allow updates',1
	if @@error <> 0 or @int1 <> 0
		raiserror('Bad sp_configure exec at top of ProcSyst.SQL, killing spid.'
			,22,127) with log
	reconfigure with override
	end
go

---- Make sure server was started in single user mode or that sp_configure was used
----    to enable updates to system tables.

if (select value from syscurconfigs where config = 102) <> 1
	raiserror('Cannot run ProcSyst.SQL unless updates to system tables are enabled.  Shutdown server and restart with the ''-m'' option or use sp_configure to enable updates to system tables.'
			,22,127) with log
go

exec sp_MS_upd_sysobj_category 1  --Capture now_datetime for use below.

go

print ' '
print 'Dropping procedures that will be (re)created.'
go

----- ---

if object_id('sp_fallback_activate_svr','P') IS NOT NULL
	drop procedure sp_fallback_activate_svr
if object_id('sp_fallback_activate_svr_db','P') IS NOT NULL
	drop procedure sp_fallback_activate_svr_db

if object_id('sp_fallback_deactivate_svr','P') IS NOT NULL
	drop procedure sp_fallback_deactivate_svr
if object_id('sp_fallback_deactivate_svr_db','P') IS NOT NULL
	drop procedure sp_fallback_deactivate_svr_db

if object_id('sp_fallback_enroll_svr_db','P') IS NOT NULL
	drop procedure sp_fallback_enroll_svr_db

if object_id('sp_fallback_help','P') IS NOT NULL
	drop procedure sp_fallback_help

if object_id('sp_fallback_help_db_dev','P') IS NOT NULL
	drop procedure sp_fallback_help_db_dev

if object_id('sp_fallback_MS_enroll_db','P') IS NOT NULL
	drop procedure sp_fallback_MS_enroll_db

if object_id('sp_fallback_MS_enroll_dev','P') IS NOT NULL
	drop procedure sp_fallback_MS_enroll_dev

if object_id('sp_fallback_MS_enroll_usg','P') IS NOT NULL
	drop procedure sp_fallback_MS_enroll_usg

if object_id('sp_fallback_MS_sel_fb_svr','P') IS NOT NULL
	drop procedure sp_fallback_MS_sel_fb_svr

if object_id('sp_fallback_MS_verify_ri','P') IS NOT NULL
	drop procedure sp_fallback_MS_verify_ri

if object_id('sp_fallback_permanent_svr','P') IS NOT NULL
	drop procedure sp_fallback_permanent_svr

if object_id('sp_fallback_upd_dev_drive','P') IS NOT NULL
	drop procedure sp_fallback_upd_dev_drive

if object_id('sp_fallback_withdraw_svr_db','P') IS NOT NULL
	drop procedure sp_fallback_withdraw_svr_db


go
------------------------------------------------------------

if object_id('sp_a_count_bits_on','P') IS NOT NULL
		     drop procedure sp_a_count_bits_on

if object_id('sp_addextendedproc','P') IS NOT NULL
	drop procedure sp_addextendedproc

if object_id('sp_addmessage','P') IS NOT NULL
	drop procedure sp_addmessage

if object_id('sp_addremotelogin','P') IS NOT NULL
	drop procedure sp_addremotelogin

if object_id('sp_addsegment','P') IS NOT NULL
	drop procedure sp_addsegment
go

checkpoint
go

if object_id('sp_addtype','P') IS NOT NULL
	drop procedure sp_addtype

if object_id('sp_addumpdevice','P') IS NOT NULL
	drop procedure sp_addumpdevice

if object_id('sp_altermessage','P') IS NOT NULL
        drop procedure sp_altermessage

if object_id('sp_attach_db','P') IS NOT NULL
	drop procedure sp_attach_db

if object_id('sp_attach_single_file_db','P') IS NOT NULL
	drop procedure sp_attach_single_file_db
go

if object_id('sp_bindefault','P') IS NOT NULL
	drop procedure sp_bindefault

if object_id('sp_bindrule','P') IS NOT NULL
	drop procedure sp_bindrule

if object_id('sp_blockcnt','P') IS NOT NULL
	drop procedure sp_blockcnt

if object_id('sp_checknames','P') IS NOT NULL
	drop procedure sp_checknames
go

if object_id('sp_configure','P') IS NOT NULL
	drop procedure sp_configure

if object_id('sp_create_removable','P') IS NOT NULL
	drop procedure sp_create_removable

if object_id('sp_createstats','P') IS NOT NULL
	drop procedure sp_createstats

if object_id('sp_cycle_errorlog','P') IS NOT NULL
	drop procedure sp_cycle_errorlog

if object_id('sp_certify_removable','P') IS NOT NULL
	drop procedure sp_certify_removable

if object_id('sp_check_removable','P') IS NOT NULL
	drop procedure sp_check_removable

if object_id('sp_cnst_csr','P') IS NOT NULL
	drop procedure sp_cnst_csr

if object_id('sp_coalesce_fragments','P') IS NOT NULL
	drop procedure sp_coalesce_fragments

if object_id('sp_dboption','P') IS NOT NULL
	drop procedure sp_dboption

if object_id('sp_dbcmptlevel','P') IS NOT NULL
	drop procedure sp_dbcmptlevel

if object_id('sp_dbremove','P') IS NOT NULL
	drop procedure sp_dbremove

if object_id('sp_depends','P') IS NOT NULL
	drop procedure sp_depends

if object_id('sp_detach_db','P') IS NOT NULL
	drop procedure sp_detach_db

if object_id('sp_diskdefault','P') IS NOT NULL
	drop procedure sp_diskdefault
go

if object_id('sp_dropdevice','P') IS NOT NULL
	drop procedure sp_dropdevice

if object_id('sp_dropdumpdevice','P') IS NOT NULL
	drop procedure sp_dropdumpdevice

if object_id('sp_dropextendedproc','P') IS NOT NULL
	drop procedure sp_dropextendedproc
go

if object_id('sp_dropmessage','P') IS NOT NULL
	drop procedure sp_dropmessage

if object_id('sp_droptype','P') IS NOT NULL
	drop procedure sp_droptype

if object_id('sp_dropremotelogin','P') IS NOT NULL
	drop procedure sp_dropremotelogin

if object_id('sp_dropsegment','P') IS NOT NULL
	drop procedure sp_dropsegment

if object_id('sp_extendsegment','P') IS NOT NULL
	drop procedure sp_extendsegment
go

if object_id('sp_help','P') IS NOT NULL
	drop procedure sp_help

if object_id('sp_help_revdatabase','P') IS NOT NULL
		     drop procedure sp_help_revdatabase

if object_id('sp_helpconstraint','P') IS NOT NULL
	drop procedure sp_helpconstraint

if object_id('sp_helpdb','P') IS NOT NULL
	drop procedure sp_helpdb

if object_id('sp_helpdevice','P') IS NOT NULL
	drop procedure sp_helpdevice

if object_id('sp_helpextendedproc','P') IS NOT NULL
	drop procedure sp_helpextendedproc

if object_id('sp_helpfile','P') IS NOT NULL
	drop procedure sp_helpfile

if object_id('sp_helpfilegroup','P') IS NOT NULL
	drop procedure sp_helpfilegroup

if object_id('sp_helpgroup','P') IS NOT NULL
	drop procedure sp_helpgroup

if object_id('sp_helpindex','P') IS NOT NULL
	drop procedure sp_helpindex

if object_id('sp_helpstats','P') IS NOT NULL
	drop procedure sp_helpstats
go

if exists (select * from sysobjects
	   where xtype = N'IF' and uid = USER_ID('system_function_schema') and
		name = 'fn_dblog')
	drop function system_function_schema.fn_dblog
go

if exists (select * from sysobjects
	   where xtype = N'TF' and uid = USER_ID('system_function_schema') and
		name = 'fn_helpcollations')
	drop function system_function_schema.fn_helpcollations
go

if exists (select * from sysobjects
	   where xtype = N'TF' and uid = USER_ID('system_function_schema') and
		name = 'fn_trace_getinfo')
	drop function system_function_schema.fn_trace_getinfo
go

if exists (select * from sysobjects
	   where xtype = N'IF' and uid = USER_ID('system_function_schema') and
		name = 'fn_trace_gettable')
	drop function system_function_schema.fn_trace_gettable
go

if exists (select * from sysobjects
	   where xtype = N'TF' and uid = USER_ID('system_function_schema') and
		name = 'fn_trace_geteventinfo')
	drop function system_function_schema.fn_trace_geteventinfo
go

if exists (select * from sysobjects
	   where xtype = N'TF' and uid = USER_ID('system_function_schema') and
		name = 'fn_trace_getfilterinfo')
	drop function system_function_schema.fn_trace_getfilterinfo
go

if exists (select * from sysobjects
	   where xtype = N'TF' and uid = USER_ID('system_function_schema') and
		name = 'fn_databaseproperties')
	drop function system_function_schema.fn_databaseproperties
go

if exists (select * from sysobjects
	   where xtype = N'TF' and uid = USER_ID('system_function_schema') and
		name = 'fn_servershareddrives')
	drop function system_function_schema.fn_servershareddrives
go

if exists (select * from sysobjects
	   where xtype = N'TF' and uid = USER_ID('system_function_schema') and
		name = 'fn_virtualfilestats')
	drop function system_function_schema.fn_virtualfilestats
go

if exists (select * from sysobjects
	   where xtype = N'TF' and uid = USER_ID('system_function_schema') and
		name = 'fn_virtualservernodes')
	drop function system_function_schema.fn_virtualservernodes
go

if exists (select * from sysobjects
	   where xtype = N'TF' and uid = USER_ID('system_function_schema') and
		name = 'fn_get_sql')
	drop function system_function_schema.fn_get_sql
go

checkpoint
go

if object_id('sp_helplanguage','P') IS NOT NULL
	drop procedure sp_helplanguage

if object_id('sp_helplog','P') IS NOT NULL
	drop procedure sp_helplog

if object_id('sp_helplogins','P') IS NOT NULL
		     drop procedure sp_helplogins

if object_id('sp_helprotect','P') IS NOT NULL
	drop procedure sp_helprotect

if object_id('sp_helptext','P') IS NOT NULL
	drop procedure sp_helptext

if object_id('sp_helpuser','P') IS NOT NULL
	drop procedure sp_helpuser

if object_id('sp_helpremotelogin','P') IS NOT NULL
	drop procedure sp_helpremotelogin

if object_id('sp_helpsegment','P') IS NOT NULL
	drop procedure sp_helpsegment

if object_id('sp_helpsort','P') IS NOT NULL
	drop procedure sp_helpsort

if object_id('sp_helpsql','P') IS NOT NULL
	drop procedure sp_helpsql

if object_id('sp_indexoption','P') IS NOT NULL
	drop procedure sp_indexoption

if object_id('sp_lock','P') IS NOT NULL
	drop procedure sp_lock

if object_id('sp_getapplock','P') IS NOT NULL
	drop procedure sp_getapplock

if object_id('sp_releaseapplock','P') IS NOT NULL
	drop procedure sp_releaseapplock
go

if object_id('sp_logdevice','P') IS NOT NULL
	drop procedure sp_logdevice

if object_id('sp_monitor','P') IS NOT NULL
	drop procedure sp_monitor

if object_id('sp_namecrack','P') IS NOT NULL
	drop procedure sp_namecrack

if object_id('sp_namecrack_qi','P') IS NOT NULL
	drop procedure sp_namecrack_qi

if object_id('sp_objectfilegroup','P') IS NOT NULL
	drop procedure sp_objectfilegroup

if object_id('sp_placeobject','P') IS NOT NULL
	drop procedure sp_placeobject

if object_id('sp_procoption','P') IS NOT NULL
	drop procedure sp_procoption

if object_id('sp_processmail','P') IS NOT NULL
	drop procedure sp_processmail
go

if object_id('sp_recompile','P') IS NOT NULL
	drop procedure sp_recompile

if object_id('sp_remoteoption','P') IS NOT NULL
	drop procedure sp_remoteoption

if object_id('sp_rename','P') IS NOT NULL
	drop procedure sp_rename

if object_id('sp_renamedb','P') IS NOT NULL
	drop procedure sp_renamedb

if object_id('sp_remove_tempdb_file','P') IS NOT NULL
        drop procedure sp_remove_tempdb_file

if object_id('sp_resetstatus','P') IS NOT NULL
   drop procedure sp_resetstatus
go

if object_id('sp_add_file_recover_suspect_db','P') IS NOT NULL
	drop procedure sp_add_file_recover_suspect_db

if object_id('sp_add_data_file_recover_suspect_db','P') IS NOT NULL
	drop procedure sp_add_data_file_recover_suspect_db

if object_id('sp_add_log_file_recover_suspect_db','P') IS NOT NULL
	drop procedure sp_add_log_file_recover_suspect_db
go

if object_id('sp_spaceused','P') IS NOT NULL
	drop procedure sp_spaceused

if object_id('sp_checktabletempsize', 'P') IS NOT NULL
	drop procedure sp_checktabletempsize

if object_id('sp_checkdbtempsize', 'P') IS NOT NULL
	drop procedure sp_checkdbtempsize

if object_id('sp_sqlexec','P') IS NOT NULL
	drop procedure sp_sqlexec
go

if object_id('sp_tableoption','P') IS NOT NULL
	drop procedure sp_tableoption

if object_id('sp_invalidate_textptr','P') IS NOT NULL
	drop procedure sp_invalidate_textptr

if object_id('sp_tempdbspace','P') IS NOT NULL
	drop procedure sp_tempdbspace

if object_id('sp_unbindefault','P') IS NOT NULL
	drop procedure sp_unbindefault

if object_id('sp_unbindrule','P') IS NOT NULL
	drop procedure sp_unbindrule


if object_id('sp_user_counter1','P') IS NOT NULL
        drop procedure sp_user_counter1
if object_id('sp_user_counter2','P') IS NOT NULL
        drop procedure sp_user_counter2
if object_id('sp_user_counter3','P') IS NOT NULL
        drop procedure sp_user_counter3
if object_id('sp_user_counter4','P') IS NOT NULL
        drop procedure sp_user_counter4
if object_id('sp_user_counter5','P') IS NOT NULL
        drop procedure sp_user_counter5
if object_id('sp_user_counter6','P') IS NOT NULL
        drop procedure sp_user_counter6
if object_id('sp_user_counter7','P') IS NOT NULL
        drop procedure sp_user_counter7
if object_id('sp_user_counter8','P') IS NOT NULL
        drop procedure sp_user_counter8
if object_id('sp_user_counter9','P') IS NOT NULL
        drop procedure sp_user_counter9
if object_id('sp_user_counter10','P') IS NOT NULL
        drop procedure sp_user_counter10
go


if object_id('sp_validaltlang','P') IS NOT NULL
	drop procedure sp_validaltlang

if object_id('sp_validlang','P') IS NOT NULL
	drop procedure sp_validlang

if object_id('sp_validname','P') IS NOT NULL
	drop procedure sp_validname

if object_id('sp_who','P') IS NOT NULL
	drop procedure sp_who

if object_id('sp_who2','P') IS NOT NULL
	drop procedure sp_who2
go

if object_id('sp_updatestats','P') IS NOT NULL
	drop procedure sp_updatestats
go

if object_id('sp_autostats','P') IS NOT NULL
	drop procedure sp_autostats
go

if object_id('sp_helptrigger','P') IS NOT NULL
	drop procedure sp_helptrigger
go

if object_id('sp_dropextendedproperty','P') IS NOT NULL
	drop procedure sp_dropextendedproperty
if object_id('sp_addextendedproperty','P') IS NOT NULL
	drop procedure sp_addextendedproperty
if object_id('sp_updateextendedproperty','P') IS NOT NULL
	drop procedure sp_updateextendedproperty
if object_id('sp_validatepropertyinputs','P') IS NOT NULL
	drop procedure sp_validatepropertyinputs
if exists (select * from sysobjects
	   where xtype = N'TF' and uid = USER_ID('system_function_schema') and
		name = 'fn_listextendedproperty')
	drop function system_function_schema.fn_listextendedproperty
go

if object_id('sp_fixindex','P') IS NOT NULL
	drop procedure sp_fixindex
go

if object_id('MS_sqlctrs_users','P') IS NOT NULL
    drop proc MS_sqlctrs_users
go

checkpoint
go


-------------------------
 -- create XP early for sysdepends
raiserror('Special section to create extended procs early for sysdepends...',0,1)
go


raiserror(15339,-1,-1,'sp_dropextendedproc')
go
create procedure sp_dropextendedproc --- 1996/08/30 20:13
@functname nvarchar(517) -- name of function
as
/*
**  If we're in a transaction, disallow the dropping of the
**  extended stored procedure.
*/
set implicit_transactions off
if @@trancount > 0
	begin
		raiserror(15002,-1,-1,'sp_dropextendedproc')
		return (1)
	end

/*
** Drop the extended procedure mapping.
*/
dbcc dropextendedproc( @functname )
return (0) -- sp_dropextendedproc
go



raiserror(15339,-1,-1,'sp_addextendedproc')
go
create procedure sp_addextendedproc --- 1996/08/30 20:13
@functname nvarchar(517),		/* (owner.)name of function to call */
@dllname varchar(255)		/* name of DLL containing function */
as
/*
**  If we're in a transaction, disallow the addition of the
**  extended stored procedure.
*/
set implicit_transactions off
if @@trancount > 0
begin
	raiserror(15002,-1,-1,'sp_addextendedproc')
	return (1)
end

-- Disallow 0-length string & NULL
if @dllname is null or datalength(@dllname) = 0
begin
	raiserror(15311,-1,-1,@dllname)
	return (1)
end

/*
** Create the extended procedure mapping.
*/
dbcc addextendedproc( @functname, @dllname)
return (0) -- sp_addextendedproc
go


raiserror(15339,-1,-1,'sp_helpextendedproc')
go
create procedure sp_helpextendedproc --- 1996/08/14 15:53
@funcname sysname = NULL
as

set nocount on

if (select count(*) from master.dbo.sysobjects where xtype = N'X ') = 0
	begin
		raiserror(15326,-1,-1)
		return (0)
	end


if @funcname is not null
begin
	/*
	**  Make sure the function name exists
	*/
	if not exists (select * from master.dbo.sysobjects
			where xtype = N'X '
			  and name = @funcname)
	begin
		raiserror(15019,-1,-1,@funcname)
		return (1)
	end
	/*print out select function name info*/
	select distinct name = o.name, dll = substring(c.text,1,255)
	from master.dbo.sysobjects o, master.dbo.syscomments c
	where o.id = c.id
		and o.name = @funcname
		and o.xtype = N'X '
	order by o.name
end
else
/*
**  or print out all function name info
*/
select distinct name = o.name, dll = substring(c.text,1,255)
	from master.dbo.sysobjects o, master.dbo.syscomments c
	where o.id = c.id
		and o.xtype = N'X '
	order by o.name

return (0) -- sp_helpextendedproc
go


---------------------------------------------------------------
raiserror('Now done creating the general system stored procs.  Start with miscellaneous tasks like xp_ and grants.',0,1)
---------------------------------------------------------------
go

---- Drop extended procs if they already exist now that sp_dropextendedproc has been created.

print ' '
print 'Dropping any existing extended stored procedures.'
go

if object_id('xp_addattach','X') IS NOT NULL
	exec sp_dropextendedproc 'xp_addattach'

if object_id('xp_addmsgline','X') IS NOT NULL
	exec sp_dropextendedproc 'xp_addmsgline'

if object_id('xp_cmdshell','X') IS NOT NULL
	exec sp_dropextendedproc 'xp_cmdshell'

if object_id('sp_cursor','X') IS NOT NULL
	exec sp_dropextendedproc 'sp_cursor'

if object_id('xp_userlock','X') IS NOT NULL
	exec sp_dropextendedproc 'xp_userlock'

if object_id('sp_cursorclose','X') IS NOT NULL
	exec sp_dropextendedproc 'sp_cursorclose'

if object_id('sp_cursorfetch','X') IS NOT NULL
	exec sp_dropextendedproc 'sp_cursorfetch'

if object_id('sp_cursoropen','X') IS NOT NULL
	exec sp_dropextendedproc 'sp_cursoropen'

if object_id('sp_cursoroption','X') IS NOT NULL
	exec sp_dropextendedproc 'sp_cursoroption'

if object_id('xp_deletemail','X') IS NOT NULL
	exec sp_dropextendedproc 'xp_deletemail'

if object_id('xp_enumgroups','X') IS NOT NULL
	exec sp_dropextendedproc 'xp_enumgroups'

if object_id('xp_findnextmsg','X') IS NOT NULL
	exec sp_dropextendedproc 'xp_findnextmsg'

if object_id('xp_logevent','X') IS NOT NULL
	exec sp_dropextendedproc 'xp_logevent'

if object_id('xp_loginconfig','X') IS NOT NULL
	exec sp_dropextendedproc 'xp_loginconfig'

if object_id('xp_logininfo','X') IS NOT NULL
	exec sp_dropextendedproc 'xp_logininfo'

if object_id('xp_loginmail','X') IS NOT NULL
	exec sp_dropextendedproc 'xp_loginmail'

if object_id('xp_logoffmail','X') IS NOT NULL
	exec sp_dropextendedproc 'xp_logoffmail'

if object_id('xp_mailproclist','X') IS NOT NULL
	exec sp_dropextendedproc 'xp_mailproclist'

if object_id('xp_msver','X') IS NOT NULL
	exec sp_dropextendedproc 'xp_msver'

if object_id('xp_prepmsg','X') IS NOT NULL
	exec sp_dropextendedproc 'xp_prepmsg'

if object_id('xp_readmail','X') IS NOT NULL
	exec sp_dropextendedproc 'xp_readmail'

if object_id('xp_sendmail','X') IS NOT NULL
	exec sp_dropextendedproc 'xp_sendmail'

if object_id('xp_sendmsg','X') IS NOT NULL
	exec sp_dropextendedproc 'xp_sendmsg'

if object_id('xp_sprintf','X') IS NOT NULL
	exec sp_dropextendedproc 'xp_sprintf'

if object_id('xp_sscanf','X') IS NOT NULL
	exec sp_dropextendedproc 'xp_sscanf'

if object_id('xp_startmail','X') IS NOT NULL
	exec sp_dropextendedproc 'xp_startmail'

if object_id('xp_stopmail','X') IS NOT NULL
	exec sp_dropextendedproc 'xp_stopmail'

if object_id('xp_get_mapi_default_profile','X') IS NOT NULL
	exec sp_dropextendedproc 'xp_get_mapi_default_profile'

if object_id('xp_get_mapi_profiles','X') IS NOT NULL
	exec sp_dropextendedproc 'xp_get_mapi_profiles'

if object_id('xp_test_mapi_profile','X') IS NOT NULL
	exec sp_dropextendedproc 'xp_test_mapi_profile'
go

if object_id('sp_bindsession','X') IS NOT NULL
	exec sp_dropextendedproc 'sp_bindsession'

if object_id('sp_getbindtoken','X') IS NOT NULL
	exec sp_dropextendedproc 'sp_getbindtoken'

if object_id('sp_createorphan','X') IS NOT NULL
	exec sp_dropextendedproc 'sp_createorphan'

if object_id('sp_droporphans','X') IS NOT NULL
	exec sp_dropextendedproc 'sp_droporphans'

if object_id('sp_sdidebug','X') IS NOT NULL
	exec sp_dropextendedproc 'sp_sdidebug'

if object_id('sp_executesql','X') IS NOT NULL
	exec sp_dropextendedproc 'sp_executesql'

if object_id('sp_stmtpermissions','X') IS NOT NULL
	exec sp_dropextendedproc 'sp_stmtpermissions'

if object_id('sp_objpermissions','X') IS NOT NULL
	exec sp_dropextendedproc 'sp_objpermissions'

if object_id('sp_prepare','X') IS NOT NULL
	exec sp_dropextendedproc 'sp_prepare'

if object_id('sp_execute','X') IS NOT NULL
	exec sp_dropextendedproc 'sp_execute'

if object_id('sp_prepexec','X') IS NOT NULL
	exec sp_dropextendedproc 'sp_prepexec'

if object_id('sp_prepexecrpc','X') IS NOT NULL
	exec sp_dropextendedproc 'sp_prepexecrpc'

if object_id('sp_unprepare','X') IS NOT NULL
	exec sp_dropextendedproc 'sp_unprepare'

if object_id('sp_cursorprepare','X') IS NOT NULL
	exec sp_dropextendedproc 'sp_cursorprepare'

if object_id('sp_cursorexecute','X') IS NOT NULL
	exec sp_dropextendedproc 'sp_cursorexecute'

if object_id('sp_cursorprepexec','X') IS NOT NULL
	exec sp_dropextendedproc 'sp_cursorprepexec'

if object_id('sp_cursorunprepare','X') IS NOT NULL
	exec sp_dropextendedproc 'sp_cursorunprepare'

if object_id('sp_reset_connection','X') IS NOT NULL
	exec sp_dropextendedproc 'sp_reset_connection'

if object_id('sp_getschemalock','X') IS NOT NULL
	exec sp_dropextendedproc 'sp_getschemalock'

if object_id('sp_releaseschemalock','X') IS NOT NULL
	exec sp_dropextendedproc 'sp_releaseschemalock'

if object_id('sp_xml_preparedocument','X') IS NOT NULL
	exec sp_dropextendedproc 'sp_xml_preparedocument'

if object_id('sp_xml_removedocument','X') IS NOT NULL
	exec sp_dropextendedproc 'sp_xml_removedocument'

-- The following four extended procs only appear in shiloh beta 1
if object_id('sp_xml_insertfromxml','X') IS NOT NULL
	exec sp_dropextendedproc 'sp_xml_insertfromxml'

if object_id('sp_xml_fetchintoxml','X') IS NOT NULL
	exec sp_dropextendedproc 'sp_xml_fetchintoxml'

if object_id('sp_xml_removexml','X') IS NOT NULL
	exec sp_dropextendedproc 'sp_xml_removexml'

if object_id('sp_xml_fetchdocument','X') IS NOT NULL
	exec sp_dropextendedproc 'sp_xml_fetchdocument'

if object_id('sp_resyncprepare','X') IS NOT NULL
	exec sp_dropextendedproc 'sp_resyncprepare'

if object_id('sp_resyncexecute','X') IS NOT NULL
	exec sp_dropextendedproc 'sp_resyncexecute'

if object_id('sp_resyncexecutesql','X') IS NOT NULL
	exec sp_dropextendedproc 'sp_resyncexecutesql'

if object_id('sp_resyncuniquetable','X') IS NOT NULL
	exec sp_dropextendedproc 'sp_resyncuniquetable'

if object_id('sp_trace_create','X') IS NOT NULL
	exec sp_dropextendedproc 'sp_trace_create'

if object_id('sp_trace_setevent','X') IS NOT NULL
	exec sp_dropextendedproc 'sp_trace_setevent'

if object_id('sp_trace_setfilter','X') IS NOT NULL
	exec sp_dropextendedproc 'sp_trace_setfilter'

if object_id('sp_trace_setstatus','X') IS NOT NULL
	exec sp_dropextendedproc 'sp_trace_setstatus'

if object_id('sp_trace_generateevent','X') IS NOT NULL
	exec sp_dropextendedproc 'sp_trace_generateevent'


go


-- Add extended stored procedures.
print ' '
print 'Adding extended stored procedures.'
go

execute sp_addextendedproc 'xp_cmdshell'	,'xplog70.dll'
execute sp_addextendedproc 'xp_logevent'	,'xplog70.dll'
execute sp_addextendedproc 'xp_sprintf'	,'xplog70.dll'
execute sp_addextendedproc 'xp_sscanf'		,'xplog70.dll'
execute sp_addextendedproc 'xp_msver'		,'xplog70.dll'
execute sp_addextendedproc 'xp_enumgroups'	,'xplog70.dll'
go

-- Add mail enabling extended procedures
--
-- IA64 related change. Due to missing libraries from Exchange SQLMail procs 
-- won't be available for Liberty B-1. Bug #352141
--
-- Stub will be there and will display a descriptive message
-- Bug #360731
--
execute sp_addextendedproc 'xp_startmail'                ,'sqlmap70.dll'
execute sp_addextendedproc 'xp_stopmail'                 ,'sqlmap70.dll'
execute sp_addextendedproc 'xp_sendmail'                 ,'sqlmap70.dll'
execute sp_addextendedproc 'xp_deletemail'               ,'sqlmap70.dll'
execute sp_addextendedproc 'xp_findnextmsg'              ,'sqlmap70.dll'
execute sp_addextendedproc 'xp_readmail'                 ,'sqlmap70.dll'
execute sp_addextendedproc 'xp_get_mapi_default_profile' ,'sqlmap70.dll'
execute sp_addextendedproc 'xp_get_mapi_profiles'        ,'sqlmap70.dll'
execute sp_addextendedproc 'xp_test_mapi_profile'        ,'sqlmap70.dll'

go

--Add extended stored procedures for NT integrated login security.
--
execute sp_addextendedproc 'xp_loginconfig'	,'xplog70.dll'
go

-- Add extended stored procedures for cursor support.
--
execute sp_addextendedproc 'sp_cursor'		,'(server internal)'
execute sp_addextendedproc 'sp_cursorclose'	,'(server internal)'
execute sp_addextendedproc 'sp_cursorfetch'	,'(server internal)'
execute sp_addextendedproc 'sp_cursoropen'	,'(server internal)'
execute sp_addextendedproc 'sp_cursoroption'	,'(server internal)'
go

-- Add extended stored procedures for bound session support.
--
execute sp_addextendedproc 'sp_bindsession'	,'(server internal)'
execute sp_addextendedproc 'sp_getbindtoken'	,'(server internal)'
go

-- Add extended stored procedures for orphaned text support for ODBC
--
execute sp_addextendedproc 'sp_createorphan' ,'(server internal)'
execute sp_addextendedproc 'sp_droporphans' ,'(server internal)'
go

-- Add extended stored procedures for XML text support
--
execute sp_addextendedproc 'sp_xml_preparedocument' ,'(server internal)'
execute sp_addextendedproc 'sp_xml_removedocument' ,'(server internal)'

go

-- Add extended stored procedures for SQLTrace support
--
execute sp_addextendedproc 'sp_trace_create'		,'(server internal)'
execute sp_addextendedproc 'sp_trace_setevent'		,'(server internal)'
execute sp_addextendedproc 'sp_trace_setfilter'		,'(server internal)'
execute sp_addextendedproc 'sp_trace_setstatus'		,'(server internal)'
execute sp_addextendedproc 'sp_trace_generateevent'	,'(server internal)'
go

-- This xproc will be used for SQL debugging and will be invoked either via RPC or SQL language.
--
execute sp_addextendedproc 'sp_sdidebug'	,'(server internal)'
go

-- This xproc will be used for server support for Prepare-Execute
--
execute sp_addextendedproc 'sp_executesql'	,'(server internal)'
go

-- Add extended stored procedures for application locks
--
execute sp_addextendedproc 'xp_userlock'	,'(server internal)'
go

-- Starfter requested security proc
--
execute sp_addextendedproc 'sp_prepare'	,'(server internal)'
go
execute sp_addextendedproc 'sp_execute'	,'(server internal)'
go
execute sp_addextendedproc 'sp_prepexec'	,'(server internal)'
go
execute sp_addextendedproc 'sp_prepexecrpc'	,'(server internal)'
go
execute sp_addextendedproc 'sp_unprepare'	,'(server internal)'
go
execute sp_addextendedproc 'sp_cursorprepare'	,'(server internal)'
go
execute sp_addextendedproc 'sp_cursorexecute'	,'(server internal)'
go
execute sp_addextendedproc 'sp_cursorprepexec'	,'(server internal)'
go
execute sp_addextendedproc 'sp_cursorunprepare'	,'(server internal)'
go

-- This xproc will be used for server support for connection-caching
--
execute sp_addextendedproc 'sp_reset_connection','(server internal)'
go

-- This xproc will be used for server support of schema locks
execute sp_addextendedproc 'sp_getschemalock','(server internal)'
execute sp_addextendedproc 'sp_releaseschemalock','(server internal)'
go

-- Add the access resync query extended proc
execute sp_addextendedproc 'sp_resyncprepare'	,'(server internal)'
go
execute sp_addextendedproc 'sp_resyncexecute'	,'(server internal)'
go
execute sp_addextendedproc 'sp_resyncexecutesql'	,'(server internal)'
go
execute sp_addextendedproc 'sp_resyncuniquetable'	,'(server internal)'
go

-- UPDATE A VIEW'S METADATA TO REFLECT CHANGES IN UNDERLYING TABLES --
if object_id('sp_refreshview','X') IS NOT NULL
	exec sp_dropextendedproc 'sp_refreshview'
execute sp_addextendedproc 'sp_refreshview','(server internal)'
grant execute on sp_refreshview to public
go

-- SP_SETLOGIN USED BY AGENT
if object_id('sp_setuserbylogin','X') IS NOT NULL
	exec sp_dropextendedproc 'sp_setuserbylogin'
execute sp_addextendedproc 'sp_setuserbylogin','(server internal)'
go
grant execute on sp_setuserbylogin to public
go
exec sp_MS_marksystemobject 'sp_setuserbylogin'
go

-------------------------------------
raiserror('Creating the general purpose System Stored Procedures ....',0,1)
-------------------------------------
go


raiserror(15339,-1,-1,'sp_user_counter1 - N')
go

create proc sp_user_counter1 @newvalue int as
dbcc setinstance ('SQLServer:User Settable', 'Query', 'User counter 1', @newvalue)
go
create proc sp_user_counter2 @newvalue int as
dbcc setinstance ('SQLServer:User Settable', 'Query', 'User counter 2', @newvalue)
go
create proc sp_user_counter3 @newvalue int as
dbcc setinstance ('SQLServer:User Settable', 'Query', 'User counter 3', @newvalue)
go
create proc sp_user_counter4 @newvalue int as
dbcc setinstance ('SQLServer:User Settable', 'Query', 'User counter 4', @newvalue)
go
create proc sp_user_counter5 @newvalue int as
dbcc setinstance ('SQLServer:User Settable', 'Query', 'User counter 5', @newvalue)
go
create proc sp_user_counter6 @newvalue int as
dbcc setinstance ('SQLServer:User Settable', 'Query', 'User counter 6', @newvalue)
go
create proc sp_user_counter7 @newvalue int as
dbcc setinstance ('SQLServer:User Settable', 'Query', 'User counter 7', @newvalue)
go
create proc sp_user_counter8 @newvalue int as
dbcc setinstance ('SQLServer:User Settable', 'Query', 'User counter 8', @newvalue)
go
create proc sp_user_counter9 @newvalue int as
dbcc setinstance ('SQLServer:User Settable', 'Query', 'User counter 9', @newvalue)
go
create proc sp_user_counter10 @newvalue int as
dbcc setinstance ('SQLServer:User Settable', 'Query', 'User counter 10', @newvalue)
go


--perfmon
raiserror(15339,-1,-1,'sp_blockcnt')
go
create procedure sp_blockcnt --- 1996/04/08 00:00
as
select blockedusers=count(*) from master.dbo.sysprocesses where blocked <> 0
go



--new query to watch max tempdbspace from perfmon
raiserror(15339,-1,-1,'sp_tempdbspace')
go
create proc sp_tempdbspace --- 1996/04/08 00:00
as

declare @dbsize dec(15,0)
declare @freespace dec(15,0)
declare @spaceused dec(15,0)

select @dbsize = sum(convert(dec(15),size))
               from tempdb.dbo.sysfiles

select  database_name = 'tempdb',
               database_size = (@dbsize / 128),
	       spaceused=(select (sum(convert(dec(15),reserved))/128)
               	from tempdb..sysindexes
		where indid in (0, 1, 255))
go




raiserror(15339,-1,-1,'sp_dboption')
go
/*ANSI_NULLS ON  for creation of sp_dboption*/
set ansi_nulls on
go
create procedure sp_dboption  -- 1999/08/09 18:25
@dbname sysname = NULL,     /* database name to change */
@optname varchar(35) = NULL,  /* option name to turn on/off */
@optvalue varchar(10) = NULL  /* true or false */
as

set nocount    on

declare @dbid int         /* dbid of the database */
declare @catvalue int     /* number of category option */
declare @optcount int      /* number of options like @optname */
declare @allstatopts int    /* bit map off all options stored in sysdatqabases.status
							** that can be set by sp_dboption. */
declare @alloptopts int    /* bit map off all options stored in sysdatqabases.status
							** that can be set by sp_dboption. */
declare @allcatopts int    /* bit map off all options stored in sysdatqabases.category
							** that can be set by sp_dboption. */
declare @exec_stmt nvarchar(550)
declare @fulloptname varchar(35)
declare @alt_optname varchar(50)
declare @alt_optvalue varchar(30)

declare @status int

/*
**  If no @dbname given, just list the possible dboptions.
**  Only certain status bits may be set or cleared by sp_dboption.
*/

/*
** Get bitmap of all options that can be set by sp_dboption.
*/
select @allstatopts=number from master.dbo.spt_values where type = 'D'
   and name = 'ALL SETTABLE OPTIONS'

select @allcatopts=number from master.dbo.spt_values where type = 'DC'
   and name = 'ALL SETTABLE OPTIONS'

select @alloptopts=number from master.dbo.spt_values where type = 'D2'
   and name = 'ALL SETTABLE OPTIONS'

if @dbname is null
begin
   select 'Settable database options:' = name
      from master.dbo.spt_values
      where (type = 'D'
            and number & @allstatopts <> 0
            and number not in (0,@allstatopts))  /* Eliminate non-option entries */
		 or (type = 'DC'
            and number & @allcatopts <> 0
            and number not in (0,@allcatopts))
		 or (type = 'D2'
            and number & @alloptopts <> 0
            and number not in (0,@alloptopts))
      order by name
   return (0)
end

/*
**  Verify the database name and get info
*/
select @dbid = dbid
from master.dbo.sysdatabases
where name = @dbname

/*
**  If @dbname not found, say so and list the databases.
*/
if @dbid is null
   begin
      raiserror(15010,-1,-1,@dbname)
      print ' '
      select 'Available databases:' = name
         from master.dbo.sysdatabases
      return (1)
   end

/*
** If no option was supplied, display current settings.
*/
if @optname is null
   begin
      select 'The following options are set:' = v.name
         from master.dbo.spt_values v, master.dbo.sysdatabases d
            where d.name=@dbname
               and ((number & @allstatopts <> 0
			         and number not in (-1,@allstatopts)
                     and v.type = 'D'
                     and (v.number & d.status)=v.number)
                 or (number & @allcatopts <> 0
			         and number not in (-1,@allcatopts)
                     and v.type = 'DC'
                     and d.category & v.number <> 0)
                 or (number & @alloptopts <> 0
			         and number not in (-1,@alloptopts)
                     and v.type = 'D2'
                     and d.status2 & v.number <> 0))
      return(0)
   end


if lower(@optvalue) not in ('true', 'false', 'on', 'off') and @optvalue is not null
   begin
      raiserror(15241,-1,-1)
      return (1)
   end

/*
**  Use @optname and try to find the right option.
**  If there isn't just one, print appropriate diagnostics and return.
*/
select @optcount = count(*) ,@fulloptname = min(name)
      from master.dbo.spt_values
      where lower(name) like '%' + lower(@optname) + '%'
         and ((type = 'D'
              and number & @allstatopts <> 0
              and number not in (-1,@allstatopts))
		  or (type = 'DC'
              and number & @allcatopts <> 0
              and number not in (-1,@allcatopts))
			or (type = 'D2'
              and number & @alloptopts <> 0
              and number not in (-1,@alloptopts)))

/*
**  If no option, show the user what the options are.
*/
if @optcount = 0
   begin
      raiserror(15011,-1,-1,@optname)
      print ' '

      select 'Settable database options:' = name
         from master.dbo.spt_values
         where (type = 'D'
               and number & @allstatopts <> 0
               and number not in (-1,@allstatopts))  /* Eliminate non-option entries */
            or (type = 'DC'
               and number & @allcatopts <> 0
               and number not in (-1,@allcatopts))
            or (type = 'D2'
               and number & @alloptopts <> 0
               and number not in (-1,@alloptopts))
		 order by name

      return (1)
   end


/*
**  If more than one option like @optname, show the duplicates and return.
*/
if @optcount > 1
   begin
      raiserror(15242,-1,-1,@optname)
      print ' '

      select duplicate_options = name
         from master.dbo.spt_values
         where lower(name) like '%' + lower(@optname) + '%'
            and ((type = 'D'
                 and number & @allstatopts <> 0
                 and number not in (-1,@allstatopts))
		      or (type = 'DC'
                 and number & @allcatopts <> 0
                 and number not in (-1,@allcatopts))
			  or (type = 'D2'
                 and number & @alloptopts <> 0
                 and number not in (-1,@alloptopts))
                )
      return (1)
   end


/*
**  Just want to see current setting of specified option.
*/
if @optvalue is null
begin
      select OptionName = v.name

            ,CurrentSetting =
               CASE
                  When ( ((v.number & d.status) = v.number
				          and v.type = 'D')
                      or (d.category & v.number <> 0
					       and v.type = 'DC')
                      or (d.status2 & v.number <> 0
					       and v.type = 'D2')
                       )
                     Then 'ON'
                  When NOT
                       ( ((v.number & d.status) = v.number
				          and v.type = 'D')
                      or (d.category & v.number <> 0
					       and v.type = 'DC')
                      or (d.status2 & v.number <> 0
					       and v.type = 'D2')
                       )
                     Then 'off'
               END

         from master.dbo.spt_values v, master.dbo.sysdatabases d
            where d.name=@dbname
               and ((v.number & @allstatopts <> 0
                     and v.number not in (-1,@allstatopts)   /* Eliminate non-option entries */
                     and v.type = 'D')
                 or (v.number & @allcatopts <> 0
                     and v.number not in (-1,@allcatopts)   /* Eliminate non-option entries */
                     and v.type = 'DC')
                 or (v.number & @alloptopts <> 0
                     and v.number not in (-1,@alloptopts)   /* Eliminate non-option entries */
                     and v.type = 'D2')
				   )
				and lower(v.name) = lower(@fulloptname)

   return (0)
end


select @catvalue = 0
select @catvalue = number
      from master.dbo.spt_values
      where lower(name) = lower(@fulloptname)
      and type = 'DC'

/* if setting replication option, call sp_replicationdboption directly */
if (@catvalue <> 0)
	begin
		if lower(@optvalue) in ('true', 'on')
			begin
				select @alt_optvalue = 'true'
			end
		else
			begin
				select @alt_optvalue = 'false'
			end

		select alt_optname = quotename(@fulloptname, '''')
		select @exec_stmt = quotename(@dbname, '[')   + '.dbo.sp_replicationdboption'

		if @catvalue = 1
			begin
				select @alt_optname  = 'publish'
			end
		if @catvalue = 2
			begin
				select @alt_optname  = 'subscribe'
			end
		if @catvalue = 4
			begin
				select @alt_optname  = 'merge publish'
			end

		exec @exec_stmt @dbname, @alt_optname, @alt_optvalue
		return (0)
	end


/* call Alter Database to set options */

/* set option value in alter database*/
if lower(@optvalue) in ('true', 'on')
   begin
		select @alt_optvalue = 'ON'
   end

else
	begin
		select @alt_optvalue = 'OFF'
	end

/* if Cross DB Ownership Chaining is the option. Set it and get out */
if lower(@fulloptname) = 'db chaining'
	begin
	
    -- CHECK PERMISSIONS (Note: All sysadmins are dbo) --
    if not (is_srvrolemember('sysadmin') = 1)
    begin
        raiserror(15247,-1,-1)
        return(1)
    end

    -- CANT SET IN ANY OF OF MASTER/MODEL/TEMPDB --
    if lower(@dbname) in ('master', 'model', 'tempdb') or
	   (lower(@dbname) ='msdb' and @alt_optvalue = 'OFF')
    begin
        raiserror(5600,-1,-1)
        return(1)
    end

    -- ERROR IF IN USER TRANSACTION --
    if @@trancount > 0
    begin
        raiserror(15289,-1,-1)
        return (1)
    end

   -- MAKE THE FOLLOWING REMOVE/REMAP/DELETES ATOMIC --
    begin transaction

	select @status = status2 from master.dbo.sysdatabases where name = @dbname
	if @alt_optvalue = 'ON'
		set @status = @status | 1024
	else
		select @status = @status & (~ 1024)
	update master.dbo.sysdatabases set status2 = @status where name = @dbname


    -- REFLECT NEW STATUS IN SYSDATABASES --
    commit transaction

    -- CHECKPOINT DATABASE TO FORCE CHANGES TO IN-MEMORY STRUCTURE --
	select @exec_stmt = 'use ' +  quotename(@dbname, '[')   + ' checkpoint'		 
	exec (@exec_stmt)        

    return (0) -- end of set db chaining/user info in doubt  option
	end


/* set option name in alter database */
if lower(@fulloptname) = 'auto create statistics'
	begin
		select @alt_optname = 'AUTO_CREATE_STATISTICS'
	end

if lower(@fulloptname) = 'auto update statistics'
	begin
		select @alt_optname = 'AUTO_UPDATE_STATISTICS'
	end

if lower(@fulloptname) = 'autoclose'
	begin
		select @alt_optname = 'AUTO_CLOSE'
	end

if lower(@fulloptname) = 'autoshrink'
	begin
		select @alt_optname = 'AUTO_SHRINK'
	end

if lower(@fulloptname) = 'ansi padding'
	begin
		select @alt_optname = 'ANSI_PADDING'
	end

if lower(@fulloptname) = 'arithabort'
	begin
		select @alt_optname = 'ARITHABORT'
	end

if lower(@fulloptname) = 'numeric roundabort'
	begin
		select @alt_optname = 'NUMERIC_ROUNDABORT'
	end

if lower(@fulloptname) = 'ansi null default'
	begin
		select @alt_optname = 'ANSI_NULL_DEFAULT'
	end

if lower(@fulloptname) = 'ansi nulls'
	begin
		select @alt_optname = 'ANSI_NULLS'
	end

if lower(@fulloptname) = 'ansi warnings'
	begin
		select @alt_optname = 'ANSI_WARNINGS'
	end

if lower(@fulloptname) = 'concat null yields null'
	begin
		select @alt_optname = 'CONCAT_NULL_YIELDS_NULL'
	end

if lower(@fulloptname) = 'cursor close on commit'
	begin
		select @alt_optname = 'CURSOR_CLOSE_ON_COMMIT'
	end

if lower(@fulloptname) = 'torn page detection'
	begin
		select @alt_optname = 'TORN_PAGE_DETECTION'
	end

if lower(@fulloptname) = 'quoted identifier'
	begin
		select @alt_optname = 'QUOTED_IDENTIFIER'
	end

if lower(@fulloptname) = 'recursive triggers'
	begin
		select @alt_optname = 'RECURSIVE_TRIGGERS'
	end

if lower(@fulloptname) = 'default to local cursor'
	begin
		select @alt_optname = 'CURSOR_DEFAULT'

		if @alt_optvalue = 'ON'
		   begin
				select @alt_optvalue = 'LOCAL'
		   end

		else
			begin
				select @alt_optvalue = 'GLOBAL'
			end
	end

if lower(@fulloptname) = 'offline'
	begin
		if @alt_optvalue = 'ON'
		   begin
				select @alt_optname = 'OFFLINE'
		   end

		else
			begin
				select @alt_optname = 'ONLINE'
			end
		select @alt_optvalue = ''
	end

if lower(@fulloptname) = 'read only'
	begin
		if @alt_optvalue = 'ON'
		   begin
				select @alt_optname = 'READ_ONLY'
		   end

		else
			begin
				select @alt_optname = 'READ_WRITE'
			end
		select @alt_optvalue = ''
	end

if lower(@fulloptname) = 'dbo use only'
	begin
		if @alt_optvalue = 'ON'
			begin
				if databaseproperty(@dbname, 'IsSingleUser') = 1
					begin
						raiserror(5066,-1,-1);
						return (1)
					end
				select @alt_optname = 'RESTRICTED_USER'
			end

		else
			begin
				if databaseproperty(@dbname, 'IsDBOOnly') = 0
					begin
						return (0)
					end
				select @alt_optname = 'MULTI_USER'
			end

		select @alt_optvalue = ''
	end

if lower(@fulloptname) = 'single user'
	begin
		if @alt_optvalue = 'ON'
		   begin
				if databaseproperty(@dbname, 'ISDBOOnly') = 1
					begin
						raiserror(5066,-1,-1);
						return (1)
					end
				select @alt_optname = 'SINGLE_USER'
		   end

		else
			begin
				if databaseproperty(@dbname, 'IsSingleUser') = 0
					begin
						return (0)
					end
				select @alt_optname = 'MULTI_USER'
			end
		select @alt_optvalue = ''
	end

if lower(@fulloptname) = 'select into/bulkcopy'
	begin
		select @alt_optname = 'RECOVERY'

		if @alt_optvalue = 'ON'
		   begin
				if databaseproperty(@dbname, 'IsTrunclog') = 1
					begin
						select @alt_optvalue = 'RECMODEL_70BACKCOMP'
					end
				else
					begin
						select @alt_optvalue = 'BULK_LOGGED'
					end
		   end

		else
			begin
				if databaseproperty(@dbname, 'IsTrunclog') = 1
					begin
						select @alt_optvalue = 'SIMPLE'
					end
				else
					begin
						select @alt_optvalue = 'FULL'
					end
			end
	end

if lower(@fulloptname) = 'trunc. log on chkpt.'
	begin
		select @alt_optname = 'RECOVERY'

		if @alt_optvalue = 'ON'
			begin
				if databaseproperty(@dbname, 'IsBulkCopy') = 1
					begin
						select @alt_optvalue = 'RECMODEL_70BACKCOMP'
					end
				else
					begin
						select @alt_optvalue = 'SIMPLE'
					end
			end

		else
			begin
				if databaseproperty(@dbname, 'IsBulkCopy') = 1
					begin
						select @alt_optvalue = 'BULK_LOGGED'
					end
				else
					begin
						select @alt_optvalue = 'FULL'
					end
			end
	end

/* construct the ALTER DATABASE command string */
select @exec_stmt = 'ALTER DATABASE ' + quotename(@dbname) +' SET ' + @alt_optname + ' ' + @alt_optvalue + ' WITH NO_WAIT'
exec (@exec_stmt)

if @@error <> 0
	begin
		raiserror(15627,-1,-1)
		return (1)
	end
else
	begin
		return (0)
	end

return (0) -- sp_dboption
go
set ansi_nulls off
go
/*ANSI_NULLS OFF  for after creation of sp_dboption*/

checkpoint
go

raiserror(15339,-1,-1,'sp_dbcmptlevel')
go
/*ANSI_NULLS ON  for creation of sp_dbcmptlevel*/
set ansi_nulls on
go
create procedure sp_dbcmptlevel  -- 1997/04/15
@dbname sysname = NULL,		/* database name to change */
@new_cmptlevel tinyint = NULL OUTPUT	/* the new compatibility level to change to */
as

set nocount    on

declare @exec_stmt nvarchar(275)
declare @returncode	int
declare @comptlevel	float(8)
declare @dbid int				/* dbid of the database */
declare @dbsid varbinary(85)    /* id of the owner of the database */
declare @orig_cmptlevel tinyint	/* original compatibility level */
declare @input_cmptlevel tinyint	/* compatibility level passed in by user */
	,@cmptlvl60 tinyint			/* compatibility to SQL Server Version 6.0 */
	,@cmptlvl65 tinyint			/* compatibility to SQL Server Version 6.5 */
	,@cmptlvl70 tinyint			/* compatibility to SQL Server Version 7.0 */
	,@cmptlvl80 tinyint			/* compatibility to SQL Server Version 8.0 */
select  @cmptlvl60 = 60,
		@cmptlvl65 = 65,
		@cmptlvl70 = 70,
		@cmptlvl80 = 80


-- SP MUST BE CALLED AT ADHOC LEVEL --
if (@@nestlevel > 1)
begin
    raiserror(15432,-1,-1,'sp_dbcmptlevel')
    return (1)
end

/*
**  If no @dbname given, just list the valid compatibility level values.
*/

if @dbname is null
begin
   raiserror (15048, -1, -1, @cmptlvl60, @cmptlvl65, @cmptlvl70, @cmptlvl80)
   return (0)
end

/*
**  Verify the database name and get info
*/
select @dbid = dbid, @dbsid = sid ,@orig_cmptlevel = cmptlevel
   from master.dbo.sysdatabases
      where name = @dbname

/*
**  If @dbname not found, say so and list the databases.
*/
if @dbid is null
   begin
      raiserror(15010,-1,-1,@dbname)
      print ' '
      select 'Available databases:' = name
         from master.dbo.sysdatabases
      return (1)
   end

/*
** Now save the input compatibility level and initialize the return clevel
** to be the current clevel
*/
select @input_cmptlevel = @new_cmptlevel
select @new_cmptlevel = @orig_cmptlevel

/*
** If no clevel was supplied, display and output current level.
*/
if @input_cmptlevel is null
   begin
      raiserror(15054, -1, -1, @orig_cmptlevel)
      return(0)
   end

/*
** We should not allow the user to change the compatibility level of the master database
*/
if @dbid = db_id('master')
	begin
	   raiserror(15417, -1, -1, @dbname)
	   return (1)
	end

/*
** If invalid clevel given, print usage and return error code
** 'usage: sp_dbcmptlevel [dbname [, compatibilitylevel]]'
*/
if @input_cmptlevel not in (@cmptlvl60, @cmptlvl65, @cmptlvl70, @cmptlvl80)
   begin
      raiserror(15416, -1, -1)
      print ' '
      raiserror (15048,
         -1, -1, @cmptlvl60, @cmptlvl65, @cmptlvl70, @cmptlvl80)
      return (1)
   end

/*
** We should not allow the user to change the compatibility level if there exists IV or ICC
*/
if @orig_cmptlevel = @cmptlvl80 and @input_cmptlevel < @cmptlvl80
	begin
		-- CHECK FOR INDEXED VIEWS OR INDEXED COMPUTED-COLUMNS
		if exists (select * from sysobjects where xtype = 'V' and id in (select id from sysindexes)) or
			exists (select * from sysobjects o join sysindexkeys k on o.id=k.id
				where o.xtype = 'U' and ColumnProperty(k.id, col_name(k.id, k.colid), 'IsComputed') = 1)
			begin
				-- Cannot set compat mode because database has a view or computed column that is indexed.
				-- These indexes require an 8.0-compatible database.
				raiserror(15414, -1, -1)
				return (1)
			end
	end

/*
**  Only the SA or the dbo of @dbname can execute the update part
**  of this procedure so check.
*/
if (not (is_srvrolemember('sysadmin') = 1)) and suser_sid() <> @dbsid
	-- ALSO ALLOW db_owner ONLY IF DB REQUESTED IS CURRENT DB
	and (@dbid <> db_id() or is_member('db_owner') <> 1)
   begin
      raiserror(15418,-1,-1)
      return (1)
   end

/*
** We should not allow the user to change the compatibility level for
** replicated or distributed databases
*/
select @comptlevel =	case @input_cmptlevel
							when 60 then 6.0
							when 65 then 6.5
							when 70 then 7.0
							when 80 then 8.0
						end

exec @returncode = sp_MSreplicationcompatlevel @dbname, @comptlevel

if @returncode <> 0
	begin
		raiserror(15306, -1, -1)
		return (1)
	end

/*
**  If we're in a transaction, disallow this since it might make recovery
**  impossible.
*/
set implicit_transactions off
if @@trancount > 0
   begin
      raiserror(15002,-1,-1,'sp_dbcmptlevel')
      return (1)
   end


update master.dbo.sysdatabases set cmptlevel = @input_cmptlevel
      where dbid = @dbid

/*
**  CHECKPOINT the database that was changed.
*/

select @exec_stmt = 'use ' +  quotename(@dbname, '[')   + ' checkpoint'
exec(@exec_stmt )
/*
** If checkpoint unsuccessful, restore the old compatibility level,
** otherwise update output clevel and flush all the SPs of this database
** from the cache
*/
if (@@error <> 0)
	begin
	update		 master.dbo.sysdatabases
		set	 cmptlevel = @orig_cmptlevel
		where	 dbid   = @dbid
	end
else
	begin
	dbcc flushprocindb(@dbid)
	select @new_cmptlevel = @input_cmptlevel
	end

return (0) -- sp_dbcmptlevel
go
set ansi_nulls off
go
/*ANSI_NULLS OFF  for after creation of sp_dbcmptlevel*/

---- Fallback 6.5 sprocs removed for 7.0 until re-coded from scratch to match new tables.
/************************  BEGIN-FALLBACK-STORED-PROCS ***********************/
raiserror(15339,-1,-1,'sp_fallback_MS_sel_fb_svr')
go

create procedure sp_fallback_MS_sel_fb_svr  --- 1997/05/30 02:44
    @pFallbackSvrName    character varying(30)   OUTPUT
as
/********1*********2*********3*********4*********5*********6*********7**

      This sproc is used by ODBC & DBLib when first connecting.
      This sproc will assign a null to the output parm.
      Note: This will need to be changed to return the name
            of the virtual server once WolfPack support is enabled.
*********1*********2*********3*********4*********5*********6*********7*/

Set nocount                   on
Set ansi_nulls                on

SELECT       @pFallbackSvrName   = null

Return 0
go

grant execute on sp_fallback_MS_sel_fb_svr to public
go

checkpoint
go
/*************************  END-FALLBACK-STORED-PROCS ************************/

raiserror(15339,-1,-1,'sp_validname')
go
CREATE PROCEDURE sp_validname
	@name			sysname,
	@raise_error	bit = 1
AS
	-----------------------------------------------------
	--	This SP checks for valid SQL-Server identifiers.
	--	For 7.0+, these are the very-simple checks below.
	--	All non-binary-zero (UNICODE) characters we just
	--	accept as being valid.
	-----------------------------------------------------
	declare @index	int

	Set nocount on

	-- Name cannot be NULL or empty ("")
	-- Blank identifiers (" ") are allowed
	IF (@name is null OR datalength(@name) = 0)
	begin
		if @raise_error = 1
			raiserror (15004,-1,-1)
		return (1)
	end

	-- Name cannot contain a binary-zero character
	select @index = charindex(convert(nchar(1),0x00), @name)
	while (@index <> 0)
	begin
		if unicode(substring(@name, @index, 1)) = 0
		begin
			if @raise_error = 1
				raiserror(15006,-1,-1,@name)
			return (1)
		end
		if @index >= len(@name)
			select @index = 0
		else
		begin
			select @name = substring(@name, @index+1, len(@name)-@index)
			select @index = charindex(convert(nchar(1),0x00), @name)
		end
	end

	-- TH-TH-TH-THAT'S IT!
	return (0) -- sp_validname
go


raiserror(15339,-1,-1,'sp_validlang')
go
create procedure sp_validlang --- 1996/04/08 00:00
@name	sysname
as

/* Check to see if this language is in Syslanguages. */
if exists (select * from master.dbo.syslanguages where name = @name or alias = @name)
	or @name = N'us_english'
	return(0)

raiserror(15033,-1,-1,@name)
return (1) -- sp_validlang
go

checkpoint
go

raiserror(15339,-1,-1,'sp_addmessage')
go
create procedure sp_addmessage --- 1996/04/08 00:00
@msgnum int = null,		-- Number of new message.
@severity smallint = null,	-- Severity of new message.
@msgtext nvarchar(255) = null,	-- Text of new message.
@lang sysname = null,       -- language (name) of new message
@with_log varchar(5) = 'FALSE', -- Whether the message will ALWAYS go to the NT event log
@replace varchar(7) = null	-- Optional parameter to specify that
				-- existing message with same number
				-- should be overwritten.
as
declare @retcode int
declare @langid smallint
declare @msglangid smallint
declare @dlevel smallint

	-- Must be ServerAdmin to manage messages
	if is_srvrolemember('serveradmin') = 0
	begin
		raiserror(15247,-1,-1)
		return (1)
	end

if @msgnum is null or @severity is null or @msgtext is null
	begin
		raiserror(15071,-1,-1)
		return(1)
	end

/*
** User defined messages must be > 50000.
*/
if @msgnum <= 50000
	begin
		raiserror(15040,-1,-1)
		return(1)
	end

/*
** Valid severity range for user defined messges is 1 to 25.
*/
if @severity not between 1 and 25
	begin
		raiserror(15041,-1,-1)
		return(1)
	end

/*
** Verify the language
*/
if @lang is not null
	begin
		exec @retcode = sp_validlang @lang
		if @retcode <>  0
			return(1)
	end
else
	select @lang = @@language

/*
** Get langid from syslanguages; us_english won't exist, so use 0.
*/
select @langid = langid, @msglangid = msglangid
    from master.dbo.syslanguages where name = @lang or alias = @lang

select @langid = isnull(@langid, 0)
select @msglangid = isnull(@msglangid, 1033)

/*
** @with_log must be 'TRUE' or 'FALSE'
*/
if (upper(@with_log) not in ('TRUE', 'FALSE'))
	begin
		raiserror(15271,-1,-1)
		return (1)
	end

/*
** Set the dlevel bit accordingly
*/
if (rtrim(upper(@with_log)) = 'TRUE')
        select @dlevel = 0x80
else
        select @dlevel = 0x0

/*
** If we're adding a non-us_english message, make sure the us_english version already exists.
*/
if (@langid <> 0) and not exists (select * from master.dbo.sysmessages where error=@msgnum and msglangid = 1033)
	begin
		raiserror(15279,-1,-1,@lang)
		return(1)
	end

/*
** If we're adding a non-us_english message, make sure that the severity matches that of the us_english version
*/
if (@langid <> 0 ) and not exists (select * from master.dbo.sysmessages where error=@msgnum and severity=@severity and msglangid = 1033)
	begin
		declare @us_english_severity smallint
		select @us_english_severity = severity from master.dbo.sysmessages where error=@msgnum and msglangid = 1033
		raiserror(15304,-1,-1,@lang,@us_english_severity)
		return(1)
	end

/*
**  Does this message already exist, and if so are we REPLACEing it?
*/
if (select count(*) from master.dbo.sysmessages where error=@msgnum and msglangid=@msglangid) > 0
	if lower(@replace) = 'replace'
		begin
			delete from master.dbo.sysmessages where error = @msgnum and msglangid = @msglangid
			/*
			** If we're REPLACEing a us_english message, make sure any non-us_english messages get updated with the same severity
			*/
			if (@langid = 0)
				begin
					update master.dbo.sysmessages set severity = @severity
					where error = @msgnum and msglangid <> 1033
				end
		end
	else
		begin
			/*
			** The 'replace' option wasn't specified and a
			** msg. with the number already exists.
			*/
			raiserror(15043,-1,-1)
			return(1)
		end

/*
**  Create the message.
*/
insert into master.dbo.sysmessages(error,severity,description,dlevel,msglangid)
	values (@msgnum,@severity,@msgtext,@dlevel,@msglangid)


return (0) -- sp_addmessage
go



raiserror(15339,-1,-1,'sp_addumpdevice')
go
create procedure sp_addumpdevice -- 1995/09/07 12:01
@devtype varchar(20),      /* disk, tape, or diskette */
@logicalname   sysname,      /* logical name of the device */
@physicalname  nvarchar(260),     /* physical name of the device */
@cntrltype  smallint = null,  /* controller type - ignored. */
@devstatus  varchar(40) = 'noskip'  /* device characteristics */
as

declare @status smallint      /* status bits for device */
declare @returncode int

/*
**  An open txn might jeopardize a recovery.
*/
set implicit_transactions off
if @@trancount > 0
   begin
      raiserror(15002,-1,-1,'sp_addumpdevice')
      return (1)
   end

/*
**  You must be SA to execute this sproc.
*/
if (not is_srvrolemember('diskadmin') = 1)
   begin
      raiserror(15247,-1,-1)
      return (1)
   end

select @devtype=lower(@devtype)

/*
**  Check out the @devtype.
*/
if @devtype not in ('disk', 'tape', 'diskette', 'pipe', 'virtual_device')
   begin
      raiserror(15044,-1,-1,@devtype)
      return (1)
   end

/*
**  Check the args are not NULL.
*/
if @logicalname is null
   begin
      raiserror(15045,-1,-1)
      return(1)
   end

/*
**  Check to see that the @logicalname is valid.
*/
exec @returncode = sp_validname @logicalname
if @returncode <> 0
   return(1)

if @physicalname is null
   begin
      raiserror(15046,-1,-1)
      return(1)
   end

/*
**  Make sure physical file name would be unique among devices.
*/
if exists (select * from master.dbo.sysdevices where phyname = @physicalname)
   begin
      raiserror(15061,-1,-1,@physicalname)
      return (1)
   end

/*
**  Prohibit certain special english words from being logical names.
*/
if (@logicalname IN ('disk' ,'diskette' ,'tape' ,'floppy'))
   begin
      raiserror(15285,-1,-1,@logicalname)
      return (1)
   end

/*
**  Make sure that a device with @logicalname doesn't already exist.
*/
if exists (select * from master.dbo.sysdevices where name = @logicalname)
   begin
      raiserror(15026,-1,-1,@logicalname)
      return (1)
   end

/*
**  Always turn on the dump status bit.
*/
select @status = 16

/*
**  If @devtype is a tape then check to see if devstatus is 'skip'.
*/
if @devtype = 'tape'
   begin
      if @devstatus not in ('noskip','skip')
         begin
            raiserror(15047,-1,-1)
            return (1)
         end

      if @devstatus = 'skip' select @status = @status | 8
   end

/*
**  If a disk then the cntrltype = 2
*/
if @devtype = 'disk'
   begin
      insert into master.dbo.sysdevices
         (low, high, size, status, cntrltype, name, phyname)
         values
         (0, 0, 0, @status, 2, @logicalname, @physicalname)
      raiserror(15444,-1,-1)
   end

/*
**  If a diskette then the cntrltype in (3,4)
*/
if @devtype = 'diskette'
   begin
      insert into master.dbo.sysdevices
         (low, high, size, status, cntrltype, name, phyname)
         values
         (0, 0, 0, @status, 3, @logicalname, @physicalname)
      raiserror(15445,-1,-1)
   end

/*
**  Tape device.
*/
if @devtype = 'tape'
   begin
      insert into master.dbo.sysdevices
         (low, high, size, status, cntrltype, name, phyname)
         values
         (0, 0, 0, @status, 5, @logicalname,@physicalname)
      raiserror(15446,-1,-1)
   end

/*
** Pipe.
*/
if @devtype = 'pipe'
   begin
      insert into master.dbo.sysdevices
         (low, high, size, status, cntrltype, name, phyname)
         values
         (0, 0, 0, @status, 6, @logicalname,@physicalname)
      raiserror(15447,-1,-1)
   end

/*
** Virtual device.
*/
if @devtype = 'virtual_device'
   begin
      insert into master.dbo.sysdevices
         (low, high, size, status, cntrltype, name, phyname)
         values
         (0, 0, 0, @status, 7, @logicalname,@physicalname)
      raiserror(15031,-1,-1)
   end


return (0) -- sp_addumpdevice
go


raiserror(15339,-1,-1,'sp_addremotelogin')
go
create procedure sp_addremotelogin --- 1996/04/08 00:00
	@remoteserver	sysname,		/* name of remote server */
	@loginame       sysname = NULL,		/* user's remote name */
	@remotename     sysname = NULL		/* user's local user name */
as
	declare @srvid smallint
	declare @sid varbinary(85)

	-- DISALLOW USER XACT --
	set implicit_transactions off
	if @@trancount > 0
	begin
		raiserror(15002,-1,-1,'sp_addremotelogin')
		return (1)
	end

    -- CHECK PERMISSIONS
    if not (is_srvrolemember('securityadmin') = 1)
    begin
		raiserror(15247,-1,-1)
        return (1)
    end

	-- VALIDATE SERVER NAME --
	select @srvid = srvid from master.dbo.sysservers where srvname = @remoteserver
	if @srvid is null
	begin
		raiserror(15015,-1,-1,@remoteserver)
		return (1)
	end

	-- CHECK FOR INVALID PARAMETER SYNTAX --
	if @loginame is null and @remotename is not null
	begin
		raiserror(15600,-1,-1,'sp_addremotelogin')
		return (1)
	end

	-- VALIDATE @loginame --
	if @loginame is not null
	begin
		select @sid = sid from master.dbo.syslogins where loginname = @loginame
					AND isntname = 0        -- cannot remap to NT login
		if @sid is null
		begin
			raiserror(15067,-1,-1,@loginame)
			return (1)
		end
	end

	-- CHECK FOR DUPLICATE <@remoteserver, @remotename> PAIR --
	--	(Note that this works for @remotename null and not null)
	if exists (select * from master.dbo.sysxlogins where srvid = @srvid
				AND ((@remotename is null AND name is null) OR name = @remotename)
				AND isrpcinmap = 1)
	begin
		if @remotename is null
			raiserror(15066,-1,-1,@remoteserver)
		else
			raiserror(15068,-1,-1,@remotename,@remoteserver)
		return (1)
	end

	-- Check if there is an outgoing mapping to which we can tag on this
	-- incoming mapping
	update master.dbo.sysxlogins set xstatus = xstatus | 32, xdate2 = getdate()
		where srvid = @srvid
		AND ((@remotename is null AND name is null) OR name = @remotename)
		AND ((@sid is null AND sid is null) OR sid = @sid)

	-- If update didnt happen, add an entry. (@srvid, @remotename, @sid)
	if @@rowcount = 0
		insert into master.dbo.sysxlogins
			values(@srvid, @sid, 32, getdate(), getdate(), @remotename, NULL, 0, NULL)

	-- SUCCESS --
	return (0)	-- sp_addremotelogin
go


checkpoint
go


raiserror(15339,-1,-1,'sp_addtype')
go
create procedure sp_addtype --- 1996/04/08 00:00
@typename sysname,		-- name of user-defined type
@phystype sysname,		-- physical system type of user-defined type
@nulltype varchar(8) = null,	-- nullability of new type
@owner sysname = null	-- Owner of type (default is caller)
as

declare @len int		-- length of user type
declare @type tinyint		-- typeid of physical type
declare @tlen smallint		-- length of physical type
declare @typeid smallint	-- user typeid of physical type
declare @nonull bit		-- default is getansinull()
declare @prec int		-- precision of the datatype
declare @scale int		-- scale of the datatype
declare @tprec tinyint		-- precision of the datatype read from systypes
declare @tscale tinyint		-- scale of the datatype read from systypes
declare @tname sysname  -- typename from systypes
declare @tstat tinyint      -- typestat from systypes
declare @orig_phystype	sysname
declare @default_collationid int		----- default collation id
declare @collationid int			---------collation id bo be used
select @orig_phystype = @phystype
select @nulltype = rtrim(lower(@nulltype))
select @typename = rtrim(@typename)
select @phystype = lower(rtrim(@phystype))

-- VALIDATE THE @owner NAME (and verify caller can use this name)
declare @uid smallint
if @owner is null
	select @uid = user_id()
else
	select @uid = uid from sysusers where name = @owner
		and isaliased = 0 AND uid NOT IN (0,3,4) --public/INFO_SCHEMA/etc can't own type
if @uid is null OR
	(is_member('db_owner')=0 AND
	 is_member('db_ddladmin')=0 AND
	 is_member(user_name(@uid))=0)
begin
	raiserror(15600, -1, -1, 'sp_addtype')
	return 1
end

-- TYPES BASED ON BIT CAN BE NULL IN SPHINX,
--	BUT MAKE NOT-NULL THE DFLT FOR BCKWRD-COMPAT
if lower(@phystype) = 'bit' and @nulltype is null
				-- If user didn't specify nullability,
				-- make sure it doesn't get set to nullable
				-- by getansinull()
		select @nulltype = 'not null'

/*
**  Should the user type allow NULLs?
*/
if @nulltype is null
	select @nonull = abs(getansinull()-1)
else if @nulltype = 'null'
	select @nonull = 0
else if @nulltype in ('not null','nonull')
	select @nonull = 1
else
	begin
		raiserror(15085,-1,-1)
		return (1)
	end

/*
**  Check to see that the @typename is valid.
*/
declare @returncode int
execute @returncode = sp_validname @typename
if @returncode <> 0
	return(1)

/*
**  Check to see if the user type already exists or a system type
**  whose name = lower(@typename) (or a synomym) already exists.
*/
if exists (select * from systypes where name = @typename
			or (name = lower(@typename) and xusertype <= 256))
		or lower(@typename)
		in ('character','character varying','char varying',
			'integer','dec','binary varying',
			'national character varying','national character',
			'national char varying','national char',
			'national text',
			'ncharacter varying', 'ncharacter', 'nchar varying',
			'rowversion')
	begin
		raiserror(15029,-1,-1,@typename)
		return (1)
	end

/*
**  Check to see if the user type has been reserved for future use.
*/
if @typename in ('variant')
	begin
		raiserror(15075,-1,-1,@typename)
		return (1)
	end

/*
** Can't supply length with sysname type.
*/
if @phystype like 'sysname%(%'
	begin
		raiserror(15270,-1,-1)
		return(1)
	end

/*
** initialize the length to be NULL first.
*/
select @len = NULL

/*
** If precision and scale were given with the type - extract them
*/
if @phystype like '_%(_%,_%)'
begin
	select @prec = convert(int, substring(@phystype,
		charindex('(',@phystype) + 1,
		charindex(',',@phystype) - 1 - charindex('(',@phystype)))

	select @scale = convert(int, substring(@phystype,
		charindex(',',@phystype) + 1,
		charindex(')',@phystype) - 1 - charindex(',',@phystype)))
	/*
	** Extract the physical type name
	*/
	select @phystype = substring(@phystype, 1,
		   charindex('(', @phystype) - 1)
end
else

/*
**  If a length was given with the user datatype, extract it.
*/
if @phystype like '_%(%)'
begin
	select @len = convert(int, substring(@phystype,
		charindex('(',@phystype) + 1,
		charindex(')',@phystype) - 1 - charindex('(',@phystype)))

	/*
	** Extract the physical type name
	*/
	select @phystype = substring(@phystype, 1,
		   charindex('(', @phystype) - 1)
end

select @phystype = rtrim(@phystype)

select @phystype= (case @phystype
	when 'character' then 'char'
	when 'character varying' then 'varchar'
	when 'char varying' then 'varchar'
	when 'integer' then 'int'
	when 'dec' then 'decimal'
	when 'binary varying' then 'varbinary'
	when 'national character varying' then 'nvarchar'
	when 'national char varying' then 'nvarchar'
	when 'national character' then 'nchar'
	when 'national char' then 'nchar'
	when 'ncharacter varying' then 'nvarchar'
	when 'ncharacter' then 'nchar'
	when 'nchar varying' then 'nvarchar'
	when 'national text' then 'ntext'
	when 'rowversion' then 'timestamp'
	else @phystype
	end)


/*
**  Make sure that the physical type exists and get its characteristics.
**  System physical types have a xusertype < 256 and are owned by the
**  dbo (userid = 1).
*/
select @type = xtype, @tlen = length,
	@tprec = xprec, @tscale = xscale, @tstat = status, @tname = name
from systypes
	where xusertype < 256 and name = @phystype and uid = 1

if @type is null
begin
	raiserror(15036,-1,-1,@orig_phystype)
	return (1)
end

/*
** get the default collation
*/

select @default_collationid  = collationid from systypes where name = @tname

/*
**  Disallow user-defined datatypes on timestamps.  This is done because
**  a timestamp is not a basic type but is really a binary.  There is,
**  therefore, no way to tell if a user-defined datatype is mapped to
**  a binary or a timestamp.  Timestamps can't have rules or defaults.
*/
if @phystype = 'timestamp'
begin
	raiserror(15038,-1,-1)
	return (1)
end

/*
**  Check if the NULL status of the user type is consistent with the NULL status
**  of the physical type.  Here are the possible cases.
**
**		   physical type
**		  NULLs	  NONULLs
**	        -----------------
** user	NULLs	|  ok	|  no
** type NONULLs	|  ok	|  ok
*/
-- NOT NECESSARY: bit and timestamp both already special-cased
/**********
if @nonull = 0 and 1 = 0
	begin
		raiserror(15037,-1,-1,@orig_phystype)
		return (1)
	end
**********/

/* Decide about precision, scale, length
** First check from NUMERIC, DECIMAL
*/
if @tname in ('numeric','decimal')
begin
	/* Type is NUMERIC or DECIMAL */

	if @len > 0
		begin
			/* Length is really the precision
			** Since no scale is specified then scale
			** is minimum(Default, precision). Default = 4
			*/
			select @prec = @len
			select @scale = 0
		end
	else
		if (@prec is NULL)
			begin
				select @prec = 18
				select @scale = 0
			end

	if (@prec > 38) or (@prec < 1)
		begin
			raiserror(15086,-1,-1)
			return (1)
		end

	if (@scale > @prec) or (@scale < 0)
		begin
			/*
			** Illegal scale specified -- must be less than precision
			** and positive.
			*/
			raiserror(15087,-1,-1)
			return (1)
		end

	/* Compute length from precision */
	if (@prec <= 9)
		select @len = 5

	if (@prec > 9) and (@prec <= 19)
		select @len = 9

	if (@prec > 19) and (@prec <= 28)
		select @len = 13

	if (@prec > 28) and (@prec <= 38)
		select @len = 17

end
else

/*
**  Typeids 1 (char), 2 (varchar), 3 (binary) and 4 (varbinary) are the
**  only ones which allow a length to be specified.
*/
if @tname not in ('binary', 'varbinary', 'char', 'varchar', 'nchar', 'nvarchar')
	begin
		/*
		**  We can't use a length and we got one.
		*/
		if @len > 0
			begin
				raiserror(15088,-1,-1)
				return (1)
			end

		/*
		**  Use the fixed length of the physical type.
		*/
		select @len = @tlen
		select @prec = @tprec
		select @scale = @tscale
	end
else
	begin
		/*
		**  We need a length and we didn't get one.
		*/
		if @len is null
			begin
				raiserror(15091,-1,-1)
				return (1)
			end

		-- need to adjust length for unicode (watch out for overflow!)
		if @tname in ('nchar', 'nvarchar') and (@len & 0x80000000) != 0x80000000
			select @len = @len * 2
		if @len <= 0 or @len > 8000
			begin
				raiserror(15092,-1,-1)
				return (1)
			end

		select @prec = @tprec
		select @scale = @tscale
	end

/*
**Get the collation's id
*/

if @tname  in ('char', 'nchar', 'ntext', 'nvarchar', 'text', 'varchar')
	begin
		select @collationid = @default_collationid
	end
else
	begin
		select @collationid=NULL
	end

/*
**  Finally, get the maximum existing user type so we use it + 1 for this
**  new type.
*/
select @typeid = max(xusertype)
	from systypes

/*
**  There are no user defined types yet so use the first number (256).
*/
if @typeid < 256
	select @typeid = 256

-- Set null status bit
if @nonull = 1
    select @tstat = @tstat | 0x01
else
    select @tstat = @tstat & 0xFE

insert systypes (name, xtype, status, xusertype, length, xprec, xscale,
            tdefault, domain, uid, reserved, collationid)
    select @typename, @type, @tstat, @typeid + 1, @len, @prec, @scale,
            0, 0, @uid, 0, @collationid

raiserror(15449,-1,-1)

return (0) -- sp_addtype
go


raiserror(15339,-1,-1,'sp_altermessage')
go
create procedure sp_altermessage --- 1996/04/08 00:00
@message_id       int,
@parameter        sysname,
@parameter_value  varchar(5)
as
begin
  declare @msg            varchar(128)

  select @parameter = upper(@parameter)
  select @parameter_value = upper(@parameter_value)

	-- Must be ServerAdmin to manage messages
	if is_srvrolemember('serveradmin') = 0
	begin
		raiserror(15247,-1,-1)
		return (1)
	end

  /*
  ** Does this message exist?
  */
  if (not exists (select * from master.dbo.sysmessages
                  where error = @message_id))
  begin
          raiserror(15179,-1,-1,@message_id)
          return (1)
  end

  /*
  ** Is Parameter 'WITH_LOG'?
  */
  if (@parameter <> 'WITH_LOG')
  begin
	raiserror(15176,-1,-1)
	return (1)
  end

  /*
  ** Is ParameterValue TRUE or FALSE?
  */
  if (@parameter_value not in ('TRUE', 'FALSE'))
  begin
          raiserror(15277,-1,-1)
          return (1)
  end


  /*
  ** Turn dlevel bit 7 on or off
  */
  if (@parameter_value = 'TRUE')
  begin
          update master.dbo.sysmessages
                  set dlevel = dlevel | 0x80
                          where error = @message_id
  end
  else
  if (@parameter_value = 'FALSE')
  begin
          update master.dbo.sysmessages
                  set dlevel = dlevel & 0x7FFFFF7F
                          where error = @message_id
  end
  return (0)
end
-- sp_altermessage
go

raiserror(15339,-1,-1,'sp_attach_db')
go
create procedure sp_attach_db
@dbname sysname
, @filename1 nvarchar(260)
, @filename2 nvarchar(260) = NULL
, @filename3 nvarchar(260) = NULL
, @filename4 nvarchar(260) = NULL
, @filename5 nvarchar(260) = NULL
, @filename6 nvarchar(260) = NULL
, @filename7 nvarchar(260) = NULL
, @filename8 nvarchar(260) = NULL
, @filename9 nvarchar(260) = NULL
, @filename10 nvarchar(260) = NULL
, @filename11 nvarchar(260) = NULL
, @filename12 nvarchar(260) = NULL
, @filename13 nvarchar(260) = NULL
, @filename14 nvarchar(260) = NULL
, @filename15 nvarchar(260) = NULL
, @filename16 nvarchar(260) = NULL
as
declare @execstring nvarchar (4000)
set nocount on

	IF ((@dbname is null OR datalength(@dbname) = 0) OR
	    (@filename1 is null OR datalength(@filename1) = 0))
	begin
		raiserror (15004,-1,-1)
		return (1)
	end

	-- build initial CREATE DATABASE
	select @execstring = 'CREATE DATABASE '
		+ quotename( @dbname , '[')
		+ ' ON (FILENAME ='
		+ ''''
		+ REPLACE(@filename1,N'''',N'''''')
		+ ''''

	-- add any additional files

	if (@filename2 IS NOT NULL)
	begin
		select @execstring = @execstring
			+ ' ), (FILENAME= '''
			+ REPLACE(@filename2 ,N'''',N'''''')
			+ ''''
	end

	if (@filename3 IS NOT NULL)
	begin
		select @execstring = @execstring
			+ ' ), (FILENAME= '''
			+ REPLACE(@filename3 ,N'''',N'''''')
			+ ''''
	end

	if (@filename4 IS NOT NULL)
	begin
		select @execstring = @execstring
			+ ' ), (FILENAME= '''
			+ REPLACE(@filename4 ,N'''',N'''''')
			+ ''''
	end

	if (@filename5 IS NOT NULL)
	begin
		select @execstring = @execstring
			+ ' ), (FILENAME= '''
			+ REPLACE(@filename5 ,N'''',N'''''')
			+ ''''
	end

	if (@filename6 IS NOT NULL)
	begin
		select @execstring = @execstring
			+ ' ), (FILENAME= '''
			+ REPLACE(@filename6 ,N'''',N'''''')
			+ ''''
	end

	if (@filename7 IS NOT NULL)
	begin
		select @execstring = @execstring
			+ ' ), (FILENAME= '''
			+ REPLACE(@filename7 ,N'''',N'''''')
			+ ''''
	end

	if (@filename8 IS NOT NULL)
	begin
		select @execstring = @execstring
			+ ' ), (FILENAME= '''
			+ REPLACE(@filename8  ,N'''',N'''''')
			+ ''''
	end

	if (@filename9 IS NOT NULL)
	begin
		select @execstring = @execstring
			+ ' ), (FILENAME= '''
			+ REPLACE(@filename9 ,N'''',N'''''')
			+ ''''
	end

	if (@filename10 IS NOT NULL)
	begin
		select @execstring = @execstring
			+ ' ), (FILENAME= '''
			+ REPLACE(@filename10  ,N'''',N'''''')
			+ ''''
	end

	if (@filename11 IS NOT NULL)
	begin
		select @execstring = @execstring
			+ ' ), (FILENAME= '''
			+ REPLACE(@filename11  ,N'''',N'''''')
			+ ''''
	end

	if (@filename12 IS NOT NULL)
	begin
		select @execstring = @execstring
			+ ' ), (FILENAME= '''
			+ REPLACE(@filename12  ,N'''',N'''''')
			+ ''''
	end

	if (@filename13 IS NOT NULL)
	begin
		select @execstring = @execstring
			+ ' ), (FILENAME= '''
			+ REPLACE(@filename13  ,N'''',N'''''')
			+ ''''
	end

	if (@filename14 IS NOT NULL)
	begin
		select @execstring = @execstring
			+ ' ), (FILENAME= '''
			+ REPLACE(@filename14  ,N'''',N'''''')
			+ ''''
	end

	if (@filename15 IS NOT NULL)
	begin
		select @execstring = @execstring
			+ ' ), (FILENAME= '''
			+ REPLACE(@filename15 ,N'''',N'''''')
			+ ''''
	end

	if (@filename16 IS NOT NULL)
	begin
		select @execstring = @execstring
			+ ' ), (FILENAME= '''
			+ REPLACE(@filename16  ,N'''',N'''''')
			+ ''''
	end


	-- note it as for attach
	select @execstring = @execstring + ' ) FOR ATTACH'
	exec (@execstring)

if @@error <>  0
	begin
		-- No need to raiserror as the CREATE DATABASE will do so
		return(1)
	end
return (0) -- sp_attach_db
go


raiserror(15339,-1,-1,'sp_attach_single_file_db')
go
create procedure sp_attach_single_file_db
@dbname sysname,
@physname nvarchar(260)
as
declare @execstring nvarchar (400)
set nocount on
	IF ((@dbname is null OR datalength(@dbname) = 0) OR
	   (@physname is null OR datalength(@physname) = 0))
	begin
		raiserror (15004,-1,-1)
		return (1)
	end

	select @execstring = 'CREATE DATABASE '
		+ quotename( @dbname , '[')
		+ ' ON (FILENAME ='
		+ ''''
		+ REPLACE(@physname,N'''',N'''''')
		+ ''''
		+ ' ) FOR ATTACH'
	exec (@execstring)
if @@error <>  0
	begin
		-- No need to raiserror as the CREATE DATABASE will do so
		return(1)
	end
	-- strip out replication from this database
if exists (select * from master.dbo.sysobjects where name=N'sp_removedbreplication')
	begin
		exec sp_removedbreplication @dbname
	end
	return (0) -- sp_attach_single_file_db
go


raiserror(15339,-1,-1,'sp_helplanguage')
go
create procedure sp_helplanguage --- 1996/04/08 00:00
@language sysname = NULL
as

/* Print all languages if the user didn't give the language name. */
if @language is null
begin
	if exists (select * from master.dbo.syslanguages)
		select * from master.dbo.syslanguages
	else
		raiserror(15452,-1,-1)

	/* Find out whether us_english is there or not. */
	if not exists (select * from master.dbo.syslanguages
			where name = 'us_english')
		raiserror(15453,-1,-1)

	return (0)
end

/*  Report information on this language. */
if exists (select * from master.dbo.syslanguages where name = @language)
	begin
		select * from master.dbo.syslanguages where name = @language
		return (0)
	end

if exists (select * from master.dbo.syslanguages where alias = @language)
	begin
		select * from master.dbo.syslanguages where alias = @language
		return (0)
	end

/* Couldn't find this language. */
if @language = 'us_english'
	begin
		raiserror(15453,-1,-1)
		return (0)
	end
else
	begin
		raiserror(15033,-1,-1,@language)
		return (1)
	end
-- sp_helplanguage
go




checkpoint
go

raiserror(15339,-1,-1,'sp_bindefault')
go
create procedure sp_bindefault --- 1996/08/30 20:04
@defname nvarchar(776),			/* name of the default */
@objname nvarchar(517),			/* table or usertype name */
@futureonly varchar(15) = NULL		/* flag to indicate extent of binding */
as

declare @defid int			/* id of the default to bind */
declare @futurevalue varchar(15)	/* the value of @futureonly that causes
					** the binding to be limited */
declare
	@vc1			nvarchar(517)
	,@tab_id		integer
	,@parent_obj	integer
	,@cur_tab_id	integer
	,@colid			smallint
	,@xtype			tinyint
	,@xusertype		smallint
	,@col_status	tinyint
	,@col_default int
	,@identity binary(1)

declare
	@UnqualDef			sysname
	,@QualDef1			sysname
	,@QualDef2			sysname
	,@QualDef3			sysname

	,@UnqualObj			sysname
	,@QualObj1			sysname
	,@QualObj2			sysname
	,@QualObj3			sysname

set cursor_close_on_commit	off
set nocount			on

select @futurevalue = 'futureonly'	/* initialize @futurevalue */
select @identity = 0X80 /* identity columns*/

/*
**  When a default or rule is bound to a user-defined datatype, it is also
**  bound, by default, to any columns of the user datatype that are currently
**  using the existing default or rule as their default or rule.  This default
**  action may be overridden by setting @futureonly = @futurevalue when the
**  procedure is invoked.  In this case existing columns with the user
**  datatype won't have their existing default or rule changed.
*/

-- get name parts --
select @UnqualDef = parsename(@defname, 1),
        @QualDef1 = parsename(@defname, 2),
        @QualDef2 = parsename(@defname, 3),
        @QualDef3 = parsename(@defname, 4)

select @UnqualObj = parsename(@objname, 1),
        @QualObj1 = parsename(@objname, 2),
        @QualObj2 = parsename(@objname, 3),
        @QualObj3 = parsename(@objname, 4)

IF (@UnqualDef is NULL OR @QualDef3 is not null)
   begin
   raiserror(15253,-1,-1,@defname)
   return (1)
   end

IF (@UnqualObj is NULL OR @QualObj3 is not null)
   begin
   raiserror(15253,-1,-1,@objname)
   return (1)
   end


------------------  Verify database.

if ((@QualObj2 is not null and @QualObj1 is null)
	or (@QualDef2 is not null and @QualDef2 <> db_name()))
	begin
		raiserror(15076,-1,-1)
		return (1)
	end

/*
**  Check that the @futureonly argument, if supplied, is correct.
*/
if (@futureonly IS NOT NULL)
begin
	select @futureonly = lower(@futureonly)
	if (@futureonly <> @futurevalue)
		begin
			raiserror(15100,-1,-1)
			return (1)
		end
end

/*
**  Check to see that the default exists and get its id.
*/
select @defid = id, @parent_obj = parent_obj from sysobjects
			where id = object_id(@defname)
				and xtype='D '	-- default object 6

if @defid is NULL
	begin
		raiserror(15016,-1,-1,@UnqualDef)
		return (1)
	end


if @parent_obj > 0
	begin
		raiserror(15050,-1,-1,@defname)
		return(1)
	end

/*
**  If @objname is of the form tab.col then we are binding to a column.
**  Otherwise its a datatype.  In the column case, we need to extract
**  and verify the table and column names and make sure the user owns
**  the table that is getting the default bound. We also need to ensure
**  that we don't overwrite any DRI style defaults.
*/
if @QualObj1 is not null
begin
	if (@QualObj2 is not null)
		select @vc1 = QuoteName(@QualObj2) + '.' + QuoteName(@QualObj1)
	else
		select @vc1 = QuoteName(@QualObj1)

	select	@tab_id = o.id,		@colid = c.colid,
			@xtype = c.xtype,	@col_status = c.status,
			@col_default = c.cdefault
	from sysobjects o, syscolumns c
	where c.id = object_id(@vc1,'local')
			and c.name = @UnqualObj
			and o.id = c.id
			and o.xtype='U '

	/*Check that table and column exist*/
 	if @tab_id is null
	begin
		raiserror(15104,-1,-1,@QualObj1,@UnqualObj)
		return (1)
	end

	/*
	**  If the column type is timestamp, disallow the bind.
	**  Defaults can't be bound to timestamp columns.
	*/
	if type_name(@xtype) = 'timestamp'
	begin
		raiserror(15101,-1,-1)
		return (1)
	end

	/*
	**  If the column category is identity, disallow the bind.
	**  Defaults can't be bound to identity columns.
	*/
	if @col_status & @identity = @identity
	begin
		raiserror(15102,-1,-1)
		return (1)
	end

   /*
   **  Check to see if the column was created with or altered
   **  to have a DRI style default value.
   */
	if @col_default > 0
		if exists
         (select	*
            from	sysobjects o
            where	@col_default       = o.id
            and		@tab_id             = o.parent_obj)
		begin
			raiserror(15103,-1,-1)
			return (1)
		end

	BEGIN TRANSACTION txn_bindefault_1

		/*
		**  Since binding a default is a schema change, update schema count
		**  for the object in the sysobjects table.
		*/

		dbcc LockObjectSchema(@vc1) --- Undocu. Locks out other schema changes until commit, and increments sysobjects.schema_ver.

		update syscolumns set cdefault = @defid where id = @tab_id and colid = @colid

	COMMIT TRANSACTION txn_bindefault_1

	raiserror(15511,-1,-1)

end
else
begin
	/*
	**  We're binding to a user type.  In this case, the @objname
	**  is really the name of the user datatype.
	**  When we bind to a user type, any existing columns get changed
	**  to the new binding unless their current binding is not equal
	**  to the current binding for the usertype or if they set the
	**  @futureonly parameter to @futurevalue.
	*/
	declare @olddefault int	/* current default for type */

	/*
	**  Get the current default for the datatype.
	*/

	select @xusertype = xusertype, @olddefault = tdefault
		from systypes where name = @UnqualObj and xusertype > 256
		AND (is_member('db_owner') = 1 OR is_member('db_ddladmin') = 1 OR is_member(user_name(uid))=1)

	if @xusertype is null
		begin
			raiserror(15105,-1,-1)
			return (1)
		end

	update systypes
		set tdefault = @defid
			from systypes
		where xusertype = @xusertype


	raiserror(15512,-1,-1)

	/*
	**  need the new binding.
	*/
	if isnull(@futureonly, ' ') <> @futurevalue
	begin

		declare ms_crs_t1 cursor local static for
		  select
			distinct
				 c.id
				 ,c.colid
			from	 syscolumns	c JOIN sysobjects o ON c.id = o.id AND o.xtype = N'U '
			where	 c.xusertype	= @xusertype
			and	(c.cdefault	= @olddefault	OR
				 c.cdefault	= 0
				)
			order by c.id
                  for read only

		open ms_crs_t1

		BEGIN TRANSACTION txn_bindefault_3

		fetch next from ms_crs_t1 into
			 @tab_id,
			 @colid

		WHILE @@fetch_status = 0
		begin

			select @vc1 = quotename(user_name(OBJECTPROPERTY(@tab_id,'OwnerId'))) + '.'
						+ quotename(object_name(@tab_id))

			dbcc LockObjectSchema(@vc1) --- Undocu. Locks out other schema changes until commit, and increments sysobjects.schema_ver.

			select @cur_tab_id = @tab_id

			while @cur_tab_id = @tab_id and @@fetch_status = 0
			begin

				update syscolumns
				set cdefault = @defid
				from syscolumns c
				where c.id = @tab_id
				and c.colid = @colid

				fetch next from ms_crs_t1 into
					 @tab_id,
					 @colid
			end

		end --loop 3

		COMMIT TRANSACTION txn_bindefault_3

		deallocate ms_crs_t1

		raiserror(15513,-1,-1)
	end
end

return (0) -- sp_bindefault
go

raiserror(15339,-1,-1,'sp_bindrule')
go
create procedure sp_bindrule --- 1996/08/14 15:02
@rulename nvarchar(776),			/* name of the rule */
@objname nvarchar(517),			/* table or usertype name */
@futureonly varchar(15) = NULL		/* column name */
as

declare @ruleid int			/* id of the rule to bind */
declare @futurevalue varchar(15)	/* the value of @futureonly that causes
					** the binding to be limited */

declare
	@vc1			nvarchar(517)
	,@tab_id		integer
	,@cur_tab_id	integer
	,@colid			smallint

	,@xtype			smallint
	,@xusertype		smallint

declare
	@UnqualRule		sysname
	,@QualRule1		sysname
	,@QualRule2		sysname
	,@QualRule3		sysname

	,@UnqualObj		sysname
	,@QualObj1		sysname
	,@QualObj2		sysname
	,@QualObj3		sysname

set cursor_close_on_commit	off
set nocount on

select @futurevalue = 'futureonly'	/* initialize @futurevalue */

/*
**  When a default or rule is bound to a user-defined datatype, it is also
**  bound, by default, to any columns of the user datatype that are currently
**  using the existing default or rule as their default or rule.  This default
**  action may be overridden by setting @futureonly = @futurevalue when the
**  procedure is invoked.  In this case existing columns with the user
**  datatype won't have their existing default or rule changed.
*/

-- get name parts --
select @UnqualRule = parsename(@rulename, 1),
        @QualRule1 = parsename(@rulename, 2),
        @QualRule2 = parsename(@rulename, 3),
        @QualRule3 = parsename(@rulename, 4)

select @UnqualObj = parsename(@objname, 1),
        @QualObj1 = parsename(@objname, 2),
        @QualObj2 = parsename(@objname, 3),
        @QualObj3 = parsename(@objname, 4)

IF (@UnqualRule is NULL OR @QualRule3 is not null)
   begin
   raiserror(15253,-1,-1,@rulename)
   return (1)
   end

IF (@UnqualObj is NULL OR @QualObj3 is not null)
   begin
   raiserror(15253,-1,-1,@objname)
   return (1)
   end


------------------  Verify database.

if ((@QualObj2 is not null and @QualObj1 is null)
	or (@QualRule2 is not null and @QualRule2 <> db_name()))
	begin
		raiserror(15077,-1,-1)
		return (1)
	end

/*
**  Check that the @futureonly argument, if supplied, is correct.
*/
if (@futureonly IS NOT NULL)
begin
	select @futureonly = lower(@futureonly)
	begin
		if (@futureonly <> @futurevalue)
			begin
				raiserror(15106,-1,-1)
				return (1)
			end
	end
end

/*
**  Check to see that the rule exists and get its id.
*/
select @ruleid = id from sysobjects
			where id = object_id(@rulename)
				and xtype='R ' --rule object 7

if @ruleid is NULL
	begin
		raiserror(15017,-1,-1,@rulename)
		return (1)
	end

/*
**  If @objname is of the form tab.col then we are binding to a column.
**  Otherwise its a datatype.  In the column case, we need to extract
**  and verify the table and column names and make sure the user owns
**  the table that is getting the rule bound.
*/
if @QualObj1 is not null
begin
	if (@QualObj2 is not null)
		select @vc1 = QuoteName(@QualObj2) + '.' + QuoteName(@QualObj1)
	else
		select @vc1 = QuoteName(@QualObj1)

	select @tab_id = o.id, @colid = c.colid, @xtype = c.xtype
	from sysobjects o, syscolumns c
	where c.id = object_id(@vc1,'local')
			and c.name = @UnqualObj
			and o.id = c.id
			and o.xtype='U '

	/*Check that table and column exist*/
 	if @tab_id is null
	begin
		raiserror(15104,-1,-1,@QualObj1,@UnqualObj)
		return (1)
	end

	/*
	**  If the column type is image, text, or timestamp, disallow the bind.
	**  Rules can't be bound to image, text, or timestamp columns.
	**  The types are checked in case
	**  there is a user-defined datatype that is an image or text.
	**  User-defined datatypes mapping to timestamp are not allowed
	**  by sp_addtype.
	*/
	if type_name(@xtype) in ('text', 'ntext', 'image', 'timestamp')
		begin
			raiserror(15107,-1,-1)
			return (1)
		end

	BEGIN TRANSACTION txn_bindrule_1

		dbcc LockObjectSchema(@vc1) --- Undocu. Locks out other schema changes until commit, and increments sysobjects.schema_ver.

		update syscolumns set domain = @ruleid
			where id = @tab_id and colid = @colid

	COMMIT TRANSACTION txn_bindrule_1

	raiserror(15514,-1,-1)

end
else
begin
	/*
	**  We're binding to a user type.  In this case, the @objname
	**  is really the name of the user datatype.
	**  When we bind to a user type, any existing columns get changed
	**  to the new binding unless their current binding is not equal
	**  to the current binding for the usertype or if they set the
	**  @futureonly parameter to @futurevalue.
	*/
	declare @oldrule int			/* current rule for type */

	/*
	**  Get the current rule for the datatype.
	*/
	select @oldrule = domain, @xtype = xtype, @xusertype = xusertype
		from systypes where name = @UnqualObj and xusertype > 256
		AND (is_member('db_owner') = 1 OR is_member('db_ddladmin') = 1 OR is_member(user_name(uid))=1)

	if @oldrule is null
		begin
			raiserror(15105,-1,-1)
			return (1)
		end

	/*
	**  If the column type is image, text, or timestamp, disallow the bind.
	**  Rules can't be bound to image or text columns.
	*/
	if type_name(@xtype) in ('text', 'ntext', 'image', 'timestamp')
		begin
			raiserror(15107,-1,-1)
			return (1)
		end

	update systypes set domain = @ruleid
			from systypes
		where xusertype = @xusertype


	raiserror(15515,-1,-1)

	/*
	**  Now see if there are any columns with the usertype that
	**  need the new binding.
	*/
	if isnull(@futureonly, ' ') <> @futurevalue
	begin
		declare ms_crs_bindrule_1 cursor local static for
		  select
			distinct
				 c.id
				,c.colid
			from	 syscolumns c JOIN sysobjects o ON c.id = o.id AND o.xtype = N'U '
			where	 c.xusertype	= @xusertype
			and	(c.domain	= @oldrule	OR
				 c.domain	= 0
				)
			order by c.id
                  for read only

		open ms_crs_bindrule_1

		BEGIN TRANSACTION txn_bindrule_2

		fetch next from ms_crs_bindrule_1 into
			@tab_id
			,@colid

		WHILE @@fetch_status = 0
		begin

			select @vc1 = quotename(user_name(OBJECTPROPERTY(@tab_id,'OwnerId'))) + '.'
						+ quotename(object_name(@tab_id))

			dbcc LockObjectSchema(@vc1) --- Undocu. Locks out other schema changes until commit, and increments sysobjects.schema_ver.

			select @cur_tab_id = @tab_id

			while @cur_tab_id = @tab_id and @@fetch_status = 0
			begin
				/*
				**  Update syscolumns with new binding.
				*/
				update syscolumns
					set domain = @ruleid
					where id = @tab_id and colid = @colid

				fetch next from ms_crs_bindrule_1 into
					 @tab_id
					,@colid
			end

		end --loop 3

		deallocate ms_crs_bindrule_1

		COMMIT TRANSACTION txn_bindrule_2

		raiserror(15516,-1,-1)
	end
end
return (0) -- sp_bindrule
go

raiserror(15339,-1,-1,'sp_checknames')
go
create procedure sp_checknames --- 1996/04/08 00:00
@mode varchar(20) = NULL		/* mode of operation; e.g. 'silent' */
as

declare @msilent	int		/* set to 1 if 'silent' mode is on */
declare @ret_val	int		/* set to 1 if we find funny char */
declare @codepoint	tinyint		/* set to 1 if we find funny char */
declare @dbname		sysname	/* holds database name */
declare @msg		varchar(90)	/* used for messages to
 */
declare @pat		varchar(132)	/* holds the pattern to search for */

set nocount on

if (@mode like '%help%')
begin
	raiserror(15525,-1,-1)
	raiserror(15526,-1,-1)
	raiserror(15527,-1,-1)
	print ' '
	raiserror(15528,-1,-1)
	raiserror('        sysdatabases.name',0,1)
	raiserror('        sysdevices.name' ,0,1)
	raiserror('        syslogins.name' ,0,1)
	raiserror('        syslogins.dbname',0,1)
	raiserror('        sysremotelogins.remoteusername',0,1)
	raiserror('        sysservers.srvname',0,1)
	raiserror('        sysservers.srvnetname',0,1)
	print ' '
	raiserror(15536,-1,-1)
	raiserror('        syscolumns.name',0,1)
	raiserror('        sysindexes.name',0,1)
	raiserror('        sysobjects.name',0,1)
	raiserror('        syssegments.name',0,1)
	raiserror('        systypes.name',0,1)
	raiserror('        sysusers.name',0,1)
	print ' '
	return (0)
end

/*
**  First, initialize return value, and set up mode variables:
*/
select @ret_val = 0

if (@mode like '%silent%')
	select @msilent = 1
else
	select @msilent = 0


/*
**  Now, initialize the pattern string we will search for:
*/
select @pat = '%[', @codepoint = 127
while (@codepoint < 255)
begin
	select @codepoint = @codepoint + 1
	select @pat = @pat + char(@codepoint)
end
select @pat = @pat + ']%'


/*
**  Get the database name we are in:
*/
select @dbname = db_name()

if (@msilent = 0)
begin
	print ' '
	raiserror(15543,-1,-1,@dbname)
	print ' '
end


/*
**  Look through these only if in the master database:
*/
if (@dbname = 'master')
begin
    if exists (select name from master.dbo.sysdatabases
		    where convert(varchar(132), name) like @pat)
    begin
	if (@msilent = 1)
	    return (1)

	select @ret_val = 1
	print ' '
	print '==============================================================='
	raiserror(15544,-1,-1,'sysdatabases.name')
	print ' '
	raiserror(15545,-1,-1)
	raiserror(15546,-1,-1,'sp_renamedb')
	print ' '
	select dbid,name from master.dbo.sysdatabases
			where convert(varchar(132), name) like @pat
    end

    if exists (select name from master.dbo.sysdevices where convert(varchar(132), name) like @pat)
    begin
	if (@msilent = 1)
	    return (1)

	select @ret_val = 1
	print ' '
	print '==============================================================='
	raiserror(15544,-1,-1,'sysdevices.name')
	print ' '
	raiserror(15564,-1,-1)
	raiserror(15546,-1,-1,'UPDATE')
        print ' '
	select name from master.dbo.sysdevices where convert(varchar(132), name) like @pat
    end

    if exists (select loginname from master.dbo.syslogins where convert(varchar(132), loginname) like @pat)
    begin
	if (@msilent = 1)
	    return (1)

	select @ret_val = 1
	print ' '
	print '==============================================================='
	raiserror(15544,-1,-1,'syslogins.name')
        print ' '
	raiserror(15565,-1,-1)
	raiserror(15546,-1,-1, 'sp_droplogin'' and ''sp_addlogin')
        print ' '
	select sid, loginname from master.dbo.syslogins
			where convert(varchar(132), loginname) like @pat
    end

    if exists (select dbname from master.dbo.syslogins
		    where convert(varchar(132), dbname) like @pat)
    begin
	if (@msilent = 1)
	    return (1)

	select @ret_val = 1
	print ' '
	print '==============================================================='
	raiserror(15544,-1,-1,'syslogins.dbname')
	print ' '
	raiserror(15547,-1,-1)
	raiserror(15548,-1,-1)
	raiserror(15549,-1,-1)
        print ' '
	select sid,loginname,dbname from master.dbo.syslogins
			where convert(varchar(132), dbname) like @pat
    end

    if exists (select remoteusername from master.dbo.sysremotelogins
		    where convert(varchar(132), remoteusername) like @pat)
    begin
	if (@msilent = 1)
	    return (1)

	select @ret_val = 1
	print ' '
	print '==============================================================='
	raiserror(15544,-1,-1,'sysremotelogins.remoteusername')
        print ' '
	raiserror(15566,-1,-1)
	raiserror(15546,-1,-1,'sp_dropremotelogin'' and ''sp_addremotelogin')
        print ' '
	select remoteserverid,remoteusername from master.dbo.sysremotelogins
			where convert(varchar(132), remoteusername) like @pat
    end

    if exists (select srvname from master.dbo.sysservers
		    where convert(varchar(132), srvname) like @pat)
    begin
	if (@msilent = 1)
	    return (1)

	select @ret_val = 1
	print ' '
	print '==============================================================='
	raiserror(15544,-1,-1,'sysservers.srvname')
        print ' '
	raiserror(15567,-1,-1)
	raiserror(15546,-1,-1,'sp_dropserver'' and ''sp_addserver')
        print ' '
	select srvid,srvname from master.dbo.sysservers
			where convert(varchar(132), srvname) like @pat
    end

    if exists (select srvnetname from master.dbo.sysservers
		    where convert(varchar(132), srvnetname) like @pat)
    begin
	if (@msilent = 1)
	    return (1)

	select @ret_val = 1
	print ' '
	print '==============================================================='
	raiserror(15544,-1,-1,'sysservers.srvnetname')
        print ' '
	raiserror(15550,-1,-1)
	raiserror(15551,-1,-1)
	raiserror(15552,-1,-1)
        print ' '
	select srvid,srvname,srvnetname from master.dbo.sysservers
			where convert(varchar(132), srvnetname) like @pat
    end

end


/*
**  For *ALL* databases, we want to look through these:
*/
if exists (select name from dbo.syscolumns
	    where convert(varchar(132), name) like @pat)
begin
    if (@msilent = 1)
	return (1)

    select @ret_val = 1
    print ' '
    print '==============================================================='
    raiserror(15544,-1,-1,'syscolumns.name')
    print ' '
    raiserror(15568,-1,-1)
    raiserror(15546,-1,-1,'sp_rename')
    print ' '
    select objname=o.name,colname=c.name from dbo.syscolumns c, dbo.sysobjects o
		where convert(varchar(132), c.name) like @pat and o.id = c.id
end

if exists (select name from dbo.sysindexes
	    where convert(varchar(132), name) like @pat
	    	  and indid > 0)
begin
    if (@msilent = 1)
	return (1)

    select @ret_val = 1
    print ' '
    print '==============================================================='
    raiserror(15544,-1,-1,'sysindexes.name')
    print ' '
    raiserror(15569,-1,-1)
    raiserror(15546,-1,-1,'UPDATE')
    print ' '
    select id,indid,name from dbo.sysindexes
		where convert(varchar(132), name) like @pat
		and indid > 0
end

if exists (select name from dbo.sysobjects
	    where convert(varchar(132), name) like @pat)
begin
    if (@msilent = 1)
	return (1)

    select @ret_val = 1
    print ' '
    print '==============================================================='
    raiserror(15544,-1,-1,'sysobjects.name')
    print ' '
    raiserror(15570,-1,-1)
    raiserror(15546,-1,-1,'sp_rename')
    print ' '
    select owner = u.name,o.name from dbo.sysobjects o,dbo.sysusers u
		where convert(varchar(132), o.name) like @pat and o.uid=u.uid
end

if exists (select name from dbo.syssegments
	    where convert(varchar(132), name) like @pat)
begin
    if (@msilent = 1)
	return (1)

    select @ret_val = 1
    print ' '
    print '==============================================================='
    raiserror(15544,-1,-1,'syssegments.name')
    print ' '
    raiserror(15571,-1,-1)
    raiserror(15546,-1,-1,'UPDATE')
    print ' '
    select segment,name from dbo.syssegments
		where convert(varchar(132), name) like @pat
end

if exists (select name from dbo.systypes
	    where convert(varchar(132), name) like @pat)
begin
    if (@msilent = 1)
	return (1)

    select @ret_val = 1
    print ' '
    print '==============================================================='
    raiserror(15544,-1,-1,'systypes.name')
    print ' '
    raiserror(15572,-1,-1)
    raiserror(15546,-1,-1,'sp_rename')
    print ' '
    select name from dbo.systypes
		where convert(varchar(132), name) like @pat
end

if exists (select name from dbo.sysusers where convert(varchar(132), name) like @pat)
begin
    if (@msilent = 1)
	return (1)

    select @ret_val = 1
    print ' '
    print '==============================================================='
    raiserror(15544,-1,-1,'sysusers.name')
    print ' '
    raiserror(15573,-1,-1)
    raiserror(15546,-1,-1,'UPDATE')
    print ' '
    select sid,uid,name from dbo.sysusers
		where convert(varchar(132), name) like @pat
end

if (@ret_val = 0  and  @msilent = 0)
begin

    raiserror(15553,-1,-1, @dbname)
    raiserror(15554,-1,-1)
end

return (@ret_val) -- sp_checknames
go

checkpoint
go

raiserror(15339,-1,-1,'sp_configure')
go
CREATE PROCEDURE sp_configure  --- 1996/08/14 09:43

    @configname   varchar(35) = NULL   -- option name to configure
   ,@configvalue  int         = NULL   -- new configuration value
as

set nocount on

declare
    @confignum                int   --Num of the opt to be configured
   ,@configcount              int   --Num of options like @configname
   ,@show_advance             int   --Y/N Read&Write actions on "advanced" opts

declare @fullconfigname		varchar (35)
declare @prevvalue			int
/*
**  Determine @maxnumber based on advance option in syscurconfigs.
*/
if (select value from master.dbo.syscurconfigs where config = 518) = 1
   select @show_advance = 1   -- Display advanced options
else
   select @show_advance = 0   -- Don't display advanced options

/*
**  Make certain that max user info. reflects any addpak upgrades.
*/
if (select high from master.dbo.spt_values where number=103 and type='C')
   <> @@max_connections

   update master.dbo.spt_values
      set high = @@max_connections
      where number = 103
         and type='C'

/*
**  If no option name is given, the procedure will just print out all the
**  options and their values.
*/
if @configname is NULL
   begin
      select name, minimum = low, maximum = high,
         config_value = c.value,
         run_value = master.dbo.syscurconfigs.value
      from master.dbo.spt_values, master.dbo.sysconfigures c, master.dbo.syscurconfigs
      where type = 'C'
         and number = c.config
         and number = master.dbo.syscurconfigs.config

         and
             ((c.status & 2 <> 0 and @show_advance = 1)
                  OR
              (c.status & 2  = 0)
             )
      order by lower(name)

      return (0)
   end

/*
**  Use @configname and try to find the right option.
**  If there isn't just one, print appropriate diagnostics and return.
*/
select @configcount = count(*), @fullconfigname = min (v.name), @prevvalue = min (c.value)
   from master.dbo.spt_values v ,master.dbo.sysconfigures c
   where v.name like '%' + @configname + '%' and v.type = 'C'
      and v.number = c.config
      and
            ((c.status & 2 <> 0 and @show_advance = 1)
                  OR
             (c.status & 2  = 0)
            )

/*
**  If no option, show the user what the options are.
*/
if @configcount = 0
   begin
      raiserror (15123,-1,-1,@configname)

      print ' '
      raiserror (15456,-1,-1)

      /*
      ** Show the user what the options are.
      */
      select name, minimum = low, maximum = high,
         config_value = c.value,
         run_value = master.dbo.syscurconfigs.value
      from master.dbo.spt_values, master.dbo.sysconfigures c, master.dbo.syscurconfigs
      where type = 'C'
         and number = c.config
         and number = master.dbo.syscurconfigs.config

         and
             ((c.status & 2 <> 0 and @show_advance = 1)
                   OR
              (c.status & 2  = 0)
             )

      return (1)
   end

/*
**  If more than one option like @configname, show the duplicates and return.
*/
if @configcount > 1
   begin
      raiserror (15124,-1,-1,@configname)
      print ' '

      select duplicate_options = name
      from master.dbo.spt_values,master.dbo.sysconfigures c
      where name like '%' + @configname + '%'
         and type = 'C'
         and number = c.config
         and
             ((c.status & 2 <> 0 and @show_advance = 1)
                   OR
              (c.status & 2  = 0)
             )

      return (1)
   end
else
   /* There must be exactly one, so get the full name. */
   select @configname = name --,@value_in_sysconfigures = c.value
      from master.dbo.spt_values,master.dbo.sysconfigures c
      where name like '%' + @configname + '%' and type = 'C'
         and number = c.config
         and
             ((c.status & 2 <> 0 and @show_advance = 1)
                   OR
              (c.status & 2  = 0)
             )

/*
** If @configvalue is NULL, just show the current state of the option.
*/
if @configvalue is null
begin

   select       v.name
               ,v.low   as 'minimum'
               ,v.high  as 'maximum'
               ,c.value as 'config_value'
               ,u.value as 'run_value'
         from
                master.dbo.spt_values     v  left outer join
                master.dbo.sysconfigures  c  on v.number = c.config
                                             left outer join
                master.dbo.syscurconfigs  u  on v.number = u.config
         where
                v.type = 'C  '
         and    v.name like '%' + @configname + '%'
         and
               ((c.status & 2 <> 0 and @show_advance = 1)
                     OR
                (c.status & 2  = 0)
               )

   return (0)
end

/*
**  Check.Permissions
*/
if (not is_srvrolemember('serveradmin') = 1)
   begin
      raiserror(15247,-1,-1)
      return (1)
   end

/*
**  Now get the configuration number.
*/
select @confignum = number
   from master.dbo.spt_values,master.dbo.sysconfigures c
   where type = 'C'
      and (@configvalue between low and high or @configvalue = 0)
      and name like '%' + @configname + '%'
      and number = c.config
      and
            ((c.status & 2 <> 0 and @show_advance = 1)
                  OR
             (c.status & 2  = 0)
            )

/*
**  If this is the number of default language, we want to make sure
**  that the new value is a valid language id in Syslanguages.
*/
if @confignum = 124
   begin
   if not exists (select * from master.dbo.syslanguages
         where langid = @configvalue)
      begin
         /* 0 is default language, us_english */
         if @configvalue <> 0
            begin
               raiserror(15127,-1,-1)
               return (1)
            end
      end
   end

/*
**  If this is the number of kernel language, we want to make sure
**  that the new value is a valid language id in Syslanguages.
*/
if @confignum = 132
   begin
   if not exists (select * from master.dbo.syslanguages
         where langid = @configvalue)
      begin
         /* 0 is default language, us_english */
         if @configvalue <> 0
            begin
               raiserror(15028,-1,-1)
               return (1)
            end
      end
   end

/*
**  "user options" should not try to set incompatible options/values.
*/
if @confignum = 1534  --"user options"
   begin

   if (@configvalue & (1024+2048) = (1024+2048)) --ansi_null_default_on/off
      begin
      raiserror(15303,-1,-1,@configvalue)
      return (1)
      end
   end

/*
**  Although the @configname is good, @configvalue wasn't in range.
*/
if @confignum is NULL
   begin
   raiserror(15129,-1,-1,@configvalue,@configname)
   return (1)
   end

--Msg 15002, but in 6.5 allow this inside a txn (not check @@trancount) #12828.

/*
**  Now update sysconfigures.
*/
update master.dbo.sysconfigures set value = @configvalue
   where config = @confignum

/*
** Flush the procedure cache - this is to account for options which become
** effective immediately (ie. dont need a server restart).
*/
dbcc freeproccache

raiserror(15457,-1,-1, @fullconfigname, @prevvalue, @configvalue) with log

return (0) -- sp_configure
go


checkpoint
go



raiserror(15339,-1,-1,'sp_dbremove')
go
create procedure sp_dbremove --- 1996/04/08 00:00
@dbname sysname = null,
@dropdev varchar(10) = null
as
	declare @dbid int
	declare @devname sysname
	declare @physname varchar(255)

	if @dbname is null
		begin
			raiserror(15131,-1,-1)
			return(1)
		end

	if lower(@dropdev) <> 'dropdev' and @dropdev is not null
		begin
			raiserror(15131,-1,-1)
			return(1)
		end

	/* Check to see if database exists. */
	select @dbid = null
	select @dbid = dbid from master.dbo.sysdatabases where name=@dbname
	if @dbid is null
		begin
			raiserror(15010,-1,-1,@dbname)
			return(1)
		end

	/* Make sure no one is in the db. */
	if (select count(*) from master.dbo.sysprocesses where dbid = @dbid) > 0
		begin
			raiserror(15069,-1,-1)
			return (1)
		end

	update master.dbo.sysdatabases set status = 256 where dbid=@dbid
	dbcc dbrepair(@dbname,dropdb,noinit)
	raiserror(15458,-1,-1)

	return(0)
-- sp_dbremove
go




raiserror(15339,-1,-1,'sp_create_removable')
go
create procedure sp_create_removable

@dbname		sysname = null,	/* name of db */
@syslogical	sysname = null,	/* logical name of system device */
@sysphysical	nvarchar (260) = null,	/* physical name of system device */
@syssize	int = null,		/* size of sys device in Meg. */
@loglogical	sysname = null,	/* logical name of log device */
@logphysical	nvarchar (260) = null,	/* physical name of log device */
@logsize	int = null,		/* size of log device in Meg. */
@datalogical1	sysname = null,	/* logical name of data device */
@dataphysical1	nvarchar (260) = null,	/* physical name of data device */
@datasize1	int = null,		/* size of data device in Meg. */
@datalogical2	sysname = null,	/* logical name of data device */
@dataphysical2	nvarchar (260) = null,	/* physical name of data device */
@datasize2	int = null,		/* size of data device in Meg. */
@datalogical3	sysname = null,	/* logical name of data device */
@dataphysical3	nvarchar (260) = null,	/* physical name of data device */
@datasize3	int = null,		/* size of data device in Meg. */
@datalogical4	sysname = null,	/* logical name of data device */
@dataphysical4	nvarchar (260) = null,	/* physical name of data device */
@datasize4	int = null,		/* size of data device in Meg. */
@datalogical5	sysname = null,	/* logical name of data device */
@dataphysical5	nvarchar (260) = null,	/* physical name of data device */
@datasize5	int = null,		/* size of data device in Meg. */
@datalogical6	sysname = null,	/* logical name of data device */
@dataphysical6	nvarchar (260) = null,	/* physical name of data device */
@datasize6	int = null,		/* size of data device in Meg. */
@datalogical7	sysname = null,	/* logical name of data device */
@dataphysical7	nvarchar (260) = null,	/* physical name of data device */
@datasize7	int = null,		/* size of data device in Meg. */
@datalogical8	sysname = null,	/* logical name of data device */
@dataphysical8	nvarchar (260) = null,	/* physical name of data device */
@datasize8	int = null,		/* size of data device in Meg. */
@datalogical9	sysname = null,	/* logical name of data device */
@dataphysical9	nvarchar (260) = null,	/* physical name of data device */
@datasize9	int = null,		/* size of data device in Meg. */
@datalogical10	sysname = null,	/* logical name of data device */
@dataphysical10	nvarchar (260) = null,	/* physical name of data device */
@datasize10	int = null,		/* size of data device in Meg. */
@datalogical11	sysname = null,	/* logical name of data device */
@dataphysical11	nvarchar (260) = null,	/* physical name of data device */
@datasize11	int = null,		/* size of data device in Meg. */
@datalogical12	sysname = null,	/* logical name of data device */
@dataphysical12	nvarchar (260) = null,	/* physical name of data device */
@datasize12	int = null,		/* size of data device in Meg. */
@datalogical13	sysname = null,	/* logical name of data device */
@dataphysical13	nvarchar (260) = null,	/* physical name of data device */
@datasize13	int = null,		/* size of data device in Meg. */
@datalogical14	sysname = null,	/* logical name of data device */
@dataphysical14	nvarchar (260) = null,	/* physical name of data device */
@datasize14	int = null,		/* size of data device in Meg. */
@datalogical15	sysname = null,	/* logical name of data device */
@dataphysical15	nvarchar (260) = null,	/* physical name of data device */
@datasize15	int = null,		/* size of data device in Meg. */
@datalogical16	sysname = null,	/* logical name of data device */
@dataphysical16 nvarchar (260) = null,	/* physical name of data device */
@datasize16	int = null		/* size of data device in Meg. */

as

declare @retcode int,
	@exec_str nvarchar (460),
	@numdevs int

if (not (is_srvrolemember('sysadmin') = 1)) -- Make sure that it's the SA executing this.
	begin
		raiserror(15247,-1,-1)
		return(1)
	end

if @dbname is null
	or @syslogical is null
	or @sysphysical is null
	or @syssize is null
	or @loglogical is null
	or @logphysical is null
	or @logsize is null
	or @datalogical1 is null
	or @dataphysical1 is null
	or @datasize1 is null
		begin
			raiserror (15261,-1,-1)
			return (1)
		end

if exists (select * from master.dbo.sysdatabases where name = @dbname)
	begin
		raiserror(15032,-1,-1,@dbname)
		return(1)
	end

/* Check to verify that valid sizes were supplied for required devices. */
if @syssize < 1 or @logsize < 1 or @datasize1 < 1
	begin
		raiserror (15262,-1,-1)
		return(1)
	end

/* Check to see if a valid database name was supplied. */
exec @retcode = sp_validname @dbname
if @retcode <> 0
	return(1)

/* valid syslogical? */
exec @retcode = sp_validname @syslogical
if @retcode <> 0
	return(1)

/* valid loglogical? */
exec @retcode = sp_validname @loglogical
if @retcode <> 0
	return(1)

/* valid datalogical1? */
exec @retcode = sp_validname @datalogical1
if @retcode <> 0
	return(1)


/* Create the database's system device segment. */
select @exec_str = 'CREATE DATABASE '
		+ quotename( @dbname , '[')
		+ ' ON (NAME ='
		+ quotename( @syslogical , '[')
		+ ',FILENAME ='
		+ ''''
		+ @sysphysical
		+ ''''
		+ ',SIZE ='
		+ convert(varchar(28),@syssize)
		+ ') LOG ON (NAME='
		+ quotename( @loglogical , '[')
		+ ',FILENAME ='
		+ ''''
		+ @logphysical
		+ ''''
		+ ',SIZE ='
		+ convert(varchar(28),@logsize)
		+ ')'
exec(@exec_str)

if @@error <> 0
	begin
		raiserror(15264,-1,-1,'system or log')
		return(1)
	end

-- Add a filegroup for data
select @exec_str = 'ALTER DATABASE '
		+ quotename( @dbname , '[')
		+ ' ADD FILEGROUP readonlyfilegroup'

exec(@exec_str)

if @@error <> 0
	begin
		raiserror(15264,-1,-1,'user filegroup')
		return(1)
	end

select @exec_str = 'ALTER DATABASE '
		+ quotename( @dbname , '[')
		+' ADD FILE (NAME ='
		+ quotename( @datalogical1 , '[')
		+ ',FILENAME ='
		+ ''''
		+ @dataphysical1
		+ ''''
		+ ',SIZE ='
		+ convert(varchar(28),@datasize1)
		+ ') TO FILEGROUP readonlyfilegroup'
		exec(@exec_str)

if @@error <> 0
	begin
		raiserror(15264,-1,-1,'user data')
		exec ('drop database '+ @dbname)
		return(1)
	end

-- Make this the default filegroup
select @exec_str = 'ALTER DATABASE '
		+ quotename( @dbname , '[')
		+ ' MODIFY FILEGROUP readonlyfilegroup DEFAULT'

exec(@exec_str)

if @@error <> 0
	begin
		raiserror(15264,-1,-1,'default filegroup')
		return(1)
	end


/* Check out optional data devices. */

if @datalogical2 is not null
begin
	select @exec_str = 'ALTER DATABASE '
		+ quotename( @dbname , '[')
		+' ADD FILE (NAME ='
		+ quotename( @datalogical2 , '[')
		+ ',FILENAME ='
		+ ''''
		+ @dataphysical2
		+ ''''
		+ ',SIZE ='
		+ convert(varchar(28),@datasize2)
		+ ') TO FILEGROUP readonlyfilegroup'
	exec(@exec_str)
	if @retcode <> 0
	begin
		raiserror(15269,-1,-1,@datalogical2)
		exec ('drop database '+ @dbname)
		return(1)
	end
	select @numdevs = 2
end
else goto no_more_devs

if @datalogical3 is not null
begin
	select @exec_str = 'ALTER DATABASE '
		+ quotename( @dbname , '[')
		+' ADD FILE (NAME ='
		+ quotename( @datalogical3 , '[')
		+ ',FILENAME ='
		+ ''''
		+ @dataphysical3
		+ ''''
		+ ',SIZE ='
		+ convert(varchar(28),@datasize3)
		+ ') TO FILEGROUP readonlyfilegroup'
	exec(@exec_str)
	if @retcode <> 0
	begin
		raiserror(15269,-1,-1,@datalogical3)
		exec ('drop database '+ @dbname)
		return(1)
	end
	select @numdevs = 3
end
else goto no_more_devs

if @datalogical4 is not null
begin
	select @exec_str = 'ALTER DATABASE '
		+ quotename( @dbname , '[')
		+' ADD FILE (NAME ='
		+ quotename( @datalogical4 , '[')
		+ ',FILENAME ='
		+ ''''
		+ @dataphysical4
		+ ''''
		+ ',SIZE ='
		+ convert(varchar(28),@datasize4)
		+ ') TO FILEGROUP readonlyfilegroup'
	exec(@exec_str)
	if @retcode <> 0
	begin
		raiserror(15269,-1,-1,@datalogical4)
		exec ('drop database '+ @dbname)
		return(1)
	end
	select @numdevs = 4
end
else goto no_more_devs

if @datalogical5 is not null
begin
	select @exec_str = 'ALTER DATABASE '
		+ quotename( @dbname , '[')
		+' ADD FILE (NAME ='
		+ quotename( @datalogical5 , '[')
		+ ',FILENAME ='
		+ ''''
		+ @dataphysical5
		+ ''''
		+ ',SIZE ='
		+ convert(varchar(28),@datasize5)
		+ ') TO FILEGROUP readonlyfilegroup'
	exec(@exec_str)
	if @retcode <> 0
	begin
		raiserror(15269,-1,-1,@datalogical5)
		exec ('drop database '+ @dbname)
		return(1)
	end
	select @numdevs = 5
end
else goto no_more_devs

if @datalogical6 is not null
begin
	select @exec_str = 'ALTER DATABASE '
		+ quotename( @dbname , '[')
		+' ADD FILE (NAME ='
		+ quotename( @datalogical6 , '[')
		+ ',FILENAME ='
		+ ''''
		+ @dataphysical6
		+ ''''
		+ ',SIZE ='
		+ convert(varchar(28),@datasize6)
		+ ') TO FILEGROUP readonlyfilegroup'
	exec(@exec_str)
	if @retcode <> 0
	begin
		raiserror(15269,-1,-1,@datalogical6)
		exec ('drop database '+ @dbname)
		return(1)
	end
	select @numdevs = 6
end
else goto no_more_devs

if @datalogical7 is not null
begin
	select @exec_str = 'ALTER DATABASE '
		+ quotename( @dbname , '[')
		+' ADD FILE (NAME ='
		+ quotename( @datalogical7 , '[')
		+ ',FILENAME ='
		+ ''''
		+ @dataphysical7
		+ ''''
		+ ',SIZE ='
		+ convert(varchar(28),@datasize7)
		+ ') TO FILEGROUP readonlyfilegroup'
	exec(@exec_str)
	if @retcode <> 0
	begin
		raiserror(15269,-1,-1,@datalogical7)
		exec ('drop database '+ @dbname)
		return(1)
	end
	select @numdevs = 7
end
else goto no_more_devs

if @datalogical8 is not null
begin
	select @exec_str = 'ALTER DATABASE '
		+ quotename( @dbname , '[')
		+' ADD FILE (NAME ='
		+ quotename( @datalogical8 , '[')
		+ ',FILENAME ='
		+ ''''
		+ @dataphysical8
		+ ''''
		+ ',SIZE ='
		+ convert(varchar(28),@datasize8)
		+ ') TO FILEGROUP readonlyfilegroup'
	exec(@exec_str)
	if @retcode <> 0
	begin
		raiserror(15269,-1,-1,@datalogical8)
		exec ('drop database '+ @dbname)
		return(1)
	end
	select @numdevs = 8
end
else goto no_more_devs
if @datalogical9 is not null
begin
	select @exec_str = 'ALTER DATABASE '
		+ quotename( @dbname , '[')
		+' ADD FILE (NAME ='
		+ quotename( @datalogical9 , '[')
		+ ',FILENAME ='
		+ ''''
		+ @dataphysical9
		+ ''''
		+ ',SIZE ='
		+ convert(varchar(28),@datasize9)
		+ ') TO FILEGROUP readonlyfilegroup'
	exec(@exec_str)
	if @retcode <> 0
	begin
		raiserror(15269,-1,-1,@datalogical9)
		exec ('drop database '+ @dbname)
		return(1)
	end
	select @numdevs = 9
end
else goto no_more_devs

if @datalogical10 is not null
begin
	select @exec_str = 'ALTER DATABASE '
		+ quotename( @dbname , '[')
		+' ADD FILE (NAME ='
		+ quotename( @datalogical10 , '[')
		+ ',FILENAME ='
		+ ''''
		+ @dataphysical10
		+ ''''
		+ ',SIZE ='
		+ convert(varchar(28),@datasize10)
		+ ') TO FILEGROUP readonlyfilegroup'
	exec(@exec_str)
	if @retcode <> 0
	begin
		raiserror(15269,-1,-1,@datalogical10)
		exec ('drop database '+ @dbname)
		return(1)
	end
	select @numdevs = 10
end
else goto no_more_devs

if @datalogical11 is not null
begin
	select @exec_str = 'ALTER DATABASE '
		+ quotename( @dbname , '[')
		+' ADD FILE (NAME ='
		+ quotename( @datalogical11 , '[')
		+ ',FILENAME ='
		+ ''''
		+ @dataphysical11
		+ ''''
		+ ',SIZE ='
		+ convert(varchar(28),@datasize11)
		+ ') TO FILEGROUP readonlyfilegroup'
	exec(@exec_str)
	if @retcode <> 0
	begin
		raiserror(15269,-1,-1,@datalogical11)
		exec ('drop database '+ @dbname)
		return(1)
	end
	select @numdevs = 11
end
else goto no_more_devs

if @datalogical12 is not null
begin
	select @exec_str = 'ALTER DATABASE '
		+ quotename( @dbname , '[')
		+' ADD FILE (NAME ='
		+ quotename( @datalogical12 , '[')
		+ ',FILENAME ='
		+ ''''
		+ @dataphysical12
		+ ''''
		+ ',SIZE ='
		+ convert(varchar(28),@datasize12)
		+ ') TO FILEGROUP readonlyfilegroup'
	exec(@exec_str)
	if @retcode <> 0
	begin
		raiserror(15269,-1,-1,@datalogical12)
		exec ('drop database '+ @dbname)
		return(1)
	end
	select @numdevs = 12
end
else goto no_more_devs

if @datalogical13 is not null
begin
	select @exec_str = 'ALTER DATABASE '
		+ quotename( @dbname , '[')
		+' ADD FILE (NAME ='
		+ quotename( @datalogical13 , '[')
		+ ',FILENAME ='
		+ ''''
		+ @dataphysical13
		+ ''''
		+ ',SIZE ='
		+ convert(varchar(28),@datasize13)
		+ ') TO FILEGROUP readonlyfilegroup'
	exec(@exec_str)
	if @retcode <> 0
	begin
		raiserror(15269,-1,-1,@datalogical13)
		exec ('drop database '+ @dbname)
		return(1)
	end
	select @numdevs = 13
end
else goto no_more_devs

if @datalogical14 is not null
begin
	select @exec_str = 'ALTER DATABASE '
		+ quotename( @dbname , '[')
		+' ADD FILE (NAME ='
		+ quotename( @datalogical14 , '[')
		+ ',FILENAME ='
		+ ''''
		+ @dataphysical14
		+ ''''
		+ ',SIZE ='
		+ convert(varchar(28),@datasize14)
		+ ') TO FILEGROUP readonlyfilegroup'
	exec(@exec_str)
	if @retcode <> 0
	begin
		raiserror(15269,-1,-1,@datalogical14)
		exec ('drop database '+ @dbname)
		return(1)
	end
	select @numdevs = 14
end
else goto no_more_devs

if @datalogical15 is not null
begin
	select @exec_str = 'ALTER DATABASE '
		+ quotename( @dbname , '[')
		+' ADD FILE (NAME ='
		+ quotename( @datalogical15 , '[')
		+ ',FILENAME ='
		+ ''''
		+ @dataphysical15
		+ ''''
		+ ',SIZE ='
		+ convert(varchar(28),@datasize15)
		+ ') TO FILEGROUP readonlyfilegroup'
	exec(@exec_str)
	if @retcode <> 0
	begin
		raiserror(15269,-1,-1,@datalogical15)
		exec ('drop database '+ @dbname)
		return(1)
	end
	select @numdevs = 15
end
else goto no_more_devs

if @datalogical16 is not null
begin
	select @exec_str = 'ALTER DATABASE '
		+ quotename( @dbname , '[')
		+' ADD FILE (NAME ='
		+ quotename( @datalogical16 , '[')
		+ ',FILENAME ='
		+ ''''
		+ @dataphysical16
		+ ''''
		+ ',SIZE ='
		+ convert(varchar(28),@datasize16)
		+ ') TO FILEGROUP readonlyfilegroup'
	exec(@exec_str)
	if @retcode <> 0
	begin
		raiserror(15269,-1,-1,@datalogical16)
		exec ('drop database '+ @dbname)
		return(1)
	end
	select @numdevs = 16
end

no_more_devs:


return(0) -- sp_create_removable
go



raiserror(15339,-1,-1,'sp_depends')
go
create procedure sp_depends  --- 1996/08/09 16:51
@objname nvarchar(776)		/* the object we want to check */
as

declare @objid int			/* the id of the object we want */
declare @found_some bit			/* flag for dependencies found */
declare @dbname sysname

/*
**  Make sure the @objname is local to the current database.
*/

select @dbname = parsename(@objname,3)

if @dbname is not null and @dbname <> db_name()
	begin
		raiserror(15250,-1,-1)
		return (1)
	end

/*
**  See if @objname exists.
*/
select @objid = object_id(@objname)
if @objid is null
	begin
		select @dbname = db_name()
		raiserror(15009,-1,-1,@objname,@dbname)
		return (1)
	end

/*
**  Initialize @found_some to indicate that we haven't seen any dependencies.
*/
select @found_some = 0

set nocount on

/*
**  Print out the particulars about the local dependencies.
*/
if exists (select *
		from sysdepends
			where id = @objid)
begin
	raiserror(15459,-1,-1)
	select		 'name' = (s6.name+ '.' + o1.name),
			 type = substring(v2.name, 5, 16),
			 updated = substring(u4.name, 1, 7),
			 selected = substring(w5.name, 1, 8),
             'column' = col_name(d3.depid, d3.depnumber)
		from	 sysobjects		o1
			,master.dbo.spt_values	v2
			,sysdepends		d3
			,master.dbo.spt_values	u4
			,master.dbo.spt_values	w5 --11667
			,sysusers		s6
		where	 o1.id = d3.depid
		and	 o1.xtype = substring(v2.name,1,2) collate database_default and v2.type = 'O9T'
		and	 u4.type = 'B' and u4.number = d3.resultobj
		and	 w5.type = 'B' and w5.number = d3.readobj|d3.selall
		and	 d3.id = @objid
		and	 o1.uid = s6.uid
		and deptype < 2

	select @found_some = 1
end

/*
**  Now check for things that depend on the object.
*/
if exists (select *
		from sysdepends
			where depid = @objid)
begin
		raiserror(15460,-1,-1)
	select distinct 'name' = (s.name + '.' + o.name),
		type = substring(v.name, 5, 16)
			from sysobjects o, master.dbo.spt_values v, sysdepends d,
				sysusers s
			where o.id = d.id
				and o.xtype = substring(v.name,1,2) collate database_default and v.type = 'O9T'
				and d.depid = @objid
				and o.uid = s.uid
				and deptype < 2

	select @found_some = 1
end

/*
**  Did we find anything in sysdepends?
*/
if @found_some = 0
	raiserror(15461,-1,-1)

set nocount off

return (0) -- sp_depends
go

raiserror(15339,-1,-1,'sp_detach_db')
go
create procedure sp_detach_db
@dbname sysname = null,
@skipchecks nvarchar(10) = null
as
declare @dbid int
declare @exec_stmt nvarchar(540)
	if @dbname is null
		begin
			raiserror(15354,-1,-1)
			return(1)
		end

	if lower(@skipchecks) <> N'true'
		and lower(@skipchecks) <> N'false'
		and @skipchecks is not null
		begin
			raiserror(15354,-1,-1)
			return(1)
		end

	select @dbid = null
	select @dbid = dbid from master.dbo.sysdatabases where name=@dbname
	if @dbid is null
		begin
			raiserror(15010,-1,-1,@dbname)
			return(1)
		end

	-- make sure not trying to detach within a transaction
	if @@trancount > 0
		begin
			raiserror(226,-1,-1,'SP_DETACH_DB')
			return(1)
		end

	-- run UPDATE STATISTICS on all tables in the database so they are current
	-- when transferred to READONLY media
	if lower(@skipchecks) <> N'true'
		begin
			print 'Running UPDATE STATISTICS on all tables'
			select @exec_stmt = 'USE ' + quotename( @dbname , '[')
			+ ' exec sp_updatestats ''RESAMPLE'' '
			exec (@exec_stmt)
		end

	select @exec_stmt = 'DBCC DETACHDB ('
			+ quotename( @dbname , '[')
			+ ')'
	exec (@exec_stmt)
	return (0) -- sp_detach_db
go


raiserror(15339,-1,-1,'sp_diskdefault')
go
create procedure sp_diskdefault --- 1996/04/08 00:00
@logicalname	sysname,		/* logical name of the device */
@defstatus	varchar(15)		/* turn on or off */
as

/*
**  If we're in a transaction, disallow this since it might make recovery
**  impossible.
*/
set implicit_transactions off
if @@trancount > 0
	begin
           raiserror(15002,-1,-1,'sp_diskdefault')
	   return (1)
	end

/*
**  Only the SA can run this sproc.
*/
if not is_srvrolemember('diskadmin') = 1
	begin
		raiserror(15247,-1,-1)
		return (1)
	end

/*
**  Make sure that a device with @logicalname exists.
*/
if not exists (select * from master.dbo.sysdevices where name = @logicalname)
	begin
		raiserror(15012,-1,-1,@logicalname)
		return (1)
	end

/*
**  Make sure that it is a database disk and not a dump device.
*/
if exists (select * from master.dbo.sysdevices
		where name = @logicalname
			and status & 16 = 16)
	begin
		raiserror(15035,-1,-1,@logicalname)
		return (1)
	end

/*
**  Make sure that the database disk is NOT a RAM device.
*/
if exists (select *
		from master.dbo.sysdevices
		where name = @logicalname
			and status & 2048 = 2048 )
	begin
		raiserror(15139,-1,-1)
		return (1)
	end

if @defstatus = 'defaulton'
	begin
		update master.dbo.sysdevices set status = status | 1
			where name = @logicalname
		return (0)
	end

if @defstatus = 'defaultoff'
	begin
		update master.dbo.sysdevices set status = status & ~1
			where name = @logicalname
		return (0)
	end

/*
**  @defstatus must be 'defaulton' or 'defaultoff'
*/
raiserror(15140,-1,-1)

return (1) -- sp_diskdefault
go

checkpoint
go


raiserror(15339,-1,-1,'sp_dropdevice')
go
create procedure sp_dropdevice --- 1996/04/08 00:00
@logicalname	sysname,		-- logical name of the device
@delfile	varchar(7) = null	-- optional param. to delete disk file
as


/*
** See if user specified something for @delfile and, if so, validate it.
*/
if @delfile is not null
	begin
		select @delfile = lower(@delfile)

		if @delfile <> 'delfile'
			begin
				raiserror(15216,-1,-1,@delfile)
				return(1)
			end
	end

/*
**  If we're in a transaction, disallow this since it might make recovery
**  impossible.
*/
set implicit_transactions off
if @@trancount > 0
	begin
		raiserror(15002,-1,-1,'sp_dropdevice')
		return (1)
	end

/*
**  Only the system administrator (SA) can run this command.
**  Check to make sure the executor is the sa.
*/
if not is_srvrolemember('diskadmin') = 1
	begin
		raiserror(15247,-1,-1)
		return (1)
	end

/*
**  Check and make sure that the device actually exists.
*/
if not exists (select * from master.dbo.sysdevices where name = @logicalname)
	begin
		raiserror(15012,-1,-1,@logicalname)
		return (1)
	end


/*
** Drop the device.
*/

if @delfile = 'delfile'
	dbcc dbrepair
	('', 'dropdevice',@logicalname, 1)  WITH NO_INFOMSGS
else
	dbcc dbrepair
	('', 'dropdevice',@logicalname, 0)  WITH NO_INFOMSGS


if @@error <> 0
	return (1)

raiserror(15463,-1,-1)

return (0) -- sp_dropdevice
go



raiserror(15339,-1,-1,'sp_dropmessage')
go
create procedure sp_dropmessage --- 1996/04/08 00:00
@msgnum int = null,		-- Number of message to drop.
@lang sysname = null	-- Language of message to drop (or 'ALL')
as
declare @retcode int
declare @msglangid smallint

	-- Must be ServerAdmin to manage messages
	if is_srvrolemember('serveradmin') = 0
	begin
		raiserror(15247,-1,-1)
		return (1)
	end

/*
** If no message id, show usage
*/
if @msgnum is null
	begin
		raiserror(15177,-1,-1)
		return (1)
	end

/*
** Message id must be > 50000
*/
if @msgnum < 50001
	begin
		raiserror(15178,-1,-1)
		return(1)
	end

if (select count(*) from master.dbo.sysmessages where error=@msgnum) = 0
	begin
		raiserror(15179,-1,-1,@msgnum)
		return(1)
	end

/*
** Verify the language
*/
if @lang is null
	select @lang = @@language
if upper(@lang) <> 'ALL'
begin
	begin
		exec @retcode = sp_validlang @lang
		if @retcode <>  0
			return(1)
	end
	/*
	** Get langid from syslanguages; us_english won't exist, so use 0.
	*/
	select @msglangid = isnull((select msglangid from master.dbo.syslanguages where name = @lang or alias = @lang),1033)
end

/*
** The us_english version must be the last one to be dropped
*/
if (@msglangid = 1033) and (select count(*) from master.dbo.sysmessages where error = @msgnum) > 1
begin
	raiserror(15280,-1,-1)
	return(1)
end

/*
**  Drop the message.
*/
if upper(@lang) = 'ALL'
	delete from master.dbo.sysmessages where error = @msgnum
else
	delete from master.dbo.sysmessages where error = @msgnum and msglangid = @msglangid

return (0) -- sp_dropmessage
go


raiserror(15339,-1,-1,'sp_droptype')
go
create procedure sp_droptype --- 1996/04/08 00:00
@typename sysname			/* the user type to drop */
as

declare @typeid smallint		/* the typeid of the usertype to drop */

/*
**  Initialize @typeid so we can tell if we can't find it.
*/
select @typeid = 0

/*
**  Find the user type with @typename.  It must be a user type (xusertype > 256)
**  and it must be owned by the person (or special role) running the procedure.
*/
select @typeid = xusertype
	from systypes
		where name = @typename and xusertype > 256
		AND (is_member('db_owner') = 1 OR is_member('db_ddladmin') = 1 OR is_member(user_name(uid))=1)

if @typeid = 0
	begin
		raiserror(15105,-1,-1)
		return (1)
	end

/*
**  Check to see if the type is being used.  If it is, it can't be dropped.
*/
if exists (select * from syscolumns where xusertype = @typeid)
	begin
		raiserror(15180,-1,-1)

		/*
		**  Show where it's being used.
		*/
		select object = o.name, type = o.xtype, owner = u.name,
			[column] = c.name, datatype = t.name
		from syscolumns c, systypes t, sysusers u, sysobjects o
		where c.xusertype = @typeid
			and t.xusertype = @typeid
			and o.uid = u.uid
			and c.id = o.id
		order by object, [column]

		return (1)
	end

/*
**  Everything is consistent so drop the type.
*/
delete from systypes where xusertype = @typeid

delete from sysproperties
where type =  1 and id = 0 and
	smallid = @typeid

raiserror(15467,-1,-1)

return (0) -- sp_droptype
go


checkpoint
go

raiserror(15339,-1,-1,'sp_dropremotelogin')
go
create procedure sp_dropremotelogin --- 1996/04/08 00:00
	@remoteserver	sysname,		/* name of remote server */
	@loginame sysname = NULL,		/* user's local user name */
	@remotename sysname = NULL		/* user's remote name */
as
	declare @srvid smallint
	declare @sid varbinary(85)
	declare @count int

	-- DISALLOW USER XACT --
	set implicit_transactions off
	if @@trancount > 0
	begin
		raiserror(15002,-1,-1,'sp_dropremotelogin')
		return (1)
	end

    -- CHECK PERMISSIONS
    if not (is_srvrolemember('securityadmin') = 1)
    begin
		raiserror(15247,-1,-1)
        return (1)
    end

	-- VALIDATE SERVER NAME --
	select @srvid = srvid from master.dbo.sysservers where srvname = @remoteserver
	if @srvid is null
	begin
		raiserror(15015,-1,-1,@remoteserver)
		return (1)
	end

	-- CHECK FOR INVALID PARAMETER SYNTAX --
	if @loginame is null and @remotename is not null
	begin
		raiserror(15600,-1,-1,'sp_dropremotelogin')
		return (1)
	end

	-- VALIDATE @loginame --
	if @loginame is not null
	begin
		select @sid = sid from master.dbo.syslogins where loginname = @loginame
					AND isntname = 0        -- cannot remap to NT login
		if @sid is null
		begin
			raiserror(15067,-1,-1,@loginame)
			return (1)
		end
	end

	-- First remove the isrpcinmap bit from all rows which are also outmap
	update master.dbo.sysxlogins set xstatus = xstatus & ~32	-- isrpcinmap bit
		where srvid = @srvid AND isrpcinmap = 1 AND ishqoutmap = 1
			AND ((@sid IS NULL and sid IS NULL) or sid = @sid)
			AND ((@remotename IS NULL and name IS NULL) or name = @remotename)

	select @count = @@rowcount

	-- Delete the remote login(s) - the remaining rows with isrpcinmap set.
	delete master.dbo.sysxlogins where srvid = @srvid AND isrpcinmap = 1
			AND ((sid IS NULL and @sid IS NULL) or sid = @sid)
			AND ((@remotename IS NULL and name IS NULL) or name = @remotename)

	select @count = @count + @@rowcount

	-- IF NO ROWS UPDATED OR DELETED, ERROR --
	if @count = 0
	begin
		if (@loginame IS NULL)
			raiserror(15021,-1,-1,@remoteserver)
		else if (@remotename IS NULL)
			raiserror(15027,-1,-1,@loginame,@remoteserver)
		else
			raiserror(15185,-1,-1,@remotename,@loginame,@remoteserver)
		return (1)
	end

	-- SUCCESS --
	return (0)	-- sp_dropremotelogin
go


raiserror(15339,-1,-1,'sp_helpconstraint')
go
create proc sp_helpconstraint
    @objname nvarchar(776)			-- the table to check for constraints
   ,@nomsg   varchar(5) = 'msg'		-- 'nomsg' supresses printing of TBName (sp_help)
as
	-- PRELIM
	set nocount on

	declare	@objid			int           -- the object id of the table
			,@cnstdes		nvarchar(4000)-- string to build up index desc
			,@cnstname		sysname       -- name of const. currently under consideration
			,@i				int
			,@cnstid		int
			,@cnsttype		character(2)
			,@keys			nvarchar(2126)	--Length (16*max_identifierLength)+(15*2)+(16*3)
			,@dbname		sysname

	-- Create temp table
	create table #spcnsttab
	(
		cnst_id			int			NOT NULL
		,cnst_type			nvarchar(146) collate database_default NOT NULL   -- 128 for name + text for DEFAULT
		,cnst_name			sysname		collate database_default NOT NULL
		,cnst_nonblank_name	sysname		collate database_default NOT NULL
		,cnst_2type			character(2)	collate database_default NULL
		,cnst_disabled		bit				NULL
		,cnst_notrepl		bit				NULL
		,cnst_delcasc		bit				NULL
		,cnst_updcasc		bit				NULL
		,cnst_keys			nvarchar(2126)	collate database_default NULL	-- see @keys above for length descr
	)

	-- Check to see that the object names are local to the current database.
	select @dbname = parsename(@objname,3)

	if @dbname is not null and @dbname <> db_name()
	begin
		raiserror(15250,-1,-1)
		return (1)
	end

	-- Check to see if the table exists and initialize @objid.
	select @objid = object_id(@objname)
	if @objid is NULL
	begin
		select @dbname=db_name()
		raiserror(15009,-1,-1,@objname,@dbname)
		return (1)
	end

	-- STATIC CURSOR OVER THE TABLE'S CONSTRAINTS
	declare ms_crs_cnst cursor local static for
		select id, xtype, name from sysobjects where parent_obj = @objid
			and xtype in ('C ','PK','UQ','F ', 'D ')	-- ONLY 6.5 sysconstraints objects
		for read only

	-- Now check out each constraint, figure out its type and keys and
	-- save the info in a temporary table that we'll print out at the end.
	open ms_crs_cnst
	fetch ms_crs_cnst into @cnstid ,@cnsttype ,@cnstname
	while @@fetch_status >= 0
	begin

		if @cnsttype in ('PK','UQ')
		begin
			-- get indid and index description
			declare @indid smallint
			select	@indid = indid,
					@cnstdes = case when @cnsttype = 'PK'
								then 'PRIMARY KEY' else 'UNIQUE' end
							 + case when (status & 16)=16
								then ' (clustered)' else ' (non-clustered)' end
			from	sysindexes
			where	name = object_name(@cnstid)
					and id = @objid

			-- Format keys string
			declare @thiskey nvarchar(131) -- 128+3

			select @keys = index_col(@objname, @indid, 1), @i = 2
			if (indexkey_property(@objid, @indid, 1, 'isdescending') = 1)
				select @keys = @keys  + '(-)'

			select @thiskey = index_col(@objname, @indid, @i)
			if ((@thiskey is not null) and (indexkey_property(@objid, @indid, @i, 'isdescending') = 1))
				select @thiskey = @thiskey + '(-)'

			while (@thiskey is not null)
			begin
				select @keys = @keys + ', ' + @thiskey, @i = @i + 1
				select @thiskey = index_col(@objname, @indid, @i)
				if ((@thiskey is not null) and (indexkey_property(@objid, @indid, @i, 'isdescending') = 1))
					select @thiskey = @thiskey + '(-)'
			end

			-- ADD TO TABLE
			insert into #spcnsttab
				(cnst_id,cnst_type,cnst_name, cnst_nonblank_name,cnst_keys, cnst_2type)
			values (@cnstid, @cnstdes, @cnstname, @cnstname, @keys, @cnsttype)
		end

		else
		if @cnsttype = 'F '
		begin
			-- OBTAIN TWO TABLE IDs
			declare @fkeyid int, @rkeyid int
			select @fkeyid = fkeyid, @rkeyid = rkeyid from sysreferences where constid = @cnstid

			-- USE CURSOR OVER FOREIGN KEY COLUMNS TO BUILD COLUMN LISTS
			--	(NOTE: @keys HAS THE FKEY AND @cnstdes HAS THE RKEY COLUMN LIST)
			declare ms_crs_fkey cursor local for select fkey, rkey from sysforeignkeys where constid = @cnstid
			open ms_crs_fkey
			declare @fkeycol smallint, @rkeycol smallint
			fetch ms_crs_fkey into @fkeycol, @rkeycol
			select @keys = col_name(@fkeyid, @fkeycol), @cnstdes = col_name(@rkeyid, @rkeycol)
			fetch ms_crs_fkey into @fkeycol, @rkeycol
			while @@fetch_status >= 0
			begin
				select	@keys = @keys + ', ' + col_name(@fkeyid, @fkeycol),
						@cnstdes = @cnstdes + ', ' + col_name(@rkeyid, @rkeycol)
				fetch ms_crs_fkey into @fkeycol, @rkeycol
			end
			deallocate ms_crs_fkey

			-- ADD ROWS FOR BOTH SIDES OF FOREIGN KEY
			insert into #spcnsttab
				(cnst_id, cnst_type,cnst_name,cnst_nonblank_name,
					cnst_keys, cnst_disabled,
					cnst_notrepl, cnst_delcasc, cnst_updcasc, cnst_2type)
			values
				(@cnstid, 'FOREIGN KEY', @cnstname, @cnstname,
					@keys, ObjectProperty(@cnstid, 'CnstIsDisabled'),
					ObjectProperty(@cnstid, 'CnstIsNotRepl'),
					ObjectProperty(@cnstid, 'CnstIsDeleteCascade'),
					ObjectProperty(@cnstid, 'CnstIsUpdateCascade'),
					@cnsttype)
			insert into #spcnsttab
				(cnst_id,cnst_type,cnst_name,cnst_nonblank_name,
					cnst_keys,
					cnst_2type)
			select
				@cnstid,' ', ' ', @cnstname,
					'REFERENCES ' + db_name()
						+ '.' + rtrim(user_name(ObjectProperty(@rkeyid,'ownerid')))
						+ '.' + object_name(@rkeyid) + ' ('+@cnstdes + ')',
					@cnsttype
		end

		else
		if @cnsttype = 'C '
		begin
			select @i = 1
			select @cnstdes = text from syscomments where id = @cnstid and colid = @i
			while @cnstdes is not null
			begin
				if @i=1
					-- Check constraint
					insert into	#spcnsttab
						(cnst_id, cnst_type ,cnst_name ,cnst_nonblank_name,
							cnst_keys, cnst_disabled, cnst_notrepl, cnst_2type)
					select	@cnstid,
						case when info = 0 then 'CHECK Table Level '
							else 'CHECK on column ' + col_name(@objid ,info) end,
						@cnstname ,@cnstname ,substring(@cnstdes,1,2000),
						ObjectProperty(@cnstid, 'CnstIsDisabled'),
						ObjectProperty(@cnstid, 'CnstIsNotRepl'),
						@cnsttype
					from sysobjects	where id = @cnstid
				else
					insert into #spcnsttab (cnst_id,cnst_type,cnst_name,cnst_nonblank_name,cnst_keys, cnst_2type)
					select	@cnstid,' ' ,' ' ,@cnstname ,substring(@cnstdes,1,2000), @cnsttype

				if len(@cnstdes) > 2000
					insert into #spcnsttab (cnst_id,cnst_type,cnst_name,cnst_nonblank_name,cnst_keys, cnst_2type)
					select	@cnstid,' ' ,' ' ,@cnstname ,substring(@cnstdes,2001,2000), @cnsttype

				select @cnstdes = null
				select @i = @i + 1
				select @cnstdes = text from syscomments where id = @cnstid and colid = @i
			end
		end

		else
		if (@cnsttype = 'D ')
		begin
			select @i = 1
			select @cnstdes = text from syscomments where id = @cnstid and colid = @i
			while @cnstdes is not null
			begin
				if @i=1
					insert into	#spcnsttab
						(cnst_id,cnst_type ,cnst_name ,cnst_nonblank_name ,cnst_keys, cnst_2type)
					select @cnstid, 'DEFAULT on column ' + col_name(@objid ,info),
						@cnstname ,@cnstname ,substring(@cnstdes,1,2000), @cnsttype
					from sysobjects where id = @cnstid
				else
					insert into #spcnsttab (cnst_id,cnst_type,cnst_name,cnst_nonblank_name,cnst_keys, cnst_2type)
					select	@cnstid,' ' ,' ' ,@cnstname ,substring(@cnstdes,1,2000), @cnsttype

				if len(@cnstdes) > 2000
					insert into #spcnsttab (cnst_id,cnst_type,cnst_name,cnst_nonblank_name,cnst_keys, cnst_2type)
					select	@cnstid,' ' ,' ' ,@cnstname ,substring(@cnstdes,2001,2000), @cnsttype

				select @i = @i + 1
				select @cnstdes = null
				select @cnstdes = text from syscomments where id = @cnstid and colid = @i
			end
		end

		fetch ms_crs_cnst into @cnstid ,@cnsttype ,@cnstname
	end		--of major loop
	deallocate ms_crs_cnst

	-- Find any rules or defaults bound by the sp_bind... method.
	insert into #spcnsttab (cnst_id,cnst_type,cnst_name,cnst_nonblank_name,cnst_keys, cnst_2type)
	select c.domain,'RULE on column ' + c.name + ' (bound with sp_bindrule)',
		object_name(c.domain), object_name(c.domain), text, 'R '
	from	syscolumns c, syscomments m
	where	c.id = @objid and m.id = c.domain and ObjectProperty(c.domain, 'IsRule') = 1

	insert into #spcnsttab (cnst_id,cnst_type,cnst_name,cnst_nonblank_name,cnst_keys, cnst_2type)
	select c.cdefault, 'DEFAULT on column ' + c.name + ' (bound with sp_bindefault)',
		object_name(c.cdefault),object_name(c.cdefault), text, 'D '
	from	syscolumns c,syscomments m
	where	c.id = @objid and m.id = c.cdefault and ObjectProperty(c.cdefault, 'IsConstraint') = 0


	-- OUTPUT RESULTS: FIRST THE OBJECT NAME (if not suppressed)
	if @nomsg <> 'nomsg'
	begin
		select 'Object Name' = @objname
		print ' '
	end

	-- Now print out the contents of the temporary index table.
	if exists (select * from #spcnsttab)
		select
			'constraint_type' = cnst_type,
			'constraint_name' = cnst_name,
			'delete_action'=
					CASE
						When cnst_name = ' ' Then ' '
						When cnst_2type in ('F ') Then
							CASE When cnst_delcasc = 1
								Then 'Cascade' else 'No Action' end
						Else '(n/a)'
					END,
			'update_action'=
					CASE
						When cnst_name = ' ' Then ' '
						When cnst_2type in ('F ') Then
							CASE When cnst_updcasc = 1
								Then 'Cascade' else 'No Action' end
						Else '(n/a)'
					END,
			'status_enabled' =
					CASE
						When cnst_name = ' ' Then ' '
						When cnst_2type in ('F ','C ') Then
							CASE When cnst_disabled = 1
								then 'Disabled' else 'Enabled' end
						Else '(n/a)'
					END,
			'status_for_replication' =
					CASE
						When cnst_name = ' ' Then ' '
						When cnst_2type in ('F ','C ') Then
							CASE When cnst_notrepl = 1
								Then 'Not_For_Replication' else 'Is_For_Replication' end
						Else '(n/a)'
					END,
			'constraint_keys' = cnst_keys
		from #spcnsttab order by cnst_nonblank_name ,cnst_name desc
	else
		raiserror(15469,-1,-1) --'No constraints have been defined for this object.'

	print ' '

	if exists (select * from sysreferences where rkeyid = @objid)
		select
			'Table is referenced by foreign key' =
				db_name() + '.'
					+ rtrim(user_name(ObjectProperty(fkeyid,'ownerid')))
					+ '.' + object_name(fkeyid)
					+ ': ' + object_name(constid)
			from sysreferences where rkeyid = @objid order by 1
	else
		raiserror(15470,-1,-1) --'No foreign keys reference this table.'

	return (0) -- sp_helpconstraint
go

checkpoint
go

raiserror(15339,-1,-1,'system_function_schema.fn_dblog')
go
create function system_function_schema.fn_dblog
	(
		@start nvarchar (22) = NULL,
		@end   nvarchar (22) = NULL
	)

returns table
as
	return select * from OpenRowset (DBLog, @start, @end)
go

raiserror(15339,-1,-1,'system_function_schema.fn_helpcollations')
go
create function system_function_schema.fn_helpcollations
	(
	)

returns @tab table(name sysname NOT NULL,
	description	nvarchar(1000)	NOT NULL)
as
begin
	insert @tab
	select * from OpenRowset(collations)

	return
end -- fn_helpcollations
go

raiserror(15339,-1,-1,'system_function_schema.fn_trace_getinfo')
go
create function system_function_schema.fn_trace_getinfo
	(@handle int = 0
	)

returns @tab table(traceid int NOT NULL,
	property int NOT NULL,
	value sql_variant)
as
begin
	insert @tab
	select * from OpenRowset(TraceInfo, @handle)

	return
end -- fn_trace_getinfo
go

raiserror(15339,-1,-1,'system_function_schema.fn_trace_geteventinfo')
go
create function system_function_schema.fn_trace_geteventinfo
	(@handle int
	)

returns @tab table(eventid int NOT NULL,
	columnid int NOT NULL)
as
begin
	insert @tab
	select * from OpenRowset(TraceEventInfo, @handle)

	return
end -- fn_trace_geteventinfo
go

raiserror(15339,-1,-1,'system_function_schema.fn_trace_getfilterinfo')
go
create function system_function_schema.fn_trace_getfilterinfo
	(@handle int = 0
	)

returns @tab table(columnid int NOT NULL,
	logical_operator int NOT NULL,
	comparison_operator int NOT NULL,
	value sql_variant)
as
begin
	insert @tab
	select * from OpenRowset(TraceFilterInfo, @handle)

	return
end -- fn_trace_getfilterinfo
go


raiserror(15339,-1,-1,'system_function_schema.fn_trace_gettable')
go
create function system_function_schema.fn_trace_gettable
	(@filename nvarchar(256), 
	 @numfiles int = -1)
	 
returns table as
return select * from OpenRowset(TrcTable, @filename, @numfiles)
go


raiserror(15339,-1,-1,'system_function_schema.fn_servershareddrives')
go
create function system_function_schema.fn_servershareddrives
	(
	)

returns @tab table(DriveName nchar(1) NOT NULL)
as
begin
	insert @tab
	select * from OpenRowset(servershareddrives)

	return
end -- fn_servershareddrives
go

raiserror(15339,-1,-1,'system_function_schema.fn_virtualfilestats')
go
create function system_function_schema.fn_virtualfilestats
	(
	@DatabaseId Int = -1,
	@FileId Int = -1
	)

returns @tab table(DbId SmallInt NOT NULL, FileId SmallInt NOT NULL, TimeStamp Int NOT NULL,
		NumberReads BigInt NOT NULL, NumberWrites BigInt NOT NULL, BytesRead BigInt NOT NULL,
		BytesWritten BigInt NOT NULL, IoStallMS BigInt NOT NULL )
as
begin
	insert @tab
	select * from OpenRowset(VirtualFileStats, @DatabaseId, @FileId)

	return
end -- fn_virtualfilestats
go

raiserror(15339,-1,-1,'system_function_schema.fn_virtualservernodes')
go
create function system_function_schema.fn_virtualservernodes
	(
	)

returns @tab table(NodeName sysname NOT NULL)
as
begin
	insert @tab
	select * from OpenRowset(virtualservernodes)

	return
end -- fn_virtualservernodes
go

raiserror(15339,-1,-1,'system_function_schema.fn_get_sql')
go
create function system_function_schema.fn_get_sql
	(
	@handle binary(20)
	)
returns @tab table(dbid SmallInt,
	objectid Int,
	number SmallInt,
	encrypted Bit NOT NULL,
	text Text)
as
begin
	insert @tab
	select * from OpenRowset(FnGetSql, @handle)

	return
end -- fn_get_sql
go

raiserror(15339,-1,-1,'sp_helpdb')
go
create procedure sp_helpdb  --- 1995/12/20 15:34 #12755
@dbname sysname = NULL			/* database name to change */
as

declare @exec_stmt nvarchar(625)
declare @showdev	bit
declare @name           sysname
declare @cmd	nvarchar(279)
declare @low nvarchar(11)
declare @dbdesc varchar(600)	/* the total description for the db */
declare @propdesc varchar(40)

set nocount on

/*	Create temp table before any DMP to enure dynamic
**  Since we examine the status bits in sysdatabase and turn them
**  into english, we need a temporary table to build the descriptions.
*/
create table #spdbdesc
(
	dbname sysname,
	owner sysname,
	created nvarchar(11),
	dbid	smallint,
	dbdesc	nvarchar(600)	null,
	dbsize		nvarchar(13) null,
	cmptlevel	tinyint
)


/*
**  If no database name given, get 'em all.
*/
if @dbname is null
	select @showdev = 0
else select @showdev = 1

/*
**  See if the database exists
*/
if not exists (select * from master.dbo.sysdatabases
	where (@dbname is null or name = @dbname))
	begin
		raiserror(15010,-1,-1,@dbname)
	  return (1)
	end

select @low = convert(varchar(11),low) from master.dbo.spt_values
			where type = N'E' and number = 1
/*
**  Initialize #spdbdesc from sysdatabases
*/
insert into #spdbdesc (dbname, owner, created, dbid, cmptlevel)
		select name, suser_sname(sid), convert(nvarchar(11), crdate),
			dbid, cmptlevel from master.dbo.sysdatabases
			where (@dbname is null or name = @dbname)

/*
** Check if you have access to database
** if have access set size and collation
*/
select @low = convert(varchar(11),low) from master.dbo.spt_values
			where type = N'E' and number = 1

declare ms_crs_c1 cursor for
	select db_name (dbid) from #spdbdesc
open ms_crs_c1
fetch ms_crs_c1 into @name
while @@fetch_status >= 0
begin
	if (has_dbaccess(@name) <> 1)
	begin
	  delete #spdbdesc where current of ms_crs_c1
	  raiserror(15622,-1,-1, @name)
	end
	else
		begin
			/* Insert row for each database */
			select @exec_stmt = 'update #spdbdesc
								set dbsize = (select str(convert(dec(15),sum(size))* ' + @low + '/ 1048576,10,2)+ N'' MB'' from '
 								+ quotename(@name, N'[') + N'.dbo.sysfiles) WHERE current of ms_crs_c1'

			execute (@exec_stmt)
		end
	fetch ms_crs_c1 into @name
end
deallocate ms_crs_c1

/*
**  Now for each dbid in #spdbdesc, build the database status
**  description.
*/
declare @curdbid smallint	/* the one we're currently working on */
/*
**  Set @curdbid to the first dbid.
*/
select @curdbid = min(dbid) from #spdbdesc


while @curdbid IS NOT NULL
begin
	set @name = db_name(@curdbid)

	-- These properties always available
	SELECT @dbdesc = 'Status=' + convert(sysname,DatabasePropertyEx(@name,'Status'))
	SELECT @dbdesc = @dbdesc + ', Updateability=' + convert(sysname,DatabasePropertyEx(@name,'Updateability'))
	SELECT @dbdesc = @dbdesc + ', UserAccess=' + convert(sysname,DatabasePropertyEx(@name,'UserAccess'))
	SELECT @dbdesc = @dbdesc + ', Recovery=' + convert(sysname,DatabasePropertyEx(@name,'Recovery'))
	SELECT @dbdesc = @dbdesc + ', Version=' + convert(sysname,DatabasePropertyEx(@name,'Version'))

	-- These props only available if db not shutdown
	IF DatabaseProperty(@name, 'IsShutdown') = 0
	BEGIN
		SELECT @dbdesc = @dbdesc + ', Collation=' + convert(sysname,DatabasePropertyEx(@name,'Collation'))
		SELECT @dbdesc = @dbdesc + ', SQLSortOrder=' + convert(sysname,DatabasePropertyEx(@name,'SQLSortOrder'))
	END

	-- These are the boolean properties
	IF DatabasePropertyEx(@name,'IsAutoClose') = 1
		SELECT @dbdesc = @dbdesc + ', ' + 'IsAutoClose'
	IF DatabasePropertyEx(@name,'IsAutoShrink') = 1
		SELECT @dbdesc = @dbdesc + ', ' + 'IsAutoShrink'
	IF DatabasePropertyEx(@name,'IsInStandby') = 1
		SELECT @dbdesc = @dbdesc + ', ' + 'IsInStandby'
	IF DatabasePropertyEx(@name,'IsTornPageDetectionEnabled') = 1
		SELECT @dbdesc = @dbdesc + ', ' + 'IsTornPageDetectionEnabled'
	IF DatabasePropertyEx(@name,'IsAnsiNullDefault') = 1
		SELECT @dbdesc = @dbdesc + ', ' + 'IsAnsiNullDefault'
	IF DatabasePropertyEx(@name,'IsAnsiNullsEnabled') = 1
		SELECT @dbdesc = @dbdesc + ', ' + 'IsAnsiNullsEnabled'
	IF DatabasePropertyEx(@name,'IsAnsiPaddingEnabled') = 1
		SELECT @dbdesc = @dbdesc + ', ' + 'IsAnsiPaddingEnabled'
	IF DatabasePropertyEx(@name,'IsAnsiWarningsEnabled') = 1
		SELECT @dbdesc = @dbdesc + ', ' + 'IsAnsiWarningsEnabled'
	IF DatabasePropertyEx(@name,'IsArithmeticAbortEnabled') = 1
		SELECT @dbdesc = @dbdesc + ', ' + 'IsArithmeticAbortEnabled'
	IF DatabasePropertyEx(@name,'IsAutoCreateStatistics') = 1
		SELECT @dbdesc = @dbdesc + ', ' + 'IsAutoCreateStatistics'
	IF DatabasePropertyEx(@name,'IsAutoUpdateStatistics') = 1
		SELECT @dbdesc = @dbdesc + ', ' + 'IsAutoUpdateStatistics'
	IF DatabasePropertyEx(@name,'IsCloseCursorsOnCommitEnabled') = 1
		SELECT @dbdesc = @dbdesc + ', ' + 'IsCloseCursorsOnCommitEnabled'
	IF DatabasePropertyEx(@name,'IsFullTextEnabled') = 1
		SELECT @dbdesc = @dbdesc + ', ' + 'IsFullTextEnabled'
	IF DatabasePropertyEx(@name,'IsLocalCursorsDefault') = 1
		SELECT @dbdesc = @dbdesc + ', ' + 'IsLocalCursorsDefault'
	IF DatabasePropertyEx(@name,'IsNullConcat') = 1
		SELECT @dbdesc = @dbdesc + ', ' + 'IsNullConcat'
	IF DatabasePropertyEx(@name,'IsNumericRoundAbortEnabled') = 1
		SELECT @dbdesc = @dbdesc + ', ' + 'IsNumericRoundAbortEnabled'
	IF DatabasePropertyEx(@name,'IsQuotedIdentifiersEnabled') = 1
		SELECT @dbdesc = @dbdesc + ', ' + 'IsQuotedIdentifiersEnabled'
	IF DatabasePropertyEx(@name,'IsRecursiveTriggersEnabled') = 1
		SELECT @dbdesc = @dbdesc + ', ' + 'IsRecursiveTriggersEnabled'
	IF DatabasePropertyEx(@name,'IsMergePublished') = 1
		SELECT @dbdesc = @dbdesc + ', ' + 'IsMergePublished'
	IF DatabasePropertyEx(@name,'IsPublished') = 1
		SELECT @dbdesc = @dbdesc + ', ' + 'IsPublished'
	IF DatabasePropertyEx(@name,'IsSubscribed') = 1
		SELECT @dbdesc = @dbdesc + ', ' + 'IsSubscribed'
	IF DatabasePropertyEx(@name,'IsSyncWithBackup') = 1
		SELECT @dbdesc = @dbdesc + ', ' + 'IsSyncWithBackup'

	update #spdbdesc set dbdesc = @dbdesc where dbid = @curdbid

	/*
	**  Now get the next, if any dbid.
	*/
	select @curdbid = min(dbid) from #spdbdesc where dbid > @curdbid
end

/*
**  Now #spdbdesc is complete so we can print out the db info
*/
select name = dbname,
	db_size = dbsize,
	owner = owner,
	dbid = dbid,
	created = created,
	status = dbdesc,
    compatibility_level = cmptlevel
from  #spdbdesc
order by dbname

/*
**  If we are looking at one database, show its file allocation.
*/
if @showdev = 1 and has_dbaccess(@dbname) = 1
begin
	print N' '
	select @cmd = N'use ' +  quotename(@dbname) + N' exec sp_helpfile'
	exec (@cmd)

end
return (0) -- sp_helpdb
go

raiserror(15339,-1,-1,'sp_helpdevice')
go
create procedure sp_helpdevice --- 1996/04/08 00:00
@devname sysname = NULL		/* device to check out */
as

/*	Create temp tables before any DML to ensure dynamic
**  Create a temporary table where we can build up a translation of
**  the device status bits.
*/
create table #spdevtab
(
	name sysname		NOT NULL,
	statusdesc nvarchar(255)	null
)
/*
**  See if the device exists.
*/

if not exists (select * from master.dbo.sysdevices where
	(@devname is null or name = @devname))
	begin
		raiserror(15012,-1,-1,@devname)
		return (1)
	end

set nocount on

/*
**  Initialize the temporary table with the names of the devices.
*/
insert into #spdevtab (name)
	select name
		from master.dbo.sysdevices
		where (@devname is null or name = @devname)


/*
**  Now figure out what kind of controller type it is.
**
**  cntrltype =			0	special (data disk)
**				2	disk (dump)
**				3-4	floppy (dump)	Not supported in SQL 7.0
**				5	tape			No size information in SQL 7.0
**				6	pipe
**				7	virtual_device
*/
update #spdevtab
	set statusdesc = N'special'
		from master.dbo.sysdevices d, #spdevtab
			where d.cntrltype = 0
				and #spdevtab.name = d.name
update #spdevtab
	set statusdesc = N'disk'
		from master.dbo.sysdevices d, #spdevtab
			where d.cntrltype = 2
				and #spdevtab.name = d.name

update #spdevtab
	set statusdesc = N'tape'
		from master.dbo.sysdevices d, #spdevtab
			where d.cntrltype = 5
				and #spdevtab.name = d.name

update #spdevtab
	set statusdesc = N'pipe'
		from master.dbo.sysdevices d, #spdevtab
			where d.cntrltype = 6
				and #spdevtab.name = d.name
update #spdevtab
	set statusdesc = N'virtual_device'
		from master.dbo.sysdevices d, #spdevtab
			where d.cntrltype = 7
				and #spdevtab.name = d.name

update #spdevtab
	set statusdesc = N'UNKNOWN DEVICE'
		from master.dbo.sysdevices d, #spdevtab
			where d.cntrltype >= 8
				and #spdevtab.name = d.name


/*
**  Now check out the status bits and turn them into english.
**  Status of 16 is a dump device.
*/
update #spdevtab set statusdesc = statusdesc + N', ' + rtrim(v.name)
	from master.dbo.sysdevices d, master.dbo.spt_values v, #spdevtab
	where v.type = 'V' and v.number > -1
		and d.status & v.number = 16
		and #spdevtab.name = d.name

/*
**  Status of 1 is a default disk.
*/
update #spdevtab set statusdesc = statusdesc + N', ' + rtrim(v.name)
	from master.dbo.sysdevices d, master.dbo.spt_values v, #spdevtab
	where v.type = 'V' and v.number > -1
		and d.status & v.number = 1
		and #spdevtab.name = d.name

/*
**  Status of 2 is a physical disk.
*/
update #spdevtab
	set statusdesc = substring(statusdesc, 1, 225) + N', ' + rtrim(v.name)
	from master.dbo.sysdevices d, master.dbo.spt_values v, #spdevtab
	where v.type = 'V' and v.number > -1
		and d.status & v.number = 2
		and #spdevtab.name = d.name

/*
**  Add in its size in MB.
*/
update #spdevtab
	set statusdesc = statusdesc + N', ' + convert(varchar(10),
		round((convert(float, d.size) * (select low from master.dbo.spt_values
			where type = 'E' and number = 1)
			 / 1048576), 1)) + ' MB'
	from master.dbo.sysdevices d, #spdevtab, master.dbo.spt_values v
	where d.status & 2 = 2
		and #spdevtab.name = d.name
		and v.number = 1
		and v.type = 'E'

/*
**  Status of 4 is a logical disk.
*/
update #spdevtab
	set statusdesc = substring(statusdesc, 1, 225) + N', ' + rtrim(v.name)
	from master.dbo.sysdevices d, master.dbo.spt_values v, #spdevtab
	where v.type = 'V' and v.number > -1
		and d.status & v.number = 4
		and #spdevtab.name = d.name

/*
**  Status of 8 is a skip tape header.
*/
update #spdevtab
	set statusdesc = substring(statusdesc, 1, 225) + N', ' + rtrim(v.name)
	from master.dbo.sysdevices d, master.dbo.spt_values v, #spdevtab
	where v.type = 'V' and v.number > -1
		and d.status & v.number = 8
		and #spdevtab.name = d.name
/*
**  Status of 4096 is read only.
*/
update #spdevtab
	set statusdesc = substring(statusdesc, 1, 225) + N', ' + rtrim(v.name)
	from master.dbo.sysdevices d, master.dbo.spt_values v, #spdevtab
	where v.type = 'V' and v.number > -1
		and d.status & v.number = 4096
		and #spdevtab.name = d.name
/*
**  Status of 8192 is deferred.
*/
update #spdevtab
	set statusdesc = substring(statusdesc, 1, 225) + N', ' + (v.name)
	from master.dbo.sysdevices d, master.dbo.spt_values v, #spdevtab
	where v.type = 'V' and v.number > -1
		and d.status & v.number = 8192
		and #spdevtab.name = d.name

set nocount off

/*
**  The device number is in the high byte of sysdevices.low so
**  spt_values tells us which byte to pick out.
*/
select device_name = d.name, physical_name = d.phyname,
	description = #spdevtab.statusdesc,
	status = d.status&12319, d.cntrltype,
	size
	from master.dbo.sysdevices d, #spdevtab, master.dbo.spt_values v
	where d.name = #spdevtab.name
		and v.type = 'E'
		and v.number = 3

return(0) -- sp_helpdevice
go

raiserror(15339,-1,-1,'sp_helpfile')
go
create procedure sp_helpfile
@filename sysname = NULL			/* file name or all files */
as

set nocount on

if @filename IS NULL
begin
select 	name,  fileid, filename,
	filegroup = filegroup_name(groupid),
	'size' = convert(nvarchar(15), size * 8) + N' KB',
	'maxsize' = (case maxsize when -1 then N'Unlimited'
			else
			convert(nvarchar(15), maxsize * 8) + N' KB' end),
	'growth' = (case status & 0x100000 when 0x100000 then
		convert(nvarchar(3), growth) + N'%'
		else
		convert(nvarchar(15), growth * 8) + N' KB' end),
	'usage' = (case status & 0x40 when 0x40 then 'log only' else 'data only' end)
	from sysfiles
	order by fileid

end
else
begin
	if file_id(@filename) IS NULL
	begin -- no such file
		raiserror (15325, -1, -1, 'file', @filename)
		return (1)
	end
	select 	name,  filename,
	filegroup = filegroup_name(groupid),
	'size' = convert(nvarchar(15), size * 8) + N' KB',
	'maxsize' = (case maxsize when -1 then N'Unlimited'
			else
			convert(nvarchar(15), maxsize * 8) + N' KB' end),
	'growth' = (case status & 0x100000 when 0x100000 then
		convert(nvarchar(3), growth) + N'%'
		else
		convert(nvarchar(15), growth * 8) + N' KB' end),
	'usage' = (case status & 0x40 when 0x40 then 'log only' else 'data only' end)
	from sysfiles
	where fileid = file_id(@filename)
	order by fileid
end

return (0) -- sp_helpfile
go

raiserror(15339,-1,-1,'sp_helpfilegroup')
go
create procedure sp_helpfilegroup
@filegroupname sysname = NULL		/* filegroup name or all filegroups */
as

set nocount on
-- status & 0x40 is a log file and thus not in any filegroup
if @filegroupname IS NULL
begin
	select 	g.groupname,  g.groupid, 'filecount' =
		(select count(*) from sysfiles f
			where f.groupid = g.groupid
				and (f.status & 0x40 <> 0x40))
	from sysfilegroups g
end
else
begin
	if (filegroup_id(@filegroupname) IS NULL)
	begin
		raiserror (15325, -1, -1, 'filegroup', @filegroupname)
		return (1)
	end
	select 	g.groupname,  g.groupid, 'filecount' =
		(select count(*) from sysfiles f
			where f.groupid = g.groupid
				and (f.status & 0x40 <> 0x40))
	from sysfilegroups g
	where g.groupid = filegroup_id(@filegroupname)

	select 	'file_in_group' = name,  fileid, filename,
	'size' = convert(nvarchar(15), size * 8) + N' KB',
	'maxsize' = (case maxsize when -1 then N'Unlimited'
			else
			convert(nvarchar(15), maxsize * 8) + N' KB' end),
	'growth' = (case status & 0x100000 when 0x100000 then
		convert(nvarchar(3), growth) + N'%'
		else
		convert(nvarchar(15), growth * 8) + N' KB' end)
	from sysfiles
	where groupid = filegroup_id(@filegroupname)
	and (status & 0x40 <> 0x40)
	order by fileid
end

return (0) -- sp_helpfilegroup
go


raiserror(15339,-1,-1,'sp_helpgroup')
go
create procedure sp_helpgroup --- 1996/04/08 00:00
@grpname sysname = NULL		/* group name of interest */
as

/*
**  If no group name given, list all the groups.
*/
if @grpname is null
begin
	select Group_name = name, Group_id = uid
		from sysusers
			where (issqlrole = 1)
		order by name

	return (0)
end

/*
**  Check to see if group exists.
*/
if not exists (select * from sysusers where name = @grpname
		and (issqlrole = 1))
	begin
		raiserror(15014,-1,-1,@grpname)
		return (1)
	end

/*
**  List the particulars for the group.
*/
select Group_name = substring(g.name, 1, 25), Group_id = g.uid,
	   Users_in_group = substring(u.name, 1, 25),
	   Userid = u.uid
	from sysusers u, sysusers g, sysmembers m
	where g.name = @grpname
		and g.uid = m.groupuid
		and (g.issqlrole = 1)
		and u.uid = m.memberuid
	order by 1, 2

return (0) -- sp_helpgroup
go





raiserror(15339,-1,-1,'sp_helplog')
go
create procedure sp_helplog --- 1996/04/08 00:00
as
declare @firstpage int,
	@devname nvarchar(257),
	@msg nvarchar(255)

raiserror('sp_helplog is no longer supported.',1,1)

return (0) -- sp_helplog
go



raiserror(15339,-1,-1,'sp_helplogins')
go
CREATE PROCEDURE sp_helplogins  --- 1996/08/12 14:34

    @LoginNamePattern     sysname    = NULL
AS

Set nocount on

Declare
		@exec_stmt nvarchar(3550)

Declare
       @RetCode                        int
      ,@CountSkipPossUsers             int
      ,@Int1                           int

Declare
       @c10DBName                      sysname
      ,@c10DBStatus                    int
      ,@c10DBSID                       varbinary(85)

Declare
       @charMaxLenLoginName            varchar(11)
      ,@charMaxLenDBName               varchar(11)
      ,@charMaxLenUserName             varchar(11)
      ,@charMaxLenLangName             varchar(11)

Declare
       @DBOptLoading                   int   --0x0020      32  "DoNotRecover"
      ,@DBOptPreRecovery               int   --0x0040      64
      ,@DBOptRecovering                int   --0x0080     128

      ,@DBOptSuspect                   int   --0x0100     256  ("not recovered")
      ,@DBOptOffline                   int   --0x0200     512
      ,@DBOptDBOUseOnly                int   --0x0800    2048

      ,@DBOptSingleUser                int   --0x1000    4096


-------------  create work holding tables  ----------------
/*Create temp tables before any DML to ensure dynamic*/

CREATE Table #tb2_PlainLogins
   (
    LoginName                       sysname        collate database_default NOT Null
   ,SID                             varchar(85)    collate database_default NOT Null
   ,DefDBName                       sysname	       collate database_default Null
   ,DefLangName                     sysname        collate database_default Null
   ,AUser                           char(5)        collate database_default Null
   ,ARemote                         char(7)        collate database_default Null
   )

CREATE Table #tb1_UA
   (
    LoginName                       sysname		collate database_default NOT Null
   ,DBName                          sysname		collate database_default NOT Null
   ,UserName                        sysname		collate database_default NOT Null
   ,UserOrAlias                     char(8)		collate database_default NOT Null
   )

----------------  Initial data values  -------------------

Select
       @RetCode                        = 0  -- 0=good ,1=bad
      ,@CountSkipPossUsers             = 0


----------------  Only SA can run this  -------------------


IF (not (is_srvrolemember('securityadmin') = 1))
   begin
   raiserror(15247,-1,-1)
   Select @RetCode = 1
   goto label_86return
   end

----------------------  spt_values  ----------------
-------- 'D'

SELECT       @DBOptLoading       = number
      from   master.dbo.spt_values
      where  type                = 'D'
      and    name                = 'loading'

SELECT       @DBOptPreRecovery   = number
      from   master.dbo.spt_values
      where  type                = 'D'
      and    name                = 'pre recovery'

SELECT       @DBOptRecovering    = number
      from   master.dbo.spt_values
      where  type                = 'D'
      and    name                = 'recovering'

SELECT       @DBOptSuspect       = number
      from   master.dbo.spt_values
      where  type                = 'D'
      and    name                = 'not recovered'

SELECT       @DBOptOffline       = number
      from   master.dbo.spt_values
      where  type                = 'D'
      and    name                = 'offline'

SELECT       @DBOptDBOUseOnly    = number
      from   master.dbo.spt_values
      where  type                = 'D'
      and    name                = 'dbo use only'

SELECT       @DBOptSingleUser    = number
      from   master.dbo.spt_values
      where  type                = 'D'
      and    name                = 'single user'



---------------  Cursor, for DBNames  -------------------


DECLARE ms_crs_10_DB
   Cursor local static For
SELECT
             name ,status ,sid
      from
             master.dbo.sysdatabases



OPEN ms_crs_10_DB


-----------------  LOOP 10:  thru Databases  ------------------


--------------
WHILE (10 = 10)
   begin    --LOOP 10: thru Databases


   FETCH
             Next
      from
             ms_crs_10_DB
      into
             @c10DBName
            ,@c10DBStatus
            ,@c10DBSID


   IF (@@fetch_status <> 0)
      begin
      Deallocate ms_crs_10_DB
      BREAK
      end


--------------------  Okay if we peek inside this DB now?


   IF (     @c10DBStatus & @DBOptDBOUseOnly  > 0
       AND  @c10DBSID                       <> suser_sid()
      )
      begin
      Select @CountSkipPossUsers = @CountSkipPossUsers + 1
      CONTINUE
      end


   IF (@c10DBStatus & @DBOptSingleUser  > 0)
      begin

      SELECT    @Int1 = count(*)
         from   master.dbo.sysprocesses
         where  spid <> @@spid
         and    dbid  = db_id(@c10DBName)

      IF (@Int1 > 0)
         begin
         Select @CountSkipPossUsers = @CountSkipPossUsers + 1
         CONTINUE
         end
      end


   IF (@c10DBStatus &
         (
           @DBOptLoading
         | @DBOptRecovering
         | @DBOptSuspect
         | @DBOptPreRecovery
         )
               > 0
      )
      begin
      Select @CountSkipPossUsers = @CountSkipPossUsers + 1
      CONTINUE
      end


   IF (@c10DBStatus &
         (
           @DBOptOffline
         )
               > 0
      )
      begin
      --Select @CountSkipPossUsers = @CountSkipPossUsers + 1
      CONTINUE
      end

	IF (has_dbaccess(@c10DBName) <> 1)
      begin
	  raiserror(15622,-1,-1, @c10DBName)
      CONTINUE
      end



---------------------  Add the User info to holding table.
	select @exec_stmt = '
   INSERT    #tb1_UA
            (
             DBName
            ,LoginName
            ,UserName
            ,UserOrAlias
            )
      Select
             N' + quotename(@c10DBName, '''') + '
            ,l.loginname
            ,u.name
            ,''User''
         from
             ' + quotename(@c10DBName, '[') + '.dbo.sysusers       u
            ,master.dbo.syslogins                  l
         where
             u.sid  = l.sid AND isaliased=0' +
			case @LoginNamePattern
			when null then ''
			else ' and ( l.name = N' + quotename(@LoginNamePattern , '''') + '
				or l.loginname = N' + quotename(@LoginNamePattern , '''') + ')'
			end
			+
'     UNION
      Select

             N' + quotename(@c10DBName, '''') + '
            ,l.loginname
            ,u2.name
            ,''MemberOf''
         from
             ' + quotename(@c10DBName, '[')+ '.dbo.sysmembers	   m
            ,' + quotename(@c10DBName, '[')+ '.dbo.sysusers       u1
            ,' + quotename(@c10DBName, '[')+ '.dbo.sysusers       u2
            ,master.dbo.syslogins                  l
         where
             u1.sid     = l.sid
         and m.memberuid = u1.uid
		 and m.groupuid  = u2.uid' +
			case @LoginNamePattern
			when null then ''
			else ' and ( l.name = N' + quotename(@LoginNamePattern , '''') + '
				or l.loginname = N' + quotename(@LoginNamePattern , '''') + ')'
			end

   EXECUTE(@exec_stmt)

   end --loop 10



---------------  Populate plain logins work table  ---------------


INSERT       #tb2_PlainLogins
            (
             LoginName
            ,SID
            ,DefDBName
            ,DefLangName
            ,AUser
            ,ARemote
            )
   SELECT
             loginname
            ,convert(varchar(85), sid)
            ,dbname
            ,language
            ,Null
            ,Null
      from
             master.dbo.syslogins
      where
             @LoginNamePattern is null
			 or name = @LoginNamePattern
             or loginname = @LoginNamePattern


-- AUser

UPDATE       #tb2_PlainLogins --(1996/08/12)
      set
             AUser  = 'yes'
      from
             #tb2_PlainLogins
            ,#tb1_UA             tb1
      where
             #tb2_PlainLogins.LoginName     = tb1.LoginName
      and    #tb2_PlainLogins.AUser        IS Null



UPDATE       #tb2_PlainLogins
      set
             AUser    =
                  CASE @CountSkipPossUsers
                     When  0  Then  'NO'
                     Else           '?'
                  END
      where
             AUser   IS Null


-- ARemote

UPDATE       #tb2_PlainLogins
      set
             ARemote   = 'YES'
      from
             #tb2_PlainLogins
            ,master.dbo.sysremotelogins   rl
      where
             #tb2_PlainLogins.SID = rl.sid
      and    #tb2_PlainLogins.ARemote                 IS Null



UPDATE       #tb2_PlainLogins
      set
             ARemote  = 'no'
      where
             ARemote IS Null



------------  Optimize widths for plain Logins report  ----------


SELECT
             @charMaxLenLoginName      =
                  convert ( varchar
                           ,isnull ( max(datalength(LoginName)) ,9)
                          )
            ,@charMaxLenDBName         =
                  convert ( varchar
                           , isnull (max(isnull (datalength(DefDBName) ,9)) ,9)
                          )
            ,@charMaxLenLangName   =
                  convert ( varchar
                           , isnull (max(isnull (datalength(DefLangName) ,11)) ,11)
                          )
      from
             #tb2_PlainLogins



----------------  Print out plain Logins report  -------------

/*** Message Handlers get confused.
Raiserror('...Logins...' ,0,1)
***/

EXECUTE(
'
Set nocount off


SELECT
          ''LoginName''       = substring (LoginName     ,1 ,'
                                       + @charMaxLenLoginName   + ')

         ,''SID''             = convert(varbinary(85), SID)

         ,''DefDBName''       = substring (DefDBName     ,1 ,'
                                       + @charMaxLenDBName      + ')

         ,''DefLangName''     = substring (DefLangName   ,1 ,'
                                       + @charMaxLenLangName    + ')

         ,AUser
         ,ARemote
   from
          #tb2_PlainLogins
   order by
          LoginName


Set nocount on
'
)



------------  Optimize UA report column display widths  -----------


SELECT
             @charMaxLenLoginName   =
                  convert ( varchar
                           ,isnull ( max(datalength(LoginName)) ,9)
                          )
            ,@charMaxLenDBName      =
                  convert ( varchar
                           ,isnull ( max(datalength(DBName)) ,6)
                          )
            ,@charMaxLenUserName    =
                  convert ( varchar
                           ,isnull ( max(datalength(UserName)) ,8)
                          )
      from
             #tb1_UA



------------  Print out the UserOrAlias report  ------------

/***
Raiserror('...Logins-to-Users...' ,0,1)
***/

EXECUTE(
'
Set nocount off


SELECT
          ''LoginName''    = substring (LoginName  ,1 ,'
                                       + @charMaxLenLoginName  + ')

         ,''DBName''       = substring (DBName     ,1 ,'
                                       + @charMaxLenDBName     + ')

         ,''UserName''     = substring (UserName   ,1 ,'
                                       + @charMaxLenUserName   + ')

         ,UserOrAlias
   from
          #tb1_UA
   order by
          1 ,2 ,3


Set nocount on
'
)


-----------------------  Finalization  --------------------
label_86return:

IF (object_id('#tb2_PlainLogins') IS NOT Null)
            DROP Table #tb2_PlainLogins

IF (object_id('#tb1_UA') IS NOT Null)
            DROP Table #tb1_UA

Return @RetCode -- sp_helplogins
go


raiserror(15339,-1,-1,'sp_helpindex')
go
create proc sp_helpindex
	@objname nvarchar(776)		-- the table to check for indexes
as
	-- PRELIM
	set nocount on

	declare @objid int,			-- the object id of the table
			@indid smallint,	-- the index id of an index
			@groupid smallint,  -- the filegroup id of an index
			@indname sysname,
			@groupname sysname,
			@status int,
			@keys nvarchar(2126),	--Length (16*max_identifierLength)+(15*2)+(16*3)
			@dbname	sysname

	-- Check to see that the object names are local to the current database.
	select @dbname = parsename(@objname,3)

	if @dbname is not null and @dbname <> db_name()
	begin
			raiserror(15250,-1,-1)
			return (1)
	end

	-- Check to see the the table exists and initialize @objid.
	select @objid = object_id(@objname)
	if @objid is NULL
	begin
		select @dbname=db_name()
		raiserror(15009,-1,-1,@objname,@dbname)
		return (1)
	end

	-- OPEN CURSOR OVER INDEXES (skip stats: bug shiloh_51196)
	declare ms_crs_ind cursor local static for
		select indid, groupid, name, status from sysindexes
			where id = @objid and indid > 0 and indid < 255 and (status & 64)=0 order by indid
	open ms_crs_ind
	fetch ms_crs_ind into @indid, @groupid, @indname, @status

	-- IF NO INDEX, QUIT
	if @@fetch_status < 0
	begin
		deallocate ms_crs_ind
		raiserror(15472,-1,-1) --'Object does not have any indexes.'
		return (0)
	end

	-- create temp table
	create table #spindtab
	(
		index_name			sysname	collate database_default NOT NULL,
		stats				int,
		groupname			sysname collate database_default NULL,
		index_keys			nvarchar(2126)	collate database_default NOT NULL -- see @keys above for length descr
	)

	-- Now check out each index, figure out its type and keys and
	--	save the info in a temporary table that we'll print out at the end.
	while @@fetch_status >= 0
	begin
		-- First we'll figure out what the keys are.
		declare @i int, @thiskey nvarchar(131) -- 128+3

		select @keys = index_col(@objname, @indid, 1), @i = 2
		if (indexkey_property(@objid, @indid, 1, 'isdescending') = 1)
			select @keys = @keys  + '(-)'

		select @thiskey = index_col(@objname, @indid, @i)
		if ((@thiskey is not null) and (indexkey_property(@objid, @indid, @i, 'isdescending') = 1))
			select @thiskey = @thiskey + '(-)'

		while (@thiskey is not null )
		begin
			select @keys = @keys + ', ' + @thiskey, @i = @i + 1
			select @thiskey = index_col(@objname, @indid, @i)
			if ((@thiskey is not null) and (indexkey_property(@objid, @indid, @i, 'isdescending') = 1))
				select @thiskey = @thiskey + '(-)'
		end

		select @groupname = null
		select @groupname = groupname from sysfilegroups where groupid = @groupid

		-- INSERT ROW FOR INDEX
		insert into #spindtab values (@indname, @status, @groupname, @keys)

		-- Next index
		fetch ms_crs_ind into @indid, @groupid, @indname, @status
	end
	deallocate ms_crs_ind

	-- SET UP SOME CONSTANT VALUES FOR OUTPUT QUERY
	declare @empty varchar(1) select @empty = ''
	declare @des1			varchar(35),	-- 35 matches spt_values
			@des2			varchar(35),
			@des4			varchar(35),
			@des32			varchar(35),
			@des64			varchar(35),
			@des2048		varchar(35),
			@des4096		varchar(35),
			@des8388608		varchar(35),
			@des16777216	varchar(35)
	select @des1 = name from master.dbo.spt_values where type = 'I' and number = 1
	select @des2 = name from master.dbo.spt_values where type = 'I' and number = 2
	select @des4 = name from master.dbo.spt_values where type = 'I' and number = 4
	select @des32 = name from master.dbo.spt_values where type = 'I' and number = 32
	select @des64 = name from master.dbo.spt_values where type = 'I' and number = 64
	select @des2048 = name from master.dbo.spt_values where type = 'I' and number = 2048
	select @des4096 = name from master.dbo.spt_values where type = 'I' and number = 4096
	select @des8388608 = name from master.dbo.spt_values where type = 'I' and number = 8388608
	select @des16777216 = name from master.dbo.spt_values where type = 'I' and number = 16777216

	-- DISPLAY THE RESULTS
	select
		'index_name' = index_name,
		'index_description' = convert(varchar(210), --bits 16 off, 1, 2, 16777216 on, located on group
				case when (stats & 16)<>0 then 'clustered' else 'nonclustered' end
				+ case when (stats & 1)<>0 then ', '+@des1 else @empty end
				+ case when (stats & 2)<>0 then ', '+@des2 else @empty end
				+ case when (stats & 4)<>0 then ', '+@des4 else @empty end
				+ case when (stats & 64)<>0 then ', '+@des64 else case when (stats & 32)<>0 then ', '+@des32 else @empty end end
				+ case when (stats & 2048)<>0 then ', '+@des2048 else @empty end
				+ case when (stats & 4096)<>0 then ', '+@des4096 else @empty end
				+ case when (stats & 8388608)<>0 then ', '+@des8388608 else @empty end
				+ case when (stats & 16777216)<>0 then ', '+@des16777216 else @empty end
				+ ' located on ' + groupname),
		'index_keys' = index_keys
	from #spindtab
	order by index_name


	return (0) -- sp_helpindex
go

raiserror(15339,-1,-1,'sp_helpstats')
go

create proc sp_helpstats
	@objname nvarchar(520),		-- the table to check for statistics (to accomodate for 2 part names)
	@results nvarchar(5) = 'STATS'	-- 'ALL' returns indexes & stats, 'STATS' returns just stats
as
	-- PRELIM
	set nocount on
	declare 	@objid int,			-- the object id of the table
			@indid smallint,	-- the index id of an index
			@indname sysname,
			@keys nvarchar(2078),-- string build index key list, length = (16*max_id_length)+(15*2)
			@dbname	sysname,
			@i int,
			@thiskey sysname,
			@curs	cursor
	-- Check to see the the table exists and initialize @objid.
	select @objid = object_id(@objname, 'local')
	if @objid is NULL
		begin
		select @dbname=db_name()
		raiserror(15009,-1,-1,@objname,@dbname)
		return (1)
		end
	If UPPER(@results) <> 'STATS' and UPPER(@results)<> 'ALL'
	BEGIN
    		raiserror(N'Invalid option: %s', 1, 1, @results)
		return (1)
	END

	If UPPER(@results) = 'STATS'
	BEGIN
		set @curs = cursor local fast_forward READ_ONLY for
			select indid, name from sysindexes
			where id = @objid and indid > 0 and indid < 255
			  and (status & (64 | 8388608)) > 0 order by indid -- User created & auto-created stats
	END
	ELSE
	BEGIN
		set @curs = cursor local fast_forward READ_ONLY for
			select indid, name from sysindexes
			where id = @objid and indid > 0 and indid < 255
			  order by indid -- Indexes, User created & auto-created stats
	END

	open @curs
	fetch @curs into @indid, @indname

	-- IF NO STATISTICS, QUIT
	if @@fetch_status < 0
	begin
		deallocate @curs
		If UPPER(@results) = 'STATS'
		BEGIN
			raiserror(15574,-1,-1) --'Object does not have any statistics.'
		END
		ELSE
		BEGIN
			raiserror(15575,-1,-1) --'Object does not have any indexes or statistics.'
		END
	return (0)
	end
	-- create temp table
	create table #spstattab
	(
		stats_name			sysname	collate database_default NOT NULL,
		stats_keys			nvarchar(2078)	collate database_default NOT NULL
	)

	-- Now check out each statistics set, figure out its keys and
	--	save the info in a temporary table that we'll print out at the end.
	while @@fetch_status >= 0
	begin
		-- First we'll figure out what the keys are.

		select @keys = index_col(@objname, @indid, 1),
				@i = 2, @thiskey = index_col(@objname, @indid, 2)
		while (@thiskey is not null )
		begin
			select @keys = @keys + ', ' + @thiskey, @i = @i + 1
			select @thiskey = index_col(@objname, @indid, @i)
		end

		-- INSERT ROW FOR INDEX
		insert into #spstattab values (@indname, @keys)

		-- Next index
		fetch @curs into @indid, @indname
	end
	deallocate @curs

	-- DISPLAY THE RESULTS
	select
		'statistics_name' = stats_name,
		'statistics_keys' = stats_keys
	from #spstattab
	order by stats_name

return (0) -- sp_helpstats

raiserror(15339,-1,-1,'sp_objectfilegroup')
go
create procedure sp_objectfilegroup --- 1996/08/30 17:44
@objid	int
as
	/*
	** Print out the object's data filegroup if applicable.
	*/
	if exists (select * from sysobjects
			where id = @objid
			and type in ('S ','U '))
		begin
			select Data_located_on_filegroup = s.groupname
			from sysfilegroups s, sysindexes i
			where i.id = @objid
				and i.indid < 2
				and i.groupid = s.groupid
		end

	/*
	**  It's not a table so segment is not applicable.
	*/
	else
		select Data_located_on_filegroup = 'not applicable'

return (0) -- sp_objectfilegroup
go

raiserror(15339,-1,-1,'sp_help')
go
create proc sp_help
	@objname nvarchar(776) = NULL		-- object name we're after
as
	-- PRELIMINARY
	set nocount on
	declare	@dbname	sysname

	-- OBTAIN DISPLAY STRINGS FROM spt_values UP FRONT --
	declare @no varchar(35), @yes varchar(35), @none varchar(35)
	select @no = name from master.dbo.spt_values where type = 'B' and number = 0
	select @yes = name from master.dbo.spt_values where type = 'B' and number = 1
	select @none = name from master.dbo.spt_values where type = 'B' and number = 2

	-- If no @objname given, give a little info about all objects.
	if @objname is null
	begin
		-- DISPLAY ALL SYSOBJECTS --
        select
            'Name'          = o.name,
            'Owner'         = user_name(uid),
            'Object_type'   = substring(v.name,5,31)
        from sysobjects o, master.dbo.spt_values v
        where o.xtype = substring(v.name,1,2) collate database_default and v.type = 'O9T'
        order by Object_type desc, Name asc

		print ' '

		-- DISPLAY ALL USER TYPES
		select
			'User_type'		= name,
			'Storage_type'	= type_name(xtype),
			'Length'		= length,
			'Prec'			= TypeProperty(name, 'precision'),
			'Scale'			= TypeProperty(name, 'scale'),
			'Nullable'		= case when TypeProperty(name, 'AllowsNull') = 1
											then @yes else @no end,
			'Default_name'	= isnull(object_name(tdefault), @none),
			'Rule_name'		= isnull(object_name(domain), @none),
			'Collation'		= collation
		from systypes
		where xusertype > 256
		order by name

		return(0)
	end

	-- Make sure the @objname is local to the current database.
	select @dbname = parsename(@objname,3)

	if @dbname is not null and @dbname <> db_name()
		begin
			raiserror(15250,-1,-1)
			return(1)
		end

	-- @objname must be either sysobjects or systypes: first look in sysobjects
	declare @objid int
	declare @sysobj_type char(2)
	select @objid = id, @sysobj_type = xtype from sysobjects where id = object_id(@objname)

	-- IF NOT IN SYSOBJECTS, TRY SYSTYPES --
	if @objid is null
	begin
		-- UNDONE: SHOULD CHECK FOR AND DISALLOW MULTI-PART NAME
		select @objid = xusertype from systypes where name = @objname

		-- IF NOT IN SYSTYPES, GIVE UP
		if @objid is null
		begin
			select @dbname=db_name()
			raiserror(15009,-1,-1,@objname,@dbname)
			return(1)
		end

		-- DATA TYPE HELP (prec/scale only valid for numerics)
		select
			'Type_name'		= name,
			'Storage_type'	= type_name(xtype),
			'Length'		= length,
			'Prec'			= TypeProperty(name, 'precision'),
			'Scale'			= TypeProperty(name, 'scale'),
			'Nullable'		= case when allownulls=1 then @yes else @no end,
			'Default_name'	= isnull(object_name(tdefault), @none),
			'Rule_name'		= isnull(object_name(domain), @none),
			'Collation'		= collation
		from systypes
		where xusertype = @objid

		return(0)
	end

	-- FOUND IT IN SYSOBJECT, SO GIVE OBJECT INFO
	select
		'Name'				= o.name,
		'Owner'				= user_name(uid),
        'Type'              = substring(v.name,5,31),
		'Created_datetime'	= o.crdate
	from sysobjects o, master.dbo.spt_values v
	where o.id = @objid and o.xtype = substring(v.name,1,2) collate database_default and v.type = 'O9T'

	print ' '

	-- DISPLAY COLUMN IF TABLE / VIEW
	if @sysobj_type in ('S ','U ','V ','TF','IF')
	begin

		-- SET UP NUMERIC TYPES: THESE WILL HAVE NON-BLANK PREC/SCALE
		declare @numtypes nvarchar(80)
		select @numtypes = N'tinyint,smallint,decimal,int,real,money,float,numeric,smallmoney'

		-- INFO FOR EACH COLUMN
		print ' '
		select
			'Column_name'			= name,
			'Type'					= type_name(xusertype),
			'Computed'				= case when iscomputed = 0 then @no else @yes end,
			'Length'				= convert(int, length),
			'Prec'					= case when charindex(type_name(xtype), @numtypes) > 0
										then convert(char(5),ColumnProperty(id, name, 'precision'))
										else '     ' end,
			'Scale'					= case when charindex(type_name(xtype), @numtypes) > 0
										then convert(char(5),OdbcScale(xtype,xscale))
										else '     ' end,
			'Nullable'				= case when isnullable = 0 then @no else @yes end,
			'TrimTrailingBlanks'	= case ColumnProperty(@objid, name, 'UsesAnsiTrim')
										when 1 then @no
										when 0 then @yes
										else '(n/a)' end,
			'FixedLenNullInSource'	= case
						when type_name(xtype) not in ('varbinary','varchar','binary','char')
							Then '(n/a)'
						When status & 0x20 = 0 Then @no
						Else @yes END,
			'Collation'		= collation
		from syscolumns where id = @objid and number = 0 order by colid

		-- IDENTITY COLUMN?
		if @sysobj_type in ('S ','U ','V ','TF')
		begin
			print ' '
			declare @colname sysname
			select @colname = name from syscolumns where id = @objid
						and colstat & 1 = 1
			select
				'Identity'				= isnull(@colname,'No identity column defined.'),
				'Seed'					= ident_seed(@objname),
				'Increment'				= ident_incr(@objname),
				'Not For Replication'	= ColumnProperty(@objid, @colname, 'IsIDNotForRepl')
			-- ROWGUIDCOL?
			print ' '
			select @colname = null
			select @colname = name from syscolumns where id = @objid and number = 0
						and ColumnProperty(@objid, name, 'IsRowGuidCol') = 1
			select 'RowGuidCol' = isnull(@colname,'No rowguidcol column defined.')
		end
	end

	-- DISPLAY PROC PARAMS
	if @sysobj_type in ('P ') --RF too?
	begin
		-- ANY PARAMS FOR THIS PROC?
		if exists (select id from syscolumns where id = @objid)
		begin
			-- INFO ON PROC PARAMS
			print ' '
			select
				'Parameter_name'	= name,
				'Type'				= type_name(xusertype),
                'Length'			= length,
                'Prec'				= case when type_name(xtype) = 'uniqueidentifier' then xprec
										else OdbcPrec(xtype, length, xprec) end,
                'Scale'				= OdbcScale(xtype,xscale),
                'Param_order'		= colid,
				'Collation'		= collation

			from syscolumns where id = @objid
		end
	end

	-- DISPLAY TABLE INDEXES & CONSTRAINTS
	if @sysobj_type in ('S ','U ')
	begin
		print ' '
		execute sp_objectfilegroup @objid
		print ' '
		execute sp_helpindex @objname
		print ' '
		execute sp_helpconstraint @objname,'nomsg'
		if (select count(*) from sysdepends where depid = @objid and deptype = 1) = 0
		begin
			raiserror(15647,-1,-1) -- 'No views with schemabinding reference this table.'
		end
		else
		begin
            select distinct 'Table is referenced by views' = obj.name from sysobjects obj, sysdepends deps
				where obj.xtype ='V' and obj.id = deps.id and deps.depid = @objid
					and deps.deptype = 1 group by obj.name

		end
	end
	else if @sysobj_type in ('V ')
	begin
		-- VIEWS DONT HAVE CONSTRAINTS, BUT PRINT THESE MESSAGES BECAUSE 6.5 DID
		print ' '
		raiserror(15469,-1,-1) -- No constraints defined
		print ' '
		raiserror(15470,-1,-1) --'No foreign keys reference this table.'
		execute sp_helpindex @objname
	end

	return (0) -- sp_help
go

checkpoint
go


raiserror(15339,-1,-1,'sp_helprotect')
go
CREATE PROCEDURE sp_helprotect
	@name				ncharacter varying(776)  = NULL
	,@username			sysname  = NULL
	,@grantorname		sysname  = NULL
	,@permissionarea	character varying(10)  = 'o s'
as

/********
Explanation of the parms...
---------------------------
@name:  Name of [Owner.]Object and Statement; meaning
for sysprotects.id and sysprotects.action at the
same time; thus see parm @permissionarea.
   Examples-   'user2.tb'  , 'CREATE TABLE', null

@username:  Name of the grantee (for sysprotects.uid).
   Examples-   'user2', null

@grantorname:  Name of the grantor (for sysprotects.grantor).
   Examples-   'user2' --Would prevent report rows which would
                       --  have 'dbo' as grantor.

@permissionarea:  O=Object, S=Statement; include all which apply.
   Examples-   'o'  , ',s'  , 'os'  , 'so'  , 's o'  , 's,o'
GeneMi
********/

	Set nocount on

	Declare
	@vc1                   sysname
	,@Int1                  integer

	Declare
	@charMaxLenOwner		character varying(11)
	,@charMaxLenObject		character varying(11)
	,@charMaxLenGrantee		character varying(11)
	,@charMaxLenGrantor		character varying(11)
	,@charMaxLenAction		character varying(11)
	,@charMaxLenColumnName	character varying(11)

	Declare
	@OwnerName				sysname
	,@ObjectStatementName	sysname


	/* Perform temp table DDL here to minimize compilation costs*/
CREATE Table #t1_Prots
	(	Id					int				Null
		,Type1Code			char(6)			collate database_default NOT Null
		,ObjType			char(2)			collate database_default Null

		,ActionName		varchar(20)			collate database_default Null
		,ActionCategory	char(2)				collate database_default Null
		,ProtectTypeName	char(10)		collate database_default Null

		,Columns_Orig		varbinary(32)	Null

		,OwnerName			sysname			collate database_default NOT Null
		,ObjectName			sysname			collate database_default NOT Null
		,GranteeName		sysname			collate database_default NOT Null
		,GrantorName		sysname			collate database_default NOT Null

		,ColumnName			sysname			collate database_default Null
		,ColId				smallint		Null

		,Max_ColId			smallint		Null
		,All_Col_Bits_On	tinyint			Null
		,new_Bit_On			tinyint			Null )  -- 1=yes on


	/*	Check for valid @permissionarea */
	Select @permissionarea = upper( isnull(@permissionarea,'?') )

	IF (	charindex('O',@permissionarea) <= 0
		AND  charindex('S',@permissionarea) <= 0)
	begin
		raiserror(15300,-1,-1 ,@permissionarea,'o,s')
		return (1)
	end

	select @vc1 = parsename(@name,3)

	/* Verified db qualifier is current db*/
	IF (@vc1 is not null and @vc1 <> db_name())
	begin
		raiserror(15302,-1,-1)  --Do not qualify with DB name.
		return (1)
	end

	/*  Derive OwnerName and @ObjectStatementName*/
	select	@OwnerName				=	parsename(@name, 2)
			,@ObjectStatementName	=	parsename(@name, 1)

	IF (@ObjectStatementName is NULL and @name is not null)
	begin
		raiserror(15253,-1,-1,@name)
		return (1)
	end

	/*	Copy info from sysprotects for processing	*/
	IF charindex('O',@permissionarea) > 0
	begin
		/*	Copy info for objects	*/
		INSERT	#t1_Prots
        (	Id
			,Type1Code

			,ObjType
			,ActionName
			,ActionCategory
			,ProtectTypeName

			,Columns_Orig
			,OwnerName
			,ObjectName
			,GranteeName

			,GrantorName
			,ColumnName
            ,ColId

			,Max_ColId
			,All_Col_Bits_On
			,new_Bit_On	)

	/*	1Regul indicates action can be at column level,
		2Simpl indicates action is at the object level */
		SELECT	id
				,case
					when columns is null then '2Simpl'
					else '1Regul'
				end

				,Null
				,val1.name
				,'Ob'
				,val2.name

				,columns
				,user_name(objectproperty( id, 'ownerid' ))
				,object_name(id)
				,user_name(uid)

				,user_name(grantor)
				,case
					when columns is null then '.'
					else Null
				end
				,-123

				,Null
				,Null
				,Null
		FROM	sysprotects sysp
				,master.dbo.spt_values  val1
				,master.dbo.spt_values  val2
		where	(@OwnerName is null or user_name(objectproperty( id, 'ownerid' )) = @OwnerName)
		and	(@ObjectStatementName is null or object_name(id) =  @ObjectStatementName)
		and	(@username is null or user_name(uid) =  @username)
		and	(@grantorname is null or user_name(grantor) =  @grantorname)
		and	val1.type     = 'T'
		and	val1.number   = sysp.action
		and	val2.type     = 'T' --T is overloaded.
		and	val2.number   = sysp.protecttype
		and sysp.id != 0


		IF EXISTS (SELECT * From #t1_Prots)
		begin
			UPDATE	#t1_Prots set ObjType = ob.xtype
			FROM	sysobjects    ob
			WHERE	ob.id	=  #t1_Prots.Id


			UPDATE 	#t1_Prots
			set		Max_ColId = (select max(colid) from syscolumns sysc
								where #t1_Prots.Id = sysc.id)	-- colid may not consecutive if column dropped
			where Type1Code = '1Regul'


			/*	First bit set indicates actions pretains to new columns. (i.e. table-level permission)
				Set new_Bit_On accordinglly							*/
			UPDATE	#t1_Prots SET new_Bit_On =
			CASE	convert(int,substring(Columns_Orig,1,1)) & 1
				WHEN	1 then	1
				ELSE	0
			END
			WHERE	ObjType	<> 'V'	and	 Type1Code = '1Regul'


			/* Views don't get new columns	*/
			UPDATE #t1_Prots set new_Bit_On = 0
			WHERE  ObjType = 'V'


			/*	Indicate enties where column level action pretains to all
				columns in table All_Col_Bits_On = 1					*/
			UPDATE	#t1_Prots	set		All_Col_Bits_On = 1
			where	#t1_Prots.Type1Code	 =  '1Regul'
			and	not exists 
				(select *
				from syscolumns sysc, master..spt_values v
				where #t1_Prots.Id = sysc.id and sysc.colid = v.number
				and v.number <= Max_ColId		-- column may be dropped/added after Max_ColId snap-shot 
				and v.type = 'P' and
			/*	Columns_Orig where first byte is 1 means off means on and on mean off
				where first byte is 0 means off means off and on mean on	*/
					case convert(int,substring(#t1_Prots.Columns_Orig, 1, 1)) & 1
						when 0 then convert(tinyint, substring(#t1_Prots.Columns_Orig, v.low, 1))
						else (~convert(tinyint, isnull(substring(#t1_Prots.Columns_Orig, v.low, 1),0)))
					end & v.high = 0)


			/* Indicate entries where column level action pretains to
				only some of columns in table  All_Col_Bits_On  =  0*/
			UPDATE	#t1_Prots	set  All_Col_Bits_On  =  0
			WHERE	#t1_Prots.Type1Code  =  '1Regul'
			and	All_Col_Bits_On  is  null


			Update #t1_Prots
			set ColumnName  =
			case
				when All_Col_Bits_On = 1 and new_Bit_On = 1 then '(All+New)'
				when All_Col_Bits_On = 1 and new_Bit_On = 0 then '(All)'
				when All_Col_Bits_On = 0 and new_Bit_On = 1 then '(New)'
			end
			from	#t1_Prots
			where	ObjType    IN ('S ' ,'U ', 'V ')
			and	Type1Code = '1Regul'
			and   NOT (All_Col_Bits_On = 0 and new_Bit_On = 0)


			/* Expand and Insert individual column permission rows */
			INSERT	into   #t1_Prots
				(Id
				,Type1Code
				,ObjType
				,ActionName

				,ActionCategory
				,ProtectTypeName
				,OwnerName
				,ObjectName

				,GranteeName
				,GrantorName
				,ColumnName
				,ColId	)
		   SELECT	prot1.Id
					,'1Regul'
					,ObjType
					,ActionName

					,ActionCategory
					,ProtectTypeName
					,OwnerName
					,ObjectName

					,GranteeName
					,GrantorName
					,col_name ( prot1.Id ,val1.number )
					,val1.number
			from	#t1_Prots              prot1
					,master.dbo.spt_values  val1
					,syscolumns sysc
			where	prot1.ObjType    IN ('S ' ,'U ' ,'V ')
				and	prot1.All_Col_Bits_On = 0
				and prot1.Id	= sysc.id
				and	val1.type   = 'P'
				and	val1.number = sysc.colid
				and
				case convert(int,substring(prot1.Columns_Orig, 1, 1)) & 1
					when 0 then convert(tinyint, substring(prot1.Columns_Orig, val1.low, 1))
					else (~convert(tinyint, isnull(substring(prot1.Columns_Orig, val1.low, 1),0)))
				end & val1.high <> 0

			delete from #t1_Prots
					where	ObjType    IN ('S ' ,'U ' ,'V ')
							and	All_Col_Bits_On = 0
							and new_Bit_On = 0
		end
	end


	/* Handle statement permissions here*/
	IF (charindex('S',@permissionarea) > 0)
	begin
	   /*	All statement permissions are 2Simpl */
		INSERT	#t1_Prots
			 (	Id
				,Type1Code
				,ObjType
				,ActionName

				,ActionCategory
				,ProtectTypeName
				,Columns_Orig
				,OwnerName

				,ObjectName
				,GranteeName
				,GrantorName
				,ColumnName

				,ColId
				,Max_ColId
				,All_Col_Bits_On
				,new_Bit_On	)
		SELECT	id
				,'2Simpl'
				,Null
				,val1.name

				,'St'
				,val2.name
				,columns
				,'.'

				,'.'
				,user_name(sysp.uid)
				,user_name(sysp.grantor)
				,'.'
				,-123

				,Null
				,Null
				,Null
		FROM	sysprotects				sysp
				,master.dbo.spt_values	val1
				,master.dbo.spt_values  val2
		where	(@username is null or user_name(sysp.uid) = @username)
			and	(@grantorname is null or user_name(sysp.grantor) = @grantorname)
			and	val1.type     = 'T'
			and	val1.number   =  sysp.action
			and	(@ObjectStatementName is null or val1.name = @ObjectStatementName)
			and	val2.number   = sysp.protecttype
			and	val2.type     = 'T'
			and sysp.id = 0
	end


	IF NOT EXISTS (SELECT * From #t1_Prots)
	begin
		raiserror(15330,-1,-1)
		return (1)
	end


	/*	Calculate dynamic display col widths		*/
	SELECT
	@charMaxLenOwner       =
		convert ( varchar, max(datalength(OwnerName)))

	,@charMaxLenObject      =
		convert ( varchar, max(datalength(ObjectName)))

	,@charMaxLenGrantee     =
		convert ( varchar, max(datalength(GranteeName)))

	,@charMaxLenGrantor     =
		convert ( varchar, max(datalength(GrantorName)))

	,@charMaxLenAction      =
		convert ( varchar, max(datalength(ActionName)))

	,@charMaxLenColumnName  =
		convert ( varchar, max(datalength(ColumnName)))
	from	#t1_Prots


/*  Output the report	*/
EXECUTE(
'Set nocount off

SELECT	''Owner''		= substring (OwnerName   ,1 ,' + @charMaxLenOwner   + ')

		,''Object''		= substring (ObjectName  ,1 ,' + @charMaxLenObject  + ')

		,''Grantee''	= substring (GranteeName ,1 ,' + @charMaxLenGrantee + ')

		,''Grantor''	= substring (GrantorName ,1 ,' + @charMaxLenGrantor + ')

		,''ProtectType''= ProtectTypeName

		,''Action''		= substring (ActionName ,1 ,' + @charMaxLenAction + ')

		,''Column''		= substring (ColumnName ,1 ,' + @charMaxLenColumnName + ')
   from	#t1_Prots
   order by
		ActionCategory
		,Owner				,Object
		,Grantee			,Grantor
		,ProtectType		,Action
		,ColId  --Multiple  -123s  ( <0 )  possible

Set nocount on'
)

Return (0) -- sp_helprotect
go

checkpoint
go

raiserror(15339,-1,-1,'sp_helptext')
go
create procedure sp_helptext --- 1996/04/08 00:00
@objname nvarchar(776)
,@columnname sysname = NULL
as

set nocount on

declare @dbname sysname
,@BlankSpaceAdded   int
,@BasePos       int
,@CurrentPos    int
,@TextLength    int
,@LineId        int
,@AddOnLen      int
,@LFCR          int --lengths of line feed carriage return
,@DefinedLength int

/* NOTE: Length of @SyscomText is 4000 to replace the length of
** text column in syscomments.
** lengths on @Line, #CommentText Text column and
** value for @DefinedLength are all 255. These need to all have
** the same values. 255 was selected in order for the max length
** display using down level clients
*/
,@SyscomText	nvarchar(4000)
,@Line          nvarchar(255)

Select @DefinedLength = 255
SELECT @BlankSpaceAdded = 0 /*Keeps track of blank spaces at end of lines. Note Len function ignores
                             trailing blank spaces*/
CREATE TABLE #CommentText
(LineId	int
 ,Text  nvarchar(255) collate database_default)

/*
**  Make sure the @objname is local to the current database.
*/
select @dbname = parsename(@objname,3)

if @dbname is not null and @dbname <> db_name()
        begin
                raiserror(15250,-1,-1)
                return (1)
        end

/*
**  See if @objname exists.
*/
if (object_id(@objname) is null)
        begin
		select @dbname = db_name()
		raiserror(15009,-1,-1,@objname,@dbname)
                return (1)
        end

-- If second parameter was given.
if ( @columnname is not null)
    begin
        -- Check if it is a table
        if (select count(*) from sysobjects where id = object_id(@objname) and xtype in ('S ','U ','TF'))=0
            begin
                raiserror(15218,-1,-1,@objname)
                return(1)
            end
        -- check if it is a correct column name
        if ((select 'count'=count(*) from syscolumns where name = @columnname and id = object_id(@objname) and number = 0) =0)
            begin
                raiserror(15645,-1,-1,@columnname)
                return(1)
            end
    if ((select iscomputed from syscolumns where name = @columnname and id = object_id(@objname) and number = 0) = 0)
		begin
			raiserror(15646,-1,-1,@columnname)
			return(1)
		end

        DECLARE ms_crs_syscom  CURSOR LOCAL
        FOR SELECT text FROM syscomments WHERE id = object_id(@objname) and encrypted = 0 and number =
                        (select colid from syscolumns where name = @columnname and id = object_id(@objname) and number = 0)
                        order by number,colid
        FOR READ ONLY

    end
else
    begin
        /*
        **  Find out how many lines of text are coming back,
        **  and return if there are none.
        */
        if (select count(*) from syscomments c, sysobjects o where o.xtype not in ('S', 'U')
            and o.id = c.id and o.id = object_id(@objname)) = 0
                begin
                        raiserror(15197,-1,-1,@objname)
                        return (1)
                end

        if (select count(*) from syscomments where id = object_id(@objname)
            and encrypted = 0) = 0
                begin
                        raiserror(15471,-1,-1)
                        return (0)
                end

        DECLARE ms_crs_syscom  CURSOR LOCAL
        FOR SELECT text FROM syscomments WHERE id = OBJECT_ID(@objname) and encrypted = 0
                ORDER BY number, colid
        FOR READ ONLY
    end

/*
**  Else get the text.
*/
SELECT @LFCR = 2
SELECT @LineId = 1


OPEN ms_crs_syscom

FETCH NEXT FROM ms_crs_syscom into @SyscomText

WHILE @@fetch_status >= 0
BEGIN

    SELECT  @BasePos    = 1
    SELECT  @CurrentPos = 1
    SELECT  @TextLength = LEN(@SyscomText)

    WHILE @CurrentPos  != 0
    BEGIN
        --Looking for end of line followed by carriage return
        SELECT @CurrentPos =   CHARINDEX(char(13)+char(10), @SyscomText, @BasePos)

        --If carriage return found
        IF @CurrentPos != 0
        BEGIN
            /*If new value for @Lines length will be > then the
            **set length then insert current contents of @line
            **and proceed.
            */
            While (isnull(LEN(@Line),0) + @BlankSpaceAdded + @CurrentPos-@BasePos + @LFCR) > @DefinedLength
            BEGIN
                SELECT @AddOnLen = @DefinedLength-(isnull(LEN(@Line),0) + @BlankSpaceAdded)
                INSERT #CommentText VALUES
                ( @LineId,
                  isnull(@Line, N'') + isnull(SUBSTRING(@SyscomText, @BasePos, @AddOnLen), N''))
                SELECT @Line = NULL, @LineId = @LineId + 1,
                       @BasePos = @BasePos + @AddOnLen, @BlankSpaceAdded = 0
            END
            SELECT @Line    = isnull(@Line, N'') + isnull(SUBSTRING(@SyscomText, @BasePos, @CurrentPos-@BasePos + @LFCR), N'')
            SELECT @BasePos = @CurrentPos+2
            INSERT #CommentText VALUES( @LineId, @Line )
            SELECT @LineId = @LineId + 1
            SELECT @Line = NULL
        END
        ELSE
        --else carriage return not found
        BEGIN
            IF @BasePos <= @TextLength
            BEGIN
                /*If new value for @Lines length will be > then the
                **defined length
                */
                While (isnull(LEN(@Line),0) + @BlankSpaceAdded + @TextLength-@BasePos+1 ) > @DefinedLength
                BEGIN
                    SELECT @AddOnLen = @DefinedLength - (isnull(LEN(@Line),0)  + @BlankSpaceAdded )
                    INSERT #CommentText VALUES
                    ( @LineId,
                      isnull(@Line, N'') + isnull(SUBSTRING(@SyscomText, @BasePos, @AddOnLen), N''))
                    SELECT @Line = NULL, @LineId = @LineId + 1,
                        @BasePos = @BasePos + @AddOnLen, @BlankSpaceAdded = 0
                END
                SELECT @Line = isnull(@Line, N'') + isnull(SUBSTRING(@SyscomText, @BasePos, @TextLength-@BasePos+1 ), N'')
                if LEN(@Line) < @DefinedLength and charindex(' ', @SyscomText, @TextLength+1 ) > 0
                BEGIN
                    SELECT @Line = @Line + ' ', @BlankSpaceAdded = 1
                END
            END
        END
    END

	FETCH NEXT FROM ms_crs_syscom into @SyscomText
END

IF @Line is NOT NULL
    INSERT #CommentText VALUES( @LineId, @Line )

select Text from #CommentText order by LineId

CLOSE  ms_crs_syscom
DEALLOCATE 	ms_crs_syscom

DROP TABLE 	#CommentText

return (0) -- sp_helptext
go


--Running this create AFTER create sp_helpgroup.
raiserror(15339,-1,-1,'sp_helpuser')
go
CREATE PROCEDURE sp_helpuser  --- 1996/08/14 10:33
    @name_in_db       sysname    = NULL --User,Group,Alias
AS

Set nocount on
Set ansi_warnings off

Declare
    @RetCode               int
   ,@_rowcount             int

Declare
    @charMaxLen_UsName     varchar(11)
   ,@charMaxLen_GrName     varchar(11)
   ,@charMaxLen_LoName     varchar(11)
   ,@charMaxLen_DbName     varchar(11)

Declare
    @Name1Type             char(2)
   ,@CMaxUsUID             smallint

-----------------------  create holding table  --------------------
/*Create temp table before any DML to ensure dynamic*/

Create Table #tb1_uga
   (
    zUserName        sysname        collate database_default Null
   ,zGroupName       sysname        collate database_default Null
   ,zLoginName       sysname        collate database_default Null
   ,zDefDBName       sysname        collate database_default Null
   ,zUID             smallint       Null
   ,zSID             varbinary(85)  Null
   )

--------

Select
    @RetCode               = 0
   ,@Name1Type             = Null
   ,@CMaxUsUID			   = 16383


-------------  What type of value (U,G,A) was input?  --------------

-------- NULL

IF (@name_in_db IS Null)
   begin

   Select @Name1Type = '-'


   INSERT into  #tb1_uga
               (
                zUserName
               ,zGroupName
               ,zLoginName
               ,zDefDBName
               ,zUID
               ,zSID
               )
      SELECT
                   usu.name
                  ,case
					when (usg.uid is null) then 'public'
					else usg.name
				   end
                  ,lo.loginname
                  ,lo.dbname
                  ,usu.uid
                  ,usu.sid
         from
				   sysusers	usu left outer join
					(sysmembers mem inner join sysusers usg on mem.groupuid = usg.uid) on usu.uid = mem.memberuid
                   left outer join master.dbo.syslogins  lo on usu.sid = lo.sid
         where
				   (usu.islogin = 1 and usu.isaliased = 0 and usu.hasdbaccess = 1) and
				   (usg.issqlrole = 1 or usg.uid is null)


   GOTO LABEL_25NAME1TYPEKNOWN

   end


-------- USER

INSERT   into   #tb1_uga
               (
                zUserName
               ,zGroupName
               ,zLoginName
               ,zDefDBName
               ,zUID
               ,zSID
               )
      SELECT
                   usu.name
                  ,case
					when (usg.uid is null) then 'public'
					else usg.name
				   end
                  ,lo.loginname
                  ,lo.dbname
                  ,usu.uid
                  ,usu.sid
         from
				   sysusers	usu left outer join
					(sysmembers mem inner join sysusers usg on mem.groupuid = usg.uid) on usu.uid = mem.memberuid
                   left outer join master.dbo.syslogins  lo on usu.sid = lo.sid
         where
				   (usu.islogin = 1 and usu.isaliased = 0 and usu.hasdbaccess = 1) and
				   (usg.issqlrole = 1 or usg.uid is null) and
                   usu.name    = @name_in_db


Select @_rowcount = @@rowcount


IF (@_rowcount > 0)
   begin
   Select @Name1Type = 'US'

   GOTO LABEL_25NAME1TYPEKNOWN

   end


 -------- ALIAS

INSERT   into   #tb1_uga
               (
                zUserName
               ,zGroupName
               ,zLoginName
               ,zDefDBName
               ,zUID
               ,zSID
               )

	SELECT
                   usu.name
                  ,case
					when (usg.uid is null) then 'public'
					else usg.name
				   end
                  ,lo.loginname
                  ,lo.dbname
                  ,usu.uid
                  ,usu.sid
         from	   (SELECT sid, altuid FROM sysusers WHERE isaliased = 1) al inner join
				   (sysusers	usu left outer join
					(sysmembers mem inner join sysusers usg on mem.groupuid = usg.uid) on usu.uid = mem.memberuid
                   left outer join master.dbo.syslogins  lo on usu.sid = lo.sid) on al.altuid  = usu.uid
         where
				   (usu.islogin = 1 and usu.isaliased = 0) and
				   (usg.issqlrole = 1 or usg.uid is null) and
                   al.sid     = suser_sid(@name_in_db)


Select @_rowcount = @@rowcount


IF (@_rowcount > 0)
   begin
   Select @Name1Type = 'AL'

   GOTO LABEL_25NAME1TYPEKNOWN

   end


-------- GROUP
IF EXISTS
      (SELECT * FROM sysusers
         WHERE  name = @name_in_db
         AND (issqlrole = 1)
      )
   begin
   Select @Name1Type = 'GR'

   Execute sp_helpgroup @name_in_db

   GOTO LABEL_75FINAL  --Done

   end

-------- Error
Raiserror(15198,-1,-1 ,@name_in_db)  --Input Name is unfound
Select @RetCode = @RetCode | 1

GOTO LABEL_75FINAL

--------


LABEL_25NAME1TYPEKNOWN:


-----------------------  Printout the report  -------------------------

-------- Preparations for dynamic exec

SELECT
          @charMaxLen_UsName  = convert( varchar,
                  isnull( max( datalength( zUserName)),8))

         ,@charMaxLen_GrName  = convert( varchar,
                  isnull( max( datalength( zGroupName)),9))

         ,@charMaxLen_LoName  = convert( varchar,
                  isnull( max( datalength( zLoginName)),9))

         ,@charMaxLen_DbName  = convert( varchar,
                  isnull( max( datalength( zDefDBName)),9))
   from
          #tb1_uga


-------- Dynamic EXEC() to printout report


EXECUTE(
'
SELECT
             ''UserName''  =
                     substring(zUserName ,1,' + @charMaxLen_UsName + ')

            ,''GroupName'' =
                     substring(zGroupName,1,' + @charMaxLen_GrName + ')

            ,''LoginName'' =
                     substring(zLoginName,1,' + @charMaxLen_LoName + ')

            ,''DefDBName'' =
                     substring(zDefDBName,1,' + @charMaxLen_DbName + ')

            ,''UserID''    = convert(char(6),zUID)

            ,''SID''   = zSID
      from
             #tb1_uga
      order by
             1
'
)

-----------------------  A little extra nice-to-have

IF (@Name1Type IN ('-','US'))
   begin

   IF EXISTS (SELECT * FROM #tb1_uga tb1 ,(SELECT altuid FROM sysusers WHERE isaliased = 1) al, sysusers us
                       WHERE tb1.zUID = us.uid and us.uid = al.altuid
             )
      begin

      SELECT   'LoginName' = suser_sname(al.sid)
              ,'UserNameAliasedTo' = tb1.zUserName
         from  #tb1_uga tb1 ,(SELECT sid, altuid FROM sysusers WHERE isaliased = 1) al, sysusers us
         WHERE tb1.zUID = us.uid and us.uid = al.altuid
         order by 1

      end
   end


-----------------------  Finalization  ----------------------


LABEL_75FINAL:


IF (object_id('tempdb..#tb1_uga') IS not Null)
            Drop Table #tb1_uga

return (0) -- sp_helpuser
go


raiserror(15339,-1,-1,'sp_indexoption')
go
create procedure sp_indexoption
    @IndexNamePattern      nvarchar(776)
   ,@OptionName            varchar(35)
   ,@OptionValue           varchar(12)
as
	-- DECLARE VARIABLES
	DECLARE @tabid  int
			,@indid  int
			,@uid int
			,@intOptionValue  int
			,@flagbit  int
			,@tablename  nvarchar(776)

    -- DISALLOW USER TRANSACTION --
	Set nocount on
	set implicit_transactions off
	IF @@trancount > 0
	begin
		raiserror(15002,-1,-1,'sp_indexoption')
		RETURN @@ERROR
	end

	-- VALIDATE OPTION VALUE
	SELECT @intOptionValue =
		CASE WHEN (lower(@OptionValue) in ('1' ,'on' ,'yes' ,'true')) THEN 1
			WHEN (lower(@OptionValue) in ('0' ,'off' ,'no' ,'false')) THEN 0
		ELSE NULL END

	-- CONVERT ANY OLD-STYLE PARAM TO NEW-STYLE, THEN VALIDATE OPTION NAME
	IF lower(@OptionName) IN ('allowrowlocks','allowpagelocks')
		SELECT @OptionName = 'dis'+@OptionName,
				@intOptionValue = 1-@intOptionValue
	SELECT @flagbit = CASE lower(@OptionName) WHEN 'disallowrowlocks' THEN 1
						WHEN 'disallowpagelocks' THEN 2
						ELSE NULL END

	-- ERROR IF INVALID OPTION NAME OR VALUE
	IF @intOptionValue IS NULL OR @flagbit IS NULL
	begin
		raiserror(15600,-1,-1, 'sp_indexoption')
		RETURN @@ERROR
	end

	-- FIRST CHECK IF GIVEN AN TABLE NAME --
	SELECT @tabid = id, @uid = uid FROM sysobjects
		WHERE id = OBJECT_ID(@IndexNamePattern, 'local') AND xtype = 'U'
	IF @tabid IS NULL
	BEGIN
		-- NOW SEE IF WE HAVE TABLE.INDEX NAME, AND RESOLVE --
		SELECT @tablename =
				IsNull(QuoteName(parsename(@IndexNamePattern, 4),'[')+'.','.') +
				IsNull(QuoteName(parsename(@IndexNamePattern, 3),'[')+'.','.') +
				IsNull(QuoteName(parsename(@IndexNamePattern, 2),'['),'')
		SELECT @tabid = OBJECT_ID(@tablename, 'U')
		SELECT @uid = ObjectProperty(@tabid, 'OwnerId'),
				@indid = IndexProperty(@tabid, parsename(@IndexNamePattern, 1), 'IndexId')
		IF @indid IN (0,255)
			SELECT @indid = NULL
	END
	ELSE
		SELECT @tablename = @IndexNamePattern, @indid = 0	-- indicate all-indexes-for-table

	-- WE KNOW NOW IF WE HAVE A VALID TABLE/INDEX --
	IF @tabid IS NULL OR @uid IS NULL OR @indid IS NULL
	BEGIN
		raiserror(15388,-1,-1,@IndexNamePattern)
		RETURN @@ERROR
	END

	-- DO THE WORK (DBCC LOCKOBJECTSCHEMA will check permissions) --
	BEGIN TRAN
	DBCC LOCKOBJECTSCHEMA (@tablename)
	dbcc invalidate_textptr_objid(@tabid)	-- Invalidate inrow text pointers for table
	UPDATE sysindexes SET lockflags = (lockflags & ~@flagbit) | (@flagbit * @intOptionValue)
				WHERE id = @tabid AND (indid = @indid OR @indid = 0)
	COMMIT TRAN

	-- RETURN SUCCESS
	RETURN 0 -- sp_indexoption
go

-------------------------------------------------------------

raiserror(15339,-1,-1,'sp_lock')
go
create procedure sp_lock --- 1996/04/08 00:00
@spid1 int = NULL,		/* server process id to check for locks */
@spid2 int = NULL		/* other process id to check for locks */
as

set nocount on
/*
**  Show the locks for both parameters.
*/
if @spid1 is not NULL
begin
	select 	convert (smallint, req_spid) As spid,
		rsc_dbid As dbid,
		rsc_objid As ObjId,
		rsc_indid As IndId,
		substring (v.name, 1, 4) As Type,
		substring (rsc_text, 1, 16) as Resource,
		substring (u.name, 1, 8) As Mode,
		substring (x.name, 1, 5) As Status

	from 	master.dbo.syslockinfo,
		master.dbo.spt_values v,
		master.dbo.spt_values x,
		master.dbo.spt_values u

	where   master.dbo.syslockinfo.rsc_type = v.number
			and v.type = 'LR'
			and master.dbo.syslockinfo.req_status = x.number
			and x.type = 'LS'
			and master.dbo.syslockinfo.req_mode + 1 = u.number
			and u.type = 'L'

			and req_spid in (@spid1, @spid2)
end

/*
**  No parameters, so show all the locks.
*/
else
begin
	select 	convert (smallint, req_spid) As spid,
		rsc_dbid As dbid,
		rsc_objid As ObjId,
		rsc_indid As IndId,
		substring (v.name, 1, 4) As Type,
		substring (rsc_text, 1, 16) as Resource,
		substring (u.name, 1, 8) As Mode,
		substring (x.name, 1, 5) As Status

	from 	master.dbo.syslockinfo,
		master.dbo.spt_values v,
		master.dbo.spt_values x,
		master.dbo.spt_values u

	where   master.dbo.syslockinfo.rsc_type = v.number
			and v.type = 'LR'
			and master.dbo.syslockinfo.req_status = x.number
			and x.type = 'LS'
			and master.dbo.syslockinfo.req_mode + 1 = u.number
			and u.type = 'L'
	order by spid
end

return (0) -- sp_lock
go

raiserror(15339,-1,-1,'sp_getapplock')
go
create procedure sp_getapplock --- 1999/04/14 00:00
 @Resource nvarchar (255) = NULL,           -- Resource to lock
 @LockMode varchar (32),                    -- Lock mode
 @LockOwner varchar (32) = 'Transaction',   -- Lock Owner - [D = Transaction]
 @LockTimeout int = NULL                    -- Lock timeout [D = Session setting]
as

  declare @mode integer
  declare @owner integer
  declare @result integer
  declare @dbid integer

  select @mode =
   CASE @LockMode
     When ('Shared')            Then 3
     When ('Update')            Then 4
     When ('Exclusive')         Then 5
     When ('IntentExclusive')   Then 8
     When ('IntentShared')      Then 6
     Else -1
   END

  if @mode = -1
  begin
    raiserror(15625, -1, -1, @LockMode, N'@LockMode')
    return (-999)
  end

  select @owner =
   CASE @LockOwner
    When ('Transaction')    Then 1
    When ('Session')        Then 3
    Else -1
   END

  if @owner = -1
  begin
    raiserror(15625, -1, -1, @LockOwner, N'@LockOwner')
    return (-999)
  end

  if @LockTimeout is null
  begin
    set @LockTimeout = @@LOCK_TIMEOUT
  end

  select @dbid = db_id ()

  if @owner = 1 and @@trancount = 0
  begin
    raiserror(15626, -1, -1)
    return (-999)
  end

  exec @result = master.dbo.xp_userlock 0, @dbid, @Resource, @mode, @owner, @LockTimeout

  return @result
go

checkpoint
go

raiserror(15339,-1,-1,'sp_releaseapplock')
go
create procedure sp_releaseapplock --- 1999/04/14 00:00
 @Resource nvarchar (255) = NULL,	    -- Resource to unlock
 @LockOwner varchar (32) = 'Transaction'    -- Lock Owner - [D = Transaction]
as

  declare @owner integer
  declare @result integer
  declare @dbid integer

  select @owner =
	CASE @LockOwner
	 When ('Transaction')   Then 1
	 When ('Session')       Then 3
	 Else -1
	END

  if @owner = -1
  begin
    raiserror(15625, -1, -1, @LockOwner, N'@LockOwner')
    return (-999)
  end

  select @dbid = db_id ()

  exec @result = master.dbo.xp_userlock 1, @dbid, @Resource, 0, @owner

  return @result
go



raiserror(15339,-1,-1,'sp_logdevice')
go
create procedure sp_logdevice
@dbname sysname,
@devicename sysname
as
declare @stmt nvarchar(1150)
declare @countrows int
declare @size nvarchar (10)
declare @maxsize nvarchar (10)
declare @growth nvarchar (10)
declare @filename sysname
set nocount on

-- Make sure the database exists
--
if not exists (select * from master.dbo.sysdatabases where name = @dbname)
	begin
		raiserror(15010,-1,-1,@dbname)
		return (1)
	end

-- Make sure the file exists and it should be in sysdevices as this is only
-- for older syntax.
--
if not exists (select * from master.dbo.sysdevices where name = @devicename)
	begin
		raiserror(15012,-1,-1,@devicename)
		return (1)
	end

-- Calculate the specs of the current file and save it into a temp table
--
create table #tempsize (size int, growth int, maxsize int, filename sysname collate database_default )
select @stmt = 'INSERT #tempsize SELECT size, growth, maxsize, filename FROM '
				+ @dbname + '.dbo.sysfiles WHERE name = '''
				+ @devicename + ''''
exec (@stmt)
select @countrows = count (*) from #tempsize

-- disconnect with devices and database
--
if @countrows <> 1
	begin
		raiserror(15012,-1,-1,@devicename)
		return (1)
	end

select @stmt = 'ALTER DATABASE ' + @dbname + ' REMOVE FILE ' + @devicename
exec (@stmt)
if @@error <> 0
	begin
		raiserror(15319,-1,-1,@dbname,@devicename)
		return(1)
	end
select @size = convert(nvarchar(10), size/128),
  @maxsize = convert(nvarchar(10), maxsize),
  @growth = convert(nvarchar(10), growth * 8),
  @filename = filename
from #tempsize

if (@maxsize = '-1')
begin
	select @maxsize = 'UNLIMITED'
end
else
begin
	select @maxsize = (convert (int, @maxsize)) / 128
end

select @stmt = 'ALTER DATABASE ' + @dbname
			+ ' ADD LOG FILE (NAME = ['
			+ @devicename + '], FILENAME = ['
			+ @filename + '], SIZE = '
			+ @size + ', MAXSIZE = '
			+ @maxsize + ', FILEGROWTH = '
			+ @growth + 'KB)'
exec (@stmt)
if @@error=0
      begin
      raiserror(15318,-1,-1,@dbname,@devicename)
      end
else
      begin
      raiserror(15319,-1,-1,@dbname,@devicename)
      return (1)
      end

return (0) -- sp_logdevice
GO


raiserror(15339,-1,-1,'sp_helpremotelogin')
go
create procedure sp_helpremotelogin --- 1996/04/08 00:00
@remoteserver sysname = NULL,	/* remote server name */
@remotename sysname = NULL		/* remote login name */
as
set nocount on

/*
**  If no server given, get 'em all.
*/
if not exists (select * from master.dbo.sysservers s, master.dbo.sysremotelogins r
	where s.srvid = r.remoteserverid
		and (@remoteserver is null or s.srvname = @remoteserver ))
	begin
		if @remoteserver is null
			begin
				raiserror(15200,-1,-1)
				return (0)
			end

		raiserror(15201,-1,-1,@remoteserver)
		return (1)
	end

/*
**  If no remotename given, get 'em all.
*/
if not exists (select * from master.dbo.sysremotelogins
	where (@remotename is null or isnull(remoteusername, ' ') = @remotename))
	begin
		if @remotename is null
			begin
				raiserror(15202,-1,-1)
				return (1)
			end

		raiserror(15203,-1,-1,@remotename)
		return (1)

	end

/*
**  Check for empty results.
*/
if not exists (select *
	from master.dbo.sysremotelogins r, master.dbo.sysservers s
	where ( @remotename is null or isnull(r.remoteusername, ' ') = @remotename)
		and s.srvid = r.remoteserverid
		and (@remoteserver is null or s.srvname = @remoteserver))
	begin
		raiserror(15204,-1,-1,@remotename,@remoteserver)
		return (1)
	end

/*
**  Select the information.
*/
select server = substring(s.srvname, 1, 22),
	local_user_name =
		substring(isnull(suser_sname(r.sid), '** use local name **'), 1, 22),
	remote_user_name =
		substring(isnull(r.remoteusername, '** mapped locally **'), 1, 22),
	options = case datalength(v.name)
				when null then ''
				when 0 then ''
				else substring(v.name, 1, 9)
			  end
		from master.dbo.sysservers s, master.dbo.sysremotelogins r,
			master.dbo.spt_values v
	where s.srvid = r.remoteserverid
		and (@remoteserver is null or s.srvname = @remoteserver)
		and (@remotename is null or isnull(r.remoteusername, ' ') = @remotename)
		and v.type = 'F'
		and v.number = r.status
order by server, remote_user_name

return (0) -- sp_helpremotelogin
go



raiserror(15339,-1,-1,'sp_helpsort')
go
create procedure sp_helpsort --- 1996/04/08 00:00
AS
set nocount on

/*
** Now display the server default collation name
*/
declare @servercollation sysname
select @servercollation = convert(sysname, serverproperty('collation'))

if @servercollation is not NULL
	BEGIN
	select 'Server default collation' = description
		from ::fn_helpcollations() C
		where @servercollation = C.name
	END

set nocount off
return(0) -- sp_helpsort
go


checkpoint
go


raiserror(15339,-1,-1,'sp_helpsql')
go

create procedure sp_helpsql
@in_command varchar(30) = NULL
AS
print 'SP_HELPSQL is not supported in this release, please refer to Online Help.'
return(0)
go


raiserror(15339,-1,-1,'sp_monitor')
go
create procedure sp_monitor --- 1996/04/08 00:00
as

/*
**  Declare variables to be used to hold current monitor values.
*/
declare @now 		datetime
declare @cpu_busy 	int
declare @io_busy	int
declare @idle		int
declare @pack_received	int
declare @pack_sent	int
declare @pack_errors	int
declare @connections	int
declare @total_read	int
declare @total_write	int
declare @total_errors	int

declare @oldcpu_busy 	int	/* used to see if DataServer has been rebooted */
declare @interval	int
declare @mspertick	int	/* milliseconds per tick */

/*
**  If we're in a transaction, disallow this since it might make recovery
**  impossible.
*/
set implicit_transactions off
if @@trancount > 0
	begin
		raiserror(15002,-1,-1,'sp_monitor')
		return (1)
	end

/*
**  Set @mspertick.  This is just used to make the numbers easier to handle
**  and avoid overflow.
*/
select @mspertick = convert(int, @@timeticks / 1000.0)

/*
**  Get current monitor values.
*/
select
	@now = getdate(),
	@cpu_busy = @@cpu_busy,
	@io_busy = @@io_busy,
	@idle = @@idle,
	@pack_received = @@pack_received,
	@pack_sent = @@pack_sent,
	@connections = @@connections,
	@pack_errors = @@packet_errors,
	@total_read = @@total_read,
	@total_write = @@total_write,
	@total_errors = @@total_errors

/*
**  Check to see if DataServer has been rebooted.  If it has then the
**  value of @@cpu_busy will be less than the value of spt_monitor.cpu_busy.
**  If it has update spt_monitor.
*/
select @oldcpu_busy = cpu_busy
	from master.dbo.spt_monitor
if @oldcpu_busy > @cpu_busy
begin
	update master.dbo.spt_monitor
		set
			lastrun = @now,
			cpu_busy = @cpu_busy,
			io_busy = @io_busy,
			idle = @idle,
			pack_received = @pack_received,
			pack_sent = @pack_sent,
			connections = @connections,
			pack_errors = @pack_errors,
			total_read = @total_read,
			total_write = @total_write,
			total_errors = @total_errors
end

/*
**  Now print out old and new monitor values.
*/
set nocount on
select @interval = datediff(ss, lastrun, @now)
	from master.dbo.spt_monitor
/* To prevent a divide by zero error when run for the first
** time after boot up
*/
if @interval = 0
	select @interval = 1
select last_run = lastrun, current_run = @now, seconds = @interval
	from master.dbo.spt_monitor

select
	cpu_busy = substring(convert(varchar(11),
		convert(int, ((@cpu_busy * @mspertick) / 1000)))
		+ '('
		+ convert(varchar(11), convert(int, (((@cpu_busy - cpu_busy)
		* @mspertick) / 1000)))
		+ ')'
		+ '-'
		+ convert(varchar(11), convert(int, ((((@cpu_busy - cpu_busy)
		* @mspertick) / 1000) * 100) / @interval))
		+ '%',
		1, 25),
	io_busy = substring(convert(varchar(11),
		convert(int, ((@io_busy * @mspertick) / 1000)))
		+ '('
		+ convert(varchar(11), convert(int, (((@io_busy - io_busy)
		* @mspertick) / 1000)))
		+ ')'
		+ '-'
		+ convert(varchar(11), convert(int, ((((@io_busy - io_busy)
		* @mspertick) / 1000) * 100) / @interval))
		+ '%',
		1, 25),
	idle = substring(convert(varchar(11),
        convert(int, ((convert(bigint,@idle) * @mspertick) / 1000)))
		+ '('
		+ convert(varchar(11), convert(int, (((@idle - idle)
		* @mspertick) / 1000)))
		+ ')'
		+ '-'
		+ convert(varchar(11), convert(int, ((((@idle - idle)
		* @mspertick) / 1000) * 100) / @interval))
		+ '%',
		1, 25)
from master.dbo.spt_monitor

select
	packets_received = substring(convert(varchar(11), @pack_received) + '(' +
		convert(varchar(11), @pack_received - pack_received) + ')', 1, 25),
	packets_sent = substring(convert(varchar(11), @pack_sent) + '(' +
		convert(varchar(11), @pack_sent - pack_sent) + ')', 1, 25),
	packet_errors = substring(convert(varchar(11), @pack_errors) + '(' +
		convert(varchar(11), @pack_errors - pack_errors) + ')', 1, 25)
from master.dbo.spt_monitor

select
	total_read = substring(convert(varchar(11), @total_read) + '(' +
		convert(varchar(11), @total_read - total_read) + ')', 1, 19),
	total_write = substring(convert(varchar(11), @total_write) + '(' +
		convert(varchar(11), @total_write - total_write) + ')', 1, 19),
	total_errors = substring(convert(varchar(11), @total_errors) + '(' +
		convert(varchar(11), @total_errors - total_errors) + ')', 1, 19),
	connections = substring(convert(varchar(11), @connections) + '(' +
		convert(varchar(11), @connections - connections) + ')', 1, 18)
from master.dbo.spt_monitor

/*
**  Now update spt_monitor
*/
update master.dbo.spt_monitor
	set
		lastrun = @now,
		cpu_busy = @cpu_busy,
		io_busy = @io_busy,
		idle = @idle,
		pack_received = @pack_received,
		pack_sent = @pack_sent,
		connections = @connections,
		pack_errors = @pack_errors,
		total_read = @total_read,
		total_write = @total_write,
		total_errors = @total_errors

return (0) -- sp_monitor
go

raiserror(15339,-1,-1,'sp_processmail')
go
create procedure sp_processmail --- 1996/06/19 17:30
	@subject varchar(255)=NULL,
	@filetype varchar(3)='txt',
	@separator varchar(3)='tab',
	@set_user varchar(132)='guest',
	@dbuse varchar(132)='master'
as

declare @status int
declare @msg_id varchar(94)
declare @originator varchar(255)
declare @cc_list varchar(255)
declare @msgsubject varchar(255)
declare @query varchar(8000)
declare @messages int
declare @mapifailure int
declare @resultmsg varchar(80)
declare @filename varchar(12)
declare @current_msg varchar(94)

select @messages=0
select @mapifailure=0

if @separator='tab' select @separator=CHAR(9)

/* get first message id */
exec @status = master.dbo.xp_findnextmsg
		@msg_id=@msg_id output,
		@unread_only='true'

if @status <> 0
	select @mapifailure=1

while (@mapifailure=0)
  begin

    if @msg_id is null break
    if @msg_id = '' break

    exec @status = master.dbo.xp_readmail
		@msg_id=@msg_id,
		@originator=@originator output,
		@cc_list=@cc_list output,
		@subject=@msgsubject output,
		@message=@query output,
		@peek='true',

		@suppress_attach='true'

    if @status <> 0
	begin
		select @mapifailure=1
		break
	end

    /* get new message id before processing & deleting current */
	select @current_msg=@msg_id
	exec @status = master.dbo.xp_findnextmsg
		@msg_id=@msg_id output,
		@unread_only='true'

    	if @status <> 0
	begin
		select @mapifailure=1
	end


    if ((@subject IS NULL) OR (@subject=@msgsubject))
    begin
	/* generate random filename */
	select @filename='SQL' + convert(varchar,ROUND(RAND()*100000,0)) + '.' + @filetype

	exec @status = master.dbo.xp_sendmail
			@recipients=@originator,
			@copy_recipients=@cc_list,
			@message=@query,
			@query=@query,
			@subject='Query Results',
			@separator=@separator,
			@width=256,
			@attachments=@filename,
			@attach_results='true',
			@no_output='false',
			@echo_error='true',
			@set_user=@set_user,
			@dbuse=@dbuse

	if @status <> 0
		begin
			select @mapifailure=1
			break
		end

	select @messages=@messages+1

	exec master.dbo.xp_deletemail @current_msg

    end /* end of xp_sendmail block */
  end  /* end of xp_findnextmsg loop */

  /* finished examining the contents of inbox;  now send results */
  if @mapifailure=1
      	begin
		raiserror(15079,-1,-1,@messages)
		return(1)
	end
  else
	return(0)
-- sp_processmail
go


raiserror(15339,-1,-1,'sp_recompile')
go
create procedure sp_recompile
    @objname	 	nvarchar(776)
as
    -- do sets and declares
    Set nocount on
    declare @objid      int,
            @curdbname  sysname

    -- CHECK VALIDITY OF OBJECT NAME --
    --  (1) Must exist in current database
    --  (2) Must be a table or an executable object
    select @objid = object_id(@objname, 'local')
    if @objid is null OR
        (ObjectProperty(@objid, 'IsTable') = 0 AND
         ObjectProperty(@objid, 'IsExecuted') = 0)
    begin
	    select @curdbname = db_name()
	    raiserror(15009,-1,-1 ,@objname, @curdbname)
	    return @@error
    end

    -- CHECK PERMISSION --
    if (is_member('db_owner') = 0) AND (is_member('db_ddladmin') = 0)
        AND (is_member(user_name(ObjectProperty(@objid, 'ownerid'))) = 0)
    begin
        raiserror(15247,-1,-1)
        return @@error
    end

    -- BUMP SCHEMA FOR RECOMPILE --
	DBCC LockObjectSchema(@objname)
    if @@error <> 0
        return (1)

	-- TH-TH-TH-THAT'S IT!
    raiserror(15070,-1,-1,@objname)
	return (0) -- sp_recompile
go

checkpoint
go

raiserror(15339,-1,-1,'sp_remoteoption')
go
create procedure sp_remoteoption --- 1996/04/08 00:00
	@remoteserver sysname = NULL,	/* server name to change */
	@loginame sysname = NULL,		/* user's remote name */
	@remotename sysname = NULL,		/* user's local user name */
	@optname varchar(35) = NULL,		/* option name to turn on/off */
	@optvalue varchar(10) = NULL		/* true or false */
as
	declare @optcount int			/* number of options like @optname */
	declare @sid	varbinary(85)

	-- NO SERVER NAME? SHOW SETTABLE OPTION ('trusted')
	if @remoteserver is null
	begin
		raiserror(15473,-1,-1)
		select remotelogin_option = name from master.dbo.spt_values
			where type = 'F_U' and number = 16
		return (0)
	end

	-- NO USER XACT --
	set implicit_transactions off
	if @@trancount > 0
	begin
		raiserror(15002,-1,-1,'sp_remoteoption')
		return (1)
	end

	-- PERMISSIONS --
	if not (is_srvrolemember('securityadmin') = 1)
	begin
		raiserror(15247,-1,-1)
		return (1)
	end

	-- VALIDATE SERVER NAME --
	declare @srvid smallint
	select @srvid = srvid from master.dbo.sysservers where srvname = @remoteserver
	if @srvid is null
	begin
		raiserror(15015,-1,-1,@remoteserver)
		return (1)
	end

	-- VALIDATE @loginame --
	if @loginame is not null
	begin
		select @sid = sid from master.dbo.syslogins where loginname = @loginame
					AND isntname = 0        -- cannot remap to NT login
		if @sid is null
		begin
			raiserror(15067,-1,-1,@loginame)
			return (1)
		end
	end

	-- VALIDATE <@sid, @remotename> PAIR FOR @srvid --
	if not exists (select * from master.dbo.sysxlogins where srvid = @srvid
				and ((@remotename is null AND name is null) OR name = @remotename)
				and ((@sid is null AND sid is null) OR sid = @sid))
	begin
		raiserror(15185,-1,-1,@remotename,@loginame,@remoteserver)
		return (1)
	end

	-- Check remaining parameters --
	if @optname is NULL or lower(@optvalue) not in ('true', 'false') or @optvalue is null
	begin
		raiserror(15220,-1,-1)
		return (1)
	end

	-- SEE IF @optname MATCHES THE 'trusted' OPTION --
	if not exists (select * from master.dbo.spt_values where name like '%' + @optname + '%'
			and type = 'F_U' and number = 16)
	begin
		raiserror(15221,-1,-1)
		return (1)
	end

	-- Now update sysremotelogins
	if lower(@optvalue) = 'true'
	begin
		update master.dbo.sysxlogins set xstatus = xstatus | 16, xdate1 = getdate()
			where srvid = @srvid
				and ((@remotename is null AND name is null) OR name = @remotename)
				and ((@sid is null AND sid is null) OR sid = @sid)
	end
	else	-- 'false'
	begin
		update master.dbo.sysxlogins set xstatus = xstatus & ~16, xdate1 = getdate()
			where srvid = @srvid
				and ((@remotename is null AND name is null) OR name = @remotename)
				and ((@sid is null AND sid is null) OR sid = @sid)
	end
	return (0) -- sp_remoteoption
go

checkpoint
go

raiserror(15339,-1,-1,'sp_invalidate_textptr')
go
create procedure sp_invalidate_textptr
	@TextPtrValue      varbinary(16) = 0x00
as
	dbcc invalidate_textptr(@TextPtrValue)
	return (0); -- sp_invalidate_textptr
go

raiserror(15339,-1,-1,'sp_tableoption')
go
create procedure sp_tableoption
    @TableNamePattern      nvarchar(776)
   ,@OptionName            varchar(35)
   ,@OptionValue           varchar(12)
as
	-- DECLARE AND INIT VARIABLES
	DECLARE @OPTpintable varchar(25)
			,@OPTbulklock varchar(25)
			,@OPTtextinrow varchar(25)
			,@CurrentDBId int
			,@TabId int
			,@intOptionValue int
			,@uid int
	SELECT @OPTpintable = 'pintable'
			,@OPTbulklock = 'table lock on bulk load'
			,@OPTtextinrow = 'text in row'
			,@CurrentDBId = db_id()

    -- DISALLOW USER TRANSACTION (except for in 'text in row') --
	Set nocount on
	set implicit_transactions off
	IF (@@trancount > 0 AND lower(@OptionName) <> @OPTtextinrow)
	begin
		raiserror(15002,-1,-1,'sp_tableoption')
		RETURN @@ERROR
	end

	-- VALIDATE OPTION VALUE
	SELECT @intOptionValue =
		CASE WHEN (lower(@OptionValue) in ('1' ,'on' ,'yes' ,'true')) THEN 1
			WHEN (lower(@OptionValue) in ('0' ,'off' ,'no' ,'false')) THEN 0
			WHEN (lower(@OptionName) = @OPTtextinrow AND ISNUMERIC (@OptionValue) <> 0)
			THEN convert (int, @OptionValue)
		ELSE NULL END

	-- ERROR IF INVALID OPTION NAME OR VALUE
	IF @intOptionValue IS NULL OR
		(lower(@OptionName) NOT IN (@OPTpintable, @OPTbulklock, @OPTtextinrow))
	begin
		raiserror(15600,-1,-1, 'sp_tableoption')
		RETURN @@ERROR
	end

	-- VERIFY WE HAVE A USER-TABLE BY THIS NAME IN THE DATABASE
	SELECT @TabId = id, @uid = uid FROM sysobjects
		WHERE id = OBJECT_ID(@TableNamePattern, 'local') AND xtype = 'U'
	IF @TabId IS NULL
	begin
		raiserror(15388,-1,-1,@TableNamePattern)
		RETURN @@ERROR
	end

	-- Check standard Table-DDL permissions
	IF not (is_member('db_owner') = 1) and
		not (is_member('db_ddladmin') = 1) and
		not (is_member(user_name(@uid)) = 1)
	begin
		raiserror(15247,-1,-1)
		RETURN @@ERROR
	end

	-- HANDLE TEXT-IN-ROW option
	IF (lower(@OptionName) = @OPTtextinrow)
	begin
		-- Set according to value given (Note: dbcc no_textptr does proper schema-locking)
		if (@intOptionValue != 0 and @intOptionValue != 1 and
			(@intOptionValue < 24 or @intOptionValue > 7000))
		BEGIN	-- Invalid value
			raiserror (15112,-1,-1)
			RETURN @@ERROR
		END

		-- invalidate inrow text pointer for the table
		--
		dbcc invalidate_textptr_objid(@TabId)

		BEGIN TRAN
		DBCC LOCKOBJECTSCHEMA(@TableNamePattern)
		dbcc no_textptr(@TabId, @intOptionValue)
		COMMIT TRAN
	end

	-- HANDLE TABLOCK-ON-BCP option
	ELSE IF (lower(@OptionName) = @OPTbulklock)
	BEGIN
		-- Make required change
		IF ObjectProperty(@TabId, 'TableIsLockedOnBulkLoad') <> @intOptionValue
		BEGIN
			BEGIN TRAN
			DBCC LOCKOBJECTSCHEMA(@TableNamePattern)
			UPDATE sysobjects SET status = (status & ~134217728) | (134217728 * @intOptionValue)
				WHERE id = @TabId
			COMMIT TRAN
		END
	END

	-- HANDLE PIN-TABLE option
	ELSE IF (lower(@OptionName) = @OPTpintable)
	BEGIN
		-- ADDITIONAL SECURITY: Must be sysadmin to pin pages
		IF (not (is_srvrolemember('sysadmin') = 1))
		begin
			raiserror(15247,-1,-1)
			RETURN @@ERROR
		end

		-- Make change if required
		IF ObjectProperty(@TabId, 'TableIsPinned') <> @intOptionValue
		BEGIN
			IF @intOptionValue = 1
				DBCC pintable(@CurrentDBId, @TabId)
			ELSE
				DBCC unpintable(@CurrentDBId, @TabId)
		END
	END

	-- Return success
	Return 0  --sp_tableoption
go

checkpoint
go

raiserror(15339,-1,-1,'sp_procoption')
go
create procedure sp_procoption
    @ProcName		nvarchar(776)
   ,@OptionName		varchar(35)
   ,@OptionValue	varchar(12)
as
	-- DECLARE VARIABLES
	DECLARE @tabid  int
			,@uid int
			,@intOptionValue  int
			,@dbname sysname

    -- DISALLOW USER TRANSACTION --
	Set nocount on
	set implicit_transactions off
	IF @@trancount > 0
	begin
		raiserror(15002,-1,-1,'sp_procoption')
		RETURN @@ERROR
	end

	-- VALIDATE OPTION NAME AND VALUE
	SELECT @intOptionValue =
		CASE WHEN (lower(@OptionValue) in ('1' ,'on' ,'yes' ,'true')) THEN 1
			WHEN (lower(@OptionValue) in ('0' ,'off' ,'no' ,'false')) THEN 0
		ELSE NULL END
	IF @intOptionValue IS NULL OR @OptionName IS NULL OR lower(@OptionName) <> 'startup'
	BEGIN
		raiserror(15600,-1,-1, 'sp_procoption')
		RETURN @@ERROR
	END

	-- MUST BE sysadmin (Startup-procs run as sysadmin) --
	IF is_srvrolemember('sysadmin') = 0
	BEGIN
		raiserror(15247,-1,-1)
		RETURN @@ERROR
	END

	-- RESOLVE GIVEN OBJECT NAME --
	SELECT @tabid = id, @uid = uid FROM sysobjects
		WHERE id = OBJECT_ID(@ProcName, 'local') AND xtype IN ('X','P')

	-- VALID OBJECT IN DATABASE? --
	IF @tabid IS NULL
	BEGIN
		SELECT @dbname = db_name()
		raiserror(15009,-1,-1 ,@ProcName, @dbname)
		RETURN @@ERROR
	END

	-- STARTUP PROC MUST BE OWNED BY DBO IN MASTER --
	IF (db_id() <> 1 OR @uid <> 1)
	BEGIN
		raiserror(15398,-1,-1)
		RETURN @@ERROR
	END

	-- PROC CANNOT HAVE PARAMETERS --
	IF EXISTS ( SELECT * FROM syscolumns WHERE id = @tabid )
	BEGIN
		raiserror(15399,-1, -1)
		RETURN @@ERROR
	END

	-- Do the work
	BEGIN TRAN
	DBCC LockObjectSchema(@ProcName)
	UPDATE sysobjects SET status = (status & ~2) | (2 * @intOptionValue) WHERE id = @tabid

	-- Set Config option for startup procs
	UPDATE master.dbo.sysconfigures SET value =
			CASE WHEN EXISTS (SELECT * FROM sysobjects WHERE xtype IN ('X','P')
				AND ObjectProperty(id, 'ExecIsStartup') = 1)
			THEN 1 ELSE 0 END
		WHERE config = 1547

	-- If no error, commit and reconfigure
	IF (@@error <> 0)
	BEGIN
		ROLLBACK TRAN
		RETURN 1
	END
	COMMIT TRAN
	RECONFIGURE WITH OVERRIDE

	-- RETURN SUCCESS
	RETURN 0 -- sp_procoption
go

checkpoint
go


raiserror(15339,-1,-1,'sp_renamedb')
go
create procedure sp_renamedb --- 1996/08/20 13:52
@dbname sysname,			/* old (current) db name */
@newname sysname			/* new name we want to call it */
as
-- Use sp_rename instead.
declare @objid int			/* object id of the thing to rename */
declare @bitdesc varchar(30)		/* bit description for the db */
declare @curdbid int			/* id of database to be changed */
declare @execstring nvarchar (4000)

/*
**  If we're in a transaction, disallow this since it might make recovery
**  impossible.
*/
set implicit_transactions off
if @@trancount > 0
	begin
		raiserror(15002,-1,-1,'sp_renamedb')
		return (1)
	end

/*
**  Only the SA can do this.
*/
if not (is_srvrolemember('dbcreator') = 1)
	begin
		raiserror(15247,-1,-1)
		return (1)
	end

/*
**  Make sure the database exists.
*/
if not exists (select * from master.dbo.sysdatabases where name = @dbname)
	begin
		raiserror(15010,-1,-1,@dbname)
		return (1)
	end

/*
**  Make sure that the @newname db doesn't already exist.
*/
if exists (select * from master.dbo.sysdatabases where name = @newname)
	begin
		raiserror(15032,-1,-1,@newname)
		return (1)
	end

/*
**  Check to see that the @newname is valid.
*/
declare @returncode int
exec @returncode = sp_validname @newname
if @returncode <> 0
begin
	raiserror(15224,-1,15,@newname)
	return(1)
end

/*
**  Don't allow the names of master, tempdb, and model to be changed.
*/
if @dbname in ('master', 'model', 'tempdb')
	begin
		raiserror(15227,-1,-1,@dbname)
		return (1)
	end


	select @execstring = 'ALTER DATABASE '
		+ quotename( @dbname , '[')
		+ ' MODIFY NAME = '
		+ quotename( @newname , '[')

	exec (@execstring)

if @@error <>  0
	begin
		-- No need to raiserror as the CREATE DATABASE will do so
		return(1)
	end

return (0) -- sp_renamedb
go

raiserror(15339,-1,-1,'sp_remove_tempdb_file')
go
create procedure sp_remove_tempdb_file @filename sysname
as
declare @fileid smallint
set nocount on

select @fileid = fileid
	from sysaltfiles
	where dbid = 2  -- limit to tempdb files
	and name = @filename
if @fileid is null
begin
	-- file name does not exist
	raiserror(15311,-1,-1,@filename)
	return (1)
end
if @fileid < 3
begin
	-- file is one of the primary files
	raiserror(15312,-1,-1,@filename)
	return (1)
end

delete sysaltfiles where dbid = 2 and fileid = @fileid
if @@error>0
   begin
      raiserror(15321,-1,-1, @filename)
      return (1)
   end
else
   begin
      raiserror(15322,-1,-1, @filename)
      return (0)
   end

go


raiserror(15339,-1,-1,'sp_rename')
go
/*ANSI_NULLS on for  creation of sp_rename*/
Set ansi_nulls on
go
CREATE PROCEDURE sp_rename
	@objname	nvarchar(776),		-- up to 3-part "old" name
	@newname	sysname,			-- one-part new name
	@objtype	varchar(13) = null	-- identifying the name
as
/********1*********2*********3*********4*********5**
DOCUMENTATION:
   [1]  To rename a table, the @objname (meaning OldName) parm can be
passed in totally unqualified or fully qualified.
   [2]  The SA or DBO can rename objects owned by lesser users,
without the need for SetUser.
   [3]  The Owner portion of a qualified name can usually be
passed in in the omitted form (as in MyDb..MyTab or MyTab).  The
typical exception is when the SA/DBO is trying to rename a table
where the @objname is present twice in sysobjects as a table
owned only by two different lesser users; requiring an explicit
owner qualifier in @objname.
   [4]  An unspecified Owner qualifier will default to the
current user if doing so will either resolve what would
otherwise be an ambiguity within @objtype, or will result
in exactly one match.
   [5]  If Database is part of the qualified @objname,
then it must match the current database.  The @newname parm can
never be qualified.
   [6]  Here are the valid @objtype values.  They correspond to
system tables which track each type:
      'column'  'database'  'index'  'object'  'userdatatype'
The @objtype parm is sometimes required.  It is always required
for databases.  It is required whenever ambiguities would
otherwise exist.  Explicit use of @objtype is always encouraged.
   [7]  Parms can use quoted_identifiers.  For example:
   Execute sp_rename 'amy."his table"','"her table"','object'
*********1*********2*********3*********4*********5*/
Set nocount      on
Set ansi_padding on

Declare @objtypeIN		varchar(13),
		@ExecRC			integer,
		@CurrentDb		sysname,
		@CountNumNodes	integer,
		@UnqualOldName	sysname,
		@QualName1		sysname,
		@QualName2		sysname,
		@QualName3		sysname,
		@OwnAndObjName	nvarchar(517),	-- "[owner].[object]"
		@objid			integer,
		@xtype			nchar(2),
		@indid			smallint,
		@colid			smallint,
		@cnstid			integer,
		@parent_obj		integer,
		@xusertype		smallint,
		@ownerid		smallint,
		@objid_tmp		integer,
		@xtype_tmp		nchar(2),
		@retcode		int,
		@replinfo		int,
		@replbits		int
-- initial (non-null) settings
Select	@CurrentDb		= db_name(),
		@objtypeIN		= @objtype,
		@replbits		= 129	--Indicates table is used in replication

-- make type case insensitive
select @objtype = lower(@objtypeIN)

------------------------------------------------------------------------
-------------------  PHASE 10:  Simple parm edits  ---------------------
------------------------------------------------------------------------

-- Valid rename-type param?
IF (@objtype is not null AND
	@objtype not in ('column', 'database', 'index', 'object', 'userdatatype'))
begin
	raiserror(15249,-1,-1,@objtypeIN,0)
	return 1
end
-- null names?
IF (@newname IS null)
begin
	raiserror(15223,-1,11,'NewName')
	return 1
end
if (@objname IS null)
begin
	raiserror(15223,-1,-1,'OldName')
	return 1
end

---------------  Is NewName minimally valid?

--Check for valid rename name
exec @retcode = sp_validname @newname
if @retcode <> 0
begin
	raiserror(15224,-1,15,@newname)
	return 1
end

-------- Parse apart the perhaps dots-qualified old name.

select @UnqualOldName = parsename(@objname, 1),
        @QualName1 = parsename(@objname, 2),
        @QualName2 = parsename(@objname, 3),
        @QualName3 = parsename(@objname, 4)
IF (@UnqualOldName IS Null)
begin
	raiserror(15253,-1,-1,@objname)
	return 1
end

-- count name parts --
select @CountNumNodes = CASE WHEN @QualName3 IS NOT NULL THEN 4
                             WHEN @QualName2 IS NOT NULL THEN 3
                             WHEN @QualName1 IS NOT NULL THEN 2
                             ELSE 1 END
IF (@objtype  = 'database' AND @CountNumNodes > 1)
begin
	Raiserror(15395,-1,20,@objtypeIN)
	return 1
end
if (@objtype in ('object','userdatatype') AND @CountNumNodes > 3)
begin
	raiserror(15225,-1,-1,@objname, @CurrentDb, @objtypeIN)
	return 1
end


---------------------------------------------------------------------------
----------------------  PHASE 20:  Settle Parm1ItemType  ------------------
---------------------------------------------------------------------------

------------- database?
IF (@objtype  = 'database')
begin
	execute @ExecRC = sp_renamedb @UnqualOldName ,@newname -- de-docu old sproc
	IF @ExecRC <> 0
		return 1
	GOTO LABEL_51_AFTERUPDATES
end

-- assuming column/index-name, obtain object/column id's
if @QualName2 is not null
	select @objid = object_id(QuoteName(@QualName2) +'.'+ QuoteName(@QualName1))
else
	select @objid = object_id(QuoteName(@QualName1))

select @xtype = xtype, @replinfo = replinfo from sysobjects where id = @objid

------------ column?
if (@objtype = 'column' or @objtypeIN is null)
begin
	-- find column
	select @colid = NULL
	if (@xtype in ('U','V'))
		select @colid = colid from syscolumns
				where id = @objid and name = @UnqualOldName

	-- check for wrong param
	if ((@colid is not null AND @objtype <> 'column') OR
		(@colid is null AND @objtype = 'column'))
	begin
		raiserror(15248,-1,-1,@objtypeIN)
		return 1
	end

	-- remember if we've found a column
	IF (@colid is not null)
	begin
		if (@replinfo & @replbits <> 0)
			begin
				raiserror(15051,-1,-1)
				return (0)
			end
		select @objtype = 'column'
	end
end

------------ index?
if (lower(@objtype) = 'index' or @objtypeIN is null)
begin
	-- find index
	if (@xtype in ('U','V'))
		select @indid = indid from sysindexes
				where id = @objid and name = @UnqualOldName
					AND indid NOT IN (0, 255)

	-- check for wrong param
	if ((@indid is not null AND @objtype <> 'index') OR
		(@indid is null AND @objtype = 'index'))
	begin
		raiserror(15248,-1,-1,@objtypeIN)
		return 1
	end

	if (@indid is not null)
	begin
		select @objtype = 'index'
		select @cnstid = id, @xtype = xtype from sysobjects
			where name = @UnqualOldName AND parent_obj = @objid and xtype in ('PK','UQ')
	end
end

------------ object?
if (@objtype = 'object' or @objtypeIN is null)
begin
	-- get object id, type
	select @objid_tmp = object_id(@objname)

	select @xtype_tmp = xtype, @replinfo = replinfo
	from sysobjects where id = @objid_tmp

	-- if object is a system table, a Scalar function, or a table valued function, skip it.

	-- Cannot rename system table
	if @xtype_tmp = 'S'
		select @objid_tmp = NULL

	-- check for wrong param
	if ((@objid_tmp is not null AND @objtype <> 'object') OR
		(@objid_tmp is null AND @objtype = 'object'))
	begin
		raiserror(15248,-1,-1,@objtypeIN)
		return 1
	end

	if (@objid_tmp is not null)
	begin

		if (@xtype_tmp in ('U'))
		begin
			if (@replinfo & @replbits <> 0)
			begin
				raiserror(15051,-1,-1)
				return (0)
			end
		end

		select @objtype = 'object', @objid = @objid_tmp, @xtype = @xtype_tmp

		if (@xtype in ('PK','UQ'))
			select @parent_obj = parent_obj from sysobjects where id = @objid
	end
end


------------ type?
if (@objtype = 'userdatatype' or @objtypeIN is null)
begin
	select @xusertype = xusertype from systypes
		where name = @UnqualOldName and xusertype > 256
			AND (@QualName1 is null or uid = user_id(@QualName1))

	-- check for wrong param
	if ((@xusertype is not null AND @objtype <> 'userdatatype') OR
		(@xusertype is null AND @objtype = 'userdatatype'))
	begin
		raiserror(15248,-1,-1,@objtypeIN)
		return 1
	end

	if (@xusertype IS NOT null)
		select @objtype = 'userdatatype'
end

---------------------------------------------------------------------
-------------------  PHASE 30:  More parm edits  --------------------
---------------------------------------------------------------------

-- item type determined?
if (@objtype IS null)
begin
	raiserror(15225,-1,-1,@objname, @CurrentDb, @objtypeIN)
	return 1
end

-- was the original name valid given this type?
if (@objtype in ('object','userdatatype') AND @CountNumNodes > 3)
begin
	raiserror(15225,-1,-1,@objname, @CurrentDb, @objtypeIN)
	return 1
end

-- verify db qualifier is current db
if (@objtype in ('object','userdatatype'))
	select @QualName3 = @QualName2
if (isnull(@QualName3, @CurrentDb) <> @CurrentDb)
begin
	raiserror(15333,-1,-1,@QualName3)
	return 1
end

-- get owner id and check permissions
if (@objtype = 'userdatatype')
	select @ownerid = uid from systypes where xusertype = @xusertype
else
	select @ownerid = ObjectProperty(@objid, 'ownerid')
if (	(not (1 = is_member('db_owner')))
	AND (not (1 = is_member('db_ddladmin')))
	AND (not (1 = is_member(user_name(@ownerid)))) )
begin
	raiserror(15247,-1,-1)
	return 1
end

-- check if system object
if (ObjectProperty(@objid, 'IsMSShipped') = 1 OR
	ObjectProperty(@objid, 'IsSystemTable') = 1)
begin
	raiserror(15001,-1,-1, @objname)
	return 1
end

-- make sure orig no longer shows null
if @objtypeIN is null
	select @objtypeIN = @objtype

-- Check for name clashing with existing name(s)
if (@newname <> @UnqualOldName)
begin
	-- column name clash?
	if (@objtype = 'column')
		if (ColumnProperty(@objid, @newname, 'isidentity') is not null)
			select @UnqualOldName = NULL
	-- object name clash?
	if ( (@objtype = 'object' AND @xtype in ('PK','UQ'))
			OR @objtype = 'index')
		if exists (select * from sysindexes where id = @objid and name = @newname
					and indid not in (0,255))
			select @UnqualOldName = NULL
	-- index name clash?
	if (@objtype = 'object' OR @cnstid IS NOT null)
		if (object_id(QuoteName(user_name(@ownerid)) +'.'+ QuoteName(@newname)) is not null)
			select @UnqualOldName = NULL
	-- type name clash?
	if (@objtype = 'userdatatype')
		if exists (select * from systypes where name = @newname)
			select @UnqualOldName = NULL
	-- stop on clash
	if (@UnqualOldName is null)
	begin
		raiserror(15335,-1,-1,@newname,@objtypeIN)
		return 1
	end
end

--------------------------------------------------------------------------
--------------------  PHASE 32:  Temporay Table Isssue -------------------
--------------------------------------------------------------------------
-- Disallow renaming object to or from a temp name (starts with #)
if (@objtype = 'object' AND
	(substring(@newname,1,1) = N'#' OR
	substring(object_name(@objid),1,1) = N'#'))
begin
	raiserror(15600,-1,-1, 'sp_rename')
	return 1
end

--------------------------------------------------------------------------
--------------------  PHASE 34:  Cautionary messages  --------------------
--------------------------------------------------------------------------

if @objtype = 'column'
begin
	-- Check for Dependencies: No column rename if enforced dependency on column
	IF EXISTS (SELECT * FROM sysdepends WHERE depid = @objid AND depnumber = @colid AND deptype > 0)
	begin
		raiserror(15336,-1,-1, @objname)
		return 1
	end
end
else if @objtype = 'object'
begin
	-- Check for Dependencies: No RENAME or CHANGEOWNER of OBJECT when exists:
	IF EXISTS (SELECT * FROM sysdepends d WHERE
		d.depid = @objid		-- A dependency on this object
		AND d.deptype > 0		-- that is enforced
		AND @objid <> d.id		-- that isn't a self-reference (self-references don't use object name)
		AND @objid <>			-- And isn't a reference from a child object (also don't use object name)
			(SELECT o.parent_obj FROM sysobjects o WHERE o.id = d.id)
		)
	begin
		raiserror(15336,-1,-1, @objname)
		return 1
	end
end

-- WITH DEFERRED RESOLUTION, SYSDEPENDS IS NOT VERY ACCURATE, SO WE ALSO
--	RAISE THIS WARNING **UNCONDITIONALLY**, EVEN FOR NON-OBJECT RENAMES
raiserror(15477,-1,-1)

-- warn about dependencies...
if (@objtype = 'objects' and exists (select * from sysdepends where depid = @objid))
	raiserror(15337,-1,-1)

--------------------------------------------------------------------------
---------------------  PHASE 40:  Update system tables  ------------------
--------------------------------------------------------------------------

-- obtain owner-qual object name (for most below)
select @OwnAndObjName = QuoteName(user_name(@ownerid))+'.'+QuoteName(object_name(@objid))

-- DO THE UPDATES --
if (@objtype = 'userdatatype')						-------- change type name
	UPDATE systypes set name = @newname where xusertype = @xusertype
else if (@objtype = 'object')						-------- change object name
begin
	BEGIN  TRANSACTION
	-- Locks Object and increments schema_ver
	DBCC LockObjectSchema(@OwnAndObjName)
	-- update the object name
	UPDATE sysobjects set name = @newname where id = @objid
	-- update index-cnst name (no rows changed if not 'PK' or 'UQ')
	if (@xtype in ('PK','UQ'))
		UPDATE sysindexes set name = @newname where id = @parent_obj and name = @UnqualOldName
	-- update base/text index name (no rows changed if not there)
	else if (@xtype in ('U', 'TF'))
	begin
		UPDATE sysindexes set name = @newname where id = @objid AND indid = 0
		UPDATE sysindexes set name = convert(sysname,'t'+@newname)
							where id = @objid AND indid = 255
	end
	COMMIT TRANSACTION
end
else if (@objtype = 'index')						-------- change index name
begin
	BEGIN  TRANSACTION
	-- Locks Object and increments schema_ver.
	DBCC LockObjectSchema(@OwnAndObjName)
	-- update the index name
	UPDATE sysindexes set name = @newname where id = @objid and indid = @indid
	-- change object name if cnst
	if (@cnstid IS NOT null)
		UPDATE sysobjects set name = @newname where id = @cnstid
	COMMIT TRANSACTION
end
else if (@objtype = 'column')						-------- change column name
begin
	-- Use DBCC to check for column in use by check-constraint, computed-column, etc
	-- THIS IS NOT A DOCUMENTED DBCC: DO NOT USE DIRECTLY!
	DBCC RENAMECOLUMN ( @OwnAndObjName, @UnqualOldName, @newname )
end


-------------------------  Finalization  -----------------------
LABEL_51_AFTERUPDATES:
Raiserror(15338,-1,-1,@objtypeIN,@newname)
return 0 -- sp_rename
go
/*ANSI_NULLS off for after creation of sp_rename*/
Set ansi_nulls off
go



checkpoint
go

raiserror(15339,-1,-1,'sp_resetstatus')
Go

CREATE PROCEDURE sp_resetstatus  -- 1995/11/30 14:12 #12092
       @DBName          sysname
as

Set nocount on

Declare
       @msg             nvarchar(280)
      ,@RetCode         integer
      ,@_error          integer
      ,@_rowcount       integer
      ,@int1            integer
      ,@bitSuspect      integer
      ,@mode            integer
      ,@status          integer

Select
       @RetCode         = 0  -- 0=no_problem, 1=some_problem

---------------------  Restrict to SA  -------------------------

if (not (is_srvrolemember('sysadmin') = 1))
   begin
   RaisError(15247,-1,-1)
   Select @RetCode = 1
   GOTO LABEL_86BYEBYE
   end


------------------  Get SuspectBit id value  ------------------

SELECT       @bitSuspect = min(number)
      from
             master..spt_values
      where  type = 'D  '
      and    name = 'not recovered'  -- 256, Suspect

----------------------  Forbid active txn  ---------------------

--- (Prior spt_values Sel trips SET implicit_transactions!)


IF @@trancount > 0
   begin
   RaisError(15002,-1,-1,'sp_resetstatus')
   Select @RetCode = 1
   GOTO LABEL_86BYEBYE
   end


---------------  Obtain/Report pre-Update values  --------------------

SELECT
             @mode   = min(mode)
            ,@status = min(status)
      from
             master..sysdatabases
      where  name = @DBName

IF @@error <> 0 OR @status IS Null
   begin
   RaisError(15010,-1,-1,@DBName)
   Select @RetCode = 1
   GOTO LABEL_86BYEBYE
   end


Select @int1 = @status & @bitSuspect


Raiserror(15052,-1,-1 ,@DBName ,@mode ,@status ,@int1)

---------------------  Update sysdatabases row  ---------------------

BEGIN TRANSACTION


UPDATE
             master..sysdatabases
      set
             mode    = 0
            ,status  = status & (~ @bitSuspect)
      where  name    = @DBName
      and
            (mode   <> 0      OR
             status  & @bitSuspect > 0
            )

Select @_error = @@error ,@_rowcount = @@rowcount


IF @_error <> 0
   begin

   ROLLBACK TRANSACTION

   RaisError(15055,-1,-1)
   Select @RetCode = 1
   GOTO LABEL_86BYEBYE
   end


COMMIT TRANSACTION

-------- Report the results

IF @_rowcount = 0
   begin
   Raiserror(15056,-1,-1)
   end

ELSE
   begin

   Raiserror(15073,-1,-1, @DBName,@bitSuspect)

   Raiserror(15074,-1,-1)

   end


LABEL_86BYEBYE:

RETURN @RetCode

Go


raiserror(15339,-1,-1,'sp_add_file_recover_suspect_db')
Go
--
-- Name: sp_add_file_recover_suspect_db
-- Purpose: Adds a data or log file to a suspect database and runs
-- 		recovery on the database.  This SP should only be used
--		on databases that have been marked suspect due to
--		insufficient data (error 1105) or log (error 9002) space.
-- Note: This SP is not documented.  Only sp_add_data_file_recover_suspect_db
--	and sp_add_log_file_recover_suspect_db below are documented
--
create procedure sp_add_file_recover_suspect_db
	@dbName 	sysname			-- database name
	,@fileType	nvarchar(4)		-- "data" or "log"
	,@filegroup	nvarchar(260)		-- file group for new file
	,@name		nvarchar(260)		-- logical file name
	,@filename	nvarchar(260)		-- OS file name
	,@size		nvarchar(20) 	= NULL	-- initial file size
	,@maxsize	nvarchar(20) 	= NULL	-- maximum file size
	,@filegrowth	nvarchar(20) 	= NULL	-- growth increment

as

declare @currentStatus int
declare @suspectBit int
declare @dboOnlyBit int
declare @emergencyModeBit int
declare @returnCode int
declare @addCmd nvarchar(4000)
declare @isLog	int

set nocount on
select @suspectBit = 0x100
select @currentStatus = 0
select @returnCode = 0

---------------------  Restrict to SA  -------------------------

if (not (is_srvrolemember('sysadmin') = 1))
begin
   RaisError(15247,-1,-1)
   Select @returnCode = 1
   GOTO LABEL_FAILURE
end


------------------  Get Status Bit id values  ------------------

SELECT       @suspectBit = min(number)
      from
             master..spt_values
      where  type = 'D  '
      and    name = 'not recovered'  -- 256, Suspect

SELECT       @dboOnlyBit = min(number)
      from
             master..spt_values
      where  type = 'D  '
      and    name = 'dbo use only'  -- 2048, dbo only

SELECT       @emergencyModeBit = min(number)
      from
             master..spt_values
      where  type = 'D  '
      and    name = 'emergency mode'  -- 32768, dbo only

--print 'Bit values ' + convert(char(10), @suspectBit) + convert(char(10), @dboOnlyBit) + convert(char(10), @emergencyModeBit)

-- Determine if this is a data or log file
--
IF (UPPER (@fileType) = 'DATA')
begin
	select @isLog = 0
end
ELSE IF (UPPER (@fileType) = 'LOG')
begin
	select @isLog = 1
end
ELSE
begin
	print 'Must specify data or log file type'
	select @returnCode = 1
	GOTO LABEL_FAILURE
end



IF @@trancount > 0
begin
   RaisError(15002,-1,-1,'sp_add_file_recover_suspect_db')
   Select @returnCode = 1
   GOTO LABEL_FAILURE
end

-- check that current status includes suspect or emergency-mode
-- otherwise fail with database does not exist
--
select @currentStatus = status from master.dbo.sysdatabases where name = @dbName

if (@currentStatus is null)
begin
	RaisError(15010,-1,-1,@dbName)
	select @returnCode = 1
	goto LABEL_FAILURE
end

-- set new temporary status to dbo-only and emergency-mode
--
BEGIN TRAN
update master.dbo.sysdatabases set status = (status | @dboOnlyBit | @emergencyModeBit) where name = @dbName
IF @@error <> 0
begin
   ROLLBACK TRANSACTION
   RaisError(15055,-1,-1)
   Select @returnCode = 1
   GOTO LABEL_FAILURE
end
COMMIT TRAN
checkpoint

-- Build the Alter Database Add File string
--
select @addCmd = 'ALTER DATABASE ' + @dbName + ' ADD'
IF (@isLog = 1)
begin
	select @addCmd = @addCmd + ' LOG FILE'
end
ELSE
begin
	select @addCmd = @addCmd + ' FILE'
end
select @addCmd = @addCmd + '(NAME = [' + @name + '], FILENAME = ''' + @filename + ''''
if (@size IS NOT NULL)
begin
	select @addCmd = @addCmd + ', SIZE = ' + @size
end
if (@maxsize IS NOT NULL)
begin
	select @addCmd = @addCmd + ', MAXSIZE = ' + @maxsize
end
if (@filegrowth IS NOT NULL)
begin
	select @addCmd = @addCmd + ', FILEGROWTH = ' + @filegrowth
end
select @addCmd = @addCmd + ' )'
if (@filegroup IS NOT NULL)
begin
	select @addCmd = @addCmd + ' TO FILEGROUP [' + @filegroup + ']'
end
print @addCmd

EXECUTE (@addCmd)

-- restore status to what it was before adding the file
--
BEGIN TRAN
update master.dbo.sysdatabases set status = @currentStatus where name = @dbName
IF @@error <> 0
   begin

   ROLLBACK TRANSACTION

   RaisError(15055,-1,-1)
   Select @returnCode = 1
   GOTO LABEL_FAILURE
   end
COMMIT TRAN
checkpoint

-- Turn off suspect bit if it is on
--
if ((@currentStatus & @suspectBit) <> 0)
begin
    exec sp_resetstatus @dbName
end

-- Run recovery on the database
--
select @addCmd = 'dbcc dbrecover (' + @dbName + ')'
exec (@addCmd)


GOTO LABEL_SUCCESS

LABEL_FAILURE:
	--print 'Failed to add file to and recover the suspect database.'
	return @returnCode

LABEL_SUCCESS:
	--print 'Successfully added file to the database'
	return @returnCode
-- sp_add_file_recover_suspect_db
go


raiserror(15339,-1,-1,'sp_add_data_file_recover_suspect_db')
Go
--
-- Name: sp_add_data_file_recover_suspect_db
-- Purpose: Adds a data file to a suspect database and runs
-- 		recovery on the database.  This SP should only be used
--		on databases that have been marked suspect due to
--		insufficient data (error 1105) or log (error 9002) space.
--
create procedure sp_add_data_file_recover_suspect_db
	@dbName 	sysname			-- database name
	,@filegroup	nvarchar(260)		-- file group for new file
	,@name		nvarchar(260)		-- logical file name
	,@filename	nvarchar(260)		-- OS file name
	,@size		nvarchar(20) 	= NULL	-- initial file size
	,@maxsize	nvarchar(20) 	= NULL	-- maximum file size
	,@filegrowth	nvarchar(20) 	= NULL	-- growth increment
as
execute sp_add_file_recover_suspect_db @dbName, 'DATA', @filegroup, @name, @filename, @size, @maxsize, @filegrowth
go

raiserror(15339,-1,-1,'sp_add_log_file_recover_suspect_db')
Go
--
-- Name: sp_add_log_file_recover_suspect_db
-- Purpose: Adds a log file to a suspect database and runs
-- 		recovery on the database.  This SP should only be used
--		on databases that have been marked suspect due to
--		insufficient data (error 1105) or log (error 9002) space.
--
create procedure sp_add_log_file_recover_suspect_db
	@dbName 	sysname			-- database name
	,@name		nvarchar(260)		-- logical file name
	,@filename	nvarchar(260)		-- OS file name
	,@size		nvarchar(20) 	= NULL	-- initial file size
	,@maxsize	nvarchar(20) 	= NULL	-- maximum file size
	,@filegrowth	nvarchar(20) 	= NULL	-- growth increment
as
execute sp_add_file_recover_suspect_db @dbName, 'LOG', NULL, @name, @filename, @size, @maxsize, @filegrowth
go


raiserror(15339,-1,-1,'sp_spaceused')
go
create procedure sp_spaceused --- 1996/08/20 17:01
@objname nvarchar(776) = null,		-- The object we want size on.
@updateusage varchar(5) = false		-- Param. for specifying that
					-- usage info. should be updated.
as

declare @id	int			-- The object id of @objname.
declare @type	character(2) -- The object type.
declare	@pages	int			-- Working variable for size calc.
declare @dbname sysname
declare @dbsize dec(15,0)
declare @logsize dec(15)
declare @bytesperpage	dec(15,0)
declare @pagesperMB		dec(15,0)

/*Create temp tables before any DML to ensure dynamic
**  We need to create a temp table to do the calculation.
**  reserved: sum(reserved) where indid in (0, 1, 255)
**  data: sum(dpages) where indid < 2 + sum(used) where indid = 255 (text)
**  indexp: sum(used) where indid in (0, 1, 255) - data
**  unused: sum(reserved) - sum(used) where indid in (0, 1, 255)
*/
create table #spt_space
(
	rows		int null,
	reserved	dec(15) null,
	data		dec(15) null,
	indexp		dec(15) null,
	unused		dec(15) null
)

/*
**  Check to see if user wants usages updated.
*/

if @updateusage is not null
	begin
		select @updateusage=lower(@updateusage)

		if @updateusage not in ('true','false')
			begin
				raiserror(15143,-1,-1,@updateusage)
				return(1)
			end
	end
/*
**  Check to see that the objname is local.
*/
if @objname IS NOT NULL
begin

	select @dbname = parsename(@objname, 3)

	if @dbname is not null and @dbname <> db_name()
		begin
			raiserror(15250,-1,-1)
			return (1)
		end

	if @dbname is null
		select @dbname = db_name()

	/*
	**  Try to find the object.
	*/
	select @id = null
	select @id = id, @type = xtype
		from sysobjects
			where id = object_id(@objname)

	/*
	**  Does the object exist?
	*/
	if @id is null
		begin
			raiserror(15009,-1,-1,@objname,@dbname)
			return (1)
		end


	if not exists (select * from sysindexes
				where @id = id and indid < 2)

		if      @type in ('P ','D ','R ','TR','C ','RF') --data stored in sysprocedures
				begin
					raiserror(15234,-1,-1)
					return (1)
				end
		else if @type = 'V ' -- View => no physical data storage.
				begin
					raiserror(15235,-1,-1)
					return (1)
				end
		else if @type in ('PK','UQ') -- no physical data storage. --?!?! too many similar messages
				begin
					raiserror(15064,-1,-1)
					return (1)
				end
		else if @type = 'F ' -- FK => no physical data storage.
				begin
					raiserror(15275,-1,-1)
					return (1)
				end
end

/*
**  Update usages if user specified to do so.
*/

if @updateusage = 'true'
	begin
		if @objname is null
			dbcc updateusage(0) with no_infomsgs
		else
			dbcc updateusage(0,@objname) with no_infomsgs
		print ' '
	end


set nocount on

/*
**  If @id is null, then we want summary data.
*/
/*	Space used calculated in the following way
**	@dbsize = Pages used
**	@bytesperpage = d.low (where d = master.dbo.spt_values) is
**	the # of bytes per page when d.type = 'E' and
**	d.number = 1.
**	Size = @dbsize * d.low / (1048576 (OR 1 MB))
*/
if @id is null
begin
	select @dbsize = sum(convert(dec(15),size))
		from dbo.sysfiles
		where (status & 64 = 0)

	select @logsize = sum(convert(dec(15),size))
		from dbo.sysfiles
		where (status & 64 <> 0)

	select @bytesperpage = low
		from master.dbo.spt_values
		where number = 1
			and type = 'E'
	select @pagesperMB = 1048576 / @bytesperpage

	select  database_name = db_name(),
		database_size =
			ltrim(str((@dbsize + @logsize) / @pagesperMB,15,2) + ' MB'),
		'unallocated space' =
			ltrim(str((@dbsize -
				(select sum(convert(dec(15),reserved))
					from sysindexes
						where indid in (0, 1, 255)
				)) / @pagesperMB,15,2)+ ' MB')

	print ' '
	/*
	**  Now calculate the summary data.
	**  reserved: sum(reserved) where indid in (0, 1, 255)
	*/
	insert into #spt_space (reserved)
		select sum(convert(dec(15),reserved))
			from sysindexes
				where indid in (0, 1, 255)

	/*
	** data: sum(dpages) where indid < 2
	**	+ sum(used) where indid = 255 (text)
	*/
	select @pages = sum(convert(dec(15),dpages))
			from sysindexes
				where indid < 2
	select @pages = @pages + isnull(sum(convert(dec(15),used)), 0)
		from sysindexes
			where indid = 255
	update #spt_space
		set data = @pages


	/* index: sum(used) where indid in (0, 1, 255) - data */
	update #spt_space
		set indexp = (select sum(convert(dec(15),used))
				from sysindexes
					where indid in (0, 1, 255))
			    - data

	/* unused: sum(reserved) - sum(used) where indid in (0, 1, 255) */
	update #spt_space
		set unused = reserved
				- (select sum(convert(dec(15),used))
					from sysindexes
						where indid in (0, 1, 255))

	select reserved = ltrim(str(reserved * d.low / 1024.,15,0) +
				' ' + 'KB'),
		data = ltrim(str(data * d.low / 1024.,15,0) +
				' ' + 'KB'),
		index_size = ltrim(str(indexp * d.low / 1024.,15,0) +
				' ' + 'KB'),
		unused = ltrim(str(unused * d.low / 1024.,15,0) +
				' ' + 'KB')
		from #spt_space, master.dbo.spt_values d
		where d.number = 1
			and d.type = 'E'
end

/*
**  We want a particular object.
*/
else
begin
	/*
	**  Now calculate the summary data.
	**  reserved: sum(reserved) where indid in (0, 1, 255)
	*/
	insert into #spt_space (reserved)
		select sum(reserved)
			from sysindexes
				where indid in (0, 1, 255)
					and id = @id

	/*
	** data: sum(dpages) where indid < 2
	**	+ sum(used) where indid = 255 (text)
	*/
	select @pages = sum(dpages)
			from sysindexes
				where indid < 2
					and id = @id
	select @pages = @pages + isnull(sum(used), 0)
		from sysindexes
			where indid = 255
				and id = @id
	update #spt_space
		set data = @pages


	/* index: sum(used) where indid in (0, 1, 255) - data */
	update #spt_space
		set indexp = (select sum(used)
				from sysindexes
					where indid in (0, 1, 255)
						and id = @id)
			    - data

	/* unused: sum(reserved) - sum(used) where indid in (0, 1, 255) */
	update #spt_space
		set unused = reserved
				- (select sum(used)
					from sysindexes
						where indid in (0, 1, 255)
							and id = @id)
	update #spt_space
		set rows = i.rows
			from sysindexes i
				where i.indid < 2
					and i.id = @id

	select name = object_name(@id),
		rows = convert(char(11), rows),
		reserved = ltrim(str(reserved * d.low / 1024.,15,0) +
				' ' + 'KB'),
		data = ltrim(str(data * d.low / 1024.,15,0) +
				' ' + 'KB'),
		index_size = ltrim(str(indexp * d.low / 1024.,15,0) +
				' ' + 'KB'),
		unused = ltrim(str(unused * d.low / 1024.,15,0) +
				' ' + 'KB')
	from #spt_space, master.dbo.spt_values d
		where d.number = 1
			and d.type = 'E'
end

return (0) -- sp_spaceused
go

checkpoint
go

raiserror(15339,-1,-1,'sp_sqlexec')

-- sp_sqlexec should not be allowed to update system catalog
exec sp_configure 'allow updates',0
reconfigure with override
go

create procedure sp_sqlexec --- 1996/04/08 00:00
    @p1 text
as
exec(@p1)
go

exec sp_configure 'allow updates',1
reconfigure with override

go


raiserror(15339,-1,-1,'sp_unbindefault')
go
create procedure sp_unbindefault --- 1996/08/13 13:34
@objname nvarchar(776),         /* table/column or datatype name */
@futureonly varchar(15) = NULL   /* flag to indicate extent of binding */
as

declare @futurevalue varchar(15) /* the value of @futureonly that causes
               ** the binding to be limited */

declare
	@vc1			nvarchar(517)
declare
	@tab_id			integer
	,@cur_tab_id	integer
	,@colid			integer
	,@cdefault		integer
	,@olddefault	integer
	,@xusertype		smallint

	,@UnqualObj		sysname
	,@QualObj1		sysname
	,@QualObj2		sysname
	,@QualObj3		sysname

set cursor_close_on_commit	off
select @futurevalue = 'futureonly'  /* initialize @futurevalue */

/*
**  When a default or rule is bound to a user-defined datatype, it is also
**  bound, by default, to any columns of the user datatype that are currently
**  using the existing default or rule as their default or rule.  This default
**  action may be overridden by setting @futureonly = @futurevalue when the
**  procedure is invoked.  In this case existing columns with the user
**  datatype won't have their existing default or rule changed.
*/

-- get name parts --
select @UnqualObj = parsename(@objname, 1),
        @QualObj1 = parsename(@objname, 2),
        @QualObj2 = parsename(@objname, 3),
        @QualObj3 = parsename(@objname, 4)

IF (@UnqualObj is NULL OR @QualObj3 is not null)
   begin
   raiserror(15253,-1,-1,@objname)
   return (1)
   end


------------------  Verify database.

if (@QualObj2 is not null and @QualObj1 is null)
	begin
		raiserror(15084,-1,-1)
		return (1)
	end

/*
**  If @objname is of the form tab.col then we are unbinding a column.
**  Otherwise its a datatype.  In the column case, we need to extract
**  and verify the table and column names and make sure the user owns
**  the table that is getting the default unbound.
*/
if @QualObj1 is not null
begin
	if (@QualObj2 is not null)
		select @vc1 = QuoteName(@QualObj2) + '.' + QuoteName(@QualObj1)
	else
		select @vc1 = QuoteName(@QualObj1)

   /*
   **  Find it and unbind it.
   */
   select @tab_id = c.id, @colid = c.colid, @cdefault = c.cdefault
   from syscolumns c, sysobjects o
      where c.id = o.id
         and c.name = @UnqualObj
         and o.id = object_id(@vc1,'local')
         and o.xtype = N'U '

	if @tab_id is null
	begin
		 raiserror(15104,-1,-1,@QualObj1,@UnqualObj)
		 return(1)
	end

	if @cdefault = 0
	begin
		raiserror(15236,-1,-1,@objname)
		return(1)
	end

	if exists
	(select	*
		from	sysobjects o
		where	@cdefault	= o.id
			and	@tab_id		= o.parent_obj)
		begin
			raiserror(15049,-1,-1, @objname)
			return (1)
		end

	BEGIN TRANSACTION txn_unbindefault_1

         /*
         **  Since binding a default is a schema change,
         **  update schema count
         **  for the object in the sysobjects table.
         */
		dbcc LockObjectSchema(@vc1) --- Undocu. Locks out other schema changes until commit, and increments sysobjects.schema_ver.

		update syscolumns set cdefault = 0
			from syscolumns where id = @tab_id and colid = @colid

	COMMIT TRANSACTION txn_bindefault_1

	raiserror(15519,-1,-1)
	return (0)

end

else

begin
   /*
   **  We're unbinding to a user type.  In this case, the @objname
   **  is really the name of the user datatype.
   **  When we unbind to a user type, any existing columns get changed
   **  to the new binding unless their current binding is not equal
   **  to the current binding for the usertype or if they set the
   **  @futureonly parameter to @futurevalue.
   */

   /*
   **  Get the current default for the datatype.
   */
   select @olddefault = tdefault, @xusertype = xusertype
		from systypes where name = @UnqualObj and xusertype > 256
		AND (is_member('db_owner') = 1 OR is_member('db_ddladmin') = 1 OR is_member(user_name(uid))=1)

   if @olddefault is null
      begin
         raiserror(15036,-1,-1,@UnqualObj)
         return (1)
      end

   if @olddefault = 0
      begin
         raiserror(15237,-1,-1,@UnqualObj)
         return (1)
      end

   update systypes set tdefault = 0
      from systypes
      where xusertype = @xusertype

   raiserror(15520,-1,-1)

   /*
   **  Now see if there are any columns with the usertype that
   **  need the new binding.
   */
   select @futureonly = lower(@futureonly)
   if isnull(@futureonly, ' ') <> @futurevalue
   begin
		declare ms_crs_unbindefault_1 cursor local static for
			select
			distinct
				 c.id
				,c.colid
			from	 syscolumns c JOIN sysobjects o ON c.id = o.id AND o.xtype = N'U '
         		where  c.xusertype = @xusertype
            		and c.cdefault = @olddefault
			order by c.id
					for read only

		open ms_crs_unbindefault_1

		fetch next from ms_crs_unbindefault_1 into
			@tab_id
			,@colid

		BEGIN TRANSACTION txn_unbindefault_2

			while @@fetch_status = 0
			begin

				select @vc1 = quotename(user_name(OBJECTPROPERTY(@tab_id,'OwnerId'))) + '.'
				+ quotename(object_name(@tab_id))

				dbcc LockObjectSchema(@vc1) --- Undocu. Locks out other schema changes until commit, and increments sysobjects.schema_ver.

				select @cur_tab_id = @tab_id

				while @cur_tab_id = @tab_id and @@fetch_status = 0
				begin
  					update syscolumns set cdefault = 0
					from syscolumns
					where id = @tab_id and colid = @colid

					fetch next from ms_crs_unbindefault_1 into
						@tab_id
						,@colid
				end
			end --loop 3      /*

		COMMIT TRANSACTION txn_unbindefault_2

		deallocate ms_crs_unbindefault_1

		raiserror(15521,-1,-1)
	end
end

return (0) -- sp_unbindefault
go

raiserror(15339,-1,-1,'sp_unbindrule')
go
create procedure sp_unbindrule --- 1996/08/13 13:33
@objname nvarchar(776),         /* table/column or datatype name */
@futureonly varchar(15) = NULL      /* flag to indicate extent of binding */
as

declare @oldrule int /* current rule for type */
declare @tabname sysname     /* name of table */
declare @colname sysname     /* name of column */
declare @futurevalue varchar(15) /* the value of @futureonly that causes
                           ** the binding to be limited */

declare
	@vc1			nvarchar(517)
declare
	 @obj_id		integer
	,@cur_tab_id	integer
	,@colid			integer
	,@domain		integer
	,@xusertype		smallint

	,@owner_name	sysname
	,@obj_name		sysname

	,@UnqualObj			sysname
	,@QualObj1			sysname
	,@QualObj2			sysname
	,@QualObj3			sysname

set cursor_close_on_commit	off

select @futurevalue = 'futureonly'  /* initialize @futurevalue */

/*
**  When a default or rule is bound to a user-defined datatype, it is also
**  bound, by default, to any columns of the user datatype that are currently
**  using the existing default or rule as their default or rule.  This default
**  action may be overridden by setting @futureonly = @futurevalue when the
**  procedure is invoked.  In this case existing columns with the user
**  datatype won't have their existing default or rule changed.
*/

-- get name parts --
select @UnqualObj = parsename(@objname, 1),
        @QualObj1 = parsename(@objname, 2),
        @QualObj2 = parsename(@objname, 3),
        @QualObj3 = parsename(@objname, 4)

IF (@UnqualObj is NULL OR @QualObj3 is not null)
   begin
   raiserror(15253,-1,-1,@objname)
   return (1)
   end


------------------  Verify database.

if (@QualObj2 is not null and @QualObj1 is null)
	begin
		raiserror(15084,-1,-1)
		return (1)
	end

/*
**  If @objname is of the form tab.col then we are unbinding a column.
**  Otherwise its a datatype.  In the column case, we need to extract
**  and verify the table and column names and make sure the user owns
**  the table that is getting the default unbound.
*/
if @QualObj1 is not null
begin
	if (@QualObj2 is not null)
		select @vc1 = QuoteName(@QualObj2) + '.' + QuoteName(@QualObj1)
	else
		select @vc1 = QuoteName(@QualObj1)

	select	@obj_id = c.id,	@colid = c.colid,	@domain = c.domain
		from syscolumns c, sysobjects o
	where c.id = o.id
	and c.name = @UnqualObj
	and o.id = object_id(@vc1,'local')
	and o.xtype = N'U '

	if @obj_id is null
	begin
		raiserror(15104,-1,-1,@QualObj1,@UnqualObj)
		return (1)
	end

	if @domain = 0
	begin
		raiserror(15238,-1,-1,@objname)
		return (1)
	end

	BEGIN TRANSACTION txn_unbindrule_1

		/*
		**  Update schema count
		**  for the object in the sysobjects table.
		*/

		dbcc LockObjectSchema(@vc1) -- Locks Object and increments schema_ver.

		update syscolumns set domain = 0
			from syscolumns c where id = @obj_id and colid = @colid

	COMMIT TRANSACTION txn_unbindrule_1

	raiserror(15522,-1,-1)

end
else
begin

	select @oldrule = domain, @xusertype = xusertype
		from systypes where name = @UnqualObj and xusertype > 256
		AND (is_member('db_owner') = 1 OR is_member('db_ddladmin') = 1 OR is_member(user_name(uid))=1)

	if @xusertype is null
	begin
		raiserror(15036,-1,-1,@UnqualObj)
		return (1)
	end

	if @oldrule = 0
	begin
		raiserror(15239,-1,-1,@UnqualObj)
		return (1)
	end

	update systypes set domain = 0
	from systypes
	where xusertype = @xusertype

	raiserror(15523,-1,-1)

	select @futureonly = lower(@futureonly)
	if isnull(@futureonly, ' ') <> @futurevalue
	begin

		declare ms_crs_unbindrule_1 cursor local static for
		select
			distinct
			 o.id
			,user_name(o.uid)
			,o.name
			,c.colid
		from	syscolumns c
			,sysobjects o
         where o.id = c.id and o.xtype = N'U '
            and c.xusertype = @xusertype
            and c.domain = @oldrule
	    order by o.id
            for read only

		open ms_crs_unbindrule_1


        BEGIN TRANSACTION txn_unbindrule_2

			fetch next from ms_crs_unbindrule_1 into
			@obj_id
			,@owner_name
			,@obj_name
			,@colid

			while @@fetch_status = 0
			begin

				select @vc1 = quotename(@owner_name) + '.' + quotename(@obj_name)

				dbcc LockObjectSchema(@vc1) --- Undocu. Locks out other schema changes until commit, and increments sysobjects.schema_ver.

				select @cur_tab_id = @obj_id

				while @cur_tab_id = @obj_id and @@fetch_status = 0
				begin
  					update syscolumns set domain = 0
					from syscolumns
					where id = @obj_id and colid = @colid

					fetch next from ms_crs_unbindrule_1 into
					@obj_id
					,@owner_name
					,@obj_name
					,@colid
				end
			end

		COMMIT TRANSACTION txn_unbindrule_2
		deallocate ms_crs_unbindrule_1
		raiserror(15524,-1,-1)

	end
end

return (0)	--sp_unbindrule
go


checkpoint
go

--
raiserror(15339,-1,-1,'sp_who')
go
create procedure sp_who  --- 1995/11/28 15:48
       @loginame sysname = NULL --or 'active'
as

declare	 @spidlow	int,
		 @spidhigh	int,
		 @spid		int,
		 @sid		varbinary(85)

select	 @spidlow	=     0
		,@spidhigh	= 32767


if (	@loginame is not NULL
   AND	upper(@loginame) = 'ACTIVE'
   )
	begin

	select spid , ecid, status
              ,loginame=rtrim(loginame)
	      ,hostname ,blk=convert(char(5),blocked)
	      ,dbname = case
						when dbid = 0 then null
						when dbid <> 0 then db_name(dbid)
					end
		  ,cmd
	from  master.dbo.sysprocesses
	where spid >= @spidlow and spid <= @spidhigh AND
	      upper(cmd) <> 'AWAITING COMMAND'

	return (0)
	end

if (@loginame is not NULL
   AND	upper(@loginame) <> 'ACTIVE'
   )
begin
	if (@loginame like '[0-9]%')	-- is a spid.
	begin
		select @spid = convert(int, @loginame)
		select spid, ecid, status,
			   loginame=rtrim(loginame),
			   hostname,blk = convert(char(5),blocked),
			   dbname = case
							when dbid = 0 then null
							when dbid <> 0 then db_name(dbid)
						end
			  ,cmd
		from  master.dbo.sysprocesses
		where spid = @spid
	end
	else
	begin
		select @sid = suser_sid(@loginame)
		if (@sid is null)
		begin
			raiserror(15007,-1,-1,@loginame)
			return (1)
		end
		select spid, ecid, status,
			   loginame=rtrim(loginame),
			   hostname ,blk=convert(char(5),blocked),
			   dbname = case
							when dbid = 0 then null
							when dbid <> 0 then db_name(dbid)
						end
			   ,cmd
		from  master.dbo.sysprocesses
		where sid = @sid
	end
	return (0)
end


/* loginame arg is null */
select spid,
	   ecid,
	   status,
       loginame=rtrim(loginame),
	   hostname,
	   blk=convert(char(5),blocked),
	   dbname = case
					when dbid = 0 then null
					when dbid <> 0 then db_name(dbid)
				end
	   ,cmd
from  master.dbo.sysprocesses
where spid >= @spidlow and spid <= @spidhigh


return (0) -- sp_who
go



raiserror(15339,-1,-1,'sp_who2')
go
CREATE PROCEDURE sp_who2  --- 1995/11/03 10:16
    @loginame     sysname = NULL
as

set nocount on

declare
    @retcode         int

declare
    @sidlow         varbinary(85)
   ,@sidhigh        varbinary(85)
   ,@sid1           varbinary(85)
   ,@spidlow         int
   ,@spidhigh        int

declare
    @charMaxLenLoginName      varchar(6)
   ,@charMaxLenDBName         varchar(6)
   ,@charMaxLenCPUTime        varchar(10)
   ,@charMaxLenDiskIO         varchar(10)
   ,@charMaxLenHostName       varchar(10)
   ,@charMaxLenProgramName    varchar(10)
   ,@charMaxLenLastBatch      varchar(10)
   ,@charMaxLenCommand        varchar(10)

declare
    @charsidlow              varchar(85)
   ,@charsidhigh             varchar(85)
   ,@charspidlow              varchar(11)
   ,@charspidhigh             varchar(11)

--------

select
    @retcode         = 0      -- 0=good ,1=bad.

--------defaults
select @sidlow = convert(varbinary(85), (replicate(char(0), 85)))
select @sidhigh = convert(varbinary(85), (replicate(char(1), 85)))

select
    @spidlow         = 0
   ,@spidhigh        = 32767

--------------------------------------------------------------
IF (@loginame IS     NULL)  --Simple default to all LoginNames.
      GOTO LABEL_17PARM1EDITED

--------

-- select @sid1 = suser_sid(@loginame)
select @sid1 = null
if exists(select * from master.dbo.syslogins where loginname = @loginame)
	select @sid1 = sid from master.dbo.syslogins where loginname = @loginame

IF (@sid1 IS NOT NULL)  --Parm is a recognized login name.
   begin
   select @sidlow  = suser_sid(@loginame)
         ,@sidhigh = suser_sid(@loginame)
   GOTO LABEL_17PARM1EDITED
   end

--------

IF (lower(@loginame) IN ('active'))  --Special action, not sleeping.
   begin
   select @loginame = lower(@loginame)
   GOTO LABEL_17PARM1EDITED
   end

--------

IF (patindex ('%[^0-9]%' , isnull(@loginame,'z')) = 0)  --Is a number.
   begin
   select
             @spidlow   = convert(int, @loginame)
            ,@spidhigh  = convert(int, @loginame)
   GOTO LABEL_17PARM1EDITED
   end

--------

RaisError(15007,-1,-1,@loginame)
select @retcode = 1
GOTO LABEL_86RETURN


LABEL_17PARM1EDITED:


--------------------  Capture consistent sysprocesses.  -------------------

SELECT

  spid
 ,status
 ,sid
 ,hostname
 ,program_name
 ,cmd
 ,cpu
 ,physical_io
 ,blocked
 ,dbid
 ,convert(sysname, rtrim(loginame))
        as loginname
 ,spid as 'spid_sort'

 ,  substring( convert(varchar,last_batch,111) ,6  ,5 ) + ' '
  + substring( convert(varchar,last_batch,113) ,13 ,8 )
       as 'last_batch_char'

      INTO    #tb1_sysprocesses
      from master.dbo.sysprocesses   (nolock)



--------Screen out any rows?

IF (@loginame IN ('active'))
   DELETE #tb1_sysprocesses
         where   lower(status)  = 'sleeping'
         and     upper(cmd)    IN (
                     'AWAITING COMMAND'
                    ,'MIRROR HANDLER'
                    ,'LAZY WRITER'
                    ,'CHECKPOINT SLEEP'
                    ,'RA MANAGER'
                                  )

         and     blocked       = 0



--------Prepare to dynamically optimize column widths.


Select
    @charsidlow     = convert(varchar(85),@sidlow)
   ,@charsidhigh    = convert(varchar(85),@sidhigh)
   ,@charspidlow     = convert(varchar,@spidlow)
   ,@charspidhigh    = convert(varchar,@spidhigh)



SELECT
             @charMaxLenLoginName =
                  convert( varchar
                          ,isnull( max( datalength(loginname)) ,5)
                         )

            ,@charMaxLenDBName    =
                  convert( varchar
                          ,isnull( max( datalength( rtrim(convert(varchar(128),db_name(dbid))))) ,6)
                         )

            ,@charMaxLenCPUTime   =
                  convert( varchar
                          ,isnull( max( datalength( rtrim(convert(varchar(128),cpu)))) ,7)
                         )

            ,@charMaxLenDiskIO    =
                  convert( varchar
                          ,isnull( max( datalength( rtrim(convert(varchar(128),physical_io)))) ,6)
                         )

            ,@charMaxLenCommand  =
                  convert( varchar
                          ,isnull( max( datalength( rtrim(convert(varchar(128),cmd)))) ,7)
                         )

            ,@charMaxLenHostName  =
                  convert( varchar
                          ,isnull( max( datalength( rtrim(convert(varchar(128),hostname)))) ,8)
                         )

            ,@charMaxLenProgramName =
                  convert( varchar
                          ,isnull( max( datalength( rtrim(convert(varchar(128),program_name)))) ,11)
                         )

            ,@charMaxLenLastBatch =
                  convert( varchar
                          ,isnull( max( datalength( rtrim(convert(varchar(128),last_batch_char)))) ,9)
                         )
      from
             #tb1_sysprocesses
      where
--             sid >= @sidlow
--      and    sid <= @sidhigh
--      and
             spid >= @spidlow
      and    spid <= @spidhigh



--------Output the report.


EXECUTE(
'
SET nocount off

SELECT
             SPID          = convert(char(5),spid)

            ,Status        =
                  CASE lower(status)
                     When ''sleeping'' Then lower(status)
                     Else                   upper(status)
                  END

            ,Login         = substring(loginname,1,' + @charMaxLenLoginName + ')

            ,HostName      =
                  CASE hostname
                     When Null  Then ''  .''
                     When '' '' Then ''  .''
                     Else    substring(hostname,1,' + @charMaxLenHostName + ')
                  END

            ,BlkBy         =
                  CASE               isnull(convert(char(5),blocked),''0'')
                     When ''0'' Then ''  .''
                     Else            isnull(convert(char(5),blocked),''0'')
                  END

            ,DBName        = substring(case when dbid = 0 then null when dbid <> 0 then db_name(dbid) end,1,' + @charMaxLenDBName + ')
            ,Command       = substring(cmd,1,' + @charMaxLenCommand + ')

            ,CPUTime       = substring(convert(varchar,cpu),1,' + @charMaxLenCPUTime + ')
            ,DiskIO        = substring(convert(varchar,physical_io),1,' + @charMaxLenDiskIO + ')

            ,LastBatch     = substring(last_batch_char,1,' + @charMaxLenLastBatch + ')

            ,ProgramName   = substring(program_name,1,' + @charMaxLenProgramName + ')
            ,SPID          = convert(char(5),spid)  --Handy extra for right-scrolling users.
      from
             #tb1_sysprocesses  --Usually DB qualification is needed in exec().
      where
             spid >= ' + @charspidlow  + '
      and    spid <= ' + @charspidhigh + '

      -- (Seems always auto sorted.)   order by spid_sort

SET nocount on
'
)
/*****AKUNDONE: removed from where-clause in above EXEC sqlstr
             sid >= ' + @charsidlow  + '
      and    sid <= ' + @charsidhigh + '
      and
**************/


LABEL_86RETURN:


if (object_id('tempdb..#tb1_sysprocesses') is not null)
            drop table #tb1_sysprocesses

return @retcode -- sp_who2
go



checkpoint
go

---------------------------------------------------------------------------------------------
---------------------------------------------------------------------------------------------
---------------------------------------------------------------------------------------------


---- Create following procs last, since they reference other procedures.



raiserror(15339,-1,-1,'sp_check_removable')
go
create procedure sp_check_removable @autofix varchar(4)
as

declare @dbosid varbinary (86)
declare @dbname sysname
declare @exec_stmt nvarchar(540)
declare @fgname sysname

select @dbname=db_name()

/* Verify that SA owns the database. */

select @dbosid = sid from master..sysdatabases where name = @dbname
if @dbosid <> 0x01
	if @autofix='auto'
	begin
		-- changing DBO to SA
		update sysdatabases set sid = 0x01
			where name = @dbname
		update sysusers set sid = 0x01
			where uid = 1
	end
	else
	begin
		raiserror(15258,-1,-1, @dbname)
		return(1)
	end

	-- USE CORRECT non-dbo/guest CHECKING
	declare @ret int
	exec @ret = sp_check_removable_sysusers @autofix
	if @ret <> 0
		return 1


	-- Run UPDATE STATISTICS on all user tables if there are
	-- no user defined filegroups
	if @autofix='auto' and
		(select count(*) from sysfilegroups) = 1
	begin
		select @exec_stmt = N'USE ' + quotename( @dbname , '[')
		+ N' exec sp_updatestats ''RESAMPLE'' '
		exec (@exec_stmt)
	end

	exec('dump tran '+@dbname+' with no_log')

	if (select count(*) from sysfilegroups) > 1
	begin
		if @autofix='auto'
		begin
			-- Mark any non-primary filegroups as READONLY
			DECLARE ms_crs_fg CURSOR LOCAL STATIC
			FOR SELECT groupname FROM sysfilegroups fg
				WHERE fg.groupid > 1 -- not primary
				AND fg.status & 0x8 = 0 -- not already readonly
				AND (SELECT count (*) FROM sysfiles f WHERE
				f.groupid = fg.groupid) > 0 -- has some files
			OPEN ms_crs_fg
			FETCH NEXT FROM ms_crs_fg INTO @fgname
			WHILE (@@FETCH_STATUS <> -1)
			BEGIN
				SELECT @exec_stmt = 'ALTER DATABASE '
				+ quotename( @dbname , '[')
				+ ' MODIFY FILEGROUP '
				+ quotename( @fgname , '[')
				+ ' READONLY'
				EXEC (@exec_stmt)
				FETCH NEXT FROM ms_crs_fg INTO @fgname
			END
			CLOSE ms_crs_fg
			DEALLOCATE ms_crs_fg
		end
		else
		begin
			if exists (SELECT groupname FROM sysfilegroups fg
				WHERE fg.groupid > 1 -- not primary
				AND fg.status & 0x8 = 0 -- not already readonly
				AND (SELECT count (*) FROM sysfiles f WHERE
				f.groupid = fg.groupid) > 0) -- has some files
			begin
				raiserror(15358,-1,-1)
				SELECT groupname FROM sysfilegroups fg
					WHERE fg.groupid > 1 -- not primary
					AND fg.status & 0x8 = 0 -- not already readonly
				return (-1)
			end
		end


	end
return(0)
go


raiserror(15339,-1,-1,'sp_certify_removable')
go
CREATE PROCEDURE sp_certify_removable  --1996/03/12 12:02

        @dbname sysname,
        @autofix nvarchar(4) = null
as

set nocount on

declare @ret_value int,
	@char_autofix varchar(25)

if (not (is_srvrolemember('sysadmin') = 1))  -- Make sure that it is the SA executing this.
        begin
                raiserror(15247,-1,-1)
                return(1)
        end


select @autofix = lower(@autofix)

if @autofix <> 'auto' and @autofix is not null
        begin
                raiserror(15255,-1,-1,@autofix)
                return(1)
        end


if @dbname is null      -- Show usage diagram if no dbname supplied.
        begin
                raiserror(15256,-1,-1)
                return(1)
        end


--See if DB exists.
if not exists (select * from master.dbo.sysdatabases where name = @dbname)
        begin
                raiserror(15010,-1,-1,@dbname)
                return(1)
        end


--Cannot take master, tempdb or model databases offline.
if lower(@dbname) in ('master','tempdb','model')
        begin
                raiserror(15266,-1,-1,@dbname)
                return(1)
        end


-- Will not be able to take db offline if user is in it.
if @dbname = db_name()
        begin
                raiserror(15257,-1,-1)
                return(1)
        end

-------------  Check things that exist only in the db.  -------------------
select @char_autofix =
	CASE
	   When @autofix IS NOT Null Then '''Auto'''
	   Else                           'Null'
	END

execute(
'use ' + @dbname + '

declare @inx_ret_value int ,@int1 int
select  @inx_ret_value = 1

exec @inx_ret_value = sp_check_removable ' + @char_autofix + '

--Use @@rowcount for a user_assignable global variable for communication.
if @inx_ret_value <> 0	--bad!!!!
	begin
	select @int1 = 1
	return
	end
else
	begin
	select @int1 = 1 where 1=2
	return
	end
'
)

if @@rowcount > 0
        return (1)  --Error was returned by other proc, so exit


-- Take it offline
raiserror('' ,0,1)
exec sp_dboption @dbname,'offline','true'

return(0)
go


print ' '
raiserror(15339,-1,-1,'MS_sqlctrs_users')
go
create procedure MS_sqlctrs_users --- 1996/08/30 21:49
as
select
		 lg.loginname + ' - ' + convert(varchar(30),pr.spid)
		,pr.memusage		as 'Memory (8K Pages)' -- 2K in 6.5
		,pr.cpu			as 'CPU time'
		,pr.physical_io
		,count(lk.spid)		as 'Locks held'
		,pr.spid
	from
		 master.dbo.sysprocesses	pr	left outer join
		 master.dbo.syslocks	lk	on pr.spid=lk.spid
		,master.dbo.syslogins	lg
	where
		 pr.sid	= lg.sid
	group by
		 lg.loginname
		,pr.spid
		,pr.memusage
		,pr.cpu
		,pr.physical_io
go

print ' '
raiserror(15339,-1,-1,'sp_autostats')
go
CREATE PROCEDURE sp_autostats
	@tblname 	nvarchar(776),
	@flagc		varchar(10)=null,
	@indname	sysname=null
AS
BEGIN
	DECLARE @flag bit, @nrc_mask int

	/*
	**  Check flag
	*/
	SET @flag = CASE lower(@flagc)
		WHEN 'on' 	THEN 1
		WHEN 'off' 	THEN 0
		ELSE NULL
		END

	IF @flag IS NULL AND @flagc IS NOT NULL
    	BEGIN
		RAISERROR(17000,-1,-1)
        	RETURN (1)
    	END

	/*
	** Set NORECOMPUTE mask
	*/
	SET @nrc_mask = 16777216

	/*
	** Check we are executing in the correct database
	*/
	DECLARE @db sysname
	SELECT @db = parsename(@tblname, 3)

	IF (@db IS NOT NULL AND @db <> db_name())
	BEGIN
		RAISERROR(15387,-1,-1)
		RETURN (1)
	END

	/*
	** PRINT or UPDATE status?
	*/
	IF (@flag IS NULL)
	BEGIN

		-- Display global settings (sp_dboption)
		--
		PRINT 'Global statistics settings for ' + quotename(db_name(), '[') + ':'
		PRINT '  Automatic update statistics: ' + (CASE WHEN DatabaseProperty(db_name(), 'IsAutoUpdateStatistics') = 1 THEN 'ON' ELSE 'OFF' END)
		PRINT '  Automatic create statistics: ' + (CASE WHEN DatabaseProperty(db_name(), 'IsAutoCreateStatistics') = 1 THEN 'ON' ELSE 'OFF' END)
		PRINT ''

		-- Display the current status of the index(s)
		--
		PRINT 'Settings for table ' + quotename(@tblname, '[')
		PRINT ''
		SELECT 'Index Name' = quotename(si.name, '['),
		       'AUTOSTATS' =
			CASE (si.status & @nrc_mask)
				WHEN @nrc_mask THEN 'OFF'
				ELSE 'ON'
			END,
		       'Last Updated' = stats_date(object_id(@tblname), si.indid)
		FROM sysindexes si
		WHERE si.id = object_id(@tblname) AND		-- Table
		      si.indid BETWEEN 1 AND 254 AND		-- Skip HEAP/TEXT index
			CASE 					-- Match name
				WHEN @indname IS NULL THEN 1
				WHEN @indname = si.name THEN 1
				ELSE 0
			END = 1
	END
	ELSE
	BEGIN
		DECLARE @_rowcount int,
				@tabid int,
				@objtype varchar(2)

		-- VERIFY WE HAVE A USER-TABLE/INDEXED-VIEW BY THIS NAME IN THE DATABASE
		SELECT @tabid = id, @objtype = xtype FROM sysobjects
			WHERE id = OBJECT_ID(@tblname, 'local') AND (xtype = 'U' OR xtype = 'V')
		IF (@tabid IS NULL OR
				(@objtype = 'V' AND
				(ObjectProperty(@tabid, 'IsIndexed') = 0 OR
				ObjectProperty(@tabid, 'IsMSShipped') = 1))
			)
		begin
			raiserror(15390,-1,-1,@tblname)
			RETURN @@ERROR
		end

		BEGIN TRANSACTION upd_tran

		-- Lock the table schema and check permissions
		--
		DBCC LOCKOBJECTSCHEMA(@tblname)

		-- Flip the status bits
		--
		DECLARE @batch varchar(8000)

		UPDATE sysindexes
		SET status =
			CASE @flag
			WHEN 1 THEN status &~ @nrc_mask
			ELSE status | @nrc_mask
			END
		WHERE id = object_id(@tblname) AND		-- Table
		      indid <> 255 AND				-- Skip TEXT index
		      CASE 					-- Match name
			WHEN @indname IS NULL THEN 1
			WHEN @indname = name THEN 1
			ELSE 0
		      END = 1

		-- Save the affected rowcount
		SET @_rowcount = @@rowcount

		COMMIT TRANSACTION upd_tran

		-- Show the user how many indices were affected
		PRINT 'Automatic statistics maintenance turned ' +
			CASE @flag WHEN 1 THEN 'ON' ELSE 'OFF' END +
			' for ' + convert(varchar(5), @_rowcount) +
			' indices.'

	END

	-- All done
	--
	RETURN(0) -- sp_autostats
END
GO

raiserror(15339,-1,-1,'sp_updatestats')
go
-- required for sp_updatestats so it can update stats on on ICC/IVs
set ansi_nulls on
go
CREATE PROCEDURE sp_updatestats
@resample CHAR(8)='NO'
AS

	DECLARE @dbsid varbinary(85)

	SELECT  @dbsid = sid
	FROM master.dbo.sysdatabases
    WHERE name = db_name()

	/*Check the user sysadmin*/
	 IF NOT is_srvrolemember('sysadmin') = 1 AND suser_sid() <> @dbsid
		BEGIN
			RAISERROR(15247,-1,-1)
			RETURN (1)
		END

	if UPPER(@resample)<>'RESAMPLE' AND UPPER(@resample)<>'NO'
	begin
   		raiserror(N'Invalid option: %s', 1, 1, @resample)
		return (1)
	end

	-- required so it can update stats on on ICC/IVs
	set ansi_nulls on
	set quoted_identifier on
	set ansi_warnings on
	set ansi_padding on
	set arithabort on
	set concat_null_yields_null on
	set numeric_roundabort off



	DECLARE @exec_stmt nvarchar(540)
	DECLARE @tablename sysname
	DECLARE @uid smallint
	DECLARE @user_name sysname
	DECLARE @tablename_header varchar(267)
	DECLARE ms_crs_tnames CURSOR LOCAL FAST_FORWARD READ_ONLY FOR SELECT name, uid FROM sysobjects WHERE type = 'U'
	OPEN ms_crs_tnames
	FETCH NEXT FROM ms_crs_tnames INTO @tablename, @uid
	WHILE (@@fetch_status <> -1)
	BEGIN
		IF (@@fetch_status <> -2)
		BEGIN
			SELECT @user_name = user_name(@uid)
			SELECT @tablename_header = 'Updating ' + @user_name +'.'+ RTRIM(@tablename)
			PRINT @tablename_header
			SELECT @exec_stmt = 'UPDATE STATISTICS ' + quotename( @user_name , '[')+'.' + quotename( @tablename, '[') 
			if (UPPER(@resample)='RESAMPLE') SET @exec_stmt = @exec_stmt + ' WITH RESAMPLE'
			EXEC (@exec_stmt)
		END
		FETCH NEXT FROM ms_crs_tnames INTO @tablename, @uid
	END
	PRINT ' '
	PRINT ' '
	raiserror(15005,-1,-1)
	DEALLOCATE ms_crs_tnames
	RETURN(0) -- sp_updatestats
go
-- was only required for sp_updatestats
set ansi_nulls off
go

-------------------------------- sp_createstats --------begin---------------------------
raiserror(15339,-1,-1,'sp_createstats')
go
-- required for sp_createstats so it can update stats on on ICC/IVs
set ansi_nulls on
go

CREATE PROCEDURE sp_createstats
@indexonly CHAR(9)= 'NO',     -- Optional 'INDEXONLY' text - if present, then only the columns
				-- covered by indexes are subject of statistics creation
@fullscan  CHAR(9)= 'NO',      -- Optional 'FULLSCAN' text - if present, then the statistics
				-- will be updated with full scan rather than sampling
@norecompute  CHAR(12)= 'NO'      -- Optional 'NORECOMPUTE' text - if present, then statistics
				-- will not be updated automatically
AS
/*
	NOTE: This sp will update statistics for *all* columns of all tables
	which the user has the privilege to update stats on (sysadmin, dbo, owner).
	The following columns are not considered
	- first column of an index
	- column which already has statistics
	- unelligible columns (Text and image columns consisting of ntext, text, or image data type,
	  bit, and computed columns)

*/

declare @sysadmin int
	,@dbname sysname

-- remember dbname

  	SELECT @dbname = db_name()

-- create temporary table (column, index position)
create table #colpostab
(	col_name  sysname collate database_default ,
	col_pos	  int,
)

set nocount on

-- required for sp_createstats so it can update stats on on ICC/IVs
set ansi_nulls on
set quoted_identifier on
set ansi_warnings on
set ansi_padding on
set arithabort on
set concat_null_yields_null on
set numeric_roundabort off

DECLARE @exec_stmt nvarchar(540)
DECLARE @tablename sysname
DECLARE @columnname sysname
--DECLARE @shortcolumnname sysname
DECLARE @indexname sysname
DECLARE @uid smallint
DECLARE @indid smallint
DECLARE @position smallint
DECLARE @table_id  int
DECLARE @user_name sysname
DECLARE @numcols int   -- number of eligible columns found
DECLARE @msg nvarchar(386)
DECLARE @timestamp varchar(17)

DECLARE @tablename_header varchar(267)

DECLARE ms_crs_tnames CURSOR LOCAL STATIC FOR
SELECT name, id, uid FROM sysobjects WHERE type = 'U' and ((object_id('[#colpostab]') is NULL) OR (id <> object_id('[#colpostab]')))

SELECT @numcols = 0

OPEN ms_crs_tnames
FETCH NEXT FROM ms_crs_tnames INTO @tablename, @table_id, @uid
WHILE (@@fetch_status <> -1)
BEGIN
	IF ((@@fetch_status <> -2) AND  (is_member('db_owner')=1) OR (is_member('ddl_admin')=1) OR (is_member(user_name(@uid))=1) OR (user_id() = @uid))
	BEGIN
		-- these are all columns for which the statistics will be updated
		DECLARE ms_crs_cnames CURSOR LOCAL FOR SELECT c.name   FROM syscolumns c, systypes t
			WHERE c.id = @table_id AND c.xtype = t.xusertype AND
				 (t.name NOT IN ('text', 'ntext', 'image', 'timestamp','bit'))
			AND ((c.colstat & 0x0004) <> 0x0004)
			AND (c.length<=900)
			AND c.name NOT IN (SELECT col_name FROM #colpostab WHERE col_pos = 1)
			AND ((c.name IN (SELECT col_name FROM #colpostab)) OR (@indexonly <> 'indexonly'))

		-- populate temporary table of all (column, index position) tuples for this table

		TRUNCATE TABLE #colpostab

		-- for each index on the table, loop though all columns and insert rows
		-- OPEN CURSOR OVER INDEXES
		DECLARE ms_crs_ind CURSOR LOCAL STATIC FOR
			SELECT indid, name FROM sysindexes
				where id = @table_id and indid > 0 and indid < 255 order by indid

		OPEN ms_crs_ind
		FETCH ms_crs_ind into @indid , @indexname

		-- IF AN INDEX EXISTS

		WHILE @@fetch_status >= 0
		BEGIN
			-- Every index has at least one column at position 1
			INSERT INTO #colpostab VALUES (index_col(@tablename,@indid,1),1)
			-- now try position 2 and beyond....
			SELECT @columnname = index_col(@tablename, @indid, 2)
			SELECT @position = 2
			WHILE (@columnname is not null )
				BEGIN
					INSERT INTO #colpostab VALUES (@columnname,@position)
					SELECT @position = @position +1
					SELECT @columnname = index_col(@tablename, @indid, @position)
				END
			-- Next Index
			FETCH ms_crs_ind into @indid , @indexname

		END
		CLOSE ms_crs_ind
		DEALLOCATE ms_crs_ind

		-- now go over all columns which are eligible for updating statistics
		-- and are not first columns of any index
		-- optionaly we test if they are covered by some index (as non-leading)

		SELECT @user_name = user_name(@uid)

		OPEN ms_crs_cnames

		FETCH NEXT FROM ms_crs_cnames INTO @columnname
		IF @@fetch_status < 0
		BEGIN
			select @msg = @dbname +'.'+ @user_name +'.'+ @tablename
			raiserror(15013,-1,-1,@msg)
		END
		ELSE
		BEGIN
			select @msg = @dbname +'.'+ @user_name +'.'+ @tablename
			raiserror(15018, -1, -1, @msg)
		END

		WHILE @@fetch_status >= 0
		BEGIN
		 	 SELECT @numcols = @numcols +1
			 -- use the column name as the name for the statistics as well
			 select @exec_stmt = 'CREATE STATISTICS ' +  quotename(@columnname, '[')  + ' ON ' +
		 quotename( @user_name ,'[')+'.' + quotename( @tablename, '[')+'('+ quotename( @columnname, '[')+')'
			-- determining the correct suffix
			if ((@fullscan = 'FULLSCAN') AND (@norecompute = 'NORECOMPUTE'))
				select @exec_stmt = @exec_stmt + ' WITH FULLSCAN, NORECOMPUTE'
			else if (@fullscan = 'FULLSCAN') select @exec_stmt = @exec_stmt + ' WITH FULLSCAN'
			else if (@norecompute = 'NORECOMPUTE') select @exec_stmt = @exec_stmt + ' WITH NORECOMPUTE'
			EXEC (@exec_stmt)
			--PRINT 'Statement='+@exec_stmt
			if (@@ERROR = 0)  -- otherwise the CREATE STATS will give a message
			     PRINT '     ' + @columnname
			FETCH NEXT FROM ms_crs_cnames INTO @columnname
		END
		CLOSE ms_crs_cnames
		DEALLOCATE ms_crs_cnames
	END
	FETCH NEXT FROM ms_crs_tnames INTO @tablename, @table_id, @uid
END

PRINT ' '
raiserror(15020,-1,-1,@numcols)

DEALLOCATE ms_crs_tnames

IF (object_id('[#colpostab]') is not null)
   begin
            drop table [#colpostab]
   end

return(0) -- sp_createstats
go
-- was only required for sp_createstats
set ansi_nulls off
go

------------------------------- sp_cycle_errorlog -----------------------------------
raiserror(15339,-1,-1,'sp_cycle_errorlog')
go
create procedure sp_cycle_errorlog  --- 1997/06/24
as
if (not (is_srvrolemember('sysadmin') = 1))  -- Make sure that it is the SA executing this.
        begin
                raiserror(15247,-1,-1)
                return(1)
        end

dbcc errorlog
return (0)
go





-------------------------------- sp_helptrigger -----------------------------------

raiserror(15339,-1,-1,'sp_helptrigger')
go
create procedure sp_helptrigger  --- 1997/06/24
    @tabname nvarchar(776),			/*	Table name		*/
	@triggertype char(6) = NULL	/*	Trigger type	*/
as

declare @objid int,        /* id of the object */
		@dbname sysname,
		@deltrig int,
		@instrig int,
		@updtrig int

-- Check to see that the object names are local to the current database.
select @dbname = parsename(@tabname,3)

if @dbname is not null and @dbname <> db_name()
begin
		raiserror(15250,-1,-1)
		return (1)
end

select @objid =  id from sysobjects where id = object_id(@tabname)
	and type in ('S','U', 'V')

if @objid is null
	begin
		select @dbname = db_name()
		raiserror(15009,-1,-1,@tabname,@dbname)
		return(1)
	end

/*	Check that input type is UPDATE, INSERT, DELETE	*/
if @triggertype  is not null and not UPPER(@triggertype ) in ('UPDATE', 'INSERT', 'DELETE')
      begin
         raiserror(15305,-1,-1)
         return(1)
      end

if @triggertype  is NULL
	select
	trigger_name = name,
	trigger_owner = user_name(uid),
	isupdate = ObjectProperty( id, 'ExecIsUpdateTrigger'),
	isdelete = ObjectProperty( id, 'ExecIsDeleteTrigger'),
	isinsert = ObjectProperty( id, 'ExecIsInsertTrigger'),
	isafter = ObjectProperty( id, 'ExecIsAfterTrigger'),
	isinsteadof = ObjectProperty( id, 'ExecIsInsteadOfTrigger')
	from sysobjects
	where parent_obj = @objid and type = 'TR'
else
begin
	set @deltrig = case
		when  upper(@triggertype ) = 'DELETE' then 0
		else -1 end
	set @instrig = case
		when  upper(@triggertype ) = 'INSERT' then 0
		else  -1 end
	set @updtrig = case
		when  upper(@triggertype ) = 'UPDATE' then 0
		else -1 end
	select
	trigger_name = name,
	trigger_owner = user_name(uid),
	isupdate = ObjectProperty( id, 'ExecIsUpdateTrigger'),
	isdelete = ObjectProperty( id, 'ExecIsDeleteTrigger'),
	isinsert = ObjectProperty( id, 'ExecIsInsertTrigger'),
	isafter = ObjectProperty( id, 'ExecIsAfterTrigger'),
	isinsteadof = ObjectProperty( id, 'ExecIsInsteadOfTrigger')
	from sysobjects
	where parent_obj = @objid and
	ObjectProperty( id, 'ExecIsDeleteTrigger') > @deltrig and
	ObjectProperty( id, 'ExecIsInsertTrigger') > @instrig and
	ObjectProperty( id, 'ExecIsUpdateTrigger') > @updtrig and
	type = 'TR'
end
return(0)  --sp_helptrigger
go

raiserror(15339,-1,-1,'sp_fixindex')
go
create procedure sp_fixindex
		@dbname		sysname,
		@tabname	sysname,  				/* system table name */
		@indid		int						/* index id value    */
as

	declare @indexname sysname
	/*
	**	Description:	allow the SA to force a drop and then a
	**			create index on system catalogs.
	**
	**	Usage:		sp_fixindex  database, systemcatalog, ind_id
	**
	**	Note:		before using this procedure the database has to
	**			be in single user mode. The sp_dboption has to
	**			be used for user databases, and update of
	**			sysdatabases for master.
	**
	*/

	/* Check that current db is db for processing*/
	if db_name() <> @dbname
		begin
			raiserror(15555,-1,-1, @dbname)
			return(1)
		end

	/*
	**	Make sure we are 'fixing' a system catalog.
	*/
	if not exists (select name from sysobjects where name = @tabname and type = 'S')
		begin
			raiserror(15193,-1,-1)
			return (1)
		end


	/* Check database is in single user mode */
	if ((select status from master..sysdatabases where name = @dbname) &
	   (select number from master..spt_values where name = 'single user' and  type = 'D') = 0) and
	   (select value from master..syscurconfigs where config = 102) <> 1
		begin
			raiserror(15308,-1,-1, @dbname)
			return(1)
		end

	/*
	**	Make sure that we are doing this on somenthing that
	**	has indexes (or real tables).
	*/
	if exists (select id from sysindexes where id = object_id(@tabname) and status & 8 <> 0)
		begin
			raiserror(15194,-1,-1)
			return (1)
		end

	/* Get the index name	*/
	select @indexname = name from sysindexes where id = object_id(@tabname) and  indid = @indid

	if @indexname is null
		begin
			raiserror(15323,-1,-1, @tabname)
			return (1)
		end

    if (object_id(@tabname) <= 100)
        begin
            dbcc dbrepair(@dbname, repairindex, @tabname, @indid)
        end
    else
        begin
	        dbcc dbreindex(@tabname, @indexname)
        end

	return (0)
go

------------------------------- sp_settriggerorder ---------------------------------

if object_id('sp_settriggerorder','P') IS NOT NULL
	drop procedure sp_settriggerorder
go
raiserror(15339,-1,-1,'sp_settriggerorder')
go
create procedure sp_settriggerorder
	@triggername	nvarchar(517),	-- name of the trigger (may be 2-part)
	@order			varchar(10),	-- first, last, or none
	@stmttype		varchar(10)		-- insert, update, or delete
as
	set nocount on
	declare @firstbit		int		-- bit for first-trigger of given @stmttype
			,@lastbit		int		-- bit for last-trigger of given @stmttype
			,@setbit		int		-- status bit to set (0 for clear) based on @stmttype/@order
			,@trigid		int		-- objid of the trigger
			,@tableid		int		-- objid of the trigger's table
			,@uid			smallint --user id
			,@tabname		nvarchar(517)	-- name of the trigger's table

	-- VALIDATE PARAMETERS and obtain bits affected --
	SELECT @order = rtrim(@order), @stmttype = rtrim(@stmttype)
	SELECT @firstbit = case lower(@stmttype)
				when 'delete' then 16384
				when 'update' then 65536
				when 'insert' then 262144
				else NULL end
	SELECT @lastbit = @firstbit * 2		-- NOTE DEPENDENCY ON BIT LAYOUT HERE!
	SELECT @setbit = case lower(@order)
				when 'none' then 0
				when 'first' then @firstbit
				when 'last' then @lastbit
				else NULL end
	IF @setbit is NULL OR @firstbit IS NULL
	begin
		raiserror(15600,-1,-1, 'sp_settriggerorder')
		return (1)
	end

	-- BEGIN TRAN AND LOCK SCHEMA (also checks permissions) --
	BEGIN TRAN
	DBCC LOCKOBJECTSCHEMA(@triggername)
	if @@error <> 0
		goto abort_exit

	-- VERIFY PROPER OBJECT TYPE --
	select @trigid = object_id(@triggername, 'local')
	select @tableid = parent_obj, @uid = uid from sysobjects where id = @trigid AND xtype='TR'
		and ObjectProperty(@trigid,'ExecIsInsteadofTrigger')=0
		and ObjectProperty(@trigid,'ExecIs'+@stmttype+'Trigger')=1
	if (@tableid is NULL)
	begin
		if ObjectProperty(@trigid,'ExecIs'+@stmttype+'Trigger')=0
			raiserror(15125,-1,-1, @triggername, @stmttype)
		else if ObjectProperty(@trigid,'ExecIsInsteadofTrigger')=1
			raiserror(15133, -1, -1, @triggername)
		else
			raiserror(15126,-1,-1,@triggername)
		goto abort_exit
	end

	-- LOCK THE TABLE SCHEMA TOO --
	select @tabname = quotename(user_name(@uid))+'.'+quotename(object_name(@tableid))
	DBCC LOCKOBJECTSCHEMA(@tabname)
	if @@error <> 0
		goto abort_exit

	-- VERIFY FIRST/LAST OF GIVEN TYPE DOESN'T ALREADY EXIST --
	IF EXISTS (select * from sysobjects where parent_obj = @tableid AND xtype='TR' AND id <> @trigid
			 AND ObjectProperty(id, 'ExecIs'+@order+@stmttype+'Trigger') = 1)
	BEGIN
		raiserror(15130,-1,-1,@tabname, @order, @stmttype)
		goto abort_exit
	END

	-- SET THE ORDER AS REQUESTED, COMMIT & RETURN SUCCESS --
	update sysobjects set status = ((status&~(@firstbit|@lastbit))|@setbit) where id = @trigid
	commit transaction
	return(0)

	-- ROLLBACK TRAN & EXIT-FAIL --
abort_exit:
	rollback transaction
	return(1)
go

grant execute on sp_settriggerorder to public
go


/**********************EXTENDED PROPERTY SPS**********************************/
raiserror(15339,-1,-1,'system_function_schema.fn_listextendedproperty')
go
create function system_function_schema.fn_listextendedproperty
	(@name sysname				= NULL,
	@level0type	varchar(128)	= NULL,
	@level0name	sysname			= NULL,
	@level1type	varchar(128)	= NULL,
	@level1name	sysname			= NULL,
	@level2type	varchar(128)	= NULL,
	@level2name	sysname			= NULL
)

returns @tab table(objtype varchar(128) null,
		objname sysname null,
		name sysname not null,
		value sql_variant null)
as
begin

declare @objtype varchar(2),
		@colnum smallint


select	@level0type	= UPPER(@level0type)
		,@level1type	= UPPER(@level1type)
		,@level2type	= UPPER(@level2type)

if @level0type is null and @level0name is null
begin
	if	@level1type is null and @level1name is null and
		@level2type is null and @level2name is null
	begin
		insert @tab
		select NULL,NULL, name, value
		from sysproperties
		where	type = 0 and is_member('db_owner') = 1 and
			(@name is null or @name = name)
	end

	return
end

if	@level1type is null and @level1name is null and
	@level2type is null and @level2name is null
begin
	if @level0type = 'TYPE'
	begin
		insert @tab
		select @level0type, t.name, p.name, p.value
		from sysproperties p, systypes t
		where	p.type = 1 and p.id = 0 and p.smallid = xusertype and
			(@level0name is null or t.name = @level0name) and
			(@name is null or @name = p.name)
	end
	else if @level0type = 'USER'
	begin
		insert @tab
		select @level0type, u.name, p.name, p.value
		from sysusers u, sysproperties p
		where p.type = 2 and p.id = 0 and p.smallid = uid and
			(is_member('db_owner') = 1 or is_member(u.name) = 1) and
			(@level0name is null or u.name = @level0name) and
			(@name is null or @name = p.name)
	end
	return
end
if @level0type is null or @level0name is null or @level0type <> 'USER'
	return

if @level2type is null and @level2name is null
begin
	if @level1type in ('TABLE', 'VIEW', 'PROCEDURE', 'RULE', 'DEFAULT')
	begin
		select @objtype = case @level1type
					when 'TABLE' then 'U'
					when 'VIEW' then 'V'
					when 'PROCEDURE' then 'P'
					when 'RULE' then 'R'
					when 'DEFAULT' then 'D'
					end

		insert @tab
		select @level1type, o.name, p.name, p.value
		from sysobjects o, sysproperties p
		where	p.type = 3 and p.smallid = 0 and o.id = p.id and
				(permissions(o.id) > 0 or @objtype in ('R', 'D')) and
				o.uid = user_id(@level0name) and
				o.xtype = @objtype and o.parent_obj = 0 and
				(@level1name is null or o.name = @level1name) and
				(@name is null or @name = p.name)

	end
	else if (@level1type = 'FUNCTION')
	begin
			insert @tab
			select @level1type, o.name, p.name, p.value
			from sysobjects o, sysproperties p
			where	p.type = 3 and p.smallid = 0 and o.id = p.id and
					permissions(o.id) > 0 and
					o.uid = user_id(@level0name) and
					o.xtype in ('TF','FN','IF') and
					(@level1name is null or o.name = @level1name) and
					(@name is null or @name = p.name)
	end

	return
end
if @level1type is null or @level1name is null
	return

if @level2type = 'COLUMN'
begin
	if @level1type not in ('TABLE', 'VIEW', 'FUNCTION')
		return

	insert @tab
	select @level2type, c.name, p.name, p.value
	from syscolumns c, sysproperties p, sysobjects o
	where	p.type = 4 and p.smallid = c.colid and
			c.id = object_id(quotename(@level0name)+'.'+quotename(@level1name)) and
			c.id = p.id and permissions(c.id,c.name) > 0 and c.number = 0 and
			(@level2name is null or c.name = @level2name) and
			(@name is null or @name = p.name) and
			c.id = o.id and o.xtype in ('U','V','TF','IF')

end
else if @level2type ='TRIGGER'
begin
	if @level1type not in ('TABLE', 'VIEW')
		return

	insert @tab
	select @level2type, o.name, p.name, p.value
		from sysobjects o, sysproperties p
		where	p.type = 3 and p.smallid = 0 and p.id = o.id and
			o.parent_obj = object_id(quotename(@level0name)+'.'+quotename(@level1name)) and
			permissions(o.parent_obj) > 0 and
			o.xtype = 'TR' and
			(@level2name is null or o.name = @level2name) and
			(@name is null or @name = p.name)

end
else if @level2type = 'CONSTRAINT'
begin
	if @level1type not in ('TABLE', 'FUNCTION')
		return

	insert @tab
	select @level2type, o.name, p.name, p.value
		from sysobjects o, sysproperties p
		where	p.type = 3 and p.smallid = 0 and p.id = o.id and
			o.parent_obj = object_id(quotename(@level0name)+'.'+quotename(@level1name)) and
			permissions(o.parent_obj) > 0 and
			o.xtype in ('C','D','F','PK','UQ') and
			(@level2name is null or o.name = @level2name) and
			(@name is null or @name = p.name)

end
else if @level2type = 'INDEX'
begin
	if @level1type not in ('TABLE', 'VIEW')
		return

	insert @tab
	select @level2type, i.name, p.name, p.value
		from sysindexes i, sysproperties p
		where	p.type = 6 and permissions(i.id) > 0 and
			p.id = object_id(quotename(@level0name)+'.'+quotename(@level1name)) and
			p.smallid = i.indid and i.id = p.id and
			(@level2name is null or i.name = @level2name) and
			(@name is null or @name = p.name) and
			i.indid not in (0,255) and i.status&0x1800 = 0	-- no PK/UQ constraint
end
else if @level2type = 'PARAMETER'
begin
	if @level1type not in ('PROCEDURE', 'FUNCTION')
		return

	select @objtype = xtype from sysobjects where id = object_id(quotename(@level0name)+'.'+quotename(@level1name))
	select @colnum = case  @objtype when 'FN' then 0 else 1 end

	insert @tab
	select @level2type, c.name, p.name, p.value
	from syscolumns c, sysproperties p
	where	p.type = 5 and p.smallid = c.colid and
			c.id = object_id(quotename(@level0name)+'.'+quotename(@level1name)) and
			c.id = p.id and permissions(c.id) > 0 and c.number = @colnum and
			(@level2name is null or c.name = @level2name) and
			(@name is null or @name = p.name) and
			@objtype in ('P', 'TF','FN','IF')
end

return
end
go

raiserror(15339,-1,-1,'sp_validatepropertyinputs')
go
create procedure sp_validatepropertyinputs
	@name			sysname
	,@level0type		varchar(128)
	,@level0name		sysname
	,@level1type		varchar(128)
	,@level1name		sysname
	,@level2type		varchar(128)
	,@level2name		sysname
	,@id				int				OUTPUT
	,@smallid			smallint		OUTPUT
	,@type				tinyint			OUTPUT
	,@exists			int				OUTPUT
	,@fullname			nvarchar(400)	OUTPUT
	,@objname			nvarchar(517)	OUTPUT		-- level 1 object name

as
-----------------------------------------------------
-- NOTE: FOR INTERNAL USE ONLY (sp_addextendedproperty,sp_updateextendedproperty,sp_dropextendedproperty)
--      DO NOT DOCUMENT OR USE!
-----------------------------------------------------

	declare @ret int

	select @id = 0, @smallid = 0	--Initialize 0 is used instead of null

	Select	@level0type		= UPPER(@level0type)
			,@level1type	= UPPER(@level1type)
			,@level2type	= UPPER(@level2type)

	declare @invalidlevel varchar(25)
			,@objtype varchar(2)
			,@uid int
			,@objid int
			,@lev2objexists tinyint

	if @name is null
		return (2)	--return to calling proc which will raiserror

	execute @ret = sp_validname @name
	if (@ret <> 0)
        return (1)


	if (@level2type is not null and
		(@level1type is null or @level0type is null)) or
		(@level1type is not null and @level0type is null)
			return (2)	--return to called proc which will raiserror

	select @fullname =
		case
			when (@level2name is not null) then
				@level0name + '.' + @level1name + '.' + @level2name
 			when (@level1name is not null) then
				@level0name + '.' + @level1name
			when (@level0name is not null) then
				@level0name
		end
	select @fullname = isnull(@fullname,'object specified')

	if @level0type is null and @level0name is null
	begin

		--must be dbo 
		if is_member('db_owner') = 0
		begin
			raiserror(15247,-1,-1)
			return (1)
		end

		--Database Property
		select	@type = 0 --Indicates database entry

	end
	else if @level0type = 'TYPE' and @level0name is not null
	begin

		select	@smallid = xusertype,@type = 1
		from	systypes
		where	name = @level0name and xusertype > 256 --only udtypes

	end
	else if @level0type = 'USER' and @level0name is not null
	begin

		select	@type = 2, @smallid = uid
		from	sysusers
		where	name = @level0name and
				(issqluser = 1 or isntname = 1 or @level1type is not null) and --no alias/should only be users (any owner ok for objects)
				uid NOT IN (3,4) --no INFORMATION_SCHEMA, system_function_schema

	end
	else
		return (2)	--return to called proc which will raiserror


	--Check is user/type does not exits then @type will be null
	if @type is null or
	(@level1type is null and @smallid in (1,2)) --Not permitted to add prop to dbo/guest
	begin
		raiserror(15135,-1,-1,@fullname)
		return (1)
	end

	if @level1type in ('TABLE', 'VIEW', 'PROCEDURE', 'RULE', 'DEFAULT', 'FUNCTION')
			and @level1name is not null
	begin

		if not (@level0type = 'USER')
			return (2)	--return to called proc which will raiserror

		--Not for temp tables
		if substring(@level1name,1,1) = N'#'
		begin
			raiserror(15135,-1,-1,@fullname)
			return (1)
		end

		select @uid = @smallid
		select @smallid = 0

		if (@level1type = 'FUNCTION')
		begin
			select	@id = id,@type = 3, @objtype = xtype
			from	sysobjects
			where	name = @level1name and uid = @uid and
					xtype in ('FN','TF','IF') and parent_obj = 0
		end
		else
		begin
		--Can only be for objects and not default/rule constraints
			select @objtype = case @level1type
						when 'TABLE' then 'U'
						when 'VIEW' then 'V'
						when 'PROCEDURE' then 'P'
						when 'RULE' then 'R'
						when 'DEFAULT' then 'D'
					end

			select	@id = id,@type = 3
			from	sysobjects
			where	name = @level1name and uid = @uid and
					xtype = @objtype and parent_obj = 0
		end
		--if object not found than @id will = 0
		if @id = 0
		begin
			raiserror(15135,-1,-1, @fullname)
			return (1)
		end

		select @objname = QUOTENAME(@level0name) + '.' + QUOTENAME(@level1name)

	end
	else if not (@level1type is null and @level1name is null)
		return (2)	--return to called proc which will raiserror

	--Check Permissions
	if @id <> 0 and
		is_member('db_owner') = 0 and is_member(@level0name) = 0
		and is_member('db_ddladmin') = 0
	begin
		raiserror(15247,-1,-1)
		return (1)
	end
	else if @smallid <> 0 and is_member('db_owner') = 0 and
		(@level0type = 'USER') OR
		-- For type: may also be db_ddladmin or an owner
		(@level0type = 'TYPE' and is_member('db_ddladmin')=0 and
			is_member(user_name((select uid from systypes where xusertype=@smallid)))=0)
	begin
		raiserror(15247,-1,-1)
		return (1)
	end

	if @level2type = 'COLUMN'  and @level2name is not null
	begin

		if @level1type not in ('TABLE','VIEW','FUNCTION')
			return (2)	--return to called proc which will raiserror

		select	@smallid = colid, @type = 4,@lev2objexists = 1
		from	syscolumns
		where	id = @id and name = @level2name and
				number = 0	--specified columns entry

	end
	else if @level2type = 'PARAMETER' and @level2name is not null
	begin

		if @level1type not in ('PROCEDURE','FUNCTION')
			return (2)	--return to called proc which will raiserror

		--scalar function params have number as 0 for params
		if @objtype = 'FN'
			select	@smallid = colid, @type = 5,@lev2objexists = 1
			from	syscolumns
			where	id = @id and name = @level2name and
					number = 0	--specified parameter entry

		else
			select	@smallid = colid, @type = 5,@lev2objexists = 1
			from	syscolumns
			where	id = @id and name = @level2name and
					number = 1	--specified parameter entry

	end
	else if @level2type ='TRIGGER' and @level2name is not null
	begin

		if @level1type not in ('TABLE','VIEW')
			return (2)	--return to called proc which will raiserror

		select @objid = @id
		select @id = 0

		select	@id = id, @type = 3, @lev2objexists = 1
		from	sysobjects
		where	name = @level2name and parent_obj = @objid and
				xtype = N'TR'

	end
	else if @level2type = 'CONSTRAINT' and @level2name is not null
	begin

		if not @level1type in ('TABLE','FUNCTION')
			return (2)	--return to called proc which will raiserror

		select @objid = @id
		select @id = 0

		select	@id = id, @type = 3, @lev2objexists = 1
		from	sysobjects
		where	name = @level2name and parent_obj = @objid and
				xtype in ('C','D','F', 'PK', 'UQ')

	end
	else if @level2type = 'INDEX' and @level2name is not null
	begin

		if not @level1type in ('TABLE', 'VIEW')
			return (2)	--return to called proc which will raiserror

		select	@smallid = indid, @type = 6, @lev2objexists = 1
		from	sysindexes
		where	name = @level2name and id = @id and
				indid not in (0,255) and status&0x1800 = 0 --no PK/U constraints

	end
	else if not (@level2type is null and @level2name is null)
			return (2)	--return to called proc which will raiserror

	--Does the level2 obj exists
	if @lev2objexists is null and @level2type is not null
	begin
		raiserror(15135,-1,-1, @fullname)
		return (1)
	end

	--Check if property exists
	select @exists = (select count(*) from sysproperties
					where	@type = type and
						@id =	id	and
						@smallid =	smallid	and
						@name = name)

	return (0)
go

raiserror(15339,-1,-1,'sp_addextendedproperty')
go
create procedure sp_addextendedproperty
	@name sysname,
	@value sql_variant			= NULL,
	@level0type	varchar(128)	= NULL,
	@level0name	sysname			= NULL,
	@level1type	varchar(128)	= NULL,
	@level1name	sysname			= NULL,
	@level2type	varchar(128)	= NULL,
	@level2name	sysname			= NULL
as

	declare @id int
		,@smallid smallint
		,@type tinyint
		,@ret int
		,@exists int
		,@fullname nvarchar(400)
		,@objname nvarchar(517)

		if datalength(@value) > 7500
		begin
			raiserror(15097,-1,-1)
			return 1
		end

		execute @ret = sp_validatepropertyinputs
						@name
						,@level0type
						,@level0name
						,@level1type
						,@level1name
						,@level2type
						,@level2name
						,@id			OUTPUT
						,@smallid		OUTPUT
						,@type			OUTPUT
						,@exists		OUTPUT
						,@fullname		OUTPUT
						,@objname		OUTPUT

	if @ret = 2
		raiserror(15600,-1,-1,'sp_addextendedproperty')
	if @ret <> 0
		return (1)

	if ( @exists = 1 ) --Indicates property for object does exist
	begin
		raiserror(15233,-1,-1,@name, @fullname)
		return(1)
	end

	BEGIN TRANSACTION

		if @objname is not null
			DBCC LockObjectSchema(@objname)

		insert into sysproperties (type, id, smallid, name, value)
		values (@type, @id, @smallid, @name, @value)

	COMMIT TRANSACTION

	return(0)
go


raiserror(15339,-1,-1,'sp_updateextendedproperty')
go
create procedure sp_updateextendedproperty
	@name sysname,
	@value sql_variant			= NULL,
	@level0type	varchar(128)	= NULL,
	@level0name	sysname			= NULL,
	@level1type	varchar(128)	= NULL,
	@level1name	sysname			= NULL,
	@level2type	varchar(128)	= NULL,
	@level2name	sysname			= NULL
as

	declare @id int
		,@smallid smallint
		,@type tinyint
		,@ret int
		,@exists int
		,@fullname nvarchar(400)
		,@objname		nvarchar(517)

	if datalength(@value) > 7500
	begin
		raiserror(15097,-1,-1)
		return 1
	end

	execute @ret = sp_validatepropertyinputs
						@name
						,@level0type
						,@level0name
						,@level1type
						,@level1name
						,@level2type
						,@level2name
						,@id			OUTPUT
						,@smallid		OUTPUT
						,@type			OUTPUT
						,@exists		OUTPUT
						,@fullname		OUTPUT
						,@objname		OUTPUT

	if @ret = 2
		raiserror(15600,-1,-1,'sp_updateextendedproperty')
	if @ret <> 0
		return (1)

	if ( @exists = 0 ) --Indicates property for object does not exist
	begin
		raiserror(15217,-1,-1,@name,@fullname)
		return(1)
	end

	BEGIN TRANSACTION

		if @objname is not null
			DBCC LockObjectSchema(@objname)

		update sysproperties set value = @value
		where		@type = type and
					@id =	id	and
					@smallid =	smallid	and
					@name = name

	COMMIT TRANSACTION

	return(0)
go


raiserror(15339,-1,-1,'sp_dropextendedproperty')
go
create procedure sp_dropextendedproperty
	@name sysname,
	@level0type	varchar(128)	= NULL,
	@level0name	sysname			= NULL,
	@level1type	varchar(128)	= NULL,
	@level1name	sysname			= NULL,
	@level2type	varchar(128)	= NULL,
	@level2name	sysname			= NULL
as

	declare @id int
		,@smallid smallint
		,@type int
		,@ret int
		,@exists int
		,@fullname nvarchar(400)
		,@objname		nvarchar(517)

	execute @ret = sp_validatepropertyinputs
						@name
						,@level0type
						,@level0name
						,@level1type
						,@level1name
						,@level2type
						,@level2name
						,@id			OUTPUT
						,@smallid		OUTPUT
						,@type			OUTPUT
						,@exists		OUTPUT
						,@fullname		OUTPUT
						,@objname		OUTPUT

	if @ret = 2
		raiserror(15600,-1,-1,'sp_dropextendedproperty')
	if @ret <> 0
		return (1)

	if (@exists = 0) --Indicates property for object does not exist
	begin
		raiserror(15217,-1,-1,@name,@fullname)
		return (1)
	end

	BEGIN TRANSACTION

		if @objname is not null
			DBCC LockObjectSchema(@objname)

  		delete from sysproperties
		where	@type = type and
				@id =	id	and
				@smallid =	smallid	and
				@name = name

	COMMIT TRANSACTION

	return(0)
go


/******************************************************************************
*************************  LOGIN-SECURITY (LOCAL)  ****************************
******************************************************************************/
checkpoint
go
if object_id('sp_addlogin','P') IS NOT NULL
	drop procedure sp_addlogin
if object_id('sp_password','P') IS NOT NULL
	drop procedure sp_password
if object_id('sp_droplogin','P') IS NOT NULL
	drop procedure sp_droplogin
if object_id('sp_MSaddlogin_implicit_ntlogin','P') IS NOT NULL
	drop procedure sp_MSaddlogin_implicit_ntlogin
if object_id('sp_grantlogin','P') IS NOT NULL
	drop procedure sp_grantlogin
if object_id('xp_grantlogin','P') IS NOT NULL
	drop procedure xp_grantlogin
if object_id('sp_validatelogins','P') IS NOT NULL
	drop procedure sp_validatelogins
if object_id('sp_denylogin','P') IS NOT NULL
	drop procedure sp_denylogin
if object_id('sp_revokelogin','P') IS NOT NULL
	drop procedure sp_revokelogin
if object_id('xp_revokelogin','P') IS NOT NULL
	drop procedure xp_revokelogin
if object_id('sp_defaultdb','P') IS NOT NULL
	drop procedure sp_defaultdb
if object_id('sp_defaultlanguage','P') IS NOT NULL
	drop procedure sp_defaultlanguage
if object_id('sp_addsrvrolemember','P') IS NOT NULL
	drop procedure sp_addsrvrolemember
if object_id('sp_dropsrvrolemember','P') IS NOT NULL
	drop procedure sp_dropsrvrolemember
go

------------------------------- sp_addlogin -----------------------------------

raiserror(15339,-1,-1,'sp_addlogin')
go
create procedure sp_addlogin
    @loginame		sysname
   ,@passwd         sysname = Null
   ,@defdb          sysname = 'master'      -- UNDONE: DEFAULT CONFIGURABLE???
   ,@deflanguage    sysname = Null
   ,@sid			varbinary(16) = Null
   ,@encryptopt		varchar(20) = Null
AS
    -- SETUP RUNTIME OPTIONS / DECLARE VARIABLES --
	set nocount on
	Declare @ret    int    -- return value of sp call

    -- CHECK PERMISSIONS --
	IF (not is_srvrolemember('securityadmin') = 1)
	begin
	   dbcc auditevent (104, 1, 0, @loginame, NULL, NULL, @sid)
	   raiserror(15247,-1,-1)
	   return (1)
	end
	ELSE
	begin
	   dbcc auditevent (104, 1, 1, @loginame, NULL, NULL, @sid)
	end

    -- DISALLOW USER TRANSACTION --
	set implicit_transactions off
	IF (@@trancount > 0)
	begin
		raiserror(15002,-1,-1,'sp_addlogin')
		return (1)
	end

    -- VALIDATE LOGIN NAME AS:
    --  (1) Valid SQL Name (SQL LOGIN)
    --  (2) No backslash (NT users only)
    --  (3) Not a reserved login name
	execute @ret = sp_validname @loginame
	if (@ret <> 0)
        return (1)
    if (charindex('\', @loginame) > 0)
    begin
        raiserror(15006,-1,-1,@loginame)
        return (1)
    end

	--Note: different case sa is allowed.
	if (@loginame = 'sa' or lower(@loginame) in ('public'))
	begin
		raiserror(15405, -1 ,-1, @loginame)
		return (1)
	end

    -- LOGIN NAME MUST NOT ALREADY EXIST --
	if exists(select * from master.dbo.syslogins where loginname = @loginame)
	begin
		raiserror(15025,-1,-1,@loginame)
		return (1)
	end

	-- VALIDATE DEFAULT DATABASE --
	IF db_id(@defdb) IS NULL
	begin
		raiserror(15010,-1,-1,@defdb)
	    return (1)
	end

	-- VALIDATE DEFAULT LANGUAGE --
	IF (@deflanguage IS NOT Null)
	begin
		Execute @ret = sp_validlang @deflanguage
		IF (@ret <> 0)
			return (1)
	end
	ELSE
	begin
		select @deflanguage = name from master.dbo.syslanguages
		where langid = @@default_langid	--server default language

		if @deflanguage is null
			select @deflanguage = N'us_english'
	end

	-- VALIDATE SID IF GIVEN --
	if ((@sid IS NOT Null) and (datalength(@sid) <> 16))
	begin
		raiserror(15419,-1,-1)
	 	return (1)
	end
	else if @sid is null
		select @sid = newid()
	if (suser_sname(@sid) IS NOT Null)
	begin
		raiserror(15433,-1,-1)
	 	return (1)
	end

	-- VALIDATE AND USE ENCRYPTION OPTION --
	declare @xstatus smallint
	select @xstatus = 2	-- access
	if @encryptopt is null
		select @passwd = pwdencrypt(@passwd)
	else if @encryptopt = 'skip_encryption_old'
	begin
		select @xstatus = @xstatus | 0x800,	-- old-style encryption
			@passwd = convert(sysname, convert(varbinary(30), convert(varchar(30), @passwd)))
	end
	else if @encryptopt <> 'skip_encryption'
	begin
		raiserror(15600,-1,-1,'sp_addlogin')
		return 1
	end

    -- ATTEMPT THE INSERT OF THE NEW LOGIN --
	INSERT INTO master.dbo.sysxlogins VALUES
        (NULL, @sid, @xstatus, getdate(),
            getdate(), @loginame, convert(varbinary(256), @passwd),
            db_id(@defdb), @deflanguage)
	if @@error <> 0		-- this indicates we saw duplicate row
        return (1)

	-- UPDATE PROTECTION TIMESTAMP FOR MASTER DB, TO INDICATE SYSLOGINS CHANGE --
	exec('use master grant all to null')

    -- FINALIZATION: RETURN SUCCESS/FAILURE --
	raiserror(15298,-1,-1)
	return  (0)	-- sp_addlogin
go

------------------------------- sp_password -----------------------------------

raiserror(15339,-1,-1,'sp_password')
go
create procedure sp_password
    @old sysname = NULL,        -- the old (current) password
    @new sysname,               -- the new password
    @loginame sysname = NULL    -- user to change password on
as
    -- SETUP RUNTIME OPTIONS / DECLARE VARIABLES --
	set nocount on
    declare @self int
    select @self = CASE WHEN @loginame is null THEN 1 ELSE 2 END

    -- RESOLVE LOGIN NAME
    if @loginame is null
        select @loginame = suser_sname()

    -- CHECK PERMISSIONS (SecurityAdmin per Richard Waymire) --
	IF (not is_srvrolemember('securityadmin') = 1)
        AND not @self = 1
	begin
	   dbcc auditevent (107, @self, 0, @loginame, NULL, NULL, NULL)
	   raiserror(15210,-1,-1)
	   return (1)
	end
	ELSE
	begin
	   dbcc auditevent (107, @self, 1, @loginame, NULL, NULL, NULL)
	end

    -- DISALLOW USER TRANSACTION --
	set implicit_transactions off
	IF (@@trancount > 0)
	begin
		raiserror(15002,-1,-1,'sp_password')
		return (1)
	end

    -- RESOLVE LOGIN NAME (disallows nt names)
    if not exists (select * from master.dbo.syslogins where
                    loginname = @loginame and isntname = 0)
	begin
		raiserror(15007,-1,-1,@loginame)
		return (1)
	end

	-- IF non-SYSADMIN ATTEMPTING CHANGE TO SYSADMIN, REQUIRE PASSWORD (218078) --
	if (@self <> 1 AND is_srvrolemember('sysadmin') = 0 AND exists
			(SELECT * FROM master.dbo.syslogins WHERE loginname = @loginame and isntname = 0
				AND sysadmin = 1) )
		SELECT @self = 1

    -- CHECK OLD PASSWORD IF NEEDED --
    if (@self = 1 or @old is not null)
        if not exists (select * from master.dbo.sysxlogins
                        where srvid IS NULL and
						      name = @loginame and
			                  ( (@old is null and password is null) or
                              (pwdcompare(@old, password, (CASE WHEN xstatus&2048 = 2048 THEN 1 ELSE 0 END)) = 1) )   )
        begin
		    raiserror(15211,-1,-1)
		    return (1)
	    end

    -- CHANGE THE PASSWORD --
    update master.dbo.sysxlogins
	set password = convert(varbinary(256), pwdencrypt(@new)), xdate2 = getdate(), xstatus = xstatus & (~2048)
	where name = @loginame and srvid IS NULL

	-- UPDATE PROTECTION TIMESTAMP FOR MASTER DB, TO INDICATE SYSLOGINS CHANGE --
	exec('use master grant all to null')

    -- FINALIZATION: RETURN SUCCESS/FAILURE --
	if @@error <> 0
        return (1)
    raiserror(15478,-1,-1)
	return  (0)	-- sp_password
go

checkpoint
go
------------------------------- sp_droplogin ----------------------------------

raiserror(15339,-1,-1,'sp_droplogin')
go
create procedure sp_droplogin
	@loginame sysname
as

declare @exec_stmt nvarchar(890)

    -- SETUP RUNTIME OPTIONS / DECLARE VARIABLES --
	set nocount on
	declare	@sid	varbinary(85)

	/*Create temp tables before any DML to ensure dynamic*/
    -- CREATE TEMPORARY TABLES FOR LATER USE --
   	create table #db_list (dbname sysname collate database_default not null, user_name sysname collate database_default not null)
	create table #retval (job_count int not null)

    -- CHECK PERMISSIONS --
	IF (not is_srvrolemember('securityadmin') = 1)
	begin
	   dbcc auditevent (104, 2, 0, @loginame, NULL, NULL, NULL)
	   raiserror(15247,-1,-1)
	   return (1)
	end
	ELSE
	begin
	   dbcc auditevent (104, 2, 1, @loginame, NULL, NULL, NULL)
	end

    -- DISALLOW USER TRANSACTION --
	set implicit_transactions off
	IF (@@trancount > 0)
	begin
		raiserror(15002,-1,-1,'sp_droplogin')
		return (1)
	end

    -- VALIDATE LOGIN NAME (SQL LOGIN) --
	select @sid = sid from master.dbo.syslogins
        where loginname = @loginame and isntname = 0
	if (@sid is null)
	begin
		raiserror(15007,10,-1,@loginame)
		return(1)
	end
    -- CANNOT CHANGE SA ROLES --
	else if @sid = 0x1	-- 'sa'
    begin
        raiserror(15405, -1 ,-1, @loginame)
        return (1)
    end

	-- CHECK IF @sid IS CURRENTLY LOGGED IN (ignore cached remote connections) --
	if exists(select * from master.dbo.sysprocesses where sid = @sid and status != 'dormant')
	begin
		raiserror(15434, -1, -1, @loginame)
		return(1)
	end

    -- CHECK IF ANY DATABASES ARE OWNED BY LOGIN --
	if exists(select * from master.dbo.sysdatabases where sid = @sid)
	begin
		raiserror(15174, -1, -1, @loginame)
		select 'Databases owned by login:' = name
                from master.dbo.sysdatabases where sid = @sid
		return(1)
	end

	-- COLLECT ALL INSTANCES OF USE OF THIS LOGIN IN SYSUSERS --
	declare @dbname		sysname
	declare ms_crs_dbname cursor local keyset for select name from master.dbo.sysdatabases
	open ms_crs_dbname
	fetch ms_crs_dbname into @dbname
	while @@fetch_status >= 0
	begin
		if (has_dbaccess(@dbname) = 1)
		begin
			select @exec_stmt = 'use ' + quotename( @dbname , '[') + '
				   insert into #db_list (dbname, user_name)
				select N'+ quotename( @dbname , '''')+', name from sysusers
				where sid = suser_sid(N' + quotename( @loginame , '''') + ') '
			exec (@exec_stmt)
		end
		else
			raiserror(15622,-1,-1, @dbname)

		fetch ms_crs_dbname into @dbname
	end
	deallocate ms_crs_dbname

    -- ERROR IF LOGIN USED AS USER IN ANY DATABASE --
	if (select count(*) from #db_list) <> 0
	begin
		raiserror(15175,-1,-1,@loginame)
		select
			'Database name:' = dbname,
			'User name:' = user_name,
			'Mapping type:' = 'user'
		from #db_list
		order by dbname
		return (1)
	end

    -- VERIFY NO JOBS IN MSDB OWNED BY THIS LOGIN --
	if db_id('msdb') is not null
        and object_id('msdb.dbo.sp_check_for_owned_jobs') is not null
	begin
        exec msdb.dbo.sp_check_for_owned_jobs @loginame, '#retval'
	    if exists (select job_count from #retval where job_count > 0)
	    begin
		    declare @job_count int
		    select @job_count = job_count from #retval
		    raiserror(14248, -1, -1, @job_count)
		    return (1)
	    end
	end

    -- DELETE THIS LOGIN (ALSO DELETES REMOTE LOGINS MAPPED TO IT) --
	delete from master.dbo.sysxlogins where sid = @sid

    -- FINALIZATION: SUCCESS/FAILURE MESSAGE
	if @@rowcount > 0
	begin
		-- UPDATE PROTECTION TIMESTAMP FOR MASTER DB, TO INDICATE SYSLOGINS CHANGE --
		exec('use master grant all to null')

		raiserror(15479,-1,-1)
		return (0)
	end
	else
	begin
		raiserror(15007,10,-1,@loginame)
		return (1)
	end     -- sp_droplogin
go

----------------------- sp_MSaddlogin_implicit_ntlogin ------------------------

raiserror(15339,-1,-1,'sp_MSaddlogin_implicit_ntlogin')
go
----------------------------------------
-- NOTE: FOR INTERNAL SECURITY USE ONLY!
--      DO NOT DOCUMENT OR USE!
----------------------------------------
create procedure sp_MSaddlogin_implicit_ntlogin
    @loginame		sysname
AS

declare @default_lang sysname

    -- NO-OP IF LOGIN ALREADY EXISTS --
	-- if suser_sid(@loginame) is null

	if not exists(select * from master.dbo.syslogins where loginname = @loginame)
	begin

        -- MUST BE NT NAME --
        if (charindex('\', @loginame) = 0)
            return (1)

	    declare	@newsid	varbinary(85),
                @status smallint

        -- OBTAIN NT SID FOR THIS LOGIN (SET STATUS BITS) --
        select @status = 4      -- ntlogin(4)
	    select @newsid = get_sid('\U'+@loginame, NULL)	    -- NT user
	    if (@newsid IS Null)
	    begin
            select @newsid = get_sid('\G'+@loginame, NULL)  -- NT group
	        IF (@newsid IS Null)
		        return (1)
	    end
        else
            select @status = @status | 8    -- NTUser
		
		-- FAIL IF SID ALREADY IN SYSLOGINS 
		if exists(select * from master.dbo.syslogins where sid = @newsid)
			return (1)

		select @default_lang = name from master.dbo.syslanguages
		where langid = @@default_langid 	--server default language


        -- ADD IMPLICIT LOGIN ENTRY --
	    INSERT into master.dbo.sysxlogins Values
            (NULL, @newsid, @status, getdate(), getdate(),
                @loginame, NULL, 1, isnull(@default_lang, N'us_english'))
		if @@error <> 0		-- this indicates we saw duplicate row
			return @@error

		-- UPDATE PROTECTION TIMESTAMP FOR MASTER DB, TO INDICATE SYSLOGINS CHANGE --
		exec('use master grant all to null')

    end

    -- RETURN FAILURE/SUCCESS
    return (0) -- sp_MSaddlogin_implicit_ntlogin
go

------------------------------- sp_grantlogin ---------------------------------

raiserror(15339,-1,-1,'sp_grantlogin')
go
create procedure sp_grantlogin
    @loginame		sysname
AS
    -- SETUP RUNTIME OPTIONS / DECLARE VARIABLES --
	set nocount on
	declare @ret   int    -- return value of sp call

    -- CHECK PERMISSIONS --
	IF (not is_srvrolemember('securityadmin') = 1)
	begin
	   dbcc auditevent (105, 1, 0, @loginame, NULL, NULL, NULL)
	   raiserror(15247,-1,-1)
	   return (1)
	end
	ELSE
	begin
	   dbcc auditevent (105, 1, 1, @loginame, NULL, NULL, NULL)
	end

    -- DISALLOW USER TRANSACTION --
	set implicit_transactions off
	IF (@@trancount > 0)
	begin
		raiserror(15002,-1,-1,'sp_grantlogin')
		return (1)
	end

    -- DISALLOW SQL LOGIN (IE. MUST BE 'DOMAIN\USER') --
	if (charindex('\', @loginame) = 0)
	begin
		raiserror(15407, -1, -1, @loginame)
		return (1)
	end

    -- ADD ROW FOR NT LOGIN IF NEEDED --
	if not exists(select * from master.dbo.syslogins where loginname = @loginame)
    begin
        execute @ret = sp_MSaddlogin_implicit_ntlogin @loginame
        if (@ret <> 0)
	    begin
		    raiserror(15401,-1,-1 ,@loginame)
		    return (1)
	    end
    end

    -- UPDATE LOGIN BITS --
    update master.dbo.sysxlogins set xstatus = (xstatus & ~1) | 2, xdate2 = getdate()
        where name = @loginame and srvid IS NULL

	-- UPDATE PROTECTION TIMESTAMP FOR MASTER DB, TO INDICATE SYSLOGINS CHANGE --
	exec('use master grant all to null')

    -- FINALIZATION: RETURN SUCCESS/FAILURE
	if @@error <> 0
	begin
		raiserror(15480,-1,-1,@loginame)
        return (1)
	end
	else
	begin
		raiserror(15481,-1,-1,@loginame)
        return (0)
	end -- sp_grantlogin
go

------------------------------- sp_validatelogins ---------------------------------

raiserror(15339,-1,-1,'sp_validatelogins')
go
create proc sp_validatelogins
AS
	-- Must be securityadmin (or sysadmin) to execute
	if is_srvrolemember('securityadmin') = 0 and is_srvrolemember('sysadmin') = 0
	begin
		raiserror(15247,-1,-1)
		return 1
	end

	-- Use get_sid() to determine if nt name is still valid (builtin is only available from system procs!)
	select 'SID' = sid, 'NT Login' = loginname from master.dbo.syslogins
		where isntname = 1 and get_sid(loginname, NULL) is null
	return 0 -- sp_validatelogins
go

-- FOR BACKWARD COMPATIBILTY ONLY --
raiserror(15339,-1,-1,'xp_grantlogin')
go
create procedure xp_grantlogin
    @loginame       sysname,
    @logintype      varchar(5) = Null       -- ignored unless 'admin'
AS
	set nocount on

    -- IF NAME NOT 'DOMAIN\USER', ADD DEFAULT DOMAIN --
    if (charindex('\', @loginame) = 0)
    begin
        declare @defdom varchar(25)
        exec master.dbo.xp_instance_regread 'HKEY_LOCAL_MACHINE',
                'SOFTWARE\Microsoft\MSSQLServer\MSSQLServer',
                'DefaultDomain', @defdom out
        select @loginame = @defdom + '\' + @loginame
    end

	Declare @ret   int     -- return value of sp call
    execute @ret = sp_grantlogin @loginame
    if (@ret = 0 and @logintype = 'admin')
        execute @ret = sp_addsrvrolemember @loginame, 'sysadmin'
    return (@ret)
go

checkpoint
go
------------------------------- sp_denylogin ----------------------------------

raiserror(15339,-1,-1,'sp_denylogin')
go
create procedure sp_denylogin
    @loginame		sysname
AS
    -- SETUP RUNTIME OPTIONS / DECLARE VARIABLES --
	set nocount on
	declare @ret   int    -- return value of sp call

    -- CHECK PERMISSIONS --
	IF (not is_srvrolemember('securityadmin') = 1)
	begin
	   dbcc auditevent (105, 3, 0, @loginame, NULL, NULL, NULL)
	   raiserror(15247,-1, -1)
	   return (1)
	end
	ELSE
	begin
	   dbcc auditevent (105, 3, 1, @loginame, NULL, NULL, NULL)
	end

    -- DISALLOW USER TRANSACTION --
	set implicit_transactions off
	IF (@@trancount > 0)
	begin
		raiserror(15002,-1,-1,'sp_denylogin')
		return (1)
	end

    -- DISALLOW SQL LOGIN (IE. MUST BE 'DOMAIN\USER') --
	if (charindex('\', @loginame) = 0)
	begin
		raiserror(15407, -1, -1, @loginame)
		return (1)
	end

    -- ADD ROW FOR NT LOGIN IF NEEDED --
	if not exists(select * from master.dbo.syslogins where loginname = @loginame)
    begin
        execute @ret = sp_MSaddlogin_implicit_ntlogin @loginame
        if (@ret <> 0)
	    begin
		    raiserror(15401,-1,-1 ,@loginame)
		    return (1)
	    end
    end

    -- UPDATE LOGIN BITS --
    update master.dbo.sysxlogins set xstatus = (xstatus & ~2) | 1, xdate2 = getdate()
        where name = @loginame and srvid IS NULL

	-- UPDATE PROTECTION TIMESTAMP FOR MASTER DB, TO INDICATE SYSLOGINS CHANGE --
	exec('use master grant all to null')

    -- FINALIZATION: RETURN SUCCESS/FAILURE
	if @@error <> 0
	begin
		raiserror(15482,-1,-1,@loginame)
        return (1)
	end
	else
	begin
		raiserror(15483,-1,-1,@loginame)
        return (0)
	end -- sp_denylogin
go

------------------------------- sp_revokelogin --------------------------------

raiserror(15339,-1,-1,'sp_revokelogin')
go
create procedure sp_revokelogin
    @loginame		sysname
AS
    -- SETUP RUNTIME OPTIONS / DECLARE VARIABLES --
	set nocount on
	declare	@sid	varbinary(85)

    -- CHECK PERMISSIONS --
	IF (not is_srvrolemember('securityadmin') = 1)
	begin
	   dbcc auditevent (105, 2, 0, @loginame, NULL, NULL, NULL)
	   raiserror(15247,-1,-1)
	   return (1)
	end
	ELSE
	begin
	   dbcc auditevent (105, 2, 1, @loginame, NULL, NULL, NULL)
	end

    -- DISALLOW USER TRANSACTION --
	set implicit_transactions off
	IF (@@trancount > 0)
	begin
		raiserror(15002,-1,-1,'sp_revokelogin')
		return (1)
	end

    -- DISALLOW SQL LOGIN (IE. MUST BE 'DOMAIN\USER') --
	if (charindex('\', @loginame) = 0)
	begin
		raiserror(15407, -1, -1, @loginame)
		return (1)
	end

    -- REMOVE ROW IF EXISTS FOR LOGIN PROVIDED IT IS AN NT NAME --
    -- select @sid = suser_sid(@loginame)
	-- if @sid is not null
	if exists(select * from master.dbo.syslogins where loginname = @loginame and isntname = 1)
	begin
		select @sid = sid from master.dbo.syslogins where loginname = @loginame and isntname = 1

        -- For nt logins, skip sid foreign-key checks. --
        -- also deletes remote logins mapped to this user --
        delete from master.dbo.sysxlogins where sid = @sid

		-- UPDATE PROTECTION TIMESTAMP FOR MASTER DB, TO INDICATE SYSLOGINS CHANGE --
		exec('use master grant all to null')
	end
	else
	begin
		-- CHECK IF THIS IS A VALID NT NAME BY GETTING ITS SID FROM NT
		declare	@newsid	varbinary(85)
		select @newsid = get_sid('\U'+@loginame, NULL)	    -- NT user
		IF (@newsid IS Null)
		begin
			select @newsid = get_sid('\G'+@loginame, NULL)  -- NT group
			IF (@newsid IS Null)
			begin
				raiserror(15401,-1,-1 ,@loginame)
				return (1)
			end
		end
	end


    -- FINALIZATION: RETURN SUCCESS/FAILURE
	if @@error <> 0
	begin
		raiserror(15484,-1,-1,@loginame)
        return (1)
	end
	else
	begin
		raiserror(15485,-1,-1,@loginame)
        return (0)
	end -- sp_revokelogin
go


-- FOR BACKWARD COMPATIBILTY ONLY --
raiserror(15339,-1,-1,'xp_revokelogin')
go
create procedure xp_revokelogin
    @loginame       sysname
AS
	set nocount on

    -- IF NAME NOT 'DOMAIN\USER', ADD DEFAULT DOMAIN --
    if (charindex('\', @loginame) = 0)
    begin
        declare @defdom varchar(25)
        exec master.dbo.xp_instance_regread 'HKEY_LOCAL_MACHINE',
                'SOFTWARE\Microsoft\MSSQLServer\MSSQLServer',
                'DefaultDomain', @defdom out
        select @loginame = @defdom + '\' + @loginame
    end

	Declare @ret   int     -- return value of sp call
    execute @ret = sp_revokelogin @loginame
    return (@ret)
go

------------------------------- sp_defaultdb ----------------------------------

raiserror(15339,-1,-1,'sp_defaultdb')
go
create procedure sp_defaultdb
    @loginame   sysname,	-- login name
    @defdb      sysname     -- default db
as
    -- SETUP RUNTIME OPTIONS / DECLARE VARIABLES --
	set nocount on
	declare @ret   int    -- return value of sp call

    -- CHECK PERMISSIONS --
	IF (not is_srvrolemember('securityadmin') = 1)
        AND not @loginame = suser_sname()
	begin
	    dbcc auditevent (106, 1, 0, @loginame, NULL, NULL, NULL)
		raiserror(15132,-1,-1)
		return (1)
	end
	ELSE
	begin
	   dbcc auditevent (106, 1, 1, @loginame, NULL, NULL, NULL)
	end

    -- DISALLOW USER TRANSACTION --
	set implicit_transactions off
	IF (@@trancount > 0)
	begin
		raiserror(15002,-1,-1,'sp_defaultdb')
		return (1)
	end


    -- VALIDATE DATABASE NAME --
    if db_id(@defdb) IS NULL
	begin
		raiserror(15010,-1,-1,@defdb)
		return (1)
	end

    -- ADD ROW FOR NT LOGIN IF NEEDED --
	if not exists(select * from master.dbo.syslogins where loginname = @loginame)
    begin
        execute @ret = sp_MSaddlogin_implicit_ntlogin @loginame
        if (@ret <> 0)
	    begin
		    raiserror(15007,-1,-1,@loginame)
		    return (1)
	    end
    end

    -- CHANGE DEFAULT DATABASE --
    update master.dbo.sysxlogins set dbid = db_id(@defdb), xdate2 = getdate()
	    where name = @loginame and srvid IS NULL

	-- UPDATE PROTECTION TIMESTAMP FOR MASTER DB, TO INDICATE SYSLOGINS CHANGE --
	exec('use master grant all to null')

    -- FINALIZATION: RETURN SUCCESS/FAILURE
	IF (@@error <> 0)
	    return (1)
    raiserror(15486,-1,-1)
	return (0) -- sp_defaultdb
go

checkpoint
go
---------------------------- sp_defaultlanguage -------------------------------

raiserror(15339,-1,-1,'sp_defaultlanguage')
go
create procedure sp_defaultlanguage
    @loginame sysname,			-- login name
    @language sysname = NULL	-- default language
as
    -- SETUP RUNTIME OPTIONS / DECLARE VARIABLES --
	set nocount on
	declare @ret   int     -- return value of sp call

    -- CHECK PERMISSIONS --
	IF (not is_srvrolemember('securityadmin') = 1)
        AND not @loginame = suser_sname()
	begin
	    dbcc auditevent (106, 2, 0, @loginame, NULL, NULL, NULL)
		raiserror(15247,-1,-1)
		return (1)
	end
	ELSE
	begin
	   dbcc auditevent (106, 2, 1, @loginame, NULL, NULL, NULL)
	end

    -- DISALLOW USER TRANSACTION --
	set implicit_transactions off
	IF (@@trancount > 0)
	begin
		raiserror(15002,-1,-1,'sp_defaultlanguage')
		return (1)
	end

	-- VALIDATE LANGUAGE --
	IF (@language is not Null)
	begin
		Execute @ret = sp_validlang @language
		IF (@ret <> 0)
			return (1)
	end
	else
	begin

		select @language = name from master.dbo.syslanguages
		where langid = @@default_langid  --default language

		if @language is null
			select @language = N'us_english'
	end

    -- ADD ROW FOR NT LOGIN IF NEEDED --
	if not exists(select * from master.dbo.syslogins where loginname = @loginame)
    begin
        execute @ret = sp_MSaddlogin_implicit_ntlogin @loginame
        if (@ret <> 0)
	    begin
		    raiserror(15007,-1,-1,@loginame)
		    return (1)
	    end
    end

    -- CHANGE DEFAULT LANGUAGE --
    update master.dbo.sysxlogins set language = @language, xdate2 = getdate()
	    where name = @loginame and srvid IS NULL

	-- UPDATE PROTECTION TIMESTAMP FOR MASTER DB, TO INDICATE SYSLOGINS CHANGE --
	exec('use master grant all to null')

    -- FINALIZATION: RETURN SUCCESS/FAILURE
	if @@error <> 0
    	return (1)
    raiserror(15487,-1,-1,@loginame,@language)
	return (0) -- sp_defaultlanguage
go

--------------------------- sp_addsrvrolemember -------------------------------

raiserror(15339,-1,-1,'sp_addsrvrolemember')
go
create procedure sp_addsrvrolemember
    @loginame sysname,			-- login name
    @rolename sysname = NULL	-- server role name
as
    -- SETUP RUNTIME OPTIONS / DECLARE VARIABLES --
	set nocount on
	declare @ret        int,    -- return value of sp call
            @rolebit    smallint,
            @ismem      int,
            @sid        varbinary(85)

    -- DISALLOW USER TRANSACTION --
	set implicit_transactions off
	IF (@@trancount > 0)
	begin
		raiserror(15002,-1,-1,'sp_addsrvrolemember')
		return (1)
	end

    -- VALIDATE SERVER ROLE NAME, CHECKING PERMISSIONS --
    select @ismem = is_srvrolemember(@rolename)
    if @ismem is null
    begin
		dbcc auditevent (108, 1, 0, @loginame, NULL, @rolename, NULL)
        raiserror(15402, -1, -1, @rolename)
        return (1)
    end
    if @ismem = 0
	begin
		dbcc auditevent (108, 1, 0, @loginame, NULL, @rolename, NULL)
		raiserror(15247,-1,-1)
		return (1)
	end

	-- AUDIT A SUCCESSFUL SECURITY CHECK --
	dbcc auditevent (108, 1, 1, @loginame, NULL, @rolename, NULL)

    -- OBTAIN THE BIT FOR THIS ROLE --
    select @rolebit = CASE @rolename
            WHEN 'sysadmin'         THEN 16
            WHEN 'securityadmin'    THEN 32
            WHEN 'serveradmin'      THEN 64
            WHEN 'setupadmin'       THEN 128
            WHEN 'processadmin'     THEN 256
            WHEN 'diskadmin'        THEN 512
            WHEN 'dbcreator'        THEN 1024
			WHEN 'bulkadmin'		THEN 4096
            ELSE NULL END

	select @sid = sid from master.dbo.syslogins where loginname = @loginame
    -- ADD ROW FOR NT LOGIN IF NEEDED --
    if @sid is null
    begin
        execute @ret = sp_MSaddlogin_implicit_ntlogin @loginame
        if (@ret <> 0)
	    begin
		    raiserror(15007,-1,-1,@loginame)
		    return (1)
	    end
    end
    -- CANNOT CHANGE SA ROLES --
	else if @sid = 0x1	-- 'sa'
    begin
        raiserror(15405, -1 ,-1, @loginame)
        return (1)
    end

    -- UPDATE ROLE MEMBERSHIP --
    update master.dbo.sysxlogins set xstatus = xstatus | @rolebit, xdate2 = getdate()
	    where name = @loginame and srvid IS NULL

	-- UPDATE PROTECTION TIMESTAMP FOR MASTER DB, TO INDICATE SYSLOGINS CHANGE --
	exec('use master grant all to null')

	raiserror(15488,-1,-1,@loginame,@rolename)

    -- FINALIZATION: RETURN SUCCESS/FAILURE
	return (@@error) -- sp_addsrvrolemember
go

checkpoint
go
--------------------------- sp_dropsrvrolemember ------------------------------

raiserror(15339,-1,-1,'sp_dropsrvrolemember')
go
create procedure sp_dropsrvrolemember
    @loginame sysname,			-- login name
    @rolename sysname = NULL	-- server role name
as
    -- SETUP RUNTIME OPTIONS / DECLARE VARIABLES --
	set nocount on
	declare @ret        int,    -- return value of sp call
            @rolebit    smallint,
            @ismem      int,
			@sid		varbinary(85)

    -- DISALLOW USER TRANSACTION --
	set implicit_transactions off
	IF (@@trancount > 0)
	begin
		raiserror(15002,-1,-1,'sp_dropsrvrolemember')
		return (1)
	end

    -- VALIDATE SERVER ROLE NAME, CHECKING PERMISSIONS --
    select @ismem = is_srvrolemember(@rolename)
    if @ismem is null
    begin
		dbcc auditevent (108, 2, 0, @loginame, NULL, @rolename, NULL)
        raiserror(15402, -1, -1, @rolename)
        return (1)
    end
    if @ismem = 0
	begin
		dbcc auditevent (108, 2, 0, @loginame, NULL, @rolename, NULL)
		raiserror(15247,-1,-1)
		return (1)
	end

	-- AUDIT THE SUCCESSFUL SECURITY CHECK --
	dbcc auditevent (108, 2, 1, @loginame, NULL, @rolename, NULL)

    -- OBTAIN THE BIT FOR THIS ROLE --
    select @rolebit = CASE @rolename
            WHEN 'sysadmin'         THEN 16
            WHEN 'securityadmin'    THEN 32
            WHEN 'serveradmin'      THEN 64
            WHEN 'setupadmin'       THEN 128
            WHEN 'processadmin'     THEN 256
            WHEN 'diskadmin'        THEN 512
            WHEN 'dbcreator'        THEN 1024
			WHEN 'bulkadmin'		THEN 4096
            ELSE NULL END

	select @sid = sid from master.dbo.syslogins where loginname = @loginame
	-- ERROR IF USER DOESNT EXIST --
	if @sid is null
    begin
	    raiserror(15007,-1,-1,@loginame)
	    return (1)
    end
    -- CANNOT CHANGE SA ROLES --
	else if @sid = 0x1	-- 'sa'
    begin
        raiserror(15405, -1 ,-1, @loginame)
        return (1)
    end

    -- UPDATE ROLE MEMBERSHIP --
    update master.dbo.sysxlogins set xstatus = xstatus & ~@rolebit, xdate2 = getdate()
	    where name = @loginame and srvid IS NULL

	-- UPDATE PROTECTION TIMESTAMP FOR MASTER DB, TO INDICATE SYSLOGINS CHANGE --
	exec('use master grant all to null')

	raiserror(15489,-1,-1,@loginame,@rolename)

    -- FINALIZATION: RETURN SUCCESS/FAILURE
	return (@@error) -- sp_dropsrvrolemember
go

-- GRANT PUBLIC ACCESS (SP'S DO INTERNAL PERMISSIONS CHECKS) --
grant execute on sp_addlogin to public
grant execute on sp_password to public
grant execute on sp_droplogin to public
grant execute on sp_grantlogin to public
grant execute on sp_validatelogins to public
grant execute on xp_grantlogin to public
grant execute on sp_denylogin to public
grant execute on sp_revokelogin to public
grant execute on xp_revokelogin to public
grant execute on sp_defaultdb to public
grant execute on sp_defaultlanguage to public
grant execute on sp_addsrvrolemember to public
grant execute on sp_dropsrvrolemember to public
grant execute on sp_attach_db to public
grant execute on sp_attach_single_file_db to public
go

/**************************  END LOGIN-SECURITY ******************************/


/******************************************************************************
************************  DATABASE-ACCESS-SECURITY  ***************************
******************************************************************************/
checkpoint
go
if object_id('sp_MSadduser_implicit_ntlogin','P') IS NOT NULL
	drop procedure sp_MSadduser_implicit_ntlogin
if object_id('sp_MScheck_uid_owns_anything','P') IS NOT NULL
	drop procedure sp_MScheck_uid_owns_anything
if object_id('sp_grantdbaccess','P') IS NOT NULL
	drop procedure sp_grantdbaccess
if object_id('sp_revokedbaccess','P') IS NOT NULL
	drop procedure sp_revokedbaccess
if object_id('sp_adduser','P') IS NOT NULL
	drop procedure sp_adduser
if object_id('sp_dropuser','P') IS NOT NULL
	drop procedure sp_dropuser
if object_id('sp_addalias','P') IS NOT NULL
	drop procedure sp_addalias
if object_id('sp_dropalias','P') IS NOT NULL
	drop procedure sp_dropalias
if object_id('sp_addrole','P') IS NOT NULL
	drop procedure sp_addrole
if object_id('sp_droprole','P') IS NOT NULL
	drop procedure sp_droprole
if object_id('sp_addgroup','P') IS NOT NULL
	drop procedure sp_addgroup
if object_id('sp_dropgroup','P') IS NOT NULL
	drop procedure sp_dropgroup
if object_id('sp_addapprole','P') IS NOT NULL
	drop procedure sp_addapprole
if object_id('sp_approlepassword','P') IS NOT NULL
	drop procedure sp_approlepassword
if object_id('sp_setapprole','P') IS NOT NULL
	drop procedure sp_setapprole
if object_id('sp_dropapprole','P') IS NOT NULL
	drop procedure sp_dropapprole
if object_id('sp_addrolemember','P') IS NOT NULL
	drop procedure sp_addrolemember
if object_id('sp_droprolemember','P') IS NOT NULL
	drop procedure sp_droprolemember
if object_id('sp_changegroup','P') IS NOT NULL
	drop procedure sp_changegroup
if object_id('sp_change_users_login','P') IS NOT NULL
    drop procedure sp_change_users_login
if object_id('sp_changedbowner','P') IS NOT NULL
	drop procedure sp_changedbowner
if object_id('sp_check_removable_sysusers','P') IS NOT NULL
	drop procedure sp_check_removable_sysusers
if object_id('sp_changeobjectowner', 'P') IS NOT NULL
	drop procedure sp_changeobjectowner
go

----------------------- sp_MSadduser_implicit_ntlogin -------------------------

raiserror(15339,-1,-1,'sp_MSadduser_implicit_ntlogin')
go
----------------------------------------
-- NOTE: FOR INTERNAL SECURITY USE ONLY!
--      DO NOT DOCUMENT OR USE!
----------------------------------------
create procedure sp_MSadduser_implicit_ntlogin
    @ntname         sysname
AS
    -- NO-OP IF LOGIN ALREADY EXISTS --
	if user_id(@ntname) is null
	begin

        -- MUST BE NT NAME --
        if (charindex('\', @ntname) = 0)
            return (1)

	    declare	@newsid	varbinary(85),
                @status smallint,
                @uid    smallint

        -- OBTAIN NT SID FOR THIS USER (SET STATUS BITS) --
        select @status = 4      -- ntlogin(4)
	    select @newsid = get_sid('\U'+@ntname, NULL)	    -- NT user
	    if (@newsid is Null)
	    begin
	        select @newsid = get_sid('\G'+@ntname, NULL)    -- NT group
	        IF (@newsid IS Null)
		        return (1)
	    end
        else
            select @status = @status | 8    -- NTUser

        -- FAIL IF SID ALREADY IN SYSUSERS --
        if exists (select sid from sysusers where sid = @newsid)
            return (1)

        -- OBTAIN NEW UID (RESERVE 1-4) --
        if user_name(5) IS NULL
            select @uid = 5
        else
		    select @uid = min(uid)+1 from sysusers
                where uid >= 5 and uid < (16384 - 1)    -- stay in users range
                    and user_name(uid+1) is null        -- uid not in use
        if @uid is null
	    begin
		    raiserror(15065,-1,-1)
		    return (1)
	    end

        -- ADD IMPLICIT SYSUSERS ENTRY --
        insert into sysusers values
            (@uid, @status, @ntname, @newsid, 0x00, getdate(), getdate(), 0, NULL)

        -- INVALIDATE UID CACHE FOR THIS DB --
        grant all to null
    end

    -- RETURN FAILURE/SUCCESS --
    return @@error -- sp_MSadduser_implicit_ntlogin
go

------------------------ sp_MScheck_uid_owns_anything -------------------------

raiserror(15339,-1,-1,'sp_MScheck_uid_owns_anything')
go
----------------------------------------
-- NOTE: FOR INTERNAL SECURITY USE ONLY!
--      DO NOT DOCUMENT OR USE!
----------------------------------------
create procedure sp_MScheck_uid_owns_anything
    @uid            smallint        -- uid to for which to check ownership
as
    -- SETUP RUNTIME OPTIONS / DECLARE VARIABLES --
	set nocount on
	declare @isowner    int
    select @isowner = 0

    -- CHECK IF USER OWNS ANY OBJECTS --
    select @isowner = 0
    if exists (select uid from sysobjects where uid = @uid)
	begin
		raiserror(15183,-1,-1)
		select name, type from sysobjects where uid = @uid
        select @isowner = 1
	end

    -- CHECK IF USER OWNS ANY TYPES --
    if exists (select uid from systypes where uid = @uid)
    begin
		raiserror(15184,-1,-1)
		select user_type = name, physical_type = type_name(xtype)
					from systypes where uid = @uid
        select @isowner = 1
	end

    -- CHECK IF USER GRANTED ANY PERMISSIONS --
    if exists (select grantor from syspermissions where grantor = @uid)
    begin
		raiserror(15284,-1,-1)
		select 'Grantee'=user_name(grantee) ,'Object'=object_name(id)
					from syspermissions where grantor = @uid
        select @isowner = 1
	end

    -- CHECK IF USER OWNS ANY ROLES --
    if exists (select altuid from sysusers where altuid = @uid
                and (issqlrole = 1 or isapprole = 1))
    begin
		raiserror(15421,-1,-1)
		select 'Role Name' = name,
               'Type' = CASE WHEN issqlrole=1 THEN 'SQL Role'
                             ELSE 'App Role' END
            from sysusers where altuid = @uid and (issqlrole = 1 or isapprole = 1)
        select @isowner = 1
    end

    return @isowner	-- sp_MScheck_uid_owns_anything
go

------------------------------ sp_grantdbaccess -------------------------------

raiserror(15339,-1,-1,'sp_grantdbaccess')
go
create procedure sp_grantdbaccess
	@loginame       sysname,
	@name_in_db     sysname = NULL OUT
as
    -- SETUP RUNTIME OPTIONS / DECLARE VARIABLES --
	set nocount on
	declare @ret        int,    -- return value of sp call
            @uid        smallint,
            @sid        varbinary(85),
            @status     smallint

    if @name_in_db is null
        select @name_in_db = @loginame

    -- CHECK PERMISSIONS --
    if (not is_member('db_accessadmin') = 1) and
       (not is_member('db_owner') = 1)
	begin
        dbcc auditevent (109, 3, 0, @loginame, @name_in_db, NULL, NULL)
		raiserror(15247,-1,-1)
		return (1)
	end
	else
	begin
        dbcc auditevent (109, 3, 1, @loginame, @name_in_db, NULL, NULL)
	end

    -- DISALLOW USER TRANSACTION --
	set implicit_transactions off
	IF (@@trancount > 0)
	begin
		raiserror(15002,-1,-1,'sp_grantdbaccess')
		return (1)
	end

    -- VALIDATE NAME-IN-DB --
    if @name_in_db <> @loginame
    begin
		exec @ret = sp_validname @name_in_db
		if @ret <> 0
			return(1)
        if (charindex('\', @name_in_db) > 0)
        begin
            raiserror(15006,-1,-1,@name_in_db)
            return (1)
        end
    end

    -- CHECK FOR SPECIAL USER GUEST --
    if @name_in_db = 'guest'
    begin
        -- ERROR IF NOT USER, OR ALREADY ADDED --
        if @loginame <> 'guest'
        begin
		    raiserror(15062,-1,-1)
		    return(1)
        end
        if exists (select * from sysusers where hasdbaccess = 1 and name = 'guest')
        begin
            raiserror(15023,-1,-1,'guest')
            return (1)
        end

        -- ENABLE USER GUEST --
        update sysusers set status = (status & ~1) | 2, updatedate = getdate()
                    where name = 'guest'
        return (0)
    end

    -- VALIDATE LOGIN NAME (OBTAIN SID) --
    select @status = case when (charindex('\', @loginame) <> 0) then 4 else 0 end
    if @status = 0
        select @sid = sid from master.dbo.syslogins         -- sql user
            where isntname = 0 and loginname = @loginame
    if @sid is null
    begin
        -- NT GROUPS REQUIRE DOMAIN NAME --
        if @status = 4
            select @sid = get_sid('\G'+@loginame, NULL)     -- nt group
        if @sid is null
        begin
            select @sid = get_sid('\U'+@loginame, NULL)     -- nt user
            if @sid is not null
                select @status = 12
        end
    end
    -- PREVENT USE OF CERTAIN LOGINS --
	else if @sid = 0x1	-- 'sa'
	begin
		raiserror(15405, -1, -1, @loginame)
		return (1)
	end

    if @sid is null
    begin
        if @status = 0
            raiserror(15007,-1,-1,@loginame)
        else
            raiserror(15401,-1,-1,@loginame)
        return (1)
    end

    -- CHECK IF LOGIN ALREADY IN DATABASE --
    if exists (select sid from sysusers where sid = @sid)
    begin
        -- ERROR IF LOGIN IS ALREADY ALIASED --
        if exists (select sid from sysusers where sid = @sid and isaliased = 1)
        begin
		    raiserror(15022,-1,-1)
		    return (1)
        end

        -- ERROR IF ALREADY EXISTS UNDER DIFFERENT NAME --
        if (not user_sid(user_id(@name_in_db)) = @sid)
        begin
		    raiserror(15063,-1,-1)
		    return (1)
        end

        -- ERROR IF LOGIN ALREADY HAS ACCESS --
        if exists (select sid from sysusers where sid = @sid and hasdbaccess = 1)
        begin
            if @status = 4
    		    raiserror(15024,-1,-1,@name_in_db)
            else
		        raiserror(15023,-1,-1,@name_in_db)
		    return (1)
        end

        -- GIVE DATABASE ACCESS TO THIS LOGIN --
        update sysusers set status = (status & ~1) | 2, updatedate = getdate()
                    where sid = @sid
        return @@error
	end

	if @name_in_db = 'sys'
		raiserror(15355,-1,-1)

    if user_id(@name_in_db) is not null OR
		@name_in_db IN ('system_function_schema','INFORMATION_SCHEMA')
    begin
        -- SYSUSERS NAME ALREADY EXISTS --
        if @status = 4
    		raiserror(15024,-1,-1,@name_in_db)
        else
		    raiserror(15023,-1,-1,@name_in_db)
        return (1)
    end

    -- OBTAIN NEW UID (RESERVE 1-4) --
    if user_name(5) IS NULL
        select @uid = 5
    else
		select @uid = min(uid)+1 from sysusers
            where uid >= 5 and uid < (16384 - 1)    -- stay in users range
                and user_name(uid+1) is null        -- uid not in use
    if @uid is null
	begin
		raiserror(15065,-1,-1)
		return (1)
	end

    -- INSERT SYSUSERS ROW --
    insert into sysusers select
        @uid, @status | 2, @name_in_db, @sid, 0x00, getdate(), getdate(), 0, NULL

    -- INVALIDATE CACHED PERMISSIONS --
    grant all to null

    -- PRINT SUCCESS --
    raiserror(15341,-1,-1, @loginame)

    -- RETURN SUCCESS STATUS --
    return @@error -- sp_grantdbaccess
go

-- FOR BACKWARD COMPATIBILTY ONLY --
raiserror(15339,-1,-1,'sp_adduser')
go
create procedure sp_adduser
	@loginame       sysname,	    -- user's login name in syslogins
	@name_in_db     sysname = NULL, -- user's name to add to current db
	@grpname		sysname = NULL  -- role to which user should be added.
as
    -- SETUP RUNTIME OPTIONS / DECLARE VARIABLES --
	set nocount on
	declare @ret        int

    -- LIMIT TO SQL/NT USERS IN SYSLOGINS (BCKWRD COMPAT ONLY!)
	if not exists (select * from master.dbo.syslogins where loginname = @loginame
			and (isntuser = 1 or isntname = 0))
        and @loginame <> 'guest'
    begin
        raiserror(15007,-1,-1,@loginame)
        return (1)
    end

	-- VALIDATE THE ROLENAME --
    if @grpname is not null and
	   not exists (select * from sysusers where name = @grpname and issqlrole = 1)
    begin
	    raiserror(15014,-1,-1,@grpname)
	    return (1)
    end

    if @name_in_db is null
        select @name_in_db = @loginame

	-- In Hydra only the user dbo can do this --
    if (not is_member('dbo') = 1)
	begin
	    -- AUDIT FAILED SECURITY CHECK --
        dbcc auditevent (109, 1, 0, @loginame, @name_in_db, @grpname , NULL)
		raiserror(15247,-1,-1)
		return (1)
	end
    else
    begin
        -- AUDIT SUCCESSFUL SECURITY CHECK --
        dbcc auditevent (109, 1, 1, @loginame, @name_in_db, @grpname , NULL)
    end

    -- ADD THE USER TO THE DATABASE --
    execute @ret = sp_grantdbaccess @loginame, @name_in_db OUT
    if (@ret <> 0)
        return (1)

    -- ADD USER TO ROLE IF GIVEN. NOP FOR 'public' --
    if (@grpname is not null) and (@grpname <> 'public')
    begin
        execute @ret = sp_addrolemember @grpname, @name_in_db
        if @ret <> 0
		begin
			-- ROLL BACK THE ABOVE sp_grantdbaccess --
			if @name_in_db = 'guest'
				update sysusers set status = status & ~2, updatedate = getdate()
                            where name = 'guest'
			else
				delete from sysusers where name = @name_in_db
            return (1)
		end
    end

    -- RETURN SUCCESS --
    return (0) -- sp_adduser
go

checkpoint
go

----------------------------- sp_revokedbaccess -------------------------------

raiserror(15339,-1,-1,'sp_revokedbaccess')
go
create procedure sp_revokedbaccess
	@name_in_db     sysname
as
    -- SETUP RUNTIME OPTIONS / DECLARE VARIABLES --
	set nocount on
	declare @uid        smallint,
            @ret        int

    -- CHECK PERMISSIONS --
    if (not is_member('db_accessadmin') = 1) and
       (not is_member('db_owner') = 1)
	begin
		dbcc auditevent (109, 4, 0, NULL, @name_in_db, NULL, NULL)
		raiserror(15247,-1,-1)
		return (1)
	end
	else
	begin
		dbcc auditevent (109, 4, 1, NULL, @name_in_db, NULL, NULL)
	end

    -- DISALLOW USER TRANSACTION --
	set implicit_transactions off
	IF (@@trancount > 0)
	begin
		raiserror(15002,-1,-1,'sp_revokedbaccess')
		return (1)
	end

    -- CHECK IF SYSUSER EXISTS --
    select @uid = uid from sysusers where name = @name_in_db
            and (issqluser = 1 or isntname = 1)         -- is droppable entity
            and (name <> 'guest' or hasdbaccess = 1)    -- special case guest
    if @uid is null
    begin
		raiserror(15008,-1,-1,@name_in_db)
        return (1)
    end

    -- CANNOT DROP DBO/INFORMATION_SCHEMA/public --
	if @uid in (1,0,3,4) --dbo, public, INFORMATION_SCHEMA, system_function_schema
	begin
		raiserror(15181,-1,-1)
		return (1)
	end

    -- CANNOT DROP GUEST IN MASTER/TEMPDB --
	if lower(@name_in_db) = 'guest' and db_id() in (1, 2)
	begin
		raiserror(15182,-1,-1)
		return(1)
	end

    -- CHECK IF USER OWNS ANYTHING --
    execute @ret = sp_MScheck_uid_owns_anything @uid
    if @ret <> 0
        return (1)

    -- REMOVE SYSPERMISSIONS ROWS AND DEPENDENT ALIASES --
    delete from syspermissions where grantee = @uid
    if exists (select altuid from sysusers where altuid = @uid and isaliased = 1)
    begin
        delete from sysusers where altuid = @uid and isaliased = 1
       	raiserror(15490,-1,-1)
    end

    -- DROP USER: SPECIAL HANDLING FOR GUEST (REMOVE HASDBACCESS) --
    if lower(@name_in_db) = 'guest'
        update sysusers set status = status & ~2, updatedate = getdate()
			where uid = user_id('guest')
    else
	begin
	    delete from sysusers where uid = @uid

		delete from sysproperties where type =  2 and id = 0 and
		smallid = @uid

	end
    -- RETURN SUCCESS/FAILURE --
    if @@error <> 0
        return (1)

    -- INVALIDATE CACHED PERMISSIONS --
    grant all to null

    raiserror(15491,-1,-1)
    return (0) -- sp_revokedbaccess
go

-- FOR BACKWARD COMPATIBILTY ONLY --
raiserror(15339,-1,-1,'sp_dropuser')
go
create procedure sp_dropuser
	@name_in_db     sysname     -- user name to drop
as
    -- SETUP RUNTIME OPTIONS / DECLARE VARIABLES --
	set nocount on
    declare @ret    int
    declare @targetName sysname
    -- LIMIT TO SQL/NT USERS (BCKWRD COMPAT ONLY!)
    if not exists (select * from sysusers where name = @name_in_db
                    and (isntuser = 1 or isntname = 0))
    begin
        raiserror(15008,-1,-1,@name_in_db)
        return (1)
    end
    -- store target name
    select  @targetName = (select sl.name from master..syslogins sl,sysusers su where su.name = @name_in_db and su.sid = sl.sid)

    -- DROP THE USER FROM THE DATABASE --
    execute @ret = sp_revokedbaccess @name_in_db
    if @ret <> 0
    begin
        -- AUDIT FAILED SECURITY CHECK
    dbcc auditevent (109, 2, 0, @targetName, @name_in_db, NULL, NULL)
        return (1)
    end

    -- AUDIT SUCCESSFUL SECURITY CHECK --
    dbcc auditevent (109, 2, 1, @targetName, @name_in_db, NULL, NULL)

    -- FINALIZATION: PRINT/RETURN SUCCESS --
    return (0) -- sp_dropuser
go

-------------------------------- sp_addalias ----------------------------------

raiserror(15339,-1,-1,'sp_addalias')
go
create procedure sp_addalias
    @loginame       sysname,    -- name of the pretender
    @name_in_db     sysname     -- user to whom to alias the login
as
    -- SETUP RUNTIME OPTIONS / DECLARE VARIABLES --
	set nocount on
	declare @sid        varbinary(85),
            @targuid    smallint,
            @newuid     smallint,
            @status     smallint,
            @dbname     sysname

    -- CHECK PERMISSIONS --
    if (not is_member('db_accessadmin') = 1) and
       (not is_member('db_owner') = 1)
	begin
		raiserror(15247,-1,-1)
		return (1)
	end

    -- DISALLOW USER TRANSACTION --
	set implicit_transactions off
	IF (@@trancount > 0)
	begin
		raiserror(15002,-1,-1,'sp_addalias')
		return (1)
	end

    -- VALIDATE LOGIN NAME (OBTAIN SID) --
    select @status = CASE WHEN charindex('\', @loginame) > 0 THEN 12 ELSE 0 END
    if @status = 0
        select @sid = suser_sid(@loginame)          -- sql user
    -- retry sql user as nt with dflt domain
    if @sid is null
    begin
        select @sid = get_sid('\U'+@loginame, NULL) -- nt user
        if @sid is null
        begin
            if @status = 0
                raiserror(15007,-1,-1,@loginame)
            else
                raiserror(15401,-1,-1,@loginame)
            return (1)
        end
        select @status = 12
    end
    -- PREVENT USE OF CERTAIN LOGINS --
	else if @sid = 0x1
	begin
		raiserror(15405, -1, -1, @loginame)
		return (1)
	end

    -- VALIDATE NAME-IN-DB (OBTAIN TARGET UID) --
    select @targuid = uid from sysusers where name = @name_in_db
                        and (issqluser = 1 or isntuser = 1)
						and uid NOT IN (3,4)	-- INFORMATION_SCHEMA, system_function_schema
    if @targuid is null
	begin
		raiserror(15008,-1,-1,@name_in_db)
		return (1)
	end

    -- ERROR IF LOGIN ALREADY IN DATABASE --
    if exists (select sid from sysusers where sid = @sid)
    begin

        -- ERROR IF ALREADY ALIASED --
        if exists (select sid from sysusers where sid = @sid and isaliased = 1)
	    begin
		    raiserror(15022,-1,-1)
		    return (1)
	    end

        -- ERROR: LOGIN ALREADY A USER --
        select @name_in_db = name, @dbname = db_name() from sysusers where sid = @sid
        raiserror(15278,-1,-1,@loginame,@name_in_db,@dbname)
        return (1)
    end

    -- ALTER NAME TO AVOID CONFLICTS IN NAME SPACE --
    select @loginame = '\' + @loginame
    if user_id(@loginame) is not null
    begin
	    raiserror(15023,-1,-1,@loginame)
        return (1)
    end

    -- OBTAIN NEW UID (RESERVE 1-4) --
    if user_name(5) IS NULL
        select @newuid = 5
    else
		select @newuid = min(uid)+1 from sysusers
            where uid >= 5 and uid < (16384 - 1)    -- stay in users range
                and user_name(uid+1) is null        -- uid not in use
    if @newuid is null
	begin
		raiserror(15065,-1,-1)
		return (1)
	end

    -- INSERT SYSUSERS ROW --
    insert into sysusers select
        @newuid, @status | 16, @loginame, @sid, 0x00,
                getdate(), getdate(), @targuid, NULL

    -- FINALIZATION: PRINT/RETURN SUCCESS --
    if @@error <> 0
        return (1)
    raiserror(15340,-1,-1)
    return (0) -- sp_addalias
go

------------------------------- sp_dropalias ----------------------------------

raiserror(15339,-1,-1,'sp_dropalias')
go
create procedure sp_dropalias
    @loginame   sysname     -- login who is currently aliased
as
    -- SETUP RUNTIME OPTIONS / DECLARE VARIABLES --
	set nocount on
	declare @sid        varbinary(85)

    -- CHECK PERMISSIONS --
    if (not is_member('db_accessadmin') = 1) and
       (not is_member('db_owner') = 1)
	begin
		raiserror(15247,-1,-1)
		return (1)
	end

    -- DISALLOW USER TRANSACTION --
	set implicit_transactions off
	IF (@@trancount > 0)
	begin
		raiserror(15002,-1,-1,'sp_dropalias')
		return (1)
	end

	-- VALIDATE LOGIN NAME (OBTAIN SID) --
	if charindex('\', @loginame) = 0
		select @sid = suser_sid(@loginame)          -- sql user
	if @sid is null
	begin
		select @sid = get_sid('\U'+@loginame, NULL) -- nt user
		if @sid is null
			begin
			-- Check directly for alias in sysusers
			SELECT @sid = sid FROM sysusers WHERE isaliased = 1 AND name = '\'+@loginame
			if @sid is null
			begin
				if charindex('\', @loginame) = 0
				raiserror(15007,-1,-1,@loginame)
				else
				raiserror(15401,-1,-1,@loginame)
				return (1)
			end
		end
	end

    -- DELETE THE ALIAS (IF ANY) --
    delete from sysusers where sid = @sid and isaliased = 1

    -- ERROR IF NO ROW DELETED --
    if @@rowcount = 0
    begin
		raiserror(15134,-1,-1)
		return (1)
    end

    -- FINALIZATION: PRINT/RETURN SUCCESS --
	raiserror(15492,-1,-1)
	return (0) -- sp_dropalias
go

--------------------------------- sp_addrole ----------------------------------

raiserror(15339,-1,-1,'sp_addrole')
go
create procedure sp_addrole
    @rolename   sysname,        -- name of new role
    @ownername  sysname = 'dbo' -- name of owner of new role
as
    -- SETUP RUNTIME OPTIONS / DECLARE VARIABLES --
	set nocount on
	declare @ret        int,    -- return value of sp call
            @uid        smallint,
            @owner      smallint

    -- CHECK PERMISSIONS --
    if (not is_member('db_securityadmin') = 1) and
       (not is_member('db_owner') = 1)
    begin
		dbcc auditevent (111, 1, 0, NULL, NULL, @rolename, NULL)
		raiserror(15247,-1,-1)
		return (1)
	end
	else
	begin
		dbcc auditevent (111, 1, 1, NULL, NULL, @rolename, NULL)
	end

    -- DISALLOW USER TRANSACTION --
	set implicit_transactions off
	if (@@trancount > 0)
	begin
		raiserror(15002,-1,-1,'sp_addrole')
		return (1)
	end

	    -- RESOLVE OWNER NAME --
    select @owner = uid from sysusers where name = @ownername
                    and isaliased = 0 AND uid NOT IN (0,3,4) --public/INFO_SCHEMA/etc can't own role
    if @owner is null
    begin
		raiserror(15008,-1,-1,@ownername)
		return (1)
    end

    -- VALIDATE ROLE NAME --
	execute @ret = sp_validname @rolename
	if @ret <> 0
		return (1)
	if (charindex('\', @rolename) > 0)
    begin
        raiserror(15006,-1,-1,@rolename)
        return (1)
    end

	if @rolename = 'sys'
		raiserror(15355,-1,-1)

    -- ERROR IF SYSUSERS NAME ALREADY EXISTS --
    if user_id(@rolename) is not null OR
		@rolename IN ('system_function_schema','INFORMATION_SCHEMA')
    begin
        if exists (select name from sysusers where issqlrole = 1 and name = @rolename)
    		raiserror(15363,-1,-1,@rolename)
        else
		    raiserror(15023,-1,-1,@rolename)

        return (1)
    end

    -- OBTAIN NEW ROLE UID (RESERVE 16384-16399) --
    if user_name(16400) IS NULL
        select @uid = 16400
    else
		select @uid = min(uid)+1 from sysusers
            where uid >= 16400 and uid < (32767 - 1)    -- stay in role range
                and user_name(uid+1) is null            -- uid not in use
    if @uid is null
	begin
		raiserror(15065,-1,-1)
		return (1)
	end

    -- INSERT THE ROW INTO SYSUSERS --
    insert into sysusers values
        (@uid, 0, @rolename, NULL, 0x00, getdate(), getdate(), @owner, NULL)

    -- FINALIZATION: PRINT/RETURN SUCCESS --
    if @@error <> 0
        return (1)
    raiserror(15424,-1,-1)
    return (0) -- sp_addrole
go

-- FOR BACKWARD COMPATIBLIITY --
raiserror(15339,-1,-1,'sp_addgroup')
go
create procedure sp_addgroup
    @grpname   sysname         -- name of new role
as
    declare @ret int
    execute @ret = sp_addrole @grpname
    return @ret
go

-------------------------------- sp_droprole ----------------------------------

raiserror(15339,-1,-1,'sp_droprole')
go
create procedure sp_droprole
    @rolename       sysname     -- role to be dropped
as
    -- SETUP RUNTIME OPTIONS / DECLARE VARIABLES --
	set nocount on
	declare @uid        smallint,
            @owner      sysname,
            @ret        int

    -- DISALLOW USER TRANSACTION --
	set implicit_transactions off
	if (@@trancount > 0)
	begin
		raiserror(15002,-1,-1,'sp_droprole')
		return (1)
	end

    -- ROLE NAME (OBTAIN OWNER FOR PERMISSIONS) --
    select @uid = uid, @owner = user_name(altuid) from sysusers
            where name = @rolename and issqlrole = 1

    -- CHECK PERMISSIONS --
    if (not is_member('db_securityadmin') = 1) and
       (not is_member('db_owner') = 1) and
       (@owner is NULL or not is_member(@owner) = 1)
    begin
		dbcc auditevent (111, 2, 0, NULL, NULL, @rolename, NULL)
		raiserror(15247,-1,-1)
		return (1)
	end
	else
	begin
		dbcc auditevent (111, 2, 1, NULL, NULL, @rolename, NULL)
	end

    -- ERROR IF ROLE NOT FOUND --
    if @uid is null
    begin
	    raiserror(15014,-1,-1,@rolename)
	    return (1)
    end

    -- ERROR IF FIXED ROLE or PUBLIC ROLE--
    if @uid < 16400	or @uid = 0
    begin
	    raiserror(15142,-1,-1, @rolename)
	    return (1)
    end

    -- ERROR IF ANYONE IS MEMBER OF ROLE (DISPLAYS MEMBERS) --
    if exists (select * from sysmembers where groupuid = @uid)
    begin
    	raiserror(15144,-1,-1)
    	select name = user_name(memberuid) from sysmembers where groupuid = @uid
    	return (1)
    end

    -- CHECK IF ROLE OWNS ANYTHING --
    execute @ret = sp_MScheck_uid_owns_anything @uid
    if @ret <> 0
        return (1)

    -- DROP SYSUSERS AND PROTECTION ENTRIES --
    delete from syspermissions where grantee = @uid
    delete from sysusers where uid = @uid

    -- FINALIZATION: PRINT/RETURN SUCCESS --
    if @@error <> 0
        return (1)
    raiserror(15493,-1,-1)
    return (0) -- sp_droprole
go


-- FOR BACKWARD COMPATIBLIITY --
raiserror(15339,-1,-1,'sp_dropgroup')
go
create procedure sp_dropgroup
    @rolename   sysname         -- name of role to drop
as
    declare @ret int
    execute @ret = sp_droprole @rolename
    return @ret
go


checkpoint
go

------------------------------- sp_addapprole ---------------------------------

raiserror(15339,-1,-1,'sp_addapprole')
go
create procedure sp_addapprole
    @rolename   sysname,        -- name of new app role
    @password   sysname         -- password for app role
as
    -- SETUP RUNTIME OPTIONS / DECLARE VARIABLES --
	set nocount on
	declare @ret        int,    -- return value of sp call
            @uid        smallint

	-- CHECK FOR NULL PASSWORD
	if (@password is null)
	begin
		raiserror(15034,-1,-1)
		return (1)
	end

    -- CHECK PERMISSIONS --
    if (not is_member('db_securityadmin') = 1) and
       (not is_member('db_owner') = 1)
	begin
		raiserror(15247,-1,-1)
		return (1)
	end

    -- DISALLOW USER TRANSACTION --
	set implicit_transactions off
	if (@@trancount > 0)
	begin
		raiserror(15002,-1,-1,'sp_addapprole')
		return (1)
	end

    -- VALIDATE APPROLE NAME --
	execute @ret = sp_validname @rolename
	if @ret <> 0
		return (1)
	if (charindex('\', @rolename) > 0)
    begin
        raiserror(15006,-1,-1,@rolename)
        return (1)
    end

	if @rolename = 'sys'
		raiserror(15355,-1,-1)

    -- ERROR IF SYSUSERS NAME ALREADY EXISTS --
    if user_id(@rolename) is not null OR
		@rolename IN ('system_function_schema','INFORMATION_SCHEMA')
    begin
        raiserror(15363,-1,-1,@rolename)
        return (1)
    end

    -- OBTAIN NEW APPROLE UID (RESERVE 1-4) --
    if user_name(5) IS NULL
        select @uid = 5
    else
		select @uid = min(uid)+1 from sysusers
            where uid >= 5 and uid < (16384 - 1)    -- stay in users range
                and user_name(uid+1) is null        -- uid not in use
    if @uid is null
	begin
		raiserror(15065,-1,-1)
		return (1)
	end

    -- INSERT THE ROW INTO SYSUSERS --
    insert into sysusers values
        (@uid, 32, @rolename, NULL, 0x00, getdate(),
                    getdate(), 1, convert(varbinary(256), pwdencrypt(@password)))

    -- FINALIZATION: PRINT/RETURN SUCCESS --
    if @@error <> 0
        return (1)
    raiserror(15425,-1,-1)
    return (0) -- sp_addapprole
go


----------------------- sp_approlepassword -------------------------------------------

raiserror(15339,-1,-1,'sp_approlepassword')
go
CREATE PROCEDURE sp_approlepassword
	@rolename		sysname,			-- name of app role
	@newpwd			sysname				-- new password
AS
	declare @roluid		smallint

	-- CHECK FOR NULL PASSWORD
	if (@newpwd is null)
	begin
		raiserror(15034,-1,-1)
		return (1)
	end

    -- CHECK PERMISSIONS --
    if (not is_member('db_securityadmin') = 1) and
       (not is_member('db_owner') = 1)
	begin
		dbcc auditevent (112, 1, 0, NULL, NULL, @rolename, NULL)
		raiserror(15247,-1,-1)
		return (1)
	end
	else
	begin
		dbcc auditevent (112, 1, 1, NULL, NULL, @rolename, NULL)
	end

    -- DISALLOW USER TRANSACTION --
	set implicit_transactions off
	if (@@trancount > 0)
	begin
		raiserror(15002, -1, -1, 'sp_approlepassword')
		return (1)
	end

    -- ROLE UID (OBTAIN OWNER FOR PERMISSIONS) --
	-- @pwd will be encrypted.
    select @roluid = uid from sysusers
                where name = @rolename and isapprole = 1

    -- ERROR IF APP ROLE NOT FOUND --
    if @roluid is null
    begin
	    raiserror(15014, -1, -1, @rolename)
	    return (1)
    end

	-- CHANGE PASSWORD --
	update sysusers set password = convert(varbinary(256), pwdencrypt(@newpwd)), updatedate = getdate()
			where uid = @roluid
	raiserror(15423,-1,-1,@rolename)

	return (0) -- sp_approlepassword
go


------------------------------- sp_setapprole ---------------------------------

raiserror(15339,-1,-1,'sp_setapprole')
go
create procedure sp_setapprole
    @rolename   sysname,        -- name app role
    @password   sysname,		-- password for app role
	@encrypt	varchar(10)	= 'none'	-- Encryption style ('none' | 'odbc')
as
    -- SETUP RUNTIME OPTIONS / DECLARE VARIABLES --
	set nocount on

    -- DISALLOW USER TRANSACTION --
	set implicit_transactions off
	if (@@trancount > 0)
	begin
		raiserror(15002,-1,-1,'sp_setapprole')
		return (1)
	end

	-- CHECK PARAMETER
	if (@rolename IS NULL)
    begin
        raiserror(15431,-1,-1)
        return (1)
    end

	-- VALIDATE ENCRYPTION
	declare @encrStyle int
	select @encrStyle = case lower(@encrypt) when 'none' then 0 when 'odbc' then 1 else null end
	if @encrStyle is null
	begin
        raiserror(15600,-1,-1,'sp_setapprole')
        return (1)
	end

    -- SP MUST BE CALLED AT ADHOC LEVEL --
    if (@@nestlevel > 1)
    begin
        raiserror(15422,-1,-1)
        return (1)
    end

    -- ACTIVATE APPROLE (THIS IS ONLY VALID FROM THIS SP!) --
    setuser @rolename, @password, @encrStyle

    -- RETURN SUCCESS/FAILURE --
    if (@@error <> 0)
        return (1)

	raiserror(15494,-1,-1,@rolename)

    return (0) -- sp_setapprole
go

------------------------------ sp_dropapprole ---------------------------------

raiserror(15339,-1,-1,'sp_dropapprole')
go
create procedure sp_dropapprole
    @rolename       sysname     -- role to be dropped
as
    -- SETUP RUNTIME OPTIONS / DECLARE VARIABLES --
	set nocount on
	declare @uid        smallint,
            @ret        int

    -- CHECK PERMISSIONS --
    if (not is_member('db_securityadmin') = 1) and
       (not is_member('db_owner') = 1)
	begin
		raiserror(15247,-1,-1)
		return (1)
	end

    -- DISALLOW USER TRANSACTION --
	set implicit_transactions off
	if (@@trancount > 0)
	begin
		raiserror(15002,-1,-1,'sp_dropapprole')
		return (1)
	end

    -- ERROR IF ROLE NOT FOUND --
    select @uid = uid from sysusers where name = @rolename and isapprole = 1
    if @uid is null
    begin
	    raiserror(15014,-1,-1,@rolename)
	    return (1)
    end

    -- CHECK IF ROLE OWNS ANYTHING --
    execute @ret = sp_MScheck_uid_owns_anything @uid
    if @ret <> 0
        return (1)

    -- DROP SYSUSERS AND PROTECTION ENTRIES --
    delete from syspermissions where grantee = @uid
    delete from sysusers where uid = @uid

    -- FINALIZATION: PRINT/RETURN SUCCESS --
    if @@error <> 0
        return (1)
    raiserror(15495,-1,-1)
    return (0) -- sp_dropapprole
go

------------------------------ sp_addrolemember -------------------------------

raiserror(15339,-1,-1,'sp_addrolemember')
go
CREATE PROCEDURE sp_addrolemember
	@rolename       sysname,
	@membername     sysname
AS
    -- SETUP RUNTIME OPTIONS / DECLARE VARIABLES --
	set nocount on
	declare @roluid     smallint,
            @owner      smallint,
            @memuid     smallint,
            @ret        int
    declare @ruidbyte   smallint,
            @ruidbit    smallint
	declare @proc		nvarchar(50)

    -- DISALLOW USER TRANSACTION --
	set implicit_transactions off
	if (@@trancount > 0)
	begin
		raiserror(15002,-1,-1,'sp_addrolemember')
		return (1)
	end

	--cannot change membership of public
	if @rolename = 'public'
	begin
		raiserror(15081, -1,-1)
		return(1)
	end

    -- ROLE NAME (OBTAIN OWNER FOR PERMISSIONS) --
    select @roluid = uid, @owner = altuid from sysusers
                where name = @rolename and issqlrole = 1

    -- ERROR IF ROLE NOT FOUND OR PUBLIC --
    if @roluid is null
    begin
	    raiserror(15014,-1,-1,@rolename)
	    return (1)
    end

    -- CHECK PERMISSIONS --
	-- Only member of db_owner can add members to db-fixed roles --
    if (not is_member('db_owner') = 1) and
       (not (@roluid < 16400 and is_member('db_owner') = 1)) and
       (not (@roluid >= 16400 and is_member('db_securityadmin') = 1)) and
       (not (@roluid >= 16400 and is_member(user_name(@owner)) = 1))
    begin
		dbcc auditevent (110, 1, 0, NULL, @membername, @rolename, NULL)
		raiserror(15247,-1,-1)
		return (1)
	end
	else
	begin
		dbcc auditevent (110, 1, 1, NULL, @membername, @rolename, NULL)
	end

    -- CHECK MEMBER NAME (ATTEMPT ADDING IMPLICIT ROW FOR NT NAME) --
    select @memuid = uid from sysusers where name = @membername and isaliased = 0
    if @memuid is null
    begin
        execute @ret = sp_MSadduser_implicit_ntlogin @membername
        select @memuid = uid from sysusers where name = @membername and isaliased = 0
    end
    if @memuid is null
    begin
		raiserror(15410, -1, -1, @membername)
		return (1)
    end

    -- CANNOT CHANGE MEMBERSHIP OF FIXED ROLES OR DBO --
    if @memuid in (1,0,3,4) --dbo, public, INFORMATION_SCHEMA, system_function_schema
		or (@memuid >= 16384 and @memuid < 16400)
    begin
        raiserror(15405, -1 ,-1, @membername)
        return (1)
    end

    -- CHECK FOR CIRCULAR MEMBERSHIPS --
    if is_userinrole(@rolename, @membername) = 1
    begin
		raiserror(15413, -1, -1)
		return (1)
    end

    -- SET ROLE BIT FOR THIS USER
    select @ruidbyte = ((@roluid - 16384) / 8) + 1
         , @ruidbit = power(2, @roluid & 7)
    update sysusers set roles = convert(varbinary(2048),
				substring(convert(binary(2048), roles), 1, @ruidbyte-1)
				+ convert(binary(1), (@ruidbit) | substring(convert(binary(2048), roles), @ruidbyte, 1))
				+ substring(convert(binary(2048), roles), @ruidbyte+1, 2048-@ruidbyte) ),
            updatedate = getdate()
        where uid = @memuid
    -- END ROLE BIT MANIPULATION

    -- INVALIDATE CACHED PERMISSIONS (MEMBERSHIP CHANGES PERMISSIONS) --
    select @ret = @@error   -- save success state
    grant all to null

    -- FINALIZATION: PRINT/RETURN SUCCESS --
    if @@error <> 0 or @ret <> 0
        return (1)

	raiserror(15488,-1,-1,@membername,@rolename)

    return (0) -- sp_addrolemember
go

checkpoint
go

----------------------------- sp_droprolemember -------------------------------

raiserror(15339,-1,-1,'sp_droprolemember')
go
CREATE PROCEDURE sp_droprolemember
	@rolename       sysname,
	@membername     sysname
AS
    -- SETUP RUNTIME OPTIONS / DECLARE VARIABLES --
	set nocount on
	declare @roluid     smallint,
            @owner      smallint,
            @memuid     smallint,
            @ret        int
    declare @ruidbyte   smallint,
            @ruidbit    smallint
	declare @proc		nvarchar(50)

    -- DISALLOW USER TRANSACTION --
	set implicit_transactions off
	if (@@trancount > 0)
	begin
		raiserror(15002,-1,-1,'sp_droprolemember')
		return (1)
	end

	--cannot change membership of public
	if @rolename = 'public'
	begin
		raiserror(15081, -1,-1)
		return(1)
	end

	    -- ROLE NAME (OBTAIN OWNER FOR PERMISSIONS) --
    select @roluid = uid, @owner = altuid from sysusers
                where name = @rolename and issqlrole = 1

    -- ERROR IF ROLE NOT FOUND OR PUBLIC --
    if @roluid is null
    begin
	    raiserror(15409,-1,-1,@rolename)
	    return (1)
    end

    -- CHECK PERMISSIONS --
	-- Only member of db_owner can drop members from db-fixed roles --
    if (not is_member('db_owner') = 1) and
       (not (@roluid < 16400 and is_member('db_owner') = 1)) and
       (not (@roluid >= 16400 and is_member('db_securityadmin') = 1)) and
       (not (@roluid >= 16400 and is_member(user_name(@owner)) = 1))
    begin
		dbcc auditevent (110, 2, 0, NULL, @membername, @rolename, NULL)
		raiserror(15247,-1,-1)
		return (1)
	end
	else
	begin
		dbcc auditevent (110, 2, 1, NULL, @membername, @rolename, NULL)
	end

    -- ERROR IF MEMBER NAME NOT NULL AND NOT FOUND --
    select @memuid = uid from sysusers where name = @membername and isaliased = 0
    if @memuid is null
    begin
		raiserror(15410, -1, -1, @membername)
		return (1)
    end

    -- CANNOT CHANGE MEMBERSHIP OF FIXED ROLES OR DBO --
    if @membername in ('dbo','public') or (@memuid >= 16384 and @memuid < 16400)
    begin
        raiserror(15405, -1 ,-1, @membername)
        return (1)
    end

    -- CLEAR ROLE BIT FOR THIS USER
    select @ruidbyte = ((@roluid - 16384) / 8) + 1
         , @ruidbit = power(2, @roluid & 7)
    update sysusers set roles = convert(varbinary(2048),
				substring(convert(binary(2048), roles), 1, @ruidbyte-1)
				+ convert(binary(1), (~@ruidbit) & substring(convert(binary(2048), roles), @ruidbyte, 1))
				+ substring(convert(binary(2048), roles), @ruidbyte+1, 2048-@ruidbyte) ),
            updatedate = getdate()
        where uid = @memuid
    -- END ROLE BIT MANIPULATION

    -- INVALIDATE CACHED PERMISSIONS (MEMBERSHIP CHANGES PERMISSIONS) --
    select @ret = @@error   -- save success state
    grant all to null

    -- FINALIZATION: PRINT/RETURN SUCCESS --
    if @@error <> 0 or @ret <> 0
        return (1)

	raiserror(15489,-1,-1,@membername,@rolename)

    return (0) -- sp_droprolemember
go

------------------------------- sp_changegroup --------------------------------

raiserror(15339,-1,-1,'sp_changegroup')
go
create procedure sp_changegroup
    @grpname    sysname,    -- name of new role
    @username   sysname     -- user to switch
as
    -- SETUP RUNTIME OPTIONS / DECLARE VARIABLES --
	set nocount on
	declare @uid        smallint,
			@ruid        smallint,
            @cnt        int,
            @ret        int,
            @oldgrp     sysname

     select @ruid = uid from sysusers
                where name = @grpname and issqlrole = 1

    -- ERROR IF GROUP NOT FOUND --
    if @ruid is null
    begin
	    raiserror(15014,-1,-1,@grpname)
	    return (1)
    end

    -- LIMIT TO USERS WITH ACCESS (BACKWARD COMPAT ONLY!) --
    select @uid = uid from sysusers where name = @username
                and (issqluser = 1 or isntuser = 1) and hasdbaccess = 1
    if @uid is null
	begin
		raiserror(15008,-1,-1,@username)
		return (1)
	end

    -- ONLY VALID IF USER IS MEMBER OF NO MORE THAN ONE GROUP --
    select @cnt = count(*) from sysmembers where memberuid = @uid
    if @cnt > 1
    begin
	    raiserror(15415, -1, -1)
	    return (1)
    end

	-- AUDIT SUCCESSFUL SECURITY CHECK --
	dbcc auditevent (110, 3, 1, NULL, @username, @grpname, NULL)

    -- REMOVE MEMBERSHIP IF NEEDED --
	if (@cnt = 1)
	begin
        select @oldgrp = user_name(groupuid) from sysmembers where memberuid = @uid
        execute @ret = sp_droprolemember @oldgrp, @username
        if @ret <> 0
            return (1)
	end

    -- ADD MEMBERSHIP --
    if (@grpname <> 'public')
    begin
        execute @ret = sp_addrolemember @grpname, @username
        if @ret <> 0
            return (1)
    end

    -- FINALIZATION: RETURN SUCCESS --
    raiserror(15496,-1,-1)

	return (0) -- sp_changegroup
go

---------------------------- sp_change_users_login ----------------------------

raiserror(15339,-1,-1,'sp_change_users_login')
go
CREATE PROCEDURE sp_change_users_login
    @Action               varchar(10)       -- REPORT / UPDATE_ONE / AUTO_FIX
   ,@UserNamePattern      sysname  = Null
   ,@LoginName            sysname  = Null
   ,@Password			  sysname  = Null
AS
    -- SETUP RUNTIME OPTIONS / DECLARE VARIABLES --
	set nocount on
	declare @exec_stmt nvarchar(430)

	declare @ret            int,
            @FixMode        char(5),
            @cfixesupdate   int,        -- count of fixes by update
            @cfixesaddlogin int,        -- count of fixes by sp_addlogin
            @dbname         sysname,
            @loginsid       varbinary(85),
            @110name        sysname

    -- SET INITIAL VALUES --
    select  @dbname         = db_name(),
            @cfixesupdate   = 0,
            @cfixesaddlogin = 0

    -- ERROR IF IN USER TRANSACTION --
    if @@trancount > 0
    begin
        raiserror(15289,-1,-1)
        return (1)
    end

    -- INVALIDATE USE OF SPECIAL LOGIN/USER NAMES --
    if suser_sid(@LoginName) = 0x1	-- 'sa'
    begin
        raiserror(15287,-1,-1,@LoginName)
        return (1)
    end
    if user_id(@UserNamePattern) in (1,0,3,4) --dbo, public, INFORMATION_SCHEMA, system_function_schema
    begin
        raiserror(15287,-1,-1,@UserNamePattern)
        return (1)
    end

    -- HANDLE REPORT --
    if upper(@Action) = 'REPORT'
    begin

        -- VALIDATE PARAMS --
        if @UserNamePattern IS NOT Null or @LoginName IS NOT Null
        begin
            raiserror(15290,-1,-1,@Action,@UserNamePattern,@LoginName)
            return (1)
        end

        -- GENERATE REPORT --
        select UserName = name, UserSID = sid from sysusers
            where issqluser = 1 and (sid is not null and sid <> 0x0)
                    and suser_sname(sid) is null
            order by name
        return (0)
    end

    -- HANDLE UPDATE_ONE --
    if upper(@Action) = 'UPDATE_ONE'
    begin

        -- CHECK PERMISSIONS --
        if not is_member('db_owner') = 1
        begin
            raiserror(15247,-1,-1)
            return (1)
        end

        -- ERROR IF PARAMS NULL --
        if @UserNamePattern IS Null or @LoginName IS Null
        begin
            raiserror(15290,-1,-1,@Action,@UserNamePattern,@LoginName)
            return (1)
        end

        -- VALIDATE PARAMS --
        -- Can ONLY remap SQL Users to SQL Logins!  Should be no need
        --  for re-mapping NT logins, and if you try, you'll mess up
        --  the user status bits! 
        if not exists (select name from sysusers where
                name = @UserNamePattern             -- match user name
            and issqluser = 1)                      -- must be sql user
        begin
            raiserror(15291,-1,-1,'User',@UserNamePattern)
            return (1)
        end
        select @loginsid = sid from master.dbo.syslogins where
                loginname = @LoginName              -- match login name
            and isntname = 0                        -- cannot use nt logins
        if @loginsid is null
        begin
            raiserror(15291,-1,-1,'Login',@LoginName)
            return (1)
        end

        -- ERROR IF SID ALREADY IN USE IN DATABASE --
        if exists (select sid from sysusers where sid = @loginsid
                    and name <> @UserNamePattern)
        begin
		    raiserror(15063,-1,-1)
		    return (1)
        end

        -- CHANGE THE USERS LOGIN (SID) --
        update sysusers set sid = @loginsid, updatedate = getdate()
                where name = @UserNamePattern and issqluser = 1
                and sid <> @loginsid

        -- FINALIZATION: REPORT (ONLY IF NOT SUCCESSFUL) AND EXIT --
        if @@error <> 0 or @@rowcount <> 1
            raiserror(15295,-1,-1, 0)
        return (0)
    end

    -- ERROR IF NOT AUTO_FIX --
    if upper(@Action) <> 'AUTO_FIX'
    begin
        raiserror(15286,-1,-1,@Action)
        return (1)
    end

    -- HANDLE AUTO_FIX --
    -- CHECK PERMISSIONS --
    if not is_srvrolemember('sysadmin') = 1
    begin
        raiserror(15247,-1,-1)
        return (1)
    end

    -- VALIDATE PARAMS --
    if @UserNamePattern IS Null or @LoginName IS NOT Null
    begin
        raiserror(15290,-1,-1,@Action,@UserNamePattern,@LoginName)
        return (1)
    end

    -- LOOP THRU ORPHANED USERS --
	select @exec_stmt = 'DECLARE ms_crs_110_Users cursor global for
            select name from sysusers
            where name = N' + quotename( @UserNamePattern , '''')+ '
                and issqluser = 1 and suser_sname(sid) is null'
    EXECUTE (@exec_stmt)
    OPEN ms_crs_110_Users

    WHILE (110=110)
    begin
        FETCH next from ms_crs_110_Users into @110name
        if (@@fetch_status <> 0)
        begin
            DEALLOCATE ms_crs_110_Users
            BREAK
        end

        -- IS NAME ALREADY IN USE? --
        -- if suser_sid(@110name) is null
		if not exists(select * from master.dbo.syslogins where loginname = @110name)
        begin

		   -- VALIDATE PARAMS --
			if @Password IS Null
			begin
				raiserror(15290,-1,-1,@Action,@UserNamePattern,@LoginName)
				return (1)
			end

            -- ADD LOGIN --
            execute @ret = sp_addlogin @110name, @Password, @dbname
            if @ret <> 0 or suser_sid(@110name) is null
            begin
                raiserror(15497,16,1,@110name)
                deallocate ms_crs_110_Users
                return (1)
            end
            select @FixMode = '1AddL'
            raiserror(15293,-1,-1,@110name)
        end
        ELSE
        begin
            Select @FixMode = '2UpdU'
            Raiserror(15292,-1,-1,@110name)
        end

        -- REPORT ERROR & CONTINUE IF DUPLICATE SID IN DB --
        select @loginsid = suser_sid(@110name)
        if user_sid(@loginsid) is not null
        begin
            raiserror(15331,-1,-1,@110name)
            CONTINUE
        end

        -- UPDATE SYSUSERS ROW --
        update sysusers set sid = @loginsid, updatedate = getdate(), status = (status & ~1) | 2 where name = @110name
        if @@error <> 0
        begin
            raiserror(15498,17,127)
            deallocate ms_crs_110_Users
            return (1)
        end


        if @FixMode = '1AddL'
            Select @cfixesaddlogin = @cfixesaddlogin + 1
        else
            Select @cfixesupdate = @cfixesupdate + 1
    end -- loop 110

    -- REPORT AND RETURN SUCCESS --
    raiserror(15295,-1,-1,@cfixesupdate)
    raiserror(15294,-1,-1,@cfixesaddlogin)
    return (0) -- sp_change_users_login
go

------------------------------ sp_changedbowner -------------------------------

raiserror(15339,-1,-1,'sp_changedbowner')
go
create procedure sp_changedbowner
    @loginame       sysname,		-- login to become dbo
    @map            varchar(5) = NULL	-- True to map aliases, else drop
as
    -- SETUP RUNTIME OPTIONS / DECLARE VARIABLES --
	set nocount on
	declare @ret        int,
            @newsid     varbinary(85),
            @status     smallint

    -- CHECK PERMISSIONS (Note: All sysadmins are dbo) --
	-- See Bug Shiloh 362190 ---
    if not (is_srvrolemember('sysadmin') = 1)
    begin
        raiserror(15247,-1,-1)
        return(1)
    end

    -- CANT CHANGE OWNER OF MASTER/MODEL/TEMPDB --
    if db_name() in ('master', 'model', 'tempdb')
    begin
        raiserror(15109,-1,-1)
        return(1)
    end

    -- CHECK LOGIN NAME IS VALID (NT/SQL USER ONLY!) --
    select @newsid = sid, @status = 2 from master.dbo.syslogins
                    where loginname = @loginame and isntname = 0
    if @newsid is null
        select @status = 14, @newsid = get_sid('\U'+@loginame, NULL)
    if @newsid is null
    begin
        raiserror(15007,-1,-1,@loginame)
        return (1)
    end

    -- CHECK IF LOGIN ALREADY ALIASED IN DB --
    if exists (select sid from sysusers where isaliased = 1 and sid = @newsid)
    begin
        raiserror(15111,-1,-1)
        return (1)
    end

    -- CHECK IF LOGIN ALREADY KNOWN TO DATABASE --
    if exists (select sid from sysusers where sid = @newsid and uid <> 1)
    begin
        raiserror(15110,-1,-1)
        return (1)
    end


    -- MAKE THE FOLLOWING REMOVE/REMAP/DELETES ATOMIC --
    begin transaction

    -- REMAP DBO TO NEW SID --
    update sysusers set sid = @newsid, status = @status, updatedate = getdate()
            where name = 'dbo'

    -- REMOVE OTHER DBO-ALIASES IF REMAPPING NOT REQUESTED --
    if lower(@map) <> 'true'
    begin
        delete from sysusers where isaliased = 1 and altuid = user_id('dbo')
        raiserror(15500,-1,-1)
    end
    else
        raiserror(15499,-1,-1)     -- nothing to do to <remap>

    -- REFLECT NEW OWNER IN SYSDATABASES --
    update master.dbo.sysdatabases set sid = @newsid where dbid = db_id()
    commit transaction

    -- CHECKPOINT DATABASE TO FORCE CHANGES TO IN-MEMORY STRUCTURE --
    checkpoint
    raiserror(15501,-1,-1)
	grant all to null
    return (0) -- sp_changedbowner
go

------------------------- sp_check_removable_sysusers -------------------------

raiserror(15339,-1,-1,'sp_check_removable_sysusers')
go
-----------------------------------------------------
-- NOTE: FOR INTERNAL USE ONLY (sp_certify_removable)
--      DO NOT DOCUMENT OR USE!
-----------------------------------------------------
create procedure sp_check_removable_sysusers
    @autofix    varchar(4)      -- true or other
as
    -- CHECK FOR DATABASE OWNED BY SQL USER --
    if exists (select name from sysusers where name = 'dbo' and issqluser = 1 and sid <> suser_sid('sa'))
    begin
        if @autofix <> 'auto'
        begin
			raiserror(15258,-1,-1)
			return(1)
        end

        -- MAKE SA THE DBO --
		raiserror(15502,-1,-1)
        update sysusers set sid = suser_sid('sa'), status = 2, updatedate = getdate()
                where name = 'dbo'
    end

    -- CHECK FOR PERMISSIONS GRANTED TO or BY SQL USERS --
    if exists (select grantee from syspermissions where grantee in
                (select uid from sysusers u where issqluser = 1 and u.uid > 4))
	OR exists (select grantor from syspermissions where grantor in
                (select uid from sysusers u where issqluser = 1 and u.uid > 4))
    begin
        if @autofix = 'auto'
            PRINT 'CANNOT AUTO-AUTOFIX GRANT-WITH-GRANT CHAINS'
		raiserror(15053,-1,-1)
		return(1)
    end

    -- CHECK FOR OBJECTS OWNED BY SQL USERS --
    if exists (select uid from sysobjects where uid in
                (select uid from sysusers u where issqluser = 1 and u.uid > 4))
    begin
        if @autofix <> 'auto'
        begin
			raiserror(15053,-1,-1)
			return(1)
        end

        -- ASSIGN DBO AS OWNER OF OTHER OBJECTS (MAY FAIL WITH DUPL!) --
        raiserror(15503,-1,-1)
        update sysobjects set uid = 1 where uid in
                (select uid from sysusers u where issqluser = 1 and u.uid > 4)
        if @@error <> 0
            return (1)
    end

    -- CHECK FOR TYPES OWNED BY SQL USERS --
    if exists (select uid from systypes where uid in
                (select uid from sysusers u where issqluser = 1 and u.uid > 4))
    begin
        if @autofix <> 'auto'
        begin
			raiserror(15053,-1,-1)
			return(1)
        end

        -- ASSIGN DBO AS OWNER OF TYPES --
        raiserror(15503,-1,-1)
        update systypes set uid = 1 where uid in
                (select uid from sysusers u where issqluser = 1 and u.uid > 4)
    end

    -- CHECK FOR ROLES OWNED BY SQL USERS --
    if exists (select altuid from sysusers where (issqlrole = 1 or isapprole = 1) and
        altuid in (select uid from sysusers u where u.issqluser = 1 and u.uid > 4))
    begin
        if @autofix <> 'auto'
        begin
			raiserror(15053,-1,-1)
			return(1)
        end

        -- ASSIGN DBO AS OWNER OF TYPES --
        raiserror(15503,-1,-1)
        update sysusers set altuid = 1, updatedate = getdate()
            where (issqlrole = 1 or isapprole = 1) and
            altuid in (select uid from sysusers u where u.issqluser = 1 and u.uid > 4)
    end

    -- CHECK FOR SQL LOGINS AS USERS --
    if exists (select uid from sysusers where issqluser = 1 and uid > 4)
    begin
        if @autofix <> 'auto'
        begin
			raiserror(15254,-1,-1)
			return(1)
        end

        -- DELETE SQL USERS AND DEPENDENT ALIASES --
        raiserror(15504,-1,-1)
        delete from sysusers where issqluser = 1 and uid > 4
        delete from sysusers where isaliased = 1 and user_name(altuid) is null
    end

    -- CHECK FOR SQL LOGINS ALIASED --
    if exists (select uid from sysusers where isaliased = 1 and isntname = 0)
    begin
        if @autofix <> 'auto'
        begin
			raiserror(15254,-1,-1)
			return(1)
        end

        -- DELETE ALIASED SQL USERS --
        raiserror(15504,-1,-1)
        delete from sysusers where isaliased = 1 and isntname = 0
    end

	-- Success
	return 0
go

checkpoint
go

---------------------------- sp_changeobjectowner -----------------------------

raiserror(15339,-1,-1,'sp_changeobjectowner')
go
create procedure sp_changeobjectowner
	@objname	nvarchar(517),		-- may be "[owner].[object]"
	@newowner	sysname				-- must be entry from sysusers
as
	Set nocount      on
	Set ansi_padding on
	declare	@objid		int,
			@newuid		smallint

	-- CHECK PERMISSIONS: Because changing owner changes both schema and
	--	permissions, the caller must be one of:
	-- (1) db_owner
	-- (2) db_ddladmin AND db_securityadmin
    if (is_member('db_owner') = 0) and
		(is_member('db_securityadmin') = 0 OR is_member('db_ddladmin') = 0)
    begin
		raiserror(15247,-1,-1)
		return (1)
    end

	-- RESOLVE OBJECT NAME (CANNOT BE A CHILD OBJECT: TRIGGER/CONSTRAINT) --
	select @objid = object_id(@objname, 'local')
	if (@objid is null) OR
		(select parent_obj from sysobjects where id = @objid) <> 0 OR
		ObjectProperty(@objid, 'IsMSShipped') = 1 OR
		ObjectProperty(@objid, 'IsSystemTable') = 1 OR
		ObjectProperty(@objid, 'ownerid') in (0,3,4) OR --public, INFORMATION_SCHEMA, system_function_schema
		-- Check for Dependencies: No RENAME or CHANGEOWNER of OBJECT when exists:
		EXISTS (SELECT * FROM sysdepends d WHERE
			d.depid = @objid		-- A dependency on this object
			AND d.deptype > 0		-- that is enforced
			AND @objid <> d.id		-- that isn't a self-reference (self-references don't use object name)
			AND @objid <>			-- And isn't a reference from a child object (also don't use object name)
				(SELECT o.parent_obj FROM sysobjects o WHERE o.id = d.id)
			)
	begin
		-- OBJECT NOT FOUND
		raiserror(15001,-1,-1,@objname)
		return 1
	end

	-- RESOLVE NEW OWNER NAME (ATTEMPT ADDING IMPLICIT ROW FOR NT NAME) --
    --  Disallow aliases, and public cannot own objects --
	select @newuid = uid from sysusers where name = @newowner
                            and isaliased = 0
							and uid not in (0,3,4) --public, INFORMATION_SCHEMA, system_function_schema
    if @newuid is null
    begin
        execute sp_MSadduser_implicit_ntlogin @newowner
        select @newuid = uid from sysusers where name = @newowner
                            and isaliased = 0 and name <> 'public'
    end
    if @newuid is null
    begin
		raiserror(15410, -1, -1, @newowner)
		return (1)
    end

	-- CHECK IF CHANGING OWNER OF OBJECT OR ITS CHILDREN WOULD PRODUCE A DUPLICATE
	if exists (select * from sysobjects where uid = @newuid and name in
		(select name from sysobjects where id = @objid OR parent_obj = @objid))
	begin
		raiserror(15505,-1,-1,@objname,@newowner)
		return (1)
	end


	-- DO THE OWNER TRANSFER (WITH A WARNING) --
	raiserror(15477,-1,-1)
	begin transaction
	-- Locks Object and increments schema_ver.
	DBCC LockObjectSchema(@objname)
	-- drop permissions (they'll be incorrect with new owner) --
	delete syspermissions where id = @objid
	update sysobjects set uid = @newuid where id = @objid
	update sysobjects set uid = @newuid where parent_obj = @objid
	commit transaction

	return 0	-- sp_changeobjectowner
go

-- GRANT PUBLIC ACCESS (SP'S DO INTERNAL PERMISSIONS CHECKS) --
grant execute on sp_grantdbaccess to public
grant execute on sp_revokedbaccess to public
grant execute on sp_adduser to public
grant execute on sp_dropuser to public
grant execute on sp_addalias to public
grant execute on sp_dropalias to public
grant execute on sp_addrole to public
grant execute on sp_droprole to public
grant execute on sp_dropgroup to public
grant execute on sp_addgroup to public
grant execute on sp_dropgroup to public
grant execute on sp_addapprole to public
grant execute on sp_approlepassword to public
grant execute on sp_setapprole to public
grant execute on sp_dropapprole to public
grant execute on sp_addrolemember to public
grant execute on sp_droprolemember to public
grant execute on sp_changegroup to public
grant execute on sp_change_users_login to public
grant execute on sp_changedbowner to public
grant execute on sp_changeobjectowner to public
go
/**********************  END DATABASE-ACCESS-SECURITY ************************/

/******************************************************************************
************************  SECURITY-HELP-PROCEDURES  ***************************
******************************************************************************/
checkpoint
go
if object_id('sp_helpsrvrole','P') IS NOT NULL
	drop procedure sp_helpsrvrole
if object_id('sp_srvrolepermission','P') IS NOT NULL
	drop procedure sp_srvrolepermission
if object_id('sp_helpsrvrolemember','P') IS NOT NULL
	drop procedure sp_helpsrvrolemember
if object_id('sp_helpdbfixedrole','P') IS NOT NULL
	drop procedure sp_helpdbfixedrole
if object_id('sp_dbfixedrolepermission','P') IS NOT NULL
	drop procedure sp_dbfixedrolepermission
if object_id('sp_helprolemember','P') IS NOT NULL
	drop procedure sp_helprolemember
if object_id('sp_helprole','P') IS NOT NULL
	drop procedure sp_helprole
if object_id('sp_helpntgroup','P') IS NOT NULL
	drop procedure sp_helpntgroup
if object_id('xp_logininfo','P') IS NOT NULL
	drop procedure xp_logininfo
go


----------------------- sp_helpsrvrole ----------------------------------------

raiserror(15339,-1,-1,'sp_helpsrvrole')
go
CREATE PROCEDURE sp_helpsrvrole
	@srvrolename		sysname = NULL
AS
	if @srvrolename is not null
	begin
		-- VALIDATE GIVEN NAME
		if not exists (select * from master.dbo.spt_values
				where name = @srvrolename and low = 0 and type = 'SRV')
		begin
			raiserror(15412, -1, -1, @srvrolename)
			return (1)
		end

		-- RESULT SET FOR SINGLE SERVER-ROLE
		select 'ServerRole' = v1.name, 'Description' = v2.name
			from master.dbo.spt_values v1, master.dbo.spt_values v2
			where v1.name = @srvrolename and
				  v1.low = 0 and
				  v1.type = 'SRV' and
				  v2.low = -1 and
				  v2.type = 'SRV' and
				  v1.number = v2.number
	end
	else
	begin
		-- RESULT SET FOR ALL SERVER-ROLES
		select 'ServerRole' = v1.name, 'Description' = v2.name
			from master.dbo.spt_values v1, master.dbo.spt_values v2
			where v1.low = 0 and
				  v1.type = 'SRV' and
				  v2.low = -1 and
				  v2.type = 'SRV' and
				  v1.number = v2.number
	end

    return (0) -- sp_helpsrvrole
go

----------------------- sp_srvrolepermission ----------------------------------

raiserror(15339,-1,-1,'sp_srvrolepermission')
go
CREATE PROCEDURE sp_srvrolepermission
	@srvrolename       sysname = NULL
AS
	if @srvrolename is not null
	begin
		-- VALIDATE GIVEN NAME
		if not exists (select * from master.dbo.spt_values
				where name = @srvrolename and low = 0 and type = 'SRV')
		begin
			raiserror(15412, -1, -1, @srvrolename)
			return (1)
		end

		-- RESULT SET FOR SINGLE SERVER-ROLE
		select distinct 'ServerRole' = v1.name, 'Permission' = v2.name
			from master.dbo.spt_values v1, master.dbo.spt_values v2
			where v1.name = @srvrolename and
				  v1.low = 0 and
				  v1.type = 'SRV' and
				  ((v2.type = 'SRV' and ((v1.number = 16 and v1.number <= v2.number) or (v1.number <> 16 and v1.number = v2.number))) or
				  (v2.type = 'DBR' and v1.number = 16 and not (v2.name like N'No %'))) and
				  v2.low > 0
			order by v1.name, v2.name
	end
	else
	begin
		-- RESULT SET FOR ALL SERVER-ROLES
		select distinct 'ServerRole' = v1.name, 'Permission' = v2.name
			from master.dbo.spt_values v1, master.dbo.spt_values v2
			where v1.low = 0 and
				  v1.type = 'SRV' and
				  ((v2.type = 'SRV' and ((v1.number = 16 and v1.number <= v2.number) or (v1.number <> 16 and v1.number = v2.number))) or
				  (v2.type = 'DBR' and v1.number = 16 and not (v2.name like N'No %'))) and
				  v2.low > 0
			order by v1.name, v2.name
	end

    return (0) -- sp_srvrolepermission
go


----------------------- sp_helpsrvrolemember ----------------------------------

raiserror(15339,-1,-1,'sp_helpsrvrolemember')
go
CREATE PROCEDURE sp_helpsrvrolemember
	@srvrolename       sysname = NULL
AS
	if @srvrolename is not null
	begin
		-- VALIDATE GIVEN NAME
		if not exists (select * from master.dbo.spt_values
				where name = @srvrolename and low = 0 and type = 'SRV')
		begin
			raiserror(15412, -1, -1, @srvrolename)
			return (1)
		end

		-- RESULT SET FOR SINGLE SERVER-ROLE
		select 'ServerRole' = spv.name, 'MemberName' = lgn.name, 'MemberSID' = lgn.sid
			from master.dbo.spt_values spv, master.dbo.sysxlogins lgn
			where spv.name = @srvrolename and
				  spv.low = 0 and
				  spv.type = 'SRV' and
				  lgn.srvid IS NULL and
				  spv.number & lgn.xstatus = spv.number
	end
	else
	begin
		-- RESULT SET FOR ALL SERVER-ROLES
		select 'ServerRole' = spv.name, 'MemberName' = lgn.name, 'MemberSID' = lgn.sid
			from master.dbo.spt_values spv, master.dbo.sysxlogins lgn
			where spv.low = 0 and
				  spv.type = 'SRV' and
				  lgn.srvid IS NULL and
				  spv.number & lgn.xstatus = spv.number
	end

    return (0) -- sp_helpsrvrolemember
go

----------------------- sp_helpdbfixedrole ----------------------------------------

raiserror(15339,-1,-1,'sp_helpdbfixedrole')
go
CREATE PROCEDURE sp_helpdbfixedrole
	@rolename		sysname = NULL
AS
	if @rolename is not null
	begin
		-- VALIDATE GIVEN NAME
		if not exists (select * from sysusers where name = @rolename
						and uid >= 16384 and uid <= 16393)
		begin
			raiserror(15412, -1, -1, @rolename)
			return (1)
		end

		-- RESULT SET FOR SINGLE FIXED-ROLE
		select 'DbFixedRole' = usr.name, 'Description' = spv.name
			from sysusers usr, master.dbo.spt_values spv
			where usr.name = @rolename and
				  usr.uid >= 16384 and
				  usr.uid <= 16393 and
				  usr.uid = spv.number and
				  spv.type = 'DBR' and
				  spv.low = -1
	end
	else
	begin
		-- RESULT SET FOR ALL FIXED-ROLES
		select 'DbFixedRole' = usr.name, 'Description' = spv.name
			from sysusers usr, master.dbo.spt_values spv
			where usr.uid >= 16384 and
				  usr.uid <= 16393 and
				  usr.uid = spv.number and
				  spv.type = 'DBR' and
				  spv.low = -1
	end

    return (0) -- sp_helpdbfixedrole
go


----------------------- sp_dbfixedrolepermission ------------------------------

raiserror(15339,-1,-1,'sp_dbfixedrolepermission')
go
CREATE PROCEDURE sp_dbfixedrolepermission
	@rolename       sysname = NULL
AS
	if @rolename is not null
	begin
		-- VALIDATE GIVEN NAME
		if not exists (select * from sysusers where name = @rolename
						and uid >= 16384 and uid <= 16393)
		begin
			raiserror(15412, -1, -1, @rolename)
			return (1)
		end

		-- RESULT SET FOR SINGLE FIXED-ROLE
		select DISTINCT 'DbFixedRole' = usr.name, 'Permission' = spv.name
			from sysusers usr, master.dbo.spt_values spv
			where usr.name = @rolename and
				  usr.uid >= 16384 and
				  usr.uid <= 16393 and
				  spv.type = 'DBR' and
				  ((usr.uid = 16384 and spv.number >= 16384 and spv.number < 16392) or (usr.uid <> 16384 and usr.uid = spv.number)) and
				  spv.low > 0
			order by usr.name, spv.name
	end
	else
	begin
		-- RESULT SET FOR ALL FIXED-ROLES
		select DISTINCT 'DbFixedRole' = usr.name, 'Permission' = spv.name
			from sysusers usr, master.dbo.spt_values spv
			where usr.uid >= 16384 and
				  usr.uid <= 16393 and
				  spv.type = 'DBR' and
				  ((usr.uid = 16384 and spv.number >= 16384 and spv.number < 16392) or (usr.uid <> 16384 and usr.uid = spv.number)) and
				  spv.low > 0
			order by usr.name, spv.name
	end

    return (0) -- sp_dbfixedrolepermission
go


----------------------- sp_helprolemember -------------------------------------

raiserror(15339,-1,-1,'sp_helprolemember')
go
CREATE PROCEDURE sp_helprolemember
	@rolename       sysname = NULL
AS
	if @rolename is not null
	begin
		-- VALIDATE GIVEN NAME
		if not exists (select * from sysusers where name = @rolename and issqlrole = 1)
		begin
			raiserror(15409, -1, -1, @rolename)
			return (1)
		end

		-- RESULT SET FOR SINGLE ROLE
		select DbRole = g.name, MemberName = u.name, MemberSID = u.sid
			from sysusers u, sysusers g, sysmembers m
			where g.name = @rolename
				and g.uid = m.groupuid
				and g.issqlrole = 1
				and u.uid = m.memberuid
			order by 1, 2
	end
	else
	begin
		-- RESULT SET FOR ALL ROLES
		select DbRole = g.name, MemberName = u.name, MemberSID = u.sid
			from sysusers u, sysusers g, sysmembers m
			where   g.uid = m.groupuid
				and g.issqlrole = 1
				and u.uid = m.memberuid
			order by 1, 2
	end

	return (0) -- sp_helprolemember
go


----------------------- sp_helprole -------------------------------------------

raiserror(15339,-1,-1,'sp_helprole')
go
CREATE PROCEDURE sp_helprole
	@rolename       sysname = NULL
AS
	if @rolename is not null
	begin
		-- VALIDATE GIVEN NAME
		if not exists (select * from sysusers where name = @rolename and (issqlrole = 1 or isapprole = 1))
		begin
			raiserror(15409, -1, -1, @rolename)
			return (1)
		end

		-- RESULT SET FOR SINGLE ROLE
		select 'RoleName' = name, 'RoleId' = uid, 'IsAppRole' = isapprole
			from sysusers where (name = @rolename) and (issqlrole = 1 or isapprole = 1)
	end
	else
	begin
		-- RESULT SET FOR ALL ROLES
		select 'RoleName' = name, 'RoleId' = uid, 'IsAppRole' = isapprole
			from sysusers where issqlrole = 1 or isapprole = 1
	end

	return (0) -- sp_helprole
go


----------------------- sp_helpntgroup ----------------------------------------

raiserror(15339,-1,-1,'sp_helpntgroup')
go
CREATE PROCEDURE sp_helpntgroup
	@ntname       sysname = NULL
AS
	if @ntname is not null
	begin
		-- VALIDATE GIVEN NAME
		if not exists (select * from sysusers where name = @ntname and isntgroup = 1)
		begin
			raiserror(15420, -1, -1, @ntname)
			return (1)
		end

		-- RESULT SET FOR SINGLE GROUP
		select 'NTGroupName' = name, 'NtGroupId' = uid, 'SID' = sid, 'HasDbAccess' = hasdbaccess
			from sysusers where name = @ntname and isntgroup = 1
	end
	else
	begin
		-- RESULT SET FOR ALL GROUPS
		select 'NTGroupName' = name, 'NtGroupId' = uid, 'SID' = sid, 'HasDbAccess' = hasdbaccess
			from sysusers where isntgroup = 1
	end

	return (0) -- sp_helpntgroup
go

------------------------------- xp_logininfo ----------------------------------

create proc xp_logininfo
	@acctname		sysname = null,				-- IN: NT login name
	@option			varchar(10) = null,			-- IN: 'all' | 'members' | null
	@privilege		varchar(10) = 'Not wanted' OUTPUT	-- OUT: 'admin' | 'user' | null
as
	-- VALIDATE PARAMETERS --
	if (@acctname is null AND (@option is not null OR (@privilege is null OR @privilege <> 'Not wanted')))
		OR ((@option is null OR @option <> 'all') AND (@privilege is null OR @privilege <> 'Not wanted'))
		OR (@option is not null and @option not in ('all', 'members'))
	begin
        raiserror(15600,-1,-1,'xp_logininfo')
        return 1
	end

	-- HANDLE CASE WHERE NO @acctname GIVEN --
	if (@acctname is null)
	begin
		select	'account name' = loginname,
				'type' = convert(varchar(8), case when isntuser = 1 then 'user' else 'group' end),
				'privilege' = convert(varchar(8), case when sysadmin = 1 then 'admin' else 'user' end),
				'mapped login name' = loginname,
				'permission path' = convert(sysname, null)
		from master..syslogins where isntname = 1 and hasaccess = 1
		order by 3, 1
		return @@error
	end

	-- HANDLE 'members' QUERY --
	if (@option = 'members')
	begin
		declare @priv varchar(8)
		select @priv = case when sysadmin = 1 then 'admin' else 'user' end
			from master..syslogins where isntname = 1 and loginname = @acctname and hasaccess = 1
		if @priv is not null
			select	'account name' = domain+N'\'+name,
					'type' = convert(varchar(8), case when sidtype = 1 then 'user' else 'group' end),
					'privilege' = @priv,
					'mapped login name' = domain+N'\'+name,
					'permission path' = @acctname
			from OpenRowset(NetGroupGetMembers, @acctname) order by 3, 1
		else
			select	'account name' = convert(sysname, null),
					'type' = convert(varchar(8), null),
					'privilege' = @priv,
					'mapped login name' = convert(sysname, null),
					'permission path' = convert(sysname, null)
			where 0=1	-- empty result set
		return @@error
	end

	-- CREATE TEMP TABLE AND POPULATE WITH THE REQUIRED DATA --
	create table #nt (name sysname collate database_default, sid varbinary(85), sidtype int)
	insert #nt select loginname, sid, isntgroup + 1 from master..syslogins
			where isntname = 1 and loginname = @acctname
	insert #nt select distinct domain+N'\'+name, sid, sidtype
			from OpenRowset(NetUserGetGroups, @acctname)
	if @@error <> 0
		return @@error
	-- IF ANY DENY, THEN NO ACCESS --
	if exists (select * from master..syslogins where sid in (select #nt.sid from #nt) and denylogin = 1)
		delete #nt

	-- HANDLE CASE WHERE OUTPUT REQUESTED --
	if (@privilege is null OR @privilege <> 'Not wanted')
	begin
		select @privilege = case max(sysadmin)
			when 1 then 'admin'
			when 0 then 'user'
			else NULL end
		from master..syslogins where isntname = 1 and hasaccess = 1
			AND sid in (select sid from #nt)
		return @@error
	end

	-- GET NT TYPE FOR NEXT OPTIONS --
	declare @type varchar(8)
	select @type = case when get_sid('\U'+@acctname, NULL) is null then 'group' else 'user' end

	-- HANDLE 'all' QUERY --
	if (@option = 'all')
	begin
		select	'account name' = @acctname,
				'type' = @type,
				'privilege' = convert(varchar(8), case when sysadmin = 1 then 'admin' else 'user' end),
				'mapped login name' = @acctname,
				'permission path' = case when l.loginname = @acctname then NULL else l.loginname end
		from master..syslogins l join #nt n on l.isntname = 1 and l.sid = n.sid
		where l.loginname = n.name and hasaccess = 1
		order by 3, 5
		return @@error
	end

	-- HANDLE DEFAULT QUERY --
	select	TOP 1
			'account name' = @acctname,
			'type' = @type,
			'privilege' = convert(varchar(8), case when sysadmin = 1 then 'admin' else 'user' end),
			'mapped login name' = @acctname,
			'permission path' = case when l.loginname = @acctname then NULL else l.loginname end
	from master..syslogins l join #nt n on l.isntname = 1 and l.sid = n.sid
	where l.loginname = n.name and hasaccess = 1
	order by 3, 5
	return @@error
go

-- GRANT PUBLIC ACCESS --
grant execute on sp_helpsrvrole            to public
grant execute on sp_srvrolepermission      to public
grant execute on sp_helpsrvrolemember      to public
grant execute on sp_helpdbfixedrole	       to public
grant execute on sp_dbfixedrolepermission  to public
grant execute on sp_helprolemember         to public
grant execute on sp_helprole               to public
grant execute on sp_helpntgroup            to public
-- NOTE: No grant for xp_logininfo! (it has no internal perm checks)
go
/************************  END-SECURITY-HELP-PROCEDURES  *********************/

/******************************************************************************
**************************  SYSSERVER-STORED-PROCS  ***************************
******************************************************************************/
checkpoint
go
if object_id('sp_addlinkedserver','P') IS NOT NULL
	drop procedure sp_addlinkedserver
if object_id('sp_dropserver','P') IS NOT NULL
	drop procedure sp_dropserver
if object_id('sp_serveroption','P') IS NOT NULL
	drop procedure sp_serveroption
if object_id('sp_addserver','P') IS NOT NULL
	drop procedure sp_addserver
if object_id('sp_setnetname','P') IS NOT NULL
	drop procedure sp_setnetname
if object_id('sp_helpserver','P') IS NOT NULL
	drop procedure sp_helpserver
if object_id('sp_helplinkedsrvlogin','P') IS NOT NULL
	drop procedure sp_helplinkedsrvlogin
go


----------------------------- sp_addlinkedserver ------------------------------

raiserror(15339,-1,-1,'sp_addlinkedserver')
go
create procedure sp_addlinkedserver
    @server         sysname,                -- server name
    @srvproduct     nvarchar(128) = NULL,   -- product name (dflt to ss)
    @provider       nvarchar(128) = NULL,   -- oledb provider name
    @datasrc        nvarchar(4000) = NULL,  -- oledb datasource property
    @location       nvarchar(4000) = NULL,  -- oledb location property
    @provstr        nvarchar(4000) = NULL,  -- oledb provider-string property
    @catalog        sysname = NULL          -- oledb catalog property
as
    -- VARIABLES
    declare @retcode    int,
            @srvid      smallint,
            @srvstat    smallint

    -- DISALLOW USER TRANSACTION
	set implicit_transactions off
    if @@trancount > 0
    begin
        raiserror(15002,-1,-1,'sp_addlinkedserver')
        return (1)
    end

    -- CHECK PERMISSIONS
    if not (is_srvrolemember('setupadmin') = 1)
    begin
		raiserror(15247,-1,-1)
        return (1)
    end

    -- VALIDATE SERVER NAME
    execute @retcode = sp_validname @server
    if @retcode <> 0
        return (1)

    -- SET DEFAULT STATUS BITS
    select @srvstat = 32 | 128  | 1024 -- local login mapping = 32, data access = 128 , use remote collation = 1024

    -- VALIDATE OLEDB PARAMETERS
    if @provider is null
    begin
        -- NO PROVIDER MEANS CANNOT SPECIFY ANY PROPERTIES!
        if @datasrc is not null or @location is not null or @provstr is not null or @catalog is not null
        begin
            raiserror(15426,-1,-1)
            return (1)
        end

        -- THIS MUST BE A WELL-KNOWN SERVER TYPE (DEFAULT IS SS)
        if @srvproduct is null OR lower(@srvproduct) = N'sql server'
        begin
            select @srvproduct = N'SQL Server'  -- force case to be this
            select @provider = N'SQLOLEDB'      -- SQL Server provider (LUXOR)
            select @datasrc = @server           -- datasrc is (network) server name
                        -- For SQL Server, we want rpc in/out by default
            select @srvstat = @srvstat | 1 | 64
                        -- rpc = 1, rpc out = 64
        end
        else            -- ADD OTHER WELL-KNOWN SOURCES HERE
        begin
            raiserror(15427,-1,-1,@srvproduct)
            return (1)
        end
    end
    else if @srvproduct in (N'SQL Server')  -- WELL-KNOWN SOURCES
    begin
        -- ILLEGAL TO SPECIFY PROVIDER/PROPERTIES FOR WELL-KNOWN SOURCES
        raiserror(15428,-1,-1,@srvproduct)
        return (1)
    end
    else if @srvproduct is null or lower(@srvproduct) like N'%sql server%'
    begin
        raiserror(15429,-1,-1,@srvproduct)
        return (1)
    end

    -- CHECK IF SERVER ALREADY EXISTS
    if exists (select * from master.dbo.sysservers where srvname = @server)
    begin
        raiserror(15028,-1,-1,@server)
        return (1)
    end

    -- GET SERVER ID FOR NEW ROW
    if not exists (select * from master.dbo.sysservers where srvid = 1)
        select @srvid = 1
    else
        select @srvid = min(s.srvid)+1 from master.dbo.sysservers s
            where s.srvid < 32767 and not exists
                (select * from master.dbo.sysservers s2 where s2.srvid = s.srvid+1)
    if @srvid is null
    begin
        raiserror(15430,-1,-1)
        return (1)
    end

    -- ADD ROW TO SYSSERVERS
	BEGIN TRAN
    insert master.dbo.sysservers select @srvid, @srvstat, @server, @srvproduct,
                @provider, @datasrc, @location, @provstr, getdate(), NULL, NULL, @catalog, NULL, 0, 0

	-- INSERT may have failed with row-too-big error.
	IF @@ERROR <> 0
	BEGIN
		ROLLBACK TRAN
		RETURN (1)
	END

	-- ADD DEFAULT MAPPING FOR OUTGOING EVENTS
	insert into master.dbo.sysxlogins select
        @srvid, NULL, 192, getdate(), getdate(), NULL, NULL, 0, NULL
	COMMIT TRAN

    -- SUCCESS
    return (0) -- sp_addlinkedserver
go


------------------------------- sp_dropserver ---------------------------------

raiserror(15339,-1,-1,'sp_dropserver')
go
create procedure sp_dropserver
    @server     sysname,            -- server name
    @droplogins char(10) = NULL     -- drop all related logins?
as
	declare @ret int

    -- DISALLOW USER TRANSACTION
	set implicit_transactions off
    if @@trancount > 0
    begin
        raiserror(15002,-1,-1,'sp_dropserver')
        return (1)
    end

    -- CHECK PERMISSIONS
    if not (is_srvrolemember('setupadmin') = 1)
    begin
		raiserror(15247,-1,-1)
        return (1)
    end


    -- CHECK SERVER NAME / GET SERVER ID
    declare @srvid smallint
    select @srvid = srvid from master.dbo.sysservers where srvname = @server
    if @srvid is null
    begin
        raiserror(15015,-1,-1,@server)
        return (1)
    end

    -- CHECK @droplogins PARAMETER (FOR RELATED SYSREMOTELOGINS ROWS)
    if @droplogins is null
    begin
		-- DONT consider default mapping for outgoing events
        if exists (select * from master.dbo.sysxlogins
					where srvid = @srvid and
						  not(ishqoutmap = 1 and
							  xstatus&192 = 192 and
							  sid is null and
							  name is null and
							  password is null))
        begin
            raiserror(15190,-1,-1,@server)
            return (1)
        end
    end
    else if @droplogins <> 'droplogins'
    begin
        raiserror(15191,-1,-1)
        return (1)
    end

    -- CHECK TO SEE IF THE SERVER IS USED BY REPLICATION.
    if object_id('master.dbo.sp_MSrepl_check_server') is not null
    begin
        execute @ret = master.dbo.sp_MSrepl_check_server @server
        if @ret <> 0 or @@error <> 0
			return 1
    end

    -- DROP THE SERVER (ALONG WITH ANY REMOTE LOGINS)
	begin transaction
	delete master.dbo.sysxlogins where srvid = @srvid
	delete master.dbo.sysservers where srvid = @srvid
	commit transaction

	-- SUCCESS
	return (0) -- sp_dropserver
go

------------------------------ sp_serveroption --------------------------------

raiserror(15339,-1,-1,'sp_serveroption')
go
create procedure sp_serveroption
	@server		sysname,		-- server name to change
	@optname	varchar(35),	-- option name to turn on/off
	@optvalue	nvarchar(128)	-- true or false, on or off, collation name, or timeout value
as
    -- VARIABLES
	SET NOCOUNT ON
    declare @statvalue      smallint,   -- status bit of option
			@collationID	int,		-- on disk collation ID of the server
			@timeout		int,		-- value for setting timeout options
			@fSet			int,		-- 0 or 1 for setting boolean option
			@distributor	sysname		-- for checking for multiple dist servers

    -- DISALLOW USER TRANSACTION
	set implicit_transactions off
    if @@trancount > 0
    begin
        raiserror(15002,-1,-1,'sp_serveroption')
        return (1)
    end

    -- CHECK PERMISSIONS
    if not (is_srvrolemember('setupadmin') = 1)
    begin
		raiserror(15247,-1,-1)
        return (1)
    end

	-- RESOLVE SERVER NAME
	IF NOT EXISTS (SELECT * FROM master.dbo.sysservers WHERE srvname = @server)
    BEGIN
        raiserror(15015,-1,-1,@server)
        return (1)
    END

	-- HANDLE VARIOUS OPTIONS
    SELECT @optname = lower(@optname), @optvalue = lower(@optvalue)

	IF @optname = 'collation name'
	BEGIN
		-- Collation Name: May reset by string 'null' or NULL value
		IF @optvalue IS NULL OR @optvalue = 'null'
			OR COLLATIONPROPERTY(@optvalue, 'collationid') IS NOT NULL
		BEGIN
			SELECT @collationID = convert(int, COLLATIONPROPERTY(@optvalue, 'collationid'))
			if @optvalue is NOT NULL
				BEGIN
				if convert(int, COLLATIONPROPERTY(@optvalue, 'isunicodeonly')) = 1
					BEGIN
					raiserror(15301, -1, -1, @optvalue)
					return (1)
					END
				if convert(int, COLLATIONPROPERTY(@optvalue, 'issupportedbyos')) = 0
					BEGIN
					raiserror(15394, -1, -1, @optvalue)
					return (1)
					END
				END
			UPDATE master.dbo.sysservers SET srvcollation = @collationID,
				-- Turn 'collation compatible' off when srvcollation NOT NULL
				srvstatus = CASE WHEN @collationID IS NOT NULL THEN (srvstatus & ~256) ELSE srvstatus END,
				schemadate = getdate() WHERE srvname = @server
			RETURN 0
		END
	END
	ELSE IF @optname IN ('connect timeout','query timeout')
	BEGIN
		-- TIMEOUT OPTIONS: Value must be integer-numeric >= 0
		IF ISNUMERIC (@optvalue) = 1 AND convert(int, @optvalue) >= 0
		BEGIN
			SELECT @timeout = convert (int, @optvalue)
			IF @optname = 'connect timeout'
				UPDATE master.dbo.sysservers SET connecttimeout = @timeout,
					schemadate = getdate() WHERE srvname = @server
			ELSE
				UPDATE master.dbo.sysservers SET querytimeout = @timeout,
					schemadate = getdate() WHERE srvname = @server
			RETURN 0
		END
	END
	ELSE
	BEGIN
		-- BIT-VALUED OPTION: GET STATUS BIT AND WHETHER TO SET OR CLEAR --
		-- NOTE: CANNOT MAKE A SYSTEM SERVER INTO NON-SYSTEM --
		SELECT @statvalue = number FROM master.dbo.spt_values WHERE name = @optname and type = 'A'
		SELECT @fSet = CASE WHEN @optvalue IN ('true','on') THEN 1
				WHEN @optvalue IN ('false','off') AND @optname <> 'system' THEN 0
				ELSE NULL END
		IF @statvalue IS NOT NULL AND @fSet IS NOT NULL
		BEGIN
			-- ONLY ONE SERVER MAY BE A DISTRIBUTION SERVER
			IF @optname = 'dist' AND @optvalue in ('true', 'on')
			BEGIN
				SELECT @distributor = srvname from master.dbo.sysservers where (srvstatus & @statvalue) <> 0
				IF @distributor is not null
				BEGIN
					raiserror(14099,-1,-1, @distributor)
					RETURN 1
				END
			END
			ELSE IF @optname = 'lazy schema validation' AND @optvalue in ('true', 'on')
			BEGIN
				IF serverproperty('EngineEdition') <> 3 -- Enterprise edition
				BEGIN
					raiserror(17050,-1,-1, @optname)
					RETURN 1
				END
			END
			-- DO THE UPDATE
			UPDATE master.dbo.sysservers SET
				srvstatus = (srvstatus & ~@statvalue) | (@statvalue * @fSet),
				-- Set srvcollation NULL when turning 'collation compatible' on
				srvcollation = CASE WHEN @optname='collation compatible' AND @fSet=1 THEN NULL ELSE srvcollation END,
				schemadate = getdate() WHERE srvname = @server
			RETURN 0
		END
	END

	-- IF WE REACH HERE, WE HAVE AN INVALID PARAMETER
	raiserror(15600,-1,-1,'sp_serveroption')
	RETURN 1 -- sp_serveroption
go


-------------------------------- sp_addserver ---------------------------------

raiserror(15339,-1,-1,'sp_addserver')
go
create procedure sp_addserver
    @server         sysname,            --server name
    @local          varchar(10) = NULL, -- NULL or 'local'
    @duplicate_ok   varchar(13) = NULL  -- NULL or 'duplicate_ok'
as
    -- VARS
    declare @retcode		int

    -- CHECK IF SERVER ALREADY EXISTS
    if exists (select * from master.dbo.sysservers where srvname = @server)
    begin
        if @duplicate_ok = 'duplicate_ok'
            return (0)
        raiserror(15028,-1,-1,@server)
        return (1)
    end

    -- VALIDATE @local PARAMETER
    if @local is not null
    begin
        select @local = lower(@local)
        if @local <> 'local'
        begin
            raiserror(15379,-1,-1,@local)
            return (1)
        end

        -- ERROR IF ALREADY HAVE A LOCAL SERVER NAME
        if exists (select * from master.dbo.sysservers where srvid = 0)
        begin
            raiserror(15090,-1,-1)
            return (1)
        end
    end

    -- ADD THE SERVER (CHECKS PERMISSIONS, ETC)
    execute @retcode = sp_addlinkedserver @server
    if @retcode <> 0
        return @retcode

    -- SET THE SERVER ID IF LOCAL OPTION SPECIFIED
    if @local = 'local'
	begin
		declare @srvid smallint
		-- UPDATE DEFAULT MAPPING CREATED BY sp_addlinkedserver
		select @srvid = srvid from master.dbo.sysservers where srvname = @server
		update master.dbo.sysxlogins set srvid = 0 where srvid = @srvid
        update master.dbo.sysservers
			set srvid = 0,
				schemadate = getdate()
            where srvname = @server
	end

    -- FOR COMPATIBILITY, TURN OFF THE data access SERVER OPTION
    execute @retcode = sp_serveroption @server, 'data access', 'off'
    if @retcode <> 0
        return @retcode

	--SET 'local login mapping', 'off' (make rpc-s behave as in 6.5)
	update master.dbo.sysservers
	set srvstatus = srvstatus & ~32, schemadate = getdate()
            where srvname = @server

    -- SUCCESS
    return (0) -- sp_addserver
go


------------------------------- sp_setnetname ---------------------------------

raiserror(15339,-1,-1,'sp_setnetname')
go
create procedure sp_setnetname  --- 1995/12/22 13:07
	 @server	sysname	-- server name
	,@netname	sysname	-- new net name
as
    DECLARE @srvproduct     nvarchar(128)   -- product name; must be SQL Server
	DECLARE @srvstatus int

    -- DISALLOW USER TRANSACTION
	set implicit_transactions off
    if @@trancount > 0
    begin
        raiserror(15002,-1,-1,'sp_setnetname')
        return (1)
    end

    -- CHECK PERMISSIONS
    if not (is_srvrolemember('setupadmin') = 1)
    begin
		raiserror(15247,-1,-1)
        return (1)
    end

    -- CHECK SERVER NAME (MUST BE A SQL SERVER!)
	select @srvproduct = srvproduct, @srvstatus = srvstatus from master.dbo.sysservers
                   where srvname = @server

	if @srvproduct is NULL
    begin
	    raiserror(15015,-1,-1,@server)
        return (1)
    end
	-- case checking is performed at sp_addlinkedserver so direct comparison is OK here
    else if @srvproduct <> N'SQL Server'
    begin
		raiserror(15576,-1,-1,@server)
		return (1)
    end

	-- CHECK FOR LOOPBACK SERVER AND ISSUE WARNING
	-- Only check linked server for "data access" since that's where the limitation
	-- lies.  Replication calls this code although only for RPC servers, so they
	-- shouldn't be seeing this message
	if @netname = @@SERVERNAME and @srvstatus & 128 = 128 and @server <> @netname
	begin
		raiserror(15577,-1,-1)
	end

    -- DO THE UPDATE
    update master.dbo.sysservers set datasource = @netname, schemadate = getdate()
        where srvname = @server

    -- SUCCESS
    return (0) -- sp_setnetname
go

------------------------------- sp_helpserver ---------------------------------

raiserror(15339,-1,-1,'sp_helpserver')
go
create procedure sp_helpserver
    @server         sysname = NULL,         -- server name
    @optname        varchar(35) = NULL,     -- option name to limit results
    @show_topology  varchar(1) = NULL       -- 't' to show topology coordinates
as
    -- PRELIMINARY
    set nocount on
    declare @optbit     int,
            @bitdesc    sysname,
            @curbit     int

    -- CHECK IF REQUESTED SERVER(S) EXIST
    if not exists (select * from master.dbo.sysservers where
		(@server is null or srvname = @server))
    begin
        if @server is null
            raiserror(15205,-1,-1)
        else
            raiserror(15015,-1,-1,@server)
        return (1)
    end

    -- GET THE BIT VALUE(S) FOR THE OPTION REQUESTED
    if @optname is not null
    begin
        select @optbit = number from master.dbo.spt_values
            where type = 'A' and name = @optname
        if @optbit is null
        begin
            raiserror(15206,-1,-1,@optname)
            return(1)
        end
    end
    else
        select @optbit = -1     -- 0xffffffff

    -- MAKE WORK COPY OF RELEVANT PART OF SYSSERVERS
    select name = srvname, network = srvnetname, status = convert(varchar(100), ''),
            id = srvid, srvstat = srvstatus, topx = topologyx, topy = topologyy,
			collation_name = convert(sysname, CollationPropertyFromID(srvcollation, 'name')),
			connect_timeout = connecttimeout, query_timeout = querytimeout
        into #spt_server
        from master.dbo.sysservers
		where (@server is null or srvname = @server) and (@optname is null or srvstatus & @optbit <> 0)

    -- SET THE STATUS FIELD
    select @curbit = 1
    while @curbit < 0x10000 -- bit field is a smallint
    begin
        select @bitdesc = null
        select @bitdesc = name from master.dbo.spt_values
			where type = 'A' and number = @curbit
        if @bitdesc is not null
            update #spt_server set status = status + ',' + @bitdesc where srvstat & @curbit <> 0
        select @curbit = @curbit * 2
    end

    -- SHOW THE RESULT SET
    if lower(@show_topology) <> 't' or @show_topology is null
	    select name, network_name = substring(network, 1, 28),
		        status = isnull(substring(status,2,8000),''),
                id = convert(char(4), id),
				collation_name, connect_timeout, query_timeout
	    from #spt_server order by name
    else
	    select name, network_name = substring(network, 1, 28),
		        status = isnull(substring(status,2,8000),''),
                id = convert(char(4), id),
				collation_name, connect_timeout, query_timeout,
				topx, topy
	    from #spt_server order by name

    -- RETURN SUCCESS
    return(0) -- sp_helpserver
go

------------------------------- sp_helpserver ---------------------------------

raiserror(15339,-1,-1,'sp_helplinkedsrvlogin')
go
create procedure sp_helplinkedsrvlogin
	@rmtsrvname		sysname = NULL,
	@locallogin		sysname = NULL
as
	declare	@srvid	smallint,
			@status	smallint,
			@ret	int

    -- CHECK REMOTE SERVER NAME.
    if @rmtsrvname is not null
    begin
    	select @srvid = srvid from master.dbo.sysservers where srvname = @rmtsrvname
    	if @srvid is null
    	begin
		raiserror(15015,-1,-1,@rmtsrvname)
		return (1)
    	end
    end

    -- IF SPECIFIED CHECK LOCAL USER NAME
	if (@locallogin IS NOT NULL)
	begin
		select	u.srvname as [Linked Server],		t.name as [Local Login],
				s.selfoutmap as [Is Self Mapping],	s.name as [Remote Login]
		from master.dbo.sysxlogins s, master.dbo.sysxlogins t, master.dbo.sysservers u
		where ((@rmtsrvname is null or @rmtsrvname=u.srvname) and u.srvid= s.srvid)
			and s.ishqoutmap = 1 and s.sid=t.sid
			and t.name = @locallogin and t.ishqoutmap = 0
	end

	if (@locallogin IS  NULL)
	begin
		-- Get global mapping (s.sid is NULL) if any
		select	u.srvname as [Linked server],		NULL as [Local Login],
			s.selfoutmap as [Is Self Mapping],	s.name as [Remote Login]
		from master.dbo.sysxlogins s, master.dbo.sysservers u
		where  ((@rmtsrvname is null or @rmtsrvname=u.srvname)and u.srvid= s.srvid)
			and s.ishqoutmap = 1 and  s.sid is NULL
		UNION
		-- Get specific mappings
		select	u.srvname as [Linked server],		t.name as [Local Login],
				s.selfoutmap as [Is Self Mapping],	s.name as [Remote Login]
		from master.dbo.sysxlogins s, master.dbo.sysxlogins t, master.dbo.sysservers u
		where ((@rmtsrvname is null or @rmtsrvname=u.srvname) and u.srvid= s.srvid)
			and s.ishqoutmap = 1 and s.sid=t.sid and t.ishqoutmap = 0
		order by u.srvname
    end
    -- RETURN SUCCESS
    return(0) -- sp_helplinkedsrvlogin
go

-- GRANT PUBLIC ACCESS --
grant execute on sp_addlinkedserver to public
grant execute on sp_dropserver to public
grant execute on sp_serveroption to public
grant execute on sp_addserver to public
grant execute on sp_setnetname to public
grant execute on sp_helpserver to public
grant execute on sp_helplinkedsrvlogin to public
go
/************************  END-SYSSERVER-STORED-PROCS  ***********************/

/************************  SYSOLEDBUSERS-STORED-PROCS  ***********************/
if object_id('sp_addlinkedsrvlogin','P') IS NOT NULL
	drop procedure sp_addlinkedsrvlogin
if object_id('sp_droplinkedsrvlogin','P') IS NOT NULL
	drop procedure sp_droplinkedsrvlogin
go

------------------------------- sp_addlinkedsrvlogin ---------------------------------

raiserror(15339,-1,-1,'sp_addlinkedsrvlogin')
go
create procedure sp_addlinkedsrvlogin
	@rmtsrvname		sysname,
	@useself		varchar(8) = 'true',
	@locallogin		sysname = NULL,
	@rmtuser    	sysname = NULL,
	@rmtpassword	sysname = NULL
as
	declare	@srvid	smallint,
			@status	smallint,
			@localsid	varbinary(85),
			@ret	int

    -- DISALLOW USER TRANSACTION
	set implicit_transactions off
    if @@trancount > 0
    begin
        raiserror(15002,-1,-1,'sp_addlinkedsrvlogin')
        return (1)
    end

    -- CHECK PERMISSIONS
    if not (is_srvrolemember('securityadmin') = 1)
    begin
		raiserror(15247,-1,-1)
        return (1)
    end

	-- VALIDATE @useself PARAMETER --
	select @useself = lower(@useself)
	if @useself is null or @useself not in ('true','false')
	begin
        raiserror(15600,-1,-1,'sp_addlinkedsrvlogin')
        return 1
	end

	-- CHECK REMOTE SERVER NAME.
	select @srvid = srvid from master.dbo.sysservers where srvname = @rmtsrvname
	if @srvid is null
	begin
		raiserror(15015,-1,-1,@rmtsrvname)
		return (1)
	end

	-- IF SPECIFIED CHECK LOCAL USER NAME
	if (@locallogin IS NOT NULL)
	begin
		select @localsid = sid from master.dbo.syslogins where loginname = @locallogin
		if @localsid IS NULL
		begin
			-- ADD ROW FOR NT LOGIN IF NEEDED --
			execute @ret = sp_MSaddlogin_implicit_ntlogin @locallogin
			if (@ret = 0)
				select @localsid = sid from master.dbo.syslogins where loginname = @locallogin
			if (@localsid IS NULL)
			begin
				raiserror(15067,-1,-1,@locallogin)
				return (1)
			end
		end
	end

	-- 64 IMPLIES sysxlogins::ishqoutmap is TRUE
	select @status = 64

	-- IF @useself IS TRUE IT OVERRIDES PARAMETERS @rmtuser, and @rmtpassword
	if @useself = 'true'
	begin
		select @rmtuser = NULL
		select @rmtpassword = NULL
		select @status = @status | 128
	end

	BEGIN TRAN

	-- DELETE EXISTING MAPPING(s) FOR THIS @sid
	update master.dbo.sysxlogins set xstatus = xstatus & ~192
		where srvid = @srvid AND ishqoutmap = 1 AND isrpcinmap = 1
			AND ((sid IS NULL AND @localsid IS NULL) OR sid = @localsid)
	if @@rowcount = 0
		delete master.dbo.sysxlogins where srvid = @srvid AND ishqoutmap = 1
			AND ((sid IS NULL AND @localsid IS NULL) OR sid = @localsid)

	-- ATTEMPT TO TAG THIS ONTO EXISTING ROW --
	update master.dbo.sysxlogins
		set xstatus = (xstatus & ~192) | @status,
			xdate2 = getdate(),
			password = convert(varbinary(256), encrypt(@rmtpassword))
		where srvid = @srvid AND isrpcinmap = 1
			AND ((sid IS NULL AND @localsid IS NULL) OR sid = @localsid)
			AND ((name IS NULL AND @rmtuser IS NULL) OR name = @rmtuser)

	-- IF NO ROW UPDATED, INSERT NEW ROW --
	if (@@rowcount = 0)
		insert master.dbo.sysxlogins values
				(@srvid, @localsid, @status, getdate(), getdate(), @rmtuser,
					   convert(varbinary(256), encrypt(@rmtpassword)), 0, NULL)

	COMMIT TRAN

    -- RETURN SUCCESS
    return(0) -- sp_addlinkedsrvlogin
go

------------------------------- sp_droplinkedsrvlogin ---------------------------------

raiserror(15339,-1,-1,'sp_droplinkedsrvlogin')
go
create procedure sp_droplinkedsrvlogin
	@rmtsrvname		sysname,
	@locallogin		sysname
as
	declare @srvid	smallint
	declare @localsid	varbinary(85)

    -- DISALLOW USER TRANSACTION
	set implicit_transactions off
    if @@trancount > 0
    begin
        raiserror(15002,-1,-1,'sp_droplinkedsrvlogin')
        return (1)
    end

    -- CHECK PERMISSIONS
    if not (is_srvrolemember('securityadmin') = 1)
    begin
		raiserror(15247,-1,-1)
        return (1)
    end

	-- CHECK REMOTE SERVER NAME.
	select @srvid = srvid from master.dbo.sysservers where srvname = @rmtsrvname
	if @srvid is null
	begin
		raiserror(15015,-1,-1,@rmtsrvname)
		return (1)
	end

	-- CHECK LOCAL USER NAME IF GIVEN
	if @locallogin is not null
	begin
		select @localsid = suser_sid(@locallogin)
		if (@localsid IS NULL)
		begin
			raiserror(15067,-1,-1,@locallogin)
			return (1)
		end
	end

	-- DELETE MAPPING(s)
	update master.dbo.sysxlogins set xstatus = xstatus & ~192
		where srvid = @srvid AND ishqoutmap = 1 AND isrpcinmap = 1
			AND ((sid IS NULL AND @localsid IS NULL) OR sid = @localsid)
	if @@rowcount = 0
		delete master.dbo.sysxlogins where srvid = @srvid AND ishqoutmap = 1
			AND ((sid IS NULL AND @localsid IS NULL) OR sid = @localsid)

    -- RETURN SUCCESS
    return(0) -- sp_droplinkedsrvlogin
go

-- GRANT PUBLIC ACCESS --
grant execute on sp_addlinkedsrvlogin to public
grant execute on sp_droplinkedsrvlogin to public
go
/************************  END-SYSOLEDBUSERS-STORED-PROCS  ***********************/

/******************************************************************************
****************************  FULLTEXT INDEXES ********************************
******************************************************************************/
checkpoint
go
if object_id('sp_fulltext_service','P') IS NOT NULL
	drop procedure sp_fulltext_service
if object_id('sp_fulltext_database','P') IS NOT NULL
	drop procedure sp_fulltext_database
if object_id('sp_fulltext_catalog','P') IS NOT NULL
	drop procedure sp_fulltext_catalog
if object_id('sp_fulltext_table','P') IS NOT NULL
	drop procedure sp_fulltext_table
if object_id('sp_fulltext_column','P') IS NOT NULL
	drop procedure sp_fulltext_column
	if object_id('sp_help_fulltext_catalogs','P') IS NOT NULL
	drop procedure sp_help_fulltext_catalogs
if object_id('sp_help_fulltext_catalogs_cursor','P') IS NOT NULL
	drop procedure sp_help_fulltext_catalogs_cursor
if object_id('sp_help_fulltext_tables','P') IS NOT NULL
	drop procedure sp_help_fulltext_tables
if object_id('sp_help_fulltext_tables_cursor','P') IS NOT NULL
	drop procedure sp_help_fulltext_tables_cursor
if object_id('sp_help_fulltext_columns','P') IS NOT NULL
	drop procedure sp_help_fulltext_columns
if object_id('sp_help_fulltext_columns_cursor','P') IS NOT NULL
	drop procedure sp_help_fulltext_columns_cursor
if object_id('sp_fulltext_getdata','X') IS NOT NULL
	exec sp_dropextendedproc 'sp_fulltext_getdata'
execute sp_addextendedproc 'sp_fulltext_getdata','(server internal)'
go


---------------------------- sp_fulltext_service ------------------------------

raiserror(15339,-1,-1,'sp_fulltext_service')
go
create proc sp_fulltext_service
    @action     varchar(20),    -- resource_usage | clean_up | connect_timeout | data_timeout
    @value      int = NULL      -- value for resource_usage | connect_timeout | data_timeout
as
	-- VALIDATE PARAMS --
	if @action is null OR @action not in ('resource_usage', 'clean_up', 'connect_timeout', 'data_timeout')
        OR (@value is not null AND @action not in ('resource_usage', 'connect_timeout', 'data_timeout'))
        OR (@value is null and @action in ('resource_usage', 'connect_timeout', 'data_timeout'))
	begin
        raiserror(15600,-1,-1,'sp_fulltext_service')
        return 1
	end

    -- DISALLOW USER TRANSACTION --
	set implicit_transactions off
    if @@trancount > 0
    begin
        raiserror(15002,-1,-1,'sp_fulltext_service')
        return 1
    end

	-- CHECK PERMISSIONS (must be serveradmin) --
	if (is_srvrolemember('serveradmin') = 0)
    begin
        raiserror(15247,-1,-1)
        return 1
    end

    if @action = 'resource_usage'
    begin
        DBCC CALLFULLTEXT ( 13, @value )  -- FTSetResource( @value )
        if @@error <> 0
            return 1
    end

	if @action = 'clean_up'
	begin
		DBCC CALLFULLTEXT ( 8 )	-- Iterate thru catalogs, remove if dbid doesn't exist.
		if @@error <> 0
			return 1
	end

    if @action = 'connect_timeout'
    begin
        DBCC CALLFULLTEXT ( 14, @value )    -- SetProperty( FT_PROP_CONN_TIMEOUT,  @value )
        if @@error <> 0
            return 1
    end

	if @action = 'data_timeout'
    begin
        DBCC CALLFULLTEXT ( 15, @value )    -- SetProperty( FT_PROP_DATA_TIMEOUT,  @value )
        if @@error <> 0
            return 1
    end


	-- SUCCESS --
	return 0	-- sp_fulltext_service
go

---------------------------- sp_fulltext_database -----------------------------

raiserror(15339,-1,-1,'sp_fulltext_database')
go
create proc sp_fulltext_database
	@action		varchar(20)		-- 'enable' | 'disable'
as
	declare @ftcat		sysname,
		    @ftcatid	smallint,
			@path		nvarchar(260),
			@objid		int,
			@dbid		smallint,
			@objname	sysname

	-- VALIDATE PARAMS --
	if @action is null OR @action not in ('enable','disable')
	begin
        raiserror(15600,-1,-1,'sp_fulltext_database')
        return 1
	end

    -- DISALLOW USER TRANSACTION --
	set implicit_transactions off
    if @@trancount > 0
    begin
        raiserror(15002,-1,-1,'sp_fulltext_database')
        return 1
    end

	-- CHECK PERMISSIONS (must be a dbowner) --
	if (is_member('db_owner') = 0)
    begin
        raiserror(15247,-1,-1)
        return 1
    end

	-- CHECK DATABASE MODE (must not be read-only) --
	if (DATABASEPROPERTY(db_name(), 'IsReadOnly') = 1)
	begin
		raiserror(15635, -1, -1, 'sp_fulltext_database')
		return 1
	end

	-- CLEAR SYSDATABASES BIT AND PROPAGATE W/ CHECKPOINT (for both enable & disable) --
	select @dbid = db_id()
	update master.dbo.sysdatabases set status2 = status2 & ~536870912 where dbid = @dbid
	checkpoint

	-- DROP ALL CATALOGS WITH THIS DATABASE (for both enable/disable) --
	DBCC CALLFULLTEXT ( 7, @dbid )	-- FTDropAllCatalogs ( "@dbid" )
	if @@error <> 0
		return 1

	-- DELETE ALL THE CHANGE NOTIFICATIONS FROM SYSFULLTEXTNOTIFY --
	delete sysfulltextnotify

	if @action = 'enable'
	begin
		-- CREATE CATALOGS --
		declare ms_crs_ftcat cursor static local for select name, path from sysfulltextcatalogs
		open ms_crs_ftcat
		fetch ms_crs_ftcat into @ftcat, @path
		while @@fetch_status >= 0
		begin
			DBCC CALLFULLTEXT ( 16, @ftcat, @path )	-- FTCreateCatalog( @ftcatid, @path )
			if @@error <> 0
				return 1
			fetch ms_crs_ftcat into @ftcat, @path
		end
		deallocate ms_crs_ftcat

		declare	@vc1			nvarchar(517)
		-- BEGIN TRAN
		begin tran

		-- ACTIVATE TABLES/URLs --
		declare ms_crs_ftind cursor static local for select ftcatid, id from sysobjects
					where (ftcatid <> 0)

		open ms_crs_ftind
		fetch ms_crs_ftind into @ftcatid, @objid
		while @@fetch_status >= 0
		begin
			DBCC CALLFULLTEXT ( 5, @ftcatid, @objid )	-- FTAddURL( @ftcatid, db_id(), @objid )
			if @@error <> 0
				goto error_abort_exit

			-- CHECK TABLE FOR NOTIFICATIONS --
			if ObjectProperty(@objid, 'TableFulltextChangeTrackingOn') = 1
			begin
				-- ERROR IF DATABASE IS IN SINGLE USER MODE --
				if DATABASEPROPERTY(db_name(), 'IsSingleUser') = 1
				begin
					select @objname = object_name(@objid)
					raiserror(15638, -1, -1, @objname)

					select @vc1 = quotename(user_name(OBJECTPROPERTY(@objid,'OwnerId'))) + '.'
						+ quotename(@objname)

					-- LOCK TABLE --
					dbcc lockobjectschema(@vc1)
					if @@error <> 0
						goto error_abort_exit

					-- TURN OFF CHANGE TRACKING ACTIVE BITS IN SYSOBJECTS --
					update sysobjects set status = status & ~192 where id = @objid

					fetch ms_crs_ftind into @ftcatid, @objid
					continue
				end

				-- START A FULL CRAWL FOR THIS TABLE --
				DBCC CALLFULLTEXT ( 12, @ftcatid, @objid, 0 )
				if @@error <> 0
					goto error_abort_exit
			end

			-- CHECK TABLE FOR AUTOPROPAGATION  -
			if ObjectProperty(@objid, 'TableFulltextBackgroundUpdateIndexOn') = 1
			begin
				DBCC CALLFULLTEXT ( 10, @ftcatid, @objid )	-- FTEnableAutoProp( @ftcatid, db_id(), @objid )
				if @@error <> 0
					goto error_abort_exit
			end

			fetch ms_crs_ftind into @ftcatid, @objid
		end
		deallocate ms_crs_ftind

		-- SET SYSDATABASES BIT --
		update master.dbo.sysdatabases set status2 = status2 | 536870912 where dbid = @dbid

		-- COMMIT TRAN --
		commit tran

		-- CHECKPOINT TO PUSH SYSDATABASES BIT TO MEMORY --
		checkpoint

		if @@error <> 0
			goto error_abort_exit

	end


	-- SUCCESS --
	return 0	-- sp_fulltext_database


error_abort_exit:
	rollback tran
	return 1	-- sp_fulltext_database
go

---------------------------- sp_fulltext_catalog ------------------------------

raiserror(15339,-1,-1,'sp_fulltext_catalog')
go
create proc sp_fulltext_catalog
	@ftcat		sysname,		-- full-text catalog name
	@action 	varchar(20),	-- create | drop | | rebuild | ...
	@path		nvarchar(101) = null	-- optional file path for create (max of 100 chars!!!)
as
	declare @objname sysname,
			@objid	int,
			@vc1	nvarchar(517),
			@tabname	nvarchar(517),
			@tabwarn int

	select @tabwarn = 0

	-- FULLTEXT MUST BE ACTIVE IN DATABASE --
	if DatabaseProperty(db_name(), 'IsFulltextEnabled') = 0
	begin
		raiserror(15601,-1,-1)
		return 1
	end

	-- VALIDATE PARAMS --
	if @action is null
		OR @action not in ('create','drop','start_full','start_incremental','stop','rebuild')
		OR @ftcat is null OR len(@ftcat) = 0
		OR (@path is not null and @action <> 'create')
		OR (len(@path) > 100 )
	begin
		raiserror(15600,-1,-1,'sp_fulltext_catalog')
		return 1
	end

	-- DISALLOW USER TRANSACTION --
	set implicit_transactions off
	if @@trancount > 0
	begin
		raiserror(15002,-1,-1,'sp_fulltext_catalog')
		return 1
	end

	-- CHECK PERMISSIONS (must be a dbowner) --
	if (is_member('db_owner') = 0)
	begin
		raiserror(15247,-1,-1)
		return 1
	end

	-- CHECK DATABASE MODE (must not be read-only) --
	if DATABASEPROPERTY(db_name(), 'IsReadOnly') = 1
	begin
		raiserror(15635, -1, -1, 'sp_fulltext_catalog')
		return 1
	end

	-- CATALOG MUST EXIST IF NOT CREATING --
	declare @ftcatid smallint
	select @ftcatid = ftcatid from sysfulltextcatalogs where name = @ftcat
	if @action not in ('create', 'drop') and @ftcatid is null
	begin
		raiserror(7641,-1,-1,@ftcat)
		return 1
	end

	if @action = 'create'
	begin
		DBCC CALLFULLTEXT ( 1, @ftcat, @path )	-- FTCreateCatalog( @ftcat, @path )
		if @@error <> 0 
			return 1
	end

	if @action = 'drop'
	begin
		-- CANNOT DROP CATALOG IF USED --
		if exists (select * from sysobjects where ftcatid = @ftcatid)
		begin
			raiserror(15604,-1,-1, @ftcat)
			return 1
		end

		DBCC CALLFULLTEXT ( 2, @ftcat )	-- FTDropCatalog( @ftcat )
		if @@error <> 0
			return 1
	end

	if @action = 'start_full'
	begin
		-- ERROR IF DATABASE IS IN SINGLE USER MODE --
		if DATABASEPROPERTY(db_name(), 'IsSingleUser') = 1
		begin
			raiserror(15636, -1, -1, @ftcat)
			return 1
		end

		begin tran
		-- MARK TABLES/URLs AS --
		declare ms_crs_ftind cursor static local for select id, name from sysobjects
					where ftcatid = @ftcatid
		open ms_crs_ftind
		fetch ms_crs_ftind into @objid, @tabname
		while @@fetch_status >= 0
		begin

			-- ERROR ON TABLE IF TABLE IS NOT ACTIVATED --
			if (ObjectProperty(@objid, 'TableHasActiveFulltextIndex') = 0)
			begin
				raiserror(15630, -1, -1, @tabname)
				goto error_exit
			end

			-- SKIP TABLE IF CRAWL ALREADY IN PROGRESS --
			if (ObjectProperty(@objid, 'TableFulltextPopulateStatus') != 0)
			begin
				select @tabwarn = 1
				fetch ms_crs_ftind into @objid, @tabname
				continue
			end


			-- START FULL CRAWL
			DBCC CALLFULLTEXT ( 12, @ftcatid, @objid, 0 )
			if @@error <> 0	-- server raised an error
			begin
				-- server did an ex_raise - this is unreachable code
				goto error_exit
			end

			-- DELETE NOTIFICATIONS FROM SYSFULLTEXTNOTIFY --
			delete sysfulltextnotify where tableid = @objid

			if (ObjectProperty(@objid, 'TableIsFulltextSchemaModified') = 1)
			and (ObjectProperty(@objid, 'TableFulltextChangeTrackingOn') = 0)
			begin

				select @vc1 = quotename(user_name(OBJECTPROPERTY(@objid,'OwnerId'))) + '.'
							+ quotename(object_name(@objid))

				dbcc lockobjectschema(@vc1)

				update sysobjects set status = status & ~128 where id = @objid

			end

			fetch ms_crs_ftind into @objid, @tabname
		end
		deallocate ms_crs_ftind

		commit tran

	end

	if @action = 'start_incremental'
	begin
		-- ERROR IF DATABASE IS IN SINGLE USER MODE --
		if DATABASEPROPERTY(db_name(), 'IsSingleUser') = 1
		begin
			raiserror(15636, -1, -1, @ftcat)
			return 1
		end
		begin tran

		-- MARK TABLES/URLs AS --
		declare ms_crs_ftind cursor static local for select id, name from sysobjects
					where ftcatid = @ftcatid
		open ms_crs_ftind
		fetch ms_crs_ftind into @objid, @tabname
		while @@fetch_status >= 0
		begin
			-- ERROR ON TABLE IF TABLE IS NOT ACTIVATED --
			if (ObjectProperty(@objid, 'TableHasActiveFulltextIndex') = 0)
			begin
				raiserror(15630, -1, -1, @tabname)
				goto error_exit
			end

			-- SKIP TABLE IF CRAWL ALREADY IN PROGRESS --
			if (ObjectProperty(@objid, 'TableFulltextPopulateStatus') != 0)
			begin
				select @tabwarn = 1
				fetch ms_crs_ftind into @objid, @tabname
				continue
			end

			if (ObjectProperty(@objid, 'TableIsFulltextSchemaModified') = 1)
			and (ObjectProperty(@objid, 'TableFulltextChangeTrackingOn') = 0)
			begin

				-- START A FULL POPULATION FOR THIS TABLE --
				DBCC CALLFULLTEXT ( 12, @ftcatid, @objid, 0 )
				if @@error <> 0
				begin
					-- server did an ex_raise - this is unreachable code --
					goto error_exit
				end

				select @vc1 = quotename(user_name(OBJECTPROPERTY(@objid,'OwnerId'))) + '.'
						+ quotename(object_name(@objid))

				dbcc lockobjectschema(@vc1)

				update sysobjects set status = status & ~128 where id = @objid

			end
			else
			begin
				-- START AN INCREMENTAL POPULATION FOR THIS TABLE --
				DBCC CALLFULLTEXT ( 12, @ftcatid, @objid, 1 )
				if @@error <> 0
				begin
					-- server did an ex_raise - this is unreachable code --
					goto error_exit
				end

			end

			-- DELETE NOTIFICATIONS FROM SYSFULLTEXTNOTIFY --
			delete sysfulltextnotify where tableid = @objid

			fetch ms_crs_ftind into @objid, @tabname
		end
		deallocate ms_crs_ftind
		commit tran


	end

	if @action = 'stop'
	begin
		declare ms_crs_ftind cursor static local for select id, name from sysobjects
					where ftcatid = @ftcatid
		open ms_crs_ftind
		fetch ms_crs_ftind into @objid, @tabname
		while @@fetch_status >= 0
		begin

			-- ERROR ON TABLE IF TABLE IS NOT ACTIVATED --
			if ObjectProperty(@objid, 'TableHasActiveFulltextIndex') = 0
			begin
				raiserror(15630, -1, -1, @tabname)
				return 1
			end

			-- SKIP TABLE IF CRAWL ALREADY STOPPED - NO WARNING --
			if (ObjectProperty(@objid, 'TableFulltextPopulateStatus') = 0)
			begin
				fetch ms_crs_ftind into @objid, @tabname
				continue
			end

			-- ERROR IF POPULATE STATUS OF THE TABLE IS CRAWLING AND CT ON
			if (ObjectProperty(@objid, 'TableFulltextChangeTrackingOn') = 1)
			and ((ObjectProperty(@objid, 'TableFulltextPopulateStatus') = 1)
			or (ObjectProperty(@objid, 'TableFulltextPopulateStatus') = 2))
			begin
				raiserror(15642,-1,-1, @tabname)
				return 1
			end

			-- STOP A FULL/INCREMENTAL POPULATION FOR THIS TABLE --
			DBCC CALLFULLTEXT ( 12, @ftcatid, @objid, 2 )
			if @@error <> 0
			begin
				-- server did an ex_raise - this is unreachable code --
				return 1
			end

			fetch ms_crs_ftind into @objid, @tabname
		end
		deallocate ms_crs_ftind

	end

	if @action = 'rebuild'
	begin

		-- RE-CREATE CATALOG (Will first drop)
		select @path = path from sysfulltextcatalogs where ftcatid = @ftcatid
		DBCC CALLFULLTEXT ( 16, @ftcat, @path )	-- FTCreateCatalog( @ftcat, @path )
		if @@error <> 0
		begin 
			-- server did an ex_raise - this is unreachable code --
			return 1
		end

		begin tran

		-- RE-ACTIVATE TABLES/URLs --
		declare ms_crs_ftind cursor static local for select id from sysobjects
					where ftcatid = @ftcatid
		open ms_crs_ftind
		fetch ms_crs_ftind into @objid
		while @@fetch_status >= 0
		begin
			DBCC CALLFULLTEXT ( 5, @ftcatid, @objid )	-- FTAddURL( @ftcat, db_id(), @objid )
			if @@error <> 0
			begin
				-- server did an ex_raise - this is unreachable code --
				goto error_exit
			end

			-- CHECK TABLE FOR NOTIFICATIONS --
			if ObjectProperty(@objid, 'TableFulltextChangeTrackingOn') = 1
				and ObjectProperty(@objid, 'TableHasActiveFulltextIndex') = 1
			begin
				-- ERROR IF DATABASE IS IN SINGLE USER MODE --
				if DATABASEPROPERTY(db_name(), 'IsSingleUser') = 1
				begin
					select @objname = object_name(@objid)
					raiserror(15638, -1, -1, @objname)

					select @vc1 = quotename(user_name(OBJECTPROPERTY(@objid,'OwnerId'))) + '.'
						+ quotename(@objname)


					dbcc lockobjectschema(@vc1)

					-- DISABLE FULLTEXT AUTO PROPAGATION (NO ERROR IF ALREADY DISABLED AND --
					-- IGNORE ANY OTHER ERRORS) --
					DBCC CALLFULLTEXT ( 9, @objid )	-- FTDisableNotify( db_id(), @objid )
					if @@error <> 0
					begin
						-- server did an ex_raise - this is unreachable code --
						goto error_exit
					end

					-- TURN OFF CHANGE TRACKING ACTIVE BITS IN SYSOBJECTS --
					update sysobjects set status = status & ~192 where id = @objid

					fetch ms_crs_ftind into @objid
					continue
				end

				-- STOP A FULL/INCREMENTAL POPULATION FOR THIS TABLE --
				DBCC CALLFULLTEXT ( 12, @ftcatid, @objid, 2 )
				if @@error <> 0
				begin
					-- server did an ex_raise - this is unreachable code --
					goto error_exit
				end

				-- START A FULL CRAWL FOR THIS TABLE --
				DBCC CALLFULLTEXT ( 12, @ftcatid, @objid, 0 )
				if @@error <> 0
				begin
					-- server did an ex_raise - this is unreachable code --
					goto error_exit
				end

				-- DELETE NOTIFICATIONS FROM SYSFULLTEXTNOTIFY --
				delete sysfulltextnotify where tableid = @objid

			end

			-- CHECK TABLE FOR AUTOPROPAGATION  -
			if ObjectProperty(@objid, 'TableFulltextAutoPropagationOn') = 1
				and ObjectProperty(@objid, 'TableHasActiveFulltextIndex') = 1
			begin
				DBCC CALLFULLTEXT ( 10, @ftcatid, @objid )	-- FTEnableAutoProp( @ftcatid, db_id(), @objid )
				if @@error <> 0
				begin
					-- server did an ex_raise - this is unreachable code --
					goto error_exit
				end
			end

			fetch ms_crs_ftind into @objid
		end
		deallocate ms_crs_ftind

		commit tran

	end
	if(@tabwarn <> 0)
	begin
		raiserror(15643, -1, -1)
		return 0
	end
	return 0	-- sp_fulltext_catalog

error_exit:
	-- 'stop', 'rebuild' never get here, this is only for 'start_full', 'start_incr'
	-- here we commit the changes for all tables on which the operation succeeded.  
	-- Before 'goto error_exit' is called, schema changes made to table currently 
	-- under cursor must be undone (so far, no schema changes)
	commit tran
	return 1	-- sp_fulltext_catalog

go

----------------------------- sp_fulltext_table -------------------------------

raiserror(15339,-1,-1,'sp_fulltext_table')
go
create proc sp_fulltext_table
	@tabname	nvarchar(517),
	@action		varchar(50),
	@ftcat		sysname = NULL,		-- create: catalog name
	@keyname	sysname = NULL		-- create: name of unique index
as
	declare @schemamodified int
	-- FULLTEXT MUST BE ACTIVE IN DATABASE --
	if DatabaseProperty(db_name(), 'IsFulltextEnabled') = 0
	begin
        raiserror(15601,-1,-1)
        return 1
	end

	-- VALIDATE PARAMS --
	if @action is null
		OR @action not in ('create','drop','activate','deactivate',
			'start_change_tracking', 'stop_change_tracking',
			'start_background_updateindex', 'stop_background_updateindex',
			'update_index', 'start_full', 'start_incremental', 'stop')
		OR (@action not in ('create') and (@ftcat is not null or @keyname is not null))
		OR (@action in ('create') and (@ftcat is null or @keyname is null))
	begin
        raiserror(15600,-1,-1,'sp_fulltext_table')
        return 1
	end

    -- DISALLOW USER TRANSACTION --
	set implicit_transactions off
    if @@trancount > 0
    begin
        raiserror(15002,-1,-1,'sp_fulltext_table')
        return 1
    end

	-- VALIDATE TABLE NAME --
    --  (1) Must exist in current database
	declare @objid int
	select @objid = object_id(@tabname, 'local')
    if @objid is null
    begin
		declare @curdbname sysname
	    select @curdbname = db_name()
	    raiserror(15009,-1,-1 ,@tabname, @curdbname)
	    return 1
    end
    --  (2) Must be a user table (and not a temp table)
    if ObjectProperty(@objid, 'IsUserTable') = 0 OR substring(parsename(@tabname,1),1,1) = '#'
    begin
	    raiserror(15218,-1,-1 ,@tabname)
	    return 1
    end

    -- CHECK PERMISSION ON TABLE --
    if (is_member('db_owner') = 0) AND (is_member('db_ddladmin') = 0)
        AND (is_member(user_name(ObjectProperty(@objid, 'ownerid'))) = 0)
    begin
        raiserror(15247,-1,-1)
        return 1
    end

	-- CHECK DATABASE MODE (must not be read-only) --
	if DATABASEPROPERTY(db_name(), 'IsReadOnly') = 1
	begin
		raiserror(15635, -1, -1, 'sp_fulltext_table')
		return 1
	end

	-- BEGIN TRAN AND LOCK TABLE --
	begin tran
	dbcc lockobjectschema(@tabname)
	if @@error <> 0
	begin
		goto error_abort_exit
	end

	-- OBTAIN CATALOG NAME FROM SYSOBJECTS & CHECK ACTION --
	declare @ftcatid smallint
	select @ftcatid = ObjectProperty(@objid, 'TableFulltextCatalogId')
	if @ftcatid <> 0 and @action = 'create'
	begin
        raiserror(15605,-1,-1,@tabname)
        goto error_abort_exit
	end
	if @ftcatid = 0 and @action <> 'create'
	begin
        raiserror(15606,-1,-1,@tabname)
        goto error_abort_exit
	end

	if @action = 'create'
	begin
		-- CHECK CATALOG NAME --
		select @ftcatid = null
		select @ftcatid = ftcatid from sysfulltextcatalogs where name = @ftcat
		if @ftcatid is null
		begin
			raiserror(7641,-1,-1,@ftcat)
			goto error_abort_exit
		end

		-- CHECK INDEX NAME (UNIQUE, SINGLE-KEY, 450-byte MAX, NON-NULLABLE) AND SET BIT IF FOUND --
		if IndexProperty(@objid, @keyname, 'IsUnique') = 1 and
		   IndexProperty(@objid, @keyname, 'UserKeyCount') = 1 and
		   IndexProperty(@objid, @keyname, 'IsHypothetical') = 0 and
		   exists (select * from syscolumns where id = @objid and name = Index_col(@tabname, IndexProperty(@objid, @keyname, 'IndexId'), 1)
				and length <= 450 and isnullable = 0)
		begin
			update sysindexes set status = status | 33554432 where id = @objid
				and name = @keyname and indid > 0 and indid < 255
		end
		else
		begin
			raiserror(15607,-1,-1,@keyname)
			goto error_abort_exit
		end

		-- ADD CATALOG NAME TO SYSOBJECTS --
		update sysobjects set ftcatid = @ftcatid where id = @objid

		-- ADD TO CATALOG
		DBCC CALLFULLTEXT ( 5, @ftcatid, @objid )	-- FTAddURL( @ftcatid, db_id(), @objid )
		if @@error <> 0
			goto error_abort_exit

	end

	if @action = 'drop'
	begin
		-- DROP FROM CATALOG (NO ERROR IF ALREADY DROPPED) --
		DBCC CALLFULLTEXT ( 6, @ftcatid, @objid )	-- FTDropURL( @ftcatid, db_id(), @objid )
		if @@error <> 0
			goto error_abort_exit

		-- DELETE SYSDEPENDS ENTRIES FOR IMAGE COLUMNS, IF ANY --
		delete sysdepends where [id] = @objid and
						  depid = @objid and
						  deptype = 1 and
						  number in ( select colid from syscolumns where [id] = @objid and
																		 type = 34 and
																		 (colstat & 16) = 16 )

		-- REMOVE CATALOG NAME AND BITS FROM SYSTEM TABLES --
		update syscolumns set colstat = colstat & ~80, language = 0 where [id] = @objid
		update sysindexes set status = status & ~33554432 where [id] = @objid
		update sysobjects set status = status & ~200, ftcatid = 0 where [id] = @objid

		-- DELETE NOTIFICATIONS FROM SYSFULLTEXTNOTIFY --
		delete sysfulltextnotify where tableid = @objid

	end

	if @action = 'activate'
	begin

		-- MUST HAVE AT LEAST ONE COLUMN MARKED FOR FULLTEXT INDEXING --
		if not exists (select * from syscolumns where id = @objid and (colstat & 16) = 16)
		begin
			raiserror(15609, -1,-1,@tabname)
			goto error_abort_exit
		end

		-- NO ERROR IF INDEXING ALREADY ACTIVATED --
		if ObjectProperty(@objid, 'TableHasActiveFulltextIndex') = 1
		begin
			rollback tran
			return 0
		end


		update sysobjects set status = status | 8 where id = @objid

		if (ObjectProperty(@objid, 'TableFulltextChangeTrackingOn') = 1)
		begin

			-- STOP A FULL/INCREMENTAL POPULATION FOR THIS TABLE --
			DBCC CALLFULLTEXT ( 12, @ftcatid, @objid, 2 )
			if @@error <> 0
				goto error_abort_exit

			-- DELETE SYSFULLTEXTNOTIFY ENTRIES
			delete sysfulltextnotify where tableid = @objid

			-- START A FULL CRAWL FOR THE TABLE
			DBCC CALLFULLTEXT ( 12, @ftcatid, @objid, 0 )
			if @@error <> 0
				goto error_abort_exit

		end


	end

	if @action = 'deactivate'
	begin
		-- NO ERROR IF INDEXING ALREADY DEACTIVATED --
		if ObjectProperty(@objid, 'TableHasActiveFulltextIndex') = 0
		begin
			rollback tran
			return 0
		end

		-- IF TABLE IS NOT ENABLED FOR NOTIFICATIONS --
		if ObjectProperty(@objid, 'TableFulltextChangeTrackingOn') = 0
		begin
			-- SET STATE TO INACTIVE, SCHEMA-MODIFIED
			update sysobjects set status = ((status & ~72) | 128) where id = @objid
		end
		else
		begin
			-- SET STATE TO INACTIVE
			update sysobjects set status = (status & ~8) where id = @objid
		end

		-- DELETE SYSFULLTEXTNOTIFY ENTRIES
		delete sysfulltextnotify where tableid = @objid

		-- STOP EXISTING CRAWL (IMPLICIT STOP WITH WARNING)
		DBCC CALLFULLTEXT ( 12, @ftcatid, @objid, 2 )
		if @@error <> 0
			goto error_abort_exit


	end

	if @action = 'start_change_tracking'
	begin
		-- ERROR IF TABLE IS NOT ACTIVATED --
		if (ObjectProperty(@objid, 'TableHasActiveFulltextIndex') = 0)
		begin
	        raiserror(15630,-1,-1, @tabname)
		    goto error_abort_exit
		end

		-- ERROR IF TABLE IS ALREADY ENABLED FOR NOTIFICATIONS --
		if ObjectProperty(@objid, 'TableFulltextChangeTrackingOn') = 1
		begin
			raiserror(15631,-1,-1, @tabname)
		    goto error_abort_exit
		end

		-- ERROR IF DATABASE IS IN SINGLE USER MODE --
		if DATABASEPROPERTY(db_name(), 'IsSingleUser') = 1
		begin
			raiserror(15637, -1, -1, @tabname)
		    goto error_abort_exit
		end

		-- CHECK TO SEE IF THERE ARE ANY COLUMNS WHICH ARE NOT IN ROW BLOBS --
		if (select count(*) from syscolumns where
			(id = object_id(@tabname)) and ((xtype = 34) or (xtype = 35) or (xtype = 99)) and
			((colstat & 16) != 0) and (length = 16)) > 0
		begin
			raiserror(15639, -1, -1, @tabname)
		end

		-- STOP EXISTING CRAWL
		DBCC CALLFULLTEXT ( 12, @ftcatid, @objid, 2 )
		if @@error <> 0
			goto error_abort_exit

		-- DELETE SYSFULLTEXTNOTIFY ENTRIES
		delete sysfulltextnotify where tableid = @objid

		select @schemamodified = ObjectProperty(@objid, 'TableIsFulltextSchemaModified')

		-- SET TABLE TO CT ON. SCHEMA MOD. OFF --
		update sysobjects set status = ((status & ~128) | 64) where id = @objid

		-- COMMIT TRAN -- NESCESSARY TO TURN ON CT BEFORE CRAWL IS KICKED OFF --
		commit tran
		if @@error <> 0
			goto error_abort_exit

		if (@schemamodified = 1)
		begin
			-- START A FULL POPULATION FOR THIS TABLE --
			DBCC CALLFULLTEXT ( 12, @ftcatid, @objid, 0 )
			if @@error <> 0
			begin
				-- NEED TO RUN A FULL POPULATION
				raiserror(15644, -1, -1,@tabname, 'start_full')
				return 1
			end
		end
		else
		begin
			-- START AN INCREMENTAL POPULATION FOR THIS TABLE --
			DBCC CALLFULLTEXT ( 12, @ftcatid, @objid, 1 )
			if @@error <> 0
			begin
				-- NEED TO RUN AN INCREMENTAL POPULATION
				raiserror(15644, -1, -1, @tabname, 'start_incremental')
				return 1
			end
		end
		return 0

	end

	if @action = 'stop_change_tracking'
	begin
		-- ERROR IF TABLE IS NOT ACTIVATED --
		if (ObjectProperty(@objid, 'TableHasActiveFulltextIndex') = 0)
		begin
	        raiserror(15630,-1,-1, @tabname)
		    goto error_abort_exit
		end

		if (ObjectProperty(@objid, 'TableFulltextChangeTrackingOn') = 0)
		begin
		    rollback tran
	    	    return 0
		end

		if(ObjectProperty(@objid, 'TableFulltextPopulateStatus') != 0)
		begin
	        raiserror(7640,-1,-1, @tabname)	
		end

		-- DISABLE FULLTEXT AUTO PROPAGATION (NO ERROR IF ALREADY DISABLED) --
		DBCC CALLFULLTEXT ( 9, @objid )	-- FTDisableNotify( db_id(), @objid )
		if @@error <> 0
			goto error_abort_exit

		-- TURN OFF ACTIVE BITS IN SYSOBJECTS --
		update sysobjects set status = status & ~192 where id = @objid

		if ((select count(*) from sysfulltextnotify where tableid = @objid) != 0)
		begin
	        raiserror(7638,-1,-1, @tabname)
		end

		-- DELETE NOTIFICATIONS FROM SYSFULLTEXTNOTIFY --
		delete sysfulltextnotify where tableid = @objid


	end

	if @action = 'start_background_updateindex'
	begin
		-- ERROR IF TABLE IS NOT ACTIVATED --
		if ObjectProperty(@objid, 'TableHasActiveFulltextIndex') = 0
		begin
	        raiserror(15630,-1,-1, @tabname)
		    goto error_abort_exit
		end


		-- ERROR IF TABLE IS NOT ENABLED FOR NOTIFICATIONS --
		if ObjectProperty(@objid, 'TableFulltextChangeTrackingOn') = 0
		begin
	        raiserror(15632,-1,-1, @tabname)
		    goto error_abort_exit
		end

		-- ERROR IF FULLTEXT SCHEMA OF THE TABLE HAS BEEN MODIFIED (SHOULD NEVER HAPPEN)--
		if (ObjectProperty(@objid, 'TableIsFulltextSchemaModified') = 1)
		begin
	        raiserror(15640,-1,-1, @tabname)
		    goto error_abort_exit
		end

		-- ERROR IF TABLE IS ALREADY ENABLED FOR AUTO PROPAGATION --
		if ObjectProperty(@objid, 'TableFulltextBackgroundUpdateIndexOn') = 1
		begin
			raiserror(15633,-1,-1, @tabname)
		    goto error_abort_exit
		end

		-- ENABLE TABLE FOR FULLTEXT AUTO PROPAGATION --
		DBCC CALLFULLTEXT ( 10, @ftcatid, @objid ) -- FTEnableAutoProp( @ftcatid, db_id(), @objid )
		if @@error <> 0
			goto error_abort_exit

		-- TURN ON FULLTEXT AUTOPROPAGATION BIT IN SYSOBJECTS --
		update sysobjects set status = status | 128 where id = @objid
	end

	if @action = 'stop_background_updateindex'
	begin
		-- ERROR IF TABLE IS NOT ACTIVATED --
		if (ObjectProperty(@objid, 'TableHasActiveFulltextIndex') = 0)
		begin
	        raiserror(15630,-1,-1, @tabname)
		    goto error_abort_exit
		end

		if (ObjectProperty(@objid, 'TableFullTextBackgroundUpdateIndexOn') = 0)
		begin
		    rollback tran
		    return 0
		end

		-- DISABLE FULLTEXT AUTO PROPAGATION (NO ERROR IF ALREADY DISABLED) --
		DBCC CALLFULLTEXT ( 9, @objid )	-- FTDisableNotify( db_id(), @objid )
		if @@error <> 0
			goto error_abort_exit

		-- TURN OFF ACTIVE BITS IN SYSOBJECTS --
		update sysobjects set status = status & ~128 where id = @objid
	end

	if @action = 'update_index'
	begin

		-- ERROR IF TABLE IS NOT ENABLED FOR NOTIFICATIONS --
		if ObjectProperty(@objid, 'TableFulltextChangeTrackingOn') = 0
		begin
	        raiserror(15634,-1,-1, @tabname)
		    goto error_abort_exit
		end

		-- ERROR IF TABLE IS NOT ACTIVE ANY MORE --
		if (ObjectProperty(@objid, 'TableHasActiveFulltextIndex') = 0)
		begin
	        raiserror(15630,-1,-1, @tabname)
		    goto error_abort_exit
		end

		-- ERROR IF FULLTEXT SCHEMA OF THE TABLE HAS BEEN MODIFIED -- THIS SHOULD NEVER HAPPEN
		if (ObjectProperty(@objid, 'TableIsFulltextSchemaModified') = 1)
		begin
	        raiserror(15640,-1,-1, @tabname)
		    goto error_abort_exit
		end

		-- ERROR IF DATABASE IS IN SIGNLE USER MODE --
		if DATABASEPROPERTY(db_name(), 'IsSingleUser') = 1
		begin
			raiserror(15637, -1, -1, @tabname)
		    goto error_abort_exit
		end

		DBCC CALLFULLTEXT ( 11, @ftcatid, @objid )	-- FTStartPropagation( db_id(), @ftcatid, @objid )
		if @@error <> 0
			goto error_abort_exit
	end

	if @action = 'start_full'
	begin
		-- ERROR IF TABLE IS NOT ACTIVATED --
		if ObjectProperty(@objid, 'TableHasActiveFulltextIndex') = 0
		begin
	        raiserror(15630,-1,-1, @tabname)
		    goto error_abort_exit
		end

		-- ERROR IF DATABASE IS IN SINGLE USER MODE --
		if DATABASEPROPERTY(db_name(), 'IsSingleUser') = 1
		begin
			raiserror(15637, -1, -1, @tabname)
		    goto error_abort_exit
		end

		-- RAISE WARNING IF POPULATE STATUS OF THE TABLE IS NOT IDLE
		if (ObjectProperty(@objid, 'TableFulltextPopulateStatus') != 0)
		begin
	        raiserror(7636,-1,-1, @tabname)
		    goto error_abort_exit
		end

		-- DELETE SYSFULLTEXTNOTIFY ENTRIES
		delete sysfulltextnotify where tableid = @objid

		-- START A FULL POPULATION FOR THIS TABLE --
		DBCC CALLFULLTEXT ( 12, @ftcatid, @objid, 0 )
		if @@error <> 0
			goto error_abort_exit

		if (ObjectProperty(@objid, 'TableIsFulltextSchemaModified') = 1)
		and (ObjectProperty(@objid, 'TableFulltextChangeTrackingOn') = 0)
			-- SET TABLE SCHEMA-UNMODIFIED
			update sysobjects set status = status & ~128 where id = @objid

	end

	if @action = 'start_incremental'
	begin
		-- ERROR IF TABLE IS NOT ACTIVATED --
		if ObjectProperty(@objid, 'TableHasActiveFulltextIndex') = 0
		begin
	        raiserror(15630,-1,-1, @tabname)
		    goto error_abort_exit
		end

		-- ERROR IF DATABASE IS IN SINGLE USER MODE --
		if DATABASEPROPERTY(db_name(), 'IsSingleUser') = 1
		begin
			raiserror(15637, -1, -1, @tabname)
		    goto error_abort_exit
		end

		-- RAISE WARNING IF POPULATE STATUS OF THE TABLE IS NOT IDLE
		if (ObjectProperty(@objid, 'TableFulltextPopulateStatus') != 0)
		begin
	        raiserror(7636,-1,-1, @tabname)
		    goto error_abort_exit
		end

		-- DELETE SYSFULLTEXTNOTIFY ENTRIES
		delete sysfulltextnotify where tableid = @objid

		-- START AN INCREMENTAL POPULATION FOR THIS TABLE --
		if (ObjectProperty(@objid, 'TableIsFulltextSchemaModified') = 1)
			and (ObjectProperty(@objid, 'TableFulltextChangeTrackingOn') = 0)
			begin
			-- FULL CRAWL IF SCHEMA MODIFIED
			DBCC CALLFULLTEXT ( 12, @ftcatid, @objid, 0 )
			if @@error <> 0
				goto error_abort_exit

			-- SET TABLE SCHEMA-UNMODIFIED
			update sysobjects set status = status & ~128 where id = @objid
		end
		else
		begin
			-- INCREMENTAL CRAWL
			DBCC CALLFULLTEXT ( 12, @ftcatid, @objid, 1 )
			if @@error <> 0
				goto error_abort_exit
		end
	end

	if @action = 'stop'
	begin
		-- ERROR IF TABLE IS NOT ACTIVATED --
		if ObjectProperty(@objid, 'TableHasActiveFulltextIndex') = 0
		begin
	        raiserror(15630,-1,-1, @tabname)
		    goto error_abort_exit
		end

		-- ERROR IF POPULATE STATUS OF THE TABLE IS CRAWLING AND CT ON
		if (ObjectProperty(@objid, 'TableFulltextChangeTrackingOn') = 1)
		and ((ObjectProperty(@objid, 'TableFulltextPopulateStatus') = 1)
		or (ObjectProperty(@objid, 'TableFulltextPopulateStatus') = 2))
		begin
		    raiserror(15642,-1,-1, @tabname)
			goto error_abort_exit
		end

		-- STOP A FULL/INCREMENTAL POPULATION FOR THIS TABLE --
		DBCC CALLFULLTEXT ( 12, @ftcatid, @objid, 2 )
		if @@error <> 0
			goto error_abort_exit
	end

	-- COMMIT TRAN --
	commit tran
	if @@error <> 0
		goto error_abort_exit

	-- SUCCESS --
	return 0

error_abort_exit:
	rollback tran
	return 1	-- sp_fulltext_table
go

---------------------------- sp_fulltext_column -------------------------------

raiserror(15339,-1,-1,'sp_fulltext_column')
go
create proc sp_fulltext_column
    @tabname        nvarchar(517),      -- table name
    @colname        sysname,            -- column name
    @action         varchar(20),        -- add | drop
    @language       int = null,         -- LCID of data in the column
    @type_colname   sysname = null      -- column name, valid if colname is img

as
	-- FULLTEXT MUST BE ACTIVE IN DATABASE --
	if DatabaseProperty(db_name(), 'IsFulltextEnabled') = 0
	begin
		raiserror(15601,-1,-1)
		return 1
	end

	-- VALIDATE PARAMS --
	if @action is null or @action not in ('add','drop')
	begin
		raiserror(15600,-1,-1,'sp_fulltext_column')
		return 1
	end

	-- DISALLOW USER TRANSACTION --
	set implicit_transactions off
	if @@trancount > 0
	begin
		raiserror(15002,-1,-1,'sp_fulltext_column')
		return 1
	end

	-- VALIDATE TABLE NAME --
	--	(1) Must exist in current database
	declare @objid int
	select @objid = object_id(@tabname, 'local')
	if @objid is null
	begin
		declare @curdbname sysname
		select @curdbname = db_name()
		raiserror(15009,-1,-1 ,@tabname, @curdbname)
		return 1
	end
	--	(2) Must be a user table
	if ObjectProperty(@objid, 'IsUserTable') = 0
	begin
		raiserror(15218,-1,-1 ,@tabname)
		return 1
	end

	-- CHECK PERMISSION ON TABLE --
	if (is_member('db_owner') = 0) AND (is_member('db_ddladmin') = 0)
		AND (is_member(user_name(ObjectProperty(@objid, 'ownerid'))) = 0)
	begin
		raiserror(15247,-1,-1)
		return 1
	end

	-- CHECK DATABASE MODE (must not be read-only) --
	if DATABASEPROPERTY(db_name(), 'IsReadOnly') = 1
	begin
		raiserror(15635, -1, -1, 'sp_fulltext_column')
		return 1
	end

	-- BEGIN TRAN AND LOCK TABLE --
	begin tran
	dbcc lockobjectschema(@tabname)
	if @@error <> 0
	begin
		goto error_abort_exit
	end

	-- CHECK FOR CATALOG IN SYSOBJECTS --
	declare @ftcatid smallint
	select @ftcatid = ObjectProperty(@objid, 'TableFulltextCatalogId')

	if @ftcatid = 0
	begin
		raiserror(15606,-1,-1,@tabname)
		goto error_abort_exit
	end

	-- VALIDATE COLUMN NAME (CANNOT BE COMPUTED) --
	declare @typename sysname
	select @typename = type_name(ColumnProperty(@objid, @colname, 'SystemType'))
	if @typename is null OR ColumnProperty(@objid, @colname, 'IsComputed') = 1
	begin
		raiserror(15104,-1,-1,@tabname,@colname)
		goto error_abort_exit
	end

	-- VALIDATE PARAMETERS
	if (@action <> 'add' or @typename <> N'image') and @type_colname is not null
	begin
		raiserror(15600, -1, -1, 'sp_fulltext_column')
		goto error_abort_exit
	end

	if @action = 'add'
	begin
		-- VALIDATE COLUMN TYPE --
		if @typename not in (N'nchar',N'nvarchar',N'ntext',N'char',N'varchar',N'text', N'image')
		begin
			raiserror(15611,-1,-1,@colname,@tabname)
			goto error_abort_exit
		end

		-- LANGUAGE
		if @language is null
			begin
				-- USE THE SERVER DEFAULT WORD BREAKING LANGUAGE
				select @language = value from master.dbo.syscurconfigs where config = 1126
			end
		else
			begin
				-- VALIDATE @LANGUAGE ARGUMENT
				if @language < 0
				begin
					raiserror(15600,-1,-1,'sp_fulltext_column')
					goto error_abort_exit
				end
			end

		update syscolumns set language = @language where id = @objid and name = @colname

		-- IF TABLE HAS ZERO INDEXED COLUMNS (THIS IS THE FIRST COLUMN TO BE ADDED), MARK IT ACTIVE
		if not exists (select * from syscolumns where id = @objid and (colstat & 16) = 16)
			and (ObjectProperty(@objid, 'TableFulltextChangeTrackingOn') = 0)
			and (ObjectProperty(@objid, 'TableIsFulltextSchemaModified') = 0)
		begin
			update sysobjects set status = (status  | 8) where id = @objid
		end

		-- SET THE BIT FOR THIS COLUMN --
		update syscolumns set colstat = colstat | 16 where id = @objid and name = @colname

		-- STOP A FULL/INCREMENTAL POPULATION FOR THIS TABLE --
		DBCC CALLFULLTEXT ( 12, @ftcatid, @objid, 2 )
		if @@error <> 0
			goto error_abort_exit

		if ObjectProperty(@objid, 'TableFulltextChangeTrackingOn') = 1
		begin


			if ObjectProperty(@objid, 'TableHasActiveFulltextIndex') = 1
			begin

				-- DELETE SYSFULLTEXTNOTIFY ENTRIES
				delete sysfulltextnotify where tableid = @objid

				-- START A FULL CRAWL FOR THE TABLE
				DBCC CALLFULLTEXT ( 12, @ftcatid, @objid, 0 )
				if @@error <> 0
					goto error_abort_exit
			end

		end
		else
		begin

			-- SET STATE TO SCHEMA_MODIFIED
			update sysobjects set status = ((status & ~64) | 128) where id = @objid
		end

		if @typename = N'image'
		begin
			-- VALIDATE THAT THE TYPE COLUMN IS GIVEN AND THAT IT IS VALID
			if @type_colname is null
			begin
				raiserror(15600, -1, -1, 'sp_fulltext_column')
				goto error_abort_exit
			end

			declare @typecolname sysname
			select @typecolname = type_name(ColumnProperty(@objid, @type_colname, 'SystemType'))

			-- TYPE COLUMN HAS TO BE A CHARACTER COLUMN
			if @typecolname not in (N'nchar',N'nvarchar',N'char',N'varchar')
			begin
				raiserror(15600 , -1, -1, 'sp_fulltext_column')
				goto error_abort_exit
			end

			-- ADD ENTRY OF COLID IN SYSDEPENDS
			declare @colid smallint
			declare @type_colid smallint

			select @colid = colid from syscolumns where [id] = @objid and name = @colname
			select @type_colid = colid from syscolumns where [id]  = @objid and name = @type_colname

			if not exists ( select [id] from sysdepends
							where  [id] = @objid and
								   depid = @objid and
								   number = @colid )
			begin
				insert into sysdepends ([id], depid, number, depnumber, status, deptype )
						values( @objid, @objid, @colid, @type_colid, 0, 1)
			end

			-- SET BIT INDICATING TYPE COLUMN
			update syscolumns set colstat = colstat | 64 where id = @objid and name = @type_colname
		end

	end
	else
	begin
		-- CLEAR THE BIT & ZERO LCID FOR THIS COLUMN --
		update syscolumns set colstat = colstat & ~16, language = 0
			where id = @objid and name = @colname

		-- IF LAST COLUMN DROPPED
		if not exists (select * from syscolumns where id = @objid and (colstat & 16) = 16)
		begin
			-- STOP A FULL/INCREMENTAL POPULATION FOR THIS TABLE --
			DBCC CALLFULLTEXT ( 12, @ftcatid, @objid, 2 )
			if @@error <> 0
				goto error_abort_exit

			-- IF TABLE HAS NOT BEEN DEACTIVATED
			if ((ObjectProperty(@objid, 'TableHasActiveFulltextIndex') = 1)
				or (ObjectProperty(@objid, 'TableIsFulltextSchemaModified') = 0))
			begin

				-- IF CHANGE-TRACKING IS OFF
				if ObjectProperty(@objid, 'TableFulltextChangeTrackingOn') = 0
				begin
					-- SET TABLE TO SCHEMA UNMODIFIED, INACTIVE (TURN OFF ALL BITS)
					update sysobjects set status = (status & ~200) where id = @objid
				end
				else
				begin
					-- SET TABLE TO INACTIVE
					update sysobjects set status = (status & ~8) where id = @objid
				end
			end
		end
		else
		if ObjectProperty(@objid, 'TableFulltextChangeTrackingOn') = 1
		begin

			-- STOP A FULL/INCREMENTAL POPULATION FOR THIS TABLE --
			DBCC CALLFULLTEXT ( 12, @ftcatid, @objid, 2 )
			if @@error <> 0
				goto error_abort_exit

			if ObjectProperty(@objid, 'TableHasActiveFulltextIndex') = 1
			begin
				-- DELETE SYSFULLTEXTNOTIFY ENTRIES
				delete sysfulltextnotify where tableid = @objid

				-- START A FULL CRAWL FOR THE TABLE
				DBCC CALLFULLTEXT ( 12, @ftcatid, @objid, 0 )
				if @@error <> 0
					goto error_abort_exit
			end

		end
		else
		begin

			-- STOP A FULL/INCREMENTAL POPULATION FOR THIS TABLE --
			DBCC CALLFULLTEXT ( 12, @ftcatid, @objid, 2 )
			if @@error <> 0
				goto error_abort_exit

			-- SET BITS IN SYSOBJECTS
			update sysobjects set status = ((status & ~64) | 128) where id = @objid
		end

		-- IF IMAGE COLUMN, UNBIND FROM THE TYPE COLUMN
		if @typename = N'image'
		begin
			declare @colid1 smallint
			declare @type_colid1 smallint

			select @colid1 = colid from syscolumns where [id] = @objid and name = @colname
			select @type_colid1 = depnumber from sysdepends
					where [id] = @objid and
						 depid = @objid and
						 number = @colid1

			delete sysdepends where [id] = @objid and
									depid = @objid and
									number = @colid1 and
									depnumber = @type_colid1 and
									deptype = 1

			-- CLEAR BIT RELATING THE IMAGE COLUMN AND TYPE COLUMN
			if not exists ( select depnumber from sysdepends 
							where	[id] = @objid and
									depnumber = @type_colid1 and
									deptype = 1 and
									number in (select colid from syscolumns 
											 where	[id] = @objid and
													type = 34 and
													(colstat & 16) = 16) )
			begin
				update syscolumns set colstat = colstat & ~64 where [id] = @objid and colid = @type_colid1
			end
		end

	end

	-- COMMIT TRAN --
	commit tran
	if @@error <> 0
		goto error_abort_exit

	-- SUCCESS --
	return 0

error_abort_exit:
	rollback tran
	return 1	-- sp_fulltext_column
go

---------------------------- sp_help_fulltext_catalogs ------------------------------

raiserror(15339,-1,-1,'sp_help_fulltext_catalogs')
go
create proc sp_help_fulltext_catalogs
	@fulltext_catalog_name		sysname = NULL		-- full-text catalog name
as
	-- FULLTEXT MUST BE ACTIVE IN DATABASE --
	if DatabaseProperty(db_name(), 'IsFulltextEnabled') = 0
	begin
		raiserror(15601,-1,-1)
		return 1
	end

	-- CATALOG MUST EXIST IF SPECIFIED --
	if @fulltext_catalog_name is not null
	begin
		declare @ftcatid smallint
		select @ftcatid = ftcatid from sysfulltextcatalogs where name = @fulltext_catalog_name
		if @ftcatid is null
		begin
			raiserror(7641,-1,-1,@fulltext_catalog_name)
			return 1
		end
	end

	-- RETRIEVE THE DEFAULT PATH --
	DECLARE @def_path as nvarchar(260)
	select @def_path = null
	exec master.dbo.xp_instance_regread 'HKEY_LOCAL_MACHINE',
		'SOFTWARE\Microsoft\MSSQLServer\MSSQLServer','FullTextDefaultPath',
		@def_path OUT

	-- SELECT ANY ROWS THAT MEET THE CRITERIA --
	select CAT.ftcatid,
	   name as NAME,
		   'PATH'= CASE WHEN path is NULL THEN @def_path
						ELSE path
						END,
		   FullTextCatalogProperty(CAT.name, 'PopulateStatus') AS STATUS ,
		   (select COUNT(*)
			  from sysobjects
			  where type='U' and sysobjects.ftcatid = CAT.ftcatid
		   ) as NUMBER_FULLTEXT_TABLES
	from sysfulltextcatalogs as CAT
	where ( @fulltext_catalog_name is null or name = @fulltext_catalog_name )
	order by ftcatid

	-- SUCCESS --
	return 0	-- sp_help_fulltext_catalogs
go

---------------------------- sp_help_fulltext_catalogs_cursor ------------------------------

raiserror(15339,-1,-1,'sp_help_fulltext_catalogs_cursor')
go
create proc sp_help_fulltext_catalogs_cursor
	@cursor_return CURSOR VARYING OUTPUT,
	@fulltext_catalog_name		sysname = NULL		-- full-text catalog name
as
	-- FULLTEXT MUST BE ACTIVE IN DATABASE --
	if DatabaseProperty(db_name(), 'IsFulltextEnabled') = 0
	begin
		raiserror(15601,-1,-1)
		return 1
	end

	-- CATALOG MUST EXIST IF SPECIFIED --
	if @fulltext_catalog_name is not null
	begin
		declare @ftcatid smallint
		select @ftcatid = ftcatid from sysfulltextcatalogs where name = @fulltext_catalog_name
		if @ftcatid is null
		begin
			raiserror(7641,-1,-1,@fulltext_catalog_name)
			return 1
		end
	end

	-- RETRIEVE THE DEFAULT PATH --
	DECLARE @def_path as nvarchar(260)
	select @def_path = null
	exec master.dbo.xp_instance_regread 'HKEY_LOCAL_MACHINE',
		'SOFTWARE\Microsoft\MSSQLServer\MSSQLServer','FullTextDefaultPath',
		@def_path OUT

	-- SELECT ANY ROWS THAT MEET THE CRITERIA --
	set @cursor_return =	CURSOR LOCAL SCROLL DYNAMIC FOR
	select CAT.ftcatid,
	   name as NAME,
	   'PATH'= CASE WHEN path is NULL THEN @def_path
							ELSE path
							END,
		FullTextCatalogProperty(CAT.name, 'PopulateStatus') AS STATUS ,
		(select COUNT(*)
		 from sysobjects
		 where type='U' and sysobjects.ftcatid = CAT.ftcatid
		 ) as NUMBER_FULLTEXT_TABLES
		from sysfulltextcatalogs as CAT
		where ( @fulltext_catalog_name is null or name = @fulltext_catalog_name )
		order by ftcatid

	open @cursor_return

	-- SUCCESS --
	return 0	-- sp_help_fulltext_catalogs_cursor
go

---------------------------- sp_help_fulltext_tables ------------------------------

raiserror(15339,-1,-1,'sp_help_fulltext_tables')
go
create proc sp_help_fulltext_tables
	@fulltext_catalog_name		sysname = NULL, 		-- full-text catalog name
	@table_name nvarchar(517) = NULL	-- table name
as
	-- FULLTEXT MUST BE ACTIVE IN DATABASE --
	if DatabaseProperty(db_name(), 'IsFulltextEnabled') = 0
	begin
		raiserror(15601,-1,-1)
		return 1
	end

	-- CATALOG MUST EXIST IF SPECIFIED --
	declare @ftcatid smallint
	if @fulltext_catalog_name is not null
	begin
		select @ftcatid = ftcatid from sysfulltextcatalogs where name = @fulltext_catalog_name
		if @ftcatid is null
		begin
			raiserror(7641,-1,-1,@fulltext_catalog_name)
			return 1
		end
	end

	if @table_name is not null
	begin
		-- VALIDATE TABLE NAME --
		--	(1) Must exist in current database
		declare @objid int
		select @objid = object_id(@table_name, 'local')
		if @objid is null
		begin
			declare @curdbname sysname
			select @curdbname = db_name()
			raiserror(15009,-1,-1 ,@table_name, @curdbname)
			return 1
		end
		--	(2) Must be a user table (and not a temp table)
		if ObjectProperty(@objid, 'IsUserTable') = 0 OR substring(parsename(@table_name,1),1,1) = '#'
		begin
			raiserror(15218,-1,-1 ,@table_name)
			return 1
		end
	end

	select susr.name as TABLE_OWNER, sobj.name as TABLE_NAME,
		sdex.name as FULLTEXT_KEY_INDEX_NAME,
		ObjectProperty(sobj.id, 'TableFulltextKeyColumn') as FULLTEXT_KEY_COLID,
		ObjectProperty(sobj.id, 'TableHasActiveFulltextIndex') as FULLTEXT_INDEX_ACTIVE,
		scat.name as FULLTEXT_CATALOG_NAME
		from sysobjects as sobj, sysindexes as sdex, sysusers as susr, sysfulltextcatalogs as scat
		where(
				@fulltext_catalog_name is null or
				sobj.ftcatid = @ftcatid
			 ) and
			 (
				@table_name is null or
				sobj.id = @objid
			 ) and
			  sobj.uid = susr.uid and
			  sobj.ftcatid = scat.ftcatid and
			  sdex.status & 33554432 <> 0 and	/* means that this is the index used enforce
												   the uniqueness of the full-text key column */
			  sdex.id = sobj.id
		order by TABLE_OWNER, TABLE_NAME

	-- SUCCESS --
	return 0	-- sp_help_fulltext_tables
go

---------------------------- sp_help_fulltext_tables_cursor ------------------------------
raiserror(15339,-1,-1,'sp_help_fulltext_tables_cursor')
go
create proc sp_help_fulltext_tables_cursor
	@cursor_return CURSOR VARYING OUTPUT,
	@fulltext_catalog_name		sysname = NULL, 		-- full-text catalog name
	@table_name nvarchar(517) = NULL	-- table name
as
	-- FULLTEXT MUST BE ACTIVE IN DATABASE --
	if DatabaseProperty(db_name(), 'IsFulltextEnabled') = 0
	begin
		raiserror(15601,-1,-1)
		return 1
	end

	-- CATALOG MUST EXIST IF SPECIFIED --
	declare @ftcatid smallint
	if @fulltext_catalog_name is not null
	begin
		select @ftcatid = ftcatid from sysfulltextcatalogs where name = @fulltext_catalog_name
		if @ftcatid is null
		begin
			raiserror(7641,-1,-1,@fulltext_catalog_name)
			return 1
		end
	end

	if @table_name is not null
	begin
		-- VALIDATE TABLE NAME --
		--	(1) Must exist in current database
		declare @objid int
		select @objid = object_id(@table_name, 'local')
		if @objid is null
		begin
			declare @curdbname sysname
			select @curdbname = db_name()
			raiserror(15009,-1,-1 ,@table_name, @curdbname)
			return 1
		end
		--	(2) Must be a user table (and not a temp table)
		if ObjectProperty(@objid, 'IsUserTable') = 0
						 OR substring(parsename(@table_name,1),1,1) = '#'
		begin
			raiserror(15218,-1,-1 ,@table_name)
			return 1
		end
	end

	set @cursor_return =	CURSOR LOCAL SCROLL DYNAMIC FOR
	select susr.name as TABLE_OWNER, sobj.name as TABLE_NAME,
		sdex.name as FULLTEXT_KEY_INDEX_NAME,
		ObjectProperty(sobj.id, 'TableFulltextKeyColumn') as FULLTEXT_KEY_COLID,
		ObjectProperty(sobj.id, 'TableHasActiveFulltextIndex') as FULLTEXT_INDEX_ACTIVE,
		scat.name as FULLTEXT_CATALOG_NAME
		from sysobjects as sobj, sysindexes as sdex, sysusers as susr, sysfulltextcatalogs as scat
		where(
				@fulltext_catalog_name is null or
				sobj.ftcatid = @ftcatid
			 ) and
			 (
				@table_name is null or
				sobj.id = @objid
			 ) and
			  sobj.uid = susr.uid and
			  sobj.ftcatid = scat.ftcatid and
			  sdex.status & 33554432 <> 0 and	/* means that this is the index used enforce
												   the uniqueness of the full-text key column */
			  sdex.id = sobj.id
		order by TABLE_OWNER, TABLE_NAME

	open @cursor_return

	-- SUCCESS --
	return 0	-- sp_help_fulltext_tables_cursor
go

---------------------------- sp_help_fulltext_columns ------------------------------
raiserror(15339,-1,-1,'sp_help_fulltext_columns')
go
create proc sp_help_fulltext_columns
	@table_name nvarchar(517) = NULL,		-- table name
	@column_name	sysname = NULL			-- column name
as
	-- FULLTEXT MUST BE ACTIVE IN DATABASE --
	if DatabaseProperty(db_name(), 'IsFulltextEnabled') = 0
	begin
		raiserror(15601,-1,-1)
		return 1
	end

	if @table_name is not null
	begin
		-- VALIDATE TABLE NAME --
		--	(1) Must exist in current database
		declare @objid int
		select @objid = object_id(@table_name, 'local')
		if @objid is null
		begin
			declare @curdbname sysname
			select @curdbname = db_name()
			raiserror(15009,-1,-1 ,@table_name, @curdbname)
			return 1
		end
		--	(2) Must be a user table (and not a temp table)
		if ObjectProperty(@objid, 'IsUserTable') = 0
							 OR substring(parsename(@table_name,1),1,1) = '#'
		begin
			raiserror(15218,-1,-1 ,@table_name)
			return 1
		end

		-- VALIDATE COLUMN NAME (CANNOT BE COMPUTED) --
		if @column_name is not null
		begin
			declare @typename sysname
			select @typename = type_name(ColumnProperty(@objid, @column_name, 'SystemType'))
			if @typename is null OR ColumnProperty(@objid, @column_name, 'IsComputed') = 1
			begin
				raiserror(15104,-1,-1,@table_name,@column_name)
				return 1
			end
		end

	end

	select distinct
		susr.name as TABLE_OWNER,
		sobj.id as TABLE_ID,
		sobj.name as TABLE_NAME,
		scol.name as FULLTEXT_COLUMN_NAME,
		scol.colid as FULLTEXT_COLID,
		b.FT_BLOBTPNAME as FULLTEXT_BLOBTP_COLNAME,
		a.FT_BLOBTPCOLID as FULLTEXT_BLOBTP_COLID,
		scol.language as FULLTEXT_LANGUAGE
	from
		sysobjects as sobj,
 		sysusers as susr,
		syscolumns as scol
		left outer join
			(
			select 	sdep.id			as TABLE_ID,
					sdep.number		as FULLTEXT_COLID,
					sdep.depnumber	as FT_BLOBTPCOLID
			from
					sysdepends as sdep,
					syscolumns as scol
			where
					scol.colid = sdep.number
				and scol.id = sdep.id
				and sdep.deptype = 1
				and ColumnProperty(scol.id, scol.name, 'IsFullTextIndexed') = 1
			) as a
		on (scol.colid = a.FULLTEXT_COLID and scol.id = a.TABLE_ID)
		left outer join
			(
			select 	sdep.id			as TABLE_ID,
					sdep.depnumber	as FT_BLOBTPCOLID,
					scol.name		as FT_BLOBTPNAME,
					sdep.number		as FULLTEXT_COLID
			from
					syscolumns as scol,
					sysdepends as sdep
			where
					scol.colid = sdep.depnumber
				and ColumnProperty(sdep.id, scol.name, 'IsTypeForFullTextBlob') = 1
			) as b
		on (a.FULLTEXT_COLID = b.FULLTEXT_COLID and a.TABLE_ID = b.TABLE_ID)
	where (
			@table_name is null or
			sobj.id = @objid
		  ) and
		  scol.id = sobj.id and
		  sobj.uid = susr.uid and
		  (
			  @column_name is null or
			  scol.name = @column_name
		  ) and
		  ColumnProperty(sobj.id, scol.name, 'IsFullTextIndexed') = 1
	order by TABLE_OWNER, TABLE_NAME, FULLTEXT_COLID

	-- SUCCESS --
	return 0	-- sp_help_fulltext_columns
go

---------------------------- sp_help_fulltext_columns_cursor ------------------------------
raiserror(15339,-1,-1,'sp_help_fulltext_columns_cursor')
go
create proc sp_help_fulltext_columns_cursor
	@cursor_return CURSOR VARYING OUTPUT,
	@table_name nvarchar(517) = NULL,		-- table name
	@column_name	sysname = NULL				-- column name
as
	-- FULLTEXT MUST BE ACTIVE IN DATABASE --
	if DatabaseProperty(db_name(), 'IsFulltextEnabled') = 0
	begin
		raiserror(15601,-1,-1)
		return 1
	end

	if @table_name is not null
	begin
		-- VALIDATE TABLE NAME --
		--	(1) Must exist in current database
		declare @objid int
		select @objid = object_id(@table_name, 'local')
		if @objid is null
		begin
			declare @curdbname sysname
			select @curdbname = db_name()
			raiserror(15009,-1,-1 ,@table_name, @curdbname)
			return 1
		end
		--	(2) Must be a user table (and not a temp table)
		if ObjectProperty(@objid, 'IsUserTable') = 0
								 OR substring(parsename(@table_name,1),1,1) = '#'
		begin
			raiserror(15218,-1,-1 ,@table_name)
			return 1
		end

		-- VALIDATE COLUMN NAME (CANNOT BE COMPUTED) --
		if @column_name is not null
		begin
			declare @typename sysname
			select @typename = type_name(ColumnProperty(@objid, @column_name, 'SystemType'))
			if @typename is null OR ColumnProperty(@objid, @column_name, 'IsComputed') = 1
			begin
				raiserror(15104,-1,-1,@table_name,@column_name)
				return 1
			end
		end
	end

	set @cursor_return =	CURSOR LOCAL SCROLL DYNAMIC FOR
		select distinct
			susr.name as TABLE_OWNER,
			sobj.id as TABLE_ID,
			sobj.name as TABLE_NAME,
			scol.name as FULLTEXT_COLUMN_NAME,
			scol.colid as FULLTEXT_COLID,
			b.FT_BLOBTPNAME as FULLTEXT_BLOBTP_COLNAME,
			a.FT_BLOBTPCOLID as FULLTEXT_BLOBTP_COLID,
			scol.language as FULLTEXT_LANGUAGE
		from
			sysobjects as sobj,
			sysusers as susr,
			syscolumns as scol
			left outer join
				(
				select 	sdep.id			as TABLE_ID,
						sdep.number		as FULLTEXT_COLID,
						sdep.depnumber	as FT_BLOBTPCOLID
				from
						sysdepends as sdep,
						syscolumns as scol
				where
						scol.colid = sdep.number
					and scol.id = sdep.id
					and sdep.deptype = 1
					and ColumnProperty(scol.id, scol.name, 'IsFullTextIndexed') = 1
				) as a
			on (scol.colid = a.FULLTEXT_COLID and scol.id = a.TABLE_ID)
			left outer join
				(
				select 	sdep.id			as TABLE_ID,
						sdep.depnumber	as FT_BLOBTPCOLID,
						scol.name		as FT_BLOBTPNAME,
						sdep.number		as FULLTEXT_COLID
				from
						syscolumns as scol,
						sysdepends as sdep
				where
						scol.colid = sdep.depnumber
					and ColumnProperty(sdep.id, scol.name, 'IsTypeForFullTextBlob') = 1
				) as b
			on (a.FULLTEXT_COLID = b.FULLTEXT_COLID and a.TABLE_ID = b.TABLE_ID)
		where (
				@table_name is null or
				sobj.id = @objid
			  ) and
			  scol.id = sobj.id and
			  sobj.uid = susr.uid and
			  (
				  @column_name is null or
				  scol.name = @column_name
			  ) and
			  ColumnProperty(sobj.id, scol.name, 'IsFullTextIndexed') = 1
		order by TABLE_OWNER, TABLE_NAME, FULLTEXT_COLID

	open @cursor_return

	-- SUCCESS --
	return 0	-- sp_help_fulltext_columns_cursor
go

-- GRANT PUBLIC ACCESS --
grant execute on sp_fulltext_service to public
grant execute on sp_fulltext_database to public
grant execute on sp_fulltext_catalog to public
grant execute on sp_fulltext_table to public
grant execute on sp_fulltext_column to public
grant execute on sp_help_fulltext_catalogs to public
grant execute on sp_help_fulltext_catalogs_cursor to public
grant execute on sp_help_fulltext_tables  to public
grant execute on sp_help_fulltext_tables_cursor  to public
grant execute on sp_help_fulltext_columns  to public
grant execute on sp_help_fulltext_columns_cursor  to public
-- sp_fulltext_getdata is NOT for CUSTOMER USE! (do not doc)
go

/*************************  END FULLTEXT INDEXES *****************************/

checkpoint
go

/**********************  SQLTRACE STORED PROCEDURES **************************/

if object_id('sp_trace_getdata','P') IS NOT NULL
	drop procedure sp_trace_getdata
go

raiserror(15339,-1,-1,'sp_trace_getdata')
go
create procedure sp_trace_getdata
	(@traceid int,
	 @records int = 0
	)
as

select * from OpenRowset(TrcData, @traceid, @records)
go 

/*********************** END SQLTRACE PROCEDURES *****************************/

checkpoint
go


if object_id('sp_describe_cursor','P') IS NOT NULL
	drop procedure sp_describe_cursor
if object_id('sp_describe_cursor_columns','P') IS NOT NULL
	drop procedure sp_describe_cursor_columns
if object_id('sp_describe_cursor_tables','P') IS NOT NULL
	drop procedure sp_describe_cursor_tables
if object_id('sp_cursor_list','P') IS NOT NULL
	drop procedure sp_cursor_list
go

raiserror(15339,-1,-1,'sp_describe_cursor')
go
-- Creation of sp_describe_cursor

Create Procedure sp_describe_cursor
(  @cursor_return CURSOR VARYING OUTPUT,
   @cursor_source nvarchar (30),
   @cursor_identity nvarchar (128)
)
AS

declare @scope int

/* Check if the cursor exists by name or handle. */
If cursor_status ( @cursor_source, @cursor_identity ) >= -1
begin
	if lower(convert(varchar(30), @cursor_source)) = 'local' OR
		lower(convert(varchar(128), @cursor_source)) = 'variable'
		select @scope = 1
	else
	if lower(convert(varchar(30), @cursor_source)) = 'global'
		select @scope = 2


	set @cursor_return =  CURSOR LOCAL SCROLL DYNAMIC FOR
			    	SELECT reference_name, cursor_name, cursor_scope,
					status, model, concurrency, scrollable,
					open_status, cursor_rows, fetch_status,
					column_count, row_count, last_operation,
					cursor_handle
			    	FROM master.dbo.syscursorrefs scr, master.dbo.syscursors sc
			    	WHERE 	scr.cursor_scope = @scope and
				  	scr.reference_name = @cursor_identity and
				  	scr.cursor_handl = sc.cursor_handle
				ORDER BY 3, 1
				FOR READ ONLY
	open @cursor_return

end
go

raiserror(15339,-1,-1,'sp_describe_cursor_columns')
go
-- Creation of sp_describe_cursor_columns

Create Procedure sp_describe_cursor_columns
(  @cursor_return CURSOR VARYING OUTPUT,
   @cursor_source nvarchar (30),
   @cursor_identity nvarchar (128)
)
AS

declare @scope int

/* Check if the cursor exists by name or handle. */
If cursor_status ( @cursor_source, @cursor_identity ) >= -1
begin
	if lower(convert(varchar(30), @cursor_source)) = 'local' OR
		lower(convert(varchar(128), @cursor_source)) = 'variable'
		select @scope = 1
	else
	if lower(convert(varchar(30), @cursor_source)) = 'global'
		select @scope = 2

	set @cursor_return =  	CURSOR LOCAL SCROLL DYNAMIC FOR
				SELECT column_name, ordinal_position, column_characteristics_flags,
					column_size, data_type_sql, column_precision,
					column_scale, order_position, order_direction,
					hidden_column, columnid, objectid, dbid, dbname
				FROM master.dbo.syscursorrefs scr, master.dbo.syscursorcolumns scc
				WHERE 	scr.cursor_scope = @scope and
					scr.reference_name = @cursor_identity and
					scr.cursor_handl = scc.cursor_handle
				ORDER BY 2
				FOR READ ONLY
	open @cursor_return

end
go

raiserror(15339,-1,-1,'sp_describe_cursor_tables')
go
-- Creation of sp_describe_cursor_tables

Create Procedure sp_describe_cursor_tables
(  @cursor_return CURSOR VARYING OUTPUT,
   @cursor_source nvarchar (30),
   @cursor_identity nvarchar (128)
)
AS

declare @scope int

/* Check if the cursor exists by name or handle. */
If cursor_status ( @cursor_source, @cursor_identity ) >= -1
begin
	if lower(convert(varchar(30), @cursor_source)) = 'local' OR
		lower(convert(varchar(128), @cursor_source)) = 'variable'
		select @scope = 1
	else
	if lower(convert(varchar(30), @cursor_source)) = 'global'
		select @scope = 2

	set @cursor_return =  	CURSOR LOCAL SCROLL DYNAMIC FOR
				SELECT table_owner, table_name, optimizer_hint, lock_type, server_name, objectid, dbid, dbname
				FROM master.dbo.syscursorrefs scr, master.dbo.syscursortables sct
				WHERE 	scr.cursor_scope = @scope and
					scr.reference_name = @cursor_identity and
					scr.cursor_handl = sct.cursor_handle
				FOR READ ONLY
	open @cursor_return
end
go

raiserror(15339,-1,-1,'sp_cursor_list')
go
-- Creation of sp_cursor_list

create procedure sp_cursor_list
(
   @cursor_return CURSOR VARYING OUTPUT,
   @cursor_scope int
)
AS

if (@cursor_scope < 1) OR (@cursor_scope > 3)
	begin
		/* Raise an error: ?The value of parameter  is invalid? */
		raiserror ( 16902, 1, 1,N'sp_cursor_list', N'@cursor_scope')
		return (1)
	end

if ( @cursor_scope  < 3)
begin
	set @cursor_return =  CURSOR LOCAL SCROLL DYNAMIC FOR
			    	SELECT reference_name, cursor_name, cursor_scope,
					status, model, concurrency, scrollable,
					open_status, cursor_rows, fetch_status,
					column_count, row_count, last_operation,
					cursor_handle
				FROM master.dbo.syscursorrefs scr, master.dbo.syscursors sc
				WHERE 	scr.cursor_scope = @cursor_scope AND
					scr.cursor_handl = sc.cursor_handle
				FOR READ ONLY
end
else
begin
	set @cursor_return =  CURSOR LOCAL SCROLL DYNAMIC FOR
			    	SELECT reference_name, cursor_name, cursor_scope,
					status, model, concurrency, scrollable,
					open_status, cursor_rows, fetch_status,
					column_count, row_count, last_operation,
					cursor_handle
				FROM master.dbo.syscursorrefs scr, master.dbo.syscursors sc
				WHERE scr.cursor_handl = sc.cursor_handle
				FOR READ ONLY
end
open @cursor_return
go

/************************  END-CURSORINFO-STORED-PROCS  ***********************/

-- GRANT PUBLIC ACCESS --
grant execute on sp_describe_cursor to public
grant execute on sp_describe_cursor_columns to public
grant execute on sp_describe_cursor_tables to public
grant execute on sp_cursor_list to public
go

checkpoint
go

print ' '
print 'Granting privileges on system tables.'
go

grant select on syscharsets to public
grant select on syscolumns to public
grant select on syscomments to public
grant select on sysconfigures to public
grant select on sysdatabases to public
grant select on sysdepends to public
grant select on sysdevices to public
grant select on sysindexes to public
grant select on syslanguages to public
go


checkpoint
go

grant select on sysmessages to public
grant select on sysobjects to public
grant select on sysprotects to public
grant select on syspermissions to public
grant select on syssegments to public
grant select on sysservers to public
grant select on systypes to public
grant select on sysusers to public
grant select on sysreferences to public
grant select on sysfiles to public
grant select on sysfilegroups to public
grant select on sysfulltextcatalogs to public
go

DENY SELECT (providerstring) ON sysservers TO PUBLIC
go

checkpoint
go

print ' '
print 'Granting privileges on system stored procedures'
go

grant execute on MS_sqlctrs_users to public
go

grant execute on sp_user_counter1   to public
grant execute on sp_user_counter2   to public
grant execute on sp_user_counter3   to public
grant execute on sp_user_counter4   to public
grant execute on sp_user_counter5   to public
grant execute on sp_user_counter6   to public
grant execute on sp_user_counter7   to public
grant execute on sp_user_counter8   to public
grant execute on sp_user_counter9   to public
grant execute on sp_user_counter10  to public

checkpoint
go

grant execute on sp_addmessage to public
grant execute on sp_addumpdevice to public
grant execute on sp_addtype to public
grant execute on sp_altermessage to public
grant execute on sp_bindefault to public
grant execute on sp_bindrule to public
grant execute on sp_checknames to public
grant execute on sp_configure to public
grant execute on sp_cursor to public
grant execute on sp_cursorclose to public
grant execute on sp_cursorfetch to public
grant execute on sp_cursoropen to public
grant execute on sp_cursoroption to public
grant execute on sp_dboption to public
grant execute on sp_bindsession to public
grant execute on sp_getbindtoken to public
grant execute on sp_dbcmptlevel to public
grant execute on sp_executesql to public
grant execute on sp_prepare to public
grant execute on sp_execute to public
grant execute on sp_prepexec to public
grant execute on sp_prepexecrpc to public
grant execute on sp_unprepare to public
grant execute on sp_cursorprepare to public
grant execute on sp_cursorexecute to public
grant execute on sp_cursorprepexec to public
grant execute on sp_cursorunprepare to public
grant execute on sp_createorphan to public
grant execute on sp_droporphans to public
grant execute on sp_reset_connection to public
grant execute on sp_getschemalock to public
grant execute on sp_releaseschemalock to public
grant execute on sp_xml_preparedocument to public
grant execute on sp_xml_removedocument to public
go

checkpoint
go
grant execute on sp_diskdefault to public
grant execute on sp_dropdevice to public

grant execute on sp_depends to public
grant execute on sp_dropmessage to public
grant execute on sp_droptype to public
go
grant execute on sp_help to public
grant execute on sp_helpconstraint to public
grant execute on sp_helpdb to public
grant execute on sp_helpfile to public
grant execute on sp_helpfilegroup to public
grant execute on sp_helpdevice to public
grant execute on sp_helpextendedproc to public
grant execute on sp_helpgroup to public
grant execute on sp_helpindex to public
grant execute on sp_helpstats to public
grant execute on sp_helplanguage to public
grant execute on sp_helplog to public
grant execute on sp_helplogins to public
grant execute on sp_helpremotelogin to public
grant execute on sp_helprotect to public
grant execute on sp_helpsort to public
grant execute on sp_helpsql to public
grant execute on sp_helptext to public
grant execute on sp_helpuser to public
grant execute on sp_lock to public
grant execute on sp_getapplock to public
grant execute on sp_releaseapplock to public
grant select on system_function_schema.fn_helpcollations to public
grant select on system_function_schema.fn_servershareddrives to public
grant select on system_function_schema.fn_virtualfilestats to public
grant select on system_function_schema.fn_virtualservernodes to public

go

checkpoint
go

grant execute on sp_objectfilegroup to public
grant execute on sp_procoption to public
grant execute on sp_recompile to public
grant execute on sp_remoteoption to public
grant execute on sp_rename to public
grant execute on sp_renamedb to public
grant execute on sp_spaceused to public
grant execute on sp_sqlexec to public
go

grant execute on sp_blockcnt to public
grant execute on sp_tableoption to public
grant execute on sp_invalidate_textptr to public
grant execute on sp_indexoption to public
grant execute on sp_tempdbspace to public
go

grant execute on sp_unbindefault to public
grant execute on sp_unbindrule to public
grant execute on sp_validname to public
grant execute on sp_validlang to public
grant execute on sp_who to public
grant execute on sp_who2 to public
grant execute on sp_updatestats to public
grant execute on sp_createstats to public
grant execute on sp_autostats to public
grant execute on sp_helptrigger to public
grant execute on sp_addextendedproperty to public
grant execute on sp_updateextendedproperty to public
grant execute on sp_dropextendedproperty to public
grant execute on sp_addremotelogin to public
grant execute on sp_dropremotelogin to public
go

--grant select on system function
grant select on system_function_schema.fn_listextendedproperty to public
go

-- grant access to access resync query sps
grant execute on sp_resyncprepare to public
grant execute on sp_resyncexecute to public
grant execute on sp_resyncexecutesql to public
grant execute on sp_resyncuniquetable to public

checkpoint
go

print ' '
print 'Granting privileges on extended stored procedures'
go

grant execute on xp_sprintf to public
grant execute on xp_sscanf to public
grant execute on xp_msver to public
go

print ' '
print 'Granting privileges on objects in model database.'
go
use model
go
grant select on sysconstraints to public
grant select on syscolumns to public
grant select on syscomments to public
grant select on sysdepends to public
grant select on sysindexes to public
grant select on sysobjects to public
grant select on sysprotects to public
grant select on syspermissions to public
grant select on syssegments to public
grant select on systypes to public
grant select on sysusers to public
grant select on sysreferences to public
grant select on sysfiles to public
grant select on sysfilegroups to public
grant select on sysfulltextcatalogs to public
go

use master
go

checkpoint
go

/*
** Set some things now that sp_configure has been created.
*/
print ' '
print 'Making final database configuration settings.'
go

print 'Forcing config for remote access to 1'
exec sp_configure 'remote access',1
go

exec sp_MS_upd_sysobj_category 2  --Now do catalog updates.

go

--- Enable auto-create and update of statistics
exec sp_dboption 'tempdb', 'auto create statistics', 'on'
exec sp_dboption 'master', 'auto create statistics', 'on'
exec sp_dboption 'model', 'auto create statistics', 'on'
go
exec sp_dboption 'tempdb', 'auto update statistics', 'on'
exec sp_dboption 'master', 'auto update statistics', 'on'
exec sp_dboption 'model', 'auto update statistics', 'on'
go
exec sp_dboption 'master', 'torn page detection', 'on'
exec sp_dboption 'model', 'torn page detection', 'on'
go

exec sp_dboption 'master','trunc. log on chkpt.','true'
go
exec sp_configure 'allow updates',0
reconfigure with override

print ' '
-- print 'Checking objects created by ProcSyst.SQL ....'
go

declare @vdt varchar(99)
select  @vdt = convert(varchar,getdate(),113)
raiserror('Finishing Install\ProcSyst.SQL at  %s',0,1,@vdt)
go

checkpoint
go
-- - -----

-- test
-- junk
