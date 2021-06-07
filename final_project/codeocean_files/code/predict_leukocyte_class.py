#!/usr/bin/env python3
# coding: utf8


from keras.preprocessing.image import ImageDataGenerator
from keras.preprocessing import image
from keras.models import Sequential
from keras.layers import Conv2D, MaxPooling2D, AveragePooling2D
from keras.layers import Activation, Dropout, Flatten, Dense
from keras.layers.normalization import BatchNormalization
from keras.callbacks import ModelCheckpoint
from keras import backend as K

#from vis.utils import utils
from imageio import imread
import numpy as np
#from scipy.misc import imsave
from imageio import imwrite
import residual_network

import sys
import os.path


classes_dictionary_org = {'BAS':0, 'EBO':1, 'EOS':2, 'KSC':3, 'LYA':4, 'LYT':5, 'MMZ':6, 'MOB':7, 'MON':8, 'MYB':9, 'MYO':10, 'NGB':11, 'NGS':12, 'PMB':13, 'PMO':14 }
classes_dictionary = {value: key for key, value in classes_dictionary_org.items()}


abbreviation_dict = { 'NGS':'Neutrophil (segmented)', 
                      'NGB':'Neutrophil (band)',
                      'EOS':'Eosinophil',
                      'BAS':'Basophil',
                      'MON':'Monocyte',
                      'LYT':'Lymphocyte (typical)',
                      'LYA':'Lymphocyte (atypical)',
                      'KSC':'Smudge Cell',
                      'MYO':'Myeloblast',
                      'PMO':'Promyelocyte',
                      'MYB':'Myelocyte',
                      'MMZ':'Metamyelocyte',
                      'MOB':'Monoblast',
                      'EBO':'Erythroblast',
                      'PMB':'Promyelocyte (bilobed)'};


img_width, img_height = 400, 400

if K.image_data_format() == 'channels_first':
        input_shape = (3, img_width, img_height)
else:
        input_shape = (img_width, img_height, 3)


if(len(sys.argv) < 2): 
    print('WARNING: No input file specified, defaulting to ../data/image_data/MYELOBLAST/Myeloblast_01_t.tiff ....')
    image_file_path = '../data/image_data/MYELOBLAST/Myeloblast_01_t.tiff'
else:
    image_file_path = sys.argv[1]

weight_file_path = "weights.hdf5"

if not os.path.exists(image_file_path):
        print ("Image file " + image_file_path+" does not exist.\nAborting.")
        sys.exit()

model = residual_network.model
model.load_weights(weight_file_path)

model.compile(loss='categorical_crossentropy',
              optimizer='adam',
              metrics=['accuracy'])

img1 = imread(image_file_path)
imwrite('../results/input_image.png',img1)
img1 = (img1[:,:,:3] *1./255)


x = image.img_to_array(img1)
x = np.expand_dims(x, axis=0)

images = np.vstack([x])
preds_probs = model.predict(images, batch_size=1)
preds_probs = np.array(preds_probs)
preds_probs[:,1]+=preds_probs[:,2]
preds_probs=np.delete(preds_probs,2,1)

print ("Network output distribution: \n----------------------------------------------")
for i in range(len(preds_probs[0])):
	print('{0:25}  {1}'.format(abbreviation_dict[classes_dictionary[i]], str(preds_probs[0][i])))

print ("\n\nPREDICTION: \n"+abbreviation_dict[classes_dictionary[np.argmax(preds_probs)]])
        

