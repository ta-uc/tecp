#! /bin/bash
if [ $# != 4 ]; then
  echo "too few args"
  exit 1
fi

declare -A MAP
MAP[0]=A
MAP[1]=B
MAP[2]=C
MAP[3]=D
MAP[4]=E
MAP[5]=F
MAP[6]=G
MAP[7]=H
MAP[8]=I
MAP[9]=J
MAP[10]=K

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"
NS3DIR=$DIR/ns-3/

cd $DIR > /dev/null

for i in $(seq $1 $2); do
  for j in $(seq $3 $4); do
        if [ $i != $j ]; then
          cd $DIR > /dev/null
          mkdir -p "./results/${i}-${j}-b/od_data"
          mkdir -p "./results/${i}-${j}-l/od_data"
          mkdir -p "./results/${i}-${j}-a/od_data"
          
          # 初期設定シミュレーション作成
          python3 ./python/create_sim.py --OrigNode ${MAP[$i]} --DestNode ${MAP[$j]} > ./created
          python3 ./python/combine.py
          # 初期設定シミュレーション実行
          cd $NS3DIR > /dev/null
          ./waf --cwd="../results/${i}-${j}-b" --run "created --OrigNode=${i} --DestNode=${j}"
          cd $DIR > /dev/null
          python3 ./python/get_od_data.py "${i}-${j}-b" >> ./python/od_data_before.py
          # クリーンアップ
          rm ./created
          rm $NS3DIR/scratch/created.cc

          # latentシミュレーション作成
          python3 ./python/create_sim.py --Opt --OdRate latent --OrigNode ${MAP[$i]} --DestNode ${MAP[$j]} >> created
          python3 ./python/combine.py
          # 実行
          cd $NS3DIR > /dev/null
          ./waf --cwd="../results/${i}-${j}-l" --run "created --OrigNode=${i} --DestNode=${j}"
          # 結果計算保存 
          cd $DIR > /dev/null
          python3 ./python/get_od_data.py "${i}-${j}-l" > ./results/${i}-${j}-l/od_data_result_latent.py
　　　　　　# クリーンアップ
          mv ./python/capas_incd.py ./results/$i-$j-l
          mv ./python/route.py ./results/$i-$j-l
          rm created
          rm $NS3DIR/scratch/created.cc

          # actualシミュレーション作成
          python3 ./python/create_sim.py --Opt --OdRate actual --OrigNode ${MAP[$i]} --DestNode ${MAP[$j]} >> created
          python3 ./python/combine.py
          # 実行
          cd $NS3DIR > /dev/null
          ./waf --cwd="../results/${i}-${j}-a" --run "created --OrigNode=${i} --DestNode=${j}"
          # 結果計算保存 
          cd $DIR > /dev/null
          python3 ./python/get_od_data.py "${i}-${j}-a" > ./results/${i}-${j}-a/od_data_result_actual.py
　　　　　　# クリーンアップ
          mv ./python/capas_incd.py ./results/$i-$j-l
          mv ./python/route.py ./results/$i-$j-l
          mv od_data_before.py ./results/$i-$j-b
          rm created
          rm $NS3DIR/scratch/created.cc
        fi
    done
done
