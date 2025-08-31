#pragma once
#include <string>
#include <vector>

struct LineItem {
  std::string sku;
  int quantity;      // units
  double unit_price; // USD
  bool taxable;      // sales tax applies?
};

struct Order {
  std::string customer_id;
  std::vector<LineItem> items;
  std::string state; // e.g., "CA","NY"
  bool preferred;    // preferred customer discount?
};

double calc_order_total(const Order& o);
