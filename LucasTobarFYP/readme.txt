This is the readme for the Final Year Project: 
'Modelling the Brain’s Oscillatory Response to Stimulation in the Visual Cortex'
Lucas Tobar, 27860221, Department of Electrical and Computer Systems Engineering
Please refer to the Final Report for more detail.


CavallariEtAl2014__7_2015:
- Cloned from a model developed by Cavallari et al. [27] which was accessed via the following ModelDB sharing repository: https://senselab.med.yale.edu/ModelDB/ShowModel?model=152539#tabs-1. 
- Contains two folders within it; the conductance-based model ‘LIF_COBN’, and the current-based model ‘LIF_CUBN’. 
- Figures 5.1 and 5.2 can be replicated by running the script ‘LIF_COBN/RestingStateDynamics.m’. 
- Figure 5.3 can be replicated by running the script ‘LIF_CUBN/InputCurrentTest.m’. 

FinalModel:
- This model was adpated from Mejias et al. 2016 (Science Advances).
- To obtain figures 5.7 and 5.8C, run the script 'interlaminarModel.m' without making any changes to the inputs.
- To obtain figure 5.8B set the variable J_25_EE to zero.
- To obtain figure 5.8A set both J_25_EE and tau_c to zero. 

Mejias2016:
- The model described by Mejias et al. was first implemented by following the mathematical descriptions outlined in the supplementary material.
- From the description given in the supplementary materials, multiple figures presented in the paper were able to be replicated.
- Figures 5.4 and 5.5 can be obtained by running the scripts ‘intralaminarModel.m’, and ‘interlaminarModel.m’ respectively. 

RodentDataAnalysis:
- I have made use of past rodent experiments conducted in the lab as a basis for my comparisons to the model. 
- The experiments were conducted on Sprague-Dawley rats, which were anaesthetized and implanted with a thirty-two channel NeuroNexus laminar array in the visual cortex. 
- The visual cortex was electrically stimulated at random times, and the responses from the neurons were recorded and analysed.
- Figure 5.6 can be obtained by running the script ‘AnalysisTest.m’. For further details on the setup of the experiments, refer to appendix A of the final report.
