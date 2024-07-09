@ECHO OFF

start pwsh -NoExit -Command "C:\sciter-js-sdk\bin\windows\packfolder.exe ui prog\src\resources.cpp -v 'resources' && make"
