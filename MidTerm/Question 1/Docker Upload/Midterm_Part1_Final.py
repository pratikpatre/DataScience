
# coding: utf-8

# In[ ]:

#LOGIN AND DOWNLOAD FILE


# In[6]:

import pip
def install(package):
    pip.main(['install', package])


# In[7]:

install('urllib3')


# In[18]:

import json 


# In[ ]:

with open('config.json') as json_file:    
        json_data = json.load(json_file)
        print (json_file)
        
        
username = json_data["args"][0]
password = json_data["args"][1]


# In[17]:

val = "Q42005"


# In[ ]:

import urllib.request
import pandas as pd
import requests
import sys
import cgitb
import urllib3
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


# In[ ]:

import os
cwd = os.getcwd()
path = cwd + "/sample"
print (cwd)
os.mkdir(path)
os.chdir(path)
os.getcwd()


# In[ ]:

import glob
fileList1 = glob.glob('*sample*')


# In[ ]:

import zipfile, io, time
soup= bsoup(response.text,'lxml')
#print(soup)

href = soup.findAll ('a',limit=None)

for a in href:
    zip_file_url = url1+a['href']
    #print (os.getcwd())
    if 'sample' in (zip_file_url):   
        count = 0
        val_orig = 'sample_orig_'+a.text[7:11]+'.txt'
        val_svcg = 'sample_svcg_'+a.text[7:11]+'.txt'
        
        if val_orig in fileList:
            count = 1     
        if val_svcg in fileList:
            count = 2
        #print (count)
        if count < 2:
            print(zip_file_url)
            zfile = session.get(zip_file_url)
            #time.sleep(5)
            print(zfile)
            z = zipfile.ZipFile(io.BytesIO(zfile.content))
            z.extractall()


# In[ ]:

#START OF PART1_Q1


# In[537]:

import glob
fileList1 = glob.glob('*sample*')


# In[538]:

import pandas as pd


# In[539]:

def getDataFrame1(list_of_lists1):
    newList = []
    data1 = pd.DataFrame(newList)
    list1 = [26,0,8,9,10,11]
    newList = [[l[i] for i in list1] for l in list_of_lists1]
    data1=pd.DataFrame(newList)
    data1.rename(columns={0:'Year',1:'CreditScore',2:'CLTV',3:'DTI',4:'UPB',5:'LTV'}, inplace=True)
    return data1


# In[540]:

def setCS_NA(data1):
    data1.CreditScore = data1[['CreditScore']].convert_objects(convert_numeric=True).fillna('NA')
    return data1


# In[541]:

def setDTI_NA(data1):
    data1.DTI = data1[['DTI']].convert_objects(convert_numeric=True).fillna('NA')
    return data1


# In[542]:

def setCLTV_NA(data1):
    data1.CLTV = data1[['CLTV']].convert_objects(convert_numeric=True).fillna('NA')
    return data1


# In[543]:

def setUPB_NA(data1):
    data1.UPB = data1[['UPB']].convert_objects(convert_numeric=True).fillna('NA') 
    return data1


# In[544]:

def setLTV_NA(data1):
    data1.LTV = data1[['LTV']].convert_objects(convert_numeric=True).fillna('NA')
    return data1
    


# In[546]:

def getDataValues1(list):
    data1= pd.DataFrame()
    data1=getDataFrame1(list)
    #print (len(data1))
  
    data1=setUPB_NA(data1)
    data1=setCLTV_NA(data1)
    data1=setDTI_NA(data1)
    data1=setLTV_NA(data1)
    data1=setCS_NA(data1)
    
    sum_CLTV = 0
    count_CLTV=0 
    for a in data1.CLTV:
        if (a != 'NA'):
            sum_CLTV = sum_CLTV+a
            count_CLTV = count_CLTV+1
    avg_CLTV=round((sum_CLTV/count_CLTV),1)
    
    sum_CS = 0
    count_CS=0
    for a in data1.CreditScore:
        if (a != 'NA'):
            sum_CS = sum_CS+a
            count_CS= count_CS +1
    avg_CS=int(sum_CS/count_CS)
    
    sum_DTI = 0
    count_DTI=0
    for a in data1.DTI:
        if (a != 'NA'):
            sum_DTI = sum_DTI+a
            count_DTI= count_DTI +1
    avg_DTI=round((sum_DTI/count_DTI),1)
    
    sum_UPB = 0
    count_UPB=0
    for a in data1.UPB:
        if (a != 'NA'):
            sum_UPB = sum_UPB+a
            count_UPB= count_UPB+1
    avg_UPB=round((sum_UPB/count_UPB),1)
    
    sum_LTV = 0
    count_LTV=0
    for a in data1.LTV:
        if (a != 'NA'):
            sum_LTV = sum_LTV+a
            count_LTV = count_LTV +1
    avg_LTV=round((sum_LTV/count_LTV),1)
    
    #tempList = [data1.Year[1],avg_CLTV,avg_CS,avg_DTI,avg_LTV,avg_UPB]
    #print(tempList)
    output_List1.append((data1.Year[1],avg_CS,avg_CLTV,avg_DTI,avg_UPB,avg_LTV))
    return output_List1


# In[547]:

list_of_lists1 = []
lines1 = []
year1 = 0
output_List1=[]
final_List1=[]

for i in fileList1:
    if 'orig' in i:
        if year1 == 0:
            year1 = i[12:16]
            file = open(i, 'r') 
            for line in file: 
                lines1 = line.split('|')
                lines1.append(i[12:16])
                list_of_lists1.append(lines1)
        if year1 != i[12:16]:
            output_List1=getDataValues1(list_of_lists1)
            #print (output_List1)
            #dataF1= pd.DataFrame(output_List1)
            final_List1.append(output_List1)
            #print (dataF1)
            output_List1=[]
            list_of_lists1=[]
           
            year1 = i[12:16]
            file = open(i, 'r') 
            for line in file: 
                lines1 = line.split('|')
                lines1.append(i[12:16])
                list_of_lists1.append(lines1)
        if(year1=='2016'):
            output_List1=getDataValues1(list_of_lists1)
            final_List1.append(output_List1)
sd=[]
for a in final_List1:
    for b in a:
        #print (b)
        sd.append(b)
dataF1=pd.DataFrame(sd)
dataF1.rename(columns={0:'Year',1:'CreditScore',2:'CLTV',3:'DTI',4:'UPB',5:'LTV'}, inplace=True)
#dataF1.to_csv('my_csv_orig.csv', index=False, header=True)
print(dataF1)


# In[516]:

df= dataF1.transpose()


# In[517]:

df1= df.loc[['Year','CLTV']]
df1=df1.transpose()
df1.set_index('Year').plot()


# In[532]:

df1= df.loc[['CreditScore','UPB']]
df1=df1.transpose()
df1.set_index('UPB').plot(kind="line")


# In[531]:

df1= df.loc[['LTV','DTI']]
df1=df1.transpose()
df1.set_index('DTI').plot(kind="bar")


# In[ ]:

df.to_csv('Part1_Sample_origination_data.csv', index=False, header=False)


# In[4]:

#END OF PART1_Q1


# In[5]:

#START OF PART1_Q2


# In[ ]:

def getDataFrame2(list_of_lists):
    newList = []
    data2 = pd.DataFrame(newList)
    list1 = [22,8,6,4]
    newList = [[l[i] for i in list1] for l in list_of_lists]
    data2=pd.DataFrame(newList)
    data2.rename(columns={0:'Year',1:'Zero Balance Score',2:'Repurchase loan',3:'Loan age'}, inplace=True)
    return data2


# In[ ]:

def getDataValues2(list):
    data2= pd.DataFrame()
    data2=getDataFrame2(list)


    precount=0
    total=0
    rpcount=0
    loanage = 0
    #unpaid = 0
    for row in data2.itertuples():
        if row[2] != "":    
            total =total+1
            loanage = loanage + int(row[4])
        if row[3] == "Y" :
            rpcount = rpcount + 1
        if row[2]=='01' or row[2]=='06':
            precount=precount+1
        #if row[2] !="" and row[5]=="0":
            #unpaid=unpaid+1


    pre_avg=(precount/total)*100
    rp_perc=(rpcount/total)*100
    avg_loanage=loanage/total
    #print(count)
    #print(total)
    #print(rpcount)
    #print(rpcount/total)
    #print(avg)
    #print("Avg Loan age:", loanage/total)
    #print(unpaid)

    output_List.append((data2.Year[1],pre_avg,rp_perc,avg_loanage))
    return output_List


# In[ ]:

list_of_lists = []
lines = []
year = 0
output_List=[]
final_List=[]

for i in fileList1: 
    if 'svcg' in i:
        if year == 0:
            year = i[12:16]
            file = open(i, 'r') 
            for line in file: 
                lines = line.split('|')
                lines.append(i[12:16])
                list_of_lists.append(lines)
        if year != i[12:16]:
            output_List=getDataValues2(list_of_lists)
            final_List.append(output_List)
            output_List=[]
            list_of_lists=[]
           
            year = i[12:16]
            file = open(i, 'r') 
            for line in file: 
                lines = line.split('|')
                lines.append(i[12:16])
                list_of_lists.append(lines)
        if(year=='2016'):
            output_List=getDataValues2(list_of_lists)
            final_List.append(output_List)
sd=[]
for a in final_List:
    for b in a:
        #print (b)
        sd.append(b)
dataF=pd.DataFrame(sd)
dataF.rename(columns={0:'Year',1:'PrePay %',2:'Repurchase',3:'Average Loan Age'}, inplace=True)
#dataF.to_csv('my_csv_orig.csv', index=False, header=True)
print(dataF)


# In[ ]:

#import matplotlib.pyplot as plt 
df= dataF.transpose()
print (df)


# In[ ]:

import matplotlib.pyplot as plt
df1= df.loc[['Year','PrePay %']]
df1=df1.transpose()
print(df1)


# In[ ]:

df1.set_index('Year').plot(kind="line")


# In[ ]:

plt.show()


# In[ ]:

import matplotlib.pyplot as plt
df2= df.loc[['Year','Average Loan Age']]
df2=df2.transpose()
print(df2)


# In[ ]:

df2.set_index('Year').plot(kind="bar")


# In[ ]:

plt.show()


# In[ ]:

df.to_csv('Part1_Sample_performance_data.csv', index=False, header=False)


# In[ ]:

#END OF PART1_Q2


# In[ ]:

#START OF PART1_Q3


# In[ ]:

os.chdir(cwd)
path1 = cwd + "/historical"
os.mkdir(path1)
os.chdir(path1)


# In[ ]:

import glob
fileList = glob.glob('*historical*')


# In[ ]:

import zipfile, io, time
soup= bsoup(response.text,'lxml')
#print(soup)

href = soup.findAll ('a',limit=None)

for a in href:
   
    zip_file_url = url1+a['href']
    #print (os.getcwd())
    if 'historical' in (zip_file_url) and '2005' in (zip_file_url):   
        count = 0
        val_orig = 'historical_data1_'+a.text[17:23]+'.txt'
        val_svcg = 'historical_data1_time_'+a.text[17:23]+'.txt'
        
        if val_orig in fileList:
            count = 1     
        if val_svcg in fileList:
            count = 2
        #print (count)
        if count < 2:
            print(zip_file_url)
            zfile = session.get(zip_file_url)
            #time.sleep(5)
            print(zfile)
            z = zipfile.ZipFile(io.BytesIO(zfile.content))
            z.extractall()

#os.chdir(cwd)


# In[ ]:

import glob
fileList = glob.glob('*historical*')


# In[ ]:

def getDataFrame3(list_of_lists):
    newList = []
    data1 = pd.DataFrame(newList)
    list1 = [0,5,6,8,9,10,14,16,22,26]
    newList = [[l[i] for i in list1] for l in list_of_lists]
    #print (newList)
    data1 = pd.DataFrame(newList)
    data1.rename(columns={0:'CreditScore',1:'MortgageInsurancePT',2:'NoUnits',3:'OrigCLTV',4:'OrigDTI',5:'OrigUPB',6:'PPMFlag',7:'PropertyState',8:'NoOfBorrowers',9:'Year'}, inplace=True)
    #print (data1.head(10))
    return data1


# In[ ]:

def getDataValues3(list_of_lists):
    data1= pd.DataFrame()
    data1=getDataFrame3(list_of_lists)
    #print (len(data2))
  
    data1=dataClean1(data1)
    data1=dataClean2(data1)
    data1=dataClean3(data1)
    data1=dataClean4(data1)
    data1=dataClean5(data1)
    data1=dataClean6(data1)
    
    averageVal=avgCalc(data1)
    stateRiskList = []
    for i in range(0,len(data1)):
        scorecount = 0
        if i < len(data1):
            if int(data1[i:i+1].CreditScore) > 650:
                scorecount += 1
            if int(data1[i:i+1].MortgageInsurancePT) == 0:
                scorecount += 1
            if int(data1[i:i+1].NoUnits) > 2:
                scorecount += 1
            if int(data1[i:i+1].OrigCLTV) < 121:
                scorecount += 1
            if int(data1[i:i+1].OrigDTI) < 36:
                scorecount += 1
            if int(data1[i:i+1].OrigUPB) < averageVal:
                scorecount += 1
            if str(data1[i:i+1].PPMFlag) == 'N':
                scorecount += 1
            if int(data1[i:i+1].NoOfBorrowers) > 1:
                scorecount += 1
            riskscore = calcRisk(scorecount)
            #print (riskscore)
            #print (data[i:i+1].PropertyState)
            stateRiskList.append((riskscore,data1[i:i+1].PropertyState.item(),data1[i:i+1].Year.item()))

    
    #tempList = [data2.Year[1],avg_CLTV,avg_CS,avg_DTI,avg_LTV,avg_UPB]
    #print(tempList)
    output_List.append(stateRiskList)
    return output_List


# In[ ]:

def avgCalc(data1):
    sumval = 0
    count = 0
    for i in data1["OrigUPB"]:
        sumval += int(i)
        count += 1
    #print (sumval)
    #print (count)
    #print (sumval/count)
    averageVal = sumval/count
    return averageVal


# In[ ]:

def calcRisk(scorecount):
    calcper = (scorecount/8)*100
    if 0 <= calcper <10:
        return 10
    if 10 <= calcper <20:
        return 9
    if 20 <= calcper <30:
        return 8
    if 30 <= calcper <40:
        return 7
    if 40 <= calcper <50:
        return 6
    if 50 <= calcper <60:
        return 5
    if 60 <= calcper <70:
        return 4
    if 70 <= calcper <80:
        return 3
    if 80 <= calcper <90:
        return 2
    if 90 <= calcper <=100:
        return 1


# In[ ]:

def dataClean1(data1):
    data1.MortgageInsurancePT = data1[['MortgageInsurancePT']].convert_objects(convert_numeric=True).fillna(0)
    return data1

def dataClean2(data1):
    data1.OrigDTI = data1[['OrigDTI']].convert_objects(convert_numeric=True).fillna(67)
    return data1

def dataClean3(data1):
    data1.CreditScore = data1[['CreditScore']].convert_objects(convert_numeric=True).fillna(300)
    return data1

def dataClean4(data1):
    data1.NoOfBorrowers = data1[['NoOfBorrowers']].convert_objects(convert_numeric=True).fillna(0)
    return data1

def dataClean5(data1):
    data1.OrigCLTV = data1[['OrigCLTV']].convert_objects(convert_numeric=True).fillna(201)
    return data1

def dataClean6(data1):
    data1.NoUnits = data1[['NoUnits']].convert_objects(convert_numeric=True).fillna(0)
    return data1


# In[ ]:

def dataProcessing(data1):
    avgCalc(data1)
    stateRiskList = []
    for i in range(0,len(data1)):
        scorecount = 0
        if i < len(data1):
            if int(data1[i:i+1].CreditScore) > 650:
                scorecount += 1
            if int(data1[i:i+1].MortgageInsurancePT) == 0:
                scorecount += 1
            if int(data1[i:i+1].NoUnits) > 2:
                scorecount += 1
            if int(data1[i:i+1].OrigCLTV) < 121:
                scorecount += 1
            if int(data1[i:i+1].OrigDTI) < 36:
                scorecount += 1
            if int(data1[i:i+1].OrigUPB) < averageVal:
                scorecount += 1
            if str(data1[i:i+1].PPMFlag) == 'N':
                scorecount += 1
            if int(data1[i:i+1].NoOfBorrowers) > 1:
                scorecount += 1
            riskscore = calcRisk(scorecount)
            #print (riskscore)
            #print (data[i:i+1].PropertyState)
            stateRiskList.append((riskscore,data1[i:i+1].PropertyState.item(),data1[i:i+1].Year.item()))


# In[ ]:

def getReducedFrame(dataF):
    reduced = pd.DataFrame(states)
    reduced.rename(columns={0:'State',1:'RiskScore',2:'Count',}, inplace=True)
    for i in range(0,len(dataF)):
        for j in range(0,len(reduced)):
           
            if (dataF[i:i+1].State.item() == reduced[j:j+1].State.item()):
                temp =  ( int(dataF[i:i+1].RiskScore)+int(reduced[j:j+1].RiskScore))

                reduced[j:j+1].RiskScore = temp
                reduced[j:j+1].Count= int(reduced[j:j+1].Count) + 1

    return reduced




# In[ ]:

states=[('AK',0,0)
('AL',0,0)
('AR',0,0),
('AS',0,0),
('AZ',0,0),
('CA',0,0),
('CO',0,0),
('CT',0,0),
('DC',0,0),
('DE',0,0),
('FL',0,0),
('GA',0,0),
('GU',0,0),
('HI',0,0),
('IA',0,0),
('ID',0,0),
('IL',0,0),
('IN',0,0),
('KS',0,0),
('KY',0,0),
('LA',0,0),
('MA',0,0),
('MD',0,0),
('ME',0,0),
('MI',0,0),
('MN',0,0),
('MO',0,0),
('MP',0,0),
('MS',0,0),
('MT',0,0),
('NA',0,0),
('NC',0,0),
('ND',0,0),
('NE',0,0),
('NH',0,0),
('NJ',0,0),
('NM',0,0),
('NV',0,0),
('NY',0,0),
('OH',0,0),
('OK',0,0),
('OR',0,0),
('PA',0,0),
('PR',0,0),
('RI',0,0),
('SC',0,0),
('SD',0,0),
('TN',0,0),
('TX',0,0),
('UT',0,0),
('VA',0,0),
('VI',0,0),
('VT',0,0),
('WA',0,0),
('WI',0,0),
('WV',0,0),
('WY',0,0)]


# In[ ]:

list_of_lists = []
lines = []
year = 0
output_List=[]
final_List=[]

for i in fileList:
    if 'data1_Q' in i:
        if year == 0:
            year = i[18:23]
            file = open(i, 'r') 
            for line in file: 
                lines = line.split('|')
                lines.append(i[18:23])
                list_of_lists.append(lines)
        if year != i[18:23]:
            output_List=getDataValues3(list_of_lists)
            #print (output_List)
            #dataF= pd.DataFrame(output_List)
            final_List.append(output_List)
            #print (dataF)
            output_List=[]
            list_of_lists=[]
           
            year = i[18:23]
            file = open(i, 'r') 
            for line in file: 
                lines = line.split('|')
                lines.append(i[18:23])
                list_of_lists.append(lines)
        if(year=='42005'):
            output_List=getDataValues3(list_of_lists)
            final_List.append(output_List)
sd=[]
for a in final_List:
    for b in a:
        for d in b:
            #print (b)
            sd.append(d)
dataF=pd.DataFrame(sd)
dataF.rename(columns={0:'RiskScore',1:'State',2:'Year'}, inplace=True)
dataF.to_csv('my_csv_2005_risk_factor.csv', index=False, header=True)
#print(dataF)

newDataF = pd.DataFrame()
newDataF=getReducedFrame(dataF)
print(newDataF)

