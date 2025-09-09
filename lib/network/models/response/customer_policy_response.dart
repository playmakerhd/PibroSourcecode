import 'dart:math';

import 'base_response.dart';

class CustomerPolicyResponse extends CustomBaseResponse {
  CustomerPolicyResponse(super.responseData);

  late List<PolicyData> policies;

  @override
  parseResponseData() {
    try {
      policies = getResponseBody() != []
          ? List.from(getResponseBody())
              .map((item) => PolicyData.fromJson(item))
              .toList()
          : [];
    } catch (e) {
      handleParsingError(e);
    }
  }
}

abstract class PolicyDetails {
  PolicyDetails({
    required this.companyID,
    required this.divisionID,
    required this.departmentID,
    required this.policyBrokerID,
  });

  String companyID;
  String divisionID;
  String departmentID;
  String policyBrokerID;
}

class PolicyData implements PolicyDetails {
  PolicyData({
    required this.companyID,
    required this.divisionID,
    required this.departmentID,
    required this.policyBrokerID,
    this.actualPolicyBrokerID,
    this.customerID,
    this.vendorID,
    this.projectTypeID,
    this.projectID,
    this.businessClassID,
    this.riskTypeID,
    this.policyDescription,
    this.policyCoInsured = false,
    this.policyCoBroked = false,
    this.sumInsured,
    this.premiumAmount,
    this.commissionable = false,
    this.brokerCommission,
    this.policyStartDate,
    this.policyEndDate,
    this.renewalDate,
    this.employeeID,
    this.insurancePremiumMethodsID,
    this.enterDate,
    this.customerName,
    this.inActive = false,
    this.branchCode,
    this.approved = false,
    this.approvedBy,
    this.itemsToInsure,
    this.insurancePolicyUnderwriters,
    this.enteredBy,
    this.insuranceRate1,
    this.insuranceRate2,
    this.insuranceRate3,
    this.discount1,
    this.discount2,
    this.discount3,
    this.buyBack1,
    this.buyBack2,
    this.buyBack3,
    this.minimumPayable,
    this.totalUnderApp,
    this.balanceApp,
    this.cleared,
    this.void_,
    this.motorFleet,
    this.marineOpen,
    this.gPAFleet,
    this.enteredDate,

    // Others
    this.policyUnderwriterID,
    this.packagePololicyID,
    this.endorsementID,
    this.brokerID,
    this.basicPremium,
    this.masterPolicyDocumentName,
    this.contractTypeID,
    this.incomeTypeID,
    this.premiumTypeID,
    this.paymentModeID,
    this.lockedBy,
    this.lockTS,
    this.noOfEmployee,
    this.basic,
    this.burglaryExtension,
    this.cashInPersonalCustody,
    this.cashInSafePremises,
    this.cashInTransit,
    this.electricalMechanicalBDLoading,
    this.excessBuyBack,
    this.flood,
    this.flueGas,
    this.iARLoading,
    this.localMedicalExpenses,
    this.multiplierI,
    this.multiplierII,
    this.nonOccupationalRisksLoading,
    this.rOthersI,
    this.rOthersII,
    this.rOthersIII,
    this.overseasMedicalExpenses,
    this.perils,
    this.sRCCommotion,
    this.tarrif,
    this.thirdPartyPD,
    this.deductible,
    this.fEA,
    this.fleet,
    this.groupD,
    this.lTA,
    this.nCD,
    this.dOthersI,
    this.dOthersII,
    this.dOthersIII,
    this.dOthersIV,
    this.packageD,
    this.silentRisk,
    this.specialD,
    this.stockDeclarationD,
    this.brokingSlipID,
    this.brokingSlipUsed,
    this.policyPageNumbering,
    this.policyExpiryDate,
    this.vendorName,
    this.insuranceCategoryID,
    this.undiscountedSumInsured,
    this.currencyID,
    this.currencyExchangeRate,
    this.sourcecode,
    // all lower case from backend
    this.branchcode,
    this.approvedDate,
    this.legalCession,
    this.reInsurance,
    this.leadCoBrokerID,
    this.coBroker,
    // All lower
    this.requestInsuranceCertificate,
    this.insuranceCertificateRequestDate,
    this.insuranceCertificateSent,
    this.paid,
    this.policyDivisionID,
    this.policyLocationID,
    this.policyDepartmentID,
    this.unitID,
    this.insuranceRate4,
    this.insuranceRate5,
    this.insuranceRate6,
    this.insuranceRate7,
    this.insuranceRate8,
    this.insuranceRate9,
    this.insuranceRate10,
    this.discount4,
    this.discount5,
    this.discount6,
    this.discount7,
    this.discount8,
    this.discount9,
    this.discount10,
    this.buyBack4,
    this.buyBack5,
    this.buyBack6,
    this.buyBack7,
    this.buyBack8,
    this.buyBack9,
    this.buyBack10,
    this.calBrokerageOnLegalCession,
    this.reInsuranceTreatyDetails,
    this.reInsuranceLossAdvice,
    this.reInsuranceRetention,
    this.reInsuranceProfitCommission,
    this.reInsuranceCondition,
    this.reInsuranceWordings,
    this.reInsuranceBordereauxAccounts,
    this.reInsuranceCoverInformation,
    this.reInsuranceSecurity,
    this.reInsuranceReInstatement,
    this.reInsuranceGeneralConditions,
    this.reInsuranceClaimsNotification,
    this.reInsuranceOutstandingLoses,
    this.reInsuranceCover,
    this.reInsuranceTerritorialScope,
    this.reInsuranceTreatyLimits,
    this.reInsuranceEventLimits,
    this.reInsuranceRate,
    this.reInsuranceProvisionalCommission,
    this.reInsurancePremiumLossReservePort,
    this.reInsuranceTreatyLimitsDeductible,
    this.reInsuranceMinimumDepositPremium,
    this.reInsuranceSettlement,
    this.reInsuranceCashLossLimit,
    this.reInsuranceCashAdvice,
    this.reInsuranceReferrals,
    this.reInsuranceVesselAgeClause,
    this.reInsuranceExclusions,
    this.reInsuranceAnnualAggLimit,
    this.reInsuranceWarranties,
    this.reInsuranceEstimatedPremiumIncome,
    this.reInsuranceGrossNetPremiumIncome,
    this.attachItemToInsure,
  });

  late String? actualPolicyBrokerID;
  late String? customerID;
  late String? vendorID;
  late String? projectTypeID;
  late String? projectID;
  late String? businessClassID;
  late String? riskTypeID;
  late String? policyDescription;
  late dynamic policyCoInsured;
  late dynamic policyCoBroked;
  late double? sumInsured;
  late double? premiumAmount;
  late dynamic commissionable;
  late double? brokerCommission;
  late String? policyStartDate;
  late String? policyEndDate;
  late String? renewalDate;
  late String? employeeID;
  late String? insurancePremiumMethodsID;
  late String? enterDate;
  late String? customerName;
  late dynamic inActive;
  late String? branchCode;
  late dynamic approved;
  late String? approvedBy;
  late List<ItemToInsure>? itemsToInsure;
  late List<InsurancePolicyUnderwriter>? insurancePolicyUnderwriters;
  late String? enteredBy;
  late double? insuranceRate1;
  late double? insuranceRate2;
  late double? insuranceRate3;
  late double? discount1;
  late double? discount2;
  late double? discount3;
  late double? buyBack1;
  late double? buyBack2;
  late double? buyBack3;
  late double? minimumPayable;
  late double? totalUnderApp;
  late double? balanceApp;
  late bool? cleared;
  late dynamic void_;
  late bool? motorFleet;
  late bool? marineOpen;
  late bool? gPAFleet;
  late dynamic enteredDate;

  // Others
  late dynamic policyUnderwriterID;
  late dynamic packagePololicyID;
  late dynamic endorsementID;
  late dynamic brokerID;
  late dynamic basicPremium;
  late dynamic masterPolicyDocumentName;
  late dynamic contractTypeID;
  late dynamic incomeTypeID;
  late dynamic premiumTypeID;
  late dynamic paymentModeID;
  late dynamic lockedBy;
  late dynamic lockTS;
  late dynamic noOfEmployee;
  late dynamic basic;
  late dynamic burglaryExtension;
  late dynamic cashInPersonalCustody;
  late dynamic cashInSafePremises;
  late dynamic cashInTransit;
  late dynamic electricalMechanicalBDLoading;
  late dynamic excessBuyBack;
  late dynamic flood;
  late dynamic flueGas;
  late dynamic iARLoading;
  late dynamic localMedicalExpenses;
  late dynamic multiplierI;
  late dynamic multiplierII;
  late dynamic nonOccupationalRisksLoading;
  late dynamic rOthersI;
  late dynamic rOthersII;
  late dynamic rOthersIII;
  late dynamic overseasMedicalExpenses;
  late dynamic perils;
  late dynamic sRCCommotion;
  late dynamic tarrif;
  late dynamic thirdPartyPD;
  late dynamic deductible;
  late dynamic fEA;
  late dynamic fleet;
  late dynamic groupD;
  late dynamic lTA;
  late dynamic nCD;
  late dynamic dOthersI;
  late dynamic dOthersII;
  late dynamic dOthersIII;
  late dynamic dOthersIV;
  late dynamic packageD;
  late dynamic silentRisk;
  late dynamic specialD;
  late dynamic stockDeclarationD;
  late dynamic brokingSlipID;
  late dynamic brokingSlipUsed;
  late dynamic policyPageNumbering;
  late dynamic policyExpiryDate;
  late dynamic vendorName;
  late dynamic insuranceCategoryID;
  late dynamic undiscountedSumInsured;
  late dynamic currencyID;
  late dynamic currencyExchangeRate;
  late dynamic sourcecode;
  // all lower case from backend
  late dynamic branchcode;
  late dynamic approvedDate;
  late dynamic legalCession;
  late dynamic reInsurance;
  late dynamic leadCoBrokerID;
  late dynamic coBroker;
  // All lower
  late dynamic requestInsuranceCertificate;
  late dynamic insuranceCertificateRequestDate;
  late dynamic insuranceCertificateSent;
  late dynamic paid;
  late dynamic policyDivisionID;
  late dynamic policyLocationID;
  late dynamic policyDepartmentID;
  late dynamic unitID;
  late dynamic insuranceRate4;
  late dynamic insuranceRate5;
  late dynamic insuranceRate6;
  late dynamic insuranceRate7;
  late dynamic insuranceRate8;
  late dynamic insuranceRate9;
  late dynamic insuranceRate10;
  late dynamic discount4;
  late dynamic discount5;
  late dynamic discount6;
  late dynamic discount7;
  late dynamic discount8;
  late dynamic discount9;
  late dynamic discount10;
  late dynamic buyBack4;
  late dynamic buyBack5;
  late dynamic buyBack6;
  late dynamic buyBack7;
  late dynamic buyBack8;
  late dynamic buyBack9;
  late dynamic buyBack10;
  late dynamic calBrokerageOnLegalCession;
  late dynamic reInsuranceTreatyDetails;
  late dynamic reInsuranceLossAdvice;
  late dynamic reInsuranceRetention;
  late dynamic reInsuranceProfitCommission;
  late dynamic reInsuranceCondition;
  late dynamic reInsuranceWordings;
  late dynamic reInsuranceBordereauxAccounts;
  late dynamic reInsuranceCoverInformation;
  late dynamic reInsuranceSecurity;
  late dynamic reInsuranceReInstatement;
  late dynamic reInsuranceGeneralConditions;
  late dynamic reInsuranceClaimsNotification;
  late dynamic reInsuranceOutstandingLoses;
  late dynamic reInsuranceCover;
  late dynamic reInsuranceTerritorialScope;
  late dynamic reInsuranceTreatyLimits;
  late dynamic reInsuranceEventLimits;
  late dynamic reInsuranceRate;
  late dynamic reInsuranceProvisionalCommission;
  late dynamic reInsurancePremiumLossReservePort;
  late dynamic reInsuranceTreatyLimitsDeductible;
  late dynamic reInsuranceMinimumDepositPremium;
  late dynamic reInsuranceSettlement;
  late dynamic reInsuranceCashLossLimit;
  late dynamic reInsuranceCashAdvice;
  late dynamic reInsuranceReferrals;
  late dynamic reInsuranceVesselAgeClause;
  late dynamic reInsuranceExclusions;
  late dynamic reInsuranceAnnualAggLimit;
  late dynamic reInsuranceWarranties;
  late dynamic reInsuranceEstimatedPremiumIncome;
  late dynamic reInsuranceGrossNetPremiumIncome;
  late dynamic attachItemToInsure;

  factory PolicyData.fromJson(dynamic json) {
    return PolicyData(
      policyBrokerID: json['PolicyBrokerID'],
      customerID: json['CustomerID'],
      vendorID: json['VendorID'],
      businessClassID: json['BusinessClassID'],
      riskTypeID: json['RiskTypeID'],
      policyDescription: json['PolicyDescription'],
      policyCoInsured: json['PolicyCoInsured'],
      policyCoBroked: json['PolicyCoBroked'],
      commissionable: json['Commissionable'],
      policyStartDate: json['PolicyStartDate'],
      policyEndDate: json['PolicyEndDate'],
      renewalDate: json['RenewalDate'],
      employeeID: json['EmployeeID'],
      enterDate: json['EnterDate'],
      customerName: json['CustomerName'],
      insurancePremiumMethodsID: json['InsurancePremiumMethodsID'],
      approved: json['Approved'] ?? false,
      approvedBy: json['ApprovedBy'],
      itemsToInsure: json['ItemToInsure'] != null && json['ItemToInsure'] != []
          ? List.from(json['ItemToInsure'])
              .map((item) => ItemToInsure.fromJson(item))
              .toList()
          : [],
      insurancePolicyUnderwriters: json['InsurancePolicyUnderwriter'] != null &&
              json['InsurancePolicyUnderwriter'] != []
          ? List.from(json['InsurancePolicyUnderwriter'])
              .map((item) => InsurancePolicyUnderwriter.fromJson(item))
              .toList()
          : [],
      enteredBy: json['EnteredBy'],
      insuranceRate1: json['InsuranceRate1'],
      insuranceRate2: json['InsuranceRate2'],
      insuranceRate3: json['InsuranceRate3'],
      discount1: json['Discount1'],
      discount2: json['Discount2'],
      discount3: json['Discount3'],
      buyBack1: json['BuyBack1'],
      buyBack2: json['BuyBack2'],
      buyBack3: json['BuyBack3'],
      minimumPayable: json['MinimumPayable'],
      totalUnderApp: json['TotalUnderApp'],
      balanceApp: json['BalanceApp'],
      cleared: json['Cleared'] ?? false,
      void_: json['Void'] ?? false,
      motorFleet: json['MotorFleet'] ?? false,
      marineOpen: json['MarineOpen'] ?? false,
      gPAFleet: json['GPAFleet'] ?? false,
      enteredDate: json['EnteredDate'],

      // Non required fields
      companyID: json['CompanyID'],
      divisionID: json['DivisionID'],
      departmentID: json['DepartmentID'],
      actualPolicyBrokerID: json['ActualPolicyBrokerID'],
      projectTypeID: json['ProjectTypeID'],
      projectID: json['ProjectID'],
      sumInsured: json['SumInsured'] ?? 0,
      premiumAmount: json['PremiumAmount'] ?? 0,
      brokerCommission: json['BrokerCommission'],
      inActive: json['InActive'],
      branchCode: json['branchcode'],
      policyUnderwriterID: json['PolicyUnderwriterID'],
      packagePololicyID: json['PackagePololicyID'],
      endorsementID: json['EndorsementID'],
      brokerID: json['BrokerID'],
      basicPremium: json['BasicPremium'],
      masterPolicyDocumentName: json['MasterPolicyDocumentName'],
      contractTypeID: json['ContractTypeID'],
      incomeTypeID: json['IncomeTypeID'],
      premiumTypeID: json['PremiumTypeID'],
      paymentModeID: json['PaymentModeID'],
      lockedBy: json['LockedBy'],
      lockTS: json['LockTS'],
      noOfEmployee: json['NoOfEmployee'],
      basic: json['Basic'],
      burglaryExtension: json['BurglaryExtension'],
      cashInPersonalCustody: json['CashInPersonalCustody'],
      cashInSafePremises: json['CashInSafePremises'],
      cashInTransit: json['CashInTransit'],
      electricalMechanicalBDLoading: json['ElectricalMechanicalBDLoading'],
      excessBuyBack: json['ExcessBuyBack'],
      flood: json['Flood'],
      flueGas: json['FlueGas'],
      iARLoading: json['IARLoading'],
      localMedicalExpenses: json['LocalMedicalExpenses'],
      multiplierI: json['MultiplierI'],
      multiplierII: json['MultiplierII'],
      nonOccupationalRisksLoading: json['nonOccupationalRisksLoading'],
      rOthersI: json['ROthersI'],
      rOthersII: json['ROthersII'],
      rOthersIII: json['ROthersIII'],
      overseasMedicalExpenses: json['OverseasMedicalExpenses'],
      perils: json['Perils'],
      sRCCommotion: json['SRCCommotion'],
      tarrif: json['Tarrif'],
      thirdPartyPD: json['ThirdPartyPD'],
      deductible: json['Deductible'],
      fEA: json['FEA'],
      fleet: json['Fleet'],
      groupD: json['GroupD'],
      lTA: json['LTA'],
      nCD: json['NCD'],
      dOthersI: json['DOthersI'],
      dOthersII: json['DOthersII'],
      dOthersIII: json['DOthersIII'],
      dOthersIV: json['DOthersIV'],
      packageD: json['PackageD'],
      silentRisk: json['SilentRisk'],
      specialD: json['SpecialD'],
      stockDeclarationD: json['StockDeclarationD'],
      brokingSlipID: json['BrokingSlipID'],
      brokingSlipUsed: json['BrokingSlipUsed'],
      policyPageNumbering: json['PolicyPageNumbering'],
      policyExpiryDate: json['PolicyExpiryDate'],
      vendorName: json['VendorName'],
      insuranceCategoryID: json['InsuranceCategoryID'],
      undiscountedSumInsured: json['UndiscountedSumInsured'],
      currencyID: json['CurrencyID'],
      currencyExchangeRate: json['CurrencyExchangeRate'],
      sourcecode: json['Sourcecode'],
      branchcode: json['branchcode'],
      approvedDate: json['ApprovedDate'],
      legalCession: json['LegalCession'],
      reInsurance: json['ReInsurance'],
      leadCoBrokerID: json['LeadCoBrokerID'],
      coBroker: json['CoBroker'],
      requestInsuranceCertificate: json['requestInsuranceCertificate'],
      insuranceCertificateRequestDate: json['InsuranceCertificateRequestDate'],
      insuranceCertificateSent: json['InsuranceCertificateSent'],
      paid: json['Paid'],
      policyDivisionID: json['PolicyDivisionID'],
      policyLocationID: json['PolicyLocationID'],
      policyDepartmentID: json['PolicyDepartmentID'],
      unitID: json['UnitID'],
      insuranceRate4: json['InsuranceRate4'],
      insuranceRate5: json['InsuranceRate5'],
      insuranceRate6: json['InsuranceRate6'],
      insuranceRate7: json['InsuranceRate7'],
      insuranceRate8: json['InsuranceRate8'],
      insuranceRate9: json['InsuranceRate9'],
      insuranceRate10: json['InsuranceRate10'],
      discount4: json['Discount4'],
      discount5: json['Discount5'],
      discount6: json['Discount6'],
      discount7: json['Discount7'],
      discount8: json['Discount8'],
      discount9: json['Discount9'],
      discount10: json['Discount10'],
      buyBack4: json['BuyBack4'],
      buyBack5: json['BuyBack5'],
      buyBack6: json['BuyBack6'],
      buyBack7: json['BuyBack7'],
      buyBack8: json['BuyBack8'],
      buyBack9: json['BuyBack9'],
      buyBack10: json['BuyBack10'],
      calBrokerageOnLegalCession: json['CalBrokerageOnLegalCession'],
      reInsuranceTreatyDetails: json['ReInsuranceTreatyDetails'],
      reInsuranceLossAdvice: json['ReInsuranceLossAdvice'],
      reInsuranceRetention: json['ReInsuranceRetention'],
      reInsuranceProfitCommission: json['ReInsuranceProfitCommission'],
      reInsuranceCondition: json['ReInsuranceCondition'],
      reInsuranceWordings: json['ReInsuranceWordings'],
      reInsuranceBordereauxAccounts: json['ReInsuranceBordereauxAccounts'],
      reInsuranceCoverInformation: json['ReInsuranceCoverInformation'],
      reInsuranceSecurity: json['ReInsuranceSecurity'],
      reInsuranceReInstatement: json['ReInsuranceReInstatement'],
      reInsuranceGeneralConditions: json['ReInsuranceGeneralConditions'],
      reInsuranceClaimsNotification: json['ReInsuranceClaimsNotification'],
      reInsuranceOutstandingLoses: json['ReInsuranceOutstandingLoses'],
      reInsuranceCover: json['ReInsuranceCover'],
      reInsuranceTerritorialScope: json['ReInsuranceTerritorialScope'],
      reInsuranceTreatyLimits: json['ReInsuranceTreatyLimits'],
      reInsuranceEventLimits: json['ReInsuranceEventLimits'],
      reInsuranceRate: json['ReInsuranceRate'],
      reInsuranceProvisionalCommission:
          json['ReInsuranceProvisionalCommission'],
      reInsurancePremiumLossReservePort:
          json['ReInsurancePremiumLossReservePort'],
      reInsuranceTreatyLimitsDeductible:
          json['ReInsuranceTreatyLimitsDeductible'],
      reInsuranceMinimumDepositPremium:
          json['ReInsuranceMinimumDepositPremium'],
      reInsuranceSettlement: json['ReInsuranceSettlement'],
      reInsuranceCashLossLimit: json['ReInsuranceCashLossLimit'],
      reInsuranceCashAdvice: json['ReInsuranceCashAdvice'],
      reInsuranceReferrals: json['ReInsuranceReferrals'],
      reInsuranceVesselAgeClause: json['ReInsuranceVesselAgeClause'],
      reInsuranceExclusions: json['ReInsuranceExclusions'],
      reInsuranceAnnualAggLimit: json['ReInsuranceAnnualAggLimit'],
      reInsuranceWarranties: json['ReInsuranceWarranties'],
      reInsuranceEstimatedPremiumIncome:
          json['ReInsuranceEstimatedPremiumIncome'],
      reInsuranceGrossNetPremiumIncome:
          json['ReInsuranceGrossNetPremiumIncome'],
      attachItemToInsure: json['AttachItemToInsure'],
    );
  }

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['PolicyBrokerID'] = policyBrokerID;
    map['CustomerID'] = customerID;
    map['VendorID'] = vendorID;
    map['BusinessClassID'] = businessClassID;
    map['RiskTypeID'] = riskTypeID;
    map['PolicyDescription'] = policyDescription;
    map['PolicyCoInsured'] = policyCoInsured;
    map['PolicyCoBroked'] = policyCoBroked;
    map['Commissionable'] = commissionable;
    map['PolicyStartDate'] = policyStartDate;
    map['PolicyEndDate'] = policyEndDate;
    map['RenewalDate'] = renewalDate;
    map['EmployeeID'] = employeeID;
    map['EnterDate'] = enterDate;
    map['CustomerName'] = customerName;
    map['InsurancePremiumMethodsID'] = insurancePremiumMethodsID;
    map['Approved'] = approved;
    map['ApprovedBy'] = approvedBy;
    map['ItemToInsure'] = itemsToInsure != null && itemsToInsure!.isNotEmpty
        ? itemsToInsure?.map((v) => v.toJson()).toList()
        : [];
    map['InsurancePolicyUnderwriter'] = insurancePolicyUnderwriters != null &&
            insurancePolicyUnderwriters!.isNotEmpty
        ? insurancePolicyUnderwriters?.map((v) => v.toJson()).toList()
        : [];
    map['EnteredBy'] = enteredBy;
    map['InsuranceRate1'] = insuranceRate1;
    map['InsuranceRate2'] = insuranceRate2;
    map['InsuranceRate3'] = insuranceRate3;
    map['Discount1'] = discount1;
    map['Discount2'] = discount2;
    map['Discount3'] = discount3;
    map['BuyBack1'] = buyBack1;
    map['BuyBack2'] = buyBack2;
    map['BuyBack3'] = buyBack3;
    map['MinimumPayable'] = minimumPayable;
    map['TotalUnderApp'] = totalUnderApp;
    map['BalanceApp'] = balanceApp;
    map['Cleared'] = cleared;
    map['Void'] = void_;
    map['MotorFleet'] = motorFleet;
    map['MarineOpen'] = marineOpen;
    map['GPAFleet'] = gPAFleet;
    map['EnteredDate'] = enteredDate;

    map['PolicyUnderwriterID'] = policyUnderwriterID;
    map['PackagePololicyID'] = packagePololicyID;
    map['EndorsementID'] = endorsementID;
    map['BrokerID'] = brokerID;
    map['BasicPremium'] = basicPremium;
    map['MasterPolicyDocumentName'] = masterPolicyDocumentName;
    map['ContractTypeID'] = contractTypeID;
    map['IncomeTypeID'] = incomeTypeID;
    map['PremiumTypeID'] = premiumTypeID;
    map['PaymentModeID'] = paymentModeID;
    map['LockedBy'] = lockedBy;
    map['LockTS'] = lockTS;
    map['NoOfEmployee'] = noOfEmployee;
    map['Basic'] = basic;
    map['BurglaryExtension'] = burglaryExtension;
    map['CashInPersonalCustody'] = cashInPersonalCustody;
    map['CashInSafePremises'] = cashInSafePremises;
    map['CashInTransit'] = cashInTransit;
    map['ElectricalMechanicalBDLoading'] = electricalMechanicalBDLoading;
    map['ExcessBuyBack'] = excessBuyBack;
    map['Flood'] = flood;
    map['FlueGas'] = flueGas;
    map['IARLoading'] = iARLoading;
    map['LocalMedicalExpenses'] = localMedicalExpenses;
    map['MultiplierI'] = multiplierI;
    map['MultiplierII'] = multiplierII;
    map['NonOccupationalRisksLoading'] = nonOccupationalRisksLoading;
    map['ROthersI'] = rOthersI;
    map['ROthersII'] = rOthersII;
    map['ROthersIII'] = rOthersIII;
    map['OverseasMedicalExpenses'] = overseasMedicalExpenses;
    map['Perils'] = perils;
    map['SRCCommotion'] = sRCCommotion;
    map['Tarrif'] = tarrif;
    map['ThirdPartyPD'] = thirdPartyPD;
    map['Deductible'] = deductible;
    map['FEA'] = fEA;
    map['Fleet'] = fleet;
    map['GroupD'] = groupD;
    map['LTA'] = lTA;
    map['NCD'] = nCD;
    map['DOthersI'] = dOthersI;
    map['DOthersII'] = dOthersII;
    map['DOthersIII'] = dOthersIII;
    map['DOthersIV'] = dOthersIV;
    map['PackageD'] = packageD;
    map['SilentRisk'] = silentRisk;
    map['SpecialD'] = specialD;
    map['StockDeclarationD'] = stockDeclarationD;
    map['BrokingSlipID'] = brokingSlipID;
    map['BrokingSlipUsed'] = brokingSlipUsed;
    map['PolicyPageNumbering'] = policyPageNumbering;
    map['PolicyExpiryDate'] = policyExpiryDate;
    map['VendorName'] = vendorName;
    map['InsuranceCategoryID'] = insuranceCategoryID;
    map['UndiscountedSumInsured'] = undiscountedSumInsured;
    map['CurrencyID'] = currencyID;
    map['CurrencyExchangeRate'] = currencyExchangeRate;
    map['Sourcecode'] = sourcecode;
    map['branchcode'] = branchcode;
    map['ApprovedDate'] = approvedDate;
    map['LegalCession'] = legalCession;
    map['ReInsurance'] = reInsurance;
    map['LeadCoBrokerID'] = leadCoBrokerID;
    map['CoBroker'] = coBroker;
    map['requestInsuranceCertificate'] = requestInsuranceCertificate;
    map['InsuranceCertificateRequestDate'] = insuranceCertificateRequestDate;
    map['InsuranceCertificateSent'] = insuranceCertificateSent;
    map['Paid'] = paid;
    map['PolicyDivisionID'] = policyDivisionID;
    map['PolicyLocationID'] = policyLocationID;
    map['PolicyDepartmentID'] = policyDepartmentID;
    map['UnitID'] = unitID;
    map['InsuranceRate4'] = insuranceRate4;
    map['InsuranceRate5'] = insuranceRate5;
    map['InsuranceRate6'] = insuranceRate6;
    map['InsuranceRate7'] = insuranceRate7;
    map['InsuranceRate8'] = insuranceRate8;
    map['InsuranceRate9'] = insuranceRate9;
    map['InsuranceRate10'] = insuranceRate10;
    map['Discount4'] = discount4;
    map['Discount5'] = discount5;
    map['Discount6'] = discount6;
    map['Discount7'] = discount7;
    map['Discount8'] = discount8;
    map['Discount9'] = discount9;
    map['Discount10'] = discount10;
    map['BuyBack4'] = buyBack4;
    map['BuyBack5'] = buyBack5;
    map['BuyBack6'] = buyBack6;
    map['BuyBack7'] = buyBack7;
    map['BuyBack8'] = buyBack8;
    map['BuyBack9'] = buyBack9;
    map['BuyBack10'] = buyBack10;
    map['CalBrokerageOnLegalCession'] = calBrokerageOnLegalCession;
    map['ReInsuranceTreatyDetails'] = reInsuranceTreatyDetails;
    map['ReInsuranceLossAdvice'] = reInsuranceLossAdvice;
    map['ReInsuranceRetention'] = reInsuranceRetention;
    map['ReInsuranceProfitCommission'] = reInsuranceProfitCommission;
    map['ReInsuranceCondition'] = reInsuranceCondition;
    map['ReInsuranceWordings'] = reInsuranceWordings;
    map['ReInsuranceBordereauxAccounts'] = reInsuranceBordereauxAccounts;
    map['ReInsuranceCoverInformation'] = reInsuranceCoverInformation;
    map['ReInsuranceSecurity'] = reInsuranceSecurity;
    map['ReInsuranceReInstatement'] = reInsuranceReInstatement;
    map['ReInsuranceGeneralConditions'] = reInsuranceGeneralConditions;
    map['ReInsuranceClaimsNotification'] = reInsuranceClaimsNotification;
    map['ReInsuranceOutstandingLoses'] = reInsuranceOutstandingLoses;
    map['ReInsuranceCover'] = reInsuranceCover;
    map['ReInsuranceTerritorialScope'] = reInsuranceTerritorialScope;
    map['ReInsuranceTreatyLimits'] = reInsuranceTreatyLimits;
    map['ReInsuranceEventLimits'] = reInsuranceEventLimits;
    map['ReInsuranceRate'] = reInsuranceRate;
    map['ReInsuranceProvisionalCommission'] = reInsuranceProvisionalCommission;
    map['ReInsurancePremiumLossReservePort'] =
        reInsurancePremiumLossReservePort;
    map['ReInsuranceTreatyLimitsDeductible'] =
        reInsuranceTreatyLimitsDeductible;
    map['ReInsuranceMinimumDepositPremium'] = reInsuranceMinimumDepositPremium;
    map['ReInsuranceSettlement'] = reInsuranceSettlement;
    map['ReInsuranceCashLossLimit'] = reInsuranceCashLossLimit;
    map['ReInsuranceCashAdvice'] = reInsuranceCashAdvice;
    map['ReInsuranceReferrals'] = reInsuranceReferrals;
    map['ReInsuranceVesselAgeClause'] = reInsuranceVesselAgeClause;
    map['ReInsuranceExclusions'] = reInsuranceExclusions;
    map['ReInsuranceAnnualAggLimit'] = reInsuranceAnnualAggLimit;
    map['ReInsuranceWarranties'] = reInsuranceWarranties;
    map['ReInsuranceEstimatedPremiumIncome'] =
        reInsuranceEstimatedPremiumIncome;
    map['ReInsuranceGrossNetPremiumIncome'] = reInsuranceGrossNetPremiumIncome;
    map['AttachItemToInsure'] = attachItemToInsure;
    return map;
  }

  @override
  String companyID;

  @override
  String departmentID;

  @override
  String divisionID;

  @override
  String policyBrokerID;
}

class ItemToInsure implements PolicyDetails {
  ItemToInsure({
    required this.companyID,
    required this.departmentID,
    required this.divisionID,
    required this.policyBrokerID,
    this.manualNumbering,
    this.brokingSlipItemCount,
    this.itemsDescription,
    this.sumInsured,
    this.excessAmount,
    this.itemLocation,
    this.discount,
    this.policyItems,
    this.sectionTypeID,
    this.lockedBy,
    this.lockTS,
    this.branchCode,
    this.itemRate,
    this.detailMemo1,
    this.detailMemo2,
    this.detailMemo3,
    this.detailMemo4,
    this.detailMemo5,
    this.detailMemo6,
    this.detailMemo7,
    this.detailMemo8,
    this.detailMemo9,
    this.detailMemo10,
    this.detailMemo11,
    this.detailMemo12,
    this.insuranceRate,
    this.loadingRate,
    this.itemPremium,
    this.sumInsuredDiscounted,
    this.undiscountedSumInsured,
    this.businessClassID,
    this.riskTypeID,
    this.basic,
    this.burglaryExtension,
    this.cashInPersonalCustody,
    this.cashInSafePremises,
    this.cashInTransit,
    this.electricalMechanicalBDLoading,
    this.excessBuyBack,
    this.flood,
    this.flueGas,
    this.iARLoading,
    this.localMedicalExpenses,
    this.multiplierI,
    this.multiplierII,
    this.nonOccupationalRisksLoading,
    this.rOthersI,
    this.rOthersII,
    this.rOthersIII,
    this.overseasMedicalExpenses,
    this.perils,
    this.sRCCommotion,
    this.tarrif,
    this.thirdPartyPD,
    this.deductible,
    this.fEA,
    this.fleet,
    this.groupD,
    this.lTA,
    this.nCD,
    this.dOthersI,
    this.dOthersII,
    this.dOthersIII,
    this.dOthersIV,
    this.packageD,
    this.silentRisk,
    this.specialD,
    this.stockDeclarationD,
  });

  late String? manualNumbering;
  late int? brokingSlipItemCount;
  late String? itemsDescription;
  late double? sumInsured;
  late double? excessAmount;
  late String? itemLocation;
  late double? discount;
  late String? policyItems;

  // Others
  late dynamic sectionTypeID;
  late dynamic lockedBy;
  late dynamic lockTS;
  late dynamic branchCode;
  late dynamic itemRate;
  late dynamic detailMemo1;
  late dynamic detailMemo2;
  late dynamic detailMemo3;
  late dynamic detailMemo4;
  late dynamic detailMemo5;
  late dynamic detailMemo6;
  late dynamic detailMemo7;
  late dynamic detailMemo8;
  late dynamic detailMemo9;
  late dynamic detailMemo10;
  late dynamic detailMemo11;
  late dynamic detailMemo12;
  late dynamic insuranceRate;
  late dynamic loadingRate;
  late dynamic itemPremium;
  late dynamic sumInsuredDiscounted;
  late dynamic undiscountedSumInsured;
  late dynamic businessClassID;
  late dynamic riskTypeID;
  late dynamic basic;
  late dynamic burglaryExtension;
  late dynamic cashInPersonalCustody;
  late dynamic cashInSafePremises;
  late dynamic cashInTransit;
  late dynamic electricalMechanicalBDLoading;
  late dynamic excessBuyBack;
  late dynamic flood;
  late dynamic flueGas;
  late dynamic iARLoading;
  late dynamic localMedicalExpenses;
  late dynamic multiplierI;
  late dynamic multiplierII;
  late dynamic nonOccupationalRisksLoading;
  late dynamic rOthersI;
  late dynamic rOthersII;
  late dynamic rOthersIII;
  late dynamic overseasMedicalExpenses;
  late dynamic perils;
  late dynamic sRCCommotion;
  late dynamic tarrif;
  late dynamic thirdPartyPD;
  late dynamic deductible;
  late dynamic fEA;
  late dynamic fleet;
  late dynamic groupD;
  late dynamic lTA;
  late dynamic nCD;
  late dynamic dOthersI;
  late dynamic dOthersII;
  late dynamic dOthersIII;
  late dynamic dOthersIV;
  late dynamic packageD;
  late dynamic silentRisk;
  late dynamic specialD;
  late dynamic stockDeclarationD;

  factory ItemToInsure.fromJson(dynamic json) {
    return ItemToInsure(
      companyID: json['CompanyID'],
      divisionID: json['DivisionID'],
      departmentID: json['DepartmentID'],
      policyBrokerID: json['PolicyBrokerID'],
      manualNumbering: json['ManualNumbering'],
      brokingSlipItemCount: json['BrokingSlipItemCount'],
      itemsDescription: json['ItemsDescription'],
      sumInsured: json['SumInsured'],
      excessAmount: json['ExcessAmount'],
      itemLocation: json['ItemLocation'],
      discount: json['Discount'],
      policyItems: json['PolicyItems'],
      sectionTypeID: json['SectionTypeID'],
      lockedBy: json['LockedBy'],
      lockTS: json['LockTS'],
      branchCode: json['BranchCode'],
      itemRate: json['ItemRate'],
      detailMemo1: json['detailMemo1'],
      detailMemo2: json['DetailMemo2'],
      detailMemo3: json['DetailMemo3'],
      detailMemo4: json['DetailMemo4'],
      detailMemo5: json['DetailMemo5'],
      detailMemo6: json['DetailMemo6'],
      detailMemo7: json['DetailMemo7'],
      detailMemo8: json['DetailMemo8'],
      detailMemo9: json['DetailMemo9'],
      detailMemo10: json['DetailMemo10'],
      detailMemo11: json['DetailMemo11'],
      detailMemo12: json['DetailMemo12'],
      insuranceRate: json['InsuranceRate'],
      loadingRate: json['LoadingRate'],
      itemPremium: json['ItemPremium'],
      sumInsuredDiscounted: json['SumInsuredDiscounted'],
      undiscountedSumInsured: json['UndiscountedSumInsured'],
      businessClassID: json['BusinessClassID'],
      riskTypeID: json['RiskTypeID'],
      basic: json['Basic'],
      burglaryExtension: json['BurglaryExtension'],
      cashInPersonalCustody: json['CashInPersonalCustody'],
      cashInSafePremises: json['CashInSafePremises'],
      cashInTransit: json['CashInTransit'],
      electricalMechanicalBDLoading: json['ElectricalMechanicalBDLoading'],
      excessBuyBack: json['ExcessBuyBack'],
      flood: json['Flood'],
      flueGas: json['FlueGas'],
      iARLoading: json['IARLoading'],
      localMedicalExpenses: json['LocalMedicalExpenses'],
      multiplierI: json['MultiplierI'],
      multiplierII: json['MultiplierII'],
      nonOccupationalRisksLoading: json['NonOccupationalRisksLoading'],
      rOthersI: json['ROthersI'],
      rOthersII: json['ROthersII'],
      rOthersIII: json['ROthersIII'],
      overseasMedicalExpenses: json['OverseasMedicalExpenses'],
      perils: json['Perils'],
      sRCCommotion: json['SRCCommotion'],
      tarrif: json['Tarrif'],
      thirdPartyPD: json['ThirdPartyPD'],
      deductible: json['Deductible'],
      fEA: json['FEA'],
      fleet: json['Fleet'],
      groupD: json['GroupD'],
      lTA: json['LTA'],
      nCD: json['NCD'],
      dOthersI: json['DOthersI'],
      dOthersII: json['DOthersII'],
      dOthersIII: json['DOthersIII'],
      dOthersIV: json['DOthersIV'],
      packageD: json['PackageD'],
      silentRisk: json['SilentRisk'],
      specialD: json['SpecialD'],
      stockDeclarationD: json['StockDeclarationD'],
    );
  }

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['CompanyID'] = companyID;
    map['DivisionID'] = divisionID;
    map['DepartmentID'] = departmentID;
    map['PolicyBrokerID'] = policyBrokerID;
    map['ManualNumbering'] = manualNumbering;
    map['BrokingSlipItemCount'] = brokingSlipItemCount;
    map['ItemsDescription'] = itemsDescription;
    map['SumInsured'] = sumInsured;
    map['ExcessAmount'] = excessAmount;
    map['ItemLocation'] = itemLocation;
    map['Discount'] = discount;
    map['PolicyItems'] = policyItems;

    map['SectionTypeID'] = sectionTypeID;
    map['LockedBy'] = lockedBy;
    map['LockTS'] = lockTS;
    map['BranchCode'] = branchCode;
    map['ItemRate'] = itemRate;
    map['DetailMemo1'] = detailMemo1;
    map['DetailMemo2'] = detailMemo2;
    map['DetailMemo3'] = detailMemo3;
    map['DetailMemo4'] = detailMemo4;
    map['DetailMemo5'] = detailMemo5;
    map['DetailMemo6'] = detailMemo6;
    map['DetailMemo7'] = detailMemo7;
    map['DetailMemo8'] = detailMemo8;
    map['DetailMemo9'] = detailMemo9;
    map['DetailMemo10'] = detailMemo10;
    map['DetailMemo11'] = detailMemo11;
    map['DetailMemo12'] = detailMemo12;
    map['InsuranceRate'] = insuranceRate;
    map['LoadingRate'] = loadingRate;
    map['ItemPremium'] = itemPremium;
    map['SumInsuredDiscounted'] = sumInsuredDiscounted;
    map['UndiscountedSumInsured'] = undiscountedSumInsured;
    map['BusinessClassID'] = businessClassID;
    map['RiskTypeID'] = riskTypeID;
    map['Basic'] = basic;
    map['BurglaryExtension'] = burglaryExtension;
    map['CashInPersonalCustody'] = cashInPersonalCustody;
    map['CashInSafePremises'] = cashInSafePremises;
    map['CashInTransit'] = cashInTransit;
    map['ElectricalMechanicalBDLoading'] = electricalMechanicalBDLoading;
    map['ExcessBuyBack'] = excessBuyBack;
    map['Flood'] = flood;
    map['FlueGas'] = flueGas;
    map['IARLoading'] = iARLoading;
    map['LocalMedicalExpenses'] = localMedicalExpenses;
    map['MultiplierI'] = multiplierI;
    map['MultiplierII'] = multiplierII;
    map['NonOccupationalRisksLoading'] = nonOccupationalRisksLoading;
    map['ROthersI'] = rOthersI;
    map['ROthersII'] = rOthersII;
    map['ROthersIII'] = rOthersIII;
    map['OverseasMedicalExpenses'] = overseasMedicalExpenses;
    map['Perils'] = perils;
    map['SRCCommotion'] = sRCCommotion;
    map['Tarrif'] = tarrif;
    map['ThirdPartyPD'] = thirdPartyPD;
    map['Deductible'] = deductible;
    map['FEA'] = fEA;
    map['Fleet'] = fleet;
    map['GroupD'] = groupD;
    map['LTA'] = lTA;
    map['NCD'] = nCD;
    map['DOthersI'] = dOthersI;
    map['DOthersII'] = dOthersII;
    map['DOthersIII'] = dOthersIII;
    map['DOthersIV'] = dOthersIV;
    map['PackageD'] = packageD;
    map['SilentRisk'] = silentRisk;
    map['SpecialD'] = specialD;
    map['StockDeclarationD'] = stockDeclarationD;
    return map;
  }

  Map<String, dynamic> toBrokerJson() {
    String computedMessage =
        '$manualNumbering, Value: N$sumInsured, Location: $itemLocation, Description: $itemsDescription';
    final map = <String, dynamic>{};
    map['CaseID'] = policyBrokerID.toString();
    map['Subject'] = manualNumbering;
    map['Message'] = computedMessage;
    map['ScreenShotURL'] = policyItems ?? '';
    map['CaseIDDetail'] = 0;
    map['Value'] = sumInsured;
    return map;
  }

  @override
  String companyID;

  @override
  String departmentID;

  @override
  String divisionID;

  @override
  String policyBrokerID;
}

class InsurancePolicyUnderwriter implements PolicyDetails {
  InsurancePolicyUnderwriter({
    required this.companyID,
    required this.departmentID,
    required this.divisionID,
    required this.policyBrokerID,
    this.vendorID,
    this.vendorName,
    this.policyUnderwriterID,
    this.apportionment,
    this.underWriterApportion,
    this.estimateAmount,
    this.receiptAmount,
    this.balanceDue,
    this.dvAmount,
  });

  late String? vendorID;
  late String? vendorName;
  late String? policyUnderwriterID;
  late double? apportionment;
  late double? underWriterApportion;
  late double? estimateAmount;
  late double? receiptAmount;
  late double? balanceDue;
  late double? dvAmount;

  factory InsurancePolicyUnderwriter.fromJson(dynamic json) {
    return InsurancePolicyUnderwriter(
      companyID: json['CompanyID'],
      divisionID: json['DivisionID'],
      departmentID: json['DepartmentID'],
      policyBrokerID: json['PolicyBrokerID'],
      vendorID: json['VendorID'],
      vendorName: json['VendorName'],
      policyUnderwriterID: json['PolicyUnderwriterID'],
      apportionment: json['Apportionment'],
      underWriterApportion: json['UnderWriterApportion'],
      estimateAmount: json['EstimateAmount'],
      receiptAmount: json['ReceiptAmount'],
      balanceDue: json['BalanceDue'],
      dvAmount: json['DVamount'],
    );
  }

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['CompanyID'] = companyID;
    map['DivisionID'] = divisionID;
    map['DepartmentID'] = departmentID;
    map['PolicyBrokerID'] = policyBrokerID;
    map['VendorID'] = vendorID;
    map['VendorName'] = vendorName;
    map['PolicyUnderwriterID'] = policyUnderwriterID;
    map['Apportionment'] = apportionment;
    map['UnderWriterApportion'] = underWriterApportion;
    map['EstimateAmount'] = estimateAmount;
    map['ReceiptAmount'] = receiptAmount;
    map['BalanceDue'] = balanceDue;
    map['DVamount'] = dvAmount;
    return map;
  }

  @override
  String companyID;

  @override
  String departmentID;

  @override
  String divisionID;

  @override
  String policyBrokerID;
}
