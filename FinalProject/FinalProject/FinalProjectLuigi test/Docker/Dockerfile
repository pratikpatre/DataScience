FROM python:3

USER root

ADD dataCleaning_Property_LUIGI.py dataCleaning_Property_LUIGI.py
ADD Property_final.csv Property_final.csv

RUN apt-get update && \
    apt-get clean && \
        rm -rf /var/lib/apt/lists/*

	USER $NB_USER
    
    # Install Python 3 packages
	# Remove pyqt and qt pulled in for matplotlib since we're only ever going to
	# use notebook-friendly backends in these images
	RUN pip install boto
	RUN pip install luigi
	RUN pip install numpy
	RUN pip install pandas
	

#RUN pip install pystrich

CMD [ "python", "./dataCleaning_Property_LUIGI.py", "UploadToS3", "--local-scheduler", "--awsKey", "AKIAIQJWJZP2CLKCC3QQ", "--awsSecret","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" ]