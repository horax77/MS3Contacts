# MS3Contacts

Mulesoft API REST BackEnd API to manage CRUD operation over contacts 

## how to run it in debug mode

In anypoint studio debug arguments 
```bash
-M-XX:-UseBiasedLocking 
-M-Dfile.encoding=UTF-8 
-M-XX:+UseG1GC 
-M-XX:+UseStringDeduplication 
-DmuleKey=!muleKeyMS3!!!!! 
-Denv=dev
```
## unit test

This app has its own mule unit test process, here is the current coverage percentage

```
[INFO] ===============================================================================
[INFO] MUnit Coverage Summary
[INFO] ===============================================================================
[INFO]  * Resources: 7 - Flows: 18 - Processors: 81
[INFO]  * Application Coverage: 44.44%
[INFO] ====================================================================================
[INFO] MUnit Run Summary - Product: MULE_EE, Version: 4.3.0
[INFO] ====================================================================================
[INFO]  >> get-logics-test-suite.xml test result: Tests: 5, Errors: 0, Failures: 0, Skipped: 0
[INFO]
[INFO] ====================================================================================
[INFO]  > Tests:        5
[INFO]  > Errors:       0
[INFO]  > Failures:     0
[INFO]  > Skipped:      0
[INFO] ====================================================================================
```

To generate the jar file
```bash
mvn clean install -Denv=test
```

## GitHun Repository
```
https://github.com/horax77/MS3Contacts
```
## Postman Collection
```
https://www.getpostman.com/collections/261640e9ee7b395336b4
```
# 2 - app-dhub-supplier-purchase.xml

Based on a cron expression this process reads a file from SFTP folder and performs an upsert operation into Salesforce.

Source Folder: /GeoApp

```text
File: Dhub_Supplier Purchase.CSV
Target Folder: /GeoApp/archive
Cron Expression: "0 0 * 3,4,5 JAN,APR,JUL,OCT ? *"
```

Outputs in /archive:

```
1- Original File renamed as now() ++ Dhub_Supplier Purchase.CSV
2- In case of being errors during the process

	a- 2021-10-13T081158.129-0300Dhub_Supplier Purchase.CSV.error: will contain all those records that weren't able to be processed.
	b- 2021-10-13T081158.129-0300Dhub_Supplier Purchase.CSV.log: will contain all the errors description for each record failed in the previous file.
	
	Note: the number of records between both errors files will always the same.
```

## main flow: app-dhub-partner-supplier-Flow

```
1- Tries to read the file, if the file is not there, continues, logs the events and finishes.
2- If the file exists set the file key to check if it was already processed before.
   The key is formed as: summatory of Amount column + | + number of rows + | + file size in bytes
   Stores this information in an object Store and if this combination is present the file is refused and the event is logged.
3- Creates groups of 200 records and perform an bulk upsert operation for each group collecting the error information if applies.
4- If there were errors create the error files in destination and move the original file renamed.
```
## secondary flow: ObjectStoreMaintenance

According to Mulesoft documentation, to keep the object store data alive more than 30 days is needed to access the date at least once per week

```
Mule versions 4.2.1 and later:
Object stores have a rolling TTL by default.
If the data is accessed at least once a week, the TTL is extended for 30 days. Otherwise, it is evicted in the next 7 to 30 days from the most recent expiration date.
```
For this purpose was created a second Flows fired by a scheduler which only function is to retrieve all positions of the O.S. and logger its content.
The cron expression is set to run every Sunday at midnight -> 0 0 12 ? * SUN *

## /run

The API allows the user to run this process manually through an endpoint created for this purpose.

```bash
curl --location --request POST 'http://app-dhub-scheduled-procs-dev.us-e1.cloudhub.io//run' \
--header 'Content-Type: application/json' \
--header 'Cookie: COOKIE_SUPPORT=true; GUEST_LANGUAGE_ID=en_US' \
--data-raw '{}'
```
## Sequence Diagram

![remittance chart](./docs/images/app-dhub-scheduled-procs-supplier.png "supplier upsert sequence diagram")



# 3 - app-dhub-partner-document.xml

Based on a cron expression this process reads three STP folders and subfolders and for each file found within each sub-folder, upsert Partner Documents Objects in Salesforce (associated with the file) and attachs the versionted file to it.

# main flow: app-dhub-partner-document-Flow

* The three root folders to read are
  * /Site/pdfs/__GIP - /Site/pdfs/__CJP - /Site/pdfs/__NPPC
  * If some new base folder will be added, that value will have to be included in this global property -> foldersToProcces: "__GIP/,__CJD/,__NPPC/"
  * These values without the undescores represent the Type field of the Partner Document object to create.
* Within each base folder will have a series of sub-folders which names represent the year: 2021, 2022, 2023. The logic of the process will discard all those folder which name is not a valid year.
* Within each year folder will have a different set of sub-folders based on the type of root folder we are in.
  * For GIP one:
    * We will have a list of sub-folders representing the Distributor Names, these folder names will be used to find the DistributorId into the LookUp. 
  * For Other ones:
    * We will have a list of sub-folders representing the year's quarter: Q1, Q2, Q3, Q4. Will be processed only those folders which name is included in this global property --> partnerDocument.sftp.quarterFolders
    * Under this folder layer we will found the list of sub-folders representing the Distributor Names, these folder names will be used to find the DistributorId into the LookUp. 
* Finally, within each distibutor sub-folder we can have files. For each file
  * We will perform an upsert operation in Partner_Document__c 
  * We will create a new version of the file as a Salesforce Content Document Version and will be linked to the just upserted Partner_Document_C record.
* Once all the steps finalized OK the process will move the file into the "archive" folder (will be created if doesn't exist) with the file renamed as timestamp ++ OriginalName
* Partner_Document_C mapping
  * Name: Name of the file,
  * Document_Type__c: "GIP" / "CJD" / "NPPC", 
  * Parent_Account__r: {
          "type": 'Account',
	  "sap_Account_number__c": DistributorName (name of the sub-folder)
      },
  * External_id__c: 
    * For GIP elements : DistributorName ++ '_' ++ Document Type ++ '_' ++ Year ++ File Name
      * Example: "Envoy_GIP_2021_FileName"
    * For CJD, NPPC element: DistributorName ++ '_' ++ Document Type ++ '_' ++ Year ++ '_' ++ Quarter ++ '_' ++ File Name
      * Example: "Envoy_CJD_2021_Q1_FileName"  
  * Posted_date__c: Date,
  * Externally_Visible__c: true
* During the process, and for each base folder, a log in csv format is collected and once this folder is full processed the file is created in the root path of the folder is being exectued. 

## salesforce content document data model

![remittance chart](./docs/images/ContentDocumentDataModel.png "content document data model")

## Sequence Diagram

![remittance chart](./docs/images/app-dhub-partner-document.png "partner document sequence diagram")

### Partner Document Process File

![remittance chart](./docs/images/app-dhub-partner-document-fileProc.png "content document data model")


  
