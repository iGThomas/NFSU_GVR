/********************************************************************************************/
/* XPSTAR.SQL - Extended Stored Procedures for the SQL Server Enterprise Components         */
/*
** Copyright Microsoft, Inc. 1994 - 2000
** All Rights Reserved.
*/
/********************************************************************************************/
use master
go

/********************************************************************************************/
/* DROP EXISTING SP's and t                                                                 */
/********************************************************************************************/

if exists (select * from master.dbo.sysobjects where name = N'xp_regread' and type = N'X')
	exec sp_dropextendedproc N'xp_regread'
go

if exists (select * from master.dbo.sysobjects where name = N'xp_regwrite' and type = N'X')
	exec sp_dropextendedproc N'xp_regwrite'
go

if exists (select * from master.dbo.sysobjects where name = N'xp_regdeletevalue' and type = N'X')
	exec sp_dropextendedproc N'xp_regdeletevalue'
go

if exists (select * from master.dbo.sysobjects where name = N'xp_regdeletekey' and type = N'X')
	exec sp_dropextendedproc N'xp_regdeletekey'
go

if exists (select * from master.dbo.sysobjects where name = N'xp_regaddmultistring' and type = N'X')
	exec sp_dropextendedproc N'xp_regaddmultistring'
go

if exists (select * from master.dbo.sysobjects where name = N'xp_regremovemultistring' and type = N'X')
	exec sp_dropextendedproc N'xp_regremovemultistring'
go

if exists (select * from master.dbo.sysobjects where name = N'xp_regenumkeys' and type = N'X')
	exec sp_dropextendedproc N'xp_regenumkeys'
go

if exists (select * from master.dbo.sysobjects where name = N'xp_regenumvalues' and type = N'X')
	exec sp_dropextendedproc N'xp_regenumvalues'
go

if exists (select * from master.dbo.sysobjects where name = N'xp_instance_regread' and type = N'X')
	exec sp_dropextendedproc N'xp_instance_regread'
go

if exists (select * from master.dbo.sysobjects where name = N'xp_instance_regwrite' and type = N'X')
	exec sp_dropextendedproc N'xp_instance_regwrite'
go

if exists (select * from master.dbo.sysobjects where name = N'xp_instance_regdeletevalue' and type = N'X')
	exec sp_dropextendedproc N'xp_instance_regdeletevalue'
go

if exists (select * from master.dbo.sysobjects where name = N'xp_instance_regdeletekey' and type = N'X')
	exec sp_dropextendedproc N'xp_instance_regdeletekey'
go

if exists (select * from master.dbo.sysobjects where name = N'xp_instance_regaddmultistring' and type = N'X')
	exec sp_dropextendedproc N'xp_instance_regaddmultistring'
go

if exists (select * from master.dbo.sysobjects where name = N'xp_instance_regremovemultistring' and type = N'X')
	exec sp_dropextendedproc N'xp_instance_regremovemultistring'
go

if exists (select * from master.dbo.sysobjects where name = N'xp_instance_regenumkeys' and type = N'X')
	exec sp_dropextendedproc N'xp_instance_regenumkeys'
go

if exists (select * from master.dbo.sysobjects where name = N'xp_instance_regenumvalues' and type = N'X')
	exec sp_dropextendedproc N'xp_instance_regenumvalues'
go

if exists (select * from master.dbo.sysobjects where name = N'xp_getprotocoldllinfo' and type = N'X')
	exec sp_dropextendedproc N'xp_getprotocoldllinfo'
go

if exists (select * from master.dbo.sysobjects where name = N'xp_readerrorlog' and type = N'X')
	exec sp_dropextendedproc N'xp_readerrorlog'
go

if exists (select * from master.dbo.sysobjects where name = N'sp_readerrorlog' and type = N'P')
	drop procedure sp_readerrorlog
go

if exists (select * from master.dbo.sysobjects where name = N'xp_enumerrorlogs' and type = N'X')
	exec sp_dropextendedproc N'xp_enumerrorlogs'
go

if exists (select * from master.dbo.sysobjects where name = N'sp_enumerrorlogs' and type = N'P')
	drop procedure sp_enumerrorlogs
go

if exists (select * from master.dbo.sysobjects where name = N'xp_getfiledetails' and type = N'X')
	exec sp_dropextendedproc N'xp_getfiledetails'
go

if exists (select * from master.dbo.sysobjects where name = N'xp_servicecontrol' and type = N'X')
	exec sp_dropextendedproc N'xp_servicecontrol'
go

if exists (select * from master.dbo.sysobjects where name = N'xp_availablemedia' and type = N'X')
	exec sp_dropextendedproc N'xp_availablemedia'
go

if exists (select * from master.dbo.sysobjects where name = N'xp_dirtree' and type = N'X')
	exec sp_dropextendedproc N'xp_dirtree'
go

if exists (select * from master.dbo.sysobjects where name = N'xp_eventlog' and type = N'X')
	exec sp_dropextendedproc N'xp_eventlog'
go

if exists (select * from master.dbo.sysobjects where name = N'sp_eventlog' and type = N'P')
	drop procedure sp_eventlog
go

if exists (select * from master.dbo.sysobjects where name = N'xp_fixeddrives' and type = N'X')
	exec sp_dropextendedproc N'xp_fixeddrives'
go

if exists (select * from master.dbo.sysobjects where name = N'xp_subdirs' and type = N'X')
	exec sp_dropextendedproc N'xp_subdirs'
go

if exists (select * from master.dbo.sysobjects where name = N'xp_getnetname' and type = N'X')
	exec sp_dropextendedproc N'xp_getnetname'
go

if exists (select * from master.dbo.sysobjects where name = N'xp_snmp_getstate' and type = N'X')
	exec sp_dropextendedproc N'xp_snmp_getstate'
go

if exists (select * from master.dbo.sysobjects where name = N'xp_snmp_raisetrap' and type = N'X')
	exec sp_dropextendedproc N'xp_snmp_raisetrap'
go

if exists(select * from master.dbo.sysobjects where name = N'xp_sqltrace' and type = N'X')
	exec sp_dropextendedproc N'xp_sqltrace'
go

if exists(select * from master.dbo.sysobjects where name = N'sp_IsMBCSLeadByte')
	exec sp_dropextendedproc N'sp_IsMBCSLeadByte'
go

if exists(select * from master.dbo.sysobjects where name = N'sp_GetMBCSCharLen' and type = N'X')
	exec sp_dropextendedproc N'sp_GetMBCSCharLen'
go

if exists (select * from master.dbo.sysobjects where name = N'xp_check_query_results' and type = N'X')
	exec sp_dropextendedproc N'xp_check_query_results'
go

if exists (select * from master.dbo.sysobjects where name = N'xp_enum_activescriptengines' and type = N'X')
	exec sp_dropextendedproc N'xp_enum_activescriptengines'
go

if exists (select * from master.dbo.sysobjects where name = N'xp_sqlagent_monitor' and type = N'X')
	exec sp_dropextendedproc N'xp_sqlagent_monitor'
go

if exists (select * from master.dbo.sysobjects where name = N'xp_sqlagent_notify' and type = N'X')
	exec sp_dropextendedproc N'xp_sqlagent_notify'
go

if exists (select * from master.dbo.sysobjects where name = N'xp_sqlagent_enum_jobs' and type = N'X')
	exec sp_dropextendedproc N'xp_sqlagent_enum_jobs'
go

if exists (select * from master.dbo.sysobjects where name = N'xp_sqlagent_is_starting' and type = N'X')
	exec sp_dropextendedproc N'xp_sqlagent_is_starting'
go

if exists (select * from master.dbo.sysobjects where name = N'xp_sqlagent_param' and type = N'X')
	exec sp_dropextendedproc N'xp_sqlagent_param'
go

if exists (select * from master.dbo.sysobjects where name = N'xp_sqlagent_proxy_account' and type = N'X')
	exec sp_dropextendedproc N'xp_sqlagent_proxy_account'
go

if exists (select * from master.dbo.sysobjects where name = N'xp_sqlagent_msx_account' and type = N'X')
	exec sp_dropextendedproc N'xp_sqlagent_msx_account'
go

if exists (select * from master.dbo.sysobjects where name = N'xp_fileexist' and type = N'X')
	exec sp_dropextendedproc N'xp_fileexist'
go

if exists (select * from master.dbo.sysobjects where name = N'xp_ntsec_enumdomains' and type = N'X')
	exec sp_dropextendedproc N'xp_ntsec_enumdomains'
go

if exists (select * from master.dbo.sysobjects where name = N'xp_ntsec_enumusers' and type = N'X')
	exec sp_dropextendedproc N'xp_ntsec_enumusers'
go

if exists (select * from master.dbo.sysobjects where name = N'xp_ntsec_enumgroups' and type = N'X')
	exec sp_dropextendedproc N'xp_ntsec_enumgroups'
go

if exists (select * from master.dbo.sysobjects where name = N'xp_msx_enlist' and type = N'X')
	exec sp_dropextendedproc N'xp_msx_enlist'
go

if exists (select * from master.dbo.sysobjects where name = N'xp_sqlmaint' and type = N'X')
	exec sp_dropextendedproc N'xp_sqlmaint'
go

if exists (select * from master.dbo.sysobjects where name = N'xp_get_tape_devices' and type = N'X')
	exec sp_dropextendedproc N'xp_get_tape_devices'
go

if exists (select * from master.dbo.sysobjects where name = N'xp_enum_oledb_providers' and type = N'X')
	exec sp_dropextendedproc N'xp_enum_oledb_providers'
go

if exists (select * from master.dbo.sysobjects where name = N'sp_enum_oledb_providers' and type = N'P')
	drop procedure sp_enum_oledb_providers
go

if exists (select * from master.dbo.sysobjects where name = N'xp_prop_oledb_provider' and type = N'X')
	exec sp_dropextendedproc N'xp_prop_oledb_provider'
go

if exists (select * from master.dbo.sysobjects where name = N'sp_prop_oledb_provider' and type = N'P')
	drop procedure sp_prop_oledb_provider
go

if exists (select * from master.dbo.sysobjects where name = N'xp_updateFTSSQLAccount' and type = N'X')
	exec sp_dropextendedproc N'xp_updateFTSSQLAccount'
go

if exists(select * from sysobjects where name = N'xp_sqlregister' and type = N'X')
	exec sp_dropextendedproc N'xp_sqlregister'
go

if exists (select * from sysobjects where name = N'sp_sqlregister' and type = N'P')
	drop procedure sp_sqlregister
go

if exists(select * from sysobjects where name = N'xp_sqlinventory' and type = N'X')
	exec sp_dropextendedproc N'xp_sqlinventory'
go

if exists (select * from master.dbo.sysobjects where name = N'xp_writesqlinfo' and type = N'X')
	exec sp_dropextendedproc N'xp_writesqlinfo'
go

if exists (select * from master.dbo.sysobjects where name = N'xp_unc_to_drive' and type = N'X')
	exec sp_dropextendedproc N'xp_unc_to_drive'
go

if exists (select * from sysobjects where name = N'xp_MSplatform' and type = N'X')
	exec sp_dropextendedproc N'xp_MSplatform'
go

if exists (select * from sysobjects where name = N'xp_MSFullText' and type = N'X')
	exec sp_dropextendedproc N'xp_MSFullText'
go

if exists (select * from sysobjects where name = N'xp_IsNTAdmin' and type = N'X')
	exec sp_dropextendedproc N'xp_IsNTAdmin'
go

if exists (select * from sysobjects where name = N'xp_SetSQLSecurity' and type = N'X')
	exec sp_dropextendedproc N'xp_SetSQLSecurity'
go

if exists (select * from sysobjects where name = N'xp_GetAdminGroupName' and type = N'X')
	exec sp_dropextendedproc N'xp_GetAdminGroupName'
go

/********************************************************************************************/
/* If sp_MSgetversion exists as SP drop it otherwise drop the extended proc                 */
/********************************************************************************************/
if exists (select * from master.dbo.sysobjects where name = N'sp_MSgetversion' and type = N'P')
	drop procedure sp_MSgetversion
else if exists (select * from master.dbo.sysobjects where name = N'sp_MSgetversion' and type = N'X')
	exec sp_dropextendedproc N'sp_MSgetversion'
go

/********************************************************************************************/
/* Drop Active Directory related SPs and XPs                                                */
/********************************************************************************************/
if exists (select * from sysobjects where name = N'xp_MSnt2000' and type = N'X')
	exec sp_dropextendedproc N'xp_MSnt2000'
go

if exists (select * from sysobjects where name = N'xp_MSADEnabled' and type = N'X')
	exec sp_dropextendedproc N'xp_MSADEnabled'
go

if exists (select * from sysobjects where name = N'xp_MSADSIReg' and type = N'X')
	exec sp_dropextendedproc N'xp_MSADSIReg'
go

if exists (select * from sysobjects where name = N'xp_MSADSIObjReg' and type = N'X')
	exec sp_dropextendedproc N'xp_MSADSIObjReg'
go

if exists (select * from sysobjects where name = N'xp_MSADSIObjRegDB' and type = N'X')
	exec sp_dropextendedproc N'xp_MSADSIObjRegDB'
go

if exists (select * from sysobjects where name = N'xp_MSLocalSystem' and type = N'X')
	exec sp_dropextendedproc N'xp_MSLocalSystem'
go

if exists (select * from sysobjects where name = N'xp_adsirequest' and type = N'X')
	exec sp_dropextendedproc N'xp_adsirequest'
go

if exists (select * from sysobjects where name = N'sp_ActiveDirectory_SCP' and type = N'P')
	drop procedure sp_ActiveDirectory_SCP
go

if exists (select * from sysobjects where name = N'sp_ActiveDirectory_Obj' and type = N'P')
	drop procedure sp_ActiveDirectory_Obj
go

if exists (select * from sysobjects where name = N'sp_ActiveDirectory_Start' and type = N'P')
	drop procedure sp_ActiveDirectory_Start
go

if exists (select * from master.dbo.sysobjects where name = N'sp_resolve_logins' and type = N'P')
	drop procedure sp_resolve_logins
go

/********************************************************************************************/
exec sp_MS_upd_sysobj_category 1
go
/********************************************************************************************/

/********************************************************************************************/
/* Create XP's                                                                              */
/********************************************************************************************/

print N'Creating extended stored procedure xp_regread'
go
sp_addextendedproc N'xp_regread', N'xpstar.dll'
go
grant execute on xp_regread to public
go

print N'Creating extended stored procedure xp_regwrite'
go
sp_addextendedproc N'xp_regwrite', N'xpstar.dll'
go

print N'Creating extended stored procedure xp_regdeletevalue'
go
sp_addextendedproc N'xp_regdeletevalue', N'xpstar.dll'
go

print N'Creating extended stored procedure xp_regaddmultistring'
go
sp_addextendedproc N'xp_regaddmultistring', N'xpstar.dll'
go

print N'Creating extended stored procedure xp_regremovemultistring'
go
sp_addextendedproc N'xp_regremovemultistring', N'xpstar.dll'
go

print N'Creating extended stored procedure xp_regenumkeys'
go
sp_addextendedproc N'xp_regenumkeys', N'xpstar.dll'
go

print N'Creating extended stored procedure xp_regenumvalues'
go
sp_addextendedproc N'xp_regenumvalues', N'xpstar.dll'
go

print N'Creating extended stored procedure xp_regdeletekey'
go
sp_addextendedproc N'xp_regdeletekey', N'xpstar.dll'
go


print N'Creating extended stored procedure xp_instance_regread'
go
sp_addextendedproc N'xp_instance_regread', N'xpstar.dll'
go
grant execute on xp_instance_regread to public
go

print N'Creating extended stored procedure xp_instance_regwrite'
go
sp_addextendedproc N'xp_instance_regwrite', N'xpstar.dll'
go

print N'Creating extended stored procedure xp_instance_regdeletevalue'
go
sp_addextendedproc N'xp_instance_regdeletevalue', N'xpstar.dll'
go

print N'Creating extended stored procedure xp_instance_regaddmultistring'
go
sp_addextendedproc N'xp_instance_regaddmultistring', N'xpstar.dll'
go

print N'Creating extended stored procedure xp_instance_regremovemultistring'
go
sp_addextendedproc N'xp_instance_regremovemultistring', N'xpstar.dll'
go

print N'Creating extended stored procedure xp_instance_regenumkeys'
go
sp_addextendedproc N'xp_instance_regenumkeys', N'xpstar.dll'
go

print N'Creating extended stored procedure xp_instance_regenumvalues'
go
sp_addextendedproc N'xp_instance_regenumvalues', N'xpstar.dll'
go

print N'Creating extended stored procedure xp_instance_regdeletekey'
go
sp_addextendedproc N'xp_instance_regdeletekey', N'xpstar.dll'
go


print N'Creating extended stored procedure xp_getprotocoldllinfo'
go
sp_addextendedproc N'xp_getprotocoldllinfo', N'xpstar.dll'
go

print N'Creating extended stored procedure xp_readerrorlog'
go
sp_addextendedproc N'xp_readerrorlog', N'xpstar.dll'
go

print N'Creating stored procedure sp_readerrorlog'
go
create proc sp_readerrorlog(
	@p1		int = 0,
	@p2		varchar(255) = NULL,
	@p3		varchar(255) = NULL,
	@p4		varchar(255) = NULL)
as
begin

	IF (not is_srvrolemember(N'securityadmin') = 1)
	begin
	   raiserror(15003,-1,-1, N'securityadmin')
	   return (1)
	end
	if (@p1 = 0)
		exec master.dbo.xp_readerrorlog
	else if (@p2 is NULL)
		exec master.dbo.xp_readerrorlog @p1
	else
		exec master.dbo.xp_readerrorlog @p1,@p2,@p3,@p4
end
go
grant execute on sp_readerrorlog to public
go

print N'Creating extended stored procedure xp_enumerrorlogs'
go
sp_addextendedproc N'xp_enumerrorlogs',N'xpstar.dll'
go

print N'Creating stored procedure sp_enumerrorlogs'
go
create proc sp_enumerrorlogs
as
begin

	IF (not is_srvrolemember(N'securityadmin') = 1)
	begin
	   raiserror(15003,-1,-1, N'securityadmin')
	   return (1)
	end
	exec master.dbo.xp_enumerrorlogs
end
go
grant execute on sp_enumerrorlogs to public
go

print N'Creating extended stored procedure xp_getfiledetails'
go
sp_addextendedproc N'xp_getfiledetails',N'xpstar.dll'
go
grant execute on xp_getfiledetails to public
go

print N'Creating extended stored procedure xp_servicecontrol'
go
sp_addextendedproc N'xp_servicecontrol',N'xpstar.dll'
go

print N'Creating extended stored procedure xp_availablemedia'
go
sp_addextendedproc N'xp_availablemedia',N'xpstar.dll'
go

print N'Creating extended stored procedure xp_dirtree'
go
sp_addextendedproc N'xp_dirtree',N'xpstar.dll'
go
grant exec on xp_dirtree to public
go

print N'Creating extended stored procedure xp_eventlog'
go
sp_addextendedproc N'xp_eventlog',N'xpstar.dll'
go

print N'Creating stored procedure sp_eventlog'
go
create proc sp_eventlog(
	@p1		varchar(255) = NULL,
	@p2		int = NULL,
	@p3		int = NULL,
	@p4		int = NULL )
as
begin

	if (not is_srvrolemember(N'securityadmin') = 1)
	begin
	   raiserror(15003,-1,-1, N'securityadmin')
	   return (1)
	end
	exec master.dbo.xp_eventlog @p1,@p2,@p3,@p3
end
go
grant execute on sp_eventlog to public
go


print N'Creating extended stored procedure xp_fixeddrives'
go
sp_addextendedproc N'xp_fixeddrives',N'xpstar.dll'
go
grant exec on xp_fixeddrives to public
go

print N'Creating extended stored procedure xp_subdirs'
go
sp_addextendedproc N'xp_subdirs',N'xpstar.dll'
go

print N'Creating extended stored procedure xp_getnetname'
go
sp_addextendedproc N'xp_getnetname',N'xpstar.dll'
go
grant execute on xp_getnetname to public
go

print N'Creating extended stored procedure sp_IsMBCSLeadByte'
go
sp_addextendedproc N'sp_IsMBCSLeadByte',N'xpstar.dll'
go
grant execute on sp_IsMBCSLeadByte to public
go

print N'Creating extended stored procedure sp_GetMBCSCharLen'
go
sp_addextendedproc N'sp_GetMBCSCharLen',N'xpstar.dll'
go
grant execute on sp_GetMBCSCharLen to public
go

print N'Creating extended stored procedure xp_sqlagent_monitor'
go
sp_addextendedproc N'xp_sqlagent_monitor',N'xpstar.dll'
go

print N'Creating extended stored procedure xp_sqlagent_notify'
go
sp_addextendedproc N'xp_sqlagent_notify',N'xpstar.dll'
go

print N'Creating extended stored procedure xp_sqlagent_enum_jobs'
go
sp_addextendedproc N'xp_sqlagent_enum_jobs',N'xpstar.dll'
go

print N'Creating extended stored procedure xp_sqlagent_is_starting'
go
sp_addextendedproc N'xp_sqlagent_is_starting',N'xpstar.dll'
go

print N'Creating extended stored procedure xp_sqlagent_param'
go
sp_addextendedproc N'xp_sqlagent_param',N'xpstar.dll'
go

print N'Creating extended stored procedure xp_sqlagent_proxy_account'
go
sp_addextendedproc N'xp_sqlagent_proxy_account',N'xpstar.dll'
go

print N'Creating extended stored procedure xp_sqlagent_msx_account'
go
exec sp_addextendedproc N'xp_sqlagent_msx_account',N'xpstar.dll'
go

print N'Creating extended stored procedure xp_enum_activescriptengines'
go
sp_addextendedproc N'xp_enum_activescriptengines',N'xpstar.dll'
go
grant execute on xp_enum_activescriptengines to public
go

print N'Creating extended stored procedure xp_fileexist'
go
sp_addextendedproc N'xp_fileexist',N'xpstar.dll'
go
grant execute on xp_fileexist to public
go

print N'Creating extended stored procedure xp_ntsec_enumdomains'
go
sp_addextendedproc N'xp_ntsec_enumdomains',N'xpstar.dll'
go
grant execute on xp_ntsec_enumdomains to public
go

print N'Creating extended stored procedure xp_msx_enlist'
go
sp_addextendedproc N'xp_msx_enlist',N'xpstar.dll'
go

print N'Creating extended stored procedure xp_sqlmaint'
go
sp_addextendedproc N'xp_sqlmaint',N'xpstar.dll'
go

print N'Creating extended stored procedure xp_get_tape_devices'
go
sp_addextendedproc N'xp_get_tape_devices',N'xpstar.dll'
go

print N'Creating extended stored procedure xp_enum_oledb_providers'
go
sp_addextendedproc N'xp_enum_oledb_providers',N'xpstar.dll'
go

print N'Creating stored procedure sp_enum_oledb_providers'
go
create proc sp_enum_oledb_providers
as
begin

	IF (not is_srvrolemember(N'setupadmin') = 1)
	begin
	   raiserror(15003,-1,-1, N'setupadmin')
	   return (1)
	end
	exec master.dbo.xp_enum_oledb_providers
end
go
grant execute on sp_enum_oledb_providers to public
go

print N'Creating extended stored procedure xp_prop_oledb_provider'
go
sp_addextendedproc N'xp_prop_oledb_provider',N'xpstar.dll'
go

print N'Creating stored procedure sp_prop_oledb_provider'
go
create proc sp_prop_oledb_provider (
@p1 nvarchar(255)=NULL)
as
begin

	IF (not is_srvrolemember(N'setupadmin') = 1)
	begin
	   raiserror(15003,-1,-1, N'setupadmin')
	   return (1)
	end
	exec master.dbo.xp_prop_oledb_provider @p1
end
go
grant execute on sp_prop_oledb_provider to public
go

print N'Creating extended stored procedure xp_updateFTSSQLAccount'
go
sp_addextendedproc N'xp_updateFTSSQLAccount',N'xpstar.dll'
go

print N'Creating extended stored procedure sp_MSgetversion'
go
sp_addextendedproc N'sp_MSgetversion',N'xpstar.dll'
go
grant execute on sp_MSgetversion to public
go

print N'Creating extended stored procedure xp_unc_to_drive'
go
sp_addextendedproc N'xp_unc_to_drive', N'xpstar.dll'
go
grant execute on xp_unc_to_drive to public
go

print N'Creating extended stored procedure xp_MSplatform'
go
sp_addextendedproc N'xp_MSplatform',N'xpstar.dll'
go
grant execute on xp_MSplatform to public
go

print N'Creating extended stored procedure xp_MSFullText'
go
sp_addextendedproc N'xp_MSFullText',N'xpstar.dll'
go
grant execute on xp_MSFullText to public
go

print N'Creating extended stored procedure xp_IsNTAdmin'
go
sp_addextendedproc N'xp_IsNTAdmin',N'xpstar.dll'
go
grant execute on xp_IsNTAdmin to public
go

print N'Creating extended stored procedure xp_SetSQLSecurity'
go
sp_addextendedproc N'xp_SetSQLSecurity',N'xpstar.dll'
go

print N'Creating extended stored procedure xp_GetAdminGroupName'
go
sp_addextendedproc N'xp_GetAdminGroupName',N'xpstar.dll'
go
grant execute on xp_GetAdminGroupName to public
go

/********************************************************************************************/
/* Create Active Directory related XPs and SPs                                              */
/* Do not grant permissions on XPs to public                                                */
/********************************************************************************************/
print N'Creating extended stored procedure xp_MSnt2000'
go
sp_addextendedproc N'xp_MSnt2000',N'xpstar.dll'
go
grant execute on xp_MSnt2000 to public
go

print N'Creating extended stored procedure xp_MSADEnabled'
go
sp_addextendedproc N'xp_MSADEnabled',N'xpstar.dll'
go
grant execute on xp_MSADEnabled to public
go

print N'Creating extended stored procedure xp_MSADSIReg'
go
sp_addextendedproc N'xp_MSADSIReg',N'xpstar.dll'
go

print N'Creating extended stored procedure xp_MSADSIObjReg'
go
sp_addextendedproc N'xp_MSADSIObjReg',N'xpstar.dll'
go

print N'Creating extended stored procedure xp_MSADSIObjRegDB'
go
sp_addextendedproc N'xp_MSADSIObjRegDB',N'xpstar.dll'
go

print N'Creating extended stored procedure xp_MSLocalSystem'
go
sp_addextendedproc N'xp_MSLocalSystem',N'xpstar.dll'
go
grant execute on xp_MSLocalSystem to public
go

print N'Creating extended stored procedure xp_adsirequest'
go
sp_addextendedproc N'xp_adsirequest',N'xpstar.dll'
go

print N'Creating stored procedure sp_ActiveDirectory_Start'
go
create proc sp_ActiveDirectory_Start
as
begin
   /* check permissions */
   IF (not is_srvrolemember(N'sysadmin') = 1)
   begin
      raiserror(15003,-1,-1, N'sysadmin')
      return 1
   end

   /* Are we running on Windows 2000 or NT4 SP5 with AD enabled?  Continue only if TRUE */
   DECLARE @retval   INT
   EXECUTE @retval = master.dbo.xp_MSADEnabled
   if (@retval = 0)
      begin
      /* Is the server a Standard or Enterpriser server? Continue only if TRUE */
      IF ((PLATFORM() & 0x100) <> 0x100) -- Not on Desktop or MSDE
         begin
            exec(N'master..sp_ActiveDirectory_SCP N''create_with_db'', 1')
         end
      end
end
go
grant execute on sp_ActiveDirectory_Start to public
go


print N'Creating stored procedure sp_ActiveDirectory_SCP'
go
create proc sp_ActiveDirectory_SCP
       @Action  nvarchar(20) = N'create',    -- create_noupdate, create_with_db, create, update, delete, shutdown
       @Startup int = 0                      -- 0 for non-startup, non-zero if called from server startup
as
begin
   /* create_noupdate         : create the SCP object, if it exists already, update it.                                     */
   /*                           create the DB objects only if they don't exists yet.  Do not update the existig DB objects. */
   /* create_with_db          : create the SCP object, if it exsits already, update it.                                     */
   /*                           Create all the DB objects under the SCP object.  If a DB object exists already, update it.  */
   /* create (DEFAULT)        : create the SCP object, if it exists already, update it.                                     */
   /* update                  : update the SCP object.                                                                      */
   /* shutdown                : mark the SCP object to indicate not running, but don't delete it.                           */
   /* delete                  : delete the SCP object and all the objects below it.                                         */

   SET NOCOUNT ON

   DECLARE @retval int
   DECLARE @SQLADSI_COM_ERROR int
   DECLARE @SQLADSI_UNEXP_ERROR int
   DECLARE @SQLADSI_SCP_NOT_FOUND int
   DECLARE @SQLADSI_SVC_ACCT_ERROR int
   DECLARE @SQLADSI_CANNOT_START_HLP int
   DECLARE @SQLADSI_TIMEOUT_WAIT_HLP int
   DECLARE @SQLADSI_AD_NOT_INSTALLED int
   DECLARE @SQLADSI_PROXY_ACCT_ERROR int

   SELECT @SQLADSI_COM_ERROR = 536870913
   SELECT @SQLADSI_UNEXP_ERROR = 536870914
   SELECT @SQLADSI_SCP_NOT_FOUND = 536870915
   SELECT @SQLADSI_SVC_ACCT_ERROR = 536870916
   SELECT @SQLADSI_CANNOT_START_HLP = 536870917
   SELECT @SQLADSI_TIMEOUT_WAIT_HLP = 536870918
   SELECT @SQLADSI_AD_NOT_INSTALLED = 536870919
   SELECT @SQLADSI_PROXY_ACCT_ERROR = 536870920

   /* check permissions */
   IF (not is_srvrolemember(N'sysadmin') = 1)
   begin
      raiserror(15003,-1,-1, N'sysadmin')
      return 1
   end

   /* check parameters */
   if (@Action is null OR UPPER(@Action) not in (N'CREATE', N'UPDATE', N'DELETE', N'SHUTDOWN', N'CREATE_WITH_DB', N'CREATE_NOUPDATE'))
   begin
      raiserror(14266, -1, -1, N'@Action', N'CREATE, UPDATE, DELETE, SHUTDOWN, CREATE_WITH_DB, CREATE_NOUPDATE')
      return 1
   end

   declare @nAction nvarchar(3)
   declare @Tmp nvarchar(10)
   select @Tmp = UPPER(@Action)
   if (UPPER(@Tmp) like N'CRE%')
      select @nAction = N'1'
   else if (UPPER(@Tmp) like N'UPD%')
      select @nAction = N'2'
   else if (UPPER(@Tmp) like N'DEL%')
      select @nAction = N'3'
   else if (UPPER(@Tmp) like N'SHU%')
      select @nAction = N'4'

   /* are we running on Windows 2000 or NT4 SP5 with AD enabled?  continue only if TRUE */
   EXECUTE @retval = master.dbo.xp_MSADEnabled
   if (@retval = 0)
   begin
      /* Get the correct path for xpadsi.exe */
      declare @Data nvarchar(256)
      exec master.dbo.xp_instance_regread N'HKEY_LOCAL_MACHINE', N'SOFTWARE\Microsoft\MSSQLServer\Setup', N'SQLPath', @param = @Data OUT, @no_output = N'no_output'

      declare @BlankIndex int
      select @BlankIndex = charindex(N' ', @Data)
      if (@BlankIndex is NULL)
          select @BlankIndex = 0

      /* Gather information */
      declare @InstanceName sysname
      declare @ServerName sysname
      select @InstanceName = convert(sysname, serverproperty(N'InstanceName'))
      select @ServerName = convert(sysname, serverproperty(N'ServerName'))
      if (@InstanceName is NULL)
         select @InstanceName = N'MSSQLSERVER'

      /* Need to create registry values only if create or update.  Delete registry when delete */
	  if (@nAction <> N'3')
	  begin
          EXECUTE @retval = master.dbo.xp_MSADSIReg @InstanceName, @nAction, @ServerName
      end
      if (@retval = 0)
      begin
         /* call xp with the valid parameters */
         DECLARE @command NVARCHAR(512)
         DECLARE @nStartup NVARCHAR(5)
         if (@Startup = 0)
            select @nStartup = N'0'
         else
            select @nStartup = N'1'
         if (@BlankIndex <> 0)
            SELECT @command = N'""' + @Data + N'\Binn\' + N'xpadsi.exe' +  N'"" ' + @InstanceName + N' ' + @nAction +  N' 1 ' + @nStartup
         else
            SELECT @command = @Data + N'\Binn\' + N'xpadsi.exe ' + @InstanceName + N' ' + @nAction +  N' 1 ' + @nStartup

         EXECUTE @retval = master.dbo.xp_cmdshell @command
         if (@retval = 0)
         begin
		    /* we successfully delete the SCP and all its children,  let's remove the registry keys/values for them */
	        if (@nAction = N'3')
		    begin
                EXECUTE @retval = master.dbo.xp_MSADSIReg @InstanceName, @nAction, @ServerName
				if (@retval <> 0)
				begin
			        raiserror(14303, -1, -1, N'sp_ActiveDirectory_SCP')
					return 1
				end
			end
            /* Get in only if caller asked for create with DB objects */
            if (UPPER(@Action) like N'CREATE_WITH%') or (UPPER(@Action) like N'CREATE_NOU%')
            begin
               /* After we created the SCP object, we create all the database objects */

               /* Note that for performance reason, we want to create all the registry entries in one connection */
               EXECUTE @retval = master.dbo.xp_MSADSIObjRegDB @InstanceName, @ServerName

               if (UPPER(@Action) like N'CREATE_WITH%')
               begin
                  declare hC cursor for select name from master.dbo.sysdatabases
               end else begin
                  declare hC cursor for select * from msdb.dbo.ADSINewDBs
               end

           	   declare @DBname sysname
	              open hC
           	   fetch next from hC into @DBname

           	   while (@@FETCH_STATUS = 0)
               begin
                  /* Do the AD part, continue even if we got error from one create */
                  if (@BlankIndex <> 0)
                     SELECT @command = N'""' + @Data + N'\Binn\' + N'xpadsi.exe ' + N'" ' + @InstanceName + N' 1 2 ' + N'"' + @DBname + N'""'
                  else
                     SELECT @command = @Data + N'\Binn\' + N'xpadsi.exe ' + @InstanceName + N' 1 2 ' + N'""' + @DBname + N'""'
                  EXECUTE master.dbo.xp_cmdshell @command

          	   	   fetch next from hC into @DBname
           	   end

              	close hC
              	deallocate hC

               /* Get rid of the worker table, which was created by master.dbo.xp_MSADSIObjRegDB */
               drop table msdb.dbo.ADSINewDBs
            end
            return 0
         end else
         begin
            if @retval = @SQLADSI_COM_ERROR 
                RAISERROR(14350, -1, -1)
            else if @retval = @SQLADSI_UNEXP_ERROR 
                RAISERROR(14351, -1, -1)
            else if @retval = @SQLADSI_SCP_NOT_FOUND 
                RAISERROR(14352, -1, -1)
            else if @retval = @SQLADSI_SVC_ACCT_ERROR 
                RAISERROR(14353, -1, -1)
            else if @retval = @SQLADSI_CANNOT_START_HLP 
                RAISERROR(14354, -1, -1)
            else if @retval = @SQLADSI_TIMEOUT_WAIT_HLP 
                RAISERROR(14355, -1, -1)
            else if @retval = @SQLADSI_AD_NOT_INSTALLED 
                RAISERROR(14356, -1, -1)
            else if @retval = @SQLADSI_PROXY_ACCT_ERROR 
                RAISERROR(14358, -1, -1)
            /* Failed */
            return 1
         end
      end else
      begin
         raiserror(14303, -1, -1, N'sp_ActiveDirectory_SCP')
         return 1
      end
   end else
   begin
      raiserror(14359, -1, -1)
      return 1
   end
end
go
grant execute on sp_ActiveDirectory_SCP to public
go

print N'Creating stored procedure sp_ActiveDirectory_Obj'
go
create proc sp_ActiveDirectory_Obj
       @Action          nvarchar(10) = N'create',    -- create, update, delete
       @ObjType         nvarchar(15) = N'database',    -- database, publication
       @ObjName         sysname  = null,        -- object name
       @DatabaseName    sysname = null,         -- database name for publication object
       @GUIDName        sysname = null          -- GUID for publication update and delete
as
begin
   /* cerate : create the object under the current SCP object. */
   /* update : update the object under the SCP object.         */
   /* delete : delete the object under the SCP object.         */

   SET NOCOUNT ON

   DECLARE @isdbowner int
   DECLARE @cmd nvarchar(255)
   DECLARE @commonname nvarchar(300)
   DECLARE @retcode int
   DECLARE @nAction nvarchar(3)
   DECLARE @Tmp nvarchar(10)
   DECLARE @dbname sysname

   DECLARE @retval int
   DECLARE @SQLADSI_COM_ERROR int
   DECLARE @SQLADSI_UNEXP_ERROR int
   DECLARE @SQLADSI_SCP_NOT_FOUND int
   DECLARE @SQLADSI_SVC_ACCT_ERROR int
   DECLARE @SQLADSI_CANNOT_START_HLP int
   DECLARE @SQLADSI_TIMEOUT_WAIT_HLP int
   DECLARE @SQLADSI_AD_NOT_INSTALLED int
   DECLARE @SQLADSI_PROXY_ACCT_ERROR int

   SELECT @SQLADSI_COM_ERROR = 536870913
   SELECT @SQLADSI_UNEXP_ERROR = 536870914
   SELECT @SQLADSI_SCP_NOT_FOUND = 536870915
   SELECT @SQLADSI_SVC_ACCT_ERROR = 536870916
   SELECT @SQLADSI_CANNOT_START_HLP = 536870917
   SELECT @SQLADSI_TIMEOUT_WAIT_HLP = 536870918
   SELECT @SQLADSI_AD_NOT_INSTALLED = 536870919
   SELECT @SQLADSI_PROXY_ACCT_ERROR = 536870920

   /* check permissions
   IF (not is_srvrolemember(N'sysadmin') = 1)
   begin
      raiserror(15003,-1,-1, N'sysadmin')
      return 1
   end
   */

   /* If publication object, we need both object name and database name */
   if ((UPPER(@ObjType) in (N'PUBLICATION')) and ((@ObjName is null) or (@DatabaseName is null)))
   begin
      raiserror(14200, -1, -1, N'@ObjName or @DatabaseName')
      return 1
   end


   /* check parameters */
   if (@Action is null OR UPPER(@Action) not in (N'CREATE', N'UPDATE', N'DELETE'))
   begin
      raiserror(14266, -1, -1, N'@Action', N'CREATE, UPDATE, DELETE')
      return 1
   end
   if (@ObjType is null OR UPPER(@ObjType) not in (N'DATABASE', N'REPOSITORY', N'PUBLICATION'))
   begin
      raiserror(14266, -1, -1, N'@ObjType', N'DATABASE, REPOSITORY, PUBLICATION')
      return 1
   end
   if (@ObjName is null)
   begin
      raiserror(14200, -1, -1, N'@ObjName')
      return 1
   end

   /* If publication object update or delete, we need GUID also */
   if ((UPPER(@ObjType) in (N'PUBLICATION')) and UPPER(@Action) in (N'UPDATE', N'DELETE') and (@GUIDName is null))
   begin
      raiserror(14200, -1, -1, N'@GUIDNName')
      return 1
   end

   if (UPPER(@ObjType) in (N'PUBLICATION'))
      select @dbname = @DatabaseName
   else
      select @dbname = @ObjName

-- Make sure the database exists
--
   if not exists (select * from master.dbo.sysdatabases where name = @dbname)
   begin
      raiserror(15010,-1,-1,@dbname)
      return (1)
   end

   /* Check permissions.  */
   SELECT @cmd = 'USE ' + quotename(@dbname) + ' SELECT @isdbowner = is_member(''db_owner'')'

   EXEC @retcode = sp_executesql @cmd, N'@isdbowner int output', @isdbowner output
   IF @@error <> 0 or @retcode <> 0
      return 1

   IF (is_srvrolemember('sysadmin') <> 1 and isnull(@isdbowner, 0) <> 1)
   BEGIN
      raiserror(21050, 14, -1)
      return 1
   END

   /* common name length check */ 
   if (UPPER(@ObjType) in (N'PUBLICATION'))
       SELECT @commonname = @ObjName + N':' + @DatabaseName
   else
       SELECT @commonname = @ObjName
  
   IF (LEN(@commonname) > 64)
      RAISERROR(14357, -1, -1, @commonname)
       
   select @Tmp = UPPER(@Action)
   if (UPPER(@Tmp) like N'CRE%')
      select @nAction = N'1'
   else if (UPPER(@Tmp) like N'UPD%')
      select @nAction = N'2'
   else if (UPPER(@Tmp) like N'DEL%')
      select @nAction = N'3'

   declare @nObjType nvarchar(3)
   select @Tmp = UPPER(@ObjType)
   if (UPPER(@Tmp) like N'DATAB%')
      select @nObjType = N'2'
   else if (UPPER(@Tmp) like N'REPOS%')
      select @nObjType = N'3'
   else if (UPPER(@Tmp) like N'PUBL%')
      select @nObjType = N'4'

   /* are we running on Windows 2000 or NT4 SP5 with AD enabled?  continue only if TRUE */
   EXECUTE @retval = master.dbo.xp_MSADEnabled
   if (@retval = 0)
   begin
      /* prepare parameters */
      declare @InstanceName sysname
      declare @ServerName sysname
      select @InstanceName = convert(sysname, serverproperty(N'InstanceName'))
      select @ServerName = convert(sysname, serverproperty(N'ServerName'))
      if (@InstanceName is NULL)
         select @InstanceName = N'MSSQLSERVER'

      /* Need to create registry values only if create or update. */
	  if (@nAction <> N'3')
	  begin
	      EXECUTE @retval = master.dbo.xp_MSADSIObjReg @InstanceName, @nAction, @nObjType, @ObjName, @DatabaseName, @ServerName
      end
      if (@retval = 0)
      begin
         /* call xp with the valid parameters, xp_cmdshell expects double quote begin and end */
         DECLARE @args NVARCHAR(512)
         if ((@nObjType like N'4') and (@nAction like N'1'))
         begin
            /* PUBLICATION creation */
            SELECT @args = @InstanceName + N' ' + @nAction +  N' ' + @nObjType + N' '  + quotename(@ObjName, N'"') + N' ' + quotename(@DatabaseName, N'"') 
         end else if ((@nObjType like N'4') and (@nAction not like N'1'))
         begin
            /* PUBLICATION update or delete */
            SELECT @args = @InstanceName + N' ' + @nAction +  N' ' + @nObjType + N' ' + quotename(@ObjName, N'"') + N' ' + quotename(@DatabaseName, N'"') + N' ' + @GUIDName
         end else
         begin
            /* Non PUBLICATION objects */
            SELECT @args = @InstanceName + N' ' + @nAction +  N' ' + @nObjType + N' ' + quotename(@ObjName, N'"')
         end

		 EXECUTE @retval = master.dbo.xp_adsirequest @args
		 if (@retval = 0)
		 begin
	        if (@nAction = N'3')
		    begin
				EXECUTE @retval = master.dbo.xp_MSADSIObjReg @InstanceName, @nAction, @nObjType, @ObjName, @DatabaseName, @ServerName
				if (@retval <> 0)
				begin
                    raiserror(14303, -1, -1, N'sp_ActiveDirectory_Obj')
					return 1
				end
			end
		 end
         else
         begin
            if @retval = @SQLADSI_COM_ERROR 
                RAISERROR(14350, -1, -1)
            else if @retval = @SQLADSI_UNEXP_ERROR 
                RAISERROR(14351, -1, -1)
            else if @retval = @SQLADSI_SCP_NOT_FOUND 
                RAISERROR(14352, -1, -1)
            else if @retval = @SQLADSI_SVC_ACCT_ERROR 
                RAISERROR(14353, -1, -1)
            else if @retval = @SQLADSI_CANNOT_START_HLP 
                RAISERROR(14354, -1, -1)
            else if @retval = @SQLADSI_TIMEOUT_WAIT_HLP 
                RAISERROR(14355, -1, -1)
            else if @retval = @SQLADSI_AD_NOT_INSTALLED 
                RAISERROR(14356, -1, -1)
            else if @retval = @SQLADSI_PROXY_ACCT_ERROR 
                RAISERROR(14358, -1, -1)
   
            /* Failed */
            return 1
         end
      end else
      begin
         raiserror(14303, -1, -1, N'sp_ActiveDirectory_Obj')
         return 1
      end
   end else
   begin
      raiserror(14304, -1, -1, N'sp_ActiveDirectory_Obj')
      return 1
   end
end
go
grant execute on sp_ActiveDirectory_Obj to public
go

-- =============================================
-- BOF SQL Tools entries
-- =============================================

if object_id(N'sp_MSget_current_activity',N'P') IS NOT NULL
	drop procedure sp_MSget_current_activity

if object_id(N'sp_MSset_current_activity',N'P') IS NOT NULL
	drop procedure sp_MSset_current_activity

if object_id(N'sp_MSobjsearch',N'P') IS NOT NULL
	drop procedure sp_MSobjsearch

if object_id(N'sp_MStrace_start',N'P') IS NOT NULL
	drop procedure sp_MStrace_start

if object_id(N'sp_MStrace_stop',N'P') IS NOT NULL
	drop procedure sp_MStrace_stop

if object_id(N'sp_MShasdbaccess',N'P') IS NOT NULL
	drop procedure sp_MShasdbaccess
go

raiserror(15339,-1,-1,N'sp_MSget_current_activity')
go
-- =============================================
-- sp_MSget_current_activity
-- =============================================
create procedure dbo.sp_MSget_current_activity @id int = 0, @option int = 0, @obj nvarchar(386) = null, @spid int = 0
as

if (@id = 0)
begin
    raiserror(N'No SPID specified (spid = %d)', 1, 1, @id)
    return(-1)
end

if (@option <= 0 or @option > 5)
begin
    raiserror(N'Invalid option %d', 1, 1, @option)
    return(-1)
end

declare @stmt as nvarchar(4000)

-- =============================================
-- make tables SPID depended
-- =============================================
declare @locktab as sysname
declare @proctab as sysname

set @locktab = N'##lockinfo' + rtrim(convert(nvarchar(5), @id))
set @proctab = N'##procinfo' + rtrim(convert(nvarchar(5), @id))

if (@option = 1)
begin
    -- process info (overview of all processes by SPID)
    set @stmt = N'select [Process ID], [User], [Database], [Status], [Open Transactions], [Command], [Application], [Wait Time], [Wait Type], [Wait Resource], [CPU], [Physical IO], [Memory Usage], [Login Time], [Last Batch], [Host], [Net Library], [Net Address], [Blocked By], [Blocking], [Execution Context ID] from ' + @proctab + ' order by [Process ID],[Execution Context ID]'
end
else if (@option = 2)
begin
    -- distinct spid list (old)
    -- set @stmt = N'select [Process ID], [Blocking], [Blocked By] from ' @proctab + ' order by [Process ID]'

    -- distinct spid list, only spids with locks
    set @stmt = N'select distinct L.[Process ID], P.[Blocking], P.[Blocked By] from ' + @locktab + ' L, ' + @proctab + ' P where L.[Process ID] = P.[Process ID] order by L.[Process ID]'
end
else if (@option = 3)
begin
    -- distinct object list
    set @stmt = N'select distinct [Object] from ' + @locktab + ' order by [Object]'
end
else if (@option = 4)
begin
    -- locks per spid
    if (@spid = 0)
    begin
        raiserror(N'Error @spid parameter not specified (option %d)', 1, 1, @option)
        return(-1)
    end
    set @stmt = N'select [Object], [Lock Type], [Mode], [Status], [Owner], [Index], [Resource] from ' + @locktab + ' where [Process ID] = ' + rtrim(convert(nvarchar(10), @spid)) + ' order by [Object]'
end
else if (@option = 5)
begin
    -- locks per object
    if (@obj is null)
    begin
        raiserror(N'Error @obj parameter not specified (option %d)', 1, 1, @option)
        return(-1)
    end
    -- locked object is db
    if parsename(@obj,3) is null
    begin
        set @stmt = N'select [Process ID], [Lock Type], [Mode], [Status], [Owner], [Index], [Resource] from ' + @locktab + ' where [Object] = ''' + @obj + ''' and [ObjID] = 0'
    end
    -- locked object is table
    else
    begin
        set @stmt = N'select [Process ID], [Lock Type], [Mode], [Status], [Owner], [Index], [Resource] from ' + @locktab + ' where [Object] = ''' + parsename(@obj,3) + '.' + parsename(@obj,2) + '.' + parsename(@obj,1) + ''''
    end
end
exec (@stmt)
return(0)
-- =============================================
-- end sp_MSget_current_activity
-- =============================================
go

raiserror(15339,-1,-1,N'sp_MSset_current_activity')
go
-- =============================================
-- sp_MSset_current_activity
-- =============================================
create procedure dbo.sp_MSset_current_activity @id int OUTPUT
as

set transaction isolation level read uncommitted
set quoted_identifier on
set nocount on
set lock_timeout 5000

declare @stmt as nvarchar(4000)
-- =============================================
-- make tables SPID depended
-- =============================================
declare @locktab as sysname
declare @proctab as sysname
declare @locktb2 as sysname
declare @proctb2 as sysname

set @id = @@spid
set @locktab = N'##lockinfo' + rtrim(convert(nvarchar(5), @id))
set @proctab = N'##procinfo' + rtrim(convert(nvarchar(5), @id))
set @locktb2 = N'tempdb..##lockinfo' + rtrim(convert(nvarchar(5), @id))
set @proctb2 = N'tempdb..##procinfo' + rtrim(convert(nvarchar(5), @id))

-- =============================================
-- delete temp tables
-- =============================================
if (object_id(@locktb2) is not null)
    exec(N'drop table ' + @locktab)

if (object_id(@proctb2) is not null)
    exec(N'drop table ' + @proctab)

-- =============================================
-- lockinfo table
-- =============================================
set @stmt =
N'select [Process ID]    = l.req_spid,
         [DBID]          = l.rsc_dbid,
         [Database]      = db_name(l.rsc_dbid),
         [ObjID]         = l.rsc_objid,
         [Object]        = convert(nvarchar(386), ''''),
         [Table]         = convert(sysname, ''''),
         [ObjOwner]      = convert(sysname, ''''),
         [IdxID]         = l.rsc_indid,
         [Index]         = convert(sysname, ''''),
         [Lock Type]     = (select substring (v.name, 1, 4) from master.dbo.spt_values v where l.rsc_type = v.number and v.type = ''LR''),
         [Mode]          = (select substring (u.name, 1, 8) from master.dbo.spt_values u where l.req_mode + 1 = u.number and u.type = ''L''),
         [Status]        = (select substring (x.name, 1, 5) from master.dbo.spt_values x where l.req_status = x.number and x.type = ''LS''),
         [Owner]         = (select substring (o.name, 1, 8) from master.dbo.spt_values o where l.req_ownertype = o.number and o.type = ''LO''),
         [Resource]      = substring (rsc_text, 1, 16)
into ' + @locktab + ' from master.dbo.syslockinfo l with (NOLOCK) order by l.req_spid'
exec (@stmt)

-- =============================================
-- processinfo table
-- =============================================
set @stmt =
N'select [Process ID]    = p.spid,
         [User]          = case when p.spid > 6
                              then convert(sysname, ISNULL(suser_sname(p.sid), rtrim(p.nt_domain) + ''\'' + rtrim(p.nt_username)))
                              else ''system''
                           end,
         [Database]      = case when p.dbid = 0
                              then ''no database context''
                              else db_name(p.dbid)
                           end,
         [Status]        = p.status,
         [Open Transactions] = p.open_tran,
         [Command]       = p.cmd,
         [Application]   = p.program_name,
         [Wait Time]     = p.waittime,
         [Wait Type]     = case when p.waittype = 0
                              then ''not waiting''
                              else p.lastwaittype
                           end,
         [Wait Resource] = case when p.waittype = 0
                              then ''''
                              else p.waitresource
                           end,
         [CPU]           = p.cpu,
         [Physical IO]   = p.physical_io,
         [Memory Usage]  = p.memusage,
         [Login Time]    = p.login_time,
         [Last Batch]    = p.last_batch,
         [Host]          = p.hostname,
         [Net Library]   = p.net_library,
         [Net Address]   = p.net_address,
         [Blocked By]	 = p.blocked,
         [Blocking]      = 0,
		 [Execution Context ID]	= p.ecid
into ' + @proctab + ' from master.dbo.sysprocesses p with (NOLOCK) order by p.spid'
exec (@stmt)

-- =============================================
-- create temporary indexes
-- =============================================
set @stmt = N'create index ' + @locktab + '_spid on ' + @locktab + '([Process ID])'
exec (@stmt)

set @stmt = N'create index ' + @locktab + '_object on ' + @locktab + '([Object])'
exec (@stmt)

set @stmt = N'create index ' + @proctab + '_spid on ' + @proctab + '([Process ID])'
exec (@stmt)

set @stmt = N'create index ' + @proctab + '_blockedby on ' + @proctab + '([Blocked By])'
exec (@stmt)

set transaction isolation level read committed

-- =============================================
-- replace placeholders get object names
-- =============================================
declare @lckdb sysname
declare @lckobjid integer
declare @lckobj sysname
declare @lckindid smallint
declare @lckind sysname

set @stmt = 'declare c1 cursor for select distinct [Database], [ObjID], [IdxID] from ' + @locktab + ' where [DBID] > 0 FOR READ ONLY'
exec (@stmt)

open  c1
fetch c1 into @lckdb, @lckobjid, @lckindid

while @@fetch_status >= 0
begin
    if (@lckobjid > 0)
    begin
	select @stmt ='update ' + @locktab + ' set [Table] = name, [ObjOwner] = user_name(uid) from ' + quotename(@lckdb, '[') + '.[dbo].[sysobjects] where id = ' + convert(nvarchar(10), @lckobjid) + ' and [Database] = ''' + @lckdb + ''' and [ObjID] = ' + convert(nvarchar(10), @lckobjid)
        exec (@stmt)
	select @stmt ='update ' + @locktab + ' set [Index] = name from ' + quotename(@lckdb, '[') + '.[dbo].[sysindexes] where id = ' + convert(nvarchar(10), @lckobjid)  + ' and indid = ' + convert(nvarchar(10), @lckindid) + ' and [Database] = ''' + @lckdb + ''' and [IdxID] = ' + convert(nvarchar(10), @lckindid)
        exec (@stmt)
    end
    fetch c1 into @lckdb, @lckobjid, @lckindid
end
deallocate c1

set @stmt = 'update ' + @locktab + ' set [Object] = [Database] where [ObjID] = 0'
exec (@stmt)

set @stmt = 'update ' + @locktab + ' set [Object] = rtrim([Database]) + ''.'' + rtrim([ObjOwner]) + ''.'' + rtrim([Table]) where [ObjID] > 0'
exec (@stmt)

-- =============================================
-- blocking
-- =============================================
set @stmt = 'update ' + @proctab + ' set [Blocking] = 1 where [Process ID] in (select [Blocked By] from ' + @proctab + ' where [Blocked By] > 0)'
exec (@stmt)

select [spid] = @id

return(0)
-- =============================================
-- end sp_MSset_current_activity
-- =============================================
go

raiserror(15339,-1,-1,'sp_MSobjsearch')
go

-- =============================================
-- sp_MSobjsearch (for 8.0 servers)
--
-- PARAMETERS
-- =============================================
-- @searchkey       default NULL
-- @dbname          default current db = db_name(), valid DB name
--                     or * (ALL)
-- @objecttype      default 1 (user table), can be valid objtype
--                     or 4096 (ALL), see remarks
-- @hitlimit		default 100 rows, 0 is all results
-- @casesensitive   default 0, only valid when server is case sensitive
-- @status          default 0 = no status, 1 = send percentage
--                     progress status back based on database/step
-- @extpropname	    default NULL
-- @extpropvalue    default NULL
--
-- REMARKS
-- =============================================
-- @objecttype	
--		user table       = 1	from @dbname..sysobjects
--		system table     = 2	from @dbname..sysobjects
--		view             = 4	from @dbname..sysobjects
--		sp               = 8	from @dbname..sysobjects
--		rf(repl sp)      = 16	from @dbname..sysobjects
--		xp               = 32	from @dbname..sysobjects
-- 		trigger          = 64	from @dbname..sysobjects
--		UDF              = 128  from @dbname..sysobjects
--     		DRI Constraints  = 256  from @dbname..sysobjects
-- 		log              = 512  from @dbname..sysobjects
--		column           = 1024 from @dbname..syscolumns
--		index            = 2048	from @dbname..sysindexes
--		all              = 4096	
-- =============================================
--
-- RETURN VALUES
-- =============================================
-- 0 = success
-- 1 = parameter error
-- 2 = resultset truncated
-- =============================================
create procedure dbo.sp_MSobjsearch
@searchkey as nvarchar(4000) = NULL,
@dbname as sysname = NULL,
@objecttype as int = 1,
@hitlimit as int = 100,
@casesensitive as tinyint = 0,
@status as tinyint = 0,
@extpropname as sysname = NULL,
@extpropvalue as nvarchar(4000) = NULL

as

-- =============================================
-- create temp result set
-- =============================================
create table #objsearch(
dbname	sysname COLLATE database_default not null,
owner	sysname COLLATE database_default not null,
objname	sysname	COLLATE database_default not null,
objtype	nvarchar(25) COLLATE database_default not null,
objtab	sysname COLLATE database_default null,
extpropname sysname COLLATE database_default null,
extpropvalue sql_variant null)

-- =============================================
-- create covering index
-- =============================================
create index #ind_objsearch on #objsearch(dbname, owner, objname, objtype)

-- =============================================
-- required connection settings setting
-- =============================================
set nocount on
set deadlock_priority low
-- =============================================
-- declare variables
-- =============================================
declare @cnt integer
declare @stmt nvarchar(4000)
declare @strtype nvarchar(100)
declare @dbcount integer
declare @i integer
declare @typepointer as integer
declare @objtype as integer
declare @quotedbname as nvarchar(256)
declare @quotedbname2 as nvarchar(256)
declare @beginupper as nvarchar(6)
declare @endupper as nvarchar(1)

declare @extprop as bit

-- =============================================
-- initialize extended property search variables
-- =============================================
if (@extpropname is NULL) and (@extpropvalue is NULL)
	select @extprop = 0
else
	select @extprop = 1

if (@extpropname is NULL) and (@extpropvalue is not NULL) select @extpropname = '%'

if (@extpropname is not NULL) and (@extpropvalue is NULL) select @extpropvalue = '%'

-- =============================================
-- initialize variables
-- =============================================
select @cnt = 0, @stmt = '', @strtype = '''U''', @dbcount = 0, @i = 0, @beginupper = '', @endupper = ''

select @searchkey = quotename(@searchkey, '''')
select @extpropname = quotename(@extpropname, '''')
select @extpropvalue = quotename(@extpropvalue, '''')

if @objtype = 4095 select @objtype = 4096

-- =============================================
-- search key is a mandatory parameter
-- =============================================
if (@searchkey is null)
begin
	raiserror ('No search key provided, search procedure aborted', 16, 1, @dbname)
	return 1
end

-- =============================================
-- default database is the current database from which executed
-- =============================================
if (@dbname is null) select @dbname = db_name()
-- =============================================
-- verify if database name exists
-- =============================================
if (@dbname <> '*')
begin
	if not exists (select * from master..sysdatabases where name = @dbname and has_dbaccess(@dbname) = 1)
	begin
		raiserror ('Database %s does not exist, search procedure aborted', 16, 1, @dbname)
		return 1
	end
end

-- =============================================
-- verify case sensitivety if needed
-- =============================================
-- we need to modify @searchkey to include all upper/lower letters in the string
if (@casesensitive = 0)
begin
    select @searchkey = upper(@searchkey)
    select @extpropname = upper(@extpropname)
    select @extpropvalue = upper(@extpropvalue)

    select @beginupper = 'upper('
    select @endupper = ')'
end

-- =============================================
-- indicate progress ?
-- =============================================
if (@status = 1)
	select @dbcount = (select count(*) from master.dbo.sysdatabases where has_dbaccess(name) = 1)

-- =============================================
-- if @dbname = '*'
-- =============================================
if (@dbname = '*')
	select @stmt = 'declare dbcursor cursor forward_only read_only for select name from master.dbo.sysdatabases where has_dbaccess(name) = 1 order by name'
else
	begin
		select @dbname = quotename(@dbname, '''')
		select @stmt = 'declare dbcursor cursor forward_only read_only for select name from master.dbo.sysdatabases where has_dbaccess(name) = 1 and name = N'+ @dbname + ' order by name'
	end

exec (@stmt)
if @@error <> 0
	begin
		raiserror ('Error creating cursor for databases, search procedure aborted', 16, 1, @dbname)
		return 1
	end

open dbcursor
-- ====================================
-- loop for each database in dbcursor
-- ====================================
fetch next from dbcursor into @dbname
while (@@fetch_status <> -1)
begin
	select @quotedbname = quotename(@dbname)
	select @quotedbname2 = quotename(@dbname, '''')
	select @typepointer = 1

	-- =============================================
	-- loop to match @objecttype with each typepointer (1, 2, 4, ...)
	-- =============================================
	while (@objecttype >= @typepointer)
	begin
		if (@@fetch_status <> -2)
		begin
		
			select @objtype = @objecttype&@typepointer
			-- =============================================
			-- query sysobjects
			-- =============================================
			if (@objtype in (1, 2, 4, 8, 16, 32, 64, 128, 256, 512, 4096))
			begin
				-- =============================================
				-- set @strobj to indicate search type
				-- =============================================
				if (@objtype = 1) select @strtype = '''U'''
				else if (@objtype = 2) select @strtype = '''S'''
				else if (@objtype = 4) select @strtype = '''V'''
				else if (@objtype = 8) select @strtype = '''P'''
				else if (@objtype = 16) select @strtype = '''RF'''
				else if (@objtype = 32) select @strtype = '''X'''
				else if (@objtype = 64) select @strtype = '''TR'''
				else if (@objtype = 128) select @strtype = '''TF'',''IF'',''FN'''
				else if (@objtype = 256) select @strtype = '''C'',''D'',''F'',''PK'',''UQ'''
				else if (@objtype = 512) select @strtype = '''L'''
	
				if (@objtype = 4096)
				    if (@extprop = 0)
					select @stmt = 'use ' + @quotedbname + ' insert into #objsearch select dbname = N' + @quotedbname2 + ', user_name(o.uid), o.name, o.xtype, object_name(o.parent_obj), NULL, NULL from ' + @quotedbname + '.dbo.sysobjects o where ' + @beginupper + 'o.name' + @endupper +' like N' + @searchkey
				    else
					select @stmt = 'use ' + @quotedbname + ' insert into #objsearch select dbname = N' + @quotedbname2 + ', user_name(o.uid), o.name, o.xtype, object_name(o.parent_obj), p.name, p.value from ' + @quotedbname + '.dbo.sysobjects o, '+ @quotedbname + '.dbo.sysproperties p where o.id = p.id and ' + @beginupper + 'o.name' + @endupper +' like N' + @searchkey + ' and ' + @beginupper + 'p.name' + @endupper +' like N' + @extpropname + ' and ' + @beginupper + 'cast(ISNULL(p.value, N'''') as nvarchar(4000))' + @endupper +' like N' + @extpropvalue + ' and p.type = 3'
					
				else 	
				    if (@extprop = 0)
					select @stmt = 'use ' + @quotedbname + ' insert into #objsearch select dbname = N' + @quotedbname2 + ', user_name(o.uid), o.name, o.xtype, object_name(o.parent_obj), NULL, NULL from ' + @quotedbname + '.dbo.sysobjects o where o.xtype in (' + @strtype + ') and ' + @beginupper + 'o.name' + @endupper +' like N' + @searchkey
				    else	
					select @stmt = 'use ' + @quotedbname + ' insert into #objsearch select dbname = N' + @quotedbname2 + ', user_name(o.uid), o.name, o.xtype, object_name(o.parent_obj), p.name, p.value from ' + @quotedbname + '.dbo.sysobjects o, '+ @quotedbname + '.dbo.sysproperties p where o.id = p.id and o.xtype in (' + @strtype + ') and ' + @beginupper + 'o.name' + @endupper +' like N' + @searchkey + ' and ' + @beginupper + 'p.name' + @endupper +' like N' + @extpropname + ' and ' + @beginupper + 'cast(ISNULL(p.value, N'''') as nvarchar(4000))' + @endupper +' like N' + @extpropvalue + ' and p.type = 3'
				
				exec (@stmt)

				if @@error <> 0
					begin
						raiserror ('Error inserting objects from %s into #objsearch, search procedure aborted', 16, 1, @dbname)
						return 1
					end

				select @cnt = @cnt + @@rowcount
			end
			
			if (@hitlimit > 0 and @cnt >= @hitlimit) goto returnresults
	
			-- =============================================
			-- query syscolumns
			-- =============================================
			if (@objtype in (1024, 4096))
			begin
				-- because paremeters for store proc and UDF are also stored in syscolumns table, the following query filter them out(by checking name start with '@' and name = '')
				if (@extprop = 0)
				   select @stmt = 'use ' + @quotedbname + ' insert into #objsearch select dbname = N' + @quotedbname2 + ', user_name(o.uid), c.name, ''COL'', o.name, NULL, NULL from ' + @quotedbname + '.dbo.syscolumns c, ' + @quotedbname + '.dbo.sysobjects o where c.id = o.id and ' + @beginupper + 'c.name' + @endupper +' like N' + @searchkey + ' and c.name not like ''@%''' + ' and c.name <> '''''
				else
				   select @stmt = 'use ' + @quotedbname + ' insert into #objsearch select dbname = N' + @quotedbname2 + ', user_name(o.uid), c.name, ''COL'', o.name, p.name, p.value from ' + @quotedbname + '.dbo.syscolumns c, ' + @quotedbname + '.dbo.sysobjects o, '+ @quotedbname + '.dbo.sysproperties p where c.id = o.id and o.id = p.id and c.colid = p.smallid and ' + @beginupper + 'c.name' + @endupper +' like N' + @searchkey + ' and c.name not like ''@%''' + ' and c.name <> ''''' + ' and ' + @beginupper + 'p.name' + @endupper +' like N' + @extpropname + ' and ' + @beginupper + 'cast(ISNULL(p.value, N'''') as nvarchar(4000))' + @endupper +' like N' + @extpropvalue + ' and p.type = 4'	

				exec  (@stmt)
				if @@error <> 0
					begin
						raiserror ('Error inserting objects from %s into #objsearch, search procedure aborted', 16, 1, @dbname)
						return 1
					end

				select @cnt = @cnt + @@rowcount
			end

			if (@hitlimit > 0 and @cnt >= @hitlimit) goto returnresults
	
			-- =============================================
			-- query sysindexes
			-- =============================================
			if (@objtype in (2048, 4096))
			begin
				-- because statistics and 'fake'index are also stored in sysindexes table, the following query filter them out (by checking status&0x0040 - statistics, and indid not in (0, 255)- fake index)
				if (@extprop = 0)
				   select @stmt = 'use ' + @quotedbname + ' insert into #objsearch select dbname = N' + @quotedbname2 + ', user_name(o.uid), i.name, ''I'', o.name, NULL, NULL from ' + @quotedbname + '.dbo.sysindexes i, ' + @quotedbname + '.dbo.sysobjects o where i.id = o.id and (i.indid not in (0, 255)) and (i.status&(32 + 64 + 2048 + 4096) = 0) and ' + @beginupper + 'i.name' + @endupper +' like N' + @searchkey
				else
				   select @stmt = 'use ' + @quotedbname + ' insert into #objsearch select dbname = N' + @quotedbname2 + ', user_name(o.uid), i.name, ''I'', o.name, p.name, p.value from ' + @quotedbname + '.dbo.sysindexes i, ' + @quotedbname + '.dbo.sysobjects o, '+ @quotedbname + '.dbo.sysproperties p where i.id = o.id and i.id = p.id and i.indid = p.smallid and (i.indid not in (0, 255)) and (i.status&(32 + 64 + 2048 + 4096) = 0) and ' + @beginupper + 'i.name' + @endupper +' like N' + @searchkey  + ' and ' + @beginupper + 'p.name' + @endupper +' like N' + @extpropname + ' and ' + @beginupper + 'cast(ISNULL(p.value, N'''') as nvarchar(4000))' + @endupper +' like N' + @extpropvalue + ' and p.type = 6'	
				
				exec  (@stmt)
				if @@error <> 0
					begin
						raiserror ('Error inserting objects from %s into #objsearch, search procedure aborted', 16, 1, @dbname)
						return 1
					end

				select @cnt = @cnt + @@rowcount
			end

			if (@hitlimit > 0 and @cnt >= @hitlimit) goto returnresults
	
			-- =============================================
			-- move on to match next datatype
			-- =============================================
			select @typepointer = @typepointer*2

		end -- if (@@fetch_status <> -2)
		
	end -- while (@objecttype >= @typepointer)

	fetch next from dbcursor into @dbname
	
	-- =============================================
	-- report progress as (step X of Y)
	-- =============================================
	if (@status = 1)
	begin
		select @i = @i + 1
		select 'step' = @i, 'steps' = @dbcount
	end
end

-- =============================================
-- return result set
-- =============================================
returnresults:

deallocate dbcursor

-- =============================================
-- enforce hitlimit
-- =============================================
set rowcount @hitlimit

if (@extprop = 0)
	select dbname, owner, objname, objtype, ISNULL(objtab, '') as objtab from #objsearch order by dbname, owner, objname, objtype
else
	select dbname, owner, objname, objtype, ISNULL(objtab, '') as objtab, extpropname, extpropvalue from #objsearch order by dbname, owner, objname, objtype

set rowcount 0

-- =============================================
-- return status
-- =============================================
if (@cnt > @hitlimit)
	return 2 -- resultset truncated
else
	return 0 -- resultset within limits

-- =============================================
-- end sp_MSobjsearch
-- =============================================
go

raiserror(15339,-1,-1,'sp_MShasdbaccess')
go
-- =============================================
-- sp_MShasdbaccess
-- =============================================
-- List all databases a user has access to
-- along with their db properties
--
-- PARAMETERS: N/A
--
-- REMARKS: for SQL Server 7.0 and 8.0
-- =============================================
create proc sp_MShasdbaccess
as

set nocount on
set deadlock_priority low

select name as 'dbname',
owner = substring(suser_sname(sid), 1, 24),
DATABASEPROPERTY(name, N'IsDboOnly') as 'DboOnly',
DATABASEPROPERTY(name, N'IsReadOnly') as 'ReadOnly',
DATABASEPROPERTY(name, N'IsSingleUser') as 'SingleUser',
DATABASEPROPERTY(name, N'IsDetached') as 'Detached',
DATABASEPROPERTY(name, N'IsSuspect') as 'Suspect',
DATABASEPROPERTY(name, N'IsOffline') as 'Offline',
DATABASEPROPERTY(name, N'IsInLoad')  as 'InLoad',
DATABASEPROPERTY(name, N'IsEmergencyMode') as 'EmergencyMode',
DATABASEPROPERTY(name, N'IsInStandBy') as 'StandBy',
DATABASEPROPERTY(name, N'IsShutdown')  as 'ShutDown',
DATABASEPROPERTY(name, N'IsInRecovery') as 'InRecovery',
DATABASEPROPERTY(name, N'IsNotRecovered') as 'NotRecovered'

from master.dbo.sysdatabases
where has_dbaccess(name) = 1
order by name
-- =============================================
-- end sp_MShasdbaccess
-- =============================================
go

-- =============================================
-- sp_resolve_logins
-- =============================================
raiserror(15339,-1,-1,'sp_resolve_logins')
go
create procedure sp_resolve_logins
    @dest_db         sysname
   ,@dest_path       nvarchar(255)
   ,@filename        nvarchar(255)
as
   -- SETUP RUNTIME OPTIONS AND 
   -- DECLARE VARIABLES
   SET NOCOUNT ON
   
   DECLARE   @retcode         int            -- return value of xp call
            ,@datafiletype    varchar(255)
            ,@command         nvarchar(255)
            ,@lgnname         sysname
            ,@lgnsid          varbinary(85)
            ,@usrname         sysname

   -- CHECK PERMISSIONS
   IF (ISNULL(IS_SRVROLEMEMBER(N'sysadmin'), 0) <> 1)
   BEGIN
     RAISERROR(15247, 16, 1)
     RETURN(1) -- Failure
   END

   -- ERROR IF IN USER TRANSACTION
   IF @@trancount > 0
   BEGIN
        raiserror(15289,-1,-1)
        RETURN (1)
   END

   -- Validate the directory the dat file is in.
   -- Remove heading and trailing spaces
   SELECT @dest_path = RTRIM(LTRIM(@dest_path))
   
   -- If the last char is '\', remove it.
   IF substring(@dest_path, len(@dest_path),1) = '\'
      SELECT @dest_path = substring(@dest_path, 1, len(@dest_path)-1)

   -- Don't do validation if it is a UNC path due to security problem.
   -- If the server is started as a service using local system account, we
   -- don't have access to the UNC path.
   IF substring(@dest_path, 1,2) <> '\\'
   BEGIN
       SELECT @command = 'dir "' + @dest_path + '"'
       exec @retcode = master..xp_cmdshell @command, 'no_output'
       IF @@error <> 0
          RETURN (1)
       IF @retcode <> 0 
       BEGIN
          raiserror (14430, 16, -1, @dest_path)              
          RETURN (1)
       END
   END


   -- CREATE the temp table for the datafile
   -- This method ensures we are always getting the
   -- real table definition of the syslogins table.
   SELECT   *
   INTO     #sysloginstemp
   FROM     syslogins
   WHERE    sid = 0x00

   truncate TABLE #sysloginstemp

   -- BULK INSERT the file into the temp table.
   SET      @dest_path = @dest_path + '\' + @filename
   SET      @datafiletype   =  '''widenative'''

   EXEC('
        BULK INSERT #sysloginstemp 
        FROM ''' + @dest_path + '''
        WITH (
                DATAFILETYPE = ' + @datafiletype + '
               ,KEEPNULLS)
       ')

   -- UPDATE the SID in the destination database to the value in the current server's 
   -- syslogins table ensuring that the names match between the source and destination 
   -- syslogins tables.  Do this by cursoring through each login and executing
   -- sp_change_users_login for each login that require a SID resynch.

   -- DECLARE & OPEN CURSOR over old login names
	DECLARE loginmapping CURSOR LOCAL FOR SELECT name, sid FROM #sysloginstemp
	OPEN loginmapping

	FETCH loginmapping INTO @lgnname, @lgnsid
	WHILE (@@fetch_status >= 0)
	BEGIN

      -- GET NAME OF USER THAT NEEDS TO BE RE-MAPPED FOR THIS LOGIN
		SELECT @usrname = NULL		-- INIT TO NULL IN CASE OF NO MATCH
		SELECT @usrname = u.name
	     FROM dbo.sysusers u
            ,master.dbo.syslogins l
		 WHERE u.sid = @lgnsid 
         AND l.loginname = @lgnname 
         AND l.sid <> u.sid
			 
		-- IF WE HAVE A USER NAME, DO THE REMAPPING
		IF @usrname IS NOT NULL
			EXEC ('EXEC ' + @dest_db + '.dbo.sp_change_users_login Update_One, ' + @usrname + ',' + @lgnname)

		-- GET NEXT LOGIN-MAPPING
		FETCH loginmapping INTO @lgnname, @lgnsid
	END

   CLOSE loginmapping
   DEALLOCATE loginmapping

   -- RETURN SUCCESS/FAILURE
   IF @@ERROR <> 0
      RETURN (1)
   RETURN  (0)
go

-- =============================================
-- marked stored procedures as system shipped objects
-- =============================================
EXEC dbo.sp_MS_marksystemobject sp_resolve_logins
go

grant execute on sp_MSget_current_activity to public
grant execute on sp_MSset_current_activity to public
grant execute on sp_MSobjsearch to public
grant execute on sp_MShasdbaccess to public
go

-- =============================================
-- EOF SQL Tools entries
-- =============================================
go

/********************************************************************************************/
exec sp_MS_upd_sysobj_category 2
go
/********************************************************************************************/

/********************************************************************************************/
/* EOF XPSTAR.SQL                                                                           */
/********************************************************************************************/

