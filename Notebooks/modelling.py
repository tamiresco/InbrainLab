import numpy as np
import pandas as pd
import random
import shap 
import pickle5 as pickle
from matplotlib import pyplot as plt
from sklearn.metrics import r2_score, f1_score, plot_confusion_matrix
from lightgbm import LGBMRegressor, LGBMClassifier, plot_tree
from sklearn.model_selection import GridSearchCV
from tqdm import tqdm


def model_with_tuning(X_train, y_train, n):
    search_space = {'n_estimators': np.linspace(50, 700, n, dtype=int),
                    'num_leaves': np.linspace(10, 50, n, dtype=int),
                    'max_depth': np.linspace(1, 10, n, dtype=int),
                    'learning_rate': np.linspace(0.005, 0.1, n),
                    'subsample_for_bin': np.linspace(20000, 300000, n, dtype=int),
                    'min_child_samples': np.linspace(10, 100, n, dtype=int),
                    'reg_alpha': np.linspace(0, 100, n, dtype=int),
                    'reg_lambda': np.linspace(0, 100, n, dtype=int),
                   }
    lgbm = LGBMRegressor()
    gs = GridSearchCV(lgbm, param_grid=search_space, 
                      scoring="r2",
                      n_jobs=-1, return_train_score=True)
    gs.fit(X_train, y_train)
    gs.best_estimator_.fit(X_train, y_train)
    #y_pred = gs.best_estimator_.predict(self.X_test[self.features]) 
    #gs.best_params_, gs.best_score_, r2_score(self.y_test, y_pred)
    return gs.best_estimator_, gs.best_params_


class Model:
    
    def __init__(self,
                 list_Xy,
                 path_images_outputs,
                 target = 'thickness',
                 categorical_target = False,
                 features = ['age'] + ['area', 'curv', 'sulc'] + ['bigbrain_layer_1','bigbrain_layer_2', 'bigbrain_layer_3',
      'bigbrain_layer_4','bigbrain_layer_5', 'bigbrain_layer_6'] , 
                 hyperparameter_search_size = 10,
                 voxel = False,
                 structure_modeling = False,
                 structure_evaluation = False
                 ):
        
        self.list_Xy = list_Xy
        self.target = target
        self.categorical_target = categorical_target
        self.features = features
        self.hyperparameter_search_size = hyperparameter_search_size
        self.voxel = voxel
        self.structure_modeling = structure_modeling
        self.structure_evaluation = structure_evaluation
        self.path_images = path_images_outputs     
        self.Xy_train_vo, self.Xy_test_vo, self.Xy_train_gr, self.Xy_test_gr = list_Xy

        if voxel:
            self.model_type = 'Vertices'
            ide = 0
            self.alpha_scatter = 0.1
            self.X_train = self.Xy_train_vo[features + ['h_structure']]
            self.X_test = self.Xy_test_vo[features + ['h_structure']]
            self.y_train = self.Xy_train_vo[target]
            self.y_test = self.Xy_test_vo[target]
        else:
            self.model_type = 'Estruturas Corticais'
            ide = 2
            self.alpha_scatter = 0.8
            self.X_train = self.Xy_train_gr[features + ['h_structure']]
            self.X_test = self.Xy_test_gr[features + ['h_structure']]
            self.y_train = self.Xy_train_gr[target]
            self.y_test = self.Xy_test_gr[target]
        
        # train
        self.model, self.best_params = model_with_tuning(self.X_train[features], self.y_train, n=self.hyperparameter_search_size)
        
        # train model structures    
        if structure_modeling:
            models = []
            h_structure_list = [str(x) for x in self.list_Xy[ide].h_structure.unique()]
            try:
                h_structure_list.remove('nan')
            except:
                pass
            for i in h_structure_list:
                X_train_i = self.X_train[self.X_train.h_structure == i][features]
                y_train_i = self.y_train[self.X_train.h_structure == i]
                best_estimator, best_params = model_with_tuning(X_train_i, y_train_i, n=self.hyperparameter_search_size)
                models.append([i, best_estimator])
            self.models = pd.DataFrame(models)        
        
              
    def set_resume(self): 
        if self.voxel:
            len_instances = len(self.Xy_train_vo)+len(self.Xy_test_vo)
        else:
            len_instances = len(self.Xy_train_gr)+len(self.Xy_test_gr)
        if self.structure_modeling:
            params = []
        else:
            params = self.best_params
        len_participants = (len(self.Xy_train_gr)+len(self.Xy_test_gr))/(2*len(self.Xy_train_gr.atlasEcono.unique()))
        return {'Target ':self.target,
                'Features': ', '.join(map(str, self.features)), 
                'Algoritmo': 'LGBMClassifier',
                'Hyperparameters': params,
                'Base de Dados instancias': len_instances,
                'Base de Dados participantes': len_participants,
                'Model Type': self.model_type,
                'structure_modeling': self.structure_modeling ,
                'structure_evaluation': self.structure_evaluation
               }
        
        
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
            text_file.write(str(self.set_resume()))
        # shaps
        shap_values = shap.TreeExplainer(self.model).shap_values(self.X_test[self.features])
        plt.figure()
        shap.summary_plot(shap_values, self.X_test[self.features], plot_type="bar", show=False)
        plt.savefig(fname=self.path_images+'shap0.png')
        plt.figure()
        shap.summary_plot(shap_values, self.X_test[self.features], show=False)
        plt.savefig(fname=self.path_images+'shap1.png')
        # tree
        try:
            ax = plot_tree(self.model, figsize = (30,30), filename = self.path_images+'tree.png',
                           show_info = ['split_gain','internal_value','internal_count','data_percentage','leaf_count',])        
            fig = ax.figure
            fig.savefig(self.path_images+'tree.png') 
        except:
            pass
      
        
    def learning_curv(self, list_sizes = [20,100,250,400,550,696]):
        X_test = self.Xy_test_gr[self.features]
        y_test = self.Xy_test_gr[self.target]
        n_strutures = 72
        list_sizes = np.array(list_sizes) * n_strutures 
        aux_learning_curve = []

        for sample_size in tqdm(list_sizes):
            for bootstrap in range(5):
                X_train = self.Xy_train_gr.head(sample_size).sample(frac=1, replace=True, random_state=bootstrap)[self.features]
                y_train = self.Xy_train_gr.head(sample_size).sample(frac=1, replace=True, random_state=bootstrap)[self.target]
                lgbm = LGBMRegressor().fit(X_train, y_train)
                r2 = r2_score(y_test, lgbm.predict(X_test))
                mean_r2_strutures = 0
                aux_learning_curve.append([sample_size, r2, mean_r2_strutures])
                
        df_lc_mean = pd.DataFrame(aux_learning_curve, columns=['train_size','r2',
                                                               'mean_r2_strutures']).groupby('train_size').mean().reset_index()
        df_lc_std = pd.DataFrame(aux_learning_curve, columns=['train_size', 'r2',
                                                              'mean_r2_strutures']).groupby('train_size').std().reset_index()
        plt.fill_between(df_lc_mean.train_size/n_strutures, 
                         df_lc_mean.r2-df_lc_std.r2,
                         df_lc_mean.r2+df_lc_std.r2, 
                         color='b', 
                         alpha=.15)
        plt.errorbar(df_lc_mean.train_size/n_strutures, df_lc_mean.r2, df_lc_std.r2)
        plt.ylabel('R2')
        plt.xlabel('train size')
        plt.show()
        plt.savefig(fname=self.path_images+'learning_curv.png')        

     
