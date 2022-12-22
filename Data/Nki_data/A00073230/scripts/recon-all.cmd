

#---------------------------------
# New invocation of recon-all Sat Feb 19 18:37:35 -03 2022 
#--------------------------------------------
#@# MotionCor Sat Feb 19 18:37:37 -03 2022

 cp /home/brunovieira/Tamires_Experiments/Bases_de_Dados/nki_data/A00073230/mri/orig/001.mgz /home/brunovieira/Tamires_Experiments/Bases_de_Dados/nki_data/A00073230/mri/rawavg.mgz 


 mri_convert /home/brunovieira/Tamires_Experiments/Bases_de_Dados/nki_data/A00073230/mri/rawavg.mgz /home/brunovieira/Tamires_Experiments/Bases_de_Dados/nki_data/A00073230/mri/orig.mgz --conform 


 mri_add_xform_to_header -c /home/brunovieira/Tamires_Experiments/Bases_de_Dados/nki_data/A00073230/mri/transforms/talairach.xfm /home/brunovieira/Tamires_Experiments/Bases_de_Dados/nki_data/A00073230/mri/orig.mgz /home/brunovieira/Tamires_Experiments/Bases_de_Dados/nki_data/A00073230/mri/orig.mgz 

#--------------------------------------------
#@# Talairach Sat Feb 19 18:37:52 -03 2022

 mri_nu_correct.mni --no-rescale --i orig.mgz --o orig_nu.mgz --n 1 --proto-iters 1000 --distance 50 


 talairach_avi --i orig_nu.mgz --xfm transforms/talairach.auto.xfm 

talairach_avi log file is transforms/talairach_avi.log...

 cp transforms/talairach.auto.xfm transforms/talairach.xfm 

#--------------------------------------------
#@# Talairach Failure Detection Sat Feb 19 18:41:23 -03 2022

 talairach_afd -T 0.005 -xfm transforms/talairach.xfm 


 awk -f /home/brunovieira/freesurfer/bin/extract_talairach_avi_QA.awk /home/brunovieira/Tamires_Experiments/Bases_de_Dados/nki_data/A00073230/mri/transforms/talairach_avi.log 


 tal_QC_AZS /home/brunovieira/Tamires_Experiments/Bases_de_Dados/nki_data/A00073230/mri/transforms/talairach_avi.log 

#--------------------------------------------
#@# Nu Intensity Correction Sat Feb 19 18:41:23 -03 2022

 mri_nu_correct.mni --i orig.mgz --o nu.mgz --uchar transforms/talairach.xfm --n 2 


 mri_add_xform_to_header -c /home/brunovieira/Tamires_Experiments/Bases_de_Dados/nki_data/A00073230/mri/transforms/talairach.xfm nu.mgz nu.mgz 

#--------------------------------------------
#@# Intensity Normalization Sat Feb 19 18:45:05 -03 2022

 mri_normalize -g 1 -mprage nu.mgz T1.mgz 

#--------------------------------------------
#@# Skull Stripping Sat Feb 19 18:47:39 -03 2022

 mri_em_register -rusage /home/brunovieira/Tamires_Experiments/Bases_de_Dados/nki_data/A00073230/touch/rusage.mri_em_register.skull.dat -skull nu.mgz /home/brunovieira/freesurfer/average/RB_all_withskull_2016-05-10.vc700.gca transforms/talairach_with_skull.lta 


 mri_watershed -rusage /home/brunovieira/Tamires_Experiments/Bases_de_Dados/nki_data/A00073230/touch/rusage.mri_watershed.dat -T1 -brain_atlas /home/brunovieira/freesurfer/average/RB_all_withskull_2016-05-10.vc700.gca transforms/talairach_with_skull.lta T1.mgz brainmask.auto.mgz 


 cp brainmask.auto.mgz brainmask.mgz 

#-------------------------------------
#@# EM Registration Sat Feb 19 19:08:57 -03 2022

 mri_em_register -rusage /home/brunovieira/Tamires_Experiments/Bases_de_Dados/nki_data/A00073230/touch/rusage.mri_em_register.dat -uns 3 -mask brainmask.mgz nu.mgz /home/brunovieira/freesurfer/average/RB_all_2016-05-10.vc700.gca transforms/talairach.lta 

#--------------------------------------
#@# CA Normalize Sat Feb 19 19:26:57 -03 2022

 mri_ca_normalize -c ctrl_pts.mgz -mask brainmask.mgz nu.mgz /home/brunovieira/freesurfer/average/RB_all_2016-05-10.vc700.gca transforms/talairach.lta norm.mgz 

#--------------------------------------
#@# CA Reg Sat Feb 19 19:28:35 -03 2022

 mri_ca_register -rusage /home/brunovieira/Tamires_Experiments/Bases_de_Dados/nki_data/A00073230/touch/rusage.mri_ca_register.dat -nobigventricles -T transforms/talairach.lta -align-after -mask brainmask.mgz norm.mgz /home/brunovieira/freesurfer/average/RB_all_2016-05-10.vc700.gca transforms/talairach.m3z 

#--------------------------------------
#@# SubCort Seg Sat Feb 19 21:58:23 -03 2022

 mri_ca_label -relabel_unlikely 9 .3 -prior 0.5 -align norm.mgz transforms/talairach.m3z /home/brunovieira/freesurfer/average/RB_all_2016-05-10.vc700.gca aseg.auto_noCCseg.mgz 


 mri_cc -aseg aseg.auto_noCCseg.mgz -o aseg.auto.mgz -lta /home/brunovieira/Tamires_Experiments/Bases_de_Dados/nki_data/A00073230/mri/transforms/cc_up.lta A00073230 

#--------------------------------------
#@# Merge ASeg Sat Feb 19 23:00:33 -03 2022

 cp aseg.auto.mgz aseg.presurf.mgz 

#--------------------------------------------
#@# Intensity Normalization2 Sat Feb 19 23:00:33 -03 2022

 mri_normalize -mprage -aseg aseg.presurf.mgz -mask brainmask.mgz norm.mgz brain.mgz 

#--------------------------------------------
#@# Mask BFS Sat Feb 19 23:04:11 -03 2022

 mri_mask -T 5 brain.mgz brainmask.mgz brain.finalsurfs.mgz 

#--------------------------------------------
#@# WM Segmentation Sat Feb 19 23:04:13 -03 2022

 mri_segment -mprage brain.mgz wm.seg.mgz 


 mri_edit_wm_with_aseg -keep-in wm.seg.mgz brain.mgz aseg.presurf.mgz wm.asegedit.mgz 


 mri_pretess wm.asegedit.mgz wm norm.mgz wm.mgz 

#--------------------------------------------
#@# Fill Sat Feb 19 23:06:37 -03 2022

 mri_fill -a ../scripts/ponscc.cut.log -xform transforms/talairach.lta -segmentation aseg.auto_noCCseg.mgz wm.mgz filled.mgz 

#--------------------------------------------
#@# Tessellate lh Sat Feb 19 23:07:22 -03 2022

 mri_pretess ../mri/filled.mgz 255 ../mri/norm.mgz ../mri/filled-pretess255.mgz 


 mri_tessellate ../mri/filled-pretess255.mgz 255 ../surf/lh.orig.nofix 


 rm -f ../mri/filled-pretess255.mgz 


 mris_extract_main_component ../surf/lh.orig.nofix ../surf/lh.orig.nofix 

#--------------------------------------------
#@# Tessellate rh Sat Feb 19 23:07:28 -03 2022

 mri_pretess ../mri/filled.mgz 127 ../mri/norm.mgz ../mri/filled-pretess127.mgz 


 mri_tessellate ../mri/filled-pretess127.mgz 127 ../surf/rh.orig.nofix 


 rm -f ../mri/filled-pretess127.mgz 


 mris_extract_main_component ../surf/rh.orig.nofix ../surf/rh.orig.nofix 

#--------------------------------------------
#@# Smooth1 lh Sat Feb 19 23:07:34 -03 2022

 mris_smooth -nw -seed 1234 ../surf/lh.orig.nofix ../surf/lh.smoothwm.nofix 

#--------------------------------------------
#@# Smooth1 rh Sat Feb 19 23:07:40 -03 2022

 mris_smooth -nw -seed 1234 ../surf/rh.orig.nofix ../surf/rh.smoothwm.nofix 

#--------------------------------------------
#@# Inflation1 lh Sat Feb 19 23:07:45 -03 2022

 mris_inflate -no-save-sulc ../surf/lh.smoothwm.nofix ../surf/lh.inflated.nofix 

#--------------------------------------------
#@# Inflation1 rh Sat Feb 19 23:08:16 -03 2022

 mris_inflate -no-save-sulc ../surf/rh.smoothwm.nofix ../surf/rh.inflated.nofix 

#--------------------------------------------
#@# QSphere lh Sat Feb 19 23:08:50 -03 2022

 mris_sphere -q -seed 1234 ../surf/lh.inflated.nofix ../surf/lh.qsphere.nofix 

#--------------------------------------------
#@# QSphere rh Sat Feb 19 23:12:08 -03 2022

 mris_sphere -q -seed 1234 ../surf/rh.inflated.nofix ../surf/rh.qsphere.nofix 

#--------------------------------------------
#@# Fix Topology Copy lh Sat Feb 19 23:15:33 -03 2022

 cp ../surf/lh.orig.nofix ../surf/lh.orig 


 cp ../surf/lh.inflated.nofix ../surf/lh.inflated 

#--------------------------------------------
#@# Fix Topology Copy rh Sat Feb 19 23:15:34 -03 2022

 cp ../surf/rh.orig.nofix ../surf/rh.orig 


 cp ../surf/rh.inflated.nofix ../surf/rh.inflated 

#@# Fix Topology lh Sat Feb 19 23:15:34 -03 2022

 mris_fix_topology -rusage /home/brunovieira/Tamires_Experiments/Bases_de_Dados/nki_data/A00073230/touch/rusage.mris_fix_topology.lh.dat -mgz -sphere qsphere.nofix -ga -seed 1234 A00073230 lh 

#@# Fix Topology rh Sat Feb 19 23:28:41 -03 2022

 mris_fix_topology -rusage /home/brunovieira/Tamires_Experiments/Bases_de_Dados/nki_data/A00073230/touch/rusage.mris_fix_topology.rh.dat -mgz -sphere qsphere.nofix -ga -seed 1234 A00073230 rh 


 mris_euler_number ../surf/lh.orig 


 mris_euler_number ../surf/rh.orig 


 mris_remove_intersection ../surf/lh.orig ../surf/lh.orig 


 rm ../surf/lh.inflated 


 mris_remove_intersection ../surf/rh.orig ../surf/rh.orig 


 rm ../surf/rh.inflated 

#--------------------------------------------
#@# Make White Surf lh Sat Feb 19 23:39:37 -03 2022

 mris_make_surfaces -aseg ../mri/aseg.presurf -white white.preaparc -noaparc -whiteonly -mgz -T1 brain.finalsurfs A00073230 lh 

#--------------------------------------------
#@# Make White Surf rh Sat Feb 19 23:43:42 -03 2022

 mris_make_surfaces -aseg ../mri/aseg.presurf -white white.preaparc -noaparc -whiteonly -mgz -T1 brain.finalsurfs A00073230 rh 

#--------------------------------------------
#@# Smooth2 lh Sat Feb 19 23:47:51 -03 2022

 mris_smooth -n 3 -nw -seed 1234 ../surf/lh.white.preaparc ../surf/lh.smoothwm 

#--------------------------------------------
#@# Smooth2 rh Sat Feb 19 23:47:55 -03 2022

 mris_smooth -n 3 -nw -seed 1234 ../surf/rh.white.preaparc ../surf/rh.smoothwm 

#--------------------------------------------
#@# Inflation2 lh Sat Feb 19 23:48:00 -03 2022

 mris_inflate -rusage /home/brunovieira/Tamires_Experiments/Bases_de_Dados/nki_data/A00073230/touch/rusage.mris_inflate.lh.dat ../surf/lh.smoothwm ../surf/lh.inflated 

#--------------------------------------------
#@# Inflation2 rh Sat Feb 19 23:48:30 -03 2022

 mris_inflate -rusage /home/brunovieira/Tamires_Experiments/Bases_de_Dados/nki_data/A00073230/touch/rusage.mris_inflate.rh.dat ../surf/rh.smoothwm ../surf/rh.inflated 

#--------------------------------------------
#@# Curv .H and .K lh Sat Feb 19 23:49:02 -03 2022

 mris_curvature -w lh.white.preaparc 


 mris_curvature -thresh .999 -n -a 5 -w -distances 10 10 lh.inflated 

#--------------------------------------------
#@# Curv .H and .K rh Sat Feb 19 23:50:11 -03 2022

 mris_curvature -w rh.white.preaparc 


 mris_curvature -thresh .999 -n -a 5 -w -distances 10 10 rh.inflated 


#-----------------------------------------
#@# Curvature Stats lh Sat Feb 19 23:51:24 -03 2022

 mris_curvature_stats -m --writeCurvatureFiles -G -o ../stats/lh.curv.stats -F smoothwm A00073230 lh curv sulc 


#-----------------------------------------
#@# Curvature Stats rh Sat Feb 19 23:51:28 -03 2022

 mris_curvature_stats -m --writeCurvatureFiles -G -o ../stats/rh.curv.stats -F smoothwm A00073230 rh curv sulc 

#--------------------------------------------
#@# Sphere lh Sat Feb 19 23:51:32 -03 2022

 mris_sphere -rusage /home/brunovieira/Tamires_Experiments/Bases_de_Dados/nki_data/A00073230/touch/rusage.mris_sphere.lh.dat -seed 1234 ../surf/lh.inflated ../surf/lh.sphere 

#--------------------------------------------
#@# Sphere rh Sun Feb 20 00:29:29 -03 2022

 mris_sphere -rusage /home/brunovieira/Tamires_Experiments/Bases_de_Dados/nki_data/A00073230/touch/rusage.mris_sphere.rh.dat -seed 1234 ../surf/rh.inflated ../surf/rh.sphere 

#--------------------------------------------
#@# Surf Reg lh Sun Feb 20 01:11:25 -03 2022

 mris_register -curv -rusage /home/brunovieira/Tamires_Experiments/Bases_de_Dados/nki_data/A00073230/touch/rusage.mris_register.lh.dat ../surf/lh.sphere /home/brunovieira/freesurfer/average/lh.folding.atlas.acfb40.noaparc.i12.2016-08-02.tif ../surf/lh.sphere.reg 

#--------------------------------------------
#@# Surf Reg rh Sun Feb 20 01:49:14 -03 2022

 mris_register -curv -rusage /home/brunovieira/Tamires_Experiments/Bases_de_Dados/nki_data/A00073230/touch/rusage.mris_register.rh.dat ../surf/rh.sphere /home/brunovieira/freesurfer/average/rh.folding.atlas.acfb40.noaparc.i12.2016-08-02.tif ../surf/rh.sphere.reg 

#--------------------------------------------
#@# Jacobian white lh Sun Feb 20 02:32:34 -03 2022

 mris_jacobian ../surf/lh.white.preaparc ../surf/lh.sphere.reg ../surf/lh.jacobian_white 

#--------------------------------------------
#@# Jacobian white rh Sun Feb 20 02:32:36 -03 2022

 mris_jacobian ../surf/rh.white.preaparc ../surf/rh.sphere.reg ../surf/rh.jacobian_white 

#--------------------------------------------
#@# AvgCurv lh Sun Feb 20 02:32:38 -03 2022

 mrisp_paint -a 5 /home/brunovieira/freesurfer/average/lh.folding.atlas.acfb40.noaparc.i12.2016-08-02.tif#6 ../surf/lh.sphere.reg ../surf/lh.avg_curv 

#--------------------------------------------
#@# AvgCurv rh Sun Feb 20 02:32:39 -03 2022

 mrisp_paint -a 5 /home/brunovieira/freesurfer/average/rh.folding.atlas.acfb40.noaparc.i12.2016-08-02.tif#6 ../surf/rh.sphere.reg ../surf/rh.avg_curv 

#-----------------------------------------
#@# Cortical Parc lh Sun Feb 20 02:32:41 -03 2022

 mris_ca_label -l ../label/lh.cortex.label -aseg ../mri/aseg.presurf.mgz -seed 1234 A00073230 lh ../surf/lh.sphere.reg /home/brunovieira/freesurfer/average/lh.DKaparc.atlas.acfb40.noaparc.i12.2016-08-02.gcs ../label/lh.aparc.annot 

#-----------------------------------------
#@# Cortical Parc rh Sun Feb 20 02:32:52 -03 2022

 mris_ca_label -l ../label/rh.cortex.label -aseg ../mri/aseg.presurf.mgz -seed 1234 A00073230 rh ../surf/rh.sphere.reg /home/brunovieira/freesurfer/average/rh.DKaparc.atlas.acfb40.noaparc.i12.2016-08-02.gcs ../label/rh.aparc.annot 

#--------------------------------------------
#@# Make Pial Surf lh Sun Feb 20 02:33:03 -03 2022

 mris_make_surfaces -orig_white white.preaparc -orig_pial white.preaparc -aseg ../mri/aseg.presurf -mgz -T1 brain.finalsurfs A00073230 lh 

#--------------------------------------------
#@# Make Pial Surf rh Sun Feb 20 02:44:48 -03 2022

 mris_make_surfaces -orig_white white.preaparc -orig_pial white.preaparc -aseg ../mri/aseg.presurf -mgz -T1 brain.finalsurfs A00073230 rh 

#--------------------------------------------
#@# Surf Volume lh Sun Feb 20 02:56:50 -03 2022
#--------------------------------------------
#@# Surf Volume rh Sun Feb 20 02:56:53 -03 2022
#--------------------------------------------
#@# Cortical ribbon mask Sun Feb 20 02:56:56 -03 2022

 mris_volmask --aseg_name aseg.presurf --label_left_white 2 --label_left_ribbon 3 --label_right_white 41 --label_right_ribbon 42 --save_ribbon A00073230 

#-----------------------------------------
#@# Parcellation Stats lh Sun Feb 20 03:05:28 -03 2022

 mris_anatomical_stats -th3 -mgz -cortex ../label/lh.cortex.label -f ../stats/lh.aparc.stats -b -a ../label/lh.aparc.annot -c ../label/aparc.annot.ctab A00073230 lh white 


 mris_anatomical_stats -th3 -mgz -cortex ../label/lh.cortex.label -f ../stats/lh.aparc.pial.stats -b -a ../label/lh.aparc.annot -c ../label/aparc.annot.ctab A00073230 lh pial 

#-----------------------------------------
#@# Parcellation Stats rh Sun Feb 20 03:06:25 -03 2022

 mris_anatomical_stats -th3 -mgz -cortex ../label/rh.cortex.label -f ../stats/rh.aparc.stats -b -a ../label/rh.aparc.annot -c ../label/aparc.annot.ctab A00073230 rh white 


 mris_anatomical_stats -th3 -mgz -cortex ../label/rh.cortex.label -f ../stats/rh.aparc.pial.stats -b -a ../label/rh.aparc.annot -c ../label/aparc.annot.ctab A00073230 rh pial 

#-----------------------------------------
#@# Cortical Parc 2 lh Sun Feb 20 03:07:27 -03 2022

 mris_ca_label -l ../label/lh.cortex.label -aseg ../mri/aseg.presurf.mgz -seed 1234 A00073230 lh ../surf/lh.sphere.reg /home/brunovieira/freesurfer/average/lh.CDaparc.atlas.acfb40.noaparc.i12.2016-08-02.gcs ../label/lh.aparc.a2009s.annot 

#-----------------------------------------
#@# Cortical Parc 2 rh Sun Feb 20 03:07:42 -03 2022

 mris_ca_label -l ../label/rh.cortex.label -aseg ../mri/aseg.presurf.mgz -seed 1234 A00073230 rh ../surf/rh.sphere.reg /home/brunovieira/freesurfer/average/rh.CDaparc.atlas.acfb40.noaparc.i12.2016-08-02.gcs ../label/rh.aparc.a2009s.annot 

#-----------------------------------------
#@# Parcellation Stats 2 lh Sun Feb 20 03:07:55 -03 2022

 mris_anatomical_stats -th3 -mgz -cortex ../label/lh.cortex.label -f ../stats/lh.aparc.a2009s.stats -b -a ../label/lh.aparc.a2009s.annot -c ../label/aparc.annot.a2009s.ctab A00073230 lh white 

#-----------------------------------------
#@# Parcellation Stats 2 rh Sun Feb 20 03:08:29 -03 2022

 mris_anatomical_stats -th3 -mgz -cortex ../label/rh.cortex.label -f ../stats/rh.aparc.a2009s.stats -b -a ../label/rh.aparc.a2009s.annot -c ../label/aparc.annot.a2009s.ctab A00073230 rh white 

#-----------------------------------------
#@# Cortical Parc 3 lh Sun Feb 20 03:08:59 -03 2022

 mris_ca_label -l ../label/lh.cortex.label -aseg ../mri/aseg.presurf.mgz -seed 1234 A00073230 lh ../surf/lh.sphere.reg /home/brunovieira/freesurfer/average/lh.DKTaparc.atlas.acfb40.noaparc.i12.2016-08-02.gcs ../label/lh.aparc.DKTatlas.annot 

#-----------------------------------------
#@# Cortical Parc 3 rh Sun Feb 20 03:09:10 -03 2022

 mris_ca_label -l ../label/rh.cortex.label -aseg ../mri/aseg.presurf.mgz -seed 1234 A00073230 rh ../surf/rh.sphere.reg /home/brunovieira/freesurfer/average/rh.DKTaparc.atlas.acfb40.noaparc.i12.2016-08-02.gcs ../label/rh.aparc.DKTatlas.annot 

#-----------------------------------------
#@# Parcellation Stats 3 lh Sun Feb 20 03:09:21 -03 2022

 mris_anatomical_stats -th3 -mgz -cortex ../label/lh.cortex.label -f ../stats/lh.aparc.DKTatlas.stats -b -a ../label/lh.aparc.DKTatlas.annot -c ../label/aparc.annot.DKTatlas.ctab A00073230 lh white 

#-----------------------------------------
#@# Parcellation Stats 3 rh Sun Feb 20 03:09:49 -03 2022

 mris_anatomical_stats -th3 -mgz -cortex ../label/rh.cortex.label -f ../stats/rh.aparc.DKTatlas.stats -b -a ../label/rh.aparc.DKTatlas.annot -c ../label/aparc.annot.DKTatlas.ctab A00073230 rh white 

#-----------------------------------------
#@# WM/GM Contrast lh Sun Feb 20 03:10:18 -03 2022

 pctsurfcon --s A00073230 --lh-only 

#-----------------------------------------
#@# WM/GM Contrast rh Sun Feb 20 03:10:22 -03 2022

 pctsurfcon --s A00073230 --rh-only 

#-----------------------------------------
#@# Relabel Hypointensities Sun Feb 20 03:10:28 -03 2022

 mri_relabel_hypointensities aseg.presurf.mgz ../surf aseg.presurf.hypos.mgz 

#-----------------------------------------
#@# AParc-to-ASeg aparc Sun Feb 20 03:10:44 -03 2022

 mri_aparc2aseg --s A00073230 --volmask --aseg aseg.presurf.hypos --relabel mri/norm.mgz mri/transforms/talairach.m3z /home/brunovieira/freesurfer/average/RB_all_2016-05-10.vc700.gca mri/aseg.auto_noCCseg.label_intensities.txt 

#-----------------------------------------
#@# AParc-to-ASeg a2009s Sun Feb 20 03:14:23 -03 2022

 mri_aparc2aseg --s A00073230 --volmask --aseg aseg.presurf.hypos --relabel mri/norm.mgz mri/transforms/talairach.m3z /home/brunovieira/freesurfer/average/RB_all_2016-05-10.vc700.gca mri/aseg.auto_noCCseg.label_intensities.txt --a2009s 

#-----------------------------------------
#@# AParc-to-ASeg DKTatlas Sun Feb 20 03:18:03 -03 2022

 mri_aparc2aseg --s A00073230 --volmask --aseg aseg.presurf.hypos --relabel mri/norm.mgz mri/transforms/talairach.m3z /home/brunovieira/freesurfer/average/RB_all_2016-05-10.vc700.gca mri/aseg.auto_noCCseg.label_intensities.txt --annot aparc.DKTatlas --o mri/aparc.DKTatlas+aseg.mgz 

#-----------------------------------------
#@# APas-to-ASeg Sun Feb 20 03:21:47 -03 2022

 apas2aseg --i aparc+aseg.mgz --o aseg.mgz 

#--------------------------------------------
#@# ASeg Stats Sun Feb 20 03:21:57 -03 2022

 mri_segstats --seg mri/aseg.mgz --sum stats/aseg.stats --pv mri/norm.mgz --empty --brainmask mri/brainmask.mgz --brain-vol-from-seg --excludeid 0 --excl-ctxgmwm --supratent --subcortgray --in mri/norm.mgz --in-intensity-name norm --in-intensity-units MR --etiv --surf-wm-vol --surf-ctx-vol --totalgray --euler --ctab /home/brunovieira/freesurfer/ASegStatsLUT.txt --subject A00073230 

#-----------------------------------------
#@# WMParc Sun Feb 20 03:24:32 -03 2022

 mri_aparc2aseg --s A00073230 --labelwm --hypo-as-wm --rip-unknown --volmask --o mri/wmparc.mgz --ctxseg aparc+aseg.mgz 


 mri_segstats --seg mri/wmparc.mgz --sum stats/wmparc.stats --pv mri/norm.mgz --excludeid 0 --brainmask mri/brainmask.mgz --in mri/norm.mgz --in-intensity-name norm --in-intensity-units MR --subject A00073230 --surf-wm-vol --ctab /home/brunovieira/freesurfer/WMParcStatsLUT.txt --etiv 

#--------------------------------------------
#@# BA_exvivo Labels lh Sun Feb 20 03:32:28 -03 2022

 mri_label2label --srcsubject fsaverage --srclabel /home/brunovieira/Tamires_Experiments/Bases_de_Dados/nki_data/fsaverage/label/lh.BA1_exvivo.label --trgsubject A00073230 --trglabel ./lh.BA1_exvivo.label --hemi lh --regmethod surface 


 mri_label2label --srcsubject fsaverage --srclabel /home/brunovieira/Tamires_Experiments/Bases_de_Dados/nki_data/fsaverage/label/lh.BA2_exvivo.label --trgsubject A00073230 --trglabel ./lh.BA2_exvivo.label --hemi lh --regmethod surface 


 mri_label2label --srcsubject fsaverage --srclabel /home/brunovieira/Tamires_Experiments/Bases_de_Dados/nki_data/fsaverage/label/lh.BA3a_exvivo.label --trgsubject A00073230 --trglabel ./lh.BA3a_exvivo.label --hemi lh --regmethod surface 


 mri_label2label --srcsubject fsaverage --srclabel /home/brunovieira/Tamires_Experiments/Bases_de_Dados/nki_data/fsaverage/label/lh.BA3b_exvivo.label --trgsubject A00073230 --trglabel ./lh.BA3b_exvivo.label --hemi lh --regmethod surface 


 mri_label2label --srcsubject fsaverage --srclabel /home/brunovieira/Tamires_Experiments/Bases_de_Dados/nki_data/fsaverage/label/lh.BA4a_exvivo.label --trgsubject A00073230 --trglabel ./lh.BA4a_exvivo.label --hemi lh --regmethod surface 


 mri_label2label --srcsubject fsaverage --srclabel /home/brunovieira/Tamires_Experiments/Bases_de_Dados/nki_data/fsaverage/label/lh.BA4p_exvivo.label --trgsubject A00073230 --trglabel ./lh.BA4p_exvivo.label --hemi lh --regmethod surface 


 mri_label2label --srcsubject fsaverage --srclabel /home/brunovieira/Tamires_Experiments/Bases_de_Dados/nki_data/fsaverage/label/lh.BA6_exvivo.label --trgsubject A00073230 --trglabel ./lh.BA6_exvivo.label --hemi lh --regmethod surface 


 mri_label2label --srcsubject fsaverage --srclabel /home/brunovieira/Tamires_Experiments/Bases_de_Dados/nki_data/fsaverage/label/lh.BA44_exvivo.label --trgsubject A00073230 --trglabel ./lh.BA44_exvivo.label --hemi lh --regmethod surface 


 mri_label2label --srcsubject fsaverage --srclabel /home/brunovieira/Tamires_Experiments/Bases_de_Dados/nki_data/fsaverage/label/lh.BA45_exvivo.label --trgsubject A00073230 --trglabel ./lh.BA45_exvivo.label --hemi lh --regmethod surface 


 mri_label2label --srcsubject fsaverage --srclabel /home/brunovieira/Tamires_Experiments/Bases_de_Dados/nki_data/fsaverage/label/lh.V1_exvivo.label --trgsubject A00073230 --trglabel ./lh.V1_exvivo.label --hemi lh --regmethod surface 


 mri_label2label --srcsubject fsaverage --srclabel /home/brunovieira/Tamires_Experiments/Bases_de_Dados/nki_data/fsaverage/label/lh.V2_exvivo.label --trgsubject A00073230 --trglabel ./lh.V2_exvivo.label --hemi lh --regmethod surface 


 mri_label2label --srcsubject fsaverage --srclabel /home/brunovieira/Tamires_Experiments/Bases_de_Dados/nki_data/fsaverage/label/lh.MT_exvivo.label --trgsubject A00073230 --trglabel ./lh.MT_exvivo.label --hemi lh --regmethod surface 


 mri_label2label --srcsubject fsaverage --srclabel /home/brunovieira/Tamires_Experiments/Bases_de_Dados/nki_data/fsaverage/label/lh.entorhinal_exvivo.label --trgsubject A00073230 --trglabel ./lh.entorhinal_exvivo.label --hemi lh --regmethod surface 


 mri_label2label --srcsubject fsaverage --srclabel /home/brunovieira/Tamires_Experiments/Bases_de_Dados/nki_data/fsaverage/label/lh.perirhinal_exvivo.label --trgsubject A00073230 --trglabel ./lh.perirhinal_exvivo.label --hemi lh --regmethod surface 


 mri_label2label --srcsubject fsaverage --srclabel /home/brunovieira/Tamires_Experiments/Bases_de_Dados/nki_data/fsaverage/label/lh.BA1_exvivo.thresh.label --trgsubject A00073230 --trglabel ./lh.BA1_exvivo.thresh.label --hemi lh --regmethod surface 


 mri_label2label --srcsubject fsaverage --srclabel /home/brunovieira/Tamires_Experiments/Bases_de_Dados/nki_data/fsaverage/label/lh.BA2_exvivo.thresh.label --trgsubject A00073230 --trglabel ./lh.BA2_exvivo.thresh.label --hemi lh --regmethod surface 


 mri_label2label --srcsubject fsaverage --srclabel /home/brunovieira/Tamires_Experiments/Bases_de_Dados/nki_data/fsaverage/label/lh.BA3a_exvivo.thresh.label --trgsubject A00073230 --trglabel ./lh.BA3a_exvivo.thresh.label --hemi lh --regmethod surface 


 mri_label2label --srcsubject fsaverage --srclabel /home/brunovieira/Tamires_Experiments/Bases_de_Dados/nki_data/fsaverage/label/lh.BA3b_exvivo.thresh.label --trgsubject A00073230 --trglabel ./lh.BA3b_exvivo.thresh.label --hemi lh --regmethod surface 


 mri_label2label --srcsubject fsaverage --srclabel /home/brunovieira/Tamires_Experiments/Bases_de_Dados/nki_data/fsaverage/label/lh.BA4a_exvivo.thresh.label --trgsubject A00073230 --trglabel ./lh.BA4a_exvivo.thresh.label --hemi lh --regmethod surface 


 mri_label2label --srcsubject fsaverage --srclabel /home/brunovieira/Tamires_Experiments/Bases_de_Dados/nki_data/fsaverage/label/lh.BA4p_exvivo.thresh.label --trgsubject A00073230 --trglabel ./lh.BA4p_exvivo.thresh.label --hemi lh --regmethod surface 


 mri_label2label --srcsubject fsaverage --srclabel /home/brunovieira/Tamires_Experiments/Bases_de_Dados/nki_data/fsaverage/label/lh.BA6_exvivo.thresh.label --trgsubject A00073230 --trglabel ./lh.BA6_exvivo.thresh.label --hemi lh --regmethod surface 


 mri_label2label --srcsubject fsaverage --srclabel /home/brunovieira/Tamires_Experiments/Bases_de_Dados/nki_data/fsaverage/label/lh.BA44_exvivo.thresh.label --trgsubject A00073230 --trglabel ./lh.BA44_exvivo.thresh.label --hemi lh --regmethod surface 


 mri_label2label --srcsubject fsaverage --srclabel /home/brunovieira/Tamires_Experiments/Bases_de_Dados/nki_data/fsaverage/label/lh.BA45_exvivo.thresh.label --trgsubject A00073230 --trglabel ./lh.BA45_exvivo.thresh.label --hemi lh --regmethod surface 


 mri_label2label --srcsubject fsaverage --srclabel /home/brunovieira/Tamires_Experiments/Bases_de_Dados/nki_data/fsaverage/label/lh.V1_exvivo.thresh.label --trgsubject A00073230 --trglabel ./lh.V1_exvivo.thresh.label --hemi lh --regmethod surface 


 mri_label2label --srcsubject fsaverage --srclabel /home/brunovieira/Tamires_Experiments/Bases_de_Dados/nki_data/fsaverage/label/lh.V2_exvivo.thresh.label --trgsubject A00073230 --trglabel ./lh.V2_exvivo.thresh.label --hemi lh --regmethod surface 


 mri_label2label --srcsubject fsaverage --srclabel /home/brunovieira/Tamires_Experiments/Bases_de_Dados/nki_data/fsaverage/label/lh.MT_exvivo.thresh.label --trgsubject A00073230 --trglabel ./lh.MT_exvivo.thresh.label --hemi lh --regmethod surface 


 mri_label2label --srcsubject fsaverage --srclabel /home/brunovieira/Tamires_Experiments/Bases_de_Dados/nki_data/fsaverage/label/lh.entorhinal_exvivo.thresh.label --trgsubject A00073230 --trglabel ./lh.entorhinal_exvivo.thresh.label --hemi lh --regmethod surface 


 mri_label2label --srcsubject fsaverage --srclabel /home/brunovieira/Tamires_Experiments/Bases_de_Dados/nki_data/fsaverage/label/lh.perirhinal_exvivo.thresh.label --trgsubject A00073230 --trglabel ./lh.perirhinal_exvivo.thresh.label --hemi lh --regmethod surface 


 mris_label2annot --s A00073230 --hemi lh --ctab /home/brunovieira/freesurfer/average/colortable_BA.txt --l lh.BA1_exvivo.label --l lh.BA2_exvivo.label --l lh.BA3a_exvivo.label --l lh.BA3b_exvivo.label --l lh.BA4a_exvivo.label --l lh.BA4p_exvivo.label --l lh.BA6_exvivo.label --l lh.BA44_exvivo.label --l lh.BA45_exvivo.label --l lh.V1_exvivo.label --l lh.V2_exvivo.label --l lh.MT_exvivo.label --l lh.entorhinal_exvivo.label --l lh.perirhinal_exvivo.label --a BA_exvivo --maxstatwinner --noverbose 


 mris_label2annot --s A00073230 --hemi lh --ctab /home/brunovieira/freesurfer/average/colortable_BA.txt --l lh.BA1_exvivo.thresh.label --l lh.BA2_exvivo.thresh.label --l lh.BA3a_exvivo.thresh.label --l lh.BA3b_exvivo.thresh.label --l lh.BA4a_exvivo.thresh.label --l lh.BA4p_exvivo.thresh.label --l lh.BA6_exvivo.thresh.label --l lh.BA44_exvivo.thresh.label --l lh.BA45_exvivo.thresh.label --l lh.V1_exvivo.thresh.label --l lh.V2_exvivo.thresh.label --l lh.MT_exvivo.thresh.label --l lh.entorhinal_exvivo.thresh.label --l lh.perirhinal_exvivo.thresh.label --a BA_exvivo.thresh --maxstatwinner --noverbose 


 mris_anatomical_stats -th3 -mgz -f ../stats/lh.BA_exvivo.stats -b -a ./lh.BA_exvivo.annot -c ./BA_exvivo.ctab A00073230 lh white 


 mris_anatomical_stats -th3 -mgz -f ../stats/lh.BA_exvivo.thresh.stats -b -a ./lh.BA_exvivo.thresh.annot -c ./BA_exvivo.thresh.ctab A00073230 lh white 

#--------------------------------------------
#@# BA_exvivo Labels rh Sun Feb 20 03:36:04 -03 2022

 mri_label2label --srcsubject fsaverage --srclabel /home/brunovieira/Tamires_Experiments/Bases_de_Dados/nki_data/fsaverage/label/rh.BA1_exvivo.label --trgsubject A00073230 --trglabel ./rh.BA1_exvivo.label --hemi rh --regmethod surface 


 mri_label2label --srcsubject fsaverage --srclabel /home/brunovieira/Tamires_Experiments/Bases_de_Dados/nki_data/fsaverage/label/rh.BA2_exvivo.label --trgsubject A00073230 --trglabel ./rh.BA2_exvivo.label --hemi rh --regmethod surface 


 mri_label2label --srcsubject fsaverage --srclabel /home/brunovieira/Tamires_Experiments/Bases_de_Dados/nki_data/fsaverage/label/rh.BA3a_exvivo.label --trgsubject A00073230 --trglabel ./rh.BA3a_exvivo.label --hemi rh --regmethod surface 


 mri_label2label --srcsubject fsaverage --srclabel /home/brunovieira/Tamires_Experiments/Bases_de_Dados/nki_data/fsaverage/label/rh.BA3b_exvivo.label --trgsubject A00073230 --trglabel ./rh.BA3b_exvivo.label --hemi rh --regmethod surface 


 mri_label2label --srcsubject fsaverage --srclabel /home/brunovieira/Tamires_Experiments/Bases_de_Dados/nki_data/fsaverage/label/rh.BA4a_exvivo.label --trgsubject A00073230 --trglabel ./rh.BA4a_exvivo.label --hemi rh --regmethod surface 


 mri_label2label --srcsubject fsaverage --srclabel /home/brunovieira/Tamires_Experiments/Bases_de_Dados/nki_data/fsaverage/label/rh.BA4p_exvivo.label --trgsubject A00073230 --trglabel ./rh.BA4p_exvivo.label --hemi rh --regmethod surface 


 mri_label2label --srcsubject fsaverage --srclabel /home/brunovieira/Tamires_Experiments/Bases_de_Dados/nki_data/fsaverage/label/rh.BA6_exvivo.label --trgsubject A00073230 --trglabel ./rh.BA6_exvivo.label --hemi rh --regmethod surface 


 mri_label2label --srcsubject fsaverage --srclabel /home/brunovieira/Tamires_Experiments/Bases_de_Dados/nki_data/fsaverage/label/rh.BA44_exvivo.label --trgsubject A00073230 --trglabel ./rh.BA44_exvivo.label --hemi rh --regmethod surface 


 mri_label2label --srcsubject fsaverage --srclabel /home/brunovieira/Tamires_Experiments/Bases_de_Dados/nki_data/fsaverage/label/rh.BA45_exvivo.label --trgsubject A00073230 --trglabel ./rh.BA45_exvivo.label --hemi rh --regmethod surface 


 mri_label2label --srcsubject fsaverage --srclabel /home/brunovieira/Tamires_Experiments/Bases_de_Dados/nki_data/fsaverage/label/rh.V1_exvivo.label --trgsubject A00073230 --trglabel ./rh.V1_exvivo.label --hemi rh --regmethod surface 


 mri_label2label --srcsubject fsaverage --srclabel /home/brunovieira/Tamires_Experiments/Bases_de_Dados/nki_data/fsaverage/label/rh.V2_exvivo.label --trgsubject A00073230 --trglabel ./rh.V2_exvivo.label --hemi rh --regmethod surface 


 mri_label2label --srcsubject fsaverage --srclabel /home/brunovieira/Tamires_Experiments/Bases_de_Dados/nki_data/fsaverage/label/rh.MT_exvivo.label --trgsubject A00073230 --trglabel ./rh.MT_exvivo.label --hemi rh --regmethod surface 


 mri_label2label --srcsubject fsaverage --srclabel /home/brunovieira/Tamires_Experiments/Bases_de_Dados/nki_data/fsaverage/label/rh.entorhinal_exvivo.label --trgsubject A00073230 --trglabel ./rh.entorhinal_exvivo.label --hemi rh --regmethod surface 


 mri_label2label --srcsubject fsaverage --srclabel /home/brunovieira/Tamires_Experiments/Bases_de_Dados/nki_data/fsaverage/label/rh.perirhinal_exvivo.label --trgsubject A00073230 --trglabel ./rh.perirhinal_exvivo.label --hemi rh --regmethod surface 


 mri_label2label --srcsubject fsaverage --srclabel /home/brunovieira/Tamires_Experiments/Bases_de_Dados/nki_data/fsaverage/label/rh.BA1_exvivo.thresh.label --trgsubject A00073230 --trglabel ./rh.BA1_exvivo.thresh.label --hemi rh --regmethod surface 


 mri_label2label --srcsubject fsaverage --srclabel /home/brunovieira/Tamires_Experiments/Bases_de_Dados/nki_data/fsaverage/label/rh.BA2_exvivo.thresh.label --trgsubject A00073230 --trglabel ./rh.BA2_exvivo.thresh.label --hemi rh --regmethod surface 


 mri_label2label --srcsubject fsaverage --srclabel /home/brunovieira/Tamires_Experiments/Bases_de_Dados/nki_data/fsaverage/label/rh.BA3a_exvivo.thresh.label --trgsubject A00073230 --trglabel ./rh.BA3a_exvivo.thresh.label --hemi rh --regmethod surface 


 mri_label2label --srcsubject fsaverage --srclabel /home/brunovieira/Tamires_Experiments/Bases_de_Dados/nki_data/fsaverage/label/rh.BA3b_exvivo.thresh.label --trgsubject A00073230 --trglabel ./rh.BA3b_exvivo.thresh.label --hemi rh --regmethod surface 


 mri_label2label --srcsubject fsaverage --srclabel /home/brunovieira/Tamires_Experiments/Bases_de_Dados/nki_data/fsaverage/label/rh.BA4a_exvivo.thresh.label --trgsubject A00073230 --trglabel ./rh.BA4a_exvivo.thresh.label --hemi rh --regmethod surface 


 mri_label2label --srcsubject fsaverage --srclabel /home/brunovieira/Tamires_Experiments/Bases_de_Dados/nki_data/fsaverage/label/rh.BA4p_exvivo.thresh.label --trgsubject A00073230 --trglabel ./rh.BA4p_exvivo.thresh.label --hemi rh --regmethod surface 


 mri_label2label --srcsubject fsaverage --srclabel /home/brunovieira/Tamires_Experiments/Bases_de_Dados/nki_data/fsaverage/label/rh.BA6_exvivo.thresh.label --trgsubject A00073230 --trglabel ./rh.BA6_exvivo.thresh.label --hemi rh --regmethod surface 


 mri_label2label --srcsubject fsaverage --srclabel /home/brunovieira/Tamires_Experiments/Bases_de_Dados/nki_data/fsaverage/label/rh.BA44_exvivo.thresh.label --trgsubject A00073230 --trglabel ./rh.BA44_exvivo.thresh.label --hemi rh --regmethod surface 


 mri_label2label --srcsubject fsaverage --srclabel /home/brunovieira/Tamires_Experiments/Bases_de_Dados/nki_data/fsaverage/label/rh.BA45_exvivo.thresh.label --trgsubject A00073230 --trglabel ./rh.BA45_exvivo.thresh.label --hemi rh --regmethod surface 


 mri_label2label --srcsubject fsaverage --srclabel /home/brunovieira/Tamires_Experiments/Bases_de_Dados/nki_data/fsaverage/label/rh.V1_exvivo.thresh.label --trgsubject A00073230 --trglabel ./rh.V1_exvivo.thresh.label --hemi rh --regmethod surface 


 mri_label2label --srcsubject fsaverage --srclabel /home/brunovieira/Tamires_Experiments/Bases_de_Dados/nki_data/fsaverage/label/rh.V2_exvivo.thresh.label --trgsubject A00073230 --trglabel ./rh.V2_exvivo.thresh.label --hemi rh --regmethod surface 


 mri_label2label --srcsubject fsaverage --srclabel /home/brunovieira/Tamires_Experiments/Bases_de_Dados/nki_data/fsaverage/label/rh.MT_exvivo.thresh.label --trgsubject A00073230 --trglabel ./rh.MT_exvivo.thresh.label --hemi rh --regmethod surface 


 mri_label2label --srcsubject fsaverage --srclabel /home/brunovieira/Tamires_Experiments/Bases_de_Dados/nki_data/fsaverage/label/rh.entorhinal_exvivo.thresh.label --trgsubject A00073230 --trglabel ./rh.entorhinal_exvivo.thresh.label --hemi rh --regmethod surface 


 mri_label2label --srcsubject fsaverage --srclabel /home/brunovieira/Tamires_Experiments/Bases_de_Dados/nki_data/fsaverage/label/rh.perirhinal_exvivo.thresh.label --trgsubject A00073230 --trglabel ./rh.perirhinal_exvivo.thresh.label --hemi rh --regmethod surface 


 mris_label2annot --s A00073230 --hemi rh --ctab /home/brunovieira/freesurfer/average/colortable_BA.txt --l rh.BA1_exvivo.label --l rh.BA2_exvivo.label --l rh.BA3a_exvivo.label --l rh.BA3b_exvivo.label --l rh.BA4a_exvivo.label --l rh.BA4p_exvivo.label --l rh.BA6_exvivo.label --l rh.BA44_exvivo.label --l rh.BA45_exvivo.label --l rh.V1_exvivo.label --l rh.V2_exvivo.label --l rh.MT_exvivo.label --l rh.entorhinal_exvivo.label --l rh.perirhinal_exvivo.label --a BA_exvivo --maxstatwinner --noverbose 


 mris_label2annot --s A00073230 --hemi rh --ctab /home/brunovieira/freesurfer/average/colortable_BA.txt --l rh.BA1_exvivo.thresh.label --l rh.BA2_exvivo.thresh.label --l rh.BA3a_exvivo.thresh.label --l rh.BA3b_exvivo.thresh.label --l rh.BA4a_exvivo.thresh.label --l rh.BA4p_exvivo.thresh.label --l rh.BA6_exvivo.thresh.label --l rh.BA44_exvivo.thresh.label --l rh.BA45_exvivo.thresh.label --l rh.V1_exvivo.thresh.label --l rh.V2_exvivo.thresh.label --l rh.MT_exvivo.thresh.label --l rh.entorhinal_exvivo.thresh.label --l rh.perirhinal_exvivo.thresh.label --a BA_exvivo.thresh --maxstatwinner --noverbose 


 mris_anatomical_stats -th3 -mgz -f ../stats/rh.BA_exvivo.stats -b -a ./rh.BA_exvivo.annot -c ./BA_exvivo.ctab A00073230 rh white 


 mris_anatomical_stats -th3 -mgz -f ../stats/rh.BA_exvivo.thresh.stats -b -a ./rh.BA_exvivo.thresh.annot -c ./BA_exvivo.thresh.ctab A00073230 rh white 
