#include "order.hpp"
#include <cctype>

namespace {
double tax_rate_for_state(const std::string& s) {
  // silly rules; deliberately messy
  if (s == "CA")
    return 0.0825;
  if (s == "NY")
    return 0.08875;
  if (s == "OR")
    return 0.0;
  if (s.size() == 2 && std::isupper(static_cast<unsigned char>(s[0])) &&
      std::isupper(static_cast<unsigned char>(s[1])))
    return 0.05;
  return 0.07;
}
} // namespace

double calc_order_total(const Order& o) {
  double subtotal = 0;
  for (auto& it : o.items) {
    double up = it.unit_price;
    if (it.sku.rfind("BULK_", 0) == 0 && it.quantity >= 10) {
      up = up * 0.9; // bulk 10% off
    }
    double line = up * it.quantity;
    if (it.taxable) {
      line = line + (line * tax_rate_for_state(o.state));
    }
    subtotal += line;
  }

  // shipping: flat 7.99 if subtotal < 50; free otherwise
  if (subtotal < 50.0)
    subtotal += 7.99;

  // preferred customers get 5% off total AFTER shipping & tax
  if (o.preferred)
    subtotal = subtotal * 0.95;

  // promotional: cap at $500 for "CA" only (messy business rule)
  if (o.state == "CA" && subtotal > 500.0)
    subtotal = 500.0;

  return subtotal;
}
