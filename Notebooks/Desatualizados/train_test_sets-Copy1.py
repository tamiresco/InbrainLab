import numpy as np
import pandas as pd
import random
from boruta import BorutaPy
from sklearn.ensemble import RandomForestRegressor

def separate(Xy):
    
    # Hemisphere + Struture 
    Xy['h_structure'] = Xy.hemisphere.astype(str) + Xy.structure

    # Separando Treino e Teste 20% 
    participants = Xy.participant.unique()
    n_test = int(len(participants) * 0.2)
    participants_test = random.sample(list(participants), n_test)
    indexes_test = Xy.participant.isin(participants_test)
    Xy_test = Xy[indexes_test]
    Xy_train = Xy[~indexes_test]

    # Criando Base a Nivel de Voxel
    Xy_train_vo = Xy_train
    Xy_test_vo = Xy_test
    
    # Criando Base Agrupada

    # treino
    list_g = []
    for i, participant in enumerate(Xy_train.participant.unique()):
        df_g = Xy_train[Xy_train.participant == participant].groupby(['h_structure']).mean()
        df_g['h_structure'] = df_g.index
        df_g['structure'] = [a[3:] for a in df_g.index]
        list_g.append(df_g)

    Xy_train_gr = pd.concat(list_g) 
    Xy_train_gr = Xy_train_gr.reset_index(drop=True)

    # test
    list_g = []
    for i, participant in enumerate(Xy_test.participant.unique()):
        df_g = Xy_test[Xy_test.participant == participant].groupby(['h_structure']).mean()
        df_g['h_structure'] = df_g.index
        df_g['structure'] = [a[3:] for a in df_g.index]
        list_g.append(df_g)

    Xy_test_gr = pd.concat(list_g) 
    Xy_test_gr = Xy_test_gr.reset_index(drop=True)

    list_Xy = [Xy_train_vo, Xy_test_vo, Xy_train_gr, Xy_test_gr]
    
    return list_Xy

def boruta(list_Xy, path='/home/brunovieira/Tamires_Experiments/Outputs/boruta_df.csv'):
    # define random forest classifier, with utilising all cores and
    rf = RandomForestRegressor(n_jobs=-1, max_depth=5)
    # define Boruta, the feature selection method
    # 1
    feat_selector_gr = BorutaPy(rf, n_estimators='auto', verbose=2, random_state=1)
    X_gr = Xy_train_gr.drop(columns=['thickness','h_structure', 'structure'])
    y_gr = Xy_train_gr.thickness
    feat_selector_gr.fit(np.array(X_gr), np.array(y_gr))
    # 2
    feat_selector_vo = BorutaPy(rf, n_estimators='auto', verbose=2, random_state=1)
    Xy_train_vo = Xy_train_vo[Xy_train_vo.astype(bool)].dropna()
    X_vo = Xy_train_vo.drop(columns=['thickness','participant','h_structure', 'structure'])
    y_vo = Xy_train_vo.thickness
    feat_selector_vo.fit(np.array(X_vo), np.array(y_vo))
    # check selected features 
    boruta_df = pd.concat([pd.Series(X_gr.columns), 
                           pd.Series(feat_selector_gr.support_), 
                           pd.Series(feat_selector_gr.ranking_),
                           pd.Series(X_vo.columns), 
                           pd.Series(feat_selector_vo.support_), 
                           pd.Series(feat_selector_vo.ranking_)], axis=1)
    boruta_df.sort_values(by=2)
    # save
    boruta_df.to_csv(path)