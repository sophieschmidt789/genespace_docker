# Steps to run this container on Nova

## 1. Build the container on your computer with `sudo` previlges

```bash
git clone git@github.com:HuffordLab-Containers/genespace_docker.git
cd genespace_docker
sudo docker build -t GeneSpaceRstudio:4.2.2  -f Dockerfile .
```

## 2. Convert docker image to Singularity

```bash
sudo singularity build rstudio-genespace.sif docker-daemon://GeneSpaceRstudio:4.2.2
```

## 3. Transfer the image to Nova

```bash
rsync -avP rstudio-genespace.sif  novadtn:/work/mash-covid/genespace/rstudio/
```

## 4. Submit a job script to start the Rstudio server

A sample job script (`container_v2.slurm`) looks like this:

```bash
#!/bin/sh
#SBATCH --nodes=1
#SBATCH --partition=amd
#SBATCH --exclusive
#SBATCH --time=4-00:00:00
#SBATCH --account=las
#SBATCH --qos=las
#SBATCH --job-name=rstudio
#SBATCH --output=nova-%x.%j.out
#SBATCH --error=nova-%x.%j.err
#SBATCH --mail-user=$USER@iastate.edu
#SBATCH --mail-type=begin
#SBATCH --mail-type=end
ml singularity
SINGULARITY_IMAGE=rstudio-genespace.sif
workdir=$(python -c 'import tempfile; print(tempfile.mkdtemp())')
mkdir -p -m 700 ${workdir}/run ${workdir}/tmp ${workdir}/var/lib/rstudio-server
cat > ${workdir}/database.conf <<END
provider=sqlite
directory=/var/lib/rstudio-server
END
mkdir -p ${SLURM_SUBMIT_DIR}/packages
cat > ${workdir}/rsession.sh <<END
#!/bin/sh
export OMP_NUM_THREADS=${SLURM_JOB_CPUS_PER_NODE}
export R_LIBS_USER=${SLURM_SUBMIT_DIR}/packages
exec /usr/lib/rstudio-server/bin/rsession "\${@}"
END
chmod +x ${workdir}/rsession.sh
export SINGULARITY_BIND="${workdir}/run:/run,${workdir}/tmp:/tmp,${workdir}/database.conf:/etc/rstudio/database.conf,${workdir}/rsession.sh:/etc/rstudio/rsession.sh,${workdir}/var/lib/rstudio-server:/var/lib/rstudio-server"
export SINGULARITYENV_RSTUDIO_SESSION_TIMEOUT=0
export SINGULARITYENV_USER=$(id -un)
export SINGULARITYENV_PASSWORD=$(openssl rand -base64 15)
readonly PORT=$(python -c 'import socket; s=socket.socket(); s.bind(("", 0)); print(s.getsockname()[1]); s.close()')
cat 1>&2 <<END
1. SSH tunnel from your workstation using the following command:

   ssh -N -L 8787:${HOSTNAME}:${PORT} ${SINGULARITYENV_USER}@${HOSTNAME}

   and point your web browser to http://localhost:8787

2. log in to RStudio Server using the following credentials:

   user: ${SINGULARITYENV_USER}
   password: ${SINGULARITYENV_PASSWORD}

When done using RStudio Server, terminate the job by:

1. Exit the RStudio Session ("power" button in the top right corner of the RStudio window)
2. Issue the following command on the login node:

      scancel -f ${SLURM_JOB_ID}
END
singularity exec --cleanenv $SINGULARITY_IMAGE \
    rserver --server-user ${USER} \
            --www-port ${PORT} \
            --auth-none=0 \
            --auth-pam-helper-path=pam-helper \
            --auth-stay-signed-in-days=30 \
            --auth-timeout-minutes=0 \
            --rsession-path=/etc/rstudio/rsession.sh
printf 'rserver exited' 1>&2
```

Submit the job

```
sbatch container_v2.slurm
```

5. Access Rstudio from your local computer after port forwarding.

From your local computer, open a port following the instructions in `nova-rstudio.11222333.err` file that appears after the job starts running.
The command looks something like this:

```bash
ssh -N -L 8787:novaamd123:54321 username@nova.its.iastate.edu
# enter auth code and the password - the terminal appears hung, but that is fine. 
```
open any of your web browser (local computer), and go to: `http://localhost:8787`
enter the username and password as shown in the `nova-rstudio.11222333.err` file. You should see the RStudio on your browser. 

This image has Rstudio with dependecies for genespace pre installed
