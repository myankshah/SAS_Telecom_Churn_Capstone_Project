/*Importing the Telecom dataset*/
libname tele "D:\Users\Jig11117\Graded Assignments\Topic 13-Final Case Study";


proc import 
datafile = "Z:\Assignments\Graded Assignment\Topic 13 - Final Case Study Implementation\telecomfinal.csv"
out = tele.telecom dbms = csv replace;
getnames = yes;
run;

proc contents data = tele.telecom varnum;
run;



/*Checking Missing values of all Numeric variables*/
proc means n nmiss mean data = tele.telecom;
run;

/*Checking Missing values of all String variables*/
proc freq data = tele.telecom;
tables income	crclscod	asl_flag	prizm_social_one	area	refurb_new	hnd_webcap	marital	ethnic	dwlltype	dwllsize	mailordr	occu1	numbcars	retdays	wrkwoman	solflag	proptype	mailresp	cartype	car_buy	children	csa	div_type;
run;



/*We have chosen 'churn' as our target variable; checking 0's and 1's freq*/
proc freq data = tele.telecom;
tables churn;
run;



/*Treating missing values: Deleting values = 'NA' from variables 
whose missing value % is <2%*/
data tele.telecom1;
set tele.telecom;
if mou_mean = . or totmrc_Mean = . or rev_Range = . or mou_Range = . or
change_mou = . or ovrrev_Mean = . or rev_Mean=. or	ovrmou_Mean=. or	age1=. or	age2=. or
hnd_price=. or 	forgntvl=. or 	mtrcycle=. or 	truck=. or 	roam_Mean=. or 
da_Mean=. or da_Range=. or datovr_Mean=. or datovr_Range=. then delete ;
run;

/*Imputing mean to income,retdays,avg6mou,avg6qty*/
data tele.telecom2;
set tele.telecom1;
income1 = input(income,10.);
retdays1 = input(retdays,5.);
run;


data tele.telecom3(drop = income retdays);
set tele.telecom2;
run;

data tele.telecom4;
set tele.telecom3;
rename income1=income retdays1=retdays;
run;


data tele.telecom5;
set tele.telecom4;
test=1;
run;

proc means mean data = tele.telecom5;
var avg6mou avg6qty income retdays;
output out  = tele.telecom5_mean mean(avg6mou) = mean_avg6mou mean(avg6qty)=mean_avg6qty
mean(income) = mean_income mean(retdays) = mean_retdays;
run;

data tele.telecom5_mean(drop = _TYPE_ _FREQ_);
set tele.telecom5_mean;
test =1;
run;

data tele.telecom_merge;
merge tele.telecom5 tele.telecom5_mean ;
by test;
run;

data tele.telecom_merge1;
set tele.telecom_merge;
if avg6mou=. then avg6mou_1 = round(mean_avg6mou,0.01);
else avg6mou_1 = avg6mou;
if avg6qty =. then avg6qty_1 = round(mean_avg6qty,0.01);
else avg6qty_1 = avg6qty;
if income = . then income_1 = round(mean_income,0.01);
else income_1 = income;
if retdays = . then retdays_1 = round(mean_retdays,0.01);
else retdays_1 = retdays;
run;

data tele.telecom_merge2(drop = avg6qty avg6mou test mean_avg6qty mean_avg6mou income retdays mean_income mean_retdays);
set tele.telecom_merge1;
run;

data tele.telecom_merge3;
set tele.telecom_merge2;
rename income_1 = income retdays_1 = retdays avg6mou_1 =avg6mou avg6qty_1=avg6qty;
run;
proc means n nmiss data = tele.telecom_merge3;
run;
proc freq data =tele.telecom_merge3;
tables income	crclscod	asl_flag	prizm_social_one	area	refurb_new	hnd_webcap	marital	ethnic	dwlltype	dwllsize	mailordr	occu1	numbcars	retdays	wrkwoman	solflag	proptype	mailresp	cartype	car_buy	children	csa	div_type;
run;


/*Taking backup*/
data tele.telecom_backup1;
set tele.telecom_merge3;
run;





/*Data Preparation : Dummy Variables*/
*1.crclscod;
data tele.telecom_dummy;
set tele.telecom_backup1;
if substr(crclscod,1,1) = "A" or substr(crclscod,1,1) = "B" or substr(crclscod,1,1) = "C" or substr(crclscod,1,1) = "D" or substr(crclscod,1,1) = "E"
then best_crclscod = 1; else best_crclscod = 0;
if substr(crclscod,1,1) = "F" or substr(crclscod,1,1) = "G" or substr(crclscod,1,1) = "H" or substr(crclscod,1,1) = "I" or substr(crclscod,1,1) = "J"
then good_crclscod = 1; else good_crclscod = 0;
if substr(crclscod,1,1) = "K" or substr(crclscod,1,1) = "L" or substr(crclscod,1,1) = "M" or substr(crclscod,1,1) = "N" or substr(crclscod,1,1) = "O"
then average_crclscod = 1; else average_crclscod = 0;
if substr(crclscod,1,1) = "P" or substr(crclscod,1,1) = "Q" or substr(crclscod,1,1) = "R" or substr(crclscod,1,1) = "S" or substr(crclscod,1,1) = "T"
then bad_crclscod = 1; else bad_crclscod = 0;
if substr(crclscod,1,1) = "U" or substr(crclscod,1,1) = "V" or substr(crclscod,1,1) = "W" or substr(crclscod,1,1) = "X" or substr(crclscod,1,1) = "Y"
or substr(crclscod,1,1) = "Z" then worst_crclscod = 1; else worst_crclscod = 0;
*run;

*2.asl_flag;
if asl_flag = 'Y' then asl_flag_yes = 1;
else asl_flag_yes = 0;
if asl_flag = 'N' then asl_flag_no = 1;
else asl_flag_no = 1;
*run;

*3.prizm_social_one;
if prizm_social_one = 'C' then area_city = 1;
else area_city = 0;
if prizm_social_one = 'R' then area_rural = 1;
else area_rural = 0;
if prizm_social_one = 'S' then area_suburban = 1;
else area_suburban = 0;
if prizm_social_one = 'T' then area_town = 1;
else area_town = 0;
if prizm_social_one = 'U' then area_urban = 1;
else area_urban = 0;
if prizm_social_one = 'NA' then area_unknown = 1;
else area_unknown = 0;
*run;

*4.refurb_new;
if refurb_new = 'N' then handset_new = 1;
else handset_new =0;
if refurb_new = 'R' then handset_refurb = 1;
else handset_refurb = 0;
*run;

*5.hnd_webcap;
if hnd_webcap = 'WC' then handset_wc = 1;
else handset_wc = 0;
if hnd_webcap = 'WCMB' then handset_wcmb = 1;
else handset_wcmb = 0;
if hnd_webcap = 'NA' then handset_na = 1;
else handset_na = 0;
if hnd_webcap = 'UNKW' then handset_unkw = 1;
else handset_unkw = 0;
*run;

*6.marital;
if marital = 'M' then status_married = 1;
else status_married = 0;
if  marital = 'A' then status_infermarried =1;
else status_infermarried =0;
if marital = 'B' then status_infersingle =1;
else status_infersingle =0;
if marital = 'S' or marital = 'B' then status_single = 1;
else status_single = 0;
if marital = 'U' then status_unknown = 1;
else status_unknown = 0;
*run;

*7.dwlltype;
if index(dwlltype,'M')>0 then dwell_multiple = 1;
else dwell_multiple = 1;
if index(dwlltype,'S')>0 then dwell_single = 1;
else dwell_single = 1;
if index(dwlltype,'NA')>0 then dwell_unknown = 1;
else dwell_unknown = 1;

*8.dwllsize;
if index(dwllsize,'A') > 0 then dsize_1 = 1;
else dsize_1 = 0;
if index(dwllsize,'B') > 0 then dsize_2 = 1;
else dsize_2 = 0;
if index(dwllsize,'C') > 0 then dsize_3 = 1;
else dsize_3 = 0;
if index(dwllsize,'D') > 0 then dsize_4 = 1;
else dsize_4 = 0;
if index(dwllsize,'E') > 0 then dsize_5 = 1;
else dsize_5 = 0;
if index(dwllsize,'F') > 0 then dsize_6 = 1;
else dsize_6 = 0;
if index(dwllsize,'G') > 0 then dsize_7 = 1;
else dsize_7 = 0;
if index(dwllsize,'H') > 0 then dsize_8 = 1;
else dsize_8 = 0;
if index(dwllsize,'I') > 0 then dsize_9 = 1;
else dsize_9 = 0;
if index(dwllsize,'J') > 0 then dsize_10to19 = 1;
else dsize_10to19 = 0;
if index(dwllsize,'K') > 0 then dsize_20to29 = 1;
else dsize_20to29 = 0;
if index(dwllsize,'L') > 0 then dsize_30to39 = 1;
else dsize_30to39 = 0;
if index(dwllsize,'M') > 0 then dsize_40to49 = 1;
else dsize_40to49 = 0;
if index(dwllsize,'N') > 0 then dsize_50to99 = 1;
else dsize_50to99 = 0;
if index(dwllsize,'O') > 0 then dsize_100 = 1;
else dsize_100 = 0;
if index(dwllsize,'NA') > 0 then dsize_unknown = 1;
else dsize_unknown = 0;

*9.mailordr;
if index(mailordr,'B')>0 then mailorder_buyer = 1;
else mailorder_buyer = 0;
if index(mailordr,'NA')>0 then mailorder_unknown = 1;
else mailorder_unknown = 0;

*10.occu1;
if index(occu1,'1')>0 then occu_technical = 1;
else occu_technical = 0;
if index(occu1,'2')>0 then occu_admin = 1;
else occu_admin = 0;
if index(occu1,'3')>0 then occu_sales = 1;
else occu_sales = 0;
if index(occu1,'4')>0 then occu_wc = 1;
else occu_wc = 0;
if index(occu1,'5')>0 then occu_bc = 1;
else occu_bc = 0;
if index(occu1,'6')>0 then occu_student = 1;
else occu_student = 0;
if index(occu1,'7')>0 then occu_homemaker = 1;
else occu_homemaker = 0;
if index(occu1,'8')>0 then occu_retires = 1;
else occu_retires = 0;
if index(occu1,'9')>0 then occu_farmer = 1;
else occu_farmer = 0;
if index(occu1,'A')>0 then occu_military = 1;
else occu_military = 0;
if index(occu1,'B')>0 then occu_religious = 1;
else occu_religious = 0;
if index(occu1,'C')>0 or index(occu1,'D')>0 or index(occu1,'E')>0 or
index(occu1,'F')>0 or index(occu1,'G')>0 or index(occu1,'H')>0 or
index(occu1,'I')>0 or index(occu1,'J')>0 or index(occu1,'K')>0
then occu_selfemp = 1;else occu_selfemp = 0;
*run;

*11.numbcars;
if index(numbcars,'1')>0 then numcars_1 = 1;
else numcars_1 = 0;
if index(numbcars,'2')>0 then numcars_2 = 1;
else numcars_2 = 0;
if index(numbcars,'3')>0 then numcars_3 = 1;
else numcars_3 = 0;
if index(numbcars,'NA')>0 then numcars_unknown = 1;
else numcars_unknown = 0;

*12.wrkwoman;
if index(wrkwoman,'Y')>0 then wrkwoman_yes = 1;
else wrkwoman_yes = 0;
if index(wrkwoman,'NA')>0 then wrkwoman_unknown = 1;
else wrkwoman_unknown = 0;

*13.solflag;
if index(solflag,'Y')>0 then solflag_yes =1;
else solflag_yes = 0;
if index(solflag,'N')>0 then solflag_no =1;
else solflag_no = 0;
if index(solflag,'NA')>0 then solflag_default =1;
else solflag_default = 0;

*14.proptype;
if index(proptype,'A')>0 then proptype_a = 1;
else proptype_a = 0;
if index(proptype,'B')>0 then proptype_b = 1;
else proptype_b = 0;
if index(proptype,'D')>0 then proptype_d = 1;
else proptype_d = 0;
if index(proptype,'E')>0 then proptype_e = 1;
else proptype_e = 0;
if index(proptype,'G')>0 then proptype_g = 1;
else proptype_g = 0;
if index(proptype,'M')>0 then proptype_m = 1;
else proptype_m = 0;
if index(proptype,'NA')>0 then proptype_unknown = 1;
else proptype_unknown = 0;

*15.mailresp;
if index(mailresp,'R')>0 then mailresp_yes=1;
else mailresp_yes = 0;
if index(mailresp,'NA')>0 then mailresp_unknown=1;
else mailresp_unknown = 0;

*16.cartype;
if index(cartype,'A')>0 then cartype_luxury = 1;
else cartype_luxury = 0;
if index(cartype,'B')>0 then cartype_truck = 1;
else cartype_truck = 0;
if index(cartype,'C')>0 then cartype_SUV = 1;
else cartype_SUV = 0;
if index(cartype,'D')>0 then cartype_minivan = 1;
else cartype_minivan = 0;
if index(cartype,'E')>0 then cartype_regular = 1;
else cartype_regular = 0;
if index(cartype,'F')>0 then cartype_upper = 1;
else cartype_upper = 0;
if index(cartype,'G')>0 then cartype_basic = 1;
else cartype_basic = 0;
if index(cartype,'NA')>0 then cartype_unknown = 1;
else cartype_unknown = 0;

*17.div_type;
if index(div_type,'BTH')>0 then division_bth = 1;
else division_bth = 0;
if index(div_type,'LDD')>0 then division_LDD = 1;
else division_LDD = 0;
if index(div_type,'LTD')>0 then division_LTD = 1;
else division_LTD = 0;
if index(div_type,'NA')>0 then division_unknown = 1;
else division_unknown = 0;
*run;

*18.ethnic;
if index(ethnic,'B')>0 then ethnic_asian_nor = 1;
else ethnic_asian_nor = 0;
if index(ethnic,'D')>0 then ethnic_south_euro = 1;
else ethnic_south_euro = 0;
if index(ethnic,'F')>0 then ethnic_french = 1;
else ethnic_french = 0;
if index(ethnic,'G')>0 then ethnic_german = 1;
else ethnic_german = 0;
if index(ethnic,'H')>0 then ethnic_hispanic = 1;
else ethnic_hispanic = 0;
if index(ethnic,'I')>0 then ethnic_italian = 1;
else ethnic_italian = 0;
if index(ethnic,'J')>0 then ethnic_jewish = 1;
else ethnic_jewish = 0;
if index(ethnic,'M')>0 then ethnic_misc = 1;
else ethnic_misc = 0;
if index(ethnic,'N')>0 then ethnic_north_euro = 1;
else ethnic_north_euro = 0;
if index(ethnic,'O')>0 then ethnic_asian = 1;
else ethnic_asian = 0;
if index(ethnic,'P')>0 then ethnic_polynesia = 1;
else ethnic_polynesia = 0;
if index(ethnic,'R')>0 then ethnic_arab = 1;
else ethnic_arab = 0;
if index(ethnic,'S')>0 then ethnic_scot_iris = 1;
else ethnic_scot_iris = 0;
if index(ethnic,'U')>0 or index(ethnic,'NA')then ethnic_unknown = 1;
else ethnic_unknown = 0;
if index(ethnic,'Z')>0 then ethnic_afro_amer = 1;
else ethnic_afro_amer = 0;
*run;

/*19.children*/
if index(children,'Y')>0 then children_yes = 1;
else children_yes= 0;
if index(children,'N')>0 then children_no = 1;
else children_no= 0;
if index(children,'NA')>0 then children_unknown = 1;
else children_unknown= 0;
*run;

*20.car_buy;
if index(car_buy,'NEW')>0 then car_buy_new = 1;
else car_buy_new=0;
if index(car_buy,'UNKNOWN')>0 or index(car_buy,'NA') then car_buy_unknown = 1;
else car_buy_unknown=0;
*run;

*21.Area;
if index(area,'ATLANTIC SOUTH AREA')>0 then area_atlantic = 1;
else area_atlantic = 0;
if index(area,'CALIFORNIA NORTH AREA')>0 then area_cali = 1;
else area_cali = 0;
if index(area,'CENTRAL/SOUTH TEXAS AREA')>0 then area_texas = 1;
else area_texas = 0;
if index(area,'CHICAGO AREA')>0 then area_chicago = 1;
else area_chicago = 0;
if index(area,'DALLAS AREA')>0 then area_dallas = 1;
else area_dallas = 0;
if index(area,'DC/MARYLAND/VIRGINIA AREA')>0 then area_dcmvir = 1;
else area_dcmvir = 0;
if index(area,'GREAT LAKES AREA')>0 then area_gla = 1;
else area_gla = 0;
if index(area,'HOUSTON AREA')>0 then area_houston = 1;
else area_houston = 0;
if index(area,'LOS ANGELES AREA')>0 then area_la = 1;
else area_la = 0;
if index(area,'MIDWEST AREA')>0 then area_mdwest = 1;
else area_mdwest = 0;
if index(area,'NA')>0 then area_unknown = 1;
else area_unknown = 0;
if index(area,'NEW ENGLAND AREA')>0 then area_neweng = 1;
else area_neweng = 0;
if index(area,'NEW YORK CITY AREA')>0 then area_nyc = 1;
else area_nyc = 0;
if index(area,'NORTH FLORIDA AREA')>0 then area_nfl = 1;
else area_nfl = 0;
if index(area,'NORTHWEST/ROCKY MOUNTAIN AREA')>0 then area_nrocky = 1;
else area_nrocky = 0;
if index(area,'OHIO AREA')>0 then area_ohio = 1;
else area_ohio = 0;
if index(area,'PHILADELPHIA AREA')>0 then area_phily = 1;
else area_phily = 0;
if index(area,'SOUTH FLORIDA AREA')>0 then area_sfl = 1;
else area_sfl = 0;
if index(area,'SOUTHWEST AREA')>0 then area_swest = 1;
else area_swest = 0;
if index(area,'TENNESSEE AREA')>0 then area_tenese = 1;
else area_tenese = 0;
*run;

*22.csa;	
if substr(csa,1,1) = "A" or substr(csa,1,1) = "B" or substr(csa,1,1) = "C" or substr(csa,1,1) = "D"
or substr(csa,1,1) = "F" or substr(csa,1,1) = "G" then csa_city1 = 1;
else csa_city1 = 0;
if substr(csa,1,1) = "H" or substr(csa,1,1) = "I" or substr(csa,1,1) = "K"
or substr(csa,1,1) = "L" or substr(csa,1,1) = "M" then csa_city2 = 1;
else csa_city2 = 0;
if substr(csa,1,1) = "N" or substr(csa,1,1) = "O" or substr(csa,1,1) = "P" or substr(csa,1,1) = "S"
or substr(csa,1,1) = "V" then csa_city3 = 1;
else csa_city3 = 0;
run;





data tele.telecom_backp2;
set tele.telecom_dummy;
run;


data tele.telcom_backup3(drop = crclscod	asl_flag	prizm_social_one	refurb_new	hnd_webcap	marital	ethnic	dwlltype	dwllsize	mailordr	occu1	numbcars	wrkwoman	solflag	proptype	mailresp	cartype	car_buy	children	div_type area csa);
set tele.telecom_backp2;
run;



proc means n nmiss data = tele.telcom_backup3;
run;
/*proc freq data =tele.telecom_merge3;
tables income	crclscod	asl_flag	prizm_social_one	area	refurb_new	hnd_webcap	marital	ethnic	dwlltype	dwllsize	mailordr	occu1	numbcars	retdays	wrkwoman	solflag	proptype	mailresp	cartype	car_buy	children	csa	div_type;
run;*/


/*outlier detection for variables:
actvsubs
adjmou
adjqty
adjrev
age1
age2
avg3mou
avg3qty
avg6mou
avg6qty
avgmou
avgqty
avgrev
callwait_Mean
callwait_Range
ccrndmou_Range
change_mou
comp_vce_Mean
custcare_Mean
da_Mean
da_Range
datovr_Mean
datovr_Range
drop_blk_Mean
drop_dat_Mean
drop_vce_Mean
drop_vce_Range
eqpdays
iwylis_vce_Mean
months
mou_mean
mou_opkv_Range
mou_pead_Mean
mou_Range
opk_dat_Mean
ovrmou_Mean
ovrrev_Mean
owylis_vce_Range
plcd_vce_Mean
recv_sms_Mean
rev_Mean
rev_Range
roam_Mean
totcalls
totmrc_mean
totrev
uniqsubs
blck_dat_Mean
*/
proc univariate data = tele.telcom_backup3;
var mou_mean;
output out=percentile1_99 pctlpts=99.9 pctlpre=percentile;
run;
/*Above 99.9 percentile values to be deleted i.e. 3765*/
data tele.telecom_out;
set tele.telcom_backup3;
if mou_mean ge 3765 then delete;
run;

proc univariate data = tele.telecom_out;
var totmrc_mean;
output out=percentile2_99 pctlpts=99.9 pctlpre=percentile;
run;
/*Above 99.9 percentile values to be deleted i.e. 189.99*/
data tele.telecom_out;
set tele.telecom_out;
if totmrc_mean > 189.99 then delete;
run;

proc univariate data = tele.telecom_out;
var rev_Range;
output out=percentile3_99 pctlpts=99.9 pctlpre=percentile;
run;
/*Above 99.9 percentile values to be deleted i.e. 671.05*/
data tele.telecom_out;
set tele.telecom_out;
if rev_Range > 671.05 then delete;
run;

proc univariate data = tele.telecom_out;
var mou_Range;
output out=percentile4_99 pctlpts=99.9 pctlpre=percentile;
run;
/*Above 99.9 percentile values to be deleted i.e. 3317*/
data tele.telecom_out;
set tele.telecom_out;
if mou_Range >3317 then delete;
run;

proc univariate data = tele.telecom_out;
var change_mou;
output out=percentile5_99 pctlpts=99.9 pctlpre=percentile;
run;
/*Above 99.9 percentile values to be deleted i.e. 1387.25*/
data tele.telecom_out;
set tele.telecom_out;
if change_mou >1387.25 then delete;
run;

proc univariate data = tele.telecom_out;
var drop_blk_Mean;
output out=percentile6_99 pctlpts=99.9 pctlpre=percentile;
run;
/*Above 99.9 percentile values to be deleted i.e. 157*/
data tele.telecom_out;
set tele.telecom_out;
if drop_blk_Mean >157 then delete;
run;

proc univariate data = tele.telecom_out;
var drop_vce_Range;
output out=percentile7_99 pctlpts=99.9 pctlpre=percentile;
run;
/*Above 99.9 percentile values to be deleted i.e. 79*/
data tele.telecom_out;
set tele.telecom_out;
if drop_vce_Range >79 then delete;
run;

proc univariate data = tele.telecom_out;
var owylis_vce_Range;
output out=percentile8_99 pctlpts=99.9 pctlpre=percentile;
run;
/*Above 99.9 percentile values to be deleted i.e. 214*/
data tele.telecom_out;
set tele.telecom_out;
if owylis_vce_Range >214 then delete;
run;

proc univariate data = tele.telecom_out;
var mou_opkv_Range;
output out=percentile9_99 pctlpts=99.9 pctlpre=percentile;
run;
/*Above 99.9 percentile values to be deleted i.e. 1505.12*/
data tele.telecom_out;
set tele.telecom_out;
if mou_opkv_Range >1505.12 then delete;
run;

proc univariate data = tele.telecom_out;
var months;
output out=percentile10_99 pctlpts=99.9 pctlpre=percentile;
run;
/*Above 99.9 percentile values to be deleted i.e. 58*/
data tele.telecom_out;
set tele.telecom_out;
if months>58 then delete;
run;

proc univariate data = tele.telecom_out;
var totcalls;
output out=percentile11_99 pctlpts=99.9 pctlpre=percentile;
run;
/*Above 99.9 percentile values to be deleted i.e. 39755*/
data tele.telecom_out;
set tele.telecom_out;
if totcalls>39755 then delete;
run;

proc univariate data = tele.telecom_out;
var eqpdays;
output out=percentile12_99 pctlpts=99.9 pctlpre=percentile;
run;
/*Above 99.9 percentile values to be deleted i.e. 1506*/
data tele.telecom_out;
set tele.telecom_out;
if eqpdays>1506 then delete;
if eqpdays <= 0 then delete;
run;

proc univariate data = tele.telecom_out;
var custcare_Mean;
output out=percentile13_99 pctlpts=99.9 pctlpre=percentile;
run;
/*Above 99.9 percentile values to be deleted i.e. 47.33333333*/
data tele.telecom_out;
set tele.telecom_out;
if custcare_Mean>47.33333333 then delete;
run;


proc univariate data = tele.telecom_out;
var callwait_Mean;
output out=percentile14_99 pctlpts=99.9 pctlpre=percentile;
run;
/*Above 99.9 percentile values to be deleted i.e. 48.66666667*/
data tele.telecom_out;
set tele.telecom_out;
if callwait_Mean>48.66666667 then delete;
run;

proc univariate data = tele.telecom_out;
var iwylis_vce_Mean;
output out=percentile15_99 pctlpts=99.9 pctlpre=percentile;
run;
/*Above 99.9 percentile values to be deleted i.e.137*/
data tele.telecom_out;
set tele.telecom_out;
if iwylis_vce_Mean>137 then delete;
run;

proc univariate data = tele.telecom_out;
var callwait_Range;
output out=percentile16_99 pctlpts=99.9 pctlpre=percentile;
run;
/*Above 99.9 percentile values to be deleted i.e.36*/
data tele.telecom_out;
set tele.telecom_out;
if callwait_Range>36 then delete;
run;

proc univariate data = tele.telecom_out;
var ccrndmou_Range;
output out=percentile17_99 pctlpts=99.9 pctlpre=percentile;
run;
/*Above 99.9 percentile values to be deleted i.e.171*/
data tele.telecom_out;
set tele.telecom_out;
if ccrndmou_Range>171 then delete;
run;

proc univariate data = tele.telecom_out;
var adjqty;
output out=percentile18_99 pctlpts=99.9 pctlpre=percentile;
run;
/*Above 99.9 percentile values to be deleted i.e.31034*/
data tele.telecom_out;
set tele.telecom_out;
if adjqty>31034 then delete;
run;

proc univariate data = tele.telecom_out;
var ovrrev_Mean;
output out=percentile19_99 pctlpts=99.9 pctlpre=percentile;
run;
/*Above 99.9 percentile values to be deleted i.e.245.35*/
data tele.telecom_out;
set tele.telecom_out;
if ovrrev_Mean>245.35 then delete;
run;

proc univariate data = tele.telecom_out;
var rev_Mean;
output out=percentile20_99 pctlpts=99.9 pctlpre=percentile;
run;
/*Above 99.9 percentile values to be deleted i.e.322.38*/
data tele.telecom_out;
set tele.telecom_out;
if rev_Mean>322.38 then delete;
run;

proc univariate data = tele.telecom_out;
var ovrmou_Mean;
output out=percentile21_99 pctlpts=99.9 pctlpre=percentile;
run;
/*Above 99.9 percentile values to be deleted i.e.701*/
data tele.telecom_out;
set tele.telecom_out;
if ovrmou_Mean>701 then delete;
run;

proc univariate data = tele.telecom_out;
var comp_vce_Mean;
output out=percentile22_99 pctlpts=99.9 pctlpre=percentile;
run;
/*Above 99.9 percentile values to be deleted i.e.878*/
data tele.telecom_out;
set tele.telecom_out;
if comp_vce_Mean>878 then delete;
run;

proc univariate data = tele.telecom_out;
var plcd_vce_Mean;
output out=percentile23_99 pctlpts=99.9 pctlpre=percentile;
run;
/*Above 99.9 percentile values to be deleted i.e.1040*/
data tele.telecom_out;
set tele.telecom_out;
if plcd_vce_Mean>1040 then delete;
run;

proc univariate data = tele.telecom_out;
var avg3mou;
output out=percentile24_99 pctlpts=99.9 pctlpre=percentile;
run;
/*Above 99.9 percentile values to be deleted i.e.3273*/
data tele.telecom_out;
set tele.telecom_out;
if avg3mou>3273 then delete;
run;

proc univariate data = tele.telecom_out;
var avgmou;
output out=percentile25_99 pctlpts=99.9 pctlpre=percentile;
run;
/*Above 99.9 percentile values to be deleted i.e.2694*/
data tele.telecom_out;
set tele.telecom_out;
if avgmou>2694 then delete;
run;

proc univariate data = tele.telecom_out;
var avg3qty;
output out=percentile26_99 pctlpts=99.9 pctlpre=percentile;
run;
/*Above 99.9 percentile values to be deleted i.e.2694*/
data tele.telecom_out;
set tele.telecom_out;
if avg3qty>2694 then delete;
run;

proc univariate data = tele.telecom_out;
var avgqty;
output out=percentile27_99 pctlpts=99.9 pctlpre=percentile;
run;
/*Above 99.9 percentile values to be deleted i.e.1191*/
data tele.telecom_out;
set tele.telecom_out;
if avgqty>1191 then delete;
run;

proc univariate data = tele.telecom_out;
var actvsubs;
output out=percentile28_99 pctlpts=99.9 pctlpre=percentile;
run;
/*Above 99.9 percentile values to be deleted i.e.5*/
data tele.telecom_out;
set tele.telecom_out;
if actvsubs>5 then delete;
run;


proc univariate data = tele.telecom_out;
var uniqsubs;
output out=percentile29_99 pctlpts=99.9 pctlpre=percentile;
run;
/*Above 99.9 percentile values to be deleted i.e.7*/
data tele.telecom_out;
set tele.telecom_out;
if uniqsubs>7 then delete;
run;

proc univariate data = tele.telecom_out;
var opk_dat_Mean;
output out=percentile30_99 pctlpts=99.9 pctlpre=percentile;
run;
/*Above 99.9 percentile values to be deleted i.e.59*/
data tele.telecom_out;
set tele.telecom_out;
if opk_dat_Mean>59 then delete;
run;

proc univariate data = tele.telecom_out;
var roam_Mean;
output out=percentile31_99 pctlpts=99.9 pctlpre=percentile;
run;
/*Above 99.9 percentile values to be deleted i.e.76*/
data tele.telecom_out;
set tele.telecom_out;
if roam_Mean>76 then delete;
run;

proc univariate data = tele.telecom_out;
var recv_sms_Mean;
output out=percentile32_99 pctlpts=99.9 pctlpre=percentile;
run;
/*Above 99.9 percentile values to be deleted i.e.9*/
data tele.telecom_out;
set tele.telecom_out;
if recv_sms_Mean>9 then delete;
run;

proc univariate data = tele.telecom_out;
var mou_pead_Mean;
output out=percentile33_99 pctlpts=99.9 pctlpre=percentile;
run;
/*Above 99.9 percentile values to be deleted i.e.82*/
data tele.telecom_out;
set tele.telecom_out;
if mou_pead_Mean>82 then delete;
run;

proc univariate data = tele.telecom_out;
var da_Mean;
output out=percentile34_99 pctlpts=99.9 pctlpre=percentile;
run;
/*Above 99.9 percentile values to be deleted i.e.19*/
data tele.telecom_out;
set tele.telecom_out;
if da_Mean>19 then delete;
run;

proc univariate data = tele.telecom_out;
var da_Range;
output out=percentile35_99 pctlpts=99.9 pctlpre=percentile;
run;
/*Above 99.9 percentile values to be deleted i.e.22*/
data tele.telecom_out;
set tele.telecom_out;
if da_Range>22 then delete;
run;

proc univariate data = tele.telecom_out;
var datovr_Mean;
output out=percentile36_99 pctlpts=99.9 pctlpre=percentile;
run;
/*Above 99.9 percentile values to be deleted i.e.24*/
data tele.telecom_out;
set tele.telecom_out;
if datovr_Mean>24 then delete;
run;

proc univariate data = tele.telecom_out;
var datovr_Range ;
output out=percentile37_99 pctlpts=99.9 pctlpre=percentile;
run;
/*Above 99.9 percentile values to be deleted i.e.46*/
data tele.telecom_out;
set tele.telecom_out;
if datovr_Range>46 then delete;
run;

proc univariate data = tele.telecom_out;
var drop_dat_Mean;
output out=percentile38_99 pctlpts=99.9 pctlpre=percentile;
run;
/*Above 99.9 percentile values to be deleted i.e.4*/
data tele.telecom_out;
set tele.telecom_out;
if drop_dat_Mean>4 then delete;
run;

proc univariate data = tele.telecom_out;
var drop_vce_Mean;
output out=percentile39_99 pctlpts=99.9 pctlpre=percentile;
run;
/*Above 99.9 percentile values to be deleted i.e.77*/
data tele.telecom_out;
set tele.telecom_out;
if drop_vce_Mean>77 then delete;
run;

proc univariate data = tele.telecom_out;
var adjmou;
output out=percentile40_99 pctlpts=99.9 pctlpre=percentile;
run;
/*Above 99.9 percentile values to be deleted i.e.75256*/
data tele.telecom_out;
set tele.telecom_out;
if adjmou>75256 then delete;
run;

proc univariate data = tele.telecom_out;
var totrev;
output out=percentile41_99 pctlpts=99.9 pctlpre=percentile;
run;
/*Above 99.9 percentile values to be deleted i.e.6687*/
data tele.telecom_out;
set tele.telecom_out;
if totrev>6687 then delete;
run;

proc univariate data = tele.telecom_out;
var adjrev;
output out=percentile42_99 pctlpts=99.9 pctlpre=percentile;
run;
/*Above 99.9 percentile values to be deleted i.e.5739*/
data tele.telecom_out;
set tele.telecom_out;
if adjrev>5739 then delete;
run;

proc univariate data = tele.telecom_out;
var avgrev;
output out=percentile43_99 pctlpts=99.9 pctlpre=percentile;
run;
/*Above 99.9 percentile values to be deleted i.e.246*/
data tele.telecom_out;
set tele.telecom_out;
if avgrev>246 then delete;
run;

proc univariate data = tele.telecom_out;
var avg6mou;
output out=percentile44_99 pctlpts=99.9 pctlpre=percentile;
run;
/*Above 99.9 percentile values to be deleted i.e.2648*/
data tele.telecom_out;
set tele.telecom_out;
if avg6mou>2648 then delete;
run;

proc univariate data = tele.telecom_out;
var avg6qty;
output out=percentile45_99 pctlpts=99.9 pctlpre=percentile;
run;
/*Above 99.9 percentile values to be deleted i.e.1055*/
data tele.telecom_out;
set tele.telecom_out;
if avg6qty>1055 then delete;
run;

proc univariate data = tele.telecom_out;
var blck_dat_Mean;
output out=percentile46_99 pctlpts=99.9 pctlpre=percentile;
run;
/*Above 99.9 percentile values to be deleted i.e.2*/
data tele.telecom_out;
set tele.telecom_out;
if blck_dat_Mean>2 then delete;
run;

/*Outliers detection in age1 and age2*/
proc univariate data = tele.telecom_out;
var age1;
output out=percentile47_99 pctlpts=99.9 pctlpre=percentile;
run;
/*Above 99.9 percentile values to be deleted i.e.86*/
data tele.telecom_out;
set tele.telecom_out;
if age1>86 then delete;
run;
/*Imputing age1=0 with mean of age1 i.e.31*/ 
data tele.telecom_out1;
set tele.telecom_out;
if age1 = 0 then age1 = 31;
run;
proc univariate data = tele.telecom_out;
var age2;
output out=percentile48_99 pctlpts=99.9 pctlpre=percentile;
run;
/*Above 99.9 percentile values to be deleted i.e.90*/
data tele.telecom_out;
set tele.telecom_out;
if age2>90 then delete;
run;
data tele.telecom_out2;
set tele.telecom_out1;
if age2 = 0 then age2 = 21;
run;

proc means n nmiss min max mean data= tele.telecom_out2;
var age1 age2 income;
run;


proc contents data = tele.telecom_out2 varnum;
run;



proc freq data = tele.telecom_dummy;
tables area csa;
run;
/*No missing values in area and csa*/

/*******************************************************************************************************
**********************************************End of Data Preparation***********************************
********************************************************************************************************/












/*******************************************************************************************************
************************************************Start of Modelling**************************************
********************************************************************************************************/



/*Partitioning data into Development and Validation Dataset*/
data tele.development tele.validation;
set tele.telecom_out2;
if ranuni (100) <0.70 then output tele.development;
else output tele.validation;
run;

proc freq data = tele.development;
tables churn;
run;

proc freq data = tele.validation;
tables churn;
run;


/*Running Logistic Regression: Iteration 1*/
proc logistic data = tele.development descending;
model churn = 
actvsubs
adjmou
adjqty
adjrev
age1
age2
area_atlantic
area_cali
area_chicago
area_city
area_dallas
area_dcmvir
area_gla
area_houston
area_la
area_mdwest
area_neweng
area_nfl
area_nrocky
area_nyc
area_ohio
area_phily
area_rural
area_sfl
area_suburban
area_swest
area_tenese
area_texas
area_town
area_unknown
area_urban
asl_flag_no
asl_flag_yes
average_crclscod
avg3mou
avg3qty
avg6mou
avg6qty
avgmou
avgqty
avgrev
bad_crclscod
best_crclscod
blck_dat_Mean
callwait_Mean
callwait_Range
car_buy_new
car_buy_unknown
cartype_basic
cartype_luxury
cartype_minivan
cartype_regular
cartype_SUV
cartype_truck
cartype_unknown
cartype_upper
ccrndmou_Range
change_mou
children_no
children_unknown
children_yes
comp_vce_Mean
csa_city1
csa_city2
csa_city3
custcare_Mean
da_Mean
da_Range
datovr_Mean
datovr_Range
division_bth
division_LDD
division_LTD
division_unknown
drop_blk_Mean
drop_dat_Mean
drop_vce_Mean
drop_vce_Range
dsize_1
dsize_100
dsize_10to19
dsize_2
dsize_20to29
dsize_3
dsize_30to39
dsize_4
dsize_40to49
dsize_5
dsize_50to99
dsize_6
dsize_7
dsize_8
dsize_9
dsize_unknown
dwell_multiple
dwell_single
dwell_unknown
eqpdays
ethnic_afro_amer
ethnic_arab
ethnic_asian
ethnic_asian_nor
ethnic_french
ethnic_german
ethnic_hispanic
ethnic_italian
ethnic_jewish
ethnic_misc
ethnic_north_euro
ethnic_polynesia
ethnic_scot_iris
ethnic_south_euro
ethnic_unknown
forgntvl
good_crclscod
handset_na
handset_new
handset_refurb
handset_unkw
handset_wc
handset_wcmb
hnd_price
income
iwylis_vce_Mean
mailorder_buyer
mailorder_unknown
mailresp_unknown
mailresp_yes
models
months
mou_Mean
mou_opkv_Range
mou_pead_Mean
mou_Range
mtrcycle
numcars_1
numcars_2
numcars_3
numcars_unknown
occu_admin
occu_bc
occu_farmer
occu_homemaker
occu_military
occu_religious
occu_retires
occu_sales
occu_selfemp
occu_student
occu_technical
occu_wc
opk_dat_Mean
ovrmou_Mean
ovrrev_Mean
owylis_vce_Range
plcd_vce_Mean
proptype_a
proptype_b
proptype_d
proptype_e
proptype_g
proptype_m
proptype_unknown
recv_sms_Mean
retdays
rev_Mean
rev_Range
roam_Mean
solflag_default
solflag_no
solflag_yes
status_infermarried
status_infersingle
status_married
status_single
status_unknown
totcalls
totmrc_Mean
totrev
truck
uniqsubs
worst_crclscod
wrkwoman_unknown
wrkwoman_yes
;
output out = tele.churn_model1 predicted = pred_prob;
run;

/*iteration2*/
proc logistic data = tele.development descending;
model churn = 
actvsubs
adjmou
/*adjqty*/
/*adjrev*/
age1
/*age2*/
/*area_atlantic
area_cali
area_chicago
area_city
area_dallas
area_dcmvir
area_gla
area_houston
area_la
area_mdwest
area_neweng
area_nfl
area_nrocky
area_nyc
area_ohio
area_phily*/
area_rural
/*area_sfl
area_suburban
area_swest
area_tenese
area_texas
area_town
area_unknown
area_urban
asl_flag_no*/
asl_flag_yes
/*average_crclscod
avg3mou
avg3qty
avg6mou
avg6qty
avgmou
avgqty
avgrev
bad_crclscod
best_crclscod
blck_dat_Mean
callwait_Mean
callwait_Range
car_buy_new
car_buy_unknown
cartype_basic
cartype_luxury
cartype_minivan
cartype_regular
cartype_SUV
cartype_truck
cartype_unknown
cartype_upper
ccrndmou_Range*/
change_mou
children_no
/*children_unknown
children_yes
comp_vce_Mean
csa_city1
csa_city2
csa_city3*/
custcare_Mean
/*da_Mean
da_Range
datovr_Mean
datovr_Range
division_bth*/
division_LDD
/*division_LTD
division_unknown*/
drop_blk_Mean
/*drop_dat_Mean*/
drop_vce_Mean
/*drop_vce_Range
dsize_1
dsize_100*/
dsize_10to19
/*dsize_2
dsize_20to29
dsize_3
dsize_30to39*/
dsize_4
/*dsize_40to49
dsize_5
dsize_50to99
dsize_6
dsize_7
dsize_8*/
dsize_9
/*dsize_unknown
dwell_multiple
dwell_single
dwell_unknown*/
eqpdays
/*ethnic_afro_amer*/
ethnic_arab
ethnic_asian
ethnic_asian_nor
ethnic_french
ethnic_german
ethnic_hispanic
ethnic_italian
ethnic_jewish
/*ethnic_misc*/
ethnic_north_euro
/*ethnic_polynesia*/
ethnic_scot_iris
ethnic_south_euro
ethnic_unknown
/*forgntvl
good_crclscod*/
handset_na
handset_new
/*handset_refurb
handset_unkw
handset_wc
handset_wcmb*/
hnd_price
/*income
iwylis_vce_Mean
mailorder_buyer
mailorder_unknown
mailresp_unknown
mailresp_yes*/
models
months
mou_Mean
mou_opkv_Range
/*mou_pead_Mean*/
mou_Range
/*mtrcycle*/
/*numcars_1
numcars_2
numcars_3
numcars_unknown
occu_admin
occu_bc
occu_farmer
occu_homemaker
occu_military
occu_religious
occu_retires
occu_sales
occu_selfemp
occu_student
occu_technical
occu_wc
opk_dat_Mean
ovrmou_Mean
ovrrev_Mean
owylis_vce_Range
plcd_vce_Mean
proptype_a
proptype_b
proptype_d
proptype_e
proptype_g
proptype_m*/
proptype_unknown
/*recv_sms_Mean*/
retdays
/*rev_Mean*/
rev_Range
roam_Mean
/*solflag_default
solflag_no
solflag_yes
status_infermarried*/
status_infersingle
status_married
status_single
/*status_unknown
totcalls*/
totmrc_Mean
/*totrev
truck*/
uniqsubs
/*worst_crclscod
wrkwoman_unknown
wrkwoman_yes*/
;
output out = tele.churn_model2 predicted = pred_prob;
run;

/*iteration3*/
proc logistic data = tele.development descending;
model churn = 
actvsubs
adjmou
/*adjqty*/
/*adjrev*/
age1
/*age2*/
/*area_atlantic
area_cali
area_chicago
area_city
area_dallas
area_dcmvir
area_gla
area_houston
area_la
area_mdwest
area_neweng
area_nfl
area_nrocky
area_nyc
area_ohio
area_phily*/
area_rural
/*area_sfl
area_suburban
area_swest
area_tenese
area_texas
area_town
area_unknown
area_urban
asl_flag_no*/
asl_flag_yes
/*average_crclscod
avg3mou
avg3qty
avg6mou
avg6qty
avgmou
avgqty
avgrev
bad_crclscod
best_crclscod
blck_dat_Mean
callwait_Mean
callwait_Range
car_buy_new
car_buy_unknown
cartype_basic
cartype_luxury
cartype_minivan
cartype_regular
cartype_SUV
cartype_truck
cartype_unknown
cartype_upper
ccrndmou_Range*/
change_mou
children_no
/*children_unknown
children_yes
comp_vce_Mean
csa_city1
csa_city2
csa_city3*/
custcare_Mean
/*da_Mean
da_Range
datovr_Mean
datovr_Range
division_bth*/
division_LDD
/*division_LTD
division_unknown*/
/*drop_blk_Mean*/
/*drop_dat_Mean*/
drop_vce_Mean
/*drop_vce_Range
dsize_1
dsize_100*/
dsize_10to19
/*dsize_2
dsize_20to29
dsize_3
dsize_30to39*/
dsize_4
/*dsize_40to49
dsize_5
dsize_50to99
dsize_6
dsize_7
dsize_8*/
dsize_9
/*dsize_unknown
dwell_multiple
dwell_single
dwell_unknown*/
eqpdays
/*ethnic_afro_amer*/
ethnic_arab
ethnic_asian
ethnic_asian_nor
ethnic_french
ethnic_german
ethnic_hispanic
ethnic_italian
ethnic_jewish
/*ethnic_misc*/
ethnic_north_euro
/*ethnic_polynesia*/
ethnic_scot_iris
ethnic_south_euro
ethnic_unknown
/*forgntvl
good_crclscod*/
handset_na
handset_new
/*handset_refurb
handset_unkw
handset_wc
handset_wcmb*/
hnd_price
/*income
iwylis_vce_Mean
mailorder_buyer
mailorder_unknown
mailresp_unknown
mailresp_yes*/
models
months
mou_Mean
mou_opkv_Range
/*mou_pead_Mean*/
mou_Range
/*mtrcycle*/
/*numcars_1
numcars_2
numcars_3
numcars_unknown
occu_admin
occu_bc
occu_farmer
occu_homemaker
occu_military
occu_religious
occu_retires
occu_sales
occu_selfemp
occu_student
occu_technical
occu_wc
opk_dat_Mean
ovrmou_Mean
ovrrev_Mean
owylis_vce_Range
plcd_vce_Mean
proptype_a
proptype_b
proptype_d
proptype_e
proptype_g
proptype_m*/
proptype_unknown
/*recv_sms_Mean*/
retdays
/*rev_Mean*/
rev_Range
/*roam_Mean*/
/*solflag_default
solflag_no
solflag_yes
status_infermarried*/
status_infersingle
status_married
status_single
/*status_unknown
totcalls*/
totmrc_Mean
/*totrev
truck*/
uniqsubs
/*worst_crclscod
wrkwoman_unknown
wrkwoman_yes*/
;
output out = tele.churn_model3 predicted = pred_prob;
run;



/*forward selection*/
proc logistic data = tele.development descending;
model churn = 
actvsubs
adjmou
adjqty
adjrev
age1
age2
area_atlantic
area_cali
area_chicago
area_city
area_dallas
area_dcmvir
area_gla
area_houston
area_la
area_mdwest
area_neweng
area_nfl
area_nrocky
area_nyc
area_ohio
area_phily
area_rural
area_sfl
area_suburban
area_swest
area_tenese
area_texas
area_town
area_unknown
area_urban
asl_flag_no
asl_flag_yes
average_crclscod
avg3mou
avg3qty
avg6mou
avg6qty
avgmou
avgqty
avgrev
bad_crclscod
best_crclscod
blck_dat_Mean
callwait_Mean
callwait_Range
car_buy_new
car_buy_unknown
cartype_basic
cartype_luxury
cartype_minivan
cartype_regular
cartype_SUV
cartype_truck
cartype_unknown
cartype_upper
ccrndmou_Range
change_mou
children_no
children_unknown
children_yes
comp_vce_Mean
csa_city1
csa_city2
csa_city3
custcare_Mean
da_Mean
da_Range
datovr_Mean
datovr_Range
division_bth
division_LDD
division_LTD
division_unknown
drop_blk_Mean
drop_dat_Mean
drop_vce_Mean
drop_vce_Range
dsize_1
dsize_100
dsize_10to19
dsize_2
dsize_20to29
dsize_3
dsize_30to39
dsize_4
dsize_40to49
dsize_5
dsize_50to99
dsize_6
dsize_7
dsize_8
dsize_9
dsize_unknown
dwell_multiple
dwell_single
dwell_unknown
eqpdays
ethnic_afro_amer
ethnic_arab
ethnic_asian
ethnic_asian_nor
ethnic_french
ethnic_german
ethnic_hispanic
ethnic_italian
ethnic_jewish
ethnic_misc
ethnic_north_euro
ethnic_polynesia
ethnic_scot_iris
ethnic_south_euro
ethnic_unknown
forgntvl
good_crclscod
handset_na
handset_new
handset_refurb
handset_unkw
handset_wc
handset_wcmb
hnd_price
income
iwylis_vce_Mean
mailorder_buyer
mailorder_unknown
mailresp_unknown
mailresp_yes
models
months
mou_Mean
mou_opkv_Range
mou_pead_Mean
mou_Range
mtrcycle
numcars_1
numcars_2
numcars_3
numcars_unknown
occu_admin
occu_bc
occu_farmer
occu_homemaker
occu_military
occu_religious
occu_retires
occu_sales
occu_selfemp
occu_student
occu_technical
occu_wc
opk_dat_Mean
ovrmou_Mean
ovrrev_Mean
owylis_vce_Range
plcd_vce_Mean
proptype_a
proptype_b
proptype_d
proptype_e
proptype_g
proptype_m
proptype_unknown
recv_sms_Mean
retdays
rev_Mean
rev_Range
roam_Mean
solflag_default
solflag_no
solflag_yes
status_infermarried
status_infersingle
status_married
status_single
status_unknown
totcalls
totmrc_Mean
totrev
truck
uniqsubs
worst_crclscod
wrkwoman_unknown
wrkwoman_yes/selection = forward
;
output out = tele.churn_model4_fwd predicted = pred_prob;
run;


/*After performing logistic regression on validation dataset many significant variables
selected by forward selection in development dataset were found to be insignificant
so perfoming final logistic regression with only significant variables*/
/*final iteration*/
proc logistic data = tele.development descending;
model churn=
eqpdays
age1
asl_flag_yes
hnd_price
mou_Mean
avgmou
ovrmou_Mean
drop_vce_Mean
ethnic_afro_amer
ethnic_asian
uniqsubs
handset_refurb
mou_Range
actvsubs
comp_vce_Mean
area_sfl
adjmou
proptype_unknown
mailresp_yes
children_yes
adjrev
area_town
area_mdwest
;
output out=tele.final_churn_dev predicted = pred_prob;
run;

proc sort data = tele.final_churn_dev out =tele.churn_sorted;
by descending pred_prob;
run;


proc rank data = tele.churn_sorted out = tele.decile groups = 10 ties = mean;
var pred_prob;
ranks decile;
run;

proc export data = tele.decile
outfile = "Y:\Graded Assignments\Topic 13-Final Case Study\Solution\development_lift_chart1.csv"
dbms = csv replace;
run;

/*Scoring a new dataset-Confusion Matrix*/
proc logistic data = tele.development descending;
model churn = 
eqpdays
age1
asl_flag_yes
hnd_price
mou_Mean
avgmou
ovrmou_Mean
drop_vce_Mean
ethnic_afro_amer
ethnic_asian
uniqsubs
handset_refurb
mou_Range
actvsubs
comp_vce_Mean
area_sfl
adjmou
proptype_unknown
mailresp_yes
children_yes
adjrev
area_town
area_mdwest
;
output out = tele.confusion_dev predicted = pred_prob;
score data = tele.validation out = tele.reg_out;
run;

proc freq data=tele.reg_out;
tables F_churn*I_churn/nocum norow nopercent nocol;
run;




/****************End of development dataset modelling*******************/


/****************Validation of Model****************************************/
proc logistic data = tele.validation descending;
model churn = 
eqpdays
age1
asl_flag_yes
hnd_price
rev_Range
mou_Mean
avgmou
ovrmou_Mean
drop_vce_Mean
ethnic_afro_amer
ethnic_asian
uniqsubs
months
handset_refurb
mou_Range
division_LDD
actvsubs
comp_vce_Mean
models
area_nrocky
area_sfl
totmrc_Mean
adjmou
proptype_unknown
ethnic_hispanic
mou_opkv_Range
status_single
roam_Mean
mailresp_yes
children_yes
drop_blk_Mean
adjrev
change_mou
rev_Mean
area_ohio
retdays
dsize_4
area_texas
area_rural
area_town
area_tenese
area_mdwest
area_houston
dsize_5
ethnic_south_euro
ethnic_asian_nor
custcare_Mean
area_dcmvir
handset_na
;
output out = tele.churn_valid_model predicted = pred_prob;
run;


/*reperfoming validation*/
proc logistic data = tele.validation descending;
model churn = 
eqpdays
age1
asl_flag_yes
hnd_price
mou_Mean
avgmou
ovrmou_Mean
drop_vce_Mean
ethnic_afro_amer
ethnic_asian
uniqsubs
handset_refurb
mou_Range
actvsubs
comp_vce_Mean
area_sfl
adjmou
proptype_unknown
mailresp_yes
children_yes
adjrev
area_town
area_mdwest
;
output out = tele.final_churn_valid predicted = pred_prob;
run;

proc sort data = tele.final_churn_valid out =tele.churn_sorted_valid;
by descending pred_prob;
run;


proc rank data = tele.churn_sorted_valid out = tele.decile_valid groups = 10 ties = mean;
var pred_prob;
ranks decile;
run;

proc export data = tele.decile_valid
outfile = "Y:\Graded Assignments\Topic 13-Final Case Study\Solution\validation_lift_chart1.csv"
dbms = csv replace;
run;

proc logistic data = tele.validation descending;
model churn = 
eqpdays
age1
asl_flag_yes
hnd_price
mou_Mean
avgmou
ovrmou_Mean
drop_vce_Mean
ethnic_afro_amer
ethnic_asian
uniqsubs
handset_refurb
mou_Range
actvsubs
comp_vce_Mean
area_sfl
adjmou
proptype_unknown
mailresp_yes
children_yes
adjrev
area_town
area_mdwest
;
output out = tele.confusion_valid predicted = pred_prob;
score data = tele.development out = tele.reg_out_valid;
run;

proc freq data=tele.reg_out_valid;
tables F_churn*I_churn/nocum norow nopercent nocol;
run;



proc corr data = tele.telecom_out2;
var churn 
eqpdays
age1
asl_flag_yes
hnd_price
mou_Mean
avgmou
ovrmou_Mean
drop_vce_Mean
ethnic_afro_amer
ethnic_asian
uniqsubs
handset_refurb
mou_Range
actvsubs
comp_vce_Mean
area_sfl
adjmou
proptype_unknown
mailresp_yes
children_yes
adjrev
area_town
area_mdwest;
run;

/*Solution for q5. Customer segmentation*/
/*Revenue segment of customers*/
proc univariate data = tele.development;
var avgrev;
run;

/*25% of high revenue customers 66.78*/
data tele.highrevenue;
set tele.development;
if avgrev>66.78;
run;

data tele.lowrevenue;
set tele.development;
if avgrev<66.78;
run;

proc freq data = tele.highrevenue;
tables churn;
run;

proc freq data = tele.lowrevenue;
tables churn;
run;

proc means data = tele.highrevenue mean;
var churn 
eqpdays
age1
asl_flag_yes
hnd_price
mou_Mean
avgmou
ovrmou_Mean
drop_vce_Mean
ethnic_afro_amer
ethnic_asian
uniqsubs
handset_refurb
mou_Range
actvsubs
comp_vce_Mean
area_sfl
adjmou
proptype_unknown
mailresp_yes
children_yes
adjrev
area_town
area_mdwest;
run; 

proc means data = tele.lowrevenue mean;
var churn 
eqpdays
age1
asl_flag_yes
hnd_price
mou_Mean
avgmou
ovrmou_Mean
drop_vce_Mean
ethnic_afro_amer
ethnic_asian
uniqsubs
handset_refurb
mou_Range
actvsubs
comp_vce_Mean
area_sfl
adjmou
proptype_unknown
mailresp_yes
children_yes
adjrev
area_town
area_mdwest;
run; 


