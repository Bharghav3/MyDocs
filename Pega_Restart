#!/bin/bash
#This script is to deploy the Pega Products/RuleSets from the Destination URL to the Target Servers.

JAVA_HOME=/usr/lib/jvm/java-1.8.0-openjdk-1.8.0.292.b10-1.el8_4.x86_64/jre
export JAVA_HOME
PATH=$JAVA_HOME/bin:$PATH
export PATH

PASSWORD=$1

build_dir=/Data/Pega/productmigration

products_name=($PRODUCTS_NAME)
products_version=($PRODUCTS_VERSION)

n=${#products_version[@]} #num elements in array products_name

PRODUCTS=$(
for (( i=0; i<n; i++ ))
do
if [ ${#products_name[@]} == ${#products_version[@]} ]
then
products[$i]=${products_name[$i]}":"${products_version[$i]}","
echo -n ${products[$i]}
elif [ ${#products_name[@]} == "1" ]
then
products[$i]=${products_name}":"${products_version[$i]}","
echo -n ${products[$i]}
else
echo "Enter the Product names in Array Format"
exit
fi
done
)

for i in $SERVERNAME
do

echo -e "\nDeploying to $i"

mkdir -p $build_dir
cp -rf $WORKDIR/$BUILD_PROJECTNAME/productmigration/* $build_dir

cd $build_dir
chmod -R 750 $build_dir/*

ReturnCode=$(./productMigration.sh migrate -url http://$i.worldbank.org:$PORT/prweb/PRSOAPServlet -user $USER -pwd $PASSWORD -targets $TARGET -products $PRODUCTS | grep ReturnCode | tail -1 | awk '{print $NF}')
line=$(grep -n 'Invoking' logs/ProductMigration.log | cut -d: -f1 | tail -1)
if [[ $ReturnCode == "Pass" ]]; then
#cat logs/ProductMigration.log | tail -n 14
sed -n "$((line+1))"',$p' logs/ProductMigration.log | cut -f11- -d' '
elif [[ $ReturnCode == "Fail" ]]; then
sed -n "$((line+1))"',$p' logs/ProductMigration.log | cut -f11- -d' '
echo "##vso[task.logissue type=error;code=1;]Please Enter Valid Target or Product Names." 1>&2
exit 1
else
cat logs/ProductMigration.log | tail -n 14
echo "##vso[task.logissue type=error;code=1;]Please check the given Parameters" 1>&2
exit 1
fi

if [[ $ReturnCode == "Pass" ]]; then
GetMigrationLog="./productMigration.sh getMigrationLog -url http://$i.worldbank.org:$PORT/prweb/PRSOAPServlet -user $USER -pwd $PASSWORD "

for i in {1..10}; do
output=$( ($GetMigrationLog) | grep Success | awk '{print $NF}')
match='Success'
if [[ "$output" == *"$match"* ]]; then
        cat $( ($GetMigrationLog) | grep Logs | awk '{print $NF}')
        echo -e "\n#########################################################################"
        exit
else
        echo "In-Progress"
        sleep 30
        
fi
done

fi

done
