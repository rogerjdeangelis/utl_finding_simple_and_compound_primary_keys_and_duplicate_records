Finding simple and compound primary keys and duplicate records

github
https://tinyurl.com/ya4absfl
https://github.com/rogerjdeangelis/utl_finding_simple_and_compound_primary_keys_and_duplicate_records

https://tinyurl.com/y72asase
https://communities.sas.com/t5/SAS-Enterprise-Guide/Asking-the-experts-how-to-find-the-proper-key-between-two-sas-or/m-p/455629?nobounce

Asking the experts / how to find the proper key between two sas or oracle table

* quick method to find simple primary keys;

ods exclude all;
ods output nlevels=nlevels;
proc freq data=sashelp.class nlevels;
run;quit;
ods select all;

Up to 40 obs WORK.NLEVELS total obs=5

Obs    TABLEVAR    NLEVELS

 1      NAME          19  primary key: 19=  number of observations in sashelp.class
 2      SEX            2
 3      AGE            6
 4      HEIGHT        17
 5      WEIGHT        15

My voodoo macro can find pairs of variables that are primary keys.
It provides the number of levels for all pairs of variables.
If the cardinality equals the number of observations then you have a primary key.

github
https://github.com/rogerjdeangelis/voodoo

The first page of voodoo output gives the number of levels for every variable.
To be a key the product levels_var1*level_var2 has to be greater then the
number of observations.

https://github.com/rogerjdeangelis/voodoo


EXAMPLE OUTPUT

Zip is a primary key

First page of voodoo

 #     Variable     Unique Values
---    --------     -------------

 26    ZIP                41,267

Pairs that form a primary key

Obs    RECORDS    VAR1ST       LEVELS_1    VAR2ND                   LEVELS_2    UNIQUE

184    41,267     COUNTY         326       DATE                      41,267     41,267
133    41,267     STATE           58       DATE                      41,267     41,267


/* T000830 STEPS FOR IDENTIFYING DUPLICATES AND POTENTIAL KEYS */

   Suggested AE key

   study, patient, aestdtc, aestipdt, aeendt, aept, aeterm

   Understanding duplicates is often very dificult.

   In relational databases there is the notion of dimension and fact variables
   Dimension variables are classification variables geography, sites, investigators.
   Fact variables are like lab results, age and weight

   Generally fact variables are never part of a key, but deciding which variables
   are fact and which are dimension variables is not always clean cut.

   Suggested steps to find duplicates:

    1. Check all datasets using
       proc sort data=ae.ae out=srtae nodupkey dupout=dups;
       by _all_;
       run;

       If there are dups send me an email put a comment in the code
       "Table xyz is ill formed there exact dubplcate records""

    2. Check datasets using the method below.
       Drop oracle variables whose only purpose is to hide true duplicates(sequence numbers, datetime?).
       proc sort data=craspirin.ae(drop=aelineno pageno) out=chkaspirin nodupkey dupout=dups;
       by _all_;
       run;

       If there are dups send me an email put a comment in the code
       "dumb potential key variables droppes ie seqno "
        without oracle keys*/"

    3. If you are using standard ae inputs then all "key"(non fact) AE variables have prefix AE and
       you can run the following code.

       proc sort data=craspirin.ae out=chkaspirin nodupkey dupout=dups;
       by patient ae:;
       run;

       If there are dups send me an email put a comment in the code
       "No combination of dimension variables forms a key"

    4. If two does not have duplicates then start removing AE variables one by one that are not part of key
       study, patient, aestdtc, aestipdt, aeendt, aept, aeterm

       proc sort data=craspirin.ae(drop=AETM) out=chkaspirin nodupkey dupout=dups;
       by patient ae:;
       run;

       If this is unique then we have to add time to our key. You are done.

       Send me an email and add the comment
       "/* may need to add time variable(AETM)  to make AE EVENTS unique */"

       Details:

       Start with dinmesion varaibles with the higest cardinality and use your judgement. I have a macro to help with this.
       But I do not have time to expalin now.

       This code below with give you cadinality.
       proc sql;select study, crt, variable, question, answer from dtmtry.ddt_034sty where
       study='aspirin' and crt='AE' and question='DISTINCT_LEVELS_MISS' and variable eqt 'AE'
       order by input(scan(answer,1,'@'),10.) descending ;

                    Distinct Levels

       AEXTM         41   Time Variable?
       AEXEVENT      38
       AEXPTERM      31
       AEXHI1TRM     23
       AEXSPDI       21
       AEXSPD4       21
       AEXSPDC       21
       AEXSPDT       21
       AEXD4         19
       AEXDI         19
       AEXDT         19
       AEXDC         19
       AEXDUR        13
       AEXBTERM      10
       AEXHI2TRM     6
       AEXRLTED      5    Related
       AEXACTION     5
       AEXSVRT       4    Severity


    5. If you cannot use 3 and have duplicates then follow step 4 using _all_ but drop highest cardiality.

       I know some of you will need to add AEPTZ(original preferred term) to make records unique
       If there are dups because of AEPT then send me an email put a comment in the code
       "/* duplicates based on orginal preferred term  */"






