data storm_summary;
	set pg2.storm_summary;
	duration = end_date-start_date;
	put
run;