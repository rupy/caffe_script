
dataset_path=$1
prefix=$2
num_output=`ls -1 $dataset_path | wc -l`
workspace=${prefix}_results/fine_tuning

mkdir -p $workspace

# 画像リストの作成
sh caffe_script/file_category_format.sh $dataset_path train > ${workspace}/train.txt
sh caffe_script/file_category_format.sh $dataset_path test > ${workspace}/val.txt

# データベースの作成
build/tools/convert_imageset --backend leveldb --resize_height 256 --resize_width 256 --shuffle $dataset_path ${workspace}/train.txt ${workspace}/${prefix}_train_leveldb
build/tools/convert_imageset --backend leveldb --resize_height 256 --resize_width 256 --shuffle $dataset_path ${workspace}/val.txt ${workspace}/${prefix}_val_leveldb

# meanファイルの作成
build/tools/compute_image_mean ${workspace}/${prefix}_train_leveldb ${workspace}/${prefix}_mean.binaryproto leveldb

#
cp models/bvlc_reference_caffenet/train_val.prototxt ${workspace}/${prefix}_train_val.prototxt
cp models/bvlc_reference_caffenet/solver.prototxt ${workspace}/${prefix}_solver.prototxt

#
cat ${workspace}/${prefix}_train_val.prototxt \
| sed -e "s|source: \"examples/imagenet/ilsvrc12_train_lmdb\"|source: \"${workspace}/${prefix}_train_leveldb\"|"\
 -e "s|backend: LMDB|backend: LEVELDB|g" \
 -e "s|batch_size: 256|batch_size: 32|" \
 -e "s|mean_file: \"data/ilsvrc12/imagenet_mean.binaryproto\"|mean_file: \"${workspace}/${prefix}_mean.binaryproto\"|" \
 -e "s|source: \"examples/imagenet/ilsvrc12_val_lmdb\"|source: \"${workspace}/${prefix}_val_leveldb\"|" \
 -e "s|\"fc8\"|\"fc8ft\"|g" \
 -e "s|num_output: 1000|num_output: ${num_output}|" \
> ${workspace}/${prefix}_train_val_edited.prototxt

cat ${workspace}/${prefix}_solver.prototxt \
| sed -e "s|net: \"models/bvlc_reference_caffenet/train_val.prototxt\"|net: \"${workspace}/${prefix}_train_val_edited.prototxt\"|" \
 -e "s|test_iter: 1000|test_iter: 100|" \
 -e "s|test_interval: 1000|test_interval: 10|" \
 -e "s|base_lr: 0.01|base_lr: 0.001|" \
 -e "s|display: 20|display: 10|" \
 -e "s|snapshot: 10000|snapshot: 100|" \
 -e "s|snapshot_prefix: \"models/bvlc_reference_caffenet/caffenet_train\"|snapshot_prefix: \"${workspace}/caffenet_train\"|" \
> ${workspace}/${prefix}_solver_edited.prototxt

build/tools/caffe train -solver ${workspace}/${prefix}_solver_edited.prototxt -weights models/bvlc_reference_caffenet/bvlc_reference_caffenet.caffemodel
