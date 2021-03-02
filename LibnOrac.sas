data dane.customer_dim;
	set dane.customer_dim;
	drop Customer_Gender Customer_FirstName;
run;

libname dane '/opt/sas/Workshop/data';
proc copy in=test2 out=dane noclone;
run;

libname oralib oracle path=orcl schema=student user=student password=xxx;
