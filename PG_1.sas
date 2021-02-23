data suv_upto_30000;
	set SASHELP.cars;
	where Type EQ "SUV" AND MSRP LT 30000;
run;

/*Użycie formatów*/

data class_bd;
	set PG1.class_birthdate;
	format Birthdate ddmmyyd10.;
	where birthdate >=  "01sep2005"d;
run;

proc sort data=class_bd out=class_bd_srt;
	by age DESCENDING Height;
run;

proc sort data=pg1.class_test3 out=class_test3_clean nodupkey dupout=class_test3_dups;
/*	by name Subject TestScore;*/
	by _all_;
run;


data class_bd;
	set PG1.class_birthdate;
	format Birthdate ddmmyyd10.;
	where birthdate >=  "01sep2005"d;
	drop age;
run;

/*Drop jako opcja zbioru*/
data class_bd;
	set PG1.class_birthdate(drop=age);
	format Birthdate ddmmyyd10.;
	where birthdate >=  "01sep2005"d;
	drop age;
run;

data cars_avg;
	format mpg_mean 5.2;
	set sashelp.cars;
	mpg_mean = mean(mpg_city, mpg_highway);

run;

data storm_avg;
	set pg1.storm_range;
	windAvg = mean(of wind1-wind4);
run;

/*Zadanie 4-28*/

data np_summary2;
	keep Reg Type ParkName ParkType ;
	set pg1.np_summary;
	ParkType=scan(ParkName,-1);
run;

data np_summary_update;
	set pg1.np_summary;
	keep Reg ParkName DayVisits OtherLodging Acres SqMiles Camping;	
	*Add assignment statements;
	SqMiles = Acres * 0.0015625;
	Camping = SUM(OtherCamping, TentCampers, RVCampers,BackcountryCampers);
	format SqMiles Camping comma10.0;
run;
data eu_occ_total;
	keep Country Hotel ShortStay Camp ReportDate Total Year Mon yearmon;
	set pg1.eu_occ;
/*	konwersja z tekstu na liczbe : funkcja input*/
/*	konwersja z liczby na tekst : funkcja put*/
	Year = input(substr(yearmon,1,4),4.);
	Mon = input(substr(yearmon,6,2),2.);
	ReportDate = MDY(Mon,1,Year);
	Total = sum(Camp,Hotel, ShortStay);
	format ReportDate monyy7. Hotel Camp Shortstay Total comma15.;
	

run;
