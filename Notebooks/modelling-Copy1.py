import numpy as np
import pandas as pd
import random
import shap 
import pickle5 as pickle
from matplotlib import pyplot as plt
from sklearn.metrics import r2_score, f1_score, plot_confusion_matrix
from lightgbm import LGBMRegressor, LGBMClassifier, plot_tree

class Model:
    
    def __init__(self,
                 list_Xy,
                 path_images_outputs,
                 target = 'thickness',
                 categorical_target = False,
                 features = ['age'] + ['area', 'curv', 'sulc'] + ['bigbrain_layer_1','bigbrain_layer_2', 'bigbrain_layer_3',
      'bigbrain_layer_4','bigbrain_layer_5', 'bigbrain_layer_6'] , 
                 categorical_feature = [],
                 voxel = False,
                 structure_modeling = False,
                 structure_evaluation = False
                 ):
        
        self.list_Xy = list_Xy
        self.target = target
        self.categorical_target = categorical_target
        self.features = features
        self.categorical_feature = categorical_feature
        self.voxel = voxel
        self.structure_modeling = structure_modeling
        self.structure_evaluation = structure_evaluation
        self.path_images = path_images_outputs
        
        Xy_train_vo, Xy_test_vo, Xy_train_gr, Xy_test_gr = list_Xy
        
        model_name = 'LGBMClassifier'

        if voxel:
            model_type = 'Voxels'
            len_instances = len(Xy_train_vo)+len(Xy_test_vo)
        else:
            model_type = 'Regioes Corticais'
            len_instances = len(Xy_train_gr)+len(Xy_test_gr)
        
        len_participants = (len(Xy_train_gr)+len(Xy_test_gr))/(2*len(Xy_train_gr.atlasEcono.unique()))

        self.resume = '- Target: '+target+'\n\n'+'- Features: '+ ', '.join(map(str, features)) +'\n\n'+'- Nivel: '+ model_type +'\n\n'+'- Algoritmo: '+model_name+'\n\n'+'- Base de Dados: '+ str(len_instances)+ ' '+model_type+' de ' + str(len_participants)+' participantes'+' - 80% treino e 20% teste\n\n'+ '- structure_modeling = '+str(self.structure_modeling)+ '- structure_evaluation = '+str(self.structure_evaluation)
    
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
            ide = 0
            self.alpha_scatter = 0.1
            X_train = X_train_vo[features + ['h_structure']]
            X_test = X_test_vo[features + ['h_structure']]
            y_train = y_train_vo
            y_test = y_test_vo
        else:
            model_type = 'Estruturas Corticais'
            ide = 2
            self.alpha_scatter = 0.8
            X_train = X_train_gr[features + ['h_structure']]
            X_test = X_test_gr[features + ['h_structure']]
            y_train = y_train_gr
            y_test = y_test_gr
            

        ################### model

        # train
        model = LGBMRegressor(n_jobs=30, categorical_feature = categorical_feature).fit(X_train[features], y_train)
            
        if structure_modeling:
            
            # train model structures
            models = []
            h_structure_list = [str(x) for x in self.list_Xy[ide].h_structure.unique()]
            try:
                h_structure_list.remove('nan')
            except:
                pass
            for i in h_structure_list:
                X_train_i = X_train[X_train.h_structure == i][features]
                y_train_i = y_train[X_train.h_structure == i]
                models.append([i,LGBMRegressor(n_jobs=30, categorical_feature = categorical_feature).fit(X_train_i, y_train_i)])
            models = pd.DataFrame(models)
            self.models = models
            
        ################### 
        
        self.model = model
        self.X_train = X_train
        self.X_test = X_test
        self.y_train = y_train
        self.y_test = y_test 
        self.Xy_test_vo = Xy_test_vo
              
    
    def _test_structure(self, h_structure):
        n = self.models[self.models[0] == h_structure].index.values[0]
        X_test = self.X_test[self.X_test.h_structure == h_structure]
        y_pred = self.models.loc[n][1].predict(X_test[self.features])
        y_pred = pd.concat([pd.Series(y_pred), pd.Series(X_test.index)], axis=1).set_index([1])
        return y_pred
    
    
    def _test_structure_all(self):
        h_structure_list = [str(x) for x in self.list_Xy[2].h_structure.unique()]
        y_pred_all=[]
        for i in h_structure_list:  
            y_pred_all.append(self._test_structure(i))
        y_pred_all = pd.concat(y_pred_all).sort_index()
        y_test_all = self.y_test.loc[y_pred_all.index]
        return y_test_all, y_pred_all

    
    def _test_group(self):
        '''
        Modelo a nivel de vertice com agrupamento na avaliação
        '''
        Xy_av = self.Xy_test_vo[['participant','structure','thickness']]
        Xy_av['thickness_pred'] = self.model.predict(self.X_test[self.features])
        list_groupby = []
        for i, participant in enumerate(Xy_av.participant.unique()):
            df_av = Xy_av[Xy_av.participant == participant].groupby(['structure']).mean()
            df_av['participant_i'] = i
            df_av['participant'] = participant
            list_groupby.append(df_av)
        Xy_groupby = pd.concat(list_groupby)
        return Xy_groupby.thickness, Xy_groupby.thickness_pred

        
    def test(self, output):
        '''
        ouput: 
            -score(float): r2  
            -vizualization(plot): scatter plot com r2 no titulo
            -score_segmented(list): r2 para cada estrutura cortical
        '''
            
        if self.structure_evaluation:
            y_test, y_pred = self._test_group()
        if self.structure_modeling:
            y_test, y_pred = self._test_structure_all()
        else:
            y_test = self.y_test
            y_pred = self.model.predict(self.X_test[self.features])

        if output == 'vizualization':
            # scatter
            plt.figure(figsize=[8,8])
            plt.title('R2 = '+str(round(r2_score(y_test, y_pred),2)))
            plt.xlabel("true")
            plt.ylabel("prediction")
            plt.scatter(y_test,y_pred,alpha = self.alpha_scatter)
            plt.savefig(fname=self.path_images+'scatter.png')
            # hist
            plt.figure(figsize=[8,8])
            score_segmented = pd.DataFrame(self.test('score_segmented'))[1]
            plt.title('r2 por estrutura cortical, media = '+str(np.round(score_segmented.mean(),2)))
            plt.hist(score_segmented, bins=20)
            plt.savefig(fname=self.path_images+'hist.png')

        if output == 'score':
            r2 = round(r2_score(y_test, y_pred),2)
            return r2

        if output == 'score_segmented':
            if self.voxel:
                t = 1
            else:
                t = 3
            score_segmented = []
            h_structure_list = [str(x) for x in self.list_Xy[t].h_structure.unique()]
            try:
                h_structure_list.remove('nan')
            except:
                pass
            for i in h_structure_list:
                y_test_i = self.list_Xy[t][self.list_Xy[t].h_structure==i][self.target]    
                if self.structure_modeling: 
                    y_pred = self._test_structure(i)
                else:
                    X_test = self.list_Xy[t][self.list_Xy[t].h_structure==i][self.features]
                    y_pred = self.model.predict(X_test[self.features])
                r2 = round(r2_score(y_test_i, y_pred),2)
                score_segmented.append([i,r2])   
            return score_segmented    
        
        
    def explicability(self):
        # save the model to disk
        filename = self.path_images+'finalized_model.sav'
        pickle.dump(self, open(filename, 'wb'))
        # save resume
        with open(self.path_images+"resume.txt", "w") as text_file:
            text_file.write(self.resume)
        # shaps
        shap_values = shap.TreeExplainer(self.model).shap_values(self.X_test[self.features])
        plt.figure()
        shap.summary_plot(shap_values, self.X_test[self.features], plot_type="bar", show=False)
        plt.savefig(fname=self.path_images+'shap0.png')
        plt.figure()
        shap.summary_plot(shap_values, self.X_test[self.features], show=False)
        plt.savefig(fname=self.path_images+'shap1.png')
        # tree
        ax = plot_tree(self.model, figsize = (30,30), filename = self.path_images+'tree.png',
                       show_info = ['split_gain','internal_value','internal_count','data_percentage','leaf_count',])        
        fig = ax.figure
        fig.savefig(self.path_images+'tree.png') 
     
