#! /usr/bin/env python
# -*- coding: utf-8 -*-
import sys, os, os.path, numpy, caffe

MEAN_FILE = 'python/caffe/imagenet/ilsvrc_2012_mean.npy'
MODEL_FILE = 'models/bvlc_reference_caffenet/feature.prototxt'
PRETRAINED = 'models/bvlc_reference_caffenet/bvlc_reference_caffenet.caffemodel'
LAYER = 'fc6wi'
INDEX = 4

net = caffe.Classifier(MODEL_FILE, PRETRAINED)
net.set_phase_test()
net.set_mode_cpu()
net.set_mean('data', numpy.load(MEAN_FILE))
net.set_raw_scale('data', 255)
net.set_channel_swap('data', (2,1,0))

image = caffe.io.load_image(sys.argv[1])
net.predict([ image ])
feat = net.blobs[LAYER].data[INDEX].flatten().tolist()

for i,f in enumerate(feat):
   print(str(i+1) + ":" + str(f)),
# print(' '.join(map(str, feat)))

