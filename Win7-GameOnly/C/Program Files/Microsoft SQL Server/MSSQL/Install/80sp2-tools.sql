/*------------------------------------------------------------------------------

80SP2_TOOLS.SQL

THIS SCRIPT TAKES THE TOOLS STORED PROCS FROM 8.0 SP1 to 8.0 SP2.

Notes:

------------------------------------------------------------------------------*/

PRINT N''
PRINT N'Updating database objects, executing 80SP2-TOOLS.SQL'
PRINT N'Started at ' + convert(nvarchar(25), getdate())
PRINT N''
go

--------------------------------------------------------------------------------
-- VERIFY Server is started in single-user-mode (catalog-updates enabled), 
-- and start marking of system-objects.
--------------------------------------------------------------------------------
use master
go

exec dbo.sp_configure 'allow updates',1
go

reconfigure with override
go

exec sp_MS_upd_sysobj_category 1
go



--------------------------------------------------------------------------------
-- BEGIN OF CHANGE SECTION:
-- Add change sprocs between here and the END OF CHANGE SECTION comment.
--------------------------------------------------------------------------------


--------------------------------------------------------------------------------
-- END OF CHANGE SECTION:
-- Turn off marking of system objects.
-- DO NOT ADD ANYTHING AFTER THIS POINT
--------------------------------------------------------------------------------
print N''
go

exec sp_MS_upd_sysobj_category 2
go

exec sp_configure 'allow updates',0
go

reconfigure with override
go

PRINT N''
PRINT N'Done updating database objects'
PRINT N'Finished at ' + convert(nvarchar(25), getdate())
PRINT N''
go
