/*IMport csv Files */
%let path = /opt/sas/Workshop/danePGDevOps/LWPG1V2/data_old;

libname np_park xlsx "&path/np_info.xlsx";

data parks;
	set np_park.visits(obs=10);
run;

libname np_park clear;

proc import file="&path/np_info.xlsx" out=tab1 dbms=xlsx; /*domyslnie importuje 1 tabele*/
run;