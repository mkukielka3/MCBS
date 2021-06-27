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


def plot_multiclass_ROC(y_test, y_pred, labels, average="macro", figsize = (10, 8),
                       save=False, model_nm = "model"):
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
    plt.title("ROC plot")
    
    if save:
        plt.savefig(f'../figures/{model_nm}_roc.png')
    
    plt.show()
    auc_score = roc_auc_score(y_test, y_pred, average=average)
    print(f'Macro AUC: {auc_score}')
    

def ROC_plot(test_response, scores):
    """Simple ROC plot for binary classification"""
    fpr, tpr, thresholds = roc_curve(test_response, scores)
    roc_auc = roc_auc_score(test_response, scores)
    print("AUC of ROC Curve:", roc_auc)
          
    plt.figure()
    lw = 2
    plt.plot(fpr, tpr, color='darkorange',
             lw=lw, label='ROC curve (area = %0.2f)' % roc_auc)
    plt.plot([0, 1], [0, 1], color='navy', lw=lw, linestyle='--')
    plt.xlim([0.0, 1.0])
    plt.ylim([0.0, 1.05])
    plt.xlabel('False Positive Rate')
    plt.ylabel('True Positive Rate')
    plt.title('Receiver operating characteristic')
    plt.legend(loc="lower right")
    plt.show()

def plot_CM_heatmap(y_test, y_pred, labels = None, save = True,
                    model_nm = "model", norm = 'true', annot = True, figsize = (12,8)):
    """ Visual representation of multiclass confusion matrix """
    plt.figure(figsize = figsize)
    
    if not norm:
        fmt = 'd'
    else:
        fmt = ".2"
    
    ax = sns.heatmap(confusion_matrix(y_test, y_pred, normalize=norm),
                     xticklabels = labels, yticklabels = labels,  
                     cmap="binary", annot=annot, fmt = fmt)

    plt.xlabel("Predicted")
    plt.ylabel("True")
    plt.xticks(rotation=50, ha="right")
    if save:
        plt.savefig(f'../figures/{model_nm}_conf_mat.png')
        
    plt.title("Confusion Matrix")
    plt.show()

    
def plot_hist(hist):
    plt.subplots(1,2, figsize=(15,5))
    plt.subplot(1,2,1)
    plt.plot(hist["accuracy"])
    plt.plot(hist["val_accuracy"])
    plt.ylabel("Accuracy")
    plt.xlabel("Epoch")
    plt.legend(["Train", "Validation"], loc="upper left")

    plt.subplot(1,2,2)
    plt.plot(hist["loss"])
    plt.plot(hist["val_loss"])
    plt.ylabel("Loss")
    plt.xlabel("Epoch")
    plt.legend(["Train", "Validation"], loc="upper right")
    plt.show()

def CM_measures(cm, labels = None):
    """ Returns a DataFrame containing confusion matrix- based measures """
    cmdict = {}
    
    FP = cm.sum(axis=0) - np.diag(cm)  
    FN = cm.sum(axis=1) - np.diag(cm)
    TP = np.diag(cm)
    TN = cm.sum() - (FP + FN + TP)

    FP = FP.astype(float)
    FN = FN.astype(float)
    TP = TP.astype(float)
    TN = TN.astype(float)
    
    # Accuracy
    cmdict['Accuracy'] = (TP + TN)/(TP + TN + FP + FN)
    # Sensitivity, hit rate, recall, or true positive rate
    cmdict['Sensitivity'] = TP/(TP+FN)
    # Specificity or true negative rate
    cmdict['Specificity'] = TN/(TN+FP) 
    # Precision or positive predictive value
    cmdict['Precision'] = TP/(TP+FP)
    
    cmdict['Support'] = (FN + TP).astype(int)
    
    df = pd.DataFrame.from_dict(cmdict, orient='columns')
   
    if labels:
        df.index = labels
    
    return df