::@ECHO OFF


:: ----------------------------------------- Register assemblies -------------------------------------------------
regasm C:\GvrPlus\1\lib\GvrPeUtil.dll /Unregister
regasm C:\GvrPlus\1\lib\GvrPeSchemaUtil.dll /Unregister
regasm C:\GvrPlus\1\lib\GvrPeClient.dll /Unregister
regasm C:\GvrPlus\1\lib\GvrPeEngine.dll /Unregister
regasm C:\GvrPlus\1\lib\GvrPeDialer.dll /Unregister

gacutil /u C:\GvrPlus\1\lib\GvrPeUtil.dll
gacutil /u C:\GvrPlus\1\lib\GvrPeSchemaUtil.dll
gacutil /u C:\GvrPlus\1\lib\GvrPeClient.dll
gacutil /u C:\GvrPlus\1\lib\GvrPeEngine.dll
gacutil /u C:\GvrPlus\1\lib\GvrPeDialer.dll

regasm C:\GvrPlus\1\lib\GvrPeUtil.dll
regasm C:\GvrPlus\1\lib\GvrPeSchemaUtil.dll 
regasm C:\GvrPlus\1\lib\GvrPeClient.dll
regasm C:\GvrPlus\1\lib\GvrPeEngine.dll
regasm C:\GvrPlus\1\lib\GvrPeDialer.dll

gacutil -i C:\GvrPlus\1\lib\GvrPeUtil.dll
gacutil -i C:\GvrPlus\1\lib\GvrPeSchemaUtil.dll
gacutil -i C:\GvrPlus\1\lib\GvrPeClient.dll
gacutil -i C:\GvrPlus\1\lib\GvrPeEngine.dll
gacutil -i C:\GvrPlus\1\lib\GvrPeDialer.dll

popd