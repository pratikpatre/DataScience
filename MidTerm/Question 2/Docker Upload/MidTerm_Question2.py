
# coding: utf-8

# In[2]:

import pip
def install(package):
   pip.main(['install', package])


# In[3]:

install('urllib3')


# In[ ]:

install('rpy2')


# In[ ]:

with open('config.json') as json_file:    
        json_data = json.load(json_file)
        quater = json_data["args"][0]
        username = json_data["args"][1]
        password = json_data["args"][2]


# In[ ]:

#Taking data from user
print("Please enter a year and quarter in config file(Example: Q12005)")
with open('config.json') as json_file:    
    json_data = json.load(json_file)

year_full=json_data["args"][0]
try:
    year = int(year_full[2:])
    #print('year ',year)
    quarter = year_full[:2] 
    #print('quarter ',quarter)

    next_quarter = int(quarter[1:]) + 1
    next_year = year
    if next_quarter > 4:
        next_quarter = 1
        next_year = year+1
    next_year_full = "Q"+ str(next_quarter) + str(next_year)

    print(next_year_full)
    if(int(year) < 1999 or int(year) > 2016):
        print("Year can have only numeric values between 1999 and 2016")
        log_entry("Wrong Year to process : Year out of range")
    else:
        year = year_full
        next_year = next_year_full
        print(year,next_year)
        return year,next_year
except Exception as e: 
    print("Year should be in format QNYYYY")
    log_entry("Wrong Year to process : Invalid format found in year") 


# In[16]:

import urllib.request
import pandas as pd
import requests
import sys
import cgitb
import urllib3
import rpy2
from bs4 import BeautifulSoup as bsoup

url ="https://freddiemac.embs.com/FLoan/secure/auth.php"
url1 = "https://freddiemac.embs.com/FLoan/Data/"

session = requests.session()

print(session)

session_data = {'username': username,
              'password':password,
               #'submit':'auth.php',
               'accept':'Yes',
                'action':'acceptTandC',
                'acceptSubmit':'Continue'}

r = session.post(url,data = session_data)
#print(r.cookies)

response = session.get("https://freddiemac.embs.com/FLoan/Data/download.php")
#print(response.text)

if 'Terms and Conditions' in response.text:
    print('Yes')
    session_data = {'username': username,
                    'password':password,
                    'accept':'Yes',
                    #'accept':'on',
                    'action': 'acceptTandC',
                   'acceptSubmit':'Continue',
                   'accept.checked':'true'}
    
    r = session.post('https://freddiemac.embs.com/FLoan/Data/download.php',data = session_data)
    #print(r.text)

    response = session.get("https://freddiemac.embs.com/FLoan/Data/download.php")
    
    #a = urllib.request.urlopen('https://freddiemac.embs.com/FLoan/Data/acceptTandC')
    #content= response.read()
    #print(response.content)
    #r = session.post(url,data = session_data)
    #response = session.get("https://freddiemac.embs.com/FLoan/Data/download.php")
    #print(response.text)


# In[4]:

import os
cwd = os.getcwd()
path = cwd +""+quater
print (cwd)
os.mkdir( path)
os.chdir(path)


# In[5]:

import zipfile, io, time
soup= bsoup(response.text,'lxml')
#print(soup)

href = soup.findAll ('a',limit=None)

for a in href:   
    zip_file_url = url1+a['href']
    #print (os.getcwd())
    if quater in (zip_file_url):
        print(zip_file_url)
        zfile = session.get(zip_file_url)
        #time.sleep(5)
        print(zfile)
        z = zipfile.ZipFile(io.BytesIO(zfile.content))
        z.extractall()
#os.chdir(cwd)


# In[12]:

import glob
fileList = glob.glob('*historical*')


# In[ ]:

list_of_lists = []
lines = []
year = 0
output_List=[]
final_List=[]

for i in fileList:
    if 'data1_Q' in i:
        file = open(i, 'r') 
        for line in file: 
            lines = line.split('|')
            lines.append(i[18:23])
            list_of_lists.append(lines)            
        output_List=getDataValues(list_of_lists)

output_List.to_csv('Assignment2_output.csv', index=False, header=True)


# In[38]:

def getDataValues(list_of_lists):
    data1=pd.DataFrame(list_of_lists)
    data1.rename(columns={0:'CreditScore',1:'FirstPaymentDT',2:'FirstTimeHomeBuyerFlag',3:'MaturityDT',4:'MetroDiv',5:'MortgageInsurancePT',6:'NoUnits',7:'OccupancyStatus',8:'OrigCLTV',9:'OrigDTI',10:'OrigUPB',11:'OrigLTV',12:'OrigInterestRate',13:'Channel',14:'PPMFlag',15:'ProductType',16:'PropertyState',17:'PropertyType',18:'PostaleCode',19:'LoanSeqNo',20:'LoanPurpose',21:'OrigLoanTerm',22:'NoOfBorrowers',23:'SellerName',24:'ServicerName',25:'SuperConfFlag'}, inplace=True)
    output_List= sendDataFrame(data1)
    return output_List


# In[17]:

from rpy2.robjects.packages import importr


# In[18]:

utils = importr('utils')


# In[19]:

utils.chooseCRANmirror(ind=1) 


# In[20]:

utils.install_packages('sqldf')


# In[21]:

utils.install_packages('ISLR')


# In[22]:

utils.install_packages('leaps')


# In[23]:

utils.install_packages('forecast')


# In[24]:

import rpy2


# In[25]:

rstring = """
          function(data1,data2){
          attach(data1)
          attach(data2)
          library(ISLR)
          library(leaps)
          library(sqldf)
          library(forecast)
          loan_train = data1
          xhstve.train = sqldf("select 
                     CreditScore,
                     MortgageInsurancePT,
                     OrigUPB,
                     OccupancyStatus,
                     LoanPurpose,
                     OrigLoanTerm,
                     OrigInterestRate
                     from loan_train")
          fit.train=lm(OrigInterestRate~.,data = xhstve.train)
          
          loan_test = data2

xhstve.test = sqldf("select 
                    CreditScore,
                    MortgageInsurancePT,
                    OrigUPB,
                    OccupancyStatus,
                    LoanPurpose,
                    OrigLoanTerm,
                    OrigInterestRate
                    from loan_test")

pred = predict(fit.train,xhstve.test)
accuracy(pred, xhstve.train$OrigInterestRate)
                     
          }"""


# In[26]:

rfunc=rpy2.robjects.r(rstring)


# In[27]:

from rpy2.robjects import pandas2ri


# In[ ]:

def sendDataFrame(data1,data2):
    rdata = pandas2ri.py2ri(data1,data2)
    r_df =rfunc(rdata)
    f_df=pandas2ri.ri2py(r_df)
    return f_df 


# In[ ]:



