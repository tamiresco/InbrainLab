

#---------------------------------
# New invocation of recon-all Wed Oct 20 21:36:40 -03 2021 
#--------------------------------------------
#@# MotionCor Wed Oct 20 21:36:46 -03 2021

 cp /home/brunovieira/freesurfer/nki_data/A00008326/mri/orig/001.mgz /home/brunovieira/freesurfer/nki_data/A00008326/mri/rawavg.mgz 


 mri_convert /home/brunovieira/freesurfer/nki_data/A00008326/mri/rawavg.mgz /home/brunovieira/freesurfer/nki_data/A00008326/mri/orig.mgz --conform 


 mri_add_xform_to_header -c /home/brunovieira/freesurfer/nki_data/A00008326/mri/transforms/talairach.xfm /home/brunovieira/freesurfer/nki_data/A00008326/mri/orig.mgz /home/brunovieira/freesurfer/nki_data/A00008326/mri/orig.mgz 

#--------------------------------------------
#@# Talairach Wed Oct 20 21:36:59 -03 2021

 mri_nu_correct.mni --no-rescale --i orig.mgz --o orig_nu.mgz --n 1 --proto-iters 1000 --distance 50 


 talairach_avi --i orig_nu.mgz --xfm transforms/talairach.auto.xfm 

talairach_avi log file is transforms/talairach_avi.log...

 cp transforms/talairach.auto.xfm transforms/talairach.xfm 

#--------------------------------------------
#@# Talairach Failure Detection Wed Oct 20 21:39:09 -03 2021

 talairach_afd -T 0.005 -xfm transforms/talairach.xfm 


 awk -f /home/brunovieira/freesurfer/bin/extract_talairach_avi_QA.awk /home/brunovieira/freesurfer/nki_data/A00008326/mri/transforms/talairach_avi.log 


 tal_QC_AZS /home/brunovieira/freesurfer/nki_data/A00008326/mri/transforms/talairach_avi.log 

#--------------------------------------------
#@# Nu Intensity Correction Wed Oct 20 21:39:10 -03 2021

 mri_nu_correct.mni --i orig.mgz --o nu.mgz --uchar transforms/talairach.xfm --n 2 


 mri_add_xform_to_header -c /home/brunovieira/freesurfer/nki_data/A00008326/mri/transforms/talairach.xfm nu.mgz nu.mgz 

#--------------------------------------------
#@# Intensity Normalization Wed Oct 20 21:41:49 -03 2021

 mri_normalize -g 1 -mprage nu.mgz T1.mgz 

#--------------------------------------------
#@# Skull Stripping Wed Oct 20 21:43:40 -03 2021

 mri_em_register -rusage /home/brunovieira/freesurfer/nki_data/A00008326/touch/rusage.mri_em_register.skull.dat -skull nu.mgz /home/brunovieira/freesurfer/average/RB_all_withskull_2016-05-10.vc700.gca transforms/talairach_with_skull.lta 


 mri_watershed -rusage /home/brunovieira/freesurfer/nki_data/A00008326/touch/rusage.mri_watershed.dat -T1 -brain_atlas /home/brunovieira/freesurfer/average/RB_all_withskull_2016-05-10.vc700.gca transforms/talairach_with_skull.lta T1.mgz brainmask.auto.mgz 


 cp brainmask.auto.mgz brainmask.mgz 

#-------------------------------------
#@# EM Registration Wed Oct 20 22:01:30 -03 2021

 mri_em_register -rusage /home/brunovieira/freesurfer/nki_data/A00008326/touch/rusage.mri_em_register.dat -uns 3 -mask brainmask.mgz nu.mgz /home/brunovieira/freesurfer/average/RB_all_2016-05-10.vc700.gca transforms/talairach.lta 

#--------------------------------------
#@# CA Normalize Wed Oct 20 22:14:18 -03 2021

 mri_ca_normalize -c ctrl_pts.mgz -mask brainmask.mgz nu.mgz /home/brunovieira/freesurfer/average/RB_all_2016-05-10.vc700.gca transforms/talairach.lta norm.mgz 

#--------------------------------------
#@# CA Reg Wed Oct 20 22:16:26 -03 2021

 mri_ca_register -rusage /home/brunovieira/freesurfer/nki_data/A00008326/touch/rusage.mri_ca_register.dat -nobigventricles -T transforms/talairach.lta -align-after -mask brainmask.mgz norm.mgz /home/brunovieira/freesurfer/average/RB_all_2016-05-10.vc700.gca transforms/talairach.m3z 

#--------------------------------------
#@# SubCort Seg Thu Oct 21 00:12:56 -03 2021

 mri_ca_label -relabel_unlikely 9 .3 -prior 0.5 -align norm.mgz transforms/talairach.m3z /home/brunovieira/freesurfer/average/RB_all_2016-05-10.vc700.gca aseg.auto_noCCseg.mgz 


 mri_cc -aseg aseg.auto_noCCseg.mgz -o aseg.auto.mgz -lta /home/brunovieira/freesurfer/nki_data/A00008326/mri/transforms/cc_up.lta A00008326 

#--------------------------------------
#@# Merge ASeg Thu Oct 21 01:06:45 -03 2021

 cp aseg.auto.mgz aseg.presurf.mgz 

#--------------------------------------------
#@# Intensity Normalization2 Thu Oct 21 01:06:45 -03 2021

 mri_normalize -mprage -aseg aseg.presurf.mgz -mask brainmask.mgz norm.mgz brain.mgz 

#--------------------------------------------
#@# Mask BFS Thu Oct 21 01:10:15 -03 2021

 mri_mask -T 5 brain.mgz brainmask.mgz brain.finalsurfs.mgz 

#--------------------------------------------
#@# WM Segmentation Thu Oct 21 01:10:17 -03 2021

 mri_segment -mprage brain.mgz wm.seg.mgz 


 mri_edit_wm_with_aseg -keep-in wm.seg.mgz brain.mgz aseg.presurf.mgz wm.asegedit.mgz 


 mri_pretess wm.asegedit.mgz wm norm.mgz wm.mgz 

#--------------------------------------------
#@# Fill Thu Oct 21 01:12:36 -03 2021

 mri_fill -a ../scripts/ponscc.cut.log -xform transforms/talairach.lta -segmentation aseg.auto_noCCseg.mgz wm.mgz filled.mgz 

#--------------------------------------------
#@# Tessellate lh Thu Oct 21 01:13:20 -03 2021

 mri_pretess ../mri/filled.mgz 255 ../mri/norm.mgz ../mri/filled-pretess255.mgz 


 mri_tessellate ../mri/filled-pretess255.mgz 255 ../surf/lh.orig.nofix 


 rm -f ../mri/filled-pretess255.mgz 


 mris_extract_main_component ../surf/lh.orig.nofix ../surf/lh.orig.nofix 

#--------------------------------------------
#@# Tessellate rh Thu Oct 21 01:13:25 -03 2021

 mri_pretess ../mri/filled.mgz 127 ../mri/norm.mgz ../mri/filled-pretess127.mgz 


 mri_tessellate ../mri/filled-pretess127.mgz 127 ../surf/rh.orig.nofix 


 rm -f ../mri/filled-pretess127.mgz 


 mris_extract_main_component ../surf/rh.orig.nofix ../surf/rh.orig.nofix 

#--------------------------------------------
#@# Smooth1 lh Thu Oct 21 01:13:31 -03 2021

 mris_smooth -nw -seed 1234 ../surf/lh.orig.nofix ../surf/lh.smoothwm.nofix 

#--------------------------------------------
#@# Smooth1 rh Thu Oct 21 01:13:36 -03 2021

 mris_smooth -nw -seed 1234 ../surf/rh.orig.nofix ../surf/rh.smoothwm.nofix 

#--------------------------------------------
#@# Inflation1 lh Thu Oct 21 01:13:40 -03 2021

 mris_inflate -no-save-sulc ../surf/lh.smoothwm.nofix ../surf/lh.inflated.nofix 

#--------------------------------------------
#@# Inflation1 rh Thu Oct 21 01:14:05 -03 2021

 mris_inflate -no-save-sulc ../surf/rh.smoothwm.nofix ../surf/rh.inflated.nofix 

#--------------------------------------------
#@# QSphere lh Thu Oct 21 01:14:29 -03 2021

 mris_sphere -q -seed 1234 ../surf/lh.inflated.nofix ../surf/lh.qsphere.nofix 

#--------------------------------------------
#@# QSphere rh Thu Oct 21 01:17:03 -03 2021

 mris_sphere -q -seed 1234 ../surf/rh.inflated.nofix ../surf/rh.qsphere.nofix 

#--------------------------------------------
#@# Fix Topology Copy lh Thu Oct 21 01:19:59 -03 2021

 cp ../surf/lh.orig.nofix ../surf/lh.orig 


 cp ../surf/lh.inflated.nofix ../surf/lh.inflated 

#--------------------------------------------
#@# Fix Topology Copy rh Thu Oct 21 01:19:59 -03 2021

 cp ../surf/rh.orig.nofix ../surf/rh.orig 


 cp ../surf/rh.inflated.nofix ../surf/rh.inflated 

#@# Fix Topology lh Thu Oct 21 01:20:00 -03 2021

 mris_fix_topology -rusage /home/brunovieira/freesurfer/nki_data/A00008326/touch/rusage.mris_fix_topology.lh.dat -mgz -sphere qsphere.nofix -ga -seed 1234 A00008326 lh 

#@# Fix Topology rh Thu Oct 21 01:34:58 -03 2021

 mris_fix_topology -rusage /home/brunovieira/freesurfer/nki_data/A00008326/touch/rusage.mris_fix_topology.rh.dat -mgz -sphere qsphere.nofix -ga -seed 1234 A00008326 rh 


 mris_euler_number ../surf/lh.orig 


 mris_euler_number ../surf/rh.orig 


 mris_remove_intersection ../surf/lh.orig ../surf/lh.orig 


 rm ../surf/lh.inflated 


 mris_remove_intersection ../surf/rh.orig ../surf/rh.orig 


 rm ../surf/rh.inflated 

#--------------------------------------------
#@# Make White Surf lh Thu Oct 21 01:41:59 -03 2021

 mris_make_surfaces -aseg ../mri/aseg.presurf -white white.preaparc -noaparc -whiteonly -mgz -T1 brain.finalsurfs A00008326 lh 

#--------------------------------------------
#@# Make White Surf rh Thu Oct 21 01:45:27 -03 2021

 mris_make_surfaces -aseg ../mri/aseg.presurf -white white.preaparc -noaparc -whiteonly -mgz -T1 brain.finalsurfs A00008326 rh 

#--------------------------------------------
#@# Smooth2 lh Thu Oct 21 01:48:53 -03 2021

 mris_smooth -n 3 -nw -seed 1234 ../surf/lh.white.preaparc ../surf/lh.smoothwm 

#--------------------------------------------
#@# Smooth2 rh Thu Oct 21 01:48:57 -03 2021

 mris_smooth -n 3 -nw -seed 1234 ../surf/rh.white.preaparc ../surf/rh.smoothwm 

#--------------------------------------------
#@# Inflation2 lh Thu Oct 21 01:49:01 -03 2021

 mris_inflate -rusage /home/brunovieira/freesurfer/nki_data/A00008326/touch/rusage.mris_inflate.lh.dat ../surf/lh.smoothwm ../surf/lh.inflated 

#--------------------------------------------
#@# Inflation2 rh Thu Oct 21 01:49:26 -03 2021

 mris_inflate -rusage /home/brunovieira/freesurfer/nki_data/A00008326/touch/rusage.mris_inflate.rh.dat ../surf/rh.smoothwm ../surf/rh.inflated 

#--------------------------------------------
#@# Curv .H and .K lh Thu Oct 21 01:49:51 -03 2021

 mris_curvature -w lh.white.preaparc 


 mris_curvature -thresh .999 -n -a 5 -w -distances 10 10 lh.inflated 

#--------------------------------------------
#@# Curv .H and .K rh Thu Oct 21 01:50:48 -03 2021

 mris_curvature -w rh.white.preaparc 


 mris_curvature -thresh .999 -n -a 5 -w -distances 10 10 rh.inflated 


#-----------------------------------------
#@# Curvature Stats lh Thu Oct 21 01:51:48 -03 2021

 mris_curvature_stats -m --writeCurvatureFiles -G -o ../stats/lh.curv.stats -F smoothwm A00008326 lh curv sulc 


#-----------------------------------------
#@# Curvature Stats rh Thu Oct 21 01:51:51 -03 2021

 mris_curvature_stats -m --writeCurvatureFiles -G -o ../stats/rh.curv.stats -F smoothwm A00008326 rh curv sulc 

#--------------------------------------------
#@# Sphere lh Thu Oct 21 01:51:54 -03 2021

 mris_sphere -rusage /home/brunovieira/freesurfer/nki_data/A00008326/touch/rusage.mris_sphere.lh.dat -seed 1234 ../surf/lh.inflated ../surf/lh.sphere 

#--------------------------------------------
#@# Sphere rh Thu Oct 21 02:08:32 -03 2021

 mris_sphere -rusage /home/brunovieira/freesurfer/nki_data/A00008326/touch/rusage.mris_sphere.rh.dat -seed 1234 ../surf/rh.inflated ../surf/rh.sphere 

#--------------------------------------------
#@# Surf Reg lh Thu Oct 21 02:25:02 -03 2021

 mris_register -curv -rusage /home/brunovieira/freesurfer/nki_data/A00008326/touch/rusage.mris_register.lh.dat ../surf/lh.sphere /home/brunovieira/freesurfer/average/lh.folding.atlas.acfb40.noaparc.i12.2016-08-02.tif ../surf/lh.sphere.reg 

#--------------------------------------------
#@# Surf Reg rh Thu Oct 21 02:54:22 -03 2021

 mris_register -curv -rusage /home/brunovieira/freesurfer/nki_data/A00008326/touch/rusage.mris_register.rh.dat ../surf/rh.sphere /home/brunovieira/freesurfer/average/rh.folding.atlas.acfb40.noaparc.i12.2016-08-02.tif ../surf/rh.sphere.reg 

#--------------------------------------------
#@# Jacobian white lh Thu Oct 21 03:29:32 -03 2021

 mris_jacobian ../surf/lh.white.preaparc ../surf/lh.sphere.reg ../surf/lh.jacobian_white 

#--------------------------------------------
#@# Jacobian white rh Thu Oct 21 03:29:34 -03 2021

 mris_jacobian ../surf/rh.white.preaparc ../surf/rh.sphere.reg ../surf/rh.jacobian_white 

#--------------------------------------------
#@# AvgCurv lh Thu Oct 21 03:29:35 -03 2021

 mrisp_paint -a 5 /home/brunovieira/freesurfer/average/lh.folding.atlas.acfb40.noaparc.i12.2016-08-02.tif#6 ../surf/lh.sphere.reg ../surf/lh.avg_curv 

#--------------------------------------------
#@# AvgCurv rh Thu Oct 21 03:29:36 -03 2021

 mrisp_paint -a 5 /home/brunovieira/freesurfer/average/rh.folding.atlas.acfb40.noaparc.i12.2016-08-02.tif#6 ../surf/rh.sphere.reg ../surf/rh.avg_curv 

#-----------------------------------------
#@# Cortical Parc lh Thu Oct 21 03:29:37 -03 2021

 mris_ca_label -l ../label/lh.cortex.label -aseg ../mri/aseg.presurf.mgz -seed 1234 A00008326 lh ../surf/lh.sphere.reg /home/brunovieira/freesurfer/average/lh.DKaparc.atlas.acfb40.noaparc.i12.2016-08-02.gcs ../label/lh.aparc.annot 

#-----------------------------------------
#@# Cortical Parc rh Thu Oct 21 03:29:51 -03 2021

 mris_ca_label -l ../label/rh.cortex.label -aseg ../mri/aseg.presurf.mgz -seed 1234 A00008326 rh ../surf/rh.sphere.reg /home/brunovieira/freesurfer/average/rh.DKaparc.atlas.acfb40.noaparc.i12.2016-08-02.gcs ../label/rh.aparc.annot 

#--------------------------------------------
#@# Make Pial Surf lh Thu Oct 21 03:30:01 -03 2021

 mris_make_surfaces -orig_white white.preaparc -orig_pial white.preaparc -aseg ../mri/aseg.presurf -mgz -T1 brain.finalsurfs A00008326 lh 

#--------------------------------------------
#@# Make Pial Surf rh Thu Oct 21 03:39:31 -03 2021

 mris_make_surfaces -orig_white white.preaparc -orig_pial white.preaparc -aseg ../mri/aseg.presurf -mgz -T1 brain.finalsurfs A00008326 rh 

#--------------------------------------------
#@# Surf Volume lh Thu Oct 21 03:49:00 -03 2021
#--------------------------------------------
#@# Surf Volume rh Thu Oct 21 03:49:03 -03 2021
#--------------------------------------------
#@# Cortical ribbon mask Thu Oct 21 03:49:05 -03 2021

 mris_volmask --aseg_name aseg.presurf --label_left_white 2 --label_left_ribbon 3 --label_right_white 41 --label_right_ribbon 42 --save_ribbon A00008326 

#-----------------------------------------
#@# Parcellation Stats lh Thu Oct 21 03:54:43 -03 2021

 mris_anatomical_stats -th3 -mgz -cortex ../label/lh.cortex.label -f ../stats/lh.aparc.stats -b -a ../label/lh.aparc.annot -c ../label/aparc.annot.ctab A00008326 lh white 


 mris_anatomical_stats -th3 -mgz -cortex ../label/lh.cortex.label -f ../stats/lh.aparc.pial.stats -b -a ../label/lh.aparc.annot -c ../label/aparc.annot.ctab A00008326 lh pial 

#-----------------------------------------
#@# Parcellation Stats rh Thu Oct 21 03:55:35 -03 2021

 mris_anatomical_stats -th3 -mgz -cortex ../label/rh.cortex.label -f ../stats/rh.aparc.stats -b -a ../label/rh.aparc.annot -c ../label/aparc.annot.ctab A00008326 rh white 


 mris_anatomical_stats -th3 -mgz -cortex ../label/rh.cortex.label -f ../stats/rh.aparc.pial.stats -b -a ../label/rh.aparc.annot -c ../label/aparc.annot.ctab A00008326 rh pial 

#-----------------------------------------
#@# Cortical Parc 2 lh Thu Oct 21 03:56:23 -03 2021

 mris_ca_label -l ../label/lh.cortex.label -aseg ../mri/aseg.presurf.mgz -seed 1234 A00008326 lh ../surf/lh.sphere.reg /home/brunovieira/freesurfer/average/lh.CDaparc.atlas.acfb40.noaparc.i12.2016-08-02.gcs ../label/lh.aparc.a2009s.annot 

#-----------------------------------------
#@# Cortical Parc 2 rh Thu Oct 21 03:56:35 -03 2021

 mris_ca_label -l ../label/rh.cortex.label -aseg ../mri/aseg.presurf.mgz -seed 1234 A00008326 rh ../surf/rh.sphere.reg /home/brunovieira/freesurfer/average/rh.CDaparc.atlas.acfb40.noaparc.i12.2016-08-02.gcs ../label/rh.aparc.a2009s.annot 

#-----------------------------------------
#@# Parcellation Stats 2 lh Thu Oct 21 03:56:52 -03 2021

 mris_anatomical_stats -th3 -mgz -cortex ../label/lh.cortex.label -f ../stats/lh.aparc.a2009s.stats -b -a ../label/lh.aparc.a2009s.annot -c ../label/aparc.annot.a2009s.ctab A00008326 lh white 

#-----------------------------------------
#@# Parcellation Stats 2 rh Thu Oct 21 03:57:16 -03 2021

 mris_anatomical_stats -th3 -mgz -cortex ../label/rh.cortex.label -f ../stats/rh.aparc.a2009s.stats -b -a ../label/rh.aparc.a2009s.annot -c ../label/aparc.annot.a2009s.ctab A00008326 rh white 

#-----------------------------------------
#@# Cortical Parc 3 lh Thu Oct 21 03:57:42 -03 2021

 mris_ca_label -l ../label/lh.cortex.label -aseg ../mri/aseg.presurf.mgz -seed 1234 A00008326 lh ../surf/lh.sphere.reg /home/brunovieira/freesurfer/average/lh.DKTaparc.atlas.acfb40.noaparc.i12.2016-08-02.gcs ../label/lh.aparc.DKTatlas.annot 

#-----------------------------------------
#@# Cortical Parc 3 rh Thu Oct 21 03:57:52 -03 2021

 mris_ca_label -l ../label/rh.cortex.label -aseg ../mri/aseg.presurf.mgz -seed 1234 A00008326 rh ../surf/rh.sphere.reg /home/brunovieira/freesurfer/average/rh.DKTaparc.atlas.acfb40.noaparc.i12.2016-08-02.gcs ../label/rh.aparc.DKTatlas.annot 

#-----------------------------------------
#@# Parcellation Stats 3 lh Thu Oct 21 03:58:02 -03 2021

 mris_anatomical_stats -th3 -mgz -cortex ../label/lh.cortex.label -f ../stats/lh.aparc.DKTatlas.stats -b -a ../label/lh.aparc.DKTatlas.annot -c ../label/aparc.annot.DKTatlas.ctab A00008326 lh white 

#-----------------------------------------
#@# Parcellation Stats 3 rh Thu Oct 21 03:58:32 -03 2021

 mris_anatomical_stats -th3 -mgz -cortex ../label/rh.cortex.label -f ../stats/rh.aparc.DKTatlas.stats -b -a ../label/rh.aparc.DKTatlas.annot -c ../label/aparc.annot.DKTatlas.ctab A00008326 rh white 

#-----------------------------------------
#@# WM/GM Contrast lh Thu Oct 21 03:58:56 -03 2021

 pctsurfcon --s A00008326 --lh-only 

#-----------------------------------------
#@# WM/GM Contrast rh Thu Oct 21 03:59:01 -03 2021

 pctsurfcon --s A00008326 --rh-only 

#-----------------------------------------
#@# Relabel Hypointensities Thu Oct 21 03:59:05 -03 2021

 mri_relabel_hypointensities aseg.presurf.mgz ../surf aseg.presurf.hypos.mgz 

#-----------------------------------------
#@# AParc-to-ASeg aparc Thu Oct 21 03:59:21 -03 2021

 mri_aparc2aseg --s A00008326 --volmask --aseg aseg.presurf.hypos --relabel mri/norm.mgz mri/transforms/talairach.m3z /home/brunovieira/freesurfer/average/RB_all_2016-05-10.vc700.gca mri/aseg.auto_noCCseg.label_intensities.txt 

#-----------------------------------------
#@# AParc-to-ASeg a2009s Thu Oct 21 04:03:01 -03 2021

 mri_aparc2aseg --s A00008326 --volmask --aseg aseg.presurf.hypos --relabel mri/norm.mgz mri/transforms/talairach.m3z /home/brunovieira/freesurfer/average/RB_all_2016-05-10.vc700.gca mri/aseg.auto_noCCseg.label_intensities.txt --a2009s 

#-----------------------------------------
#@# AParc-to-ASeg DKTatlas Thu Oct 21 04:06:46 -03 2021

 mri_aparc2aseg --s A00008326 --volmask --aseg aseg.presurf.hypos --relabel mri/norm.mgz mri/transforms/talairach.m3z /home/brunovieira/freesurfer/average/RB_all_2016-05-10.vc700.gca mri/aseg.auto_noCCseg.label_intensities.txt --annot aparc.DKTatlas --o mri/aparc.DKTatlas+aseg.mgz 

#-----------------------------------------
#@# APas-to-ASeg Thu Oct 21 04:10:29 -03 2021

 apas2aseg --i aparc+aseg.mgz --o aseg.mgz 

#--------------------------------------------
#@# ASeg Stats Thu Oct 21 04:10:37 -03 2021

 mri_segstats --seg mri/aseg.mgz --sum stats/aseg.stats --pv mri/norm.mgz --empty --brainmask mri/brainmask.mgz --brain-vol-from-seg --excludeid 0 --excl-ctxgmwm --supratent --subcortgray --in mri/norm.mgz --in-intensity-name norm --in-intensity-units MR --etiv --surf-wm-vol --surf-ctx-vol --totalgray --euler --ctab /home/brunovieira/freesurfer/ASegStatsLUT.txt --subject A00008326 

#-----------------------------------------
#@# WMParc Thu Oct 21 04:13:05 -03 2021

 mri_aparc2aseg --s A00008326 --labelwm --hypo-as-wm --rip-unknown --volmask --o mri/wmparc.mgz --ctxseg aparc+aseg.mgz 


 mri_segstats --seg mri/wmparc.mgz --sum stats/wmparc.stats --pv mri/norm.mgz --excludeid 0 --brainmask mri/brainmask.mgz --in mri/norm.mgz --in-intensity-name norm --in-intensity-units MR --subject A00008326 --surf-wm-vol --ctab /home/brunovieira/freesurfer/WMParcStatsLUT.txt --etiv 

INFO: fsaverage subject does not exist in SUBJECTS_DIR
INFO: Creating symlink to fsaverage subject...

 cd /home/brunovieira/freesurfer/nki_data; ln -s /home/brunovieira/freesurfer/subjects/fsaverage; cd - 

#--------------------------------------------
#@# BA_exvivo Labels lh Thu Oct 21 04:20:51 -03 2021

 mri_label2label --srcsubject fsaverage --srclabel /home/brunovieira/freesurfer/nki_data/fsaverage/label/lh.BA1_exvivo.label --trgsubject A00008326 --trglabel ./lh.BA1_exvivo.label --hemi lh --regmethod surface 


 mri_label2label --srcsubject fsaverage --srclabel /home/brunovieira/freesurfer/nki_data/fsaverage/label/lh.BA2_exvivo.label --trgsubject A00008326 --trglabel ./lh.BA2_exvivo.label --hemi lh --regmethod surface 


 mri_label2label --srcsubject fsaverage --srclabel /home/brunovieira/freesurfer/nki_data/fsaverage/label/lh.BA3a_exvivo.label --trgsubject A00008326 --trglabel ./lh.BA3a_exvivo.label --hemi lh --regmethod surface 


 mri_label2label --srcsubject fsaverage --srclabel /home/brunovieira/freesurfer/nki_data/fsaverage/label/lh.BA3b_exvivo.label --trgsubject A00008326 --trglabel ./lh.BA3b_exvivo.label --hemi lh --regmethod surface 


 mri_label2label --srcsubject fsaverage --srclabel /home/brunovieira/freesurfer/nki_data/fsaverage/label/lh.BA4a_exvivo.label --trgsubject A00008326 --trglabel ./lh.BA4a_exvivo.label --hemi lh --regmethod surface 


 mri_label2label --srcsubject fsaverage --srclabel /home/brunovieira/freesurfer/nki_data/fsaverage/label/lh.BA4p_exvivo.label --trgsubject A00008326 --trglabel ./lh.BA4p_exvivo.label --hemi lh --regmethod surface 


 mri_label2label --srcsubject fsaverage --srclabel /home/brunovieira/freesurfer/nki_data/fsaverage/label/lh.BA6_exvivo.label --trgsubject A00008326 --trglabel ./lh.BA6_exvivo.label --hemi lh --regmethod surface 


 mri_label2label --srcsubject fsaverage --srclabel /home/brunovieira/freesurfer/nki_data/fsaverage/label/lh.BA44_exvivo.label --trgsubject A00008326 --trglabel ./lh.BA44_exvivo.label --hemi lh --regmethod surface 


 mri_label2label --srcsubject fsaverage --srclabel /home/brunovieira/freesurfer/nki_data/fsaverage/label/lh.BA45_exvivo.label --trgsubject A00008326 --trglabel ./lh.BA45_exvivo.label --hemi lh --regmethod surface 


 mri_label2label --srcsubject fsaverage --srclabel /home/brunovieira/freesurfer/nki_data/fsaverage/label/lh.V1_exvivo.label --trgsubject A00008326 --trglabel ./lh.V1_exvivo.label --hemi lh --regmethod surface 


 mri_label2label --srcsubject fsaverage --srclabel /home/brunovieira/freesurfer/nki_data/fsaverage/label/lh.V2_exvivo.label --trgsubject A00008326 --trglabel ./lh.V2_exvivo.label --hemi lh --regmethod surface 


 mri_label2label --srcsubject fsaverage --srclabel /home/brunovieira/freesurfer/nki_data/fsaverage/label/lh.MT_exvivo.label --trgsubject A00008326 --trglabel ./lh.MT_exvivo.label --hemi lh --regmethod surface 


 mri_label2label --srcsubject fsaverage --srclabel /home/brunovieira/freesurfer/nki_data/fsaverage/label/lh.entorhinal_exvivo.label --trgsubject A00008326 --trglabel ./lh.entorhinal_exvivo.label --hemi lh --regmethod surface 


 mri_label2label --srcsubject fsaverage --srclabel /home/brunovieira/freesurfer/nki_data/fsaverage/label/lh.perirhinal_exvivo.label --trgsubject A00008326 --trglabel ./lh.perirhinal_exvivo.label --hemi lh --regmethod surface 


 mri_label2label --srcsubject fsaverage --srclabel /home/brunovieira/freesurfer/nki_data/fsaverage/label/lh.BA1_exvivo.thresh.label --trgsubject A00008326 --trglabel ./lh.BA1_exvivo.thresh.label --hemi lh --regmethod surface 


 mri_label2label --srcsubject fsaverage --srclabel /home/brunovieira/freesurfer/nki_data/fsaverage/label/lh.BA2_exvivo.thresh.label --trgsubject A00008326 --trglabel ./lh.BA2_exvivo.thresh.label --hemi lh --regmethod surface 


 mri_label2label --srcsubject fsaverage --srclabel /home/brunovieira/freesurfer/nki_data/fsaverage/label/lh.BA3a_exvivo.thresh.label --trgsubject A00008326 --trglabel ./lh.BA3a_exvivo.thresh.label --hemi lh --regmethod surface 


 mri_label2label --srcsubject fsaverage --srclabel /home/brunovieira/freesurfer/nki_data/fsaverage/label/lh.BA3b_exvivo.thresh.label --trgsubject A00008326 --trglabel ./lh.BA3b_exvivo.thresh.label --hemi lh --regmethod surface 


 mri_label2label --srcsubject fsaverage --srclabel /home/brunovieira/freesurfer/nki_data/fsaverage/label/lh.BA4a_exvivo.thresh.label --trgsubject A00008326 --trglabel ./lh.BA4a_exvivo.thresh.label --hemi lh --regmethod surface 


 mri_label2label --srcsubject fsaverage --srclabel /home/brunovieira/freesurfer/nki_data/fsaverage/label/lh.BA4p_exvivo.thresh.label --trgsubject A00008326 --trglabel ./lh.BA4p_exvivo.thresh.label --hemi lh --regmethod surface 


 mri_label2label --srcsubject fsaverage --srclabel /home/brunovieira/freesurfer/nki_data/fsaverage/label/lh.BA6_exvivo.thresh.label --trgsubject A00008326 --trglabel ./lh.BA6_exvivo.thresh.label --hemi lh --regmethod surface 


 mri_label2label --srcsubject fsaverage --srclabel /home/brunovieira/freesurfer/nki_data/fsaverage/label/lh.BA44_exvivo.thresh.label --trgsubject A00008326 --trglabel ./lh.BA44_exvivo.thresh.label --hemi lh --regmethod surface 


 mri_label2label --srcsubject fsaverage --srclabel /home/brunovieira/freesurfer/nki_data/fsaverage/label/lh.BA45_exvivo.thresh.label --trgsubject A00008326 --trglabel ./lh.BA45_exvivo.thresh.label --hemi lh --regmethod surface 


 mri_label2label --srcsubject fsaverage --srclabel /home/brunovieira/freesurfer/nki_data/fsaverage/label/lh.V1_exvivo.thresh.label --trgsubject A00008326 --trglabel ./lh.V1_exvivo.thresh.label --hemi lh --regmethod surface 


 mri_label2label --srcsubject fsaverage --srclabel /home/brunovieira/freesurfer/nki_data/fsaverage/label/lh.V2_exvivo.thresh.label --trgsubject A00008326 --trglabel ./lh.V2_exvivo.thresh.label --hemi lh --regmethod surface 


 mri_label2label --srcsubject fsaverage --srclabel /home/brunovieira/freesurfer/nki_data/fsaverage/label/lh.MT_exvivo.thresh.label --trgsubject A00008326 --trglabel ./lh.MT_exvivo.thresh.label --hemi lh --regmethod surface 


 mri_label2label --srcsubject fsaverage --srclabel /home/brunovieira/freesurfer/nki_data/fsaverage/label/lh.entorhinal_exvivo.thresh.label --trgsubject A00008326 --trglabel ./lh.entorhinal_exvivo.thresh.label --hemi lh --regmethod surface 


 mri_label2label --srcsubject fsaverage --srclabel /home/brunovieira/freesurfer/nki_data/fsaverage/label/lh.perirhinal_exvivo.thresh.label --trgsubject A00008326 --trglabel ./lh.perirhinal_exvivo.thresh.label --hemi lh --regmethod surface 


 mris_label2annot --s A00008326 --hemi lh --ctab /home/brunovieira/freesurfer/average/colortable_BA.txt --l lh.BA1_exvivo.label --l lh.BA2_exvivo.label --l lh.BA3a_exvivo.label --l lh.BA3b_exvivo.label --l lh.BA4a_exvivo.label --l lh.BA4p_exvivo.label --l lh.BA6_exvivo.label --l lh.BA44_exvivo.label --l lh.BA45_exvivo.label --l lh.V1_exvivo.label --l lh.V2_exvivo.label --l lh.MT_exvivo.label --l lh.entorhinal_exvivo.label --l lh.perirhinal_exvivo.label --a BA_exvivo --maxstatwinner --noverbose 


 mris_label2annot --s A00008326 --hemi lh --ctab /home/brunovieira/freesurfer/average/colortable_BA.txt --l lh.BA1_exvivo.thresh.label --l lh.BA2_exvivo.thresh.label --l lh.BA3a_exvivo.thresh.label --l lh.BA3b_exvivo.thresh.label --l lh.BA4a_exvivo.thresh.label --l lh.BA4p_exvivo.thresh.label --l lh.BA6_exvivo.thresh.label --l lh.BA44_exvivo.thresh.label --l lh.BA45_exvivo.thresh.label --l lh.V1_exvivo.thresh.label --l lh.V2_exvivo.thresh.label --l lh.MT_exvivo.thresh.label --l lh.entorhinal_exvivo.thresh.label --l lh.perirhinal_exvivo.thresh.label --a BA_exvivo.thresh --maxstatwinner --noverbose 


 mris_anatomical_stats -th3 -mgz -f ../stats/lh.BA_exvivo.stats -b -a ./lh.BA_exvivo.annot -c ./BA_exvivo.ctab A00008326 lh white 


 mris_anatomical_stats -th3 -mgz -f ../stats/lh.BA_exvivo.thresh.stats -b -a ./lh.BA_exvivo.thresh.annot -c ./BA_exvivo.thresh.ctab A00008326 lh white 

#--------------------------------------------
#@# BA_exvivo Labels rh Thu Oct 21 04:24:31 -03 2021

 mri_label2label --srcsubject fsaverage --srclabel /home/brunovieira/freesurfer/nki_data/fsaverage/label/rh.BA1_exvivo.label --trgsubject A00008326 --trglabel ./rh.BA1_exvivo.label --hemi rh --regmethod surface 


 mri_label2label --srcsubject fsaverage --srclabel /home/brunovieira/freesurfer/nki_data/fsaverage/label/rh.BA2_exvivo.label --trgsubject A00008326 --trglabel ./rh.BA2_exvivo.label --hemi rh --regmethod surface 


 mri_label2label --srcsubject fsaverage --srclabel /home/brunovieira/freesurfer/nki_data/fsaverage/label/rh.BA3a_exvivo.label --trgsubject A00008326 --trglabel ./rh.BA3a_exvivo.label --hemi rh --regmethod surface 


 mri_label2label --srcsubject fsaverage --srclabel /home/brunovieira/freesurfer/nki_data/fsaverage/label/rh.BA3b_exvivo.label --trgsubject A00008326 --trglabel ./rh.BA3b_exvivo.label --hemi rh --regmethod surface 


 mri_label2label --srcsubject fsaverage --srclabel /home/brunovieira/freesurfer/nki_data/fsaverage/label/rh.BA4a_exvivo.label --trgsubject A00008326 --trglabel ./rh.BA4a_exvivo.label --hemi rh --regmethod surface 


 mri_label2label --srcsubject fsaverage --srclabel /home/brunovieira/freesurfer/nki_data/fsaverage/label/rh.BA4p_exvivo.label --trgsubject A00008326 --trglabel ./rh.BA4p_exvivo.label --hemi rh --regmethod surface 


 mri_label2label --srcsubject fsaverage --srclabel /home/brunovieira/freesurfer/nki_data/fsaverage/label/rh.BA6_exvivo.label --trgsubject A00008326 --trglabel ./rh.BA6_exvivo.label --hemi rh --regmethod surface 


 mri_label2label --srcsubject fsaverage --srclabel /home/brunovieira/freesurfer/nki_data/fsaverage/label/rh.BA44_exvivo.label --trgsubject A00008326 --trglabel ./rh.BA44_exvivo.label --hemi rh --regmethod surface 


 mri_label2label --srcsubject fsaverage --srclabel /home/brunovieira/freesurfer/nki_data/fsaverage/label/rh.BA45_exvivo.label --trgsubject A00008326 --trglabel ./rh.BA45_exvivo.label --hemi rh --regmethod surface 


 mri_label2label --srcsubject fsaverage --srclabel /home/brunovieira/freesurfer/nki_data/fsaverage/label/rh.V1_exvivo.label --trgsubject A00008326 --trglabel ./rh.V1_exvivo.label --hemi rh --regmethod surface 


 mri_label2label --srcsubject fsaverage --srclabel /home/brunovieira/freesurfer/nki_data/fsaverage/label/rh.V2_exvivo.label --trgsubject A00008326 --trglabel ./rh.V2_exvivo.label --hemi rh --regmethod surface 


 mri_label2label --srcsubject fsaverage --srclabel /home/brunovieira/freesurfer/nki_data/fsaverage/label/rh.MT_exvivo.label --trgsubject A00008326 --trglabel ./rh.MT_exvivo.label --hemi rh --regmethod surface 


 mri_label2label --srcsubject fsaverage --srclabel /home/brunovieira/freesurfer/nki_data/fsaverage/label/rh.entorhinal_exvivo.label --trgsubject A00008326 --trglabel ./rh.entorhinal_exvivo.label --hemi rh --regmethod surface 


 mri_label2label --srcsubject fsaverage --srclabel /home/brunovieira/freesurfer/nki_data/fsaverage/label/rh.perirhinal_exvivo.label --trgsubject A00008326 --trglabel ./rh.perirhinal_exvivo.label --hemi rh --regmethod surface 


 mri_label2label --srcsubject fsaverage --srclabel /home/brunovieira/freesurfer/nki_data/fsaverage/label/rh.BA1_exvivo.thresh.label --trgsubject A00008326 --trglabel ./rh.BA1_exvivo.thresh.label --hemi rh --regmethod surface 


 mri_label2label --srcsubject fsaverage --srclabel /home/brunovieira/freesurfer/nki_data/fsaverage/label/rh.BA2_exvivo.thresh.label --trgsubject A00008326 --trglabel ./rh.BA2_exvivo.thresh.label --hemi rh --regmethod surface 


 mri_label2label --srcsubject fsaverage --srclabel /home/brunovieira/freesurfer/nki_data/fsaverage/label/rh.BA3a_exvivo.thresh.label --trgsubject A00008326 --trglabel ./rh.BA3a_exvivo.thresh.label --hemi rh --regmethod surface 


 mri_label2label --srcsubject fsaverage --srclabel /home/brunovieira/freesurfer/nki_data/fsaverage/label/rh.BA3b_exvivo.thresh.label --trgsubject A00008326 --trglabel ./rh.BA3b_exvivo.thresh.label --hemi rh --regmethod surface 


 mri_label2label --srcsubject fsaverage --srclabel /home/brunovieira/freesurfer/nki_data/fsaverage/label/rh.BA4a_exvivo.thresh.label --trgsubject A00008326 --trglabel ./rh.BA4a_exvivo.thresh.label --hemi rh --regmethod surface 


 mri_label2label --srcsubject fsaverage --srclabel /home/brunovieira/freesurfer/nki_data/fsaverage/label/rh.BA4p_exvivo.thresh.label --trgsubject A00008326 --trglabel ./rh.BA4p_exvivo.thresh.label --hemi rh --regmethod surface 


 mri_label2label --srcsubject fsaverage --srclabel /home/brunovieira/freesurfer/nki_data/fsaverage/label/rh.BA6_exvivo.thresh.label --trgsubject A00008326 --trglabel ./rh.BA6_exvivo.thresh.label --hemi rh --regmethod surface 


 mri_label2label --srcsubject fsaverage --srclabel /home/brunovieira/freesurfer/nki_data/fsaverage/label/rh.BA44_exvivo.thresh.label --trgsubject A00008326 --trglabel ./rh.BA44_exvivo.thresh.label --hemi rh --regmethod surface 


 mri_label2label --srcsubject fsaverage --srclabel /home/brunovieira/freesurfer/nki_data/fsaverage/label/rh.BA45_exvivo.thresh.label --trgsubject A00008326 --trglabel ./rh.BA45_exvivo.thresh.label --hemi rh --regmethod surface 


 mri_label2label --srcsubject fsaverage --srclabel /home/brunovieira/freesurfer/nki_data/fsaverage/label/rh.V1_exvivo.thresh.label --trgsubject A00008326 --trglabel ./rh.V1_exvivo.thresh.label --hemi rh --regmethod surface 


 mri_label2label --srcsubject fsaverage --srclabel /home/brunovieira/freesurfer/nki_data/fsaverage/label/rh.V2_exvivo.thresh.label --trgsubject A00008326 --trglabel ./rh.V2_exvivo.thresh.label --hemi rh --regmethod surface 


 mri_label2label --srcsubject fsaverage --srclabel /home/brunovieira/freesurfer/nki_data/fsaverage/label/rh.MT_exvivo.thresh.label --trgsubject A00008326 --trglabel ./rh.MT_exvivo.thresh.label --hemi rh --regmethod surface 


 mri_label2label --srcsubject fsaverage --srclabel /home/brunovieira/freesurfer/nki_data/fsaverage/label/rh.entorhinal_exvivo.thresh.label --trgsubject A00008326 --trglabel ./rh.entorhinal_exvivo.thresh.label --hemi rh --regmethod surface 


 mri_label2label --srcsubject fsaverage --srclabel /home/brunovieira/freesurfer/nki_data/fsaverage/label/rh.perirhinal_exvivo.thresh.label --trgsubject A00008326 --trglabel ./rh.perirhinal_exvivo.thresh.label --hemi rh --regmethod surface 


 mris_label2annot --s A00008326 --hemi rh --ctab /home/brunovieira/freesurfer/average/colortable_BA.txt --l rh.BA1_exvivo.label --l rh.BA2_exvivo.label --l rh.BA3a_exvivo.label --l rh.BA3b_exvivo.label --l rh.BA4a_exvivo.label --l rh.BA4p_exvivo.label --l rh.BA6_exvivo.label --l rh.BA44_exvivo.label --l rh.BA45_exvivo.label --l rh.V1_exvivo.label --l rh.V2_exvivo.label --l rh.MT_exvivo.label --l rh.entorhinal_exvivo.label --l rh.perirhinal_exvivo.label --a BA_exvivo --maxstatwinner --noverbose 


 mris_label2annot --s A00008326 --hemi rh --ctab /home/brunovieira/freesurfer/average/colortable_BA.txt --l rh.BA1_exvivo.thresh.label --l rh.BA2_exvivo.thresh.label --l rh.BA3a_exvivo.thresh.label --l rh.BA3b_exvivo.thresh.label --l rh.BA4a_exvivo.thresh.label --l rh.BA4p_exvivo.thresh.label --l rh.BA6_exvivo.thresh.label --l rh.BA44_exvivo.thresh.label --l rh.BA45_exvivo.thresh.label --l rh.V1_exvivo.thresh.label --l rh.V2_exvivo.thresh.label --l rh.MT_exvivo.thresh.label --l rh.entorhinal_exvivo.thresh.label --l rh.perirhinal_exvivo.thresh.label --a BA_exvivo.thresh --maxstatwinner --noverbose 


 mris_anatomical_stats -th3 -mgz -f ../stats/rh.BA_exvivo.stats -b -a ./rh.BA_exvivo.annot -c ./BA_exvivo.ctab A00008326 rh white 


 mris_anatomical_stats -th3 -mgz -f ../stats/rh.BA_exvivo.thresh.stats -b -a ./rh.BA_exvivo.thresh.annot -c ./BA_exvivo.thresh.ctab A00008326 rh white 



#---------------------------------
# New invocation of recon-all Mon Oct 25 20:47:18 -03 2021 
#--------------------------------------------
#@# MotionCor Mon Oct 25 20:48:33 -03 2021

 cp /home/brunovieira/freesurfer/nki_data/A00008326/mri/orig/001.mgz /home/brunovieira/freesurfer/nki_data/A00008326/mri/rawavg.mgz 


 mri_convert /home/brunovieira/freesurfer/nki_data/A00008326/mri/rawavg.mgz /home/brunovieira/freesurfer/nki_data/A00008326/mri/orig.mgz --conform 


 mri_add_xform_to_header -c /home/brunovieira/freesurfer/nki_data/A00008326/mri/transforms/talairach.xfm /home/brunovieira/freesurfer/nki_data/A00008326/mri/orig.mgz /home/brunovieira/freesurfer/nki_data/A00008326/mri/orig.mgz 

#--------------------------------------------
#@# Talairach Mon Oct 25 20:49:30 -03 2021

 mri_nu_correct.mni --no-rescale --i orig.mgz --o orig_nu.mgz --n 1 --proto-iters 1000 --distance 50 


 talairach_avi --i orig_nu.mgz --xfm transforms/talairach.auto.xfm 

talairach_avi log file is transforms/talairach_avi.log...

INFO: transforms/talairach.xfm already exists!
The new transforms/talairach.auto.xfm will not be copied to transforms/talairach.xfm
This is done to retain any edits made to transforms/talairach.xfm
Add the -clean-tal flag to recon-all to overwrite transforms/talairach.xfm

#--------------------------------------------
#@# Talairach Failure Detection Mon Oct 25 21:28:08 -03 2021

 talairach_afd -T 0.005 -xfm transforms/talairach.xfm 


 awk -f /home/brunovieira/freesurfer/bin/extract_talairach_avi_QA.awk /home/brunovieira/freesurfer/nki_data/A00008326/mri/transforms/talairach_avi.log 


 tal_QC_AZS /home/brunovieira/freesurfer/nki_data/A00008326/mri/transforms/talairach_avi.log 

#--------------------------------------------
#@# Nu Intensity Correction Mon Oct 25 21:28:28 -03 2021

 mri_nu_correct.mni --i orig.mgz --o nu.mgz --uchar transforms/talairach.xfm --n 2 


 mri_add_xform_to_header -c /home/brunovieira/freesurfer/nki_data/A00008326/mri/transforms/talairach.xfm nu.mgz nu.mgz 

#--------------------------------------------
#@# Intensity Normalization Mon Oct 25 22:35:10 -03 2021

 mri_normalize -g 1 -mprage nu.mgz T1.mgz 

#--------------------------------------------
#@# Skull Stripping Mon Oct 25 22:37:34 -03 2021

 mri_watershed -rusage /home/brunovieira/freesurfer/nki_data/A00008326/touch/rusage.mri_watershed.dat -keep brainmask.auto.mgz brainmask.mgz brainmask.mgz -T1 -brain_atlas /home/brunovieira/freesurfer/average/RB_all_withskull_2016-05-10.vc700.gca transforms/talairach_with_skull.lta T1.mgz brainmask.auto.mgz 


INFO: brainmask.mgz already exists!
The new brainmask.auto.mgz will not be copied to brainmask.mgz.
This is done to retain any edits made to brainmask.mgz.
Add the -clean-bm flag to recon-all to overwrite brainmask.mgz.

#-------------------------------------
#@# EM Registration Mon Oct 25 22:39:51 -03 2021

 mri_em_register -rusage /home/brunovieira/freesurfer/nki_data/A00008326/touch/rusage.mri_em_register.dat -uns 3 -mask brainmask.mgz nu.mgz /home/brunovieira/freesurfer/average/RB_all_2016-05-10.vc700.gca transforms/talairach.lta 

#--------------------------------------
#@# CA Normalize Mon Oct 25 22:53:23 -03 2021

 mri_ca_normalize -c ctrl_pts.mgz -mask brainmask.mgz nu.mgz /home/brunovieira/freesurfer/average/RB_all_2016-05-10.vc700.gca transforms/talairach.lta norm.mgz 

#--------------------------------------
#@# CA Reg Mon Oct 25 22:55:20 -03 2021

 mri_ca_register -rusage /home/brunovieira/freesurfer/nki_data/A00008326/touch/rusage.mri_ca_register.dat -nobigventricles -T transforms/talairach.lta -align-after -mask brainmask.mgz norm.mgz /home/brunovieira/freesurfer/average/RB_all_2016-05-10.vc700.gca transforms/talairach.m3z 

#--------------------------------------
#@# SubCort Seg Tue Oct 26 01:15:21 -03 2021

 mri_seg_diff --seg1 aseg.auto.mgz --seg2 aseg.presurf.mgz --diff aseg.manedit.mgz 


 mri_ca_label -relabel_unlikely 9 .3 -prior 0.5 -align norm.mgz transforms/talairach.m3z /home/brunovieira/freesurfer/average/RB_all_2016-05-10.vc700.gca aseg.auto_noCCseg.mgz 


 mri_cc -aseg aseg.auto_noCCseg.mgz -o aseg.auto.mgz -lta /home/brunovieira/freesurfer/nki_data/A00008326/mri/transforms/cc_up.lta A00008326 

#--------------------------------------
#@# Merge ASeg Tue Oct 26 02:11:40 -03 2021

 cp aseg.auto.mgz aseg.presurf.mgz 

#--------------------------------------------
#@# Intensity Normalization2 Tue Oct 26 02:11:40 -03 2021

 mri_normalize -mprage -aseg aseg.presurf.mgz -mask brainmask.mgz norm.mgz brain.mgz 

#--------------------------------------------
#@# Mask BFS Tue Oct 26 02:15:04 -03 2021

 mri_mask -T 5 brain.mgz brainmask.mgz brain.finalsurfs.mgz 

#--------------------------------------------
#@# WM Segmentation Tue Oct 26 02:15:06 -03 2021

 mri_binarize --i wm.mgz --min 255 --max 255 --o wm255.mgz --count wm255.txt 


 mri_binarize --i wm.mgz --min 1 --max 1 --o wm1.mgz --count wm1.txt 


 rm wm1.mgz wm255.mgz 


 mri_segment -keep -mprage brain.mgz wm.seg.mgz 


 mri_edit_wm_with_aseg -keep-in wm.seg.mgz brain.mgz aseg.presurf.mgz wm.asegedit.mgz 


 mri_pretess -keep wm.asegedit.mgz wm norm.mgz wm.mgz 

#--------------------------------------------
#@# Fill Tue Oct 26 02:17:27 -03 2021

 mri_fill -a ../scripts/ponscc.cut.log -xform transforms/talairach.lta -segmentation aseg.auto_noCCseg.mgz wm.mgz filled.mgz 

#--------------------------------------------
#@# Tessellate lh Tue Oct 26 02:18:08 -03 2021

 mri_pretess ../mri/filled.mgz 255 ../mri/norm.mgz ../mri/filled-pretess255.mgz 


 mri_tessellate ../mri/filled-pretess255.mgz 255 ../surf/lh.orig.nofix 


 rm -f ../mri/filled-pretess255.mgz 


 mris_extract_main_component ../surf/lh.orig.nofix ../surf/lh.orig.nofix 

#--------------------------------------------
#@# Tessellate rh Tue Oct 26 02:18:14 -03 2021

 mri_pretess ../mri/filled.mgz 127 ../mri/norm.mgz ../mri/filled-pretess127.mgz 


 mri_tessellate ../mri/filled-pretess127.mgz 127 ../surf/rh.orig.nofix 


 rm -f ../mri/filled-pretess127.mgz 


 mris_extract_main_component ../surf/rh.orig.nofix ../surf/rh.orig.nofix 

#--------------------------------------------
#@# Smooth1 lh Tue Oct 26 02:18:22 -03 2021

 mris_smooth -nw -seed 1234 ../surf/lh.orig.nofix ../surf/lh.smoothwm.nofix 

#--------------------------------------------
#@# Smooth1 rh Tue Oct 26 02:18:26 -03 2021

 mris_smooth -nw -seed 1234 ../surf/rh.orig.nofix ../surf/rh.smoothwm.nofix 

#--------------------------------------------
#@# Inflation1 lh Tue Oct 26 02:18:30 -03 2021

 mris_inflate -no-save-sulc ../surf/lh.smoothwm.nofix ../surf/lh.inflated.nofix 

#--------------------------------------------
#@# Inflation1 rh Tue Oct 26 02:18:54 -03 2021

 mris_inflate -no-save-sulc ../surf/rh.smoothwm.nofix ../surf/rh.inflated.nofix 

#--------------------------------------------
#@# QSphere lh Tue Oct 26 02:19:21 -03 2021

 mris_sphere -q -seed 1234 ../surf/lh.inflated.nofix ../surf/lh.qsphere.nofix 

#--------------------------------------------
#@# QSphere rh Tue Oct 26 02:21:51 -03 2021

 mris_sphere -q -seed 1234 ../surf/rh.inflated.nofix ../surf/rh.qsphere.nofix 

#--------------------------------------------
#@# Fix Topology Copy lh Tue Oct 26 02:24:47 -03 2021

 cp ../surf/lh.orig.nofix ../surf/lh.orig 


 cp ../surf/lh.inflated.nofix ../surf/lh.inflated 

#--------------------------------------------
#@# Fix Topology Copy rh Tue Oct 26 02:24:48 -03 2021

 cp ../surf/rh.orig.nofix ../surf/rh.orig 


 cp ../surf/rh.inflated.nofix ../surf/rh.inflated 

#@# Fix Topology lh Tue Oct 26 02:24:48 -03 2021

 mris_fix_topology -rusage /home/brunovieira/freesurfer/nki_data/A00008326/touch/rusage.mris_fix_topology.lh.dat -mgz -sphere qsphere.nofix -ga -seed 1234 A00008326 lh 

#@# Fix Topology rh Tue Oct 26 02:39:29 -03 2021

 mris_fix_topology -rusage /home/brunovieira/freesurfer/nki_data/A00008326/touch/rusage.mris_fix_topology.rh.dat -mgz -sphere qsphere.nofix -ga -seed 1234 A00008326 rh 


 mris_euler_number ../surf/lh.orig 


 mris_euler_number ../surf/rh.orig 


 mris_remove_intersection ../surf/lh.orig ../surf/lh.orig 


 rm ../surf/lh.inflated 


 mris_remove_intersection ../surf/rh.orig ../surf/rh.orig 


 rm ../surf/rh.inflated 

#--------------------------------------------
#@# Make White Surf lh Tue Oct 26 02:46:20 -03 2021

 mris_make_surfaces -aseg ../mri/aseg.presurf -white white.preaparc -noaparc -whiteonly -mgz -T1 brain.finalsurfs A00008326 lh 

#--------------------------------------------
#@# Make White Surf rh Tue Oct 26 02:49:40 -03 2021

 mris_make_surfaces -aseg ../mri/aseg.presurf -white white.preaparc -noaparc -whiteonly -mgz -T1 brain.finalsurfs A00008326 rh 

#--------------------------------------------
#@# Smooth2 lh Tue Oct 26 02:52:58 -03 2021

 mris_smooth -n 3 -nw -seed 1234 ../surf/lh.white.preaparc ../surf/lh.smoothwm 

#--------------------------------------------
#@# Smooth2 rh Tue Oct 26 02:53:02 -03 2021

 mris_smooth -n 3 -nw -seed 1234 ../surf/rh.white.preaparc ../surf/rh.smoothwm 

#--------------------------------------------
#@# Inflation2 lh Tue Oct 26 02:53:11 -03 2021

 mris_inflate -rusage /home/brunovieira/freesurfer/nki_data/A00008326/touch/rusage.mris_inflate.lh.dat ../surf/lh.smoothwm ../surf/lh.inflated 

#--------------------------------------------
#@# Inflation2 rh Tue Oct 26 02:53:35 -03 2021

 mris_inflate -rusage /home/brunovieira/freesurfer/nki_data/A00008326/touch/rusage.mris_inflate.rh.dat ../surf/rh.smoothwm ../surf/rh.inflated 

#--------------------------------------------
#@# Curv .H and .K lh Tue Oct 26 02:54:01 -03 2021

 mris_curvature -w lh.white.preaparc 


 mris_curvature -thresh .999 -n -a 5 -w -distances 10 10 lh.inflated 

#--------------------------------------------
#@# Curv .H and .K rh Tue Oct 26 02:55:00 -03 2021

 mris_curvature -w rh.white.preaparc 


 mris_curvature -thresh .999 -n -a 5 -w -distances 10 10 rh.inflated 


#-----------------------------------------
#@# Curvature Stats lh Tue Oct 26 02:55:58 -03 2021

 mris_curvature_stats -m --writeCurvatureFiles -G -o ../stats/lh.curv.stats -F smoothwm A00008326 lh curv sulc 


#-----------------------------------------
#@# Curvature Stats rh Tue Oct 26 02:56:01 -03 2021

 mris_curvature_stats -m --writeCurvatureFiles -G -o ../stats/rh.curv.stats -F smoothwm A00008326 rh curv sulc 

#--------------------------------------------
#@# Sphere lh Tue Oct 26 02:56:04 -03 2021

 mris_sphere -rusage /home/brunovieira/freesurfer/nki_data/A00008326/touch/rusage.mris_sphere.lh.dat -seed 1234 ../surf/lh.inflated ../surf/lh.sphere 

#--------------------------------------------
#@# Sphere rh Tue Oct 26 03:11:32 -03 2021

 mris_sphere -rusage /home/brunovieira/freesurfer/nki_data/A00008326/touch/rusage.mris_sphere.rh.dat -seed 1234 ../surf/rh.inflated ../surf/rh.sphere 

#--------------------------------------------
#@# Surf Reg lh Tue Oct 26 03:27:04 -03 2021

 mris_register -curv -rusage /home/brunovieira/freesurfer/nki_data/A00008326/touch/rusage.mris_register.lh.dat ../surf/lh.sphere /home/brunovieira/freesurfer/average/lh.folding.atlas.acfb40.noaparc.i12.2016-08-02.tif ../surf/lh.sphere.reg 

#--------------------------------------------
#@# Surf Reg rh Tue Oct 26 03:55:08 -03 2021

 mris_register -curv -rusage /home/brunovieira/freesurfer/nki_data/A00008326/touch/rusage.mris_register.rh.dat ../surf/rh.sphere /home/brunovieira/freesurfer/average/rh.folding.atlas.acfb40.noaparc.i12.2016-08-02.tif ../surf/rh.sphere.reg 

#--------------------------------------------
#@# Jacobian white lh Tue Oct 26 04:29:55 -03 2021

 mris_jacobian ../surf/lh.white.preaparc ../surf/lh.sphere.reg ../surf/lh.jacobian_white 

#--------------------------------------------
#@# Jacobian white rh Tue Oct 26 04:29:56 -03 2021

 mris_jacobian ../surf/rh.white.preaparc ../surf/rh.sphere.reg ../surf/rh.jacobian_white 

#--------------------------------------------
#@# AvgCurv lh Tue Oct 26 04:29:58 -03 2021

 mrisp_paint -a 5 /home/brunovieira/freesurfer/average/lh.folding.atlas.acfb40.noaparc.i12.2016-08-02.tif#6 ../surf/lh.sphere.reg ../surf/lh.avg_curv 

#--------------------------------------------
#@# AvgCurv rh Tue Oct 26 04:29:59 -03 2021

 mrisp_paint -a 5 /home/brunovieira/freesurfer/average/rh.folding.atlas.acfb40.noaparc.i12.2016-08-02.tif#6 ../surf/rh.sphere.reg ../surf/rh.avg_curv 

#-----------------------------------------
#@# Cortical Parc lh Tue Oct 26 04:30:00 -03 2021

 mris_ca_label -l ../label/lh.cortex.label -aseg ../mri/aseg.presurf.mgz -seed 1234 A00008326 lh ../surf/lh.sphere.reg /home/brunovieira/freesurfer/average/lh.DKaparc.atlas.acfb40.noaparc.i12.2016-08-02.gcs ../label/lh.aparc.annot 

#-----------------------------------------
#@# Cortical Parc rh Tue Oct 26 04:30:17 -03 2021

 mris_ca_label -l ../label/rh.cortex.label -aseg ../mri/aseg.presurf.mgz -seed 1234 A00008326 rh ../surf/rh.sphere.reg /home/brunovieira/freesurfer/average/rh.DKaparc.atlas.acfb40.noaparc.i12.2016-08-02.gcs ../label/rh.aparc.annot 

#--------------------------------------------
#@# Make Pial Surf lh Tue Oct 26 04:30:27 -03 2021

 mris_make_surfaces -orig_white white.preaparc -orig_pial white.preaparc -aseg ../mri/aseg.presurf -mgz -T1 brain.finalsurfs A00008326 lh 

#--------------------------------------------
#@# Make Pial Surf rh Tue Oct 26 04:40:05 -03 2021

 mris_make_surfaces -orig_white white.preaparc -orig_pial white.preaparc -aseg ../mri/aseg.presurf -mgz -T1 brain.finalsurfs A00008326 rh 

#--------------------------------------------
#@# Surf Volume lh Tue Oct 26 04:49:41 -03 2021
#--------------------------------------------
#@# Surf Volume rh Tue Oct 26 04:49:48 -03 2021
#--------------------------------------------
#@# Cortical ribbon mask Tue Oct 26 04:49:50 -03 2021

 mris_volmask --aseg_name aseg.presurf --label_left_white 2 --label_left_ribbon 3 --label_right_white 41 --label_right_ribbon 42 --save_ribbon A00008326 

#-----------------------------------------
#@# Parcellation Stats lh Tue Oct 26 04:57:45 -03 2021

 mris_anatomical_stats -th3 -mgz -cortex ../label/lh.cortex.label -f ../stats/lh.aparc.stats -b -a ../label/lh.aparc.annot -c ../label/aparc.annot.ctab A00008326 lh white 


 mris_anatomical_stats -th3 -mgz -cortex ../label/lh.cortex.label -f ../stats/lh.aparc.pial.stats -b -a ../label/lh.aparc.annot -c ../label/aparc.annot.ctab A00008326 lh pial 

#-----------------------------------------
#@# Parcellation Stats rh Tue Oct 26 04:58:46 -03 2021

 mris_anatomical_stats -th3 -mgz -cortex ../label/rh.cortex.label -f ../stats/rh.aparc.stats -b -a ../label/rh.aparc.annot -c ../label/aparc.annot.ctab A00008326 rh white 


 mris_anatomical_stats -th3 -mgz -cortex ../label/rh.cortex.label -f ../stats/rh.aparc.pial.stats -b -a ../label/rh.aparc.annot -c ../label/aparc.annot.ctab A00008326 rh pial 

#-----------------------------------------
#@# Cortical Parc 2 lh Tue Oct 26 04:59:45 -03 2021

 mris_ca_label -l ../label/lh.cortex.label -aseg ../mri/aseg.presurf.mgz -seed 1234 A00008326 lh ../surf/lh.sphere.reg /home/brunovieira/freesurfer/average/lh.CDaparc.atlas.acfb40.noaparc.i12.2016-08-02.gcs ../label/lh.aparc.a2009s.annot 

#-----------------------------------------
#@# Cortical Parc 2 rh Tue Oct 26 04:59:58 -03 2021

 mris_ca_label -l ../label/rh.cortex.label -aseg ../mri/aseg.presurf.mgz -seed 1234 A00008326 rh ../surf/rh.sphere.reg /home/brunovieira/freesurfer/average/rh.CDaparc.atlas.acfb40.noaparc.i12.2016-08-02.gcs ../label/rh.aparc.a2009s.annot 

#-----------------------------------------
#@# Parcellation Stats 2 lh Tue Oct 26 05:00:15 -03 2021

 mris_anatomical_stats -th3 -mgz -cortex ../label/lh.cortex.label -f ../stats/lh.aparc.a2009s.stats -b -a ../label/lh.aparc.a2009s.annot -c ../label/aparc.annot.a2009s.ctab A00008326 lh white 

#-----------------------------------------
#@# Parcellation Stats 2 rh Tue Oct 26 05:00:46 -03 2021

 mris_anatomical_stats -th3 -mgz -cortex ../label/rh.cortex.label -f ../stats/rh.aparc.a2009s.stats -b -a ../label/rh.aparc.a2009s.annot -c ../label/aparc.annot.a2009s.ctab A00008326 rh white 

#-----------------------------------------
#@# Cortical Parc 3 lh Tue Oct 26 05:01:17 -03 2021

 mris_ca_label -l ../label/lh.cortex.label -aseg ../mri/aseg.presurf.mgz -seed 1234 A00008326 lh ../surf/lh.sphere.reg /home/brunovieira/freesurfer/average/lh.DKTaparc.atlas.acfb40.noaparc.i12.2016-08-02.gcs ../label/lh.aparc.DKTatlas.annot 

#-----------------------------------------
#@# Cortical Parc 3 rh Tue Oct 26 05:01:31 -03 2021

 mris_ca_label -l ../label/rh.cortex.label -aseg ../mri/aseg.presurf.mgz -seed 1234 A00008326 rh ../surf/rh.sphere.reg /home/brunovieira/freesurfer/average/rh.DKTaparc.atlas.acfb40.noaparc.i12.2016-08-02.gcs ../label/rh.aparc.DKTatlas.annot 

#-----------------------------------------
#@# Parcellation Stats 3 lh Tue Oct 26 05:01:42 -03 2021

 mris_anatomical_stats -th3 -mgz -cortex ../label/lh.cortex.label -f ../stats/lh.aparc.DKTatlas.stats -b -a ../label/lh.aparc.DKTatlas.annot -c ../label/aparc.annot.DKTatlas.ctab A00008326 lh white 

#-----------------------------------------
#@# Parcellation Stats 3 rh Tue Oct 26 05:02:11 -03 2021

 mris_anatomical_stats -th3 -mgz -cortex ../label/rh.cortex.label -f ../stats/rh.aparc.DKTatlas.stats -b -a ../label/rh.aparc.DKTatlas.annot -c ../label/aparc.annot.DKTatlas.ctab A00008326 rh white 

#-----------------------------------------
#@# WM/GM Contrast lh Tue Oct 26 05:02:39 -03 2021

 pctsurfcon --s A00008326 --lh-only 

#-----------------------------------------
#@# WM/GM Contrast rh Tue Oct 26 05:02:44 -03 2021

 pctsurfcon --s A00008326 --rh-only 

#-----------------------------------------
#@# Relabel Hypointensities Tue Oct 26 05:02:52 -03 2021

 mri_relabel_hypointensities aseg.presurf.mgz ../surf aseg.presurf.hypos.mgz 

#-----------------------------------------
#@# AParc-to-ASeg aparc Tue Oct 26 05:03:10 -03 2021

 mri_aparc2aseg --s A00008326 --volmask --aseg aseg.presurf.hypos --relabel mri/norm.mgz mri/transforms/talairach.m3z /home/brunovieira/freesurfer/average/RB_all_2016-05-10.vc700.gca mri/aseg.auto_noCCseg.label_intensities.txt 

#-----------------------------------------
#@# AParc-to-ASeg a2009s Tue Oct 26 05:07:15 -03 2021

 mri_aparc2aseg --s A00008326 --volmask --aseg aseg.presurf.hypos --relabel mri/norm.mgz mri/transforms/talairach.m3z /home/brunovieira/freesurfer/average/RB_all_2016-05-10.vc700.gca mri/aseg.auto_noCCseg.label_intensities.txt --a2009s 

#-----------------------------------------
#@# AParc-to-ASeg DKTatlas Tue Oct 26 05:11:21 -03 2021

 mri_aparc2aseg --s A00008326 --volmask --aseg aseg.presurf.hypos --relabel mri/norm.mgz mri/transforms/talairach.m3z /home/brunovieira/freesurfer/average/RB_all_2016-05-10.vc700.gca mri/aseg.auto_noCCseg.label_intensities.txt --annot aparc.DKTatlas --o mri/aparc.DKTatlas+aseg.mgz 

#-----------------------------------------
#@# APas-to-ASeg Tue Oct 26 05:15:17 -03 2021

 apas2aseg --i aparc+aseg.mgz --o aseg.mgz 

#--------------------------------------------
#@# ASeg Stats Tue Oct 26 05:15:29 -03 2021

 mri_segstats --seg mri/aseg.mgz --sum stats/aseg.stats --pv mri/norm.mgz --empty --brainmask mri/brainmask.mgz --brain-vol-from-seg --excludeid 0 --excl-ctxgmwm --supratent --subcortgray --in mri/norm.mgz --in-intensity-name norm --in-intensity-units MR --etiv --surf-wm-vol --surf-ctx-vol --totalgray --euler --ctab /home/brunovieira/freesurfer/ASegStatsLUT.txt --subject A00008326 

#-----------------------------------------
#@# WMParc Tue Oct 26 05:19:16 -03 2021

 mri_aparc2aseg --s A00008326 --labelwm --hypo-as-wm --rip-unknown --volmask --o mri/wmparc.mgz --ctxseg aparc+aseg.mgz 


 mri_segstats --seg mri/wmparc.mgz --sum stats/wmparc.stats --pv mri/norm.mgz --excludeid 0 --brainmask mri/brainmask.mgz --in mri/norm.mgz --in-intensity-name norm --in-intensity-units MR --subject A00008326 --surf-wm-vol --ctab /home/brunovieira/freesurfer/WMParcStatsLUT.txt --etiv 

#--------------------------------------------
#@# BA_exvivo Labels lh Tue Oct 26 05:27:55 -03 2021

 mri_label2label --srcsubject fsaverage --srclabel /home/brunovieira/freesurfer/nki_data/fsaverage/label/lh.BA1_exvivo.label --trgsubject A00008326 --trglabel ./lh.BA1_exvivo.label --hemi lh --regmethod surface 


 mri_label2label --srcsubject fsaverage --srclabel /home/brunovieira/freesurfer/nki_data/fsaverage/label/lh.BA2_exvivo.label --trgsubject A00008326 --trglabel ./lh.BA2_exvivo.label --hemi lh --regmethod surface 


 mri_label2label --srcsubject fsaverage --srclabel /home/brunovieira/freesurfer/nki_data/fsaverage/label/lh.BA3a_exvivo.label --trgsubject A00008326 --trglabel ./lh.BA3a_exvivo.label --hemi lh --regmethod surface 


 mri_label2label --srcsubject fsaverage --srclabel /home/brunovieira/freesurfer/nki_data/fsaverage/label/lh.BA3b_exvivo.label --trgsubject A00008326 --trglabel ./lh.BA3b_exvivo.label --hemi lh --regmethod surface 


 mri_label2label --srcsubject fsaverage --srclabel /home/brunovieira/freesurfer/nki_data/fsaverage/label/lh.BA4a_exvivo.label --trgsubject A00008326 --trglabel ./lh.BA4a_exvivo.label --hemi lh --regmethod surface 


 mri_label2label --srcsubject fsaverage --srclabel /home/brunovieira/freesurfer/nki_data/fsaverage/label/lh.BA4p_exvivo.label --trgsubject A00008326 --trglabel ./lh.BA4p_exvivo.label --hemi lh --regmethod surface 


 mri_label2label --srcsubject fsaverage --srclabel /home/brunovieira/freesurfer/nki_data/fsaverage/label/lh.BA6_exvivo.label --trgsubject A00008326 --trglabel ./lh.BA6_exvivo.label --hemi lh --regmethod surface 


 mri_label2label --srcsubject fsaverage --srclabel /home/brunovieira/freesurfer/nki_data/fsaverage/label/lh.BA44_exvivo.label --trgsubject A00008326 --trglabel ./lh.BA44_exvivo.label --hemi lh --regmethod surface 


 mri_label2label --srcsubject fsaverage --srclabel /home/brunovieira/freesurfer/nki_data/fsaverage/label/lh.BA45_exvivo.label --trgsubject A00008326 --trglabel ./lh.BA45_exvivo.label --hemi lh --regmethod surface 


 mri_label2label --srcsubject fsaverage --srclabel /home/brunovieira/freesurfer/nki_data/fsaverage/label/lh.V1_exvivo.label --trgsubject A00008326 --trglabel ./lh.V1_exvivo.label --hemi lh --regmethod surface 


 mri_label2label --srcsubject fsaverage --srclabel /home/brunovieira/freesurfer/nki_data/fsaverage/label/lh.V2_exvivo.label --trgsubject A00008326 --trglabel ./lh.V2_exvivo.label --hemi lh --regmethod surface 


 mri_label2label --srcsubject fsaverage --srclabel /home/brunovieira/freesurfer/nki_data/fsaverage/label/lh.MT_exvivo.label --trgsubject A00008326 --trglabel ./lh.MT_exvivo.label --hemi lh --regmethod surface 


 mri_label2label --srcsubject fsaverage --srclabel /home/brunovieira/freesurfer/nki_data/fsaverage/label/lh.entorhinal_exvivo.label --trgsubject A00008326 --trglabel ./lh.entorhinal_exvivo.label --hemi lh --regmethod surface 


 mri_label2label --srcsubject fsaverage --srclabel /home/brunovieira/freesurfer/nki_data/fsaverage/label/lh.perirhinal_exvivo.label --trgsubject A00008326 --trglabel ./lh.perirhinal_exvivo.label --hemi lh --regmethod surface 


 mri_label2label --srcsubject fsaverage --srclabel /home/brunovieira/freesurfer/nki_data/fsaverage/label/lh.BA1_exvivo.thresh.label --trgsubject A00008326 --trglabel ./lh.BA1_exvivo.thresh.label --hemi lh --regmethod surface 


 mri_label2label --srcsubject fsaverage --srclabel /home/brunovieira/freesurfer/nki_data/fsaverage/label/lh.BA2_exvivo.thresh.label --trgsubject A00008326 --trglabel ./lh.BA2_exvivo.thresh.label --hemi lh --regmethod surface 


 mri_label2label --srcsubject fsaverage --srclabel /home/brunovieira/freesurfer/nki_data/fsaverage/label/lh.BA3a_exvivo.thresh.label --trgsubject A00008326 --trglabel ./lh.BA3a_exvivo.thresh.label --hemi lh --regmethod surface 


 mri_label2label --srcsubject fsaverage --srclabel /home/brunovieira/freesurfer/nki_data/fsaverage/label/lh.BA3b_exvivo.thresh.label --trgsubject A00008326 --trglabel ./lh.BA3b_exvivo.thresh.label --hemi lh --regmethod surface 


 mri_label2label --srcsubject fsaverage --srclabel /home/brunovieira/freesurfer/nki_data/fsaverage/label/lh.BA4a_exvivo.thresh.label --trgsubject A00008326 --trglabel ./lh.BA4a_exvivo.thresh.label --hemi lh --regmethod surface 


 mri_label2label --srcsubject fsaverage --srclabel /home/brunovieira/freesurfer/nki_data/fsaverage/label/lh.BA4p_exvivo.thresh.label --trgsubject A00008326 --trglabel ./lh.BA4p_exvivo.thresh.label --hemi lh --regmethod surface 


 mri_label2label --srcsubject fsaverage --srclabel /home/brunovieira/freesurfer/nki_data/fsaverage/label/lh.BA6_exvivo.thresh.label --trgsubject A00008326 --trglabel ./lh.BA6_exvivo.thresh.label --hemi lh --regmethod surface 


 mri_label2label --srcsubject fsaverage --srclabel /home/brunovieira/freesurfer/nki_data/fsaverage/label/lh.BA44_exvivo.thresh.label --trgsubject A00008326 --trglabel ./lh.BA44_exvivo.thresh.label --hemi lh --regmethod surface 


 mri_label2label --srcsubject fsaverage --srclabel /home/brunovieira/freesurfer/nki_data/fsaverage/label/lh.BA45_exvivo.thresh.label --trgsubject A00008326 --trglabel ./lh.BA45_exvivo.thresh.label --hemi lh --regmethod surface 


 mri_label2label --srcsubject fsaverage --srclabel /home/brunovieira/freesurfer/nki_data/fsaverage/label/lh.V1_exvivo.thresh.label --trgsubject A00008326 --trglabel ./lh.V1_exvivo.thresh.label --hemi lh --regmethod surface 


 mri_label2label --srcsubject fsaverage --srclabel /home/brunovieira/freesurfer/nki_data/fsaverage/label/lh.V2_exvivo.thresh.label --trgsubject A00008326 --trglabel ./lh.V2_exvivo.thresh.label --hemi lh --regmethod surface 


 mri_label2label --srcsubject fsaverage --srclabel /home/brunovieira/freesurfer/nki_data/fsaverage/label/lh.MT_exvivo.thresh.label --trgsubject A00008326 --trglabel ./lh.MT_exvivo.thresh.label --hemi lh --regmethod surface 


 mri_label2label --srcsubject fsaverage --srclabel /home/brunovieira/freesurfer/nki_data/fsaverage/label/lh.entorhinal_exvivo.thresh.label --trgsubject A00008326 --trglabel ./lh.entorhinal_exvivo.thresh.label --hemi lh --regmethod surface 


 mri_label2label --srcsubject fsaverage --srclabel /home/brunovieira/freesurfer/nki_data/fsaverage/label/lh.perirhinal_exvivo.thresh.label --trgsubject A00008326 --trglabel ./lh.perirhinal_exvivo.thresh.label --hemi lh --regmethod surface 


 mris_label2annot --s A00008326 --hemi lh --ctab /home/brunovieira/freesurfer/average/colortable_BA.txt --l lh.BA1_exvivo.label --l lh.BA2_exvivo.label --l lh.BA3a_exvivo.label --l lh.BA3b_exvivo.label --l lh.BA4a_exvivo.label --l lh.BA4p_exvivo.label --l lh.BA6_exvivo.label --l lh.BA44_exvivo.label --l lh.BA45_exvivo.label --l lh.V1_exvivo.label --l lh.V2_exvivo.label --l lh.MT_exvivo.label --l lh.entorhinal_exvivo.label --l lh.perirhinal_exvivo.label --a BA_exvivo --maxstatwinner --noverbose 


 mris_label2annot --s A00008326 --hemi lh --ctab /home/brunovieira/freesurfer/average/colortable_BA.txt --l lh.BA1_exvivo.thresh.label --l lh.BA2_exvivo.thresh.label --l lh.BA3a_exvivo.thresh.label --l lh.BA3b_exvivo.thresh.label --l lh.BA4a_exvivo.thresh.label --l lh.BA4p_exvivo.thresh.label --l lh.BA6_exvivo.thresh.label --l lh.BA44_exvivo.thresh.label --l lh.BA45_exvivo.thresh.label --l lh.V1_exvivo.thresh.label --l lh.V2_exvivo.thresh.label --l lh.MT_exvivo.thresh.label --l lh.entorhinal_exvivo.thresh.label --l lh.perirhinal_exvivo.thresh.label --a BA_exvivo.thresh --maxstatwinner --noverbose 


 mris_anatomical_stats -th3 -mgz -f ../stats/lh.BA_exvivo.stats -b -a ./lh.BA_exvivo.annot -c ./BA_exvivo.ctab A00008326 lh white 


 mris_anatomical_stats -th3 -mgz -f ../stats/lh.BA_exvivo.thresh.stats -b -a ./lh.BA_exvivo.thresh.annot -c ./BA_exvivo.thresh.ctab A00008326 lh white 

#--------------------------------------------
#@# BA_exvivo Labels rh Tue Oct 26 05:31:46 -03 2021

 mri_label2label --srcsubject fsaverage --srclabel /home/brunovieira/freesurfer/nki_data/fsaverage/label/rh.BA1_exvivo.label --trgsubject A00008326 --trglabel ./rh.BA1_exvivo.label --hemi rh --regmethod surface 


 mri_label2label --srcsubject fsaverage --srclabel /home/brunovieira/freesurfer/nki_data/fsaverage/label/rh.BA2_exvivo.label --trgsubject A00008326 --trglabel ./rh.BA2_exvivo.label --hemi rh --regmethod surface 


 mri_label2label --srcsubject fsaverage --srclabel /home/brunovieira/freesurfer/nki_data/fsaverage/label/rh.BA3a_exvivo.label --trgsubject A00008326 --trglabel ./rh.BA3a_exvivo.label --hemi rh --regmethod surface 


 mri_label2label --srcsubject fsaverage --srclabel /home/brunovieira/freesurfer/nki_data/fsaverage/label/rh.BA3b_exvivo.label --trgsubject A00008326 --trglabel ./rh.BA3b_exvivo.label --hemi rh --regmethod surface 


 mri_label2label --srcsubject fsaverage --srclabel /home/brunovieira/freesurfer/nki_data/fsaverage/label/rh.BA4a_exvivo.label --trgsubject A00008326 --trglabel ./rh.BA4a_exvivo.label --hemi rh --regmethod surface 


 mri_label2label --srcsubject fsaverage --srclabel /home/brunovieira/freesurfer/nki_data/fsaverage/label/rh.BA4p_exvivo.label --trgsubject A00008326 --trglabel ./rh.BA4p_exvivo.label --hemi rh --regmethod surface 


 mri_label2label --srcsubject fsaverage --srclabel /home/brunovieira/freesurfer/nki_data/fsaverage/label/rh.BA6_exvivo.label --trgsubject A00008326 --trglabel ./rh.BA6_exvivo.label --hemi rh --regmethod surface 


 mri_label2label --srcsubject fsaverage --srclabel /home/brunovieira/freesurfer/nki_data/fsaverage/label/rh.BA44_exvivo.label --trgsubject A00008326 --trglabel ./rh.BA44_exvivo.label --hemi rh --regmethod surface 


 mri_label2label --srcsubject fsaverage --srclabel /home/brunovieira/freesurfer/nki_data/fsaverage/label/rh.BA45_exvivo.label --trgsubject A00008326 --trglabel ./rh.BA45_exvivo.label --hemi rh --regmethod surface 


 mri_label2label --srcsubject fsaverage --srclabel /home/brunovieira/freesurfer/nki_data/fsaverage/label/rh.V1_exvivo.label --trgsubject A00008326 --trglabel ./rh.V1_exvivo.label --hemi rh --regmethod surface 


 mri_label2label --srcsubject fsaverage --srclabel /home/brunovieira/freesurfer/nki_data/fsaverage/label/rh.V2_exvivo.label --trgsubject A00008326 --trglabel ./rh.V2_exvivo.label --hemi rh --regmethod surface 


 mri_label2label --srcsubject fsaverage --srclabel /home/brunovieira/freesurfer/nki_data/fsaverage/label/rh.MT_exvivo.label --trgsubject A00008326 --trglabel ./rh.MT_exvivo.label --hemi rh --regmethod surface 


 mri_label2label --srcsubject fsaverage --srclabel /home/brunovieira/freesurfer/nki_data/fsaverage/label/rh.entorhinal_exvivo.label --trgsubject A00008326 --trglabel ./rh.entorhinal_exvivo.label --hemi rh --regmethod surface 


 mri_label2label --srcsubject fsaverage --srclabel /home/brunovieira/freesurfer/nki_data/fsaverage/label/rh.perirhinal_exvivo.label --trgsubject A00008326 --trglabel ./rh.perirhinal_exvivo.label --hemi rh --regmethod surface 


 mri_label2label --srcsubject fsaverage --srclabel /home/brunovieira/freesurfer/nki_data/fsaverage/label/rh.BA1_exvivo.thresh.label --trgsubject A00008326 --trglabel ./rh.BA1_exvivo.thresh.label --hemi rh --regmethod surface 


 mri_label2label --srcsubject fsaverage --srclabel /home/brunovieira/freesurfer/nki_data/fsaverage/label/rh.BA2_exvivo.thresh.label --trgsubject A00008326 --trglabel ./rh.BA2_exvivo.thresh.label --hemi rh --regmethod surface 


 mri_label2label --srcsubject fsaverage --srclabel /home/brunovieira/freesurfer/nki_data/fsaverage/label/rh.BA3a_exvivo.thresh.label --trgsubject A00008326 --trglabel ./rh.BA3a_exvivo.thresh.label --hemi rh --regmethod surface 


 mri_label2label --srcsubject fsaverage --srclabel /home/brunovieira/freesurfer/nki_data/fsaverage/label/rh.BA3b_exvivo.thresh.label --trgsubject A00008326 --trglabel ./rh.BA3b_exvivo.thresh.label --hemi rh --regmethod surface 


 mri_label2label --srcsubject fsaverage --srclabel /home/brunovieira/freesurfer/nki_data/fsaverage/label/rh.BA4a_exvivo.thresh.label --trgsubject A00008326 --trglabel ./rh.BA4a_exvivo.thresh.label --hemi rh --regmethod surface 


 mri_label2label --srcsubject fsaverage --srclabel /home/brunovieira/freesurfer/nki_data/fsaverage/label/rh.BA4p_exvivo.thresh.label --trgsubject A00008326 --trglabel ./rh.BA4p_exvivo.thresh.label --hemi rh --regmethod surface 


 mri_label2label --srcsubject fsaverage --srclabel /home/brunovieira/freesurfer/nki_data/fsaverage/label/rh.BA6_exvivo.thresh.label --trgsubject A00008326 --trglabel ./rh.BA6_exvivo.thresh.label --hemi rh --regmethod surface 


 mri_label2label --srcsubject fsaverage --srclabel /home/brunovieira/freesurfer/nki_data/fsaverage/label/rh.BA44_exvivo.thresh.label --trgsubject A00008326 --trglabel ./rh.BA44_exvivo.thresh.label --hemi rh --regmethod surface 


 mri_label2label --srcsubject fsaverage --srclabel /home/brunovieira/freesurfer/nki_data/fsaverage/label/rh.BA45_exvivo.thresh.label --trgsubject A00008326 --trglabel ./rh.BA45_exvivo.thresh.label --hemi rh --regmethod surface 


 mri_label2label --srcsubject fsaverage --srclabel /home/brunovieira/freesurfer/nki_data/fsaverage/label/rh.V1_exvivo.thresh.label --trgsubject A00008326 --trglabel ./rh.V1_exvivo.thresh.label --hemi rh --regmethod surface 


 mri_label2label --srcsubject fsaverage --srclabel /home/brunovieira/freesurfer/nki_data/fsaverage/label/rh.V2_exvivo.thresh.label --trgsubject A00008326 --trglabel ./rh.V2_exvivo.thresh.label --hemi rh --regmethod surface 


 mri_label2label --srcsubject fsaverage --srclabel /home/brunovieira/freesurfer/nki_data/fsaverage/label/rh.MT_exvivo.thresh.label --trgsubject A00008326 --trglabel ./rh.MT_exvivo.thresh.label --hemi rh --regmethod surface 


 mri_label2label --srcsubject fsaverage --srclabel /home/brunovieira/freesurfer/nki_data/fsaverage/label/rh.entorhinal_exvivo.thresh.label --trgsubject A00008326 --trglabel ./rh.entorhinal_exvivo.thresh.label --hemi rh --regmethod surface 


 mri_label2label --srcsubject fsaverage --srclabel /home/brunovieira/freesurfer/nki_data/fsaverage/label/rh.perirhinal_exvivo.thresh.label --trgsubject A00008326 --trglabel ./rh.perirhinal_exvivo.thresh.label --hemi rh --regmethod surface 


 mris_label2annot --s A00008326 --hemi rh --ctab /home/brunovieira/freesurfer/average/colortable_BA.txt --l rh.BA1_exvivo.label --l rh.BA2_exvivo.label --l rh.BA3a_exvivo.label --l rh.BA3b_exvivo.label --l rh.BA4a_exvivo.label --l rh.BA4p_exvivo.label --l rh.BA6_exvivo.label --l rh.BA44_exvivo.label --l rh.BA45_exvivo.label --l rh.V1_exvivo.label --l rh.V2_exvivo.label --l rh.MT_exvivo.label --l rh.entorhinal_exvivo.label --l rh.perirhinal_exvivo.label --a BA_exvivo --maxstatwinner --noverbose 


 mris_label2annot --s A00008326 --hemi rh --ctab /home/brunovieira/freesurfer/average/colortable_BA.txt --l rh.BA1_exvivo.thresh.label --l rh.BA2_exvivo.thresh.label --l rh.BA3a_exvivo.thresh.label --l rh.BA3b_exvivo.thresh.label --l rh.BA4a_exvivo.thresh.label --l rh.BA4p_exvivo.thresh.label --l rh.BA6_exvivo.thresh.label --l rh.BA44_exvivo.thresh.label --l rh.BA45_exvivo.thresh.label --l rh.V1_exvivo.thresh.label --l rh.V2_exvivo.thresh.label --l rh.MT_exvivo.thresh.label --l rh.entorhinal_exvivo.thresh.label --l rh.perirhinal_exvivo.thresh.label --a BA_exvivo.thresh --maxstatwinner --noverbose 


 mris_anatomical_stats -th3 -mgz -f ../stats/rh.BA_exvivo.stats -b -a ./rh.BA_exvivo.annot -c ./BA_exvivo.ctab A00008326 rh white 


 mris_anatomical_stats -th3 -mgz -f ../stats/rh.BA_exvivo.thresh.stats -b -a ./rh.BA_exvivo.thresh.annot -c ./BA_exvivo.thresh.ctab A00008326 rh white 

