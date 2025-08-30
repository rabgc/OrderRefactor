#include <gtest/gtest.h>
#include "order.hpp"
#include <string>

static Order base(std::string state, bool preferred=false) {
  return Order{ "cust-1",
    {
      {"A", 2, 10.0, true},
      {"BULK_X", 12, 5.0, true},
      {"NTY", 1, 100.0, false}
    },
    state, preferred
  };
}

TEST(Smoke, BuildsAndRuns) {
  auto o = base("CA");
  EXPECT_NO_THROW(calc_order_total(o));
}

TEST(Unit, TaxAndBulkAndShipping) {
  auto o = base("CA");
  // Manual expectation establishes *current behavior*
  // A: 2*10=20 (taxed 8.25%) -> 21.65
  // BULK_X: 12*5=60 -> bulk -10% = 54, taxed -> 54*(1+0.0825)=58.455
  // NTY: 1*100 = 100 (non-taxable)
  // Subtotal before shipping: 21.65 + 58.455 + 100 = 180.105
  // Shipping: free (>= 50)
  // Preferred: no
  // CA cap: none (<= 500)
  EXPECT_NEAR(calc_order_total(o), 180.105, 1e-6);
}

TEST(Unit, ShippingAppliedUnderThreshold) {
  Order o{ "cust-2", { {"A",1,10.0,true} }, "OR", false };
  // 10 taxed 0% = 10; shipping +7.99 => 17.99
  EXPECT_NEAR(calc_order_total(o), 17.99, 1e-6);
}

TEST(Unit, PreferredDiscountAfterEverything) {
  auto o = base("NY", true);
  double total = calc_order_total(o);
  auto o2 = base("NY", false);
  EXPECT_LT(total, calc_order_total(o2));
}

TEST(Integration, CaliforniaCap) {
  Order o{ "cust-3",
           { {"EXP", 100, 10.0, true} },
           "CA", true };
  // Capped at 500 in CA
  EXPECT_DOUBLE_EQ(calc_order_total(o), 500.0);
}
