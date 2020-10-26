#!/bin/bash

function helpnote(){

echo -e "\nArguments Below \n\n-f --file \t\tThe Input File which has Hostname/IP space seperated in the same order\n-s --community-string \tSNMP Community String for SNMPWALKS\n-h --help \t\tShows Arguments to be Passed\n"
}

if [[ $# -lt 1 ]]
then
	echo "Atleast 1 argument required... Exiting..\n"
	helpnote
	exit;
fi


while getopts "F:f:S:s:hH" OPTION
do
	case $OPTION in
		f|F) 	INFILE=$OPTARG
			;;
		s|S) 	PWSD=$OPTARG
			;;
		h|H) helpnote
			exit
			;;
		*) echo -e "Unknow Argument\n"
			helpnote
			exit
			;;
	esac
done

#echo "OUTSIDE OF WHILE VARIABLES PASSED ARE FILE-NAME::$INFILE COMMUNITY-STRING::$PWD"

if [[ ! -f "$INFILE" ]];then echo -e "\nFile Does Not Exist Exiting..." ; exit  ;fi
if [[ ! -n "$PWSD" ]];then echo -e "\nCommunity String is not passed... Exiting" ; helpnote;exit ;fi




OID=".1.3.6.1.2.1.1.2.0" ##SysOID
FNAME=$INFILE
CSTR=$PWSD

#printf "HOSTNAME\t\tIP\t\tICMP\t\tSNMP\t\tSYSOID\t\tREQUISITION">>results.txt
while read line
do
HNAME=`echo $line | awk '{print $1}'`
IP=`echo $line | awk '{print $2}'`
REQ=`echo $line | awk '{print $3}'`
printf "\n$HNAME \t$IP" >>results.txt

#to check if the node is pingable
ICMPCHK=`ping -c 3 $IP`
ICMPCHKR=$?

if [ $ICMPCHKR -eq 0 ]
then
printf "\tICMP::Yes">>results.txt
else
printf "\tICMP::No">>results.txt
fi

SNMPCHK=`snmpwalk -v 2c -c $CSTR $IP $OID -On`
SNMPCHKR=$?
SYSOID=`echo $SNMPCHK | awk '{print $4}'`

if [ $SNMPCHKR -eq 0 ]
then
printf "\tSNMP::YES \t$SYSOID">>results.txt
else
printf "\tSNMP::NO">>results.txt
fi

printf "\tREQUISITION::$REQ">>results.txt
done <$FNAME
