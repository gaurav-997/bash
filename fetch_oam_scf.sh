#!/bin/bash

parent_dir="/var/tmp/es_logs/"
date_dir=$(date '+%Y_%m_%d_%H_%M_%S')
sub_dir="/var/tmp/es_logs/${date_dir}"

if [[ -z "$enbs" && -z "$all_enbs" ]]; then
   echo "No enbs specified, exiting!"
   exit -1
fi


oamterm_svc_ip=$(kubectl get svc -n ricplt  oamterm-http -o=jsonpath='{.spec.clusterIP}')
ppinf_pod_name=$(kubectl get pods -n ricxapp | grep Running | grep "ricxapp-es-profileprediction-inference"  | grep -v  "5g" | awk '{print $1}' | tr -d '\n')

declare -a es_enbs=$(echo ${enbs} | sed 's/,/\n/g')
declare -a enbs_hex=()

if [[ "$enbs_int" && ${#es_enbs[@]} -gt 0 ]]; then
        for enb in ${es_enbs[@]}
        do
                echo $enb
                enbs_hex[${#enbs_hex[@]}]=$(printf '%X' $enb)
        done
elif [[ "$all_enbs" ]]; then
        enbs_hex=$(kubectl exec -it -n ricxapp deploy/ricxapp-tpmgr -- tpmcli get nodes | awk -F"|" '{print $3}' | grep -v "NODE-ID" |xargs)
else
        enbs_hex=${es_enbs[@]}
fi

if [[ ${#enbs_hex[@]} -eq 0 ]]; then
        echo "No enbs specified, exiting!"
        exit -1
fi

for enb in ${enbs_hex[@]}
do
        enbid=$(echo $enb | tr -d '\n')
        echo "Refreshing SCF for enbid: $enbid -- $((16#${enbid}))"
        kubectl exec -it -n ricxapp ${ppinf_pod_name} -c es-profileprediction-inference -- curl -X GET http://${oamterm_svc_ip}:8080/ric/v1/generic/parameters/${enbid} -H "accept: application/json" -H "Content-Type: application/json" -d '[{"MOId": "MOIMP","mo_name": "MRBTS.LNBTS.MOPR.MOIMP","parameterList": ["dlCarFrqEutL","idleLBEutCelResWeight","idleLBEutCelResWeightEnDc"]}]'
done

for po in $(kubectl get po -n ricplt | grep oamtdist | awk '{print $1}'); do kubectl exec -it $po -n ricplt -- tar -cf /tmp/scf_$po.tar /opt/OAMTermination/scf; kubectl cp ricplt/$po:/tmp/scf_$po.tar ./scf_$po.tar; echo $(date +%c):oamtdist scf file "scf_${po}.tar" ; done

rm -rf scf_tmp
mkdir scf_tmp
mkdir scf_tmp/scf_files

for scf in $(ls scf*.tar)
do
        dir=$(echo "scf_oamtdist-569cbcfd7c-sndpr.tar" | sed -e "s/.tar//" | tr -d '\n')
        mkdir -pv scf_tmp/$dir
        tar -xf $scf -C scf_tmp/$dir
done

declare -a enbwise_latest=()

for enb in ${enbs_hex[@]}
do
        declare -a files=$(find scf_tmp/ -name "scf_$enb" -type f -exec stat -c '%Y %n' {} + | sort -r | awk '{print strftime("%Y-%m-%d %H:%M:%S", $1), $2}'   |awk '{print $3}')
        if [[ (( ${#files[@]} )) &&  ${files[0]} != "" ]] ; then
                enbwise_latest[${#enbwise_latest[@]}]=${files[0]}
                cp ${files[0]} scf_tmp/scf_files/
        else
                echo "SCF for enbid: $enbid -- $((16#${enbid})) not exported"
        fi
done

cd scf_tmp/ && tar -cf ../scf_files_${date_dir}.tar scf_files/

echo "Saved to scf_files_${date_dir}.tar"


rm -rf scf_tmp