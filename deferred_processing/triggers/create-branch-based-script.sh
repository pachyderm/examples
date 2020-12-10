#!/bin/sh

echo "deleting existing pipelines"
pachctl delete pipeline regression
pachctl delete repo housing_data
echo "creating repo"
pachctl create repo housing_data
echo "creating pipeline"
pachctl create pipeline -f ../../housing-prices/regression.json
echo "creating trigger"
pachctl create branch housing_data@master --trigger staging --trigger-size 3KB

read -n 1 -t 5 -p "list branch in 5 seconds (press any key to do it now) " meow
echo 
pachctl list branch housing_data

read -n 1 -t 5 -p "inspect branch in 5 seconds (press any key to do it now) " meow
echo 
pachctl inspect branch housing_data@master

read -n 1 -t 5 -p "putting data in 5 seconds (press any key to do it now) " meow
echo
pachctl put file housing_data@staging:housing-simplified.csv -f housing-simplified-aa.csv

read -n 1 -t 5 -p "listing branch in 5 seconds (press any key to do it now) " meow
echo
pachctl list branch housing_data

read -n 1 -t 5 -p "listing job in 5 seconds (press any key to do it now) " meow
echo
pachctl list job --no-pager

read -n 1 -t 5 -p "listing file in 5 seconds (press any key to do it now) " meow
echo
pachctl list file housing_data@master

read -n 1 -t 5 -p "putting file in 5 seconds (press any key to do it now) " meow
echo
pachctl put file housing_data@staging:housing-simplified.csv -f housing-simplified-ab.csv

read -n 1 -t 5 -p "list branch in 5 seconds (press any key to do it now) " meow
echo 
pachctl list branch housing_data

read -n 1 -t 5 -p "listing job in 5 seconds (press any key to do it now) " meow
echo
pachctl list job --no-pager

read -n 1 -t 5 -p "putting file in 5 seconds (press any key to do it now) " meow
echo
pachctl put file housing_data@staging:housing-simplified.csv -f housing-simplified-ac.csv

read -n 1 -t 5 -p "list branch in 5 seconds (press any key to do it now) " meow
echo 
pachctl list branch housing_data

read -n 1 -t 5 -p "listing job in 5 seconds (press any key to do it now) " meow
echo
pachctl list job --no-pager


read -n 1 -t 5 -p "deleting commit in 5 seconds (press any key to do it now) " meow
echo 
pachctl delete commit housing_data@staging

read -n 1 -t 5 -p "list branch in 5 seconds (press any key to do it now) " meow
echo 
pachctl list branch housing_data

read -n 1 -t 5 -p "listing job in 5 seconds (press any key to do it now) " meow
echo
pachctl list job --no-pager

read -n 1 -t 5 -p "putting file in 5 seconds (press any key to do it now) " meow
echo
pachctl put file housing_data@staging:housing-simplified.csv -f housing-simplified-ad.csv

read -n 1 -t 5 -p "list branch in 5 seconds (press any key to do it now) " meow
echo 
pachctl list branch housing_data

read -n 1 -t 5 -p "listing job in 5 seconds (press any key to do it now) " meow
echo
pachctl list job --no-pager


read -n 1 -t 5 -p "putting file in 5 seconds (press any key to do it now) " meow
echo
pachctl put file housing_data@staging:housing-simplified.csv -f housing-simplified-ae.csv

read -n 1 -t 5 -p "list branch in 5 seconds (press any key to do it now) " meow
echo 
pachctl list branch housing_data

read -n 1 -t 5 -p "listing job in 5 seconds (press any key to do it now) " meow
echo
pachctl list job --no-pager

read -n 1 -t 5 -p "deleting commit in 5 seconds (press any key to do it now) " meow
echo 
pachctl delete commit housing_data@staging

read -n 1 -t 5 -p "listing job in 5 seconds (press any key to do it now) " meow
echo
pachctl list job --no-pager

read -n 1 -t 5 -p "putting file in 5 seconds (press any key to do it now) " meow
echo
pachctl put file housing_data@staging:housing-simplified.csv -f housing-simplified-ac.csv

read -n 1 -t 5 -p "list branch in 5 seconds (press any key to do it now) " meow
echo 
pachctl list branch housing_data

read -n 1 -t 5 -p "listing job in 5 seconds (press any key to do it now) " meow
echo
pachctl list job --no-pager

read -n 1 -t 5 -p "putting file in 5 seconds (press any key to do it now) " meow
echo
pachctl put file housing_data@staging:housing-simplified.csv -f housing-simplified-ae.csv

read -n 1 -t 5 -p "list branch in 5 seconds (press any key to do it now) " meow
echo 
pachctl list branch housing_data

read -n 1 -t 5 -p "listing job in 5 seconds (press any key to do it now) " meow
echo
pachctl list job --no-pager

