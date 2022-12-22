import numpy as np
import pandas as pd
import shap
from matplotlib import pyplot as plt


def _shap_info(X_train, lgbm, df_eval_1, features_sets, features_set=2):
    explicables_index = df_eval_1[df_eval_1.r2_complete>0].index
    i = explicables_index[0]
    X_train_ = pd.DataFrame(X_train[features_set,i])
    X_train_.columns = features_sets[features_set]
    explainer = shap.Explainer(lgbm[features_set,i])
    shap_complete = explainer(X_train_)
    for i in explicables_index[1:]:
        X_train_ = pd.DataFrame(X_train[features_set,i])
        X_train_.columns = features_sets[features_set]
        explainer = shap.Explainer(lgbm[features_set,i])
        shap_values = explainer(X_train_)
        shap_complete.values = np.append(shap_complete.values, shap_values.values,axis=0)
        shap_complete.base_values = np.append(shap_complete.base_values, shap_values.base_values,axis=0)
        shap_complete.data = np.append(shap_complete.data, shap_values.data,axis=0)
    return shap_complete


def explicability_shap(X_train, lgbm, df_eval_1, features_sets, features_set=2):
    shap_complete = _shap_info(X_train, lgbm, df_eval_1, features_sets, features_set=features_set)
    # main plot     
    shap.summary_plot(shap_complete)
    shap.summary_plot(shap_complete, plot_type='bar',color='purple')
    # main interactions
    for i in range(12):
        shap.plots.scatter(shap_complete[:, i], color=shap_complete[:,"Age"], dot_size=5, cmap=plt.cm.magma, alpha =0.8) #show=False
        shap.plots.scatter(shap_complete[:, i], color=shap_complete[:,"Lobe"], dot_size=5, cmap=plt.cm.viridis, alpha =0.8)
        shap.plots.scatter(shap_complete[:, i], color=shap_complete[:,"Layer I thickness"], dot_size=5, cmap=plt.cm.plasma, alpha =0.8)
        shap.plots.scatter(shap_complete[:, i], color=shap_complete[:,"Layer IV thickness"], dot_size=5, cmap=plt.cm.plasma, alpha =0.8)
        