@ECHO OFF

start pwsh -NoExit -Command "C:\sciter-js-sdk\bin\windows\packfolder.exe ui prog\include\resources.cpp -v 'resources' && make -j $(python3 -c 'import multiprocessing as mp; print(int(mp.cpu_count() * 1.5))')"
