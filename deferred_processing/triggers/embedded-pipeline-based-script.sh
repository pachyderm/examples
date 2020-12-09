#!/bin/sh

# Note: work in progress, waiting for a build to test this.

echo "deleting existing pipelines"
pachctl delete pipeline regression
pachctl delete repo housing_data
echo "creating repo"
pachctl create repo housing_data
echo "creating pipeline with trigger"
pachctl create pipeline -f regression-trigger.json

read -n 1 -t 5 -p "list branch in 5 seconds (press any key to do it now) " meow
echo 
pachctl list branch housing_data


read -n 1 -t 5 -p "inspect branch in 5 seconds (press any key to do it now) " meow
echo 
pachctl inspect branch housing_data@regression-trigger-1

read -n 1 -t 5 -p "putting data in 5 seconds (press any key to do it now) " meow
echo
pachctl put file housing_data@regression-trigger-1:housing-simplified.csv -f housing-simplified-aa.csv

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
pachctl put file housing_data@regression-trigger-1:housing-simplified.csv -f housing-simplified-ab.csv

read -n 1 -t 5 -p "list branch in 5 seconds (press any key to do it now) " meow
echo 
pachctl list branch housing_data

read -n 1 -t 5 -p "listing job in 5 seconds (press any key to do it now) " meow
echo
pachctl list job --no-pager

read -n 1 -t 5 -p "putting file in 5 seconds (press any key to do it now) " meow
echo
pachctl put file housing_data@regression-trigger-1:housing-simplified.csv -f housing-simplified-ac.csv

read -n 1 -t 5 -p "list branch in 5 seconds (press any key to do it now) " meow
echo 
pachctl list branch housing_data

read -n 1 -t 5 -p "listing job in 5 seconds (press any key to do it now) " meow
echo
pachctl list job --no-pager

