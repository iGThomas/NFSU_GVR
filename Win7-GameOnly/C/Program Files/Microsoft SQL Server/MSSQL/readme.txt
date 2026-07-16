***************************************************************
                            NOTICE
***************************************************************
This readme.txt file was included with the original release
of SQL Server 2000; it is not relevant for this service pack.
 
For information about SQL Server 2000 Service Pack 3,
see the sp3readme.htm file located in the same folder
as this file.

***************************************************************
           Microsoft SQL Server 2000 Readme File
                        July 31, 2000
***************************************************************
(c) Copyright Microsoft Corporation, 2000. All rights reserved.

This file contains information that supplements the Microsoft 
SQL Server 2000 documentation.

***************************************************************
Contents
***************************************************************
1.0 Introduction
2.0 Installing SQL Server 2000
    2.1 System Requirements
    2.2 Do Not Install Analysis Services to a DBCS Folder
    2.3 Installing Analysis Services Samples
    2.4 Updating Statistics After Upgrading from SQL Server 7.0
    2.5 Minimum SQL Server Installation Components
    2.6 Requirements for Active Directory Integration
    2.7 Silverston Samples Are Not Installed
    2.8 Installation Help on Windows 95
    2.9 Installing SQL Server 2000 with SQL Server Version 6.5
3.0 Documentation Notes    
    3.1 SQL Server Core Components Notes
      3.1.1 Replication and Host Integration Server
      3.1.2 Backup/Restore APIs for Independent Software Vendors
      3.1.3 Executing DTS Custom Tasks Created in Visual Basic
      3.1.4 Desktop Engine Setup Parameters
      3.1.5 Adding Properties to DTS Custom Tasks
      3.1.6 @@TRANCOUNT and COMMIT in Triggers
      3.1.7 Behavior of Wildcard and Escape Characters
      3.1.8 Changing the SQL Server Agent Service Account 
      3.1.9 Adding Pure Unicode Error Messages
      3.1.10 DTS Using ActiveX Scripting After Uninstalling 
             SQL Server 7.0
      3.1.11 Removing Secondary Databases for Log Shipping 
      3.1.12 ODBC API: SQLGetConnectAttr
      3.1.13 Connecting Early Version Clients to Named Instances
      3.1.14 SQL Server Sometimes Cannot Open Static IP Port
             Addresses
      3.1.15 SQLSetConnectAttr and the Connection Attribute
             SQL_COPT_SS_PRESERVE_CURSORS
      3.1.16 SQLEndTran
      3.1.17 Permissions for Active Directory Integration
      3.1.18 srv_pfield (Extended Stored Procedures Programming)
      3.1.19 Using the MSX Wizard with Windows Authentication
      3.1.20 Updating a Table on a Linked Server  
      3.1.21 Effects of Locking Hints on READ_ONLY Cursors
      3.1.22 Adding Dependencies to the SQL Server Resource
      3.1.23 Upgrading from MSDE 1.0 to SQL Server 2000 
             Desktop Engine
      3.1.24 Microsoft Search Service
      3.1.25 References to Windows 95
      3.1.26 Full-Text Catalogs Inaccessible After Changing 
             SQL Server Account
      3.1.27 Recommendations for Designing Distributed 
             Partitioned Views
    3.2 SQL Server Books Online Functionality Notes
      3.2.1 Link to MDAC and XML Documentation Does Not Work
      3.2.2 Printing Limitations 
    3.3 English Query   
      3.3.1 SaveProjectToXMLDom Method  
      3.3.2 Automatic Clarification of Questions Feature
    3.4 Analysis Services
      3.4.1 Before Registering Analysis Services Performance
            Monitoring Counters on Windows NT 4.0
      3.4.2 Distinct Count Aggregate Function
      3.4.3 UPDATE CUBE Statement
      3.4.4 Process Databases After Upgrading from Beta 2

***************************************************************
1.0 Introduction
***************************************************************
This file contains important information you should read
before installing Microsoft SQL Server 2000.

SQL Server 2000 builds on and extends the performance,
reliability, quality, and ease of use of SQL Server version
7.0. It also includes a number of new features that further
establish SQL Server as the best database platform for OLTP,
data warehousing, and e-commerce applications.

***************************************************************
2.0 Installing SQL Server 2000
***************************************************************
Microsoft SQL Server 2000 documentation is available from these 
sources:

* The Microsoft SQL Server 2000 Introduction manual in the 
  SQL Server 2000 box.
* F1 Help available on the SQL Server Setup windows. You can
  also open the SQL Server Setup Help file from the autorun
  installation menu.
* You can perform a custom setup and select only the Books
  Online component to install the SQL Server Books Online
  documentation on the hard drive of your computer.

The complete SQL Server Books Online documentation for SQL 
Server 2000 cannot be opened from the SQL Server 2000 compact 
disc. SQL Server Books Online must be installed to your local 
hard drive before it can be opened. The installation 
documentation in the Microsoft SQL Server 2000 Introduction 
manual does not include some items that arose after the manual 
was printed. These items are covered in both SQL Server Books 
Online and the SQL Server Setup Help file.

Use the autorun setup program on the SQL Server 2000 compact 
disc to install the SQL Server 2000 components. The autorun 
setup program is executed automatically when you insert the 
compact disc in the drive. You can also execute it by selecting 
the Autorun.exe program in the root folder of the SQL Server 
2000 compact disc. Although there is a Setup.exe program in the 
SQLMSDE folder of the SQL Server 2000 compact disc, this program
is intended to be used by applications that must install the 
SQL Server 2000 Desktop Engine during their installation 
process. The Desktop Engine Setup is not intended for installing 
the SQL Server 2000 components from the compact disc. For more 
information about distributing SQL Server applications, see 
SQL Server Books Online.

SQL Server Books Online is a collection of HTML Help documents 
and requires Microsoft Internet Explorer version 5.0. Internet 
Explorer 5.0 can be downloaded from http://microsoft.com/ie.

For users of SQL Server version 7.0 who are installing SQL
Server 2000 for the first time, these new features are chosen 
during setup:

* You can install multiple instances of SQL Server on one
  computer. 
* Failover clustering has been integrated with SQL Server
  Setup. 
* A SQL Server collation must be specified instead of a code
  page and sort order. 

For more information about these features, see SQL Server
Books Online.

When upgrading SQL Server version 6.5 to an instance of SQL
Server 2000 on the same computer, you must have first applied
SQL Server version 6.5 Service Pack 5 (SP5) or later. When
upgrading SQL Server version 6.5 to an instance of SQL Server
2000 on a different computer, you must have first applied SQL
Server version 6.5 Service Pack 3 (SP3) or later.

Service Pack 5a, which is the most current service pack for
SQL Server version 6.5, is available at
http://support.microsoft.com/support/sql.

There are two ways to upgrade from an installation of SQL
Server version 6.0 to an installation of SQL Server 2000:

* You can upgrade the installation of SQL Server 6.0 to
  SQL Server 6.5, and then use the SQL Server 2000 Upgrade 
  Wizard to upgrade the installation of SQL Server 6.5 to
  SQL Server 2000.
* You can upgrade the installation of SQL Server 6.0 to
  SQL Server 7.0, and then use SQL Server 2000 Setup to upgrade 
  the installation SQL Server 7.0 to SQL Server 2000.

For more information, see "Upgrading an Existing Installation of 
SQL Server" in either SQL Server Books Online or the Microsoft 
SQL Server 2000 Introduction manual.

-----------------------
2.1 System Requirements
-----------------------
Microsoft SQL Server 2000 operates on computers running Intel 
or compatible Pentium, Pentium Pro, or Pentium II processors.
The processor must be running at a minimum of 166 MHz.

The editions and versions of SQL Server 2000 have these
memory (RAM) requirements:

    Enterprise Edition     64 MB of minimum, 128 MB recommended
    Standard Edition       64 MB of minimum
    Personal Edition       64 MB on Windows 2000, 32 MB on all
                           other operating systems
    Developer Edition      64 MB of minimum
    Desktop Engine         64 MB minimum on Windows 2000, 32 MB
                           on all other operating systems

SQL Server 2000 has the following hard drive requirements,
depending on the components and setup option selected:

    Database components      95 to 270 MB, 250 MB typical
    Analysis Services        50 MB minimum, 130 MB typical
    English Query            80 MB
    Desktop Engine only      44 MB

SQL Server 2000 requires a monitor with VGA resolution; the
SQL Server graphical tools require a monitor with 800x600
resolution or higher.

SQL Server 2000 requires a CD-ROM drive, and a Microsoft
Mouse or compatible pointing device.

SQL Server 2000 requires Internet Explorer 5.0 or later and
is supported on these operating systems:

    * Windows 2000
    * Microsoft Windows NT version 4.0 Service Pack 5 or later
    * Windows Millennium Edition
    * Windows 98
    * Windows 95 (client connectivity option only)

The latest service pack for Windows NT is available at
http://support.microsoft.com/support/NTServer.

Before installing SQL Server 2000 software on Windows 95,
you must install a Winsock 2 Update for Windows 95. This
update is supplied on the SQL Server 2000 compact disc and 
can be installed by selecting the SQL Server 2000
Prerequisites option from the autorun window displayed by
the SQL Server 2000 compact disc.

SQL Server 2000 is not supported on Windows NT 4.0
Terminal Server.

For more information about the operating-system 
requirements for the editions and components of SQL Server 
2000, see Hardware and Software Requirements for Installing
SQL Server 2000 in either SQL Server Books Online or 
the Microsoft SQL Server 2000 Introduction manual.

-----------------------------------------------------
2.2 Do Not Install Analysis Services to a DBCS Folder
-----------------------------------------------------
Analysis Services should not be installed to a folder that uses 
characters from a double-byte character set (DBCS) in the path 
or name. Install Analysis Services to a folder that uses only 
single-byte characters in the path and name.

----------------------------------------
2.3 Installing Analysis Services Samples
----------------------------------------
To install the Analysis Services samples, you must install 
Analysis Services from the SQL Server compact disc. The samples 
are installed at 
x:\Program Files\Microsoft Analysis Services\Samples.

-----------------------------------------------------------
2.4 Updating Statistics After Upgrading from SQL Server 7.0
-----------------------------------------------------------
After upgrading from SQL Server 7.0, run sp_updatestats 
'resample' to update the statistics on the user tables in your 
databases.

----------------------------------------------
2.5 Minimum SQL Server Installation Components
----------------------------------------------
Full-Text Search is not included in a Minimum installation of
SQL Server 2000.

-------------------------------------------------
2.6 Requirements for Active Directory Integration
-------------------------------------------------
To register an instance of Microsoft SQL Server 2000 in 
Active Directory, the instance of SQL Server must be installed 
on a computer running Microsoft Windows 2000 with the 
Active Directory service enabled. The SQL Server service must 
also be configured to run under either the Windows LocalSystem 
account or a Windows domain account in the local administrators 
group. This requirement must be met to add databases and 
publications from the instance to Active Directory. Instances 
of SQL Server 2000 configured to run under a power user account 
do not have sufficient permissions to invoke all of the 
SQL Server components required to work with Active Directory.

To register an Analysis server in Active Directory,
MSSQLServerOLAPService must be installed on a computer running
Windows 2000 with the Active Directory service enabled. 
MSSQLServerOLAPService must also be configured to run under 
either the Windows LocalSystem account or a Windows domain 
account in the local administrators group.

----------------------------------------
2.7 Silverston Samples Are Not Installed
----------------------------------------
Microsoft SQL Server 2000 Enterprise Edition includes a license 
for four popular database schema samples. Instructions for 
installing these samples using the Setup program are provided 
in the topic "Database Schema Samples"; however, Setup does 
not install these samples. To install the database schema 
samples, double-click Unzip_silverstondb.exe located at 
\Devtools\Samples\Silverstondb on the SQL Server 2000 
compact disc.

-----------------------------------
2.8 Installation Help on Windows 95
-----------------------------------
If you want to use Help during the installation of Client 
Connectivity on Microsoft Windows 95, you may need to upgrade 
to Microsoft Internet Explorer 5.0 and HTML Help 1.3. You can 
update Internet Explorer and HTML Help by downloading the 
latest versions from http://www.microsoft.com. The HTML Help 
update file is named Hhupd.exe.

----------------------------------------------------------
2.9 Installing SQL Server 2000 with SQL Server Version 6.5
----------------------------------------------------------
SQL Server Books Online contains contradictory statements 
about installing Microsoft SQL Server 2000 on a computer 
running SQL Server version 6.5. The resulting installation 
depends on whether you are installing a named instance or 
a default instance of SQL Server 2000:

* If you install a default instance of SQL Server 2000 on a 
  computer running an instance of SQL Server 6.5, the default 
  instance of SQL Server 2000 becomes the accessible instance 
  of SQL Server, and the SQL Server 2000 program group appears 
  on the Start menu. The instance of SQL Server 6.5 is switched 
  out, and the SQL Server 6.5 program group does not appear on 
  the Start menu.

  You can run either the default instance of SQL Server 2000 
  or the instance of SQL Server 6.5, but not both at the same 
  time. To switch between the two versions of SQL Server, use 
  the Microsoft SQL Server-Verswitch entry on the Start menu. 
  When you switch from SQL Server 2000 to SQL Server 6.5, the 
  instance of SQL Server 2000 becomes inactive, and the SQL 
  Server 6.5 program group replaces the SQL Server 2000 program 
  group on the Start menu. When you switch from SQL Server 6.5 
  to SQL Server 2000, the process is reversed.

* If you install one or more named instances of SQL Server 2000 
  on a computer running SQL Server 6.5 and there is no default 
  instance of SQL Server 2000, the instance of SQL Server 6.5 
  remains active as the default instance. Both the SQL Server 
  2000 and SQL Server 6.5 program groups appear on the Start 
  menu. You should use the SQL Server 6.5 tools to manage the 
  default instance of SQL Server 6.5, and the SQL Server 2000
  tools to manage the named instances of SQL Server 2000.

* If you install both named and default instances of SQL Server 
  2000 on a computer running SQL Server 6.5, you can run the 
  named instances of SQL Server 2000 at any time, but must 
  version-switch between the default instance of SQL Server 2000
  and the default instance of SQL Server 6.5. The SQL Server 
  2000 program group always appears on the Start menu. The 
  SQL Server 6.5 program group appears on the Start menu 
  whenever you have version switched to make SQL Server 6.5 
  the active default instance. The SQL Server 6.5 program 
  group does not appear when you have version switched to make 
  SQL Server 2000 the active default instance.

***************************************************************
3.0 Documentation Notes
***************************************************************
These are issues that arose after the SQL Server Books Online 
documentation was completed.

-----------------------------------
3.1 SQL Server Core Component Notes
-----------------------------------
These notes relate to the SQL Server core components, including 
the database engine, client components, connectivity components, 
graphical tools, and command prompt utilities.

3.1.1 Replication and Host Integration Server

The topic "Programming Replication from Heterogeneous Data 
Sources" indicates that Microsoft Host Integration Server 2000 
provides a replication Log Reader Agent for use with Microsoft 
SQL Server 2000; however, Host Integration Server 2000 does not 
provide a Log Reader Agent for use with SQL Server 2000.

3.1.2 Backup/Restore APIs for Independent Software Vendors

Microsoft SQL Server 2000 is supported by a large number of 
third-party backup solutions. SQL Server provides application 
programming interfaces that enable independent software vendors 
to integrate SQL Server into their products. These APIs provide 
maximum reliability and performance, and support the full range 
of SQL Server backup and restore functionality, including hot 
and snapshot capabilities. For information about how your backup 
solution integrates with SQL Server, contact your backup solution 
vendor. For information about the Backup/Restore APIs, install 
the "Backup/Restore API" subcomponent of the "Development Tools"
component of SQL Server. To complete the installation of the 
samples and the documentation, run Unzip_backup.exe, located at 
C:\Program Files\Microsoft SQL Server\80\Tools\Devtools\Samples\
Backup. 
The documentation is provided in Vbackup.chm. 

3.1.3 Executing DTS Custom Tasks Created in Visual Basic

To implement a Data Transformation Services (DTS) custom task in 
Microsoft Visual Basic, you must execute the custom task on the 
main thread. If the custom task is included in an Execute Package 
task, the Execute Package task will also need to run on the main 
thread. Similarly, if the custom task is manipulated (for example, 
has one of its property values assigned) by a Dynamic Properties 
task, the Dynamic Properties task will need to execute on the 
main thread.

3.1.4 Desktop Engine Setup Parameters

SQL Server Books Online topics "Merging the Desktop Engine into 
Windows Installer" and "SQL Server 2000 Desktop Engine Setup" 
document two parameters that are ignored by the final version 
of the Desktop Engine Setup: USEDEFAULTSAPWD and SAPASSWORD.

By default, when run on the Microsoft Windows NT 4.0 or Windows 
2000 operating system, the Desktop Engine Setup configures the 
installed instance of Microsoft SQL Server to use Windows 
Authentication, and places the Windows local administrator's group 
in the SQL Server sysadmin fixed server role. When running Desktop 
Engine Setup on the Windows NT 4.0 or Windows 2000 operating 
system, you can specify a SECURITYMODE=SQL parameter to have the 
installed instance configured to use SQL Server Authentication 
with a null sa password. When run on the Windows 98 operating 
system, the Desktop Engine Setup always configures the installed 
instance to use SQL Server Authentication, regardless of whether 
or not SECURITYMODE=SQL is specified.

A set of Desktop Engine merge modules that have been merged into 
a Windows Installer setup has the same behavior. On the Windows 
NT 4.0 and Windows 2000 operating systems, the instance of SQL 
Server is configured to use Windows Authentication if 
SECURITYMODE=SQL is not specified, and is configured to use SQL 
Server Authentication if SECURITYMODE=SQL is specified. The 
instance is always configured to use SQL Server Authentication 
on the Windows 98 operating system.

You can specify SECURITYMODE=SQL in the same locations where you 
can use USEDEFAULTSAPWD or SAPASSWORD. For more information, see 
the SQL Server Books Online topics "Merging the Desktop Engine 
into Windows Installer" and "SQL Server 2000 Desktop Engine Setup."

3.1.5 Adding Properties to DTS Custom Tasks

Because of the process Microsoft SQL Server 2000 uses to manage 
DTS custom tasks, you must include both a Get and Let (or Set) 
property procedure for all properties. Each property associated 
with a custom task should consist of a pair of property 
procedures: a property Get to retrieve the property value, and 
a property Let (or Set) to assign a new value.      

3.1.6 @@TRANCOUNT and COMMIT in Triggers

Microsoft SQL Server 2000 increments the transaction count within
a statement only when the transaction count is 0 at the start of 
the statement. In SQL Server version 7.0, the transaction count 
is always incremented, regardless of the transaction count at 
the start of the statement. This can cause the value returned by 
@@TRANCOUNT in triggers to be lower in SQL Server 2000 than it 
is in SQL Server version 7.0. 

In SQL Server 2000, if a COMMIT TRANSACTION or COMMIT WORK 
statement is executed in a trigger, and there is no corresponding 
explicit or implicit BEGIN TRANSACTION statement at the start 
of the trigger, users may see different behavior than on 
SQL Server version 7.0. Placing COMMIT TRANSACTION or COMMIT 
WORK statements in a trigger is not recommended.

3.1.7 Behavior of Wildcard and Escape Characters

Wildcard characters and escape characters have these additional 
behaviors in the LIKE operator in Microsoft SQL Server 2000:

* Within the '[]' characters that delimit a single character 
  range, the wildcard characters '%', '_', and '[' do not 
  operate as wildcards.

* Within the '[]' characters that delimit a single character 
  range, escape characters can be used, and the characters 
  '^', '-',   and ']' can be escaped.

* If there is no character after an escape character in the 
  LIKE pattern, the pattern is invalid and LIKE returns FALSE.

* If the character after an escape character is not a wildcard, 
  the escape character is discarded and the character following 
  the escape is treated as regular character in the pattern. 
  This includes the wildcard characters '%', '_', and '[' when 
  they are enclosed in the '[]' characters that delimit a single 
  character range.

3.1.8 Changing the SQL Server Agent Service Account 

If you are running Microsoft Windows NT 4.0 and Windows 2000, 
and you select to change the SQL Server Agent service account 
for Microsoft SQL Server to a non-administrator account, you 
must add the non-Administrator account to the sysadmin server 
role in SQL Server. If you do not add the account, the 
SQL Server Agent service account will not be able to log in 
to SQL Server.

The SQL Server Agent service must be running under a 
Windows NT 4.0 or Windows 2000 administrator account to use 
non-integrated security to connect to SQL Server. SQL Server 
must be running under a Windows NT or Windows 2000 administrator 
account to set the SQL Server Agent connection option to 
non-integrated security.

If you change the SQL Server service account to a Windows NT 4.0 
or Windows 2000 non-administrator account, and you are switching 
between SQL Server 6.5 and SQL Server 2000, it is possible for 
you to lose access to the SQL Server 6.5 service account. For 
example, if you change the SQL Server 2000 service account to 
a non-administrator account on Windows NT 4.0 or Windows 2000, 
and then switch to SQL Server 6.5, you will not have access to 
the computer running SQL Server 6.5. You must use Control Panel 
to change the SQL Server service account back to a Windows NT 
or Windows 2000 administrator account.

If you have a default instance of SQL Server 7.0 and a named 
instance of SQL Server 2000 on the same computer, and you manage 
the default instance of SQL Server 7.0 using SQL Server Enterprise 
Manager in SQL Server 7.0, you may be unable to switch the 
service account on the named instance of SQL Server 2000. For 
example, if both instances are running using the same 
non-administrator account for the SQL Server service, and you 
change the instance of SQL Server 7.0 to a different account, you 
may not be able to change the service account on the instance of 
SQL Server 2000. The ability to impersonate an administrator has 
been lost on this account because the instance of SQL Server 7.0 
and the instance of SQL Server 2000 both have the same 
non-administrator account. To correct this, use Control Panel 
on the instance of SQL Server 2000 to change the SQL Server 
service account to a Windows NT or Windows 2000 administrator 
account. After restarting the service, you can change the service 
account to any other account on the computer running 
SQL Server 2000. 

3.1.9 Adding Pure Unicode Error Messages

The Manage SQL Server Messages dialog box does not support 
adding pure Unicode messages to the sysmessages table. To add 
such messages, use the sp_addmessage stored procedure. Be 
sure to use the N prefix on the 'msg' parameter (for example, 
@msgtext = N'xxx').

3.1.10  DTS Using ActiveX Scripting After Uninstalling 
        SQL Server 7.0

To use Microsoft ActiveX scripting in Microsoft SQL Server 2000 
after uninstalling SQL Server 7.0, you must re-register the 
ActiveX scripting library (Axscphst.dll). Use the Regsvr32.exe 
registration utility and execute the following command 
(substituting your own drive letter) from MS-DOS or the Windows 
Run command: 
regsvr32.exe C:\Program Files\Microsoft SQL Server\80\Tools\Binn\
axscphst.dll 

If the registration is successful, a message box appears 
indicating that Axscphst.dll is registered properly. 

3.1.11 Removing Secondary Databases for Log Shipping 

If all secondary databases configured for log shipping have been 
removed from the secondaries themselves, the database maintenance 
plan for log shipping can no longer be used to add the secondary 
databases back to the plan. The database maintenance plan for 
log shipping must be removed and configured again for log 
shipping to work on the secondary databases. 

3.1.12 ODBC API: SQLGetConnectAttr

The behavior of SQL_ATTR_CONNECTION_DEAD and 
SQL_COPT_SS_CONNECTION_DEAD in Microsoft SQL Server 2000 is 
different from the behavior in earlier versions of SQL Server. 
In SQL Server 2000, SQL_ATTR_CONNECTION_DEAD returns the most 
recent state of the connection, which may not be the current 
connection state. However, SQL_COPT_SS_CONNECTION_DEAD will 
always query the Net-Library for the current state of the 
connection.

To differentiate between these behaviors, 
SQL_COPT_SS_CONNECTION_DEAD is given a new value in the 
SQL Server 2000 include files. Applications using this attribute 
that are built using the SQL Server 2000 headers will return an 
error (HY092, Invalid attribute/option identifier) if the 
applications are run using a SQL Server 7.0 driver. It is 
recommended that the application check the version of driver 
being used before calling SQLGetConnectAttr, and then use 
SQL_ATTR_CONNECTION_DEAD in place of SQL_COPT_SS_CONNECTION_DEAD 
if the application is running on a SQL Server 7.0 driver.

3.1.13 Connecting Early Version Clients to Named Instances

The SQL Server Books Online topic "Working with Named and 
Multiple Instances of SQL Server 2000" states that you must use 
SQL Server 2000 client components to connect to named instances 
of SQL Server 2000. However, the SQL Server version 7.0 Client 
Network Utility can be used to configure a server alias name 
that the SQL Server version 7.0 client components can use to 
connect to a named instance of SQL Server 2000. This is 
documented in the SQL Server Books Online topics "SQL Server 
2000 and SQL Server version 7.0" and "Communicating with 
Multiple Instances."

3.1.14 SQL Server Sometimes Cannot Open Static IP Port Addresses

When an instance of Microsoft SQL Server is configured to listen 
on a static IP port (such as a default instance that takes the 
default of listening on port 1433), the SQL Server service cannot 
open the port if another application or component is using the 
port when the SQL Server service initializes. The TCP/IP server 
Net-Library will not initialize, and the instance of SQL Server 
cannot accept TCP/IP connections until the service is stopped 
and restarted. This problem should not occur if the instance of 
SQL Server is configured to use a dynamic port address by 
specifying a port address of 0 using the Server Network Utility. 
If you cannot use dynamic port addresses (for example, when 
SQL Server connections must pass through a firewall server
configured to pass through specific port addresses, or when some
connections are made using the client components from SQL Server
version 7.0 or earlier), then using a port address less than 1024 
is recommended. Choose a port in this range that is not used 
by the operating system or another application.

3.1.15 SQLSetConnectAttr and the Connection Attribute
       SQL_COPT_SS_PRESERVE_CURSORS

SQL_COPT_SS_PRESERVE_CURSORS defines the behavior of cursors 
when manual-commit mode is used. The behavior is exposed as 
transactions are either committed or rolled back using SQLEndTran.

SQL_PC_OFF: Default. Cursors are closed when transaction is 
committed or rolled back using SQLEndTran.

SQL_PC_ON: Cursors are not closed when transaction is committed 
or rolled back using SQLEndTran, except when using a static or 
keyset cursor in asynchronous mode, if a rollback is issued 
while the population of the cursor is not complete, the cursor 
is closed.

3.1.16 SQLEndTran

When SQLEndTran commits or rolls back an operation, the behavior 
of the statement's associated cursor is determined by the value 
of the driver-specific ODBC connection attribute 
SQL_COPT_SS_PRESERVE_CURSORS, set by SQLSetConnectAttr.

3.1.17 Permissions for Active Directory Integration

In Microsoft SQL Server 2000, only members of the sysadmin 
fixed server role can register databases or publications in 
Active Directory; members of the dbowner fixed database role 
cannot.

3.1.18 srv_pfield (Extended Stored Procedures Programming)

The SRV_PWD field is no longer supported. Do not write 
extended stored procedures that use this field.

3.1.19 Using the MSX Wizard with Windows Authentication

If you are using the Make Master Server Wizard (MSX) on a 
computer configured with Windows Authentication, you must 
restart the computer. This is because the wizard requires Mixed 
Mode Authentication (Windows Authentication and SQL Server 
Authentication). The wizard will change the authentication mode 
for you, but you must then restart Microsoft SQL Server and 
SQL Server Agent on the master server.

3.1.20 Updating a Table on a Linked Server

You cannot update a table on a linked server through a view. 
This is true for any linked server, regardless of the provider.

3.1.21 Effects of Locking Hints on READ_ONLY Cursors

The UPDLOCK and TABLOCKX locking hints no longer raise errors 
on READ_ONLY cursors. Instead, the effects are identical to 
the effects on OPTIMISTIC cursors. UPDLOCK causes the cursor 
to acquire update scroll locks, and TABLOCKX is ignored for 
the purposes of scroll locks.

3.1.22 Adding Dependencies to the SQL Server Resource

If you install SQL Server 2000 into a Windows 2000 or 
Windows NT cluster group with multiple disk drives and choose 
to place your data on one of the drives, the SQL Server 
resource is set to be dependent only on that drive. To put 
data or logs on another disk, you must first add a dependency 
to the SQL Server resource for the additional disk.
 
To add a new disk (for example, disk K) to the SQL Server 
dependencies:

1. Open Cluster Administrator in Administrative Tools.

2. Locate the group that contains the applicable SQL Server 
   resource.

3. If the resource for disk K is already in this group, go to 
   Step 4. Otherwise, locate the group that contains disk K. 
   If that group and the group that contains SQL Server are 
   not owned by the same node, move the group containing the 
   resource for disk K to the node that owns the SQL Server 
   group.

4. Select the SQL Server resource, open the Properties dialog 
   box, and use the Dependencies tab to add disk K to the set 
   of SQL Server dependencies.

3.1.23 Upgrading from MSDE 1.0 to SQL Server 2000 
       Desktop Engine

To upgrade from MSDE 1.0 to SQL Server 2000 Desktop Engine:

* If you are using Setup.exe, you must specify UPGRADE=1 as 
  a command prompt switch. For more information about the 
  Setup.exe command prompt switches, see "SQL Server 2000 
  Desktop Engine Setup" in SQL Server Books Online. 
  Or
  If you are using the Desktop Engine merge files in a Windows 
  Installer setup, you must specify UPGRADE=1 with the other 
  Desktop Engine entries in the [Options] section of your 
  Windows Installer .ini file. For more information about 
  the Desktop Engine Windows Installer entries, see "Merging 
  the Desktop Engine into Windows Installer" in SQL Server 
  Books Online.

* You must provide a custom installation package file built 
  using SampleUpg.msi. For more information about 
  SampleUpg.msi, see "Managing Desktop Engine Installation 
  Package Files" in SQL Server Books Online.

3.1.24 Microsoft Search Service

A note in the Creating and Maintaining Databases topic, 
Full-Text Indexes, contains incorrect information about 
Microsoft Search service. Here is the correct information:

The Microsoft Search service is supported on Microsoft 
Windows NT and Windows 2000, but not on Windows 98. 
The Microsoft Search service can be installed with 
Microsoft SQL Server 2000 Personal Edition.

3.1.25 References to Windows 95

A few SQL Server Books Online topics incorrectly refer to 
these configurations:

* Running instances of Microsoft SQL Server 2000 on computers 
  running Microsoft Windows 95.

* Running the SQL Server 2000 tools and utilities on computers 
  running Windows 95.

The Books Online topic "SQL Server 2000 on Windows 98" 
correctly states that the SQL Server utilities and tools 
are not supported on Windows 95. Likewise, the topic 
"Server Components" correctly states that the SQL Server 
2000 database engine and other server components are not 
supported on Windows 95.

You can install the client-connectivity components on 
Windows 95, which allow applications to access instances of 
SQL Server 2000 on other computers.

3.1.26 Full-Text Catalogs Inaccessible After Changing 
       SQL Server Account

Changing Microsoft SQL Server to run under a non-administrator 
account causes existing full-text catalogs to be inaccessible. 
Either rebuild and perform a full population of all catalogs 
belonging to this instance of SQL Server, or switch back to 
an account with administrator permissions.

3.1.27 Recommendations for Designing Distributed Partitioned 
       Views

In designing a partitioning scheme, it must be clear what data 
belongs to each partition. The partitioning column cannot be an 
identity, default, or timestamp column. There are no restrictions 
on the updatability of the partitioning column.

-----------------------------------------------
3.2 SQL Server Books Online Functionality Notes
-----------------------------------------------
These are issues that relate to the functionality of SQL Server 
Books Online.

3.2.1 Link to MDAC and XML Documentation Does Not Work

When SQL Server Books Online is opened using F1 or the Help menu 
in an MMC snap-in (such as SQL Server Enterprise Manager), the 
link to the MDAC and XML documentation does not work. To view 
the MDAC and XML documentation, open Mdacxml.chm located in 
C:\Program Files\Microsoft Sql Server\80\Tools\Books.

NOTE: The link works correctly when SQL Server Books Online 
is started directly from the SQL Server Program Group on the 
Start menu, or from running Sql80.col.

3.2.2 Printing Limitations

If you are using Microsoft Internet Explorer version 5.5, 
printing with the "Print the selected headings and all 
subtopics" option is not recommended.

If you are using Internet Explorer 5.0 or Internet Explorer 5.5,
linked topics may not always print when the "Print all linked 
documents" option is selected in the Print dialog box.
 
-----------------
3.3 English Query
-----------------   
These are issues in English Query that are not reflected in the 
documentation.
     
3.3.1 SaveProjectToXMLDom Method  

The syntax for this method should be:
      Set variable = EQModel.SaveProjectToXMLDOM
where variable is a returned XMLDOMDocument object to which the 
project is saved.

3.3.2 Automatic Clarification of Questions Feature

The InputList object has the following additional properties to 
support the Automatic Clarification of Questions feature. The 
properties are read-only, optional, and of the variant data type:

* LookupQueries
  Returns an array of QueryCmd objects of the size specified in 
  ItemCount, or is NULL. Each LookupQuery corresponds to an item 
  in the Items array. If the query returns no rows, the 
  corresponding item may not be the correct default choice for 
  the InputList object.  

  For example, for the question "How many awards did John 
  Fortune win?", an English Query application might not have 
  "John Fortune" in its dictionary; therefore, a 
  UserClarification Response is returned containing an InputList 
  with the text, "Which of these do you mean by John Fortune?" 
  The choices are: the name of an actor, which selects actors 
  named John Fortune, or the name of a movie, which selects 
  movies named John Fortune. A LookupQuery is associated 
  with each choice. If only one of these queries returns rows, 
  the client application can use the corresponding item as the 
  user selection for the InputList, and can respond to the 
  UserClarificationResponse without user intervention.

  NOTE: LookupQueries cannot be generated for some InputList 
  objects. For these objects, each LookupQuery in the array 
  is NULL.

* EntityIDs Property
  Returns an array of EntityIDs of the size specified in ItemCount. 
  Each EntityID corresponds to an item in the Items array. If the 
  choice in the Items array is an entity (for example, the name of 
  an actor), the EntityID contains the ID of that entity 
  (for example, author_name). If the choice in the Items array is 
  not an entity (for example, First Name), the EntityID is empty.

The InputText object has an additional property to support the 
Automatic Clarification of Questions feature:

* LookupQueries is a read-only, optional property of the variant 
  data type and can be NULL. LookupQueries is a collection of 
  QueryCmds objects that are used to determine a default value for 
  the InputText object.

  For example, for the question "List the old people", the English 
  Query application might not have a threshold specified for "old". 
  A UserClarificationResponse is returned containing an InputText 
  with the text, "An old person is a person whose age is over ___." 
  The LookupQuery selects the median age. The client application 
  can choose to use the returned value as the response to the 
  InputText and can respond to the UserClarificationResponse 
  without user intervention.

  NOTE: LookupQueries cannot be generated for some InputText 
  objects. For these objects, the LookupQuery collection is empty.

---------------------
3.4 Analysis Services
---------------------
These are issues in Analysis Services that are not reflected in 
the documentation.

3.4.1 Before Registering Analysis Services Performance Monitoring
      Counters on Windows NT 4.0

Analysis Services performance monitoring counters are installed
to your hard disk during setup, but on Microsoft Windows NT 4.0
they are not registered automatically because of a problem with
some versions of Windows NT 4.0. Before using the manual 
instructions documented in the SQL Server Books Online topic, 
"Monitoring Analysis Services Performance" to register the 
counters on Windows NT 4.0, review Microsoft Knowledge Base 
article Q242472 for more information. You may need to move 
the file Msmdctr80.dll to a different folder to meet the 
requirements listed in the article. On Microsoft Windows 2000,
the performance counters are installed and registered 
automatically during setup.

3.4.2 Distinct Count Aggregate Function
    
The Analysis Services topic "Specifications and Limits" 
incorrectly identifies the restrictions on the Distinct Count 
aggregate function. The Distinct Count aggregate function 
requires the measure to be numeric.

In the Analysis Services topic "Indexed Views for ROLAP 
Partitions," the first bullet item should read: "The partition 
cannot contain measures that use the aggregate functions Min, 
Max, or Distinct Count."

3.4.3 UPDATE CUBE Statement

In the Analysis Services topic "UPDATE CUBE Statement," the BNF 
for the statement incorrectly indicates that multiple cells can 
be updated in a single statement. Only a single cell can be 
updated in each UPDATE CUBE statement.

3.4.4 Process Databases After Upgrading from Beta 2

If you upgrade from the Beta 2 release of Analysis Services, 
process all upgraded databases to ensure correct data 
conversion.