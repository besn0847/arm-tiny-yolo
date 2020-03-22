#!/bin/ash

export FLASK_APP=app.py

if [ ! -f /conf/.bootstrapped_yolo ]
then
	mv /yolo/* /conf/
	echo 1 > /conf/.bootstrapped_yolo
fi

cd /conf/
while(true)
do
	flask run -h 0.0.0.0
	sleep 5
done
