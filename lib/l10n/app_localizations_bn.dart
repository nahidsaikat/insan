// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Bengali Bangla (`bn`).
class AppLocalizationsBn extends AppLocalizations {
  AppLocalizationsBn([String locale = 'bn']) : super(locale);

  @override
  String get appTitle => 'এগ্রোস্টক ম্যানেজার';

  @override
  String get dashboardTitle => 'ড্যাশবোর্ড';

  @override
  String get inventoryTitle => 'ইনভেন্টরি';

  @override
  String get transactionsTitle => 'লেনদেন';

  @override
  String get expensesInvestmentsTitle => 'খরচ ও বিনিয়োগ';

  @override
  String get seasonManagementTitle => 'সিজন ব্যবস্থাপনা';

  @override
  String get partyManagementTitle => 'পার্টি ব্যবস্থাপনা';

  @override
  String get inventoryLocationsTitle => 'ইনভেন্টরি স্থান';

  @override
  String get noLocationsFoundMessage =>
      'কোনো ইনভেন্টরি স্থান পাওয়া যায়নি। আপনার প্রথম স্থান যোগ করুন!';

  @override
  String get confirmDeleteLocation =>
      'আপনি কি নিশ্চিত যে আপনি এই ইনভেন্টরি স্থানটি মুছে ফেলতে চান?';

  @override
  String get settingsTitle => 'সেটিংস';

  @override
  String get aboutTitle => 'সম্পর্কে';

  @override
  String get activeSeasonLabel => 'বর্তমান সিজন:';

  @override
  String get noActiveSeasonMessage =>
      'কোনো সক্রিয় সিজন পাওয়া যায়নি। অনুগ্রহ করে একটি তৈরি করুন বা নির্বাচন করুন।';

  @override
  String get createSeasonButton => 'নতুন সিজন তৈরি করুন';

  @override
  String get selectSeasonButton => 'সিজন নির্বাচন করুন';

  @override
  String get addSeasonPrompt => 'নতুন সিজনের নাম লিখুন:';

  @override
  String get seasonNameHint => 'উদাহরণ: বোরো ২০২৫';

  @override
  String get saveButton => 'সংরক্ষণ করুন';

  @override
  String get cancelButton => 'বাতিল করুন';

  @override
  String get editButton => 'সম্পাদনা করুন';

  @override
  String get deleteButton => 'মুছুন';

  @override
  String get confirmDeleteSeason =>
      'আপনি কি নিশ্চিত যে আপনি এই সিজন এবং এর সাথে সম্পর্কিত সমস্ত ডেটা মুছে ফেলতে চান?';

  @override
  String get seasonStartHint => 'শুরুর তারিখ';

  @override
  String get seasonEndHint => 'শেষের তারিখ';

  @override
  String get seasonStatus => 'অবস্থা:';

  @override
  String get activeStatus => 'সক্রিয়';

  @override
  String get inactiveStatus => 'নিষ্ক্রিয়';

  @override
  String get partyNameHint => 'পার্টির নাম';

  @override
  String get partyTypeHint => 'পার্টির প্রকার';

  @override
  String get partyContactHint => 'ফোন নম্বর';

  @override
  String get partyAddressHint => 'ঠিকানা';

  @override
  String get addPartyButton => 'নতুন পার্টি যোগ করুন';

  @override
  String get partyFilterAll => 'সব';

  @override
  String get partyTypeInvestor => 'বিনিয়োগকারী';

  @override
  String get partyTypeFarmer => 'কৃষক';

  @override
  String get partyTypeCustomer => 'ক্রেতা';

  @override
  String get partyTypeOtherVendor => 'অন্যান্য বিক্রেতা';

  @override
  String get noPartiesFoundMessage =>
      'কোন পার্টি খুঁজে পাওয়া যায়নি। আপনার প্রথম যোগাযোগ যোগ করুন!';

  @override
  String get noFilteredPartiesFoundMessage => 'কোন পার্টি খুঁজে পাওয়া যায়নি।';

  @override
  String get productNameHint => 'পণ্যের নাম';

  @override
  String get productUnitHint => 'একক (যেমন, কেজি)';

  @override
  String get addProductButton => 'নতুন পণ্য যোগ করুন';

  @override
  String get locationNameHint => 'স্থানের নাম (যেমন, গুদাম ক)';

  @override
  String get locationAddressHint => 'ঠিকানা';

  @override
  String get locationRentCostHint => 'মাসিক ভাড়া খরচ';

  @override
  String get addLocationButton => 'নতুন স্থান যোগ করুন';

  @override
  String get totalSacksPurchased => 'মোট বস্তা ক্রয়:';

  @override
  String get totalSacksSold => 'মোট বস্তা বিক্রয়:';

  @override
  String get currentInStockValue => 'বর্তমান মজুদের মূল্য:';

  @override
  String get totalExpenses => 'মোট খরচ:';

  @override
  String get totalInvestments => 'মোট বিনিয়োগ:';

  @override
  String get recordPurchaseButton => 'ক্রয় রেকর্ড করুন';

  @override
  String get recordSaleButton => 'বিক্রয় রেকর্ড করুন';

  @override
  String get addExpenseButton => 'খরচ যোগ করুন';

  @override
  String get addInvestmentButton => 'বিনিয়োগ যোগ করুন';

  @override
  String get viewAllInventory => 'সমস্ত ইনভেন্টরি দেখুন';

  @override
  String get viewAllExpenses => 'সমস্ত খরচ দেখুন';

  @override
  String get viewAllInvestments => 'সমস্ত বিনিয়োগ দেখুন';

  @override
  String get noSacksFound => 'কোনো বস্তা পাওয়া যায়নি।';

  @override
  String get noExpensesFound => 'কোনো খরচ পাওয়া যায়নি।';

  @override
  String get noInvestmentsFound => 'কোনো বিনিয়োগ পাওয়া যায়নি।';

  @override
  String get purchaseDetails => 'ক্রয়ের বিবরণ';

  @override
  String get saleDetails => 'বিক্রয়ের বিবরণ';

  @override
  String get dateLabel => 'তারিখ:';

  @override
  String get productLabel => 'পণ্য:';

  @override
  String get vendorLabel => 'বিক্রেতা:';

  @override
  String get customerLabel => 'ক্রেতা:';

  @override
  String get weightLabel => 'ওজন (কেজি):';

  @override
  String get pricePerKgLabel => 'কেজি প্রতি মূল্য:';

  @override
  String get carryingCostLabel => 'বহন খরচ:';

  @override
  String get locationLabel => 'স্থান:';

  @override
  String get statusLabel => 'অবস্থা:';

  @override
  String get uniqueSackIdentifierLabel => 'বস্তা আইডি:';

  @override
  String get addNewSack => 'নতুন বস্তা যোগ করুন';

  @override
  String get updateSack => 'বস্তা আপডেট করুন';

  @override
  String get sackStatusInStock => 'মজুদ আছে';

  @override
  String get sackStatusSold => 'বিক্রি হয়েছে';

  @override
  String get sackStatusDiscarded => 'বাদ দেওয়া হয়েছে';

  @override
  String get expenseCategoryHint => 'বিভাগ';

  @override
  String get expenseDescriptionHint => 'বিবরণ';

  @override
  String get expenseAmountHint => 'পরিমাণ';

  @override
  String get expenseCategoryTransport => 'পরিবহন';

  @override
  String get expenseCategoryLabor => 'শ্রমিক';

  @override
  String get expenseCategoryRent => 'ভাড়া';

  @override
  String get expenseCategoryMaintenance => 'রক্ষণাবেক্ষণ';

  @override
  String get expenseCategoryOther => 'অন্যান্য';

  @override
  String get investorLabel => 'বিনিয়োগকারী:';

  @override
  String get investmentAmountHint => 'পরিমাণ';

  @override
  String get investmentNotesHint => 'নোট';

  @override
  String get profitDistributionLabel => 'লাভ বিতরণ';

  @override
  String get amountDistributedHint => 'বিতরণকৃত পরিমাণ';

  @override
  String get profitDistributionNotesHint => 'নোট';

  @override
  String get purchaseRequiredFieldsMessage =>
      'অনুগ্রহ করে ক্রয়ের জন্য প্রয়োজনীয় সকল ক্ষেত্র পূরণ করুন।';

  @override
  String get saleRequiredFieldsMessage =>
      'অনুগ্রহ করে একটি বস্তা নির্বাচন করুন এবং বিক্রয়ের জন্য প্রয়োজনীয় সকল ক্ষেত্র পূরণ করুন।';

  @override
  String get invalidNumberInputMessage =>
      'ওজন এবং মূল্যের জন্য বৈধ সংখ্যা লিখুন।';

  @override
  String get purchaseSuccessMessage => 'ক্রয় সফলভাবে রেকর্ড করা হয়েছে!';

  @override
  String get saleSuccessMessage => 'বিক্রয় সফলভাবে রেকর্ড করা হয়েছে!';

  @override
  String get errorRecordingPurchase => 'ক্রয় রেকর্ড করতে ত্রুটি:';

  @override
  String get errorRecordingSale => 'বিক্রয় রেকর্ড করতে ত্রুটি:';

  @override
  String get selectVendorPrompt => 'অনুগ্রহ করে একজন বিক্রেতা নির্বাচন করুন।';

  @override
  String get selectLocationPrompt => 'অনুগ্রহ করে একটি স্থান নির্বাচন করুন।';

  @override
  String get selectCustomerPrompt => 'অনুগ্রহ করে একটি ক্রেতা নির্বাচন করুন।';

  @override
  String get selectSackToSellPrompt =>
      'বিক্রয়ের জন্য একটি বস্তা নির্বাচন করুন।';

  @override
  String get recordExpense => 'খরচ রেকর্ড করুন';

  @override
  String get recordInvestment => 'বিনিয়োগ রেকর্ড করুন';

  @override
  String get amountLabel => 'পরিমাণ:';

  @override
  String get descriptionLabel => 'বিবরণ:';

  @override
  String get categoryLabel => 'শ্রেণী:';

  @override
  String get investmentDescriptionHint => 'যেমন: প্রাথমিক মূলধন, ঋণ';

  @override
  String get recentExpenses => 'সাম্প্রতিক খরচ';

  @override
  String get recentInvestments => 'সাম্প্রতিক বিনিয়োগ';

  @override
  String get confirmDeleteExpense =>
      'আপনি কি নিশ্চিত যে আপনি এই খরচটি মুছে ফেলতে চান?';

  @override
  String get confirmDeleteInvestment =>
      'আপনি কি নিশ্চিত যে আপনি এই বিনিয়োগটি মুছে ফেলতে চান?';

  @override
  String get expenseRequiredFieldsMessage =>
      'অনুগ্রহ করে খরচের জন্য প্রয়োজনীয় সকল ক্ষেত্র পূরণ করুন।';

  @override
  String get invalidExpenseAmount =>
      'অনুগ্রহ করে খরচের জন্য একটি বৈধ ধনাত্মক পরিমাণ লিখুন।';

  @override
  String get investmentRequiredFieldsMessage =>
      'অনুগ্রহ করে একজন বিনিয়োগকারী নির্বাচন করুন এবং বিনিয়োগের জন্য প্রয়োজনীয় সকল ক্ষেত্র পূরণ করুন।';

  @override
  String get invalidInvestmentAmount =>
      'অনুগ্রহ করে বিনিয়োগের জন্য একটি বৈধ ধনাত্মক পরিমাণ লিখুন।';

  @override
  String get expenseSuccessMessage => 'খরচ সফলভাবে রেকর্ড করা হয়েছে!';

  @override
  String get investmentSuccessMessage => 'বিনিয়োগ সফলভাবে রেকর্ড করা হয়েছে!';

  @override
  String get errorRecordingExpense => 'খরচ রেকর্ড করতে ত্রুটি:';

  @override
  String get errorRecordingInvestment => 'বিনিয়োগ রেকর্ড করতে ত্রুটি:';

  @override
  String get selectInvestorPrompt =>
      'অনুগ্রহ করে একজন বিনিয়োগকারী নির্বাচন করুন।';

  @override
  String get profitDistributionTitle => 'লাভ বন্টন';

  @override
  String get seasonFinancialSummary => 'সিজনের আর্থিক সারাংশ';

  @override
  String get totalRevenue => 'মোট আয়:';

  @override
  String get totalPurchaseCost => 'মোট ক্রয় খরচ:';

  @override
  String get totalCarryingCost => 'মোট বহন খরচ:';

  @override
  String get netProfitLoss => 'নীট লাভ/ক্ষতি:';

  @override
  String get recordProfitDistribution => 'লাভ বন্টন রেকর্ড করুন';

  @override
  String get recipientLabel => 'গ্রহীতা:';

  @override
  String get distributionDescriptionHint =>
      'যেমন: বিনিয়োগকারী X এর জন্য অংশ, মালিকের উত্তোলন';

  @override
  String get recordDistribution => 'বন্টন রেকর্ড করুন';

  @override
  String get recentDistributions => 'সাম্প্রতিক বন্টন';

  @override
  String get noDistributionsFound =>
      'এই সিজনের জন্য কোনো লাভ বন্টন পাওয়া যায়নি।';

  @override
  String get confirmDeleteDistribution =>
      'আপনি কি নিশ্চিত যে আপনি এই লাভ বন্টনটি মুছে ফেলতে চান?';

  @override
  String get distributionRequiredFieldsMessage =>
      'অনুগ্রহ করে একজন গ্রহীতা নির্বাচন করুন এবং বন্টনের জন্য প্রয়োজনীয় সকল ক্ষেত্র পূরণ করুন।';

  @override
  String get invalidDistributionAmount =>
      'অনুগ্রহ করে বন্টনের জন্য একটি বৈধ ধনাত্মক পরিমাণ লিখুন।';

  @override
  String get distributionSuccessMessage =>
      'লাভ বন্টন সফলভাবে রেকর্ড করা হয়েছে!';

  @override
  String get errorRecordingDistribution => 'বন্টন রেকর্ড করতে ত্রুটি:';

  @override
  String get selectRecipientPrompt => 'অনুগ্রহ করে একজন প্রাপক নির্বাচন করুন।';

  @override
  String get totalDistributedAmount => 'মোট বন্টিত:';

  @override
  String get undistributedProfit => 'অবন্টিত লাভ:';

  @override
  String get distributionExceedsProfit =>
      'বন্টনের পরিমাণ অবন্টিত লাভের চেয়ে বেশি!';

  @override
  String get cannotDistributeNegativeProfit =>
      'নীট লাভ শূন্য বা ঋণাত্মক হলে লাভ বন্টন করা যাবে না।';

  @override
  String get sackDetailsTitle => 'বস্তার বিবরণ';

  @override
  String get generalInfo => 'সাধারণ তথ্য';

  @override
  String get currentLocation => 'বর্তমান অবস্থান:';

  @override
  String get totalPurchaseValue => 'মোট ক্রয় মূল্য:';

  @override
  String get totalSaleValue => 'মোট বিক্রয় মূল্য:';

  @override
  String get netGainLoss => 'নীট লাভ/ক্ষতি:';

  @override
  String get notAvailable => 'উপলভ্য নয়';

  @override
  String get unknown => 'অজানা';

  @override
  String get sackNotFound => 'বস্তা পাওয়া যায়নি!';

  @override
  String get sackUpdatedSuccessfully =>
      'বস্তার বিবরণ সফলভাবে আপডেট করা হয়েছে!';

  @override
  String get errorUpdatingSack => 'বস্তা আপডেট করতে ত্রুটি:';

  @override
  String get sackDeletedSuccessfully => 'বস্তা সফলভাবে মুছে ফেলা হয়েছে!';

  @override
  String get errorDeletingSack => 'বস্তা মুছে ফেলতে ত্রুটি:';

  @override
  String get confirmDeleteSack =>
      'আপনি কি নিশ্চিত যে আপনি এই বস্তাটি মুছে ফেলতে চান?';

  @override
  String get confirmDeleteSoldSack =>
      'এই বস্তাটি বিক্রি হয়ে গেছে। এটি মুছে ফেললে আপনার আর্থিক রেকর্ডে প্রভাব পড়বে। আপনি কি তবুও এটি মুছে ফেলতে চান?';

  @override
  String get deleteAnyway => 'যাইহোক মুছে ফেলুন';

  @override
  String get singleSaleTab => 'একক বস্তা বিক্রয়';

  @override
  String get bulkSaleTab => 'একসাথে বিক্রয়';

  @override
  String get sellingSack => 'বিক্রয় হচ্ছে বস্তা';

  @override
  String get selectSackForSale =>
      'এককভাবে বিক্রয় করার জন্য ইনভেন্টরি থেকে একটি বস্তা নির্বাচন করুন।';

  @override
  String get selectSackFromInventoryTip =>
      'একক বস্তা বিক্রি করতে, ইনভেন্টরি স্ক্রিনে যান এবং নির্দিষ্ট বস্তাটিতে ট্যাপ করে বিক্রি করুন।';

  @override
  String get saleDateLabel => 'বিক্রয়ের তারিখ:';

  @override
  String get saleWeightLabel => 'বিক্রয়ের ওজন:';

  @override
  String get salePricePerKgLabel => 'প্রতি কেজি বিক্রয় মূল্য:';

  @override
  String get saleCarryingCostLabel => 'বিক্রয় বহন খরচ:';

  @override
  String get customerRequired => 'অনুগ্রহ করে একজন ক্রেতা নির্বাচন করুন।';

  @override
  String get selectCustomer => 'ক্রেতা নির্বাচন করুন';

  @override
  String get recordSale => 'বিক্রয় রেকর্ড করুন';

  @override
  String get validAmountRequired =>
      'অনুগ্রহ করে বৈধ ধনাত্মক বিক্রয় ওজন এবং মূল্য লিখুন।';

  @override
  String get saleWeightExceedsPurchase =>
      'বিক্রয়ের ওজন ক্রয় ওজনের বেশি হতে পারে না।';

  @override
  String get saleRecordedSuccessfully => 'বিক্রয় সফলভাবে রেকর্ড করা হয়েছে!';

  @override
  String get selectSacksAndFillFields =>
      'অনুগ্রহ করে একসাথে বিক্রয়ের জন্য বস্তা নির্বাচন করুন এবং প্রয়োজনীয় সকল ক্ষেত্র পূরণ করুন।';

  @override
  String get validPriceRequired =>
      'অনুগ্রহ করে প্রতি কেজি একটি বৈধ ধনাত্মক বিক্রয় মূল্য লিখুন।';

  @override
  String get totalCarryingCostLabel => 'মোট বহন খরচ:';

  @override
  String get totalCarryingCostHint => 'যেমন: পুরো লটের পরিবহন খরচ';

  @override
  String get totalSelectedWeight => 'মোট নির্বাচিত ওজন:';

  @override
  String get calculatedSaleAmount => 'গণনাকৃত বিক্রয় পরিমাণ:';

  @override
  String get recordBulkSale => 'একসাথে বিক্রয় রেকর্ড করুন';

  @override
  String get noSacksInStock =>
      'এই সিজনের জন্য বর্তমানে কোনো বস্তা ইন-স্টক নেই।';

  @override
  String get bulkSaleRecordedSuccessfully =>
      'একসাথে বিক্রয় সফলভাবে রেকর্ড করা হয়েছে!';

  @override
  String get errorRecordingBulkSale => 'একসাথে বিক্রয় রেকর্ড করতে ত্রুটি:';

  @override
  String get purchaseDateLabel => 'ক্রয় তারিখ:';

  @override
  String get purchaseWeightLabel => 'ক্রয় ওজন:';

  @override
  String get purchasePricePerKgLabel => 'প্রতি কেজি ক্রয় মূল্য:';

  @override
  String get unknownLocation => 'অবস্থান জানা নেই';

  @override
  String get saleTitle => 'বিক্রয় লেনদেন';

  @override
  String get saleScreenTitle => 'বিক্রয় করুন';

  @override
  String get fillAllFields => 'সকল ঘর পূরণ করুন';

  @override
  String get reportsTitle => 'রিপোর্ট ও বিশ্লেষণ';

  @override
  String get noSeasonsFoundForReports =>
      'রিপোর্ট তৈরি করার জন্য কোনো সিজন পাওয়া যায়নি। অনুগ্রহ করে প্রথমে সিজন যোগ করুন।';

  @override
  String get season => 'সিজন';

  @override
  String get duration => 'সময়কাল';

  @override
  String get inventorySummary => 'ইনভেন্টরি সারাংশ';

  @override
  String get financialSummary => 'সারাংশ';

  @override
  String get sacksInStock => 'স্টকে থাকা বস্তা';

  @override
  String get totalWeightInStock => 'মোট ওজন (স্টকে)';

  @override
  String get sacksSold => 'বিক্রি হওয়া বস্তা';

  @override
  String get totalWeightSold => 'মোট ওজন (বিক্রি)';

  @override
  String get sacksDiscarded => 'বাদ দেওয়া বস্তা';

  @override
  String get totalStockValue => 'মোট স্টক মূল্য (স্টকে)';

  @override
  String get notApplicable => 'প্রযোজ্য নয়';

  @override
  String get currentInventoryValue => 'বর্তমান ইনভেন্টরি মূল্য:';

  @override
  String get profitTrendBySeason => 'সিজন অনুযায়ী লাভ/ক্ষতির প্রবণতা';

  @override
  String get inventoryStatusBreakdown => 'ইনভেন্টরি অবস্থার বিভাজন';

  @override
  String get inStockShort => 'স্টকে আছে';

  @override
  String get soldShort => 'বিক্রি হয়েছে';

  @override
  String get discardedShort => 'বাদ দেওয়া হয়েছে';

  @override
  String get activeSeason => 'সক্রিয় সিজন';

  @override
  String get manageSeasons => 'সিজন পরিচালনা করুন';

  @override
  String get noProfitDataAvailable =>
      'চার্টের জন্য কোনো লাভের ডেটা উপলব্ধ নেই।';

  @override
  String get noInventoryDataForCharts =>
      'চার্টের জন্য কোনো ইনভেন্টরি ডেটা উপলব্ধ নেই।';

  @override
  String get searchSacks => 'বস্তা খুঁজুন';

  @override
  String get searchSacksHint => 'কোড, প্রকার বা নোট লিখুন...';

  @override
  String get allProducts => 'সব প্রকার';

  @override
  String get allStatuses => 'সব অবস্থা';

  @override
  String get allLocations => 'সব অবস্থান';

  @override
  String get productType => 'পণ্যের প্রকার';

  @override
  String get status => 'অবস্থা';

  @override
  String get location => 'অবস্থান';

  @override
  String get resetFilters => 'ফিল্টার রিসেট করুন';

  @override
  String get code => 'কোড';

  @override
  String get weight => 'ওজন';

  @override
  String get date => 'তারিখ';

  @override
  String get searchParty => 'পার্টি খুঁজুন';

  @override
  String get searchPartyHint => 'নাম বা ফোন নম্বর লিখুন...';

  @override
  String get allTypes => 'সব প্রকার';

  @override
  String get partyType => 'পার্টির প্রকার';

  @override
  String get confirmDeleteParty =>
      'আপনি কি নিশ্চিত এই পার্টিটি মুছে ফেলতে চান?';

  @override
  String get partyTypeEmptyValidation =>
      'অনুগ্রহ করে একটি পার্টির প্রকার নির্বাচন করুন।';

  @override
  String get partyNameTypeEmptyValidation =>
      'পার্টির নাম এবং প্রকার খালি থাকতে পারে না।';

  @override
  String get darkMode => 'Dark Mode';

  @override
  String get currencySymbol => 'Currency Symbol';

  @override
  String get dateFormat => 'Date Format';

  @override
  String get overviewTitle => 'সারসংক্ষেপ';

  @override
  String get managementTitle => 'ব্যবস্থাপনা';

  @override
  String get reportingTitle => 'রিপোর্টিং';

  @override
  String get totalKgPurchased => 'মোট ক্রয়কৃত কেজি';

  @override
  String get totalKgSold => 'মোট বিক্রিত কেজি';

  @override
  String get sacksLabel => 'বস্তা';

  @override
  String get kgLabel => 'কেজি';

  @override
  String get totalSacksInLocation => 'মোট বস্তা';

  @override
  String get totalQuantityInLocation => 'মোট পরিমাণ';

  @override
  String get locationNameEmptyError => 'অবস্থানের নাম খালি রাখা যাবে না।';

  @override
  String get cannotDeleteLocationWithSacks =>
      'অবস্থানে বস্তা থাকাকালীন মুছে ফেলা যাবে না। প্রথমে বস্তা সরান।';

  @override
  String get currentActiveSeason => 'বর্তমান সক্রিয় সিজন';

  @override
  String get deactivateCurrentSeason => 'বর্তমান সিজন নিষ্ক্রিয় করুন';

  @override
  String get deactivateSeasonSubtitle =>
      'বর্তমানে সক্রিয় সিজনটিকে নিষ্ক্রিয় করুন। এটি আপনাকে সিজনের তালিকায় নিয়ে যাবে।';

  @override
  String get deactivateSeasonConfirmTitle => 'নিষ্ক্রিয়করণের নিশ্চিতকরণ';

  @override
  String get deactivateSeasonConfirmMessage =>
      'আপনি কি নিশ্চিত যে বর্তমান সিজনটিকে নিষ্ক্রিয় করতে চান? এই পদক্ষেপটি বর্তমান সেশনের জন্য পূর্বাবস্থায় ফেরানো যাবে না।';

  @override
  String get deactivateButton => 'নিষ্ক্রিয় করুন';

  @override
  String get seasonDeactivatedSuccess =>
      'বর্তমান সিজন সফলভাবে নিষ্ক্রিয় করা হয়েছে।';

  @override
  String get seasonActivatedSuccess =>
      'বর্তমান সিজন সফলভাবে সক্রিয় করা হয়েছে।';

  @override
  String get language => 'ভাষা';

  @override
  String get english => 'ইংরেজি';

  @override
  String get bengali => 'বাংলা';
}
