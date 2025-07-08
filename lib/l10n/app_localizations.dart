import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_bn.dart';
import 'app_localizations_en.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('bn'),
    Locale('en'),
  ];

  /// No description provided for @appTitle.
  ///
  /// In en, this message translates to:
  /// **'AgroStock Manager'**
  String get appTitle;

  /// No description provided for @dashboardTitle.
  ///
  /// In en, this message translates to:
  /// **'Dashboard'**
  String get dashboardTitle;

  /// No description provided for @inventoryTitle.
  ///
  /// In en, this message translates to:
  /// **'Inventory'**
  String get inventoryTitle;

  /// No description provided for @transactionsTitle.
  ///
  /// In en, this message translates to:
  /// **'Transactions'**
  String get transactionsTitle;

  /// No description provided for @expensesInvestmentsTitle.
  ///
  /// In en, this message translates to:
  /// **'Expenses & Investments'**
  String get expensesInvestmentsTitle;

  /// No description provided for @seasonManagementTitle.
  ///
  /// In en, this message translates to:
  /// **'Season Management'**
  String get seasonManagementTitle;

  /// No description provided for @partyManagementTitle.
  ///
  /// In en, this message translates to:
  /// **'Party Management'**
  String get partyManagementTitle;

  /// No description provided for @inventoryLocationsTitle.
  ///
  /// In en, this message translates to:
  /// **'Inventory Locations'**
  String get inventoryLocationsTitle;

  /// No description provided for @noLocationsFoundMessage.
  ///
  /// In en, this message translates to:
  /// **'No inventory locations found. Add your first location!'**
  String get noLocationsFoundMessage;

  /// No description provided for @confirmDeleteLocation.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to delete this inventory location?'**
  String get confirmDeleteLocation;

  /// No description provided for @settingsTitle.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settingsTitle;

  /// No description provided for @aboutTitle.
  ///
  /// In en, this message translates to:
  /// **'About'**
  String get aboutTitle;

  /// No description provided for @activeSeasonLabel.
  ///
  /// In en, this message translates to:
  /// **'Active Season:'**
  String get activeSeasonLabel;

  /// No description provided for @noActiveSeasonMessage.
  ///
  /// In en, this message translates to:
  /// **'No active season found. Please create or select one.'**
  String get noActiveSeasonMessage;

  /// No description provided for @createSeasonButton.
  ///
  /// In en, this message translates to:
  /// **'Create New Season'**
  String get createSeasonButton;

  /// No description provided for @selectSeasonButton.
  ///
  /// In en, this message translates to:
  /// **'Select Season'**
  String get selectSeasonButton;

  /// No description provided for @addSeasonPrompt.
  ///
  /// In en, this message translates to:
  /// **'Enter new season name:'**
  String get addSeasonPrompt;

  /// No description provided for @seasonNameHint.
  ///
  /// In en, this message translates to:
  /// **'e.g., Boro 2025'**
  String get seasonNameHint;

  /// No description provided for @saveButton.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get saveButton;

  /// No description provided for @cancelButton.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancelButton;

  /// No description provided for @editButton.
  ///
  /// In en, this message translates to:
  /// **'Edit'**
  String get editButton;

  /// No description provided for @deleteButton.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get deleteButton;

  /// No description provided for @confirmDeleteSeason.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to delete this season and all associated data?'**
  String get confirmDeleteSeason;

  /// No description provided for @seasonStartHint.
  ///
  /// In en, this message translates to:
  /// **'Start Date'**
  String get seasonStartHint;

  /// No description provided for @seasonEndHint.
  ///
  /// In en, this message translates to:
  /// **'End Date'**
  String get seasonEndHint;

  /// No description provided for @seasonStatus.
  ///
  /// In en, this message translates to:
  /// **'Status:'**
  String get seasonStatus;

  /// No description provided for @activeStatus.
  ///
  /// In en, this message translates to:
  /// **'Active'**
  String get activeStatus;

  /// No description provided for @inactiveStatus.
  ///
  /// In en, this message translates to:
  /// **'Inactive'**
  String get inactiveStatus;

  /// No description provided for @partyNameHint.
  ///
  /// In en, this message translates to:
  /// **'Party Name'**
  String get partyNameHint;

  /// No description provided for @partyTypeHint.
  ///
  /// In en, this message translates to:
  /// **'Party Type'**
  String get partyTypeHint;

  /// No description provided for @partyContactHint.
  ///
  /// In en, this message translates to:
  /// **'Phone Number'**
  String get partyContactHint;

  /// No description provided for @partyAddressHint.
  ///
  /// In en, this message translates to:
  /// **'Address'**
  String get partyAddressHint;

  /// No description provided for @addPartyButton.
  ///
  /// In en, this message translates to:
  /// **'Add New Party'**
  String get addPartyButton;

  /// No description provided for @partyFilterAll.
  ///
  /// In en, this message translates to:
  /// **'All'**
  String get partyFilterAll;

  /// No description provided for @partyTypeInvestor.
  ///
  /// In en, this message translates to:
  /// **'Investor'**
  String get partyTypeInvestor;

  /// No description provided for @partyTypeFarmer.
  ///
  /// In en, this message translates to:
  /// **'Farmer'**
  String get partyTypeFarmer;

  /// No description provided for @partyTypeCustomer.
  ///
  /// In en, this message translates to:
  /// **'Customer'**
  String get partyTypeCustomer;

  /// No description provided for @partyTypeOtherVendor.
  ///
  /// In en, this message translates to:
  /// **'Other Vendor'**
  String get partyTypeOtherVendor;

  /// No description provided for @noPartiesFoundMessage.
  ///
  /// In en, this message translates to:
  /// **'No parties found. Add your first contact!'**
  String get noPartiesFoundMessage;

  /// No description provided for @noFilteredPartiesFoundMessage.
  ///
  /// In en, this message translates to:
  /// **'No parties found.'**
  String get noFilteredPartiesFoundMessage;

  /// No description provided for @productNameHint.
  ///
  /// In en, this message translates to:
  /// **'Product Name'**
  String get productNameHint;

  /// No description provided for @productUnitHint.
  ///
  /// In en, this message translates to:
  /// **'Unit (e.g., Kg)'**
  String get productUnitHint;

  /// No description provided for @addProductButton.
  ///
  /// In en, this message translates to:
  /// **'Add New Product'**
  String get addProductButton;

  /// No description provided for @locationNameHint.
  ///
  /// In en, this message translates to:
  /// **'Location Name (e.g., Godown A)'**
  String get locationNameHint;

  /// No description provided for @locationAddressHint.
  ///
  /// In en, this message translates to:
  /// **'Address'**
  String get locationAddressHint;

  /// No description provided for @locationRentCostHint.
  ///
  /// In en, this message translates to:
  /// **'Monthly Rent Cost'**
  String get locationRentCostHint;

  /// No description provided for @addLocationButton.
  ///
  /// In en, this message translates to:
  /// **'Add New Location'**
  String get addLocationButton;

  /// No description provided for @totalSacksPurchased.
  ///
  /// In en, this message translates to:
  /// **'Total Sacks Purchased:'**
  String get totalSacksPurchased;

  /// No description provided for @totalSacksSold.
  ///
  /// In en, this message translates to:
  /// **'Total Sacks Sold:'**
  String get totalSacksSold;

  /// No description provided for @currentInStockValue.
  ///
  /// In en, this message translates to:
  /// **'Current In-Stock Value:'**
  String get currentInStockValue;

  /// No description provided for @totalExpenses.
  ///
  /// In en, this message translates to:
  /// **'Total Expenses:'**
  String get totalExpenses;

  /// No description provided for @totalInvestments.
  ///
  /// In en, this message translates to:
  /// **'Total Investments:'**
  String get totalInvestments;

  /// No description provided for @recordPurchaseButton.
  ///
  /// In en, this message translates to:
  /// **'Record Purchase'**
  String get recordPurchaseButton;

  /// No description provided for @recordSaleButton.
  ///
  /// In en, this message translates to:
  /// **'Record Sale'**
  String get recordSaleButton;

  /// No description provided for @addExpenseButton.
  ///
  /// In en, this message translates to:
  /// **'Add Expense'**
  String get addExpenseButton;

  /// No description provided for @addInvestmentButton.
  ///
  /// In en, this message translates to:
  /// **'Add Investment'**
  String get addInvestmentButton;

  /// No description provided for @viewAllInventory.
  ///
  /// In en, this message translates to:
  /// **'View All Inventory'**
  String get viewAllInventory;

  /// No description provided for @viewAllExpenses.
  ///
  /// In en, this message translates to:
  /// **'View All Expenses'**
  String get viewAllExpenses;

  /// No description provided for @viewAllInvestments.
  ///
  /// In en, this message translates to:
  /// **'View All Investments'**
  String get viewAllInvestments;

  /// No description provided for @noSacksFound.
  ///
  /// In en, this message translates to:
  /// **'No sacks found.'**
  String get noSacksFound;

  /// No description provided for @noExpensesFound.
  ///
  /// In en, this message translates to:
  /// **'No expenses found.'**
  String get noExpensesFound;

  /// No description provided for @noInvestmentsFound.
  ///
  /// In en, this message translates to:
  /// **'No investments found.'**
  String get noInvestmentsFound;

  /// No description provided for @purchaseDetails.
  ///
  /// In en, this message translates to:
  /// **'Purchase Details'**
  String get purchaseDetails;

  /// No description provided for @saleDetails.
  ///
  /// In en, this message translates to:
  /// **'Sale Details'**
  String get saleDetails;

  /// No description provided for @dateLabel.
  ///
  /// In en, this message translates to:
  /// **'Date:'**
  String get dateLabel;

  /// No description provided for @productLabel.
  ///
  /// In en, this message translates to:
  /// **'Product:'**
  String get productLabel;

  /// No description provided for @vendorLabel.
  ///
  /// In en, this message translates to:
  /// **'Vendor:'**
  String get vendorLabel;

  /// No description provided for @customerLabel.
  ///
  /// In en, this message translates to:
  /// **'Customer:'**
  String get customerLabel;

  /// No description provided for @weightLabel.
  ///
  /// In en, this message translates to:
  /// **'Weight (Kg):'**
  String get weightLabel;

  /// No description provided for @pricePerKgLabel.
  ///
  /// In en, this message translates to:
  /// **'Price per Kg:'**
  String get pricePerKgLabel;

  /// No description provided for @carryingCostLabel.
  ///
  /// In en, this message translates to:
  /// **'Carrying Cost:'**
  String get carryingCostLabel;

  /// No description provided for @locationLabel.
  ///
  /// In en, this message translates to:
  /// **'Location:'**
  String get locationLabel;

  /// No description provided for @statusLabel.
  ///
  /// In en, this message translates to:
  /// **'Status:'**
  String get statusLabel;

  /// No description provided for @uniqueSackIdentifierLabel.
  ///
  /// In en, this message translates to:
  /// **'Sack ID:'**
  String get uniqueSackIdentifierLabel;

  /// No description provided for @addNewSack.
  ///
  /// In en, this message translates to:
  /// **'Add New Sack'**
  String get addNewSack;

  /// No description provided for @updateSack.
  ///
  /// In en, this message translates to:
  /// **'Update Sack'**
  String get updateSack;

  /// No description provided for @sackStatusInStock.
  ///
  /// In en, this message translates to:
  /// **'In Stock'**
  String get sackStatusInStock;

  /// No description provided for @sackStatusSold.
  ///
  /// In en, this message translates to:
  /// **'Sold'**
  String get sackStatusSold;

  /// No description provided for @sackStatusDiscarded.
  ///
  /// In en, this message translates to:
  /// **'Discarded'**
  String get sackStatusDiscarded;

  /// No description provided for @expenseCategoryHint.
  ///
  /// In en, this message translates to:
  /// **'Category'**
  String get expenseCategoryHint;

  /// No description provided for @expenseDescriptionHint.
  ///
  /// In en, this message translates to:
  /// **'Description'**
  String get expenseDescriptionHint;

  /// No description provided for @expenseAmountHint.
  ///
  /// In en, this message translates to:
  /// **'Amount'**
  String get expenseAmountHint;

  /// No description provided for @expenseCategoryTransport.
  ///
  /// In en, this message translates to:
  /// **'Transport'**
  String get expenseCategoryTransport;

  /// No description provided for @expenseCategoryLabor.
  ///
  /// In en, this message translates to:
  /// **'Labor'**
  String get expenseCategoryLabor;

  /// No description provided for @expenseCategoryRent.
  ///
  /// In en, this message translates to:
  /// **'Rent'**
  String get expenseCategoryRent;

  /// No description provided for @expenseCategoryMaintenance.
  ///
  /// In en, this message translates to:
  /// **'Maintenance'**
  String get expenseCategoryMaintenance;

  /// No description provided for @expenseCategoryOther.
  ///
  /// In en, this message translates to:
  /// **'Other'**
  String get expenseCategoryOther;

  /// No description provided for @investorLabel.
  ///
  /// In en, this message translates to:
  /// **'Investor:'**
  String get investorLabel;

  /// No description provided for @investmentAmountHint.
  ///
  /// In en, this message translates to:
  /// **'Amount'**
  String get investmentAmountHint;

  /// No description provided for @investmentNotesHint.
  ///
  /// In en, this message translates to:
  /// **'Notes'**
  String get investmentNotesHint;

  /// No description provided for @profitDistributionLabel.
  ///
  /// In en, this message translates to:
  /// **'Profit Distribution'**
  String get profitDistributionLabel;

  /// No description provided for @amountDistributedHint.
  ///
  /// In en, this message translates to:
  /// **'Amount Distributed'**
  String get amountDistributedHint;

  /// No description provided for @profitDistributionNotesHint.
  ///
  /// In en, this message translates to:
  /// **'Notes'**
  String get profitDistributionNotesHint;

  /// No description provided for @purchaseRequiredFieldsMessage.
  ///
  /// In en, this message translates to:
  /// **'Please fill all required purchase fields.'**
  String get purchaseRequiredFieldsMessage;

  /// No description provided for @saleRequiredFieldsMessage.
  ///
  /// In en, this message translates to:
  /// **'Please select a sack and fill all required sale fields.'**
  String get saleRequiredFieldsMessage;

  /// No description provided for @invalidNumberInputMessage.
  ///
  /// In en, this message translates to:
  /// **'Please enter valid numbers for weight and price.'**
  String get invalidNumberInputMessage;

  /// No description provided for @purchaseSuccessMessage.
  ///
  /// In en, this message translates to:
  /// **'Purchase recorded successfully!'**
  String get purchaseSuccessMessage;

  /// No description provided for @saleSuccessMessage.
  ///
  /// In en, this message translates to:
  /// **'Sale recorded successfully!'**
  String get saleSuccessMessage;

  /// No description provided for @errorRecordingPurchase.
  ///
  /// In en, this message translates to:
  /// **'Error recording purchase:'**
  String get errorRecordingPurchase;

  /// No description provided for @errorRecordingSale.
  ///
  /// In en, this message translates to:
  /// **'Error recording sale:'**
  String get errorRecordingSale;

  /// No description provided for @selectVendorPrompt.
  ///
  /// In en, this message translates to:
  /// **'Please select a vendor.'**
  String get selectVendorPrompt;

  /// No description provided for @selectLocationPrompt.
  ///
  /// In en, this message translates to:
  /// **'Please select a location.'**
  String get selectLocationPrompt;

  /// No description provided for @selectCustomerPrompt.
  ///
  /// In en, this message translates to:
  /// **'Please select a customer.'**
  String get selectCustomerPrompt;

  /// No description provided for @selectSackToSellPrompt.
  ///
  /// In en, this message translates to:
  /// **'Please select a sack to sell.'**
  String get selectSackToSellPrompt;

  /// No description provided for @recordExpense.
  ///
  /// In en, this message translates to:
  /// **'Record Expense'**
  String get recordExpense;

  /// No description provided for @recordInvestment.
  ///
  /// In en, this message translates to:
  /// **'Record Investment'**
  String get recordInvestment;

  /// No description provided for @amountLabel.
  ///
  /// In en, this message translates to:
  /// **'Amount:'**
  String get amountLabel;

  /// No description provided for @descriptionLabel.
  ///
  /// In en, this message translates to:
  /// **'Description:'**
  String get descriptionLabel;

  /// No description provided for @categoryLabel.
  ///
  /// In en, this message translates to:
  /// **'Category:'**
  String get categoryLabel;

  /// No description provided for @investmentDescriptionHint.
  ///
  /// In en, this message translates to:
  /// **'e.g., Initial capital, Loan'**
  String get investmentDescriptionHint;

  /// No description provided for @recentExpenses.
  ///
  /// In en, this message translates to:
  /// **'Recent Expenses'**
  String get recentExpenses;

  /// No description provided for @recentInvestments.
  ///
  /// In en, this message translates to:
  /// **'Recent Investments'**
  String get recentInvestments;

  /// No description provided for @confirmDeleteExpense.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to delete this expense?'**
  String get confirmDeleteExpense;

  /// No description provided for @confirmDeleteInvestment.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to delete this investment?'**
  String get confirmDeleteInvestment;

  /// No description provided for @expenseRequiredFieldsMessage.
  ///
  /// In en, this message translates to:
  /// **'Please fill all required expense fields.'**
  String get expenseRequiredFieldsMessage;

  /// No description provided for @invalidExpenseAmount.
  ///
  /// In en, this message translates to:
  /// **'Please enter a valid positive amount for expense.'**
  String get invalidExpenseAmount;

  /// No description provided for @investmentRequiredFieldsMessage.
  ///
  /// In en, this message translates to:
  /// **'Please select an investor and fill all required investment fields.'**
  String get investmentRequiredFieldsMessage;

  /// No description provided for @invalidInvestmentAmount.
  ///
  /// In en, this message translates to:
  /// **'Please enter a valid positive amount for investment.'**
  String get invalidInvestmentAmount;

  /// No description provided for @expenseSuccessMessage.
  ///
  /// In en, this message translates to:
  /// **'Expense recorded successfully!'**
  String get expenseSuccessMessage;

  /// No description provided for @investmentSuccessMessage.
  ///
  /// In en, this message translates to:
  /// **'Investment recorded successfully!'**
  String get investmentSuccessMessage;

  /// No description provided for @errorRecordingExpense.
  ///
  /// In en, this message translates to:
  /// **'Error recording expense:'**
  String get errorRecordingExpense;

  /// No description provided for @errorRecordingInvestment.
  ///
  /// In en, this message translates to:
  /// **'Error recording investment:'**
  String get errorRecordingInvestment;

  /// No description provided for @selectInvestorPrompt.
  ///
  /// In en, this message translates to:
  /// **'Please select an investor.'**
  String get selectInvestorPrompt;

  /// No description provided for @profitDistributionTitle.
  ///
  /// In en, this message translates to:
  /// **'Profit Distribution'**
  String get profitDistributionTitle;

  /// No description provided for @seasonFinancialSummary.
  ///
  /// In en, this message translates to:
  /// **'Season Financial Summary'**
  String get seasonFinancialSummary;

  /// No description provided for @totalRevenue.
  ///
  /// In en, this message translates to:
  /// **'Total Revenue:'**
  String get totalRevenue;

  /// No description provided for @totalPurchaseCost.
  ///
  /// In en, this message translates to:
  /// **'Total Purchase Cost:'**
  String get totalPurchaseCost;

  /// No description provided for @totalCarryingCost.
  ///
  /// In en, this message translates to:
  /// **'Total Carrying Cost:'**
  String get totalCarryingCost;

  /// No description provided for @netProfitLoss.
  ///
  /// In en, this message translates to:
  /// **'Net Profit/Loss:'**
  String get netProfitLoss;

  /// No description provided for @recordProfitDistribution.
  ///
  /// In en, this message translates to:
  /// **'Record Profit Distribution'**
  String get recordProfitDistribution;

  /// No description provided for @recipientLabel.
  ///
  /// In en, this message translates to:
  /// **'Recipient:'**
  String get recipientLabel;

  /// No description provided for @distributionDescriptionHint.
  ///
  /// In en, this message translates to:
  /// **'e.g., Share for Investor X, Owner\'s drawing'**
  String get distributionDescriptionHint;

  /// No description provided for @recordDistribution.
  ///
  /// In en, this message translates to:
  /// **'Record Distribution'**
  String get recordDistribution;

  /// No description provided for @recentDistributions.
  ///
  /// In en, this message translates to:
  /// **'Recent Distributions'**
  String get recentDistributions;

  /// No description provided for @noDistributionsFound.
  ///
  /// In en, this message translates to:
  /// **'No profit distributions found for this season.'**
  String get noDistributionsFound;

  /// No description provided for @confirmDeleteDistribution.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to delete this profit distribution?'**
  String get confirmDeleteDistribution;

  /// No description provided for @distributionRequiredFieldsMessage.
  ///
  /// In en, this message translates to:
  /// **'Please select a recipient and fill all required distribution fields.'**
  String get distributionRequiredFieldsMessage;

  /// No description provided for @invalidDistributionAmount.
  ///
  /// In en, this message translates to:
  /// **'Please enter a valid positive amount for distribution.'**
  String get invalidDistributionAmount;

  /// No description provided for @distributionSuccessMessage.
  ///
  /// In en, this message translates to:
  /// **'Profit distribution recorded successfully!'**
  String get distributionSuccessMessage;

  /// No description provided for @errorRecordingDistribution.
  ///
  /// In en, this message translates to:
  /// **'Error recording distribution:'**
  String get errorRecordingDistribution;

  /// No description provided for @selectRecipientPrompt.
  ///
  /// In en, this message translates to:
  /// **'Please select a recipient.'**
  String get selectRecipientPrompt;

  /// No description provided for @totalDistributedAmount.
  ///
  /// In en, this message translates to:
  /// **'Total Distributed:'**
  String get totalDistributedAmount;

  /// No description provided for @undistributedProfit.
  ///
  /// In en, this message translates to:
  /// **'Undistributed Profit:'**
  String get undistributedProfit;

  /// No description provided for @distributionExceedsProfit.
  ///
  /// In en, this message translates to:
  /// **'Distribution amount exceeds undistributed profit!'**
  String get distributionExceedsProfit;

  /// No description provided for @cannotDistributeNegativeProfit.
  ///
  /// In en, this message translates to:
  /// **'Cannot distribute profit when net profit is zero or negative.'**
  String get cannotDistributeNegativeProfit;

  /// No description provided for @sackDetailsTitle.
  ///
  /// In en, this message translates to:
  /// **'Sack Details'**
  String get sackDetailsTitle;

  /// No description provided for @generalInfo.
  ///
  /// In en, this message translates to:
  /// **'General Info'**
  String get generalInfo;

  /// No description provided for @currentLocation.
  ///
  /// In en, this message translates to:
  /// **'Current Location:'**
  String get currentLocation;

  /// No description provided for @totalPurchaseValue.
  ///
  /// In en, this message translates to:
  /// **'Total Purchase Value:'**
  String get totalPurchaseValue;

  /// No description provided for @totalSaleValue.
  ///
  /// In en, this message translates to:
  /// **'Total Sale Value:'**
  String get totalSaleValue;

  /// No description provided for @netGainLoss.
  ///
  /// In en, this message translates to:
  /// **'Net Gain/Loss:'**
  String get netGainLoss;

  /// No description provided for @notAvailable.
  ///
  /// In en, this message translates to:
  /// **'N/A'**
  String get notAvailable;

  /// No description provided for @unknown.
  ///
  /// In en, this message translates to:
  /// **'Unknown'**
  String get unknown;

  /// No description provided for @sackNotFound.
  ///
  /// In en, this message translates to:
  /// **'Sack not found!'**
  String get sackNotFound;

  /// No description provided for @sackUpdatedSuccessfully.
  ///
  /// In en, this message translates to:
  /// **'Sack details updated successfully!'**
  String get sackUpdatedSuccessfully;

  /// No description provided for @errorUpdatingSack.
  ///
  /// In en, this message translates to:
  /// **'Error updating sack:'**
  String get errorUpdatingSack;

  /// No description provided for @sackDeletedSuccessfully.
  ///
  /// In en, this message translates to:
  /// **'Sack deleted successfully!'**
  String get sackDeletedSuccessfully;

  /// No description provided for @errorDeletingSack.
  ///
  /// In en, this message translates to:
  /// **'Error deleting sack:'**
  String get errorDeletingSack;

  /// No description provided for @confirmDeleteSack.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to delete this sack?'**
  String get confirmDeleteSack;

  /// No description provided for @confirmDeleteSoldSack.
  ///
  /// In en, this message translates to:
  /// **'This sack has been sold. Deleting it will affect your financial records. Are you sure you want to delete it anyway?'**
  String get confirmDeleteSoldSack;

  /// No description provided for @deleteAnyway.
  ///
  /// In en, this message translates to:
  /// **'Delete Anyway'**
  String get deleteAnyway;

  /// No description provided for @singleSaleTab.
  ///
  /// In en, this message translates to:
  /// **'Single Sack Sale'**
  String get singleSaleTab;

  /// No description provided for @bulkSaleTab.
  ///
  /// In en, this message translates to:
  /// **'Bulk Sale'**
  String get bulkSaleTab;

  /// No description provided for @sellingSack.
  ///
  /// In en, this message translates to:
  /// **'Selling Sack'**
  String get sellingSack;

  /// No description provided for @selectSackForSale.
  ///
  /// In en, this message translates to:
  /// **'Select a sack from Inventory to sell individually.'**
  String get selectSackForSale;

  /// No description provided for @selectSackFromInventoryTip.
  ///
  /// In en, this message translates to:
  /// **'To sell a single sack, please go to the Inventory screen and tap on the specific sack to sell it.'**
  String get selectSackFromInventoryTip;

  /// No description provided for @saleDateLabel.
  ///
  /// In en, this message translates to:
  /// **'Sale Date:'**
  String get saleDateLabel;

  /// No description provided for @saleWeightLabel.
  ///
  /// In en, this message translates to:
  /// **'Sale Weight:'**
  String get saleWeightLabel;

  /// No description provided for @salePricePerKgLabel.
  ///
  /// In en, this message translates to:
  /// **'Sale Price per Kg:'**
  String get salePricePerKgLabel;

  /// No description provided for @saleCarryingCostLabel.
  ///
  /// In en, this message translates to:
  /// **'Sale Carrying Cost:'**
  String get saleCarryingCostLabel;

  /// No description provided for @customerRequired.
  ///
  /// In en, this message translates to:
  /// **'Please select a customer.'**
  String get customerRequired;

  /// No description provided for @selectCustomer.
  ///
  /// In en, this message translates to:
  /// **'Select Customer'**
  String get selectCustomer;

  /// No description provided for @recordSale.
  ///
  /// In en, this message translates to:
  /// **'Record Sale'**
  String get recordSale;

  /// No description provided for @validAmountRequired.
  ///
  /// In en, this message translates to:
  /// **'Please enter valid positive sale weight and price.'**
  String get validAmountRequired;

  /// No description provided for @saleWeightExceedsPurchase.
  ///
  /// In en, this message translates to:
  /// **'Sale weight cannot exceed purchase weight.'**
  String get saleWeightExceedsPurchase;

  /// No description provided for @saleRecordedSuccessfully.
  ///
  /// In en, this message translates to:
  /// **'Sale recorded successfully!'**
  String get saleRecordedSuccessfully;

  /// No description provided for @selectSacksAndFillFields.
  ///
  /// In en, this message translates to:
  /// **'Please select sacks and fill all required fields for bulk sale.'**
  String get selectSacksAndFillFields;

  /// No description provided for @validPriceRequired.
  ///
  /// In en, this message translates to:
  /// **'Please enter a valid positive sale price per Kg.'**
  String get validPriceRequired;

  /// No description provided for @totalCarryingCostLabel.
  ///
  /// In en, this message translates to:
  /// **'Total Bulk Carrying Cost:'**
  String get totalCarryingCostLabel;

  /// No description provided for @totalCarryingCostHint.
  ///
  /// In en, this message translates to:
  /// **'e.g., transport cost for the entire lot'**
  String get totalCarryingCostHint;

  /// No description provided for @totalSelectedWeight.
  ///
  /// In en, this message translates to:
  /// **'Total Selected Weight:'**
  String get totalSelectedWeight;

  /// No description provided for @calculatedSaleAmount.
  ///
  /// In en, this message translates to:
  /// **'Calculated Sale Amount:'**
  String get calculatedSaleAmount;

  /// No description provided for @recordBulkSale.
  ///
  /// In en, this message translates to:
  /// **'Record Bulk Sale'**
  String get recordBulkSale;

  /// No description provided for @noSacksInStock.
  ///
  /// In en, this message translates to:
  /// **'No sacks currently in stock for this season.'**
  String get noSacksInStock;

  /// No description provided for @bulkSaleRecordedSuccessfully.
  ///
  /// In en, this message translates to:
  /// **'Bulk sale recorded successfully!'**
  String get bulkSaleRecordedSuccessfully;

  /// No description provided for @errorRecordingBulkSale.
  ///
  /// In en, this message translates to:
  /// **'Error recording bulk sale:'**
  String get errorRecordingBulkSale;

  /// No description provided for @purchaseDateLabel.
  ///
  /// In en, this message translates to:
  /// **'Purchase Date:'**
  String get purchaseDateLabel;

  /// No description provided for @purchaseWeightLabel.
  ///
  /// In en, this message translates to:
  /// **'Purchase Weight:'**
  String get purchaseWeightLabel;

  /// No description provided for @purchasePricePerKgLabel.
  ///
  /// In en, this message translates to:
  /// **'Purchase Price per Kg:'**
  String get purchasePricePerKgLabel;

  /// No description provided for @unknownLocation.
  ///
  /// In en, this message translates to:
  /// **'Location not known'**
  String get unknownLocation;

  /// No description provided for @saleTitle.
  ///
  /// In en, this message translates to:
  /// **'Sale Transaction'**
  String get saleTitle;

  /// No description provided for @saleScreenTitle.
  ///
  /// In en, this message translates to:
  /// **'Sell'**
  String get saleScreenTitle;

  /// No description provided for @fillAllFields.
  ///
  /// In en, this message translates to:
  /// **'Fill All Fields'**
  String get fillAllFields;

  /// No description provided for @reportsTitle.
  ///
  /// In en, this message translates to:
  /// **'Reports & Analytics'**
  String get reportsTitle;

  /// No description provided for @noSeasonsFoundForReports.
  ///
  /// In en, this message translates to:
  /// **'No seasons found to generate reports. Please add seasons first.'**
  String get noSeasonsFoundForReports;

  /// No description provided for @season.
  ///
  /// In en, this message translates to:
  /// **'Season'**
  String get season;

  /// No description provided for @duration.
  ///
  /// In en, this message translates to:
  /// **'Duration'**
  String get duration;

  /// No description provided for @inventorySummary.
  ///
  /// In en, this message translates to:
  /// **'Inventory Summary'**
  String get inventorySummary;

  /// No description provided for @financialSummary.
  ///
  /// In en, this message translates to:
  /// **'Summary'**
  String get financialSummary;

  /// No description provided for @sacksInStock.
  ///
  /// In en, this message translates to:
  /// **'Sacks In Stock'**
  String get sacksInStock;

  /// No description provided for @totalWeightInStock.
  ///
  /// In en, this message translates to:
  /// **'Total Weight (In Stock)'**
  String get totalWeightInStock;

  /// No description provided for @sacksSold.
  ///
  /// In en, this message translates to:
  /// **'Sacks Sold'**
  String get sacksSold;

  /// No description provided for @totalWeightSold.
  ///
  /// In en, this message translates to:
  /// **'Total Weight (Sold)'**
  String get totalWeightSold;

  /// No description provided for @sacksDiscarded.
  ///
  /// In en, this message translates to:
  /// **'Sacks Discarded'**
  String get sacksDiscarded;

  /// No description provided for @totalStockValue.
  ///
  /// In en, this message translates to:
  /// **'Total Stock Value (In Stock)'**
  String get totalStockValue;

  /// No description provided for @notApplicable.
  ///
  /// In en, this message translates to:
  /// **'N/A'**
  String get notApplicable;

  /// No description provided for @currentInventoryValue.
  ///
  /// In en, this message translates to:
  /// **'Current Inventory Value:'**
  String get currentInventoryValue;

  /// No description provided for @profitTrendBySeason.
  ///
  /// In en, this message translates to:
  /// **'Profit/Loss Trend by Season'**
  String get profitTrendBySeason;

  /// No description provided for @inventoryStatusBreakdown.
  ///
  /// In en, this message translates to:
  /// **'Inventory Status Breakdown'**
  String get inventoryStatusBreakdown;

  /// No description provided for @inStockShort.
  ///
  /// In en, this message translates to:
  /// **'In Stock'**
  String get inStockShort;

  /// No description provided for @soldShort.
  ///
  /// In en, this message translates to:
  /// **'Sold'**
  String get soldShort;

  /// No description provided for @discardedShort.
  ///
  /// In en, this message translates to:
  /// **'Discarded'**
  String get discardedShort;

  /// No description provided for @activeSeason.
  ///
  /// In en, this message translates to:
  /// **'Active Season'**
  String get activeSeason;

  /// No description provided for @manageSeasons.
  ///
  /// In en, this message translates to:
  /// **'Manage Seasons'**
  String get manageSeasons;

  /// No description provided for @noProfitDataAvailable.
  ///
  /// In en, this message translates to:
  /// **'No profit data available for charts.'**
  String get noProfitDataAvailable;

  /// No description provided for @noInventoryDataForCharts.
  ///
  /// In en, this message translates to:
  /// **'No inventory data available for charts.'**
  String get noInventoryDataForCharts;

  /// No description provided for @searchSacks.
  ///
  /// In en, this message translates to:
  /// **'Search Sacks'**
  String get searchSacks;

  /// No description provided for @searchSacksHint.
  ///
  /// In en, this message translates to:
  /// **'Enter code, type, or notes...'**
  String get searchSacksHint;

  /// No description provided for @allProducts.
  ///
  /// In en, this message translates to:
  /// **'All Products'**
  String get allProducts;

  /// No description provided for @allStatuses.
  ///
  /// In en, this message translates to:
  /// **'All Statuses'**
  String get allStatuses;

  /// No description provided for @allLocations.
  ///
  /// In en, this message translates to:
  /// **'All Locations'**
  String get allLocations;

  /// No description provided for @productType.
  ///
  /// In en, this message translates to:
  /// **'Product Type'**
  String get productType;

  /// No description provided for @status.
  ///
  /// In en, this message translates to:
  /// **'Status'**
  String get status;

  /// No description provided for @location.
  ///
  /// In en, this message translates to:
  /// **'Location'**
  String get location;

  /// No description provided for @resetFilters.
  ///
  /// In en, this message translates to:
  /// **'Reset Filters'**
  String get resetFilters;

  /// No description provided for @code.
  ///
  /// In en, this message translates to:
  /// **'Code'**
  String get code;

  /// No description provided for @weight.
  ///
  /// In en, this message translates to:
  /// **'Weight'**
  String get weight;

  /// No description provided for @date.
  ///
  /// In en, this message translates to:
  /// **'Date'**
  String get date;

  /// No description provided for @searchParty.
  ///
  /// In en, this message translates to:
  /// **'Search Party'**
  String get searchParty;

  /// No description provided for @searchPartyHint.
  ///
  /// In en, this message translates to:
  /// **'Enter name or phone number...'**
  String get searchPartyHint;

  /// No description provided for @allTypes.
  ///
  /// In en, this message translates to:
  /// **'All Types'**
  String get allTypes;

  /// No description provided for @partyType.
  ///
  /// In en, this message translates to:
  /// **'Party Type'**
  String get partyType;

  /// No description provided for @confirmDeleteParty.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to delete this party?'**
  String get confirmDeleteParty;

  /// No description provided for @partyTypeEmptyValidation.
  ///
  /// In en, this message translates to:
  /// **'Please select a party type.'**
  String get partyTypeEmptyValidation;

  /// No description provided for @partyNameTypeEmptyValidation.
  ///
  /// In en, this message translates to:
  /// **'Party name and type cannot be empty.'**
  String get partyNameTypeEmptyValidation;

  /// No description provided for @darkMode.
  ///
  /// In en, this message translates to:
  /// **'Dark Mode'**
  String get darkMode;

  /// No description provided for @currencySymbol.
  ///
  /// In en, this message translates to:
  /// **'Currency Symbol'**
  String get currencySymbol;

  /// No description provided for @dateFormat.
  ///
  /// In en, this message translates to:
  /// **'Date Format'**
  String get dateFormat;

  /// No description provided for @overviewTitle.
  ///
  /// In en, this message translates to:
  /// **'Overview'**
  String get overviewTitle;

  /// No description provided for @managementTitle.
  ///
  /// In en, this message translates to:
  /// **'Management'**
  String get managementTitle;

  /// No description provided for @reportingTitle.
  ///
  /// In en, this message translates to:
  /// **'Reporting'**
  String get reportingTitle;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['bn', 'en'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'bn':
      return AppLocalizationsBn();
    case 'en':
      return AppLocalizationsEn();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
