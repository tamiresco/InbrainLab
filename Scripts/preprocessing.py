import numpy as np
import pandas as pd
import openpyxl
import random
from sklearn.preprocessing import OrdinalEncoder

def read_parquet(mri_subs_path,
                 features_int = ['atlasEcono','atlasDF'],
                 features_objects = ['participant','structure','sex', 'handedness', 'hemisphere']
                ):
    mri_subs_all = pd.read_parquet(mri_subs_path)
    features_float = list(set(mri_subs_all.columns) - set(features_int + features_objects))
    mri_subs_all[features_int] = mri_subs_all[features_int].astype('int8')
    mri_subs_all[features_float] = mri_subs_all[features_float].astype('float32')
    return mri_subs_all


def find_bad_ones(mri_areas_path, threshold_std = 4, threshold_risks = 5):
    
    mri_areas = pd.read_csv(mri_areas_path)
    mri_areas = mri_areas.rename(columns={'Unnamed: 0':'participant'})
    mri_areas.participant = [x[:-2] for x in mri_areas.participant]

    mri_areas_std = mri_areas.copy()
    for col in mri_areas.columns[2:]:
        mean = np.mean(mri_areas[col])
        std = np.std(mri_areas[col])
        lower = mean - threshold_std*std
        upper = mean + threshold_std*std
        mri_areas_std[col] = [1 if x < lower or x > upper else 0 for x in mri_areas[col]]

    mri_areas_std['sum_risks'] = mri_areas_std.sum(axis=1)
    mri_areas_std = mri_areas_std[['sum_risks'] + list(mri_areas_std.columns[:-1])]
    mri_areas_std[mri_areas_std.sum_risks>0].sort_values(by=['sum_risks'],ascending=False)
    
    bad_participants = mri_areas_std.participant[mri_areas_std.sum_risks>threshold_risks].unique()
    return bad_participants


def eliminate_bad_ones(bad_participant, mri_subs):
    mri_subs = mri_subs[~mri_subs.participant.isin(bad_participant)]
    return mri_subs


def cat2int(mri_subs, cat_features):
    '''
    encode categoricals features
    '''
    enc = OrdinalEncoder()
    mri_subs[cat_features] = enc.fit_transform(mri_subs[cat_features])
    mri_subs[cat_features] = mri_subs[cat_features].astype('int8')
    return mri_subs


def ids_features(ids_path, mri_subs, cat_features = ['sex', 'handedness', 'hemisphere']):
    nkienhanced_infos = pd.read_csv(ids_path, sep='\t', header=0)
    nkienhanced_infos = nkienhanced_infos.rename(columns={'participant_id': "participant"})
    nkienhanced_infos.set_index('participant',inplace=True) 
    mri_subs = mri_subs.merge(nkienhanced_infos, left_on='participant', right_on='participant')
    mri_subs = cat2int(mri_subs, cat_features)
    mri_subs['age'] = mri_subs['age'].astype('int8')
    return mri_subs


def bb_normalizing(bb_path):
    
    bb = pd.read_excel(bb_path,engine='openpyxl')
    bb = bb.rename(columns={'Unnamed: 0': 'atlasEcono', 'area_name':'structure'})
    
    bb["bb_sum"] =bb[["bigbrain_layer_1","bigbrain_layer_2","bigbrain_layer_3","bigbrain_layer_4","bigbrain_layer_5","bigbrain_layer_6"]].agg(['sum'], axis =1)
    bb["ve_sum"] =bb[["ve_1","ve_2","ve_3","ve_4","ve_5","ve_6"]].agg(['sum'], axis =1)

    bb['ve_1'] = bb.apply(lambda x: x.ve_1/x.ve_sum, axis=1)
    bb['ve_2'] = bb.apply(lambda x: x.ve_2/x.ve_sum, axis=1)
    bb['ve_3'] = bb.apply(lambda x: x.ve_3/x.ve_sum, axis=1)
    bb['ve_4'] = bb.apply(lambda x: x.ve_4/x.ve_sum, axis=1)
    bb['ve_5'] = bb.apply(lambda x: x.ve_5/x.ve_sum, axis=1)
    bb['ve_6'] = bb.apply(lambda x: x.ve_6/x.ve_sum, axis=1)

    bb['bigbrain_layer_1'] = bb.apply(lambda x: x.bigbrain_layer_1/x.bb_sum, axis=1)
    bb['bigbrain_layer_2'] = bb.apply(lambda x: x.bigbrain_layer_2/x.bb_sum, axis=1)
    bb['bigbrain_layer_3'] = bb.apply(lambda x: x.bigbrain_layer_3/x.bb_sum, axis=1)
    bb['bigbrain_layer_4'] = bb.apply(lambda x: x.bigbrain_layer_4/x.bb_sum, axis=1)
    bb['bigbrain_layer_5'] = bb.apply(lambda x: x.bigbrain_layer_5/x.bb_sum, axis=1)
    bb['bigbrain_layer_6'] = bb.apply(lambda x: x.bigbrain_layer_6/x.bb_sum, axis=1)

    bb.drop(columns = ['crown_min','bigbrain','ve_sum','bb_sum','area'], inplace=True)

    missing_data = pd.DataFrame([[1, 'corpuscallosum'],[14, 'FLMN'],[15, 'HA'],[16, 'HB'],[17, 'HC'],[26, 'LE']],
                                columns=['atlasEcono', 'structure'])
    bb = pd.concat([bb,missing_data])
    bb.sort_values(by=['atlasEcono'], inplace = True)
    bb.set_index('atlasEcono', inplace=True)
    bb = bb.dropna()
    bb[bb.select_dtypes(include ='float64').columns] = bb.select_dtypes(include ='float64').astype('float32')
    return bb
  
    
def bb_rounding(bb):
    bb_rounded = bb[["bigbrain_layer_1","bigbrain_layer_2","bigbrain_layer_3","bigbrain_layer_4","bigbrain_layer_5","bigbrain_layer_6"]]
    bb_rounded = bb_rounded.applymap(lambda x: np.round(x,2))
    bb_rounded.columns = ["bigbrain_layer_1_r","bigbrain_layer_2_r","bigbrain_layer_3_r","bigbrain_layer_4_r","bigbrain_layer_5_r","bigbrain_layer_6_r"]
    bb = pd.concat([bb,bb_rounded], axis=1)
    bb[bb.select_dtypes(include ='float64').columns] = bb.select_dtypes(include ='float64').astype('float32')
    return bb
  

def bb_multipling_age(dataframe_with_bb):
    try:
        layers_data = ['bigbrain_layer_1','bigbrain_layer_2','bigbrain_layer_3','bigbrain_layer_4','bigbrain_layer_5','bigbrain_layer_6']
        for i, ld in enumerate(layers_data):
            dataframe_with_bb["bblayer" + str(i+1) + "_age"] = dataframe_with_bb.age * dataframe_with_bb[ld]
        layers_data2 = ['ve_1', 've_2', 've_3', 've_4', 've_5', 've_6']
        for i, ld in enumerate(layers_data2):
            dataframe_with_bb["ve" + str(i+1) + "_age"] = dataframe_with_bb.age * dataframe_with_bb[ld]
        dataframe_with_bb[dataframe_with_bb.select_dtypes(include ='float64').columns] = dataframe_with_bb.select_dtypes(include ='float64').astype('float32')
        return dataframe_with_bb
    except:
        return print("error: Falta adicionar variavel idade na base.")
    
    
def bb_features(bb_path, mri_subs):
    bb = bb_normalizing(bb_path)
    bb = bb_rounding(bb)
    mri_subs = mri_subs.join(bb, on="atlasEcono")
    mri_subs = bb_multipling_age(mri_subs)
    return mri_subs


def clean_sample(mri_subs_all, sample_size):
    '''Criando sub amostra com N participantes and drop zeros thickness
    '''
    participants_list = mri_subs_all.participant.unique()
    participants_sample = random.sample(list(participants_list), sample_size)
    mri_subs = mri_subs_all[mri_subs_all.participant.isin(participants_sample)]
    mri_subs = mri_subs[mri_subs['thickness'].astype(bool)]
    return mri_subs

def clean(mri_subs_all):
    '''drop zeros thickness
    '''
    mri_subs = mri_subs_all[mri_subs_all['thickness'].astype(bool)]
    return mri_subs

