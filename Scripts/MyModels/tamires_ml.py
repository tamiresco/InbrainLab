import argparse
import numpy as np
import pandas as pd
import random
import shap 
import sys   
from matplotlib import pyplot as plt
from sklearn.metrics import r2_score, f1_score, plot_confusion_matrix
from lightgbm import LGBMRegressor, LGBMClassifier, plot_tree
    
    
def parse_args():
    parser = argparse.ArgumentParser()
    
    parser.add_argument('--path_data', dest='path_data', type=str, required=False, default="/home/brunovieira/Tamires_Experiments/Bases_de_Dados/Xy_Voxels_665.parquet")
    parser.add_argument('--path_images', dest='path_images', type=str, required=False, default="/home/brunovieira/Tamires_Experiments/Outputs/Images/")
    parser.add_argument('--sample_size', dest='sample_size', type=int, required=False, default=50)
    parser.add_argument('--target', dest='target', type=str, required=False, default="thickness")
    parser.add_argument('--categorical_target', dest='categorical_target', type=bool, required=False, default=False)
    parser.add_argument('--features', dest='features',nargs='+',type=str, required=False, 
                        default=['age', 'area', 'curv', 'sulc','bigbrain_layer_1','bigbrain_layer_2', 'bigbrain_layer_3','bigbrain_layer_4','bigbrain_layer_5', 'bigbrain_layer_6'])
    parser.add_argument('--categorical_feature', dest='categorical_feature',nargs='+',type=str, required=False, default=[])
    parser.add_argument('--voxel', dest='voxel', type=bool, required=False, default=False)
    parser.add_argument('--structure_selection', dest='structure_selection', type=int, required=False, default=0)
    parser.add_argument('--visualization', dest='visualization', type=bool, required=False, default=True)
    parser.add_argument('--explicability', dest='explicability', type=bool, required=False, default=True)    
    parser.add_argument('--resume', dest='resume', type=bool, required=False, default=True)
    
    args = parser.parse_args()
    
    return args
        
def preprocessing(path_data, sample_size):
   
    ###### Data
    
    print('-> Data Loader Started')
    Xy = pd.read_parquet(path_data)
    Xy = Xy.rename(columns={'thickness':'curv', 'curv':'thickness'})
    print('-> Data Loader Finished')
    
    main = ['participant', 'thickness', 'age', 'structure']
    geometrics =['area', 'curv', 'sulc']
    atlas = ['atlasDF', 'atlasEcono']
    basic =['hemisphere', 'sex', 'handedness']
    basic_dummies =['hemisphere_left', 'sex_FEMALE']
    structure_dummies =['structure_FA', 'structure_FB', 'structure_FC', 'structure_FCBm',
                        'structure_FD', 'structure_FDT', 'structure_FDdelta', 'structure_FE',
                        'structure_FF', 'structure_FG', 'structure_FH', 'structure_FJK',
                        'structure_IA', 'structure_IB', 'structure_LA1', 'structure_LA2',
                        'structure_LC1', 'structure_LC2', 'structure_LC3', 'structure_LD',
                        'structure_OA', 'structure_OB', 'structure_OC', 'structure_PA',
                        'structure_PB', 'structure_PC', 'structure_PD', 'structure_PE',
                        'structure_PF', 'structure_PG', 'structure_PH', 'structure_TA',
                        'structure_TB', 'structure_TC', 'structure_TD', 'structure_TE',
                        'structure_TF', 'structure_TG']
    bb1 =['ve_1','ve_2', 've_3', 've_4', 've_5', 've_6']
    bb2 =['ve1_age', 've2_age', 've3_age','ve4_age', 've5_age', 've6_age']
    bb3 =['bigbrain_layer_1','bigbrain_layer_2', 'bigbrain_layer_3',
          'bigbrain_layer_4','bigbrain_layer_5', 'bigbrain_layer_6']
    bb4 =['bblayer1_age', 'bblayer2_age', 'bblayer3_age', 
          'bblayer4_age','bblayer5_age', 'bblayer6_age'] 
    
    ##### Criando sub amostra com N participantes
    
    if sample_size == 'all':
        sample = Xy
    else:
        participants_list0 = Xy.participant.unique()
        participants_test0 = random.sample(list(participants_list0), sample_size)
        sample = Xy[Xy.participant.isin(participants_test0)]

    ##### Dropando voxels thickness are zeros

    sample = sample[sample['thickness'].astype(bool)]

    ##### Separando Treino e Teste 20% 

    n_test = int(len(participants_test0)*0.2)
    participants_test = random.sample(list(participants_test0), n_test)
    Xy_test = sample[sample.participant.isin(participants_test)]
    Xy_train = sample[~sample.participant.isin(participants_test)]

    ##### Criando Base a Nivel de Voxel
   
    Xy_train_vo = Xy_train.drop(columns = ['participant', 'structure']) 
    Xy_test_vo = Xy_test.drop(columns = ['participant', 'structure']) 
    
    ##### Criando Base Agrupada

    # treino
    list_g = []
    for i, participant in enumerate(Xy_train.participant.unique()):
        df_g = Xy_train[Xy_train.participant == participant].groupby(['structure']).mean()
        list_g.append(df_g)

    Xy_train_gr = pd.concat(list_g) 
    Xy_train_gr = Xy_train_gr.reset_index(drop=True)

    # test
    list_g = []
    for i, participant in enumerate(Xy_test.participant.unique()):
        df_g = Xy_test[Xy_test.participant == participant].groupby(['structure']).mean()
        list_g.append(df_g)

    Xy_test_gr = pd.concat(list_g) 
    Xy_test_gr = Xy_test_gr.reset_index(drop=True)
    
    list_Xy = [Xy_train_vo, Xy_test_vo, Xy_train_gr, Xy_test_gr]
    
    return list_Xy
    
def model(list_Xy, target, categorical_target, features, categorical_feature, voxel, structure_selection, 
          visualization, explicability, resume, path_images):
    
    Xy_train_vo, Xy_test_vo, Xy_train_gr, Xy_test_gr = list_Xy
    
    ################### X y split
        
    X_train_vo = Xy_train_vo.drop(columns = [target]) 
    X_test_vo = Xy_test_vo.drop(columns = [target]) 
    y_train_vo = Xy_train_vo[target]
    y_test_vo = Xy_test_vo[target]
    
    X_train_gr = Xy_train_gr.drop(columns=[target])
    y_train_gr = Xy_train_gr[target]
    X_test_gr = Xy_test_gr.drop(columns=[target])
    y_test_gr = Xy_test_gr[target]   
    
    ##################### voxel or regions
    
    if voxel:
        model_type = 'Voxels'
        alpha_scatter = 0.1
        X_train = X_train_vo[features]
        X_test = X_test_vo[features]
        y_train = y_train_vo
        y_test = y_test_vo
    else:
        model_type = 'RegioesCorticais'
        alpha_scatter = 0.8
        X_train = X_train_gr[features]
        X_test = X_test_gr[features]
        y_train = y_train_gr
        y_test = y_test_gr
    
    if structure_selection != 0:
        index_train = X_train_gr.atlasEcono == structure
        index_test = X_train_gr.atlasEcono == structure
        X_train = X_train[index_train]
        X_test = X_test[index_test]
        y_train = y_train[index_train]
        y_test = y_test[index_test]
        
    ################ resume
    
    if categorical_target:
        model_name = 'LGBMClassifier'
    else:
        model_name = 'LGBMRegressor'
    if resume:
        print('MODEL RESUME:\n\n'+
              '- Target: '+target+'\n\n'+
              '- Features: '+ ', '.join(map(str, features)) +'\n\n'+
              '- Nivel: '+ model_type +'\n\n'+
              '- Algoritmo: '+model_name+'\n\n'+
              '- Base de Dados: '+ str(sample_size)+ 
              ' individuos que geram '+ str(len(X_test)+len(X_train))+' '+model_type+' - 80% treino e 20% teste\n\n'
             )
    else:
        print('- Features: '+ ', '.join(map(str, features)) +'\n')
        
    model_resume = 'T-'+target+'_F-'+'_'.join(map(str, features))+'_'+'S-'+ str(sample_size)+'_'+ model_type
    
    ################### model
    
    if categorical_target:
        
        # transformation data
        y_train = y_train.astype(int)
        y_test = y_test.astype(int)

        # train
        model = LGBMClassifier(n_jobs=-1, categorical_feature = categorical_feature).fit(X_train, y_train)
        
        # test
        y_pred = model.predict(X_test)
        f1 = round(f1_score(y_test, y_pred, average='micro'),2)
        if visualization:
            fig, ax = plt.subplots(figsize=(12, 12))
            plt.title('F1 = ' + str(f1))
            plot_confusion_matrix(model, X_test, y_test, cmap=plt.cm.Blues, ax=ax)
            plt.savefig(fname=path_images+model_resume+'_matrix.png')
        else:
            return f1
        
    else:
        
        # train
        model = LGBMRegressor(n_jobs=30, categorical_feature = categorical_feature).fit(X_train, y_train)
        
        # test
        y_pred = model.predict(X_test)
        r2 = round(r2_score(y_test, y_pred),2)
        if visualization:
            plt.figure(figsize=[8,8])
            plt.title('R2 = '+str(r2))
            plt.xlabel("true")
            plt.ylabel("prediction")
            plt.scatter(y_test,y_pred,alpha = alpha_scatter)
            plt.savefig(fname=path_images+model_resume+'_scatter.png')
        else:
            return r2

    ############### explicabilidade
    
    if explicability: 
        shap_values = shap.TreeExplainer(model).shap_values(X_test)
        
        plt.figure()
        shap.summary_plot(shap_values, X_test, plot_type="bar", show=False)
        plt.savefig(fname=path_images+model_resume+'_shap0.png')
        
        plt.figure()
        shap.summary_plot(shap_values, X_test, show=False)
        plt.savefig(fname=path_images+model_resume+'_shap1.png')
        
        ax = plot_tree(model, figsize = (30,30), filename = path_images+model_resume+'_tree.png',
                       show_info = ['split_gain','internal_value','internal_count','data_percentage','leaf_count',])        
        fig = ax.figure
        fig.savefig(path_images+model_resume+'_tree.png') 
        
        
if __name__ == '__main__':
    
    params = parse_args()
    path_data = params.path_data
    path_images = params.path_images
    sample_size = params.sample_size
    target = params.target
    categorical_target = params.categorical_target
    features = params.features
    categorical_feature = params.categorical_feature
    voxel = params.voxel
    structure_selection = params.structure_selection
    visualization = params.visualization
    explicability = params.explicability
    resume = params.resume
    
    print('-> Preprocessing Started')
    list_Xy = preprocessing(path_data,sample_size)
    print('-> Preprocessing Finished and Modeling Started')
    model(list_Xy, target, categorical_target, features, categorical_feature, voxel, structure_selection, 
          visualization, explicability, resume, path_images)
    