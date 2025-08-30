# TEST STRUCTURE REMINDER:
# - Individual tests are auto-discovered from order_tests.cpp using gtest_discover_tests.
# - Grouped tests (order_smoke, order_unit, order_integration) are registered manually.
#   Each grouped test runs all tests in a suite (e.g., Smoke.*) using GoogleTest's filter.
# - Only grouped tests have CTest labels ("smoke", "unit", "integration") for fast filtering.
#   Individual tests do NOT have labels and always run with ctest --test-dir build.
# - To run only smoke/unit tests quickly:
#     ctest --test-dir build -L "unit|smoke"
# - To run all tests:
#     ctest --test-dir build
#
# This setup allows rapid suite-based test runs for refactoring, while keeping individual test 
#   results for debugging.

include(GoogleTest)

add_executable(order_tests order_tests.cpp)
target_link_libraries(order_tests PRIVATE order GTest::gtest_main)
target_include_directories(order_tests PRIVATE ${CMAKE_SOURCE_DIR}/src)

# (Optional) Still register each individual test for full runs/reporting:
gtest_discover_tests(order_tests)

# Add grouped/labeled suites that reuse the same binary with gtest filters
add_test(NAME order_smoke COMMAND order_tests --gtest_filter=Smoke.*)
set_tests_properties(order_smoke PROPERTIES LABELS "smoke")

add_test(NAME order_unit COMMAND order_tests --gtest_filter=Unit.*)
set_tests_properties(order_unit PROPERTIES LABELS "unit")

add_test(NAME order_integration COMMAND order_tests --gtest_filter=Integration.*)
set_tests_properties(order_integration PROPERTIES LABELS "integration")

# (Optional) add slow/e2e groups if you use them:
# add_test(NAME order_slow COMMAND order_tests --gtest_filter=Slow.*)
# set_tests_properties(order_slow PROPERTIES LABELS "slow")
# add_test(NAME order_e2e COMMAND order_tests --gtest_filter=E2E.*)
# set_tests_properties(order_e2e PROPERTIES LABELS "e2e")
