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
SINGULARITY_IMAGE=genespace_0.9.4.sif
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