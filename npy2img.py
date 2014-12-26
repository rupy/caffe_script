import numpy as np
from PIL import Image
import sys

if len(sys.argv) != 3:
    print "Usage: python npy2img.py input.npy output_image"
    sys.exit()

npy_file = sys.argv[1]
out_file = sys.argv[2]
mean = np.load(npy_file)
img = Image.fromarray(mean.astype('uint8').transpose((1,2,0)))
img.save(out_file)
