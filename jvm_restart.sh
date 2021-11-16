#!/bin/bash

jboss_home=/Data/JBoss/jboss-eap-7.1

server_list=`echo $SERVERNAME | tr ',' ' '`

if [[ $APPNAME =~ "ifc-ifcdocs" ]];
then
    jboss_home=/Data/JBoss/jboss-eap-7.2
    APPNAME=$APPNAME"72"
elif [[ $APPNAME == "ifc-iportal-api1oauth" && $ENVIRONMENT == "dev4" ]];
then
    APPNAME=ifc-iportal-api1oauth-dev4
elif [[ $APPNAME == "ifc-iportal-api1oauth" && $ENVIRONMENT == "qa3" ]];
then
    APPNAME=ifc-iportal-api1oauth3
elif [[ $APPNAME == "ifc-iportal-api1oauth" && $ENVIRONMENT == "qa4" ]];
then
    APPNAME=ifc-iportal-api1oauth-QA4
elif [[ $APPNAME == "ifc-iportal-api1" && $ENVIRONMENT == "dev4" ]];
then
    APPNAME=ifc-iportal-api1-dev4
elif [[ $APPNAME == "ifc-iportal-api1" && $ENVIRONMENT == "qa4" ]];
then
    APPNAME=ifc-iportal-api1-QA4
elif [[ $APPNAME == "ifc-search" && $ENVIRONMENT == "dev4" ]];
then
    APPNAME=ifc-search-dev4
elif [[ $APPNAME == "ifc-search" && $ENVIRONMENT == "qa3" ]];
then
    APPNAME=ifc-search3
fi

if [ $ACTION == "Restart" ];
then
for i in $server_list
do
echo "#############################################"
echo "Restarting $APPNAME application in $ENVIRONMENT environment"
echo "---------------------------------------------"
echo $i
ssh -q $i.ifc.org<<EOF
/Data/JBossfs/scripts/$APPNAME/"$APPNAME"_appserver_restart.sh >/dev/null 2>&1
sleep 30
egrep "WFLYSRV0026|WFLYSRV0025" $jboss_home/$APPNAME/log/server.log | tail -1
jvm_pid=\$(ps -ef | grep java | grep -v grep | grep $APPNAME/ | awk '{print \$2}')
if [ -n "\$jvm_pid" ]
then
	output_status="$APPNAME has been Restarted in $i server"
	echo \$output_status
else
	output_status="$APPNAME was not Started in $i server. Please contact JBOSS Admins"
	echo \$output_status >&2
fi
curl -s -u $1:'$2' -H "Content-Type: application/json" -H "sys_context: esbADO" -X POST "https://servicenow.esbp.worldbank.org/v1/api/updatetask" -d '{"TaskNumber":"$SNOWREFNO","Comments":"'"\$output_status"'","Status":"es500","CustomerVisible":"Y"}'
EOF
echo -e "\n#############################################\n"
done
fi

if [ $ACTION == "Stop" ]; 
then
for i in $server_list
do
echo "#############################################"
echo "Stopping $APPNAME application in $ENVIRONMENT environment"
echo "---------------------------------------------"
echo $i
ssh -q $i.ifc.org<<EOF
jvm_pid=\$(ps -ef | grep java | grep -v grep | grep $APPNAME/ | awk '{print \$2}')
if [ -z "\$jvm_pid" ]; then
output_status="$APPNAME already stopped in $i server"
echo \$output_status
else
$jboss_home/bin/$APPNAME/"$APPNAME"_stop.sh >/dev/null 2>&1
sleep 15
egrep "WFLYSRV0050" $jboss_home/$APPNAME/log/server.log | tail -1
jvm_pid=\$(ps -ef | grep java | grep -v grep | grep $APPNAME/ | awk '{print \$2}')
kill -9 \$jvm_pid >/dev/null 2>&1
	if [ -z "\$jvm_pid" ]
	then
		output_status="$APPNAME has been Stopped in $i server"
		echo \$output_status
	else
		output_status="$APPNAME was not Stopped in $i server. Please contact JBOSS Admins"
		echo \$output_status >&2
	fi
fi
curl -s -u $1:'$2' -H "Content-Type: application/json" -H "sys_context: esbADO" -X POST "https://servicenow.esbp.worldbank.org/v1/api/updatetask" -d '{"TaskNumber":"$SNOWREFNO","Comments":"'"\$output_status"'","Status":"es500","CustomerVisible":"Y"}'
EOF
echo -e "\n#############################################\n"
done
fi

if [ $ACTION == "Start" ];
then
for i in $server_list
do
echo -e "#############################################"
echo "Starting $APPNAME application in $ENVIRONMENT environment"
echo "---------------------------------------------"
echo $i
ssh -q $i.ifc.org<<EOF
jvm_pid=\$(ps -ef | grep java | grep -v grep | grep $APPNAME/ | awk '{print \$2}')
if [ -n "\$jvm_pid" ]; then
output_status="$APPNAME is already Started in $i server"
echo \$output_status
else
$jboss_home/bin/$APPNAME/"$APPNAME"_start.sh >/dev/null 2>&1
sleep 15
jvm_pid=\$(ps -ef | grep java | grep -v grep | grep $APPNAME/ | awk '{print \$2}')
	if [ -n "\$jvm_pid" ]
	then
		output_status="$APPNAME has been Started in $i server"
		echo \$output_status
	else
		output_status="$APPNAME was not started in $i server. Please contact JBOSS Admins"
		echo \$output_status >&2
	fi
fi
curl -s -u $1:'$2' -H "Content-Type: application/json" -H "sys_context: esbADO" -X POST "https://servicenow.esbp.worldbank.org/v1/api/updatetask" -d '{"TaskNumber":"$SNOWREFNO","Comments":"'"\$output_status"'","Status":"es500","CustomerVisible":"Y"}'
EOF
echo -e "\n#############################################\n"
done
fi
