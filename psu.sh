#!/bin/bash
read -p "please enter the IP address " addr
read -p "please enter the initialport " initialport
read -p "please enter first psu ID " psuid
firstport=$((initialport-psuid))
for (( i=$psuid; i<=$((psuid+150)); i++))
do
echo "{
  "\"psuid\"": $i,
  "\"config\"": "\"{"'Address'": \'$addr\', "'Port'": $((firstport +i)), "'SNMP-version'": 3, "'User'": "'v3user'", "'communitystring'": "'private'", "'Psu-Type'": "'APRA'" , "'AuthProto'": "'MD5'","'AuthPhrase'": "'authpass'" , "'PrivProto'": "'DES'" , "'PrivPhrase'": "'privpass'" , "'MsgFlags'": "'AuthPriv'"}"\",
  "\"siteid\"": "\"site1\""
}," >>./simulator_nesc.txt
done
