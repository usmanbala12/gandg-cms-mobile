class TPricingCalculator {
  static const double nigeriaTaxRate = 0.075; // 7.5% VAT in Nigeria
  static const double internationalTaxRate =
      0.05; // 5% VAT for international orders

  static double getTaxRate(String location, {bool international = false}) {
    return international ? internationalTaxRate : nigeriaTaxRate;
  }

  static double getShippingCost(String location, {bool international = false}) {
    if (international) {
      // Define international shipping rates
      Map<String, double> internationalShippingRates = {
        "USA": 15000,
        "UK": 14000,
        "Canada": 16000,
        "Germany": 15500,
        "Other": 18000,
      };
      return internationalShippingRates[location] ??
          internationalShippingRates["Other"]!;
    }

    // Define local shipping costs based on location
    Map<String, double> localShippingRates = {
      "Lagos": 2000,
      "Abuja": 2500,
      "Kano": 3000,
      "Port Harcourt": 2800,
      "Other": 3500,
    };

    return localShippingRates[location] ?? localShippingRates["Other"]!;
  }

  static double calculateTotalPrice({
    required double basePrice,
    required String location,
    bool international = false,
  }) {
    double taxRate = getTaxRate(location, international: international);
    double taxAmount = basePrice * taxRate;
    double shippingCost =
        getShippingCost(location, international: international);
    double totalPrice = basePrice + taxAmount + shippingCost;
    return totalPrice;
  }
}
