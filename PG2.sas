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
	
	if CampTotal > 0 then do;
		output camping;
	end; 
	if LodgingOther > 0 then do;
		output lodging;
	end; 
		keep ParkName Month DayVisits CampTotal LodgingOther;
		format CampTotal comma10.;
run;