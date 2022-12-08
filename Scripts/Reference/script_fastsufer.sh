# Define data directory
subjectsdir=/srv/nkienhanced
datadir=/home/tamirescorrea/my_mri_data
fastsurferdir=/home/tamirescorrea/my_fastsurfer_analysis
template_file=/usr/local/freesurfer/average/lh.average.curvature.filled.buckner40.tif 
touch processed_subjects.txt 

echo $1
#for subject_file in nkienhanced.txt[:3]
sed -n '1,$1 p' nkienhanced.txt | while read line
do
    #Creating Directory
    subject_file=$line
    subject="${subject_file:6:9}"
    echo "===================== Processing subject: $subject =====================" 
    while read processed
    do
        if [ $subject == $processed ]
        then
            echo "Subject already have been processed" 
            continue 2
        fi
    done < processed_subjects.txt

    echo $subject >> processed_subjects.txt
    mkdir -p $datadir/$subject
    echo "============= Initianting nii conversion to mgz ============="
    # Convert
    mri_convert \
        --in_type nii \
        --out_type mgz \
        $subjectsdir/$subject_file \
        $datadir/$subject/001.mgz

    # Run FastSufer
    /usr/local/FastSurfer/run_fastsurfer.sh \
        --t1 $datadir/$subject/001.mgz \
        --sid $subject \
        --sd $fastsurferdir \
        --parallel \
        --threads 4

    for h in rh lh
    do
        # define hemisphere
        hemisphere=$h

        # Add Atlas - sphere
        mris_sphere \
            $fastsurferdir/$subject/surf/$hemisphere.inflated \
            $fastsurferdir/$subject/surf/$hemisphere.sphere 

        # Add Atlas - sphere.reg 
        mris_register \
            $fastsurferdir/$subject/surf/$hemisphere.sphere \
            $template_file \
            $fastsurferdir/$subject/surf/$hemisphere.sphere.reg 

        # Add Atlas - sphere.annot
        mris_ca_label \
            -sdir $fastsurferdir/ \
            $subject \
            $hemisphere \
            sphere.reg \
            /home/tamirescorrea/AtlasCollection/Economo/$hemisphere.atlas.gcs \
            $fastsurferdir/$subject/label/$hemisphere.Eco.annot 
    done
    sleep 90s
done

