FROM quay.io/hisplan/scri-notebook:0.0.3

LABEL maintainer="Jaeyoung Chun (chunj@mskcc.org)"

RUN apt-get install -y zip

RUN pip install seaborn==0.11.1 matplotlib humanfriendly
        
# hack: nbcovert 6+ doesn't work properly to run `nbconvert --to html_toc`
RUN pip install nbconvert==5.6.1 jupyter_contrib_nbextensions==0.5.1
RUN jupyter contrib nbextension install --user \
    && jupyter nbextension enable toc2

COPY ./notebooks/inspect-*.ipynb /opt/
