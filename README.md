## InBrain Lab

# Cortical thinning encodes link between pruning and normal neurodegeneration

Cortical thinning is associated with pruning, neuroplasticity, and normal neurodegeneration. However, it is not well known how thinning is connected to cortex architecture and cognitive aspects at a multi-scale level in a way that comprehends the decrease in neuroplasticity in development and the normal neurodegeneration in aging. Our goal was to predict thinning based on temporal and spatial variables and identify their role: age, cortical type, lobes, structures, curvature and cytoarchitectonic estimation. Cytoarchitecture profiles were estimated based on the BigBrain database. We used Magnetic Resonance Imaging (MRI) of 871 participants without a history of neurological diseases to estimate cortical thinning variation throughout the lifespan and cortical regions. We next predict cortical thinning in each cortical structure and life stage with an ensemble regressor model. For explainability, we calculated the Shapley additive explanations, a technique that utilizes game theory to determine the contribution of each variable to individual model output. We demonstrate that multi-level spatial variables have different roles in development and healthy aging. Regions that have the greater thinning in pruning are the regions that thin lesser in normal neurodegeneration. Layer I thickness is the spatial feature that most contributes to thinning, and the impact on thinning has an opposite behavior in development and in aging. We propose that pruning occurs more in regions with more corticocortical connections and subcortical projections, while in normal neurodegeneration, these are the regions that remain more preserved and thin less. 

The data used for this project is on Data folder, the methods built is on Scripts folder and the analyses can be found on Notebooks folder. Spotted a mistake or have a questions? Please message me, create an issue or email me on tamires dot 2505 at gmail dot com.



## Notebooks
### 1) Thinning Processing 
  
### 2) Thinning Modelling 

Multi Modelling:
• How a model predicting cortical thinnning performs when we use temporal and spatial variables?
• Which cortical structure thinning is better explained by which model?
• Database that summarizes the cortical structure information acquired in the models

Variable roles in cortical thinning (ShapValues):
• Which features are more important and how they contribute to the model in summary?
• Does the variables interact with each other on the model?
• How each variable contribute to the model?
     
### 3) Cortex Visualization 

Plots:
• How much is thinning in the cortex?
• How does our model perform in the cortex?
• How thick is Layer I in the cortex?
• How thick is Layer IV in the cortex?
• Which cortical structure thins the most in life?
• How is an Atlas segmented?

### 4) Feature Analyses

Basic analysis of the variables relation to the annual thining rate:
• What are the features correlation to each other?  
• All the features are important to predict annual thining rate? (Boruta) 

Thinning segmented by Life Stages:
• Is thinning different in Development, Mid Life and Aging?
• Does features correlation to thinning vary depending on life stage?
• How is thinning in development correlated to thinning in aging?

