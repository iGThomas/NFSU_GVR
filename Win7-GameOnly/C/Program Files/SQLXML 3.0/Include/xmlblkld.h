
#pragma warning( disable: 4049 )  /* more than 64k source lines */
#pragma warning( disable: 4100 ) /* unreferenced arguments in x86 call */
#pragma warning( disable: 4211 )  /* redefine extent to static */

/* this ALWAYS GENERATED file contains the definitions for the interfaces */


 /* File created by MIDL compiler version 6.00.0358 */
/* Compiler settings for xmlblkld.idl:
    Oicf, W1, Zp8, env=Win32 (32b run)
    protocol : dce , ms_ext, c_ext
    error checks: allocation ref bounds_check enum stub_data 
    VC __declspec() decoration level: 
         __declspec(uuid()), __declspec(selectany), __declspec(novtable)
         DECLSPEC_UUID(), MIDL_INTERFACE()
*/
//@@MIDL_FILE_HEADING(  )


/* verify that the <rpcndr.h> version is high enough to compile this file*/
#ifndef __REQUIRED_RPCNDR_H_VERSION__
#define __REQUIRED_RPCNDR_H_VERSION__ 440
#endif

#include "rpc.h"
#include "rpcndr.h"

#ifndef __RPCNDR_H_VERSION__
#error this stub requires an updated version of <rpcndr.h>
#endif // __RPCNDR_H_VERSION__

#ifndef COM_NO_WINDOWS_H
#include "windows.h"
#include "ole2.h"
#endif /*COM_NO_WINDOWS_H*/

#ifndef __xmlblkld_h__
#define __xmlblkld_h__

#if defined(_MSC_VER) && (_MSC_VER >= 1020)
#pragma once
#endif

/* Forward Declarations */ 

#ifndef __ISQLXMLBulkLoad_FWD_DEFINED__
#define __ISQLXMLBulkLoad_FWD_DEFINED__
typedef interface ISQLXMLBulkLoad ISQLXMLBulkLoad;
#endif 	/* __ISQLXMLBulkLoad_FWD_DEFINED__ */


#ifndef __SQLXMLBulkLoad_FWD_DEFINED__
#define __SQLXMLBulkLoad_FWD_DEFINED__

#ifdef __cplusplus
typedef class SQLXMLBulkLoad SQLXMLBulkLoad;
#else
typedef struct SQLXMLBulkLoad SQLXMLBulkLoad;
#endif /* __cplusplus */

#endif 	/* __SQLXMLBulkLoad_FWD_DEFINED__ */


#ifndef __SQLXMLBulkLoad3_FWD_DEFINED__
#define __SQLXMLBulkLoad3_FWD_DEFINED__

#ifdef __cplusplus
typedef class SQLXMLBulkLoad3 SQLXMLBulkLoad3;
#else
typedef struct SQLXMLBulkLoad3 SQLXMLBulkLoad3;
#endif /* __cplusplus */

#endif 	/* __SQLXMLBulkLoad3_FWD_DEFINED__ */


/* header files for imported files */
#include "oaidl.h"
#include "ocidl.h"

#ifdef __cplusplus
extern "C"{
#endif 

void * __RPC_USER MIDL_user_allocate(size_t);
void __RPC_USER MIDL_user_free( void * ); 

/* interface __MIDL_itf_xmlblkld_0000 */
/* [local] */ 

typedef 
enum _tagConnection
    {	connSTRING	= 1,
	connCOMMAND	= 2
    } 	tagConnection;



extern RPC_IF_HANDLE __MIDL_itf_xmlblkld_0000_v0_0_c_ifspec;
extern RPC_IF_HANDLE __MIDL_itf_xmlblkld_0000_v0_0_s_ifspec;

#ifndef __ISQLXMLBulkLoad_INTERFACE_DEFINED__
#define __ISQLXMLBulkLoad_INTERFACE_DEFINED__

/* interface ISQLXMLBulkLoad */
/* [unique][helpstring][hidden][uuid][dual][object] */ 


EXTERN_C const IID IID_ISQLXMLBulkLoad;

#if defined(__cplusplus) && !defined(CINTERFACE)
    
    MIDL_INTERFACE("1380DD8D-DCB9-4A6E-9D53-EECDDF18DA85")
    ISQLXMLBulkLoad : public IDispatch
    {
    public:
        virtual /* [helpstring][id][propget] */ HRESULT STDMETHODCALLTYPE get_ConnectionString( 
            /* [retval][out] */ BSTR *pbstrConnectionString) = 0;
        
        virtual /* [helpstring][id][propput] */ HRESULT STDMETHODCALLTYPE put_ConnectionString( 
            /* [in] */ BSTR bstrConnectionString) = 0;
        
        virtual /* [helpstring][id][propget] */ HRESULT STDMETHODCALLTYPE get_ConnectionCommand( 
            /* [retval][out] */ IUnknown **ppICommand) = 0;
        
        virtual /* [helpstring][id][propput] */ HRESULT STDMETHODCALLTYPE put_ConnectionCommand( 
            /* [in] */ IUnknown *pICommand) = 0;
        
        virtual /* [helpstring][id][propget] */ HRESULT STDMETHODCALLTYPE get_KeepNulls( 
            /* [retval][out] */ VARIANT_BOOL *pfKeepNulls) = 0;
        
        virtual /* [helpstring][id][propput] */ HRESULT STDMETHODCALLTYPE put_KeepNulls( 
            /* [in] */ VARIANT_BOOL fKeepNulls) = 0;
        
        virtual /* [helpstring][id][propget] */ HRESULT STDMETHODCALLTYPE get_KeepIdentity( 
            /* [retval][out] */ VARIANT_BOOL *pfKeepIdentity) = 0;
        
        virtual /* [helpstring][id][propput] */ HRESULT STDMETHODCALLTYPE put_KeepIdentity( 
            /* [in] */ VARIANT_BOOL fKeepIdentity) = 0;
        
        virtual /* [helpstring][id][propget] */ HRESULT STDMETHODCALLTYPE get_CheckConstraints( 
            /* [retval][out] */ VARIANT_BOOL *pfCheckConstraints) = 0;
        
        virtual /* [helpstring][id][propput] */ HRESULT STDMETHODCALLTYPE put_CheckConstraints( 
            /* [in] */ VARIANT_BOOL fCheckConstraints) = 0;
        
        virtual /* [helpstring][id][propget] */ HRESULT STDMETHODCALLTYPE get_ForceTableLock( 
            /* [retval][out] */ VARIANT_BOOL *pfForceTableLock) = 0;
        
        virtual /* [helpstring][id][propput] */ HRESULT STDMETHODCALLTYPE put_ForceTableLock( 
            /* [in] */ VARIANT_BOOL fForceTableLock) = 0;
        
        virtual /* [helpstring][id][propget] */ HRESULT STDMETHODCALLTYPE get_XMLFragment( 
            /* [retval][out] */ VARIANT_BOOL *pfXMLFragment) = 0;
        
        virtual /* [helpstring][id][propput] */ HRESULT STDMETHODCALLTYPE put_XMLFragment( 
            /* [in] */ VARIANT_BOOL fXMLFragment) = 0;
        
        virtual /* [helpstring][id][propget] */ HRESULT STDMETHODCALLTYPE get_Transaction( 
            /* [retval][out] */ VARIANT_BOOL *pfTransaction) = 0;
        
        virtual /* [helpstring][id][propput] */ HRESULT STDMETHODCALLTYPE put_Transaction( 
            /* [in] */ VARIANT_BOOL fTransaction) = 0;
        
        virtual /* [helpstring][id][propget] */ HRESULT STDMETHODCALLTYPE get_IgnoreDuplicateKeys( 
            /* [retval][out] */ VARIANT_BOOL *pfIgnoreDuplicateKeys) = 0;
        
        virtual /* [helpstring][id][propput] */ HRESULT STDMETHODCALLTYPE put_IgnoreDuplicateKeys( 
            /* [in] */ VARIANT_BOOL fIgnoreDuplicateKeys) = 0;
        
        virtual /* [helpstring][id][propget] */ HRESULT STDMETHODCALLTYPE get_BulkLoad( 
            /* [retval][out] */ VARIANT_BOOL *pfBulkLoad) = 0;
        
        virtual /* [helpstring][id][propput] */ HRESULT STDMETHODCALLTYPE put_BulkLoad( 
            /* [in] */ VARIANT_BOOL fBulkLoad) = 0;
        
        virtual /* [helpstring][id][propget] */ HRESULT STDMETHODCALLTYPE get_SchemaGen( 
            /* [retval][out] */ VARIANT_BOOL *pfSchemaGen) = 0;
        
        virtual /* [helpstring][id][propput] */ HRESULT STDMETHODCALLTYPE put_SchemaGen( 
            /* [in] */ VARIANT_BOOL fSchemaGen) = 0;
        
        virtual /* [helpstring][id][propget] */ HRESULT STDMETHODCALLTYPE get_SGDropTables( 
            /* [retval][out] */ VARIANT_BOOL *pfDropTables) = 0;
        
        virtual /* [helpstring][id][propput] */ HRESULT STDMETHODCALLTYPE put_SGDropTables( 
            /* [in] */ VARIANT_BOOL fDropTables) = 0;
        
        virtual /* [helpstring][id][propget] */ HRESULT STDMETHODCALLTYPE get_SGUseID( 
            /* [retval][out] */ VARIANT_BOOL *pfUseID) = 0;
        
        virtual /* [helpstring][id][propput] */ HRESULT STDMETHODCALLTYPE put_SGUseID( 
            /* [in] */ VARIANT_BOOL fUseID) = 0;
        
        virtual /* [helpstring][id][propget] */ HRESULT STDMETHODCALLTYPE get_ErrorLogFile( 
            /* [retval][out] */ BSTR *pbstrFileName) = 0;
        
        virtual /* [helpstring][id][propput] */ HRESULT STDMETHODCALLTYPE put_ErrorLogFile( 
            /* [in] */ BSTR bstrFileName) = 0;
        
        virtual /* [helpstring][id][propget] */ HRESULT STDMETHODCALLTYPE get_TempFilePath( 
            /* [retval][out] */ BSTR *pbstrTempFilePath) = 0;
        
        virtual /* [helpstring][id][propput] */ HRESULT STDMETHODCALLTYPE put_TempFilePath( 
            /* [in] */ BSTR bstrTempFilePath) = 0;
        
        virtual /* [helpstring][id] */ HRESULT STDMETHODCALLTYPE Execute( 
            /* [in] */ BSTR bstrSchemaFile,
            /* [optional][in] */ VARIANT vDataFile) = 0;
        
    };
    
#else 	/* C style interface */

    typedef struct ISQLXMLBulkLoadVtbl
    {
        BEGIN_INTERFACE
        
        HRESULT ( STDMETHODCALLTYPE *QueryInterface )( 
            ISQLXMLBulkLoad * This,
            /* [in] */ REFIID riid,
            /* [iid_is][out] */ void **ppvObject);
        
        ULONG ( STDMETHODCALLTYPE *AddRef )( 
            ISQLXMLBulkLoad * This);
        
        ULONG ( STDMETHODCALLTYPE *Release )( 
            ISQLXMLBulkLoad * This);
        
        HRESULT ( STDMETHODCALLTYPE *GetTypeInfoCount )( 
            ISQLXMLBulkLoad * This,
            /* [out] */ UINT *pctinfo);
        
        HRESULT ( STDMETHODCALLTYPE *GetTypeInfo )( 
            ISQLXMLBulkLoad * This,
            /* [in] */ UINT iTInfo,
            /* [in] */ LCID lcid,
            /* [out] */ ITypeInfo **ppTInfo);
        
        HRESULT ( STDMETHODCALLTYPE *GetIDsOfNames )( 
            ISQLXMLBulkLoad * This,
            /* [in] */ REFIID riid,
            /* [size_is][in] */ LPOLESTR *rgszNames,
            /* [in] */ UINT cNames,
            /* [in] */ LCID lcid,
            /* [size_is][out] */ DISPID *rgDispId);
        
        /* [local] */ HRESULT ( STDMETHODCALLTYPE *Invoke )( 
            ISQLXMLBulkLoad * This,
            /* [in] */ DISPID dispIdMember,
            /* [in] */ REFIID riid,
            /* [in] */ LCID lcid,
            /* [in] */ WORD wFlags,
            /* [out][in] */ DISPPARAMS *pDispParams,
            /* [out] */ VARIANT *pVarResult,
            /* [out] */ EXCEPINFO *pExcepInfo,
            /* [out] */ UINT *puArgErr);
        
        /* [helpstring][id][propget] */ HRESULT ( STDMETHODCALLTYPE *get_ConnectionString )( 
            ISQLXMLBulkLoad * This,
            /* [retval][out] */ BSTR *pbstrConnectionString);
        
        /* [helpstring][id][propput] */ HRESULT ( STDMETHODCALLTYPE *put_ConnectionString )( 
            ISQLXMLBulkLoad * This,
            /* [in] */ BSTR bstrConnectionString);
        
        /* [helpstring][id][propget] */ HRESULT ( STDMETHODCALLTYPE *get_ConnectionCommand )( 
            ISQLXMLBulkLoad * This,
            /* [retval][out] */ IUnknown **ppICommand);
        
        /* [helpstring][id][propput] */ HRESULT ( STDMETHODCALLTYPE *put_ConnectionCommand )( 
            ISQLXMLBulkLoad * This,
            /* [in] */ IUnknown *pICommand);
        
        /* [helpstring][id][propget] */ HRESULT ( STDMETHODCALLTYPE *get_KeepNulls )( 
            ISQLXMLBulkLoad * This,
            /* [retval][out] */ VARIANT_BOOL *pfKeepNulls);
        
        /* [helpstring][id][propput] */ HRESULT ( STDMETHODCALLTYPE *put_KeepNulls )( 
            ISQLXMLBulkLoad * This,
            /* [in] */ VARIANT_BOOL fKeepNulls);
        
        /* [helpstring][id][propget] */ HRESULT ( STDMETHODCALLTYPE *get_KeepIdentity )( 
            ISQLXMLBulkLoad * This,
            /* [retval][out] */ VARIANT_BOOL *pfKeepIdentity);
        
        /* [helpstring][id][propput] */ HRESULT ( STDMETHODCALLTYPE *put_KeepIdentity )( 
            ISQLXMLBulkLoad * This,
            /* [in] */ VARIANT_BOOL fKeepIdentity);
        
        /* [helpstring][id][propget] */ HRESULT ( STDMETHODCALLTYPE *get_CheckConstraints )( 
            ISQLXMLBulkLoad * This,
            /* [retval][out] */ VARIANT_BOOL *pfCheckConstraints);
        
        /* [helpstring][id][propput] */ HRESULT ( STDMETHODCALLTYPE *put_CheckConstraints )( 
            ISQLXMLBulkLoad * This,
            /* [in] */ VARIANT_BOOL fCheckConstraints);
        
        /* [helpstring][id][propget] */ HRESULT ( STDMETHODCALLTYPE *get_ForceTableLock )( 
            ISQLXMLBulkLoad * This,
            /* [retval][out] */ VARIANT_BOOL *pfForceTableLock);
        
        /* [helpstring][id][propput] */ HRESULT ( STDMETHODCALLTYPE *put_ForceTableLock )( 
            ISQLXMLBulkLoad * This,
            /* [in] */ VARIANT_BOOL fForceTableLock);
        
        /* [helpstring][id][propget] */ HRESULT ( STDMETHODCALLTYPE *get_XMLFragment )( 
            ISQLXMLBulkLoad * This,
            /* [retval][out] */ VARIANT_BOOL *pfXMLFragment);
        
        /* [helpstring][id][propput] */ HRESULT ( STDMETHODCALLTYPE *put_XMLFragment )( 
            ISQLXMLBulkLoad * This,
            /* [in] */ VARIANT_BOOL fXMLFragment);
        
        /* [helpstring][id][propget] */ HRESULT ( STDMETHODCALLTYPE *get_Transaction )( 
            ISQLXMLBulkLoad * This,
            /* [retval][out] */ VARIANT_BOOL *pfTransaction);
        
        /* [helpstring][id][propput] */ HRESULT ( STDMETHODCALLTYPE *put_Transaction )( 
            ISQLXMLBulkLoad * This,
            /* [in] */ VARIANT_BOOL fTransaction);
        
        /* [helpstring][id][propget] */ HRESULT ( STDMETHODCALLTYPE *get_IgnoreDuplicateKeys )( 
            ISQLXMLBulkLoad * This,
            /* [retval][out] */ VARIANT_BOOL *pfIgnoreDuplicateKeys);
        
        /* [helpstring][id][propput] */ HRESULT ( STDMETHODCALLTYPE *put_IgnoreDuplicateKeys )( 
            ISQLXMLBulkLoad * This,
            /* [in] */ VARIANT_BOOL fIgnoreDuplicateKeys);
        
        /* [helpstring][id][propget] */ HRESULT ( STDMETHODCALLTYPE *get_BulkLoad )( 
            ISQLXMLBulkLoad * This,
            /* [retval][out] */ VARIANT_BOOL *pfBulkLoad);
        
        /* [helpstring][id][propput] */ HRESULT ( STDMETHODCALLTYPE *put_BulkLoad )( 
            ISQLXMLBulkLoad * This,
            /* [in] */ VARIANT_BOOL fBulkLoad);
        
        /* [helpstring][id][propget] */ HRESULT ( STDMETHODCALLTYPE *get_SchemaGen )( 
            ISQLXMLBulkLoad * This,
            /* [retval][out] */ VARIANT_BOOL *pfSchemaGen);
        
        /* [helpstring][id][propput] */ HRESULT ( STDMETHODCALLTYPE *put_SchemaGen )( 
            ISQLXMLBulkLoad * This,
            /* [in] */ VARIANT_BOOL fSchemaGen);
        
        /* [helpstring][id][propget] */ HRESULT ( STDMETHODCALLTYPE *get_SGDropTables )( 
            ISQLXMLBulkLoad * This,
            /* [retval][out] */ VARIANT_BOOL *pfDropTables);
        
        /* [helpstring][id][propput] */ HRESULT ( STDMETHODCALLTYPE *put_SGDropTables )( 
            ISQLXMLBulkLoad * This,
            /* [in] */ VARIANT_BOOL fDropTables);
        
        /* [helpstring][id][propget] */ HRESULT ( STDMETHODCALLTYPE *get_SGUseID )( 
            ISQLXMLBulkLoad * This,
            /* [retval][out] */ VARIANT_BOOL *pfUseID);
        
        /* [helpstring][id][propput] */ HRESULT ( STDMETHODCALLTYPE *put_SGUseID )( 
            ISQLXMLBulkLoad * This,
            /* [in] */ VARIANT_BOOL fUseID);
        
        /* [helpstring][id][propget] */ HRESULT ( STDMETHODCALLTYPE *get_ErrorLogFile )( 
            ISQLXMLBulkLoad * This,
            /* [retval][out] */ BSTR *pbstrFileName);
        
        /* [helpstring][id][propput] */ HRESULT ( STDMETHODCALLTYPE *put_ErrorLogFile )( 
            ISQLXMLBulkLoad * This,
            /* [in] */ BSTR bstrFileName);
        
        /* [helpstring][id][propget] */ HRESULT ( STDMETHODCALLTYPE *get_TempFilePath )( 
            ISQLXMLBulkLoad * This,
            /* [retval][out] */ BSTR *pbstrTempFilePath);
        
        /* [helpstring][id][propput] */ HRESULT ( STDMETHODCALLTYPE *put_TempFilePath )( 
            ISQLXMLBulkLoad * This,
            /* [in] */ BSTR bstrTempFilePath);
        
        /* [helpstring][id] */ HRESULT ( STDMETHODCALLTYPE *Execute )( 
            ISQLXMLBulkLoad * This,
            /* [in] */ BSTR bstrSchemaFile,
            /* [optional][in] */ VARIANT vDataFile);
        
        END_INTERFACE
    } ISQLXMLBulkLoadVtbl;

    interface ISQLXMLBulkLoad
    {
        CONST_VTBL struct ISQLXMLBulkLoadVtbl *lpVtbl;
    };

    

#ifdef COBJMACROS


#define ISQLXMLBulkLoad_QueryInterface(This,riid,ppvObject)	\
    (This)->lpVtbl -> QueryInterface(This,riid,ppvObject)

#define ISQLXMLBulkLoad_AddRef(This)	\
    (This)->lpVtbl -> AddRef(This)

#define ISQLXMLBulkLoad_Release(This)	\
    (This)->lpVtbl -> Release(This)


#define ISQLXMLBulkLoad_GetTypeInfoCount(This,pctinfo)	\
    (This)->lpVtbl -> GetTypeInfoCount(This,pctinfo)

#define ISQLXMLBulkLoad_GetTypeInfo(This,iTInfo,lcid,ppTInfo)	\
    (This)->lpVtbl -> GetTypeInfo(This,iTInfo,lcid,ppTInfo)

#define ISQLXMLBulkLoad_GetIDsOfNames(This,riid,rgszNames,cNames,lcid,rgDispId)	\
    (This)->lpVtbl -> GetIDsOfNames(This,riid,rgszNames,cNames,lcid,rgDispId)

#define ISQLXMLBulkLoad_Invoke(This,dispIdMember,riid,lcid,wFlags,pDispParams,pVarResult,pExcepInfo,puArgErr)	\
    (This)->lpVtbl -> Invoke(This,dispIdMember,riid,lcid,wFlags,pDispParams,pVarResult,pExcepInfo,puArgErr)


#define ISQLXMLBulkLoad_get_ConnectionString(This,pbstrConnectionString)	\
    (This)->lpVtbl -> get_ConnectionString(This,pbstrConnectionString)

#define ISQLXMLBulkLoad_put_ConnectionString(This,bstrConnectionString)	\
    (This)->lpVtbl -> put_ConnectionString(This,bstrConnectionString)

#define ISQLXMLBulkLoad_get_ConnectionCommand(This,ppICommand)	\
    (This)->lpVtbl -> get_ConnectionCommand(This,ppICommand)

#define ISQLXMLBulkLoad_put_ConnectionCommand(This,pICommand)	\
    (This)->lpVtbl -> put_ConnectionCommand(This,pICommand)

#define ISQLXMLBulkLoad_get_KeepNulls(This,pfKeepNulls)	\
    (This)->lpVtbl -> get_KeepNulls(This,pfKeepNulls)

#define ISQLXMLBulkLoad_put_KeepNulls(This,fKeepNulls)	\
    (This)->lpVtbl -> put_KeepNulls(This,fKeepNulls)

#define ISQLXMLBulkLoad_get_KeepIdentity(This,pfKeepIdentity)	\
    (This)->lpVtbl -> get_KeepIdentity(This,pfKeepIdentity)

#define ISQLXMLBulkLoad_put_KeepIdentity(This,fKeepIdentity)	\
    (This)->lpVtbl -> put_KeepIdentity(This,fKeepIdentity)

#define ISQLXMLBulkLoad_get_CheckConstraints(This,pfCheckConstraints)	\
    (This)->lpVtbl -> get_CheckConstraints(This,pfCheckConstraints)

#define ISQLXMLBulkLoad_put_CheckConstraints(This,fCheckConstraints)	\
    (This)->lpVtbl -> put_CheckConstraints(This,fCheckConstraints)

#define ISQLXMLBulkLoad_get_ForceTableLock(This,pfForceTableLock)	\
    (This)->lpVtbl -> get_ForceTableLock(This,pfForceTableLock)

#define ISQLXMLBulkLoad_put_ForceTableLock(This,fForceTableLock)	\
    (This)->lpVtbl -> put_ForceTableLock(This,fForceTableLock)

#define ISQLXMLBulkLoad_get_XMLFragment(This,pfXMLFragment)	\
    (This)->lpVtbl -> get_XMLFragment(This,pfXMLFragment)

#define ISQLXMLBulkLoad_put_XMLFragment(This,fXMLFragment)	\
    (This)->lpVtbl -> put_XMLFragment(This,fXMLFragment)

#define ISQLXMLBulkLoad_get_Transaction(This,pfTransaction)	\
    (This)->lpVtbl -> get_Transaction(This,pfTransaction)

#define ISQLXMLBulkLoad_put_Transaction(This,fTransaction)	\
    (This)->lpVtbl -> put_Transaction(This,fTransaction)

#define ISQLXMLBulkLoad_get_IgnoreDuplicateKeys(This,pfIgnoreDuplicateKeys)	\
    (This)->lpVtbl -> get_IgnoreDuplicateKeys(This,pfIgnoreDuplicateKeys)

#define ISQLXMLBulkLoad_put_IgnoreDuplicateKeys(This,fIgnoreDuplicateKeys)	\
    (This)->lpVtbl -> put_IgnoreDuplicateKeys(This,fIgnoreDuplicateKeys)

#define ISQLXMLBulkLoad_get_BulkLoad(This,pfBulkLoad)	\
    (This)->lpVtbl -> get_BulkLoad(This,pfBulkLoad)

#define ISQLXMLBulkLoad_put_BulkLoad(This,fBulkLoad)	\
    (This)->lpVtbl -> put_BulkLoad(This,fBulkLoad)

#define ISQLXMLBulkLoad_get_SchemaGen(This,pfSchemaGen)	\
    (This)->lpVtbl -> get_SchemaGen(This,pfSchemaGen)

#define ISQLXMLBulkLoad_put_SchemaGen(This,fSchemaGen)	\
    (This)->lpVtbl -> put_SchemaGen(This,fSchemaGen)

#define ISQLXMLBulkLoad_get_SGDropTables(This,pfDropTables)	\
    (This)->lpVtbl -> get_SGDropTables(This,pfDropTables)

#define ISQLXMLBulkLoad_put_SGDropTables(This,fDropTables)	\
    (This)->lpVtbl -> put_SGDropTables(This,fDropTables)

#define ISQLXMLBulkLoad_get_SGUseID(This,pfUseID)	\
    (This)->lpVtbl -> get_SGUseID(This,pfUseID)

#define ISQLXMLBulkLoad_put_SGUseID(This,fUseID)	\
    (This)->lpVtbl -> put_SGUseID(This,fUseID)

#define ISQLXMLBulkLoad_get_ErrorLogFile(This,pbstrFileName)	\
    (This)->lpVtbl -> get_ErrorLogFile(This,pbstrFileName)

#define ISQLXMLBulkLoad_put_ErrorLogFile(This,bstrFileName)	\
    (This)->lpVtbl -> put_ErrorLogFile(This,bstrFileName)

#define ISQLXMLBulkLoad_get_TempFilePath(This,pbstrTempFilePath)	\
    (This)->lpVtbl -> get_TempFilePath(This,pbstrTempFilePath)

#define ISQLXMLBulkLoad_put_TempFilePath(This,bstrTempFilePath)	\
    (This)->lpVtbl -> put_TempFilePath(This,bstrTempFilePath)

#define ISQLXMLBulkLoad_Execute(This,bstrSchemaFile,vDataFile)	\
    (This)->lpVtbl -> Execute(This,bstrSchemaFile,vDataFile)

#endif /* COBJMACROS */


#endif 	/* C style interface */



/* [helpstring][id][propget] */ HRESULT STDMETHODCALLTYPE ISQLXMLBulkLoad_get_ConnectionString_Proxy( 
    ISQLXMLBulkLoad * This,
    /* [retval][out] */ BSTR *pbstrConnectionString);


void __RPC_STUB ISQLXMLBulkLoad_get_ConnectionString_Stub(
    IRpcStubBuffer *This,
    IRpcChannelBuffer *_pRpcChannelBuffer,
    PRPC_MESSAGE _pRpcMessage,
    DWORD *_pdwStubPhase);


/* [helpstring][id][propput] */ HRESULT STDMETHODCALLTYPE ISQLXMLBulkLoad_put_ConnectionString_Proxy( 
    ISQLXMLBulkLoad * This,
    /* [in] */ BSTR bstrConnectionString);


void __RPC_STUB ISQLXMLBulkLoad_put_ConnectionString_Stub(
    IRpcStubBuffer *This,
    IRpcChannelBuffer *_pRpcChannelBuffer,
    PRPC_MESSAGE _pRpcMessage,
    DWORD *_pdwStubPhase);


/* [helpstring][id][propget] */ HRESULT STDMETHODCALLTYPE ISQLXMLBulkLoad_get_ConnectionCommand_Proxy( 
    ISQLXMLBulkLoad * This,
    /* [retval][out] */ IUnknown **ppICommand);


void __RPC_STUB ISQLXMLBulkLoad_get_ConnectionCommand_Stub(
    IRpcStubBuffer *This,
    IRpcChannelBuffer *_pRpcChannelBuffer,
    PRPC_MESSAGE _pRpcMessage,
    DWORD *_pdwStubPhase);


/* [helpstring][id][propput] */ HRESULT STDMETHODCALLTYPE ISQLXMLBulkLoad_put_ConnectionCommand_Proxy( 
    ISQLXMLBulkLoad * This,
    /* [in] */ IUnknown *pICommand);


void __RPC_STUB ISQLXMLBulkLoad_put_ConnectionCommand_Stub(
    IRpcStubBuffer *This,
    IRpcChannelBuffer *_pRpcChannelBuffer,
    PRPC_MESSAGE _pRpcMessage,
    DWORD *_pdwStubPhase);


/* [helpstring][id][propget] */ HRESULT STDMETHODCALLTYPE ISQLXMLBulkLoad_get_KeepNulls_Proxy( 
    ISQLXMLBulkLoad * This,
    /* [retval][out] */ VARIANT_BOOL *pfKeepNulls);


void __RPC_STUB ISQLXMLBulkLoad_get_KeepNulls_Stub(
    IRpcStubBuffer *This,
    IRpcChannelBuffer *_pRpcChannelBuffer,
    PRPC_MESSAGE _pRpcMessage,
    DWORD *_pdwStubPhase);


/* [helpstring][id][propput] */ HRESULT STDMETHODCALLTYPE ISQLXMLBulkLoad_put_KeepNulls_Proxy( 
    ISQLXMLBulkLoad * This,
    /* [in] */ VARIANT_BOOL fKeepNulls);


void __RPC_STUB ISQLXMLBulkLoad_put_KeepNulls_Stub(
    IRpcStubBuffer *This,
    IRpcChannelBuffer *_pRpcChannelBuffer,
    PRPC_MESSAGE _pRpcMessage,
    DWORD *_pdwStubPhase);


/* [helpstring][id][propget] */ HRESULT STDMETHODCALLTYPE ISQLXMLBulkLoad_get_KeepIdentity_Proxy( 
    ISQLXMLBulkLoad * This,
    /* [retval][out] */ VARIANT_BOOL *pfKeepIdentity);


void __RPC_STUB ISQLXMLBulkLoad_get_KeepIdentity_Stub(
    IRpcStubBuffer *This,
    IRpcChannelBuffer *_pRpcChannelBuffer,
    PRPC_MESSAGE _pRpcMessage,
    DWORD *_pdwStubPhase);


/* [helpstring][id][propput] */ HRESULT STDMETHODCALLTYPE ISQLXMLBulkLoad_put_KeepIdentity_Proxy( 
    ISQLXMLBulkLoad * This,
    /* [in] */ VARIANT_BOOL fKeepIdentity);


void __RPC_STUB ISQLXMLBulkLoad_put_KeepIdentity_Stub(
    IRpcStubBuffer *This,
    IRpcChannelBuffer *_pRpcChannelBuffer,
    PRPC_MESSAGE _pRpcMessage,
    DWORD *_pdwStubPhase);


/* [helpstring][id][propget] */ HRESULT STDMETHODCALLTYPE ISQLXMLBulkLoad_get_CheckConstraints_Proxy( 
    ISQLXMLBulkLoad * This,
    /* [retval][out] */ VARIANT_BOOL *pfCheckConstraints);


void __RPC_STUB ISQLXMLBulkLoad_get_CheckConstraints_Stub(
    IRpcStubBuffer *This,
    IRpcChannelBuffer *_pRpcChannelBuffer,
    PRPC_MESSAGE _pRpcMessage,
    DWORD *_pdwStubPhase);


/* [helpstring][id][propput] */ HRESULT STDMETHODCALLTYPE ISQLXMLBulkLoad_put_CheckConstraints_Proxy( 
    ISQLXMLBulkLoad * This,
    /* [in] */ VARIANT_BOOL fCheckConstraints);


void __RPC_STUB ISQLXMLBulkLoad_put_CheckConstraints_Stub(
    IRpcStubBuffer *This,
    IRpcChannelBuffer *_pRpcChannelBuffer,
    PRPC_MESSAGE _pRpcMessage,
    DWORD *_pdwStubPhase);


/* [helpstring][id][propget] */ HRESULT STDMETHODCALLTYPE ISQLXMLBulkLoad_get_ForceTableLock_Proxy( 
    ISQLXMLBulkLoad * This,
    /* [retval][out] */ VARIANT_BOOL *pfForceTableLock);


void __RPC_STUB ISQLXMLBulkLoad_get_ForceTableLock_Stub(
    IRpcStubBuffer *This,
    IRpcChannelBuffer *_pRpcChannelBuffer,
    PRPC_MESSAGE _pRpcMessage,
    DWORD *_pdwStubPhase);


/* [helpstring][id][propput] */ HRESULT STDMETHODCALLTYPE ISQLXMLBulkLoad_put_ForceTableLock_Proxy( 
    ISQLXMLBulkLoad * This,
    /* [in] */ VARIANT_BOOL fForceTableLock);


void __RPC_STUB ISQLXMLBulkLoad_put_ForceTableLock_Stub(
    IRpcStubBuffer *This,
    IRpcChannelBuffer *_pRpcChannelBuffer,
    PRPC_MESSAGE _pRpcMessage,
    DWORD *_pdwStubPhase);


/* [helpstring][id][propget] */ HRESULT STDMETHODCALLTYPE ISQLXMLBulkLoad_get_XMLFragment_Proxy( 
    ISQLXMLBulkLoad * This,
    /* [retval][out] */ VARIANT_BOOL *pfXMLFragment);


void __RPC_STUB ISQLXMLBulkLoad_get_XMLFragment_Stub(
    IRpcStubBuffer *This,
    IRpcChannelBuffer *_pRpcChannelBuffer,
    PRPC_MESSAGE _pRpcMessage,
    DWORD *_pdwStubPhase);


/* [helpstring][id][propput] */ HRESULT STDMETHODCALLTYPE ISQLXMLBulkLoad_put_XMLFragment_Proxy( 
    ISQLXMLBulkLoad * This,
    /* [in] */ VARIANT_BOOL fXMLFragment);


void __RPC_STUB ISQLXMLBulkLoad_put_XMLFragment_Stub(
    IRpcStubBuffer *This,
    IRpcChannelBuffer *_pRpcChannelBuffer,
    PRPC_MESSAGE _pRpcMessage,
    DWORD *_pdwStubPhase);


/* [helpstring][id][propget] */ HRESULT STDMETHODCALLTYPE ISQLXMLBulkLoad_get_Transaction_Proxy( 
    ISQLXMLBulkLoad * This,
    /* [retval][out] */ VARIANT_BOOL *pfTransaction);


void __RPC_STUB ISQLXMLBulkLoad_get_Transaction_Stub(
    IRpcStubBuffer *This,
    IRpcChannelBuffer *_pRpcChannelBuffer,
    PRPC_MESSAGE _pRpcMessage,
    DWORD *_pdwStubPhase);


/* [helpstring][id][propput] */ HRESULT STDMETHODCALLTYPE ISQLXMLBulkLoad_put_Transaction_Proxy( 
    ISQLXMLBulkLoad * This,
    /* [in] */ VARIANT_BOOL fTransaction);


void __RPC_STUB ISQLXMLBulkLoad_put_Transaction_Stub(
    IRpcStubBuffer *This,
    IRpcChannelBuffer *_pRpcChannelBuffer,
    PRPC_MESSAGE _pRpcMessage,
    DWORD *_pdwStubPhase);


/* [helpstring][id][propget] */ HRESULT STDMETHODCALLTYPE ISQLXMLBulkLoad_get_IgnoreDuplicateKeys_Proxy( 
    ISQLXMLBulkLoad * This,
    /* [retval][out] */ VARIANT_BOOL *pfIgnoreDuplicateKeys);


void __RPC_STUB ISQLXMLBulkLoad_get_IgnoreDuplicateKeys_Stub(
    IRpcStubBuffer *This,
    IRpcChannelBuffer *_pRpcChannelBuffer,
    PRPC_MESSAGE _pRpcMessage,
    DWORD *_pdwStubPhase);


/* [helpstring][id][propput] */ HRESULT STDMETHODCALLTYPE ISQLXMLBulkLoad_put_IgnoreDuplicateKeys_Proxy( 
    ISQLXMLBulkLoad * This,
    /* [in] */ VARIANT_BOOL fIgnoreDuplicateKeys);


void __RPC_STUB ISQLXMLBulkLoad_put_IgnoreDuplicateKeys_Stub(
    IRpcStubBuffer *This,
    IRpcChannelBuffer *_pRpcChannelBuffer,
    PRPC_MESSAGE _pRpcMessage,
    DWORD *_pdwStubPhase);


/* [helpstring][id][propget] */ HRESULT STDMETHODCALLTYPE ISQLXMLBulkLoad_get_BulkLoad_Proxy( 
    ISQLXMLBulkLoad * This,
    /* [retval][out] */ VARIANT_BOOL *pfBulkLoad);


void __RPC_STUB ISQLXMLBulkLoad_get_BulkLoad_Stub(
    IRpcStubBuffer *This,
    IRpcChannelBuffer *_pRpcChannelBuffer,
    PRPC_MESSAGE _pRpcMessage,
    DWORD *_pdwStubPhase);


/* [helpstring][id][propput] */ HRESULT STDMETHODCALLTYPE ISQLXMLBulkLoad_put_BulkLoad_Proxy( 
    ISQLXMLBulkLoad * This,
    /* [in] */ VARIANT_BOOL fBulkLoad);


void __RPC_STUB ISQLXMLBulkLoad_put_BulkLoad_Stub(
    IRpcStubBuffer *This,
    IRpcChannelBuffer *_pRpcChannelBuffer,
    PRPC_MESSAGE _pRpcMessage,
    DWORD *_pdwStubPhase);


/* [helpstring][id][propget] */ HRESULT STDMETHODCALLTYPE ISQLXMLBulkLoad_get_SchemaGen_Proxy( 
    ISQLXMLBulkLoad * This,
    /* [retval][out] */ VARIANT_BOOL *pfSchemaGen);


void __RPC_STUB ISQLXMLBulkLoad_get_SchemaGen_Stub(
    IRpcStubBuffer *This,
    IRpcChannelBuffer *_pRpcChannelBuffer,
    PRPC_MESSAGE _pRpcMessage,
    DWORD *_pdwStubPhase);


/* [helpstring][id][propput] */ HRESULT STDMETHODCALLTYPE ISQLXMLBulkLoad_put_SchemaGen_Proxy( 
    ISQLXMLBulkLoad * This,
    /* [in] */ VARIANT_BOOL fSchemaGen);


void __RPC_STUB ISQLXMLBulkLoad_put_SchemaGen_Stub(
    IRpcStubBuffer *This,
    IRpcChannelBuffer *_pRpcChannelBuffer,
    PRPC_MESSAGE _pRpcMessage,
    DWORD *_pdwStubPhase);


/* [helpstring][id][propget] */ HRESULT STDMETHODCALLTYPE ISQLXMLBulkLoad_get_SGDropTables_Proxy( 
    ISQLXMLBulkLoad * This,
    /* [retval][out] */ VARIANT_BOOL *pfDropTables);


void __RPC_STUB ISQLXMLBulkLoad_get_SGDropTables_Stub(
    IRpcStubBuffer *This,
    IRpcChannelBuffer *_pRpcChannelBuffer,
    PRPC_MESSAGE _pRpcMessage,
    DWORD *_pdwStubPhase);


/* [helpstring][id][propput] */ HRESULT STDMETHODCALLTYPE ISQLXMLBulkLoad_put_SGDropTables_Proxy( 
    ISQLXMLBulkLoad * This,
    /* [in] */ VARIANT_BOOL fDropTables);


void __RPC_STUB ISQLXMLBulkLoad_put_SGDropTables_Stub(
    IRpcStubBuffer *This,
    IRpcChannelBuffer *_pRpcChannelBuffer,
    PRPC_MESSAGE _pRpcMessage,
    DWORD *_pdwStubPhase);


/* [helpstring][id][propget] */ HRESULT STDMETHODCALLTYPE ISQLXMLBulkLoad_get_SGUseID_Proxy( 
    ISQLXMLBulkLoad * This,
    /* [retval][out] */ VARIANT_BOOL *pfUseID);


void __RPC_STUB ISQLXMLBulkLoad_get_SGUseID_Stub(
    IRpcStubBuffer *This,
    IRpcChannelBuffer *_pRpcChannelBuffer,
    PRPC_MESSAGE _pRpcMessage,
    DWORD *_pdwStubPhase);


/* [helpstring][id][propput] */ HRESULT STDMETHODCALLTYPE ISQLXMLBulkLoad_put_SGUseID_Proxy( 
    ISQLXMLBulkLoad * This,
    /* [in] */ VARIANT_BOOL fUseID);


void __RPC_STUB ISQLXMLBulkLoad_put_SGUseID_Stub(
    IRpcStubBuffer *This,
    IRpcChannelBuffer *_pRpcChannelBuffer,
    PRPC_MESSAGE _pRpcMessage,
    DWORD *_pdwStubPhase);


/* [helpstring][id][propget] */ HRESULT STDMETHODCALLTYPE ISQLXMLBulkLoad_get_ErrorLogFile_Proxy( 
    ISQLXMLBulkLoad * This,
    /* [retval][out] */ BSTR *pbstrFileName);


void __RPC_STUB ISQLXMLBulkLoad_get_ErrorLogFile_Stub(
    IRpcStubBuffer *This,
    IRpcChannelBuffer *_pRpcChannelBuffer,
    PRPC_MESSAGE _pRpcMessage,
    DWORD *_pdwStubPhase);


/* [helpstring][id][propput] */ HRESULT STDMETHODCALLTYPE ISQLXMLBulkLoad_put_ErrorLogFile_Proxy( 
    ISQLXMLBulkLoad * This,
    /* [in] */ BSTR bstrFileName);


void __RPC_STUB ISQLXMLBulkLoad_put_ErrorLogFile_Stub(
    IRpcStubBuffer *This,
    IRpcChannelBuffer *_pRpcChannelBuffer,
    PRPC_MESSAGE _pRpcMessage,
    DWORD *_pdwStubPhase);


/* [helpstring][id][propget] */ HRESULT STDMETHODCALLTYPE ISQLXMLBulkLoad_get_TempFilePath_Proxy( 
    ISQLXMLBulkLoad * This,
    /* [retval][out] */ BSTR *pbstrTempFilePath);


void __RPC_STUB ISQLXMLBulkLoad_get_TempFilePath_Stub(
    IRpcStubBuffer *This,
    IRpcChannelBuffer *_pRpcChannelBuffer,
    PRPC_MESSAGE _pRpcMessage,
    DWORD *_pdwStubPhase);


/* [helpstring][id][propput] */ HRESULT STDMETHODCALLTYPE ISQLXMLBulkLoad_put_TempFilePath_Proxy( 
    ISQLXMLBulkLoad * This,
    /* [in] */ BSTR bstrTempFilePath);


void __RPC_STUB ISQLXMLBulkLoad_put_TempFilePath_Stub(
    IRpcStubBuffer *This,
    IRpcChannelBuffer *_pRpcChannelBuffer,
    PRPC_MESSAGE _pRpcMessage,
    DWORD *_pdwStubPhase);


/* [helpstring][id] */ HRESULT STDMETHODCALLTYPE ISQLXMLBulkLoad_Execute_Proxy( 
    ISQLXMLBulkLoad * This,
    /* [in] */ BSTR bstrSchemaFile,
    /* [optional][in] */ VARIANT vDataFile);


void __RPC_STUB ISQLXMLBulkLoad_Execute_Stub(
    IRpcStubBuffer *This,
    IRpcChannelBuffer *_pRpcChannelBuffer,
    PRPC_MESSAGE _pRpcMessage,
    DWORD *_pdwStubPhase);



#endif 	/* __ISQLXMLBulkLoad_INTERFACE_DEFINED__ */



#ifndef __SQLXMLBULKLOADLib_LIBRARY_DEFINED__
#define __SQLXMLBULKLOADLib_LIBRARY_DEFINED__

/* library SQLXMLBULKLOADLib */
/* [helpstring][version][uuid] */ 


EXTERN_C const IID LIBID_SQLXMLBULKLOADLib;

EXTERN_C const CLSID CLSID_SQLXMLBulkLoad;

#ifdef __cplusplus

class DECLSPEC_UUID("1DB51355-B2CA-43cb-B045-1FAA42A724B2")
SQLXMLBulkLoad;
#endif

EXTERN_C const CLSID CLSID_SQLXMLBulkLoad3;

#ifdef __cplusplus

class DECLSPEC_UUID("8270CB2F-B0E6-4c37-8A40-D70778F47894")
SQLXMLBulkLoad3;
#endif
#endif /* __SQLXMLBULKLOADLib_LIBRARY_DEFINED__ */

/* Additional Prototypes for ALL interfaces */

unsigned long             __RPC_USER  BSTR_UserSize(     unsigned long *, unsigned long            , BSTR * ); 
unsigned char * __RPC_USER  BSTR_UserMarshal(  unsigned long *, unsigned char *, BSTR * ); 
unsigned char * __RPC_USER  BSTR_UserUnmarshal(unsigned long *, unsigned char *, BSTR * ); 
void                      __RPC_USER  BSTR_UserFree(     unsigned long *, BSTR * ); 

unsigned long             __RPC_USER  VARIANT_UserSize(     unsigned long *, unsigned long            , VARIANT * ); 
unsigned char * __RPC_USER  VARIANT_UserMarshal(  unsigned long *, unsigned char *, VARIANT * ); 
unsigned char * __RPC_USER  VARIANT_UserUnmarshal(unsigned long *, unsigned char *, VARIANT * ); 
void                      __RPC_USER  VARIANT_UserFree(     unsigned long *, VARIANT * ); 

/* end of Additional Prototypes */

#ifdef __cplusplus
}
#endif

#endif


