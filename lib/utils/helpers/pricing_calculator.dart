class YPricingCalculator {
  /// Calculates price based on tax and shipping.
  static double calculateTotalPrice(double productPrice, String location) {
    double shippingCost = getShippingCost(location);

    double totalPrice = productPrice + shippingCost;
    return totalPrice;
  }

  /// Calculates shipping cost
  static String calculateShippingCost(double subTotal, String location) {
    double shippingCost = 1.0; // always $1
    return shippingCost.toStringAsFixed(2);
  }

  /// Calculates tax
  static String calculateTaxAmount(double productPrice, String location) {
    double taxRate = getTaxRateForLocation(location);
    double taxAmount = productPrice * taxRate;
    return taxAmount.toStringAsFixed(2);
  }

  static double getTaxRateForLocation(String location) {
    return 0.0; // 10% tax rate for demonstration
  }

  static double getShippingCost(String location) {
    return 1.00; // Flat $1 shipping
  }

  /// Calculates shipping from coordinates.
  /// Returns null when the location is outside supported delivery area.
  static double? calculateShippingFeeByCoordinates({
    required double latitude,
    required double longitude,
  }) {
    // Cambodia bounding box.
    final inCambodia =
        latitude >= 9.2 && latitude <= 14.9 && longitude >= 102.3 && longitude <= 108.0;
    if (!inCambodia) return null;

    // Phnom Penh zone gets lower shipping.
    final inPhnomPenh =
        latitude >= 11.45 && latitude <= 11.70 && longitude >= 104.75 && longitude <= 105.05;
    return inPhnomPenh ? 1.00 : 1.00;
  }
}
