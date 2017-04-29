
# coding: utf-8

# In[ ]:

import luigi
import boto
import boto.s3
import pandas as pd

from boto.s3.key import Key
from luigi.s3 import S3Target, S3Client
import numpy as np
import random
from random import randint


def percent_cb(complete, total):
    sys.stdout.write('.')
    sys.stdout.flush()
# In[ ]:

class CleanUp(luigi.Task):

    def requires(self):
        return []
 
    def output(self):
        return luigi.LocalTarget("Clean_Property_final.csv")
 
    def run(self):
        df1 = pd.read_csv("Property_final.csv", encoding= 'iso-8859-1',low_memory=False)

        print('Handling Missing Data in approved Loan')
        
        df1["no.of.house"] = df1["no.of.house"].replace(np.nan,0)
        df1["price"] = df1["price"].replace(np.nan,0)
        df1["YoY"]= df1["YoY"].replace(np.nan,0)
        df1["DaysOnMarket"]= df1["DaysOnMarket"].replace(np.nan,0)
        df1["sq_price"]= df1["sq_price"].replace(np.nan,0)
        df1["price.1"]= df1["price.1"].replace(np.nan,0)
        df1.rename(columns={'no.of.house': 'noofhouse'}, inplace=True)
        df1.rename(columns={'price.1': 'price1'}, inplace=True)
        
        for i in range(0,len(df1)):
            if i < len(df1):
                if int(df1[i:i+1].price) == 0:
                    df1.ix[i:i+1,"price"] = int(df1['price'].mean())
                if int(df1[i:i+1].DaysOnMarket) == 0:
                    df1.ix[i:i+1,"DaysOnMarket"] = randint(50,70)
                if int(df1[i:i+1].YoY) == 0:
                    df1.ix[i:i+1,"YoY"] = randint(1,6)
                if int(df1[i:i+1].sq_price) == 0:
                    df1.ix[i:i+1,"sq_price"] = randint(3,8)
                if int(df1[i:i+1].price1) == 0:
                    df1.ix[i:i+1,"price1"] = randint(80,200)
                if int(df1[i:i+1].noofhouse) == 0:
                    df1.ix[i:i+1,"noofhouse"] = randint(1,5)
        
        df1["sq_price"] = df1["sq_price"].astype(int)
        df1["price"] = df1["price"].astype(int)
        df1["DaysOnMarket"] = df1["DaysOnMarket"].astype(int)
        df1["YoY"] = df1["YoY"].astype(int)
        df1["price1"] = df1["price1"].astype(int)
        df1["noofhouse"] = df1["noofhouse"].astype(int)

        df1["sq_feet"] = df1["sq_price"] * df1["price"] / 1000
        df1["sq_feet"] = df1["sq_feet"].astype(int)
        
        #propertyData = pd.DataFrame(df1, columns = ['zipcode', 'Beds','DaysOnMarket','AppreciationIndex','Sq_feet'])
        propertyData = pd.DataFrame()
        propertyData['zipcode']= df1['zipcode']
        propertyData['Beds']= df1['noofhouse']
        propertyData['price']= df1['price']
        propertyData['DaysOnMarket']= df1['DaysOnMarket']
        propertyData['AppreciationIndex']= df1['YoY']
        propertyData['Sq_feet']= df1['sq_feet']
        
        
        #Write clean data to new CSV
        propertyData.to_csv("Clean_Property_final.csv", sep=",") 


# In[ ]:

class UploadToS3(luigi.Task):
    awsKey = luigi.Parameter(config_path=dict(section='path',name='aws_key'))
    awsSecret = luigi.Parameter(config_path=dict(section='path',name='aws_secret'))
    def requires(self):
        return [CleanUp()]
    def output(self):
        return []
    def run(self):
        akey=self.awsKey
        askey=self.awsSecret
        conn = boto.connect_s3(akey,askey)
        TeamNumber='team3'
        bucket_name = TeamNumber+ '-final-project'
        try:
            bucket = conn.create_bucket(bucket_name,location=boto.s3.connection.Location.DEFAULT)
        except Exception as e:
            print("Amazon access key or secret key is invalid")
        bucket = conn.get_bucket(bucket_name)
        k = Key(bucket)
        k.key = "Clean_Property_final.csv"
        k.set_contents_from_filename("Clean_Property_final.csv")

# In[ ]:

if __name__ == '__main__':
    luigi.run()

