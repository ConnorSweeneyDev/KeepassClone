#!/usr/bin/bash

~\sciter-js-sdk\bin\linux\packfolder ui prog\include\resources.cpp -v 'resources' && make -j $(python3 -c 'import multiprocessing as mp; print(int(mp.cpu_count() * 1.5))')
