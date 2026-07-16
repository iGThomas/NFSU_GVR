***************************************************************
         Microsoft SQLXML 3.0 Service Pack 1 Readme File
                          May 1, 2002
***************************************************************
(c) Copyright Microsoft Corporation, 2002. All rights reserved.

***************************************************************
Contents
***************************************************************
1.0 Introduction
2.0 Notes and Guidelines
    2.1 SQLXML 3.0 Is Not Fully Backward Compatible
    2.2 Previous DLLs Are Not Removed
    2.3 Version-Dependent and Version-Independent PROGIDS
    2.4 Registry Keys
    2.5 SQLXML 3.0 Uses MSXML 4.0 Service Pack 1
    2.6 SOAP Support - Stored Procedure Parameter Limitation
3.0 Installing SQLXML 3.0
    3.1 System Requirements
4.0 Questions and Comments

***************************************************************
1.0 Introduction
***************************************************************
Microsoft SQLXML 3.0 Service Pack 1 (SP1) includes bug fixes 
and security enhancements. SQLXML 3.0 SP1 uses MSXML 4.0 
Service Pack 1.

SQLXML 3.0 provides additional XML functionality for users of 
Microsoft SQL Server 2000. SQLXML 3.0 offers support for these
features:

* Web Services (SOAP) Support
  You can send SOAP requests to a SQLXML-enabled IIS server to 
  execute stored procedures, user-defined functions and templates.
* Client-side FOR XML
  SQL Server 2000 introduced FOR XML support. SQLXML 30 allows
  you to format the query results on the client-side.
* XML Schema Definition language (XSD)
  You can write an XSD schema by using annotations to create
  an XML view of the relational data
* Updategrams
  You can modify (insert, update, or delete) a data in 
  SQL Server 2000 from an existing XML document by using an 
  updategram  
* Bulk loading XML data
  You can bulk load XML documents by using XML Bulk Load 
  support in SQLXML.
* Support for Microsoft .NET Framework
  SQLXML Managed Classes expose the functionality
  of SQLXML 3.0 inside the Microsoft .NET Framework. The
  DiffGram format to modify data in tables is supported.

***************************************************************
2.0 Notes and Guidelines
***************************************************************
This section includes important information about Microsoft 
SQLXML 3.0. If you are upgrading from SQLXML Web Release 1 and 
have not installed SQLXML 2.0, the following information will 
be helpful.

-----------------------------------------------
2.1 SQLXML 3.0 Is Not Fully Backward Compatible
-----------------------------------------------
SQLXML 3.0 is not completely backward compatible with 
SQLXML 2.0 and SQLXML Web Release 1 because of some 
bug fixes and minor functional changes. Although most 
applications will run without modification, you must test 
them before putting them into production with SQLXML 3.0. 
See section 2.3 for related information.

---------------------------------
2.2 Previous DLLs Are Not Removed
---------------------------------
The installation process for SQLXML 3.0 does not remove the 
files installed by XML for SQL Server 2000 Web Release 1 or
SQLXML 2.0. The DLLs from Web Release 1, SQLXML 2.0 and those 
installed with SQLXML 3.0 will be on your computer. You can 
run these installations side by side. 

-----------------------------------------------------
2.3 Version-Dependent and Version-Independent PROGIDS
-----------------------------------------------------
SQLXML 3.0 includes version-independent and version-dependent 
PROGIDs. It is recommended that all production applications 
use version-dependent PROGIDs. This is especially important 
because SQLXML 3.0 is not fully backward compatible. 

Using version dependent PROGIDs protects from possible 
production failures when you install newer releases. From 
release to release, program behavior may change due to several 
reasons, such as bug fixes, possible design changes, and so on. 

Using version-dependent PROGIDs protects from unexpected 
failure when you install newer releases. With version-dependent 
PROGIDs, when you install a newer release, your application 
will continue to work without failure.
 
If you decide to change the previous version-dependent PROGIDs 
and use the recent version-dependent PROGIDs in a newer 
release, you must test your application before putting it 
into production.
  
For example, the following scenario shows when applications 
using version-independent PROGIDs may fail:
You are running an application that uses SQLXML 3.0 and 
version-independent PROGIDs, and you decide to install some 
other software program. This program might install an earlier 
version of SQLXML. Your application may fail because the 
version-independent PROGIDS in your application now point
to the earlier version of SQLXML, which may or may not have
the SQLXML feature that your application is using.

-----------------
2.4 Registry Keys
-----------------
Registry Keys Changes
In XML for SQL Server Web Release 1, the following registry 
keys are used:  
HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\MSSQLServer\Client\
SQLXMLX\TemplateCacheSize 
HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\MSSQLServer\Client\
SQLXMLX\SchemaSize  
HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\MSSQLServer\Client\
SQLXMLX\NumThreads  
HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\MSSQLServer\Client\
SQLXMLX\MaxRequestQueueSize

In SQLXML 2.0, these keys have changed to:
HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\MSSQLServer\Client\
SQLXML2\TemplateCacheSize  
HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\MSSQLServer\Client\
SQLXML2\SchemaCacheSize  
HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\MSSQLServer\Client\
SQLIS2\NumThreads  
HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\MSSQLServer\Client\
SQLIS2\MaxRequestQueueSize

In SQLXML 3.0, these keys have changed to:
HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\MSSQLServer\Client\
SQLXML3\TemplateCacheSize  
HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\MSSQLServer\Client\
SQLXML3\SchemaCacheSize  
HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\MSSQLServer\Client\
SQLIS3\NumThreads  
HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\MSSQLServer\Client\
SQLIS3\MaxRequestQueueSize

You must change the settings if you want these keys 
to be in effect for SQLXML 3.0.

--------------------------------------------
2.5 SQLXML 3.0 Uses MSXML 4.0 Service Pack 1
--------------------------------------------
SQLXML 3.0 uses MSXML 4.0 Service Pack 1 (installed as part 
of SQLXML 3.0 SP1 installation process). Information about
what's new in MSXML 4.0 Service Pack 1 can be found at
http://msdn.microsoft.com/library/en-us/dnmsxml/html/
whatsnew40rtm.asp?frame=true.

--------------------------------------------------------
2.6 SOAP Support - Stored Procedure Parameter Limitation
--------------------------------------------------------
The stored procedures you add in the configuration of the 
virtual name of soap type cannot have output parameters of 
BLOB type (text, ntext, or image).

***************************************************************
3.0 Installing SQLXML 3.0 
***************************************************************
The SQLXML 3.0 installation program copies the following DLLs 
into the following folders:

* C:\Program Files\Common Files\System\OLE DB:
  * Sqlis3.dll
  * Sqlis3r.dll
  * Sqlvdr3.dll
  * Sqlvdr3r.dll
  * Sqlxml3.dll
  * Sqlxml3r.dll
  * Xblkld3.dll
  * Xblkld3r.dll

* C:\Program Files\SQLXML 3.0\bin:
  * Microsoft.Data.SqlXml.dll 
  * Cvtschema.exe
  * cvtsres.dll

* Winnt\System32:
  * Msxml4.dll
  * Msxml4r.dll
  * Msxml4a.dll
  * WINHTTP5.dll
  * Proxycfg.exe

* C:\Program Files\SQLXML 3.0:
  * Sqlisad3.msc

* C:\Program Files\SQLXML 3.0\Documents:
  * Sqlxml3.chm
  * Readme.txt

* C:\Program Files\SQLXML 3.0\include:
  * Xmlblkld.h
  * Xmlblkld_i.c

NOTE: If you want to know where SQLXML 3.0 is installed, 
      install the release from the command prompt using: 
         MSIEXEC /i installerfile.msi /l*v logfile.log 
      After installation, inspect the log file.

-----------------------
3.1 System Requirements
-----------------------
* You can install SQLXML 3.0 on computers running the 
  Microsoft Windows 98, Windows Millennium, Windows NT 4.0, 
  Windows 2000, or Windows XP operating system. 
* Before you install SQLXML 3.0, the SQL Server 2000 
  client must be installed. 
* Microsoft .NET Framework must be installed to use
  SQLXML Managed Classes.
* SOAP Toolkit 2.0 Service Pack 2 must be installed to use
  the Web service (SOAP) functionality (Windows XP includes
  SOAP Toolkit).

***************************************************************
4.0 Questions and Comments
***************************************************************
* SQLXML 3.0 is a fully supported product through Microsoft 
  Product Support Services (PSS).
* You can discuss SQLXML issues at the following newsgroup:
  microsoft.public.sqlserver.xml.
* You can send feedback to the following alias:
  xmlsqlfb@microsoft.com.


 

