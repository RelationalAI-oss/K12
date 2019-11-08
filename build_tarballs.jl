# Note that this script can accept some limited command-line arguments, run
# `julia build_tarballs.jl --help` to see a usage message.
using BinaryBuilder

name = "libk12"
version = v"0.0.1"

# Collection of sources required to build tpch-dbgen
sources = [
    "http://xmlsoft.org/sources/libxml2-2.9.9.tar.gz" => "94fb70890143e3c6549f265cee93ec064c80a84c42ad0f23e85ee1fd6540a871",
    "http://xmlsoft.org/sources/libxslt-1.1.33.tar.gz" => "8e36605144409df979cab43d835002f63988f3dc94d5d3537c12796db90e38c8",
    joinpath(pwd())
]

# Bash recipe for building across all platforms
script = raw"""
cd $WORKSPACE/srcdir

apk add libxslt

targets="generic64/libk12.so Haswell/libk12.so SkylakeX/libk12.so"
if [ $target = "x86_64-apple-darwin14" ]; then
  targets="generic64/libk12.so"
fi

make $targets

mkdir -p $prefix/lib

if [ $target = "x86_64-apple-darwin14" ]; then
  cp bin/generic64/libk12.so $prefix/lib/libk12.dylib
else
  cp bin/generic64/libk12.so $prefix/lib
  cp bin/Haswell/libk12.so $prefix/lib/libk12-avx2.so
  cp bin/SkylakeX/libk12.so $prefix/lib/libk12-avx512vl.so
fi

"""

# These are the platforms we will build for by default, unless further
# platforms are passed in on the command line
platforms = [
    Linux(:x86_64, libc=:glibc, compiler_abi=CompilerABI(:gcc7, :cxx11))
    MacOS(:x86_64)
]

# The products that we will ensure are always built
products(prefix) = [
    LibraryProduct(prefix, "libk12", :libk12)
]

# Dependencies that must be installed before this package can be built
dependencies = [
]

# Build the tarballs, and possibly a `build.jl` as well.
build_tarballs(ARGS, name, version, sources, script, platforms, products, dependencies)

