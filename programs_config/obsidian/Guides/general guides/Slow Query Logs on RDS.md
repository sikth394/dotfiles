# Step 1

Find the db on RDS

![[Pasted image 20231225132646.png]]

# Step 2

Click on the `Logs & events` tab
![[Pasted image 20231225132806.png]]
  
  
  

Scroll down to the `Logs` section and filter for `slow`  
  
  
  
![[Pasted image 20231225132751.png]]
Select and download the file that is relevant to the time you need

# step 3

Make sure you have `percona-toolkit` installed ( `brew install percona-toolkit`)

Run `pt-query-digest <path_to_file_you_downloaded>` in order to print out the percona digest in your terminal  
  
  
![[Pasted image 20231225132832.png]]
Green = list of the 12 slowest queries on the DB, Blue= the time distribution of the slowest query (all triggers of this query were above 10 sec in the pic)

  
  
  
![[Pasted image 20231225132854.png]]
Full query can be found here, from the first “SELECT” until the end