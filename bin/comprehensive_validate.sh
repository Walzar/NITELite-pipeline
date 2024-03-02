echo 'Performing comprehensive validation...'
echo

echo 'Can we see the input and output buckets (referenced_images, nitelite_pipeline_output) from inside the ec2 instance?'
ls /data/
echo

echo 'Can we see the input and output buckets from inside the docker container inside the ec2 instance?'
docker compose -f ./aws/docker-compose.yaml \
    run nitelite-pipeline \
    /bin/bash -c \
    'ls /data/'
echo

echo 'Can we create, see, and delete files inside the output bucket?'
echo 'Writing files to output bucket...'
touch /data/nitelite_pipeline_output/test.txt; touch /data/nitelite_pipeline_output/test2.txt
echo 'Files in output bucket:'
ls /data/nitelite_pipeline_output/
echo 'Removing files from output bucket...'
rm /data/nitelite_pipeline_output/test.txt; rm /data/nitelite_pipeline_output/test2.txt
ls /data/nitelite_pipeline_output/
echo

echo 'Can we see the config file from inside the docker container inside the ec2 instance?'
docker compose -f ./aws/docker-compose.yaml \
    run \
    --volume $(realpath ./config/mosaic.yml):/used_config.yml \
    nitelite-pipeline \
    /bin/bash -c \
    'ls /*.yml'
echo

echo 'Does the conda environment inside the docker container work?'
docker compose -f ./aws/docker-compose.yaml \
    run nitelite-pipeline \
    /bin/bash -c \
    'conda run -n nitelite-pipeline-conda python -c \
    "import sys; \
print(f\"Found sys.executable at {sys.executable}!\");"'
echo

echo 'Can we see the input and output buckets from inside the conda environment inside the docker container inside the ec2 instance?'
docker compose -f ./aws/docker-compose.yaml \
    run nitelite-pipeline \
    /bin/bash -c \
    'conda run -n nitelite-pipeline-conda ls /data/'
echo

echo 'Can we create, see, and delete files inside the output bucket using Python?'
docker compose -f ./aws/docker-compose.yaml \
    run \
    --volume $(realpath ./bin/validate_filesystem.py):/validate_filesystem.py \
    nitelite-pipeline \
    /bin/bash -c \
    'conda run -n nitelite-pipeline-conda --live-stream \
    python /validate_filesystem.py'
echo

echo 'Is the code inside the docker container what we expect?'
docker compose -f ./aws/docker-compose.yaml \
    run nitelite-pipeline \
    /bin/bash -c \
    'pwd; echo "Contained files:"; ls ./night-horizons-mapmaker/night_horizons'
echo

echo 'Can we see the input and output buckets from inside a python script inside the conda environment inside the docker container inside the ec2 instance?'
docker compose -f ./aws/docker-compose.yaml \
    run \
    --volume $(realpath ./bin/validate.py):/validate.py \
    --volume $(realpath ./bin/io_manager.py):/io_manager.py \
    --volume $(realpath ./config/mosaic.yml):/used_config.yml \
    nitelite-pipeline \
    /bin/bash -c \
    'conda run -n nitelite-pipeline-conda --live-stream \
    python /validate.py /used_config.yml --validate_only'
echo

# echo 'Does the pipeline code inside the docker container find the data?'
# docker compose -f ./aws/docker-compose.yaml \
#     run \
#     --volume $(realpath ./config/mosaic.yml):/used_config.yml \
#     nitelite-pipeline \
#     /bin/bash -c \
#     'conda run -n nitelite-pipeline-conda \
#     python night-horizons-mapmaker/night_horizons/mapmake.py \
#     /used_config.yml --validate_only'
# 
# echo 'Does the execution script work?'
# ./bin/mapmake.sh -d /data:/data -c $(realpath ./config/mosaic.yml):/used_config.yml --validate_only
# echo