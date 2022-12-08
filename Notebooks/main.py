import pandas as pd
import preprocessing as pp
import train_test_sets
import modelling

mri_subs_path = "/home/brunovieira/Tamires_Experiments/Bases_de_Dados/MRI_Data_Voxels_894.parquet" 
mri_areas_path = "/home/brunovieira/Tamires_Experiments/Bases_de_Dados/MRI_Data_Areas_890.csv" 
bb_path = "/home/brunovieira/Tamires_Experiments/Bases_de_Dados/BigBrain.xlsx"
ids_path = "/home/brunovieira/Tamires_Experiments/Bases_de_Dados/participants_nkienhanced.tsv"

# freesufer data
print('iniciando leitura de dados')
mri_subs_all = pp.read_parquet(mri_subs_path)
print('acabou leitura de dados - iniciando preparacao da base')

# drop zeros
mri_subs = pp.clean(mri_subs_all)

# quality assessment
bad_participants = pp.find_bad_ones(mri_areas_path)
mri_subs = pp.eliminate_bad_ones(bad_participants, mri_subs)

# add identification features and encode cats
#mri_subs = pp.ids_features(ids_path, mri_subs)
mri_subs = pp.cat2int(mri_subs, cat_features=['sex', 'handedness', 'hemisphere'])

# add bigbrain features
mri_subs = pp.bb_features(bb_path, mri_subs)
print('acabou de preparar a base - inciando separar terino e teste')

# prepare sets to models train and test
Xy_sets = train_test_sets.separate(mri_subs)
print('acabou de separar terino e teste - inciando treino')

# experiment 
m = modelling.Model(Xy_sets,
                    path_images_outputs = '/home/brunovieira/Tamires_Experiments/Outputs/exp6/',
                    features = ['sex', 'handedness', 'hemisphere',
                                'age','area', 'curv', 'sulc', 
                                'bigbrain_layer_1', 'bigbrain_layer_2','bigbrain_layer_3', 
                                'bigbrain_layer_4', 'bigbrain_layer_5','bigbrain_layer_6'], 
                    hyperparameter_search_size = 10,
                    voxel = False,
                    structure_modeling = False
                    )
print('acabou terino - inciando teste')

m.test('vizualization')
print('acabou teste - inciando explicabilidade')

m.explicability()
print('acabou explicabilidade - inciando curva de aprendizado')

m.learning_curv()
