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

## Pre-commit integration with git

```bash
pip install pre-commit

# Install to run hooks automatically when making a commit
pre-commit install

# Try on all files once
pre-commit run --all-files
```

## Refactoring steps (suggested)

1. Baseline run: ensure all tests pass.
2. Extract helpers: pricing, tax, shipping; keep behavior identical.
	 - **Pricing Helper:** Calculates total price for each item, applying bulk or preferred discounts.
	 - **Tax Helper:** Determines applicable tax for each item or order, based on state and item type.
	 - **Shipping Helper:** Calculates shipping costs, considering free shipping thresholds and special rules.
3. Replace magic numbers with named constants.
4. Introduce `PricingPolicy` seam (without changing behavior).
5. Improve readability and reduce conditional complexity.
6. (Optional) Inject tax policy function for testability.

**Test-Driven Development (TDD) Recommended:**  
For each refactoring or new feature, start by writing or updating a test that describes the desired behavior. Only then make code changes to pass the test. This approach helps ensure correctness and makes refactoring safer.

**Running and Adding Tests:**  
- To run a specific test or suite:
	```bash
	ctest --test-dir build -R <TestName>
	```
	Or:
	```bash
	./build/order_tests --gtest_filter=TestSuiteName.TestName
	```
- To add new tests, edit `tests/order_tests.cpp` using the `TEST` or `TEST_F` macros. Rebuild and run the suite to verify your changes.

Commit frequently; run tests after every tiny change.
