data storm_summary;
	set pg2.storm_summary(obs=5);
	duration = enddate-startddate;
	putlog "Error: duration = " duration;
	putlog "Warning: " duration=;
	putlog "----------------";
	putlog _all_;
run;

data camping(drop=LodgingOther) lodging(drop=CampTotal);
	set pg2.np_2017;
	CampTotal = sum(CampingOther,CampingTent,CampingRV,CampingBackountry);  /*camptotal = sum(of Camping:, inny argument)  jesli chcemy odddac o ciagu arg*/

	if CampTotal > 0 then
		do;
			output camping;
		end;

	if LodgingOther > 0 then
		do;
			output lodging;
		end;

	keep ParkName Month DayVisits CampTotal LodgingOther;
	format CampTotal comma10.;
run;

data quiz;
	set pg2.class_quiz;
	avgQuiz = mean(of Q:);

	/*	drop Quiz1-Quiz5; */
	/*	format Quiz1-Quiz5 4.1;*/
	/*format _numeric_ 4.1;*/
	format Quiz1--avgQuiz 4.2; /*kolumny od Quiz1 do tej kolumny 2 myslnikki*/
run;

data quiz;
	set pg2.class_quiz;
	putlog "NOTE: przedd rutyna";
	putlog _all_;
	call sortn(of Q:);  /*sortowanie po kolei*/
	putlog "NOTE: po rutyna";
	putlog _all_;

	if mean(of Q:) < 7 then
		call missing(of _all_);
run;

data quiz;
	set pg2.class_quiz;
	quiz1st = largest(1, of quiz1-quiz5);
	quiz2nd = largest(2, of quiz1-quiz5);
	avgBest = mean(quiz1st, quiz2nd);
	studentId = rand('integer', 100, 999);
	avg = round(mean(of quiz1 - quiz5));
run;

***********************************************************;
*  Activity 3.03                                          *;
*  1) Notice that the expressions for WindAvg1 and        *;
*     WindAvg2 are the same. Run the program and examine  *;
*     the output table.                                   *;
*  2) Modify the WindAvg1 expression to use the ROUND     *;
*     function to round values to the nearest tenth (.1). *;
*  3) Add a FORMAT statement to format WindAvg2 with the  *;
*     5.1 format. Run the program. What is the difference *;
*     between using a function and a format?              *;
***********************************************************;
data wind_avg;
	set pg2.storm_top4_wide;
	WindAvg1=roun(mean(of Wind1-Wind4),0.1);
	WindAvg2=mean(of Wind1-Wind4);
run;

***********************************************************;
*  Activity 3.04                                          *;
*  1) Notice that the INTCK function does not include the *;
*     optional method argument, so the default discrete   *;
*     method is used to calculate the number of weekly    *;
*     boundaries (ending each Saturday) between StartDate *;
*     and EndDate.                                        *;
*  2) Run the program and examine rows 8 and 9. Both      *;
*     storms were two days, but why are the values        *;
*     assigned to Weeks different?                        *;
*  3) Add 'c' as the fourth argument in the INTCK         *;
*     function to use the continuous method. Run the      *;
*     program. Are the values for Weeks in rows 8 and 9   *;
*     different?                                          *;
***********************************************************;
*  Syntax Help                                            *;
*     INTCK('interval', start-date, end-date, <'method'>) *;
*         Interval: WEEK, MONTH, YEAR, WEEKDAY, HOUR, etc.*;
*         Method: DISCRETE (D) or CONTINUOUS (C)          *;
***********************************************************;
data storm_length;
	set pg2.storm_final(obs=10);
	keep Season Name StartDate Enddate StormLength Weeks WeeksC;
	Weeks=intck('week', StartDate, EndDate);	/*liczenie niepelnych tygodni*/
	WeeksC=intck('week', StartDate, EndDate, 'c'); /*lcizenie pelnych tygodni*/
run;

data storm_length;
	set pg2.storm_final(obs=10);
	month1Later = intnx("month",endDate, 1, "same"); /*4 paramater poczatek kopniec sroek miesiaca przesuwanie*/
	format month1Later dmmyy10.;
run;

data test;
	data1 = "31jan2012"d;
	data2 = intnx("month", datal, 1, "same");
	format data1 data2 ddmmyy10.;

	***********************************************************;
	*  LESSON 3, PRACTICE 1                                   *;
	*  a) Highlight the PROC PRINT step and run the selected  *;
	*     code. Examine the column names and the 10 rows      *;
	*     printed from the np_lodging table.                  *;
	*  b) Use the LARGEST function to create three new        *;
	*     columns (Stay1, Stay2, and Stay3) whose values are  *;
	*     the first, second, and third highest number of      *;
	*     nights stayed from 2010 through 2017.               *;
	*  c) Use the MEAN function to create a column named      *;
	*     StayAvg that is the average number of nights stayed *;
	*     for the years 2010 through 2017. Use the ROUND      *;
	*     function to round values to the nearest integer.    *;
	*  d) Add a subsetting IF statement to output only rows   *;
	*     with StayAvg greater than zero. Highlight the DATA  *;
	*     step and run the selected code.                     *;
	***********************************************************;
proc print data=pg2.np_lodging(obs=10);
	where CL2010>0;
run;

data stays;
	set pg2.np_lodging;
	Stay1 = Largest(1,of CL:);
	Stay2 = Largest(2,of CL:);
	Stay3 = Largest(3,of CL:);
	StayAvg = round(mean(of CL:));

	if StayAvg > 0 then
		output stays;
	format Stay: comma11.;
	keep Park Stay:;
run;

***********************************************************;
*  LESSON 3, PRACTICE 2                                   *;
*  a) Run the program and notice that each row includes a *;
*     datetime value and rain amount. The                 *;
*     MonthlyRainTotal column represents a cumulative     *;
*     total of Rain for each value of Month.              *;
*  b) Uncomment the subsetting IF statement to continue   *;
*     processing a row only if it is the last row within  *;
*     each month. After the subsetting IF statement,      *;
*     create the following new columns:                   *;
*     1) Date - the date portion of the DateTime column   *;
*     2) MonthEnd - the last day of the month             *;
*  c) Format Date and MonthEnd as a date value and keep   *;
*     only the StationName, MonthlyRainTotal, Date, and   *;
*     MonthEnd columns.                                   *;
***********************************************************;
data rainsummary;
	set pg2.np_hourlyrain;
	by Month; /*powoduje pojawienia sie first i last*/

	if first.Month=1 then
		MonthlyRainTotal=0;
	MonthlyRainTotal+Rain;

	if last.Month=1;
	Date = datepart(DateTime);
	MonthEnd = intnx("month", Date, 0, "end");
	format Date MonthEnd date9.
		keep StationName MonthlyRainTotal Date MonthEnd;
run;

***********************************************************;
*  LESSON 3, PRACTICE 3                                   *;
*  a) The program contains a PROC SORT step that creates  *;
*     the WINTER2015_2016 table. This table contains rows *;
*     with dates with some snowfall between October 1,    *;
*     2015, and June 1, 2016, sorted by Code and Date.    *;
*     Only the Name, Code, Date, and Snow columns are     *;
*     kept.                                               *;
*  b) Modify the DATA step to create the SNOWFORECAST     *;
*     table based on the following specifications:        *;
*     1) Process the data in groups by Code.              *;
*     2) For the first row within each Code group, create *;
*        a new column named FirstSnow that is the date of *;
*        the first snowfall for that code.                *;
*     3) For the last row within each Code group, do the  *;
*        following:                                       *;
*        a) Create a new column named LastSnow that is    *;
*           the date of the last snowfall for that code.  *;
*        b) Create a new column named WinterLengthWeeks   *;
*           that counts the number of full weeks between  *;
*           the FirstSnow and LastSnow dates.             *;
*        c) Create a new column named ProjectedFirstSnow  *;
*           that is the same day of the first snowfall    *;
*           for the next year.                            *;
*        d) Output the row to the new table.              *;
*     4) Apply the DATE7. format to the FirstSnow,        *;
*        LastSnow, and ProjectedFirstSnow columns and     *;
*        drop the Date and Snow columns.                  *;
***********************************************************;
proc sort data=pg2.np_weather(keep=Name Code Date Snow)
	out=winter2015_2016;
	where date between '01Oct15'd and '01Jun16'd and Snow > 0;
	by Code Date;
run;
data snowforecast;
	set winter2015_2016;
	by Code;
	retain FirstSnow LastSnow;

	if first.code=1 then
		FirstSnow=Date;

	if last.code=1 then
		do;
			LastSnow=Date;
			WinterLengthWeeks = intck("week",FirstSnow, LastSnow, "c");
			ProjectedFirstWeeks = intnx("year",FirstSnow, 1, "same");
			output;
		end;

	format FirstSnow LastSnow ProjectedFirstWeeks date9.;
run;

***********************************************************;
*  Activity 3.06                                          *;
*  1) Complete the NewLocation assignment statement to    *;
*     use the COMPBL function to read Location and        *;
*     convert each occurrence of two or more consecutive  *;
*     blanks into a single blank.                         *;
*  2) Complete the NewStation assignment to use the       *;
*     COMPRESS function with Station as the only          *;
*     argument. Run the program. Which characters are     *;
*     removed in the NewStation column?                   *;
*  3) Add a second argument in the COMPRESS function to   *;
*     remove both the space and hyphen. Both characters   *;
*     should be enclosed in a single set of quotation     *;
*     marks. Run the program.                             *;
***********************************************************;
*  Syntax Help                                            *;
*     COMPBL(string)                                      *;
*     COMPRESS (string <, characters>)                    *;
***********************************************************;

data weather_japan_clean;
    set pg2.weather_japan;
    NewLocation= compbl(location);
    NewStation= compress(Station, "- "); /*usuwa 2 znaki spacje i myslnik*/
	City = strip(scan(NewLocation,2,",")); /*usuwa strip niepotrzebne znaki ktore wystapily*/
	Prefecture = propcase(scan(NewLocation,2,","));
run;

***********************************************************;
*  Activity 3.08                                          *;
*  1) Notice that the assignment statement for            *;
*     CategoryLoc uses the FIND function to search for    *;
*     category within each value of the Summary column.   *;
*     Run the program.                                    *;
*  2) Examine the PROC PRINT report. Why is CategoryLoc   *;
*     equal to 0 in row 1? Why is CategoryLoc equal to 0  *;
*     in row 15?                                          *;
*  3) Modify the FIND function to make the search case    *;
*     insensitive. Uncomment the IF-THEN statement to     *;
*     create a new column named Category. Run the program *;
*     and examine the results.                            *;
***********************************************************;
*  Syntax Help                                            *;	
*     FIND(string, substring <, 'modifiers'>)             *;
*         Modifiers:                                      *;
*             'I'=case insensitive search                 *;
*             'T'=trim leading and training blanks from   *;
*			     string and substring                     *;
***********************************************************;

data storm_damage2;
	set pg2.storm_damage;
	drop Date Cost;
	CategoryLoc=find(Summary, 'category',"e"); /*find jest case sensitive*/
	if CategoryLoc > 0 then Category=substr(Summary,CategoryLoc, 10);
run;

proc print data=storm_damage2;
	var Event Summary Cat:;
run;


data test;
	a = "ala ";
	call missing(a); /*modyfikuje argum na braki danych*/
	l1 = length(a); /*usuwa spacje na koncu*/
	l2 = lengthc(a); /*zwraca calkowita dlugosc razem ze spacjami*/
	l3 = lengthn(a); 
	
run;

data test;
	length imie imie2 nazwisko $20;
	imie = "Kasia";
	imie2 = "Barbara";
	nazwisko = "Kowalska";
	fullname = cat(imie, imie2, nazwisko);
	fullname2 = imie !! imie2 || nazwisko; /*inne laczenie tekstu*/
	fullname3 = catx(" ",imie, imie2, nazwisko);
run;

***********************************************************;
*  LESSON 3, PRACTICE 5                                   *;
*  a) Notice that the DATA step creates a table named     *;
*     PARKS and reads only those rows where ParkName ends *;
*     with NP.                                            *;
*  b) Modify the DATA step to create or modify the        *;
*     following columns:                                  *;
*     1) Use the SUBSTR function to create a new column   *;
*        named Park that reads each ParkName value and    *;
*        excludes the NP code at the end of the string.   *;
*        Note: Use the FIND function to identify the      *;
*        position number of the NP string. That value can *;
*        be used as the third argument of the SUBSTR      *;
*        function to specify how many characters to read. *;
*     2) Convert the Location column to proper case. Use  *;
*        the COMPBL function to remove any extra blanks   *;
*        between words.                                   *;
*     3) Use the TRANWRD function to create a new column  *;
*        named Gate that reads Location and converts the  *;
*        string Traffic Count At to a blank.              *;
*     4) Create a new column names GateCode that          *;
*        concatenates ParkCode and Gate together with a   *;
*        single hyphen between the strings.               *;
***********************************************************;

data parks;
	set pg2.np_monthlytraffic;
	where ParkName like '%NP';
	Park = substr(ParkName,1,find(ParkName,"NP") - 1);
	Location = compbl(propcase(Location));
	Gate = tranwrd(Location,Count," ");
	GateCode = catx("-",ParkCode, Gate);

run;

proc print data=parks;
	var Park GateCode Month Count;
run;
***********************************************************;
*  LESSON 3, PRACTICE 6                                   *;
*  a) Run the program. Notice that the Column1 column     *;
*     contains raw data with values separated by various  *;
*     symbols. The SCAN function is used to extract the   *;
*     ParkCode and ParkName values.                       *;
*  b) Examine the PROC CONTENTS report. Notice that       *;
*     ParkCode and ParkName have a length of 200, which   *;
*     is the same as Column1.                             *;
*     Note: When the SCAN function creates a new column,  *;
*     the new column will have the same length as the     *;
*     column listed as the first argument.                *;
*  c) The ParkCode column should include only the first   *;
*     four characters in the string. Add a LENGTH         *;
*     statement to define the length of ParkCode as 4.    *;
*  d) The length for the ParkName column can be optimized *;
*     by determining the longest string and setting an    *;
*     appropriate length. Modify the DATA step to create  *;
*     a new column named NameLength that uses the LENGTH  *;
*     function to return the position of the last         *;
*     non-blank character for each value of ParkName.     *;
*  e) Use a RETAIN statement to create a new column named *;
*     MaxLength that has an initial value of zero.        *;
*  f) Use an assignment statement and the MAX function to *;
*     set the value of MaxLength to either the current    *;
*     value of NameLength or MaxLength, whichever is      *;
*     larger.                                             *;
*  g) Use the END= option in the SET statement to create  *;
*     a temporary variable in the PDV named LastRow.      *;
*     LastRow will be zero for all rows until the last    *;
*     row of the table, when it will be 1. Add an IF-THEN *;
*     statement to write the value of MaxLength to the    *;
*     log if the value of LastRow is 1.                   *;
***********************************************************;

data parklookup;
	set pg2.np_unstructured_codes end=Lastrow;  /*end=LastRow przyjmuje 0 do momentu keidy osiagnie osatni wiersz wtedy przyjmuje 1*/

	length ParkCode $4;
	ParkCode=scan(Column1, 2, '{}:,"()-'); /*akceptowany przyjmowany separator*/
	ParkName=scan(Column1, 4, '{}:,"()');
	NameLength = LENGTH(ParkName);
	retain MaxLength 0;
	MaxLength = max(MaxLength, NameLength); /*83 wyszlo wiec mozna ustawic ParkName 83*/
	if Lastrow = 1 then
		putlog "MaxLength = " MaxLength ;
run;

proc print data=parklookup(obs=10);
run;

proc contents data=parklookup;
run;


data stock2;
	set pg2.stocks2 (rename = (date=date_old high=high_old volume=volume_old));
	Date = input(date_old, date9.);
	High = input(high_old, best12.); /*best ma wartosc domyslna 12 lub po prostu 12.*/
	volume = input(volume_old, comma12.);
	format Date ddmmyy10. Volume nlnum12.;
	drop date_old high_old volume_old;
run;


data stocks3;
	set stocks2;

	value_zl = put(Volume, nlmny15.2) /*m od money w zlotówkach*/
run;


****************************************************************;
*  Concatenating Tables                                        *;
****************************************************************;
*  Syntax and Example                                          *;
*                                                              *;
*    DATA output-table;                          	           *;
*        SET input-table1(rename=(current-colname=new-colname))*;
*            input-table2 ...;                                 *;
*    RUN;                                                      *;
****************************************************************;

*Example with all matching columns;
data class_current;
	set sashelp.class pg2.class_new;
run;

*Example with columns having different names;
data class_current;
	set sashelp.class pg2.class_new2(rename=(Student=Name));
run;

***********************************************************;
*  Demo                                                   *;
*  1) Modify the SET statement to concatenate             *;
*     PG2.STORM_SUMMARY and PG2.STORM_2017. Highlight the *;
*     DATA and PROC SORT steps and run the selected code. *;
*  2) Notice that for the 2017 storms Year is populated   *;
*     with 2017, Location has values, and Season is       *;
*     missing. Rows from the storm_summary table          *;
*     (starting with row 55) have Season populated and    *;
*     Year and Location are missing.                      *;
*  3) After PG2.STORM_2017, use the RENAME= data set      *;
*     option to rename Year as Season. Use the DROP= data *;
*     set option to drop Location. Highlight the demo     *;
*     program and run the selected code.                  *;
***********************************************************;

data storm_complete;
	*Complete the SET statement;
	set   ; 
	Basin=upcase(Basin);
run;

proc sort data=storm_complete;
	by descending StartDate;
run;

/*
1. Skopiuje dadne z SASHELP.class do work.class
2. DDolacze dane z pg2.classs_new do work.class
*/

proc copy in=sashelp out=work;
	select class; /*opcjonalnie zamiast select mozna uzyc exclude czyli skopiju poza wymienionymim*/
run;

data class;
	length name $9;
	set sashelp.class;
run;

proc append base=class data=pg2.class_new;		/*w proc mozna zlaczyc tylko 2, w set mozna wiele*/
run;

proc append base=class data=pg2.class_new2(rename=(student=name); /*poprawianie bledów*/		
run;	

data np_join_class;
	set pg2.np_2014 pg2.np_2015 pg2.np_2016;
/*	by Month;*/
	if ParkType = "National Park" then
		output;
	
run;

proc sort data=np_join_class out= np_join_sort;
	by ParkType, ParkCode, Year;
run;

proc copy in=pg2 out=work;
	select np_2014;
run;

proc append base=np_2014(rename=(park=Park_code type=park_type)) data=pg2.np_2015;
run;

data klasa ;
	if 0 then do;
		set sashelp.class;
		output;
	end;
run;


data clas_grades;
	merge sashelp.class(in=c) pg2.class_teachers(in=t);
	by name; /*odwolanie do klucza*/
	if c = 1 and t = 1;
		output;

run;