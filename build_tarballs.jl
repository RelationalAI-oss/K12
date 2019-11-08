# Note that this script can accept some limited command-line arguments, run
# `julia build_tarballs.jl --help` to see a usage message.
using BinaryBuilder

name = "libk12"
version = v"0.0.1"

# Collection of sources required to build tpch-dbgen
sources = [
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

