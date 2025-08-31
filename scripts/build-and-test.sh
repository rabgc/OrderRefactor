#!/usr/bin/env bash
set -euo pipefail

MODE="quick"
BUILD_TYPE="Debug"
JOBS="${JOBS:-$(command -v nproc >/dev/null 2>&1 && nproc || sysctl -n hw.ncpu || echo 4)}"
SANITIZE="none"
COVERAGE="off"
CMAKE_ARGS=()
CLEAN="no"

while [[ $# -gt 0 ]]; do
  case "$1" in
    --mode) MODE="${2:?}"; shift 2;;
    --build-type) BUILD_TYPE="${2:?}"; shift 2;;
    --jobs) JOBS="${2:?}"; shift 2;;
    --sanitize) SANITIZE="${2:?}"; shift 2;;
    --coverage) COVERAGE="${2:?}"; shift 2;;
    --clean) CLEAN="yes"; shift ;;
    --cmake-arg) CMAKE_ARGS+=("$2"); shift 2;;
    -h|--help) echo "Usage: $0 [--mode quick|full] [--build-type Debug|RelWithDebInfo|Release]"; exit 0;;
    *) echo "Unknown arg: $1"; exit 2;;
  esac
done

BUILD_DIR="build/${BUILD_TYPE}-${MODE}"
mkdir -p "$(dirname "${BUILD_DIR}")"
if [[ "${CLEAN}" == "yes" && -d "${BUILD_DIR}" ]]; then rm -rf "${BUILD_DIR}"; fi

CMAKE_CACHE_FLAGS=( -DCMAKE_BUILD_TYPE="${BUILD_TYPE}" -DCMAKE_EXPORT_COMPILE_COMMANDS=ON )

SAN_FLAGS=""
case "${SANITIZE}" in
  asan)        SAN_FLAGS="-fsanitize=address -fno-omit-frame-pointer" ;;
  ubsan)       SAN_FLAGS="-fsanitize=undefined -fno-omit-frame-pointer" ;;
  asan+ubsan)  SAN_FLAGS="-fsanitize=address,undefined -fno-omit-frame-pointer" ;;
  none)        SAN_FLAGS="" ;;
  *) echo "Unknown --sanitize ${SANITIZE}"; exit 2;;
esac
if [[ -n "${SAN_FLAGS}" ]]; then
  CMAKE_CACHE_FLAGS+=( -DCMAKE_CXX_FLAGS="${SAN_FLAGS}" -DCMAKE_C_FLAGS="${SAN_FLAGS}" )
fi

if [[ "${COVERAGE}" == "on" ]]; then
  COV_FLAGS="--coverage -O0 -g"
  CMAKE_CACHE_FLAGS+=( -DCMAKE_CXX_FLAGS="${SAN_FLAGS} ${COV_FLAGS}"
                       -DCMAKE_C_FLAGS="${SAN_FLAGS} ${COV_FLAGS}"
                       -DCMAKE_EXE_LINKER_FLAGS="--coverage"
                       -DCMAKE_SHARED_LINKER_FLAGS="--coverage" )
fi

CTEST_ARGS=( --output-on-failure -j "${JOBS}" )
if [[ "${MODE}" == "quick" ]]; then
  CTEST_ARGS+=( -L "unit|smoke" -E "slow|e2e|integration" )
elif [[ "${MODE}" == "full" ]]; then
  :
else
  echo "Unknown --mode ${MODE}"; exit 2
fi

echo "==> Config: MODE=${MODE} BUILD_TYPE=${BUILD_TYPE} JOBS=${JOBS} SANITIZE=${SANITIZE} COVERAGE=${COVERAGE}"
echo "==> BUILD_DIR=${BUILD_DIR}"

CMAKE_ARGS=("${CMAKE_ARGS[@]:-}") 
cmake -S . -B "${BUILD_DIR}" "${CMAKE_CACHE_FLAGS[@]}" "${CMAKE_ARGS[@]}"
cmake --build "${BUILD_DIR}" -j "${JOBS}"
ctest --test-dir "${BUILD_DIR}" "${CTEST_ARGS[@]}"
echo "Done."
