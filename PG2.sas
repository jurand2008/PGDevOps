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