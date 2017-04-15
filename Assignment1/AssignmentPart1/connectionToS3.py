import boto
import boto.s3
import sys
from boto.s3.key import Key
import glob

AWS_ACCESS_KEY_ID = Access key
AWS_SECRET_ACCESS_KEY = Password
TeamNumber='team3'

bucket_name = TeamNumber+ '-ads-assignment-1'

conn = boto.connect_s3(AWS_ACCESS_KEY_ID,
        AWS_SECRET_ACCESS_KEY)

try:
    bucket = conn.create_bucket(bucket_name,location=boto.s3.connection.Location.DEFAULT)
    #log_entry("Connection with Amazon S3 bucket is successful.")
except Exception as e:  
    #log_entry("Amazon access key or secret key is invalid")
    print("Amazon access key or secret key is invalid")
    sys.exit()
    
#uploading multiple files
filenames=[]
#filenames =glob.glob(".\\'zip_"+str(CIK)+".zip")
#filenames.append("input_append.csv")
#filenames.append("Team3_Zip.zip")
#filenames.append(“logFile.txt”)
#filenames.append(“Report.pdf”)
filenames.append(“QUESTION 1.docx”)


def percent_cb(complete, total):
    sys.stdout.write('.')
    sys.stdout.flush()

for fname in filenames:
    bucket = conn.get_bucket(bucket_name)
    key = bucket.new_key(fname).set_contents_from_filename(fname,cb=percent_cb, num_cb=10)
    print ("uploaded file %s" % fname)
    #log_entry("{fname} has been uploaded.".format(fname=fname)) 