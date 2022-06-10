# Solution for Cloud hurdles

Here are the steps to solve cloud hurdles. 

# Task 1

The challenge description is, 
```
Get ready to clear 5 tasks to get to the flag, everything you need is in the Cloud project - bsidessf2022-recon, 
resources are in us-west1 or us-central1. 
Your first task is in the bucket - bsidessf-2022-task1.
```
Navigating to the bucket (**https://storage.googleapis.com/bsidessf-2022-task1/**) shows that there is only one file, **task2.txt**.
```
<ListBucketResult xmlns="http://doc.s3.amazonaws.com/2006-03-01">
<Name>bsidessf-2022-task1</Name>
<Prefix/>
<Marker/>
<IsTruncated>false</IsTruncated>
<Contents>
<Key>task2.txt</Key>
	<Generation>1652668999272303</Generation>
	<MetaGeneration>2</MetaGeneration>
	<LastModified>2022-05-16T02:43:19.273Z</LastModified
	<ETag>"514f3b184e97b4895588f13672400fd2"</ETag>
	<Size>65</Size>
	</Contents>
</ListBucketResult>
```
You can view **task2.txt** by visiting **https://storage.googleapis.com/bsidessf-2022-task1/task2.txt**.

# Task 2

The default Firebase realtime DB is usually at  ``https://<project-name>-default-rtdb.firebaseio.com``, so for ``bsidessf2022-recon`` it will be ``https://bsidessf2022-recon-default-rtdb.firebaseio.com``. 

This DB is misconfigured to be public, you can view it by visiting **https://bsidessf2022-recon-default-rtdb.firebaseio.com/.json**.  Which will show you the next clue. 

```
{"Task":"Good job, subscribe to bsidessf-2022-task3-sub for the next task"}
```

# Task 3

For this task, you'll need to pull messages from the sub ```bsidessf-2022-task3-sub```. You can use make an API call to [rest/v1/projects.subscriptions/pull](https://cloud.google.com/pubsub/docs/reference/rest/v1/projects.subscriptions/pull). 

### Request Parameters
* **subscription:** projects/bsidessf2022-recon/subscriptions/bsidessf-2022-task3-sub
* **body:** "maxMessages":10
* If you are using API playground, check the box for API key

Sample response, 
```
{
  "receivedMessages": [
    {
      "ackId": "RVNEUAYWLF1GSFE3GQhoUQ5PXiM_NSAoRRoHCBQFfH1xQ1p1VVkaB1ENGXJ8aXU5C0ZSBk0ALVVbEQ16bVxttPa6vURfQXFsWhEHAENbfF9dGgpvX1hdk_S2j-b8x01wYSuypfL3SH-q3MRkZiA9XxJLLD5-LTdFQV5AEkwmAkRJUytDCypYEU4EISE-MD4",
      "message": {
        "data": "bmV4dC10YXNr",
        "attributes": {
          "task4": "Awesome! The next task awaits you at cloud function bsidessf-2022-task4"
        },
        "messageId": "4602626820617734",
        "publishTime": "2022-05-16T03:32:04.477Z"
      }
    }
  ]
}
```

# Task 4

For this task, you'll invoke the cloud function ```bsidessf-2022-task3-sub``` by visiting **https://us-west1-bsidessf2022-recon.cloudfunctions.net/bsidessf-2022-task4**.

You will get the next clue, 
```
One last task, fetch the source code for this function to view the flag. You do need to be authenticated!
```

# Task 5

In a browser session with an authenticated Google account make an API call to [rest/v1/projects.locations.functions/generateDownloadUrl](https://cloud.google.com/functions/docs/reference/rest/v1/projects.locations.functions/generateDownloadUrl). 

### Request Parameters
* **name:** projects/bsidessf2022-recon/locations/us-west1/functions/bsidessf-2022-task4
* If you are using the API playground, check the box for OAuth and API key 

Sample response,
```
{
  "downloadUrl": "https://storage.googleapis.com/gcf-sources-373933237187-us-west1/bsidessf-2022-task4-3e94d742-f61f-42a1-90f8-c42f3d9926dc/version-1/function-source.zip?GoogleAccessId=service-373933237187@gcf-admin-robot.iam.gserviceaccount.com&Expires=1652675455&Signature=s9MCM9YOnmD4WFclEx0....snip...."
}
```


