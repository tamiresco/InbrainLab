from boruta import BorutaPy
from lightgbm import LGBMRegressor
from matplotlib import pyplot as plt
import numpy as np
import pandas as pd
from scipy import stats
import shap
from sklearn.metrics import r2_score
from sklearn.ensemble import RandomForestRegressor

def split_train_test(df1, features, structure):
    test_index = df1[(df1.h_structure=='1'+str(structure))|(df1.h_structure=='0'+str(structure))].index #nao levar em conta hemisferio
    train_index = set(df1.index)-set(test_index)
    X, y = df1[features], df1.anual_rate
    X_train = np.array(X.loc[train_index])
    X_test = np.array(X.loc[test_index])
    y_train = np.array(y.loc[train_index])
    y_test = np.array(y.loc[test_index])
    Xy = X_train,X_test,y_train,y_test
    return Xy
    
    
def model_train(X_train,y_train):
    lgbm = LGBMRegressor()
    lgbm.fit(X_train, y_train) #, categorical_feature = categorical_feature #atrapalha o modelo usar categoricas
    return lgbm
    
    
def model_test(lgbm,X_test,y_test):
    y_pred = np.array(lgbm.predict(X_test))
    r2 = r2_score(y_test, y_pred)
    return y_pred, r2

def model_test_all(y_test, y_pred, r2):
    y_test_all = np.concatenate(y_test, axis=None)
    y_pred_all = np.concatenate(y_pred, axis=None)
    r2_all = r2_score(y_test_all, y_pred_all)
    r2_mean = r2.mean()
    r2_std = r2.std()
    r2_sem = stats.sem(r2)
    r2_mean_clean = r2[r2>0].mean()
    r2_std_clean = r2[r2>0].std()
    r2_sem_clean = stats.sem(r2[r2>0])
    inexplicable = len(r2[r2<0])
    return r2_all, r2_mean, r2_std, r2_sem, r2_mean_clean, r2_std_clean, r2_sem_clean, inexplicable


def evaluation_structures(df1, cortical_structures, r2):
    df_eval_1 = pd.DataFrame([cortical_structures,r2[0],r2[1],r2[2]]).T
    df_eval_1.columns = 'structure', 'r2_spatial', 'r2_temporal', 'r2_complete'
    df_eval_1 = pd.merge(df_eval_1, df1[['structure_name','atlas']].drop_duplicates(), left_on="structure", right_on="atlas")
    col_r2 = ['r2_spatial','r2_temporal','r2_complete']
    df_eval_1[col_r2] = df_eval_1[col_r2].where(df_eval_1[col_r2]>0, -0.01)
    return df_eval_1

    
def evaluation_features(features_sets, models_evaluation):
    df_eval_2 = pd.DataFrame(models_evaluation)
    df_eval_2['features_set'] = features_sets
    df_eval_2.columns = 'r2_all', 'r2_mean', 'r2_std', 'r2_sem','r2_mean_clean', 'r2_std_clean','r2_sem_clean','inexplicable', 'features_set'
    df_eval_2['labels'] = ['Spatial Features','Temporal Features','Temporal and Spatial Features']
    return df_eval_2


def plot_bar_models(df_eval_1, df_eval_2, vertical=False):
    # plot 1A
    df_eval_1 = df_eval_1.sort_values(by='r2_complete', ascending=False).reset_index()
    plt.figure(figsize=(20, 5), dpi=80)
    plt.bar(df_eval_1.index-0.2, df_eval_1['r2_spatial'], width=0.2, label = 'Spatial Features',color='purple',alpha=1)
    plt.bar(df_eval_1.index+0.0, df_eval_1['r2_temporal'], width=0.2, label = 'Temporal Features',color='#a17fc0',alpha=1)
    plt.bar(df_eval_1.index+0.2, df_eval_1['r2_complete'], width=0.2, label = 'Temporal and Spatial Features',color='#e75f00',alpha=1)
    plt.xticks(df_eval_1.index, df_eval_1.structure_name, rotation = 45, horizontalalignment = 'right')
    plt.legend(loc='upper right')
    plt.grid(axis='y',color='0.7', linestyle='--', linewidth=1)
    plt.show()
    # plot 1B
    if vertical:
        plt.figure(figsize=(5, 20), dpi=80)
        plt.barh(-df_eval_1.index+0.2, df_eval_1['r2_spatial'], height=0.2, label = 'Spatial Features',color='purple',alpha=1)
        plt.barh(-df_eval_1.index+0.0, df_eval_1['r2_temporal'], height=0.2, label = 'Temporal Features',color='#a17fc0',alpha=1)
        plt.barh(-df_eval_1.index-0.2, df_eval_1['r2_complete'], height=0.2, label = 'Temporal and Spatial Features',color='#e75f00',alpha=1)
        plt.yticks(-df_eval_1.index, df_eval_1.structure_name, horizontalalignment = 'right')
        plt.legend()
        plt.grid(axis='x',color='0.7', linestyle='--', linewidth=1)
        plt.show()
    # plot 2
    plt.figure(figsize=(3, 5), dpi=80)
    bar=plt.bar(df_eval_2.labels, np.round(df_eval_2.r2_mean_clean,2), color=['purple','#a17fc0','#e75f00'])
    plt.bar_label(bar,padding=10)
    plt.errorbar(df_eval_2.labels, df_eval_2.r2_mean_clean, yerr=df_eval_2.r2_sem_clean, fmt=".", color="black")
    plt.xticks(rotation = 45, horizontalalignment = 'right')
    plt.show()
    
def summarize_info(df1, df_eval_1, path=[], atlas =[]):
    # sera a base q deixarei aberta no artigo em csv
    df_summarize = df1[['h_structure', 'atlas','Hemisphere','Lobe','Thickness at 10y.o.','Thickness at 80y.o.','Curvature',
                            'Layer I thickness','Layer II thickness','Layer III thickness',
                            'Layer IV thickness','Layer V thickness','Layer VI thickness',
                            'bigbrain_layer_1', 'bigbrain_layer_2','bigbrain_layer_3', 
                            'bigbrain_layer_4', 'bigbrain_layer_5','bigbrain_layer_6'
                           ]].groupby(['h_structure']).mean()
    df_summarize['Global thinning'] = df_summarize['Thickness at 10y.o.'] - df_summarize['Thickness at 80y.o.']
    df_summarize['Global thinning normalized'] = (df_summarize['Thickness at 10y.o.'] - df_summarize['Thickness at 80y.o.'])/df_summarize['Thickness at 10y.o.']
    df_summarize = pd.merge(df_summarize, df_eval_1, left_on="atlas", right_on="structure")
    if path != []:
        df_summarize.to_csv(path+atlas+'_summary_data.csv')
    else:
        return df_summarize
    
def boruta_ranking():
    # TO DO/THINK 
    # 1 - problema da função 
    # 2 - usar o test ta certo mesmo?
    features = features_sets[-1]
    features_support = np.empty((len(cortical_structures),len(features)), dtype=object) 
    for j, structure in tqdm(enumerate(cortical_structures)):
        X_train, X_test, y_train, y_test = split_train_test(df1, cortical_structures, features)
        forest = RandomForestRegressor(n_jobs=-1, max_depth=20)
        forest.fit(X_test, y_test)
        feat_selector = BorutaPy(forest, n_estimators='auto', verbose=0, random_state=1, alpha= 0.001)
        feat_selector.fit(X_test, y_test)
        features_support[j] = feat_selector.support_
    df = pd.DataFrame(features_support)
    df.columns = features
    df['structure'] = cortical_structures
    df = pd.merge(df, df1[['structure_name','atlas']].drop_duplicates(), left_on="structure", right_on="atlas")
    return df

