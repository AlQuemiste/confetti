# Building Boost from source under MS-Windows 10
[7.10.2021]

* Compiler MSVC Compiler (2019), version 19 (MSVC v142) for x64

* Obtain Boost source from the website.

* Obtain the sources for [zlib](https://zlib.net) and [bzip2](https://www.sourceware.org/bzip2).

* Bootstrapping Boost: Build `Boost.Build` component inside Boost _root_ directory:
  ```
  $ .\bootstrap.bat
  ```

* Building Boost:
  - See Boost::iostream [installation docs](https://www.boost.org/doc/libs/1_77_0/libs/iostreams/doc/installation.html) and B2 [user manual](https://www.boost.org/doc/libs/1_77_0/tools/build/doc/html/index.html).
  - Assuming that `zlib` source is placed inside `C:/opt/x64/src/zlib`, and `bzip2` source is placed inside `C:/opt/x64/src/bzip2`.
  - Note that LZMA and ZSTD libraries are excluded.
  - The installation folder is `C:/opt/x64/boost_1_77` and build folder is `C:/tmp/buildboost_1_77`.
  - Inside Boost _root_ directory:
    ```
    $ .\b2 install -j 4
    --prefix="C:/opt/x64/boost_1_77" --build-dir="C:/tmp/buildboost_1_77" 
    --with-program_options
    --with-iostreams --with-regex
    --with-filesystem --with-system
    toolset=msvc address-model=64 variant=release
    optimization=speed link=static,shared runtime-link=shared
    threading=single,multi
    -s ZLIB_SOURCE="C:/opt/x64/src/zlib" -s BZIP2_SOURCE="C:/opt/x64/src/bzip2" -s NO_LZMA -s NO_ZSTD
    ```
