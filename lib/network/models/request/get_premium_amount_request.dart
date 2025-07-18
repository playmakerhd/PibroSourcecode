class GetPremiumAmountRequest {
  GetPremiumAmountRequest({
    required this.brokerId,
    required this.startDate,
    required this.endDate,
  });

  final String brokerId;
  final String startDate;
  final String endDate;
}
