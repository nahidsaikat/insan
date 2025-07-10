// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'AgroStock Manager';

  @override
  String get dashboardTitle => 'Dashboard';

  @override
  String get inventoryTitle => 'Inventory';

  @override
  String get transactionsTitle => 'Transactions';

  @override
  String get expensesInvestmentsTitle => 'Expenses & Investments';

  @override
  String get seasonManagementTitle => 'Season Management';

  @override
  String get partyManagementTitle => 'Party Management';

  @override
  String get inventoryLocationsTitle => 'Inventory Locations';

  @override
  String get noLocationsFoundMessage =>
      'No inventory locations found. Add your first location!';

  @override
  String get confirmDeleteLocation =>
      'Are you sure you want to delete this inventory location?';

  @override
  String get settingsTitle => 'Settings';

  @override
  String get aboutTitle => 'About';

  @override
  String get activeSeasonLabel => 'Active Season:';

  @override
  String get noActiveSeasonMessage =>
      'No active season found. Please create or select one.';

  @override
  String get createSeasonButton => 'Create New Season';

  @override
  String get selectSeasonButton => 'Select Season';

  @override
  String get addSeasonPrompt => 'Enter new season name:';

  @override
  String get seasonNameHint => 'e.g., Boro 2025';

  @override
  String get saveButton => 'Save';

  @override
  String get cancelButton => 'Cancel';

  @override
  String get editButton => 'Edit';

  @override
  String get deleteButton => 'Delete';

  @override
  String get confirmDeleteSeason =>
      'Are you sure you want to delete this season and all associated data?';

  @override
  String get seasonStartHint => 'Start Date';

  @override
  String get seasonEndHint => 'End Date';

  @override
  String get seasonStatus => 'Status:';

  @override
  String get activeStatus => 'Active';

  @override
  String get inactiveStatus => 'Inactive';

  @override
  String get partyNameHint => 'Party Name';

  @override
  String get partyTypeHint => 'Party Type';

  @override
  String get partyContactHint => 'Phone Number';

  @override
  String get partyAddressHint => 'Address';

  @override
  String get addPartyButton => 'Add New Party';

  @override
  String get partyFilterAll => 'All';

  @override
  String get partyTypeInvestor => 'Investor';

  @override
  String get partyTypeFarmer => 'Farmer';

  @override
  String get partyTypeCustomer => 'Customer';

  @override
  String get partyTypeOtherVendor => 'Other Vendor';

  @override
  String get noPartiesFoundMessage =>
      'No parties found. Add your first contact!';

  @override
  String get noFilteredPartiesFoundMessage => 'No parties found.';

  @override
  String get productNameHint => 'Product Name';

  @override
  String get productUnitHint => 'Unit (e.g., Kg)';

  @override
  String get addProductButton => 'Add New Product';

  @override
  String get locationNameHint => 'Location Name (e.g., Godown A)';

  @override
  String get locationAddressHint => 'Address';

  @override
  String get locationRentCostHint => 'Monthly Rent Cost';

  @override
  String get addLocationButton => 'Add New Location';

  @override
  String get totalSacksPurchased => 'Total Sacks Purchased:';

  @override
  String get totalSacksSold => 'Total Sacks Sold:';

  @override
  String get currentInStockValue => 'Current In-Stock Value:';

  @override
  String get totalExpenses => 'Total Expenses:';

  @override
  String get totalInvestments => 'Total Investments:';

  @override
  String get recordPurchaseButton => 'Record Purchase';

  @override
  String get recordSaleButton => 'Record Sale';

  @override
  String get addExpenseButton => 'Add Expense';

  @override
  String get addInvestmentButton => 'Add Investment';

  @override
  String get viewAllInventory => 'View All Inventory';

  @override
  String get viewAllExpenses => 'View All Expenses';

  @override
  String get viewAllInvestments => 'View All Investments';

  @override
  String get noSacksFound => 'No sacks found.';

  @override
  String get noExpensesFound => 'No expenses found.';

  @override
  String get noInvestmentsFound => 'No investments found.';

  @override
  String get purchaseDetails => 'Purchase Details';

  @override
  String get saleDetails => 'Sale Details';

  @override
  String get dateLabel => 'Date:';

  @override
  String get productLabel => 'Product:';

  @override
  String get vendorLabel => 'Vendor:';

  @override
  String get customerLabel => 'Customer:';

  @override
  String get weightLabel => 'Weight (Kg):';

  @override
  String get pricePerKgLabel => 'Price per Kg:';

  @override
  String get carryingCostLabel => 'Carrying Cost:';

  @override
  String get locationLabel => 'Location:';

  @override
  String get statusLabel => 'Status:';

  @override
  String get uniqueSackIdentifierLabel => 'Sack ID:';

  @override
  String get addNewSack => 'Add New Sack';

  @override
  String get updateSack => 'Update Sack';

  @override
  String get sackStatusInStock => 'In Stock';

  @override
  String get sackStatusSold => 'Sold';

  @override
  String get sackStatusDiscarded => 'Discarded';

  @override
  String get expenseCategoryHint => 'Category';

  @override
  String get expenseDescriptionHint => 'Description';

  @override
  String get expenseAmountHint => 'Amount';

  @override
  String get expenseCategoryTransport => 'Transport';

  @override
  String get expenseCategoryLabor => 'Labor';

  @override
  String get expenseCategoryRent => 'Rent';

  @override
  String get expenseCategoryMaintenance => 'Maintenance';

  @override
  String get expenseCategoryOther => 'Other';

  @override
  String get investorLabel => 'Investor:';

  @override
  String get investmentAmountHint => 'Amount';

  @override
  String get investmentNotesHint => 'Notes';

  @override
  String get profitDistributionLabel => 'Profit Distribution';

  @override
  String get amountDistributedHint => 'Amount Distributed';

  @override
  String get profitDistributionNotesHint => 'Notes';

  @override
  String get purchaseRequiredFieldsMessage =>
      'Please fill all required purchase fields.';

  @override
  String get saleRequiredFieldsMessage =>
      'Please select a sack and fill all required sale fields.';

  @override
  String get invalidNumberInputMessage =>
      'Please enter valid numbers for weight and price.';

  @override
  String get purchaseSuccessMessage => 'Purchase recorded successfully!';

  @override
  String get saleSuccessMessage => 'Sale recorded successfully!';

  @override
  String get errorRecordingPurchase => 'Error recording purchase:';

  @override
  String get errorRecordingSale => 'Error recording sale:';

  @override
  String get selectVendorPrompt => 'Please select a vendor.';

  @override
  String get selectLocationPrompt => 'Please select a location.';

  @override
  String get selectCustomerPrompt => 'Please select a customer.';

  @override
  String get selectSackToSellPrompt => 'Please select a sack to sell.';

  @override
  String get recordExpense => 'Record Expense';

  @override
  String get recordInvestment => 'Record Investment';

  @override
  String get amountLabel => 'Amount:';

  @override
  String get descriptionLabel => 'Description:';

  @override
  String get categoryLabel => 'Category:';

  @override
  String get investmentDescriptionHint => 'e.g., Initial capital, Loan';

  @override
  String get recentExpenses => 'Recent Expenses';

  @override
  String get recentInvestments => 'Recent Investments';

  @override
  String get confirmDeleteExpense =>
      'Are you sure you want to delete this expense?';

  @override
  String get confirmDeleteInvestment =>
      'Are you sure you want to delete this investment?';

  @override
  String get expenseRequiredFieldsMessage =>
      'Please fill all required expense fields.';

  @override
  String get invalidExpenseAmount =>
      'Please enter a valid positive amount for expense.';

  @override
  String get investmentRequiredFieldsMessage =>
      'Please select an investor and fill all required investment fields.';

  @override
  String get invalidInvestmentAmount =>
      'Please enter a valid positive amount for investment.';

  @override
  String get expenseSuccessMessage => 'Expense recorded successfully!';

  @override
  String get investmentSuccessMessage => 'Investment recorded successfully!';

  @override
  String get errorRecordingExpense => 'Error recording expense:';

  @override
  String get errorRecordingInvestment => 'Error recording investment:';

  @override
  String get selectInvestorPrompt => 'Please select an investor.';

  @override
  String get profitDistributionTitle => 'Profit Distribution';

  @override
  String get seasonFinancialSummary => 'Season Financial Summary';

  @override
  String get totalRevenue => 'Total Revenue:';

  @override
  String get totalPurchaseCost => 'Total Purchase Cost:';

  @override
  String get totalCarryingCost => 'Total Carrying Cost:';

  @override
  String get netProfitLoss => 'Net Profit/Loss:';

  @override
  String get recordProfitDistribution => 'Record Profit Distribution';

  @override
  String get recipientLabel => 'Recipient:';

  @override
  String get distributionDescriptionHint =>
      'e.g., Share for Investor X, Owner\'s drawing';

  @override
  String get recordDistribution => 'Record Distribution';

  @override
  String get recentDistributions => 'Recent Distributions';

  @override
  String get noDistributionsFound =>
      'No profit distributions found for this season.';

  @override
  String get confirmDeleteDistribution =>
      'Are you sure you want to delete this profit distribution?';

  @override
  String get distributionRequiredFieldsMessage =>
      'Please select a recipient and fill all required distribution fields.';

  @override
  String get invalidDistributionAmount =>
      'Please enter a valid positive amount for distribution.';

  @override
  String get distributionSuccessMessage =>
      'Profit distribution recorded successfully!';

  @override
  String get errorRecordingDistribution => 'Error recording distribution:';

  @override
  String get selectRecipientPrompt => 'Please select a recipient.';

  @override
  String get totalDistributedAmount => 'Total Distributed:';

  @override
  String get undistributedProfit => 'Undistributed Profit:';

  @override
  String get distributionExceedsProfit =>
      'Distribution amount exceeds undistributed profit!';

  @override
  String get cannotDistributeNegativeProfit =>
      'Cannot distribute profit when net profit is zero or negative.';

  @override
  String get sackDetailsTitle => 'Sack Details';

  @override
  String get generalInfo => 'General Info';

  @override
  String get currentLocation => 'Current Location:';

  @override
  String get totalPurchaseValue => 'Total Purchase Value:';

  @override
  String get totalSaleValue => 'Total Sale Value:';

  @override
  String get netGainLoss => 'Net Gain/Loss:';

  @override
  String get notAvailable => 'N/A';

  @override
  String get unknown => 'Unknown';

  @override
  String get sackNotFound => 'Sack not found!';

  @override
  String get sackUpdatedSuccessfully => 'Sack details updated successfully!';

  @override
  String get errorUpdatingSack => 'Error updating sack:';

  @override
  String get sackDeletedSuccessfully => 'Sack deleted successfully!';

  @override
  String get errorDeletingSack => 'Error deleting sack:';

  @override
  String get confirmDeleteSack => 'Are you sure you want to delete this sack?';

  @override
  String get confirmDeleteSoldSack =>
      'This sack has been sold. Deleting it will affect your financial records. Are you sure you want to delete it anyway?';

  @override
  String get deleteAnyway => 'Delete Anyway';

  @override
  String get singleSaleTab => 'Single Sack Sale';

  @override
  String get bulkSaleTab => 'Bulk Sale';

  @override
  String get sellingSack => 'Selling Sack';

  @override
  String get selectSackForSale =>
      'Select a sack from Inventory to sell individually.';

  @override
  String get selectSackFromInventoryTip =>
      'To sell a single sack, please go to the Inventory screen and tap on the specific sack to sell it.';

  @override
  String get saleDateLabel => 'Sale Date:';

  @override
  String get saleWeightLabel => 'Sale Weight:';

  @override
  String get salePricePerKgLabel => 'Sale Price per Kg:';

  @override
  String get saleCarryingCostLabel => 'Sale Carrying Cost:';

  @override
  String get customerRequired => 'Please select a customer.';

  @override
  String get selectCustomer => 'Select Customer';

  @override
  String get recordSale => 'Record Sale';

  @override
  String get validAmountRequired =>
      'Please enter valid positive sale weight and price.';

  @override
  String get saleWeightExceedsPurchase =>
      'Sale weight cannot exceed purchase weight.';

  @override
  String get saleRecordedSuccessfully => 'Sale recorded successfully!';

  @override
  String get selectSacksAndFillFields =>
      'Please select sacks and fill all required fields for bulk sale.';

  @override
  String get validPriceRequired =>
      'Please enter a valid positive sale price per Kg.';

  @override
  String get totalCarryingCostLabel => 'Total Bulk Carrying Cost:';

  @override
  String get totalCarryingCostHint => 'e.g., transport cost for the entire lot';

  @override
  String get totalSelectedWeight => 'Total Selected Weight:';

  @override
  String get calculatedSaleAmount => 'Calculated Sale Amount:';

  @override
  String get recordBulkSale => 'Record Bulk Sale';

  @override
  String get noSacksInStock => 'No sacks currently in stock for this season.';

  @override
  String get bulkSaleRecordedSuccessfully => 'Bulk sale recorded successfully!';

  @override
  String get errorRecordingBulkSale => 'Error recording bulk sale:';

  @override
  String get purchaseDateLabel => 'Purchase Date:';

  @override
  String get purchaseWeightLabel => 'Purchase Weight:';

  @override
  String get purchasePricePerKgLabel => 'Purchase Price per Kg:';

  @override
  String get unknownLocation => 'Location not known';

  @override
  String get saleTitle => 'Sale Transaction';

  @override
  String get saleScreenTitle => 'Sell';

  @override
  String get fillAllFields => 'Fill All Fields';

  @override
  String get reportsTitle => 'Reports & Analytics';

  @override
  String get noSeasonsFoundForReports =>
      'No seasons found to generate reports. Please add seasons first.';

  @override
  String get season => 'Season';

  @override
  String get duration => 'Duration';

  @override
  String get inventorySummary => 'Inventory Summary';

  @override
  String get financialSummary => 'Summary';

  @override
  String get sacksInStock => 'Sacks In Stock';

  @override
  String get totalWeightInStock => 'Total Weight (In Stock)';

  @override
  String get sacksSold => 'Sacks Sold';

  @override
  String get totalWeightSold => 'Total Weight (Sold)';

  @override
  String get sacksDiscarded => 'Sacks Discarded';

  @override
  String get totalStockValue => 'Total Stock Value (In Stock)';

  @override
  String get notApplicable => 'N/A';

  @override
  String get currentInventoryValue => 'Current Inventory Value:';

  @override
  String get profitTrendBySeason => 'Profit/Loss Trend by Season';

  @override
  String get inventoryStatusBreakdown => 'Inventory Status Breakdown';

  @override
  String get inStockShort => 'In Stock';

  @override
  String get soldShort => 'Sold';

  @override
  String get discardedShort => 'Discarded';

  @override
  String get activeSeason => 'Active Season';

  @override
  String get manageSeasons => 'Manage Seasons';

  @override
  String get noProfitDataAvailable => 'No profit data available for charts.';

  @override
  String get noInventoryDataForCharts =>
      'No inventory data available for charts.';

  @override
  String get searchSacks => 'Search Sacks';

  @override
  String get searchSacksHint => 'Enter code, type, or notes...';

  @override
  String get allProducts => 'All Products';

  @override
  String get allStatuses => 'All Statuses';

  @override
  String get allLocations => 'All Locations';

  @override
  String get productType => 'Product Type';

  @override
  String get status => 'Status';

  @override
  String get location => 'Location';

  @override
  String get resetFilters => 'Reset Filters';

  @override
  String get code => 'Code';

  @override
  String get weight => 'Weight';

  @override
  String get date => 'Date';

  @override
  String get searchParty => 'Search Party';

  @override
  String get searchPartyHint => 'Enter name or phone number...';

  @override
  String get allTypes => 'All Types';

  @override
  String get partyType => 'Party Type';

  @override
  String get confirmDeleteParty =>
      'Are you sure you want to delete this party?';

  @override
  String get partyTypeEmptyValidation => 'Please select a party type.';

  @override
  String get partyNameTypeEmptyValidation =>
      'Party name and type cannot be empty.';

  @override
  String get darkMode => 'Dark Mode';

  @override
  String get currencySymbol => 'Currency Symbol';

  @override
  String get dateFormat => 'Date Format';

  @override
  String get overviewTitle => 'Overview';

  @override
  String get managementTitle => 'Management';

  @override
  String get reportingTitle => 'Reporting';

  @override
  String get totalKgPurchased => 'Total Kg Purchased';

  @override
  String get totalKgSold => 'Total Kg Sold';

  @override
  String get sacksLabel => 'Sacks';

  @override
  String get kgLabel => 'Kg';

  @override
  String get totalSacksInLocation => 'Total Sacks';

  @override
  String get totalQuantityInLocation => 'Total Quantity';

  @override
  String get locationNameEmptyError => 'Location name cannot be empty.';

  @override
  String get cannotDeleteLocationWithSacks =>
      'Cannot delete location with sacks in it. Please move sacks first.';

  @override
  String get currentActiveSeason => 'Current Active Season';

  @override
  String get deactivateCurrentSeason => 'Deactivate Current Season';

  @override
  String get deactivateSeasonSubtitle =>
      'Mark the currently active season as inactive. This will take you to the season list.';

  @override
  String get deactivateSeasonConfirmTitle => 'Confirm Deactivation';

  @override
  String get deactivateSeasonConfirmMessage =>
      'Are you sure you want to deactivate the current season? This action cannot be undone for the current session.';

  @override
  String get deactivateButton => 'Deactivate';

  @override
  String get seasonDeactivatedSuccess =>
      'Current season successfully deactivated.';

  @override
  String get seasonActivatedSuccess => 'Current season successfully activated.';
}
