# We will use Ubuntu for our image
FROM ubuntu:22.04

# Updating Ubuntu packages
RUN apt-get update && yes|apt-get upgrade

# Adding wget and bzip2
RUN apt-get install -y wget bzip2

# Anaconda installing
RUN wget https://repo.anaconda.com/archive/Anaconda3-2022.10-Linux-x86_64.sh
RUN bash Anaconda3-2022.10-Linux-x86_64.sh -b
RUN rm Anaconda3-2022.10-Linux-x86_64.sh

# Set path to conda
ENV PATH /root/anaconda3/bin:$PATH

# Updating Anaconda packages
RUN conda update conda
RUN conda update anaconda
RUN conda update --all

# Configuring access to Jupyter
RUN mkdir /notebooks
RUN pip install notebook==6.5.6
RUN jupyter notebook --generate-config --allow-root
RUN echo "c.NotebookApp.password = u'sha1:6a3f528eec40:6e896b6e4828f525a6e20e5411cd1c8075d68619'" >> /root/.jupyter/jupyter_notebook_config.py

# Jupyter listens port: 8888
EXPOSE 8888

# Set working directory
WORKDIR /notebooks

RUN conda install tensorflow && python -c "import tensorflow; print(tensorflow.__version__)"
RUN conda install keras && python -c "import keras; print(keras.__version__)"

# Create the user
ARG user_id
ARG group_id
ARG user

RUN groupadd --gid $group_id $user \
    && useradd --uid $user_id --gid $group_id -m $user \
    #
    # [Optional] Add sudo support. Omit if you don't need to install software after connecting.
    && apt-get update \
    && apt-get install -y sudo \
    && echo $user ALL=\(root\) NOPASSWD:ALL > /etc/sudoers.d/$user \
    && chmod 0440 /etc/sudoers.d/$user

USER ${user}

# Run Jupytewr notebook as Docker main process
#CMD ["jupyter", "notebook", "--allow-root", "--notebook-dir=/notebooks", "--ip='*'", "--port=8888", "--no-browser"]
CMD [ "sudo", "/root/anaconda3/bin/jupyter", "notebook", "--allow-root", "--notebook-dir=/notebooks", "--ip='*'", "--port=8888", "--no-browser" ]
