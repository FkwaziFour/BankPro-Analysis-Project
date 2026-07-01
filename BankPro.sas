/* Phase 1 - Environment Setup */
/* Create a permanent library called FINANCE */
libname FINANCE "/home/u64443627/myfolders/Finance";

/* Inspect library using proc contents */
proc contents data=FINANCE._all_;
run;

/*Phase 2*/

/*import Customers sheet*/
proc import datafile ="/home/u64443627/myfolders/financial_project_dataset.xlsx"
out = FINANCE.customers
dbms = xlsx replace;
sheet= "Customers";
getnames=yes;
Run;

/*import Accounts sheet*/
proc import datafile ="/home/u64443627/myfolders/financial_project_dataset.xlsx"
out = FINANCE.accounts
dbms = xlsx replace;
sheet= "Accounts";
getnames=yes;
Run;

/*import Transactions sheet*/
proc import datafile ="/home/u64443627/myfolders/financial_project_dataset.xlsx"
out = FINANCE.transactions
dbms = xlsx replace;
sheet= "Transactions";
getnames=yes;
Run;

/*import MonthlySummary sheet*/
proc import datafile ="/home/u64443627/myfolders/financial_project_dataset.xlsx"
out = FINANCE.monthsummary
dbms = xlsx replace;
sheet= "MonthlySummary";
getnames=yes;
Run;

/*convert date columns into sas date format*/
data FINANCE.accounts;
set FINANCE.accounts (rename = (OpenDate = CharOpenDate));
OpenDate = input(CharOpenDate, yymmdd10.);
format OpenDate yymmdd10.;
	drop CharOpenDate;
Run;

/*convert date columns into sas date format*/
data FINANCE.transactions;
set FINANCE.transactions (rename = (TransDate = CharTransDate));
TransDate = input(CharTransDate, yymmdd10.);
format TransDate yymmdd10.;
	drop CharTransDate;
Run;

/*convert date columns into sas date format*/
data FINANCE.customers;
set FINANCE.customers (rename = (JoinDate = CharJoinDate));
JoinDate = input(CharJoinDate, yymmdd10.);
format JoinDate yymmdd10.;
	drop CharJoinDate;;
Run;

/*Test using datalines*/

data FINANCE.sample_accounts;
input AccountID $ CustID $ AccountType $ Balance InterestRate OpenDate :yymmdd10.;
format OpenDate yymmdd10.;
datalines;
1A 1B Savings 300 4.2 2026-01-21
2A 2B Investement 56000 5.6 2026-01-26
3A 3B Loan 7800 7.2 2026-01-31
;

run;

/*phase 3*/
/*Create account status variable*/

data FINANCE.accounts_clean;
	set FINANCE.accounts;
	if Balance < 0 then AccountStatus = "Overdrawn";
	else if Balance = 0 then AccountStatus = "Zero balance";
	else AccountStatus = "Active";

run;

/*identify negetive balances*/

proc print data = finance.accounts_clean;
	where Balance < 0;
	title "Accounts with Negative Balances";
 run;
 
/*loan accounts*/
data FINANCE.loan_accounts;
	set Finance.accounts_clean;
	where AccountType = "Loan";
run;

/*value classificaton*/

data FINANCE.accounts_segmented;
    set FINANCE.accounts_clean;
    if Balance >= 100000 then ValueSegment = "Platinum";
    else if Balance >= 50000 then ValueSegment = "Gold";
    else if Balance >= 10000 then ValueSegment = "Silver";
    else ValueSegment = "Bronze";
run;

	
/*phase 4*/	
/* Custom segment format */

proc format;
    value $segfmt
        "Platinum" = "VIP Clients"
        "Gold" = "High Value Clients"
        "Silver" = "Standard Value Clients"
        "Bronze" = "Low Value Clients";
run;

/* Apply format to accounts_segmented */
data FINANCE.accounts_segmented_fmt;
    set FINANCE.accounts_segmented;
    format ValueSegment $segfmt.;
run;

proc print data=FINANCE.accounts_segmented_fmt;
    title "Accounts with Segment Format Applied";
run;

/* Apply format to customers */
data FINANCE.customers_clean;
    set FINANCE.customers;
    format Segment $segfmt.;
run;

/* Assign labels to variables in accounts */
proc datasets library=FINANCE;
    modify accounts_clean;
    label AccountID = "Account Identifier"
          Balance = "Current Balance"
          CustID = "Customer Identifier"
          AccountType = "Account Type"
          OpenDate = "Account Opening Date"  
          InterestRate = "Interest Rate"
          AccountStatus = "Account's Current Status";
    format Balance dollar12.2; /* Apply currency format */
quit;

/* Assign labels to variables in customers */
proc datasets library=FINANCE;
    modify customers_clean;
    label CustID = "Customer Identifier"  
          FirstName = "Customer's First Name"
          LastName = "Customer's Last Name"
          Gender = "Customer's Gender"
          City = "Customer's Location"
          Segment = "Customer Classification"
          JoinDate = "Customer Joining Date";
quit;	

/*phase 5*/

/*
• Combine names
• Extract initials
• Standardize text
*/

data FINANCE.customers_text;
    set FINANCE.customers_clean;

    FullName = catx(' ', FirstName, LastName);
    Initials = cats(substr(FirstName,1,1), substr(LastName,1,1));

    StandardName = propcase(FullName);

run;

proc print data = FINANCE.customers_text;
run;

/*
• Round balances
• Generate random values
*/
data FINANCE.accounts_rounded;
 set FINANCE.accounts_clean;
 
	RoundedValue = round(Balance, 100);
	RandomScore = rand("Uniform") * 100;
	format RoundedValue dollar12. RandomScore 6.2;
run;

proc print data=FINANCE.accounts_rounded;
    title "Accounts with Rounded Balances and Random Scores";
run;

/*phase 6
• Extract year and month
• Calculate customer tenure
• Calculate account age
• Analyze transaction timing
*/

data FINANCE.accounts_dates;
    set FINANCE.accounts_clean;
    
    Year = year(OpenDate);
    Month = month(OpenDate);
    TenureDays = today() - OpenDate;  /* CORRECTED: OpenDate not Opendate */
    TenureYears = TenureDays / 365.25;  /* Use 365.25 for leap years */
    AccountAgeYears = yrdif(OpenDate, today(), "AGE");
    
    format TenureYears AccountAgeYears 6.2;
run;

proc print data=FINANCE.accounts_dates(obs=10);
    title "Account Date Analytics";
run;

data FINANCE.transactions_clean;
    set FINANCE.transactions;
    
    /* Extract date parts */
    Trans_Year = year(TransDate);
    Trans_Month = month(TransDate);
    Trans_Day = day(TransDate);
    Trans_DOW = weekday(TransDate);
    
    format TransDate yymmdd10.;
run;

proc print data=FINANCE.transactions_clean(obs=10);
    title "Transaction Date Analytics";
run;

/* Transactions by month */
proc freq data=FINANCE.transactions_clean;
    tables Trans_Month;
    title "Transactions by Month";
run;

/* Day of the week */
proc freq data=FINANCE.transactions_clean;
    tables Trans_DOW;
    title "Transactions by Day of Week";
run;

/* By Year */
proc freq data=FINANCE.transactions_clean;
    tables Trans_Year;
    title "Transactions by Year";
run;

proc sort data=FINANCE.transactions_clean;
    by AccountID TransDate;
run;

data FINANCE.transaction_gaps;
    set FINANCE.transactions_clean;
    by AccountID;
    
    PrevDate = lag(TransDate);
    
    if first.AccountID then Gap_Days = .;
    else Gap_Days = TransDate - PrevDate;  /* days between transactions */
run;

proc means data=FINANCE.transaction_gaps mean min max n;
    var Gap_Days;
    class AccountID;
    title "Average Days Between Transactions";
run;

/*
phase 7
• Simulate 12‑month balance growth
• Create projection dataset

here we start by creating the projection dataset then proceed to simulate the 12 month balance
*/

data FINANCE.accounts_balance_projection;
    set FINANCE.accounts_clean;
    where Balance > 0 and AccountType ne "Loan";  /* Exclude negative and loan balances */
    
    /* Store initial balance */
    InitialBalance = Balance;
    
    /* Set growth rate to interest rate */
    GrowthRate = InterestRate;
    MonthlyInterest = (GrowthRate/100)/12;
    
    /* Project for 12 months */
    do Month = 0 to 12;  /* Include month 0 as starting point */
        if Month = 0 then ProjectedBalance = Balance;
        else ProjectedBalance = ProjectedBalance * (1 + MonthlyInterest);
        
        output;
    end;
    
    keep AccountID CustID AccountType InitialBalance InterestRate 
         Month ProjectedBalance;
    format ProjectedBalance dollar12.2;
run;

proc print data=FINANCE.accounts_balance_projection(obs=20);
    where Month > 0;
    title "12-Month Balance Projection";
run;


/* Phase 8 – Array Processing of Monthly Balances */
/* Phase 8 - Arrays */

data FINANCE.monthly_stats;
    set FINANCE.monthsummary;
    
    /* Array for 6 months */
    array M{6} Jan Feb Mar Apr May Jun;
    
    /* Total and average */
    Total = sum(of M{*});
    Average = mean(of M{*});
    
    /* Get best & worst month values */
    BestMonthValue = max(of M{*});
    WorstMonthValue = min(of M{*});
    
    /* Find the index (1-6) of best & worst months */
    do i = 1 to 6;
        if M{i} = BestMonthValue then BestMonthIndex = i;
        if M{i} = WorstMonthValue then WorstMonthIndex = i;
    end;
    
    /* Convert index to month text */
    length BestMonth $10 WorstMonth $10;
    BestMonth = scan("Jan Feb Mar Apr May Jun", BestMonthIndex);
    WorstMonth = scan("Jan Feb Mar Apr May Jun", WorstMonthIndex);
    
    /* Volatility (Range) */
    Range = BestMonthValue - WorstMonthValue;
    
    drop i;
    format Total Average BestMonthValue WorstMonthValue Range comma12.2;
run;

proc print data=FINANCE.monthly_stats;
    title "Monthly Balance Statistics";
run;	

/* Phase 9 - Merging Data */


proc sort data=FINANCE.customers_clean;
    by CustID;
run;

proc sort data=FINANCE.accounts_clean;
    by CustID;
run;

/* Merge customers and accounts */
data FINANCE.customer_accounts;
    merge FINANCE.customers_clean (in=a)
          FINANCE.accounts_clean (in=b);
    by CustID;
    if a and b;  /* Inner join */
run;

/* Sort transactions by AccountID */
proc sort data=FINANCE.transactions_clean;
    by AccountID;
run;

/* Merge with transactions */
data FINANCE.master;
    merge FINANCE.customer_accounts (in=a)
          FINANCE.transactions_clean (in=b);
    by AccountID;
    if a;  /* Keep all customer-account records, with or without transactions */
run;

proc print data=FINANCE.master(obs=20);
    title "Master Dataset (First 20 Observations)";
run;

/*phase 10*/
/* Wide → Long */
proc transpose data=FINANCE.monthsummary
               out=FINANCE.monthlong
               name=Month;
    by AccountID;
    var Jan--Jun;
run;

/* Long → Wide */
proc transpose data=FINANCE.monthlong
               out=FINANCE.monthwide
               prefix=M;
    by AccountID;
    id Month;
    var COL1;
run;

/* Phase 11 - Statistical Analysis */

/* Sort data */
proc sort data=FINANCE.master out=FINANCE.Master_Sorted;
    by CustID AccountID TransDate;
run;

/* Summary statistics */
proc means data=FINANCE.Master_Sorted n mean median min max std maxdec=2;
    class AccountType;
    var Balance Amount;
    title "Summary Statistics by Account Type";
run;

/* Frequency analysis */
proc freq data=FINANCE.Master_Sorted;
    tables Segment AccountType / nocum;
    title "Frequency Distribution of Segments and Account Types";
run;

/* Descriptive distributions */
proc univariate data=FINANCE.Master_Sorted;
    var Balance Amount;
    histogram Balance / normal;
    histogram Amount / normal;
    inset mean median min max std / position=ne;
    title "Descriptive Statistics for Balances and Transaction Amounts";
run;

/* Tabular report */
proc tabulate data=FINANCE.Master_Sorted;
    class Segment AccountType;
    var Balance;
    table Segment,
          AccountType * Balance * (mean min max);
    title "Tabular Financial Report by Segment and Account Type";
run;

/* Report layout */
proc report data=FINANCE.Master_Sorted nowd;
    column CustID AccountID AccountType Balance Amount Segment;
    define CustID / group "Customer ID";
    define AccountID / group "Account ID";
    define AccountType / display "Account Type";
    define Balance / analysis mean "Avg Balance" format=dollar12.2;
    define Amount / analysis mean "Avg Transaction Amount" format=dollar12.2;
    define Segment / display "Customer Segment";
    title "Customer Financial Summary Report";
run;

/* Phase 12 - Professional Reporting */
/* Generate PDF report */

ods pdf file="/home/u64443627/myfolders/Finance/BankPro_Analysis_Report.pdf"
        style=journal;

title "BankPro Financial Services - Comprehensive Analysis Report";
title2 "Generated on &sysdate";

/* Executive Summary */
proc print data=FINANCE.Accounts(obs=10) noobs label;
    var AccountID AccountType Balance InterestRate;
    sum Balance;
    label 
        AccountID = "Account ID"
        AccountType = "Account Type"
        Balance = "Balance ($)"
        InterestRate = "Interest Rate (%)";
    title3 "Sample Account Overview (First 10 Records)";
run;
/* Customer Segment Analysis */
proc freq data=FINANCE.Customers;
    tables CustID FirstName LastName Segment Gender;
    title3 "Customer Demographics";
run;

/* Account Type Distribution */
proc freq data=FINANCE.Accounts;
    tables AccountType / nocum;
    title3 "Account Type Distribution";
run;



/* Monthly Balance Analysis */
proc print data=FINANCE. monthly_stats noobs label;
    var AccountID Total Average BestMonth WorstMonth;
    sum Total;
    label
        AccountID = "Account ID"
        Total = "Total Balance"
        Average = "Average Monthly Balance"
        BestMonth = "Best Performing Month"
        WorstMonth = "Worst Performing Month";
    title3 "Monthly Balance Analysis";
run;

ods pdf close;

/* Create Excel management report */
ods excel file="/home/u64443627/myfolders/Finance/BankPro_management_Report.xlsx"
          options(sheet_interval="proc"
                  sheet_name="Account Summary"
                  frozen_headers="yes");

/* Account Summary Sheet */
proc report data=FINANCE.Accounts_clean nowd;
    column AccountID AccountType Balance InterestRate AccountStatus;
    
    define AccountID / group "Account Identifier";
    define AccountType / group "Account Type";
    define Balance / group "Total Balance" format=dollar12.2;
    define InterestRate / group "Avg Interest Rate(%)" format=percent8.2;
    compute InterestRate;    
       call define(_col_, 'format', '8.2');
    endcomp;
     define AccountStatus / group "Account Status";
    title "Account Summary by ID";
run;

/* Customer Overview Sheet */
ods excel options(sheet_name="Customer Overview");
proc report data=FINANCE.Customers_clean nowd;
    column CustID FirstName LastName Segment Gender City JoinDate;
    
    define CustID / group "Customer ID";
    define FirstName / group "Name(s)";
    define LastName / group "Surname";
    define Segment / group "Customer Segment";
    define Gender / group "Gender";
    define City / group "City";
    define JoinDate/ group "Joining Date";
    title "Customer Overview";
run;

/* Transaction Analysis Sheet */
ods excel options(sheet_name="Transaction Analysis");
proc report data=FINANCE.Transactions_clean nowd;
    column TransID TransType TransDate Channel Amount;
    
    define TransID / group "Transaction Identifier";
    define TransType / group "Transaction Type";
    define TransDate / group "Transaction Date";
    define Channel / group "Channel";
    define Amount / analysis sum "Total Amount" format=dollar12.2;
    title "Transaction Analysis";
run;

ods excel close;


/* Phase 14 - Automation with Macros */

%macro SummaryReport(dataset, classvar, numvar);
    title "Summary Report: &numvar by &classvar";
    proc means data=&dataset mean min max std maxdec=2;
        class &classvar;
        var &numvar;
    run;
%mend SummaryReport;

/* Run macro examples */
%SummaryReport(FINANCE.Master_Sorted, AccountType, Balance);
%SummaryReport(FINANCE.Master_Sorted, Segment, Amount);


/*phase 15*/
proc sql;
    create table FINANCE.sql_summary as
    select Segment,
           AccountType,
           count(*) as AccountCount,
           avg(Balance) as AvgBalance format=dollar12.2,
           sum(Balance) as TotalBalance format=dollar12.2,
           min(Balance) as MinBalance format=dollar12.2,
           max(Balance) as MaxBalance format=dollar12.2
    from FINANCE.master
    group by Segment, AccountType
    order by Segment, AccountType;
quit;

proc print data=FINANCE.sql_summary;
    title "SQL Summary by Segment and Account Type";
run;