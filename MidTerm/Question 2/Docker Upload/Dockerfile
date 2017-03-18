# Copyright (c) Jupyter Development Team.
# Distributed under the terms of the Modified BSD License.
FROM jupyter/minimal

MAINTAINER Jupyter Project <kamath.p@husky.neu.edu>

USER root

# libav-tools for matplotlib anim
RUN apt-get update && \
    apt-get clean && \
        rm -rf /var/lib/apt/lists/*

	USER $NB_USER
    
        # Install Python 3 packages
	# Remove pyqt and qt pulled in for matplotlib since we're only ever going to
	# use notebook-friendly backends in these images
	RUN conda install --quiet --yes \
	    'nomkl' \
              'python-dateutil' \
	        'ipywidgets=5.2*' \
		    'pandas=0.19*' \
		        'numexpr=2.6*' \
			    'matplotlib' \
			        'scipy=0.17*' \
				    'beautifulsoup4=4.5.*' \
				               'lxml' \
  				               	  ‘pip’ \
				               	    ‘urllib’ \
				               	      ‘requests’ \
				               	 	‘sys’ \
				               	 	 ‘cgitb’ \
				               	          ‘urllib3’ \
				               	 	    ‘glob’ \
				               	 	     ‘os’ \
	    					              ‘zipfile’ \
				               	 		‘io’ \
				               	   		 ‘time’ \
						                    'html5lib' \
				                                     'xlrd'  && \
					        # conda remove --quiet --yes --force qt pyqt && \
					        conda clean -tipsy



ADD adsmidtermpart1.py adsmidtermpart1.py
ADD config.json config.json

# WORKDIR /srv/
EXPOSE 8888
CMD ["bash"]

#-c 'jupyter notebook --ip=8888 --NotebookApp.password="$PASSWD" "$@"'