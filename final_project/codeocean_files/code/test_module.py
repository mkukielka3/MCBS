# coding: utf8

from sklearn.metrics import classification_report, confusion_matrix, multilabel_confusion_matrix, roc_curve, auc, roc_auc_score
import seaborn as sns
from sklearn.preprocessing import LabelBinarizer
import matplotlib.pyplot as plt
import pandas as pd
import numpy as np
import os

def save_model(input_model, model_name, history=None, zip_files = True):
    """ 
    Saves <input_model>'s' weights and state to the <model_name> directory.
    """
    
    #save the model with its weitghts
    input_model.save(f"../models/{model_name}")
    input_model.save_weights(f"../models/{model_name}/weights.h5")
    
    #save training history
    if history:
        history_dt = pd.DataFrame(history.history) 
        history_dt.to_csv(f"../models/{model_name}/history.csv")
    
    #archive model files
    if zip_files: os.system(f"zip -r ../models/{model_name}.zip ../models/{model_name}")


def plot_multiclass_ROC(y_test, y_pred, labels, average="macro", figsize = (12, 8)):
    """ ROC plot for multiclass models """
    
    lb = LabelBinarizer()
    lb.fit(y_test)
    y_test = lb.transform(y_test)
    y_pred = lb.transform(y_pred)
    
    fig, ax = plt.subplots(1,1, figsize = figsize)
    
    for i, class_label in enumerate(labels):
        fpr, tpr, thresholds = roc_curve(y_test[:,i].astype(int), y_pred[:,i])
        ax.plot(fpr, tpr, label = f'{class_label} (AUC:{auc(fpr, tpr):.2})')
                
    ax.set_xlabel('False Positive Rate')
    ax.set_ylabel('True Positive Rate')
    ax.legend(bbox_to_anchor=(1.05, 1.0), loc='upper left', frameon=False)
    plt.show()
    auc_score = roc_auc_score(y_test, y_pred, average=average)
    print(f'Macro AUC: {auc_score}')



def plot_CM_heatmap(y_test, y_pred, labels=None, save=True,
                    model_nm = "model", norm='true',
                    annot=True):
    """ Visual representation of multiclass confusion matrix """
    plt.figure(figsize = (12,8))
    
    if not norm:
        fmt = 'd'
    else:
        fmt = ".2"
    
    ax = sns.heatmap(confusion_matrix(y_test, y_pred, normalize=norm),
                     xticklabels = labels, yticklabels = labels,  
                     cmap="binary", annot=annot, fmt = fmt)

    plt.xlabel("True", fontsize=15)
    plt.ylabel("Predicted",  fontsize=15)
    plt.xticks(rotation=50, ha="right")
    if save:
        plt.savefig(f'../figures/{model_nm}_conf_mat.png')
    plt.show()

    
def plot_hist(hist):
    plt.plot(hist["accuracy"])
    plt.plot(hist["val_accuracy"])
    plt.title("model accuracy")
    plt.ylabel("Accuracy")
    plt.xlabel("Epoch")
    plt.legend(["Train", "Validation"], loc="upper left")
    plt.show()
