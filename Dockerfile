FROM condaforge/mambaforge

RUN conda update -n base conda
RUN conda install -n base conda-libmamba-solver
RUN conda config --set solver libmamba

COPY . .

RUN conda env create -f envs/environment.yaml

RUN echo "source activate pypsa-eur" > ~/.bashrc
ENV PATH /opt/conda/envs/pypsa-eur/bin:$PATH

