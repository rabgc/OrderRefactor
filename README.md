# Order Refactoring Kata (C++ / CMake / GoogleTest)

A self-contained kata to practice refactoring with tests as guardrails.

## Quick start

```bash
# Configure + build
cmake -S . -B build -DCMAKE_BUILD_TYPE=Debug
cmake --build build -j

# Run all tests
ctest --test-dir build --output-on-failure

# Or run quick smoke/unit tests only (used by pre-commit quick mode)
ctest --test-dir build -L "unit|smoke" -E "slow|integration|e2e" --output-on-failure
```

## Pre-commit (optional but recommended)

```bash
pip install pre-commit
pre-commit install
# Try on all files once
pre-commit run --all-files
```

## Refactoring steps (suggested)

1. Baseline run: ensure all tests pass.
2. Extract helpers: pricing, tax, shipping; keep behavior identical.
3. Replace magic numbers with named constants.
4. Introduce `PricingPolicy` seam (without changing behavior).
5. Improve readability and reduce conditional complexity.
6. (Optional) Inject tax policy function for testability.

Commit frequently; run tests after every tiny change.
