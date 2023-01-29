import os
import shutil
import numpy as np
import pandas as pd
from nilearn import surface
    
def strutures_to_df(path):
    #acessando o dicionario de estruturas e seus codigos
    b = "label/aparc.annot.DKTatlas.ctab"
    x = pd.read_csv(path+b , header=None, delimiter=r"\s+")
    x = x[[0,1]]
    x = x.set_index([1])
    #acessando os dados de estatistica de cada estrutura de um sujeito
    a = path + "stats/rh.aparc.DKTatlas.stats"
    columns = ['StructName', 'NumVert', 'SurfArea', 'GrayVol', 'ThickAvg', 'ThickStd', 'MeanCurv', 'GausCurv', 'FoldInd', 'CurvInd']
    y = pd.read_csv(a , delimiter=r"\s+", skiprows=59, header=0, names=columns, index_col=False)
    y = y.set_index(['StructName'])
    #adicionando o codigo das estruturas
    z = pd.concat([x,y],join="inner",axis=1).reset_index()
    z = z.rename(columns = {'index':'StructName',0:'StructCode'})
    z2 = z.drop(columns=['StructName','StructCode'])
    #criando nome das colunas do dataframe final : hemisferio x columns x StructCode
    feature_stats = []
    for j in z.StructCode:
        for i in list(z2.columns):
            feature_stats.append(str(j)+'_'+i)
    feature_stats = ['hemisphere']+feature_stats
    #criando df final
    Data_Strutures = pd.DataFrame(columns=feature_stats)
        
def struct_stats(participant, hemisphere):
    #acessando os dados de estatistica de cada estrutura de um sujeito
    a = freesurfer_data_folder+participant+"/stats/"+str(hemisphere)+".aparc.DKTatlas.stats"
    columns = ['StructName', 'NumVert', 'SurfArea', 'GrayVol', 'ThickAvg', 'ThickStd', 'MeanCurv', 'GausCurv', 'FoldInd', 'CurvInd']
    y = pd.read_csv(a , delimiter=r"\s+", skiprows=59, header=0, names=columns, index_col=False)
    y = y.set_index(['StructName'])
    #adicionando o codigo das estruturas
    z = pd.concat([x,y],join="inner",axis=1).reset_index()
    z = z.rename(columns = {'index':'StructName',0:'StructCode'})
    z2 = z.drop(columns=['StructName','StructCode'])
    #transformando em um vetor o dataframe stats
    part_stats = z2.to_numpy().flatten()
    #add dataframe final
    Data_Strutures.loc[participant+hemisphere] = [hemisphere]+list(part_stats)


def collector(participants_list, path_example):
    
    Data_Strutures = strutures_to_df(path_example)
    
    data = []
    participants_list_completed = []
    participants_list_incompleted = []
    t=0
    for participant in participants_list:
        feature_processed = []
        for hemisphere in ['lh', 'rh']:
            atlasEcono = "/label/"+str(hemisphere)+".Eco.annot" 
            atlasDF = "/label/"+str(hemisphere)+".aparc.DKTatlas.annot" # o atlas padrao do fastsurfer é lh.aparc.mapped.annot 
            area = "/surf/"+str(hemisphere)+".area"
            curv = "/surf/"+str(hemisphere)+".curv"
            sulc = "/surf/"+str(hemisphere)+".sulc"
            thickness = "/surf/"+str(hemisphere)+".thickness"
            features = [atlasEcono, atlasDF, area, curv, sulc, thickness]
            for feature in features:
                try:
                    feature_processed.append(surface.load_surf_data(freesurfer_data_folder + participant + feature))
                except:
                    #print('Error: '+str(participant)+' has no '+feature)
                    participants_list_incompleted.append(participant)
                    pass
            try:
                struct_stats(participant, hemisphere)
            except:
                #participants_list_incompleted.append(participant)
                pass       
        data.append([participant, feature_processed])

    participants_list_incompleted = np.unique(participants_list_incompleted)
    participants_list_comp = [[i, sub] for i, sub in enumerate(participants_list) if sub not in participants_list_incompleted]
    participants_list_completed_index = pd.DataFrame(participants_list_comp)[0]
    participants_list_completed = pd.DataFrame(participants_list_comp)[1]

    return Data_Strutures, data, participants_list_completed_index, participants_list_completed, participants_list_incompleted 


def vertices_to_df(data, participants_list_completed_index):    
    df_dict = {"participant":[],"hemisphere":[],"atlasEcono":[],"atlasDF":[], "area":[],"curv":[],"sulc":[],"thickness":[]}
    participants_list_completed_index = list(participants_list_completed_index)
    for i,part in enumerate(data):
        if i in participants_list_completed_index:
            frame_lh = np.array(part[1][0:6])
            df_dict['atlasEcono'].extend(frame_lh[0])  
            df_dict['atlasDF'].extend(frame_lh[1])
            df_dict['area'].extend(frame_lh[2])
            df_dict['curv'].extend(frame_lh[3])
            df_dict['sulc'].extend(frame_lh[4])
            df_dict['thickness'].extend(frame_lh[5])
            df_dict['participant'].extend([part[0]] * len(frame_lh[0]))
            df_dict['hemisphere'].extend(['left'] * len(frame_lh[0]))
            frame_rh = np.array(part[1][6:12])
            df_dict['atlasEcono'].extend(frame_rh[0])
            df_dict['atlasDF'].extend(frame_rh[1])
            df_dict['area'].extend(frame_rh[2])
            df_dict['curv'].extend(frame_rh[3])
            df_dict['sulc'].extend(frame_rh[4])
            df_dict['thickness'].extend(frame_rh[5])
            df_dict['participant'].extend([part[0]] * len(frame_rh[0]))
            df_dict['hemisphere'].extend(['right'] * len(frame_rh[0]))
    Data_Vertices = pd.DataFrame(df_dict) 
    return Data_Vertices


class Sufer_Data:
    
    def __init__(   self,
                    freesurfer_data_folder = "/home/brunovieira/Tamires_Experiments/Bases_de_Dados/nki_data/",
                    path_base_mri = "/home/brunovieira/Tamires_Experiments/Bases_de_Dados/",
                    path_example = "/home/brunovieira/Tamires_Experiments/Bases_de_Dados/nki_data/A00008326/"
                    ):
    
        participants_list = os.listdir(freesurfer_data_folder)
        participants_list = np.setdiff1d(participants_list, ['fsaverage'])

        Data_Strutures, data, participants_list_completed_index, participants_list_completed, participants_list_incompleted = collector(participants_list, path_example)

        self.Data_Strutures = Data_Strutures
        self.data = data
        self.participants_list_completed_index = participants_list_completed_index
        self.participants_list_completed = participants_list_completed
        self.participants_list_incompleted = participants_list_incompleted

    def save_files(self):
        self.Data_Strutures.to_parquet(self.path_base_mri + "MRI_Data_Strutures_" + str(round(len(self.Data_Strutures)/2)) + ".parquet")  
        self.Data_Vertices = vertices_to_df(self.data, self.participants_list_completed_index)
        self.Data_Vertices.to_parquet(self.path_base_mri + "MRI_Data_Vertices_" + str(len(self.Data_Vertices.participant.unique())) + ".parquet")

    def monitor(self):
        print('Completed: '+str(len(self.participants_list_completed)))
        print('Incompleted: '+str(len(self.participants_list_incompleted)))
