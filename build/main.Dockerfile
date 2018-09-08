FROM kaggle/python

EXPOSE 8888

sinclude(`proxy.Dockersecret')

# upgrade notebook to latest version
RUN conda install -c conda-forge libsodium
RUN conda install tornado=4.5.3
RUN conda upgrade notebook
RUN conda upgrade ipykernel
RUN conda upgrade terminado

RUN apt-get install vim -y
RUN pip install --upgrade pip
RUN pip install --upgrade tensorflow==1.3.0
RUN pip install --upgrade scikit-learn
RUN pip install --upgrade notebook
RUN pip install --upgrade jupyterlab
#RUN pip install --upgrade notebook==5.6.0

# extra dependencies
RUN pip install auto_ml
#RUN pip install pystache

# for Debugging:
RUN apt-get install net-tools

RUN echo "alias ll='ls -lA --color=auto'" >> $HOME/.bashrc
RUN adduser --system --shell /bin/bash --gecos 'Jupyter Labs User' --group --disabled-password --home /home/jupyter jupyter

WORKDIR /home/jupyter
RUN mkdir -p .jupyter
RUN chown -R jupyter.jupyter .

RUN echo "alias ll='ls -lA --color=auto'" >> .bashrc
RUN echo '{ "NotebookApp": { "password": "sha1:e72de5b3745a:1fb2bc04bba859d1a81aad3480abe2344076f3b9" } }' > /home/jupyter/.jupyter/jupyter_notebook_config.json

WORKDIR /tmp/Notebook
CMD [ "su", "-", "jupyter", "-c", "jupyter lab --ip=0.0.0.0 --notebook-dir=/tmp/Notebook" ]
