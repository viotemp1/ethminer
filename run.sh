#!/bin/bash


user_worker="3HyomGyZZoRRVzx1sacg8f7NYcer1yuqPV.worker1"
pass="9iIUgwoAkmNT2Wo3"

#docker_run_cmd="miner.sh -l $algo_server -u $user_worker -p $pass -d 2 -t 3 -cv 1 -cd 0 -cb 72 -ct 128"
docker_run_cmd="miner.sh -l $algo_server -u $user_worker -p $pass -d 2 -t 3 -cv 1 -cd 0 1"

#echo $docker_run_cmd

#docker run --rm -i --cpus=3 --gpus '"device=1"' -t ethminer ${docker_run_cmd}
docker run --rm -i --cpus=3 --gpus '"device=0,1"' -t ethminer ${docker_run_cmd}

#Parameters:
