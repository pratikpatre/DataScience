
# coding: utf-8

# In[4]:

import luigi
import boto
import boto.s3
import requests
import zipfile, io, time, os
import urllib.request
import requests
import zipfile
import glob
import pandas as pd

from urllib.request import urlopen
from bs4 import BeautifulSoup as bsoup
from boto.s3.key import Key
from luigi.s3 import S3Target, S3Client


# In[5]:

def login():
    #loanStatsFileNamesJS
    loan_data = 'loanStatsFileNamesJS'
    download_data(loan_data)
    loanData = read_data(loan_data)
    return loanData

    #rejectedLoanStatsFileNamesJS
    #rejected_loan = 'rejectedLoanStatsFileNamesJS'
    #download_data(rejected_loan)
    #rejected_data = read_data(rejected_loan)
    #return rejected_data


# In[6]:

def download_data(dataset):
    base_URL = "https://resources.lendingclub.com"
    url = urllib.request.urlopen("https://www.lendingclub.com/info/download-data.action")
    content = url.read()
    #print(content)
    soup= bsoup(content,'lxml')
    
    #find div by ID
    fileNameDiv = soup.find('div',{"id":dataset})
    FileList = fileNameDiv.text.rstrip("|")
    #print(FileList)

    for fileName in FileList.split("|"):
        file_URL= base_URL+'/'+fileName
        print(file_URL)
        if not is_file_present(dataset,fileName):    
            zfile = requests.get(file_URL)
            z = zipfile.ZipFile(io.BytesIO(zfile.content))
            z.extractall(dataset)


# In[7]:

def read_data(dataset):
    fileList = glob.glob(dataset+'/*.csv')
    
    dfList=[]
    #columns=["id","member_id","loan_amnt","funded_amnt","funded_amnt_inv","term","int_rate","installment","grade","sub_grade","emp_title","emp_length","home_ownership","annual_inc","verification_status","issue_d","loan_status","pymnt_plan","url","desc","purpose","title","zip_code","addr_state","dti","delinq_2yrs","earliest_cr_line","inq_last_6mths","mths_since_last_delinq","mths_since_last_record","open_acc","pub_rec","revol_bal","revol_util","total_acc","initial_list_status","out_prncp","out_prncp_inv","total_pymnt","total_pymnt_inv","total_rec_prncp","total_rec_int","total_rec_late_fee","recoveries","collection_recovery_fee","last_pymnt_d","last_pymnt_amnt","next_pymnt_d","last_credit_pull_d","collections_12_mths_ex_med","mths_since_last_major_derog","policy_code","application_type","annual_inc_joint","dti_joint","verification_status_joint","acc_now_delinq","tot_coll_amt","tot_cur_bal","open_acc_6m","open_il_6m","open_il_12m","open_il_24m","mths_since_rcnt_il","total_bal_il","il_util","open_rv_12m","open_rv_24m","max_bal_bc","all_util","total_rev_hi_lim","inq_fi","total_cu_tl",
             #"inq_last_12m","acc_open_past_24mths","avg_cur_bal","bc_open_to_buy","bc_util","chargeoff_within_12_mths","delinq_amnt","mo_sin_old_il_acct","mo_sin_old_rev_tl_op","mo_sin_rcnt_rev_tl_op","mo_sin_rcnt_tl","mort_acc","mths_since_recent_bc","mths_since_recent_bc_dlq","mths_since_recent_inq","mths_since_recent_revol_delinq","num_accts_ever_120_pd","num_actv_bc_tl","num_actv_rev_tl","num_bc_sats","num_bc_tl","num_il_tl","num_op_rev_tl","num_rev_accts","num_rev_tl_bal_gt_0","num_sats","num_tl_120dpd_2m","num_tl_30dpd","num_tl_90g_dpd_24m","num_tl_op_past_12m","pct_tl_nvr_dlq","percent_bc_gt_75","pub_rec_bankruptcies","tax_liens","tot_hi_cred_lim","total_bal_ex_mort","total_bc_limit","total_il_high_credit_limit"]
    for filename in fileList:
        print(filename)
        df=pd.read_csv(filename, low_memory=False,skiprows=1)
        print(df.shape)
        ts = time.time()
        df["recorded_timestamp"] = filename.rstrip('csv').lstrip('loanStatsFileNamesJS\\').lstrip('rejectedLoanStatsFileNamesJS\\').lstrip("LoanStats").lstrip("RejectStats").lstrip("_")
        dfList.append(df)
    concatDf=pd.concat(dfList, axis=0)
    #concatDf.columns=columns
    concatDf.to_csv(dataset+"_concat_file.csv", index=None)
    print(concatDf.shape)
    return concatDf


# In[8]:

def is_file_present(dataset,filename):
    if not os.path.exists(dataset):
        os.makedirs(dataset)
    #print(os.path.isdir(directory))
    file_list = glob.glob(dataset+'/*.csv')
    for file_name_in_dir in file_list:
        if (dataset+ '/' + filename) == (file_name_in_dir+".zip"):
            return True
    return False


# In[12]:

def columnDrop(data):
    data.drop('grade', axis=1, inplace=True)
    data.drop('sub_grade', axis=1, inplace=True)
    data.drop('emp_title', axis=1, inplace=True)
    data.drop('desc', axis=1, inplace=True)
    data.drop('url', axis=1, inplace=True)
    data.drop('pymnt_plan', axis=1, inplace=True)
    data.drop('zip_code', axis=1, inplace=True)
    data.drop('title', axis=1, inplace=True)
    data.drop('policy_code', axis=1, inplace=True)
    data.drop('verification_status_joint', axis=1, inplace=True)
    
    return data


# In[13]:

def Clean_data(data):
    #Handling Missing data
    #P.S. All the data below replaced is missing data and data which is handled with 10101010 is handled further ahead for logical reasons.
    data.mo_sin_old_il_acct = data[['mo_sin_old_il_acct']].convert_objects(convert_numeric=True).fillna(10101010)
    data.inq_last_6mths = data[['inq_last_6mths']].convert_objects(convert_numeric=True).fillna(10101010)
    data.mo_sin_old_rev_tl_op = data[['mo_sin_old_rev_tl_op']].convert_objects(convert_numeric=True).fillna(10101010)
    data.mths_since_rcnt_il = data[['mths_since_rcnt_il']].convert_objects(convert_numeric=True).fillna(10101010)
    data.num_bc_tl = data[['num_bc_tl']].convert_objects(convert_numeric=True).fillna(10101010)
    data.mths_since_last_delinq = data[['mths_since_last_delinq']].convert_objects(convert_numeric=True).fillna(10101010)

    #dti
    #acc_now_delinq
    #pct_tl_nvr_dlq

    #replace "int_rate" with 0% and remove trailing '%' and divide by 100 to get the final interest rate
    data.int_rate = data[['int_rate']].convert_objects(convert_numeric=True).fillna('0.0%')
    data['int_rate'] = data['int_rate'].map(lambda x: x.rstrip('%'))
    data['int_rate'] = data['int_rate'].apply(lambda x: float(x)/100)

    #replace "Number of installment accounts" with 0
    data.num_il_tl = data[['num_il_tl']].convert_objects(convert_numeric=True).fillna(0)

    #replace "Number of revolving accounts" with 0
    data.num_rev_accts = data[['num_rev_accts']].convert_objects(convert_numeric=True).fillna(0)

    #replace "Number of bankcard accounts" with sum of "Number of revolving accounts" and "Number of installment accounts"
    data.num_bc_tl[data.num_bc_tl==10101010]= data.num_rev_accts + data.num_il_tl

    #replace "Number of credit inquiries in past 12 months" with 0
    data.inq_last_12m = data[['inq_last_12m']].convert_objects(convert_numeric=True).fillna(0)

    #replace "Number of derogatory public records" with NA as it is important in determining FICO SCORE
    data.pub_rec = data[['pub_rec']].convert_objects(convert_numeric=True).fillna('NA')

    #replace "Average current balance of all accounts" with NA as it is important in determining FICO SCORE
    data.avg_cur_bal = data[['avg_cur_bal']].convert_objects(convert_numeric=True).fillna('NA')

    #replace "Months since oldest bank installment account opened" with "Months since oldest revolving account opened" which are not NA
    b1 = data.id.where(data.mo_sin_old_il_acct==10101010)
    b2 = data.id.where(data.mo_sin_old_rev_tl_op!=10101010)
    b3 = set(b1).intersection(b2)
    for i in b3:
        for j in data.id:
            if i==j:
                data.mo_sin_old_il_acct[data.id == j]= data.mo_sin_old_rev_tl_op

    #replace remaining "Months since oldest bank installment account opened" having "Months since oldest revolving account opened" as NA with "Months since most recent account opened"
    b1 = data.id.where(data.mo_sin_old_il_acct==10101010)
    b2 = data.id.where(data.mths_since_rcnt_il!=10101010)
    b3 = set(b1).intersection(b2)
    for i in b3:
        for j in data.id:
            if i==j:
                data.mo_sin_old_il_acct[data.id == j]= data.mths_since_rcnt_il


    #finally if few "Months since oldest bank installment account opened" values remains NA then replace all three month values with NA as 1
    data.mo_sin_old_il_acct[data.mo_sin_old_il_acct==10101010]=1
    data.mo_sin_old_rev_tl_op[data.mo_sin_old_rev_tl_op==10101010]=1
    data.mths_since_rcnt_il[data.mths_since_rcnt_il==10101010]=1  

    #replace "The number of months since the borrower's last delinquency" by 24 months if number of delinquency is 0 for last 2 years.
    b1 = data.id.where(data.delinq_2yrs==0)
    b2 = data.id.where(data.mths_since_last_delinq==10101010)
    b3 = set(b1).intersection(b2)
    for i in b3:
        for j in data.id:
            if i==j:
                data.mths_since_last_delinq[data.id == j]= 24
    data.mths_since_last_delinq[data.mths_since_last_delinq==10101010]=0  

    #replace "The number of inquiries in past 6 months" with "Number of credit inquiries in past 12 months"
    data.inq_last_6mths[data.inq_last_6mths==10101010]= data.inq_last_12m
    return data


# In[14]:

def calcFICO(data):
    fs = []
    data['FicoScore']=0

    for i in range(0,len(data)):
        fico = 0
        newCredSc = 0
        credMix = 0
        credHist = 0
        payHist = 0
        outDebt = 0
        ficoSc = 0

        #Pursuit of New Credit Score based on Number of inquiries in last 6 months
        if int(data[i:i+1].inq_last_6mths)==0:
            fico = 70
        elif int(data[i:i+1].inq_last_6mths)==1:
            fico = 60
        elif int(data[i:i+1].inq_last_6mths)==2:
            fico = 45
        elif int(data[i:i+1].inq_last_6mths)==3:
            fico = 25
        elif int(data[i:i+1].inq_last_6mths)>4 or int(data[i:i+1].inq_last_6mths)==4:
            fico = 20
        #print(fico)
        newCredSc = 0.1*fico
        fico=0
        #print(newCredSc)

        #Credit Mix Score based on Number of Bankcard trade lines
        if int(data[i:i+1].num_bc_tl)==0:
            fico = 15
        elif int(data[i:i+1].num_bc_tl)==1 or int(data[i:i+1].num_bc_tl)==5 or (int(data[i:i+1].num_bc_tl)>1 and int(data[i:i+1].num_bc_tl)<5):
            fico = 25
        elif int(data[i:i+1].num_bc_tl)==6 or int(data[i:i+1].num_bc_tl)==10 or (int(data[i:i+1].num_bc_tl)>6 and int(data[i:i+1].num_bc_tl)<10):
            fico = 37
        elif int(data[i:i+1].num_bc_tl)==11 or int(data[i:i+1].num_bc_tl)==20 or (int(data[i:i+1].num_bc_tl)>11 and int(data[i:i+1].num_bc_tl)<20):
            fico = 50
        elif int(data[i:i+1].num_bc_tl)==21 or int(data[i:i+1].num_bc_tl)==30 or (int(data[i:i+1].num_bc_tl)>21 and int(data[i:i+1].num_bc_tl)<30):
            fico = 60
        elif int(data[i:i+1].num_bc_tl)>30:
            fico = 80

        #print(fico)
        credMix = 0.1*fico
        fico=0 
        #print(credMix)

        #Credit History Length Score based on Number of months in file


        if int(data[i:i+1].mo_sin_old_il_acct)<12:
            fico = 12
        elif int(data[i:i+1].mo_sin_old_il_acct)==12 or int(data[i:i+1].mo_sin_old_il_acct)==23 or (int(data[i:i+1].mo_sin_old_il_acct)>12 and int(data[i:i+1].mo_sin_old_il_acct)<23):
            fico = 35
        elif int(data[i:i+1].mo_sin_old_il_acct)==24 or int(data[i:i+1].mo_sin_old_il_acct)==47 or (int(data[i:i+1].mo_sin_old_il_acct)>24 and int(data[i:i+1].mo_sin_old_il_acct)<47):
            fico = 60
        elif int(data[i:i+1].mo_sin_old_il_acct)>48 or int(data[i:i+1].mo_sin_old_il_acct)==48:
            fico = 75
        #print(fico)
        credHist = 0.15*fico
        fico=0 
        #print(credHist)    

        #Payment History Score based on Number of months since the most recent derogatory public record
        if data[i:i+1].pub_rec.equals('NA'):
            fico = 75
        elif int(data[i:i+1].pub_rec)==0 or int(data[i:i+1].pub_rec)==5 or (int(data[i:i+1].pub_rec)>0 and int(data[i:i+1].pub_rec)<5):
            fico = 10
        elif int(data[i:i+1].pub_rec)==6 or int(data[i:i+1].pub_rec)==11 or (int(data[i:i+1].pub_rec)>6 and int(data[i:i+1].pub_rec)<11):
            fico = 15
        elif int(data[i:i+1].pub_rec)==12 or int(data[i:i+1].pub_rec)==23 or (int(data[i:i+1].pub_rec)>12 and int(data[i:i+1].pub_rec)<23):
            fico = 25
        elif int(data[i:i+1].pub_rec)==24 or int(data[i:i+1].pub_rec)>24:
            fico = 55
        #print(fico)
        payHist = 0.35*fico
        fico=0 
        #print(credHist) 

        #Outstanding Debt Score based on Average Balance on revolving trades
        #if data[i:i+1].avg_cur_bal.equals('NA'):
        #    fico = 30
        #elif int(data[i:i+1].avg_cur_bal)==0:
        #    fico = 55
        #elif int(data[i:i+1].avg_cur_bal)==1 or int(data[i:i+1].avg_cur_bal)==50000 or (int(data[i:i+1].avg_cur_bal)>1 and int(data[i:i+1].avg_cur_bal)<50000):
        #    fico = 65
        #elif int(data[i:i+1].avg_cur_bal)==50001 or int(data[i:i+1].avg_cur_bal)==100000 or (int(data[i:i+1].avg_cur_bal)>50001 and int(data[i:i+1].avg_cur_bal)<100000):
        #    fico = 50
        #elif int(data[i:i+1].avg_cur_bal)==100001 or int(data[i:i+1].avg_cur_bal)==150000 or (int(data[i:i+1].avg_cur_bal)>100001 and int(data[i:i+1].avg_cur_bal)<150000):
        #    fico = 40
        #elif int(data[i:i+1].avg_cur_bal)==150001 or int(data[i:i+1].avg_cur_bal)==200000 or (int(data[i:i+1].avg_cur_bal)>150001 and int(data[i:i+1].avg_cur_bal)<200000):
        #    fico = 25
        #elif int(data[i:i+1].avg_cur_bal)>200000:
        #    fico = 15
        #print(fico)
        #outDebt = 0.30*fico
        #fico=0 
        #print(credHist)
        #ficoSc = newCredSc + credMix + credHist + payHist + outDebt
        ficoSc = newCredSc + credMix + credHist + payHist
        fs.append(ficoSc)
        #print(ficoSc)

    data['FicoScore']=fs
    return data


# In[15]:

def upbClac(data):
    #UPB Calculation
    upbL=[]
    data['UPB']=0
    for i in range(0,len(data)):
        upb=(int(data[i:i+1].total_pymnt)/((int(data[i:i+1].out_prncp))+ (int(data[i:i+1].total_pymnt))))*100
        upbL.append(upb)
        #print(upb)
    data['UPB']=upbL
    return data


# In[16]:

def riskScore(data):
    #Risk Score Percent Calculation
    data['RiskScorePercent']=0
    risk = []
    for i in range(0,len(data)):
        count = 0
        riskSrPercent = 0

        if int(data[i:i+1].dti)>43:
            count=count+1
        if int(data[i:i+1].UPB)<50:
            count=count+1
        if int(data[i:i+1].acc_now_delinq)>0:
            count=count+1
        if int(data[i:i+1].pct_tl_nvr_dlq)!=100:
            count=count+1
        riskSrPercent = (count/4)*100
        #print(riskSrPercent)
        risk.append(riskSrPercent)
    data['RiskScorePercent']=risk
    return data


# In[17]:

def openAccVsNumFund(data):
    #Analysing Number of Open Accounts vs Number of Funded loan

    a = data['open_acc']
    a = pd.DataFrame(a)
    a['Number of Funded loans'] = a.groupby('open_acc')['open_acc'].transform('count')
    a = a.drop_duplicates('open_acc')
    a =a.sort('open_acc')

    import matplotlib.pyplot as plt
    a.set_index('open_acc').plot(kind="bar")
    plt.show()
    return a


# In[18]:

def summaryMatrix(a):
    #Further Analysis of finding average interest rate and net returns vs Open accounts
    interestRate = []
    tot_pay = []
    for i in a['open_acc']:
        count = 0
        interest = 0.0
        tot_p = 0.0
        for j in range(0,len(data)):
            if i==int(data[j:j+1].open_acc):
                interest = interest + float(data[j:j+1].int_rate)
                count=count+1
                tot_p = tot_p + float(data[j:j+1].total_pymnt)
        interestRate.append(round((interest/count),2))
        tot_pay.append(round(tot_p,2))
    a['avg_interestRate']=interestRate
    a['net_returns'] = tot_pay
    a.to_csv('NetRetVSOpenAcc.csv')


# In[19]:

def LoanIssuanceByState(data):
    #Summarizing Loan Issuance by State
    state = []
    for i in data.addr_state:
        state.append(i)

    state = pd.DataFrame(state)
    state = state.drop_duplicates()
    state['State'] = state
    st=[]

    for i in state.State:
        st.append(i)

    loan = []

    for i in st:
        loSum = 0
        for j in range(0,len(data)):
            if data[j:j+1].addr_state.item() == i:
                loSum = loSum + int(data[j:j+1].funded_amnt_inv)
        loan.append(loSum)

    loan_issue = pd.DataFrame()
    loan_issue['State']=st
    loan_issue['Issued Loan'] = loan
    loan_issue =loan_issue.sort('Issued Loan')
    loan_issue.to_csv('LoanIssue.csv')


# In[21]:

def StateWiseNoAcceptedLoans(data):
    #Statewise Number of Accepted Loans
    acc = data['addr_state']
    acc = pd.DataFrame(acc)
    acc['Number_of_Accepted_Loans'] = acc.groupby('addr_state')['addr_state'].transform('count')
    acc = acc.drop_duplicates('addr_state')
    acc.to_csv('StateWise_AcceptedLoans.csv')


# In[22]:

def Feature_Engineering_data(data):
    #data = calcFICO(data)
    data = upbClac(data)
    data = riskScore(data)
    a = openAccVsNumFund(data)
    summaryMatrix(a)
    LoanIssuanceByState(data)
    StateWiseNoAcceptedLoans(data)
    return data


# In[23]:

class Login(luigi.Task):
     
    def requires(self):
        return []
 
    def output(self):
        return luigi.LocalTarget("Loan_combinedData.csv")
 
    def run(self):
        #loanStatsFileNamesJS
        loanData = login()
        loanData.to_csv("Loan_combinedData.csv", sep=",")


# In[24]:

class CleanUp(luigi.Task):

    def requires(self):
        return [Login()]
 
    def output(self):
        return luigi.LocalTarget("Clean_Loan_combinedData.csv")
 
    def run(self):
        loanData = pd.read_csv("Loan_combinedData.csv", encoding= 'iso-8859-1',low_memory=False)
        
        #print amount of missing values
        print('Handling Missing Data in approved Loan')
        loanData = columnDrop(loanData)
        loanData = Clean_data(loanData)
        #Write clean data to new CSV
        loanData.to_csv("Clean_Loan_combinedData.csv", sep=",") 


# In[25]:

class ExploratoryData(luigi.Task):
    def requires(self):
        return [CleanUp()]
 
    def output(self):
        return []
  
    def run(self):
        #loanData = pd.read_csv("Clean_Loan_combinedData.csv", encoding= 'iso-8859-1',low_memory=False)
        #Feature_Engineering_data(loanData)


# In[26]:

class UploadToS3(luigi.Task):
    awsKey = luigi.Parameter(config_path=dict(section='path',name='aws_key'))
    awsSecret = luigi.Parameter(config_path=dict(section='path',name='aws_secret'))
    def requires(self):
        return [ExploratoryData()]
    def output(self):
        return []
    def run(self):
        access_key = self.awsKey
        access_secret = self.awsSecret
        conn = boto.connect_s3(access_key,access_secret)
        TeamNumber='team3'
        bucket_name = TeamNumber+ '-ads-assignment-2'
        try:
            bucket = conn.create_bucket(bucket_name,location=boto.s3.connection.Location.DEFAULT)
        except Exception as e:
            print("Amazon access key or secret key is invalid")
        bucket = conn.get_bucket(bucket_name)
        k = Key(bucket)
        k.key = "Cleaned_Rejected_loans_combinedData.csv"
        k.set_contents_from_filename("Cleaned_Rejected_loans_combinedData.csv")
# In[243]:

if __name__ == '__main__':
    luigi.run()


# In[177]:




# In[173]:




# In[174]:




# In[175]:




# In[ ]:




# In[ ]:




# In[ ]:




# In[ ]:



