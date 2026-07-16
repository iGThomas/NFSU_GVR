/*
** Copyright Microsoft, Inc. 1994 - 2000
** All Rights Reserved.
*/
use master
go

/*
 * Beta nomenclature; delete for upgrades.
 */
if object_id('xp_OACreate') is not null
	exec sp_dropextendedproc 'xp_OACreate'
go
if object_id('xp_OADestroy') is not null
	exec sp_dropextendedproc 'xp_OADestroy'
go
if object_id('xp_OAGetErrorInfo') is not null
	exec sp_dropextendedproc 'xp_OAGetErrorInfo'
go
if object_id('xp_OAGetProperty') is not null
	exec sp_dropextendedproc 'xp_OAGetProperty'
go
if object_id('xp_OAMethod') is not null
	exec sp_dropextendedproc 'xp_OAMethod'
go
if object_id('xp_OASetProperty') is not null
	exec sp_dropextendedproc 'xp_OASetProperty'
go

/* 
 * Drop and create.
 */
if object_id('sp_OACreate') is not null
	exec sp_dropextendedproc 'sp_OACreate'
go
if object_id('sp_OADestroy') is not null
	exec sp_dropextendedproc 'sp_OADestroy'
go
if object_id('sp_OAGetErrorInfo') is not null
	exec sp_dropextendedproc 'sp_OAGetErrorInfo'
go
if object_id('sp_OAGetProperty') is not null
	exec sp_dropextendedproc 'sp_OAGetProperty'
go
if object_id('sp_OAMethod') is not null
	exec sp_dropextendedproc 'sp_OAMethod'
go
if object_id('sp_OASetProperty') is not null
	exec sp_dropextendedproc 'sp_OASetProperty'
go
if object_id('sp_OAStop') is not null
	exec sp_dropextendedproc 'sp_OAStop'
go

exec sp_MS_upd_sysobj_category 1
go

exec sp_addextendedproc 'sp_OACreate', 'odsole70.dll'
go
exec sp_addextendedproc 'sp_OADestroy', 'odsole70.dll'
go
exec sp_addextendedproc 'sp_OAGetErrorInfo', 'odsole70.dll'
go
exec sp_addextendedproc 'sp_OAGetProperty', 'odsole70.dll'
go
exec sp_addextendedproc 'sp_OAMethod', 'odsole70.dll'
go
exec sp_addextendedproc 'sp_OASetProperty', 'odsole70.dll'
go
exec sp_addextendedproc 'sp_OAStop', 'odsole70.dll'
go

exec sp_MS_upd_sysobj_category 2
go

