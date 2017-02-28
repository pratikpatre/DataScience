install.packages("rvest")
install.packages("rPython")
library(rvest)
library(dplyr)
library(readr)
library(stringr)


dir.create("Part1_Files")

sink(file = "Part1_log.txt")
file_path_input <- paste(getwd(),"/input_append.csv", sep = "")
file_read <- read_csv(file_path_input)
cik <- c()
acc <- c()
for (i in 1:length(file_read)){
  if( toupper(file_read$Processing[i]) == 'Y'){
    cik <- file_read$CIK[i]
    acc <- file_read$Accession[i]
  }
}

name <- c()
print(paste(Sys.time(),"Fetching Master List for CIK",sep=" "))
temp <- tempfile()
download.file("https://www.sec.gov/edgar/NYU/cik.coleft.c",temp)
cik_list <- unlist(readLines(temp))

for (i in 1:length(cik_list)){
  if (grepl(cik,cik_list[i])){
    name <- unlist(strsplit(cik_list[i],":"))
  }
}

filename <- gsub(" ", "_", name[1])
field1 = substr(cik,regexpr("[^0]",cik),nchar(cik)) 
field2 = unlist(strsplit(acc,"-"))
print(paste(Sys.time(),"Generating files for CIK : ",field1," and name : ",name[1],sep=" "))

create_url_1 <- paste("https://www.sec.gov/Archives/edgar/data/",field1,"/",field2[1],field2[2],field2[3],"/",field2[1],"-",field2[2],"-",field2[3],"-index.html",sep = "")       
url_accession <- read_html(create_url)
url_accession %>% html_nodes(xpath = './/*[@id="formDiv"]/div/table') %>% .[[1]] %>% html_table(fill = TRUE) -> testTable

for (i in 1:length(testTable)){
  if (testTable$Description[i] == "10-Q"){
    field3 <- testTable$Document[i]
  }
  if(testTable$Description[i] == "FORM 10-K"){
    field3 <- testTable$Document[i]
  }
}

print(paste(Sys.time(),"Fetching from ",field1," and name : ",name[1],sep=" "))

create_url_2 <- paste("https://www.sec.gov/Archives/edgar/data/",field1,"/",field2[1],field2[2],field2[3],"/",field3,sep = "")

url1<- c()
url1 <- read_html(create_url_2)

if (is.null(url1)){
  url1 <- read_html("https://www.sec.gov/Archives/edgar/data/51143/000005114313000007/ibm13q3_10q.htm")
  print ("Please enter valid CIK and Aaccession key. The default url is taken into consideration now and i.e. - https://www.sec.gov/Archives/edgar/data/51143/000005114313000007/ibm13q3_10q.htm")
}

url1 %>% html_nodes("table") -> totalTable
length(totalTable) -> len
count <- 0
for (i in 1:(len)){
  url1 %>% html_nodes("table") %>% .[[i]] %>% html_table(fill = TRUE) -> testTable
  testinsert <- testTable
  bool <- FALSE
  k <- 0
  colm <- c()
  for (j in testTable){
    k <- k+1
    bool1 <- TRUE
    if(any(grepl('\\$',j))){
      if(!any(grepl('\\$[0-9_]+',j))){
        bool <- TRUE
        colm <- c(colm,k)
        bool1 <- FALSE
      }
    }
    if(colSums(is.na(data.frame(j)))>1){
      colm <- c(colm,k)
    }
    if(((sum(grepl('^\\s+$|^$',j)) / length(j))*100 ) > 80 & bool1){
      colm <- c(colm,k)
    }
  }
  if (bool){
    count <- count+1
    testinsert <- testinsert[-c(colm)]
    path_file <- getwd()
    var <- paste(path_file,"/Part1_Files/",filename,"_",count,".csv",sep="")
    print(paste(Sys.time(),"Generating file : ",var,sep=" "))
    write.csv(testinsert,var)
  }
}

dir('Part1_Files')
files2zip <- dir('Part1_Files', full.names = TRUE)
zip(zipfile = 'Team3_Zip', files = files2zip)

sink()

