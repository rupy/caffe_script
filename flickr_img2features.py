#! /usr/bin/env python
# -*- coding: utf-8 -*-
import sys, os, os.path, numpy, caffe, re, logging

MEAN_FILE = 'python/caffe/imagenet/ilsvrc_2012_mean.npy'
MODEL_FILE = 'models/bvlc_reference_caffenet/feature.prototxt'
PRETRAINED = 'models/bvlc_reference_caffenet/bvlc_reference_caffenet.caffemodel'
LAYER = 'fc6wi'
INDEX = 4

DATASET_DIR = '../dataset/mirflickr'

def file_num_sort(a, b):
  a_num = re.sub(r'[^0-9]+', '', a)
  b_num = re.sub(r'[^0-9]+', '', b)
  if a_num == '' or b_num == '':
    return cmp(a, b)
  else:
    return cmp(int(a_num), int(b_num))

if __name__=="__main__":

  program = os.path.basename(sys.argv[0])
  logger = logging.getLogger(program)
  logging.basicConfig(format='%(asctime)s : %(levelname)s : %(message)s')
  logging.root.setLevel(level=logging.INFO)
  logger.info("running %s" % ' '.join(sys.argv))

  net = caffe.Classifier(MODEL_FILE, PRETRAINED)
  net.set_phase_test()
  net.set_mode_cpu()
  net.set_mean('data', numpy.load(MEAN_FILE))
  net.set_raw_scale('data', 255)
  net.set_channel_swap('data', (2,1,0))

  image_files = os.listdir(DATASET_DIR)
  image_files = sorted([
  image_file for image_file in image_files
  if  image_file.endswith(".jpg")
  or image_file.endswith(".jpeg")
  or image_file.endswith(".png")
  ], cmp=file_num_sort)

  features = [None] * len(image_files)

  for i, image_file in enumerate(image_files):
    # 'im1234.jpg' => 1234
    file_num = int(re.sub(r'[^0-9]+', '', image_file))

    image_path = DATASET_DIR + "/" + image_file
    # show filename & progress
    logger.info(
      "extracting features: %s %3d%% (%5d/%d)" % (
        image_file,
        (i + 1) * 100 / len(image_files), # progress rate
        i + 1,
        len(image_files)
        )
      )
    # show progress
    # extract features
    image = caffe.io.load_image(image_path)
    net.predict([ image ])
    feat = net.blobs[LAYER].data[INDEX].flatten().tolist()
    # add to list
    features[file_num - 1] = feat

  logger.info("converting features to numpy array.")
  features_arr = numpy.array(features)
  logger.info("saving.")
  numpy.save('features', features_arr)