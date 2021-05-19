#!/bin/bash -u
#

_help(){

cat >&2 <<-EOF
Usage: $1 [OPTION] ...
	  -g                     use Nvidia GPU(s)
	  -a ALGORITHM           mining algorithm (e.g., scrypt, equihash)
	  -u BITCOIN_ADDRESS     your Nicehash wallet address
	  -w WORKER              default is hostname
	  -t CPU_THREADS         default is nproc
EOF

exit

}

# associate algorithms with stratum server ports
typeset -A NICEHASH
NICEHASH[scrypt]=3333
NICEHASH[neoscrypt]=3341
NICEHASH[daggerhashimoto]=3353
NICEHASH[cryptonight]=3355
NICEHASH[lbry]=3356
NICEHASH[equihash]=3357
NICEHASH[x11gost]=3359

# configure ethminer, sgminer
export GPU_FORCE_64BIT_PTR=0
export GPU_MAX_HEAP_SIZE=100
export GPU_USE_SYNC_OBJECTS=1
export GPU_MAX_ALLOC_PERCENT=100
export GPU_SINGLE_ALLOC_PERCENT=100

# opts
while getopts ga:u:w:t:h OPT;do
  case $OPT in
    g) FLAGS+=$OPT;; # start a GPU miner if possible
    a) ALGORITHM=$OPTARG;;
    u) XBT=$OPTARG;;
    w) WORKER=$OPTARG;;
    t) THREADS=$OPTARG;;
    *|h) _help $(basename $0);;
  esac
done
shift "$((OPTIND-1))"

# defaults
: ${ALGORITHM:=cryptonight}
: ${XBT:=3FRTZmp2uP1QXApbCzys6auMsNfQ5co6sw}
: ${THREADS:=$(nproc)}
: ${WORKER:=${HOSTNAME%%.*}}

# continuously alternate between the two nearest regions
while :; do
  for REGION in usa eu;do
    case $ALGORITHM in
      daggerhashimoto)
        if [[ ${FLAGS:-x} =~ g ]]; then
          ~/Sites/ethminer/build/ethminer/ethminer \
            --cuda-parallel-hash 2 \
            --farm-recheck 999 \
            --cuda \
            --stratum-protocol 2 \
            -S "${ALGORITHM}.${REGION}.nicehash.com:${NICEHASH[$ALGORITHM]}" \
            --user "${XBT}.${WORKER}gpu"
        else
          false
        fi
        ;;
      lbry)
        if [[ ${FLAGS:-x} =~ g ]]; then
          ~/Sites/lbrycrd-gpu/sgminer \
            --url "stratum+tcp://${ALGORITHM}.${REGION}.nicehash.com:${NICEHASH[$ALGORITHM]}" \
            --userpass "${XBT}.${WORKER}gpu:" \
            --algorithm lbry
        else
          false
        fi
        ;;
      equihash)
        pgrep -f nvidia-docker-plugin || \
          sudo -b nohup nvidia-docker-plugin > /tmp/nvidia-docker-plugin.out
        if [[ ${FLAGS:-x} =~ g ]]; then
          sudo nvidia-docker run --rm -i --name nheqminergpu unsalted/nheqminer:latest \
            nheqminer -l "${ALGORITHM}.${REGION}.nicehash.com:${NICEHASH[$ALGORITHM]}" \
             -u $XBT.${WORKER}gpu \
             -t 0 \
             -cd 0
        else
          sudo nvidia-docker run --rm -i --name nheqminercpu unsalted/nheqminer:latest \
            nheqminer -l "${ALGORITHM}.${REGION}.nicehash.com:${NICEHASH[$ALGORITHM]}" \
             -u $XBT.${WORKER}cpu \
             -t 6
        fi
        ;;
      neoscrypt)
        if [[ ${FLAGS:-x} =~ g ]]; then
          ~/Sites/nsgminer/nsgminer \
            --url "stratum+tcp://s1.theblocksfactory.com:3333" \
            --userpass "qrkourier.${WORKER}gpu:0iuE5zX3*!OtC692" \
            --cpu-threads 0 \
            --text-only \
            --${ALGORITHM}
        else
          ~/Sites/nsgminer/nsgminer \
            --url "stratum+tcp://s1.theblocksfactory.com:3333" \
            --userpass "qrkourier.${WORKER}cpu:0iuE5zX3*!OtC692" \
            --cpu-threads $THREADS \
            --enable-cpu \
            --disable-gpu \
            --text-only \
            --${ALGORITHM}
        fi
        ;;
      scrypt)
        if [[ ${FLAGS:-x} =~ g ]]; then
          ~/Sites/nsgminer/nsgminer \
            --url "stratum+tcp://${ALGORITHM}.${REGION}.nicehash.com:${NICEHASH[$ALGORITHM]}" \
            --userpass "${XBT}.${WORKER}gpu:" \
            --cpu-threads 0 \
            --text-only \
            --${ALGORITHM}
        else
          ~/Sites/nsgminer/nsgminer \
            --url "stratum+tcp://${ALGORITHM}.${REGION}.nicehash.com:${NICEHASH[$ALGORITHM]}" \
            --userpass "${XBT}.${WORKER}cpu:" \
            --cpu-threads $THREADS \
            --enable-cpu \
            --disable-gpu \
            --text-only \
            --${ALGORITHM}
        fi
        ;;
      *)
        ~/Sites/cpuminer-opt/cpuminer \
          --timeout 99 \
          --retries 1 \
          --algo $ALGORITHM \
          --threads $THREADS \
          --config ~/Sites/cpuminer-multi/cpuminer-conf.json \
          --user $XBT.${WORKER}cpu \
          --url "stratum+tcp://${ALGORITHM}.${REGION}.nicehash.com:${NICEHASH[$ALGORITHM]}"
        ;;
    esac
  sleep 11
  done
done
