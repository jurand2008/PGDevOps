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

/*wyrazenia warunkkowe*/

data cars_categories;
	set sashelp.cars;
	length car_category $12;
	if MSRP <= 30000 then do;
		num_category=1;
		car_category="basic";
	end;
	else if MSRP <= 60000 then do;
		num_category=2;
		car_category="premium";
	end;
	else do;
		num_category=3;
		car_category="luxury";
	end;
run;

data basic premium luxury;
	set sashelp.cars;
	length car_category $12;
	if MSRP <= 30000 then do;
		num_category=1;
		car_category="basic";
		output basic;
	end;
	else if MSRP <= 60000 then do;
		num_category=2;
		car_category="premium";
		output premium;
	end;
	else do;
		num_category=3;
		car_category="luxury";
		output luxury;
	end;
run;

/*zadanie 4.46*/

***********************************************************;
*  LESSON 4, PRACTICE 7                                   *;
*    a) Submit the program and view the generated output. *;
*    b) In the DATA step, use IF-THEN/ELSE statements to  *;
*       create a new column, ParkType, based on the value *;
*       of Type.                                          *;
*       NM -> Monument                                    *;
*       NP -> Park                                        *;
*       NPRE, PRE, or PRESERVE -> Preserve                *;
*       NS -> Seashore                                    *;
*       RVR or RIVERWAYS -> River                         *;
*    c) Modify the PROC FREQ step to generate a frequency *;
*       report for ParkType.                              *;
***********************************************************;

data park_type;
	set pg1.np_summary;
	
	if Type="NM" then do;
		ParkType = "Monument";
	end;
	else if Type="NP" then do;
		ParkType = "Park";
	end;
	else if Type="NPRE" or Type="PRE" or Type="PRESERVE" then do;
		ParkType = "Preserve";
	end;
	else if Type="NS" then do;
		ParkType = "Seashore";
	end;
	else if Type="RVR" or Type="RIVERWAYS" then do;
		ParkType = "River";
	end;


run;

proc freq data=park_type;
	tables Type;
run;

data parks monuments;
	set pg1.np_summary;
	length ParkType $8;

	Campers = sum(TentCampers, RVCampers, BackcountryCampers);
	format Campers comma.;
	keep Reg ParkName DdayVisits OtherLodging Campers ParkType;
	if Type="NP" then do;
		ParkType = "Park";
		output parks;
	end;
	else if Type="NM" then do;
		ParkType = "Monument";
		output monuments;
	end;

run;


data parks monuments;
	set pg1.np_summary;
	length ParkType $8;

	Campers = sum(TentCampers, RVCampers, BackcountryCampers);
	format Campers comma.;
	keep Reg ParkName DdayVisits OtherLodging Campers ParkType;
	select;  /* lub select(Type) i wtedy when("NP) itd*/
		when(Type="NP") do; 
			ParkType = "Park";
			output parks;
		end;
		when(Type="NM") do;
			ParkType = "Monument";
			output monuments;
		end;
		otherwise;	
	end;

run;

proc sql;
	select Name, Age, Height
	from pg1.class_birthday;
quit;

***********************************************************;
*  Activity 7.02                                          *;
*    1) Complete the SQL query to display Event and Cost  *;
*       from PG1.STORM_DAMAGE. Format the values of Cost. *;
*    2) Add a new column named Season that extracts the   *;
*       year from Date.                                   *;
*    3) Add a WHERE clause to return rows where Cost is   *;
*       greater than 25 billion.                          *;
*    4) Add an ORDER BY clause to arrange rows by         *;
*       descending Cost. Which storm had the highest      *;
*       cost?                                             *;
***********************************************************;
*  Syntax                                                 *;
*    PROC SQL;                                            *;
*        SELECT col-name, col-name FORMAT=fmt             *;
*        FROM input-table                                 *;
*        WHERE expression                                 *;
*        ORDER BY col-name <DESC>;                        *;
*    QUIT;                                                *;
*                                                         *;
*    New column in SELECT list:                           *;
*    expression AS col-name                               *;
***********************************************************;

title "Most Costly Storms";
proc sql number /*instr liczeniwa wierszy*/;
	select Event, Cost format=dollar20., year(date) as Season  /*laczenie sasa i sql*/
	from PG1.STORM_DAMAGE
	where Cost > 25000000000
	order by Cost desc;
quit;
title;

title "Most Costly Storms";
proc sql number /*instr liczeniwa wierszy*/;
	create table storm_damage as
	select Event, Cost format=dollar20., year(date) as Season  /*laczenie sasa i sql*/
	from PG1.STORM_DAMAGE
	where Cost > 25000000000
	order by Cost desc;
quit;
title;


/*laczenie danych w sql*/
proc sql;
	create table class_grade as
	select u.name, u.sex, u.age, t.teacher, t.grade
		from pg1.class_teachers t 
			inner join pg1.class_update u
		on t.name = u.name;
quit;

proc sql;
	
	select coalesce(u.name,t.name)as name, u.sex, u.age, t.teacher, t.grade
		from pg1.class_teachers t 
			full join pg1.class_update u
		on t.name = u.name;
quit;
