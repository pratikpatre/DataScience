
# coding: utf-8

# In[ ]:

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


# In[ ]:

def login():
    #rejectedLoanStatsFileNamesJS
    rejected_loan = 'rejectedLoanStatsFileNamesJS'
    download_data(rejected_loan)
    rejected_data = read_data(rejected_loan)
    return rejected_data


# In[ ]:

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


# In[ ]:

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


# In[ ]:

def is_file_present(dataset,filename):
    if not os.path.exists(dataset):
        os.makedirs(dataset)
    #print(os.path.isdir(directory))
    file_list = glob.glob(dataset+'/*.csv')
    for file_name_in_dir in file_list:
        if (dataset+ '/' + filename) == (file_name_in_dir+".zip"):
            return True
    return False


# In[ ]:

def Clean_data(datad):
    #Missing Data Handling for Declined Loan Dataset

    #replace "Loan Title" with Others
    datad.loan_title = datad[['loan_title']].convert_objects(convert_numeric=True).fillna('Others')

    #replace "Risk Score" with 0 or Space with 300
    datad.risk_score = datad[['risk_score']].convert_objects(convert_numeric=True).fillna(300)
    datad.risk_score[datad.risk_score==0]=300

    #replace "DTI" with 0%. Handle -1% values with 0 and remove trailing '%' and divide by 100 to get the final DTI
    datad.dti = datad[['dti']].convert_objects(convert_numeric=True).fillna('0.0%')
    datad.dti[datad.dti==-1]='0.0%'
    datad['dti'] = datad['dti'].map(lambda x: x.rstrip('%'))
    datad['dti'] = datad['dti'].apply(lambda x: float(x)/100)

    #replace "ZIP code" with 000xx
    datad.zip_code = datad[['zip_code']].convert_objects(convert_numeric=True).fillna('000xx')

    #replace "State" with Other
    datad.state = datad[['state']].convert_objects(convert_numeric=True).fillna('Other')

    #replace "Employee Length" with 0 for '<1 year' and 10 for '10+year'
    datad.emp_len[datad.emp_len=='n/a']=0
    datad.emp_len[datad.emp_len=='< 1 year']=0
    datad.emp_len[datad.emp_len=='10+ years']=10
    #datad.loan_title = datad[['loan_title']].convert_objects(convert_numeric=True).fillna('Others')
    #replace "Risk Score" with 0 or Space with 300
    datad.risk_score = datad[['risk_score']].convert_objects(convert_numeric=True).fillna(300)
    datad.risk_score[datad.risk_score==0]=300

    #replace "DTI" with 0%. Handle -1% values with 0 and remove trailing '%' and divide by 100 to get the final DTI
    datad.dti = datad[['dti']].convert_objects(convert_numeric=True).fillna('0.0%')
    datad.dti[datad.dti==-1]='0.0%'
    datad['dti'] = datad['dti'].map(lambda x: x.rstrip('%'))
    datad['dti'] = datad['dti'].apply(lambda x: float(x)/100)

    #replace "ZIP code" with 000xx
    datad.zip_code = datad[['zip_code']].convert_objects(convert_numeric=True).fillna('000xx')

    #replace "State" with Other
    datad.state = datad[['state']].convert_objects(convert_numeric=True).fillna('Other')

    #replace "Employee Length" with 0 for '<1 year' and 10 for '10+year'
    datad.emp_len[datad.emp_len=='n/a']=0
    datad.emp_len[datad.emp_len=='< 1 year']=0
    datad.emp_len[datad.emp_len=='10+ years']=10
    datad.emp_len[datad.emp_len=='1 year']=1
    datad.emp_len[datad.emp_len=='2 years']=2
    datad.emp_len[datad.emp_len=='3 years']=3
    datad.emp_len[datad.emp_len=='4 years']=4
    datad.emp_len[datad.emp_len=='5 years']=5
    datad.emp_len[datad.emp_len=='6 years']=6
    datad.emp_len[datad.emp_len=='7 years']=7
    datad.emp_len[datad.emp_len=='8 years']=8
    datad.emp_len[datad.emp_len=='9 years']=9

    #replace "Policy Code" having blank and 0 values with 1
    datad.pol_code = datad[['pol_code']].convert_objects(convert_numeric=True).fillna(1)
    datad.pol_code[datad.pol_code==0]=1
    datad.emp_len[datad.emp_len=='1 year']=1
    datad.emp_len[datad.emp_len=='2 years']=2
    datad.emp_len[datad.emp_len=='3 years']=3
    datad.emp_len[datad.emp_len=='4 years']=4
    datad.emp_len[datad.emp_len=='5 years']=5
    datad.emp_len[datad.emp_len=='6 years']=6
    datad.emp_len[datad.emp_len=='7 years']=7
    datad.emp_len[datad.emp_len=='8 years']=8
    datad.emp_len[datad.emp_len=='9 years']=9

    #replace "Policy Code" having blank and 0 values with 1
    datad.pol_code = datad[['pol_code']].convert_objects(convert_numeric=True).fillna(1)
    datad.pol_code[datad.pol_code==0]=1
    return datad


# In[ ]:

def grossIncome(datad):
    #Calculating the Gross Income
    Gross = []
    for i in range(0,len(datad)):
        gro = 0.0
        if float(datad[i:i+1].dti) != 0.0:
            gro = (float(datad[i:i+1].amount_req))/(float(datad[i:i+1].dti))
            #print(gro)
            Gross.append(round(gro,2))
        else: 
            #print(0)
            Gross.append(0)
    datad['gross_income']=Gross
    return datad


# In[ ]:

def EmpFlag(datad):
    #EmployeeID Flag calculation
    empFlg = []
    for i in range(0,len(datad)):
        gro = 0.0
        if float(datad[i:i+1].dti) == 0.0 and int(datad[i:i+1].emp_len) == 0:
            empFlg.append('N')
        else: 
            empFlg.append('Y')
    datad['empFlg']=empFlg
    return datad


# In[ ]:

def declinedLoans(datad):
    #Statewise Number of Declined Loans
    dec = datad['state']
    dec = pd.DataFrame(dec)
    dec['Number_of_Declined_Loans'] = dec.groupby('state')['state'].transform('count')
    dec = dec.drop_duplicates('state')
    


# In[ ]:

##########################Statewise Number of Declined Loans and Number of Accepted Loans##############################
#usSt = []
#AccC = []
#DecC = []
#for i in range(0,len(acc)):
#    for j in range(0,len(dec)):
#        if acc[i:i+1].addr_state.item() == dec[j:j+1].state.item():
#            #print(acc[i:i+1].count)
#            usSt.append(acc[i:i+1].addr_state.item())
#            AccC.append(int(acc[i:i+1].Number_of_Accepted_Loans))
#            DecC.append(int(dec[j:j+1].Number_of_Declined_Loans))
#St_Wise = pd.DataFrame()
#St_Wise['State']=usSt
#St_Wise['Accepted Loan Count']=AccC
#St_Wise['Declined Loan Count']=DecC


# In[ ]:

def addYear(datad):
    #Adding Year column to the dataset

    datad['year']=pd.DatetimeIndex(datad['app_date']).year
    year = pd.DataFrame()
    year = datad['year']
    year = year.drop_duplicates()
    return datad


# In[ ]:

def summaryMatrix(datad):
    #Calculating Average Risk, Average DTI, Average GI, Average Amount Request and over the years.
    avgRisk = []
    avgDti = []
    avgAmtReq = []
    avgGI = []
    yr = []
    for i in year:
        riskScr = 0
        dti = 0.0
        amt_req = 0
        gi = 0.0
        count = 0
        avg_risk =0
        avg_dti = 0
        avg_amt_req=0
        avg_gi=0
        for j in range(0,len(datad)):
                if datad[j:j+1].year.item() == i:
                    riskScr = riskScr + int(datad[j:j+1].risk_score)
                    dti = dti + float(datad[j:j+1].dti)
                    amt_req = amt_req + int(datad[j:j+1].amount_req)
                    gi = gi + float(datad[j:j+1].gross_income)
                    count = count +1
        avg_risk = riskScr/count
        avg_dti = dti/count
        avg_amt_req = amt_req/count
        avg_gi = gi/count
        avgRisk.append(avg_risk)
        avgDti.append(avg_dti)
        avgAmtReq.append(avg_amt_req)
        avgGI.append(avg_gi)
        yr.append(i)

    avg = pd.DataFrame()
    avg['avgRisk'] = avgRisk
    avg['avgDti'] = avgDti
    avg['avgAmtReq'] = avgAmtReq
    avg['avgGI'] = avgGI
    avg['yr'] = yr   
    avg.to_csv('YearWise_Summary.csv')


# In[ ]:

def Feature_Engineering_data(datad):
    datad = grossIncome(datad)
    datad = EmpFlag(datad)
    datad = addYear(datad)
    declinedLoans(datad)
    summaryMatrix(datad)


# In[ ]:

class Login(luigi.Task):
     
    def requires(self):
        return []
 
    def output(self):
        return luigi.LocalTarget("Declined_Loan_combinedData.csv")
 
    def run(self):
        #loanStatsFileNamesJS
        loanData = login()
        loanData.to_csv("Declined_Loan_combinedData.csv", sep=",")


# In[ ]:

class CleanUp(luigi.Task):

    def requires(self):
        return [Login()]
 
    def output(self):
        return luigi.LocalTarget("Clean_Declined_Loan_combinedData.csv")
 
    def run(self):
        loanData = pd.read_csv("Declined_Loan_combinedData.csv", encoding= 'iso-8859-1',low_memory=False)
        
        #print amount of missing values
        print('Handling Missing Data in approved Loan')
        #loanData = Clean_data(loanData)
        #Write clean data to new CSV
        loanData.to_csv("Clean_Declined_Loan_combinedData.csv", sep=",") 


# In[ ]:

class ExploratoryData(luigi.Task):
    def requires(self):
        return [CleanUp()]
 
    def output(self):
        return []
  
    def run(self):
        loanData = pd.read_csv("Clean_Declined_Loan_combinedData.csv", encoding= 'iso-8859-1',low_memory=False)
        Feature_Engineering_data(loanData)


# In[ ]:

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
# In[ ]:

if __name__ == '__main__':
    luigi.run()

